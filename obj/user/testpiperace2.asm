
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
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
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003d:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800044:	e8 0a 03 00 00       	call   800353 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 d0 20 00 00       	call   802124 <pipe>
  800054:	85 c0                	test   %eax,%eax
  800056:	79 20                	jns    800078 <umain+0x44>
		panic("pipe: %e", r);
  800058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005c:	c7 44 24 08 ae 29 80 	movl   $0x8029ae,0x8(%esp)
  800063:	00 
  800064:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006b:	00 
  80006c:	c7 04 24 b7 29 80 00 	movl   $0x8029b7,(%esp)
  800073:	e8 e0 01 00 00       	call   800258 <_panic>
	if ((r = fork()) < 0)
  800078:	e8 3a 13 00 00       	call   8013b7 <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <umain+0x6f>
		panic("fork: %e", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 cc 29 80 	movl   $0x8029cc,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 b7 29 80 00 	movl   $0x8029b7,(%esp)
  80009e:	e8 b5 01 00 00       	call   800258 <_panic>
	if (r == 0) {
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 75                	jne    80011c <umain+0xe8>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 db 17 00 00       	call   80188d <close>
		for (i = 0; i < 200; i++) {
  8000b2:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  8000b7:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	f7 ee                	imul   %esi
  8000c0:	c1 fa 02             	sar    $0x2,%edx
  8000c3:	89 d8                	mov    %ebx,%eax
  8000c5:	c1 f8 1f             	sar    $0x1f,%eax
  8000c8:	29 c2                	sub    %eax,%edx
  8000ca:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000cd:	01 c0                	add    %eax,%eax
  8000cf:	39 c3                	cmp    %eax,%ebx
  8000d1:	75 10                	jne    8000e3 <umain+0xaf>
				cprintf("%d.", i);
  8000d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d7:	c7 04 24 d5 29 80 00 	movl   $0x8029d5,(%esp)
  8000de:	e8 70 02 00 00       	call   800353 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000e3:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8000ea:	00 
  8000eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 ea 17 00 00       	call   8018e0 <dup>
			sys_yield();
  8000f6:	e8 71 0e 00 00       	call   800f6c <sys_yield>
			close(10);
  8000fb:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800102:	e8 86 17 00 00       	call   80188d <close>
			sys_yield();
  800107:	e8 60 0e 00 00       	call   800f6c <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  80010c:	83 c3 01             	add    $0x1,%ebx
  80010f:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  800115:	75 a5                	jne    8000bc <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  800117:	e8 20 01 00 00       	call   80023c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  80011c:	89 fb                	mov    %edi,%ebx
  80011e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800124:	c1 e3 07             	shl    $0x7,%ebx
  800127:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80012d:	eb 28                	jmp    800157 <umain+0x123>
		if (pipeisclosed(p[0]) != 0) {
  80012f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800132:	89 04 24             	mov    %eax,(%esp)
  800135:	e8 65 21 00 00       	call   80229f <pipeisclosed>
  80013a:	85 c0                	test   %eax,%eax
  80013c:	74 19                	je     800157 <umain+0x123>
			cprintf("\nRACE: pipe appears closed\n");
  80013e:	c7 04 24 d9 29 80 00 	movl   $0x8029d9,(%esp)
  800145:	e8 09 02 00 00       	call   800353 <cprintf>
			sys_env_destroy(r);
  80014a:	89 3c 24             	mov    %edi,(%esp)
  80014d:	e8 8d 0d 00 00       	call   800edf <sys_env_destroy>
			exit();
  800152:	e8 e5 00 00 00       	call   80023c <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800157:	8b 43 54             	mov    0x54(%ebx),%eax
  80015a:	83 f8 02             	cmp    $0x2,%eax
  80015d:	74 d0                	je     80012f <umain+0xfb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80015f:	c7 04 24 f5 29 80 00 	movl   $0x8029f5,(%esp)
  800166:	e8 e8 01 00 00       	call   800353 <cprintf>
	if (pipeisclosed(p[0]))
  80016b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016e:	89 04 24             	mov    %eax,(%esp)
  800171:	e8 29 21 00 00       	call   80229f <pipeisclosed>
  800176:	85 c0                	test   %eax,%eax
  800178:	74 1c                	je     800196 <umain+0x162>
		panic("somehow the other end of p[0] got closed!");
  80017a:	c7 44 24 08 84 29 80 	movl   $0x802984,0x8(%esp)
  800181:	00 
  800182:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800189:	00 
  80018a:	c7 04 24 b7 29 80 00 	movl   $0x8029b7,(%esp)
  800191:	e8 c2 00 00 00       	call   800258 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800196:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 96 15 00 00       	call   80173e <fd_lookup>
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	79 20                	jns    8001cc <umain+0x198>
		panic("cannot look up p[0]: %e", r);
  8001ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b0:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  8001b7:	00 
  8001b8:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001bf:	00 
  8001c0:	c7 04 24 b7 29 80 00 	movl   $0x8029b7,(%esp)
  8001c7:	e8 8c 00 00 00       	call   800258 <_panic>
	(void) fd2data(fd);
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	e8 d9 14 00 00       	call   8016b0 <fd2data>
	cprintf("race didn't happen\n");
  8001d7:	c7 04 24 23 2a 80 00 	movl   $0x802a23,(%esp)
  8001de:	e8 70 01 00 00       	call   800353 <cprintf>
}
  8001e3:	83 c4 2c             	add    $0x2c,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    
	...

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 18             	sub    $0x18,%esp
  8001f2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001f5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001fe:	e8 39 0d 00 00       	call   800f3c <sys_getenvid>
  800203:	25 ff 03 00 00       	and    $0x3ff,%eax
  800208:	c1 e0 07             	shl    $0x7,%eax
  80020b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800210:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800215:	85 f6                	test   %esi,%esi
  800217:	7e 07                	jle    800220 <libmain+0x34>
		binaryname = argv[0];
  800219:	8b 03                	mov    (%ebx),%eax
  80021b:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	89 34 24             	mov    %esi,(%esp)
  800227:	e8 08 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80022c:	e8 0b 00 00 00       	call   80023c <exit>
}
  800231:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800234:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    
	...

0080023c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800242:	e8 77 16 00 00       	call   8018be <close_all>
	sys_env_destroy(0);
  800247:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80024e:	e8 8c 0c 00 00       	call   800edf <sys_env_destroy>
}
  800253:	c9                   	leave  
  800254:	c3                   	ret    
  800255:	00 00                	add    %al,(%eax)
	...

00800258 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800260:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800263:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800269:	e8 ce 0c 00 00       	call   800f3c <sys_getenvid>
  80026e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800271:	89 54 24 10          	mov    %edx,0x10(%esp)
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  80028b:	e8 c3 00 00 00       	call   800353 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800290:	89 74 24 04          	mov    %esi,0x4(%esp)
  800294:	8b 45 10             	mov    0x10(%ebp),%eax
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	e8 53 00 00 00       	call   8002f2 <vcprintf>
	cprintf("\n");
  80029f:	c7 04 24 bf 2d 80 00 	movl   $0x802dbf,(%esp)
  8002a6:	e8 a8 00 00 00       	call   800353 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ab:	cc                   	int3   
  8002ac:	eb fd                	jmp    8002ab <_panic+0x53>
	...

008002b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 14             	sub    $0x14,%esp
  8002b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ba:	8b 03                	mov    (%ebx),%eax
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002c3:	83 c0 01             	add    $0x1,%eax
  8002c6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002cd:	75 19                	jne    8002e8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002cf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002d6:	00 
  8002d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	e8 9e 0b 00 00       	call   800e80 <sys_cputs>
		b->idx = 0;
  8002e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002ec:	83 c4 14             	add    $0x14,%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800302:	00 00 00 
	b.cnt = 0;
  800305:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80030c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80030f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800323:	89 44 24 04          	mov    %eax,0x4(%esp)
  800327:	c7 04 24 b0 02 80 00 	movl   $0x8002b0,(%esp)
  80032e:	e8 97 01 00 00       	call   8004ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800333:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	e8 35 0b 00 00       	call   800e80 <sys_cputs>

	return b.cnt;
}
  80034b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800351:	c9                   	leave  
  800352:	c3                   	ret    

00800353 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800359:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	e8 87 ff ff ff       	call   8002f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    
  80036d:	00 00                	add    %al,(%eax)
	...

00800370 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
  800376:	83 ec 3c             	sub    $0x3c,%esp
  800379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037c:	89 d7                	mov    %edx,%edi
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
  800387:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80038d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800390:	b8 00 00 00 00       	mov    $0x0,%eax
  800395:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800398:	72 11                	jb     8003ab <printnum+0x3b>
  80039a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039d:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003a0:	76 09                	jbe    8003ab <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a2:	83 eb 01             	sub    $0x1,%ebx
  8003a5:	85 db                	test   %ebx,%ebx
  8003a7:	7f 51                	jg     8003fa <printnum+0x8a>
  8003a9:	eb 5e                	jmp    800409 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003af:	83 eb 01             	sub    $0x1,%ebx
  8003b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003bd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003c1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003cc:	00 
  8003cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003da:	e8 c1 22 00 00       	call   8026a0 <__udivdi3>
  8003df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ee:	89 fa                	mov    %edi,%edx
  8003f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f3:	e8 78 ff ff ff       	call   800370 <printnum>
  8003f8:	eb 0f                	jmp    800409 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fe:	89 34 24             	mov    %esi,(%esp)
  800401:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800404:	83 eb 01             	sub    $0x1,%ebx
  800407:	75 f1                	jne    8003fa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800409:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800411:	8b 45 10             	mov    0x10(%ebp),%eax
  800414:	89 44 24 08          	mov    %eax,0x8(%esp)
  800418:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80041f:	00 
  800420:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800423:	89 04 24             	mov    %eax,(%esp)
  800426:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042d:	e8 9e 23 00 00       	call   8027d0 <__umoddi3>
  800432:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800436:	0f be 80 67 2a 80 00 	movsbl 0x802a67(%eax),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800443:	83 c4 3c             	add    $0x3c,%esp
  800446:	5b                   	pop    %ebx
  800447:	5e                   	pop    %esi
  800448:	5f                   	pop    %edi
  800449:	5d                   	pop    %ebp
  80044a:	c3                   	ret    

0080044b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80044e:	83 fa 01             	cmp    $0x1,%edx
  800451:	7e 0e                	jle    800461 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800453:	8b 10                	mov    (%eax),%edx
  800455:	8d 4a 08             	lea    0x8(%edx),%ecx
  800458:	89 08                	mov    %ecx,(%eax)
  80045a:	8b 02                	mov    (%edx),%eax
  80045c:	8b 52 04             	mov    0x4(%edx),%edx
  80045f:	eb 22                	jmp    800483 <getuint+0x38>
	else if (lflag)
  800461:	85 d2                	test   %edx,%edx
  800463:	74 10                	je     800475 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800465:	8b 10                	mov    (%eax),%edx
  800467:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046a:	89 08                	mov    %ecx,(%eax)
  80046c:	8b 02                	mov    (%edx),%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	eb 0e                	jmp    800483 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800475:	8b 10                	mov    (%eax),%edx
  800477:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047a:	89 08                	mov    %ecx,(%eax)
  80047c:	8b 02                	mov    (%edx),%eax
  80047e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800483:	5d                   	pop    %ebp
  800484:	c3                   	ret    

00800485 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80048b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80048f:	8b 10                	mov    (%eax),%edx
  800491:	3b 50 04             	cmp    0x4(%eax),%edx
  800494:	73 0a                	jae    8004a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800496:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800499:	88 0a                	mov    %cl,(%edx)
  80049b:	83 c2 01             	add    $0x1,%edx
  80049e:	89 10                	mov    %edx,(%eax)
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004af:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	e8 02 00 00 00       	call   8004ca <vprintfmt>
	va_end(ap);
}
  8004c8:	c9                   	leave  
  8004c9:	c3                   	ret    

