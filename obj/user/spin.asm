
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  80004e:	e8 74 01 00 00       	call   8001c7 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 6e 12 00 00       	call   8012c6 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 98 19 80 00 	movl   $0x801998,(%esp)
  800065:	e8 5d 01 00 00       	call   8001c7 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  800073:	e8 4f 01 00 00       	call   8001c7 <cprintf>
	sys_yield();
  800078:	e8 6f 0d 00 00       	call   800dec <sys_yield>
	sys_yield();
  80007d:	e8 6a 0d 00 00       	call   800dec <sys_yield>
	sys_yield();
  800082:	e8 65 0d 00 00       	call   800dec <sys_yield>
	sys_yield();
  800087:	e8 60 0d 00 00       	call   800dec <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 57 0d 00 00       	call   800dec <sys_yield>
	sys_yield();
  800095:	e8 52 0d 00 00       	call   800dec <sys_yield>
	sys_yield();
  80009a:	e8 4d 0d 00 00       	call   800dec <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 47 0d 00 00       	call   800dec <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  8000ac:	e8 16 01 00 00       	call   8001c7 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 a6 0c 00 00       	call   800d5f <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d2:	e8 e5 0c 00 00       	call   800dbc <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	c1 e0 07             	shl    $0x7,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f8:	89 34 24             	mov    %esi,(%esp)
  8000fb:	e8 40 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
}
  800105:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800108:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
	...

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800116:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011d:	e8 3d 0c 00 00       	call   800d5f <sys_env_destroy>
}
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	53                   	push   %ebx
  800128:	83 ec 14             	sub    $0x14,%esp
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800137:	83 c0 01             	add    $0x1,%eax
  80013a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800141:	75 19                	jne    80015c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800143:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014a:	00 
  80014b:	8d 43 08             	lea    0x8(%ebx),%eax
  80014e:	89 04 24             	mov    %eax,(%esp)
  800151:	e8 aa 0b 00 00       	call   800d00 <sys_cputs>
		b->idx = 0;
  800156:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800160:	83 c4 14             	add    $0x14,%esp
  800163:	5b                   	pop    %ebx
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800176:	00 00 00 
	b.cnt = 0;
  800179:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800180:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800183:	8b 45 0c             	mov    0xc(%ebp),%eax
  800186:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018a:	8b 45 08             	mov    0x8(%ebp),%eax
  80018d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800191:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019b:	c7 04 24 24 01 80 00 	movl   $0x800124,(%esp)
  8001a2:	e8 97 01 00 00       	call   80033e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 41 0b 00 00       	call   800d00 <sys_cputs>

	return b.cnt;
}
  8001bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	e8 87 ff ff ff       	call   800166 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    
  8001e1:	00 00                	add    %al,(%eax)
	...

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 3c             	sub    $0x3c,%esp
  8001ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f0:	89 d7                	mov    %edx,%edi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800201:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800204:	b8 00 00 00 00       	mov    $0x0,%eax
  800209:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80020c:	72 11                	jb     80021f <printnum+0x3b>
  80020e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800211:	39 45 10             	cmp    %eax,0x10(%ebp)
  800214:	76 09                	jbe    80021f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800216:	83 eb 01             	sub    $0x1,%ebx
  800219:	85 db                	test   %ebx,%ebx
  80021b:	7f 51                	jg     80026e <printnum+0x8a>
  80021d:	eb 5e                	jmp    80027d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800223:	83 eb 01             	sub    $0x1,%ebx
  800226:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80022a:	8b 45 10             	mov    0x10(%ebp),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800235:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800239:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800240:	00 
  800241:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	e8 0d 14 00 00       	call   801660 <__udivdi3>
  800253:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800257:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800262:	89 fa                	mov    %edi,%edx
  800264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800267:	e8 78 ff ff ff       	call   8001e4 <printnum>
  80026c:	eb 0f                	jmp    80027d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800272:	89 34 24             	mov    %esi,(%esp)
  800275:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	75 f1                	jne    80026e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800281:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800285:	8b 45 10             	mov    0x10(%ebp),%eax
  800288:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800293:	00 
  800294:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	e8 ea 14 00 00       	call   801790 <__umoddi3>
  8002a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002aa:	0f be 80 c0 19 80 00 	movsbl 0x8019c0(%eax),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b7:	83 c4 3c             	add    $0x3c,%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c2:	83 fa 01             	cmp    $0x1,%edx
  8002c5:	7e 0e                	jle    8002d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 02                	mov    (%edx),%eax
  8002d0:	8b 52 04             	mov    0x4(%edx),%edx
  8002d3:	eb 22                	jmp    8002f7 <getuint+0x38>
	else if (lflag)
  8002d5:	85 d2                	test   %edx,%edx
  8002d7:	74 10                	je     8002e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	eb 0e                	jmp    8002f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800303:	8b 10                	mov    (%eax),%edx
  800305:	3b 50 04             	cmp    0x4(%eax),%edx
  800308:	73 0a                	jae    800314 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030d:	88 0a                	mov    %cl,(%edx)
  80030f:	83 c2 01             	add    $0x1,%edx
  800312:	89 10                	mov    %edx,(%eax)
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80031c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800323:	8b 45 10             	mov    0x10(%ebp),%eax
  800326:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 02 00 00 00       	call   80033e <vprintfmt>
	va_end(ap);
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	57                   	push   %edi
  800342:	56                   	push   %esi
  800343:	53                   	push   %ebx
  800344:	83 ec 5c             	sub    $0x5c,%esp
  800347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034a:	8b 75 10             	mov    0x10(%ebp),%esi
  80034d:	eb 12                	jmp    800361 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034f:	85 c0                	test   %eax,%eax
  800351:	0f 84 e4 04 00 00    	je     80083b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800357:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800361:	0f b6 06             	movzbl (%esi),%eax
  800364:	83 c6 01             	add    $0x1,%esi
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e3                	jne    80034f <vprintfmt+0x11>
  80036c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800370:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800377:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80037c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800383:	b9 00 00 00 00       	mov    $0x0,%ecx
  800388:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80038b:	eb 2b                	jmp    8003b8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800390:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800394:	eb 22                	jmp    8003b8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800399:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80039d:	eb 19                	jmp    8003b8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003a9:	eb 0d                	jmp    8003b8 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ab:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003b1:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	0f b6 06             	movzbl (%esi),%eax
  8003bb:	0f b6 d0             	movzbl %al,%edx
  8003be:	8d 7e 01             	lea    0x1(%esi),%edi
  8003c1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003c4:	83 e8 23             	sub    $0x23,%eax
  8003c7:	3c 55                	cmp    $0x55,%al
  8003c9:	0f 87 46 04 00 00    	ja     800815 <vprintfmt+0x4d7>
  8003cf:	0f b6 c0             	movzbl %al,%eax
  8003d2:	ff 24 85 a0 1a 80 00 	jmp    *0x801aa0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d9:	83 ea 30             	sub    $0x30,%edx
  8003dc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003df:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003e3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003e9:	83 fa 09             	cmp    $0x9,%edx
  8003ec:	77 4a                	ja     800438 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003f4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003f7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003fb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003fe:	8d 50 d0             	lea    -0x30(%eax),%edx
  800401:	83 fa 09             	cmp    $0x9,%edx
  800404:	76 eb                	jbe    8003f1 <vprintfmt+0xb3>
  800406:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800409:	eb 2d                	jmp    800438 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 00                	mov    (%eax),%eax
  800416:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041c:	eb 1a                	jmp    800438 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800421:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800425:	79 91                	jns    8003b8 <vprintfmt+0x7a>
  800427:	e9 73 ff ff ff       	jmp    80039f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800436:	eb 80                	jmp    8003b8 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800438:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80043c:	0f 89 76 ff ff ff    	jns    8003b8 <vprintfmt+0x7a>
  800442:	e9 64 ff ff ff       	jmp    8003ab <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044d:	e9 66 ff ff ff       	jmp    8003b8 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046a:	e9 f2 fe ff ff       	jmp    800361 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80046f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800473:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800476:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80047a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80047d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800481:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800484:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800487:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80048b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80048e:	80 f9 09             	cmp    $0x9,%cl
  800491:	77 1d                	ja     8004b0 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800493:	0f be c0             	movsbl %al,%eax
  800496:	6b c0 64             	imul   $0x64,%eax,%eax
  800499:	0f be d2             	movsbl %dl,%edx
  80049c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80049f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004a6:	a3 04 20 80 00       	mov    %eax,0x802004
  8004ab:	e9 b1 fe ff ff       	jmp    800361 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004b0:	c7 44 24 04 d8 19 80 	movl   $0x8019d8,0x4(%esp)
  8004b7:	00 
  8004b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004bb:	89 04 24             	mov    %eax,(%esp)
  8004be:	e8 18 05 00 00       	call   8009db <strcmp>
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	75 0f                	jne    8004d6 <vprintfmt+0x198>
  8004c7:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8004ce:	00 00 00 
  8004d1:	e9 8b fe ff ff       	jmp    800361 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004d6:	c7 44 24 04 dc 19 80 	movl   $0x8019dc,0x4(%esp)
  8004dd:	00 
  8004de:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004e1:	89 14 24             	mov    %edx,(%esp)
  8004e4:	e8 f2 04 00 00       	call   8009db <strcmp>
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 0f                	jne    8004fc <vprintfmt+0x1be>
  8004ed:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8004f4:	00 00 00 
  8004f7:	e9 65 fe ff ff       	jmp    800361 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8004fc:	c7 44 24 04 e0 19 80 	movl   $0x8019e0,0x4(%esp)
  800503:	00 
  800504:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800507:	89 0c 24             	mov    %ecx,(%esp)
  80050a:	e8 cc 04 00 00       	call   8009db <strcmp>
  80050f:	85 c0                	test   %eax,%eax
  800511:	75 0f                	jne    800522 <vprintfmt+0x1e4>
  800513:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  80051a:	00 00 00 
  80051d:	e9 3f fe ff ff       	jmp    800361 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800522:	c7 44 24 04 e4 19 80 	movl   $0x8019e4,0x4(%esp)
  800529:	00 
  80052a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80052d:	89 3c 24             	mov    %edi,(%esp)
  800530:	e8 a6 04 00 00       	call   8009db <strcmp>
  800535:	85 c0                	test   %eax,%eax
  800537:	75 0f                	jne    800548 <vprintfmt+0x20a>
  800539:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800540:	00 00 00 
  800543:	e9 19 fe ff ff       	jmp    800361 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800548:	c7 44 24 04 e8 19 80 	movl   $0x8019e8,0x4(%esp)
  80054f:	00 
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	e8 80 04 00 00       	call   8009db <strcmp>
  80055b:	85 c0                	test   %eax,%eax
  80055d:	75 0f                	jne    80056e <vprintfmt+0x230>
  80055f:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800566:	00 00 00 
  800569:	e9 f3 fd ff ff       	jmp    800361 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80056e:	c7 44 24 04 ec 19 80 	movl   $0x8019ec,0x4(%esp)
  800575:	00 
  800576:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800579:	89 14 24             	mov    %edx,(%esp)
  80057c:	e8 5a 04 00 00       	call   8009db <strcmp>
  800581:	83 f8 01             	cmp    $0x1,%eax
  800584:	19 c0                	sbb    %eax,%eax
  800586:	f7 d0                	not    %eax
  800588:	83 c0 08             	add    $0x8,%eax
  80058b:	a3 04 20 80 00       	mov    %eax,0x802004
  800590:	e9 cc fd ff ff       	jmp    800361 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 c2                	mov    %eax,%edx
  8005a2:	c1 fa 1f             	sar    $0x1f,%edx
  8005a5:	31 d0                	xor    %edx,%eax
  8005a7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a9:	83 f8 08             	cmp    $0x8,%eax
  8005ac:	7f 0b                	jg     8005b9 <vprintfmt+0x27b>
  8005ae:	8b 14 85 00 1c 80 00 	mov    0x801c00(,%eax,4),%edx
  8005b5:	85 d2                	test   %edx,%edx
  8005b7:	75 23                	jne    8005dc <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bd:	c7 44 24 08 f0 19 80 	movl   $0x8019f0,0x8(%esp)
  8005c4:	00 
  8005c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cc:	89 3c 24             	mov    %edi,(%esp)
  8005cf:	e8 42 fd ff ff       	call   800316 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d7:	e9 85 fd ff ff       	jmp    800361 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e0:	c7 44 24 08 f9 19 80 	movl   $0x8019f9,0x8(%esp)
  8005e7:	00 
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ef:	89 3c 24             	mov    %edi,(%esp)
  8005f2:	e8 1f fd ff ff       	call   800316 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005fa:	e9 62 fd ff ff       	jmp    800361 <vprintfmt+0x23>
  8005ff:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800602:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800605:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800613:	85 f6                	test   %esi,%esi
  800615:	b8 d1 19 80 00       	mov    $0x8019d1,%eax
  80061a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80061d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800621:	7e 06                	jle    800629 <vprintfmt+0x2eb>
  800623:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800627:	75 13                	jne    80063c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800629:	0f be 06             	movsbl (%esi),%eax
  80062c:	83 c6 01             	add    $0x1,%esi
  80062f:	85 c0                	test   %eax,%eax
  800631:	0f 85 94 00 00 00    	jne    8006cb <vprintfmt+0x38d>
  800637:	e9 81 00 00 00       	jmp    8006bd <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800640:	89 34 24             	mov    %esi,(%esp)
  800643:	e8 a3 02 00 00       	call   8008eb <strnlen>
  800648:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80064b:	29 c2                	sub    %eax,%edx
  80064d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800650:	85 d2                	test   %edx,%edx
  800652:	7e d5                	jle    800629 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800654:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800658:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80065b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80065e:	89 d6                	mov    %edx,%esi
  800660:	89 cf                	mov    %ecx,%edi
  800662:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800666:	89 3c 24             	mov    %edi,(%esp)
  800669:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066c:	83 ee 01             	sub    $0x1,%esi
  80066f:	75 f1                	jne    800662 <vprintfmt+0x324>
  800671:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800674:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800677:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80067a:	eb ad                	jmp    800629 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80067c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800680:	74 1b                	je     80069d <vprintfmt+0x35f>
  800682:	8d 50 e0             	lea    -0x20(%eax),%edx
  800685:	83 fa 5e             	cmp    $0x5e,%edx
  800688:	76 13                	jbe    80069d <vprintfmt+0x35f>
					putch('?', putdat);
  80068a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80068d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800691:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
  80069b:	eb 0d                	jmp    8006aa <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80069d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006aa:	83 eb 01             	sub    $0x1,%ebx
  8006ad:	0f be 06             	movsbl (%esi),%eax
  8006b0:	83 c6 01             	add    $0x1,%esi
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	75 1a                	jne    8006d1 <vprintfmt+0x393>
  8006b7:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006ba:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006c4:	7f 1c                	jg     8006e2 <vprintfmt+0x3a4>
  8006c6:	e9 96 fc ff ff       	jmp    800361 <vprintfmt+0x23>
  8006cb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006ce:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d1:	85 ff                	test   %edi,%edi
  8006d3:	78 a7                	js     80067c <vprintfmt+0x33e>
  8006d5:	83 ef 01             	sub    $0x1,%edi
  8006d8:	79 a2                	jns    80067c <vprintfmt+0x33e>
  8006da:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e0:	eb db                	jmp    8006bd <vprintfmt+0x37f>
  8006e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e5:	89 de                	mov    %ebx,%esi
  8006e7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f7:	83 eb 01             	sub    $0x1,%ebx
  8006fa:	75 ee                	jne    8006ea <vprintfmt+0x3ac>
  8006fc:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800701:	e9 5b fc ff ff       	jmp    800361 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800706:	83 f9 01             	cmp    $0x1,%ecx
  800709:	7e 10                	jle    80071b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8d 50 08             	lea    0x8(%eax),%edx
  800711:	89 55 14             	mov    %edx,0x14(%ebp)
  800714:	8b 30                	mov    (%eax),%esi
  800716:	8b 78 04             	mov    0x4(%eax),%edi
  800719:	eb 26                	jmp    800741 <vprintfmt+0x403>
	else if (lflag)
  80071b:	85 c9                	test   %ecx,%ecx
  80071d:	74 12                	je     800731 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8d 50 04             	lea    0x4(%eax),%edx
  800725:	89 55 14             	mov    %edx,0x14(%ebp)
  800728:	8b 30                	mov    (%eax),%esi
  80072a:	89 f7                	mov    %esi,%edi
  80072c:	c1 ff 1f             	sar    $0x1f,%edi
  80072f:	eb 10                	jmp    800741 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 30                	mov    (%eax),%esi
  80073c:	89 f7                	mov    %esi,%edi
  80073e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800741:	85 ff                	test   %edi,%edi
  800743:	78 0e                	js     800753 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800745:	89 f0                	mov    %esi,%eax
  800747:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800749:	be 0a 00 00 00       	mov    $0xa,%esi
  80074e:	e9 84 00 00 00       	jmp    8007d7 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800753:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800757:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80075e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800761:	89 f0                	mov    %esi,%eax
  800763:	89 fa                	mov    %edi,%edx
  800765:	f7 d8                	neg    %eax
  800767:	83 d2 00             	adc    $0x0,%edx
  80076a:	f7 da                	neg    %edx
			}
			base = 10;
  80076c:	be 0a 00 00 00       	mov    $0xa,%esi
  800771:	eb 64                	jmp    8007d7 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800773:	89 ca                	mov    %ecx,%edx
  800775:	8d 45 14             	lea    0x14(%ebp),%eax
  800778:	e8 42 fb ff ff       	call   8002bf <getuint>
			base = 10;
  80077d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800782:	eb 53                	jmp    8007d7 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800784:	89 ca                	mov    %ecx,%edx
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 31 fb ff ff       	call   8002bf <getuint>
    			base = 8;
  80078e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800793:	eb 42                	jmp    8007d7 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800795:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800799:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ae:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8d 50 04             	lea    0x4(%eax),%edx
  8007b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ba:	8b 00                	mov    (%eax),%eax
  8007bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c1:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007c6:	eb 0f                	jmp    8007d7 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c8:	89 ca                	mov    %ecx,%edx
  8007ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cd:	e8 ed fa ff ff       	call   8002bf <getuint>
			base = 16;
  8007d2:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d7:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007db:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007df:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007e2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007ea:	89 04 24             	mov    %eax,(%esp)
  8007ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f1:	89 da                	mov    %ebx,%edx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	e8 e9 f9 ff ff       	call   8001e4 <printnum>
			break;
  8007fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007fe:	e9 5e fb ff ff       	jmp    800361 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800803:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800807:	89 14 24             	mov    %edx,(%esp)
  80080a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800810:	e9 4c fb ff ff       	jmp    800361 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800815:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800819:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800820:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800823:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800827:	0f 84 34 fb ff ff    	je     800361 <vprintfmt+0x23>
  80082d:	83 ee 01             	sub    $0x1,%esi
  800830:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800834:	75 f7                	jne    80082d <vprintfmt+0x4ef>
  800836:	e9 26 fb ff ff       	jmp    800361 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80083b:	83 c4 5c             	add    $0x5c,%esp
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5f                   	pop    %edi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 28             	sub    $0x28,%esp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800852:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800856:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800859:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800860:	85 c0                	test   %eax,%eax
  800862:	74 30                	je     800894 <vsnprintf+0x51>
  800864:	85 d2                	test   %edx,%edx
  800866:	7e 2c                	jle    800894 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086f:	8b 45 10             	mov    0x10(%ebp),%eax
  800872:	89 44 24 08          	mov    %eax,0x8(%esp)
  800876:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087d:	c7 04 24 f9 02 80 00 	movl   $0x8002f9,(%esp)
  800884:	e8 b5 fa ff ff       	call   80033e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800889:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800892:	eb 05                	jmp    800899 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800894:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	89 04 24             	mov    %eax,(%esp)
  8008bc:	e8 82 ff ff ff       	call   800843 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    
	...

