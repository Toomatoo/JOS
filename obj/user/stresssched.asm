
obj/user/stresssched.debug:     file format elf32-i386


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
  800048:	e8 3f 0e 00 00       	call   800e8c <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 ae 12 00 00       	call   801307 <fork>
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
  800095:	e8 22 0e 00 00       	call   800ebc <sys_yield>
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
  8000b3:	e8 04 0e 00 00       	call   800ebc <sys_yield>
  8000b8:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000bd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000c3:	83 c2 01             	add    $0x1,%edx
  8000c6:	89 15 04 40 80 00    	mov    %edx,0x804004
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
  8000d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000db:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000e0:	74 25                	je     800107 <umain+0xc7>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000eb:	c7 44 24 08 a0 28 80 	movl   $0x8028a0,0x8(%esp)
  8000f2:	00 
  8000f3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000fa:	00 
  8000fb:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  800102:	e8 95 00 00 00       	call   80019c <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800107:	a1 08 40 80 00       	mov    0x804008,%eax
  80010c:	8b 50 5c             	mov    0x5c(%eax),%edx
  80010f:	8b 40 48             	mov    0x48(%eax),%eax
  800112:	89 54 24 08          	mov    %edx,0x8(%esp)
  800116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011a:	c7 04 24 db 28 80 00 	movl   $0x8028db,(%esp)
  800121:	e8 71 01 00 00       	call   800297 <cprintf>

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
  800142:	e8 45 0d 00 00       	call   800e8c <sys_getenvid>
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	c1 e0 07             	shl    $0x7,%eax
  80014f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800154:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	85 f6                	test   %esi,%esi
  80015b:	7e 07                	jle    800164 <libmain+0x34>
		binaryname = argv[0];
  80015d:	8b 03                	mov    (%ebx),%eax
  80015f:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800186:	e8 83 16 00 00       	call   80180e <close_all>
	sys_env_destroy(0);
  80018b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800192:	e8 98 0c 00 00       	call   800e2f <sys_env_destroy>
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001a4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001ad:	e8 da 0c 00 00       	call   800e8c <sys_getenvid>
  8001b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c8:	c7 04 24 04 29 80 00 	movl   $0x802904,(%esp)
  8001cf:	e8 c3 00 00 00       	call   800297 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 53 00 00 00       	call   800236 <vcprintf>
	cprintf("\n");
  8001e3:	c7 04 24 7f 2c 80 00 	movl   $0x802c7f,(%esp)
  8001ea:	e8 a8 00 00 00       	call   800297 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ef:	cc                   	int3   
  8001f0:	eb fd                	jmp    8001ef <_panic+0x53>
	...

008001f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 14             	sub    $0x14,%esp
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fe:	8b 03                	mov    (%ebx),%eax
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800207:	83 c0 01             	add    $0x1,%eax
  80020a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800211:	75 19                	jne    80022c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800213:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80021a:	00 
  80021b:	8d 43 08             	lea    0x8(%ebx),%eax
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	e8 aa 0b 00 00       	call   800dd0 <sys_cputs>
		b->idx = 0;
  800226:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80022c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800230:	83 c4 14             	add    $0x14,%esp
  800233:	5b                   	pop    %ebx
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80023f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800246:	00 00 00 
	b.cnt = 0;
  800249:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800250:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
  800256:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800261:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 f4 01 80 00 	movl   $0x8001f4,(%esp)
  800272:	e8 97 01 00 00       	call   80040e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800277:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800287:	89 04 24             	mov    %eax,(%esp)
  80028a:	e8 41 0b 00 00       	call   800dd0 <sys_cputs>

	return b.cnt;
}
  80028f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 87 ff ff ff       	call   800236 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    
  8002b1:	00 00                	add    %al,(%eax)
	...

