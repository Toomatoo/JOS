
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 ff 00 00 00       	call   800130 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 2f 0e 00 00       	call   800e7c <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 2d 13 00 00       	call   801386 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 2e                	jmp    800095 <umain+0x55>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 29                	je     800095 <umain+0x55>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	89 f0                	mov    %esi,%eax
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  80007c:	8b 40 50             	mov    0x50(%eax),%eax
  80007f:	89 f2                	mov    %esi,%edx
  800081:	c1 e2 07             	shl    $0x7,%edx
  800084:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80008a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80008f:	85 c0                	test   %eax,%eax
  800091:	75 12                	jne    8000a5 <umain+0x65>
  800093:	eb 1e                	jmp    8000b3 <umain+0x73>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800095:	e8 12 0e 00 00       	call   800eac <sys_yield>
		return;
  80009a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8000a0:	e9 81 00 00 00       	jmp    800126 <umain+0xe6>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  8000a5:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a7:	8b 42 50             	mov    0x50(%edx),%eax
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	75 f7                	jne    8000a5 <umain+0x65>
  8000ae:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000b3:	e8 f4 0d 00 00       	call   800eac <sys_yield>
  8000b8:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000bd:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8000c3:	83 c2 01             	add    $0x1,%edx
  8000c6:	89 15 08 20 80 00    	mov    %edx,0x802008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000cc:	83 e8 01             	sub    $0x1,%eax
  8000cf:	75 ec                	jne    8000bd <umain+0x7d>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000d1:	83 eb 01             	sub    $0x1,%ebx
  8000d4:	75 dd                	jne    8000b3 <umain+0x73>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000d6:	a1 08 20 80 00       	mov    0x802008,%eax
  8000db:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000e0:	74 25                	je     800107 <umain+0xc7>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e2:	a1 08 20 80 00       	mov    0x802008,%eax
  8000e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000eb:	c7 44 24 08 80 19 80 	movl   $0x801980,0x8(%esp)
  8000f2:	00 
  8000f3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000fa:	00 
  8000fb:	c7 04 24 a8 19 80 00 	movl   $0x8019a8,(%esp)
  800102:	e8 8d 00 00 00       	call   800194 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800107:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010c:	8b 50 5c             	mov    0x5c(%eax),%edx
  80010f:	8b 40 48             	mov    0x48(%eax),%eax
  800112:	89 54 24 08          	mov    %edx,0x8(%esp)
  800116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011a:	c7 04 24 bb 19 80 00 	movl   $0x8019bb,(%esp)
  800121:	e8 69 01 00 00       	call   80028f <cprintf>

}
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    
  80012d:	00 00                	add    %al,(%eax)
	...

00800130 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 18             	sub    $0x18,%esp
  800136:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800139:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80013c:	8b 75 08             	mov    0x8(%ebp),%esi
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800142:	e8 35 0d 00 00       	call   800e7c <sys_getenvid>
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	c1 e0 07             	shl    $0x7,%eax
  80014f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800154:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	85 f6                	test   %esi,%esi
  80015b:	7e 07                	jle    800164 <libmain+0x34>
		binaryname = argv[0];
  80015d:	8b 03                	mov    (%ebx),%eax
  80015f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800168:	89 34 24             	mov    %esi,(%esp)
  80016b:	e8 d0 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800170:	e8 0b 00 00 00       	call   800180 <exit>
}
  800175:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800178:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80017b:	89 ec                	mov    %ebp,%esp
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    
	...

00800180 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800186:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018d:	e8 8d 0c 00 00       	call   800e1f <sys_env_destroy>
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80019c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a5:	e8 d2 0c 00 00       	call   800e7c <sys_getenvid>
  8001aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c0:	c7 04 24 e4 19 80 00 	movl   $0x8019e4,(%esp)
  8001c7:	e8 c3 00 00 00       	call   80028f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 53 00 00 00       	call   80022e <vcprintf>
	cprintf("\n");
  8001db:	c7 04 24 d7 19 80 00 	movl   $0x8019d7,(%esp)
  8001e2:	e8 a8 00 00 00       	call   80028f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x53>
	...

008001ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 14             	sub    $0x14,%esp
  8001f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f6:	8b 03                	mov    (%ebx),%eax
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ff:	83 c0 01             	add    $0x1,%eax
  800202:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800204:	3d ff 00 00 00       	cmp    $0xff,%eax
  800209:	75 19                	jne    800224 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800212:	00 
  800213:	8d 43 08             	lea    0x8(%ebx),%eax
  800216:	89 04 24             	mov    %eax,(%esp)
  800219:	e8 a2 0b 00 00       	call   800dc0 <sys_cputs>
		b->idx = 0;
  80021e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800224:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800228:	83 c4 14             	add    $0x14,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800237:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023e:	00 00 00 
	b.cnt = 0;
  800241:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800248:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	89 44 24 08          	mov    %eax,0x8(%esp)
  800259:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800263:	c7 04 24 ec 01 80 00 	movl   $0x8001ec,(%esp)
  80026a:	e8 97 01 00 00       	call   800406 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	e8 39 0b 00 00       	call   800dc0 <sys_cputs>

	return b.cnt;
}
  800287:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800295:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 87 ff ff ff       	call   80022e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    
  8002a9:	00 00                	add    %al,(%eax)
	...

