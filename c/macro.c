#define COMMA ,
#define FOO(_) _(x) COMMA _(y) COMMA _(z) COMMA _(c)
#define SHIFT(x) (1 << (x))
#define ID(x) x
static int foo[] = { FOO(ID) }
#undef COMMA
#define COMMA |
int i = FOO(SHIFT);
#undef COMMA
#define COMMA
#define UNDERSCORE(x) _ ## x
FOO(UNDERSCORE)