008002b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 3c             	sub    $0x3c,%esp
  8002bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c0:	89 d7                	mov    %edx,%edi
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002dc:	72 11                	jb     8002ef <printnum+0x3b>
  8002de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e4:	76 09                	jbe    8002ef <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e6:	83 eb 01             	sub    $0x1,%ebx
  8002e9:	85 db                	test   %ebx,%ebx
  8002eb:	7f 51                	jg     80033e <printnum+0x8a>
  8002ed:	eb 5e                	jmp    80034d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002f3:	83 eb 01             	sub    $0x1,%ebx
  8002f6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800301:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800305:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800309:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800310:	00 
  800311:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031e:	e8 cd 22 00 00       	call   8025f0 <__udivdi3>
  800323:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800327:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800332:	89 fa                	mov    %edi,%edx
  800334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800337:	e8 78 ff ff ff       	call   8002b4 <printnum>
  80033c:	eb 0f                	jmp    80034d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800342:	89 34 24             	mov    %esi,(%esp)
  800345:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800348:	83 eb 01             	sub    $0x1,%ebx
  80034b:	75 f1                	jne    80033e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800351:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800355:	8b 45 10             	mov    0x10(%ebp),%eax
  800358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800363:	00 
  800364:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800371:	e8 aa 23 00 00       	call   802720 <__umoddi3>
  800376:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037a:	0f be 80 27 29 80 00 	movsbl 0x802927(%eax),%eax
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800387:	83 c4 3c             	add    $0x3c,%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800392:	83 fa 01             	cmp    $0x1,%edx
  800395:	7e 0e                	jle    8003a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800397:	8b 10                	mov    (%eax),%edx
  800399:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039c:	89 08                	mov    %ecx,(%eax)
  80039e:	8b 02                	mov    (%edx),%eax
  8003a0:	8b 52 04             	mov    0x4(%edx),%edx
  8003a3:	eb 22                	jmp    8003c7 <getuint+0x38>
	else if (lflag)
  8003a5:	85 d2                	test   %edx,%edx
  8003a7:	74 10                	je     8003b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	eb 0e                	jmp    8003c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b9:	8b 10                	mov    (%eax),%edx
  8003bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003be:	89 08                	mov    %ecx,(%eax)
  8003c0:	8b 02                	mov    (%edx),%eax
  8003c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d8:	73 0a                	jae    8003e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003dd:	88 0a                	mov    %cl,(%edx)
  8003df:	83 c2 01             	add    $0x1,%edx
  8003e2:	89 10                	mov    %edx,(%eax)
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	e8 02 00 00 00       	call   80040e <vprintfmt>
	va_end(ap);
}
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	57                   	push   %edi
  800412:	56                   	push   %esi
  800413:	53                   	push   %ebx
  800414:	83 ec 5c             	sub    $0x5c,%esp
  800417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041a:	8b 75 10             	mov    0x10(%ebp),%esi
  80041d:	eb 12                	jmp    800431 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80041f:	85 c0                	test   %eax,%eax
  800421:	0f 84 e4 04 00 00    	je     80090b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800427:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042b:	89 04 24             	mov    %eax,(%esp)
  80042e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800431:	0f b6 06             	movzbl (%esi),%eax
  800434:	83 c6 01             	add    $0x1,%esi
  800437:	83 f8 25             	cmp    $0x25,%eax
  80043a:	75 e3                	jne    80041f <vprintfmt+0x11>
  80043c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800440:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800447:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80044c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800453:	b9 00 00 00 00       	mov    $0x0,%ecx
  800458:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80045b:	eb 2b                	jmp    800488 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800460:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800464:	eb 22                	jmp    800488 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800469:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80046d:	eb 19                	jmp    800488 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800472:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800479:	eb 0d                	jmp    800488 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80047b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80047e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800481:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	0f b6 06             	movzbl (%esi),%eax
  80048b:	0f b6 d0             	movzbl %al,%edx
  80048e:	8d 7e 01             	lea    0x1(%esi),%edi
  800491:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800494:	83 e8 23             	sub    $0x23,%eax
  800497:	3c 55                	cmp    $0x55,%al
  800499:	0f 87 46 04 00 00    	ja     8008e5 <vprintfmt+0x4d7>
  80049f:	0f b6 c0             	movzbl %al,%eax
  8004a2:	ff 24 85 80 2a 80 00 	jmp    *0x802a80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a9:	83 ea 30             	sub    $0x30,%edx
  8004ac:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004af:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004b3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004b9:	83 fa 09             	cmp    $0x9,%edx
  8004bc:	77 4a                	ja     800508 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004c4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004c7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004cb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ce:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d1:	83 fa 09             	cmp    $0x9,%edx
  8004d4:	76 eb                	jbe    8004c1 <vprintfmt+0xb3>
  8004d6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004d9:	eb 2d                	jmp    800508 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ec:	eb 1a                	jmp    800508 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004f1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004f5:	79 91                	jns    800488 <vprintfmt+0x7a>
  8004f7:	e9 73 ff ff ff       	jmp    80046f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ff:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800506:	eb 80                	jmp    800488 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800508:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80050c:	0f 89 76 ff ff ff    	jns    800488 <vprintfmt+0x7a>
  800512:	e9 64 ff ff ff       	jmp    80047b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800517:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051d:	e9 66 ff ff ff       	jmp    800488 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 04 24             	mov    %eax,(%esp)
  800534:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053a:	e9 f2 fe ff ff       	jmp    800431 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80053f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800543:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800546:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80054a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80054d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800551:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800554:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800557:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80055b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80055e:	80 f9 09             	cmp    $0x9,%cl
  800561:	77 1d                	ja     800580 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800563:	0f be c0             	movsbl %al,%eax
  800566:	6b c0 64             	imul   $0x64,%eax,%eax
  800569:	0f be d2             	movsbl %dl,%edx
  80056c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80056f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800576:	a3 04 30 80 00       	mov    %eax,0x803004
  80057b:	e9 b1 fe ff ff       	jmp    800431 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800580:	c7 44 24 04 3f 29 80 	movl   $0x80293f,0x4(%esp)
  800587:	00 
  800588:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058b:	89 04 24             	mov    %eax,(%esp)
  80058e:	e8 18 05 00 00       	call   800aab <strcmp>
  800593:	85 c0                	test   %eax,%eax
  800595:	75 0f                	jne    8005a6 <vprintfmt+0x198>
  800597:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  80059e:	00 00 00 
  8005a1:	e9 8b fe ff ff       	jmp    800431 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8005a6:	c7 44 24 04 43 29 80 	movl   $0x802943,0x4(%esp)
  8005ad:	00 
  8005ae:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005b1:	89 14 24             	mov    %edx,(%esp)
  8005b4:	e8 f2 04 00 00       	call   800aab <strcmp>
  8005b9:	85 c0                	test   %eax,%eax
  8005bb:	75 0f                	jne    8005cc <vprintfmt+0x1be>
  8005bd:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8005c4:	00 00 00 
  8005c7:	e9 65 fe ff ff       	jmp    800431 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005cc:	c7 44 24 04 47 29 80 	movl   $0x802947,0x4(%esp)
  8005d3:	00 
  8005d4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005d7:	89 0c 24             	mov    %ecx,(%esp)
  8005da:	e8 cc 04 00 00       	call   800aab <strcmp>
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	75 0f                	jne    8005f2 <vprintfmt+0x1e4>
  8005e3:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8005ea:	00 00 00 
  8005ed:	e9 3f fe ff ff       	jmp    800431 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005f2:	c7 44 24 04 4b 29 80 	movl   $0x80294b,0x4(%esp)
  8005f9:	00 
  8005fa:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005fd:	89 3c 24             	mov    %edi,(%esp)
  800600:	e8 a6 04 00 00       	call   800aab <strcmp>
  800605:	85 c0                	test   %eax,%eax
  800607:	75 0f                	jne    800618 <vprintfmt+0x20a>
  800609:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800610:	00 00 00 
  800613:	e9 19 fe ff ff       	jmp    800431 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800618:	c7 44 24 04 4f 29 80 	movl   $0x80294f,0x4(%esp)
  80061f:	00 
  800620:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	e8 80 04 00 00       	call   800aab <strcmp>
  80062b:	85 c0                	test   %eax,%eax
  80062d:	75 0f                	jne    80063e <vprintfmt+0x230>
  80062f:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800636:	00 00 00 
  800639:	e9 f3 fd ff ff       	jmp    800431 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80063e:	c7 44 24 04 53 29 80 	movl   $0x802953,0x4(%esp)
  800645:	00 
  800646:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800649:	89 14 24             	mov    %edx,(%esp)
  80064c:	e8 5a 04 00 00       	call   800aab <strcmp>
  800651:	83 f8 01             	cmp    $0x1,%eax
  800654:	19 c0                	sbb    %eax,%eax
  800656:	f7 d0                	not    %eax
  800658:	83 c0 08             	add    $0x8,%eax
  80065b:	a3 04 30 80 00       	mov    %eax,0x803004
  800660:	e9 cc fd ff ff       	jmp    800431 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	89 c2                	mov    %eax,%edx
  800672:	c1 fa 1f             	sar    $0x1f,%edx
  800675:	31 d0                	xor    %edx,%eax
  800677:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800679:	83 f8 0f             	cmp    $0xf,%eax
  80067c:	7f 0b                	jg     800689 <vprintfmt+0x27b>
  80067e:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  800685:	85 d2                	test   %edx,%edx
  800687:	75 23                	jne    8006ac <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800689:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068d:	c7 44 24 08 57 29 80 	movl   $0x802957,0x8(%esp)
  800694:	00 
  800695:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800699:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069c:	89 3c 24             	mov    %edi,(%esp)
  80069f:	e8 42 fd ff ff       	call   8003e6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a7:	e9 85 fd ff ff       	jmp    800431 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b0:	c7 44 24 08 a1 2e 80 	movl   $0x802ea1,0x8(%esp)
  8006b7:	00 
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	89 3c 24             	mov    %edi,(%esp)
  8006c2:	e8 1f fd ff ff       	call   8003e6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006ca:	e9 62 fd ff ff       	jmp    800431 <vprintfmt+0x23>
  8006cf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006d5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006e3:	85 f6                	test   %esi,%esi
  8006e5:	b8 38 29 80 00       	mov    $0x802938,%eax
  8006ea:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006ed:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006f1:	7e 06                	jle    8006f9 <vprintfmt+0x2eb>
  8006f3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006f7:	75 13                	jne    80070c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f9:	0f be 06             	movsbl (%esi),%eax
  8006fc:	83 c6 01             	add    $0x1,%esi
  8006ff:	85 c0                	test   %eax,%eax
  800701:	0f 85 94 00 00 00    	jne    80079b <vprintfmt+0x38d>
  800707:	e9 81 00 00 00       	jmp    80078d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800710:	89 34 24             	mov    %esi,(%esp)
  800713:	e8 a3 02 00 00       	call   8009bb <strnlen>
  800718:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80071b:	29 c2                	sub    %eax,%edx
  80071d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800720:	85 d2                	test   %edx,%edx
  800722:	7e d5                	jle    8006f9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800724:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800728:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80072b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80072e:	89 d6                	mov    %edx,%esi
  800730:	89 cf                	mov    %ecx,%edi
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	89 3c 24             	mov    %edi,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073c:	83 ee 01             	sub    $0x1,%esi
  80073f:	75 f1                	jne    800732 <vprintfmt+0x324>
  800741:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800744:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800747:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80074a:	eb ad                	jmp    8006f9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80074c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800750:	74 1b                	je     80076d <vprintfmt+0x35f>
  800752:	8d 50 e0             	lea    -0x20(%eax),%edx
  800755:	83 fa 5e             	cmp    $0x5e,%edx
  800758:	76 13                	jbe    80076d <vprintfmt+0x35f>
					putch('?', putdat);
  80075a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80075d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800761:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800768:	ff 55 08             	call   *0x8(%ebp)
  80076b:	eb 0d                	jmp    80077a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80076d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800770:	89 54 24 04          	mov    %edx,0x4(%esp)
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80077a:	83 eb 01             	sub    $0x1,%ebx
  80077d:	0f be 06             	movsbl (%esi),%eax
  800780:	83 c6 01             	add    $0x1,%esi
  800783:	85 c0                	test   %eax,%eax
  800785:	75 1a                	jne    8007a1 <vprintfmt+0x393>
  800787:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80078a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800790:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800794:	7f 1c                	jg     8007b2 <vprintfmt+0x3a4>
  800796:	e9 96 fc ff ff       	jmp    800431 <vprintfmt+0x23>
  80079b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80079e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a1:	85 ff                	test   %edi,%edi
  8007a3:	78 a7                	js     80074c <vprintfmt+0x33e>
  8007a5:	83 ef 01             	sub    $0x1,%edi
  8007a8:	79 a2                	jns    80074c <vprintfmt+0x33e>
  8007aa:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007ad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007b0:	eb db                	jmp    80078d <vprintfmt+0x37f>
  8007b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b5:	89 de                	mov    %ebx,%esi
  8007b7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c7:	83 eb 01             	sub    $0x1,%ebx
  8007ca:	75 ee                	jne    8007ba <vprintfmt+0x3ac>
  8007cc:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007d1:	e9 5b fc ff ff       	jmp    800431 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d6:	83 f9 01             	cmp    $0x1,%ecx
  8007d9:	7e 10                	jle    8007eb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 50 08             	lea    0x8(%eax),%edx
  8007e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e4:	8b 30                	mov    (%eax),%esi
  8007e6:	8b 78 04             	mov    0x4(%eax),%edi
  8007e9:	eb 26                	jmp    800811 <vprintfmt+0x403>
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	74 12                	je     800801 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 30                	mov    (%eax),%esi
  8007fa:	89 f7                	mov    %esi,%edi
  8007fc:	c1 ff 1f             	sar    $0x1f,%edi
  8007ff:	eb 10                	jmp    800811 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8d 50 04             	lea    0x4(%eax),%edx
  800807:	89 55 14             	mov    %edx,0x14(%ebp)
  80080a:	8b 30                	mov    (%eax),%esi
  80080c:	89 f7                	mov    %esi,%edi
  80080e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800811:	85 ff                	test   %edi,%edi
  800813:	78 0e                	js     800823 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800815:	89 f0                	mov    %esi,%eax
  800817:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800819:	be 0a 00 00 00       	mov    $0xa,%esi
  80081e:	e9 84 00 00 00       	jmp    8008a7 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800823:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800827:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800831:	89 f0                	mov    %esi,%eax
  800833:	89 fa                	mov    %edi,%edx
  800835:	f7 d8                	neg    %eax
  800837:	83 d2 00             	adc    $0x0,%edx
  80083a:	f7 da                	neg    %edx
			}
			base = 10;
  80083c:	be 0a 00 00 00       	mov    $0xa,%esi
  800841:	eb 64                	jmp    8008a7 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800843:	89 ca                	mov    %ecx,%edx
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
  800848:	e8 42 fb ff ff       	call   80038f <getuint>
			base = 10;
  80084d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800852:	eb 53                	jmp    8008a7 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800854:	89 ca                	mov    %ecx,%edx
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	e8 31 fb ff ff       	call   80038f <getuint>
    			base = 8;
  80085e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800863:	eb 42                	jmp    8008a7 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800865:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800869:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800870:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800873:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800877:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80087e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8d 50 04             	lea    0x4(%eax),%edx
  800887:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088a:	8b 00                	mov    (%eax),%eax
  80088c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800891:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800896:	eb 0f                	jmp    8008a7 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800898:	89 ca                	mov    %ecx,%edx
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
  80089d:	e8 ed fa ff ff       	call   80038f <getuint>
			base = 16;
  8008a2:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a7:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008ab:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008af:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008b2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008b6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c1:	89 da                	mov    %ebx,%edx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	e8 e9 f9 ff ff       	call   8002b4 <printnum>
			break;
  8008cb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008ce:	e9 5e fb ff ff       	jmp    800431 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d7:	89 14 24             	mov    %edx,(%esp)
  8008da:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e0:	e9 4c fb ff ff       	jmp    800431 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f7:	0f 84 34 fb ff ff    	je     800431 <vprintfmt+0x23>
  8008fd:	83 ee 01             	sub    $0x1,%esi
  800900:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800904:	75 f7                	jne    8008fd <vprintfmt+0x4ef>
  800906:	e9 26 fb ff ff       	jmp    800431 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80090b:	83 c4 5c             	add    $0x5c,%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	83 ec 28             	sub    $0x28,%esp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800922:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800926:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800929:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800930:	85 c0                	test   %eax,%eax
  800932:	74 30                	je     800964 <vsnprintf+0x51>
  800934:	85 d2                	test   %edx,%edx
  800936:	7e 2c                	jle    800964 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800938:	8b 45 14             	mov    0x14(%ebp),%eax
  80093b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093f:	8b 45 10             	mov    0x10(%ebp),%eax
  800942:	89 44 24 08          	mov    %eax,0x8(%esp)
  800946:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	c7 04 24 c9 03 80 00 	movl   $0x8003c9,(%esp)
  800954:	e8 b5 fa ff ff       	call   80040e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800959:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800962:	eb 05                	jmp    800969 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800964:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800971:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800974:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800978:	8b 45 10             	mov    0x10(%ebp),%eax
  80097b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800982:	89 44 24 04          	mov    %eax,0x4(%esp)
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	89 04 24             	mov    %eax,(%esp)
  80098c:	e8 82 ff ff ff       	call   800913 <vsnprintf>
	va_end(ap);

	return rc;
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    
	...

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ae:	74 09                	je     8009b9 <strlen+0x19>
		n++;
  8009b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b7:	75 f7                	jne    8009b0 <strlen+0x10>
		n++;
	return n;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	85 c9                	test   %ecx,%ecx
  8009cc:	74 1a                	je     8009e8 <strnlen+0x2d>
  8009ce:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009d1:	74 15                	je     8009e8 <strnlen+0x2d>
  8009d3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009d8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009da:	39 ca                	cmp    %ecx,%edx
  8009dc:	74 0a                	je     8009e8 <strnlen+0x2d>
  8009de:	83 c2 01             	add    $0x1,%edx
  8009e1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009e6:	75 f0                	jne    8009d8 <strnlen+0x1d>
		n++;
	return n;
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009fe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	84 c9                	test   %cl,%cl
  800a06:	75 f2                	jne    8009fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a15:	89 1c 24             	mov    %ebx,(%esp)
  800a18:	e8 83 ff ff ff       	call   8009a0 <strlen>
	strcpy(dst + len, src);
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a24:	01 d8                	add    %ebx,%eax
  800a26:	89 04 24             	mov    %eax,(%esp)
  800a29:	e8 bd ff ff ff       	call   8009eb <strcpy>
	return dst;
}
  800a2e:	89 d8                	mov    %ebx,%eax
  800a30:	83 c4 08             	add    $0x8,%esp
  800a33:	5b                   	pop    %ebx
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a44:	85 f6                	test   %esi,%esi
  800a46:	74 18                	je     800a60 <strncpy+0x2a>
  800a48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a4d:	0f b6 1a             	movzbl (%edx),%ebx
  800a50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a53:	80 3a 01             	cmpb   $0x1,(%edx)
  800a56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	39 f1                	cmp    %esi,%ecx
  800a5e:	75 ed                	jne    800a4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a70:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a73:	89 f8                	mov    %edi,%eax
  800a75:	85 f6                	test   %esi,%esi
  800a77:	74 2b                	je     800aa4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a79:	83 fe 01             	cmp    $0x1,%esi
  800a7c:	74 23                	je     800aa1 <strlcpy+0x3d>
  800a7e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a81:	84 c9                	test   %cl,%cl
  800a83:	74 1c                	je     800aa1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a85:	83 ee 02             	sub    $0x2,%esi
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a8d:	88 08                	mov    %cl,(%eax)
  800a8f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a92:	39 f2                	cmp    %esi,%edx
  800a94:	74 0b                	je     800aa1 <strlcpy+0x3d>
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a9d:	84 c9                	test   %cl,%cl
  800a9f:	75 ec                	jne    800a8d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800aa1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa4:	29 f8                	sub    %edi,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab4:	0f b6 01             	movzbl (%ecx),%eax
  800ab7:	84 c0                	test   %al,%al
  800ab9:	74 16                	je     800ad1 <strcmp+0x26>
  800abb:	3a 02                	cmp    (%edx),%al
  800abd:	75 12                	jne    800ad1 <strcmp+0x26>
		p++, q++;
  800abf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ac2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ac6:	84 c0                	test   %al,%al
  800ac8:	74 07                	je     800ad1 <strcmp+0x26>
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	3a 02                	cmp    (%edx),%al
  800acf:	74 ee                	je     800abf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad1:	0f b6 c0             	movzbl %al,%eax
  800ad4:	0f b6 12             	movzbl (%edx),%edx
  800ad7:	29 d0                	sub    %edx,%eax
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aed:	85 d2                	test   %edx,%edx
  800aef:	74 28                	je     800b19 <strncmp+0x3e>
  800af1:	0f b6 01             	movzbl (%ecx),%eax
  800af4:	84 c0                	test   %al,%al
  800af6:	74 24                	je     800b1c <strncmp+0x41>
  800af8:	3a 03                	cmp    (%ebx),%al
  800afa:	75 20                	jne    800b1c <strncmp+0x41>
  800afc:	83 ea 01             	sub    $0x1,%edx
  800aff:	74 13                	je     800b14 <strncmp+0x39>
		n--, p++, q++;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	84 c0                	test   %al,%al
  800b0c:	74 0e                	je     800b1c <strncmp+0x41>
  800b0e:	3a 03                	cmp    (%ebx),%al
  800b10:	74 ea                	je     800afc <strncmp+0x21>
  800b12:	eb 08                	jmp    800b1c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	0f b6 13             	movzbl (%ebx),%edx
  800b22:	29 d0                	sub    %edx,%eax
  800b24:	eb f3                	jmp    800b19 <strncmp+0x3e>

