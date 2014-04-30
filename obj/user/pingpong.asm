
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 b4 12 00 00       	call   8012f6 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 9c 0d 00 00       	call   800dec <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 60 1a 80 00 	movl   $0x801a60,(%esp)
  80005f:	e8 9b 01 00 00       	call   8001ff <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 5f 15 00 00       	call   8015e6 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 de 14 00 00       	call   801580 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 40 0d 00 00       	call   800dec <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 76 1a 80 00 	movl   $0x801a76,(%esp)
  8000bf:	e8 3b 01 00 00       	call   8001ff <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 fb 14 00 00       	call   8015e6 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010a:	e8 dd 0c 00 00       	call   800dec <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 35 0c 00 00       	call   800d8f <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	83 c0 01             	add    $0x1,%eax
  800172:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800174:	3d ff 00 00 00       	cmp    $0xff,%eax
  800179:	75 19                	jne    800194 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800182:	00 
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 a2 0b 00 00       	call   800d30 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	83 c4 14             	add    $0x14,%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ae:	00 00 00 
	b.cnt = 0;
  8001b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d3:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001da:	e8 97 01 00 00       	call   800376 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001df:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	e8 39 0b 00 00       	call   800d30 <sys_cputs>

	return b.cnt;
}
  8001f7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800205:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020c:	8b 45 08             	mov    0x8(%ebp),%eax
  80020f:	89 04 24             	mov    %eax,(%esp)
  800212:	e8 87 ff ff ff       	call   80019e <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    
  800219:	00 00                	add    %al,(%eax)
	...

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 3c             	sub    $0x3c,%esp
  800225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800228:	89 d7                	mov    %edx,%edi
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800230:	8b 45 0c             	mov    0xc(%ebp),%eax
  800233:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800236:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800239:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023c:	b8 00 00 00 00       	mov    $0x0,%eax
  800241:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800244:	72 11                	jb     800257 <printnum+0x3b>
  800246:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800249:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024c:	76 09                	jbe    800257 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024e:	83 eb 01             	sub    $0x1,%ebx
  800251:	85 db                	test   %ebx,%ebx
  800253:	7f 51                	jg     8002a6 <printnum+0x8a>
  800255:	eb 5e                	jmp    8002b5 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800257:	89 74 24 10          	mov    %esi,0x10(%esp)
  80025b:	83 eb 01             	sub    $0x1,%ebx
  80025e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800262:	8b 45 10             	mov    0x10(%ebp),%eax
  800265:	89 44 24 08          	mov    %eax,0x8(%esp)
  800269:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80026d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800271:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800278:	00 
  800279:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800282:	89 44 24 04          	mov    %eax,0x4(%esp)
  800286:	e8 25 15 00 00       	call   8017b0 <__udivdi3>
  80028b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029a:	89 fa                	mov    %edi,%edx
  80029c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029f:	e8 78 ff ff ff       	call   80021c <printnum>
  8002a4:	eb 0f                	jmp    8002b5 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002aa:	89 34 24             	mov    %esi,(%esp)
  8002ad:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b0:	83 eb 01             	sub    $0x1,%ebx
  8002b3:	75 f1                	jne    8002a6 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cb:	00 
  8002cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	e8 02 16 00 00       	call   8018e0 <__umoddi3>
  8002de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e2:	0f be 80 93 1a 80 00 	movsbl 0x801a93(%eax),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ef:	83 c4 3c             	add    $0x3c,%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fa:	83 fa 01             	cmp    $0x1,%edx
  8002fd:	7e 0e                	jle    80030d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 08             	lea    0x8(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	8b 52 04             	mov    0x4(%edx),%edx
  80030b:	eb 22                	jmp    80032f <getuint+0x38>
	else if (lflag)
  80030d:	85 d2                	test   %edx,%edx
  80030f:	74 10                	je     800321 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800311:	8b 10                	mov    (%eax),%edx
  800313:	8d 4a 04             	lea    0x4(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 02                	mov    (%edx),%eax
  80031a:	ba 00 00 00 00       	mov    $0x0,%edx
  80031f:	eb 0e                	jmp    80032f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800321:	8b 10                	mov    (%eax),%edx
  800323:	8d 4a 04             	lea    0x4(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 02                	mov    (%edx),%eax
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800337:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	3b 50 04             	cmp    0x4(%eax),%edx
  800340:	73 0a                	jae    80034c <sprintputch+0x1b>
		*b->buf++ = ch;
  800342:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800345:	88 0a                	mov    %cl,(%edx)
  800347:	83 c2 01             	add    $0x1,%edx
  80034a:	89 10                	mov    %edx,(%eax)
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800354:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800357:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035b:	8b 45 10             	mov    0x10(%ebp),%eax
  80035e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800362:	8b 45 0c             	mov    0xc(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	e8 02 00 00 00       	call   800376 <vprintfmt>
	va_end(ap);
}
  800374:	c9                   	leave  
  800375:	c3                   	ret    

00800376 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 5c             	sub    $0x5c,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800382:	8b 75 10             	mov    0x10(%ebp),%esi
  800385:	eb 12                	jmp    800399 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800387:	85 c0                	test   %eax,%eax
  800389:	0f 84 e4 04 00 00    	je     800873 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80038f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	0f b6 06             	movzbl (%esi),%eax
  80039c:	83 c6 01             	add    $0x1,%esi
  80039f:	83 f8 25             	cmp    $0x25,%eax
  8003a2:	75 e3                	jne    800387 <vprintfmt+0x11>
  8003a4:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003a8:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003af:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c0:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003c3:	eb 2b                	jmp    8003f0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c8:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003cc:	eb 22                	jmp    8003f0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d1:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003d5:	eb 19                	jmp    8003f0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003da:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003e1:	eb 0d                	jmp    8003f0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003e6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e9:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	0f b6 06             	movzbl (%esi),%eax
  8003f3:	0f b6 d0             	movzbl %al,%edx
  8003f6:	8d 7e 01             	lea    0x1(%esi),%edi
  8003f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003fc:	83 e8 23             	sub    $0x23,%eax
  8003ff:	3c 55                	cmp    $0x55,%al
  800401:	0f 87 46 04 00 00    	ja     80084d <vprintfmt+0x4d7>
  800407:	0f b6 c0             	movzbl %al,%eax
  80040a:	ff 24 85 80 1b 80 00 	jmp    *0x801b80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800411:	83 ea 30             	sub    $0x30,%edx
  800414:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800417:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80041b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800421:	83 fa 09             	cmp    $0x9,%edx
  800424:	77 4a                	ja     800470 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80042c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80042f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800433:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800436:	8d 50 d0             	lea    -0x30(%eax),%edx
  800439:	83 fa 09             	cmp    $0x9,%edx
  80043c:	76 eb                	jbe    800429 <vprintfmt+0xb3>
  80043e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800441:	eb 2d                	jmp    800470 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800454:	eb 1a                	jmp    800470 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800459:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80045d:	79 91                	jns    8003f0 <vprintfmt+0x7a>
  80045f:	e9 73 ff ff ff       	jmp    8003d7 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800467:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80046e:	eb 80                	jmp    8003f0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800470:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800474:	0f 89 76 ff ff ff    	jns    8003f0 <vprintfmt+0x7a>
  80047a:	e9 64 ff ff ff       	jmp    8003e3 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800485:	e9 66 ff ff ff       	jmp    8003f0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800497:	8b 00                	mov    (%eax),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a2:	e9 f2 fe ff ff       	jmp    800399 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004a7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004ab:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004ae:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8004b2:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8004b5:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8004b9:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8004bc:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8004bf:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8004c3:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004c6:	80 f9 09             	cmp    $0x9,%cl
  8004c9:	77 1d                	ja     8004e8 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8004cb:	0f be c0             	movsbl %al,%eax
  8004ce:	6b c0 64             	imul   $0x64,%eax,%eax
  8004d1:	0f be d2             	movsbl %dl,%edx
  8004d4:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004d7:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004de:	a3 04 20 80 00       	mov    %eax,0x802004
  8004e3:	e9 b1 fe ff ff       	jmp    800399 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004e8:	c7 44 24 04 ab 1a 80 	movl   $0x801aab,0x4(%esp)
  8004ef:	00 
  8004f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004f3:	89 04 24             	mov    %eax,(%esp)
  8004f6:	e8 10 05 00 00       	call   800a0b <strcmp>
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	75 0f                	jne    80050e <vprintfmt+0x198>
  8004ff:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800506:	00 00 00 
  800509:	e9 8b fe ff ff       	jmp    800399 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80050e:	c7 44 24 04 af 1a 80 	movl   $0x801aaf,0x4(%esp)
  800515:	00 
  800516:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800519:	89 14 24             	mov    %edx,(%esp)
  80051c:	e8 ea 04 00 00       	call   800a0b <strcmp>
  800521:	85 c0                	test   %eax,%eax
  800523:	75 0f                	jne    800534 <vprintfmt+0x1be>
  800525:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  80052c:	00 00 00 
  80052f:	e9 65 fe ff ff       	jmp    800399 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800534:	c7 44 24 04 b3 1a 80 	movl   $0x801ab3,0x4(%esp)
  80053b:	00 
  80053c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80053f:	89 0c 24             	mov    %ecx,(%esp)
  800542:	e8 c4 04 00 00       	call   800a0b <strcmp>
  800547:	85 c0                	test   %eax,%eax
  800549:	75 0f                	jne    80055a <vprintfmt+0x1e4>
  80054b:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800552:	00 00 00 
  800555:	e9 3f fe ff ff       	jmp    800399 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80055a:	c7 44 24 04 b7 1a 80 	movl   $0x801ab7,0x4(%esp)
  800561:	00 
  800562:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800565:	89 3c 24             	mov    %edi,(%esp)
  800568:	e8 9e 04 00 00       	call   800a0b <strcmp>
  80056d:	85 c0                	test   %eax,%eax
  80056f:	75 0f                	jne    800580 <vprintfmt+0x20a>
  800571:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800578:	00 00 00 
  80057b:	e9 19 fe ff ff       	jmp    800399 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800580:	c7 44 24 04 bb 1a 80 	movl   $0x801abb,0x4(%esp)
  800587:	00 
  800588:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058b:	89 04 24             	mov    %eax,(%esp)
  80058e:	e8 78 04 00 00       	call   800a0b <strcmp>
  800593:	85 c0                	test   %eax,%eax
  800595:	75 0f                	jne    8005a6 <vprintfmt+0x230>
  800597:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80059e:	00 00 00 
  8005a1:	e9 f3 fd ff ff       	jmp    800399 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005a6:	c7 44 24 04 bf 1a 80 	movl   $0x801abf,0x4(%esp)
  8005ad:	00 
  8005ae:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005b1:	89 14 24             	mov    %edx,(%esp)
  8005b4:	e8 52 04 00 00       	call   800a0b <strcmp>
  8005b9:	83 f8 01             	cmp    $0x1,%eax
  8005bc:	19 c0                	sbb    %eax,%eax
  8005be:	f7 d0                	not    %eax
  8005c0:	83 c0 08             	add    $0x8,%eax
  8005c3:	a3 04 20 80 00       	mov    %eax,0x802004
  8005c8:	e9 cc fd ff ff       	jmp    800399 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 c2                	mov    %eax,%edx
  8005da:	c1 fa 1f             	sar    $0x1f,%edx
  8005dd:	31 d0                	xor    %edx,%eax
  8005df:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e1:	83 f8 08             	cmp    $0x8,%eax
  8005e4:	7f 0b                	jg     8005f1 <vprintfmt+0x27b>
  8005e6:	8b 14 85 e0 1c 80 00 	mov    0x801ce0(,%eax,4),%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	75 23                	jne    800614 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f5:	c7 44 24 08 c3 1a 80 	movl   $0x801ac3,0x8(%esp)
  8005fc:	00 
  8005fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800601:	8b 7d 08             	mov    0x8(%ebp),%edi
  800604:	89 3c 24             	mov    %edi,(%esp)
  800607:	e8 42 fd ff ff       	call   80034e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80060f:	e9 85 fd ff ff       	jmp    800399 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800614:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800618:	c7 44 24 08 cc 1a 80 	movl   $0x801acc,0x8(%esp)
  80061f:	00 
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	8b 7d 08             	mov    0x8(%ebp),%edi
  800627:	89 3c 24             	mov    %edi,(%esp)
  80062a:	e8 1f fd ff ff       	call   80034e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800632:	e9 62 fd ff ff       	jmp    800399 <vprintfmt+0x23>
  800637:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80063a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80063d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80064b:	85 f6                	test   %esi,%esi
  80064d:	b8 a4 1a 80 00       	mov    $0x801aa4,%eax
  800652:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800655:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800659:	7e 06                	jle    800661 <vprintfmt+0x2eb>
  80065b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80065f:	75 13                	jne    800674 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800661:	0f be 06             	movsbl (%esi),%eax
  800664:	83 c6 01             	add    $0x1,%esi
  800667:	85 c0                	test   %eax,%eax
  800669:	0f 85 94 00 00 00    	jne    800703 <vprintfmt+0x38d>
  80066f:	e9 81 00 00 00       	jmp    8006f5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800674:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800678:	89 34 24             	mov    %esi,(%esp)
  80067b:	e8 9b 02 00 00       	call   80091b <strnlen>
  800680:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800683:	29 c2                	sub    %eax,%edx
  800685:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800688:	85 d2                	test   %edx,%edx
  80068a:	7e d5                	jle    800661 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80068c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800690:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800693:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800696:	89 d6                	mov    %edx,%esi
  800698:	89 cf                	mov    %ecx,%edi
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	89 3c 24             	mov    %edi,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a4:	83 ee 01             	sub    $0x1,%esi
  8006a7:	75 f1                	jne    80069a <vprintfmt+0x324>
  8006a9:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006ac:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006af:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8006b2:	eb ad                	jmp    800661 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006b4:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006b8:	74 1b                	je     8006d5 <vprintfmt+0x35f>
  8006ba:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006bd:	83 fa 5e             	cmp    $0x5e,%edx
  8006c0:	76 13                	jbe    8006d5 <vprintfmt+0x35f>
					putch('?', putdat);
  8006c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006d0:	ff 55 08             	call   *0x8(%ebp)
  8006d3:	eb 0d                	jmp    8006e2 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006d5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e2:	83 eb 01             	sub    $0x1,%ebx
  8006e5:	0f be 06             	movsbl (%esi),%eax
  8006e8:	83 c6 01             	add    $0x1,%esi
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	75 1a                	jne    800709 <vprintfmt+0x393>
  8006ef:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006f2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006fc:	7f 1c                	jg     80071a <vprintfmt+0x3a4>
  8006fe:	e9 96 fc ff ff       	jmp    800399 <vprintfmt+0x23>
  800703:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800706:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800709:	85 ff                	test   %edi,%edi
  80070b:	78 a7                	js     8006b4 <vprintfmt+0x33e>
  80070d:	83 ef 01             	sub    $0x1,%edi
  800710:	79 a2                	jns    8006b4 <vprintfmt+0x33e>
  800712:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800715:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800718:	eb db                	jmp    8006f5 <vprintfmt+0x37f>
  80071a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071d:	89 de                	mov    %ebx,%esi
  80071f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800722:	89 74 24 04          	mov    %esi,0x4(%esp)
  800726:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80072d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072f:	83 eb 01             	sub    $0x1,%ebx
  800732:	75 ee                	jne    800722 <vprintfmt+0x3ac>
  800734:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800736:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800739:	e9 5b fc ff ff       	jmp    800399 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073e:	83 f9 01             	cmp    $0x1,%ecx
  800741:	7e 10                	jle    800753 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 50 08             	lea    0x8(%eax),%edx
  800749:	89 55 14             	mov    %edx,0x14(%ebp)
  80074c:	8b 30                	mov    (%eax),%esi
  80074e:	8b 78 04             	mov    0x4(%eax),%edi
  800751:	eb 26                	jmp    800779 <vprintfmt+0x403>
	else if (lflag)
  800753:	85 c9                	test   %ecx,%ecx
  800755:	74 12                	je     800769 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)
  800760:	8b 30                	mov    (%eax),%esi
  800762:	89 f7                	mov    %esi,%edi
  800764:	c1 ff 1f             	sar    $0x1f,%edi
  800767:	eb 10                	jmp    800779 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8d 50 04             	lea    0x4(%eax),%edx
  80076f:	89 55 14             	mov    %edx,0x14(%ebp)
  800772:	8b 30                	mov    (%eax),%esi
  800774:	89 f7                	mov    %esi,%edi
  800776:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800779:	85 ff                	test   %edi,%edi
  80077b:	78 0e                	js     80078b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80077d:	89 f0                	mov    %esi,%eax
  80077f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800781:	be 0a 00 00 00       	mov    $0xa,%esi
  800786:	e9 84 00 00 00       	jmp    80080f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80078b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800796:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800799:	89 f0                	mov    %esi,%eax
  80079b:	89 fa                	mov    %edi,%edx
  80079d:	f7 d8                	neg    %eax
  80079f:	83 d2 00             	adc    $0x0,%edx
  8007a2:	f7 da                	neg    %edx
			}
			base = 10;
  8007a4:	be 0a 00 00 00       	mov    $0xa,%esi
  8007a9:	eb 64                	jmp    80080f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ab:	89 ca                	mov    %ecx,%edx
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b0:	e8 42 fb ff ff       	call   8002f7 <getuint>
			base = 10;
  8007b5:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8007ba:	eb 53                	jmp    80080f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007bc:	89 ca                	mov    %ecx,%edx
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c1:	e8 31 fb ff ff       	call   8002f7 <getuint>
    			base = 8;
  8007c6:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8007cb:	eb 42                	jmp    80080f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8007cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007df:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007e6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f2:	8b 00                	mov    (%eax),%eax
  8007f4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007fe:	eb 0f                	jmp    80080f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800800:	89 ca                	mov    %ecx,%edx
  800802:	8d 45 14             	lea    0x14(%ebp),%eax
  800805:	e8 ed fa ff ff       	call   8002f7 <getuint>
			base = 16;
  80080a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800813:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800817:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80081a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80081e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	89 54 24 04          	mov    %edx,0x4(%esp)
  800829:	89 da                	mov    %ebx,%edx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	e8 e9 f9 ff ff       	call   80021c <printnum>
			break;
  800833:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800836:	e9 5e fb ff ff       	jmp    800399 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083f:	89 14 24             	mov    %edx,(%esp)
  800842:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800845:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800848:	e9 4c fb ff ff       	jmp    800399 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800851:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800858:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80085f:	0f 84 34 fb ff ff    	je     800399 <vprintfmt+0x23>
  800865:	83 ee 01             	sub    $0x1,%esi
  800868:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80086c:	75 f7                	jne    800865 <vprintfmt+0x4ef>
  80086e:	e9 26 fb ff ff       	jmp    800399 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800873:	83 c4 5c             	add    $0x5c,%esp
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5f                   	pop    %edi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 28             	sub    $0x28,%esp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800887:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800891:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800898:	85 c0                	test   %eax,%eax
  80089a:	74 30                	je     8008cc <vsnprintf+0x51>
  80089c:	85 d2                	test   %edx,%edx
  80089e:	7e 2c                	jle    8008cc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b5:	c7 04 24 31 03 80 00 	movl   $0x800331,(%esp)
  8008bc:	e8 b5 fa ff ff       	call   800376 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ca:	eb 05                	jmp    8008d1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	89 04 24             	mov    %eax,(%esp)
  8008f4:	e8 82 ff ff ff       	call   80087b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    
  8008fb:	00 00                	add    %al,(%eax)
  8008fd:	00 00                	add    %al,(%eax)
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	80 3a 00             	cmpb   $0x0,(%edx)
  80090e:	74 09                	je     800919 <strlen+0x19>
		n++;
  800910:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800913:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800917:	75 f7                	jne    800910 <strlen+0x10>
		n++;
	return n;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
  80092a:	85 c9                	test   %ecx,%ecx
  80092c:	74 1a                	je     800948 <strnlen+0x2d>
  80092e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800931:	74 15                	je     800948 <strnlen+0x2d>
  800933:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800938:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093a:	39 ca                	cmp    %ecx,%edx
  80093c:	74 0a                	je     800948 <strnlen+0x2d>
  80093e:	83 c2 01             	add    $0x1,%edx
  800941:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800946:	75 f0                	jne    800938 <strnlen+0x1d>
		n++;
	return n;
}
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800955:	ba 00 00 00 00       	mov    $0x0,%edx
  80095a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800961:	83 c2 01             	add    $0x1,%edx
  800964:	84 c9                	test   %cl,%cl
  800966:	75 f2                	jne    80095a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	83 ec 08             	sub    $0x8,%esp
  800972:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800975:	89 1c 24             	mov    %ebx,(%esp)
  800978:	e8 83 ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800980:	89 54 24 04          	mov    %edx,0x4(%esp)
  800984:	01 d8                	add    %ebx,%eax
  800986:	89 04 24             	mov    %eax,(%esp)
  800989:	e8 bd ff ff ff       	call   80094b <strcpy>
	return dst;
}
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	83 c4 08             	add    $0x8,%esp
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a4:	85 f6                	test   %esi,%esi
  8009a6:	74 18                	je     8009c0 <strncpy+0x2a>
  8009a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009ad:	0f b6 1a             	movzbl (%edx),%ebx
  8009b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	39 f1                	cmp    %esi,%ecx
  8009be:	75 ed                	jne    8009ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d3:	89 f8                	mov    %edi,%eax
  8009d5:	85 f6                	test   %esi,%esi
  8009d7:	74 2b                	je     800a04 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8009d9:	83 fe 01             	cmp    $0x1,%esi
  8009dc:	74 23                	je     800a01 <strlcpy+0x3d>
  8009de:	0f b6 0b             	movzbl (%ebx),%ecx
  8009e1:	84 c9                	test   %cl,%cl
  8009e3:	74 1c                	je     800a01 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009e5:	83 ee 02             	sub    $0x2,%esi
  8009e8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ed:	88 08                	mov    %cl,(%eax)
  8009ef:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f2:	39 f2                	cmp    %esi,%edx
  8009f4:	74 0b                	je     800a01 <strlcpy+0x3d>
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009fd:	84 c9                	test   %cl,%cl
  8009ff:	75 ec                	jne    8009ed <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a04:	29 f8                	sub    %edi,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	84 c0                	test   %al,%al
  800a19:	74 16                	je     800a31 <strcmp+0x26>
  800a1b:	3a 02                	cmp    (%edx),%al
  800a1d:	75 12                	jne    800a31 <strcmp+0x26>
		p++, q++;
  800a1f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a22:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a26:	84 c0                	test   %al,%al
  800a28:	74 07                	je     800a31 <strcmp+0x26>
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	3a 02                	cmp    (%edx),%al
  800a2f:	74 ee                	je     800a1f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a31:	0f b6 c0             	movzbl %al,%eax
  800a34:	0f b6 12             	movzbl (%edx),%edx
  800a37:	29 d0                	sub    %edx,%eax
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a45:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4d:	85 d2                	test   %edx,%edx
  800a4f:	74 28                	je     800a79 <strncmp+0x3e>
  800a51:	0f b6 01             	movzbl (%ecx),%eax
  800a54:	84 c0                	test   %al,%al
  800a56:	74 24                	je     800a7c <strncmp+0x41>
  800a58:	3a 03                	cmp    (%ebx),%al
  800a5a:	75 20                	jne    800a7c <strncmp+0x41>
  800a5c:	83 ea 01             	sub    $0x1,%edx
  800a5f:	74 13                	je     800a74 <strncmp+0x39>
		n--, p++, q++;
  800a61:	83 c1 01             	add    $0x1,%ecx
  800a64:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a67:	0f b6 01             	movzbl (%ecx),%eax
  800a6a:	84 c0                	test   %al,%al
  800a6c:	74 0e                	je     800a7c <strncmp+0x41>
  800a6e:	3a 03                	cmp    (%ebx),%al
  800a70:	74 ea                	je     800a5c <strncmp+0x21>
  800a72:	eb 08                	jmp    800a7c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7c:	0f b6 01             	movzbl (%ecx),%eax
  800a7f:	0f b6 13             	movzbl (%ebx),%edx
  800a82:	29 d0                	sub    %edx,%eax
  800a84:	eb f3                	jmp    800a79 <strncmp+0x3e>

