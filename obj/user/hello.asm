
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 20 23 80 00 	movl   $0x802320,(%esp)
  800041:	e8 29 01 00 00       	call   80016f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 40 80 00       	mov    0x804004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 2e 23 80 00 	movl   $0x80232e,(%esp)
  800059:	e8 11 01 00 00       	call   80016f <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800072:	e8 e5 0c 00 00       	call   800d5c <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	c1 e0 07             	shl    $0x7,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 23 12 00 00       	call   8012de <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 38 0c 00 00       	call   800cff <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 14             	sub    $0x14,%esp
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d6:	8b 03                	mov    (%ebx),%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000df:	83 c0 01             	add    $0x1,%eax
  8000e2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e9:	75 19                	jne    800104 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f2:	00 
  8000f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f6:	89 04 24             	mov    %eax,(%esp)
  8000f9:	e8 a2 0b 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  8000fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800104:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800108:	83 c4 14             	add    $0x14,%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011e:	00 00 00 
	b.cnt = 0;
  800121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 cc 00 80 00 	movl   $0x8000cc,(%esp)
  80014a:	e8 97 01 00 00       	call   8002e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 39 0b 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  800167:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800175:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 87 ff ff ff       	call   80010e <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
	...

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 3c             	sub    $0x3c,%esp
  800195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800198:	89 d7                	mov    %edx,%edi
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b4:	72 11                	jb     8001c7 <printnum+0x3b>
  8001b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001bc:	76 09                	jbe    8001c7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001be:	83 eb 01             	sub    $0x1,%ebx
  8001c1:	85 db                	test   %ebx,%ebx
  8001c3:	7f 51                	jg     800216 <printnum+0x8a>
  8001c5:	eb 5e                	jmp    800225 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001cb:	83 eb 01             	sub    $0x1,%ebx
  8001ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001dd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e8:	00 
  8001e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f6:	e8 65 1e 00 00       	call   802060 <__udivdi3>
  8001fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020a:	89 fa                	mov    %edi,%edx
  80020c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020f:	e8 78 ff ff ff       	call   80018c <printnum>
  800214:	eb 0f                	jmp    800225 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800216:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021a:	89 34 24             	mov    %esi,(%esp)
  80021d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	75 f1                	jne    800216 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800225:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800229:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80022d:	8b 45 10             	mov    0x10(%ebp),%eax
  800230:	89 44 24 08          	mov    %eax,0x8(%esp)
  800234:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023b:	00 
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	e8 42 1f 00 00       	call   802190 <__umoddi3>
  80024e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800252:	0f be 80 4f 23 80 00 	movsbl 0x80234f(%eax),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80025f:	83 c4 3c             	add    $0x3c,%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026a:	83 fa 01             	cmp    $0x1,%edx
  80026d:	7e 0e                	jle    80027d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	8d 4a 08             	lea    0x8(%edx),%ecx
  800274:	89 08                	mov    %ecx,(%eax)
  800276:	8b 02                	mov    (%edx),%eax
  800278:	8b 52 04             	mov    0x4(%edx),%edx
  80027b:	eb 22                	jmp    80029f <getuint+0x38>
	else if (lflag)
  80027d:	85 d2                	test   %edx,%edx
  80027f:	74 10                	je     800291 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
  80028f:	eb 0e                	jmp    80029f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b0:	73 0a                	jae    8002bc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b5:	88 0a                	mov    %cl,(%edx)
  8002b7:	83 c2 01             	add    $0x1,%edx
  8002ba:	89 10                	mov    %edx,(%eax)
}
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 02 00 00 00       	call   8002e6 <vprintfmt>
	va_end(ap);
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 5c             	sub    $0x5c,%esp
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f5:	eb 12                	jmp    800309 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	0f 84 e4 04 00 00    	je     8007e3 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 06             	movzbl (%esi),%eax
  80030c:	83 c6 01             	add    $0x1,%esi
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	75 e3                	jne    8002f7 <vprintfmt+0x11>
  800314:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800318:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80031f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800324:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80032b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800330:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800333:	eb 2b                	jmp    800360 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800338:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80033c:	eb 22                	jmp    800360 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800345:	eb 19                	jmp    800360 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80034a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800351:	eb 0d                	jmp    800360 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800353:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800356:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800359:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	0f b6 06             	movzbl (%esi),%eax
  800363:	0f b6 d0             	movzbl %al,%edx
  800366:	8d 7e 01             	lea    0x1(%esi),%edi
  800369:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80036c:	83 e8 23             	sub    $0x23,%eax
  80036f:	3c 55                	cmp    $0x55,%al
  800371:	0f 87 46 04 00 00    	ja     8007bd <vprintfmt+0x4d7>
  800377:	0f b6 c0             	movzbl %al,%eax
  80037a:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800381:	83 ea 30             	sub    $0x30,%edx
  800384:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800387:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80038b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800391:	83 fa 09             	cmp    $0x9,%edx
  800394:	77 4a                	ja     8003e0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800399:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80039c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80039f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003a3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a9:	83 fa 09             	cmp    $0x9,%edx
  8003ac:	76 eb                	jbe    800399 <vprintfmt+0xb3>
  8003ae:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003b1:	eb 2d                	jmp    8003e0 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 50 04             	lea    0x4(%eax),%edx
  8003b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c4:	eb 1a                	jmp    8003e0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003c9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003cd:	79 91                	jns    800360 <vprintfmt+0x7a>
  8003cf:	e9 73 ff ff ff       	jmp    800347 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003de:	eb 80                	jmp    800360 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003e0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003e4:	0f 89 76 ff ff ff    	jns    800360 <vprintfmt+0x7a>
  8003ea:	e9 64 ff ff ff       	jmp    800353 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f5:	e9 66 ff ff ff       	jmp    800360 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800412:	e9 f2 fe ff ff       	jmp    800309 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800417:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80041b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80041e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800422:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800425:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800429:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80042c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80042f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800433:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800436:	80 f9 09             	cmp    $0x9,%cl
  800439:	77 1d                	ja     800458 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80043b:	0f be c0             	movsbl %al,%eax
  80043e:	6b c0 64             	imul   $0x64,%eax,%eax
  800441:	0f be d2             	movsbl %dl,%edx
  800444:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800447:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80044e:	a3 04 30 80 00       	mov    %eax,0x803004
  800453:	e9 b1 fe ff ff       	jmp    800309 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800458:	c7 44 24 04 67 23 80 	movl   $0x802367,0x4(%esp)
  80045f:	00 
  800460:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	e8 10 05 00 00       	call   80097b <strcmp>
  80046b:	85 c0                	test   %eax,%eax
  80046d:	75 0f                	jne    80047e <vprintfmt+0x198>
  80046f:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800476:	00 00 00 
  800479:	e9 8b fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80047e:	c7 44 24 04 6b 23 80 	movl   $0x80236b,0x4(%esp)
  800485:	00 
  800486:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800489:	89 14 24             	mov    %edx,(%esp)
  80048c:	e8 ea 04 00 00       	call   80097b <strcmp>
  800491:	85 c0                	test   %eax,%eax
  800493:	75 0f                	jne    8004a4 <vprintfmt+0x1be>
  800495:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  80049c:	00 00 00 
  80049f:	e9 65 fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004a4:	c7 44 24 04 6f 23 80 	movl   $0x80236f,0x4(%esp)
  8004ab:	00 
  8004ac:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004af:	89 0c 24             	mov    %ecx,(%esp)
  8004b2:	e8 c4 04 00 00       	call   80097b <strcmp>
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	75 0f                	jne    8004ca <vprintfmt+0x1e4>
  8004bb:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8004c2:	00 00 00 
  8004c5:	e9 3f fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004ca:	c7 44 24 04 73 23 80 	movl   $0x802373,0x4(%esp)
  8004d1:	00 
  8004d2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004d5:	89 3c 24             	mov    %edi,(%esp)
  8004d8:	e8 9e 04 00 00       	call   80097b <strcmp>
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	75 0f                	jne    8004f0 <vprintfmt+0x20a>
  8004e1:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  8004e8:	00 00 00 
  8004eb:	e9 19 fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004f0:	c7 44 24 04 77 23 80 	movl   $0x802377,0x4(%esp)
  8004f7:	00 
  8004f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	e8 78 04 00 00       	call   80097b <strcmp>
  800503:	85 c0                	test   %eax,%eax
  800505:	75 0f                	jne    800516 <vprintfmt+0x230>
  800507:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  80050e:	00 00 00 
  800511:	e9 f3 fd ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800516:	c7 44 24 04 7b 23 80 	movl   $0x80237b,0x4(%esp)
  80051d:	00 
  80051e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800521:	89 14 24             	mov    %edx,(%esp)
  800524:	e8 52 04 00 00       	call   80097b <strcmp>
  800529:	83 f8 01             	cmp    $0x1,%eax
  80052c:	19 c0                	sbb    %eax,%eax
  80052e:	f7 d0                	not    %eax
  800530:	83 c0 08             	add    $0x8,%eax
  800533:	a3 04 30 80 00       	mov    %eax,0x803004
  800538:	e9 cc fd ff ff       	jmp    800309 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 c2                	mov    %eax,%edx
  80054a:	c1 fa 1f             	sar    $0x1f,%edx
  80054d:	31 d0                	xor    %edx,%eax
  80054f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800551:	83 f8 0f             	cmp    $0xf,%eax
  800554:	7f 0b                	jg     800561 <vprintfmt+0x27b>
  800556:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  80055d:	85 d2                	test   %edx,%edx
  80055f:	75 23                	jne    800584 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800561:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800565:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  80056c:	00 
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	8b 7d 08             	mov    0x8(%ebp),%edi
  800574:	89 3c 24             	mov    %edi,(%esp)
  800577:	e8 42 fd ff ff       	call   8002be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057f:	e9 85 fd ff ff       	jmp    800309 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800584:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800588:	c7 44 24 08 31 27 80 	movl   $0x802731,0x8(%esp)
  80058f:	00 
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	8b 7d 08             	mov    0x8(%ebp),%edi
  800597:	89 3c 24             	mov    %edi,(%esp)
  80059a:	e8 1f fd ff ff       	call   8002be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a2:	e9 62 fd ff ff       	jmp    800309 <vprintfmt+0x23>
  8005a7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005bb:	85 f6                	test   %esi,%esi
  8005bd:	b8 60 23 80 00       	mov    $0x802360,%eax
  8005c2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005c5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005c9:	7e 06                	jle    8005d1 <vprintfmt+0x2eb>
  8005cb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005cf:	75 13                	jne    8005e4 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d1:	0f be 06             	movsbl (%esi),%eax
  8005d4:	83 c6 01             	add    $0x1,%esi
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	0f 85 94 00 00 00    	jne    800673 <vprintfmt+0x38d>
  8005df:	e9 81 00 00 00       	jmp    800665 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e8:	89 34 24             	mov    %esi,(%esp)
  8005eb:	e8 9b 02 00 00       	call   80088b <strnlen>
  8005f0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	7e d5                	jle    8005d1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005fc:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800600:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800603:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800606:	89 d6                	mov    %edx,%esi
  800608:	89 cf                	mov    %ecx,%edi
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	89 3c 24             	mov    %edi,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	75 f1                	jne    80060a <vprintfmt+0x324>
  800619:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80061c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80061f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800622:	eb ad                	jmp    8005d1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800624:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800628:	74 1b                	je     800645 <vprintfmt+0x35f>
  80062a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80062d:	83 fa 5e             	cmp    $0x5e,%edx
  800630:	76 13                	jbe    800645 <vprintfmt+0x35f>
					putch('?', putdat);
  800632:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800635:	89 44 24 04          	mov    %eax,0x4(%esp)
  800639:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800640:	ff 55 08             	call   *0x8(%ebp)
  800643:	eb 0d                	jmp    800652 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800645:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800648:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064c:	89 04 24             	mov    %eax,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800652:	83 eb 01             	sub    $0x1,%ebx
  800655:	0f be 06             	movsbl (%esi),%eax
  800658:	83 c6 01             	add    $0x1,%esi
  80065b:	85 c0                	test   %eax,%eax
  80065d:	75 1a                	jne    800679 <vprintfmt+0x393>
  80065f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800662:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800668:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80066c:	7f 1c                	jg     80068a <vprintfmt+0x3a4>
  80066e:	e9 96 fc ff ff       	jmp    800309 <vprintfmt+0x23>
  800673:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800676:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800679:	85 ff                	test   %edi,%edi
  80067b:	78 a7                	js     800624 <vprintfmt+0x33e>
  80067d:	83 ef 01             	sub    $0x1,%edi
  800680:	79 a2                	jns    800624 <vprintfmt+0x33e>
  800682:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800685:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800688:	eb db                	jmp    800665 <vprintfmt+0x37f>
  80068a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80068d:	89 de                	mov    %ebx,%esi
  80068f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800692:	89 74 24 04          	mov    %esi,0x4(%esp)
  800696:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069f:	83 eb 01             	sub    $0x1,%ebx
  8006a2:	75 ee                	jne    800692 <vprintfmt+0x3ac>
  8006a4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006a9:	e9 5b fc ff ff       	jmp    800309 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ae:	83 f9 01             	cmp    $0x1,%ecx
  8006b1:	7e 10                	jle    8006c3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 50 08             	lea    0x8(%eax),%edx
  8006b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bc:	8b 30                	mov    (%eax),%esi
  8006be:	8b 78 04             	mov    0x4(%eax),%edi
  8006c1:	eb 26                	jmp    8006e9 <vprintfmt+0x403>
	else if (lflag)
  8006c3:	85 c9                	test   %ecx,%ecx
  8006c5:	74 12                	je     8006d9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 04             	lea    0x4(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 30                	mov    (%eax),%esi
  8006d2:	89 f7                	mov    %esi,%edi
  8006d4:	c1 ff 1f             	sar    $0x1f,%edi
  8006d7:	eb 10                	jmp    8006e9 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 50 04             	lea    0x4(%eax),%edx
  8006df:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e2:	8b 30                	mov    (%eax),%esi
  8006e4:	89 f7                	mov    %esi,%edi
  8006e6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e9:	85 ff                	test   %edi,%edi
  8006eb:	78 0e                	js     8006fb <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ed:	89 f0                	mov    %esi,%eax
  8006ef:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f1:	be 0a 00 00 00       	mov    $0xa,%esi
  8006f6:	e9 84 00 00 00       	jmp    80077f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800706:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800709:	89 f0                	mov    %esi,%eax
  80070b:	89 fa                	mov    %edi,%edx
  80070d:	f7 d8                	neg    %eax
  80070f:	83 d2 00             	adc    $0x0,%edx
  800712:	f7 da                	neg    %edx
			}
			base = 10;
  800714:	be 0a 00 00 00       	mov    $0xa,%esi
  800719:	eb 64                	jmp    80077f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071b:	89 ca                	mov    %ecx,%edx
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
  800720:	e8 42 fb ff ff       	call   800267 <getuint>
			base = 10;
  800725:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80072a:	eb 53                	jmp    80077f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80072c:	89 ca                	mov    %ecx,%edx
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
  800731:	e8 31 fb ff ff       	call   800267 <getuint>
    			base = 8;
  800736:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80073b:	eb 42                	jmp    80077f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80073d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800741:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80074b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800756:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 50 04             	lea    0x4(%eax),%edx
  80075f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800762:	8b 00                	mov    (%eax),%eax
  800764:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800769:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80076e:	eb 0f                	jmp    80077f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800770:	89 ca                	mov    %ecx,%edx
  800772:	8d 45 14             	lea    0x14(%ebp),%eax
  800775:	e8 ed fa ff ff       	call   800267 <getuint>
			base = 16;
  80077a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800783:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800787:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80078a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80078e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800792:	89 04 24             	mov    %eax,(%esp)
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	89 da                	mov    %ebx,%edx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	e8 e9 f9 ff ff       	call   80018c <printnum>
			break;
  8007a3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007a6:	e9 5e fb ff ff       	jmp    800309 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007af:	89 14 24             	mov    %edx,(%esp)
  8007b2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b8:	e9 4c fb ff ff       	jmp    800309 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007cf:	0f 84 34 fb ff ff    	je     800309 <vprintfmt+0x23>
  8007d5:	83 ee 01             	sub    $0x1,%esi
  8007d8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007dc:	75 f7                	jne    8007d5 <vprintfmt+0x4ef>
  8007de:	e9 26 fb ff ff       	jmp    800309 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007e3:	83 c4 5c             	add    $0x5c,%esp
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5f                   	pop    %edi
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	83 ec 28             	sub    $0x28,%esp
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800801:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800808:	85 c0                	test   %eax,%eax
  80080a:	74 30                	je     80083c <vsnprintf+0x51>
  80080c:	85 d2                	test   %edx,%edx
  80080e:	7e 2c                	jle    80083c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	c7 04 24 a1 02 80 00 	movl   $0x8002a1,(%esp)
  80082c:	e8 b5 fa ff ff       	call   8002e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800831:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800834:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	eb 05                	jmp    800841 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800850:	8b 45 10             	mov    0x10(%ebp),%eax
  800853:	89 44 24 08          	mov    %eax,0x8(%esp)
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	89 04 24             	mov    %eax,(%esp)
  800864:	e8 82 ff ff ff       	call   8007eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    
  80086b:	00 00                	add    %al,(%eax)
  80086d:	00 00                	add    %al,(%eax)
	...

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	80 3a 00             	cmpb   $0x0,(%edx)
  80087e:	74 09                	je     800889 <strlen+0x19>
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	75 f7                	jne    800880 <strlen+0x10>
		n++;
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	74 1a                	je     8008b8 <strnlen+0x2d>
  80089e:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008a1:	74 15                	je     8008b8 <strnlen+0x2d>
  8008a3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008a8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008aa:	39 ca                	cmp    %ecx,%edx
  8008ac:	74 0a                	je     8008b8 <strnlen+0x2d>
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008b6:	75 f0                	jne    8008a8 <strnlen+0x1d>
		n++;
	return n;
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ca:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ce:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008d1:	83 c2 01             	add    $0x1,%edx
  8008d4:	84 c9                	test   %cl,%cl
  8008d6:	75 f2                	jne    8008ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e5:	89 1c 24             	mov    %ebx,(%esp)
  8008e8:	e8 83 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f4:	01 d8                	add    %ebx,%eax
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	e8 bd ff ff ff       	call   8008bb <strcpy>
	return dst;
}
  8008fe:	89 d8                	mov    %ebx,%eax
  800900:	83 c4 08             	add    $0x8,%esp
  800903:	5b                   	pop    %ebx
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800911:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800914:	85 f6                	test   %esi,%esi
  800916:	74 18                	je     800930 <strncpy+0x2a>
  800918:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80091d:	0f b6 1a             	movzbl (%edx),%ebx
  800920:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800923:	80 3a 01             	cmpb   $0x1,(%edx)
  800926:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	39 f1                	cmp    %esi,%ecx
  80092e:	75 ed                	jne    80091d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800940:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800943:	89 f8                	mov    %edi,%eax
  800945:	85 f6                	test   %esi,%esi
  800947:	74 2b                	je     800974 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800949:	83 fe 01             	cmp    $0x1,%esi
  80094c:	74 23                	je     800971 <strlcpy+0x3d>
  80094e:	0f b6 0b             	movzbl (%ebx),%ecx
  800951:	84 c9                	test   %cl,%cl
  800953:	74 1c                	je     800971 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800955:	83 ee 02             	sub    $0x2,%esi
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095d:	88 08                	mov    %cl,(%eax)
  80095f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800962:	39 f2                	cmp    %esi,%edx
  800964:	74 0b                	je     800971 <strlcpy+0x3d>
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80096d:	84 c9                	test   %cl,%cl
  80096f:	75 ec                	jne    80095d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800971:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800974:	29 f8                	sub    %edi,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800981:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800984:	0f b6 01             	movzbl (%ecx),%eax
  800987:	84 c0                	test   %al,%al
  800989:	74 16                	je     8009a1 <strcmp+0x26>
  80098b:	3a 02                	cmp    (%edx),%al
  80098d:	75 12                	jne    8009a1 <strcmp+0x26>
		p++, q++;
  80098f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800992:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800996:	84 c0                	test   %al,%al
  800998:	74 07                	je     8009a1 <strcmp+0x26>
  80099a:	83 c1 01             	add    $0x1,%ecx
  80099d:	3a 02                	cmp    (%edx),%al
  80099f:	74 ee                	je     80098f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 c0             	movzbl %al,%eax
  8009a4:	0f b6 12             	movzbl (%edx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009bd:	85 d2                	test   %edx,%edx
  8009bf:	74 28                	je     8009e9 <strncmp+0x3e>
  8009c1:	0f b6 01             	movzbl (%ecx),%eax
  8009c4:	84 c0                	test   %al,%al
  8009c6:	74 24                	je     8009ec <strncmp+0x41>
  8009c8:	3a 03                	cmp    (%ebx),%al
  8009ca:	75 20                	jne    8009ec <strncmp+0x41>
  8009cc:	83 ea 01             	sub    $0x1,%edx
  8009cf:	74 13                	je     8009e4 <strncmp+0x39>
		n--, p++, q++;
  8009d1:	83 c1 01             	add    $0x1,%ecx
  8009d4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d7:	0f b6 01             	movzbl (%ecx),%eax
  8009da:	84 c0                	test   %al,%al
  8009dc:	74 0e                	je     8009ec <strncmp+0x41>
  8009de:	3a 03                	cmp    (%ebx),%al
  8009e0:	74 ea                	je     8009cc <strncmp+0x21>
  8009e2:	eb 08                	jmp    8009ec <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ec:	0f b6 01             	movzbl (%ecx),%eax
  8009ef:	0f b6 13             	movzbl (%ebx),%edx
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	eb f3                	jmp    8009e9 <strncmp+0x3e>

008009f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a00:	0f b6 10             	movzbl (%eax),%edx
  800a03:	84 d2                	test   %dl,%dl
  800a05:	74 1c                	je     800a23 <strchr+0x2d>
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	75 09                	jne    800a14 <strchr+0x1e>
  800a0b:	eb 1b                	jmp    800a28 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	74 14                	je     800a28 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a14:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	75 f1                	jne    800a0d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	eb 05                	jmp    800a28 <strchr+0x32>
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	84 d2                	test   %dl,%dl
  800a39:	74 14                	je     800a4f <strfind+0x25>
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	75 06                	jne    800a45 <strfind+0x1b>
  800a3f:	eb 0e                	jmp    800a4f <strfind+0x25>
  800a41:	38 ca                	cmp    %cl,%dl
  800a43:	74 0a                	je     800a4f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a45:	83 c0 01             	add    $0x1,%eax
  800a48:	0f b6 10             	movzbl (%eax),%edx
  800a4b:	84 d2                	test   %dl,%dl
  800a4d:	75 f2                	jne    800a41 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	83 ec 0c             	sub    $0xc,%esp
  800a57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a69:	85 c9                	test   %ecx,%ecx
  800a6b:	74 30                	je     800a9d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a73:	75 25                	jne    800a9a <memset+0x49>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 20                	jne    800a9a <memset+0x49>
		c &= 0xFF;
  800a7a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7d:	89 d3                	mov    %edx,%ebx
  800a7f:	c1 e3 08             	shl    $0x8,%ebx
  800a82:	89 d6                	mov    %edx,%esi
  800a84:	c1 e6 18             	shl    $0x18,%esi
  800a87:	89 d0                	mov    %edx,%eax
  800a89:	c1 e0 10             	shl    $0x10,%eax
  800a8c:	09 f0                	or     %esi,%eax
  800a8e:	09 d0                	or     %edx,%eax
  800a90:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a92:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a95:	fc                   	cld    
  800a96:	f3 ab                	rep stos %eax,%es:(%edi)
  800a98:	eb 03                	jmp    800a9d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9a:	fc                   	cld    
  800a9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9d:	89 f8                	mov    %edi,%eax
  800a9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800aa2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aa5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aa8:	89 ec                	mov    %ebp,%esp
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 08             	sub    $0x8,%esp
  800ab2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ab5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac1:	39 c6                	cmp    %eax,%esi
  800ac3:	73 36                	jae    800afb <memmove+0x4f>
  800ac5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac8:	39 d0                	cmp    %edx,%eax
  800aca:	73 2f                	jae    800afb <memmove+0x4f>
		s += n;
		d += n;
  800acc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	f6 c2 03             	test   $0x3,%dl
  800ad2:	75 1b                	jne    800aef <memmove+0x43>
  800ad4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ada:	75 13                	jne    800aef <memmove+0x43>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 0e                	jne    800aef <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae1:	83 ef 04             	sub    $0x4,%edi
  800ae4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aea:	fd                   	std    
  800aeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aed:	eb 09                	jmp    800af8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aef:	83 ef 01             	sub    $0x1,%edi
  800af2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af5:	fd                   	std    
  800af6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af8:	fc                   	cld    
  800af9:	eb 20                	jmp    800b1b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b01:	75 13                	jne    800b16 <memmove+0x6a>
  800b03:	a8 03                	test   $0x3,%al
  800b05:	75 0f                	jne    800b16 <memmove+0x6a>
  800b07:	f6 c1 03             	test   $0x3,%cl
  800b0a:	75 0a                	jne    800b16 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b0c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	fc                   	cld    
  800b12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b14:	eb 05                	jmp    800b1b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b16:	89 c7                	mov    %eax,%edi
  800b18:	fc                   	cld    
  800b19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b21:	89 ec                	mov    %ebp,%esp
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	89 04 24             	mov    %eax,(%esp)
  800b3f:	e8 68 ff ff ff       	call   800aac <memmove>
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b52:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5a:	85 ff                	test   %edi,%edi
  800b5c:	74 37                	je     800b95 <memcmp+0x4f>
		if (*s1 != *s2)
  800b5e:	0f b6 03             	movzbl (%ebx),%eax
  800b61:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b64:	83 ef 01             	sub    $0x1,%edi
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b6c:	38 c8                	cmp    %cl,%al
  800b6e:	74 1c                	je     800b8c <memcmp+0x46>
  800b70:	eb 10                	jmp    800b82 <memcmp+0x3c>
  800b72:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b77:	83 c2 01             	add    $0x1,%edx
  800b7a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b7e:	38 c8                	cmp    %cl,%al
  800b80:	74 0a                	je     800b8c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b82:	0f b6 c0             	movzbl %al,%eax
  800b85:	0f b6 c9             	movzbl %cl,%ecx
  800b88:	29 c8                	sub    %ecx,%eax
  800b8a:	eb 09                	jmp    800b95 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8c:	39 fa                	cmp    %edi,%edx
  800b8e:	75 e2                	jne    800b72 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ba0:	89 c2                	mov    %eax,%edx
  800ba2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba5:	39 d0                	cmp    %edx,%eax
  800ba7:	73 19                	jae    800bc2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bad:	38 08                	cmp    %cl,(%eax)
  800baf:	75 06                	jne    800bb7 <memfind+0x1d>
  800bb1:	eb 0f                	jmp    800bc2 <memfind+0x28>
  800bb3:	38 08                	cmp    %cl,(%eax)
  800bb5:	74 0b                	je     800bc2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	39 d0                	cmp    %edx,%eax
  800bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bc0:	75 f1                	jne    800bb3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd0:	0f b6 02             	movzbl (%edx),%eax
  800bd3:	3c 20                	cmp    $0x20,%al
  800bd5:	74 04                	je     800bdb <strtol+0x17>
  800bd7:	3c 09                	cmp    $0x9,%al
  800bd9:	75 0e                	jne    800be9 <strtol+0x25>
		s++;
  800bdb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bde:	0f b6 02             	movzbl (%edx),%eax
  800be1:	3c 20                	cmp    $0x20,%al
  800be3:	74 f6                	je     800bdb <strtol+0x17>
  800be5:	3c 09                	cmp    $0x9,%al
  800be7:	74 f2                	je     800bdb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be9:	3c 2b                	cmp    $0x2b,%al
  800beb:	75 0a                	jne    800bf7 <strtol+0x33>
		s++;
  800bed:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf5:	eb 10                	jmp    800c07 <strtol+0x43>
  800bf7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bfc:	3c 2d                	cmp    $0x2d,%al
  800bfe:	75 07                	jne    800c07 <strtol+0x43>
		s++, neg = 1;
  800c00:	83 c2 01             	add    $0x1,%edx
  800c03:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c07:	85 db                	test   %ebx,%ebx
  800c09:	0f 94 c0             	sete   %al
  800c0c:	74 05                	je     800c13 <strtol+0x4f>
  800c0e:	83 fb 10             	cmp    $0x10,%ebx
  800c11:	75 15                	jne    800c28 <strtol+0x64>
  800c13:	80 3a 30             	cmpb   $0x30,(%edx)
  800c16:	75 10                	jne    800c28 <strtol+0x64>
  800c18:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c1c:	75 0a                	jne    800c28 <strtol+0x64>
		s += 2, base = 16;
  800c1e:	83 c2 02             	add    $0x2,%edx
  800c21:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c26:	eb 13                	jmp    800c3b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c28:	84 c0                	test   %al,%al
  800c2a:	74 0f                	je     800c3b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c31:	80 3a 30             	cmpb   $0x30,(%edx)
  800c34:	75 05                	jne    800c3b <strtol+0x77>
		s++, base = 8;
  800c36:	83 c2 01             	add    $0x1,%edx
  800c39:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c40:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c42:	0f b6 0a             	movzbl (%edx),%ecx
  800c45:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c48:	80 fb 09             	cmp    $0x9,%bl
  800c4b:	77 08                	ja     800c55 <strtol+0x91>
			dig = *s - '0';
  800c4d:	0f be c9             	movsbl %cl,%ecx
  800c50:	83 e9 30             	sub    $0x30,%ecx
  800c53:	eb 1e                	jmp    800c73 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c55:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c58:	80 fb 19             	cmp    $0x19,%bl
  800c5b:	77 08                	ja     800c65 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c5d:	0f be c9             	movsbl %cl,%ecx
  800c60:	83 e9 57             	sub    $0x57,%ecx
  800c63:	eb 0e                	jmp    800c73 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c65:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c68:	80 fb 19             	cmp    $0x19,%bl
  800c6b:	77 14                	ja     800c81 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c6d:	0f be c9             	movsbl %cl,%ecx
  800c70:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c73:	39 f1                	cmp    %esi,%ecx
  800c75:	7d 0e                	jge    800c85 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c77:	83 c2 01             	add    $0x1,%edx
  800c7a:	0f af c6             	imul   %esi,%eax
  800c7d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c7f:	eb c1                	jmp    800c42 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c81:	89 c1                	mov    %eax,%ecx
  800c83:	eb 02                	jmp    800c87 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c85:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c8b:	74 05                	je     800c92 <strtol+0xce>
		*endptr = (char *) s;
  800c8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c90:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c92:	89 ca                	mov    %ecx,%edx
  800c94:	f7 da                	neg    %edx
  800c96:	85 ff                	test   %edi,%edi
  800c98:	0f 45 c2             	cmovne %edx,%eax
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 c3                	mov    %eax,%ebx
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	89 c6                	mov    %eax,%esi
  800cc0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ccb:	89 ec                	mov    %ebp,%esp
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_cgetc>:

int
sys_cgetc(void)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfb:	89 ec                	mov    %ebp,%esp
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 38             	sub    $0x38,%esp
  800d05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d13:	b8 03 00 00 00       	mov    $0x3,%eax
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	89 cb                	mov    %ecx,%ebx
  800d1d:	89 cf                	mov    %ecx,%edi
  800d1f:	89 ce                	mov    %ecx,%esi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 28                	jle    800d4f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d32:	00 
  800d33:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800d4a:	e8 61 11 00 00       	call   801eb0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d58:	89 ec                	mov    %ebp,%esp
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d68:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d70:	b8 02 00 00 00       	mov    $0x2,%eax
  800d75:	89 d1                	mov    %edx,%ecx
  800d77:	89 d3                	mov    %edx,%ebx
  800d79:	89 d7                	mov    %edx,%edi
  800d7b:	89 d6                	mov    %edx,%esi
  800d7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d88:	89 ec                	mov    %ebp,%esp
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_yield>:

void
sys_yield(void)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d98:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 38             	sub    $0x38,%esp
  800dc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 f7                	mov    %esi,%edi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e09:	e8 a2 10 00 00       	call   801eb0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e17:	89 ec                	mov    %ebp,%esp
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 38             	sub    $0x38,%esp
  800e21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e2f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 28                	jle    800e6c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e48:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e4f:	00 
  800e50:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e67:	e8 44 10 00 00       	call   801eb0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e6f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e72:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e75:	89 ec                	mov    %ebp,%esp
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 38             	sub    $0x38,%esp
  800e7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e85:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	89 df                	mov    %ebx,%edi
  800e9a:	89 de                	mov    %ebx,%esi
  800e9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	7e 28                	jle    800eca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ead:	00 
  800eae:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800ec5:	e8 e6 0f 00 00       	call   801eb0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed3:	89 ec                	mov    %ebp,%esp
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 38             	sub    $0x38,%esp
  800edd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eeb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	89 df                	mov    %ebx,%edi
  800ef8:	89 de                	mov    %ebx,%esi
  800efa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	7e 28                	jle    800f28 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f13:	00 
  800f14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1b:	00 
  800f1c:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f23:	e8 88 0f 00 00       	call   801eb0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f28:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f31:	89 ec                	mov    %ebp,%esp
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 38             	sub    $0x38,%esp
  800f3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f41:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f49:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	89 df                	mov    %ebx,%edi
  800f56:	89 de                	mov    %ebx,%esi
  800f58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	7e 28                	jle    800f86 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f62:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f69:	00 
  800f6a:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f71:	00 
  800f72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f79:	00 
  800f7a:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f81:	e8 2a 0f 00 00       	call   801eb0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8f:	89 ec                	mov    %ebp,%esp
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 38             	sub    $0x38,%esp
  800f99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb2:	89 df                	mov    %ebx,%edi
  800fb4:	89 de                	mov    %ebx,%esi
  800fb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	7e 28                	jle    800fe4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800fcf:	00 
  800fd0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd7:	00 
  800fd8:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800fdf:	e8 cc 0e 00 00       	call   801eb0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fe4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fed:	89 ec                	mov    %ebp,%esp
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ffa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ffd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801000:	be 00 00 00 00       	mov    $0x0,%esi
  801005:	b8 0c 00 00 00       	mov    $0xc,%eax
  80100a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80100d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801018:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801021:	89 ec                	mov    %ebp,%esp
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 38             	sub    $0x38,%esp
  80102b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801031:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801034:	b9 00 00 00 00       	mov    $0x0,%ecx
  801039:	b8 0d 00 00 00       	mov    $0xd,%eax
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	89 cb                	mov    %ecx,%ebx
  801043:	89 cf                	mov    %ecx,%edi
  801045:	89 ce                	mov    %ecx,%esi
  801047:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	7e 28                	jle    801075 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801051:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801058:	00 
  801059:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  801070:	e8 3b 0e 00 00       	call   801eb0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801075:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801078:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107e:	89 ec                	mov    %ebp,%esp
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80108e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801091:	b9 00 00 00 00       	mov    $0x0,%ecx
  801096:	b8 0e 00 00 00       	mov    $0xe,%eax
  80109b:	8b 55 08             	mov    0x8(%ebp),%edx
  80109e:	89 cb                	mov    %ecx,%ebx
  8010a0:	89 cf                	mov    %ecx,%edi
  8010a2:	89 ce                	mov    %ecx,%esi
  8010a4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8010a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010af:	89 ec                	mov    %ebp,%esp
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    
	...

008010c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	89 04 24             	mov    %eax,(%esp)
  8010dc:	e8 df ff ff ff       	call   8010c0 <fd2num>
  8010e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	53                   	push   %ebx
  8010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010f2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010f7:	a8 01                	test   $0x1,%al
  8010f9:	74 34                	je     80112f <fd_alloc+0x44>
  8010fb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801100:	a8 01                	test   $0x1,%al
  801102:	74 32                	je     801136 <fd_alloc+0x4b>
  801104:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801109:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80110b:	89 c2                	mov    %eax,%edx
  80110d:	c1 ea 16             	shr    $0x16,%edx
  801110:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801117:	f6 c2 01             	test   $0x1,%dl
  80111a:	74 1f                	je     80113b <fd_alloc+0x50>
  80111c:	89 c2                	mov    %eax,%edx
  80111e:	c1 ea 0c             	shr    $0xc,%edx
  801121:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801128:	f6 c2 01             	test   $0x1,%dl
  80112b:	75 17                	jne    801144 <fd_alloc+0x59>
  80112d:	eb 0c                	jmp    80113b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80112f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801134:	eb 05                	jmp    80113b <fd_alloc+0x50>
  801136:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80113b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80113d:	b8 00 00 00 00       	mov    $0x0,%eax
  801142:	eb 17                	jmp    80115b <fd_alloc+0x70>
  801144:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801149:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114e:	75 b9                	jne    801109 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801156:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115b:	5b                   	pop    %ebx
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801164:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801169:	83 fa 1f             	cmp    $0x1f,%edx
  80116c:	77 3f                	ja     8011ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80116e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801174:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801177:	89 d0                	mov    %edx,%eax
  801179:	c1 e8 16             	shr    $0x16,%eax
  80117c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801183:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801188:	f6 c1 01             	test   $0x1,%cl
  80118b:	74 20                	je     8011ad <fd_lookup+0x4f>
  80118d:	89 d0                	mov    %edx,%eax
  80118f:	c1 e8 0c             	shr    $0xc,%eax
  801192:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801199:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119e:	f6 c1 01             	test   $0x1,%cl
  8011a1:	74 0a                	je     8011ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 14             	sub    $0x14,%esp
  8011b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011bc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011c1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8011c7:	75 17                	jne    8011e0 <dev_lookup+0x31>
  8011c9:	eb 07                	jmp    8011d2 <dev_lookup+0x23>
  8011cb:	39 0a                	cmp    %ecx,(%edx)
  8011cd:	75 11                	jne    8011e0 <dev_lookup+0x31>
  8011cf:	90                   	nop
  8011d0:	eb 05                	jmp    8011d7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d2:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011d7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011de:	eb 35                	jmp    801215 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e0:	83 c0 01             	add    $0x1,%eax
  8011e3:	8b 14 85 08 27 80 00 	mov    0x802708(,%eax,4),%edx
  8011ea:	85 d2                	test   %edx,%edx
  8011ec:	75 dd                	jne    8011cb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f3:	8b 40 48             	mov    0x48(%eax),%eax
  8011f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fe:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  801205:	e8 65 ef ff ff       	call   80016f <cprintf>
	*dev = 0;
  80120a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801215:	83 c4 14             	add    $0x14,%esp
  801218:	5b                   	pop    %ebx
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 38             	sub    $0x38,%esp
  801221:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801224:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801227:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80122a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801231:	89 3c 24             	mov    %edi,(%esp)
  801234:	e8 87 fe ff ff       	call   8010c0 <fd2num>
  801239:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80123c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801240:	89 04 24             	mov    %eax,(%esp)
  801243:	e8 16 ff ff ff       	call   80115e <fd_lookup>
  801248:	89 c3                	mov    %eax,%ebx
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 05                	js     801253 <fd_close+0x38>
	    || fd != fd2)
  80124e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801251:	74 0e                	je     801261 <fd_close+0x46>
		return (must_exist ? r : 0);
  801253:	89 f0                	mov    %esi,%eax
  801255:	84 c0                	test   %al,%al
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	0f 44 d8             	cmove  %eax,%ebx
  80125f:	eb 3d                	jmp    80129e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801261:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801264:	89 44 24 04          	mov    %eax,0x4(%esp)
  801268:	8b 07                	mov    (%edi),%eax
  80126a:	89 04 24             	mov    %eax,(%esp)
  80126d:	e8 3d ff ff ff       	call   8011af <dev_lookup>
  801272:	89 c3                	mov    %eax,%ebx
  801274:	85 c0                	test   %eax,%eax
  801276:	78 16                	js     80128e <fd_close+0x73>
		if (dev->dev_close)
  801278:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80127b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80127e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801283:	85 c0                	test   %eax,%eax
  801285:	74 07                	je     80128e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801287:	89 3c 24             	mov    %edi,(%esp)
  80128a:	ff d0                	call   *%eax
  80128c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80128e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801292:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801299:	e8 db fb ff ff       	call   800e79 <sys_page_unmap>
	return r;
}
  80129e:	89 d8                	mov    %ebx,%eax
  8012a0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012a3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012a6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012a9:	89 ec                	mov    %ebp,%esp
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	89 04 24             	mov    %eax,(%esp)
  8012c0:	e8 99 fe ff ff       	call   80115e <fd_lookup>
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 13                	js     8012dc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012d0:	00 
  8012d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d4:	89 04 24             	mov    %eax,(%esp)
  8012d7:	e8 3f ff ff ff       	call   80121b <fd_close>
}
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <close_all>:

void
close_all(void)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ea:	89 1c 24             	mov    %ebx,(%esp)
  8012ed:	e8 bb ff ff ff       	call   8012ad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f2:	83 c3 01             	add    $0x1,%ebx
  8012f5:	83 fb 20             	cmp    $0x20,%ebx
  8012f8:	75 f0                	jne    8012ea <close_all+0xc>
		close(i);
}
  8012fa:	83 c4 14             	add    $0x14,%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 58             	sub    $0x58,%esp
  801306:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801309:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80130c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80130f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801312:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	89 04 24             	mov    %eax,(%esp)
  80131f:	e8 3a fe ff ff       	call   80115e <fd_lookup>
  801324:	89 c3                	mov    %eax,%ebx
  801326:	85 c0                	test   %eax,%eax
  801328:	0f 88 e1 00 00 00    	js     80140f <dup+0x10f>
		return r;
	close(newfdnum);
  80132e:	89 3c 24             	mov    %edi,(%esp)
  801331:	e8 77 ff ff ff       	call   8012ad <close>

	newfd = INDEX2FD(newfdnum);
  801336:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80133c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80133f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	e8 86 fd ff ff       	call   8010d0 <fd2data>
  80134a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80134c:	89 34 24             	mov    %esi,(%esp)
  80134f:	e8 7c fd ff ff       	call   8010d0 <fd2data>
  801354:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801357:	89 d8                	mov    %ebx,%eax
  801359:	c1 e8 16             	shr    $0x16,%eax
  80135c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801363:	a8 01                	test   $0x1,%al
  801365:	74 46                	je     8013ad <dup+0xad>
  801367:	89 d8                	mov    %ebx,%eax
  801369:	c1 e8 0c             	shr    $0xc,%eax
  80136c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801373:	f6 c2 01             	test   $0x1,%dl
  801376:	74 35                	je     8013ad <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801378:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137f:	25 07 0e 00 00       	and    $0xe07,%eax
  801384:	89 44 24 10          	mov    %eax,0x10(%esp)
  801388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80138b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801396:	00 
  801397:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80139b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a2:	e8 74 fa ff ff       	call   800e1b <sys_page_map>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 3b                	js     8013e8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	c1 ea 0c             	shr    $0xc,%edx
  8013b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013d1:	00 
  8013d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013dd:	e8 39 fa ff ff       	call   800e1b <sys_page_map>
  8013e2:	89 c3                	mov    %eax,%ebx
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	79 25                	jns    80140d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f3:	e8 81 fa ff ff       	call   800e79 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801406:	e8 6e fa ff ff       	call   800e79 <sys_page_unmap>
	return r;
  80140b:	eb 02                	jmp    80140f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80140d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801414:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801417:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80141a:	89 ec                	mov    %ebp,%esp
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 24             	sub    $0x24,%esp
  801425:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801428:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142f:	89 1c 24             	mov    %ebx,(%esp)
  801432:	e8 27 fd ff ff       	call   80115e <fd_lookup>
  801437:	85 c0                	test   %eax,%eax
  801439:	78 6d                	js     8014a8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	8b 00                	mov    (%eax),%eax
  801447:	89 04 24             	mov    %eax,(%esp)
  80144a:	e8 60 fd ff ff       	call   8011af <dev_lookup>
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 55                	js     8014a8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801456:	8b 50 08             	mov    0x8(%eax),%edx
  801459:	83 e2 03             	and    $0x3,%edx
  80145c:	83 fa 01             	cmp    $0x1,%edx
  80145f:	75 23                	jne    801484 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801461:	a1 04 40 80 00       	mov    0x804004,%eax
  801466:	8b 40 48             	mov    0x48(%eax),%eax
  801469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	c7 04 24 cd 26 80 00 	movl   $0x8026cd,(%esp)
  801478:	e8 f2 ec ff ff       	call   80016f <cprintf>
		return -E_INVAL;
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801482:	eb 24                	jmp    8014a8 <read+0x8a>
	}
	if (!dev->dev_read)
  801484:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801487:	8b 52 08             	mov    0x8(%edx),%edx
  80148a:	85 d2                	test   %edx,%edx
  80148c:	74 15                	je     8014a3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80148e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801491:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801495:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801498:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80149c:	89 04 24             	mov    %eax,(%esp)
  80149f:	ff d2                	call   *%edx
  8014a1:	eb 05                	jmp    8014a8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8014a8:	83 c4 24             	add    $0x24,%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	57                   	push   %edi
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 1c             	sub    $0x1c,%esp
  8014b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c2:	85 f6                	test   %esi,%esi
  8014c4:	74 30                	je     8014f6 <readn+0x48>
  8014c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014cb:	89 f2                	mov    %esi,%edx
  8014cd:	29 c2                	sub    %eax,%edx
  8014cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014d3:	03 45 0c             	add    0xc(%ebp),%eax
  8014d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014da:	89 3c 24             	mov    %edi,(%esp)
  8014dd:	e8 3c ff ff ff       	call   80141e <read>
		if (m < 0)
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 10                	js     8014f6 <readn+0x48>
			return m;
		if (m == 0)
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	74 0a                	je     8014f4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ea:	01 c3                	add    %eax,%ebx
  8014ec:	89 d8                	mov    %ebx,%eax
  8014ee:	39 f3                	cmp    %esi,%ebx
  8014f0:	72 d9                	jb     8014cb <readn+0x1d>
  8014f2:	eb 02                	jmp    8014f6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014f4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014f6:	83 c4 1c             	add    $0x1c,%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 24             	sub    $0x24,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801508:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	e8 47 fc ff ff       	call   80115e <fd_lookup>
  801517:	85 c0                	test   %eax,%eax
  801519:	78 68                	js     801583 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	8b 00                	mov    (%eax),%eax
  801527:	89 04 24             	mov    %eax,(%esp)
  80152a:	e8 80 fc ff ff       	call   8011af <dev_lookup>
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 50                	js     801583 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153a:	75 23                	jne    80155f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153c:	a1 04 40 80 00       	mov    0x804004,%eax
  801541:	8b 40 48             	mov    0x48(%eax),%eax
  801544:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154c:	c7 04 24 e9 26 80 00 	movl   $0x8026e9,(%esp)
  801553:	e8 17 ec ff ff       	call   80016f <cprintf>
		return -E_INVAL;
  801558:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155d:	eb 24                	jmp    801583 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80155f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801562:	8b 52 0c             	mov    0xc(%edx),%edx
  801565:	85 d2                	test   %edx,%edx
  801567:	74 15                	je     80157e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801569:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80156c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801570:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801573:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	ff d2                	call   *%edx
  80157c:	eb 05                	jmp    801583 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80157e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801583:	83 c4 24             	add    $0x24,%esp
  801586:	5b                   	pop    %ebx
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    