00800b26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b30:	0f b6 10             	movzbl (%eax),%edx
  800b33:	84 d2                	test   %dl,%dl
  800b35:	74 1c                	je     800b53 <strchr+0x2d>
		if (*s == c)
  800b37:	38 ca                	cmp    %cl,%dl
  800b39:	75 09                	jne    800b44 <strchr+0x1e>
  800b3b:	eb 1b                	jmp    800b58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b40:	38 ca                	cmp    %cl,%dl
  800b42:	74 14                	je     800b58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b44:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	75 f1                	jne    800b3d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b51:	eb 05                	jmp    800b58 <strchr+0x32>
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b64:	0f b6 10             	movzbl (%eax),%edx
  800b67:	84 d2                	test   %dl,%dl
  800b69:	74 14                	je     800b7f <strfind+0x25>
		if (*s == c)
  800b6b:	38 ca                	cmp    %cl,%dl
  800b6d:	75 06                	jne    800b75 <strfind+0x1b>
  800b6f:	eb 0e                	jmp    800b7f <strfind+0x25>
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 0a                	je     800b7f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b99:	85 c9                	test   %ecx,%ecx
  800b9b:	74 30                	je     800bcd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba3:	75 25                	jne    800bca <memset+0x49>
  800ba5:	f6 c1 03             	test   $0x3,%cl
  800ba8:	75 20                	jne    800bca <memset+0x49>
		c &= 0xFF;
  800baa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	c1 e3 08             	shl    $0x8,%ebx
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	c1 e6 18             	shl    $0x18,%esi
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	c1 e0 10             	shl    $0x10,%eax
  800bbc:	09 f0                	or     %esi,%eax
  800bbe:	09 d0                	or     %edx,%eax
  800bc0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bc5:	fc                   	cld    
  800bc6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc8:	eb 03                	jmp    800bcd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bca:	fc                   	cld    
  800bcb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bcd:	89 f8                	mov    %edi,%eax
  800bcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bd8:	89 ec                	mov    %ebp,%esp
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
  800be2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800be5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf1:	39 c6                	cmp    %eax,%esi
  800bf3:	73 36                	jae    800c2b <memmove+0x4f>
  800bf5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf8:	39 d0                	cmp    %edx,%eax
  800bfa:	73 2f                	jae    800c2b <memmove+0x4f>
		s += n;
		d += n;
  800bfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bff:	f6 c2 03             	test   $0x3,%dl
  800c02:	75 1b                	jne    800c1f <memmove+0x43>
  800c04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0a:	75 13                	jne    800c1f <memmove+0x43>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 0e                	jne    800c1f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c11:	83 ef 04             	sub    $0x4,%edi
  800c14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c1a:	fd                   	std    
  800c1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1d:	eb 09                	jmp    800c28 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1f:	83 ef 01             	sub    $0x1,%edi
  800c22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c25:	fd                   	std    
  800c26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c28:	fc                   	cld    
  800c29:	eb 20                	jmp    800c4b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c31:	75 13                	jne    800c46 <memmove+0x6a>
  800c33:	a8 03                	test   $0x3,%al
  800c35:	75 0f                	jne    800c46 <memmove+0x6a>
  800c37:	f6 c1 03             	test   $0x3,%cl
  800c3a:	75 0a                	jne    800c46 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c3c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c3f:	89 c7                	mov    %eax,%edi
  800c41:	fc                   	cld    
  800c42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c44:	eb 05                	jmp    800c4b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	fc                   	cld    
  800c49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c51:	89 ec                	mov    %ebp,%esp
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	89 04 24             	mov    %eax,(%esp)
  800c6f:	e8 68 ff ff ff       	call   800bdc <memmove>
}
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    

00800c76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c82:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8a:	85 ff                	test   %edi,%edi
  800c8c:	74 37                	je     800cc5 <memcmp+0x4f>
		if (*s1 != *s2)
  800c8e:	0f b6 03             	movzbl (%ebx),%eax
  800c91:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c94:	83 ef 01             	sub    $0x1,%edi
  800c97:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c9c:	38 c8                	cmp    %cl,%al
  800c9e:	74 1c                	je     800cbc <memcmp+0x46>
  800ca0:	eb 10                	jmp    800cb2 <memcmp+0x3c>
  800ca2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ca7:	83 c2 01             	add    $0x1,%edx
  800caa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cae:	38 c8                	cmp    %cl,%al
  800cb0:	74 0a                	je     800cbc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800cb2:	0f b6 c0             	movzbl %al,%eax
  800cb5:	0f b6 c9             	movzbl %cl,%ecx
  800cb8:	29 c8                	sub    %ecx,%eax
  800cba:	eb 09                	jmp    800cc5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbc:	39 fa                	cmp    %edi,%edx
  800cbe:	75 e2                	jne    800ca2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cd0:	89 c2                	mov    %eax,%edx
  800cd2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cd5:	39 d0                	cmp    %edx,%eax
  800cd7:	73 19                	jae    800cf2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cdd:	38 08                	cmp    %cl,(%eax)
  800cdf:	75 06                	jne    800ce7 <memfind+0x1d>
  800ce1:	eb 0f                	jmp    800cf2 <memfind+0x28>
  800ce3:	38 08                	cmp    %cl,(%eax)
  800ce5:	74 0b                	je     800cf2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce7:	83 c0 01             	add    $0x1,%eax
  800cea:	39 d0                	cmp    %edx,%eax
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	75 f1                	jne    800ce3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d00:	0f b6 02             	movzbl (%edx),%eax
  800d03:	3c 20                	cmp    $0x20,%al
  800d05:	74 04                	je     800d0b <strtol+0x17>
  800d07:	3c 09                	cmp    $0x9,%al
  800d09:	75 0e                	jne    800d19 <strtol+0x25>
		s++;
  800d0b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0e:	0f b6 02             	movzbl (%edx),%eax
  800d11:	3c 20                	cmp    $0x20,%al
  800d13:	74 f6                	je     800d0b <strtol+0x17>
  800d15:	3c 09                	cmp    $0x9,%al
  800d17:	74 f2                	je     800d0b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d19:	3c 2b                	cmp    $0x2b,%al
  800d1b:	75 0a                	jne    800d27 <strtol+0x33>
		s++;
  800d1d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d20:	bf 00 00 00 00       	mov    $0x0,%edi
  800d25:	eb 10                	jmp    800d37 <strtol+0x43>
  800d27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d2c:	3c 2d                	cmp    $0x2d,%al
  800d2e:	75 07                	jne    800d37 <strtol+0x43>
		s++, neg = 1;
  800d30:	83 c2 01             	add    $0x1,%edx
  800d33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d37:	85 db                	test   %ebx,%ebx
  800d39:	0f 94 c0             	sete   %al
  800d3c:	74 05                	je     800d43 <strtol+0x4f>
  800d3e:	83 fb 10             	cmp    $0x10,%ebx
  800d41:	75 15                	jne    800d58 <strtol+0x64>
  800d43:	80 3a 30             	cmpb   $0x30,(%edx)
  800d46:	75 10                	jne    800d58 <strtol+0x64>
  800d48:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d4c:	75 0a                	jne    800d58 <strtol+0x64>
		s += 2, base = 16;
  800d4e:	83 c2 02             	add    $0x2,%edx
  800d51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d56:	eb 13                	jmp    800d6b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d58:	84 c0                	test   %al,%al
  800d5a:	74 0f                	je     800d6b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d61:	80 3a 30             	cmpb   $0x30,(%edx)
  800d64:	75 05                	jne    800d6b <strtol+0x77>
		s++, base = 8;
  800d66:	83 c2 01             	add    $0x1,%edx
  800d69:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d72:	0f b6 0a             	movzbl (%edx),%ecx
  800d75:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d78:	80 fb 09             	cmp    $0x9,%bl
  800d7b:	77 08                	ja     800d85 <strtol+0x91>
			dig = *s - '0';
  800d7d:	0f be c9             	movsbl %cl,%ecx
  800d80:	83 e9 30             	sub    $0x30,%ecx
  800d83:	eb 1e                	jmp    800da3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d85:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d88:	80 fb 19             	cmp    $0x19,%bl
  800d8b:	77 08                	ja     800d95 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d8d:	0f be c9             	movsbl %cl,%ecx
  800d90:	83 e9 57             	sub    $0x57,%ecx
  800d93:	eb 0e                	jmp    800da3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d95:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d98:	80 fb 19             	cmp    $0x19,%bl
  800d9b:	77 14                	ja     800db1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d9d:	0f be c9             	movsbl %cl,%ecx
  800da0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800da3:	39 f1                	cmp    %esi,%ecx
  800da5:	7d 0e                	jge    800db5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800da7:	83 c2 01             	add    $0x1,%edx
  800daa:	0f af c6             	imul   %esi,%eax
  800dad:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800daf:	eb c1                	jmp    800d72 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800db1:	89 c1                	mov    %eax,%ecx
  800db3:	eb 02                	jmp    800db7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800db5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800db7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dbb:	74 05                	je     800dc2 <strtol+0xce>
		*endptr = (char *) s;
  800dbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc2:	89 ca                	mov    %ecx,%edx
  800dc4:	f7 da                	neg    %edx
  800dc6:	85 ff                	test   %edi,%edi
  800dc8:	0f 45 c2             	cmovne %edx,%eax
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 c7                	mov    %eax,%edi
  800dee:	89 c6                	mov    %eax,%esi
  800df0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800df2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfb:	89 ec                	mov    %ebp,%esp
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_cgetc>:

int
sys_cgetc(void)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 0c             	sub    $0xc,%esp
  800e05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e13:	b8 01 00 00 00       	mov    $0x1,%eax
  800e18:	89 d1                	mov    %edx,%ecx
  800e1a:	89 d3                	mov    %edx,%ebx
  800e1c:	89 d7                	mov    %edx,%edi
  800e1e:	89 d6                	mov    %edx,%esi
  800e20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2b:	89 ec                	mov    %ebp,%esp
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 38             	sub    $0x38,%esp
  800e35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e43:	b8 03 00 00 00       	mov    $0x3,%eax
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	89 cb                	mov    %ecx,%ebx
  800e4d:	89 cf                	mov    %ecx,%edi
  800e4f:	89 ce                	mov    %ecx,%esi
  800e51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7e 28                	jle    800e7f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e62:	00 
  800e63:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e72:	00 
  800e73:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800e7a:	e8 1d f3 ff ff       	call   80019c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e98:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea5:	89 d1                	mov    %edx,%ecx
  800ea7:	89 d3                	mov    %edx,%ebx
  800ea9:	89 d7                	mov    %edx,%edi
  800eab:	89 d6                	mov    %edx,%esi
  800ead:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800eaf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb8:	89 ec                	mov    %ebp,%esp
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_yield>:

void
sys_yield(void)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed5:	89 d1                	mov    %edx,%ecx
  800ed7:	89 d3                	mov    %edx,%ebx
  800ed9:	89 d7                	mov    %edx,%edi
  800edb:	89 d6                	mov    %edx,%esi
  800edd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800edf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 38             	sub    $0x38,%esp
  800ef2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efb:	be 00 00 00 00       	mov    $0x0,%esi
  800f00:	b8 04 00 00 00       	mov    $0x4,%eax
  800f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	89 f7                	mov    %esi,%edi
  800f10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	7e 28                	jle    800f3e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800f39:	e8 5e f2 ff ff       	call   80019c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f47:	89 ec                	mov    %ebp,%esp
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 38             	sub    $0x38,%esp
  800f51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f57:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	7e 28                	jle    800f9c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f7f:	00 
  800f80:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800f87:	00 
  800f88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8f:	00 
  800f90:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800f97:	e8 00 f2 ff ff       	call   80019c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f9c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa5:	89 ec                	mov    %ebp,%esp
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 38             	sub    $0x38,%esp
  800faf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbd:	b8 06 00 00 00       	mov    $0x6,%eax
  800fc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc8:	89 df                	mov    %ebx,%edi
  800fca:	89 de                	mov    %ebx,%esi
  800fcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	7e 28                	jle    800ffa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fdd:	00 
  800fde:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800fe5:	00 
  800fe6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fed:	00 
  800fee:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800ff5:	e8 a2 f1 ff ff       	call   80019c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ffa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801000:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801003:	89 ec                	mov    %ebp,%esp
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 38             	sub    $0x38,%esp
  80100d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801010:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801013:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101b:	b8 08 00 00 00       	mov    $0x8,%eax
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 df                	mov    %ebx,%edi
  801028:	89 de                	mov    %ebx,%esi
  80102a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102c:	85 c0                	test   %eax,%eax
  80102e:	7e 28                	jle    801058 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801030:	89 44 24 10          	mov    %eax,0x10(%esp)
  801034:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80103b:	00 
  80103c:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  801043:	00 
  801044:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104b:	00 
  80104c:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  801053:	e8 44 f1 ff ff       	call   80019c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801058:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80105b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80105e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801061:	89 ec                	mov    %ebp,%esp
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 38             	sub    $0x38,%esp
  80106b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80106e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801071:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	bb 00 00 00 00       	mov    $0x0,%ebx
  801079:	b8 09 00 00 00       	mov    $0x9,%eax
  80107e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	89 df                	mov    %ebx,%edi
  801086:	89 de                	mov    %ebx,%esi
  801088:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108a:	85 c0                	test   %eax,%eax
  80108c:	7e 28                	jle    8010b6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801092:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801099:	00 
  80109a:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  8010a1:	00 
  8010a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a9:	00 
  8010aa:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8010b1:	e8 e6 f0 ff ff       	call   80019c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010bf:	89 ec                	mov    %ebp,%esp
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 38             	sub    $0x38,%esp
  8010c9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010cc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010cf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010df:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e2:	89 df                	mov    %ebx,%edi
  8010e4:	89 de                	mov    %ebx,%esi
  8010e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	7e 28                	jle    801114 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  8010ff:	00 
  801100:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801107:	00 
  801108:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  80110f:	e8 88 f0 ff ff       	call   80019c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801114:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801117:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80111a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80111d:	89 ec                	mov    %ebp,%esp
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80112a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80112d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801130:	be 00 00 00 00       	mov    $0x0,%esi
  801135:	b8 0c 00 00 00       	mov    $0xc,%eax
  80113a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80113d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801140:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801143:	8b 55 08             	mov    0x8(%ebp),%edx
  801146:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801148:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80114b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80114e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801151:	89 ec                	mov    %ebp,%esp
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 38             	sub    $0x38,%esp
  80115b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80115e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801161:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801164:	b9 00 00 00 00       	mov    $0x0,%ecx
  801169:	b8 0d 00 00 00       	mov    $0xd,%eax
  80116e:	8b 55 08             	mov    0x8(%ebp),%edx
  801171:	89 cb                	mov    %ecx,%ebx
  801173:	89 cf                	mov    %ecx,%edi
  801175:	89 ce                	mov    %ecx,%esi
  801177:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801179:	85 c0                	test   %eax,%eax
  80117b:	7e 28                	jle    8011a5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801181:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801188:	00 
  801189:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8011a0:	e8 f7 ef ff ff       	call   80019c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011a5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011a8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ae:	89 ec                	mov    %ebp,%esp
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011bb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011be:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ce:	89 cb                	mov    %ecx,%ebx
  8011d0:	89 cf                	mov    %ecx,%edi
  8011d2:	89 ce                	mov    %ecx,%esi
  8011d4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8011d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011df:	89 ec                	mov    %ebp,%esp
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    
	...

