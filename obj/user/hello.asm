
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
  80003a:	c7 04 24 40 13 80 00 	movl   $0x801340,(%esp)
  800041:	e8 21 01 00 00       	call   800167 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 08 20 80 00       	mov    0x802008,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 4e 13 80 00 	movl   $0x80134e,(%esp)
  800059:	e8 09 01 00 00       	call   800167 <cprintf>
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
  80007c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 3d 0c 00 00       	call   800cff <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	83 c0 01             	add    $0x1,%eax
  8000da:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e1:	75 19                	jne    8000fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ea:	00 
  8000eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 aa 0b 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  8000f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800100:	83 c4 14             	add    $0x14,%esp
  800103:	5b                   	pop    %ebx
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800116:	00 00 00 
	b.cnt = 0;
  800119:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800120:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800123:	8b 45 0c             	mov    0xc(%ebp),%eax
  800126:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012a:	8b 45 08             	mov    0x8(%ebp),%eax
  80012d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013b:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  800142:	e8 97 01 00 00       	call   8002de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800157:	89 04 24             	mov    %eax,(%esp)
  80015a:	e8 41 0b 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  80015f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	89 04 24             	mov    %eax,(%esp)
  80017a:	e8 87 ff ff ff       	call   800106 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
  800181:	00 00                	add    %al,(%eax)
	...

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 3c             	sub    $0x3c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d7                	mov    %edx,%edi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001ac:	72 11                	jb     8001bf <printnum+0x3b>
  8001ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b4:	76 09                	jbe    8001bf <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b6:	83 eb 01             	sub    $0x1,%ebx
  8001b9:	85 db                	test   %ebx,%ebx
  8001bb:	7f 51                	jg     80020e <printnum+0x8a>
  8001bd:	eb 5e                	jmp    80021d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c3:	83 eb 01             	sub    $0x1,%ebx
  8001c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e0:	00 
  8001e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ee:	e8 8d 0e 00 00       	call   801080 <__udivdi3>
  8001f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800202:	89 fa                	mov    %edi,%edx
  800204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800207:	e8 78 ff ff ff       	call   800184 <printnum>
  80020c:	eb 0f                	jmp    80021d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800212:	89 34 24             	mov    %esi,(%esp)
  800215:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	75 f1                	jne    80020e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800221:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800225:	8b 45 10             	mov    0x10(%ebp),%eax
  800228:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800233:	00 
  800234:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800237:	89 04 24             	mov    %eax,(%esp)
  80023a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	e8 6a 0f 00 00       	call   8011b0 <__umoddi3>
  800246:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024a:	0f be 80 6f 13 80 00 	movsbl 0x80136f(%eax),%eax
  800251:	89 04 24             	mov    %eax,(%esp)
  800254:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800257:	83 c4 3c             	add    $0x3c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800262:	83 fa 01             	cmp    $0x1,%edx
  800265:	7e 0e                	jle    800275 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800267:	8b 10                	mov    (%eax),%edx
  800269:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 02                	mov    (%edx),%eax
  800270:	8b 52 04             	mov    0x4(%edx),%edx
  800273:	eb 22                	jmp    800297 <getuint+0x38>
	else if (lflag)
  800275:	85 d2                	test   %edx,%edx
  800277:	74 10                	je     800289 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
  800287:	eb 0e                	jmp    800297 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a8:	73 0a                	jae    8002b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ad:	88 0a                	mov    %cl,(%edx)
  8002af:	83 c2 01             	add    $0x1,%edx
  8002b2:	89 10                	mov    %edx,(%eax)
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 02 00 00 00       	call   8002de <vprintfmt>
	va_end(ap);
}
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    

