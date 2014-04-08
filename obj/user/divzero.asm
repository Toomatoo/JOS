
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
  800059:	c7 04 24 98 10 80 00 	movl   $0x801098,(%esp)
  800060:	e8 0e 01 00 00       	call   800173 <cprintf>
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
  800084:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800087:	c1 e0 05             	shl    $0x5,%eax
  80008a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008f:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800094:	85 f6                	test   %esi,%esi
  800096:	7e 07                	jle    80009f <libmain+0x37>
		binaryname = argv[0];
  800098:	8b 03                	mov    (%ebx),%eax
  80009a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a3:	89 34 24             	mov    %esi,(%esp)
  8000a6:	e8 89 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ab:	e8 0c 00 00 00       	call   8000bc <exit>
}
  8000b0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b6:	89 ec                	mov    %ebp,%esp
  8000b8:	5d                   	pop    %ebp
  8000b9:	c3                   	ret    
	...

008000bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c9:	e8 31 0c 00 00       	call   800cff <sys_env_destroy>
}
  8000ce:	c9                   	leave  
  8000cf:	c3                   	ret    

008000d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 14             	sub    $0x14,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e3:	83 c0 01             	add    $0x1,%eax
  8000e6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ed:	75 19                	jne    800108 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f6:	00 
  8000f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fa:	89 04 24             	mov    %eax,(%esp)
  8000fd:	e8 9e 0b 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  800102:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800108:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010c:	83 c4 14             	add    $0x14,%esp
  80010f:	5b                   	pop    %ebx
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800122:	00 00 00 
	b.cnt = 0;
  800125:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	8b 45 08             	mov    0x8(%ebp),%eax
  800139:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	89 44 24 04          	mov    %eax,0x4(%esp)
  800147:	c7 04 24 d0 00 80 00 	movl   $0x8000d0,(%esp)
  80014e:	e8 97 01 00 00       	call   8002ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800153:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800159:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800163:	89 04 24             	mov    %eax,(%esp)
  800166:	e8 35 0b 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	8b 45 08             	mov    0x8(%ebp),%eax
  800183:	89 04 24             	mov    %eax,(%esp)
  800186:	e8 87 ff ff ff       	call   800112 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b8:	72 11                	jb     8001cb <printnum+0x3b>
  8001ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c0:	76 09                	jbe    8001cb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7f 51                	jg     80021a <printnum+0x8a>
  8001c9:	eb 5e                	jmp    800229 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001cf:	83 eb 01             	sub    $0x1,%ebx
  8001d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ec:	00 
  8001ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	e8 f1 0b 00 00       	call   800df0 <__udivdi3>
  8001ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800203:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020e:	89 fa                	mov    %edi,%edx
  800210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800213:	e8 78 ff ff ff       	call   800190 <printnum>
  800218:	eb 0f                	jmp    800229 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021e:	89 34 24             	mov    %esi,(%esp)
  800221:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800224:	83 eb 01             	sub    $0x1,%ebx
  800227:	75 f1                	jne    80021a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800229:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800231:	8b 45 10             	mov    0x10(%ebp),%eax
  800234:	89 44 24 08          	mov    %eax,0x8(%esp)
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	e8 ce 0c 00 00       	call   800f20 <__umoddi3>
  800252:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800256:	0f be 80 b0 10 80 00 	movsbl 0x8010b0(%eax),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800263:	83 c4 3c             	add    $0x3c,%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b9:	88 0a                	mov    %cl,(%edx)
  8002bb:	83 c2 01             	add    $0x1,%edx
  8002be:	89 10                	mov    %edx,(%eax)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	e8 02 00 00 00       	call   8002ea <vprintfmt>
	va_end(ap);
}
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 5c             	sub    $0x5c,%esp
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f9:	eb 12                	jmp    80030d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fb:	85 c0                	test   %eax,%eax
  8002fd:	0f 84 e4 04 00 00    	je     8007e7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800303:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030d:	0f b6 06             	movzbl (%esi),%eax
  800310:	83 c6 01             	add    $0x1,%esi
  800313:	83 f8 25             	cmp    $0x25,%eax
  800316:	75 e3                	jne    8002fb <vprintfmt+0x11>
  800318:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80031c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800323:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800328:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80032f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800334:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800337:	eb 2b                	jmp    800364 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800340:	eb 22                	jmp    800364 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800345:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800349:	eb 19                	jmp    800364 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80034e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800355:	eb 0d                	jmp    800364 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800357:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80035a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80035d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	0f b6 06             	movzbl (%esi),%eax
  800367:	0f b6 d0             	movzbl %al,%edx
  80036a:	8d 7e 01             	lea    0x1(%esi),%edi
  80036d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800370:	83 e8 23             	sub    $0x23,%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 46 04 00 00    	ja     8007c1 <vprintfmt+0x4d7>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 58 11 80 00 	jmp    *0x801158(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800385:	83 ea 30             	sub    $0x30,%edx
  800388:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80038b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80038f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800395:	83 fa 09             	cmp    $0x9,%edx
  800398:	77 4a                	ja     8003e4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003a0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003a3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003a7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003aa:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ad:	83 fa 09             	cmp    $0x9,%edx
  8003b0:	76 eb                	jbe    80039d <vprintfmt+0xb3>
  8003b2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003b5:	eb 2d                	jmp    8003e4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 50 04             	lea    0x4(%eax),%edx
  8003bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c8:	eb 1a                	jmp    8003e4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003cd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003d1:	79 91                	jns    800364 <vprintfmt+0x7a>
  8003d3:	e9 73 ff ff ff       	jmp    80034b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003e2:	eb 80                	jmp    800364 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003e4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003e8:	0f 89 76 ff ff ff    	jns    800364 <vprintfmt+0x7a>
  8003ee:	e9 64 ff ff ff       	jmp    800357 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f9:	e9 66 ff ff ff       	jmp    800364 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 04 24             	mov    %eax,(%esp)
  800410:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800416:	e9 f2 fe ff ff       	jmp    80030d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80041b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80041f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800422:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800426:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800429:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80042d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800430:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800433:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800437:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80043a:	80 f9 09             	cmp    $0x9,%cl
  80043d:	77 1d                	ja     80045c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80043f:	0f be c0             	movsbl %al,%eax
  800442:	6b c0 64             	imul   $0x64,%eax,%eax
  800445:	0f be d2             	movsbl %dl,%edx
  800448:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80044b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800452:	a3 04 20 80 00       	mov    %eax,0x802004
  800457:	e9 b1 fe ff ff       	jmp    80030d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80045c:	c7 44 24 04 c8 10 80 	movl   $0x8010c8,0x4(%esp)
  800463:	00 
  800464:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	e8 0c 05 00 00       	call   80097b <strcmp>
  80046f:	85 c0                	test   %eax,%eax
  800471:	75 0f                	jne    800482 <vprintfmt+0x198>
  800473:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80047a:	00 00 00 
  80047d:	e9 8b fe ff ff       	jmp    80030d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800482:	c7 44 24 04 cc 10 80 	movl   $0x8010cc,0x4(%esp)
  800489:	00 
  80048a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80048d:	89 14 24             	mov    %edx,(%esp)
  800490:	e8 e6 04 00 00       	call   80097b <strcmp>
  800495:	85 c0                	test   %eax,%eax
  800497:	75 0f                	jne    8004a8 <vprintfmt+0x1be>
  800499:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8004a0:	00 00 00 
  8004a3:	e9 65 fe ff ff       	jmp    80030d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004a8:	c7 44 24 04 d0 10 80 	movl   $0x8010d0,0x4(%esp)
  8004af:	00 
  8004b0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004b3:	89 0c 24             	mov    %ecx,(%esp)
  8004b6:	e8 c0 04 00 00       	call   80097b <strcmp>
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	75 0f                	jne    8004ce <vprintfmt+0x1e4>
  8004bf:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004c6:	00 00 00 
  8004c9:	e9 3f fe ff ff       	jmp    80030d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004ce:	c7 44 24 04 d4 10 80 	movl   $0x8010d4,0x4(%esp)
  8004d5:	00 
  8004d6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004d9:	89 3c 24             	mov    %edi,(%esp)
  8004dc:	e8 9a 04 00 00       	call   80097b <strcmp>
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 0f                	jne    8004f4 <vprintfmt+0x20a>
  8004e5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004ec:	00 00 00 
  8004ef:	e9 19 fe ff ff       	jmp    80030d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004f4:	c7 44 24 04 d8 10 80 	movl   $0x8010d8,0x4(%esp)
  8004fb:	00 
  8004fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	e8 74 04 00 00       	call   80097b <strcmp>
  800507:	85 c0                	test   %eax,%eax
  800509:	75 0f                	jne    80051a <vprintfmt+0x230>
  80050b:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800512:	00 00 00 
  800515:	e9 f3 fd ff ff       	jmp    80030d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80051a:	c7 44 24 04 dc 10 80 	movl   $0x8010dc,0x4(%esp)
  800521:	00 
  800522:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800525:	89 14 24             	mov    %edx,(%esp)
  800528:	e8 4e 04 00 00       	call   80097b <strcmp>
  80052d:	83 f8 01             	cmp    $0x1,%eax
  800530:	19 c0                	sbb    %eax,%eax
  800532:	f7 d0                	not    %eax
  800534:	83 c0 08             	add    $0x8,%eax
  800537:	a3 04 20 80 00       	mov    %eax,0x802004
  80053c:	e9 cc fd ff ff       	jmp    80030d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 c2                	mov    %eax,%edx
  80054e:	c1 fa 1f             	sar    $0x1f,%edx
  800551:	31 d0                	xor    %edx,%eax
  800553:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800555:	83 f8 06             	cmp    $0x6,%eax
  800558:	7f 0b                	jg     800565 <vprintfmt+0x27b>
  80055a:	8b 14 85 b0 12 80 00 	mov    0x8012b0(,%eax,4),%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	75 23                	jne    800588 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800565:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800569:	c7 44 24 08 e0 10 80 	movl   $0x8010e0,0x8(%esp)
  800570:	00 
  800571:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800575:	8b 7d 08             	mov    0x8(%ebp),%edi
  800578:	89 3c 24             	mov    %edi,(%esp)
  80057b:	e8 42 fd ff ff       	call   8002c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800583:	e9 85 fd ff ff       	jmp    80030d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800588:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058c:	c7 44 24 08 e9 10 80 	movl   $0x8010e9,0x8(%esp)
  800593:	00 
  800594:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800598:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059b:	89 3c 24             	mov    %edi,(%esp)
  80059e:	e8 1f fd ff ff       	call   8002c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a6:	e9 62 fd ff ff       	jmp    80030d <vprintfmt+0x23>
  8005ab:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005bf:	85 f6                	test   %esi,%esi
  8005c1:	b8 c1 10 80 00       	mov    $0x8010c1,%eax
  8005c6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005c9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005cd:	7e 06                	jle    8005d5 <vprintfmt+0x2eb>
  8005cf:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005d3:	75 13                	jne    8005e8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d5:	0f be 06             	movsbl (%esi),%eax
  8005d8:	83 c6 01             	add    $0x1,%esi
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	0f 85 94 00 00 00    	jne    800677 <vprintfmt+0x38d>
  8005e3:	e9 81 00 00 00       	jmp    800669 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ec:	89 34 24             	mov    %esi,(%esp)
  8005ef:	e8 97 02 00 00       	call   80088b <strnlen>
  8005f4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005f7:	29 c2                	sub    %eax,%edx
  8005f9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	7e d5                	jle    8005d5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800600:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800604:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800607:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80060a:	89 d6                	mov    %edx,%esi
  80060c:	89 cf                	mov    %ecx,%edi
  80060e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800612:	89 3c 24             	mov    %edi,(%esp)
  800615:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800618:	83 ee 01             	sub    $0x1,%esi
  80061b:	75 f1                	jne    80060e <vprintfmt+0x324>
  80061d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800620:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800623:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800626:	eb ad                	jmp    8005d5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800628:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80062c:	74 1b                	je     800649 <vprintfmt+0x35f>
  80062e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800631:	83 fa 5e             	cmp    $0x5e,%edx
  800634:	76 13                	jbe    800649 <vprintfmt+0x35f>
					putch('?', putdat);
  800636:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
  800647:	eb 0d                	jmp    800656 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800649:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80064c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800656:	83 eb 01             	sub    $0x1,%ebx
  800659:	0f be 06             	movsbl (%esi),%eax
  80065c:	83 c6 01             	add    $0x1,%esi
  80065f:	85 c0                	test   %eax,%eax
  800661:	75 1a                	jne    80067d <vprintfmt+0x393>
  800663:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800666:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800670:	7f 1c                	jg     80068e <vprintfmt+0x3a4>
  800672:	e9 96 fc ff ff       	jmp    80030d <vprintfmt+0x23>
  800677:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80067a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067d:	85 ff                	test   %edi,%edi
  80067f:	78 a7                	js     800628 <vprintfmt+0x33e>
  800681:	83 ef 01             	sub    $0x1,%edi
  800684:	79 a2                	jns    800628 <vprintfmt+0x33e>
  800686:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800689:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80068c:	eb db                	jmp    800669 <vprintfmt+0x37f>
  80068e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800691:	89 de                	mov    %ebx,%esi
  800693:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800696:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a3:	83 eb 01             	sub    $0x1,%ebx
  8006a6:	75 ee                	jne    800696 <vprintfmt+0x3ac>
  8006a8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006ad:	e9 5b fc ff ff       	jmp    80030d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b2:	83 f9 01             	cmp    $0x1,%ecx
  8006b5:	7e 10                	jle    8006c7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 08             	lea    0x8(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 30                	mov    (%eax),%esi
  8006c2:	8b 78 04             	mov    0x4(%eax),%edi
  8006c5:	eb 26                	jmp    8006ed <vprintfmt+0x403>
	else if (lflag)
  8006c7:	85 c9                	test   %ecx,%ecx
  8006c9:	74 12                	je     8006dd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 30                	mov    (%eax),%esi
  8006d6:	89 f7                	mov    %esi,%edi
  8006d8:	c1 ff 1f             	sar    $0x1f,%edi
  8006db:	eb 10                	jmp    8006ed <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 30                	mov    (%eax),%esi
  8006e8:	89 f7                	mov    %esi,%edi
  8006ea:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ed:	85 ff                	test   %edi,%edi
  8006ef:	78 0e                	js     8006ff <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f1:	89 f0                	mov    %esi,%eax
  8006f3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f5:	be 0a 00 00 00       	mov    $0xa,%esi
  8006fa:	e9 84 00 00 00       	jmp    800783 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800703:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80070a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	89 fa                	mov    %edi,%edx
  800711:	f7 d8                	neg    %eax
  800713:	83 d2 00             	adc    $0x0,%edx
  800716:	f7 da                	neg    %edx
			}
			base = 10;
  800718:	be 0a 00 00 00       	mov    $0xa,%esi
  80071d:	eb 64                	jmp    800783 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071f:	89 ca                	mov    %ecx,%edx
  800721:	8d 45 14             	lea    0x14(%ebp),%eax
  800724:	e8 42 fb ff ff       	call   80026b <getuint>
			base = 10;
  800729:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80072e:	eb 53                	jmp    800783 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800730:	89 ca                	mov    %ecx,%edx
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	e8 31 fb ff ff       	call   80026b <getuint>
    			base = 8;
  80073a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80073f:	eb 42                	jmp    800783 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800741:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800745:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80074c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80074f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800753:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8d 50 04             	lea    0x4(%eax),%edx
  800763:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800766:	8b 00                	mov    (%eax),%eax
  800768:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800772:	eb 0f                	jmp    800783 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800774:	89 ca                	mov    %ecx,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 ed fa ff ff       	call   80026b <getuint>
			base = 16;
  80077e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800783:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800787:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80078b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80078e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800792:	89 74 24 08          	mov    %esi,0x8(%esp)
  800796:	89 04 24             	mov    %eax,(%esp)
  800799:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079d:	89 da                	mov    %ebx,%edx
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	e8 e9 f9 ff ff       	call   800190 <printnum>
			break;
  8007a7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007aa:	e9 5e fb ff ff       	jmp    80030d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b3:	89 14 24             	mov    %edx,(%esp)
  8007b6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007bc:	e9 4c fb ff ff       	jmp    80030d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007cc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d3:	0f 84 34 fb ff ff    	je     80030d <vprintfmt+0x23>
  8007d9:	83 ee 01             	sub    $0x1,%esi
  8007dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e0:	75 f7                	jne    8007d9 <vprintfmt+0x4ef>
  8007e2:	e9 26 fb ff ff       	jmp    80030d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007e7:	83 c4 5c             	add    $0x5c,%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 28             	sub    $0x28,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 30                	je     800840 <vsnprintf+0x51>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 2c                	jle    800840 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081b:	8b 45 10             	mov    0x10(%ebp),%eax
  80081e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800822:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800825:	89 44 24 04          	mov    %eax,0x4(%esp)
  800829:	c7 04 24 a5 02 80 00 	movl   $0x8002a5,(%esp)
  800830:	e8 b5 fa ff ff       	call   8002ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800835:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800838:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083e:	eb 05                	jmp    800845 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800840:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800850:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800854:	8b 45 10             	mov    0x10(%ebp),%eax
  800857:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	89 04 24             	mov    %eax,(%esp)
  800868:	e8 82 ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    
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
  800d33:	c7 44 24 08 cc 12 80 	movl   $0x8012cc,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 e9 12 80 00 	movl   $0x8012e9,(%esp)
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
  800db8:	c7 04 24 f8 12 80 00 	movl   $0x8012f8,(%esp)
  800dbf:	e8 af f3 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dcb:	89 04 24             	mov    %eax,(%esp)
  800dce:	e8 3f f3 ff ff       	call   800112 <vcprintf>
	cprintf("\n");
  800dd3:	c7 04 24 a4 10 80 00 	movl   $0x8010a4,(%esp)
  800dda:	e8 94 f3 ff ff       	call   800173 <cprintf>

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