008011e4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 24             	sub    $0x24,%esp
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011ee:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  8011f0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011f4:	75 1c                	jne    801212 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  8011f6:	c7 44 24 08 6a 2c 80 	movl   $0x802c6a,0x8(%esp)
  8011fd:	00 
  8011fe:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801205:	00 
  801206:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80120d:	e8 8a ef ff ff       	call   80019c <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801212:	89 d8                	mov    %ebx,%eax
  801214:	c1 e8 0c             	shr    $0xc,%eax
  801217:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80121e:	f6 c4 08             	test   $0x8,%ah
  801221:	0f 84 be 00 00 00    	je     8012e5 <pgfault+0x101>
  801227:	89 d8                	mov    %ebx,%eax
  801229:	c1 e8 16             	shr    $0x16,%eax
  80122c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801233:	a8 01                	test   $0x1,%al
  801235:	0f 84 aa 00 00 00    	je     8012e5 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  80123b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801242:	00 
  801243:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80124a:	00 
  80124b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801252:	e8 95 fc ff ff       	call   800eec <sys_page_alloc>
		if (r < 0)
  801257:	85 c0                	test   %eax,%eax
  801259:	79 20                	jns    80127b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80125b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125f:	c7 44 24 08 a4 2c 80 	movl   $0x802ca4,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80126e:	00 
  80126f:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801276:	e8 21 ef ff ff       	call   80019c <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80127b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801281:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801288:	00 
  801289:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80128d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801294:	e8 bc f9 ff ff       	call   800c55 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801299:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012a0:	00 
  8012a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b4:	00 
  8012b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bc:	e8 8a fc ff ff       	call   800f4b <sys_page_map>
		if (r < 0)
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	79 3c                	jns    801301 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  8012c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c9:	c7 44 24 08 cc 2c 80 	movl   $0x802ccc,0x8(%esp)
  8012d0:	00 
  8012d1:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8012d8:	00 
  8012d9:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8012e0:	e8 b7 ee ff ff       	call   80019c <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  8012e5:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8012f4:	00 
  8012f5:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8012fc:	e8 9b ee ff ff       	call   80019c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801301:	83 c4 24             	add    $0x24,%esp
  801304:	5b                   	pop    %ebx
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	57                   	push   %edi
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801310:	c7 04 24 e4 11 80 00 	movl   $0x8011e4,(%esp)
  801317:	e8 c4 10 00 00       	call   8023e0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80131c:	bf 07 00 00 00       	mov    $0x7,%edi
  801321:	89 f8                	mov    %edi,%eax
  801323:	cd 30                	int    $0x30
  801325:	89 c7                	mov    %eax,%edi
  801327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80132a:	85 c0                	test   %eax,%eax
  80132c:	79 20                	jns    80134e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80132e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801332:	c7 44 24 08 10 2d 80 	movl   $0x802d10,0x8(%esp)
  801339:	00 
  80133a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801341:	00 
  801342:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801349:	e8 4e ee ff ff       	call   80019c <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80134e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801353:	85 c0                	test   %eax,%eax
  801355:	75 1c                	jne    801373 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801357:	e8 30 fb ff ff       	call   800e8c <sys_getenvid>
  80135c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801361:	c1 e0 07             	shl    $0x7,%eax
  801364:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801369:	a3 08 40 80 00       	mov    %eax,0x804008
		//cprintf("child fork ok!\n");
		return 0;
  80136e:	e9 51 02 00 00       	jmp    8015c4 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801373:	89 d8                	mov    %ebx,%eax
  801375:	c1 e8 16             	shr    $0x16,%eax
  801378:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137f:	a8 01                	test   $0x1,%al
  801381:	0f 84 87 01 00 00    	je     80150e <fork+0x207>
  801387:	89 d8                	mov    %ebx,%eax
  801389:	c1 e8 0c             	shr    $0xc,%eax
  80138c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801393:	f6 c2 01             	test   $0x1,%dl
  801396:	0f 84 72 01 00 00    	je     80150e <fork+0x207>
  80139c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a3:	f6 c2 04             	test   $0x4,%dl
  8013a6:	0f 84 62 01 00 00    	je     80150e <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8013ac:	89 c6                	mov    %eax,%esi
  8013ae:	c1 e6 0c             	shl    $0xc,%esi
  8013b1:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8013b7:	0f 84 51 01 00 00    	je     80150e <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  8013bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c4:	f6 c6 04             	test   $0x4,%dh
  8013c7:	74 53                	je     80141c <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8013c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ef:	e8 57 fb ff ff       	call   800f4b <sys_page_map>
		if (r < 0)
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	0f 89 12 01 00 00    	jns    80150e <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  8013fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801400:	c7 44 24 08 30 2d 80 	movl   $0x802d30,0x8(%esp)
  801407:	00 
  801408:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80140f:	00 
  801410:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801417:	e8 80 ed ff ff       	call   80019c <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80141c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801423:	f6 c2 02             	test   $0x2,%dl
  801426:	75 10                	jne    801438 <fork+0x131>
  801428:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142f:	f6 c4 08             	test   $0x8,%ah
  801432:	0f 84 8f 00 00 00    	je     8014c7 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801438:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80143f:	00 
  801440:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801444:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80144f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801456:	e8 f0 fa ff ff       	call   800f4b <sys_page_map>
		if (r < 0)
  80145b:	85 c0                	test   %eax,%eax
  80145d:	79 20                	jns    80147f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80145f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801463:	c7 44 24 08 5c 2d 80 	movl   $0x802d5c,0x8(%esp)
  80146a:	00 
  80146b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801472:	00 
  801473:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80147a:	e8 1d ed ff ff       	call   80019c <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80147f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801486:	00 
  801487:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80148b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801492:	00 
  801493:	89 74 24 04          	mov    %esi,0x4(%esp)
  801497:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149e:	e8 a8 fa ff ff       	call   800f4b <sys_page_map>
		if (r < 0)
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	79 67                	jns    80150e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8014a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ab:	c7 44 24 08 5c 2d 80 	movl   $0x802d5c,0x8(%esp)
  8014b2:	00 
  8014b3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8014ba:	00 
  8014bb:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8014c2:	e8 d5 ec ff ff       	call   80019c <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  8014c7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8014ce:	00 
  8014cf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e5:	e8 61 fa ff ff       	call   800f4b <sys_page_map>
		if (r < 0)
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	79 20                	jns    80150e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8014ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f2:	c7 44 24 08 5c 2d 80 	movl   $0x802d5c,0x8(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801501:	00 
  801502:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801509:	e8 8e ec ff ff       	call   80019c <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  80150e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801514:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80151a:	0f 85 53 fe ff ff    	jne    801373 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801520:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801527:	00 
  801528:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80152f:	ee 
  801530:	89 3c 24             	mov    %edi,(%esp)
  801533:	e8 b4 f9 ff ff       	call   800eec <sys_page_alloc>
	if (res < 0)
  801538:	85 c0                	test   %eax,%eax
  80153a:	79 20                	jns    80155c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  80153c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801540:	c7 44 24 08 80 2d 80 	movl   $0x802d80,0x8(%esp)
  801547:	00 
  801548:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80154f:	00 
  801550:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801557:	e8 40 ec ff ff       	call   80019c <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80155c:	c7 44 24 04 6c 24 80 	movl   $0x80246c,0x4(%esp)
  801563:	00 
  801564:	89 3c 24             	mov    %edi,(%esp)
  801567:	e8 57 fb ff ff       	call   8010c3 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80156c:	85 c0                	test   %eax,%eax
  80156e:	79 20                	jns    801590 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801570:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801574:	c7 44 24 08 a4 2d 80 	movl   $0x802da4,0x8(%esp)
  80157b:	00 
  80157c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801583:	00 
  801584:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80158b:	e8 0c ec ff ff       	call   80019c <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801590:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801597:	00 
  801598:	89 3c 24             	mov    %edi,(%esp)
  80159b:	e8 67 fa ff ff       	call   801007 <sys_env_set_status>
	if (res < 0)
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	79 20                	jns    8015c4 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  8015a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a8:	c7 44 24 08 d4 2d 80 	movl   $0x802dd4,0x8(%esp)
  8015af:	00 
  8015b0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  8015b7:	00 
  8015b8:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8015bf:	e8 d8 eb ff ff       	call   80019c <_panic>

	return pid;
	//panic("fork not implemented");
}
  8015c4:	89 f8                	mov    %edi,%eax
  8015c6:	83 c4 3c             	add    $0x3c,%esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5e                   	pop    %esi
  8015cb:	5f                   	pop    %edi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <sfork>:

// Challenge!
int
sfork(void)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8015d4:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  8015db:	00 
  8015dc:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8015e3:	00 
  8015e4:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8015eb:	e8 ac eb ff ff       	call   80019c <_panic>

008015f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801606:	8b 45 08             	mov    0x8(%ebp),%eax
  801609:	89 04 24             	mov    %eax,(%esp)
  80160c:	e8 df ff ff ff       	call   8015f0 <fd2num>
  801611:	05 20 00 0d 00       	add    $0xd0020,%eax
  801616:	c1 e0 0c             	shl    $0xc,%eax
}
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	53                   	push   %ebx
  80161f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801622:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801627:	a8 01                	test   $0x1,%al
  801629:	74 34                	je     80165f <fd_alloc+0x44>
  80162b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801630:	a8 01                	test   $0x1,%al
  801632:	74 32                	je     801666 <fd_alloc+0x4b>
  801634:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801639:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80163b:	89 c2                	mov    %eax,%edx
  80163d:	c1 ea 16             	shr    $0x16,%edx
  801640:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801647:	f6 c2 01             	test   $0x1,%dl
  80164a:	74 1f                	je     80166b <fd_alloc+0x50>
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	c1 ea 0c             	shr    $0xc,%edx
  801651:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801658:	f6 c2 01             	test   $0x1,%dl
  80165b:	75 17                	jne    801674 <fd_alloc+0x59>
  80165d:	eb 0c                	jmp    80166b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80165f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801664:	eb 05                	jmp    80166b <fd_alloc+0x50>
  801666:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80166b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80166d:	b8 00 00 00 00       	mov    $0x0,%eax
  801672:	eb 17                	jmp    80168b <fd_alloc+0x70>
  801674:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801679:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80167e:	75 b9                	jne    801639 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801680:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801686:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80168b:	5b                   	pop    %ebx
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801694:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801699:	83 fa 1f             	cmp    $0x1f,%edx
  80169c:	77 3f                	ja     8016dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80169e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8016a4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	c1 e8 16             	shr    $0x16,%eax
  8016ac:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016b8:	f6 c1 01             	test   $0x1,%cl
  8016bb:	74 20                	je     8016dd <fd_lookup+0x4f>
  8016bd:	89 d0                	mov    %edx,%eax
  8016bf:	c1 e8 0c             	shr    $0xc,%eax
  8016c2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016ce:	f6 c1 01             	test   $0x1,%cl
  8016d1:	74 0a                	je     8016dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016dd:	5d                   	pop    %ebp
  8016de:	c3                   	ret    