00800a86 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a90:	0f b6 10             	movzbl (%eax),%edx
  800a93:	84 d2                	test   %dl,%dl
  800a95:	74 1c                	je     800ab3 <strchr+0x2d>
		if (*s == c)
  800a97:	38 ca                	cmp    %cl,%dl
  800a99:	75 09                	jne    800aa4 <strchr+0x1e>
  800a9b:	eb 1b                	jmp    800ab8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	74 14                	je     800ab8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	75 f1                	jne    800a9d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	eb 05                	jmp    800ab8 <strchr+0x32>
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac4:	0f b6 10             	movzbl (%eax),%edx
  800ac7:	84 d2                	test   %dl,%dl
  800ac9:	74 14                	je     800adf <strfind+0x25>
		if (*s == c)
  800acb:	38 ca                	cmp    %cl,%dl
  800acd:	75 06                	jne    800ad5 <strfind+0x1b>
  800acf:	eb 0e                	jmp    800adf <strfind+0x25>
  800ad1:	38 ca                	cmp    %cl,%dl
  800ad3:	74 0a                	je     800adf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	0f b6 10             	movzbl (%eax),%edx
  800adb:	84 d2                	test   %dl,%dl
  800add:	75 f2                	jne    800ad1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 0c             	sub    $0xc,%esp
  800ae7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800aea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aed:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800af0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af9:	85 c9                	test   %ecx,%ecx
  800afb:	74 30                	je     800b2d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b03:	75 25                	jne    800b2a <memset+0x49>
  800b05:	f6 c1 03             	test   $0x3,%cl
  800b08:	75 20                	jne    800b2a <memset+0x49>
		c &= 0xFF;
  800b0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	c1 e3 08             	shl    $0x8,%ebx
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	c1 e6 18             	shl    $0x18,%esi
  800b17:	89 d0                	mov    %edx,%eax
  800b19:	c1 e0 10             	shl    $0x10,%eax
  800b1c:	09 f0                	or     %esi,%eax
  800b1e:	09 d0                	or     %edx,%eax
  800b20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b25:	fc                   	cld    
  800b26:	f3 ab                	rep stos %eax,%es:(%edi)
  800b28:	eb 03                	jmp    800b2d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2a:	fc                   	cld    
  800b2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b38:	89 ec                	mov    %ebp,%esp
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b45:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b51:	39 c6                	cmp    %eax,%esi
  800b53:	73 36                	jae    800b8b <memmove+0x4f>
  800b55:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b58:	39 d0                	cmp    %edx,%eax
  800b5a:	73 2f                	jae    800b8b <memmove+0x4f>
		s += n;
		d += n;
  800b5c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 1b                	jne    800b7f <memmove+0x43>
  800b64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6a:	75 13                	jne    800b7f <memmove+0x43>
  800b6c:	f6 c1 03             	test   $0x3,%cl
  800b6f:	75 0e                	jne    800b7f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b71:	83 ef 04             	sub    $0x4,%edi
  800b74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b7a:	fd                   	std    
  800b7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7d:	eb 09                	jmp    800b88 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b7f:	83 ef 01             	sub    $0x1,%edi
  800b82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b85:	fd                   	std    
  800b86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b88:	fc                   	cld    
  800b89:	eb 20                	jmp    800bab <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b91:	75 13                	jne    800ba6 <memmove+0x6a>
  800b93:	a8 03                	test   $0x3,%al
  800b95:	75 0f                	jne    800ba6 <memmove+0x6a>
  800b97:	f6 c1 03             	test   $0x3,%cl
  800b9a:	75 0a                	jne    800ba6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	fc                   	cld    
  800ba2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba4:	eb 05                	jmp    800bab <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bb1:	89 ec                	mov    %ebp,%esp
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	89 04 24             	mov    %eax,(%esp)
  800bcf:	e8 68 ff ff ff       	call   800b3c <memmove>
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bea:	85 ff                	test   %edi,%edi
  800bec:	74 37                	je     800c25 <memcmp+0x4f>
		if (*s1 != *s2)
  800bee:	0f b6 03             	movzbl (%ebx),%eax
  800bf1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf4:	83 ef 01             	sub    $0x1,%edi
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800bfc:	38 c8                	cmp    %cl,%al
  800bfe:	74 1c                	je     800c1c <memcmp+0x46>
  800c00:	eb 10                	jmp    800c12 <memcmp+0x3c>
  800c02:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c07:	83 c2 01             	add    $0x1,%edx
  800c0a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c0e:	38 c8                	cmp    %cl,%al
  800c10:	74 0a                	je     800c1c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c12:	0f b6 c0             	movzbl %al,%eax
  800c15:	0f b6 c9             	movzbl %cl,%ecx
  800c18:	29 c8                	sub    %ecx,%eax
  800c1a:	eb 09                	jmp    800c25 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1c:	39 fa                	cmp    %edi,%edx
  800c1e:	75 e2                	jne    800c02 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c30:	89 c2                	mov    %eax,%edx
  800c32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	73 19                	jae    800c52 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c3d:	38 08                	cmp    %cl,(%eax)
  800c3f:	75 06                	jne    800c47 <memfind+0x1d>
  800c41:	eb 0f                	jmp    800c52 <memfind+0x28>
  800c43:	38 08                	cmp    %cl,(%eax)
  800c45:	74 0b                	je     800c52 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c47:	83 c0 01             	add    $0x1,%eax
  800c4a:	39 d0                	cmp    %edx,%eax
  800c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c50:	75 f1                	jne    800c43 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c60:	0f b6 02             	movzbl (%edx),%eax
  800c63:	3c 20                	cmp    $0x20,%al
  800c65:	74 04                	je     800c6b <strtol+0x17>
  800c67:	3c 09                	cmp    $0x9,%al
  800c69:	75 0e                	jne    800c79 <strtol+0x25>
		s++;
  800c6b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6e:	0f b6 02             	movzbl (%edx),%eax
  800c71:	3c 20                	cmp    $0x20,%al
  800c73:	74 f6                	je     800c6b <strtol+0x17>
  800c75:	3c 09                	cmp    $0x9,%al
  800c77:	74 f2                	je     800c6b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c79:	3c 2b                	cmp    $0x2b,%al
  800c7b:	75 0a                	jne    800c87 <strtol+0x33>
		s++;
  800c7d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c80:	bf 00 00 00 00       	mov    $0x0,%edi
  800c85:	eb 10                	jmp    800c97 <strtol+0x43>
  800c87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c8c:	3c 2d                	cmp    $0x2d,%al
  800c8e:	75 07                	jne    800c97 <strtol+0x43>
		s++, neg = 1;
  800c90:	83 c2 01             	add    $0x1,%edx
  800c93:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c97:	85 db                	test   %ebx,%ebx
  800c99:	0f 94 c0             	sete   %al
  800c9c:	74 05                	je     800ca3 <strtol+0x4f>
  800c9e:	83 fb 10             	cmp    $0x10,%ebx
  800ca1:	75 15                	jne    800cb8 <strtol+0x64>
  800ca3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ca6:	75 10                	jne    800cb8 <strtol+0x64>
  800ca8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cac:	75 0a                	jne    800cb8 <strtol+0x64>
		s += 2, base = 16;
  800cae:	83 c2 02             	add    $0x2,%edx
  800cb1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cb6:	eb 13                	jmp    800ccb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cb8:	84 c0                	test   %al,%al
  800cba:	74 0f                	je     800ccb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cbc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc1:	80 3a 30             	cmpb   $0x30,(%edx)
  800cc4:	75 05                	jne    800ccb <strtol+0x77>
		s++, base = 8;
  800cc6:	83 c2 01             	add    $0x1,%edx
  800cc9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd2:	0f b6 0a             	movzbl (%edx),%ecx
  800cd5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cd8:	80 fb 09             	cmp    $0x9,%bl
  800cdb:	77 08                	ja     800ce5 <strtol+0x91>
			dig = *s - '0';
  800cdd:	0f be c9             	movsbl %cl,%ecx
  800ce0:	83 e9 30             	sub    $0x30,%ecx
  800ce3:	eb 1e                	jmp    800d03 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ce5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ce8:	80 fb 19             	cmp    $0x19,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ced:	0f be c9             	movsbl %cl,%ecx
  800cf0:	83 e9 57             	sub    $0x57,%ecx
  800cf3:	eb 0e                	jmp    800d03 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800cf5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cf8:	80 fb 19             	cmp    $0x19,%bl
  800cfb:	77 14                	ja     800d11 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cfd:	0f be c9             	movsbl %cl,%ecx
  800d00:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d03:	39 f1                	cmp    %esi,%ecx
  800d05:	7d 0e                	jge    800d15 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d07:	83 c2 01             	add    $0x1,%edx
  800d0a:	0f af c6             	imul   %esi,%eax
  800d0d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d0f:	eb c1                	jmp    800cd2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d11:	89 c1                	mov    %eax,%ecx
  800d13:	eb 02                	jmp    800d17 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d15:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d1b:	74 05                	je     800d22 <strtol+0xce>
		*endptr = (char *) s;
  800d1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d20:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d22:	89 ca                	mov    %ecx,%edx
  800d24:	f7 da                	neg    %edx
  800d26:	85 ff                	test   %edi,%edi
  800d28:	0f 45 c2             	cmovne %edx,%eax
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 c7                	mov    %eax,%edi
  800d4e:	89 c6                	mov    %eax,%esi
  800d50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5b:	89 ec                	mov    %ebp,%esp
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d73:	b8 01 00 00 00       	mov    $0x1,%eax
  800d78:	89 d1                	mov    %edx,%ecx
  800d7a:	89 d3                	mov    %edx,%ebx
  800d7c:	89 d7                	mov    %edx,%edi
  800d7e:	89 d6                	mov    %edx,%esi
  800d80:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8b:	89 ec                	mov    %ebp,%esp
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 38             	sub    $0x38,%esp
  800d95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da3:	b8 03 00 00 00       	mov    $0x3,%eax
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 cb                	mov    %ecx,%ebx
  800dad:	89 cf                	mov    %ecx,%edi
  800daf:	89 ce                	mov    %ecx,%esi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 28                	jle    800ddf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  800dda:	e8 bd 08 00 00       	call   80169c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de8:	89 ec                	mov    %ebp,%esp
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800e00:	b8 02 00 00 00       	mov    $0x2,%eax
  800e05:	89 d1                	mov    %edx,%ecx
  800e07:	89 d3                	mov    %edx,%ebx
  800e09:	89 d7                	mov    %edx,%edi
  800e0b:	89 d6                	mov    %edx,%esi
  800e0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_yield>:

void
sys_yield(void)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e48:	89 ec                	mov    %ebp,%esp
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 38             	sub    $0x38,%esp
  800e52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	be 00 00 00 00       	mov    $0x0,%esi
  800e60:	b8 04 00 00 00       	mov    $0x4,%eax
  800e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	89 f7                	mov    %esi,%edi
  800e70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  800e99:	e8 fe 07 00 00       	call   80169c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea7:	89 ec                	mov    %ebp,%esp
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 38             	sub    $0x38,%esp
  800eb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebf:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	7e 28                	jle    800efc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800edf:	00 
  800ee0:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eef:	00 
  800ef0:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  800ef7:	e8 a0 07 00 00       	call   80169c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800efc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f02:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f05:	89 ec                	mov    %ebp,%esp
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 38             	sub    $0x38,%esp
  800f0f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	7e 28                	jle    800f5a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f36:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  800f45:	00 
  800f46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  800f55:	e8 42 07 00 00       	call   80169c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f63:	89 ec                	mov    %ebp,%esp
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 38             	sub    $0x38,%esp
  800f6d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f70:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f73:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
  800f86:	89 df                	mov    %ebx,%edi
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 28                	jle    800fb8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  800fb3:	e8 e4 06 00 00       	call   80169c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fb8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc1:	89 ec                	mov    %ebp,%esp
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 38             	sub    $0x38,%esp
  800fcb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 df                	mov    %ebx,%edi
  800fe6:	89 de                	mov    %ebx,%esi
  800fe8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 28                	jle    801016 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  801001:	00 
  801002:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801009:	00 
  80100a:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  801011:	e8 86 06 00 00       	call   80169c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801016:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801019:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101f:	89 ec                	mov    %ebp,%esp
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80102f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	be 00 00 00 00       	mov    $0x0,%esi
  801037:	b8 0b 00 00 00       	mov    $0xb,%eax
  80103c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80103f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801045:	8b 55 08             	mov    0x8(%ebp),%edx
  801048:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80104a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801050:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801053:	89 ec                	mov    %ebp,%esp
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 38             	sub    $0x38,%esp
  80105d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801060:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801063:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801066:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801070:	8b 55 08             	mov    0x8(%ebp),%edx
  801073:	89 cb                	mov    %ecx,%ebx
  801075:	89 cf                	mov    %ecx,%edi
  801077:	89 ce                	mov    %ecx,%esi
  801079:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107b:	85 c0                	test   %eax,%eax
  80107d:	7e 28                	jle    8010a7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801083:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80108a:	00 
  80108b:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  801092:	00 
  801093:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109a:	00 
  80109b:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  8010a2:	e8 f5 05 00 00       	call   80169c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010aa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b0:	89 ec                	mov    %ebp,%esp
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d0:	89 cb                	mov    %ecx,%ebx
  8010d2:	89 cf                	mov    %ecx,%edi
  8010d4:	89 ce                	mov    %ecx,%esi
  8010d6:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  8010d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e1:	89 ec                	mov    %ebp,%esp
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    
  8010e5:	00 00                	add    %al,(%eax)
	...

