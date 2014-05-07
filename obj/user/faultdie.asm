
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  800060:	e8 3e 01 00 00       	call   8001a3 <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 22 0d 00 00       	call   800d8c <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 bd 0c 00 00       	call   800d2f <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 5e 10 00 00       	call   8010e4 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a6:	e8 e1 0c 00 00       	call   800d8c <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	c1 e0 07             	shl    $0x7,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 a0 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ea:	e8 cf 12 00 00       	call   8013be <close_all>
	sys_env_destroy(0);
  8000ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f6:	e8 34 0c 00 00       	call   800d2f <sys_env_destroy>
}
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	53                   	push   %ebx
  800104:	83 ec 14             	sub    $0x14,%esp
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010a:	8b 03                	mov    (%ebx),%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800113:	83 c0 01             	add    $0x1,%eax
  800116:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011d:	75 19                	jne    800138 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80011f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800126:	00 
  800127:	8d 43 08             	lea    0x8(%ebx),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 9e 0b 00 00       	call   800cd0 <sys_cputs>
		b->idx = 0;
  800132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800138:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013c:	83 c4 14             	add    $0x14,%esp
  80013f:	5b                   	pop    %ebx
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800152:	00 00 00 
	b.cnt = 0;
  800155:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800162:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	c7 04 24 00 01 80 00 	movl   $0x800100,(%esp)
  80017e:	e8 97 01 00 00       	call   80031a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 35 0b 00 00       	call   800cd0 <sys_cputs>

	return b.cnt;
}
  80019b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 87 ff ff ff       	call   800142 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
  8001bd:	00 00                	add    %al,(%eax)
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001e8:	72 11                	jb     8001fb <printnum+0x3b>
  8001ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ed:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f0:	76 09                	jbe    8001fb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f2:	83 eb 01             	sub    $0x1,%ebx
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7f 51                	jg     80024a <printnum+0x8a>
  8001f9:	eb 5e                	jmp    800259 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	8b 45 10             	mov    0x10(%ebp),%eax
  800209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800211:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800215:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021c:	00 
  80021d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	e8 11 1f 00 00       	call   802140 <__udivdi3>
  80022f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800233:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800237:	89 04 24             	mov    %eax,(%esp)
  80023a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023e:	89 fa                	mov    %edi,%edx
  800240:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800243:	e8 78 ff ff ff       	call   8001c0 <printnum>
  800248:	eb 0f                	jmp    800259 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024e:	89 34 24             	mov    %esi,(%esp)
  800251:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800254:	83 eb 01             	sub    $0x1,%ebx
  800257:	75 f1                	jne    80024a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800259:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800261:	8b 45 10             	mov    0x10(%ebp),%eax
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	e8 ee 1f 00 00       	call   802270 <__umoddi3>
  800282:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800286:	0f be 80 26 24 80 00 	movsbl 0x802426(%eax),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800293:	83 c4 3c             	add    $0x3c,%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029e:	83 fa 01             	cmp    $0x1,%edx
  8002a1:	7e 0e                	jle    8002b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	8b 52 04             	mov    0x4(%edx),%edx
  8002af:	eb 22                	jmp    8002d3 <getuint+0x38>
	else if (lflag)
  8002b1:	85 d2                	test   %edx,%edx
  8002b3:	74 10                	je     8002c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b5:	8b 10                	mov    (%eax),%edx
  8002b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 02                	mov    (%edx),%eax
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	eb 0e                	jmp    8002d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 02                	mov    (%edx),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e4:	73 0a                	jae    8002f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e9:	88 0a                	mov    %cl,(%edx)
  8002eb:	83 c2 01             	add    $0x1,%edx
  8002ee:	89 10                	mov    %edx,(%eax)
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800302:	89 44 24 08          	mov    %eax,0x8(%esp)
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
  800309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 02 00 00 00       	call   80031a <vprintfmt>
	va_end(ap);
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 5c             	sub    $0x5c,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800326:	8b 75 10             	mov    0x10(%ebp),%esi
  800329:	eb 12                	jmp    80033d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032b:	85 c0                	test   %eax,%eax
  80032d:	0f 84 e4 04 00 00    	je     800817 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800333:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033d:	0f b6 06             	movzbl (%esi),%eax
  800340:	83 c6 01             	add    $0x1,%esi
  800343:	83 f8 25             	cmp    $0x25,%eax
  800346:	75 e3                	jne    80032b <vprintfmt+0x11>
  800348:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80034c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800353:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800358:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800364:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800367:	eb 2b                	jmp    800394 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800370:	eb 22                	jmp    800394 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800375:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800379:	eb 19                	jmp    800394 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80037e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800385:	eb 0d                	jmp    800394 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800387:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80038a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80038d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	0f b6 06             	movzbl (%esi),%eax
  800397:	0f b6 d0             	movzbl %al,%edx
  80039a:	8d 7e 01             	lea    0x1(%esi),%edi
  80039d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003a0:	83 e8 23             	sub    $0x23,%eax
  8003a3:	3c 55                	cmp    $0x55,%al
  8003a5:	0f 87 46 04 00 00    	ja     8007f1 <vprintfmt+0x4d7>
  8003ab:	0f b6 c0             	movzbl %al,%eax
  8003ae:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b5:	83 ea 30             	sub    $0x30,%edx
  8003b8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003bb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003bf:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003c5:	83 fa 09             	cmp    $0x9,%edx
  8003c8:	77 4a                	ja     800414 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003d0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003d3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003d7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003da:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003dd:	83 fa 09             	cmp    $0x9,%edx
  8003e0:	76 eb                	jbe    8003cd <vprintfmt+0xb3>
  8003e2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003e5:	eb 2d                	jmp    800414 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8d 50 04             	lea    0x4(%eax),%edx
  8003ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f8:	eb 1a                	jmp    800414 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003fd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800401:	79 91                	jns    800394 <vprintfmt+0x7a>
  800403:	e9 73 ff ff ff       	jmp    80037b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800412:	eb 80                	jmp    800394 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800414:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800418:	0f 89 76 ff ff ff    	jns    800394 <vprintfmt+0x7a>
  80041e:	e9 64 ff ff ff       	jmp    800387 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 66 ff ff ff       	jmp    800394 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800446:	e9 f2 fe ff ff       	jmp    80033d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80044b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80044f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800452:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800456:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800459:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80045d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800460:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800463:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800467:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80046a:	80 f9 09             	cmp    $0x9,%cl
  80046d:	77 1d                	ja     80048c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80046f:	0f be c0             	movsbl %al,%eax
  800472:	6b c0 64             	imul   $0x64,%eax,%eax
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80047b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800482:	a3 04 30 80 00       	mov    %eax,0x803004
  800487:	e9 b1 fe ff ff       	jmp    80033d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80048c:	c7 44 24 04 3e 24 80 	movl   $0x80243e,0x4(%esp)
  800493:	00 
  800494:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800497:	89 04 24             	mov    %eax,(%esp)
  80049a:	e8 0c 05 00 00       	call   8009ab <strcmp>
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	75 0f                	jne    8004b2 <vprintfmt+0x198>
  8004a3:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8004aa:	00 00 00 
  8004ad:	e9 8b fe ff ff       	jmp    80033d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004b2:	c7 44 24 04 42 24 80 	movl   $0x802442,0x4(%esp)
  8004b9:	00 
  8004ba:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004bd:	89 14 24             	mov    %edx,(%esp)
  8004c0:	e8 e6 04 00 00       	call   8009ab <strcmp>
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 0f                	jne    8004d8 <vprintfmt+0x1be>
  8004c9:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8004d0:	00 00 00 
  8004d3:	e9 65 fe ff ff       	jmp    80033d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004d8:	c7 44 24 04 46 24 80 	movl   $0x802446,0x4(%esp)
  8004df:	00 
  8004e0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004e3:	89 0c 24             	mov    %ecx,(%esp)
  8004e6:	e8 c0 04 00 00       	call   8009ab <strcmp>
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 0f                	jne    8004fe <vprintfmt+0x1e4>
  8004ef:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8004f6:	00 00 00 
  8004f9:	e9 3f fe ff ff       	jmp    80033d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004fe:	c7 44 24 04 4a 24 80 	movl   $0x80244a,0x4(%esp)
  800505:	00 
  800506:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800509:	89 3c 24             	mov    %edi,(%esp)
  80050c:	e8 9a 04 00 00       	call   8009ab <strcmp>
  800511:	85 c0                	test   %eax,%eax
  800513:	75 0f                	jne    800524 <vprintfmt+0x20a>
  800515:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  80051c:	00 00 00 
  80051f:	e9 19 fe ff ff       	jmp    80033d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800524:	c7 44 24 04 4e 24 80 	movl   $0x80244e,0x4(%esp)
  80052b:	00 
  80052c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 74 04 00 00       	call   8009ab <strcmp>
  800537:	85 c0                	test   %eax,%eax
  800539:	75 0f                	jne    80054a <vprintfmt+0x230>
  80053b:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800542:	00 00 00 
  800545:	e9 f3 fd ff ff       	jmp    80033d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80054a:	c7 44 24 04 52 24 80 	movl   $0x802452,0x4(%esp)
  800551:	00 
  800552:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800555:	89 14 24             	mov    %edx,(%esp)
  800558:	e8 4e 04 00 00       	call   8009ab <strcmp>
  80055d:	83 f8 01             	cmp    $0x1,%eax
  800560:	19 c0                	sbb    %eax,%eax
  800562:	f7 d0                	not    %eax
  800564:	83 c0 08             	add    $0x8,%eax
  800567:	a3 04 30 80 00       	mov    %eax,0x803004
  80056c:	e9 cc fd ff ff       	jmp    80033d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 c2                	mov    %eax,%edx
  80057e:	c1 fa 1f             	sar    $0x1f,%edx
  800581:	31 d0                	xor    %edx,%eax
  800583:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800585:	83 f8 0f             	cmp    $0xf,%eax
  800588:	7f 0b                	jg     800595 <vprintfmt+0x27b>
  80058a:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800591:	85 d2                	test   %edx,%edx
  800593:	75 23                	jne    8005b8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800595:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800599:	c7 44 24 08 56 24 80 	movl   $0x802456,0x8(%esp)
  8005a0:	00 
  8005a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a8:	89 3c 24             	mov    %edi,(%esp)
  8005ab:	e8 42 fd ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b3:	e9 85 fd ff ff       	jmp    80033d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005bc:	c7 44 24 08 81 28 80 	movl   $0x802881,0x8(%esp)
  8005c3:	00 
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cb:	89 3c 24             	mov    %edi,(%esp)
  8005ce:	e8 1f fd ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005d6:	e9 62 fd ff ff       	jmp    80033d <vprintfmt+0x23>
  8005db:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005de:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005e1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005ef:	85 f6                	test   %esi,%esi
  8005f1:	b8 37 24 80 00       	mov    $0x802437,%eax
  8005f6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005f9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005fd:	7e 06                	jle    800605 <vprintfmt+0x2eb>
  8005ff:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800603:	75 13                	jne    800618 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800605:	0f be 06             	movsbl (%esi),%eax
  800608:	83 c6 01             	add    $0x1,%esi
  80060b:	85 c0                	test   %eax,%eax
  80060d:	0f 85 94 00 00 00    	jne    8006a7 <vprintfmt+0x38d>
  800613:	e9 81 00 00 00       	jmp    800699 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061c:	89 34 24             	mov    %esi,(%esp)
  80061f:	e8 97 02 00 00       	call   8008bb <strnlen>
  800624:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800627:	29 c2                	sub    %eax,%edx
  800629:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80062c:	85 d2                	test   %edx,%edx
  80062e:	7e d5                	jle    800605 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800630:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800634:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800637:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80063a:	89 d6                	mov    %edx,%esi
  80063c:	89 cf                	mov    %ecx,%edi
  80063e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800642:	89 3c 24             	mov    %edi,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800648:	83 ee 01             	sub    $0x1,%esi
  80064b:	75 f1                	jne    80063e <vprintfmt+0x324>
  80064d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800650:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800653:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800656:	eb ad                	jmp    800605 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800658:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80065c:	74 1b                	je     800679 <vprintfmt+0x35f>
  80065e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800661:	83 fa 5e             	cmp    $0x5e,%edx
  800664:	76 13                	jbe    800679 <vprintfmt+0x35f>
					putch('?', putdat);
  800666:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800674:	ff 55 08             	call   *0x8(%ebp)
  800677:	eb 0d                	jmp    800686 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800679:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80067c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800686:	83 eb 01             	sub    $0x1,%ebx
  800689:	0f be 06             	movsbl (%esi),%eax
  80068c:	83 c6 01             	add    $0x1,%esi
  80068f:	85 c0                	test   %eax,%eax
  800691:	75 1a                	jne    8006ad <vprintfmt+0x393>
  800693:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800696:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006a0:	7f 1c                	jg     8006be <vprintfmt+0x3a4>
  8006a2:	e9 96 fc ff ff       	jmp    80033d <vprintfmt+0x23>
  8006a7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006aa:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ad:	85 ff                	test   %edi,%edi
  8006af:	78 a7                	js     800658 <vprintfmt+0x33e>
  8006b1:	83 ef 01             	sub    $0x1,%edi
  8006b4:	79 a2                	jns    800658 <vprintfmt+0x33e>
  8006b6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006b9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006bc:	eb db                	jmp    800699 <vprintfmt+0x37f>
  8006be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c1:	89 de                	mov    %ebx,%esi
  8006c3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d3:	83 eb 01             	sub    $0x1,%ebx
  8006d6:	75 ee                	jne    8006c6 <vprintfmt+0x3ac>
  8006d8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006dd:	e9 5b fc ff ff       	jmp    80033d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e2:	83 f9 01             	cmp    $0x1,%ecx
  8006e5:	7e 10                	jle    8006f7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 50 08             	lea    0x8(%eax),%edx
  8006ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f0:	8b 30                	mov    (%eax),%esi
  8006f2:	8b 78 04             	mov    0x4(%eax),%edi
  8006f5:	eb 26                	jmp    80071d <vprintfmt+0x403>
	else if (lflag)
  8006f7:	85 c9                	test   %ecx,%ecx
  8006f9:	74 12                	je     80070d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 50 04             	lea    0x4(%eax),%edx
  800701:	89 55 14             	mov    %edx,0x14(%ebp)
  800704:	8b 30                	mov    (%eax),%esi
  800706:	89 f7                	mov    %esi,%edi
  800708:	c1 ff 1f             	sar    $0x1f,%edi
  80070b:	eb 10                	jmp    80071d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)
  800716:	8b 30                	mov    (%eax),%esi
  800718:	89 f7                	mov    %esi,%edi
  80071a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071d:	85 ff                	test   %edi,%edi
  80071f:	78 0e                	js     80072f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800721:	89 f0                	mov    %esi,%eax
  800723:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800725:	be 0a 00 00 00       	mov    $0xa,%esi
  80072a:	e9 84 00 00 00       	jmp    8007b3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80072f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800733:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80073a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80073d:	89 f0                	mov    %esi,%eax
  80073f:	89 fa                	mov    %edi,%edx
  800741:	f7 d8                	neg    %eax
  800743:	83 d2 00             	adc    $0x0,%edx
  800746:	f7 da                	neg    %edx
			}
			base = 10;
  800748:	be 0a 00 00 00       	mov    $0xa,%esi
  80074d:	eb 64                	jmp    8007b3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074f:	89 ca                	mov    %ecx,%edx
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 42 fb ff ff       	call   80029b <getuint>
			base = 10;
  800759:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80075e:	eb 53                	jmp    8007b3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800760:	89 ca                	mov    %ecx,%edx
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 31 fb ff ff       	call   80029b <getuint>
    			base = 8;
  80076a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80076f:	eb 42                	jmp    8007b3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800771:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800775:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80077c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800783:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80078a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8d 50 04             	lea    0x4(%eax),%edx
  800793:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800796:	8b 00                	mov    (%eax),%eax
  800798:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007a2:	eb 0f                	jmp    8007b3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a4:	89 ca                	mov    %ecx,%edx
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	e8 ed fa ff ff       	call   80029b <getuint>
			base = 16;
  8007ae:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007b7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007bb:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007be:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007c2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007c6:	89 04 24             	mov    %eax,(%esp)
  8007c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007cd:	89 da                	mov    %ebx,%edx
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	e8 e9 f9 ff ff       	call   8001c0 <printnum>
			break;
  8007d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007da:	e9 5e fb ff ff       	jmp    80033d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	89 14 24             	mov    %edx,(%esp)
  8007e6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ec:	e9 4c fb ff ff       	jmp    80033d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007fc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800803:	0f 84 34 fb ff ff    	je     80033d <vprintfmt+0x23>
  800809:	83 ee 01             	sub    $0x1,%esi
  80080c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800810:	75 f7                	jne    800809 <vprintfmt+0x4ef>
  800812:	e9 26 fb ff ff       	jmp    80033d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800817:	83 c4 5c             	add    $0x5c,%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 28             	sub    $0x28,%esp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800832:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 30                	je     800870 <vsnprintf+0x51>
  800840:	85 d2                	test   %edx,%edx
  800842:	7e 2c                	jle    800870 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084b:	8b 45 10             	mov    0x10(%ebp),%eax
  80084e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800852:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800855:	89 44 24 04          	mov    %eax,0x4(%esp)
  800859:	c7 04 24 d5 02 80 00 	movl   $0x8002d5,(%esp)
  800860:	e8 b5 fa ff ff       	call   80031a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800865:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800868:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	eb 05                	jmp    800875 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800870:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800880:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800884:	8b 45 10             	mov    0x10(%ebp),%eax
  800887:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	89 04 24             	mov    %eax,(%esp)
  800898:	e8 82 ff ff ff       	call   80081f <vsnprintf>
	va_end(ap);

	return rc;
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    
	...

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ae:	74 09                	je     8008b9 <strlen+0x19>
		n++;
  8008b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	75 f7                	jne    8008b0 <strlen+0x10>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 1a                	je     8008e8 <strnlen+0x2d>
  8008ce:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008d1:	74 15                	je     8008e8 <strnlen+0x2d>
  8008d3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008d8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	39 ca                	cmp    %ecx,%edx
  8008dc:	74 0a                	je     8008e8 <strnlen+0x2d>
  8008de:	83 c2 01             	add    $0x1,%edx
  8008e1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008e6:	75 f0                	jne    8008d8 <strnlen+0x1d>
		n++;
	return n;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008fe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	84 c9                	test   %cl,%cl
  800906:	75 f2                	jne    8008fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800908:	5b                   	pop    %ebx
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	83 ec 08             	sub    $0x8,%esp
  800912:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800915:	89 1c 24             	mov    %ebx,(%esp)
  800918:	e8 83 ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800920:	89 54 24 04          	mov    %edx,0x4(%esp)
  800924:	01 d8                	add    %ebx,%eax
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	e8 bd ff ff ff       	call   8008eb <strcpy>
	return dst;
}
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	83 c4 08             	add    $0x8,%esp
  800933:	5b                   	pop    %ebx
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800944:	85 f6                	test   %esi,%esi
  800946:	74 18                	je     800960 <strncpy+0x2a>
  800948:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80094d:	0f b6 1a             	movzbl (%edx),%ebx
  800950:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800953:	80 3a 01             	cmpb   $0x1,(%edx)
  800956:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800959:	83 c1 01             	add    $0x1,%ecx
  80095c:	39 f1                	cmp    %esi,%ecx
  80095e:	75 ed                	jne    80094d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800970:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800973:	89 f8                	mov    %edi,%eax
  800975:	85 f6                	test   %esi,%esi
  800977:	74 2b                	je     8009a4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800979:	83 fe 01             	cmp    $0x1,%esi
  80097c:	74 23                	je     8009a1 <strlcpy+0x3d>
  80097e:	0f b6 0b             	movzbl (%ebx),%ecx
  800981:	84 c9                	test   %cl,%cl
  800983:	74 1c                	je     8009a1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800985:	83 ee 02             	sub    $0x2,%esi
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098d:	88 08                	mov    %cl,(%eax)
  80098f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800992:	39 f2                	cmp    %esi,%edx
  800994:	74 0b                	je     8009a1 <strlcpy+0x3d>
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80099d:	84 c9                	test   %cl,%cl
  80099f:	75 ec                	jne    80098d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8009a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a4:	29 f8                	sub    %edi,%eax
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b4:	0f b6 01             	movzbl (%ecx),%eax
  8009b7:	84 c0                	test   %al,%al
  8009b9:	74 16                	je     8009d1 <strcmp+0x26>
  8009bb:	3a 02                	cmp    (%edx),%al
  8009bd:	75 12                	jne    8009d1 <strcmp+0x26>
		p++, q++;
  8009bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8009c6:	84 c0                	test   %al,%al
  8009c8:	74 07                	je     8009d1 <strcmp+0x26>
  8009ca:	83 c1 01             	add    $0x1,%ecx
  8009cd:	3a 02                	cmp    (%edx),%al
  8009cf:	74 ee                	je     8009bf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d1:	0f b6 c0             	movzbl %al,%eax
  8009d4:	0f b6 12             	movzbl (%edx),%edx
  8009d7:	29 d0                	sub    %edx,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ed:	85 d2                	test   %edx,%edx
  8009ef:	74 28                	je     800a19 <strncmp+0x3e>
  8009f1:	0f b6 01             	movzbl (%ecx),%eax
  8009f4:	84 c0                	test   %al,%al
  8009f6:	74 24                	je     800a1c <strncmp+0x41>
  8009f8:	3a 03                	cmp    (%ebx),%al
  8009fa:	75 20                	jne    800a1c <strncmp+0x41>
  8009fc:	83 ea 01             	sub    $0x1,%edx
  8009ff:	74 13                	je     800a14 <strncmp+0x39>
		n--, p++, q++;
  800a01:	83 c1 01             	add    $0x1,%ecx
  800a04:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a07:	0f b6 01             	movzbl (%ecx),%eax
  800a0a:	84 c0                	test   %al,%al
  800a0c:	74 0e                	je     800a1c <strncmp+0x41>
  800a0e:	3a 03                	cmp    (%ebx),%al
  800a10:	74 ea                	je     8009fc <strncmp+0x21>
  800a12:	eb 08                	jmp    800a1c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1c:	0f b6 01             	movzbl (%ecx),%eax
  800a1f:	0f b6 13             	movzbl (%ebx),%edx
  800a22:	29 d0                	sub    %edx,%eax
  800a24:	eb f3                	jmp    800a19 <strncmp+0x3e>

