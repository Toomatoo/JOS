
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 68 10 80 00 	movl   $0x801068,(%esp)
  80004a:	e8 f4 00 00 00       	call   800143 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 31 0c 00 00       	call   800ccf <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 14             	sub    $0x14,%esp
  8000a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000b3:	83 c0 01             	add    $0x1,%eax
  8000b6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000bd:	75 19                	jne    8000d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000c6:	00 
  8000c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ca:	89 04 24             	mov    %eax,(%esp)
  8000cd:	e8 9e 0b 00 00       	call   800c70 <sys_cputs>
		b->idx = 0;
  8000d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000dc:	83 c4 14             	add    $0x14,%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f2:	00 00 00 
	b.cnt = 0;
  8000f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 45 08             	mov    0x8(%ebp),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	c7 04 24 a0 00 80 00 	movl   $0x8000a0,(%esp)
  80011e:	e8 97 01 00 00       	call   8002ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800123:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	89 04 24             	mov    %eax,(%esp)
  800136:	e8 35 0b 00 00       	call   800c70 <sys_cputs>

	return b.cnt;
}
  80013b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800149:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	e8 87 ff ff ff       	call   8000e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    
  80015d:	00 00                	add    %al,(%eax)
	...

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 3c             	sub    $0x3c,%esp
  800169:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80016c:	89 d7                	mov    %edx,%edi
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80017a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80017d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	b8 00 00 00 00       	mov    $0x0,%eax
  800185:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800188:	72 11                	jb     80019b <printnum+0x3b>
  80018a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80018d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800190:	76 09                	jbe    80019b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800192:	83 eb 01             	sub    $0x1,%ebx
  800195:	85 db                	test   %ebx,%ebx
  800197:	7f 51                	jg     8001ea <printnum+0x8a>
  800199:	eb 5e                	jmp    8001f9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80019f:	83 eb 01             	sub    $0x1,%ebx
  8001a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ad:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001b1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bc:	00 
  8001bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ca:	e8 f1 0b 00 00       	call   800dc0 <__udivdi3>
  8001cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001de:	89 fa                	mov    %edi,%edx
  8001e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001e3:	e8 78 ff ff ff       	call   800160 <printnum>
  8001e8:	eb 0f                	jmp    8001f9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001ee:	89 34 24             	mov    %esi,(%esp)
  8001f1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f4:	83 eb 01             	sub    $0x1,%ebx
  8001f7:	75 f1                	jne    8001ea <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800201:	8b 45 10             	mov    0x10(%ebp),%eax
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020f:	00 
  800210:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021d:	e8 ce 0c 00 00       	call   800ef0 <__umoddi3>
  800222:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800226:	0f be 80 90 10 80 00 	movsbl 0x801090(%eax),%eax
  80022d:	89 04 24             	mov    %eax,(%esp)
  800230:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800233:	83 c4 3c             	add    $0x3c,%esp
  800236:	5b                   	pop    %ebx
  800237:	5e                   	pop    %esi
  800238:	5f                   	pop    %edi
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023e:	83 fa 01             	cmp    $0x1,%edx
  800241:	7e 0e                	jle    800251 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800243:	8b 10                	mov    (%eax),%edx
  800245:	8d 4a 08             	lea    0x8(%edx),%ecx
  800248:	89 08                	mov    %ecx,(%eax)
  80024a:	8b 02                	mov    (%edx),%eax
  80024c:	8b 52 04             	mov    0x4(%edx),%edx
  80024f:	eb 22                	jmp    800273 <getuint+0x38>
	else if (lflag)
  800251:	85 d2                	test   %edx,%edx
  800253:	74 10                	je     800265 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800255:	8b 10                	mov    (%eax),%edx
  800257:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 02                	mov    (%edx),%eax
  80025e:	ba 00 00 00 00       	mov    $0x0,%edx
  800263:	eb 0e                	jmp    800273 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800265:	8b 10                	mov    (%eax),%edx
  800267:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 02                	mov    (%edx),%eax
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	3b 50 04             	cmp    0x4(%eax),%edx
  800284:	73 0a                	jae    800290 <sprintputch+0x1b>
		*b->buf++ = ch;
  800286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800289:	88 0a                	mov    %cl,(%edx)
  80028b:	83 c2 01             	add    $0x1,%edx
  80028e:	89 10                	mov    %edx,(%eax)
}
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800298:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029f:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 02 00 00 00       	call   8002ba <vprintfmt>
	va_end(ap);
}
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 5c             	sub    $0x5c,%esp
  8002c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002c9:	eb 12                	jmp    8002dd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	0f 84 e4 04 00 00    	je     8007b7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002dd:	0f b6 06             	movzbl (%esi),%eax
  8002e0:	83 c6 01             	add    $0x1,%esi
  8002e3:	83 f8 25             	cmp    $0x25,%eax
  8002e6:	75 e3                	jne    8002cb <vprintfmt+0x11>
  8002e8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8002ec:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002f3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002f8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800304:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800307:	eb 2b                	jmp    800334 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800310:	eb 22                	jmp    800334 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800315:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800319:	eb 19                	jmp    800334 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80031e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800325:	eb 0d                	jmp    800334 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800327:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80032a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80032d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	0f b6 06             	movzbl (%esi),%eax
  800337:	0f b6 d0             	movzbl %al,%edx
  80033a:	8d 7e 01             	lea    0x1(%esi),%edi
  80033d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800340:	83 e8 23             	sub    $0x23,%eax
  800343:	3c 55                	cmp    $0x55,%al
  800345:	0f 87 46 04 00 00    	ja     800791 <vprintfmt+0x4d7>
  80034b:	0f b6 c0             	movzbl %al,%eax
  80034e:	ff 24 85 38 11 80 00 	jmp    *0x801138(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800355:	83 ea 30             	sub    $0x30,%edx
  800358:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80035b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80035f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800365:	83 fa 09             	cmp    $0x9,%edx
  800368:	77 4a                	ja     8003b4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800370:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800373:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800377:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80037a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80037d:	83 fa 09             	cmp    $0x9,%edx
  800380:	76 eb                	jbe    80036d <vprintfmt+0xb3>
  800382:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800385:	eb 2d                	jmp    8003b4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800387:	8b 45 14             	mov    0x14(%ebp),%eax
  80038a:	8d 50 04             	lea    0x4(%eax),%edx
  80038d:	89 55 14             	mov    %edx,0x14(%ebp)
  800390:	8b 00                	mov    (%eax),%eax
  800392:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800398:	eb 1a                	jmp    8003b4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80039d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003a1:	79 91                	jns    800334 <vprintfmt+0x7a>
  8003a3:	e9 73 ff ff ff       	jmp    80031b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ab:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003b2:	eb 80                	jmp    800334 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003b4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003b8:	0f 89 76 ff ff ff    	jns    800334 <vprintfmt+0x7a>
  8003be:	e9 64 ff ff ff       	jmp    800327 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c9:	e9 66 ff ff ff       	jmp    800334 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 50 04             	lea    0x4(%eax),%edx
  8003d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	89 04 24             	mov    %eax,(%esp)
  8003e0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e6:	e9 f2 fe ff ff       	jmp    8002dd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8003eb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8003ef:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8003f2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8003f6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8003f9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8003fd:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800400:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800403:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800407:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80040a:	80 f9 09             	cmp    $0x9,%cl
  80040d:	77 1d                	ja     80042c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80040f:	0f be c0             	movsbl %al,%eax
  800412:	6b c0 64             	imul   $0x64,%eax,%eax
  800415:	0f be d2             	movsbl %dl,%edx
  800418:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80041b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800422:	a3 04 20 80 00       	mov    %eax,0x802004
  800427:	e9 b1 fe ff ff       	jmp    8002dd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80042c:	c7 44 24 04 a8 10 80 	movl   $0x8010a8,0x4(%esp)
  800433:	00 
  800434:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	e8 0c 05 00 00       	call   80094b <strcmp>
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 0f                	jne    800452 <vprintfmt+0x198>
  800443:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80044a:	00 00 00 
  80044d:	e9 8b fe ff ff       	jmp    8002dd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800452:	c7 44 24 04 ac 10 80 	movl   $0x8010ac,0x4(%esp)
  800459:	00 
  80045a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80045d:	89 14 24             	mov    %edx,(%esp)
  800460:	e8 e6 04 00 00       	call   80094b <strcmp>
  800465:	85 c0                	test   %eax,%eax
  800467:	75 0f                	jne    800478 <vprintfmt+0x1be>
  800469:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800470:	00 00 00 
  800473:	e9 65 fe ff ff       	jmp    8002dd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800478:	c7 44 24 04 b0 10 80 	movl   $0x8010b0,0x4(%esp)
  80047f:	00 
  800480:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800483:	89 0c 24             	mov    %ecx,(%esp)
  800486:	e8 c0 04 00 00       	call   80094b <strcmp>
  80048b:	85 c0                	test   %eax,%eax
  80048d:	75 0f                	jne    80049e <vprintfmt+0x1e4>
  80048f:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800496:	00 00 00 
  800499:	e9 3f fe ff ff       	jmp    8002dd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80049e:	c7 44 24 04 b4 10 80 	movl   $0x8010b4,0x4(%esp)
  8004a5:	00 
  8004a6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004a9:	89 3c 24             	mov    %edi,(%esp)
  8004ac:	e8 9a 04 00 00       	call   80094b <strcmp>
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	75 0f                	jne    8004c4 <vprintfmt+0x20a>
  8004b5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004bc:	00 00 00 
  8004bf:	e9 19 fe ff ff       	jmp    8002dd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004c4:	c7 44 24 04 b8 10 80 	movl   $0x8010b8,0x4(%esp)
  8004cb:	00 
  8004cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004cf:	89 04 24             	mov    %eax,(%esp)
  8004d2:	e8 74 04 00 00       	call   80094b <strcmp>
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	75 0f                	jne    8004ea <vprintfmt+0x230>
  8004db:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8004e2:	00 00 00 
  8004e5:	e9 f3 fd ff ff       	jmp    8002dd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8004ea:	c7 44 24 04 bc 10 80 	movl   $0x8010bc,0x4(%esp)
  8004f1:	00 
  8004f2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004f5:	89 14 24             	mov    %edx,(%esp)
  8004f8:	e8 4e 04 00 00       	call   80094b <strcmp>
  8004fd:	83 f8 01             	cmp    $0x1,%eax
  800500:	19 c0                	sbb    %eax,%eax
  800502:	f7 d0                	not    %eax
  800504:	83 c0 08             	add    $0x8,%eax
  800507:	a3 04 20 80 00       	mov    %eax,0x802004
  80050c:	e9 cc fd ff ff       	jmp    8002dd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 c2                	mov    %eax,%edx
  80051e:	c1 fa 1f             	sar    $0x1f,%edx
  800521:	31 d0                	xor    %edx,%eax
  800523:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800525:	83 f8 06             	cmp    $0x6,%eax
  800528:	7f 0b                	jg     800535 <vprintfmt+0x27b>
  80052a:	8b 14 85 90 12 80 00 	mov    0x801290(,%eax,4),%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	75 23                	jne    800558 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800535:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800539:	c7 44 24 08 c0 10 80 	movl   $0x8010c0,0x8(%esp)
  800540:	00 
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	8b 7d 08             	mov    0x8(%ebp),%edi
  800548:	89 3c 24             	mov    %edi,(%esp)
  80054b:	e8 42 fd ff ff       	call   800292 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800553:	e9 85 fd ff ff       	jmp    8002dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800558:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055c:	c7 44 24 08 c9 10 80 	movl   $0x8010c9,0x8(%esp)
  800563:	00 
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056b:	89 3c 24             	mov    %edi,(%esp)
  80056e:	e8 1f fd ff ff       	call   800292 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800576:	e9 62 fd ff ff       	jmp    8002dd <vprintfmt+0x23>
  80057b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80057e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800581:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 50 04             	lea    0x4(%eax),%edx
  80058a:	89 55 14             	mov    %edx,0x14(%ebp)
  80058d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80058f:	85 f6                	test   %esi,%esi
  800591:	b8 a1 10 80 00       	mov    $0x8010a1,%eax
  800596:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800599:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80059d:	7e 06                	jle    8005a5 <vprintfmt+0x2eb>
  80059f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005a3:	75 13                	jne    8005b8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	0f be 06             	movsbl (%esi),%eax
  8005a8:	83 c6 01             	add    $0x1,%esi
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	0f 85 94 00 00 00    	jne    800647 <vprintfmt+0x38d>
  8005b3:	e9 81 00 00 00       	jmp    800639 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bc:	89 34 24             	mov    %esi,(%esp)
  8005bf:	e8 97 02 00 00       	call   80085b <strnlen>
  8005c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005c7:	29 c2                	sub    %eax,%edx
  8005c9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	7e d5                	jle    8005a5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005d0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8005d4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005d7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8005da:	89 d6                	mov    %edx,%esi
  8005dc:	89 cf                	mov    %ecx,%edi
  8005de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e2:	89 3c 24             	mov    %edi,(%esp)
  8005e5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e8:	83 ee 01             	sub    $0x1,%esi
  8005eb:	75 f1                	jne    8005de <vprintfmt+0x324>
  8005ed:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8005f0:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8005f3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8005f6:	eb ad                	jmp    8005a5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005fc:	74 1b                	je     800619 <vprintfmt+0x35f>
  8005fe:	8d 50 e0             	lea    -0x20(%eax),%edx
  800601:	83 fa 5e             	cmp    $0x5e,%edx
  800604:	76 13                	jbe    800619 <vprintfmt+0x35f>
					putch('?', putdat);
  800606:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800614:	ff 55 08             	call   *0x8(%ebp)
  800617:	eb 0d                	jmp    800626 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800619:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80061c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800626:	83 eb 01             	sub    $0x1,%ebx
  800629:	0f be 06             	movsbl (%esi),%eax
  80062c:	83 c6 01             	add    $0x1,%esi
  80062f:	85 c0                	test   %eax,%eax
  800631:	75 1a                	jne    80064d <vprintfmt+0x393>
  800633:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800636:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800640:	7f 1c                	jg     80065e <vprintfmt+0x3a4>
  800642:	e9 96 fc ff ff       	jmp    8002dd <vprintfmt+0x23>
  800647:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80064a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064d:	85 ff                	test   %edi,%edi
  80064f:	78 a7                	js     8005f8 <vprintfmt+0x33e>
  800651:	83 ef 01             	sub    $0x1,%edi
  800654:	79 a2                	jns    8005f8 <vprintfmt+0x33e>
  800656:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800659:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80065c:	eb db                	jmp    800639 <vprintfmt+0x37f>
  80065e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800661:	89 de                	mov    %ebx,%esi
  800663:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800666:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800671:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800673:	83 eb 01             	sub    $0x1,%ebx
  800676:	75 ee                	jne    800666 <vprintfmt+0x3ac>
  800678:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80067d:	e9 5b fc ff ff       	jmp    8002dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800682:	83 f9 01             	cmp    $0x1,%ecx
  800685:	7e 10                	jle    800697 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 08             	lea    0x8(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
  800690:	8b 30                	mov    (%eax),%esi
  800692:	8b 78 04             	mov    0x4(%eax),%edi
  800695:	eb 26                	jmp    8006bd <vprintfmt+0x403>
	else if (lflag)
  800697:	85 c9                	test   %ecx,%ecx
  800699:	74 12                	je     8006ad <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8d 50 04             	lea    0x4(%eax),%edx
  8006a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a4:	8b 30                	mov    (%eax),%esi
  8006a6:	89 f7                	mov    %esi,%edi
  8006a8:	c1 ff 1f             	sar    $0x1f,%edi
  8006ab:	eb 10                	jmp    8006bd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b6:	8b 30                	mov    (%eax),%esi
  8006b8:	89 f7                	mov    %esi,%edi
  8006ba:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006bd:	85 ff                	test   %edi,%edi
  8006bf:	78 0e                	js     8006cf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c1:	89 f0                	mov    %esi,%eax
  8006c3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c5:	be 0a 00 00 00       	mov    $0xa,%esi
  8006ca:	e9 84 00 00 00       	jmp    800753 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006da:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	89 fa                	mov    %edi,%edx
  8006e1:	f7 d8                	neg    %eax
  8006e3:	83 d2 00             	adc    $0x0,%edx
  8006e6:	f7 da                	neg    %edx
			}
			base = 10;
  8006e8:	be 0a 00 00 00       	mov    $0xa,%esi
  8006ed:	eb 64                	jmp    800753 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ef:	89 ca                	mov    %ecx,%edx
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	e8 42 fb ff ff       	call   80023b <getuint>
			base = 10;
  8006f9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8006fe:	eb 53                	jmp    800753 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800700:	89 ca                	mov    %ecx,%edx
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
  800705:	e8 31 fb ff ff       	call   80023b <getuint>
    			base = 8;
  80070a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80070f:	eb 42                	jmp    800753 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800715:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800723:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8d 50 04             	lea    0x4(%eax),%edx
  800733:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800736:	8b 00                	mov    (%eax),%eax
  800738:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800742:	eb 0f                	jmp    800753 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 ed fa ff ff       	call   80023b <getuint>
			base = 16;
  80074e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800753:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800757:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80075b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80075e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800762:	89 74 24 08          	mov    %esi,0x8(%esp)
  800766:	89 04 24             	mov    %eax,(%esp)
  800769:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076d:	89 da                	mov    %ebx,%edx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	e8 e9 f9 ff ff       	call   800160 <printnum>
			break;
  800777:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80077a:	e9 5e fb ff ff       	jmp    8002dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800783:	89 14 24             	mov    %edx,(%esp)
  800786:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800789:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078c:	e9 4c fb ff ff       	jmp    8002dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800791:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800795:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80079c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007a3:	0f 84 34 fb ff ff    	je     8002dd <vprintfmt+0x23>
  8007a9:	83 ee 01             	sub    $0x1,%esi
  8007ac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007b0:	75 f7                	jne    8007a9 <vprintfmt+0x4ef>
  8007b2:	e9 26 fb ff ff       	jmp    8002dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007b7:	83 c4 5c             	add    $0x5c,%esp
  8007ba:	5b                   	pop    %ebx
  8007bb:	5e                   	pop    %esi
  8007bc:	5f                   	pop    %edi
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	83 ec 28             	sub    $0x28,%esp
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	74 30                	je     800810 <vsnprintf+0x51>
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	7e 2c                	jle    800810 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f9:	c7 04 24 75 02 80 00 	movl   $0x800275,(%esp)
  800800:	e8 b5 fa ff ff       	call   8002ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800805:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800808:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080e:	eb 05                	jmp    800815 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800810:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800820:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800824:	8b 45 10             	mov    0x10(%ebp),%eax
  800827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	89 04 24             	mov    %eax,(%esp)
  800838:	e8 82 ff ff ff       	call   8007bf <vsnprintf>
	va_end(ap);

	return rc;
}
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    
	...

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	80 3a 00             	cmpb   $0x0,(%edx)
  80084e:	74 09                	je     800859 <strlen+0x19>
		n++;
  800850:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800853:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800857:	75 f7                	jne    800850 <strlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
  80086a:	85 c9                	test   %ecx,%ecx
  80086c:	74 1a                	je     800888 <strnlen+0x2d>
  80086e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800871:	74 15                	je     800888 <strnlen+0x2d>
  800873:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800878:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087a:	39 ca                	cmp    %ecx,%edx
  80087c:	74 0a                	je     800888 <strnlen+0x2d>
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800886:	75 f0                	jne    800878 <strnlen+0x1d>
		n++;
	return n;
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800895:	ba 00 00 00 00       	mov    $0x0,%edx
  80089a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	75 f2                	jne    80089a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b5:	89 1c 24             	mov    %ebx,(%esp)
  8008b8:	e8 83 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c4:	01 d8                	add    %ebx,%eax
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	e8 bd ff ff ff       	call   80088b <strcpy>
	return dst;
}
  8008ce:	89 d8                	mov    %ebx,%eax
  8008d0:	83 c4 08             	add    $0x8,%esp
  8008d3:	5b                   	pop    %ebx
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e4:	85 f6                	test   %esi,%esi
  8008e6:	74 18                	je     800900 <strncpy+0x2a>
  8008e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008ed:	0f b6 1a             	movzbl (%edx),%ebx
  8008f0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	83 c1 01             	add    $0x1,%ecx
  8008fc:	39 f1                	cmp    %esi,%ecx
  8008fe:	75 ed                	jne    8008ed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800910:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	89 f8                	mov    %edi,%eax
  800915:	85 f6                	test   %esi,%esi
  800917:	74 2b                	je     800944 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800919:	83 fe 01             	cmp    $0x1,%esi
  80091c:	74 23                	je     800941 <strlcpy+0x3d>
  80091e:	0f b6 0b             	movzbl (%ebx),%ecx
  800921:	84 c9                	test   %cl,%cl
  800923:	74 1c                	je     800941 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800925:	83 ee 02             	sub    $0x2,%esi
  800928:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092d:	88 08                	mov    %cl,(%eax)
  80092f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800932:	39 f2                	cmp    %esi,%edx
  800934:	74 0b                	je     800941 <strlcpy+0x3d>
  800936:	83 c2 01             	add    $0x1,%edx
  800939:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80093d:	84 c9                	test   %cl,%cl
  80093f:	75 ec                	jne    80092d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800941:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800944:	29 f8                	sub    %edi,%eax
}
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800954:	0f b6 01             	movzbl (%ecx),%eax
  800957:	84 c0                	test   %al,%al
  800959:	74 16                	je     800971 <strcmp+0x26>
  80095b:	3a 02                	cmp    (%edx),%al
  80095d:	75 12                	jne    800971 <strcmp+0x26>
		p++, q++;
  80095f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800962:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800966:	84 c0                	test   %al,%al
  800968:	74 07                	je     800971 <strcmp+0x26>
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	3a 02                	cmp    (%edx),%al
  80096f:	74 ee                	je     80095f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800971:	0f b6 c0             	movzbl %al,%eax
  800974:	0f b6 12             	movzbl (%edx),%edx
  800977:	29 d0                	sub    %edx,%eax
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800985:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098d:	85 d2                	test   %edx,%edx
  80098f:	74 28                	je     8009b9 <strncmp+0x3e>
  800991:	0f b6 01             	movzbl (%ecx),%eax
  800994:	84 c0                	test   %al,%al
  800996:	74 24                	je     8009bc <strncmp+0x41>
  800998:	3a 03                	cmp    (%ebx),%al
  80099a:	75 20                	jne    8009bc <strncmp+0x41>
  80099c:	83 ea 01             	sub    $0x1,%edx
  80099f:	74 13                	je     8009b4 <strncmp+0x39>
		n--, p++, q++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 0e                	je     8009bc <strncmp+0x41>
  8009ae:	3a 03                	cmp    (%ebx),%al
  8009b0:	74 ea                	je     80099c <strncmp+0x21>
  8009b2:	eb 08                	jmp    8009bc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bc:	0f b6 01             	movzbl (%ecx),%eax
  8009bf:	0f b6 13             	movzbl (%ebx),%edx
  8009c2:	29 d0                	sub    %edx,%eax
  8009c4:	eb f3                	jmp    8009b9 <strncmp+0x3e>

