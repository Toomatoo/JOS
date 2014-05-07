
obj/user/fairness.debug:     file format elf32-i386


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
  800043:	81 3d 04 40 80 00 80 	cmpl   $0xeec00080,0x804004
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
  800065:	e8 aa 10 00 00       	call   801114 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 80 23 80 00 	movl   $0x802380,(%esp)
  80007c:	e8 52 01 00 00       	call   8001d3 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 91 23 80 00 	movl   $0x802391,(%esp)
  800097:	e8 37 01 00 00       	call   8001d3 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 b9 10 00 00       	call   80117a <ipc_send>
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
  8000e0:	c1 e0 07             	shl    $0x7,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x34>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  80011a:	e8 2f 13 00 00       	call   80144e <close_all>
	sys_env_destroy(0);
  80011f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800126:	e8 34 0c 00 00       	call   800d5f <sys_env_destroy>
}
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    
  80012d:	00 00                	add    %al,(%eax)
	...

00800130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	53                   	push   %ebx
  800134:	83 ec 14             	sub    $0x14,%esp
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800143:	83 c0 01             	add    $0x1,%eax
  800146:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800148:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014d:	75 19                	jne    800168 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80014f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800156:	00 
  800157:	8d 43 08             	lea    0x8(%ebx),%eax
  80015a:	89 04 24             	mov    %eax,(%esp)
  80015d:	e8 9e 0b 00 00       	call   800d00 <sys_cputs>
		b->idx = 0;
  800162:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800168:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016c:	83 c4 14             	add    $0x14,%esp
  80016f:	5b                   	pop    %ebx
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800182:	00 00 00 
	b.cnt = 0;
  800185:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 30 01 80 00 	movl   $0x800130,(%esp)
  8001ae:	e8 97 01 00 00       	call   80034a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 35 0b 00 00       	call   800d00 <sys_cputs>

	return b.cnt;
}
  8001cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 87 ff ff ff       	call   800172 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    
  8001ed:	00 00                	add    %al,(%eax)
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	b8 00 00 00 00       	mov    $0x0,%eax
  800215:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800218:	72 11                	jb     80022b <printnum+0x3b>
  80021a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800220:	76 09                	jbe    80022b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 eb 01             	sub    $0x1,%ebx
  800225:	85 db                	test   %ebx,%ebx
  800227:	7f 51                	jg     80027a <printnum+0x8a>
  800229:	eb 5e                	jmp    800289 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800236:	8b 45 10             	mov    0x10(%ebp),%eax
  800239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800241:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800245:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024c:	00 
  80024d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	e8 61 1e 00 00       	call   8020c0 <__udivdi3>
  80025f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800263:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026e:	89 fa                	mov    %edi,%edx
  800270:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800273:	e8 78 ff ff ff       	call   8001f0 <printnum>
  800278:	eb 0f                	jmp    800289 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027e:	89 34 24             	mov    %esi,(%esp)
  800281:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	75 f1                	jne    80027a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800291:	8b 45 10             	mov    0x10(%ebp),%eax
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	e8 3e 1f 00 00       	call   8021f0 <__umoddi3>
  8002b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b6:	0f be 80 b2 23 80 00 	movsbl 0x8023b2(%eax),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002c3:	83 c4 3c             	add    $0x3c,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ce:	83 fa 01             	cmp    $0x1,%edx
  8002d1:	7e 0e                	jle    8002e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	8b 52 04             	mov    0x4(%edx),%edx
  8002df:	eb 22                	jmp    800303 <getuint+0x38>
	else if (lflag)
  8002e1:	85 d2                	test   %edx,%edx
  8002e3:	74 10                	je     8002f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f3:	eb 0e                	jmp    800303 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	3b 50 04             	cmp    0x4(%eax),%edx
  800314:	73 0a                	jae    800320 <sprintputch+0x1b>
		*b->buf++ = ch;
  800316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800319:	88 0a                	mov    %cl,(%edx)
  80031b:	83 c2 01             	add    $0x1,%edx
  80031e:	89 10                	mov    %edx,(%eax)
}
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800328:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032f:	8b 45 10             	mov    0x10(%ebp),%eax
  800332:	89 44 24 08          	mov    %eax,0x8(%esp)
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	e8 02 00 00 00       	call   80034a <vprintfmt>
	va_end(ap);
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
  800350:	83 ec 5c             	sub    $0x5c,%esp
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800356:	8b 75 10             	mov    0x10(%ebp),%esi
  800359:	eb 12                	jmp    80036d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035b:	85 c0                	test   %eax,%eax
  80035d:	0f 84 e4 04 00 00    	je     800847 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800363:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036d:	0f b6 06             	movzbl (%esi),%eax
  800370:	83 c6 01             	add    $0x1,%esi
  800373:	83 f8 25             	cmp    $0x25,%eax
  800376:	75 e3                	jne    80035b <vprintfmt+0x11>
  800378:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80037c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800383:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800388:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800394:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800397:	eb 2b                	jmp    8003c4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003a0:	eb 22                	jmp    8003c4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003a9:	eb 19                	jmp    8003c4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003ae:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003b5:	eb 0d                	jmp    8003c4 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003bd:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	0f b6 06             	movzbl (%esi),%eax
  8003c7:	0f b6 d0             	movzbl %al,%edx
  8003ca:	8d 7e 01             	lea    0x1(%esi),%edi
  8003cd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003d0:	83 e8 23             	sub    $0x23,%eax
  8003d3:	3c 55                	cmp    $0x55,%al
  8003d5:	0f 87 46 04 00 00    	ja     800821 <vprintfmt+0x4d7>
  8003db:	0f b6 c0             	movzbl %al,%eax
  8003de:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e5:	83 ea 30             	sub    $0x30,%edx
  8003e8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8003eb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003ef:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003f5:	83 fa 09             	cmp    $0x9,%edx
  8003f8:	77 4a                	ja     800444 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800400:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800403:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800407:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80040a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040d:	83 fa 09             	cmp    $0x9,%edx
  800410:	76 eb                	jbe    8003fd <vprintfmt+0xb3>
  800412:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800415:	eb 2d                	jmp    800444 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800428:	eb 1a                	jmp    800444 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80042d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800431:	79 91                	jns    8003c4 <vprintfmt+0x7a>
  800433:	e9 73 ff ff ff       	jmp    8003ab <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800442:	eb 80                	jmp    8003c4 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800444:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800448:	0f 89 76 ff ff ff    	jns    8003c4 <vprintfmt+0x7a>
  80044e:	e9 64 ff ff ff       	jmp    8003b7 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800453:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800459:	e9 66 ff ff ff       	jmp    8003c4 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	89 04 24             	mov    %eax,(%esp)
  800470:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800476:	e9 f2 fe ff ff       	jmp    80036d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80047b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80047f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800482:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800486:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800489:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80048d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800490:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800493:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800497:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80049a:	80 f9 09             	cmp    $0x9,%cl
  80049d:	77 1d                	ja     8004bc <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80049f:	0f be c0             	movsbl %al,%eax
  8004a2:	6b c0 64             	imul   $0x64,%eax,%eax
  8004a5:	0f be d2             	movsbl %dl,%edx
  8004a8:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004ab:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004b2:	a3 04 30 80 00       	mov    %eax,0x803004
  8004b7:	e9 b1 fe ff ff       	jmp    80036d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004bc:	c7 44 24 04 ca 23 80 	movl   $0x8023ca,0x4(%esp)
  8004c3:	00 
  8004c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	e8 0c 05 00 00       	call   8009db <strcmp>
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	75 0f                	jne    8004e2 <vprintfmt+0x198>
  8004d3:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8004da:	00 00 00 
  8004dd:	e9 8b fe ff ff       	jmp    80036d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8004e2:	c7 44 24 04 ce 23 80 	movl   $0x8023ce,0x4(%esp)
  8004e9:	00 
  8004ea:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004ed:	89 14 24             	mov    %edx,(%esp)
  8004f0:	e8 e6 04 00 00       	call   8009db <strcmp>
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	75 0f                	jne    800508 <vprintfmt+0x1be>
  8004f9:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800500:	00 00 00 
  800503:	e9 65 fe ff ff       	jmp    80036d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800508:	c7 44 24 04 d2 23 80 	movl   $0x8023d2,0x4(%esp)
  80050f:	00 
  800510:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800513:	89 0c 24             	mov    %ecx,(%esp)
  800516:	e8 c0 04 00 00       	call   8009db <strcmp>
  80051b:	85 c0                	test   %eax,%eax
  80051d:	75 0f                	jne    80052e <vprintfmt+0x1e4>
  80051f:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  800526:	00 00 00 
  800529:	e9 3f fe ff ff       	jmp    80036d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80052e:	c7 44 24 04 d6 23 80 	movl   $0x8023d6,0x4(%esp)
  800535:	00 
  800536:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800539:	89 3c 24             	mov    %edi,(%esp)
  80053c:	e8 9a 04 00 00       	call   8009db <strcmp>
  800541:	85 c0                	test   %eax,%eax
  800543:	75 0f                	jne    800554 <vprintfmt+0x20a>
  800545:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  80054c:	00 00 00 
  80054f:	e9 19 fe ff ff       	jmp    80036d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800554:	c7 44 24 04 da 23 80 	movl   $0x8023da,0x4(%esp)
  80055b:	00 
  80055c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 74 04 00 00       	call   8009db <strcmp>
  800567:	85 c0                	test   %eax,%eax
  800569:	75 0f                	jne    80057a <vprintfmt+0x230>
  80056b:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800572:	00 00 00 
  800575:	e9 f3 fd ff ff       	jmp    80036d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80057a:	c7 44 24 04 de 23 80 	movl   $0x8023de,0x4(%esp)
  800581:	00 
  800582:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800585:	89 14 24             	mov    %edx,(%esp)
  800588:	e8 4e 04 00 00       	call   8009db <strcmp>
  80058d:	83 f8 01             	cmp    $0x1,%eax
  800590:	19 c0                	sbb    %eax,%eax
  800592:	f7 d0                	not    %eax
  800594:	83 c0 08             	add    $0x8,%eax
  800597:	a3 04 30 80 00       	mov    %eax,0x803004
  80059c:	e9 cc fd ff ff       	jmp    80036d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 c2                	mov    %eax,%edx
  8005ae:	c1 fa 1f             	sar    $0x1f,%edx
  8005b1:	31 d0                	xor    %edx,%eax
  8005b3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b5:	83 f8 0f             	cmp    $0xf,%eax
  8005b8:	7f 0b                	jg     8005c5 <vprintfmt+0x27b>
  8005ba:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	75 23                	jne    8005e8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c9:	c7 44 24 08 e2 23 80 	movl   $0x8023e2,0x8(%esp)
  8005d0:	00 
  8005d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d8:	89 3c 24             	mov    %edi,(%esp)
  8005db:	e8 42 fd ff ff       	call   800322 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e3:	e9 85 fd ff ff       	jmp    80036d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ec:	c7 44 24 08 b1 27 80 	movl   $0x8027b1,0x8(%esp)
  8005f3:	00 
  8005f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005fb:	89 3c 24             	mov    %edi,(%esp)
  8005fe:	e8 1f fd ff ff       	call   800322 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800606:	e9 62 fd ff ff       	jmp    80036d <vprintfmt+0x23>
  80060b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80060e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800611:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80061f:	85 f6                	test   %esi,%esi
  800621:	b8 c3 23 80 00       	mov    $0x8023c3,%eax
  800626:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800629:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80062d:	7e 06                	jle    800635 <vprintfmt+0x2eb>
  80062f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800633:	75 13                	jne    800648 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800635:	0f be 06             	movsbl (%esi),%eax
  800638:	83 c6 01             	add    $0x1,%esi
  80063b:	85 c0                	test   %eax,%eax
  80063d:	0f 85 94 00 00 00    	jne    8006d7 <vprintfmt+0x38d>
  800643:	e9 81 00 00 00       	jmp    8006c9 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064c:	89 34 24             	mov    %esi,(%esp)
  80064f:	e8 97 02 00 00       	call   8008eb <strnlen>
  800654:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800657:	29 c2                	sub    %eax,%edx
  800659:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80065c:	85 d2                	test   %edx,%edx
  80065e:	7e d5                	jle    800635 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800660:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800664:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800667:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80066a:	89 d6                	mov    %edx,%esi
  80066c:	89 cf                	mov    %ecx,%edi
  80066e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800672:	89 3c 24             	mov    %edi,(%esp)
  800675:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800678:	83 ee 01             	sub    $0x1,%esi
  80067b:	75 f1                	jne    80066e <vprintfmt+0x324>
  80067d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800680:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800683:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800686:	eb ad                	jmp    800635 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800688:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80068c:	74 1b                	je     8006a9 <vprintfmt+0x35f>
  80068e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800691:	83 fa 5e             	cmp    $0x5e,%edx
  800694:	76 13                	jbe    8006a9 <vprintfmt+0x35f>
					putch('?', putdat);
  800696:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a4:	ff 55 08             	call   *0x8(%ebp)
  8006a7:	eb 0d                	jmp    8006b6 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	83 eb 01             	sub    $0x1,%ebx
  8006b9:	0f be 06             	movsbl (%esi),%eax
  8006bc:	83 c6 01             	add    $0x1,%esi
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	75 1a                	jne    8006dd <vprintfmt+0x393>
  8006c3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006c6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006d0:	7f 1c                	jg     8006ee <vprintfmt+0x3a4>
  8006d2:	e9 96 fc ff ff       	jmp    80036d <vprintfmt+0x23>
  8006d7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006da:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006dd:	85 ff                	test   %edi,%edi
  8006df:	78 a7                	js     800688 <vprintfmt+0x33e>
  8006e1:	83 ef 01             	sub    $0x1,%edi
  8006e4:	79 a2                	jns    800688 <vprintfmt+0x33e>
  8006e6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006e9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006ec:	eb db                	jmp    8006c9 <vprintfmt+0x37f>
  8006ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f1:	89 de                	mov    %ebx,%esi
  8006f3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800701:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800703:	83 eb 01             	sub    $0x1,%ebx
  800706:	75 ee                	jne    8006f6 <vprintfmt+0x3ac>
  800708:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80070d:	e9 5b fc ff ff       	jmp    80036d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800712:	83 f9 01             	cmp    $0x1,%ecx
  800715:	7e 10                	jle    800727 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 08             	lea    0x8(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)
  800720:	8b 30                	mov    (%eax),%esi
  800722:	8b 78 04             	mov    0x4(%eax),%edi
  800725:	eb 26                	jmp    80074d <vprintfmt+0x403>
	else if (lflag)
  800727:	85 c9                	test   %ecx,%ecx
  800729:	74 12                	je     80073d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8d 50 04             	lea    0x4(%eax),%edx
  800731:	89 55 14             	mov    %edx,0x14(%ebp)
  800734:	8b 30                	mov    (%eax),%esi
  800736:	89 f7                	mov    %esi,%edi
  800738:	c1 ff 1f             	sar    $0x1f,%edi
  80073b:	eb 10                	jmp    80074d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8d 50 04             	lea    0x4(%eax),%edx
  800743:	89 55 14             	mov    %edx,0x14(%ebp)
  800746:	8b 30                	mov    (%eax),%esi
  800748:	89 f7                	mov    %esi,%edi
  80074a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80074d:	85 ff                	test   %edi,%edi
  80074f:	78 0e                	js     80075f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800751:	89 f0                	mov    %esi,%eax
  800753:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800755:	be 0a 00 00 00       	mov    $0xa,%esi
  80075a:	e9 84 00 00 00       	jmp    8007e3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80075f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800763:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80076a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80076d:	89 f0                	mov    %esi,%eax
  80076f:	89 fa                	mov    %edi,%edx
  800771:	f7 d8                	neg    %eax
  800773:	83 d2 00             	adc    $0x0,%edx
  800776:	f7 da                	neg    %edx
			}
			base = 10;
  800778:	be 0a 00 00 00       	mov    $0xa,%esi
  80077d:	eb 64                	jmp    8007e3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077f:	89 ca                	mov    %ecx,%edx
  800781:	8d 45 14             	lea    0x14(%ebp),%eax
  800784:	e8 42 fb ff ff       	call   8002cb <getuint>
			base = 10;
  800789:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80078e:	eb 53                	jmp    8007e3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800790:	89 ca                	mov    %ecx,%edx
  800792:	8d 45 14             	lea    0x14(%ebp),%eax
  800795:	e8 31 fb ff ff       	call   8002cb <getuint>
    			base = 8;
  80079a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80079f:	eb 42                	jmp    8007e3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8007a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ba:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 04             	lea    0x4(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007cd:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007d2:	eb 0f                	jmp    8007e3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d4:	89 ca                	mov    %ecx,%edx
  8007d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d9:	e8 ed fa ff ff       	call   8002cb <getuint>
			base = 16;
  8007de:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007e7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007eb:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007ee:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007f2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007f6:	89 04 24             	mov    %eax,(%esp)
  8007f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fd:	89 da                	mov    %ebx,%edx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	e8 e9 f9 ff ff       	call   8001f0 <printnum>
			break;
  800807:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80080a:	e9 5e fb ff ff       	jmp    80036d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80080f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800813:	89 14 24             	mov    %edx,(%esp)
  800816:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800819:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80081c:	e9 4c fb ff ff       	jmp    80036d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800821:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800825:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80082c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800833:	0f 84 34 fb ff ff    	je     80036d <vprintfmt+0x23>
  800839:	83 ee 01             	sub    $0x1,%esi
  80083c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800840:	75 f7                	jne    800839 <vprintfmt+0x4ef>
  800842:	e9 26 fb ff ff       	jmp    80036d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800847:	83 c4 5c             	add    $0x5c,%esp
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5f                   	pop    %edi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 28             	sub    $0x28,%esp
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800862:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800865:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086c:	85 c0                	test   %eax,%eax
  80086e:	74 30                	je     8008a0 <vsnprintf+0x51>
  800870:	85 d2                	test   %edx,%edx
  800872:	7e 2c                	jle    8008a0 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087b:	8b 45 10             	mov    0x10(%ebp),%eax
  80087e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800882:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	c7 04 24 05 03 80 00 	movl   $0x800305,(%esp)
  800890:	e8 b5 fa ff ff       	call   80034a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800895:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800898:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089e:	eb 05                	jmp    8008a5 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	e8 82 ff ff ff       	call   80084f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    
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
  800d93:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800daa:	e8 71 12 00 00       	call   802020 <_panic>

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
  800e52:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800e69:	e8 b2 11 00 00       	call   802020 <_panic>

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
  800eb0:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800ec7:	e8 54 11 00 00       	call   802020 <_panic>

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
  800f0e:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800f15:	00 
  800f16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1d:	00 
  800f1e:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800f25:	e8 f6 10 00 00       	call   802020 <_panic>

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
  800f6c:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800f83:	e8 98 10 00 00       	call   802020 <_panic>

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
  800fca:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800fe1:	e8 3a 10 00 00       	call   802020 <_panic>

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
  801028:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  80103f:	e8 dc 0f 00 00       	call   802020 <_panic>

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
  8010b9:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  8010c0:	00 
  8010c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  8010d0:	e8 4b 0f 00 00       	call   802020 <_panic>

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

00801114 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
  801119:	83 ec 10             	sub    $0x10,%esp
  80111c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80111f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801122:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801125:	85 db                	test   %ebx,%ebx
  801127:	74 06                	je     80112f <ipc_recv+0x1b>
  801129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80112f:	85 f6                	test   %esi,%esi
  801131:	74 06                	je     801139 <ipc_recv+0x25>
  801133:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801139:	85 c0                	test   %eax,%eax
  80113b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801140:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801143:	89 04 24             	mov    %eax,(%esp)
  801146:	e8 3a ff ff ff       	call   801085 <sys_ipc_recv>
    if (ret) return ret;
  80114b:	85 c0                	test   %eax,%eax
  80114d:	75 24                	jne    801173 <ipc_recv+0x5f>
    if (from_env_store)
  80114f:	85 db                	test   %ebx,%ebx
  801151:	74 0a                	je     80115d <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801153:	a1 04 40 80 00       	mov    0x804004,%eax
  801158:	8b 40 74             	mov    0x74(%eax),%eax
  80115b:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  80115d:	85 f6                	test   %esi,%esi
  80115f:	74 0a                	je     80116b <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801161:	a1 04 40 80 00       	mov    0x804004,%eax
  801166:	8b 40 78             	mov    0x78(%eax),%eax
  801169:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
  801170:	8b 40 70             	mov    0x70(%eax),%eax
}
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 1c             	sub    $0x1c,%esp
  801183:	8b 75 08             	mov    0x8(%ebp),%esi
  801186:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801189:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80118c:	85 db                	test   %ebx,%ebx
  80118e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801193:	0f 44 d8             	cmove  %eax,%ebx
  801196:	eb 2a                	jmp    8011c2 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801198:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80119b:	74 20                	je     8011bd <ipc_send+0x43>
  80119d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a1:	c7 44 24 08 ea 26 80 	movl   $0x8026ea,0x8(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8011b0:	00 
  8011b1:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8011b8:	e8 63 0e 00 00       	call   802020 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8011bd:	e8 2a fc ff ff       	call   800dec <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8011c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8011c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011d1:	89 34 24             	mov    %esi,(%esp)
  8011d4:	e8 78 fe ff ff       	call   801051 <sys_ipc_try_send>
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	75 bb                	jne    801198 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8011dd:	83 c4 1c             	add    $0x1c,%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8011eb:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8011f0:	39 c8                	cmp    %ecx,%eax
  8011f2:	74 19                	je     80120d <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011f4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 e2 07             	shl    $0x7,%edx
  8011fe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801204:	8b 52 50             	mov    0x50(%edx),%edx
  801207:	39 ca                	cmp    %ecx,%edx
  801209:	75 14                	jne    80121f <ipc_find_env+0x3a>
  80120b:	eb 05                	jmp    801212 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80120d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801212:	c1 e0 07             	shl    $0x7,%eax
  801215:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80121a:	8b 40 40             	mov    0x40(%eax),%eax
  80121d:	eb 0e                	jmp    80122d <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80121f:	83 c0 01             	add    $0x1,%eax
  801222:	3d 00 04 00 00       	cmp    $0x400,%eax
  801227:	75 d0                	jne    8011f9 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801229:	66 b8 00 00          	mov    $0x0,%ax
}
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    
	...

