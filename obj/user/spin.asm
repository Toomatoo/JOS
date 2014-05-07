
obj/user/spin.debug:     file format elf32-i386


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
  800047:	c7 04 24 20 28 80 00 	movl   $0x802820,(%esp)
  80004e:	e8 7c 01 00 00       	call   8001cf <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 df 11 00 00       	call   801237 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 98 28 80 00 	movl   $0x802898,(%esp)
  800065:	e8 65 01 00 00       	call   8001cf <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 48 28 80 00 	movl   $0x802848,(%esp)
  800073:	e8 57 01 00 00       	call   8001cf <cprintf>
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
  8000a5:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  8000ac:	e8 1e 01 00 00       	call   8001cf <cprintf>
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
  8000e4:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800116:	e8 23 16 00 00       	call   80173e <close_all>
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 38 0c 00 00       	call   800d5f <sys_env_destroy>
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    
  800129:	00 00                	add    %al,(%eax)
	...

0080012c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	53                   	push   %ebx
  800130:	83 ec 14             	sub    $0x14,%esp
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013f:	83 c0 01             	add    $0x1,%eax
  800142:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800144:	3d ff 00 00 00       	cmp    $0xff,%eax
  800149:	75 19                	jne    800164 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80014b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800152:	00 
  800153:	8d 43 08             	lea    0x8(%ebx),%eax
  800156:	89 04 24             	mov    %eax,(%esp)
  800159:	e8 a2 0b 00 00       	call   800d00 <sys_cputs>
		b->idx = 0;
  80015e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800164:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800168:	83 c4 14             	add    $0x14,%esp
  80016b:	5b                   	pop    %ebx
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800177:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017e:	00 00 00 
	b.cnt = 0;
  800181:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800188:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 44 24 08          	mov    %eax,0x8(%esp)
  800199:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a3:	c7 04 24 2c 01 80 00 	movl   $0x80012c,(%esp)
  8001aa:	e8 97 01 00 00       	call   800346 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 39 0b 00 00       	call   800d00 <sys_cputs>

	return b.cnt;
}
  8001c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	e8 87 ff ff ff       	call   80016e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    
  8001e9:	00 00                	add    %al,(%eax)
	...

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 3c             	sub    $0x3c,%esp
  8001f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f8:	89 d7                	mov    %edx,%edi
  8001fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800206:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800209:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020c:	b8 00 00 00 00       	mov    $0x0,%eax
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	72 11                	jb     800227 <printnum+0x3b>
  800216:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800219:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021c:	76 09                	jbe    800227 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021e:	83 eb 01             	sub    $0x1,%ebx
  800221:	85 db                	test   %ebx,%ebx
  800223:	7f 51                	jg     800276 <printnum+0x8a>
  800225:	eb 5e                	jmp    800285 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800227:	89 74 24 10          	mov    %esi,0x10(%esp)
  80022b:	83 eb 01             	sub    $0x1,%ebx
  80022e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	89 44 24 08          	mov    %eax,0x8(%esp)
  800239:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80023d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800241:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800248:	00 
  800249:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	e8 15 23 00 00       	call   802570 <__udivdi3>
  80025b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80025f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026a:	89 fa                	mov    %edi,%edx
  80026c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026f:	e8 78 ff ff ff       	call   8001ec <printnum>
  800274:	eb 0f                	jmp    800285 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027a:	89 34 24             	mov    %esi,(%esp)
  80027d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	75 f1                	jne    800276 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800285:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800289:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80028d:	8b 45 10             	mov    0x10(%ebp),%eax
  800290:	89 44 24 08          	mov    %eax,0x8(%esp)
  800294:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029b:	00 
  80029c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a9:	e8 f2 23 00 00       	call   8026a0 <__umoddi3>
  8002ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b2:	0f be 80 c0 28 80 00 	movsbl 0x8028c0(%eax),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002bf:	83 c4 3c             	add    $0x3c,%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5e                   	pop    %esi
  8002c4:	5f                   	pop    %edi
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ca:	83 fa 01             	cmp    $0x1,%edx
  8002cd:	7e 0e                	jle    8002dd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	8b 52 04             	mov    0x4(%edx),%edx
  8002db:	eb 22                	jmp    8002ff <getuint+0x38>
	else if (lflag)
  8002dd:	85 d2                	test   %edx,%edx
  8002df:	74 10                	je     8002f1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 02                	mov    (%edx),%eax
  8002ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ef:	eb 0e                	jmp    8002ff <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800307:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	3b 50 04             	cmp    0x4(%eax),%edx
  800310:	73 0a                	jae    80031c <sprintputch+0x1b>
		*b->buf++ = ch;
  800312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800315:	88 0a                	mov    %cl,(%edx)
  800317:	83 c2 01             	add    $0x1,%edx
  80031a:	89 10                	mov    %edx,(%eax)
}
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800324:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800327:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032b:	8b 45 10             	mov    0x10(%ebp),%eax
  80032e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	e8 02 00 00 00       	call   800346 <vprintfmt>
	va_end(ap);
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
  80034c:	83 ec 5c             	sub    $0x5c,%esp
  80034f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800352:	8b 75 10             	mov    0x10(%ebp),%esi
  800355:	eb 12                	jmp    800369 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800357:	85 c0                	test   %eax,%eax
  800359:	0f 84 e4 04 00 00    	je     800843 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80035f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	0f b6 06             	movzbl (%esi),%eax
  80036c:	83 c6 01             	add    $0x1,%esi
  80036f:	83 f8 25             	cmp    $0x25,%eax
  800372:	75 e3                	jne    800357 <vprintfmt+0x11>
  800374:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800378:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80037f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800384:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80038b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800390:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800393:	eb 2b                	jmp    8003c0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800398:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80039c:	eb 22                	jmp    8003c0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a1:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003a5:	eb 19                	jmp    8003c0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003aa:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003b1:	eb 0d                	jmp    8003c0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003b9:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	0f b6 06             	movzbl (%esi),%eax
  8003c3:	0f b6 d0             	movzbl %al,%edx
  8003c6:	8d 7e 01             	lea    0x1(%esi),%edi
  8003c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003cc:	83 e8 23             	sub    $0x23,%eax
  8003cf:	3c 55                	cmp    $0x55,%al
  8003d1:	0f 87 46 04 00 00    	ja     80081d <vprintfmt+0x4d7>
  8003d7:	0f b6 c0             	movzbl %al,%eax
  8003da:	ff 24 85 20 2a 80 00 	jmp    *0x802a20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e1:	83 ea 30             	sub    $0x30,%edx
  8003e4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003e7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003eb:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003f1:	83 fa 09             	cmp    $0x9,%edx
  8003f4:	77 4a                	ja     800440 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003fc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ff:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800403:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800406:	8d 50 d0             	lea    -0x30(%eax),%edx
  800409:	83 fa 09             	cmp    $0x9,%edx
  80040c:	76 eb                	jbe    8003f9 <vprintfmt+0xb3>
  80040e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800411:	eb 2d                	jmp    800440 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 50 04             	lea    0x4(%eax),%edx
  800419:	89 55 14             	mov    %edx,0x14(%ebp)
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800424:	eb 1a                	jmp    800440 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800429:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80042d:	79 91                	jns    8003c0 <vprintfmt+0x7a>
  80042f:	e9 73 ff ff ff       	jmp    8003a7 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800437:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80043e:	eb 80                	jmp    8003c0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800440:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800444:	0f 89 76 ff ff ff    	jns    8003c0 <vprintfmt+0x7a>
  80044a:	e9 64 ff ff ff       	jmp    8003b3 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800455:	e9 66 ff ff ff       	jmp    8003c0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800472:	e9 f2 fe ff ff       	jmp    800369 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800477:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80047b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80047e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800482:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800485:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800489:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80048c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80048f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800493:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800496:	80 f9 09             	cmp    $0x9,%cl
  800499:	77 1d                	ja     8004b8 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80049b:	0f be c0             	movsbl %al,%eax
  80049e:	6b c0 64             	imul   $0x64,%eax,%eax
  8004a1:	0f be d2             	movsbl %dl,%edx
  8004a4:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004a7:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004ae:	a3 04 30 80 00       	mov    %eax,0x803004
  8004b3:	e9 b1 fe ff ff       	jmp    800369 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004b8:	c7 44 24 04 d8 28 80 	movl   $0x8028d8,0x4(%esp)
  8004bf:	00 
  8004c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	e8 10 05 00 00       	call   8009db <strcmp>
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	75 0f                	jne    8004de <vprintfmt+0x198>
  8004cf:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8004d6:	00 00 00 
  8004d9:	e9 8b fe ff ff       	jmp    800369 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004de:	c7 44 24 04 dc 28 80 	movl   $0x8028dc,0x4(%esp)
  8004e5:	00 
  8004e6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004e9:	89 14 24             	mov    %edx,(%esp)
  8004ec:	e8 ea 04 00 00       	call   8009db <strcmp>
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	75 0f                	jne    800504 <vprintfmt+0x1be>
  8004f5:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8004fc:	00 00 00 
  8004ff:	e9 65 fe ff ff       	jmp    800369 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800504:	c7 44 24 04 e0 28 80 	movl   $0x8028e0,0x4(%esp)
  80050b:	00 
  80050c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80050f:	89 0c 24             	mov    %ecx,(%esp)
  800512:	e8 c4 04 00 00       	call   8009db <strcmp>
  800517:	85 c0                	test   %eax,%eax
  800519:	75 0f                	jne    80052a <vprintfmt+0x1e4>
  80051b:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  800522:	00 00 00 
  800525:	e9 3f fe ff ff       	jmp    800369 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80052a:	c7 44 24 04 e4 28 80 	movl   $0x8028e4,0x4(%esp)
  800531:	00 
  800532:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800535:	89 3c 24             	mov    %edi,(%esp)
  800538:	e8 9e 04 00 00       	call   8009db <strcmp>
  80053d:	85 c0                	test   %eax,%eax
  80053f:	75 0f                	jne    800550 <vprintfmt+0x20a>
  800541:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800548:	00 00 00 
  80054b:	e9 19 fe ff ff       	jmp    800369 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800550:	c7 44 24 04 e8 28 80 	movl   $0x8028e8,0x4(%esp)
  800557:	00 
  800558:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 78 04 00 00       	call   8009db <strcmp>
  800563:	85 c0                	test   %eax,%eax
  800565:	75 0f                	jne    800576 <vprintfmt+0x230>
  800567:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  80056e:	00 00 00 
  800571:	e9 f3 fd ff ff       	jmp    800369 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800576:	c7 44 24 04 ec 28 80 	movl   $0x8028ec,0x4(%esp)
  80057d:	00 
  80057e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800581:	89 14 24             	mov    %edx,(%esp)
  800584:	e8 52 04 00 00       	call   8009db <strcmp>
  800589:	83 f8 01             	cmp    $0x1,%eax
  80058c:	19 c0                	sbb    %eax,%eax
  80058e:	f7 d0                	not    %eax
  800590:	83 c0 08             	add    $0x8,%eax
  800593:	a3 04 30 80 00       	mov    %eax,0x803004
  800598:	e9 cc fd ff ff       	jmp    800369 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 c2                	mov    %eax,%edx
  8005aa:	c1 fa 1f             	sar    $0x1f,%edx
  8005ad:	31 d0                	xor    %edx,%eax
  8005af:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b1:	83 f8 0f             	cmp    $0xf,%eax
  8005b4:	7f 0b                	jg     8005c1 <vprintfmt+0x27b>
  8005b6:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  8005bd:	85 d2                	test   %edx,%edx
  8005bf:	75 23                	jne    8005e4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c5:	c7 44 24 08 f0 28 80 	movl   $0x8028f0,0x8(%esp)
  8005cc:	00 
  8005cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d4:	89 3c 24             	mov    %edi,(%esp)
  8005d7:	e8 42 fd ff ff       	call   80031e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005df:	e9 85 fd ff ff       	jmp    800369 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e8:	c7 44 24 08 41 2e 80 	movl   $0x802e41,0x8(%esp)
  8005ef:	00 
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f7:	89 3c 24             	mov    %edi,(%esp)
  8005fa:	e8 1f fd ff ff       	call   80031e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800602:	e9 62 fd ff ff       	jmp    800369 <vprintfmt+0x23>
  800607:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80060a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80060d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80061b:	85 f6                	test   %esi,%esi
  80061d:	b8 d1 28 80 00       	mov    $0x8028d1,%eax
  800622:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800625:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800629:	7e 06                	jle    800631 <vprintfmt+0x2eb>
  80062b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80062f:	75 13                	jne    800644 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800631:	0f be 06             	movsbl (%esi),%eax
  800634:	83 c6 01             	add    $0x1,%esi
  800637:	85 c0                	test   %eax,%eax
  800639:	0f 85 94 00 00 00    	jne    8006d3 <vprintfmt+0x38d>
  80063f:	e9 81 00 00 00       	jmp    8006c5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800644:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800648:	89 34 24             	mov    %esi,(%esp)
  80064b:	e8 9b 02 00 00       	call   8008eb <strnlen>
  800650:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800653:	29 c2                	sub    %eax,%edx
  800655:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800658:	85 d2                	test   %edx,%edx
  80065a:	7e d5                	jle    800631 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80065c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800660:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800663:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800666:	89 d6                	mov    %edx,%esi
  800668:	89 cf                	mov    %ecx,%edi
  80066a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066e:	89 3c 24             	mov    %edi,(%esp)
  800671:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800674:	83 ee 01             	sub    $0x1,%esi
  800677:	75 f1                	jne    80066a <vprintfmt+0x324>
  800679:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80067c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80067f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800682:	eb ad                	jmp    800631 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800684:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800688:	74 1b                	je     8006a5 <vprintfmt+0x35f>
  80068a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80068d:	83 fa 5e             	cmp    $0x5e,%edx
  800690:	76 13                	jbe    8006a5 <vprintfmt+0x35f>
					putch('?', putdat);
  800692:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800695:	89 44 24 04          	mov    %eax,0x4(%esp)
  800699:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a0:	ff 55 08             	call   *0x8(%ebp)
  8006a3:	eb 0d                	jmp    8006b2 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ac:	89 04 24             	mov    %eax,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b2:	83 eb 01             	sub    $0x1,%ebx
  8006b5:	0f be 06             	movsbl (%esi),%eax
  8006b8:	83 c6 01             	add    $0x1,%esi
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	75 1a                	jne    8006d9 <vprintfmt+0x393>
  8006bf:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006c2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006cc:	7f 1c                	jg     8006ea <vprintfmt+0x3a4>
  8006ce:	e9 96 fc ff ff       	jmp    800369 <vprintfmt+0x23>
  8006d3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006d6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d9:	85 ff                	test   %edi,%edi
  8006db:	78 a7                	js     800684 <vprintfmt+0x33e>
  8006dd:	83 ef 01             	sub    $0x1,%edi
  8006e0:	79 a2                	jns    800684 <vprintfmt+0x33e>
  8006e2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006e5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e8:	eb db                	jmp    8006c5 <vprintfmt+0x37f>
  8006ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ed:	89 de                	mov    %ebx,%esi
  8006ef:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ff:	83 eb 01             	sub    $0x1,%ebx
  800702:	75 ee                	jne    8006f2 <vprintfmt+0x3ac>
  800704:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800709:	e9 5b fc ff ff       	jmp    800369 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070e:	83 f9 01             	cmp    $0x1,%ecx
  800711:	7e 10                	jle    800723 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8d 50 08             	lea    0x8(%eax),%edx
  800719:	89 55 14             	mov    %edx,0x14(%ebp)
  80071c:	8b 30                	mov    (%eax),%esi
  80071e:	8b 78 04             	mov    0x4(%eax),%edi
  800721:	eb 26                	jmp    800749 <vprintfmt+0x403>
	else if (lflag)
  800723:	85 c9                	test   %ecx,%ecx
  800725:	74 12                	je     800739 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8d 50 04             	lea    0x4(%eax),%edx
  80072d:	89 55 14             	mov    %edx,0x14(%ebp)
  800730:	8b 30                	mov    (%eax),%esi
  800732:	89 f7                	mov    %esi,%edi
  800734:	c1 ff 1f             	sar    $0x1f,%edi
  800737:	eb 10                	jmp    800749 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8d 50 04             	lea    0x4(%eax),%edx
  80073f:	89 55 14             	mov    %edx,0x14(%ebp)
  800742:	8b 30                	mov    (%eax),%esi
  800744:	89 f7                	mov    %esi,%edi
  800746:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800749:	85 ff                	test   %edi,%edi
  80074b:	78 0e                	js     80075b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074d:	89 f0                	mov    %esi,%eax
  80074f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800751:	be 0a 00 00 00       	mov    $0xa,%esi
  800756:	e9 84 00 00 00       	jmp    8007df <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800766:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800769:	89 f0                	mov    %esi,%eax
  80076b:	89 fa                	mov    %edi,%edx
  80076d:	f7 d8                	neg    %eax
  80076f:	83 d2 00             	adc    $0x0,%edx
  800772:	f7 da                	neg    %edx
			}
			base = 10;
  800774:	be 0a 00 00 00       	mov    $0xa,%esi
  800779:	eb 64                	jmp    8007df <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077b:	89 ca                	mov    %ecx,%edx
  80077d:	8d 45 14             	lea    0x14(%ebp),%eax
  800780:	e8 42 fb ff ff       	call   8002c7 <getuint>
			base = 10;
  800785:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80078a:	eb 53                	jmp    8007df <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80078c:	89 ca                	mov    %ecx,%edx
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	e8 31 fb ff ff       	call   8002c7 <getuint>
    			base = 8;
  800796:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80079b:	eb 42                	jmp    8007df <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80079d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007af:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 50 04             	lea    0x4(%eax),%edx
  8007bf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007ce:	eb 0f                	jmp    8007df <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d0:	89 ca                	mov    %ecx,%edx
  8007d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d5:	e8 ed fa ff ff       	call   8002c7 <getuint>
			base = 16;
  8007da:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007df:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007e7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007ea:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007ee:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007f2:	89 04 24             	mov    %eax,(%esp)
  8007f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f9:	89 da                	mov    %ebx,%edx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	e8 e9 f9 ff ff       	call   8001ec <printnum>
			break;
  800803:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800806:	e9 5e fb ff ff       	jmp    800369 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80080b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080f:	89 14 24             	mov    %edx,(%esp)
  800812:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800815:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800818:	e9 4c fb ff ff       	jmp    800369 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80081d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800821:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800828:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80082f:	0f 84 34 fb ff ff    	je     800369 <vprintfmt+0x23>
  800835:	83 ee 01             	sub    $0x1,%esi
  800838:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80083c:	75 f7                	jne    800835 <vprintfmt+0x4ef>
  80083e:	e9 26 fb ff ff       	jmp    800369 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800843:	83 c4 5c             	add    $0x5c,%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 28             	sub    $0x28,%esp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800857:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800868:	85 c0                	test   %eax,%eax
  80086a:	74 30                	je     80089c <vsnprintf+0x51>
  80086c:	85 d2                	test   %edx,%edx
  80086e:	7e 2c                	jle    80089c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800877:	8b 45 10             	mov    0x10(%ebp),%eax
  80087a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	c7 04 24 01 03 80 00 	movl   $0x800301,(%esp)
  80088c:	e8 b5 fa ff ff       	call   800346 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800891:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800894:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089a:	eb 05                	jmp    8008a1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	89 04 24             	mov    %eax,(%esp)
  8008c4:	e8 82 ff ff ff       	call   80084b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    
  8008cb:	00 00                	add    %al,(%eax)
  8008cd:	00 00                	add    %al,(%eax)
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
  800d93:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800daa:	e8 61 15 00 00       	call   802310 <_panic>

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
  800e00:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800e52:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800e69:	e8 a2 14 00 00       	call   802310 <_panic>

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
  800eb0:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800ec7:	e8 44 14 00 00       	call   802310 <_panic>

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
  800f0e:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800f15:	00 
  800f16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1d:	00 
  800f1e:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800f25:	e8 e6 13 00 00       	call   802310 <_panic>

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
  800f6c:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800f83:	e8 88 13 00 00       	call   802310 <_panic>

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