008016df <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 14             	sub    $0x14,%esp
  8016e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016ec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8016f1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8016f7:	75 17                	jne    801710 <dev_lookup+0x31>
  8016f9:	eb 07                	jmp    801702 <dev_lookup+0x23>
  8016fb:	39 0a                	cmp    %ecx,(%edx)
  8016fd:	75 11                	jne    801710 <dev_lookup+0x31>
  8016ff:	90                   	nop
  801700:	eb 05                	jmp    801707 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801702:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801707:	89 13                	mov    %edx,(%ebx)
			return 0;
  801709:	b8 00 00 00 00       	mov    $0x0,%eax
  80170e:	eb 35                	jmp    801745 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801710:	83 c0 01             	add    $0x1,%eax
  801713:	8b 14 85 78 2e 80 00 	mov    0x802e78(,%eax,4),%edx
  80171a:	85 d2                	test   %edx,%edx
  80171c:	75 dd                	jne    8016fb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80171e:	a1 08 40 80 00       	mov    0x804008,%eax
  801723:	8b 40 48             	mov    0x48(%eax),%eax
  801726:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80172a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172e:	c7 04 24 fc 2d 80 00 	movl   $0x802dfc,(%esp)
  801735:	e8 5d eb ff ff       	call   800297 <cprintf>
	*dev = 0;
  80173a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801745:	83 c4 14             	add    $0x14,%esp
  801748:	5b                   	pop    %ebx
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 38             	sub    $0x38,%esp
  801751:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801754:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801757:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80175a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80175d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801761:	89 3c 24             	mov    %edi,(%esp)
  801764:	e8 87 fe ff ff       	call   8015f0 <fd2num>
  801769:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80176c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	e8 16 ff ff ff       	call   80168e <fd_lookup>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 05                	js     801783 <fd_close+0x38>
	    || fd != fd2)
  80177e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801781:	74 0e                	je     801791 <fd_close+0x46>
		return (must_exist ? r : 0);
  801783:	89 f0                	mov    %esi,%eax
  801785:	84 c0                	test   %al,%al
  801787:	b8 00 00 00 00       	mov    $0x0,%eax
  80178c:	0f 44 d8             	cmove  %eax,%ebx
  80178f:	eb 3d                	jmp    8017ce <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801791:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801794:	89 44 24 04          	mov    %eax,0x4(%esp)
  801798:	8b 07                	mov    (%edi),%eax
  80179a:	89 04 24             	mov    %eax,(%esp)
  80179d:	e8 3d ff ff ff       	call   8016df <dev_lookup>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 16                	js     8017be <fd_close+0x73>
		if (dev->dev_close)
  8017a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8017ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	74 07                	je     8017be <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8017b7:	89 3c 24             	mov    %edi,(%esp)
  8017ba:	ff d0                	call   *%eax
  8017bc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c9:	e8 db f7 ff ff       	call   800fa9 <sys_page_unmap>
	return r;
}
  8017ce:	89 d8                	mov    %ebx,%eax
  8017d0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017d3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017d9:	89 ec                	mov    %ebp,%esp
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 99 fe ff ff       	call   80168e <fd_lookup>
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 13                	js     80180c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801800:	00 
  801801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	e8 3f ff ff ff       	call   80174b <fd_close>
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <close_all>:

void
close_all(void)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801815:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80181a:	89 1c 24             	mov    %ebx,(%esp)
  80181d:	e8 bb ff ff ff       	call   8017dd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801822:	83 c3 01             	add    $0x1,%ebx
  801825:	83 fb 20             	cmp    $0x20,%ebx
  801828:	75 f0                	jne    80181a <close_all+0xc>
		close(i);
}
  80182a:	83 c4 14             	add    $0x14,%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 58             	sub    $0x58,%esp
  801836:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801839:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80183c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80183f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801842:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	89 04 24             	mov    %eax,(%esp)
  80184f:	e8 3a fe ff ff       	call   80168e <fd_lookup>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	85 c0                	test   %eax,%eax
  801858:	0f 88 e1 00 00 00    	js     80193f <dup+0x10f>
		return r;
	close(newfdnum);
  80185e:	89 3c 24             	mov    %edi,(%esp)
  801861:	e8 77 ff ff ff       	call   8017dd <close>

	newfd = INDEX2FD(newfdnum);
  801866:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80186c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80186f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801872:	89 04 24             	mov    %eax,(%esp)
  801875:	e8 86 fd ff ff       	call   801600 <fd2data>
  80187a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80187c:	89 34 24             	mov    %esi,(%esp)
  80187f:	e8 7c fd ff ff       	call   801600 <fd2data>
  801884:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801887:	89 d8                	mov    %ebx,%eax
  801889:	c1 e8 16             	shr    $0x16,%eax
  80188c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801893:	a8 01                	test   $0x1,%al
  801895:	74 46                	je     8018dd <dup+0xad>
  801897:	89 d8                	mov    %ebx,%eax
  801899:	c1 e8 0c             	shr    $0xc,%eax
  80189c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018a3:	f6 c2 01             	test   $0x1,%dl
  8018a6:	74 35                	je     8018dd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018af:	25 07 0e 00 00       	and    $0xe07,%eax
  8018b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018c6:	00 
  8018c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d2:	e8 74 f6 ff ff       	call   800f4b <sys_page_map>
  8018d7:	89 c3                	mov    %eax,%ebx
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 3b                	js     801918 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e0:	89 c2                	mov    %eax,%edx
  8018e2:	c1 ea 0c             	shr    $0xc,%edx
  8018e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018f6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801901:	00 
  801902:	89 44 24 04          	mov    %eax,0x4(%esp)
  801906:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190d:	e8 39 f6 ff ff       	call   800f4b <sys_page_map>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	85 c0                	test   %eax,%eax
  801916:	79 25                	jns    80193d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801918:	89 74 24 04          	mov    %esi,0x4(%esp)
  80191c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801923:	e8 81 f6 ff ff       	call   800fa9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801928:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80192b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801936:	e8 6e f6 ff ff       	call   800fa9 <sys_page_unmap>
	return r;
  80193b:	eb 02                	jmp    80193f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80193d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80193f:	89 d8                	mov    %ebx,%eax
  801941:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801944:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801947:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80194a:	89 ec                	mov    %ebp,%esp
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 24             	sub    $0x24,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801958:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195f:	89 1c 24             	mov    %ebx,(%esp)
  801962:	e8 27 fd ff ff       	call   80168e <fd_lookup>
  801967:	85 c0                	test   %eax,%eax
  801969:	78 6d                	js     8019d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801972:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801975:	8b 00                	mov    (%eax),%eax
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 60 fd ff ff       	call   8016df <dev_lookup>
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 55                	js     8019d8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801986:	8b 50 08             	mov    0x8(%eax),%edx
  801989:	83 e2 03             	and    $0x3,%edx
  80198c:	83 fa 01             	cmp    $0x1,%edx
  80198f:	75 23                	jne    8019b4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801991:	a1 08 40 80 00       	mov    0x804008,%eax
  801996:	8b 40 48             	mov    0x48(%eax),%eax
  801999:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	c7 04 24 3d 2e 80 00 	movl   $0x802e3d,(%esp)
  8019a8:	e8 ea e8 ff ff       	call   800297 <cprintf>
		return -E_INVAL;
  8019ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b2:	eb 24                	jmp    8019d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8019b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b7:	8b 52 08             	mov    0x8(%edx),%edx
  8019ba:	85 d2                	test   %edx,%edx
  8019bc:	74 15                	je     8019d3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8019be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	ff d2                	call   *%edx
  8019d1:	eb 05                	jmp    8019d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8019d8:	83 c4 24             	add    $0x24,%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	57                   	push   %edi
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 1c             	sub    $0x1c,%esp
  8019e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f2:	85 f6                	test   %esi,%esi
  8019f4:	74 30                	je     801a26 <readn+0x48>
  8019f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019fb:	89 f2                	mov    %esi,%edx
  8019fd:	29 c2                	sub    %eax,%edx
  8019ff:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a03:	03 45 0c             	add    0xc(%ebp),%eax
  801a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0a:	89 3c 24             	mov    %edi,(%esp)
  801a0d:	e8 3c ff ff ff       	call   80194e <read>
		if (m < 0)
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 10                	js     801a26 <readn+0x48>
			return m;
		if (m == 0)
  801a16:	85 c0                	test   %eax,%eax
  801a18:	74 0a                	je     801a24 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a1a:	01 c3                	add    %eax,%ebx
  801a1c:	89 d8                	mov    %ebx,%eax
  801a1e:	39 f3                	cmp    %esi,%ebx
  801a20:	72 d9                	jb     8019fb <readn+0x1d>
  801a22:	eb 02                	jmp    801a26 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a24:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a26:	83 c4 1c             	add    $0x1c,%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5f                   	pop    %edi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	53                   	push   %ebx
  801a32:	83 ec 24             	sub    $0x24,%esp
  801a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3f:	89 1c 24             	mov    %ebx,(%esp)
  801a42:	e8 47 fc ff ff       	call   80168e <fd_lookup>
  801a47:	85 c0                	test   %eax,%eax
  801a49:	78 68                	js     801ab3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a55:	8b 00                	mov    (%eax),%eax
  801a57:	89 04 24             	mov    %eax,(%esp)
  801a5a:	e8 80 fc ff ff       	call   8016df <dev_lookup>
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 50                	js     801ab3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a66:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a6a:	75 23                	jne    801a8f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a6c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a71:	8b 40 48             	mov    0x48(%eax),%eax
  801a74:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7c:	c7 04 24 59 2e 80 00 	movl   $0x802e59,(%esp)
  801a83:	e8 0f e8 ff ff       	call   800297 <cprintf>
		return -E_INVAL;
  801a88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a8d:	eb 24                	jmp    801ab3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a92:	8b 52 0c             	mov    0xc(%edx),%edx
  801a95:	85 d2                	test   %edx,%edx
  801a97:	74 15                	je     801aae <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a99:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a9c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aa7:	89 04 24             	mov    %eax,(%esp)
  801aaa:	ff d2                	call   *%edx
  801aac:	eb 05                	jmp    801ab3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801aae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801ab3:	83 c4 24             	add    $0x24,%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801abf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	89 04 24             	mov    %eax,(%esp)
  801acc:	e8 bd fb ff ff       	call   80168e <fd_lookup>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 0e                	js     801ae3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ad5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801adb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 24             	sub    $0x24,%esp
  801aec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af6:	89 1c 24             	mov    %ebx,(%esp)
  801af9:	e8 90 fb ff ff       	call   80168e <fd_lookup>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 61                	js     801b63 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0c:	8b 00                	mov    (%eax),%eax
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 c9 fb ff ff       	call   8016df <dev_lookup>
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 49                	js     801b63 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b21:	75 23                	jne    801b46 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b23:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b28:	8b 40 48             	mov    0x48(%eax),%eax
  801b2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b33:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801b3a:	e8 58 e7 ff ff       	call   800297 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b44:	eb 1d                	jmp    801b63 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b49:	8b 52 18             	mov    0x18(%edx),%edx
  801b4c:	85 d2                	test   %edx,%edx
  801b4e:	74 0e                	je     801b5e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b53:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b57:	89 04 24             	mov    %eax,(%esp)
  801b5a:	ff d2                	call   *%edx
  801b5c:	eb 05                	jmp    801b63 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b5e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b63:	83 c4 24             	add    $0x24,%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 24             	sub    $0x24,%esp
  801b70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	89 04 24             	mov    %eax,(%esp)
  801b80:	e8 09 fb ff ff       	call   80168e <fd_lookup>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 52                	js     801bdb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b93:	8b 00                	mov    (%eax),%eax
  801b95:	89 04 24             	mov    %eax,(%esp)
  801b98:	e8 42 fb ff ff       	call   8016df <dev_lookup>
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 3a                	js     801bdb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ba8:	74 2c                	je     801bd6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801baa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bb4:	00 00 00 
	stat->st_isdir = 0;
  801bb7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bbe:	00 00 00 
	stat->st_dev = dev;
  801bc1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bce:	89 14 24             	mov    %edx,(%esp)
  801bd1:	ff 50 14             	call   *0x14(%eax)
  801bd4:	eb 05                	jmp    801bdb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801bd6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bdb:	83 c4 24             	add    $0x24,%esp
  801bde:	5b                   	pop    %ebx
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	83 ec 18             	sub    $0x18,%esp
  801be7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bea:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bf4:	00 
  801bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 bc 01 00 00       	call   801dbc <open>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 1b                	js     801c21 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	89 1c 24             	mov    %ebx,(%esp)
  801c10:	e8 54 ff ff ff       	call   801b69 <fstat>
  801c15:	89 c6                	mov    %eax,%esi
	close(fd);
  801c17:	89 1c 24             	mov    %ebx,(%esp)
  801c1a:	e8 be fb ff ff       	call   8017dd <close>
	return r;
  801c1f:	89 f3                	mov    %esi,%ebx
}
  801c21:	89 d8                	mov    %ebx,%eax
  801c23:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c26:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c29:	89 ec                	mov    %ebp,%esp
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    
  801c2d:	00 00                	add    %al,(%eax)
	...