00801230 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	05 00 00 00 30       	add    $0x30000000,%eax
  80123b:	c1 e8 0c             	shr    $0xc,%eax
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	89 04 24             	mov    %eax,(%esp)
  80124c:	e8 df ff ff ff       	call   801230 <fd2num>
  801251:	05 20 00 0d 00       	add    $0xd0020,%eax
  801256:	c1 e0 0c             	shl    $0xc,%eax
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801262:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801267:	a8 01                	test   $0x1,%al
  801269:	74 34                	je     80129f <fd_alloc+0x44>
  80126b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801270:	a8 01                	test   $0x1,%al
  801272:	74 32                	je     8012a6 <fd_alloc+0x4b>
  801274:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801279:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80127b:	89 c2                	mov    %eax,%edx
  80127d:	c1 ea 16             	shr    $0x16,%edx
  801280:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801287:	f6 c2 01             	test   $0x1,%dl
  80128a:	74 1f                	je     8012ab <fd_alloc+0x50>
  80128c:	89 c2                	mov    %eax,%edx
  80128e:	c1 ea 0c             	shr    $0xc,%edx
  801291:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801298:	f6 c2 01             	test   $0x1,%dl
  80129b:	75 17                	jne    8012b4 <fd_alloc+0x59>
  80129d:	eb 0c                	jmp    8012ab <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80129f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012a4:	eb 05                	jmp    8012ab <fd_alloc+0x50>
  8012a6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012ab:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	eb 17                	jmp    8012cb <fd_alloc+0x70>
  8012b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012be:	75 b9                	jne    801279 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012cb:	5b                   	pop    %ebx
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d9:	83 fa 1f             	cmp    $0x1f,%edx
  8012dc:	77 3f                	ja     80131d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012de:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8012e4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e7:	89 d0                	mov    %edx,%eax
  8012e9:	c1 e8 16             	shr    $0x16,%eax
  8012ec:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f8:	f6 c1 01             	test   $0x1,%cl
  8012fb:	74 20                	je     80131d <fd_lookup+0x4f>
  8012fd:	89 d0                	mov    %edx,%eax
  8012ff:	c1 e8 0c             	shr    $0xc,%eax
  801302:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801309:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80130e:	f6 c1 01             	test   $0x1,%cl
  801311:	74 0a                	je     80131d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801313:	8b 45 0c             	mov    0xc(%ebp),%eax
  801316:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	83 ec 14             	sub    $0x14,%esp
  801326:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80132c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801331:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801337:	75 17                	jne    801350 <dev_lookup+0x31>
  801339:	eb 07                	jmp    801342 <dev_lookup+0x23>
  80133b:	39 0a                	cmp    %ecx,(%edx)
  80133d:	75 11                	jne    801350 <dev_lookup+0x31>
  80133f:	90                   	nop
  801340:	eb 05                	jmp    801347 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801342:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801347:	89 13                	mov    %edx,(%ebx)
			return 0;
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	eb 35                	jmp    801385 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801350:	83 c0 01             	add    $0x1,%eax
  801353:	8b 14 85 88 27 80 00 	mov    0x802788(,%eax,4),%edx
  80135a:	85 d2                	test   %edx,%edx
  80135c:	75 dd                	jne    80133b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80135e:	a1 04 40 80 00       	mov    0x804004,%eax
  801363:	8b 40 48             	mov    0x48(%eax),%eax
  801366:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136e:	c7 04 24 0c 27 80 00 	movl   $0x80270c,(%esp)
  801375:	e8 59 ee ff ff       	call   8001d3 <cprintf>
	*dev = 0;
  80137a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801380:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801385:	83 c4 14             	add    $0x14,%esp
  801388:	5b                   	pop    %ebx
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	83 ec 38             	sub    $0x38,%esp
  801391:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801394:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801397:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80139a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a1:	89 3c 24             	mov    %edi,(%esp)
  8013a4:	e8 87 fe ff ff       	call   801230 <fd2num>
  8013a9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8013ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013b0:	89 04 24             	mov    %eax,(%esp)
  8013b3:	e8 16 ff ff ff       	call   8012ce <fd_lookup>
  8013b8:	89 c3                	mov    %eax,%ebx
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 05                	js     8013c3 <fd_close+0x38>
	    || fd != fd2)
  8013be:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8013c1:	74 0e                	je     8013d1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013c3:	89 f0                	mov    %esi,%eax
  8013c5:	84 c0                	test   %al,%al
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cc:	0f 44 d8             	cmove  %eax,%ebx
  8013cf:	eb 3d                	jmp    80140e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013d1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	8b 07                	mov    (%edi),%eax
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	e8 3d ff ff ff       	call   80131f <dev_lookup>
  8013e2:	89 c3                	mov    %eax,%ebx
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 16                	js     8013fe <fd_close+0x73>
		if (dev->dev_close)
  8013e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013eb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ee:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	74 07                	je     8013fe <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8013f7:	89 3c 24             	mov    %edi,(%esp)
  8013fa:	ff d0                	call   *%eax
  8013fc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801402:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801409:	e8 cb fa ff ff       	call   800ed9 <sys_page_unmap>
	return r;
}
  80140e:	89 d8                	mov    %ebx,%eax
  801410:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801413:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801416:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801419:	89 ec                	mov    %ebp,%esp
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801423:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801426:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142a:	8b 45 08             	mov    0x8(%ebp),%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 99 fe ff ff       	call   8012ce <fd_lookup>
  801435:	85 c0                	test   %eax,%eax
  801437:	78 13                	js     80144c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801439:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801440:	00 
  801441:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801444:	89 04 24             	mov    %eax,(%esp)
  801447:	e8 3f ff ff ff       	call   80138b <fd_close>
}
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <close_all>:

