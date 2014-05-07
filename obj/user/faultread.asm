
obj/user/faultread.debug:     file format elf32-i386


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
  800043:	c7 04 24 00 23 80 00 	movl   $0x802300,(%esp)
  80004a:	e8 14 01 00 00       	call   800163 <cprintf>
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
  800078:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000aa:	e8 1f 12 00 00       	call   8012ce <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 34 0c 00 00       	call   800cef <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 14             	sub    $0x14,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 03                	mov    (%ebx),%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d3:	83 c0 01             	add    $0x1,%eax
  8000d6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 19                	jne    8000f8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e6:	00 
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	89 04 24             	mov    %eax,(%esp)
  8000ed:	e8 9e 0b 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  8000f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fc:	83 c4 14             	add    $0x14,%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800122:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	c7 04 24 c0 00 80 00 	movl   $0x8000c0,(%esp)
  80013e:	e8 97 01 00 00       	call   8002da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	e8 35 0b 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  80015b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800169:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	8b 45 08             	mov    0x8(%ebp),%eax
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 87 ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    
  80017d:	00 00                	add    %al,(%eax)
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a8:	72 11                	jb     8001bb <printnum+0x3b>
  8001aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b0:	76 09                	jbe    8001bb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b2:	83 eb 01             	sub    $0x1,%ebx
  8001b5:	85 db                	test   %ebx,%ebx
  8001b7:	7f 51                	jg     80020a <printnum+0x8a>
  8001b9:	eb 5e                	jmp    800219 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001bf:	83 eb 01             	sub    $0x1,%ebx
  8001c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001dc:	00 
  8001dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	e8 61 1e 00 00       	call   802050 <__udivdi3>
  8001ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fe:	89 fa                	mov    %edi,%edx
  800200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800203:	e8 78 ff ff ff       	call   800180 <printnum>
  800208:	eb 0f                	jmp    800219 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020e:	89 34 24             	mov    %esi,(%esp)
  800211:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800214:	83 eb 01             	sub    $0x1,%ebx
  800217:	75 f1                	jne    80020a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800219:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800221:	8b 45 10             	mov    0x10(%ebp),%eax
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	e8 3e 1f 00 00       	call   802180 <__umoddi3>
  800242:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800246:	0f be 80 28 23 80 00 	movsbl 0x802328(%eax),%eax
  80024d:	89 04 24             	mov    %eax,(%esp)
  800250:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800253:	83 c4 3c             	add    $0x3c,%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025e:	83 fa 01             	cmp    $0x1,%edx
  800261:	7e 0e                	jle    800271 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800263:	8b 10                	mov    (%eax),%edx
  800265:	8d 4a 08             	lea    0x8(%edx),%ecx
  800268:	89 08                	mov    %ecx,(%eax)
  80026a:	8b 02                	mov    (%edx),%eax
  80026c:	8b 52 04             	mov    0x4(%edx),%edx
  80026f:	eb 22                	jmp    800293 <getuint+0x38>
	else if (lflag)
  800271:	85 d2                	test   %edx,%edx
  800273:	74 10                	je     800285 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800275:	8b 10                	mov    (%eax),%edx
  800277:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027a:	89 08                	mov    %ecx,(%eax)
  80027c:	8b 02                	mov    (%edx),%eax
  80027e:	ba 00 00 00 00       	mov    $0x0,%edx
  800283:	eb 0e                	jmp    800293 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a4:	73 0a                	jae    8002b0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a9:	88 0a                	mov    %cl,(%edx)
  8002ab:	83 c2 01             	add    $0x1,%edx
  8002ae:	89 10                	mov    %edx,(%eax)
}
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	e8 02 00 00 00       	call   8002da <vprintfmt>
	va_end(ap);
}
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 5c             	sub    $0x5c,%esp
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e9:	eb 12                	jmp    8002fd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 e4 04 00 00    	je     8007d7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fd:	0f b6 06             	movzbl (%esi),%eax
  800300:	83 c6 01             	add    $0x1,%esi
  800303:	83 f8 25             	cmp    $0x25,%eax
  800306:	75 e3                	jne    8002eb <vprintfmt+0x11>
  800308:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80030c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800313:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800318:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800327:	eb 2b                	jmp    800354 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800330:	eb 22                	jmp    800354 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800335:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800339:	eb 19                	jmp    800354 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80033e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800345:	eb 0d                	jmp    800354 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800347:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80034a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80034d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	0f b6 06             	movzbl (%esi),%eax
  800357:	0f b6 d0             	movzbl %al,%edx
  80035a:	8d 7e 01             	lea    0x1(%esi),%edi
  80035d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800360:	83 e8 23             	sub    $0x23,%eax
  800363:	3c 55                	cmp    $0x55,%al
  800365:	0f 87 46 04 00 00    	ja     8007b1 <vprintfmt+0x4d7>
  80036b:	0f b6 c0             	movzbl %al,%eax
  80036e:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800375:	83 ea 30             	sub    $0x30,%edx
  800378:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80037b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80037f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800385:	83 fa 09             	cmp    $0x9,%edx
  800388:	77 4a                	ja     8003d4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800390:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800393:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800397:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80039d:	83 fa 09             	cmp    $0x9,%edx
  8003a0:	76 eb                	jbe    80038d <vprintfmt+0xb3>
  8003a2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003a5:	eb 2d                	jmp    8003d4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 50 04             	lea    0x4(%eax),%edx
  8003ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b8:	eb 1a                	jmp    8003d4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003bd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003c1:	79 91                	jns    800354 <vprintfmt+0x7a>
  8003c3:	e9 73 ff ff ff       	jmp    80033b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003cb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003d2:	eb 80                	jmp    800354 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003d4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003d8:	0f 89 76 ff ff ff    	jns    800354 <vprintfmt+0x7a>
  8003de:	e9 64 ff ff ff       	jmp    800347 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 66 ff ff ff       	jmp    800354 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	89 04 24             	mov    %eax,(%esp)
  800400:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800406:	e9 f2 fe ff ff       	jmp    8002fd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80040b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80040f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800412:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800416:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800419:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80041d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800420:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800423:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800427:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80042a:	80 f9 09             	cmp    $0x9,%cl
  80042d:	77 1d                	ja     80044c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80042f:	0f be c0             	movsbl %al,%eax
  800432:	6b c0 64             	imul   $0x64,%eax,%eax
  800435:	0f be d2             	movsbl %dl,%edx
  800438:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80043b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800442:	a3 04 30 80 00       	mov    %eax,0x803004
  800447:	e9 b1 fe ff ff       	jmp    8002fd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80044c:	c7 44 24 04 40 23 80 	movl   $0x802340,0x4(%esp)
  800453:	00 
  800454:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800457:	89 04 24             	mov    %eax,(%esp)
  80045a:	e8 0c 05 00 00       	call   80096b <strcmp>
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 0f                	jne    800472 <vprintfmt+0x198>
  800463:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  80046a:	00 00 00 
  80046d:	e9 8b fe ff ff       	jmp    8002fd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800472:	c7 44 24 04 44 23 80 	movl   $0x802344,0x4(%esp)
  800479:	00 
  80047a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80047d:	89 14 24             	mov    %edx,(%esp)
  800480:	e8 e6 04 00 00       	call   80096b <strcmp>
  800485:	85 c0                	test   %eax,%eax
  800487:	75 0f                	jne    800498 <vprintfmt+0x1be>
  800489:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800490:	00 00 00 
  800493:	e9 65 fe ff ff       	jmp    8002fd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800498:	c7 44 24 04 48 23 80 	movl   $0x802348,0x4(%esp)
  80049f:	00 
  8004a0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004a3:	89 0c 24             	mov    %ecx,(%esp)
  8004a6:	e8 c0 04 00 00       	call   80096b <strcmp>
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 0f                	jne    8004be <vprintfmt+0x1e4>
  8004af:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8004b6:	00 00 00 
  8004b9:	e9 3f fe ff ff       	jmp    8002fd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004be:	c7 44 24 04 4c 23 80 	movl   $0x80234c,0x4(%esp)
  8004c5:	00 
  8004c6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004c9:	89 3c 24             	mov    %edi,(%esp)
  8004cc:	e8 9a 04 00 00       	call   80096b <strcmp>
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 0f                	jne    8004e4 <vprintfmt+0x20a>
  8004d5:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  8004dc:	00 00 00 
  8004df:	e9 19 fe ff ff       	jmp    8002fd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004e4:	c7 44 24 04 50 23 80 	movl   $0x802350,0x4(%esp)
  8004eb:	00 
  8004ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	e8 74 04 00 00       	call   80096b <strcmp>
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	75 0f                	jne    80050a <vprintfmt+0x230>
  8004fb:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800502:	00 00 00 
  800505:	e9 f3 fd ff ff       	jmp    8002fd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80050a:	c7 44 24 04 54 23 80 	movl   $0x802354,0x4(%esp)
  800511:	00 
  800512:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800515:	89 14 24             	mov    %edx,(%esp)
  800518:	e8 4e 04 00 00       	call   80096b <strcmp>
  80051d:	83 f8 01             	cmp    $0x1,%eax
  800520:	19 c0                	sbb    %eax,%eax
  800522:	f7 d0                	not    %eax
  800524:	83 c0 08             	add    $0x8,%eax
  800527:	a3 04 30 80 00       	mov    %eax,0x803004
  80052c:	e9 cc fd ff ff       	jmp    8002fd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 c2                	mov    %eax,%edx
  80053e:	c1 fa 1f             	sar    $0x1f,%edx
  800541:	31 d0                	xor    %edx,%eax
  800543:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800545:	83 f8 0f             	cmp    $0xf,%eax
  800548:	7f 0b                	jg     800555 <vprintfmt+0x27b>
  80054a:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800551:	85 d2                	test   %edx,%edx
  800553:	75 23                	jne    800578 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800555:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800559:	c7 44 24 08 58 23 80 	movl   $0x802358,0x8(%esp)
  800560:	00 
  800561:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800565:	8b 7d 08             	mov    0x8(%ebp),%edi
  800568:	89 3c 24             	mov    %edi,(%esp)
  80056b:	e8 42 fd ff ff       	call   8002b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800573:	e9 85 fd ff ff       	jmp    8002fd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800578:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057c:	c7 44 24 08 11 27 80 	movl   $0x802711,0x8(%esp)
  800583:	00 
  800584:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800588:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058b:	89 3c 24             	mov    %edi,(%esp)
  80058e:	e8 1f fd ff ff       	call   8002b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800593:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800596:	e9 62 fd ff ff       	jmp    8002fd <vprintfmt+0x23>
  80059b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80059e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005af:	85 f6                	test   %esi,%esi
  8005b1:	b8 39 23 80 00       	mov    $0x802339,%eax
  8005b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005b9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005bd:	7e 06                	jle    8005c5 <vprintfmt+0x2eb>
  8005bf:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005c3:	75 13                	jne    8005d8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	83 c6 01             	add    $0x1,%esi
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	0f 85 94 00 00 00    	jne    800667 <vprintfmt+0x38d>
  8005d3:	e9 81 00 00 00       	jmp    800659 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dc:	89 34 24             	mov    %esi,(%esp)
  8005df:	e8 97 02 00 00       	call   80087b <strnlen>
  8005e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005e7:	29 c2                	sub    %eax,%edx
  8005e9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	7e d5                	jle    8005c5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005f0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8005f4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005f7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8005fa:	89 d6                	mov    %edx,%esi
  8005fc:	89 cf                	mov    %ecx,%edi
  8005fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800602:	89 3c 24             	mov    %edi,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800608:	83 ee 01             	sub    $0x1,%esi
  80060b:	75 f1                	jne    8005fe <vprintfmt+0x324>
  80060d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800610:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800613:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800616:	eb ad                	jmp    8005c5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80061c:	74 1b                	je     800639 <vprintfmt+0x35f>
  80061e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800621:	83 fa 5e             	cmp    $0x5e,%edx
  800624:	76 13                	jbe    800639 <vprintfmt+0x35f>
					putch('?', putdat);
  800626:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800639:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80063c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	0f be 06             	movsbl (%esi),%eax
  80064c:	83 c6 01             	add    $0x1,%esi
  80064f:	85 c0                	test   %eax,%eax
  800651:	75 1a                	jne    80066d <vprintfmt+0x393>
  800653:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800656:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800660:	7f 1c                	jg     80067e <vprintfmt+0x3a4>
  800662:	e9 96 fc ff ff       	jmp    8002fd <vprintfmt+0x23>
  800667:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80066a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066d:	85 ff                	test   %edi,%edi
  80066f:	78 a7                	js     800618 <vprintfmt+0x33e>
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	79 a2                	jns    800618 <vprintfmt+0x33e>
  800676:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800679:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80067c:	eb db                	jmp    800659 <vprintfmt+0x37f>
  80067e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800681:	89 de                	mov    %ebx,%esi
  800683:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800686:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800691:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800693:	83 eb 01             	sub    $0x1,%ebx
  800696:	75 ee                	jne    800686 <vprintfmt+0x3ac>
  800698:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80069d:	e9 5b fc ff ff       	jmp    8002fd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a2:	83 f9 01             	cmp    $0x1,%ecx
  8006a5:	7e 10                	jle    8006b7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 08             	lea    0x8(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 30                	mov    (%eax),%esi
  8006b2:	8b 78 04             	mov    0x4(%eax),%edi
  8006b5:	eb 26                	jmp    8006dd <vprintfmt+0x403>
	else if (lflag)
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	74 12                	je     8006cd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 30                	mov    (%eax),%esi
  8006c6:	89 f7                	mov    %esi,%edi
  8006c8:	c1 ff 1f             	sar    $0x1f,%edi
  8006cb:	eb 10                	jmp    8006dd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	8b 30                	mov    (%eax),%esi
  8006d8:	89 f7                	mov    %esi,%edi
  8006da:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006dd:	85 ff                	test   %edi,%edi
  8006df:	78 0e                	js     8006ef <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e5:	be 0a 00 00 00       	mov    $0xa,%esi
  8006ea:	e9 84 00 00 00       	jmp    800773 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fd:	89 f0                	mov    %esi,%eax
  8006ff:	89 fa                	mov    %edi,%edx
  800701:	f7 d8                	neg    %eax
  800703:	83 d2 00             	adc    $0x0,%edx
  800706:	f7 da                	neg    %edx
			}
			base = 10;
  800708:	be 0a 00 00 00       	mov    $0xa,%esi
  80070d:	eb 64                	jmp    800773 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070f:	89 ca                	mov    %ecx,%edx
  800711:	8d 45 14             	lea    0x14(%ebp),%eax
  800714:	e8 42 fb ff ff       	call   80025b <getuint>
			base = 10;
  800719:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80071e:	eb 53                	jmp    800773 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800720:	89 ca                	mov    %ecx,%edx
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
  800725:	e8 31 fb ff ff       	call   80025b <getuint>
    			base = 8;
  80072a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80072f:	eb 42                	jmp    800773 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800731:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800735:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80073c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800743:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8d 50 04             	lea    0x4(%eax),%edx
  800753:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800756:	8b 00                	mov    (%eax),%eax
  800758:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800762:	eb 0f                	jmp    800773 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800764:	89 ca                	mov    %ecx,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 ed fa ff ff       	call   80025b <getuint>
			base = 16;
  80076e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800773:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800777:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80077b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80077e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800782:	89 74 24 08          	mov    %esi,0x8(%esp)
  800786:	89 04 24             	mov    %eax,(%esp)
  800789:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078d:	89 da                	mov    %ebx,%edx
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	e8 e9 f9 ff ff       	call   800180 <printnum>
			break;
  800797:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80079a:	e9 5e fb ff ff       	jmp    8002fd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a3:	89 14 24             	mov    %edx,(%esp)
  8007a6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ac:	e9 4c fb ff ff       	jmp    8002fd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007bc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c3:	0f 84 34 fb ff ff    	je     8002fd <vprintfmt+0x23>
  8007c9:	83 ee 01             	sub    $0x1,%esi
  8007cc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d0:	75 f7                	jne    8007c9 <vprintfmt+0x4ef>
  8007d2:	e9 26 fb ff ff       	jmp    8002fd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007d7:	83 c4 5c             	add    $0x5c,%esp
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5f                   	pop    %edi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 28             	sub    $0x28,%esp
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	74 30                	je     800830 <vsnprintf+0x51>
  800800:	85 d2                	test   %edx,%edx
  800802:	7e 2c                	jle    800830 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080b:	8b 45 10             	mov    0x10(%ebp),%eax
  80080e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800812:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800815:	89 44 24 04          	mov    %eax,0x4(%esp)
  800819:	c7 04 24 95 02 80 00 	movl   $0x800295,(%esp)
  800820:	e8 b5 fa ff ff       	call   8002da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800825:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800828:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082e:	eb 05                	jmp    800835 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800840:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800844:	8b 45 10             	mov    0x10(%ebp),%eax
  800847:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	89 04 24             	mov    %eax,(%esp)
  800858:	e8 82 ff ff ff       	call   8007df <vsnprintf>
	va_end(ap);

	return rc;
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    
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
  800d23:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800d3a:	e8 61 11 00 00       	call   801ea0 <_panic>

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
  800d90:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800de2:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800de9:	00 
  800dea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df1:	00 
  800df2:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800df9:	e8 a2 10 00 00       	call   801ea0 <_panic>

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
  800e40:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800e47:	00 
  800e48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4f:	00 
  800e50:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800e57:	e8 44 10 00 00       	call   801ea0 <_panic>

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
  800e9e:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ead:	00 
  800eae:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800eb5:	e8 e6 0f 00 00       	call   801ea0 <_panic>

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
  800efc:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800f13:	e8 88 0f 00 00       	call   801ea0 <_panic>

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

