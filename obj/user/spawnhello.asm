
obj/user/spawnhello.debug:     file format elf32-i386


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

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  80004d:	e8 a9 01 00 00       	call   8001fb <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 1e 2a 80 	movl   $0x802a1e,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 1e 2a 80 00 	movl   $0x802a1e,(%esp)
  800069:	e8 56 1f 00 00       	call   801fc4 <spawnl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("spawn(hello) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 24 2a 80 	movl   $0x802a24,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  80008d:	e8 6e 00 00 00       	call   800100 <_panic>
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

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
  8000a6:	e8 41 0d 00 00       	call   800dec <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	c1 e0 07             	shl    $0x7,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 60 ff ff ff       	call   800034 <umain>

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
	close_all();
  8000ea:	e8 7f 12 00 00       	call   80136e <close_all>
	sys_env_destroy(0);
  8000ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f6:	e8 94 0c 00 00       	call   800d8f <sys_env_destroy>
}
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800108:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80010b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800111:	e8 d6 0c 00 00       	call   800dec <sys_getenvid>
  800116:	8b 55 0c             	mov    0xc(%ebp),%edx
  800119:	89 54 24 10          	mov    %edx,0x10(%esp)
  80011d:	8b 55 08             	mov    0x8(%ebp),%edx
  800120:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800124:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012c:	c7 04 24 58 2a 80 00 	movl   $0x802a58,(%esp)
  800133:	e8 c3 00 00 00       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800138:	89 74 24 04          	mov    %esi,0x4(%esp)
  80013c:	8b 45 10             	mov    0x10(%ebp),%eax
  80013f:	89 04 24             	mov    %eax,(%esp)
  800142:	e8 53 00 00 00       	call   80019a <vcprintf>
	cprintf("\n");
  800147:	c7 04 24 70 2f 80 00 	movl   $0x802f70,(%esp)
  80014e:	e8 a8 00 00 00       	call   8001fb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800153:	cc                   	int3   
  800154:	eb fd                	jmp    800153 <_panic+0x53>
	...

00800158 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	53                   	push   %ebx
  80015c:	83 ec 14             	sub    $0x14,%esp
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800162:	8b 03                	mov    (%ebx),%eax
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016b:	83 c0 01             	add    $0x1,%eax
  80016e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800170:	3d ff 00 00 00       	cmp    $0xff,%eax
  800175:	75 19                	jne    800190 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800177:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017e:	00 
  80017f:	8d 43 08             	lea    0x8(%ebx),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 a6 0b 00 00       	call   800d30 <sys_cputs>
		b->idx = 0;
  80018a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800190:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800194:	83 c4 14             	add    $0x14,%esp
  800197:	5b                   	pop    %ebx
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001aa:	00 00 00 
	b.cnt = 0;
  8001ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cf:	c7 04 24 58 01 80 00 	movl   $0x800158,(%esp)
  8001d6:	e8 97 01 00 00       	call   800372 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001eb:	89 04 24             	mov    %eax,(%esp)
  8001ee:	e8 3d 0b 00 00       	call   800d30 <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	89 44 24 04          	mov    %eax,0x4(%esp)
  800208:	8b 45 08             	mov    0x8(%ebp),%eax
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	e8 87 ff ff ff       	call   80019a <vcprintf>
	va_end(ap);

	return cnt;
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    
  800215:	00 00                	add    %al,(%eax)
	...

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 3c             	sub    $0x3c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d7                	mov    %edx,%edi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800235:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	b8 00 00 00 00       	mov    $0x0,%eax
  80023d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800240:	72 11                	jb     800253 <printnum+0x3b>
  800242:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800245:	39 45 10             	cmp    %eax,0x10(%ebp)
  800248:	76 09                	jbe    800253 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	85 db                	test   %ebx,%ebx
  80024f:	7f 51                	jg     8002a2 <printnum+0x8a>
  800251:	eb 5e                	jmp    8002b1 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800253:	89 74 24 10          	mov    %esi,0x10(%esp)
  800257:	83 eb 01             	sub    $0x1,%ebx
  80025a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80025e:	8b 45 10             	mov    0x10(%ebp),%eax
  800261:	89 44 24 08          	mov    %eax,0x8(%esp)
  800265:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800269:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80026d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800274:	00 
  800275:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800282:	e8 c9 24 00 00       	call   802750 <__udivdi3>
  800287:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	89 54 24 04          	mov    %edx,0x4(%esp)
  800296:	89 fa                	mov    %edi,%edx
  800298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029b:	e8 78 ff ff ff       	call   800218 <printnum>
  8002a0:	eb 0f                	jmp    8002b1 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a6:	89 34 24             	mov    %esi,(%esp)
  8002a9:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ac:	83 eb 01             	sub    $0x1,%ebx
  8002af:	75 f1                	jne    8002a2 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c7:	00 
  8002c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	e8 a6 25 00 00       	call   802880 <__umoddi3>
  8002da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002de:	0f be 80 7b 2a 80 00 	movsbl 0x802a7b(%eax),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002eb:	83 c4 3c             	add    $0x3c,%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f6:	83 fa 01             	cmp    $0x1,%edx
  8002f9:	7e 0e                	jle    800309 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 08             	lea    0x8(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	8b 52 04             	mov    0x4(%edx),%edx
  800307:	eb 22                	jmp    80032b <getuint+0x38>
	else if (lflag)
  800309:	85 d2                	test   %edx,%edx
  80030b:	74 10                	je     80031d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 0e                	jmp    80032b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800333:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800337:	8b 10                	mov    (%eax),%edx
  800339:	3b 50 04             	cmp    0x4(%eax),%edx
  80033c:	73 0a                	jae    800348 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800341:	88 0a                	mov    %cl,(%edx)
  800343:	83 c2 01             	add    $0x1,%edx
  800346:	89 10                	mov    %edx,(%eax)
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800350:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800353:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800357:	8b 45 10             	mov    0x10(%ebp),%eax
  80035a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	e8 02 00 00 00       	call   800372 <vprintfmt>
	va_end(ap);
}
  800370:	c9                   	leave  
  800371:	c3                   	ret    

