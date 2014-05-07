
obj/user/pingpongs.debug:     file format elf32-i386


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
  80003d:	e8 4c 15 00 00       	call   80158e <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 f8 0d 00 00       	call   800e4c <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 c0 28 80 00 	movl   $0x8028c0,(%esp)
  800063:	e8 f3 01 00 00       	call   80025b <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 dc 0d 00 00       	call   800e4c <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 da 28 80 00 	movl   $0x8028da,(%esp)
  80007f:	e8 d7 01 00 00       	call   80025b <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 6f 15 00 00       	call   801616 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 ee 14 00 00       	call   8015b0 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 70 0d 00 00       	call   800e4c <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  8000fa:	e8 5c 01 00 00       	call   80025b <cprintf>
		if (val == 10)
  8000ff:	a1 04 40 80 00       	mov    0x804004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 e2 14 00 00       	call   801616 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  80015e:	e8 e9 0c 00 00       	call   800e4c <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	c1 e0 07             	shl    $0x7,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8001a2:	e8 47 17 00 00       	call   8018ee <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 3c 0c 00 00       	call   800def <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 14             	sub    $0x14,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 03                	mov    (%ebx),%eax
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cb:	83 c0 01             	add    $0x1,%eax
  8001ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d5:	75 19                	jne    8001f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001de:	00 
  8001df:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 a6 0b 00 00       	call   800d90 <sys_cputs>
		b->idx = 0;
  8001ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f4:	83 c4 14             	add    $0x14,%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    

008001fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800203:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020a:	00 00 00 
	b.cnt = 0;
  80020d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800214:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	c7 04 24 b8 01 80 00 	movl   $0x8001b8,(%esp)
  800236:	e8 97 01 00 00       	call   8003d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024b:	89 04 24             	mov    %eax,(%esp)
  80024e:	e8 3d 0b 00 00       	call   800d90 <sys_cputs>

	return b.cnt;
}
  800253:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800261:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 87 ff ff ff       	call   8001fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    
  800275:	00 00                	add    %al,(%eax)
	...

00800278 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 3c             	sub    $0x3c,%esp
  800281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800284:	89 d7                	mov    %edx,%edi
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800292:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800295:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800298:	b8 00 00 00 00       	mov    $0x0,%eax
  80029d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a0:	72 11                	jb     8002b3 <printnum+0x3b>
  8002a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a8:	76 09                	jbe    8002b3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f 51                	jg     800302 <printnum+0x8a>
  8002b1:	eb 5e                	jmp    800311 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b7:	83 eb 01             	sub    $0x1,%ebx
  8002ba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002be:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d4:	00 
  8002d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e2:	e8 29 23 00 00       	call   802610 <__udivdi3>
  8002e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002eb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f6:	89 fa                	mov    %edi,%edx
  8002f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fb:	e8 78 ff ff ff       	call   800278 <printnum>
  800300:	eb 0f                	jmp    800311 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800302:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800306:	89 34 24             	mov    %esi,(%esp)
  800309:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030c:	83 eb 01             	sub    $0x1,%ebx
  80030f:	75 f1                	jne    800302 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800319:	8b 45 10             	mov    0x10(%ebp),%eax
  80031c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800320:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800327:	00 
  800328:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	e8 06 24 00 00       	call   802740 <__umoddi3>
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	0f be 80 20 29 80 00 	movsbl 0x802920(%eax),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034b:	83 c4 3c             	add    $0x3c,%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800356:	83 fa 01             	cmp    $0x1,%edx
  800359:	7e 0e                	jle    800369 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 02                	mov    (%edx),%eax
  800364:	8b 52 04             	mov    0x4(%edx),%edx
  800367:	eb 22                	jmp    80038b <getuint+0x38>
	else if (lflag)
  800369:	85 d2                	test   %edx,%edx
  80036b:	74 10                	je     80037d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 02                	mov    (%edx),%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	eb 0e                	jmp    80038b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800393:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800397:	8b 10                	mov    (%eax),%edx
  800399:	3b 50 04             	cmp    0x4(%eax),%edx
  80039c:	73 0a                	jae    8003a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a1:	88 0a                	mov    %cl,(%edx)
  8003a3:	83 c2 01             	add    $0x1,%edx
  8003a6:	89 10                	mov    %edx,(%eax)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	e8 02 00 00 00       	call   8003d2 <vprintfmt>
	va_end(ap);
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    

008003d2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 5c             	sub    $0x5c,%esp
  8003db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003de:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e1:	eb 12                	jmp    8003f5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	0f 84 e4 04 00 00    	je     8008cf <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f5:	0f b6 06             	movzbl (%esi),%eax
  8003f8:	83 c6 01             	add    $0x1,%esi
  8003fb:	83 f8 25             	cmp    $0x25,%eax
  8003fe:	75 e3                	jne    8003e3 <vprintfmt+0x11>
  800400:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800404:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80040b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800410:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800417:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80041f:	eb 2b                	jmp    80044c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800424:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800428:	eb 22                	jmp    80044c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800431:	eb 19                	jmp    80044c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800436:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80043d:	eb 0d                	jmp    80044c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800442:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800445:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	0f b6 06             	movzbl (%esi),%eax
  80044f:	0f b6 d0             	movzbl %al,%edx
  800452:	8d 7e 01             	lea    0x1(%esi),%edi
  800455:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800458:	83 e8 23             	sub    $0x23,%eax
  80045b:	3c 55                	cmp    $0x55,%al
  80045d:	0f 87 46 04 00 00    	ja     8008a9 <vprintfmt+0x4d7>
  800463:	0f b6 c0             	movzbl %al,%eax
  800466:	ff 24 85 80 2a 80 00 	jmp    *0x802a80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046d:	83 ea 30             	sub    $0x30,%edx
  800470:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800473:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800477:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80047d:	83 fa 09             	cmp    $0x9,%edx
  800480:	77 4a                	ja     8004cc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800485:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800488:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80048b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80048f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800492:	8d 50 d0             	lea    -0x30(%eax),%edx
  800495:	83 fa 09             	cmp    $0x9,%edx
  800498:	76 eb                	jbe    800485 <vprintfmt+0xb3>
  80049a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80049d:	eb 2d                	jmp    8004cc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 50 04             	lea    0x4(%eax),%edx
  8004a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a8:	8b 00                	mov    (%eax),%eax
  8004aa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b0:	eb 1a                	jmp    8004cc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004b9:	79 91                	jns    80044c <vprintfmt+0x7a>
  8004bb:	e9 73 ff ff ff       	jmp    800433 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004ca:	eb 80                	jmp    80044c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d0:	0f 89 76 ff ff ff    	jns    80044c <vprintfmt+0x7a>
  8004d6:	e9 64 ff ff ff       	jmp    80043f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004db:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e1:	e9 66 ff ff ff       	jmp    80044c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004fe:	e9 f2 fe ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800503:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800507:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80050a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80050e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800511:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800515:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800518:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80051b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80051f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800522:	80 f9 09             	cmp    $0x9,%cl
  800525:	77 1d                	ja     800544 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	6b c0 64             	imul   $0x64,%eax,%eax
  80052d:	0f be d2             	movsbl %dl,%edx
  800530:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800533:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80053a:	a3 04 30 80 00       	mov    %eax,0x803004
  80053f:	e9 b1 fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800544:	c7 44 24 04 38 29 80 	movl   $0x802938,0x4(%esp)
  80054b:	00 
  80054c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 14 05 00 00       	call   800a6b <strcmp>
  800557:	85 c0                	test   %eax,%eax
  800559:	75 0f                	jne    80056a <vprintfmt+0x198>
  80055b:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800562:	00 00 00 
  800565:	e9 8b fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80056a:	c7 44 24 04 3c 29 80 	movl   $0x80293c,0x4(%esp)
  800571:	00 
  800572:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800575:	89 14 24             	mov    %edx,(%esp)
  800578:	e8 ee 04 00 00       	call   800a6b <strcmp>
  80057d:	85 c0                	test   %eax,%eax
  80057f:	75 0f                	jne    800590 <vprintfmt+0x1be>
  800581:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800588:	00 00 00 
  80058b:	e9 65 fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800590:	c7 44 24 04 40 29 80 	movl   $0x802940,0x4(%esp)
  800597:	00 
  800598:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80059b:	89 0c 24             	mov    %ecx,(%esp)
  80059e:	e8 c8 04 00 00       	call   800a6b <strcmp>
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	75 0f                	jne    8005b6 <vprintfmt+0x1e4>
  8005a7:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8005ae:	00 00 00 
  8005b1:	e9 3f fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005b6:	c7 44 24 04 44 29 80 	movl   $0x802944,0x4(%esp)
  8005bd:	00 
  8005be:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005c1:	89 3c 24             	mov    %edi,(%esp)
  8005c4:	e8 a2 04 00 00       	call   800a6b <strcmp>
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	75 0f                	jne    8005dc <vprintfmt+0x20a>
  8005cd:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  8005d4:	00 00 00 
  8005d7:	e9 19 fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005dc:	c7 44 24 04 48 29 80 	movl   $0x802948,0x4(%esp)
  8005e3:	00 
  8005e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e7:	89 04 24             	mov    %eax,(%esp)
  8005ea:	e8 7c 04 00 00       	call   800a6b <strcmp>
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	75 0f                	jne    800602 <vprintfmt+0x230>
  8005f3:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  8005fa:	00 00 00 
  8005fd:	e9 f3 fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800602:	c7 44 24 04 4c 29 80 	movl   $0x80294c,0x4(%esp)
  800609:	00 
  80060a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80060d:	89 14 24             	mov    %edx,(%esp)
  800610:	e8 56 04 00 00       	call   800a6b <strcmp>
  800615:	83 f8 01             	cmp    $0x1,%eax
  800618:	19 c0                	sbb    %eax,%eax
  80061a:	f7 d0                	not    %eax
  80061c:	83 c0 08             	add    $0x8,%eax
  80061f:	a3 04 30 80 00       	mov    %eax,0x803004
  800624:	e9 cc fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)
  800632:	8b 00                	mov    (%eax),%eax
  800634:	89 c2                	mov    %eax,%edx
  800636:	c1 fa 1f             	sar    $0x1f,%edx
  800639:	31 d0                	xor    %edx,%eax
  80063b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063d:	83 f8 0f             	cmp    $0xf,%eax
  800640:	7f 0b                	jg     80064d <vprintfmt+0x27b>
  800642:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  800649:	85 d2                	test   %edx,%edx
  80064b:	75 23                	jne    800670 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80064d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800651:	c7 44 24 08 50 29 80 	movl   $0x802950,0x8(%esp)
  800658:	00 
  800659:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800660:	89 3c 24             	mov    %edi,(%esp)
  800663:	e8 42 fd ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066b:	e9 85 fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800670:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800674:	c7 44 24 08 c1 2e 80 	movl   $0x802ec1,0x8(%esp)
  80067b:	00 
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	8b 7d 08             	mov    0x8(%ebp),%edi
  800683:	89 3c 24             	mov    %edi,(%esp)
  800686:	e8 1f fd ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80068e:	e9 62 fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
  800693:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800696:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800699:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006a7:	85 f6                	test   %esi,%esi
  8006a9:	b8 31 29 80 00       	mov    $0x802931,%eax
  8006ae:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006b1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006b5:	7e 06                	jle    8006bd <vprintfmt+0x2eb>
  8006b7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006bb:	75 13                	jne    8006d0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006bd:	0f be 06             	movsbl (%esi),%eax
  8006c0:	83 c6 01             	add    $0x1,%esi
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	0f 85 94 00 00 00    	jne    80075f <vprintfmt+0x38d>
  8006cb:	e9 81 00 00 00       	jmp    800751 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	89 34 24             	mov    %esi,(%esp)
  8006d7:	e8 9f 02 00 00       	call   80097b <strnlen>
  8006dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006df:	29 c2                	sub    %eax,%edx
  8006e1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	7e d5                	jle    8006bd <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006e8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006ec:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006ef:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006f2:	89 d6                	mov    %edx,%esi
  8006f4:	89 cf                	mov    %ecx,%edi
  8006f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fa:	89 3c 24             	mov    %edi,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	83 ee 01             	sub    $0x1,%esi
  800703:	75 f1                	jne    8006f6 <vprintfmt+0x324>
  800705:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800708:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80070b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80070e:	eb ad                	jmp    8006bd <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800710:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800714:	74 1b                	je     800731 <vprintfmt+0x35f>
  800716:	8d 50 e0             	lea    -0x20(%eax),%edx
  800719:	83 fa 5e             	cmp    $0x5e,%edx
  80071c:	76 13                	jbe    800731 <vprintfmt+0x35f>
					putch('?', putdat);
  80071e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800721:	89 44 24 04          	mov    %eax,0x4(%esp)
  800725:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80072c:	ff 55 08             	call   *0x8(%ebp)
  80072f:	eb 0d                	jmp    80073e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800731:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800734:	89 54 24 04          	mov    %edx,0x4(%esp)
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073e:	83 eb 01             	sub    $0x1,%ebx
  800741:	0f be 06             	movsbl (%esi),%eax
  800744:	83 c6 01             	add    $0x1,%esi
  800747:	85 c0                	test   %eax,%eax
  800749:	75 1a                	jne    800765 <vprintfmt+0x393>
  80074b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80074e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800751:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800754:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800758:	7f 1c                	jg     800776 <vprintfmt+0x3a4>
  80075a:	e9 96 fc ff ff       	jmp    8003f5 <vprintfmt+0x23>
  80075f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800762:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800765:	85 ff                	test   %edi,%edi
  800767:	78 a7                	js     800710 <vprintfmt+0x33e>
  800769:	83 ef 01             	sub    $0x1,%edi
  80076c:	79 a2                	jns    800710 <vprintfmt+0x33e>
  80076e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800771:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800774:	eb db                	jmp    800751 <vprintfmt+0x37f>
  800776:	8b 7d 08             	mov    0x8(%ebp),%edi
  800779:	89 de                	mov    %ebx,%esi
  80077b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800782:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800789:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078b:	83 eb 01             	sub    $0x1,%ebx
  80078e:	75 ee                	jne    80077e <vprintfmt+0x3ac>
  800790:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800795:	e9 5b fc ff ff       	jmp    8003f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079a:	83 f9 01             	cmp    $0x1,%ecx
  80079d:	7e 10                	jle    8007af <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 08             	lea    0x8(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a8:	8b 30                	mov    (%eax),%esi
  8007aa:	8b 78 04             	mov    0x4(%eax),%edi
  8007ad:	eb 26                	jmp    8007d5 <vprintfmt+0x403>
	else if (lflag)
  8007af:	85 c9                	test   %ecx,%ecx
  8007b1:	74 12                	je     8007c5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 50 04             	lea    0x4(%eax),%edx
  8007b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bc:	8b 30                	mov    (%eax),%esi
  8007be:	89 f7                	mov    %esi,%edi
  8007c0:	c1 ff 1f             	sar    $0x1f,%edi
  8007c3:	eb 10                	jmp    8007d5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 30                	mov    (%eax),%esi
  8007d0:	89 f7                	mov    %esi,%edi
  8007d2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d5:	85 ff                	test   %edi,%edi
  8007d7:	78 0e                	js     8007e7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d9:	89 f0                	mov    %esi,%eax
  8007db:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007dd:	be 0a 00 00 00       	mov    $0xa,%esi
  8007e2:	e9 84 00 00 00       	jmp    80086b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007eb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007f2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	89 fa                	mov    %edi,%edx
  8007f9:	f7 d8                	neg    %eax
  8007fb:	83 d2 00             	adc    $0x0,%edx
  8007fe:	f7 da                	neg    %edx
			}
			base = 10;
  800800:	be 0a 00 00 00       	mov    $0xa,%esi
  800805:	eb 64                	jmp    80086b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800807:	89 ca                	mov    %ecx,%edx
  800809:	8d 45 14             	lea    0x14(%ebp),%eax
  80080c:	e8 42 fb ff ff       	call   800353 <getuint>
			base = 10;
  800811:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800816:	eb 53                	jmp    80086b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800818:	89 ca                	mov    %ecx,%edx
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
  80081d:	e8 31 fb ff ff       	call   800353 <getuint>
    			base = 8;
  800822:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800827:	eb 42                	jmp    80086b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800829:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800834:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800837:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800842:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	8d 50 04             	lea    0x4(%eax),%edx
  80084b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80084e:	8b 00                	mov    (%eax),%eax
  800850:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800855:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80085a:	eb 0f                	jmp    80086b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80085c:	89 ca                	mov    %ecx,%edx
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
  800861:	e8 ed fa ff ff       	call   800353 <getuint>
			base = 16;
  800866:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80086f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800873:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800876:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80087a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	89 54 24 04          	mov    %edx,0x4(%esp)
  800885:	89 da                	mov    %ebx,%edx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	e8 e9 f9 ff ff       	call   800278 <printnum>
			break;
  80088f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800892:	e9 5e fb ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800897:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089b:	89 14 24             	mov    %edx,(%esp)
  80089e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a4:	e9 4c fb ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ad:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008bb:	0f 84 34 fb ff ff    	je     8003f5 <vprintfmt+0x23>
  8008c1:	83 ee 01             	sub    $0x1,%esi
  8008c4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008c8:	75 f7                	jne    8008c1 <vprintfmt+0x4ef>
  8008ca:	e9 26 fb ff ff       	jmp    8003f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008cf:	83 c4 5c             	add    $0x5c,%esp
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 28             	sub    $0x28,%esp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f4:	85 c0                	test   %eax,%eax
  8008f6:	74 30                	je     800928 <vsnprintf+0x51>
  8008f8:	85 d2                	test   %edx,%edx
  8008fa:	7e 2c                	jle    800928 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800903:	8b 45 10             	mov    0x10(%ebp),%eax
  800906:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800911:	c7 04 24 8d 03 80 00 	movl   $0x80038d,(%esp)
  800918:	e8 b5 fa ff ff       	call   8003d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800920:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800926:	eb 05                	jmp    80092d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800938:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093c:	8b 45 10             	mov    0x10(%ebp),%eax
  80093f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	89 04 24             	mov    %eax,(%esp)
  800950:	e8 82 ff ff ff       	call   8008d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    
	...

