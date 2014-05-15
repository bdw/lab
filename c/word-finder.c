#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define LETTER(x) ( tolower((x)) - 'a' )

int usage(char * name) {
	printf("Usage: %s <word>\n", name);
	return 1;
}

int error(char * msg) {
	puts(msg);
	exit(1);
}

void build_tokens(int * alphabet, char * word) {
	memset(alphabet, 0, 26*sizeof(int));
	for(;*word; word++) {
		if(!isalpha(*word)) error("Non-alphabetic character encountered");
		alphabet[ LETTER(*word) ] += 1;
	}	
}	

void dump_tokens(int * alphabet) {
	int i;
	for(i = 0; i < 26; i++) {
		printf("%c: %d\n", i + 'a', alphabet[i]);
	}
}

int match_word(char * word, int * tokens) {
	int i, copy[26];
	memcpy(copy, tokens, 26 * sizeof(int));
	for(i = 0; word[i] && isalpha(word[i]); i++) {
		if(!(copy[LETTER(word[i])]--)) return 0; /* the magic line */
	}
	return (i > 2) && !(word[i+1]);
}

void scan_file(char * filename, int * tokens) {
	FILE * fd = fopen(filename, "r");
	while(!feof(fd)) {
		char word[80];
		fgets(word, 80, fd);
		if(match_word(word, tokens))
			printf("%s", word);
	}
	fclose(fd);
}

int main(int argc, char *argv[]) {
	int tokens[26];
	if(argc < 2) return usage(argv[0]);
	build_tokens(tokens, argv[1]);
	scan_file("/usr/share/dict/words", tokens);
	return 0;
}