008009c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d0:	0f b6 10             	movzbl (%eax),%edx
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	74 1c                	je     8009f3 <strchr+0x2d>
		if (*s == c)
  8009d7:	38 ca                	cmp    %cl,%dl
  8009d9:	75 09                	jne    8009e4 <strchr+0x1e>
  8009db:	eb 1b                	jmp    8009f8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009dd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009e0:	38 ca                	cmp    %cl,%dl
  8009e2:	74 14                	je     8009f8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	75 f1                	jne    8009dd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 05                	jmp    8009f8 <strchr+0x32>
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	0f b6 10             	movzbl (%eax),%edx
  800a07:	84 d2                	test   %dl,%dl
  800a09:	74 14                	je     800a1f <strfind+0x25>
		if (*s == c)
  800a0b:	38 ca                	cmp    %cl,%dl
  800a0d:	75 06                	jne    800a15 <strfind+0x1b>
  800a0f:	eb 0e                	jmp    800a1f <strfind+0x25>
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 0a                	je     800a1f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	84 d2                	test   %dl,%dl
  800a1d:	75 f2                	jne    800a11 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a2a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a2d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a39:	85 c9                	test   %ecx,%ecx
  800a3b:	74 30                	je     800a6d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a43:	75 25                	jne    800a6a <memset+0x49>
  800a45:	f6 c1 03             	test   $0x3,%cl
  800a48:	75 20                	jne    800a6a <memset+0x49>
		c &= 0xFF;
  800a4a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4d:	89 d3                	mov    %edx,%ebx
  800a4f:	c1 e3 08             	shl    $0x8,%ebx
  800a52:	89 d6                	mov    %edx,%esi
  800a54:	c1 e6 18             	shl    $0x18,%esi
  800a57:	89 d0                	mov    %edx,%eax
  800a59:	c1 e0 10             	shl    $0x10,%eax
  800a5c:	09 f0                	or     %esi,%eax
  800a5e:	09 d0                	or     %edx,%eax
  800a60:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a62:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a65:	fc                   	cld    
  800a66:	f3 ab                	rep stos %eax,%es:(%edi)
  800a68:	eb 03                	jmp    800a6d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6a:	fc                   	cld    
  800a6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6d:	89 f8                	mov    %edi,%eax
  800a6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a78:	89 ec                	mov    %ebp,%esp
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 08             	sub    $0x8,%esp
  800a82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a85:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a91:	39 c6                	cmp    %eax,%esi
  800a93:	73 36                	jae    800acb <memmove+0x4f>
  800a95:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a98:	39 d0                	cmp    %edx,%eax
  800a9a:	73 2f                	jae    800acb <memmove+0x4f>
		s += n;
		d += n;
  800a9c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9f:	f6 c2 03             	test   $0x3,%dl
  800aa2:	75 1b                	jne    800abf <memmove+0x43>
  800aa4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaa:	75 13                	jne    800abf <memmove+0x43>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 0e                	jne    800abf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab1:	83 ef 04             	sub    $0x4,%edi
  800ab4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aba:	fd                   	std    
  800abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abd:	eb 09                	jmp    800ac8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800abf:	83 ef 01             	sub    $0x1,%edi
  800ac2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac5:	fd                   	std    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac8:	fc                   	cld    
  800ac9:	eb 20                	jmp    800aeb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad1:	75 13                	jne    800ae6 <memmove+0x6a>
  800ad3:	a8 03                	test   $0x3,%al
  800ad5:	75 0f                	jne    800ae6 <memmove+0x6a>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 0a                	jne    800ae6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb 05                	jmp    800aeb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	fc                   	cld    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aeb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800af1:	89 ec                	mov    %ebp,%esp
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800afb:	8b 45 10             	mov    0x10(%ebp),%eax
  800afe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	89 04 24             	mov    %eax,(%esp)
  800b0f:	e8 68 ff ff ff       	call   800a7c <memmove>
}
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    