008002ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 3c             	sub    $0x3c,%esp
  8002b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b8:	89 d7                	mov    %edx,%edi
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002d4:	72 11                	jb     8002e7 <printnum+0x3b>
  8002d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002dc:	76 09                	jbe    8002e7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002de:	83 eb 01             	sub    $0x1,%ebx
  8002e1:	85 db                	test   %ebx,%ebx
  8002e3:	7f 51                	jg     800336 <printnum+0x8a>
  8002e5:	eb 5e                	jmp    800345 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002eb:	83 eb 01             	sub    $0x1,%ebx
  8002ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002fd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800301:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800308:	00 
  800309:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800312:	89 44 24 04          	mov    %eax,0x4(%esp)
  800316:	e8 a5 13 00 00       	call   8016c0 <__udivdi3>
  80031b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032a:	89 fa                	mov    %edi,%edx
  80032c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032f:	e8 78 ff ff ff       	call   8002ac <printnum>
  800334:	eb 0f                	jmp    800345 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800336:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033a:	89 34 24             	mov    %esi,(%esp)
  80033d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800340:	83 eb 01             	sub    $0x1,%ebx
  800343:	75 f1                	jne    800336 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800345:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800349:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80034d:	8b 45 10             	mov    0x10(%ebp),%eax
  800350:	89 44 24 08          	mov    %eax,0x8(%esp)
  800354:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035b:	00 
  80035c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	e8 82 14 00 00       	call   8017f0 <__umoddi3>
  80036e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800372:	0f be 80 07 1a 80 00 	movsbl 0x801a07(%eax),%eax
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80037f:	83 c4 3c             	add    $0x3c,%esp
  800382:	5b                   	pop    %ebx
  800383:	5e                   	pop    %esi
  800384:	5f                   	pop    %edi
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038a:	83 fa 01             	cmp    $0x1,%edx
  80038d:	7e 0e                	jle    80039d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	8d 4a 08             	lea    0x8(%edx),%ecx
  800394:	89 08                	mov    %ecx,(%eax)
  800396:	8b 02                	mov    (%edx),%eax
  800398:	8b 52 04             	mov    0x4(%edx),%edx
  80039b:	eb 22                	jmp    8003bf <getuint+0x38>
	else if (lflag)
  80039d:	85 d2                	test   %edx,%edx
  80039f:	74 10                	je     8003b1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a6:	89 08                	mov    %ecx,(%eax)
  8003a8:	8b 02                	mov    (%edx),%eax
  8003aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003af:	eb 0e                	jmp    8003bf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b1:	8b 10                	mov    (%eax),%edx
  8003b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b6:	89 08                	mov    %ecx,(%eax)
  8003b8:	8b 02                	mov    (%edx),%eax
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cb:	8b 10                	mov    (%eax),%edx
  8003cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d0:	73 0a                	jae    8003dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d5:	88 0a                	mov    %cl,(%edx)
  8003d7:	83 c2 01             	add    $0x1,%edx
  8003da:	89 10                	mov    %edx,(%eax)
}
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	e8 02 00 00 00       	call   800406 <vprintfmt>
	va_end(ap);
}
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	57                   	push   %edi
  80040a:	56                   	push   %esi
  80040b:	53                   	push   %ebx
  80040c:	83 ec 5c             	sub    $0x5c,%esp
  80040f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800412:	8b 75 10             	mov    0x10(%ebp),%esi
  800415:	eb 12                	jmp    800429 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800417:	85 c0                	test   %eax,%eax
  800419:	0f 84 e4 04 00 00    	je     800903 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80041f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800423:	89 04 24             	mov    %eax,(%esp)
  800426:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800429:	0f b6 06             	movzbl (%esi),%eax
  80042c:	83 c6 01             	add    $0x1,%esi
  80042f:	83 f8 25             	cmp    $0x25,%eax
  800432:	75 e3                	jne    800417 <vprintfmt+0x11>
  800434:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800438:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80043f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800444:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80044b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800450:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800453:	eb 2b                	jmp    800480 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800458:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80045c:	eb 22                	jmp    800480 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800461:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800465:	eb 19                	jmp    800480 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80046a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800471:	eb 0d                	jmp    800480 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800473:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800476:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800479:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	0f b6 06             	movzbl (%esi),%eax
  800483:	0f b6 d0             	movzbl %al,%edx
  800486:	8d 7e 01             	lea    0x1(%esi),%edi
  800489:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048c:	83 e8 23             	sub    $0x23,%eax
  80048f:	3c 55                	cmp    $0x55,%al
  800491:	0f 87 46 04 00 00    	ja     8008dd <vprintfmt+0x4d7>
  800497:	0f b6 c0             	movzbl %al,%eax
  80049a:	ff 24 85 e0 1a 80 00 	jmp    *0x801ae0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a1:	83 ea 30             	sub    $0x30,%edx
  8004a4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004a7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004ab:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004b1:	83 fa 09             	cmp    $0x9,%edx
  8004b4:	77 4a                	ja     800500 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004bc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004bf:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c9:	83 fa 09             	cmp    $0x9,%edx
  8004cc:	76 eb                	jbe    8004b9 <vprintfmt+0xb3>
  8004ce:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004d1:	eb 2d                	jmp    800500 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e4:	eb 1a                	jmp    800500 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004e9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004ed:	79 91                	jns    800480 <vprintfmt+0x7a>
  8004ef:	e9 73 ff ff ff       	jmp    800467 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004fe:	eb 80                	jmp    800480 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800500:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800504:	0f 89 76 ff ff ff    	jns    800480 <vprintfmt+0x7a>
  80050a:	e9 64 ff ff ff       	jmp    800473 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800515:	e9 66 ff ff ff       	jmp    800480 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 04             	lea    0x4(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800532:	e9 f2 fe ff ff       	jmp    800429 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800537:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80053b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80053e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800542:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800545:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800549:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80054c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80054f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800553:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800556:	80 f9 09             	cmp    $0x9,%cl
  800559:	77 1d                	ja     800578 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80055b:	0f be c0             	movsbl %al,%eax
  80055e:	6b c0 64             	imul   $0x64,%eax,%eax
  800561:	0f be d2             	movsbl %dl,%edx
  800564:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800567:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80056e:	a3 04 20 80 00       	mov    %eax,0x802004
  800573:	e9 b1 fe ff ff       	jmp    800429 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800578:	c7 44 24 04 1f 1a 80 	movl   $0x801a1f,0x4(%esp)
  80057f:	00 
  800580:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	e8 10 05 00 00       	call   800a9b <strcmp>
  80058b:	85 c0                	test   %eax,%eax
  80058d:	75 0f                	jne    80059e <vprintfmt+0x198>
  80058f:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800596:	00 00 00 
  800599:	e9 8b fe ff ff       	jmp    800429 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80059e:	c7 44 24 04 23 1a 80 	movl   $0x801a23,0x4(%esp)
  8005a5:	00 
  8005a6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005a9:	89 14 24             	mov    %edx,(%esp)
  8005ac:	e8 ea 04 00 00       	call   800a9b <strcmp>
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	75 0f                	jne    8005c4 <vprintfmt+0x1be>
  8005b5:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005bc:	00 00 00 
  8005bf:	e9 65 fe ff ff       	jmp    800429 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005c4:	c7 44 24 04 27 1a 80 	movl   $0x801a27,0x4(%esp)
  8005cb:	00 
  8005cc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005cf:	89 0c 24             	mov    %ecx,(%esp)
  8005d2:	e8 c4 04 00 00       	call   800a9b <strcmp>
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	75 0f                	jne    8005ea <vprintfmt+0x1e4>
  8005db:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005e2:	00 00 00 
  8005e5:	e9 3f fe ff ff       	jmp    800429 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005ea:	c7 44 24 04 2b 1a 80 	movl   $0x801a2b,0x4(%esp)
  8005f1:	00 
  8005f2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005f5:	89 3c 24             	mov    %edi,(%esp)
  8005f8:	e8 9e 04 00 00       	call   800a9b <strcmp>
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	75 0f                	jne    800610 <vprintfmt+0x20a>
  800601:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800608:	00 00 00 
  80060b:	e9 19 fe ff ff       	jmp    800429 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800610:	c7 44 24 04 2f 1a 80 	movl   $0x801a2f,0x4(%esp)
  800617:	00 
  800618:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	e8 78 04 00 00       	call   800a9b <strcmp>
  800623:	85 c0                	test   %eax,%eax
  800625:	75 0f                	jne    800636 <vprintfmt+0x230>
  800627:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80062e:	00 00 00 
  800631:	e9 f3 fd ff ff       	jmp    800429 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800636:	c7 44 24 04 33 1a 80 	movl   $0x801a33,0x4(%esp)
  80063d:	00 
  80063e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800641:	89 14 24             	mov    %edx,(%esp)
  800644:	e8 52 04 00 00       	call   800a9b <strcmp>
  800649:	83 f8 01             	cmp    $0x1,%eax
  80064c:	19 c0                	sbb    %eax,%eax
  80064e:	f7 d0                	not    %eax
  800650:	83 c0 08             	add    $0x8,%eax
  800653:	a3 04 20 80 00       	mov    %eax,0x802004
  800658:	e9 cc fd ff ff       	jmp    800429 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
  800666:	8b 00                	mov    (%eax),%eax
  800668:	89 c2                	mov    %eax,%edx
  80066a:	c1 fa 1f             	sar    $0x1f,%edx
  80066d:	31 d0                	xor    %edx,%eax
  80066f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800671:	83 f8 08             	cmp    $0x8,%eax
  800674:	7f 0b                	jg     800681 <vprintfmt+0x27b>
  800676:	8b 14 85 40 1c 80 00 	mov    0x801c40(,%eax,4),%edx
  80067d:	85 d2                	test   %edx,%edx
  80067f:	75 23                	jne    8006a4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800681:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800685:	c7 44 24 08 37 1a 80 	movl   $0x801a37,0x8(%esp)
  80068c:	00 
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	8b 7d 08             	mov    0x8(%ebp),%edi
  800694:	89 3c 24             	mov    %edi,(%esp)
  800697:	e8 42 fd ff ff       	call   8003de <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069f:	e9 85 fd ff ff       	jmp    800429 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a8:	c7 44 24 08 40 1a 80 	movl   $0x801a40,0x8(%esp)
  8006af:	00 
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b7:	89 3c 24             	mov    %edi,(%esp)
  8006ba:	e8 1f fd ff ff       	call   8003de <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006c2:	e9 62 fd ff ff       	jmp    800429 <vprintfmt+0x23>
  8006c7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006cd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 04             	lea    0x4(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006db:	85 f6                	test   %esi,%esi
  8006dd:	b8 18 1a 80 00       	mov    $0x801a18,%eax
  8006e2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006e5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006e9:	7e 06                	jle    8006f1 <vprintfmt+0x2eb>
  8006eb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006ef:	75 13                	jne    800704 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f1:	0f be 06             	movsbl (%esi),%eax
  8006f4:	83 c6 01             	add    $0x1,%esi
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	0f 85 94 00 00 00    	jne    800793 <vprintfmt+0x38d>
  8006ff:	e9 81 00 00 00       	jmp    800785 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800704:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800708:	89 34 24             	mov    %esi,(%esp)
  80070b:	e8 9b 02 00 00       	call   8009ab <strnlen>
  800710:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800713:	29 c2                	sub    %eax,%edx
  800715:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e d5                	jle    8006f1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80071c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800720:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800723:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800726:	89 d6                	mov    %edx,%esi
  800728:	89 cf                	mov    %ecx,%edi
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	89 3c 24             	mov    %edi,(%esp)
  800731:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	83 ee 01             	sub    $0x1,%esi
  800737:	75 f1                	jne    80072a <vprintfmt+0x324>
  800739:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80073c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80073f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800742:	eb ad                	jmp    8006f1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800744:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800748:	74 1b                	je     800765 <vprintfmt+0x35f>
  80074a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80074d:	83 fa 5e             	cmp    $0x5e,%edx
  800750:	76 13                	jbe    800765 <vprintfmt+0x35f>
					putch('?', putdat);
  800752:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800760:	ff 55 08             	call   *0x8(%ebp)
  800763:	eb 0d                	jmp    800772 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800765:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800768:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800772:	83 eb 01             	sub    $0x1,%ebx
  800775:	0f be 06             	movsbl (%esi),%eax
  800778:	83 c6 01             	add    $0x1,%esi
  80077b:	85 c0                	test   %eax,%eax
  80077d:	75 1a                	jne    800799 <vprintfmt+0x393>
  80077f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800782:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800788:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80078c:	7f 1c                	jg     8007aa <vprintfmt+0x3a4>
  80078e:	e9 96 fc ff ff       	jmp    800429 <vprintfmt+0x23>
  800793:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800796:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800799:	85 ff                	test   %edi,%edi
  80079b:	78 a7                	js     800744 <vprintfmt+0x33e>
  80079d:	83 ef 01             	sub    $0x1,%edi
  8007a0:	79 a2                	jns    800744 <vprintfmt+0x33e>
  8007a2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007a5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007a8:	eb db                	jmp    800785 <vprintfmt+0x37f>
  8007aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ad:	89 de                	mov    %ebx,%esi
  8007af:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007bd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bf:	83 eb 01             	sub    $0x1,%ebx
  8007c2:	75 ee                	jne    8007b2 <vprintfmt+0x3ac>
  8007c4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007c9:	e9 5b fc ff ff       	jmp    800429 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ce:	83 f9 01             	cmp    $0x1,%ecx
  8007d1:	7e 10                	jle    8007e3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 08             	lea    0x8(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 30                	mov    (%eax),%esi
  8007de:	8b 78 04             	mov    0x4(%eax),%edi
  8007e1:	eb 26                	jmp    800809 <vprintfmt+0x403>
	else if (lflag)
  8007e3:	85 c9                	test   %ecx,%ecx
  8007e5:	74 12                	je     8007f9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8d 50 04             	lea    0x4(%eax),%edx
  8007ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f0:	8b 30                	mov    (%eax),%esi
  8007f2:	89 f7                	mov    %esi,%edi
  8007f4:	c1 ff 1f             	sar    $0x1f,%edi
  8007f7:	eb 10                	jmp    800809 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 30                	mov    (%eax),%esi
  800804:	89 f7                	mov    %esi,%edi
  800806:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800809:	85 ff                	test   %edi,%edi
  80080b:	78 0e                	js     80081b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800811:	be 0a 00 00 00       	mov    $0xa,%esi
  800816:	e9 84 00 00 00       	jmp    80089f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80081b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800826:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800829:	89 f0                	mov    %esi,%eax
  80082b:	89 fa                	mov    %edi,%edx
  80082d:	f7 d8                	neg    %eax
  80082f:	83 d2 00             	adc    $0x0,%edx
  800832:	f7 da                	neg    %edx
			}
			base = 10;
  800834:	be 0a 00 00 00       	mov    $0xa,%esi
  800839:	eb 64                	jmp    80089f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083b:	89 ca                	mov    %ecx,%edx
  80083d:	8d 45 14             	lea    0x14(%ebp),%eax
  800840:	e8 42 fb ff ff       	call   800387 <getuint>
			base = 10;
  800845:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80084a:	eb 53                	jmp    80089f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80084c:	89 ca                	mov    %ecx,%edx
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
  800851:	e8 31 fb ff ff       	call   800387 <getuint>
    			base = 8;
  800856:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80085b:	eb 42                	jmp    80089f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80085d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800861:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800868:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80086b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800876:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8d 50 04             	lea    0x4(%eax),%edx
  80087f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800882:	8b 00                	mov    (%eax),%eax
  800884:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800889:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80088e:	eb 0f                	jmp    80089f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800890:	89 ca                	mov    %ecx,%edx
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
  800895:	e8 ed fa ff ff       	call   800387 <getuint>
			base = 16;
  80089a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008a7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008aa:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008ae:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b9:	89 da                	mov    %ebx,%edx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	e8 e9 f9 ff ff       	call   8002ac <printnum>
			break;
  8008c3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008c6:	e9 5e fb ff ff       	jmp    800429 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cf:	89 14 24             	mov    %edx,(%esp)
  8008d2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d8:	e9 4c fb ff ff       	jmp    800429 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008eb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008ef:	0f 84 34 fb ff ff    	je     800429 <vprintfmt+0x23>
  8008f5:	83 ee 01             	sub    $0x1,%esi
  8008f8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008fc:	75 f7                	jne    8008f5 <vprintfmt+0x4ef>
  8008fe:	e9 26 fb ff ff       	jmp    800429 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800903:	83 c4 5c             	add    $0x5c,%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 28             	sub    $0x28,%esp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800917:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800921:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800928:	85 c0                	test   %eax,%eax
  80092a:	74 30                	je     80095c <vsnprintf+0x51>
  80092c:	85 d2                	test   %edx,%edx
  80092e:	7e 2c                	jle    80095c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800930:	8b 45 14             	mov    0x14(%ebp),%eax
  800933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800937:	8b 45 10             	mov    0x10(%ebp),%eax
  80093a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800941:	89 44 24 04          	mov    %eax,0x4(%esp)
  800945:	c7 04 24 c1 03 80 00 	movl   $0x8003c1,(%esp)
  80094c:	e8 b5 fa ff ff       	call   800406 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800951:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800954:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095a:	eb 05                	jmp    800961 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800969:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800970:	8b 45 10             	mov    0x10(%ebp),%eax
  800973:	89 44 24 08          	mov    %eax,0x8(%esp)
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	89 04 24             	mov    %eax,(%esp)
  800984:	e8 82 ff ff ff       	call   80090b <vsnprintf>
	va_end(ap);

	return rc;
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    
  80098b:	00 00                	add    %al,(%eax)
  80098d:	00 00                	add    %al,(%eax)
	...

00800990 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	80 3a 00             	cmpb   $0x0,(%edx)
  80099e:	74 09                	je     8009a9 <strlen+0x19>
		n++;
  8009a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a7:	75 f7                	jne    8009a0 <strlen+0x10>
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	85 c9                	test   %ecx,%ecx
  8009bc:	74 1a                	je     8009d8 <strnlen+0x2d>
  8009be:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009c1:	74 15                	je     8009d8 <strnlen+0x2d>
  8009c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ca:	39 ca                	cmp    %ecx,%edx
  8009cc:	74 0a                	je     8009d8 <strnlen+0x2d>
  8009ce:	83 c2 01             	add    $0x1,%edx
  8009d1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009d6:	75 f0                	jne    8009c8 <strnlen+0x1d>
		n++;
	return n;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f1:	83 c2 01             	add    $0x1,%edx
  8009f4:	84 c9                	test   %cl,%cl
  8009f6:	75 f2                	jne    8009ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a05:	89 1c 24             	mov    %ebx,(%esp)
  800a08:	e8 83 ff ff ff       	call   800990 <strlen>
	strcpy(dst + len, src);
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a10:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a14:	01 d8                	add    %ebx,%eax
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 bd ff ff ff       	call   8009db <strcpy>
	return dst;
}
  800a1e:	89 d8                	mov    %ebx,%eax
  800a20:	83 c4 08             	add    $0x8,%esp
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a34:	85 f6                	test   %esi,%esi
  800a36:	74 18                	je     800a50 <strncpy+0x2a>
  800a38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a3d:	0f b6 1a             	movzbl (%edx),%ebx
  800a40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a43:	80 3a 01             	cmpb   $0x1,(%edx)
  800a46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	39 f1                	cmp    %esi,%ecx
  800a4e:	75 ed                	jne    800a3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a60:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a63:	89 f8                	mov    %edi,%eax
  800a65:	85 f6                	test   %esi,%esi
  800a67:	74 2b                	je     800a94 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a69:	83 fe 01             	cmp    $0x1,%esi
  800a6c:	74 23                	je     800a91 <strlcpy+0x3d>
  800a6e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a71:	84 c9                	test   %cl,%cl
  800a73:	74 1c                	je     800a91 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a75:	83 ee 02             	sub    $0x2,%esi
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7d:	88 08                	mov    %cl,(%eax)
  800a7f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a82:	39 f2                	cmp    %esi,%edx
  800a84:	74 0b                	je     800a91 <strlcpy+0x3d>
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a8d:	84 c9                	test   %cl,%cl
  800a8f:	75 ec                	jne    800a7d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a94:	29 f8                	sub    %edi,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa4:	0f b6 01             	movzbl (%ecx),%eax
  800aa7:	84 c0                	test   %al,%al
  800aa9:	74 16                	je     800ac1 <strcmp+0x26>
  800aab:	3a 02                	cmp    (%edx),%al
  800aad:	75 12                	jne    800ac1 <strcmp+0x26>
		p++, q++;
  800aaf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ab6:	84 c0                	test   %al,%al
  800ab8:	74 07                	je     800ac1 <strcmp+0x26>
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	3a 02                	cmp    (%edx),%al
  800abf:	74 ee                	je     800aaf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac1:	0f b6 c0             	movzbl %al,%eax
  800ac4:	0f b6 12             	movzbl (%edx),%edx
  800ac7:	29 d0                	sub    %edx,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800add:	85 d2                	test   %edx,%edx
  800adf:	74 28                	je     800b09 <strncmp+0x3e>
  800ae1:	0f b6 01             	movzbl (%ecx),%eax
  800ae4:	84 c0                	test   %al,%al
  800ae6:	74 24                	je     800b0c <strncmp+0x41>
  800ae8:	3a 03                	cmp    (%ebx),%al
  800aea:	75 20                	jne    800b0c <strncmp+0x41>
  800aec:	83 ea 01             	sub    $0x1,%edx
  800aef:	74 13                	je     800b04 <strncmp+0x39>
		n--, p++, q++;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af7:	0f b6 01             	movzbl (%ecx),%eax
  800afa:	84 c0                	test   %al,%al
  800afc:	74 0e                	je     800b0c <strncmp+0x41>
  800afe:	3a 03                	cmp    (%ebx),%al
  800b00:	74 ea                	je     800aec <strncmp+0x21>
  800b02:	eb 08                	jmp    800b0c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0c:	0f b6 01             	movzbl (%ecx),%eax
  800b0f:	0f b6 13             	movzbl (%ebx),%edx
  800b12:	29 d0                	sub    %edx,%eax
  800b14:	eb f3                	jmp    800b09 <strncmp+0x3e>

00800b16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b20:	0f b6 10             	movzbl (%eax),%edx
  800b23:	84 d2                	test   %dl,%dl
  800b25:	74 1c                	je     800b43 <strchr+0x2d>
		if (*s == c)
  800b27:	38 ca                	cmp    %cl,%dl
  800b29:	75 09                	jne    800b34 <strchr+0x1e>
  800b2b:	eb 1b                	jmp    800b48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b2d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b30:	38 ca                	cmp    %cl,%dl
  800b32:	74 14                	je     800b48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b34:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b38:	84 d2                	test   %dl,%dl
  800b3a:	75 f1                	jne    800b2d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	eb 05                	jmp    800b48 <strchr+0x32>
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b54:	0f b6 10             	movzbl (%eax),%edx
  800b57:	84 d2                	test   %dl,%dl
  800b59:	74 14                	je     800b6f <strfind+0x25>
		if (*s == c)
  800b5b:	38 ca                	cmp    %cl,%dl
  800b5d:	75 06                	jne    800b65 <strfind+0x1b>
  800b5f:	eb 0e                	jmp    800b6f <strfind+0x25>
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 0a                	je     800b6f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b65:	83 c0 01             	add    $0x1,%eax
  800b68:	0f b6 10             	movzbl (%eax),%edx
  800b6b:	84 d2                	test   %dl,%dl
  800b6d:	75 f2                	jne    800b61 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b89:	85 c9                	test   %ecx,%ecx
  800b8b:	74 30                	je     800bbd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b93:	75 25                	jne    800bba <memset+0x49>
  800b95:	f6 c1 03             	test   $0x3,%cl
  800b98:	75 20                	jne    800bba <memset+0x49>
		c &= 0xFF;
  800b9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	c1 e3 08             	shl    $0x8,%ebx
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	c1 e6 18             	shl    $0x18,%esi
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	c1 e0 10             	shl    $0x10,%eax
  800bac:	09 f0                	or     %esi,%eax
  800bae:	09 d0                	or     %edx,%eax
  800bb0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bb2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bb5:	fc                   	cld    
  800bb6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb8:	eb 03                	jmp    800bbd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bba:	fc                   	cld    
  800bbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbd:	89 f8                	mov    %edi,%eax
  800bbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc8:	89 ec                	mov    %ebp,%esp
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 08             	sub    $0x8,%esp
  800bd2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be1:	39 c6                	cmp    %eax,%esi
  800be3:	73 36                	jae    800c1b <memmove+0x4f>
  800be5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be8:	39 d0                	cmp    %edx,%eax
  800bea:	73 2f                	jae    800c1b <memmove+0x4f>
		s += n;
		d += n;
  800bec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bef:	f6 c2 03             	test   $0x3,%dl
  800bf2:	75 1b                	jne    800c0f <memmove+0x43>
  800bf4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfa:	75 13                	jne    800c0f <memmove+0x43>
  800bfc:	f6 c1 03             	test   $0x3,%cl
  800bff:	75 0e                	jne    800c0f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c01:	83 ef 04             	sub    $0x4,%edi
  800c04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c0a:	fd                   	std    
  800c0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0d:	eb 09                	jmp    800c18 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c0f:	83 ef 01             	sub    $0x1,%edi
  800c12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c15:	fd                   	std    
  800c16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c18:	fc                   	cld    
  800c19:	eb 20                	jmp    800c3b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c21:	75 13                	jne    800c36 <memmove+0x6a>
  800c23:	a8 03                	test   $0x3,%al
  800c25:	75 0f                	jne    800c36 <memmove+0x6a>
  800c27:	f6 c1 03             	test   $0x3,%cl
  800c2a:	75 0a                	jne    800c36 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c2f:	89 c7                	mov    %eax,%edi
  800c31:	fc                   	cld    
  800c32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c34:	eb 05                	jmp    800c3b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	fc                   	cld    
  800c39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c41:	89 ec                	mov    %ebp,%esp
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	89 04 24             	mov    %eax,(%esp)
  800c5f:	e8 68 ff ff ff       	call   800bcc <memmove>
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c72:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	85 ff                	test   %edi,%edi
  800c7c:	74 37                	je     800cb5 <memcmp+0x4f>
		if (*s1 != *s2)
  800c7e:	0f b6 03             	movzbl (%ebx),%eax
  800c81:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c84:	83 ef 01             	sub    $0x1,%edi
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c8c:	38 c8                	cmp    %cl,%al
  800c8e:	74 1c                	je     800cac <memcmp+0x46>
  800c90:	eb 10                	jmp    800ca2 <memcmp+0x3c>
  800c92:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c97:	83 c2 01             	add    $0x1,%edx
  800c9a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c9e:	38 c8                	cmp    %cl,%al
  800ca0:	74 0a                	je     800cac <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800ca2:	0f b6 c0             	movzbl %al,%eax
  800ca5:	0f b6 c9             	movzbl %cl,%ecx
  800ca8:	29 c8                	sub    %ecx,%eax
  800caa:	eb 09                	jmp    800cb5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cac:	39 fa                	cmp    %edi,%edx
  800cae:	75 e2                	jne    800c92 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cc0:	89 c2                	mov    %eax,%edx
  800cc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cc5:	39 d0                	cmp    %edx,%eax
  800cc7:	73 19                	jae    800ce2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ccd:	38 08                	cmp    %cl,(%eax)
  800ccf:	75 06                	jne    800cd7 <memfind+0x1d>
  800cd1:	eb 0f                	jmp    800ce2 <memfind+0x28>
  800cd3:	38 08                	cmp    %cl,(%eax)
  800cd5:	74 0b                	je     800ce2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd7:	83 c0 01             	add    $0x1,%eax
  800cda:	39 d0                	cmp    %edx,%eax
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	75 f1                	jne    800cd3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf0:	0f b6 02             	movzbl (%edx),%eax
  800cf3:	3c 20                	cmp    $0x20,%al
  800cf5:	74 04                	je     800cfb <strtol+0x17>
  800cf7:	3c 09                	cmp    $0x9,%al
  800cf9:	75 0e                	jne    800d09 <strtol+0x25>
		s++;
  800cfb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfe:	0f b6 02             	movzbl (%edx),%eax
  800d01:	3c 20                	cmp    $0x20,%al
  800d03:	74 f6                	je     800cfb <strtol+0x17>
  800d05:	3c 09                	cmp    $0x9,%al
  800d07:	74 f2                	je     800cfb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d09:	3c 2b                	cmp    $0x2b,%al
  800d0b:	75 0a                	jne    800d17 <strtol+0x33>
		s++;
  800d0d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d10:	bf 00 00 00 00       	mov    $0x0,%edi
  800d15:	eb 10                	jmp    800d27 <strtol+0x43>
  800d17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d1c:	3c 2d                	cmp    $0x2d,%al
  800d1e:	75 07                	jne    800d27 <strtol+0x43>
		s++, neg = 1;
  800d20:	83 c2 01             	add    $0x1,%edx
  800d23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d27:	85 db                	test   %ebx,%ebx
  800d29:	0f 94 c0             	sete   %al
  800d2c:	74 05                	je     800d33 <strtol+0x4f>
  800d2e:	83 fb 10             	cmp    $0x10,%ebx
  800d31:	75 15                	jne    800d48 <strtol+0x64>
  800d33:	80 3a 30             	cmpb   $0x30,(%edx)
  800d36:	75 10                	jne    800d48 <strtol+0x64>
  800d38:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d3c:	75 0a                	jne    800d48 <strtol+0x64>
		s += 2, base = 16;
  800d3e:	83 c2 02             	add    $0x2,%edx
  800d41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d46:	eb 13                	jmp    800d5b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d48:	84 c0                	test   %al,%al
  800d4a:	74 0f                	je     800d5b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d51:	80 3a 30             	cmpb   $0x30,(%edx)
  800d54:	75 05                	jne    800d5b <strtol+0x77>
		s++, base = 8;
  800d56:	83 c2 01             	add    $0x1,%edx
  800d59:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d60:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d62:	0f b6 0a             	movzbl (%edx),%ecx
  800d65:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d68:	80 fb 09             	cmp    $0x9,%bl
  800d6b:	77 08                	ja     800d75 <strtol+0x91>
			dig = *s - '0';
  800d6d:	0f be c9             	movsbl %cl,%ecx
  800d70:	83 e9 30             	sub    $0x30,%ecx
  800d73:	eb 1e                	jmp    800d93 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d75:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d78:	80 fb 19             	cmp    $0x19,%bl
  800d7b:	77 08                	ja     800d85 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d7d:	0f be c9             	movsbl %cl,%ecx
  800d80:	83 e9 57             	sub    $0x57,%ecx
  800d83:	eb 0e                	jmp    800d93 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d85:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d88:	80 fb 19             	cmp    $0x19,%bl
  800d8b:	77 14                	ja     800da1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d8d:	0f be c9             	movsbl %cl,%ecx
  800d90:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d93:	39 f1                	cmp    %esi,%ecx
  800d95:	7d 0e                	jge    800da5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d97:	83 c2 01             	add    $0x1,%edx
  800d9a:	0f af c6             	imul   %esi,%eax
  800d9d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d9f:	eb c1                	jmp    800d62 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800da1:	89 c1                	mov    %eax,%ecx
  800da3:	eb 02                	jmp    800da7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800da7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dab:	74 05                	je     800db2 <strtol+0xce>
		*endptr = (char *) s;
  800dad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800db0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800db2:	89 ca                	mov    %ecx,%edx
  800db4:	f7 da                	neg    %edx
  800db6:	85 ff                	test   %edi,%edi
  800db8:	0f 45 c2             	cmovne %edx,%eax
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 c7                	mov    %eax,%edi
  800dde:	89 c6                	mov    %eax,%esi
  800de0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_cgetc>:

int
sys_cgetc(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800e03:	b8 01 00 00 00       	mov    $0x1,%eax
  800e08:	89 d1                	mov    %edx,%ecx
  800e0a:	89 d3                	mov    %edx,%ebx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 d6                	mov    %edx,%esi
  800e10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 38             	sub    $0x38,%esp
  800e25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e33:	b8 03 00 00 00       	mov    $0x3,%eax
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 cb                	mov    %ecx,%ebx
  800e3d:	89 cf                	mov    %ecx,%edi
  800e3f:	89 ce                	mov    %ecx,%esi
  800e41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 28                	jle    800e6f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e52:	00 
  800e53:	c7 44 24 08 64 1c 80 	movl   $0x801c64,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 81 1c 80 00 	movl   $0x801c81,(%esp)
  800e6a:	e8 25 f3 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800e90:	b8 02 00 00 00       	mov    $0x2,%eax
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 d3                	mov    %edx,%ebx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_yield>:

void
sys_yield(void)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 38             	sub    $0x38,%esp
  800ee2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
  800ef0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 f7                	mov    %esi,%edi
  800f00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	7e 28                	jle    800f2e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f11:	00 
  800f12:	c7 44 24 08 64 1c 80 	movl   $0x801c64,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 81 1c 80 00 	movl   $0x801c81,(%esp)
  800f29:	e8 66 f2 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f37:	89 ec                	mov    %ebp,%esp
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 38             	sub    $0x38,%esp
  800f41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f60:	85 c0                	test   %eax,%eax
  800f62:	7e 28                	jle    800f8c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f6f:	00 
  800f70:	c7 44 24 08 64 1c 80 	movl   $0x801c64,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 81 1c 80 00 	movl   $0x801c81,(%esp)
  800f87:	e8 08 f2 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f95:	89 ec                	mov    %ebp,%esp
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 38             	sub    $0x38,%esp
  800f9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fad:	b8 06 00 00 00       	mov    $0x6,%eax
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 df                	mov    %ebx,%edi
  800fba:	89 de                	mov    %ebx,%esi
  800fbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	7e 28                	jle    800fea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fcd:	00 
  800fce:	c7 44 24 08 64 1c 80 	movl   $0x801c64,0x8(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdd:	00 
  800fde:	c7 04 24 81 1c 80 00 	movl   $0x801c81,(%esp)
  800fe5:	e8 aa f1 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff3:	89 ec                	mov    %ebp,%esp
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100b:	b8 08 00 00 00       	mov    $0x8,%eax
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	89 df                	mov    %ebx,%edi
  801018:	89 de                	mov    %ebx,%esi
  80101a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	7e 28                	jle    801048 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801020:	89 44 24 10          	mov    %eax,0x10(%esp)
  801024:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80102b:	00 
  80102c:	c7 44 24 08 64 1c 80 	movl   $0x801c64,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 81 1c 80 00 	movl   $0x801c81,(%esp)
  801043:	e8 4c f1 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801048:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801051:	89 ec                	mov    %ebp,%esp
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 38             	sub    $0x38,%esp
  80105b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80105e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801061:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801064:	bb 00 00 00 00       	mov    $0x0,%ebx
  801069:	b8 09 00 00 00       	mov    $0x9,%eax
  80106e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801071:	8b 55 08             	mov    0x8(%ebp),%edx
  801074:	89 df                	mov    %ebx,%edi
  801076:	89 de                	mov    %ebx,%esi
  801078:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	7e 28                	jle    8010a6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801082:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801089:	00 
  80108a:	c7 44 24 08 64 1c 80 	movl   $0x801c64,0x8(%esp)
  801091:	00 
  801092:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801099:	00 
  80109a:	c7 04 24 81 1c 80 00 	movl   $0x801c81,(%esp)
  8010a1:	e8 ee f0 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010af:	89 ec                	mov    %ebp,%esp
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c2:	be 00 00 00 00       	mov    $0x0,%esi
  8010c7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e3:	89 ec                	mov    %ebp,%esp
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	83 ec 38             	sub    $0x38,%esp
  8010ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  801100:	8b 55 08             	mov    0x8(%ebp),%edx
  801103:	89 cb                	mov    %ecx,%ebx
  801105:	89 cf                	mov    %ecx,%edi
  801107:	89 ce                	mov    %ecx,%esi
  801109:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7e 28                	jle    801137 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801113:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80111a:	00 
  80111b:	c7 44 24 08 64 1c 80 	movl   $0x801c64,0x8(%esp)
  801122:	00 
  801123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112a:	00 
  80112b:	c7 04 24 81 1c 80 00 	movl   $0x801c81,(%esp)
  801132:	e8 5d f0 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801137:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80113a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801140:	89 ec                	mov    %ebp,%esp
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 0c             	sub    $0xc,%esp
  80114a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80114d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801150:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801153:	b9 00 00 00 00       	mov    $0x0,%ecx
  801158:	b8 0d 00 00 00       	mov    $0xd,%eax
  80115d:	8b 55 08             	mov    0x8(%ebp),%edx
  801160:	89 cb                	mov    %ecx,%ebx
  801162:	89 cf                	mov    %ecx,%edi
  801164:	89 ce                	mov    %ecx,%esi
  801166:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  801168:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80116b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801171:	89 ec                	mov    %ebp,%esp
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    
  801175:	00 00                	add    %al,(%eax)
	...

00801178 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	83 ec 24             	sub    $0x24,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  80117f:	89 d3                	mov    %edx,%ebx
  801181:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801184:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80118b:	f6 c1 02             	test   $0x2,%cl
  80118e:	75 10                	jne    8011a0 <duppage+0x28>
  801190:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801197:	f6 c6 08             	test   $0x8,%dh
  80119a:	0f 84 84 00 00 00    	je     801224 <duppage+0xac>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8011a0:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011a7:	00 
  8011a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011bb:	e8 7b fd ff ff       	call   800f3b <sys_page_map>
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 1c                	jns    8011e0 <duppage+0x68>
			panic("2");
  8011c4:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8011d3:	00 
  8011d4:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8011db:	e8 b4 ef ff ff       	call   800194 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8011e0:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011e7:	00 
  8011e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011f3:	00 
  8011f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ff:	e8 37 fd ff ff       	call   800f3b <sys_page_map>
  801204:	85 c0                	test   %eax,%eax
  801206:	79 3c                	jns    801244 <duppage+0xcc>
			panic("3");
  801208:	c7 44 24 08 9c 1c 80 	movl   $0x801c9c,0x8(%esp)
  80120f:	00 
  801210:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801217:	00 
  801218:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  80121f:	e8 70 ef ff ff       	call   800194 <_panic>
		
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801224:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80122b:	00 
  80122c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801230:	89 44 24 08          	mov    %eax,0x8(%esp)
  801234:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123f:	e8 f7 fc ff ff       	call   800f3b <sys_page_map>
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
  801249:	83 c4 24             	add    $0x24,%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	53                   	push   %ebx
  801253:	83 ec 24             	sub    $0x24,%esp
  801256:	8b 45 08             	mov    0x8(%ebp),%eax
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  801259:	8b 18                	mov    (%eax),%ebx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  80125b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80125f:	74 2d                	je     80128e <pgfault+0x3f>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801261:	89 d8                	mov    %ebx,%eax
  801263:	c1 e8 16             	shr    $0x16,%eax
  801266:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80126d:	a8 01                	test   $0x1,%al
  80126f:	74 1d                	je     80128e <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  801271:	89 d8                	mov    %ebx,%eax
  801273:	c1 e8 0c             	shr    $0xc,%eax
  801276:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  80127d:	f6 c2 01             	test   $0x1,%dl
  801280:	74 0c                	je     80128e <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  801282:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  801289:	f6 c4 08             	test   $0x8,%ah
  80128c:	75 1c                	jne    8012aa <pgfault+0x5b>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  80128e:	c7 44 24 08 9e 1c 80 	movl   $0x801c9e,0x8(%esp)
  801295:	00 
  801296:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80129d:	00 
  80129e:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8012a5:	e8 ea ee ff ff       	call   800194 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  8012aa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b9:	00 
  8012ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c1:	e8 16 fc ff ff       	call   800edc <sys_page_alloc>
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	79 1c                	jns    8012e6 <pgfault+0x97>
		panic("sys_page_alloc");
  8012ca:	c7 44 24 08 b0 1c 80 	movl   $0x801cb0,0x8(%esp)
  8012d1:	00 
  8012d2:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8012d9:	00 
  8012da:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8012e1:	e8 ae ee ff ff       	call   800194 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  8012e6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  8012ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012f3:	00 
  8012f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012f8:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8012ff:	e8 41 f9 ff ff       	call   800c45 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801304:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80130b:	00 
  80130c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801310:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801317:	00 
  801318:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80131f:	00 
  801320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801327:	e8 0f fc ff ff       	call   800f3b <sys_page_map>
  80132c:	85 c0                	test   %eax,%eax
  80132e:	79 1c                	jns    80134c <pgfault+0xfd>
		panic("sys_page_map");
  801330:	c7 44 24 08 bf 1c 80 	movl   $0x801cbf,0x8(%esp)
  801337:	00 
  801338:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80133f:	00 
  801340:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  801347:	e8 48 ee ff ff       	call   800194 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  80134c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801353:	00 
  801354:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135b:	e8 39 fc ff ff       	call   800f99 <sys_page_unmap>
  801360:	85 c0                	test   %eax,%eax
  801362:	79 1c                	jns    801380 <pgfault+0x131>
		panic("sys_page_unmap");
  801364:	c7 44 24 08 cc 1c 80 	movl   $0x801ccc,0x8(%esp)
  80136b:	00 
  80136c:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801373:	00 
  801374:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  80137b:	e8 14 ee ff ff       	call   800194 <_panic>
	return;
}
  801380:	83 c4 24             	add    $0x24,%esp
  801383:	5b                   	pop    %ebx
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	83 ec 1c             	sub    $0x1c,%esp
	set_pgfault_handler(pgfault);
  80138f:	c7 04 24 4f 12 80 00 	movl   $0x80124f,(%esp)
  801396:	e8 75 02 00 00       	call   801610 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80139b:	be 07 00 00 00       	mov    $0x7,%esi
  8013a0:	89 f0                	mov    %esi,%eax
  8013a2:	cd 30                	int    $0x30
  8013a4:	89 c6                	mov    %eax,%esi
  8013a6:	89 c7                	mov    %eax,%edi

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	75 1c                	jne    8013c8 <fork+0x42>
		thisenv = &envs[ENVX(sys_getenvid())];
  8013ac:	e8 cb fa ff ff       	call   800e7c <sys_getenvid>
  8013b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013b6:	c1 e0 07             	shl    $0x7,%eax
  8013b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013be:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  8013c3:	e9 e1 00 00 00       	jmp    8014a9 <fork+0x123>
	}
	if (envid < 0)
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	79 20                	jns    8013ec <fork+0x66>
		panic("sys_exofork: %e", envid);
  8013cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d0:	c7 44 24 08 db 1c 80 	movl   $0x801cdb,0x8(%esp)
  8013d7:	00 
  8013d8:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  8013df:	00 
  8013e0:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8013e7:	e8 a8 ed ff ff       	call   800194 <_panic>
	envid = sys_exofork();
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	c1 e8 16             	shr    $0x16,%eax
  8013f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fd:	a8 01                	test   $0x1,%al
  8013ff:	74 22                	je     801423 <fork+0x9d>
  801401:	89 da                	mov    %ebx,%edx
  801403:	c1 ea 0c             	shr    $0xc,%edx
  801406:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80140d:	a8 01                	test   $0x1,%al
  80140f:	74 12                	je     801423 <fork+0x9d>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801411:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801418:	a8 04                	test   $0x4,%al
  80141a:	74 07                	je     801423 <fork+0x9d>
			duppage(envid, PGNUM(addr));
  80141c:	89 f8                	mov    %edi,%eax
  80141e:	e8 55 fd ff ff       	call   801178 <duppage>
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801423:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801429:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80142f:	75 c0                	jne    8013f1 <fork+0x6b>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801431:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801438:	00 
  801439:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801440:	ee 
  801441:	89 34 24             	mov    %esi,(%esp)
  801444:	e8 93 fa ff ff       	call   800edc <sys_page_alloc>
  801449:	85 c0                	test   %eax,%eax
  80144b:	79 1c                	jns    801469 <fork+0xe3>
		panic("1");
  80144d:	c7 44 24 08 eb 1c 80 	movl   $0x801ceb,0x8(%esp)
  801454:	00 
  801455:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80145c:	00 
  80145d:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  801464:	e8 2b ed ff ff       	call   800194 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801469:	c7 44 24 04 9c 16 80 	movl   $0x80169c,0x4(%esp)
  801470:	00 
  801471:	89 34 24             	mov    %esi,(%esp)
  801474:	e8 dc fb ff ff       	call   801055 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801479:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801480:	00 
  801481:	89 34 24             	mov    %esi,(%esp)
  801484:	e8 6e fb ff ff       	call   800ff7 <sys_env_set_status>
  801489:	85 c0                	test   %eax,%eax
  80148b:	79 1c                	jns    8014a9 <fork+0x123>
		panic("sys_env_set_status");
  80148d:	c7 44 24 08 ed 1c 80 	movl   $0x801ced,0x8(%esp)
  801494:	00 
  801495:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80149c:	00 
  80149d:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8014a4:	e8 eb ec ff ff       	call   800194 <_panic>

	return envid;
}
  8014a9:	89 f0                	mov    %esi,%eax
  8014ab:	83 c4 1c             	add    $0x1c,%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <sfork>:

// Challenge!
int
sfork(void)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014b9:	c7 44 24 08 00 1d 80 	movl   $0x801d00,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8014d0:	e8 bf ec ff ff       	call   800194 <_panic>

008014d5 <pfork>:
	return -E_INVAL;
}

envid_t
pfork(int pr)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	57                   	push   %edi
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
  8014db:	83 ec 1c             	sub    $0x1c,%esp
    set_pgfault_handler(pgfault);
  8014de:	c7 04 24 4f 12 80 00 	movl   $0x80124f,(%esp)
  8014e5:	e8 26 01 00 00       	call   801610 <set_pgfault_handler>
  8014ea:	be 07 00 00 00       	mov    $0x7,%esi
  8014ef:	89 f0                	mov    %esi,%eax
  8014f1:	cd 30                	int    $0x30
  8014f3:	89 c6                	mov    %eax,%esi
  8014f5:	89 c7                	mov    %eax,%edi

    envid_t envid;
    uint32_t addr;
    envid = sys_exofork();
    if (envid == 0) {
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	75 27                	jne    801522 <pfork+0x4d>
        thisenv = &envs[ENVX(sys_getenvid())];
  8014fb:	e8 7c f9 ff ff       	call   800e7c <sys_getenvid>
  801500:	25 ff 03 00 00       	and    $0x3ff,%eax
  801505:	c1 e0 07             	shl    $0x7,%eax
  801508:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80150d:	a3 0c 20 80 00       	mov    %eax,0x80200c
        sys_change_pr(pr);
  801512:	8b 45 08             	mov    0x8(%ebp),%eax
  801515:	89 04 24             	mov    %eax,(%esp)
  801518:	e8 27 fc ff ff       	call   801144 <sys_change_pr>
        return 0;
  80151d:	e9 e1 00 00 00       	jmp    801603 <pfork+0x12e>
    }

    if (envid < 0)
  801522:	85 c0                	test   %eax,%eax
  801524:	79 20                	jns    801546 <pfork+0x71>
        panic("sys_exofork: %e", envid);
  801526:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80152a:	c7 44 24 08 db 1c 80 	movl   $0x801cdb,0x8(%esp)
  801531:	00 
  801532:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801539:	00 
  80153a:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  801541:	e8 4e ec ff ff       	call   800194 <_panic>
        thisenv = &envs[ENVX(sys_getenvid())];
        sys_change_pr(pr);
        return 0;
    }

    if (envid < 0)
  801546:	bb 00 00 00 00       	mov    $0x0,%ebx
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80154b:	89 d8                	mov    %ebx,%eax
  80154d:	c1 e8 16             	shr    $0x16,%eax
  801550:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801557:	a8 01                	test   $0x1,%al
  801559:	74 22                	je     80157d <pfork+0xa8>
  80155b:	89 da                	mov    %ebx,%edx
  80155d:	c1 ea 0c             	shr    $0xc,%edx
  801560:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801567:	a8 01                	test   $0x1,%al
  801569:	74 12                	je     80157d <pfork+0xa8>
            && (uvpt[PGNUM(addr)] & PTE_U)) {
  80156b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801572:	a8 04                	test   $0x4,%al
  801574:	74 07                	je     80157d <pfork+0xa8>
            duppage(envid, PGNUM(addr));
  801576:	89 f8                	mov    %edi,%eax
  801578:	e8 fb fb ff ff       	call   801178 <duppage>
    }

    if (envid < 0)
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80157d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801583:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801589:	75 c0                	jne    80154b <pfork+0x76>
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
            && (uvpt[PGNUM(addr)] & PTE_U)) {
            duppage(envid, PGNUM(addr));
        }

    if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80158b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801592:	00 
  801593:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80159a:	ee 
  80159b:	89 34 24             	mov    %esi,(%esp)
  80159e:	e8 39 f9 ff ff       	call   800edc <sys_page_alloc>
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	79 1c                	jns    8015c3 <pfork+0xee>
        panic("1");
  8015a7:	c7 44 24 08 eb 1c 80 	movl   $0x801ceb,0x8(%esp)
  8015ae:	00 
  8015af:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8015b6:	00 
  8015b7:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8015be:	e8 d1 eb ff ff       	call   800194 <_panic>
    extern void _pgfault_upcall();
    sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8015c3:	c7 44 24 04 9c 16 80 	movl   $0x80169c,0x4(%esp)
  8015ca:	00 
  8015cb:	89 34 24             	mov    %esi,(%esp)
  8015ce:	e8 82 fa ff ff       	call   801055 <sys_env_set_pgfault_upcall>

    if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8015d3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015da:	00 
  8015db:	89 34 24             	mov    %esi,(%esp)
  8015de:	e8 14 fa ff ff       	call   800ff7 <sys_env_set_status>
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	79 1c                	jns    801603 <pfork+0x12e>
        panic("sys_env_set_status");
  8015e7:	c7 44 24 08 ed 1c 80 	movl   $0x801ced,0x8(%esp)
  8015ee:	00 
  8015ef:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  8015f6:	00 
  8015f7:	c7 04 24 91 1c 80 00 	movl   $0x801c91,(%esp)
  8015fe:	e8 91 eb ff ff       	call   800194 <_panic>

    return envid;
    panic("fork not implemented");
  801603:	89 f0                	mov    %esi,%eax
  801605:	83 c4 1c             	add    $0x1c,%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    
  80160d:	00 00                	add    %al,(%eax)
	...

