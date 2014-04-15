
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
  800047:	c7 04 24 c0 17 80 00 	movl   $0x8017c0,(%esp)
  80004e:	e8 74 01 00 00       	call   8001c7 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 63 11 00 00       	call   8011bb <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 38 18 80 00 	movl   $0x801838,(%esp)
  800065:	e8 5d 01 00 00       	call   8001c7 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 e8 17 80 00 	movl   $0x8017e8,(%esp)
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
  8000a5:	c7 04 24 10 18 80 00 	movl   $0x801810,(%esp)
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
  8000dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
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
  80024e:	e8 ad 12 00 00       	call   801500 <__udivdi3>
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
  8002a1:	e8 8a 13 00 00       	call   801630 <__umoddi3>
  8002a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002aa:	0f be 80 60 18 80 00 	movsbl 0x801860(%eax),%eax
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
  8003d2:	ff 24 85 40 19 80 00 	jmp    *0x801940(,%eax,4)
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
  8004b0:	c7 44 24 04 78 18 80 	movl   $0x801878,0x4(%esp)
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
  8004d6:	c7 44 24 04 7c 18 80 	movl   $0x80187c,0x4(%esp)
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
  8004fc:	c7 44 24 04 80 18 80 	movl   $0x801880,0x4(%esp)
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
  800522:	c7 44 24 04 84 18 80 	movl   $0x801884,0x4(%esp)
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
  800548:	c7 44 24 04 88 18 80 	movl   $0x801888,0x4(%esp)
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
  80056e:	c7 44 24 04 8c 18 80 	movl   $0x80188c,0x4(%esp)
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
  8005ae:	8b 14 85 a0 1a 80 00 	mov    0x801aa0(,%eax,4),%edx
  8005b5:	85 d2                	test   %edx,%edx
  8005b7:	75 23                	jne    8005dc <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bd:	c7 44 24 08 90 18 80 	movl   $0x801890,0x8(%esp)
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
  8005e0:	c7 44 24 08 99 18 80 	movl   $0x801899,0x8(%esp)
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
  800615:	b8 71 18 80 00       	mov    $0x801871,%eax
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
  800d93:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  800daa:	e8 3d 06 00 00       	call   8013ec <_panic>

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
  800e52:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  800e69:	e8 7e 05 00 00       	call   8013ec <_panic>

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
  800eb0:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  800ec7:	e8 20 05 00 00       	call   8013ec <_panic>

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
  800f0e:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  800f15:	00 
  800f16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1d:	00 
  800f1e:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  800f25:	e8 c2 04 00 00       	call   8013ec <_panic>

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
  800f6c:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  800f83:	e8 64 04 00 00       	call   8013ec <_panic>

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
  800fca:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  800fe1:	e8 06 04 00 00       	call   8013ec <_panic>

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
  80105b:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801062:	00 
  801063:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801072:	e8 75 03 00 00       	call   8013ec <_panic>

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

