
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 7b 0d 00 00       	call   800dbc <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 08 20 80 00 7c 	cmpl   $0xeec0007c,0x802008
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 1a 10 00 00       	call   801084 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 c0 14 80 00 	movl   $0x8014c0,(%esp)
  80007c:	e8 4a 01 00 00       	call   8001cb <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 d1 14 80 00 	movl   $0x8014d1,(%esp)
  800097:	e8 2f 01 00 00       	call   8001cb <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 29 10 00 00       	call   8010ea <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
  8000ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d6:	e8 e1 0c 00 00       	call   800dbc <sys_getenvid>
  8000db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x34>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fc:	89 34 24             	mov    %esi,(%esp)
  8000ff:	e8 30 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800104:	e8 0b 00 00 00       	call   800114 <exit>
}
  800109:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80010c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 39 0c 00 00       	call   800d5f <sys_env_destroy>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 14             	sub    $0x14,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013b:	83 c0 01             	add    $0x1,%eax
  80013e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	75 19                	jne    800160 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800147:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014e:	00 
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	89 04 24             	mov    %eax,(%esp)
  800155:	e8 a6 0b 00 00       	call   800d00 <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800160:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800164:	83 c4 14             	add    $0x14,%esp
  800167:	5b                   	pop    %ebx
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800173:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017a:	00 00 00 
	b.cnt = 0;
  80017d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800184:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 44 24 08          	mov    %eax,0x8(%esp)
  800195:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019f:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  8001a6:	e8 97 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ab:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bb:	89 04 24             	mov    %eax,(%esp)
  8001be:	e8 3d 0b 00 00       	call   800d00 <sys_cputs>

	return b.cnt;
}
  8001c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 87 ff ff ff       	call   80016a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    
  8001e5:	00 00                	add    %al,(%eax)
	...

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 3c             	sub    $0x3c,%esp
  8001f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f4:	89 d7                	mov    %edx,%edi
  8001f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800202:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800205:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800208:	b8 00 00 00 00       	mov    $0x0,%eax
  80020d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800210:	72 11                	jb     800223 <printnum+0x3b>
  800212:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800215:	39 45 10             	cmp    %eax,0x10(%ebp)
  800218:	76 09                	jbe    800223 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021a:	83 eb 01             	sub    $0x1,%ebx
  80021d:	85 db                	test   %ebx,%ebx
  80021f:	7f 51                	jg     800272 <printnum+0x8a>
  800221:	eb 5e                	jmp    800281 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800223:	89 74 24 10          	mov    %esi,0x10(%esp)
  800227:	83 eb 01             	sub    $0x1,%ebx
  80022a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80022e:	8b 45 10             	mov    0x10(%ebp),%eax
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800239:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80023d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800244:	00 
  800245:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	e8 a9 0f 00 00       	call   801200 <__udivdi3>
  800257:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80025b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	89 54 24 04          	mov    %edx,0x4(%esp)
  800266:	89 fa                	mov    %edi,%edx
  800268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026b:	e8 78 ff ff ff       	call   8001e8 <printnum>
  800270:	eb 0f                	jmp    800281 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800272:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800276:	89 34 24             	mov    %esi,(%esp)
  800279:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027c:	83 eb 01             	sub    $0x1,%ebx
  80027f:	75 f1                	jne    800272 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800285:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800289:	8b 45 10             	mov    0x10(%ebp),%eax
  80028c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800290:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800297:	00 
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a5:	e8 86 10 00 00       	call   801330 <__umoddi3>
  8002aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ae:	0f be 80 f2 14 80 00 	movsbl 0x8014f2(%eax),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002bb:	83 c4 3c             	add    $0x3c,%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800311:	88 0a                	mov    %cl,(%edx)
  800313:	83 c2 01             	add    $0x1,%edx
  800316:	89 10                	mov    %edx,(%eax)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800327:	8b 45 10             	mov    0x10(%ebp),%eax
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 02 00 00 00       	call   800342 <vprintfmt>
	va_end(ap);
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
  800348:	83 ec 5c             	sub    $0x5c,%esp
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034e:	8b 75 10             	mov    0x10(%ebp),%esi
  800351:	eb 12                	jmp    800365 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 84 e4 04 00 00    	je     80083f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80035b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800365:	0f b6 06             	movzbl (%esi),%eax
  800368:	83 c6 01             	add    $0x1,%esi
  80036b:	83 f8 25             	cmp    $0x25,%eax
  80036e:	75 e3                	jne    800353 <vprintfmt+0x11>
  800370:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800374:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80037b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800380:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800387:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80038f:	eb 2b                	jmp    8003bc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800394:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800398:	eb 22                	jmp    8003bc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003a1:	eb 19                	jmp    8003bc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003ad:	eb 0d                	jmp    8003bc <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003b5:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	0f b6 06             	movzbl (%esi),%eax
  8003bf:	0f b6 d0             	movzbl %al,%edx
  8003c2:	8d 7e 01             	lea    0x1(%esi),%edi
  8003c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003c8:	83 e8 23             	sub    $0x23,%eax
  8003cb:	3c 55                	cmp    $0x55,%al
  8003cd:	0f 87 46 04 00 00    	ja     800819 <vprintfmt+0x4d7>
  8003d3:	0f b6 c0             	movzbl %al,%eax
  8003d6:	ff 24 85 e0 15 80 00 	jmp    *0x8015e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003dd:	83 ea 30             	sub    $0x30,%edx
  8003e0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003e3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003e7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003ed:	83 fa 09             	cmp    $0x9,%edx
  8003f0:	77 4a                	ja     80043c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003f8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003fb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ff:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800402:	8d 50 d0             	lea    -0x30(%eax),%edx
  800405:	83 fa 09             	cmp    $0x9,%edx
  800408:	76 eb                	jbe    8003f5 <vprintfmt+0xb3>
  80040a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80040d:	eb 2d                	jmp    80043c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 50 04             	lea    0x4(%eax),%edx
  800415:	89 55 14             	mov    %edx,0x14(%ebp)
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800420:	eb 1a                	jmp    80043c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800425:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800429:	79 91                	jns    8003bc <vprintfmt+0x7a>
  80042b:	e9 73 ff ff ff       	jmp    8003a3 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800433:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80043a:	eb 80                	jmp    8003bc <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80043c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800440:	0f 89 76 ff ff ff    	jns    8003bc <vprintfmt+0x7a>
  800446:	e9 64 ff ff ff       	jmp    8003af <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800451:	e9 66 ff ff ff       	jmp    8003bc <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800463:	8b 00                	mov    (%eax),%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046e:	e9 f2 fe ff ff       	jmp    800365 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800473:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800477:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80047a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80047e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800481:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800485:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800488:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80048b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80048f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800492:	80 f9 09             	cmp    $0x9,%cl
  800495:	77 1d                	ja     8004b4 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800497:	0f be c0             	movsbl %al,%eax
  80049a:	6b c0 64             	imul   $0x64,%eax,%eax
  80049d:	0f be d2             	movsbl %dl,%edx
  8004a0:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004a3:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004aa:	a3 04 20 80 00       	mov    %eax,0x802004
  8004af:	e9 b1 fe ff ff       	jmp    800365 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004b4:	c7 44 24 04 0a 15 80 	movl   $0x80150a,0x4(%esp)
  8004bb:	00 
  8004bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004bf:	89 04 24             	mov    %eax,(%esp)
  8004c2:	e8 14 05 00 00       	call   8009db <strcmp>
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	75 0f                	jne    8004da <vprintfmt+0x198>
  8004cb:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8004d2:	00 00 00 
  8004d5:	e9 8b fe ff ff       	jmp    800365 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004da:	c7 44 24 04 0e 15 80 	movl   $0x80150e,0x4(%esp)
  8004e1:	00 
  8004e2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004e5:	89 14 24             	mov    %edx,(%esp)
  8004e8:	e8 ee 04 00 00       	call   8009db <strcmp>
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	75 0f                	jne    800500 <vprintfmt+0x1be>
  8004f1:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8004f8:	00 00 00 
  8004fb:	e9 65 fe ff ff       	jmp    800365 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800500:	c7 44 24 04 12 15 80 	movl   $0x801512,0x4(%esp)
  800507:	00 
  800508:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80050b:	89 0c 24             	mov    %ecx,(%esp)
  80050e:	e8 c8 04 00 00       	call   8009db <strcmp>
  800513:	85 c0                	test   %eax,%eax
  800515:	75 0f                	jne    800526 <vprintfmt+0x1e4>
  800517:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  80051e:	00 00 00 
  800521:	e9 3f fe ff ff       	jmp    800365 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800526:	c7 44 24 04 16 15 80 	movl   $0x801516,0x4(%esp)
  80052d:	00 
  80052e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800531:	89 3c 24             	mov    %edi,(%esp)
  800534:	e8 a2 04 00 00       	call   8009db <strcmp>
  800539:	85 c0                	test   %eax,%eax
  80053b:	75 0f                	jne    80054c <vprintfmt+0x20a>
  80053d:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800544:	00 00 00 
  800547:	e9 19 fe ff ff       	jmp    800365 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80054c:	c7 44 24 04 1a 15 80 	movl   $0x80151a,0x4(%esp)
  800553:	00 
  800554:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	e8 7c 04 00 00       	call   8009db <strcmp>
  80055f:	85 c0                	test   %eax,%eax
  800561:	75 0f                	jne    800572 <vprintfmt+0x230>
  800563:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80056a:	00 00 00 
  80056d:	e9 f3 fd ff ff       	jmp    800365 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800572:	c7 44 24 04 1e 15 80 	movl   $0x80151e,0x4(%esp)
  800579:	00 
  80057a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80057d:	89 14 24             	mov    %edx,(%esp)
  800580:	e8 56 04 00 00       	call   8009db <strcmp>
  800585:	83 f8 01             	cmp    $0x1,%eax
  800588:	19 c0                	sbb    %eax,%eax
  80058a:	f7 d0                	not    %eax
  80058c:	83 c0 08             	add    $0x8,%eax
  80058f:	a3 04 20 80 00       	mov    %eax,0x802004
  800594:	e9 cc fd ff ff       	jmp    800365 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 c2                	mov    %eax,%edx
  8005a6:	c1 fa 1f             	sar    $0x1f,%edx
  8005a9:	31 d0                	xor    %edx,%eax
  8005ab:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ad:	83 f8 08             	cmp    $0x8,%eax
  8005b0:	7f 0b                	jg     8005bd <vprintfmt+0x27b>
  8005b2:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	75 23                	jne    8005e0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c1:	c7 44 24 08 22 15 80 	movl   $0x801522,0x8(%esp)
  8005c8:	00 
  8005c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d0:	89 3c 24             	mov    %edi,(%esp)
  8005d3:	e8 42 fd ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005db:	e9 85 fd ff ff       	jmp    800365 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e4:	c7 44 24 08 2b 15 80 	movl   $0x80152b,0x8(%esp)
  8005eb:	00 
  8005ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f3:	89 3c 24             	mov    %edi,(%esp)
  8005f6:	e8 1f fd ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005fe:	e9 62 fd ff ff       	jmp    800365 <vprintfmt+0x23>
  800603:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800606:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800609:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800617:	85 f6                	test   %esi,%esi
  800619:	b8 03 15 80 00       	mov    $0x801503,%eax
  80061e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800621:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800625:	7e 06                	jle    80062d <vprintfmt+0x2eb>
  800627:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80062b:	75 13                	jne    800640 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062d:	0f be 06             	movsbl (%esi),%eax
  800630:	83 c6 01             	add    $0x1,%esi
  800633:	85 c0                	test   %eax,%eax
  800635:	0f 85 94 00 00 00    	jne    8006cf <vprintfmt+0x38d>
  80063b:	e9 81 00 00 00       	jmp    8006c1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800640:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800644:	89 34 24             	mov    %esi,(%esp)
  800647:	e8 9f 02 00 00       	call   8008eb <strnlen>
  80064c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80064f:	29 c2                	sub    %eax,%edx
  800651:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800654:	85 d2                	test   %edx,%edx
  800656:	7e d5                	jle    80062d <vprintfmt+0x2eb>
					putch(padc, putdat);
  800658:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80065c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80065f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800662:	89 d6                	mov    %edx,%esi
  800664:	89 cf                	mov    %ecx,%edi
  800666:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066a:	89 3c 24             	mov    %edi,(%esp)
  80066d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800670:	83 ee 01             	sub    $0x1,%esi
  800673:	75 f1                	jne    800666 <vprintfmt+0x324>
  800675:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800678:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80067b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80067e:	eb ad                	jmp    80062d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800680:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800684:	74 1b                	je     8006a1 <vprintfmt+0x35f>
  800686:	8d 50 e0             	lea    -0x20(%eax),%edx
  800689:	83 fa 5e             	cmp    $0x5e,%edx
  80068c:	76 13                	jbe    8006a1 <vprintfmt+0x35f>
					putch('?', putdat);
  80068e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800691:	89 44 24 04          	mov    %eax,0x4(%esp)
  800695:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80069c:	ff 55 08             	call   *0x8(%ebp)
  80069f:	eb 0d                	jmp    8006ae <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ae:	83 eb 01             	sub    $0x1,%ebx
  8006b1:	0f be 06             	movsbl (%esi),%eax
  8006b4:	83 c6 01             	add    $0x1,%esi
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	75 1a                	jne    8006d5 <vprintfmt+0x393>
  8006bb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006be:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006c8:	7f 1c                	jg     8006e6 <vprintfmt+0x3a4>
  8006ca:	e9 96 fc ff ff       	jmp    800365 <vprintfmt+0x23>
  8006cf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006d2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	78 a7                	js     800680 <vprintfmt+0x33e>
  8006d9:	83 ef 01             	sub    $0x1,%edi
  8006dc:	79 a2                	jns    800680 <vprintfmt+0x33e>
  8006de:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e4:	eb db                	jmp    8006c1 <vprintfmt+0x37f>
  8006e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e9:	89 de                	mov    %ebx,%esi
  8006eb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fb:	83 eb 01             	sub    $0x1,%ebx
  8006fe:	75 ee                	jne    8006ee <vprintfmt+0x3ac>
  800700:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800705:	e9 5b fc ff ff       	jmp    800365 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070a:	83 f9 01             	cmp    $0x1,%ecx
  80070d:	7e 10                	jle    80071f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 08             	lea    0x8(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 30                	mov    (%eax),%esi
  80071a:	8b 78 04             	mov    0x4(%eax),%edi
  80071d:	eb 26                	jmp    800745 <vprintfmt+0x403>
	else if (lflag)
  80071f:	85 c9                	test   %ecx,%ecx
  800721:	74 12                	je     800735 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8d 50 04             	lea    0x4(%eax),%edx
  800729:	89 55 14             	mov    %edx,0x14(%ebp)
  80072c:	8b 30                	mov    (%eax),%esi
  80072e:	89 f7                	mov    %esi,%edi
  800730:	c1 ff 1f             	sar    $0x1f,%edi
  800733:	eb 10                	jmp    800745 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8d 50 04             	lea    0x4(%eax),%edx
  80073b:	89 55 14             	mov    %edx,0x14(%ebp)
  80073e:	8b 30                	mov    (%eax),%esi
  800740:	89 f7                	mov    %esi,%edi
  800742:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800745:	85 ff                	test   %edi,%edi
  800747:	78 0e                	js     800757 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800749:	89 f0                	mov    %esi,%eax
  80074b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80074d:	be 0a 00 00 00       	mov    $0xa,%esi
  800752:	e9 84 00 00 00       	jmp    8007db <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800757:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800762:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800765:	89 f0                	mov    %esi,%eax
  800767:	89 fa                	mov    %edi,%edx
  800769:	f7 d8                	neg    %eax
  80076b:	83 d2 00             	adc    $0x0,%edx
  80076e:	f7 da                	neg    %edx
			}
			base = 10;
  800770:	be 0a 00 00 00       	mov    $0xa,%esi
  800775:	eb 64                	jmp    8007db <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800777:	89 ca                	mov    %ecx,%edx
  800779:	8d 45 14             	lea    0x14(%ebp),%eax
  80077c:	e8 42 fb ff ff       	call   8002c3 <getuint>
			base = 10;
  800781:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800786:	eb 53                	jmp    8007db <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800788:	89 ca                	mov    %ecx,%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 31 fb ff ff       	call   8002c3 <getuint>
    			base = 8;
  800792:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800797:	eb 42                	jmp    8007db <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800799:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 50 04             	lea    0x4(%eax),%edx
  8007bb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007ca:	eb 0f                	jmp    8007db <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007cc:	89 ca                	mov    %ecx,%edx
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d1:	e8 ed fa ff ff       	call   8002c3 <getuint>
			base = 16;
  8007d6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007db:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007df:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007e3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007e6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007ee:	89 04 24             	mov    %eax,(%esp)
  8007f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f5:	89 da                	mov    %ebx,%edx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	e8 e9 f9 ff ff       	call   8001e8 <printnum>
			break;
  8007ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800802:	e9 5e fb ff ff       	jmp    800365 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800807:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080b:	89 14 24             	mov    %edx,(%esp)
  80080e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800811:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800814:	e9 4c fb ff ff       	jmp    800365 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800819:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800824:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800827:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80082b:	0f 84 34 fb ff ff    	je     800365 <vprintfmt+0x23>
  800831:	83 ee 01             	sub    $0x1,%esi
  800834:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800838:	75 f7                	jne    800831 <vprintfmt+0x4ef>
  80083a:	e9 26 fb ff ff       	jmp    800365 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80083f:	83 c4 5c             	add    $0x5c,%esp
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5f                   	pop    %edi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	83 ec 28             	sub    $0x28,%esp
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800853:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800856:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800864:	85 c0                	test   %eax,%eax
  800866:	74 30                	je     800898 <vsnprintf+0x51>
  800868:	85 d2                	test   %edx,%edx
  80086a:	7e 2c                	jle    800898 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800873:	8b 45 10             	mov    0x10(%ebp),%eax
  800876:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800881:	c7 04 24 fd 02 80 00 	movl   $0x8002fd,(%esp)
  800888:	e8 b5 fa ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800890:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800896:	eb 05                	jmp    80089d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800898:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8008af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	89 04 24             	mov    %eax,(%esp)
  8008c0:	e8 82 ff ff ff       	call   800847 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    
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
  800d93:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800daa:	e8 f1 03 00 00       	call   8011a0 <_panic>

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
  800e52:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800e69:	e8 32 03 00 00       	call   8011a0 <_panic>

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
  800eb0:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800ec7:	e8 d4 02 00 00       	call   8011a0 <_panic>

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
  800f0e:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800f15:	00 
  800f16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1d:	00 
  800f1e:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800f25:	e8 76 02 00 00       	call   8011a0 <_panic>

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
  800f6c:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800f83:	e8 18 02 00 00       	call   8011a0 <_panic>

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
  800fca:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800fe1:	e8 ba 01 00 00       	call   8011a0 <_panic>

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
  80105b:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  801062:	00 
  801063:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  801072:	e8 29 01 00 00       	call   8011a0 <_panic>

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