00800f25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800f4c:	7e 28                	jle    800f76 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f52:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800f71:	e8 2a 0f 00 00       	call   801ea0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7f:	89 ec                	mov    %ebp,%esp
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 38             	sub    $0x38,%esp
  800f89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	89 df                	mov    %ebx,%edi
  800fa4:	89 de                	mov    %ebx,%esi
  800fa6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 28                	jle    800fd4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800fbf:	00 
  800fc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc7:	00 
  800fc8:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800fcf:	e8 cc 0e 00 00       	call   801ea0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fdd:	89 ec                	mov    %ebp,%esp
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fed:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff0:	be 00 00 00 00       	mov    $0x0,%esi
  800ff5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ffa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ffd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801008:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801011:	89 ec                	mov    %ebp,%esp
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 38             	sub    $0x38,%esp
  80101b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80101e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801021:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801024:	b9 00 00 00 00       	mov    $0x0,%ecx
  801029:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102e:	8b 55 08             	mov    0x8(%ebp),%edx
  801031:	89 cb                	mov    %ecx,%ebx
  801033:	89 cf                	mov    %ecx,%edi
  801035:	89 ce                	mov    %ecx,%esi
  801037:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801039:	85 c0                	test   %eax,%eax
  80103b:	7e 28                	jle    801065 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801041:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801048:	00 
  801049:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  801050:	00 
  801051:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801058:	00 
  801059:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  801060:	e8 3b 0e 00 00       	call   801ea0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801065:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801068:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80106e:	89 ec                	mov    %ebp,%esp
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80107b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80107e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801081:	b9 00 00 00 00       	mov    $0x0,%ecx
  801086:	b8 0e 00 00 00       	mov    $0xe,%eax
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	89 cb                	mov    %ecx,%ebx
  801090:	89 cf                	mov    %ecx,%edi
  801092:	89 ce                	mov    %ecx,%esi
  801094:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801096:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801099:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80109c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80109f:	89 ec                	mov    %ebp,%esp
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    
	...