00801610 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801616:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  80161d:	75 3c                	jne    80165b <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80161f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801626:	00 
  801627:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80162e:	ee 
  80162f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801636:	e8 a1 f8 ff ff       	call   800edc <sys_page_alloc>
  80163b:	85 c0                	test   %eax,%eax
  80163d:	79 1c                	jns    80165b <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  80163f:	c7 44 24 08 18 1d 80 	movl   $0x801d18,0x8(%esp)
  801646:	00 
  801647:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80164e:	00 
  80164f:	c7 04 24 7c 1d 80 00 	movl   $0x801d7c,(%esp)
  801656:	e8 39 eb ff ff       	call   800194 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	a3 10 20 80 00       	mov    %eax,0x802010
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801663:	c7 44 24 04 9c 16 80 	movl   $0x80169c,0x4(%esp)
  80166a:	00 
  80166b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801672:	e8 de f9 ff ff       	call   801055 <sys_env_set_pgfault_upcall>
  801677:	85 c0                	test   %eax,%eax
  801679:	79 1c                	jns    801697 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80167b:	c7 44 24 08 44 1d 80 	movl   $0x801d44,0x8(%esp)
  801682:	00 
  801683:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80168a:	00 
  80168b:	c7 04 24 7c 1d 80 00 	movl   $0x801d7c,(%esp)
  801692:	e8 fd ea ff ff       	call   800194 <_panic>
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    
  801699:	00 00                	add    %al,(%eax)
	...