void
close_all(void)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	53                   	push   %ebx
  801452:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801455:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80145a:	89 1c 24             	mov    %ebx,(%esp)
  80145d:	e8 bb ff ff ff       	call   80141d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801462:	83 c3 01             	add    $0x1,%ebx
  801465:	83 fb 20             	cmp    $0x20,%ebx
  801468:	75 f0                	jne    80145a <close_all+0xc>
		close(i);
}
  80146a:	83 c4 14             	add    $0x14,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 58             	sub    $0x58,%esp
  801476:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801479:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80147c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80147f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801482:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801485:	89 44 24 04          	mov    %eax,0x4(%esp)
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	89 04 24             	mov    %eax,(%esp)
  80148f:	e8 3a fe ff ff       	call   8012ce <fd_lookup>
  801494:	89 c3                	mov    %eax,%ebx
  801496:	85 c0                	test   %eax,%eax
  801498:	0f 88 e1 00 00 00    	js     80157f <dup+0x10f>
		return r;
	close(newfdnum);
  80149e:	89 3c 24             	mov    %edi,(%esp)
  8014a1:	e8 77 ff ff ff       	call   80141d <close>

	newfd = INDEX2FD(newfdnum);
  8014a6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014ac:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b2:	89 04 24             	mov    %eax,(%esp)
  8014b5:	e8 86 fd ff ff       	call   801240 <fd2data>
  8014ba:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014bc:	89 34 24             	mov    %esi,(%esp)
  8014bf:	e8 7c fd ff ff       	call   801240 <fd2data>
  8014c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	c1 e8 16             	shr    $0x16,%eax
  8014cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d3:	a8 01                	test   $0x1,%al
  8014d5:	74 46                	je     80151d <dup+0xad>
  8014d7:	89 d8                	mov    %ebx,%eax
  8014d9:	c1 e8 0c             	shr    $0xc,%eax
  8014dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e3:	f6 c2 01             	test   $0x1,%dl
  8014e6:	74 35                	je     80151d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801506:	00 
  801507:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80150b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801512:	e8 64 f9 ff ff       	call   800e7b <sys_page_map>
  801517:	89 c3                	mov    %eax,%ebx
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 3b                	js     801558 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80151d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801520:	89 c2                	mov    %eax,%edx
  801522:	c1 ea 0c             	shr    $0xc,%edx
  801525:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80152c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801532:	89 54 24 10          	mov    %edx,0x10(%esp)
  801536:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80153a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801541:	00 
  801542:	89 44 24 04          	mov    %eax,0x4(%esp)
  801546:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80154d:	e8 29 f9 ff ff       	call   800e7b <sys_page_map>
  801552:	89 c3                	mov    %eax,%ebx
  801554:	85 c0                	test   %eax,%eax
  801556:	79 25                	jns    80157d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801558:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801563:	e8 71 f9 ff ff       	call   800ed9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80156b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801576:	e8 5e f9 ff ff       	call   800ed9 <sys_page_unmap>
	return r;
  80157b:	eb 02                	jmp    80157f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80157d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80157f:	89 d8                	mov    %ebx,%eax
  801581:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801584:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801587:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80158a:	89 ec                	mov    %ebp,%esp
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 24             	sub    $0x24,%esp
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801598:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159f:	89 1c 24             	mov    %ebx,(%esp)
  8015a2:	e8 27 fd ff ff       	call   8012ce <fd_lookup>
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 6d                	js     801618 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	8b 00                	mov    (%eax),%eax
  8015b7:	89 04 24             	mov    %eax,(%esp)
  8015ba:	e8 60 fd ff ff       	call   80131f <dev_lookup>
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 55                	js     801618 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c6:	8b 50 08             	mov    0x8(%eax),%edx
  8015c9:	83 e2 03             	and    $0x3,%edx
  8015cc:	83 fa 01             	cmp    $0x1,%edx
  8015cf:	75 23                	jne    8015f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d6:	8b 40 48             	mov    0x48(%eax),%eax
  8015d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e1:	c7 04 24 4d 27 80 00 	movl   $0x80274d,(%esp)
  8015e8:	e8 e6 eb ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  8015ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f2:	eb 24                	jmp    801618 <read+0x8a>
	}
	if (!dev->dev_read)
  8015f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f7:	8b 52 08             	mov    0x8(%edx),%edx
  8015fa:	85 d2                	test   %edx,%edx
  8015fc:	74 15                	je     801613 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8015fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801601:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801605:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801608:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80160c:	89 04 24             	mov    %eax,(%esp)
  80160f:	ff d2                	call   *%edx
  801611:	eb 05                	jmp    801618 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801613:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801618:	83 c4 24             	add    $0x24,%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	57                   	push   %edi
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 1c             	sub    $0x1c,%esp
  801627:	8b 7d 08             	mov    0x8(%ebp),%edi
  80162a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162d:	b8 00 00 00 00       	mov    $0x0,%eax
  801632:	85 f6                	test   %esi,%esi
  801634:	74 30                	je     801666 <readn+0x48>
  801636:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163b:	89 f2                	mov    %esi,%edx
  80163d:	29 c2                	sub    %eax,%edx
  80163f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801643:	03 45 0c             	add    0xc(%ebp),%eax
  801646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164a:	89 3c 24             	mov    %edi,(%esp)
  80164d:	e8 3c ff ff ff       	call   80158e <read>
		if (m < 0)
  801652:	85 c0                	test   %eax,%eax
  801654:	78 10                	js     801666 <readn+0x48>
			return m;
		if (m == 0)
  801656:	85 c0                	test   %eax,%eax
  801658:	74 0a                	je     801664 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165a:	01 c3                	add    %eax,%ebx
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	39 f3                	cmp    %esi,%ebx
  801660:	72 d9                	jb     80163b <readn+0x1d>
  801662:	eb 02                	jmp    801666 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801664:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801666:	83 c4 1c             	add    $0x1c,%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 24             	sub    $0x24,%esp
  801675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167f:	89 1c 24             	mov    %ebx,(%esp)
  801682:	e8 47 fc ff ff       	call   8012ce <fd_lookup>
  801687:	85 c0                	test   %eax,%eax
  801689:	78 68                	js     8016f3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	8b 00                	mov    (%eax),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 80 fc ff ff       	call   80131f <dev_lookup>
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 50                	js     8016f3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016aa:	75 23                	jne    8016cf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b1:	8b 40 48             	mov    0x48(%eax),%eax
  8016b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	c7 04 24 69 27 80 00 	movl   $0x802769,(%esp)
  8016c3:	e8 0b eb ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  8016c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cd:	eb 24                	jmp    8016f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d5:	85 d2                	test   %edx,%edx
  8016d7:	74 15                	je     8016ee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016dc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	ff d2                	call   *%edx
  8016ec:	eb 05                	jmp    8016f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016f3:	83 c4 24             	add    $0x24,%esp
  8016f6:	5b                   	pop    %ebx
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ff:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	8b 45 08             	mov    0x8(%ebp),%eax
  801709:	89 04 24             	mov    %eax,(%esp)
  80170c:	e8 bd fb ff ff       	call   8012ce <fd_lookup>
  801711:	85 c0                	test   %eax,%eax
  801713:	78 0e                	js     801723 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801715:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801718:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80171e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	53                   	push   %ebx
  801729:	83 ec 24             	sub    $0x24,%esp
  80172c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801732:	89 44 24 04          	mov    %eax,0x4(%esp)
  801736:	89 1c 24             	mov    %ebx,(%esp)
  801739:	e8 90 fb ff ff       	call   8012ce <fd_lookup>
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 61                	js     8017a3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	89 44 24 04          	mov    %eax,0x4(%esp)
  801749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174c:	8b 00                	mov    (%eax),%eax
  80174e:	89 04 24             	mov    %eax,(%esp)
  801751:	e8 c9 fb ff ff       	call   80131f <dev_lookup>
  801756:	85 c0                	test   %eax,%eax
  801758:	78 49                	js     8017a3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801761:	75 23                	jne    801786 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801763:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801768:	8b 40 48             	mov    0x48(%eax),%eax
  80176b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80176f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801773:	c7 04 24 2c 27 80 00 	movl   $0x80272c,(%esp)
  80177a:	e8 54 ea ff ff       	call   8001d3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80177f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801784:	eb 1d                	jmp    8017a3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801786:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801789:	8b 52 18             	mov    0x18(%edx),%edx
  80178c:	85 d2                	test   %edx,%edx
  80178e:	74 0e                	je     80179e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801793:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801797:	89 04 24             	mov    %eax,(%esp)
  80179a:	ff d2                	call   *%edx
  80179c:	eb 05                	jmp    8017a3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80179e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a3:	83 c4 24             	add    $0x24,%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 24             	sub    $0x24,%esp
  8017b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	89 04 24             	mov    %eax,(%esp)
  8017c0:	e8 09 fb ff ff       	call   8012ce <fd_lookup>
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 52                	js     80181b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	8b 00                	mov    (%eax),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 42 fb ff ff       	call   80131f <dev_lookup>
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 3a                	js     80181b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017e8:	74 2c                	je     801816 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f4:	00 00 00 
	stat->st_isdir = 0;
  8017f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017fe:	00 00 00 
	stat->st_dev = dev;
  801801:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801807:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80180b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80180e:	89 14 24             	mov    %edx,(%esp)
  801811:	ff 50 14             	call   *0x14(%eax)
  801814:	eb 05                	jmp    80181b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801816:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80181b:	83 c4 24             	add    $0x24,%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 18             	sub    $0x18,%esp
  801827:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80182a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80182d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801834:	00 
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	89 04 24             	mov    %eax,(%esp)
  80183b:	e8 bc 01 00 00       	call   8019fc <open>
  801840:	89 c3                	mov    %eax,%ebx
  801842:	85 c0                	test   %eax,%eax
  801844:	78 1b                	js     801861 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801846:	8b 45 0c             	mov    0xc(%ebp),%eax
  801849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184d:	89 1c 24             	mov    %ebx,(%esp)
  801850:	e8 54 ff ff ff       	call   8017a9 <fstat>
  801855:	89 c6                	mov    %eax,%esi
	close(fd);
  801857:	89 1c 24             	mov    %ebx,(%esp)
  80185a:	e8 be fb ff ff       	call   80141d <close>
	return r;
  80185f:	89 f3                	mov    %esi,%ebx
}
  801861:	89 d8                	mov    %ebx,%eax
  801863:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801866:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801869:	89 ec                	mov    %ebp,%esp
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    
  80186d:	00 00                	add    %al,(%eax)
	...