00800a26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a30:	0f b6 10             	movzbl (%eax),%edx
  800a33:	84 d2                	test   %dl,%dl
  800a35:	74 1c                	je     800a53 <strchr+0x2d>
		if (*s == c)
  800a37:	38 ca                	cmp    %cl,%dl
  800a39:	75 09                	jne    800a44 <strchr+0x1e>
  800a3b:	eb 1b                	jmp    800a58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a40:	38 ca                	cmp    %cl,%dl
  800a42:	74 14                	je     800a58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a44:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	75 f1                	jne    800a3d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	eb 05                	jmp    800a58 <strchr+0x32>
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a64:	0f b6 10             	movzbl (%eax),%edx
  800a67:	84 d2                	test   %dl,%dl
  800a69:	74 14                	je     800a7f <strfind+0x25>
		if (*s == c)
  800a6b:	38 ca                	cmp    %cl,%dl
  800a6d:	75 06                	jne    800a75 <strfind+0x1b>
  800a6f:	eb 0e                	jmp    800a7f <strfind+0x25>
  800a71:	38 ca                	cmp    %cl,%dl
  800a73:	74 0a                	je     800a7f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	0f b6 10             	movzbl (%eax),%edx
  800a7b:	84 d2                	test   %dl,%dl
  800a7d:	75 f2                	jne    800a71 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 0c             	sub    $0xc,%esp
  800a87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a99:	85 c9                	test   %ecx,%ecx
  800a9b:	74 30                	je     800acd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa3:	75 25                	jne    800aca <memset+0x49>
  800aa5:	f6 c1 03             	test   $0x3,%cl
  800aa8:	75 20                	jne    800aca <memset+0x49>
		c &= 0xFF;
  800aaa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	c1 e3 08             	shl    $0x8,%ebx
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	c1 e6 18             	shl    $0x18,%esi
  800ab7:	89 d0                	mov    %edx,%eax
  800ab9:	c1 e0 10             	shl    $0x10,%eax
  800abc:	09 f0                	or     %esi,%eax
  800abe:	09 d0                	or     %edx,%eax
  800ac0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac5:	fc                   	cld    
  800ac6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac8:	eb 03                	jmp    800acd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aca:	fc                   	cld    
  800acb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acd:	89 f8                	mov    %edi,%eax
  800acf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ad2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ad5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ad8:	89 ec                	mov    %ebp,%esp
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 08             	sub    $0x8,%esp
  800ae2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ae5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af1:	39 c6                	cmp    %eax,%esi
  800af3:	73 36                	jae    800b2b <memmove+0x4f>
  800af5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af8:	39 d0                	cmp    %edx,%eax
  800afa:	73 2f                	jae    800b2b <memmove+0x4f>
		s += n;
		d += n;
  800afc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aff:	f6 c2 03             	test   $0x3,%dl
  800b02:	75 1b                	jne    800b1f <memmove+0x43>
  800b04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0a:	75 13                	jne    800b1f <memmove+0x43>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 0e                	jne    800b1f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb 09                	jmp    800b28 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1f:	83 ef 01             	sub    $0x1,%edi
  800b22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b25:	fd                   	std    
  800b26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b28:	fc                   	cld    
  800b29:	eb 20                	jmp    800b4b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b31:	75 13                	jne    800b46 <memmove+0x6a>
  800b33:	a8 03                	test   $0x3,%al
  800b35:	75 0f                	jne    800b46 <memmove+0x6a>
  800b37:	f6 c1 03             	test   $0x3,%cl
  800b3a:	75 0a                	jne    800b46 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b3c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	fc                   	cld    
  800b42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b44:	eb 05                	jmp    800b4b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	fc                   	cld    
  800b49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b51:	89 ec                	mov    %ebp,%esp
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	89 04 24             	mov    %eax,(%esp)
  800b6f:	e8 68 ff ff ff       	call   800adc <memmove>
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b82:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8a:	85 ff                	test   %edi,%edi
  800b8c:	74 37                	je     800bc5 <memcmp+0x4f>
		if (*s1 != *s2)
  800b8e:	0f b6 03             	movzbl (%ebx),%eax
  800b91:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b94:	83 ef 01             	sub    $0x1,%edi
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b9c:	38 c8                	cmp    %cl,%al
  800b9e:	74 1c                	je     800bbc <memcmp+0x46>
  800ba0:	eb 10                	jmp    800bb2 <memcmp+0x3c>
  800ba2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ba7:	83 c2 01             	add    $0x1,%edx
  800baa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bae:	38 c8                	cmp    %cl,%al
  800bb0:	74 0a                	je     800bbc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800bb2:	0f b6 c0             	movzbl %al,%eax
  800bb5:	0f b6 c9             	movzbl %cl,%ecx
  800bb8:	29 c8                	sub    %ecx,%eax
  800bba:	eb 09                	jmp    800bc5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbc:	39 fa                	cmp    %edi,%edx
  800bbe:	75 e2                	jne    800ba2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bd0:	89 c2                	mov    %eax,%edx
  800bd2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd5:	39 d0                	cmp    %edx,%eax
  800bd7:	73 19                	jae    800bf2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bdd:	38 08                	cmp    %cl,(%eax)
  800bdf:	75 06                	jne    800be7 <memfind+0x1d>
  800be1:	eb 0f                	jmp    800bf2 <memfind+0x28>
  800be3:	38 08                	cmp    %cl,(%eax)
  800be5:	74 0b                	je     800bf2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be7:	83 c0 01             	add    $0x1,%eax
  800bea:	39 d0                	cmp    %edx,%eax
  800bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bf0:	75 f1                	jne    800be3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c00:	0f b6 02             	movzbl (%edx),%eax
  800c03:	3c 20                	cmp    $0x20,%al
  800c05:	74 04                	je     800c0b <strtol+0x17>
  800c07:	3c 09                	cmp    $0x9,%al
  800c09:	75 0e                	jne    800c19 <strtol+0x25>
		s++;
  800c0b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0e:	0f b6 02             	movzbl (%edx),%eax
  800c11:	3c 20                	cmp    $0x20,%al
  800c13:	74 f6                	je     800c0b <strtol+0x17>
  800c15:	3c 09                	cmp    $0x9,%al
  800c17:	74 f2                	je     800c0b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c19:	3c 2b                	cmp    $0x2b,%al
  800c1b:	75 0a                	jne    800c27 <strtol+0x33>
		s++;
  800c1d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c20:	bf 00 00 00 00       	mov    $0x0,%edi
  800c25:	eb 10                	jmp    800c37 <strtol+0x43>
  800c27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c2c:	3c 2d                	cmp    $0x2d,%al
  800c2e:	75 07                	jne    800c37 <strtol+0x43>
		s++, neg = 1;
  800c30:	83 c2 01             	add    $0x1,%edx
  800c33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c37:	85 db                	test   %ebx,%ebx
  800c39:	0f 94 c0             	sete   %al
  800c3c:	74 05                	je     800c43 <strtol+0x4f>
  800c3e:	83 fb 10             	cmp    $0x10,%ebx
  800c41:	75 15                	jne    800c58 <strtol+0x64>
  800c43:	80 3a 30             	cmpb   $0x30,(%edx)
  800c46:	75 10                	jne    800c58 <strtol+0x64>
  800c48:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c4c:	75 0a                	jne    800c58 <strtol+0x64>
		s += 2, base = 16;
  800c4e:	83 c2 02             	add    $0x2,%edx
  800c51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c56:	eb 13                	jmp    800c6b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c58:	84 c0                	test   %al,%al
  800c5a:	74 0f                	je     800c6b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c61:	80 3a 30             	cmpb   $0x30,(%edx)
  800c64:	75 05                	jne    800c6b <strtol+0x77>
		s++, base = 8;
  800c66:	83 c2 01             	add    $0x1,%edx
  800c69:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c70:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c72:	0f b6 0a             	movzbl (%edx),%ecx
  800c75:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c78:	80 fb 09             	cmp    $0x9,%bl
  800c7b:	77 08                	ja     800c85 <strtol+0x91>
			dig = *s - '0';
  800c7d:	0f be c9             	movsbl %cl,%ecx
  800c80:	83 e9 30             	sub    $0x30,%ecx
  800c83:	eb 1e                	jmp    800ca3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c85:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c88:	80 fb 19             	cmp    $0x19,%bl
  800c8b:	77 08                	ja     800c95 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c8d:	0f be c9             	movsbl %cl,%ecx
  800c90:	83 e9 57             	sub    $0x57,%ecx
  800c93:	eb 0e                	jmp    800ca3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c95:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c98:	80 fb 19             	cmp    $0x19,%bl
  800c9b:	77 14                	ja     800cb1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c9d:	0f be c9             	movsbl %cl,%ecx
  800ca0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ca3:	39 f1                	cmp    %esi,%ecx
  800ca5:	7d 0e                	jge    800cb5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ca7:	83 c2 01             	add    $0x1,%edx
  800caa:	0f af c6             	imul   %esi,%eax
  800cad:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800caf:	eb c1                	jmp    800c72 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cb1:	89 c1                	mov    %eax,%ecx
  800cb3:	eb 02                	jmp    800cb7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cbb:	74 05                	je     800cc2 <strtol+0xce>
		*endptr = (char *) s;
  800cbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cc2:	89 ca                	mov    %ecx,%edx
  800cc4:	f7 da                	neg    %edx
  800cc6:	85 ff                	test   %edi,%edi
  800cc8:	0f 45 c2             	cmovne %edx,%eax
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 c3                	mov    %eax,%ebx
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	89 c6                	mov    %eax,%esi
  800cf0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfb:	89 ec                	mov    %ebp,%esp
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_cgetc>:

int
sys_cgetc(void)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d13:	b8 01 00 00 00       	mov    $0x1,%eax
  800d18:	89 d1                	mov    %edx,%ecx
  800d1a:	89 d3                	mov    %edx,%ebx
  800d1c:	89 d7                	mov    %edx,%edi
  800d1e:	89 d6                	mov    %edx,%esi
  800d20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2b:	89 ec                	mov    %ebp,%esp
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 38             	sub    $0x38,%esp
  800d35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d43:	b8 03 00 00 00       	mov    $0x3,%eax
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 cb                	mov    %ecx,%ebx
  800d4d:	89 cf                	mov    %ecx,%edi
  800d4f:	89 ce                	mov    %ecx,%esi
  800d51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 28                	jle    800d7f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800d7a:	e8 11 12 00 00       	call   801f90 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d88:	89 ec                	mov    %ebp,%esp
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800da0:	b8 02 00 00 00       	mov    $0x2,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_yield>:

void
sys_yield(void)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 d3                	mov    %edx,%ebx
  800dd9:	89 d7                	mov    %edx,%edi
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de8:	89 ec                	mov    %ebp,%esp
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 38             	sub    $0x38,%esp
  800df2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	be 00 00 00 00       	mov    $0x0,%esi
  800e00:	b8 04 00 00 00       	mov    $0x4,%eax
  800e05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	89 f7                	mov    %esi,%edi
  800e10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 28                	jle    800e3e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e21:	00 
  800e22:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e31:	00 
  800e32:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e39:	e8 52 11 00 00       	call   801f90 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e47:	89 ec                	mov    %ebp,%esp
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	83 ec 38             	sub    $0x38,%esp
  800e51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e57:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7e 28                	jle    800e9c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e7f:	00 
  800e80:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e87:	00 
  800e88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8f:	00 
  800e90:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e97:	e8 f4 10 00 00       	call   801f90 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e9c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea5:	89 ec                	mov    %ebp,%esp
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 38             	sub    $0x38,%esp
  800eaf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebd:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	89 df                	mov    %ebx,%edi
  800eca:	89 de                	mov    %ebx,%esi
  800ecc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	7e 28                	jle    800efa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800edd:	00 
  800ede:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800ef5:	e8 96 10 00 00       	call   801f90 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800efa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f03:	89 ec                	mov    %ebp,%esp
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 38             	sub    $0x38,%esp
  800f0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f13:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	89 df                	mov    %ebx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 28                	jle    800f58 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f34:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800f43:	00 
  800f44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4b:	00 
  800f4c:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800f53:	e8 38 10 00 00       	call   801f90 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f58:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f61:	89 ec                	mov    %ebp,%esp
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 38             	sub    $0x38,%esp
  800f6b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f6e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f71:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f79:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 df                	mov    %ebx,%edi
  800f86:	89 de                	mov    %ebx,%esi
  800f88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	7e 28                	jle    800fb6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f92:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f99:	00 
  800f9a:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa9:	00 
  800faa:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800fb1:	e8 da 0f 00 00       	call   801f90 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fb6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fbf:	89 ec                	mov    %ebp,%esp
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	83 ec 38             	sub    $0x38,%esp
  800fc9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fcc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fcf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe2:	89 df                	mov    %ebx,%edi
  800fe4:	89 de                	mov    %ebx,%esi
  800fe6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	7e 28                	jle    801014 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fec:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ff7:	00 
  800ff8:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800fff:	00 
  801000:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801007:	00 
  801008:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  80100f:	e8 7c 0f 00 00       	call   801f90 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801014:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801017:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101d:	89 ec                	mov    %ebp,%esp
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80102d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801030:	be 00 00 00 00       	mov    $0x0,%esi
  801035:	b8 0c 00 00 00       	mov    $0xc,%eax
  80103a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80103d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801048:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801051:	89 ec                	mov    %ebp,%esp
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 38             	sub    $0x38,%esp
  80105b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80105e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801061:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801064:	b9 00 00 00 00       	mov    $0x0,%ecx
  801069:	b8 0d 00 00 00       	mov    $0xd,%eax
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	89 cb                	mov    %ecx,%ebx
  801073:	89 cf                	mov    %ecx,%edi
  801075:	89 ce                	mov    %ecx,%esi
  801077:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	7e 28                	jle    8010a5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801081:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801088:	00 
  801089:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  801090:	00 
  801091:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801098:	00 
  801099:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  8010a0:	e8 eb 0e 00 00       	call   801f90 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010a5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ae:	89 ec                	mov    %ebp,%esp
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010bb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010be:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ce:	89 cb                	mov    %ecx,%ebx
  8010d0:	89 cf                	mov    %ecx,%edi
  8010d2:	89 ce                	mov    %ecx,%esi
  8010d4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8010d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010df:	89 ec                	mov    %ebp,%esp
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    
	...

