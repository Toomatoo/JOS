
obj/user/echo.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 d3 00 00 00       	call   800104 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800043:	83 ff 01             	cmp    $0x1,%edi
  800046:	0f 8e 8a 00 00 00    	jle    8000d6 <umain+0xa2>
  80004c:	c7 44 24 04 c0 23 80 	movl   $0x8023c0,0x4(%esp)
  800053:	00 
  800054:	8b 46 04             	mov    0x4(%esi),%eax
  800057:	89 04 24             	mov    %eax,(%esp)
  80005a:	e8 1c 02 00 00       	call   80027b <strcmp>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  80005f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800066:	85 c0                	test   %eax,%eax
  800068:	0f 85 86 00 00 00    	jne    8000f4 <umain+0xc0>
		nflag = 1;
		argc--;
  80006e:	83 ef 01             	sub    $0x1,%edi
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800071:	83 ff 01             	cmp    $0x1,%edi
  800074:	0f 8e 81 00 00 00    	jle    8000fb <umain+0xc7>

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
  80007a:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  80007d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800084:	eb 6e                	jmp    8000f4 <umain+0xc0>
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
		if (i > 1)
  800086:	83 fb 01             	cmp    $0x1,%ebx
  800089:	7e 1c                	jle    8000a7 <umain+0x73>
			write(1, " ", 1);
  80008b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 c3 23 80 	movl   $0x8023c3,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000a2:	e8 57 0d 00 00       	call   800dfe <write>
		write(1, argv[i], strlen(argv[i]));
  8000a7:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 be 00 00 00       	call   800170 <strlen>
  8000b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000c4:	e8 35 0d 00 00       	call   800dfe <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000c9:	83 c3 01             	add    $0x1,%ebx
  8000cc:	39 fb                	cmp    %edi,%ebx
  8000ce:	7c b6                	jl     800086 <umain+0x52>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d4:	75 25                	jne    8000fb <umain+0xc7>
		write(1, "\n", 1);
  8000d6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000dd:	00 
  8000de:	c7 44 24 04 d3 24 80 	movl   $0x8024d3,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ed:	e8 0c 0d 00 00       	call   800dfe <write>
  8000f2:	eb 07                	jmp    8000fb <umain+0xc7>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  8000f4:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000f9:	eb ac                	jmp    8000a7 <umain+0x73>
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
		write(1, "\n", 1);
}
  8000fb:	83 c4 2c             	add    $0x2c,%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	5f                   	pop    %edi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    
	...

00800104 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
  80010a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80010d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800110:	8b 75 08             	mov    0x8(%ebp),%esi
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800116:	e8 41 05 00 00       	call   80065c <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	c1 e0 07             	shl    $0x7,%eax
  800123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800128:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012d:	85 f6                	test   %esi,%esi
  80012f:	7e 07                	jle    800138 <libmain+0x34>
		binaryname = argv[0];
  800131:	8b 03                	mov    (%ebx),%eax
  800133:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013c:	89 34 24             	mov    %esi,(%esp)
  80013f:	e8 f0 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800144:	e8 0b 00 00 00       	call   800154 <exit>
}
  800149:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80014c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80014f:	89 ec                	mov    %ebp,%esp
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80015a:	e8 7f 0a 00 00       	call   800bde <close_all>
	sys_env_destroy(0);
  80015f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800166:	e8 94 04 00 00       	call   8005ff <sys_env_destroy>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800176:	b8 00 00 00 00       	mov    $0x0,%eax
  80017b:	80 3a 00             	cmpb   $0x0,(%edx)
  80017e:	74 09                	je     800189 <strlen+0x19>
		n++;
  800180:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800183:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800187:	75 f7                	jne    800180 <strlen+0x10>
		n++;
	return n;
}
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    

0080018b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800195:	b8 00 00 00 00       	mov    $0x0,%eax
  80019a:	85 c9                	test   %ecx,%ecx
  80019c:	74 1a                	je     8001b8 <strnlen+0x2d>
  80019e:	80 3b 00             	cmpb   $0x0,(%ebx)
  8001a1:	74 15                	je     8001b8 <strnlen+0x2d>
  8001a3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8001a8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8001aa:	39 ca                	cmp    %ecx,%edx
  8001ac:	74 0a                	je     8001b8 <strnlen+0x2d>
  8001ae:	83 c2 01             	add    $0x1,%edx
  8001b1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8001b6:	75 f0                	jne    8001a8 <strnlen+0x1d>
		n++;
	return n;
}
  8001b8:	5b                   	pop    %ebx
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	53                   	push   %ebx
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ca:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8001ce:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8001d1:	83 c2 01             	add    $0x1,%edx
  8001d4:	84 c9                	test   %cl,%cl
  8001d6:	75 f2                	jne    8001ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001d8:	5b                   	pop    %ebx
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	53                   	push   %ebx
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001e5:	89 1c 24             	mov    %ebx,(%esp)
  8001e8:	e8 83 ff ff ff       	call   800170 <strlen>
	strcpy(dst + len, src);
  8001ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f4:	01 d8                	add    %ebx,%eax
  8001f6:	89 04 24             	mov    %eax,(%esp)
  8001f9:	e8 bd ff ff ff       	call   8001bb <strcpy>
	return dst;
}
  8001fe:	89 d8                	mov    %ebx,%eax
  800200:	83 c4 08             	add    $0x8,%esp
  800203:	5b                   	pop    %ebx
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	8b 45 08             	mov    0x8(%ebp),%eax
  80020e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800211:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800214:	85 f6                	test   %esi,%esi
  800216:	74 18                	je     800230 <strncpy+0x2a>
  800218:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80021d:	0f b6 1a             	movzbl (%edx),%ebx
  800220:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800223:	80 3a 01             	cmpb   $0x1,(%edx)
  800226:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800229:	83 c1 01             	add    $0x1,%ecx
  80022c:	39 f1                	cmp    %esi,%ecx
  80022e:	75 ed                	jne    80021d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800230:	5b                   	pop    %ebx
  800231:	5e                   	pop    %esi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80023d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800240:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800243:	89 f8                	mov    %edi,%eax
  800245:	85 f6                	test   %esi,%esi
  800247:	74 2b                	je     800274 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800249:	83 fe 01             	cmp    $0x1,%esi
  80024c:	74 23                	je     800271 <strlcpy+0x3d>
  80024e:	0f b6 0b             	movzbl (%ebx),%ecx
  800251:	84 c9                	test   %cl,%cl
  800253:	74 1c                	je     800271 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800255:	83 ee 02             	sub    $0x2,%esi
  800258:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80025d:	88 08                	mov    %cl,(%eax)
  80025f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800262:	39 f2                	cmp    %esi,%edx
  800264:	74 0b                	je     800271 <strlcpy+0x3d>
  800266:	83 c2 01             	add    $0x1,%edx
  800269:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80026d:	84 c9                	test   %cl,%cl
  80026f:	75 ec                	jne    80025d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800271:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800274:	29 f8                	sub    %edi,%eax
}
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800281:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800284:	0f b6 01             	movzbl (%ecx),%eax
  800287:	84 c0                	test   %al,%al
  800289:	74 16                	je     8002a1 <strcmp+0x26>
  80028b:	3a 02                	cmp    (%edx),%al
  80028d:	75 12                	jne    8002a1 <strcmp+0x26>
		p++, q++;
  80028f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800292:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800296:	84 c0                	test   %al,%al
  800298:	74 07                	je     8002a1 <strcmp+0x26>
  80029a:	83 c1 01             	add    $0x1,%ecx
  80029d:	3a 02                	cmp    (%edx),%al
  80029f:	74 ee                	je     80028f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8002a1:	0f b6 c0             	movzbl %al,%eax
  8002a4:	0f b6 12             	movzbl (%edx),%edx
  8002a7:	29 d0                	sub    %edx,%eax
}
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	53                   	push   %ebx
  8002af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8002b8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8002bd:	85 d2                	test   %edx,%edx
  8002bf:	74 28                	je     8002e9 <strncmp+0x3e>
  8002c1:	0f b6 01             	movzbl (%ecx),%eax
  8002c4:	84 c0                	test   %al,%al
  8002c6:	74 24                	je     8002ec <strncmp+0x41>
  8002c8:	3a 03                	cmp    (%ebx),%al
  8002ca:	75 20                	jne    8002ec <strncmp+0x41>
  8002cc:	83 ea 01             	sub    $0x1,%edx
  8002cf:	74 13                	je     8002e4 <strncmp+0x39>
		n--, p++, q++;
  8002d1:	83 c1 01             	add    $0x1,%ecx
  8002d4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8002d7:	0f b6 01             	movzbl (%ecx),%eax
  8002da:	84 c0                	test   %al,%al
  8002dc:	74 0e                	je     8002ec <strncmp+0x41>
  8002de:	3a 03                	cmp    (%ebx),%al
  8002e0:	74 ea                	je     8002cc <strncmp+0x21>
  8002e2:	eb 08                	jmp    8002ec <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8002e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8002e9:	5b                   	pop    %ebx
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8002ec:	0f b6 01             	movzbl (%ecx),%eax
  8002ef:	0f b6 13             	movzbl (%ebx),%edx
  8002f2:	29 d0                	sub    %edx,%eax
  8002f4:	eb f3                	jmp    8002e9 <strncmp+0x3e>

008002f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800300:	0f b6 10             	movzbl (%eax),%edx
  800303:	84 d2                	test   %dl,%dl
  800305:	74 1c                	je     800323 <strchr+0x2d>
		if (*s == c)
  800307:	38 ca                	cmp    %cl,%dl
  800309:	75 09                	jne    800314 <strchr+0x1e>
  80030b:	eb 1b                	jmp    800328 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80030d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800310:	38 ca                	cmp    %cl,%dl
  800312:	74 14                	je     800328 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800314:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800318:	84 d2                	test   %dl,%dl
  80031a:	75 f1                	jne    80030d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80031c:	b8 00 00 00 00       	mov    $0x0,%eax
  800321:	eb 05                	jmp    800328 <strchr+0x32>
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800334:	0f b6 10             	movzbl (%eax),%edx
  800337:	84 d2                	test   %dl,%dl
  800339:	74 14                	je     80034f <strfind+0x25>
		if (*s == c)
  80033b:	38 ca                	cmp    %cl,%dl
  80033d:	75 06                	jne    800345 <strfind+0x1b>
  80033f:	eb 0e                	jmp    80034f <strfind+0x25>
  800341:	38 ca                	cmp    %cl,%dl
  800343:	74 0a                	je     80034f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800345:	83 c0 01             	add    $0x1,%eax
  800348:	0f b6 10             	movzbl (%eax),%edx
  80034b:	84 d2                	test   %dl,%dl
  80034d:	75 f2                	jne    800341 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80035d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800360:	8b 7d 08             	mov    0x8(%ebp),%edi
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
  800366:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800369:	85 c9                	test   %ecx,%ecx
  80036b:	74 30                	je     80039d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80036d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800373:	75 25                	jne    80039a <memset+0x49>
  800375:	f6 c1 03             	test   $0x3,%cl
  800378:	75 20                	jne    80039a <memset+0x49>
		c &= 0xFF;
  80037a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80037d:	89 d3                	mov    %edx,%ebx
  80037f:	c1 e3 08             	shl    $0x8,%ebx
  800382:	89 d6                	mov    %edx,%esi
  800384:	c1 e6 18             	shl    $0x18,%esi
  800387:	89 d0                	mov    %edx,%eax
  800389:	c1 e0 10             	shl    $0x10,%eax
  80038c:	09 f0                	or     %esi,%eax
  80038e:	09 d0                	or     %edx,%eax
  800390:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800392:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800395:	fc                   	cld    
  800396:	f3 ab                	rep stos %eax,%es:(%edi)
  800398:	eb 03                	jmp    80039d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80039a:	fc                   	cld    
  80039b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80039d:	89 f8                	mov    %edi,%eax
  80039f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a8:	89 ec                	mov    %ebp,%esp
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003b5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8003c1:	39 c6                	cmp    %eax,%esi
  8003c3:	73 36                	jae    8003fb <memmove+0x4f>
  8003c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8003c8:	39 d0                	cmp    %edx,%eax
  8003ca:	73 2f                	jae    8003fb <memmove+0x4f>
		s += n;
		d += n;
  8003cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8003cf:	f6 c2 03             	test   $0x3,%dl
  8003d2:	75 1b                	jne    8003ef <memmove+0x43>
  8003d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8003da:	75 13                	jne    8003ef <memmove+0x43>
  8003dc:	f6 c1 03             	test   $0x3,%cl
  8003df:	75 0e                	jne    8003ef <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8003e1:	83 ef 04             	sub    $0x4,%edi
  8003e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8003e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8003ea:	fd                   	std    
  8003eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003ed:	eb 09                	jmp    8003f8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8003ef:	83 ef 01             	sub    $0x1,%edi
  8003f2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8003f5:	fd                   	std    
  8003f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8003f8:	fc                   	cld    
  8003f9:	eb 20                	jmp    80041b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8003fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800401:	75 13                	jne    800416 <memmove+0x6a>
  800403:	a8 03                	test   $0x3,%al
  800405:	75 0f                	jne    800416 <memmove+0x6a>
  800407:	f6 c1 03             	test   $0x3,%cl
  80040a:	75 0a                	jne    800416 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80040c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80040f:	89 c7                	mov    %eax,%edi
  800411:	fc                   	cld    
  800412:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800414:	eb 05                	jmp    80041b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800416:	89 c7                	mov    %eax,%edi
  800418:	fc                   	cld    
  800419:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80041b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80041e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800421:	89 ec                	mov    %ebp,%esp
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80042b:	8b 45 10             	mov    0x10(%ebp),%eax
  80042e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800432:	8b 45 0c             	mov    0xc(%ebp),%eax
  800435:	89 44 24 04          	mov    %eax,0x4(%esp)
  800439:	8b 45 08             	mov    0x8(%ebp),%eax
  80043c:	89 04 24             	mov    %eax,(%esp)
  80043f:	e8 68 ff ff ff       	call   8003ac <memmove>
}
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80044f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800452:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80045a:	85 ff                	test   %edi,%edi
  80045c:	74 37                	je     800495 <memcmp+0x4f>
		if (*s1 != *s2)
  80045e:	0f b6 03             	movzbl (%ebx),%eax
  800461:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800464:	83 ef 01             	sub    $0x1,%edi
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  80046c:	38 c8                	cmp    %cl,%al
  80046e:	74 1c                	je     80048c <memcmp+0x46>
  800470:	eb 10                	jmp    800482 <memcmp+0x3c>
  800472:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800477:	83 c2 01             	add    $0x1,%edx
  80047a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  80047e:	38 c8                	cmp    %cl,%al
  800480:	74 0a                	je     80048c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800482:	0f b6 c0             	movzbl %al,%eax
  800485:	0f b6 c9             	movzbl %cl,%ecx
  800488:	29 c8                	sub    %ecx,%eax
  80048a:	eb 09                	jmp    800495 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80048c:	39 fa                	cmp    %edi,%edx
  80048e:	75 e2                	jne    800472 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800495:	5b                   	pop    %ebx
  800496:	5e                   	pop    %esi
  800497:	5f                   	pop    %edi
  800498:	5d                   	pop    %ebp
  800499:	c3                   	ret    