00801870 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 18             	sub    $0x18,%esp
  801876:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801879:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801880:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801887:	75 11                	jne    80189a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801889:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801890:	e8 50 f9 ff ff       	call   8011e5 <ipc_find_env>
  801895:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80189a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018a1:	00 
  8018a2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018a9:	00 
  8018aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ae:	a1 00 40 80 00       	mov    0x804000,%eax
  8018b3:	89 04 24             	mov    %eax,(%esp)
  8018b6:	e8 bf f8 ff ff       	call   80117a <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8018bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018c2:	00 
  8018c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ce:	e8 41 f8 ff ff       	call   801114 <ipc_recv>
}
  8018d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018d6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018d9:	89 ec                	mov    %ebp,%esp
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 14             	sub    $0x14,%esp
  8018e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fc:	e8 6f ff ff ff       	call   801870 <fsipc>
  801901:	85 c0                	test   %eax,%eax
  801903:	78 2b                	js     801930 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801905:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80190c:	00 
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 06 f0 ff ff       	call   80091b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801915:	a1 80 50 80 00       	mov    0x805080,%eax
  80191a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801920:	a1 84 50 80 00       	mov    0x805084,%eax
  801925:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80192b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801930:	83 c4 14             	add    $0x14,%esp
  801933:	5b                   	pop    %ebx
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	8b 40 0c             	mov    0xc(%eax),%eax
  801942:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801947:	ba 00 00 00 00       	mov    $0x0,%edx
  80194c:	b8 06 00 00 00       	mov    $0x6,%eax
  801951:	e8 1a ff ff ff       	call   801870 <fsipc>
}
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	56                   	push   %esi
  80195c:	53                   	push   %ebx
  80195d:	83 ec 10             	sub    $0x10,%esp
  801960:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	8b 40 0c             	mov    0xc(%eax),%eax
  801969:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80196e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 03 00 00 00       	mov    $0x3,%eax
  80197e:	e8 ed fe ff ff       	call   801870 <fsipc>
  801983:	89 c3                	mov    %eax,%ebx
  801985:	85 c0                	test   %eax,%eax
  801987:	78 6a                	js     8019f3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801989:	39 c6                	cmp    %eax,%esi
  80198b:	73 24                	jae    8019b1 <devfile_read+0x59>
  80198d:	c7 44 24 0c 98 27 80 	movl   $0x802798,0xc(%esp)
  801994:	00 
  801995:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  80199c:	00 
  80199d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8019a4:	00 
  8019a5:	c7 04 24 b4 27 80 00 	movl   $0x8027b4,(%esp)
  8019ac:	e8 6f 06 00 00       	call   802020 <_panic>
	assert(r <= PGSIZE);
  8019b1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019b6:	7e 24                	jle    8019dc <devfile_read+0x84>
  8019b8:	c7 44 24 0c bf 27 80 	movl   $0x8027bf,0xc(%esp)
  8019bf:	00 
  8019c0:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  8019c7:	00 
  8019c8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019cf:	00 
  8019d0:	c7 04 24 b4 27 80 00 	movl   $0x8027b4,(%esp)
  8019d7:	e8 44 06 00 00       	call   802020 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019e7:	00 
  8019e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019eb:	89 04 24             	mov    %eax,(%esp)
  8019ee:	e8 19 f1 ff ff       	call   800b0c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  8019f3:	89 d8                	mov    %ebx,%eax
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	5b                   	pop    %ebx
  8019f9:	5e                   	pop    %esi
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	83 ec 20             	sub    $0x20,%esp
  801a04:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a07:	89 34 24             	mov    %esi,(%esp)
  801a0a:	e8 c1 ee ff ff       	call   8008d0 <strlen>
		return -E_BAD_PATH;
  801a0f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a14:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a19:	7f 5e                	jg     801a79 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1e:	89 04 24             	mov    %eax,(%esp)
  801a21:	e8 35 f8 ff ff       	call   80125b <fd_alloc>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 4d                	js     801a79 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a30:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a37:	e8 df ee ff ff       	call   80091b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a47:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4c:	e8 1f fe ff ff       	call   801870 <fsipc>
  801a51:	89 c3                	mov    %eax,%ebx
  801a53:	85 c0                	test   %eax,%eax
  801a55:	79 15                	jns    801a6c <open+0x70>
		fd_close(fd, 0);
  801a57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a5e:	00 
  801a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a62:	89 04 24             	mov    %eax,(%esp)
  801a65:	e8 21 f9 ff ff       	call   80138b <fd_close>
		return r;
  801a6a:	eb 0d                	jmp    801a79 <open+0x7d>
	}

	return fd2num(fd);
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	89 04 24             	mov    %eax,(%esp)
  801a72:	e8 b9 f7 ff ff       	call   801230 <fd2num>
  801a77:	89 c3                	mov    %eax,%ebx
}
  801a79:	89 d8                	mov    %ebx,%eax
  801a7b:	83 c4 20             	add    $0x20,%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    
	...

