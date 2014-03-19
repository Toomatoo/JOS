
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
  800059:	c7 04 24 88 10 80 00 	movl   $0x801088,(%esp)
  800060:	e8 f2 00 00 00       	call   800157 <cprintf>
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
  80006e:	8b 45 08             	mov    0x8(%ebp),%eax
  800071:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800074:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  80007b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	7e 08                	jle    80008a <libmain+0x22>
		binaryname = argv[0];
  800082:	8b 0a                	mov    (%edx),%ecx
  800084:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80008a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80008e:	89 04 24             	mov    %eax,(%esp)
  800091:	e8 9e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800096:	e8 05 00 00 00       	call   8000a0 <exit>
}
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 3d 0c 00 00       	call   800cef <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	53                   	push   %ebx
  8000b8:	83 ec 14             	sub    $0x14,%esp
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000be:	8b 03                	mov    (%ebx),%eax
  8000c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000c7:	83 c0 01             	add    $0x1,%eax
  8000ca:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d1:	75 19                	jne    8000ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000da:	00 
  8000db:	8d 43 08             	lea    0x8(%ebx),%eax
  8000de:	89 04 24             	mov    %eax,(%esp)
  8000e1:	e8 aa 0b 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f0:	83 c4 14             	add    $0x14,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    

008000f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800106:	00 00 00 
	b.cnt = 0;
  800109:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800110:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800113:	8b 45 0c             	mov    0xc(%ebp),%eax
  800116:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011a:	8b 45 08             	mov    0x8(%ebp),%eax
  80011d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800121:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012b:	c7 04 24 b4 00 80 00 	movl   $0x8000b4,(%esp)
  800132:	e8 97 01 00 00       	call   8002ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800137:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800147:	89 04 24             	mov    %eax,(%esp)
  80014a:	e8 41 0b 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  80014f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 87 ff ff ff       	call   8000f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    
  800171:	00 00                	add    %al,(%eax)
	...

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 3c             	sub    $0x3c,%esp
  80017d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800180:	89 d7                	mov    %edx,%edi
  800182:	8b 45 08             	mov    0x8(%ebp),%eax
  800185:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800191:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800194:	b8 00 00 00 00       	mov    $0x0,%eax
  800199:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80019c:	72 11                	jb     8001af <printnum+0x3b>
  80019e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a4:	76 09                	jbe    8001af <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001a6:	83 eb 01             	sub    $0x1,%ebx
  8001a9:	85 db                	test   %ebx,%ebx
  8001ab:	7f 51                	jg     8001fe <printnum+0x8a>
  8001ad:	eb 5e                	jmp    80020d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b3:	83 eb 01             	sub    $0x1,%ebx
  8001b6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d0:	00 
  8001d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001de:	e8 fd 0b 00 00       	call   800de0 <__udivdi3>
  8001e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001eb:	89 04 24             	mov    %eax,(%esp)
  8001ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f2:	89 fa                	mov    %edi,%edx
  8001f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f7:	e8 78 ff ff ff       	call   800174 <printnum>
  8001fc:	eb 0f                	jmp    80020d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800202:	89 34 24             	mov    %esi,(%esp)
  800205:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	75 f1                	jne    8001fe <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800211:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800215:	8b 45 10             	mov    0x10(%ebp),%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800223:	00 
  800224:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800227:	89 04 24             	mov    %eax,(%esp)
  80022a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800231:	e8 da 0c 00 00       	call   800f10 <__umoddi3>
  800236:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023a:	0f be 80 a0 10 80 00 	movsbl 0x8010a0(%eax),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800247:	83 c4 3c             	add    $0x3c,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7e 0e                	jle    800265 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	8b 52 04             	mov    0x4(%edx),%edx
  800263:	eb 22                	jmp    800287 <getuint+0x38>
	else if (lflag)
  800265:	85 d2                	test   %edx,%edx
  800267:	74 10                	je     800279 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	eb 0e                	jmp    800287 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 0a                	jae    8002a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029d:	88 0a                	mov    %cl,(%edx)
  80029f:	83 c2 01             	add    $0x1,%edx
  8002a2:	89 10                	mov    %edx,(%eax)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c4:	89 04 24             	mov    %eax,(%esp)
  8002c7:	e8 02 00 00 00       	call   8002ce <vprintfmt>
	va_end(ap);
}
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 5c             	sub    $0x5c,%esp
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 75 10             	mov    0x10(%ebp),%esi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 e4 04 00 00    	je     8007cb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	0f b6 06             	movzbl (%esi),%eax
  8002f4:	83 c6 01             	add    $0x1,%esi
  8002f7:	83 f8 25             	cmp    $0x25,%eax
  8002fa:	75 e3                	jne    8002df <vprintfmt+0x11>
  8002fc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800300:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800307:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80031b:	eb 2b                	jmp    800348 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800324:	eb 22                	jmp    800348 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800329:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80032d:	eb 19                	jmp    800348 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800332:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800339:	eb 0d                	jmp    800348 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80033e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800341:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	0f b6 06             	movzbl (%esi),%eax
  80034b:	0f b6 d0             	movzbl %al,%edx
  80034e:	8d 7e 01             	lea    0x1(%esi),%edi
  800351:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800354:	83 e8 23             	sub    $0x23,%eax
  800357:	3c 55                	cmp    $0x55,%al
  800359:	0f 87 46 04 00 00    	ja     8007a5 <vprintfmt+0x4d7>
  80035f:	0f b6 c0             	movzbl %al,%eax
  800362:	ff 24 85 48 11 80 00 	jmp    *0x801148(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800369:	83 ea 30             	sub    $0x30,%edx
  80036c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80036f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800373:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800379:	83 fa 09             	cmp    $0x9,%edx
  80037c:	77 4a                	ja     8003c8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800384:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800387:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80038b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80038e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800391:	83 fa 09             	cmp    $0x9,%edx
  800394:	76 eb                	jbe    800381 <vprintfmt+0xb3>
  800396:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800399:	eb 2d                	jmp    8003c8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 50 04             	lea    0x4(%eax),%edx
  8003a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a4:	8b 00                	mov    (%eax),%eax
  8003a6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ac:	eb 1a                	jmp    8003c8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003b1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003b5:	79 91                	jns    800348 <vprintfmt+0x7a>
  8003b7:	e9 73 ff ff ff       	jmp    80032f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bf:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003c6:	eb 80                	jmp    800348 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003cc:	0f 89 76 ff ff ff    	jns    800348 <vprintfmt+0x7a>
  8003d2:	e9 64 ff ff ff       	jmp    80033b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003dd:	e9 66 ff ff ff       	jmp    800348 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 50 04             	lea    0x4(%eax),%edx
  8003e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fa:	e9 f2 fe ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8003ff:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800403:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800406:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80040a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80040d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800411:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800414:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800417:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80041b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80041e:	80 f9 09             	cmp    $0x9,%cl
  800421:	77 1d                	ja     800440 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800423:	0f be c0             	movsbl %al,%eax
  800426:	6b c0 64             	imul   $0x64,%eax,%eax
  800429:	0f be d2             	movsbl %dl,%edx
  80042c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80042f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800436:	a3 04 20 80 00       	mov    %eax,0x802004
  80043b:	e9 b1 fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800440:	c7 44 24 04 b8 10 80 	movl   $0x8010b8,0x4(%esp)
  800447:	00 
  800448:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	e8 18 05 00 00       	call   80096b <strcmp>
  800453:	85 c0                	test   %eax,%eax
  800455:	75 0f                	jne    800466 <vprintfmt+0x198>
  800457:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80045e:	00 00 00 
  800461:	e9 8b fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800466:	c7 44 24 04 bc 10 80 	movl   $0x8010bc,0x4(%esp)
  80046d:	00 
  80046e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800471:	89 14 24             	mov    %edx,(%esp)
  800474:	e8 f2 04 00 00       	call   80096b <strcmp>
  800479:	85 c0                	test   %eax,%eax
  80047b:	75 0f                	jne    80048c <vprintfmt+0x1be>
  80047d:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800484:	00 00 00 
  800487:	e9 65 fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80048c:	c7 44 24 04 c0 10 80 	movl   $0x8010c0,0x4(%esp)
  800493:	00 
  800494:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800497:	89 0c 24             	mov    %ecx,(%esp)
  80049a:	e8 cc 04 00 00       	call   80096b <strcmp>
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	75 0f                	jne    8004b2 <vprintfmt+0x1e4>
  8004a3:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004aa:	00 00 00 
  8004ad:	e9 3f fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004b2:	c7 44 24 04 c4 10 80 	movl   $0x8010c4,0x4(%esp)
  8004b9:	00 
  8004ba:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004bd:	89 3c 24             	mov    %edi,(%esp)
  8004c0:	e8 a6 04 00 00       	call   80096b <strcmp>
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 0f                	jne    8004d8 <vprintfmt+0x20a>
  8004c9:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004d0:	00 00 00 
  8004d3:	e9 19 fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004d8:	c7 44 24 04 c8 10 80 	movl   $0x8010c8,0x4(%esp)
  8004df:	00 
  8004e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004e3:	89 04 24             	mov    %eax,(%esp)
  8004e6:	e8 80 04 00 00       	call   80096b <strcmp>
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 0f                	jne    8004fe <vprintfmt+0x230>
  8004ef:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8004f6:	00 00 00 
  8004f9:	e9 f3 fd ff ff       	jmp    8002f1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8004fe:	c7 44 24 04 cc 10 80 	movl   $0x8010cc,0x4(%esp)
  800505:	00 
  800506:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800509:	89 14 24             	mov    %edx,(%esp)
  80050c:	e8 5a 04 00 00       	call   80096b <strcmp>
  800511:	83 f8 01             	cmp    $0x1,%eax
  800514:	19 c0                	sbb    %eax,%eax
  800516:	f7 d0                	not    %eax
  800518:	83 c0 08             	add    $0x8,%eax
  80051b:	a3 04 20 80 00       	mov    %eax,0x802004
  800520:	e9 cc fd ff ff       	jmp    8002f1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 c2                	mov    %eax,%edx
  800532:	c1 fa 1f             	sar    $0x1f,%edx
  800535:	31 d0                	xor    %edx,%eax
  800537:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800539:	83 f8 06             	cmp    $0x6,%eax
  80053c:	7f 0b                	jg     800549 <vprintfmt+0x27b>
  80053e:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800545:	85 d2                	test   %edx,%edx
  800547:	75 23                	jne    80056c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054d:	c7 44 24 08 d0 10 80 	movl   $0x8010d0,0x8(%esp)
  800554:	00 
  800555:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800559:	8b 7d 08             	mov    0x8(%ebp),%edi
  80055c:	89 3c 24             	mov    %edi,(%esp)
  80055f:	e8 42 fd ff ff       	call   8002a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800567:	e9 85 fd ff ff       	jmp    8002f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800570:	c7 44 24 08 d9 10 80 	movl   $0x8010d9,0x8(%esp)
  800577:	00 
  800578:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057f:	89 3c 24             	mov    %edi,(%esp)
  800582:	e8 1f fd ff ff       	call   8002a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80058a:	e9 62 fd ff ff       	jmp    8002f1 <vprintfmt+0x23>
  80058f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800592:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800595:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 50 04             	lea    0x4(%eax),%edx
  80059e:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005a3:	85 f6                	test   %esi,%esi
  8005a5:	b8 b1 10 80 00       	mov    $0x8010b1,%eax
  8005aa:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005b1:	7e 06                	jle    8005b9 <vprintfmt+0x2eb>
  8005b3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005b7:	75 13                	jne    8005cc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	0f be 06             	movsbl (%esi),%eax
  8005bc:	83 c6 01             	add    $0x1,%esi
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	0f 85 94 00 00 00    	jne    80065b <vprintfmt+0x38d>
  8005c7:	e9 81 00 00 00       	jmp    80064d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d0:	89 34 24             	mov    %esi,(%esp)
  8005d3:	e8 a3 02 00 00       	call   80087b <strnlen>
  8005d8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005db:	29 c2                	sub    %eax,%edx
  8005dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	7e d5                	jle    8005b9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005e4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8005e8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005eb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8005ee:	89 d6                	mov    %edx,%esi
  8005f0:	89 cf                	mov    %ecx,%edi
  8005f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f6:	89 3c 24             	mov    %edi,(%esp)
  8005f9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fc:	83 ee 01             	sub    $0x1,%esi
  8005ff:	75 f1                	jne    8005f2 <vprintfmt+0x324>
  800601:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800604:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800607:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80060a:	eb ad                	jmp    8005b9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800610:	74 1b                	je     80062d <vprintfmt+0x35f>
  800612:	8d 50 e0             	lea    -0x20(%eax),%edx
  800615:	83 fa 5e             	cmp    $0x5e,%edx
  800618:	76 13                	jbe    80062d <vprintfmt+0x35f>
					putch('?', putdat);
  80061a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800621:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800628:	ff 55 08             	call   *0x8(%ebp)
  80062b:	eb 0d                	jmp    80063a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80062d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800630:	89 54 24 04          	mov    %edx,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063a:	83 eb 01             	sub    $0x1,%ebx
  80063d:	0f be 06             	movsbl (%esi),%eax
  800640:	83 c6 01             	add    $0x1,%esi
  800643:	85 c0                	test   %eax,%eax
  800645:	75 1a                	jne    800661 <vprintfmt+0x393>
  800647:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80064a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800654:	7f 1c                	jg     800672 <vprintfmt+0x3a4>
  800656:	e9 96 fc ff ff       	jmp    8002f1 <vprintfmt+0x23>
  80065b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80065e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800661:	85 ff                	test   %edi,%edi
  800663:	78 a7                	js     80060c <vprintfmt+0x33e>
  800665:	83 ef 01             	sub    $0x1,%edi
  800668:	79 a2                	jns    80060c <vprintfmt+0x33e>
  80066a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80066d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800670:	eb db                	jmp    80064d <vprintfmt+0x37f>
  800672:	8b 7d 08             	mov    0x8(%ebp),%edi
  800675:	89 de                	mov    %ebx,%esi
  800677:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800685:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800687:	83 eb 01             	sub    $0x1,%ebx
  80068a:	75 ee                	jne    80067a <vprintfmt+0x3ac>
  80068c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800691:	e9 5b fc ff ff       	jmp    8002f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800696:	83 f9 01             	cmp    $0x1,%ecx
  800699:	7e 10                	jle    8006ab <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8d 50 08             	lea    0x8(%eax),%edx
  8006a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a4:	8b 30                	mov    (%eax),%esi
  8006a6:	8b 78 04             	mov    0x4(%eax),%edi
  8006a9:	eb 26                	jmp    8006d1 <vprintfmt+0x403>
	else if (lflag)
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	74 12                	je     8006c1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 30                	mov    (%eax),%esi
  8006ba:	89 f7                	mov    %esi,%edi
  8006bc:	c1 ff 1f             	sar    $0x1f,%edi
  8006bf:	eb 10                	jmp    8006d1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	8b 30                	mov    (%eax),%esi
  8006cc:	89 f7                	mov    %esi,%edi
  8006ce:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d1:	85 ff                	test   %edi,%edi
  8006d3:	78 0e                	js     8006e3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d9:	be 0a 00 00 00       	mov    $0xa,%esi
  8006de:	e9 84 00 00 00       	jmp    800767 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f1:	89 f0                	mov    %esi,%eax
  8006f3:	89 fa                	mov    %edi,%edx
  8006f5:	f7 d8                	neg    %eax
  8006f7:	83 d2 00             	adc    $0x0,%edx
  8006fa:	f7 da                	neg    %edx
			}
			base = 10;
  8006fc:	be 0a 00 00 00       	mov    $0xa,%esi
  800701:	eb 64                	jmp    800767 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800703:	89 ca                	mov    %ecx,%edx
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 42 fb ff ff       	call   80024f <getuint>
			base = 10;
  80070d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800712:	eb 53                	jmp    800767 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800714:	89 ca                	mov    %ecx,%edx
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
  800719:	e8 31 fb ff ff       	call   80024f <getuint>
    			base = 8;
  80071e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800723:	eb 42                	jmp    800767 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 50 04             	lea    0x4(%eax),%edx
  800747:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800751:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800756:	eb 0f                	jmp    800767 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800758:	89 ca                	mov    %ecx,%edx
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 ed fa ff ff       	call   80024f <getuint>
			base = 16;
  800762:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800767:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80076b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80076f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800772:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800776:	89 74 24 08          	mov    %esi,0x8(%esp)
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800781:	89 da                	mov    %ebx,%edx
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	e8 e9 f9 ff ff       	call   800174 <printnum>
			break;
  80078b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80078e:	e9 5e fb ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	89 14 24             	mov    %edx,(%esp)
  80079a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a0:	e9 4c fb ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007b7:	0f 84 34 fb ff ff    	je     8002f1 <vprintfmt+0x23>
  8007bd:	83 ee 01             	sub    $0x1,%esi
  8007c0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c4:	75 f7                	jne    8007bd <vprintfmt+0x4ef>
  8007c6:	e9 26 fb ff ff       	jmp    8002f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007cb:	83 c4 5c             	add    $0x5c,%esp
  8007ce:	5b                   	pop    %ebx
  8007cf:	5e                   	pop    %esi
  8007d0:	5f                   	pop    %edi
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 28             	sub    $0x28,%esp
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	74 30                	je     800824 <vsnprintf+0x51>
  8007f4:	85 d2                	test   %edx,%edx
  8007f6:	7e 2c                	jle    800824 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800802:	89 44 24 08          	mov    %eax,0x8(%esp)
  800806:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080d:	c7 04 24 89 02 80 00 	movl   $0x800289,(%esp)
  800814:	e8 b5 fa ff ff       	call   8002ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800819:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800822:	eb 05                	jmp    800829 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800824:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800834:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800838:	8b 45 10             	mov    0x10(%ebp),%eax
  80083b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800842:	89 44 24 04          	mov    %eax,0x4(%esp)
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	89 04 24             	mov    %eax,(%esp)
  80084c:	e8 82 ff ff ff       	call   8007d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800851:	c9                   	leave  
  800852:	c3                   	ret    
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	80 3a 00             	cmpb   $0x0,(%edx)
  80086e:	74 09                	je     800879 <strlen+0x19>
		n++;
  800870:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800877:	75 f7                	jne    800870 <strlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 1a                	je     8008a8 <strnlen+0x2d>
  80088e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800891:	74 15                	je     8008a8 <strnlen+0x2d>
  800893:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800898:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089a:	39 ca                	cmp    %ecx,%edx
  80089c:	74 0a                	je     8008a8 <strnlen+0x2d>
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008a6:	75 f0                	jne    800898 <strnlen+0x1d>
		n++;
	return n;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008be:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	84 c9                	test   %cl,%cl
  8008c6:	75 f2                	jne    8008ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d5:	89 1c 24             	mov    %ebx,(%esp)
  8008d8:	e8 83 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e4:	01 d8                	add    %ebx,%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 bd ff ff ff       	call   8008ab <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	83 c4 08             	add    $0x8,%esp
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800904:	85 f6                	test   %esi,%esi
  800906:	74 18                	je     800920 <strncpy+0x2a>
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80090d:	0f b6 1a             	movzbl (%edx),%ebx
  800910:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800913:	80 3a 01             	cmpb   $0x1,(%edx)
  800916:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	39 f1                	cmp    %esi,%ecx
  80091e:	75 ed                	jne    80090d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800930:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800933:	89 f8                	mov    %edi,%eax
  800935:	85 f6                	test   %esi,%esi
  800937:	74 2b                	je     800964 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800939:	83 fe 01             	cmp    $0x1,%esi
  80093c:	74 23                	je     800961 <strlcpy+0x3d>
  80093e:	0f b6 0b             	movzbl (%ebx),%ecx
  800941:	84 c9                	test   %cl,%cl
  800943:	74 1c                	je     800961 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800945:	83 ee 02             	sub    $0x2,%esi
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094d:	88 08                	mov    %cl,(%eax)
  80094f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800952:	39 f2                	cmp    %esi,%edx
  800954:	74 0b                	je     800961 <strlcpy+0x3d>
  800956:	83 c2 01             	add    $0x1,%edx
  800959:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095d:	84 c9                	test   %cl,%cl
  80095f:	75 ec                	jne    80094d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f8                	sub    %edi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800974:	0f b6 01             	movzbl (%ecx),%eax
  800977:	84 c0                	test   %al,%al
  800979:	74 16                	je     800991 <strcmp+0x26>
  80097b:	3a 02                	cmp    (%edx),%al
  80097d:	75 12                	jne    800991 <strcmp+0x26>
		p++, q++;
  80097f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800982:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800986:	84 c0                	test   %al,%al
  800988:	74 07                	je     800991 <strcmp+0x26>
  80098a:	83 c1 01             	add    $0x1,%ecx
  80098d:	3a 02                	cmp    (%edx),%al
  80098f:	74 ee                	je     80097f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 12             	movzbl (%edx),%edx
  800997:	29 d0                	sub    %edx,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	74 28                	je     8009d9 <strncmp+0x3e>
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	84 c0                	test   %al,%al
  8009b6:	74 24                	je     8009dc <strncmp+0x41>
  8009b8:	3a 03                	cmp    (%ebx),%al
  8009ba:	75 20                	jne    8009dc <strncmp+0x41>
  8009bc:	83 ea 01             	sub    $0x1,%edx
  8009bf:	74 13                	je     8009d4 <strncmp+0x39>
		n--, p++, q++;
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c7:	0f b6 01             	movzbl (%ecx),%eax
  8009ca:	84 c0                	test   %al,%al
  8009cc:	74 0e                	je     8009dc <strncmp+0x41>
  8009ce:	3a 03                	cmp    (%ebx),%al
  8009d0:	74 ea                	je     8009bc <strncmp+0x21>
  8009d2:	eb 08                	jmp    8009dc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	0f b6 13             	movzbl (%ebx),%edx
  8009e2:	29 d0                	sub    %edx,%eax
  8009e4:	eb f3                	jmp    8009d9 <strncmp+0x3e>

