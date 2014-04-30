
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  800060:	e8 0a 01 00 00       	call   80016f <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 75 08             	mov    0x8(%ebp),%esi
  800077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80007a:	e8 dd 0c 00 00       	call   800d5c <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	c1 e0 07             	shl    $0x7,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 f6                	test   %esi,%esi
  800093:	7e 07                	jle    80009c <libmain+0x34>
		binaryname = argv[0];
  800095:	8b 03                	mov    (%ebx),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a0:	89 34 24             	mov    %esi,(%esp)
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 35 0c 00 00       	call   800cff <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

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
  8001f6:	e8 b5 0e 00 00       	call   8010b0 <__udivdi3>
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
  800249:	e8 92 0f 00 00       	call   8011e0 <__umoddi3>
  80024e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800252:	0f be 80 78 13 80 00 	movsbl 0x801378(%eax),%eax
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
  80037a:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
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
  80044e:	a3 04 20 80 00       	mov    %eax,0x802004
  800453:	e9 b1 fe ff ff       	jmp    800309 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800458:	c7 44 24 04 90 13 80 	movl   $0x801390,0x4(%esp)
  80045f:	00 
  800460:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	e8 10 05 00 00       	call   80097b <strcmp>
  80046b:	85 c0                	test   %eax,%eax
  80046d:	75 0f                	jne    80047e <vprintfmt+0x198>
  80046f:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800476:	00 00 00 
  800479:	e9 8b fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80047e:	c7 44 24 04 94 13 80 	movl   $0x801394,0x4(%esp)
  800485:	00 
  800486:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800489:	89 14 24             	mov    %edx,(%esp)
  80048c:	e8 ea 04 00 00       	call   80097b <strcmp>
  800491:	85 c0                	test   %eax,%eax
  800493:	75 0f                	jne    8004a4 <vprintfmt+0x1be>
  800495:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  80049c:	00 00 00 
  80049f:	e9 65 fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004a4:	c7 44 24 04 98 13 80 	movl   $0x801398,0x4(%esp)
  8004ab:	00 
  8004ac:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004af:	89 0c 24             	mov    %ecx,(%esp)
  8004b2:	e8 c4 04 00 00       	call   80097b <strcmp>
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	75 0f                	jne    8004ca <vprintfmt+0x1e4>
  8004bb:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004c2:	00 00 00 
  8004c5:	e9 3f fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004ca:	c7 44 24 04 9c 13 80 	movl   $0x80139c,0x4(%esp)
  8004d1:	00 
  8004d2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004d5:	89 3c 24             	mov    %edi,(%esp)
  8004d8:	e8 9e 04 00 00       	call   80097b <strcmp>
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	75 0f                	jne    8004f0 <vprintfmt+0x20a>
  8004e1:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004e8:	00 00 00 
  8004eb:	e9 19 fe ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004f0:	c7 44 24 04 a0 13 80 	movl   $0x8013a0,0x4(%esp)
  8004f7:	00 
  8004f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	e8 78 04 00 00       	call   80097b <strcmp>
  800503:	85 c0                	test   %eax,%eax
  800505:	75 0f                	jne    800516 <vprintfmt+0x230>
  800507:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80050e:	00 00 00 
  800511:	e9 f3 fd ff ff       	jmp    800309 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800516:	c7 44 24 04 a4 13 80 	movl   $0x8013a4,0x4(%esp)
  80051d:	00 
  80051e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800521:	89 14 24             	mov    %edx,(%esp)
  800524:	e8 52 04 00 00       	call   80097b <strcmp>
  800529:	83 f8 01             	cmp    $0x1,%eax
  80052c:	19 c0                	sbb    %eax,%eax
  80052e:	f7 d0                	not    %eax
  800530:	83 c0 08             	add    $0x8,%eax
  800533:	a3 04 20 80 00       	mov    %eax,0x802004
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
  800551:	83 f8 08             	cmp    $0x8,%eax
  800554:	7f 0b                	jg     800561 <vprintfmt+0x27b>
  800556:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  80055d:	85 d2                	test   %edx,%edx
  80055f:	75 23                	jne    800584 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800561:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800565:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
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
  800588:	c7 44 24 08 b1 13 80 	movl   $0x8013b1,0x8(%esp)
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
  8005bd:	b8 89 13 80 00       	mov    $0x801389,%eax
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
  800d33:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800d4a:	e8 09 03 00 00       	call   801058 <_panic>

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
  800da0:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800df2:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800e09:	e8 4a 02 00 00       	call   801058 <_panic>

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
  800e50:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800e67:	e8 ec 01 00 00       	call   801058 <_panic>

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
  800eae:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800ec5:	e8 8e 01 00 00       	call   801058 <_panic>

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
  800f0c:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800f13:	00 
  800f14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1b:	00 
  800f1c:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800f23:	e8 30 01 00 00       	call   801058 <_panic>

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