00800f95 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800fbc:	7e 28                	jle    800fe6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fc9:	00 
  800fca:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800fe1:	e8 2a 13 00 00       	call   802310 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fe6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fef:	89 ec                	mov    %ebp,%esp
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 38             	sub    $0x38,%esp
  800ff9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ffc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
  801007:	b8 0a 00 00 00       	mov    $0xa,%eax
  80100c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100f:	8b 55 08             	mov    0x8(%ebp),%edx
  801012:	89 df                	mov    %ebx,%edi
  801014:	89 de                	mov    %ebx,%esi
  801016:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	7e 28                	jle    801044 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801020:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801027:	00 
  801028:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  80103f:	e8 cc 12 00 00       	call   802310 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801044:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801047:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80104d:	89 ec                	mov    %ebp,%esp
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80105a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80105d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801060:	be 00 00 00 00       	mov    $0x0,%esi
  801065:	b8 0c 00 00 00       	mov    $0xc,%eax
  80106a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80106d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801070:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801073:	8b 55 08             	mov    0x8(%ebp),%edx
  801076:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801078:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801081:	89 ec                	mov    %ebp,%esp
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 38             	sub    $0x38,%esp
  80108b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801091:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801094:	b9 00 00 00 00       	mov    $0x0,%ecx
  801099:	b8 0d 00 00 00       	mov    $0xd,%eax
  80109e:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a1:	89 cb                	mov    %ecx,%ebx
  8010a3:	89 cf                	mov    %ecx,%edi
  8010a5:	89 ce                	mov    %ecx,%esi
  8010a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	7e 28                	jle    8010d5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010b8:	00 
  8010b9:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  8010c0:	00 
  8010c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  8010d0:	e8 3b 12 00 00       	call   802310 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010de:	89 ec                	mov    %ebp,%esp
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010eb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fe:	89 cb                	mov    %ecx,%ebx
  801100:	89 cf                	mov    %ecx,%edi
  801102:	89 ce                	mov    %ecx,%esi
  801104:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801106:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801109:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80110f:	89 ec                	mov    %ebp,%esp
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    
	...