008008d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	80 3a 00             	cmpb   $0x0,(%edx)
  8008de:	74 09                	je     8008e9 <strlen+0x19>
		n++;
  8008e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e7:	75 f7                	jne    8008e0 <strlen+0x10>
		n++;
	return n;
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 1a                	je     800918 <strnlen+0x2d>
  8008fe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800901:	74 15                	je     800918 <strnlen+0x2d>
  800903:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800908:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090a:	39 ca                	cmp    %ecx,%edx
  80090c:	74 0a                	je     800918 <strnlen+0x2d>
  80090e:	83 c2 01             	add    $0x1,%edx
  800911:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800916:	75 f0                	jne    800908 <strnlen+0x1d>
		n++;
	return n;
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800925:	ba 00 00 00 00       	mov    $0x0,%edx
  80092a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80092e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800931:	83 c2 01             	add    $0x1,%edx
  800934:	84 c9                	test   %cl,%cl
  800936:	75 f2                	jne    80092a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800938:	5b                   	pop    %ebx
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	83 ec 08             	sub    $0x8,%esp
  800942:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800945:	89 1c 24             	mov    %ebx,(%esp)
  800948:	e8 83 ff ff ff       	call   8008d0 <strlen>
	strcpy(dst + len, src);
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 54 24 04          	mov    %edx,0x4(%esp)
  800954:	01 d8                	add    %ebx,%eax
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	e8 bd ff ff ff       	call   80091b <strcpy>
	return dst;
}
  80095e:	89 d8                	mov    %ebx,%eax
  800960:	83 c4 08             	add    $0x8,%esp
  800963:	5b                   	pop    %ebx
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800971:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800974:	85 f6                	test   %esi,%esi
  800976:	74 18                	je     800990 <strncpy+0x2a>
  800978:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80097d:	0f b6 1a             	movzbl (%edx),%ebx
  800980:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800983:	80 3a 01             	cmpb   $0x1,(%edx)
  800986:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	39 f1                	cmp    %esi,%ecx
  80098e:	75 ed                	jne    80097d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a3:	89 f8                	mov    %edi,%eax
  8009a5:	85 f6                	test   %esi,%esi
  8009a7:	74 2b                	je     8009d4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8009a9:	83 fe 01             	cmp    $0x1,%esi
  8009ac:	74 23                	je     8009d1 <strlcpy+0x3d>
  8009ae:	0f b6 0b             	movzbl (%ebx),%ecx
  8009b1:	84 c9                	test   %cl,%cl
  8009b3:	74 1c                	je     8009d1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009b5:	83 ee 02             	sub    $0x2,%esi
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009bd:	88 08                	mov    %cl,(%eax)
  8009bf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c2:	39 f2                	cmp    %esi,%edx
  8009c4:	74 0b                	je     8009d1 <strlcpy+0x3d>
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009cd:	84 c9                	test   %cl,%cl
  8009cf:	75 ec                	jne    8009bd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8009d1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009d4:	29 f8                	sub    %edi,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009e4:	0f b6 01             	movzbl (%ecx),%eax
  8009e7:	84 c0                	test   %al,%al
  8009e9:	74 16                	je     800a01 <strcmp+0x26>
  8009eb:	3a 02                	cmp    (%edx),%al
  8009ed:	75 12                	jne    800a01 <strcmp+0x26>
		p++, q++;
  8009ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8009f6:	84 c0                	test   %al,%al
  8009f8:	74 07                	je     800a01 <strcmp+0x26>
  8009fa:	83 c1 01             	add    $0x1,%ecx
  8009fd:	3a 02                	cmp    (%edx),%al
  8009ff:	74 ee                	je     8009ef <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 12             	movzbl (%edx),%edx
  800a07:	29 d0                	sub    %edx,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1d:	85 d2                	test   %edx,%edx
  800a1f:	74 28                	je     800a49 <strncmp+0x3e>
  800a21:	0f b6 01             	movzbl (%ecx),%eax
  800a24:	84 c0                	test   %al,%al
  800a26:	74 24                	je     800a4c <strncmp+0x41>
  800a28:	3a 03                	cmp    (%ebx),%al
  800a2a:	75 20                	jne    800a4c <strncmp+0x41>
  800a2c:	83 ea 01             	sub    $0x1,%edx
  800a2f:	74 13                	je     800a44 <strncmp+0x39>
		n--, p++, q++;
  800a31:	83 c1 01             	add    $0x1,%ecx
  800a34:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a37:	0f b6 01             	movzbl (%ecx),%eax
  800a3a:	84 c0                	test   %al,%al
  800a3c:	74 0e                	je     800a4c <strncmp+0x41>
  800a3e:	3a 03                	cmp    (%ebx),%al
  800a40:	74 ea                	je     800a2c <strncmp+0x21>
  800a42:	eb 08                	jmp    800a4c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4c:	0f b6 01             	movzbl (%ecx),%eax
  800a4f:	0f b6 13             	movzbl (%ebx),%edx
  800a52:	29 d0                	sub    %edx,%eax
  800a54:	eb f3                	jmp    800a49 <strncmp+0x3e>