00800f35 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800f5c:	7e 28                	jle    800f86 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f62:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f69:	00 
  800f6a:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800f71:	00 
  800f72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f79:	00 
  800f7a:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800f81:	e8 d2 00 00 00       	call   801058 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8f:	89 ec                	mov    %ebp,%esp
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	be 00 00 00 00       	mov    $0x0,%esi
  800fa7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fac:	8b 7d 14             	mov    0x14(%ebp),%edi
  800faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc3:	89 ec                	mov    %ebp,%esp
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 38             	sub    $0x38,%esp
  800fcd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 cb                	mov    %ecx,%ebx
  800fe5:	89 cf                	mov    %ecx,%edi
  800fe7:	89 ce                	mov    %ecx,%esi
  800fe9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	7e 28                	jle    801017 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  801002:	00 
  801003:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  801012:	e8 41 00 00 00       	call   801058 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801017:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801020:	89 ec                	mov    %ebp,%esp
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801030:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	b9 00 00 00 00       	mov    $0x0,%ecx
  801038:	b8 0d 00 00 00       	mov    $0xd,%eax
  80103d:	8b 55 08             	mov    0x8(%ebp),%edx
  801040:	89 cb                	mov    %ecx,%ebx
  801042:	89 cf                	mov    %ecx,%edi
  801044:	89 ce                	mov    %ecx,%esi
  801046:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  801048:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801051:	89 ec                	mov    %ebp,%esp
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	00 00                	add    %al,(%eax)
	...

00801058 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801060:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801063:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801069:	e8 ee fc ff ff       	call   800d5c <sys_getenvid>
  80106e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801071:	89 54 24 10          	mov    %edx,0x10(%esp)
  801075:	8b 55 08             	mov    0x8(%ebp),%edx
  801078:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80107c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  80108b:	e8 df f0 ff ff       	call   80016f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801090:	89 74 24 04          	mov    %esi,0x4(%esp)
  801094:	8b 45 10             	mov    0x10(%ebp),%eax
  801097:	89 04 24             	mov    %eax,(%esp)
  80109a:	e8 6f f0 ff ff       	call   80010e <vcprintf>
	cprintf("\n");
  80109f:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  8010a6:	e8 c4 f0 ff ff       	call   80016f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ab:	cc                   	int3   
  8010ac:	eb fd                	jmp    8010ab <_panic+0x53>
	...

