
obj/user/yield:     file format elf32-i386


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
  80003b:	a1 08 20 80 00       	mov    0x802008,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  80004e:	e8 54 01 00 00       	call   8001a7 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 6f 0d 00 00       	call   800dcc <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 08 20 80 00       	mov    0x802008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 a0 13 80 00 	movl   $0x8013a0,(%esp)
  800074:	e8 2e 01 00 00       	call   8001a7 <cprintf>
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
  800081:	a1 08 20 80 00       	mov    0x802008,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 cc 13 80 00 	movl   $0x8013cc,(%esp)
  800094:	e8 0e 01 00 00       	call   8001a7 <cprintf>
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
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 3d 0c 00 00       	call   800d3f <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	83 c0 01             	add    $0x1,%eax
  80011a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 19                	jne    80013c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800123:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012a:	00 
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 aa 0b 00 00       	call   800ce0 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	83 c4 14             	add    $0x14,%esp
  800143:	5b                   	pop    %ebx
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	8b 45 0c             	mov    0xc(%ebp),%eax
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800171:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  800182:	e8 97 01 00 00       	call   80031e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 41 0b 00 00       	call   800ce0 <sys_cputs>

	return b.cnt;
}
  80019f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 87 ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
  8001c1:	00 00                	add    %al,(%eax)
	...

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 3c             	sub    $0x3c,%esp
  8001cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d0:	89 d7                	mov    %edx,%edi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001de:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001ec:	72 11                	jb     8001ff <printnum+0x3b>
  8001ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f4:	76 09                	jbe    8001ff <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f6:	83 eb 01             	sub    $0x1,%ebx
  8001f9:	85 db                	test   %ebx,%ebx
  8001fb:	7f 51                	jg     80024e <printnum+0x8a>
  8001fd:	eb 5e                	jmp    80025d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  800203:	83 eb 01             	sub    $0x1,%ebx
  800206:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800211:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800215:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800219:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800220:	00 
  800221:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	e8 8d 0e 00 00       	call   8010c0 <__udivdi3>
  800233:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800237:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800242:	89 fa                	mov    %edi,%edx
  800244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800247:	e8 78 ff ff ff       	call   8001c4 <printnum>
  80024c:	eb 0f                	jmp    80025d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800252:	89 34 24             	mov    %esi,(%esp)
  800255:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	75 f1                	jne    80024e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800261:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800265:	8b 45 10             	mov    0x10(%ebp),%eax
  800268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800273:	00 
  800274:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	e8 6a 0f 00 00       	call   8011f0 <__umoddi3>
  800286:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028a:	0f be 80 f5 13 80 00 	movsbl 0x8013f5(%eax),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800297:	83 c4 3c             	add    $0x3c,%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5e                   	pop    %esi
  80029c:	5f                   	pop    %edi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a2:	83 fa 01             	cmp    $0x1,%edx
  8002a5:	7e 0e                	jle    8002b5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 02                	mov    (%edx),%eax
  8002b0:	8b 52 04             	mov    0x4(%edx),%edx
  8002b3:	eb 22                	jmp    8002d7 <getuint+0x38>
	else if (lflag)
  8002b5:	85 d2                	test   %edx,%edx
  8002b7:	74 10                	je     8002c9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c7:	eb 0e                	jmp    8002d7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e8:	73 0a                	jae    8002f4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ed:	88 0a                	mov    %cl,(%edx)
  8002ef:	83 c2 01             	add    $0x1,%edx
  8002f2:	89 10                	mov    %edx,(%eax)
}
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800303:	8b 45 10             	mov    0x10(%ebp),%eax
  800306:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 02 00 00 00       	call   80031e <vprintfmt>
	va_end(ap);
}
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 5c             	sub    $0x5c,%esp
  800327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032a:	8b 75 10             	mov    0x10(%ebp),%esi
  80032d:	eb 12                	jmp    800341 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032f:	85 c0                	test   %eax,%eax
  800331:	0f 84 e4 04 00 00    	je     80081b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800337:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033b:	89 04 24             	mov    %eax,(%esp)
  80033e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800341:	0f b6 06             	movzbl (%esi),%eax
  800344:	83 c6 01             	add    $0x1,%esi
  800347:	83 f8 25             	cmp    $0x25,%eax
  80034a:	75 e3                	jne    80032f <vprintfmt+0x11>
  80034c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800350:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800357:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800363:	b9 00 00 00 00       	mov    $0x0,%ecx
  800368:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80036b:	eb 2b                	jmp    800398 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800370:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800374:	eb 22                	jmp    800398 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800379:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80037d:	eb 19                	jmp    800398 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800382:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800389:	eb 0d                	jmp    800398 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80038e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800391:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	0f b6 06             	movzbl (%esi),%eax
  80039b:	0f b6 d0             	movzbl %al,%edx
  80039e:	8d 7e 01             	lea    0x1(%esi),%edi
  8003a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003a4:	83 e8 23             	sub    $0x23,%eax
  8003a7:	3c 55                	cmp    $0x55,%al
  8003a9:	0f 87 46 04 00 00    	ja     8007f5 <vprintfmt+0x4d7>
  8003af:	0f b6 c0             	movzbl %al,%eax
  8003b2:	ff 24 85 e0 14 80 00 	jmp    *0x8014e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b9:	83 ea 30             	sub    $0x30,%edx
  8003bc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003bf:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003c3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003c9:	83 fa 09             	cmp    $0x9,%edx
  8003cc:	77 4a                	ja     800418 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003d4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003d7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003db:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003de:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e1:	83 fa 09             	cmp    $0x9,%edx
  8003e4:	76 eb                	jbe    8003d1 <vprintfmt+0xb3>
  8003e6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003e9:	eb 2d                	jmp    800418 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fc:	eb 1a                	jmp    800418 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800401:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800405:	79 91                	jns    800398 <vprintfmt+0x7a>
  800407:	e9 73 ff ff ff       	jmp    80037f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800416:	eb 80                	jmp    800398 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800418:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80041c:	0f 89 76 ff ff ff    	jns    800398 <vprintfmt+0x7a>
  800422:	e9 64 ff ff ff       	jmp    80038b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800427:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042d:	e9 66 ff ff ff       	jmp    800398 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 50 04             	lea    0x4(%eax),%edx
  800438:	89 55 14             	mov    %edx,0x14(%ebp)
  80043b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	89 04 24             	mov    %eax,(%esp)
  800444:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044a:	e9 f2 fe ff ff       	jmp    800341 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80044f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800453:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800456:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80045a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80045d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800461:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800464:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800467:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80046b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80046e:	80 f9 09             	cmp    $0x9,%cl
  800471:	77 1d                	ja     800490 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800473:	0f be c0             	movsbl %al,%eax
  800476:	6b c0 64             	imul   $0x64,%eax,%eax
  800479:	0f be d2             	movsbl %dl,%edx
  80047c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80047f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800486:	a3 04 20 80 00       	mov    %eax,0x802004
  80048b:	e9 b1 fe ff ff       	jmp    800341 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800490:	c7 44 24 04 0d 14 80 	movl   $0x80140d,0x4(%esp)
  800497:	00 
  800498:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	e8 18 05 00 00       	call   8009bb <strcmp>
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	75 0f                	jne    8004b6 <vprintfmt+0x198>
  8004a7:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8004ae:	00 00 00 
  8004b1:	e9 8b fe ff ff       	jmp    800341 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004b6:	c7 44 24 04 11 14 80 	movl   $0x801411,0x4(%esp)
  8004bd:	00 
  8004be:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004c1:	89 14 24             	mov    %edx,(%esp)
  8004c4:	e8 f2 04 00 00       	call   8009bb <strcmp>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	75 0f                	jne    8004dc <vprintfmt+0x1be>
  8004cd:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8004d4:	00 00 00 
  8004d7:	e9 65 fe ff ff       	jmp    800341 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004dc:	c7 44 24 04 15 14 80 	movl   $0x801415,0x4(%esp)
  8004e3:	00 
  8004e4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004e7:	89 0c 24             	mov    %ecx,(%esp)
  8004ea:	e8 cc 04 00 00       	call   8009bb <strcmp>
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	75 0f                	jne    800502 <vprintfmt+0x1e4>
  8004f3:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004fa:	00 00 00 
  8004fd:	e9 3f fe ff ff       	jmp    800341 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800502:	c7 44 24 04 19 14 80 	movl   $0x801419,0x4(%esp)
  800509:	00 
  80050a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80050d:	89 3c 24             	mov    %edi,(%esp)
  800510:	e8 a6 04 00 00       	call   8009bb <strcmp>
  800515:	85 c0                	test   %eax,%eax
  800517:	75 0f                	jne    800528 <vprintfmt+0x20a>
  800519:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800520:	00 00 00 
  800523:	e9 19 fe ff ff       	jmp    800341 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800528:	c7 44 24 04 1d 14 80 	movl   $0x80141d,0x4(%esp)
  80052f:	00 
  800530:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	e8 80 04 00 00       	call   8009bb <strcmp>
  80053b:	85 c0                	test   %eax,%eax
  80053d:	75 0f                	jne    80054e <vprintfmt+0x230>
  80053f:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800546:	00 00 00 
  800549:	e9 f3 fd ff ff       	jmp    800341 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80054e:	c7 44 24 04 21 14 80 	movl   $0x801421,0x4(%esp)
  800555:	00 
  800556:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800559:	89 14 24             	mov    %edx,(%esp)
  80055c:	e8 5a 04 00 00       	call   8009bb <strcmp>
  800561:	83 f8 01             	cmp    $0x1,%eax
  800564:	19 c0                	sbb    %eax,%eax
  800566:	f7 d0                	not    %eax
  800568:	83 c0 08             	add    $0x8,%eax
  80056b:	a3 04 20 80 00       	mov    %eax,0x802004
  800570:	e9 cc fd ff ff       	jmp    800341 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 04             	lea    0x4(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 c2                	mov    %eax,%edx
  800582:	c1 fa 1f             	sar    $0x1f,%edx
  800585:	31 d0                	xor    %edx,%eax
  800587:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800589:	83 f8 08             	cmp    $0x8,%eax
  80058c:	7f 0b                	jg     800599 <vprintfmt+0x27b>
  80058e:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	75 23                	jne    8005bc <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800599:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059d:	c7 44 24 08 25 14 80 	movl   $0x801425,0x8(%esp)
  8005a4:	00 
  8005a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ac:	89 3c 24             	mov    %edi,(%esp)
  8005af:	e8 42 fd ff ff       	call   8002f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b7:	e9 85 fd ff ff       	jmp    800341 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c0:	c7 44 24 08 2e 14 80 	movl   $0x80142e,0x8(%esp)
  8005c7:	00 
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cf:	89 3c 24             	mov    %edi,(%esp)
  8005d2:	e8 1f fd ff ff       	call   8002f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005da:	e9 62 fd ff ff       	jmp    800341 <vprintfmt+0x23>
  8005df:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005e5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005f3:	85 f6                	test   %esi,%esi
  8005f5:	b8 06 14 80 00       	mov    $0x801406,%eax
  8005fa:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005fd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800601:	7e 06                	jle    800609 <vprintfmt+0x2eb>
  800603:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800607:	75 13                	jne    80061c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800609:	0f be 06             	movsbl (%esi),%eax
  80060c:	83 c6 01             	add    $0x1,%esi
  80060f:	85 c0                	test   %eax,%eax
  800611:	0f 85 94 00 00 00    	jne    8006ab <vprintfmt+0x38d>
  800617:	e9 81 00 00 00       	jmp    80069d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800620:	89 34 24             	mov    %esi,(%esp)
  800623:	e8 a3 02 00 00       	call   8008cb <strnlen>
  800628:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80062b:	29 c2                	sub    %eax,%edx
  80062d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800630:	85 d2                	test   %edx,%edx
  800632:	7e d5                	jle    800609 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800634:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800638:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80063b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80063e:	89 d6                	mov    %edx,%esi
  800640:	89 cf                	mov    %ecx,%edi
  800642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800646:	89 3c 24             	mov    %edi,(%esp)
  800649:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064c:	83 ee 01             	sub    $0x1,%esi
  80064f:	75 f1                	jne    800642 <vprintfmt+0x324>
  800651:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800654:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800657:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80065a:	eb ad                	jmp    800609 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80065c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800660:	74 1b                	je     80067d <vprintfmt+0x35f>
  800662:	8d 50 e0             	lea    -0x20(%eax),%edx
  800665:	83 fa 5e             	cmp    $0x5e,%edx
  800668:	76 13                	jbe    80067d <vprintfmt+0x35f>
					putch('?', putdat);
  80066a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800671:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800678:	ff 55 08             	call   *0x8(%ebp)
  80067b:	eb 0d                	jmp    80068a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80067d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800680:	89 54 24 04          	mov    %edx,0x4(%esp)
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068a:	83 eb 01             	sub    $0x1,%ebx
  80068d:	0f be 06             	movsbl (%esi),%eax
  800690:	83 c6 01             	add    $0x1,%esi
  800693:	85 c0                	test   %eax,%eax
  800695:	75 1a                	jne    8006b1 <vprintfmt+0x393>
  800697:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80069a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006a4:	7f 1c                	jg     8006c2 <vprintfmt+0x3a4>
  8006a6:	e9 96 fc ff ff       	jmp    800341 <vprintfmt+0x23>
  8006ab:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006ae:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	78 a7                	js     80065c <vprintfmt+0x33e>
  8006b5:	83 ef 01             	sub    $0x1,%edi
  8006b8:	79 a2                	jns    80065c <vprintfmt+0x33e>
  8006ba:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006bd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c0:	eb db                	jmp    80069d <vprintfmt+0x37f>
  8006c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d7:	83 eb 01             	sub    $0x1,%ebx
  8006da:	75 ee                	jne    8006ca <vprintfmt+0x3ac>
  8006dc:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006de:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006e1:	e9 5b fc ff ff       	jmp    800341 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e6:	83 f9 01             	cmp    $0x1,%ecx
  8006e9:	7e 10                	jle    8006fb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 50 08             	lea    0x8(%eax),%edx
  8006f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f4:	8b 30                	mov    (%eax),%esi
  8006f6:	8b 78 04             	mov    0x4(%eax),%edi
  8006f9:	eb 26                	jmp    800721 <vprintfmt+0x403>
	else if (lflag)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	74 12                	je     800711 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 50 04             	lea    0x4(%eax),%edx
  800705:	89 55 14             	mov    %edx,0x14(%ebp)
  800708:	8b 30                	mov    (%eax),%esi
  80070a:	89 f7                	mov    %esi,%edi
  80070c:	c1 ff 1f             	sar    $0x1f,%edi
  80070f:	eb 10                	jmp    800721 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8d 50 04             	lea    0x4(%eax),%edx
  800717:	89 55 14             	mov    %edx,0x14(%ebp)
  80071a:	8b 30                	mov    (%eax),%esi
  80071c:	89 f7                	mov    %esi,%edi
  80071e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800721:	85 ff                	test   %edi,%edi
  800723:	78 0e                	js     800733 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	89 f0                	mov    %esi,%eax
  800727:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800729:	be 0a 00 00 00       	mov    $0xa,%esi
  80072e:	e9 84 00 00 00       	jmp    8007b7 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80073e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800741:	89 f0                	mov    %esi,%eax
  800743:	89 fa                	mov    %edi,%edx
  800745:	f7 d8                	neg    %eax
  800747:	83 d2 00             	adc    $0x0,%edx
  80074a:	f7 da                	neg    %edx
			}
			base = 10;
  80074c:	be 0a 00 00 00       	mov    $0xa,%esi
  800751:	eb 64                	jmp    8007b7 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800753:	89 ca                	mov    %ecx,%edx
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 42 fb ff ff       	call   80029f <getuint>
			base = 10;
  80075d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800762:	eb 53                	jmp    8007b7 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800764:	89 ca                	mov    %ecx,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 31 fb ff ff       	call   80029f <getuint>
    			base = 8;
  80076e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800773:	eb 42                	jmp    8007b7 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800775:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800779:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800783:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800787:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80078e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a1:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007a6:	eb 0f                	jmp    8007b7 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a8:	89 ca                	mov    %ecx,%edx
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ad:	e8 ed fa ff ff       	call   80029f <getuint>
			base = 16;
  8007b2:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b7:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007bb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007bf:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007c6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007ca:	89 04 24             	mov    %eax,(%esp)
  8007cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d1:	89 da                	mov    %ebx,%edx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	e8 e9 f9 ff ff       	call   8001c4 <printnum>
			break;
  8007db:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007de:	e9 5e fb ff ff       	jmp    800341 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e7:	89 14 24             	mov    %edx,(%esp)
  8007ea:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ed:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f0:	e9 4c fb ff ff       	jmp    800341 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800800:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800803:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800807:	0f 84 34 fb ff ff    	je     800341 <vprintfmt+0x23>
  80080d:	83 ee 01             	sub    $0x1,%esi
  800810:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800814:	75 f7                	jne    80080d <vprintfmt+0x4ef>
  800816:	e9 26 fb ff ff       	jmp    800341 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80081b:	83 c4 5c             	add    $0x5c,%esp
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5f                   	pop    %edi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 28             	sub    $0x28,%esp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800832:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800836:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800839:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800840:	85 c0                	test   %eax,%eax
  800842:	74 30                	je     800874 <vsnprintf+0x51>
  800844:	85 d2                	test   %edx,%edx
  800846:	7e 2c                	jle    800874 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084f:	8b 45 10             	mov    0x10(%ebp),%eax
  800852:	89 44 24 08          	mov    %eax,0x8(%esp)
  800856:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085d:	c7 04 24 d9 02 80 00 	movl   $0x8002d9,(%esp)
  800864:	e8 b5 fa ff ff       	call   80031e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800869:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800872:	eb 05                	jmp    800879 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800884:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800888:	8b 45 10             	mov    0x10(%ebp),%eax
  80088b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800892:	89 44 24 04          	mov    %eax,0x4(%esp)
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	89 04 24             	mov    %eax,(%esp)
  80089c:	e8 82 ff ff ff       	call   800823 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    
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
  800d73:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d82:	00 
  800d83:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800d8a:	e8 d5 02 00 00       	call   801064 <_panic>

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
  800de0:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800e32:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e39:	00 
  800e3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e41:	00 
  800e42:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800e49:	e8 16 02 00 00       	call   801064 <_panic>

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
  800e90:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e97:	00 
  800e98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9f:	00 
  800ea0:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800ea7:	e8 b8 01 00 00       	call   801064 <_panic>

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
  800eee:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f05:	e8 5a 01 00 00       	call   801064 <_panic>

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
  800f4c:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800f53:	00 
  800f54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5b:	00 
  800f5c:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f63:	e8 fc 00 00 00       	call   801064 <_panic>

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