008002de <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 5c             	sub    $0x5c,%esp
  8002e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ea:	8b 75 10             	mov    0x10(%ebp),%esi
  8002ed:	eb 12                	jmp    800301 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ef:	85 c0                	test   %eax,%eax
  8002f1:	0f 84 e4 04 00 00    	je     8007db <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8002f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800301:	0f b6 06             	movzbl (%esi),%eax
  800304:	83 c6 01             	add    $0x1,%esi
  800307:	83 f8 25             	cmp    $0x25,%eax
  80030a:	75 e3                	jne    8002ef <vprintfmt+0x11>
  80030c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800310:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800317:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80031c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80032b:	eb 2b                	jmp    800358 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800330:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800334:	eb 22                	jmp    800358 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800339:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80033d:	eb 19                	jmp    800358 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800342:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800349:	eb 0d                	jmp    800358 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80034b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80034e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800351:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	0f b6 06             	movzbl (%esi),%eax
  80035b:	0f b6 d0             	movzbl %al,%edx
  80035e:	8d 7e 01             	lea    0x1(%esi),%edi
  800361:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800364:	83 e8 23             	sub    $0x23,%eax
  800367:	3c 55                	cmp    $0x55,%al
  800369:	0f 87 46 04 00 00    	ja     8007b5 <vprintfmt+0x4d7>
  80036f:	0f b6 c0             	movzbl %al,%eax
  800372:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	83 ea 30             	sub    $0x30,%edx
  80037c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80037f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800383:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800389:	83 fa 09             	cmp    $0x9,%edx
  80038c:	77 4a                	ja     8003d8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800391:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800394:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800397:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80039b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039e:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a1:	83 fa 09             	cmp    $0x9,%edx
  8003a4:	76 eb                	jbe    800391 <vprintfmt+0xb3>
  8003a6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003a9:	eb 2d                	jmp    8003d8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 50 04             	lea    0x4(%eax),%edx
  8003b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bc:	eb 1a                	jmp    8003d8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003c1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003c5:	79 91                	jns    800358 <vprintfmt+0x7a>
  8003c7:	e9 73 ff ff ff       	jmp    80033f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003cf:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8003d6:	eb 80                	jmp    800358 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003dc:	0f 89 76 ff ff ff    	jns    800358 <vprintfmt+0x7a>
  8003e2:	e9 64 ff ff ff       	jmp    80034b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ed:	e9 66 ff ff ff       	jmp    800358 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 50 04             	lea    0x4(%eax),%edx
  8003f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040a:	e9 f2 fe ff ff       	jmp    800301 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80040f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800413:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800416:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80041a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80041d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800421:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800424:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800427:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80042b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80042e:	80 f9 09             	cmp    $0x9,%cl
  800431:	77 1d                	ja     800450 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800433:	0f be c0             	movsbl %al,%eax
  800436:	6b c0 64             	imul   $0x64,%eax,%eax
  800439:	0f be d2             	movsbl %dl,%edx
  80043c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80043f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800446:	a3 04 20 80 00       	mov    %eax,0x802004
  80044b:	e9 b1 fe ff ff       	jmp    800301 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800450:	c7 44 24 04 87 13 80 	movl   $0x801387,0x4(%esp)
  800457:	00 
  800458:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	e8 18 05 00 00       	call   80097b <strcmp>
  800463:	85 c0                	test   %eax,%eax
  800465:	75 0f                	jne    800476 <vprintfmt+0x198>
  800467:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80046e:	00 00 00 
  800471:	e9 8b fe ff ff       	jmp    800301 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800476:	c7 44 24 04 8b 13 80 	movl   $0x80138b,0x4(%esp)
  80047d:	00 
  80047e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800481:	89 14 24             	mov    %edx,(%esp)
  800484:	e8 f2 04 00 00       	call   80097b <strcmp>
  800489:	85 c0                	test   %eax,%eax
  80048b:	75 0f                	jne    80049c <vprintfmt+0x1be>
  80048d:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800494:	00 00 00 
  800497:	e9 65 fe ff ff       	jmp    800301 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80049c:	c7 44 24 04 8f 13 80 	movl   $0x80138f,0x4(%esp)
  8004a3:	00 
  8004a4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004a7:	89 0c 24             	mov    %ecx,(%esp)
  8004aa:	e8 cc 04 00 00       	call   80097b <strcmp>
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	75 0f                	jne    8004c2 <vprintfmt+0x1e4>
  8004b3:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004ba:	00 00 00 
  8004bd:	e9 3f fe ff ff       	jmp    800301 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004c2:	c7 44 24 04 93 13 80 	movl   $0x801393,0x4(%esp)
  8004c9:	00 
  8004ca:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8004cd:	89 3c 24             	mov    %edi,(%esp)
  8004d0:	e8 a6 04 00 00       	call   80097b <strcmp>
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	75 0f                	jne    8004e8 <vprintfmt+0x20a>
  8004d9:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8004e0:	00 00 00 
  8004e3:	e9 19 fe ff ff       	jmp    800301 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8004e8:	c7 44 24 04 97 13 80 	movl   $0x801397,0x4(%esp)
  8004ef:	00 
  8004f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004f3:	89 04 24             	mov    %eax,(%esp)
  8004f6:	e8 80 04 00 00       	call   80097b <strcmp>
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	75 0f                	jne    80050e <vprintfmt+0x230>
  8004ff:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800506:	00 00 00 
  800509:	e9 f3 fd ff ff       	jmp    800301 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80050e:	c7 44 24 04 9b 13 80 	movl   $0x80139b,0x4(%esp)
  800515:	00 
  800516:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800519:	89 14 24             	mov    %edx,(%esp)
  80051c:	e8 5a 04 00 00       	call   80097b <strcmp>
  800521:	83 f8 01             	cmp    $0x1,%eax
  800524:	19 c0                	sbb    %eax,%eax
  800526:	f7 d0                	not    %eax
  800528:	83 c0 08             	add    $0x8,%eax
  80052b:	a3 04 20 80 00       	mov    %eax,0x802004
  800530:	e9 cc fd ff ff       	jmp    800301 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 c2                	mov    %eax,%edx
  800542:	c1 fa 1f             	sar    $0x1f,%edx
  800545:	31 d0                	xor    %edx,%eax
  800547:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800549:	83 f8 08             	cmp    $0x8,%eax
  80054c:	7f 0b                	jg     800559 <vprintfmt+0x27b>
  80054e:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	75 23                	jne    80057c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055d:	c7 44 24 08 9f 13 80 	movl   $0x80139f,0x8(%esp)
  800564:	00 
  800565:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800569:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056c:	89 3c 24             	mov    %edi,(%esp)
  80056f:	e8 42 fd ff ff       	call   8002b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800577:	e9 85 fd ff ff       	jmp    800301 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80057c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800580:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800587:	00 
  800588:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 3c 24             	mov    %edi,(%esp)
  800592:	e8 1f fd ff ff       	call   8002b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80059a:	e9 62 fd ff ff       	jmp    800301 <vprintfmt+0x23>
  80059f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005b3:	85 f6                	test   %esi,%esi
  8005b5:	b8 80 13 80 00       	mov    $0x801380,%eax
  8005ba:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005bd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005c1:	7e 06                	jle    8005c9 <vprintfmt+0x2eb>
  8005c3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005c7:	75 13                	jne    8005dc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	0f be 06             	movsbl (%esi),%eax
  8005cc:	83 c6 01             	add    $0x1,%esi
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	0f 85 94 00 00 00    	jne    80066b <vprintfmt+0x38d>
  8005d7:	e9 81 00 00 00       	jmp    80065d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e0:	89 34 24             	mov    %esi,(%esp)
  8005e3:	e8 a3 02 00 00       	call   80088b <strnlen>
  8005e8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005eb:	29 c2                	sub    %eax,%edx
  8005ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005f0:	85 d2                	test   %edx,%edx
  8005f2:	7e d5                	jle    8005c9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8005f4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8005f8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005fb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8005fe:	89 d6                	mov    %edx,%esi
  800600:	89 cf                	mov    %ecx,%edi
  800602:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800606:	89 3c 24             	mov    %edi,(%esp)
  800609:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	75 f1                	jne    800602 <vprintfmt+0x324>
  800611:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800614:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800617:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80061a:	eb ad                	jmp    8005c9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800620:	74 1b                	je     80063d <vprintfmt+0x35f>
  800622:	8d 50 e0             	lea    -0x20(%eax),%edx
  800625:	83 fa 5e             	cmp    $0x5e,%edx
  800628:	76 13                	jbe    80063d <vprintfmt+0x35f>
					putch('?', putdat);
  80062a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80062d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800631:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
  80063b:	eb 0d                	jmp    80064a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80063d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800640:	89 54 24 04          	mov    %edx,0x4(%esp)
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064a:	83 eb 01             	sub    $0x1,%ebx
  80064d:	0f be 06             	movsbl (%esi),%eax
  800650:	83 c6 01             	add    $0x1,%esi
  800653:	85 c0                	test   %eax,%eax
  800655:	75 1a                	jne    800671 <vprintfmt+0x393>
  800657:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80065a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800660:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800664:	7f 1c                	jg     800682 <vprintfmt+0x3a4>
  800666:	e9 96 fc ff ff       	jmp    800301 <vprintfmt+0x23>
  80066b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80066e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800671:	85 ff                	test   %edi,%edi
  800673:	78 a7                	js     80061c <vprintfmt+0x33e>
  800675:	83 ef 01             	sub    $0x1,%edi
  800678:	79 a2                	jns    80061c <vprintfmt+0x33e>
  80067a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80067d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800680:	eb db                	jmp    80065d <vprintfmt+0x37f>
  800682:	8b 7d 08             	mov    0x8(%ebp),%edi
  800685:	89 de                	mov    %ebx,%esi
  800687:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800695:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800697:	83 eb 01             	sub    $0x1,%ebx
  80069a:	75 ee                	jne    80068a <vprintfmt+0x3ac>
  80069c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006a1:	e9 5b fc ff ff       	jmp    800301 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a6:	83 f9 01             	cmp    $0x1,%ecx
  8006a9:	7e 10                	jle    8006bb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8d 50 08             	lea    0x8(%eax),%edx
  8006b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b4:	8b 30                	mov    (%eax),%esi
  8006b6:	8b 78 04             	mov    0x4(%eax),%edi
  8006b9:	eb 26                	jmp    8006e1 <vprintfmt+0x403>
	else if (lflag)
  8006bb:	85 c9                	test   %ecx,%ecx
  8006bd:	74 12                	je     8006d1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 30                	mov    (%eax),%esi
  8006ca:	89 f7                	mov    %esi,%edi
  8006cc:	c1 ff 1f             	sar    $0x1f,%edi
  8006cf:	eb 10                	jmp    8006e1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 04             	lea    0x4(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	8b 30                	mov    (%eax),%esi
  8006dc:	89 f7                	mov    %esi,%edi
  8006de:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e1:	85 ff                	test   %edi,%edi
  8006e3:	78 0e                	js     8006f3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e5:	89 f0                	mov    %esi,%eax
  8006e7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e9:	be 0a 00 00 00       	mov    $0xa,%esi
  8006ee:	e9 84 00 00 00       	jmp    800777 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800701:	89 f0                	mov    %esi,%eax
  800703:	89 fa                	mov    %edi,%edx
  800705:	f7 d8                	neg    %eax
  800707:	83 d2 00             	adc    $0x0,%edx
  80070a:	f7 da                	neg    %edx
			}
			base = 10;
  80070c:	be 0a 00 00 00       	mov    $0xa,%esi
  800711:	eb 64                	jmp    800777 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800713:	89 ca                	mov    %ecx,%edx
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
  800718:	e8 42 fb ff ff       	call   80025f <getuint>
			base = 10;
  80071d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800722:	eb 53                	jmp    800777 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800724:	89 ca                	mov    %ecx,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 31 fb ff ff       	call   80025f <getuint>
    			base = 8;
  80072e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800733:	eb 42                	jmp    800777 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800735:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800739:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800747:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 50 04             	lea    0x4(%eax),%edx
  800757:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075a:	8b 00                	mov    (%eax),%eax
  80075c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800761:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800766:	eb 0f                	jmp    800777 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800768:	89 ca                	mov    %ecx,%edx
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	e8 ed fa ff ff       	call   80025f <getuint>
			base = 16;
  800772:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800777:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80077b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80077f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800782:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800786:	89 74 24 08          	mov    %esi,0x8(%esp)
  80078a:	89 04 24             	mov    %eax,(%esp)
  80078d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800791:	89 da                	mov    %ebx,%edx
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	e8 e9 f9 ff ff       	call   800184 <printnum>
			break;
  80079b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80079e:	e9 5e fb ff ff       	jmp    800301 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	89 14 24             	mov    %edx,(%esp)
  8007aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b0:	e9 4c fb ff ff       	jmp    800301 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c7:	0f 84 34 fb ff ff    	je     800301 <vprintfmt+0x23>
  8007cd:	83 ee 01             	sub    $0x1,%esi
  8007d0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d4:	75 f7                	jne    8007cd <vprintfmt+0x4ef>
  8007d6:	e9 26 fb ff ff       	jmp    800301 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007db:	83 c4 5c             	add    $0x5c,%esp
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5f                   	pop    %edi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 28             	sub    $0x28,%esp
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800800:	85 c0                	test   %eax,%eax
  800802:	74 30                	je     800834 <vsnprintf+0x51>
  800804:	85 d2                	test   %edx,%edx
  800806:	7e 2c                	jle    800834 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080f:	8b 45 10             	mov    0x10(%ebp),%eax
  800812:	89 44 24 08          	mov    %eax,0x8(%esp)
  800816:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081d:	c7 04 24 99 02 80 00 	movl   $0x800299,(%esp)
  800824:	e8 b5 fa ff ff       	call   8002de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800829:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800832:	eb 05                	jmp    800839 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800834:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800841:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800844:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800848:	8b 45 10             	mov    0x10(%ebp),%eax
  80084b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800852:	89 44 24 04          	mov    %eax,0x4(%esp)
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	89 04 24             	mov    %eax,(%esp)
  80085c:	e8 82 ff ff ff       	call   8007e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800861:	c9                   	leave  
  800862:	c3                   	ret    
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
  800d33:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800d4a:	e8 d5 02 00 00       	call   801024 <_panic>

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