00801a90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 18             	sub    $0x18,%esp
  801a96:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a99:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	e8 96 f7 ff ff       	call   801240 <fd2data>
  801aaa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801aac:	c7 44 24 04 cb 27 80 	movl   $0x8027cb,0x4(%esp)
  801ab3:	00 
  801ab4:	89 34 24             	mov    %esi,(%esp)
  801ab7:	e8 5f ee ff ff       	call   80091b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801abc:	8b 43 04             	mov    0x4(%ebx),%eax
  801abf:	2b 03                	sub    (%ebx),%eax
  801ac1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ac7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ace:	00 00 00 
	stat->st_dev = &devpipe;
  801ad1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801ad8:	30 80 00 
	return 0;
}
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ae3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ae6:	89 ec                	mov    %ebp,%esp
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	53                   	push   %ebx
  801aee:	83 ec 14             	sub    $0x14,%esp
  801af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801af8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aff:	e8 d5 f3 ff ff       	call   800ed9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b04:	89 1c 24             	mov    %ebx,(%esp)
  801b07:	e8 34 f7 ff ff       	call   801240 <fd2data>
  801b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b17:	e8 bd f3 ff ff       	call   800ed9 <sys_page_unmap>
}
  801b1c:	83 c4 14             	add    $0x14,%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 2c             	sub    $0x2c,%esp
  801b2b:	89 c7                	mov    %eax,%edi
  801b2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b30:	a1 04 40 80 00       	mov    0x804004,%eax
  801b35:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b38:	89 3c 24             	mov    %edi,(%esp)
  801b3b:	e8 38 05 00 00       	call   802078 <pageref>
  801b40:	89 c6                	mov    %eax,%esi
  801b42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 2b 05 00 00       	call   802078 <pageref>
  801b4d:	39 c6                	cmp    %eax,%esi
  801b4f:	0f 94 c0             	sete   %al
  801b52:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b55:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b5b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b5e:	39 cb                	cmp    %ecx,%ebx
  801b60:	75 08                	jne    801b6a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b62:	83 c4 2c             	add    $0x2c,%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b6a:	83 f8 01             	cmp    $0x1,%eax
  801b6d:	75 c1                	jne    801b30 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b6f:	8b 52 58             	mov    0x58(%edx),%edx
  801b72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b76:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b7e:	c7 04 24 d2 27 80 00 	movl   $0x8027d2,(%esp)
  801b85:	e8 49 e6 ff ff       	call   8001d3 <cprintf>
  801b8a:	eb a4                	jmp    801b30 <_pipeisclosed+0xe>