008010b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    

008010c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	89 04 24             	mov    %eax,(%esp)
  8010cc:	e8 df ff ff ff       	call   8010b0 <fd2num>
  8010d1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010d6:	c1 e0 0c             	shl    $0xc,%eax
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010e7:	a8 01                	test   $0x1,%al
  8010e9:	74 34                	je     80111f <fd_alloc+0x44>
  8010eb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010f0:	a8 01                	test   $0x1,%al
  8010f2:	74 32                	je     801126 <fd_alloc+0x4b>
  8010f4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010f9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 ea 16             	shr    $0x16,%edx
  801100:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	74 1f                	je     80112b <fd_alloc+0x50>
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	c1 ea 0c             	shr    $0xc,%edx
  801111:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801118:	f6 c2 01             	test   $0x1,%dl
  80111b:	75 17                	jne    801134 <fd_alloc+0x59>
  80111d:	eb 0c                	jmp    80112b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80111f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801124:	eb 05                	jmp    80112b <fd_alloc+0x50>
  801126:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80112b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
  801132:	eb 17                	jmp    80114b <fd_alloc+0x70>
  801134:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801139:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80113e:	75 b9                	jne    8010f9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801140:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801146:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80114b:	5b                   	pop    %ebx
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    

0080114e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801154:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801159:	83 fa 1f             	cmp    $0x1f,%edx
  80115c:	77 3f                	ja     80119d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80115e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801164:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801167:	89 d0                	mov    %edx,%eax
  801169:	c1 e8 16             	shr    $0x16,%eax
  80116c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801178:	f6 c1 01             	test   $0x1,%cl
  80117b:	74 20                	je     80119d <fd_lookup+0x4f>
  80117d:	89 d0                	mov    %edx,%eax
  80117f:	c1 e8 0c             	shr    $0xc,%eax
  801182:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801189:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80118e:	f6 c1 01             	test   $0x1,%cl
  801191:	74 0a                	je     80119d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801193:	8b 45 0c             	mov    0xc(%ebp),%eax
  801196:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 14             	sub    $0x14,%esp
  8011a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011b1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8011b7:	75 17                	jne    8011d0 <dev_lookup+0x31>
  8011b9:	eb 07                	jmp    8011c2 <dev_lookup+0x23>
  8011bb:	39 0a                	cmp    %ecx,(%edx)
  8011bd:	75 11                	jne    8011d0 <dev_lookup+0x31>
  8011bf:	90                   	nop
  8011c0:	eb 05                	jmp    8011c7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c2:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011c7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ce:	eb 35                	jmp    801205 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d0:	83 c0 01             	add    $0x1,%eax
  8011d3:	8b 14 85 e8 26 80 00 	mov    0x8026e8(,%eax,4),%edx
  8011da:	85 d2                	test   %edx,%edx
  8011dc:	75 dd                	jne    8011bb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011de:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e3:	8b 40 48             	mov    0x48(%eax),%eax
  8011e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ee:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  8011f5:	e8 69 ef ff ff       	call   800163 <cprintf>
	*dev = 0;
  8011fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801205:	83 c4 14             	add    $0x14,%esp
  801208:	5b                   	pop    %ebx
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	83 ec 38             	sub    $0x38,%esp
  801211:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801214:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801217:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80121a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801221:	89 3c 24             	mov    %edi,(%esp)
  801224:	e8 87 fe ff ff       	call   8010b0 <fd2num>
  801229:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80122c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801230:	89 04 24             	mov    %eax,(%esp)
  801233:	e8 16 ff ff ff       	call   80114e <fd_lookup>
  801238:	89 c3                	mov    %eax,%ebx
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 05                	js     801243 <fd_close+0x38>
	    || fd != fd2)
  80123e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801241:	74 0e                	je     801251 <fd_close+0x46>
		return (must_exist ? r : 0);
  801243:	89 f0                	mov    %esi,%eax
  801245:	84 c0                	test   %al,%al
  801247:	b8 00 00 00 00       	mov    $0x0,%eax
  80124c:	0f 44 d8             	cmove  %eax,%ebx
  80124f:	eb 3d                	jmp    80128e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801251:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801254:	89 44 24 04          	mov    %eax,0x4(%esp)
  801258:	8b 07                	mov    (%edi),%eax
  80125a:	89 04 24             	mov    %eax,(%esp)
  80125d:	e8 3d ff ff ff       	call   80119f <dev_lookup>
  801262:	89 c3                	mov    %eax,%ebx
  801264:	85 c0                	test   %eax,%eax
  801266:	78 16                	js     80127e <fd_close+0x73>
		if (dev->dev_close)
  801268:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80126b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80126e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801273:	85 c0                	test   %eax,%eax
  801275:	74 07                	je     80127e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801277:	89 3c 24             	mov    %edi,(%esp)
  80127a:	ff d0                	call   *%eax
  80127c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80127e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801282:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801289:	e8 db fb ff ff       	call   800e69 <sys_page_unmap>
	return r;
}
  80128e:	89 d8                	mov    %ebx,%eax
  801290:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801293:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801296:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801299:	89 ec                	mov    %ebp,%esp
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	89 04 24             	mov    %eax,(%esp)
  8012b0:	e8 99 fe ff ff       	call   80114e <fd_lookup>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 13                	js     8012cc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012c0:	00 
  8012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c4:	89 04 24             	mov    %eax,(%esp)
  8012c7:	e8 3f ff ff ff       	call   80120b <fd_close>
}
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <close_all>:

void
close_all(void)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012da:	89 1c 24             	mov    %ebx,(%esp)
  8012dd:	e8 bb ff ff ff       	call   80129d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e2:	83 c3 01             	add    $0x1,%ebx
  8012e5:	83 fb 20             	cmp    $0x20,%ebx
  8012e8:	75 f0                	jne    8012da <close_all+0xc>
		close(i);
}
  8012ea:	83 c4 14             	add    $0x14,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 58             	sub    $0x58,%esp
  8012f6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801302:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	8b 45 08             	mov    0x8(%ebp),%eax
  80130c:	89 04 24             	mov    %eax,(%esp)
  80130f:	e8 3a fe ff ff       	call   80114e <fd_lookup>
  801314:	89 c3                	mov    %eax,%ebx
  801316:	85 c0                	test   %eax,%eax
  801318:	0f 88 e1 00 00 00    	js     8013ff <dup+0x10f>
		return r;
	close(newfdnum);
  80131e:	89 3c 24             	mov    %edi,(%esp)
  801321:	e8 77 ff ff ff       	call   80129d <close>

	newfd = INDEX2FD(newfdnum);
  801326:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80132c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80132f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	e8 86 fd ff ff       	call   8010c0 <fd2data>
  80133a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80133c:	89 34 24             	mov    %esi,(%esp)
  80133f:	e8 7c fd ff ff       	call   8010c0 <fd2data>
  801344:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801347:	89 d8                	mov    %ebx,%eax
  801349:	c1 e8 16             	shr    $0x16,%eax
  80134c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801353:	a8 01                	test   $0x1,%al
  801355:	74 46                	je     80139d <dup+0xad>
  801357:	89 d8                	mov    %ebx,%eax
  801359:	c1 e8 0c             	shr    $0xc,%eax
  80135c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 35                	je     80139d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801368:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136f:	25 07 0e 00 00       	and    $0xe07,%eax
  801374:	89 44 24 10          	mov    %eax,0x10(%esp)
  801378:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80137b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80137f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801386:	00 
  801387:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80138b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801392:	e8 74 fa ff ff       	call   800e0b <sys_page_map>
  801397:	89 c3                	mov    %eax,%ebx
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 3b                	js     8013d8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a0:	89 c2                	mov    %eax,%edx
  8013a2:	c1 ea 0c             	shr    $0xc,%edx
  8013a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ac:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013b2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013c1:	00 
  8013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013cd:	e8 39 fa ff ff       	call   800e0b <sys_page_map>
  8013d2:	89 c3                	mov    %eax,%ebx
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	79 25                	jns    8013fd <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e3:	e8 81 fa ff ff       	call   800e69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f6:	e8 6e fa ff ff       	call   800e69 <sys_page_unmap>
	return r;
  8013fb:	eb 02                	jmp    8013ff <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013fd:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013ff:	89 d8                	mov    %ebx,%eax
  801401:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801404:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801407:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80140a:	89 ec                	mov    %ebp,%esp
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	53                   	push   %ebx
  801412:	83 ec 24             	sub    $0x24,%esp
  801415:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801418:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	89 1c 24             	mov    %ebx,(%esp)
  801422:	e8 27 fd ff ff       	call   80114e <fd_lookup>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 6d                	js     801498 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801432:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801435:	8b 00                	mov    (%eax),%eax
  801437:	89 04 24             	mov    %eax,(%esp)
  80143a:	e8 60 fd ff ff       	call   80119f <dev_lookup>
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 55                	js     801498 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801446:	8b 50 08             	mov    0x8(%eax),%edx
  801449:	83 e2 03             	and    $0x3,%edx
  80144c:	83 fa 01             	cmp    $0x1,%edx
  80144f:	75 23                	jne    801474 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801451:	a1 04 40 80 00       	mov    0x804004,%eax
  801456:	8b 40 48             	mov    0x48(%eax),%eax
  801459:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80145d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801461:	c7 04 24 ad 26 80 00 	movl   $0x8026ad,(%esp)
  801468:	e8 f6 ec ff ff       	call   800163 <cprintf>
		return -E_INVAL;
  80146d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801472:	eb 24                	jmp    801498 <read+0x8a>
	}
	if (!dev->dev_read)
  801474:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801477:	8b 52 08             	mov    0x8(%edx),%edx
  80147a:	85 d2                	test   %edx,%edx
  80147c:	74 15                	je     801493 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80147e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801481:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801485:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801488:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80148c:	89 04 24             	mov    %eax,(%esp)
  80148f:	ff d2                	call   *%edx
  801491:	eb 05                	jmp    801498 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801493:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801498:	83 c4 24             	add    $0x24,%esp
  80149b:	5b                   	pop    %ebx
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	57                   	push   %edi
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 1c             	sub    $0x1c,%esp
  8014a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b2:	85 f6                	test   %esi,%esi
  8014b4:	74 30                	je     8014e6 <readn+0x48>
  8014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bb:	89 f2                	mov    %esi,%edx
  8014bd:	29 c2                	sub    %eax,%edx
  8014bf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014c3:	03 45 0c             	add    0xc(%ebp),%eax
  8014c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ca:	89 3c 24             	mov    %edi,(%esp)
  8014cd:	e8 3c ff ff ff       	call   80140e <read>
		if (m < 0)
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 10                	js     8014e6 <readn+0x48>
			return m;
		if (m == 0)
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	74 0a                	je     8014e4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014da:	01 c3                	add    %eax,%ebx
  8014dc:	89 d8                	mov    %ebx,%eax
  8014de:	39 f3                	cmp    %esi,%ebx
  8014e0:	72 d9                	jb     8014bb <readn+0x1d>
  8014e2:	eb 02                	jmp    8014e6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014e4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014e6:	83 c4 1c             	add    $0x1c,%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 24             	sub    $0x24,%esp
  8014f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ff:	89 1c 24             	mov    %ebx,(%esp)
  801502:	e8 47 fc ff ff       	call   80114e <fd_lookup>
  801507:	85 c0                	test   %eax,%eax
  801509:	78 68                	js     801573 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801512:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801515:	8b 00                	mov    (%eax),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 80 fc ff ff       	call   80119f <dev_lookup>
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 50                	js     801573 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152a:	75 23                	jne    80154f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152c:	a1 04 40 80 00       	mov    0x804004,%eax
  801531:	8b 40 48             	mov    0x48(%eax),%eax
  801534:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801538:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153c:	c7 04 24 c9 26 80 00 	movl   $0x8026c9,(%esp)
  801543:	e8 1b ec ff ff       	call   800163 <cprintf>
		return -E_INVAL;
  801548:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154d:	eb 24                	jmp    801573 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801552:	8b 52 0c             	mov    0xc(%edx),%edx
  801555:	85 d2                	test   %edx,%edx
  801557:	74 15                	je     80156e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801559:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80155c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801560:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801563:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801567:	89 04 24             	mov    %eax,(%esp)
  80156a:	ff d2                	call   *%edx
  80156c:	eb 05                	jmp    801573 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801573:	83 c4 24             	add    $0x24,%esp
  801576:	5b                   	pop    %ebx
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <seek>:

int
seek(int fdnum, off_t offset)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801582:	89 44 24 04          	mov    %eax,0x4(%esp)
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	89 04 24             	mov    %eax,(%esp)
  80158c:	e8 bd fb ff ff       	call   80114e <fd_lookup>
  801591:	85 c0                	test   %eax,%eax
  801593:	78 0e                	js     8015a3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801595:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801598:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 24             	sub    $0x24,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b6:	89 1c 24             	mov    %ebx,(%esp)
  8015b9:	e8 90 fb ff ff       	call   80114e <fd_lookup>
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 61                	js     801623 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cc:	8b 00                	mov    (%eax),%eax
  8015ce:	89 04 24             	mov    %eax,(%esp)
  8015d1:	e8 c9 fb ff ff       	call   80119f <dev_lookup>
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 49                	js     801623 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e1:	75 23                	jne    801606 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e8:	8b 40 48             	mov    0x48(%eax),%eax
  8015eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f3:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8015fa:	e8 64 eb ff ff       	call   800163 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801604:	eb 1d                	jmp    801623 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801606:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801609:	8b 52 18             	mov    0x18(%edx),%edx
  80160c:	85 d2                	test   %edx,%edx
  80160e:	74 0e                	je     80161e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801610:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801613:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801617:	89 04 24             	mov    %eax,(%esp)
  80161a:	ff d2                	call   *%edx
  80161c:	eb 05                	jmp    801623 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801623:	83 c4 24             	add    $0x24,%esp
  801626:	5b                   	pop    %ebx
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	53                   	push   %ebx
  80162d:	83 ec 24             	sub    $0x24,%esp
  801630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	89 04 24             	mov    %eax,(%esp)
  801640:	e8 09 fb ff ff       	call   80114e <fd_lookup>
  801645:	85 c0                	test   %eax,%eax
  801647:	78 52                	js     80169b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801649:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801653:	8b 00                	mov    (%eax),%eax
  801655:	89 04 24             	mov    %eax,(%esp)
  801658:	e8 42 fb ff ff       	call   80119f <dev_lookup>
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 3a                	js     80169b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801668:	74 2c                	je     801696 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801674:	00 00 00 
	stat->st_isdir = 0;
  801677:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167e:	00 00 00 
	stat->st_dev = dev;
  801681:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801687:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80168b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80168e:	89 14 24             	mov    %edx,(%esp)
  801691:	ff 50 14             	call   *0x14(%eax)
  801694:	eb 05                	jmp    80169b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801696:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80169b:	83 c4 24             	add    $0x24,%esp
  80169e:	5b                   	pop    %ebx
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 18             	sub    $0x18,%esp
  8016a7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016aa:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016b4:	00 
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	89 04 24             	mov    %eax,(%esp)
  8016bb:	e8 bc 01 00 00       	call   80187c <open>
  8016c0:	89 c3                	mov    %eax,%ebx
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 1b                	js     8016e1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	e8 54 ff ff ff       	call   801629 <fstat>
  8016d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d7:	89 1c 24             	mov    %ebx,(%esp)
  8016da:	e8 be fb ff ff       	call   80129d <close>
	return r;
  8016df:	89 f3                	mov    %esi,%ebx
}
  8016e1:	89 d8                	mov    %ebx,%eax
  8016e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016e6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016e9:	89 ec                	mov    %ebp,%esp
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    
  8016ed:	00 00                	add    %al,(%eax)
	...

008016f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 18             	sub    $0x18,%esp
  8016f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016f9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8016fc:	89 c3                	mov    %eax,%ebx
  8016fe:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801700:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801707:	75 11                	jne    80171a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801709:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801710:	e8 b4 08 00 00       	call   801fc9 <ipc_find_env>
  801715:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80171a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801721:	00 
  801722:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801729:	00 
  80172a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80172e:	a1 00 40 80 00       	mov    0x804000,%eax
  801733:	89 04 24             	mov    %eax,(%esp)
  801736:	e8 23 08 00 00       	call   801f5e <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80173b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801742:	00 
  801743:	89 74 24 04          	mov    %esi,0x4(%esp)
  801747:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80174e:	e8 a5 07 00 00       	call   801ef8 <ipc_recv>
}
  801753:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801756:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801759:	89 ec                	mov    %ebp,%esp
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	53                   	push   %ebx
  801761:	83 ec 14             	sub    $0x14,%esp
  801764:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	8b 40 0c             	mov    0xc(%eax),%eax
  80176d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801772:	ba 00 00 00 00       	mov    $0x0,%edx
  801777:	b8 05 00 00 00       	mov    $0x5,%eax
  80177c:	e8 6f ff ff ff       	call   8016f0 <fsipc>
  801781:	85 c0                	test   %eax,%eax
  801783:	78 2b                	js     8017b0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801785:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80178c:	00 
  80178d:	89 1c 24             	mov    %ebx,(%esp)
  801790:	e8 16 f1 ff ff       	call   8008ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801795:	a1 80 50 80 00       	mov    0x805080,%eax
  80179a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b0:	83 c4 14             	add    $0x14,%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d1:	e8 1a ff ff ff       	call   8016f0 <fsipc>
}
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    

008017d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 10             	sub    $0x10,%esp
  8017e0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017fe:	e8 ed fe ff ff       	call   8016f0 <fsipc>
  801803:	89 c3                	mov    %eax,%ebx
  801805:	85 c0                	test   %eax,%eax
  801807:	78 6a                	js     801873 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801809:	39 c6                	cmp    %eax,%esi
  80180b:	73 24                	jae    801831 <devfile_read+0x59>
  80180d:	c7 44 24 0c f8 26 80 	movl   $0x8026f8,0xc(%esp)
  801814:	00 
  801815:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  80181c:	00 
  80181d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801824:	00 
  801825:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  80182c:	e8 6f 06 00 00       	call   801ea0 <_panic>
	assert(r <= PGSIZE);
  801831:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801836:	7e 24                	jle    80185c <devfile_read+0x84>
  801838:	c7 44 24 0c 1f 27 80 	movl   $0x80271f,0xc(%esp)
  80183f:	00 
  801840:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  801847:	00 
  801848:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80184f:	00 
  801850:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  801857:	e8 44 06 00 00       	call   801ea0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80185c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801860:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801867:	00 
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	89 04 24             	mov    %eax,(%esp)
  80186e:	e8 29 f2 ff ff       	call   800a9c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801873:	89 d8                	mov    %ebx,%eax
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	83 ec 20             	sub    $0x20,%esp
  801884:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801887:	89 34 24             	mov    %esi,(%esp)
  80188a:	e8 d1 ef ff ff       	call   800860 <strlen>
		return -E_BAD_PATH;
  80188f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801894:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801899:	7f 5e                	jg     8018f9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	e8 35 f8 ff ff       	call   8010db <fd_alloc>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 4d                	js     8018f9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018b7:	e8 ef ef ff ff       	call   8008ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018cc:	e8 1f fe ff ff       	call   8016f0 <fsipc>
  8018d1:	89 c3                	mov    %eax,%ebx
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	79 15                	jns    8018ec <open+0x70>
		fd_close(fd, 0);
  8018d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018de:	00 
  8018df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e2:	89 04 24             	mov    %eax,(%esp)
  8018e5:	e8 21 f9 ff ff       	call   80120b <fd_close>
		return r;
  8018ea:	eb 0d                	jmp    8018f9 <open+0x7d>
	}

	return fd2num(fd);
  8018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	e8 b9 f7 ff ff       	call   8010b0 <fd2num>
  8018f7:	89 c3                	mov    %eax,%ebx
}
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	83 c4 20             	add    $0x20,%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    
	...

00801910 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 18             	sub    $0x18,%esp
  801916:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801919:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80191c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	89 04 24             	mov    %eax,(%esp)
  801925:	e8 96 f7 ff ff       	call   8010c0 <fd2data>
  80192a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80192c:	c7 44 24 04 2b 27 80 	movl   $0x80272b,0x4(%esp)
  801933:	00 
  801934:	89 34 24             	mov    %esi,(%esp)
  801937:	e8 6f ef ff ff       	call   8008ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80193c:	8b 43 04             	mov    0x4(%ebx),%eax
  80193f:	2b 03                	sub    (%ebx),%eax
  801941:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801947:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80194e:	00 00 00 
	stat->st_dev = &devpipe;
  801951:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801958:	30 80 00 
	return 0;
}
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
  801960:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801963:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801966:	89 ec                	mov    %ebp,%esp
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	53                   	push   %ebx
  80196e:	83 ec 14             	sub    $0x14,%esp
  801971:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801974:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801978:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80197f:	e8 e5 f4 ff ff       	call   800e69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801984:	89 1c 24             	mov    %ebx,(%esp)
  801987:	e8 34 f7 ff ff       	call   8010c0 <fd2data>
  80198c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801990:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801997:	e8 cd f4 ff ff       	call   800e69 <sys_page_unmap>
}
  80199c:	83 c4 14             	add    $0x14,%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	57                   	push   %edi
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 2c             	sub    $0x2c,%esp
  8019ab:	89 c7                	mov    %eax,%edi
  8019ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8019b5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019b8:	89 3c 24             	mov    %edi,(%esp)
  8019bb:	e8 54 06 00 00       	call   802014 <pageref>
  8019c0:	89 c6                	mov    %eax,%esi
  8019c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c5:	89 04 24             	mov    %eax,(%esp)
  8019c8:	e8 47 06 00 00       	call   802014 <pageref>
  8019cd:	39 c6                	cmp    %eax,%esi
  8019cf:	0f 94 c0             	sete   %al
  8019d2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019d5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019db:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019de:	39 cb                	cmp    %ecx,%ebx
  8019e0:	75 08                	jne    8019ea <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019e2:	83 c4 2c             	add    $0x2c,%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5f                   	pop    %edi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019ea:	83 f8 01             	cmp    $0x1,%eax
  8019ed:	75 c1                	jne    8019b0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ef:	8b 52 58             	mov    0x58(%edx),%edx
  8019f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019fe:	c7 04 24 32 27 80 00 	movl   $0x802732,(%esp)
  801a05:	e8 59 e7 ff ff       	call   800163 <cprintf>
  801a0a:	eb a4                	jmp    8019b0 <_pipeisclosed+0xe>

