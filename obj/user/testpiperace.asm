
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 ef 01 00 00       	call   800220 <libmain>
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
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  800048:	c7 04 24 80 29 80 00 	movl   $0x802980,(%esp)
  80004f:	e8 33 03 00 00       	call   800387 <cprintf>
	if ((r = pipe(p)) < 0)
  800054:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800057:	89 04 24             	mov    %eax,(%esp)
  80005a:	e8 55 22 00 00       	call   8022b4 <pipe>
  80005f:	85 c0                	test   %eax,%eax
  800061:	79 20                	jns    800083 <umain+0x43>
		panic("pipe: %e", r);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 99 29 80 	movl   $0x802999,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 a2 29 80 00 	movl   $0x8029a2,(%esp)
  80007e:	e8 09 02 00 00       	call   80028c <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800083:	e8 6f 13 00 00       	call   8013f7 <fork>
  800088:	89 c6                	mov    %eax,%esi
  80008a:	85 c0                	test   %eax,%eax
  80008c:	79 20                	jns    8000ae <umain+0x6e>
		panic("fork: %e", r);
  80008e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800092:	c7 44 24 08 b6 29 80 	movl   $0x8029b6,0x8(%esp)
  800099:	00 
  80009a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000a1:	00 
  8000a2:	c7 04 24 a2 29 80 00 	movl   $0x8029a2,(%esp)
  8000a9:	e8 de 01 00 00       	call   80028c <_panic>
	if (r == 0) {
  8000ae:	85 c0                	test   %eax,%eax
  8000b0:	75 56                	jne    800108 <umain+0xc8>
		close(p[1]);
  8000b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b5:	89 04 24             	mov    %eax,(%esp)
  8000b8:	e8 30 19 00 00       	call   8019ed <close>
  8000bd:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000c5:	89 04 24             	mov    %eax,(%esp)
  8000c8:	e8 62 23 00 00       	call   80242f <pipeisclosed>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 11                	je     8000e2 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000d1:	c7 04 24 bf 29 80 00 	movl   $0x8029bf,(%esp)
  8000d8:	e8 aa 02 00 00       	call   800387 <cprintf>
				exit();
  8000dd:	e8 8e 01 00 00       	call   800270 <exit>
			}
			sys_yield();
  8000e2:	e8 c5 0e 00 00       	call   800fac <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000e7:	83 eb 01             	sub    $0x1,%ebx
  8000ea:	75 d6                	jne    8000c2 <umain+0x82>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000f3:	00 
  8000f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000fb:	00 
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 d8 15 00 00       	call   8016e0 <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800108:	89 74 24 04          	mov    %esi,0x4(%esp)
  80010c:	c7 04 24 da 29 80 00 	movl   $0x8029da,(%esp)
  800113:	e8 6f 02 00 00       	call   800387 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800118:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80011e:	c1 e6 07             	shl    $0x7,%esi
	cprintf("kid is %d\n", kid-envs);
  800121:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800127:	c1 ee 07             	shr    $0x7,%esi
  80012a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80012e:	c7 04 24 e5 29 80 00 	movl   $0x8029e5,(%esp)
  800135:	e8 4d 02 00 00       	call   800387 <cprintf>
	dup(p[0], 10);
  80013a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800141:	00 
  800142:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 f3 18 00 00       	call   801a40 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80014d:	8b 43 54             	mov    0x54(%ebx),%eax
  800150:	83 f8 02             	cmp    $0x2,%eax
  800153:	75 1b                	jne    800170 <umain+0x130>
		dup(p[0], 10);
  800155:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80015c:	00 
  80015d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 d8 18 00 00       	call   801a40 <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800168:	8b 43 54             	mov    0x54(%ebx),%eax
  80016b:	83 f8 02             	cmp    $0x2,%eax
  80016e:	74 e5                	je     800155 <umain+0x115>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800170:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  800177:	e8 0b 02 00 00       	call   800387 <cprintf>
	if (pipeisclosed(p[0]))
  80017c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 a8 22 00 00       	call   80242f <pipeisclosed>
  800187:	85 c0                	test   %eax,%eax
  800189:	74 1c                	je     8001a7 <umain+0x167>
		panic("somehow the other end of p[0] got closed!");
  80018b:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  800192:	00 
  800193:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 a2 29 80 00 	movl   $0x8029a2,(%esp)
  8001a2:	e8 e5 00 00 00       	call   80028c <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 e5 16 00 00       	call   80189e <fd_lookup>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	79 20                	jns    8001dd <umain+0x19d>
		panic("cannot look up p[0]: %e", r);
  8001bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c1:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 a2 29 80 00 	movl   $0x8029a2,(%esp)
  8001d8:	e8 af 00 00 00       	call   80028c <_panic>
	va = fd2data(fd);
  8001dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 28 16 00 00       	call   801810 <fd2data>
	if (pageref(va) != 3+1)
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 64 1e 00 00       	call   802054 <pageref>
  8001f0:	83 f8 04             	cmp    $0x4,%eax
  8001f3:	74 0e                	je     800203 <umain+0x1c3>
		cprintf("\nchild detected race\n");
  8001f5:	c7 04 24 1e 2a 80 00 	movl   $0x802a1e,(%esp)
  8001fc:	e8 86 01 00 00       	call   800387 <cprintf>
  800201:	eb 14                	jmp    800217 <umain+0x1d7>
	else
		cprintf("\nrace didn't happen\n", max);
  800203:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80020a:	00 
  80020b:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  800212:	e8 70 01 00 00       	call   800387 <cprintf>
}
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    
	...

00800220 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 18             	sub    $0x18,%esp
  800226:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800229:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80022c:	8b 75 08             	mov    0x8(%ebp),%esi
  80022f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800232:	e8 45 0d 00 00       	call   800f7c <sys_getenvid>
  800237:	25 ff 03 00 00       	and    $0x3ff,%eax
  80023c:	c1 e0 07             	shl    $0x7,%eax
  80023f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800244:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800249:	85 f6                	test   %esi,%esi
  80024b:	7e 07                	jle    800254 <libmain+0x34>
		binaryname = argv[0];
  80024d:	8b 03                	mov    (%ebx),%eax
  80024f:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800254:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800258:	89 34 24             	mov    %esi,(%esp)
  80025b:	e8 e0 fd ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800260:	e8 0b 00 00 00       	call   800270 <exit>
}
  800265:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800268:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80026b:	89 ec                	mov    %ebp,%esp
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    
	...

00800270 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800276:	e8 a3 17 00 00       	call   801a1e <close_all>
	sys_env_destroy(0);
  80027b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800282:	e8 98 0c 00 00       	call   800f1f <sys_env_destroy>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    
  800289:	00 00                	add    %al,(%eax)
	...

0080028c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800294:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800297:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  80029d:	e8 da 0c 00 00       	call   800f7c <sys_getenvid>
  8002a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  8002bf:	e8 c3 00 00 00       	call   800387 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 53 00 00 00       	call   800326 <vcprintf>
	cprintf("\n");
  8002d3:	c7 04 24 ff 2d 80 00 	movl   $0x802dff,(%esp)
  8002da:	e8 a8 00 00 00       	call   800387 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002df:	cc                   	int3   
  8002e0:	eb fd                	jmp    8002df <_panic+0x53>
	...

008002e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 14             	sub    $0x14,%esp
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f7:	83 c0 01             	add    $0x1,%eax
  8002fa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800301:	75 19                	jne    80031c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800303:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80030a:	00 
  80030b:	8d 43 08             	lea    0x8(%ebx),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	e8 aa 0b 00 00       	call   800ec0 <sys_cputs>
		b->idx = 0;
  800316:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80031c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800320:	83 c4 14             	add    $0x14,%esp
  800323:	5b                   	pop    %ebx
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80032f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800336:	00 00 00 
	b.cnt = 0;
  800339:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800340:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800343:	8b 45 0c             	mov    0xc(%ebp),%eax
  800346:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800351:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035b:	c7 04 24 e4 02 80 00 	movl   $0x8002e4,(%esp)
  800362:	e8 97 01 00 00       	call   8004fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800367:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80036d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800371:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800377:	89 04 24             	mov    %eax,(%esp)
  80037a:	e8 41 0b 00 00       	call   800ec0 <sys_cputs>

	return b.cnt;
}
  80037f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800390:	89 44 24 04          	mov    %eax,0x4(%esp)
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	e8 87 ff ff ff       	call   800326 <vcprintf>
	va_end(ap);

	return cnt;
}
  80039f:	c9                   	leave  
  8003a0:	c3                   	ret    
  8003a1:	00 00                	add    %al,(%eax)
	...

008003a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 3c             	sub    $0x3c,%esp
  8003ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b0:	89 d7                	mov    %edx,%edi
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003cc:	72 11                	jb     8003df <printnum+0x3b>
  8003ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003d4:	76 09                	jbe    8003df <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d6:	83 eb 01             	sub    $0x1,%ebx
  8003d9:	85 db                	test   %ebx,%ebx
  8003db:	7f 51                	jg     80042e <printnum+0x8a>
  8003dd:	eb 5e                	jmp    80043d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003e3:	83 eb 01             	sub    $0x1,%ebx
  8003e6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003f5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800400:	00 
  800401:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040e:	e8 bd 22 00 00       	call   8026d0 <__udivdi3>
  800413:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800417:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800422:	89 fa                	mov    %edi,%edx
  800424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800427:	e8 78 ff ff ff       	call   8003a4 <printnum>
  80042c:	eb 0f                	jmp    80043d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800432:	89 34 24             	mov    %esi,(%esp)
  800435:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800438:	83 eb 01             	sub    $0x1,%ebx
  80043b:	75 f1                	jne    80042e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800441:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800445:	8b 45 10             	mov    0x10(%ebp),%eax
  800448:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800453:	00 
  800454:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800457:	89 04 24             	mov    %eax,(%esp)
  80045a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800461:	e8 9a 23 00 00       	call   802800 <__umoddi3>
  800466:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046a:	0f be 80 a3 2a 80 00 	movsbl 0x802aa3(%eax),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800477:	83 c4 3c             	add    $0x3c,%esp
  80047a:	5b                   	pop    %ebx
  80047b:	5e                   	pop    %esi
  80047c:	5f                   	pop    %edi
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800482:	83 fa 01             	cmp    $0x1,%edx
  800485:	7e 0e                	jle    800495 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800487:	8b 10                	mov    (%eax),%edx
  800489:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048c:	89 08                	mov    %ecx,(%eax)
  80048e:	8b 02                	mov    (%edx),%eax
  800490:	8b 52 04             	mov    0x4(%edx),%edx
  800493:	eb 22                	jmp    8004b7 <getuint+0x38>
	else if (lflag)
  800495:	85 d2                	test   %edx,%edx
  800497:	74 10                	je     8004a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800499:	8b 10                	mov    (%eax),%edx
  80049b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049e:	89 08                	mov    %ecx,(%eax)
  8004a0:	8b 02                	mov    (%edx),%eax
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	eb 0e                	jmp    8004b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    

008004b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c8:	73 0a                	jae    8004d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cd:	88 0a                	mov    %cl,(%edx)
  8004cf:	83 c2 01             	add    $0x1,%edx
  8004d2:	89 10                	mov    %edx,(%eax)
}
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 02 00 00 00       	call   8004fe <vprintfmt>
	va_end(ap);
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    