008010e4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010ea:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8010f1:	75 3c                	jne    80112f <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8010f3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801102:	ee 
  801103:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80110a:	e8 dd fc ff ff       	call   800dec <sys_page_alloc>
  80110f:	85 c0                	test   %eax,%eax
  801111:	79 1c                	jns    80112f <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801113:	c7 44 24 08 6c 27 80 	movl   $0x80276c,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 ce 27 80 00 	movl   $0x8027ce,(%esp)
  80112a:	e8 61 0e 00 00       	call   801f90 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801137:	c7 44 24 04 70 11 80 	movl   $0x801170,0x4(%esp)
  80113e:	00 
  80113f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801146:	e8 78 fe ff ff       	call   800fc3 <sys_env_set_pgfault_upcall>
  80114b:	85 c0                	test   %eax,%eax
  80114d:	79 1c                	jns    80116b <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80114f:	c7 44 24 08 98 27 80 	movl   $0x802798,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80115e:	00 
  80115f:	c7 04 24 ce 27 80 00 	movl   $0x8027ce,(%esp)
  801166:	e8 25 0e 00 00       	call   801f90 <_panic>
}
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    
  80116d:	00 00                	add    %al,(%eax)
	...

00801170 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801170:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801171:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801176:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801178:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80117b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80117f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801184:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  801188:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80118a:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  80118d:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80118e:	83 c4 04             	add    $0x4,%esp
    popfl
  801191:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  801192:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  801193:	c3                   	ret    
	...

008011a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 df ff ff ff       	call   8011a0 <fd2num>
  8011c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	53                   	push   %ebx
  8011cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011d7:	a8 01                	test   $0x1,%al
  8011d9:	74 34                	je     80120f <fd_alloc+0x44>
  8011db:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011e0:	a8 01                	test   $0x1,%al
  8011e2:	74 32                	je     801216 <fd_alloc+0x4b>
  8011e4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011e9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	c1 ea 16             	shr    $0x16,%edx
  8011f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f7:	f6 c2 01             	test   $0x1,%dl
  8011fa:	74 1f                	je     80121b <fd_alloc+0x50>
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	c1 ea 0c             	shr    $0xc,%edx
  801201:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801208:	f6 c2 01             	test   $0x1,%dl
  80120b:	75 17                	jne    801224 <fd_alloc+0x59>
  80120d:	eb 0c                	jmp    80121b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80120f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801214:	eb 05                	jmp    80121b <fd_alloc+0x50>
  801216:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80121b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
  801222:	eb 17                	jmp    80123b <fd_alloc+0x70>
  801224:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801229:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122e:	75 b9                	jne    8011e9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801230:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801236:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80123b:	5b                   	pop    %ebx
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801244:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801249:	83 fa 1f             	cmp    $0x1f,%edx
  80124c:	77 3f                	ja     80128d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801254:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801257:	89 d0                	mov    %edx,%eax
  801259:	c1 e8 16             	shr    $0x16,%eax
  80125c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801268:	f6 c1 01             	test   $0x1,%cl
  80126b:	74 20                	je     80128d <fd_lookup+0x4f>
  80126d:	89 d0                	mov    %edx,%eax
  80126f:	c1 e8 0c             	shr    $0xc,%eax
  801272:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801279:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80127e:	f6 c1 01             	test   $0x1,%cl
  801281:	74 0a                	je     80128d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801283:	8b 45 0c             	mov    0xc(%ebp),%eax
  801286:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	53                   	push   %ebx
  801293:	83 ec 14             	sub    $0x14,%esp
  801296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80129c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012a1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8012a7:	75 17                	jne    8012c0 <dev_lookup+0x31>
  8012a9:	eb 07                	jmp    8012b2 <dev_lookup+0x23>
  8012ab:	39 0a                	cmp    %ecx,(%edx)
  8012ad:	75 11                	jne    8012c0 <dev_lookup+0x31>
  8012af:	90                   	nop
  8012b0:	eb 05                	jmp    8012b7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b2:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012b7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012be:	eb 35                	jmp    8012f5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c0:	83 c0 01             	add    $0x1,%eax
  8012c3:	8b 14 85 58 28 80 00 	mov    0x802858(,%eax,4),%edx
  8012ca:	85 d2                	test   %edx,%edx
  8012cc:	75 dd                	jne    8012ab <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d3:	8b 40 48             	mov    0x48(%eax),%eax
  8012d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012de:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  8012e5:	e8 b9 ee ff ff       	call   8001a3 <cprintf>
	*dev = 0;
  8012ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f5:	83 c4 14             	add    $0x14,%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    

008012fb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	83 ec 38             	sub    $0x38,%esp
  801301:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801304:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801307:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80130a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80130d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801311:	89 3c 24             	mov    %edi,(%esp)
  801314:	e8 87 fe ff ff       	call   8011a0 <fd2num>
  801319:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80131c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801320:	89 04 24             	mov    %eax,(%esp)
  801323:	e8 16 ff ff ff       	call   80123e <fd_lookup>
  801328:	89 c3                	mov    %eax,%ebx
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 05                	js     801333 <fd_close+0x38>
	    || fd != fd2)
  80132e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801331:	74 0e                	je     801341 <fd_close+0x46>
		return (must_exist ? r : 0);
  801333:	89 f0                	mov    %esi,%eax
  801335:	84 c0                	test   %al,%al
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
  80133c:	0f 44 d8             	cmove  %eax,%ebx
  80133f:	eb 3d                	jmp    80137e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801341:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801344:	89 44 24 04          	mov    %eax,0x4(%esp)
  801348:	8b 07                	mov    (%edi),%eax
  80134a:	89 04 24             	mov    %eax,(%esp)
  80134d:	e8 3d ff ff ff       	call   80128f <dev_lookup>
  801352:	89 c3                	mov    %eax,%ebx
  801354:	85 c0                	test   %eax,%eax
  801356:	78 16                	js     80136e <fd_close+0x73>
		if (dev->dev_close)
  801358:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80135e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801363:	85 c0                	test   %eax,%eax
  801365:	74 07                	je     80136e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801367:	89 3c 24             	mov    %edi,(%esp)
  80136a:	ff d0                	call   *%eax
  80136c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80136e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801372:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801379:	e8 2b fb ff ff       	call   800ea9 <sys_page_unmap>
	return r;
}
  80137e:	89 d8                	mov    %ebx,%eax
  801380:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801383:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801386:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801389:	89 ec                	mov    %ebp,%esp
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139a:	8b 45 08             	mov    0x8(%ebp),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 99 fe ff ff       	call   80123e <fd_lookup>
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 13                	js     8013bc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013b0:	00 
  8013b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b4:	89 04 24             	mov    %eax,(%esp)
  8013b7:	e8 3f ff ff ff       	call   8012fb <fd_close>
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <close_all>:

void
close_all(void)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ca:	89 1c 24             	mov    %ebx,(%esp)
  8013cd:	e8 bb ff ff ff       	call   80138d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d2:	83 c3 01             	add    $0x1,%ebx
  8013d5:	83 fb 20             	cmp    $0x20,%ebx
  8013d8:	75 f0                	jne    8013ca <close_all+0xc>
		close(i);
}
  8013da:	83 c4 14             	add    $0x14,%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 58             	sub    $0x58,%esp
  8013e6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	89 04 24             	mov    %eax,(%esp)
  8013ff:	e8 3a fe ff ff       	call   80123e <fd_lookup>
  801404:	89 c3                	mov    %eax,%ebx
  801406:	85 c0                	test   %eax,%eax
  801408:	0f 88 e1 00 00 00    	js     8014ef <dup+0x10f>
		return r;
	close(newfdnum);
  80140e:	89 3c 24             	mov    %edi,(%esp)
  801411:	e8 77 ff ff ff       	call   80138d <close>

	newfd = INDEX2FD(newfdnum);
  801416:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80141c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80141f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801422:	89 04 24             	mov    %eax,(%esp)
  801425:	e8 86 fd ff ff       	call   8011b0 <fd2data>
  80142a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80142c:	89 34 24             	mov    %esi,(%esp)
  80142f:	e8 7c fd ff ff       	call   8011b0 <fd2data>
  801434:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801437:	89 d8                	mov    %ebx,%eax
  801439:	c1 e8 16             	shr    $0x16,%eax
  80143c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801443:	a8 01                	test   $0x1,%al
  801445:	74 46                	je     80148d <dup+0xad>
  801447:	89 d8                	mov    %ebx,%eax
  801449:	c1 e8 0c             	shr    $0xc,%eax
  80144c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801453:	f6 c2 01             	test   $0x1,%dl
  801456:	74 35                	je     80148d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801458:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145f:	25 07 0e 00 00       	and    $0xe07,%eax
  801464:	89 44 24 10          	mov    %eax,0x10(%esp)
  801468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80146b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801476:	00 
  801477:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80147b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801482:	e8 c4 f9 ff ff       	call   800e4b <sys_page_map>
  801487:	89 c3                	mov    %eax,%ebx
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 3b                	js     8014c8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801490:	89 c2                	mov    %eax,%edx
  801492:	c1 ea 0c             	shr    $0xc,%edx
  801495:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80149c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014a2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b1:	00 
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014bd:	e8 89 f9 ff ff       	call   800e4b <sys_page_map>
  8014c2:	89 c3                	mov    %eax,%ebx
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	79 25                	jns    8014ed <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d3:	e8 d1 f9 ff ff       	call   800ea9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e6:	e8 be f9 ff ff       	call   800ea9 <sys_page_unmap>
	return r;
  8014eb:	eb 02                	jmp    8014ef <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014ed:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014f4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014fa:	89 ec                	mov    %ebp,%esp
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 24             	sub    $0x24,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801508:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	e8 27 fd ff ff       	call   80123e <fd_lookup>
  801517:	85 c0                	test   %eax,%eax
  801519:	78 6d                	js     801588 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	8b 00                	mov    (%eax),%eax
  801527:	89 04 24             	mov    %eax,(%esp)
  80152a:	e8 60 fd ff ff       	call   80128f <dev_lookup>
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 55                	js     801588 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	8b 50 08             	mov    0x8(%eax),%edx
  801539:	83 e2 03             	and    $0x3,%edx
  80153c:	83 fa 01             	cmp    $0x1,%edx
  80153f:	75 23                	jne    801564 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801541:	a1 04 40 80 00       	mov    0x804004,%eax
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80154d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801551:	c7 04 24 1d 28 80 00 	movl   $0x80281d,(%esp)
  801558:	e8 46 ec ff ff       	call   8001a3 <cprintf>
		return -E_INVAL;
  80155d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801562:	eb 24                	jmp    801588 <read+0x8a>
	}
	if (!dev->dev_read)
  801564:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801567:	8b 52 08             	mov    0x8(%edx),%edx
  80156a:	85 d2                	test   %edx,%edx
  80156c:	74 15                	je     801583 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80156e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801571:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801575:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801578:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	ff d2                	call   *%edx
  801581:	eb 05                	jmp    801588 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801583:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801588:	83 c4 24             	add    $0x24,%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 1c             	sub    $0x1c,%esp
  801597:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159d:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a2:	85 f6                	test   %esi,%esi
  8015a4:	74 30                	je     8015d6 <readn+0x48>
  8015a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ab:	89 f2                	mov    %esi,%edx
  8015ad:	29 c2                	sub    %eax,%edx
  8015af:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015b3:	03 45 0c             	add    0xc(%ebp),%eax
  8015b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ba:	89 3c 24             	mov    %edi,(%esp)
  8015bd:	e8 3c ff ff ff       	call   8014fe <read>
		if (m < 0)
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 10                	js     8015d6 <readn+0x48>
			return m;
		if (m == 0)
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	74 0a                	je     8015d4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ca:	01 c3                	add    %eax,%ebx
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	39 f3                	cmp    %esi,%ebx
  8015d0:	72 d9                	jb     8015ab <readn+0x1d>
  8015d2:	eb 02                	jmp    8015d6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015d4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015d6:	83 c4 1c             	add    $0x1c,%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5f                   	pop    %edi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 24             	sub    $0x24,%esp
  8015e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ef:	89 1c 24             	mov    %ebx,(%esp)
  8015f2:	e8 47 fc ff ff       	call   80123e <fd_lookup>
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 68                	js     801663 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801605:	8b 00                	mov    (%eax),%eax
  801607:	89 04 24             	mov    %eax,(%esp)
  80160a:	e8 80 fc ff ff       	call   80128f <dev_lookup>
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 50                	js     801663 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801616:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161a:	75 23                	jne    80163f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80161c:	a1 04 40 80 00       	mov    0x804004,%eax
  801621:	8b 40 48             	mov    0x48(%eax),%eax
  801624:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801628:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162c:	c7 04 24 39 28 80 00 	movl   $0x802839,(%esp)
  801633:	e8 6b eb ff ff       	call   8001a3 <cprintf>
		return -E_INVAL;
  801638:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163d:	eb 24                	jmp    801663 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801642:	8b 52 0c             	mov    0xc(%edx),%edx
  801645:	85 d2                	test   %edx,%edx
  801647:	74 15                	je     80165e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801649:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80164c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801650:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801653:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	ff d2                	call   *%edx
  80165c:	eb 05                	jmp    801663 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80165e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801663:	83 c4 24             	add    $0x24,%esp
  801666:	5b                   	pop    %ebx
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <seek>:

int
seek(int fdnum, off_t offset)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801672:	89 44 24 04          	mov    %eax,0x4(%esp)
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	89 04 24             	mov    %eax,(%esp)
  80167c:	e8 bd fb ff ff       	call   80123e <fd_lookup>
  801681:	85 c0                	test   %eax,%eax
  801683:	78 0e                	js     801693 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801685:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801688:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 24             	sub    $0x24,%esp
  80169c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a6:	89 1c 24             	mov    %ebx,(%esp)
  8016a9:	e8 90 fb ff ff       	call   80123e <fd_lookup>
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 61                	js     801713 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bc:	8b 00                	mov    (%eax),%eax
  8016be:	89 04 24             	mov    %eax,(%esp)
  8016c1:	e8 c9 fb ff ff       	call   80128f <dev_lookup>
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 49                	js     801713 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d1:	75 23                	jne    8016f6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d8:	8b 40 48             	mov    0x48(%eax),%eax
  8016db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e3:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  8016ea:	e8 b4 ea ff ff       	call   8001a3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f4:	eb 1d                	jmp    801713 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f9:	8b 52 18             	mov    0x18(%edx),%edx
  8016fc:	85 d2                	test   %edx,%edx
  8016fe:	74 0e                	je     80170e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801700:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801703:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	ff d2                	call   *%edx
  80170c:	eb 05                	jmp    801713 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80170e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801713:	83 c4 24             	add    $0x24,%esp
  801716:	5b                   	pop    %ebx
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	53                   	push   %ebx
  80171d:	83 ec 24             	sub    $0x24,%esp
  801720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801723:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	89 04 24             	mov    %eax,(%esp)
  801730:	e8 09 fb ff ff       	call   80123e <fd_lookup>
  801735:	85 c0                	test   %eax,%eax
  801737:	78 52                	js     80178b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801739:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801743:	8b 00                	mov    (%eax),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 42 fb ff ff       	call   80128f <dev_lookup>
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 3a                	js     80178b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801754:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801758:	74 2c                	je     801786 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80175a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80175d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801764:	00 00 00 
	stat->st_isdir = 0;
  801767:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80176e:	00 00 00 
	stat->st_dev = dev;
  801771:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801777:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177e:	89 14 24             	mov    %edx,(%esp)
  801781:	ff 50 14             	call   *0x14(%eax)
  801784:	eb 05                	jmp    80178b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801786:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80178b:	83 c4 24             	add    $0x24,%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 18             	sub    $0x18,%esp
  801797:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80179a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80179d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017a4:	00 
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	89 04 24             	mov    %eax,(%esp)
  8017ab:	e8 bc 01 00 00       	call   80196c <open>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 1b                	js     8017d1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8017b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bd:	89 1c 24             	mov    %ebx,(%esp)
  8017c0:	e8 54 ff ff ff       	call   801719 <fstat>
  8017c5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c7:	89 1c 24             	mov    %ebx,(%esp)
  8017ca:	e8 be fb ff ff       	call   80138d <close>
	return r;
  8017cf:	89 f3                	mov    %esi,%ebx
}
  8017d1:	89 d8                	mov    %ebx,%eax
  8017d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017d6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017d9:	89 ec                	mov    %ebp,%esp
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    
  8017dd:	00 00                	add    %al,(%eax)
	...

008017e0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 18             	sub    $0x18,%esp
  8017e6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017e9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017ec:	89 c3                	mov    %eax,%ebx
  8017ee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f7:	75 11                	jne    80180a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801800:	e8 b4 08 00 00       	call   8020b9 <ipc_find_env>
  801805:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801811:	00 
  801812:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801819:	00 
  80181a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181e:	a1 00 40 80 00       	mov    0x804000,%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 23 08 00 00       	call   80204e <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80182b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801832:	00 
  801833:	89 74 24 04          	mov    %esi,0x4(%esp)
  801837:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183e:	e8 a5 07 00 00       	call   801fe8 <ipc_recv>
}
  801843:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801846:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801849:	89 ec                	mov    %ebp,%esp
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    