00800a56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a60:	0f b6 10             	movzbl (%eax),%edx
  800a63:	84 d2                	test   %dl,%dl
  800a65:	74 1c                	je     800a83 <strchr+0x2d>
		if (*s == c)
  800a67:	38 ca                	cmp    %cl,%dl
  800a69:	75 09                	jne    800a74 <strchr+0x1e>
  800a6b:	eb 1b                	jmp    800a88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a70:	38 ca                	cmp    %cl,%dl
  800a72:	74 14                	je     800a88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a74:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f1                	jne    800a6d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a81:	eb 05                	jmp    800a88 <strchr+0x32>
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	0f b6 10             	movzbl (%eax),%edx
  800a97:	84 d2                	test   %dl,%dl
  800a99:	74 14                	je     800aaf <strfind+0x25>
		if (*s == c)
  800a9b:	38 ca                	cmp    %cl,%dl
  800a9d:	75 06                	jne    800aa5 <strfind+0x1b>
  800a9f:	eb 0e                	jmp    800aaf <strfind+0x25>
  800aa1:	38 ca                	cmp    %cl,%dl
  800aa3:	74 0a                	je     800aaf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	0f b6 10             	movzbl (%eax),%edx
  800aab:	84 d2                	test   %dl,%dl
  800aad:	75 f2                	jne    800aa1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 0c             	sub    $0xc,%esp
  800ab7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800aba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800abd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ac0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac9:	85 c9                	test   %ecx,%ecx
  800acb:	74 30                	je     800afd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800acd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad3:	75 25                	jne    800afa <memset+0x49>
  800ad5:	f6 c1 03             	test   $0x3,%cl
  800ad8:	75 20                	jne    800afa <memset+0x49>
		c &= 0xFF;
  800ada:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800add:	89 d3                	mov    %edx,%ebx
  800adf:	c1 e3 08             	shl    $0x8,%ebx
  800ae2:	89 d6                	mov    %edx,%esi
  800ae4:	c1 e6 18             	shl    $0x18,%esi
  800ae7:	89 d0                	mov    %edx,%eax
  800ae9:	c1 e0 10             	shl    $0x10,%eax
  800aec:	09 f0                	or     %esi,%eax
  800aee:	09 d0                	or     %edx,%eax
  800af0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800af2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af5:	fc                   	cld    
  800af6:	f3 ab                	rep stos %eax,%es:(%edi)
  800af8:	eb 03                	jmp    800afd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afa:	fc                   	cld    
  800afb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afd:	89 f8                	mov    %edi,%eax
  800aff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b08:	89 ec                	mov    %ebp,%esp
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b15:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b21:	39 c6                	cmp    %eax,%esi
  800b23:	73 36                	jae    800b5b <memmove+0x4f>
  800b25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b28:	39 d0                	cmp    %edx,%eax
  800b2a:	73 2f                	jae    800b5b <memmove+0x4f>
		s += n;
		d += n;
  800b2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2f:	f6 c2 03             	test   $0x3,%dl
  800b32:	75 1b                	jne    800b4f <memmove+0x43>
  800b34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3a:	75 13                	jne    800b4f <memmove+0x43>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 09                	jmp    800b58 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4f:	83 ef 01             	sub    $0x1,%edi
  800b52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b55:	fd                   	std    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b58:	fc                   	cld    
  800b59:	eb 20                	jmp    800b7b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b61:	75 13                	jne    800b76 <memmove+0x6a>
  800b63:	a8 03                	test   $0x3,%al
  800b65:	75 0f                	jne    800b76 <memmove+0x6a>
  800b67:	f6 c1 03             	test   $0x3,%cl
  800b6a:	75 0a                	jne    800b76 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b6c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b6f:	89 c7                	mov    %eax,%edi
  800b71:	fc                   	cld    
  800b72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b74:	eb 05                	jmp    800b7b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b76:	89 c7                	mov    %eax,%edi
  800b78:	fc                   	cld    
  800b79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b81:	89 ec                	mov    %ebp,%esp
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	89 04 24             	mov    %eax,(%esp)
  800b9f:	e8 68 ff ff ff       	call   800b0c <memmove>
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800baf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bba:	85 ff                	test   %edi,%edi
  800bbc:	74 37                	je     800bf5 <memcmp+0x4f>
		if (*s1 != *s2)
  800bbe:	0f b6 03             	movzbl (%ebx),%eax
  800bc1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc4:	83 ef 01             	sub    $0x1,%edi
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800bcc:	38 c8                	cmp    %cl,%al
  800bce:	74 1c                	je     800bec <memcmp+0x46>
  800bd0:	eb 10                	jmp    800be2 <memcmp+0x3c>
  800bd2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800bd7:	83 c2 01             	add    $0x1,%edx
  800bda:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bde:	38 c8                	cmp    %cl,%al
  800be0:	74 0a                	je     800bec <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800be2:	0f b6 c0             	movzbl %al,%eax
  800be5:	0f b6 c9             	movzbl %cl,%ecx
  800be8:	29 c8                	sub    %ecx,%eax
  800bea:	eb 09                	jmp    800bf5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bec:	39 fa                	cmp    %edi,%edx
  800bee:	75 e2                	jne    800bd2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c00:	89 c2                	mov    %eax,%edx
  800c02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c05:	39 d0                	cmp    %edx,%eax
  800c07:	73 19                	jae    800c22 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c0d:	38 08                	cmp    %cl,(%eax)
  800c0f:	75 06                	jne    800c17 <memfind+0x1d>
  800c11:	eb 0f                	jmp    800c22 <memfind+0x28>
  800c13:	38 08                	cmp    %cl,(%eax)
  800c15:	74 0b                	je     800c22 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c17:	83 c0 01             	add    $0x1,%eax
  800c1a:	39 d0                	cmp    %edx,%eax
  800c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c20:	75 f1                	jne    800c13 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c30:	0f b6 02             	movzbl (%edx),%eax
  800c33:	3c 20                	cmp    $0x20,%al
  800c35:	74 04                	je     800c3b <strtol+0x17>
  800c37:	3c 09                	cmp    $0x9,%al
  800c39:	75 0e                	jne    800c49 <strtol+0x25>
		s++;
  800c3b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3e:	0f b6 02             	movzbl (%edx),%eax
  800c41:	3c 20                	cmp    $0x20,%al
  800c43:	74 f6                	je     800c3b <strtol+0x17>
  800c45:	3c 09                	cmp    $0x9,%al
  800c47:	74 f2                	je     800c3b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c49:	3c 2b                	cmp    $0x2b,%al
  800c4b:	75 0a                	jne    800c57 <strtol+0x33>
		s++;
  800c4d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c50:	bf 00 00 00 00       	mov    $0x0,%edi
  800c55:	eb 10                	jmp    800c67 <strtol+0x43>
  800c57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c5c:	3c 2d                	cmp    $0x2d,%al
  800c5e:	75 07                	jne    800c67 <strtol+0x43>
		s++, neg = 1;
  800c60:	83 c2 01             	add    $0x1,%edx
  800c63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c67:	85 db                	test   %ebx,%ebx
  800c69:	0f 94 c0             	sete   %al
  800c6c:	74 05                	je     800c73 <strtol+0x4f>
  800c6e:	83 fb 10             	cmp    $0x10,%ebx
  800c71:	75 15                	jne    800c88 <strtol+0x64>
  800c73:	80 3a 30             	cmpb   $0x30,(%edx)
  800c76:	75 10                	jne    800c88 <strtol+0x64>
  800c78:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c7c:	75 0a                	jne    800c88 <strtol+0x64>
		s += 2, base = 16;
  800c7e:	83 c2 02             	add    $0x2,%edx
  800c81:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c86:	eb 13                	jmp    800c9b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c88:	84 c0                	test   %al,%al
  800c8a:	74 0f                	je     800c9b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c91:	80 3a 30             	cmpb   $0x30,(%edx)
  800c94:	75 05                	jne    800c9b <strtol+0x77>
		s++, base = 8;
  800c96:	83 c2 01             	add    $0x1,%edx
  800c99:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca2:	0f b6 0a             	movzbl (%edx),%ecx
  800ca5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ca8:	80 fb 09             	cmp    $0x9,%bl
  800cab:	77 08                	ja     800cb5 <strtol+0x91>
			dig = *s - '0';
  800cad:	0f be c9             	movsbl %cl,%ecx
  800cb0:	83 e9 30             	sub    $0x30,%ecx
  800cb3:	eb 1e                	jmp    800cd3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800cb5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cb8:	80 fb 19             	cmp    $0x19,%bl
  800cbb:	77 08                	ja     800cc5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800cbd:	0f be c9             	movsbl %cl,%ecx
  800cc0:	83 e9 57             	sub    $0x57,%ecx
  800cc3:	eb 0e                	jmp    800cd3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800cc5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cc8:	80 fb 19             	cmp    $0x19,%bl
  800ccb:	77 14                	ja     800ce1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ccd:	0f be c9             	movsbl %cl,%ecx
  800cd0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cd3:	39 f1                	cmp    %esi,%ecx
  800cd5:	7d 0e                	jge    800ce5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cd7:	83 c2 01             	add    $0x1,%edx
  800cda:	0f af c6             	imul   %esi,%eax
  800cdd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cdf:	eb c1                	jmp    800ca2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ce1:	89 c1                	mov    %eax,%ecx
  800ce3:	eb 02                	jmp    800ce7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ce5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ceb:	74 05                	je     800cf2 <strtol+0xce>
		*endptr = (char *) s;
  800ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cf0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cf2:	89 ca                	mov    %ecx,%edx
  800cf4:	f7 da                	neg    %edx
  800cf6:	85 ff                	test   %edi,%edi
  800cf8:	0f 45 c2             	cmovne %edx,%eax
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	89 c7                	mov    %eax,%edi
  800d1e:	89 c6                	mov    %eax,%esi
  800d20:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2b:	89 ec                	mov    %ebp,%esp
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d43:	b8 01 00 00 00       	mov    $0x1,%eax
  800d48:	89 d1                	mov    %edx,%ecx
  800d4a:	89 d3                	mov    %edx,%ebx
  800d4c:	89 d7                	mov    %edx,%edi
  800d4e:	89 d6                	mov    %edx,%esi
  800d50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5b:	89 ec                	mov    %ebp,%esp
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 38             	sub    $0x38,%esp
  800d65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d73:	b8 03 00 00 00       	mov    $0x3,%eax
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 cb                	mov    %ecx,%ebx
  800d7d:	89 cf                	mov    %ecx,%edi
  800d7f:	89 ce                	mov    %ecx,%esi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 28                	jle    800daf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d92:	00 
  800d93:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 41 1c 80 00 	movl   $0x801c41,(%esp)
  800daa:	e8 a1 07 00 00       	call   801550 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800dd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 d3                	mov    %edx,%ebx
  800dd9:	89 d7                	mov    %edx,%edi
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de8:	89 ec                	mov    %ebp,%esp
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_yield>:

void
sys_yield(void)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800e00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e05:	89 d1                	mov    %edx,%ecx
  800e07:	89 d3                	mov    %edx,%ebx
  800e09:	89 d7                	mov    %edx,%edi
  800e0b:	89 d6                	mov    %edx,%esi
  800e0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 38             	sub    $0x38,%esp
  800e22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	be 00 00 00 00       	mov    $0x0,%esi
  800e30:	b8 04 00 00 00       	mov    $0x4,%eax
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 f7                	mov    %esi,%edi
  800e40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 28                	jle    800e6e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e51:	00 
  800e52:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 41 1c 80 00 	movl   $0x801c41,(%esp)
  800e69:	e8 e2 06 00 00       	call   801550 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e6e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e71:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e74:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e77:	89 ec                	mov    %ebp,%esp
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 38             	sub    $0x38,%esp
  800e81:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e84:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e87:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 28                	jle    800ecc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 41 1c 80 00 	movl   $0x801c41,(%esp)
  800ec7:	e8 84 06 00 00       	call   801550 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ecc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed5:	89 ec                	mov    %ebp,%esp
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 38             	sub    $0x38,%esp
  800edf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eed:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef8:	89 df                	mov    %ebx,%edi
  800efa:	89 de                	mov    %ebx,%esi
  800efc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efe:	85 c0                	test   %eax,%eax
  800f00:	7e 28                	jle    800f2a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f06:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f0d:	00 
  800f0e:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  800f15:	00 
  800f16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1d:	00 
  800f1e:	c7 04 24 41 1c 80 00 	movl   $0x801c41,(%esp)
  800f25:	e8 26 06 00 00       	call   801550 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f2a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f30:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f33:	89 ec                	mov    %ebp,%esp
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 38             	sub    $0x38,%esp
  800f3d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f40:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f43:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	89 df                	mov    %ebx,%edi
  800f58:	89 de                	mov    %ebx,%esi
  800f5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 28                	jle    800f88 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f64:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 41 1c 80 00 	movl   $0x801c41,(%esp)
  800f83:	e8 c8 05 00 00       	call   801550 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f88:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f91:	89 ec                	mov    %ebp,%esp
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 38             	sub    $0x38,%esp
  800f9b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	89 df                	mov    %ebx,%edi
  800fb6:	89 de                	mov    %ebx,%esi
  800fb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	7e 28                	jle    800fe6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fc9:	00 
  800fca:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 41 1c 80 00 	movl   $0x801c41,(%esp)
  800fe1:	e8 6a 05 00 00       	call   801550 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fe6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fef:	89 ec                	mov    %ebp,%esp
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 0c             	sub    $0xc,%esp
  800ff9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ffc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801002:	be 00 00 00 00       	mov    $0x0,%esi
  801007:	b8 0b 00 00 00       	mov    $0xb,%eax
  80100c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80100f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801015:	8b 55 08             	mov    0x8(%ebp),%edx
  801018:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80101a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801020:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801023:	89 ec                	mov    %ebp,%esp
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 38             	sub    $0x38,%esp
  80102d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801030:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801033:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801036:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801040:	8b 55 08             	mov    0x8(%ebp),%edx
  801043:	89 cb                	mov    %ecx,%ebx
  801045:	89 cf                	mov    %ecx,%edi
  801047:	89 ce                	mov    %ecx,%esi
  801049:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104b:	85 c0                	test   %eax,%eax
  80104d:	7e 28                	jle    801077 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801053:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80105a:	00 
  80105b:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  801062:	00 
  801063:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 41 1c 80 00 	movl   $0x801c41,(%esp)
  801072:	e8 d9 04 00 00       	call   801550 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801077:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801080:	89 ec                	mov    %ebp,%esp
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801090:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801093:	b9 00 00 00 00       	mov    $0x0,%ecx
  801098:	b8 0d 00 00 00       	mov    $0xd,%eax
  80109d:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a0:	89 cb                	mov    %ecx,%ebx
  8010a2:	89 cf                	mov    %ecx,%edi
  8010a4:	89 ce                	mov    %ecx,%esi
  8010a6:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  8010a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b1:	89 ec                	mov    %ebp,%esp
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    
  8010b5:	00 00                	add    %al,(%eax)
	...