00800372 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
  800378:	83 ec 5c             	sub    $0x5c,%esp
  80037b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037e:	8b 75 10             	mov    0x10(%ebp),%esi
  800381:	eb 12                	jmp    800395 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800383:	85 c0                	test   %eax,%eax
  800385:	0f 84 e4 04 00 00    	je     80086f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80038b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800395:	0f b6 06             	movzbl (%esi),%eax
  800398:	83 c6 01             	add    $0x1,%esi
  80039b:	83 f8 25             	cmp    $0x25,%eax
  80039e:	75 e3                	jne    800383 <vprintfmt+0x11>
  8003a0:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003a4:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003ab:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003b0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bc:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003bf:	eb 2b                	jmp    8003ec <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c4:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003c8:	eb 22                	jmp    8003ec <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cd:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003d1:	eb 19                	jmp    8003ec <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003dd:	eb 0d                	jmp    8003ec <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003df:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e5:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	0f b6 06             	movzbl (%esi),%eax
  8003ef:	0f b6 d0             	movzbl %al,%edx
  8003f2:	8d 7e 01             	lea    0x1(%esi),%edi
  8003f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003f8:	83 e8 23             	sub    $0x23,%eax
  8003fb:	3c 55                	cmp    $0x55,%al
  8003fd:	0f 87 46 04 00 00    	ja     800849 <vprintfmt+0x4d7>
  800403:	0f b6 c0             	movzbl %al,%eax
  800406:	ff 24 85 e0 2b 80 00 	jmp    *0x802be0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040d:	83 ea 30             	sub    $0x30,%edx
  800410:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800413:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800417:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80041d:	83 fa 09             	cmp    $0x9,%edx
  800420:	77 4a                	ja     80046c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800425:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800428:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80042b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80042f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800432:	8d 50 d0             	lea    -0x30(%eax),%edx
  800435:	83 fa 09             	cmp    $0x9,%edx
  800438:	76 eb                	jbe    800425 <vprintfmt+0xb3>
  80043a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80043d:	eb 2d                	jmp    80046c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800450:	eb 1a                	jmp    80046c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800455:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800459:	79 91                	jns    8003ec <vprintfmt+0x7a>
  80045b:	e9 73 ff ff ff       	jmp    8003d3 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800463:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80046a:	eb 80                	jmp    8003ec <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80046c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800470:	0f 89 76 ff ff ff    	jns    8003ec <vprintfmt+0x7a>
  800476:	e9 64 ff ff ff       	jmp    8003df <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800481:	e9 66 ff ff ff       	jmp    8003ec <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	8d 50 04             	lea    0x4(%eax),%edx
  80048c:	89 55 14             	mov    %edx,0x14(%ebp)
  80048f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80049e:	e9 f2 fe ff ff       	jmp    800395 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004a3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004a7:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004aa:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8004ae:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8004b1:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8004b5:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8004b8:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8004bb:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8004bf:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004c2:	80 f9 09             	cmp    $0x9,%cl
  8004c5:	77 1d                	ja     8004e4 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8004c7:	0f be c0             	movsbl %al,%eax
  8004ca:	6b c0 64             	imul   $0x64,%eax,%eax
  8004cd:	0f be d2             	movsbl %dl,%edx
  8004d0:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004d3:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004da:	a3 04 30 80 00       	mov    %eax,0x803004
  8004df:	e9 b1 fe ff ff       	jmp    800395 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004e4:	c7 44 24 04 93 2a 80 	movl   $0x802a93,0x4(%esp)
  8004eb:	00 
  8004ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	e8 14 05 00 00       	call   800a0b <strcmp>
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	75 0f                	jne    80050a <vprintfmt+0x198>
  8004fb:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800502:	00 00 00 
  800505:	e9 8b fe ff ff       	jmp    800395 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80050a:	c7 44 24 04 97 2a 80 	movl   $0x802a97,0x4(%esp)
  800511:	00 
  800512:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800515:	89 14 24             	mov    %edx,(%esp)
  800518:	e8 ee 04 00 00       	call   800a0b <strcmp>
  80051d:	85 c0                	test   %eax,%eax
  80051f:	75 0f                	jne    800530 <vprintfmt+0x1be>
  800521:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800528:	00 00 00 
  80052b:	e9 65 fe ff ff       	jmp    800395 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800530:	c7 44 24 04 9b 2a 80 	movl   $0x802a9b,0x4(%esp)
  800537:	00 
  800538:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80053b:	89 0c 24             	mov    %ecx,(%esp)
  80053e:	e8 c8 04 00 00       	call   800a0b <strcmp>
  800543:	85 c0                	test   %eax,%eax
  800545:	75 0f                	jne    800556 <vprintfmt+0x1e4>
  800547:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  80054e:	00 00 00 
  800551:	e9 3f fe ff ff       	jmp    800395 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800556:	c7 44 24 04 9f 2a 80 	movl   $0x802a9f,0x4(%esp)
  80055d:	00 
  80055e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800561:	89 3c 24             	mov    %edi,(%esp)
  800564:	e8 a2 04 00 00       	call   800a0b <strcmp>
  800569:	85 c0                	test   %eax,%eax
  80056b:	75 0f                	jne    80057c <vprintfmt+0x20a>
  80056d:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800574:	00 00 00 
  800577:	e9 19 fe ff ff       	jmp    800395 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80057c:	c7 44 24 04 a3 2a 80 	movl   $0x802aa3,0x4(%esp)
  800583:	00 
  800584:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800587:	89 04 24             	mov    %eax,(%esp)
  80058a:	e8 7c 04 00 00       	call   800a0b <strcmp>
  80058f:	85 c0                	test   %eax,%eax
  800591:	75 0f                	jne    8005a2 <vprintfmt+0x230>
  800593:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  80059a:	00 00 00 
  80059d:	e9 f3 fd ff ff       	jmp    800395 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005a2:	c7 44 24 04 a7 2a 80 	movl   $0x802aa7,0x4(%esp)
  8005a9:	00 
  8005aa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005ad:	89 14 24             	mov    %edx,(%esp)
  8005b0:	e8 56 04 00 00       	call   800a0b <strcmp>
  8005b5:	83 f8 01             	cmp    $0x1,%eax
  8005b8:	19 c0                	sbb    %eax,%eax
  8005ba:	f7 d0                	not    %eax
  8005bc:	83 c0 08             	add    $0x8,%eax
  8005bf:	a3 04 30 80 00       	mov    %eax,0x803004
  8005c4:	e9 cc fd ff ff       	jmp    800395 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 c2                	mov    %eax,%edx
  8005d6:	c1 fa 1f             	sar    $0x1f,%edx
  8005d9:	31 d0                	xor    %edx,%eax
  8005db:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005dd:	83 f8 0f             	cmp    $0xf,%eax
  8005e0:	7f 0b                	jg     8005ed <vprintfmt+0x27b>
  8005e2:	8b 14 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%edx
  8005e9:	85 d2                	test   %edx,%edx
  8005eb:	75 23                	jne    800610 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f1:	c7 44 24 08 ab 2a 80 	movl   $0x802aab,0x8(%esp)
  8005f8:	00 
  8005f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800600:	89 3c 24             	mov    %edi,(%esp)
  800603:	e8 42 fd ff ff       	call   80034a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80060b:	e9 85 fd ff ff       	jmp    800395 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800610:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800614:	c7 44 24 08 71 2e 80 	movl   $0x802e71,0x8(%esp)
  80061b:	00 
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	8b 7d 08             	mov    0x8(%ebp),%edi
  800623:	89 3c 24             	mov    %edi,(%esp)
  800626:	e8 1f fd ff ff       	call   80034a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80062e:	e9 62 fd ff ff       	jmp    800395 <vprintfmt+0x23>
  800633:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800636:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800639:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800647:	85 f6                	test   %esi,%esi
  800649:	b8 8c 2a 80 00       	mov    $0x802a8c,%eax
  80064e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800651:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800655:	7e 06                	jle    80065d <vprintfmt+0x2eb>
  800657:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80065b:	75 13                	jne    800670 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	0f be 06             	movsbl (%esi),%eax
  800660:	83 c6 01             	add    $0x1,%esi
  800663:	85 c0                	test   %eax,%eax
  800665:	0f 85 94 00 00 00    	jne    8006ff <vprintfmt+0x38d>
  80066b:	e9 81 00 00 00       	jmp    8006f1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800670:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800674:	89 34 24             	mov    %esi,(%esp)
  800677:	e8 9f 02 00 00       	call   80091b <strnlen>
  80067c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80067f:	29 c2                	sub    %eax,%edx
  800681:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800684:	85 d2                	test   %edx,%edx
  800686:	7e d5                	jle    80065d <vprintfmt+0x2eb>
					putch(padc, putdat);
  800688:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80068c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80068f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800692:	89 d6                	mov    %edx,%esi
  800694:	89 cf                	mov    %ecx,%edi
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	89 3c 24             	mov    %edi,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	83 ee 01             	sub    $0x1,%esi
  8006a3:	75 f1                	jne    800696 <vprintfmt+0x324>
  8006a5:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006a8:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006ab:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8006ae:	eb ad                	jmp    80065d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006b0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006b4:	74 1b                	je     8006d1 <vprintfmt+0x35f>
  8006b6:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006b9:	83 fa 5e             	cmp    $0x5e,%edx
  8006bc:	76 13                	jbe    8006d1 <vprintfmt+0x35f>
					putch('?', putdat);
  8006be:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006cc:	ff 55 08             	call   *0x8(%ebp)
  8006cf:	eb 0d                	jmp    8006de <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006d1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006de:	83 eb 01             	sub    $0x1,%ebx
  8006e1:	0f be 06             	movsbl (%esi),%eax
  8006e4:	83 c6 01             	add    $0x1,%esi
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	75 1a                	jne    800705 <vprintfmt+0x393>
  8006eb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006f8:	7f 1c                	jg     800716 <vprintfmt+0x3a4>
  8006fa:	e9 96 fc ff ff       	jmp    800395 <vprintfmt+0x23>
  8006ff:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800702:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800705:	85 ff                	test   %edi,%edi
  800707:	78 a7                	js     8006b0 <vprintfmt+0x33e>
  800709:	83 ef 01             	sub    $0x1,%edi
  80070c:	79 a2                	jns    8006b0 <vprintfmt+0x33e>
  80070e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800711:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800714:	eb db                	jmp    8006f1 <vprintfmt+0x37f>
  800716:	8b 7d 08             	mov    0x8(%ebp),%edi
  800719:	89 de                	mov    %ebx,%esi
  80071b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80071e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800722:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800729:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072b:	83 eb 01             	sub    $0x1,%ebx
  80072e:	75 ee                	jne    80071e <vprintfmt+0x3ac>
  800730:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800735:	e9 5b fc ff ff       	jmp    800395 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073a:	83 f9 01             	cmp    $0x1,%ecx
  80073d:	7e 10                	jle    80074f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8d 50 08             	lea    0x8(%eax),%edx
  800745:	89 55 14             	mov    %edx,0x14(%ebp)
  800748:	8b 30                	mov    (%eax),%esi
  80074a:	8b 78 04             	mov    0x4(%eax),%edi
  80074d:	eb 26                	jmp    800775 <vprintfmt+0x403>
	else if (lflag)
  80074f:	85 c9                	test   %ecx,%ecx
  800751:	74 12                	je     800765 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)
  80075c:	8b 30                	mov    (%eax),%esi
  80075e:	89 f7                	mov    %esi,%edi
  800760:	c1 ff 1f             	sar    $0x1f,%edi
  800763:	eb 10                	jmp    800775 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 04             	lea    0x4(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 30                	mov    (%eax),%esi
  800770:	89 f7                	mov    %esi,%edi
  800772:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800775:	85 ff                	test   %edi,%edi
  800777:	78 0e                	js     800787 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	89 f0                	mov    %esi,%eax
  80077b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077d:	be 0a 00 00 00       	mov    $0xa,%esi
  800782:	e9 84 00 00 00       	jmp    80080b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800787:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800792:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800795:	89 f0                	mov    %esi,%eax
  800797:	89 fa                	mov    %edi,%edx
  800799:	f7 d8                	neg    %eax
  80079b:	83 d2 00             	adc    $0x0,%edx
  80079e:	f7 da                	neg    %edx
			}
			base = 10;
  8007a0:	be 0a 00 00 00       	mov    $0xa,%esi
  8007a5:	eb 64                	jmp    80080b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a7:	89 ca                	mov    %ecx,%edx
  8007a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ac:	e8 42 fb ff ff       	call   8002f3 <getuint>
			base = 10;
  8007b1:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8007b6:	eb 53                	jmp    80080b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007b8:	89 ca                	mov    %ecx,%edx
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 31 fb ff ff       	call   8002f3 <getuint>
    			base = 8;
  8007c2:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8007c7:	eb 42                	jmp    80080b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007db:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007e2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 04             	lea    0x4(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ee:	8b 00                	mov    (%eax),%eax
  8007f0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8007fa:	eb 0f                	jmp    80080b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007fc:	89 ca                	mov    %ecx,%edx
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800801:	e8 ed fa ff ff       	call   8002f3 <getuint>
			base = 16;
  800806:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80080f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800813:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800816:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80081a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	89 54 24 04          	mov    %edx,0x4(%esp)
  800825:	89 da                	mov    %ebx,%edx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	e8 e9 f9 ff ff       	call   800218 <printnum>
			break;
  80082f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800832:	e9 5e fb ff ff       	jmp    800395 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800837:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083b:	89 14 24             	mov    %edx,(%esp)
  80083e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800841:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800844:	e9 4c fb ff ff       	jmp    800395 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800849:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800854:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800857:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80085b:	0f 84 34 fb ff ff    	je     800395 <vprintfmt+0x23>
  800861:	83 ee 01             	sub    $0x1,%esi
  800864:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800868:	75 f7                	jne    800861 <vprintfmt+0x4ef>
  80086a:	e9 26 fb ff ff       	jmp    800395 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80086f:	83 c4 5c             	add    $0x5c,%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 28             	sub    $0x28,%esp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800883:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800886:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800894:	85 c0                	test   %eax,%eax
  800896:	74 30                	je     8008c8 <vsnprintf+0x51>
  800898:	85 d2                	test   %edx,%edx
  80089a:	7e 2c                	jle    8008c8 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	c7 04 24 2d 03 80 00 	movl   $0x80032d,(%esp)
  8008b8:	e8 b5 fa ff ff       	call   800372 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c6:	eb 05                	jmp    8008cd <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	e8 82 ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    
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
  800dc3:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800dda:	e8 21 f3 ff ff       	call   800100 <_panic>

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
  800e30:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800e82:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800e99:	e8 62 f2 ff ff       	call   800100 <_panic>

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
  800ee0:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eef:	00 
  800ef0:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800ef7:	e8 04 f2 ff ff       	call   800100 <_panic>

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
  800f3e:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800f45:	00 
  800f46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800f55:	e8 a6 f1 ff ff       	call   800100 <_panic>

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
  800f9c:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800fb3:	e8 48 f1 ff ff       	call   800100 <_panic>

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

00800fc5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800fec:	7e 28                	jle    801016 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  801001:	00 
  801002:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801009:	00 
  80100a:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801011:	e8 ea f0 ff ff       	call   800100 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801016:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801019:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101f:	89 ec                	mov    %ebp,%esp
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 38             	sub    $0x38,%esp
  801029:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80102f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	bb 00 00 00 00       	mov    $0x0,%ebx
  801037:	b8 0a 00 00 00       	mov    $0xa,%eax
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	89 df                	mov    %ebx,%edi
  801044:	89 de                	mov    %ebx,%esi
  801046:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801048:	85 c0                	test   %eax,%eax
  80104a:	7e 28                	jle    801074 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801050:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801057:	00 
  801058:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  80106f:	e8 8c f0 ff ff       	call   800100 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801074:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801077:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107d:	89 ec                	mov    %ebp,%esp
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80108d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801090:	be 00 00 00 00       	mov    $0x0,%esi
  801095:	b8 0c 00 00 00       	mov    $0xc,%eax
  80109a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80109d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b1:	89 ec                	mov    %ebp,%esp
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 38             	sub    $0x38,%esp
  8010bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d1:	89 cb                	mov    %ecx,%ebx
  8010d3:	89 cf                	mov    %ecx,%edi
  8010d5:	89 ce                	mov    %ecx,%esi
  8010d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	7e 28                	jle    801105 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f8:	00 
  8010f9:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801100:	e8 fb ef ff ff       	call   800100 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801105:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801108:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80110e:	89 ec                	mov    %ebp,%esp
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80111e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801121:	b9 00 00 00 00       	mov    $0x0,%ecx
  801126:	b8 0e 00 00 00       	mov    $0xe,%eax
  80112b:	8b 55 08             	mov    0x8(%ebp),%edx
  80112e:	89 cb                	mov    %ecx,%ebx
  801130:	89 cf                	mov    %ecx,%edi
  801132:	89 ce                	mov    %ecx,%esi
  801134:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801136:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801139:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113f:	89 ec                	mov    %ebp,%esp
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    
	...

00801150 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	05 00 00 00 30       	add    $0x30000000,%eax
  80115b:	c1 e8 0c             	shr    $0xc,%eax
}
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801166:	8b 45 08             	mov    0x8(%ebp),%eax
  801169:	89 04 24             	mov    %eax,(%esp)
  80116c:	e8 df ff ff ff       	call   801150 <fd2num>
  801171:	05 20 00 0d 00       	add    $0xd0020,%eax
  801176:	c1 e0 0c             	shl    $0xc,%eax
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	53                   	push   %ebx
  80117f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801182:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801187:	a8 01                	test   $0x1,%al
  801189:	74 34                	je     8011bf <fd_alloc+0x44>
  80118b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801190:	a8 01                	test   $0x1,%al
  801192:	74 32                	je     8011c6 <fd_alloc+0x4b>
  801194:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801199:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	c1 ea 16             	shr    $0x16,%edx
  8011a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	74 1f                	je     8011cb <fd_alloc+0x50>
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 0c             	shr    $0xc,%edx
  8011b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	75 17                	jne    8011d4 <fd_alloc+0x59>
  8011bd:	eb 0c                	jmp    8011cb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011bf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011c4:	eb 05                	jmp    8011cb <fd_alloc+0x50>
  8011c6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011cb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d2:	eb 17                	jmp    8011eb <fd_alloc+0x70>
  8011d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011de:	75 b9                	jne    801199 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011eb:	5b                   	pop    %ebx
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f9:	83 fa 1f             	cmp    $0x1f,%edx
  8011fc:	77 3f                	ja     80123d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fe:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801204:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801207:	89 d0                	mov    %edx,%eax
  801209:	c1 e8 16             	shr    $0x16,%eax
  80120c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801213:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801218:	f6 c1 01             	test   $0x1,%cl
  80121b:	74 20                	je     80123d <fd_lookup+0x4f>
  80121d:	89 d0                	mov    %edx,%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
  801222:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801229:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80122e:	f6 c1 01             	test   $0x1,%cl
  801231:	74 0a                	je     80123d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801233:	8b 45 0c             	mov    0xc(%ebp),%eax
  801236:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	53                   	push   %ebx
  801243:	83 ec 14             	sub    $0x14,%esp
  801246:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801249:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801251:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801257:	75 17                	jne    801270 <dev_lookup+0x31>
  801259:	eb 07                	jmp    801262 <dev_lookup+0x23>
  80125b:	39 0a                	cmp    %ecx,(%edx)
  80125d:	75 11                	jne    801270 <dev_lookup+0x31>
  80125f:	90                   	nop
  801260:	eb 05                	jmp    801267 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801262:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801267:	89 13                	mov    %edx,(%ebx)
			return 0;
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
  80126e:	eb 35                	jmp    8012a5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801270:	83 c0 01             	add    $0x1,%eax
  801273:	8b 14 85 48 2e 80 00 	mov    0x802e48(,%eax,4),%edx
  80127a:	85 d2                	test   %edx,%edx
  80127c:	75 dd                	jne    80125b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80127e:	a1 04 40 80 00       	mov    0x804004,%eax
  801283:	8b 40 48             	mov    0x48(%eax),%eax
  801286:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128e:	c7 04 24 cc 2d 80 00 	movl   $0x802dcc,(%esp)
  801295:	e8 61 ef ff ff       	call   8001fb <cprintf>
	*dev = 0;
  80129a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012a5:	83 c4 14             	add    $0x14,%esp
  8012a8:	5b                   	pop    %ebx
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	83 ec 38             	sub    $0x38,%esp
  8012b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012bd:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c1:	89 3c 24             	mov    %edi,(%esp)
  8012c4:	e8 87 fe ff ff       	call   801150 <fd2num>
  8012c9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8012cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 16 ff ff ff       	call   8011ee <fd_lookup>
  8012d8:	89 c3                	mov    %eax,%ebx
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 05                	js     8012e3 <fd_close+0x38>
	    || fd != fd2)
  8012de:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8012e1:	74 0e                	je     8012f1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012e3:	89 f0                	mov    %esi,%eax
  8012e5:	84 c0                	test   %al,%al
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ec:	0f 44 d8             	cmove  %eax,%ebx
  8012ef:	eb 3d                	jmp    80132e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	8b 07                	mov    (%edi),%eax
  8012fa:	89 04 24             	mov    %eax,(%esp)
  8012fd:	e8 3d ff ff ff       	call   80123f <dev_lookup>
  801302:	89 c3                	mov    %eax,%ebx
  801304:	85 c0                	test   %eax,%eax
  801306:	78 16                	js     80131e <fd_close+0x73>
		if (dev->dev_close)
  801308:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801313:	85 c0                	test   %eax,%eax
  801315:	74 07                	je     80131e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801317:	89 3c 24             	mov    %edi,(%esp)
  80131a:	ff d0                	call   *%eax
  80131c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80131e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801322:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801329:	e8 db fb ff ff       	call   800f09 <sys_page_unmap>
	return r;
}
  80132e:	89 d8                	mov    %ebx,%eax
  801330:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801333:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801336:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801339:	89 ec                	mov    %ebp,%esp
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134a:	8b 45 08             	mov    0x8(%ebp),%eax
  80134d:	89 04 24             	mov    %eax,(%esp)
  801350:	e8 99 fe ff ff       	call   8011ee <fd_lookup>
  801355:	85 c0                	test   %eax,%eax
  801357:	78 13                	js     80136c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801359:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801360:	00 
  801361:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801364:	89 04 24             	mov    %eax,(%esp)
  801367:	e8 3f ff ff ff       	call   8012ab <fd_close>
}
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <close_all>:

void
close_all(void)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	53                   	push   %ebx
  801372:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801375:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80137a:	89 1c 24             	mov    %ebx,(%esp)
  80137d:	e8 bb ff ff ff       	call   80133d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801382:	83 c3 01             	add    $0x1,%ebx
  801385:	83 fb 20             	cmp    $0x20,%ebx
  801388:	75 f0                	jne    80137a <close_all+0xc>
		close(i);
}
  80138a:	83 c4 14             	add    $0x14,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 58             	sub    $0x58,%esp
  801396:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801399:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80139c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80139f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	89 04 24             	mov    %eax,(%esp)
  8013af:	e8 3a fe ff ff       	call   8011ee <fd_lookup>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	0f 88 e1 00 00 00    	js     80149f <dup+0x10f>
		return r;
	close(newfdnum);
  8013be:	89 3c 24             	mov    %edi,(%esp)
  8013c1:	e8 77 ff ff ff       	call   80133d <close>

	newfd = INDEX2FD(newfdnum);
  8013c6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013cc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d2:	89 04 24             	mov    %eax,(%esp)
  8013d5:	e8 86 fd ff ff       	call   801160 <fd2data>
  8013da:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013dc:	89 34 24             	mov    %esi,(%esp)
  8013df:	e8 7c fd ff ff       	call   801160 <fd2data>
  8013e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013e7:	89 d8                	mov    %ebx,%eax
  8013e9:	c1 e8 16             	shr    $0x16,%eax
  8013ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f3:	a8 01                	test   $0x1,%al
  8013f5:	74 46                	je     80143d <dup+0xad>
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	c1 e8 0c             	shr    $0xc,%eax
  8013fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801403:	f6 c2 01             	test   $0x1,%dl
  801406:	74 35                	je     80143d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801408:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140f:	25 07 0e 00 00       	and    $0xe07,%eax
  801414:	89 44 24 10          	mov    %eax,0x10(%esp)
  801418:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80141b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80141f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801426:	00 
  801427:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80142b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801432:	e8 74 fa ff ff       	call   800eab <sys_page_map>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 3b                	js     801478 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801440:	89 c2                	mov    %eax,%edx
  801442:	c1 ea 0c             	shr    $0xc,%edx
  801445:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801452:	89 54 24 10          	mov    %edx,0x10(%esp)
  801456:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80145a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801461:	00 
  801462:	89 44 24 04          	mov    %eax,0x4(%esp)
  801466:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146d:	e8 39 fa ff ff       	call   800eab <sys_page_map>
  801472:	89 c3                	mov    %eax,%ebx
  801474:	85 c0                	test   %eax,%eax
  801476:	79 25                	jns    80149d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801478:	89 74 24 04          	mov    %esi,0x4(%esp)
  80147c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801483:	e8 81 fa ff ff       	call   800f09 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801488:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801496:	e8 6e fa ff ff       	call   800f09 <sys_page_unmap>
	return r;
  80149b:	eb 02                	jmp    80149f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80149d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80149f:	89 d8                	mov    %ebx,%eax
  8014a1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014a4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014a7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014aa:	89 ec                	mov    %ebp,%esp
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 24             	sub    $0x24,%esp
  8014b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bf:	89 1c 24             	mov    %ebx,(%esp)
  8014c2:	e8 27 fd ff ff       	call   8011ee <fd_lookup>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 6d                	js     801538 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	8b 00                	mov    (%eax),%eax
  8014d7:	89 04 24             	mov    %eax,(%esp)
  8014da:	e8 60 fd ff ff       	call   80123f <dev_lookup>
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 55                	js     801538 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	8b 50 08             	mov    0x8(%eax),%edx
  8014e9:	83 e2 03             	and    $0x3,%edx
  8014ec:	83 fa 01             	cmp    $0x1,%edx
  8014ef:	75 23                	jne    801514 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f6:	8b 40 48             	mov    0x48(%eax),%eax
  8014f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801501:	c7 04 24 0d 2e 80 00 	movl   $0x802e0d,(%esp)
  801508:	e8 ee ec ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  80150d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801512:	eb 24                	jmp    801538 <read+0x8a>
	}
	if (!dev->dev_read)
  801514:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801517:	8b 52 08             	mov    0x8(%edx),%edx
  80151a:	85 d2                	test   %edx,%edx
  80151c:	74 15                	je     801533 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80151e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801521:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801525:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801528:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80152c:	89 04 24             	mov    %eax,(%esp)
  80152f:	ff d2                	call   *%edx
  801531:	eb 05                	jmp    801538 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801533:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801538:	83 c4 24             	add    $0x24,%esp
  80153b:	5b                   	pop    %ebx
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	57                   	push   %edi
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	83 ec 1c             	sub    $0x1c,%esp
  801547:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154d:	b8 00 00 00 00       	mov    $0x0,%eax
  801552:	85 f6                	test   %esi,%esi
  801554:	74 30                	je     801586 <readn+0x48>
  801556:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155b:	89 f2                	mov    %esi,%edx
  80155d:	29 c2                	sub    %eax,%edx
  80155f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801563:	03 45 0c             	add    0xc(%ebp),%eax
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	89 3c 24             	mov    %edi,(%esp)
  80156d:	e8 3c ff ff ff       	call   8014ae <read>
		if (m < 0)
  801572:	85 c0                	test   %eax,%eax
  801574:	78 10                	js     801586 <readn+0x48>
			return m;
		if (m == 0)
  801576:	85 c0                	test   %eax,%eax
  801578:	74 0a                	je     801584 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157a:	01 c3                	add    %eax,%ebx
  80157c:	89 d8                	mov    %ebx,%eax
  80157e:	39 f3                	cmp    %esi,%ebx
  801580:	72 d9                	jb     80155b <readn+0x1d>
  801582:	eb 02                	jmp    801586 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801584:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801586:	83 c4 1c             	add    $0x1c,%esp
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5f                   	pop    %edi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 24             	sub    $0x24,%esp
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801598:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159f:	89 1c 24             	mov    %ebx,(%esp)
  8015a2:	e8 47 fc ff ff       	call   8011ee <fd_lookup>
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 68                	js     801613 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	8b 00                	mov    (%eax),%eax
  8015b7:	89 04 24             	mov    %eax,(%esp)
  8015ba:	e8 80 fc ff ff       	call   80123f <dev_lookup>
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 50                	js     801613 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ca:	75 23                	jne    8015ef <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d1:	8b 40 48             	mov    0x48(%eax),%eax
  8015d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015dc:	c7 04 24 29 2e 80 00 	movl   $0x802e29,(%esp)
  8015e3:	e8 13 ec ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  8015e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ed:	eb 24                	jmp    801613 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f5:	85 d2                	test   %edx,%edx
  8015f7:	74 15                	je     80160e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015fc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801600:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801603:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801607:	89 04 24             	mov    %eax,(%esp)
  80160a:	ff d2                	call   *%edx
  80160c:	eb 05                	jmp    801613 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80160e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801613:	83 c4 24             	add    $0x24,%esp
  801616:	5b                   	pop    %ebx
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <seek>:

int
seek(int fdnum, off_t offset)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801622:	89 44 24 04          	mov    %eax,0x4(%esp)
  801626:	8b 45 08             	mov    0x8(%ebp),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 bd fb ff ff       	call   8011ee <fd_lookup>
  801631:	85 c0                	test   %eax,%eax
  801633:	78 0e                	js     801643 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801635:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801638:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 24             	sub    $0x24,%esp
  80164c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801652:	89 44 24 04          	mov    %eax,0x4(%esp)
  801656:	89 1c 24             	mov    %ebx,(%esp)
  801659:	e8 90 fb ff ff       	call   8011ee <fd_lookup>
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 61                	js     8016c3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801665:	89 44 24 04          	mov    %eax,0x4(%esp)
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	8b 00                	mov    (%eax),%eax
  80166e:	89 04 24             	mov    %eax,(%esp)
  801671:	e8 c9 fb ff ff       	call   80123f <dev_lookup>
  801676:	85 c0                	test   %eax,%eax
  801678:	78 49                	js     8016c3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801681:	75 23                	jne    8016a6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801683:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801688:	8b 40 48             	mov    0x48(%eax),%eax
  80168b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80168f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801693:	c7 04 24 ec 2d 80 00 	movl   $0x802dec,(%esp)
  80169a:	e8 5c eb ff ff       	call   8001fb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a4:	eb 1d                	jmp    8016c3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a9:	8b 52 18             	mov    0x18(%edx),%edx
  8016ac:	85 d2                	test   %edx,%edx
  8016ae:	74 0e                	je     8016be <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016b7:	89 04 24             	mov    %eax,(%esp)
  8016ba:	ff d2                	call   *%edx
  8016bc:	eb 05                	jmp    8016c3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c3:	83 c4 24             	add    $0x24,%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 24             	sub    $0x24,%esp
  8016d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	89 04 24             	mov    %eax,(%esp)
  8016e0:	e8 09 fb ff ff       	call   8011ee <fd_lookup>
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 52                	js     80173b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	8b 00                	mov    (%eax),%eax
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	e8 42 fb ff ff       	call   80123f <dev_lookup>
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 3a                	js     80173b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801701:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801704:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801708:	74 2c                	je     801736 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801714:	00 00 00 
	stat->st_isdir = 0;
  801717:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171e:	00 00 00 
	stat->st_dev = dev;
  801721:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801727:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80172b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80172e:	89 14 24             	mov    %edx,(%esp)
  801731:	ff 50 14             	call   *0x14(%eax)
  801734:	eb 05                	jmp    80173b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801736:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173b:	83 c4 24             	add    $0x24,%esp
  80173e:	5b                   	pop    %ebx
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 18             	sub    $0x18,%esp
  801747:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80174a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801754:	00 
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	89 04 24             	mov    %eax,(%esp)
  80175b:	e8 bc 01 00 00       	call   80191c <open>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	85 c0                	test   %eax,%eax
  801764:	78 1b                	js     801781 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801766:	8b 45 0c             	mov    0xc(%ebp),%eax
  801769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176d:	89 1c 24             	mov    %ebx,(%esp)
  801770:	e8 54 ff ff ff       	call   8016c9 <fstat>
  801775:	89 c6                	mov    %eax,%esi
	close(fd);
  801777:	89 1c 24             	mov    %ebx,(%esp)
  80177a:	e8 be fb ff ff       	call   80133d <close>
	return r;
  80177f:	89 f3                	mov    %esi,%ebx
}
  801781:	89 d8                	mov    %ebx,%eax
  801783:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801786:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801789:	89 ec                	mov    %ebp,%esp
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    
  80178d:	00 00                	add    %al,(%eax)
	...

00801790 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 18             	sub    $0x18,%esp
  801796:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801799:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017a0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a7:	75 11                	jne    8017ba <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017b0:	e8 0c 0f 00 00       	call   8026c1 <ipc_find_env>
  8017b5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ba:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017c1:	00 
  8017c2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017c9:	00 
  8017ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ce:	a1 00 40 80 00       	mov    0x804000,%eax
  8017d3:	89 04 24             	mov    %eax,(%esp)
  8017d6:	e8 7b 0e 00 00       	call   802656 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8017db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017e2:	00 
  8017e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ee:	e8 fd 0d 00 00       	call   8025f0 <ipc_recv>
}
  8017f3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017f6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017f9:	89 ec                	mov    %ebp,%esp
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	53                   	push   %ebx
  801801:	83 ec 14             	sub    $0x14,%esp
  801804:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 40 0c             	mov    0xc(%eax),%eax
  80180d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801812:	ba 00 00 00 00       	mov    $0x0,%edx
  801817:	b8 05 00 00 00       	mov    $0x5,%eax
  80181c:	e8 6f ff ff ff       	call   801790 <fsipc>
  801821:	85 c0                	test   %eax,%eax
  801823:	78 2b                	js     801850 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801825:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80182c:	00 
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 16 f1 ff ff       	call   80094b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801835:	a1 80 50 80 00       	mov    0x805080,%eax
  80183a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801840:	a1 84 50 80 00       	mov    0x805084,%eax
  801845:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801850:	83 c4 14             	add    $0x14,%esp
  801853:	5b                   	pop    %ebx
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	8b 40 0c             	mov    0xc(%eax),%eax
  801862:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801867:	ba 00 00 00 00       	mov    $0x0,%edx
  80186c:	b8 06 00 00 00       	mov    $0x6,%eax
  801871:	e8 1a ff ff ff       	call   801790 <fsipc>
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	83 ec 10             	sub    $0x10,%esp
  801880:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	8b 40 0c             	mov    0xc(%eax),%eax
  801889:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80188e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 03 00 00 00       	mov    $0x3,%eax
  80189e:	e8 ed fe ff ff       	call   801790 <fsipc>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 6a                	js     801913 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018a9:	39 c6                	cmp    %eax,%esi
  8018ab:	73 24                	jae    8018d1 <devfile_read+0x59>
  8018ad:	c7 44 24 0c 58 2e 80 	movl   $0x802e58,0xc(%esp)
  8018b4:	00 
  8018b5:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  8018bc:	00 
  8018bd:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8018c4:	00 
  8018c5:	c7 04 24 74 2e 80 00 	movl   $0x802e74,(%esp)
  8018cc:	e8 2f e8 ff ff       	call   800100 <_panic>
	assert(r <= PGSIZE);
  8018d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d6:	7e 24                	jle    8018fc <devfile_read+0x84>
  8018d8:	c7 44 24 0c 7f 2e 80 	movl   $0x802e7f,0xc(%esp)
  8018df:	00 
  8018e0:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  8018e7:	00 
  8018e8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8018ef:	00 
  8018f0:	c7 04 24 74 2e 80 00 	movl   $0x802e74,(%esp)
  8018f7:	e8 04 e8 ff ff       	call   800100 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801900:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801907:	00 
  801908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190b:	89 04 24             	mov    %eax,(%esp)
  80190e:	e8 29 f2 ff ff       	call   800b3c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801913:	89 d8                	mov    %ebx,%eax
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	83 ec 20             	sub    $0x20,%esp
  801924:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801927:	89 34 24             	mov    %esi,(%esp)
  80192a:	e8 d1 ef ff ff       	call   800900 <strlen>
		return -E_BAD_PATH;
  80192f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801934:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801939:	7f 5e                	jg     801999 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193e:	89 04 24             	mov    %eax,(%esp)
  801941:	e8 35 f8 ff ff       	call   80117b <fd_alloc>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 4d                	js     801999 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80194c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801950:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801957:	e8 ef ef ff ff       	call   80094b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801964:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801967:	b8 01 00 00 00       	mov    $0x1,%eax
  80196c:	e8 1f fe ff ff       	call   801790 <fsipc>
  801971:	89 c3                	mov    %eax,%ebx
  801973:	85 c0                	test   %eax,%eax
  801975:	79 15                	jns    80198c <open+0x70>
		fd_close(fd, 0);
  801977:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80197e:	00 
  80197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801982:	89 04 24             	mov    %eax,(%esp)
  801985:	e8 21 f9 ff ff       	call   8012ab <fd_close>
		return r;
  80198a:	eb 0d                	jmp    801999 <open+0x7d>
	}

	return fd2num(fd);
  80198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 b9 f7 ff ff       	call   801150 <fd2num>
  801997:	89 c3                	mov    %eax,%ebx
}
  801999:	89 d8                	mov    %ebx,%eax
  80199b:	83 c4 20             	add    $0x20,%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    
	...

