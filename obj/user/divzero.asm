
obj/user/divzero.debug:     file format elf32-i386


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
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 20 23 80 00 	movl   $0x802320,(%esp)
  800060:	e8 12 01 00 00       	call   800177 <cprintf>
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
  80007a:	e8 ed 0c 00 00       	call   800d6c <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	c1 e0 07             	shl    $0x7,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 f6                	test   %esi,%esi
  800093:	7e 07                	jle    80009c <libmain+0x34>
		binaryname = argv[0];
  800095:	8b 03                	mov    (%ebx),%eax
  800097:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000be:	e8 2b 12 00 00       	call   8012ee <close_all>
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 40 0c 00 00       	call   800d0f <sys_env_destroy>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    
  8000d1:	00 00                	add    %al,(%eax)
	...

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e7:	83 c0 01             	add    $0x1,%eax
  8000ea:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f1:	75 19                	jne    80010c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fa:	00 
  8000fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fe:	89 04 24             	mov    %eax,(%esp)
  800101:	e8 aa 0b 00 00       	call   800cb0 <sys_cputs>
		b->idx = 0;
  800106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800110:	83 c4 14             	add    $0x14,%esp
  800113:	5b                   	pop    %ebx
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800126:	00 00 00 
	b.cnt = 0;
  800129:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800130:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800141:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014b:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  800152:	e8 97 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800157:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 41 0b 00 00       	call   800cb0 <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 87 ff ff ff       	call   800116 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    
  800191:	00 00                	add    %al,(%eax)
	...