008010e8 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 24             	sub    $0x24,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  8010ef:	89 d3                	mov    %edx,%ebx
  8010f1:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010f4:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8010fb:	f6 c1 02             	test   $0x2,%cl
  8010fe:	75 10                	jne    801110 <duppage+0x28>
  801100:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801107:	f6 c6 08             	test   $0x8,%dh
  80110a:	0f 84 84 00 00 00    	je     801194 <duppage+0xac>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801110:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801117:	00 
  801118:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80111c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801124:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112b:	e8 7b fd ff ff       	call   800eab <sys_page_map>
  801130:	85 c0                	test   %eax,%eax
  801132:	79 1c                	jns    801150 <duppage+0x68>
			panic("2");
  801134:	c7 44 24 08 2f 1d 80 	movl   $0x801d2f,0x8(%esp)
  80113b:	00 
  80113c:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  80114b:	e8 4c 05 00 00       	call   80169c <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801150:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801157:	00 
  801158:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80115c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801163:	00 
  801164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116f:	e8 37 fd ff ff       	call   800eab <sys_page_map>
  801174:	85 c0                	test   %eax,%eax
  801176:	79 3c                	jns    8011b4 <duppage+0xcc>
			panic("3");
  801178:	c7 44 24 08 3c 1d 80 	movl   $0x801d3c,0x8(%esp)
  80117f:	00 
  801180:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801187:	00 
  801188:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  80118f:	e8 08 05 00 00       	call   80169c <_panic>
		
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801194:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80119b:	00 
  80119c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011af:	e8 f7 fc ff ff       	call   800eab <sys_page_map>
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b9:	83 c4 24             	add    $0x24,%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 24             	sub    $0x24,%esp
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  8011c9:	8b 18                	mov    (%eax),%ebx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8011cb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011cf:	74 2d                	je     8011fe <pgfault+0x3f>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8011d1:	89 d8                	mov    %ebx,%eax
  8011d3:	c1 e8 16             	shr    $0x16,%eax
  8011d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011dd:	a8 01                	test   $0x1,%al
  8011df:	74 1d                	je     8011fe <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8011e1:	89 d8                	mov    %ebx,%eax
  8011e3:	c1 e8 0c             	shr    $0xc,%eax
  8011e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8011ed:	f6 c2 01             	test   $0x1,%dl
  8011f0:	74 0c                	je     8011fe <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8011f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8011f9:	f6 c4 08             	test   $0x8,%ah
  8011fc:	75 1c                	jne    80121a <pgfault+0x5b>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  8011fe:	c7 44 24 08 3e 1d 80 	movl   $0x801d3e,0x8(%esp)
  801205:	00 
  801206:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80120d:	00 
  80120e:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  801215:	e8 82 04 00 00       	call   80169c <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  80121a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801231:	e8 16 fc ff ff       	call   800e4c <sys_page_alloc>
  801236:	85 c0                	test   %eax,%eax
  801238:	79 1c                	jns    801256 <pgfault+0x97>
		panic("sys_page_alloc");
  80123a:	c7 44 24 08 50 1d 80 	movl   $0x801d50,0x8(%esp)
  801241:	00 
  801242:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801249:	00 
  80124a:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  801251:	e8 46 04 00 00       	call   80169c <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  801256:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  80125c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801263:	00 
  801264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801268:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80126f:	e8 41 f9 ff ff       	call   800bb5 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801274:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80127b:	00 
  80127c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801287:	00 
  801288:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80128f:	00 
  801290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801297:	e8 0f fc ff ff       	call   800eab <sys_page_map>
  80129c:	85 c0                	test   %eax,%eax
  80129e:	79 1c                	jns    8012bc <pgfault+0xfd>
		panic("sys_page_map");
  8012a0:	c7 44 24 08 5f 1d 80 	movl   $0x801d5f,0x8(%esp)
  8012a7:	00 
  8012a8:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  8012af:	00 
  8012b0:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  8012b7:	e8 e0 03 00 00       	call   80169c <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  8012bc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012c3:	00 
  8012c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cb:	e8 39 fc ff ff       	call   800f09 <sys_page_unmap>
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	79 1c                	jns    8012f0 <pgfault+0x131>
		panic("sys_page_unmap");
  8012d4:	c7 44 24 08 6c 1d 80 	movl   $0x801d6c,0x8(%esp)
  8012db:	00 
  8012dc:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8012e3:	00 
  8012e4:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  8012eb:	e8 ac 03 00 00       	call   80169c <_panic>
	return;
}
  8012f0:	83 c4 24             	add    $0x24,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 1c             	sub    $0x1c,%esp
	set_pgfault_handler(pgfault);
  8012ff:	c7 04 24 bf 11 80 00 	movl   $0x8011bf,(%esp)
  801306:	e8 e9 03 00 00       	call   8016f4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80130b:	be 07 00 00 00       	mov    $0x7,%esi
  801310:	89 f0                	mov    %esi,%eax
  801312:	cd 30                	int    $0x30
  801314:	89 c6                	mov    %eax,%esi
  801316:	89 c7                	mov    %eax,%edi

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801318:	85 c0                	test   %eax,%eax
  80131a:	75 1c                	jne    801338 <fork+0x42>
		thisenv = &envs[ENVX(sys_getenvid())];
  80131c:	e8 cb fa ff ff       	call   800dec <sys_getenvid>
  801321:	25 ff 03 00 00       	and    $0x3ff,%eax
  801326:	c1 e0 07             	shl    $0x7,%eax
  801329:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80132e:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801333:	e9 e1 00 00 00       	jmp    801419 <fork+0x123>
	}
	if (envid < 0)
  801338:	85 c0                	test   %eax,%eax
  80133a:	79 20                	jns    80135c <fork+0x66>
		panic("sys_exofork: %e", envid);
  80133c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801340:	c7 44 24 08 7b 1d 80 	movl   $0x801d7b,0x8(%esp)
  801347:	00 
  801348:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  80134f:	00 
  801350:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  801357:	e8 40 03 00 00       	call   80169c <_panic>
	envid = sys_exofork();
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  80135c:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801361:	89 d8                	mov    %ebx,%eax
  801363:	c1 e8 16             	shr    $0x16,%eax
  801366:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80136d:	a8 01                	test   $0x1,%al
  80136f:	74 22                	je     801393 <fork+0x9d>
  801371:	89 da                	mov    %ebx,%edx
  801373:	c1 ea 0c             	shr    $0xc,%edx
  801376:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80137d:	a8 01                	test   $0x1,%al
  80137f:	74 12                	je     801393 <fork+0x9d>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801381:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801388:	a8 04                	test   $0x4,%al
  80138a:	74 07                	je     801393 <fork+0x9d>
			duppage(envid, PGNUM(addr));
  80138c:	89 f8                	mov    %edi,%eax
  80138e:	e8 55 fd ff ff       	call   8010e8 <duppage>
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801393:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801399:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80139f:	75 c0                	jne    801361 <fork+0x6b>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8013a1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013a8:	00 
  8013a9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013b0:	ee 
  8013b1:	89 34 24             	mov    %esi,(%esp)
  8013b4:	e8 93 fa ff ff       	call   800e4c <sys_page_alloc>
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	79 1c                	jns    8013d9 <fork+0xe3>
		panic("1");
  8013bd:	c7 44 24 08 8b 1d 80 	movl   $0x801d8b,0x8(%esp)
  8013c4:	00 
  8013c5:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8013cc:	00 
  8013cd:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  8013d4:	e8 c3 02 00 00       	call   80169c <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013d9:	c7 44 24 04 80 17 80 	movl   $0x801780,0x4(%esp)
  8013e0:	00 
  8013e1:	89 34 24             	mov    %esi,(%esp)
  8013e4:	e8 dc fb ff ff       	call   800fc5 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8013e9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013f0:	00 
  8013f1:	89 34 24             	mov    %esi,(%esp)
  8013f4:	e8 6e fb ff ff       	call   800f67 <sys_env_set_status>
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	79 1c                	jns    801419 <fork+0x123>
		panic("sys_env_set_status");
  8013fd:	c7 44 24 08 8d 1d 80 	movl   $0x801d8d,0x8(%esp)
  801404:	00 
  801405:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80140c:	00 
  80140d:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  801414:	e8 83 02 00 00       	call   80169c <_panic>

	return envid;
}
  801419:	89 f0                	mov    %esi,%eax
  80141b:	83 c4 1c             	add    $0x1c,%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <sfork>:

// Challenge!
int
sfork(void)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801429:	c7 44 24 08 a0 1d 80 	movl   $0x801da0,0x8(%esp)
  801430:	00 
  801431:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801438:	00 
  801439:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  801440:	e8 57 02 00 00       	call   80169c <_panic>

00801445 <pfork>:
	return -E_INVAL;
}

envid_t
pfork(int pr)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	57                   	push   %edi
  801449:	56                   	push   %esi
  80144a:	53                   	push   %ebx
  80144b:	83 ec 1c             	sub    $0x1c,%esp
    set_pgfault_handler(pgfault);
  80144e:	c7 04 24 bf 11 80 00 	movl   $0x8011bf,(%esp)
  801455:	e8 9a 02 00 00       	call   8016f4 <set_pgfault_handler>
  80145a:	be 07 00 00 00       	mov    $0x7,%esi
  80145f:	89 f0                	mov    %esi,%eax
  801461:	cd 30                	int    $0x30
  801463:	89 c6                	mov    %eax,%esi
  801465:	89 c7                	mov    %eax,%edi

    envid_t envid;
    uint32_t addr;
    envid = sys_exofork();
    if (envid == 0) {
  801467:	85 c0                	test   %eax,%eax
  801469:	75 27                	jne    801492 <pfork+0x4d>
        thisenv = &envs[ENVX(sys_getenvid())];
  80146b:	e8 7c f9 ff ff       	call   800dec <sys_getenvid>
  801470:	25 ff 03 00 00       	and    $0x3ff,%eax
  801475:	c1 e0 07             	shl    $0x7,%eax
  801478:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80147d:	a3 08 20 80 00       	mov    %eax,0x802008
        sys_change_pr(pr);
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	89 04 24             	mov    %eax,(%esp)
  801488:	e8 27 fc ff ff       	call   8010b4 <sys_change_pr>
        return 0;
  80148d:	e9 e1 00 00 00       	jmp    801573 <pfork+0x12e>
    }

    if (envid < 0)
  801492:	85 c0                	test   %eax,%eax
  801494:	79 20                	jns    8014b6 <pfork+0x71>
        panic("sys_exofork: %e", envid);
  801496:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80149a:	c7 44 24 08 7b 1d 80 	movl   $0x801d7b,0x8(%esp)
  8014a1:	00 
  8014a2:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8014a9:	00 
  8014aa:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  8014b1:	e8 e6 01 00 00       	call   80169c <_panic>
        thisenv = &envs[ENVX(sys_getenvid())];
        sys_change_pr(pr);
        return 0;
    }

    if (envid < 0)
  8014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8014bb:	89 d8                	mov    %ebx,%eax
  8014bd:	c1 e8 16             	shr    $0x16,%eax
  8014c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c7:	a8 01                	test   $0x1,%al
  8014c9:	74 22                	je     8014ed <pfork+0xa8>
  8014cb:	89 da                	mov    %ebx,%edx
  8014cd:	c1 ea 0c             	shr    $0xc,%edx
  8014d0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014d7:	a8 01                	test   $0x1,%al
  8014d9:	74 12                	je     8014ed <pfork+0xa8>
            && (uvpt[PGNUM(addr)] & PTE_U)) {
  8014db:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014e2:	a8 04                	test   $0x4,%al
  8014e4:	74 07                	je     8014ed <pfork+0xa8>
            duppage(envid, PGNUM(addr));
  8014e6:	89 f8                	mov    %edi,%eax
  8014e8:	e8 fb fb ff ff       	call   8010e8 <duppage>
    }

    if (envid < 0)
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8014ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014f3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8014f9:	75 c0                	jne    8014bb <pfork+0x76>
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
            && (uvpt[PGNUM(addr)] & PTE_U)) {
            duppage(envid, PGNUM(addr));
        }

    if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8014fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801502:	00 
  801503:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80150a:	ee 
  80150b:	89 34 24             	mov    %esi,(%esp)
  80150e:	e8 39 f9 ff ff       	call   800e4c <sys_page_alloc>
  801513:	85 c0                	test   %eax,%eax
  801515:	79 1c                	jns    801533 <pfork+0xee>
        panic("1");
  801517:	c7 44 24 08 8b 1d 80 	movl   $0x801d8b,0x8(%esp)
  80151e:	00 
  80151f:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801526:	00 
  801527:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  80152e:	e8 69 01 00 00       	call   80169c <_panic>
    extern void _pgfault_upcall();
    sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801533:	c7 44 24 04 80 17 80 	movl   $0x801780,0x4(%esp)
  80153a:	00 
  80153b:	89 34 24             	mov    %esi,(%esp)
  80153e:	e8 82 fa ff ff       	call   800fc5 <sys_env_set_pgfault_upcall>

    if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801543:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80154a:	00 
  80154b:	89 34 24             	mov    %esi,(%esp)
  80154e:	e8 14 fa ff ff       	call   800f67 <sys_env_set_status>
  801553:	85 c0                	test   %eax,%eax
  801555:	79 1c                	jns    801573 <pfork+0x12e>
        panic("sys_env_set_status");
  801557:	c7 44 24 08 8d 1d 80 	movl   $0x801d8d,0x8(%esp)
  80155e:	00 
  80155f:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801566:	00 
  801567:	c7 04 24 31 1d 80 00 	movl   $0x801d31,(%esp)
  80156e:	e8 29 01 00 00       	call   80169c <_panic>

    return envid;
    panic("fork not implemented");
  801573:	89 f0                	mov    %esi,%eax
  801575:	83 c4 1c             	add    $0x1c,%esp
  801578:	5b                   	pop    %ebx
  801579:	5e                   	pop    %esi
  80157a:	5f                   	pop    %edi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    
  80157d:	00 00                	add    %al,(%eax)
	...