00800d8c <sys_yield>:

void
sys_yield(void)
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
  800da0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 38             	sub    $0x38,%esp
  800dc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 f7                	mov    %esi,%edi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800e09:	e8 16 02 00 00       	call   801024 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e17:	89 ec                	mov    %ebp,%esp
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 38             	sub    $0x38,%esp
  800e21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e2f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 28                	jle    800e6c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e48:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e4f:	00 
  800e50:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800e67:	e8 b8 01 00 00       	call   801024 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e6f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e72:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e75:	89 ec                	mov    %ebp,%esp
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 38             	sub    $0x38,%esp
  800e7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e85:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	89 df                	mov    %ebx,%edi
  800e9a:	89 de                	mov    %ebx,%esi
  800e9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	7e 28                	jle    800eca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ead:	00 
  800eae:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800ec5:	e8 5a 01 00 00       	call   801024 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed3:	89 ec                	mov    %ebp,%esp
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 38             	sub    $0x38,%esp
  800edd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eeb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	89 df                	mov    %ebx,%edi
  800ef8:	89 de                	mov    %ebx,%esi
  800efa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	7e 28                	jle    800f28 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800f13:	00 
  800f14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1b:	00 
  800f1c:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800f23:	e8 fc 00 00 00       	call   801024 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f28:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f31:	89 ec                	mov    %ebp,%esp
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 38             	sub    $0x38,%esp
  800f3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f41:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f49:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	89 df                	mov    %ebx,%edi
  800f56:	89 de                	mov    %ebx,%esi
  800f58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	7e 28                	jle    800f86 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f62:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f69:	00 
  800f6a:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800f71:	00 
  800f72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f79:	00 
  800f7a:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800f81:	e8 9e 00 00 00       	call   801024 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8f:	89 ec                	mov    %ebp,%esp
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	be 00 00 00 00       	mov    $0x0,%esi
  800fa7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fac:	8b 7d 14             	mov    0x14(%ebp),%edi
  800faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc3:	89 ec                	mov    %ebp,%esp
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 38             	sub    $0x38,%esp
  800fcd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 cb                	mov    %ecx,%ebx
  800fe5:	89 cf                	mov    %ecx,%edi
  800fe7:	89 ce                	mov    %ecx,%esi
  800fe9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	7e 28                	jle    801017 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  801002:	00 
  801003:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  801012:	e8 0d 00 00 00       	call   801024 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801017:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801020:	89 ec                	mov    %ebp,%esp
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80102c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80102f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801035:	e8 22 fd ff ff       	call   800d5c <sys_getenvid>
  80103a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801041:	8b 55 08             	mov    0x8(%ebp),%edx
  801044:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801048:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80104c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801050:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  801057:	e8 0b f1 ff ff       	call   800167 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801060:	8b 45 10             	mov    0x10(%ebp),%eax
  801063:	89 04 24             	mov    %eax,(%esp)
  801066:	e8 9b f0 ff ff       	call   800106 <vcprintf>
	cprintf("\n");
  80106b:	c7 04 24 4c 13 80 00 	movl   $0x80134c,(%esp)
  801072:	e8 f0 f0 ff ff       	call   800167 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801077:	cc                   	int3   
  801078:	eb fd                	jmp    801077 <_panic+0x53>
  80107a:	00 00                	add    %al,(%eax)
  80107c:	00 00                	add    %al,(%eax)
	...