00800194 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 3c             	sub    $0x3c,%esp
  80019d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001a0:	89 d7                	mov    %edx,%edi
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001bc:	72 11                	jb     8001cf <printnum+0x3b>
  8001be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c4:	76 09                	jbe    8001cf <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c6:	83 eb 01             	sub    $0x1,%ebx
  8001c9:	85 db                	test   %ebx,%ebx
  8001cb:	7f 51                	jg     80021e <printnum+0x8a>
  8001cd:	eb 5e                	jmp    80022d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001d3:	83 eb 01             	sub    $0x1,%ebx
  8001d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001e5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f0:	00 
  8001f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fe:	e8 6d 1e 00 00       	call   802070 <__udivdi3>
  800203:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800207:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800212:	89 fa                	mov    %edi,%edx
  800214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800217:	e8 78 ff ff ff       	call   800194 <printnum>
  80021c:	eb 0f                	jmp    80022d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800222:	89 34 24             	mov    %esi,(%esp)
  800225:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	75 f1                	jne    80021e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800231:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800235:	8b 45 10             	mov    0x10(%ebp),%eax
  800238:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800243:	00 
  800244:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	e8 4a 1f 00 00       	call   8021a0 <__umoddi3>
  800256:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025a:	0f be 80 38 23 80 00 	movsbl 0x802338(%eax),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800267:	83 c4 3c             	add    $0x3c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800272:	83 fa 01             	cmp    $0x1,%edx
  800275:	7e 0e                	jle    800285 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	8b 52 04             	mov    0x4(%edx),%edx
  800283:	eb 22                	jmp    8002a7 <getuint+0x38>
	else if (lflag)
  800285:	85 d2                	test   %edx,%edx
  800287:	74 10                	je     800299 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	eb 0e                	jmp    8002a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bd:	88 0a                	mov    %cl,(%edx)
  8002bf:	83 c2 01             	add    $0x1,%edx
  8002c2:	89 10                	mov    %edx,(%eax)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	e8 02 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 5c             	sub    $0x5c,%esp
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 75 10             	mov    0x10(%ebp),%esi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 e4 04 00 00    	je     8007eb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800307:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	0f b6 06             	movzbl (%esi),%eax
  800314:	83 c6 01             	add    $0x1,%esi
  800317:	83 f8 25             	cmp    $0x25,%eax
  80031a:	75 e3                	jne    8002ff <vprintfmt+0x11>
  80031c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800320:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800327:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80032c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800333:	b9 00 00 00 00       	mov    $0x0,%ecx
  800338:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80033b:	eb 2b                	jmp    800368 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800344:	eb 22                	jmp    800368 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800349:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80034d:	eb 19                	jmp    800368 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800352:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800359:	eb 0d                	jmp    800368 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80035b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80035e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800361:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800368:	0f b6 06             	movzbl (%esi),%eax
  80036b:	0f b6 d0             	movzbl %al,%edx
  80036e:	8d 7e 01             	lea    0x1(%esi),%edi
  800371:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800374:	83 e8 23             	sub    $0x23,%eax
  800377:	3c 55                	cmp    $0x55,%al
  800379:	0f 87 46 04 00 00    	ja     8007c5 <vprintfmt+0x4d7>
  80037f:	0f b6 c0             	movzbl %al,%eax
  800382:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800389:	83 ea 30             	sub    $0x30,%edx
  80038c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80038f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800393:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800399:	83 fa 09             	cmp    $0x9,%edx
  80039c:	77 4a                	ja     8003e8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003a4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003a7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ab:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ae:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b1:	83 fa 09             	cmp    $0x9,%edx
  8003b4:	76 eb                	jbe    8003a1 <vprintfmt+0xb3>
  8003b6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003b9:	eb 2d                	jmp    8003e8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 50 04             	lea    0x4(%eax),%edx
  8003c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c4:	8b 00                	mov    (%eax),%eax
  8003c6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cc:	eb 1a                	jmp    8003e8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003d1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003d5:	79 91                	jns    800368 <vprintfmt+0x7a>
  8003d7:	e9 73 ff ff ff       	jmp    80034f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003df:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003e6:	eb 80                	jmp    800368 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003e8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003ec:	0f 89 76 ff ff ff    	jns    800368 <vprintfmt+0x7a>
  8003f2:	e9 64 ff ff ff       	jmp    80035b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fd:	e9 66 ff ff ff       	jmp    800368 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 50 04             	lea    0x4(%eax),%edx
  800408:	89 55 14             	mov    %edx,0x14(%ebp)
  80040b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	89 04 24             	mov    %eax,(%esp)
  800414:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041a:	e9 f2 fe ff ff       	jmp    800311 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80041f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800423:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800426:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80042a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80042d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800431:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800434:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800437:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80043b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80043e:	80 f9 09             	cmp    $0x9,%cl
  800441:	77 1d                	ja     800460 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800443:	0f be c0             	movsbl %al,%eax
  800446:	6b c0 64             	imul   $0x64,%eax,%eax
  800449:	0f be d2             	movsbl %dl,%edx
  80044c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80044f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800456:	a3 04 30 80 00       	mov    %eax,0x803004
  80045b:	e9 b1 fe ff ff       	jmp    800311 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800460:	c7 44 24 04 50 23 80 	movl   $0x802350,0x4(%esp)
  800467:	00 
  800468:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	e8 18 05 00 00       	call   80098b <strcmp>
  800473:	85 c0                	test   %eax,%eax
  800475:	75 0f                	jne    800486 <vprintfmt+0x198>
  800477:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  80047e:	00 00 00 
  800481:	e9 8b fe ff ff       	jmp    800311 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800486:	c7 44 24 04 54 23 80 	movl   $0x802354,0x4(%esp)
  80048d:	00 
  80048e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800491:	89 14 24             	mov    %edx,(%esp)
  800494:	e8 f2 04 00 00       	call   80098b <strcmp>
  800499:	85 c0                	test   %eax,%eax
  80049b:	75 0f                	jne    8004ac <vprintfmt+0x1be>
  80049d:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8004a4:	00 00 00 
  8004a7:	e9 65 fe ff ff       	jmp    800311 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004ac:	c7 44 24 04 58 23 80 	movl   $0x802358,0x4(%esp)
  8004b3:	00 
  8004b4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004b7:	89 0c 24             	mov    %ecx,(%esp)
  8004ba:	e8 cc 04 00 00       	call   80098b <strcmp>
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	75 0f                	jne    8004d2 <vprintfmt+0x1e4>
  8004c3:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8004ca:	00 00 00 
  8004cd:	e9 3f fe ff ff       	jmp    800311 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004d2:	c7 44 24 04 5c 23 80 	movl   $0x80235c,0x4(%esp)
  8004d9:	00 
  8004da:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004dd:	89 3c 24             	mov    %edi,(%esp)
  8004e0:	e8 a6 04 00 00       	call   80098b <strcmp>
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 0f                	jne    8004f8 <vprintfmt+0x20a>
  8004e9:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  8004f0:	00 00 00 
  8004f3:	e9 19 fe ff ff       	jmp    800311 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004f8:	c7 44 24 04 60 23 80 	movl   $0x802360,0x4(%esp)
  8004ff:	00 
  800500:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	e8 80 04 00 00       	call   80098b <strcmp>
  80050b:	85 c0                	test   %eax,%eax
  80050d:	75 0f                	jne    80051e <vprintfmt+0x230>
  80050f:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800516:	00 00 00 
  800519:	e9 f3 fd ff ff       	jmp    800311 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80051e:	c7 44 24 04 64 23 80 	movl   $0x802364,0x4(%esp)
  800525:	00 
  800526:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800529:	89 14 24             	mov    %edx,(%esp)
  80052c:	e8 5a 04 00 00       	call   80098b <strcmp>
  800531:	83 f8 01             	cmp    $0x1,%eax
  800534:	19 c0                	sbb    %eax,%eax
  800536:	f7 d0                	not    %eax
  800538:	83 c0 08             	add    $0x8,%eax
  80053b:	a3 04 30 80 00       	mov    %eax,0x803004
  800540:	e9 cc fd ff ff       	jmp    800311 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 c2                	mov    %eax,%edx
  800552:	c1 fa 1f             	sar    $0x1f,%edx
  800555:	31 d0                	xor    %edx,%eax
  800557:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800559:	83 f8 0f             	cmp    $0xf,%eax
  80055c:	7f 0b                	jg     800569 <vprintfmt+0x27b>
  80055e:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  800565:	85 d2                	test   %edx,%edx
  800567:	75 23                	jne    80058c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800569:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056d:	c7 44 24 08 68 23 80 	movl   $0x802368,0x8(%esp)
  800574:	00 
  800575:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800579:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057c:	89 3c 24             	mov    %edi,(%esp)
  80057f:	e8 42 fd ff ff       	call   8002c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800587:	e9 85 fd ff ff       	jmp    800311 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80058c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800590:	c7 44 24 08 31 27 80 	movl   $0x802731,0x8(%esp)
  800597:	00 
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059f:	89 3c 24             	mov    %edi,(%esp)
  8005a2:	e8 1f fd ff ff       	call   8002c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005aa:	e9 62 fd ff ff       	jmp    800311 <vprintfmt+0x23>
  8005af:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005c3:	85 f6                	test   %esi,%esi
  8005c5:	b8 49 23 80 00       	mov    $0x802349,%eax
  8005ca:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005cd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005d1:	7e 06                	jle    8005d9 <vprintfmt+0x2eb>
  8005d3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005d7:	75 13                	jne    8005ec <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	83 c6 01             	add    $0x1,%esi
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	0f 85 94 00 00 00    	jne    80067b <vprintfmt+0x38d>
  8005e7:	e9 81 00 00 00       	jmp    80066d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f0:	89 34 24             	mov    %esi,(%esp)
  8005f3:	e8 a3 02 00 00       	call   80089b <strnlen>
  8005f8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005fb:	29 c2                	sub    %eax,%edx
  8005fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800600:	85 d2                	test   %edx,%edx
  800602:	7e d5                	jle    8005d9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800604:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800608:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80060b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80060e:	89 d6                	mov    %edx,%esi
  800610:	89 cf                	mov    %ecx,%edi
  800612:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800616:	89 3c 24             	mov    %edi,(%esp)
  800619:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061c:	83 ee 01             	sub    $0x1,%esi
  80061f:	75 f1                	jne    800612 <vprintfmt+0x324>
  800621:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800624:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800627:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80062a:	eb ad                	jmp    8005d9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800630:	74 1b                	je     80064d <vprintfmt+0x35f>
  800632:	8d 50 e0             	lea    -0x20(%eax),%edx
  800635:	83 fa 5e             	cmp    $0x5e,%edx
  800638:	76 13                	jbe    80064d <vprintfmt+0x35f>
					putch('?', putdat);
  80063a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800641:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
  80064b:	eb 0d                	jmp    80065a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80064d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800650:	89 54 24 04          	mov    %edx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	83 eb 01             	sub    $0x1,%ebx
  80065d:	0f be 06             	movsbl (%esi),%eax
  800660:	83 c6 01             	add    $0x1,%esi
  800663:	85 c0                	test   %eax,%eax
  800665:	75 1a                	jne    800681 <vprintfmt+0x393>
  800667:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80066a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800670:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800674:	7f 1c                	jg     800692 <vprintfmt+0x3a4>
  800676:	e9 96 fc ff ff       	jmp    800311 <vprintfmt+0x23>
  80067b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80067e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800681:	85 ff                	test   %edi,%edi
  800683:	78 a7                	js     80062c <vprintfmt+0x33e>
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	79 a2                	jns    80062c <vprintfmt+0x33e>
  80068a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80068d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800690:	eb db                	jmp    80066d <vprintfmt+0x37f>
  800692:	8b 7d 08             	mov    0x8(%ebp),%edi
  800695:	89 de                	mov    %ebx,%esi
  800697:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a7:	83 eb 01             	sub    $0x1,%ebx
  8006aa:	75 ee                	jne    80069a <vprintfmt+0x3ac>
  8006ac:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006b1:	e9 5b fc ff ff       	jmp    800311 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b6:	83 f9 01             	cmp    $0x1,%ecx
  8006b9:	7e 10                	jle    8006cb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 08             	lea    0x8(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 30                	mov    (%eax),%esi
  8006c6:	8b 78 04             	mov    0x4(%eax),%edi
  8006c9:	eb 26                	jmp    8006f1 <vprintfmt+0x403>
	else if (lflag)
  8006cb:	85 c9                	test   %ecx,%ecx
  8006cd:	74 12                	je     8006e1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 04             	lea    0x4(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 30                	mov    (%eax),%esi
  8006da:	89 f7                	mov    %esi,%edi
  8006dc:	c1 ff 1f             	sar    $0x1f,%edi
  8006df:	eb 10                	jmp    8006f1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 04             	lea    0x4(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 30                	mov    (%eax),%esi
  8006ec:	89 f7                	mov    %esi,%edi
  8006ee:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	78 0e                	js     800703 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f5:	89 f0                	mov    %esi,%eax
  8006f7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f9:	be 0a 00 00 00       	mov    $0xa,%esi
  8006fe:	e9 84 00 00 00       	jmp    800787 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800703:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800707:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80070e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800711:	89 f0                	mov    %esi,%eax
  800713:	89 fa                	mov    %edi,%edx
  800715:	f7 d8                	neg    %eax
  800717:	83 d2 00             	adc    $0x0,%edx
  80071a:	f7 da                	neg    %edx
			}
			base = 10;
  80071c:	be 0a 00 00 00       	mov    $0xa,%esi
  800721:	eb 64                	jmp    800787 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800723:	89 ca                	mov    %ecx,%edx
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
  800728:	e8 42 fb ff ff       	call   80026f <getuint>
			base = 10;
  80072d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800732:	eb 53                	jmp    800787 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800734:	89 ca                	mov    %ecx,%edx
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	e8 31 fb ff ff       	call   80026f <getuint>
    			base = 8;
  80073e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800743:	eb 42                	jmp    800787 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800745:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800749:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800753:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800757:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8d 50 04             	lea    0x4(%eax),%edx
  800767:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076a:	8b 00                	mov    (%eax),%eax
  80076c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800771:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800776:	eb 0f                	jmp    800787 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800778:	89 ca                	mov    %ecx,%edx
  80077a:	8d 45 14             	lea    0x14(%ebp),%eax
  80077d:	e8 ed fa ff ff       	call   80026f <getuint>
			base = 16;
  800782:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800787:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80078b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80078f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800792:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800796:	89 74 24 08          	mov    %esi,0x8(%esp)
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a1:	89 da                	mov    %ebx,%edx
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	e8 e9 f9 ff ff       	call   800194 <printnum>
			break;
  8007ab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007ae:	e9 5e fb ff ff       	jmp    800311 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b7:	89 14 24             	mov    %edx,(%esp)
  8007ba:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c0:	e9 4c fb ff ff       	jmp    800311 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d7:	0f 84 34 fb ff ff    	je     800311 <vprintfmt+0x23>
  8007dd:	83 ee 01             	sub    $0x1,%esi
  8007e0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x4ef>
  8007e6:	e9 26 fb ff ff       	jmp    800311 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	83 c4 5c             	add    $0x5c,%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 28             	sub    $0x28,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 30                	je     800844 <vsnprintf+0x51>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 2c                	jle    800844 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081f:	8b 45 10             	mov    0x10(%ebp),%eax
  800822:	89 44 24 08          	mov    %eax,0x8(%esp)
  800826:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082d:	c7 04 24 a9 02 80 00 	movl   $0x8002a9,(%esp)
  800834:	e8 b5 fa ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800839:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800842:	eb 05                	jmp    800849 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800844:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800851:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800854:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800858:	8b 45 10             	mov    0x10(%ebp),%eax
  80085b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800862:	89 44 24 04          	mov    %eax,0x4(%esp)
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	89 04 24             	mov    %eax,(%esp)
  80086c:	e8 82 ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800871:	c9                   	leave  
  800872:	c3                   	ret    
	...

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	80 3a 00             	cmpb   $0x0,(%edx)
  80088e:	74 09                	je     800899 <strlen+0x19>
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
		n++;
	return n;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 1a                	je     8008c8 <strnlen+0x2d>
  8008ae:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008b1:	74 15                	je     8008c8 <strnlen+0x2d>
  8008b3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008b8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ba:	39 ca                	cmp    %ecx,%edx
  8008bc:	74 0a                	je     8008c8 <strnlen+0x2d>
  8008be:	83 c2 01             	add    $0x1,%edx
  8008c1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008c6:	75 f0                	jne    8008b8 <strnlen+0x1d>
		n++;
	return n;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008da:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008de:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	84 c9                	test   %cl,%cl
  8008e6:	75 f2                	jne    8008da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f5:	89 1c 24             	mov    %ebx,(%esp)
  8008f8:	e8 83 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800900:	89 54 24 04          	mov    %edx,0x4(%esp)
  800904:	01 d8                	add    %ebx,%eax
  800906:	89 04 24             	mov    %eax,(%esp)
  800909:	e8 bd ff ff ff       	call   8008cb <strcpy>
	return dst;
}
  80090e:	89 d8                	mov    %ebx,%eax
  800910:	83 c4 08             	add    $0x8,%esp
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800924:	85 f6                	test   %esi,%esi
  800926:	74 18                	je     800940 <strncpy+0x2a>
  800928:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80092d:	0f b6 1a             	movzbl (%edx),%ebx
  800930:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800933:	80 3a 01             	cmpb   $0x1,(%edx)
  800936:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	39 f1                	cmp    %esi,%ecx
  80093e:	75 ed                	jne    80092d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800950:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800953:	89 f8                	mov    %edi,%eax
  800955:	85 f6                	test   %esi,%esi
  800957:	74 2b                	je     800984 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800959:	83 fe 01             	cmp    $0x1,%esi
  80095c:	74 23                	je     800981 <strlcpy+0x3d>
  80095e:	0f b6 0b             	movzbl (%ebx),%ecx
  800961:	84 c9                	test   %cl,%cl
  800963:	74 1c                	je     800981 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800965:	83 ee 02             	sub    $0x2,%esi
  800968:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096d:	88 08                	mov    %cl,(%eax)
  80096f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800972:	39 f2                	cmp    %esi,%edx
  800974:	74 0b                	je     800981 <strlcpy+0x3d>
  800976:	83 c2 01             	add    $0x1,%edx
  800979:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80097d:	84 c9                	test   %cl,%cl
  80097f:	75 ec                	jne    80096d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800981:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800984:	29 f8                	sub    %edi,%eax
}
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800994:	0f b6 01             	movzbl (%ecx),%eax
  800997:	84 c0                	test   %al,%al
  800999:	74 16                	je     8009b1 <strcmp+0x26>
  80099b:	3a 02                	cmp    (%edx),%al
  80099d:	75 12                	jne    8009b1 <strcmp+0x26>
		p++, q++;
  80099f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8009a6:	84 c0                	test   %al,%al
  8009a8:	74 07                	je     8009b1 <strcmp+0x26>
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	3a 02                	cmp    (%edx),%al
  8009af:	74 ee                	je     80099f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b1:	0f b6 c0             	movzbl %al,%eax
  8009b4:	0f b6 12             	movzbl (%edx),%edx
  8009b7:	29 d0                	sub    %edx,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cd:	85 d2                	test   %edx,%edx
  8009cf:	74 28                	je     8009f9 <strncmp+0x3e>
  8009d1:	0f b6 01             	movzbl (%ecx),%eax
  8009d4:	84 c0                	test   %al,%al
  8009d6:	74 24                	je     8009fc <strncmp+0x41>
  8009d8:	3a 03                	cmp    (%ebx),%al
  8009da:	75 20                	jne    8009fc <strncmp+0x41>
  8009dc:	83 ea 01             	sub    $0x1,%edx
  8009df:	74 13                	je     8009f4 <strncmp+0x39>
		n--, p++, q++;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e7:	0f b6 01             	movzbl (%ecx),%eax
  8009ea:	84 c0                	test   %al,%al
  8009ec:	74 0e                	je     8009fc <strncmp+0x41>
  8009ee:	3a 03                	cmp    (%ebx),%al
  8009f0:	74 ea                	je     8009dc <strncmp+0x21>
  8009f2:	eb 08                	jmp    8009fc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fc:	0f b6 01             	movzbl (%ecx),%eax
  8009ff:	0f b6 13             	movzbl (%ebx),%edx
  800a02:	29 d0                	sub    %edx,%eax
  800a04:	eb f3                	jmp    8009f9 <strncmp+0x3e>