00801589 <seek>:

int
seek(int fdnum, off_t offset)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801592:	89 44 24 04          	mov    %eax,0x4(%esp)
  801596:	8b 45 08             	mov    0x8(%ebp),%eax
  801599:	89 04 24             	mov    %eax,(%esp)
  80159c:	e8 bd fb ff ff       	call   80115e <fd_lookup>
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 0e                	js     8015b3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 24             	sub    $0x24,%esp
  8015bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c6:	89 1c 24             	mov    %ebx,(%esp)
  8015c9:	e8 90 fb ff ff       	call   80115e <fd_lookup>
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 61                	js     801633 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	8b 00                	mov    (%eax),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 c9 fb ff ff       	call   8011af <dev_lookup>
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 49                	js     801633 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f1:	75 23                	jne    801616 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015f8:	8b 40 48             	mov    0x48(%eax),%eax
  8015fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  80160a:	e8 60 eb ff ff       	call   80016f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801614:	eb 1d                	jmp    801633 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801619:	8b 52 18             	mov    0x18(%edx),%edx
  80161c:	85 d2                	test   %edx,%edx
  80161e:	74 0e                	je     80162e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801620:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801623:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801627:	89 04 24             	mov    %eax,(%esp)
  80162a:	ff d2                	call   *%edx
  80162c:	eb 05                	jmp    801633 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80162e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801633:	83 c4 24             	add    $0x24,%esp
  801636:	5b                   	pop    %ebx
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	53                   	push   %ebx
  80163d:	83 ec 24             	sub    $0x24,%esp
  801640:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801643:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	89 04 24             	mov    %eax,(%esp)
  801650:	e8 09 fb ff ff       	call   80115e <fd_lookup>
  801655:	85 c0                	test   %eax,%eax
  801657:	78 52                	js     8016ab <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	8b 00                	mov    (%eax),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	e8 42 fb ff ff       	call   8011af <dev_lookup>
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 3a                	js     8016ab <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801678:	74 2c                	je     8016a6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80167d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801684:	00 00 00 
	stat->st_isdir = 0;
  801687:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80168e:	00 00 00 
	stat->st_dev = dev;
  801691:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80169e:	89 14 24             	mov    %edx,(%esp)
  8016a1:	ff 50 14             	call   *0x14(%eax)
  8016a4:	eb 05                	jmp    8016ab <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ab:	83 c4 24             	add    $0x24,%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	83 ec 18             	sub    $0x18,%esp
  8016b7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016ba:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016c4:	00 
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	89 04 24             	mov    %eax,(%esp)
  8016cb:	e8 bc 01 00 00       	call   80188c <open>
  8016d0:	89 c3                	mov    %eax,%ebx
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 1b                	js     8016f1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dd:	89 1c 24             	mov    %ebx,(%esp)
  8016e0:	e8 54 ff ff ff       	call   801639 <fstat>
  8016e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 be fb ff ff       	call   8012ad <close>
	return r;
  8016ef:	89 f3                	mov    %esi,%ebx
}
  8016f1:	89 d8                	mov    %ebx,%eax
  8016f3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016f6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016f9:	89 ec                	mov    %ebp,%esp
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    
  8016fd:	00 00                	add    %al,(%eax)
	...