00800960 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	80 3a 00             	cmpb   $0x0,(%edx)
  80096e:	74 09                	je     800979 <strlen+0x19>
		n++;
  800970:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800973:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800977:	75 f7                	jne    800970 <strlen+0x10>
		n++;
	return n;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
  80098a:	85 c9                	test   %ecx,%ecx
  80098c:	74 1a                	je     8009a8 <strnlen+0x2d>
  80098e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800991:	74 15                	je     8009a8 <strnlen+0x2d>
  800993:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800998:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099a:	39 ca                	cmp    %ecx,%edx
  80099c:	74 0a                	je     8009a8 <strnlen+0x2d>
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009a6:	75 f0                	jne    800998 <strnlen+0x1d>
		n++;
	return n;
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009be:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009c1:	83 c2 01             	add    $0x1,%edx
  8009c4:	84 c9                	test   %cl,%cl
  8009c6:	75 f2                	jne    8009ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 08             	sub    $0x8,%esp
  8009d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d5:	89 1c 24             	mov    %ebx,(%esp)
  8009d8:	e8 83 ff ff ff       	call   800960 <strlen>
	strcpy(dst + len, src);
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e4:	01 d8                	add    %ebx,%eax
  8009e6:	89 04 24             	mov    %eax,(%esp)
  8009e9:	e8 bd ff ff ff       	call   8009ab <strcpy>
	return dst;
}
  8009ee:	89 d8                	mov    %ebx,%eax
  8009f0:	83 c4 08             	add    $0x8,%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a04:	85 f6                	test   %esi,%esi
  800a06:	74 18                	je     800a20 <strncpy+0x2a>
  800a08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a0d:	0f b6 1a             	movzbl (%edx),%ebx
  800a10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a13:	80 3a 01             	cmpb   $0x1,(%edx)
  800a16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	39 f1                	cmp    %esi,%ecx
  800a1e:	75 ed                	jne    800a0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a33:	89 f8                	mov    %edi,%eax
  800a35:	85 f6                	test   %esi,%esi
  800a37:	74 2b                	je     800a64 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a39:	83 fe 01             	cmp    $0x1,%esi
  800a3c:	74 23                	je     800a61 <strlcpy+0x3d>
  800a3e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a41:	84 c9                	test   %cl,%cl
  800a43:	74 1c                	je     800a61 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a45:	83 ee 02             	sub    $0x2,%esi
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a4d:	88 08                	mov    %cl,(%eax)
  800a4f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a52:	39 f2                	cmp    %esi,%edx
  800a54:	74 0b                	je     800a61 <strlcpy+0x3d>
  800a56:	83 c2 01             	add    $0x1,%edx
  800a59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a5d:	84 c9                	test   %cl,%cl
  800a5f:	75 ec                	jne    800a4d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a61:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a64:	29 f8                	sub    %edi,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	84 c0                	test   %al,%al
  800a79:	74 16                	je     800a91 <strcmp+0x26>
  800a7b:	3a 02                	cmp    (%edx),%al
  800a7d:	75 12                	jne    800a91 <strcmp+0x26>
		p++, q++;
  800a7f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a82:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a86:	84 c0                	test   %al,%al
  800a88:	74 07                	je     800a91 <strcmp+0x26>
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	3a 02                	cmp    (%edx),%al
  800a8f:	74 ee                	je     800a7f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a91:	0f b6 c0             	movzbl %al,%eax
  800a94:	0f b6 12             	movzbl (%edx),%edx
  800a97:	29 d0                	sub    %edx,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aad:	85 d2                	test   %edx,%edx
  800aaf:	74 28                	je     800ad9 <strncmp+0x3e>
  800ab1:	0f b6 01             	movzbl (%ecx),%eax
  800ab4:	84 c0                	test   %al,%al
  800ab6:	74 24                	je     800adc <strncmp+0x41>
  800ab8:	3a 03                	cmp    (%ebx),%al
  800aba:	75 20                	jne    800adc <strncmp+0x41>
  800abc:	83 ea 01             	sub    $0x1,%edx
  800abf:	74 13                	je     800ad4 <strncmp+0x39>
		n--, p++, q++;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac7:	0f b6 01             	movzbl (%ecx),%eax
  800aca:	84 c0                	test   %al,%al
  800acc:	74 0e                	je     800adc <strncmp+0x41>
  800ace:	3a 03                	cmp    (%ebx),%al
  800ad0:	74 ea                	je     800abc <strncmp+0x21>
  800ad2:	eb 08                	jmp    800adc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800adc:	0f b6 01             	movzbl (%ecx),%eax
  800adf:	0f b6 13             	movzbl (%ebx),%edx
  800ae2:	29 d0                	sub    %edx,%eax
  800ae4:	eb f3                	jmp    800ad9 <strncmp+0x3e>