008010b8 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	53                   	push   %ebx
  8010bc:	83 ec 24             	sub    $0x24,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  8010bf:	89 d3                	mov    %edx,%ebx
  8010c1:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010c4:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8010cb:	f6 c1 02             	test   $0x2,%cl
  8010ce:	75 10                	jne    8010e0 <duppage+0x28>
  8010d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d7:	f6 c6 08             	test   $0x8,%dh
  8010da:	0f 84 84 00 00 00    	je     801164 <duppage+0xac>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8010e0:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010e7:	00 
  8010e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010fb:	e8 7b fd ff ff       	call   800e7b <sys_page_map>
  801100:	85 c0                	test   %eax,%eax
  801102:	79 1c                	jns    801120 <duppage+0x68>
			panic("2");
  801104:	c7 44 24 08 4f 1c 80 	movl   $0x801c4f,0x8(%esp)
  80110b:	00 
  80110c:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801113:	00 
  801114:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  80111b:	e8 30 04 00 00       	call   801550 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801120:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801127:	00 
  801128:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80112c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801133:	00 
  801134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80113f:	e8 37 fd ff ff       	call   800e7b <sys_page_map>
  801144:	85 c0                	test   %eax,%eax
  801146:	79 3c                	jns    801184 <duppage+0xcc>
			panic("3");
  801148:	c7 44 24 08 5c 1c 80 	movl   $0x801c5c,0x8(%esp)
  80114f:	00 
  801150:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801157:	00 
  801158:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  80115f:	e8 ec 03 00 00       	call   801550 <_panic>
		
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801164:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80116b:	00 
  80116c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801170:	89 44 24 08          	mov    %eax,0x8(%esp)
  801174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117f:	e8 f7 fc ff ff       	call   800e7b <sys_page_map>
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  801184:	b8 00 00 00 00       	mov    $0x0,%eax
  801189:	83 c4 24             	add    $0x24,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	53                   	push   %ebx
  801193:	83 ec 24             	sub    $0x24,%esp
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  801199:	8b 18                	mov    (%eax),%ebx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  80119b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80119f:	74 2d                	je     8011ce <pgfault+0x3f>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	c1 e8 16             	shr    $0x16,%eax
  8011a6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ad:	a8 01                	test   $0x1,%al
  8011af:	74 1d                	je     8011ce <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8011b1:	89 d8                	mov    %ebx,%eax
  8011b3:	c1 e8 0c             	shr    $0xc,%eax
  8011b6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8011bd:	f6 c2 01             	test   $0x1,%dl
  8011c0:	74 0c                	je     8011ce <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8011c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8011c9:	f6 c4 08             	test   $0x8,%ah
  8011cc:	75 1c                	jne    8011ea <pgfault+0x5b>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  8011ce:	c7 44 24 08 5e 1c 80 	movl   $0x801c5e,0x8(%esp)
  8011d5:	00 
  8011d6:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011dd:	00 
  8011de:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  8011e5:	e8 66 03 00 00       	call   801550 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  8011ea:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011f1:	00 
  8011f2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011f9:	00 
  8011fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801201:	e8 16 fc ff ff       	call   800e1c <sys_page_alloc>
  801206:	85 c0                	test   %eax,%eax
  801208:	79 1c                	jns    801226 <pgfault+0x97>
		panic("sys_page_alloc");
  80120a:	c7 44 24 08 70 1c 80 	movl   $0x801c70,0x8(%esp)
  801211:	00 
  801212:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801219:	00 
  80121a:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  801221:	e8 2a 03 00 00       	call   801550 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  801226:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  80122c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801233:	00 
  801234:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801238:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80123f:	e8 41 f9 ff ff       	call   800b85 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801244:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80124b:	00 
  80124c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801250:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801257:	00 
  801258:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80125f:	00 
  801260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801267:	e8 0f fc ff ff       	call   800e7b <sys_page_map>
  80126c:	85 c0                	test   %eax,%eax
  80126e:	79 1c                	jns    80128c <pgfault+0xfd>
		panic("sys_page_map");
  801270:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  801277:	00 
  801278:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80127f:	00 
  801280:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  801287:	e8 c4 02 00 00       	call   801550 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  80128c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801293:	00 
  801294:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129b:	e8 39 fc ff ff       	call   800ed9 <sys_page_unmap>
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	79 1c                	jns    8012c0 <pgfault+0x131>
		panic("sys_page_unmap");
  8012a4:	c7 44 24 08 8c 1c 80 	movl   $0x801c8c,0x8(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8012b3:	00 
  8012b4:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  8012bb:	e8 90 02 00 00       	call   801550 <_panic>
	return;
}
  8012c0:	83 c4 24             	add    $0x24,%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	57                   	push   %edi
  8012ca:	56                   	push   %esi
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 1c             	sub    $0x1c,%esp
	set_pgfault_handler(pgfault);
  8012cf:	c7 04 24 8f 11 80 00 	movl   $0x80118f,(%esp)
  8012d6:	e8 cd 02 00 00       	call   8015a8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8012db:	be 07 00 00 00       	mov    $0x7,%esi
  8012e0:	89 f0                	mov    %esi,%eax
  8012e2:	cd 30                	int    $0x30
  8012e4:	89 c6                	mov    %eax,%esi
  8012e6:	89 c7                	mov    %eax,%edi

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	75 1c                	jne    801308 <fork+0x42>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012ec:	e8 cb fa ff ff       	call   800dbc <sys_getenvid>
  8012f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012f6:	c1 e0 07             	shl    $0x7,%eax
  8012f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012fe:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801303:	e9 e1 00 00 00       	jmp    8013e9 <fork+0x123>
	}
	if (envid < 0)
  801308:	85 c0                	test   %eax,%eax
  80130a:	79 20                	jns    80132c <fork+0x66>
		panic("sys_exofork: %e", envid);
  80130c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801310:	c7 44 24 08 9b 1c 80 	movl   $0x801c9b,0x8(%esp)
  801317:	00 
  801318:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  80131f:	00 
  801320:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  801327:	e8 24 02 00 00       	call   801550 <_panic>
	envid = sys_exofork();
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  80132c:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801331:	89 d8                	mov    %ebx,%eax
  801333:	c1 e8 16             	shr    $0x16,%eax
  801336:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133d:	a8 01                	test   $0x1,%al
  80133f:	74 22                	je     801363 <fork+0x9d>
  801341:	89 da                	mov    %ebx,%edx
  801343:	c1 ea 0c             	shr    $0xc,%edx
  801346:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80134d:	a8 01                	test   $0x1,%al
  80134f:	74 12                	je     801363 <fork+0x9d>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801351:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801358:	a8 04                	test   $0x4,%al
  80135a:	74 07                	je     801363 <fork+0x9d>
			duppage(envid, PGNUM(addr));
  80135c:	89 f8                	mov    %edi,%eax
  80135e:	e8 55 fd ff ff       	call   8010b8 <duppage>
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801363:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801369:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80136f:	75 c0                	jne    801331 <fork+0x6b>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801371:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801378:	00 
  801379:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801380:	ee 
  801381:	89 34 24             	mov    %esi,(%esp)
  801384:	e8 93 fa ff ff       	call   800e1c <sys_page_alloc>
  801389:	85 c0                	test   %eax,%eax
  80138b:	79 1c                	jns    8013a9 <fork+0xe3>
		panic("1");
  80138d:	c7 44 24 08 ab 1c 80 	movl   $0x801cab,0x8(%esp)
  801394:	00 
  801395:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80139c:	00 
  80139d:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  8013a4:	e8 a7 01 00 00       	call   801550 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013a9:	c7 44 24 04 34 16 80 	movl   $0x801634,0x4(%esp)
  8013b0:	00 
  8013b1:	89 34 24             	mov    %esi,(%esp)
  8013b4:	e8 dc fb ff ff       	call   800f95 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8013b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013c0:	00 
  8013c1:	89 34 24             	mov    %esi,(%esp)
  8013c4:	e8 6e fb ff ff       	call   800f37 <sys_env_set_status>
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	79 1c                	jns    8013e9 <fork+0x123>
		panic("sys_env_set_status");
  8013cd:	c7 44 24 08 ad 1c 80 	movl   $0x801cad,0x8(%esp)
  8013d4:	00 
  8013d5:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8013dc:	00 
  8013dd:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  8013e4:	e8 67 01 00 00       	call   801550 <_panic>

	return envid;
}
  8013e9:	89 f0                	mov    %esi,%eax
  8013eb:	83 c4 1c             	add    $0x1c,%esp
  8013ee:	5b                   	pop    %ebx
  8013ef:	5e                   	pop    %esi
  8013f0:	5f                   	pop    %edi
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <sfork>:

// Challenge!
int
sfork(void)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013f9:	c7 44 24 08 c0 1c 80 	movl   $0x801cc0,0x8(%esp)
  801400:	00 
  801401:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801408:	00 
  801409:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  801410:	e8 3b 01 00 00       	call   801550 <_panic>

00801415 <pfork>:
	return -E_INVAL;
}

envid_t
pfork(int pr)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	57                   	push   %edi
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	83 ec 1c             	sub    $0x1c,%esp
    set_pgfault_handler(pgfault);
  80141e:	c7 04 24 8f 11 80 00 	movl   $0x80118f,(%esp)
  801425:	e8 7e 01 00 00       	call   8015a8 <set_pgfault_handler>
  80142a:	be 07 00 00 00       	mov    $0x7,%esi
  80142f:	89 f0                	mov    %esi,%eax
  801431:	cd 30                	int    $0x30
  801433:	89 c6                	mov    %eax,%esi
  801435:	89 c7                	mov    %eax,%edi

    envid_t envid;
    uint32_t addr;
    envid = sys_exofork();
    if (envid == 0) {
  801437:	85 c0                	test   %eax,%eax
  801439:	75 27                	jne    801462 <pfork+0x4d>
        thisenv = &envs[ENVX(sys_getenvid())];
  80143b:	e8 7c f9 ff ff       	call   800dbc <sys_getenvid>
  801440:	25 ff 03 00 00       	and    $0x3ff,%eax
  801445:	c1 e0 07             	shl    $0x7,%eax
  801448:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80144d:	a3 08 20 80 00       	mov    %eax,0x802008
        sys_change_pr(pr);
  801452:	8b 45 08             	mov    0x8(%ebp),%eax
  801455:	89 04 24             	mov    %eax,(%esp)
  801458:	e8 27 fc ff ff       	call   801084 <sys_change_pr>
        return 0;
  80145d:	e9 e1 00 00 00       	jmp    801543 <pfork+0x12e>
    }

    if (envid < 0)
  801462:	85 c0                	test   %eax,%eax
  801464:	79 20                	jns    801486 <pfork+0x71>
        panic("sys_exofork: %e", envid);
  801466:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146a:	c7 44 24 08 9b 1c 80 	movl   $0x801c9b,0x8(%esp)
  801471:	00 
  801472:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801479:	00 
  80147a:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  801481:	e8 ca 00 00 00       	call   801550 <_panic>
        thisenv = &envs[ENVX(sys_getenvid())];
        sys_change_pr(pr);
        return 0;
    }

    if (envid < 0)
  801486:	bb 00 00 00 00       	mov    $0x0,%ebx
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80148b:	89 d8                	mov    %ebx,%eax
  80148d:	c1 e8 16             	shr    $0x16,%eax
  801490:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801497:	a8 01                	test   $0x1,%al
  801499:	74 22                	je     8014bd <pfork+0xa8>
  80149b:	89 da                	mov    %ebx,%edx
  80149d:	c1 ea 0c             	shr    $0xc,%edx
  8014a0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014a7:	a8 01                	test   $0x1,%al
  8014a9:	74 12                	je     8014bd <pfork+0xa8>
            && (uvpt[PGNUM(addr)] & PTE_U)) {
  8014ab:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014b2:	a8 04                	test   $0x4,%al
  8014b4:	74 07                	je     8014bd <pfork+0xa8>
            duppage(envid, PGNUM(addr));
  8014b6:	89 f8                	mov    %edi,%eax
  8014b8:	e8 fb fb ff ff       	call   8010b8 <duppage>
    }

    if (envid < 0)
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8014bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014c3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8014c9:	75 c0                	jne    80148b <pfork+0x76>
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
            && (uvpt[PGNUM(addr)] & PTE_U)) {
            duppage(envid, PGNUM(addr));
        }

    if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8014cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014d2:	00 
  8014d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014da:	ee 
  8014db:	89 34 24             	mov    %esi,(%esp)
  8014de:	e8 39 f9 ff ff       	call   800e1c <sys_page_alloc>
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	79 1c                	jns    801503 <pfork+0xee>
        panic("1");
  8014e7:	c7 44 24 08 ab 1c 80 	movl   $0x801cab,0x8(%esp)
  8014ee:	00 
  8014ef:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8014f6:	00 
  8014f7:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  8014fe:	e8 4d 00 00 00       	call   801550 <_panic>
    extern void _pgfault_upcall();
    sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801503:	c7 44 24 04 34 16 80 	movl   $0x801634,0x4(%esp)
  80150a:	00 
  80150b:	89 34 24             	mov    %esi,(%esp)
  80150e:	e8 82 fa ff ff       	call   800f95 <sys_env_set_pgfault_upcall>

    if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801513:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80151a:	00 
  80151b:	89 34 24             	mov    %esi,(%esp)
  80151e:	e8 14 fa ff ff       	call   800f37 <sys_env_set_status>
  801523:	85 c0                	test   %eax,%eax
  801525:	79 1c                	jns    801543 <pfork+0x12e>
        panic("sys_env_set_status");
  801527:	c7 44 24 08 ad 1c 80 	movl   $0x801cad,0x8(%esp)
  80152e:	00 
  80152f:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801536:	00 
  801537:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  80153e:	e8 0d 00 00 00       	call   801550 <_panic>

    return envid;
    panic("fork not implemented");
  801543:	89 f0                	mov    %esi,%eax
  801545:	83 c4 1c             	add    $0x1c,%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    
  80154d:	00 00                	add    %al,(%eax)
	...

