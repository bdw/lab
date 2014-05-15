package ePub;
use 5.10.0;
use Archive::Zip qw(:CONSTANTS);
use HTML::Entities qw(:DEFAULT encode_entities_numeric);
use Data::Dumper;
use strict;


sub new {
    my $class = shift;
    my $self = {
        docs => [], figures => {},
        title => '', author => '', isbn => 0
    };
    bless $self, $class;
}

sub set_meta {
    my $self = shift;
    my %meta = @_;
    my ($k,$v);
    while(($k,$v) = each(%meta)) {
        $self->{$k} = encode_entities_numeric($v);
    }
}

sub initialize_archive {
    my $zip = shift;
    my $member = $zip->addString('application/epub+zip', 'mimetype');
    $member->desiredCompressionMethod( COMPRESSION_STORED );
    $zip->addDirectory('META-INF');
    $zip->addDirectory('OEBPS');
    my $rootfile = <<ROOT;
<?xml version="1.0"?>
	<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
	<rootfiles>
	<rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
	</rootfiles>
</container>
ROOT
    $zip->addString($rootfile, 'META-INF/container.xml');
    $zip->addDirectory('OEBPS/figures');
}

sub add_stylesheet {
    my $zip = shift;
    my $cssfile = <<CSS;
h1.section { text-decoration: underline; text-align: center; }
h1.chapter { text-decoration: underline; }

p { margin-bottom: 0px; text-align: justify; }
p + p { text-indent: 1em;  margin-top: 0px; }

div { font-size: smaller; border: thin solid gray; margin-bottom: 5px; }
div h3 { text-align: center; }
div p { margin: 0px 5px 0px 5px; }
div.figure { text-align: center; } 

ul, ol { margin-top: 1em; }
li p { margin-top: 0px; }
li ul, li ol { margin-top: 0em; }

td { vertical-align: top;  }
img { max-width: 100%; } 
CSS
    $zip->addString($cssfile, 'OEBPS/style.css');
}


sub add_doc {
    my ($self, $doc) = @_;
    push @{$self->{docs}}, $doc;
}

sub add_fig {
    my ($self, $figure) = @_;
    my $name = $figure->{name};
    return if defined $self->{figures}->{name};
    $self->{figures}->{$name} = $figure;
}

sub add_content {
    my ($self, $archive) = @_;
    for my $doc (@{$self->{docs}}) {
        my $member = $archive->addString($doc->content, 'OEBPS/' . $doc->fileName);
        $member->desiredCompressionLevel(9);
    }
    for my $fig (values %{$self->{figures}}) {
        my $member = $archive->addString($fig->{data}, 
                                         'OEBPS/figures/' . $fig->fileName);
        $member->desiredCompressionLevel(0); 
# after-compression is not very effective in GIF files
    }
}


sub add_content_file {
    my ($self, $archive) = @_;
    my $boilerplate = <<HEAD;
<?xml version="1.0"?>
<package version="2.0" xmlns="http://www.idpf.org/2007/opf"
         unique-identifier="BookId">
 <metadata xmlns:dc="http://purl.org/dc/elements/1.1/"
           xmlns:opf="http://www.idpf.org/2007/opf">
   <dc:title>$self->{title}</dc:title>
   <dc:creator opf:role="aut">$self->{author}</dc:creator>
   <dc:language>en-US</dc:language>
   <dc:rights>None</dc:rights>
   <dc:publisher></dc:publisher>
   <dc:identifier id="BookId">urn:uuid:$self->{isbn}</dc:identifier>
</metadata>
HEAD
    my $manifest = $self->build_manifest();
    my $spine = $self->build_spine();
    my $contentfile = $boilerplate . $manifest . $spine . '</package>';
    $archive->addString($contentfile, 'OEBPS/content.opf');
}

sub build_manifest {
    my $self = shift;
    my @manifest = ('<item id="ncx" href="toc.ncx" media-type="text/xml" />');
    push @manifest, '<item id="style" href="style.css" media-type="text/css"/>';
    for my $doc (@{$self->{docs}}) {
        my $line = sprintf('<item id="%s" href="%s" media-type="%s" />',
                           $doc->id, $doc->fileName, 'application/xhtml+xml');
        push @manifest, $line;
    }
    for my $fig (values %{$self->{figures}}) {
        my $line = sprintf('<item id="%s" href="figures/%s" media-type="%s" />',
                           $fig->id, $fig->fileName, $fig->{mime});
        push @manifest, $line;
    }
    return '<manifest>' . join("\n", @manifest) . '</manifest>';
}

sub build_spine {
    my $self = shift;
    my @spine;
    for my $doc (@{$self->{docs}}) {
        push @spine, sprintf('<itemref idref="%s" />', $doc->id);
    }
    return '<spine toc="ncx">' . join("\n\t", @spine) . '</spine>';
}