00801700 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	83 ec 18             	sub    $0x18,%esp
  801706:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801709:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801710:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801717:	75 11                	jne    80172a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801719:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801720:	e8 b4 08 00 00       	call   801fd9 <ipc_find_env>
  801725:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80172a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801731:	00 
  801732:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801739:	00 
  80173a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173e:	a1 00 40 80 00       	mov    0x804000,%eax
  801743:	89 04 24             	mov    %eax,(%esp)
  801746:	e8 23 08 00 00       	call   801f6e <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80174b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801752:	00 
  801753:	89 74 24 04          	mov    %esi,0x4(%esp)
  801757:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175e:	e8 a5 07 00 00       	call   801f08 <ipc_recv>
}
  801763:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801766:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801769:	89 ec                	mov    %ebp,%esp
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	53                   	push   %ebx
  801771:	83 ec 14             	sub    $0x14,%esp
  801774:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 40 0c             	mov    0xc(%eax),%eax
  80177d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 05 00 00 00       	mov    $0x5,%eax
  80178c:	e8 6f ff ff ff       	call   801700 <fsipc>
  801791:	85 c0                	test   %eax,%eax
  801793:	78 2b                	js     8017c0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801795:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80179c:	00 
  80179d:	89 1c 24             	mov    %ebx,(%esp)
  8017a0:	e8 16 f1 ff ff       	call   8008bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8017aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8017b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c0:	83 c4 14             	add    $0x14,%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e1:	e8 1a ff ff ff       	call   801700 <fsipc>
}
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 10             	sub    $0x10,%esp
  8017f0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801804:	ba 00 00 00 00       	mov    $0x0,%edx
  801809:	b8 03 00 00 00       	mov    $0x3,%eax
  80180e:	e8 ed fe ff ff       	call   801700 <fsipc>
  801813:	89 c3                	mov    %eax,%ebx
  801815:	85 c0                	test   %eax,%eax
  801817:	78 6a                	js     801883 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801819:	39 c6                	cmp    %eax,%esi
  80181b:	73 24                	jae    801841 <devfile_read+0x59>
  80181d:	c7 44 24 0c 18 27 80 	movl   $0x802718,0xc(%esp)
  801824:	00 
  801825:	c7 44 24 08 1f 27 80 	movl   $0x80271f,0x8(%esp)
  80182c:	00 
  80182d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801834:	00 
  801835:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  80183c:	e8 6f 06 00 00       	call   801eb0 <_panic>
	assert(r <= PGSIZE);
  801841:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801846:	7e 24                	jle    80186c <devfile_read+0x84>
  801848:	c7 44 24 0c 3f 27 80 	movl   $0x80273f,0xc(%esp)
  80184f:	00 
  801850:	c7 44 24 08 1f 27 80 	movl   $0x80271f,0x8(%esp)
  801857:	00 
  801858:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80185f:	00 
  801860:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  801867:	e8 44 06 00 00       	call   801eb0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80186c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801870:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801877:	00 
  801878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187b:	89 04 24             	mov    %eax,(%esp)
  80187e:	e8 29 f2 ff ff       	call   800aac <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801883:	89 d8                	mov    %ebx,%eax
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
  801891:	83 ec 20             	sub    $0x20,%esp
  801894:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801897:	89 34 24             	mov    %esi,(%esp)
  80189a:	e8 d1 ef ff ff       	call   800870 <strlen>
		return -E_BAD_PATH;
  80189f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a9:	7f 5e                	jg     801909 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ae:	89 04 24             	mov    %eax,(%esp)
  8018b1:	e8 35 f8 ff ff       	call   8010eb <fd_alloc>
  8018b6:	89 c3                	mov    %eax,%ebx
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 4d                	js     801909 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018c0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018c7:	e8 ef ef ff ff       	call   8008bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018dc:	e8 1f fe ff ff       	call   801700 <fsipc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	79 15                	jns    8018fc <open+0x70>
		fd_close(fd, 0);
  8018e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ee:	00 
  8018ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 21 f9 ff ff       	call   80121b <fd_close>
		return r;
  8018fa:	eb 0d                	jmp    801909 <open+0x7d>
	}

	return fd2num(fd);
  8018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	e8 b9 f7 ff ff       	call   8010c0 <fd2num>
  801907:	89 c3                	mov    %eax,%ebx
}
  801909:	89 d8                	mov    %ebx,%eax
  80190b:	83 c4 20             	add    $0x20,%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5e                   	pop    %esi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    
	...