00801550 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801558:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80155b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801561:	e8 56 f8 ff ff       	call   800dbc <sys_getenvid>
  801566:	8b 55 0c             	mov    0xc(%ebp),%edx
  801569:	89 54 24 10          	mov    %edx,0x10(%esp)
  80156d:	8b 55 08             	mov    0x8(%ebp),%edx
  801570:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801574:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801578:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157c:	c7 04 24 d8 1c 80 00 	movl   $0x801cd8,(%esp)
  801583:	e8 3f ec ff ff       	call   8001c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801588:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158c:	8b 45 10             	mov    0x10(%ebp),%eax
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 cf eb ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  801597:	c7 04 24 b4 19 80 00 	movl   $0x8019b4,(%esp)
  80159e:	e8 24 ec ff ff       	call   8001c7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015a3:	cc                   	int3   
  8015a4:	eb fd                	jmp    8015a3 <_panic+0x53>
	...

008015a8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8015ae:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8015b5:	75 3c                	jne    8015f3 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8015b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015be:	00 
  8015bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015c6:	ee 
  8015c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ce:	e8 49 f8 ff ff       	call   800e1c <sys_page_alloc>
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	79 1c                	jns    8015f3 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8015d7:	c7 44 24 08 fc 1c 80 	movl   $0x801cfc,0x8(%esp)
  8015de:	00 
  8015df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8015e6:	00 
  8015e7:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8015ee:	e8 5d ff ff ff       	call   801550 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8015fb:	c7 44 24 04 34 16 80 	movl   $0x801634,0x4(%esp)
  801602:	00 
  801603:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160a:	e8 86 f9 ff ff       	call   800f95 <sys_env_set_pgfault_upcall>
  80160f:	85 c0                	test   %eax,%eax
  801611:	79 1c                	jns    80162f <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801613:	c7 44 24 08 28 1d 80 	movl   $0x801d28,0x8(%esp)
  80161a:	00 
  80161b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801622:	00 
  801623:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80162a:	e8 21 ff ff ff       	call   801550 <_panic>
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    
  801631:	00 00                	add    %al,(%eax)
	...

00801634 <_pgfault_upcall>:
  801634:	54                   	push   %esp
  801635:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80163a:	ff d0                	call   *%eax
  80163c:	83 c4 04             	add    $0x4,%esp
  80163f:	8b 54 24 28          	mov    0x28(%esp),%edx
  801643:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  801648:	8b 44 24 30          	mov    0x30(%esp),%eax
  80164c:	89 10                	mov    %edx,(%eax)
  80164e:	83 c4 08             	add    $0x8,%esp
  801651:	61                   	popa   
  801652:	83 c4 04             	add    $0x4,%esp
  801655:	9d                   	popf   
  801656:	5c                   	pop    %esp
  801657:	c3                   	ret    
	...

00801660 <__udivdi3>:
  801660:	83 ec 1c             	sub    $0x1c,%esp
  801663:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801667:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80166b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80166f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801673:	89 74 24 10          	mov    %esi,0x10(%esp)
  801677:	8b 74 24 24          	mov    0x24(%esp),%esi
  80167b:	85 ff                	test   %edi,%edi
  80167d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801681:	89 44 24 08          	mov    %eax,0x8(%esp)
  801685:	89 cd                	mov    %ecx,%ebp
  801687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168b:	75 33                	jne    8016c0 <__udivdi3+0x60>
  80168d:	39 f1                	cmp    %esi,%ecx
  80168f:	77 57                	ja     8016e8 <__udivdi3+0x88>
  801691:	85 c9                	test   %ecx,%ecx
  801693:	75 0b                	jne    8016a0 <__udivdi3+0x40>
  801695:	b8 01 00 00 00       	mov    $0x1,%eax
  80169a:	31 d2                	xor    %edx,%edx
  80169c:	f7 f1                	div    %ecx
  80169e:	89 c1                	mov    %eax,%ecx
  8016a0:	89 f0                	mov    %esi,%eax
  8016a2:	31 d2                	xor    %edx,%edx
  8016a4:	f7 f1                	div    %ecx
  8016a6:	89 c6                	mov    %eax,%esi
  8016a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016ac:	f7 f1                	div    %ecx
  8016ae:	89 f2                	mov    %esi,%edx
  8016b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016bc:	83 c4 1c             	add    $0x1c,%esp
  8016bf:	c3                   	ret    
  8016c0:	31 d2                	xor    %edx,%edx
  8016c2:	31 c0                	xor    %eax,%eax
  8016c4:	39 f7                	cmp    %esi,%edi
  8016c6:	77 e8                	ja     8016b0 <__udivdi3+0x50>
  8016c8:	0f bd cf             	bsr    %edi,%ecx
  8016cb:	83 f1 1f             	xor    $0x1f,%ecx
  8016ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016d2:	75 2c                	jne    801700 <__udivdi3+0xa0>
  8016d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8016d8:	76 04                	jbe    8016de <__udivdi3+0x7e>
  8016da:	39 f7                	cmp    %esi,%edi
  8016dc:	73 d2                	jae    8016b0 <__udivdi3+0x50>
  8016de:	31 d2                	xor    %edx,%edx
  8016e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e5:	eb c9                	jmp    8016b0 <__udivdi3+0x50>
  8016e7:	90                   	nop
  8016e8:	89 f2                	mov    %esi,%edx
  8016ea:	f7 f1                	div    %ecx
  8016ec:	31 d2                	xor    %edx,%edx
  8016ee:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016fa:	83 c4 1c             	add    $0x1c,%esp
  8016fd:	c3                   	ret    
  8016fe:	66 90                	xchg   %ax,%ax
  801700:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801705:	b8 20 00 00 00       	mov    $0x20,%eax
  80170a:	89 ea                	mov    %ebp,%edx
  80170c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801710:	d3 e7                	shl    %cl,%edi
  801712:	89 c1                	mov    %eax,%ecx
  801714:	d3 ea                	shr    %cl,%edx
  801716:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80171b:	09 fa                	or     %edi,%edx
  80171d:	89 f7                	mov    %esi,%edi
  80171f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801723:	89 f2                	mov    %esi,%edx
  801725:	8b 74 24 08          	mov    0x8(%esp),%esi
  801729:	d3 e5                	shl    %cl,%ebp
  80172b:	89 c1                	mov    %eax,%ecx
  80172d:	d3 ef                	shr    %cl,%edi
  80172f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801734:	d3 e2                	shl    %cl,%edx
  801736:	89 c1                	mov    %eax,%ecx
  801738:	d3 ee                	shr    %cl,%esi
  80173a:	09 d6                	or     %edx,%esi
  80173c:	89 fa                	mov    %edi,%edx
  80173e:	89 f0                	mov    %esi,%eax
  801740:	f7 74 24 0c          	divl   0xc(%esp)
  801744:	89 d7                	mov    %edx,%edi
  801746:	89 c6                	mov    %eax,%esi
  801748:	f7 e5                	mul    %ebp
  80174a:	39 d7                	cmp    %edx,%edi
  80174c:	72 22                	jb     801770 <__udivdi3+0x110>
  80174e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801752:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801757:	d3 e5                	shl    %cl,%ebp
  801759:	39 c5                	cmp    %eax,%ebp
  80175b:	73 04                	jae    801761 <__udivdi3+0x101>
  80175d:	39 d7                	cmp    %edx,%edi
  80175f:	74 0f                	je     801770 <__udivdi3+0x110>
  801761:	89 f0                	mov    %esi,%eax
  801763:	31 d2                	xor    %edx,%edx
  801765:	e9 46 ff ff ff       	jmp    8016b0 <__udivdi3+0x50>
  80176a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801770:	8d 46 ff             	lea    -0x1(%esi),%eax
  801773:	31 d2                	xor    %edx,%edx
  801775:	8b 74 24 10          	mov    0x10(%esp),%esi
  801779:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80177d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801781:	83 c4 1c             	add    $0x1c,%esp
  801784:	c3                   	ret    
	...

