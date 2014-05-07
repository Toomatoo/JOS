
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 60 23 80 00 	movl   $0x802360,(%esp)
  80004e:	e8 5c 01 00 00       	call   8001af <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 6f 0d 00 00       	call   800dcc <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 80 23 80 00 	movl   $0x802380,(%esp)
  800074:	e8 36 01 00 00       	call   8001af <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 40 80 00       	mov    0x804004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  800094:	e8 16 01 00 00       	call   8001af <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000b2:	e8 e5 0c 00 00       	call   800d9c <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	c1 e0 07             	shl    $0x7,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000f6:	e8 23 12 00 00       	call   80131e <close_all>
	sys_env_destroy(0);
  8000fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800102:	e8 38 0c 00 00       	call   800d3f <sys_env_destroy>
}
  800107:	c9                   	leave  
  800108:	c3                   	ret    
  800109:	00 00                	add    %al,(%eax)
	...

0080010c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 14             	sub    $0x14,%esp
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011f:	83 c0 01             	add    $0x1,%eax
  800122:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800124:	3d ff 00 00 00       	cmp    $0xff,%eax
  800129:	75 19                	jne    800144 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80012b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800132:	00 
  800133:	8d 43 08             	lea    0x8(%ebx),%eax
  800136:	89 04 24             	mov    %eax,(%esp)
  800139:	e8 a2 0b 00 00       	call   800ce0 <sys_cputs>
		b->idx = 0;
  80013e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800144:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800148:	83 c4 14             	add    $0x14,%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800157:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015e:	00 00 00 
	b.cnt = 0;
  800161:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800168:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	89 44 24 08          	mov    %eax,0x8(%esp)
  800179:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800183:	c7 04 24 0c 01 80 00 	movl   $0x80010c,(%esp)
  80018a:	e8 97 01 00 00       	call   800326 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 39 0b 00 00       	call   800ce0 <sys_cputs>

	return b.cnt;
}
  8001a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 87 ff ff ff       	call   80014e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
  8001c9:	00 00                	add    %al,(%eax)
	...

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 3c             	sub    $0x3c,%esp
  8001d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d8:	89 d7                	mov    %edx,%edi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001f4:	72 11                	jb     800207 <printnum+0x3b>
  8001f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fc:	76 09                	jbe    800207 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fe:	83 eb 01             	sub    $0x1,%ebx
  800201:	85 db                	test   %ebx,%ebx
  800203:	7f 51                	jg     800256 <printnum+0x8a>
  800205:	eb 5e                	jmp    800265 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800207:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020b:	83 eb 01             	sub    $0x1,%ebx
  80020e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800212:	8b 45 10             	mov    0x10(%ebp),%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80021d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800221:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800228:	00 
  800229:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022c:	89 04 24             	mov    %eax,(%esp)
  80022f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800232:	89 44 24 04          	mov    %eax,0x4(%esp)
  800236:	e8 65 1e 00 00       	call   8020a0 <__udivdi3>
  80023b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024a:	89 fa                	mov    %edi,%edx
  80024c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024f:	e8 78 ff ff ff       	call   8001cc <printnum>
  800254:	eb 0f                	jmp    800265 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800256:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025a:	89 34 24             	mov    %esi,(%esp)
  80025d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	75 f1                	jne    800256 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800265:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800269:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80026d:	8b 45 10             	mov    0x10(%ebp),%eax
  800270:	89 44 24 08          	mov    %eax,0x8(%esp)
  800274:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027b:	00 
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	e8 42 1f 00 00       	call   8021d0 <__umoddi3>
  80028e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800292:	0f be 80 d5 23 80 00 	movsbl 0x8023d5(%eax),%eax
  800299:	89 04 24             	mov    %eax,(%esp)
  80029c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029f:	83 c4 3c             	add    $0x3c,%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002aa:	83 fa 01             	cmp    $0x1,%edx
  8002ad:	7e 0e                	jle    8002bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	8b 52 04             	mov    0x4(%edx),%edx
  8002bb:	eb 22                	jmp    8002df <getuint+0x38>
	else if (lflag)
  8002bd:	85 d2                	test   %edx,%edx
  8002bf:	74 10                	je     8002d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cf:	eb 0e                	jmp    8002df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f0:	73 0a                	jae    8002fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f5:	88 0a                	mov    %cl,(%edx)
  8002f7:	83 c2 01             	add    $0x1,%edx
  8002fa:	89 10                	mov    %edx,(%eax)
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800304:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800307:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80030b:	8b 45 10             	mov    0x10(%ebp),%eax
  80030e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
  800315:	89 44 24 04          	mov    %eax,0x4(%esp)
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	e8 02 00 00 00       	call   800326 <vprintfmt>
	va_end(ap);
}
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 5c             	sub    $0x5c,%esp
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 75 10             	mov    0x10(%ebp),%esi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 e4 04 00 00    	je     800823 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80033f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	0f b6 06             	movzbl (%esi),%eax
  80034c:	83 c6 01             	add    $0x1,%esi
  80034f:	83 f8 25             	cmp    $0x25,%eax
  800352:	75 e3                	jne    800337 <vprintfmt+0x11>
  800354:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800358:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80035f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800364:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800370:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800373:	eb 2b                	jmp    8003a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80037c:	eb 22                	jmp    8003a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800381:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800385:	eb 19                	jmp    8003a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80038a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800391:	eb 0d                	jmp    8003a0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800393:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800396:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800399:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	0f b6 06             	movzbl (%esi),%eax
  8003a3:	0f b6 d0             	movzbl %al,%edx
  8003a6:	8d 7e 01             	lea    0x1(%esi),%edi
  8003a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003ac:	83 e8 23             	sub    $0x23,%eax
  8003af:	3c 55                	cmp    $0x55,%al
  8003b1:	0f 87 46 04 00 00    	ja     8007fd <vprintfmt+0x4d7>
  8003b7:	0f b6 c0             	movzbl %al,%eax
  8003ba:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c1:	83 ea 30             	sub    $0x30,%edx
  8003c4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003c7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003cb:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003d1:	83 fa 09             	cmp    $0x9,%edx
  8003d4:	77 4a                	ja     800420 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003dc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003df:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003e3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e9:	83 fa 09             	cmp    $0x9,%edx
  8003ec:	76 eb                	jbe    8003d9 <vprintfmt+0xb3>
  8003ee:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003f1:	eb 2d                	jmp    800420 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 50 04             	lea    0x4(%eax),%edx
  8003f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fc:	8b 00                	mov    (%eax),%eax
  8003fe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800404:	eb 1a                	jmp    800420 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800409:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80040d:	79 91                	jns    8003a0 <vprintfmt+0x7a>
  80040f:	e9 73 ff ff ff       	jmp    800387 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800417:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80041e:	eb 80                	jmp    8003a0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800420:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800424:	0f 89 76 ff ff ff    	jns    8003a0 <vprintfmt+0x7a>
  80042a:	e9 64 ff ff ff       	jmp    800393 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800435:	e9 66 ff ff ff       	jmp    8003a0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800447:	8b 00                	mov    (%eax),%eax
  800449:	89 04 24             	mov    %eax,(%esp)
  80044c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800452:	e9 f2 fe ff ff       	jmp    800349 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800457:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80045b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80045e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800462:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800465:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800469:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80046c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80046f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800473:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800476:	80 f9 09             	cmp    $0x9,%cl
  800479:	77 1d                	ja     800498 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80047b:	0f be c0             	movsbl %al,%eax
  80047e:	6b c0 64             	imul   $0x64,%eax,%eax
  800481:	0f be d2             	movsbl %dl,%edx
  800484:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800487:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80048e:	a3 04 30 80 00       	mov    %eax,0x803004
  800493:	e9 b1 fe ff ff       	jmp    800349 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800498:	c7 44 24 04 ed 23 80 	movl   $0x8023ed,0x4(%esp)
  80049f:	00 
  8004a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	e8 10 05 00 00       	call   8009bb <strcmp>
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 0f                	jne    8004be <vprintfmt+0x198>
  8004af:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8004b6:	00 00 00 
  8004b9:	e9 8b fe ff ff       	jmp    800349 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004be:	c7 44 24 04 f1 23 80 	movl   $0x8023f1,0x4(%esp)
  8004c5:	00 
  8004c6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004c9:	89 14 24             	mov    %edx,(%esp)
  8004cc:	e8 ea 04 00 00       	call   8009bb <strcmp>
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 0f                	jne    8004e4 <vprintfmt+0x1be>
  8004d5:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8004dc:	00 00 00 
  8004df:	e9 65 fe ff ff       	jmp    800349 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004e4:	c7 44 24 04 f5 23 80 	movl   $0x8023f5,0x4(%esp)
  8004eb:	00 
  8004ec:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004ef:	89 0c 24             	mov    %ecx,(%esp)
  8004f2:	e8 c4 04 00 00       	call   8009bb <strcmp>
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	75 0f                	jne    80050a <vprintfmt+0x1e4>
  8004fb:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  800502:	00 00 00 
  800505:	e9 3f fe ff ff       	jmp    800349 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80050a:	c7 44 24 04 f9 23 80 	movl   $0x8023f9,0x4(%esp)
  800511:	00 
  800512:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800515:	89 3c 24             	mov    %edi,(%esp)
  800518:	e8 9e 04 00 00       	call   8009bb <strcmp>
  80051d:	85 c0                	test   %eax,%eax
  80051f:	75 0f                	jne    800530 <vprintfmt+0x20a>
  800521:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800528:	00 00 00 
  80052b:	e9 19 fe ff ff       	jmp    800349 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800530:	c7 44 24 04 fd 23 80 	movl   $0x8023fd,0x4(%esp)
  800537:	00 
  800538:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	e8 78 04 00 00       	call   8009bb <strcmp>
  800543:	85 c0                	test   %eax,%eax
  800545:	75 0f                	jne    800556 <vprintfmt+0x230>
  800547:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  80054e:	00 00 00 
  800551:	e9 f3 fd ff ff       	jmp    800349 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800556:	c7 44 24 04 01 24 80 	movl   $0x802401,0x4(%esp)
  80055d:	00 
  80055e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800561:	89 14 24             	mov    %edx,(%esp)
  800564:	e8 52 04 00 00       	call   8009bb <strcmp>
  800569:	83 f8 01             	cmp    $0x1,%eax
  80056c:	19 c0                	sbb    %eax,%eax
  80056e:	f7 d0                	not    %eax
  800570:	83 c0 08             	add    $0x8,%eax
  800573:	a3 04 30 80 00       	mov    %eax,0x803004
  800578:	e9 cc fd ff ff       	jmp    800349 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 c2                	mov    %eax,%edx
  80058a:	c1 fa 1f             	sar    $0x1f,%edx
  80058d:	31 d0                	xor    %edx,%eax
  80058f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800591:	83 f8 0f             	cmp    $0xf,%eax
  800594:	7f 0b                	jg     8005a1 <vprintfmt+0x27b>
  800596:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80059d:	85 d2                	test   %edx,%edx
  80059f:	75 23                	jne    8005c4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a5:	c7 44 24 08 05 24 80 	movl   $0x802405,0x8(%esp)
  8005ac:	00 
  8005ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b4:	89 3c 24             	mov    %edi,(%esp)
  8005b7:	e8 42 fd ff ff       	call   8002fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005bf:	e9 85 fd ff ff       	jmp    800349 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c8:	c7 44 24 08 b1 27 80 	movl   $0x8027b1,0x8(%esp)
  8005cf:	00 
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d7:	89 3c 24             	mov    %edi,(%esp)
  8005da:	e8 1f fd ff ff       	call   8002fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005e2:	e9 62 fd ff ff       	jmp    800349 <vprintfmt+0x23>
  8005e7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ed:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 04             	lea    0x4(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005fb:	85 f6                	test   %esi,%esi
  8005fd:	b8 e6 23 80 00       	mov    $0x8023e6,%eax
  800602:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800605:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800609:	7e 06                	jle    800611 <vprintfmt+0x2eb>
  80060b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80060f:	75 13                	jne    800624 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800611:	0f be 06             	movsbl (%esi),%eax
  800614:	83 c6 01             	add    $0x1,%esi
  800617:	85 c0                	test   %eax,%eax
  800619:	0f 85 94 00 00 00    	jne    8006b3 <vprintfmt+0x38d>
  80061f:	e9 81 00 00 00       	jmp    8006a5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800628:	89 34 24             	mov    %esi,(%esp)
  80062b:	e8 9b 02 00 00       	call   8008cb <strnlen>
  800630:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800633:	29 c2                	sub    %eax,%edx
  800635:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800638:	85 d2                	test   %edx,%edx
  80063a:	7e d5                	jle    800611 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80063c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800640:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800643:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800646:	89 d6                	mov    %edx,%esi
  800648:	89 cf                	mov    %ecx,%edi
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	89 3c 24             	mov    %edi,(%esp)
  800651:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800654:	83 ee 01             	sub    $0x1,%esi
  800657:	75 f1                	jne    80064a <vprintfmt+0x324>
  800659:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80065c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80065f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800662:	eb ad                	jmp    800611 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800664:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800668:	74 1b                	je     800685 <vprintfmt+0x35f>
  80066a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80066d:	83 fa 5e             	cmp    $0x5e,%edx
  800670:	76 13                	jbe    800685 <vprintfmt+0x35f>
					putch('?', putdat);
  800672:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800675:	89 44 24 04          	mov    %eax,0x4(%esp)
  800679:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800680:	ff 55 08             	call   *0x8(%ebp)
  800683:	eb 0d                	jmp    800692 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800685:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800688:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800692:	83 eb 01             	sub    $0x1,%ebx
  800695:	0f be 06             	movsbl (%esi),%eax
  800698:	83 c6 01             	add    $0x1,%esi
  80069b:	85 c0                	test   %eax,%eax
  80069d:	75 1a                	jne    8006b9 <vprintfmt+0x393>
  80069f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ac:	7f 1c                	jg     8006ca <vprintfmt+0x3a4>
  8006ae:	e9 96 fc ff ff       	jmp    800349 <vprintfmt+0x23>
  8006b3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006b6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b9:	85 ff                	test   %edi,%edi
  8006bb:	78 a7                	js     800664 <vprintfmt+0x33e>
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	79 a2                	jns    800664 <vprintfmt+0x33e>
  8006c2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006c5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c8:	eb db                	jmp    8006a5 <vprintfmt+0x37f>
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	89 de                	mov    %ebx,%esi
  8006cf:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006df:	83 eb 01             	sub    $0x1,%ebx
  8006e2:	75 ee                	jne    8006d2 <vprintfmt+0x3ac>
  8006e4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006e9:	e9 5b fc ff ff       	jmp    800349 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ee:	83 f9 01             	cmp    $0x1,%ecx
  8006f1:	7e 10                	jle    800703 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 50 08             	lea    0x8(%eax),%edx
  8006f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fc:	8b 30                	mov    (%eax),%esi
  8006fe:	8b 78 04             	mov    0x4(%eax),%edi
  800701:	eb 26                	jmp    800729 <vprintfmt+0x403>
	else if (lflag)
  800703:	85 c9                	test   %ecx,%ecx
  800705:	74 12                	je     800719 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 30                	mov    (%eax),%esi
  800712:	89 f7                	mov    %esi,%edi
  800714:	c1 ff 1f             	sar    $0x1f,%edi
  800717:	eb 10                	jmp    800729 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 50 04             	lea    0x4(%eax),%edx
  80071f:	89 55 14             	mov    %edx,0x14(%ebp)
  800722:	8b 30                	mov    (%eax),%esi
  800724:	89 f7                	mov    %esi,%edi
  800726:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800729:	85 ff                	test   %edi,%edi
  80072b:	78 0e                	js     80073b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072d:	89 f0                	mov    %esi,%eax
  80072f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800731:	be 0a 00 00 00       	mov    $0xa,%esi
  800736:	e9 84 00 00 00       	jmp    8007bf <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80073b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800746:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800749:	89 f0                	mov    %esi,%eax
  80074b:	89 fa                	mov    %edi,%edx
  80074d:	f7 d8                	neg    %eax
  80074f:	83 d2 00             	adc    $0x0,%edx
  800752:	f7 da                	neg    %edx
			}
			base = 10;
  800754:	be 0a 00 00 00       	mov    $0xa,%esi
  800759:	eb 64                	jmp    8007bf <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075b:	89 ca                	mov    %ecx,%edx
  80075d:	8d 45 14             	lea    0x14(%ebp),%eax
  800760:	e8 42 fb ff ff       	call   8002a7 <getuint>
			base = 10;
  800765:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80076a:	eb 53                	jmp    8007bf <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80076c:	89 ca                	mov    %ecx,%edx
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	e8 31 fb ff ff       	call   8002a7 <getuint>
    			base = 8;
  800776:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80077b:	eb 42                	jmp    8007bf <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80077d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800781:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800788:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80078b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800796:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 50 04             	lea    0x4(%eax),%edx
  80079f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007ae:	eb 0f                	jmp    8007bf <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b0:	89 ca                	mov    %ecx,%edx
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b5:	e8 ed fa ff ff       	call   8002a7 <getuint>
			base = 16;
  8007ba:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bf:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007c7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007ca:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d9:	89 da                	mov    %ebx,%edx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	e8 e9 f9 ff ff       	call   8001cc <printnum>
			break;
  8007e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007e6:	e9 5e fb ff ff       	jmp    800349 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ef:	89 14 24             	mov    %edx,(%esp)
  8007f2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f8:	e9 4c fb ff ff       	jmp    800349 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800801:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800808:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80080b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80080f:	0f 84 34 fb ff ff    	je     800349 <vprintfmt+0x23>
  800815:	83 ee 01             	sub    $0x1,%esi
  800818:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80081c:	75 f7                	jne    800815 <vprintfmt+0x4ef>
  80081e:	e9 26 fb ff ff       	jmp    800349 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800823:	83 c4 5c             	add    $0x5c,%esp
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5f                   	pop    %edi
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	83 ec 28             	sub    $0x28,%esp
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800837:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80083a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80083e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800841:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800848:	85 c0                	test   %eax,%eax
  80084a:	74 30                	je     80087c <vsnprintf+0x51>
  80084c:	85 d2                	test   %edx,%edx
  80084e:	7e 2c                	jle    80087c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800857:	8b 45 10             	mov    0x10(%ebp),%eax
  80085a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800861:	89 44 24 04          	mov    %eax,0x4(%esp)
  800865:	c7 04 24 e1 02 80 00 	movl   $0x8002e1,(%esp)
  80086c:	e8 b5 fa ff ff       	call   800326 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800871:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800874:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087a:	eb 05                	jmp    800881 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80087c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800889:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80088c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800890:	8b 45 10             	mov    0x10(%ebp),%eax
  800893:	89 44 24 08          	mov    %eax,0x8(%esp)
  800897:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	89 04 24             	mov    %eax,(%esp)
  8008a4:	e8 82 ff ff ff       	call   80082b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    
  8008ab:	00 00                	add    %al,(%eax)
  8008ad:	00 00                	add    %al,(%eax)
	...

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008be:	74 09                	je     8008c9 <strlen+0x19>
		n++;
  8008c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c7:	75 f7                	jne    8008c0 <strlen+0x10>
		n++;
	return n;
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008da:	85 c9                	test   %ecx,%ecx
  8008dc:	74 1a                	je     8008f8 <strnlen+0x2d>
  8008de:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008e1:	74 15                	je     8008f8 <strnlen+0x2d>
  8008e3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008e8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ea:	39 ca                	cmp    %ecx,%edx
  8008ec:	74 0a                	je     8008f8 <strnlen+0x2d>
  8008ee:	83 c2 01             	add    $0x1,%edx
  8008f1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008f6:	75 f0                	jne    8008e8 <strnlen+0x1d>
		n++;
	return n;
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800905:	ba 00 00 00 00       	mov    $0x0,%edx
  80090a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80090e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800911:	83 c2 01             	add    $0x1,%edx
  800914:	84 c9                	test   %cl,%cl
  800916:	75 f2                	jne    80090a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800925:	89 1c 24             	mov    %ebx,(%esp)
  800928:	e8 83 ff ff ff       	call   8008b0 <strlen>
	strcpy(dst + len, src);
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 54 24 04          	mov    %edx,0x4(%esp)
  800934:	01 d8                	add    %ebx,%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	e8 bd ff ff ff       	call   8008fb <strcpy>
	return dst;
}
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	83 c4 08             	add    $0x8,%esp
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800954:	85 f6                	test   %esi,%esi
  800956:	74 18                	je     800970 <strncpy+0x2a>
  800958:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80095d:	0f b6 1a             	movzbl (%edx),%ebx
  800960:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800963:	80 3a 01             	cmpb   $0x1,(%edx)
  800966:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	39 f1                	cmp    %esi,%ecx
  80096e:	75 ed                	jne    80095d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800980:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800983:	89 f8                	mov    %edi,%eax
  800985:	85 f6                	test   %esi,%esi
  800987:	74 2b                	je     8009b4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800989:	83 fe 01             	cmp    $0x1,%esi
  80098c:	74 23                	je     8009b1 <strlcpy+0x3d>
  80098e:	0f b6 0b             	movzbl (%ebx),%ecx
  800991:	84 c9                	test   %cl,%cl
  800993:	74 1c                	je     8009b1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800995:	83 ee 02             	sub    $0x2,%esi
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80099d:	88 08                	mov    %cl,(%eax)
  80099f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a2:	39 f2                	cmp    %esi,%edx
  8009a4:	74 0b                	je     8009b1 <strlcpy+0x3d>
  8009a6:	83 c2 01             	add    $0x1,%edx
  8009a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ad:	84 c9                	test   %cl,%cl
  8009af:	75 ec                	jne    80099d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8009b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b4:	29 f8                	sub    %edi,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c4:	0f b6 01             	movzbl (%ecx),%eax
  8009c7:	84 c0                	test   %al,%al
  8009c9:	74 16                	je     8009e1 <strcmp+0x26>
  8009cb:	3a 02                	cmp    (%edx),%al
  8009cd:	75 12                	jne    8009e1 <strcmp+0x26>
		p++, q++;
  8009cf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8009d6:	84 c0                	test   %al,%al
  8009d8:	74 07                	je     8009e1 <strcmp+0x26>
  8009da:	83 c1 01             	add    $0x1,%ecx
  8009dd:	3a 02                	cmp    (%edx),%al
  8009df:	74 ee                	je     8009cf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e1:	0f b6 c0             	movzbl %al,%eax
  8009e4:	0f b6 12             	movzbl (%edx),%edx
  8009e7:	29 d0                	sub    %edx,%eax
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fd:	85 d2                	test   %edx,%edx
  8009ff:	74 28                	je     800a29 <strncmp+0x3e>
  800a01:	0f b6 01             	movzbl (%ecx),%eax
  800a04:	84 c0                	test   %al,%al
  800a06:	74 24                	je     800a2c <strncmp+0x41>
  800a08:	3a 03                	cmp    (%ebx),%al
  800a0a:	75 20                	jne    800a2c <strncmp+0x41>
  800a0c:	83 ea 01             	sub    $0x1,%edx
  800a0f:	74 13                	je     800a24 <strncmp+0x39>
		n--, p++, q++;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a17:	0f b6 01             	movzbl (%ecx),%eax
  800a1a:	84 c0                	test   %al,%al
  800a1c:	74 0e                	je     800a2c <strncmp+0x41>
  800a1e:	3a 03                	cmp    (%ebx),%al
  800a20:	74 ea                	je     800a0c <strncmp+0x21>
  800a22:	eb 08                	jmp    800a2c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2c:	0f b6 01             	movzbl (%ecx),%eax
  800a2f:	0f b6 13             	movzbl (%ebx),%edx
  800a32:	29 d0                	sub    %edx,%eax
  800a34:	eb f3                	jmp    800a29 <strncmp+0x3e>