00801080 <__udivdi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801087:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80108b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80108f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801093:	89 74 24 10          	mov    %esi,0x10(%esp)
  801097:	8b 74 24 24          	mov    0x24(%esp),%esi
  80109b:	85 ff                	test   %edi,%edi
  80109d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	89 cd                	mov    %ecx,%ebp
  8010a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ab:	75 33                	jne    8010e0 <__udivdi3+0x60>
  8010ad:	39 f1                	cmp    %esi,%ecx
  8010af:	77 57                	ja     801108 <__udivdi3+0x88>
  8010b1:	85 c9                	test   %ecx,%ecx
  8010b3:	75 0b                	jne    8010c0 <__udivdi3+0x40>
  8010b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ba:	31 d2                	xor    %edx,%edx
  8010bc:	f7 f1                	div    %ecx
  8010be:	89 c1                	mov    %eax,%ecx
  8010c0:	89 f0                	mov    %esi,%eax
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	f7 f1                	div    %ecx
  8010c6:	89 c6                	mov    %eax,%esi
  8010c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010cc:	f7 f1                	div    %ecx
  8010ce:	89 f2                	mov    %esi,%edx
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	31 d2                	xor    %edx,%edx
  8010e2:	31 c0                	xor    %eax,%eax
  8010e4:	39 f7                	cmp    %esi,%edi
  8010e6:	77 e8                	ja     8010d0 <__udivdi3+0x50>
  8010e8:	0f bd cf             	bsr    %edi,%ecx
  8010eb:	83 f1 1f             	xor    $0x1f,%ecx
  8010ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010f2:	75 2c                	jne    801120 <__udivdi3+0xa0>
  8010f4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010f8:	76 04                	jbe    8010fe <__udivdi3+0x7e>
  8010fa:	39 f7                	cmp    %esi,%edi
  8010fc:	73 d2                	jae    8010d0 <__udivdi3+0x50>
  8010fe:	31 d2                	xor    %edx,%edx
  801100:	b8 01 00 00 00       	mov    $0x1,%eax
  801105:	eb c9                	jmp    8010d0 <__udivdi3+0x50>
  801107:	90                   	nop
  801108:	89 f2                	mov    %esi,%edx
  80110a:	f7 f1                	div    %ecx
  80110c:	31 d2                	xor    %edx,%edx
  80110e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801112:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801116:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111a:	83 c4 1c             	add    $0x1c,%esp
  80111d:	c3                   	ret    
  80111e:	66 90                	xchg   %ax,%ax
  801120:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801125:	b8 20 00 00 00       	mov    $0x20,%eax
  80112a:	89 ea                	mov    %ebp,%edx
  80112c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801130:	d3 e7                	shl    %cl,%edi
  801132:	89 c1                	mov    %eax,%ecx
  801134:	d3 ea                	shr    %cl,%edx
  801136:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113b:	09 fa                	or     %edi,%edx
  80113d:	89 f7                	mov    %esi,%edi
  80113f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801143:	89 f2                	mov    %esi,%edx
  801145:	8b 74 24 08          	mov    0x8(%esp),%esi
  801149:	d3 e5                	shl    %cl,%ebp
  80114b:	89 c1                	mov    %eax,%ecx
  80114d:	d3 ef                	shr    %cl,%edi
  80114f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801154:	d3 e2                	shl    %cl,%edx
  801156:	89 c1                	mov    %eax,%ecx
  801158:	d3 ee                	shr    %cl,%esi
  80115a:	09 d6                	or     %edx,%esi
  80115c:	89 fa                	mov    %edi,%edx
  80115e:	89 f0                	mov    %esi,%eax
  801160:	f7 74 24 0c          	divl   0xc(%esp)
  801164:	89 d7                	mov    %edx,%edi
  801166:	89 c6                	mov    %eax,%esi
  801168:	f7 e5                	mul    %ebp
  80116a:	39 d7                	cmp    %edx,%edi
  80116c:	72 22                	jb     801190 <__udivdi3+0x110>
  80116e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801172:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801177:	d3 e5                	shl    %cl,%ebp
  801179:	39 c5                	cmp    %eax,%ebp
  80117b:	73 04                	jae    801181 <__udivdi3+0x101>
  80117d:	39 d7                	cmp    %edx,%edi
  80117f:	74 0f                	je     801190 <__udivdi3+0x110>
  801181:	89 f0                	mov    %esi,%eax
  801183:	31 d2                	xor    %edx,%edx
  801185:	e9 46 ff ff ff       	jmp    8010d0 <__udivdi3+0x50>
  80118a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801190:	8d 46 ff             	lea    -0x1(%esi),%eax
  801193:	31 d2                	xor    %edx,%edx
  801195:	8b 74 24 10          	mov    0x10(%esp),%esi
  801199:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80119d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a1:	83 c4 1c             	add    $0x1c,%esp
  8011a4:	c3                   	ret    
	...