00801114 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	53                   	push   %ebx
  801118:	83 ec 24             	sub    $0x24,%esp
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80111e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  801120:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801124:	75 1c                	jne    801142 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  801126:	c7 44 24 08 0a 2c 80 	movl   $0x802c0a,0x8(%esp)
  80112d:	00 
  80112e:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801135:	00 
  801136:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  80113d:	e8 ce 11 00 00       	call   802310 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801142:	89 d8                	mov    %ebx,%eax
  801144:	c1 e8 0c             	shr    $0xc,%eax
  801147:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114e:	f6 c4 08             	test   $0x8,%ah
  801151:	0f 84 be 00 00 00    	je     801215 <pgfault+0x101>
  801157:	89 d8                	mov    %ebx,%eax
  801159:	c1 e8 16             	shr    $0x16,%eax
  80115c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801163:	a8 01                	test   $0x1,%al
  801165:	0f 84 aa 00 00 00    	je     801215 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  80116b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801172:	00 
  801173:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80117a:	00 
  80117b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801182:	e8 95 fc ff ff       	call   800e1c <sys_page_alloc>
		if (r < 0)
  801187:	85 c0                	test   %eax,%eax
  801189:	79 20                	jns    8011ab <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80118b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118f:	c7 44 24 08 44 2c 80 	movl   $0x802c44,0x8(%esp)
  801196:	00 
  801197:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80119e:	00 
  80119f:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  8011a6:	e8 65 11 00 00       	call   802310 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  8011ab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  8011b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011b8:	00 
  8011b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011bd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011c4:	e8 bc f9 ff ff       	call   800b85 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8011c9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011d0:	00 
  8011d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011dc:	00 
  8011dd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011e4:	00 
  8011e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ec:	e8 8a fc ff ff       	call   800e7b <sys_page_map>
		if (r < 0)
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	79 3c                	jns    801231 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  8011f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f9:	c7 44 24 08 6c 2c 80 	movl   $0x802c6c,0x8(%esp)
  801200:	00 
  801201:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801208:	00 
  801209:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  801210:	e8 fb 10 00 00       	call   802310 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801215:	c7 44 24 08 90 2c 80 	movl   $0x802c90,0x8(%esp)
  80121c:	00 
  80121d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801224:	00 
  801225:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  80122c:	e8 df 10 00 00       	call   802310 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801231:	83 c4 24             	add    $0x24,%esp
  801234:	5b                   	pop    %ebx
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801240:	c7 04 24 14 11 80 00 	movl   $0x801114,(%esp)
  801247:	e8 1c 11 00 00       	call   802368 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80124c:	bf 07 00 00 00       	mov    $0x7,%edi
  801251:	89 f8                	mov    %edi,%eax
  801253:	cd 30                	int    $0x30
  801255:	89 c7                	mov    %eax,%edi
  801257:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80125a:	85 c0                	test   %eax,%eax
  80125c:	79 20                	jns    80127e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80125e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801262:	c7 44 24 08 b0 2c 80 	movl   $0x802cb0,0x8(%esp)
  801269:	00 
  80126a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801271:	00 
  801272:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  801279:	e8 92 10 00 00       	call   802310 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80127e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801283:	85 c0                	test   %eax,%eax
  801285:	75 1c                	jne    8012a3 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801287:	e8 30 fb ff ff       	call   800dbc <sys_getenvid>
  80128c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801291:	c1 e0 07             	shl    $0x7,%eax
  801294:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801299:	a3 04 40 80 00       	mov    %eax,0x804004
		//cprintf("child fork ok!\n");
		return 0;
  80129e:	e9 51 02 00 00       	jmp    8014f4 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  8012a3:	89 d8                	mov    %ebx,%eax
  8012a5:	c1 e8 16             	shr    $0x16,%eax
  8012a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012af:	a8 01                	test   $0x1,%al
  8012b1:	0f 84 87 01 00 00    	je     80143e <fork+0x207>
  8012b7:	89 d8                	mov    %ebx,%eax
  8012b9:	c1 e8 0c             	shr    $0xc,%eax
  8012bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c3:	f6 c2 01             	test   $0x1,%dl
  8012c6:	0f 84 72 01 00 00    	je     80143e <fork+0x207>
  8012cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d3:	f6 c2 04             	test   $0x4,%dl
  8012d6:	0f 84 62 01 00 00    	je     80143e <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8012dc:	89 c6                	mov    %eax,%esi
  8012de:	c1 e6 0c             	shl    $0xc,%esi
  8012e1:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8012e7:	0f 84 51 01 00 00    	je     80143e <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  8012ed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f4:	f6 c6 04             	test   $0x4,%dh
  8012f7:	74 53                	je     80134c <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8012f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801300:	25 07 0e 00 00       	and    $0xe07,%eax
  801305:	89 44 24 10          	mov    %eax,0x10(%esp)
  801309:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80130d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801310:	89 44 24 08          	mov    %eax,0x8(%esp)
  801314:	89 74 24 04          	mov    %esi,0x4(%esp)
  801318:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131f:	e8 57 fb ff ff       	call   800e7b <sys_page_map>
		if (r < 0)
  801324:	85 c0                	test   %eax,%eax
  801326:	0f 89 12 01 00 00    	jns    80143e <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  80132c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801330:	c7 44 24 08 d0 2c 80 	movl   $0x802cd0,0x8(%esp)
  801337:	00 
  801338:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80133f:	00 
  801340:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  801347:	e8 c4 0f 00 00       	call   802310 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80134c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801353:	f6 c2 02             	test   $0x2,%dl
  801356:	75 10                	jne    801368 <fork+0x131>
  801358:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135f:	f6 c4 08             	test   $0x8,%ah
  801362:	0f 84 8f 00 00 00    	je     8013f7 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801368:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80136f:	00 
  801370:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801377:	89 44 24 08          	mov    %eax,0x8(%esp)
  80137b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80137f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801386:	e8 f0 fa ff ff       	call   800e7b <sys_page_map>
		if (r < 0)
  80138b:	85 c0                	test   %eax,%eax
  80138d:	79 20                	jns    8013af <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80138f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801393:	c7 44 24 08 fc 2c 80 	movl   $0x802cfc,0x8(%esp)
  80139a:	00 
  80139b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8013a2:	00 
  8013a3:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  8013aa:	e8 61 0f 00 00       	call   802310 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8013af:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013b6:	00 
  8013b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013c2:	00 
  8013c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ce:	e8 a8 fa ff ff       	call   800e7b <sys_page_map>
		if (r < 0)
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	79 67                	jns    80143e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8013d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013db:	c7 44 24 08 fc 2c 80 	movl   $0x802cfc,0x8(%esp)
  8013e2:	00 
  8013e3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8013ea:	00 
  8013eb:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  8013f2:	e8 19 0f 00 00       	call   802310 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  8013f7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8013fe:	00 
  8013ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801403:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801406:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801415:	e8 61 fa ff ff       	call   800e7b <sys_page_map>
		if (r < 0)
  80141a:	85 c0                	test   %eax,%eax
  80141c:	79 20                	jns    80143e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  80141e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801422:	c7 44 24 08 fc 2c 80 	movl   $0x802cfc,0x8(%esp)
  801429:	00 
  80142a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801431:	00 
  801432:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  801439:	e8 d2 0e 00 00       	call   802310 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  80143e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801444:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80144a:	0f 85 53 fe ff ff    	jne    8012a3 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801450:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801457:	00 
  801458:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80145f:	ee 
  801460:	89 3c 24             	mov    %edi,(%esp)
  801463:	e8 b4 f9 ff ff       	call   800e1c <sys_page_alloc>
	if (res < 0)
  801468:	85 c0                	test   %eax,%eax
  80146a:	79 20                	jns    80148c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  80146c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801470:	c7 44 24 08 20 2d 80 	movl   $0x802d20,0x8(%esp)
  801477:	00 
  801478:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80147f:	00 
  801480:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  801487:	e8 84 0e 00 00       	call   802310 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80148c:	c7 44 24 04 f4 23 80 	movl   $0x8023f4,0x4(%esp)
  801493:	00 
  801494:	89 3c 24             	mov    %edi,(%esp)
  801497:	e8 57 fb ff ff       	call   800ff3 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80149c:	85 c0                	test   %eax,%eax
  80149e:	79 20                	jns    8014c0 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  8014a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a4:	c7 44 24 08 44 2d 80 	movl   $0x802d44,0x8(%esp)
  8014ab:	00 
  8014ac:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8014b3:	00 
  8014b4:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  8014bb:	e8 50 0e 00 00       	call   802310 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  8014c0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8014c7:	00 
  8014c8:	89 3c 24             	mov    %edi,(%esp)
  8014cb:	e8 67 fa ff ff       	call   800f37 <sys_env_set_status>
	if (res < 0)
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	79 20                	jns    8014f4 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  8014d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d8:	c7 44 24 08 74 2d 80 	movl   $0x802d74,0x8(%esp)
  8014df:	00 
  8014e0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  8014e7:	00 
  8014e8:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  8014ef:	e8 1c 0e 00 00       	call   802310 <_panic>

	return pid;
	//panic("fork not implemented");
}
  8014f4:	89 f8                	mov    %edi,%eax
  8014f6:	83 c4 3c             	add    $0x3c,%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <sfork>:

// Challenge!
int
sfork(void)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801504:	c7 44 24 08 2c 2c 80 	movl   $0x802c2c,0x8(%esp)
  80150b:	00 
  80150c:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801513:	00 
  801514:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  80151b:	e8 f0 0d 00 00       	call   802310 <_panic>

00801520 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	05 00 00 00 30       	add    $0x30000000,%eax
  80152b:	c1 e8 0c             	shr    $0xc,%eax
}
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 df ff ff ff       	call   801520 <fd2num>
  801541:	05 20 00 0d 00       	add    $0xd0020,%eax
  801546:	c1 e0 0c             	shl    $0xc,%eax
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801552:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801557:	a8 01                	test   $0x1,%al
  801559:	74 34                	je     80158f <fd_alloc+0x44>
  80155b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801560:	a8 01                	test   $0x1,%al
  801562:	74 32                	je     801596 <fd_alloc+0x4b>
  801564:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801569:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	c1 ea 16             	shr    $0x16,%edx
  801570:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801577:	f6 c2 01             	test   $0x1,%dl
  80157a:	74 1f                	je     80159b <fd_alloc+0x50>
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	c1 ea 0c             	shr    $0xc,%edx
  801581:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801588:	f6 c2 01             	test   $0x1,%dl
  80158b:	75 17                	jne    8015a4 <fd_alloc+0x59>
  80158d:	eb 0c                	jmp    80159b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80158f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801594:	eb 05                	jmp    80159b <fd_alloc+0x50>
  801596:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80159b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80159d:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a2:	eb 17                	jmp    8015bb <fd_alloc+0x70>
  8015a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015ae:	75 b9                	jne    801569 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8015b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015bb:	5b                   	pop    %ebx
  8015bc:	5d                   	pop    %ebp
  8015bd:	c3                   	ret    