00801580 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 10             	sub    $0x10,%esp
  801588:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80158b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801591:	85 db                	test   %ebx,%ebx
  801593:	74 06                	je     80159b <ipc_recv+0x1b>
  801595:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80159b:	85 f6                	test   %esi,%esi
  80159d:	74 06                	je     8015a5 <ipc_recv+0x25>
  80159f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8015ac:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 a0 fa ff ff       	call   801057 <sys_ipc_recv>
    if (ret) return ret;
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	75 24                	jne    8015df <ipc_recv+0x5f>
    if (from_env_store)
  8015bb:	85 db                	test   %ebx,%ebx
  8015bd:	74 0a                	je     8015c9 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  8015bf:	a1 08 20 80 00       	mov    0x802008,%eax
  8015c4:	8b 40 74             	mov    0x74(%eax),%eax
  8015c7:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8015c9:	85 f6                	test   %esi,%esi
  8015cb:	74 0a                	je     8015d7 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8015cd:	a1 08 20 80 00       	mov    0x802008,%eax
  8015d2:	8b 40 78             	mov    0x78(%eax),%eax
  8015d5:	89 06                	mov    %eax,(%esi)
    return thisenv->env_ipc_value;
  8015d7:	a1 08 20 80 00       	mov    0x802008,%eax
  8015dc:	8b 40 70             	mov    0x70(%eax),%eax
}
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	57                   	push   %edi
  8015ea:	56                   	push   %esi
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 1c             	sub    $0x1c,%esp
  8015ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8015f8:	85 db                	test   %ebx,%ebx
  8015fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8015ff:	0f 44 d8             	cmove  %eax,%ebx
  801602:	eb 2a                	jmp    80162e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801604:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801607:	74 20                	je     801629 <ipc_send+0x43>
  801609:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160d:	c7 44 24 08 b6 1d 80 	movl   $0x801db6,0x8(%esp)
  801614:	00 
  801615:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  80161c:	00 
  80161d:	c7 04 24 cd 1d 80 00 	movl   $0x801dcd,(%esp)
  801624:	e8 73 00 00 00       	call   80169c <_panic>
        sys_yield();
  801629:	e8 ee f7 ff ff       	call   800e1c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80162e:	8b 45 14             	mov    0x14(%ebp),%eax
  801631:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801635:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801639:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80163d:	89 34 24             	mov    %esi,(%esp)
  801640:	e8 de f9 ff ff       	call   801023 <sys_ipc_try_send>
  801645:	85 c0                	test   %eax,%eax
  801647:	75 bb                	jne    801604 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
        sys_yield();
    }
}
  801649:	83 c4 1c             	add    $0x1c,%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801657:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80165c:	39 c8                	cmp    %ecx,%eax
  80165e:	74 19                	je     801679 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801660:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801665:	89 c2                	mov    %eax,%edx
  801667:	c1 e2 07             	shl    $0x7,%edx
  80166a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801670:	8b 52 50             	mov    0x50(%edx),%edx
  801673:	39 ca                	cmp    %ecx,%edx
  801675:	75 14                	jne    80168b <ipc_find_env+0x3a>
  801677:	eb 05                	jmp    80167e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80167e:	c1 e0 07             	shl    $0x7,%eax
  801681:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801686:	8b 40 40             	mov    0x40(%eax),%eax
  801689:	eb 0e                	jmp    801699 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80168b:	83 c0 01             	add    $0x1,%eax
  80168e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801693:	75 d0                	jne    801665 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801695:	66 b8 00 00          	mov    $0x0,%ax
}
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    
	...