008004ca <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	57                   	push   %edi
  8004ce:	56                   	push   %esi
  8004cf:	53                   	push   %ebx
  8004d0:	83 ec 5c             	sub    $0x5c,%esp
  8004d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8004d9:	eb 12                	jmp    8004ed <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	0f 84 e4 04 00 00    	je     8009c7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8004e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e7:	89 04 24             	mov    %eax,(%esp)
  8004ea:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ed:	0f b6 06             	movzbl (%esi),%eax
  8004f0:	83 c6 01             	add    $0x1,%esi
  8004f3:	83 f8 25             	cmp    $0x25,%eax
  8004f6:	75 e3                	jne    8004db <vprintfmt+0x11>
  8004f8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8004fc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800503:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800508:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80050f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800514:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800517:	eb 2b                	jmp    800544 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80051c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800520:	eb 22                	jmp    800544 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800529:	eb 19                	jmp    800544 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80052e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800535:	eb 0d                	jmp    800544 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800537:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80053a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80053d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	0f b6 06             	movzbl (%esi),%eax
  800547:	0f b6 d0             	movzbl %al,%edx
  80054a:	8d 7e 01             	lea    0x1(%esi),%edi
  80054d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800550:	83 e8 23             	sub    $0x23,%eax
  800553:	3c 55                	cmp    $0x55,%al
  800555:	0f 87 46 04 00 00    	ja     8009a1 <vprintfmt+0x4d7>
  80055b:	0f b6 c0             	movzbl %al,%eax
  80055e:	ff 24 85 c0 2b 80 00 	jmp    *0x802bc0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800565:	83 ea 30             	sub    $0x30,%edx
  800568:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80056b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80056f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800575:	83 fa 09             	cmp    $0x9,%edx
  800578:	77 4a                	ja     8005c4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800580:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800583:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800587:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80058a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80058d:	83 fa 09             	cmp    $0x9,%edx
  800590:	76 eb                	jbe    80057d <vprintfmt+0xb3>
  800592:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800595:	eb 2d                	jmp    8005c4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 04             	lea    0x4(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a8:	eb 1a                	jmp    8005c4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8005ad:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005b1:	79 91                	jns    800544 <vprintfmt+0x7a>
  8005b3:	e9 73 ff ff ff       	jmp    80052b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8005c2:	eb 80                	jmp    800544 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8005c4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005c8:	0f 89 76 ff ff ff    	jns    800544 <vprintfmt+0x7a>
  8005ce:	e9 64 ff ff ff       	jmp    800537 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d9:	e9 66 ff ff ff       	jmp    800544 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 04 24             	mov    %eax,(%esp)
  8005f0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f6:	e9 f2 fe ff ff       	jmp    8004ed <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8005fb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8005ff:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800602:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800606:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800609:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80060d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800610:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800613:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800617:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80061a:	80 f9 09             	cmp    $0x9,%cl
  80061d:	77 1d                	ja     80063c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80061f:	0f be c0             	movsbl %al,%eax
  800622:	6b c0 64             	imul   $0x64,%eax,%eax
  800625:	0f be d2             	movsbl %dl,%edx
  800628:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80062b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800632:	a3 04 40 80 00       	mov    %eax,0x804004
  800637:	e9 b1 fe ff ff       	jmp    8004ed <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80063c:	c7 44 24 04 7f 2a 80 	movl   $0x802a7f,0x4(%esp)
  800643:	00 
  800644:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	e8 0c 05 00 00       	call   800b5b <strcmp>
  80064f:	85 c0                	test   %eax,%eax
  800651:	75 0f                	jne    800662 <vprintfmt+0x198>
  800653:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  80065a:	00 00 00 
  80065d:	e9 8b fe ff ff       	jmp    8004ed <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800662:	c7 44 24 04 83 2a 80 	movl   $0x802a83,0x4(%esp)
  800669:	00 
  80066a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80066d:	89 14 24             	mov    %edx,(%esp)
  800670:	e8 e6 04 00 00       	call   800b5b <strcmp>
  800675:	85 c0                	test   %eax,%eax
  800677:	75 0f                	jne    800688 <vprintfmt+0x1be>
  800679:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  800680:	00 00 00 
  800683:	e9 65 fe ff ff       	jmp    8004ed <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800688:	c7 44 24 04 87 2a 80 	movl   $0x802a87,0x4(%esp)
  80068f:	00 
  800690:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800693:	89 0c 24             	mov    %ecx,(%esp)
  800696:	e8 c0 04 00 00       	call   800b5b <strcmp>
  80069b:	85 c0                	test   %eax,%eax
  80069d:	75 0f                	jne    8006ae <vprintfmt+0x1e4>
  80069f:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  8006a6:	00 00 00 
  8006a9:	e9 3f fe ff ff       	jmp    8004ed <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8006ae:	c7 44 24 04 8b 2a 80 	movl   $0x802a8b,0x4(%esp)
  8006b5:	00 
  8006b6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8006b9:	89 3c 24             	mov    %edi,(%esp)
  8006bc:	e8 9a 04 00 00       	call   800b5b <strcmp>
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	75 0f                	jne    8006d4 <vprintfmt+0x20a>
  8006c5:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  8006cc:	00 00 00 
  8006cf:	e9 19 fe ff ff       	jmp    8004ed <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8006d4:	c7 44 24 04 8f 2a 80 	movl   $0x802a8f,0x4(%esp)
  8006db:	00 
  8006dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	e8 74 04 00 00       	call   800b5b <strcmp>
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	75 0f                	jne    8006fa <vprintfmt+0x230>
  8006eb:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  8006f2:	00 00 00 
  8006f5:	e9 f3 fd ff ff       	jmp    8004ed <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8006fa:	c7 44 24 04 93 2a 80 	movl   $0x802a93,0x4(%esp)
  800701:	00 
  800702:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800705:	89 14 24             	mov    %edx,(%esp)
  800708:	e8 4e 04 00 00       	call   800b5b <strcmp>
  80070d:	83 f8 01             	cmp    $0x1,%eax
  800710:	19 c0                	sbb    %eax,%eax
  800712:	f7 d0                	not    %eax
  800714:	83 c0 08             	add    $0x8,%eax
  800717:	a3 04 40 80 00       	mov    %eax,0x804004
  80071c:	e9 cc fd ff ff       	jmp    8004ed <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8d 50 04             	lea    0x4(%eax),%edx
  800727:	89 55 14             	mov    %edx,0x14(%ebp)
  80072a:	8b 00                	mov    (%eax),%eax
  80072c:	89 c2                	mov    %eax,%edx
  80072e:	c1 fa 1f             	sar    $0x1f,%edx
  800731:	31 d0                	xor    %edx,%eax
  800733:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800735:	83 f8 0f             	cmp    $0xf,%eax
  800738:	7f 0b                	jg     800745 <vprintfmt+0x27b>
  80073a:	8b 14 85 20 2d 80 00 	mov    0x802d20(,%eax,4),%edx
  800741:	85 d2                	test   %edx,%edx
  800743:	75 23                	jne    800768 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800745:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800749:	c7 44 24 08 97 2a 80 	movl   $0x802a97,0x8(%esp)
  800750:	00 
  800751:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800755:	8b 7d 08             	mov    0x8(%ebp),%edi
  800758:	89 3c 24             	mov    %edi,(%esp)
  80075b:	e8 42 fd ff ff       	call   8004a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800760:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800763:	e9 85 fd ff ff       	jmp    8004ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800768:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076c:	c7 44 24 08 e1 2f 80 	movl   $0x802fe1,0x8(%esp)
  800773:	00 
  800774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800778:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077b:	89 3c 24             	mov    %edi,(%esp)
  80077e:	e8 1f fd ff ff       	call   8004a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800783:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800786:	e9 62 fd ff ff       	jmp    8004ed <vprintfmt+0x23>
  80078b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80078e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800791:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)
  80079d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80079f:	85 f6                	test   %esi,%esi
  8007a1:	b8 78 2a 80 00       	mov    $0x802a78,%eax
  8007a6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007a9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007ad:	7e 06                	jle    8007b5 <vprintfmt+0x2eb>
  8007af:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8007b3:	75 13                	jne    8007c8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b5:	0f be 06             	movsbl (%esi),%eax
  8007b8:	83 c6 01             	add    $0x1,%esi
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	0f 85 94 00 00 00    	jne    800857 <vprintfmt+0x38d>
  8007c3:	e9 81 00 00 00       	jmp    800849 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cc:	89 34 24             	mov    %esi,(%esp)
  8007cf:	e8 97 02 00 00       	call   800a6b <strnlen>
  8007d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8007d7:	29 c2                	sub    %eax,%edx
  8007d9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	7e d5                	jle    8007b5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8007e0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007e4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8007e7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8007ea:	89 d6                	mov    %edx,%esi
  8007ec:	89 cf                	mov    %ecx,%edi
  8007ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f2:	89 3c 24             	mov    %edi,(%esp)
  8007f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f8:	83 ee 01             	sub    $0x1,%esi
  8007fb:	75 f1                	jne    8007ee <vprintfmt+0x324>
  8007fd:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800800:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800803:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800806:	eb ad                	jmp    8007b5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800808:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80080c:	74 1b                	je     800829 <vprintfmt+0x35f>
  80080e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800811:	83 fa 5e             	cmp    $0x5e,%edx
  800814:	76 13                	jbe    800829 <vprintfmt+0x35f>
					putch('?', putdat);
  800816:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800824:	ff 55 08             	call   *0x8(%ebp)
  800827:	eb 0d                	jmp    800836 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800829:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80082c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800836:	83 eb 01             	sub    $0x1,%ebx
  800839:	0f be 06             	movsbl (%esi),%eax
  80083c:	83 c6 01             	add    $0x1,%esi
  80083f:	85 c0                	test   %eax,%eax
  800841:	75 1a                	jne    80085d <vprintfmt+0x393>
  800843:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800846:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800849:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80084c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800850:	7f 1c                	jg     80086e <vprintfmt+0x3a4>
  800852:	e9 96 fc ff ff       	jmp    8004ed <vprintfmt+0x23>
  800857:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80085a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80085d:	85 ff                	test   %edi,%edi
  80085f:	78 a7                	js     800808 <vprintfmt+0x33e>
  800861:	83 ef 01             	sub    $0x1,%edi
  800864:	79 a2                	jns    800808 <vprintfmt+0x33e>
  800866:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800869:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80086c:	eb db                	jmp    800849 <vprintfmt+0x37f>
  80086e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800871:	89 de                	mov    %ebx,%esi
  800873:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800876:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800881:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800883:	83 eb 01             	sub    $0x1,%ebx
  800886:	75 ee                	jne    800876 <vprintfmt+0x3ac>
  800888:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80088d:	e9 5b fc ff ff       	jmp    8004ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800892:	83 f9 01             	cmp    $0x1,%ecx
  800895:	7e 10                	jle    8008a7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	8d 50 08             	lea    0x8(%eax),%edx
  80089d:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a0:	8b 30                	mov    (%eax),%esi
  8008a2:	8b 78 04             	mov    0x4(%eax),%edi
  8008a5:	eb 26                	jmp    8008cd <vprintfmt+0x403>
	else if (lflag)
  8008a7:	85 c9                	test   %ecx,%ecx
  8008a9:	74 12                	je     8008bd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8d 50 04             	lea    0x4(%eax),%edx
  8008b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b4:	8b 30                	mov    (%eax),%esi
  8008b6:	89 f7                	mov    %esi,%edi
  8008b8:	c1 ff 1f             	sar    $0x1f,%edi
  8008bb:	eb 10                	jmp    8008cd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 50 04             	lea    0x4(%eax),%edx
  8008c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c6:	8b 30                	mov    (%eax),%esi
  8008c8:	89 f7                	mov    %esi,%edi
  8008ca:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008cd:	85 ff                	test   %edi,%edi
  8008cf:	78 0e                	js     8008df <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008d1:	89 f0                	mov    %esi,%eax
  8008d3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008d5:	be 0a 00 00 00       	mov    $0xa,%esi
  8008da:	e9 84 00 00 00       	jmp    800963 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008ea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	89 fa                	mov    %edi,%edx
  8008f1:	f7 d8                	neg    %eax
  8008f3:	83 d2 00             	adc    $0x0,%edx
  8008f6:	f7 da                	neg    %edx
			}
			base = 10;
  8008f8:	be 0a 00 00 00       	mov    $0xa,%esi
  8008fd:	eb 64                	jmp    800963 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008ff:	89 ca                	mov    %ecx,%edx
  800901:	8d 45 14             	lea    0x14(%ebp),%eax
  800904:	e8 42 fb ff ff       	call   80044b <getuint>
			base = 10;
  800909:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80090e:	eb 53                	jmp    800963 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800910:	89 ca                	mov    %ecx,%edx
  800912:	8d 45 14             	lea    0x14(%ebp),%eax
  800915:	e8 31 fb ff ff       	call   80044b <getuint>
    			base = 8;
  80091a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80091f:	eb 42                	jmp    800963 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800921:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800925:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80092c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80092f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800933:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80093a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8d 50 04             	lea    0x4(%eax),%edx
  800943:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800946:	8b 00                	mov    (%eax),%eax
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80094d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800952:	eb 0f                	jmp    800963 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800954:	89 ca                	mov    %ecx,%edx
  800956:	8d 45 14             	lea    0x14(%ebp),%eax
  800959:	e8 ed fa ff ff       	call   80044b <getuint>
			base = 16;
  80095e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800963:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800967:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80096b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80096e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800972:	89 74 24 08          	mov    %esi,0x8(%esp)
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	89 54 24 04          	mov    %edx,0x4(%esp)
  80097d:	89 da                	mov    %ebx,%edx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	e8 e9 f9 ff ff       	call   800370 <printnum>
			break;
  800987:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80098a:	e9 5e fb ff ff       	jmp    8004ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80098f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800993:	89 14 24             	mov    %edx,(%esp)
  800996:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800999:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80099c:	e9 4c fb ff ff       	jmp    8004ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009ac:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009af:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009b3:	0f 84 34 fb ff ff    	je     8004ed <vprintfmt+0x23>
  8009b9:	83 ee 01             	sub    $0x1,%esi
  8009bc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009c0:	75 f7                	jne    8009b9 <vprintfmt+0x4ef>
  8009c2:	e9 26 fb ff ff       	jmp    8004ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009c7:	83 c4 5c             	add    $0x5c,%esp
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 28             	sub    $0x28,%esp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ec:	85 c0                	test   %eax,%eax
  8009ee:	74 30                	je     800a20 <vsnprintf+0x51>
  8009f0:	85 d2                	test   %edx,%edx
  8009f2:	7e 2c                	jle    800a20 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a02:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a09:	c7 04 24 85 04 80 00 	movl   $0x800485,(%esp)
  800a10:	e8 b5 fa ff ff       	call   8004ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a18:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1e:	eb 05                	jmp    800a25 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a34:	8b 45 10             	mov    0x10(%ebp),%eax
  800a37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	89 04 24             	mov    %eax,(%esp)
  800a48:	e8 82 ff ff ff       	call   8009cf <vsnprintf>
	va_end(ap);

	return rc;
}
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    
	...