00801a0c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	57                   	push   %edi
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	83 ec 2c             	sub    $0x2c,%esp
  801a15:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a18:	89 34 24             	mov    %esi,(%esp)
  801a1b:	e8 a0 f6 ff ff       	call   8010c0 <fd2data>
  801a20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a22:	bf 00 00 00 00       	mov    $0x0,%edi
  801a27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a2b:	75 50                	jne    801a7d <devpipe_write+0x71>
  801a2d:	eb 5c                	jmp    801a8b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a2f:	89 da                	mov    %ebx,%edx
  801a31:	89 f0                	mov    %esi,%eax
  801a33:	e8 6a ff ff ff       	call   8019a2 <_pipeisclosed>
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	75 53                	jne    801a8f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a3c:	e8 3b f3 ff ff       	call   800d7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a41:	8b 43 04             	mov    0x4(%ebx),%eax
  801a44:	8b 13                	mov    (%ebx),%edx
  801a46:	83 c2 20             	add    $0x20,%edx
  801a49:	39 d0                	cmp    %edx,%eax
  801a4b:	73 e2                	jae    801a2f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a50:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801a54:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	c1 fa 1f             	sar    $0x1f,%edx
  801a5c:	c1 ea 1b             	shr    $0x1b,%edx
  801a5f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801a62:	83 e1 1f             	and    $0x1f,%ecx
  801a65:	29 d1                	sub    %edx,%ecx
  801a67:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801a6b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801a6f:	83 c0 01             	add    $0x1,%eax
  801a72:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a75:	83 c7 01             	add    $0x1,%edi
  801a78:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a7b:	74 0e                	je     801a8b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a7d:	8b 43 04             	mov    0x4(%ebx),%eax
  801a80:	8b 13                	mov    (%ebx),%edx
  801a82:	83 c2 20             	add    $0x20,%edx
  801a85:	39 d0                	cmp    %edx,%eax
  801a87:	73 a6                	jae    801a2f <devpipe_write+0x23>
  801a89:	eb c2                	jmp    801a4d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a8b:	89 f8                	mov    %edi,%eax
  801a8d:	eb 05                	jmp    801a94 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a8f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a94:	83 c4 2c             	add    $0x2c,%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5f                   	pop    %edi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 28             	sub    $0x28,%esp
  801aa2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801aa5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801aa8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801aab:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aae:	89 3c 24             	mov    %edi,(%esp)
  801ab1:	e8 0a f6 ff ff       	call   8010c0 <fd2data>
  801ab6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab8:	be 00 00 00 00       	mov    $0x0,%esi
  801abd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ac1:	75 47                	jne    801b0a <devpipe_read+0x6e>
  801ac3:	eb 52                	jmp    801b17 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ac5:	89 f0                	mov    %esi,%eax
  801ac7:	eb 5e                	jmp    801b27 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ac9:	89 da                	mov    %ebx,%edx
  801acb:	89 f8                	mov    %edi,%eax
  801acd:	8d 76 00             	lea    0x0(%esi),%esi
  801ad0:	e8 cd fe ff ff       	call   8019a2 <_pipeisclosed>
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	75 49                	jne    801b22 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801ad9:	e8 9e f2 ff ff       	call   800d7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ade:	8b 03                	mov    (%ebx),%eax
  801ae0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ae3:	74 e4                	je     801ac9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	c1 fa 1f             	sar    $0x1f,%edx
  801aea:	c1 ea 1b             	shr    $0x1b,%edx
  801aed:	01 d0                	add    %edx,%eax
  801aef:	83 e0 1f             	and    $0x1f,%eax
  801af2:	29 d0                	sub    %edx,%eax
  801af4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801aff:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b02:	83 c6 01             	add    $0x1,%esi
  801b05:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b08:	74 0d                	je     801b17 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801b0a:	8b 03                	mov    (%ebx),%eax
  801b0c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b0f:	75 d4                	jne    801ae5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b11:	85 f6                	test   %esi,%esi
  801b13:	75 b0                	jne    801ac5 <devpipe_read+0x29>
  801b15:	eb b2                	jmp    801ac9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b17:	89 f0                	mov    %esi,%eax
  801b19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b20:	eb 05                	jmp    801b27 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b30:	89 ec                	mov    %ebp,%esp
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	83 ec 48             	sub    $0x48,%esp
  801b3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b40:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b43:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b49:	89 04 24             	mov    %eax,(%esp)
  801b4c:	e8 8a f5 ff ff       	call   8010db <fd_alloc>
  801b51:	89 c3                	mov    %eax,%ebx
  801b53:	85 c0                	test   %eax,%eax
  801b55:	0f 88 45 01 00 00    	js     801ca0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b62:	00 
  801b63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b71:	e8 36 f2 ff ff       	call   800dac <sys_page_alloc>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	0f 88 20 01 00 00    	js     801ca0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b80:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b83:	89 04 24             	mov    %eax,(%esp)
  801b86:	e8 50 f5 ff ff       	call   8010db <fd_alloc>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	0f 88 f8 00 00 00    	js     801c8d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b95:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b9c:	00 
  801b9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bab:	e8 fc f1 ff ff       	call   800dac <sys_page_alloc>
  801bb0:	89 c3                	mov    %eax,%ebx
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 d3 00 00 00    	js     801c8d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bbd:	89 04 24             	mov    %eax,(%esp)
  801bc0:	e8 fb f4 ff ff       	call   8010c0 <fd2data>
  801bc5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bce:	00 
  801bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bda:	e8 cd f1 ff ff       	call   800dac <sys_page_alloc>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	85 c0                	test   %eax,%eax
  801be3:	0f 88 91 00 00 00    	js     801c7a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 cc f4 ff ff       	call   8010c0 <fd2data>
  801bf4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801bfb:	00 
  801bfc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c07:	00 
  801c08:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c13:	e8 f3 f1 ff ff       	call   800e0b <sys_page_map>
  801c18:	89 c3                	mov    %eax,%ebx
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 4c                	js     801c6a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c1e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c27:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c33:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c39:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c3c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c4b:	89 04 24             	mov    %eax,(%esp)
  801c4e:	e8 5d f4 ff ff       	call   8010b0 <fd2num>
  801c53:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c58:	89 04 24             	mov    %eax,(%esp)
  801c5b:	e8 50 f4 ff ff       	call   8010b0 <fd2num>
  801c60:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c68:	eb 36                	jmp    801ca0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801c6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c75:	e8 ef f1 ff ff       	call   800e69 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c88:	e8 dc f1 ff ff       	call   800e69 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9b:	e8 c9 f1 ff ff       	call   800e69 <sys_page_unmap>
    err:
	return r;
}
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ca5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ca8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cab:	89 ec                	mov    %ebp,%esp
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 87 f4 ff ff       	call   80114e <fd_lookup>
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 15                	js     801ce0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cce:	89 04 24             	mov    %eax,(%esp)
  801cd1:	e8 ea f3 ff ff       	call   8010c0 <fd2data>
	return _pipeisclosed(fd, p);
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	e8 c2 fc ff ff       	call   8019a2 <_pipeisclosed>
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    
	...

00801cf0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    

00801cfa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d00:	c7 44 24 04 4a 27 80 	movl   $0x80274a,0x4(%esp)
  801d07:	00 
  801d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0b:	89 04 24             	mov    %eax,(%esp)
  801d0e:	e8 98 eb ff ff       	call   8008ab <strcpy>
	return 0;
}
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	57                   	push   %edi
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d26:	be 00 00 00 00       	mov    $0x0,%esi
  801d2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d2f:	74 43                	je     801d74 <devcons_write+0x5a>
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d36:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d3f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d41:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d44:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d49:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d50:	03 45 0c             	add    0xc(%ebp),%eax
  801d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d57:	89 3c 24             	mov    %edi,(%esp)
  801d5a:	e8 3d ed ff ff       	call   800a9c <memmove>
		sys_cputs(buf, m);
  801d5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	e8 25 ef ff ff       	call   800c90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d6b:	01 de                	add    %ebx,%esi
  801d6d:	89 f0                	mov    %esi,%eax
  801d6f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d72:	72 c8                	jb     801d3c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d74:	89 f0                	mov    %esi,%eax
  801d76:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d90:	75 07                	jne    801d99 <devcons_read+0x18>
  801d92:	eb 31                	jmp    801dc5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d94:	e8 e3 ef ff ff       	call   800d7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	e8 1a ef ff ff       	call   800cbf <sys_cgetc>
  801da5:	85 c0                	test   %eax,%eax
  801da7:	74 eb                	je     801d94 <devcons_read+0x13>
  801da9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 16                	js     801dc5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801daf:	83 f8 04             	cmp    $0x4,%eax
  801db2:	74 0c                	je     801dc0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801db4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db7:	88 10                	mov    %dl,(%eax)
	return 1;
  801db9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbe:	eb 05                	jmp    801dc5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dc0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dd3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801dda:	00 
  801ddb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dde:	89 04 24             	mov    %eax,(%esp)
  801de1:	e8 aa ee ff ff       	call   800c90 <sys_cputs>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <getchar>:

int
getchar(void)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801df5:	00 
  801df6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e04:	e8 05 f6 ff ff       	call   80140e <read>
	if (r < 0)
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 0f                	js     801e1c <getchar+0x34>
		return r;
	if (r < 1)
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	7e 06                	jle    801e17 <getchar+0x2f>
		return -E_EOF;
	return c;
  801e11:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e15:	eb 05                	jmp    801e1c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e17:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	89 04 24             	mov    %eax,(%esp)
  801e31:	e8 18 f3 ff ff       	call   80114e <fd_lookup>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 11                	js     801e4b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e43:	39 10                	cmp    %edx,(%eax)
  801e45:	0f 94 c0             	sete   %al
  801e48:	0f b6 c0             	movzbl %al,%eax
}
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <opencons>:

int
opencons(void)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e56:	89 04 24             	mov    %eax,(%esp)
  801e59:	e8 7d f2 ff ff       	call   8010db <fd_alloc>
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 3c                	js     801e9e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e69:	00 
  801e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e78:	e8 2f ef ff ff       	call   800dac <sys_page_alloc>
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 1d                	js     801e9e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e81:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 12 f2 ff ff       	call   8010b0 <fd2num>
}
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801ea8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801eab:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801eb1:	e8 96 ee ff ff       	call   800d4c <sys_getenvid>
  801eb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  801ec0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ec4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecc:	c7 04 24 58 27 80 00 	movl   $0x802758,(%esp)
  801ed3:	e8 8b e2 ff ff       	call   800163 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ed8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801edc:	8b 45 10             	mov    0x10(%ebp),%eax
  801edf:	89 04 24             	mov    %eax,(%esp)
  801ee2:	e8 1b e2 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801ee7:	c7 04 24 1c 23 80 00 	movl   $0x80231c,(%esp)
  801eee:	e8 70 e2 ff ff       	call   800163 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ef3:	cc                   	int3   
  801ef4:	eb fd                	jmp    801ef3 <_panic+0x53>
	...

00801ef8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 10             	sub    $0x10,%esp
  801f00:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f06:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f09:	85 db                	test   %ebx,%ebx
  801f0b:	74 06                	je     801f13 <ipc_recv+0x1b>
  801f0d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801f13:	85 f6                	test   %esi,%esi
  801f15:	74 06                	je     801f1d <ipc_recv+0x25>
  801f17:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f24:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f27:	89 04 24             	mov    %eax,(%esp)
  801f2a:	e8 e6 f0 ff ff       	call   801015 <sys_ipc_recv>
    if (ret) return ret;
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	75 24                	jne    801f57 <ipc_recv+0x5f>
    if (from_env_store)
  801f33:	85 db                	test   %ebx,%ebx
  801f35:	74 0a                	je     801f41 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f37:	a1 04 40 80 00       	mov    0x804004,%eax
  801f3c:	8b 40 74             	mov    0x74(%eax),%eax
  801f3f:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f41:	85 f6                	test   %esi,%esi
  801f43:	74 0a                	je     801f4f <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f45:	a1 04 40 80 00       	mov    0x804004,%eax
  801f4a:	8b 40 78             	mov    0x78(%eax),%eax
  801f4d:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f54:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801f70:	85 db                	test   %ebx,%ebx
  801f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f77:	0f 44 d8             	cmove  %eax,%ebx
  801f7a:	eb 2a                	jmp    801fa6 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801f7c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f7f:	74 20                	je     801fa1 <ipc_send+0x43>
  801f81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f85:	c7 44 24 08 7c 27 80 	movl   $0x80277c,0x8(%esp)
  801f8c:	00 
  801f8d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801f94:	00 
  801f95:	c7 04 24 93 27 80 00 	movl   $0x802793,(%esp)
  801f9c:	e8 ff fe ff ff       	call   801ea0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801fa1:	e8 d6 ed ff ff       	call   800d7c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fa6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fb1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fb5:	89 34 24             	mov    %esi,(%esp)
  801fb8:	e8 24 f0 ff ff       	call   800fe1 <sys_ipc_try_send>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	75 bb                	jne    801f7c <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801fc1:	83 c4 1c             	add    $0x1c,%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fcf:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801fd4:	39 c8                	cmp    %ecx,%eax
  801fd6:	74 19                	je     801ff1 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fdd:	89 c2                	mov    %eax,%edx
  801fdf:	c1 e2 07             	shl    $0x7,%edx
  801fe2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe8:	8b 52 50             	mov    0x50(%edx),%edx
  801feb:	39 ca                	cmp    %ecx,%edx
  801fed:	75 14                	jne    802003 <ipc_find_env+0x3a>
  801fef:	eb 05                	jmp    801ff6 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ff6:	c1 e0 07             	shl    $0x7,%eax
  801ff9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ffe:	8b 40 40             	mov    0x40(%eax),%eax
  802001:	eb 0e                	jmp    802011 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802003:	83 c0 01             	add    $0x1,%eax
  802006:	3d 00 04 00 00       	cmp    $0x400,%eax
  80200b:	75 d0                	jne    801fdd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80200d:	66 b8 00 00          	mov    $0x0,%ax
}
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    
	...

00802014 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201a:	89 d0                	mov    %edx,%eax
  80201c:	c1 e8 16             	shr    $0x16,%eax
  80201f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802026:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202b:	f6 c1 01             	test   $0x1,%cl
  80202e:	74 1d                	je     80204d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802030:	c1 ea 0c             	shr    $0xc,%edx
  802033:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80203a:	f6 c2 01             	test   $0x1,%dl
  80203d:	74 0e                	je     80204d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80203f:	c1 ea 0c             	shr    $0xc,%edx
  802042:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802049:	ef 
  80204a:	0f b7 c0             	movzwl %ax,%eax
}
  80204d:	5d                   	pop    %ebp
  80204e:	c3                   	ret    
	...