0080169c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8016a7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8016ad:	e8 3a f7 ff ff       	call   800dec <sys_getenvid>
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	c7 04 24 d8 1d 80 00 	movl   $0x801dd8,(%esp)
  8016cf:	e8 2b eb ff ff       	call   8001ff <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8016d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8016db:	89 04 24             	mov    %eax,(%esp)
  8016de:	e8 bb ea ff ff       	call   80019e <vcprintf>
	cprintf("\n");
  8016e3:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  8016ea:	e8 10 eb ff ff       	call   8001ff <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8016ef:	cc                   	int3   
  8016f0:	eb fd                	jmp    8016ef <_panic+0x53>
	...

008016f4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8016fa:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801701:	75 3c                	jne    80173f <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801703:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80170a:	00 
  80170b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801712:	ee 
  801713:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171a:	e8 2d f7 ff ff       	call   800e4c <sys_page_alloc>
  80171f:	85 c0                	test   %eax,%eax
  801721:	79 1c                	jns    80173f <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801723:	c7 44 24 08 fc 1d 80 	movl   $0x801dfc,0x8(%esp)
  80172a:	00 
  80172b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801732:	00 
  801733:	c7 04 24 60 1e 80 00 	movl   $0x801e60,(%esp)
  80173a:	e8 5d ff ff ff       	call   80169c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801747:	c7 44 24 04 80 17 80 	movl   $0x801780,0x4(%esp)
  80174e:	00 
  80174f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801756:	e8 6a f8 ff ff       	call   800fc5 <sys_env_set_pgfault_upcall>
  80175b:	85 c0                	test   %eax,%eax
  80175d:	79 1c                	jns    80177b <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80175f:	c7 44 24 08 28 1e 80 	movl   $0x801e28,0x8(%esp)
  801766:	00 
  801767:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80176e:	00 
  80176f:	c7 04 24 60 1e 80 00 	movl   $0x801e60,(%esp)
  801776:	e8 21 ff ff ff       	call   80169c <_panic>
}
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    
  80177d:	00 00                	add    %al,(%eax)
	...

00801780 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801780:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801781:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801786:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801788:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80178b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80178f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801794:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  801798:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80179a:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  80179d:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80179e:	83 c4 04             	add    $0x4,%esp
    popfl
  8017a1:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8017a2:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8017a3:	c3                   	ret    
	...

008017b0 <__udivdi3>:
  8017b0:	83 ec 1c             	sub    $0x1c,%esp
  8017b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8017b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8017bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8017bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8017c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8017c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8017cb:	85 ff                	test   %edi,%edi
  8017cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8017d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d5:	89 cd                	mov    %ecx,%ebp
  8017d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017db:	75 33                	jne    801810 <__udivdi3+0x60>
  8017dd:	39 f1                	cmp    %esi,%ecx
  8017df:	77 57                	ja     801838 <__udivdi3+0x88>
  8017e1:	85 c9                	test   %ecx,%ecx
  8017e3:	75 0b                	jne    8017f0 <__udivdi3+0x40>
  8017e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ea:	31 d2                	xor    %edx,%edx
  8017ec:	f7 f1                	div    %ecx
  8017ee:	89 c1                	mov    %eax,%ecx
  8017f0:	89 f0                	mov    %esi,%eax
  8017f2:	31 d2                	xor    %edx,%edx
  8017f4:	f7 f1                	div    %ecx
  8017f6:	89 c6                	mov    %eax,%esi
  8017f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8017fc:	f7 f1                	div    %ecx
  8017fe:	89 f2                	mov    %esi,%edx
  801800:	8b 74 24 10          	mov    0x10(%esp),%esi
  801804:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801808:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80180c:	83 c4 1c             	add    $0x1c,%esp
  80180f:	c3                   	ret    
  801810:	31 d2                	xor    %edx,%edx
  801812:	31 c0                	xor    %eax,%eax
  801814:	39 f7                	cmp    %esi,%edi
  801816:	77 e8                	ja     801800 <__udivdi3+0x50>
  801818:	0f bd cf             	bsr    %edi,%ecx
  80181b:	83 f1 1f             	xor    $0x1f,%ecx
  80181e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801822:	75 2c                	jne    801850 <__udivdi3+0xa0>
  801824:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801828:	76 04                	jbe    80182e <__udivdi3+0x7e>
  80182a:	39 f7                	cmp    %esi,%edi
  80182c:	73 d2                	jae    801800 <__udivdi3+0x50>
  80182e:	31 d2                	xor    %edx,%edx
  801830:	b8 01 00 00 00       	mov    $0x1,%eax
  801835:	eb c9                	jmp    801800 <__udivdi3+0x50>
  801837:	90                   	nop
  801838:	89 f2                	mov    %esi,%edx
  80183a:	f7 f1                	div    %ecx
  80183c:	31 d2                	xor    %edx,%edx
  80183e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801842:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801846:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80184a:	83 c4 1c             	add    $0x1c,%esp
  80184d:	c3                   	ret    
  80184e:	66 90                	xchg   %ax,%ax
  801850:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801855:	b8 20 00 00 00       	mov    $0x20,%eax
  80185a:	89 ea                	mov    %ebp,%edx
  80185c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801860:	d3 e7                	shl    %cl,%edi
  801862:	89 c1                	mov    %eax,%ecx
  801864:	d3 ea                	shr    %cl,%edx
  801866:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80186b:	09 fa                	or     %edi,%edx
  80186d:	89 f7                	mov    %esi,%edi
  80186f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801873:	89 f2                	mov    %esi,%edx
  801875:	8b 74 24 08          	mov    0x8(%esp),%esi
  801879:	d3 e5                	shl    %cl,%ebp
  80187b:	89 c1                	mov    %eax,%ecx
  80187d:	d3 ef                	shr    %cl,%edi
  80187f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801884:	d3 e2                	shl    %cl,%edx
  801886:	89 c1                	mov    %eax,%ecx
  801888:	d3 ee                	shr    %cl,%esi
  80188a:	09 d6                	or     %edx,%esi
  80188c:	89 fa                	mov    %edi,%edx
  80188e:	89 f0                	mov    %esi,%eax
  801890:	f7 74 24 0c          	divl   0xc(%esp)
  801894:	89 d7                	mov    %edx,%edi
  801896:	89 c6                	mov    %eax,%esi
  801898:	f7 e5                	mul    %ebp
  80189a:	39 d7                	cmp    %edx,%edi
  80189c:	72 22                	jb     8018c0 <__udivdi3+0x110>
  80189e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8018a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018a7:	d3 e5                	shl    %cl,%ebp
  8018a9:	39 c5                	cmp    %eax,%ebp
  8018ab:	73 04                	jae    8018b1 <__udivdi3+0x101>
  8018ad:	39 d7                	cmp    %edx,%edi
  8018af:	74 0f                	je     8018c0 <__udivdi3+0x110>
  8018b1:	89 f0                	mov    %esi,%eax
  8018b3:	31 d2                	xor    %edx,%edx
  8018b5:	e9 46 ff ff ff       	jmp    801800 <__udivdi3+0x50>
  8018ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8018c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8018c3:	31 d2                	xor    %edx,%edx
  8018c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8018c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8018cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8018d1:	83 c4 1c             	add    $0x1c,%esp
  8018d4:	c3                   	ret    
	...