00800ae6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af0:	0f b6 10             	movzbl (%eax),%edx
  800af3:	84 d2                	test   %dl,%dl
  800af5:	74 1c                	je     800b13 <strchr+0x2d>
		if (*s == c)
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	75 09                	jne    800b04 <strchr+0x1e>
  800afb:	eb 1b                	jmp    800b18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b00:	38 ca                	cmp    %cl,%dl
  800b02:	74 14                	je     800b18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b04:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	75 f1                	jne    800afd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	eb 05                	jmp    800b18 <strchr+0x32>
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b24:	0f b6 10             	movzbl (%eax),%edx
  800b27:	84 d2                	test   %dl,%dl
  800b29:	74 14                	je     800b3f <strfind+0x25>
		if (*s == c)
  800b2b:	38 ca                	cmp    %cl,%dl
  800b2d:	75 06                	jne    800b35 <strfind+0x1b>
  800b2f:	eb 0e                	jmp    800b3f <strfind+0x25>
  800b31:	38 ca                	cmp    %cl,%dl
  800b33:	74 0a                	je     800b3f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	0f b6 10             	movzbl (%eax),%edx
  800b3b:	84 d2                	test   %dl,%dl
  800b3d:	75 f2                	jne    800b31 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 0c             	sub    $0xc,%esp
  800b47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b59:	85 c9                	test   %ecx,%ecx
  800b5b:	74 30                	je     800b8d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b63:	75 25                	jne    800b8a <memset+0x49>
  800b65:	f6 c1 03             	test   $0x3,%cl
  800b68:	75 20                	jne    800b8a <memset+0x49>
		c &= 0xFF;
  800b6a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	c1 e3 08             	shl    $0x8,%ebx
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	c1 e6 18             	shl    $0x18,%esi
  800b77:	89 d0                	mov    %edx,%eax
  800b79:	c1 e0 10             	shl    $0x10,%eax
  800b7c:	09 f0                	or     %esi,%eax
  800b7e:	09 d0                	or     %edx,%eax
  800b80:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b82:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b85:	fc                   	cld    
  800b86:	f3 ab                	rep stos %eax,%es:(%edi)
  800b88:	eb 03                	jmp    800b8d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8a:	fc                   	cld    
  800b8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b8d:	89 f8                	mov    %edi,%eax
  800b8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b98:	89 ec                	mov    %ebp,%esp
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb1:	39 c6                	cmp    %eax,%esi
  800bb3:	73 36                	jae    800beb <memmove+0x4f>
  800bb5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb8:	39 d0                	cmp    %edx,%eax
  800bba:	73 2f                	jae    800beb <memmove+0x4f>
		s += n;
		d += n;
  800bbc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbf:	f6 c2 03             	test   $0x3,%dl
  800bc2:	75 1b                	jne    800bdf <memmove+0x43>
  800bc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bca:	75 13                	jne    800bdf <memmove+0x43>
  800bcc:	f6 c1 03             	test   $0x3,%cl
  800bcf:	75 0e                	jne    800bdf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd1:	83 ef 04             	sub    $0x4,%edi
  800bd4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bda:	fd                   	std    
  800bdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bdd:	eb 09                	jmp    800be8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bdf:	83 ef 01             	sub    $0x1,%edi
  800be2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be5:	fd                   	std    
  800be6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be8:	fc                   	cld    
  800be9:	eb 20                	jmp    800c0b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800beb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf1:	75 13                	jne    800c06 <memmove+0x6a>
  800bf3:	a8 03                	test   $0x3,%al
  800bf5:	75 0f                	jne    800c06 <memmove+0x6a>
  800bf7:	f6 c1 03             	test   $0x3,%cl
  800bfa:	75 0a                	jne    800c06 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bfc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bff:	89 c7                	mov    %eax,%edi
  800c01:	fc                   	cld    
  800c02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c04:	eb 05                	jmp    800c0b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c06:	89 c7                	mov    %eax,%edi
  800c08:	fc                   	cld    
  800c09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c11:	89 ec                	mov    %ebp,%esp
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2c:	89 04 24             	mov    %eax,(%esp)
  800c2f:	e8 68 ff ff ff       	call   800b9c <memmove>
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c42:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4a:	85 ff                	test   %edi,%edi
  800c4c:	74 37                	je     800c85 <memcmp+0x4f>
		if (*s1 != *s2)
  800c4e:	0f b6 03             	movzbl (%ebx),%eax
  800c51:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c54:	83 ef 01             	sub    $0x1,%edi
  800c57:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c5c:	38 c8                	cmp    %cl,%al
  800c5e:	74 1c                	je     800c7c <memcmp+0x46>
  800c60:	eb 10                	jmp    800c72 <memcmp+0x3c>
  800c62:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c67:	83 c2 01             	add    $0x1,%edx
  800c6a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c6e:	38 c8                	cmp    %cl,%al
  800c70:	74 0a                	je     800c7c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c72:	0f b6 c0             	movzbl %al,%eax
  800c75:	0f b6 c9             	movzbl %cl,%ecx
  800c78:	29 c8                	sub    %ecx,%eax
  800c7a:	eb 09                	jmp    800c85 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7c:	39 fa                	cmp    %edi,%edx
  800c7e:	75 e2                	jne    800c62 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c95:	39 d0                	cmp    %edx,%eax
  800c97:	73 19                	jae    800cb2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c9d:	38 08                	cmp    %cl,(%eax)
  800c9f:	75 06                	jne    800ca7 <memfind+0x1d>
  800ca1:	eb 0f                	jmp    800cb2 <memfind+0x28>
  800ca3:	38 08                	cmp    %cl,(%eax)
  800ca5:	74 0b                	je     800cb2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca7:	83 c0 01             	add    $0x1,%eax
  800caa:	39 d0                	cmp    %edx,%eax
  800cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	75 f1                	jne    800ca3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc0:	0f b6 02             	movzbl (%edx),%eax
  800cc3:	3c 20                	cmp    $0x20,%al
  800cc5:	74 04                	je     800ccb <strtol+0x17>
  800cc7:	3c 09                	cmp    $0x9,%al
  800cc9:	75 0e                	jne    800cd9 <strtol+0x25>
		s++;
  800ccb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cce:	0f b6 02             	movzbl (%edx),%eax
  800cd1:	3c 20                	cmp    $0x20,%al
  800cd3:	74 f6                	je     800ccb <strtol+0x17>
  800cd5:	3c 09                	cmp    $0x9,%al
  800cd7:	74 f2                	je     800ccb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cd9:	3c 2b                	cmp    $0x2b,%al
  800cdb:	75 0a                	jne    800ce7 <strtol+0x33>
		s++;
  800cdd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce5:	eb 10                	jmp    800cf7 <strtol+0x43>
  800ce7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cec:	3c 2d                	cmp    $0x2d,%al
  800cee:	75 07                	jne    800cf7 <strtol+0x43>
		s++, neg = 1;
  800cf0:	83 c2 01             	add    $0x1,%edx
  800cf3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	0f 94 c0             	sete   %al
  800cfc:	74 05                	je     800d03 <strtol+0x4f>
  800cfe:	83 fb 10             	cmp    $0x10,%ebx
  800d01:	75 15                	jne    800d18 <strtol+0x64>
  800d03:	80 3a 30             	cmpb   $0x30,(%edx)
  800d06:	75 10                	jne    800d18 <strtol+0x64>
  800d08:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d0c:	75 0a                	jne    800d18 <strtol+0x64>
		s += 2, base = 16;
  800d0e:	83 c2 02             	add    $0x2,%edx
  800d11:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d16:	eb 13                	jmp    800d2b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d18:	84 c0                	test   %al,%al
  800d1a:	74 0f                	je     800d2b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d21:	80 3a 30             	cmpb   $0x30,(%edx)
  800d24:	75 05                	jne    800d2b <strtol+0x77>
		s++, base = 8;
  800d26:	83 c2 01             	add    $0x1,%edx
  800d29:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d32:	0f b6 0a             	movzbl (%edx),%ecx
  800d35:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d38:	80 fb 09             	cmp    $0x9,%bl
  800d3b:	77 08                	ja     800d45 <strtol+0x91>
			dig = *s - '0';
  800d3d:	0f be c9             	movsbl %cl,%ecx
  800d40:	83 e9 30             	sub    $0x30,%ecx
  800d43:	eb 1e                	jmp    800d63 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d45:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d48:	80 fb 19             	cmp    $0x19,%bl
  800d4b:	77 08                	ja     800d55 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d4d:	0f be c9             	movsbl %cl,%ecx
  800d50:	83 e9 57             	sub    $0x57,%ecx
  800d53:	eb 0e                	jmp    800d63 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d55:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d58:	80 fb 19             	cmp    $0x19,%bl
  800d5b:	77 14                	ja     800d71 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d5d:	0f be c9             	movsbl %cl,%ecx
  800d60:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d63:	39 f1                	cmp    %esi,%ecx
  800d65:	7d 0e                	jge    800d75 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d67:	83 c2 01             	add    $0x1,%edx
  800d6a:	0f af c6             	imul   %esi,%eax
  800d6d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d6f:	eb c1                	jmp    800d32 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d71:	89 c1                	mov    %eax,%ecx
  800d73:	eb 02                	jmp    800d77 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d75:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d7b:	74 05                	je     800d82 <strtol+0xce>
		*endptr = (char *) s;
  800d7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d80:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d82:	89 ca                	mov    %ecx,%edx
  800d84:	f7 da                	neg    %edx
  800d86:	85 ff                	test   %edi,%edi
  800d88:	0f 45 c2             	cmovne %edx,%eax
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	89 c7                	mov    %eax,%edi
  800dae:	89 c6                	mov    %eax,%esi
  800db0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800db2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbb:	89 ec                	mov    %ebp,%esp
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd8:	89 d1                	mov    %edx,%ecx
  800dda:	89 d3                	mov    %edx,%ebx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	89 d6                	mov    %edx,%esi
  800de0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 38             	sub    $0x38,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e03:	b8 03 00 00 00       	mov    $0x3,%eax
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	89 cb                	mov    %ecx,%ebx
  800e0d:	89 cf                	mov    %ecx,%edi
  800e0f:	89 ce                	mov    %ecx,%esi
  800e11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 28                	jle    800e3f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800e3a:	e8 81 16 00 00       	call   8024c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e48:	89 ec                	mov    %ebp,%esp
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 0c             	sub    $0xc,%esp
  800e52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e60:	b8 02 00 00 00       	mov    $0x2,%eax
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 d3                	mov    %edx,%ebx
  800e69:	89 d7                	mov    %edx,%edi
  800e6b:	89 d6                	mov    %edx,%esi
  800e6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_yield>:

void
sys_yield(void)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 d3                	mov    %edx,%ebx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 38             	sub    $0x38,%esp
  800eb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	be 00 00 00 00       	mov    $0x0,%esi
  800ec0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	89 f7                	mov    %esi,%edi
  800ed0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	7e 28                	jle    800efe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eda:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef1:	00 
  800ef2:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800ef9:	e8 c2 15 00 00       	call   8024c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800efe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f01:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f04:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f07:	89 ec                	mov    %ebp,%esp
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 38             	sub    $0x38,%esp
  800f11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f30:	85 c0                	test   %eax,%eax
  800f32:	7e 28                	jle    800f5c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f3f:	00 
  800f40:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800f47:	00 
  800f48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4f:	00 
  800f50:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800f57:	e8 64 15 00 00       	call   8024c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f5c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f62:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f65:	89 ec                	mov    %ebp,%esp
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 38             	sub    $0x38,%esp
  800f6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f75:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	89 df                	mov    %ebx,%edi
  800f8a:	89 de                	mov    %ebx,%esi
  800f8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	7e 28                	jle    800fba <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f96:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800fa5:	00 
  800fa6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fad:	00 
  800fae:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800fb5:	e8 06 15 00 00       	call   8024c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc3:	89 ec                	mov    %ebp,%esp
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	89 df                	mov    %ebx,%edi
  800fe8:	89 de                	mov    %ebx,%esi
  800fea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	7e 28                	jle    801018 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  801003:	00 
  801004:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100b:	00 
  80100c:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  801013:	e8 a8 14 00 00       	call   8024c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801018:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801021:	89 ec                	mov    %ebp,%esp
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 38             	sub    $0x38,%esp
  80102b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801031:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801034:	bb 00 00 00 00       	mov    $0x0,%ebx
  801039:	b8 09 00 00 00       	mov    $0x9,%eax
  80103e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801041:	8b 55 08             	mov    0x8(%ebp),%edx
  801044:	89 df                	mov    %ebx,%edi
  801046:	89 de                	mov    %ebx,%esi
  801048:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104a:	85 c0                	test   %eax,%eax
  80104c:	7e 28                	jle    801076 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801052:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801059:	00 
  80105a:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  801061:	00 
  801062:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801069:	00 
  80106a:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  801071:	e8 4a 14 00 00       	call   8024c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801076:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801079:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107f:	89 ec                	mov    %ebp,%esp
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 38             	sub    $0x38,%esp
  801089:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80108f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
  801097:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a2:	89 df                	mov    %ebx,%edi
  8010a4:	89 de                	mov    %ebx,%esi
  8010a6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	7e 28                	jle    8010d4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8010cf:	e8 ec 13 00 00       	call   8024c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010da:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010dd:	89 ec                	mov    %ebp,%esp
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ed:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f0:	be 00 00 00 00       	mov    $0x0,%esi
  8010f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801100:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
  801106:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801108:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80110b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801111:	89 ec                	mov    %ebp,%esp
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 38             	sub    $0x38,%esp
  80111b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801121:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801124:	b9 00 00 00 00       	mov    $0x0,%ecx
  801129:	b8 0d 00 00 00       	mov    $0xd,%eax
  80112e:	8b 55 08             	mov    0x8(%ebp),%edx
  801131:	89 cb                	mov    %ecx,%ebx
  801133:	89 cf                	mov    %ecx,%edi
  801135:	89 ce                	mov    %ecx,%esi
  801137:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801139:	85 c0                	test   %eax,%eax
  80113b:	7e 28                	jle    801165 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801141:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801148:	00 
  801149:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  801160:	e8 5b 13 00 00       	call   8024c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801165:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801168:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80116e:	89 ec                	mov    %ebp,%esp
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80117b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80117e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801181:	b9 00 00 00 00       	mov    $0x0,%ecx
  801186:	b8 0e 00 00 00       	mov    $0xe,%eax
  80118b:	8b 55 08             	mov    0x8(%ebp),%edx
  80118e:	89 cb                	mov    %ecx,%ebx
  801190:	89 cf                	mov    %ecx,%edi
  801192:	89 ce                	mov    %ecx,%esi
  801194:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801196:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801199:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80119c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80119f:	89 ec                	mov    %ebp,%esp
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    
	...