00801920 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 18             	sub    $0x18,%esp
  801926:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801929:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80192c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	89 04 24             	mov    %eax,(%esp)
  801935:	e8 96 f7 ff ff       	call   8010d0 <fd2data>
  80193a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80193c:	c7 44 24 04 4b 27 80 	movl   $0x80274b,0x4(%esp)
  801943:	00 
  801944:	89 34 24             	mov    %esi,(%esp)
  801947:	e8 6f ef ff ff       	call   8008bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80194c:	8b 43 04             	mov    0x4(%ebx),%eax
  80194f:	2b 03                	sub    (%ebx),%eax
  801951:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801957:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80195e:	00 00 00 
	stat->st_dev = &devpipe;
  801961:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801968:	30 80 00 
	return 0;
}
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
  801970:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801973:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801976:	89 ec                	mov    %ebp,%esp
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	53                   	push   %ebx
  80197e:	83 ec 14             	sub    $0x14,%esp
  801981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801988:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198f:	e8 e5 f4 ff ff       	call   800e79 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801994:	89 1c 24             	mov    %ebx,(%esp)
  801997:	e8 34 f7 ff ff       	call   8010d0 <fd2data>
  80199c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a7:	e8 cd f4 ff ff       	call   800e79 <sys_page_unmap>
}
  8019ac:	83 c4 14             	add    $0x14,%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5d                   	pop    %ebp
  8019b1:	c3                   	ret    