00800a36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a40:	0f b6 10             	movzbl (%eax),%edx
  800a43:	84 d2                	test   %dl,%dl
  800a45:	74 1c                	je     800a63 <strchr+0x2d>
		if (*s == c)
  800a47:	38 ca                	cmp    %cl,%dl
  800a49:	75 09                	jne    800a54 <strchr+0x1e>
  800a4b:	eb 1b                	jmp    800a68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a50:	38 ca                	cmp    %cl,%dl
  800a52:	74 14                	je     800a68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a54:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	75 f1                	jne    800a4d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	eb 05                	jmp    800a68 <strchr+0x32>
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a74:	0f b6 10             	movzbl (%eax),%edx
  800a77:	84 d2                	test   %dl,%dl
  800a79:	74 14                	je     800a8f <strfind+0x25>
		if (*s == c)
  800a7b:	38 ca                	cmp    %cl,%dl
  800a7d:	75 06                	jne    800a85 <strfind+0x1b>
  800a7f:	eb 0e                	jmp    800a8f <strfind+0x25>
  800a81:	38 ca                	cmp    %cl,%dl
  800a83:	74 0a                	je     800a8f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a85:	83 c0 01             	add    $0x1,%eax
  800a88:	0f b6 10             	movzbl (%eax),%edx
  800a8b:	84 d2                	test   %dl,%dl
  800a8d:	75 f2                	jne    800a81 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 0c             	sub    $0xc,%esp
  800a97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa9:	85 c9                	test   %ecx,%ecx
  800aab:	74 30                	je     800add <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab3:	75 25                	jne    800ada <memset+0x49>
  800ab5:	f6 c1 03             	test   $0x3,%cl
  800ab8:	75 20                	jne    800ada <memset+0x49>
		c &= 0xFF;
  800aba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800abd:	89 d3                	mov    %edx,%ebx
  800abf:	c1 e3 08             	shl    $0x8,%ebx
  800ac2:	89 d6                	mov    %edx,%esi
  800ac4:	c1 e6 18             	shl    $0x18,%esi
  800ac7:	89 d0                	mov    %edx,%eax
  800ac9:	c1 e0 10             	shl    $0x10,%eax
  800acc:	09 f0                	or     %esi,%eax
  800ace:	09 d0                	or     %edx,%eax
  800ad0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ad2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ad5:	fc                   	cld    
  800ad6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad8:	eb 03                	jmp    800add <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ada:	fc                   	cld    
  800adb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800add:	89 f8                	mov    %edi,%eax
  800adf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ae2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ae5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ae8:	89 ec                	mov    %ebp,%esp
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800af5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b01:	39 c6                	cmp    %eax,%esi
  800b03:	73 36                	jae    800b3b <memmove+0x4f>
  800b05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b08:	39 d0                	cmp    %edx,%eax
  800b0a:	73 2f                	jae    800b3b <memmove+0x4f>
		s += n;
		d += n;
  800b0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0f:	f6 c2 03             	test   $0x3,%dl
  800b12:	75 1b                	jne    800b2f <memmove+0x43>
  800b14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1a:	75 13                	jne    800b2f <memmove+0x43>
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	75 0e                	jne    800b2f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b21:	83 ef 04             	sub    $0x4,%edi
  800b24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b2a:	fd                   	std    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb 09                	jmp    800b38 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2f:	83 ef 01             	sub    $0x1,%edi
  800b32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b35:	fd                   	std    
  800b36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b38:	fc                   	cld    
  800b39:	eb 20                	jmp    800b5b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b41:	75 13                	jne    800b56 <memmove+0x6a>
  800b43:	a8 03                	test   $0x3,%al
  800b45:	75 0f                	jne    800b56 <memmove+0x6a>
  800b47:	f6 c1 03             	test   $0x3,%cl
  800b4a:	75 0a                	jne    800b56 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	fc                   	cld    
  800b52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b54:	eb 05                	jmp    800b5b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b56:	89 c7                	mov    %eax,%edi
  800b58:	fc                   	cld    
  800b59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b61:	89 ec                	mov    %ebp,%esp
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	89 04 24             	mov    %eax,(%esp)
  800b7f:	e8 68 ff ff ff       	call   800aec <memmove>
}
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b92:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9a:	85 ff                	test   %edi,%edi
  800b9c:	74 37                	je     800bd5 <memcmp+0x4f>
		if (*s1 != *s2)
  800b9e:	0f b6 03             	movzbl (%ebx),%eax
  800ba1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba4:	83 ef 01             	sub    $0x1,%edi
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800bac:	38 c8                	cmp    %cl,%al
  800bae:	74 1c                	je     800bcc <memcmp+0x46>
  800bb0:	eb 10                	jmp    800bc2 <memcmp+0x3c>
  800bb2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800bb7:	83 c2 01             	add    $0x1,%edx
  800bba:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bbe:	38 c8                	cmp    %cl,%al
  800bc0:	74 0a                	je     800bcc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800bc2:	0f b6 c0             	movzbl %al,%eax
  800bc5:	0f b6 c9             	movzbl %cl,%ecx
  800bc8:	29 c8                	sub    %ecx,%eax
  800bca:	eb 09                	jmp    800bd5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcc:	39 fa                	cmp    %edi,%edx
  800bce:	75 e2                	jne    800bb2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be0:	89 c2                	mov    %eax,%edx
  800be2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be5:	39 d0                	cmp    %edx,%eax
  800be7:	73 19                	jae    800c02 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bed:	38 08                	cmp    %cl,(%eax)
  800bef:	75 06                	jne    800bf7 <memfind+0x1d>
  800bf1:	eb 0f                	jmp    800c02 <memfind+0x28>
  800bf3:	38 08                	cmp    %cl,(%eax)
  800bf5:	74 0b                	je     800c02 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf7:	83 c0 01             	add    $0x1,%eax
  800bfa:	39 d0                	cmp    %edx,%eax
  800bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c00:	75 f1                	jne    800bf3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c10:	0f b6 02             	movzbl (%edx),%eax
  800c13:	3c 20                	cmp    $0x20,%al
  800c15:	74 04                	je     800c1b <strtol+0x17>
  800c17:	3c 09                	cmp    $0x9,%al
  800c19:	75 0e                	jne    800c29 <strtol+0x25>
		s++;
  800c1b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1e:	0f b6 02             	movzbl (%edx),%eax
  800c21:	3c 20                	cmp    $0x20,%al
  800c23:	74 f6                	je     800c1b <strtol+0x17>
  800c25:	3c 09                	cmp    $0x9,%al
  800c27:	74 f2                	je     800c1b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c29:	3c 2b                	cmp    $0x2b,%al
  800c2b:	75 0a                	jne    800c37 <strtol+0x33>
		s++;
  800c2d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c30:	bf 00 00 00 00       	mov    $0x0,%edi
  800c35:	eb 10                	jmp    800c47 <strtol+0x43>
  800c37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c3c:	3c 2d                	cmp    $0x2d,%al
  800c3e:	75 07                	jne    800c47 <strtol+0x43>
		s++, neg = 1;
  800c40:	83 c2 01             	add    $0x1,%edx
  800c43:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c47:	85 db                	test   %ebx,%ebx
  800c49:	0f 94 c0             	sete   %al
  800c4c:	74 05                	je     800c53 <strtol+0x4f>
  800c4e:	83 fb 10             	cmp    $0x10,%ebx
  800c51:	75 15                	jne    800c68 <strtol+0x64>
  800c53:	80 3a 30             	cmpb   $0x30,(%edx)
  800c56:	75 10                	jne    800c68 <strtol+0x64>
  800c58:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c5c:	75 0a                	jne    800c68 <strtol+0x64>
		s += 2, base = 16;
  800c5e:	83 c2 02             	add    $0x2,%edx
  800c61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c66:	eb 13                	jmp    800c7b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c68:	84 c0                	test   %al,%al
  800c6a:	74 0f                	je     800c7b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c71:	80 3a 30             	cmpb   $0x30,(%edx)
  800c74:	75 05                	jne    800c7b <strtol+0x77>
		s++, base = 8;
  800c76:	83 c2 01             	add    $0x1,%edx
  800c79:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c80:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c82:	0f b6 0a             	movzbl (%edx),%ecx
  800c85:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c88:	80 fb 09             	cmp    $0x9,%bl
  800c8b:	77 08                	ja     800c95 <strtol+0x91>
			dig = *s - '0';
  800c8d:	0f be c9             	movsbl %cl,%ecx
  800c90:	83 e9 30             	sub    $0x30,%ecx
  800c93:	eb 1e                	jmp    800cb3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c95:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c98:	80 fb 19             	cmp    $0x19,%bl
  800c9b:	77 08                	ja     800ca5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c9d:	0f be c9             	movsbl %cl,%ecx
  800ca0:	83 e9 57             	sub    $0x57,%ecx
  800ca3:	eb 0e                	jmp    800cb3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800ca5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ca8:	80 fb 19             	cmp    $0x19,%bl
  800cab:	77 14                	ja     800cc1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cad:	0f be c9             	movsbl %cl,%ecx
  800cb0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cb3:	39 f1                	cmp    %esi,%ecx
  800cb5:	7d 0e                	jge    800cc5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cb7:	83 c2 01             	add    $0x1,%edx
  800cba:	0f af c6             	imul   %esi,%eax
  800cbd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cbf:	eb c1                	jmp    800c82 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cc1:	89 c1                	mov    %eax,%ecx
  800cc3:	eb 02                	jmp    800cc7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccb:	74 05                	je     800cd2 <strtol+0xce>
		*endptr = (char *) s;
  800ccd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cd0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cd2:	89 ca                	mov    %ecx,%edx
  800cd4:	f7 da                	neg    %edx
  800cd6:	85 ff                	test   %edi,%edi
  800cd8:	0f 45 c2             	cmovne %edx,%eax
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 c3                	mov    %eax,%ebx
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0b:	89 ec                	mov    %ebp,%esp
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d23:	b8 01 00 00 00       	mov    $0x1,%eax
  800d28:	89 d1                	mov    %edx,%ecx
  800d2a:	89 d3                	mov    %edx,%ebx
  800d2c:	89 d7                	mov    %edx,%edi
  800d2e:	89 d6                	mov    %edx,%esi
  800d30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3b:	89 ec                	mov    %ebp,%esp
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 38             	sub    $0x38,%esp
  800d45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d53:	b8 03 00 00 00       	mov    $0x3,%eax
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 cb                	mov    %ecx,%ebx
  800d5d:	89 cf                	mov    %ecx,%edi
  800d5f:	89 ce                	mov    %ecx,%esi
  800d61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 28                	jle    800d8f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d72:	00 
  800d73:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d82:	00 
  800d83:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800d8a:	e8 61 11 00 00       	call   801ef0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d98:	89 ec                	mov    %ebp,%esp
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800db0:	b8 02 00 00 00       	mov    $0x2,%eax
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	89 d3                	mov    %edx,%ebx
  800db9:	89 d7                	mov    %edx,%edi
  800dbb:	89 d6                	mov    %edx,%esi
  800dbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc8:	89 ec                	mov    %ebp,%esp
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_yield>:

void
sys_yield(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	ba 00 00 00 00       	mov    $0x0,%edx
  800de0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de5:	89 d1                	mov    %edx,%ecx
  800de7:	89 d3                	mov    %edx,%ebx
  800de9:	89 d7                	mov    %edx,%edi
  800deb:	89 d6                	mov    %edx,%esi
  800ded:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800def:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df8:	89 ec                	mov    %ebp,%esp
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 38             	sub    $0x38,%esp
  800e02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	be 00 00 00 00       	mov    $0x0,%esi
  800e10:	b8 04 00 00 00       	mov    $0x4,%eax
  800e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 f7                	mov    %esi,%edi
  800e20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 28                	jle    800e4e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e31:	00 
  800e32:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800e39:	00 
  800e3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e41:	00 
  800e42:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800e49:	e8 a2 10 00 00       	call   801ef0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e4e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e51:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e54:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e57:	89 ec                	mov    %ebp,%esp
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	83 ec 38             	sub    $0x38,%esp
  800e61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e67:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 28                	jle    800eac <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e8f:	00 
  800e90:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800e97:	00 
  800e98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9f:	00 
  800ea0:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800ea7:	e8 44 10 00 00       	call   801ef0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eac:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eaf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb5:	89 ec                	mov    %ebp,%esp
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 38             	sub    $0x38,%esp
  800ebf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecd:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed8:	89 df                	mov    %ebx,%edi
  800eda:	89 de                	mov    %ebx,%esi
  800edc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	7e 28                	jle    800f0a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800eed:	00 
  800eee:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800f05:	e8 e6 0f 00 00       	call   801ef0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f13:	89 ec                	mov    %ebp,%esp
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 38             	sub    $0x38,%esp
  800f1d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f20:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f23:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	89 df                	mov    %ebx,%edi
  800f38:	89 de                	mov    %ebx,%esi
  800f3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	7e 28                	jle    800f68 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800f53:	00 
  800f54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5b:	00 
  800f5c:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800f63:	e8 88 0f 00 00       	call   801ef0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f68:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f71:	89 ec                	mov    %ebp,%esp
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 38             	sub    $0x38,%esp
  800f7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f81:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f89:	b8 09 00 00 00       	mov    $0x9,%eax
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	89 df                	mov    %ebx,%edi
  800f96:	89 de                	mov    %ebx,%esi
  800f98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	7e 28                	jle    800fc6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fa9:	00 
  800faa:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb9:	00 
  800fba:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800fc1:	e8 2a 0f 00 00       	call   801ef0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fcf:	89 ec                	mov    %ebp,%esp
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 38             	sub    $0x38,%esp
  800fd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff2:	89 df                	mov    %ebx,%edi
  800ff4:	89 de                	mov    %ebx,%esi
  800ff6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	7e 28                	jle    801024 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801000:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801007:	00 
  801008:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  80100f:	00 
  801010:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801017:	00 
  801018:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  80101f:	e8 cc 0e 00 00       	call   801ef0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801024:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801027:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80102a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80102d:	89 ec                	mov    %ebp,%esp
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80103a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80103d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801040:	be 00 00 00 00       	mov    $0x0,%esi
  801045:	b8 0c 00 00 00       	mov    $0xc,%eax
  80104a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801050:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
  801056:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801058:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80105b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80105e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801061:	89 ec                	mov    %ebp,%esp
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 38             	sub    $0x38,%esp
  80106b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80106e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801071:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	b9 00 00 00 00       	mov    $0x0,%ecx
  801079:	b8 0d 00 00 00       	mov    $0xd,%eax
  80107e:	8b 55 08             	mov    0x8(%ebp),%edx
  801081:	89 cb                	mov    %ecx,%ebx
  801083:	89 cf                	mov    %ecx,%edi
  801085:	89 ce                	mov    %ecx,%esi
  801087:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	7e 28                	jle    8010b5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801091:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801098:	00 
  801099:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  8010b0:	e8 3b 0e 00 00       	call   801ef0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010be:	89 ec                	mov    %ebp,%esp
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010cb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ce:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	89 cb                	mov    %ecx,%ebx
  8010e0:	89 cf                	mov    %ecx,%edi
  8010e2:	89 ce                	mov    %ecx,%esi
  8010e4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8010e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ef:	89 ec                	mov    %ebp,%esp
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    
	...

00801100 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	05 00 00 00 30       	add    $0x30000000,%eax
  80110b:	c1 e8 0c             	shr    $0xc,%eax
}
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	89 04 24             	mov    %eax,(%esp)
  80111c:	e8 df ff ff ff       	call   801100 <fd2num>
  801121:	05 20 00 0d 00       	add    $0xd0020,%eax
  801126:	c1 e0 0c             	shl    $0xc,%eax
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	53                   	push   %ebx
  80112f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801132:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801137:	a8 01                	test   $0x1,%al
  801139:	74 34                	je     80116f <fd_alloc+0x44>
  80113b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801140:	a8 01                	test   $0x1,%al
  801142:	74 32                	je     801176 <fd_alloc+0x4b>
  801144:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801149:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	c1 ea 16             	shr    $0x16,%edx
  801150:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801157:	f6 c2 01             	test   $0x1,%dl
  80115a:	74 1f                	je     80117b <fd_alloc+0x50>
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	c1 ea 0c             	shr    $0xc,%edx
  801161:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801168:	f6 c2 01             	test   $0x1,%dl
  80116b:	75 17                	jne    801184 <fd_alloc+0x59>
  80116d:	eb 0c                	jmp    80117b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80116f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801174:	eb 05                	jmp    80117b <fd_alloc+0x50>
  801176:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80117b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
  801182:	eb 17                	jmp    80119b <fd_alloc+0x70>
  801184:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801189:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118e:	75 b9                	jne    801149 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801190:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801196:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80119b:	5b                   	pop    %ebx
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a9:	83 fa 1f             	cmp    $0x1f,%edx
  8011ac:	77 3f                	ja     8011ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ae:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8011b4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b7:	89 d0                	mov    %edx,%eax
  8011b9:	c1 e8 16             	shr    $0x16,%eax
  8011bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c8:	f6 c1 01             	test   $0x1,%cl
  8011cb:	74 20                	je     8011ed <fd_lookup+0x4f>
  8011cd:	89 d0                	mov    %edx,%eax
  8011cf:	c1 e8 0c             	shr    $0xc,%eax
  8011d2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011de:	f6 c1 01             	test   $0x1,%cl
  8011e1:	74 0a                	je     8011ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 14             	sub    $0x14,%esp
  8011f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801201:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801207:	75 17                	jne    801220 <dev_lookup+0x31>
  801209:	eb 07                	jmp    801212 <dev_lookup+0x23>
  80120b:	39 0a                	cmp    %ecx,(%edx)
  80120d:	75 11                	jne    801220 <dev_lookup+0x31>
  80120f:	90                   	nop
  801210:	eb 05                	jmp    801217 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801212:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801217:	89 13                	mov    %edx,(%ebx)
			return 0;
  801219:	b8 00 00 00 00       	mov    $0x0,%eax
  80121e:	eb 35                	jmp    801255 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801220:	83 c0 01             	add    $0x1,%eax
  801223:	8b 14 85 88 27 80 00 	mov    0x802788(,%eax,4),%edx
  80122a:	85 d2                	test   %edx,%edx
  80122c:	75 dd                	jne    80120b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122e:	a1 04 40 80 00       	mov    0x804004,%eax
  801233:	8b 40 48             	mov    0x48(%eax),%eax
  801236:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80123a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123e:	c7 04 24 0c 27 80 00 	movl   $0x80270c,(%esp)
  801245:	e8 65 ef ff ff       	call   8001af <cprintf>
	*dev = 0;
  80124a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801255:	83 c4 14             	add    $0x14,%esp
  801258:	5b                   	pop    %ebx
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	83 ec 38             	sub    $0x38,%esp
  801261:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801264:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801267:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80126a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80126d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801271:	89 3c 24             	mov    %edi,(%esp)
  801274:	e8 87 fe ff ff       	call   801100 <fd2num>
  801279:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80127c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	e8 16 ff ff ff       	call   80119e <fd_lookup>
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 05                	js     801293 <fd_close+0x38>
	    || fd != fd2)
  80128e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801291:	74 0e                	je     8012a1 <fd_close+0x46>
		return (must_exist ? r : 0);
  801293:	89 f0                	mov    %esi,%eax
  801295:	84 c0                	test   %al,%al
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
  80129c:	0f 44 d8             	cmove  %eax,%ebx
  80129f:	eb 3d                	jmp    8012de <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a8:	8b 07                	mov    (%edi),%eax
  8012aa:	89 04 24             	mov    %eax,(%esp)
  8012ad:	e8 3d ff ff ff       	call   8011ef <dev_lookup>
  8012b2:	89 c3                	mov    %eax,%ebx
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 16                	js     8012ce <fd_close+0x73>
		if (dev->dev_close)
  8012b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	74 07                	je     8012ce <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8012c7:	89 3c 24             	mov    %edi,(%esp)
  8012ca:	ff d0                	call   *%eax
  8012cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d9:	e8 db fb ff ff       	call   800eb9 <sys_page_unmap>
	return r;
}
  8012de:	89 d8                	mov    %ebx,%eax
  8012e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012e3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012e9:	89 ec                	mov    %ebp,%esp
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fd:	89 04 24             	mov    %eax,(%esp)
  801300:	e8 99 fe ff ff       	call   80119e <fd_lookup>
  801305:	85 c0                	test   %eax,%eax
  801307:	78 13                	js     80131c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801309:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801310:	00 
  801311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801314:	89 04 24             	mov    %eax,(%esp)
  801317:	e8 3f ff ff ff       	call   80125b <fd_close>
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <close_all>:

void
close_all(void)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	53                   	push   %ebx
  801322:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801325:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132a:	89 1c 24             	mov    %ebx,(%esp)
  80132d:	e8 bb ff ff ff       	call   8012ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801332:	83 c3 01             	add    $0x1,%ebx
  801335:	83 fb 20             	cmp    $0x20,%ebx
  801338:	75 f0                	jne    80132a <close_all+0xc>
		close(i);
}
  80133a:	83 c4 14             	add    $0x14,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 58             	sub    $0x58,%esp
  801346:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801349:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80134c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80134f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801352:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801355:	89 44 24 04          	mov    %eax,0x4(%esp)
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	89 04 24             	mov    %eax,(%esp)
  80135f:	e8 3a fe ff ff       	call   80119e <fd_lookup>
  801364:	89 c3                	mov    %eax,%ebx
  801366:	85 c0                	test   %eax,%eax
  801368:	0f 88 e1 00 00 00    	js     80144f <dup+0x10f>
		return r;
	close(newfdnum);
  80136e:	89 3c 24             	mov    %edi,(%esp)
  801371:	e8 77 ff ff ff       	call   8012ed <close>

	newfd = INDEX2FD(newfdnum);
  801376:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80137c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80137f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	e8 86 fd ff ff       	call   801110 <fd2data>
  80138a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80138c:	89 34 24             	mov    %esi,(%esp)
  80138f:	e8 7c fd ff ff       	call   801110 <fd2data>
  801394:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801397:	89 d8                	mov    %ebx,%eax
  801399:	c1 e8 16             	shr    $0x16,%eax
  80139c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a3:	a8 01                	test   $0x1,%al
  8013a5:	74 46                	je     8013ed <dup+0xad>
  8013a7:	89 d8                	mov    %ebx,%eax
  8013a9:	c1 e8 0c             	shr    $0xc,%eax
  8013ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b3:	f6 c2 01             	test   $0x1,%dl
  8013b6:	74 35                	je     8013ed <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013d6:	00 
  8013d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e2:	e8 74 fa ff ff       	call   800e5b <sys_page_map>
  8013e7:	89 c3                	mov    %eax,%ebx
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 3b                	js     801428 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	c1 ea 0c             	shr    $0xc,%edx
  8013f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801402:	89 54 24 10          	mov    %edx,0x10(%esp)
  801406:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80140a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801411:	00 
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
  801416:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141d:	e8 39 fa ff ff       	call   800e5b <sys_page_map>
  801422:	89 c3                	mov    %eax,%ebx
  801424:	85 c0                	test   %eax,%eax
  801426:	79 25                	jns    80144d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801428:	89 74 24 04          	mov    %esi,0x4(%esp)
  80142c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801433:	e8 81 fa ff ff       	call   800eb9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80143b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801446:	e8 6e fa ff ff       	call   800eb9 <sys_page_unmap>
	return r;
  80144b:	eb 02                	jmp    80144f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80144d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801454:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801457:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80145a:	89 ec                	mov    %ebp,%esp
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	53                   	push   %ebx
  801462:	83 ec 24             	sub    $0x24,%esp
  801465:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801468:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	89 1c 24             	mov    %ebx,(%esp)
  801472:	e8 27 fd ff ff       	call   80119e <fd_lookup>
  801477:	85 c0                	test   %eax,%eax
  801479:	78 6d                	js     8014e8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801485:	8b 00                	mov    (%eax),%eax
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 60 fd ff ff       	call   8011ef <dev_lookup>
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 55                	js     8014e8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801496:	8b 50 08             	mov    0x8(%eax),%edx
  801499:	83 e2 03             	and    $0x3,%edx
  80149c:	83 fa 01             	cmp    $0x1,%edx
  80149f:	75 23                	jne    8014c4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a6:	8b 40 48             	mov    0x48(%eax),%eax
  8014a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b1:	c7 04 24 4d 27 80 00 	movl   $0x80274d,(%esp)
  8014b8:	e8 f2 ec ff ff       	call   8001af <cprintf>
		return -E_INVAL;
  8014bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c2:	eb 24                	jmp    8014e8 <read+0x8a>
	}
	if (!dev->dev_read)
  8014c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c7:	8b 52 08             	mov    0x8(%edx),%edx
  8014ca:	85 d2                	test   %edx,%edx
  8014cc:	74 15                	je     8014e3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8014ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	ff d2                	call   *%edx
  8014e1:	eb 05                	jmp    8014e8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8014e8:	83 c4 24             	add    $0x24,%esp
  8014eb:	5b                   	pop    %ebx
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 1c             	sub    $0x1c,%esp
  8014f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801502:	85 f6                	test   %esi,%esi
  801504:	74 30                	je     801536 <readn+0x48>
  801506:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80150b:	89 f2                	mov    %esi,%edx
  80150d:	29 c2                	sub    %eax,%edx
  80150f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801513:	03 45 0c             	add    0xc(%ebp),%eax
  801516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151a:	89 3c 24             	mov    %edi,(%esp)
  80151d:	e8 3c ff ff ff       	call   80145e <read>
		if (m < 0)
  801522:	85 c0                	test   %eax,%eax
  801524:	78 10                	js     801536 <readn+0x48>
			return m;
		if (m == 0)
  801526:	85 c0                	test   %eax,%eax
  801528:	74 0a                	je     801534 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152a:	01 c3                	add    %eax,%ebx
  80152c:	89 d8                	mov    %ebx,%eax
  80152e:	39 f3                	cmp    %esi,%ebx
  801530:	72 d9                	jb     80150b <readn+0x1d>
  801532:	eb 02                	jmp    801536 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801534:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801536:	83 c4 1c             	add    $0x1c,%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5f                   	pop    %edi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 24             	sub    $0x24,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154f:	89 1c 24             	mov    %ebx,(%esp)
  801552:	e8 47 fc ff ff       	call   80119e <fd_lookup>
  801557:	85 c0                	test   %eax,%eax
  801559:	78 68                	js     8015c3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	8b 00                	mov    (%eax),%eax
  801567:	89 04 24             	mov    %eax,(%esp)
  80156a:	e8 80 fc ff ff       	call   8011ef <dev_lookup>
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 50                	js     8015c3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157a:	75 23                	jne    80159f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80157c:	a1 04 40 80 00       	mov    0x804004,%eax
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158c:	c7 04 24 69 27 80 00 	movl   $0x802769,(%esp)
  801593:	e8 17 ec ff ff       	call   8001af <cprintf>
		return -E_INVAL;
  801598:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159d:	eb 24                	jmp    8015c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a5:	85 d2                	test   %edx,%edx
  8015a7:	74 15                	je     8015be <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015b7:	89 04 24             	mov    %eax,(%esp)
  8015ba:	ff d2                	call   *%edx
  8015bc:	eb 05                	jmp    8015c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015c3:	83 c4 24             	add    $0x24,%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d9:	89 04 24             	mov    %eax,(%esp)
  8015dc:	e8 bd fb ff ff       	call   80119e <fd_lookup>
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 0e                	js     8015f3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 24             	sub    $0x24,%esp
  8015fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801602:	89 44 24 04          	mov    %eax,0x4(%esp)
  801606:	89 1c 24             	mov    %ebx,(%esp)
  801609:	e8 90 fb ff ff       	call   80119e <fd_lookup>
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 61                	js     801673 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801615:	89 44 24 04          	mov    %eax,0x4(%esp)
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	8b 00                	mov    (%eax),%eax
  80161e:	89 04 24             	mov    %eax,(%esp)
  801621:	e8 c9 fb ff ff       	call   8011ef <dev_lookup>
  801626:	85 c0                	test   %eax,%eax
  801628:	78 49                	js     801673 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801631:	75 23                	jne    801656 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801633:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801638:	8b 40 48             	mov    0x48(%eax),%eax
  80163b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80163f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801643:	c7 04 24 2c 27 80 00 	movl   $0x80272c,(%esp)
  80164a:	e8 60 eb ff ff       	call   8001af <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801654:	eb 1d                	jmp    801673 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801656:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801659:	8b 52 18             	mov    0x18(%edx),%edx
  80165c:	85 d2                	test   %edx,%edx
  80165e:	74 0e                	je     80166e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801660:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801663:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801667:	89 04 24             	mov    %eax,(%esp)
  80166a:	ff d2                	call   *%edx
  80166c:	eb 05                	jmp    801673 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80166e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801673:	83 c4 24             	add    $0x24,%esp
  801676:	5b                   	pop    %ebx
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	53                   	push   %ebx
  80167d:	83 ec 24             	sub    $0x24,%esp
  801680:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801683:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	89 04 24             	mov    %eax,(%esp)
  801690:	e8 09 fb ff ff       	call   80119e <fd_lookup>
  801695:	85 c0                	test   %eax,%eax
  801697:	78 52                	js     8016eb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801699:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a3:	8b 00                	mov    (%eax),%eax
  8016a5:	89 04 24             	mov    %eax,(%esp)
  8016a8:	e8 42 fb ff ff       	call   8011ef <dev_lookup>
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 3a                	js     8016eb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b8:	74 2c                	je     8016e6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c4:	00 00 00 
	stat->st_isdir = 0;
  8016c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ce:	00 00 00 
	stat->st_dev = dev;
  8016d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016de:	89 14 24             	mov    %edx,(%esp)
  8016e1:	ff 50 14             	call   *0x14(%eax)
  8016e4:	eb 05                	jmp    8016eb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016eb:	83 c4 24             	add    $0x24,%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 18             	sub    $0x18,%esp
  8016f7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016fa:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801704:	00 
  801705:	8b 45 08             	mov    0x8(%ebp),%eax
  801708:	89 04 24             	mov    %eax,(%esp)
  80170b:	e8 bc 01 00 00       	call   8018cc <open>
  801710:	89 c3                	mov    %eax,%ebx
  801712:	85 c0                	test   %eax,%eax
  801714:	78 1b                	js     801731 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801716:	8b 45 0c             	mov    0xc(%ebp),%eax
  801719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171d:	89 1c 24             	mov    %ebx,(%esp)
  801720:	e8 54 ff ff ff       	call   801679 <fstat>
  801725:	89 c6                	mov    %eax,%esi
	close(fd);
  801727:	89 1c 24             	mov    %ebx,(%esp)
  80172a:	e8 be fb ff ff       	call   8012ed <close>
	return r;
  80172f:	89 f3                	mov    %esi,%ebx
}
  801731:	89 d8                	mov    %ebx,%eax
  801733:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801736:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801739:	89 ec                	mov    %ebp,%esp
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    
  80173d:	00 00                	add    %al,(%eax)
	...