008004fe <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	57                   	push   %edi
  800502:	56                   	push   %esi
  800503:	53                   	push   %ebx
  800504:	83 ec 5c             	sub    $0x5c,%esp
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	8b 75 10             	mov    0x10(%ebp),%esi
  80050d:	eb 12                	jmp    800521 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050f:	85 c0                	test   %eax,%eax
  800511:	0f 84 e4 04 00 00    	je     8009fb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051b:	89 04 24             	mov    %eax,(%esp)
  80051e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800521:	0f b6 06             	movzbl (%esi),%eax
  800524:	83 c6 01             	add    $0x1,%esi
  800527:	83 f8 25             	cmp    $0x25,%eax
  80052a:	75 e3                	jne    80050f <vprintfmt+0x11>
  80052c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800530:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800537:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80053c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800543:	b9 00 00 00 00       	mov    $0x0,%ecx
  800548:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80054b:	eb 2b                	jmp    800578 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800550:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800554:	eb 22                	jmp    800578 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800559:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80055d:	eb 19                	jmp    800578 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800562:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800569:	eb 0d                	jmp    800578 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80056b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80056e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800571:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	0f b6 06             	movzbl (%esi),%eax
  80057b:	0f b6 d0             	movzbl %al,%edx
  80057e:	8d 7e 01             	lea    0x1(%esi),%edi
  800581:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800584:	83 e8 23             	sub    $0x23,%eax
  800587:	3c 55                	cmp    $0x55,%al
  800589:	0f 87 46 04 00 00    	ja     8009d5 <vprintfmt+0x4d7>
  80058f:	0f b6 c0             	movzbl %al,%eax
  800592:	ff 24 85 00 2c 80 00 	jmp    *0x802c00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800599:	83 ea 30             	sub    $0x30,%edx
  80059c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80059f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005a3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8005a9:	83 fa 09             	cmp    $0x9,%edx
  8005ac:	77 4a                	ja     8005f8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005b4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005b7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005bb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005be:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005c1:	83 fa 09             	cmp    $0x9,%edx
  8005c4:	76 eb                	jbe    8005b1 <vprintfmt+0xb3>
  8005c6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8005c9:	eb 2d                	jmp    8005f8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005dc:	eb 1a                	jmp    8005f8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8005e1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005e5:	79 91                	jns    800578 <vprintfmt+0x7a>
  8005e7:	e9 73 ff ff ff       	jmp    80055f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ef:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8005f6:	eb 80                	jmp    800578 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8005f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005fc:	0f 89 76 ff ff ff    	jns    800578 <vprintfmt+0x7a>
  800602:	e9 64 ff ff ff       	jmp    80056b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800607:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80060d:	e9 66 ff ff ff       	jmp    800578 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80062a:	e9 f2 fe ff ff       	jmp    800521 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80062f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800633:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800636:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80063a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80063d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800641:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800644:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800647:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80064b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80064e:	80 f9 09             	cmp    $0x9,%cl
  800651:	77 1d                	ja     800670 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800653:	0f be c0             	movsbl %al,%eax
  800656:	6b c0 64             	imul   $0x64,%eax,%eax
  800659:	0f be d2             	movsbl %dl,%edx
  80065c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80065f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800666:	a3 04 40 80 00       	mov    %eax,0x804004
  80066b:	e9 b1 fe ff ff       	jmp    800521 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800670:	c7 44 24 04 bb 2a 80 	movl   $0x802abb,0x4(%esp)
  800677:	00 
  800678:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	e8 18 05 00 00       	call   800b9b <strcmp>
  800683:	85 c0                	test   %eax,%eax
  800685:	75 0f                	jne    800696 <vprintfmt+0x198>
  800687:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  80068e:	00 00 00 
  800691:	e9 8b fe ff ff       	jmp    800521 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800696:	c7 44 24 04 bf 2a 80 	movl   $0x802abf,0x4(%esp)
  80069d:	00 
  80069e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006a1:	89 14 24             	mov    %edx,(%esp)
  8006a4:	e8 f2 04 00 00       	call   800b9b <strcmp>
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	75 0f                	jne    8006bc <vprintfmt+0x1be>
  8006ad:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  8006b4:	00 00 00 
  8006b7:	e9 65 fe ff ff       	jmp    800521 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8006bc:	c7 44 24 04 c3 2a 80 	movl   $0x802ac3,0x4(%esp)
  8006c3:	00 
  8006c4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8006c7:	89 0c 24             	mov    %ecx,(%esp)
  8006ca:	e8 cc 04 00 00       	call   800b9b <strcmp>
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	75 0f                	jne    8006e2 <vprintfmt+0x1e4>
  8006d3:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  8006da:	00 00 00 
  8006dd:	e9 3f fe ff ff       	jmp    800521 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8006e2:	c7 44 24 04 c7 2a 80 	movl   $0x802ac7,0x4(%esp)
  8006e9:	00 
  8006ea:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8006ed:	89 3c 24             	mov    %edi,(%esp)
  8006f0:	e8 a6 04 00 00       	call   800b9b <strcmp>
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	75 0f                	jne    800708 <vprintfmt+0x20a>
  8006f9:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  800700:	00 00 00 
  800703:	e9 19 fe ff ff       	jmp    800521 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800708:	c7 44 24 04 cb 2a 80 	movl   $0x802acb,0x4(%esp)
  80070f:	00 
  800710:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800713:	89 04 24             	mov    %eax,(%esp)
  800716:	e8 80 04 00 00       	call   800b9b <strcmp>
  80071b:	85 c0                	test   %eax,%eax
  80071d:	75 0f                	jne    80072e <vprintfmt+0x230>
  80071f:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  800726:	00 00 00 
  800729:	e9 f3 fd ff ff       	jmp    800521 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80072e:	c7 44 24 04 cf 2a 80 	movl   $0x802acf,0x4(%esp)
  800735:	00 
  800736:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800739:	89 14 24             	mov    %edx,(%esp)
  80073c:	e8 5a 04 00 00       	call   800b9b <strcmp>
  800741:	83 f8 01             	cmp    $0x1,%eax
  800744:	19 c0                	sbb    %eax,%eax
  800746:	f7 d0                	not    %eax
  800748:	83 c0 08             	add    $0x8,%eax
  80074b:	a3 04 40 80 00       	mov    %eax,0x804004
  800750:	e9 cc fd ff ff       	jmp    800521 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8d 50 04             	lea    0x4(%eax),%edx
  80075b:	89 55 14             	mov    %edx,0x14(%ebp)
  80075e:	8b 00                	mov    (%eax),%eax
  800760:	89 c2                	mov    %eax,%edx
  800762:	c1 fa 1f             	sar    $0x1f,%edx
  800765:	31 d0                	xor    %edx,%eax
  800767:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800769:	83 f8 0f             	cmp    $0xf,%eax
  80076c:	7f 0b                	jg     800779 <vprintfmt+0x27b>
  80076e:	8b 14 85 60 2d 80 00 	mov    0x802d60(,%eax,4),%edx
  800775:	85 d2                	test   %edx,%edx
  800777:	75 23                	jne    80079c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800779:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077d:	c7 44 24 08 d3 2a 80 	movl   $0x802ad3,0x8(%esp)
  800784:	00 
  800785:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800789:	8b 7d 08             	mov    0x8(%ebp),%edi
  80078c:	89 3c 24             	mov    %edi,(%esp)
  80078f:	e8 42 fd ff ff       	call   8004d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800794:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800797:	e9 85 fd ff ff       	jmp    800521 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80079c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a0:	c7 44 24 08 41 30 80 	movl   $0x803041,0x8(%esp)
  8007a7:	00 
  8007a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007af:	89 3c 24             	mov    %edi,(%esp)
  8007b2:	e8 1f fd ff ff       	call   8004d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007ba:	e9 62 fd ff ff       	jmp    800521 <vprintfmt+0x23>
  8007bf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8007c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007c5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007d3:	85 f6                	test   %esi,%esi
  8007d5:	b8 b4 2a 80 00       	mov    $0x802ab4,%eax
  8007da:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007dd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007e1:	7e 06                	jle    8007e9 <vprintfmt+0x2eb>
  8007e3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8007e7:	75 13                	jne    8007fc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e9:	0f be 06             	movsbl (%esi),%eax
  8007ec:	83 c6 01             	add    $0x1,%esi
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	0f 85 94 00 00 00    	jne    80088b <vprintfmt+0x38d>
  8007f7:	e9 81 00 00 00       	jmp    80087d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800800:	89 34 24             	mov    %esi,(%esp)
  800803:	e8 a3 02 00 00       	call   800aab <strnlen>
  800808:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80080b:	29 c2                	sub    %eax,%edx
  80080d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800810:	85 d2                	test   %edx,%edx
  800812:	7e d5                	jle    8007e9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800814:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800818:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80081b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80081e:	89 d6                	mov    %edx,%esi
  800820:	89 cf                	mov    %ecx,%edi
  800822:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800826:	89 3c 24             	mov    %edi,(%esp)
  800829:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082c:	83 ee 01             	sub    $0x1,%esi
  80082f:	75 f1                	jne    800822 <vprintfmt+0x324>
  800831:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800834:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800837:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80083a:	eb ad                	jmp    8007e9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80083c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800840:	74 1b                	je     80085d <vprintfmt+0x35f>
  800842:	8d 50 e0             	lea    -0x20(%eax),%edx
  800845:	83 fa 5e             	cmp    $0x5e,%edx
  800848:	76 13                	jbe    80085d <vprintfmt+0x35f>
					putch('?', putdat);
  80084a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800858:	ff 55 08             	call   *0x8(%ebp)
  80085b:	eb 0d                	jmp    80086a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80085d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800860:	89 54 24 04          	mov    %edx,0x4(%esp)
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80086a:	83 eb 01             	sub    $0x1,%ebx
  80086d:	0f be 06             	movsbl (%esi),%eax
  800870:	83 c6 01             	add    $0x1,%esi
  800873:	85 c0                	test   %eax,%eax
  800875:	75 1a                	jne    800891 <vprintfmt+0x393>
  800877:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80087a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800880:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800884:	7f 1c                	jg     8008a2 <vprintfmt+0x3a4>
  800886:	e9 96 fc ff ff       	jmp    800521 <vprintfmt+0x23>
  80088b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80088e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800891:	85 ff                	test   %edi,%edi
  800893:	78 a7                	js     80083c <vprintfmt+0x33e>
  800895:	83 ef 01             	sub    $0x1,%edi
  800898:	79 a2                	jns    80083c <vprintfmt+0x33e>
  80089a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80089d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008a0:	eb db                	jmp    80087d <vprintfmt+0x37f>
  8008a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a5:	89 de                	mov    %ebx,%esi
  8008a7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b7:	83 eb 01             	sub    $0x1,%ebx
  8008ba:	75 ee                	jne    8008aa <vprintfmt+0x3ac>
  8008bc:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008c1:	e9 5b fc ff ff       	jmp    800521 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c6:	83 f9 01             	cmp    $0x1,%ecx
  8008c9:	7e 10                	jle    8008db <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8d 50 08             	lea    0x8(%eax),%edx
  8008d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d4:	8b 30                	mov    (%eax),%esi
  8008d6:	8b 78 04             	mov    0x4(%eax),%edi
  8008d9:	eb 26                	jmp    800901 <vprintfmt+0x403>
	else if (lflag)
  8008db:	85 c9                	test   %ecx,%ecx
  8008dd:	74 12                	je     8008f1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8008df:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e2:	8d 50 04             	lea    0x4(%eax),%edx
  8008e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e8:	8b 30                	mov    (%eax),%esi
  8008ea:	89 f7                	mov    %esi,%edi
  8008ec:	c1 ff 1f             	sar    $0x1f,%edi
  8008ef:	eb 10                	jmp    800901 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8008f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f4:	8d 50 04             	lea    0x4(%eax),%edx
  8008f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fa:	8b 30                	mov    (%eax),%esi
  8008fc:	89 f7                	mov    %esi,%edi
  8008fe:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800901:	85 ff                	test   %edi,%edi
  800903:	78 0e                	js     800913 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800905:	89 f0                	mov    %esi,%eax
  800907:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800909:	be 0a 00 00 00       	mov    $0xa,%esi
  80090e:	e9 84 00 00 00       	jmp    800997 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800913:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800917:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80091e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800921:	89 f0                	mov    %esi,%eax
  800923:	89 fa                	mov    %edi,%edx
  800925:	f7 d8                	neg    %eax
  800927:	83 d2 00             	adc    $0x0,%edx
  80092a:	f7 da                	neg    %edx
			}
			base = 10;
  80092c:	be 0a 00 00 00       	mov    $0xa,%esi
  800931:	eb 64                	jmp    800997 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800933:	89 ca                	mov    %ecx,%edx
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
  800938:	e8 42 fb ff ff       	call   80047f <getuint>
			base = 10;
  80093d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800942:	eb 53                	jmp    800997 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800944:	89 ca                	mov    %ecx,%edx
  800946:	8d 45 14             	lea    0x14(%ebp),%eax
  800949:	e8 31 fb ff ff       	call   80047f <getuint>
    			base = 8;
  80094e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800953:	eb 42                	jmp    800997 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800955:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800959:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800960:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800963:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800967:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80096e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 50 04             	lea    0x4(%eax),%edx
  800977:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80097a:	8b 00                	mov    (%eax),%eax
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800981:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800986:	eb 0f                	jmp    800997 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800988:	89 ca                	mov    %ecx,%edx
  80098a:	8d 45 14             	lea    0x14(%ebp),%eax
  80098d:	e8 ed fa ff ff       	call   80047f <getuint>
			base = 16;
  800992:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800997:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80099b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80099f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009a2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8009a6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8009aa:	89 04 24             	mov    %eax,(%esp)
  8009ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b1:	89 da                	mov    %ebx,%edx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	e8 e9 f9 ff ff       	call   8003a4 <printnum>
			break;
  8009bb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009be:	e9 5e fb ff ff       	jmp    800521 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c7:	89 14 24             	mov    %edx,(%esp)
  8009ca:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009cd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009d0:	e9 4c fb ff ff       	jmp    800521 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009e7:	0f 84 34 fb ff ff    	je     800521 <vprintfmt+0x23>
  8009ed:	83 ee 01             	sub    $0x1,%esi
  8009f0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009f4:	75 f7                	jne    8009ed <vprintfmt+0x4ef>
  8009f6:	e9 26 fb ff ff       	jmp    800521 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009fb:	83 c4 5c             	add    $0x5c,%esp
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	83 ec 28             	sub    $0x28,%esp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a12:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a16:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a20:	85 c0                	test   %eax,%eax
  800a22:	74 30                	je     800a54 <vsnprintf+0x51>
  800a24:	85 d2                	test   %edx,%edx
  800a26:	7e 2c                	jle    800a54 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a28:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a32:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a36:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3d:	c7 04 24 b9 04 80 00 	movl   $0x8004b9,(%esp)
  800a44:	e8 b5 fa ff ff       	call   8004fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a4c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a52:	eb 05                	jmp    800a59 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a61:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a68:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	89 04 24             	mov    %eax,(%esp)
  800a7c:	e8 82 ff ff ff       	call   800a03 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    
	...

