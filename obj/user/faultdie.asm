
obj/user/faultdie:     file format elf32-i386


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
  800059:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  800060:	e8 36 01 00 00       	call   80019b <cprintf>
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
  800081:	e8 02 10 00 00       	call   801088 <set_pgfault_handler>
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
  8000b8:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 39 0c 00 00       	call   800d2f <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	83 c0 01             	add    $0x1,%eax
  80010e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800110:	3d ff 00 00 00       	cmp    $0xff,%eax
  800115:	75 19                	jne    800130 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800117:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011e:	00 
  80011f:	8d 43 08             	lea    0x8(%ebx),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 a6 0b 00 00       	call   800cd0 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800130:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800134:	83 c4 14             	add    $0x14,%esp
  800137:	5b                   	pop    %ebx
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800143:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014a:	00 00 00 
	b.cnt = 0;
  80014d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800154:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015e:	8b 45 08             	mov    0x8(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800176:	e8 97 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 3d 0b 00 00       	call   800cd0 <sys_cputs>

	return b.cnt;
}
  800193:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 87 ff ff ff       	call   80013a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 3c             	sub    $0x3c,%esp
  8001c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c4:	89 d7                	mov    %edx,%edi
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001dd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001e0:	72 11                	jb     8001f3 <printnum+0x3b>
  8001e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e8:	76 09                	jbe    8001f3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ea:	83 eb 01             	sub    $0x1,%ebx
  8001ed:	85 db                	test   %ebx,%ebx
  8001ef:	7f 51                	jg     800242 <printnum+0x8a>
  8001f1:	eb 5e                	jmp    800251 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800201:	89 44 24 08          	mov    %eax,0x8(%esp)
  800205:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800209:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80020d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800214:	00 
  800215:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	e8 69 0f 00 00       	call   801190 <__udivdi3>
  800227:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80022b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80022f:	89 04 24             	mov    %eax,(%esp)
  800232:	89 54 24 04          	mov    %edx,0x4(%esp)
  800236:	89 fa                	mov    %edi,%edx
  800238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023b:	e8 78 ff ff ff       	call   8001b8 <printnum>
  800240:	eb 0f                	jmp    800251 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800242:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800246:	89 34 24             	mov    %esi,(%esp)
  800249:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024c:	83 eb 01             	sub    $0x1,%ebx
  80024f:	75 f1                	jne    800242 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800251:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800255:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800259:	8b 45 10             	mov    0x10(%ebp),%eax
  80025c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800260:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800267:	00 
  800268:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	e8 46 10 00 00       	call   8012c0 <__umoddi3>
  80027a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027e:	0f be 80 66 14 80 00 	movsbl 0x801466(%eax),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028b:	83 c4 3c             	add    $0x3c,%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800296:	83 fa 01             	cmp    $0x1,%edx
  800299:	7e 0e                	jle    8002a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 02                	mov    (%edx),%eax
  8002a4:	8b 52 04             	mov    0x4(%edx),%edx
  8002a7:	eb 22                	jmp    8002cb <getuint+0x38>
	else if (lflag)
  8002a9:	85 d2                	test   %edx,%edx
  8002ab:	74 10                	je     8002bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bb:	eb 0e                	jmp    8002cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dc:	73 0a                	jae    8002e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e1:	88 0a                	mov    %cl,(%edx)
  8002e3:	83 c2 01             	add    $0x1,%edx
  8002e6:	89 10                	mov    %edx,(%eax)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800301:	89 44 24 04          	mov    %eax,0x4(%esp)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	e8 02 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 5c             	sub    $0x5c,%esp
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031e:	8b 75 10             	mov    0x10(%ebp),%esi
  800321:	eb 12                	jmp    800335 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800323:	85 c0                	test   %eax,%eax
  800325:	0f 84 e4 04 00 00    	je     80080f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80032b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800335:	0f b6 06             	movzbl (%esi),%eax
  800338:	83 c6 01             	add    $0x1,%esi
  80033b:	83 f8 25             	cmp    $0x25,%eax
  80033e:	75 e3                	jne    800323 <vprintfmt+0x11>
  800340:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800344:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80034b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800350:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800357:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80035f:	eb 2b                	jmp    80038c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800364:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800368:	eb 22                	jmp    80038c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800371:	eb 19                	jmp    80038c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800376:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80037d:	eb 0d                	jmp    80038c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800382:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800385:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	0f b6 06             	movzbl (%esi),%eax
  80038f:	0f b6 d0             	movzbl %al,%edx
  800392:	8d 7e 01             	lea    0x1(%esi),%edi
  800395:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800398:	83 e8 23             	sub    $0x23,%eax
  80039b:	3c 55                	cmp    $0x55,%al
  80039d:	0f 87 46 04 00 00    	ja     8007e9 <vprintfmt+0x4d7>
  8003a3:	0f b6 c0             	movzbl %al,%eax
  8003a6:	ff 24 85 40 15 80 00 	jmp    *0x801540(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ad:	83 ea 30             	sub    $0x30,%edx
  8003b0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003b3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003b7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003bd:	83 fa 09             	cmp    $0x9,%edx
  8003c0:	77 4a                	ja     80040c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003c8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003cb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003cf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	76 eb                	jbe    8003c5 <vprintfmt+0xb3>
  8003da:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003dd:	eb 2d                	jmp    80040c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 50 04             	lea    0x4(%eax),%edx
  8003e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f0:	eb 1a                	jmp    80040c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003f5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003f9:	79 91                	jns    80038c <vprintfmt+0x7a>
  8003fb:	e9 73 ff ff ff       	jmp    800373 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800403:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80040a:	eb 80                	jmp    80038c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80040c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800410:	0f 89 76 ff ff ff    	jns    80038c <vprintfmt+0x7a>
  800416:	e9 64 ff ff ff       	jmp    80037f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800421:	e9 66 ff ff ff       	jmp    80038c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800433:	8b 00                	mov    (%eax),%eax
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043e:	e9 f2 fe ff ff       	jmp    800335 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800443:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800447:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80044a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80044e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800451:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800455:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800458:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80045b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80045f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800462:	80 f9 09             	cmp    $0x9,%cl
  800465:	77 1d                	ja     800484 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800467:	0f be c0             	movsbl %al,%eax
  80046a:	6b c0 64             	imul   $0x64,%eax,%eax
  80046d:	0f be d2             	movsbl %dl,%edx
  800470:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800473:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80047a:	a3 04 20 80 00       	mov    %eax,0x802004
  80047f:	e9 b1 fe ff ff       	jmp    800335 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800484:	c7 44 24 04 7e 14 80 	movl   $0x80147e,0x4(%esp)
  80048b:	00 
  80048c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 14 05 00 00       	call   8009ab <strcmp>
  800497:	85 c0                	test   %eax,%eax
  800499:	75 0f                	jne    8004aa <vprintfmt+0x198>
  80049b:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8004a2:	00 00 00 
  8004a5:	e9 8b fe ff ff       	jmp    800335 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004aa:	c7 44 24 04 82 14 80 	movl   $0x801482,0x4(%esp)
  8004b1:	00 
  8004b2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004b5:	89 14 24             	mov    %edx,(%esp)
  8004b8:	e8 ee 04 00 00       	call   8009ab <strcmp>
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	75 0f                	jne    8004d0 <vprintfmt+0x1be>
  8004c1:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8004c8:	00 00 00 
  8004cb:	e9 65 fe ff ff       	jmp    800335 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004d0:	c7 44 24 04 86 14 80 	movl   $0x801486,0x4(%esp)
  8004d7:	00 
  8004d8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8004db:	89 0c 24             	mov    %ecx,(%esp)
  8004de:	e8 c8 04 00 00       	call   8009ab <strcmp>
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	75 0f                	jne    8004f6 <vprintfmt+0x1e4>
  8004e7:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8004ee:	00 00 00 
  8004f1:	e9 3f fe ff ff       	jmp    800335 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8004f6:	c7 44 24 04 8a 14 80 	movl   $0x80148a,0x4(%esp)
  8004fd:	00 
  8004fe:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800501:	89 3c 24             	mov    %edi,(%esp)
  800504:	e8 a2 04 00 00       	call   8009ab <strcmp>
  800509:	85 c0                	test   %eax,%eax
  80050b:	75 0f                	jne    80051c <vprintfmt+0x20a>
  80050d:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800514:	00 00 00 
  800517:	e9 19 fe ff ff       	jmp    800335 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80051c:	c7 44 24 04 8e 14 80 	movl   $0x80148e,0x4(%esp)
  800523:	00 
  800524:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	e8 7c 04 00 00       	call   8009ab <strcmp>
  80052f:	85 c0                	test   %eax,%eax
  800531:	75 0f                	jne    800542 <vprintfmt+0x230>
  800533:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80053a:	00 00 00 
  80053d:	e9 f3 fd ff ff       	jmp    800335 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800542:	c7 44 24 04 92 14 80 	movl   $0x801492,0x4(%esp)
  800549:	00 
  80054a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80054d:	89 14 24             	mov    %edx,(%esp)
  800550:	e8 56 04 00 00       	call   8009ab <strcmp>
  800555:	83 f8 01             	cmp    $0x1,%eax
  800558:	19 c0                	sbb    %eax,%eax
  80055a:	f7 d0                	not    %eax
  80055c:	83 c0 08             	add    $0x8,%eax
  80055f:	a3 04 20 80 00       	mov    %eax,0x802004
  800564:	e9 cc fd ff ff       	jmp    800335 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 c2                	mov    %eax,%edx
  800576:	c1 fa 1f             	sar    $0x1f,%edx
  800579:	31 d0                	xor    %edx,%eax
  80057b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057d:	83 f8 08             	cmp    $0x8,%eax
  800580:	7f 0b                	jg     80058d <vprintfmt+0x27b>
  800582:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  800589:	85 d2                	test   %edx,%edx
  80058b:	75 23                	jne    8005b0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80058d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800591:	c7 44 24 08 96 14 80 	movl   $0x801496,0x8(%esp)
  800598:	00 
  800599:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a0:	89 3c 24             	mov    %edi,(%esp)
  8005a3:	e8 42 fd ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005ab:	e9 85 fd ff ff       	jmp    800335 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b4:	c7 44 24 08 9f 14 80 	movl   $0x80149f,0x8(%esp)
  8005bb:	00 
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005c3:	89 3c 24             	mov    %edi,(%esp)
  8005c6:	e8 1f fd ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005ce:	e9 62 fd ff ff       	jmp    800335 <vprintfmt+0x23>
  8005d3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8005d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005d9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005e7:	85 f6                	test   %esi,%esi
  8005e9:	b8 77 14 80 00       	mov    $0x801477,%eax
  8005ee:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005f1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005f5:	7e 06                	jle    8005fd <vprintfmt+0x2eb>
  8005f7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005fb:	75 13                	jne    800610 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fd:	0f be 06             	movsbl (%esi),%eax
  800600:	83 c6 01             	add    $0x1,%esi
  800603:	85 c0                	test   %eax,%eax
  800605:	0f 85 94 00 00 00    	jne    80069f <vprintfmt+0x38d>
  80060b:	e9 81 00 00 00       	jmp    800691 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800610:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800614:	89 34 24             	mov    %esi,(%esp)
  800617:	e8 9f 02 00 00       	call   8008bb <strnlen>
  80061c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80061f:	29 c2                	sub    %eax,%edx
  800621:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800624:	85 d2                	test   %edx,%edx
  800626:	7e d5                	jle    8005fd <vprintfmt+0x2eb>
					putch(padc, putdat);
  800628:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80062c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80062f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800632:	89 d6                	mov    %edx,%esi
  800634:	89 cf                	mov    %ecx,%edi
  800636:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063a:	89 3c 24             	mov    %edi,(%esp)
  80063d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800640:	83 ee 01             	sub    $0x1,%esi
  800643:	75 f1                	jne    800636 <vprintfmt+0x324>
  800645:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800648:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80064b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80064e:	eb ad                	jmp    8005fd <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800650:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800654:	74 1b                	je     800671 <vprintfmt+0x35f>
  800656:	8d 50 e0             	lea    -0x20(%eax),%edx
  800659:	83 fa 5e             	cmp    $0x5e,%edx
  80065c:	76 13                	jbe    800671 <vprintfmt+0x35f>
					putch('?', putdat);
  80065e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800661:	89 44 24 04          	mov    %eax,0x4(%esp)
  800665:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80066c:	ff 55 08             	call   *0x8(%ebp)
  80066f:	eb 0d                	jmp    80067e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800671:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800674:	89 54 24 04          	mov    %edx,0x4(%esp)
  800678:	89 04 24             	mov    %eax,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067e:	83 eb 01             	sub    $0x1,%ebx
  800681:	0f be 06             	movsbl (%esi),%eax
  800684:	83 c6 01             	add    $0x1,%esi
  800687:	85 c0                	test   %eax,%eax
  800689:	75 1a                	jne    8006a5 <vprintfmt+0x393>
  80068b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80068e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800694:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800698:	7f 1c                	jg     8006b6 <vprintfmt+0x3a4>
  80069a:	e9 96 fc ff ff       	jmp    800335 <vprintfmt+0x23>
  80069f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006a2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	78 a7                	js     800650 <vprintfmt+0x33e>
  8006a9:	83 ef 01             	sub    $0x1,%edi
  8006ac:	79 a2                	jns    800650 <vprintfmt+0x33e>
  8006ae:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006b1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b4:	eb db                	jmp    800691 <vprintfmt+0x37f>
  8006b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b9:	89 de                	mov    %ebx,%esi
  8006bb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cb:	83 eb 01             	sub    $0x1,%ebx
  8006ce:	75 ee                	jne    8006be <vprintfmt+0x3ac>
  8006d0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006d5:	e9 5b fc ff ff       	jmp    800335 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006da:	83 f9 01             	cmp    $0x1,%ecx
  8006dd:	7e 10                	jle    8006ef <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 08             	lea    0x8(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 30                	mov    (%eax),%esi
  8006ea:	8b 78 04             	mov    0x4(%eax),%edi
  8006ed:	eb 26                	jmp    800715 <vprintfmt+0x403>
	else if (lflag)
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	74 12                	je     800705 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 50 04             	lea    0x4(%eax),%edx
  8006f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fc:	8b 30                	mov    (%eax),%esi
  8006fe:	89 f7                	mov    %esi,%edi
  800700:	c1 ff 1f             	sar    $0x1f,%edi
  800703:	eb 10                	jmp    800715 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8d 50 04             	lea    0x4(%eax),%edx
  80070b:	89 55 14             	mov    %edx,0x14(%ebp)
  80070e:	8b 30                	mov    (%eax),%esi
  800710:	89 f7                	mov    %esi,%edi
  800712:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800715:	85 ff                	test   %edi,%edi
  800717:	78 0e                	js     800727 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800719:	89 f0                	mov    %esi,%eax
  80071b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	be 0a 00 00 00       	mov    $0xa,%esi
  800722:	e9 84 00 00 00       	jmp    8007ab <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800727:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800732:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800735:	89 f0                	mov    %esi,%eax
  800737:	89 fa                	mov    %edi,%edx
  800739:	f7 d8                	neg    %eax
  80073b:	83 d2 00             	adc    $0x0,%edx
  80073e:	f7 da                	neg    %edx
			}
			base = 10;
  800740:	be 0a 00 00 00       	mov    $0xa,%esi
  800745:	eb 64                	jmp    8007ab <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	89 ca                	mov    %ecx,%edx
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
  80074c:	e8 42 fb ff ff       	call   800293 <getuint>
			base = 10;
  800751:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800756:	eb 53                	jmp    8007ab <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800758:	89 ca                	mov    %ecx,%edx
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 31 fb ff ff       	call   800293 <getuint>
    			base = 8;
  800762:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800767:	eb 42                	jmp    8007ab <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800769:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800774:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800777:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800782:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078e:	8b 00                	mov    (%eax),%eax
  800790:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800795:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80079a:	eb 0f                	jmp    8007ab <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079c:	89 ca                	mov    %ecx,%edx
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 ed fa ff ff       	call   800293 <getuint>
			base = 16;
  8007a6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ab:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007af:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007b3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007b6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c5:	89 da                	mov    %ebx,%edx
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	e8 e9 f9 ff ff       	call   8001b8 <printnum>
			break;
  8007cf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007d2:	e9 5e fb ff ff       	jmp    800335 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007db:	89 14 24             	mov    %edx,(%esp)
  8007de:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e4:	e9 4c fb ff ff       	jmp    800335 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007fb:	0f 84 34 fb ff ff    	je     800335 <vprintfmt+0x23>
  800801:	83 ee 01             	sub    $0x1,%esi
  800804:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800808:	75 f7                	jne    800801 <vprintfmt+0x4ef>
  80080a:	e9 26 fb ff ff       	jmp    800335 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80080f:	83 c4 5c             	add    $0x5c,%esp
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5f                   	pop    %edi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	83 ec 28             	sub    $0x28,%esp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800823:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800826:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800834:	85 c0                	test   %eax,%eax
  800836:	74 30                	je     800868 <vsnprintf+0x51>
  800838:	85 d2                	test   %edx,%edx
  80083a:	7e 2c                	jle    800868 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800843:	8b 45 10             	mov    0x10(%ebp),%eax
  800846:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	c7 04 24 cd 02 80 00 	movl   $0x8002cd,(%esp)
  800858:	e8 b5 fa ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800860:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800866:	eb 05                	jmp    80086d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800868:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800878:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087c:	8b 45 10             	mov    0x10(%ebp),%eax
  80087f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800883:	8b 45 0c             	mov    0xc(%ebp),%eax
  800886:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	89 04 24             	mov    %eax,(%esp)
  800890:	e8 82 ff ff ff       	call   800817 <vsnprintf>
	va_end(ap);

	return rc;
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    
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
  800d63:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800d7a:	e8 b9 03 00 00       	call   801138 <_panic>

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
  800dd0:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800e22:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e31:	00 
  800e32:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800e39:	e8 fa 02 00 00       	call   801138 <_panic>

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
  800e80:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800e87:	00 
  800e88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8f:	00 
  800e90:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800e97:	e8 9c 02 00 00       	call   801138 <_panic>

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
  800ede:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800ef5:	e8 3e 02 00 00       	call   801138 <_panic>

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
  800f3c:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800f43:	00 
  800f44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4b:	00 
  800f4c:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800f53:	e8 e0 01 00 00       	call   801138 <_panic>

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

00800f65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800f8c:	7e 28                	jle    800fb6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f92:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f99:	00 
  800f9a:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa9:	00 
  800faa:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800fb1:	e8 82 01 00 00       	call   801138 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fb6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fbf:	89 ec                	mov    %ebp,%esp
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fcc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fcf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	be 00 00 00 00       	mov    $0x0,%esi
  800fd7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff3:	89 ec                	mov    %ebp,%esp
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 38             	sub    $0x38,%esp
  800ffd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801000:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801003:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
  801013:	89 cb                	mov    %ecx,%ebx
  801015:	89 cf                	mov    %ecx,%edi
  801017:	89 ce                	mov    %ecx,%esi
  801019:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7e 28                	jle    801047 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801023:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80102a:	00 
  80102b:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103a:	00 
  80103b:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  801042:	e8 f1 00 00 00       	call   801138 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801047:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801050:	89 ec                	mov    %ebp,%esp
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80105d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801060:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801063:	b9 00 00 00 00       	mov    $0x0,%ecx
  801068:	b8 0d 00 00 00       	mov    $0xd,%eax
  80106d:	8b 55 08             	mov    0x8(%ebp),%edx
  801070:	89 cb                	mov    %ecx,%ebx
  801072:	89 cf                	mov    %ecx,%edi
  801074:	89 ce                	mov    %ecx,%esi
  801076:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  801078:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801081:	89 ec                	mov    %ebp,%esp
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    
  801085:	00 00                	add    %al,(%eax)
	...

00801088 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80108e:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801095:	75 3c                	jne    8010d3 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801097:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80109e:	00 
  80109f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010a6:	ee 
  8010a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ae:	e8 39 fd ff ff       	call   800dec <sys_page_alloc>
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 1c                	jns    8010d3 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8010b7:	c7 44 24 08 f0 16 80 	movl   $0x8016f0,0x8(%esp)
  8010be:	00 
  8010bf:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8010c6:	00 
  8010c7:	c7 04 24 52 17 80 00 	movl   $0x801752,(%esp)
  8010ce:	e8 65 00 00 00       	call   801138 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8010db:	c7 44 24 04 14 11 80 	movl   $0x801114,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ea:	e8 76 fe ff ff       	call   800f65 <sys_env_set_pgfault_upcall>
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	79 1c                	jns    80110f <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8010f3:	c7 44 24 08 1c 17 80 	movl   $0x80171c,0x8(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801102:	00 
  801103:	c7 04 24 52 17 80 00 	movl   $0x801752,(%esp)
  80110a:	e8 29 00 00 00       	call   801138 <_panic>
}
  80110f:	c9                   	leave  
  801110:	c3                   	ret    
  801111:	00 00                	add    %al,(%eax)
	...

00801114 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801114:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801115:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80111a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80111c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80111f:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  801123:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801128:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80112c:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80112e:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  801131:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  801132:	83 c4 04             	add    $0x4,%esp
    popfl
  801135:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  801136:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  801137:	c3                   	ret    

00801138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801140:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801143:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801149:	e8 3e fc ff ff       	call   800d8c <sys_getenvid>
  80114e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801151:	89 54 24 10          	mov    %edx,0x10(%esp)
  801155:	8b 55 08             	mov    0x8(%ebp),%edx
  801158:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80115c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801160:	89 44 24 04          	mov    %eax,0x4(%esp)
  801164:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  80116b:	e8 2b f0 ff ff       	call   80019b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801170:	89 74 24 04          	mov    %esi,0x4(%esp)
  801174:	8b 45 10             	mov    0x10(%ebp),%eax
  801177:	89 04 24             	mov    %eax,(%esp)
  80117a:	e8 bb ef ff ff       	call   80013a <vcprintf>
	cprintf("\n");
  80117f:	c7 04 24 5a 14 80 00 	movl   $0x80145a,(%esp)
  801186:	e8 10 f0 ff ff       	call   80019b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80118b:	cc                   	int3   
  80118c:	eb fd                	jmp    80118b <_panic+0x53>
	...

00801190 <__udivdi3>:
  801190:	83 ec 1c             	sub    $0x1c,%esp
  801193:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801197:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80119b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80119f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011a3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011ab:	85 ff                	test   %edi,%edi
  8011ad:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b5:	89 cd                	mov    %ecx,%ebp
  8011b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011bb:	75 33                	jne    8011f0 <__udivdi3+0x60>
  8011bd:	39 f1                	cmp    %esi,%ecx
  8011bf:	77 57                	ja     801218 <__udivdi3+0x88>
  8011c1:	85 c9                	test   %ecx,%ecx
  8011c3:	75 0b                	jne    8011d0 <__udivdi3+0x40>
  8011c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ca:	31 d2                	xor    %edx,%edx
  8011cc:	f7 f1                	div    %ecx
  8011ce:	89 c1                	mov    %eax,%ecx
  8011d0:	89 f0                	mov    %esi,%eax
  8011d2:	31 d2                	xor    %edx,%edx
  8011d4:	f7 f1                	div    %ecx
  8011d6:	89 c6                	mov    %eax,%esi
  8011d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011dc:	f7 f1                	div    %ecx
  8011de:	89 f2                	mov    %esi,%edx
  8011e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ec:	83 c4 1c             	add    $0x1c,%esp
  8011ef:	c3                   	ret    
  8011f0:	31 d2                	xor    %edx,%edx
  8011f2:	31 c0                	xor    %eax,%eax
  8011f4:	39 f7                	cmp    %esi,%edi
  8011f6:	77 e8                	ja     8011e0 <__udivdi3+0x50>
  8011f8:	0f bd cf             	bsr    %edi,%ecx
  8011fb:	83 f1 1f             	xor    $0x1f,%ecx
  8011fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801202:	75 2c                	jne    801230 <__udivdi3+0xa0>
  801204:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801208:	76 04                	jbe    80120e <__udivdi3+0x7e>
  80120a:	39 f7                	cmp    %esi,%edi
  80120c:	73 d2                	jae    8011e0 <__udivdi3+0x50>
  80120e:	31 d2                	xor    %edx,%edx
  801210:	b8 01 00 00 00       	mov    $0x1,%eax
  801215:	eb c9                	jmp    8011e0 <__udivdi3+0x50>
  801217:	90                   	nop
  801218:	89 f2                	mov    %esi,%edx
  80121a:	f7 f1                	div    %ecx
  80121c:	31 d2                	xor    %edx,%edx
  80121e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801222:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801226:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80122a:	83 c4 1c             	add    $0x1c,%esp
  80122d:	c3                   	ret    
  80122e:	66 90                	xchg   %ax,%ax
  801230:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801235:	b8 20 00 00 00       	mov    $0x20,%eax
  80123a:	89 ea                	mov    %ebp,%edx
  80123c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801240:	d3 e7                	shl    %cl,%edi
  801242:	89 c1                	mov    %eax,%ecx
  801244:	d3 ea                	shr    %cl,%edx
  801246:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80124b:	09 fa                	or     %edi,%edx
  80124d:	89 f7                	mov    %esi,%edi
  80124f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801253:	89 f2                	mov    %esi,%edx
  801255:	8b 74 24 08          	mov    0x8(%esp),%esi
  801259:	d3 e5                	shl    %cl,%ebp
  80125b:	89 c1                	mov    %eax,%ecx
  80125d:	d3 ef                	shr    %cl,%edi
  80125f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801264:	d3 e2                	shl    %cl,%edx
  801266:	89 c1                	mov    %eax,%ecx
  801268:	d3 ee                	shr    %cl,%esi
  80126a:	09 d6                	or     %edx,%esi
  80126c:	89 fa                	mov    %edi,%edx
  80126e:	89 f0                	mov    %esi,%eax
  801270:	f7 74 24 0c          	divl   0xc(%esp)
  801274:	89 d7                	mov    %edx,%edi
  801276:	89 c6                	mov    %eax,%esi
  801278:	f7 e5                	mul    %ebp
  80127a:	39 d7                	cmp    %edx,%edi
  80127c:	72 22                	jb     8012a0 <__udivdi3+0x110>
  80127e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801282:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801287:	d3 e5                	shl    %cl,%ebp
  801289:	39 c5                	cmp    %eax,%ebp
  80128b:	73 04                	jae    801291 <__udivdi3+0x101>
  80128d:	39 d7                	cmp    %edx,%edi
  80128f:	74 0f                	je     8012a0 <__udivdi3+0x110>
  801291:	89 f0                	mov    %esi,%eax
  801293:	31 d2                	xor    %edx,%edx
  801295:	e9 46 ff ff ff       	jmp    8011e0 <__udivdi3+0x50>
  80129a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8012a3:	31 d2                	xor    %edx,%edx
  8012a5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012a9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012ad:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012b1:	83 c4 1c             	add    $0x1c,%esp
  8012b4:	c3                   	ret    
	...

008012c0 <__umoddi3>:
  8012c0:	83 ec 1c             	sub    $0x1c,%esp
  8012c3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8012c7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8012cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8012cf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012d3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8012db:	85 ed                	test   %ebp,%ebp
  8012dd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8012e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e5:	89 cf                	mov    %ecx,%edi
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	89 f2                	mov    %esi,%edx
  8012ec:	75 1a                	jne    801308 <__umoddi3+0x48>
  8012ee:	39 f1                	cmp    %esi,%ecx
  8012f0:	76 4e                	jbe    801340 <__umoddi3+0x80>
  8012f2:	f7 f1                	div    %ecx
  8012f4:	89 d0                	mov    %edx,%eax
  8012f6:	31 d2                	xor    %edx,%edx
  8012f8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012fc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801300:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801304:	83 c4 1c             	add    $0x1c,%esp
  801307:	c3                   	ret    
  801308:	39 f5                	cmp    %esi,%ebp
  80130a:	77 54                	ja     801360 <__umoddi3+0xa0>
  80130c:	0f bd c5             	bsr    %ebp,%eax
  80130f:	83 f0 1f             	xor    $0x1f,%eax
  801312:	89 44 24 04          	mov    %eax,0x4(%esp)
  801316:	75 60                	jne    801378 <__umoddi3+0xb8>
  801318:	3b 0c 24             	cmp    (%esp),%ecx
  80131b:	0f 87 07 01 00 00    	ja     801428 <__umoddi3+0x168>
  801321:	89 f2                	mov    %esi,%edx
  801323:	8b 34 24             	mov    (%esp),%esi
  801326:	29 ce                	sub    %ecx,%esi
  801328:	19 ea                	sbb    %ebp,%edx
  80132a:	89 34 24             	mov    %esi,(%esp)
  80132d:	8b 04 24             	mov    (%esp),%eax
  801330:	8b 74 24 10          	mov    0x10(%esp),%esi
  801334:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801338:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80133c:	83 c4 1c             	add    $0x1c,%esp
  80133f:	c3                   	ret    
  801340:	85 c9                	test   %ecx,%ecx
  801342:	75 0b                	jne    80134f <__umoddi3+0x8f>
  801344:	b8 01 00 00 00       	mov    $0x1,%eax
  801349:	31 d2                	xor    %edx,%edx
  80134b:	f7 f1                	div    %ecx
  80134d:	89 c1                	mov    %eax,%ecx
  80134f:	89 f0                	mov    %esi,%eax
  801351:	31 d2                	xor    %edx,%edx
  801353:	f7 f1                	div    %ecx
  801355:	8b 04 24             	mov    (%esp),%eax
  801358:	f7 f1                	div    %ecx
  80135a:	eb 98                	jmp    8012f4 <__umoddi3+0x34>
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	89 f2                	mov    %esi,%edx
  801362:	8b 74 24 10          	mov    0x10(%esp),%esi
  801366:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80136a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80136e:	83 c4 1c             	add    $0x1c,%esp
  801371:	c3                   	ret    
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80137d:	89 e8                	mov    %ebp,%eax
  80137f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801384:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801388:	89 fa                	mov    %edi,%edx
  80138a:	d3 e0                	shl    %cl,%eax
  80138c:	89 e9                	mov    %ebp,%ecx
  80138e:	d3 ea                	shr    %cl,%edx
  801390:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801395:	09 c2                	or     %eax,%edx
  801397:	8b 44 24 08          	mov    0x8(%esp),%eax
  80139b:	89 14 24             	mov    %edx,(%esp)
  80139e:	89 f2                	mov    %esi,%edx
  8013a0:	d3 e7                	shl    %cl,%edi
  8013a2:	89 e9                	mov    %ebp,%ecx
  8013a4:	d3 ea                	shr    %cl,%edx
  8013a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013af:	d3 e6                	shl    %cl,%esi
  8013b1:	89 e9                	mov    %ebp,%ecx
  8013b3:	d3 e8                	shr    %cl,%eax
  8013b5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013ba:	09 f0                	or     %esi,%eax
  8013bc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8013c0:	f7 34 24             	divl   (%esp)
  8013c3:	d3 e6                	shl    %cl,%esi
  8013c5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013c9:	89 d6                	mov    %edx,%esi
  8013cb:	f7 e7                	mul    %edi
  8013cd:	39 d6                	cmp    %edx,%esi
  8013cf:	89 c1                	mov    %eax,%ecx
  8013d1:	89 d7                	mov    %edx,%edi
  8013d3:	72 3f                	jb     801414 <__umoddi3+0x154>
  8013d5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013d9:	72 35                	jb     801410 <__umoddi3+0x150>
  8013db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013df:	29 c8                	sub    %ecx,%eax
  8013e1:	19 fe                	sbb    %edi,%esi
  8013e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013e8:	89 f2                	mov    %esi,%edx
  8013ea:	d3 e8                	shr    %cl,%eax
  8013ec:	89 e9                	mov    %ebp,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013f5:	09 d0                	or     %edx,%eax
  8013f7:	89 f2                	mov    %esi,%edx
  8013f9:	d3 ea                	shr    %cl,%edx
  8013fb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013ff:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801403:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801407:	83 c4 1c             	add    $0x1c,%esp
  80140a:	c3                   	ret    
  80140b:	90                   	nop
  80140c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801410:	39 d6                	cmp    %edx,%esi
  801412:	75 c7                	jne    8013db <__umoddi3+0x11b>
  801414:	89 d7                	mov    %edx,%edi
  801416:	89 c1                	mov    %eax,%ecx
  801418:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80141c:	1b 3c 24             	sbb    (%esp),%edi
  80141f:	eb ba                	jmp    8013db <__umoddi3+0x11b>
  801421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801428:	39 f5                	cmp    %esi,%ebp
  80142a:	0f 82 f1 fe ff ff    	jb     801321 <__umoddi3+0x61>
  801430:	e9 f8 fe ff ff       	jmp    80132d <__umoddi3+0x6d>