00801740 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 18             	sub    $0x18,%esp
  801746:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801749:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801750:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801757:	75 11                	jne    80176a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801759:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801760:	e8 b4 08 00 00       	call   802019 <ipc_find_env>
  801765:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801771:	00 
  801772:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801779:	00 
  80177a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177e:	a1 00 40 80 00       	mov    0x804000,%eax
  801783:	89 04 24             	mov    %eax,(%esp)
  801786:	e8 23 08 00 00       	call   801fae <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80178b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801792:	00 
  801793:	89 74 24 04          	mov    %esi,0x4(%esp)
  801797:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179e:	e8 a5 07 00 00       	call   801f48 <ipc_recv>
}
  8017a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017a6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017a9:	89 ec                	mov    %ebp,%esp
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 14             	sub    $0x14,%esp
  8017b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8017cc:	e8 6f ff ff ff       	call   801740 <fsipc>
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 2b                	js     801800 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017d5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017dc:	00 
  8017dd:	89 1c 24             	mov    %ebx,(%esp)
  8017e0:	e8 16 f1 ff ff       	call   8008fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017e5:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f0:	a1 84 50 80 00       	mov    0x805084,%eax
  8017f5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801800:	83 c4 14             	add    $0x14,%esp
  801803:	5b                   	pop    %ebx
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	8b 40 0c             	mov    0xc(%eax),%eax
  801812:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	b8 06 00 00 00       	mov    $0x6,%eax
  801821:	e8 1a ff ff ff       	call   801740 <fsipc>
}
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	56                   	push   %esi
  80182c:	53                   	push   %ebx
  80182d:	83 ec 10             	sub    $0x10,%esp
  801830:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	8b 40 0c             	mov    0xc(%eax),%eax
  801839:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80183e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801844:	ba 00 00 00 00       	mov    $0x0,%edx
  801849:	b8 03 00 00 00       	mov    $0x3,%eax
  80184e:	e8 ed fe ff ff       	call   801740 <fsipc>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	85 c0                	test   %eax,%eax
  801857:	78 6a                	js     8018c3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801859:	39 c6                	cmp    %eax,%esi
  80185b:	73 24                	jae    801881 <devfile_read+0x59>
  80185d:	c7 44 24 0c 98 27 80 	movl   $0x802798,0xc(%esp)
  801864:	00 
  801865:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  80186c:	00 
  80186d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801874:	00 
  801875:	c7 04 24 b4 27 80 00 	movl   $0x8027b4,(%esp)
  80187c:	e8 6f 06 00 00       	call   801ef0 <_panic>
	assert(r <= PGSIZE);
  801881:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801886:	7e 24                	jle    8018ac <devfile_read+0x84>
  801888:	c7 44 24 0c bf 27 80 	movl   $0x8027bf,0xc(%esp)
  80188f:	00 
  801890:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  801897:	00 
  801898:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80189f:	00 
  8018a0:	c7 04 24 b4 27 80 00 	movl   $0x8027b4,(%esp)
  8018a7:	e8 44 06 00 00       	call   801ef0 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018b7:	00 
  8018b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 29 f2 ff ff       	call   800aec <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  8018c3:	89 d8                	mov    %ebx,%eax
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5e                   	pop    %esi
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 20             	sub    $0x20,%esp
  8018d4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d7:	89 34 24             	mov    %esi,(%esp)
  8018da:	e8 d1 ef ff ff       	call   8008b0 <strlen>
		return -E_BAD_PATH;
  8018df:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e9:	7f 5e                	jg     801949 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 35 f8 ff ff       	call   80112b <fd_alloc>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 4d                	js     801949 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801900:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801907:	e8 ef ef ff ff       	call   8008fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  80190c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801914:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801917:	b8 01 00 00 00       	mov    $0x1,%eax
  80191c:	e8 1f fe ff ff       	call   801740 <fsipc>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	85 c0                	test   %eax,%eax
  801925:	79 15                	jns    80193c <open+0x70>
		fd_close(fd, 0);
  801927:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80192e:	00 
  80192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801932:	89 04 24             	mov    %eax,(%esp)
  801935:	e8 21 f9 ff ff       	call   80125b <fd_close>
		return r;
  80193a:	eb 0d                	jmp    801949 <open+0x7d>
	}

	return fd2num(fd);
  80193c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193f:	89 04 24             	mov    %eax,(%esp)
  801942:	e8 b9 f7 ff ff       	call   801100 <fd2num>
  801947:	89 c3                	mov    %eax,%ebx
}
  801949:	89 d8                	mov    %ebx,%eax
  80194b:	83 c4 20             	add    $0x20,%esp
  80194e:	5b                   	pop    %ebx
  80194f:	5e                   	pop    %esi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    
	...