0080184d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	53                   	push   %ebx
  801851:	83 ec 14             	sub    $0x14,%esp
  801854:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	8b 40 0c             	mov    0xc(%eax),%eax
  80185d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801862:	ba 00 00 00 00       	mov    $0x0,%edx
  801867:	b8 05 00 00 00       	mov    $0x5,%eax
  80186c:	e8 6f ff ff ff       	call   8017e0 <fsipc>
  801871:	85 c0                	test   %eax,%eax
  801873:	78 2b                	js     8018a0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801875:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80187c:	00 
  80187d:	89 1c 24             	mov    %ebx,(%esp)
  801880:	e8 66 f0 ff ff       	call   8008eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801885:	a1 80 50 80 00       	mov    0x805080,%eax
  80188a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801890:	a1 84 50 80 00       	mov    0x805084,%eax
  801895:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a0:	83 c4 14             	add    $0x14,%esp
  8018a3:	5b                   	pop    %ebx
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c1:	e8 1a ff ff ff       	call   8017e0 <fsipc>
}
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 10             	sub    $0x10,%esp
  8018d0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018de:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ee:	e8 ed fe ff ff       	call   8017e0 <fsipc>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 6a                	js     801963 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018f9:	39 c6                	cmp    %eax,%esi
  8018fb:	73 24                	jae    801921 <devfile_read+0x59>
  8018fd:	c7 44 24 0c 68 28 80 	movl   $0x802868,0xc(%esp)
  801904:	00 
  801905:	c7 44 24 08 6f 28 80 	movl   $0x80286f,0x8(%esp)
  80190c:	00 
  80190d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801914:	00 
  801915:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  80191c:	e8 6f 06 00 00       	call   801f90 <_panic>
	assert(r <= PGSIZE);
  801921:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801926:	7e 24                	jle    80194c <devfile_read+0x84>
  801928:	c7 44 24 0c 8f 28 80 	movl   $0x80288f,0xc(%esp)
  80192f:	00 
  801930:	c7 44 24 08 6f 28 80 	movl   $0x80286f,0x8(%esp)
  801937:	00 
  801938:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80193f:	00 
  801940:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  801947:	e8 44 06 00 00       	call   801f90 <_panic>
	memmove(buf, &fsipcbuf, r);
  80194c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801950:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801957:	00 
  801958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195b:	89 04 24             	mov    %eax,(%esp)
  80195e:	e8 79 f1 ff ff       	call   800adc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801963:	89 d8                	mov    %ebx,%eax
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	83 ec 20             	sub    $0x20,%esp
  801974:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801977:	89 34 24             	mov    %esi,(%esp)
  80197a:	e8 21 ef ff ff       	call   8008a0 <strlen>
		return -E_BAD_PATH;
  80197f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801984:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801989:	7f 5e                	jg     8019e9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80198b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198e:	89 04 24             	mov    %eax,(%esp)
  801991:	e8 35 f8 ff ff       	call   8011cb <fd_alloc>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 4d                	js     8019e9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80199c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019a7:	e8 3f ef ff ff       	call   8008eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019af:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bc:	e8 1f fe ff ff       	call   8017e0 <fsipc>
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	79 15                	jns    8019dc <open+0x70>
		fd_close(fd, 0);
  8019c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ce:	00 
  8019cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d2:	89 04 24             	mov    %eax,(%esp)
  8019d5:	e8 21 f9 ff ff       	call   8012fb <fd_close>
		return r;
  8019da:	eb 0d                	jmp    8019e9 <open+0x7d>
	}

	return fd2num(fd);
  8019dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019df:	89 04 24             	mov    %eax,(%esp)
  8019e2:	e8 b9 f7 ff ff       	call   8011a0 <fd2num>
  8019e7:	89 c3                	mov    %eax,%ebx
}
  8019e9:	89 d8                	mov    %ebx,%eax
  8019eb:	83 c4 20             	add    $0x20,%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	5d                   	pop    %ebp
  8019f1:	c3                   	ret    
	...

00801a00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 18             	sub    $0x18,%esp
  801a06:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a09:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 96 f7 ff ff       	call   8011b0 <fd2data>
  801a1a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a1c:	c7 44 24 04 9b 28 80 	movl   $0x80289b,0x4(%esp)
  801a23:	00 
  801a24:	89 34 24             	mov    %esi,(%esp)
  801a27:	e8 bf ee ff ff       	call   8008eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a2f:	2b 03                	sub    (%ebx),%eax
  801a31:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a37:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a3e:	00 00 00 
	stat->st_dev = &devpipe;
  801a41:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801a48:	30 80 00 
	return 0;
}
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a50:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a53:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a56:	89 ec                	mov    %ebp,%esp
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 14             	sub    $0x14,%esp
  801a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a6f:	e8 35 f4 ff ff       	call   800ea9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a74:	89 1c 24             	mov    %ebx,(%esp)
  801a77:	e8 34 f7 ff ff       	call   8011b0 <fd2data>
  801a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a87:	e8 1d f4 ff ff       	call   800ea9 <sys_page_unmap>
}
  801a8c:	83 c4 14             	add    $0x14,%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	57                   	push   %edi
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 2c             	sub    $0x2c,%esp
  801a9b:	89 c7                	mov    %eax,%edi
  801a9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa0:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aa8:	89 3c 24             	mov    %edi,(%esp)
  801aab:	e8 54 06 00 00       	call   802104 <pageref>
  801ab0:	89 c6                	mov    %eax,%esi
  801ab2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab5:	89 04 24             	mov    %eax,(%esp)
  801ab8:	e8 47 06 00 00       	call   802104 <pageref>
  801abd:	39 c6                	cmp    %eax,%esi
  801abf:	0f 94 c0             	sete   %al
  801ac2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ac5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801acb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ace:	39 cb                	cmp    %ecx,%ebx
  801ad0:	75 08                	jne    801ada <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ad2:	83 c4 2c             	add    $0x2c,%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ada:	83 f8 01             	cmp    $0x1,%eax
  801add:	75 c1                	jne    801aa0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801adf:	8b 52 58             	mov    0x58(%edx),%edx
  801ae2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ae6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801aea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aee:	c7 04 24 a2 28 80 00 	movl   $0x8028a2,(%esp)
  801af5:	e8 a9 e6 ff ff       	call   8001a3 <cprintf>
  801afa:	eb a4                	jmp    801aa0 <_pipeisclosed+0xe>

00801afc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 2c             	sub    $0x2c,%esp
  801b05:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b08:	89 34 24             	mov    %esi,(%esp)
  801b0b:	e8 a0 f6 ff ff       	call   8011b0 <fd2data>
  801b10:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b12:	bf 00 00 00 00       	mov    $0x0,%edi
  801b17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b1b:	75 50                	jne    801b6d <devpipe_write+0x71>
  801b1d:	eb 5c                	jmp    801b7b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1f:	89 da                	mov    %ebx,%edx
  801b21:	89 f0                	mov    %esi,%eax
  801b23:	e8 6a ff ff ff       	call   801a92 <_pipeisclosed>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	75 53                	jne    801b7f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2c:	e8 8b f2 ff ff       	call   800dbc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b31:	8b 43 04             	mov    0x4(%ebx),%eax
  801b34:	8b 13                	mov    (%ebx),%edx
  801b36:	83 c2 20             	add    $0x20,%edx
  801b39:	39 d0                	cmp    %edx,%eax
  801b3b:	73 e2                	jae    801b1f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b40:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801b44:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	c1 fa 1f             	sar    $0x1f,%edx
  801b4c:	c1 ea 1b             	shr    $0x1b,%edx
  801b4f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801b52:	83 e1 1f             	and    $0x1f,%ecx
  801b55:	29 d1                	sub    %edx,%ecx
  801b57:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801b5b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801b5f:	83 c0 01             	add    $0x1,%eax
  801b62:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b65:	83 c7 01             	add    $0x1,%edi
  801b68:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b6b:	74 0e                	je     801b7b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b6d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b70:	8b 13                	mov    (%ebx),%edx
  801b72:	83 c2 20             	add    $0x20,%edx
  801b75:	39 d0                	cmp    %edx,%eax
  801b77:	73 a6                	jae    801b1f <devpipe_write+0x23>
  801b79:	eb c2                	jmp    801b3d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b7b:	89 f8                	mov    %edi,%eax
  801b7d:	eb 05                	jmp    801b84 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b84:	83 c4 2c             	add    $0x2c,%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5f                   	pop    %edi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 28             	sub    $0x28,%esp
  801b92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b98:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b9b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b9e:	89 3c 24             	mov    %edi,(%esp)
  801ba1:	e8 0a f6 ff ff       	call   8011b0 <fd2data>
  801ba6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba8:	be 00 00 00 00       	mov    $0x0,%esi
  801bad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb1:	75 47                	jne    801bfa <devpipe_read+0x6e>
  801bb3:	eb 52                	jmp    801c07 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bb5:	89 f0                	mov    %esi,%eax
  801bb7:	eb 5e                	jmp    801c17 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb9:	89 da                	mov    %ebx,%edx
  801bbb:	89 f8                	mov    %edi,%eax
  801bbd:	8d 76 00             	lea    0x0(%esi),%esi
  801bc0:	e8 cd fe ff ff       	call   801a92 <_pipeisclosed>
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	75 49                	jne    801c12 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801bc9:	e8 ee f1 ff ff       	call   800dbc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bce:	8b 03                	mov    (%ebx),%eax
  801bd0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bd3:	74 e4                	je     801bb9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd5:	89 c2                	mov    %eax,%edx
  801bd7:	c1 fa 1f             	sar    $0x1f,%edx
  801bda:	c1 ea 1b             	shr    $0x1b,%edx
  801bdd:	01 d0                	add    %edx,%eax
  801bdf:	83 e0 1f             	and    $0x1f,%eax
  801be2:	29 d0                	sub    %edx,%eax
  801be4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801be9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bec:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801bef:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf2:	83 c6 01             	add    $0x1,%esi
  801bf5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf8:	74 0d                	je     801c07 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801bfa:	8b 03                	mov    (%ebx),%eax
  801bfc:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bff:	75 d4                	jne    801bd5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c01:	85 f6                	test   %esi,%esi
  801c03:	75 b0                	jne    801bb5 <devpipe_read+0x29>
  801c05:	eb b2                	jmp    801bb9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c07:	89 f0                	mov    %esi,%eax
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	eb 05                	jmp    801c17 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c12:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c17:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c1a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c1d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c20:	89 ec                	mov    %ebp,%esp
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	83 ec 48             	sub    $0x48,%esp
  801c2a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c2d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c30:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c33:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c36:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c39:	89 04 24             	mov    %eax,(%esp)
  801c3c:	e8 8a f5 ff ff       	call   8011cb <fd_alloc>
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	85 c0                	test   %eax,%eax
  801c45:	0f 88 45 01 00 00    	js     801d90 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c52:	00 
  801c53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c61:	e8 86 f1 ff ff       	call   800dec <sys_page_alloc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	0f 88 20 01 00 00    	js     801d90 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c70:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c73:	89 04 24             	mov    %eax,(%esp)
  801c76:	e8 50 f5 ff ff       	call   8011cb <fd_alloc>
  801c7b:	89 c3                	mov    %eax,%ebx
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	0f 88 f8 00 00 00    	js     801d7d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c85:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c8c:	00 
  801c8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9b:	e8 4c f1 ff ff       	call   800dec <sys_page_alloc>
  801ca0:	89 c3                	mov    %eax,%ebx
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	0f 88 d3 00 00 00    	js     801d7d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801caa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cad:	89 04 24             	mov    %eax,(%esp)
  801cb0:	e8 fb f4 ff ff       	call   8011b0 <fd2data>
  801cb5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cbe:	00 
  801cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cca:	e8 1d f1 ff ff       	call   800dec <sys_page_alloc>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	0f 88 91 00 00 00    	js     801d6a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cdc:	89 04 24             	mov    %eax,(%esp)
  801cdf:	e8 cc f4 ff ff       	call   8011b0 <fd2data>
  801ce4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ceb:	00 
  801cec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cf0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cf7:	00 
  801cf8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d03:	e8 43 f1 ff ff       	call   800e4b <sys_page_map>
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 4c                	js     801d5a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d0e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d17:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d1c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d23:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d2c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d31:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3b:	89 04 24             	mov    %eax,(%esp)
  801d3e:	e8 5d f4 ff ff       	call   8011a0 <fd2num>
  801d43:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d45:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d48:	89 04 24             	mov    %eax,(%esp)
  801d4b:	e8 50 f4 ff ff       	call   8011a0 <fd2num>
  801d50:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d58:	eb 36                	jmp    801d90 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801d5a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d65:	e8 3f f1 ff ff       	call   800ea9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d78:	e8 2c f1 ff ff       	call   800ea9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801d7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8b:	e8 19 f1 ff ff       	call   800ea9 <sys_page_unmap>
    err:
	return r;
}
  801d90:	89 d8                	mov    %ebx,%eax
  801d92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d9b:	89 ec                	mov    %ebp,%esp
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dac:	8b 45 08             	mov    0x8(%ebp),%eax
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	e8 87 f4 ff ff       	call   80123e <fd_lookup>
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 15                	js     801dd0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbe:	89 04 24             	mov    %eax,(%esp)
  801dc1:	e8 ea f3 ff ff       	call   8011b0 <fd2data>
	return _pipeisclosed(fd, p);
  801dc6:	89 c2                	mov    %eax,%edx
  801dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcb:	e8 c2 fc ff ff       	call   801a92 <_pipeisclosed>
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    
	...