00800a06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	84 d2                	test   %dl,%dl
  800a15:	74 1c                	je     800a33 <strchr+0x2d>
		if (*s == c)
  800a17:	38 ca                	cmp    %cl,%dl
  800a19:	75 09                	jne    800a24 <strchr+0x1e>
  800a1b:	eb 1b                	jmp    800a38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a20:	38 ca                	cmp    %cl,%dl
  800a22:	74 14                	je     800a38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a24:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	75 f1                	jne    800a1d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb 05                	jmp    800a38 <strchr+0x32>
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a44:	0f b6 10             	movzbl (%eax),%edx
  800a47:	84 d2                	test   %dl,%dl
  800a49:	74 14                	je     800a5f <strfind+0x25>
		if (*s == c)
  800a4b:	38 ca                	cmp    %cl,%dl
  800a4d:	75 06                	jne    800a55 <strfind+0x1b>
  800a4f:	eb 0e                	jmp    800a5f <strfind+0x25>
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 0a                	je     800a5f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	75 f2                	jne    800a51 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	74 30                	je     800aad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a83:	75 25                	jne    800aaa <memset+0x49>
  800a85:	f6 c1 03             	test   $0x3,%cl
  800a88:	75 20                	jne    800aaa <memset+0x49>
		c &= 0xFF;
  800a8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	c1 e3 08             	shl    $0x8,%ebx
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	c1 e6 18             	shl    $0x18,%esi
  800a97:	89 d0                	mov    %edx,%eax
  800a99:	c1 e0 10             	shl    $0x10,%eax
  800a9c:	09 f0                	or     %esi,%eax
  800a9e:	09 d0                	or     %edx,%eax
  800aa0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aa5:	fc                   	cld    
  800aa6:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa8:	eb 03                	jmp    800aad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aaa:	fc                   	cld    
  800aab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aad:	89 f8                	mov    %edi,%eax
  800aaf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ab2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ab5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ab8:	89 ec                	mov    %ebp,%esp
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 08             	sub    $0x8,%esp
  800ac2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ac5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ace:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad1:	39 c6                	cmp    %eax,%esi
  800ad3:	73 36                	jae    800b0b <memmove+0x4f>
  800ad5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad8:	39 d0                	cmp    %edx,%eax
  800ada:	73 2f                	jae    800b0b <memmove+0x4f>
		s += n;
		d += n;
  800adc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adf:	f6 c2 03             	test   $0x3,%dl
  800ae2:	75 1b                	jne    800aff <memmove+0x43>
  800ae4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aea:	75 13                	jne    800aff <memmove+0x43>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 0e                	jne    800aff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af1:	83 ef 04             	sub    $0x4,%edi
  800af4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800afa:	fd                   	std    
  800afb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afd:	eb 09                	jmp    800b08 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aff:	83 ef 01             	sub    $0x1,%edi
  800b02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b05:	fd                   	std    
  800b06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b08:	fc                   	cld    
  800b09:	eb 20                	jmp    800b2b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b11:	75 13                	jne    800b26 <memmove+0x6a>
  800b13:	a8 03                	test   $0x3,%al
  800b15:	75 0f                	jne    800b26 <memmove+0x6a>
  800b17:	f6 c1 03             	test   $0x3,%cl
  800b1a:	75 0a                	jne    800b26 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b1c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b1f:	89 c7                	mov    %eax,%edi
  800b21:	fc                   	cld    
  800b22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b24:	eb 05                	jmp    800b2b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b26:	89 c7                	mov    %eax,%edi
  800b28:	fc                   	cld    
  800b29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b31:	89 ec                	mov    %ebp,%esp
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	89 04 24             	mov    %eax,(%esp)
  800b4f:	e8 68 ff ff ff       	call   800abc <memmove>
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b62:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6a:	85 ff                	test   %edi,%edi
  800b6c:	74 37                	je     800ba5 <memcmp+0x4f>
		if (*s1 != *s2)
  800b6e:	0f b6 03             	movzbl (%ebx),%eax
  800b71:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b74:	83 ef 01             	sub    $0x1,%edi
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b7c:	38 c8                	cmp    %cl,%al
  800b7e:	74 1c                	je     800b9c <memcmp+0x46>
  800b80:	eb 10                	jmp    800b92 <memcmp+0x3c>
  800b82:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b8e:	38 c8                	cmp    %cl,%al
  800b90:	74 0a                	je     800b9c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b92:	0f b6 c0             	movzbl %al,%eax
  800b95:	0f b6 c9             	movzbl %cl,%ecx
  800b98:	29 c8                	sub    %ecx,%eax
  800b9a:	eb 09                	jmp    800ba5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9c:	39 fa                	cmp    %edi,%edx
  800b9e:	75 e2                	jne    800b82 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bb0:	89 c2                	mov    %eax,%edx
  800bb2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb5:	39 d0                	cmp    %edx,%eax
  800bb7:	73 19                	jae    800bd2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bbd:	38 08                	cmp    %cl,(%eax)
  800bbf:	75 06                	jne    800bc7 <memfind+0x1d>
  800bc1:	eb 0f                	jmp    800bd2 <memfind+0x28>
  800bc3:	38 08                	cmp    %cl,(%eax)
  800bc5:	74 0b                	je     800bd2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	39 d0                	cmp    %edx,%eax
  800bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bd0:	75 f1                	jne    800bc3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be0:	0f b6 02             	movzbl (%edx),%eax
  800be3:	3c 20                	cmp    $0x20,%al
  800be5:	74 04                	je     800beb <strtol+0x17>
  800be7:	3c 09                	cmp    $0x9,%al
  800be9:	75 0e                	jne    800bf9 <strtol+0x25>
		s++;
  800beb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bee:	0f b6 02             	movzbl (%edx),%eax
  800bf1:	3c 20                	cmp    $0x20,%al
  800bf3:	74 f6                	je     800beb <strtol+0x17>
  800bf5:	3c 09                	cmp    $0x9,%al
  800bf7:	74 f2                	je     800beb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf9:	3c 2b                	cmp    $0x2b,%al
  800bfb:	75 0a                	jne    800c07 <strtol+0x33>
		s++;
  800bfd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c00:	bf 00 00 00 00       	mov    $0x0,%edi
  800c05:	eb 10                	jmp    800c17 <strtol+0x43>
  800c07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0c:	3c 2d                	cmp    $0x2d,%al
  800c0e:	75 07                	jne    800c17 <strtol+0x43>
		s++, neg = 1;
  800c10:	83 c2 01             	add    $0x1,%edx
  800c13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c17:	85 db                	test   %ebx,%ebx
  800c19:	0f 94 c0             	sete   %al
  800c1c:	74 05                	je     800c23 <strtol+0x4f>
  800c1e:	83 fb 10             	cmp    $0x10,%ebx
  800c21:	75 15                	jne    800c38 <strtol+0x64>
  800c23:	80 3a 30             	cmpb   $0x30,(%edx)
  800c26:	75 10                	jne    800c38 <strtol+0x64>
  800c28:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c2c:	75 0a                	jne    800c38 <strtol+0x64>
		s += 2, base = 16;
  800c2e:	83 c2 02             	add    $0x2,%edx
  800c31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c36:	eb 13                	jmp    800c4b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c38:	84 c0                	test   %al,%al
  800c3a:	74 0f                	je     800c4b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c41:	80 3a 30             	cmpb   $0x30,(%edx)
  800c44:	75 05                	jne    800c4b <strtol+0x77>
		s++, base = 8;
  800c46:	83 c2 01             	add    $0x1,%edx
  800c49:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c52:	0f b6 0a             	movzbl (%edx),%ecx
  800c55:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c58:	80 fb 09             	cmp    $0x9,%bl
  800c5b:	77 08                	ja     800c65 <strtol+0x91>
			dig = *s - '0';
  800c5d:	0f be c9             	movsbl %cl,%ecx
  800c60:	83 e9 30             	sub    $0x30,%ecx
  800c63:	eb 1e                	jmp    800c83 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c65:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c68:	80 fb 19             	cmp    $0x19,%bl
  800c6b:	77 08                	ja     800c75 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c6d:	0f be c9             	movsbl %cl,%ecx
  800c70:	83 e9 57             	sub    $0x57,%ecx
  800c73:	eb 0e                	jmp    800c83 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c75:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c78:	80 fb 19             	cmp    $0x19,%bl
  800c7b:	77 14                	ja     800c91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c7d:	0f be c9             	movsbl %cl,%ecx
  800c80:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c83:	39 f1                	cmp    %esi,%ecx
  800c85:	7d 0e                	jge    800c95 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c87:	83 c2 01             	add    $0x1,%edx
  800c8a:	0f af c6             	imul   %esi,%eax
  800c8d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c8f:	eb c1                	jmp    800c52 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c91:	89 c1                	mov    %eax,%ecx
  800c93:	eb 02                	jmp    800c97 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c95:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9b:	74 05                	je     800ca2 <strtol+0xce>
		*endptr = (char *) s;
  800c9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca2:	89 ca                	mov    %ecx,%edx
  800ca4:	f7 da                	neg    %edx
  800ca6:	85 ff                	test   %edi,%edi
  800ca8:	0f 45 c2             	cmovne %edx,%eax
}
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	89 c3                	mov    %eax,%ebx
  800ccc:	89 c7                	mov    %eax,%edi
  800cce:	89 c6                	mov    %eax,%esi
  800cd0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cdb:	89 ec                	mov    %ebp,%esp
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ceb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf8:	89 d1                	mov    %edx,%ecx
  800cfa:	89 d3                	mov    %edx,%ebx
  800cfc:	89 d7                	mov    %edx,%edi
  800cfe:	89 d6                	mov    %edx,%esi
  800d00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0b:	89 ec                	mov    %ebp,%esp
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 38             	sub    $0x38,%esp
  800d15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d23:	b8 03 00 00 00       	mov    $0x3,%eax
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	89 cb                	mov    %ecx,%ebx
  800d2d:	89 cf                	mov    %ecx,%edi
  800d2f:	89 ce                	mov    %ecx,%esi
  800d31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 28                	jle    800d5f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800d5a:	e8 61 11 00 00       	call   801ec0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d68:	89 ec                	mov    %ebp,%esp
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 02 00 00 00       	mov    $0x2,%eax
  800d85:	89 d1                	mov    %edx,%ecx
  800d87:	89 d3                	mov    %edx,%ebx
  800d89:	89 d7                	mov    %edx,%edi
  800d8b:	89 d6                	mov    %edx,%esi
  800d8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d98:	89 ec                	mov    %ebp,%esp
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_yield>:

void
sys_yield(void)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	89 d3                	mov    %edx,%ebx
  800db9:	89 d7                	mov    %edx,%edi
  800dbb:	89 d6                	mov    %edx,%esi
  800dbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc8:	89 ec                	mov    %ebp,%esp
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 38             	sub    $0x38,%esp
  800dd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	be 00 00 00 00       	mov    $0x0,%esi
  800de0:	b8 04 00 00 00       	mov    $0x4,%eax
  800de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 f7                	mov    %esi,%edi
  800df0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df2:	85 c0                	test   %eax,%eax
  800df4:	7e 28                	jle    800e1e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e01:	00 
  800e02:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e09:	00 
  800e0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e11:	00 
  800e12:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e19:	e8 a2 10 00 00       	call   801ec0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e1e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e21:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e24:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e27:	89 ec                	mov    %ebp,%esp
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	83 ec 38             	sub    $0x38,%esp
  800e31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e37:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e3f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e50:	85 c0                	test   %eax,%eax
  800e52:	7e 28                	jle    800e7c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e58:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e5f:	00 
  800e60:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e67:	00 
  800e68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6f:	00 
  800e70:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e77:	e8 44 10 00 00       	call   801ec0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e7c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e82:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e85:	89 ec                	mov    %ebp,%esp
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 38             	sub    $0x38,%esp
  800e8f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e95:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	89 df                	mov    %ebx,%edi
  800eaa:	89 de                	mov    %ebx,%esi
  800eac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	7e 28                	jle    800eda <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ebd:	00 
  800ebe:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800ec5:	00 
  800ec6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecd:	00 
  800ece:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800ed5:	e8 e6 0f 00 00       	call   801ec0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800edd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee3:	89 ec                	mov    %ebp,%esp
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 38             	sub    $0x38,%esp
  800eed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 08 00 00 00       	mov    $0x8,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f33:	e8 88 0f 00 00       	call   801ec0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f38:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f41:	89 ec                	mov    %ebp,%esp
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 38             	sub    $0x38,%esp
  800f4b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f51:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f59:	b8 09 00 00 00       	mov    $0x9,%eax
  800f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	89 df                	mov    %ebx,%edi
  800f66:	89 de                	mov    %ebx,%esi
  800f68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 28                	jle    800f96 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f72:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f79:	00 
  800f7a:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f89:	00 
  800f8a:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f91:	e8 2a 0f 00 00       	call   801ec0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9f:	89 ec                	mov    %ebp,%esp
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 38             	sub    $0x38,%esp
  800fa9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800faf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	89 df                	mov    %ebx,%edi
  800fc4:	89 de                	mov    %ebx,%esi
  800fc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	7e 28                	jle    800ff4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe7:	00 
  800fe8:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800fef:	e8 cc 0e 00 00       	call   801ec0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ff4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffd:	89 ec                	mov    %ebp,%esp
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801010:	be 00 00 00 00       	mov    $0x0,%esi
  801015:	b8 0c 00 00 00       	mov    $0xc,%eax
  80101a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80101d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801028:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80102b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80102e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801031:	89 ec                	mov    %ebp,%esp
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 38             	sub    $0x38,%esp
  80103b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80103e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801041:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801044:	b9 00 00 00 00       	mov    $0x0,%ecx
  801049:	b8 0d 00 00 00       	mov    $0xd,%eax
  80104e:	8b 55 08             	mov    0x8(%ebp),%edx
  801051:	89 cb                	mov    %ecx,%ebx
  801053:	89 cf                	mov    %ecx,%edi
  801055:	89 ce                	mov    %ecx,%esi
  801057:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	7e 28                	jle    801085 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  801080:	e8 3b 0e 00 00       	call   801ec0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801085:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801088:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80108b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108e:	89 ec                	mov    %ebp,%esp
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80109b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80109e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ae:	89 cb                	mov    %ecx,%ebx
  8010b0:	89 cf                	mov    %ecx,%edi
  8010b2:	89 ce                	mov    %ecx,%esi
  8010b4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8010b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010bf:	89 ec                	mov    %ebp,%esp
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    
	...

008010d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010db:	c1 e8 0c             	shr    $0xc,%eax
}
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	89 04 24             	mov    %eax,(%esp)
  8010ec:	e8 df ff ff ff       	call   8010d0 <fd2num>
  8010f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	53                   	push   %ebx
  8010ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801102:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801107:	a8 01                	test   $0x1,%al
  801109:	74 34                	je     80113f <fd_alloc+0x44>
  80110b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801110:	a8 01                	test   $0x1,%al
  801112:	74 32                	je     801146 <fd_alloc+0x4b>
  801114:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801119:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	c1 ea 16             	shr    $0x16,%edx
  801120:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801127:	f6 c2 01             	test   $0x1,%dl
  80112a:	74 1f                	je     80114b <fd_alloc+0x50>
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	c1 ea 0c             	shr    $0xc,%edx
  801131:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	75 17                	jne    801154 <fd_alloc+0x59>
  80113d:	eb 0c                	jmp    80114b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80113f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801144:	eb 05                	jmp    80114b <fd_alloc+0x50>
  801146:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80114b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80114d:	b8 00 00 00 00       	mov    $0x0,%eax
  801152:	eb 17                	jmp    80116b <fd_alloc+0x70>
  801154:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801159:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80115e:	75 b9                	jne    801119 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801160:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801166:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116b:	5b                   	pop    %ebx
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801174:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801179:	83 fa 1f             	cmp    $0x1f,%edx
  80117c:	77 3f                	ja     8011bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801184:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801187:	89 d0                	mov    %edx,%eax
  801189:	c1 e8 16             	shr    $0x16,%eax
  80118c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801193:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801198:	f6 c1 01             	test   $0x1,%cl
  80119b:	74 20                	je     8011bd <fd_lookup+0x4f>
  80119d:	89 d0                	mov    %edx,%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
  8011a2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ae:	f6 c1 01             	test   $0x1,%cl
  8011b1:	74 0a                	je     8011bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8011b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 14             	sub    $0x14,%esp
  8011c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011d1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8011d7:	75 17                	jne    8011f0 <dev_lookup+0x31>
  8011d9:	eb 07                	jmp    8011e2 <dev_lookup+0x23>
  8011db:	39 0a                	cmp    %ecx,(%edx)
  8011dd:	75 11                	jne    8011f0 <dev_lookup+0x31>
  8011df:	90                   	nop
  8011e0:	eb 05                	jmp    8011e7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e2:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011e7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	eb 35                	jmp    801225 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f0:	83 c0 01             	add    $0x1,%eax
  8011f3:	8b 14 85 08 27 80 00 	mov    0x802708(,%eax,4),%edx
  8011fa:	85 d2                	test   %edx,%edx
  8011fc:	75 dd                	jne    8011db <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011fe:	a1 08 40 80 00       	mov    0x804008,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
  801206:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80120a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120e:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  801215:	e8 5d ef ff ff       	call   800177 <cprintf>
	*dev = 0;
  80121a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801220:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801225:	83 c4 14             	add    $0x14,%esp
  801228:	5b                   	pop    %ebx
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 38             	sub    $0x38,%esp
  801231:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801234:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801237:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80123a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801241:	89 3c 24             	mov    %edi,(%esp)
  801244:	e8 87 fe ff ff       	call   8010d0 <fd2num>
  801249:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80124c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801250:	89 04 24             	mov    %eax,(%esp)
  801253:	e8 16 ff ff ff       	call   80116e <fd_lookup>
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 05                	js     801263 <fd_close+0x38>
	    || fd != fd2)
  80125e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801261:	74 0e                	je     801271 <fd_close+0x46>
		return (must_exist ? r : 0);
  801263:	89 f0                	mov    %esi,%eax
  801265:	84 c0                	test   %al,%al
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
  80126c:	0f 44 d8             	cmove  %eax,%ebx
  80126f:	eb 3d                	jmp    8012ae <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801271:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801274:	89 44 24 04          	mov    %eax,0x4(%esp)
  801278:	8b 07                	mov    (%edi),%eax
  80127a:	89 04 24             	mov    %eax,(%esp)
  80127d:	e8 3d ff ff ff       	call   8011bf <dev_lookup>
  801282:	89 c3                	mov    %eax,%ebx
  801284:	85 c0                	test   %eax,%eax
  801286:	78 16                	js     80129e <fd_close+0x73>
		if (dev->dev_close)
  801288:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80128e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801293:	85 c0                	test   %eax,%eax
  801295:	74 07                	je     80129e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801297:	89 3c 24             	mov    %edi,(%esp)
  80129a:	ff d0                	call   *%eax
  80129c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80129e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a9:	e8 db fb ff ff       	call   800e89 <sys_page_unmap>
	return r;
}
  8012ae:	89 d8                	mov    %ebx,%eax
  8012b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012b9:	89 ec                	mov    %ebp,%esp
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	89 04 24             	mov    %eax,(%esp)
  8012d0:	e8 99 fe ff ff       	call   80116e <fd_lookup>
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 13                	js     8012ec <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012e0:	00 
  8012e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e4:	89 04 24             	mov    %eax,(%esp)
  8012e7:	e8 3f ff ff ff       	call   80122b <fd_close>
}
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <close_all>:

void
close_all(void)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012fa:	89 1c 24             	mov    %ebx,(%esp)
  8012fd:	e8 bb ff ff ff       	call   8012bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801302:	83 c3 01             	add    $0x1,%ebx
  801305:	83 fb 20             	cmp    $0x20,%ebx
  801308:	75 f0                	jne    8012fa <close_all+0xc>
		close(i);
}
  80130a:	83 c4 14             	add    $0x14,%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 58             	sub    $0x58,%esp
  801316:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801319:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80131c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80131f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801322:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801325:	89 44 24 04          	mov    %eax,0x4(%esp)
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	e8 3a fe ff ff       	call   80116e <fd_lookup>
  801334:	89 c3                	mov    %eax,%ebx
  801336:	85 c0                	test   %eax,%eax
  801338:	0f 88 e1 00 00 00    	js     80141f <dup+0x10f>
		return r;
	close(newfdnum);
  80133e:	89 3c 24             	mov    %edi,(%esp)
  801341:	e8 77 ff ff ff       	call   8012bd <close>

	newfd = INDEX2FD(newfdnum);
  801346:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80134c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80134f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801352:	89 04 24             	mov    %eax,(%esp)
  801355:	e8 86 fd ff ff       	call   8010e0 <fd2data>
  80135a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80135c:	89 34 24             	mov    %esi,(%esp)
  80135f:	e8 7c fd ff ff       	call   8010e0 <fd2data>
  801364:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801367:	89 d8                	mov    %ebx,%eax
  801369:	c1 e8 16             	shr    $0x16,%eax
  80136c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801373:	a8 01                	test   $0x1,%al
  801375:	74 46                	je     8013bd <dup+0xad>
  801377:	89 d8                	mov    %ebx,%eax
  801379:	c1 e8 0c             	shr    $0xc,%eax
  80137c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801383:	f6 c2 01             	test   $0x1,%dl
  801386:	74 35                	je     8013bd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801388:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138f:	25 07 0e 00 00       	and    $0xe07,%eax
  801394:	89 44 24 10          	mov    %eax,0x10(%esp)
  801398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80139b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013a6:	00 
  8013a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b2:	e8 74 fa ff ff       	call   800e2b <sys_page_map>
  8013b7:	89 c3                	mov    %eax,%ebx
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 3b                	js     8013f8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	c1 ea 0c             	shr    $0xc,%edx
  8013c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013e1:	00 
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ed:	e8 39 fa ff ff       	call   800e2b <sys_page_map>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	79 25                	jns    80141d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801403:	e8 81 fa ff ff       	call   800e89 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80140b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801416:	e8 6e fa ff ff       	call   800e89 <sys_page_unmap>
	return r;
  80141b:	eb 02                	jmp    80141f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80141d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80141f:	89 d8                	mov    %ebx,%eax
  801421:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801424:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801427:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80142a:	89 ec                	mov    %ebp,%esp
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	53                   	push   %ebx
  801432:	83 ec 24             	sub    $0x24,%esp
  801435:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801438:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143f:	89 1c 24             	mov    %ebx,(%esp)
  801442:	e8 27 fd ff ff       	call   80116e <fd_lookup>
  801447:	85 c0                	test   %eax,%eax
  801449:	78 6d                	js     8014b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801455:	8b 00                	mov    (%eax),%eax
  801457:	89 04 24             	mov    %eax,(%esp)
  80145a:	e8 60 fd ff ff       	call   8011bf <dev_lookup>
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 55                	js     8014b8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801463:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801466:	8b 50 08             	mov    0x8(%eax),%edx
  801469:	83 e2 03             	and    $0x3,%edx
  80146c:	83 fa 01             	cmp    $0x1,%edx
  80146f:	75 23                	jne    801494 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801471:	a1 08 40 80 00       	mov    0x804008,%eax
  801476:	8b 40 48             	mov    0x48(%eax),%eax
  801479:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	c7 04 24 cd 26 80 00 	movl   $0x8026cd,(%esp)
  801488:	e8 ea ec ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  80148d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801492:	eb 24                	jmp    8014b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801494:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801497:	8b 52 08             	mov    0x8(%edx),%edx
  80149a:	85 d2                	test   %edx,%edx
  80149c:	74 15                	je     8014b3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80149e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	ff d2                	call   *%edx
  8014b1:	eb 05                	jmp    8014b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8014b8:	83 c4 24             	add    $0x24,%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5d                   	pop    %ebp
  8014bd:	c3                   	ret    

008014be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 1c             	sub    $0x1c,%esp
  8014c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d2:	85 f6                	test   %esi,%esi
  8014d4:	74 30                	je     801506 <readn+0x48>
  8014d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014db:	89 f2                	mov    %esi,%edx
  8014dd:	29 c2                	sub    %eax,%edx
  8014df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014e3:	03 45 0c             	add    0xc(%ebp),%eax
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	89 3c 24             	mov    %edi,(%esp)
  8014ed:	e8 3c ff ff ff       	call   80142e <read>
		if (m < 0)
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 10                	js     801506 <readn+0x48>
			return m;
		if (m == 0)
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	74 0a                	je     801504 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fa:	01 c3                	add    %eax,%ebx
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	39 f3                	cmp    %esi,%ebx
  801500:	72 d9                	jb     8014db <readn+0x1d>
  801502:	eb 02                	jmp    801506 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801504:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801506:	83 c4 1c             	add    $0x1c,%esp
  801509:	5b                   	pop    %ebx
  80150a:	5e                   	pop    %esi
  80150b:	5f                   	pop    %edi
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    

0080150e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	53                   	push   %ebx
  801512:	83 ec 24             	sub    $0x24,%esp
  801515:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801518:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151f:	89 1c 24             	mov    %ebx,(%esp)
  801522:	e8 47 fc ff ff       	call   80116e <fd_lookup>
  801527:	85 c0                	test   %eax,%eax
  801529:	78 68                	js     801593 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	8b 00                	mov    (%eax),%eax
  801537:	89 04 24             	mov    %eax,(%esp)
  80153a:	e8 80 fc ff ff       	call   8011bf <dev_lookup>
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 50                	js     801593 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154a:	75 23                	jne    80156f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80154c:	a1 08 40 80 00       	mov    0x804008,%eax
  801551:	8b 40 48             	mov    0x48(%eax),%eax
  801554:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155c:	c7 04 24 e9 26 80 00 	movl   $0x8026e9,(%esp)
  801563:	e8 0f ec ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  801568:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156d:	eb 24                	jmp    801593 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80156f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801572:	8b 52 0c             	mov    0xc(%edx),%edx
  801575:	85 d2                	test   %edx,%edx
  801577:	74 15                	je     80158e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801579:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80157c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801580:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801583:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801587:	89 04 24             	mov    %eax,(%esp)
  80158a:	ff d2                	call   *%edx
  80158c:	eb 05                	jmp    801593 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80158e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801593:	83 c4 24             	add    $0x24,%esp
  801596:	5b                   	pop    %ebx
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    

00801599 <seek>:

int
seek(int fdnum, off_t offset)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a9:	89 04 24             	mov    %eax,(%esp)
  8015ac:	e8 bd fb ff ff       	call   80116e <fd_lookup>
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 0e                	js     8015c3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 24             	sub    $0x24,%esp
  8015cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d6:	89 1c 24             	mov    %ebx,(%esp)
  8015d9:	e8 90 fb ff ff       	call   80116e <fd_lookup>
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 61                	js     801643 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ec:	8b 00                	mov    (%eax),%eax
  8015ee:	89 04 24             	mov    %eax,(%esp)
  8015f1:	e8 c9 fb ff ff       	call   8011bf <dev_lookup>
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 49                	js     801643 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801601:	75 23                	jne    801626 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801603:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801608:	8b 40 48             	mov    0x48(%eax),%eax
  80160b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80160f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801613:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  80161a:	e8 58 eb ff ff       	call   800177 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80161f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801624:	eb 1d                	jmp    801643 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801626:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801629:	8b 52 18             	mov    0x18(%edx),%edx
  80162c:	85 d2                	test   %edx,%edx
  80162e:	74 0e                	je     80163e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801630:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801633:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	ff d2                	call   *%edx
  80163c:	eb 05                	jmp    801643 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801643:	83 c4 24             	add    $0x24,%esp
  801646:	5b                   	pop    %ebx
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	53                   	push   %ebx
  80164d:	83 ec 24             	sub    $0x24,%esp
  801650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801653:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	89 04 24             	mov    %eax,(%esp)
  801660:	e8 09 fb ff ff       	call   80116e <fd_lookup>
  801665:	85 c0                	test   %eax,%eax
  801667:	78 52                	js     8016bb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801670:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801673:	8b 00                	mov    (%eax),%eax
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 42 fb ff ff       	call   8011bf <dev_lookup>
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 3a                	js     8016bb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801681:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801684:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801688:	74 2c                	je     8016b6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80168a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801694:	00 00 00 
	stat->st_isdir = 0;
  801697:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169e:	00 00 00 
	stat->st_dev = dev;
  8016a1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ae:	89 14 24             	mov    %edx,(%esp)
  8016b1:	ff 50 14             	call   *0x14(%eax)
  8016b4:	eb 05                	jmp    8016bb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016bb:	83 c4 24             	add    $0x24,%esp
  8016be:	5b                   	pop    %ebx
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 18             	sub    $0x18,%esp
  8016c7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016ca:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016d4:	00 
  8016d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d8:	89 04 24             	mov    %eax,(%esp)
  8016db:	e8 bc 01 00 00       	call   80189c <open>
  8016e0:	89 c3                	mov    %eax,%ebx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 1b                	js     801701 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ed:	89 1c 24             	mov    %ebx,(%esp)
  8016f0:	e8 54 ff ff ff       	call   801649 <fstat>
  8016f5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f7:	89 1c 24             	mov    %ebx,(%esp)
  8016fa:	e8 be fb ff ff       	call   8012bd <close>
	return r;
  8016ff:	89 f3                	mov    %esi,%ebx
}
  801701:	89 d8                	mov    %ebx,%eax
  801703:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801706:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801709:	89 ec                	mov    %ebp,%esp
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    
  80170d:	00 00                	add    %al,(%eax)
	...