00801c30 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 18             	sub    $0x18,%esp
  801c36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c39:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c40:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c47:	75 11                	jne    801c5a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c50:	e8 0c 09 00 00       	call   802561 <ipc_find_env>
  801c55:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c5a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c61:	00 
  801c62:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c69:	00 
  801c6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c6e:	a1 00 40 80 00       	mov    0x804000,%eax
  801c73:	89 04 24             	mov    %eax,(%esp)
  801c76:	e8 7b 08 00 00       	call   8024f6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801c7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c82:	00 
  801c83:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8e:	e8 fd 07 00 00       	call   802490 <ipc_recv>
}
  801c93:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c96:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c99:	89 ec                	mov    %ebp,%esp
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	53                   	push   %ebx
  801ca1:	83 ec 14             	sub    $0x14,%esp
  801ca4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	8b 40 0c             	mov    0xc(%eax),%eax
  801cad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb7:	b8 05 00 00 00       	mov    $0x5,%eax
  801cbc:	e8 6f ff ff ff       	call   801c30 <fsipc>
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	78 2b                	js     801cf0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cc5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ccc:	00 
  801ccd:	89 1c 24             	mov    %ebx,(%esp)
  801cd0:	e8 16 ed ff ff       	call   8009eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cd5:	a1 80 50 80 00       	mov    0x805080,%eax
  801cda:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ce0:	a1 84 50 80 00       	mov    0x805084,%eax
  801ce5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf0:	83 c4 14             	add    $0x14,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    

00801cf6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	8b 40 0c             	mov    0xc(%eax),%eax
  801d02:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d07:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  801d11:	e8 1a ff ff ff       	call   801c30 <fsipc>
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 10             	sub    $0x10,%esp
  801d20:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	8b 40 0c             	mov    0xc(%eax),%eax
  801d29:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d2e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d34:	ba 00 00 00 00       	mov    $0x0,%edx
  801d39:	b8 03 00 00 00       	mov    $0x3,%eax
  801d3e:	e8 ed fe ff ff       	call   801c30 <fsipc>
  801d43:	89 c3                	mov    %eax,%ebx
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 6a                	js     801db3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 24                	jae    801d71 <devfile_read+0x59>
  801d4d:	c7 44 24 0c 88 2e 80 	movl   $0x802e88,0xc(%esp)
  801d54:	00 
  801d55:	c7 44 24 08 8f 2e 80 	movl   $0x802e8f,0x8(%esp)
  801d5c:	00 
  801d5d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801d64:	00 
  801d65:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  801d6c:	e8 2b e4 ff ff       	call   80019c <_panic>
	assert(r <= PGSIZE);
  801d71:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d76:	7e 24                	jle    801d9c <devfile_read+0x84>
  801d78:	c7 44 24 0c af 2e 80 	movl   $0x802eaf,0xc(%esp)
  801d7f:	00 
  801d80:	c7 44 24 08 8f 2e 80 	movl   $0x802e8f,0x8(%esp)
  801d87:	00 
  801d88:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801d8f:	00 
  801d90:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  801d97:	e8 00 e4 ff ff       	call   80019c <_panic>
	memmove(buf, &fsipcbuf, r);
  801d9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801da7:	00 
  801da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dab:	89 04 24             	mov    %eax,(%esp)
  801dae:	e8 29 ee ff ff       	call   800bdc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801db3:	89 d8                	mov    %ebx,%eax
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	83 ec 20             	sub    $0x20,%esp
  801dc4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801dc7:	89 34 24             	mov    %esi,(%esp)
  801dca:	e8 d1 eb ff ff       	call   8009a0 <strlen>
		return -E_BAD_PATH;
  801dcf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801dd4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dd9:	7f 5e                	jg     801e39 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ddb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dde:	89 04 24             	mov    %eax,(%esp)
  801de1:	e8 35 f8 ff ff       	call   80161b <fd_alloc>
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 4d                	js     801e39 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801dec:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801df7:	e8 ef eb ff ff       	call   8009eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e07:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0c:	e8 1f fe ff ff       	call   801c30 <fsipc>
  801e11:	89 c3                	mov    %eax,%ebx
  801e13:	85 c0                	test   %eax,%eax
  801e15:	79 15                	jns    801e2c <open+0x70>
		fd_close(fd, 0);
  801e17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e1e:	00 
  801e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e22:	89 04 24             	mov    %eax,(%esp)
  801e25:	e8 21 f9 ff ff       	call   80174b <fd_close>
		return r;
  801e2a:	eb 0d                	jmp    801e39 <open+0x7d>
	}

	return fd2num(fd);
  801e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2f:	89 04 24             	mov    %eax,(%esp)
  801e32:	e8 b9 f7 ff ff       	call   8015f0 <fd2num>
  801e37:	89 c3                	mov    %eax,%ebx
}
  801e39:	89 d8                	mov    %ebx,%eax
  801e3b:	83 c4 20             	add    $0x20,%esp
  801e3e:	5b                   	pop    %ebx
  801e3f:	5e                   	pop    %esi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    
	...

00801e50 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 18             	sub    $0x18,%esp
  801e56:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e59:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e5c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e62:	89 04 24             	mov    %eax,(%esp)
  801e65:	e8 96 f7 ff ff       	call   801600 <fd2data>
  801e6a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e6c:	c7 44 24 04 bb 2e 80 	movl   $0x802ebb,0x4(%esp)
  801e73:	00 
  801e74:	89 34 24             	mov    %esi,(%esp)
  801e77:	e8 6f eb ff ff       	call   8009eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e7f:	2b 03                	sub    (%ebx),%eax
  801e81:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e87:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e8e:	00 00 00 
	stat->st_dev = &devpipe;
  801e91:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801e98:	30 80 00 
	return 0;
}
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ea3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ea6:	89 ec                	mov    %ebp,%esp
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	53                   	push   %ebx
  801eae:	83 ec 14             	sub    $0x14,%esp
  801eb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebf:	e8 e5 f0 ff ff       	call   800fa9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ec4:	89 1c 24             	mov    %ebx,(%esp)
  801ec7:	e8 34 f7 ff ff       	call   801600 <fd2data>
  801ecc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed7:	e8 cd f0 ff ff       	call   800fa9 <sys_page_unmap>
}
  801edc:	83 c4 14             	add    $0x14,%esp
  801edf:	5b                   	pop    %ebx
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	57                   	push   %edi
  801ee6:	56                   	push   %esi
  801ee7:	53                   	push   %ebx
  801ee8:	83 ec 2c             	sub    $0x2c,%esp
  801eeb:	89 c7                	mov    %eax,%edi
  801eed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef0:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ef8:	89 3c 24             	mov    %edi,(%esp)
  801efb:	e8 ac 06 00 00       	call   8025ac <pageref>
  801f00:	89 c6                	mov    %eax,%esi
  801f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f05:	89 04 24             	mov    %eax,(%esp)
  801f08:	e8 9f 06 00 00       	call   8025ac <pageref>
  801f0d:	39 c6                	cmp    %eax,%esi
  801f0f:	0f 94 c0             	sete   %al
  801f12:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f15:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f1b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f1e:	39 cb                	cmp    %ecx,%ebx
  801f20:	75 08                	jne    801f2a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f22:	83 c4 2c             	add    $0x2c,%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f2a:	83 f8 01             	cmp    $0x1,%eax
  801f2d:	75 c1                	jne    801ef0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f2f:	8b 52 58             	mov    0x58(%edx),%edx
  801f32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f36:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f3e:	c7 04 24 c2 2e 80 00 	movl   $0x802ec2,(%esp)
  801f45:	e8 4d e3 ff ff       	call   800297 <cprintf>
  801f4a:	eb a4                	jmp    801ef0 <_pipeisclosed+0xe>

00801f4c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	57                   	push   %edi
  801f50:	56                   	push   %esi
  801f51:	53                   	push   %ebx
  801f52:	83 ec 2c             	sub    $0x2c,%esp
  801f55:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f58:	89 34 24             	mov    %esi,(%esp)
  801f5b:	e8 a0 f6 ff ff       	call   801600 <fd2data>
  801f60:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f62:	bf 00 00 00 00       	mov    $0x0,%edi
  801f67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f6b:	75 50                	jne    801fbd <devpipe_write+0x71>
  801f6d:	eb 5c                	jmp    801fcb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f6f:	89 da                	mov    %ebx,%edx
  801f71:	89 f0                	mov    %esi,%eax
  801f73:	e8 6a ff ff ff       	call   801ee2 <_pipeisclosed>
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	75 53                	jne    801fcf <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f7c:	e8 3b ef ff ff       	call   800ebc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f81:	8b 43 04             	mov    0x4(%ebx),%eax
  801f84:	8b 13                	mov    (%ebx),%edx
  801f86:	83 c2 20             	add    $0x20,%edx
  801f89:	39 d0                	cmp    %edx,%eax
  801f8b:	73 e2                	jae    801f6f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f90:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801f94:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801f97:	89 c2                	mov    %eax,%edx
  801f99:	c1 fa 1f             	sar    $0x1f,%edx
  801f9c:	c1 ea 1b             	shr    $0x1b,%edx
  801f9f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801fa2:	83 e1 1f             	and    $0x1f,%ecx
  801fa5:	29 d1                	sub    %edx,%ecx
  801fa7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801fab:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801faf:	83 c0 01             	add    $0x1,%eax
  801fb2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb5:	83 c7 01             	add    $0x1,%edi
  801fb8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fbb:	74 0e                	je     801fcb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fbd:	8b 43 04             	mov    0x4(%ebx),%eax
  801fc0:	8b 13                	mov    (%ebx),%edx
  801fc2:	83 c2 20             	add    $0x20,%edx
  801fc5:	39 d0                	cmp    %edx,%eax
  801fc7:	73 a6                	jae    801f6f <devpipe_write+0x23>
  801fc9:	eb c2                	jmp    801f8d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fcb:	89 f8                	mov    %edi,%eax
  801fcd:	eb 05                	jmp    801fd4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fd4:	83 c4 2c             	add    $0x2c,%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5f                   	pop    %edi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	83 ec 28             	sub    $0x28,%esp
  801fe2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fe5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fe8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801feb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fee:	89 3c 24             	mov    %edi,(%esp)
  801ff1:	e8 0a f6 ff ff       	call   801600 <fd2data>
  801ff6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff8:	be 00 00 00 00       	mov    $0x0,%esi
  801ffd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802001:	75 47                	jne    80204a <devpipe_read+0x6e>
  802003:	eb 52                	jmp    802057 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802005:	89 f0                	mov    %esi,%eax
  802007:	eb 5e                	jmp    802067 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802009:	89 da                	mov    %ebx,%edx
  80200b:	89 f8                	mov    %edi,%eax
  80200d:	8d 76 00             	lea    0x0(%esi),%esi
  802010:	e8 cd fe ff ff       	call   801ee2 <_pipeisclosed>
  802015:	85 c0                	test   %eax,%eax
  802017:	75 49                	jne    802062 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802019:	e8 9e ee ff ff       	call   800ebc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80201e:	8b 03                	mov    (%ebx),%eax
  802020:	3b 43 04             	cmp    0x4(%ebx),%eax
  802023:	74 e4                	je     802009 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802025:	89 c2                	mov    %eax,%edx
  802027:	c1 fa 1f             	sar    $0x1f,%edx
  80202a:	c1 ea 1b             	shr    $0x1b,%edx
  80202d:	01 d0                	add    %edx,%eax
  80202f:	83 e0 1f             	and    $0x1f,%eax
  802032:	29 d0                	sub    %edx,%eax
  802034:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802039:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80203f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802042:	83 c6 01             	add    $0x1,%esi
  802045:	3b 75 10             	cmp    0x10(%ebp),%esi
  802048:	74 0d                	je     802057 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80204a:	8b 03                	mov    (%ebx),%eax
  80204c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80204f:	75 d4                	jne    802025 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802051:	85 f6                	test   %esi,%esi
  802053:	75 b0                	jne    802005 <devpipe_read+0x29>
  802055:	eb b2                	jmp    802009 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802057:	89 f0                	mov    %esi,%eax
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	eb 05                	jmp    802067 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802062:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802067:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80206a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80206d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802070:	89 ec                	mov    %ebp,%esp
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 48             	sub    $0x48,%esp
  80207a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80207d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802080:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802083:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802086:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802089:	89 04 24             	mov    %eax,(%esp)
  80208c:	e8 8a f5 ff ff       	call   80161b <fd_alloc>
  802091:	89 c3                	mov    %eax,%ebx
  802093:	85 c0                	test   %eax,%eax
  802095:	0f 88 45 01 00 00    	js     8021e0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020a2:	00 
  8020a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b1:	e8 36 ee ff ff       	call   800eec <sys_page_alloc>
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	0f 88 20 01 00 00    	js     8021e0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8020c3:	89 04 24             	mov    %eax,(%esp)
  8020c6:	e8 50 f5 ff ff       	call   80161b <fd_alloc>
  8020cb:	89 c3                	mov    %eax,%ebx
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	0f 88 f8 00 00 00    	js     8021cd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020dc:	00 
  8020dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020eb:	e8 fc ed ff ff       	call   800eec <sys_page_alloc>
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	0f 88 d3 00 00 00    	js     8021cd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020fd:	89 04 24             	mov    %eax,(%esp)
  802100:	e8 fb f4 ff ff       	call   801600 <fd2data>
  802105:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802107:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80210e:	00 
  80210f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802113:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211a:	e8 cd ed ff ff       	call   800eec <sys_page_alloc>
  80211f:	89 c3                	mov    %eax,%ebx
  802121:	85 c0                	test   %eax,%eax
  802123:	0f 88 91 00 00 00    	js     8021ba <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802129:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80212c:	89 04 24             	mov    %eax,(%esp)
  80212f:	e8 cc f4 ff ff       	call   801600 <fd2data>
  802134:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80213b:	00 
  80213c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802140:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802147:	00 
  802148:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802153:	e8 f3 ed ff ff       	call   800f4b <sys_page_map>
  802158:	89 c3                	mov    %eax,%ebx
  80215a:	85 c0                	test   %eax,%eax
  80215c:	78 4c                	js     8021aa <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80215e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802164:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802167:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80216c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802173:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802179:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80217c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80217e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802181:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218b:	89 04 24             	mov    %eax,(%esp)
  80218e:	e8 5d f4 ff ff       	call   8015f0 <fd2num>
  802193:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802195:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802198:	89 04 24             	mov    %eax,(%esp)
  80219b:	e8 50 f4 ff ff       	call   8015f0 <fd2num>
  8021a0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8021a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021a8:	eb 36                	jmp    8021e0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8021aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b5:	e8 ef ed ff ff       	call   800fa9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8021ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c8:	e8 dc ed ff ff       	call   800fa9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8021cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021db:	e8 c9 ed ff ff       	call   800fa9 <sys_page_unmap>
    err:
	return r;
}
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8021e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8021e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8021eb:	89 ec                	mov    %ebp,%esp
  8021ed:	5d                   	pop    %ebp
  8021ee:	c3                   	ret    