008019a4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	57                   	push   %edi
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019b7:	00 
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 59 ff ff ff       	call   80191c <open>
  8019c3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	0f 88 c9 05 00 00    	js     801f9a <spawn+0x5f6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019d1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8019d8:	00 
  8019d9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8019e9:	89 04 24             	mov    %eax,(%esp)
  8019ec:	e8 4d fb ff ff       	call   80153e <readn>
  8019f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019f6:	75 0c                	jne    801a04 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8019f8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019ff:	45 4c 46 
  801a02:	74 3b                	je     801a3f <spawn+0x9b>
		close(fd);
  801a04:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a0a:	89 04 24             	mov    %eax,(%esp)
  801a0d:	e8 2b f9 ff ff       	call   80133d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a12:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801a19:	46 
  801a1a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801a20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a24:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  801a2b:	e8 cb e7 ff ff       	call   8001fb <cprintf>
		return -E_NOT_EXEC;
  801a30:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801a37:	ff ff ff 
  801a3a:	e9 67 05 00 00       	jmp    801fa6 <spawn+0x602>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801a3f:	ba 07 00 00 00       	mov    $0x7,%edx
  801a44:	89 d0                	mov    %edx,%eax
  801a46:	cd 30                	int    $0x30
  801a48:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a4e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 4a 05 00 00    	js     801fa6 <spawn+0x602>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a5c:	89 c6                	mov    %eax,%esi
  801a5e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a64:	c1 e6 07             	shl    $0x7,%esi
  801a67:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a6d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a73:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a7a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a80:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a89:	8b 02                	mov    (%edx),%eax
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	74 5f                	je     801aee <spawn+0x14a>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a8f:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (argc = 0; argv[argc] != 0; argc++)
  801a94:	be 00 00 00 00       	mov    $0x0,%esi
  801a99:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  801a9b:	89 04 24             	mov    %eax,(%esp)
  801a9e:	e8 5d ee ff ff       	call   800900 <strlen>
  801aa3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801aa7:	83 c6 01             	add    $0x1,%esi
  801aaa:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801aac:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ab3:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	75 e1                	jne    801a9b <spawn+0xf7>
  801aba:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801ac0:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ac6:	bf 00 10 40 00       	mov    $0x401000,%edi
  801acb:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801acd:	89 f8                	mov    %edi,%eax
  801acf:	83 e0 fc             	and    $0xfffffffc,%eax
  801ad2:	f7 d2                	not    %edx
  801ad4:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801ad7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801add:	89 d0                	mov    %edx,%eax
  801adf:	83 e8 08             	sub    $0x8,%eax
  801ae2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ae7:	77 2d                	ja     801b16 <spawn+0x172>
  801ae9:	e9 c9 04 00 00       	jmp    801fb7 <spawn+0x613>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801aee:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801af5:	00 00 00 
  801af8:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801aff:	00 00 00 
  801b02:	be 00 00 00 00       	mov    $0x0,%esi
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b07:	c7 85 94 fd ff ff fc 	movl   $0x400ffc,-0x26c(%ebp)
  801b0e:	0f 40 00 
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b11:	bf 00 10 40 00       	mov    $0x401000,%edi
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b16:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b1d:	00 
  801b1e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b25:	00 
  801b26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2d:	e8 1a f3 ff ff       	call   800e4c <sys_page_alloc>
  801b32:	85 c0                	test   %eax,%eax
  801b34:	0f 88 82 04 00 00    	js     801fbc <spawn+0x618>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b3a:	85 f6                	test   %esi,%esi
  801b3c:	7e 46                	jle    801b84 <spawn+0x1e0>
  801b3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b43:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b49:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  801b4c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b52:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b58:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801b5b:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b62:	89 3c 24             	mov    %edi,(%esp)
  801b65:	e8 e1 ed ff ff       	call   80094b <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b6a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b6d:	89 04 24             	mov    %eax,(%esp)
  801b70:	e8 8b ed ff ff       	call   800900 <strlen>
  801b75:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b79:	83 c3 01             	add    $0x1,%ebx
  801b7c:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801b82:	75 c8                	jne    801b4c <spawn+0x1a8>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b84:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b8a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b90:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b97:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b9d:	74 24                	je     801bc3 <spawn+0x21f>
  801b9f:	c7 44 24 0c 00 2f 80 	movl   $0x802f00,0xc(%esp)
  801ba6:	00 
  801ba7:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801bae:	00 
  801baf:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801bb6:	00 
  801bb7:	c7 04 24 a5 2e 80 00 	movl   $0x802ea5,(%esp)
  801bbe:	e8 3d e5 ff ff       	call   800100 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801bc3:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bc9:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801bce:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bd4:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801bd7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bdd:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801be0:	89 d0                	mov    %edx,%eax
  801be2:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801be7:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bed:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801bf4:	00 
  801bf5:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801bfc:	ee 
  801bfd:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c07:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c0e:	00 
  801c0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c16:	e8 90 f2 ff ff       	call   800eab <sys_page_map>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 1a                	js     801c3b <spawn+0x297>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c21:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c28:	00 
  801c29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c30:	e8 d4 f2 ff ff       	call   800f09 <sys_page_unmap>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	85 c0                	test   %eax,%eax
  801c39:	79 1f                	jns    801c5a <spawn+0x2b6>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801c3b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c42:	00 
  801c43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4a:	e8 ba f2 ff ff       	call   800f09 <sys_page_unmap>
	return r;
  801c4f:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801c55:	e9 4c 03 00 00       	jmp    801fa6 <spawn+0x602>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c5a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c60:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801c67:	00 
  801c68:	0f 84 e2 01 00 00    	je     801e50 <spawn+0x4ac>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c6e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801c75:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c7b:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801c82:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801c85:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801c8b:	83 3a 01             	cmpl   $0x1,(%edx)
  801c8e:	0f 85 9b 01 00 00    	jne    801e2f <spawn+0x48b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c94:	8b 42 18             	mov    0x18(%edx),%eax
  801c97:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c9a:	83 f8 01             	cmp    $0x1,%eax
  801c9d:	19 c0                	sbb    %eax,%eax
  801c9f:	83 e0 fe             	and    $0xfffffffe,%eax
  801ca2:	83 c0 07             	add    $0x7,%eax
  801ca5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801cab:	8b 52 04             	mov    0x4(%edx),%edx
  801cae:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801cb4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cba:	8b 70 10             	mov    0x10(%eax),%esi
  801cbd:	8b 50 14             	mov    0x14(%eax),%edx
  801cc0:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801cc6:	8b 40 08             	mov    0x8(%eax),%eax
  801cc9:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ccf:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cd4:	74 16                	je     801cec <spawn+0x348>
		va -= i;
  801cd6:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  801cdc:	01 c2                	add    %eax,%edx
  801cde:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801ce4:	01 c6                	add    %eax,%esi
		fileoffset -= i;
  801ce6:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cec:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801cf3:	0f 84 36 01 00 00    	je     801e2f <spawn+0x48b>
  801cf9:	bf 00 00 00 00       	mov    $0x0,%edi
  801cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801d03:	39 f7                	cmp    %esi,%edi
  801d05:	72 31                	jb     801d38 <spawn+0x394>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d07:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d0d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d11:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801d17:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d1b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 23 f1 ff ff       	call   800e4c <sys_page_alloc>
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 89 ea 00 00 00    	jns    801e1b <spawn+0x477>
  801d31:	89 c6                	mov    %eax,%esi
  801d33:	e9 3e 02 00 00       	jmp    801f76 <spawn+0x5d2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d38:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d3f:	00 
  801d40:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d47:	00 
  801d48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4f:	e8 f8 f0 ff ff       	call   800e4c <sys_page_alloc>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	0f 88 10 02 00 00    	js     801f6c <spawn+0x5c8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d5c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801d62:	01 d8                	add    %ebx,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d68:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 a3 f8 ff ff       	call   801619 <seek>
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 f2 01 00 00    	js     801f70 <spawn+0x5cc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d7e:	89 f0                	mov    %esi,%eax
  801d80:	29 f8                	sub    %edi,%eax
  801d82:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d87:	ba 00 10 00 00       	mov    $0x1000,%edx
  801d8c:	0f 47 c2             	cmova  %edx,%eax
  801d8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d93:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d9a:	00 
  801d9b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801da1:	89 04 24             	mov    %eax,(%esp)
  801da4:	e8 95 f7 ff ff       	call   80153e <readn>
  801da9:	85 c0                	test   %eax,%eax
  801dab:	0f 88 c3 01 00 00    	js     801f74 <spawn+0x5d0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801db1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801db7:	89 54 24 10          	mov    %edx,0x10(%esp)
  801dbb:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801dc1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801dc5:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcf:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801dd6:	00 
  801dd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dde:	e8 c8 f0 ff ff       	call   800eab <sys_page_map>
  801de3:	85 c0                	test   %eax,%eax
  801de5:	79 20                	jns    801e07 <spawn+0x463>
				panic("spawn: sys_page_map data: %e", r);
  801de7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801deb:	c7 44 24 08 b1 2e 80 	movl   $0x802eb1,0x8(%esp)
  801df2:	00 
  801df3:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801dfa:	00 
  801dfb:	c7 04 24 a5 2e 80 00 	movl   $0x802ea5,(%esp)
  801e02:	e8 f9 e2 ff ff       	call   800100 <_panic>
			sys_page_unmap(0, UTEMP);
  801e07:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e0e:	00 
  801e0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e16:	e8 ee f0 ff ff       	call   800f09 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e1b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e21:	89 df                	mov    %ebx,%edi
  801e23:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801e29:	0f 82 d4 fe ff ff    	jb     801d03 <spawn+0x35f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e2f:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801e36:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801e3d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e44:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801e4a:	0f 8f 35 fe ff ff    	jg     801c85 <spawn+0x2e1>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801e50:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e56:	89 04 24             	mov    %eax,(%esp)
  801e59:	e8 df f4 ff ff       	call   80133d <close>
  801e5e:	bf 00 00 00 00       	mov    $0x0,%edi
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  801e63:	be 00 00 00 00       	mov    $0x0,%esi
  801e68:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(i * PGSIZE)] & PTE_P) && (uvpt[i] & PTE_P) && (uvpt[i] & PTE_SHARE)) {
  801e6e:	89 f8                	mov    %edi,%eax
  801e70:	c1 e8 16             	shr    $0x16,%eax
  801e73:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e7a:	a8 01                	test   $0x1,%al
  801e7c:	74 63                	je     801ee1 <spawn+0x53d>
  801e7e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801e85:	a8 01                	test   $0x1,%al
  801e87:	74 58                	je     801ee1 <spawn+0x53d>
  801e89:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801e90:	f6 c4 04             	test   $0x4,%ah
  801e93:	74 4c                	je     801ee1 <spawn+0x53d>
			res = sys_page_map(0, (void *)(i * PGSIZE), child, (void *)(i * PGSIZE), uvpt[i] & PTE_SYSCALL);
  801e95:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801e9c:	25 07 0e 00 00       	and    $0xe07,%eax
  801ea1:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ea5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ea9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ead:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb8:	e8 ee ef ff ff       	call   800eab <sys_page_map>
			if (res < 0)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	79 20                	jns    801ee1 <spawn+0x53d>
				panic("sys_page_map failed in copy_shared_pages %e\n", res);
  801ec1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ec5:	c7 44 24 08 28 2f 80 	movl   $0x802f28,0x8(%esp)
  801ecc:	00 
  801ecd:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  801ed4:	00 
  801ed5:	c7 04 24 a5 2e 80 00 	movl   $0x802ea5,(%esp)
  801edc:	e8 1f e2 ff ff       	call   800100 <_panic>
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  801ee1:	83 c6 01             	add    $0x1,%esi
  801ee4:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801eea:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801ef0:	0f 85 78 ff ff ff    	jne    801e6e <spawn+0x4ca>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ef6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f00:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f06:	89 04 24             	mov    %eax,(%esp)
  801f09:	e8 b7 f0 ff ff       	call   800fc5 <sys_env_set_trapframe>
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	79 20                	jns    801f32 <spawn+0x58e>
		panic("sys_env_set_trapframe: %e", r);
  801f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f16:	c7 44 24 08 ce 2e 80 	movl   $0x802ece,0x8(%esp)
  801f1d:	00 
  801f1e:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801f25:	00 
  801f26:	c7 04 24 a5 2e 80 00 	movl   $0x802ea5,(%esp)
  801f2d:	e8 ce e1 ff ff       	call   800100 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f32:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801f39:	00 
  801f3a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f40:	89 04 24             	mov    %eax,(%esp)
  801f43:	e8 1f f0 ff ff       	call   800f67 <sys_env_set_status>
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	79 5a                	jns    801fa6 <spawn+0x602>
		panic("sys_env_set_status: %e", r);
  801f4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f50:	c7 44 24 08 e8 2e 80 	movl   $0x802ee8,0x8(%esp)
  801f57:	00 
  801f58:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801f5f:	00 
  801f60:	c7 04 24 a5 2e 80 00 	movl   $0x802ea5,(%esp)
  801f67:	e8 94 e1 ff ff       	call   800100 <_panic>
  801f6c:	89 c6                	mov    %eax,%esi
  801f6e:	eb 06                	jmp    801f76 <spawn+0x5d2>
  801f70:	89 c6                	mov    %eax,%esi
  801f72:	eb 02                	jmp    801f76 <spawn+0x5d2>
  801f74:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801f76:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f7c:	89 04 24             	mov    %eax,(%esp)
  801f7f:	e8 0b ee ff ff       	call   800d8f <sys_env_destroy>
	close(fd);
  801f84:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f8a:	89 04 24             	mov    %eax,(%esp)
  801f8d:	e8 ab f3 ff ff       	call   80133d <close>
	return r;
  801f92:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801f98:	eb 0c                	jmp    801fa6 <spawn+0x602>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801f9a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801fa0:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801fa6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801fac:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801fb2:	5b                   	pop    %ebx
  801fb3:	5e                   	pop    %esi
  801fb4:	5f                   	pop    %edi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801fb7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801fbc:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801fc2:	eb e2                	jmp    801fa6 <spawn+0x602>

00801fc4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	83 ec 10             	sub    $0x10,%esp
  801fcc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fcf:	8d 45 14             	lea    0x14(%ebp),%eax
  801fd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fd6:	74 66                	je     80203e <spawnl+0x7a>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801fd8:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801fdd:	83 c1 01             	add    $0x1,%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fe0:	89 c2                	mov    %eax,%edx
  801fe2:	83 c0 04             	add    $0x4,%eax
  801fe5:	83 3a 00             	cmpl   $0x0,(%edx)
  801fe8:	75 f3                	jne    801fdd <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801fea:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801ff1:	83 e0 f0             	and    $0xfffffff0,%eax
  801ff4:	29 c4                	sub    %eax,%esp
  801ff6:	8d 44 24 17          	lea    0x17(%esp),%eax
  801ffa:	83 e0 f0             	and    $0xfffffff0,%eax
  801ffd:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801fff:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802001:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802008:	00 

	va_start(vl, arg0);
  802009:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80200c:	89 ce                	mov    %ecx,%esi
  80200e:	85 c9                	test   %ecx,%ecx
  802010:	74 16                	je     802028 <spawnl+0x64>
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802017:	83 c0 01             	add    $0x1,%eax
  80201a:	89 d1                	mov    %edx,%ecx
  80201c:	83 c2 04             	add    $0x4,%edx
  80201f:	8b 09                	mov    (%ecx),%ecx
  802021:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802024:	39 f0                	cmp    %esi,%eax
  802026:	75 ef                	jne    802017 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802028:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	89 04 24             	mov    %eax,(%esp)
  802032:	e8 6d f9 ff ff       	call   8019a4 <spawn>
}
  802037:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80203e:	83 ec 20             	sub    $0x20,%esp
  802041:	8d 44 24 17          	lea    0x17(%esp),%eax
  802045:	83 e0 f0             	and    $0xfffffff0,%eax
  802048:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80204a:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80204c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802053:	eb d3                	jmp    802028 <spawnl+0x64>
	...