008011a4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 24             	sub    $0x24,%esp
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011ae:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  8011b0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011b4:	75 1c                	jne    8011d2 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  8011b6:	c7 44 24 08 6a 2c 80 	movl   $0x802c6a,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8011cd:	e8 ee 12 00 00       	call   8024c0 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  8011d2:	89 d8                	mov    %ebx,%eax
  8011d4:	c1 e8 0c             	shr    $0xc,%eax
  8011d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011de:	f6 c4 08             	test   $0x8,%ah
  8011e1:	0f 84 be 00 00 00    	je     8012a5 <pgfault+0x101>
  8011e7:	89 d8                	mov    %ebx,%eax
  8011e9:	c1 e8 16             	shr    $0x16,%eax
  8011ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f3:	a8 01                	test   $0x1,%al
  8011f5:	0f 84 aa 00 00 00    	je     8012a5 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  8011fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801212:	e8 95 fc ff ff       	call   800eac <sys_page_alloc>
		if (r < 0)
  801217:	85 c0                	test   %eax,%eax
  801219:	79 20                	jns    80123b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80121b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121f:	c7 44 24 08 a4 2c 80 	movl   $0x802ca4,0x8(%esp)
  801226:	00 
  801227:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80122e:	00 
  80122f:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801236:	e8 85 12 00 00       	call   8024c0 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80123b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801241:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801248:	00 
  801249:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80124d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801254:	e8 bc f9 ff ff       	call   800c15 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801259:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801260:	00 
  801261:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801265:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80126c:	00 
  80126d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801274:	00 
  801275:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80127c:	e8 8a fc ff ff       	call   800f0b <sys_page_map>
		if (r < 0)
  801281:	85 c0                	test   %eax,%eax
  801283:	79 3c                	jns    8012c1 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  801285:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801289:	c7 44 24 08 cc 2c 80 	movl   $0x802ccc,0x8(%esp)
  801290:	00 
  801291:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801298:	00 
  801299:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8012a0:	e8 1b 12 00 00       	call   8024c0 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  8012a5:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8012b4:	00 
  8012b5:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8012bc:	e8 ff 11 00 00       	call   8024c0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  8012c1:	83 c4 24             	add    $0x24,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	57                   	push   %edi
  8012cb:	56                   	push   %esi
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8012d0:	c7 04 24 a4 11 80 00 	movl   $0x8011a4,(%esp)
  8012d7:	e8 3c 12 00 00       	call   802518 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8012dc:	bf 07 00 00 00       	mov    $0x7,%edi
  8012e1:	89 f8                	mov    %edi,%eax
  8012e3:	cd 30                	int    $0x30
  8012e5:	89 c7                	mov    %eax,%edi
  8012e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	79 20                	jns    80130e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  8012ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f2:	c7 44 24 08 10 2d 80 	movl   $0x802d10,0x8(%esp)
  8012f9:	00 
  8012fa:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801301:	00 
  801302:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801309:	e8 b2 11 00 00       	call   8024c0 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80130e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801313:	85 c0                	test   %eax,%eax
  801315:	75 1c                	jne    801333 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801317:	e8 30 fb ff ff       	call   800e4c <sys_getenvid>
  80131c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801321:	c1 e0 07             	shl    $0x7,%eax
  801324:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801329:	a3 08 40 80 00       	mov    %eax,0x804008
		//cprintf("child fork ok!\n");
		return 0;
  80132e:	e9 51 02 00 00       	jmp    801584 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801333:	89 d8                	mov    %ebx,%eax
  801335:	c1 e8 16             	shr    $0x16,%eax
  801338:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133f:	a8 01                	test   $0x1,%al
  801341:	0f 84 87 01 00 00    	je     8014ce <fork+0x207>
  801347:	89 d8                	mov    %ebx,%eax
  801349:	c1 e8 0c             	shr    $0xc,%eax
  80134c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801353:	f6 c2 01             	test   $0x1,%dl
  801356:	0f 84 72 01 00 00    	je     8014ce <fork+0x207>
  80135c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801363:	f6 c2 04             	test   $0x4,%dl
  801366:	0f 84 62 01 00 00    	je     8014ce <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80136c:	89 c6                	mov    %eax,%esi
  80136e:	c1 e6 0c             	shl    $0xc,%esi
  801371:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801377:	0f 84 51 01 00 00    	je     8014ce <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  80137d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801384:	f6 c6 04             	test   $0x4,%dh
  801387:	74 53                	je     8013dc <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801389:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801390:	25 07 0e 00 00       	and    $0xe07,%eax
  801395:	89 44 24 10          	mov    %eax,0x10(%esp)
  801399:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80139d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013af:	e8 57 fb ff ff       	call   800f0b <sys_page_map>
		if (r < 0)
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	0f 89 12 01 00 00    	jns    8014ce <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  8013bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c0:	c7 44 24 08 30 2d 80 	movl   $0x802d30,0x8(%esp)
  8013c7:	00 
  8013c8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8013cf:	00 
  8013d0:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8013d7:	e8 e4 10 00 00       	call   8024c0 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  8013dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e3:	f6 c2 02             	test   $0x2,%dl
  8013e6:	75 10                	jne    8013f8 <fork+0x131>
  8013e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ef:	f6 c4 08             	test   $0x8,%ah
  8013f2:	0f 84 8f 00 00 00    	je     801487 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8013f8:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013ff:	00 
  801400:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801407:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801416:	e8 f0 fa ff ff       	call   800f0b <sys_page_map>
		if (r < 0)
  80141b:	85 c0                	test   %eax,%eax
  80141d:	79 20                	jns    80143f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80141f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801423:	c7 44 24 08 5c 2d 80 	movl   $0x802d5c,0x8(%esp)
  80142a:	00 
  80142b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801432:	00 
  801433:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80143a:	e8 81 10 00 00       	call   8024c0 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80143f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801446:	00 
  801447:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80144b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801452:	00 
  801453:	89 74 24 04          	mov    %esi,0x4(%esp)
  801457:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145e:	e8 a8 fa ff ff       	call   800f0b <sys_page_map>
		if (r < 0)
  801463:	85 c0                	test   %eax,%eax
  801465:	79 67                	jns    8014ce <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146b:	c7 44 24 08 5c 2d 80 	movl   $0x802d5c,0x8(%esp)
  801472:	00 
  801473:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80147a:	00 
  80147b:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801482:	e8 39 10 00 00       	call   8024c0 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  801487:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80148e:	00 
  80148f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801496:	89 44 24 08          	mov    %eax,0x8(%esp)
  80149a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a5:	e8 61 fa ff ff       	call   800f0b <sys_page_map>
		if (r < 0)
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	79 20                	jns    8014ce <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8014ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b2:	c7 44 24 08 5c 2d 80 	movl   $0x802d5c,0x8(%esp)
  8014b9:	00 
  8014ba:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8014c1:	00 
  8014c2:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8014c9:	e8 f2 0f 00 00       	call   8024c0 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  8014ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014d4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8014da:	0f 85 53 fe ff ff    	jne    801333 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8014e0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014e7:	00 
  8014e8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014ef:	ee 
  8014f0:	89 3c 24             	mov    %edi,(%esp)
  8014f3:	e8 b4 f9 ff ff       	call   800eac <sys_page_alloc>
	if (res < 0)
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	79 20                	jns    80151c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  8014fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801500:	c7 44 24 08 80 2d 80 	movl   $0x802d80,0x8(%esp)
  801507:	00 
  801508:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80150f:	00 
  801510:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801517:	e8 a4 0f 00 00       	call   8024c0 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80151c:	c7 44 24 04 a4 25 80 	movl   $0x8025a4,0x4(%esp)
  801523:	00 
  801524:	89 3c 24             	mov    %edi,(%esp)
  801527:	e8 57 fb ff ff       	call   801083 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80152c:	85 c0                	test   %eax,%eax
  80152e:	79 20                	jns    801550 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801530:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801534:	c7 44 24 08 a4 2d 80 	movl   $0x802da4,0x8(%esp)
  80153b:	00 
  80153c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801543:	00 
  801544:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80154b:	e8 70 0f 00 00       	call   8024c0 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801550:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801557:	00 
  801558:	89 3c 24             	mov    %edi,(%esp)
  80155b:	e8 67 fa ff ff       	call   800fc7 <sys_env_set_status>
	if (res < 0)
  801560:	85 c0                	test   %eax,%eax
  801562:	79 20                	jns    801584 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801564:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801568:	c7 44 24 08 d4 2d 80 	movl   $0x802dd4,0x8(%esp)
  80156f:	00 
  801570:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801577:	00 
  801578:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80157f:	e8 3c 0f 00 00       	call   8024c0 <_panic>

	return pid;
	//panic("fork not implemented");
}
  801584:	89 f8                	mov    %edi,%eax
  801586:	83 c4 3c             	add    $0x3c,%esp
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5f                   	pop    %edi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <sfork>:

// Challenge!
int
sfork(void)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801594:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  80159b:	00 
  80159c:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8015a3:	00 
  8015a4:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8015ab:	e8 10 0f 00 00       	call   8024c0 <_panic>

008015b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 10             	sub    $0x10,%esp
  8015b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015be:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8015c1:	85 db                	test   %ebx,%ebx
  8015c3:	74 06                	je     8015cb <ipc_recv+0x1b>
  8015c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8015cb:	85 f6                	test   %esi,%esi
  8015cd:	74 06                	je     8015d5 <ipc_recv+0x25>
  8015cf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8015dc:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8015df:	89 04 24             	mov    %eax,(%esp)
  8015e2:	e8 2e fb ff ff       	call   801115 <sys_ipc_recv>
    if (ret) return ret;
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	75 24                	jne    80160f <ipc_recv+0x5f>
    if (from_env_store)
  8015eb:	85 db                	test   %ebx,%ebx
  8015ed:	74 0a                	je     8015f9 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  8015ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f4:	8b 40 74             	mov    0x74(%eax),%eax
  8015f7:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8015f9:	85 f6                	test   %esi,%esi
  8015fb:	74 0a                	je     801607 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8015fd:	a1 08 40 80 00       	mov    0x804008,%eax
  801602:	8b 40 78             	mov    0x78(%eax),%eax
  801605:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801607:	a1 08 40 80 00       	mov    0x804008,%eax
  80160c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	57                   	push   %edi
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	83 ec 1c             	sub    $0x1c,%esp
  80161f:	8b 75 08             	mov    0x8(%ebp),%esi
  801622:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801625:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801628:	85 db                	test   %ebx,%ebx
  80162a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80162f:	0f 44 d8             	cmove  %eax,%ebx
  801632:	eb 2a                	jmp    80165e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801634:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801637:	74 20                	je     801659 <ipc_send+0x43>
  801639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80163d:	c7 44 24 08 fa 2d 80 	movl   $0x802dfa,0x8(%esp)
  801644:	00 
  801645:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80164c:	00 
  80164d:	c7 04 24 11 2e 80 00 	movl   $0x802e11,(%esp)
  801654:	e8 67 0e 00 00       	call   8024c0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801659:	e8 1e f8 ff ff       	call   800e7c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80165e:	8b 45 14             	mov    0x14(%ebp),%eax
  801661:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801665:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801669:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80166d:	89 34 24             	mov    %esi,(%esp)
  801670:	e8 6c fa ff ff       	call   8010e1 <sys_ipc_try_send>
  801675:	85 c0                	test   %eax,%eax
  801677:	75 bb                	jne    801634 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801679:	83 c4 1c             	add    $0x1c,%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801687:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80168c:	39 c8                	cmp    %ecx,%eax
  80168e:	74 19                	je     8016a9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801690:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801695:	89 c2                	mov    %eax,%edx
  801697:	c1 e2 07             	shl    $0x7,%edx
  80169a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8016a0:	8b 52 50             	mov    0x50(%edx),%edx
  8016a3:	39 ca                	cmp    %ecx,%edx
  8016a5:	75 14                	jne    8016bb <ipc_find_env+0x3a>
  8016a7:	eb 05                	jmp    8016ae <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8016a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8016ae:	c1 e0 07             	shl    $0x7,%eax
  8016b1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8016b6:	8b 40 40             	mov    0x40(%eax),%eax
  8016b9:	eb 0e                	jmp    8016c9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8016bb:	83 c0 01             	add    $0x1,%eax
  8016be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8016c3:	75 d0                	jne    801695 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8016c5:	66 b8 00 00          	mov    $0x0,%ax
}
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    
  8016cb:	00 00                	add    %al,(%eax)
  8016cd:	00 00                	add    %al,(%eax)
	...