00801de0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    

00801dea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801df0:	c7 44 24 04 ba 28 80 	movl   $0x8028ba,0x4(%esp)
  801df7:	00 
  801df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfb:	89 04 24             	mov    %eax,(%esp)
  801dfe:	e8 e8 ea ff ff       	call   8008eb <strcpy>
	return 0;
}
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	57                   	push   %edi
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e16:	be 00 00 00 00       	mov    $0x0,%esi
  801e1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e1f:	74 43                	je     801e64 <devcons_write+0x5a>
  801e21:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e26:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e2f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e31:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e34:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e39:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e3c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e40:	03 45 0c             	add    0xc(%ebp),%eax
  801e43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e47:	89 3c 24             	mov    %edi,(%esp)
  801e4a:	e8 8d ec ff ff       	call   800adc <memmove>
		sys_cputs(buf, m);
  801e4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e53:	89 3c 24             	mov    %edi,(%esp)
  801e56:	e8 75 ee ff ff       	call   800cd0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5b:	01 de                	add    %ebx,%esi
  801e5d:	89 f0                	mov    %esi,%eax
  801e5f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e62:	72 c8                	jb     801e2c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e64:	89 f0                	mov    %esi,%eax
  801e66:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e6c:	5b                   	pop    %ebx
  801e6d:	5e                   	pop    %esi
  801e6e:	5f                   	pop    %edi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801e7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e80:	75 07                	jne    801e89 <devcons_read+0x18>
  801e82:	eb 31                	jmp    801eb5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e84:	e8 33 ef ff ff       	call   800dbc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	e8 6a ee ff ff       	call   800cff <sys_cgetc>
  801e95:	85 c0                	test   %eax,%eax
  801e97:	74 eb                	je     801e84 <devcons_read+0x13>
  801e99:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 16                	js     801eb5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e9f:	83 f8 04             	cmp    $0x4,%eax
  801ea2:	74 0c                	je     801eb0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea7:	88 10                	mov    %dl,(%eax)
	return 1;
  801ea9:	b8 01 00 00 00       	mov    $0x1,%eax
  801eae:	eb 05                	jmp    801eb5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eb0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eb5:	c9                   	leave  
  801eb6:	c3                   	ret    

00801eb7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ec3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801eca:	00 
  801ecb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ece:	89 04 24             	mov    %eax,(%esp)
  801ed1:	e8 fa ed ff ff       	call   800cd0 <sys_cputs>
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <getchar>:

int
getchar(void)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ede:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ee5:	00 
  801ee6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef4:	e8 05 f6 ff ff       	call   8014fe <read>
	if (r < 0)
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 0f                	js     801f0c <getchar+0x34>
		return r;
	if (r < 1)
  801efd:	85 c0                	test   %eax,%eax
  801eff:	7e 06                	jle    801f07 <getchar+0x2f>
		return -E_EOF;
	return c;
  801f01:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f05:	eb 05                	jmp    801f0c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f07:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 18 f3 ff ff       	call   80123e <fd_lookup>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 11                	js     801f3b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f33:	39 10                	cmp    %edx,(%eax)
  801f35:	0f 94 c0             	sete   %al
  801f38:	0f b6 c0             	movzbl %al,%eax
}
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <opencons>:

int
opencons(void)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f46:	89 04 24             	mov    %eax,(%esp)
  801f49:	e8 7d f2 ff ff       	call   8011cb <fd_alloc>
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 3c                	js     801f8e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f59:	00 
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f68:	e8 7f ee ff ff       	call   800dec <sys_page_alloc>
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	78 1d                	js     801f8e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f71:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 12 f2 ff ff       	call   8011a0 <fd2num>
}
  801f8e:	c9                   	leave  
  801f8f:	c3                   	ret    

00801f90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801f98:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f9b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801fa1:	e8 e6 ed ff ff       	call   800d8c <sys_getenvid>
  801fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801fad:	8b 55 08             	mov    0x8(%ebp),%edx
  801fb0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbc:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  801fc3:	e8 db e1 ff ff       	call   8001a3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fcc:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcf:	89 04 24             	mov    %eax,(%esp)
  801fd2:	e8 6b e1 ff ff       	call   800142 <vcprintf>
	cprintf("\n");
  801fd7:	c7 04 24 b3 28 80 00 	movl   $0x8028b3,(%esp)
  801fde:	e8 c0 e1 ff ff       	call   8001a3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fe3:	cc                   	int3   
  801fe4:	eb fd                	jmp    801fe3 <_panic+0x53>
	...

00801fe8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	56                   	push   %esi
  801fec:	53                   	push   %ebx
  801fed:	83 ec 10             	sub    $0x10,%esp
  801ff0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ff9:	85 db                	test   %ebx,%ebx
  801ffb:	74 06                	je     802003 <ipc_recv+0x1b>
  801ffd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  802003:	85 f6                	test   %esi,%esi
  802005:	74 06                	je     80200d <ipc_recv+0x25>
  802007:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  80200d:	85 c0                	test   %eax,%eax
  80200f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802014:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  802017:	89 04 24             	mov    %eax,(%esp)
  80201a:	e8 36 f0 ff ff       	call   801055 <sys_ipc_recv>
    if (ret) return ret;
  80201f:	85 c0                	test   %eax,%eax
  802021:	75 24                	jne    802047 <ipc_recv+0x5f>
    if (from_env_store)
  802023:	85 db                	test   %ebx,%ebx
  802025:	74 0a                	je     802031 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  802027:	a1 04 40 80 00       	mov    0x804004,%eax
  80202c:	8b 40 74             	mov    0x74(%eax),%eax
  80202f:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802031:	85 f6                	test   %esi,%esi
  802033:	74 0a                	je     80203f <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  802035:	a1 04 40 80 00       	mov    0x804004,%eax
  80203a:	8b 40 78             	mov    0x78(%eax),%eax
  80203d:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  80203f:	a1 04 40 80 00       	mov    0x804004,%eax
  802044:	8b 40 70             	mov    0x70(%eax),%eax
}
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 75 08             	mov    0x8(%ebp),%esi
  80205a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80205d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802060:	85 db                	test   %ebx,%ebx
  802062:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802067:	0f 44 d8             	cmove  %eax,%ebx
  80206a:	eb 2a                	jmp    802096 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80206c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80206f:	74 20                	je     802091 <ipc_send+0x43>
  802071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802075:	c7 44 24 08 ec 28 80 	movl   $0x8028ec,0x8(%esp)
  80207c:	00 
  80207d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  802084:	00 
  802085:	c7 04 24 03 29 80 00 	movl   $0x802903,(%esp)
  80208c:	e8 ff fe ff ff       	call   801f90 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802091:	e8 26 ed ff ff       	call   800dbc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802096:	8b 45 14             	mov    0x14(%ebp),%eax
  802099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020a5:	89 34 24             	mov    %esi,(%esp)
  8020a8:	e8 74 ef ff ff       	call   801021 <sys_ipc_try_send>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	75 bb                	jne    80206c <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    

008020b9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8020bf:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8020c4:	39 c8                	cmp    %ecx,%eax
  8020c6:	74 19                	je     8020e1 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8020cd:	89 c2                	mov    %eax,%edx
  8020cf:	c1 e2 07             	shl    $0x7,%edx
  8020d2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020d8:	8b 52 50             	mov    0x50(%edx),%edx
  8020db:	39 ca                	cmp    %ecx,%edx
  8020dd:	75 14                	jne    8020f3 <ipc_find_env+0x3a>
  8020df:	eb 05                	jmp    8020e6 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020e1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020e6:	c1 e0 07             	shl    $0x7,%eax
  8020e9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8020ee:	8b 40 40             	mov    0x40(%eax),%eax
  8020f1:	eb 0e                	jmp    802101 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020f3:	83 c0 01             	add    $0x1,%eax
  8020f6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020fb:	75 d0                	jne    8020cd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020fd:	66 b8 00 00          	mov    $0x0,%ax
}
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    
	...

00802104 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	c1 e8 16             	shr    $0x16,%eax
  80210f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802116:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211b:	f6 c1 01             	test   $0x1,%cl
  80211e:	74 1d                	je     80213d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802120:	c1 ea 0c             	shr    $0xc,%edx
  802123:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80212a:	f6 c2 01             	test   $0x1,%dl
  80212d:	74 0e                	je     80213d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80212f:	c1 ea 0c             	shr    $0xc,%edx
  802132:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802139:	ef 
  80213a:	0f b7 c0             	movzwl %ax,%eax
}
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    
	...