008015be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015c9:	83 fa 1f             	cmp    $0x1f,%edx
  8015cc:	77 3f                	ja     80160d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015ce:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8015d4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015d7:	89 d0                	mov    %edx,%eax
  8015d9:	c1 e8 16             	shr    $0x16,%eax
  8015dc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015e8:	f6 c1 01             	test   $0x1,%cl
  8015eb:	74 20                	je     80160d <fd_lookup+0x4f>
  8015ed:	89 d0                	mov    %edx,%eax
  8015ef:	c1 e8 0c             	shr    $0xc,%eax
  8015f2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015fe:	f6 c1 01             	test   $0x1,%cl
  801601:	74 0a                	je     80160d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801603:	8b 45 0c             	mov    0xc(%ebp),%eax
  801606:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801608:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 14             	sub    $0x14,%esp
  801616:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80161c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801621:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801627:	75 17                	jne    801640 <dev_lookup+0x31>
  801629:	eb 07                	jmp    801632 <dev_lookup+0x23>
  80162b:	39 0a                	cmp    %ecx,(%edx)
  80162d:	75 11                	jne    801640 <dev_lookup+0x31>
  80162f:	90                   	nop
  801630:	eb 05                	jmp    801637 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801632:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801637:	89 13                	mov    %edx,(%ebx)
			return 0;
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
  80163e:	eb 35                	jmp    801675 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801640:	83 c0 01             	add    $0x1,%eax
  801643:	8b 14 85 18 2e 80 00 	mov    0x802e18(,%eax,4),%edx
  80164a:	85 d2                	test   %edx,%edx
  80164c:	75 dd                	jne    80162b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80164e:	a1 04 40 80 00       	mov    0x804004,%eax
  801653:	8b 40 48             	mov    0x48(%eax),%eax
  801656:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80165a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165e:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  801665:	e8 65 eb ff ff       	call   8001cf <cprintf>
	*dev = 0;
  80166a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801670:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801675:	83 c4 14             	add    $0x14,%esp
  801678:	5b                   	pop    %ebx
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 38             	sub    $0x38,%esp
  801681:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801684:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801687:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80168a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801691:	89 3c 24             	mov    %edi,(%esp)
  801694:	e8 87 fe ff ff       	call   801520 <fd2num>
  801699:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80169c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016a0:	89 04 24             	mov    %eax,(%esp)
  8016a3:	e8 16 ff ff ff       	call   8015be <fd_lookup>
  8016a8:	89 c3                	mov    %eax,%ebx
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 05                	js     8016b3 <fd_close+0x38>
	    || fd != fd2)
  8016ae:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8016b1:	74 0e                	je     8016c1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8016b3:	89 f0                	mov    %esi,%eax
  8016b5:	84 c0                	test   %al,%al
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bc:	0f 44 d8             	cmove  %eax,%ebx
  8016bf:	eb 3d                	jmp    8016fe <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	8b 07                	mov    (%edi),%eax
  8016ca:	89 04 24             	mov    %eax,(%esp)
  8016cd:	e8 3d ff ff ff       	call   80160f <dev_lookup>
  8016d2:	89 c3                	mov    %eax,%ebx
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 16                	js     8016ee <fd_close+0x73>
		if (dev->dev_close)
  8016d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8016de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	74 07                	je     8016ee <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8016e7:	89 3c 24             	mov    %edi,(%esp)
  8016ea:	ff d0                	call   *%eax
  8016ec:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f9:	e8 db f7 ff ff       	call   800ed9 <sys_page_unmap>
	return r;
}
  8016fe:	89 d8                	mov    %ebx,%eax
  801700:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801703:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801706:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801709:	89 ec                	mov    %ebp,%esp
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	89 04 24             	mov    %eax,(%esp)
  801720:	e8 99 fe ff ff       	call   8015be <fd_lookup>
  801725:	85 c0                	test   %eax,%eax
  801727:	78 13                	js     80173c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801729:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801730:	00 
  801731:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801734:	89 04 24             	mov    %eax,(%esp)
  801737:	e8 3f ff ff ff       	call   80167b <fd_close>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <close_all>:

void
close_all(void)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801745:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80174a:	89 1c 24             	mov    %ebx,(%esp)
  80174d:	e8 bb ff ff ff       	call   80170d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801752:	83 c3 01             	add    $0x1,%ebx
  801755:	83 fb 20             	cmp    $0x20,%ebx
  801758:	75 f0                	jne    80174a <close_all+0xc>
		close(i);
}
  80175a:	83 c4 14             	add    $0x14,%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 58             	sub    $0x58,%esp
  801766:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801769:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80176c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80176f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801772:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	8b 45 08             	mov    0x8(%ebp),%eax
  80177c:	89 04 24             	mov    %eax,(%esp)
  80177f:	e8 3a fe ff ff       	call   8015be <fd_lookup>
  801784:	89 c3                	mov    %eax,%ebx
  801786:	85 c0                	test   %eax,%eax
  801788:	0f 88 e1 00 00 00    	js     80186f <dup+0x10f>
		return r;
	close(newfdnum);
  80178e:	89 3c 24             	mov    %edi,(%esp)
  801791:	e8 77 ff ff ff       	call   80170d <close>

	newfd = INDEX2FD(newfdnum);
  801796:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80179c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80179f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 86 fd ff ff       	call   801530 <fd2data>
  8017aa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017ac:	89 34 24             	mov    %esi,(%esp)
  8017af:	e8 7c fd ff ff       	call   801530 <fd2data>
  8017b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017b7:	89 d8                	mov    %ebx,%eax
  8017b9:	c1 e8 16             	shr    $0x16,%eax
  8017bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017c3:	a8 01                	test   $0x1,%al
  8017c5:	74 46                	je     80180d <dup+0xad>
  8017c7:	89 d8                	mov    %ebx,%eax
  8017c9:	c1 e8 0c             	shr    $0xc,%eax
  8017cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017d3:	f6 c2 01             	test   $0x1,%dl
  8017d6:	74 35                	je     80180d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017df:	25 07 0e 00 00       	and    $0xe07,%eax
  8017e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017f6:	00 
  8017f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801802:	e8 74 f6 ff ff       	call   800e7b <sys_page_map>
  801807:	89 c3                	mov    %eax,%ebx
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 3b                	js     801848 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80180d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801810:	89 c2                	mov    %eax,%edx
  801812:	c1 ea 0c             	shr    $0xc,%edx
  801815:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80181c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801822:	89 54 24 10          	mov    %edx,0x10(%esp)
  801826:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80182a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801831:	00 
  801832:	89 44 24 04          	mov    %eax,0x4(%esp)
  801836:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183d:	e8 39 f6 ff ff       	call   800e7b <sys_page_map>
  801842:	89 c3                	mov    %eax,%ebx
  801844:	85 c0                	test   %eax,%eax
  801846:	79 25                	jns    80186d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801848:	89 74 24 04          	mov    %esi,0x4(%esp)
  80184c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801853:	e8 81 f6 ff ff       	call   800ed9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80185b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801866:	e8 6e f6 ff ff       	call   800ed9 <sys_page_unmap>
	return r;
  80186b:	eb 02                	jmp    80186f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80186d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801874:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801877:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80187a:	89 ec                	mov    %ebp,%esp
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 24             	sub    $0x24,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188f:	89 1c 24             	mov    %ebx,(%esp)
  801892:	e8 27 fd ff ff       	call   8015be <fd_lookup>
  801897:	85 c0                	test   %eax,%eax
  801899:	78 6d                	js     801908 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a5:	8b 00                	mov    (%eax),%eax
  8018a7:	89 04 24             	mov    %eax,(%esp)
  8018aa:	e8 60 fd ff ff       	call   80160f <dev_lookup>
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 55                	js     801908 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	8b 50 08             	mov    0x8(%eax),%edx
  8018b9:	83 e2 03             	and    $0x3,%edx
  8018bc:	83 fa 01             	cmp    $0x1,%edx
  8018bf:	75 23                	jne    8018e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c6:	8b 40 48             	mov    0x48(%eax),%eax
  8018c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d1:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  8018d8:	e8 f2 e8 ff ff       	call   8001cf <cprintf>
		return -E_INVAL;
  8018dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018e2:	eb 24                	jmp    801908 <read+0x8a>
	}
	if (!dev->dev_read)
  8018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e7:	8b 52 08             	mov    0x8(%edx),%edx
  8018ea:	85 d2                	test   %edx,%edx
  8018ec:	74 15                	je     801903 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8018ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	ff d2                	call   *%edx
  801901:	eb 05                	jmp    801908 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801903:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801908:	83 c4 24             	add    $0x24,%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	83 ec 1c             	sub    $0x1c,%esp
  801917:	8b 7d 08             	mov    0x8(%ebp),%edi
  80191a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
  801922:	85 f6                	test   %esi,%esi
  801924:	74 30                	je     801956 <readn+0x48>
  801926:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80192b:	89 f2                	mov    %esi,%edx
  80192d:	29 c2                	sub    %eax,%edx
  80192f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801933:	03 45 0c             	add    0xc(%ebp),%eax
  801936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193a:	89 3c 24             	mov    %edi,(%esp)
  80193d:	e8 3c ff ff ff       	call   80187e <read>
		if (m < 0)
  801942:	85 c0                	test   %eax,%eax
  801944:	78 10                	js     801956 <readn+0x48>
			return m;
		if (m == 0)
  801946:	85 c0                	test   %eax,%eax
  801948:	74 0a                	je     801954 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80194a:	01 c3                	add    %eax,%ebx
  80194c:	89 d8                	mov    %ebx,%eax
  80194e:	39 f3                	cmp    %esi,%ebx
  801950:	72 d9                	jb     80192b <readn+0x1d>
  801952:	eb 02                	jmp    801956 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801954:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801956:	83 c4 1c             	add    $0x1c,%esp
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5f                   	pop    %edi
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 24             	sub    $0x24,%esp
  801965:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801968:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196f:	89 1c 24             	mov    %ebx,(%esp)
  801972:	e8 47 fc ff ff       	call   8015be <fd_lookup>
  801977:	85 c0                	test   %eax,%eax
  801979:	78 68                	js     8019e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801985:	8b 00                	mov    (%eax),%eax
  801987:	89 04 24             	mov    %eax,(%esp)
  80198a:	e8 80 fc ff ff       	call   80160f <dev_lookup>
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 50                	js     8019e3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801993:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801996:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80199a:	75 23                	jne    8019bf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80199c:	a1 04 40 80 00       	mov    0x804004,%eax
  8019a1:	8b 40 48             	mov    0x48(%eax),%eax
  8019a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ac:	c7 04 24 f9 2d 80 00 	movl   $0x802df9,(%esp)
  8019b3:	e8 17 e8 ff ff       	call   8001cf <cprintf>
		return -E_INVAL;
  8019b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019bd:	eb 24                	jmp    8019e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8019c5:	85 d2                	test   %edx,%edx
  8019c7:	74 15                	je     8019de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019cc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019d7:	89 04 24             	mov    %eax,(%esp)
  8019da:	ff d2                	call   *%edx
  8019dc:	eb 05                	jmp    8019e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8019de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8019e3:	83 c4 24             	add    $0x24,%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	89 04 24             	mov    %eax,(%esp)
  8019fc:	e8 bd fb ff ff       	call   8015be <fd_lookup>
  801a01:	85 c0                	test   %eax,%eax
  801a03:	78 0e                	js     801a13 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	53                   	push   %ebx
  801a19:	83 ec 24             	sub    $0x24,%esp
  801a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a26:	89 1c 24             	mov    %ebx,(%esp)
  801a29:	e8 90 fb ff ff       	call   8015be <fd_lookup>
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 61                	js     801a93 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3c:	8b 00                	mov    (%eax),%eax
  801a3e:	89 04 24             	mov    %eax,(%esp)
  801a41:	e8 c9 fb ff ff       	call   80160f <dev_lookup>
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 49                	js     801a93 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a51:	75 23                	jne    801a76 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a53:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a58:	8b 40 48             	mov    0x48(%eax),%eax
  801a5b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a63:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801a6a:	e8 60 e7 ff ff       	call   8001cf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a74:	eb 1d                	jmp    801a93 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801a76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a79:	8b 52 18             	mov    0x18(%edx),%edx
  801a7c:	85 d2                	test   %edx,%edx
  801a7e:	74 0e                	je     801a8e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a83:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a87:	89 04 24             	mov    %eax,(%esp)
  801a8a:	ff d2                	call   *%edx
  801a8c:	eb 05                	jmp    801a93 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a8e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a93:	83 c4 24             	add    $0x24,%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 24             	sub    $0x24,%esp
  801aa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 09 fb ff ff       	call   8015be <fd_lookup>
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 52                	js     801b0b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac3:	8b 00                	mov    (%eax),%eax
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	e8 42 fb ff ff       	call   80160f <dev_lookup>
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 3a                	js     801b0b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ad8:	74 2c                	je     801b06 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ada:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801add:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801ae4:	00 00 00 
	stat->st_isdir = 0;
  801ae7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aee:	00 00 00 
	stat->st_dev = dev;
  801af1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801af7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801afb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801afe:	89 14 24             	mov    %edx,(%esp)
  801b01:	ff 50 14             	call   *0x14(%eax)
  801b04:	eb 05                	jmp    801b0b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b06:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b0b:	83 c4 24             	add    $0x24,%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 18             	sub    $0x18,%esp
  801b17:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b1a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b24:	00 
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	89 04 24             	mov    %eax,(%esp)
  801b2b:	e8 bc 01 00 00       	call   801cec <open>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 1b                	js     801b51 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3d:	89 1c 24             	mov    %ebx,(%esp)
  801b40:	e8 54 ff ff ff       	call   801a99 <fstat>
  801b45:	89 c6                	mov    %eax,%esi
	close(fd);
  801b47:	89 1c 24             	mov    %ebx,(%esp)
  801b4a:	e8 be fb ff ff       	call   80170d <close>
	return r;
  801b4f:	89 f3                	mov    %esi,%ebx
}
  801b51:	89 d8                	mov    %ebx,%eax
  801b53:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b56:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b59:	89 ec                	mov    %ebp,%esp
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    
  801b5d:	00 00                	add    %al,(%eax)
	...