00801084 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	53                   	push   %ebx
  801088:	83 ec 24             	sub    $0x24,%esp
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  80108e:	8b 18                	mov    (%eax),%ebx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  801090:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801094:	74 2d                	je     8010c3 <pgfault+0x3f>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801096:	89 d8                	mov    %ebx,%eax
  801098:	c1 e8 16             	shr    $0x16,%eax
  80109b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a2:	a8 01                	test   $0x1,%al
  8010a4:	74 1d                	je     8010c3 <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8010a6:	89 d8                	mov    %ebx,%eax
  8010a8:	c1 e8 0c             	shr    $0xc,%eax
  8010ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8010b2:	f6 c2 01             	test   $0x1,%dl
  8010b5:	74 0c                	je     8010c3 <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8010b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8010be:	f6 c4 08             	test   $0x8,%ah
  8010c1:	75 1c                	jne    8010df <pgfault+0x5b>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  8010c3:	c7 44 24 08 ef 1a 80 	movl   $0x801aef,0x8(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8010d2:	00 
  8010d3:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8010da:	e8 0d 03 00 00       	call   8013ec <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  8010df:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010e6:	00 
  8010e7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ee:	00 
  8010ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f6:	e8 21 fd ff ff       	call   800e1c <sys_page_alloc>
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	79 1c                	jns    80111b <pgfault+0x97>
		panic("sys_page_alloc");
  8010ff:	c7 44 24 08 0c 1b 80 	movl   $0x801b0c,0x8(%esp)
  801106:	00 
  801107:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80110e:	00 
  80110f:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801116:	e8 d1 02 00 00       	call   8013ec <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  80111b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  801121:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801128:	00 
  801129:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80112d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801134:	e8 4c fa ff ff       	call   800b85 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801139:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801140:	00 
  801141:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801145:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80115c:	e8 1a fd ff ff       	call   800e7b <sys_page_map>
  801161:	85 c0                	test   %eax,%eax
  801163:	79 1c                	jns    801181 <pgfault+0xfd>
		panic("sys_page_map");
  801165:	c7 44 24 08 1b 1b 80 	movl   $0x801b1b,0x8(%esp)
  80116c:	00 
  80116d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801174:	00 
  801175:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  80117c:	e8 6b 02 00 00       	call   8013ec <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  801181:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801188:	00 
  801189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801190:	e8 44 fd ff ff       	call   800ed9 <sys_page_unmap>
  801195:	85 c0                	test   %eax,%eax
  801197:	79 1c                	jns    8011b5 <pgfault+0x131>
		panic("sys_page_unmap");
  801199:	c7 44 24 08 28 1b 80 	movl   $0x801b28,0x8(%esp)
  8011a0:	00 
  8011a1:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8011a8:	00 
  8011a9:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8011b0:	e8 37 02 00 00       	call   8013ec <_panic>
	return;
}
  8011b5:	83 c4 24             	add    $0x24,%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	57                   	push   %edi
  8011bf:	56                   	push   %esi
  8011c0:	53                   	push   %ebx
  8011c1:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8011c4:	c7 04 24 84 10 80 00 	movl   $0x801084,(%esp)
  8011cb:	e8 74 02 00 00       	call   801444 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011d0:	ba 07 00 00 00       	mov    $0x7,%edx
  8011d5:	89 d0                	mov    %edx,%eax
  8011d7:	cd 30                	int    $0x30
  8011d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011dc:	89 c7                	mov    %eax,%edi

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	75 1c                	jne    8011fe <fork+0x43>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011e2:	e8 d5 fb ff ff       	call   800dbc <sys_getenvid>
  8011e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011ec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f4:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  8011f9:	e9 bf 01 00 00       	jmp    8013bd <fork+0x202>
	}
	if (envid < 0)
  8011fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801202:	79 23                	jns    801227 <fork+0x6c>
		panic("sys_exofork: %e", envid);
  801204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120b:	c7 44 24 08 37 1b 80 	movl   $0x801b37,0x8(%esp)
  801212:	00 
  801213:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801222:	e8 c5 01 00 00       	call   8013ec <_panic>
	envid = sys_exofork();
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80122c:	89 d8                	mov    %ebx,%eax
  80122e:	c1 e8 16             	shr    $0x16,%eax
  801231:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801238:	a8 01                	test   $0x1,%al
  80123a:	0f 84 ea 00 00 00    	je     80132a <fork+0x16f>
  801240:	89 d8                	mov    %ebx,%eax
  801242:	c1 e8 0c             	shr    $0xc,%eax
  801245:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	0f 84 d5 00 00 00    	je     80132a <fork+0x16f>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801255:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80125c:	f6 c2 04             	test   $0x4,%dl
  80125f:	0f 84 c5 00 00 00    	je     80132a <fork+0x16f>
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  801265:	89 c6                	mov    %eax,%esi
  801267:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80126a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801271:	f6 c2 02             	test   $0x2,%dl
  801274:	75 10                	jne    801286 <fork+0xcb>
  801276:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127d:	f6 c4 08             	test   $0x8,%ah
  801280:	0f 84 84 00 00 00    	je     80130a <fork+0x14f>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801286:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80128d:	00 
  80128e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801292:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80129a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a1:	e8 d5 fb ff ff       	call   800e7b <sys_page_map>
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	79 1c                	jns    8012c6 <fork+0x10b>
			panic("2");
  8012aa:	c7 44 24 08 47 1b 80 	movl   $0x801b47,0x8(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8012b9:	00 
  8012ba:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8012c1:	e8 26 01 00 00       	call   8013ec <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8012c6:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012cd:	00 
  8012ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012d9:	00 
  8012da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e5:	e8 91 fb ff ff       	call   800e7b <sys_page_map>
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	79 3c                	jns    80132a <fork+0x16f>
			panic("3");
  8012ee:	c7 44 24 08 49 1b 80 	movl   $0x801b49,0x8(%esp)
  8012f5:	00 
  8012f6:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8012fd:	00 
  8012fe:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801305:	e8 e2 00 00 00       	call   8013ec <_panic>
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80130a:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801311:	00 
  801312:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801316:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80131a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801325:	e8 51 fb ff ff       	call   800e7b <sys_page_map>
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80132a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801330:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801336:	0f 85 f0 fe ff ff    	jne    80122c <fork+0x71>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80133c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801343:	00 
  801344:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80134b:	ee 
  80134c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80134f:	89 04 24             	mov    %eax,(%esp)
  801352:	e8 c5 fa ff ff       	call   800e1c <sys_page_alloc>
  801357:	85 c0                	test   %eax,%eax
  801359:	79 1c                	jns    801377 <fork+0x1bc>
		panic("1");
  80135b:	c7 44 24 08 4b 1b 80 	movl   $0x801b4b,0x8(%esp)
  801362:	00 
  801363:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  80136a:	00 
  80136b:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801372:	e8 75 00 00 00       	call   8013ec <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801377:	c7 44 24 04 d0 14 80 	movl   $0x8014d0,0x4(%esp)
  80137e:	00 
  80137f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	e8 0b fc ff ff       	call   800f95 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80138a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801391:	00 
  801392:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801395:	89 04 24             	mov    %eax,(%esp)
  801398:	e8 9a fb ff ff       	call   800f37 <sys_env_set_status>
  80139d:	85 c0                	test   %eax,%eax
  80139f:	79 1c                	jns    8013bd <fork+0x202>
		panic("sys_env_set_status");
  8013a1:	c7 44 24 08 4d 1b 80 	movl   $0x801b4d,0x8(%esp)
  8013a8:	00 
  8013a9:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8013b0:	00 
  8013b1:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8013b8:	e8 2f 00 00 00       	call   8013ec <_panic>

	return envid;
	panic("fork not implemented");
}
  8013bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c0:	83 c4 3c             	add    $0x3c,%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <sfork>:

// Challenge!
int
sfork(void)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013ce:	c7 44 24 08 60 1b 80 	movl   $0x801b60,0x8(%esp)
  8013d5:	00 
  8013d6:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8013dd:	00 
  8013de:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8013e5:	e8 02 00 00 00       	call   8013ec <_panic>
	...

008013ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013f4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013f7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013fd:	e8 ba f9 ff ff       	call   800dbc <sys_getenvid>
  801402:	8b 55 0c             	mov    0xc(%ebp),%edx
  801405:	89 54 24 10          	mov    %edx,0x10(%esp)
  801409:	8b 55 08             	mov    0x8(%ebp),%edx
  80140c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801410:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801414:	89 44 24 04          	mov    %eax,0x4(%esp)
  801418:	c7 04 24 78 1b 80 00 	movl   $0x801b78,(%esp)
  80141f:	e8 a3 ed ff ff       	call   8001c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801424:	89 74 24 04          	mov    %esi,0x4(%esp)
  801428:	8b 45 10             	mov    0x10(%ebp),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 33 ed ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  801433:	c7 04 24 54 18 80 00 	movl   $0x801854,(%esp)
  80143a:	e8 88 ed ff ff       	call   8001c7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80143f:	cc                   	int3   
  801440:	eb fd                	jmp    80143f <_panic+0x53>
	...