00802060 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 18             	sub    $0x18,%esp
  802066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80206c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80206f:	8b 45 08             	mov    0x8(%ebp),%eax
  802072:	89 04 24             	mov    %eax,(%esp)
  802075:	e8 e6 f0 ff ff       	call   801160 <fd2data>
  80207a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80207c:	c7 44 24 04 58 2f 80 	movl   $0x802f58,0x4(%esp)
  802083:	00 
  802084:	89 34 24             	mov    %esi,(%esp)
  802087:	e8 bf e8 ff ff       	call   80094b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80208c:	8b 43 04             	mov    0x4(%ebx),%eax
  80208f:	2b 03                	sub    (%ebx),%eax
  802091:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802097:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80209e:	00 00 00 
	stat->st_dev = &devpipe;
  8020a1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  8020a8:	30 80 00 
	return 0;
}
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8020b3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8020b6:	89 ec                	mov    %ebp,%esp
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    

008020ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 14             	sub    $0x14,%esp
  8020c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020cf:	e8 35 ee ff ff       	call   800f09 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020d4:	89 1c 24             	mov    %ebx,(%esp)
  8020d7:	e8 84 f0 ff ff       	call   801160 <fd2data>
  8020dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e7:	e8 1d ee ff ff       	call   800f09 <sys_page_unmap>
}
  8020ec:	83 c4 14             	add    $0x14,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    

008020f2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 2c             	sub    $0x2c,%esp
  8020fb:	89 c7                	mov    %eax,%edi
  8020fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802100:	a1 04 40 80 00       	mov    0x804004,%eax
  802105:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802108:	89 3c 24             	mov    %edi,(%esp)
  80210b:	e8 fc 05 00 00       	call   80270c <pageref>
  802110:	89 c6                	mov    %eax,%esi
  802112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802115:	89 04 24             	mov    %eax,(%esp)
  802118:	e8 ef 05 00 00       	call   80270c <pageref>
  80211d:	39 c6                	cmp    %eax,%esi
  80211f:	0f 94 c0             	sete   %al
  802122:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802125:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80212b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80212e:	39 cb                	cmp    %ecx,%ebx
  802130:	75 08                	jne    80213a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802132:	83 c4 2c             	add    $0x2c,%esp
  802135:	5b                   	pop    %ebx
  802136:	5e                   	pop    %esi
  802137:	5f                   	pop    %edi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80213a:	83 f8 01             	cmp    $0x1,%eax
  80213d:	75 c1                	jne    802100 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80213f:	8b 52 58             	mov    0x58(%edx),%edx
  802142:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802146:	89 54 24 08          	mov    %edx,0x8(%esp)
  80214a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80214e:	c7 04 24 5f 2f 80 00 	movl   $0x802f5f,(%esp)
  802155:	e8 a1 e0 ff ff       	call   8001fb <cprintf>
  80215a:	eb a4                	jmp    802100 <_pipeisclosed+0xe>

0080215c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	57                   	push   %edi
  802160:	56                   	push   %esi
  802161:	53                   	push   %ebx
  802162:	83 ec 2c             	sub    $0x2c,%esp
  802165:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802168:	89 34 24             	mov    %esi,(%esp)
  80216b:	e8 f0 ef ff ff       	call   801160 <fd2data>
  802170:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802172:	bf 00 00 00 00       	mov    $0x0,%edi
  802177:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80217b:	75 50                	jne    8021cd <devpipe_write+0x71>
  80217d:	eb 5c                	jmp    8021db <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80217f:	89 da                	mov    %ebx,%edx
  802181:	89 f0                	mov    %esi,%eax
  802183:	e8 6a ff ff ff       	call   8020f2 <_pipeisclosed>
  802188:	85 c0                	test   %eax,%eax
  80218a:	75 53                	jne    8021df <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80218c:	e8 8b ec ff ff       	call   800e1c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802191:	8b 43 04             	mov    0x4(%ebx),%eax
  802194:	8b 13                	mov    (%ebx),%edx
  802196:	83 c2 20             	add    $0x20,%edx
  802199:	39 d0                	cmp    %edx,%eax
  80219b:	73 e2                	jae    80217f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80219d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021a0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  8021a4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  8021a7:	89 c2                	mov    %eax,%edx
  8021a9:	c1 fa 1f             	sar    $0x1f,%edx
  8021ac:	c1 ea 1b             	shr    $0x1b,%edx
  8021af:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8021b2:	83 e1 1f             	and    $0x1f,%ecx
  8021b5:	29 d1                	sub    %edx,%ecx
  8021b7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8021bb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8021bf:	83 c0 01             	add    $0x1,%eax
  8021c2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021c5:	83 c7 01             	add    $0x1,%edi
  8021c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021cb:	74 0e                	je     8021db <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8021d0:	8b 13                	mov    (%ebx),%edx
  8021d2:	83 c2 20             	add    $0x20,%edx
  8021d5:	39 d0                	cmp    %edx,%eax
  8021d7:	73 a6                	jae    80217f <devpipe_write+0x23>
  8021d9:	eb c2                	jmp    80219d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021db:	89 f8                	mov    %edi,%eax
  8021dd:	eb 05                	jmp    8021e4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021df:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021e4:	83 c4 2c             	add    $0x2c,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    

008021ec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	83 ec 28             	sub    $0x28,%esp
  8021f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8021f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8021f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8021fb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021fe:	89 3c 24             	mov    %edi,(%esp)
  802201:	e8 5a ef ff ff       	call   801160 <fd2data>
  802206:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802208:	be 00 00 00 00       	mov    $0x0,%esi
  80220d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802211:	75 47                	jne    80225a <devpipe_read+0x6e>
  802213:	eb 52                	jmp    802267 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802215:	89 f0                	mov    %esi,%eax
  802217:	eb 5e                	jmp    802277 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802219:	89 da                	mov    %ebx,%edx
  80221b:	89 f8                	mov    %edi,%eax
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	e8 cd fe ff ff       	call   8020f2 <_pipeisclosed>
  802225:	85 c0                	test   %eax,%eax
  802227:	75 49                	jne    802272 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802229:	e8 ee eb ff ff       	call   800e1c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80222e:	8b 03                	mov    (%ebx),%eax
  802230:	3b 43 04             	cmp    0x4(%ebx),%eax
  802233:	74 e4                	je     802219 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802235:	89 c2                	mov    %eax,%edx
  802237:	c1 fa 1f             	sar    $0x1f,%edx
  80223a:	c1 ea 1b             	shr    $0x1b,%edx
  80223d:	01 d0                	add    %edx,%eax
  80223f:	83 e0 1f             	and    $0x1f,%eax
  802242:	29 d0                	sub    %edx,%eax
  802244:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802249:	8b 55 0c             	mov    0xc(%ebp),%edx
  80224c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80224f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802252:	83 c6 01             	add    $0x1,%esi
  802255:	3b 75 10             	cmp    0x10(%ebp),%esi
  802258:	74 0d                	je     802267 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80225a:	8b 03                	mov    (%ebx),%eax
  80225c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80225f:	75 d4                	jne    802235 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802261:	85 f6                	test   %esi,%esi
  802263:	75 b0                	jne    802215 <devpipe_read+0x29>
  802265:	eb b2                	jmp    802219 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802267:	89 f0                	mov    %esi,%eax
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	eb 05                	jmp    802277 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802272:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802277:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80227a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80227d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802280:	89 ec                	mov    %ebp,%esp
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    

00802284 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	83 ec 48             	sub    $0x48,%esp
  80228a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80228d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802290:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802293:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802296:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802299:	89 04 24             	mov    %eax,(%esp)
  80229c:	e8 da ee ff ff       	call   80117b <fd_alloc>
  8022a1:	89 c3                	mov    %eax,%ebx
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	0f 88 45 01 00 00    	js     8023f0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022b2:	00 
  8022b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c1:	e8 86 eb ff ff       	call   800e4c <sys_page_alloc>
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	0f 88 20 01 00 00    	js     8023f0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8022d3:	89 04 24             	mov    %eax,(%esp)
  8022d6:	e8 a0 ee ff ff       	call   80117b <fd_alloc>
  8022db:	89 c3                	mov    %eax,%ebx
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	0f 88 f8 00 00 00    	js     8023dd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022ec:	00 
  8022ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fb:	e8 4c eb ff ff       	call   800e4c <sys_page_alloc>
  802300:	89 c3                	mov    %eax,%ebx
  802302:	85 c0                	test   %eax,%eax
  802304:	0f 88 d3 00 00 00    	js     8023dd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80230a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80230d:	89 04 24             	mov    %eax,(%esp)
  802310:	e8 4b ee ff ff       	call   801160 <fd2data>
  802315:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802317:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80231e:	00 
  80231f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802323:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232a:	e8 1d eb ff ff       	call   800e4c <sys_page_alloc>
  80232f:	89 c3                	mov    %eax,%ebx
  802331:	85 c0                	test   %eax,%eax
  802333:	0f 88 91 00 00 00    	js     8023ca <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802339:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80233c:	89 04 24             	mov    %eax,(%esp)
  80233f:	e8 1c ee ff ff       	call   801160 <fd2data>
  802344:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80234b:	00 
  80234c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802350:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802357:	00 
  802358:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802363:	e8 43 eb ff ff       	call   800eab <sys_page_map>
  802368:	89 c3                	mov    %eax,%ebx
  80236a:	85 c0                	test   %eax,%eax
  80236c:	78 4c                	js     8023ba <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80236e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802377:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80237c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802383:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802389:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80238c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80238e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802391:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80239b:	89 04 24             	mov    %eax,(%esp)
  80239e:	e8 ad ed ff ff       	call   801150 <fd2num>
  8023a3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8023a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023a8:	89 04 24             	mov    %eax,(%esp)
  8023ab:	e8 a0 ed ff ff       	call   801150 <fd2num>
  8023b0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8023b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023b8:	eb 36                	jmp    8023f0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8023ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c5:	e8 3f eb ff ff       	call   800f09 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8023ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023d8:	e8 2c eb ff ff       	call   800f09 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8023dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023eb:	e8 19 eb ff ff       	call   800f09 <sys_page_unmap>
    err:
	return r;
}
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8023f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8023f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8023fb:	89 ec                	mov    %ebp,%esp
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240c:	8b 45 08             	mov    0x8(%ebp),%eax
  80240f:	89 04 24             	mov    %eax,(%esp)
  802412:	e8 d7 ed ff ff       	call   8011ee <fd_lookup>
  802417:	85 c0                	test   %eax,%eax
  802419:	78 15                	js     802430 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80241b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241e:	89 04 24             	mov    %eax,(%esp)
  802421:	e8 3a ed ff ff       	call   801160 <fd2data>
	return _pipeisclosed(fd, p);
  802426:	89 c2                	mov    %eax,%edx
  802428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242b:	e8 c2 fc ff ff       	call   8020f2 <_pipeisclosed>
}
  802430:	c9                   	leave  
  802431:	c3                   	ret    
	...