00800a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a9e:	74 09                	je     800aa9 <strlen+0x19>
		n++;
  800aa0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aa7:	75 f7                	jne    800aa0 <strlen+0x10>
		n++;
	return n;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	53                   	push   %ebx
  800aaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	85 c9                	test   %ecx,%ecx
  800abc:	74 1a                	je     800ad8 <strnlen+0x2d>
  800abe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ac1:	74 15                	je     800ad8 <strnlen+0x2d>
  800ac3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ac8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aca:	39 ca                	cmp    %ecx,%edx
  800acc:	74 0a                	je     800ad8 <strnlen+0x2d>
  800ace:	83 c2 01             	add    $0x1,%edx
  800ad1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ad6:	75 f0                	jne    800ac8 <strnlen+0x1d>
		n++;
	return n;
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800aee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800af1:	83 c2 01             	add    $0x1,%edx
  800af4:	84 c9                	test   %cl,%cl
  800af6:	75 f2                	jne    800aea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	83 ec 08             	sub    $0x8,%esp
  800b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b05:	89 1c 24             	mov    %ebx,(%esp)
  800b08:	e8 83 ff ff ff       	call   800a90 <strlen>
	strcpy(dst + len, src);
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b10:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b14:	01 d8                	add    %ebx,%eax
  800b16:	89 04 24             	mov    %eax,(%esp)
  800b19:	e8 bd ff ff ff       	call   800adb <strcpy>
	return dst;
}
  800b1e:	89 d8                	mov    %ebx,%eax
  800b20:	83 c4 08             	add    $0x8,%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b34:	85 f6                	test   %esi,%esi
  800b36:	74 18                	je     800b50 <strncpy+0x2a>
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b3d:	0f b6 1a             	movzbl (%edx),%ebx
  800b40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b43:	80 3a 01             	cmpb   $0x1,(%edx)
  800b46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	39 f1                	cmp    %esi,%ecx
  800b4e:	75 ed                	jne    800b3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b60:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b63:	89 f8                	mov    %edi,%eax
  800b65:	85 f6                	test   %esi,%esi
  800b67:	74 2b                	je     800b94 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b69:	83 fe 01             	cmp    $0x1,%esi
  800b6c:	74 23                	je     800b91 <strlcpy+0x3d>
  800b6e:	0f b6 0b             	movzbl (%ebx),%ecx
  800b71:	84 c9                	test   %cl,%cl
  800b73:	74 1c                	je     800b91 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b75:	83 ee 02             	sub    $0x2,%esi
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b7d:	88 08                	mov    %cl,(%eax)
  800b7f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b82:	39 f2                	cmp    %esi,%edx
  800b84:	74 0b                	je     800b91 <strlcpy+0x3d>
  800b86:	83 c2 01             	add    $0x1,%edx
  800b89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b8d:	84 c9                	test   %cl,%cl
  800b8f:	75 ec                	jne    800b7d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800b91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b94:	29 f8                	sub    %edi,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba4:	0f b6 01             	movzbl (%ecx),%eax
  800ba7:	84 c0                	test   %al,%al
  800ba9:	74 16                	je     800bc1 <strcmp+0x26>
  800bab:	3a 02                	cmp    (%edx),%al
  800bad:	75 12                	jne    800bc1 <strcmp+0x26>
		p++, q++;
  800baf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bb2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800bb6:	84 c0                	test   %al,%al
  800bb8:	74 07                	je     800bc1 <strcmp+0x26>
  800bba:	83 c1 01             	add    $0x1,%ecx
  800bbd:	3a 02                	cmp    (%edx),%al
  800bbf:	74 ee                	je     800baf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc1:	0f b6 c0             	movzbl %al,%eax
  800bc4:	0f b6 12             	movzbl (%edx),%edx
  800bc7:	29 d0                	sub    %edx,%eax
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bdd:	85 d2                	test   %edx,%edx
  800bdf:	74 28                	je     800c09 <strncmp+0x3e>
  800be1:	0f b6 01             	movzbl (%ecx),%eax
  800be4:	84 c0                	test   %al,%al
  800be6:	74 24                	je     800c0c <strncmp+0x41>
  800be8:	3a 03                	cmp    (%ebx),%al
  800bea:	75 20                	jne    800c0c <strncmp+0x41>
  800bec:	83 ea 01             	sub    $0x1,%edx
  800bef:	74 13                	je     800c04 <strncmp+0x39>
		n--, p++, q++;
  800bf1:	83 c1 01             	add    $0x1,%ecx
  800bf4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bf7:	0f b6 01             	movzbl (%ecx),%eax
  800bfa:	84 c0                	test   %al,%al
  800bfc:	74 0e                	je     800c0c <strncmp+0x41>
  800bfe:	3a 03                	cmp    (%ebx),%al
  800c00:	74 ea                	je     800bec <strncmp+0x21>
  800c02:	eb 08                	jmp    800c0c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c0c:	0f b6 01             	movzbl (%ecx),%eax
  800c0f:	0f b6 13             	movzbl (%ebx),%edx
  800c12:	29 d0                	sub    %edx,%eax
  800c14:	eb f3                	jmp    800c09 <strncmp+0x3e>

00800c16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c20:	0f b6 10             	movzbl (%eax),%edx
  800c23:	84 d2                	test   %dl,%dl
  800c25:	74 1c                	je     800c43 <strchr+0x2d>
		if (*s == c)
  800c27:	38 ca                	cmp    %cl,%dl
  800c29:	75 09                	jne    800c34 <strchr+0x1e>
  800c2b:	eb 1b                	jmp    800c48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c2d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800c30:	38 ca                	cmp    %cl,%dl
  800c32:	74 14                	je     800c48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c34:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800c38:	84 d2                	test   %dl,%dl
  800c3a:	75 f1                	jne    800c2d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	eb 05                	jmp    800c48 <strchr+0x32>
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	0f b6 10             	movzbl (%eax),%edx
  800c57:	84 d2                	test   %dl,%dl
  800c59:	74 14                	je     800c6f <strfind+0x25>
		if (*s == c)
  800c5b:	38 ca                	cmp    %cl,%dl
  800c5d:	75 06                	jne    800c65 <strfind+0x1b>
  800c5f:	eb 0e                	jmp    800c6f <strfind+0x25>
  800c61:	38 ca                	cmp    %cl,%dl
  800c63:	74 0a                	je     800c6f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c65:	83 c0 01             	add    $0x1,%eax
  800c68:	0f b6 10             	movzbl (%eax),%edx
  800c6b:	84 d2                	test   %dl,%dl
  800c6d:	75 f2                	jne    800c61 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c89:	85 c9                	test   %ecx,%ecx
  800c8b:	74 30                	je     800cbd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c93:	75 25                	jne    800cba <memset+0x49>
  800c95:	f6 c1 03             	test   $0x3,%cl
  800c98:	75 20                	jne    800cba <memset+0x49>
		c &= 0xFF;
  800c9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c9d:	89 d3                	mov    %edx,%ebx
  800c9f:	c1 e3 08             	shl    $0x8,%ebx
  800ca2:	89 d6                	mov    %edx,%esi
  800ca4:	c1 e6 18             	shl    $0x18,%esi
  800ca7:	89 d0                	mov    %edx,%eax
  800ca9:	c1 e0 10             	shl    $0x10,%eax
  800cac:	09 f0                	or     %esi,%eax
  800cae:	09 d0                	or     %edx,%eax
  800cb0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cb2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cb5:	fc                   	cld    
  800cb6:	f3 ab                	rep stos %eax,%es:(%edi)
  800cb8:	eb 03                	jmp    800cbd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cba:	fc                   	cld    
  800cbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cbd:	89 f8                	mov    %edi,%eax
  800cbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 08             	sub    $0x8,%esp
  800cd2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce1:	39 c6                	cmp    %eax,%esi
  800ce3:	73 36                	jae    800d1b <memmove+0x4f>
  800ce5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce8:	39 d0                	cmp    %edx,%eax
  800cea:	73 2f                	jae    800d1b <memmove+0x4f>
		s += n;
		d += n;
  800cec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cef:	f6 c2 03             	test   $0x3,%dl
  800cf2:	75 1b                	jne    800d0f <memmove+0x43>
  800cf4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cfa:	75 13                	jne    800d0f <memmove+0x43>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 20                	jmp    800d3b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d21:	75 13                	jne    800d36 <memmove+0x6a>
  800d23:	a8 03                	test   $0x3,%al
  800d25:	75 0f                	jne    800d36 <memmove+0x6a>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 0a                	jne    800d36 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d2c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d2f:	89 c7                	mov    %eax,%edi
  800d31:	fc                   	cld    
  800d32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d34:	eb 05                	jmp    800d3b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d36:	89 c7                	mov    %eax,%edi
  800d38:	fc                   	cld    
  800d39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d41:	89 ec                	mov    %ebp,%esp
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	89 04 24             	mov    %eax,(%esp)
  800d5f:	e8 68 ff ff ff       	call   800ccc <memmove>
}
  800d64:	c9                   	leave  
  800d65:	c3                   	ret    

00800d66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d72:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d75:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7a:	85 ff                	test   %edi,%edi
  800d7c:	74 37                	je     800db5 <memcmp+0x4f>
		if (*s1 != *s2)
  800d7e:	0f b6 03             	movzbl (%ebx),%eax
  800d81:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d84:	83 ef 01             	sub    $0x1,%edi
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800d8c:	38 c8                	cmp    %cl,%al
  800d8e:	74 1c                	je     800dac <memcmp+0x46>
  800d90:	eb 10                	jmp    800da2 <memcmp+0x3c>
  800d92:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d97:	83 c2 01             	add    $0x1,%edx
  800d9a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d9e:	38 c8                	cmp    %cl,%al
  800da0:	74 0a                	je     800dac <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800da2:	0f b6 c0             	movzbl %al,%eax
  800da5:	0f b6 c9             	movzbl %cl,%ecx
  800da8:	29 c8                	sub    %ecx,%eax
  800daa:	eb 09                	jmp    800db5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dac:	39 fa                	cmp    %edi,%edx
  800dae:	75 e2                	jne    800d92 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800db0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dc5:	39 d0                	cmp    %edx,%eax
  800dc7:	73 19                	jae    800de2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800dcd:	38 08                	cmp    %cl,(%eax)
  800dcf:	75 06                	jne    800dd7 <memfind+0x1d>
  800dd1:	eb 0f                	jmp    800de2 <memfind+0x28>
  800dd3:	38 08                	cmp    %cl,(%eax)
  800dd5:	74 0b                	je     800de2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dd7:	83 c0 01             	add    $0x1,%eax
  800dda:	39 d0                	cmp    %edx,%eax
  800ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de0:	75 f1                	jne    800dd3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800df0:	0f b6 02             	movzbl (%edx),%eax
  800df3:	3c 20                	cmp    $0x20,%al
  800df5:	74 04                	je     800dfb <strtol+0x17>
  800df7:	3c 09                	cmp    $0x9,%al
  800df9:	75 0e                	jne    800e09 <strtol+0x25>
		s++;
  800dfb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dfe:	0f b6 02             	movzbl (%edx),%eax
  800e01:	3c 20                	cmp    $0x20,%al
  800e03:	74 f6                	je     800dfb <strtol+0x17>
  800e05:	3c 09                	cmp    $0x9,%al
  800e07:	74 f2                	je     800dfb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e09:	3c 2b                	cmp    $0x2b,%al
  800e0b:	75 0a                	jne    800e17 <strtol+0x33>
		s++;
  800e0d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e10:	bf 00 00 00 00       	mov    $0x0,%edi
  800e15:	eb 10                	jmp    800e27 <strtol+0x43>
  800e17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e1c:	3c 2d                	cmp    $0x2d,%al
  800e1e:	75 07                	jne    800e27 <strtol+0x43>
		s++, neg = 1;
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e27:	85 db                	test   %ebx,%ebx
  800e29:	0f 94 c0             	sete   %al
  800e2c:	74 05                	je     800e33 <strtol+0x4f>
  800e2e:	83 fb 10             	cmp    $0x10,%ebx
  800e31:	75 15                	jne    800e48 <strtol+0x64>
  800e33:	80 3a 30             	cmpb   $0x30,(%edx)
  800e36:	75 10                	jne    800e48 <strtol+0x64>
  800e38:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e3c:	75 0a                	jne    800e48 <strtol+0x64>
		s += 2, base = 16;
  800e3e:	83 c2 02             	add    $0x2,%edx
  800e41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e46:	eb 13                	jmp    800e5b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e48:	84 c0                	test   %al,%al
  800e4a:	74 0f                	je     800e5b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e51:	80 3a 30             	cmpb   $0x30,(%edx)
  800e54:	75 05                	jne    800e5b <strtol+0x77>
		s++, base = 8;
  800e56:	83 c2 01             	add    $0x1,%edx
  800e59:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e62:	0f b6 0a             	movzbl (%edx),%ecx
  800e65:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e68:	80 fb 09             	cmp    $0x9,%bl
  800e6b:	77 08                	ja     800e75 <strtol+0x91>
			dig = *s - '0';
  800e6d:	0f be c9             	movsbl %cl,%ecx
  800e70:	83 e9 30             	sub    $0x30,%ecx
  800e73:	eb 1e                	jmp    800e93 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800e75:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e78:	80 fb 19             	cmp    $0x19,%bl
  800e7b:	77 08                	ja     800e85 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800e7d:	0f be c9             	movsbl %cl,%ecx
  800e80:	83 e9 57             	sub    $0x57,%ecx
  800e83:	eb 0e                	jmp    800e93 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800e85:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e88:	80 fb 19             	cmp    $0x19,%bl
  800e8b:	77 14                	ja     800ea1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e8d:	0f be c9             	movsbl %cl,%ecx
  800e90:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e93:	39 f1                	cmp    %esi,%ecx
  800e95:	7d 0e                	jge    800ea5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e97:	83 c2 01             	add    $0x1,%edx
  800e9a:	0f af c6             	imul   %esi,%eax
  800e9d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e9f:	eb c1                	jmp    800e62 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ea1:	89 c1                	mov    %eax,%ecx
  800ea3:	eb 02                	jmp    800ea7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ea5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ea7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eab:	74 05                	je     800eb2 <strtol+0xce>
		*endptr = (char *) s;
  800ead:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800eb2:	89 ca                	mov    %ecx,%edx
  800eb4:	f7 da                	neg    %edx
  800eb6:	85 ff                	test   %edi,%edi
  800eb8:	0f 45 c2             	cmovne %edx,%eax
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eda:	89 c3                	mov    %eax,%ebx
  800edc:	89 c7                	mov    %eax,%edi
  800ede:	89 c6                	mov    %eax,%esi
  800ee0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ee2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eeb:	89 ec                	mov    %ebp,%esp
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_cgetc>:

int
sys_cgetc(void)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	ba 00 00 00 00       	mov    $0x0,%edx
  800f03:	b8 01 00 00 00       	mov    $0x1,%eax
  800f08:	89 d1                	mov    %edx,%ecx
  800f0a:	89 d3                	mov    %edx,%ebx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	89 d6                	mov    %edx,%esi
  800f10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1b:	89 ec                	mov    %ebp,%esp
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 38             	sub    $0x38,%esp
  800f25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f33:	b8 03 00 00 00       	mov    $0x3,%eax
  800f38:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3b:	89 cb                	mov    %ecx,%ebx
  800f3d:	89 cf                	mov    %ecx,%edi
  800f3f:	89 ce                	mov    %ecx,%esi
  800f41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7e 28                	jle    800f6f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f52:	00 
  800f53:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  800f5a:	00 
  800f5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f62:	00 
  800f63:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  800f6a:	e8 1d f3 ff ff       	call   80028c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f78:	89 ec                	mov    %ebp,%esp
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f90:	b8 02 00 00 00       	mov    $0x2,%eax
  800f95:	89 d1                	mov    %edx,%ecx
  800f97:	89 d3                	mov    %edx,%ebx
  800f99:	89 d7                	mov    %edx,%edi
  800f9b:	89 d6                	mov    %edx,%esi
  800f9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa8:	89 ec                	mov    %ebp,%esp
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_yield>:

void
sys_yield(void)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	89 d3                	mov    %edx,%ebx
  800fc9:	89 d7                	mov    %edx,%edi
  800fcb:	89 d6                	mov    %edx,%esi
  800fcd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 38             	sub    $0x38,%esp
  800fe2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800feb:	be 00 00 00 00       	mov    $0x0,%esi
  800ff0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ff5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	89 f7                	mov    %esi,%edi
  801000:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801002:	85 c0                	test   %eax,%eax
  801004:	7e 28                	jle    80102e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801006:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801011:	00 
  801012:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  801019:	00 
  80101a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801021:	00 
  801022:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  801029:	e8 5e f2 ff ff       	call   80028c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80102e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801031:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801034:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801037:	89 ec                	mov    %ebp,%esp
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 38             	sub    $0x38,%esp
  801041:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801044:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801047:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104a:	b8 05 00 00 00       	mov    $0x5,%eax
  80104f:	8b 75 18             	mov    0x18(%ebp),%esi
  801052:	8b 7d 14             	mov    0x14(%ebp),%edi
  801055:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105b:	8b 55 08             	mov    0x8(%ebp),%edx
  80105e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801060:	85 c0                	test   %eax,%eax
  801062:	7e 28                	jle    80108c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801064:	89 44 24 10          	mov    %eax,0x10(%esp)
  801068:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80106f:	00 
  801070:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  801077:	00 
  801078:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107f:	00 
  801080:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  801087:	e8 00 f2 ff ff       	call   80028c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80108c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801092:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801095:	89 ec                	mov    %ebp,%esp
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 38             	sub    $0x38,%esp
  80109f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010a2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010a5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8010b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b8:	89 df                	mov    %ebx,%edi
  8010ba:	89 de                	mov    %ebx,%esi
  8010bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	7e 28                	jle    8010ea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010dd:	00 
  8010de:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  8010e5:	e8 a2 f1 ff ff       	call   80028c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010ea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010f3:	89 ec                	mov    %ebp,%esp
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	83 ec 38             	sub    $0x38,%esp
  8010fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801100:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801103:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801106:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110b:	b8 08 00 00 00       	mov    $0x8,%eax
  801110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801113:	8b 55 08             	mov    0x8(%ebp),%edx
  801116:	89 df                	mov    %ebx,%edi
  801118:	89 de                	mov    %ebx,%esi
  80111a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111c:	85 c0                	test   %eax,%eax
  80111e:	7e 28                	jle    801148 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801120:	89 44 24 10          	mov    %eax,0x10(%esp)
  801124:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80112b:	00 
  80112c:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  801133:	00 
  801134:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80113b:	00 
  80113c:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  801143:	e8 44 f1 ff ff       	call   80028c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801148:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80114b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80114e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801151:	89 ec                	mov    %ebp,%esp
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
  801169:	b8 09 00 00 00       	mov    $0x9,%eax
  80116e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801171:	8b 55 08             	mov    0x8(%ebp),%edx
  801174:	89 df                	mov    %ebx,%edi
  801176:	89 de                	mov    %ebx,%esi
  801178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80117a:	85 c0                	test   %eax,%eax
  80117c:	7e 28                	jle    8011a6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801182:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801189:	00 
  80118a:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  801191:	00 
  801192:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801199:	00 
  80119a:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  8011a1:	e8 e6 f0 ff ff       	call   80028c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011af:	89 ec                	mov    %ebp,%esp
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 38             	sub    $0x38,%esp
  8011b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d2:	89 df                	mov    %ebx,%edi
  8011d4:	89 de                	mov    %ebx,%esi
  8011d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	7e 28                	jle    801204 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  8011ef:	00 
  8011f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011f7:	00 
  8011f8:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  8011ff:	e8 88 f0 ff ff       	call   80028c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801204:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801207:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80120a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80120d:	89 ec                	mov    %ebp,%esp
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	83 ec 0c             	sub    $0xc,%esp
  801217:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80121a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80121d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801220:	be 00 00 00 00       	mov    $0x0,%esi
  801225:	b8 0c 00 00 00       	mov    $0xc,%eax
  80122a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80122d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801233:	8b 55 08             	mov    0x8(%ebp),%edx
  801236:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801238:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80123b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80123e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801241:	89 ec                	mov    %ebp,%esp
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 38             	sub    $0x38,%esp
  80124b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80124e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801251:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801254:	b9 00 00 00 00       	mov    $0x0,%ecx
  801259:	b8 0d 00 00 00       	mov    $0xd,%eax
  80125e:	8b 55 08             	mov    0x8(%ebp),%edx
  801261:	89 cb                	mov    %ecx,%ebx
  801263:	89 cf                	mov    %ecx,%edi
  801265:	89 ce                	mov    %ecx,%esi
  801267:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801269:	85 c0                	test   %eax,%eax
  80126b:	7e 28                	jle    801295 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801271:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801278:	00 
  801279:	c7 44 24 08 bf 2d 80 	movl   $0x802dbf,0x8(%esp)
  801280:	00 
  801281:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  801290:	e8 f7 ef ff ff       	call   80028c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801295:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801298:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80129b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80129e:	89 ec                	mov    %ebp,%esp
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	83 ec 0c             	sub    $0xc,%esp
  8012a8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012ab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012ae:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012be:	89 cb                	mov    %ecx,%ebx
  8012c0:	89 cf                	mov    %ecx,%edi
  8012c2:	89 ce                	mov    %ecx,%esi
  8012c4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8012c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012cf:	89 ec                	mov    %ebp,%esp
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    
	...

008012d4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 24             	sub    $0x24,%esp
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8012de:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  8012e0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8012e4:	75 1c                	jne    801302 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  8012e6:	c7 44 24 08 ea 2d 80 	movl   $0x802dea,0x8(%esp)
  8012ed:	00 
  8012ee:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8012f5:	00 
  8012f6:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8012fd:	e8 8a ef ff ff       	call   80028c <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801302:	89 d8                	mov    %ebx,%eax
  801304:	c1 e8 0c             	shr    $0xc,%eax
  801307:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130e:	f6 c4 08             	test   $0x8,%ah
  801311:	0f 84 be 00 00 00    	je     8013d5 <pgfault+0x101>
  801317:	89 d8                	mov    %ebx,%eax
  801319:	c1 e8 16             	shr    $0x16,%eax
  80131c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801323:	a8 01                	test   $0x1,%al
  801325:	0f 84 aa 00 00 00    	je     8013d5 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  80132b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801332:	00 
  801333:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80133a:	00 
  80133b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801342:	e8 95 fc ff ff       	call   800fdc <sys_page_alloc>
		if (r < 0)
  801347:	85 c0                	test   %eax,%eax
  801349:	79 20                	jns    80136b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80134b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134f:	c7 44 24 08 24 2e 80 	movl   $0x802e24,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80135e:	00 
  80135f:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  801366:	e8 21 ef ff ff       	call   80028c <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80136b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801371:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801378:	00 
  801379:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80137d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801384:	e8 bc f9 ff ff       	call   800d45 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801389:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801390:	00 
  801391:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801395:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80139c:	00 
  80139d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013a4:	00 
  8013a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ac:	e8 8a fc ff ff       	call   80103b <sys_page_map>
		if (r < 0)
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	79 3c                	jns    8013f1 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  8013b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b9:	c7 44 24 08 4c 2e 80 	movl   $0x802e4c,0x8(%esp)
  8013c0:	00 
  8013c1:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8013c8:	00 
  8013c9:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8013d0:	e8 b7 ee ff ff       	call   80028c <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  8013d5:	c7 44 24 08 70 2e 80 	movl   $0x802e70,0x8(%esp)
  8013dc:	00 
  8013dd:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8013e4:	00 
  8013e5:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8013ec:	e8 9b ee ff ff       	call   80028c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  8013f1:	83 c4 24             	add    $0x24,%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801400:	c7 04 24 d4 12 80 00 	movl   $0x8012d4,(%esp)
  801407:	e8 14 12 00 00       	call   802620 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80140c:	bf 07 00 00 00       	mov    $0x7,%edi
  801411:	89 f8                	mov    %edi,%eax
  801413:	cd 30                	int    $0x30
  801415:	89 c7                	mov    %eax,%edi
  801417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80141a:	85 c0                	test   %eax,%eax
  80141c:	79 20                	jns    80143e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80141e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801422:	c7 44 24 08 90 2e 80 	movl   $0x802e90,0x8(%esp)
  801429:	00 
  80142a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801431:	00 
  801432:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  801439:	e8 4e ee ff ff       	call   80028c <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80143e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801443:	85 c0                	test   %eax,%eax
  801445:	75 1c                	jne    801463 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801447:	e8 30 fb ff ff       	call   800f7c <sys_getenvid>
  80144c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801451:	c1 e0 07             	shl    $0x7,%eax
  801454:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801459:	a3 04 50 80 00       	mov    %eax,0x805004
		//cprintf("child fork ok!\n");
		return 0;
  80145e:	e9 51 02 00 00       	jmp    8016b4 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801463:	89 d8                	mov    %ebx,%eax
  801465:	c1 e8 16             	shr    $0x16,%eax
  801468:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146f:	a8 01                	test   $0x1,%al
  801471:	0f 84 87 01 00 00    	je     8015fe <fork+0x207>
  801477:	89 d8                	mov    %ebx,%eax
  801479:	c1 e8 0c             	shr    $0xc,%eax
  80147c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801483:	f6 c2 01             	test   $0x1,%dl
  801486:	0f 84 72 01 00 00    	je     8015fe <fork+0x207>
  80148c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801493:	f6 c2 04             	test   $0x4,%dl
  801496:	0f 84 62 01 00 00    	je     8015fe <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80149c:	89 c6                	mov    %eax,%esi
  80149e:	c1 e6 0c             	shl    $0xc,%esi
  8014a1:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8014a7:	0f 84 51 01 00 00    	je     8015fe <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  8014ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b4:	f6 c6 04             	test   $0x4,%dh
  8014b7:	74 53                	je     80150c <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8014b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014c9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014df:	e8 57 fb ff ff       	call   80103b <sys_page_map>
		if (r < 0)
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	0f 89 12 01 00 00    	jns    8015fe <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  8014ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f0:	c7 44 24 08 b0 2e 80 	movl   $0x802eb0,0x8(%esp)
  8014f7:	00 
  8014f8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8014ff:	00 
  801500:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  801507:	e8 80 ed ff ff       	call   80028c <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80150c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801513:	f6 c2 02             	test   $0x2,%dl
  801516:	75 10                	jne    801528 <fork+0x131>
  801518:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151f:	f6 c4 08             	test   $0x8,%ah
  801522:	0f 84 8f 00 00 00    	je     8015b7 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801528:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80152f:	00 
  801530:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801537:	89 44 24 08          	mov    %eax,0x8(%esp)
  80153b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80153f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801546:	e8 f0 fa ff ff       	call   80103b <sys_page_map>
		if (r < 0)
  80154b:	85 c0                	test   %eax,%eax
  80154d:	79 20                	jns    80156f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80154f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801553:	c7 44 24 08 dc 2e 80 	movl   $0x802edc,0x8(%esp)
  80155a:	00 
  80155b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801562:	00 
  801563:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  80156a:	e8 1d ed ff ff       	call   80028c <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80156f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801576:	00 
  801577:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80157b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801582:	00 
  801583:	89 74 24 04          	mov    %esi,0x4(%esp)
  801587:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158e:	e8 a8 fa ff ff       	call   80103b <sys_page_map>
		if (r < 0)
  801593:	85 c0                	test   %eax,%eax
  801595:	79 67                	jns    8015fe <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801597:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159b:	c7 44 24 08 dc 2e 80 	movl   $0x802edc,0x8(%esp)
  8015a2:	00 
  8015a3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8015aa:	00 
  8015ab:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8015b2:	e8 d5 ec ff ff       	call   80028c <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  8015b7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8015be:	00 
  8015bf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d5:	e8 61 fa ff ff       	call   80103b <sys_page_map>
		if (r < 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	79 20                	jns    8015fe <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8015de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e2:	c7 44 24 08 dc 2e 80 	movl   $0x802edc,0x8(%esp)
  8015e9:	00 
  8015ea:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8015f1:	00 
  8015f2:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8015f9:	e8 8e ec ff ff       	call   80028c <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  8015fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801604:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80160a:	0f 85 53 fe ff ff    	jne    801463 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801610:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801617:	00 
  801618:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80161f:	ee 
  801620:	89 3c 24             	mov    %edi,(%esp)
  801623:	e8 b4 f9 ff ff       	call   800fdc <sys_page_alloc>
	if (res < 0)
  801628:	85 c0                	test   %eax,%eax
  80162a:	79 20                	jns    80164c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  80162c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801630:	c7 44 24 08 00 2f 80 	movl   $0x802f00,0x8(%esp)
  801637:	00 
  801638:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80163f:	00 
  801640:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  801647:	e8 40 ec ff ff       	call   80028c <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80164c:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  801653:	00 
  801654:	89 3c 24             	mov    %edi,(%esp)
  801657:	e8 57 fb ff ff       	call   8011b3 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80165c:	85 c0                	test   %eax,%eax
  80165e:	79 20                	jns    801680 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801660:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801664:	c7 44 24 08 24 2f 80 	movl   $0x802f24,0x8(%esp)
  80166b:	00 
  80166c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801673:	00 
  801674:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  80167b:	e8 0c ec ff ff       	call   80028c <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801680:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801687:	00 
  801688:	89 3c 24             	mov    %edi,(%esp)
  80168b:	e8 67 fa ff ff       	call   8010f7 <sys_env_set_status>
	if (res < 0)
  801690:	85 c0                	test   %eax,%eax
  801692:	79 20                	jns    8016b4 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801694:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801698:	c7 44 24 08 54 2f 80 	movl   $0x802f54,0x8(%esp)
  80169f:	00 
  8016a0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  8016a7:	00 
  8016a8:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8016af:	e8 d8 eb ff ff       	call   80028c <_panic>

	return pid;
	//panic("fork not implemented");
}
  8016b4:	89 f8                	mov    %edi,%eax
  8016b6:	83 c4 3c             	add    $0x3c,%esp
  8016b9:	5b                   	pop    %ebx
  8016ba:	5e                   	pop    %esi
  8016bb:	5f                   	pop    %edi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <sfork>:

// Challenge!
int
sfork(void)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016c4:	c7 44 24 08 0c 2e 80 	movl   $0x802e0c,0x8(%esp)
  8016cb:	00 
  8016cc:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8016d3:	00 
  8016d4:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8016db:	e8 ac eb ff ff       	call   80028c <_panic>

008016e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 10             	sub    $0x10,%esp
  8016e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8016f1:	85 db                	test   %ebx,%ebx
  8016f3:	74 06                	je     8016fb <ipc_recv+0x1b>
  8016f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8016fb:	85 f6                	test   %esi,%esi
  8016fd:	74 06                	je     801705 <ipc_recv+0x25>
  8016ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801705:	85 c0                	test   %eax,%eax
  801707:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80170c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80170f:	89 04 24             	mov    %eax,(%esp)
  801712:	e8 2e fb ff ff       	call   801245 <sys_ipc_recv>
    if (ret) return ret;
  801717:	85 c0                	test   %eax,%eax
  801719:	75 24                	jne    80173f <ipc_recv+0x5f>
    if (from_env_store)
  80171b:	85 db                	test   %ebx,%ebx
  80171d:	74 0a                	je     801729 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80171f:	a1 04 50 80 00       	mov    0x805004,%eax
  801724:	8b 40 74             	mov    0x74(%eax),%eax
  801727:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801729:	85 f6                	test   %esi,%esi
  80172b:	74 0a                	je     801737 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80172d:	a1 04 50 80 00       	mov    0x805004,%eax
  801732:	8b 40 78             	mov    0x78(%eax),%eax
  801735:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801737:	a1 04 50 80 00       	mov    0x805004,%eax
  80173c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	57                   	push   %edi
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	83 ec 1c             	sub    $0x1c,%esp
  80174f:	8b 75 08             	mov    0x8(%ebp),%esi
  801752:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801755:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801758:	85 db                	test   %ebx,%ebx
  80175a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80175f:	0f 44 d8             	cmove  %eax,%ebx
  801762:	eb 2a                	jmp    80178e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801764:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801767:	74 20                	je     801789 <ipc_send+0x43>
  801769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80176d:	c7 44 24 08 7a 2f 80 	movl   $0x802f7a,0x8(%esp)
  801774:	00 
  801775:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80177c:	00 
  80177d:	c7 04 24 91 2f 80 00 	movl   $0x802f91,(%esp)
  801784:	e8 03 eb ff ff       	call   80028c <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801789:	e8 1e f8 ff ff       	call   800fac <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80178e:	8b 45 14             	mov    0x14(%ebp),%eax
  801791:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801795:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801799:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179d:	89 34 24             	mov    %esi,(%esp)
  8017a0:	e8 6c fa ff ff       	call   801211 <sys_ipc_try_send>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	75 bb                	jne    801764 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8017a9:	83 c4 1c             	add    $0x1c,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5f                   	pop    %edi
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8017b7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8017bc:	39 c8                	cmp    %ecx,%eax
  8017be:	74 19                	je     8017d9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8017c0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	c1 e2 07             	shl    $0x7,%edx
  8017ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8017d0:	8b 52 50             	mov    0x50(%edx),%edx
  8017d3:	39 ca                	cmp    %ecx,%edx
  8017d5:	75 14                	jne    8017eb <ipc_find_env+0x3a>
  8017d7:	eb 05                	jmp    8017de <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8017d9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8017de:	c1 e0 07             	shl    $0x7,%eax
  8017e1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8017e6:	8b 40 40             	mov    0x40(%eax),%eax
  8017e9:	eb 0e                	jmp    8017f9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8017eb:	83 c0 01             	add    $0x1,%eax
  8017ee:	3d 00 04 00 00       	cmp    $0x400,%eax
  8017f3:	75 d0                	jne    8017c5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8017f5:	66 b8 00 00          	mov    $0x0,%ax
}
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    
  8017fb:	00 00                	add    %al,(%eax)
  8017fd:	00 00                	add    %al,(%eax)
	...

00801800 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	05 00 00 00 30       	add    $0x30000000,%eax
  80180b:	c1 e8 0c             	shr    $0xc,%eax
}
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801816:	8b 45 08             	mov    0x8(%ebp),%eax
  801819:	89 04 24             	mov    %eax,(%esp)
  80181c:	e8 df ff ff ff       	call   801800 <fd2num>
  801821:	05 20 00 0d 00       	add    $0xd0020,%eax
  801826:	c1 e0 0c             	shl    $0xc,%eax
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	53                   	push   %ebx
  80182f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801832:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801837:	a8 01                	test   $0x1,%al
  801839:	74 34                	je     80186f <fd_alloc+0x44>
  80183b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801840:	a8 01                	test   $0x1,%al
  801842:	74 32                	je     801876 <fd_alloc+0x4b>
  801844:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801849:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	c1 ea 16             	shr    $0x16,%edx
  801850:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801857:	f6 c2 01             	test   $0x1,%dl
  80185a:	74 1f                	je     80187b <fd_alloc+0x50>
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	c1 ea 0c             	shr    $0xc,%edx
  801861:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801868:	f6 c2 01             	test   $0x1,%dl
  80186b:	75 17                	jne    801884 <fd_alloc+0x59>
  80186d:	eb 0c                	jmp    80187b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80186f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801874:	eb 05                	jmp    80187b <fd_alloc+0x50>
  801876:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80187b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80187d:	b8 00 00 00 00       	mov    $0x0,%eax
  801882:	eb 17                	jmp    80189b <fd_alloc+0x70>
  801884:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801889:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80188e:	75 b9                	jne    801849 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801890:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801896:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80189b:	5b                   	pop    %ebx
  80189c:	5d                   	pop    %ebp
  80189d:	c3                   	ret    

0080189e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8018a9:	83 fa 1f             	cmp    $0x1f,%edx
  8018ac:	77 3f                	ja     8018ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8018ae:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8018b4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8018b7:	89 d0                	mov    %edx,%eax
  8018b9:	c1 e8 16             	shr    $0x16,%eax
  8018bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8018c8:	f6 c1 01             	test   $0x1,%cl
  8018cb:	74 20                	je     8018ed <fd_lookup+0x4f>
  8018cd:	89 d0                	mov    %edx,%eax
  8018cf:	c1 e8 0c             	shr    $0xc,%eax
  8018d2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8018de:	f6 c1 01             	test   $0x1,%cl
  8018e1:	74 0a                	je     8018ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 14             	sub    $0x14,%esp
  8018f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8018fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801901:	39 0d 08 40 80 00    	cmp    %ecx,0x804008
  801907:	75 17                	jne    801920 <dev_lookup+0x31>
  801909:	eb 07                	jmp    801912 <dev_lookup+0x23>
  80190b:	39 0a                	cmp    %ecx,(%edx)
  80190d:	75 11                	jne    801920 <dev_lookup+0x31>
  80190f:	90                   	nop
  801910:	eb 05                	jmp    801917 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801912:	ba 08 40 80 00       	mov    $0x804008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801917:	89 13                	mov    %edx,(%ebx)
			return 0;
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
  80191e:	eb 35                	jmp    801955 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801920:	83 c0 01             	add    $0x1,%eax
  801923:	8b 14 85 18 30 80 00 	mov    0x803018(,%eax,4),%edx
  80192a:	85 d2                	test   %edx,%edx
  80192c:	75 dd                	jne    80190b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80192e:	a1 04 50 80 00       	mov    0x805004,%eax
  801933:	8b 40 48             	mov    0x48(%eax),%eax
  801936:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80193a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193e:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  801945:	e8 3d ea ff ff       	call   800387 <cprintf>
	*dev = 0;
  80194a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801950:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801955:	83 c4 14             	add    $0x14,%esp
  801958:	5b                   	pop    %ebx
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 38             	sub    $0x38,%esp
  801961:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801964:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801967:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80196a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80196d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801971:	89 3c 24             	mov    %edi,(%esp)
  801974:	e8 87 fe ff ff       	call   801800 <fd2num>
  801979:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80197c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801980:	89 04 24             	mov    %eax,(%esp)
  801983:	e8 16 ff ff ff       	call   80189e <fd_lookup>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 05                	js     801993 <fd_close+0x38>
	    || fd != fd2)
  80198e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801991:	74 0e                	je     8019a1 <fd_close+0x46>
		return (must_exist ? r : 0);
  801993:	89 f0                	mov    %esi,%eax
  801995:	84 c0                	test   %al,%al
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	0f 44 d8             	cmove  %eax,%ebx
  80199f:	eb 3d                	jmp    8019de <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8019a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8019a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a8:	8b 07                	mov    (%edi),%eax
  8019aa:	89 04 24             	mov    %eax,(%esp)
  8019ad:	e8 3d ff ff ff       	call   8018ef <dev_lookup>
  8019b2:	89 c3                	mov    %eax,%ebx
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 16                	js     8019ce <fd_close+0x73>
		if (dev->dev_close)
  8019b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8019be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	74 07                	je     8019ce <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8019c7:	89 3c 24             	mov    %edi,(%esp)
  8019ca:	ff d0                	call   *%eax
  8019cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d9:	e8 bb f6 ff ff       	call   801099 <sys_page_unmap>
	return r;
}
  8019de:	89 d8                	mov    %ebx,%eax
  8019e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019e3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019e9:	89 ec                	mov    %ebp,%esp
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	89 04 24             	mov    %eax,(%esp)
  801a00:	e8 99 fe ff ff       	call   80189e <fd_lookup>
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 13                	js     801a1c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a09:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a10:	00 
  801a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a14:	89 04 24             	mov    %eax,(%esp)
  801a17:	e8 3f ff ff ff       	call   80195b <fd_close>
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <close_all>:

void
close_all(void)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	53                   	push   %ebx
  801a22:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801a25:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801a2a:	89 1c 24             	mov    %ebx,(%esp)
  801a2d:	e8 bb ff ff ff       	call   8019ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a32:	83 c3 01             	add    $0x1,%ebx
  801a35:	83 fb 20             	cmp    $0x20,%ebx
  801a38:	75 f0                	jne    801a2a <close_all+0xc>
		close(i);
}
  801a3a:	83 c4 14             	add    $0x14,%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 58             	sub    $0x58,%esp
  801a46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a4f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 3a fe ff ff       	call   80189e <fd_lookup>
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	85 c0                	test   %eax,%eax
  801a68:	0f 88 e1 00 00 00    	js     801b4f <dup+0x10f>
		return r;
	close(newfdnum);
  801a6e:	89 3c 24             	mov    %edi,(%esp)
  801a71:	e8 77 ff ff ff       	call   8019ed <close>

	newfd = INDEX2FD(newfdnum);
  801a76:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a7c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a82:	89 04 24             	mov    %eax,(%esp)
  801a85:	e8 86 fd ff ff       	call   801810 <fd2data>
  801a8a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a8c:	89 34 24             	mov    %esi,(%esp)
  801a8f:	e8 7c fd ff ff       	call   801810 <fd2data>
  801a94:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a97:	89 d8                	mov    %ebx,%eax
  801a99:	c1 e8 16             	shr    $0x16,%eax
  801a9c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801aa3:	a8 01                	test   $0x1,%al
  801aa5:	74 46                	je     801aed <dup+0xad>
  801aa7:	89 d8                	mov    %ebx,%eax
  801aa9:	c1 e8 0c             	shr    $0xc,%eax
  801aac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ab3:	f6 c2 01             	test   $0x1,%dl
  801ab6:	74 35                	je     801aed <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ab8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801abf:	25 07 0e 00 00       	and    $0xe07,%eax
  801ac4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ac8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801acb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801acf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ad6:	00 
  801ad7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801adb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae2:	e8 54 f5 ff ff       	call   80103b <sys_page_map>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 3b                	js     801b28 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801aed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af0:	89 c2                	mov    %eax,%edx
  801af2:	c1 ea 0c             	shr    $0xc,%edx
  801af5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801afc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b02:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b06:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b11:	00 
  801b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1d:	e8 19 f5 ff ff       	call   80103b <sys_page_map>
  801b22:	89 c3                	mov    %eax,%ebx
  801b24:	85 c0                	test   %eax,%eax
  801b26:	79 25                	jns    801b4d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b33:	e8 61 f5 ff ff       	call   801099 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b46:	e8 4e f5 ff ff       	call   801099 <sys_page_unmap>
	return r;
  801b4b:	eb 02                	jmp    801b4f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801b4d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801b4f:	89 d8                	mov    %ebx,%eax
  801b51:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b54:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b57:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b5a:	89 ec                	mov    %ebp,%esp
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	53                   	push   %ebx
  801b62:	83 ec 24             	sub    $0x24,%esp
  801b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6f:	89 1c 24             	mov    %ebx,(%esp)
  801b72:	e8 27 fd ff ff       	call   80189e <fd_lookup>
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 6d                	js     801be8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b85:	8b 00                	mov    (%eax),%eax
  801b87:	89 04 24             	mov    %eax,(%esp)
  801b8a:	e8 60 fd ff ff       	call   8018ef <dev_lookup>
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 55                	js     801be8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b96:	8b 50 08             	mov    0x8(%eax),%edx
  801b99:	83 e2 03             	and    $0x3,%edx
  801b9c:	83 fa 01             	cmp    $0x1,%edx
  801b9f:	75 23                	jne    801bc4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ba1:	a1 04 50 80 00       	mov    0x805004,%eax
  801ba6:	8b 40 48             	mov    0x48(%eax),%eax
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb1:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  801bb8:	e8 ca e7 ff ff       	call   800387 <cprintf>
		return -E_INVAL;
  801bbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bc2:	eb 24                	jmp    801be8 <read+0x8a>
	}
	if (!dev->dev_read)
  801bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc7:	8b 52 08             	mov    0x8(%edx),%edx
  801bca:	85 d2                	test   %edx,%edx
  801bcc:	74 15                	je     801be3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bd1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bdc:	89 04 24             	mov    %eax,(%esp)
  801bdf:	ff d2                	call   *%edx
  801be1:	eb 05                	jmp    801be8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801be3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801be8:	83 c4 24             	add    $0x24,%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bfa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bfd:	b8 00 00 00 00       	mov    $0x0,%eax
  801c02:	85 f6                	test   %esi,%esi
  801c04:	74 30                	je     801c36 <readn+0x48>
  801c06:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	29 c2                	sub    %eax,%edx
  801c0f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c13:	03 45 0c             	add    0xc(%ebp),%eax
  801c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1a:	89 3c 24             	mov    %edi,(%esp)
  801c1d:	e8 3c ff ff ff       	call   801b5e <read>
		if (m < 0)
  801c22:	85 c0                	test   %eax,%eax
  801c24:	78 10                	js     801c36 <readn+0x48>
			return m;
		if (m == 0)
  801c26:	85 c0                	test   %eax,%eax
  801c28:	74 0a                	je     801c34 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c2a:	01 c3                	add    %eax,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	39 f3                	cmp    %esi,%ebx
  801c30:	72 d9                	jb     801c0b <readn+0x1d>
  801c32:	eb 02                	jmp    801c36 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801c34:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801c36:	83 c4 1c             	add    $0x1c,%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5f                   	pop    %edi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	53                   	push   %ebx
  801c42:	83 ec 24             	sub    $0x24,%esp
  801c45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4f:	89 1c 24             	mov    %ebx,(%esp)
  801c52:	e8 47 fc ff ff       	call   80189e <fd_lookup>
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 68                	js     801cc3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c65:	8b 00                	mov    (%eax),%eax
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	e8 80 fc ff ff       	call   8018ef <dev_lookup>
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 50                	js     801cc3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c76:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c7a:	75 23                	jne    801c9f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801c7c:	a1 04 50 80 00       	mov    0x805004,%eax
  801c81:	8b 40 48             	mov    0x48(%eax),%eax
  801c84:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8c:	c7 04 24 f9 2f 80 00 	movl   $0x802ff9,(%esp)
  801c93:	e8 ef e6 ff ff       	call   800387 <cprintf>
		return -E_INVAL;
  801c98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c9d:	eb 24                	jmp    801cc3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca2:	8b 52 0c             	mov    0xc(%edx),%edx
  801ca5:	85 d2                	test   %edx,%edx
  801ca7:	74 15                	je     801cbe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ca9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801cac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cb7:	89 04 24             	mov    %eax,(%esp)
  801cba:	ff d2                	call   *%edx
  801cbc:	eb 05                	jmp    801cc3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801cbe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801cc3:	83 c4 24             	add    $0x24,%esp
  801cc6:	5b                   	pop    %ebx
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <seek>:

int
seek(int fdnum, off_t offset)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ccf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	89 04 24             	mov    %eax,(%esp)
  801cdc:	e8 bd fb ff ff       	call   80189e <fd_lookup>
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	78 0e                	js     801cf3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ce5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ce8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ceb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	53                   	push   %ebx
  801cf9:	83 ec 24             	sub    $0x24,%esp
  801cfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d06:	89 1c 24             	mov    %ebx,(%esp)
  801d09:	e8 90 fb ff ff       	call   80189e <fd_lookup>
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 61                	js     801d73 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1c:	8b 00                	mov    (%eax),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 c9 fb ff ff       	call   8018ef <dev_lookup>
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 49                	js     801d73 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d31:	75 23                	jne    801d56 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801d33:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801d38:	8b 40 48             	mov    0x48(%eax),%eax
  801d3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d43:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  801d4a:	e8 38 e6 ff ff       	call   800387 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801d4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d54:	eb 1d                	jmp    801d73 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801d56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d59:	8b 52 18             	mov    0x18(%edx),%edx
  801d5c:	85 d2                	test   %edx,%edx
  801d5e:	74 0e                	je     801d6e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d63:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d67:	89 04 24             	mov    %eax,(%esp)
  801d6a:	ff d2                	call   *%edx
  801d6c:	eb 05                	jmp    801d73 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801d6e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801d73:	83 c4 24             	add    $0x24,%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	53                   	push   %ebx
  801d7d:	83 ec 24             	sub    $0x24,%esp
  801d80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 09 fb ff ff       	call   80189e <fd_lookup>
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 52                	js     801deb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da3:	8b 00                	mov    (%eax),%eax
  801da5:	89 04 24             	mov    %eax,(%esp)
  801da8:	e8 42 fb ff ff       	call   8018ef <dev_lookup>
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 3a                	js     801deb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801db8:	74 2c                	je     801de6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801dba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801dbd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801dc4:	00 00 00 
	stat->st_isdir = 0;
  801dc7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dce:	00 00 00 
	stat->st_dev = dev;
  801dd1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801dd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ddb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dde:	89 14 24             	mov    %edx,(%esp)
  801de1:	ff 50 14             	call   *0x14(%eax)
  801de4:	eb 05                	jmp    801deb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801de6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801deb:	83 c4 24             	add    $0x24,%esp
  801dee:	5b                   	pop    %ebx
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 18             	sub    $0x18,%esp
  801df7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dfa:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801dfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e04:	00 
  801e05:	8b 45 08             	mov    0x8(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 bc 01 00 00       	call   801fcc <open>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 1b                	js     801e31 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1d:	89 1c 24             	mov    %ebx,(%esp)
  801e20:	e8 54 ff ff ff       	call   801d79 <fstat>
  801e25:	89 c6                	mov    %eax,%esi
	close(fd);
  801e27:	89 1c 24             	mov    %ebx,(%esp)
  801e2a:	e8 be fb ff ff       	call   8019ed <close>
	return r;
  801e2f:	89 f3                	mov    %esi,%ebx
}
  801e31:	89 d8                	mov    %ebx,%eax
  801e33:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e36:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e39:	89 ec                	mov    %ebp,%esp
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	00 00                	add    %al,(%eax)
	...

00801e40 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 18             	sub    $0x18,%esp
  801e46:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e49:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e4c:	89 c3                	mov    %eax,%ebx
  801e4e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801e50:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801e57:	75 11                	jne    801e6a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801e59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801e60:	e8 4c f9 ff ff       	call   8017b1 <ipc_find_env>
  801e65:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e6a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e71:	00 
  801e72:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e79:	00 
  801e7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e7e:	a1 00 50 80 00       	mov    0x805000,%eax
  801e83:	89 04 24             	mov    %eax,(%esp)
  801e86:	e8 bb f8 ff ff       	call   801746 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801e8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e92:	00 
  801e93:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9e:	e8 3d f8 ff ff       	call   8016e0 <ipc_recv>
}
  801ea3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ea6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ea9:	89 ec                	mov    %ebp,%esp
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	53                   	push   %ebx
  801eb1:	83 ec 14             	sub    $0x14,%esp
  801eb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	8b 40 0c             	mov    0xc(%eax),%eax
  801ebd:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ec2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec7:	b8 05 00 00 00       	mov    $0x5,%eax
  801ecc:	e8 6f ff ff ff       	call   801e40 <fsipc>
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 2b                	js     801f00 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ed5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801edc:	00 
  801edd:	89 1c 24             	mov    %ebx,(%esp)
  801ee0:	e8 f6 eb ff ff       	call   800adb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ee5:	a1 80 60 80 00       	mov    0x806080,%eax
  801eea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ef0:	a1 84 60 80 00       	mov    0x806084,%eax
  801ef5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f00:	83 c4 14             	add    $0x14,%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    

00801f06 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801f12:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f17:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1c:	b8 06 00 00 00       	mov    $0x6,%eax
  801f21:	e8 1a ff ff ff       	call   801e40 <fsipc>
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	56                   	push   %esi
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 10             	sub    $0x10,%esp
  801f30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801f33:	8b 45 08             	mov    0x8(%ebp),%eax
  801f36:	8b 40 0c             	mov    0xc(%eax),%eax
  801f39:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801f3e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801f44:	ba 00 00 00 00       	mov    $0x0,%edx
  801f49:	b8 03 00 00 00       	mov    $0x3,%eax
  801f4e:	e8 ed fe ff ff       	call   801e40 <fsipc>
  801f53:	89 c3                	mov    %eax,%ebx
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 6a                	js     801fc3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801f59:	39 c6                	cmp    %eax,%esi
  801f5b:	73 24                	jae    801f81 <devfile_read+0x59>
  801f5d:	c7 44 24 0c 28 30 80 	movl   $0x803028,0xc(%esp)
  801f64:	00 
  801f65:	c7 44 24 08 2f 30 80 	movl   $0x80302f,0x8(%esp)
  801f6c:	00 
  801f6d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801f74:	00 
  801f75:	c7 04 24 44 30 80 00 	movl   $0x803044,(%esp)
  801f7c:	e8 0b e3 ff ff       	call   80028c <_panic>
	assert(r <= PGSIZE);
  801f81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f86:	7e 24                	jle    801fac <devfile_read+0x84>
  801f88:	c7 44 24 0c 4f 30 80 	movl   $0x80304f,0xc(%esp)
  801f8f:	00 
  801f90:	c7 44 24 08 2f 30 80 	movl   $0x80302f,0x8(%esp)
  801f97:	00 
  801f98:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801f9f:	00 
  801fa0:	c7 04 24 44 30 80 00 	movl   $0x803044,(%esp)
  801fa7:	e8 e0 e2 ff ff       	call   80028c <_panic>
	memmove(buf, &fsipcbuf, r);
  801fac:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fb0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fb7:	00 
  801fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 09 ed ff ff       	call   800ccc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801fc3:	89 d8                	mov    %ebx,%eax
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	56                   	push   %esi
  801fd0:	53                   	push   %ebx
  801fd1:	83 ec 20             	sub    $0x20,%esp
  801fd4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801fd7:	89 34 24             	mov    %esi,(%esp)
  801fda:	e8 b1 ea ff ff       	call   800a90 <strlen>
		return -E_BAD_PATH;
  801fdf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801fe4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801fe9:	7f 5e                	jg     802049 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801feb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fee:	89 04 24             	mov    %eax,(%esp)
  801ff1:	e8 35 f8 ff ff       	call   80182b <fd_alloc>
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	78 4d                	js     802049 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ffc:	89 74 24 04          	mov    %esi,0x4(%esp)
  802000:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802007:	e8 cf ea ff ff       	call   800adb <strcpy>
	fsipcbuf.open.req_omode = mode;
  80200c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802014:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802017:	b8 01 00 00 00       	mov    $0x1,%eax
  80201c:	e8 1f fe ff ff       	call   801e40 <fsipc>
  802021:	89 c3                	mov    %eax,%ebx
  802023:	85 c0                	test   %eax,%eax
  802025:	79 15                	jns    80203c <open+0x70>
		fd_close(fd, 0);
  802027:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80202e:	00 
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	89 04 24             	mov    %eax,(%esp)
  802035:	e8 21 f9 ff ff       	call   80195b <fd_close>
		return r;
  80203a:	eb 0d                	jmp    802049 <open+0x7d>
	}

	return fd2num(fd);
  80203c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203f:	89 04 24             	mov    %eax,(%esp)
  802042:	e8 b9 f7 ff ff       	call   801800 <fd2num>
  802047:	89 c3                	mov    %eax,%ebx
}
  802049:	89 d8                	mov    %ebx,%eax
  80204b:	83 c4 20             	add    $0x20,%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5e                   	pop    %esi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
	...

00802054 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	c1 e8 16             	shr    $0x16,%eax
  80205f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802066:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206b:	f6 c1 01             	test   $0x1,%cl
  80206e:	74 1d                	je     80208d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802070:	c1 ea 0c             	shr    $0xc,%edx
  802073:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80207a:	f6 c2 01             	test   $0x1,%dl
  80207d:	74 0e                	je     80208d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207f:	c1 ea 0c             	shr    $0xc,%edx
  802082:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802089:	ef 
  80208a:	0f b7 c0             	movzwl %ax,%eax
}
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    
	...

00802090 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	83 ec 18             	sub    $0x18,%esp
  802096:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802099:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80209c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80209f:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a2:	89 04 24             	mov    %eax,(%esp)
  8020a5:	e8 66 f7 ff ff       	call   801810 <fd2data>
  8020aa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8020ac:	c7 44 24 04 5b 30 80 	movl   $0x80305b,0x4(%esp)
  8020b3:	00 
  8020b4:	89 34 24             	mov    %esi,(%esp)
  8020b7:	e8 1f ea ff ff       	call   800adb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8020bf:	2b 03                	sub    (%ebx),%eax
  8020c1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8020c7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8020ce:	00 00 00 
	stat->st_dev = &devpipe;
  8020d1:	c7 86 88 00 00 00 24 	movl   $0x804024,0x88(%esi)
  8020d8:	40 80 00 
	return 0;
}
  8020db:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8020e3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8020e6:	89 ec                	mov    %ebp,%esp
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    

008020ea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	53                   	push   %ebx
  8020ee:	83 ec 14             	sub    $0x14,%esp
  8020f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ff:	e8 95 ef ff ff       	call   801099 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802104:	89 1c 24             	mov    %ebx,(%esp)
  802107:	e8 04 f7 ff ff       	call   801810 <fd2data>
  80210c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802110:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802117:	e8 7d ef ff ff       	call   801099 <sys_page_unmap>
}
  80211c:	83 c4 14             	add    $0x14,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    

00802122 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 2c             	sub    $0x2c,%esp
  80212b:	89 c7                	mov    %eax,%edi
  80212d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802130:	a1 04 50 80 00       	mov    0x805004,%eax
  802135:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802138:	89 3c 24             	mov    %edi,(%esp)
  80213b:	e8 14 ff ff ff       	call   802054 <pageref>
  802140:	89 c6                	mov    %eax,%esi
  802142:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802145:	89 04 24             	mov    %eax,(%esp)
  802148:	e8 07 ff ff ff       	call   802054 <pageref>
  80214d:	39 c6                	cmp    %eax,%esi
  80214f:	0f 94 c0             	sete   %al
  802152:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802155:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80215b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80215e:	39 cb                	cmp    %ecx,%ebx
  802160:	75 08                	jne    80216a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802162:	83 c4 2c             	add    $0x2c,%esp
  802165:	5b                   	pop    %ebx
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80216a:	83 f8 01             	cmp    $0x1,%eax
  80216d:	75 c1                	jne    802130 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80216f:	8b 52 58             	mov    0x58(%edx),%edx
  802172:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802176:	89 54 24 08          	mov    %edx,0x8(%esp)
  80217a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80217e:	c7 04 24 62 30 80 00 	movl   $0x803062,(%esp)
  802185:	e8 fd e1 ff ff       	call   800387 <cprintf>
  80218a:	eb a4                	jmp    802130 <_pipeisclosed+0xe>