00801084 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 10             	sub    $0x10,%esp
  80108c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80108f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801092:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801095:	85 db                	test   %ebx,%ebx
  801097:	74 06                	je     80109f <ipc_recv+0x1b>
  801099:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80109f:	85 f6                	test   %esi,%esi
  8010a1:	74 06                	je     8010a9 <ipc_recv+0x25>
  8010a3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010b0:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8010b3:	89 04 24             	mov    %eax,(%esp)
  8010b6:	e8 6c ff ff ff       	call   801027 <sys_ipc_recv>
    if (ret) return ret;
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	75 24                	jne    8010e3 <ipc_recv+0x5f>
    if (from_env_store)
  8010bf:	85 db                	test   %ebx,%ebx
  8010c1:	74 0a                	je     8010cd <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  8010c3:	a1 08 20 80 00       	mov    0x802008,%eax
  8010c8:	8b 40 74             	mov    0x74(%eax),%eax
  8010cb:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8010cd:	85 f6                	test   %esi,%esi
  8010cf:	74 0a                	je     8010db <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8010d1:	a1 08 20 80 00       	mov    0x802008,%eax
  8010d6:	8b 40 78             	mov    0x78(%eax),%eax
  8010d9:	89 06                	mov    %eax,(%esi)
    return thisenv->env_ipc_value;
  8010db:	a1 08 20 80 00       	mov    0x802008,%eax
  8010e0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	57                   	push   %edi
  8010ee:	56                   	push   %esi
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 1c             	sub    $0x1c,%esp
  8010f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8010fc:	85 db                	test   %ebx,%ebx
  8010fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801103:	0f 44 d8             	cmove  %eax,%ebx
  801106:	eb 2a                	jmp    801132 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801108:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80110b:	74 20                	je     80112d <ipc_send+0x43>
  80110d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801111:	c7 44 24 08 8f 17 80 	movl   $0x80178f,0x8(%esp)
  801118:	00 
  801119:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801120:	00 
  801121:	c7 04 24 a6 17 80 00 	movl   $0x8017a6,(%esp)
  801128:	e8 73 00 00 00       	call   8011a0 <_panic>
        sys_yield();
  80112d:	e8 ba fc ff ff       	call   800dec <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801132:	8b 45 14             	mov    0x14(%ebp),%eax
  801135:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80113d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801141:	89 34 24             	mov    %esi,(%esp)
  801144:	e8 aa fe ff ff       	call   800ff3 <sys_ipc_try_send>
  801149:	85 c0                	test   %eax,%eax
  80114b:	75 bb                	jne    801108 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
        sys_yield();
    }
}
  80114d:	83 c4 1c             	add    $0x1c,%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80115b:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801160:	39 c8                	cmp    %ecx,%eax
  801162:	74 17                	je     80117b <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801164:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801169:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80116c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801172:	8b 52 50             	mov    0x50(%edx),%edx
  801175:	39 ca                	cmp    %ecx,%edx
  801177:	75 14                	jne    80118d <ipc_find_env+0x38>
  801179:	eb 05                	jmp    801180 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80117b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801180:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801183:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801188:	8b 40 40             	mov    0x40(%eax),%eax
  80118b:	eb 0e                	jmp    80119b <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80118d:	83 c0 01             	add    $0x1,%eax
  801190:	3d 00 04 00 00       	cmp    $0x400,%eax
  801195:	75 d2                	jne    801169 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801197:	66 b8 00 00          	mov    $0x0,%ax
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    
  80119d:	00 00                	add    %al,(%eax)
	...