00800a50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a5e:	74 09                	je     800a69 <strlen+0x19>
		n++;
  800a60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a67:	75 f7                	jne    800a60 <strlen+0x10>
		n++;
	return n;
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	85 c9                	test   %ecx,%ecx
  800a7c:	74 1a                	je     800a98 <strnlen+0x2d>
  800a7e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a81:	74 15                	je     800a98 <strnlen+0x2d>
  800a83:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a88:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8a:	39 ca                	cmp    %ecx,%edx
  800a8c:	74 0a                	je     800a98 <strnlen+0x2d>
  800a8e:	83 c2 01             	add    $0x1,%edx
  800a91:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a96:	75 f0                	jne    800a88 <strnlen+0x1d>
		n++;
	return n;
}
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800aae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ab1:	83 c2 01             	add    $0x1,%edx
  800ab4:	84 c9                	test   %cl,%cl
  800ab6:	75 f2                	jne    800aaa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	83 ec 08             	sub    $0x8,%esp
  800ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac5:	89 1c 24             	mov    %ebx,(%esp)
  800ac8:	e8 83 ff ff ff       	call   800a50 <strlen>
	strcpy(dst + len, src);
  800acd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad4:	01 d8                	add    %ebx,%eax
  800ad6:	89 04 24             	mov    %eax,(%esp)
  800ad9:	e8 bd ff ff ff       	call   800a9b <strcpy>
	return dst;
}
  800ade:	89 d8                	mov    %ebx,%eax
  800ae0:	83 c4 08             	add    $0x8,%esp
  800ae3:	5b                   	pop    %ebx
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af4:	85 f6                	test   %esi,%esi
  800af6:	74 18                	je     800b10 <strncpy+0x2a>
  800af8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800afd:	0f b6 1a             	movzbl (%edx),%ebx
  800b00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b03:	80 3a 01             	cmpb   $0x1,(%edx)
  800b06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	39 f1                	cmp    %esi,%ecx
  800b0e:	75 ed                	jne    800afd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b20:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b23:	89 f8                	mov    %edi,%eax
  800b25:	85 f6                	test   %esi,%esi
  800b27:	74 2b                	je     800b54 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b29:	83 fe 01             	cmp    $0x1,%esi
  800b2c:	74 23                	je     800b51 <strlcpy+0x3d>
  800b2e:	0f b6 0b             	movzbl (%ebx),%ecx
  800b31:	84 c9                	test   %cl,%cl
  800b33:	74 1c                	je     800b51 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b35:	83 ee 02             	sub    $0x2,%esi
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b3d:	88 08                	mov    %cl,(%eax)
  800b3f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b42:	39 f2                	cmp    %esi,%edx
  800b44:	74 0b                	je     800b51 <strlcpy+0x3d>
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b4d:	84 c9                	test   %cl,%cl
  800b4f:	75 ec                	jne    800b3d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800b51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b54:	29 f8                	sub    %edi,%eax
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b64:	0f b6 01             	movzbl (%ecx),%eax
  800b67:	84 c0                	test   %al,%al
  800b69:	74 16                	je     800b81 <strcmp+0x26>
  800b6b:	3a 02                	cmp    (%edx),%al
  800b6d:	75 12                	jne    800b81 <strcmp+0x26>
		p++, q++;
  800b6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b72:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800b76:	84 c0                	test   %al,%al
  800b78:	74 07                	je     800b81 <strcmp+0x26>
  800b7a:	83 c1 01             	add    $0x1,%ecx
  800b7d:	3a 02                	cmp    (%edx),%al
  800b7f:	74 ee                	je     800b6f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b81:	0f b6 c0             	movzbl %al,%eax
  800b84:	0f b6 12             	movzbl (%edx),%edx
  800b87:	29 d0                	sub    %edx,%eax
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
  800b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b95:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b9d:	85 d2                	test   %edx,%edx
  800b9f:	74 28                	je     800bc9 <strncmp+0x3e>
  800ba1:	0f b6 01             	movzbl (%ecx),%eax
  800ba4:	84 c0                	test   %al,%al
  800ba6:	74 24                	je     800bcc <strncmp+0x41>
  800ba8:	3a 03                	cmp    (%ebx),%al
  800baa:	75 20                	jne    800bcc <strncmp+0x41>
  800bac:	83 ea 01             	sub    $0x1,%edx
  800baf:	74 13                	je     800bc4 <strncmp+0x39>
		n--, p++, q++;
  800bb1:	83 c1 01             	add    $0x1,%ecx
  800bb4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bb7:	0f b6 01             	movzbl (%ecx),%eax
  800bba:	84 c0                	test   %al,%al
  800bbc:	74 0e                	je     800bcc <strncmp+0x41>
  800bbe:	3a 03                	cmp    (%ebx),%al
  800bc0:	74 ea                	je     800bac <strncmp+0x21>
  800bc2:	eb 08                	jmp    800bcc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bcc:	0f b6 01             	movzbl (%ecx),%eax
  800bcf:	0f b6 13             	movzbl (%ebx),%edx
  800bd2:	29 d0                	sub    %edx,%eax
  800bd4:	eb f3                	jmp    800bc9 <strncmp+0x3e>

00800bd6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be0:	0f b6 10             	movzbl (%eax),%edx
  800be3:	84 d2                	test   %dl,%dl
  800be5:	74 1c                	je     800c03 <strchr+0x2d>
		if (*s == c)
  800be7:	38 ca                	cmp    %cl,%dl
  800be9:	75 09                	jne    800bf4 <strchr+0x1e>
  800beb:	eb 1b                	jmp    800c08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bed:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800bf0:	38 ca                	cmp    %cl,%dl
  800bf2:	74 14                	je     800c08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bf4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800bf8:	84 d2                	test   %dl,%dl
  800bfa:	75 f1                	jne    800bed <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800c01:	eb 05                	jmp    800c08 <strchr+0x32>
  800c03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c14:	0f b6 10             	movzbl (%eax),%edx
  800c17:	84 d2                	test   %dl,%dl
  800c19:	74 14                	je     800c2f <strfind+0x25>
		if (*s == c)
  800c1b:	38 ca                	cmp    %cl,%dl
  800c1d:	75 06                	jne    800c25 <strfind+0x1b>
  800c1f:	eb 0e                	jmp    800c2f <strfind+0x25>
  800c21:	38 ca                	cmp    %cl,%dl
  800c23:	74 0a                	je     800c2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c25:	83 c0 01             	add    $0x1,%eax
  800c28:	0f b6 10             	movzbl (%eax),%edx
  800c2b:	84 d2                	test   %dl,%dl
  800c2d:	75 f2                	jne    800c21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c3a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c49:	85 c9                	test   %ecx,%ecx
  800c4b:	74 30                	je     800c7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c53:	75 25                	jne    800c7a <memset+0x49>
  800c55:	f6 c1 03             	test   $0x3,%cl
  800c58:	75 20                	jne    800c7a <memset+0x49>
		c &= 0xFF;
  800c5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c5d:	89 d3                	mov    %edx,%ebx
  800c5f:	c1 e3 08             	shl    $0x8,%ebx
  800c62:	89 d6                	mov    %edx,%esi
  800c64:	c1 e6 18             	shl    $0x18,%esi
  800c67:	89 d0                	mov    %edx,%eax
  800c69:	c1 e0 10             	shl    $0x10,%eax
  800c6c:	09 f0                	or     %esi,%eax
  800c6e:	09 d0                	or     %edx,%eax
  800c70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c75:	fc                   	cld    
  800c76:	f3 ab                	rep stos %eax,%es:(%edi)
  800c78:	eb 03                	jmp    800c7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c7a:	fc                   	cld    
  800c7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c7d:	89 f8                	mov    %edi,%eax
  800c7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c88:	89 ec                	mov    %ebp,%esp
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 08             	sub    $0x8,%esp
  800c92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c95:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ca1:	39 c6                	cmp    %eax,%esi
  800ca3:	73 36                	jae    800cdb <memmove+0x4f>
  800ca5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ca8:	39 d0                	cmp    %edx,%eax
  800caa:	73 2f                	jae    800cdb <memmove+0x4f>
		s += n;
		d += n;
  800cac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800caf:	f6 c2 03             	test   $0x3,%dl
  800cb2:	75 1b                	jne    800ccf <memmove+0x43>
  800cb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cba:	75 13                	jne    800ccf <memmove+0x43>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 0e                	jne    800ccf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cc1:	83 ef 04             	sub    $0x4,%edi
  800cc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cca:	fd                   	std    
  800ccb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccd:	eb 09                	jmp    800cd8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ccf:	83 ef 01             	sub    $0x1,%edi
  800cd2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cd5:	fd                   	std    
  800cd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cd8:	fc                   	cld    
  800cd9:	eb 20                	jmp    800cfb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cdb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ce1:	75 13                	jne    800cf6 <memmove+0x6a>
  800ce3:	a8 03                	test   $0x3,%al
  800ce5:	75 0f                	jne    800cf6 <memmove+0x6a>
  800ce7:	f6 c1 03             	test   $0x3,%cl
  800cea:	75 0a                	jne    800cf6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cef:	89 c7                	mov    %eax,%edi
  800cf1:	fc                   	cld    
  800cf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf4:	eb 05                	jmp    800cfb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cf6:	89 c7                	mov    %eax,%edi
  800cf8:	fc                   	cld    
  800cf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cfb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d01:	89 ec                	mov    %ebp,%esp
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	89 04 24             	mov    %eax,(%esp)
  800d1f:	e8 68 ff ff ff       	call   800c8c <memmove>
}
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    

00800d26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d32:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3a:	85 ff                	test   %edi,%edi
  800d3c:	74 37                	je     800d75 <memcmp+0x4f>
		if (*s1 != *s2)
  800d3e:	0f b6 03             	movzbl (%ebx),%eax
  800d41:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d44:	83 ef 01             	sub    $0x1,%edi
  800d47:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800d4c:	38 c8                	cmp    %cl,%al
  800d4e:	74 1c                	je     800d6c <memcmp+0x46>
  800d50:	eb 10                	jmp    800d62 <memcmp+0x3c>
  800d52:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d57:	83 c2 01             	add    $0x1,%edx
  800d5a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d5e:	38 c8                	cmp    %cl,%al
  800d60:	74 0a                	je     800d6c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800d62:	0f b6 c0             	movzbl %al,%eax
  800d65:	0f b6 c9             	movzbl %cl,%ecx
  800d68:	29 c8                	sub    %ecx,%eax
  800d6a:	eb 09                	jmp    800d75 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d6c:	39 fa                	cmp    %edi,%edx
  800d6e:	75 e2                	jne    800d52 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d80:	89 c2                	mov    %eax,%edx
  800d82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d85:	39 d0                	cmp    %edx,%eax
  800d87:	73 19                	jae    800da2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d8d:	38 08                	cmp    %cl,(%eax)
  800d8f:	75 06                	jne    800d97 <memfind+0x1d>
  800d91:	eb 0f                	jmp    800da2 <memfind+0x28>
  800d93:	38 08                	cmp    %cl,(%eax)
  800d95:	74 0b                	je     800da2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d97:	83 c0 01             	add    $0x1,%eax
  800d9a:	39 d0                	cmp    %edx,%eax
  800d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da0:	75 f1                	jne    800d93 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db0:	0f b6 02             	movzbl (%edx),%eax
  800db3:	3c 20                	cmp    $0x20,%al
  800db5:	74 04                	je     800dbb <strtol+0x17>
  800db7:	3c 09                	cmp    $0x9,%al
  800db9:	75 0e                	jne    800dc9 <strtol+0x25>
		s++;
  800dbb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbe:	0f b6 02             	movzbl (%edx),%eax
  800dc1:	3c 20                	cmp    $0x20,%al
  800dc3:	74 f6                	je     800dbb <strtol+0x17>
  800dc5:	3c 09                	cmp    $0x9,%al
  800dc7:	74 f2                	je     800dbb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc9:	3c 2b                	cmp    $0x2b,%al
  800dcb:	75 0a                	jne    800dd7 <strtol+0x33>
		s++;
  800dcd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd5:	eb 10                	jmp    800de7 <strtol+0x43>
  800dd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ddc:	3c 2d                	cmp    $0x2d,%al
  800dde:	75 07                	jne    800de7 <strtol+0x43>
		s++, neg = 1;
  800de0:	83 c2 01             	add    $0x1,%edx
  800de3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de7:	85 db                	test   %ebx,%ebx
  800de9:	0f 94 c0             	sete   %al
  800dec:	74 05                	je     800df3 <strtol+0x4f>
  800dee:	83 fb 10             	cmp    $0x10,%ebx
  800df1:	75 15                	jne    800e08 <strtol+0x64>
  800df3:	80 3a 30             	cmpb   $0x30,(%edx)
  800df6:	75 10                	jne    800e08 <strtol+0x64>
  800df8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dfc:	75 0a                	jne    800e08 <strtol+0x64>
		s += 2, base = 16;
  800dfe:	83 c2 02             	add    $0x2,%edx
  800e01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e06:	eb 13                	jmp    800e1b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e08:	84 c0                	test   %al,%al
  800e0a:	74 0f                	je     800e1b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e11:	80 3a 30             	cmpb   $0x30,(%edx)
  800e14:	75 05                	jne    800e1b <strtol+0x77>
		s++, base = 8;
  800e16:	83 c2 01             	add    $0x1,%edx
  800e19:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e22:	0f b6 0a             	movzbl (%edx),%ecx
  800e25:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e28:	80 fb 09             	cmp    $0x9,%bl
  800e2b:	77 08                	ja     800e35 <strtol+0x91>
			dig = *s - '0';
  800e2d:	0f be c9             	movsbl %cl,%ecx
  800e30:	83 e9 30             	sub    $0x30,%ecx
  800e33:	eb 1e                	jmp    800e53 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800e35:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e38:	80 fb 19             	cmp    $0x19,%bl
  800e3b:	77 08                	ja     800e45 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800e3d:	0f be c9             	movsbl %cl,%ecx
  800e40:	83 e9 57             	sub    $0x57,%ecx
  800e43:	eb 0e                	jmp    800e53 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800e45:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e48:	80 fb 19             	cmp    $0x19,%bl
  800e4b:	77 14                	ja     800e61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e4d:	0f be c9             	movsbl %cl,%ecx
  800e50:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e53:	39 f1                	cmp    %esi,%ecx
  800e55:	7d 0e                	jge    800e65 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e57:	83 c2 01             	add    $0x1,%edx
  800e5a:	0f af c6             	imul   %esi,%eax
  800e5d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e5f:	eb c1                	jmp    800e22 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e61:	89 c1                	mov    %eax,%ecx
  800e63:	eb 02                	jmp    800e67 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e65:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6b:	74 05                	je     800e72 <strtol+0xce>
		*endptr = (char *) s;
  800e6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e70:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e72:	89 ca                	mov    %ecx,%edx
  800e74:	f7 da                	neg    %edx
  800e76:	85 ff                	test   %edi,%edi
  800e78:	0f 45 c2             	cmovne %edx,%eax
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eab:	89 ec                	mov    %ebp,%esp
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_cgetc>:

int
sys_cgetc(void)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 0c             	sub    $0xc,%esp
  800eb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec8:	89 d1                	mov    %edx,%ecx
  800eca:	89 d3                	mov    %edx,%ebx
  800ecc:	89 d7                	mov    %edx,%edi
  800ece:	89 d6                	mov    %edx,%esi
  800ed0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ed2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800edb:	89 ec                	mov    %ebp,%esp
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 38             	sub    $0x38,%esp
  800ee5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eeb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	89 cb                	mov    %ecx,%ebx
  800efd:	89 cf                	mov    %ecx,%edi
  800eff:	89 ce                	mov    %ecx,%esi
  800f01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f03:	85 c0                	test   %eax,%eax
  800f05:	7e 28                	jle    800f2f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f12:	00 
  800f13:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f22:	00 
  800f23:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  800f2a:	e8 29 f3 ff ff       	call   800258 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f50:	b8 02 00 00 00       	mov    $0x2,%eax
  800f55:	89 d1                	mov    %edx,%ecx
  800f57:	89 d3                	mov    %edx,%ebx
  800f59:	89 d7                	mov    %edx,%edi
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_yield>:

void
sys_yield(void)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f85:	89 d1                	mov    %edx,%ecx
  800f87:	89 d3                	mov    %edx,%ebx
  800f89:	89 d7                	mov    %edx,%edi
  800f8b:	89 d6                	mov    %edx,%esi
  800f8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f98:	89 ec                	mov    %ebp,%esp
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 38             	sub    $0x38,%esp
  800fa2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	be 00 00 00 00       	mov    $0x0,%esi
  800fb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbe:	89 f7                	mov    %esi,%edi
  800fc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	7e 28                	jle    800fee <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  800fd9:	00 
  800fda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe1:	00 
  800fe2:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  800fe9:	e8 6a f2 ff ff       	call   800258 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff7:	89 ec                	mov    %ebp,%esp
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 38             	sub    $0x38,%esp
  801001:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801004:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801007:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100a:	b8 05 00 00 00       	mov    $0x5,%eax
  80100f:	8b 75 18             	mov    0x18(%ebp),%esi
  801012:	8b 7d 14             	mov    0x14(%ebp),%edi
  801015:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801020:	85 c0                	test   %eax,%eax
  801022:	7e 28                	jle    80104c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801024:	89 44 24 10          	mov    %eax,0x10(%esp)
  801028:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80102f:	00 
  801030:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  801037:	00 
  801038:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103f:	00 
  801040:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  801047:	e8 0c f2 ff ff       	call   800258 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80104c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801052:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801055:	89 ec                	mov    %ebp,%esp
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	83 ec 38             	sub    $0x38,%esp
  80105f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801062:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801065:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801068:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106d:	b8 06 00 00 00       	mov    $0x6,%eax
  801072:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801075:	8b 55 08             	mov    0x8(%ebp),%edx
  801078:	89 df                	mov    %ebx,%edi
  80107a:	89 de                	mov    %ebx,%esi
  80107c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107e:	85 c0                	test   %eax,%eax
  801080:	7e 28                	jle    8010aa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801082:	89 44 24 10          	mov    %eax,0x10(%esp)
  801086:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80108d:	00 
  80108e:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  801095:	00 
  801096:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109d:	00 
  80109e:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  8010a5:	e8 ae f1 ff ff       	call   800258 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010aa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b3:	89 ec                	mov    %ebp,%esp
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 38             	sub    $0x38,%esp
  8010bd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010c0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8010d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d6:	89 df                	mov    %ebx,%edi
  8010d8:	89 de                	mov    %ebx,%esi
  8010da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	7e 28                	jle    801108 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010eb:	00 
  8010ec:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010fb:	00 
  8010fc:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  801103:	e8 50 f1 ff ff       	call   800258 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801108:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80110b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801111:	89 ec                	mov    %ebp,%esp
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  801124:	bb 00 00 00 00       	mov    $0x0,%ebx
  801129:	b8 09 00 00 00       	mov    $0x9,%eax
  80112e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801131:	8b 55 08             	mov    0x8(%ebp),%edx
  801134:	89 df                	mov    %ebx,%edi
  801136:	89 de                	mov    %ebx,%esi
  801138:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113a:	85 c0                	test   %eax,%eax
  80113c:	7e 28                	jle    801166 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801142:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801149:	00 
  80114a:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  801151:	00 
  801152:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801159:	00 
  80115a:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  801161:	e8 f2 f0 ff ff       	call   800258 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801166:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801169:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80116f:	89 ec                	mov    %ebp,%esp
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	83 ec 38             	sub    $0x38,%esp
  801179:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80117c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80117f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801182:	bb 00 00 00 00       	mov    $0x0,%ebx
  801187:	b8 0a 00 00 00       	mov    $0xa,%eax
  80118c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118f:	8b 55 08             	mov    0x8(%ebp),%edx
  801192:	89 df                	mov    %ebx,%edi
  801194:	89 de                	mov    %ebx,%esi
  801196:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801198:	85 c0                	test   %eax,%eax
  80119a:	7e 28                	jle    8011c4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  8011af:	00 
  8011b0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b7:	00 
  8011b8:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  8011bf:	e8 94 f0 ff ff       	call   800258 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011c4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011c7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011cd:	89 ec                	mov    %ebp,%esp
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 0c             	sub    $0xc,%esp
  8011d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011da:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e0:	be 00 00 00 00       	mov    $0x0,%esi
  8011e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801201:	89 ec                	mov    %ebp,%esp
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	83 ec 38             	sub    $0x38,%esp
  80120b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80120e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801211:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801214:	b9 00 00 00 00       	mov    $0x0,%ecx
  801219:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121e:	8b 55 08             	mov    0x8(%ebp),%edx
  801221:	89 cb                	mov    %ecx,%ebx
  801223:	89 cf                	mov    %ecx,%edi
  801225:	89 ce                	mov    %ecx,%esi
  801227:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801229:	85 c0                	test   %eax,%eax
  80122b:	7e 28                	jle    801255 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801231:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801238:	00 
  801239:	c7 44 24 08 7f 2d 80 	movl   $0x802d7f,0x8(%esp)
  801240:	00 
  801241:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801248:	00 
  801249:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  801250:	e8 03 f0 ff ff       	call   800258 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801255:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801258:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80125b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80125e:	89 ec                	mov    %ebp,%esp
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 0c             	sub    $0xc,%esp
  801268:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80126b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80126e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801271:	b9 00 00 00 00       	mov    $0x0,%ecx
  801276:	b8 0e 00 00 00       	mov    $0xe,%eax
  80127b:	8b 55 08             	mov    0x8(%ebp),%edx
  80127e:	89 cb                	mov    %ecx,%ebx
  801280:	89 cf                	mov    %ecx,%edi
  801282:	89 ce                	mov    %ecx,%esi
  801284:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801286:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801289:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80128c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80128f:	89 ec                	mov    %ebp,%esp
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    
	...

00801294 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	53                   	push   %ebx
  801298:	83 ec 24             	sub    $0x24,%esp
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80129e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  8012a0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8012a4:	75 1c                	jne    8012c2 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  8012a6:	c7 44 24 08 aa 2d 80 	movl   $0x802daa,0x8(%esp)
  8012ad:	00 
  8012ae:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8012b5:	00 
  8012b6:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  8012bd:	e8 96 ef ff ff       	call   800258 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  8012c2:	89 d8                	mov    %ebx,%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
  8012c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ce:	f6 c4 08             	test   $0x8,%ah
  8012d1:	0f 84 be 00 00 00    	je     801395 <pgfault+0x101>
  8012d7:	89 d8                	mov    %ebx,%eax
  8012d9:	c1 e8 16             	shr    $0x16,%eax
  8012dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e3:	a8 01                	test   $0x1,%al
  8012e5:	0f 84 aa 00 00 00    	je     801395 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  8012eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012fa:	00 
  8012fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801302:	e8 95 fc ff ff       	call   800f9c <sys_page_alloc>
		if (r < 0)
  801307:	85 c0                	test   %eax,%eax
  801309:	79 20                	jns    80132b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80130b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130f:	c7 44 24 08 e4 2d 80 	movl   $0x802de4,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  801326:	e8 2d ef ff ff       	call   800258 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80132b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801331:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801338:	00 
  801339:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80133d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801344:	e8 bc f9 ff ff       	call   800d05 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801349:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801350:	00 
  801351:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801355:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80135c:	00 
  80135d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801364:	00 
  801365:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80136c:	e8 8a fc ff ff       	call   800ffb <sys_page_map>
		if (r < 0)
  801371:	85 c0                	test   %eax,%eax
  801373:	79 3c                	jns    8013b1 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  801375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801379:	c7 44 24 08 0c 2e 80 	movl   $0x802e0c,0x8(%esp)
  801380:	00 
  801381:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801388:	00 
  801389:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  801390:	e8 c3 ee ff ff       	call   800258 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801395:	c7 44 24 08 30 2e 80 	movl   $0x802e30,0x8(%esp)
  80139c:	00 
  80139d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8013a4:	00 
  8013a5:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  8013ac:	e8 a7 ee ff ff       	call   800258 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  8013b1:	83 c4 24             	add    $0x24,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	57                   	push   %edi
  8013bb:	56                   	push   %esi
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8013c0:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  8013c7:	e8 c4 10 00 00       	call   802490 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8013cc:	bf 07 00 00 00       	mov    $0x7,%edi
  8013d1:	89 f8                	mov    %edi,%eax
  8013d3:	cd 30                	int    $0x30
  8013d5:	89 c7                	mov    %eax,%edi
  8013d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	79 20                	jns    8013fe <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  8013de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e2:	c7 44 24 08 50 2e 80 	movl   $0x802e50,0x8(%esp)
  8013e9:	00 
  8013ea:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8013f1:	00 
  8013f2:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  8013f9:	e8 5a ee ff ff       	call   800258 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  8013fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801403:	85 c0                	test   %eax,%eax
  801405:	75 1c                	jne    801423 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801407:	e8 30 fb ff ff       	call   800f3c <sys_getenvid>
  80140c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801411:	c1 e0 07             	shl    $0x7,%eax
  801414:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801419:	a3 04 50 80 00       	mov    %eax,0x805004
		//cprintf("child fork ok!\n");
		return 0;
  80141e:	e9 51 02 00 00       	jmp    801674 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801423:	89 d8                	mov    %ebx,%eax
  801425:	c1 e8 16             	shr    $0x16,%eax
  801428:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142f:	a8 01                	test   $0x1,%al
  801431:	0f 84 87 01 00 00    	je     8015be <fork+0x207>
  801437:	89 d8                	mov    %ebx,%eax
  801439:	c1 e8 0c             	shr    $0xc,%eax
  80143c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801443:	f6 c2 01             	test   $0x1,%dl
  801446:	0f 84 72 01 00 00    	je     8015be <fork+0x207>
  80144c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801453:	f6 c2 04             	test   $0x4,%dl
  801456:	0f 84 62 01 00 00    	je     8015be <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80145c:	89 c6                	mov    %eax,%esi
  80145e:	c1 e6 0c             	shl    $0xc,%esi
  801461:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801467:	0f 84 51 01 00 00    	je     8015be <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  80146d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801474:	f6 c6 04             	test   $0x4,%dh
  801477:	74 53                	je     8014cc <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801479:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801480:	25 07 0e 00 00       	and    $0xe07,%eax
  801485:	89 44 24 10          	mov    %eax,0x10(%esp)
  801489:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80148d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801490:	89 44 24 08          	mov    %eax,0x8(%esp)
  801494:	89 74 24 04          	mov    %esi,0x4(%esp)
  801498:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149f:	e8 57 fb ff ff       	call   800ffb <sys_page_map>
		if (r < 0)
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	0f 89 12 01 00 00    	jns    8015be <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  8014ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b0:	c7 44 24 08 70 2e 80 	movl   $0x802e70,0x8(%esp)
  8014b7:	00 
  8014b8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8014bf:	00 
  8014c0:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  8014c7:	e8 8c ed ff ff       	call   800258 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  8014cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d3:	f6 c2 02             	test   $0x2,%dl
  8014d6:	75 10                	jne    8014e8 <fork+0x131>
  8014d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014df:	f6 c4 08             	test   $0x8,%ah
  8014e2:	0f 84 8f 00 00 00    	je     801577 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8014e8:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8014ef:	00 
  8014f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801506:	e8 f0 fa ff ff       	call   800ffb <sys_page_map>
		if (r < 0)
  80150b:	85 c0                	test   %eax,%eax
  80150d:	79 20                	jns    80152f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80150f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801513:	c7 44 24 08 9c 2e 80 	movl   $0x802e9c,0x8(%esp)
  80151a:	00 
  80151b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801522:	00 
  801523:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  80152a:	e8 29 ed ff ff       	call   800258 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80152f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801536:	00 
  801537:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80153b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801542:	00 
  801543:	89 74 24 04          	mov    %esi,0x4(%esp)
  801547:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80154e:	e8 a8 fa ff ff       	call   800ffb <sys_page_map>
		if (r < 0)
  801553:	85 c0                	test   %eax,%eax
  801555:	79 67                	jns    8015be <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801557:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80155b:	c7 44 24 08 9c 2e 80 	movl   $0x802e9c,0x8(%esp)
  801562:	00 
  801563:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80156a:	00 
  80156b:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  801572:	e8 e1 ec ff ff       	call   800258 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  801577:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80157e:	00 
  80157f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801586:	89 44 24 08          	mov    %eax,0x8(%esp)
  80158a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801595:	e8 61 fa ff ff       	call   800ffb <sys_page_map>
		if (r < 0)
  80159a:	85 c0                	test   %eax,%eax
  80159c:	79 20                	jns    8015be <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  80159e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a2:	c7 44 24 08 9c 2e 80 	movl   $0x802e9c,0x8(%esp)
  8015a9:	00 
  8015aa:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8015b1:	00 
  8015b2:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  8015b9:	e8 9a ec ff ff       	call   800258 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  8015be:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015c4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8015ca:	0f 85 53 fe ff ff    	jne    801423 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8015d0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015d7:	00 
  8015d8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015df:	ee 
  8015e0:	89 3c 24             	mov    %edi,(%esp)
  8015e3:	e8 b4 f9 ff ff       	call   800f9c <sys_page_alloc>
	if (res < 0)
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	79 20                	jns    80160c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  8015ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f0:	c7 44 24 08 c0 2e 80 	movl   $0x802ec0,0x8(%esp)
  8015f7:	00 
  8015f8:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8015ff:	00 
  801600:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  801607:	e8 4c ec ff ff       	call   800258 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80160c:	c7 44 24 04 1c 25 80 	movl   $0x80251c,0x4(%esp)
  801613:	00 
  801614:	89 3c 24             	mov    %edi,(%esp)
  801617:	e8 57 fb ff ff       	call   801173 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80161c:	85 c0                	test   %eax,%eax
  80161e:	79 20                	jns    801640 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801620:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801624:	c7 44 24 08 e4 2e 80 	movl   $0x802ee4,0x8(%esp)
  80162b:	00 
  80162c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801633:	00 
  801634:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  80163b:	e8 18 ec ff ff       	call   800258 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801640:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801647:	00 
  801648:	89 3c 24             	mov    %edi,(%esp)
  80164b:	e8 67 fa ff ff       	call   8010b7 <sys_env_set_status>
	if (res < 0)
  801650:	85 c0                	test   %eax,%eax
  801652:	79 20                	jns    801674 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801654:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801658:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  80165f:	00 
  801660:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801667:	00 
  801668:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  80166f:	e8 e4 eb ff ff       	call   800258 <_panic>

	return pid;
	//panic("fork not implemented");
}
  801674:	89 f8                	mov    %edi,%eax
  801676:	83 c4 3c             	add    $0x3c,%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <sfork>:

// Challenge!
int
sfork(void)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801684:	c7 44 24 08 cc 2d 80 	movl   $0x802dcc,0x8(%esp)
  80168b:	00 
  80168c:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801693:	00 
  801694:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  80169b:	e8 b8 eb ff ff       	call   800258 <_panic>

008016a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	89 04 24             	mov    %eax,(%esp)
  8016bc:	e8 df ff ff ff       	call   8016a0 <fd2num>
  8016c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016d2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016d7:	a8 01                	test   $0x1,%al
  8016d9:	74 34                	je     80170f <fd_alloc+0x44>
  8016db:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016e0:	a8 01                	test   $0x1,%al
  8016e2:	74 32                	je     801716 <fd_alloc+0x4b>
  8016e4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016e9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016eb:	89 c2                	mov    %eax,%edx
  8016ed:	c1 ea 16             	shr    $0x16,%edx
  8016f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016f7:	f6 c2 01             	test   $0x1,%dl
  8016fa:	74 1f                	je     80171b <fd_alloc+0x50>
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	c1 ea 0c             	shr    $0xc,%edx
  801701:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801708:	f6 c2 01             	test   $0x1,%dl
  80170b:	75 17                	jne    801724 <fd_alloc+0x59>
  80170d:	eb 0c                	jmp    80171b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80170f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801714:	eb 05                	jmp    80171b <fd_alloc+0x50>
  801716:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80171b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
  801722:	eb 17                	jmp    80173b <fd_alloc+0x70>
  801724:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801729:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80172e:	75 b9                	jne    8016e9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801730:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801736:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80173b:	5b                   	pop    %ebx
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801744:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801749:	83 fa 1f             	cmp    $0x1f,%edx
  80174c:	77 3f                	ja     80178d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80174e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801754:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801757:	89 d0                	mov    %edx,%eax
  801759:	c1 e8 16             	shr    $0x16,%eax
  80175c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801768:	f6 c1 01             	test   $0x1,%cl
  80176b:	74 20                	je     80178d <fd_lookup+0x4f>
  80176d:	89 d0                	mov    %edx,%eax
  80176f:	c1 e8 0c             	shr    $0xc,%eax
  801772:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80177e:	f6 c1 01             	test   $0x1,%cl
  801781:	74 0a                	je     80178d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801783:	8b 45 0c             	mov    0xc(%ebp),%eax
  801786:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	53                   	push   %ebx
  801793:	83 ec 14             	sub    $0x14,%esp
  801796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80179c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8017a1:	39 0d 08 40 80 00    	cmp    %ecx,0x804008
  8017a7:	75 17                	jne    8017c0 <dev_lookup+0x31>
  8017a9:	eb 07                	jmp    8017b2 <dev_lookup+0x23>
  8017ab:	39 0a                	cmp    %ecx,(%edx)
  8017ad:	75 11                	jne    8017c0 <dev_lookup+0x31>
  8017af:	90                   	nop
  8017b0:	eb 05                	jmp    8017b7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017b2:	ba 08 40 80 00       	mov    $0x804008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8017b7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017be:	eb 35                	jmp    8017f5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017c0:	83 c0 01             	add    $0x1,%eax
  8017c3:	8b 14 85 b8 2f 80 00 	mov    0x802fb8(,%eax,4),%edx
  8017ca:	85 d2                	test   %edx,%edx
  8017cc:	75 dd                	jne    8017ab <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017ce:	a1 04 50 80 00       	mov    0x805004,%eax
  8017d3:	8b 40 48             	mov    0x48(%eax),%eax
  8017d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017de:	c7 04 24 3c 2f 80 00 	movl   $0x802f3c,(%esp)
  8017e5:	e8 69 eb ff ff       	call   800353 <cprintf>
	*dev = 0;
  8017ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8017f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017f5:	83 c4 14             	add    $0x14,%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	83 ec 38             	sub    $0x38,%esp
  801801:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801804:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801807:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80180a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801811:	89 3c 24             	mov    %edi,(%esp)
  801814:	e8 87 fe ff ff       	call   8016a0 <fd2num>
  801819:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80181c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801820:	89 04 24             	mov    %eax,(%esp)
  801823:	e8 16 ff ff ff       	call   80173e <fd_lookup>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 05                	js     801833 <fd_close+0x38>
	    || fd != fd2)
  80182e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801831:	74 0e                	je     801841 <fd_close+0x46>
		return (must_exist ? r : 0);
  801833:	89 f0                	mov    %esi,%eax
  801835:	84 c0                	test   %al,%al
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
  80183c:	0f 44 d8             	cmove  %eax,%ebx
  80183f:	eb 3d                	jmp    80187e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801841:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801844:	89 44 24 04          	mov    %eax,0x4(%esp)
  801848:	8b 07                	mov    (%edi),%eax
  80184a:	89 04 24             	mov    %eax,(%esp)
  80184d:	e8 3d ff ff ff       	call   80178f <dev_lookup>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	85 c0                	test   %eax,%eax
  801856:	78 16                	js     80186e <fd_close+0x73>
		if (dev->dev_close)
  801858:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80185b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80185e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801863:	85 c0                	test   %eax,%eax
  801865:	74 07                	je     80186e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801867:	89 3c 24             	mov    %edi,(%esp)
  80186a:	ff d0                	call   *%eax
  80186c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80186e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801872:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801879:	e8 db f7 ff ff       	call   801059 <sys_page_unmap>
	return r;
}
  80187e:	89 d8                	mov    %ebx,%eax
  801880:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801883:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801886:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801889:	89 ec                	mov    %ebp,%esp
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801893:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	89 04 24             	mov    %eax,(%esp)
  8018a0:	e8 99 fe ff ff       	call   80173e <fd_lookup>
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 13                	js     8018bc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8018a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018b0:	00 
  8018b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b4:	89 04 24             	mov    %eax,(%esp)
  8018b7:	e8 3f ff ff ff       	call   8017fb <fd_close>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <close_all>:

void
close_all(void)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8018c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8018ca:	89 1c 24             	mov    %ebx,(%esp)
  8018cd:	e8 bb ff ff ff       	call   80188d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018d2:	83 c3 01             	add    $0x1,%ebx
  8018d5:	83 fb 20             	cmp    $0x20,%ebx
  8018d8:	75 f0                	jne    8018ca <close_all+0xc>
		close(i);
}
  8018da:	83 c4 14             	add    $0x14,%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 58             	sub    $0x58,%esp
  8018e6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8018e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8018ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 3a fe ff ff       	call   80173e <fd_lookup>
  801904:	89 c3                	mov    %eax,%ebx
  801906:	85 c0                	test   %eax,%eax
  801908:	0f 88 e1 00 00 00    	js     8019ef <dup+0x10f>
		return r;
	close(newfdnum);
  80190e:	89 3c 24             	mov    %edi,(%esp)
  801911:	e8 77 ff ff ff       	call   80188d <close>

	newfd = INDEX2FD(newfdnum);
  801916:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80191c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80191f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801922:	89 04 24             	mov    %eax,(%esp)
  801925:	e8 86 fd ff ff       	call   8016b0 <fd2data>
  80192a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80192c:	89 34 24             	mov    %esi,(%esp)
  80192f:	e8 7c fd ff ff       	call   8016b0 <fd2data>
  801934:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801937:	89 d8                	mov    %ebx,%eax
  801939:	c1 e8 16             	shr    $0x16,%eax
  80193c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801943:	a8 01                	test   $0x1,%al
  801945:	74 46                	je     80198d <dup+0xad>
  801947:	89 d8                	mov    %ebx,%eax
  801949:	c1 e8 0c             	shr    $0xc,%eax
  80194c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801953:	f6 c2 01             	test   $0x1,%dl
  801956:	74 35                	je     80198d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801958:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80195f:	25 07 0e 00 00       	and    $0xe07,%eax
  801964:	89 44 24 10          	mov    %eax,0x10(%esp)
  801968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80196b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80196f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801976:	00 
  801977:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801982:	e8 74 f6 ff ff       	call   800ffb <sys_page_map>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 3b                	js     8019c8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80198d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801990:	89 c2                	mov    %eax,%edx
  801992:	c1 ea 0c             	shr    $0xc,%edx
  801995:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80199c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8019a2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019b1:	00 
  8019b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019bd:	e8 39 f6 ff ff       	call   800ffb <sys_page_map>
  8019c2:	89 c3                	mov    %eax,%ebx
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	79 25                	jns    8019ed <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d3:	e8 81 f6 ff ff       	call   801059 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8019d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e6:	e8 6e f6 ff ff       	call   801059 <sys_page_unmap>
	return r;
  8019eb:	eb 02                	jmp    8019ef <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8019ed:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019f4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019fa:	89 ec                	mov    %ebp,%esp
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	53                   	push   %ebx
  801a02:	83 ec 24             	sub    $0x24,%esp
  801a05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0f:	89 1c 24             	mov    %ebx,(%esp)
  801a12:	e8 27 fd ff ff       	call   80173e <fd_lookup>
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 6d                	js     801a88 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a25:	8b 00                	mov    (%eax),%eax
  801a27:	89 04 24             	mov    %eax,(%esp)
  801a2a:	e8 60 fd ff ff       	call   80178f <dev_lookup>
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 55                	js     801a88 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a36:	8b 50 08             	mov    0x8(%eax),%edx
  801a39:	83 e2 03             	and    $0x3,%edx
  801a3c:	83 fa 01             	cmp    $0x1,%edx
  801a3f:	75 23                	jne    801a64 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a41:	a1 04 50 80 00       	mov    0x805004,%eax
  801a46:	8b 40 48             	mov    0x48(%eax),%eax
  801a49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a51:	c7 04 24 7d 2f 80 00 	movl   $0x802f7d,(%esp)
  801a58:	e8 f6 e8 ff ff       	call   800353 <cprintf>
		return -E_INVAL;
  801a5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a62:	eb 24                	jmp    801a88 <read+0x8a>
	}
	if (!dev->dev_read)
  801a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a67:	8b 52 08             	mov    0x8(%edx),%edx
  801a6a:	85 d2                	test   %edx,%edx
  801a6c:	74 15                	je     801a83 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801a6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a71:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a78:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a7c:	89 04 24             	mov    %eax,(%esp)
  801a7f:	ff d2                	call   *%edx
  801a81:	eb 05                	jmp    801a88 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a83:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801a88:	83 c4 24             	add    $0x24,%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	57                   	push   %edi
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	83 ec 1c             	sub    $0x1c,%esp
  801a97:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa2:	85 f6                	test   %esi,%esi
  801aa4:	74 30                	je     801ad6 <readn+0x48>
  801aa6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801aab:	89 f2                	mov    %esi,%edx
  801aad:	29 c2                	sub    %eax,%edx
  801aaf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ab3:	03 45 0c             	add    0xc(%ebp),%eax
  801ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aba:	89 3c 24             	mov    %edi,(%esp)
  801abd:	e8 3c ff ff ff       	call   8019fe <read>
		if (m < 0)
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 10                	js     801ad6 <readn+0x48>
			return m;
		if (m == 0)
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	74 0a                	je     801ad4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aca:	01 c3                	add    %eax,%ebx
  801acc:	89 d8                	mov    %ebx,%eax
  801ace:	39 f3                	cmp    %esi,%ebx
  801ad0:	72 d9                	jb     801aab <readn+0x1d>
  801ad2:	eb 02                	jmp    801ad6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801ad4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801ad6:	83 c4 1c             	add    $0x1c,%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	53                   	push   %ebx
  801ae2:	83 ec 24             	sub    $0x24,%esp
  801ae5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ae8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aef:	89 1c 24             	mov    %ebx,(%esp)
  801af2:	e8 47 fc ff ff       	call   80173e <fd_lookup>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 68                	js     801b63 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801afb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b05:	8b 00                	mov    (%eax),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 80 fc ff ff       	call   80178f <dev_lookup>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 50                	js     801b63 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b16:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b1a:	75 23                	jne    801b3f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b1c:	a1 04 50 80 00       	mov    0x805004,%eax
  801b21:	8b 40 48             	mov    0x48(%eax),%eax
  801b24:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2c:	c7 04 24 99 2f 80 00 	movl   $0x802f99,(%esp)
  801b33:	e8 1b e8 ff ff       	call   800353 <cprintf>
		return -E_INVAL;
  801b38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b3d:	eb 24                	jmp    801b63 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b42:	8b 52 0c             	mov    0xc(%edx),%edx
  801b45:	85 d2                	test   %edx,%edx
  801b47:	74 15                	je     801b5e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b49:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b4c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b53:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b57:	89 04 24             	mov    %eax,(%esp)
  801b5a:	ff d2                	call   *%edx
  801b5c:	eb 05                	jmp    801b63 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b5e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b63:	83 c4 24             	add    $0x24,%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b6f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 bd fb ff ff       	call   80173e <fd_lookup>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 0e                	js     801b93 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b85:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b8b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	53                   	push   %ebx
  801b99:	83 ec 24             	sub    $0x24,%esp
  801b9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba6:	89 1c 24             	mov    %ebx,(%esp)
  801ba9:	e8 90 fb ff ff       	call   80173e <fd_lookup>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 61                	js     801c13 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bbc:	8b 00                	mov    (%eax),%eax
  801bbe:	89 04 24             	mov    %eax,(%esp)
  801bc1:	e8 c9 fb ff ff       	call   80178f <dev_lookup>
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 49                	js     801c13 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bcd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bd1:	75 23                	jne    801bf6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bd3:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bd8:	8b 40 48             	mov    0x48(%eax),%eax
  801bdb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be3:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  801bea:	e8 64 e7 ff ff       	call   800353 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bf4:	eb 1d                	jmp    801c13 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf9:	8b 52 18             	mov    0x18(%edx),%edx
  801bfc:	85 d2                	test   %edx,%edx
  801bfe:	74 0e                	je     801c0e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c03:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c07:	89 04 24             	mov    %eax,(%esp)
  801c0a:	ff d2                	call   *%edx
  801c0c:	eb 05                	jmp    801c13 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c0e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801c13:	83 c4 24             	add    $0x24,%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 24             	sub    $0x24,%esp
  801c20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c23:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2d:	89 04 24             	mov    %eax,(%esp)
  801c30:	e8 09 fb ff ff       	call   80173e <fd_lookup>
  801c35:	85 c0                	test   %eax,%eax
  801c37:	78 52                	js     801c8b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c43:	8b 00                	mov    (%eax),%eax
  801c45:	89 04 24             	mov    %eax,(%esp)
  801c48:	e8 42 fb ff ff       	call   80178f <dev_lookup>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 3a                	js     801c8b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c54:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c58:	74 2c                	je     801c86 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c5a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c5d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c64:	00 00 00 
	stat->st_isdir = 0;
  801c67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c6e:	00 00 00 
	stat->st_dev = dev;
  801c71:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7e:	89 14 24             	mov    %edx,(%esp)
  801c81:	ff 50 14             	call   *0x14(%eax)
  801c84:	eb 05                	jmp    801c8b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c86:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c8b:	83 c4 24             	add    $0x24,%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 18             	sub    $0x18,%esp
  801c97:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c9a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ca4:	00 
  801ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca8:	89 04 24             	mov    %eax,(%esp)
  801cab:	e8 bc 01 00 00       	call   801e6c <open>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 1b                	js     801cd1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbd:	89 1c 24             	mov    %ebx,(%esp)
  801cc0:	e8 54 ff ff ff       	call   801c19 <fstat>
  801cc5:	89 c6                	mov    %eax,%esi
	close(fd);
  801cc7:	89 1c 24             	mov    %ebx,(%esp)
  801cca:	e8 be fb ff ff       	call   80188d <close>
	return r;
  801ccf:	89 f3                	mov    %esi,%ebx
}
  801cd1:	89 d8                	mov    %ebx,%eax
  801cd3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cd6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cd9:	89 ec                	mov    %ebp,%esp
  801cdb:	5d                   	pop    %ebp
  801cdc:	c3                   	ret    
  801cdd:	00 00                	add    %al,(%eax)
	...