00801960 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 18             	sub    $0x18,%esp
  801966:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801969:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80196c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	89 04 24             	mov    %eax,(%esp)
  801975:	e8 96 f7 ff ff       	call   801110 <fd2data>
  80197a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80197c:	c7 44 24 04 cb 27 80 	movl   $0x8027cb,0x4(%esp)
  801983:	00 
  801984:	89 34 24             	mov    %esi,(%esp)
  801987:	e8 6f ef ff ff       	call   8008fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198c:	8b 43 04             	mov    0x4(%ebx),%eax
  80198f:	2b 03                	sub    (%ebx),%eax
  801991:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801997:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80199e:	00 00 00 
	stat->st_dev = &devpipe;
  8019a1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  8019a8:	30 80 00 
	return 0;
}
  8019ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019b3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019b6:	89 ec                	mov    %ebp,%esp
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 14             	sub    $0x14,%esp
  8019c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019cf:	e8 e5 f4 ff ff       	call   800eb9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019d4:	89 1c 24             	mov    %ebx,(%esp)
  8019d7:	e8 34 f7 ff ff       	call   801110 <fd2data>
  8019dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e7:	e8 cd f4 ff ff       	call   800eb9 <sys_page_unmap>
}
  8019ec:	83 c4 14             	add    $0x14,%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5d                   	pop    %ebp
  8019f1:	c3                   	ret    

008019f2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	57                   	push   %edi
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 2c             	sub    $0x2c,%esp
  8019fb:	89 c7                	mov    %eax,%edi
  8019fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a00:	a1 04 40 80 00       	mov    0x804004,%eax
  801a05:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a08:	89 3c 24             	mov    %edi,(%esp)
  801a0b:	e8 54 06 00 00       	call   802064 <pageref>
  801a10:	89 c6                	mov    %eax,%esi
  801a12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a15:	89 04 24             	mov    %eax,(%esp)
  801a18:	e8 47 06 00 00       	call   802064 <pageref>
  801a1d:	39 c6                	cmp    %eax,%esi
  801a1f:	0f 94 c0             	sete   %al
  801a22:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a25:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a2b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a2e:	39 cb                	cmp    %ecx,%ebx
  801a30:	75 08                	jne    801a3a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a32:	83 c4 2c             	add    $0x2c,%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5f                   	pop    %edi
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a3a:	83 f8 01             	cmp    $0x1,%eax
  801a3d:	75 c1                	jne    801a00 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3f:	8b 52 58             	mov    0x58(%edx),%edx
  801a42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a46:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a4e:	c7 04 24 d2 27 80 00 	movl   $0x8027d2,(%esp)
  801a55:	e8 55 e7 ff ff       	call   8001af <cprintf>
  801a5a:	eb a4                	jmp    801a00 <_pipeisclosed+0xe>