00801b60 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 18             	sub    $0x18,%esp
  801b66:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b69:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b6c:	89 c3                	mov    %eax,%ebx
  801b6e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b70:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b77:	75 11                	jne    801b8a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b80:	e8 64 09 00 00       	call   8024e9 <ipc_find_env>
  801b85:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b8a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b91:	00 
  801b92:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b99:	00 
  801b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9e:	a1 00 40 80 00       	mov    0x804000,%eax
  801ba3:	89 04 24             	mov    %eax,(%esp)
  801ba6:	e8 d3 08 00 00       	call   80247e <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801bab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bb2:	00 
  801bb3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbe:	e8 55 08 00 00       	call   802418 <ipc_recv>
}
  801bc3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bc6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bc9:	89 ec                	mov    %ebp,%esp
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 14             	sub    $0x14,%esp
  801bd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	8b 40 0c             	mov    0xc(%eax),%eax
  801bdd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801be2:	ba 00 00 00 00       	mov    $0x0,%edx
  801be7:	b8 05 00 00 00       	mov    $0x5,%eax
  801bec:	e8 6f ff ff ff       	call   801b60 <fsipc>
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	78 2b                	js     801c20 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bf5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bfc:	00 
  801bfd:	89 1c 24             	mov    %ebx,(%esp)
  801c00:	e8 16 ed ff ff       	call   80091b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c05:	a1 80 50 80 00       	mov    0x805080,%eax
  801c0a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c10:	a1 84 50 80 00       	mov    0x805084,%eax
  801c15:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c20:	83 c4 14             	add    $0x14,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c32:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c37:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3c:	b8 06 00 00 00       	mov    $0x6,%eax
  801c41:	e8 1a ff ff ff       	call   801b60 <fsipc>
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 10             	sub    $0x10,%esp
  801c50:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	8b 40 0c             	mov    0xc(%eax),%eax
  801c59:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c5e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c64:	ba 00 00 00 00       	mov    $0x0,%edx
  801c69:	b8 03 00 00 00       	mov    $0x3,%eax
  801c6e:	e8 ed fe ff ff       	call   801b60 <fsipc>
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 6a                	js     801ce3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 24                	jae    801ca1 <devfile_read+0x59>
  801c7d:	c7 44 24 0c 28 2e 80 	movl   $0x802e28,0xc(%esp)
  801c84:	00 
  801c85:	c7 44 24 08 2f 2e 80 	movl   $0x802e2f,0x8(%esp)
  801c8c:	00 
  801c8d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801c94:	00 
  801c95:	c7 04 24 44 2e 80 00 	movl   $0x802e44,(%esp)
  801c9c:	e8 6f 06 00 00       	call   802310 <_panic>
	assert(r <= PGSIZE);
  801ca1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca6:	7e 24                	jle    801ccc <devfile_read+0x84>
  801ca8:	c7 44 24 0c 4f 2e 80 	movl   $0x802e4f,0xc(%esp)
  801caf:	00 
  801cb0:	c7 44 24 08 2f 2e 80 	movl   $0x802e2f,0x8(%esp)
  801cb7:	00 
  801cb8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801cbf:	00 
  801cc0:	c7 04 24 44 2e 80 00 	movl   $0x802e44,(%esp)
  801cc7:	e8 44 06 00 00       	call   802310 <_panic>
	memmove(buf, &fsipcbuf, r);
  801ccc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cd7:	00 
  801cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdb:	89 04 24             	mov    %eax,(%esp)
  801cde:	e8 29 ee ff ff       	call   800b0c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801ce3:	89 d8                	mov    %ebx,%eax
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	5b                   	pop    %ebx
  801ce9:	5e                   	pop    %esi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	56                   	push   %esi
  801cf0:	53                   	push   %ebx
  801cf1:	83 ec 20             	sub    $0x20,%esp
  801cf4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cf7:	89 34 24             	mov    %esi,(%esp)
  801cfa:	e8 d1 eb ff ff       	call   8008d0 <strlen>
		return -E_BAD_PATH;
  801cff:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d09:	7f 5e                	jg     801d69 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0e:	89 04 24             	mov    %eax,(%esp)
  801d11:	e8 35 f8 ff ff       	call   80154b <fd_alloc>
  801d16:	89 c3                	mov    %eax,%ebx
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	78 4d                	js     801d69 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d20:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d27:	e8 ef eb ff ff       	call   80091b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d37:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3c:	e8 1f fe ff ff       	call   801b60 <fsipc>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	85 c0                	test   %eax,%eax
  801d45:	79 15                	jns    801d5c <open+0x70>
		fd_close(fd, 0);
  801d47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d4e:	00 
  801d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d52:	89 04 24             	mov    %eax,(%esp)
  801d55:	e8 21 f9 ff ff       	call   80167b <fd_close>
		return r;
  801d5a:	eb 0d                	jmp    801d69 <open+0x7d>
	}

	return fd2num(fd);
  801d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5f:	89 04 24             	mov    %eax,(%esp)
  801d62:	e8 b9 f7 ff ff       	call   801520 <fd2num>
  801d67:	89 c3                	mov    %eax,%ebx
}
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	83 c4 20             	add    $0x20,%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5e                   	pop    %esi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
	...

00801d80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 18             	sub    $0x18,%esp
  801d86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d89:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d8c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	89 04 24             	mov    %eax,(%esp)
  801d95:	e8 96 f7 ff ff       	call   801530 <fd2data>
  801d9a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d9c:	c7 44 24 04 5b 2e 80 	movl   $0x802e5b,0x4(%esp)
  801da3:	00 
  801da4:	89 34 24             	mov    %esi,(%esp)
  801da7:	e8 6f eb ff ff       	call   80091b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dac:	8b 43 04             	mov    0x4(%ebx),%eax
  801daf:	2b 03                	sub    (%ebx),%eax
  801db1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801db7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801dbe:	00 00 00 
	stat->st_dev = &devpipe;
  801dc1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801dc8:	30 80 00 
	return 0;
}
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dd3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801dd6:	89 ec                	mov    %ebp,%esp
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    