00801ce0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 18             	sub    $0x18,%esp
  801ce6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ce9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cf0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801cf7:	75 11                	jne    801d0a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d00:	e8 0c 09 00 00       	call   802611 <ipc_find_env>
  801d05:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d0a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d11:	00 
  801d12:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d19:	00 
  801d1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d1e:	a1 00 50 80 00       	mov    0x805000,%eax
  801d23:	89 04 24             	mov    %eax,(%esp)
  801d26:	e8 7b 08 00 00       	call   8025a6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801d2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d32:	00 
  801d33:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3e:	e8 fd 07 00 00       	call   802540 <ipc_recv>
}
  801d43:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d46:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d49:	89 ec                	mov    %ebp,%esp
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	53                   	push   %ebx
  801d51:	83 ec 14             	sub    $0x14,%esp
  801d54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d5d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d62:	ba 00 00 00 00       	mov    $0x0,%edx
  801d67:	b8 05 00 00 00       	mov    $0x5,%eax
  801d6c:	e8 6f ff ff ff       	call   801ce0 <fsipc>
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 2b                	js     801da0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d75:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d7c:	00 
  801d7d:	89 1c 24             	mov    %ebx,(%esp)
  801d80:	e8 16 ed ff ff       	call   800a9b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d85:	a1 80 60 80 00       	mov    0x806080,%eax
  801d8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d90:	a1 84 60 80 00       	mov    0x806084,%eax
  801d95:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da0:	83 c4 14             	add    $0x14,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    

00801da6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801dac:	8b 45 08             	mov    0x8(%ebp),%eax
  801daf:	8b 40 0c             	mov    0xc(%eax),%eax
  801db2:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801db7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbc:	b8 06 00 00 00       	mov    $0x6,%eax
  801dc1:	e8 1a ff ff ff       	call   801ce0 <fsipc>
}
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    

00801dc8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 10             	sub    $0x10,%esp
  801dd0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd6:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801dde:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801de4:	ba 00 00 00 00       	mov    $0x0,%edx
  801de9:	b8 03 00 00 00       	mov    $0x3,%eax
  801dee:	e8 ed fe ff ff       	call   801ce0 <fsipc>
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 6a                	js     801e63 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801df9:	39 c6                	cmp    %eax,%esi
  801dfb:	73 24                	jae    801e21 <devfile_read+0x59>
  801dfd:	c7 44 24 0c c8 2f 80 	movl   $0x802fc8,0xc(%esp)
  801e04:	00 
  801e05:	c7 44 24 08 cf 2f 80 	movl   $0x802fcf,0x8(%esp)
  801e0c:	00 
  801e0d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801e14:	00 
  801e15:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  801e1c:	e8 37 e4 ff ff       	call   800258 <_panic>
	assert(r <= PGSIZE);
  801e21:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e26:	7e 24                	jle    801e4c <devfile_read+0x84>
  801e28:	c7 44 24 0c ef 2f 80 	movl   $0x802fef,0xc(%esp)
  801e2f:	00 
  801e30:	c7 44 24 08 cf 2f 80 	movl   $0x802fcf,0x8(%esp)
  801e37:	00 
  801e38:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e3f:	00 
  801e40:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  801e47:	e8 0c e4 ff ff       	call   800258 <_panic>
	memmove(buf, &fsipcbuf, r);
  801e4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e50:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e57:	00 
  801e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5b:	89 04 24             	mov    %eax,(%esp)
  801e5e:	e8 29 ee ff ff       	call   800c8c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801e63:	89 d8                	mov    %ebx,%eax
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	83 ec 20             	sub    $0x20,%esp
  801e74:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e77:	89 34 24             	mov    %esi,(%esp)
  801e7a:	e8 d1 eb ff ff       	call   800a50 <strlen>
		return -E_BAD_PATH;
  801e7f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e84:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e89:	7f 5e                	jg     801ee9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8e:	89 04 24             	mov    %eax,(%esp)
  801e91:	e8 35 f8 ff ff       	call   8016cb <fd_alloc>
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	78 4d                	js     801ee9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea0:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ea7:	e8 ef eb ff ff       	call   800a9b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaf:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801eb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801eb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebc:	e8 1f fe ff ff       	call   801ce0 <fsipc>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	79 15                	jns    801edc <open+0x70>
		fd_close(fd, 0);
  801ec7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ece:	00 
  801ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed2:	89 04 24             	mov    %eax,(%esp)
  801ed5:	e8 21 f9 ff ff       	call   8017fb <fd_close>
		return r;
  801eda:	eb 0d                	jmp    801ee9 <open+0x7d>
	}

	return fd2num(fd);
  801edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edf:	89 04 24             	mov    %eax,(%esp)
  801ee2:	e8 b9 f7 ff ff       	call   8016a0 <fd2num>
  801ee7:	89 c3                	mov    %eax,%ebx
}
  801ee9:	89 d8                	mov    %ebx,%eax
  801eeb:	83 c4 20             	add    $0x20,%esp
  801eee:	5b                   	pop    %ebx
  801eef:	5e                   	pop    %esi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    
	...

00801f00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 18             	sub    $0x18,%esp
  801f06:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f09:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f0c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	89 04 24             	mov    %eax,(%esp)
  801f15:	e8 96 f7 ff ff       	call   8016b0 <fd2data>
  801f1a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f1c:	c7 44 24 04 fb 2f 80 	movl   $0x802ffb,0x4(%esp)
  801f23:	00 
  801f24:	89 34 24             	mov    %esi,(%esp)
  801f27:	e8 6f eb ff ff       	call   800a9b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f2f:	2b 03                	sub    (%ebx),%eax
  801f31:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f37:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f3e:	00 00 00 
	stat->st_dev = &devpipe;
  801f41:	c7 86 88 00 00 00 24 	movl   $0x804024,0x88(%esi)
  801f48:	40 80 00 
	return 0;
}
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f50:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f53:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f56:	89 ec                	mov    %ebp,%esp
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 14             	sub    $0x14,%esp
  801f61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6f:	e8 e5 f0 ff ff       	call   801059 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f74:	89 1c 24             	mov    %ebx,(%esp)
  801f77:	e8 34 f7 ff ff       	call   8016b0 <fd2data>
  801f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f87:	e8 cd f0 ff ff       	call   801059 <sys_page_unmap>
}
  801f8c:	83 c4 14             	add    $0x14,%esp
  801f8f:	5b                   	pop    %ebx
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	57                   	push   %edi
  801f96:	56                   	push   %esi
  801f97:	53                   	push   %ebx
  801f98:	83 ec 2c             	sub    $0x2c,%esp
  801f9b:	89 c7                	mov    %eax,%edi
  801f9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fa0:	a1 04 50 80 00       	mov    0x805004,%eax
  801fa5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fa8:	89 3c 24             	mov    %edi,(%esp)
  801fab:	e8 ac 06 00 00       	call   80265c <pageref>
  801fb0:	89 c6                	mov    %eax,%esi
  801fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fb5:	89 04 24             	mov    %eax,(%esp)
  801fb8:	e8 9f 06 00 00       	call   80265c <pageref>
  801fbd:	39 c6                	cmp    %eax,%esi
  801fbf:	0f 94 c0             	sete   %al
  801fc2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801fc5:	8b 15 04 50 80 00    	mov    0x805004,%edx
  801fcb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fce:	39 cb                	cmp    %ecx,%ebx
  801fd0:	75 08                	jne    801fda <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801fd2:	83 c4 2c             	add    $0x2c,%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5f                   	pop    %edi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801fda:	83 f8 01             	cmp    $0x1,%eax
  801fdd:	75 c1                	jne    801fa0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fdf:	8b 52 58             	mov    0x58(%edx),%edx
  801fe2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fee:	c7 04 24 02 30 80 00 	movl   $0x803002,(%esp)
  801ff5:	e8 59 e3 ff ff       	call   800353 <cprintf>
  801ffa:	eb a4                	jmp    801fa0 <_pipeisclosed+0xe>

00801ffc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	57                   	push   %edi
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	83 ec 2c             	sub    $0x2c,%esp
  802005:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802008:	89 34 24             	mov    %esi,(%esp)
  80200b:	e8 a0 f6 ff ff       	call   8016b0 <fd2data>
  802010:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802012:	bf 00 00 00 00       	mov    $0x0,%edi
  802017:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80201b:	75 50                	jne    80206d <devpipe_write+0x71>
  80201d:	eb 5c                	jmp    80207b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80201f:	89 da                	mov    %ebx,%edx
  802021:	89 f0                	mov    %esi,%eax
  802023:	e8 6a ff ff ff       	call   801f92 <_pipeisclosed>
  802028:	85 c0                	test   %eax,%eax
  80202a:	75 53                	jne    80207f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80202c:	e8 3b ef ff ff       	call   800f6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802031:	8b 43 04             	mov    0x4(%ebx),%eax
  802034:	8b 13                	mov    (%ebx),%edx
  802036:	83 c2 20             	add    $0x20,%edx
  802039:	39 d0                	cmp    %edx,%eax
  80203b:	73 e2                	jae    80201f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80203d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802040:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802044:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802047:	89 c2                	mov    %eax,%edx
  802049:	c1 fa 1f             	sar    $0x1f,%edx
  80204c:	c1 ea 1b             	shr    $0x1b,%edx
  80204f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802052:	83 e1 1f             	and    $0x1f,%ecx
  802055:	29 d1                	sub    %edx,%ecx
  802057:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80205b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80205f:	83 c0 01             	add    $0x1,%eax
  802062:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802065:	83 c7 01             	add    $0x1,%edi
  802068:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80206b:	74 0e                	je     80207b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80206d:	8b 43 04             	mov    0x4(%ebx),%eax
  802070:	8b 13                	mov    (%ebx),%edx
  802072:	83 c2 20             	add    $0x20,%edx
  802075:	39 d0                	cmp    %edx,%eax
  802077:	73 a6                	jae    80201f <devpipe_write+0x23>
  802079:	eb c2                	jmp    80203d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80207b:	89 f8                	mov    %edi,%eax
  80207d:	eb 05                	jmp    802084 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802084:	83 c4 2c             	add    $0x2c,%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    