00802440 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802443:	b8 00 00 00 00       	mov    $0x0,%eax
  802448:	5d                   	pop    %ebp
  802449:	c3                   	ret    

0080244a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80244a:	55                   	push   %ebp
  80244b:	89 e5                	mov    %esp,%ebp
  80244d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802450:	c7 44 24 04 77 2f 80 	movl   $0x802f77,0x4(%esp)
  802457:	00 
  802458:	8b 45 0c             	mov    0xc(%ebp),%eax
  80245b:	89 04 24             	mov    %eax,(%esp)
  80245e:	e8 e8 e4 ff ff       	call   80094b <strcpy>
	return 0;
}
  802463:	b8 00 00 00 00       	mov    $0x0,%eax
  802468:	c9                   	leave  
  802469:	c3                   	ret    

0080246a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80246a:	55                   	push   %ebp
  80246b:	89 e5                	mov    %esp,%ebp
  80246d:	57                   	push   %edi
  80246e:	56                   	push   %esi
  80246f:	53                   	push   %ebx
  802470:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802476:	be 00 00 00 00       	mov    $0x0,%esi
  80247b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80247f:	74 43                	je     8024c4 <devcons_write+0x5a>
  802481:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802486:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80248c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80248f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802491:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802494:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802499:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80249c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024a0:	03 45 0c             	add    0xc(%ebp),%eax
  8024a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a7:	89 3c 24             	mov    %edi,(%esp)
  8024aa:	e8 8d e6 ff ff       	call   800b3c <memmove>
		sys_cputs(buf, m);
  8024af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024b3:	89 3c 24             	mov    %edi,(%esp)
  8024b6:	e8 75 e8 ff ff       	call   800d30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024bb:	01 de                	add    %ebx,%esi
  8024bd:	89 f0                	mov    %esi,%eax
  8024bf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024c2:	72 c8                	jb     80248c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024c4:	89 f0                	mov    %esi,%eax
  8024c6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8024cc:	5b                   	pop    %ebx
  8024cd:	5e                   	pop    %esi
  8024ce:	5f                   	pop    %edi
  8024cf:	5d                   	pop    %ebp
  8024d0:	c3                   	ret    

008024d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8024d7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8024dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024e0:	75 07                	jne    8024e9 <devcons_read+0x18>
  8024e2:	eb 31                	jmp    802515 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024e4:	e8 33 e9 ff ff       	call   800e1c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	e8 6a e8 ff ff       	call   800d5f <sys_cgetc>
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	74 eb                	je     8024e4 <devcons_read+0x13>
  8024f9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	78 16                	js     802515 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024ff:	83 f8 04             	cmp    $0x4,%eax
  802502:	74 0c                	je     802510 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802504:	8b 45 0c             	mov    0xc(%ebp),%eax
  802507:	88 10                	mov    %dl,(%eax)
	return 1;
  802509:	b8 01 00 00 00       	mov    $0x1,%eax
  80250e:	eb 05                	jmp    802515 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802510:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802515:	c9                   	leave  
  802516:	c3                   	ret    

00802517 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80251d:	8b 45 08             	mov    0x8(%ebp),%eax
  802520:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802523:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80252a:	00 
  80252b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80252e:	89 04 24             	mov    %eax,(%esp)
  802531:	e8 fa e7 ff ff       	call   800d30 <sys_cputs>
}
  802536:	c9                   	leave  
  802537:	c3                   	ret    

00802538 <getchar>:

int
getchar(void)
{
  802538:	55                   	push   %ebp
  802539:	89 e5                	mov    %esp,%ebp
  80253b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80253e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802545:	00 
  802546:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80254d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802554:	e8 55 ef ff ff       	call   8014ae <read>
	if (r < 0)
  802559:	85 c0                	test   %eax,%eax
  80255b:	78 0f                	js     80256c <getchar+0x34>
		return r;
	if (r < 1)
  80255d:	85 c0                	test   %eax,%eax
  80255f:	7e 06                	jle    802567 <getchar+0x2f>
		return -E_EOF;
	return c;
  802561:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802565:	eb 05                	jmp    80256c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802567:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80256c:	c9                   	leave  
  80256d:	c3                   	ret    

0080256e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802574:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80257b:	8b 45 08             	mov    0x8(%ebp),%eax
  80257e:	89 04 24             	mov    %eax,(%esp)
  802581:	e8 68 ec ff ff       	call   8011ee <fd_lookup>
  802586:	85 c0                	test   %eax,%eax
  802588:	78 11                	js     80259b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80258a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80258d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802593:	39 10                	cmp    %edx,(%eax)
  802595:	0f 94 c0             	sete   %al
  802598:	0f b6 c0             	movzbl %al,%eax
}
  80259b:	c9                   	leave  
  80259c:	c3                   	ret    

0080259d <opencons>:

int
opencons(void)
{
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025a6:	89 04 24             	mov    %eax,(%esp)
  8025a9:	e8 cd eb ff ff       	call   80117b <fd_alloc>
  8025ae:	85 c0                	test   %eax,%eax
  8025b0:	78 3c                	js     8025ee <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025b9:	00 
  8025ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025c8:	e8 7f e8 ff ff       	call   800e4c <sys_page_alloc>
  8025cd:	85 c0                	test   %eax,%eax
  8025cf:	78 1d                	js     8025ee <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025d1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8025d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025da:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025df:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025e6:	89 04 24             	mov    %eax,(%esp)
  8025e9:	e8 62 eb ff ff       	call   801150 <fd2num>
}
  8025ee:	c9                   	leave  
  8025ef:	c3                   	ret    

008025f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	56                   	push   %esi
  8025f4:	53                   	push   %ebx
  8025f5:	83 ec 10             	sub    $0x10,%esp
  8025f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8025fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025fe:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802601:	85 db                	test   %ebx,%ebx
  802603:	74 06                	je     80260b <ipc_recv+0x1b>
  802605:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80260b:	85 f6                	test   %esi,%esi
  80260d:	74 06                	je     802615 <ipc_recv+0x25>
  80260f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802615:	85 c0                	test   %eax,%eax
  802617:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80261c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80261f:	89 04 24             	mov    %eax,(%esp)
  802622:	e8 8e ea ff ff       	call   8010b5 <sys_ipc_recv>
    if (ret) return ret;
  802627:	85 c0                	test   %eax,%eax
  802629:	75 24                	jne    80264f <ipc_recv+0x5f>
    if (from_env_store)
  80262b:	85 db                	test   %ebx,%ebx
  80262d:	74 0a                	je     802639 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80262f:	a1 04 40 80 00       	mov    0x804004,%eax
  802634:	8b 40 74             	mov    0x74(%eax),%eax
  802637:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802639:	85 f6                	test   %esi,%esi
  80263b:	74 0a                	je     802647 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80263d:	a1 04 40 80 00       	mov    0x804004,%eax
  802642:	8b 40 78             	mov    0x78(%eax),%eax
  802645:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802647:	a1 04 40 80 00       	mov    0x804004,%eax
  80264c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80264f:	83 c4 10             	add    $0x10,%esp
  802652:	5b                   	pop    %ebx
  802653:	5e                   	pop    %esi
  802654:	5d                   	pop    %ebp
  802655:	c3                   	ret    

00802656 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802656:	55                   	push   %ebp
  802657:	89 e5                	mov    %esp,%ebp
  802659:	57                   	push   %edi
  80265a:	56                   	push   %esi
  80265b:	53                   	push   %ebx
  80265c:	83 ec 1c             	sub    $0x1c,%esp
  80265f:	8b 75 08             	mov    0x8(%ebp),%esi
  802662:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802665:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802668:	85 db                	test   %ebx,%ebx
  80266a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80266f:	0f 44 d8             	cmove  %eax,%ebx
  802672:	eb 2a                	jmp    80269e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802674:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802677:	74 20                	je     802699 <ipc_send+0x43>
  802679:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80267d:	c7 44 24 08 83 2f 80 	movl   $0x802f83,0x8(%esp)
  802684:	00 
  802685:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80268c:	00 
  80268d:	c7 04 24 9a 2f 80 00 	movl   $0x802f9a,(%esp)
  802694:	e8 67 da ff ff       	call   800100 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802699:	e8 7e e7 ff ff       	call   800e1c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80269e:	8b 45 14             	mov    0x14(%ebp),%eax
  8026a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026ad:	89 34 24             	mov    %esi,(%esp)
  8026b0:	e8 cc e9 ff ff       	call   801081 <sys_ipc_try_send>
  8026b5:	85 c0                	test   %eax,%eax
  8026b7:	75 bb                	jne    802674 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8026b9:	83 c4 1c             	add    $0x1c,%esp
  8026bc:	5b                   	pop    %ebx
  8026bd:	5e                   	pop    %esi
  8026be:	5f                   	pop    %edi
  8026bf:	5d                   	pop    %ebp
  8026c0:	c3                   	ret    

008026c1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026c1:	55                   	push   %ebp
  8026c2:	89 e5                	mov    %esp,%ebp
  8026c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8026c7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8026cc:	39 c8                	cmp    %ecx,%eax
  8026ce:	74 19                	je     8026e9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026d0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8026d5:	89 c2                	mov    %eax,%edx
  8026d7:	c1 e2 07             	shl    $0x7,%edx
  8026da:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026e0:	8b 52 50             	mov    0x50(%edx),%edx
  8026e3:	39 ca                	cmp    %ecx,%edx
  8026e5:	75 14                	jne    8026fb <ipc_find_env+0x3a>
  8026e7:	eb 05                	jmp    8026ee <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026e9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8026ee:	c1 e0 07             	shl    $0x7,%eax
  8026f1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026f6:	8b 40 40             	mov    0x40(%eax),%eax
  8026f9:	eb 0e                	jmp    802709 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026fb:	83 c0 01             	add    $0x1,%eax
  8026fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802703:	75 d0                	jne    8026d5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802705:	66 b8 00 00          	mov    $0x0,%ax
}
  802709:	5d                   	pop    %ebp
  80270a:	c3                   	ret    
	...