008016d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016db:	c1 e8 0c             	shr    $0xc,%eax
}
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	89 04 24             	mov    %eax,(%esp)
  8016ec:	e8 df ff ff ff       	call   8016d0 <fd2num>
  8016f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801702:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801707:	a8 01                	test   $0x1,%al
  801709:	74 34                	je     80173f <fd_alloc+0x44>
  80170b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801710:	a8 01                	test   $0x1,%al
  801712:	74 32                	je     801746 <fd_alloc+0x4b>
  801714:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801719:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80171b:	89 c2                	mov    %eax,%edx
  80171d:	c1 ea 16             	shr    $0x16,%edx
  801720:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801727:	f6 c2 01             	test   $0x1,%dl
  80172a:	74 1f                	je     80174b <fd_alloc+0x50>
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	c1 ea 0c             	shr    $0xc,%edx
  801731:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801738:	f6 c2 01             	test   $0x1,%dl
  80173b:	75 17                	jne    801754 <fd_alloc+0x59>
  80173d:	eb 0c                	jmp    80174b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80173f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801744:	eb 05                	jmp    80174b <fd_alloc+0x50>
  801746:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80174b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
  801752:	eb 17                	jmp    80176b <fd_alloc+0x70>
  801754:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801759:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80175e:	75 b9                	jne    801719 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801760:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801766:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80176b:	5b                   	pop    %ebx
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801779:	83 fa 1f             	cmp    $0x1f,%edx
  80177c:	77 3f                	ja     8017bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80177e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801784:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801787:	89 d0                	mov    %edx,%eax
  801789:	c1 e8 16             	shr    $0x16,%eax
  80178c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801793:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801798:	f6 c1 01             	test   $0x1,%cl
  80179b:	74 20                	je     8017bd <fd_lookup+0x4f>
  80179d:	89 d0                	mov    %edx,%eax
  80179f:	c1 e8 0c             	shr    $0xc,%eax
  8017a2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017ae:	f6 c1 01             	test   $0x1,%cl
  8017b1:	74 0a                	je     8017bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 14             	sub    $0x14,%esp
  8017c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8017d1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8017d7:	75 17                	jne    8017f0 <dev_lookup+0x31>
  8017d9:	eb 07                	jmp    8017e2 <dev_lookup+0x23>
  8017db:	39 0a                	cmp    %ecx,(%edx)
  8017dd:	75 11                	jne    8017f0 <dev_lookup+0x31>
  8017df:	90                   	nop
  8017e0:	eb 05                	jmp    8017e7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017e2:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8017e7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8017e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ee:	eb 35                	jmp    801825 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017f0:	83 c0 01             	add    $0x1,%eax
  8017f3:	8b 14 85 98 2e 80 00 	mov    0x802e98(,%eax,4),%edx
  8017fa:	85 d2                	test   %edx,%edx
  8017fc:	75 dd                	jne    8017db <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017fe:	a1 08 40 80 00       	mov    0x804008,%eax
  801803:	8b 40 48             	mov    0x48(%eax),%eax
  801806:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80180a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180e:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801815:	e8 41 ea ff ff       	call   80025b <cprintf>
	*dev = 0;
  80181a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801820:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801825:	83 c4 14             	add    $0x14,%esp
  801828:	5b                   	pop    %ebx
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 38             	sub    $0x38,%esp
  801831:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801834:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801837:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80183a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80183d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801841:	89 3c 24             	mov    %edi,(%esp)
  801844:	e8 87 fe ff ff       	call   8016d0 <fd2num>
  801849:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80184c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801850:	89 04 24             	mov    %eax,(%esp)
  801853:	e8 16 ff ff ff       	call   80176e <fd_lookup>
  801858:	89 c3                	mov    %eax,%ebx
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 05                	js     801863 <fd_close+0x38>
	    || fd != fd2)
  80185e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801861:	74 0e                	je     801871 <fd_close+0x46>
		return (must_exist ? r : 0);
  801863:	89 f0                	mov    %esi,%eax
  801865:	84 c0                	test   %al,%al
  801867:	b8 00 00 00 00       	mov    $0x0,%eax
  80186c:	0f 44 d8             	cmove  %eax,%ebx
  80186f:	eb 3d                	jmp    8018ae <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801871:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801874:	89 44 24 04          	mov    %eax,0x4(%esp)
  801878:	8b 07                	mov    (%edi),%eax
  80187a:	89 04 24             	mov    %eax,(%esp)
  80187d:	e8 3d ff ff ff       	call   8017bf <dev_lookup>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	85 c0                	test   %eax,%eax
  801886:	78 16                	js     80189e <fd_close+0x73>
		if (dev->dev_close)
  801888:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80188b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80188e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801893:	85 c0                	test   %eax,%eax
  801895:	74 07                	je     80189e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801897:	89 3c 24             	mov    %edi,(%esp)
  80189a:	ff d0                	call   *%eax
  80189c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80189e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a9:	e8 bb f6 ff ff       	call   800f69 <sys_page_unmap>
	return r;
}
  8018ae:	89 d8                	mov    %ebx,%eax
  8018b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8018b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8018b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018b9:	89 ec                	mov    %ebp,%esp
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	89 04 24             	mov    %eax,(%esp)
  8018d0:	e8 99 fe ff ff       	call   80176e <fd_lookup>
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 13                	js     8018ec <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8018d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018e0:	00 
  8018e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e4:	89 04 24             	mov    %eax,(%esp)
  8018e7:	e8 3f ff ff ff       	call   80182b <fd_close>
}
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <close_all>:

void
close_all(void)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8018f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8018fa:	89 1c 24             	mov    %ebx,(%esp)
  8018fd:	e8 bb ff ff ff       	call   8018bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801902:	83 c3 01             	add    $0x1,%ebx
  801905:	83 fb 20             	cmp    $0x20,%ebx
  801908:	75 f0                	jne    8018fa <close_all+0xc>
		close(i);
}
  80190a:	83 c4 14             	add    $0x14,%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 58             	sub    $0x58,%esp
  801916:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801919:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80191c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80191f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801922:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801925:	89 44 24 04          	mov    %eax,0x4(%esp)
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	89 04 24             	mov    %eax,(%esp)
  80192f:	e8 3a fe ff ff       	call   80176e <fd_lookup>
  801934:	89 c3                	mov    %eax,%ebx
  801936:	85 c0                	test   %eax,%eax
  801938:	0f 88 e1 00 00 00    	js     801a1f <dup+0x10f>
		return r;
	close(newfdnum);
  80193e:	89 3c 24             	mov    %edi,(%esp)
  801941:	e8 77 ff ff ff       	call   8018bd <close>

	newfd = INDEX2FD(newfdnum);
  801946:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80194c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80194f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	e8 86 fd ff ff       	call   8016e0 <fd2data>
  80195a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80195c:	89 34 24             	mov    %esi,(%esp)
  80195f:	e8 7c fd ff ff       	call   8016e0 <fd2data>
  801964:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801967:	89 d8                	mov    %ebx,%eax
  801969:	c1 e8 16             	shr    $0x16,%eax
  80196c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801973:	a8 01                	test   $0x1,%al
  801975:	74 46                	je     8019bd <dup+0xad>
  801977:	89 d8                	mov    %ebx,%eax
  801979:	c1 e8 0c             	shr    $0xc,%eax
  80197c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801983:	f6 c2 01             	test   $0x1,%dl
  801986:	74 35                	je     8019bd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801988:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80198f:	25 07 0e 00 00       	and    $0xe07,%eax
  801994:	89 44 24 10          	mov    %eax,0x10(%esp)
  801998:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80199b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80199f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019a6:	00 
  8019a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b2:	e8 54 f5 ff ff       	call   800f0b <sys_page_map>
  8019b7:	89 c3                	mov    %eax,%ebx
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 3b                	js     8019f8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c0:	89 c2                	mov    %eax,%edx
  8019c2:	c1 ea 0c             	shr    $0xc,%edx
  8019c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8019d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019e1:	00 
  8019e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ed:	e8 19 f5 ff ff       	call   800f0b <sys_page_map>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	79 25                	jns    801a1d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a03:	e8 61 f5 ff ff       	call   800f69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a16:	e8 4e f5 ff ff       	call   800f69 <sys_page_unmap>
	return r;
  801a1b:	eb 02                	jmp    801a1f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801a1d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801a1f:	89 d8                	mov    %ebx,%eax
  801a21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a2a:	89 ec                	mov    %ebp,%esp
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	53                   	push   %ebx
  801a32:	83 ec 24             	sub    $0x24,%esp
  801a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3f:	89 1c 24             	mov    %ebx,(%esp)
  801a42:	e8 27 fd ff ff       	call   80176e <fd_lookup>
  801a47:	85 c0                	test   %eax,%eax
  801a49:	78 6d                	js     801ab8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a55:	8b 00                	mov    (%eax),%eax
  801a57:	89 04 24             	mov    %eax,(%esp)
  801a5a:	e8 60 fd ff ff       	call   8017bf <dev_lookup>
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 55                	js     801ab8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a66:	8b 50 08             	mov    0x8(%eax),%edx
  801a69:	83 e2 03             	and    $0x3,%edx
  801a6c:	83 fa 01             	cmp    $0x1,%edx
  801a6f:	75 23                	jne    801a94 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a71:	a1 08 40 80 00       	mov    0x804008,%eax
  801a76:	8b 40 48             	mov    0x48(%eax),%eax
  801a79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a81:	c7 04 24 5d 2e 80 00 	movl   $0x802e5d,(%esp)
  801a88:	e8 ce e7 ff ff       	call   80025b <cprintf>
		return -E_INVAL;
  801a8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a92:	eb 24                	jmp    801ab8 <read+0x8a>
	}
	if (!dev->dev_read)
  801a94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a97:	8b 52 08             	mov    0x8(%edx),%edx
  801a9a:	85 d2                	test   %edx,%edx
  801a9c:	74 15                	je     801ab3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aa1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aac:	89 04 24             	mov    %eax,(%esp)
  801aaf:	ff d2                	call   *%edx
  801ab1:	eb 05                	jmp    801ab8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ab3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801ab8:	83 c4 24             	add    $0x24,%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	57                   	push   %edi
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 1c             	sub    $0x1c,%esp
  801ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801acd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad2:	85 f6                	test   %esi,%esi
  801ad4:	74 30                	je     801b06 <readn+0x48>
  801ad6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801adb:	89 f2                	mov    %esi,%edx
  801add:	29 c2                	sub    %eax,%edx
  801adf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ae3:	03 45 0c             	add    0xc(%ebp),%eax
  801ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aea:	89 3c 24             	mov    %edi,(%esp)
  801aed:	e8 3c ff ff ff       	call   801a2e <read>
		if (m < 0)
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 10                	js     801b06 <readn+0x48>
			return m;
		if (m == 0)
  801af6:	85 c0                	test   %eax,%eax
  801af8:	74 0a                	je     801b04 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801afa:	01 c3                	add    %eax,%ebx
  801afc:	89 d8                	mov    %ebx,%eax
  801afe:	39 f3                	cmp    %esi,%ebx
  801b00:	72 d9                	jb     801adb <readn+0x1d>
  801b02:	eb 02                	jmp    801b06 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801b04:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801b06:	83 c4 1c             	add    $0x1c,%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5e                   	pop    %esi
  801b0b:	5f                   	pop    %edi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	53                   	push   %ebx
  801b12:	83 ec 24             	sub    $0x24,%esp
  801b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1f:	89 1c 24             	mov    %ebx,(%esp)
  801b22:	e8 47 fc ff ff       	call   80176e <fd_lookup>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 68                	js     801b93 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b35:	8b 00                	mov    (%eax),%eax
  801b37:	89 04 24             	mov    %eax,(%esp)
  801b3a:	e8 80 fc ff ff       	call   8017bf <dev_lookup>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 50                	js     801b93 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b46:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b4a:	75 23                	jne    801b6f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b4c:	a1 08 40 80 00       	mov    0x804008,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
  801b54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	c7 04 24 79 2e 80 00 	movl   $0x802e79,(%esp)
  801b63:	e8 f3 e6 ff ff       	call   80025b <cprintf>
		return -E_INVAL;
  801b68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b6d:	eb 24                	jmp    801b93 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b72:	8b 52 0c             	mov    0xc(%edx),%edx
  801b75:	85 d2                	test   %edx,%edx
  801b77:	74 15                	je     801b8e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b79:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b7c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b83:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b87:	89 04 24             	mov    %eax,(%esp)
  801b8a:	ff d2                	call   *%edx
  801b8c:	eb 05                	jmp    801b93 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b8e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b93:	83 c4 24             	add    $0x24,%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    