00800f75 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800f9c:	7e 28                	jle    800fc6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fa9:	00 
  800faa:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb9:	00 
  800fba:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800fc1:	e8 9e 00 00 00       	call   801064 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fcf:	89 ec                	mov    %ebp,%esp
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	be 00 00 00 00       	mov    $0x0,%esi
  800fe7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ffa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801000:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801003:	89 ec                	mov    %ebp,%esp
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 38             	sub    $0x38,%esp
  80100d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801010:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801013:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	89 cb                	mov    %ecx,%ebx
  801025:	89 cf                	mov    %ecx,%edi
  801027:	89 ce                	mov    %ecx,%esi
  801029:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 28                	jle    801057 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801033:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80103a:	00 
  80103b:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  801042:	00 
  801043:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104a:	00 
  80104b:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  801052:	e8 0d 00 00 00       	call   801064 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801057:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80105a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80105d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801060:	89 ec                	mov    %ebp,%esp
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80106c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80106f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801075:	e8 22 fd ff ff       	call   800d9c <sys_getenvid>
  80107a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801088:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80108c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801090:	c7 04 24 90 16 80 00 	movl   $0x801690,(%esp)
  801097:	e8 0b f1 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80109c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8010a3:	89 04 24             	mov    %eax,(%esp)
  8010a6:	e8 9b f0 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  8010ab:	c7 04 24 b4 16 80 00 	movl   $0x8016b4,(%esp)
  8010b2:	e8 f0 f0 ff ff       	call   8001a7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b7:	cc                   	int3   
  8010b8:	eb fd                	jmp    8010b7 <_panic+0x53>
  8010ba:	00 00                	add    %al,(%eax)
  8010bc:	00 00                	add    %al,(%eax)
	...