0080208c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	83 ec 28             	sub    $0x28,%esp
  802092:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802095:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802098:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80209b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80209e:	89 3c 24             	mov    %edi,(%esp)
  8020a1:	e8 0a f6 ff ff       	call   8016b0 <fd2data>
  8020a6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a8:	be 00 00 00 00       	mov    $0x0,%esi
  8020ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020b1:	75 47                	jne    8020fa <devpipe_read+0x6e>
  8020b3:	eb 52                	jmp    802107 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8020b5:	89 f0                	mov    %esi,%eax
  8020b7:	eb 5e                	jmp    802117 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020b9:	89 da                	mov    %ebx,%edx
  8020bb:	89 f8                	mov    %edi,%eax
  8020bd:	8d 76 00             	lea    0x0(%esi),%esi
  8020c0:	e8 cd fe ff ff       	call   801f92 <_pipeisclosed>
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	75 49                	jne    802112 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8020c9:	e8 9e ee ff ff       	call   800f6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020ce:	8b 03                	mov    (%ebx),%eax
  8020d0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020d3:	74 e4                	je     8020b9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020d5:	89 c2                	mov    %eax,%edx
  8020d7:	c1 fa 1f             	sar    $0x1f,%edx
  8020da:	c1 ea 1b             	shr    $0x1b,%edx
  8020dd:	01 d0                	add    %edx,%eax
  8020df:	83 e0 1f             	and    $0x1f,%eax
  8020e2:	29 d0                	sub    %edx,%eax
  8020e4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ec:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8020ef:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f2:	83 c6 01             	add    $0x1,%esi
  8020f5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020f8:	74 0d                	je     802107 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  8020fa:	8b 03                	mov    (%ebx),%eax
  8020fc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020ff:	75 d4                	jne    8020d5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802101:	85 f6                	test   %esi,%esi
  802103:	75 b0                	jne    8020b5 <devpipe_read+0x29>
  802105:	eb b2                	jmp    8020b9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802107:	89 f0                	mov    %esi,%eax
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	eb 05                	jmp    802117 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802112:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802117:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80211a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80211d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802120:	89 ec                	mov    %ebp,%esp
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	83 ec 48             	sub    $0x48,%esp
  80212a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80212d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802130:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802133:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802136:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802139:	89 04 24             	mov    %eax,(%esp)
  80213c:	e8 8a f5 ff ff       	call   8016cb <fd_alloc>
  802141:	89 c3                	mov    %eax,%ebx
  802143:	85 c0                	test   %eax,%eax
  802145:	0f 88 45 01 00 00    	js     802290 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802152:	00 
  802153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802161:	e8 36 ee ff ff       	call   800f9c <sys_page_alloc>
  802166:	89 c3                	mov    %eax,%ebx
  802168:	85 c0                	test   %eax,%eax
  80216a:	0f 88 20 01 00 00    	js     802290 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802170:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802173:	89 04 24             	mov    %eax,(%esp)
  802176:	e8 50 f5 ff ff       	call   8016cb <fd_alloc>
  80217b:	89 c3                	mov    %eax,%ebx
  80217d:	85 c0                	test   %eax,%eax
  80217f:	0f 88 f8 00 00 00    	js     80227d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802185:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80218c:	00 
  80218d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802190:	89 44 24 04          	mov    %eax,0x4(%esp)
  802194:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219b:	e8 fc ed ff ff       	call   800f9c <sys_page_alloc>
  8021a0:	89 c3                	mov    %eax,%ebx
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	0f 88 d3 00 00 00    	js     80227d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ad:	89 04 24             	mov    %eax,(%esp)
  8021b0:	e8 fb f4 ff ff       	call   8016b0 <fd2data>
  8021b5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021be:	00 
  8021bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ca:	e8 cd ed ff ff       	call   800f9c <sys_page_alloc>
  8021cf:	89 c3                	mov    %eax,%ebx
  8021d1:	85 c0                	test   %eax,%eax
  8021d3:	0f 88 91 00 00 00    	js     80226a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021dc:	89 04 24             	mov    %eax,(%esp)
  8021df:	e8 cc f4 ff ff       	call   8016b0 <fd2data>
  8021e4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8021eb:	00 
  8021ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021f7:	00 
  8021f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802203:	e8 f3 ed ff ff       	call   800ffb <sys_page_map>
  802208:	89 c3                	mov    %eax,%ebx
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 4c                	js     80225a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80220e:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802217:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80221c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802223:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80222c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80222e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802231:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80223b:	89 04 24             	mov    %eax,(%esp)
  80223e:	e8 5d f4 ff ff       	call   8016a0 <fd2num>
  802243:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802245:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802248:	89 04 24             	mov    %eax,(%esp)
  80224b:	e8 50 f4 ff ff       	call   8016a0 <fd2num>
  802250:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802253:	bb 00 00 00 00       	mov    $0x0,%ebx
  802258:	eb 36                	jmp    802290 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80225a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802265:	e8 ef ed ff ff       	call   801059 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80226a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80226d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802271:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802278:	e8 dc ed ff ff       	call   801059 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80227d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802280:	89 44 24 04          	mov    %eax,0x4(%esp)
  802284:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80228b:	e8 c9 ed ff ff       	call   801059 <sys_page_unmap>
    err:
	return r;
}
  802290:	89 d8                	mov    %ebx,%eax
  802292:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802295:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802298:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80229b:	89 ec                	mov    %ebp,%esp
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    

0080229f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8022af:	89 04 24             	mov    %eax,(%esp)
  8022b2:	e8 87 f4 ff ff       	call   80173e <fd_lookup>
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	78 15                	js     8022d0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022be:	89 04 24             	mov    %eax,(%esp)
  8022c1:	e8 ea f3 ff ff       	call   8016b0 <fd2data>
	return _pipeisclosed(fd, p);
  8022c6:	89 c2                	mov    %eax,%edx
  8022c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cb:	e8 c2 fc ff ff       	call   801f92 <_pipeisclosed>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    
	...

008022e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8022f0:	c7 44 24 04 1a 30 80 	movl   $0x80301a,0x4(%esp)
  8022f7:	00 
  8022f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fb:	89 04 24             	mov    %eax,(%esp)
  8022fe:	e8 98 e7 ff ff       	call   800a9b <strcpy>
	return 0;
}
  802303:	b8 00 00 00 00       	mov    $0x0,%eax
  802308:	c9                   	leave  
  802309:	c3                   	ret    

0080230a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	57                   	push   %edi
  80230e:	56                   	push   %esi
  80230f:	53                   	push   %ebx
  802310:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802316:	be 00 00 00 00       	mov    $0x0,%esi
  80231b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80231f:	74 43                	je     802364 <devcons_write+0x5a>
  802321:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802326:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80232c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80232f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802331:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802334:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802339:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80233c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802340:	03 45 0c             	add    0xc(%ebp),%eax
  802343:	89 44 24 04          	mov    %eax,0x4(%esp)
  802347:	89 3c 24             	mov    %edi,(%esp)
  80234a:	e8 3d e9 ff ff       	call   800c8c <memmove>
		sys_cputs(buf, m);
  80234f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	e8 25 eb ff ff       	call   800e80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80235b:	01 de                	add    %ebx,%esi
  80235d:	89 f0                	mov    %esi,%eax
  80235f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802362:	72 c8                	jb     80232c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802364:	89 f0                	mov    %esi,%eax
  802366:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80236c:	5b                   	pop    %ebx
  80236d:	5e                   	pop    %esi
  80236e:	5f                   	pop    %edi
  80236f:	5d                   	pop    %ebp
  802370:	c3                   	ret    

00802371 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802371:	55                   	push   %ebp
  802372:	89 e5                	mov    %esp,%ebp
  802374:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802377:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80237c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802380:	75 07                	jne    802389 <devcons_read+0x18>
  802382:	eb 31                	jmp    8023b5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802384:	e8 e3 eb ff ff       	call   800f6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	e8 1a eb ff ff       	call   800eaf <sys_cgetc>
  802395:	85 c0                	test   %eax,%eax
  802397:	74 eb                	je     802384 <devcons_read+0x13>
  802399:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80239b:	85 c0                	test   %eax,%eax
  80239d:	78 16                	js     8023b5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80239f:	83 f8 04             	cmp    $0x4,%eax
  8023a2:	74 0c                	je     8023b0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8023a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a7:	88 10                	mov    %dl,(%eax)
	return 1;
  8023a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ae:	eb 05                	jmp    8023b5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023b5:	c9                   	leave  
  8023b6:	c3                   	ret    

008023b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023b7:	55                   	push   %ebp
  8023b8:	89 e5                	mov    %esp,%ebp
  8023ba:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8023bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023c3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8023ca:	00 
  8023cb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ce:	89 04 24             	mov    %eax,(%esp)
  8023d1:	e8 aa ea ff ff       	call   800e80 <sys_cputs>
}
  8023d6:	c9                   	leave  
  8023d7:	c3                   	ret    

008023d8 <getchar>:

int
getchar(void)
{
  8023d8:	55                   	push   %ebp
  8023d9:	89 e5                	mov    %esp,%ebp
  8023db:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023de:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8023e5:	00 
  8023e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f4:	e8 05 f6 ff ff       	call   8019fe <read>
	if (r < 0)
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	78 0f                	js     80240c <getchar+0x34>
		return r;
	if (r < 1)
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	7e 06                	jle    802407 <getchar+0x2f>
		return -E_EOF;
	return c;
  802401:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802405:	eb 05                	jmp    80240c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802407:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80240c:	c9                   	leave  
  80240d:	c3                   	ret    

0080240e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80240e:	55                   	push   %ebp
  80240f:	89 e5                	mov    %esp,%ebp
  802411:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802414:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241b:	8b 45 08             	mov    0x8(%ebp),%eax
  80241e:	89 04 24             	mov    %eax,(%esp)
  802421:	e8 18 f3 ff ff       	call   80173e <fd_lookup>
  802426:	85 c0                	test   %eax,%eax
  802428:	78 11                	js     80243b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242d:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802433:	39 10                	cmp    %edx,(%eax)
  802435:	0f 94 c0             	sete   %al
  802438:	0f b6 c0             	movzbl %al,%eax
}
  80243b:	c9                   	leave  
  80243c:	c3                   	ret    

0080243d <opencons>:

int
opencons(void)
{
  80243d:	55                   	push   %ebp
  80243e:	89 e5                	mov    %esp,%ebp
  802440:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802443:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802446:	89 04 24             	mov    %eax,(%esp)
  802449:	e8 7d f2 ff ff       	call   8016cb <fd_alloc>
  80244e:	85 c0                	test   %eax,%eax
  802450:	78 3c                	js     80248e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802452:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802459:	00 
  80245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802461:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802468:	e8 2f eb ff ff       	call   800f9c <sys_page_alloc>
  80246d:	85 c0                	test   %eax,%eax
  80246f:	78 1d                	js     80248e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802471:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80247c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802486:	89 04 24             	mov    %eax,(%esp)
  802489:	e8 12 f2 ff ff       	call   8016a0 <fd2num>
}
  80248e:	c9                   	leave  
  80248f:	c3                   	ret    

00802490 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802496:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80249d:	75 3c                	jne    8024db <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80249f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8024a6:	00 
  8024a7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8024ae:	ee 
  8024af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b6:	e8 e1 ea ff ff       	call   800f9c <sys_page_alloc>
  8024bb:	85 c0                	test   %eax,%eax
  8024bd:	79 1c                	jns    8024db <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8024bf:	c7 44 24 08 28 30 80 	movl   $0x803028,0x8(%esp)
  8024c6:	00 
  8024c7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8024ce:	00 
  8024cf:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  8024d6:	e8 7d dd ff ff       	call   800258 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024db:	8b 45 08             	mov    0x8(%ebp),%eax
  8024de:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8024e3:	c7 44 24 04 1c 25 80 	movl   $0x80251c,0x4(%esp)
  8024ea:	00 
  8024eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f2:	e8 7c ec ff ff       	call   801173 <sys_env_set_pgfault_upcall>
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	79 1c                	jns    802517 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8024fb:	c7 44 24 08 54 30 80 	movl   $0x803054,0x8(%esp)
  802502:	00 
  802503:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80250a:	00 
  80250b:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  802512:	e8 41 dd ff ff       	call   800258 <_panic>
}
  802517:	c9                   	leave  
  802518:	c3                   	ret    
  802519:	00 00                	add    %al,(%eax)
	...

0080251c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80251c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80251d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802522:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802524:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  802527:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80252b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802530:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802534:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  802536:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802539:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80253a:	83 c4 04             	add    $0x4,%esp
    popfl
  80253d:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  80253e:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  80253f:	c3                   	ret    

00802540 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	56                   	push   %esi
  802544:	53                   	push   %ebx
  802545:	83 ec 10             	sub    $0x10,%esp
  802548:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80254b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80254e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802551:	85 db                	test   %ebx,%ebx
  802553:	74 06                	je     80255b <ipc_recv+0x1b>
  802555:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80255b:	85 f6                	test   %esi,%esi
  80255d:	74 06                	je     802565 <ipc_recv+0x25>
  80255f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802565:	85 c0                	test   %eax,%eax
  802567:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80256c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80256f:	89 04 24             	mov    %eax,(%esp)
  802572:	e8 8e ec ff ff       	call   801205 <sys_ipc_recv>
    if (ret) return ret;
  802577:	85 c0                	test   %eax,%eax
  802579:	75 24                	jne    80259f <ipc_recv+0x5f>
    if (from_env_store)
  80257b:	85 db                	test   %ebx,%ebx
  80257d:	74 0a                	je     802589 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80257f:	a1 04 50 80 00       	mov    0x805004,%eax
  802584:	8b 40 74             	mov    0x74(%eax),%eax
  802587:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802589:	85 f6                	test   %esi,%esi
  80258b:	74 0a                	je     802597 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80258d:	a1 04 50 80 00       	mov    0x805004,%eax
  802592:	8b 40 78             	mov    0x78(%eax),%eax
  802595:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802597:	a1 04 50 80 00       	mov    0x805004,%eax
  80259c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80259f:	83 c4 10             	add    $0x10,%esp
  8025a2:	5b                   	pop    %ebx
  8025a3:	5e                   	pop    %esi
  8025a4:	5d                   	pop    %ebp
  8025a5:	c3                   	ret    