008019b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	57                   	push   %edi
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
  8019b8:	83 ec 2c             	sub    $0x2c,%esp
  8019bb:	89 c7                	mov    %eax,%edi
  8019bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8019c5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019c8:	89 3c 24             	mov    %edi,(%esp)
  8019cb:	e8 54 06 00 00       	call   802024 <pageref>
  8019d0:	89 c6                	mov    %eax,%esi
  8019d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019d5:	89 04 24             	mov    %eax,(%esp)
  8019d8:	e8 47 06 00 00       	call   802024 <pageref>
  8019dd:	39 c6                	cmp    %eax,%esi
  8019df:	0f 94 c0             	sete   %al
  8019e2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019e5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019eb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ee:	39 cb                	cmp    %ecx,%ebx
  8019f0:	75 08                	jne    8019fa <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019f2:	83 c4 2c             	add    $0x2c,%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019fa:	83 f8 01             	cmp    $0x1,%eax
  8019fd:	75 c1                	jne    8019c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ff:	8b 52 58             	mov    0x58(%edx),%edx
  801a02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a06:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0e:	c7 04 24 52 27 80 00 	movl   $0x802752,(%esp)
  801a15:	e8 55 e7 ff ff       	call   80016f <cprintf>
  801a1a:	eb a4                	jmp    8019c0 <_pipeisclosed+0xe>

00801a1c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	57                   	push   %edi
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	83 ec 2c             	sub    $0x2c,%esp
  801a25:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a28:	89 34 24             	mov    %esi,(%esp)
  801a2b:	e8 a0 f6 ff ff       	call   8010d0 <fd2data>
  801a30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a32:	bf 00 00 00 00       	mov    $0x0,%edi
  801a37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a3b:	75 50                	jne    801a8d <devpipe_write+0x71>
  801a3d:	eb 5c                	jmp    801a9b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a3f:	89 da                	mov    %ebx,%edx
  801a41:	89 f0                	mov    %esi,%eax
  801a43:	e8 6a ff ff ff       	call   8019b2 <_pipeisclosed>
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	75 53                	jne    801a9f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a4c:	e8 3b f3 ff ff       	call   800d8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a51:	8b 43 04             	mov    0x4(%ebx),%eax
  801a54:	8b 13                	mov    (%ebx),%edx
  801a56:	83 c2 20             	add    $0x20,%edx
  801a59:	39 d0                	cmp    %edx,%eax
  801a5b:	73 e2                	jae    801a3f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a60:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801a64:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801a67:	89 c2                	mov    %eax,%edx
  801a69:	c1 fa 1f             	sar    $0x1f,%edx
  801a6c:	c1 ea 1b             	shr    $0x1b,%edx
  801a6f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801a72:	83 e1 1f             	and    $0x1f,%ecx
  801a75:	29 d1                	sub    %edx,%ecx
  801a77:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801a7b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801a7f:	83 c0 01             	add    $0x1,%eax
  801a82:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a85:	83 c7 01             	add    $0x1,%edi
  801a88:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a8b:	74 0e                	je     801a9b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8d:	8b 43 04             	mov    0x4(%ebx),%eax
  801a90:	8b 13                	mov    (%ebx),%edx
  801a92:	83 c2 20             	add    $0x20,%edx
  801a95:	39 d0                	cmp    %edx,%eax
  801a97:	73 a6                	jae    801a3f <devpipe_write+0x23>
  801a99:	eb c2                	jmp    801a5d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a9b:	89 f8                	mov    %edi,%eax
  801a9d:	eb 05                	jmp    801aa4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa4:	83 c4 2c             	add    $0x2c,%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5f                   	pop    %edi
  801aaa:	5d                   	pop    %ebp
  801aab:	c3                   	ret    

00801aac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	83 ec 28             	sub    $0x28,%esp
  801ab2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ab5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ab8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801abb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801abe:	89 3c 24             	mov    %edi,(%esp)
  801ac1:	e8 0a f6 ff ff       	call   8010d0 <fd2data>
  801ac6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac8:	be 00 00 00 00       	mov    $0x0,%esi
  801acd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad1:	75 47                	jne    801b1a <devpipe_read+0x6e>
  801ad3:	eb 52                	jmp    801b27 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ad5:	89 f0                	mov    %esi,%eax
  801ad7:	eb 5e                	jmp    801b37 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad9:	89 da                	mov    %ebx,%edx
  801adb:	89 f8                	mov    %edi,%eax
  801add:	8d 76 00             	lea    0x0(%esi),%esi
  801ae0:	e8 cd fe ff ff       	call   8019b2 <_pipeisclosed>
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	75 49                	jne    801b32 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801ae9:	e8 9e f2 ff ff       	call   800d8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aee:	8b 03                	mov    (%ebx),%eax
  801af0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801af3:	74 e4                	je     801ad9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	c1 fa 1f             	sar    $0x1f,%edx
  801afa:	c1 ea 1b             	shr    $0x1b,%edx
  801afd:	01 d0                	add    %edx,%eax
  801aff:	83 e0 1f             	and    $0x1f,%eax
  801b02:	29 d0                	sub    %edx,%eax
  801b04:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b09:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b0c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b0f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b12:	83 c6 01             	add    $0x1,%esi
  801b15:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b18:	74 0d                	je     801b27 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801b1a:	8b 03                	mov    (%ebx),%eax
  801b1c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b1f:	75 d4                	jne    801af5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b21:	85 f6                	test   %esi,%esi
  801b23:	75 b0                	jne    801ad5 <devpipe_read+0x29>
  801b25:	eb b2                	jmp    801ad9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b27:	89 f0                	mov    %esi,%eax
  801b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b30:	eb 05                	jmp    801b37 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b40:	89 ec                	mov    %ebp,%esp
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 48             	sub    $0x48,%esp
  801b4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b50:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b53:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b59:	89 04 24             	mov    %eax,(%esp)
  801b5c:	e8 8a f5 ff ff       	call   8010eb <fd_alloc>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	85 c0                	test   %eax,%eax
  801b65:	0f 88 45 01 00 00    	js     801cb0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b72:	00 
  801b73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b81:	e8 36 f2 ff ff       	call   800dbc <sys_page_alloc>
  801b86:	89 c3                	mov    %eax,%ebx
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 88 20 01 00 00    	js     801cb0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b90:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b93:	89 04 24             	mov    %eax,(%esp)
  801b96:	e8 50 f5 ff ff       	call   8010eb <fd_alloc>
  801b9b:	89 c3                	mov    %eax,%ebx
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	0f 88 f8 00 00 00    	js     801c9d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bac:	00 
  801bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbb:	e8 fc f1 ff ff       	call   800dbc <sys_page_alloc>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	0f 88 d3 00 00 00    	js     801c9d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bcd:	89 04 24             	mov    %eax,(%esp)
  801bd0:	e8 fb f4 ff ff       	call   8010d0 <fd2data>
  801bd5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bde:	00 
  801bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bea:	e8 cd f1 ff ff       	call   800dbc <sys_page_alloc>
  801bef:	89 c3                	mov    %eax,%ebx
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	0f 88 91 00 00 00    	js     801c8a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bfc:	89 04 24             	mov    %eax,(%esp)
  801bff:	e8 cc f4 ff ff       	call   8010d0 <fd2data>
  801c04:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c0b:	00 
  801c0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c17:	00 
  801c18:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c23:	e8 f3 f1 ff ff       	call   800e1b <sys_page_map>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 4c                	js     801c7a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c37:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c43:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c49:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c4c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c51:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5b:	89 04 24             	mov    %eax,(%esp)
  801c5e:	e8 5d f4 ff ff       	call   8010c0 <fd2num>
  801c63:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c68:	89 04 24             	mov    %eax,(%esp)
  801c6b:	e8 50 f4 ff ff       	call   8010c0 <fd2num>
  801c70:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c78:	eb 36                	jmp    801cb0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801c7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c85:	e8 ef f1 ff ff       	call   800e79 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c98:	e8 dc f1 ff ff       	call   800e79 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cab:	e8 c9 f1 ff ff       	call   800e79 <sys_page_unmap>
    err:
	return r;
}
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cbb:	89 ec                	mov    %ebp,%esp
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	89 04 24             	mov    %eax,(%esp)
  801cd2:	e8 87 f4 ff ff       	call   80115e <fd_lookup>
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	78 15                	js     801cf0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 ea f3 ff ff       	call   8010d0 <fd2data>
	return _pipeisclosed(fd, p);
  801ce6:	89 c2                	mov    %eax,%edx
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	e8 c2 fc ff ff       	call   8019b2 <_pipeisclosed>
}
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    
	...