00801710 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 18             	sub    $0x18,%esp
  801716:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801719:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801720:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801727:	75 11                	jne    80173a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801729:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801730:	e8 b4 08 00 00       	call   801fe9 <ipc_find_env>
  801735:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80173a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801741:	00 
  801742:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801749:	00 
  80174a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174e:	a1 00 40 80 00       	mov    0x804000,%eax
  801753:	89 04 24             	mov    %eax,(%esp)
  801756:	e8 23 08 00 00       	call   801f7e <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80175b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801762:	00 
  801763:	89 74 24 04          	mov    %esi,0x4(%esp)
  801767:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176e:	e8 a5 07 00 00       	call   801f18 <ipc_recv>
}
  801773:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801776:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801779:	89 ec                	mov    %ebp,%esp
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	53                   	push   %ebx
  801781:	83 ec 14             	sub    $0x14,%esp
  801784:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 40 0c             	mov    0xc(%eax),%eax
  80178d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801792:	ba 00 00 00 00       	mov    $0x0,%edx
  801797:	b8 05 00 00 00       	mov    $0x5,%eax
  80179c:	e8 6f ff ff ff       	call   801710 <fsipc>
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 2b                	js     8017d0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017ac:	00 
  8017ad:	89 1c 24             	mov    %ebx,(%esp)
  8017b0:	e8 16 f1 ff ff       	call   8008cb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d0:	83 c4 14             	add    $0x14,%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f1:	e8 1a ff ff ff       	call   801710 <fsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 10             	sub    $0x10,%esp
  801800:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 40 0c             	mov    0xc(%eax),%eax
  801809:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 03 00 00 00       	mov    $0x3,%eax
  80181e:	e8 ed fe ff ff       	call   801710 <fsipc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 6a                	js     801893 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801829:	39 c6                	cmp    %eax,%esi
  80182b:	73 24                	jae    801851 <devfile_read+0x59>
  80182d:	c7 44 24 0c 18 27 80 	movl   $0x802718,0xc(%esp)
  801834:	00 
  801835:	c7 44 24 08 1f 27 80 	movl   $0x80271f,0x8(%esp)
  80183c:	00 
  80183d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801844:	00 
  801845:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  80184c:	e8 6f 06 00 00       	call   801ec0 <_panic>
	assert(r <= PGSIZE);
  801851:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801856:	7e 24                	jle    80187c <devfile_read+0x84>
  801858:	c7 44 24 0c 3f 27 80 	movl   $0x80273f,0xc(%esp)
  80185f:	00 
  801860:	c7 44 24 08 1f 27 80 	movl   $0x80271f,0x8(%esp)
  801867:	00 
  801868:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80186f:	00 
  801870:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  801877:	e8 44 06 00 00       	call   801ec0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80187c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801880:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801887:	00 
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 29 f2 ff ff       	call   800abc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801893:	89 d8                	mov    %ebx,%eax
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	5b                   	pop    %ebx
  801899:	5e                   	pop    %esi
  80189a:	5d                   	pop    %ebp
  80189b:	c3                   	ret    

0080189c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	83 ec 20             	sub    $0x20,%esp
  8018a4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018a7:	89 34 24             	mov    %esi,(%esp)
  8018aa:	e8 d1 ef ff ff       	call   800880 <strlen>
		return -E_BAD_PATH;
  8018af:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018b9:	7f 5e                	jg     801919 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018be:	89 04 24             	mov    %eax,(%esp)
  8018c1:	e8 35 f8 ff ff       	call   8010fb <fd_alloc>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 4d                	js     801919 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018d7:	e8 ef ef ff ff       	call   8008cb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018df:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ec:	e8 1f fe ff ff       	call   801710 <fsipc>
  8018f1:	89 c3                	mov    %eax,%ebx
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	79 15                	jns    80190c <open+0x70>
		fd_close(fd, 0);
  8018f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018fe:	00 
  8018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801902:	89 04 24             	mov    %eax,(%esp)
  801905:	e8 21 f9 ff ff       	call   80122b <fd_close>
		return r;
  80190a:	eb 0d                	jmp    801919 <open+0x7d>
	}

	return fd2num(fd);
  80190c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 b9 f7 ff ff       	call   8010d0 <fd2num>
  801917:	89 c3                	mov    %eax,%ebx
}
  801919:	89 d8                	mov    %ebx,%eax
  80191b:	83 c4 20             	add    $0x20,%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    
	...

00801930 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 18             	sub    $0x18,%esp
  801936:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801939:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80193c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	e8 96 f7 ff ff       	call   8010e0 <fd2data>
  80194a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80194c:	c7 44 24 04 4b 27 80 	movl   $0x80274b,0x4(%esp)
  801953:	00 
  801954:	89 34 24             	mov    %esi,(%esp)
  801957:	e8 6f ef ff ff       	call   8008cb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80195c:	8b 43 04             	mov    0x4(%ebx),%eax
  80195f:	2b 03                	sub    (%ebx),%eax
  801961:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801967:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80196e:	00 00 00 
	stat->st_dev = &devpipe;
  801971:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801978:	30 80 00 
	return 0;
}
  80197b:	b8 00 00 00 00       	mov    $0x0,%eax
  801980:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801983:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801986:	89 ec                	mov    %ebp,%esp
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 14             	sub    $0x14,%esp
  801991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801994:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801998:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199f:	e8 e5 f4 ff ff       	call   800e89 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019a4:	89 1c 24             	mov    %ebx,(%esp)
  8019a7:	e8 34 f7 ff ff       	call   8010e0 <fd2data>
  8019ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b7:	e8 cd f4 ff ff       	call   800e89 <sys_page_unmap>
}
  8019bc:	83 c4 14             	add    $0x14,%esp
  8019bf:	5b                   	pop    %ebx
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	57                   	push   %edi
  8019c6:	56                   	push   %esi
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 2c             	sub    $0x2c,%esp
  8019cb:	89 c7                	mov    %eax,%edi
  8019cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d0:	a1 08 40 80 00       	mov    0x804008,%eax
  8019d5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019d8:	89 3c 24             	mov    %edi,(%esp)
  8019db:	e8 54 06 00 00       	call   802034 <pageref>
  8019e0:	89 c6                	mov    %eax,%esi
  8019e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	e8 47 06 00 00       	call   802034 <pageref>
  8019ed:	39 c6                	cmp    %eax,%esi
  8019ef:	0f 94 c0             	sete   %al
  8019f2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019f5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019fb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019fe:	39 cb                	cmp    %ecx,%ebx
  801a00:	75 08                	jne    801a0a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a02:	83 c4 2c             	add    $0x2c,%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5f                   	pop    %edi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a0a:	83 f8 01             	cmp    $0x1,%eax
  801a0d:	75 c1                	jne    8019d0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a0f:	8b 52 58             	mov    0x58(%edx),%edx
  801a12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a16:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1e:	c7 04 24 52 27 80 00 	movl   $0x802752,(%esp)
  801a25:	e8 4d e7 ff ff       	call   800177 <cprintf>
  801a2a:	eb a4                	jmp    8019d0 <_pipeisclosed+0xe>

00801a2c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	57                   	push   %edi
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	83 ec 2c             	sub    $0x2c,%esp
  801a35:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a38:	89 34 24             	mov    %esi,(%esp)
  801a3b:	e8 a0 f6 ff ff       	call   8010e0 <fd2data>
  801a40:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a42:	bf 00 00 00 00       	mov    $0x0,%edi
  801a47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a4b:	75 50                	jne    801a9d <devpipe_write+0x71>
  801a4d:	eb 5c                	jmp    801aab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a4f:	89 da                	mov    %ebx,%edx
  801a51:	89 f0                	mov    %esi,%eax
  801a53:	e8 6a ff ff ff       	call   8019c2 <_pipeisclosed>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	75 53                	jne    801aaf <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a5c:	e8 3b f3 ff ff       	call   800d9c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a61:	8b 43 04             	mov    0x4(%ebx),%eax
  801a64:	8b 13                	mov    (%ebx),%edx
  801a66:	83 c2 20             	add    $0x20,%edx
  801a69:	39 d0                	cmp    %edx,%eax
  801a6b:	73 e2                	jae    801a4f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a70:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801a74:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801a77:	89 c2                	mov    %eax,%edx
  801a79:	c1 fa 1f             	sar    $0x1f,%edx
  801a7c:	c1 ea 1b             	shr    $0x1b,%edx
  801a7f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801a82:	83 e1 1f             	and    $0x1f,%ecx
  801a85:	29 d1                	sub    %edx,%ecx
  801a87:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801a8b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801a8f:	83 c0 01             	add    $0x1,%eax
  801a92:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a95:	83 c7 01             	add    $0x1,%edi
  801a98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9b:	74 0e                	je     801aab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9d:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa0:	8b 13                	mov    (%ebx),%edx
  801aa2:	83 c2 20             	add    $0x20,%edx
  801aa5:	39 d0                	cmp    %edx,%eax
  801aa7:	73 a6                	jae    801a4f <devpipe_write+0x23>
  801aa9:	eb c2                	jmp    801a6d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aab:	89 f8                	mov    %edi,%eax
  801aad:	eb 05                	jmp    801ab4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ab4:	83 c4 2c             	add    $0x2c,%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 28             	sub    $0x28,%esp
  801ac2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ac5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ac8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801acb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ace:	89 3c 24             	mov    %edi,(%esp)
  801ad1:	e8 0a f6 ff ff       	call   8010e0 <fd2data>
  801ad6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad8:	be 00 00 00 00       	mov    $0x0,%esi
  801add:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ae1:	75 47                	jne    801b2a <devpipe_read+0x6e>
  801ae3:	eb 52                	jmp    801b37 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ae5:	89 f0                	mov    %esi,%eax
  801ae7:	eb 5e                	jmp    801b47 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ae9:	89 da                	mov    %ebx,%edx
  801aeb:	89 f8                	mov    %edi,%eax
  801aed:	8d 76 00             	lea    0x0(%esi),%esi
  801af0:	e8 cd fe ff ff       	call   8019c2 <_pipeisclosed>
  801af5:	85 c0                	test   %eax,%eax
  801af7:	75 49                	jne    801b42 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801af9:	e8 9e f2 ff ff       	call   800d9c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801afe:	8b 03                	mov    (%ebx),%eax
  801b00:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b03:	74 e4                	je     801ae9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	c1 fa 1f             	sar    $0x1f,%edx
  801b0a:	c1 ea 1b             	shr    $0x1b,%edx
  801b0d:	01 d0                	add    %edx,%eax
  801b0f:	83 e0 1f             	and    $0x1f,%eax
  801b12:	29 d0                	sub    %edx,%eax
  801b14:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b19:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b1f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	83 c6 01             	add    $0x1,%esi
  801b25:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b28:	74 0d                	je     801b37 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801b2a:	8b 03                	mov    (%ebx),%eax
  801b2c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b2f:	75 d4                	jne    801b05 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b31:	85 f6                	test   %esi,%esi
  801b33:	75 b0                	jne    801ae5 <devpipe_read+0x29>
  801b35:	eb b2                	jmp    801ae9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b37:	89 f0                	mov    %esi,%eax
  801b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b40:	eb 05                	jmp    801b47 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b50:	89 ec                	mov    %ebp,%esp
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 48             	sub    $0x48,%esp
  801b5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b60:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b63:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b66:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b69:	89 04 24             	mov    %eax,(%esp)
  801b6c:	e8 8a f5 ff ff       	call   8010fb <fd_alloc>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	85 c0                	test   %eax,%eax
  801b75:	0f 88 45 01 00 00    	js     801cc0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b82:	00 
  801b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b91:	e8 36 f2 ff ff       	call   800dcc <sys_page_alloc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 88 20 01 00 00    	js     801cc0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ba3:	89 04 24             	mov    %eax,(%esp)
  801ba6:	e8 50 f5 ff ff       	call   8010fb <fd_alloc>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	85 c0                	test   %eax,%eax
  801baf:	0f 88 f8 00 00 00    	js     801cad <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bbc:	00 
  801bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcb:	e8 fc f1 ff ff       	call   800dcc <sys_page_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	0f 88 d3 00 00 00    	js     801cad <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bdd:	89 04 24             	mov    %eax,(%esp)
  801be0:	e8 fb f4 ff ff       	call   8010e0 <fd2data>
  801be5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bee:	00 
  801bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfa:	e8 cd f1 ff ff       	call   800dcc <sys_page_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	85 c0                	test   %eax,%eax
  801c03:	0f 88 91 00 00 00    	js     801c9a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c0c:	89 04 24             	mov    %eax,(%esp)
  801c0f:	e8 cc f4 ff ff       	call   8010e0 <fd2data>
  801c14:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c1b:	00 
  801c1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c27:	00 
  801c28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c33:	e8 f3 f1 ff ff       	call   800e2b <sys_page_map>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	78 4c                	js     801c8a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c3e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c53:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c6b:	89 04 24             	mov    %eax,(%esp)
  801c6e:	e8 5d f4 ff ff       	call   8010d0 <fd2num>
  801c73:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c75:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 50 f4 ff ff       	call   8010d0 <fd2num>
  801c80:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c88:	eb 36                	jmp    801cc0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801c8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c95:	e8 ef f1 ff ff       	call   800e89 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca8:	e8 dc f1 ff ff       	call   800e89 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cbb:	e8 c9 f1 ff ff       	call   800e89 <sys_page_unmap>
    err:
	return r;
}
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ccb:	89 ec                	mov    %ebp,%esp
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 87 f4 ff ff       	call   80116e <fd_lookup>
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 15                	js     801d00 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 ea f3 ff ff       	call   8010e0 <fd2data>
	return _pipeisclosed(fd, p);
  801cf6:	89 c2                	mov    %eax,%edx
  801cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfb:	e8 c2 fc ff ff       	call   8019c2 <_pipeisclosed>
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    
	...