008025a6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025a6:	55                   	push   %ebp
  8025a7:	89 e5                	mov    %esp,%ebp
  8025a9:	57                   	push   %edi
  8025aa:	56                   	push   %esi
  8025ab:	53                   	push   %ebx
  8025ac:	83 ec 1c             	sub    $0x1c,%esp
  8025af:	8b 75 08             	mov    0x8(%ebp),%esi
  8025b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8025b8:	85 db                	test   %ebx,%ebx
  8025ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8025bf:	0f 44 d8             	cmove  %eax,%ebx
  8025c2:	eb 2a                	jmp    8025ee <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8025c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025c7:	74 20                	je     8025e9 <ipc_send+0x43>
  8025c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025cd:	c7 44 24 08 9a 30 80 	movl   $0x80309a,0x8(%esp)
  8025d4:	00 
  8025d5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8025dc:	00 
  8025dd:	c7 04 24 b1 30 80 00 	movl   $0x8030b1,(%esp)
  8025e4:	e8 6f dc ff ff       	call   800258 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8025e9:	e8 7e e9 ff ff       	call   800f6c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8025ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8025f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025fd:	89 34 24             	mov    %esi,(%esp)
  802600:	e8 cc eb ff ff       	call   8011d1 <sys_ipc_try_send>
  802605:	85 c0                	test   %eax,%eax
  802607:	75 bb                	jne    8025c4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802609:	83 c4 1c             	add    $0x1c,%esp
  80260c:	5b                   	pop    %ebx
  80260d:	5e                   	pop    %esi
  80260e:	5f                   	pop    %edi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    

00802611 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802611:	55                   	push   %ebp
  802612:	89 e5                	mov    %esp,%ebp
  802614:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802617:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80261c:	39 c8                	cmp    %ecx,%eax
  80261e:	74 19                	je     802639 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802620:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802625:	89 c2                	mov    %eax,%edx
  802627:	c1 e2 07             	shl    $0x7,%edx
  80262a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802630:	8b 52 50             	mov    0x50(%edx),%edx
  802633:	39 ca                	cmp    %ecx,%edx
  802635:	75 14                	jne    80264b <ipc_find_env+0x3a>
  802637:	eb 05                	jmp    80263e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802639:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80263e:	c1 e0 07             	shl    $0x7,%eax
  802641:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802646:	8b 40 40             	mov    0x40(%eax),%eax
  802649:	eb 0e                	jmp    802659 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80264b:	83 c0 01             	add    $0x1,%eax
  80264e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802653:	75 d0                	jne    802625 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802655:	66 b8 00 00          	mov    $0x0,%ax
}
  802659:	5d                   	pop    %ebp
  80265a:	c3                   	ret    
	...

0080265c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802662:	89 d0                	mov    %edx,%eax
  802664:	c1 e8 16             	shr    $0x16,%eax
  802667:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80266e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802673:	f6 c1 01             	test   $0x1,%cl
  802676:	74 1d                	je     802695 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802678:	c1 ea 0c             	shr    $0xc,%edx
  80267b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802682:	f6 c2 01             	test   $0x1,%dl
  802685:	74 0e                	je     802695 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802687:	c1 ea 0c             	shr    $0xc,%edx
  80268a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802691:	ef 
  802692:	0f b7 c0             	movzwl %ax,%eax
}
  802695:	5d                   	pop    %ebp
  802696:	c3                   	ret    
	...

008026a0 <__udivdi3>:
  8026a0:	83 ec 1c             	sub    $0x1c,%esp
  8026a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8026a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8026ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8026af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8026b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8026b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8026bb:	85 ff                	test   %edi,%edi
  8026bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8026c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026c5:	89 cd                	mov    %ecx,%ebp
  8026c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026cb:	75 33                	jne    802700 <__udivdi3+0x60>
  8026cd:	39 f1                	cmp    %esi,%ecx
  8026cf:	77 57                	ja     802728 <__udivdi3+0x88>
  8026d1:	85 c9                	test   %ecx,%ecx
  8026d3:	75 0b                	jne    8026e0 <__udivdi3+0x40>
  8026d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8026da:	31 d2                	xor    %edx,%edx
  8026dc:	f7 f1                	div    %ecx
  8026de:	89 c1                	mov    %eax,%ecx
  8026e0:	89 f0                	mov    %esi,%eax
  8026e2:	31 d2                	xor    %edx,%edx
  8026e4:	f7 f1                	div    %ecx
  8026e6:	89 c6                	mov    %eax,%esi
  8026e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026ec:	f7 f1                	div    %ecx
  8026ee:	89 f2                	mov    %esi,%edx
  8026f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8026f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8026fc:	83 c4 1c             	add    $0x1c,%esp
  8026ff:	c3                   	ret    
  802700:	31 d2                	xor    %edx,%edx
  802702:	31 c0                	xor    %eax,%eax
  802704:	39 f7                	cmp    %esi,%edi
  802706:	77 e8                	ja     8026f0 <__udivdi3+0x50>
  802708:	0f bd cf             	bsr    %edi,%ecx
  80270b:	83 f1 1f             	xor    $0x1f,%ecx
  80270e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802712:	75 2c                	jne    802740 <__udivdi3+0xa0>
  802714:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802718:	76 04                	jbe    80271e <__udivdi3+0x7e>
  80271a:	39 f7                	cmp    %esi,%edi
  80271c:	73 d2                	jae    8026f0 <__udivdi3+0x50>
  80271e:	31 d2                	xor    %edx,%edx
  802720:	b8 01 00 00 00       	mov    $0x1,%eax
  802725:	eb c9                	jmp    8026f0 <__udivdi3+0x50>
  802727:	90                   	nop
  802728:	89 f2                	mov    %esi,%edx
  80272a:	f7 f1                	div    %ecx
  80272c:	31 d2                	xor    %edx,%edx
  80272e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802732:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802736:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80273a:	83 c4 1c             	add    $0x1c,%esp
  80273d:	c3                   	ret    
  80273e:	66 90                	xchg   %ax,%ax
  802740:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802745:	b8 20 00 00 00       	mov    $0x20,%eax
  80274a:	89 ea                	mov    %ebp,%edx
  80274c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802750:	d3 e7                	shl    %cl,%edi
  802752:	89 c1                	mov    %eax,%ecx
  802754:	d3 ea                	shr    %cl,%edx
  802756:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80275b:	09 fa                	or     %edi,%edx
  80275d:	89 f7                	mov    %esi,%edi
  80275f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802763:	89 f2                	mov    %esi,%edx
  802765:	8b 74 24 08          	mov    0x8(%esp),%esi
  802769:	d3 e5                	shl    %cl,%ebp
  80276b:	89 c1                	mov    %eax,%ecx
  80276d:	d3 ef                	shr    %cl,%edi
  80276f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802774:	d3 e2                	shl    %cl,%edx
  802776:	89 c1                	mov    %eax,%ecx
  802778:	d3 ee                	shr    %cl,%esi
  80277a:	09 d6                	or     %edx,%esi
  80277c:	89 fa                	mov    %edi,%edx
  80277e:	89 f0                	mov    %esi,%eax
  802780:	f7 74 24 0c          	divl   0xc(%esp)
  802784:	89 d7                	mov    %edx,%edi
  802786:	89 c6                	mov    %eax,%esi
  802788:	f7 e5                	mul    %ebp
  80278a:	39 d7                	cmp    %edx,%edi
  80278c:	72 22                	jb     8027b0 <__udivdi3+0x110>
  80278e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802792:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802797:	d3 e5                	shl    %cl,%ebp
  802799:	39 c5                	cmp    %eax,%ebp
  80279b:	73 04                	jae    8027a1 <__udivdi3+0x101>
  80279d:	39 d7                	cmp    %edx,%edi
  80279f:	74 0f                	je     8027b0 <__udivdi3+0x110>
  8027a1:	89 f0                	mov    %esi,%eax
  8027a3:	31 d2                	xor    %edx,%edx
  8027a5:	e9 46 ff ff ff       	jmp    8026f0 <__udivdi3+0x50>
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8027b3:	31 d2                	xor    %edx,%edx
  8027b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027c1:	83 c4 1c             	add    $0x1c,%esp
  8027c4:	c3                   	ret    
	...

008027d0 <__umoddi3>:
  8027d0:	83 ec 1c             	sub    $0x1c,%esp
  8027d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8027d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8027db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8027df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8027e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8027e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8027eb:	85 ed                	test   %ebp,%ebp
  8027ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8027f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027f5:	89 cf                	mov    %ecx,%edi
  8027f7:	89 04 24             	mov    %eax,(%esp)
  8027fa:	89 f2                	mov    %esi,%edx
  8027fc:	75 1a                	jne    802818 <__umoddi3+0x48>
  8027fe:	39 f1                	cmp    %esi,%ecx
  802800:	76 4e                	jbe    802850 <__umoddi3+0x80>
  802802:	f7 f1                	div    %ecx
  802804:	89 d0                	mov    %edx,%eax
  802806:	31 d2                	xor    %edx,%edx
  802808:	8b 74 24 10          	mov    0x10(%esp),%esi
  80280c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802810:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802814:	83 c4 1c             	add    $0x1c,%esp
  802817:	c3                   	ret    
  802818:	39 f5                	cmp    %esi,%ebp
  80281a:	77 54                	ja     802870 <__umoddi3+0xa0>
  80281c:	0f bd c5             	bsr    %ebp,%eax
  80281f:	83 f0 1f             	xor    $0x1f,%eax
  802822:	89 44 24 04          	mov    %eax,0x4(%esp)
  802826:	75 60                	jne    802888 <__umoddi3+0xb8>
  802828:	3b 0c 24             	cmp    (%esp),%ecx
  80282b:	0f 87 07 01 00 00    	ja     802938 <__umoddi3+0x168>
  802831:	89 f2                	mov    %esi,%edx
  802833:	8b 34 24             	mov    (%esp),%esi
  802836:	29 ce                	sub    %ecx,%esi
  802838:	19 ea                	sbb    %ebp,%edx
  80283a:	89 34 24             	mov    %esi,(%esp)
  80283d:	8b 04 24             	mov    (%esp),%eax
  802840:	8b 74 24 10          	mov    0x10(%esp),%esi
  802844:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802848:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80284c:	83 c4 1c             	add    $0x1c,%esp
  80284f:	c3                   	ret    
  802850:	85 c9                	test   %ecx,%ecx
  802852:	75 0b                	jne    80285f <__umoddi3+0x8f>
  802854:	b8 01 00 00 00       	mov    $0x1,%eax
  802859:	31 d2                	xor    %edx,%edx
  80285b:	f7 f1                	div    %ecx
  80285d:	89 c1                	mov    %eax,%ecx
  80285f:	89 f0                	mov    %esi,%eax
  802861:	31 d2                	xor    %edx,%edx
  802863:	f7 f1                	div    %ecx
  802865:	8b 04 24             	mov    (%esp),%eax
  802868:	f7 f1                	div    %ecx
  80286a:	eb 98                	jmp    802804 <__umoddi3+0x34>
  80286c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802870:	89 f2                	mov    %esi,%edx
  802872:	8b 74 24 10          	mov    0x10(%esp),%esi
  802876:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80287a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80287e:	83 c4 1c             	add    $0x1c,%esp
  802881:	c3                   	ret    
  802882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802888:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80288d:	89 e8                	mov    %ebp,%eax
  80288f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802894:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802898:	89 fa                	mov    %edi,%edx
  80289a:	d3 e0                	shl    %cl,%eax
  80289c:	89 e9                	mov    %ebp,%ecx
  80289e:	d3 ea                	shr    %cl,%edx
  8028a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028a5:	09 c2                	or     %eax,%edx
  8028a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028ab:	89 14 24             	mov    %edx,(%esp)
  8028ae:	89 f2                	mov    %esi,%edx
  8028b0:	d3 e7                	shl    %cl,%edi
  8028b2:	89 e9                	mov    %ebp,%ecx
  8028b4:	d3 ea                	shr    %cl,%edx
  8028b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028bf:	d3 e6                	shl    %cl,%esi
  8028c1:	89 e9                	mov    %ebp,%ecx
  8028c3:	d3 e8                	shr    %cl,%eax
  8028c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028ca:	09 f0                	or     %esi,%eax
  8028cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028d0:	f7 34 24             	divl   (%esp)
  8028d3:	d3 e6                	shl    %cl,%esi
  8028d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8028d9:	89 d6                	mov    %edx,%esi
  8028db:	f7 e7                	mul    %edi
  8028dd:	39 d6                	cmp    %edx,%esi
  8028df:	89 c1                	mov    %eax,%ecx
  8028e1:	89 d7                	mov    %edx,%edi
  8028e3:	72 3f                	jb     802924 <__umoddi3+0x154>
  8028e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028e9:	72 35                	jb     802920 <__umoddi3+0x150>
  8028eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028ef:	29 c8                	sub    %ecx,%eax
  8028f1:	19 fe                	sbb    %edi,%esi
  8028f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028f8:	89 f2                	mov    %esi,%edx
  8028fa:	d3 e8                	shr    %cl,%eax
  8028fc:	89 e9                	mov    %ebp,%ecx
  8028fe:	d3 e2                	shl    %cl,%edx
  802900:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802905:	09 d0                	or     %edx,%eax
  802907:	89 f2                	mov    %esi,%edx
  802909:	d3 ea                	shr    %cl,%edx
  80290b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80290f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802913:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802917:	83 c4 1c             	add    $0x1c,%esp
  80291a:	c3                   	ret    
  80291b:	90                   	nop
  80291c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802920:	39 d6                	cmp    %edx,%esi
  802922:	75 c7                	jne    8028eb <__umoddi3+0x11b>
  802924:	89 d7                	mov    %edx,%edi
  802926:	89 c1                	mov    %eax,%ecx
  802928:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80292c:	1b 3c 24             	sbb    (%esp),%edi
  80292f:	eb ba                	jmp    8028eb <__umoddi3+0x11b>
  802931:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802938:	39 f5                	cmp    %esi,%ebp
  80293a:	0f 82 f1 fe ff ff    	jb     802831 <__umoddi3+0x61>
  802940:	e9 f8 fe ff ff       	jmp    80283d <__umoddi3+0x6d>