00801dda <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 14             	sub    $0x14,%esp
  801de1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801de4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801de8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801def:	e8 e5 f0 ff ff       	call   800ed9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801df4:	89 1c 24             	mov    %ebx,(%esp)
  801df7:	e8 34 f7 ff ff       	call   801530 <fd2data>
  801dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e07:	e8 cd f0 ff ff       	call   800ed9 <sys_page_unmap>
}
  801e0c:	83 c4 14             	add    $0x14,%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	83 ec 2c             	sub    $0x2c,%esp
  801e1b:	89 c7                	mov    %eax,%edi
  801e1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e20:	a1 04 40 80 00       	mov    0x804004,%eax
  801e25:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e28:	89 3c 24             	mov    %edi,(%esp)
  801e2b:	e8 04 07 00 00       	call   802534 <pageref>
  801e30:	89 c6                	mov    %eax,%esi
  801e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e35:	89 04 24             	mov    %eax,(%esp)
  801e38:	e8 f7 06 00 00       	call   802534 <pageref>
  801e3d:	39 c6                	cmp    %eax,%esi
  801e3f:	0f 94 c0             	sete   %al
  801e42:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e45:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e4b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e4e:	39 cb                	cmp    %ecx,%ebx
  801e50:	75 08                	jne    801e5a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e52:	83 c4 2c             	add    $0x2c,%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5f                   	pop    %edi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e5a:	83 f8 01             	cmp    $0x1,%eax
  801e5d:	75 c1                	jne    801e20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e5f:	8b 52 58             	mov    0x58(%edx),%edx
  801e62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e66:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e6e:	c7 04 24 62 2e 80 00 	movl   $0x802e62,(%esp)
  801e75:	e8 55 e3 ff ff       	call   8001cf <cprintf>
  801e7a:	eb a4                	jmp    801e20 <_pipeisclosed+0xe>

00801e7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	57                   	push   %edi
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
  801e82:	83 ec 2c             	sub    $0x2c,%esp
  801e85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e88:	89 34 24             	mov    %esi,(%esp)
  801e8b:	e8 a0 f6 ff ff       	call   801530 <fd2data>
  801e90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e92:	bf 00 00 00 00       	mov    $0x0,%edi
  801e97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e9b:	75 50                	jne    801eed <devpipe_write+0x71>
  801e9d:	eb 5c                	jmp    801efb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e9f:	89 da                	mov    %ebx,%edx
  801ea1:	89 f0                	mov    %esi,%eax
  801ea3:	e8 6a ff ff ff       	call   801e12 <_pipeisclosed>
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	75 53                	jne    801eff <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eac:	e8 3b ef ff ff       	call   800dec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eb1:	8b 43 04             	mov    0x4(%ebx),%eax
  801eb4:	8b 13                	mov    (%ebx),%edx
  801eb6:	83 c2 20             	add    $0x20,%edx
  801eb9:	39 d0                	cmp    %edx,%eax
  801ebb:	73 e2                	jae    801e9f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ebd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801ec4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801ec7:	89 c2                	mov    %eax,%edx
  801ec9:	c1 fa 1f             	sar    $0x1f,%edx
  801ecc:	c1 ea 1b             	shr    $0x1b,%edx
  801ecf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801ed2:	83 e1 1f             	and    $0x1f,%ecx
  801ed5:	29 d1                	sub    %edx,%ecx
  801ed7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801edb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801edf:	83 c0 01             	add    $0x1,%eax
  801ee2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee5:	83 c7 01             	add    $0x1,%edi
  801ee8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eeb:	74 0e                	je     801efb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eed:	8b 43 04             	mov    0x4(%ebx),%eax
  801ef0:	8b 13                	mov    (%ebx),%edx
  801ef2:	83 c2 20             	add    $0x20,%edx
  801ef5:	39 d0                	cmp    %edx,%eax
  801ef7:	73 a6                	jae    801e9f <devpipe_write+0x23>
  801ef9:	eb c2                	jmp    801ebd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801efb:	89 f8                	mov    %edi,%eax
  801efd:	eb 05                	jmp    801f04 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f04:	83 c4 2c             	add    $0x2c,%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5f                   	pop    %edi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	83 ec 28             	sub    $0x28,%esp
  801f12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f18:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f1e:	89 3c 24             	mov    %edi,(%esp)
  801f21:	e8 0a f6 ff ff       	call   801530 <fd2data>
  801f26:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f28:	be 00 00 00 00       	mov    $0x0,%esi
  801f2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f31:	75 47                	jne    801f7a <devpipe_read+0x6e>
  801f33:	eb 52                	jmp    801f87 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801f35:	89 f0                	mov    %esi,%eax
  801f37:	eb 5e                	jmp    801f97 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f39:	89 da                	mov    %ebx,%edx
  801f3b:	89 f8                	mov    %edi,%eax
  801f3d:	8d 76 00             	lea    0x0(%esi),%esi
  801f40:	e8 cd fe ff ff       	call   801e12 <_pipeisclosed>
  801f45:	85 c0                	test   %eax,%eax
  801f47:	75 49                	jne    801f92 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801f49:	e8 9e ee ff ff       	call   800dec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f4e:	8b 03                	mov    (%ebx),%eax
  801f50:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f53:	74 e4                	je     801f39 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f55:	89 c2                	mov    %eax,%edx
  801f57:	c1 fa 1f             	sar    $0x1f,%edx
  801f5a:	c1 ea 1b             	shr    $0x1b,%edx
  801f5d:	01 d0                	add    %edx,%eax
  801f5f:	83 e0 1f             	and    $0x1f,%eax
  801f62:	29 d0                	sub    %edx,%eax
  801f64:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f6f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f72:	83 c6 01             	add    $0x1,%esi
  801f75:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f78:	74 0d                	je     801f87 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801f7a:	8b 03                	mov    (%ebx),%eax
  801f7c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f7f:	75 d4                	jne    801f55 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f81:	85 f6                	test   %esi,%esi
  801f83:	75 b0                	jne    801f35 <devpipe_read+0x29>
  801f85:	eb b2                	jmp    801f39 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f87:	89 f0                	mov    %esi,%eax
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	eb 05                	jmp    801f97 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fa0:	89 ec                	mov    %ebp,%esp
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    

00801fa4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	83 ec 48             	sub    $0x48,%esp
  801faa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fb0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801fb3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fb9:	89 04 24             	mov    %eax,(%esp)
  801fbc:	e8 8a f5 ff ff       	call   80154b <fd_alloc>
  801fc1:	89 c3                	mov    %eax,%ebx
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	0f 88 45 01 00 00    	js     802110 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fcb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fd2:	00 
  801fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe1:	e8 36 ee ff ff       	call   800e1c <sys_page_alloc>
  801fe6:	89 c3                	mov    %eax,%ebx
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	0f 88 20 01 00 00    	js     802110 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ff0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ff3:	89 04 24             	mov    %eax,(%esp)
  801ff6:	e8 50 f5 ff ff       	call   80154b <fd_alloc>
  801ffb:	89 c3                	mov    %eax,%ebx
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	0f 88 f8 00 00 00    	js     8020fd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802005:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80200c:	00 
  80200d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802010:	89 44 24 04          	mov    %eax,0x4(%esp)
  802014:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201b:	e8 fc ed ff ff       	call   800e1c <sys_page_alloc>
  802020:	89 c3                	mov    %eax,%ebx
  802022:	85 c0                	test   %eax,%eax
  802024:	0f 88 d3 00 00 00    	js     8020fd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80202a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80202d:	89 04 24             	mov    %eax,(%esp)
  802030:	e8 fb f4 ff ff       	call   801530 <fd2data>
  802035:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802037:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80203e:	00 
  80203f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802043:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204a:	e8 cd ed ff ff       	call   800e1c <sys_page_alloc>
  80204f:	89 c3                	mov    %eax,%ebx
  802051:	85 c0                	test   %eax,%eax
  802053:	0f 88 91 00 00 00    	js     8020ea <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802059:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80205c:	89 04 24             	mov    %eax,(%esp)
  80205f:	e8 cc f4 ff ff       	call   801530 <fd2data>
  802064:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80206b:	00 
  80206c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802070:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802077:	00 
  802078:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802083:	e8 f3 ed ff ff       	call   800e7b <sys_page_map>
  802088:	89 c3                	mov    %eax,%ebx
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 4c                	js     8020da <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80208e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802094:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802097:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802099:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80209c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020a3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8020a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020ac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020bb:	89 04 24             	mov    %eax,(%esp)
  8020be:	e8 5d f4 ff ff       	call   801520 <fd2num>
  8020c3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020c8:	89 04 24             	mov    %eax,(%esp)
  8020cb:	e8 50 f4 ff ff       	call   801520 <fd2num>
  8020d0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d8:	eb 36                	jmp    802110 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8020da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e5:	e8 ef ed ff ff       	call   800ed9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f8:	e8 dc ed ff ff       	call   800ed9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802100:	89 44 24 04          	mov    %eax,0x4(%esp)
  802104:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210b:	e8 c9 ed ff ff       	call   800ed9 <sys_page_unmap>
    err:
	return r;
}
  802110:	89 d8                	mov    %ebx,%eax
  802112:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802115:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802118:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80211b:	89 ec                	mov    %ebp,%esp
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    

0080211f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802125:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212c:	8b 45 08             	mov    0x8(%ebp),%eax
  80212f:	89 04 24             	mov    %eax,(%esp)
  802132:	e8 87 f4 ff ff       	call   8015be <fd_lookup>
  802137:	85 c0                	test   %eax,%eax
  802139:	78 15                	js     802150 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80213b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213e:	89 04 24             	mov    %eax,(%esp)
  802141:	e8 ea f3 ff ff       	call   801530 <fd2data>
	return _pipeisclosed(fd, p);
  802146:	89 c2                	mov    %eax,%edx
  802148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214b:	e8 c2 fc ff ff       	call   801e12 <_pipeisclosed>
}
  802150:	c9                   	leave  
  802151:	c3                   	ret    
	...

00802160 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802170:	c7 44 24 04 7a 2e 80 	movl   $0x802e7a,0x4(%esp)
  802177:	00 
  802178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217b:	89 04 24             	mov    %eax,(%esp)
  80217e:	e8 98 e7 ff ff       	call   80091b <strcpy>
	return 0;
}
  802183:	b8 00 00 00 00       	mov    $0x0,%eax
  802188:	c9                   	leave  
  802189:	c3                   	ret    

0080218a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80218a:	55                   	push   %ebp
  80218b:	89 e5                	mov    %esp,%ebp
  80218d:	57                   	push   %edi
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
  802190:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802196:	be 00 00 00 00       	mov    $0x0,%esi
  80219b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80219f:	74 43                	je     8021e4 <devcons_write+0x5a>
  8021a1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021a6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021af:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8021b1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021b4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021b9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c0:	03 45 0c             	add    0xc(%ebp),%eax
  8021c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c7:	89 3c 24             	mov    %edi,(%esp)
  8021ca:	e8 3d e9 ff ff       	call   800b0c <memmove>
		sys_cputs(buf, m);
  8021cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	e8 25 eb ff ff       	call   800d00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021db:	01 de                	add    %ebx,%esi
  8021dd:	89 f0                	mov    %esi,%eax
  8021df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021e2:	72 c8                	jb     8021ac <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021e4:	89 f0                	mov    %esi,%eax
  8021e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021ec:	5b                   	pop    %ebx
  8021ed:	5e                   	pop    %esi
  8021ee:	5f                   	pop    %edi
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    