00801790 <__umoddi3>:
  801790:	83 ec 1c             	sub    $0x1c,%esp
  801793:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801797:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80179b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80179f:	89 74 24 10          	mov    %esi,0x10(%esp)
  8017a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8017a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8017ab:	85 ed                	test   %ebp,%ebp
  8017ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8017b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b5:	89 cf                	mov    %ecx,%edi
  8017b7:	89 04 24             	mov    %eax,(%esp)
  8017ba:	89 f2                	mov    %esi,%edx
  8017bc:	75 1a                	jne    8017d8 <__umoddi3+0x48>
  8017be:	39 f1                	cmp    %esi,%ecx
  8017c0:	76 4e                	jbe    801810 <__umoddi3+0x80>
  8017c2:	f7 f1                	div    %ecx
  8017c4:	89 d0                	mov    %edx,%eax
  8017c6:	31 d2                	xor    %edx,%edx
  8017c8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8017d4:	83 c4 1c             	add    $0x1c,%esp
  8017d7:	c3                   	ret    
  8017d8:	39 f5                	cmp    %esi,%ebp
  8017da:	77 54                	ja     801830 <__umoddi3+0xa0>
  8017dc:	0f bd c5             	bsr    %ebp,%eax
  8017df:	83 f0 1f             	xor    $0x1f,%eax
  8017e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e6:	75 60                	jne    801848 <__umoddi3+0xb8>
  8017e8:	3b 0c 24             	cmp    (%esp),%ecx
  8017eb:	0f 87 07 01 00 00    	ja     8018f8 <__umoddi3+0x168>
  8017f1:	89 f2                	mov    %esi,%edx
  8017f3:	8b 34 24             	mov    (%esp),%esi
  8017f6:	29 ce                	sub    %ecx,%esi
  8017f8:	19 ea                	sbb    %ebp,%edx
  8017fa:	89 34 24             	mov    %esi,(%esp)
  8017fd:	8b 04 24             	mov    (%esp),%eax
  801800:	8b 74 24 10          	mov    0x10(%esp),%esi
  801804:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801808:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80180c:	83 c4 1c             	add    $0x1c,%esp
  80180f:	c3                   	ret    
  801810:	85 c9                	test   %ecx,%ecx
  801812:	75 0b                	jne    80181f <__umoddi3+0x8f>
  801814:	b8 01 00 00 00       	mov    $0x1,%eax
  801819:	31 d2                	xor    %edx,%edx
  80181b:	f7 f1                	div    %ecx
  80181d:	89 c1                	mov    %eax,%ecx
  80181f:	89 f0                	mov    %esi,%eax
  801821:	31 d2                	xor    %edx,%edx
  801823:	f7 f1                	div    %ecx
  801825:	8b 04 24             	mov    (%esp),%eax
  801828:	f7 f1                	div    %ecx
  80182a:	eb 98                	jmp    8017c4 <__umoddi3+0x34>
  80182c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801830:	89 f2                	mov    %esi,%edx
  801832:	8b 74 24 10          	mov    0x10(%esp),%esi
  801836:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80183a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80183e:	83 c4 1c             	add    $0x1c,%esp
  801841:	c3                   	ret    
  801842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801848:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80184d:	89 e8                	mov    %ebp,%eax
  80184f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801854:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801858:	89 fa                	mov    %edi,%edx
  80185a:	d3 e0                	shl    %cl,%eax
  80185c:	89 e9                	mov    %ebp,%ecx
  80185e:	d3 ea                	shr    %cl,%edx
  801860:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801865:	09 c2                	or     %eax,%edx
  801867:	8b 44 24 08          	mov    0x8(%esp),%eax
  80186b:	89 14 24             	mov    %edx,(%esp)
  80186e:	89 f2                	mov    %esi,%edx
  801870:	d3 e7                	shl    %cl,%edi
  801872:	89 e9                	mov    %ebp,%ecx
  801874:	d3 ea                	shr    %cl,%edx
  801876:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80187b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80187f:	d3 e6                	shl    %cl,%esi
  801881:	89 e9                	mov    %ebp,%ecx
  801883:	d3 e8                	shr    %cl,%eax
  801885:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80188a:	09 f0                	or     %esi,%eax
  80188c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801890:	f7 34 24             	divl   (%esp)
  801893:	d3 e6                	shl    %cl,%esi
  801895:	89 74 24 08          	mov    %esi,0x8(%esp)
  801899:	89 d6                	mov    %edx,%esi
  80189b:	f7 e7                	mul    %edi
  80189d:	39 d6                	cmp    %edx,%esi
  80189f:	89 c1                	mov    %eax,%ecx
  8018a1:	89 d7                	mov    %edx,%edi
  8018a3:	72 3f                	jb     8018e4 <__umoddi3+0x154>
  8018a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8018a9:	72 35                	jb     8018e0 <__umoddi3+0x150>
  8018ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018af:	29 c8                	sub    %ecx,%eax
  8018b1:	19 fe                	sbb    %edi,%esi
  8018b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018b8:	89 f2                	mov    %esi,%edx
  8018ba:	d3 e8                	shr    %cl,%eax
  8018bc:	89 e9                	mov    %ebp,%ecx
  8018be:	d3 e2                	shl    %cl,%edx
  8018c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018c5:	09 d0                	or     %edx,%eax
  8018c7:	89 f2                	mov    %esi,%edx
  8018c9:	d3 ea                	shr    %cl,%edx
  8018cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8018cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8018d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8018d7:	83 c4 1c             	add    $0x1c,%esp
  8018da:	c3                   	ret    
  8018db:	90                   	nop
  8018dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018e0:	39 d6                	cmp    %edx,%esi
  8018e2:	75 c7                	jne    8018ab <__umoddi3+0x11b>
  8018e4:	89 d7                	mov    %edx,%edi
  8018e6:	89 c1                	mov    %eax,%ecx
  8018e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8018ec:	1b 3c 24             	sbb    (%esp),%edi
  8018ef:	eb ba                	jmp    8018ab <__umoddi3+0x11b>
  8018f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8018f8:	39 f5                	cmp    %esi,%ebp
  8018fa:	0f 82 f1 fe ff ff    	jb     8017f1 <__umoddi3+0x61>
  801900:	e9 f8 fe ff ff       	jmp    8017fd <__umoddi3+0x6d>