0080049a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8004a0:	89 c2                	mov    %eax,%edx
  8004a2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8004a5:	39 d0                	cmp    %edx,%eax
  8004a7:	73 19                	jae    8004c2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  8004a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8004ad:	38 08                	cmp    %cl,(%eax)
  8004af:	75 06                	jne    8004b7 <memfind+0x1d>
  8004b1:	eb 0f                	jmp    8004c2 <memfind+0x28>
  8004b3:	38 08                	cmp    %cl,(%eax)
  8004b5:	74 0b                	je     8004c2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8004b7:	83 c0 01             	add    $0x1,%eax
  8004ba:	39 d0                	cmp    %edx,%eax
  8004bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004c0:	75 f1                	jne    8004b3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	53                   	push   %ebx
  8004ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8004d0:	0f b6 02             	movzbl (%edx),%eax
  8004d3:	3c 20                	cmp    $0x20,%al
  8004d5:	74 04                	je     8004db <strtol+0x17>
  8004d7:	3c 09                	cmp    $0x9,%al
  8004d9:	75 0e                	jne    8004e9 <strtol+0x25>
		s++;
  8004db:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8004de:	0f b6 02             	movzbl (%edx),%eax
  8004e1:	3c 20                	cmp    $0x20,%al
  8004e3:	74 f6                	je     8004db <strtol+0x17>
  8004e5:	3c 09                	cmp    $0x9,%al
  8004e7:	74 f2                	je     8004db <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  8004e9:	3c 2b                	cmp    $0x2b,%al
  8004eb:	75 0a                	jne    8004f7 <strtol+0x33>
		s++;
  8004ed:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8004f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8004f5:	eb 10                	jmp    800507 <strtol+0x43>
  8004f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8004fc:	3c 2d                	cmp    $0x2d,%al
  8004fe:	75 07                	jne    800507 <strtol+0x43>
		s++, neg = 1;
  800500:	83 c2 01             	add    $0x1,%edx
  800503:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800507:	85 db                	test   %ebx,%ebx
  800509:	0f 94 c0             	sete   %al
  80050c:	74 05                	je     800513 <strtol+0x4f>
  80050e:	83 fb 10             	cmp    $0x10,%ebx
  800511:	75 15                	jne    800528 <strtol+0x64>
  800513:	80 3a 30             	cmpb   $0x30,(%edx)
  800516:	75 10                	jne    800528 <strtol+0x64>
  800518:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80051c:	75 0a                	jne    800528 <strtol+0x64>
		s += 2, base = 16;
  80051e:	83 c2 02             	add    $0x2,%edx
  800521:	bb 10 00 00 00       	mov    $0x10,%ebx
  800526:	eb 13                	jmp    80053b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800528:	84 c0                	test   %al,%al
  80052a:	74 0f                	je     80053b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80052c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800531:	80 3a 30             	cmpb   $0x30,(%edx)
  800534:	75 05                	jne    80053b <strtol+0x77>
		s++, base = 8;
  800536:	83 c2 01             	add    $0x1,%edx
  800539:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800542:	0f b6 0a             	movzbl (%edx),%ecx
  800545:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800548:	80 fb 09             	cmp    $0x9,%bl
  80054b:	77 08                	ja     800555 <strtol+0x91>
			dig = *s - '0';
  80054d:	0f be c9             	movsbl %cl,%ecx
  800550:	83 e9 30             	sub    $0x30,%ecx
  800553:	eb 1e                	jmp    800573 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800555:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800558:	80 fb 19             	cmp    $0x19,%bl
  80055b:	77 08                	ja     800565 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80055d:	0f be c9             	movsbl %cl,%ecx
  800560:	83 e9 57             	sub    $0x57,%ecx
  800563:	eb 0e                	jmp    800573 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800565:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800568:	80 fb 19             	cmp    $0x19,%bl
  80056b:	77 14                	ja     800581 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80056d:	0f be c9             	movsbl %cl,%ecx
  800570:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800573:	39 f1                	cmp    %esi,%ecx
  800575:	7d 0e                	jge    800585 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800577:	83 c2 01             	add    $0x1,%edx
  80057a:	0f af c6             	imul   %esi,%eax
  80057d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80057f:	eb c1                	jmp    800542 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800581:	89 c1                	mov    %eax,%ecx
  800583:	eb 02                	jmp    800587 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800585:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800587:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80058b:	74 05                	je     800592 <strtol+0xce>
		*endptr = (char *) s;
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800592:	89 ca                	mov    %ecx,%edx
  800594:	f7 da                	neg    %edx
  800596:	85 ff                	test   %edi,%edi
  800598:	0f 45 c2             	cmovne %edx,%eax
}
  80059b:	5b                   	pop    %ebx
  80059c:	5e                   	pop    %esi
  80059d:	5f                   	pop    %edi
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	83 ec 0c             	sub    $0xc,%esp
  8005a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8005a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8005ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005af:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ba:	89 c3                	mov    %eax,%ebx
  8005bc:	89 c7                	mov    %eax,%edi
  8005be:	89 c6                	mov    %eax,%esi
  8005c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8005c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8005c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8005c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005cb:	89 ec                	mov    %ebp,%esp
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	83 ec 0c             	sub    $0xc,%esp
  8005d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8005d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8005db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005de:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8005e8:	89 d1                	mov    %edx,%ecx
  8005ea:	89 d3                	mov    %edx,%ebx
  8005ec:	89 d7                	mov    %edx,%edi
  8005ee:	89 d6                	mov    %edx,%esi
  8005f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8005f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8005f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8005f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005fb:	89 ec                	mov    %ebp,%esp
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	83 ec 38             	sub    $0x38,%esp
  800605:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800608:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80060b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	b8 03 00 00 00       	mov    $0x3,%eax
  800618:	8b 55 08             	mov    0x8(%ebp),%edx
  80061b:	89 cb                	mov    %ecx,%ebx
  80061d:	89 cf                	mov    %ecx,%edi
  80061f:	89 ce                	mov    %ecx,%esi
  800621:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800623:	85 c0                	test   %eax,%eax
  800625:	7e 28                	jle    80064f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800627:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800632:	00 
  800633:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  80063a:	00 
  80063b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800642:	00 
  800643:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  80064a:	e8 61 11 00 00       	call   8017b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80064f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800652:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800655:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800658:	89 ec                	mov    %ebp,%esp
  80065a:	5d                   	pop    %ebp
  80065b:	c3                   	ret    

0080065c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800665:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800668:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80066b:	ba 00 00 00 00       	mov    $0x0,%edx
  800670:	b8 02 00 00 00       	mov    $0x2,%eax
  800675:	89 d1                	mov    %edx,%ecx
  800677:	89 d3                	mov    %edx,%ebx
  800679:	89 d7                	mov    %edx,%edi
  80067b:	89 d6                	mov    %edx,%esi
  80067d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80067f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800682:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800685:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800688:	89 ec                	mov    %ebp,%esp
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <sys_yield>:

void
sys_yield(void)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800695:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800698:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006a5:	89 d1                	mov    %edx,%ecx
  8006a7:	89 d3                	mov    %edx,%ebx
  8006a9:	89 d7                	mov    %edx,%edi
  8006ab:	89 d6                	mov    %edx,%esi
  8006ad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8006af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006b8:	89 ec                	mov    %ebp,%esp
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 38             	sub    $0x38,%esp
  8006c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8006c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8006c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006cb:	be 00 00 00 00       	mov    $0x0,%esi
  8006d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8006d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 f7                	mov    %esi,%edi
  8006e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	7e 28                	jle    80070e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8006f1:	00 
  8006f2:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  8006f9:	00 
  8006fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800701:	00 
  800702:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  800709:	e8 a2 10 00 00       	call   8017b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80070e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800711:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800714:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800717:	89 ec                	mov    %ebp,%esp
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 38             	sub    $0x38,%esp
  800721:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800724:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800727:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80072a:	b8 05 00 00 00       	mov    $0x5,%eax
  80072f:	8b 75 18             	mov    0x18(%ebp),%esi
  800732:	8b 7d 14             	mov    0x14(%ebp),%edi
  800735:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073b:	8b 55 08             	mov    0x8(%ebp),%edx
  80073e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800740:	85 c0                	test   %eax,%eax
  800742:	7e 28                	jle    80076c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800744:	89 44 24 10          	mov    %eax,0x10(%esp)
  800748:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80074f:	00 
  800750:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  800757:	00 
  800758:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80075f:	00 
  800760:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  800767:	e8 44 10 00 00       	call   8017b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80076c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80076f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800772:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800775:	89 ec                	mov    %ebp,%esp
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	83 ec 38             	sub    $0x38,%esp
  80077f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800782:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800785:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800788:	bb 00 00 00 00       	mov    $0x0,%ebx
  80078d:	b8 06 00 00 00       	mov    $0x6,%eax
  800792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
  800798:	89 df                	mov    %ebx,%edi
  80079a:	89 de                	mov    %ebx,%esi
  80079c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	7e 28                	jle    8007ca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8007ad:	00 
  8007ae:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  8007b5:	00 
  8007b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007bd:	00 
  8007be:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  8007c5:	e8 e6 0f 00 00       	call   8017b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8007ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8007cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8007d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8007d3:	89 ec                	mov    %ebp,%esp
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 38             	sub    $0x38,%esp
  8007dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8007e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8007e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f6:	89 df                	mov    %ebx,%edi
  8007f8:	89 de                	mov    %ebx,%esi
  8007fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	7e 28                	jle    800828 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800800:	89 44 24 10          	mov    %eax,0x10(%esp)
  800804:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80080b:	00 
  80080c:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  800813:	00 
  800814:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80081b:	00 
  80081c:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  800823:	e8 88 0f 00 00       	call   8017b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800828:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80082b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80082e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800831:	89 ec                	mov    %ebp,%esp
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 38             	sub    $0x38,%esp
  80083b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80083e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800841:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800844:	bb 00 00 00 00       	mov    $0x0,%ebx
  800849:	b8 09 00 00 00       	mov    $0x9,%eax
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	8b 55 08             	mov    0x8(%ebp),%edx
  800854:	89 df                	mov    %ebx,%edi
  800856:	89 de                	mov    %ebx,%esi
  800858:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	7e 28                	jle    800886 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80085e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800862:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800869:	00 
  80086a:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  800871:	00 
  800872:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800879:	00 
  80087a:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  800881:	e8 2a 0f 00 00       	call   8017b0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800886:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800889:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80088c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80088f:	89 ec                	mov    %ebp,%esp
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	83 ec 38             	sub    $0x38,%esp
  800899:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80089c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80089f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008af:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b2:	89 df                	mov    %ebx,%edi
  8008b4:	89 de                	mov    %ebx,%esi
  8008b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	7e 28                	jle    8008e4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008c0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8008c7:	00 
  8008c8:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  8008cf:	00 
  8008d0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008d7:	00 
  8008d8:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  8008df:	e8 cc 0e 00 00       	call   8017b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8008e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8008e7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8008ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8008ed:	89 ec                	mov    %ebp,%esp
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 0c             	sub    $0xc,%esp
  8008f7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008fa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8008fd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800900:	be 00 00 00 00       	mov    $0x0,%esi
  800905:	b8 0c 00 00 00       	mov    $0xc,%eax
  80090a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80090d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
  800916:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800918:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80091b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80091e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800921:	89 ec                	mov    %ebp,%esp
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 38             	sub    $0x38,%esp
  80092b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80092e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800931:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800934:	b9 00 00 00 00       	mov    $0x0,%ecx
  800939:	b8 0d 00 00 00       	mov    $0xd,%eax
  80093e:	8b 55 08             	mov    0x8(%ebp),%edx
  800941:	89 cb                	mov    %ecx,%ebx
  800943:	89 cf                	mov    %ecx,%edi
  800945:	89 ce                	mov    %ecx,%esi
  800947:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800949:	85 c0                	test   %eax,%eax
  80094b:	7e 28                	jle    800975 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80094d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800951:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800958:	00 
  800959:	c7 44 24 08 cf 23 80 	movl   $0x8023cf,0x8(%esp)
  800960:	00 
  800961:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800968:	00 
  800969:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  800970:	e8 3b 0e 00 00       	call   8017b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800975:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800978:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80097b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80097e:	89 ec                	mov    %ebp,%esp
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 0c             	sub    $0xc,%esp
  800988:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80098b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80098e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800991:	b9 00 00 00 00       	mov    $0x0,%ecx
  800996:	b8 0e 00 00 00       	mov    $0xe,%eax
  80099b:	8b 55 08             	mov    0x8(%ebp),%edx
  80099e:	89 cb                	mov    %ecx,%ebx
  8009a0:	89 cf                	mov    %ecx,%edi
  8009a2:	89 ce                	mov    %ecx,%esi
  8009a4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8009a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009af:	89 ec                	mov    %ebp,%esp
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    
	...