00801444 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80144a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801451:	75 3c                	jne    80148f <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801453:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80145a:	00 
  80145b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801462:	ee 
  801463:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146a:	e8 ad f9 ff ff       	call   800e1c <sys_page_alloc>
  80146f:	85 c0                	test   %eax,%eax
  801471:	79 1c                	jns    80148f <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801473:	c7 44 24 08 9c 1b 80 	movl   $0x801b9c,0x8(%esp)
  80147a:	00 
  80147b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801482:	00 
  801483:	c7 04 24 00 1c 80 00 	movl   $0x801c00,(%esp)
  80148a:	e8 5d ff ff ff       	call   8013ec <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801497:	c7 44 24 04 d0 14 80 	movl   $0x8014d0,0x4(%esp)
  80149e:	00 
  80149f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a6:	e8 ea fa ff ff       	call   800f95 <sys_env_set_pgfault_upcall>
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	79 1c                	jns    8014cb <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8014af:	c7 44 24 08 c8 1b 80 	movl   $0x801bc8,0x8(%esp)
  8014b6:	00 
  8014b7:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8014be:	00 
  8014bf:	c7 04 24 00 1c 80 00 	movl   $0x801c00,(%esp)
  8014c6:	e8 21 ff ff ff       	call   8013ec <_panic>
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    
  8014cd:	00 00                	add    %al,(%eax)
	...

008014d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014d1:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8014d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014d8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  8014db:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  8014df:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  8014e4:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8014e8:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  8014ea:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  8014ed:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  8014ee:	83 c4 04             	add    $0x4,%esp
    popfl
  8014f1:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8014f2:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8014f3:	c3                   	ret    
	...

00801500 <__udivdi3>:
  801500:	83 ec 1c             	sub    $0x1c,%esp
  801503:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801507:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80150b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80150f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801513:	89 74 24 10          	mov    %esi,0x10(%esp)
  801517:	8b 74 24 24          	mov    0x24(%esp),%esi
  80151b:	85 ff                	test   %edi,%edi
  80151d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801521:	89 44 24 08          	mov    %eax,0x8(%esp)
  801525:	89 cd                	mov    %ecx,%ebp
  801527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152b:	75 33                	jne    801560 <__udivdi3+0x60>
  80152d:	39 f1                	cmp    %esi,%ecx
  80152f:	77 57                	ja     801588 <__udivdi3+0x88>
  801531:	85 c9                	test   %ecx,%ecx
  801533:	75 0b                	jne    801540 <__udivdi3+0x40>
  801535:	b8 01 00 00 00       	mov    $0x1,%eax
  80153a:	31 d2                	xor    %edx,%edx
  80153c:	f7 f1                	div    %ecx
  80153e:	89 c1                	mov    %eax,%ecx
  801540:	89 f0                	mov    %esi,%eax
  801542:	31 d2                	xor    %edx,%edx
  801544:	f7 f1                	div    %ecx
  801546:	89 c6                	mov    %eax,%esi
  801548:	8b 44 24 04          	mov    0x4(%esp),%eax
  80154c:	f7 f1                	div    %ecx
  80154e:	89 f2                	mov    %esi,%edx
  801550:	8b 74 24 10          	mov    0x10(%esp),%esi
  801554:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801558:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80155c:	83 c4 1c             	add    $0x1c,%esp
  80155f:	c3                   	ret    
  801560:	31 d2                	xor    %edx,%edx
  801562:	31 c0                	xor    %eax,%eax
  801564:	39 f7                	cmp    %esi,%edi
  801566:	77 e8                	ja     801550 <__udivdi3+0x50>
  801568:	0f bd cf             	bsr    %edi,%ecx
  80156b:	83 f1 1f             	xor    $0x1f,%ecx
  80156e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801572:	75 2c                	jne    8015a0 <__udivdi3+0xa0>
  801574:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801578:	76 04                	jbe    80157e <__udivdi3+0x7e>
  80157a:	39 f7                	cmp    %esi,%edi
  80157c:	73 d2                	jae    801550 <__udivdi3+0x50>
  80157e:	31 d2                	xor    %edx,%edx
  801580:	b8 01 00 00 00       	mov    $0x1,%eax
  801585:	eb c9                	jmp    801550 <__udivdi3+0x50>
  801587:	90                   	nop
  801588:	89 f2                	mov    %esi,%edx
  80158a:	f7 f1                	div    %ecx
  80158c:	31 d2                	xor    %edx,%edx
  80158e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801592:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801596:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80159a:	83 c4 1c             	add    $0x1c,%esp
  80159d:	c3                   	ret    
  80159e:	66 90                	xchg   %ax,%ax
  8015a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015a5:	b8 20 00 00 00       	mov    $0x20,%eax
  8015aa:	89 ea                	mov    %ebp,%edx
  8015ac:	2b 44 24 04          	sub    0x4(%esp),%eax
  8015b0:	d3 e7                	shl    %cl,%edi
  8015b2:	89 c1                	mov    %eax,%ecx
  8015b4:	d3 ea                	shr    %cl,%edx
  8015b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015bb:	09 fa                	or     %edi,%edx
  8015bd:	89 f7                	mov    %esi,%edi
  8015bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015c3:	89 f2                	mov    %esi,%edx
  8015c5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015c9:	d3 e5                	shl    %cl,%ebp
  8015cb:	89 c1                	mov    %eax,%ecx
  8015cd:	d3 ef                	shr    %cl,%edi
  8015cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015d4:	d3 e2                	shl    %cl,%edx
  8015d6:	89 c1                	mov    %eax,%ecx
  8015d8:	d3 ee                	shr    %cl,%esi
  8015da:	09 d6                	or     %edx,%esi
  8015dc:	89 fa                	mov    %edi,%edx
  8015de:	89 f0                	mov    %esi,%eax
  8015e0:	f7 74 24 0c          	divl   0xc(%esp)
  8015e4:	89 d7                	mov    %edx,%edi
  8015e6:	89 c6                	mov    %eax,%esi
  8015e8:	f7 e5                	mul    %ebp
  8015ea:	39 d7                	cmp    %edx,%edi
  8015ec:	72 22                	jb     801610 <__udivdi3+0x110>
  8015ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8015f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015f7:	d3 e5                	shl    %cl,%ebp
  8015f9:	39 c5                	cmp    %eax,%ebp
  8015fb:	73 04                	jae    801601 <__udivdi3+0x101>
  8015fd:	39 d7                	cmp    %edx,%edi
  8015ff:	74 0f                	je     801610 <__udivdi3+0x110>
  801601:	89 f0                	mov    %esi,%eax
  801603:	31 d2                	xor    %edx,%edx
  801605:	e9 46 ff ff ff       	jmp    801550 <__udivdi3+0x50>
  80160a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801610:	8d 46 ff             	lea    -0x1(%esi),%eax
  801613:	31 d2                	xor    %edx,%edx
  801615:	8b 74 24 10          	mov    0x10(%esp),%esi
  801619:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80161d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801621:	83 c4 1c             	add    $0x1c,%esp
  801624:	c3                   	ret    
	...