008009e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f0:	0f b6 10             	movzbl (%eax),%edx
  8009f3:	84 d2                	test   %dl,%dl
  8009f5:	74 1c                	je     800a13 <strchr+0x2d>
		if (*s == c)
  8009f7:	38 ca                	cmp    %cl,%dl
  8009f9:	75 09                	jne    800a04 <strchr+0x1e>
  8009fb:	eb 1b                	jmp    800a18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a00:	38 ca                	cmp    %cl,%dl
  800a02:	74 14                	je     800a18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a04:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	75 f1                	jne    8009fd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb 05                	jmp    800a18 <strchr+0x32>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	0f b6 10             	movzbl (%eax),%edx
  800a27:	84 d2                	test   %dl,%dl
  800a29:	74 14                	je     800a3f <strfind+0x25>
		if (*s == c)
  800a2b:	38 ca                	cmp    %cl,%dl
  800a2d:	75 06                	jne    800a35 <strfind+0x1b>
  800a2f:	eb 0e                	jmp    800a3f <strfind+0x25>
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 0a                	je     800a3f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	75 f2                	jne    800a31 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	83 ec 0c             	sub    $0xc,%esp
  800a47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a59:	85 c9                	test   %ecx,%ecx
  800a5b:	74 30                	je     800a8d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a63:	75 25                	jne    800a8a <memset+0x49>
  800a65:	f6 c1 03             	test   $0x3,%cl
  800a68:	75 20                	jne    800a8a <memset+0x49>
		c &= 0xFF;
  800a6a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6d:	89 d3                	mov    %edx,%ebx
  800a6f:	c1 e3 08             	shl    $0x8,%ebx
  800a72:	89 d6                	mov    %edx,%esi
  800a74:	c1 e6 18             	shl    $0x18,%esi
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	c1 e0 10             	shl    $0x10,%eax
  800a7c:	09 f0                	or     %esi,%eax
  800a7e:	09 d0                	or     %edx,%eax
  800a80:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a82:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a85:	fc                   	cld    
  800a86:	f3 ab                	rep stos %eax,%es:(%edi)
  800a88:	eb 03                	jmp    800a8d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8a:	fc                   	cld    
  800a8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8d:	89 f8                	mov    %edi,%eax
  800a8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a98:	89 ec                	mov    %ebp,%esp
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 08             	sub    $0x8,%esp
  800aa2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aa5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab1:	39 c6                	cmp    %eax,%esi
  800ab3:	73 36                	jae    800aeb <memmove+0x4f>
  800ab5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab8:	39 d0                	cmp    %edx,%eax
  800aba:	73 2f                	jae    800aeb <memmove+0x4f>
		s += n;
		d += n;
  800abc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abf:	f6 c2 03             	test   $0x3,%dl
  800ac2:	75 1b                	jne    800adf <memmove+0x43>
  800ac4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aca:	75 13                	jne    800adf <memmove+0x43>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0e                	jne    800adf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad1:	83 ef 04             	sub    $0x4,%edi
  800ad4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ada:	fd                   	std    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb 09                	jmp    800ae8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adf:	83 ef 01             	sub    $0x1,%edi
  800ae2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae8:	fc                   	cld    
  800ae9:	eb 20                	jmp    800b0b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aeb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af1:	75 13                	jne    800b06 <memmove+0x6a>
  800af3:	a8 03                	test   $0x3,%al
  800af5:	75 0f                	jne    800b06 <memmove+0x6a>
  800af7:	f6 c1 03             	test   $0x3,%cl
  800afa:	75 0a                	jne    800b06 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800afc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	fc                   	cld    
  800b02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b04:	eb 05                	jmp    800b0b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	fc                   	cld    
  800b09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b11:	89 ec                	mov    %ebp,%esp
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	e8 68 ff ff ff       	call   800a9c <memmove>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4a:	85 ff                	test   %edi,%edi
  800b4c:	74 37                	je     800b85 <memcmp+0x4f>
		if (*s1 != *s2)
  800b4e:	0f b6 03             	movzbl (%ebx),%eax
  800b51:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b54:	83 ef 01             	sub    $0x1,%edi
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b5c:	38 c8                	cmp    %cl,%al
  800b5e:	74 1c                	je     800b7c <memcmp+0x46>
  800b60:	eb 10                	jmp    800b72 <memcmp+0x3c>
  800b62:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b6e:	38 c8                	cmp    %cl,%al
  800b70:	74 0a                	je     800b7c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b72:	0f b6 c0             	movzbl %al,%eax
  800b75:	0f b6 c9             	movzbl %cl,%ecx
  800b78:	29 c8                	sub    %ecx,%eax
  800b7a:	eb 09                	jmp    800b85 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7c:	39 fa                	cmp    %edi,%edx
  800b7e:	75 e2                	jne    800b62 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b90:	89 c2                	mov    %eax,%edx
  800b92:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b95:	39 d0                	cmp    %edx,%eax
  800b97:	73 19                	jae    800bb2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b9d:	38 08                	cmp    %cl,(%eax)
  800b9f:	75 06                	jne    800ba7 <memfind+0x1d>
  800ba1:	eb 0f                	jmp    800bb2 <memfind+0x28>
  800ba3:	38 08                	cmp    %cl,(%eax)
  800ba5:	74 0b                	je     800bb2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba7:	83 c0 01             	add    $0x1,%eax
  800baa:	39 d0                	cmp    %edx,%eax
  800bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bb0:	75 f1                	jne    800ba3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc0:	0f b6 02             	movzbl (%edx),%eax
  800bc3:	3c 20                	cmp    $0x20,%al
  800bc5:	74 04                	je     800bcb <strtol+0x17>
  800bc7:	3c 09                	cmp    $0x9,%al
  800bc9:	75 0e                	jne    800bd9 <strtol+0x25>
		s++;
  800bcb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bce:	0f b6 02             	movzbl (%edx),%eax
  800bd1:	3c 20                	cmp    $0x20,%al
  800bd3:	74 f6                	je     800bcb <strtol+0x17>
  800bd5:	3c 09                	cmp    $0x9,%al
  800bd7:	74 f2                	je     800bcb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd9:	3c 2b                	cmp    $0x2b,%al
  800bdb:	75 0a                	jne    800be7 <strtol+0x33>
		s++;
  800bdd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be0:	bf 00 00 00 00       	mov    $0x0,%edi
  800be5:	eb 10                	jmp    800bf7 <strtol+0x43>
  800be7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bec:	3c 2d                	cmp    $0x2d,%al
  800bee:	75 07                	jne    800bf7 <strtol+0x43>
		s++, neg = 1;
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf7:	85 db                	test   %ebx,%ebx
  800bf9:	0f 94 c0             	sete   %al
  800bfc:	74 05                	je     800c03 <strtol+0x4f>
  800bfe:	83 fb 10             	cmp    $0x10,%ebx
  800c01:	75 15                	jne    800c18 <strtol+0x64>
  800c03:	80 3a 30             	cmpb   $0x30,(%edx)
  800c06:	75 10                	jne    800c18 <strtol+0x64>
  800c08:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c0c:	75 0a                	jne    800c18 <strtol+0x64>
		s += 2, base = 16;
  800c0e:	83 c2 02             	add    $0x2,%edx
  800c11:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c16:	eb 13                	jmp    800c2b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c18:	84 c0                	test   %al,%al
  800c1a:	74 0f                	je     800c2b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c21:	80 3a 30             	cmpb   $0x30,(%edx)
  800c24:	75 05                	jne    800c2b <strtol+0x77>
		s++, base = 8;
  800c26:	83 c2 01             	add    $0x1,%edx
  800c29:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c32:	0f b6 0a             	movzbl (%edx),%ecx
  800c35:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c38:	80 fb 09             	cmp    $0x9,%bl
  800c3b:	77 08                	ja     800c45 <strtol+0x91>
			dig = *s - '0';
  800c3d:	0f be c9             	movsbl %cl,%ecx
  800c40:	83 e9 30             	sub    $0x30,%ecx
  800c43:	eb 1e                	jmp    800c63 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c45:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c48:	80 fb 19             	cmp    $0x19,%bl
  800c4b:	77 08                	ja     800c55 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c4d:	0f be c9             	movsbl %cl,%ecx
  800c50:	83 e9 57             	sub    $0x57,%ecx
  800c53:	eb 0e                	jmp    800c63 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c55:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c58:	80 fb 19             	cmp    $0x19,%bl
  800c5b:	77 14                	ja     800c71 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c5d:	0f be c9             	movsbl %cl,%ecx
  800c60:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c63:	39 f1                	cmp    %esi,%ecx
  800c65:	7d 0e                	jge    800c75 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c67:	83 c2 01             	add    $0x1,%edx
  800c6a:	0f af c6             	imul   %esi,%eax
  800c6d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c6f:	eb c1                	jmp    800c32 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c71:	89 c1                	mov    %eax,%ecx
  800c73:	eb 02                	jmp    800c77 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c75:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c7b:	74 05                	je     800c82 <strtol+0xce>
		*endptr = (char *) s;
  800c7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c80:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c82:	89 ca                	mov    %ecx,%edx
  800c84:	f7 da                	neg    %edx
  800c86:	85 ff                	test   %edi,%edi
  800c88:	0f 45 c2             	cmovne %edx,%eax
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 c3                	mov    %eax,%ebx
  800cac:	89 c7                	mov    %eax,%edi
  800cae:	89 c6                	mov    %eax,%esi
  800cb0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbb:	89 ec                	mov    %ebp,%esp
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd8:	89 d1                	mov    %edx,%ecx
  800cda:	89 d3                	mov    %edx,%ebx
  800cdc:	89 d7                	mov    %edx,%edi
  800cde:	89 d6                	mov    %edx,%esi
  800ce0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ceb:	89 ec                	mov    %ebp,%esp
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 38             	sub    $0x38,%esp
  800cf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d03:	b8 03 00 00 00       	mov    $0x3,%eax
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 cb                	mov    %ecx,%ebx
  800d0d:	89 cf                	mov    %ecx,%edi
  800d0f:	89 ce                	mov    %ecx,%esi
  800d11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 bc 12 80 	movl   $0x8012bc,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 d9 12 80 00 	movl   $0x8012d9,(%esp)
  800d3a:	e8 3d 00 00 00       	call   800d7c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 02 00 00 00       	mov    $0x2,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d84:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d87:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d8d:	e8 ba ff ff ff       	call   800d4c <sys_getenvid>
  800d92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d95:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da8:	c7 04 24 e8 12 80 00 	movl   $0x8012e8,(%esp)
  800daf:	e8 a3 f3 ff ff       	call   800157 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbb:	89 04 24             	mov    %eax,(%esp)
  800dbe:	e8 33 f3 ff ff       	call   8000f6 <vcprintf>
	cprintf("\n");
  800dc3:	c7 04 24 94 10 80 00 	movl   $0x801094,(%esp)
  800dca:	e8 88 f3 ff ff       	call   800157 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dcf:	cc                   	int3   
  800dd0:	eb fd                	jmp    800dcf <_panic+0x53>
	...