00801a5c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	57                   	push   %edi
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	83 ec 2c             	sub    $0x2c,%esp
  801a65:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a68:	89 34 24             	mov    %esi,(%esp)
  801a6b:	e8 a0 f6 ff ff       	call   801110 <fd2data>
  801a70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	bf 00 00 00 00       	mov    $0x0,%edi
  801a77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7b:	75 50                	jne    801acd <devpipe_write+0x71>
  801a7d:	eb 5c                	jmp    801adb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7f:	89 da                	mov    %ebx,%edx
  801a81:	89 f0                	mov    %esi,%eax
  801a83:	e8 6a ff ff ff       	call   8019f2 <_pipeisclosed>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	75 53                	jne    801adf <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a8c:	e8 3b f3 ff ff       	call   800dcc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a91:	8b 43 04             	mov    0x4(%ebx),%eax
  801a94:	8b 13                	mov    (%ebx),%edx
  801a96:	83 c2 20             	add    $0x20,%edx
  801a99:	39 d0                	cmp    %edx,%eax
  801a9b:	73 e2                	jae    801a7f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801aa4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801aa7:	89 c2                	mov    %eax,%edx
  801aa9:	c1 fa 1f             	sar    $0x1f,%edx
  801aac:	c1 ea 1b             	shr    $0x1b,%edx
  801aaf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801ab2:	83 e1 1f             	and    $0x1f,%ecx
  801ab5:	29 d1                	sub    %edx,%ecx
  801ab7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801abb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801abf:	83 c0 01             	add    $0x1,%eax
  801ac2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac5:	83 c7 01             	add    $0x1,%edi
  801ac8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801acb:	74 0e                	je     801adb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801acd:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad0:	8b 13                	mov    (%ebx),%edx
  801ad2:	83 c2 20             	add    $0x20,%edx
  801ad5:	39 d0                	cmp    %edx,%eax
  801ad7:	73 a6                	jae    801a7f <devpipe_write+0x23>
  801ad9:	eb c2                	jmp    801a9d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801adb:	89 f8                	mov    %edi,%eax
  801add:	eb 05                	jmp    801ae4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae4:	83 c4 2c             	add    $0x2c,%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5f                   	pop    %edi
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	83 ec 28             	sub    $0x28,%esp
  801af2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801af5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801af8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801afb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801afe:	89 3c 24             	mov    %edi,(%esp)
  801b01:	e8 0a f6 ff ff       	call   801110 <fd2data>
  801b06:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b08:	be 00 00 00 00       	mov    $0x0,%esi
  801b0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b11:	75 47                	jne    801b5a <devpipe_read+0x6e>
  801b13:	eb 52                	jmp    801b67 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b15:	89 f0                	mov    %esi,%eax
  801b17:	eb 5e                	jmp    801b77 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b19:	89 da                	mov    %ebx,%edx
  801b1b:	89 f8                	mov    %edi,%eax
  801b1d:	8d 76 00             	lea    0x0(%esi),%esi
  801b20:	e8 cd fe ff ff       	call   8019f2 <_pipeisclosed>
  801b25:	85 c0                	test   %eax,%eax
  801b27:	75 49                	jne    801b72 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801b29:	e8 9e f2 ff ff       	call   800dcc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b2e:	8b 03                	mov    (%ebx),%eax
  801b30:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b33:	74 e4                	je     801b19 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b35:	89 c2                	mov    %eax,%edx
  801b37:	c1 fa 1f             	sar    $0x1f,%edx
  801b3a:	c1 ea 1b             	shr    $0x1b,%edx
  801b3d:	01 d0                	add    %edx,%eax
  801b3f:	83 e0 1f             	and    $0x1f,%eax
  801b42:	29 d0                	sub    %edx,%eax
  801b44:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b49:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b4f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b52:	83 c6 01             	add    $0x1,%esi
  801b55:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b58:	74 0d                	je     801b67 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801b5a:	8b 03                	mov    (%ebx),%eax
  801b5c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b5f:	75 d4                	jne    801b35 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b61:	85 f6                	test   %esi,%esi
  801b63:	75 b0                	jne    801b15 <devpipe_read+0x29>
  801b65:	eb b2                	jmp    801b19 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b67:	89 f0                	mov    %esi,%eax
  801b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b70:	eb 05                	jmp    801b77 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b80:	89 ec                	mov    %ebp,%esp
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	83 ec 48             	sub    $0x48,%esp
  801b8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b90:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b93:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b96:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b99:	89 04 24             	mov    %eax,(%esp)
  801b9c:	e8 8a f5 ff ff       	call   80112b <fd_alloc>
  801ba1:	89 c3                	mov    %eax,%ebx
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 45 01 00 00    	js     801cf0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bb2:	00 
  801bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc1:	e8 36 f2 ff ff       	call   800dfc <sys_page_alloc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	0f 88 20 01 00 00    	js     801cf0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bd3:	89 04 24             	mov    %eax,(%esp)
  801bd6:	e8 50 f5 ff ff       	call   80112b <fd_alloc>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 f8 00 00 00    	js     801cdd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bec:	00 
  801bed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfb:	e8 fc f1 ff ff       	call   800dfc <sys_page_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	85 c0                	test   %eax,%eax
  801c04:	0f 88 d3 00 00 00    	js     801cdd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0d:	89 04 24             	mov    %eax,(%esp)
  801c10:	e8 fb f4 ff ff       	call   801110 <fd2data>
  801c15:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c17:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c1e:	00 
  801c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2a:	e8 cd f1 ff ff       	call   800dfc <sys_page_alloc>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	85 c0                	test   %eax,%eax
  801c33:	0f 88 91 00 00 00    	js     801cca <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c39:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c3c:	89 04 24             	mov    %eax,(%esp)
  801c3f:	e8 cc f4 ff ff       	call   801110 <fd2data>
  801c44:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c4b:	00 
  801c4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c57:	00 
  801c58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c63:	e8 f3 f1 ff ff       	call   800e5b <sys_page_map>
  801c68:	89 c3                	mov    %eax,%ebx
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	78 4c                	js     801cba <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c6e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c77:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c7c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c83:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c8c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c91:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 5d f4 ff ff       	call   801100 <fd2num>
  801ca3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ca5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ca8:	89 04 24             	mov    %eax,(%esp)
  801cab:	e8 50 f4 ff ff       	call   801100 <fd2num>
  801cb0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb8:	eb 36                	jmp    801cf0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801cba:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc5:	e8 ef f1 ff ff       	call   800eb9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801cca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd8:	e8 dc f1 ff ff       	call   800eb9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ceb:	e8 c9 f1 ff ff       	call   800eb9 <sys_page_unmap>
    err:
	return r;
}
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cf5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cf8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cfb:	89 ec                	mov    %ebp,%esp
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	89 04 24             	mov    %eax,(%esp)
  801d12:	e8 87 f4 ff ff       	call   80119e <fd_lookup>
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 15                	js     801d30 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 ea f3 ff ff       	call   801110 <fd2data>
	return _pipeisclosed(fd, p);
  801d26:	89 c2                	mov    %eax,%edx
  801d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2b:	e8 c2 fc ff ff       	call   8019f2 <_pipeisclosed>
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    
	...

00801d40 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    

00801d4a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d50:	c7 44 24 04 ea 27 80 	movl   $0x8027ea,0x4(%esp)
  801d57:	00 
  801d58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5b:	89 04 24             	mov    %eax,(%esp)
  801d5e:	e8 98 eb ff ff       	call   8008fb <strcpy>
	return 0;
}
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	57                   	push   %edi
  801d6e:	56                   	push   %esi
  801d6f:	53                   	push   %ebx
  801d70:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d76:	be 00 00 00 00       	mov    $0x0,%esi
  801d7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7f:	74 43                	je     801dc4 <devcons_write+0x5a>
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d86:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d8f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d91:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d94:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d99:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801da0:	03 45 0c             	add    0xc(%ebp),%eax
  801da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da7:	89 3c 24             	mov    %edi,(%esp)
  801daa:	e8 3d ed ff ff       	call   800aec <memmove>
		sys_cputs(buf, m);
  801daf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801db3:	89 3c 24             	mov    %edi,(%esp)
  801db6:	e8 25 ef ff ff       	call   800ce0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbb:	01 de                	add    %ebx,%esi
  801dbd:	89 f0                	mov    %esi,%eax
  801dbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc2:	72 c8                	jb     801d8c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801dcc:	5b                   	pop    %ebx
  801dcd:	5e                   	pop    %esi
  801dce:	5f                   	pop    %edi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ddc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de0:	75 07                	jne    801de9 <devcons_read+0x18>
  801de2:	eb 31                	jmp    801e15 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de4:	e8 e3 ef ff ff       	call   800dcc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	e8 1a ef ff ff       	call   800d0f <sys_cgetc>
  801df5:	85 c0                	test   %eax,%eax
  801df7:	74 eb                	je     801de4 <devcons_read+0x13>
  801df9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 16                	js     801e15 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dff:	83 f8 04             	cmp    $0x4,%eax
  801e02:	74 0c                	je     801e10 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801e04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e07:	88 10                	mov    %dl,(%eax)
	return 1;
  801e09:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0e:	eb 05                	jmp    801e15 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e20:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e23:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e2a:	00 
  801e2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2e:	89 04 24             	mov    %eax,(%esp)
  801e31:	e8 aa ee ff ff       	call   800ce0 <sys_cputs>
}
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <getchar>:

int
getchar(void)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e3e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e45:	00 
  801e46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e54:	e8 05 f6 ff ff       	call   80145e <read>
	if (r < 0)
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 0f                	js     801e6c <getchar+0x34>
		return r;
	if (r < 1)
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	7e 06                	jle    801e67 <getchar+0x2f>
		return -E_EOF;
	return c;
  801e61:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e65:	eb 05                	jmp    801e6c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e67:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	89 04 24             	mov    %eax,(%esp)
  801e81:	e8 18 f3 ff ff       	call   80119e <fd_lookup>
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 11                	js     801e9b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e93:	39 10                	cmp    %edx,(%eax)
  801e95:	0f 94 c0             	sete   %al
  801e98:	0f b6 c0             	movzbl %al,%eax
}
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <opencons>:

int
opencons(void)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea6:	89 04 24             	mov    %eax,(%esp)
  801ea9:	e8 7d f2 ff ff       	call   80112b <fd_alloc>
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 3c                	js     801eee <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb9:	00 
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec8:	e8 2f ef ff ff       	call   800dfc <sys_page_alloc>
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 1d                	js     801eee <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eda:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 12 f2 ff ff       	call   801100 <fd2num>
}
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	56                   	push   %esi
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801ef8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801efb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801f01:	e8 96 ee ff ff       	call   800d9c <sys_getenvid>
  801f06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f09:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  801f10:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f14:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1c:	c7 04 24 f8 27 80 00 	movl   $0x8027f8,(%esp)
  801f23:	e8 87 e2 ff ff       	call   8001af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f2f:	89 04 24             	mov    %eax,(%esp)
  801f32:	e8 17 e2 ff ff       	call   80014e <vcprintf>
	cprintf("\n");
  801f37:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
  801f3e:	e8 6c e2 ff ff       	call   8001af <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f43:	cc                   	int3   
  801f44:	eb fd                	jmp    801f43 <_panic+0x53>
	...

00801f48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 10             	sub    $0x10,%esp
  801f50:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f56:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f59:	85 db                	test   %ebx,%ebx
  801f5b:	74 06                	je     801f63 <ipc_recv+0x1b>
  801f5d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801f63:	85 f6                	test   %esi,%esi
  801f65:	74 06                	je     801f6d <ipc_recv+0x25>
  801f67:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f74:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f77:	89 04 24             	mov    %eax,(%esp)
  801f7a:	e8 e6 f0 ff ff       	call   801065 <sys_ipc_recv>
    if (ret) return ret;
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	75 24                	jne    801fa7 <ipc_recv+0x5f>
    if (from_env_store)
  801f83:	85 db                	test   %ebx,%ebx
  801f85:	74 0a                	je     801f91 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f87:	a1 04 40 80 00       	mov    0x804004,%eax
  801f8c:	8b 40 74             	mov    0x74(%eax),%eax
  801f8f:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f91:	85 f6                	test   %esi,%esi
  801f93:	74 0a                	je     801f9f <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f95:	a1 04 40 80 00       	mov    0x804004,%eax
  801f9a:	8b 40 78             	mov    0x78(%eax),%eax
  801f9d:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	5b                   	pop    %ebx
  801fab:	5e                   	pop    %esi
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    

00801fae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 75 08             	mov    0x8(%ebp),%esi
  801fba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801fc0:	85 db                	test   %ebx,%ebx
  801fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fc7:	0f 44 d8             	cmove  %eax,%ebx
  801fca:	eb 2a                	jmp    801ff6 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801fcc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcf:	74 20                	je     801ff1 <ipc_send+0x43>
  801fd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd5:	c7 44 24 08 1c 28 80 	movl   $0x80281c,0x8(%esp)
  801fdc:	00 
  801fdd:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801fe4:	00 
  801fe5:	c7 04 24 33 28 80 00 	movl   $0x802833,(%esp)
  801fec:	e8 ff fe ff ff       	call   801ef0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801ff1:	e8 d6 ed ff ff       	call   800dcc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ff6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802001:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802005:	89 34 24             	mov    %esi,(%esp)
  802008:	e8 24 f0 ff ff       	call   801031 <sys_ipc_try_send>
  80200d:	85 c0                	test   %eax,%eax
  80200f:	75 bb                	jne    801fcc <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802011:	83 c4 1c             	add    $0x1c,%esp
  802014:	5b                   	pop    %ebx
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80201f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802024:	39 c8                	cmp    %ecx,%eax
  802026:	74 19                	je     802041 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802028:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80202d:	89 c2                	mov    %eax,%edx
  80202f:	c1 e2 07             	shl    $0x7,%edx
  802032:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802038:	8b 52 50             	mov    0x50(%edx),%edx
  80203b:	39 ca                	cmp    %ecx,%edx
  80203d:	75 14                	jne    802053 <ipc_find_env+0x3a>
  80203f:	eb 05                	jmp    802046 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802041:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802046:	c1 e0 07             	shl    $0x7,%eax
  802049:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80204e:	8b 40 40             	mov    0x40(%eax),%eax
  802051:	eb 0e                	jmp    802061 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802053:	83 c0 01             	add    $0x1,%eax
  802056:	3d 00 04 00 00       	cmp    $0x400,%eax
  80205b:	75 d0                	jne    80202d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80205d:	66 b8 00 00          	mov    $0x0,%ax
}
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    
	...