00801b8c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	57                   	push   %edi
  801b90:	56                   	push   %esi
  801b91:	53                   	push   %ebx
  801b92:	83 ec 2c             	sub    $0x2c,%esp
  801b95:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b98:	89 34 24             	mov    %esi,(%esp)
  801b9b:	e8 a0 f6 ff ff       	call   801240 <fd2data>
  801ba0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bab:	75 50                	jne    801bfd <devpipe_write+0x71>
  801bad:	eb 5c                	jmp    801c0b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801baf:	89 da                	mov    %ebx,%edx
  801bb1:	89 f0                	mov    %esi,%eax
  801bb3:	e8 6a ff ff ff       	call   801b22 <_pipeisclosed>
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	75 53                	jne    801c0f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bbc:	e8 2b f2 ff ff       	call   800dec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc1:	8b 43 04             	mov    0x4(%ebx),%eax
  801bc4:	8b 13                	mov    (%ebx),%edx
  801bc6:	83 c2 20             	add    $0x20,%edx
  801bc9:	39 d0                	cmp    %edx,%eax
  801bcb:	73 e2                	jae    801baf <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801bd4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801bd7:	89 c2                	mov    %eax,%edx
  801bd9:	c1 fa 1f             	sar    $0x1f,%edx
  801bdc:	c1 ea 1b             	shr    $0x1b,%edx
  801bdf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801be2:	83 e1 1f             	and    $0x1f,%ecx
  801be5:	29 d1                	sub    %edx,%ecx
  801be7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801beb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801bef:	83 c0 01             	add    $0x1,%eax
  801bf2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf5:	83 c7 01             	add    $0x1,%edi
  801bf8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bfb:	74 0e                	je     801c0b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bfd:	8b 43 04             	mov    0x4(%ebx),%eax
  801c00:	8b 13                	mov    (%ebx),%edx
  801c02:	83 c2 20             	add    $0x20,%edx
  801c05:	39 d0                	cmp    %edx,%eax
  801c07:	73 a6                	jae    801baf <devpipe_write+0x23>
  801c09:	eb c2                	jmp    801bcd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c0b:	89 f8                	mov    %edi,%eax
  801c0d:	eb 05                	jmp    801c14 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c14:	83 c4 2c             	add    $0x2c,%esp
  801c17:	5b                   	pop    %ebx
  801c18:	5e                   	pop    %esi
  801c19:	5f                   	pop    %edi
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	83 ec 28             	sub    $0x28,%esp
  801c22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c28:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c2b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c2e:	89 3c 24             	mov    %edi,(%esp)
  801c31:	e8 0a f6 ff ff       	call   801240 <fd2data>
  801c36:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c38:	be 00 00 00 00       	mov    $0x0,%esi
  801c3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c41:	75 47                	jne    801c8a <devpipe_read+0x6e>
  801c43:	eb 52                	jmp    801c97 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c45:	89 f0                	mov    %esi,%eax
  801c47:	eb 5e                	jmp    801ca7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c49:	89 da                	mov    %ebx,%edx
  801c4b:	89 f8                	mov    %edi,%eax
  801c4d:	8d 76 00             	lea    0x0(%esi),%esi
  801c50:	e8 cd fe ff ff       	call   801b22 <_pipeisclosed>
  801c55:	85 c0                	test   %eax,%eax
  801c57:	75 49                	jne    801ca2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801c59:	e8 8e f1 ff ff       	call   800dec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c5e:	8b 03                	mov    (%ebx),%eax
  801c60:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c63:	74 e4                	je     801c49 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c65:	89 c2                	mov    %eax,%edx
  801c67:	c1 fa 1f             	sar    $0x1f,%edx
  801c6a:	c1 ea 1b             	shr    $0x1b,%edx
  801c6d:	01 d0                	add    %edx,%eax
  801c6f:	83 e0 1f             	and    $0x1f,%eax
  801c72:	29 d0                	sub    %edx,%eax
  801c74:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c7f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c82:	83 c6 01             	add    $0x1,%esi
  801c85:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c88:	74 0d                	je     801c97 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801c8a:	8b 03                	mov    (%ebx),%eax
  801c8c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c8f:	75 d4                	jne    801c65 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c91:	85 f6                	test   %esi,%esi
  801c93:	75 b0                	jne    801c45 <devpipe_read+0x29>
  801c95:	eb b2                	jmp    801c49 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c97:	89 f0                	mov    %esi,%eax
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	eb 05                	jmp    801ca7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801caa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cb0:	89 ec                	mov    %ebp,%esp
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 48             	sub    $0x48,%esp
  801cba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801cbd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801cc0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801cc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801cc9:	89 04 24             	mov    %eax,(%esp)
  801ccc:	e8 8a f5 ff ff       	call   80125b <fd_alloc>
  801cd1:	89 c3                	mov    %eax,%ebx
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	0f 88 45 01 00 00    	js     801e20 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ce2:	00 
  801ce3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf1:	e8 26 f1 ff ff       	call   800e1c <sys_page_alloc>
  801cf6:	89 c3                	mov    %eax,%ebx
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	0f 88 20 01 00 00    	js     801e20 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d00:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d03:	89 04 24             	mov    %eax,(%esp)
  801d06:	e8 50 f5 ff ff       	call   80125b <fd_alloc>
  801d0b:	89 c3                	mov    %eax,%ebx
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	0f 88 f8 00 00 00    	js     801e0d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d15:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d1c:	00 
  801d1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2b:	e8 ec f0 ff ff       	call   800e1c <sys_page_alloc>
  801d30:	89 c3                	mov    %eax,%ebx
  801d32:	85 c0                	test   %eax,%eax
  801d34:	0f 88 d3 00 00 00    	js     801e0d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3d:	89 04 24             	mov    %eax,(%esp)
  801d40:	e8 fb f4 ff ff       	call   801240 <fd2data>
  801d45:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d47:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d4e:	00 
  801d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5a:	e8 bd f0 ff ff       	call   800e1c <sys_page_alloc>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	85 c0                	test   %eax,%eax
  801d63:	0f 88 91 00 00 00    	js     801dfa <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d6c:	89 04 24             	mov    %eax,(%esp)
  801d6f:	e8 cc f4 ff ff       	call   801240 <fd2data>
  801d74:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d7b:	00 
  801d7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d87:	00 
  801d88:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d93:	e8 e3 f0 ff ff       	call   800e7b <sys_page_map>
  801d98:	89 c3                	mov    %eax,%ebx
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 4c                	js     801dea <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d9e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801da4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801da7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801db3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801db9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dbc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dc1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dcb:	89 04 24             	mov    %eax,(%esp)
  801dce:	e8 5d f4 ff ff       	call   801230 <fd2num>
  801dd3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801dd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dd8:	89 04 24             	mov    %eax,(%esp)
  801ddb:	e8 50 f4 ff ff       	call   801230 <fd2num>
  801de0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de8:	eb 36                	jmp    801e20 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801dea:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df5:	e8 df f0 ff ff       	call   800ed9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801dfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e08:	e8 cc f0 ff ff       	call   800ed9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1b:	e8 b9 f0 ff ff       	call   800ed9 <sys_page_unmap>
    err:
	return r;
}
  801e20:	89 d8                	mov    %ebx,%eax
  801e22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801e2b:	89 ec                	mov    %ebp,%esp
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	89 04 24             	mov    %eax,(%esp)
  801e42:	e8 87 f4 ff ff       	call   8012ce <fd_lookup>
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 15                	js     801e60 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4e:	89 04 24             	mov    %eax,(%esp)
  801e51:	e8 ea f3 ff ff       	call   801240 <fd2data>
	return _pipeisclosed(fd, p);
  801e56:	89 c2                	mov    %eax,%edx
  801e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5b:	e8 c2 fc ff ff       	call   801b22 <_pipeisclosed>
}
  801e60:	c9                   	leave  
  801e61:	c3                   	ret    
	...