008021f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8021f7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8021fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802200:	75 07                	jne    802209 <devcons_read+0x18>
  802202:	eb 31                	jmp    802235 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802204:	e8 e3 eb ff ff       	call   800dec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	e8 1a eb ff ff       	call   800d2f <sys_cgetc>
  802215:	85 c0                	test   %eax,%eax
  802217:	74 eb                	je     802204 <devcons_read+0x13>
  802219:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80221b:	85 c0                	test   %eax,%eax
  80221d:	78 16                	js     802235 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80221f:	83 f8 04             	cmp    $0x4,%eax
  802222:	74 0c                	je     802230 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802224:	8b 45 0c             	mov    0xc(%ebp),%eax
  802227:	88 10                	mov    %dl,(%eax)
	return 1;
  802229:	b8 01 00 00 00       	mov    $0x1,%eax
  80222e:	eb 05                	jmp    802235 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802230:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802235:	c9                   	leave  
  802236:	c3                   	ret    

00802237 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80223d:	8b 45 08             	mov    0x8(%ebp),%eax
  802240:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802243:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80224a:	00 
  80224b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80224e:	89 04 24             	mov    %eax,(%esp)
  802251:	e8 aa ea ff ff       	call   800d00 <sys_cputs>
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <getchar>:

int
getchar(void)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80225e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802265:	00 
  802266:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802274:	e8 05 f6 ff ff       	call   80187e <read>
	if (r < 0)
  802279:	85 c0                	test   %eax,%eax
  80227b:	78 0f                	js     80228c <getchar+0x34>
		return r;
	if (r < 1)
  80227d:	85 c0                	test   %eax,%eax
  80227f:	7e 06                	jle    802287 <getchar+0x2f>
		return -E_EOF;
	return c;
  802281:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802285:	eb 05                	jmp    80228c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802287:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80228c:	c9                   	leave  
  80228d:	c3                   	ret    

0080228e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802294:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229b:	8b 45 08             	mov    0x8(%ebp),%eax
  80229e:	89 04 24             	mov    %eax,(%esp)
  8022a1:	e8 18 f3 ff ff       	call   8015be <fd_lookup>
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	78 11                	js     8022bb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ad:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8022b3:	39 10                	cmp    %edx,(%eax)
  8022b5:	0f 94 c0             	sete   %al
  8022b8:	0f b6 c0             	movzbl %al,%eax
}
  8022bb:	c9                   	leave  
  8022bc:	c3                   	ret    

008022bd <opencons>:

int
opencons(void)
{
  8022bd:	55                   	push   %ebp
  8022be:	89 e5                	mov    %esp,%ebp
  8022c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c6:	89 04 24             	mov    %eax,(%esp)
  8022c9:	e8 7d f2 ff ff       	call   80154b <fd_alloc>
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	78 3c                	js     80230e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022d9:	00 
  8022da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e8:	e8 2f eb ff ff       	call   800e1c <sys_page_alloc>
  8022ed:	85 c0                	test   %eax,%eax
  8022ef:	78 1d                	js     80230e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022f1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8022f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802306:	89 04 24             	mov    %eax,(%esp)
  802309:	e8 12 f2 ff ff       	call   801520 <fd2num>
}
  80230e:	c9                   	leave  
  80230f:	c3                   	ret    

00802310 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	56                   	push   %esi
  802314:	53                   	push   %ebx
  802315:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802318:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80231b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802321:	e8 96 ea ff ff       	call   800dbc <sys_getenvid>
  802326:	8b 55 0c             	mov    0xc(%ebp),%edx
  802329:	89 54 24 10          	mov    %edx,0x10(%esp)
  80232d:	8b 55 08             	mov    0x8(%ebp),%edx
  802330:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802334:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	c7 04 24 88 2e 80 00 	movl   $0x802e88,(%esp)
  802343:	e8 87 de ff ff       	call   8001cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802348:	89 74 24 04          	mov    %esi,0x4(%esp)
  80234c:	8b 45 10             	mov    0x10(%ebp),%eax
  80234f:	89 04 24             	mov    %eax,(%esp)
  802352:	e8 17 de ff ff       	call   80016e <vcprintf>
	cprintf("\n");
  802357:	c7 04 24 1f 2c 80 00 	movl   $0x802c1f,(%esp)
  80235e:	e8 6c de ff ff       	call   8001cf <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802363:	cc                   	int3   
  802364:	eb fd                	jmp    802363 <_panic+0x53>
	...

00802368 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80236e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802375:	75 3c                	jne    8023b3 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802377:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80237e:	00 
  80237f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802386:	ee 
  802387:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80238e:	e8 89 ea ff ff       	call   800e1c <sys_page_alloc>
  802393:	85 c0                	test   %eax,%eax
  802395:	79 1c                	jns    8023b3 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  802397:	c7 44 24 08 ac 2e 80 	movl   $0x802eac,0x8(%esp)
  80239e:	00 
  80239f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8023a6:	00 
  8023a7:	c7 04 24 10 2f 80 00 	movl   $0x802f10,(%esp)
  8023ae:	e8 5d ff ff ff       	call   802310 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b6:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8023bb:	c7 44 24 04 f4 23 80 	movl   $0x8023f4,0x4(%esp)
  8023c2:	00 
  8023c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ca:	e8 24 ec ff ff       	call   800ff3 <sys_env_set_pgfault_upcall>
  8023cf:	85 c0                	test   %eax,%eax
  8023d1:	79 1c                	jns    8023ef <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8023d3:	c7 44 24 08 d8 2e 80 	movl   $0x802ed8,0x8(%esp)
  8023da:	00 
  8023db:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8023e2:	00 
  8023e3:	c7 04 24 10 2f 80 00 	movl   $0x802f10,(%esp)
  8023ea:	e8 21 ff ff ff       	call   802310 <_panic>
}
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    
  8023f1:	00 00                	add    %al,(%eax)
	...

008023f4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023f4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023f5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8023fa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023fc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  8023ff:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  802403:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802408:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80240c:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80240e:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802411:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  802412:	83 c4 04             	add    $0x4,%esp
    popfl
  802415:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  802416:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  802417:	c3                   	ret    

00802418 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	56                   	push   %esi
  80241c:	53                   	push   %ebx
  80241d:	83 ec 10             	sub    $0x10,%esp
  802420:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802423:	8b 45 0c             	mov    0xc(%ebp),%eax
  802426:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802429:	85 db                	test   %ebx,%ebx
  80242b:	74 06                	je     802433 <ipc_recv+0x1b>
  80242d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  802433:	85 f6                	test   %esi,%esi
  802435:	74 06                	je     80243d <ipc_recv+0x25>
  802437:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  80243d:	85 c0                	test   %eax,%eax
  80243f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802444:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  802447:	89 04 24             	mov    %eax,(%esp)
  80244a:	e8 36 ec ff ff       	call   801085 <sys_ipc_recv>
    if (ret) return ret;
  80244f:	85 c0                	test   %eax,%eax
  802451:	75 24                	jne    802477 <ipc_recv+0x5f>
    if (from_env_store)
  802453:	85 db                	test   %ebx,%ebx
  802455:	74 0a                	je     802461 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  802457:	a1 04 40 80 00       	mov    0x804004,%eax
  80245c:	8b 40 74             	mov    0x74(%eax),%eax
  80245f:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802461:	85 f6                	test   %esi,%esi
  802463:	74 0a                	je     80246f <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  802465:	a1 04 40 80 00       	mov    0x804004,%eax
  80246a:	8b 40 78             	mov    0x78(%eax),%eax
  80246d:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  80246f:	a1 04 40 80 00       	mov    0x804004,%eax
  802474:	8b 40 70             	mov    0x70(%eax),%eax
}
  802477:	83 c4 10             	add    $0x10,%esp
  80247a:	5b                   	pop    %ebx
  80247b:	5e                   	pop    %esi
  80247c:	5d                   	pop    %ebp
  80247d:	c3                   	ret    

0080247e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	53                   	push   %ebx
  802484:	83 ec 1c             	sub    $0x1c,%esp
  802487:	8b 75 08             	mov    0x8(%ebp),%esi
  80248a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80248d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802490:	85 db                	test   %ebx,%ebx
  802492:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802497:	0f 44 d8             	cmove  %eax,%ebx
  80249a:	eb 2a                	jmp    8024c6 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80249c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80249f:	74 20                	je     8024c1 <ipc_send+0x43>
  8024a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024a5:	c7 44 24 08 1e 2f 80 	movl   $0x802f1e,0x8(%esp)
  8024ac:	00 
  8024ad:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8024b4:	00 
  8024b5:	c7 04 24 35 2f 80 00 	movl   $0x802f35,(%esp)
  8024bc:	e8 4f fe ff ff       	call   802310 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8024c1:	e8 26 e9 ff ff       	call   800dec <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8024c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8024c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024d5:	89 34 24             	mov    %esi,(%esp)
  8024d8:	e8 74 eb ff ff       	call   801051 <sys_ipc_try_send>
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	75 bb                	jne    80249c <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8024e1:	83 c4 1c             	add    $0x1c,%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    

008024e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8024ef:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8024f4:	39 c8                	cmp    %ecx,%eax
  8024f6:	74 19                	je     802511 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024f8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8024fd:	89 c2                	mov    %eax,%edx
  8024ff:	c1 e2 07             	shl    $0x7,%edx
  802502:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802508:	8b 52 50             	mov    0x50(%edx),%edx
  80250b:	39 ca                	cmp    %ecx,%edx
  80250d:	75 14                	jne    802523 <ipc_find_env+0x3a>
  80250f:	eb 05                	jmp    802516 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802511:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802516:	c1 e0 07             	shl    $0x7,%eax
  802519:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80251e:	8b 40 40             	mov    0x40(%eax),%eax
  802521:	eb 0e                	jmp    802531 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802523:	83 c0 01             	add    $0x1,%eax
  802526:	3d 00 04 00 00       	cmp    $0x400,%eax
  80252b:	75 d0                	jne    8024fd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80252d:	66 b8 00 00          	mov    $0x0,%ax
}
  802531:	5d                   	pop    %ebp
  802532:	c3                   	ret    
	...

00802534 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802534:	55                   	push   %ebp
  802535:	89 e5                	mov    %esp,%ebp
  802537:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80253a:	89 d0                	mov    %edx,%eax
  80253c:	c1 e8 16             	shr    $0x16,%eax
  80253f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802546:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80254b:	f6 c1 01             	test   $0x1,%cl
  80254e:	74 1d                	je     80256d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802550:	c1 ea 0c             	shr    $0xc,%edx
  802553:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80255a:	f6 c2 01             	test   $0x1,%dl
  80255d:	74 0e                	je     80256d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80255f:	c1 ea 0c             	shr    $0xc,%edx
  802562:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802569:	ef 
  80256a:	0f b7 c0             	movzwl %ax,%eax
}
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    
	...