00801b99 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b9f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba9:	89 04 24             	mov    %eax,(%esp)
  801bac:	e8 bd fb ff ff       	call   80176e <fd_lookup>
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 0e                	js     801bc3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801bb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	53                   	push   %ebx
  801bc9:	83 ec 24             	sub    $0x24,%esp
  801bcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd6:	89 1c 24             	mov    %ebx,(%esp)
  801bd9:	e8 90 fb ff ff       	call   80176e <fd_lookup>
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 61                	js     801c43 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801be2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bec:	8b 00                	mov    (%eax),%eax
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 c9 fb ff ff       	call   8017bf <dev_lookup>
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 49                	js     801c43 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c01:	75 23                	jne    801c26 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c03:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c08:	8b 40 48             	mov    0x48(%eax),%eax
  801c0b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c13:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  801c1a:	e8 3c e6 ff ff       	call   80025b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c24:	eb 1d                	jmp    801c43 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801c26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c29:	8b 52 18             	mov    0x18(%edx),%edx
  801c2c:	85 d2                	test   %edx,%edx
  801c2e:	74 0e                	je     801c3e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	ff d2                	call   *%edx
  801c3c:	eb 05                	jmp    801c43 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801c43:	83 c4 24             	add    $0x24,%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 24             	sub    $0x24,%esp
  801c50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	89 04 24             	mov    %eax,(%esp)
  801c60:	e8 09 fb ff ff       	call   80176e <fd_lookup>
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 52                	js     801cbb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c73:	8b 00                	mov    (%eax),%eax
  801c75:	89 04 24             	mov    %eax,(%esp)
  801c78:	e8 42 fb ff ff       	call   8017bf <dev_lookup>
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 3a                	js     801cbb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c84:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c88:	74 2c                	je     801cb6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c8a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c8d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c94:	00 00 00 
	stat->st_isdir = 0;
  801c97:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c9e:	00 00 00 
	stat->st_dev = dev;
  801ca1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ca7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cae:	89 14 24             	mov    %edx,(%esp)
  801cb1:	ff 50 14             	call   *0x14(%eax)
  801cb4:	eb 05                	jmp    801cbb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801cb6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801cbb:	83 c4 24             	add    $0x24,%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 18             	sub    $0x18,%esp
  801cc7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cca:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ccd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cd4:	00 
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	e8 bc 01 00 00       	call   801e9c <open>
  801ce0:	89 c3                	mov    %eax,%ebx
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	78 1b                	js     801d01 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ced:	89 1c 24             	mov    %ebx,(%esp)
  801cf0:	e8 54 ff ff ff       	call   801c49 <fstat>
  801cf5:	89 c6                	mov    %eax,%esi
	close(fd);
  801cf7:	89 1c 24             	mov    %ebx,(%esp)
  801cfa:	e8 be fb ff ff       	call   8018bd <close>
	return r;
  801cff:	89 f3                	mov    %esi,%ebx
}
  801d01:	89 d8                	mov    %ebx,%eax
  801d03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d09:	89 ec                	mov    %ebp,%esp
  801d0b:	5d                   	pop    %ebp
  801d0c:	c3                   	ret    
  801d0d:	00 00                	add    %al,(%eax)
	...

00801d10 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 18             	sub    $0x18,%esp
  801d16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d19:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d1c:	89 c3                	mov    %eax,%ebx
  801d1e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d20:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801d27:	75 11                	jne    801d3a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d30:	e8 4c f9 ff ff       	call   801681 <ipc_find_env>
  801d35:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d3a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d41:	00 
  801d42:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d49:	00 
  801d4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4e:	a1 00 40 80 00       	mov    0x804000,%eax
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 bb f8 ff ff       	call   801616 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801d5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d62:	00 
  801d63:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6e:	e8 3d f8 ff ff       	call   8015b0 <ipc_recv>
}
  801d73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d79:	89 ec                	mov    %ebp,%esp
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	53                   	push   %ebx
  801d81:	83 ec 14             	sub    $0x14,%esp
  801d84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d8d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d92:	ba 00 00 00 00       	mov    $0x0,%edx
  801d97:	b8 05 00 00 00       	mov    $0x5,%eax
  801d9c:	e8 6f ff ff ff       	call   801d10 <fsipc>
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 2b                	js     801dd0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801da5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dac:	00 
  801dad:	89 1c 24             	mov    %ebx,(%esp)
  801db0:	e8 f6 eb ff ff       	call   8009ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801db5:	a1 80 50 80 00       	mov    0x805080,%eax
  801dba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801dc0:	a1 84 50 80 00       	mov    0x805084,%eax
  801dc5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd0:	83 c4 14             	add    $0x14,%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	8b 40 0c             	mov    0xc(%eax),%eax
  801de2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801de7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dec:	b8 06 00 00 00       	mov    $0x6,%eax
  801df1:	e8 1a ff ff ff       	call   801d10 <fsipc>
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	56                   	push   %esi
  801dfc:	53                   	push   %ebx
  801dfd:	83 ec 10             	sub    $0x10,%esp
  801e00:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e03:	8b 45 08             	mov    0x8(%ebp),%eax
  801e06:	8b 40 0c             	mov    0xc(%eax),%eax
  801e09:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801e0e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e14:	ba 00 00 00 00       	mov    $0x0,%edx
  801e19:	b8 03 00 00 00       	mov    $0x3,%eax
  801e1e:	e8 ed fe ff ff       	call   801d10 <fsipc>
  801e23:	89 c3                	mov    %eax,%ebx
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 6a                	js     801e93 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e29:	39 c6                	cmp    %eax,%esi
  801e2b:	73 24                	jae    801e51 <devfile_read+0x59>
  801e2d:	c7 44 24 0c a8 2e 80 	movl   $0x802ea8,0xc(%esp)
  801e34:	00 
  801e35:	c7 44 24 08 af 2e 80 	movl   $0x802eaf,0x8(%esp)
  801e3c:	00 
  801e3d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801e44:	00 
  801e45:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  801e4c:	e8 6f 06 00 00       	call   8024c0 <_panic>
	assert(r <= PGSIZE);
  801e51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e56:	7e 24                	jle    801e7c <devfile_read+0x84>
  801e58:	c7 44 24 0c cf 2e 80 	movl   $0x802ecf,0xc(%esp)
  801e5f:	00 
  801e60:	c7 44 24 08 af 2e 80 	movl   $0x802eaf,0x8(%esp)
  801e67:	00 
  801e68:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e6f:	00 
  801e70:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  801e77:	e8 44 06 00 00       	call   8024c0 <_panic>
	memmove(buf, &fsipcbuf, r);
  801e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e80:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e87:	00 
  801e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8b:	89 04 24             	mov    %eax,(%esp)
  801e8e:	e8 09 ed ff ff       	call   800b9c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801e93:	89 d8                	mov    %ebx,%eax
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 20             	sub    $0x20,%esp
  801ea4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ea7:	89 34 24             	mov    %esi,(%esp)
  801eaa:	e8 b1 ea ff ff       	call   800960 <strlen>
		return -E_BAD_PATH;
  801eaf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801eb4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801eb9:	7f 5e                	jg     801f19 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ebb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebe:	89 04 24             	mov    %eax,(%esp)
  801ec1:	e8 35 f8 ff ff       	call   8016fb <fd_alloc>
  801ec6:	89 c3                	mov    %eax,%ebx
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 4d                	js     801f19 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ecc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ed7:	e8 cf ea ff ff       	call   8009ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ee4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee7:	b8 01 00 00 00       	mov    $0x1,%eax
  801eec:	e8 1f fe ff ff       	call   801d10 <fsipc>
  801ef1:	89 c3                	mov    %eax,%ebx
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	79 15                	jns    801f0c <open+0x70>
		fd_close(fd, 0);
  801ef7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801efe:	00 
  801eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f02:	89 04 24             	mov    %eax,(%esp)
  801f05:	e8 21 f9 ff ff       	call   80182b <fd_close>
		return r;
  801f0a:	eb 0d                	jmp    801f19 <open+0x7d>
	}

	return fd2num(fd);
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	89 04 24             	mov    %eax,(%esp)
  801f12:	e8 b9 f7 ff ff       	call   8016d0 <fd2num>
  801f17:	89 c3                	mov    %eax,%ebx
}
  801f19:	89 d8                	mov    %ebx,%eax
  801f1b:	83 c4 20             	add    $0x20,%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    
	...

00801f30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 18             	sub    $0x18,%esp
  801f36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f39:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f3c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f42:	89 04 24             	mov    %eax,(%esp)
  801f45:	e8 96 f7 ff ff       	call   8016e0 <fd2data>
  801f4a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f4c:	c7 44 24 04 db 2e 80 	movl   $0x802edb,0x4(%esp)
  801f53:	00 
  801f54:	89 34 24             	mov    %esi,(%esp)
  801f57:	e8 4f ea ff ff       	call   8009ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f5c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f5f:	2b 03                	sub    (%ebx),%eax
  801f61:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f67:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f6e:	00 00 00 
	stat->st_dev = &devpipe;
  801f71:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801f78:	30 80 00 
	return 0;
}
  801f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f80:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f83:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f86:	89 ec                	mov    %ebp,%esp
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	53                   	push   %ebx
  801f8e:	83 ec 14             	sub    $0x14,%esp
  801f91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9f:	e8 c5 ef ff ff       	call   800f69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fa4:	89 1c 24             	mov    %ebx,(%esp)
  801fa7:	e8 34 f7 ff ff       	call   8016e0 <fd2data>
  801fac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb7:	e8 ad ef ff ff       	call   800f69 <sys_page_unmap>
}
  801fbc:	83 c4 14             	add    $0x14,%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    

00801fc2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	57                   	push   %edi
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 2c             	sub    $0x2c,%esp
  801fcb:	89 c7                	mov    %eax,%edi
  801fcd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fd0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fd8:	89 3c 24             	mov    %edi,(%esp)
  801fdb:	e8 e8 05 00 00       	call   8025c8 <pageref>
  801fe0:	89 c6                	mov    %eax,%esi
  801fe2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 db 05 00 00       	call   8025c8 <pageref>
  801fed:	39 c6                	cmp    %eax,%esi
  801fef:	0f 94 c0             	sete   %al
  801ff2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ff5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ffb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ffe:	39 cb                	cmp    %ecx,%ebx
  802000:	75 08                	jne    80200a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802002:	83 c4 2c             	add    $0x2c,%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80200a:	83 f8 01             	cmp    $0x1,%eax
  80200d:	75 c1                	jne    801fd0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80200f:	8b 52 58             	mov    0x58(%edx),%edx
  802012:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802016:	89 54 24 08          	mov    %edx,0x8(%esp)
  80201a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80201e:	c7 04 24 e2 2e 80 00 	movl   $0x802ee2,(%esp)
  802025:	e8 31 e2 ff ff       	call   80025b <cprintf>
  80202a:	eb a4                	jmp    801fd0 <_pipeisclosed+0xe>

0080202c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	57                   	push   %edi
  802030:	56                   	push   %esi
  802031:	53                   	push   %ebx
  802032:	83 ec 2c             	sub    $0x2c,%esp
  802035:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802038:	89 34 24             	mov    %esi,(%esp)
  80203b:	e8 a0 f6 ff ff       	call   8016e0 <fd2data>
  802040:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802042:	bf 00 00 00 00       	mov    $0x0,%edi
  802047:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80204b:	75 50                	jne    80209d <devpipe_write+0x71>
  80204d:	eb 5c                	jmp    8020ab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80204f:	89 da                	mov    %ebx,%edx
  802051:	89 f0                	mov    %esi,%eax
  802053:	e8 6a ff ff ff       	call   801fc2 <_pipeisclosed>
  802058:	85 c0                	test   %eax,%eax
  80205a:	75 53                	jne    8020af <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80205c:	e8 1b ee ff ff       	call   800e7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802061:	8b 43 04             	mov    0x4(%ebx),%eax
  802064:	8b 13                	mov    (%ebx),%edx
  802066:	83 c2 20             	add    $0x20,%edx
  802069:	39 d0                	cmp    %edx,%eax
  80206b:	73 e2                	jae    80204f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80206d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802070:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802074:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802077:	89 c2                	mov    %eax,%edx
  802079:	c1 fa 1f             	sar    $0x1f,%edx
  80207c:	c1 ea 1b             	shr    $0x1b,%edx
  80207f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802082:	83 e1 1f             	and    $0x1f,%ecx
  802085:	29 d1                	sub    %edx,%ecx
  802087:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80208b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80208f:	83 c0 01             	add    $0x1,%eax
  802092:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802095:	83 c7 01             	add    $0x1,%edi
  802098:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80209b:	74 0e                	je     8020ab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80209d:	8b 43 04             	mov    0x4(%ebx),%eax
  8020a0:	8b 13                	mov    (%ebx),%edx
  8020a2:	83 c2 20             	add    $0x20,%edx
  8020a5:	39 d0                	cmp    %edx,%eax
  8020a7:	73 a6                	jae    80204f <devpipe_write+0x23>
  8020a9:	eb c2                	jmp    80206d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020ab:	89 f8                	mov    %edi,%eax
  8020ad:	eb 05                	jmp    8020b4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020af:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020b4:	83 c4 2c             	add    $0x2c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    