008009c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8009cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	89 04 24             	mov    %eax,(%esp)
  8009dc:	e8 df ff ff ff       	call   8009c0 <fd2num>
  8009e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8009e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8009f2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8009f7:	a8 01                	test   $0x1,%al
  8009f9:	74 34                	je     800a2f <fd_alloc+0x44>
  8009fb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800a00:	a8 01                	test   $0x1,%al
  800a02:	74 32                	je     800a36 <fd_alloc+0x4b>
  800a04:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800a09:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	c1 ea 16             	shr    $0x16,%edx
  800a10:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800a17:	f6 c2 01             	test   $0x1,%dl
  800a1a:	74 1f                	je     800a3b <fd_alloc+0x50>
  800a1c:	89 c2                	mov    %eax,%edx
  800a1e:	c1 ea 0c             	shr    $0xc,%edx
  800a21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a28:	f6 c2 01             	test   $0x1,%dl
  800a2b:	75 17                	jne    800a44 <fd_alloc+0x59>
  800a2d:	eb 0c                	jmp    800a3b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800a2f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800a34:	eb 05                	jmp    800a3b <fd_alloc+0x50>
  800a36:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800a3b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	eb 17                	jmp    800a5b <fd_alloc+0x70>
  800a44:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800a49:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800a4e:	75 b9                	jne    800a09 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800a50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800a56:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800a69:	83 fa 1f             	cmp    $0x1f,%edx
  800a6c:	77 3f                	ja     800aad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800a6e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  800a74:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	c1 e8 16             	shr    $0x16,%eax
  800a7c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800a88:	f6 c1 01             	test   $0x1,%cl
  800a8b:	74 20                	je     800aad <fd_lookup+0x4f>
  800a8d:	89 d0                	mov    %edx,%eax
  800a8f:	c1 e8 0c             	shr    $0xc,%eax
  800a92:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800a9e:	f6 c1 01             	test   $0x1,%cl
  800aa1:	74 0a                	je     800aad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	53                   	push   %ebx
  800ab3:	83 ec 14             	sub    $0x14,%esp
  800ab6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ac1:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800ac7:	75 17                	jne    800ae0 <dev_lookup+0x31>
  800ac9:	eb 07                	jmp    800ad2 <dev_lookup+0x23>
  800acb:	39 0a                	cmp    %ecx,(%edx)
  800acd:	75 11                	jne    800ae0 <dev_lookup+0x31>
  800acf:	90                   	nop
  800ad0:	eb 05                	jmp    800ad7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ad2:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ad7:	89 13                	mov    %edx,(%ebx)
			return 0;
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	eb 35                	jmp    800b15 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ae0:	83 c0 01             	add    $0x1,%eax
  800ae3:	8b 14 85 78 24 80 00 	mov    0x802478(,%eax,4),%edx
  800aea:	85 d2                	test   %edx,%edx
  800aec:	75 dd                	jne    800acb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800aee:	a1 04 40 80 00       	mov    0x804004,%eax
  800af3:	8b 40 48             	mov    0x48(%eax),%eax
  800af6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afe:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  800b05:	e8 a1 0d 00 00       	call   8018ab <cprintf>
	*dev = 0;
  800b0a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800b10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800b15:	83 c4 14             	add    $0x14,%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 38             	sub    $0x38,%esp
  800b21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b27:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800b31:	89 3c 24             	mov    %edi,(%esp)
  800b34:	e8 87 fe ff ff       	call   8009c0 <fd2num>
  800b39:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800b3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b40:	89 04 24             	mov    %eax,(%esp)
  800b43:	e8 16 ff ff ff       	call   800a5e <fd_lookup>
  800b48:	89 c3                	mov    %eax,%ebx
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	78 05                	js     800b53 <fd_close+0x38>
	    || fd != fd2)
  800b4e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800b51:	74 0e                	je     800b61 <fd_close+0x46>
		return (must_exist ? r : 0);
  800b53:	89 f0                	mov    %esi,%eax
  800b55:	84 c0                	test   %al,%al
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	0f 44 d8             	cmove  %eax,%ebx
  800b5f:	eb 3d                	jmp    800b9e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800b61:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b68:	8b 07                	mov    (%edi),%eax
  800b6a:	89 04 24             	mov    %eax,(%esp)
  800b6d:	e8 3d ff ff ff       	call   800aaf <dev_lookup>
  800b72:	89 c3                	mov    %eax,%ebx
  800b74:	85 c0                	test   %eax,%eax
  800b76:	78 16                	js     800b8e <fd_close+0x73>
		if (dev->dev_close)
  800b78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b7b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800b7e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	74 07                	je     800b8e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  800b87:	89 3c 24             	mov    %edi,(%esp)
  800b8a:	ff d0                	call   *%eax
  800b8c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800b8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b99:	e8 db fb ff ff       	call   800779 <sys_page_unmap>
	return r;
}
  800b9e:	89 d8                	mov    %ebx,%eax
  800ba0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ba3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba9:	89 ec                	mov    %ebp,%esp
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	89 04 24             	mov    %eax,(%esp)
  800bc0:	e8 99 fe ff ff       	call   800a5e <fd_lookup>
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	78 13                	js     800bdc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800bc9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800bd0:	00 
  800bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd4:	89 04 24             	mov    %eax,(%esp)
  800bd7:	e8 3f ff ff ff       	call   800b1b <fd_close>
}
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <close_all>:

void
close_all(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	53                   	push   %ebx
  800be2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800bea:	89 1c 24             	mov    %ebx,(%esp)
  800bed:	e8 bb ff ff ff       	call   800bad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800bf2:	83 c3 01             	add    $0x1,%ebx
  800bf5:	83 fb 20             	cmp    $0x20,%ebx
  800bf8:	75 f0                	jne    800bea <close_all+0xc>
		close(i);
}
  800bfa:	83 c4 14             	add    $0x14,%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 58             	sub    $0x58,%esp
  800c06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c0f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800c12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	89 04 24             	mov    %eax,(%esp)
  800c1f:	e8 3a fe ff ff       	call   800a5e <fd_lookup>
  800c24:	89 c3                	mov    %eax,%ebx
  800c26:	85 c0                	test   %eax,%eax
  800c28:	0f 88 e1 00 00 00    	js     800d0f <dup+0x10f>
		return r;
	close(newfdnum);
  800c2e:	89 3c 24             	mov    %edi,(%esp)
  800c31:	e8 77 ff ff ff       	call   800bad <close>

	newfd = INDEX2FD(newfdnum);
  800c36:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800c3c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800c3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c42:	89 04 24             	mov    %eax,(%esp)
  800c45:	e8 86 fd ff ff       	call   8009d0 <fd2data>
  800c4a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800c4c:	89 34 24             	mov    %esi,(%esp)
  800c4f:	e8 7c fd ff ff       	call   8009d0 <fd2data>
  800c54:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800c57:	89 d8                	mov    %ebx,%eax
  800c59:	c1 e8 16             	shr    $0x16,%eax
  800c5c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800c63:	a8 01                	test   $0x1,%al
  800c65:	74 46                	je     800cad <dup+0xad>
  800c67:	89 d8                	mov    %ebx,%eax
  800c69:	c1 e8 0c             	shr    $0xc,%eax
  800c6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800c73:	f6 c2 01             	test   $0x1,%dl
  800c76:	74 35                	je     800cad <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800c78:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800c7f:	25 07 0e 00 00       	and    $0xe07,%eax
  800c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c96:	00 
  800c97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ca2:	e8 74 fa ff ff       	call   80071b <sys_page_map>
  800ca7:	89 c3                	mov    %eax,%ebx
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	78 3b                	js     800ce8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cb0:	89 c2                	mov    %eax,%edx
  800cb2:	c1 ea 0c             	shr    $0xc,%edx
  800cb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800cbc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800cc2:	89 54 24 10          	mov    %edx,0x10(%esp)
  800cc6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800cca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800cd1:	00 
  800cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cdd:	e8 39 fa ff ff       	call   80071b <sys_page_map>
  800ce2:	89 c3                	mov    %eax,%ebx
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	79 25                	jns    800d0d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ce8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cf3:	e8 81 fa ff ff       	call   800779 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800cf8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d06:	e8 6e fa ff ff       	call   800779 <sys_page_unmap>
	return r;
  800d0b:	eb 02                	jmp    800d0f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800d0d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800d0f:	89 d8                	mov    %ebx,%eax
  800d11:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d14:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d17:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d1a:	89 ec                	mov    %ebp,%esp
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	53                   	push   %ebx
  800d22:	83 ec 24             	sub    $0x24,%esp
  800d25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d28:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2f:	89 1c 24             	mov    %ebx,(%esp)
  800d32:	e8 27 fd ff ff       	call   800a5e <fd_lookup>
  800d37:	85 c0                	test   %eax,%eax
  800d39:	78 6d                	js     800da8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d45:	8b 00                	mov    (%eax),%eax
  800d47:	89 04 24             	mov    %eax,(%esp)
  800d4a:	e8 60 fd ff ff       	call   800aaf <dev_lookup>
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	78 55                	js     800da8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d56:	8b 50 08             	mov    0x8(%eax),%edx
  800d59:	83 e2 03             	and    $0x3,%edx
  800d5c:	83 fa 01             	cmp    $0x1,%edx
  800d5f:	75 23                	jne    800d84 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800d61:	a1 04 40 80 00       	mov    0x804004,%eax
  800d66:	8b 40 48             	mov    0x48(%eax),%eax
  800d69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d71:	c7 04 24 3d 24 80 00 	movl   $0x80243d,(%esp)
  800d78:	e8 2e 0b 00 00       	call   8018ab <cprintf>
		return -E_INVAL;
  800d7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d82:	eb 24                	jmp    800da8 <read+0x8a>
	}
	if (!dev->dev_read)
  800d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d87:	8b 52 08             	mov    0x8(%edx),%edx
  800d8a:	85 d2                	test   %edx,%edx
  800d8c:	74 15                	je     800da3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  800d8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d91:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d9c:	89 04 24             	mov    %eax,(%esp)
  800d9f:	ff d2                	call   *%edx
  800da1:	eb 05                	jmp    800da8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800da3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  800da8:	83 c4 24             	add    $0x24,%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 1c             	sub    $0x1c,%esp
  800db7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc2:	85 f6                	test   %esi,%esi
  800dc4:	74 30                	je     800df6 <readn+0x48>
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	29 c2                	sub    %eax,%edx
  800dcf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dd3:	03 45 0c             	add    0xc(%ebp),%eax
  800dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dda:	89 3c 24             	mov    %edi,(%esp)
  800ddd:	e8 3c ff ff ff       	call   800d1e <read>
		if (m < 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	78 10                	js     800df6 <readn+0x48>
			return m;
		if (m == 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	74 0a                	je     800df4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800dea:	01 c3                	add    %eax,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	39 f3                	cmp    %esi,%ebx
  800df0:	72 d9                	jb     800dcb <readn+0x1d>
  800df2:	eb 02                	jmp    800df6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800df4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800df6:	83 c4 1c             	add    $0x1c,%esp
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	53                   	push   %ebx
  800e02:	83 ec 24             	sub    $0x24,%esp
  800e05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0f:	89 1c 24             	mov    %ebx,(%esp)
  800e12:	e8 47 fc ff ff       	call   800a5e <fd_lookup>
  800e17:	85 c0                	test   %eax,%eax
  800e19:	78 68                	js     800e83 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e25:	8b 00                	mov    (%eax),%eax
  800e27:	89 04 24             	mov    %eax,(%esp)
  800e2a:	e8 80 fc ff ff       	call   800aaf <dev_lookup>
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	78 50                	js     800e83 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e36:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800e3a:	75 23                	jne    800e5f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800e3c:	a1 04 40 80 00       	mov    0x804004,%eax
  800e41:	8b 40 48             	mov    0x48(%eax),%eax
  800e44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4c:	c7 04 24 59 24 80 00 	movl   $0x802459,(%esp)
  800e53:	e8 53 0a 00 00       	call   8018ab <cprintf>
		return -E_INVAL;
  800e58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e5d:	eb 24                	jmp    800e83 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800e5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e62:	8b 52 0c             	mov    0xc(%edx),%edx
  800e65:	85 d2                	test   %edx,%edx
  800e67:	74 15                	je     800e7e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800e69:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e6c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e77:	89 04 24             	mov    %eax,(%esp)
  800e7a:	ff d2                	call   *%edx
  800e7c:	eb 05                	jmp    800e83 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800e7e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800e83:	83 c4 24             	add    $0x24,%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <seek>:

int
seek(int fdnum, off_t offset)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800e92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	89 04 24             	mov    %eax,(%esp)
  800e9c:	e8 bd fb ff ff       	call   800a5e <fd_lookup>
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	78 0e                	js     800eb3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800ea5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ea8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 24             	sub    $0x24,%esp
  800ebc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ebf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec6:	89 1c 24             	mov    %ebx,(%esp)
  800ec9:	e8 90 fb ff ff       	call   800a5e <fd_lookup>
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	78 61                	js     800f33 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edc:	8b 00                	mov    (%eax),%eax
  800ede:	89 04 24             	mov    %eax,(%esp)
  800ee1:	e8 c9 fb ff ff       	call   800aaf <dev_lookup>
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 49                	js     800f33 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ef1:	75 23                	jne    800f16 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800ef3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800ef8:	8b 40 48             	mov    0x48(%eax),%eax
  800efb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800eff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f03:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800f0a:	e8 9c 09 00 00       	call   8018ab <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f14:	eb 1d                	jmp    800f33 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800f16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f19:	8b 52 18             	mov    0x18(%edx),%edx
  800f1c:	85 d2                	test   %edx,%edx
  800f1e:	74 0e                	je     800f2e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f27:	89 04 24             	mov    %eax,(%esp)
  800f2a:	ff d2                	call   *%edx
  800f2c:	eb 05                	jmp    800f33 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800f2e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800f33:	83 c4 24             	add    $0x24,%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	53                   	push   %ebx
  800f3d:	83 ec 24             	sub    $0x24,%esp
  800f40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	e8 09 fb ff ff       	call   800a5e <fd_lookup>
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 52                	js     800fab <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800f59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f63:	8b 00                	mov    (%eax),%eax
  800f65:	89 04 24             	mov    %eax,(%esp)
  800f68:	e8 42 fb ff ff       	call   800aaf <dev_lookup>
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 3a                	js     800fab <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f74:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800f78:	74 2c                	je     800fa6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800f7a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800f7d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800f84:	00 00 00 
	stat->st_isdir = 0;
  800f87:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f8e:	00 00 00 
	stat->st_dev = dev;
  800f91:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800f97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f9e:	89 14 24             	mov    %edx,(%esp)
  800fa1:	ff 50 14             	call   *0x14(%eax)
  800fa4:	eb 05                	jmp    800fab <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800fa6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800fab:	83 c4 24             	add    $0x24,%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 18             	sub    $0x18,%esp
  800fb7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fba:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800fbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc4:	00 
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	89 04 24             	mov    %eax,(%esp)
  800fcb:	e8 bc 01 00 00       	call   80118c <open>
  800fd0:	89 c3                	mov    %eax,%ebx
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 1b                	js     800ff1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdd:	89 1c 24             	mov    %ebx,(%esp)
  800fe0:	e8 54 ff ff ff       	call   800f39 <fstat>
  800fe5:	89 c6                	mov    %eax,%esi
	close(fd);
  800fe7:	89 1c 24             	mov    %ebx,(%esp)
  800fea:	e8 be fb ff ff       	call   800bad <close>
	return r;
  800fef:	89 f3                	mov    %esi,%ebx
}
  800ff1:	89 d8                	mov    %ebx,%eax
  800ff3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ff6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ff9:	89 ec                	mov    %ebp,%esp
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	00 00                	add    %al,(%eax)
	...

00801000 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 18             	sub    $0x18,%esp
  801006:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801009:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80100c:	89 c3                	mov    %eax,%ebx
  80100e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801010:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801017:	75 11                	jne    80102a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801019:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801020:	e8 54 10 00 00       	call   802079 <ipc_find_env>
  801025:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80102a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801039:	00 
  80103a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80103e:	a1 00 40 80 00       	mov    0x804000,%eax
  801043:	89 04 24             	mov    %eax,(%esp)
  801046:	e8 c3 0f 00 00       	call   80200e <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80104b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801052:	00 
  801053:	89 74 24 04          	mov    %esi,0x4(%esp)
  801057:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80105e:	e8 45 0f 00 00       	call   801fa8 <ipc_recv>
}
  801063:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801066:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801069:	89 ec                	mov    %ebp,%esp
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	53                   	push   %ebx
  801071:	83 ec 14             	sub    $0x14,%esp
  801074:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	8b 40 0c             	mov    0xc(%eax),%eax
  80107d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801082:	ba 00 00 00 00       	mov    $0x0,%edx
  801087:	b8 05 00 00 00       	mov    $0x5,%eax
  80108c:	e8 6f ff ff ff       	call   801000 <fsipc>
  801091:	85 c0                	test   %eax,%eax
  801093:	78 2b                	js     8010c0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801095:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80109c:	00 
  80109d:	89 1c 24             	mov    %ebx,(%esp)
  8010a0:	e8 16 f1 ff ff       	call   8001bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8010a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8010aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8010b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8010b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010c0:	83 c4 14             	add    $0x14,%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8010d2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8010d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8010e1:	e8 1a ff ff ff       	call   801000 <fsipc>
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 10             	sub    $0x10,%esp
  8010f0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8010f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8010fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801104:	ba 00 00 00 00       	mov    $0x0,%edx
  801109:	b8 03 00 00 00       	mov    $0x3,%eax
  80110e:	e8 ed fe ff ff       	call   801000 <fsipc>
  801113:	89 c3                	mov    %eax,%ebx
  801115:	85 c0                	test   %eax,%eax
  801117:	78 6a                	js     801183 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801119:	39 c6                	cmp    %eax,%esi
  80111b:	73 24                	jae    801141 <devfile_read+0x59>
  80111d:	c7 44 24 0c 88 24 80 	movl   $0x802488,0xc(%esp)
  801124:	00 
  801125:	c7 44 24 08 8f 24 80 	movl   $0x80248f,0x8(%esp)
  80112c:	00 
  80112d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  80113c:	e8 6f 06 00 00       	call   8017b0 <_panic>
	assert(r <= PGSIZE);
  801141:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801146:	7e 24                	jle    80116c <devfile_read+0x84>
  801148:	c7 44 24 0c af 24 80 	movl   $0x8024af,0xc(%esp)
  80114f:	00 
  801150:	c7 44 24 08 8f 24 80 	movl   $0x80248f,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  801167:	e8 44 06 00 00       	call   8017b0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80116c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801170:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801177:	00 
  801178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117b:	89 04 24             	mov    %eax,(%esp)
  80117e:	e8 29 f2 ff ff       	call   8003ac <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801183:	89 d8                	mov    %ebx,%eax
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	56                   	push   %esi
  801190:	53                   	push   %ebx
  801191:	83 ec 20             	sub    $0x20,%esp
  801194:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801197:	89 34 24             	mov    %esi,(%esp)
  80119a:	e8 d1 ef ff ff       	call   800170 <strlen>
		return -E_BAD_PATH;
  80119f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8011a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8011a9:	7f 5e                	jg     801209 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8011ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ae:	89 04 24             	mov    %eax,(%esp)
  8011b1:	e8 35 f8 ff ff       	call   8009eb <fd_alloc>
  8011b6:	89 c3                	mov    %eax,%ebx
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 4d                	js     801209 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8011bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8011c7:	e8 ef ef ff ff       	call   8001bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8011cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8011d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8011dc:	e8 1f fe ff ff       	call   801000 <fsipc>
  8011e1:	89 c3                	mov    %eax,%ebx
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	79 15                	jns    8011fc <open+0x70>
		fd_close(fd, 0);
  8011e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011ee:	00 
  8011ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f2:	89 04 24             	mov    %eax,(%esp)
  8011f5:	e8 21 f9 ff ff       	call   800b1b <fd_close>
		return r;
  8011fa:	eb 0d                	jmp    801209 <open+0x7d>
	}

	return fd2num(fd);
  8011fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ff:	89 04 24             	mov    %eax,(%esp)
  801202:	e8 b9 f7 ff ff       	call   8009c0 <fd2num>
  801207:	89 c3                	mov    %eax,%ebx
}
  801209:	89 d8                	mov    %ebx,%eax
  80120b:	83 c4 20             	add    $0x20,%esp
  80120e:	5b                   	pop    %ebx
  80120f:	5e                   	pop    %esi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    
	...

00801220 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 18             	sub    $0x18,%esp
  801226:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801229:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80122c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	89 04 24             	mov    %eax,(%esp)
  801235:	e8 96 f7 ff ff       	call   8009d0 <fd2data>
  80123a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80123c:	c7 44 24 04 bb 24 80 	movl   $0x8024bb,0x4(%esp)
  801243:	00 
  801244:	89 34 24             	mov    %esi,(%esp)
  801247:	e8 6f ef ff ff       	call   8001bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80124c:	8b 43 04             	mov    0x4(%ebx),%eax
  80124f:	2b 03                	sub    (%ebx),%eax
  801251:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801257:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80125e:	00 00 00 
	stat->st_dev = &devpipe;
  801261:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801268:	30 80 00 
	return 0;
}
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801273:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801276:	89 ec                	mov    %ebp,%esp
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	53                   	push   %ebx
  80127e:	83 ec 14             	sub    $0x14,%esp
  801281:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801284:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801288:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80128f:	e8 e5 f4 ff ff       	call   800779 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801294:	89 1c 24             	mov    %ebx,(%esp)
  801297:	e8 34 f7 ff ff       	call   8009d0 <fd2data>
  80129c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a7:	e8 cd f4 ff ff       	call   800779 <sys_page_unmap>
}
  8012ac:	83 c4 14             	add    $0x14,%esp
  8012af:	5b                   	pop    %ebx
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	57                   	push   %edi
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 2c             	sub    $0x2c,%esp
  8012bb:	89 c7                	mov    %eax,%edi
  8012bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8012c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8012c5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8012c8:	89 3c 24             	mov    %edi,(%esp)
  8012cb:	e8 f4 0d 00 00       	call   8020c4 <pageref>
  8012d0:	89 c6                	mov    %eax,%esi
  8012d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	e8 e7 0d 00 00       	call   8020c4 <pageref>
  8012dd:	39 c6                	cmp    %eax,%esi
  8012df:	0f 94 c0             	sete   %al
  8012e2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8012e5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012eb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8012ee:	39 cb                	cmp    %ecx,%ebx
  8012f0:	75 08                	jne    8012fa <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8012f2:	83 c4 2c             	add    $0x2c,%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5e                   	pop    %esi
  8012f7:	5f                   	pop    %edi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012fa:	83 f8 01             	cmp    $0x1,%eax
  8012fd:	75 c1                	jne    8012c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012ff:	8b 52 58             	mov    0x58(%edx),%edx
  801302:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801306:	89 54 24 08          	mov    %edx,0x8(%esp)
  80130a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80130e:	c7 04 24 c2 24 80 00 	movl   $0x8024c2,(%esp)
  801315:	e8 91 05 00 00       	call   8018ab <cprintf>
  80131a:	eb a4                	jmp    8012c0 <_pipeisclosed+0xe>

