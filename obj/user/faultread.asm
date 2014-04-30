
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
  800043:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  80004a:	e8 0c 01 00 00       	call   80015b <cprintf>
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
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800066:	e8 e1 0c 00 00       	call   800d4c <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	c1 e0 07             	shl    $0x7,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 39 0c 00 00       	call   800cef <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 14             	sub    $0x14,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cb:	83 c0 01             	add    $0x1,%eax
  8000ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 19                	jne    8000f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000de:	00 
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 a6 0b 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  8000ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f4:	83 c4 14             	add    $0x14,%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011e:	8b 45 08             	mov    0x8(%ebp),%eax
  800121:	89 44 24 08          	mov    %eax,0x8(%esp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012f:	c7 04 24 b8 00 80 00 	movl   $0x8000b8,(%esp)
  800136:	e8 97 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
  80014e:	e8 3d 0b 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8b 45 08             	mov    0x8(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 87 ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
  800175:	00 00                	add    %al,(%eax)
	...

00800178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 3c             	sub    $0x3c,%esp
  800181:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800184:	89 d7                	mov    %edx,%edi
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80018c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800192:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800195:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
  80019d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a0:	72 11                	jb     8001b3 <printnum+0x3b>
  8001a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a8:	76 09                	jbe    8001b3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001aa:	83 eb 01             	sub    $0x1,%ebx
  8001ad:	85 db                	test   %ebx,%ebx
  8001af:	7f 51                	jg     800202 <printnum+0x8a>
  8001b1:	eb 5e                	jmp    800211 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b7:	83 eb 01             	sub    $0x1,%ebx
  8001ba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001be:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d4:	00 
  8001d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	e8 b9 0e 00 00       	call   8010a0 <__udivdi3>
  8001e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001eb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f6:	89 fa                	mov    %edi,%edx
  8001f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fb:	e8 78 ff ff ff       	call   800178 <printnum>
  800200:	eb 0f                	jmp    800211 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800202:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800206:	89 34 24             	mov    %esi,(%esp)
  800209:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020c:	83 eb 01             	sub    $0x1,%ebx
  80020f:	75 f1                	jne    800202 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800211:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800215:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800219:	8b 45 10             	mov    0x10(%ebp),%eax
  80021c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	e8 96 0f 00 00       	call   8011d0 <__umoddi3>
  80023a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023e:	0f be 80 88 13 80 00 	movsbl 0x801388(%eax),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024b:	83 c4 3c             	add    $0x3c,%esp
  80024e:	5b                   	pop    %ebx
  80024f:	5e                   	pop    %esi
  800250:	5f                   	pop    %edi
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800256:	83 fa 01             	cmp    $0x1,%edx
  800259:	7e 0e                	jle    800269 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 02                	mov    (%edx),%eax
  800264:	8b 52 04             	mov    0x4(%edx),%edx
  800267:	eb 22                	jmp    80028b <getuint+0x38>
	else if (lflag)
  800269:	85 d2                	test   %edx,%edx
  80026b:	74 10                	je     80027d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800272:	89 08                	mov    %ecx,(%eax)
  800274:	8b 02                	mov    (%edx),%eax
  800276:	ba 00 00 00 00       	mov    $0x0,%edx
  80027b:	eb 0e                	jmp    80028b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800293:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800297:	8b 10                	mov    (%eax),%edx
  800299:	3b 50 04             	cmp    0x4(%eax),%edx
  80029c:	73 0a                	jae    8002a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a1:	88 0a                	mov    %cl,(%edx)
  8002a3:	83 c2 01             	add    $0x1,%edx
  8002a6:	89 10                	mov    %edx,(%eax)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	e8 02 00 00 00       	call   8002d2 <vprintfmt>
	va_end(ap);
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 5c             	sub    $0x5c,%esp
  8002db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002de:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e1:	eb 12                	jmp    8002f5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	0f 84 e4 04 00 00    	je     8007cf <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f5:	0f b6 06             	movzbl (%esi),%eax
  8002f8:	83 c6 01             	add    $0x1,%esi
  8002fb:	83 f8 25             	cmp    $0x25,%eax
  8002fe:	75 e3                	jne    8002e3 <vprintfmt+0x11>
  800300:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800304:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80030b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800310:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80031f:	eb 2b                	jmp    80034c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800324:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800328:	eb 22                	jmp    80034c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800331:	eb 19                	jmp    80034c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800336:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80033d:	eb 0d                	jmp    80034c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800342:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800345:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	0f b6 06             	movzbl (%esi),%eax
  80034f:	0f b6 d0             	movzbl %al,%edx
  800352:	8d 7e 01             	lea    0x1(%esi),%edi
  800355:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800358:	83 e8 23             	sub    $0x23,%eax
  80035b:	3c 55                	cmp    $0x55,%al
  80035d:	0f 87 46 04 00 00    	ja     8007a9 <vprintfmt+0x4d7>
  800363:	0f b6 c0             	movzbl %al,%eax
  800366:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036d:	83 ea 30             	sub    $0x30,%edx
  800370:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800373:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800377:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80037d:	83 fa 09             	cmp    $0x9,%edx
  800380:	77 4a                	ja     8003cc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800385:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800388:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80038b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80038f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800392:	8d 50 d0             	lea    -0x30(%eax),%edx
  800395:	83 fa 09             	cmp    $0x9,%edx
  800398:	76 eb                	jbe    800385 <vprintfmt+0xb3>
  80039a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80039d:	eb 2d                	jmp    8003cc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 50 04             	lea    0x4(%eax),%edx
  8003a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b0:	eb 1a                	jmp    8003cc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003b9:	79 91                	jns    80034c <vprintfmt+0x7a>
  8003bb:	e9 73 ff ff ff       	jmp    800333 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003ca:	eb 80                	jmp    80034c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003d0:	0f 89 76 ff ff ff    	jns    80034c <vprintfmt+0x7a>
  8003d6:	e9 64 ff ff ff       	jmp    80033f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003db:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e1:	e9 66 ff ff ff       	jmp    80034c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fe:	e9 f2 fe ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800403:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800407:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80040a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80040e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800411:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800415:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800418:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80041b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80041f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800422:	80 f9 09             	cmp    $0x9,%cl
  800425:	77 1d                	ja     800444 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800427:	0f be c0             	movsbl %al,%eax
  80042a:	6b c0 64             	imul   $0x64,%eax,%eax
  80042d:	0f be d2             	movsbl %dl,%edx
  800430:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800433:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80043a:	a3 04 20 80 00       	mov    %eax,0x802004
  80043f:	e9 b1 fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800444:	c7 44 24 04 a0 13 80 	movl   $0x8013a0,0x4(%esp)
  80044b:	00 
  80044c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80044f:	89 04 24             	mov    %eax,(%esp)
  800452:	e8 14 05 00 00       	call   80096b <strcmp>
  800457:	85 c0                	test   %eax,%eax
  800459:	75 0f                	jne    80046a <vprintfmt+0x198>
  80045b:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800462:	00 00 00 
  800465:	e9 8b fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80046a:	c7 44 24 04 a4 13 80 	movl   $0x8013a4,0x4(%esp)
  800471:	00 
  800472:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800475:	89 14 24             	mov    %edx,(%esp)
  800478:	e8 ee 04 00 00       	call   80096b <strcmp>
  80047d:	85 c0                	test   %eax,%eax
  80047f:	75 0f                	jne    800490 <vprintfmt+0x1be>
  800481:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800488:	00 00 00 
  80048b:	e9 65 fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800490:	c7 44 24 04 a8 13 80 	movl   $0x8013a8,0x4(%esp)
  800497:	00 
  800498:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80049b:	89 0c 24             	mov    %ecx,(%esp)
  80049e:	e8 c8 04 00 00       	call   80096b <strcmp>
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	75 0f                	jne    8004b6 <vprintfmt+0x1e4>
  8004a7:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004ae:	00 00 00 
  8004b1:	e9 3f fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004b6:	c7 44 24 04 ac 13 80 	movl   $0x8013ac,0x4(%esp)
  8004bd:	00 
  8004be:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004c1:	89 3c 24             	mov    %edi,(%esp)
  8004c4:	e8 a2 04 00 00       	call   80096b <strcmp>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	75 0f                	jne    8004dc <vprintfmt+0x20a>
  8004cd:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004d4:	00 00 00 
  8004d7:	e9 19 fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004dc:	c7 44 24 04 b0 13 80 	movl   $0x8013b0,0x4(%esp)
  8004e3:	00 
  8004e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004e7:	89 04 24             	mov    %eax,(%esp)
  8004ea:	e8 7c 04 00 00       	call   80096b <strcmp>
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	75 0f                	jne    800502 <vprintfmt+0x230>
  8004f3:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8004fa:	00 00 00 
  8004fd:	e9 f3 fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800502:	c7 44 24 04 b4 13 80 	movl   $0x8013b4,0x4(%esp)
  800509:	00 
  80050a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80050d:	89 14 24             	mov    %edx,(%esp)
  800510:	e8 56 04 00 00       	call   80096b <strcmp>
  800515:	83 f8 01             	cmp    $0x1,%eax
  800518:	19 c0                	sbb    %eax,%eax
  80051a:	f7 d0                	not    %eax
  80051c:	83 c0 08             	add    $0x8,%eax
  80051f:	a3 04 20 80 00       	mov    %eax,0x802004
  800524:	e9 cc fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 50 04             	lea    0x4(%eax),%edx
  80052f:	89 55 14             	mov    %edx,0x14(%ebp)
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 c2                	mov    %eax,%edx
  800536:	c1 fa 1f             	sar    $0x1f,%edx
  800539:	31 d0                	xor    %edx,%eax
  80053b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053d:	83 f8 08             	cmp    $0x8,%eax
  800540:	7f 0b                	jg     80054d <vprintfmt+0x27b>
  800542:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  800549:	85 d2                	test   %edx,%edx
  80054b:	75 23                	jne    800570 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80054d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800551:	c7 44 24 08 b8 13 80 	movl   $0x8013b8,0x8(%esp)
  800558:	00 
  800559:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800560:	89 3c 24             	mov    %edi,(%esp)
  800563:	e8 42 fd ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056b:	e9 85 fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800570:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800574:	c7 44 24 08 c1 13 80 	movl   $0x8013c1,0x8(%esp)
  80057b:	00 
  80057c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800580:	8b 7d 08             	mov    0x8(%ebp),%edi
  800583:	89 3c 24             	mov    %edi,(%esp)
  800586:	e8 1f fd ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80058e:	e9 62 fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
  800593:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800596:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800599:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005a7:	85 f6                	test   %esi,%esi
  8005a9:	b8 99 13 80 00       	mov    $0x801399,%eax
  8005ae:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005b1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005b5:	7e 06                	jle    8005bd <vprintfmt+0x2eb>
  8005b7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005bb:	75 13                	jne    8005d0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bd:	0f be 06             	movsbl (%esi),%eax
  8005c0:	83 c6 01             	add    $0x1,%esi
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	0f 85 94 00 00 00    	jne    80065f <vprintfmt+0x38d>
  8005cb:	e9 81 00 00 00       	jmp    800651 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d4:	89 34 24             	mov    %esi,(%esp)
  8005d7:	e8 9f 02 00 00       	call   80087b <strnlen>
  8005dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005df:	29 c2                	sub    %eax,%edx
  8005e1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	7e d5                	jle    8005bd <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005e8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8005ec:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005ef:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8005f2:	89 d6                	mov    %edx,%esi
  8005f4:	89 cf                	mov    %ecx,%edi
  8005f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fa:	89 3c 24             	mov    %edi,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800600:	83 ee 01             	sub    $0x1,%esi
  800603:	75 f1                	jne    8005f6 <vprintfmt+0x324>
  800605:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800608:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80060b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80060e:	eb ad                	jmp    8005bd <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800610:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800614:	74 1b                	je     800631 <vprintfmt+0x35f>
  800616:	8d 50 e0             	lea    -0x20(%eax),%edx
  800619:	83 fa 5e             	cmp    $0x5e,%edx
  80061c:	76 13                	jbe    800631 <vprintfmt+0x35f>
					putch('?', putdat);
  80061e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800621:	89 44 24 04          	mov    %eax,0x4(%esp)
  800625:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062c:	ff 55 08             	call   *0x8(%ebp)
  80062f:	eb 0d                	jmp    80063e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800631:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800634:	89 54 24 04          	mov    %edx,0x4(%esp)
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063e:	83 eb 01             	sub    $0x1,%ebx
  800641:	0f be 06             	movsbl (%esi),%eax
  800644:	83 c6 01             	add    $0x1,%esi
  800647:	85 c0                	test   %eax,%eax
  800649:	75 1a                	jne    800665 <vprintfmt+0x393>
  80064b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80064e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800654:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800658:	7f 1c                	jg     800676 <vprintfmt+0x3a4>
  80065a:	e9 96 fc ff ff       	jmp    8002f5 <vprintfmt+0x23>
  80065f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800662:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800665:	85 ff                	test   %edi,%edi
  800667:	78 a7                	js     800610 <vprintfmt+0x33e>
  800669:	83 ef 01             	sub    $0x1,%edi
  80066c:	79 a2                	jns    800610 <vprintfmt+0x33e>
  80066e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800671:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800674:	eb db                	jmp    800651 <vprintfmt+0x37f>
  800676:	8b 7d 08             	mov    0x8(%ebp),%edi
  800679:	89 de                	mov    %ebx,%esi
  80067b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800689:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068b:	83 eb 01             	sub    $0x1,%ebx
  80068e:	75 ee                	jne    80067e <vprintfmt+0x3ac>
  800690:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800695:	e9 5b fc ff ff       	jmp    8002f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069a:	83 f9 01             	cmp    $0x1,%ecx
  80069d:	7e 10                	jle    8006af <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 08             	lea    0x8(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a8:	8b 30                	mov    (%eax),%esi
  8006aa:	8b 78 04             	mov    0x4(%eax),%edi
  8006ad:	eb 26                	jmp    8006d5 <vprintfmt+0x403>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	74 12                	je     8006c5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 50 04             	lea    0x4(%eax),%edx
  8006b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bc:	8b 30                	mov    (%eax),%esi
  8006be:	89 f7                	mov    %esi,%edi
  8006c0:	c1 ff 1f             	sar    $0x1f,%edi
  8006c3:	eb 10                	jmp    8006d5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 04             	lea    0x4(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 30                	mov    (%eax),%esi
  8006d0:	89 f7                	mov    %esi,%edi
  8006d2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	78 0e                	js     8006e7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d9:	89 f0                	mov    %esi,%eax
  8006db:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006dd:	be 0a 00 00 00       	mov    $0xa,%esi
  8006e2:	e9 84 00 00 00       	jmp    80076b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006eb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f5:	89 f0                	mov    %esi,%eax
  8006f7:	89 fa                	mov    %edi,%edx
  8006f9:	f7 d8                	neg    %eax
  8006fb:	83 d2 00             	adc    $0x0,%edx
  8006fe:	f7 da                	neg    %edx
			}
			base = 10;
  800700:	be 0a 00 00 00       	mov    $0xa,%esi
  800705:	eb 64                	jmp    80076b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800707:	89 ca                	mov    %ecx,%edx
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
  80070c:	e8 42 fb ff ff       	call   800253 <getuint>
			base = 10;
  800711:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800716:	eb 53                	jmp    80076b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800718:	89 ca                	mov    %ecx,%edx
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
  80071d:	e8 31 fb ff ff       	call   800253 <getuint>
    			base = 8;
  800722:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800727:	eb 42                	jmp    80076b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800729:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800734:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800737:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800742:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8d 50 04             	lea    0x4(%eax),%edx
  80074b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800755:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80075a:	eb 0f                	jmp    80076b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 ed fa ff ff       	call   800253 <getuint>
			base = 16;
  800766:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80076b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80076f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800773:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800776:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80077a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	89 54 24 04          	mov    %edx,0x4(%esp)
  800785:	89 da                	mov    %ebx,%edx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	e8 e9 f9 ff ff       	call   800178 <printnum>
			break;
  80078f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800792:	e9 5e fb ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	89 14 24             	mov    %edx,(%esp)
  80079e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a4:	e9 4c fb ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ad:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007bb:	0f 84 34 fb ff ff    	je     8002f5 <vprintfmt+0x23>
  8007c1:	83 ee 01             	sub    $0x1,%esi
  8007c4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c8:	75 f7                	jne    8007c1 <vprintfmt+0x4ef>
  8007ca:	e9 26 fb ff ff       	jmp    8002f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007cf:	83 c4 5c             	add    $0x5c,%esp
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5f                   	pop    %edi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 28             	sub    $0x28,%esp
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	74 30                	je     800828 <vsnprintf+0x51>
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	7e 2c                	jle    800828 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800803:	8b 45 10             	mov    0x10(%ebp),%eax
  800806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800811:	c7 04 24 8d 02 80 00 	movl   $0x80028d,(%esp)
  800818:	e8 b5 fa ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800820:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800823:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800826:	eb 05                	jmp    80082d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800838:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083c:	8b 45 10             	mov    0x10(%ebp),%eax
  80083f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800843:	8b 45 0c             	mov    0xc(%ebp),%eax
  800846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	89 04 24             	mov    %eax,(%esp)
  800850:	e8 82 ff ff ff       	call   8007d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    
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
  800d23:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800d3a:	e8 09 03 00 00       	call   801048 <_panic>

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

00800d7c <sys_yield>:

void
sys_yield(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 38             	sub    $0x38,%esp
  800db2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	89 f7                	mov    %esi,%edi
  800dd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	7e 28                	jle    800dfe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dda:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de1:	00 
  800de2:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800de9:	00 
  800dea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df1:	00 
  800df2:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800df9:	e8 4a 02 00 00       	call   801048 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dfe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e01:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e04:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e07:	89 ec                	mov    %ebp,%esp
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 38             	sub    $0x38,%esp
  800e11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7e 28                	jle    800e5c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e3f:	00 
  800e40:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800e47:	00 
  800e48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4f:	00 
  800e50:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800e57:	e8 ec 01 00 00       	call   801048 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e5c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e62:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e65:	89 ec                	mov    %ebp,%esp
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 38             	sub    $0x38,%esp
  800e6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e75:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 28                	jle    800eba <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e96:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ead:	00 
  800eae:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800eb5:	e8 8e 01 00 00       	call   801048 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ebd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec3:	89 ec                	mov    %ebp,%esp
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 38             	sub    $0x38,%esp
  800ecd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 28                	jle    800f18 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800efb:	00 
  800efc:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800f13:	e8 30 01 00 00       	call   801048 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f18:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f21:	89 ec                	mov    %ebp,%esp
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 38             	sub    $0x38,%esp
  800f2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f31:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f39:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	89 df                	mov    %ebx,%edi
  800f46:	89 de                	mov    %ebx,%esi
  800f48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	7e 28                	jle    800f76 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f52:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800f71:	e8 d2 00 00 00       	call   801048 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7f:	89 ec                	mov    %ebp,%esp
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	be 00 00 00 00       	mov    $0x0,%esi
  800f97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800faa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb3:	89 ec                	mov    %ebp,%esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 38             	sub    $0x38,%esp
  800fbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd3:	89 cb                	mov    %ecx,%ebx
  800fd5:	89 cf                	mov    %ecx,%edi
  800fd7:	89 ce                	mov    %ecx,%esi
  800fd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	7e 28                	jle    801007 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fea:	00 
  800feb:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffa:	00 
  800ffb:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  801002:	e8 41 00 00 00       	call   801048 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801007:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801010:	89 ec                	mov    %ebp,%esp
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80101d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801020:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801023:	b9 00 00 00 00       	mov    $0x0,%ecx
  801028:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	89 cb                	mov    %ecx,%ebx
  801032:	89 cf                	mov    %ecx,%edi
  801034:	89 ce                	mov    %ecx,%esi
  801036:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  801038:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80103b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801041:	89 ec                	mov    %ebp,%esp
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    
  801045:	00 00                	add    %al,(%eax)
	...

00801048 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
  80104d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801050:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801053:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801059:	e8 ee fc ff ff       	call   800d4c <sys_getenvid>
  80105e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801061:	89 54 24 10          	mov    %edx,0x10(%esp)
  801065:	8b 55 08             	mov    0x8(%ebp),%edx
  801068:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80106c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801070:	89 44 24 04          	mov    %eax,0x4(%esp)
  801074:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  80107b:	e8 db f0 ff ff       	call   80015b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801080:	89 74 24 04          	mov    %esi,0x4(%esp)
  801084:	8b 45 10             	mov    0x10(%ebp),%eax
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	e8 6b f0 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  80108f:	c7 04 24 7c 13 80 00 	movl   $0x80137c,(%esp)
  801096:	e8 c0 f0 ff ff       	call   80015b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109b:	cc                   	int3   
  80109c:	eb fd                	jmp    80109b <_panic+0x53>
	...

008010a0 <__udivdi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010bb:	85 ff                	test   %edi,%edi
  8010bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	89 cd                	mov    %ecx,%ebp
  8010c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cb:	75 33                	jne    801100 <__udivdi3+0x60>
  8010cd:	39 f1                	cmp    %esi,%ecx
  8010cf:	77 57                	ja     801128 <__udivdi3+0x88>
  8010d1:	85 c9                	test   %ecx,%ecx
  8010d3:	75 0b                	jne    8010e0 <__udivdi3+0x40>
  8010d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010da:	31 d2                	xor    %edx,%edx
  8010dc:	f7 f1                	div    %ecx
  8010de:	89 c1                	mov    %eax,%ecx
  8010e0:	89 f0                	mov    %esi,%eax
  8010e2:	31 d2                	xor    %edx,%edx
  8010e4:	f7 f1                	div    %ecx
  8010e6:	89 c6                	mov    %eax,%esi
  8010e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010ec:	f7 f1                	div    %ecx
  8010ee:	89 f2                	mov    %esi,%edx
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	31 d2                	xor    %edx,%edx
  801102:	31 c0                	xor    %eax,%eax
  801104:	39 f7                	cmp    %esi,%edi
  801106:	77 e8                	ja     8010f0 <__udivdi3+0x50>
  801108:	0f bd cf             	bsr    %edi,%ecx
  80110b:	83 f1 1f             	xor    $0x1f,%ecx
  80110e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801112:	75 2c                	jne    801140 <__udivdi3+0xa0>
  801114:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801118:	76 04                	jbe    80111e <__udivdi3+0x7e>
  80111a:	39 f7                	cmp    %esi,%edi
  80111c:	73 d2                	jae    8010f0 <__udivdi3+0x50>
  80111e:	31 d2                	xor    %edx,%edx
  801120:	b8 01 00 00 00       	mov    $0x1,%eax
  801125:	eb c9                	jmp    8010f0 <__udivdi3+0x50>
  801127:	90                   	nop
  801128:	89 f2                	mov    %esi,%edx
  80112a:	f7 f1                	div    %ecx
  80112c:	31 d2                	xor    %edx,%edx
  80112e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801132:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801136:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80113a:	83 c4 1c             	add    $0x1c,%esp
  80113d:	c3                   	ret    
  80113e:	66 90                	xchg   %ax,%ax
  801140:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801145:	b8 20 00 00 00       	mov    $0x20,%eax
  80114a:	89 ea                	mov    %ebp,%edx
  80114c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801150:	d3 e7                	shl    %cl,%edi
  801152:	89 c1                	mov    %eax,%ecx
  801154:	d3 ea                	shr    %cl,%edx
  801156:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115b:	09 fa                	or     %edi,%edx
  80115d:	89 f7                	mov    %esi,%edi
  80115f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801163:	89 f2                	mov    %esi,%edx
  801165:	8b 74 24 08          	mov    0x8(%esp),%esi
  801169:	d3 e5                	shl    %cl,%ebp
  80116b:	89 c1                	mov    %eax,%ecx
  80116d:	d3 ef                	shr    %cl,%edi
  80116f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801174:	d3 e2                	shl    %cl,%edx
  801176:	89 c1                	mov    %eax,%ecx
  801178:	d3 ee                	shr    %cl,%esi
  80117a:	09 d6                	or     %edx,%esi
  80117c:	89 fa                	mov    %edi,%edx
  80117e:	89 f0                	mov    %esi,%eax
  801180:	f7 74 24 0c          	divl   0xc(%esp)
  801184:	89 d7                	mov    %edx,%edi
  801186:	89 c6                	mov    %eax,%esi
  801188:	f7 e5                	mul    %ebp
  80118a:	39 d7                	cmp    %edx,%edi
  80118c:	72 22                	jb     8011b0 <__udivdi3+0x110>
  80118e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801192:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801197:	d3 e5                	shl    %cl,%ebp
  801199:	39 c5                	cmp    %eax,%ebp
  80119b:	73 04                	jae    8011a1 <__udivdi3+0x101>
  80119d:	39 d7                	cmp    %edx,%edi
  80119f:	74 0f                	je     8011b0 <__udivdi3+0x110>
  8011a1:	89 f0                	mov    %esi,%eax
  8011a3:	31 d2                	xor    %edx,%edx
  8011a5:	e9 46 ff ff ff       	jmp    8010f0 <__udivdi3+0x50>
  8011aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011b3:	31 d2                	xor    %edx,%edx
  8011b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c1:	83 c4 1c             	add    $0x1c,%esp
  8011c4:	c3                   	ret    
	...

008011d0 <__umoddi3>:
  8011d0:	83 ec 1c             	sub    $0x1c,%esp
  8011d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011eb:	85 ed                	test   %ebp,%ebp
  8011ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f5:	89 cf                	mov    %ecx,%edi
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	89 f2                	mov    %esi,%edx
  8011fc:	75 1a                	jne    801218 <__umoddi3+0x48>
  8011fe:	39 f1                	cmp    %esi,%ecx
  801200:	76 4e                	jbe    801250 <__umoddi3+0x80>
  801202:	f7 f1                	div    %ecx
  801204:	89 d0                	mov    %edx,%eax
  801206:	31 d2                	xor    %edx,%edx
  801208:	8b 74 24 10          	mov    0x10(%esp),%esi
  80120c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801210:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801214:	83 c4 1c             	add    $0x1c,%esp
  801217:	c3                   	ret    
  801218:	39 f5                	cmp    %esi,%ebp
  80121a:	77 54                	ja     801270 <__umoddi3+0xa0>
  80121c:	0f bd c5             	bsr    %ebp,%eax
  80121f:	83 f0 1f             	xor    $0x1f,%eax
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	75 60                	jne    801288 <__umoddi3+0xb8>
  801228:	3b 0c 24             	cmp    (%esp),%ecx
  80122b:	0f 87 07 01 00 00    	ja     801338 <__umoddi3+0x168>
  801231:	89 f2                	mov    %esi,%edx
  801233:	8b 34 24             	mov    (%esp),%esi
  801236:	29 ce                	sub    %ecx,%esi
  801238:	19 ea                	sbb    %ebp,%edx
  80123a:	89 34 24             	mov    %esi,(%esp)
  80123d:	8b 04 24             	mov    (%esp),%eax
  801240:	8b 74 24 10          	mov    0x10(%esp),%esi
  801244:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801248:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124c:	83 c4 1c             	add    $0x1c,%esp
  80124f:	c3                   	ret    
  801250:	85 c9                	test   %ecx,%ecx
  801252:	75 0b                	jne    80125f <__umoddi3+0x8f>
  801254:	b8 01 00 00 00       	mov    $0x1,%eax
  801259:	31 d2                	xor    %edx,%edx
  80125b:	f7 f1                	div    %ecx
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 f0                	mov    %esi,%eax
  801261:	31 d2                	xor    %edx,%edx
  801263:	f7 f1                	div    %ecx
  801265:	8b 04 24             	mov    (%esp),%eax
  801268:	f7 f1                	div    %ecx
  80126a:	eb 98                	jmp    801204 <__umoddi3+0x34>
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 f2                	mov    %esi,%edx
  801272:	8b 74 24 10          	mov    0x10(%esp),%esi
  801276:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80127a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80127e:	83 c4 1c             	add    $0x1c,%esp
  801281:	c3                   	ret    
  801282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801288:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128d:	89 e8                	mov    %ebp,%eax
  80128f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801294:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801298:	89 fa                	mov    %edi,%edx
  80129a:	d3 e0                	shl    %cl,%eax
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 ea                	shr    %cl,%edx
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	09 c2                	or     %eax,%edx
  8012a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ab:	89 14 24             	mov    %edx,(%esp)
  8012ae:	89 f2                	mov    %esi,%edx
  8012b0:	d3 e7                	shl    %cl,%edi
  8012b2:	89 e9                	mov    %ebp,%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bf:	d3 e6                	shl    %cl,%esi
  8012c1:	89 e9                	mov    %ebp,%ecx
  8012c3:	d3 e8                	shr    %cl,%eax
  8012c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ca:	09 f0                	or     %esi,%eax
  8012cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012d0:	f7 34 24             	divl   (%esp)
  8012d3:	d3 e6                	shl    %cl,%esi
  8012d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012d9:	89 d6                	mov    %edx,%esi
  8012db:	f7 e7                	mul    %edi
  8012dd:	39 d6                	cmp    %edx,%esi
  8012df:	89 c1                	mov    %eax,%ecx
  8012e1:	89 d7                	mov    %edx,%edi
  8012e3:	72 3f                	jb     801324 <__umoddi3+0x154>
  8012e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012e9:	72 35                	jb     801320 <__umoddi3+0x150>
  8012eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ef:	29 c8                	sub    %ecx,%eax
  8012f1:	19 fe                	sbb    %edi,%esi
  8012f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f8:	89 f2                	mov    %esi,%edx
  8012fa:	d3 e8                	shr    %cl,%eax
  8012fc:	89 e9                	mov    %ebp,%ecx
  8012fe:	d3 e2                	shl    %cl,%edx
  801300:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801305:	09 d0                	or     %edx,%eax
  801307:	89 f2                	mov    %esi,%edx
  801309:	d3 ea                	shr    %cl,%edx
  80130b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80130f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801313:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801317:	83 c4 1c             	add    $0x1c,%esp
  80131a:	c3                   	ret    
  80131b:	90                   	nop
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	39 d6                	cmp    %edx,%esi
  801322:	75 c7                	jne    8012eb <__umoddi3+0x11b>
  801324:	89 d7                	mov    %edx,%edi
  801326:	89 c1                	mov    %eax,%ecx
  801328:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80132c:	1b 3c 24             	sbb    (%esp),%edi
  80132f:	eb ba                	jmp    8012eb <__umoddi3+0x11b>
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 f5                	cmp    %esi,%ebp
  80133a:	0f 82 f1 fe ff ff    	jb     801231 <__umoddi3+0x61>
  801340:	e9 f8 fe ff ff       	jmp    80123d <__umoddi3+0x6d>