00802050 <__udivdi3>:
  802050:	83 ec 1c             	sub    $0x1c,%esp
  802053:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802057:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80205b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80205f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802063:	89 74 24 10          	mov    %esi,0x10(%esp)
  802067:	8b 74 24 24          	mov    0x24(%esp),%esi
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802071:	89 44 24 08          	mov    %eax,0x8(%esp)
  802075:	89 cd                	mov    %ecx,%ebp
  802077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207b:	75 33                	jne    8020b0 <__udivdi3+0x60>
  80207d:	39 f1                	cmp    %esi,%ecx
  80207f:	77 57                	ja     8020d8 <__udivdi3+0x88>
  802081:	85 c9                	test   %ecx,%ecx
  802083:	75 0b                	jne    802090 <__udivdi3+0x40>
  802085:	b8 01 00 00 00       	mov    $0x1,%eax
  80208a:	31 d2                	xor    %edx,%edx
  80208c:	f7 f1                	div    %ecx
  80208e:	89 c1                	mov    %eax,%ecx
  802090:	89 f0                	mov    %esi,%eax
  802092:	31 d2                	xor    %edx,%edx
  802094:	f7 f1                	div    %ecx
  802096:	89 c6                	mov    %eax,%esi
  802098:	8b 44 24 04          	mov    0x4(%esp),%eax
  80209c:	f7 f1                	div    %ecx
  80209e:	89 f2                	mov    %esi,%edx
  8020a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	c3                   	ret    
  8020b0:	31 d2                	xor    %edx,%edx
  8020b2:	31 c0                	xor    %eax,%eax
  8020b4:	39 f7                	cmp    %esi,%edi
  8020b6:	77 e8                	ja     8020a0 <__udivdi3+0x50>
  8020b8:	0f bd cf             	bsr    %edi,%ecx
  8020bb:	83 f1 1f             	xor    $0x1f,%ecx
  8020be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020c2:	75 2c                	jne    8020f0 <__udivdi3+0xa0>
  8020c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8020c8:	76 04                	jbe    8020ce <__udivdi3+0x7e>
  8020ca:	39 f7                	cmp    %esi,%edi
  8020cc:	73 d2                	jae    8020a0 <__udivdi3+0x50>
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d5:	eb c9                	jmp    8020a0 <__udivdi3+0x50>
  8020d7:	90                   	nop
  8020d8:	89 f2                	mov    %esi,%edx
  8020da:	f7 f1                	div    %ecx
  8020dc:	31 d2                	xor    %edx,%edx
  8020de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	c3                   	ret    
  8020ee:	66 90                	xchg   %ax,%ax
  8020f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8020fa:	89 ea                	mov    %ebp,%edx
  8020fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  802100:	d3 e7                	shl    %cl,%edi
  802102:	89 c1                	mov    %eax,%ecx
  802104:	d3 ea                	shr    %cl,%edx
  802106:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80210b:	09 fa                	or     %edi,%edx
  80210d:	89 f7                	mov    %esi,%edi
  80210f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802113:	89 f2                	mov    %esi,%edx
  802115:	8b 74 24 08          	mov    0x8(%esp),%esi
  802119:	d3 e5                	shl    %cl,%ebp
  80211b:	89 c1                	mov    %eax,%ecx
  80211d:	d3 ef                	shr    %cl,%edi
  80211f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802124:	d3 e2                	shl    %cl,%edx
  802126:	89 c1                	mov    %eax,%ecx
  802128:	d3 ee                	shr    %cl,%esi
  80212a:	09 d6                	or     %edx,%esi
  80212c:	89 fa                	mov    %edi,%edx
  80212e:	89 f0                	mov    %esi,%eax
  802130:	f7 74 24 0c          	divl   0xc(%esp)
  802134:	89 d7                	mov    %edx,%edi
  802136:	89 c6                	mov    %eax,%esi
  802138:	f7 e5                	mul    %ebp
  80213a:	39 d7                	cmp    %edx,%edi
  80213c:	72 22                	jb     802160 <__udivdi3+0x110>
  80213e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802142:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802147:	d3 e5                	shl    %cl,%ebp
  802149:	39 c5                	cmp    %eax,%ebp
  80214b:	73 04                	jae    802151 <__udivdi3+0x101>
  80214d:	39 d7                	cmp    %edx,%edi
  80214f:	74 0f                	je     802160 <__udivdi3+0x110>
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	e9 46 ff ff ff       	jmp    8020a0 <__udivdi3+0x50>
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	8d 46 ff             	lea    -0x1(%esi),%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	8b 74 24 10          	mov    0x10(%esp),%esi
  802169:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80216d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	c3                   	ret    
	...

00802180 <__umoddi3>:
  802180:	83 ec 1c             	sub    $0x1c,%esp
  802183:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802187:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80218b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80218f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802193:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802197:	8b 74 24 24          	mov    0x24(%esp),%esi
  80219b:	85 ed                	test   %ebp,%ebp
  80219d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a5:	89 cf                	mov    %ecx,%edi
  8021a7:	89 04 24             	mov    %eax,(%esp)
  8021aa:	89 f2                	mov    %esi,%edx
  8021ac:	75 1a                	jne    8021c8 <__umoddi3+0x48>
  8021ae:	39 f1                	cmp    %esi,%ecx
  8021b0:	76 4e                	jbe    802200 <__umoddi3+0x80>
  8021b2:	f7 f1                	div    %ecx
  8021b4:	89 d0                	mov    %edx,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	c3                   	ret    
  8021c8:	39 f5                	cmp    %esi,%ebp
  8021ca:	77 54                	ja     802220 <__umoddi3+0xa0>
  8021cc:	0f bd c5             	bsr    %ebp,%eax
  8021cf:	83 f0 1f             	xor    $0x1f,%eax
  8021d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d6:	75 60                	jne    802238 <__umoddi3+0xb8>
  8021d8:	3b 0c 24             	cmp    (%esp),%ecx
  8021db:	0f 87 07 01 00 00    	ja     8022e8 <__umoddi3+0x168>
  8021e1:	89 f2                	mov    %esi,%edx
  8021e3:	8b 34 24             	mov    (%esp),%esi
  8021e6:	29 ce                	sub    %ecx,%esi
  8021e8:	19 ea                	sbb    %ebp,%edx
  8021ea:	89 34 24             	mov    %esi,(%esp)
  8021ed:	8b 04 24             	mov    (%esp),%eax
  8021f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	c3                   	ret    
  802200:	85 c9                	test   %ecx,%ecx
  802202:	75 0b                	jne    80220f <__umoddi3+0x8f>
  802204:	b8 01 00 00 00       	mov    $0x1,%eax
  802209:	31 d2                	xor    %edx,%edx
  80220b:	f7 f1                	div    %ecx
  80220d:	89 c1                	mov    %eax,%ecx
  80220f:	89 f0                	mov    %esi,%eax
  802211:	31 d2                	xor    %edx,%edx
  802213:	f7 f1                	div    %ecx
  802215:	8b 04 24             	mov    (%esp),%eax
  802218:	f7 f1                	div    %ecx
  80221a:	eb 98                	jmp    8021b4 <__umoddi3+0x34>
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 f2                	mov    %esi,%edx
  802222:	8b 74 24 10          	mov    0x10(%esp),%esi
  802226:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80222a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80222e:	83 c4 1c             	add    $0x1c,%esp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80223d:	89 e8                	mov    %ebp,%eax
  80223f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802244:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802248:	89 fa                	mov    %edi,%edx
  80224a:	d3 e0                	shl    %cl,%eax
  80224c:	89 e9                	mov    %ebp,%ecx
  80224e:	d3 ea                	shr    %cl,%edx
  802250:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802255:	09 c2                	or     %eax,%edx
  802257:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225b:	89 14 24             	mov    %edx,(%esp)
  80225e:	89 f2                	mov    %esi,%edx
  802260:	d3 e7                	shl    %cl,%edi
  802262:	89 e9                	mov    %ebp,%ecx
  802264:	d3 ea                	shr    %cl,%edx
  802266:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80226b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80226f:	d3 e6                	shl    %cl,%esi
  802271:	89 e9                	mov    %ebp,%ecx
  802273:	d3 e8                	shr    %cl,%eax
  802275:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80227a:	09 f0                	or     %esi,%eax
  80227c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802280:	f7 34 24             	divl   (%esp)
  802283:	d3 e6                	shl    %cl,%esi
  802285:	89 74 24 08          	mov    %esi,0x8(%esp)
  802289:	89 d6                	mov    %edx,%esi
  80228b:	f7 e7                	mul    %edi
  80228d:	39 d6                	cmp    %edx,%esi
  80228f:	89 c1                	mov    %eax,%ecx
  802291:	89 d7                	mov    %edx,%edi
  802293:	72 3f                	jb     8022d4 <__umoddi3+0x154>
  802295:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802299:	72 35                	jb     8022d0 <__umoddi3+0x150>
  80229b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80229f:	29 c8                	sub    %ecx,%eax
  8022a1:	19 fe                	sbb    %edi,%esi
  8022a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022a8:	89 f2                	mov    %esi,%edx
  8022aa:	d3 e8                	shr    %cl,%eax
  8022ac:	89 e9                	mov    %ebp,%ecx
  8022ae:	d3 e2                	shl    %cl,%edx
  8022b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022b5:	09 d0                	or     %edx,%eax
  8022b7:	89 f2                	mov    %esi,%edx
  8022b9:	d3 ea                	shr    %cl,%edx
  8022bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022c7:	83 c4 1c             	add    $0x1c,%esp
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	39 d6                	cmp    %edx,%esi
  8022d2:	75 c7                	jne    80229b <__umoddi3+0x11b>
  8022d4:	89 d7                	mov    %edx,%edi
  8022d6:	89 c1                	mov    %eax,%ecx
  8022d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8022dc:	1b 3c 24             	sbb    (%esp),%edi
  8022df:	eb ba                	jmp    80229b <__umoddi3+0x11b>
  8022e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 f5                	cmp    %esi,%ebp
  8022ea:	0f 82 f1 fe ff ff    	jb     8021e1 <__umoddi3+0x61>
  8022f0:	e9 f8 fe ff ff       	jmp    8021ed <__umoddi3+0x6d>