00801e70 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
  801e78:	5d                   	pop    %ebp
  801e79:	c3                   	ret    

00801e7a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801e80:	c7 44 24 04 ea 27 80 	movl   $0x8027ea,0x4(%esp)
  801e87:	00 
  801e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8b:	89 04 24             	mov    %eax,(%esp)
  801e8e:	e8 88 ea ff ff       	call   80091b <strcpy>
	return 0;
}
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    

00801e9a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	57                   	push   %edi
  801e9e:	56                   	push   %esi
  801e9f:	53                   	push   %ebx
  801ea0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea6:	be 00 00 00 00       	mov    $0x0,%esi
  801eab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eaf:	74 43                	je     801ef4 <devcons_write+0x5a>
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ebf:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ec1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ec4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ec9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ecc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ed0:	03 45 0c             	add    0xc(%ebp),%eax
  801ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed7:	89 3c 24             	mov    %edi,(%esp)
  801eda:	e8 2d ec ff ff       	call   800b0c <memmove>
		sys_cputs(buf, m);
  801edf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ee3:	89 3c 24             	mov    %edi,(%esp)
  801ee6:	e8 15 ee ff ff       	call   800d00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eeb:	01 de                	add    %ebx,%esi
  801eed:	89 f0                	mov    %esi,%eax
  801eef:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef2:	72 c8                	jb     801ebc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ef4:	89 f0                	mov    %esi,%eax
  801ef6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5f                   	pop    %edi
  801eff:	5d                   	pop    %ebp
  801f00:	c3                   	ret    

00801f01 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801f07:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801f0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f10:	75 07                	jne    801f19 <devcons_read+0x18>
  801f12:	eb 31                	jmp    801f45 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f14:	e8 d3 ee ff ff       	call   800dec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f20:	e8 0a ee ff ff       	call   800d2f <sys_cgetc>
  801f25:	85 c0                	test   %eax,%eax
  801f27:	74 eb                	je     801f14 <devcons_read+0x13>
  801f29:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 16                	js     801f45 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f2f:	83 f8 04             	cmp    $0x4,%eax
  801f32:	74 0c                	je     801f40 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	88 10                	mov    %dl,(%eax)
	return 1;
  801f39:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3e:	eb 05                	jmp    801f45 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f50:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f53:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f5a:	00 
  801f5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f5e:	89 04 24             	mov    %eax,(%esp)
  801f61:	e8 9a ed ff ff       	call   800d00 <sys_cputs>
}
  801f66:	c9                   	leave  
  801f67:	c3                   	ret    

00801f68 <getchar>:

int
getchar(void)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f6e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801f75:	00 
  801f76:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f84:	e8 05 f6 ff ff       	call   80158e <read>
	if (r < 0)
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 0f                	js     801f9c <getchar+0x34>
		return r;
	if (r < 1)
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	7e 06                	jle    801f97 <getchar+0x2f>
		return -E_EOF;
	return c;
  801f91:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f95:	eb 05                	jmp    801f9c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f97:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f9c:	c9                   	leave  
  801f9d:	c3                   	ret    

00801f9e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 18 f3 ff ff       	call   8012ce <fd_lookup>
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 11                	js     801fcb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fc3:	39 10                	cmp    %edx,(%eax)
  801fc5:	0f 94 c0             	sete   %al
  801fc8:	0f b6 c0             	movzbl %al,%eax
}
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <opencons>:

int
opencons(void)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd6:	89 04 24             	mov    %eax,(%esp)
  801fd9:	e8 7d f2 ff ff       	call   80125b <fd_alloc>
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	78 3c                	js     80201e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fe9:	00 
  801fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff8:	e8 1f ee ff ff       	call   800e1c <sys_page_alloc>
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 1d                	js     80201e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802001:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802007:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802016:	89 04 24             	mov    %eax,(%esp)
  802019:	e8 12 f2 ff ff       	call   801230 <fd2num>
}
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802028:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80202b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802031:	e8 86 ed ff ff       	call   800dbc <sys_getenvid>
  802036:	8b 55 0c             	mov    0xc(%ebp),%edx
  802039:	89 54 24 10          	mov    %edx,0x10(%esp)
  80203d:	8b 55 08             	mov    0x8(%ebp),%edx
  802040:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802044:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204c:	c7 04 24 f8 27 80 00 	movl   $0x8027f8,(%esp)
  802053:	e8 7b e1 ff ff       	call   8001d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802058:	89 74 24 04          	mov    %esi,0x4(%esp)
  80205c:	8b 45 10             	mov    0x10(%ebp),%eax
  80205f:	89 04 24             	mov    %eax,(%esp)
  802062:	e8 0b e1 ff ff       	call   800172 <vcprintf>
	cprintf("\n");
  802067:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
  80206e:	e8 60 e1 ff ff       	call   8001d3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802073:	cc                   	int3   
  802074:	eb fd                	jmp    802073 <_panic+0x53>
	...

00802078 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207e:	89 d0                	mov    %edx,%eax
  802080:	c1 e8 16             	shr    $0x16,%eax
  802083:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80208a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208f:	f6 c1 01             	test   $0x1,%cl
  802092:	74 1d                	je     8020b1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802094:	c1 ea 0c             	shr    $0xc,%edx
  802097:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80209e:	f6 c2 01             	test   $0x1,%dl
  8020a1:	74 0e                	je     8020b1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020a3:	c1 ea 0c             	shr    $0xc,%edx
  8020a6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020ad:	ef 
  8020ae:	0f b7 c0             	movzwl %ax,%eax
}
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    
	...