008010c0 <__udivdi3>:
  8010c0:	83 ec 1c             	sub    $0x1c,%esp
  8010c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010d3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010db:	85 ff                	test   %edi,%edi
  8010dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e5:	89 cd                	mov    %ecx,%ebp
  8010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010eb:	75 33                	jne    801120 <__udivdi3+0x60>
  8010ed:	39 f1                	cmp    %esi,%ecx
  8010ef:	77 57                	ja     801148 <__udivdi3+0x88>
  8010f1:	85 c9                	test   %ecx,%ecx
  8010f3:	75 0b                	jne    801100 <__udivdi3+0x40>
  8010f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010fa:	31 d2                	xor    %edx,%edx
  8010fc:	f7 f1                	div    %ecx
  8010fe:	89 c1                	mov    %eax,%ecx
  801100:	89 f0                	mov    %esi,%eax
  801102:	31 d2                	xor    %edx,%edx
  801104:	f7 f1                	div    %ecx
  801106:	89 c6                	mov    %eax,%esi
  801108:	8b 44 24 04          	mov    0x4(%esp),%eax
  80110c:	f7 f1                	div    %ecx
  80110e:	89 f2                	mov    %esi,%edx
  801110:	8b 74 24 10          	mov    0x10(%esp),%esi
  801114:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801118:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111c:	83 c4 1c             	add    $0x1c,%esp
  80111f:	c3                   	ret    
  801120:	31 d2                	xor    %edx,%edx
  801122:	31 c0                	xor    %eax,%eax
  801124:	39 f7                	cmp    %esi,%edi
  801126:	77 e8                	ja     801110 <__udivdi3+0x50>
  801128:	0f bd cf             	bsr    %edi,%ecx
  80112b:	83 f1 1f             	xor    $0x1f,%ecx
  80112e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801132:	75 2c                	jne    801160 <__udivdi3+0xa0>
  801134:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801138:	76 04                	jbe    80113e <__udivdi3+0x7e>
  80113a:	39 f7                	cmp    %esi,%edi
  80113c:	73 d2                	jae    801110 <__udivdi3+0x50>
  80113e:	31 d2                	xor    %edx,%edx
  801140:	b8 01 00 00 00       	mov    $0x1,%eax
  801145:	eb c9                	jmp    801110 <__udivdi3+0x50>
  801147:	90                   	nop
  801148:	89 f2                	mov    %esi,%edx
  80114a:	f7 f1                	div    %ecx
  80114c:	31 d2                	xor    %edx,%edx
  80114e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801152:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801156:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80115a:	83 c4 1c             	add    $0x1c,%esp
  80115d:	c3                   	ret    
  80115e:	66 90                	xchg   %ax,%ax
  801160:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801165:	b8 20 00 00 00       	mov    $0x20,%eax
  80116a:	89 ea                	mov    %ebp,%edx
  80116c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801170:	d3 e7                	shl    %cl,%edi
  801172:	89 c1                	mov    %eax,%ecx
  801174:	d3 ea                	shr    %cl,%edx
  801176:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117b:	09 fa                	or     %edi,%edx
  80117d:	89 f7                	mov    %esi,%edi
  80117f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801183:	89 f2                	mov    %esi,%edx
  801185:	8b 74 24 08          	mov    0x8(%esp),%esi
  801189:	d3 e5                	shl    %cl,%ebp
  80118b:	89 c1                	mov    %eax,%ecx
  80118d:	d3 ef                	shr    %cl,%edi
  80118f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801194:	d3 e2                	shl    %cl,%edx
  801196:	89 c1                	mov    %eax,%ecx
  801198:	d3 ee                	shr    %cl,%esi
  80119a:	09 d6                	or     %edx,%esi
  80119c:	89 fa                	mov    %edi,%edx
  80119e:	89 f0                	mov    %esi,%eax
  8011a0:	f7 74 24 0c          	divl   0xc(%esp)
  8011a4:	89 d7                	mov    %edx,%edi
  8011a6:	89 c6                	mov    %eax,%esi
  8011a8:	f7 e5                	mul    %ebp
  8011aa:	39 d7                	cmp    %edx,%edi
  8011ac:	72 22                	jb     8011d0 <__udivdi3+0x110>
  8011ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8011b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011b7:	d3 e5                	shl    %cl,%ebp
  8011b9:	39 c5                	cmp    %eax,%ebp
  8011bb:	73 04                	jae    8011c1 <__udivdi3+0x101>
  8011bd:	39 d7                	cmp    %edx,%edi
  8011bf:	74 0f                	je     8011d0 <__udivdi3+0x110>
  8011c1:	89 f0                	mov    %esi,%eax
  8011c3:	31 d2                	xor    %edx,%edx
  8011c5:	e9 46 ff ff ff       	jmp    801110 <__udivdi3+0x50>
  8011ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011d3:	31 d2                	xor    %edx,%edx
  8011d5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e1:	83 c4 1c             	add    $0x1c,%esp
  8011e4:	c3                   	ret    
	...