00801d10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d20:	c7 44 24 04 6a 27 80 	movl   $0x80276a,0x4(%esp)
  801d27:	00 
  801d28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2b:	89 04 24             	mov    %eax,(%esp)
  801d2e:	e8 98 eb ff ff       	call   8008cb <strcpy>
	return 0;
}
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	57                   	push   %edi
  801d3e:	56                   	push   %esi
  801d3f:	53                   	push   %ebx
  801d40:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d46:	be 00 00 00 00       	mov    $0x0,%esi
  801d4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d4f:	74 43                	je     801d94 <devcons_write+0x5a>
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d61:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d64:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d69:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d70:	03 45 0c             	add    0xc(%ebp),%eax
  801d73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d77:	89 3c 24             	mov    %edi,(%esp)
  801d7a:	e8 3d ed ff ff       	call   800abc <memmove>
		sys_cputs(buf, m);
  801d7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d83:	89 3c 24             	mov    %edi,(%esp)
  801d86:	e8 25 ef ff ff       	call   800cb0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8b:	01 de                	add    %ebx,%esi
  801d8d:	89 f0                	mov    %esi,%eax
  801d8f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d92:	72 c8                	jb     801d5c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d94:	89 f0                	mov    %esi,%eax
  801d96:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d9c:	5b                   	pop    %ebx
  801d9d:	5e                   	pop    %esi
  801d9e:	5f                   	pop    %edi
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    

00801da1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801dac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db0:	75 07                	jne    801db9 <devcons_read+0x18>
  801db2:	eb 31                	jmp    801de5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db4:	e8 e3 ef ff ff       	call   800d9c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	e8 1a ef ff ff       	call   800cdf <sys_cgetc>
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	74 eb                	je     801db4 <devcons_read+0x13>
  801dc9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 16                	js     801de5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dcf:	83 f8 04             	cmp    $0x4,%eax
  801dd2:	74 0c                	je     801de0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd7:	88 10                	mov    %dl,(%eax)
	return 1;
  801dd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dde:	eb 05                	jmp    801de5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801dfa:	00 
  801dfb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfe:	89 04 24             	mov    %eax,(%esp)
  801e01:	e8 aa ee ff ff       	call   800cb0 <sys_cputs>
}
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    

00801e08 <getchar>:

int
getchar(void)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e0e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e15:	00 
  801e16:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e24:	e8 05 f6 ff ff       	call   80142e <read>
	if (r < 0)
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 0f                	js     801e3c <getchar+0x34>
		return r;
	if (r < 1)
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	7e 06                	jle    801e37 <getchar+0x2f>
		return -E_EOF;
	return c;
  801e31:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e35:	eb 05                	jmp    801e3c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e37:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	89 04 24             	mov    %eax,(%esp)
  801e51:	e8 18 f3 ff ff       	call   80116e <fd_lookup>
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 11                	js     801e6b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e63:	39 10                	cmp    %edx,(%eax)
  801e65:	0f 94 c0             	sete   %al
  801e68:	0f b6 c0             	movzbl %al,%eax
}
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <opencons>:

int
opencons(void)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e76:	89 04 24             	mov    %eax,(%esp)
  801e79:	e8 7d f2 ff ff       	call   8010fb <fd_alloc>
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	78 3c                	js     801ebe <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e89:	00 
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e98:	e8 2f ef ff ff       	call   800dcc <sys_page_alloc>
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 1d                	js     801ebe <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ea1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb6:	89 04 24             	mov    %eax,(%esp)
  801eb9:	e8 12 f2 ff ff       	call   8010d0 <fd2num>
}
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801ec8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ecb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ed1:	e8 96 ee ff ff       	call   800d6c <sys_getenvid>
  801ed6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801edd:	8b 55 08             	mov    0x8(%ebp),%edx
  801ee0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ee4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eec:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  801ef3:	e8 7f e2 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ef8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801efc:	8b 45 10             	mov    0x10(%ebp),%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 0f e2 ff ff       	call   800116 <vcprintf>
	cprintf("\n");
  801f07:	c7 04 24 2c 23 80 00 	movl   $0x80232c,(%esp)
  801f0e:	e8 64 e2 ff ff       	call   800177 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f13:	cc                   	int3   
  801f14:	eb fd                	jmp    801f13 <_panic+0x53>
	...

00801f18 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	56                   	push   %esi
  801f1c:	53                   	push   %ebx
  801f1d:	83 ec 10             	sub    $0x10,%esp
  801f20:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f26:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f29:	85 db                	test   %ebx,%ebx
  801f2b:	74 06                	je     801f33 <ipc_recv+0x1b>
  801f2d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801f33:	85 f6                	test   %esi,%esi
  801f35:	74 06                	je     801f3d <ipc_recv+0x25>
  801f37:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f44:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f47:	89 04 24             	mov    %eax,(%esp)
  801f4a:	e8 e6 f0 ff ff       	call   801035 <sys_ipc_recv>
    if (ret) return ret;
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	75 24                	jne    801f77 <ipc_recv+0x5f>
    if (from_env_store)
  801f53:	85 db                	test   %ebx,%ebx
  801f55:	74 0a                	je     801f61 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f57:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5c:	8b 40 74             	mov    0x74(%eax),%eax
  801f5f:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f61:	85 f6                	test   %esi,%esi
  801f63:	74 0a                	je     801f6f <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f65:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6a:	8b 40 78             	mov    0x78(%eax),%eax
  801f6d:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f6f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f74:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 75 08             	mov    0x8(%ebp),%esi
  801f8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801f90:	85 db                	test   %ebx,%ebx
  801f92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f97:	0f 44 d8             	cmove  %eax,%ebx
  801f9a:	eb 2a                	jmp    801fc6 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801f9c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f9f:	74 20                	je     801fc1 <ipc_send+0x43>
  801fa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa5:	c7 44 24 08 9c 27 80 	movl   $0x80279c,0x8(%esp)
  801fac:	00 
  801fad:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801fb4:	00 
  801fb5:	c7 04 24 b3 27 80 00 	movl   $0x8027b3,(%esp)
  801fbc:	e8 ff fe ff ff       	call   801ec0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801fc1:	e8 d6 ed ff ff       	call   800d9c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fd5:	89 34 24             	mov    %esi,(%esp)
  801fd8:	e8 24 f0 ff ff       	call   801001 <sys_ipc_try_send>
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	75 bb                	jne    801f9c <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801fe1:	83 c4 1c             	add    $0x1c,%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5e                   	pop    %esi
  801fe6:	5f                   	pop    %edi
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    

00801fe9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fef:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801ff4:	39 c8                	cmp    %ecx,%eax
  801ff6:	74 19                	je     802011 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ffd:	89 c2                	mov    %eax,%edx
  801fff:	c1 e2 07             	shl    $0x7,%edx
  802002:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802008:	8b 52 50             	mov    0x50(%edx),%edx
  80200b:	39 ca                	cmp    %ecx,%edx
  80200d:	75 14                	jne    802023 <ipc_find_env+0x3a>
  80200f:	eb 05                	jmp    802016 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802016:	c1 e0 07             	shl    $0x7,%eax
  802019:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80201e:	8b 40 40             	mov    0x40(%eax),%eax
  802021:	eb 0e                	jmp    802031 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802023:	83 c0 01             	add    $0x1,%eax
  802026:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202b:	75 d0                	jne    801ffd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202d:	66 b8 00 00          	mov    $0x0,%ax
}
  802031:	5d                   	pop    %ebp
  802032:	c3                   	ret    
	...

00802034 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203a:	89 d0                	mov    %edx,%eax
  80203c:	c1 e8 16             	shr    $0x16,%eax
  80203f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802046:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204b:	f6 c1 01             	test   $0x1,%cl
  80204e:	74 1d                	je     80206d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802050:	c1 ea 0c             	shr    $0xc,%edx
  802053:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205a:	f6 c2 01             	test   $0x1,%dl
  80205d:	74 0e                	je     80206d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205f:	c1 ea 0c             	shr    $0xc,%edx
  802062:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802069:	ef 
  80206a:	0f b7 c0             	movzwl %ax,%eax
}
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    
	...