0080169c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80169c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80169d:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8016a2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8016a4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  8016a7:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  8016ab:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  8016b0:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8016b4:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  8016b6:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  8016b9:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  8016ba:	83 c4 04             	add    $0x4,%esp
    popfl
  8016bd:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8016be:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8016bf:	c3                   	ret    

008016c0 <__udivdi3>:
  8016c0:	83 ec 1c             	sub    $0x1c,%esp
  8016c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8016c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8016cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8016cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8016d3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8016d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8016db:	85 ff                	test   %edi,%edi
  8016dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8016e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e5:	89 cd                	mov    %ecx,%ebp
  8016e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016eb:	75 33                	jne    801720 <__udivdi3+0x60>
  8016ed:	39 f1                	cmp    %esi,%ecx
  8016ef:	77 57                	ja     801748 <__udivdi3+0x88>
  8016f1:	85 c9                	test   %ecx,%ecx
  8016f3:	75 0b                	jne    801700 <__udivdi3+0x40>
  8016f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8016fa:	31 d2                	xor    %edx,%edx
  8016fc:	f7 f1                	div    %ecx
  8016fe:	89 c1                	mov    %eax,%ecx
  801700:	89 f0                	mov    %esi,%eax
  801702:	31 d2                	xor    %edx,%edx
  801704:	f7 f1                	div    %ecx
  801706:	89 c6                	mov    %eax,%esi
  801708:	8b 44 24 04          	mov    0x4(%esp),%eax
  80170c:	f7 f1                	div    %ecx
  80170e:	89 f2                	mov    %esi,%edx
  801710:	8b 74 24 10          	mov    0x10(%esp),%esi
  801714:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801718:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80171c:	83 c4 1c             	add    $0x1c,%esp
  80171f:	c3                   	ret    
  801720:	31 d2                	xor    %edx,%edx
  801722:	31 c0                	xor    %eax,%eax
  801724:	39 f7                	cmp    %esi,%edi
  801726:	77 e8                	ja     801710 <__udivdi3+0x50>
  801728:	0f bd cf             	bsr    %edi,%ecx
  80172b:	83 f1 1f             	xor    $0x1f,%ecx
  80172e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801732:	75 2c                	jne    801760 <__udivdi3+0xa0>
  801734:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801738:	76 04                	jbe    80173e <__udivdi3+0x7e>
  80173a:	39 f7                	cmp    %esi,%edi
  80173c:	73 d2                	jae    801710 <__udivdi3+0x50>
  80173e:	31 d2                	xor    %edx,%edx
  801740:	b8 01 00 00 00       	mov    $0x1,%eax
  801745:	eb c9                	jmp    801710 <__udivdi3+0x50>
  801747:	90                   	nop
  801748:	89 f2                	mov    %esi,%edx
  80174a:	f7 f1                	div    %ecx
  80174c:	31 d2                	xor    %edx,%edx
  80174e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801752:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801756:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80175a:	83 c4 1c             	add    $0x1c,%esp
  80175d:	c3                   	ret    
  80175e:	66 90                	xchg   %ax,%ax
  801760:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801765:	b8 20 00 00 00       	mov    $0x20,%eax
  80176a:	89 ea                	mov    %ebp,%edx
  80176c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801770:	d3 e7                	shl    %cl,%edi
  801772:	89 c1                	mov    %eax,%ecx
  801774:	d3 ea                	shr    %cl,%edx
  801776:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80177b:	09 fa                	or     %edi,%edx
  80177d:	89 f7                	mov    %esi,%edi
  80177f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801783:	89 f2                	mov    %esi,%edx
  801785:	8b 74 24 08          	mov    0x8(%esp),%esi
  801789:	d3 e5                	shl    %cl,%ebp
  80178b:	89 c1                	mov    %eax,%ecx
  80178d:	d3 ef                	shr    %cl,%edi
  80178f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801794:	d3 e2                	shl    %cl,%edx
  801796:	89 c1                	mov    %eax,%ecx
  801798:	d3 ee                	shr    %cl,%esi
  80179a:	09 d6                	or     %edx,%esi
  80179c:	89 fa                	mov    %edi,%edx
  80179e:	89 f0                	mov    %esi,%eax
  8017a0:	f7 74 24 0c          	divl   0xc(%esp)
  8017a4:	89 d7                	mov    %edx,%edi
  8017a6:	89 c6                	mov    %eax,%esi
  8017a8:	f7 e5                	mul    %ebp
  8017aa:	39 d7                	cmp    %edx,%edi
  8017ac:	72 22                	jb     8017d0 <__udivdi3+0x110>
  8017ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8017b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8017b7:	d3 e5                	shl    %cl,%ebp
  8017b9:	39 c5                	cmp    %eax,%ebp
  8017bb:	73 04                	jae    8017c1 <__udivdi3+0x101>
  8017bd:	39 d7                	cmp    %edx,%edi
  8017bf:	74 0f                	je     8017d0 <__udivdi3+0x110>
  8017c1:	89 f0                	mov    %esi,%eax
  8017c3:	31 d2                	xor    %edx,%edx
  8017c5:	e9 46 ff ff ff       	jmp    801710 <__udivdi3+0x50>
  8017ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8017d3:	31 d2                	xor    %edx,%edx
  8017d5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8017e1:	83 c4 1c             	add    $0x1c,%esp
  8017e4:	c3                   	ret    
	...