00801630 <__umoddi3>:
  801630:	83 ec 1c             	sub    $0x1c,%esp
  801633:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801637:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80163b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80163f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801643:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801647:	8b 74 24 24          	mov    0x24(%esp),%esi
  80164b:	85 ed                	test   %ebp,%ebp
  80164d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801651:	89 44 24 08          	mov    %eax,0x8(%esp)
  801655:	89 cf                	mov    %ecx,%edi
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	89 f2                	mov    %esi,%edx
  80165c:	75 1a                	jne    801678 <__umoddi3+0x48>
  80165e:	39 f1                	cmp    %esi,%ecx
  801660:	76 4e                	jbe    8016b0 <__umoddi3+0x80>
  801662:	f7 f1                	div    %ecx
  801664:	89 d0                	mov    %edx,%eax
  801666:	31 d2                	xor    %edx,%edx
  801668:	8b 74 24 10          	mov    0x10(%esp),%esi
  80166c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801670:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801674:	83 c4 1c             	add    $0x1c,%esp
  801677:	c3                   	ret    
  801678:	39 f5                	cmp    %esi,%ebp
  80167a:	77 54                	ja     8016d0 <__umoddi3+0xa0>
  80167c:	0f bd c5             	bsr    %ebp,%eax
  80167f:	83 f0 1f             	xor    $0x1f,%eax
  801682:	89 44 24 04          	mov    %eax,0x4(%esp)
  801686:	75 60                	jne    8016e8 <__umoddi3+0xb8>
  801688:	3b 0c 24             	cmp    (%esp),%ecx
  80168b:	0f 87 07 01 00 00    	ja     801798 <__umoddi3+0x168>
  801691:	89 f2                	mov    %esi,%edx
  801693:	8b 34 24             	mov    (%esp),%esi
  801696:	29 ce                	sub    %ecx,%esi
  801698:	19 ea                	sbb    %ebp,%edx
  80169a:	89 34 24             	mov    %esi,(%esp)
  80169d:	8b 04 24             	mov    (%esp),%eax
  8016a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016ac:	83 c4 1c             	add    $0x1c,%esp
  8016af:	c3                   	ret    
  8016b0:	85 c9                	test   %ecx,%ecx
  8016b2:	75 0b                	jne    8016bf <__umoddi3+0x8f>
  8016b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016b9:	31 d2                	xor    %edx,%edx
  8016bb:	f7 f1                	div    %ecx
  8016bd:	89 c1                	mov    %eax,%ecx
  8016bf:	89 f0                	mov    %esi,%eax
  8016c1:	31 d2                	xor    %edx,%edx
  8016c3:	f7 f1                	div    %ecx
  8016c5:	8b 04 24             	mov    (%esp),%eax
  8016c8:	f7 f1                	div    %ecx
  8016ca:	eb 98                	jmp    801664 <__umoddi3+0x34>
  8016cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016d0:	89 f2                	mov    %esi,%edx
  8016d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016de:	83 c4 1c             	add    $0x1c,%esp
  8016e1:	c3                   	ret    
  8016e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016ed:	89 e8                	mov    %ebp,%eax
  8016ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8016f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8016f8:	89 fa                	mov    %edi,%edx
  8016fa:	d3 e0                	shl    %cl,%eax
  8016fc:	89 e9                	mov    %ebp,%ecx
  8016fe:	d3 ea                	shr    %cl,%edx
  801700:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801705:	09 c2                	or     %eax,%edx
  801707:	8b 44 24 08          	mov    0x8(%esp),%eax
  80170b:	89 14 24             	mov    %edx,(%esp)
  80170e:	89 f2                	mov    %esi,%edx
  801710:	d3 e7                	shl    %cl,%edi
  801712:	89 e9                	mov    %ebp,%ecx
  801714:	d3 ea                	shr    %cl,%edx
  801716:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80171b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80171f:	d3 e6                	shl    %cl,%esi
  801721:	89 e9                	mov    %ebp,%ecx
  801723:	d3 e8                	shr    %cl,%eax
  801725:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80172a:	09 f0                	or     %esi,%eax
  80172c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801730:	f7 34 24             	divl   (%esp)
  801733:	d3 e6                	shl    %cl,%esi
  801735:	89 74 24 08          	mov    %esi,0x8(%esp)
  801739:	89 d6                	mov    %edx,%esi
  80173b:	f7 e7                	mul    %edi
  80173d:	39 d6                	cmp    %edx,%esi
  80173f:	89 c1                	mov    %eax,%ecx
  801741:	89 d7                	mov    %edx,%edi
  801743:	72 3f                	jb     801784 <__umoddi3+0x154>
  801745:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801749:	72 35                	jb     801780 <__umoddi3+0x150>
  80174b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80174f:	29 c8                	sub    %ecx,%eax
  801751:	19 fe                	sbb    %edi,%esi
  801753:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801758:	89 f2                	mov    %esi,%edx
  80175a:	d3 e8                	shr    %cl,%eax
  80175c:	89 e9                	mov    %ebp,%ecx
  80175e:	d3 e2                	shl    %cl,%edx
  801760:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801765:	09 d0                	or     %edx,%eax
  801767:	89 f2                	mov    %esi,%edx
  801769:	d3 ea                	shr    %cl,%edx
  80176b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80176f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801773:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801777:	83 c4 1c             	add    $0x1c,%esp
  80177a:	c3                   	ret    
  80177b:	90                   	nop
  80177c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801780:	39 d6                	cmp    %edx,%esi
  801782:	75 c7                	jne    80174b <__umoddi3+0x11b>
  801784:	89 d7                	mov    %edx,%edi
  801786:	89 c1                	mov    %eax,%ecx
  801788:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80178c:	1b 3c 24             	sbb    (%esp),%edi
  80178f:	eb ba                	jmp    80174b <__umoddi3+0x11b>
  801791:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801798:	39 f5                	cmp    %esi,%ebp
  80179a:	0f 82 f1 fe ff ff    	jb     801691 <__umoddi3+0x61>
  8017a0:	e9 f8 fe ff ff       	jmp    80169d <__umoddi3+0x6d>