00802070 <__udivdi3>:
  802070:	83 ec 1c             	sub    $0x1c,%esp
  802073:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802077:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80207b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80207f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802083:	89 74 24 10          	mov    %esi,0x10(%esp)
  802087:	8b 74 24 24          	mov    0x24(%esp),%esi
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802091:	89 44 24 08          	mov    %eax,0x8(%esp)
  802095:	89 cd                	mov    %ecx,%ebp
  802097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209b:	75 33                	jne    8020d0 <__udivdi3+0x60>
  80209d:	39 f1                	cmp    %esi,%ecx
  80209f:	77 57                	ja     8020f8 <__udivdi3+0x88>
  8020a1:	85 c9                	test   %ecx,%ecx
  8020a3:	75 0b                	jne    8020b0 <__udivdi3+0x40>
  8020a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020aa:	31 d2                	xor    %edx,%edx
  8020ac:	f7 f1                	div    %ecx
  8020ae:	89 c1                	mov    %eax,%ecx
  8020b0:	89 f0                	mov    %esi,%eax
  8020b2:	31 d2                	xor    %edx,%edx
  8020b4:	f7 f1                	div    %ecx
  8020b6:	89 c6                	mov    %eax,%esi
  8020b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020bc:	f7 f1                	div    %ecx
  8020be:	89 f2                	mov    %esi,%edx
  8020c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	c3                   	ret    
  8020d0:	31 d2                	xor    %edx,%edx
  8020d2:	31 c0                	xor    %eax,%eax
  8020d4:	39 f7                	cmp    %esi,%edi
  8020d6:	77 e8                	ja     8020c0 <__udivdi3+0x50>
  8020d8:	0f bd cf             	bsr    %edi,%ecx
  8020db:	83 f1 1f             	xor    $0x1f,%ecx
  8020de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020e2:	75 2c                	jne    802110 <__udivdi3+0xa0>
  8020e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8020e8:	76 04                	jbe    8020ee <__udivdi3+0x7e>
  8020ea:	39 f7                	cmp    %esi,%edi
  8020ec:	73 d2                	jae    8020c0 <__udivdi3+0x50>
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f5:	eb c9                	jmp    8020c0 <__udivdi3+0x50>
  8020f7:	90                   	nop
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	f7 f1                	div    %ecx
  8020fc:	31 d2                	xor    %edx,%edx
  8020fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  802102:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802106:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	c3                   	ret    
  80210e:	66 90                	xchg   %ax,%ax
  802110:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802115:	b8 20 00 00 00       	mov    $0x20,%eax
  80211a:	89 ea                	mov    %ebp,%edx
  80211c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802120:	d3 e7                	shl    %cl,%edi
  802122:	89 c1                	mov    %eax,%ecx
  802124:	d3 ea                	shr    %cl,%edx
  802126:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80212b:	09 fa                	or     %edi,%edx
  80212d:	89 f7                	mov    %esi,%edi
  80212f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802133:	89 f2                	mov    %esi,%edx
  802135:	8b 74 24 08          	mov    0x8(%esp),%esi
  802139:	d3 e5                	shl    %cl,%ebp
  80213b:	89 c1                	mov    %eax,%ecx
  80213d:	d3 ef                	shr    %cl,%edi
  80213f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802144:	d3 e2                	shl    %cl,%edx
  802146:	89 c1                	mov    %eax,%ecx
  802148:	d3 ee                	shr    %cl,%esi
  80214a:	09 d6                	or     %edx,%esi
  80214c:	89 fa                	mov    %edi,%edx
  80214e:	89 f0                	mov    %esi,%eax
  802150:	f7 74 24 0c          	divl   0xc(%esp)
  802154:	89 d7                	mov    %edx,%edi
  802156:	89 c6                	mov    %eax,%esi
  802158:	f7 e5                	mul    %ebp
  80215a:	39 d7                	cmp    %edx,%edi
  80215c:	72 22                	jb     802180 <__udivdi3+0x110>
  80215e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802162:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802167:	d3 e5                	shl    %cl,%ebp
  802169:	39 c5                	cmp    %eax,%ebp
  80216b:	73 04                	jae    802171 <__udivdi3+0x101>
  80216d:	39 d7                	cmp    %edx,%edi
  80216f:	74 0f                	je     802180 <__udivdi3+0x110>
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	e9 46 ff ff ff       	jmp    8020c0 <__udivdi3+0x50>
  80217a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802180:	8d 46 ff             	lea    -0x1(%esi),%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	8b 74 24 10          	mov    0x10(%esp),%esi
  802189:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80218d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	c3                   	ret    
	...

008021a0 <__umoddi3>:
  8021a0:	83 ec 1c             	sub    $0x1c,%esp
  8021a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8021a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8021ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8021af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8021b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021bb:	85 ed                	test   %ebp,%ebp
  8021bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c5:	89 cf                	mov    %ecx,%edi
  8021c7:	89 04 24             	mov    %eax,(%esp)
  8021ca:	89 f2                	mov    %esi,%edx
  8021cc:	75 1a                	jne    8021e8 <__umoddi3+0x48>
  8021ce:	39 f1                	cmp    %esi,%ecx
  8021d0:	76 4e                	jbe    802220 <__umoddi3+0x80>
  8021d2:	f7 f1                	div    %ecx
  8021d4:	89 d0                	mov    %edx,%eax
  8021d6:	31 d2                	xor    %edx,%edx
  8021d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021e4:	83 c4 1c             	add    $0x1c,%esp
  8021e7:	c3                   	ret    
  8021e8:	39 f5                	cmp    %esi,%ebp
  8021ea:	77 54                	ja     802240 <__umoddi3+0xa0>
  8021ec:	0f bd c5             	bsr    %ebp,%eax
  8021ef:	83 f0 1f             	xor    $0x1f,%eax
  8021f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f6:	75 60                	jne    802258 <__umoddi3+0xb8>
  8021f8:	3b 0c 24             	cmp    (%esp),%ecx
  8021fb:	0f 87 07 01 00 00    	ja     802308 <__umoddi3+0x168>
  802201:	89 f2                	mov    %esi,%edx
  802203:	8b 34 24             	mov    (%esp),%esi
  802206:	29 ce                	sub    %ecx,%esi
  802208:	19 ea                	sbb    %ebp,%edx
  80220a:	89 34 24             	mov    %esi,(%esp)
  80220d:	8b 04 24             	mov    (%esp),%eax
  802210:	8b 74 24 10          	mov    0x10(%esp),%esi
  802214:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802218:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	c3                   	ret    
  802220:	85 c9                	test   %ecx,%ecx
  802222:	75 0b                	jne    80222f <__umoddi3+0x8f>
  802224:	b8 01 00 00 00       	mov    $0x1,%eax
  802229:	31 d2                	xor    %edx,%edx
  80222b:	f7 f1                	div    %ecx
  80222d:	89 c1                	mov    %eax,%ecx
  80222f:	89 f0                	mov    %esi,%eax
  802231:	31 d2                	xor    %edx,%edx
  802233:	f7 f1                	div    %ecx
  802235:	8b 04 24             	mov    (%esp),%eax
  802238:	f7 f1                	div    %ecx
  80223a:	eb 98                	jmp    8021d4 <__umoddi3+0x34>
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 f2                	mov    %esi,%edx
  802242:	8b 74 24 10          	mov    0x10(%esp),%esi
  802246:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80224a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80224e:	83 c4 1c             	add    $0x1c,%esp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80225d:	89 e8                	mov    %ebp,%eax
  80225f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802264:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802268:	89 fa                	mov    %edi,%edx
  80226a:	d3 e0                	shl    %cl,%eax
  80226c:	89 e9                	mov    %ebp,%ecx
  80226e:	d3 ea                	shr    %cl,%edx
  802270:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802275:	09 c2                	or     %eax,%edx
  802277:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227b:	89 14 24             	mov    %edx,(%esp)
  80227e:	89 f2                	mov    %esi,%edx
  802280:	d3 e7                	shl    %cl,%edi
  802282:	89 e9                	mov    %ebp,%ecx
  802284:	d3 ea                	shr    %cl,%edx
  802286:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80228b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80228f:	d3 e6                	shl    %cl,%esi
  802291:	89 e9                	mov    %ebp,%ecx
  802293:	d3 e8                	shr    %cl,%eax
  802295:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80229a:	09 f0                	or     %esi,%eax
  80229c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022a0:	f7 34 24             	divl   (%esp)
  8022a3:	d3 e6                	shl    %cl,%esi
  8022a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022a9:	89 d6                	mov    %edx,%esi
  8022ab:	f7 e7                	mul    %edi
  8022ad:	39 d6                	cmp    %edx,%esi
  8022af:	89 c1                	mov    %eax,%ecx
  8022b1:	89 d7                	mov    %edx,%edi
  8022b3:	72 3f                	jb     8022f4 <__umoddi3+0x154>
  8022b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022b9:	72 35                	jb     8022f0 <__umoddi3+0x150>
  8022bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bf:	29 c8                	sub    %ecx,%eax
  8022c1:	19 fe                	sbb    %edi,%esi
  8022c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022c8:	89 f2                	mov    %esi,%edx
  8022ca:	d3 e8                	shr    %cl,%eax
  8022cc:	89 e9                	mov    %ebp,%ecx
  8022ce:	d3 e2                	shl    %cl,%edx
  8022d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022d5:	09 d0                	or     %edx,%eax
  8022d7:	89 f2                	mov    %esi,%edx
  8022d9:	d3 ea                	shr    %cl,%edx
  8022db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022e7:	83 c4 1c             	add    $0x1c,%esp
  8022ea:	c3                   	ret    
  8022eb:	90                   	nop
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	39 d6                	cmp    %edx,%esi
  8022f2:	75 c7                	jne    8022bb <__umoddi3+0x11b>
  8022f4:	89 d7                	mov    %edx,%edi
  8022f6:	89 c1                	mov    %eax,%ecx
  8022f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8022fc:	1b 3c 24             	sbb    (%esp),%edi
  8022ff:	eb ba                	jmp    8022bb <__umoddi3+0x11b>
  802301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 f5                	cmp    %esi,%ebp
  80230a:	0f 82 f1 fe ff ff    	jb     802201 <__umoddi3+0x61>
  802310:	e9 f8 fe ff ff       	jmp    80220d <__umoddi3+0x6d>