008017f0 <__umoddi3>:
  8017f0:	83 ec 1c             	sub    $0x1c,%esp
  8017f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8017f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8017fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8017ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  801803:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801807:	8b 74 24 24          	mov    0x24(%esp),%esi
  80180b:	85 ed                	test   %ebp,%ebp
  80180d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801811:	89 44 24 08          	mov    %eax,0x8(%esp)
  801815:	89 cf                	mov    %ecx,%edi
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	89 f2                	mov    %esi,%edx
  80181c:	75 1a                	jne    801838 <__umoddi3+0x48>
  80181e:	39 f1                	cmp    %esi,%ecx
  801820:	76 4e                	jbe    801870 <__umoddi3+0x80>
  801822:	f7 f1                	div    %ecx
  801824:	89 d0                	mov    %edx,%eax
  801826:	31 d2                	xor    %edx,%edx
  801828:	8b 74 24 10          	mov    0x10(%esp),%esi
  80182c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801830:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801834:	83 c4 1c             	add    $0x1c,%esp
  801837:	c3                   	ret    
  801838:	39 f5                	cmp    %esi,%ebp
  80183a:	77 54                	ja     801890 <__umoddi3+0xa0>
  80183c:	0f bd c5             	bsr    %ebp,%eax
  80183f:	83 f0 1f             	xor    $0x1f,%eax
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	75 60                	jne    8018a8 <__umoddi3+0xb8>
  801848:	3b 0c 24             	cmp    (%esp),%ecx
  80184b:	0f 87 07 01 00 00    	ja     801958 <__umoddi3+0x168>
  801851:	89 f2                	mov    %esi,%edx
  801853:	8b 34 24             	mov    (%esp),%esi
  801856:	29 ce                	sub    %ecx,%esi
  801858:	19 ea                	sbb    %ebp,%edx
  80185a:	89 34 24             	mov    %esi,(%esp)
  80185d:	8b 04 24             	mov    (%esp),%eax
  801860:	8b 74 24 10          	mov    0x10(%esp),%esi
  801864:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801868:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80186c:	83 c4 1c             	add    $0x1c,%esp
  80186f:	c3                   	ret    
  801870:	85 c9                	test   %ecx,%ecx
  801872:	75 0b                	jne    80187f <__umoddi3+0x8f>
  801874:	b8 01 00 00 00       	mov    $0x1,%eax
  801879:	31 d2                	xor    %edx,%edx
  80187b:	f7 f1                	div    %ecx
  80187d:	89 c1                	mov    %eax,%ecx
  80187f:	89 f0                	mov    %esi,%eax
  801881:	31 d2                	xor    %edx,%edx
  801883:	f7 f1                	div    %ecx
  801885:	8b 04 24             	mov    (%esp),%eax
  801888:	f7 f1                	div    %ecx
  80188a:	eb 98                	jmp    801824 <__umoddi3+0x34>
  80188c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801890:	89 f2                	mov    %esi,%edx
  801892:	8b 74 24 10          	mov    0x10(%esp),%esi
  801896:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80189a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80189e:	83 c4 1c             	add    $0x1c,%esp
  8018a1:	c3                   	ret    
  8018a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8018a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018ad:	89 e8                	mov    %ebp,%eax
  8018af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8018b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8018b8:	89 fa                	mov    %edi,%edx
  8018ba:	d3 e0                	shl    %cl,%eax
  8018bc:	89 e9                	mov    %ebp,%ecx
  8018be:	d3 ea                	shr    %cl,%edx
  8018c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018c5:	09 c2                	or     %eax,%edx
  8018c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018cb:	89 14 24             	mov    %edx,(%esp)
  8018ce:	89 f2                	mov    %esi,%edx
  8018d0:	d3 e7                	shl    %cl,%edi
  8018d2:	89 e9                	mov    %ebp,%ecx
  8018d4:	d3 ea                	shr    %cl,%edx
  8018d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018df:	d3 e6                	shl    %cl,%esi
  8018e1:	89 e9                	mov    %ebp,%ecx
  8018e3:	d3 e8                	shr    %cl,%eax
  8018e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018ea:	09 f0                	or     %esi,%eax
  8018ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8018f0:	f7 34 24             	divl   (%esp)
  8018f3:	d3 e6                	shl    %cl,%esi
  8018f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8018f9:	89 d6                	mov    %edx,%esi
  8018fb:	f7 e7                	mul    %edi
  8018fd:	39 d6                	cmp    %edx,%esi
  8018ff:	89 c1                	mov    %eax,%ecx
  801901:	89 d7                	mov    %edx,%edi
  801903:	72 3f                	jb     801944 <__umoddi3+0x154>
  801905:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801909:	72 35                	jb     801940 <__umoddi3+0x150>
  80190b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80190f:	29 c8                	sub    %ecx,%eax
  801911:	19 fe                	sbb    %edi,%esi
  801913:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801918:	89 f2                	mov    %esi,%edx
  80191a:	d3 e8                	shr    %cl,%eax
  80191c:	89 e9                	mov    %ebp,%ecx
  80191e:	d3 e2                	shl    %cl,%edx
  801920:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801925:	09 d0                	or     %edx,%eax
  801927:	89 f2                	mov    %esi,%edx
  801929:	d3 ea                	shr    %cl,%edx
  80192b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80192f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801933:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801937:	83 c4 1c             	add    $0x1c,%esp
  80193a:	c3                   	ret    
  80193b:	90                   	nop
  80193c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801940:	39 d6                	cmp    %edx,%esi
  801942:	75 c7                	jne    80190b <__umoddi3+0x11b>
  801944:	89 d7                	mov    %edx,%edi
  801946:	89 c1                	mov    %eax,%ecx
  801948:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80194c:	1b 3c 24             	sbb    (%esp),%edi
  80194f:	eb ba                	jmp    80190b <__umoddi3+0x11b>
  801951:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801958:	39 f5                	cmp    %esi,%ebp
  80195a:	0f 82 f1 fe ff ff    	jb     801851 <__umoddi3+0x61>
  801960:	e9 f8 fe ff ff       	jmp    80185d <__umoddi3+0x6d>