00801d00 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
  801d08:	5d                   	pop    %ebp
  801d09:	c3                   	ret    

00801d0a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d10:	c7 44 24 04 6a 27 80 	movl   $0x80276a,0x4(%esp)
  801d17:	00 
  801d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1b:	89 04 24             	mov    %eax,(%esp)
  801d1e:	e8 98 eb ff ff       	call   8008bb <strcpy>
	return 0;
}
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	57                   	push   %edi
  801d2e:	56                   	push   %esi
  801d2f:	53                   	push   %ebx
  801d30:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d36:	be 00 00 00 00       	mov    $0x0,%esi
  801d3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d3f:	74 43                	je     801d84 <devcons_write+0x5a>
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d46:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d4f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d51:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d54:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d59:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d60:	03 45 0c             	add    0xc(%ebp),%eax
  801d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d67:	89 3c 24             	mov    %edi,(%esp)
  801d6a:	e8 3d ed ff ff       	call   800aac <memmove>
		sys_cputs(buf, m);
  801d6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d73:	89 3c 24             	mov    %edi,(%esp)
  801d76:	e8 25 ef ff ff       	call   800ca0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7b:	01 de                	add    %ebx,%esi
  801d7d:	89 f0                	mov    %esi,%eax
  801d7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d82:	72 c8                	jb     801d4c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d84:	89 f0                	mov    %esi,%eax
  801d86:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d8c:	5b                   	pop    %ebx
  801d8d:	5e                   	pop    %esi
  801d8e:	5f                   	pop    %edi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da0:	75 07                	jne    801da9 <devcons_read+0x18>
  801da2:	eb 31                	jmp    801dd5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801da4:	e8 e3 ef ff ff       	call   800d8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	e8 1a ef ff ff       	call   800ccf <sys_cgetc>
  801db5:	85 c0                	test   %eax,%eax
  801db7:	74 eb                	je     801da4 <devcons_read+0x13>
  801db9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	78 16                	js     801dd5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbf:	83 f8 04             	cmp    $0x4,%eax
  801dc2:	74 0c                	je     801dd0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	88 10                	mov    %dl,(%eax)
	return 1;
  801dc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dce:	eb 05                	jmp    801dd5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801dea:	00 
  801deb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dee:	89 04 24             	mov    %eax,(%esp)
  801df1:	e8 aa ee ff ff       	call   800ca0 <sys_cputs>
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <getchar>:

int
getchar(void)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dfe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e05:	00 
  801e06:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e14:	e8 05 f6 ff ff       	call   80141e <read>
	if (r < 0)
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	78 0f                	js     801e2c <getchar+0x34>
		return r;
	if (r < 1)
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	7e 06                	jle    801e27 <getchar+0x2f>
		return -E_EOF;
	return c;
  801e21:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e25:	eb 05                	jmp    801e2c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e27:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	89 04 24             	mov    %eax,(%esp)
  801e41:	e8 18 f3 ff ff       	call   80115e <fd_lookup>
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 11                	js     801e5b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e53:	39 10                	cmp    %edx,(%eax)
  801e55:	0f 94 c0             	sete   %al
  801e58:	0f b6 c0             	movzbl %al,%eax
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <opencons>:

int
opencons(void)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e66:	89 04 24             	mov    %eax,(%esp)
  801e69:	e8 7d f2 ff ff       	call   8010eb <fd_alloc>
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 3c                	js     801eae <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e72:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e79:	00 
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e88:	e8 2f ef ff ff       	call   800dbc <sys_page_alloc>
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 1d                	js     801eae <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e91:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ea6:	89 04 24             	mov    %eax,(%esp)
  801ea9:	e8 12 f2 ff ff       	call   8010c0 <fd2num>
}
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    

00801eb0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801eb8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ebb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ec1:	e8 96 ee ff ff       	call   800d5c <sys_getenvid>
  801ec6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  801ed0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ed4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ed8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edc:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  801ee3:	e8 87 e2 ff ff       	call   80016f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ee8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eec:	8b 45 10             	mov    0x10(%ebp),%eax
  801eef:	89 04 24             	mov    %eax,(%esp)
  801ef2:	e8 17 e2 ff ff       	call   80010e <vcprintf>
	cprintf("\n");
  801ef7:	c7 04 24 63 27 80 00 	movl   $0x802763,(%esp)
  801efe:	e8 6c e2 ff ff       	call   80016f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f03:	cc                   	int3   
  801f04:	eb fd                	jmp    801f03 <_panic+0x53>
	...

00801f08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 10             	sub    $0x10,%esp
  801f10:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f16:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f19:	85 db                	test   %ebx,%ebx
  801f1b:	74 06                	je     801f23 <ipc_recv+0x1b>
  801f1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801f23:	85 f6                	test   %esi,%esi
  801f25:	74 06                	je     801f2d <ipc_recv+0x25>
  801f27:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f34:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f37:	89 04 24             	mov    %eax,(%esp)
  801f3a:	e8 e6 f0 ff ff       	call   801025 <sys_ipc_recv>
    if (ret) return ret;
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	75 24                	jne    801f67 <ipc_recv+0x5f>
    if (from_env_store)
  801f43:	85 db                	test   %ebx,%ebx
  801f45:	74 0a                	je     801f51 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f47:	a1 04 40 80 00       	mov    0x804004,%eax
  801f4c:	8b 40 74             	mov    0x74(%eax),%eax
  801f4f:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f51:	85 f6                	test   %esi,%esi
  801f53:	74 0a                	je     801f5f <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f55:	a1 04 40 80 00       	mov    0x804004,%eax
  801f5a:	8b 40 78             	mov    0x78(%eax),%eax
  801f5d:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f64:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5d                   	pop    %ebp
  801f6d:	c3                   	ret    

00801f6e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 75 08             	mov    0x8(%ebp),%esi
  801f7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801f80:	85 db                	test   %ebx,%ebx
  801f82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f87:	0f 44 d8             	cmove  %eax,%ebx
  801f8a:	eb 2a                	jmp    801fb6 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801f8c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f8f:	74 20                	je     801fb1 <ipc_send+0x43>
  801f91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f95:	c7 44 24 08 9c 27 80 	movl   $0x80279c,0x8(%esp)
  801f9c:	00 
  801f9d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801fa4:	00 
  801fa5:	c7 04 24 b3 27 80 00 	movl   $0x8027b3,(%esp)
  801fac:	e8 ff fe ff ff       	call   801eb0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801fb1:	e8 d6 ed ff ff       	call   800d8c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fb6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fc1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fc5:	89 34 24             	mov    %esi,(%esp)
  801fc8:	e8 24 f0 ff ff       	call   800ff1 <sys_ipc_try_send>
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	75 bb                	jne    801f8c <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801fd1:	83 c4 1c             	add    $0x1c,%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fdf:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801fe4:	39 c8                	cmp    %ecx,%eax
  801fe6:	74 19                	je     802001 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fed:	89 c2                	mov    %eax,%edx
  801fef:	c1 e2 07             	shl    $0x7,%edx
  801ff2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff8:	8b 52 50             	mov    0x50(%edx),%edx
  801ffb:	39 ca                	cmp    %ecx,%edx
  801ffd:	75 14                	jne    802013 <ipc_find_env+0x3a>
  801fff:	eb 05                	jmp    802006 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802001:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802006:	c1 e0 07             	shl    $0x7,%eax
  802009:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80200e:	8b 40 40             	mov    0x40(%eax),%eax
  802011:	eb 0e                	jmp    802021 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802013:	83 c0 01             	add    $0x1,%eax
  802016:	3d 00 04 00 00       	cmp    $0x400,%eax
  80201b:	75 d0                	jne    801fed <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80201d:	66 b8 00 00          	mov    $0x0,%ax
}
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    
	...

00802024 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202a:	89 d0                	mov    %edx,%eax
  80202c:	c1 e8 16             	shr    $0x16,%eax
  80202f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802036:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203b:	f6 c1 01             	test   $0x1,%cl
  80203e:	74 1d                	je     80205d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802040:	c1 ea 0c             	shr    $0xc,%edx
  802043:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204a:	f6 c2 01             	test   $0x1,%dl
  80204d:	74 0e                	je     80205d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80204f:	c1 ea 0c             	shr    $0xc,%edx
  802052:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802059:	ef 
  80205a:	0f b7 c0             	movzwl %ax,%eax
}
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    
	...