0080131c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 2c             	sub    $0x2c,%esp
  801325:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801328:	89 34 24             	mov    %esi,(%esp)
  80132b:	e8 a0 f6 ff ff       	call   8009d0 <fd2data>
  801330:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801332:	bf 00 00 00 00       	mov    $0x0,%edi
  801337:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80133b:	75 50                	jne    80138d <devpipe_write+0x71>
  80133d:	eb 5c                	jmp    80139b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80133f:	89 da                	mov    %ebx,%edx
  801341:	89 f0                	mov    %esi,%eax
  801343:	e8 6a ff ff ff       	call   8012b2 <_pipeisclosed>
  801348:	85 c0                	test   %eax,%eax
  80134a:	75 53                	jne    80139f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80134c:	e8 3b f3 ff ff       	call   80068c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801351:	8b 43 04             	mov    0x4(%ebx),%eax
  801354:	8b 13                	mov    (%ebx),%edx
  801356:	83 c2 20             	add    $0x20,%edx
  801359:	39 d0                	cmp    %edx,%eax
  80135b:	73 e2                	jae    80133f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80135d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801360:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801364:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801367:	89 c2                	mov    %eax,%edx
  801369:	c1 fa 1f             	sar    $0x1f,%edx
  80136c:	c1 ea 1b             	shr    $0x1b,%edx
  80136f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801372:	83 e1 1f             	and    $0x1f,%ecx
  801375:	29 d1                	sub    %edx,%ecx
  801377:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80137b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80137f:	83 c0 01             	add    $0x1,%eax
  801382:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801385:	83 c7 01             	add    $0x1,%edi
  801388:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80138b:	74 0e                	je     80139b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80138d:	8b 43 04             	mov    0x4(%ebx),%eax
  801390:	8b 13                	mov    (%ebx),%edx
  801392:	83 c2 20             	add    $0x20,%edx
  801395:	39 d0                	cmp    %edx,%eax
  801397:	73 a6                	jae    80133f <devpipe_write+0x23>
  801399:	eb c2                	jmp    80135d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80139b:	89 f8                	mov    %edi,%eax
  80139d:	eb 05                	jmp    8013a4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80139f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8013a4:	83 c4 2c             	add    $0x2c,%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 28             	sub    $0x28,%esp
  8013b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013bb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8013be:	89 3c 24             	mov    %edi,(%esp)
  8013c1:	e8 0a f6 ff ff       	call   8009d0 <fd2data>
  8013c6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013c8:	be 00 00 00 00       	mov    $0x0,%esi
  8013cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013d1:	75 47                	jne    80141a <devpipe_read+0x6e>
  8013d3:	eb 52                	jmp    801427 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	eb 5e                	jmp    801437 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8013d9:	89 da                	mov    %ebx,%edx
  8013db:	89 f8                	mov    %edi,%eax
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	e8 cd fe ff ff       	call   8012b2 <_pipeisclosed>
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	75 49                	jne    801432 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8013e9:	e8 9e f2 ff ff       	call   80068c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8013ee:	8b 03                	mov    (%ebx),%eax
  8013f0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8013f3:	74 e4                	je     8013d9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	c1 fa 1f             	sar    $0x1f,%edx
  8013fa:	c1 ea 1b             	shr    $0x1b,%edx
  8013fd:	01 d0                	add    %edx,%eax
  8013ff:	83 e0 1f             	and    $0x1f,%eax
  801402:	29 d0                	sub    %edx,%eax
  801404:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801409:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80140f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801412:	83 c6 01             	add    $0x1,%esi
  801415:	3b 75 10             	cmp    0x10(%ebp),%esi
  801418:	74 0d                	je     801427 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80141a:	8b 03                	mov    (%ebx),%eax
  80141c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80141f:	75 d4                	jne    8013f5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801421:	85 f6                	test   %esi,%esi
  801423:	75 b0                	jne    8013d5 <devpipe_read+0x29>
  801425:	eb b2                	jmp    8013d9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801427:	89 f0                	mov    %esi,%eax
  801429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801430:	eb 05                	jmp    801437 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801432:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801437:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80143a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80143d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801440:	89 ec                	mov    %ebp,%esp
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 48             	sub    $0x48,%esp
  80144a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80144d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801450:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801453:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801456:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801459:	89 04 24             	mov    %eax,(%esp)
  80145c:	e8 8a f5 ff ff       	call   8009eb <fd_alloc>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	85 c0                	test   %eax,%eax
  801465:	0f 88 45 01 00 00    	js     8015b0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80146b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801472:	00 
  801473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801481:	e8 36 f2 ff ff       	call   8006bc <sys_page_alloc>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	85 c0                	test   %eax,%eax
  80148a:	0f 88 20 01 00 00    	js     8015b0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801490:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 50 f5 ff ff       	call   8009eb <fd_alloc>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	85 c0                	test   %eax,%eax
  80149f:	0f 88 f8 00 00 00    	js     80159d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8014ac:	00 
  8014ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014bb:	e8 fc f1 ff ff       	call   8006bc <sys_page_alloc>
  8014c0:	89 c3                	mov    %eax,%ebx
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	0f 88 d3 00 00 00    	js     80159d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8014ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014cd:	89 04 24             	mov    %eax,(%esp)
  8014d0:	e8 fb f4 ff ff       	call   8009d0 <fd2data>
  8014d5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014d7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8014de:	00 
  8014df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ea:	e8 cd f1 ff ff       	call   8006bc <sys_page_alloc>
  8014ef:	89 c3                	mov    %eax,%ebx
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	0f 88 91 00 00 00    	js     80158a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014fc:	89 04 24             	mov    %eax,(%esp)
  8014ff:	e8 cc f4 ff ff       	call   8009d0 <fd2data>
  801504:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80150b:	00 
  80150c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801510:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801517:	00 
  801518:	89 74 24 04          	mov    %esi,0x4(%esp)
  80151c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801523:	e8 f3 f1 ff ff       	call   80071b <sys_page_map>
  801528:	89 c3                	mov    %eax,%ebx
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 4c                	js     80157a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80152e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801537:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80153c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801543:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801549:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80154c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80154e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801551:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80155b:	89 04 24             	mov    %eax,(%esp)
  80155e:	e8 5d f4 ff ff       	call   8009c0 <fd2num>
  801563:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801565:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801568:	89 04 24             	mov    %eax,(%esp)
  80156b:	e8 50 f4 ff ff       	call   8009c0 <fd2num>
  801570:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801573:	bb 00 00 00 00       	mov    $0x0,%ebx
  801578:	eb 36                	jmp    8015b0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80157a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801585:	e8 ef f1 ff ff       	call   800779 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80158a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80158d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801591:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801598:	e8 dc f1 ff ff       	call   800779 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80159d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ab:	e8 c9 f1 ff ff       	call   800779 <sys_page_unmap>
    err:
	return r;
}
  8015b0:	89 d8                	mov    %ebx,%eax
  8015b2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015b5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015bb:	89 ec                	mov    %ebp,%esp
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    

008015bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cf:	89 04 24             	mov    %eax,(%esp)
  8015d2:	e8 87 f4 ff ff       	call   800a5e <fd_lookup>
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 15                	js     8015f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8015db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 ea f3 ff ff       	call   8009d0 <fd2data>
	return _pipeisclosed(fd, p);
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015eb:	e8 c2 fc ff ff       	call   8012b2 <_pipeisclosed>
}
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    
	...

00801600 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801603:	b8 00 00 00 00       	mov    $0x0,%eax
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801610:	c7 44 24 04 da 24 80 	movl   $0x8024da,0x4(%esp)
  801617:	00 
  801618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161b:	89 04 24             	mov    %eax,(%esp)
  80161e:	e8 98 eb ff ff       	call   8001bb <strcpy>
	return 0;
}
  801623:	b8 00 00 00 00       	mov    $0x0,%eax
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	57                   	push   %edi
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801636:	be 00 00 00 00       	mov    $0x0,%esi
  80163b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80163f:	74 43                	je     801684 <devcons_write+0x5a>
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801646:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80164c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80164f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801651:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801654:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801659:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80165c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801660:	03 45 0c             	add    0xc(%ebp),%eax
  801663:	89 44 24 04          	mov    %eax,0x4(%esp)
  801667:	89 3c 24             	mov    %edi,(%esp)
  80166a:	e8 3d ed ff ff       	call   8003ac <memmove>
		sys_cputs(buf, m);
  80166f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801673:	89 3c 24             	mov    %edi,(%esp)
  801676:	e8 25 ef ff ff       	call   8005a0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80167b:	01 de                	add    %ebx,%esi
  80167d:	89 f0                	mov    %esi,%eax
  80167f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801682:	72 c8                	jb     80164c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801684:	89 f0                	mov    %esi,%eax
  801686:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5f                   	pop    %edi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801697:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80169c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016a0:	75 07                	jne    8016a9 <devcons_read+0x18>
  8016a2:	eb 31                	jmp    8016d5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8016a4:	e8 e3 ef ff ff       	call   80068c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8016a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8016b0:	e8 1a ef ff ff       	call   8005cf <sys_cgetc>
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	74 eb                	je     8016a4 <devcons_read+0x13>
  8016b9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 16                	js     8016d5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8016bf:	83 f8 04             	cmp    $0x4,%eax
  8016c2:	74 0c                	je     8016d0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c7:	88 10                	mov    %dl,(%eax)
	return 1;
  8016c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ce:	eb 05                	jmp    8016d5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8016d0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8016dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8016e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016ea:	00 
  8016eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016ee:	89 04 24             	mov    %eax,(%esp)
  8016f1:	e8 aa ee ff ff       	call   8005a0 <sys_cputs>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <getchar>:

int
getchar(void)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8016fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801705:	00 
  801706:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801714:	e8 05 f6 ff ff       	call   800d1e <read>
	if (r < 0)
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 0f                	js     80172c <getchar+0x34>
		return r;
	if (r < 1)
  80171d:	85 c0                	test   %eax,%eax
  80171f:	7e 06                	jle    801727 <getchar+0x2f>
		return -E_EOF;
	return c;
  801721:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801725:	eb 05                	jmp    80172c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801727:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801734:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 18 f3 ff ff       	call   800a5e <fd_lookup>
  801746:	85 c0                	test   %eax,%eax
  801748:	78 11                	js     80175b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801753:	39 10                	cmp    %edx,(%eax)
  801755:	0f 94 c0             	sete   %al
  801758:	0f b6 c0             	movzbl %al,%eax
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <opencons>:

int
opencons(void)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801763:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801766:	89 04 24             	mov    %eax,(%esp)
  801769:	e8 7d f2 ff ff       	call   8009eb <fd_alloc>
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 3c                	js     8017ae <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801772:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801779:	00 
  80177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801788:	e8 2f ef ff ff       	call   8006bc <sys_page_alloc>
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 1d                	js     8017ae <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801791:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80179c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8017a6:	89 04 24             	mov    %eax,(%esp)
  8017a9:	e8 12 f2 ff ff       	call   8009c0 <fd2num>
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	56                   	push   %esi
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8017b8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8017bb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8017c1:	e8 96 ee ff ff       	call   80065c <sys_getenvid>
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	c7 04 24 e8 24 80 00 	movl   $0x8024e8,(%esp)
  8017e3:	e8 c3 00 00 00       	call   8018ab <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8017e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 53 00 00 00       	call   80184a <vcprintf>
	cprintf("\n");
  8017f7:	c7 04 24 d3 24 80 00 	movl   $0x8024d3,(%esp)
  8017fe:	e8 a8 00 00 00       	call   8018ab <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801803:	cc                   	int3   
  801804:	eb fd                	jmp    801803 <_panic+0x53>
	...

