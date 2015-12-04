#!/usr/bin/env perl
use Data::Dumper;
use List::Util qw(sum);
use sexpr;
use warnings;
use strict;



# shorthand for numeric sorts
sub sortn {
    sort { $a <=> $b } @_;
}

# Get unique items in tree
sub uniq {
    my %h;
    $h{$_}++ for @_;
    return keys %h;
}

sub avg {
    return (sum(@_))/ scalar @_
}

package rule {
    my $pseudosym = 0;
    sub add {
        my ($name, $tree, $sym, $cost) = @_;
        my $ctx = {
            # lookup path for values
            path => [],
            regs => 0,
            num  => 0,
        };
        my @rules = decompose($ctx, $tree, $sym, $cost);
        my $head = $rules[$#rules];
        $head->{name} = $name;
        $head->{path} = join('', @{$ctx->{path}});
        $head->{regs} = $ctx->{regs};
        $head->{text} = sexpr::encode($tree);
        return @rules;
    }


    sub new {
        # Build a new, fully decomposed rule
        my ($class, $pat, $sym, $cost) = @_;
        return {
            pat  => $pat,
            sym  => $sym,
            cost => $cost
        };
    }

    sub decompose {
        my ($ctx, $tree, $sym, $cost, @trace) = @_;
        my $list  = [];
        my @rules;
        # Recursively replace child nodes by pseudosymbols
        for (my $i = 0; $i < @$tree; $i++) {
            my $item = $tree->[$i];
            if (ref $item eq 'ARRAY') {
                # subtree, which has to be replaced with a symbol
                my $newsym = sprintf("#%s", $pseudosym++);
                # divide cost by two
                $cost /= 2;
                # add rule and subrules to the list
                push @rules, decompose($ctx, $item, $newsym, $cost, @trace, $i);
                push @$list, $newsym;
            } elsif (substr($item, 0, 1) eq '$') {
                # argument symbol
                # add trace to path
                push @{$ctx->{path}}, @trace, $i, '.';
                $ctx->{num}++;
            } else {
                if ($i > 0) {
                    # value symbol
                    push @{$ctx->{path}}, @trace, $i, '.';
                    # this is a value symbol, so add it to the bitmap
                    $ctx->{regs}  += (1 << $ctx->{num});
                    $ctx->{num}++;
                } # else head
                push @$list, $item;
            }
        }
        push @rules, rule->new($list, $sym, $cost);
        return @rules;
    }

    sub combine {
        my @rules = @_;
        # %sets represents the symbols which can occur in combination (symsets)
        # %trie is the table that holds all combinations of rules and symsets
        my (%sets, %trie);
        # Initialize the symsets with just their own symbols
        $sets{$_->{sym}} = [$_->{sym}] for @rules;
        my ($added, $deleted, $iterations);
        do {
            $iterations++;
            # Generate a lookup table to translate symbols to the
            # combinations (symsets) they appear in
            my %lookup;
            while (my ($k, $v) = each %sets) {
                # Use a nested hash for set semantics
                $lookup{$_}{$k} = 1 for @$v;
            }
            # Reset trie
            %trie = ();
            # Translate symbols in rule patterns to symsets and use these to
            # build the combinations of matching rules
            for (my $rule_nr = 0; $rule_nr < @rules; $rule_nr++) {
                my $rule = $rules[$rule_nr];
                # The head is significant because this represent the expression node we match
                my ($head, $sym1, $sym2) = @{$rule->{pat}};
                if (defined $sym2) {
                    # iterate over all symbols in the symsets
                    for my $s_k1 (keys %{$lookup{$sym1}}) {
                        for my $s_k2 (keys %{$lookup{$sym2}}) {
                            # This rule could match all combinations of $s_k1 and $s_k2 that appear
                            # here because their matching symbols are contained in these symsets.
                            # Here we are interested in all the other rules that also match these
                            # symsets and the symbols these rules generate in combination. Thus,
                            # we generate a new table here.
                            $trie{$head, $s_k1, $s_k2}{$rule_nr} = $rule->{sym};
                        }
                    }
                } elsif (defined $sym1) {
                    # Handle the one-item case
                    for my $s_k1 (keys %{$lookup{$sym1}}) {
                        $trie{$head, $s_k1, -1}{$rule_nr} = $rule->{sym};
                    }
                } else {
                    $trie{$head, -1, -1}{$rule_nr} = $rule->{sym};
                }
            }
            # Read the symsets from the generated table, generate a
            # key to identify them and replace the old %sets table
            my %new_sets;
            for my $gen (values %trie) {
                my @set = sort(main::uniq(values %$gen));
                my $key = join(':', @set);
                $new_sets{$key} = [@set];
            }
            # This loop converges the symsets to an unchanging and complete
            # set of symsets. That seems to be because a symsets is always
            # formed by the combination of other symsets that happen to be
            # applicable to the same rules. The combined symset is still
            # applicable to those rules (thus a symset is never lost, just
            # embedded into a larger symset). When symsets stop changing that
            # must be because they cannot be combined further, and thus the
            # set is complete.
            $deleted = 0;
            for my $k (keys %sets) {
                $deleted++ unless exists $new_sets{$k};
            }
            $added = scalar(keys %new_sets) - scalar(keys %sets) + $deleted;
            # Continue with newly generated sets
            %sets = %new_sets;
        } while ($added || $deleted);

        # Given that all possible symsets are known, we can now read
        # the rulesets from the %trie as well.
        my (%seen, @rulesets);
        for my $symset (values %trie) {
            my @rule_nrs = main::sortn(keys %$symset);
            my $key = join $;, @rule_nrs;
            push @rulesets, [@rule_nrs] unless $seen{$key}++;
        }
        return @rulesets;
    }

    sub set_key {
        my @rule_nrs = @_;
        return join ":", main::sortn(@rule_nrs);
    }
};




sub generate_table {
    # Compute possible combination tables and minimum cost tables from
    # rulesets. Requires rules (pattern + symbol + cost) and rulesets
    # (indices into rules).

    my ($rules, $rulesets) = @_;

    print "Rules:\n";
    for (my $rule_nr = 0; $rule_nr < @$rules; $rule_nr++) {
        print "$rule_nr => ";
        print sexpr::encode($rules->[$rule_nr]{pat}), ": ", $rules->[$rule_nr]{sym} , "\n";
    }

    print "Rulesets:\n";
    for (my $ruleset_nr = 0; $ruleset_nr < @$rulesets; $ruleset_nr++) {
        print "$ruleset_nr => ";
        for my $rule_nr (@{$rulesets->[$ruleset_nr]}) {
            print "$rule_nr, ";
        }
        print "\n";
    }


    my (%candidates, %trans);
    # map symbols to rulesets, rule set names to ruleset numbers
    for (my $ruleset_nr = 0; $ruleset_nr < @$rulesets; $ruleset_nr++) {
        my $ruleset = $rulesets->[$ruleset_nr];
        for my $rule_nr (@$ruleset) {
            $candidates{$rules->[$rule_nr]{sym}}{$ruleset_nr} = 1;
        }
        my $key = rule::set_key(@$ruleset);
        $trans{$key} = $ruleset_nr;
    }

    # build flat table first
    my %flat;
    for (my $rule_nr = 0; $rule_nr < @$rules; $rule_nr++) {
        my $rule = $rules->[$rule_nr];
        my ($head, $sym1, $sym2) = @{$rule->{pat}};
        if (defined $sym2) {
            for my $rs1 (keys %{$candidates{$sym1}}) {
                for my $rs2 (keys %{$candidates{$sym2}}) {
                    $flat{$head,$rs1,$rs2}{$rule_nr} = 1;
                }
            }
        } elsif (defined $sym1) {
            for my $rs1 (keys %{$candidates{$sym1}}) {
                $flat{$head,$rs1,-1}{$rule_nr} = 1;
            }
        } else {
            $flat{$head,-1,-1}{$rule_nr} = 1;
        }
    }

    # with the flat table, we can directly build the tiler table by expanding the keys
    my %table;
    while (my ($idx, $match) = each %flat) {
        my ($head, $rs1, $rs2) = split $;, $idx;
        my $key = rule::set_key(keys %$match);
        die "Cannot find key $key" unless defined $trans{$key};
        $table{$head}{$rs1}{$rs2} = $trans{$key};
    }
    return %table;
}


sub compute_costs {
    my ($rules, $rulesets, $table) = @_;

    my %reversed;
    for my $head (keys %$table) {
        for my $rs1 (keys %{$table->{$head}}) {
            for my $rs2 (keys %{$table->{$head}->{$rs1}}) {
                my $rsy = $table->{$head}{$rs1}{$rs2};
                push @{$reversed{$rsy}}, [$rs1, $rs2];
            }
        }
    }
    # new attempt; converge at %min_cost.
    # seed %rule_cost with the minimum-zero-order cost, %min_cost according to that
    # compute first order cost using the seeded zero-order cost,
    # compute minimum cost table again; while it remains changing,
    # compute again with updated costs
    my %rule_cost;
    my %min_cost;


    for (my $ruleset_nr = 0; $ruleset_nr < @$rulesets; $ruleset_nr++) {
        for my $rule_nr (@{$rulesets->[$ruleset_nr]}) {
            my $cost = $rules->[$rule_nr]{cost};
            my $sym  = $rules->[$rule_nr]{sym};
            my $best = $min_cost{$ruleset_nr, $sym};
            if (!defined($best) || $rule_cost{$ruleset_nr, $best} > $cost) {
                $min_cost{$ruleset_nr, $sym} = $rule_nr;
            }
            $rule_cost{$ruleset_nr, $rule_nr} = $cost;
        }
    }

    print "Initial:\n";
    for my $key (sort keys %min_cost) {
        my ($ruleset_nr, $sym) = split /$;/, $key;
        print "$ruleset_nr $sym $min_cost{$key}\n";
    }

    my $changed = 0;
    do {
        my %new_cost;
        my %new_min;
        for (my $ruleset_nr = 0; $ruleset_nr < @$rulesets; $ruleset_nr++) {
            for my $rule_nr (@{$rulesets->[$ruleset_nr]}) {
                my $cost = $rules->[$rule_nr]->{cost};
                my ($head, $sym1, $sym2) = @{$rules->[$rule_nr]->{pat}};
                # compute new cost of rule
                for my $rsg (@{$reversed{$ruleset_nr}}) {
                    $cost += $rule_cost{$rsg->[0], $min_cost{$rsg->[0], $sym1}} if defined $sym1;
                    $cost += $rule_cost{$rsg->[1], $min_cost{$rsg->[1], $sym2}} if defined $sym2;
                }
                $cost /= scalar @{$reversed{$ruleset_nr}};
                # determine new minimum cost rule
                my $sym = $rules->[$rule_nr]->{sym};
                my $best = $new_min{$ruleset_nr, $sym};
                if (!defined ($best) || $new_cost{$ruleset_nr, $best} > $cost) {
                    $new_min{$ruleset_nr, $sym} = $rule_nr;
                }
                $new_cost{$ruleset_nr, $rule_nr} = $cost;
            }

        }
        $changed = 0;
        # nb, i assume we've converged after the *relative* cost of rules doesn't change,
        # but i only compute whether the *top* rule hasn't changed, and that's actually
        # not sufficient in some cases
        for my $key (keys %min_cost) {
            die "huh $key" if !defined $new_min{$key};
            $changed++ if $min_cost{$key} != $new_min{$key};
        }

        %rule_cost = %new_cost;
        %min_cost  = %new_min;
    } while($changed);
    return %min_cost;
}

# Collect rules -> form list, table;
# list contains 'shallow' nodes, maps rulenr -> rule
# indirectly create rulenr -> terminal

# Use a readable hash key separator
local $; = ",";

my $input = \*DATA;
my @_rules;

# Collect rules from the grammar
my $parser = sexpr->parser($input);
while (my $tree = $parser->read) {
    my $keyword = shift @$tree;
    if ($keyword eq 'tile:') {
        push @_rules, rule::add(@$tree);
    }
}
close $input;


my @_rulesets  = rule::combine(@_rules);
my %_table     = generate_table(\@_rules, \@_rulesets);
my %_min_cost  = compute_costs(\@_rules, \@_rulesets, \%_table);
print "Second:\n";
for my $key (sort keys %_min_cost) {
    my ($ruleset_nr, $sym) = split /$;/, $key;
    print "$ruleset_nr $sym $_min_cost{$key}\n";
}


__DATA__
# Minimal grammar to test tiler table generator
(tile: a (local) reg 1)
(tile: b (const) reg 2)
(tile: c (and reg reg) reg 2)
(tile: d (nz reg) flag 2)
(tile: o (addr reg) reg 2)
(tile: l (load (addr reg)) reg 5)
(tile: g (load reg) reg 4)
(tile: v (nz (and (load (addr reg)) (const))) flag 6)
(tile: e (nz (and reg (const))) flag 5)