008020bc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	83 ec 28             	sub    $0x28,%esp
  8020c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8020c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8020cb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020ce:	89 3c 24             	mov    %edi,(%esp)
  8020d1:	e8 0a f6 ff ff       	call   8016e0 <fd2data>
  8020d6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d8:	be 00 00 00 00       	mov    $0x0,%esi
  8020dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020e1:	75 47                	jne    80212a <devpipe_read+0x6e>
  8020e3:	eb 52                	jmp    802137 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8020e5:	89 f0                	mov    %esi,%eax
  8020e7:	eb 5e                	jmp    802147 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020e9:	89 da                	mov    %ebx,%edx
  8020eb:	89 f8                	mov    %edi,%eax
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
  8020f0:	e8 cd fe ff ff       	call   801fc2 <_pipeisclosed>
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	75 49                	jne    802142 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8020f9:	e8 7e ed ff ff       	call   800e7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020fe:	8b 03                	mov    (%ebx),%eax
  802100:	3b 43 04             	cmp    0x4(%ebx),%eax
  802103:	74 e4                	je     8020e9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802105:	89 c2                	mov    %eax,%edx
  802107:	c1 fa 1f             	sar    $0x1f,%edx
  80210a:	c1 ea 1b             	shr    $0x1b,%edx
  80210d:	01 d0                	add    %edx,%eax
  80210f:	83 e0 1f             	and    $0x1f,%eax
  802112:	29 d0                	sub    %edx,%eax
  802114:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802119:	8b 55 0c             	mov    0xc(%ebp),%edx
  80211c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80211f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802122:	83 c6 01             	add    $0x1,%esi
  802125:	3b 75 10             	cmp    0x10(%ebp),%esi
  802128:	74 0d                	je     802137 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80212a:	8b 03                	mov    (%ebx),%eax
  80212c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80212f:	75 d4                	jne    802105 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802131:	85 f6                	test   %esi,%esi
  802133:	75 b0                	jne    8020e5 <devpipe_read+0x29>
  802135:	eb b2                	jmp    8020e9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802137:	89 f0                	mov    %esi,%eax
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	eb 05                	jmp    802147 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802142:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802147:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80214a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80214d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802150:	89 ec                	mov    %ebp,%esp
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	83 ec 48             	sub    $0x48,%esp
  80215a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80215d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802160:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802163:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802166:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802169:	89 04 24             	mov    %eax,(%esp)
  80216c:	e8 8a f5 ff ff       	call   8016fb <fd_alloc>
  802171:	89 c3                	mov    %eax,%ebx
  802173:	85 c0                	test   %eax,%eax
  802175:	0f 88 45 01 00 00    	js     8022c0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80217b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802182:	00 
  802183:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802191:	e8 16 ed ff ff       	call   800eac <sys_page_alloc>
  802196:	89 c3                	mov    %eax,%ebx
  802198:	85 c0                	test   %eax,%eax
  80219a:	0f 88 20 01 00 00    	js     8022c0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021a0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8021a3:	89 04 24             	mov    %eax,(%esp)
  8021a6:	e8 50 f5 ff ff       	call   8016fb <fd_alloc>
  8021ab:	89 c3                	mov    %eax,%ebx
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	0f 88 f8 00 00 00    	js     8022ad <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021bc:	00 
  8021bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021cb:	e8 dc ec ff ff       	call   800eac <sys_page_alloc>
  8021d0:	89 c3                	mov    %eax,%ebx
  8021d2:	85 c0                	test   %eax,%eax
  8021d4:	0f 88 d3 00 00 00    	js     8022ad <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021dd:	89 04 24             	mov    %eax,(%esp)
  8021e0:	e8 fb f4 ff ff       	call   8016e0 <fd2data>
  8021e5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021ee:	00 
  8021ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021fa:	e8 ad ec ff ff       	call   800eac <sys_page_alloc>
  8021ff:	89 c3                	mov    %eax,%ebx
  802201:	85 c0                	test   %eax,%eax
  802203:	0f 88 91 00 00 00    	js     80229a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802209:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80220c:	89 04 24             	mov    %eax,(%esp)
  80220f:	e8 cc f4 ff ff       	call   8016e0 <fd2data>
  802214:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80221b:	00 
  80221c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802220:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802227:	00 
  802228:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802233:	e8 d3 ec ff ff       	call   800f0b <sys_page_map>
  802238:	89 c3                	mov    %eax,%ebx
  80223a:	85 c0                	test   %eax,%eax
  80223c:	78 4c                	js     80228a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80223e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802247:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80224c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802253:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802259:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80225c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80225e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802261:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80226b:	89 04 24             	mov    %eax,(%esp)
  80226e:	e8 5d f4 ff ff       	call   8016d0 <fd2num>
  802273:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802275:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802278:	89 04 24             	mov    %eax,(%esp)
  80227b:	e8 50 f4 ff ff       	call   8016d0 <fd2num>
  802280:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802283:	bb 00 00 00 00       	mov    $0x0,%ebx
  802288:	eb 36                	jmp    8022c0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80228a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802295:	e8 cf ec ff ff       	call   800f69 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80229a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80229d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a8:	e8 bc ec ff ff       	call   800f69 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022bb:	e8 a9 ec ff ff       	call   800f69 <sys_page_unmap>
    err:
	return r;
}
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8022c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8022c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8022cb:	89 ec                	mov    %ebp,%esp
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    

008022cf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022cf:	55                   	push   %ebp
  8022d0:	89 e5                	mov    %esp,%ebp
  8022d2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022df:	89 04 24             	mov    %eax,(%esp)
  8022e2:	e8 87 f4 ff ff       	call   80176e <fd_lookup>
  8022e7:	85 c0                	test   %eax,%eax
  8022e9:	78 15                	js     802300 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ee:	89 04 24             	mov    %eax,(%esp)
  8022f1:	e8 ea f3 ff ff       	call   8016e0 <fd2data>
	return _pipeisclosed(fd, p);
  8022f6:	89 c2                	mov    %eax,%edx
  8022f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fb:	e8 c2 fc ff ff       	call   801fc2 <_pipeisclosed>
}
  802300:	c9                   	leave  
  802301:	c3                   	ret    
	...

00802310 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802313:	b8 00 00 00 00       	mov    $0x0,%eax
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    

0080231a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
  80231d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802320:	c7 44 24 04 fa 2e 80 	movl   $0x802efa,0x4(%esp)
  802327:	00 
  802328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232b:	89 04 24             	mov    %eax,(%esp)
  80232e:	e8 78 e6 ff ff       	call   8009ab <strcpy>
	return 0;
}
  802333:	b8 00 00 00 00       	mov    $0x0,%eax
  802338:	c9                   	leave  
  802339:	c3                   	ret    

0080233a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	57                   	push   %edi
  80233e:	56                   	push   %esi
  80233f:	53                   	push   %ebx
  802340:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802346:	be 00 00 00 00       	mov    $0x0,%esi
  80234b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80234f:	74 43                	je     802394 <devcons_write+0x5a>
  802351:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802356:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80235c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80235f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802361:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802364:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802369:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80236c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802370:	03 45 0c             	add    0xc(%ebp),%eax
  802373:	89 44 24 04          	mov    %eax,0x4(%esp)
  802377:	89 3c 24             	mov    %edi,(%esp)
  80237a:	e8 1d e8 ff ff       	call   800b9c <memmove>
		sys_cputs(buf, m);
  80237f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802383:	89 3c 24             	mov    %edi,(%esp)
  802386:	e8 05 ea ff ff       	call   800d90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80238b:	01 de                	add    %ebx,%esi
  80238d:	89 f0                	mov    %esi,%eax
  80238f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802392:	72 c8                	jb     80235c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802394:	89 f0                	mov    %esi,%eax
  802396:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80239c:	5b                   	pop    %ebx
  80239d:	5e                   	pop    %esi
  80239e:	5f                   	pop    %edi
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    

008023a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023a1:	55                   	push   %ebp
  8023a2:	89 e5                	mov    %esp,%ebp
  8023a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8023a7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8023ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023b0:	75 07                	jne    8023b9 <devcons_read+0x18>
  8023b2:	eb 31                	jmp    8023e5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023b4:	e8 c3 ea ff ff       	call   800e7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	e8 fa e9 ff ff       	call   800dbf <sys_cgetc>
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	74 eb                	je     8023b4 <devcons_read+0x13>
  8023c9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8023cb:	85 c0                	test   %eax,%eax
  8023cd:	78 16                	js     8023e5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023cf:	83 f8 04             	cmp    $0x4,%eax
  8023d2:	74 0c                	je     8023e0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8023d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d7:	88 10                	mov    %dl,(%eax)
	return 1;
  8023d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8023de:	eb 05                	jmp    8023e5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023e0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023e5:	c9                   	leave  
  8023e6:	c3                   	ret    

008023e7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023e7:	55                   	push   %ebp
  8023e8:	89 e5                	mov    %esp,%ebp
  8023ea:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8023ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8023fa:	00 
  8023fb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023fe:	89 04 24             	mov    %eax,(%esp)
  802401:	e8 8a e9 ff ff       	call   800d90 <sys_cputs>
}
  802406:	c9                   	leave  
  802407:	c3                   	ret    

00802408 <getchar>:

int
getchar(void)
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80240e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802415:	00 
  802416:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802424:	e8 05 f6 ff ff       	call   801a2e <read>
	if (r < 0)
  802429:	85 c0                	test   %eax,%eax
  80242b:	78 0f                	js     80243c <getchar+0x34>
		return r;
	if (r < 1)
  80242d:	85 c0                	test   %eax,%eax
  80242f:	7e 06                	jle    802437 <getchar+0x2f>
		return -E_EOF;
	return c;
  802431:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802435:	eb 05                	jmp    80243c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802437:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80243c:	c9                   	leave  
  80243d:	c3                   	ret    

0080243e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80243e:	55                   	push   %ebp
  80243f:	89 e5                	mov    %esp,%ebp
  802441:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244b:	8b 45 08             	mov    0x8(%ebp),%eax
  80244e:	89 04 24             	mov    %eax,(%esp)
  802451:	e8 18 f3 ff ff       	call   80176e <fd_lookup>
  802456:	85 c0                	test   %eax,%eax
  802458:	78 11                	js     80246b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802463:	39 10                	cmp    %edx,(%eax)
  802465:	0f 94 c0             	sete   %al
  802468:	0f b6 c0             	movzbl %al,%eax
}
  80246b:	c9                   	leave  
  80246c:	c3                   	ret    

0080246d <opencons>:

int
opencons(void)
{
  80246d:	55                   	push   %ebp
  80246e:	89 e5                	mov    %esp,%ebp
  802470:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802476:	89 04 24             	mov    %eax,(%esp)
  802479:	e8 7d f2 ff ff       	call   8016fb <fd_alloc>
  80247e:	85 c0                	test   %eax,%eax
  802480:	78 3c                	js     8024be <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802482:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802489:	00 
  80248a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802491:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802498:	e8 0f ea ff ff       	call   800eac <sys_page_alloc>
  80249d:	85 c0                	test   %eax,%eax
  80249f:	78 1d                	js     8024be <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024a1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8024a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024aa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024b6:	89 04 24             	mov    %eax,(%esp)
  8024b9:	e8 12 f2 ff ff       	call   8016d0 <fd2num>
}
  8024be:	c9                   	leave  
  8024bf:	c3                   	ret    

008024c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	56                   	push   %esi
  8024c4:	53                   	push   %ebx
  8024c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8024c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8024cb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8024d1:	e8 76 e9 ff ff       	call   800e4c <sys_getenvid>
  8024d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8024e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ec:	c7 04 24 08 2f 80 00 	movl   $0x802f08,(%esp)
  8024f3:	e8 63 dd ff ff       	call   80025b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8024f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8024ff:	89 04 24             	mov    %eax,(%esp)
  802502:	e8 f3 dc ff ff       	call   8001fa <vcprintf>
	cprintf("\n");
  802507:	c7 04 24 7f 2c 80 00 	movl   $0x802c7f,(%esp)
  80250e:	e8 48 dd ff ff       	call   80025b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802513:	cc                   	int3   
  802514:	eb fd                	jmp    802513 <_panic+0x53>
	...

00802518 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802518:	55                   	push   %ebp
  802519:	89 e5                	mov    %esp,%ebp
  80251b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80251e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802525:	75 3c                	jne    802563 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802527:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80252e:	00 
  80252f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802536:	ee 
  802537:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80253e:	e8 69 e9 ff ff       	call   800eac <sys_page_alloc>
  802543:	85 c0                	test   %eax,%eax
  802545:	79 1c                	jns    802563 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  802547:	c7 44 24 08 2c 2f 80 	movl   $0x802f2c,0x8(%esp)
  80254e:	00 
  80254f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802556:	00 
  802557:	c7 04 24 90 2f 80 00 	movl   $0x802f90,(%esp)
  80255e:	e8 5d ff ff ff       	call   8024c0 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802563:	8b 45 08             	mov    0x8(%ebp),%eax
  802566:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80256b:	c7 44 24 04 a4 25 80 	movl   $0x8025a4,0x4(%esp)
  802572:	00 
  802573:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80257a:	e8 04 eb ff ff       	call   801083 <sys_env_set_pgfault_upcall>
  80257f:	85 c0                	test   %eax,%eax
  802581:	79 1c                	jns    80259f <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802583:	c7 44 24 08 58 2f 80 	movl   $0x802f58,0x8(%esp)
  80258a:	00 
  80258b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  802592:	00 
  802593:	c7 04 24 90 2f 80 00 	movl   $0x802f90,(%esp)
  80259a:	e8 21 ff ff ff       	call   8024c0 <_panic>
}
  80259f:	c9                   	leave  
  8025a0:	c3                   	ret    
  8025a1:	00 00                	add    %al,(%eax)
	...