0080218c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	57                   	push   %edi
  802190:	56                   	push   %esi
  802191:	53                   	push   %ebx
  802192:	83 ec 2c             	sub    $0x2c,%esp
  802195:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802198:	89 34 24             	mov    %esi,(%esp)
  80219b:	e8 70 f6 ff ff       	call   801810 <fd2data>
  8021a0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8021a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021ab:	75 50                	jne    8021fd <devpipe_write+0x71>
  8021ad:	eb 5c                	jmp    80220b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021af:	89 da                	mov    %ebx,%edx
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	e8 6a ff ff ff       	call   802122 <_pipeisclosed>
  8021b8:	85 c0                	test   %eax,%eax
  8021ba:	75 53                	jne    80220f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021bc:	e8 eb ed ff ff       	call   800fac <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8021c4:	8b 13                	mov    (%ebx),%edx
  8021c6:	83 c2 20             	add    $0x20,%edx
  8021c9:	39 d0                	cmp    %edx,%eax
  8021cb:	73 e2                	jae    8021af <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  8021d4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  8021d7:	89 c2                	mov    %eax,%edx
  8021d9:	c1 fa 1f             	sar    $0x1f,%edx
  8021dc:	c1 ea 1b             	shr    $0x1b,%edx
  8021df:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8021e2:	83 e1 1f             	and    $0x1f,%ecx
  8021e5:	29 d1                	sub    %edx,%ecx
  8021e7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8021eb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8021ef:	83 c0 01             	add    $0x1,%eax
  8021f2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021f5:	83 c7 01             	add    $0x1,%edi
  8021f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021fb:	74 0e                	je     80220b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021fd:	8b 43 04             	mov    0x4(%ebx),%eax
  802200:	8b 13                	mov    (%ebx),%edx
  802202:	83 c2 20             	add    $0x20,%edx
  802205:	39 d0                	cmp    %edx,%eax
  802207:	73 a6                	jae    8021af <devpipe_write+0x23>
  802209:	eb c2                	jmp    8021cd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80220b:	89 f8                	mov    %edi,%eax
  80220d:	eb 05                	jmp    802214 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802214:	83 c4 2c             	add    $0x2c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    

0080221c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 28             	sub    $0x28,%esp
  802222:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802225:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802228:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80222b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80222e:	89 3c 24             	mov    %edi,(%esp)
  802231:	e8 da f5 ff ff       	call   801810 <fd2data>
  802236:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802238:	be 00 00 00 00       	mov    $0x0,%esi
  80223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802241:	75 47                	jne    80228a <devpipe_read+0x6e>
  802243:	eb 52                	jmp    802297 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802245:	89 f0                	mov    %esi,%eax
  802247:	eb 5e                	jmp    8022a7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802249:	89 da                	mov    %ebx,%edx
  80224b:	89 f8                	mov    %edi,%eax
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	e8 cd fe ff ff       	call   802122 <_pipeisclosed>
  802255:	85 c0                	test   %eax,%eax
  802257:	75 49                	jne    8022a2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802259:	e8 4e ed ff ff       	call   800fac <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80225e:	8b 03                	mov    (%ebx),%eax
  802260:	3b 43 04             	cmp    0x4(%ebx),%eax
  802263:	74 e4                	je     802249 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802265:	89 c2                	mov    %eax,%edx
  802267:	c1 fa 1f             	sar    $0x1f,%edx
  80226a:	c1 ea 1b             	shr    $0x1b,%edx
  80226d:	01 d0                	add    %edx,%eax
  80226f:	83 e0 1f             	and    $0x1f,%eax
  802272:	29 d0                	sub    %edx,%eax
  802274:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80227f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802282:	83 c6 01             	add    $0x1,%esi
  802285:	3b 75 10             	cmp    0x10(%ebp),%esi
  802288:	74 0d                	je     802297 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80228a:	8b 03                	mov    (%ebx),%eax
  80228c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80228f:	75 d4                	jne    802265 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802291:	85 f6                	test   %esi,%esi
  802293:	75 b0                	jne    802245 <devpipe_read+0x29>
  802295:	eb b2                	jmp    802249 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802297:	89 f0                	mov    %esi,%eax
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	eb 05                	jmp    8022a7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022a2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8022aa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8022ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8022b0:	89 ec                	mov    %ebp,%esp
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    

008022b4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	83 ec 48             	sub    $0x48,%esp
  8022ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8022bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8022c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8022c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022c9:	89 04 24             	mov    %eax,(%esp)
  8022cc:	e8 5a f5 ff ff       	call   80182b <fd_alloc>
  8022d1:	89 c3                	mov    %eax,%ebx
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	0f 88 45 01 00 00    	js     802420 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022db:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022e2:	00 
  8022e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f1:	e8 e6 ec ff ff       	call   800fdc <sys_page_alloc>
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	85 c0                	test   %eax,%eax
  8022fa:	0f 88 20 01 00 00    	js     802420 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802300:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802303:	89 04 24             	mov    %eax,(%esp)
  802306:	e8 20 f5 ff ff       	call   80182b <fd_alloc>
  80230b:	89 c3                	mov    %eax,%ebx
  80230d:	85 c0                	test   %eax,%eax
  80230f:	0f 88 f8 00 00 00    	js     80240d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802315:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80231c:	00 
  80231d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802320:	89 44 24 04          	mov    %eax,0x4(%esp)
  802324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232b:	e8 ac ec ff ff       	call   800fdc <sys_page_alloc>
  802330:	89 c3                	mov    %eax,%ebx
  802332:	85 c0                	test   %eax,%eax
  802334:	0f 88 d3 00 00 00    	js     80240d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80233a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80233d:	89 04 24             	mov    %eax,(%esp)
  802340:	e8 cb f4 ff ff       	call   801810 <fd2data>
  802345:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802347:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80234e:	00 
  80234f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802353:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235a:	e8 7d ec ff ff       	call   800fdc <sys_page_alloc>
  80235f:	89 c3                	mov    %eax,%ebx
  802361:	85 c0                	test   %eax,%eax
  802363:	0f 88 91 00 00 00    	js     8023fa <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80236c:	89 04 24             	mov    %eax,(%esp)
  80236f:	e8 9c f4 ff ff       	call   801810 <fd2data>
  802374:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80237b:	00 
  80237c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802380:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802387:	00 
  802388:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802393:	e8 a3 ec ff ff       	call   80103b <sys_page_map>
  802398:	89 c3                	mov    %eax,%ebx
  80239a:	85 c0                	test   %eax,%eax
  80239c:	78 4c                	js     8023ea <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80239e:	8b 15 24 40 80 00    	mov    0x804024,%edx
  8023a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023a7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023b3:	8b 15 24 40 80 00    	mov    0x804024,%edx
  8023b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023bc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023c1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023cb:	89 04 24             	mov    %eax,(%esp)
  8023ce:	e8 2d f4 ff ff       	call   801800 <fd2num>
  8023d3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8023d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023d8:	89 04 24             	mov    %eax,(%esp)
  8023db:	e8 20 f4 ff ff       	call   801800 <fd2num>
  8023e0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8023e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023e8:	eb 36                	jmp    802420 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8023ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f5:	e8 9f ec ff ff       	call   801099 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8023fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802401:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802408:	e8 8c ec ff ff       	call   801099 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80240d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802410:	89 44 24 04          	mov    %eax,0x4(%esp)
  802414:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80241b:	e8 79 ec ff ff       	call   801099 <sys_page_unmap>
    err:
	return r;
}
  802420:	89 d8                	mov    %ebx,%eax
  802422:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802425:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802428:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80242b:	89 ec                	mov    %ebp,%esp
  80242d:	5d                   	pop    %ebp
  80242e:	c3                   	ret    

0080242f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80242f:	55                   	push   %ebp
  802430:	89 e5                	mov    %esp,%ebp
  802432:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802435:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802438:	89 44 24 04          	mov    %eax,0x4(%esp)
  80243c:	8b 45 08             	mov    0x8(%ebp),%eax
  80243f:	89 04 24             	mov    %eax,(%esp)
  802442:	e8 57 f4 ff ff       	call   80189e <fd_lookup>
  802447:	85 c0                	test   %eax,%eax
  802449:	78 15                	js     802460 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80244b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244e:	89 04 24             	mov    %eax,(%esp)
  802451:	e8 ba f3 ff ff       	call   801810 <fd2data>
	return _pipeisclosed(fd, p);
  802456:	89 c2                	mov    %eax,%edx
  802458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245b:	e8 c2 fc ff ff       	call   802122 <_pipeisclosed>
}
  802460:	c9                   	leave  
  802461:	c3                   	ret    
	...

00802470 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802473:	b8 00 00 00 00       	mov    $0x0,%eax
  802478:	5d                   	pop    %ebp
  802479:	c3                   	ret    

0080247a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802480:	c7 44 24 04 7a 30 80 	movl   $0x80307a,0x4(%esp)
  802487:	00 
  802488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248b:	89 04 24             	mov    %eax,(%esp)
  80248e:	e8 48 e6 ff ff       	call   800adb <strcpy>
	return 0;
}
  802493:	b8 00 00 00 00       	mov    $0x0,%eax
  802498:	c9                   	leave  
  802499:	c3                   	ret    

0080249a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80249a:	55                   	push   %ebp
  80249b:	89 e5                	mov    %esp,%ebp
  80249d:	57                   	push   %edi
  80249e:	56                   	push   %esi
  80249f:	53                   	push   %ebx
  8024a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024a6:	be 00 00 00 00       	mov    $0x0,%esi
  8024ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024af:	74 43                	je     8024f4 <devcons_write+0x5a>
  8024b1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024b6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024bf:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8024c1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024c4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8024c9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024d0:	03 45 0c             	add    0xc(%ebp),%eax
  8024d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d7:	89 3c 24             	mov    %edi,(%esp)
  8024da:	e8 ed e7 ff ff       	call   800ccc <memmove>
		sys_cputs(buf, m);
  8024df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024e3:	89 3c 24             	mov    %edi,(%esp)
  8024e6:	e8 d5 e9 ff ff       	call   800ec0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024eb:	01 de                	add    %ebx,%esi
  8024ed:	89 f0                	mov    %esi,%eax
  8024ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024f2:	72 c8                	jb     8024bc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024f4:	89 f0                	mov    %esi,%eax
  8024f6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8024fc:	5b                   	pop    %ebx
  8024fd:	5e                   	pop    %esi
  8024fe:	5f                   	pop    %edi
  8024ff:	5d                   	pop    %ebp
  802500:	c3                   	ret    

00802501 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802501:	55                   	push   %ebp
  802502:	89 e5                	mov    %esp,%ebp
  802504:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802507:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80250c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802510:	75 07                	jne    802519 <devcons_read+0x18>
  802512:	eb 31                	jmp    802545 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802514:	e8 93 ea ff ff       	call   800fac <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	e8 ca e9 ff ff       	call   800eef <sys_cgetc>
  802525:	85 c0                	test   %eax,%eax
  802527:	74 eb                	je     802514 <devcons_read+0x13>
  802529:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80252b:	85 c0                	test   %eax,%eax
  80252d:	78 16                	js     802545 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80252f:	83 f8 04             	cmp    $0x4,%eax
  802532:	74 0c                	je     802540 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802534:	8b 45 0c             	mov    0xc(%ebp),%eax
  802537:	88 10                	mov    %dl,(%eax)
	return 1;
  802539:	b8 01 00 00 00       	mov    $0x1,%eax
  80253e:	eb 05                	jmp    802545 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802540:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802545:	c9                   	leave  
  802546:	c3                   	ret    

00802547 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802547:	55                   	push   %ebp
  802548:	89 e5                	mov    %esp,%ebp
  80254a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80254d:	8b 45 08             	mov    0x8(%ebp),%eax
  802550:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802553:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80255a:	00 
  80255b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80255e:	89 04 24             	mov    %eax,(%esp)
  802561:	e8 5a e9 ff ff       	call   800ec0 <sys_cputs>
}
  802566:	c9                   	leave  
  802567:	c3                   	ret    

00802568 <getchar>:

int
getchar(void)
{
  802568:	55                   	push   %ebp
  802569:	89 e5                	mov    %esp,%ebp
  80256b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80256e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802575:	00 
  802576:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80257d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802584:	e8 d5 f5 ff ff       	call   801b5e <read>
	if (r < 0)
  802589:	85 c0                	test   %eax,%eax
  80258b:	78 0f                	js     80259c <getchar+0x34>
		return r;
	if (r < 1)
  80258d:	85 c0                	test   %eax,%eax
  80258f:	7e 06                	jle    802597 <getchar+0x2f>
		return -E_EOF;
	return c;
  802591:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802595:	eb 05                	jmp    80259c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802597:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80259c:	c9                   	leave  
  80259d:	c3                   	ret    

0080259e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80259e:	55                   	push   %ebp
  80259f:	89 e5                	mov    %esp,%ebp
  8025a1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ae:	89 04 24             	mov    %eax,(%esp)
  8025b1:	e8 e8 f2 ff ff       	call   80189e <fd_lookup>
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	78 11                	js     8025cb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025bd:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8025c3:	39 10                	cmp    %edx,(%eax)
  8025c5:	0f 94 c0             	sete   %al
  8025c8:	0f b6 c0             	movzbl %al,%eax
}
  8025cb:	c9                   	leave  
  8025cc:	c3                   	ret    

008025cd <opencons>:

int
opencons(void)
{
  8025cd:	55                   	push   %ebp
  8025ce:	89 e5                	mov    %esp,%ebp
  8025d0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025d6:	89 04 24             	mov    %eax,(%esp)
  8025d9:	e8 4d f2 ff ff       	call   80182b <fd_alloc>
  8025de:	85 c0                	test   %eax,%eax
  8025e0:	78 3c                	js     80261e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025e9:	00 
  8025ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025f8:	e8 df e9 ff ff       	call   800fdc <sys_page_alloc>
  8025fd:	85 c0                	test   %eax,%eax
  8025ff:	78 1d                	js     80261e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802601:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802607:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80260c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802616:	89 04 24             	mov    %eax,(%esp)
  802619:	e8 e2 f1 ff ff       	call   801800 <fd2num>
}
  80261e:	c9                   	leave  
  80261f:	c3                   	ret    

00802620 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802626:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80262d:	75 3c                	jne    80266b <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80262f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802636:	00 
  802637:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80263e:	ee 
  80263f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802646:	e8 91 e9 ff ff       	call   800fdc <sys_page_alloc>
  80264b:	85 c0                	test   %eax,%eax
  80264d:	79 1c                	jns    80266b <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  80264f:	c7 44 24 08 88 30 80 	movl   $0x803088,0x8(%esp)
  802656:	00 
  802657:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80265e:	00 
  80265f:	c7 04 24 ec 30 80 00 	movl   $0x8030ec,(%esp)
  802666:	e8 21 dc ff ff       	call   80028c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80266b:	8b 45 08             	mov    0x8(%ebp),%eax
  80266e:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802673:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  80267a:	00 
  80267b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802682:	e8 2c eb ff ff       	call   8011b3 <sys_env_set_pgfault_upcall>
  802687:	85 c0                	test   %eax,%eax
  802689:	79 1c                	jns    8026a7 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80268b:	c7 44 24 08 b4 30 80 	movl   $0x8030b4,0x8(%esp)
  802692:	00 
  802693:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80269a:	00 
  80269b:	c7 04 24 ec 30 80 00 	movl   $0x8030ec,(%esp)
  8026a2:	e8 e5 db ff ff       	call   80028c <_panic>
}
  8026a7:	c9                   	leave  
  8026a8:	c3                   	ret    
  8026a9:	00 00                	add    %al,(%eax)
	...

008026ac <_pgfault_upcall>:
  8026ac:	54                   	push   %esp
  8026ad:	a1 00 70 80 00       	mov    0x807000,%eax
  8026b2:	ff d0                	call   *%eax
  8026b4:	83 c4 04             	add    $0x4,%esp
  8026b7:	8b 54 24 28          	mov    0x28(%esp),%edx
  8026bb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  8026c0:	8b 44 24 30          	mov    0x30(%esp),%eax
  8026c4:	89 10                	mov    %edx,(%eax)
  8026c6:	83 c4 08             	add    $0x8,%esp
  8026c9:	61                   	popa   
  8026ca:	83 c4 04             	add    $0x4,%esp
  8026cd:	9d                   	popf   
  8026ce:	5c                   	pop    %esp
  8026cf:	c3                   	ret    

008026d0 <__udivdi3>:
  8026d0:	83 ec 1c             	sub    $0x1c,%esp
  8026d3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8026d7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8026db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8026df:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8026e3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8026e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8026eb:	85 ff                	test   %edi,%edi
  8026ed:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8026f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026f5:	89 cd                	mov    %ecx,%ebp
  8026f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026fb:	75 33                	jne    802730 <__udivdi3+0x60>
  8026fd:	39 f1                	cmp    %esi,%ecx
  8026ff:	77 57                	ja     802758 <__udivdi3+0x88>
  802701:	85 c9                	test   %ecx,%ecx
  802703:	75 0b                	jne    802710 <__udivdi3+0x40>
  802705:	b8 01 00 00 00       	mov    $0x1,%eax
  80270a:	31 d2                	xor    %edx,%edx
  80270c:	f7 f1                	div    %ecx
  80270e:	89 c1                	mov    %eax,%ecx
  802710:	89 f0                	mov    %esi,%eax
  802712:	31 d2                	xor    %edx,%edx
  802714:	f7 f1                	div    %ecx
  802716:	89 c6                	mov    %eax,%esi
  802718:	8b 44 24 04          	mov    0x4(%esp),%eax
  80271c:	f7 f1                	div    %ecx
  80271e:	89 f2                	mov    %esi,%edx
  802720:	8b 74 24 10          	mov    0x10(%esp),%esi
  802724:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802728:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80272c:	83 c4 1c             	add    $0x1c,%esp
  80272f:	c3                   	ret    
  802730:	31 d2                	xor    %edx,%edx
  802732:	31 c0                	xor    %eax,%eax
  802734:	39 f7                	cmp    %esi,%edi
  802736:	77 e8                	ja     802720 <__udivdi3+0x50>
  802738:	0f bd cf             	bsr    %edi,%ecx
  80273b:	83 f1 1f             	xor    $0x1f,%ecx
  80273e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802742:	75 2c                	jne    802770 <__udivdi3+0xa0>
  802744:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802748:	76 04                	jbe    80274e <__udivdi3+0x7e>
  80274a:	39 f7                	cmp    %esi,%edi
  80274c:	73 d2                	jae    802720 <__udivdi3+0x50>
  80274e:	31 d2                	xor    %edx,%edx
  802750:	b8 01 00 00 00       	mov    $0x1,%eax
  802755:	eb c9                	jmp    802720 <__udivdi3+0x50>
  802757:	90                   	nop
  802758:	89 f2                	mov    %esi,%edx
  80275a:	f7 f1                	div    %ecx
  80275c:	31 d2                	xor    %edx,%edx
  80275e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802762:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802766:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80276a:	83 c4 1c             	add    $0x1c,%esp
  80276d:	c3                   	ret    
  80276e:	66 90                	xchg   %ax,%ax
  802770:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802775:	b8 20 00 00 00       	mov    $0x20,%eax
  80277a:	89 ea                	mov    %ebp,%edx
  80277c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802780:	d3 e7                	shl    %cl,%edi
  802782:	89 c1                	mov    %eax,%ecx
  802784:	d3 ea                	shr    %cl,%edx
  802786:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80278b:	09 fa                	or     %edi,%edx
  80278d:	89 f7                	mov    %esi,%edi
  80278f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802793:	89 f2                	mov    %esi,%edx
  802795:	8b 74 24 08          	mov    0x8(%esp),%esi
  802799:	d3 e5                	shl    %cl,%ebp
  80279b:	89 c1                	mov    %eax,%ecx
  80279d:	d3 ef                	shr    %cl,%edi
  80279f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027a4:	d3 e2                	shl    %cl,%edx
  8027a6:	89 c1                	mov    %eax,%ecx
  8027a8:	d3 ee                	shr    %cl,%esi
  8027aa:	09 d6                	or     %edx,%esi
  8027ac:	89 fa                	mov    %edi,%edx
  8027ae:	89 f0                	mov    %esi,%eax
  8027b0:	f7 74 24 0c          	divl   0xc(%esp)
  8027b4:	89 d7                	mov    %edx,%edi
  8027b6:	89 c6                	mov    %eax,%esi
  8027b8:	f7 e5                	mul    %ebp
  8027ba:	39 d7                	cmp    %edx,%edi
  8027bc:	72 22                	jb     8027e0 <__udivdi3+0x110>
  8027be:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8027c2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027c7:	d3 e5                	shl    %cl,%ebp
  8027c9:	39 c5                	cmp    %eax,%ebp
  8027cb:	73 04                	jae    8027d1 <__udivdi3+0x101>
  8027cd:	39 d7                	cmp    %edx,%edi
  8027cf:	74 0f                	je     8027e0 <__udivdi3+0x110>
  8027d1:	89 f0                	mov    %esi,%eax
  8027d3:	31 d2                	xor    %edx,%edx
  8027d5:	e9 46 ff ff ff       	jmp    802720 <__udivdi3+0x50>
  8027da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027e0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8027e3:	31 d2                	xor    %edx,%edx
  8027e5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027e9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027ed:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027f1:	83 c4 1c             	add    $0x1c,%esp
  8027f4:	c3                   	ret    
	...

00802800 <__umoddi3>:
  802800:	83 ec 1c             	sub    $0x1c,%esp
  802803:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802807:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80280b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80280f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802813:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802817:	8b 74 24 24          	mov    0x24(%esp),%esi
  80281b:	85 ed                	test   %ebp,%ebp
  80281d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802821:	89 44 24 08          	mov    %eax,0x8(%esp)
  802825:	89 cf                	mov    %ecx,%edi
  802827:	89 04 24             	mov    %eax,(%esp)
  80282a:	89 f2                	mov    %esi,%edx
  80282c:	75 1a                	jne    802848 <__umoddi3+0x48>
  80282e:	39 f1                	cmp    %esi,%ecx
  802830:	76 4e                	jbe    802880 <__umoddi3+0x80>
  802832:	f7 f1                	div    %ecx
  802834:	89 d0                	mov    %edx,%eax
  802836:	31 d2                	xor    %edx,%edx
  802838:	8b 74 24 10          	mov    0x10(%esp),%esi
  80283c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802840:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802844:	83 c4 1c             	add    $0x1c,%esp
  802847:	c3                   	ret    
  802848:	39 f5                	cmp    %esi,%ebp
  80284a:	77 54                	ja     8028a0 <__umoddi3+0xa0>
  80284c:	0f bd c5             	bsr    %ebp,%eax
  80284f:	83 f0 1f             	xor    $0x1f,%eax
  802852:	89 44 24 04          	mov    %eax,0x4(%esp)
  802856:	75 60                	jne    8028b8 <__umoddi3+0xb8>
  802858:	3b 0c 24             	cmp    (%esp),%ecx
  80285b:	0f 87 07 01 00 00    	ja     802968 <__umoddi3+0x168>
  802861:	89 f2                	mov    %esi,%edx
  802863:	8b 34 24             	mov    (%esp),%esi
  802866:	29 ce                	sub    %ecx,%esi
  802868:	19 ea                	sbb    %ebp,%edx
  80286a:	89 34 24             	mov    %esi,(%esp)
  80286d:	8b 04 24             	mov    (%esp),%eax
  802870:	8b 74 24 10          	mov    0x10(%esp),%esi
  802874:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802878:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80287c:	83 c4 1c             	add    $0x1c,%esp
  80287f:	c3                   	ret    
  802880:	85 c9                	test   %ecx,%ecx
  802882:	75 0b                	jne    80288f <__umoddi3+0x8f>
  802884:	b8 01 00 00 00       	mov    $0x1,%eax
  802889:	31 d2                	xor    %edx,%edx
  80288b:	f7 f1                	div    %ecx
  80288d:	89 c1                	mov    %eax,%ecx
  80288f:	89 f0                	mov    %esi,%eax
  802891:	31 d2                	xor    %edx,%edx
  802893:	f7 f1                	div    %ecx
  802895:	8b 04 24             	mov    (%esp),%eax
  802898:	f7 f1                	div    %ecx
  80289a:	eb 98                	jmp    802834 <__umoddi3+0x34>
  80289c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	89 f2                	mov    %esi,%edx
  8028a2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028a6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028aa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028ae:	83 c4 1c             	add    $0x1c,%esp
  8028b1:	c3                   	ret    
  8028b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028b8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028bd:	89 e8                	mov    %ebp,%eax
  8028bf:	bd 20 00 00 00       	mov    $0x20,%ebp
  8028c4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8028c8:	89 fa                	mov    %edi,%edx
  8028ca:	d3 e0                	shl    %cl,%eax
  8028cc:	89 e9                	mov    %ebp,%ecx
  8028ce:	d3 ea                	shr    %cl,%edx
  8028d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028d5:	09 c2                	or     %eax,%edx
  8028d7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028db:	89 14 24             	mov    %edx,(%esp)
  8028de:	89 f2                	mov    %esi,%edx
  8028e0:	d3 e7                	shl    %cl,%edi
  8028e2:	89 e9                	mov    %ebp,%ecx
  8028e4:	d3 ea                	shr    %cl,%edx
  8028e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028ef:	d3 e6                	shl    %cl,%esi
  8028f1:	89 e9                	mov    %ebp,%ecx
  8028f3:	d3 e8                	shr    %cl,%eax
  8028f5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028fa:	09 f0                	or     %esi,%eax
  8028fc:	8b 74 24 08          	mov    0x8(%esp),%esi
  802900:	f7 34 24             	divl   (%esp)
  802903:	d3 e6                	shl    %cl,%esi
  802905:	89 74 24 08          	mov    %esi,0x8(%esp)
  802909:	89 d6                	mov    %edx,%esi
  80290b:	f7 e7                	mul    %edi
  80290d:	39 d6                	cmp    %edx,%esi
  80290f:	89 c1                	mov    %eax,%ecx
  802911:	89 d7                	mov    %edx,%edi
  802913:	72 3f                	jb     802954 <__umoddi3+0x154>
  802915:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802919:	72 35                	jb     802950 <__umoddi3+0x150>
  80291b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80291f:	29 c8                	sub    %ecx,%eax
  802921:	19 fe                	sbb    %edi,%esi
  802923:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802928:	89 f2                	mov    %esi,%edx
  80292a:	d3 e8                	shr    %cl,%eax
  80292c:	89 e9                	mov    %ebp,%ecx
  80292e:	d3 e2                	shl    %cl,%edx
  802930:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802935:	09 d0                	or     %edx,%eax
  802937:	89 f2                	mov    %esi,%edx
  802939:	d3 ea                	shr    %cl,%edx
  80293b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80293f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802943:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802947:	83 c4 1c             	add    $0x1c,%esp
  80294a:	c3                   	ret    
  80294b:	90                   	nop
  80294c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802950:	39 d6                	cmp    %edx,%esi
  802952:	75 c7                	jne    80291b <__umoddi3+0x11b>
  802954:	89 d7                	mov    %edx,%edi
  802956:	89 c1                	mov    %eax,%ecx
  802958:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80295c:	1b 3c 24             	sbb    (%esp),%edi
  80295f:	eb ba                	jmp    80291b <__umoddi3+0x11b>
  802961:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802968:	39 f5                	cmp    %esi,%ebp
  80296a:	0f 82 f1 fe ff ff    	jb     802861 <__umoddi3+0x61>
  802970:	e9 f8 fe ff ff       	jmp    80286d <__umoddi3+0x6d>