008011a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011ab:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8011b1:	e8 06 fc ff ff       	call   800dbc <sys_getenvid>
  8011b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cc:	c7 04 24 b0 17 80 00 	movl   $0x8017b0,(%esp)
  8011d3:	e8 f3 ef ff ff       	call   8001cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	e8 83 ef ff ff       	call   80016a <vcprintf>
	cprintf("\n");
  8011e7:	c7 04 24 cf 14 80 00 	movl   $0x8014cf,(%esp)
  8011ee:	e8 d8 ef ff ff       	call   8001cb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011f3:	cc                   	int3   
  8011f4:	eb fd                	jmp    8011f3 <_panic+0x53>
	...

00801200 <__udivdi3>:
  801200:	83 ec 1c             	sub    $0x1c,%esp
  801203:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801207:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80120b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80120f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801213:	89 74 24 10          	mov    %esi,0x10(%esp)
  801217:	8b 74 24 24          	mov    0x24(%esp),%esi
  80121b:	85 ff                	test   %edi,%edi
  80121d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801221:	89 44 24 08          	mov    %eax,0x8(%esp)
  801225:	89 cd                	mov    %ecx,%ebp
  801227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122b:	75 33                	jne    801260 <__udivdi3+0x60>
  80122d:	39 f1                	cmp    %esi,%ecx
  80122f:	77 57                	ja     801288 <__udivdi3+0x88>
  801231:	85 c9                	test   %ecx,%ecx
  801233:	75 0b                	jne    801240 <__udivdi3+0x40>
  801235:	b8 01 00 00 00       	mov    $0x1,%eax
  80123a:	31 d2                	xor    %edx,%edx
  80123c:	f7 f1                	div    %ecx
  80123e:	89 c1                	mov    %eax,%ecx
  801240:	89 f0                	mov    %esi,%eax
  801242:	31 d2                	xor    %edx,%edx
  801244:	f7 f1                	div    %ecx
  801246:	89 c6                	mov    %eax,%esi
  801248:	8b 44 24 04          	mov    0x4(%esp),%eax
  80124c:	f7 f1                	div    %ecx
  80124e:	89 f2                	mov    %esi,%edx
  801250:	8b 74 24 10          	mov    0x10(%esp),%esi
  801254:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801258:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80125c:	83 c4 1c             	add    $0x1c,%esp
  80125f:	c3                   	ret    
  801260:	31 d2                	xor    %edx,%edx
  801262:	31 c0                	xor    %eax,%eax
  801264:	39 f7                	cmp    %esi,%edi
  801266:	77 e8                	ja     801250 <__udivdi3+0x50>
  801268:	0f bd cf             	bsr    %edi,%ecx
  80126b:	83 f1 1f             	xor    $0x1f,%ecx
  80126e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801272:	75 2c                	jne    8012a0 <__udivdi3+0xa0>
  801274:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801278:	76 04                	jbe    80127e <__udivdi3+0x7e>
  80127a:	39 f7                	cmp    %esi,%edi
  80127c:	73 d2                	jae    801250 <__udivdi3+0x50>
  80127e:	31 d2                	xor    %edx,%edx
  801280:	b8 01 00 00 00       	mov    $0x1,%eax
  801285:	eb c9                	jmp    801250 <__udivdi3+0x50>
  801287:	90                   	nop
  801288:	89 f2                	mov    %esi,%edx
  80128a:	f7 f1                	div    %ecx
  80128c:	31 d2                	xor    %edx,%edx
  80128e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801292:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801296:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80129a:	83 c4 1c             	add    $0x1c,%esp
  80129d:	c3                   	ret    
  80129e:	66 90                	xchg   %ax,%ax
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	b8 20 00 00 00       	mov    $0x20,%eax
  8012aa:	89 ea                	mov    %ebp,%edx
  8012ac:	2b 44 24 04          	sub    0x4(%esp),%eax
  8012b0:	d3 e7                	shl    %cl,%edi
  8012b2:	89 c1                	mov    %eax,%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012bb:	09 fa                	or     %edi,%edx
  8012bd:	89 f7                	mov    %esi,%edi
  8012bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012c3:	89 f2                	mov    %esi,%edx
  8012c5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012c9:	d3 e5                	shl    %cl,%ebp
  8012cb:	89 c1                	mov    %eax,%ecx
  8012cd:	d3 ef                	shr    %cl,%edi
  8012cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d4:	d3 e2                	shl    %cl,%edx
  8012d6:	89 c1                	mov    %eax,%ecx
  8012d8:	d3 ee                	shr    %cl,%esi
  8012da:	09 d6                	or     %edx,%esi
  8012dc:	89 fa                	mov    %edi,%edx
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	f7 74 24 0c          	divl   0xc(%esp)
  8012e4:	89 d7                	mov    %edx,%edi
  8012e6:	89 c6                	mov    %eax,%esi
  8012e8:	f7 e5                	mul    %ebp
  8012ea:	39 d7                	cmp    %edx,%edi
  8012ec:	72 22                	jb     801310 <__udivdi3+0x110>
  8012ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8012f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f7:	d3 e5                	shl    %cl,%ebp
  8012f9:	39 c5                	cmp    %eax,%ebp
  8012fb:	73 04                	jae    801301 <__udivdi3+0x101>
  8012fd:	39 d7                	cmp    %edx,%edi
  8012ff:	74 0f                	je     801310 <__udivdi3+0x110>
  801301:	89 f0                	mov    %esi,%eax
  801303:	31 d2                	xor    %edx,%edx
  801305:	e9 46 ff ff ff       	jmp    801250 <__udivdi3+0x50>
  80130a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801310:	8d 46 ff             	lea    -0x1(%esi),%eax
  801313:	31 d2                	xor    %edx,%edx
  801315:	8b 74 24 10          	mov    0x10(%esp),%esi
  801319:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80131d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801321:	83 c4 1c             	add    $0x1c,%esp
  801324:	c3                   	ret    
	...