008021ef <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ff:	89 04 24             	mov    %eax,(%esp)
  802202:	e8 87 f4 ff ff       	call   80168e <fd_lookup>
  802207:	85 c0                	test   %eax,%eax
  802209:	78 15                	js     802220 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80220b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220e:	89 04 24             	mov    %eax,(%esp)
  802211:	e8 ea f3 ff ff       	call   801600 <fd2data>
	return _pipeisclosed(fd, p);
  802216:	89 c2                	mov    %eax,%edx
  802218:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221b:	e8 c2 fc ff ff       	call   801ee2 <_pipeisclosed>
}
  802220:	c9                   	leave  
  802221:	c3                   	ret    
	...

00802230 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802233:	b8 00 00 00 00       	mov    $0x0,%eax
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    

0080223a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802240:	c7 44 24 04 da 2e 80 	movl   $0x802eda,0x4(%esp)
  802247:	00 
  802248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224b:	89 04 24             	mov    %eax,(%esp)
  80224e:	e8 98 e7 ff ff       	call   8009eb <strcpy>
	return 0;
}
  802253:	b8 00 00 00 00       	mov    $0x0,%eax
  802258:	c9                   	leave  
  802259:	c3                   	ret    

0080225a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80225a:	55                   	push   %ebp
  80225b:	89 e5                	mov    %esp,%ebp
  80225d:	57                   	push   %edi
  80225e:	56                   	push   %esi
  80225f:	53                   	push   %ebx
  802260:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802266:	be 00 00 00 00       	mov    $0x0,%esi
  80226b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80226f:	74 43                	je     8022b4 <devcons_write+0x5a>
  802271:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802276:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80227c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80227f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802281:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802284:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802289:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80228c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802290:	03 45 0c             	add    0xc(%ebp),%eax
  802293:	89 44 24 04          	mov    %eax,0x4(%esp)
  802297:	89 3c 24             	mov    %edi,(%esp)
  80229a:	e8 3d e9 ff ff       	call   800bdc <memmove>
		sys_cputs(buf, m);
  80229f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022a3:	89 3c 24             	mov    %edi,(%esp)
  8022a6:	e8 25 eb ff ff       	call   800dd0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ab:	01 de                	add    %ebx,%esi
  8022ad:	89 f0                	mov    %esi,%eax
  8022af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022b2:	72 c8                	jb     80227c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022b4:	89 f0                	mov    %esi,%eax
  8022b6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5e                   	pop    %esi
  8022be:	5f                   	pop    %edi
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    

008022c1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
  8022c4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8022c7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8022cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022d0:	75 07                	jne    8022d9 <devcons_read+0x18>
  8022d2:	eb 31                	jmp    802305 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022d4:	e8 e3 eb ff ff       	call   800ebc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	e8 1a eb ff ff       	call   800dff <sys_cgetc>
  8022e5:	85 c0                	test   %eax,%eax
  8022e7:	74 eb                	je     8022d4 <devcons_read+0x13>
  8022e9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	78 16                	js     802305 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022ef:	83 f8 04             	cmp    $0x4,%eax
  8022f2:	74 0c                	je     802300 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8022f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f7:	88 10                	mov    %dl,(%eax)
	return 1;
  8022f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fe:	eb 05                	jmp    802305 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802300:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80230d:	8b 45 08             	mov    0x8(%ebp),%eax
  802310:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802313:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80231a:	00 
  80231b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80231e:	89 04 24             	mov    %eax,(%esp)
  802321:	e8 aa ea ff ff       	call   800dd0 <sys_cputs>
}
  802326:	c9                   	leave  
  802327:	c3                   	ret    

00802328 <getchar>:

int
getchar(void)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80232e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802335:	00 
  802336:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802344:	e8 05 f6 ff ff       	call   80194e <read>
	if (r < 0)
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 0f                	js     80235c <getchar+0x34>
		return r;
	if (r < 1)
  80234d:	85 c0                	test   %eax,%eax
  80234f:	7e 06                	jle    802357 <getchar+0x2f>
		return -E_EOF;
	return c;
  802351:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802355:	eb 05                	jmp    80235c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802357:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80235c:	c9                   	leave  
  80235d:	c3                   	ret    

0080235e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236b:	8b 45 08             	mov    0x8(%ebp),%eax
  80236e:	89 04 24             	mov    %eax,(%esp)
  802371:	e8 18 f3 ff ff       	call   80168e <fd_lookup>
  802376:	85 c0                	test   %eax,%eax
  802378:	78 11                	js     80238b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80237a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802383:	39 10                	cmp    %edx,(%eax)
  802385:	0f 94 c0             	sete   %al
  802388:	0f b6 c0             	movzbl %al,%eax
}
  80238b:	c9                   	leave  
  80238c:	c3                   	ret    

0080238d <opencons>:

int
opencons(void)
{
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802396:	89 04 24             	mov    %eax,(%esp)
  802399:	e8 7d f2 ff ff       	call   80161b <fd_alloc>
  80239e:	85 c0                	test   %eax,%eax
  8023a0:	78 3c                	js     8023de <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023a9:	00 
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b8:	e8 2f eb ff ff       	call   800eec <sys_page_alloc>
  8023bd:	85 c0                	test   %eax,%eax
  8023bf:	78 1d                	js     8023de <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023c1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8023c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023d6:	89 04 24             	mov    %eax,(%esp)
  8023d9:	e8 12 f2 ff ff       	call   8015f0 <fd2num>
}
  8023de:	c9                   	leave  
  8023df:	c3                   	ret    

008023e0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023e6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8023ed:	75 3c                	jne    80242b <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8023ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023f6:	00 
  8023f7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023fe:	ee 
  8023ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802406:	e8 e1 ea ff ff       	call   800eec <sys_page_alloc>
  80240b:	85 c0                	test   %eax,%eax
  80240d:	79 1c                	jns    80242b <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  80240f:	c7 44 24 08 e8 2e 80 	movl   $0x802ee8,0x8(%esp)
  802416:	00 
  802417:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80241e:	00 
  80241f:	c7 04 24 4c 2f 80 00 	movl   $0x802f4c,(%esp)
  802426:	e8 71 dd ff ff       	call   80019c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80242b:	8b 45 08             	mov    0x8(%ebp),%eax
  80242e:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802433:	c7 44 24 04 6c 24 80 	movl   $0x80246c,0x4(%esp)
  80243a:	00 
  80243b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802442:	e8 7c ec ff ff       	call   8010c3 <sys_env_set_pgfault_upcall>
  802447:	85 c0                	test   %eax,%eax
  802449:	79 1c                	jns    802467 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80244b:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  802452:	00 
  802453:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80245a:	00 
  80245b:	c7 04 24 4c 2f 80 00 	movl   $0x802f4c,(%esp)
  802462:	e8 35 dd ff ff       	call   80019c <_panic>
}
  802467:	c9                   	leave  
  802468:	c3                   	ret    
  802469:	00 00                	add    %al,(%eax)
	...

0080246c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80246c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80246d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802472:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802474:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  802477:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80247b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802480:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802484:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  802486:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802489:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80248a:	83 c4 04             	add    $0x4,%esp
    popfl
  80248d:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  80248e:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  80248f:	c3                   	ret    

00802490 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	56                   	push   %esi
  802494:	53                   	push   %ebx
  802495:	83 ec 10             	sub    $0x10,%esp
  802498:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80249b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80249e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8024a1:	85 db                	test   %ebx,%ebx
  8024a3:	74 06                	je     8024ab <ipc_recv+0x1b>
  8024a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8024ab:	85 f6                	test   %esi,%esi
  8024ad:	74 06                	je     8024b5 <ipc_recv+0x25>
  8024af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8024bc:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8024bf:	89 04 24             	mov    %eax,(%esp)
  8024c2:	e8 8e ec ff ff       	call   801155 <sys_ipc_recv>
    if (ret) return ret;
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	75 24                	jne    8024ef <ipc_recv+0x5f>
    if (from_env_store)
  8024cb:	85 db                	test   %ebx,%ebx
  8024cd:	74 0a                	je     8024d9 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  8024cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8024d4:	8b 40 74             	mov    0x74(%eax),%eax
  8024d7:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8024d9:	85 f6                	test   %esi,%esi
  8024db:	74 0a                	je     8024e7 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8024dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8024e2:	8b 40 78             	mov    0x78(%eax),%eax
  8024e5:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8024e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8024ec:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024ef:	83 c4 10             	add    $0x10,%esp
  8024f2:	5b                   	pop    %ebx
  8024f3:	5e                   	pop    %esi
  8024f4:	5d                   	pop    %ebp
  8024f5:	c3                   	ret    

008024f6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	57                   	push   %edi
  8024fa:	56                   	push   %esi
  8024fb:	53                   	push   %ebx
  8024fc:	83 ec 1c             	sub    $0x1c,%esp
  8024ff:	8b 75 08             	mov    0x8(%ebp),%esi
  802502:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802505:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802508:	85 db                	test   %ebx,%ebx
  80250a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80250f:	0f 44 d8             	cmove  %eax,%ebx
  802512:	eb 2a                	jmp    80253e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802514:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802517:	74 20                	je     802539 <ipc_send+0x43>
  802519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251d:	c7 44 24 08 5a 2f 80 	movl   $0x802f5a,0x8(%esp)
  802524:	00 
  802525:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80252c:	00 
  80252d:	c7 04 24 71 2f 80 00 	movl   $0x802f71,(%esp)
  802534:	e8 63 dc ff ff       	call   80019c <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802539:	e8 7e e9 ff ff       	call   800ebc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80253e:	8b 45 14             	mov    0x14(%ebp),%eax
  802541:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802545:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802549:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80254d:	89 34 24             	mov    %esi,(%esp)
  802550:	e8 cc eb ff ff       	call   801121 <sys_ipc_try_send>
  802555:	85 c0                	test   %eax,%eax
  802557:	75 bb                	jne    802514 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802559:	83 c4 1c             	add    $0x1c,%esp
  80255c:	5b                   	pop    %ebx
  80255d:	5e                   	pop    %esi
  80255e:	5f                   	pop    %edi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    