0080270c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
  80270f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802712:	89 d0                	mov    %edx,%eax
  802714:	c1 e8 16             	shr    $0x16,%eax
  802717:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80271e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802723:	f6 c1 01             	test   $0x1,%cl
  802726:	74 1d                	je     802745 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802728:	c1 ea 0c             	shr    $0xc,%edx
  80272b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802732:	f6 c2 01             	test   $0x1,%dl
  802735:	74 0e                	je     802745 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802737:	c1 ea 0c             	shr    $0xc,%edx
  80273a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802741:	ef 
  802742:	0f b7 c0             	movzwl %ax,%eax
}
  802745:	5d                   	pop    %ebp
  802746:	c3                   	ret    
	...

00802750 <__udivdi3>:
  802750:	83 ec 1c             	sub    $0x1c,%esp
  802753:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802757:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80275b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80275f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802763:	89 74 24 10          	mov    %esi,0x10(%esp)
  802767:	8b 74 24 24          	mov    0x24(%esp),%esi
  80276b:	85 ff                	test   %edi,%edi
  80276d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802771:	89 44 24 08          	mov    %eax,0x8(%esp)
  802775:	89 cd                	mov    %ecx,%ebp
  802777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80277b:	75 33                	jne    8027b0 <__udivdi3+0x60>
  80277d:	39 f1                	cmp    %esi,%ecx
  80277f:	77 57                	ja     8027d8 <__udivdi3+0x88>
  802781:	85 c9                	test   %ecx,%ecx
  802783:	75 0b                	jne    802790 <__udivdi3+0x40>
  802785:	b8 01 00 00 00       	mov    $0x1,%eax
  80278a:	31 d2                	xor    %edx,%edx
  80278c:	f7 f1                	div    %ecx
  80278e:	89 c1                	mov    %eax,%ecx
  802790:	89 f0                	mov    %esi,%eax
  802792:	31 d2                	xor    %edx,%edx
  802794:	f7 f1                	div    %ecx
  802796:	89 c6                	mov    %eax,%esi
  802798:	8b 44 24 04          	mov    0x4(%esp),%eax
  80279c:	f7 f1                	div    %ecx
  80279e:	89 f2                	mov    %esi,%edx
  8027a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027ac:	83 c4 1c             	add    $0x1c,%esp
  8027af:	c3                   	ret    
  8027b0:	31 d2                	xor    %edx,%edx
  8027b2:	31 c0                	xor    %eax,%eax
  8027b4:	39 f7                	cmp    %esi,%edi
  8027b6:	77 e8                	ja     8027a0 <__udivdi3+0x50>
  8027b8:	0f bd cf             	bsr    %edi,%ecx
  8027bb:	83 f1 1f             	xor    $0x1f,%ecx
  8027be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027c2:	75 2c                	jne    8027f0 <__udivdi3+0xa0>
  8027c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8027c8:	76 04                	jbe    8027ce <__udivdi3+0x7e>
  8027ca:	39 f7                	cmp    %esi,%edi
  8027cc:	73 d2                	jae    8027a0 <__udivdi3+0x50>
  8027ce:	31 d2                	xor    %edx,%edx
  8027d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d5:	eb c9                	jmp    8027a0 <__udivdi3+0x50>
  8027d7:	90                   	nop
  8027d8:	89 f2                	mov    %esi,%edx
  8027da:	f7 f1                	div    %ecx
  8027dc:	31 d2                	xor    %edx,%edx
  8027de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027ea:	83 c4 1c             	add    $0x1c,%esp
  8027ed:	c3                   	ret    
  8027ee:	66 90                	xchg   %ax,%ax
  8027f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8027fa:	89 ea                	mov    %ebp,%edx
  8027fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  802800:	d3 e7                	shl    %cl,%edi
  802802:	89 c1                	mov    %eax,%ecx
  802804:	d3 ea                	shr    %cl,%edx
  802806:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80280b:	09 fa                	or     %edi,%edx
  80280d:	89 f7                	mov    %esi,%edi
  80280f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802813:	89 f2                	mov    %esi,%edx
  802815:	8b 74 24 08          	mov    0x8(%esp),%esi
  802819:	d3 e5                	shl    %cl,%ebp
  80281b:	89 c1                	mov    %eax,%ecx
  80281d:	d3 ef                	shr    %cl,%edi
  80281f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802824:	d3 e2                	shl    %cl,%edx
  802826:	89 c1                	mov    %eax,%ecx
  802828:	d3 ee                	shr    %cl,%esi
  80282a:	09 d6                	or     %edx,%esi
  80282c:	89 fa                	mov    %edi,%edx
  80282e:	89 f0                	mov    %esi,%eax
  802830:	f7 74 24 0c          	divl   0xc(%esp)
  802834:	89 d7                	mov    %edx,%edi
  802836:	89 c6                	mov    %eax,%esi
  802838:	f7 e5                	mul    %ebp
  80283a:	39 d7                	cmp    %edx,%edi
  80283c:	72 22                	jb     802860 <__udivdi3+0x110>
  80283e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802842:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802847:	d3 e5                	shl    %cl,%ebp
  802849:	39 c5                	cmp    %eax,%ebp
  80284b:	73 04                	jae    802851 <__udivdi3+0x101>
  80284d:	39 d7                	cmp    %edx,%edi
  80284f:	74 0f                	je     802860 <__udivdi3+0x110>
  802851:	89 f0                	mov    %esi,%eax
  802853:	31 d2                	xor    %edx,%edx
  802855:	e9 46 ff ff ff       	jmp    8027a0 <__udivdi3+0x50>
  80285a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802860:	8d 46 ff             	lea    -0x1(%esi),%eax
  802863:	31 d2                	xor    %edx,%edx
  802865:	8b 74 24 10          	mov    0x10(%esp),%esi
  802869:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80286d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802871:	83 c4 1c             	add    $0x1c,%esp
  802874:	c3                   	ret    
	...

00802880 <__umoddi3>:
  802880:	83 ec 1c             	sub    $0x1c,%esp
  802883:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802887:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80288b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80288f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802893:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802897:	8b 74 24 24          	mov    0x24(%esp),%esi
  80289b:	85 ed                	test   %ebp,%ebp
  80289d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8028a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028a5:	89 cf                	mov    %ecx,%edi
  8028a7:	89 04 24             	mov    %eax,(%esp)
  8028aa:	89 f2                	mov    %esi,%edx
  8028ac:	75 1a                	jne    8028c8 <__umoddi3+0x48>
  8028ae:	39 f1                	cmp    %esi,%ecx
  8028b0:	76 4e                	jbe    802900 <__umoddi3+0x80>
  8028b2:	f7 f1                	div    %ecx
  8028b4:	89 d0                	mov    %edx,%eax
  8028b6:	31 d2                	xor    %edx,%edx
  8028b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028c4:	83 c4 1c             	add    $0x1c,%esp
  8028c7:	c3                   	ret    
  8028c8:	39 f5                	cmp    %esi,%ebp
  8028ca:	77 54                	ja     802920 <__umoddi3+0xa0>
  8028cc:	0f bd c5             	bsr    %ebp,%eax
  8028cf:	83 f0 1f             	xor    $0x1f,%eax
  8028d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028d6:	75 60                	jne    802938 <__umoddi3+0xb8>
  8028d8:	3b 0c 24             	cmp    (%esp),%ecx
  8028db:	0f 87 07 01 00 00    	ja     8029e8 <__umoddi3+0x168>
  8028e1:	89 f2                	mov    %esi,%edx
  8028e3:	8b 34 24             	mov    (%esp),%esi
  8028e6:	29 ce                	sub    %ecx,%esi
  8028e8:	19 ea                	sbb    %ebp,%edx
  8028ea:	89 34 24             	mov    %esi,(%esp)
  8028ed:	8b 04 24             	mov    (%esp),%eax
  8028f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028fc:	83 c4 1c             	add    $0x1c,%esp
  8028ff:	c3                   	ret    
  802900:	85 c9                	test   %ecx,%ecx
  802902:	75 0b                	jne    80290f <__umoddi3+0x8f>
  802904:	b8 01 00 00 00       	mov    $0x1,%eax
  802909:	31 d2                	xor    %edx,%edx
  80290b:	f7 f1                	div    %ecx
  80290d:	89 c1                	mov    %eax,%ecx
  80290f:	89 f0                	mov    %esi,%eax
  802911:	31 d2                	xor    %edx,%edx
  802913:	f7 f1                	div    %ecx
  802915:	8b 04 24             	mov    (%esp),%eax
  802918:	f7 f1                	div    %ecx
  80291a:	eb 98                	jmp    8028b4 <__umoddi3+0x34>
  80291c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802920:	89 f2                	mov    %esi,%edx
  802922:	8b 74 24 10          	mov    0x10(%esp),%esi
  802926:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80292a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80292e:	83 c4 1c             	add    $0x1c,%esp
  802931:	c3                   	ret    
  802932:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802938:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80293d:	89 e8                	mov    %ebp,%eax
  80293f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802944:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802948:	89 fa                	mov    %edi,%edx
  80294a:	d3 e0                	shl    %cl,%eax
  80294c:	89 e9                	mov    %ebp,%ecx
  80294e:	d3 ea                	shr    %cl,%edx
  802950:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802955:	09 c2                	or     %eax,%edx
  802957:	8b 44 24 08          	mov    0x8(%esp),%eax
  80295b:	89 14 24             	mov    %edx,(%esp)
  80295e:	89 f2                	mov    %esi,%edx
  802960:	d3 e7                	shl    %cl,%edi
  802962:	89 e9                	mov    %ebp,%ecx
  802964:	d3 ea                	shr    %cl,%edx
  802966:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80296b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80296f:	d3 e6                	shl    %cl,%esi
  802971:	89 e9                	mov    %ebp,%ecx
  802973:	d3 e8                	shr    %cl,%eax
  802975:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80297a:	09 f0                	or     %esi,%eax
  80297c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802980:	f7 34 24             	divl   (%esp)
  802983:	d3 e6                	shl    %cl,%esi
  802985:	89 74 24 08          	mov    %esi,0x8(%esp)
  802989:	89 d6                	mov    %edx,%esi
  80298b:	f7 e7                	mul    %edi
  80298d:	39 d6                	cmp    %edx,%esi
  80298f:	89 c1                	mov    %eax,%ecx
  802991:	89 d7                	mov    %edx,%edi
  802993:	72 3f                	jb     8029d4 <__umoddi3+0x154>
  802995:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802999:	72 35                	jb     8029d0 <__umoddi3+0x150>
  80299b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80299f:	29 c8                	sub    %ecx,%eax
  8029a1:	19 fe                	sbb    %edi,%esi
  8029a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029a8:	89 f2                	mov    %esi,%edx
  8029aa:	d3 e8                	shr    %cl,%eax
  8029ac:	89 e9                	mov    %ebp,%ecx
  8029ae:	d3 e2                	shl    %cl,%edx
  8029b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029b5:	09 d0                	or     %edx,%eax
  8029b7:	89 f2                	mov    %esi,%edx
  8029b9:	d3 ea                	shr    %cl,%edx
  8029bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029c7:	83 c4 1c             	add    $0x1c,%esp
  8029ca:	c3                   	ret    
  8029cb:	90                   	nop
  8029cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029d0:	39 d6                	cmp    %edx,%esi
  8029d2:	75 c7                	jne    80299b <__umoddi3+0x11b>
  8029d4:	89 d7                	mov    %edx,%edi
  8029d6:	89 c1                	mov    %eax,%ecx
  8029d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8029dc:	1b 3c 24             	sbb    (%esp),%edi
  8029df:	eb ba                	jmp    80299b <__umoddi3+0x11b>
  8029e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029e8:	39 f5                	cmp    %esi,%ebp
  8029ea:	0f 82 f1 fe ff ff    	jb     8028e1 <__umoddi3+0x61>
  8029f0:	e9 f8 fe ff ff       	jmp    8028ed <__umoddi3+0x6d>