00801808 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	53                   	push   %ebx
  80180c:	83 ec 14             	sub    $0x14,%esp
  80180f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801812:	8b 03                	mov    (%ebx),%eax
  801814:	8b 55 08             	mov    0x8(%ebp),%edx
  801817:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80181b:	83 c0 01             	add    $0x1,%eax
  80181e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801820:	3d ff 00 00 00       	cmp    $0xff,%eax
  801825:	75 19                	jne    801840 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801827:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80182e:	00 
  80182f:	8d 43 08             	lea    0x8(%ebx),%eax
  801832:	89 04 24             	mov    %eax,(%esp)
  801835:	e8 66 ed ff ff       	call   8005a0 <sys_cputs>
		b->idx = 0;
  80183a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801840:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801844:	83 c4 14             	add    $0x14,%esp
  801847:	5b                   	pop    %ebx
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801853:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80185a:	00 00 00 
	b.cnt = 0;
  80185d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801864:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	89 44 24 08          	mov    %eax,0x8(%esp)
  801875:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80187b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187f:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  801886:	e8 97 01 00 00       	call   801a22 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80188b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801891:	89 44 24 04          	mov    %eax,0x4(%esp)
  801895:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80189b:	89 04 24             	mov    %eax,(%esp)
  80189e:	e8 fd ec ff ff       	call   8005a0 <sys_cputs>

	return b.cnt;
}
  8018a3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018b1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8018b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 87 ff ff ff       	call   80184a <vcprintf>
	va_end(ap);

	return cnt;
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    
  8018c5:	00 00                	add    %al,(%eax)
	...