00800de0 <__udivdi3>:
  800de0:	83 ec 1c             	sub    $0x1c,%esp
  800de3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800de7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800deb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800def:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800df3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800df7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800dfb:	85 ff                	test   %edi,%edi
  800dfd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800e01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e05:	89 cd                	mov    %ecx,%ebp
  800e07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0b:	75 33                	jne    800e40 <__udivdi3+0x60>
  800e0d:	39 f1                	cmp    %esi,%ecx
  800e0f:	77 57                	ja     800e68 <__udivdi3+0x88>
  800e11:	85 c9                	test   %ecx,%ecx
  800e13:	75 0b                	jne    800e20 <__udivdi3+0x40>
  800e15:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1a:	31 d2                	xor    %edx,%edx
  800e1c:	f7 f1                	div    %ecx
  800e1e:	89 c1                	mov    %eax,%ecx
  800e20:	89 f0                	mov    %esi,%eax
  800e22:	31 d2                	xor    %edx,%edx
  800e24:	f7 f1                	div    %ecx
  800e26:	89 c6                	mov    %eax,%esi
  800e28:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e2c:	f7 f1                	div    %ecx
  800e2e:	89 f2                	mov    %esi,%edx
  800e30:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e34:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e38:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e3c:	83 c4 1c             	add    $0x1c,%esp
  800e3f:	c3                   	ret    
  800e40:	31 d2                	xor    %edx,%edx
  800e42:	31 c0                	xor    %eax,%eax
  800e44:	39 f7                	cmp    %esi,%edi
  800e46:	77 e8                	ja     800e30 <__udivdi3+0x50>
  800e48:	0f bd cf             	bsr    %edi,%ecx
  800e4b:	83 f1 1f             	xor    $0x1f,%ecx
  800e4e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e52:	75 2c                	jne    800e80 <__udivdi3+0xa0>
  800e54:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800e58:	76 04                	jbe    800e5e <__udivdi3+0x7e>
  800e5a:	39 f7                	cmp    %esi,%edi
  800e5c:	73 d2                	jae    800e30 <__udivdi3+0x50>
  800e5e:	31 d2                	xor    %edx,%edx
  800e60:	b8 01 00 00 00       	mov    $0x1,%eax
  800e65:	eb c9                	jmp    800e30 <__udivdi3+0x50>
  800e67:	90                   	nop
  800e68:	89 f2                	mov    %esi,%edx
  800e6a:	f7 f1                	div    %ecx
  800e6c:	31 d2                	xor    %edx,%edx
  800e6e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e72:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e76:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	c3                   	ret    
  800e7e:	66 90                	xchg   %ax,%ax
  800e80:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e85:	b8 20 00 00 00       	mov    $0x20,%eax
  800e8a:	89 ea                	mov    %ebp,%edx
  800e8c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e90:	d3 e7                	shl    %cl,%edi
  800e92:	89 c1                	mov    %eax,%ecx
  800e94:	d3 ea                	shr    %cl,%edx
  800e96:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e9b:	09 fa                	or     %edi,%edx
  800e9d:	89 f7                	mov    %esi,%edi
  800e9f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ea3:	89 f2                	mov    %esi,%edx
  800ea5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ea9:	d3 e5                	shl    %cl,%ebp
  800eab:	89 c1                	mov    %eax,%ecx
  800ead:	d3 ef                	shr    %cl,%edi
  800eaf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eb4:	d3 e2                	shl    %cl,%edx
  800eb6:	89 c1                	mov    %eax,%ecx
  800eb8:	d3 ee                	shr    %cl,%esi
  800eba:	09 d6                	or     %edx,%esi
  800ebc:	89 fa                	mov    %edi,%edx
  800ebe:	89 f0                	mov    %esi,%eax
  800ec0:	f7 74 24 0c          	divl   0xc(%esp)
  800ec4:	89 d7                	mov    %edx,%edi
  800ec6:	89 c6                	mov    %eax,%esi
  800ec8:	f7 e5                	mul    %ebp
  800eca:	39 d7                	cmp    %edx,%edi
  800ecc:	72 22                	jb     800ef0 <__udivdi3+0x110>
  800ece:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800ed2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ed7:	d3 e5                	shl    %cl,%ebp
  800ed9:	39 c5                	cmp    %eax,%ebp
  800edb:	73 04                	jae    800ee1 <__udivdi3+0x101>
  800edd:	39 d7                	cmp    %edx,%edi
  800edf:	74 0f                	je     800ef0 <__udivdi3+0x110>
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	e9 46 ff ff ff       	jmp    800e30 <__udivdi3+0x50>
  800eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ef0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ef9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800efd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f01:	83 c4 1c             	add    $0x1c,%esp
  800f04:	c3                   	ret    
	...

