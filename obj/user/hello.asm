
obj/user/hello:     file format elf32-i386


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
  80003a:	c7 04 24 98 10 80 00 	movl   $0x801098,(%esp)
  800041:	e8 25 01 00 00       	call   80016b <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 08 20 80 00       	mov    0x802008,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 a6 10 80 00 	movl   $0x8010a6,(%esp)
  800059:	e8 0d 01 00 00       	call   80016b <cprintf>
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
  80007c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80007f:	c1 e0 05             	shl    $0x5,%eax
  800082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800087:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008c:	85 f6                	test   %esi,%esi
  80008e:	7e 07                	jle    800097 <libmain+0x37>
		binaryname = argv[0];
  800090:	8b 03                	mov    (%ebx),%eax
  800092:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800097:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009b:	89 34 24             	mov    %esi,(%esp)
  80009e:	e8 91 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a3:	e8 0c 00 00 00       	call   8000b4 <exit>
}
  8000a8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ab:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ae:	89 ec                	mov    %ebp,%esp
  8000b0:	5d                   	pop    %ebp
  8000b1:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 39 0c 00 00       	call   800cff <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	83 c0 01             	add    $0x1,%eax
  8000de:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e5:	75 19                	jne    800100 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ee:	00 
  8000ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f2:	89 04 24             	mov    %eax,(%esp)
  8000f5:	e8 a6 0b 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  8000fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800100:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800104:	83 c4 14             	add    $0x14,%esp
  800107:	5b                   	pop    %ebx
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800113:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011a:	00 00 00 
	b.cnt = 0;
  80011d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800124:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800127:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012e:	8b 45 08             	mov    0x8(%ebp),%eax
  800131:	89 44 24 08          	mov    %eax,0x8(%esp)
  800135:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013f:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800146:	e8 97 01 00 00       	call   8002e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800151:	89 44 24 04          	mov    %eax,0x4(%esp)
  800155:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 3d 0b 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	8b 45 08             	mov    0x8(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	e8 87 ff ff ff       	call   80010a <vcprintf>
	va_end(ap);

	return cnt;
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 3c             	sub    $0x3c,%esp
  800191:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800194:	89 d7                	mov    %edx,%edi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ad:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b0:	72 11                	jb     8001c3 <printnum+0x3b>
  8001b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b8:	76 09                	jbe    8001c3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ba:	83 eb 01             	sub    $0x1,%ebx
  8001bd:	85 db                	test   %ebx,%ebx
  8001bf:	7f 51                	jg     800212 <printnum+0x8a>
  8001c1:	eb 5e                	jmp    800221 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c7:	83 eb 01             	sub    $0x1,%ebx
  8001ca:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e4:	00 
  8001e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	e8 f9 0b 00 00       	call   800df0 <__udivdi3>
  8001f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	89 54 24 04          	mov    %edx,0x4(%esp)
  800206:	89 fa                	mov    %edi,%edx
  800208:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020b:	e8 78 ff ff ff       	call   800188 <printnum>
  800210:	eb 0f                	jmp    800221 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800212:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800216:	89 34 24             	mov    %esi,(%esp)
  800219:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021c:	83 eb 01             	sub    $0x1,%ebx
  80021f:	75 f1                	jne    800212 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800221:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800225:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800229:	8b 45 10             	mov    0x10(%ebp),%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800237:	00 
  800238:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	e8 d6 0c 00 00       	call   800f20 <__umoddi3>
  80024a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024e:	0f be 80 c7 10 80 00 	movsbl 0x8010c7(%eax),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80025b:	83 c4 3c             	add    $0x3c,%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800266:	83 fa 01             	cmp    $0x1,%edx
  800269:	7e 0e                	jle    800279 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 02                	mov    (%edx),%eax
  800274:	8b 52 04             	mov    0x4(%edx),%edx
  800277:	eb 22                	jmp    80029b <getuint+0x38>
	else if (lflag)
  800279:	85 d2                	test   %edx,%edx
  80027b:	74 10                	je     80028d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
  80028b:	eb 0e                	jmp    80029b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 0a                	jae    8002b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b1:	88 0a                	mov    %cl,(%edx)
  8002b3:	83 c2 01             	add    $0x1,%edx
  8002b6:	89 10                	mov    %edx,(%eax)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	e8 02 00 00 00       	call   8002e2 <vprintfmt>
	va_end(ap);
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 5c             	sub    $0x5c,%esp
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 e4 04 00 00    	je     8007df <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	0f b6 06             	movzbl (%esi),%eax
  800308:	83 c6 01             	add    $0x1,%esi
  80030b:	83 f8 25             	cmp    $0x25,%eax
  80030e:	75 e3                	jne    8002f3 <vprintfmt+0x11>
  800310:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800314:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80031b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800320:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800327:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80032f:	eb 2b                	jmp    80035c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800338:	eb 22                	jmp    80035c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800341:	eb 19                	jmp    80035c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800346:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80034d:	eb 0d                	jmp    80035c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80034f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800352:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800355:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	0f b6 06             	movzbl (%esi),%eax
  80035f:	0f b6 d0             	movzbl %al,%edx
  800362:	8d 7e 01             	lea    0x1(%esi),%edi
  800365:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800368:	83 e8 23             	sub    $0x23,%eax
  80036b:	3c 55                	cmp    $0x55,%al
  80036d:	0f 87 46 04 00 00    	ja     8007b9 <vprintfmt+0x4d7>
  800373:	0f b6 c0             	movzbl %al,%eax
  800376:	ff 24 85 6c 11 80 00 	jmp    *0x80116c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037d:	83 ea 30             	sub    $0x30,%edx
  800380:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800383:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800387:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80038d:	83 fa 09             	cmp    $0x9,%edx
  800390:	77 4a                	ja     8003dc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800395:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800398:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80039b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80039f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a5:	83 fa 09             	cmp    $0x9,%edx
  8003a8:	76 eb                	jbe    800395 <vprintfmt+0xb3>
  8003aa:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003ad:	eb 2d                	jmp    8003dc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 50 04             	lea    0x4(%eax),%edx
  8003b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c0:	eb 1a                	jmp    8003dc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003c5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003c9:	79 91                	jns    80035c <vprintfmt+0x7a>
  8003cb:	e9 73 ff ff ff       	jmp    800343 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003da:	eb 80                	jmp    80035c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003dc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003e0:	0f 89 76 ff ff ff    	jns    80035c <vprintfmt+0x7a>
  8003e6:	e9 64 ff ff ff       	jmp    80034f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003eb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f1:	e9 66 ff ff ff       	jmp    80035c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 50 04             	lea    0x4(%eax),%edx
  8003fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040e:	e9 f2 fe ff ff       	jmp    800305 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800413:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800417:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80041a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80041e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800421:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800425:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800428:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80042b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80042f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800432:	80 f9 09             	cmp    $0x9,%cl
  800435:	77 1d                	ja     800454 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800437:	0f be c0             	movsbl %al,%eax
  80043a:	6b c0 64             	imul   $0x64,%eax,%eax
  80043d:	0f be d2             	movsbl %dl,%edx
  800440:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800443:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80044a:	a3 04 20 80 00       	mov    %eax,0x802004
  80044f:	e9 b1 fe ff ff       	jmp    800305 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800454:	c7 44 24 04 df 10 80 	movl   $0x8010df,0x4(%esp)
  80045b:	00 
  80045c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	e8 14 05 00 00       	call   80097b <strcmp>
  800467:	85 c0                	test   %eax,%eax
  800469:	75 0f                	jne    80047a <vprintfmt+0x198>
  80046b:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800472:	00 00 00 
  800475:	e9 8b fe ff ff       	jmp    800305 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80047a:	c7 44 24 04 e3 10 80 	movl   $0x8010e3,0x4(%esp)
  800481:	00 
  800482:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800485:	89 14 24             	mov    %edx,(%esp)
  800488:	e8 ee 04 00 00       	call   80097b <strcmp>
  80048d:	85 c0                	test   %eax,%eax
  80048f:	75 0f                	jne    8004a0 <vprintfmt+0x1be>
  800491:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800498:	00 00 00 
  80049b:	e9 65 fe ff ff       	jmp    800305 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004a0:	c7 44 24 04 e7 10 80 	movl   $0x8010e7,0x4(%esp)
  8004a7:	00 
  8004a8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004ab:	89 0c 24             	mov    %ecx,(%esp)
  8004ae:	e8 c8 04 00 00       	call   80097b <strcmp>
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	75 0f                	jne    8004c6 <vprintfmt+0x1e4>
  8004b7:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004be:	00 00 00 
  8004c1:	e9 3f fe ff ff       	jmp    800305 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004c6:	c7 44 24 04 eb 10 80 	movl   $0x8010eb,0x4(%esp)
  8004cd:	00 
  8004ce:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004d1:	89 3c 24             	mov    %edi,(%esp)
  8004d4:	e8 a2 04 00 00       	call   80097b <strcmp>
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	75 0f                	jne    8004ec <vprintfmt+0x20a>
  8004dd:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004e4:	00 00 00 
  8004e7:	e9 19 fe ff ff       	jmp    800305 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004ec:	c7 44 24 04 ef 10 80 	movl   $0x8010ef,0x4(%esp)
  8004f3:	00 
  8004f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	e8 7c 04 00 00       	call   80097b <strcmp>
  8004ff:	85 c0                	test   %eax,%eax
  800501:	75 0f                	jne    800512 <vprintfmt+0x230>
  800503:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80050a:	00 00 00 
  80050d:	e9 f3 fd ff ff       	jmp    800305 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800512:	c7 44 24 04 f3 10 80 	movl   $0x8010f3,0x4(%esp)
  800519:	00 
  80051a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80051d:	89 14 24             	mov    %edx,(%esp)
  800520:	e8 56 04 00 00       	call   80097b <strcmp>
  800525:	83 f8 01             	cmp    $0x1,%eax
  800528:	19 c0                	sbb    %eax,%eax
  80052a:	f7 d0                	not    %eax
  80052c:	83 c0 08             	add    $0x8,%eax
  80052f:	a3 04 20 80 00       	mov    %eax,0x802004
  800534:	e9 cc fd ff ff       	jmp    800305 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 c2                	mov    %eax,%edx
  800546:	c1 fa 1f             	sar    $0x1f,%edx
  800549:	31 d0                	xor    %edx,%eax
  80054b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054d:	83 f8 06             	cmp    $0x6,%eax
  800550:	7f 0b                	jg     80055d <vprintfmt+0x27b>
  800552:	8b 14 85 c4 12 80 00 	mov    0x8012c4(,%eax,4),%edx
  800559:	85 d2                	test   %edx,%edx
  80055b:	75 23                	jne    800580 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80055d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800561:	c7 44 24 08 f7 10 80 	movl   $0x8010f7,0x8(%esp)
  800568:	00 
  800569:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800570:	89 3c 24             	mov    %edi,(%esp)
  800573:	e8 42 fd ff ff       	call   8002ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057b:	e9 85 fd ff ff       	jmp    800305 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800580:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800584:	c7 44 24 08 00 11 80 	movl   $0x801100,0x8(%esp)
  80058b:	00 
  80058c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800590:	8b 7d 08             	mov    0x8(%ebp),%edi
  800593:	89 3c 24             	mov    %edi,(%esp)
  800596:	e8 1f fd ff ff       	call   8002ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80059e:	e9 62 fd ff ff       	jmp    800305 <vprintfmt+0x23>
  8005a3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	b8 d8 10 80 00       	mov    $0x8010d8,%eax
  8005be:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005c1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005c5:	7e 06                	jle    8005cd <vprintfmt+0x2eb>
  8005c7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005cb:	75 13                	jne    8005e0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cd:	0f be 06             	movsbl (%esi),%eax
  8005d0:	83 c6 01             	add    $0x1,%esi
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	0f 85 94 00 00 00    	jne    80066f <vprintfmt+0x38d>
  8005db:	e9 81 00 00 00       	jmp    800661 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e4:	89 34 24             	mov    %esi,(%esp)
  8005e7:	e8 9f 02 00 00       	call   80088b <strnlen>
  8005ec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ef:	29 c2                	sub    %eax,%edx
  8005f1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	7e d5                	jle    8005cd <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005f8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8005fc:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005ff:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800602:	89 d6                	mov    %edx,%esi
  800604:	89 cf                	mov    %ecx,%edi
  800606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060a:	89 3c 24             	mov    %edi,(%esp)
  80060d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800610:	83 ee 01             	sub    $0x1,%esi
  800613:	75 f1                	jne    800606 <vprintfmt+0x324>
  800615:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800618:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80061b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80061e:	eb ad                	jmp    8005cd <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800620:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800624:	74 1b                	je     800641 <vprintfmt+0x35f>
  800626:	8d 50 e0             	lea    -0x20(%eax),%edx
  800629:	83 fa 5e             	cmp    $0x5e,%edx
  80062c:	76 13                	jbe    800641 <vprintfmt+0x35f>
					putch('?', putdat);
  80062e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800631:	89 44 24 04          	mov    %eax,0x4(%esp)
  800635:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80063c:	ff 55 08             	call   *0x8(%ebp)
  80063f:	eb 0d                	jmp    80064e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800641:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800644:	89 54 24 04          	mov    %edx,0x4(%esp)
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064e:	83 eb 01             	sub    $0x1,%ebx
  800651:	0f be 06             	movsbl (%esi),%eax
  800654:	83 c6 01             	add    $0x1,%esi
  800657:	85 c0                	test   %eax,%eax
  800659:	75 1a                	jne    800675 <vprintfmt+0x393>
  80065b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80065e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800664:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800668:	7f 1c                	jg     800686 <vprintfmt+0x3a4>
  80066a:	e9 96 fc ff ff       	jmp    800305 <vprintfmt+0x23>
  80066f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800672:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	85 ff                	test   %edi,%edi
  800677:	78 a7                	js     800620 <vprintfmt+0x33e>
  800679:	83 ef 01             	sub    $0x1,%edi
  80067c:	79 a2                	jns    800620 <vprintfmt+0x33e>
  80067e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800681:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800684:	eb db                	jmp    800661 <vprintfmt+0x37f>
  800686:	8b 7d 08             	mov    0x8(%ebp),%edi
  800689:	89 de                	mov    %ebx,%esi
  80068b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800692:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800699:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069b:	83 eb 01             	sub    $0x1,%ebx
  80069e:	75 ee                	jne    80068e <vprintfmt+0x3ac>
  8006a0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006a5:	e9 5b fc ff ff       	jmp    800305 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006aa:	83 f9 01             	cmp    $0x1,%ecx
  8006ad:	7e 10                	jle    8006bf <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 08             	lea    0x8(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 30                	mov    (%eax),%esi
  8006ba:	8b 78 04             	mov    0x4(%eax),%edi
  8006bd:	eb 26                	jmp    8006e5 <vprintfmt+0x403>
	else if (lflag)
  8006bf:	85 c9                	test   %ecx,%ecx
  8006c1:	74 12                	je     8006d5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 04             	lea    0x4(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cc:	8b 30                	mov    (%eax),%esi
  8006ce:	89 f7                	mov    %esi,%edi
  8006d0:	c1 ff 1f             	sar    $0x1f,%edi
  8006d3:	eb 10                	jmp    8006e5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 30                	mov    (%eax),%esi
  8006e0:	89 f7                	mov    %esi,%edi
  8006e2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	85 ff                	test   %edi,%edi
  8006e7:	78 0e                	js     8006f7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e9:	89 f0                	mov    %esi,%eax
  8006eb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ed:	be 0a 00 00 00       	mov    $0xa,%esi
  8006f2:	e9 84 00 00 00       	jmp    80077b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800702:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800705:	89 f0                	mov    %esi,%eax
  800707:	89 fa                	mov    %edi,%edx
  800709:	f7 d8                	neg    %eax
  80070b:	83 d2 00             	adc    $0x0,%edx
  80070e:	f7 da                	neg    %edx
			}
			base = 10;
  800710:	be 0a 00 00 00       	mov    $0xa,%esi
  800715:	eb 64                	jmp    80077b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800717:	89 ca                	mov    %ecx,%edx
  800719:	8d 45 14             	lea    0x14(%ebp),%eax
  80071c:	e8 42 fb ff ff       	call   800263 <getuint>
			base = 10;
  800721:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800726:	eb 53                	jmp    80077b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800728:	89 ca                	mov    %ecx,%edx
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
  80072d:	e8 31 fb ff ff       	call   800263 <getuint>
    			base = 8;
  800732:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800737:	eb 42                	jmp    80077b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800739:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800744:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800752:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8d 50 04             	lea    0x4(%eax),%edx
  80075b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075e:	8b 00                	mov    (%eax),%eax
  800760:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800765:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80076a:	eb 0f                	jmp    80077b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076c:	89 ca                	mov    %ecx,%edx
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	e8 ed fa ff ff       	call   800263 <getuint>
			base = 16;
  800776:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80077f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800783:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800786:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80078a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	89 54 24 04          	mov    %edx,0x4(%esp)
  800795:	89 da                	mov    %ebx,%edx
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	e8 e9 f9 ff ff       	call   800188 <printnum>
			break;
  80079f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007a2:	e9 5e fb ff ff       	jmp    800305 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	89 14 24             	mov    %edx,(%esp)
  8007ae:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b4:	e9 4c fb ff ff       	jmp    800305 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007cb:	0f 84 34 fb ff ff    	je     800305 <vprintfmt+0x23>
  8007d1:	83 ee 01             	sub    $0x1,%esi
  8007d4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d8:	75 f7                	jne    8007d1 <vprintfmt+0x4ef>
  8007da:	e9 26 fb ff ff       	jmp    800305 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007df:	83 c4 5c             	add    $0x5c,%esp
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5f                   	pop    %edi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	83 ec 28             	sub    $0x28,%esp
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800804:	85 c0                	test   %eax,%eax
  800806:	74 30                	je     800838 <vsnprintf+0x51>
  800808:	85 d2                	test   %edx,%edx
  80080a:	7e 2c                	jle    800838 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800813:	8b 45 10             	mov    0x10(%ebp),%eax
  800816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	c7 04 24 9d 02 80 00 	movl   $0x80029d,(%esp)
  800828:	e8 b5 fa ff ff       	call   8002e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800830:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800836:	eb 05                	jmp    80083d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800838:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800848:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084c:	8b 45 10             	mov    0x10(%ebp),%eax
  80084f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
  800856:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	89 04 24             	mov    %eax,(%esp)
  800860:	e8 82 ff ff ff       	call   8007e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800865:	c9                   	leave  
  800866:	c3                   	ret    
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
  800d33:	c7 44 24 08 e0 12 80 	movl   $0x8012e0,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 fd 12 80 00 	movl   $0x8012fd,(%esp)
  800d4a:	e8 3d 00 00 00       	call   800d8c <_panic>

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

00800d8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d94:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d97:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d9d:	e8 ba ff ff ff       	call   800d5c <sys_getenvid>
  800da2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800db4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db8:	c7 04 24 0c 13 80 00 	movl   $0x80130c,(%esp)
  800dbf:	e8 a7 f3 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dcb:	89 04 24             	mov    %eax,(%esp)
  800dce:	e8 37 f3 ff ff       	call   80010a <vcprintf>
	cprintf("\n");
  800dd3:	c7 04 24 a4 10 80 00 	movl   $0x8010a4,(%esp)
  800dda:	e8 8c f3 ff ff       	call   80016b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ddf:	cc                   	int3   
  800de0:	eb fd                	jmp    800ddf <_panic+0x53>
	...

00800df0 <__udivdi3>:
  800df0:	83 ec 1c             	sub    $0x1c,%esp
  800df3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800df7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800dfb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800dff:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e03:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e07:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e0b:	85 ff                	test   %edi,%edi
  800e0d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800e11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e15:	89 cd                	mov    %ecx,%ebp
  800e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e1b:	75 33                	jne    800e50 <__udivdi3+0x60>
  800e1d:	39 f1                	cmp    %esi,%ecx
  800e1f:	77 57                	ja     800e78 <__udivdi3+0x88>
  800e21:	85 c9                	test   %ecx,%ecx
  800e23:	75 0b                	jne    800e30 <__udivdi3+0x40>
  800e25:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2a:	31 d2                	xor    %edx,%edx
  800e2c:	f7 f1                	div    %ecx
  800e2e:	89 c1                	mov    %eax,%ecx
  800e30:	89 f0                	mov    %esi,%eax
  800e32:	31 d2                	xor    %edx,%edx
  800e34:	f7 f1                	div    %ecx
  800e36:	89 c6                	mov    %eax,%esi
  800e38:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e3c:	f7 f1                	div    %ecx
  800e3e:	89 f2                	mov    %esi,%edx
  800e40:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e44:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e48:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e4c:	83 c4 1c             	add    $0x1c,%esp
  800e4f:	c3                   	ret    
  800e50:	31 d2                	xor    %edx,%edx
  800e52:	31 c0                	xor    %eax,%eax
  800e54:	39 f7                	cmp    %esi,%edi
  800e56:	77 e8                	ja     800e40 <__udivdi3+0x50>
  800e58:	0f bd cf             	bsr    %edi,%ecx
  800e5b:	83 f1 1f             	xor    $0x1f,%ecx
  800e5e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e62:	75 2c                	jne    800e90 <__udivdi3+0xa0>
  800e64:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800e68:	76 04                	jbe    800e6e <__udivdi3+0x7e>
  800e6a:	39 f7                	cmp    %esi,%edi
  800e6c:	73 d2                	jae    800e40 <__udivdi3+0x50>
  800e6e:	31 d2                	xor    %edx,%edx
  800e70:	b8 01 00 00 00       	mov    $0x1,%eax
  800e75:	eb c9                	jmp    800e40 <__udivdi3+0x50>
  800e77:	90                   	nop
  800e78:	89 f2                	mov    %esi,%edx
  800e7a:	f7 f1                	div    %ecx
  800e7c:	31 d2                	xor    %edx,%edx
  800e7e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e82:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e86:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	c3                   	ret    
  800e8e:	66 90                	xchg   %ax,%ax
  800e90:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e95:	b8 20 00 00 00       	mov    $0x20,%eax
  800e9a:	89 ea                	mov    %ebp,%edx
  800e9c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ea0:	d3 e7                	shl    %cl,%edi
  800ea2:	89 c1                	mov    %eax,%ecx
  800ea4:	d3 ea                	shr    %cl,%edx
  800ea6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eab:	09 fa                	or     %edi,%edx
  800ead:	89 f7                	mov    %esi,%edi
  800eaf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eb3:	89 f2                	mov    %esi,%edx
  800eb5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800eb9:	d3 e5                	shl    %cl,%ebp
  800ebb:	89 c1                	mov    %eax,%ecx
  800ebd:	d3 ef                	shr    %cl,%edi
  800ebf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ec4:	d3 e2                	shl    %cl,%edx
  800ec6:	89 c1                	mov    %eax,%ecx
  800ec8:	d3 ee                	shr    %cl,%esi
  800eca:	09 d6                	or     %edx,%esi
  800ecc:	89 fa                	mov    %edi,%edx
  800ece:	89 f0                	mov    %esi,%eax
  800ed0:	f7 74 24 0c          	divl   0xc(%esp)
  800ed4:	89 d7                	mov    %edx,%edi
  800ed6:	89 c6                	mov    %eax,%esi
  800ed8:	f7 e5                	mul    %ebp
  800eda:	39 d7                	cmp    %edx,%edi
  800edc:	72 22                	jb     800f00 <__udivdi3+0x110>
  800ede:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800ee2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ee7:	d3 e5                	shl    %cl,%ebp
  800ee9:	39 c5                	cmp    %eax,%ebp
  800eeb:	73 04                	jae    800ef1 <__udivdi3+0x101>
  800eed:	39 d7                	cmp    %edx,%edi
  800eef:	74 0f                	je     800f00 <__udivdi3+0x110>
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	e9 46 ff ff ff       	jmp    800e40 <__udivdi3+0x50>
  800efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f00:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f03:	31 d2                	xor    %edx,%edx
  800f05:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f09:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f0d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f11:	83 c4 1c             	add    $0x1c,%esp
  800f14:	c3                   	ret    
	...

00800f20 <__umoddi3>:
  800f20:	83 ec 1c             	sub    $0x1c,%esp
  800f23:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f27:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800f2b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f2f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f33:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f37:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f3b:	85 ed                	test   %ebp,%ebp
  800f3d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f45:	89 cf                	mov    %ecx,%edi
  800f47:	89 04 24             	mov    %eax,(%esp)
  800f4a:	89 f2                	mov    %esi,%edx
  800f4c:	75 1a                	jne    800f68 <__umoddi3+0x48>
  800f4e:	39 f1                	cmp    %esi,%ecx
  800f50:	76 4e                	jbe    800fa0 <__umoddi3+0x80>
  800f52:	f7 f1                	div    %ecx
  800f54:	89 d0                	mov    %edx,%eax
  800f56:	31 d2                	xor    %edx,%edx
  800f58:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f5c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f60:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f64:	83 c4 1c             	add    $0x1c,%esp
  800f67:	c3                   	ret    
  800f68:	39 f5                	cmp    %esi,%ebp
  800f6a:	77 54                	ja     800fc0 <__umoddi3+0xa0>
  800f6c:	0f bd c5             	bsr    %ebp,%eax
  800f6f:	83 f0 1f             	xor    $0x1f,%eax
  800f72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f76:	75 60                	jne    800fd8 <__umoddi3+0xb8>
  800f78:	3b 0c 24             	cmp    (%esp),%ecx
  800f7b:	0f 87 07 01 00 00    	ja     801088 <__umoddi3+0x168>
  800f81:	89 f2                	mov    %esi,%edx
  800f83:	8b 34 24             	mov    (%esp),%esi
  800f86:	29 ce                	sub    %ecx,%esi
  800f88:	19 ea                	sbb    %ebp,%edx
  800f8a:	89 34 24             	mov    %esi,(%esp)
  800f8d:	8b 04 24             	mov    (%esp),%eax
  800f90:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f94:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f98:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f9c:	83 c4 1c             	add    $0x1c,%esp
  800f9f:	c3                   	ret    
  800fa0:	85 c9                	test   %ecx,%ecx
  800fa2:	75 0b                	jne    800faf <__umoddi3+0x8f>
  800fa4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa9:	31 d2                	xor    %edx,%edx
  800fab:	f7 f1                	div    %ecx
  800fad:	89 c1                	mov    %eax,%ecx
  800faf:	89 f0                	mov    %esi,%eax
  800fb1:	31 d2                	xor    %edx,%edx
  800fb3:	f7 f1                	div    %ecx
  800fb5:	8b 04 24             	mov    (%esp),%eax
  800fb8:	f7 f1                	div    %ecx
  800fba:	eb 98                	jmp    800f54 <__umoddi3+0x34>
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fca:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fce:	83 c4 1c             	add    $0x1c,%esp
  800fd1:	c3                   	ret    
  800fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fdd:	89 e8                	mov    %ebp,%eax
  800fdf:	bd 20 00 00 00       	mov    $0x20,%ebp
  800fe4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800fe8:	89 fa                	mov    %edi,%edx
  800fea:	d3 e0                	shl    %cl,%eax
  800fec:	89 e9                	mov    %ebp,%ecx
  800fee:	d3 ea                	shr    %cl,%edx
  800ff0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff5:	09 c2                	or     %eax,%edx
  800ff7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ffb:	89 14 24             	mov    %edx,(%esp)
  800ffe:	89 f2                	mov    %esi,%edx
  801000:	d3 e7                	shl    %cl,%edi
  801002:	89 e9                	mov    %ebp,%ecx
  801004:	d3 ea                	shr    %cl,%edx
  801006:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80100f:	d3 e6                	shl    %cl,%esi
  801011:	89 e9                	mov    %ebp,%ecx
  801013:	d3 e8                	shr    %cl,%eax
  801015:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101a:	09 f0                	or     %esi,%eax
  80101c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801020:	f7 34 24             	divl   (%esp)
  801023:	d3 e6                	shl    %cl,%esi
  801025:	89 74 24 08          	mov    %esi,0x8(%esp)
  801029:	89 d6                	mov    %edx,%esi
  80102b:	f7 e7                	mul    %edi
  80102d:	39 d6                	cmp    %edx,%esi
  80102f:	89 c1                	mov    %eax,%ecx
  801031:	89 d7                	mov    %edx,%edi
  801033:	72 3f                	jb     801074 <__umoddi3+0x154>
  801035:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801039:	72 35                	jb     801070 <__umoddi3+0x150>
  80103b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80103f:	29 c8                	sub    %ecx,%eax
  801041:	19 fe                	sbb    %edi,%esi
  801043:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801048:	89 f2                	mov    %esi,%edx
  80104a:	d3 e8                	shr    %cl,%eax
  80104c:	89 e9                	mov    %ebp,%ecx
  80104e:	d3 e2                	shl    %cl,%edx
  801050:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801055:	09 d0                	or     %edx,%eax
  801057:	89 f2                	mov    %esi,%edx
  801059:	d3 ea                	shr    %cl,%edx
  80105b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80105f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801063:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801067:	83 c4 1c             	add    $0x1c,%esp
  80106a:	c3                   	ret    
  80106b:	90                   	nop
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	39 d6                	cmp    %edx,%esi
  801072:	75 c7                	jne    80103b <__umoddi3+0x11b>
  801074:	89 d7                	mov    %edx,%edi
  801076:	89 c1                	mov    %eax,%ecx
  801078:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80107c:	1b 3c 24             	sbb    (%esp),%edi
  80107f:	eb ba                	jmp    80103b <__umoddi3+0x11b>
  801081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801088:	39 f5                	cmp    %esi,%ebp
  80108a:	0f 82 f1 fe ff ff    	jb     800f81 <__umoddi3+0x61>
  801090:	e9 f8 fe ff ff       	jmp    800f8d <__umoddi3+0x6d>