00800b16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b22:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2a:	85 ff                	test   %edi,%edi
  800b2c:	74 37                	je     800b65 <memcmp+0x4f>
		if (*s1 != *s2)
  800b2e:	0f b6 03             	movzbl (%ebx),%eax
  800b31:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b34:	83 ef 01             	sub    $0x1,%edi
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b3c:	38 c8                	cmp    %cl,%al
  800b3e:	74 1c                	je     800b5c <memcmp+0x46>
  800b40:	eb 10                	jmp    800b52 <memcmp+0x3c>
  800b42:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b47:	83 c2 01             	add    $0x1,%edx
  800b4a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b4e:	38 c8                	cmp    %cl,%al
  800b50:	74 0a                	je     800b5c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b52:	0f b6 c0             	movzbl %al,%eax
  800b55:	0f b6 c9             	movzbl %cl,%ecx
  800b58:	29 c8                	sub    %ecx,%eax
  800b5a:	eb 09                	jmp    800b65 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5c:	39 fa                	cmp    %edi,%edx
  800b5e:	75 e2                	jne    800b42 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b75:	39 d0                	cmp    %edx,%eax
  800b77:	73 19                	jae    800b92 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b7d:	38 08                	cmp    %cl,(%eax)
  800b7f:	75 06                	jne    800b87 <memfind+0x1d>
  800b81:	eb 0f                	jmp    800b92 <memfind+0x28>
  800b83:	38 08                	cmp    %cl,(%eax)
  800b85:	74 0b                	je     800b92 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b87:	83 c0 01             	add    $0x1,%eax
  800b8a:	39 d0                	cmp    %edx,%eax
  800b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b90:	75 f1                	jne    800b83 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba0:	0f b6 02             	movzbl (%edx),%eax
  800ba3:	3c 20                	cmp    $0x20,%al
  800ba5:	74 04                	je     800bab <strtol+0x17>
  800ba7:	3c 09                	cmp    $0x9,%al
  800ba9:	75 0e                	jne    800bb9 <strtol+0x25>
		s++;
  800bab:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bae:	0f b6 02             	movzbl (%edx),%eax
  800bb1:	3c 20                	cmp    $0x20,%al
  800bb3:	74 f6                	je     800bab <strtol+0x17>
  800bb5:	3c 09                	cmp    $0x9,%al
  800bb7:	74 f2                	je     800bab <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bb9:	3c 2b                	cmp    $0x2b,%al
  800bbb:	75 0a                	jne    800bc7 <strtol+0x33>
		s++;
  800bbd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc5:	eb 10                	jmp    800bd7 <strtol+0x43>
  800bc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bcc:	3c 2d                	cmp    $0x2d,%al
  800bce:	75 07                	jne    800bd7 <strtol+0x43>
		s++, neg = 1;
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd7:	85 db                	test   %ebx,%ebx
  800bd9:	0f 94 c0             	sete   %al
  800bdc:	74 05                	je     800be3 <strtol+0x4f>
  800bde:	83 fb 10             	cmp    $0x10,%ebx
  800be1:	75 15                	jne    800bf8 <strtol+0x64>
  800be3:	80 3a 30             	cmpb   $0x30,(%edx)
  800be6:	75 10                	jne    800bf8 <strtol+0x64>
  800be8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bec:	75 0a                	jne    800bf8 <strtol+0x64>
		s += 2, base = 16;
  800bee:	83 c2 02             	add    $0x2,%edx
  800bf1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bf6:	eb 13                	jmp    800c0b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bf8:	84 c0                	test   %al,%al
  800bfa:	74 0f                	je     800c0b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bfc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c01:	80 3a 30             	cmpb   $0x30,(%edx)
  800c04:	75 05                	jne    800c0b <strtol+0x77>
		s++, base = 8;
  800c06:	83 c2 01             	add    $0x1,%edx
  800c09:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c10:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c12:	0f b6 0a             	movzbl (%edx),%ecx
  800c15:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c18:	80 fb 09             	cmp    $0x9,%bl
  800c1b:	77 08                	ja     800c25 <strtol+0x91>
			dig = *s - '0';
  800c1d:	0f be c9             	movsbl %cl,%ecx
  800c20:	83 e9 30             	sub    $0x30,%ecx
  800c23:	eb 1e                	jmp    800c43 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c25:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c28:	80 fb 19             	cmp    $0x19,%bl
  800c2b:	77 08                	ja     800c35 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c2d:	0f be c9             	movsbl %cl,%ecx
  800c30:	83 e9 57             	sub    $0x57,%ecx
  800c33:	eb 0e                	jmp    800c43 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c35:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c38:	80 fb 19             	cmp    $0x19,%bl
  800c3b:	77 14                	ja     800c51 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c3d:	0f be c9             	movsbl %cl,%ecx
  800c40:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c43:	39 f1                	cmp    %esi,%ecx
  800c45:	7d 0e                	jge    800c55 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c47:	83 c2 01             	add    $0x1,%edx
  800c4a:	0f af c6             	imul   %esi,%eax
  800c4d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c4f:	eb c1                	jmp    800c12 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c51:	89 c1                	mov    %eax,%ecx
  800c53:	eb 02                	jmp    800c57 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c55:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5b:	74 05                	je     800c62 <strtol+0xce>
		*endptr = (char *) s;
  800c5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c60:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c62:	89 ca                	mov    %ecx,%edx
  800c64:	f7 da                	neg    %edx
  800c66:	85 ff                	test   %edi,%edi
  800c68:	0f 45 c2             	cmovne %edx,%eax
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c79:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c7c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	89 c3                	mov    %eax,%ebx
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	89 c6                	mov    %eax,%esi
  800c90:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c9b:	89 ec                	mov    %ebp,%esp
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb8:	89 d1                	mov    %edx,%ecx
  800cba:	89 d3                	mov    %edx,%ebx
  800cbc:	89 d7                	mov    %edx,%edi
  800cbe:	89 d6                	mov    %edx,%esi
  800cc0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ccb:	89 ec                	mov    %ebp,%esp
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 38             	sub    $0x38,%esp
  800cd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	89 cb                	mov    %ecx,%ebx
  800ced:	89 cf                	mov    %ecx,%edi
  800cef:	89 ce                	mov    %ecx,%esi
  800cf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7e 28                	jle    800d1f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d02:	00 
  800d03:	c7 44 24 08 ac 12 80 	movl   $0x8012ac,0x8(%esp)
  800d0a:	00 
  800d0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d12:	00 
  800d13:	c7 04 24 c9 12 80 00 	movl   $0x8012c9,(%esp)
  800d1a:	e8 3d 00 00 00       	call   800d5c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d28:	89 ec                	mov    %ebp,%esp
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 02 00 00 00       	mov    $0x2,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d58:	89 ec                	mov    %ebp,%esp
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d64:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d67:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d6d:	e8 ba ff ff ff       	call   800d2c <sys_getenvid>
  800d72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d75:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d80:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d88:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  800d8f:	e8 af f3 ff ff       	call   800143 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d98:	8b 45 10             	mov    0x10(%ebp),%eax
  800d9b:	89 04 24             	mov    %eax,(%esp)
  800d9e:	e8 3f f3 ff ff       	call   8000e2 <vcprintf>
	cprintf("\n");
  800da3:	c7 04 24 84 10 80 00 	movl   $0x801084,(%esp)
  800daa:	e8 94 f3 ff ff       	call   800143 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800daf:	cc                   	int3   
  800db0:	eb fd                	jmp    800daf <_panic+0x53>
	...