008025a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025a5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8025aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025ac:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  8025af:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  8025b3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  8025b8:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8025bc:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  8025be:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  8025c1:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  8025c2:	83 c4 04             	add    $0x4,%esp
    popfl
  8025c5:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8025c6:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8025c7:	c3                   	ret    

008025c8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025c8:	55                   	push   %ebp
  8025c9:	89 e5                	mov    %esp,%ebp
  8025cb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025ce:	89 d0                	mov    %edx,%eax
  8025d0:	c1 e8 16             	shr    $0x16,%eax
  8025d3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025da:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025df:	f6 c1 01             	test   $0x1,%cl
  8025e2:	74 1d                	je     802601 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025e4:	c1 ea 0c             	shr    $0xc,%edx
  8025e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025ee:	f6 c2 01             	test   $0x1,%dl
  8025f1:	74 0e                	je     802601 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025f3:	c1 ea 0c             	shr    $0xc,%edx
  8025f6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025fd:	ef 
  8025fe:	0f b7 c0             	movzwl %ax,%eax
}
  802601:	5d                   	pop    %ebp
  802602:	c3                   	ret    
	...

00802610 <__udivdi3>:
  802610:	83 ec 1c             	sub    $0x1c,%esp
  802613:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802617:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80261b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80261f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802623:	89 74 24 10          	mov    %esi,0x10(%esp)
  802627:	8b 74 24 24          	mov    0x24(%esp),%esi
  80262b:	85 ff                	test   %edi,%edi
  80262d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802631:	89 44 24 08          	mov    %eax,0x8(%esp)
  802635:	89 cd                	mov    %ecx,%ebp
  802637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80263b:	75 33                	jne    802670 <__udivdi3+0x60>
  80263d:	39 f1                	cmp    %esi,%ecx
  80263f:	77 57                	ja     802698 <__udivdi3+0x88>
  802641:	85 c9                	test   %ecx,%ecx
  802643:	75 0b                	jne    802650 <__udivdi3+0x40>
  802645:	b8 01 00 00 00       	mov    $0x1,%eax
  80264a:	31 d2                	xor    %edx,%edx
  80264c:	f7 f1                	div    %ecx
  80264e:	89 c1                	mov    %eax,%ecx
  802650:	89 f0                	mov    %esi,%eax
  802652:	31 d2                	xor    %edx,%edx
  802654:	f7 f1                	div    %ecx
  802656:	89 c6                	mov    %eax,%esi
  802658:	8b 44 24 04          	mov    0x4(%esp),%eax
  80265c:	f7 f1                	div    %ecx
  80265e:	89 f2                	mov    %esi,%edx
  802660:	8b 74 24 10          	mov    0x10(%esp),%esi
  802664:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802668:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80266c:	83 c4 1c             	add    $0x1c,%esp
  80266f:	c3                   	ret    
  802670:	31 d2                	xor    %edx,%edx
  802672:	31 c0                	xor    %eax,%eax
  802674:	39 f7                	cmp    %esi,%edi
  802676:	77 e8                	ja     802660 <__udivdi3+0x50>
  802678:	0f bd cf             	bsr    %edi,%ecx
  80267b:	83 f1 1f             	xor    $0x1f,%ecx
  80267e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802682:	75 2c                	jne    8026b0 <__udivdi3+0xa0>
  802684:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802688:	76 04                	jbe    80268e <__udivdi3+0x7e>
  80268a:	39 f7                	cmp    %esi,%edi
  80268c:	73 d2                	jae    802660 <__udivdi3+0x50>
  80268e:	31 d2                	xor    %edx,%edx
  802690:	b8 01 00 00 00       	mov    $0x1,%eax
  802695:	eb c9                	jmp    802660 <__udivdi3+0x50>
  802697:	90                   	nop
  802698:	89 f2                	mov    %esi,%edx
  80269a:	f7 f1                	div    %ecx
  80269c:	31 d2                	xor    %edx,%edx
  80269e:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026a2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8026a6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8026aa:	83 c4 1c             	add    $0x1c,%esp
  8026ad:	c3                   	ret    
  8026ae:	66 90                	xchg   %ax,%ax
  8026b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026b5:	b8 20 00 00 00       	mov    $0x20,%eax
  8026ba:	89 ea                	mov    %ebp,%edx
  8026bc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026c0:	d3 e7                	shl    %cl,%edi
  8026c2:	89 c1                	mov    %eax,%ecx
  8026c4:	d3 ea                	shr    %cl,%edx
  8026c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026cb:	09 fa                	or     %edi,%edx
  8026cd:	89 f7                	mov    %esi,%edi
  8026cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026d9:	d3 e5                	shl    %cl,%ebp
  8026db:	89 c1                	mov    %eax,%ecx
  8026dd:	d3 ef                	shr    %cl,%edi
  8026df:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026e4:	d3 e2                	shl    %cl,%edx
  8026e6:	89 c1                	mov    %eax,%ecx
  8026e8:	d3 ee                	shr    %cl,%esi
  8026ea:	09 d6                	or     %edx,%esi
  8026ec:	89 fa                	mov    %edi,%edx
  8026ee:	89 f0                	mov    %esi,%eax
  8026f0:	f7 74 24 0c          	divl   0xc(%esp)
  8026f4:	89 d7                	mov    %edx,%edi
  8026f6:	89 c6                	mov    %eax,%esi
  8026f8:	f7 e5                	mul    %ebp
  8026fa:	39 d7                	cmp    %edx,%edi
  8026fc:	72 22                	jb     802720 <__udivdi3+0x110>
  8026fe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802702:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802707:	d3 e5                	shl    %cl,%ebp
  802709:	39 c5                	cmp    %eax,%ebp
  80270b:	73 04                	jae    802711 <__udivdi3+0x101>
  80270d:	39 d7                	cmp    %edx,%edi
  80270f:	74 0f                	je     802720 <__udivdi3+0x110>
  802711:	89 f0                	mov    %esi,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	e9 46 ff ff ff       	jmp    802660 <__udivdi3+0x50>
  80271a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802720:	8d 46 ff             	lea    -0x1(%esi),%eax
  802723:	31 d2                	xor    %edx,%edx
  802725:	8b 74 24 10          	mov    0x10(%esp),%esi
  802729:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80272d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802731:	83 c4 1c             	add    $0x1c,%esp
  802734:	c3                   	ret    
	...

00802740 <__umoddi3>:
  802740:	83 ec 1c             	sub    $0x1c,%esp
  802743:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802747:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80274b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80274f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802753:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802757:	8b 74 24 24          	mov    0x24(%esp),%esi
  80275b:	85 ed                	test   %ebp,%ebp
  80275d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802761:	89 44 24 08          	mov    %eax,0x8(%esp)
  802765:	89 cf                	mov    %ecx,%edi
  802767:	89 04 24             	mov    %eax,(%esp)
  80276a:	89 f2                	mov    %esi,%edx
  80276c:	75 1a                	jne    802788 <__umoddi3+0x48>
  80276e:	39 f1                	cmp    %esi,%ecx
  802770:	76 4e                	jbe    8027c0 <__umoddi3+0x80>
  802772:	f7 f1                	div    %ecx
  802774:	89 d0                	mov    %edx,%eax
  802776:	31 d2                	xor    %edx,%edx
  802778:	8b 74 24 10          	mov    0x10(%esp),%esi
  80277c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802780:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	c3                   	ret    
  802788:	39 f5                	cmp    %esi,%ebp
  80278a:	77 54                	ja     8027e0 <__umoddi3+0xa0>
  80278c:	0f bd c5             	bsr    %ebp,%eax
  80278f:	83 f0 1f             	xor    $0x1f,%eax
  802792:	89 44 24 04          	mov    %eax,0x4(%esp)
  802796:	75 60                	jne    8027f8 <__umoddi3+0xb8>
  802798:	3b 0c 24             	cmp    (%esp),%ecx
  80279b:	0f 87 07 01 00 00    	ja     8028a8 <__umoddi3+0x168>
  8027a1:	89 f2                	mov    %esi,%edx
  8027a3:	8b 34 24             	mov    (%esp),%esi
  8027a6:	29 ce                	sub    %ecx,%esi
  8027a8:	19 ea                	sbb    %ebp,%edx
  8027aa:	89 34 24             	mov    %esi,(%esp)
  8027ad:	8b 04 24             	mov    (%esp),%eax
  8027b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027bc:	83 c4 1c             	add    $0x1c,%esp
  8027bf:	c3                   	ret    
  8027c0:	85 c9                	test   %ecx,%ecx
  8027c2:	75 0b                	jne    8027cf <__umoddi3+0x8f>
  8027c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c9:	31 d2                	xor    %edx,%edx
  8027cb:	f7 f1                	div    %ecx
  8027cd:	89 c1                	mov    %eax,%ecx
  8027cf:	89 f0                	mov    %esi,%eax
  8027d1:	31 d2                	xor    %edx,%edx
  8027d3:	f7 f1                	div    %ecx
  8027d5:	8b 04 24             	mov    (%esp),%eax
  8027d8:	f7 f1                	div    %ecx
  8027da:	eb 98                	jmp    802774 <__umoddi3+0x34>
  8027dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	89 f2                	mov    %esi,%edx
  8027e2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027e6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027ea:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027ee:	83 c4 1c             	add    $0x1c,%esp
  8027f1:	c3                   	ret    
  8027f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027f8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027fd:	89 e8                	mov    %ebp,%eax
  8027ff:	bd 20 00 00 00       	mov    $0x20,%ebp
  802804:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802808:	89 fa                	mov    %edi,%edx
  80280a:	d3 e0                	shl    %cl,%eax
  80280c:	89 e9                	mov    %ebp,%ecx
  80280e:	d3 ea                	shr    %cl,%edx
  802810:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802815:	09 c2                	or     %eax,%edx
  802817:	8b 44 24 08          	mov    0x8(%esp),%eax
  80281b:	89 14 24             	mov    %edx,(%esp)
  80281e:	89 f2                	mov    %esi,%edx
  802820:	d3 e7                	shl    %cl,%edi
  802822:	89 e9                	mov    %ebp,%ecx
  802824:	d3 ea                	shr    %cl,%edx
  802826:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80282b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80282f:	d3 e6                	shl    %cl,%esi
  802831:	89 e9                	mov    %ebp,%ecx
  802833:	d3 e8                	shr    %cl,%eax
  802835:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80283a:	09 f0                	or     %esi,%eax
  80283c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802840:	f7 34 24             	divl   (%esp)
  802843:	d3 e6                	shl    %cl,%esi
  802845:	89 74 24 08          	mov    %esi,0x8(%esp)
  802849:	89 d6                	mov    %edx,%esi
  80284b:	f7 e7                	mul    %edi
  80284d:	39 d6                	cmp    %edx,%esi
  80284f:	89 c1                	mov    %eax,%ecx
  802851:	89 d7                	mov    %edx,%edi
  802853:	72 3f                	jb     802894 <__umoddi3+0x154>
  802855:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802859:	72 35                	jb     802890 <__umoddi3+0x150>
  80285b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80285f:	29 c8                	sub    %ecx,%eax
  802861:	19 fe                	sbb    %edi,%esi
  802863:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802868:	89 f2                	mov    %esi,%edx
  80286a:	d3 e8                	shr    %cl,%eax
  80286c:	89 e9                	mov    %ebp,%ecx
  80286e:	d3 e2                	shl    %cl,%edx
  802870:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802875:	09 d0                	or     %edx,%eax
  802877:	89 f2                	mov    %esi,%edx
  802879:	d3 ea                	shr    %cl,%edx
  80287b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80287f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802883:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802887:	83 c4 1c             	add    $0x1c,%esp
  80288a:	c3                   	ret    
  80288b:	90                   	nop
  80288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802890:	39 d6                	cmp    %edx,%esi
  802892:	75 c7                	jne    80285b <__umoddi3+0x11b>
  802894:	89 d7                	mov    %edx,%edi
  802896:	89 c1                	mov    %eax,%ecx
  802898:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80289c:	1b 3c 24             	sbb    (%esp),%edi
  80289f:	eb ba                	jmp    80285b <__umoddi3+0x11b>
  8028a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 f5                	cmp    %esi,%ebp
  8028aa:	0f 82 f1 fe ff ff    	jb     8027a1 <__umoddi3+0x61>
  8028b0:	e9 f8 fe ff ff       	jmp    8027ad <__umoddi3+0x6d>