008010b0 <__udivdi3>:
  8010b0:	83 ec 1c             	sub    $0x1c,%esp
  8010b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010cb:	85 ff                	test   %edi,%edi
  8010cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d5:	89 cd                	mov    %ecx,%ebp
  8010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010db:	75 33                	jne    801110 <__udivdi3+0x60>
  8010dd:	39 f1                	cmp    %esi,%ecx
  8010df:	77 57                	ja     801138 <__udivdi3+0x88>
  8010e1:	85 c9                	test   %ecx,%ecx
  8010e3:	75 0b                	jne    8010f0 <__udivdi3+0x40>
  8010e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ea:	31 d2                	xor    %edx,%edx
  8010ec:	f7 f1                	div    %ecx
  8010ee:	89 c1                	mov    %eax,%ecx
  8010f0:	89 f0                	mov    %esi,%eax
  8010f2:	31 d2                	xor    %edx,%edx
  8010f4:	f7 f1                	div    %ecx
  8010f6:	89 c6                	mov    %eax,%esi
  8010f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010fc:	f7 f1                	div    %ecx
  8010fe:	89 f2                	mov    %esi,%edx
  801100:	8b 74 24 10          	mov    0x10(%esp),%esi
  801104:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801108:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110c:	83 c4 1c             	add    $0x1c,%esp
  80110f:	c3                   	ret    
  801110:	31 d2                	xor    %edx,%edx
  801112:	31 c0                	xor    %eax,%eax
  801114:	39 f7                	cmp    %esi,%edi
  801116:	77 e8                	ja     801100 <__udivdi3+0x50>
  801118:	0f bd cf             	bsr    %edi,%ecx
  80111b:	83 f1 1f             	xor    $0x1f,%ecx
  80111e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801122:	75 2c                	jne    801150 <__udivdi3+0xa0>
  801124:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801128:	76 04                	jbe    80112e <__udivdi3+0x7e>
  80112a:	39 f7                	cmp    %esi,%edi
  80112c:	73 d2                	jae    801100 <__udivdi3+0x50>
  80112e:	31 d2                	xor    %edx,%edx
  801130:	b8 01 00 00 00       	mov    $0x1,%eax
  801135:	eb c9                	jmp    801100 <__udivdi3+0x50>
  801137:	90                   	nop
  801138:	89 f2                	mov    %esi,%edx
  80113a:	f7 f1                	div    %ecx
  80113c:	31 d2                	xor    %edx,%edx
  80113e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801142:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801146:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80114a:	83 c4 1c             	add    $0x1c,%esp
  80114d:	c3                   	ret    
  80114e:	66 90                	xchg   %ax,%ax
  801150:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801155:	b8 20 00 00 00       	mov    $0x20,%eax
  80115a:	89 ea                	mov    %ebp,%edx
  80115c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801160:	d3 e7                	shl    %cl,%edi
  801162:	89 c1                	mov    %eax,%ecx
  801164:	d3 ea                	shr    %cl,%edx
  801166:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116b:	09 fa                	or     %edi,%edx
  80116d:	89 f7                	mov    %esi,%edi
  80116f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801173:	89 f2                	mov    %esi,%edx
  801175:	8b 74 24 08          	mov    0x8(%esp),%esi
  801179:	d3 e5                	shl    %cl,%ebp
  80117b:	89 c1                	mov    %eax,%ecx
  80117d:	d3 ef                	shr    %cl,%edi
  80117f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801184:	d3 e2                	shl    %cl,%edx
  801186:	89 c1                	mov    %eax,%ecx
  801188:	d3 ee                	shr    %cl,%esi
  80118a:	09 d6                	or     %edx,%esi
  80118c:	89 fa                	mov    %edi,%edx
  80118e:	89 f0                	mov    %esi,%eax
  801190:	f7 74 24 0c          	divl   0xc(%esp)
  801194:	89 d7                	mov    %edx,%edi
  801196:	89 c6                	mov    %eax,%esi
  801198:	f7 e5                	mul    %ebp
  80119a:	39 d7                	cmp    %edx,%edi
  80119c:	72 22                	jb     8011c0 <__udivdi3+0x110>
  80119e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8011a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a7:	d3 e5                	shl    %cl,%ebp
  8011a9:	39 c5                	cmp    %eax,%ebp
  8011ab:	73 04                	jae    8011b1 <__udivdi3+0x101>
  8011ad:	39 d7                	cmp    %edx,%edi
  8011af:	74 0f                	je     8011c0 <__udivdi3+0x110>
  8011b1:	89 f0                	mov    %esi,%eax
  8011b3:	31 d2                	xor    %edx,%edx
  8011b5:	e9 46 ff ff ff       	jmp    801100 <__udivdi3+0x50>
  8011ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011c3:	31 d2                	xor    %edx,%edx
  8011c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011d1:	83 c4 1c             	add    $0x1c,%esp
  8011d4:	c3                   	ret    
	...