00800dc0 <__udivdi3>:
  800dc0:	83 ec 1c             	sub    $0x1c,%esp
  800dc3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800dc7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800dcb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800dcf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800dd3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800dd7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ddb:	85 ff                	test   %edi,%edi
  800ddd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800de1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de5:	89 cd                	mov    %ecx,%ebp
  800de7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800deb:	75 33                	jne    800e20 <__udivdi3+0x60>
  800ded:	39 f1                	cmp    %esi,%ecx
  800def:	77 57                	ja     800e48 <__udivdi3+0x88>
  800df1:	85 c9                	test   %ecx,%ecx
  800df3:	75 0b                	jne    800e00 <__udivdi3+0x40>
  800df5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfa:	31 d2                	xor    %edx,%edx
  800dfc:	f7 f1                	div    %ecx
  800dfe:	89 c1                	mov    %eax,%ecx
  800e00:	89 f0                	mov    %esi,%eax
  800e02:	31 d2                	xor    %edx,%edx
  800e04:	f7 f1                	div    %ecx
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e0c:	f7 f1                	div    %ecx
  800e0e:	89 f2                	mov    %esi,%edx
  800e10:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e14:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e18:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	c3                   	ret    
  800e20:	31 d2                	xor    %edx,%edx
  800e22:	31 c0                	xor    %eax,%eax
  800e24:	39 f7                	cmp    %esi,%edi
  800e26:	77 e8                	ja     800e10 <__udivdi3+0x50>
  800e28:	0f bd cf             	bsr    %edi,%ecx
  800e2b:	83 f1 1f             	xor    $0x1f,%ecx
  800e2e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e32:	75 2c                	jne    800e60 <__udivdi3+0xa0>
  800e34:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800e38:	76 04                	jbe    800e3e <__udivdi3+0x7e>
  800e3a:	39 f7                	cmp    %esi,%edi
  800e3c:	73 d2                	jae    800e10 <__udivdi3+0x50>
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	b8 01 00 00 00       	mov    $0x1,%eax
  800e45:	eb c9                	jmp    800e10 <__udivdi3+0x50>
  800e47:	90                   	nop
  800e48:	89 f2                	mov    %esi,%edx
  800e4a:	f7 f1                	div    %ecx
  800e4c:	31 d2                	xor    %edx,%edx
  800e4e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e52:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e56:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	c3                   	ret    
  800e5e:	66 90                	xchg   %ax,%ax
  800e60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e65:	b8 20 00 00 00       	mov    $0x20,%eax
  800e6a:	89 ea                	mov    %ebp,%edx
  800e6c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e70:	d3 e7                	shl    %cl,%edi
  800e72:	89 c1                	mov    %eax,%ecx
  800e74:	d3 ea                	shr    %cl,%edx
  800e76:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e7b:	09 fa                	or     %edi,%edx
  800e7d:	89 f7                	mov    %esi,%edi
  800e7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e83:	89 f2                	mov    %esi,%edx
  800e85:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e89:	d3 e5                	shl    %cl,%ebp
  800e8b:	89 c1                	mov    %eax,%ecx
  800e8d:	d3 ef                	shr    %cl,%edi
  800e8f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e94:	d3 e2                	shl    %cl,%edx
  800e96:	89 c1                	mov    %eax,%ecx
  800e98:	d3 ee                	shr    %cl,%esi
  800e9a:	09 d6                	or     %edx,%esi
  800e9c:	89 fa                	mov    %edi,%edx
  800e9e:	89 f0                	mov    %esi,%eax
  800ea0:	f7 74 24 0c          	divl   0xc(%esp)
  800ea4:	89 d7                	mov    %edx,%edi
  800ea6:	89 c6                	mov    %eax,%esi
  800ea8:	f7 e5                	mul    %ebp
  800eaa:	39 d7                	cmp    %edx,%edi
  800eac:	72 22                	jb     800ed0 <__udivdi3+0x110>
  800eae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800eb2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eb7:	d3 e5                	shl    %cl,%ebp
  800eb9:	39 c5                	cmp    %eax,%ebp
  800ebb:	73 04                	jae    800ec1 <__udivdi3+0x101>
  800ebd:	39 d7                	cmp    %edx,%edi
  800ebf:	74 0f                	je     800ed0 <__udivdi3+0x110>
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	e9 46 ff ff ff       	jmp    800e10 <__udivdi3+0x50>
  800eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ed9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800edd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	c3                   	ret    
	...

