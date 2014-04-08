
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 e4 10 00 00       	call   801126 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 0c 20 80 00    	mov    0x80200c,%ebx
  80004f:	e8 e8 0d 00 00       	call   800e3c <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 e0 14 80 00 	movl   $0x8014e0,(%esp)
  800063:	e8 eb 01 00 00       	call   800253 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 cc 0d 00 00       	call   800e3c <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 fa 14 80 00 	movl   $0x8014fa,(%esp)
  80007f:	e8 cf 01 00 00       	call   800253 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 c3 10 00 00       	call   80116a <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 86 10 00 00       	call   801148 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 0c 20 80 00    	mov    0x80200c,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 60 0d 00 00       	call   800e3c <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 10 15 80 00 	movl   $0x801510,(%esp)
  8000fa:	e8 54 01 00 00       	call   800253 <cprintf>
		if (val == 10)
  8000ff:	a1 08 20 80 00       	mov    0x802008,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 08 20 80 00       	mov    %eax,0x802008
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 36 10 00 00       	call   80116a <ipc_send>
		if (val == 10)
  800134:	83 3d 08 20 80 00 0a 	cmpl   $0xa,0x802008
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80015e:	e8 d9 0c 00 00       	call   800e3c <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 a8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018c:	e8 0b 00 00 00       	call   80019c <exit>
}
  800191:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800194:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800197:	89 ec                	mov    %ebp,%esp
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 31 0c 00 00       	call   800ddf <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	83 c0 01             	add    $0x1,%eax
  8001c6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cd:	75 19                	jne    8001e8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001cf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d6:	00 
  8001d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	e8 9e 0b 00 00       	call   800d80 <sys_cputs>
		b->idx = 0;
  8001e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800202:	00 00 00 
	b.cnt = 0;
  800205:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800212:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800223:	89 44 24 04          	mov    %eax,0x4(%esp)
  800227:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022e:	e8 97 01 00 00       	call   8003ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800233:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	e8 35 0b 00 00       	call   800d80 <sys_cputs>

	return b.cnt;
}
  80024b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800259:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 87 ff ff ff       	call   8001f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	b8 00 00 00 00       	mov    $0x0,%eax
  800295:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800298:	72 11                	jb     8002ab <printnum+0x3b>
  80029a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029d:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a0:	76 09                	jbe    8002ab <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a2:	83 eb 01             	sub    $0x1,%ebx
  8002a5:	85 db                	test   %ebx,%ebx
  8002a7:	7f 51                	jg     8002fa <printnum+0x8a>
  8002a9:	eb 5e                	jmp    800309 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cc:	00 
  8002cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002da:	e8 51 0f 00 00       	call   801230 <__udivdi3>
  8002df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ee:	89 fa                	mov    %edi,%edx
  8002f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f3:	e8 78 ff ff ff       	call   800270 <printnum>
  8002f8:	eb 0f                	jmp    800309 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fe:	89 34 24             	mov    %esi,(%esp)
  800301:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800304:	83 eb 01             	sub    $0x1,%ebx
  800307:	75 f1                	jne    8002fa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800311:	8b 45 10             	mov    0x10(%ebp),%eax
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	e8 2e 10 00 00       	call   801360 <__umoddi3>
  800332:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800336:	0f be 80 40 15 80 00 	movsbl 0x801540(%eax),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800343:	83 c4 3c             	add    $0x3c,%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034e:	83 fa 01             	cmp    $0x1,%edx
  800351:	7e 0e                	jle    800361 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800353:	8b 10                	mov    (%eax),%edx
  800355:	8d 4a 08             	lea    0x8(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 02                	mov    (%edx),%eax
  80035c:	8b 52 04             	mov    0x4(%edx),%edx
  80035f:	eb 22                	jmp    800383 <getuint+0x38>
	else if (lflag)
  800361:	85 d2                	test   %edx,%edx
  800363:	74 10                	je     800375 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800365:	8b 10                	mov    (%eax),%edx
  800367:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036a:	89 08                	mov    %ecx,(%eax)
  80036c:	8b 02                	mov    (%edx),%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	eb 0e                	jmp    800383 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800375:	8b 10                	mov    (%eax),%edx
  800377:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037a:	89 08                	mov    %ecx,(%eax)
  80037c:	8b 02                	mov    (%edx),%eax
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	3b 50 04             	cmp    0x4(%eax),%edx
  800394:	73 0a                	jae    8003a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800396:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800399:	88 0a                	mov    %cl,(%edx)
  80039b:	83 c2 01             	add    $0x1,%edx
  80039e:	89 10                	mov    %edx,(%eax)
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003af:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 02 00 00 00       	call   8003ca <vprintfmt>
	va_end(ap);
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 5c             	sub    $0x5c,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 e4 04 00 00    	je     8008c7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	0f b6 06             	movzbl (%esi),%eax
  8003f0:	83 c6 01             	add    $0x1,%esi
  8003f3:	83 f8 25             	cmp    $0x25,%eax
  8003f6:	75 e3                	jne    8003db <vprintfmt+0x11>
  8003f8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003fc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800403:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800408:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80040f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800414:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800417:	eb 2b                	jmp    800444 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800420:	eb 22                	jmp    800444 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800425:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800429:	eb 19                	jmp    800444 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80042e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800435:	eb 0d                	jmp    800444 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800437:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80043a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80043d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	0f b6 06             	movzbl (%esi),%eax
  800447:	0f b6 d0             	movzbl %al,%edx
  80044a:	8d 7e 01             	lea    0x1(%esi),%edi
  80044d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800450:	83 e8 23             	sub    $0x23,%eax
  800453:	3c 55                	cmp    $0x55,%al
  800455:	0f 87 46 04 00 00    	ja     8008a1 <vprintfmt+0x4d7>
  80045b:	0f b6 c0             	movzbl %al,%eax
  80045e:	ff 24 85 20 16 80 00 	jmp    *0x801620(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800465:	83 ea 30             	sub    $0x30,%edx
  800468:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80046b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80046f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800475:	83 fa 09             	cmp    $0x9,%edx
  800478:	77 4a                	ja     8004c4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800480:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800483:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800487:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80048a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80048d:	83 fa 09             	cmp    $0x9,%edx
  800490:	76 eb                	jbe    80047d <vprintfmt+0xb3>
  800492:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800495:	eb 2d                	jmp    8004c4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 00                	mov    (%eax),%eax
  8004a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a8:	eb 1a                	jmp    8004c4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004ad:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004b1:	79 91                	jns    800444 <vprintfmt+0x7a>
  8004b3:	e9 73 ff ff ff       	jmp    80042b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004c2:	eb 80                	jmp    800444 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004c4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004c8:	0f 89 76 ff ff ff    	jns    800444 <vprintfmt+0x7a>
  8004ce:	e9 64 ff ff ff       	jmp    800437 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004d9:	e9 66 ff ff ff       	jmp    800444 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8d 50 04             	lea    0x4(%eax),%edx
  8004e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	89 04 24             	mov    %eax,(%esp)
  8004f0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f6:	e9 f2 fe ff ff       	jmp    8003ed <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004fb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004ff:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800502:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800506:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800509:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80050d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800510:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800513:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800517:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80051a:	80 f9 09             	cmp    $0x9,%cl
  80051d:	77 1d                	ja     80053c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	6b c0 64             	imul   $0x64,%eax,%eax
  800525:	0f be d2             	movsbl %dl,%edx
  800528:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80052b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800532:	a3 04 20 80 00       	mov    %eax,0x802004
  800537:	e9 b1 fe ff ff       	jmp    8003ed <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80053c:	c7 44 24 04 58 15 80 	movl   $0x801558,0x4(%esp)
  800543:	00 
  800544:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800547:	89 04 24             	mov    %eax,(%esp)
  80054a:	e8 0c 05 00 00       	call   800a5b <strcmp>
  80054f:	85 c0                	test   %eax,%eax
  800551:	75 0f                	jne    800562 <vprintfmt+0x198>
  800553:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80055a:	00 00 00 
  80055d:	e9 8b fe ff ff       	jmp    8003ed <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800562:	c7 44 24 04 5c 15 80 	movl   $0x80155c,0x4(%esp)
  800569:	00 
  80056a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80056d:	89 14 24             	mov    %edx,(%esp)
  800570:	e8 e6 04 00 00       	call   800a5b <strcmp>
  800575:	85 c0                	test   %eax,%eax
  800577:	75 0f                	jne    800588 <vprintfmt+0x1be>
  800579:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800580:	00 00 00 
  800583:	e9 65 fe ff ff       	jmp    8003ed <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800588:	c7 44 24 04 60 15 80 	movl   $0x801560,0x4(%esp)
  80058f:	00 
  800590:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800593:	89 0c 24             	mov    %ecx,(%esp)
  800596:	e8 c0 04 00 00       	call   800a5b <strcmp>
  80059b:	85 c0                	test   %eax,%eax
  80059d:	75 0f                	jne    8005ae <vprintfmt+0x1e4>
  80059f:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005a6:	00 00 00 
  8005a9:	e9 3f fe ff ff       	jmp    8003ed <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005ae:	c7 44 24 04 64 15 80 	movl   $0x801564,0x4(%esp)
  8005b5:	00 
  8005b6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005b9:	89 3c 24             	mov    %edi,(%esp)
  8005bc:	e8 9a 04 00 00       	call   800a5b <strcmp>
  8005c1:	85 c0                	test   %eax,%eax
  8005c3:	75 0f                	jne    8005d4 <vprintfmt+0x20a>
  8005c5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005cc:	00 00 00 
  8005cf:	e9 19 fe ff ff       	jmp    8003ed <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005d4:	c7 44 24 04 68 15 80 	movl   $0x801568,0x4(%esp)
  8005db:	00 
  8005dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	e8 74 04 00 00       	call   800a5b <strcmp>
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	75 0f                	jne    8005fa <vprintfmt+0x230>
  8005eb:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8005f2:	00 00 00 
  8005f5:	e9 f3 fd ff ff       	jmp    8003ed <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005fa:	c7 44 24 04 6c 15 80 	movl   $0x80156c,0x4(%esp)
  800601:	00 
  800602:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800605:	89 14 24             	mov    %edx,(%esp)
  800608:	e8 4e 04 00 00       	call   800a5b <strcmp>
  80060d:	83 f8 01             	cmp    $0x1,%eax
  800610:	19 c0                	sbb    %eax,%eax
  800612:	f7 d0                	not    %eax
  800614:	83 c0 08             	add    $0x8,%eax
  800617:	a3 04 20 80 00       	mov    %eax,0x802004
  80061c:	e9 cc fd ff ff       	jmp    8003ed <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 c2                	mov    %eax,%edx
  80062e:	c1 fa 1f             	sar    $0x1f,%edx
  800631:	31 d0                	xor    %edx,%eax
  800633:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800635:	83 f8 08             	cmp    $0x8,%eax
  800638:	7f 0b                	jg     800645 <vprintfmt+0x27b>
  80063a:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  800641:	85 d2                	test   %edx,%edx
  800643:	75 23                	jne    800668 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800645:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800649:	c7 44 24 08 70 15 80 	movl   $0x801570,0x8(%esp)
  800650:	00 
  800651:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800655:	8b 7d 08             	mov    0x8(%ebp),%edi
  800658:	89 3c 24             	mov    %edi,(%esp)
  80065b:	e8 42 fd ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800660:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800663:	e9 85 fd ff ff       	jmp    8003ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800668:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80066c:	c7 44 24 08 79 15 80 	movl   $0x801579,0x8(%esp)
  800673:	00 
  800674:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800678:	8b 7d 08             	mov    0x8(%ebp),%edi
  80067b:	89 3c 24             	mov    %edi,(%esp)
  80067e:	e8 1f fd ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800683:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800686:	e9 62 fd ff ff       	jmp    8003ed <vprintfmt+0x23>
  80068b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80068e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800691:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80069f:	85 f6                	test   %esi,%esi
  8006a1:	b8 51 15 80 00       	mov    $0x801551,%eax
  8006a6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006a9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006ad:	7e 06                	jle    8006b5 <vprintfmt+0x2eb>
  8006af:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006b3:	75 13                	jne    8006c8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b5:	0f be 06             	movsbl (%esi),%eax
  8006b8:	83 c6 01             	add    $0x1,%esi
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	0f 85 94 00 00 00    	jne    800757 <vprintfmt+0x38d>
  8006c3:	e9 81 00 00 00       	jmp    800749 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cc:	89 34 24             	mov    %esi,(%esp)
  8006cf:	e8 97 02 00 00       	call   80096b <strnlen>
  8006d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006d7:	29 c2                	sub    %eax,%edx
  8006d9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	7e d5                	jle    8006b5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006e0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006e4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006e7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006ea:	89 d6                	mov    %edx,%esi
  8006ec:	89 cf                	mov    %ecx,%edi
  8006ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f2:	89 3c 24             	mov    %edi,(%esp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f8:	83 ee 01             	sub    $0x1,%esi
  8006fb:	75 f1                	jne    8006ee <vprintfmt+0x324>
  8006fd:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800700:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800703:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800706:	eb ad                	jmp    8006b5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800708:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80070c:	74 1b                	je     800729 <vprintfmt+0x35f>
  80070e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800711:	83 fa 5e             	cmp    $0x5e,%edx
  800714:	76 13                	jbe    800729 <vprintfmt+0x35f>
					putch('?', putdat);
  800716:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800724:	ff 55 08             	call   *0x8(%ebp)
  800727:	eb 0d                	jmp    800736 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800729:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80072c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800736:	83 eb 01             	sub    $0x1,%ebx
  800739:	0f be 06             	movsbl (%esi),%eax
  80073c:	83 c6 01             	add    $0x1,%esi
  80073f:	85 c0                	test   %eax,%eax
  800741:	75 1a                	jne    80075d <vprintfmt+0x393>
  800743:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800746:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800749:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800750:	7f 1c                	jg     80076e <vprintfmt+0x3a4>
  800752:	e9 96 fc ff ff       	jmp    8003ed <vprintfmt+0x23>
  800757:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80075a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075d:	85 ff                	test   %edi,%edi
  80075f:	78 a7                	js     800708 <vprintfmt+0x33e>
  800761:	83 ef 01             	sub    $0x1,%edi
  800764:	79 a2                	jns    800708 <vprintfmt+0x33e>
  800766:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800769:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80076c:	eb db                	jmp    800749 <vprintfmt+0x37f>
  80076e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800771:	89 de                	mov    %ebx,%esi
  800773:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800781:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800783:	83 eb 01             	sub    $0x1,%ebx
  800786:	75 ee                	jne    800776 <vprintfmt+0x3ac>
  800788:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80078d:	e9 5b fc ff ff       	jmp    8003ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800792:	83 f9 01             	cmp    $0x1,%ecx
  800795:	7e 10                	jle    8007a7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 08             	lea    0x8(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 30                	mov    (%eax),%esi
  8007a2:	8b 78 04             	mov    0x4(%eax),%edi
  8007a5:	eb 26                	jmp    8007cd <vprintfmt+0x403>
	else if (lflag)
  8007a7:	85 c9                	test   %ecx,%ecx
  8007a9:	74 12                	je     8007bd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 04             	lea    0x4(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 30                	mov    (%eax),%esi
  8007b6:	89 f7                	mov    %esi,%edi
  8007b8:	c1 ff 1f             	sar    $0x1f,%edi
  8007bb:	eb 10                	jmp    8007cd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 04             	lea    0x4(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 30                	mov    (%eax),%esi
  8007c8:	89 f7                	mov    %esi,%edi
  8007ca:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007cd:	85 ff                	test   %edi,%edi
  8007cf:	78 0e                	js     8007df <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d5:	be 0a 00 00 00       	mov    $0xa,%esi
  8007da:	e9 84 00 00 00       	jmp    800863 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007ed:	89 f0                	mov    %esi,%eax
  8007ef:	89 fa                	mov    %edi,%edx
  8007f1:	f7 d8                	neg    %eax
  8007f3:	83 d2 00             	adc    $0x0,%edx
  8007f6:	f7 da                	neg    %edx
			}
			base = 10;
  8007f8:	be 0a 00 00 00       	mov    $0xa,%esi
  8007fd:	eb 64                	jmp    800863 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ff:	89 ca                	mov    %ecx,%edx
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
  800804:	e8 42 fb ff ff       	call   80034b <getuint>
			base = 10;
  800809:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80080e:	eb 53                	jmp    800863 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800810:	89 ca                	mov    %ecx,%edx
  800812:	8d 45 14             	lea    0x14(%ebp),%eax
  800815:	e8 31 fb ff ff       	call   80034b <getuint>
    			base = 8;
  80081a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80081f:	eb 42                	jmp    800863 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800821:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800825:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80082c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80082f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800833:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80083a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8d 50 04             	lea    0x4(%eax),%edx
  800843:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800846:	8b 00                	mov    (%eax),%eax
  800848:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80084d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800852:	eb 0f                	jmp    800863 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800854:	89 ca                	mov    %ecx,%edx
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	e8 ed fa ff ff       	call   80034b <getuint>
			base = 16;
  80085e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800863:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800867:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80086b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80086e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800872:	89 74 24 08          	mov    %esi,0x8(%esp)
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087d:	89 da                	mov    %ebx,%edx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	e8 e9 f9 ff ff       	call   800270 <printnum>
			break;
  800887:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80088a:	e9 5e fb ff ff       	jmp    8003ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800893:	89 14 24             	mov    %edx,(%esp)
  800896:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800899:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80089c:	e9 4c fb ff ff       	jmp    8003ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008ac:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008af:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008b3:	0f 84 34 fb ff ff    	je     8003ed <vprintfmt+0x23>
  8008b9:	83 ee 01             	sub    $0x1,%esi
  8008bc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008c0:	75 f7                	jne    8008b9 <vprintfmt+0x4ef>
  8008c2:	e9 26 fb ff ff       	jmp    8003ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008c7:	83 c4 5c             	add    $0x5c,%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 28             	sub    $0x28,%esp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	74 30                	je     800920 <vsnprintf+0x51>
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	7e 2c                	jle    800920 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800902:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800905:	89 44 24 04          	mov    %eax,0x4(%esp)
  800909:	c7 04 24 85 03 80 00 	movl   $0x800385,(%esp)
  800910:	e8 b5 fa ff ff       	call   8003ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800915:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800918:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091e:	eb 05                	jmp    800925 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800920:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80092d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800930:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800934:	8b 45 10             	mov    0x10(%ebp),%eax
  800937:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	89 04 24             	mov    %eax,(%esp)
  800948:	e8 82 ff ff ff       	call   8008cf <vsnprintf>
	va_end(ap);

	return rc;
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    
	...

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	80 3a 00             	cmpb   $0x0,(%edx)
  80095e:	74 09                	je     800969 <strlen+0x19>
		n++;
  800960:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800963:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800967:	75 f7                	jne    800960 <strlen+0x10>
		n++;
	return n;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	85 c9                	test   %ecx,%ecx
  80097c:	74 1a                	je     800998 <strnlen+0x2d>
  80097e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800981:	74 15                	je     800998 <strnlen+0x2d>
  800983:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800988:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098a:	39 ca                	cmp    %ecx,%edx
  80098c:	74 0a                	je     800998 <strnlen+0x2d>
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800996:	75 f0                	jne    800988 <strnlen+0x1d>
		n++;
	return n;
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009b1:	83 c2 01             	add    $0x1,%edx
  8009b4:	84 c9                	test   %cl,%cl
  8009b6:	75 f2                	jne    8009aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c5:	89 1c 24             	mov    %ebx,(%esp)
  8009c8:	e8 83 ff ff ff       	call   800950 <strlen>
	strcpy(dst + len, src);
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d4:	01 d8                	add    %ebx,%eax
  8009d6:	89 04 24             	mov    %eax,(%esp)
  8009d9:	e8 bd ff ff ff       	call   80099b <strcpy>
	return dst;
}
  8009de:	89 d8                	mov    %ebx,%eax
  8009e0:	83 c4 08             	add    $0x8,%esp
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f4:	85 f6                	test   %esi,%esi
  8009f6:	74 18                	je     800a10 <strncpy+0x2a>
  8009f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a03:	80 3a 01             	cmpb   $0x1,(%edx)
  800a06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	39 f1                	cmp    %esi,%ecx
  800a0e:	75 ed                	jne    8009fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a20:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a23:	89 f8                	mov    %edi,%eax
  800a25:	85 f6                	test   %esi,%esi
  800a27:	74 2b                	je     800a54 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a29:	83 fe 01             	cmp    $0x1,%esi
  800a2c:	74 23                	je     800a51 <strlcpy+0x3d>
  800a2e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a31:	84 c9                	test   %cl,%cl
  800a33:	74 1c                	je     800a51 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a35:	83 ee 02             	sub    $0x2,%esi
  800a38:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3d:	88 08                	mov    %cl,(%eax)
  800a3f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a42:	39 f2                	cmp    %esi,%edx
  800a44:	74 0b                	je     800a51 <strlcpy+0x3d>
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a4d:	84 c9                	test   %cl,%cl
  800a4f:	75 ec                	jne    800a3d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a54:	29 f8                	sub    %edi,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	84 c0                	test   %al,%al
  800a69:	74 16                	je     800a81 <strcmp+0x26>
  800a6b:	3a 02                	cmp    (%edx),%al
  800a6d:	75 12                	jne    800a81 <strcmp+0x26>
		p++, q++;
  800a6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a72:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a76:	84 c0                	test   %al,%al
  800a78:	74 07                	je     800a81 <strcmp+0x26>
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	3a 02                	cmp    (%edx),%al
  800a7f:	74 ee                	je     800a6f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a95:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9d:	85 d2                	test   %edx,%edx
  800a9f:	74 28                	je     800ac9 <strncmp+0x3e>
  800aa1:	0f b6 01             	movzbl (%ecx),%eax
  800aa4:	84 c0                	test   %al,%al
  800aa6:	74 24                	je     800acc <strncmp+0x41>
  800aa8:	3a 03                	cmp    (%ebx),%al
  800aaa:	75 20                	jne    800acc <strncmp+0x41>
  800aac:	83 ea 01             	sub    $0x1,%edx
  800aaf:	74 13                	je     800ac4 <strncmp+0x39>
		n--, p++, q++;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab7:	0f b6 01             	movzbl (%ecx),%eax
  800aba:	84 c0                	test   %al,%al
  800abc:	74 0e                	je     800acc <strncmp+0x41>
  800abe:	3a 03                	cmp    (%ebx),%al
  800ac0:	74 ea                	je     800aac <strncmp+0x21>
  800ac2:	eb 08                	jmp    800acc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800acc:	0f b6 01             	movzbl (%ecx),%eax
  800acf:	0f b6 13             	movzbl (%ebx),%edx
  800ad2:	29 d0                	sub    %edx,%eax
  800ad4:	eb f3                	jmp    800ac9 <strncmp+0x3e>

00800ad6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae0:	0f b6 10             	movzbl (%eax),%edx
  800ae3:	84 d2                	test   %dl,%dl
  800ae5:	74 1c                	je     800b03 <strchr+0x2d>
		if (*s == c)
  800ae7:	38 ca                	cmp    %cl,%dl
  800ae9:	75 09                	jne    800af4 <strchr+0x1e>
  800aeb:	eb 1b                	jmp    800b08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800af0:	38 ca                	cmp    %cl,%dl
  800af2:	74 14                	je     800b08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800af8:	84 d2                	test   %dl,%dl
  800afa:	75 f1                	jne    800aed <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	eb 05                	jmp    800b08 <strchr+0x32>
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b14:	0f b6 10             	movzbl (%eax),%edx
  800b17:	84 d2                	test   %dl,%dl
  800b19:	74 14                	je     800b2f <strfind+0x25>
		if (*s == c)
  800b1b:	38 ca                	cmp    %cl,%dl
  800b1d:	75 06                	jne    800b25 <strfind+0x1b>
  800b1f:	eb 0e                	jmp    800b2f <strfind+0x25>
  800b21:	38 ca                	cmp    %cl,%dl
  800b23:	74 0a                	je     800b2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b25:	83 c0 01             	add    $0x1,%eax
  800b28:	0f b6 10             	movzbl (%eax),%edx
  800b2b:	84 d2                	test   %dl,%dl
  800b2d:	75 f2                	jne    800b21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b3a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b3d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b49:	85 c9                	test   %ecx,%ecx
  800b4b:	74 30                	je     800b7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b53:	75 25                	jne    800b7a <memset+0x49>
  800b55:	f6 c1 03             	test   $0x3,%cl
  800b58:	75 20                	jne    800b7a <memset+0x49>
		c &= 0xFF;
  800b5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5d:	89 d3                	mov    %edx,%ebx
  800b5f:	c1 e3 08             	shl    $0x8,%ebx
  800b62:	89 d6                	mov    %edx,%esi
  800b64:	c1 e6 18             	shl    $0x18,%esi
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	c1 e0 10             	shl    $0x10,%eax
  800b6c:	09 f0                	or     %esi,%eax
  800b6e:	09 d0                	or     %edx,%eax
  800b70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b75:	fc                   	cld    
  800b76:	f3 ab                	rep stos %eax,%es:(%edi)
  800b78:	eb 03                	jmp    800b7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7a:	fc                   	cld    
  800b7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7d:	89 f8                	mov    %edi,%eax
  800b7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b88:	89 ec                	mov    %ebp,%esp
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 08             	sub    $0x8,%esp
  800b92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b95:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba1:	39 c6                	cmp    %eax,%esi
  800ba3:	73 36                	jae    800bdb <memmove+0x4f>
  800ba5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba8:	39 d0                	cmp    %edx,%eax
  800baa:	73 2f                	jae    800bdb <memmove+0x4f>
		s += n;
		d += n;
  800bac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baf:	f6 c2 03             	test   $0x3,%dl
  800bb2:	75 1b                	jne    800bcf <memmove+0x43>
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 13                	jne    800bcf <memmove+0x43>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 0e                	jne    800bcf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc1:	83 ef 04             	sub    $0x4,%edi
  800bc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bca:	fd                   	std    
  800bcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcd:	eb 09                	jmp    800bd8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bcf:	83 ef 01             	sub    $0x1,%edi
  800bd2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bd5:	fd                   	std    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd8:	fc                   	cld    
  800bd9:	eb 20                	jmp    800bfb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be1:	75 13                	jne    800bf6 <memmove+0x6a>
  800be3:	a8 03                	test   $0x3,%al
  800be5:	75 0f                	jne    800bf6 <memmove+0x6a>
  800be7:	f6 c1 03             	test   $0x3,%cl
  800bea:	75 0a                	jne    800bf6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	fc                   	cld    
  800bf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf4:	eb 05                	jmp    800bfb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	fc                   	cld    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bfb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bfe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c01:	89 ec                	mov    %ebp,%esp
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	89 04 24             	mov    %eax,(%esp)
  800c1f:	e8 68 ff ff ff       	call   800b8c <memmove>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c32:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	74 37                	je     800c75 <memcmp+0x4f>
		if (*s1 != *s2)
  800c3e:	0f b6 03             	movzbl (%ebx),%eax
  800c41:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c44:	83 ef 01             	sub    $0x1,%edi
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c4c:	38 c8                	cmp    %cl,%al
  800c4e:	74 1c                	je     800c6c <memcmp+0x46>
  800c50:	eb 10                	jmp    800c62 <memcmp+0x3c>
  800c52:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c5e:	38 c8                	cmp    %cl,%al
  800c60:	74 0a                	je     800c6c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c62:	0f b6 c0             	movzbl %al,%eax
  800c65:	0f b6 c9             	movzbl %cl,%ecx
  800c68:	29 c8                	sub    %ecx,%eax
  800c6a:	eb 09                	jmp    800c75 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6c:	39 fa                	cmp    %edi,%edx
  800c6e:	75 e2                	jne    800c52 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c80:	89 c2                	mov    %eax,%edx
  800c82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c85:	39 d0                	cmp    %edx,%eax
  800c87:	73 19                	jae    800ca2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c8d:	38 08                	cmp    %cl,(%eax)
  800c8f:	75 06                	jne    800c97 <memfind+0x1d>
  800c91:	eb 0f                	jmp    800ca2 <memfind+0x28>
  800c93:	38 08                	cmp    %cl,(%eax)
  800c95:	74 0b                	je     800ca2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	39 d0                	cmp    %edx,%eax
  800c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	75 f1                	jne    800c93 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb0:	0f b6 02             	movzbl (%edx),%eax
  800cb3:	3c 20                	cmp    $0x20,%al
  800cb5:	74 04                	je     800cbb <strtol+0x17>
  800cb7:	3c 09                	cmp    $0x9,%al
  800cb9:	75 0e                	jne    800cc9 <strtol+0x25>
		s++;
  800cbb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cbe:	0f b6 02             	movzbl (%edx),%eax
  800cc1:	3c 20                	cmp    $0x20,%al
  800cc3:	74 f6                	je     800cbb <strtol+0x17>
  800cc5:	3c 09                	cmp    $0x9,%al
  800cc7:	74 f2                	je     800cbb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc9:	3c 2b                	cmp    $0x2b,%al
  800ccb:	75 0a                	jne    800cd7 <strtol+0x33>
		s++;
  800ccd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd5:	eb 10                	jmp    800ce7 <strtol+0x43>
  800cd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cdc:	3c 2d                	cmp    $0x2d,%al
  800cde:	75 07                	jne    800ce7 <strtol+0x43>
		s++, neg = 1;
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce7:	85 db                	test   %ebx,%ebx
  800ce9:	0f 94 c0             	sete   %al
  800cec:	74 05                	je     800cf3 <strtol+0x4f>
  800cee:	83 fb 10             	cmp    $0x10,%ebx
  800cf1:	75 15                	jne    800d08 <strtol+0x64>
  800cf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cf6:	75 10                	jne    800d08 <strtol+0x64>
  800cf8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cfc:	75 0a                	jne    800d08 <strtol+0x64>
		s += 2, base = 16;
  800cfe:	83 c2 02             	add    $0x2,%edx
  800d01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d06:	eb 13                	jmp    800d1b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d08:	84 c0                	test   %al,%al
  800d0a:	74 0f                	je     800d1b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d11:	80 3a 30             	cmpb   $0x30,(%edx)
  800d14:	75 05                	jne    800d1b <strtol+0x77>
		s++, base = 8;
  800d16:	83 c2 01             	add    $0x1,%edx
  800d19:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d22:	0f b6 0a             	movzbl (%edx),%ecx
  800d25:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d28:	80 fb 09             	cmp    $0x9,%bl
  800d2b:	77 08                	ja     800d35 <strtol+0x91>
			dig = *s - '0';
  800d2d:	0f be c9             	movsbl %cl,%ecx
  800d30:	83 e9 30             	sub    $0x30,%ecx
  800d33:	eb 1e                	jmp    800d53 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d35:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d38:	80 fb 19             	cmp    $0x19,%bl
  800d3b:	77 08                	ja     800d45 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d3d:	0f be c9             	movsbl %cl,%ecx
  800d40:	83 e9 57             	sub    $0x57,%ecx
  800d43:	eb 0e                	jmp    800d53 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d45:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d48:	80 fb 19             	cmp    $0x19,%bl
  800d4b:	77 14                	ja     800d61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d4d:	0f be c9             	movsbl %cl,%ecx
  800d50:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d53:	39 f1                	cmp    %esi,%ecx
  800d55:	7d 0e                	jge    800d65 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d57:	83 c2 01             	add    $0x1,%edx
  800d5a:	0f af c6             	imul   %esi,%eax
  800d5d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d5f:	eb c1                	jmp    800d22 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d61:	89 c1                	mov    %eax,%ecx
  800d63:	eb 02                	jmp    800d67 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d65:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d6b:	74 05                	je     800d72 <strtol+0xce>
		*endptr = (char *) s;
  800d6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d70:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d72:	89 ca                	mov    %ecx,%edx
  800d74:	f7 da                	neg    %edx
  800d76:	85 ff                	test   %edi,%edi
  800d78:	0f 45 c2             	cmovne %edx,%eax
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	89 c7                	mov    %eax,%edi
  800d9e:	89 c6                	mov    %eax,%esi
  800da0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dab:	89 ec                	mov    %ebp,%esp
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_cgetc>:

int
sys_cgetc(void)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc8:	89 d1                	mov    %edx,%ecx
  800dca:	89 d3                	mov    %edx,%ebx
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	89 d6                	mov    %edx,%esi
  800dd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 38             	sub    $0x38,%esp
  800de5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800deb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df3:	b8 03 00 00 00       	mov    $0x3,%eax
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 cb                	mov    %ecx,%ebx
  800dfd:	89 cf                	mov    %ecx,%edi
  800dff:	89 ce                	mov    %ecx,%esi
  800e01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7e 28                	jle    800e2f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e12:	00 
  800e13:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800e1a:	00 
  800e1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e22:	00 
  800e23:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800e2a:	e8 a5 03 00 00       	call   8011d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e38:	89 ec                	mov    %ebp,%esp
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e50:	b8 02 00 00 00       	mov    $0x2,%eax
  800e55:	89 d1                	mov    %edx,%ecx
  800e57:	89 d3                	mov    %edx,%ebx
  800e59:	89 d7                	mov    %edx,%edi
  800e5b:	89 d6                	mov    %edx,%esi
  800e5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_yield>:

void
sys_yield(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 d3                	mov    %edx,%ebx
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 38             	sub    $0x38,%esp
  800ea2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eab:	be 00 00 00 00       	mov    $0x0,%esi
  800eb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 f7                	mov    %esi,%edi
  800ec0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800ee9:	e8 e6 02 00 00       	call   8011d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef7:	89 ec                	mov    %ebp,%esp
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 38             	sub    $0x38,%esp
  800f01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	7e 28                	jle    800f4c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f2f:	00 
  800f30:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800f37:	00 
  800f38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3f:	00 
  800f40:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800f47:	e8 88 02 00 00       	call   8011d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f55:	89 ec                	mov    %ebp,%esp
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 38             	sub    $0x38,%esp
  800f5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	89 df                	mov    %ebx,%edi
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 28                	jle    800faa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800f95:	00 
  800f96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800fa5:	e8 2a 02 00 00       	call   8011d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800faa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb3:	89 ec                	mov    %ebp,%esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 38             	sub    $0x38,%esp
  800fbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  801003:	e8 cc 01 00 00       	call   8011d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801008:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801011:	89 ec                	mov    %ebp,%esp
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 38             	sub    $0x38,%esp
  80101b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80101e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801021:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
  801029:	b8 09 00 00 00       	mov    $0x9,%eax
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	8b 55 08             	mov    0x8(%ebp),%edx
  801034:	89 df                	mov    %ebx,%edi
  801036:	89 de                	mov    %ebx,%esi
  801038:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	7e 28                	jle    801066 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801042:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801049:	00 
  80104a:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  801051:	00 
  801052:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801059:	00 
  80105a:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  801061:	e8 6e 01 00 00       	call   8011d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801066:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801069:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80106f:	89 ec                	mov    %ebp,%esp
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80107c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80107f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	be 00 00 00 00       	mov    $0x0,%esi
  801087:	b8 0b 00 00 00       	mov    $0xb,%eax
  80108c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80108f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801092:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801095:	8b 55 08             	mov    0x8(%ebp),%edx
  801098:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80109a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80109d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010a3:	89 ec                	mov    %ebp,%esp
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	83 ec 38             	sub    $0x38,%esp
  8010ad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010b0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010b3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010bb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c3:	89 cb                	mov    %ecx,%ebx
  8010c5:	89 cf                	mov    %ecx,%edi
  8010c7:	89 ce                	mov    %ecx,%esi
  8010c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	7e 28                	jle    8010f7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8010da:	00 
  8010db:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ea:	00 
  8010eb:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  8010f2:	e8 dd 00 00 00       	call   8011d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801100:	89 ec                	mov    %ebp,%esp
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80110a:	c7 44 24 08 db 17 80 	movl   $0x8017db,0x8(%esp)
  801111:	00 
  801112:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 cf 17 80 00 	movl   $0x8017cf,(%esp)
  801121:	e8 ae 00 00 00       	call   8011d4 <_panic>

00801126 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80112c:	c7 44 24 08 da 17 80 	movl   $0x8017da,0x8(%esp)
  801133:	00 
  801134:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80113b:	00 
  80113c:	c7 04 24 cf 17 80 00 	movl   $0x8017cf,(%esp)
  801143:	e8 8c 00 00 00       	call   8011d4 <_panic>

00801148 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80114e:	c7 44 24 08 f0 17 80 	movl   $0x8017f0,0x8(%esp)
  801155:	00 
  801156:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80115d:	00 
  80115e:	c7 04 24 09 18 80 00 	movl   $0x801809,(%esp)
  801165:	e8 6a 00 00 00       	call   8011d4 <_panic>

0080116a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801170:	c7 44 24 08 13 18 80 	movl   $0x801813,0x8(%esp)
  801177:	00 
  801178:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80117f:	00 
  801180:	c7 04 24 09 18 80 00 	movl   $0x801809,(%esp)
  801187:	e8 48 00 00 00       	call   8011d4 <_panic>

0080118c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801192:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801197:	39 c8                	cmp    %ecx,%eax
  801199:	74 17                	je     8011b2 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80119b:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8011a0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011a3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011a9:	8b 52 50             	mov    0x50(%edx),%edx
  8011ac:	39 ca                	cmp    %ecx,%edx
  8011ae:	75 14                	jne    8011c4 <ipc_find_env+0x38>
  8011b0:	eb 05                	jmp    8011b7 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011b7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ba:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8011bf:	8b 40 40             	mov    0x40(%eax),%eax
  8011c2:	eb 0e                	jmp    8011d2 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011c4:	83 c0 01             	add    $0x1,%eax
  8011c7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011cc:	75 d2                	jne    8011a0 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011ce:	66 b8 00 00          	mov    $0x0,%ax
}
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011dc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011df:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8011e5:	e8 52 fc ff ff       	call   800e3c <sys_getenvid>
  8011ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801200:	c7 04 24 2c 18 80 00 	movl   $0x80182c,(%esp)
  801207:	e8 47 f0 ff ff       	call   800253 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80120c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801210:	8b 45 10             	mov    0x10(%ebp),%eax
  801213:	89 04 24             	mov    %eax,(%esp)
  801216:	e8 d7 ef ff ff       	call   8001f2 <vcprintf>
	cprintf("\n");
  80121b:	c7 04 24 f8 14 80 00 	movl   $0x8014f8,(%esp)
  801222:	e8 2c f0 ff ff       	call   800253 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801227:	cc                   	int3   
  801228:	eb fd                	jmp    801227 <_panic+0x53>
  80122a:	00 00                	add    %al,(%eax)
  80122c:	00 00                	add    %al,(%eax)
	...

00801230 <__udivdi3>:
  801230:	83 ec 1c             	sub    $0x1c,%esp
  801233:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801237:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80123b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80123f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801243:	89 74 24 10          	mov    %esi,0x10(%esp)
  801247:	8b 74 24 24          	mov    0x24(%esp),%esi
  80124b:	85 ff                	test   %edi,%edi
  80124d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801251:	89 44 24 08          	mov    %eax,0x8(%esp)
  801255:	89 cd                	mov    %ecx,%ebp
  801257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125b:	75 33                	jne    801290 <__udivdi3+0x60>
  80125d:	39 f1                	cmp    %esi,%ecx
  80125f:	77 57                	ja     8012b8 <__udivdi3+0x88>
  801261:	85 c9                	test   %ecx,%ecx
  801263:	75 0b                	jne    801270 <__udivdi3+0x40>
  801265:	b8 01 00 00 00       	mov    $0x1,%eax
  80126a:	31 d2                	xor    %edx,%edx
  80126c:	f7 f1                	div    %ecx
  80126e:	89 c1                	mov    %eax,%ecx
  801270:	89 f0                	mov    %esi,%eax
  801272:	31 d2                	xor    %edx,%edx
  801274:	f7 f1                	div    %ecx
  801276:	89 c6                	mov    %eax,%esi
  801278:	8b 44 24 04          	mov    0x4(%esp),%eax
  80127c:	f7 f1                	div    %ecx
  80127e:	89 f2                	mov    %esi,%edx
  801280:	8b 74 24 10          	mov    0x10(%esp),%esi
  801284:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801288:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80128c:	83 c4 1c             	add    $0x1c,%esp
  80128f:	c3                   	ret    
  801290:	31 d2                	xor    %edx,%edx
  801292:	31 c0                	xor    %eax,%eax
  801294:	39 f7                	cmp    %esi,%edi
  801296:	77 e8                	ja     801280 <__udivdi3+0x50>
  801298:	0f bd cf             	bsr    %edi,%ecx
  80129b:	83 f1 1f             	xor    $0x1f,%ecx
  80129e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012a2:	75 2c                	jne    8012d0 <__udivdi3+0xa0>
  8012a4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8012a8:	76 04                	jbe    8012ae <__udivdi3+0x7e>
  8012aa:	39 f7                	cmp    %esi,%edi
  8012ac:	73 d2                	jae    801280 <__udivdi3+0x50>
  8012ae:	31 d2                	xor    %edx,%edx
  8012b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b5:	eb c9                	jmp    801280 <__udivdi3+0x50>
  8012b7:	90                   	nop
  8012b8:	89 f2                	mov    %esi,%edx
  8012ba:	f7 f1                	div    %ecx
  8012bc:	31 d2                	xor    %edx,%edx
  8012be:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012c2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012c6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012ca:	83 c4 1c             	add    $0x1c,%esp
  8012cd:	c3                   	ret    
  8012ce:	66 90                	xchg   %ax,%ax
  8012d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d5:	b8 20 00 00 00       	mov    $0x20,%eax
  8012da:	89 ea                	mov    %ebp,%edx
  8012dc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8012e0:	d3 e7                	shl    %cl,%edi
  8012e2:	89 c1                	mov    %eax,%ecx
  8012e4:	d3 ea                	shr    %cl,%edx
  8012e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012eb:	09 fa                	or     %edi,%edx
  8012ed:	89 f7                	mov    %esi,%edi
  8012ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f3:	89 f2                	mov    %esi,%edx
  8012f5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012f9:	d3 e5                	shl    %cl,%ebp
  8012fb:	89 c1                	mov    %eax,%ecx
  8012fd:	d3 ef                	shr    %cl,%edi
  8012ff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801304:	d3 e2                	shl    %cl,%edx
  801306:	89 c1                	mov    %eax,%ecx
  801308:	d3 ee                	shr    %cl,%esi
  80130a:	09 d6                	or     %edx,%esi
  80130c:	89 fa                	mov    %edi,%edx
  80130e:	89 f0                	mov    %esi,%eax
  801310:	f7 74 24 0c          	divl   0xc(%esp)
  801314:	89 d7                	mov    %edx,%edi
  801316:	89 c6                	mov    %eax,%esi
  801318:	f7 e5                	mul    %ebp
  80131a:	39 d7                	cmp    %edx,%edi
  80131c:	72 22                	jb     801340 <__udivdi3+0x110>
  80131e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801322:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801327:	d3 e5                	shl    %cl,%ebp
  801329:	39 c5                	cmp    %eax,%ebp
  80132b:	73 04                	jae    801331 <__udivdi3+0x101>
  80132d:	39 d7                	cmp    %edx,%edi
  80132f:	74 0f                	je     801340 <__udivdi3+0x110>
  801331:	89 f0                	mov    %esi,%eax
  801333:	31 d2                	xor    %edx,%edx
  801335:	e9 46 ff ff ff       	jmp    801280 <__udivdi3+0x50>
  80133a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801340:	8d 46 ff             	lea    -0x1(%esi),%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	8b 74 24 10          	mov    0x10(%esp),%esi
  801349:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80134d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801351:	83 c4 1c             	add    $0x1c,%esp
  801354:	c3                   	ret    
	...

00801360 <__umoddi3>:
  801360:	83 ec 1c             	sub    $0x1c,%esp
  801363:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801367:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80136b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80136f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801373:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801377:	8b 74 24 24          	mov    0x24(%esp),%esi
  80137b:	85 ed                	test   %ebp,%ebp
  80137d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801381:	89 44 24 08          	mov    %eax,0x8(%esp)
  801385:	89 cf                	mov    %ecx,%edi
  801387:	89 04 24             	mov    %eax,(%esp)
  80138a:	89 f2                	mov    %esi,%edx
  80138c:	75 1a                	jne    8013a8 <__umoddi3+0x48>
  80138e:	39 f1                	cmp    %esi,%ecx
  801390:	76 4e                	jbe    8013e0 <__umoddi3+0x80>
  801392:	f7 f1                	div    %ecx
  801394:	89 d0                	mov    %edx,%eax
  801396:	31 d2                	xor    %edx,%edx
  801398:	8b 74 24 10          	mov    0x10(%esp),%esi
  80139c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013a4:	83 c4 1c             	add    $0x1c,%esp
  8013a7:	c3                   	ret    
  8013a8:	39 f5                	cmp    %esi,%ebp
  8013aa:	77 54                	ja     801400 <__umoddi3+0xa0>
  8013ac:	0f bd c5             	bsr    %ebp,%eax
  8013af:	83 f0 1f             	xor    $0x1f,%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	75 60                	jne    801418 <__umoddi3+0xb8>
  8013b8:	3b 0c 24             	cmp    (%esp),%ecx
  8013bb:	0f 87 07 01 00 00    	ja     8014c8 <__umoddi3+0x168>
  8013c1:	89 f2                	mov    %esi,%edx
  8013c3:	8b 34 24             	mov    (%esp),%esi
  8013c6:	29 ce                	sub    %ecx,%esi
  8013c8:	19 ea                	sbb    %ebp,%edx
  8013ca:	89 34 24             	mov    %esi,(%esp)
  8013cd:	8b 04 24             	mov    (%esp),%eax
  8013d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013dc:	83 c4 1c             	add    $0x1c,%esp
  8013df:	c3                   	ret    
  8013e0:	85 c9                	test   %ecx,%ecx
  8013e2:	75 0b                	jne    8013ef <__umoddi3+0x8f>
  8013e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e9:	31 d2                	xor    %edx,%edx
  8013eb:	f7 f1                	div    %ecx
  8013ed:	89 c1                	mov    %eax,%ecx
  8013ef:	89 f0                	mov    %esi,%eax
  8013f1:	31 d2                	xor    %edx,%edx
  8013f3:	f7 f1                	div    %ecx
  8013f5:	8b 04 24             	mov    (%esp),%eax
  8013f8:	f7 f1                	div    %ecx
  8013fa:	eb 98                	jmp    801394 <__umoddi3+0x34>
  8013fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801400:	89 f2                	mov    %esi,%edx
  801402:	8b 74 24 10          	mov    0x10(%esp),%esi
  801406:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80140a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80140e:	83 c4 1c             	add    $0x1c,%esp
  801411:	c3                   	ret    
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80141d:	89 e8                	mov    %ebp,%eax
  80141f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801424:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801428:	89 fa                	mov    %edi,%edx
  80142a:	d3 e0                	shl    %cl,%eax
  80142c:	89 e9                	mov    %ebp,%ecx
  80142e:	d3 ea                	shr    %cl,%edx
  801430:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801435:	09 c2                	or     %eax,%edx
  801437:	8b 44 24 08          	mov    0x8(%esp),%eax
  80143b:	89 14 24             	mov    %edx,(%esp)
  80143e:	89 f2                	mov    %esi,%edx
  801440:	d3 e7                	shl    %cl,%edi
  801442:	89 e9                	mov    %ebp,%ecx
  801444:	d3 ea                	shr    %cl,%edx
  801446:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80144b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80144f:	d3 e6                	shl    %cl,%esi
  801451:	89 e9                	mov    %ebp,%ecx
  801453:	d3 e8                	shr    %cl,%eax
  801455:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80145a:	09 f0                	or     %esi,%eax
  80145c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801460:	f7 34 24             	divl   (%esp)
  801463:	d3 e6                	shl    %cl,%esi
  801465:	89 74 24 08          	mov    %esi,0x8(%esp)
  801469:	89 d6                	mov    %edx,%esi
  80146b:	f7 e7                	mul    %edi
  80146d:	39 d6                	cmp    %edx,%esi
  80146f:	89 c1                	mov    %eax,%ecx
  801471:	89 d7                	mov    %edx,%edi
  801473:	72 3f                	jb     8014b4 <__umoddi3+0x154>
  801475:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801479:	72 35                	jb     8014b0 <__umoddi3+0x150>
  80147b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80147f:	29 c8                	sub    %ecx,%eax
  801481:	19 fe                	sbb    %edi,%esi
  801483:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801488:	89 f2                	mov    %esi,%edx
  80148a:	d3 e8                	shr    %cl,%eax
  80148c:	89 e9                	mov    %ebp,%ecx
  80148e:	d3 e2                	shl    %cl,%edx
  801490:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801495:	09 d0                	or     %edx,%eax
  801497:	89 f2                	mov    %esi,%edx
  801499:	d3 ea                	shr    %cl,%edx
  80149b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80149f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014a7:	83 c4 1c             	add    $0x1c,%esp
  8014aa:	c3                   	ret    
  8014ab:	90                   	nop
  8014ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	39 d6                	cmp    %edx,%esi
  8014b2:	75 c7                	jne    80147b <__umoddi3+0x11b>
  8014b4:	89 d7                	mov    %edx,%edi
  8014b6:	89 c1                	mov    %eax,%ecx
  8014b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8014bc:	1b 3c 24             	sbb    (%esp),%edi
  8014bf:	eb ba                	jmp    80147b <__umoddi3+0x11b>
  8014c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014c8:	39 f5                	cmp    %esi,%ebp
  8014ca:	0f 82 f1 fe ff ff    	jb     8013c1 <__umoddi3+0x61>
  8014d0:	e9 f8 fe ff ff       	jmp    8013cd <__umoddi3+0x6d>