008011b0 <__umoddi3>:
  8011b0:	83 ec 1c             	sub    $0x1c,%esp
  8011b3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011b7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011c3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011cb:	85 ed                	test   %ebp,%ebp
  8011cd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	89 cf                	mov    %ecx,%edi
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	89 f2                	mov    %esi,%edx
  8011dc:	75 1a                	jne    8011f8 <__umoddi3+0x48>
  8011de:	39 f1                	cmp    %esi,%ecx
  8011e0:	76 4e                	jbe    801230 <__umoddi3+0x80>
  8011e2:	f7 f1                	div    %ecx
  8011e4:	89 d0                	mov    %edx,%eax
  8011e6:	31 d2                	xor    %edx,%edx
  8011e8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011ec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011f0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011f4:	83 c4 1c             	add    $0x1c,%esp
  8011f7:	c3                   	ret    
  8011f8:	39 f5                	cmp    %esi,%ebp
  8011fa:	77 54                	ja     801250 <__umoddi3+0xa0>
  8011fc:	0f bd c5             	bsr    %ebp,%eax
  8011ff:	83 f0 1f             	xor    $0x1f,%eax
  801202:	89 44 24 04          	mov    %eax,0x4(%esp)
  801206:	75 60                	jne    801268 <__umoddi3+0xb8>
  801208:	3b 0c 24             	cmp    (%esp),%ecx
  80120b:	0f 87 07 01 00 00    	ja     801318 <__umoddi3+0x168>
  801211:	89 f2                	mov    %esi,%edx
  801213:	8b 34 24             	mov    (%esp),%esi
  801216:	29 ce                	sub    %ecx,%esi
  801218:	19 ea                	sbb    %ebp,%edx
  80121a:	89 34 24             	mov    %esi,(%esp)
  80121d:	8b 04 24             	mov    (%esp),%eax
  801220:	8b 74 24 10          	mov    0x10(%esp),%esi
  801224:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801228:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80122c:	83 c4 1c             	add    $0x1c,%esp
  80122f:	c3                   	ret    
  801230:	85 c9                	test   %ecx,%ecx
  801232:	75 0b                	jne    80123f <__umoddi3+0x8f>
  801234:	b8 01 00 00 00       	mov    $0x1,%eax
  801239:	31 d2                	xor    %edx,%edx
  80123b:	f7 f1                	div    %ecx
  80123d:	89 c1                	mov    %eax,%ecx
  80123f:	89 f0                	mov    %esi,%eax
  801241:	31 d2                	xor    %edx,%edx
  801243:	f7 f1                	div    %ecx
  801245:	8b 04 24             	mov    (%esp),%eax
  801248:	f7 f1                	div    %ecx
  80124a:	eb 98                	jmp    8011e4 <__umoddi3+0x34>
  80124c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 f2                	mov    %esi,%edx
  801252:	8b 74 24 10          	mov    0x10(%esp),%esi
  801256:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80125a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80125e:	83 c4 1c             	add    $0x1c,%esp
  801261:	c3                   	ret    
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126d:	89 e8                	mov    %ebp,%eax
  80126f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801274:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801278:	89 fa                	mov    %edi,%edx
  80127a:	d3 e0                	shl    %cl,%eax
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 ea                	shr    %cl,%edx
  801280:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801285:	09 c2                	or     %eax,%edx
  801287:	8b 44 24 08          	mov    0x8(%esp),%eax
  80128b:	89 14 24             	mov    %edx,(%esp)
  80128e:	89 f2                	mov    %esi,%edx
  801290:	d3 e7                	shl    %cl,%edi
  801292:	89 e9                	mov    %ebp,%ecx
  801294:	d3 ea                	shr    %cl,%edx
  801296:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80129f:	d3 e6                	shl    %cl,%esi
  8012a1:	89 e9                	mov    %ebp,%ecx
  8012a3:	d3 e8                	shr    %cl,%eax
  8012a5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012aa:	09 f0                	or     %esi,%eax
  8012ac:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012b0:	f7 34 24             	divl   (%esp)
  8012b3:	d3 e6                	shl    %cl,%esi
  8012b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012b9:	89 d6                	mov    %edx,%esi
  8012bb:	f7 e7                	mul    %edi
  8012bd:	39 d6                	cmp    %edx,%esi
  8012bf:	89 c1                	mov    %eax,%ecx
  8012c1:	89 d7                	mov    %edx,%edi
  8012c3:	72 3f                	jb     801304 <__umoddi3+0x154>
  8012c5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012c9:	72 35                	jb     801300 <__umoddi3+0x150>
  8012cb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cf:	29 c8                	sub    %ecx,%eax
  8012d1:	19 fe                	sbb    %edi,%esi
  8012d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d8:	89 f2                	mov    %esi,%edx
  8012da:	d3 e8                	shr    %cl,%eax
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012e5:	09 d0                	or     %edx,%eax
  8012e7:	89 f2                	mov    %esi,%edx
  8012e9:	d3 ea                	shr    %cl,%edx
  8012eb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012ef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012f3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012f7:	83 c4 1c             	add    $0x1c,%esp
  8012fa:	c3                   	ret    
  8012fb:	90                   	nop
  8012fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801300:	39 d6                	cmp    %edx,%esi
  801302:	75 c7                	jne    8012cb <__umoddi3+0x11b>
  801304:	89 d7                	mov    %edx,%edi
  801306:	89 c1                	mov    %eax,%ecx
  801308:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80130c:	1b 3c 24             	sbb    (%esp),%edi
  80130f:	eb ba                	jmp    8012cb <__umoddi3+0x11b>
  801311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801318:	39 f5                	cmp    %esi,%ebp
  80131a:	0f 82 f1 fe ff ff    	jb     801211 <__umoddi3+0x61>
  801320:	e9 f8 fe ff ff       	jmp    80121d <__umoddi3+0x6d>
