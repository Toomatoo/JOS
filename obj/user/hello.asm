
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
  80003a:	c7 04 24 78 10 80 00 	movl   $0x801078,(%esp)
  800041:	e8 09 01 00 00       	call   80014f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 08 20 80 00       	mov    0x802008,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 86 10 80 00 	movl   $0x801086,(%esp)
  800059:	e8 f1 00 00 00       	call   80014f <cprintf>
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
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	89 54 24 04          	mov    %edx,0x4(%esp)
  800086:	89 04 24             	mov    %eax,(%esp)
  800089:	e8 a6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008e:	e8 05 00 00 00       	call   800098 <exit>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 35 0c 00 00       	call   800cdf <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 03                	mov    (%ebx),%eax
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000bf:	83 c0 01             	add    $0x1,%eax
  8000c2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c9:	75 19                	jne    8000e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d6:	89 04 24             	mov    %eax,(%esp)
  8000d9:	e8 a2 0b 00 00       	call   800c80 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e8:	83 c4 14             	add    $0x14,%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fe:	00 00 00 
	b.cnt = 0;
  800101:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800108:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 08          	mov    %eax,0x8(%esp)
  800119:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	c7 04 24 ac 00 80 00 	movl   $0x8000ac,(%esp)
  80012a:	e8 97 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	89 04 24             	mov    %eax,(%esp)
  800142:	e8 39 0b 00 00       	call   800c80 <sys_cputs>

	return b.cnt;
}
  800147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800155:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 87 ff ff ff       	call   8000ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 3c             	sub    $0x3c,%esp
  800175:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800178:	89 d7                	mov    %edx,%edi
  80017a:	8b 45 08             	mov    0x8(%ebp),%eax
  80017d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800180:	8b 45 0c             	mov    0xc(%ebp),%eax
  800183:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800186:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800189:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018c:	b8 00 00 00 00       	mov    $0x0,%eax
  800191:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800194:	72 11                	jb     8001a7 <printnum+0x3b>
  800196:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800199:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019c:	76 09                	jbe    8001a7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80019e:	83 eb 01             	sub    $0x1,%ebx
  8001a1:	85 db                	test   %ebx,%ebx
  8001a3:	7f 51                	jg     8001f6 <printnum+0x8a>
  8001a5:	eb 5e                	jmp    800205 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001ab:	83 eb 01             	sub    $0x1,%ebx
  8001ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001bd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c8:	00 
  8001c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d6:	e8 f5 0b 00 00       	call   800dd0 <__udivdi3>
  8001db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001df:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ea:	89 fa                	mov    %edi,%edx
  8001ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ef:	e8 78 ff ff ff       	call   80016c <printnum>
  8001f4:	eb 0f                	jmp    800205 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fa:	89 34 24             	mov    %esi,(%esp)
  8001fd:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800200:	83 eb 01             	sub    $0x1,%ebx
  800203:	75 f1                	jne    8001f6 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800205:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800209:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80020d:	8b 45 10             	mov    0x10(%ebp),%eax
  800210:	89 44 24 08          	mov    %eax,0x8(%esp)
  800214:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021b:	00 
  80021c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021f:	89 04 24             	mov    %eax,(%esp)
  800222:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800225:	89 44 24 04          	mov    %eax,0x4(%esp)
  800229:	e8 d2 0c 00 00       	call   800f00 <__umoddi3>
  80022e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800232:	0f be 80 a7 10 80 00 	movsbl 0x8010a7(%eax),%eax
  800239:	89 04 24             	mov    %eax,(%esp)
  80023c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80023f:	83 c4 3c             	add    $0x3c,%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024a:	83 fa 01             	cmp    $0x1,%edx
  80024d:	7e 0e                	jle    80025d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024f:	8b 10                	mov    (%eax),%edx
  800251:	8d 4a 08             	lea    0x8(%edx),%ecx
  800254:	89 08                	mov    %ecx,(%eax)
  800256:	8b 02                	mov    (%edx),%eax
  800258:	8b 52 04             	mov    0x4(%edx),%edx
  80025b:	eb 22                	jmp    80027f <getuint+0x38>
	else if (lflag)
  80025d:	85 d2                	test   %edx,%edx
  80025f:	74 10                	je     800271 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800261:	8b 10                	mov    (%eax),%edx
  800263:	8d 4a 04             	lea    0x4(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 02                	mov    (%edx),%eax
  80026a:	ba 00 00 00 00       	mov    $0x0,%edx
  80026f:	eb 0e                	jmp    80027f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800287:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	3b 50 04             	cmp    0x4(%eax),%edx
  800290:	73 0a                	jae    80029c <sprintputch+0x1b>
		*b->buf++ = ch;
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 0a                	mov    %cl,(%edx)
  800297:	83 c2 01             	add    $0x1,%edx
  80029a:	89 10                	mov    %edx,(%eax)
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 02 00 00 00       	call   8002c6 <vprintfmt>
	va_end(ap);
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 5c             	sub    $0x5c,%esp
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d5:	eb 12                	jmp    8002e9 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	0f 84 e4 04 00 00    	je     8007c3 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	0f b6 06             	movzbl (%esi),%eax
  8002ec:	83 c6 01             	add    $0x1,%esi
  8002ef:	83 f8 25             	cmp    $0x25,%eax
  8002f2:	75 e3                	jne    8002d7 <vprintfmt+0x11>
  8002f4:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8002f8:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002ff:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800304:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80030b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800310:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800313:	eb 2b                	jmp    800340 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800318:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80031c:	eb 22                	jmp    800340 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800321:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800325:	eb 19                	jmp    800340 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80032a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800331:	eb 0d                	jmp    800340 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800333:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800336:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800339:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	0f b6 06             	movzbl (%esi),%eax
  800343:	0f b6 d0             	movzbl %al,%edx
  800346:	8d 7e 01             	lea    0x1(%esi),%edi
  800349:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80034c:	83 e8 23             	sub    $0x23,%eax
  80034f:	3c 55                	cmp    $0x55,%al
  800351:	0f 87 46 04 00 00    	ja     80079d <vprintfmt+0x4d7>
  800357:	0f b6 c0             	movzbl %al,%eax
  80035a:	ff 24 85 4c 11 80 00 	jmp    *0x80114c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800361:	83 ea 30             	sub    $0x30,%edx
  800364:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800367:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80036b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800371:	83 fa 09             	cmp    $0x9,%edx
  800374:	77 4a                	ja     8003c0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800379:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80037c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80037f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800383:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800386:	8d 50 d0             	lea    -0x30(%eax),%edx
  800389:	83 fa 09             	cmp    $0x9,%edx
  80038c:	76 eb                	jbe    800379 <vprintfmt+0xb3>
  80038e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800391:	eb 2d                	jmp    8003c0 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 50 04             	lea    0x4(%eax),%edx
  800399:	89 55 14             	mov    %edx,0x14(%ebp)
  80039c:	8b 00                	mov    (%eax),%eax
  80039e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a4:	eb 1a                	jmp    8003c0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003a9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003ad:	79 91                	jns    800340 <vprintfmt+0x7a>
  8003af:	e9 73 ff ff ff       	jmp    800327 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003be:	eb 80                	jmp    800340 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003c0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003c4:	0f 89 76 ff ff ff    	jns    800340 <vprintfmt+0x7a>
  8003ca:	e9 64 ff ff ff       	jmp    800333 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cf:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d5:	e9 66 ff ff ff       	jmp    800340 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 50 04             	lea    0x4(%eax),%edx
  8003e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	89 04 24             	mov    %eax,(%esp)
  8003ec:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f2:	e9 f2 fe ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8003f7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8003fb:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8003fe:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800402:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800405:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800409:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80040c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80040f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800413:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800416:	80 f9 09             	cmp    $0x9,%cl
  800419:	77 1d                	ja     800438 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80041b:	0f be c0             	movsbl %al,%eax
  80041e:	6b c0 64             	imul   $0x64,%eax,%eax
  800421:	0f be d2             	movsbl %dl,%edx
  800424:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800427:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80042e:	a3 04 20 80 00       	mov    %eax,0x802004
  800433:	e9 b1 fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800438:	c7 44 24 04 bf 10 80 	movl   $0x8010bf,0x4(%esp)
  80043f:	00 
  800440:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	e8 10 05 00 00       	call   80095b <strcmp>
  80044b:	85 c0                	test   %eax,%eax
  80044d:	75 0f                	jne    80045e <vprintfmt+0x198>
  80044f:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800456:	00 00 00 
  800459:	e9 8b fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80045e:	c7 44 24 04 c3 10 80 	movl   $0x8010c3,0x4(%esp)
  800465:	00 
  800466:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800469:	89 14 24             	mov    %edx,(%esp)
  80046c:	e8 ea 04 00 00       	call   80095b <strcmp>
  800471:	85 c0                	test   %eax,%eax
  800473:	75 0f                	jne    800484 <vprintfmt+0x1be>
  800475:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  80047c:	00 00 00 
  80047f:	e9 65 fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800484:	c7 44 24 04 c7 10 80 	movl   $0x8010c7,0x4(%esp)
  80048b:	00 
  80048c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80048f:	89 0c 24             	mov    %ecx,(%esp)
  800492:	e8 c4 04 00 00       	call   80095b <strcmp>
  800497:	85 c0                	test   %eax,%eax
  800499:	75 0f                	jne    8004aa <vprintfmt+0x1e4>
  80049b:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004a2:	00 00 00 
  8004a5:	e9 3f fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004aa:	c7 44 24 04 cb 10 80 	movl   $0x8010cb,0x4(%esp)
  8004b1:	00 
  8004b2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004b5:	89 3c 24             	mov    %edi,(%esp)
  8004b8:	e8 9e 04 00 00       	call   80095b <strcmp>
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	75 0f                	jne    8004d0 <vprintfmt+0x20a>
  8004c1:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004c8:	00 00 00 
  8004cb:	e9 19 fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004d0:	c7 44 24 04 cf 10 80 	movl   $0x8010cf,0x4(%esp)
  8004d7:	00 
  8004d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004db:	89 04 24             	mov    %eax,(%esp)
  8004de:	e8 78 04 00 00       	call   80095b <strcmp>
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	75 0f                	jne    8004f6 <vprintfmt+0x230>
  8004e7:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8004ee:	00 00 00 
  8004f1:	e9 f3 fd ff ff       	jmp    8002e9 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8004f6:	c7 44 24 04 d3 10 80 	movl   $0x8010d3,0x4(%esp)
  8004fd:	00 
  8004fe:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800501:	89 14 24             	mov    %edx,(%esp)
  800504:	e8 52 04 00 00       	call   80095b <strcmp>
  800509:	83 f8 01             	cmp    $0x1,%eax
  80050c:	19 c0                	sbb    %eax,%eax
  80050e:	f7 d0                	not    %eax
  800510:	83 c0 08             	add    $0x8,%eax
  800513:	a3 04 20 80 00       	mov    %eax,0x802004
  800518:	e9 cc fd ff ff       	jmp    8002e9 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 50 04             	lea    0x4(%eax),%edx
  800523:	89 55 14             	mov    %edx,0x14(%ebp)
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 c2                	mov    %eax,%edx
  80052a:	c1 fa 1f             	sar    $0x1f,%edx
  80052d:	31 d0                	xor    %edx,%eax
  80052f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800531:	83 f8 06             	cmp    $0x6,%eax
  800534:	7f 0b                	jg     800541 <vprintfmt+0x27b>
  800536:	8b 14 85 a4 12 80 00 	mov    0x8012a4(,%eax,4),%edx
  80053d:	85 d2                	test   %edx,%edx
  80053f:	75 23                	jne    800564 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800541:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800545:	c7 44 24 08 d7 10 80 	movl   $0x8010d7,0x8(%esp)
  80054c:	00 
  80054d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800551:	8b 7d 08             	mov    0x8(%ebp),%edi
  800554:	89 3c 24             	mov    %edi,(%esp)
  800557:	e8 42 fd ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80055f:	e9 85 fd ff ff       	jmp    8002e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800564:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800568:	c7 44 24 08 e0 10 80 	movl   $0x8010e0,0x8(%esp)
  80056f:	00 
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	8b 7d 08             	mov    0x8(%ebp),%edi
  800577:	89 3c 24             	mov    %edi,(%esp)
  80057a:	e8 1f fd ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800582:	e9 62 fd ff ff       	jmp    8002e9 <vprintfmt+0x23>
  800587:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80058a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80058d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80059b:	85 f6                	test   %esi,%esi
  80059d:	b8 b8 10 80 00       	mov    $0x8010b8,%eax
  8005a2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005a5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005a9:	7e 06                	jle    8005b1 <vprintfmt+0x2eb>
  8005ab:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005af:	75 13                	jne    8005c4 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b1:	0f be 06             	movsbl (%esi),%eax
  8005b4:	83 c6 01             	add    $0x1,%esi
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	0f 85 94 00 00 00    	jne    800653 <vprintfmt+0x38d>
  8005bf:	e9 81 00 00 00       	jmp    800645 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c8:	89 34 24             	mov    %esi,(%esp)
  8005cb:	e8 9b 02 00 00       	call   80086b <strnlen>
  8005d0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005d3:	29 c2                	sub    %eax,%edx
  8005d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	7e d5                	jle    8005b1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005dc:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8005e0:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005e3:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8005e6:	89 d6                	mov    %edx,%esi
  8005e8:	89 cf                	mov    %ecx,%edi
  8005ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ee:	89 3c 24             	mov    %edi,(%esp)
  8005f1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	75 f1                	jne    8005ea <vprintfmt+0x324>
  8005f9:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8005fc:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8005ff:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800602:	eb ad                	jmp    8005b1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800604:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800608:	74 1b                	je     800625 <vprintfmt+0x35f>
  80060a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80060d:	83 fa 5e             	cmp    $0x5e,%edx
  800610:	76 13                	jbe    800625 <vprintfmt+0x35f>
					putch('?', putdat);
  800612:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800615:	89 44 24 04          	mov    %eax,0x4(%esp)
  800619:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
  800623:	eb 0d                	jmp    800632 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800625:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800628:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800632:	83 eb 01             	sub    $0x1,%ebx
  800635:	0f be 06             	movsbl (%esi),%eax
  800638:	83 c6 01             	add    $0x1,%esi
  80063b:	85 c0                	test   %eax,%eax
  80063d:	75 1a                	jne    800659 <vprintfmt+0x393>
  80063f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800642:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800648:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80064c:	7f 1c                	jg     80066a <vprintfmt+0x3a4>
  80064e:	e9 96 fc ff ff       	jmp    8002e9 <vprintfmt+0x23>
  800653:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800656:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800659:	85 ff                	test   %edi,%edi
  80065b:	78 a7                	js     800604 <vprintfmt+0x33e>
  80065d:	83 ef 01             	sub    $0x1,%edi
  800660:	79 a2                	jns    800604 <vprintfmt+0x33e>
  800662:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800665:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800668:	eb db                	jmp    800645 <vprintfmt+0x37f>
  80066a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066d:	89 de                	mov    %ebx,%esi
  80066f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800672:	89 74 24 04          	mov    %esi,0x4(%esp)
  800676:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067f:	83 eb 01             	sub    $0x1,%ebx
  800682:	75 ee                	jne    800672 <vprintfmt+0x3ac>
  800684:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800689:	e9 5b fc ff ff       	jmp    8002e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068e:	83 f9 01             	cmp    $0x1,%ecx
  800691:	7e 10                	jle    8006a3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 08             	lea    0x8(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)
  80069c:	8b 30                	mov    (%eax),%esi
  80069e:	8b 78 04             	mov    0x4(%eax),%edi
  8006a1:	eb 26                	jmp    8006c9 <vprintfmt+0x403>
	else if (lflag)
  8006a3:	85 c9                	test   %ecx,%ecx
  8006a5:	74 12                	je     8006b9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 30                	mov    (%eax),%esi
  8006b2:	89 f7                	mov    %esi,%edi
  8006b4:	c1 ff 1f             	sar    $0x1f,%edi
  8006b7:	eb 10                	jmp    8006c9 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8d 50 04             	lea    0x4(%eax),%edx
  8006bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c2:	8b 30                	mov    (%eax),%esi
  8006c4:	89 f7                	mov    %esi,%edi
  8006c6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c9:	85 ff                	test   %edi,%edi
  8006cb:	78 0e                	js     8006db <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d1:	be 0a 00 00 00       	mov    $0xa,%esi
  8006d6:	e9 84 00 00 00       	jmp    80075f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006e6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006e9:	89 f0                	mov    %esi,%eax
  8006eb:	89 fa                	mov    %edi,%edx
  8006ed:	f7 d8                	neg    %eax
  8006ef:	83 d2 00             	adc    $0x0,%edx
  8006f2:	f7 da                	neg    %edx
			}
			base = 10;
  8006f4:	be 0a 00 00 00       	mov    $0xa,%esi
  8006f9:	eb 64                	jmp    80075f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006fb:	89 ca                	mov    %ecx,%edx
  8006fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800700:	e8 42 fb ff ff       	call   800247 <getuint>
			base = 10;
  800705:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80070a:	eb 53                	jmp    80075f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80070c:	89 ca                	mov    %ecx,%edx
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
  800711:	e8 31 fb ff ff       	call   800247 <getuint>
    			base = 8;
  800716:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80071b:	eb 42                	jmp    80075f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80071d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800721:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800728:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80072b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800736:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8d 50 04             	lea    0x4(%eax),%edx
  80073f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800742:	8b 00                	mov    (%eax),%eax
  800744:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800749:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80074e:	eb 0f                	jmp    80075f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800750:	89 ca                	mov    %ecx,%edx
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
  800755:	e8 ed fa ff ff       	call   800247 <getuint>
			base = 16;
  80075a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800763:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800767:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80076a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80076e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800772:	89 04 24             	mov    %eax,(%esp)
  800775:	89 54 24 04          	mov    %edx,0x4(%esp)
  800779:	89 da                	mov    %ebx,%edx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	e8 e9 f9 ff ff       	call   80016c <printnum>
			break;
  800783:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800786:	e9 5e fb ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078f:	89 14 24             	mov    %edx,(%esp)
  800792:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800795:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800798:	e9 4c fb ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007af:	0f 84 34 fb ff ff    	je     8002e9 <vprintfmt+0x23>
  8007b5:	83 ee 01             	sub    $0x1,%esi
  8007b8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007bc:	75 f7                	jne    8007b5 <vprintfmt+0x4ef>
  8007be:	e9 26 fb ff ff       	jmp    8002e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007c3:	83 c4 5c             	add    $0x5c,%esp
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5f                   	pop    %edi
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	83 ec 28             	sub    $0x28,%esp
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	74 30                	je     80081c <vsnprintf+0x51>
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	7e 2c                	jle    80081c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800801:	89 44 24 04          	mov    %eax,0x4(%esp)
  800805:	c7 04 24 81 02 80 00 	movl   $0x800281,(%esp)
  80080c:	e8 b5 fa ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800811:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800814:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800817:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800830:	8b 45 10             	mov    0x10(%ebp),%eax
  800833:	89 44 24 08          	mov    %eax,0x8(%esp)
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	89 04 24             	mov    %eax,(%esp)
  800844:	e8 82 ff ff ff       	call   8007cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    
  80084b:	00 00                	add    %al,(%eax)
  80084d:	00 00                	add    %al,(%eax)
	...

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	80 3a 00             	cmpb   $0x0,(%edx)
  80085e:	74 09                	je     800869 <strlen+0x19>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
  80087a:	85 c9                	test   %ecx,%ecx
  80087c:	74 1a                	je     800898 <strnlen+0x2d>
  80087e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800881:	74 15                	je     800898 <strnlen+0x2d>
  800883:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800888:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	39 ca                	cmp    %ecx,%edx
  80088c:	74 0a                	je     800898 <strnlen+0x2d>
  80088e:	83 c2 01             	add    $0x1,%edx
  800891:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800896:	75 f0                	jne    800888 <strnlen+0x1d>
		n++;
	return n;
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b1:	83 c2 01             	add    $0x1,%edx
  8008b4:	84 c9                	test   %cl,%cl
  8008b6:	75 f2                	jne    8008aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	89 1c 24             	mov    %ebx,(%esp)
  8008c8:	e8 83 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d4:	01 d8                	add    %ebx,%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 bd ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008de:	89 d8                	mov    %ebx,%eax
  8008e0:	83 c4 08             	add    $0x8,%esp
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	85 f6                	test   %esi,%esi
  8008f6:	74 18                	je     800910 <strncpy+0x2a>
  8008f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008fd:	0f b6 1a             	movzbl (%edx),%ebx
  800900:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800903:	80 3a 01             	cmpb   $0x1,(%edx)
  800906:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	83 c1 01             	add    $0x1,%ecx
  80090c:	39 f1                	cmp    %esi,%ecx
  80090e:	75 ed                	jne    8008fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800920:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800923:	89 f8                	mov    %edi,%eax
  800925:	85 f6                	test   %esi,%esi
  800927:	74 2b                	je     800954 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800929:	83 fe 01             	cmp    $0x1,%esi
  80092c:	74 23                	je     800951 <strlcpy+0x3d>
  80092e:	0f b6 0b             	movzbl (%ebx),%ecx
  800931:	84 c9                	test   %cl,%cl
  800933:	74 1c                	je     800951 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800935:	83 ee 02             	sub    $0x2,%esi
  800938:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093d:	88 08                	mov    %cl,(%eax)
  80093f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800942:	39 f2                	cmp    %esi,%edx
  800944:	74 0b                	je     800951 <strlcpy+0x3d>
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80094d:	84 c9                	test   %cl,%cl
  80094f:	75 ec                	jne    80093d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800951:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800954:	29 f8                	sub    %edi,%eax
}
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800964:	0f b6 01             	movzbl (%ecx),%eax
  800967:	84 c0                	test   %al,%al
  800969:	74 16                	je     800981 <strcmp+0x26>
  80096b:	3a 02                	cmp    (%edx),%al
  80096d:	75 12                	jne    800981 <strcmp+0x26>
		p++, q++;
  80096f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800972:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800976:	84 c0                	test   %al,%al
  800978:	74 07                	je     800981 <strcmp+0x26>
  80097a:	83 c1 01             	add    $0x1,%ecx
  80097d:	3a 02                	cmp    (%edx),%al
  80097f:	74 ee                	je     80096f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800981:	0f b6 c0             	movzbl %al,%eax
  800984:	0f b6 12             	movzbl (%edx),%edx
  800987:	29 d0                	sub    %edx,%eax
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800992:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800995:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099d:	85 d2                	test   %edx,%edx
  80099f:	74 28                	je     8009c9 <strncmp+0x3e>
  8009a1:	0f b6 01             	movzbl (%ecx),%eax
  8009a4:	84 c0                	test   %al,%al
  8009a6:	74 24                	je     8009cc <strncmp+0x41>
  8009a8:	3a 03                	cmp    (%ebx),%al
  8009aa:	75 20                	jne    8009cc <strncmp+0x41>
  8009ac:	83 ea 01             	sub    $0x1,%edx
  8009af:	74 13                	je     8009c4 <strncmp+0x39>
		n--, p++, q++;
  8009b1:	83 c1 01             	add    $0x1,%ecx
  8009b4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b7:	0f b6 01             	movzbl (%ecx),%eax
  8009ba:	84 c0                	test   %al,%al
  8009bc:	74 0e                	je     8009cc <strncmp+0x41>
  8009be:	3a 03                	cmp    (%ebx),%al
  8009c0:	74 ea                	je     8009ac <strncmp+0x21>
  8009c2:	eb 08                	jmp    8009cc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cc:	0f b6 01             	movzbl (%ecx),%eax
  8009cf:	0f b6 13             	movzbl (%ebx),%edx
  8009d2:	29 d0                	sub    %edx,%eax
  8009d4:	eb f3                	jmp    8009c9 <strncmp+0x3e>