00802140 <__udivdi3>:
  802140:	83 ec 1c             	sub    $0x1c,%esp
  802143:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802147:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80214b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80214f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802153:	89 74 24 10          	mov    %esi,0x10(%esp)
  802157:	8b 74 24 24          	mov    0x24(%esp),%esi
  80215b:	85 ff                	test   %edi,%edi
  80215d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802161:	89 44 24 08          	mov    %eax,0x8(%esp)
  802165:	89 cd                	mov    %ecx,%ebp
  802167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216b:	75 33                	jne    8021a0 <__udivdi3+0x60>
  80216d:	39 f1                	cmp    %esi,%ecx
  80216f:	77 57                	ja     8021c8 <__udivdi3+0x88>
  802171:	85 c9                	test   %ecx,%ecx
  802173:	75 0b                	jne    802180 <__udivdi3+0x40>
  802175:	b8 01 00 00 00       	mov    $0x1,%eax
  80217a:	31 d2                	xor    %edx,%edx
  80217c:	f7 f1                	div    %ecx
  80217e:	89 c1                	mov    %eax,%ecx
  802180:	89 f0                	mov    %esi,%eax
  802182:	31 d2                	xor    %edx,%edx
  802184:	f7 f1                	div    %ecx
  802186:	89 c6                	mov    %eax,%esi
  802188:	8b 44 24 04          	mov    0x4(%esp),%eax
  80218c:	f7 f1                	div    %ecx
  80218e:	89 f2                	mov    %esi,%edx
  802190:	8b 74 24 10          	mov    0x10(%esp),%esi
  802194:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802198:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	c3                   	ret    
  8021a0:	31 d2                	xor    %edx,%edx
  8021a2:	31 c0                	xor    %eax,%eax
  8021a4:	39 f7                	cmp    %esi,%edi
  8021a6:	77 e8                	ja     802190 <__udivdi3+0x50>
  8021a8:	0f bd cf             	bsr    %edi,%ecx
  8021ab:	83 f1 1f             	xor    $0x1f,%ecx
  8021ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021b2:	75 2c                	jne    8021e0 <__udivdi3+0xa0>
  8021b4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8021b8:	76 04                	jbe    8021be <__udivdi3+0x7e>
  8021ba:	39 f7                	cmp    %esi,%edi
  8021bc:	73 d2                	jae    802190 <__udivdi3+0x50>
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c5:	eb c9                	jmp    802190 <__udivdi3+0x50>
  8021c7:	90                   	nop
  8021c8:	89 f2                	mov    %esi,%edx
  8021ca:	f7 f1                	div    %ecx
  8021cc:	31 d2                	xor    %edx,%edx
  8021ce:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021d2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021d6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	c3                   	ret    
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021e5:	b8 20 00 00 00       	mov    $0x20,%eax
  8021ea:	89 ea                	mov    %ebp,%edx
  8021ec:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f0:	d3 e7                	shl    %cl,%edi
  8021f2:	89 c1                	mov    %eax,%ecx
  8021f4:	d3 ea                	shr    %cl,%edx
  8021f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021fb:	09 fa                	or     %edi,%edx
  8021fd:	89 f7                	mov    %esi,%edi
  8021ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802203:	89 f2                	mov    %esi,%edx
  802205:	8b 74 24 08          	mov    0x8(%esp),%esi
  802209:	d3 e5                	shl    %cl,%ebp
  80220b:	89 c1                	mov    %eax,%ecx
  80220d:	d3 ef                	shr    %cl,%edi
  80220f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802214:	d3 e2                	shl    %cl,%edx
  802216:	89 c1                	mov    %eax,%ecx
  802218:	d3 ee                	shr    %cl,%esi
  80221a:	09 d6                	or     %edx,%esi
  80221c:	89 fa                	mov    %edi,%edx
  80221e:	89 f0                	mov    %esi,%eax
  802220:	f7 74 24 0c          	divl   0xc(%esp)
  802224:	89 d7                	mov    %edx,%edi
  802226:	89 c6                	mov    %eax,%esi
  802228:	f7 e5                	mul    %ebp
  80222a:	39 d7                	cmp    %edx,%edi
  80222c:	72 22                	jb     802250 <__udivdi3+0x110>
  80222e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802232:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802237:	d3 e5                	shl    %cl,%ebp
  802239:	39 c5                	cmp    %eax,%ebp
  80223b:	73 04                	jae    802241 <__udivdi3+0x101>
  80223d:	39 d7                	cmp    %edx,%edi
  80223f:	74 0f                	je     802250 <__udivdi3+0x110>
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	e9 46 ff ff ff       	jmp    802190 <__udivdi3+0x50>
  80224a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802250:	8d 46 ff             	lea    -0x1(%esi),%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	8b 74 24 10          	mov    0x10(%esp),%esi
  802259:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80225d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	c3                   	ret    
	...

00802270 <__umoddi3>:
  802270:	83 ec 1c             	sub    $0x1c,%esp
  802273:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802277:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80227b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80227f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802283:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802287:	8b 74 24 24          	mov    0x24(%esp),%esi
  80228b:	85 ed                	test   %ebp,%ebp
  80228d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802291:	89 44 24 08          	mov    %eax,0x8(%esp)
  802295:	89 cf                	mov    %ecx,%edi
  802297:	89 04 24             	mov    %eax,(%esp)
  80229a:	89 f2                	mov    %esi,%edx
  80229c:	75 1a                	jne    8022b8 <__umoddi3+0x48>
  80229e:	39 f1                	cmp    %esi,%ecx
  8022a0:	76 4e                	jbe    8022f0 <__umoddi3+0x80>
  8022a2:	f7 f1                	div    %ecx
  8022a4:	89 d0                	mov    %edx,%eax
  8022a6:	31 d2                	xor    %edx,%edx
  8022a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	c3                   	ret    
  8022b8:	39 f5                	cmp    %esi,%ebp
  8022ba:	77 54                	ja     802310 <__umoddi3+0xa0>
  8022bc:	0f bd c5             	bsr    %ebp,%eax
  8022bf:	83 f0 1f             	xor    $0x1f,%eax
  8022c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c6:	75 60                	jne    802328 <__umoddi3+0xb8>
  8022c8:	3b 0c 24             	cmp    (%esp),%ecx
  8022cb:	0f 87 07 01 00 00    	ja     8023d8 <__umoddi3+0x168>
  8022d1:	89 f2                	mov    %esi,%edx
  8022d3:	8b 34 24             	mov    (%esp),%esi
  8022d6:	29 ce                	sub    %ecx,%esi
  8022d8:	19 ea                	sbb    %ebp,%edx
  8022da:	89 34 24             	mov    %esi,(%esp)
  8022dd:	8b 04 24             	mov    (%esp),%eax
  8022e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022ec:	83 c4 1c             	add    $0x1c,%esp
  8022ef:	c3                   	ret    
  8022f0:	85 c9                	test   %ecx,%ecx
  8022f2:	75 0b                	jne    8022ff <__umoddi3+0x8f>
  8022f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f9:	31 d2                	xor    %edx,%edx
  8022fb:	f7 f1                	div    %ecx
  8022fd:	89 c1                	mov    %eax,%ecx
  8022ff:	89 f0                	mov    %esi,%eax
  802301:	31 d2                	xor    %edx,%edx
  802303:	f7 f1                	div    %ecx
  802305:	8b 04 24             	mov    (%esp),%eax
  802308:	f7 f1                	div    %ecx
  80230a:	eb 98                	jmp    8022a4 <__umoddi3+0x34>
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 f2                	mov    %esi,%edx
  802312:	8b 74 24 10          	mov    0x10(%esp),%esi
  802316:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80231a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80231e:	83 c4 1c             	add    $0x1c,%esp
  802321:	c3                   	ret    
  802322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802328:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80232d:	89 e8                	mov    %ebp,%eax
  80232f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802334:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802338:	89 fa                	mov    %edi,%edx
  80233a:	d3 e0                	shl    %cl,%eax
  80233c:	89 e9                	mov    %ebp,%ecx
  80233e:	d3 ea                	shr    %cl,%edx
  802340:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802345:	09 c2                	or     %eax,%edx
  802347:	8b 44 24 08          	mov    0x8(%esp),%eax
  80234b:	89 14 24             	mov    %edx,(%esp)
  80234e:	89 f2                	mov    %esi,%edx
  802350:	d3 e7                	shl    %cl,%edi
  802352:	89 e9                	mov    %ebp,%ecx
  802354:	d3 ea                	shr    %cl,%edx
  802356:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80235b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80235f:	d3 e6                	shl    %cl,%esi
  802361:	89 e9                	mov    %ebp,%ecx
  802363:	d3 e8                	shr    %cl,%eax
  802365:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80236a:	09 f0                	or     %esi,%eax
  80236c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802370:	f7 34 24             	divl   (%esp)
  802373:	d3 e6                	shl    %cl,%esi
  802375:	89 74 24 08          	mov    %esi,0x8(%esp)
  802379:	89 d6                	mov    %edx,%esi
  80237b:	f7 e7                	mul    %edi
  80237d:	39 d6                	cmp    %edx,%esi
  80237f:	89 c1                	mov    %eax,%ecx
  802381:	89 d7                	mov    %edx,%edi
  802383:	72 3f                	jb     8023c4 <__umoddi3+0x154>
  802385:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802389:	72 35                	jb     8023c0 <__umoddi3+0x150>
  80238b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80238f:	29 c8                	sub    %ecx,%eax
  802391:	19 fe                	sbb    %edi,%esi
  802393:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802398:	89 f2                	mov    %esi,%edx
  80239a:	d3 e8                	shr    %cl,%eax
  80239c:	89 e9                	mov    %ebp,%ecx
  80239e:	d3 e2                	shl    %cl,%edx
  8023a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023a5:	09 d0                	or     %edx,%eax
  8023a7:	89 f2                	mov    %esi,%edx
  8023a9:	d3 ea                	shr    %cl,%edx
  8023ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8023b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8023b7:	83 c4 1c             	add    $0x1c,%esp
  8023ba:	c3                   	ret    
  8023bb:	90                   	nop
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	39 d6                	cmp    %edx,%esi
  8023c2:	75 c7                	jne    80238b <__umoddi3+0x11b>
  8023c4:	89 d7                	mov    %edx,%edi
  8023c6:	89 c1                	mov    %eax,%ecx
  8023c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8023cc:	1b 3c 24             	sbb    (%esp),%edi
  8023cf:	eb ba                	jmp    80238b <__umoddi3+0x11b>
  8023d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	39 f5                	cmp    %esi,%ebp
  8023da:	0f 82 f1 fe ff ff    	jb     8022d1 <__umoddi3+0x61>
  8023e0:	e9 f8 fe ff ff       	jmp    8022dd <__umoddi3+0x6d>