00802064 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206a:	89 d0                	mov    %edx,%eax
  80206c:	c1 e8 16             	shr    $0x16,%eax
  80206f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802076:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207b:	f6 c1 01             	test   $0x1,%cl
  80207e:	74 1d                	je     80209d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802080:	c1 ea 0c             	shr    $0xc,%edx
  802083:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80208a:	f6 c2 01             	test   $0x1,%dl
  80208d:	74 0e                	je     80209d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80208f:	c1 ea 0c             	shr    $0xc,%edx
  802092:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802099:	ef 
  80209a:	0f b7 c0             	movzwl %ax,%eax
}
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    
	...

008020a0 <__udivdi3>:
  8020a0:	83 ec 1c             	sub    $0x1c,%esp
  8020a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8020a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8020ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8020af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8020b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8020c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c5:	89 cd                	mov    %ecx,%ebp
  8020c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cb:	75 33                	jne    802100 <__udivdi3+0x60>
  8020cd:	39 f1                	cmp    %esi,%ecx
  8020cf:	77 57                	ja     802128 <__udivdi3+0x88>
  8020d1:	85 c9                	test   %ecx,%ecx
  8020d3:	75 0b                	jne    8020e0 <__udivdi3+0x40>
  8020d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020da:	31 d2                	xor    %edx,%edx
  8020dc:	f7 f1                	div    %ecx
  8020de:	89 c1                	mov    %eax,%ecx
  8020e0:	89 f0                	mov    %esi,%eax
  8020e2:	31 d2                	xor    %edx,%edx
  8020e4:	f7 f1                	div    %ecx
  8020e6:	89 c6                	mov    %eax,%esi
  8020e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020ec:	f7 f1                	div    %ecx
  8020ee:	89 f2                	mov    %esi,%edx
  8020f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020fc:	83 c4 1c             	add    $0x1c,%esp
  8020ff:	c3                   	ret    
  802100:	31 d2                	xor    %edx,%edx
  802102:	31 c0                	xor    %eax,%eax
  802104:	39 f7                	cmp    %esi,%edi
  802106:	77 e8                	ja     8020f0 <__udivdi3+0x50>
  802108:	0f bd cf             	bsr    %edi,%ecx
  80210b:	83 f1 1f             	xor    $0x1f,%ecx
  80210e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802112:	75 2c                	jne    802140 <__udivdi3+0xa0>
  802114:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802118:	76 04                	jbe    80211e <__udivdi3+0x7e>
  80211a:	39 f7                	cmp    %esi,%edi
  80211c:	73 d2                	jae    8020f0 <__udivdi3+0x50>
  80211e:	31 d2                	xor    %edx,%edx
  802120:	b8 01 00 00 00       	mov    $0x1,%eax
  802125:	eb c9                	jmp    8020f0 <__udivdi3+0x50>
  802127:	90                   	nop
  802128:	89 f2                	mov    %esi,%edx
  80212a:	f7 f1                	div    %ecx
  80212c:	31 d2                	xor    %edx,%edx
  80212e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802132:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802136:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	c3                   	ret    
  80213e:	66 90                	xchg   %ax,%ax
  802140:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802145:	b8 20 00 00 00       	mov    $0x20,%eax
  80214a:	89 ea                	mov    %ebp,%edx
  80214c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802150:	d3 e7                	shl    %cl,%edi
  802152:	89 c1                	mov    %eax,%ecx
  802154:	d3 ea                	shr    %cl,%edx
  802156:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80215b:	09 fa                	or     %edi,%edx
  80215d:	89 f7                	mov    %esi,%edi
  80215f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802163:	89 f2                	mov    %esi,%edx
  802165:	8b 74 24 08          	mov    0x8(%esp),%esi
  802169:	d3 e5                	shl    %cl,%ebp
  80216b:	89 c1                	mov    %eax,%ecx
  80216d:	d3 ef                	shr    %cl,%edi
  80216f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802174:	d3 e2                	shl    %cl,%edx
  802176:	89 c1                	mov    %eax,%ecx
  802178:	d3 ee                	shr    %cl,%esi
  80217a:	09 d6                	or     %edx,%esi
  80217c:	89 fa                	mov    %edi,%edx
  80217e:	89 f0                	mov    %esi,%eax
  802180:	f7 74 24 0c          	divl   0xc(%esp)
  802184:	89 d7                	mov    %edx,%edi
  802186:	89 c6                	mov    %eax,%esi
  802188:	f7 e5                	mul    %ebp
  80218a:	39 d7                	cmp    %edx,%edi
  80218c:	72 22                	jb     8021b0 <__udivdi3+0x110>
  80218e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802192:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802197:	d3 e5                	shl    %cl,%ebp
  802199:	39 c5                	cmp    %eax,%ebp
  80219b:	73 04                	jae    8021a1 <__udivdi3+0x101>
  80219d:	39 d7                	cmp    %edx,%edi
  80219f:	74 0f                	je     8021b0 <__udivdi3+0x110>
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	e9 46 ff ff ff       	jmp    8020f0 <__udivdi3+0x50>
  8021aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	c3                   	ret    
	...

008021d0 <__umoddi3>:
  8021d0:	83 ec 1c             	sub    $0x1c,%esp
  8021d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8021d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8021db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8021df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8021e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021eb:	85 ed                	test   %ebp,%ebp
  8021ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021f5:	89 cf                	mov    %ecx,%edi
  8021f7:	89 04 24             	mov    %eax,(%esp)
  8021fa:	89 f2                	mov    %esi,%edx
  8021fc:	75 1a                	jne    802218 <__umoddi3+0x48>
  8021fe:	39 f1                	cmp    %esi,%ecx
  802200:	76 4e                	jbe    802250 <__umoddi3+0x80>
  802202:	f7 f1                	div    %ecx
  802204:	89 d0                	mov    %edx,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	8b 74 24 10          	mov    0x10(%esp),%esi
  80220c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802210:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	c3                   	ret    
  802218:	39 f5                	cmp    %esi,%ebp
  80221a:	77 54                	ja     802270 <__umoddi3+0xa0>
  80221c:	0f bd c5             	bsr    %ebp,%eax
  80221f:	83 f0 1f             	xor    $0x1f,%eax
  802222:	89 44 24 04          	mov    %eax,0x4(%esp)
  802226:	75 60                	jne    802288 <__umoddi3+0xb8>
  802228:	3b 0c 24             	cmp    (%esp),%ecx
  80222b:	0f 87 07 01 00 00    	ja     802338 <__umoddi3+0x168>
  802231:	89 f2                	mov    %esi,%edx
  802233:	8b 34 24             	mov    (%esp),%esi
  802236:	29 ce                	sub    %ecx,%esi
  802238:	19 ea                	sbb    %ebp,%edx
  80223a:	89 34 24             	mov    %esi,(%esp)
  80223d:	8b 04 24             	mov    (%esp),%eax
  802240:	8b 74 24 10          	mov    0x10(%esp),%esi
  802244:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802248:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80224c:	83 c4 1c             	add    $0x1c,%esp
  80224f:	c3                   	ret    
  802250:	85 c9                	test   %ecx,%ecx
  802252:	75 0b                	jne    80225f <__umoddi3+0x8f>
  802254:	b8 01 00 00 00       	mov    $0x1,%eax
  802259:	31 d2                	xor    %edx,%edx
  80225b:	f7 f1                	div    %ecx
  80225d:	89 c1                	mov    %eax,%ecx
  80225f:	89 f0                	mov    %esi,%eax
  802261:	31 d2                	xor    %edx,%edx
  802263:	f7 f1                	div    %ecx
  802265:	8b 04 24             	mov    (%esp),%eax
  802268:	f7 f1                	div    %ecx
  80226a:	eb 98                	jmp    802204 <__umoddi3+0x34>
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 f2                	mov    %esi,%edx
  802272:	8b 74 24 10          	mov    0x10(%esp),%esi
  802276:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80227a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80227e:	83 c4 1c             	add    $0x1c,%esp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80228d:	89 e8                	mov    %ebp,%eax
  80228f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802294:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802298:	89 fa                	mov    %edi,%edx
  80229a:	d3 e0                	shl    %cl,%eax
  80229c:	89 e9                	mov    %ebp,%ecx
  80229e:	d3 ea                	shr    %cl,%edx
  8022a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022a5:	09 c2                	or     %eax,%edx
  8022a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ab:	89 14 24             	mov    %edx,(%esp)
  8022ae:	89 f2                	mov    %esi,%edx
  8022b0:	d3 e7                	shl    %cl,%edi
  8022b2:	89 e9                	mov    %ebp,%ecx
  8022b4:	d3 ea                	shr    %cl,%edx
  8022b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022bf:	d3 e6                	shl    %cl,%esi
  8022c1:	89 e9                	mov    %ebp,%ecx
  8022c3:	d3 e8                	shr    %cl,%eax
  8022c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022ca:	09 f0                	or     %esi,%eax
  8022cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022d0:	f7 34 24             	divl   (%esp)
  8022d3:	d3 e6                	shl    %cl,%esi
  8022d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022d9:	89 d6                	mov    %edx,%esi
  8022db:	f7 e7                	mul    %edi
  8022dd:	39 d6                	cmp    %edx,%esi
  8022df:	89 c1                	mov    %eax,%ecx
  8022e1:	89 d7                	mov    %edx,%edi
  8022e3:	72 3f                	jb     802324 <__umoddi3+0x154>
  8022e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022e9:	72 35                	jb     802320 <__umoddi3+0x150>
  8022eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ef:	29 c8                	sub    %ecx,%eax
  8022f1:	19 fe                	sbb    %edi,%esi
  8022f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022f8:	89 f2                	mov    %esi,%edx
  8022fa:	d3 e8                	shr    %cl,%eax
  8022fc:	89 e9                	mov    %ebp,%ecx
  8022fe:	d3 e2                	shl    %cl,%edx
  802300:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802305:	09 d0                	or     %edx,%eax
  802307:	89 f2                	mov    %esi,%edx
  802309:	d3 ea                	shr    %cl,%edx
  80230b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80230f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802313:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802317:	83 c4 1c             	add    $0x1c,%esp
  80231a:	c3                   	ret    
  80231b:	90                   	nop
  80231c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802320:	39 d6                	cmp    %edx,%esi
  802322:	75 c7                	jne    8022eb <__umoddi3+0x11b>
  802324:	89 d7                	mov    %edx,%edi
  802326:	89 c1                	mov    %eax,%ecx
  802328:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80232c:	1b 3c 24             	sbb    (%esp),%edi
  80232f:	eb ba                	jmp    8022eb <__umoddi3+0x11b>
  802331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802338:	39 f5                	cmp    %esi,%ebp
  80233a:	0f 82 f1 fe ff ff    	jb     802231 <__umoddi3+0x61>
  802340:	e9 f8 fe ff ff       	jmp    80223d <__umoddi3+0x6d>