00801330 <__umoddi3>:
  801330:	83 ec 1c             	sub    $0x1c,%esp
  801333:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801337:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80133b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80133f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801343:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801347:	8b 74 24 24          	mov    0x24(%esp),%esi
  80134b:	85 ed                	test   %ebp,%ebp
  80134d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801351:	89 44 24 08          	mov    %eax,0x8(%esp)
  801355:	89 cf                	mov    %ecx,%edi
  801357:	89 04 24             	mov    %eax,(%esp)
  80135a:	89 f2                	mov    %esi,%edx
  80135c:	75 1a                	jne    801378 <__umoddi3+0x48>
  80135e:	39 f1                	cmp    %esi,%ecx
  801360:	76 4e                	jbe    8013b0 <__umoddi3+0x80>
  801362:	f7 f1                	div    %ecx
  801364:	89 d0                	mov    %edx,%eax
  801366:	31 d2                	xor    %edx,%edx
  801368:	8b 74 24 10          	mov    0x10(%esp),%esi
  80136c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801370:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801374:	83 c4 1c             	add    $0x1c,%esp
  801377:	c3                   	ret    
  801378:	39 f5                	cmp    %esi,%ebp
  80137a:	77 54                	ja     8013d0 <__umoddi3+0xa0>
  80137c:	0f bd c5             	bsr    %ebp,%eax
  80137f:	83 f0 1f             	xor    $0x1f,%eax
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	75 60                	jne    8013e8 <__umoddi3+0xb8>
  801388:	3b 0c 24             	cmp    (%esp),%ecx
  80138b:	0f 87 07 01 00 00    	ja     801498 <__umoddi3+0x168>
  801391:	89 f2                	mov    %esi,%edx
  801393:	8b 34 24             	mov    (%esp),%esi
  801396:	29 ce                	sub    %ecx,%esi
  801398:	19 ea                	sbb    %ebp,%edx
  80139a:	89 34 24             	mov    %esi,(%esp)
  80139d:	8b 04 24             	mov    (%esp),%eax
  8013a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013ac:	83 c4 1c             	add    $0x1c,%esp
  8013af:	c3                   	ret    
  8013b0:	85 c9                	test   %ecx,%ecx
  8013b2:	75 0b                	jne    8013bf <__umoddi3+0x8f>
  8013b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b9:	31 d2                	xor    %edx,%edx
  8013bb:	f7 f1                	div    %ecx
  8013bd:	89 c1                	mov    %eax,%ecx
  8013bf:	89 f0                	mov    %esi,%eax
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	f7 f1                	div    %ecx
  8013c5:	8b 04 24             	mov    (%esp),%eax
  8013c8:	f7 f1                	div    %ecx
  8013ca:	eb 98                	jmp    801364 <__umoddi3+0x34>
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	89 f2                	mov    %esi,%edx
  8013d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013de:	83 c4 1c             	add    $0x1c,%esp
  8013e1:	c3                   	ret    
  8013e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013ed:	89 e8                	mov    %ebp,%eax
  8013ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8013f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8013f8:	89 fa                	mov    %edi,%edx
  8013fa:	d3 e0                	shl    %cl,%eax
  8013fc:	89 e9                	mov    %ebp,%ecx
  8013fe:	d3 ea                	shr    %cl,%edx
  801400:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801405:	09 c2                	or     %eax,%edx
  801407:	8b 44 24 08          	mov    0x8(%esp),%eax
  80140b:	89 14 24             	mov    %edx,(%esp)
  80140e:	89 f2                	mov    %esi,%edx
  801410:	d3 e7                	shl    %cl,%edi
  801412:	89 e9                	mov    %ebp,%ecx
  801414:	d3 ea                	shr    %cl,%edx
  801416:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80141b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80141f:	d3 e6                	shl    %cl,%esi
  801421:	89 e9                	mov    %ebp,%ecx
  801423:	d3 e8                	shr    %cl,%eax
  801425:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80142a:	09 f0                	or     %esi,%eax
  80142c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801430:	f7 34 24             	divl   (%esp)
  801433:	d3 e6                	shl    %cl,%esi
  801435:	89 74 24 08          	mov    %esi,0x8(%esp)
  801439:	89 d6                	mov    %edx,%esi
  80143b:	f7 e7                	mul    %edi
  80143d:	39 d6                	cmp    %edx,%esi
  80143f:	89 c1                	mov    %eax,%ecx
  801441:	89 d7                	mov    %edx,%edi
  801443:	72 3f                	jb     801484 <__umoddi3+0x154>
  801445:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801449:	72 35                	jb     801480 <__umoddi3+0x150>
  80144b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80144f:	29 c8                	sub    %ecx,%eax
  801451:	19 fe                	sbb    %edi,%esi
  801453:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801458:	89 f2                	mov    %esi,%edx
  80145a:	d3 e8                	shr    %cl,%eax
  80145c:	89 e9                	mov    %ebp,%ecx
  80145e:	d3 e2                	shl    %cl,%edx
  801460:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801465:	09 d0                	or     %edx,%eax
  801467:	89 f2                	mov    %esi,%edx
  801469:	d3 ea                	shr    %cl,%edx
  80146b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80146f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801473:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801477:	83 c4 1c             	add    $0x1c,%esp
  80147a:	c3                   	ret    
  80147b:	90                   	nop
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	39 d6                	cmp    %edx,%esi
  801482:	75 c7                	jne    80144b <__umoddi3+0x11b>
  801484:	89 d7                	mov    %edx,%edi
  801486:	89 c1                	mov    %eax,%ecx
  801488:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80148c:	1b 3c 24             	sbb    (%esp),%edi
  80148f:	eb ba                	jmp    80144b <__umoddi3+0x11b>
  801491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801498:	39 f5                	cmp    %esi,%ebp
  80149a:	0f 82 f1 fe ff ff    	jb     801391 <__umoddi3+0x61>
  8014a0:	e9 f8 fe ff ff       	jmp    80139d <__umoddi3+0x6d>