008009d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e0:	0f b6 10             	movzbl (%eax),%edx
  8009e3:	84 d2                	test   %dl,%dl
  8009e5:	74 1c                	je     800a03 <strchr+0x2d>
		if (*s == c)
  8009e7:	38 ca                	cmp    %cl,%dl
  8009e9:	75 09                	jne    8009f4 <strchr+0x1e>
  8009eb:	eb 1b                	jmp    800a08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ed:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	74 14                	je     800a08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 f1                	jne    8009ed <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 05                	jmp    800a08 <strchr+0x32>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	0f b6 10             	movzbl (%eax),%edx
  800a17:	84 d2                	test   %dl,%dl
  800a19:	74 14                	je     800a2f <strfind+0x25>
		if (*s == c)
  800a1b:	38 ca                	cmp    %cl,%dl
  800a1d:	75 06                	jne    800a25 <strfind+0x1b>
  800a1f:	eb 0e                	jmp    800a2f <strfind+0x25>
  800a21:	38 ca                	cmp    %cl,%dl
  800a23:	74 0a                	je     800a2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	0f b6 10             	movzbl (%eax),%edx
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	75 f2                	jne    800a21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 0c             	sub    $0xc,%esp
  800a37:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a3a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a3d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 30                	je     800a7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a53:	75 25                	jne    800a7a <memset+0x49>
  800a55:	f6 c1 03             	test   $0x3,%cl
  800a58:	75 20                	jne    800a7a <memset+0x49>
		c &= 0xFF;
  800a5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5d:	89 d3                	mov    %edx,%ebx
  800a5f:	c1 e3 08             	shl    $0x8,%ebx
  800a62:	89 d6                	mov    %edx,%esi
  800a64:	c1 e6 18             	shl    $0x18,%esi
  800a67:	89 d0                	mov    %edx,%eax
  800a69:	c1 e0 10             	shl    $0x10,%eax
  800a6c:	09 f0                	or     %esi,%eax
  800a6e:	09 d0                	or     %edx,%eax
  800a70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a75:	fc                   	cld    
  800a76:	f3 ab                	rep stos %eax,%es:(%edi)
  800a78:	eb 03                	jmp    800a7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7a:	fc                   	cld    
  800a7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a88:	89 ec                	mov    %ebp,%esp
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	83 ec 08             	sub    $0x8,%esp
  800a92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a95:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 36                	jae    800adb <memmove+0x4f>
  800aa5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa8:	39 d0                	cmp    %edx,%eax
  800aaa:	73 2f                	jae    800adb <memmove+0x4f>
		s += n;
		d += n;
  800aac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	f6 c2 03             	test   $0x3,%dl
  800ab2:	75 1b                	jne    800acf <memmove+0x43>
  800ab4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aba:	75 13                	jne    800acf <memmove+0x43>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	75 0e                	jne    800acf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac1:	83 ef 04             	sub    $0x4,%edi
  800ac4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aca:	fd                   	std    
  800acb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acd:	eb 09                	jmp    800ad8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800acf:	83 ef 01             	sub    $0x1,%edi
  800ad2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ad5:	fd                   	std    
  800ad6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad8:	fc                   	cld    
  800ad9:	eb 20                	jmp    800afb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae1:	75 13                	jne    800af6 <memmove+0x6a>
  800ae3:	a8 03                	test   $0x3,%al
  800ae5:	75 0f                	jne    800af6 <memmove+0x6a>
  800ae7:	f6 c1 03             	test   $0x3,%cl
  800aea:	75 0a                	jne    800af6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aef:	89 c7                	mov    %eax,%edi
  800af1:	fc                   	cld    
  800af2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af4:	eb 05                	jmp    800afb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af6:	89 c7                	mov    %eax,%edi
  800af8:	fc                   	cld    
  800af9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800afb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800afe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b01:	89 ec                	mov    %ebp,%esp
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	89 04 24             	mov    %eax,(%esp)
  800b1f:	e8 68 ff ff ff       	call   800a8c <memmove>
}
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b32:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	85 ff                	test   %edi,%edi
  800b3c:	74 37                	je     800b75 <memcmp+0x4f>
		if (*s1 != *s2)
  800b3e:	0f b6 03             	movzbl (%ebx),%eax
  800b41:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b44:	83 ef 01             	sub    $0x1,%edi
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b4c:	38 c8                	cmp    %cl,%al
  800b4e:	74 1c                	je     800b6c <memcmp+0x46>
  800b50:	eb 10                	jmp    800b62 <memcmp+0x3c>
  800b52:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b57:	83 c2 01             	add    $0x1,%edx
  800b5a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b5e:	38 c8                	cmp    %cl,%al
  800b60:	74 0a                	je     800b6c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b62:	0f b6 c0             	movzbl %al,%eax
  800b65:	0f b6 c9             	movzbl %cl,%ecx
  800b68:	29 c8                	sub    %ecx,%eax
  800b6a:	eb 09                	jmp    800b75 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6c:	39 fa                	cmp    %edi,%edx
  800b6e:	75 e2                	jne    800b52 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b85:	39 d0                	cmp    %edx,%eax
  800b87:	73 19                	jae    800ba2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b8d:	38 08                	cmp    %cl,(%eax)
  800b8f:	75 06                	jne    800b97 <memfind+0x1d>
  800b91:	eb 0f                	jmp    800ba2 <memfind+0x28>
  800b93:	38 08                	cmp    %cl,(%eax)
  800b95:	74 0b                	je     800ba2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b97:	83 c0 01             	add    $0x1,%eax
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ba0:	75 f1                	jne    800b93 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb0:	0f b6 02             	movzbl (%edx),%eax
  800bb3:	3c 20                	cmp    $0x20,%al
  800bb5:	74 04                	je     800bbb <strtol+0x17>
  800bb7:	3c 09                	cmp    $0x9,%al
  800bb9:	75 0e                	jne    800bc9 <strtol+0x25>
		s++;
  800bbb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbe:	0f b6 02             	movzbl (%edx),%eax
  800bc1:	3c 20                	cmp    $0x20,%al
  800bc3:	74 f6                	je     800bbb <strtol+0x17>
  800bc5:	3c 09                	cmp    $0x9,%al
  800bc7:	74 f2                	je     800bbb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc9:	3c 2b                	cmp    $0x2b,%al
  800bcb:	75 0a                	jne    800bd7 <strtol+0x33>
		s++;
  800bcd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd5:	eb 10                	jmp    800be7 <strtol+0x43>
  800bd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bdc:	3c 2d                	cmp    $0x2d,%al
  800bde:	75 07                	jne    800be7 <strtol+0x43>
		s++, neg = 1;
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	85 db                	test   %ebx,%ebx
  800be9:	0f 94 c0             	sete   %al
  800bec:	74 05                	je     800bf3 <strtol+0x4f>
  800bee:	83 fb 10             	cmp    $0x10,%ebx
  800bf1:	75 15                	jne    800c08 <strtol+0x64>
  800bf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf6:	75 10                	jne    800c08 <strtol+0x64>
  800bf8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bfc:	75 0a                	jne    800c08 <strtol+0x64>
		s += 2, base = 16;
  800bfe:	83 c2 02             	add    $0x2,%edx
  800c01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c06:	eb 13                	jmp    800c1b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c08:	84 c0                	test   %al,%al
  800c0a:	74 0f                	je     800c1b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c11:	80 3a 30             	cmpb   $0x30,(%edx)
  800c14:	75 05                	jne    800c1b <strtol+0x77>
		s++, base = 8;
  800c16:	83 c2 01             	add    $0x1,%edx
  800c19:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c22:	0f b6 0a             	movzbl (%edx),%ecx
  800c25:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c28:	80 fb 09             	cmp    $0x9,%bl
  800c2b:	77 08                	ja     800c35 <strtol+0x91>
			dig = *s - '0';
  800c2d:	0f be c9             	movsbl %cl,%ecx
  800c30:	83 e9 30             	sub    $0x30,%ecx
  800c33:	eb 1e                	jmp    800c53 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c35:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c38:	80 fb 19             	cmp    $0x19,%bl
  800c3b:	77 08                	ja     800c45 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c3d:	0f be c9             	movsbl %cl,%ecx
  800c40:	83 e9 57             	sub    $0x57,%ecx
  800c43:	eb 0e                	jmp    800c53 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c45:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c48:	80 fb 19             	cmp    $0x19,%bl
  800c4b:	77 14                	ja     800c61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c4d:	0f be c9             	movsbl %cl,%ecx
  800c50:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c53:	39 f1                	cmp    %esi,%ecx
  800c55:	7d 0e                	jge    800c65 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	0f af c6             	imul   %esi,%eax
  800c5d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c5f:	eb c1                	jmp    800c22 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c61:	89 c1                	mov    %eax,%ecx
  800c63:	eb 02                	jmp    800c67 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c65:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6b:	74 05                	je     800c72 <strtol+0xce>
		*endptr = (char *) s;
  800c6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c70:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c72:	89 ca                	mov    %ecx,%edx
  800c74:	f7 da                	neg    %edx
  800c76:	85 ff                	test   %edi,%edi
  800c78:	0f 45 c2             	cmovne %edx,%eax
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 c3                	mov    %eax,%ebx
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	89 c6                	mov    %eax,%esi
  800ca0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cab:	89 ec                	mov    %ebp,%esp
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_cgetc>:

int
sys_cgetc(void)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc8:	89 d1                	mov    %edx,%ecx
  800cca:	89 d3                	mov    %edx,%ebx
  800ccc:	89 d7                	mov    %edx,%edi
  800cce:	89 d6                	mov    %edx,%esi
  800cd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cdb:	89 ec                	mov    %ebp,%esp
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 38             	sub    $0x38,%esp
  800ce5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ceb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 cb                	mov    %ecx,%ebx
  800cfd:	89 cf                	mov    %ecx,%edi
  800cff:	89 ce                	mov    %ecx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 28                	jle    800d2f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d12:	00 
  800d13:	c7 44 24 08 c0 12 80 	movl   $0x8012c0,0x8(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d22:	00 
  800d23:	c7 04 24 dd 12 80 00 	movl   $0x8012dd,(%esp)
  800d2a:	e8 3d 00 00 00       	call   800d6c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 02 00 00 00       	mov    $0x2,%eax
  800d55:	89 d1                	mov    %edx,%ecx
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	89 d7                	mov    %edx,%edi
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d68:	89 ec                	mov    %ebp,%esp
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d74:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d77:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d7d:	e8 ba ff ff ff       	call   800d3c <sys_getenvid>
  800d82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d85:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d90:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d98:	c7 04 24 ec 12 80 00 	movl   $0x8012ec,(%esp)
  800d9f:	e8 ab f3 ff ff       	call   80014f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dab:	89 04 24             	mov    %eax,(%esp)
  800dae:	e8 3b f3 ff ff       	call   8000ee <vcprintf>
	cprintf("\n");
  800db3:	c7 04 24 84 10 80 00 	movl   $0x801084,(%esp)
  800dba:	e8 90 f3 ff ff       	call   80014f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dbf:	cc                   	int3   
  800dc0:	eb fd                	jmp    800dbf <_panic+0x53>
	...

00800dd0 <__udivdi3>:
  800dd0:	83 ec 1c             	sub    $0x1c,%esp
  800dd3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800dd7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800ddb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800ddf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800de3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800de7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800df1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df5:	89 cd                	mov    %ecx,%ebp
  800df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dfb:	75 33                	jne    800e30 <__udivdi3+0x60>
  800dfd:	39 f1                	cmp    %esi,%ecx
  800dff:	77 57                	ja     800e58 <__udivdi3+0x88>
  800e01:	85 c9                	test   %ecx,%ecx
  800e03:	75 0b                	jne    800e10 <__udivdi3+0x40>
  800e05:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0a:	31 d2                	xor    %edx,%edx
  800e0c:	f7 f1                	div    %ecx
  800e0e:	89 c1                	mov    %eax,%ecx
  800e10:	89 f0                	mov    %esi,%eax
  800e12:	31 d2                	xor    %edx,%edx
  800e14:	f7 f1                	div    %ecx
  800e16:	89 c6                	mov    %eax,%esi
  800e18:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e1c:	f7 f1                	div    %ecx
  800e1e:	89 f2                	mov    %esi,%edx
  800e20:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e2c:	83 c4 1c             	add    $0x1c,%esp
  800e2f:	c3                   	ret    
  800e30:	31 d2                	xor    %edx,%edx
  800e32:	31 c0                	xor    %eax,%eax
  800e34:	39 f7                	cmp    %esi,%edi
  800e36:	77 e8                	ja     800e20 <__udivdi3+0x50>
  800e38:	0f bd cf             	bsr    %edi,%ecx
  800e3b:	83 f1 1f             	xor    $0x1f,%ecx
  800e3e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e42:	75 2c                	jne    800e70 <__udivdi3+0xa0>
  800e44:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800e48:	76 04                	jbe    800e4e <__udivdi3+0x7e>
  800e4a:	39 f7                	cmp    %esi,%edi
  800e4c:	73 d2                	jae    800e20 <__udivdi3+0x50>
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	eb c9                	jmp    800e20 <__udivdi3+0x50>
  800e57:	90                   	nop
  800e58:	89 f2                	mov    %esi,%edx
  800e5a:	f7 f1                	div    %ecx
  800e5c:	31 d2                	xor    %edx,%edx
  800e5e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e62:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e66:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	c3                   	ret    
  800e6e:	66 90                	xchg   %ax,%ax
  800e70:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e75:	b8 20 00 00 00       	mov    $0x20,%eax
  800e7a:	89 ea                	mov    %ebp,%edx
  800e7c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e80:	d3 e7                	shl    %cl,%edi
  800e82:	89 c1                	mov    %eax,%ecx
  800e84:	d3 ea                	shr    %cl,%edx
  800e86:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e8b:	09 fa                	or     %edi,%edx
  800e8d:	89 f7                	mov    %esi,%edi
  800e8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e93:	89 f2                	mov    %esi,%edx
  800e95:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e99:	d3 e5                	shl    %cl,%ebp
  800e9b:	89 c1                	mov    %eax,%ecx
  800e9d:	d3 ef                	shr    %cl,%edi
  800e9f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ea4:	d3 e2                	shl    %cl,%edx
  800ea6:	89 c1                	mov    %eax,%ecx
  800ea8:	d3 ee                	shr    %cl,%esi
  800eaa:	09 d6                	or     %edx,%esi
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	f7 74 24 0c          	divl   0xc(%esp)
  800eb4:	89 d7                	mov    %edx,%edi
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	f7 e5                	mul    %ebp
  800eba:	39 d7                	cmp    %edx,%edi
  800ebc:	72 22                	jb     800ee0 <__udivdi3+0x110>
  800ebe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800ec2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ec7:	d3 e5                	shl    %cl,%ebp
  800ec9:	39 c5                	cmp    %eax,%ebp
  800ecb:	73 04                	jae    800ed1 <__udivdi3+0x101>
  800ecd:	39 d7                	cmp    %edx,%edi
  800ecf:	74 0f                	je     800ee0 <__udivdi3+0x110>
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	e9 46 ff ff ff       	jmp    800e20 <__udivdi3+0x50>
  800eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ee9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800eed:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ef1:	83 c4 1c             	add    $0x1c,%esp
  800ef4:	c3                   	ret    
	...

00800f00 <__umoddi3>:
  800f00:	83 ec 1c             	sub    $0x1c,%esp
  800f03:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f07:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800f0b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f0f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f13:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f17:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f1b:	85 ed                	test   %ebp,%ebp
  800f1d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f25:	89 cf                	mov    %ecx,%edi
  800f27:	89 04 24             	mov    %eax,(%esp)
  800f2a:	89 f2                	mov    %esi,%edx
  800f2c:	75 1a                	jne    800f48 <__umoddi3+0x48>
  800f2e:	39 f1                	cmp    %esi,%ecx
  800f30:	76 4e                	jbe    800f80 <__umoddi3+0x80>
  800f32:	f7 f1                	div    %ecx
  800f34:	89 d0                	mov    %edx,%eax
  800f36:	31 d2                	xor    %edx,%edx
  800f38:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f3c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f40:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f44:	83 c4 1c             	add    $0x1c,%esp
  800f47:	c3                   	ret    
  800f48:	39 f5                	cmp    %esi,%ebp
  800f4a:	77 54                	ja     800fa0 <__umoddi3+0xa0>
  800f4c:	0f bd c5             	bsr    %ebp,%eax
  800f4f:	83 f0 1f             	xor    $0x1f,%eax
  800f52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f56:	75 60                	jne    800fb8 <__umoddi3+0xb8>
  800f58:	3b 0c 24             	cmp    (%esp),%ecx
  800f5b:	0f 87 07 01 00 00    	ja     801068 <__umoddi3+0x168>
  800f61:	89 f2                	mov    %esi,%edx
  800f63:	8b 34 24             	mov    (%esp),%esi
  800f66:	29 ce                	sub    %ecx,%esi
  800f68:	19 ea                	sbb    %ebp,%edx
  800f6a:	89 34 24             	mov    %esi,(%esp)
  800f6d:	8b 04 24             	mov    (%esp),%eax
  800f70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f74:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f78:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f7c:	83 c4 1c             	add    $0x1c,%esp
  800f7f:	c3                   	ret    
  800f80:	85 c9                	test   %ecx,%ecx
  800f82:	75 0b                	jne    800f8f <__umoddi3+0x8f>
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	31 d2                	xor    %edx,%edx
  800f8b:	f7 f1                	div    %ecx
  800f8d:	89 c1                	mov    %eax,%ecx
  800f8f:	89 f0                	mov    %esi,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f1                	div    %ecx
  800f95:	8b 04 24             	mov    (%esp),%eax
  800f98:	f7 f1                	div    %ecx
  800f9a:	eb 98                	jmp    800f34 <__umoddi3+0x34>
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	89 f2                	mov    %esi,%edx
  800fa2:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800faa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fae:	83 c4 1c             	add    $0x1c,%esp
  800fb1:	c3                   	ret    
  800fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fbd:	89 e8                	mov    %ebp,%eax
  800fbf:	bd 20 00 00 00       	mov    $0x20,%ebp
  800fc4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800fc8:	89 fa                	mov    %edi,%edx
  800fca:	d3 e0                	shl    %cl,%eax
  800fcc:	89 e9                	mov    %ebp,%ecx
  800fce:	d3 ea                	shr    %cl,%edx
  800fd0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fd5:	09 c2                	or     %eax,%edx
  800fd7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fdb:	89 14 24             	mov    %edx,(%esp)
  800fde:	89 f2                	mov    %esi,%edx
  800fe0:	d3 e7                	shl    %cl,%edi
  800fe2:	89 e9                	mov    %ebp,%ecx
  800fe4:	d3 ea                	shr    %cl,%edx
  800fe6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800feb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fef:	d3 e6                	shl    %cl,%esi
  800ff1:	89 e9                	mov    %ebp,%ecx
  800ff3:	d3 e8                	shr    %cl,%eax
  800ff5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffa:	09 f0                	or     %esi,%eax
  800ffc:	8b 74 24 08          	mov    0x8(%esp),%esi
  801000:	f7 34 24             	divl   (%esp)
  801003:	d3 e6                	shl    %cl,%esi
  801005:	89 74 24 08          	mov    %esi,0x8(%esp)
  801009:	89 d6                	mov    %edx,%esi
  80100b:	f7 e7                	mul    %edi
  80100d:	39 d6                	cmp    %edx,%esi
  80100f:	89 c1                	mov    %eax,%ecx
  801011:	89 d7                	mov    %edx,%edi
  801013:	72 3f                	jb     801054 <__umoddi3+0x154>
  801015:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801019:	72 35                	jb     801050 <__umoddi3+0x150>
  80101b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80101f:	29 c8                	sub    %ecx,%eax
  801021:	19 fe                	sbb    %edi,%esi
  801023:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801028:	89 f2                	mov    %esi,%edx
  80102a:	d3 e8                	shr    %cl,%eax
  80102c:	89 e9                	mov    %ebp,%ecx
  80102e:	d3 e2                	shl    %cl,%edx
  801030:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801035:	09 d0                	or     %edx,%eax
  801037:	89 f2                	mov    %esi,%edx
  801039:	d3 ea                	shr    %cl,%edx
  80103b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80103f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801043:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801047:	83 c4 1c             	add    $0x1c,%esp
  80104a:	c3                   	ret    
  80104b:	90                   	nop
  80104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801050:	39 d6                	cmp    %edx,%esi
  801052:	75 c7                	jne    80101b <__umoddi3+0x11b>
  801054:	89 d7                	mov    %edx,%edi
  801056:	89 c1                	mov    %eax,%ecx
  801058:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80105c:	1b 3c 24             	sbb    (%esp),%edi
  80105f:	eb ba                	jmp    80101b <__umoddi3+0x11b>
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	39 f5                	cmp    %esi,%ebp
  80106a:	0f 82 f1 fe ff ff    	jb     800f61 <__umoddi3+0x61>
  801070:	e9 f8 fe ff ff       	jmp    800f6d <__umoddi3+0x6d>