008011e0 <__umoddi3>:
  8011e0:	83 ec 1c             	sub    $0x1c,%esp
  8011e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011fb:	85 ed                	test   %ebp,%ebp
  8011fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801201:	89 44 24 08          	mov    %eax,0x8(%esp)
  801205:	89 cf                	mov    %ecx,%edi
  801207:	89 04 24             	mov    %eax,(%esp)
  80120a:	89 f2                	mov    %esi,%edx
  80120c:	75 1a                	jne    801228 <__umoddi3+0x48>
  80120e:	39 f1                	cmp    %esi,%ecx
  801210:	76 4e                	jbe    801260 <__umoddi3+0x80>
  801212:	f7 f1                	div    %ecx
  801214:	89 d0                	mov    %edx,%eax
  801216:	31 d2                	xor    %edx,%edx
  801218:	8b 74 24 10          	mov    0x10(%esp),%esi
  80121c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801220:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801224:	83 c4 1c             	add    $0x1c,%esp
  801227:	c3                   	ret    
  801228:	39 f5                	cmp    %esi,%ebp
  80122a:	77 54                	ja     801280 <__umoddi3+0xa0>
  80122c:	0f bd c5             	bsr    %ebp,%eax
  80122f:	83 f0 1f             	xor    $0x1f,%eax
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	75 60                	jne    801298 <__umoddi3+0xb8>
  801238:	3b 0c 24             	cmp    (%esp),%ecx
  80123b:	0f 87 07 01 00 00    	ja     801348 <__umoddi3+0x168>
  801241:	89 f2                	mov    %esi,%edx
  801243:	8b 34 24             	mov    (%esp),%esi
  801246:	29 ce                	sub    %ecx,%esi
  801248:	19 ea                	sbb    %ebp,%edx
  80124a:	89 34 24             	mov    %esi,(%esp)
  80124d:	8b 04 24             	mov    (%esp),%eax
  801250:	8b 74 24 10          	mov    0x10(%esp),%esi
  801254:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801258:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80125c:	83 c4 1c             	add    $0x1c,%esp
  80125f:	c3                   	ret    
  801260:	85 c9                	test   %ecx,%ecx
  801262:	75 0b                	jne    80126f <__umoddi3+0x8f>
  801264:	b8 01 00 00 00       	mov    $0x1,%eax
  801269:	31 d2                	xor    %edx,%edx
  80126b:	f7 f1                	div    %ecx
  80126d:	89 c1                	mov    %eax,%ecx
  80126f:	89 f0                	mov    %esi,%eax
  801271:	31 d2                	xor    %edx,%edx
  801273:	f7 f1                	div    %ecx
  801275:	8b 04 24             	mov    (%esp),%eax
  801278:	f7 f1                	div    %ecx
  80127a:	eb 98                	jmp    801214 <__umoddi3+0x34>
  80127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 f2                	mov    %esi,%edx
  801282:	8b 74 24 10          	mov    0x10(%esp),%esi
  801286:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80128a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80128e:	83 c4 1c             	add    $0x1c,%esp
  801291:	c3                   	ret    
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129d:	89 e8                	mov    %ebp,%eax
  80129f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8012a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8012a8:	89 fa                	mov    %edi,%edx
  8012aa:	d3 e0                	shl    %cl,%eax
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	d3 ea                	shr    %cl,%edx
  8012b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012b5:	09 c2                	or     %eax,%edx
  8012b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012bb:	89 14 24             	mov    %edx,(%esp)
  8012be:	89 f2                	mov    %esi,%edx
  8012c0:	d3 e7                	shl    %cl,%edi
  8012c2:	89 e9                	mov    %ebp,%ecx
  8012c4:	d3 ea                	shr    %cl,%edx
  8012c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012cf:	d3 e6                	shl    %cl,%esi
  8012d1:	89 e9                	mov    %ebp,%ecx
  8012d3:	d3 e8                	shr    %cl,%eax
  8012d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012da:	09 f0                	or     %esi,%eax
  8012dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012e0:	f7 34 24             	divl   (%esp)
  8012e3:	d3 e6                	shl    %cl,%esi
  8012e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012e9:	89 d6                	mov    %edx,%esi
  8012eb:	f7 e7                	mul    %edi
  8012ed:	39 d6                	cmp    %edx,%esi
  8012ef:	89 c1                	mov    %eax,%ecx
  8012f1:	89 d7                	mov    %edx,%edi
  8012f3:	72 3f                	jb     801334 <__umoddi3+0x154>
  8012f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012f9:	72 35                	jb     801330 <__umoddi3+0x150>
  8012fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ff:	29 c8                	sub    %ecx,%eax
  801301:	19 fe                	sbb    %edi,%esi
  801303:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801308:	89 f2                	mov    %esi,%edx
  80130a:	d3 e8                	shr    %cl,%eax
  80130c:	89 e9                	mov    %ebp,%ecx
  80130e:	d3 e2                	shl    %cl,%edx
  801310:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801315:	09 d0                	or     %edx,%eax
  801317:	89 f2                	mov    %esi,%edx
  801319:	d3 ea                	shr    %cl,%edx
  80131b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80131f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801323:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801327:	83 c4 1c             	add    $0x1c,%esp
  80132a:	c3                   	ret    
  80132b:	90                   	nop
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	39 d6                	cmp    %edx,%esi
  801332:	75 c7                	jne    8012fb <__umoddi3+0x11b>
  801334:	89 d7                	mov    %edx,%edi
  801336:	89 c1                	mov    %eax,%ecx
  801338:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80133c:	1b 3c 24             	sbb    (%esp),%edi
  80133f:	eb ba                	jmp    8012fb <__umoddi3+0x11b>
  801341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801348:	39 f5                	cmp    %esi,%ebp
  80134a:	0f 82 f1 fe ff ff    	jb     801241 <__umoddi3+0x61>
  801350:	e9 f8 fe ff ff       	jmp    80124d <__umoddi3+0x6d>