008018c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	57                   	push   %edi
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 3c             	sub    $0x3c,%esp
  8018d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018d4:	89 d7                	mov    %edx,%edi
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8018dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8018e5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ed:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8018f0:	72 11                	jb     801903 <printnum+0x3b>
  8018f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8018f8:	76 09                	jbe    801903 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8018fa:	83 eb 01             	sub    $0x1,%ebx
  8018fd:	85 db                	test   %ebx,%ebx
  8018ff:	7f 51                	jg     801952 <printnum+0x8a>
  801901:	eb 5e                	jmp    801961 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801903:	89 74 24 10          	mov    %esi,0x10(%esp)
  801907:	83 eb 01             	sub    $0x1,%ebx
  80190a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80190e:	8b 45 10             	mov    0x10(%ebp),%eax
  801911:	89 44 24 08          	mov    %eax,0x8(%esp)
  801915:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801919:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80191d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801924:	00 
  801925:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801928:	89 04 24             	mov    %eax,(%esp)
  80192b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80192e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801932:	e8 c9 07 00 00       	call   802100 <__udivdi3>
  801937:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80193b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80193f:	89 04 24             	mov    %eax,(%esp)
  801942:	89 54 24 04          	mov    %edx,0x4(%esp)
  801946:	89 fa                	mov    %edi,%edx
  801948:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80194b:	e8 78 ff ff ff       	call   8018c8 <printnum>
  801950:	eb 0f                	jmp    801961 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801952:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801956:	89 34 24             	mov    %esi,(%esp)
  801959:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80195c:	83 eb 01             	sub    $0x1,%ebx
  80195f:	75 f1                	jne    801952 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801961:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801965:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801969:	8b 45 10             	mov    0x10(%ebp),%eax
  80196c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801970:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801977:	00 
  801978:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80197b:	89 04 24             	mov    %eax,(%esp)
  80197e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801981:	89 44 24 04          	mov    %eax,0x4(%esp)
  801985:	e8 a6 08 00 00       	call   802230 <__umoddi3>
  80198a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80198e:	0f be 80 0b 25 80 00 	movsbl 0x80250b(%eax),%eax
  801995:	89 04 24             	mov    %eax,(%esp)
  801998:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80199b:	83 c4 3c             	add    $0x3c,%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5f                   	pop    %edi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8019a6:	83 fa 01             	cmp    $0x1,%edx
  8019a9:	7e 0e                	jle    8019b9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8019ab:	8b 10                	mov    (%eax),%edx
  8019ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8019b0:	89 08                	mov    %ecx,(%eax)
  8019b2:	8b 02                	mov    (%edx),%eax
  8019b4:	8b 52 04             	mov    0x4(%edx),%edx
  8019b7:	eb 22                	jmp    8019db <getuint+0x38>
	else if (lflag)
  8019b9:	85 d2                	test   %edx,%edx
  8019bb:	74 10                	je     8019cd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8019bd:	8b 10                	mov    (%eax),%edx
  8019bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019c2:	89 08                	mov    %ecx,(%eax)
  8019c4:	8b 02                	mov    (%edx),%eax
  8019c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cb:	eb 0e                	jmp    8019db <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8019cd:	8b 10                	mov    (%eax),%edx
  8019cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019d2:	89 08                	mov    %ecx,(%eax)
  8019d4:	8b 02                	mov    (%edx),%eax
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8019e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8019e7:	8b 10                	mov    (%eax),%edx
  8019e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8019ec:	73 0a                	jae    8019f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8019ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f1:	88 0a                	mov    %cl,(%edx)
  8019f3:	83 c2 01             	add    $0x1,%edx
  8019f6:	89 10                	mov    %edx,(%eax)
}
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801a00:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801a03:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a07:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	89 04 24             	mov    %eax,(%esp)
  801a1b:	e8 02 00 00 00       	call   801a22 <vprintfmt>
	va_end(ap);
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	57                   	push   %edi
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 5c             	sub    $0x5c,%esp
  801a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a2e:	8b 75 10             	mov    0x10(%ebp),%esi
  801a31:	eb 12                	jmp    801a45 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801a33:	85 c0                	test   %eax,%eax
  801a35:	0f 84 e4 04 00 00    	je     801f1f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  801a3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a3f:	89 04 24             	mov    %eax,(%esp)
  801a42:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a45:	0f b6 06             	movzbl (%esi),%eax
  801a48:	83 c6 01             	add    $0x1,%esi
  801a4b:	83 f8 25             	cmp    $0x25,%eax
  801a4e:	75 e3                	jne    801a33 <vprintfmt+0x11>
  801a50:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  801a54:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  801a5b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801a60:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801a67:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a6c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  801a6f:	eb 2b                	jmp    801a9c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a71:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a74:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  801a78:	eb 22                	jmp    801a9c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a7d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  801a81:	eb 19                	jmp    801a9c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a83:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801a86:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801a8d:	eb 0d                	jmp    801a9c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801a8f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  801a92:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801a95:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a9c:	0f b6 06             	movzbl (%esi),%eax
  801a9f:	0f b6 d0             	movzbl %al,%edx
  801aa2:	8d 7e 01             	lea    0x1(%esi),%edi
  801aa5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801aa8:	83 e8 23             	sub    $0x23,%eax
  801aab:	3c 55                	cmp    $0x55,%al
  801aad:	0f 87 46 04 00 00    	ja     801ef9 <vprintfmt+0x4d7>
  801ab3:	0f b6 c0             	movzbl %al,%eax
  801ab6:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801abd:	83 ea 30             	sub    $0x30,%edx
  801ac0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  801ac3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  801ac7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  801acd:	83 fa 09             	cmp    $0x9,%edx
  801ad0:	77 4a                	ja     801b1c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801ad5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  801ad8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801adb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801adf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801ae2:	8d 50 d0             	lea    -0x30(%eax),%edx
  801ae5:	83 fa 09             	cmp    $0x9,%edx
  801ae8:	76 eb                	jbe    801ad5 <vprintfmt+0xb3>
  801aea:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  801aed:	eb 2d                	jmp    801b1c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801aef:	8b 45 14             	mov    0x14(%ebp),%eax
  801af2:	8d 50 04             	lea    0x4(%eax),%edx
  801af5:	89 55 14             	mov    %edx,0x14(%ebp)
  801af8:	8b 00                	mov    (%eax),%eax
  801afa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801afd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801b00:	eb 1a                	jmp    801b1c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b02:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  801b05:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801b09:	79 91                	jns    801a9c <vprintfmt+0x7a>
  801b0b:	e9 73 ff ff ff       	jmp    801a83 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b10:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801b13:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  801b1a:	eb 80                	jmp    801a9c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  801b1c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801b20:	0f 89 76 ff ff ff    	jns    801a9c <vprintfmt+0x7a>
  801b26:	e9 64 ff ff ff       	jmp    801a8f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801b2b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b2e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801b31:	e9 66 ff ff ff       	jmp    801a9c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801b36:	8b 45 14             	mov    0x14(%ebp),%eax
  801b39:	8d 50 04             	lea    0x4(%eax),%edx
  801b3c:	89 55 14             	mov    %edx,0x14(%ebp)
  801b3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b43:	8b 00                	mov    (%eax),%eax
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b4b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801b4e:	e9 f2 fe ff ff       	jmp    801a45 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  801b53:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  801b57:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  801b5a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  801b5e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  801b61:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  801b65:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  801b68:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  801b6b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  801b6f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801b72:	80 f9 09             	cmp    $0x9,%cl
  801b75:	77 1d                	ja     801b94 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  801b77:	0f be c0             	movsbl %al,%eax
  801b7a:	6b c0 64             	imul   $0x64,%eax,%eax
  801b7d:	0f be d2             	movsbl %dl,%edx
  801b80:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801b83:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  801b8a:	a3 58 30 80 00       	mov    %eax,0x803058
  801b8f:	e9 b1 fe ff ff       	jmp    801a45 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  801b94:	c7 44 24 04 23 25 80 	movl   $0x802523,0x4(%esp)
  801b9b:	00 
  801b9c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	e8 d4 e6 ff ff       	call   80027b <strcmp>
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	75 0f                	jne    801bba <vprintfmt+0x198>
  801bab:	c7 05 58 30 80 00 04 	movl   $0x4,0x803058
  801bb2:	00 00 00 
  801bb5:	e9 8b fe ff ff       	jmp    801a45 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  801bba:	c7 44 24 04 27 25 80 	movl   $0x802527,0x4(%esp)
  801bc1:	00 
  801bc2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801bc5:	89 14 24             	mov    %edx,(%esp)
  801bc8:	e8 ae e6 ff ff       	call   80027b <strcmp>
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	75 0f                	jne    801be0 <vprintfmt+0x1be>
  801bd1:	c7 05 58 30 80 00 02 	movl   $0x2,0x803058
  801bd8:	00 00 00 
  801bdb:	e9 65 fe ff ff       	jmp    801a45 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  801be0:	c7 44 24 04 2b 25 80 	movl   $0x80252b,0x4(%esp)
  801be7:	00 
  801be8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  801beb:	89 0c 24             	mov    %ecx,(%esp)
  801bee:	e8 88 e6 ff ff       	call   80027b <strcmp>
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	75 0f                	jne    801c06 <vprintfmt+0x1e4>
  801bf7:	c7 05 58 30 80 00 01 	movl   $0x1,0x803058
  801bfe:	00 00 00 
  801c01:	e9 3f fe ff ff       	jmp    801a45 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  801c06:	c7 44 24 04 2f 25 80 	movl   $0x80252f,0x4(%esp)
  801c0d:	00 
  801c0e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  801c11:	89 3c 24             	mov    %edi,(%esp)
  801c14:	e8 62 e6 ff ff       	call   80027b <strcmp>
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	75 0f                	jne    801c2c <vprintfmt+0x20a>
  801c1d:	c7 05 58 30 80 00 06 	movl   $0x6,0x803058
  801c24:	00 00 00 
  801c27:	e9 19 fe ff ff       	jmp    801a45 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  801c2c:	c7 44 24 04 33 25 80 	movl   $0x802533,0x4(%esp)
  801c33:	00 
  801c34:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	e8 3c e6 ff ff       	call   80027b <strcmp>
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	75 0f                	jne    801c52 <vprintfmt+0x230>
  801c43:	c7 05 58 30 80 00 07 	movl   $0x7,0x803058
  801c4a:	00 00 00 
  801c4d:	e9 f3 fd ff ff       	jmp    801a45 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  801c52:	c7 44 24 04 37 25 80 	movl   $0x802537,0x4(%esp)
  801c59:	00 
  801c5a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801c5d:	89 14 24             	mov    %edx,(%esp)
  801c60:	e8 16 e6 ff ff       	call   80027b <strcmp>
  801c65:	83 f8 01             	cmp    $0x1,%eax
  801c68:	19 c0                	sbb    %eax,%eax
  801c6a:	f7 d0                	not    %eax
  801c6c:	83 c0 08             	add    $0x8,%eax
  801c6f:	a3 58 30 80 00       	mov    %eax,0x803058
  801c74:	e9 cc fd ff ff       	jmp    801a45 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  801c79:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7c:	8d 50 04             	lea    0x4(%eax),%edx
  801c7f:	89 55 14             	mov    %edx,0x14(%ebp)
  801c82:	8b 00                	mov    (%eax),%eax
  801c84:	89 c2                	mov    %eax,%edx
  801c86:	c1 fa 1f             	sar    $0x1f,%edx
  801c89:	31 d0                	xor    %edx,%eax
  801c8b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c8d:	83 f8 0f             	cmp    $0xf,%eax
  801c90:	7f 0b                	jg     801c9d <vprintfmt+0x27b>
  801c92:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  801c99:	85 d2                	test   %edx,%edx
  801c9b:	75 23                	jne    801cc0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  801c9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ca1:	c7 44 24 08 3b 25 80 	movl   $0x80253b,0x8(%esp)
  801ca8:	00 
  801ca9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cad:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cb0:	89 3c 24             	mov    %edi,(%esp)
  801cb3:	e8 42 fd ff ff       	call   8019fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cb8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801cbb:	e9 85 fd ff ff       	jmp    801a45 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801cc0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cc4:	c7 44 24 08 a1 24 80 	movl   $0x8024a1,0x8(%esp)
  801ccb:	00 
  801ccc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	e8 1f fd ff ff       	call   8019fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cdb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801cde:	e9 62 fd ff ff       	jmp    801a45 <vprintfmt+0x23>
  801ce3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  801ce6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801ce9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801cec:	8b 45 14             	mov    0x14(%ebp),%eax
  801cef:	8d 50 04             	lea    0x4(%eax),%edx
  801cf2:	89 55 14             	mov    %edx,0x14(%ebp)
  801cf5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801cf7:	85 f6                	test   %esi,%esi
  801cf9:	b8 1c 25 80 00       	mov    $0x80251c,%eax
  801cfe:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801d01:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801d05:	7e 06                	jle    801d0d <vprintfmt+0x2eb>
  801d07:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  801d0b:	75 13                	jne    801d20 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d0d:	0f be 06             	movsbl (%esi),%eax
  801d10:	83 c6 01             	add    $0x1,%esi
  801d13:	85 c0                	test   %eax,%eax
  801d15:	0f 85 94 00 00 00    	jne    801daf <vprintfmt+0x38d>
  801d1b:	e9 81 00 00 00       	jmp    801da1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d20:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d24:	89 34 24             	mov    %esi,(%esp)
  801d27:	e8 5f e4 ff ff       	call   80018b <strnlen>
  801d2c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801d2f:	29 c2                	sub    %eax,%edx
  801d31:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801d34:	85 d2                	test   %edx,%edx
  801d36:	7e d5                	jle    801d0d <vprintfmt+0x2eb>
					putch(padc, putdat);
  801d38:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  801d3c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  801d3f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  801d42:	89 d6                	mov    %edx,%esi
  801d44:	89 cf                	mov    %ecx,%edi
  801d46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4a:	89 3c 24             	mov    %edi,(%esp)
  801d4d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d50:	83 ee 01             	sub    $0x1,%esi
  801d53:	75 f1                	jne    801d46 <vprintfmt+0x324>
  801d55:	8b 7d c0             	mov    -0x40(%ebp),%edi
  801d58:	89 75 cc             	mov    %esi,-0x34(%ebp)
  801d5b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  801d5e:	eb ad                	jmp    801d0d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d60:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  801d64:	74 1b                	je     801d81 <vprintfmt+0x35f>
  801d66:	8d 50 e0             	lea    -0x20(%eax),%edx
  801d69:	83 fa 5e             	cmp    $0x5e,%edx
  801d6c:	76 13                	jbe    801d81 <vprintfmt+0x35f>
					putch('?', putdat);
  801d6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d75:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801d7c:	ff 55 08             	call   *0x8(%ebp)
  801d7f:	eb 0d                	jmp    801d8e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  801d81:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801d84:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d88:	89 04 24             	mov    %eax,(%esp)
  801d8b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d8e:	83 eb 01             	sub    $0x1,%ebx
  801d91:	0f be 06             	movsbl (%esi),%eax
  801d94:	83 c6 01             	add    $0x1,%esi
  801d97:	85 c0                	test   %eax,%eax
  801d99:	75 1a                	jne    801db5 <vprintfmt+0x393>
  801d9b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  801d9e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801da4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801da8:	7f 1c                	jg     801dc6 <vprintfmt+0x3a4>
  801daa:	e9 96 fc ff ff       	jmp    801a45 <vprintfmt+0x23>
  801daf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801db2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801db5:	85 ff                	test   %edi,%edi
  801db7:	78 a7                	js     801d60 <vprintfmt+0x33e>
  801db9:	83 ef 01             	sub    $0x1,%edi
  801dbc:	79 a2                	jns    801d60 <vprintfmt+0x33e>
  801dbe:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  801dc1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801dc4:	eb db                	jmp    801da1 <vprintfmt+0x37f>
  801dc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dc9:	89 de                	mov    %ebx,%esi
  801dcb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801dce:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801dd9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ddb:	83 eb 01             	sub    $0x1,%ebx
  801dde:	75 ee                	jne    801dce <vprintfmt+0x3ac>
  801de0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801de2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801de5:	e9 5b fc ff ff       	jmp    801a45 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801dea:	83 f9 01             	cmp    $0x1,%ecx
  801ded:	7e 10                	jle    801dff <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  801def:	8b 45 14             	mov    0x14(%ebp),%eax
  801df2:	8d 50 08             	lea    0x8(%eax),%edx
  801df5:	89 55 14             	mov    %edx,0x14(%ebp)
  801df8:	8b 30                	mov    (%eax),%esi
  801dfa:	8b 78 04             	mov    0x4(%eax),%edi
  801dfd:	eb 26                	jmp    801e25 <vprintfmt+0x403>
	else if (lflag)
  801dff:	85 c9                	test   %ecx,%ecx
  801e01:	74 12                	je     801e15 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  801e03:	8b 45 14             	mov    0x14(%ebp),%eax
  801e06:	8d 50 04             	lea    0x4(%eax),%edx
  801e09:	89 55 14             	mov    %edx,0x14(%ebp)
  801e0c:	8b 30                	mov    (%eax),%esi
  801e0e:	89 f7                	mov    %esi,%edi
  801e10:	c1 ff 1f             	sar    $0x1f,%edi
  801e13:	eb 10                	jmp    801e25 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  801e15:	8b 45 14             	mov    0x14(%ebp),%eax
  801e18:	8d 50 04             	lea    0x4(%eax),%edx
  801e1b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e1e:	8b 30                	mov    (%eax),%esi
  801e20:	89 f7                	mov    %esi,%edi
  801e22:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e25:	85 ff                	test   %edi,%edi
  801e27:	78 0e                	js     801e37 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e29:	89 f0                	mov    %esi,%eax
  801e2b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e2d:	be 0a 00 00 00       	mov    $0xa,%esi
  801e32:	e9 84 00 00 00       	jmp    801ebb <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801e37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e3b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801e42:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	89 fa                	mov    %edi,%edx
  801e49:	f7 d8                	neg    %eax
  801e4b:	83 d2 00             	adc    $0x0,%edx
  801e4e:	f7 da                	neg    %edx
			}
			base = 10;
  801e50:	be 0a 00 00 00       	mov    $0xa,%esi
  801e55:	eb 64                	jmp    801ebb <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e57:	89 ca                	mov    %ecx,%edx
  801e59:	8d 45 14             	lea    0x14(%ebp),%eax
  801e5c:	e8 42 fb ff ff       	call   8019a3 <getuint>
			base = 10;
  801e61:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  801e66:	eb 53                	jmp    801ebb <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801e68:	89 ca                	mov    %ecx,%edx
  801e6a:	8d 45 14             	lea    0x14(%ebp),%eax
  801e6d:	e8 31 fb ff ff       	call   8019a3 <getuint>
    			base = 8;
  801e72:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  801e77:	eb 42                	jmp    801ebb <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  801e79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e7d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801e84:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801e87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e8b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801e92:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801e95:	8b 45 14             	mov    0x14(%ebp),%eax
  801e98:	8d 50 04             	lea    0x4(%eax),%edx
  801e9b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801e9e:	8b 00                	mov    (%eax),%eax
  801ea0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ea5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  801eaa:	eb 0f                	jmp    801ebb <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801eac:	89 ca                	mov    %ecx,%edx
  801eae:	8d 45 14             	lea    0x14(%ebp),%eax
  801eb1:	e8 ed fa ff ff       	call   8019a3 <getuint>
			base = 16;
  801eb6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ebb:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  801ebf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ec3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801ec6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eca:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ece:	89 04 24             	mov    %eax,(%esp)
  801ed1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ed5:	89 da                	mov    %ebx,%edx
  801ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eda:	e8 e9 f9 ff ff       	call   8018c8 <printnum>
			break;
  801edf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801ee2:	e9 5e fb ff ff       	jmp    801a45 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ee7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eeb:	89 14 24             	mov    %edx,(%esp)
  801eee:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ef1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ef4:	e9 4c fb ff ff       	jmp    801a45 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ef9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801efd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801f04:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f07:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801f0b:	0f 84 34 fb ff ff    	je     801a45 <vprintfmt+0x23>
  801f11:	83 ee 01             	sub    $0x1,%esi
  801f14:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801f18:	75 f7                	jne    801f11 <vprintfmt+0x4ef>
  801f1a:	e9 26 fb ff ff       	jmp    801a45 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801f1f:	83 c4 5c             	add    $0x5c,%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 28             	sub    $0x28,%esp
  801f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f30:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f33:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f36:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f44:	85 c0                	test   %eax,%eax
  801f46:	74 30                	je     801f78 <vsnprintf+0x51>
  801f48:	85 d2                	test   %edx,%edx
  801f4a:	7e 2c                	jle    801f78 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f53:	8b 45 10             	mov    0x10(%ebp),%eax
  801f56:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f5a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f61:	c7 04 24 dd 19 80 00 	movl   $0x8019dd,(%esp)
  801f68:	e8 b5 fa ff ff       	call   801a22 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f70:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f76:	eb 05                	jmp    801f7d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f85:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9d:	89 04 24             	mov    %eax,(%esp)
  801fa0:	e8 82 ff ff ff       	call   801f27 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fa5:	c9                   	leave  
  801fa6:	c3                   	ret    
	...

00801fa8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	56                   	push   %esi
  801fac:	53                   	push   %ebx
  801fad:	83 ec 10             	sub    $0x10,%esp
  801fb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801fb9:	85 db                	test   %ebx,%ebx
  801fbb:	74 06                	je     801fc3 <ipc_recv+0x1b>
  801fbd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801fc3:	85 f6                	test   %esi,%esi
  801fc5:	74 06                	je     801fcd <ipc_recv+0x25>
  801fc7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801fd4:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801fd7:	89 04 24             	mov    %eax,(%esp)
  801fda:	e8 46 e9 ff ff       	call   800925 <sys_ipc_recv>
    if (ret) return ret;
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	75 24                	jne    802007 <ipc_recv+0x5f>
    if (from_env_store)
  801fe3:	85 db                	test   %ebx,%ebx
  801fe5:	74 0a                	je     801ff1 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801fe7:	a1 04 40 80 00       	mov    0x804004,%eax
  801fec:	8b 40 74             	mov    0x74(%eax),%eax
  801fef:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801ff1:	85 f6                	test   %esi,%esi
  801ff3:	74 0a                	je     801fff <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801ff5:	a1 04 40 80 00       	mov    0x804004,%eax
  801ffa:	8b 40 78             	mov    0x78(%eax),%eax
  801ffd:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801fff:	a1 04 40 80 00       	mov    0x804004,%eax
  802004:	8b 40 70             	mov    0x70(%eax),%eax
}
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 75 08             	mov    0x8(%ebp),%esi
  80201a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80201d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802020:	85 db                	test   %ebx,%ebx
  802022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802027:	0f 44 d8             	cmove  %eax,%ebx
  80202a:	eb 2a                	jmp    802056 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80202c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80202f:	74 20                	je     802051 <ipc_send+0x43>
  802031:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802035:	c7 44 24 08 20 28 80 	movl   $0x802820,0x8(%esp)
  80203c:	00 
  80203d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  802044:	00 
  802045:	c7 04 24 37 28 80 00 	movl   $0x802837,(%esp)
  80204c:	e8 5f f7 ff ff       	call   8017b0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802051:	e8 36 e6 ff ff       	call   80068c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802056:	8b 45 14             	mov    0x14(%ebp),%eax
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802061:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802065:	89 34 24             	mov    %esi,(%esp)
  802068:	e8 84 e8 ff ff       	call   8008f1 <sys_ipc_try_send>
  80206d:	85 c0                	test   %eax,%eax
  80206f:	75 bb                	jne    80202c <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    