008020c0 <__udivdi3>:
  8020c0:	83 ec 1c             	sub    $0x1c,%esp
  8020c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8020c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8020cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8020cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020d3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8020d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8020e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e5:	89 cd                	mov    %ecx,%ebp
  8020e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020eb:	75 33                	jne    802120 <__udivdi3+0x60>
  8020ed:	39 f1                	cmp    %esi,%ecx
  8020ef:	77 57                	ja     802148 <__udivdi3+0x88>
  8020f1:	85 c9                	test   %ecx,%ecx
  8020f3:	75 0b                	jne    802100 <__udivdi3+0x40>
  8020f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fa:	31 d2                	xor    %edx,%edx
  8020fc:	f7 f1                	div    %ecx
  8020fe:	89 c1                	mov    %eax,%ecx
  802100:	89 f0                	mov    %esi,%eax
  802102:	31 d2                	xor    %edx,%edx
  802104:	f7 f1                	div    %ecx
  802106:	89 c6                	mov    %eax,%esi
  802108:	8b 44 24 04          	mov    0x4(%esp),%eax
  80210c:	f7 f1                	div    %ecx
  80210e:	89 f2                	mov    %esi,%edx
  802110:	8b 74 24 10          	mov    0x10(%esp),%esi
  802114:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802118:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	c3                   	ret    
  802120:	31 d2                	xor    %edx,%edx
  802122:	31 c0                	xor    %eax,%eax
  802124:	39 f7                	cmp    %esi,%edi
  802126:	77 e8                	ja     802110 <__udivdi3+0x50>
  802128:	0f bd cf             	bsr    %edi,%ecx
  80212b:	83 f1 1f             	xor    $0x1f,%ecx
  80212e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802132:	75 2c                	jne    802160 <__udivdi3+0xa0>
  802134:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802138:	76 04                	jbe    80213e <__udivdi3+0x7e>
  80213a:	39 f7                	cmp    %esi,%edi
  80213c:	73 d2                	jae    802110 <__udivdi3+0x50>
  80213e:	31 d2                	xor    %edx,%edx
  802140:	b8 01 00 00 00       	mov    $0x1,%eax
  802145:	eb c9                	jmp    802110 <__udivdi3+0x50>
  802147:	90                   	nop
  802148:	89 f2                	mov    %esi,%edx
  80214a:	f7 f1                	div    %ecx
  80214c:	31 d2                	xor    %edx,%edx
  80214e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802152:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802156:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	c3                   	ret    
  80215e:	66 90                	xchg   %ax,%ax
  802160:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802165:	b8 20 00 00 00       	mov    $0x20,%eax
  80216a:	89 ea                	mov    %ebp,%edx
  80216c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802170:	d3 e7                	shl    %cl,%edi
  802172:	89 c1                	mov    %eax,%ecx
  802174:	d3 ea                	shr    %cl,%edx
  802176:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80217b:	09 fa                	or     %edi,%edx
  80217d:	89 f7                	mov    %esi,%edi
  80217f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802183:	89 f2                	mov    %esi,%edx
  802185:	8b 74 24 08          	mov    0x8(%esp),%esi
  802189:	d3 e5                	shl    %cl,%ebp
  80218b:	89 c1                	mov    %eax,%ecx
  80218d:	d3 ef                	shr    %cl,%edi
  80218f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802194:	d3 e2                	shl    %cl,%edx
  802196:	89 c1                	mov    %eax,%ecx
  802198:	d3 ee                	shr    %cl,%esi
  80219a:	09 d6                	or     %edx,%esi
  80219c:	89 fa                	mov    %edi,%edx
  80219e:	89 f0                	mov    %esi,%eax
  8021a0:	f7 74 24 0c          	divl   0xc(%esp)
  8021a4:	89 d7                	mov    %edx,%edi
  8021a6:	89 c6                	mov    %eax,%esi
  8021a8:	f7 e5                	mul    %ebp
  8021aa:	39 d7                	cmp    %edx,%edi
  8021ac:	72 22                	jb     8021d0 <__udivdi3+0x110>
  8021ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8021b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021b7:	d3 e5                	shl    %cl,%ebp
  8021b9:	39 c5                	cmp    %eax,%ebp
  8021bb:	73 04                	jae    8021c1 <__udivdi3+0x101>
  8021bd:	39 d7                	cmp    %edx,%edi
  8021bf:	74 0f                	je     8021d0 <__udivdi3+0x110>
  8021c1:	89 f0                	mov    %esi,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	e9 46 ff ff ff       	jmp    802110 <__udivdi3+0x50>
  8021ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	c3                   	ret    
	...

008021f0 <__umoddi3>:
  8021f0:	83 ec 1c             	sub    $0x1c,%esp
  8021f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8021f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8021fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8021ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  802203:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802207:	8b 74 24 24          	mov    0x24(%esp),%esi
  80220b:	85 ed                	test   %ebp,%ebp
  80220d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802211:	89 44 24 08          	mov    %eax,0x8(%esp)
  802215:	89 cf                	mov    %ecx,%edi
  802217:	89 04 24             	mov    %eax,(%esp)
  80221a:	89 f2                	mov    %esi,%edx
  80221c:	75 1a                	jne    802238 <__umoddi3+0x48>
  80221e:	39 f1                	cmp    %esi,%ecx
  802220:	76 4e                	jbe    802270 <__umoddi3+0x80>
  802222:	f7 f1                	div    %ecx
  802224:	89 d0                	mov    %edx,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	8b 74 24 10          	mov    0x10(%esp),%esi
  80222c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802230:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	c3                   	ret    
  802238:	39 f5                	cmp    %esi,%ebp
  80223a:	77 54                	ja     802290 <__umoddi3+0xa0>
  80223c:	0f bd c5             	bsr    %ebp,%eax
  80223f:	83 f0 1f             	xor    $0x1f,%eax
  802242:	89 44 24 04          	mov    %eax,0x4(%esp)
  802246:	75 60                	jne    8022a8 <__umoddi3+0xb8>
  802248:	3b 0c 24             	cmp    (%esp),%ecx
  80224b:	0f 87 07 01 00 00    	ja     802358 <__umoddi3+0x168>
  802251:	89 f2                	mov    %esi,%edx
  802253:	8b 34 24             	mov    (%esp),%esi
  802256:	29 ce                	sub    %ecx,%esi
  802258:	19 ea                	sbb    %ebp,%edx
  80225a:	89 34 24             	mov    %esi,(%esp)
  80225d:	8b 04 24             	mov    (%esp),%eax
  802260:	8b 74 24 10          	mov    0x10(%esp),%esi
  802264:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802268:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	c3                   	ret    
  802270:	85 c9                	test   %ecx,%ecx
  802272:	75 0b                	jne    80227f <__umoddi3+0x8f>
  802274:	b8 01 00 00 00       	mov    $0x1,%eax
  802279:	31 d2                	xor    %edx,%edx
  80227b:	f7 f1                	div    %ecx
  80227d:	89 c1                	mov    %eax,%ecx
  80227f:	89 f0                	mov    %esi,%eax
  802281:	31 d2                	xor    %edx,%edx
  802283:	f7 f1                	div    %ecx
  802285:	8b 04 24             	mov    (%esp),%eax
  802288:	f7 f1                	div    %ecx
  80228a:	eb 98                	jmp    802224 <__umoddi3+0x34>
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 f2                	mov    %esi,%edx
  802292:	8b 74 24 10          	mov    0x10(%esp),%esi
  802296:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80229a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80229e:	83 c4 1c             	add    $0x1c,%esp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022ad:	89 e8                	mov    %ebp,%eax
  8022af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8022b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	d3 e0                	shl    %cl,%eax
  8022bc:	89 e9                	mov    %ebp,%ecx
  8022be:	d3 ea                	shr    %cl,%edx
  8022c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022c5:	09 c2                	or     %eax,%edx
  8022c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022cb:	89 14 24             	mov    %edx,(%esp)
  8022ce:	89 f2                	mov    %esi,%edx
  8022d0:	d3 e7                	shl    %cl,%edi
  8022d2:	89 e9                	mov    %ebp,%ecx
  8022d4:	d3 ea                	shr    %cl,%edx
  8022d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022df:	d3 e6                	shl    %cl,%esi
  8022e1:	89 e9                	mov    %ebp,%ecx
  8022e3:	d3 e8                	shr    %cl,%eax
  8022e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022ea:	09 f0                	or     %esi,%eax
  8022ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022f0:	f7 34 24             	divl   (%esp)
  8022f3:	d3 e6                	shl    %cl,%esi
  8022f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022f9:	89 d6                	mov    %edx,%esi
  8022fb:	f7 e7                	mul    %edi
  8022fd:	39 d6                	cmp    %edx,%esi
  8022ff:	89 c1                	mov    %eax,%ecx
  802301:	89 d7                	mov    %edx,%edi
  802303:	72 3f                	jb     802344 <__umoddi3+0x154>
  802305:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802309:	72 35                	jb     802340 <__umoddi3+0x150>
  80230b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230f:	29 c8                	sub    %ecx,%eax
  802311:	19 fe                	sbb    %edi,%esi
  802313:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802318:	89 f2                	mov    %esi,%edx
  80231a:	d3 e8                	shr    %cl,%eax
  80231c:	89 e9                	mov    %ebp,%ecx
  80231e:	d3 e2                	shl    %cl,%edx
  802320:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802325:	09 d0                	or     %edx,%eax
  802327:	89 f2                	mov    %esi,%edx
  802329:	d3 ea                	shr    %cl,%edx
  80232b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80232f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802333:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802337:	83 c4 1c             	add    $0x1c,%esp
  80233a:	c3                   	ret    
  80233b:	90                   	nop
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	39 d6                	cmp    %edx,%esi
  802342:	75 c7                	jne    80230b <__umoddi3+0x11b>
  802344:	89 d7                	mov    %edx,%edi
  802346:	89 c1                	mov    %eax,%ecx
  802348:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80234c:	1b 3c 24             	sbb    (%esp),%edi
  80234f:	eb ba                	jmp    80230b <__umoddi3+0x11b>
  802351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802358:	39 f5                	cmp    %esi,%ebp
  80235a:	0f 82 f1 fe ff ff    	jb     802251 <__umoddi3+0x61>
  802360:	e9 f8 fe ff ff       	jmp    80225d <__umoddi3+0x6d>