00802060 <__udivdi3>:
  802060:	83 ec 1c             	sub    $0x1c,%esp
  802063:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802067:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80206b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80206f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802073:	89 74 24 10          	mov    %esi,0x10(%esp)
  802077:	8b 74 24 24          	mov    0x24(%esp),%esi
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802081:	89 44 24 08          	mov    %eax,0x8(%esp)
  802085:	89 cd                	mov    %ecx,%ebp
  802087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208b:	75 33                	jne    8020c0 <__udivdi3+0x60>
  80208d:	39 f1                	cmp    %esi,%ecx
  80208f:	77 57                	ja     8020e8 <__udivdi3+0x88>
  802091:	85 c9                	test   %ecx,%ecx
  802093:	75 0b                	jne    8020a0 <__udivdi3+0x40>
  802095:	b8 01 00 00 00       	mov    $0x1,%eax
  80209a:	31 d2                	xor    %edx,%edx
  80209c:	f7 f1                	div    %ecx
  80209e:	89 c1                	mov    %eax,%ecx
  8020a0:	89 f0                	mov    %esi,%eax
  8020a2:	31 d2                	xor    %edx,%edx
  8020a4:	f7 f1                	div    %ecx
  8020a6:	89 c6                	mov    %eax,%esi
  8020a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020ac:	f7 f1                	div    %ecx
  8020ae:	89 f2                	mov    %esi,%edx
  8020b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	c3                   	ret    
  8020c0:	31 d2                	xor    %edx,%edx
  8020c2:	31 c0                	xor    %eax,%eax
  8020c4:	39 f7                	cmp    %esi,%edi
  8020c6:	77 e8                	ja     8020b0 <__udivdi3+0x50>
  8020c8:	0f bd cf             	bsr    %edi,%ecx
  8020cb:	83 f1 1f             	xor    $0x1f,%ecx
  8020ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020d2:	75 2c                	jne    802100 <__udivdi3+0xa0>
  8020d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8020d8:	76 04                	jbe    8020de <__udivdi3+0x7e>
  8020da:	39 f7                	cmp    %esi,%edi
  8020dc:	73 d2                	jae    8020b0 <__udivdi3+0x50>
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e5:	eb c9                	jmp    8020b0 <__udivdi3+0x50>
  8020e7:	90                   	nop
  8020e8:	89 f2                	mov    %esi,%edx
  8020ea:	f7 f1                	div    %ecx
  8020ec:	31 d2                	xor    %edx,%edx
  8020ee:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	c3                   	ret    
  8020fe:	66 90                	xchg   %ax,%ax
  802100:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802105:	b8 20 00 00 00       	mov    $0x20,%eax
  80210a:	89 ea                	mov    %ebp,%edx
  80210c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802110:	d3 e7                	shl    %cl,%edi
  802112:	89 c1                	mov    %eax,%ecx
  802114:	d3 ea                	shr    %cl,%edx
  802116:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80211b:	09 fa                	or     %edi,%edx
  80211d:	89 f7                	mov    %esi,%edi
  80211f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802123:	89 f2                	mov    %esi,%edx
  802125:	8b 74 24 08          	mov    0x8(%esp),%esi
  802129:	d3 e5                	shl    %cl,%ebp
  80212b:	89 c1                	mov    %eax,%ecx
  80212d:	d3 ef                	shr    %cl,%edi
  80212f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802134:	d3 e2                	shl    %cl,%edx
  802136:	89 c1                	mov    %eax,%ecx
  802138:	d3 ee                	shr    %cl,%esi
  80213a:	09 d6                	or     %edx,%esi
  80213c:	89 fa                	mov    %edi,%edx
  80213e:	89 f0                	mov    %esi,%eax
  802140:	f7 74 24 0c          	divl   0xc(%esp)
  802144:	89 d7                	mov    %edx,%edi
  802146:	89 c6                	mov    %eax,%esi
  802148:	f7 e5                	mul    %ebp
  80214a:	39 d7                	cmp    %edx,%edi
  80214c:	72 22                	jb     802170 <__udivdi3+0x110>
  80214e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802152:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802157:	d3 e5                	shl    %cl,%ebp
  802159:	39 c5                	cmp    %eax,%ebp
  80215b:	73 04                	jae    802161 <__udivdi3+0x101>
  80215d:	39 d7                	cmp    %edx,%edi
  80215f:	74 0f                	je     802170 <__udivdi3+0x110>
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	e9 46 ff ff ff       	jmp    8020b0 <__udivdi3+0x50>
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	8d 46 ff             	lea    -0x1(%esi),%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	8b 74 24 10          	mov    0x10(%esp),%esi
  802179:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80217d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	c3                   	ret    
	...

00802190 <__umoddi3>:
  802190:	83 ec 1c             	sub    $0x1c,%esp
  802193:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802197:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80219b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80219f:	89 74 24 10          	mov    %esi,0x10(%esp)
  8021a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021ab:	85 ed                	test   %ebp,%ebp
  8021ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021b5:	89 cf                	mov    %ecx,%edi
  8021b7:	89 04 24             	mov    %eax,(%esp)
  8021ba:	89 f2                	mov    %esi,%edx
  8021bc:	75 1a                	jne    8021d8 <__umoddi3+0x48>
  8021be:	39 f1                	cmp    %esi,%ecx
  8021c0:	76 4e                	jbe    802210 <__umoddi3+0x80>
  8021c2:	f7 f1                	div    %ecx
  8021c4:	89 d0                	mov    %edx,%eax
  8021c6:	31 d2                	xor    %edx,%edx
  8021c8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	c3                   	ret    
  8021d8:	39 f5                	cmp    %esi,%ebp
  8021da:	77 54                	ja     802230 <__umoddi3+0xa0>
  8021dc:	0f bd c5             	bsr    %ebp,%eax
  8021df:	83 f0 1f             	xor    $0x1f,%eax
  8021e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e6:	75 60                	jne    802248 <__umoddi3+0xb8>
  8021e8:	3b 0c 24             	cmp    (%esp),%ecx
  8021eb:	0f 87 07 01 00 00    	ja     8022f8 <__umoddi3+0x168>
  8021f1:	89 f2                	mov    %esi,%edx
  8021f3:	8b 34 24             	mov    (%esp),%esi
  8021f6:	29 ce                	sub    %ecx,%esi
  8021f8:	19 ea                	sbb    %ebp,%edx
  8021fa:	89 34 24             	mov    %esi,(%esp)
  8021fd:	8b 04 24             	mov    (%esp),%eax
  802200:	8b 74 24 10          	mov    0x10(%esp),%esi
  802204:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802208:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	c3                   	ret    
  802210:	85 c9                	test   %ecx,%ecx
  802212:	75 0b                	jne    80221f <__umoddi3+0x8f>
  802214:	b8 01 00 00 00       	mov    $0x1,%eax
  802219:	31 d2                	xor    %edx,%edx
  80221b:	f7 f1                	div    %ecx
  80221d:	89 c1                	mov    %eax,%ecx
  80221f:	89 f0                	mov    %esi,%eax
  802221:	31 d2                	xor    %edx,%edx
  802223:	f7 f1                	div    %ecx
  802225:	8b 04 24             	mov    (%esp),%eax
  802228:	f7 f1                	div    %ecx
  80222a:	eb 98                	jmp    8021c4 <__umoddi3+0x34>
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f2                	mov    %esi,%edx
  802232:	8b 74 24 10          	mov    0x10(%esp),%esi
  802236:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80223a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80223e:	83 c4 1c             	add    $0x1c,%esp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80224d:	89 e8                	mov    %ebp,%eax
  80224f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802254:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802258:	89 fa                	mov    %edi,%edx
  80225a:	d3 e0                	shl    %cl,%eax
  80225c:	89 e9                	mov    %ebp,%ecx
  80225e:	d3 ea                	shr    %cl,%edx
  802260:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802265:	09 c2                	or     %eax,%edx
  802267:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226b:	89 14 24             	mov    %edx,(%esp)
  80226e:	89 f2                	mov    %esi,%edx
  802270:	d3 e7                	shl    %cl,%edi
  802272:	89 e9                	mov    %ebp,%ecx
  802274:	d3 ea                	shr    %cl,%edx
  802276:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80227b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80227f:	d3 e6                	shl    %cl,%esi
  802281:	89 e9                	mov    %ebp,%ecx
  802283:	d3 e8                	shr    %cl,%eax
  802285:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80228a:	09 f0                	or     %esi,%eax
  80228c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802290:	f7 34 24             	divl   (%esp)
  802293:	d3 e6                	shl    %cl,%esi
  802295:	89 74 24 08          	mov    %esi,0x8(%esp)
  802299:	89 d6                	mov    %edx,%esi
  80229b:	f7 e7                	mul    %edi
  80229d:	39 d6                	cmp    %edx,%esi
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	89 d7                	mov    %edx,%edi
  8022a3:	72 3f                	jb     8022e4 <__umoddi3+0x154>
  8022a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022a9:	72 35                	jb     8022e0 <__umoddi3+0x150>
  8022ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022af:	29 c8                	sub    %ecx,%eax
  8022b1:	19 fe                	sbb    %edi,%esi
  8022b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022b8:	89 f2                	mov    %esi,%edx
  8022ba:	d3 e8                	shr    %cl,%eax
  8022bc:	89 e9                	mov    %ebp,%ecx
  8022be:	d3 e2                	shl    %cl,%edx
  8022c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022c5:	09 d0                	or     %edx,%eax
  8022c7:	89 f2                	mov    %esi,%edx
  8022c9:	d3 ea                	shr    %cl,%edx
  8022cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022d7:	83 c4 1c             	add    $0x1c,%esp
  8022da:	c3                   	ret    
  8022db:	90                   	nop
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 d6                	cmp    %edx,%esi
  8022e2:	75 c7                	jne    8022ab <__umoddi3+0x11b>
  8022e4:	89 d7                	mov    %edx,%edi
  8022e6:	89 c1                	mov    %eax,%ecx
  8022e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8022ec:	1b 3c 24             	sbb    (%esp),%edi
  8022ef:	eb ba                	jmp    8022ab <__umoddi3+0x11b>
  8022f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 f5                	cmp    %esi,%ebp
  8022fa:	0f 82 f1 fe ff ff    	jb     8021f1 <__umoddi3+0x61>
  802300:	e9 f8 fe ff ff       	jmp    8021fd <__umoddi3+0x6d>