008018e0 <__umoddi3>:
  8018e0:	83 ec 1c             	sub    $0x1c,%esp
  8018e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8018e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8018eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8018ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8018f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8018f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8018fb:	85 ed                	test   %ebp,%ebp
  8018fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801901:	89 44 24 08          	mov    %eax,0x8(%esp)
  801905:	89 cf                	mov    %ecx,%edi
  801907:	89 04 24             	mov    %eax,(%esp)
  80190a:	89 f2                	mov    %esi,%edx
  80190c:	75 1a                	jne    801928 <__umoddi3+0x48>
  80190e:	39 f1                	cmp    %esi,%ecx
  801910:	76 4e                	jbe    801960 <__umoddi3+0x80>
  801912:	f7 f1                	div    %ecx
  801914:	89 d0                	mov    %edx,%eax
  801916:	31 d2                	xor    %edx,%edx
  801918:	8b 74 24 10          	mov    0x10(%esp),%esi
  80191c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801920:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801924:	83 c4 1c             	add    $0x1c,%esp
  801927:	c3                   	ret    
  801928:	39 f5                	cmp    %esi,%ebp
  80192a:	77 54                	ja     801980 <__umoddi3+0xa0>
  80192c:	0f bd c5             	bsr    %ebp,%eax
  80192f:	83 f0 1f             	xor    $0x1f,%eax
  801932:	89 44 24 04          	mov    %eax,0x4(%esp)
  801936:	75 60                	jne    801998 <__umoddi3+0xb8>
  801938:	3b 0c 24             	cmp    (%esp),%ecx
  80193b:	0f 87 07 01 00 00    	ja     801a48 <__umoddi3+0x168>
  801941:	89 f2                	mov    %esi,%edx
  801943:	8b 34 24             	mov    (%esp),%esi
  801946:	29 ce                	sub    %ecx,%esi
  801948:	19 ea                	sbb    %ebp,%edx
  80194a:	89 34 24             	mov    %esi,(%esp)
  80194d:	8b 04 24             	mov    (%esp),%eax
  801950:	8b 74 24 10          	mov    0x10(%esp),%esi
  801954:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801958:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80195c:	83 c4 1c             	add    $0x1c,%esp
  80195f:	c3                   	ret    
  801960:	85 c9                	test   %ecx,%ecx
  801962:	75 0b                	jne    80196f <__umoddi3+0x8f>
  801964:	b8 01 00 00 00       	mov    $0x1,%eax
  801969:	31 d2                	xor    %edx,%edx
  80196b:	f7 f1                	div    %ecx
  80196d:	89 c1                	mov    %eax,%ecx
  80196f:	89 f0                	mov    %esi,%eax
  801971:	31 d2                	xor    %edx,%edx
  801973:	f7 f1                	div    %ecx
  801975:	8b 04 24             	mov    (%esp),%eax
  801978:	f7 f1                	div    %ecx
  80197a:	eb 98                	jmp    801914 <__umoddi3+0x34>
  80197c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801980:	89 f2                	mov    %esi,%edx
  801982:	8b 74 24 10          	mov    0x10(%esp),%esi
  801986:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80198a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80198e:	83 c4 1c             	add    $0x1c,%esp
  801991:	c3                   	ret    
  801992:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801998:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80199d:	89 e8                	mov    %ebp,%eax
  80199f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8019a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8019a8:	89 fa                	mov    %edi,%edx
  8019aa:	d3 e0                	shl    %cl,%eax
  8019ac:	89 e9                	mov    %ebp,%ecx
  8019ae:	d3 ea                	shr    %cl,%edx
  8019b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8019b5:	09 c2                	or     %eax,%edx
  8019b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019bb:	89 14 24             	mov    %edx,(%esp)
  8019be:	89 f2                	mov    %esi,%edx
  8019c0:	d3 e7                	shl    %cl,%edi
  8019c2:	89 e9                	mov    %ebp,%ecx
  8019c4:	d3 ea                	shr    %cl,%edx
  8019c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8019cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019cf:	d3 e6                	shl    %cl,%esi
  8019d1:	89 e9                	mov    %ebp,%ecx
  8019d3:	d3 e8                	shr    %cl,%eax
  8019d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8019da:	09 f0                	or     %esi,%eax
  8019dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8019e0:	f7 34 24             	divl   (%esp)
  8019e3:	d3 e6                	shl    %cl,%esi
  8019e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019e9:	89 d6                	mov    %edx,%esi
  8019eb:	f7 e7                	mul    %edi
  8019ed:	39 d6                	cmp    %edx,%esi
  8019ef:	89 c1                	mov    %eax,%ecx
  8019f1:	89 d7                	mov    %edx,%edi
  8019f3:	72 3f                	jb     801a34 <__umoddi3+0x154>
  8019f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8019f9:	72 35                	jb     801a30 <__umoddi3+0x150>
  8019fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019ff:	29 c8                	sub    %ecx,%eax
  801a01:	19 fe                	sbb    %edi,%esi
  801a03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801a08:	89 f2                	mov    %esi,%edx
  801a0a:	d3 e8                	shr    %cl,%eax
  801a0c:	89 e9                	mov    %ebp,%ecx
  801a0e:	d3 e2                	shl    %cl,%edx
  801a10:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801a15:	09 d0                	or     %edx,%eax
  801a17:	89 f2                	mov    %esi,%edx
  801a19:	d3 ea                	shr    %cl,%edx
  801a1b:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a1f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a23:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a27:	83 c4 1c             	add    $0x1c,%esp
  801a2a:	c3                   	ret    
  801a2b:	90                   	nop
  801a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a30:	39 d6                	cmp    %edx,%esi
  801a32:	75 c7                	jne    8019fb <__umoddi3+0x11b>
  801a34:	89 d7                	mov    %edx,%edi
  801a36:	89 c1                	mov    %eax,%ecx
  801a38:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  801a3c:	1b 3c 24             	sbb    (%esp),%edi
  801a3f:	eb ba                	jmp    8019fb <__umoddi3+0x11b>
  801a41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a48:	39 f5                	cmp    %esi,%ebp
  801a4a:	0f 82 f1 fe ff ff    	jb     801941 <__umoddi3+0x61>
  801a50:	e9 f8 fe ff ff       	jmp    80194d <__umoddi3+0x6d>