00802561 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802567:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80256c:	39 c8                	cmp    %ecx,%eax
  80256e:	74 19                	je     802589 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802570:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802575:	89 c2                	mov    %eax,%edx
  802577:	c1 e2 07             	shl    $0x7,%edx
  80257a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802580:	8b 52 50             	mov    0x50(%edx),%edx
  802583:	39 ca                	cmp    %ecx,%edx
  802585:	75 14                	jne    80259b <ipc_find_env+0x3a>
  802587:	eb 05                	jmp    80258e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802589:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80258e:	c1 e0 07             	shl    $0x7,%eax
  802591:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802596:	8b 40 40             	mov    0x40(%eax),%eax
  802599:	eb 0e                	jmp    8025a9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80259b:	83 c0 01             	add    $0x1,%eax
  80259e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025a3:	75 d0                	jne    802575 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025a5:	66 b8 00 00          	mov    $0x0,%ax
}
  8025a9:	5d                   	pop    %ebp
  8025aa:	c3                   	ret    
	...

008025ac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025ac:	55                   	push   %ebp
  8025ad:	89 e5                	mov    %esp,%ebp
  8025af:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025b2:	89 d0                	mov    %edx,%eax
  8025b4:	c1 e8 16             	shr    $0x16,%eax
  8025b7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025be:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025c3:	f6 c1 01             	test   $0x1,%cl
  8025c6:	74 1d                	je     8025e5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025c8:	c1 ea 0c             	shr    $0xc,%edx
  8025cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025d2:	f6 c2 01             	test   $0x1,%dl
  8025d5:	74 0e                	je     8025e5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025d7:	c1 ea 0c             	shr    $0xc,%edx
  8025da:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025e1:	ef 
  8025e2:	0f b7 c0             	movzwl %ax,%eax
}
  8025e5:	5d                   	pop    %ebp
  8025e6:	c3                   	ret    
	...

008025f0 <__udivdi3>:
  8025f0:	83 ec 1c             	sub    $0x1c,%esp
  8025f3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8025f7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8025fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8025ff:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802603:	89 74 24 10          	mov    %esi,0x10(%esp)
  802607:	8b 74 24 24          	mov    0x24(%esp),%esi
  80260b:	85 ff                	test   %edi,%edi
  80260d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802611:	89 44 24 08          	mov    %eax,0x8(%esp)
  802615:	89 cd                	mov    %ecx,%ebp
  802617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80261b:	75 33                	jne    802650 <__udivdi3+0x60>
  80261d:	39 f1                	cmp    %esi,%ecx
  80261f:	77 57                	ja     802678 <__udivdi3+0x88>
  802621:	85 c9                	test   %ecx,%ecx
  802623:	75 0b                	jne    802630 <__udivdi3+0x40>
  802625:	b8 01 00 00 00       	mov    $0x1,%eax
  80262a:	31 d2                	xor    %edx,%edx
  80262c:	f7 f1                	div    %ecx
  80262e:	89 c1                	mov    %eax,%ecx
  802630:	89 f0                	mov    %esi,%eax
  802632:	31 d2                	xor    %edx,%edx
  802634:	f7 f1                	div    %ecx
  802636:	89 c6                	mov    %eax,%esi
  802638:	8b 44 24 04          	mov    0x4(%esp),%eax
  80263c:	f7 f1                	div    %ecx
  80263e:	89 f2                	mov    %esi,%edx
  802640:	8b 74 24 10          	mov    0x10(%esp),%esi
  802644:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802648:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80264c:	83 c4 1c             	add    $0x1c,%esp
  80264f:	c3                   	ret    
  802650:	31 d2                	xor    %edx,%edx
  802652:	31 c0                	xor    %eax,%eax
  802654:	39 f7                	cmp    %esi,%edi
  802656:	77 e8                	ja     802640 <__udivdi3+0x50>
  802658:	0f bd cf             	bsr    %edi,%ecx
  80265b:	83 f1 1f             	xor    $0x1f,%ecx
  80265e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802662:	75 2c                	jne    802690 <__udivdi3+0xa0>
  802664:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802668:	76 04                	jbe    80266e <__udivdi3+0x7e>
  80266a:	39 f7                	cmp    %esi,%edi
  80266c:	73 d2                	jae    802640 <__udivdi3+0x50>
  80266e:	31 d2                	xor    %edx,%edx
  802670:	b8 01 00 00 00       	mov    $0x1,%eax
  802675:	eb c9                	jmp    802640 <__udivdi3+0x50>
  802677:	90                   	nop
  802678:	89 f2                	mov    %esi,%edx
  80267a:	f7 f1                	div    %ecx
  80267c:	31 d2                	xor    %edx,%edx
  80267e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802682:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802686:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80268a:	83 c4 1c             	add    $0x1c,%esp
  80268d:	c3                   	ret    
  80268e:	66 90                	xchg   %ax,%ax
  802690:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802695:	b8 20 00 00 00       	mov    $0x20,%eax
  80269a:	89 ea                	mov    %ebp,%edx
  80269c:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026a0:	d3 e7                	shl    %cl,%edi
  8026a2:	89 c1                	mov    %eax,%ecx
  8026a4:	d3 ea                	shr    %cl,%edx
  8026a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026ab:	09 fa                	or     %edi,%edx
  8026ad:	89 f7                	mov    %esi,%edi
  8026af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026b9:	d3 e5                	shl    %cl,%ebp
  8026bb:	89 c1                	mov    %eax,%ecx
  8026bd:	d3 ef                	shr    %cl,%edi
  8026bf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026c4:	d3 e2                	shl    %cl,%edx
  8026c6:	89 c1                	mov    %eax,%ecx
  8026c8:	d3 ee                	shr    %cl,%esi
  8026ca:	09 d6                	or     %edx,%esi
  8026cc:	89 fa                	mov    %edi,%edx
  8026ce:	89 f0                	mov    %esi,%eax
  8026d0:	f7 74 24 0c          	divl   0xc(%esp)
  8026d4:	89 d7                	mov    %edx,%edi
  8026d6:	89 c6                	mov    %eax,%esi
  8026d8:	f7 e5                	mul    %ebp
  8026da:	39 d7                	cmp    %edx,%edi
  8026dc:	72 22                	jb     802700 <__udivdi3+0x110>
  8026de:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8026e2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026e7:	d3 e5                	shl    %cl,%ebp
  8026e9:	39 c5                	cmp    %eax,%ebp
  8026eb:	73 04                	jae    8026f1 <__udivdi3+0x101>
  8026ed:	39 d7                	cmp    %edx,%edi
  8026ef:	74 0f                	je     802700 <__udivdi3+0x110>
  8026f1:	89 f0                	mov    %esi,%eax
  8026f3:	31 d2                	xor    %edx,%edx
  8026f5:	e9 46 ff ff ff       	jmp    802640 <__udivdi3+0x50>
  8026fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802700:	8d 46 ff             	lea    -0x1(%esi),%eax
  802703:	31 d2                	xor    %edx,%edx
  802705:	8b 74 24 10          	mov    0x10(%esp),%esi
  802709:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80270d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802711:	83 c4 1c             	add    $0x1c,%esp
  802714:	c3                   	ret    
	...

00802720 <__umoddi3>:
  802720:	83 ec 1c             	sub    $0x1c,%esp
  802723:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802727:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80272b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80272f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802733:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802737:	8b 74 24 24          	mov    0x24(%esp),%esi
  80273b:	85 ed                	test   %ebp,%ebp
  80273d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802741:	89 44 24 08          	mov    %eax,0x8(%esp)
  802745:	89 cf                	mov    %ecx,%edi
  802747:	89 04 24             	mov    %eax,(%esp)
  80274a:	89 f2                	mov    %esi,%edx
  80274c:	75 1a                	jne    802768 <__umoddi3+0x48>
  80274e:	39 f1                	cmp    %esi,%ecx
  802750:	76 4e                	jbe    8027a0 <__umoddi3+0x80>
  802752:	f7 f1                	div    %ecx
  802754:	89 d0                	mov    %edx,%eax
  802756:	31 d2                	xor    %edx,%edx
  802758:	8b 74 24 10          	mov    0x10(%esp),%esi
  80275c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802760:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802764:	83 c4 1c             	add    $0x1c,%esp
  802767:	c3                   	ret    
  802768:	39 f5                	cmp    %esi,%ebp
  80276a:	77 54                	ja     8027c0 <__umoddi3+0xa0>
  80276c:	0f bd c5             	bsr    %ebp,%eax
  80276f:	83 f0 1f             	xor    $0x1f,%eax
  802772:	89 44 24 04          	mov    %eax,0x4(%esp)
  802776:	75 60                	jne    8027d8 <__umoddi3+0xb8>
  802778:	3b 0c 24             	cmp    (%esp),%ecx
  80277b:	0f 87 07 01 00 00    	ja     802888 <__umoddi3+0x168>
  802781:	89 f2                	mov    %esi,%edx
  802783:	8b 34 24             	mov    (%esp),%esi
  802786:	29 ce                	sub    %ecx,%esi
  802788:	19 ea                	sbb    %ebp,%edx
  80278a:	89 34 24             	mov    %esi,(%esp)
  80278d:	8b 04 24             	mov    (%esp),%eax
  802790:	8b 74 24 10          	mov    0x10(%esp),%esi
  802794:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802798:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80279c:	83 c4 1c             	add    $0x1c,%esp
  80279f:	c3                   	ret    
  8027a0:	85 c9                	test   %ecx,%ecx
  8027a2:	75 0b                	jne    8027af <__umoddi3+0x8f>
  8027a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027a9:	31 d2                	xor    %edx,%edx
  8027ab:	f7 f1                	div    %ecx
  8027ad:	89 c1                	mov    %eax,%ecx
  8027af:	89 f0                	mov    %esi,%eax
  8027b1:	31 d2                	xor    %edx,%edx
  8027b3:	f7 f1                	div    %ecx
  8027b5:	8b 04 24             	mov    (%esp),%eax
  8027b8:	f7 f1                	div    %ecx
  8027ba:	eb 98                	jmp    802754 <__umoddi3+0x34>
  8027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	89 f2                	mov    %esi,%edx
  8027c2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027c6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027ca:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027ce:	83 c4 1c             	add    $0x1c,%esp
  8027d1:	c3                   	ret    
  8027d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027d8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027dd:	89 e8                	mov    %ebp,%eax
  8027df:	bd 20 00 00 00       	mov    $0x20,%ebp
  8027e4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8027e8:	89 fa                	mov    %edi,%edx
  8027ea:	d3 e0                	shl    %cl,%eax
  8027ec:	89 e9                	mov    %ebp,%ecx
  8027ee:	d3 ea                	shr    %cl,%edx
  8027f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027f5:	09 c2                	or     %eax,%edx
  8027f7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027fb:	89 14 24             	mov    %edx,(%esp)
  8027fe:	89 f2                	mov    %esi,%edx
  802800:	d3 e7                	shl    %cl,%edi
  802802:	89 e9                	mov    %ebp,%ecx
  802804:	d3 ea                	shr    %cl,%edx
  802806:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80280b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80280f:	d3 e6                	shl    %cl,%esi
  802811:	89 e9                	mov    %ebp,%ecx
  802813:	d3 e8                	shr    %cl,%eax
  802815:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80281a:	09 f0                	or     %esi,%eax
  80281c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802820:	f7 34 24             	divl   (%esp)
  802823:	d3 e6                	shl    %cl,%esi
  802825:	89 74 24 08          	mov    %esi,0x8(%esp)
  802829:	89 d6                	mov    %edx,%esi
  80282b:	f7 e7                	mul    %edi
  80282d:	39 d6                	cmp    %edx,%esi
  80282f:	89 c1                	mov    %eax,%ecx
  802831:	89 d7                	mov    %edx,%edi
  802833:	72 3f                	jb     802874 <__umoddi3+0x154>
  802835:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802839:	72 35                	jb     802870 <__umoddi3+0x150>
  80283b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80283f:	29 c8                	sub    %ecx,%eax
  802841:	19 fe                	sbb    %edi,%esi
  802843:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802848:	89 f2                	mov    %esi,%edx
  80284a:	d3 e8                	shr    %cl,%eax
  80284c:	89 e9                	mov    %ebp,%ecx
  80284e:	d3 e2                	shl    %cl,%edx
  802850:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802855:	09 d0                	or     %edx,%eax
  802857:	89 f2                	mov    %esi,%edx
  802859:	d3 ea                	shr    %cl,%edx
  80285b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80285f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802863:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802867:	83 c4 1c             	add    $0x1c,%esp
  80286a:	c3                   	ret    
  80286b:	90                   	nop
  80286c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802870:	39 d6                	cmp    %edx,%esi
  802872:	75 c7                	jne    80283b <__umoddi3+0x11b>
  802874:	89 d7                	mov    %edx,%edi
  802876:	89 c1                	mov    %eax,%ecx
  802878:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80287c:	1b 3c 24             	sbb    (%esp),%edi
  80287f:	eb ba                	jmp    80283b <__umoddi3+0x11b>
  802881:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802888:	39 f5                	cmp    %esi,%ebp
  80288a:	0f 82 f1 fe ff ff    	jb     802781 <__umoddi3+0x61>
  802890:	e9 f8 fe ff ff       	jmp    80278d <__umoddi3+0x6d>