00802570 <__udivdi3>:
  802570:	83 ec 1c             	sub    $0x1c,%esp
  802573:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802577:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80257b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80257f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802583:	89 74 24 10          	mov    %esi,0x10(%esp)
  802587:	8b 74 24 24          	mov    0x24(%esp),%esi
  80258b:	85 ff                	test   %edi,%edi
  80258d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802591:	89 44 24 08          	mov    %eax,0x8(%esp)
  802595:	89 cd                	mov    %ecx,%ebp
  802597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80259b:	75 33                	jne    8025d0 <__udivdi3+0x60>
  80259d:	39 f1                	cmp    %esi,%ecx
  80259f:	77 57                	ja     8025f8 <__udivdi3+0x88>
  8025a1:	85 c9                	test   %ecx,%ecx
  8025a3:	75 0b                	jne    8025b0 <__udivdi3+0x40>
  8025a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8025aa:	31 d2                	xor    %edx,%edx
  8025ac:	f7 f1                	div    %ecx
  8025ae:	89 c1                	mov    %eax,%ecx
  8025b0:	89 f0                	mov    %esi,%eax
  8025b2:	31 d2                	xor    %edx,%edx
  8025b4:	f7 f1                	div    %ecx
  8025b6:	89 c6                	mov    %eax,%esi
  8025b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025bc:	f7 f1                	div    %ecx
  8025be:	89 f2                	mov    %esi,%edx
  8025c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8025c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8025c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8025cc:	83 c4 1c             	add    $0x1c,%esp
  8025cf:	c3                   	ret    
  8025d0:	31 d2                	xor    %edx,%edx
  8025d2:	31 c0                	xor    %eax,%eax
  8025d4:	39 f7                	cmp    %esi,%edi
  8025d6:	77 e8                	ja     8025c0 <__udivdi3+0x50>
  8025d8:	0f bd cf             	bsr    %edi,%ecx
  8025db:	83 f1 1f             	xor    $0x1f,%ecx
  8025de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025e2:	75 2c                	jne    802610 <__udivdi3+0xa0>
  8025e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8025e8:	76 04                	jbe    8025ee <__udivdi3+0x7e>
  8025ea:	39 f7                	cmp    %esi,%edi
  8025ec:	73 d2                	jae    8025c0 <__udivdi3+0x50>
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025f5:	eb c9                	jmp    8025c0 <__udivdi3+0x50>
  8025f7:	90                   	nop
  8025f8:	89 f2                	mov    %esi,%edx
  8025fa:	f7 f1                	div    %ecx
  8025fc:	31 d2                	xor    %edx,%edx
  8025fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  802602:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802606:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80260a:	83 c4 1c             	add    $0x1c,%esp
  80260d:	c3                   	ret    
  80260e:	66 90                	xchg   %ax,%ax
  802610:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802615:	b8 20 00 00 00       	mov    $0x20,%eax
  80261a:	89 ea                	mov    %ebp,%edx
  80261c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802620:	d3 e7                	shl    %cl,%edi
  802622:	89 c1                	mov    %eax,%ecx
  802624:	d3 ea                	shr    %cl,%edx
  802626:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80262b:	09 fa                	or     %edi,%edx
  80262d:	89 f7                	mov    %esi,%edi
  80262f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802633:	89 f2                	mov    %esi,%edx
  802635:	8b 74 24 08          	mov    0x8(%esp),%esi
  802639:	d3 e5                	shl    %cl,%ebp
  80263b:	89 c1                	mov    %eax,%ecx
  80263d:	d3 ef                	shr    %cl,%edi
  80263f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802644:	d3 e2                	shl    %cl,%edx
  802646:	89 c1                	mov    %eax,%ecx
  802648:	d3 ee                	shr    %cl,%esi
  80264a:	09 d6                	or     %edx,%esi
  80264c:	89 fa                	mov    %edi,%edx
  80264e:	89 f0                	mov    %esi,%eax
  802650:	f7 74 24 0c          	divl   0xc(%esp)
  802654:	89 d7                	mov    %edx,%edi
  802656:	89 c6                	mov    %eax,%esi
  802658:	f7 e5                	mul    %ebp
  80265a:	39 d7                	cmp    %edx,%edi
  80265c:	72 22                	jb     802680 <__udivdi3+0x110>
  80265e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802662:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802667:	d3 e5                	shl    %cl,%ebp
  802669:	39 c5                	cmp    %eax,%ebp
  80266b:	73 04                	jae    802671 <__udivdi3+0x101>
  80266d:	39 d7                	cmp    %edx,%edi
  80266f:	74 0f                	je     802680 <__udivdi3+0x110>
  802671:	89 f0                	mov    %esi,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	e9 46 ff ff ff       	jmp    8025c0 <__udivdi3+0x50>
  80267a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802680:	8d 46 ff             	lea    -0x1(%esi),%eax
  802683:	31 d2                	xor    %edx,%edx
  802685:	8b 74 24 10          	mov    0x10(%esp),%esi
  802689:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80268d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802691:	83 c4 1c             	add    $0x1c,%esp
  802694:	c3                   	ret    
	...

008026a0 <__umoddi3>:
  8026a0:	83 ec 1c             	sub    $0x1c,%esp
  8026a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8026a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8026ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8026af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8026b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8026b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8026bb:	85 ed                	test   %ebp,%ebp
  8026bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8026c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026c5:	89 cf                	mov    %ecx,%edi
  8026c7:	89 04 24             	mov    %eax,(%esp)
  8026ca:	89 f2                	mov    %esi,%edx
  8026cc:	75 1a                	jne    8026e8 <__umoddi3+0x48>
  8026ce:	39 f1                	cmp    %esi,%ecx
  8026d0:	76 4e                	jbe    802720 <__umoddi3+0x80>
  8026d2:	f7 f1                	div    %ecx
  8026d4:	89 d0                	mov    %edx,%eax
  8026d6:	31 d2                	xor    %edx,%edx
  8026d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8026e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8026e4:	83 c4 1c             	add    $0x1c,%esp
  8026e7:	c3                   	ret    
  8026e8:	39 f5                	cmp    %esi,%ebp
  8026ea:	77 54                	ja     802740 <__umoddi3+0xa0>
  8026ec:	0f bd c5             	bsr    %ebp,%eax
  8026ef:	83 f0 1f             	xor    $0x1f,%eax
  8026f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026f6:	75 60                	jne    802758 <__umoddi3+0xb8>
  8026f8:	3b 0c 24             	cmp    (%esp),%ecx
  8026fb:	0f 87 07 01 00 00    	ja     802808 <__umoddi3+0x168>
  802701:	89 f2                	mov    %esi,%edx
  802703:	8b 34 24             	mov    (%esp),%esi
  802706:	29 ce                	sub    %ecx,%esi
  802708:	19 ea                	sbb    %ebp,%edx
  80270a:	89 34 24             	mov    %esi,(%esp)
  80270d:	8b 04 24             	mov    (%esp),%eax
  802710:	8b 74 24 10          	mov    0x10(%esp),%esi
  802714:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802718:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80271c:	83 c4 1c             	add    $0x1c,%esp
  80271f:	c3                   	ret    
  802720:	85 c9                	test   %ecx,%ecx
  802722:	75 0b                	jne    80272f <__umoddi3+0x8f>
  802724:	b8 01 00 00 00       	mov    $0x1,%eax
  802729:	31 d2                	xor    %edx,%edx
  80272b:	f7 f1                	div    %ecx
  80272d:	89 c1                	mov    %eax,%ecx
  80272f:	89 f0                	mov    %esi,%eax
  802731:	31 d2                	xor    %edx,%edx
  802733:	f7 f1                	div    %ecx
  802735:	8b 04 24             	mov    (%esp),%eax
  802738:	f7 f1                	div    %ecx
  80273a:	eb 98                	jmp    8026d4 <__umoddi3+0x34>
  80273c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 f2                	mov    %esi,%edx
  802742:	8b 74 24 10          	mov    0x10(%esp),%esi
  802746:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80274a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80274e:	83 c4 1c             	add    $0x1c,%esp
  802751:	c3                   	ret    
  802752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802758:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80275d:	89 e8                	mov    %ebp,%eax
  80275f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802764:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802768:	89 fa                	mov    %edi,%edx
  80276a:	d3 e0                	shl    %cl,%eax
  80276c:	89 e9                	mov    %ebp,%ecx
  80276e:	d3 ea                	shr    %cl,%edx
  802770:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802775:	09 c2                	or     %eax,%edx
  802777:	8b 44 24 08          	mov    0x8(%esp),%eax
  80277b:	89 14 24             	mov    %edx,(%esp)
  80277e:	89 f2                	mov    %esi,%edx
  802780:	d3 e7                	shl    %cl,%edi
  802782:	89 e9                	mov    %ebp,%ecx
  802784:	d3 ea                	shr    %cl,%edx
  802786:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80278b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80278f:	d3 e6                	shl    %cl,%esi
  802791:	89 e9                	mov    %ebp,%ecx
  802793:	d3 e8                	shr    %cl,%eax
  802795:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80279a:	09 f0                	or     %esi,%eax
  80279c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027a0:	f7 34 24             	divl   (%esp)
  8027a3:	d3 e6                	shl    %cl,%esi
  8027a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027a9:	89 d6                	mov    %edx,%esi
  8027ab:	f7 e7                	mul    %edi
  8027ad:	39 d6                	cmp    %edx,%esi
  8027af:	89 c1                	mov    %eax,%ecx
  8027b1:	89 d7                	mov    %edx,%edi
  8027b3:	72 3f                	jb     8027f4 <__umoddi3+0x154>
  8027b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027b9:	72 35                	jb     8027f0 <__umoddi3+0x150>
  8027bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027bf:	29 c8                	sub    %ecx,%eax
  8027c1:	19 fe                	sbb    %edi,%esi
  8027c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027c8:	89 f2                	mov    %esi,%edx
  8027ca:	d3 e8                	shr    %cl,%eax
  8027cc:	89 e9                	mov    %ebp,%ecx
  8027ce:	d3 e2                	shl    %cl,%edx
  8027d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027d5:	09 d0                	or     %edx,%eax
  8027d7:	89 f2                	mov    %esi,%edx
  8027d9:	d3 ea                	shr    %cl,%edx
  8027db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027e7:	83 c4 1c             	add    $0x1c,%esp
  8027ea:	c3                   	ret    
  8027eb:	90                   	nop
  8027ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f0:	39 d6                	cmp    %edx,%esi
  8027f2:	75 c7                	jne    8027bb <__umoddi3+0x11b>
  8027f4:	89 d7                	mov    %edx,%edi
  8027f6:	89 c1                	mov    %eax,%ecx
  8027f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8027fc:	1b 3c 24             	sbb    (%esp),%edi
  8027ff:	eb ba                	jmp    8027bb <__umoddi3+0x11b>
  802801:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802808:	39 f5                	cmp    %esi,%ebp
  80280a:	0f 82 f1 fe ff ff    	jb     802701 <__umoddi3+0x61>
  802810:	e9 f8 fe ff ff       	jmp    80270d <__umoddi3+0x6d>