008011f0 <__umoddi3>:
  8011f0:	83 ec 1c             	sub    $0x1c,%esp
  8011f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  801203:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801207:	8b 74 24 24          	mov    0x24(%esp),%esi
  80120b:	85 ed                	test   %ebp,%ebp
  80120d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801211:	89 44 24 08          	mov    %eax,0x8(%esp)
  801215:	89 cf                	mov    %ecx,%edi
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	89 f2                	mov    %esi,%edx
  80121c:	75 1a                	jne    801238 <__umoddi3+0x48>
  80121e:	39 f1                	cmp    %esi,%ecx
  801220:	76 4e                	jbe    801270 <__umoddi3+0x80>
  801222:	f7 f1                	div    %ecx
  801224:	89 d0                	mov    %edx,%eax
  801226:	31 d2                	xor    %edx,%edx
  801228:	8b 74 24 10          	mov    0x10(%esp),%esi
  80122c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801230:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801234:	83 c4 1c             	add    $0x1c,%esp
  801237:	c3                   	ret    
  801238:	39 f5                	cmp    %esi,%ebp
  80123a:	77 54                	ja     801290 <__umoddi3+0xa0>
  80123c:	0f bd c5             	bsr    %ebp,%eax
  80123f:	83 f0 1f             	xor    $0x1f,%eax
  801242:	89 44 24 04          	mov    %eax,0x4(%esp)
  801246:	75 60                	jne    8012a8 <__umoddi3+0xb8>
  801248:	3b 0c 24             	cmp    (%esp),%ecx
  80124b:	0f 87 07 01 00 00    	ja     801358 <__umoddi3+0x168>
  801251:	89 f2                	mov    %esi,%edx
  801253:	8b 34 24             	mov    (%esp),%esi
  801256:	29 ce                	sub    %ecx,%esi
  801258:	19 ea                	sbb    %ebp,%edx
  80125a:	89 34 24             	mov    %esi,(%esp)
  80125d:	8b 04 24             	mov    (%esp),%eax
  801260:	8b 74 24 10          	mov    0x10(%esp),%esi
  801264:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801268:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80126c:	83 c4 1c             	add    $0x1c,%esp
  80126f:	c3                   	ret    
  801270:	85 c9                	test   %ecx,%ecx
  801272:	75 0b                	jne    80127f <__umoddi3+0x8f>
  801274:	b8 01 00 00 00       	mov    $0x1,%eax
  801279:	31 d2                	xor    %edx,%edx
  80127b:	f7 f1                	div    %ecx
  80127d:	89 c1                	mov    %eax,%ecx
  80127f:	89 f0                	mov    %esi,%eax
  801281:	31 d2                	xor    %edx,%edx
  801283:	f7 f1                	div    %ecx
  801285:	8b 04 24             	mov    (%esp),%eax
  801288:	f7 f1                	div    %ecx
  80128a:	eb 98                	jmp    801224 <__umoddi3+0x34>
  80128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801290:	89 f2                	mov    %esi,%edx
  801292:	8b 74 24 10          	mov    0x10(%esp),%esi
  801296:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80129a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80129e:	83 c4 1c             	add    $0x1c,%esp
  8012a1:	c3                   	ret    
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ad:	89 e8                	mov    %ebp,%eax
  8012af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8012b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8012b8:	89 fa                	mov    %edi,%edx
  8012ba:	d3 e0                	shl    %cl,%eax
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	d3 ea                	shr    %cl,%edx
  8012c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012c5:	09 c2                	or     %eax,%edx
  8012c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cb:	89 14 24             	mov    %edx,(%esp)
  8012ce:	89 f2                	mov    %esi,%edx
  8012d0:	d3 e7                	shl    %cl,%edi
  8012d2:	89 e9                	mov    %ebp,%ecx
  8012d4:	d3 ea                	shr    %cl,%edx
  8012d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012df:	d3 e6                	shl    %cl,%esi
  8012e1:	89 e9                	mov    %ebp,%ecx
  8012e3:	d3 e8                	shr    %cl,%eax
  8012e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ea:	09 f0                	or     %esi,%eax
  8012ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012f0:	f7 34 24             	divl   (%esp)
  8012f3:	d3 e6                	shl    %cl,%esi
  8012f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012f9:	89 d6                	mov    %edx,%esi
  8012fb:	f7 e7                	mul    %edi
  8012fd:	39 d6                	cmp    %edx,%esi
  8012ff:	89 c1                	mov    %eax,%ecx
  801301:	89 d7                	mov    %edx,%edi
  801303:	72 3f                	jb     801344 <__umoddi3+0x154>
  801305:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801309:	72 35                	jb     801340 <__umoddi3+0x150>
  80130b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80130f:	29 c8                	sub    %ecx,%eax
  801311:	19 fe                	sbb    %edi,%esi
  801313:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801318:	89 f2                	mov    %esi,%edx
  80131a:	d3 e8                	shr    %cl,%eax
  80131c:	89 e9                	mov    %ebp,%ecx
  80131e:	d3 e2                	shl    %cl,%edx
  801320:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801325:	09 d0                	or     %edx,%eax
  801327:	89 f2                	mov    %esi,%edx
  801329:	d3 ea                	shr    %cl,%edx
  80132b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80132f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801333:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801337:	83 c4 1c             	add    $0x1c,%esp
  80133a:	c3                   	ret    
  80133b:	90                   	nop
  80133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801340:	39 d6                	cmp    %edx,%esi
  801342:	75 c7                	jne    80130b <__umoddi3+0x11b>
  801344:	89 d7                	mov    %edx,%edi
  801346:	89 c1                	mov    %eax,%ecx
  801348:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80134c:	1b 3c 24             	sbb    (%esp),%edi
  80134f:	eb ba                	jmp    80130b <__umoddi3+0x11b>
  801351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801358:	39 f5                	cmp    %esi,%ebp
  80135a:	0f 82 f1 fe ff ff    	jb     801251 <__umoddi3+0x61>
  801360:	e9 f8 fe ff ff       	jmp    80125d <__umoddi3+0x6d>