00800ef0 <__umoddi3>:
  800ef0:	83 ec 1c             	sub    $0x1c,%esp
  800ef3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ef7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800efb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800eff:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f03:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f07:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f0b:	85 ed                	test   %ebp,%ebp
  800f0d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f15:	89 cf                	mov    %ecx,%edi
  800f17:	89 04 24             	mov    %eax,(%esp)
  800f1a:	89 f2                	mov    %esi,%edx
  800f1c:	75 1a                	jne    800f38 <__umoddi3+0x48>
  800f1e:	39 f1                	cmp    %esi,%ecx
  800f20:	76 4e                	jbe    800f70 <__umoddi3+0x80>
  800f22:	f7 f1                	div    %ecx
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	31 d2                	xor    %edx,%edx
  800f28:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f2c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f30:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f34:	83 c4 1c             	add    $0x1c,%esp
  800f37:	c3                   	ret    
  800f38:	39 f5                	cmp    %esi,%ebp
  800f3a:	77 54                	ja     800f90 <__umoddi3+0xa0>
  800f3c:	0f bd c5             	bsr    %ebp,%eax
  800f3f:	83 f0 1f             	xor    $0x1f,%eax
  800f42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f46:	75 60                	jne    800fa8 <__umoddi3+0xb8>
  800f48:	3b 0c 24             	cmp    (%esp),%ecx
  800f4b:	0f 87 07 01 00 00    	ja     801058 <__umoddi3+0x168>
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	8b 34 24             	mov    (%esp),%esi
  800f56:	29 ce                	sub    %ecx,%esi
  800f58:	19 ea                	sbb    %ebp,%edx
  800f5a:	89 34 24             	mov    %esi,(%esp)
  800f5d:	8b 04 24             	mov    (%esp),%eax
  800f60:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f64:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f68:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f6c:	83 c4 1c             	add    $0x1c,%esp
  800f6f:	c3                   	ret    
  800f70:	85 c9                	test   %ecx,%ecx
  800f72:	75 0b                	jne    800f7f <__umoddi3+0x8f>
  800f74:	b8 01 00 00 00       	mov    $0x1,%eax
  800f79:	31 d2                	xor    %edx,%edx
  800f7b:	f7 f1                	div    %ecx
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	89 f0                	mov    %esi,%eax
  800f81:	31 d2                	xor    %edx,%edx
  800f83:	f7 f1                	div    %ecx
  800f85:	8b 04 24             	mov    (%esp),%eax
  800f88:	f7 f1                	div    %ecx
  800f8a:	eb 98                	jmp    800f24 <__umoddi3+0x34>
  800f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f96:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f9a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f9e:	83 c4 1c             	add    $0x1c,%esp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fad:	89 e8                	mov    %ebp,%eax
  800faf:	bd 20 00 00 00       	mov    $0x20,%ebp
  800fb4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800fb8:	89 fa                	mov    %edi,%edx
  800fba:	d3 e0                	shl    %cl,%eax
  800fbc:	89 e9                	mov    %ebp,%ecx
  800fbe:	d3 ea                	shr    %cl,%edx
  800fc0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fc5:	09 c2                	or     %eax,%edx
  800fc7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fcb:	89 14 24             	mov    %edx,(%esp)
  800fce:	89 f2                	mov    %esi,%edx
  800fd0:	d3 e7                	shl    %cl,%edi
  800fd2:	89 e9                	mov    %ebp,%ecx
  800fd4:	d3 ea                	shr    %cl,%edx
  800fd6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	d3 e6                	shl    %cl,%esi
  800fe1:	89 e9                	mov    %ebp,%ecx
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fea:	09 f0                	or     %esi,%eax
  800fec:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ff0:	f7 34 24             	divl   (%esp)
  800ff3:	d3 e6                	shl    %cl,%esi
  800ff5:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ff9:	89 d6                	mov    %edx,%esi
  800ffb:	f7 e7                	mul    %edi
  800ffd:	39 d6                	cmp    %edx,%esi
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	89 d7                	mov    %edx,%edi
  801003:	72 3f                	jb     801044 <__umoddi3+0x154>
  801005:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801009:	72 35                	jb     801040 <__umoddi3+0x150>
  80100b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80100f:	29 c8                	sub    %ecx,%eax
  801011:	19 fe                	sbb    %edi,%esi
  801013:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801018:	89 f2                	mov    %esi,%edx
  80101a:	d3 e8                	shr    %cl,%eax
  80101c:	89 e9                	mov    %ebp,%ecx
  80101e:	d3 e2                	shl    %cl,%edx
  801020:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801025:	09 d0                	or     %edx,%eax
  801027:	89 f2                	mov    %esi,%edx
  801029:	d3 ea                	shr    %cl,%edx
  80102b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80102f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801033:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801037:	83 c4 1c             	add    $0x1c,%esp
  80103a:	c3                   	ret    
  80103b:	90                   	nop
  80103c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801040:	39 d6                	cmp    %edx,%esi
  801042:	75 c7                	jne    80100b <__umoddi3+0x11b>
  801044:	89 d7                	mov    %edx,%edi
  801046:	89 c1                	mov    %eax,%ecx
  801048:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80104c:	1b 3c 24             	sbb    (%esp),%edi
  80104f:	eb ba                	jmp    80100b <__umoddi3+0x11b>
  801051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801058:	39 f5                	cmp    %esi,%ebp
  80105a:	0f 82 f1 fe ff ff    	jb     800f51 <__umoddi3+0x61>
  801060:	e9 f8 fe ff ff       	jmp    800f5d <__umoddi3+0x6d>