00800f10 <__umoddi3>:
  800f10:	83 ec 1c             	sub    $0x1c,%esp
  800f13:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f17:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800f1b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f1f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f23:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f27:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f2b:	85 ed                	test   %ebp,%ebp
  800f2d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f35:	89 cf                	mov    %ecx,%edi
  800f37:	89 04 24             	mov    %eax,(%esp)
  800f3a:	89 f2                	mov    %esi,%edx
  800f3c:	75 1a                	jne    800f58 <__umoddi3+0x48>
  800f3e:	39 f1                	cmp    %esi,%ecx
  800f40:	76 4e                	jbe    800f90 <__umoddi3+0x80>
  800f42:	f7 f1                	div    %ecx
  800f44:	89 d0                	mov    %edx,%eax
  800f46:	31 d2                	xor    %edx,%edx
  800f48:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f4c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f50:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f54:	83 c4 1c             	add    $0x1c,%esp
  800f57:	c3                   	ret    
  800f58:	39 f5                	cmp    %esi,%ebp
  800f5a:	77 54                	ja     800fb0 <__umoddi3+0xa0>
  800f5c:	0f bd c5             	bsr    %ebp,%eax
  800f5f:	83 f0 1f             	xor    $0x1f,%eax
  800f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f66:	75 60                	jne    800fc8 <__umoddi3+0xb8>
  800f68:	3b 0c 24             	cmp    (%esp),%ecx
  800f6b:	0f 87 07 01 00 00    	ja     801078 <__umoddi3+0x168>
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	8b 34 24             	mov    (%esp),%esi
  800f76:	29 ce                	sub    %ecx,%esi
  800f78:	19 ea                	sbb    %ebp,%edx
  800f7a:	89 34 24             	mov    %esi,(%esp)
  800f7d:	8b 04 24             	mov    (%esp),%eax
  800f80:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f88:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f8c:	83 c4 1c             	add    $0x1c,%esp
  800f8f:	c3                   	ret    
  800f90:	85 c9                	test   %ecx,%ecx
  800f92:	75 0b                	jne    800f9f <__umoddi3+0x8f>
  800f94:	b8 01 00 00 00       	mov    $0x1,%eax
  800f99:	31 d2                	xor    %edx,%edx
  800f9b:	f7 f1                	div    %ecx
  800f9d:	89 c1                	mov    %eax,%ecx
  800f9f:	89 f0                	mov    %esi,%eax
  800fa1:	31 d2                	xor    %edx,%edx
  800fa3:	f7 f1                	div    %ecx
  800fa5:	8b 04 24             	mov    (%esp),%eax
  800fa8:	f7 f1                	div    %ecx
  800faa:	eb 98                	jmp    800f44 <__umoddi3+0x34>
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fb6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fba:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fbe:	83 c4 1c             	add    $0x1c,%esp
  800fc1:	c3                   	ret    
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fcd:	89 e8                	mov    %ebp,%eax
  800fcf:	bd 20 00 00 00       	mov    $0x20,%ebp
  800fd4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800fd8:	89 fa                	mov    %edi,%edx
  800fda:	d3 e0                	shl    %cl,%eax
  800fdc:	89 e9                	mov    %ebp,%ecx
  800fde:	d3 ea                	shr    %cl,%edx
  800fe0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fe5:	09 c2                	or     %eax,%edx
  800fe7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800feb:	89 14 24             	mov    %edx,(%esp)
  800fee:	89 f2                	mov    %esi,%edx
  800ff0:	d3 e7                	shl    %cl,%edi
  800ff2:	89 e9                	mov    %ebp,%ecx
  800ff4:	d3 ea                	shr    %cl,%edx
  800ff6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fff:	d3 e6                	shl    %cl,%esi
  801001:	89 e9                	mov    %ebp,%ecx
  801003:	d3 e8                	shr    %cl,%eax
  801005:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100a:	09 f0                	or     %esi,%eax
  80100c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801010:	f7 34 24             	divl   (%esp)
  801013:	d3 e6                	shl    %cl,%esi
  801015:	89 74 24 08          	mov    %esi,0x8(%esp)
  801019:	89 d6                	mov    %edx,%esi
  80101b:	f7 e7                	mul    %edi
  80101d:	39 d6                	cmp    %edx,%esi
  80101f:	89 c1                	mov    %eax,%ecx
  801021:	89 d7                	mov    %edx,%edi
  801023:	72 3f                	jb     801064 <__umoddi3+0x154>
  801025:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801029:	72 35                	jb     801060 <__umoddi3+0x150>
  80102b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80102f:	29 c8                	sub    %ecx,%eax
  801031:	19 fe                	sbb    %edi,%esi
  801033:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801038:	89 f2                	mov    %esi,%edx
  80103a:	d3 e8                	shr    %cl,%eax
  80103c:	89 e9                	mov    %ebp,%ecx
  80103e:	d3 e2                	shl    %cl,%edx
  801040:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801045:	09 d0                	or     %edx,%eax
  801047:	89 f2                	mov    %esi,%edx
  801049:	d3 ea                	shr    %cl,%edx
  80104b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80104f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801053:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801057:	83 c4 1c             	add    $0x1c,%esp
  80105a:	c3                   	ret    
  80105b:	90                   	nop
  80105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801060:	39 d6                	cmp    %edx,%esi
  801062:	75 c7                	jne    80102b <__umoddi3+0x11b>
  801064:	89 d7                	mov    %edx,%edi
  801066:	89 c1                	mov    %eax,%ecx
  801068:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80106c:	1b 3c 24             	sbb    (%esp),%edi
  80106f:	eb ba                	jmp    80102b <__umoddi3+0x11b>
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	39 f5                	cmp    %esi,%ebp
  80107a:	0f 82 f1 fe ff ff    	jb     800f71 <__umoddi3+0x61>
  801080:	e9 f8 fe ff ff       	jmp    800f7d <__umoddi3+0x6d>