00802079 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80207f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802084:	39 c8                	cmp    %ecx,%eax
  802086:	74 19                	je     8020a1 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802088:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80208d:	89 c2                	mov    %eax,%edx
  80208f:	c1 e2 07             	shl    $0x7,%edx
  802092:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802098:	8b 52 50             	mov    0x50(%edx),%edx
  80209b:	39 ca                	cmp    %ecx,%edx
  80209d:	75 14                	jne    8020b3 <ipc_find_env+0x3a>
  80209f:	eb 05                	jmp    8020a6 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020a6:	c1 e0 07             	shl    $0x7,%eax
  8020a9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8020ae:	8b 40 40             	mov    0x40(%eax),%eax
  8020b1:	eb 0e                	jmp    8020c1 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020b3:	83 c0 01             	add    $0x1,%eax
  8020b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020bb:	75 d0                	jne    80208d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020bd:	66 b8 00 00          	mov    $0x0,%ax
}
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    
	...

008020c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	c1 e8 16             	shr    $0x16,%eax
  8020cf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020db:	f6 c1 01             	test   $0x1,%cl
  8020de:	74 1d                	je     8020fd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e0:	c1 ea 0c             	shr    $0xc,%edx
  8020e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ea:	f6 c2 01             	test   $0x1,%dl
  8020ed:	74 0e                	je     8020fd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ef:	c1 ea 0c             	shr    $0xc,%edx
  8020f2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020f9:	ef 
  8020fa:	0f b7 c0             	movzwl %ax,%eax
}
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
	...

00802100 <__udivdi3>:
  802100:	83 ec 1c             	sub    $0x1c,%esp
  802103:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802107:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80210b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80210f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802113:	89 74 24 10          	mov    %esi,0x10(%esp)
  802117:	8b 74 24 24          	mov    0x24(%esp),%esi
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802121:	89 44 24 08          	mov    %eax,0x8(%esp)
  802125:	89 cd                	mov    %ecx,%ebp
  802127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212b:	75 33                	jne    802160 <__udivdi3+0x60>
  80212d:	39 f1                	cmp    %esi,%ecx
  80212f:	77 57                	ja     802188 <__udivdi3+0x88>
  802131:	85 c9                	test   %ecx,%ecx
  802133:	75 0b                	jne    802140 <__udivdi3+0x40>
  802135:	b8 01 00 00 00       	mov    $0x1,%eax
  80213a:	31 d2                	xor    %edx,%edx
  80213c:	f7 f1                	div    %ecx
  80213e:	89 c1                	mov    %eax,%ecx
  802140:	89 f0                	mov    %esi,%eax
  802142:	31 d2                	xor    %edx,%edx
  802144:	f7 f1                	div    %ecx
  802146:	89 c6                	mov    %eax,%esi
  802148:	8b 44 24 04          	mov    0x4(%esp),%eax
  80214c:	f7 f1                	div    %ecx
  80214e:	89 f2                	mov    %esi,%edx
  802150:	8b 74 24 10          	mov    0x10(%esp),%esi
  802154:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802158:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	c3                   	ret    
  802160:	31 d2                	xor    %edx,%edx
  802162:	31 c0                	xor    %eax,%eax
  802164:	39 f7                	cmp    %esi,%edi
  802166:	77 e8                	ja     802150 <__udivdi3+0x50>
  802168:	0f bd cf             	bsr    %edi,%ecx
  80216b:	83 f1 1f             	xor    $0x1f,%ecx
  80216e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802172:	75 2c                	jne    8021a0 <__udivdi3+0xa0>
  802174:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802178:	76 04                	jbe    80217e <__udivdi3+0x7e>
  80217a:	39 f7                	cmp    %esi,%edi
  80217c:	73 d2                	jae    802150 <__udivdi3+0x50>
  80217e:	31 d2                	xor    %edx,%edx
  802180:	b8 01 00 00 00       	mov    $0x1,%eax
  802185:	eb c9                	jmp    802150 <__udivdi3+0x50>
  802187:	90                   	nop
  802188:	89 f2                	mov    %esi,%edx
  80218a:	f7 f1                	div    %ecx
  80218c:	31 d2                	xor    %edx,%edx
  80218e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802192:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802196:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	c3                   	ret    
  80219e:	66 90                	xchg   %ax,%ax
  8021a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021a5:	b8 20 00 00 00       	mov    $0x20,%eax
  8021aa:	89 ea                	mov    %ebp,%edx
  8021ac:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b0:	d3 e7                	shl    %cl,%edi
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	d3 ea                	shr    %cl,%edx
  8021b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021bb:	09 fa                	or     %edi,%edx
  8021bd:	89 f7                	mov    %esi,%edi
  8021bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c9:	d3 e5                	shl    %cl,%ebp
  8021cb:	89 c1                	mov    %eax,%ecx
  8021cd:	d3 ef                	shr    %cl,%edi
  8021cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021d4:	d3 e2                	shl    %cl,%edx
  8021d6:	89 c1                	mov    %eax,%ecx
  8021d8:	d3 ee                	shr    %cl,%esi
  8021da:	09 d6                	or     %edx,%esi
  8021dc:	89 fa                	mov    %edi,%edx
  8021de:	89 f0                	mov    %esi,%eax
  8021e0:	f7 74 24 0c          	divl   0xc(%esp)
  8021e4:	89 d7                	mov    %edx,%edi
  8021e6:	89 c6                	mov    %eax,%esi
  8021e8:	f7 e5                	mul    %ebp
  8021ea:	39 d7                	cmp    %edx,%edi
  8021ec:	72 22                	jb     802210 <__udivdi3+0x110>
  8021ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8021f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021f7:	d3 e5                	shl    %cl,%ebp
  8021f9:	39 c5                	cmp    %eax,%ebp
  8021fb:	73 04                	jae    802201 <__udivdi3+0x101>
  8021fd:	39 d7                	cmp    %edx,%edi
  8021ff:	74 0f                	je     802210 <__udivdi3+0x110>
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	e9 46 ff ff ff       	jmp    802150 <__udivdi3+0x50>
  80220a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802210:	8d 46 ff             	lea    -0x1(%esi),%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	8b 74 24 10          	mov    0x10(%esp),%esi
  802219:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80221d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	c3                   	ret    
	...

00802230 <__umoddi3>:
  802230:	83 ec 1c             	sub    $0x1c,%esp
  802233:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802237:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80223b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80223f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802243:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802247:	8b 74 24 24          	mov    0x24(%esp),%esi
  80224b:	85 ed                	test   %ebp,%ebp
  80224d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802251:	89 44 24 08          	mov    %eax,0x8(%esp)
  802255:	89 cf                	mov    %ecx,%edi
  802257:	89 04 24             	mov    %eax,(%esp)
  80225a:	89 f2                	mov    %esi,%edx
  80225c:	75 1a                	jne    802278 <__umoddi3+0x48>
  80225e:	39 f1                	cmp    %esi,%ecx
  802260:	76 4e                	jbe    8022b0 <__umoddi3+0x80>
  802262:	f7 f1                	div    %ecx
  802264:	89 d0                	mov    %edx,%eax
  802266:	31 d2                	xor    %edx,%edx
  802268:	8b 74 24 10          	mov    0x10(%esp),%esi
  80226c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802270:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	c3                   	ret    
  802278:	39 f5                	cmp    %esi,%ebp
  80227a:	77 54                	ja     8022d0 <__umoddi3+0xa0>
  80227c:	0f bd c5             	bsr    %ebp,%eax
  80227f:	83 f0 1f             	xor    $0x1f,%eax
  802282:	89 44 24 04          	mov    %eax,0x4(%esp)
  802286:	75 60                	jne    8022e8 <__umoddi3+0xb8>
  802288:	3b 0c 24             	cmp    (%esp),%ecx
  80228b:	0f 87 07 01 00 00    	ja     802398 <__umoddi3+0x168>
  802291:	89 f2                	mov    %esi,%edx
  802293:	8b 34 24             	mov    (%esp),%esi
  802296:	29 ce                	sub    %ecx,%esi
  802298:	19 ea                	sbb    %ebp,%edx
  80229a:	89 34 24             	mov    %esi,(%esp)
  80229d:	8b 04 24             	mov    (%esp),%eax
  8022a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022ac:	83 c4 1c             	add    $0x1c,%esp
  8022af:	c3                   	ret    
  8022b0:	85 c9                	test   %ecx,%ecx
  8022b2:	75 0b                	jne    8022bf <__umoddi3+0x8f>
  8022b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b9:	31 d2                	xor    %edx,%edx
  8022bb:	f7 f1                	div    %ecx
  8022bd:	89 c1                	mov    %eax,%ecx
  8022bf:	89 f0                	mov    %esi,%eax
  8022c1:	31 d2                	xor    %edx,%edx
  8022c3:	f7 f1                	div    %ecx
  8022c5:	8b 04 24             	mov    (%esp),%eax
  8022c8:	f7 f1                	div    %ecx
  8022ca:	eb 98                	jmp    802264 <__umoddi3+0x34>
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022de:	83 c4 1c             	add    $0x1c,%esp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022ed:	89 e8                	mov    %ebp,%eax
  8022ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8022f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8022f8:	89 fa                	mov    %edi,%edx
  8022fa:	d3 e0                	shl    %cl,%eax
  8022fc:	89 e9                	mov    %ebp,%ecx
  8022fe:	d3 ea                	shr    %cl,%edx
  802300:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802305:	09 c2                	or     %eax,%edx
  802307:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230b:	89 14 24             	mov    %edx,(%esp)
  80230e:	89 f2                	mov    %esi,%edx
  802310:	d3 e7                	shl    %cl,%edi
  802312:	89 e9                	mov    %ebp,%ecx
  802314:	d3 ea                	shr    %cl,%edx
  802316:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80231b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80231f:	d3 e6                	shl    %cl,%esi
  802321:	89 e9                	mov    %ebp,%ecx
  802323:	d3 e8                	shr    %cl,%eax
  802325:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80232a:	09 f0                	or     %esi,%eax
  80232c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802330:	f7 34 24             	divl   (%esp)
  802333:	d3 e6                	shl    %cl,%esi
  802335:	89 74 24 08          	mov    %esi,0x8(%esp)
  802339:	89 d6                	mov    %edx,%esi
  80233b:	f7 e7                	mul    %edi
  80233d:	39 d6                	cmp    %edx,%esi
  80233f:	89 c1                	mov    %eax,%ecx
  802341:	89 d7                	mov    %edx,%edi
  802343:	72 3f                	jb     802384 <__umoddi3+0x154>
  802345:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802349:	72 35                	jb     802380 <__umoddi3+0x150>
  80234b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80234f:	29 c8                	sub    %ecx,%eax
  802351:	19 fe                	sbb    %edi,%esi
  802353:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802358:	89 f2                	mov    %esi,%edx
  80235a:	d3 e8                	shr    %cl,%eax
  80235c:	89 e9                	mov    %ebp,%ecx
  80235e:	d3 e2                	shl    %cl,%edx
  802360:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802365:	09 d0                	or     %edx,%eax
  802367:	89 f2                	mov    %esi,%edx
  802369:	d3 ea                	shr    %cl,%edx
  80236b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80236f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802373:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802377:	83 c4 1c             	add    $0x1c,%esp
  80237a:	c3                   	ret    
  80237b:	90                   	nop
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	39 d6                	cmp    %edx,%esi
  802382:	75 c7                	jne    80234b <__umoddi3+0x11b>
  802384:	89 d7                	mov    %edx,%edi
  802386:	89 c1                	mov    %eax,%ecx
  802388:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80238c:	1b 3c 24             	sbb    (%esp),%edi
  80238f:	eb ba                	jmp    80234b <__umoddi3+0x11b>
  802391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802398:	39 f5                	cmp    %esi,%ebp
  80239a:	0f 82 f1 fe ff ff    	jb     802291 <__umoddi3+0x61>
  8023a0:	e9 f8 fe ff ff       	jmp    80229d <__umoddi3+0x6d>