sub add_toc {
    my ($self, $zip) = @_;
    unless(defined $self->{nav}) {
        $self->{nav} = ePub::DocRef->buildTree($self->{docs});
    }
    my $navMap = ePub::DocRef::navMap($self->{nav});
    my $boilerplate = <<TOC;
<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta name="dtb:uid" content="$self->{isbn}"/>
    <meta name="dtb:depth" content="1"/>
    <meta name="dtb:totalPageCount" content="0"/>
    <meta name="dtb:maxPageNumber" content="0"/>
  </head>
  <docTitle>
    <text>$self->{title}</text>
  </docTitle>
  <navMap>
TOC
    my $toc_content = $boilerplate . $navMap . '</navMap></ncx>';
    $zip->addString($toc_content, 'OEBPS/toc.ncx');
}

sub save {
    my ($self, $file) = @_;
    my $archive = Archive::Zip->new();
    initialize_archive($archive);
    add_stylesheet($archive);
    $self->add_content($archive);
    $self->add_content_file($archive);
    $self->add_toc($archive);
    $archive->writeToFileNamed($file);
}



package ePub::DocRef;
# TODO fix the tree building algotrithm

sub new {
    my ($class, $t, $f, $i, $c,) = @_;
    bless { title => $t, file => $f,
            id => $i,  count => $c, childs => [] }, $class;
}

sub imagine {
    my ($class, $title, $parent) = @_;
    bless {
        title => $title, file => $parent->{file},
        id => $parent->{id}, count => $parent->{count},
        childs => [] }, $class;
}

sub buildTree {
    my ($class, $docs) = @_;
    my ($count, $depth, $tree) = (1,1,[]);
    my ($root, $ref, @stack) = ($tree);
    for my $doc (@$docs) {
        my @title = $doc->title;
        if($title[0] eq 'Unknown') {
            # do nothing
        } else {
            while($depth < @title) {
                push @stack, $tree;
                $tree = $ref->{childs};
                $ref = $class->imagine($title[$depth], $ref);
                push @$tree, $ref if ($depth + 1 < @title);
            } continue { $depth++; }
            while($depth > @title) {
                $tree = pop @stack;
            } continue { $depth--; }
        }
        $ref = $class->new(pop(@title), $doc->fileName, $doc->id, $count++);
        push @$tree, $ref;
    }
    bless $root, $class;
}

sub navMap {
    my $list = shift;
    my @points = map { $_->navPoint } @$list;
    join('', @points);
}

sub navPoint {
    my $self = shift;
    my $point = sprintf('<navPoint id="%s" playOrder="%d">', $self->{id}, $self->{count});
    my $label = sprintf('<navLabel><text>%s</text></navLabel><content src="%s" />',
                        $self->{title}, $self->{file});
    my $childs = navMap($self->{childs});
    my $end = sprintf('</navPoint>');
    return $point . $label . $childs . $end;
}

package ePub::Figure;
use GD;
@ePub::Figure::colors = qw(0 17 34 51 68 85 102 119 136 153 170 187 204 221 238 255);
$ePub::Figure::maxWidth = 750;

sub optimize {
    my $self = shift;
    my $im = GD::Image->new($self->{data});
    if($im->width > $ePub::Figure::maxWidth) {
        my $new = GD::Image->new($ePub::Figure::maxWidth,
                                 int($im->height * $ePub::Figure::maxWidth / $im->width), 1);
        $new->copyResampled($im, 0, 0, 0, 0, $new->width, $new->height,
                            $im->width, $im->height);
        $im = $new;
    }
    my $new = GD::Image->new($im->width, $im->height, 0);
    for(@ePub::Figure::colors) {
        $new->colorAllocate($_, $_, $_);
    }
    for(my $y = 0; $y < $im->height; $y++) {
        for(my $x = 0; $x < $im->width; $x++) {
            my $color = $new->colorClosest($im->rgb($im->getPixel($x, $y)));
            $new->setPixel($x, $y, $color);
        }
    }
    $self->{data} = $new->gif;
    $self->{mime} = 'image/gif';
}

sub new {
    my ($class, $name, $data, $type) = @_;
    bless { name => $name, data => $data, mime => $type }, $class;
}


sub fileName {
    my $self = shift;
    return $self->{name};
}

sub id {
    my $id = $_[0]->{name};
    $id =~ tr/A-Z/a-z/;
    $id =~ s/[^a-z0-9]//g;
    $id =~ s/^[0-9]+//;
    return $id;
}


package ePub::Document;

sub new {
    my ($class, $title, $content) = @_;
    bless { title => $title, content => $content }, $class;
}

sub title {
    my $self = shift;
    return wantarray ? split (/ - /, $self->{title}) : $self->{title};
}

sub content {
    my $self = shift;
    my $head = <<HEAD;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
<head><title>$self->{title}</title>
<link rel="stylesheet" type="text/css" href="style.css" />
</head><body>
HEAD
   return $head . $self->{content} . '</body></html>';
}

sub fileName {
    my $name = $_[0]->{title};
    $name =~ s/[^-_a-z0-9 .]//ig;
    return $name . '.xhtml';
}

sub id {
    my $id = $_[0]->{title};
    $id =~ tr/A-Z/a-z/;
    $id =~ s/[^a-z0-9]//g;
    $id =~ s/^[0-9]+//;
    return $id;
}



return 1;


