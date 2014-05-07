
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 eb 01 00 00       	call   80021c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800044:	00 
  800045:	c7 04 24 e0 29 80 00 	movl   $0x8029e0,(%esp)
  80004c:	e8 4b 1e 00 00       	call   801e9c <open>
  800051:	89 c3                	mov    %eax,%ebx
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("open motd: %e", fd);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 e5 29 80 	movl   $0x8029e5,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 f3 29 80 00 	movl   $0x8029f3,(%esp)
  800072:	e8 11 02 00 00       	call   800288 <_panic>
	seek(fd, 0);
  800077:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007e:	00 
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 12 1b 00 00       	call   801b99 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800087:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 20 52 80 	movl   $0x805220,0x4(%esp)
  800096:	00 
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 1f 1a 00 00       	call   801abe <readn>
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	7f 20                	jg     8000c5 <umain+0x91>
		panic("readn: %e", n);
  8000a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a9:	c7 44 24 08 08 2a 80 	movl   $0x802a08,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b8:	00 
  8000b9:	c7 04 24 f3 29 80 00 	movl   $0x8029f3,(%esp)
  8000c0:	e8 c3 01 00 00       	call   800288 <_panic>

	if ((r = fork()) < 0)
  8000c5:	e8 1d 13 00 00       	call   8013e7 <fork>
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	79 20                	jns    8000f0 <umain+0xbc>
		panic("fork: %e", r);
  8000d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d4:	c7 44 24 08 12 2a 80 	movl   $0x802a12,0x8(%esp)
  8000db:	00 
  8000dc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e3:	00 
  8000e4:	c7 04 24 f3 29 80 00 	movl   $0x8029f3,(%esp)
  8000eb:	e8 98 01 00 00       	call   800288 <_panic>
	if (r == 0) {
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	0f 85 bd 00 00 00    	jne    8001b5 <umain+0x181>
		seek(fd, 0);
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 91 1a 00 00       	call   801b99 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800108:	c7 04 24 50 2a 80 00 	movl   $0x802a50,(%esp)
  80010f:	e8 6f 02 00 00       	call   800383 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011b:	00 
  80011c:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  800123:	00 
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 92 19 00 00       	call   801abe <readn>
  80012c:	39 f8                	cmp    %edi,%eax
  80012e:	74 24                	je     800154 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800138:	c7 44 24 08 94 2a 80 	movl   $0x802a94,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 f3 29 80 00 	movl   $0x8029f3,(%esp)
  80014f:	e8 34 01 00 00       	call   800288 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800154:	89 44 24 08          	mov    %eax,0x8(%esp)
  800158:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  80015f:	00 
  800160:	c7 04 24 20 52 80 00 	movl   $0x805220,(%esp)
  800167:	e8 ea 0b 00 00       	call   800d56 <memcmp>
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 1c                	je     80018c <umain+0x158>
			panic("read in parent got different bytes from read in child");
  800170:	c7 44 24 08 c0 2a 80 	movl   $0x802ac0,0x8(%esp)
  800177:	00 
  800178:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017f:	00 
  800180:	c7 04 24 f3 29 80 00 	movl   $0x8029f3,(%esp)
  800187:	e8 fc 00 00 00       	call   800288 <_panic>
		cprintf("read in child succeeded\n");
  80018c:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800193:	e8 eb 01 00 00       	call   800383 <cprintf>
		seek(fd, 0);
  800198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019f:	00 
  8001a0:	89 1c 24             	mov    %ebx,(%esp)
  8001a3:	e8 f1 19 00 00       	call   801b99 <seek>
		close(fd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 0d 17 00 00       	call   8018bd <close>
		exit();
  8001b0:	e8 b7 00 00 00       	call   80026c <exit>
	}
	wait(r);
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 47 21 00 00       	call   802304 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  8001cc:	00 
  8001cd:	89 1c 24             	mov    %ebx,(%esp)
  8001d0:	e8 e9 18 00 00       	call   801abe <readn>
  8001d5:	39 f8                	cmp    %edi,%eax
  8001d7:	74 24                	je     8001fd <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e1:	c7 44 24 08 f8 2a 80 	movl   $0x802af8,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 f3 29 80 00 	movl   $0x8029f3,(%esp)
  8001f8:	e8 8b 00 00 00       	call   800288 <_panic>
	cprintf("read in parent succeeded\n");
  8001fd:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  800204:	e8 7a 01 00 00       	call   800383 <cprintf>
	close(fd);
  800209:	89 1c 24             	mov    %ebx,(%esp)
  80020c:	e8 ac 16 00 00       	call   8018bd <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800211:	cc                   	int3   

	breakpoint();
}
  800212:	83 c4 2c             	add    $0x2c,%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
	...

0080021c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 18             	sub    $0x18,%esp
  800222:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800225:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800228:	8b 75 08             	mov    0x8(%ebp),%esi
  80022b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80022e:	e8 39 0d 00 00       	call   800f6c <sys_getenvid>
  800233:	25 ff 03 00 00       	and    $0x3ff,%eax
  800238:	c1 e0 07             	shl    $0x7,%eax
  80023b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800240:	a3 20 54 80 00       	mov    %eax,0x805420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800245:	85 f6                	test   %esi,%esi
  800247:	7e 07                	jle    800250 <libmain+0x34>
		binaryname = argv[0];
  800249:	8b 03                	mov    (%ebx),%eax
  80024b:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800254:	89 34 24             	mov    %esi,(%esp)
  800257:	e8 d8 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80025c:	e8 0b 00 00 00       	call   80026c <exit>
}
  800261:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800264:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800267:	89 ec                	mov    %ebp,%esp
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    
	...

0080026c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800272:	e8 77 16 00 00       	call   8018ee <close_all>
	sys_env_destroy(0);
  800277:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80027e:	e8 8c 0c 00 00       	call   800f0f <sys_env_destroy>
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    
  800285:	00 00                	add    %al,(%eax)
	...

00800288 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800290:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800293:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800299:	e8 ce 0c 00 00       	call   800f6c <sys_getenvid>
  80029e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b4:	c7 04 24 28 2b 80 00 	movl   $0x802b28,(%esp)
  8002bb:	e8 c3 00 00 00       	call   800383 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 53 00 00 00       	call   800322 <vcprintf>
	cprintf("\n");
  8002cf:	c7 04 24 9f 2e 80 00 	movl   $0x802e9f,(%esp)
  8002d6:	e8 a8 00 00 00       	call   800383 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x53>
	...

008002e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 14             	sub    $0x14,%esp
  8002e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ea:	8b 03                	mov    (%ebx),%eax
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f3:	83 c0 01             	add    $0x1,%eax
  8002f6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fd:	75 19                	jne    800318 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002ff:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800306:	00 
  800307:	8d 43 08             	lea    0x8(%ebx),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	e8 9e 0b 00 00       	call   800eb0 <sys_cputs>
		b->idx = 0;
  800312:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800318:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031c:	83 c4 14             	add    $0x14,%esp
  80031f:	5b                   	pop    %ebx
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80032b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800332:	00 00 00 
	b.cnt = 0;
  800335:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800342:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800353:	89 44 24 04          	mov    %eax,0x4(%esp)
  800357:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  80035e:	e8 97 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800363:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800373:	89 04 24             	mov    %eax,(%esp)
  800376:	e8 35 0b 00 00       	call   800eb0 <sys_cputs>

	return b.cnt;
}
  80037b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800389:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80038c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	e8 87 ff ff ff       	call   800322 <vcprintf>
	va_end(ap);

	return cnt;
}
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    
  80039d:	00 00                	add    %al,(%eax)
	...

008003a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 3c             	sub    $0x3c,%esp
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003c8:	72 11                	jb     8003db <printnum+0x3b>
  8003ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003d0:	76 09                	jbe    8003db <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d2:	83 eb 01             	sub    $0x1,%ebx
  8003d5:	85 db                	test   %ebx,%ebx
  8003d7:	7f 51                	jg     80042a <printnum+0x8a>
  8003d9:	eb 5e                	jmp    800439 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003db:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003df:	83 eb 01             	sub    $0x1,%ebx
  8003e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ed:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003f1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003fc:	00 
  8003fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040a:	e8 21 23 00 00       	call   802730 <__udivdi3>
  80040f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800413:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80041e:	89 fa                	mov    %edi,%edx
  800420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800423:	e8 78 ff ff ff       	call   8003a0 <printnum>
  800428:	eb 0f                	jmp    800439 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042e:	89 34 24             	mov    %esi,(%esp)
  800431:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800434:	83 eb 01             	sub    $0x1,%ebx
  800437:	75 f1                	jne    80042a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800439:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800441:	8b 45 10             	mov    0x10(%ebp),%eax
  800444:	89 44 24 08          	mov    %eax,0x8(%esp)
  800448:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044f:	00 
  800450:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045d:	e8 fe 23 00 00       	call   802860 <__umoddi3>
  800462:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800466:	0f be 80 4b 2b 80 00 	movsbl 0x802b4b(%eax),%eax
  80046d:	89 04 24             	mov    %eax,(%esp)
  800470:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800473:	83 c4 3c             	add    $0x3c,%esp
  800476:	5b                   	pop    %ebx
  800477:	5e                   	pop    %esi
  800478:	5f                   	pop    %edi
  800479:	5d                   	pop    %ebp
  80047a:	c3                   	ret    

0080047b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047e:	83 fa 01             	cmp    $0x1,%edx
  800481:	7e 0e                	jle    800491 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800483:	8b 10                	mov    (%eax),%edx
  800485:	8d 4a 08             	lea    0x8(%edx),%ecx
  800488:	89 08                	mov    %ecx,(%eax)
  80048a:	8b 02                	mov    (%edx),%eax
  80048c:	8b 52 04             	mov    0x4(%edx),%edx
  80048f:	eb 22                	jmp    8004b3 <getuint+0x38>
	else if (lflag)
  800491:	85 d2                	test   %edx,%edx
  800493:	74 10                	je     8004a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800495:	8b 10                	mov    (%eax),%edx
  800497:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049a:	89 08                	mov    %ecx,(%eax)
  80049c:	8b 02                	mov    (%edx),%eax
  80049e:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a3:	eb 0e                	jmp    8004b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b3:	5d                   	pop    %ebp
  8004b4:	c3                   	ret    

008004b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004bf:	8b 10                	mov    (%eax),%edx
  8004c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c4:	73 0a                	jae    8004d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c9:	88 0a                	mov    %cl,(%edx)
  8004cb:	83 c2 01             	add    $0x1,%edx
  8004ce:	89 10                	mov    %edx,(%eax)
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004df:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 02 00 00 00       	call   8004fa <vprintfmt>
	va_end(ap);
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 5c             	sub    $0x5c,%esp
  800503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800506:	8b 75 10             	mov    0x10(%ebp),%esi
  800509:	eb 12                	jmp    80051d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050b:	85 c0                	test   %eax,%eax
  80050d:	0f 84 e4 04 00 00    	je     8009f7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800513:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800517:	89 04 24             	mov    %eax,(%esp)
  80051a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80051d:	0f b6 06             	movzbl (%esi),%eax
  800520:	83 c6 01             	add    $0x1,%esi
  800523:	83 f8 25             	cmp    $0x25,%eax
  800526:	75 e3                	jne    80050b <vprintfmt+0x11>
  800528:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80052c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800533:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800538:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80053f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800544:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800547:	eb 2b                	jmp    800574 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80054c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800550:	eb 22                	jmp    800574 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800555:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800559:	eb 19                	jmp    800574 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80055e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800565:	eb 0d                	jmp    800574 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800567:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80056a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80056d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	0f b6 06             	movzbl (%esi),%eax
  800577:	0f b6 d0             	movzbl %al,%edx
  80057a:	8d 7e 01             	lea    0x1(%esi),%edi
  80057d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800580:	83 e8 23             	sub    $0x23,%eax
  800583:	3c 55                	cmp    $0x55,%al
  800585:	0f 87 46 04 00 00    	ja     8009d1 <vprintfmt+0x4d7>
  80058b:	0f b6 c0             	movzbl %al,%eax
  80058e:	ff 24 85 a0 2c 80 00 	jmp    *0x802ca0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800595:	83 ea 30             	sub    $0x30,%edx
  800598:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80059b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80059f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8005a5:	83 fa 09             	cmp    $0x9,%edx
  8005a8:	77 4a                	ja     8005f4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ad:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005b0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005b3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005b7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005ba:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005bd:	83 fa 09             	cmp    $0x9,%edx
  8005c0:	76 eb                	jbe    8005ad <vprintfmt+0xb3>
  8005c2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8005c5:	eb 2d                	jmp    8005f4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d8:	eb 1a                	jmp    8005f4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8005dd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005e1:	79 91                	jns    800574 <vprintfmt+0x7a>
  8005e3:	e9 73 ff ff ff       	jmp    80055b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005eb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8005f2:	eb 80                	jmp    800574 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8005f4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005f8:	0f 89 76 ff ff ff    	jns    800574 <vprintfmt+0x7a>
  8005fe:	e9 64 ff ff ff       	jmp    800567 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800603:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800609:	e9 66 ff ff ff       	jmp    800574 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800626:	e9 f2 fe ff ff       	jmp    80051d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80062b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80062f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800632:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800636:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800639:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80063d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800640:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800643:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800647:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80064a:	80 f9 09             	cmp    $0x9,%cl
  80064d:	77 1d                	ja     80066c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80064f:	0f be c0             	movsbl %al,%eax
  800652:	6b c0 64             	imul   $0x64,%eax,%eax
  800655:	0f be d2             	movsbl %dl,%edx
  800658:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80065b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800662:	a3 04 40 80 00       	mov    %eax,0x804004
  800667:	e9 b1 fe ff ff       	jmp    80051d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80066c:	c7 44 24 04 63 2b 80 	movl   $0x802b63,0x4(%esp)
  800673:	00 
  800674:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	e8 0c 05 00 00       	call   800b8b <strcmp>
  80067f:	85 c0                	test   %eax,%eax
  800681:	75 0f                	jne    800692 <vprintfmt+0x198>
  800683:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  80068a:	00 00 00 
  80068d:	e9 8b fe ff ff       	jmp    80051d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800692:	c7 44 24 04 67 2b 80 	movl   $0x802b67,0x4(%esp)
  800699:	00 
  80069a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80069d:	89 14 24             	mov    %edx,(%esp)
  8006a0:	e8 e6 04 00 00       	call   800b8b <strcmp>
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	75 0f                	jne    8006b8 <vprintfmt+0x1be>
  8006a9:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  8006b0:	00 00 00 
  8006b3:	e9 65 fe ff ff       	jmp    80051d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8006b8:	c7 44 24 04 6b 2b 80 	movl   $0x802b6b,0x4(%esp)
  8006bf:	00 
  8006c0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8006c3:	89 0c 24             	mov    %ecx,(%esp)
  8006c6:	e8 c0 04 00 00       	call   800b8b <strcmp>
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	75 0f                	jne    8006de <vprintfmt+0x1e4>
  8006cf:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  8006d6:	00 00 00 
  8006d9:	e9 3f fe ff ff       	jmp    80051d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8006de:	c7 44 24 04 6f 2b 80 	movl   $0x802b6f,0x4(%esp)
  8006e5:	00 
  8006e6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8006e9:	89 3c 24             	mov    %edi,(%esp)
  8006ec:	e8 9a 04 00 00       	call   800b8b <strcmp>
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	75 0f                	jne    800704 <vprintfmt+0x20a>
  8006f5:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  8006fc:	00 00 00 
  8006ff:	e9 19 fe ff ff       	jmp    80051d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800704:	c7 44 24 04 73 2b 80 	movl   $0x802b73,0x4(%esp)
  80070b:	00 
  80070c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80070f:	89 04 24             	mov    %eax,(%esp)
  800712:	e8 74 04 00 00       	call   800b8b <strcmp>
  800717:	85 c0                	test   %eax,%eax
  800719:	75 0f                	jne    80072a <vprintfmt+0x230>
  80071b:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  800722:	00 00 00 
  800725:	e9 f3 fd ff ff       	jmp    80051d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80072a:	c7 44 24 04 77 2b 80 	movl   $0x802b77,0x4(%esp)
  800731:	00 
  800732:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800735:	89 14 24             	mov    %edx,(%esp)
  800738:	e8 4e 04 00 00       	call   800b8b <strcmp>
  80073d:	83 f8 01             	cmp    $0x1,%eax
  800740:	19 c0                	sbb    %eax,%eax
  800742:	f7 d0                	not    %eax
  800744:	83 c0 08             	add    $0x8,%eax
  800747:	a3 04 40 80 00       	mov    %eax,0x804004
  80074c:	e9 cc fd ff ff       	jmp    80051d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 50 04             	lea    0x4(%eax),%edx
  800757:	89 55 14             	mov    %edx,0x14(%ebp)
  80075a:	8b 00                	mov    (%eax),%eax
  80075c:	89 c2                	mov    %eax,%edx
  80075e:	c1 fa 1f             	sar    $0x1f,%edx
  800761:	31 d0                	xor    %edx,%eax
  800763:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800765:	83 f8 0f             	cmp    $0xf,%eax
  800768:	7f 0b                	jg     800775 <vprintfmt+0x27b>
  80076a:	8b 14 85 00 2e 80 00 	mov    0x802e00(,%eax,4),%edx
  800771:	85 d2                	test   %edx,%edx
  800773:	75 23                	jne    800798 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800775:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800779:	c7 44 24 08 7b 2b 80 	movl   $0x802b7b,0x8(%esp)
  800780:	00 
  800781:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800785:	8b 7d 08             	mov    0x8(%ebp),%edi
  800788:	89 3c 24             	mov    %edi,(%esp)
  80078b:	e8 42 fd ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800790:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800793:	e9 85 fd ff ff       	jmp    80051d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800798:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80079c:	c7 44 24 08 c1 30 80 	movl   $0x8030c1,0x8(%esp)
  8007a3:	00 
  8007a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ab:	89 3c 24             	mov    %edi,(%esp)
  8007ae:	e8 1f fd ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007b6:	e9 62 fd ff ff       	jmp    80051d <vprintfmt+0x23>
  8007bb:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8007be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007c1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007cf:	85 f6                	test   %esi,%esi
  8007d1:	b8 5c 2b 80 00       	mov    $0x802b5c,%eax
  8007d6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007d9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007dd:	7e 06                	jle    8007e5 <vprintfmt+0x2eb>
  8007df:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8007e3:	75 13                	jne    8007f8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e5:	0f be 06             	movsbl (%esi),%eax
  8007e8:	83 c6 01             	add    $0x1,%esi
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	0f 85 94 00 00 00    	jne    800887 <vprintfmt+0x38d>
  8007f3:	e9 81 00 00 00       	jmp    800879 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fc:	89 34 24             	mov    %esi,(%esp)
  8007ff:	e8 97 02 00 00       	call   800a9b <strnlen>
  800804:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800807:	29 c2                	sub    %eax,%edx
  800809:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80080c:	85 d2                	test   %edx,%edx
  80080e:	7e d5                	jle    8007e5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800810:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800814:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800817:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80081a:	89 d6                	mov    %edx,%esi
  80081c:	89 cf                	mov    %ecx,%edi
  80081e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800822:	89 3c 24             	mov    %edi,(%esp)
  800825:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800828:	83 ee 01             	sub    $0x1,%esi
  80082b:	75 f1                	jne    80081e <vprintfmt+0x324>
  80082d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800830:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800833:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800836:	eb ad                	jmp    8007e5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800838:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80083c:	74 1b                	je     800859 <vprintfmt+0x35f>
  80083e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800841:	83 fa 5e             	cmp    $0x5e,%edx
  800844:	76 13                	jbe    800859 <vprintfmt+0x35f>
					putch('?', putdat);
  800846:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800854:	ff 55 08             	call   *0x8(%ebp)
  800857:	eb 0d                	jmp    800866 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800859:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80085c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800866:	83 eb 01             	sub    $0x1,%ebx
  800869:	0f be 06             	movsbl (%esi),%eax
  80086c:	83 c6 01             	add    $0x1,%esi
  80086f:	85 c0                	test   %eax,%eax
  800871:	75 1a                	jne    80088d <vprintfmt+0x393>
  800873:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800876:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800879:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80087c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800880:	7f 1c                	jg     80089e <vprintfmt+0x3a4>
  800882:	e9 96 fc ff ff       	jmp    80051d <vprintfmt+0x23>
  800887:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80088a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088d:	85 ff                	test   %edi,%edi
  80088f:	78 a7                	js     800838 <vprintfmt+0x33e>
  800891:	83 ef 01             	sub    $0x1,%edi
  800894:	79 a2                	jns    800838 <vprintfmt+0x33e>
  800896:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800899:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80089c:	eb db                	jmp    800879 <vprintfmt+0x37f>
  80089e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a1:	89 de                	mov    %ebx,%esi
  8008a3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008aa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b3:	83 eb 01             	sub    $0x1,%ebx
  8008b6:	75 ee                	jne    8008a6 <vprintfmt+0x3ac>
  8008b8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008bd:	e9 5b fc ff ff       	jmp    80051d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c2:	83 f9 01             	cmp    $0x1,%ecx
  8008c5:	7e 10                	jle    8008d7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 08             	lea    0x8(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 30                	mov    (%eax),%esi
  8008d2:	8b 78 04             	mov    0x4(%eax),%edi
  8008d5:	eb 26                	jmp    8008fd <vprintfmt+0x403>
	else if (lflag)
  8008d7:	85 c9                	test   %ecx,%ecx
  8008d9:	74 12                	je     8008ed <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8008db:	8b 45 14             	mov    0x14(%ebp),%eax
  8008de:	8d 50 04             	lea    0x4(%eax),%edx
  8008e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e4:	8b 30                	mov    (%eax),%esi
  8008e6:	89 f7                	mov    %esi,%edi
  8008e8:	c1 ff 1f             	sar    $0x1f,%edi
  8008eb:	eb 10                	jmp    8008fd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8008ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f0:	8d 50 04             	lea    0x4(%eax),%edx
  8008f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f6:	8b 30                	mov    (%eax),%esi
  8008f8:	89 f7                	mov    %esi,%edi
  8008fa:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008fd:	85 ff                	test   %edi,%edi
  8008ff:	78 0e                	js     80090f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800901:	89 f0                	mov    %esi,%eax
  800903:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800905:	be 0a 00 00 00       	mov    $0xa,%esi
  80090a:	e9 84 00 00 00       	jmp    800993 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80090f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800913:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80091a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	89 fa                	mov    %edi,%edx
  800921:	f7 d8                	neg    %eax
  800923:	83 d2 00             	adc    $0x0,%edx
  800926:	f7 da                	neg    %edx
			}
			base = 10;
  800928:	be 0a 00 00 00       	mov    $0xa,%esi
  80092d:	eb 64                	jmp    800993 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80092f:	89 ca                	mov    %ecx,%edx
  800931:	8d 45 14             	lea    0x14(%ebp),%eax
  800934:	e8 42 fb ff ff       	call   80047b <getuint>
			base = 10;
  800939:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80093e:	eb 53                	jmp    800993 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800940:	89 ca                	mov    %ecx,%edx
  800942:	8d 45 14             	lea    0x14(%ebp),%eax
  800945:	e8 31 fb ff ff       	call   80047b <getuint>
    			base = 8;
  80094a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80094f:	eb 42                	jmp    800993 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800955:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80095c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80095f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800963:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80096a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80096d:	8b 45 14             	mov    0x14(%ebp),%eax
  800970:	8d 50 04             	lea    0x4(%eax),%edx
  800973:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800976:	8b 00                	mov    (%eax),%eax
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80097d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800982:	eb 0f                	jmp    800993 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800984:	89 ca                	mov    %ecx,%edx
  800986:	8d 45 14             	lea    0x14(%ebp),%eax
  800989:	e8 ed fa ff ff       	call   80047b <getuint>
			base = 16;
  80098e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800993:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800997:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80099b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80099e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8009a2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8009a6:	89 04 24             	mov    %eax,(%esp)
  8009a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ad:	89 da                	mov    %ebx,%edx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	e8 e9 f9 ff ff       	call   8003a0 <printnum>
			break;
  8009b7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009ba:	e9 5e fb ff ff       	jmp    80051d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c3:	89 14 24             	mov    %edx,(%esp)
  8009c6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009cc:	e9 4c fb ff ff       	jmp    80051d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009dc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009df:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009e3:	0f 84 34 fb ff ff    	je     80051d <vprintfmt+0x23>
  8009e9:	83 ee 01             	sub    $0x1,%esi
  8009ec:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009f0:	75 f7                	jne    8009e9 <vprintfmt+0x4ef>
  8009f2:	e9 26 fb ff ff       	jmp    80051d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009f7:	83 c4 5c             	add    $0x5c,%esp
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	83 ec 28             	sub    $0x28,%esp
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a0e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a12:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a1c:	85 c0                	test   %eax,%eax
  800a1e:	74 30                	je     800a50 <vsnprintf+0x51>
  800a20:	85 d2                	test   %edx,%edx
  800a22:	7e 2c                	jle    800a50 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a24:	8b 45 14             	mov    0x14(%ebp),%eax
  800a27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a32:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a39:	c7 04 24 b5 04 80 00 	movl   $0x8004b5,(%esp)
  800a40:	e8 b5 fa ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a48:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a4e:	eb 05                	jmp    800a55 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a5d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a64:	8b 45 10             	mov    0x10(%ebp),%eax
  800a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 82 ff ff ff       	call   8009ff <vsnprintf>
	va_end(ap);

	return rc;
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    
	...

00800a80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a8e:	74 09                	je     800a99 <strlen+0x19>
		n++;
  800a90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a97:	75 f7                	jne    800a90 <strlen+0x10>
		n++;
	return n;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaa:	85 c9                	test   %ecx,%ecx
  800aac:	74 1a                	je     800ac8 <strnlen+0x2d>
  800aae:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ab1:	74 15                	je     800ac8 <strnlen+0x2d>
  800ab3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ab8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aba:	39 ca                	cmp    %ecx,%edx
  800abc:	74 0a                	je     800ac8 <strnlen+0x2d>
  800abe:	83 c2 01             	add    $0x1,%edx
  800ac1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ac6:	75 f0                	jne    800ab8 <strnlen+0x1d>
		n++;
	return n;
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800ade:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ae1:	83 c2 01             	add    $0x1,%edx
  800ae4:	84 c9                	test   %cl,%cl
  800ae6:	75 f2                	jne    800ada <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af5:	89 1c 24             	mov    %ebx,(%esp)
  800af8:	e8 83 ff ff ff       	call   800a80 <strlen>
	strcpy(dst + len, src);
  800afd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b00:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b04:	01 d8                	add    %ebx,%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	e8 bd ff ff ff       	call   800acb <strcpy>
	return dst;
}
  800b0e:	89 d8                	mov    %ebx,%eax
  800b10:	83 c4 08             	add    $0x8,%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b24:	85 f6                	test   %esi,%esi
  800b26:	74 18                	je     800b40 <strncpy+0x2a>
  800b28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b2d:	0f b6 1a             	movzbl (%edx),%ebx
  800b30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b33:	80 3a 01             	cmpb   $0x1,(%edx)
  800b36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b39:	83 c1 01             	add    $0x1,%ecx
  800b3c:	39 f1                	cmp    %esi,%ecx
  800b3e:	75 ed                	jne    800b2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b50:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b53:	89 f8                	mov    %edi,%eax
  800b55:	85 f6                	test   %esi,%esi
  800b57:	74 2b                	je     800b84 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b59:	83 fe 01             	cmp    $0x1,%esi
  800b5c:	74 23                	je     800b81 <strlcpy+0x3d>
  800b5e:	0f b6 0b             	movzbl (%ebx),%ecx
  800b61:	84 c9                	test   %cl,%cl
  800b63:	74 1c                	je     800b81 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b65:	83 ee 02             	sub    $0x2,%esi
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b6d:	88 08                	mov    %cl,(%eax)
  800b6f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b72:	39 f2                	cmp    %esi,%edx
  800b74:	74 0b                	je     800b81 <strlcpy+0x3d>
  800b76:	83 c2 01             	add    $0x1,%edx
  800b79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b7d:	84 c9                	test   %cl,%cl
  800b7f:	75 ec                	jne    800b6d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800b81:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b84:	29 f8                	sub    %edi,%eax
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b94:	0f b6 01             	movzbl (%ecx),%eax
  800b97:	84 c0                	test   %al,%al
  800b99:	74 16                	je     800bb1 <strcmp+0x26>
  800b9b:	3a 02                	cmp    (%edx),%al
  800b9d:	75 12                	jne    800bb1 <strcmp+0x26>
		p++, q++;
  800b9f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ba2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ba6:	84 c0                	test   %al,%al
  800ba8:	74 07                	je     800bb1 <strcmp+0x26>
  800baa:	83 c1 01             	add    $0x1,%ecx
  800bad:	3a 02                	cmp    (%edx),%al
  800baf:	74 ee                	je     800b9f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb1:	0f b6 c0             	movzbl %al,%eax
  800bb4:	0f b6 12             	movzbl (%edx),%edx
  800bb7:	29 d0                	sub    %edx,%eax
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bcd:	85 d2                	test   %edx,%edx
  800bcf:	74 28                	je     800bf9 <strncmp+0x3e>
  800bd1:	0f b6 01             	movzbl (%ecx),%eax
  800bd4:	84 c0                	test   %al,%al
  800bd6:	74 24                	je     800bfc <strncmp+0x41>
  800bd8:	3a 03                	cmp    (%ebx),%al
  800bda:	75 20                	jne    800bfc <strncmp+0x41>
  800bdc:	83 ea 01             	sub    $0x1,%edx
  800bdf:	74 13                	je     800bf4 <strncmp+0x39>
		n--, p++, q++;
  800be1:	83 c1 01             	add    $0x1,%ecx
  800be4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800be7:	0f b6 01             	movzbl (%ecx),%eax
  800bea:	84 c0                	test   %al,%al
  800bec:	74 0e                	je     800bfc <strncmp+0x41>
  800bee:	3a 03                	cmp    (%ebx),%al
  800bf0:	74 ea                	je     800bdc <strncmp+0x21>
  800bf2:	eb 08                	jmp    800bfc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bfc:	0f b6 01             	movzbl (%ecx),%eax
  800bff:	0f b6 13             	movzbl (%ebx),%edx
  800c02:	29 d0                	sub    %edx,%eax
  800c04:	eb f3                	jmp    800bf9 <strncmp+0x3e>

00800c06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c10:	0f b6 10             	movzbl (%eax),%edx
  800c13:	84 d2                	test   %dl,%dl
  800c15:	74 1c                	je     800c33 <strchr+0x2d>
		if (*s == c)
  800c17:	38 ca                	cmp    %cl,%dl
  800c19:	75 09                	jne    800c24 <strchr+0x1e>
  800c1b:	eb 1b                	jmp    800c38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c1d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800c20:	38 ca                	cmp    %cl,%dl
  800c22:	74 14                	je     800c38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c24:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800c28:	84 d2                	test   %dl,%dl
  800c2a:	75 f1                	jne    800c1d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c31:	eb 05                	jmp    800c38 <strchr+0x32>
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c44:	0f b6 10             	movzbl (%eax),%edx
  800c47:	84 d2                	test   %dl,%dl
  800c49:	74 14                	je     800c5f <strfind+0x25>
		if (*s == c)
  800c4b:	38 ca                	cmp    %cl,%dl
  800c4d:	75 06                	jne    800c55 <strfind+0x1b>
  800c4f:	eb 0e                	jmp    800c5f <strfind+0x25>
  800c51:	38 ca                	cmp    %cl,%dl
  800c53:	74 0a                	je     800c5f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c55:	83 c0 01             	add    $0x1,%eax
  800c58:	0f b6 10             	movzbl (%eax),%edx
  800c5b:	84 d2                	test   %dl,%dl
  800c5d:	75 f2                	jne    800c51 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c79:	85 c9                	test   %ecx,%ecx
  800c7b:	74 30                	je     800cad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c83:	75 25                	jne    800caa <memset+0x49>
  800c85:	f6 c1 03             	test   $0x3,%cl
  800c88:	75 20                	jne    800caa <memset+0x49>
		c &= 0xFF;
  800c8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c8d:	89 d3                	mov    %edx,%ebx
  800c8f:	c1 e3 08             	shl    $0x8,%ebx
  800c92:	89 d6                	mov    %edx,%esi
  800c94:	c1 e6 18             	shl    $0x18,%esi
  800c97:	89 d0                	mov    %edx,%eax
  800c99:	c1 e0 10             	shl    $0x10,%eax
  800c9c:	09 f0                	or     %esi,%eax
  800c9e:	09 d0                	or     %edx,%eax
  800ca0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ca2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ca5:	fc                   	cld    
  800ca6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ca8:	eb 03                	jmp    800cad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800caa:	fc                   	cld    
  800cab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cad:	89 f8                	mov    %edi,%eax
  800caf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb8:	89 ec                	mov    %ebp,%esp
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 08             	sub    $0x8,%esp
  800cc2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cd1:	39 c6                	cmp    %eax,%esi
  800cd3:	73 36                	jae    800d0b <memmove+0x4f>
  800cd5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cd8:	39 d0                	cmp    %edx,%eax
  800cda:	73 2f                	jae    800d0b <memmove+0x4f>
		s += n;
		d += n;
  800cdc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cdf:	f6 c2 03             	test   $0x3,%dl
  800ce2:	75 1b                	jne    800cff <memmove+0x43>
  800ce4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cea:	75 13                	jne    800cff <memmove+0x43>
  800cec:	f6 c1 03             	test   $0x3,%cl
  800cef:	75 0e                	jne    800cff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cf1:	83 ef 04             	sub    $0x4,%edi
  800cf4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cf7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cfa:	fd                   	std    
  800cfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cfd:	eb 09                	jmp    800d08 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cff:	83 ef 01             	sub    $0x1,%edi
  800d02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d05:	fd                   	std    
  800d06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d08:	fc                   	cld    
  800d09:	eb 20                	jmp    800d2b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d11:	75 13                	jne    800d26 <memmove+0x6a>
  800d13:	a8 03                	test   $0x3,%al
  800d15:	75 0f                	jne    800d26 <memmove+0x6a>
  800d17:	f6 c1 03             	test   $0x3,%cl
  800d1a:	75 0a                	jne    800d26 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d1c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d1f:	89 c7                	mov    %eax,%edi
  800d21:	fc                   	cld    
  800d22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d24:	eb 05                	jmp    800d2b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d26:	89 c7                	mov    %eax,%edi
  800d28:	fc                   	cld    
  800d29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d31:	89 ec                	mov    %ebp,%esp
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	89 04 24             	mov    %eax,(%esp)
  800d4f:	e8 68 ff ff ff       	call   800cbc <memmove>
}
  800d54:	c9                   	leave  
  800d55:	c3                   	ret    

00800d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d62:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d65:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d6a:	85 ff                	test   %edi,%edi
  800d6c:	74 37                	je     800da5 <memcmp+0x4f>
		if (*s1 != *s2)
  800d6e:	0f b6 03             	movzbl (%ebx),%eax
  800d71:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d74:	83 ef 01             	sub    $0x1,%edi
  800d77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800d7c:	38 c8                	cmp    %cl,%al
  800d7e:	74 1c                	je     800d9c <memcmp+0x46>
  800d80:	eb 10                	jmp    800d92 <memcmp+0x3c>
  800d82:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d8e:	38 c8                	cmp    %cl,%al
  800d90:	74 0a                	je     800d9c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800d92:	0f b6 c0             	movzbl %al,%eax
  800d95:	0f b6 c9             	movzbl %cl,%ecx
  800d98:	29 c8                	sub    %ecx,%eax
  800d9a:	eb 09                	jmp    800da5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d9c:	39 fa                	cmp    %edi,%edx
  800d9e:	75 e2                	jne    800d82 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800da0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800db5:	39 d0                	cmp    %edx,%eax
  800db7:	73 19                	jae    800dd2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800dbd:	38 08                	cmp    %cl,(%eax)
  800dbf:	75 06                	jne    800dc7 <memfind+0x1d>
  800dc1:	eb 0f                	jmp    800dd2 <memfind+0x28>
  800dc3:	38 08                	cmp    %cl,(%eax)
  800dc5:	74 0b                	je     800dd2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dc7:	83 c0 01             	add    $0x1,%eax
  800dca:	39 d0                	cmp    %edx,%eax
  800dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	75 f1                	jne    800dc3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800de0:	0f b6 02             	movzbl (%edx),%eax
  800de3:	3c 20                	cmp    $0x20,%al
  800de5:	74 04                	je     800deb <strtol+0x17>
  800de7:	3c 09                	cmp    $0x9,%al
  800de9:	75 0e                	jne    800df9 <strtol+0x25>
		s++;
  800deb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dee:	0f b6 02             	movzbl (%edx),%eax
  800df1:	3c 20                	cmp    $0x20,%al
  800df3:	74 f6                	je     800deb <strtol+0x17>
  800df5:	3c 09                	cmp    $0x9,%al
  800df7:	74 f2                	je     800deb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800df9:	3c 2b                	cmp    $0x2b,%al
  800dfb:	75 0a                	jne    800e07 <strtol+0x33>
		s++;
  800dfd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e00:	bf 00 00 00 00       	mov    $0x0,%edi
  800e05:	eb 10                	jmp    800e17 <strtol+0x43>
  800e07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e0c:	3c 2d                	cmp    $0x2d,%al
  800e0e:	75 07                	jne    800e17 <strtol+0x43>
		s++, neg = 1;
  800e10:	83 c2 01             	add    $0x1,%edx
  800e13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e17:	85 db                	test   %ebx,%ebx
  800e19:	0f 94 c0             	sete   %al
  800e1c:	74 05                	je     800e23 <strtol+0x4f>
  800e1e:	83 fb 10             	cmp    $0x10,%ebx
  800e21:	75 15                	jne    800e38 <strtol+0x64>
  800e23:	80 3a 30             	cmpb   $0x30,(%edx)
  800e26:	75 10                	jne    800e38 <strtol+0x64>
  800e28:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e2c:	75 0a                	jne    800e38 <strtol+0x64>
		s += 2, base = 16;
  800e2e:	83 c2 02             	add    $0x2,%edx
  800e31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e36:	eb 13                	jmp    800e4b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e38:	84 c0                	test   %al,%al
  800e3a:	74 0f                	je     800e4b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e41:	80 3a 30             	cmpb   $0x30,(%edx)
  800e44:	75 05                	jne    800e4b <strtol+0x77>
		s++, base = 8;
  800e46:	83 c2 01             	add    $0x1,%edx
  800e49:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e52:	0f b6 0a             	movzbl (%edx),%ecx
  800e55:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e58:	80 fb 09             	cmp    $0x9,%bl
  800e5b:	77 08                	ja     800e65 <strtol+0x91>
			dig = *s - '0';
  800e5d:	0f be c9             	movsbl %cl,%ecx
  800e60:	83 e9 30             	sub    $0x30,%ecx
  800e63:	eb 1e                	jmp    800e83 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800e65:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e68:	80 fb 19             	cmp    $0x19,%bl
  800e6b:	77 08                	ja     800e75 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800e6d:	0f be c9             	movsbl %cl,%ecx
  800e70:	83 e9 57             	sub    $0x57,%ecx
  800e73:	eb 0e                	jmp    800e83 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800e75:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e78:	80 fb 19             	cmp    $0x19,%bl
  800e7b:	77 14                	ja     800e91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e7d:	0f be c9             	movsbl %cl,%ecx
  800e80:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e83:	39 f1                	cmp    %esi,%ecx
  800e85:	7d 0e                	jge    800e95 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e87:	83 c2 01             	add    $0x1,%edx
  800e8a:	0f af c6             	imul   %esi,%eax
  800e8d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e8f:	eb c1                	jmp    800e52 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e91:	89 c1                	mov    %eax,%ecx
  800e93:	eb 02                	jmp    800e97 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e95:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e9b:	74 05                	je     800ea2 <strtol+0xce>
		*endptr = (char *) s;
  800e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ea2:	89 ca                	mov    %ecx,%edx
  800ea4:	f7 da                	neg    %edx
  800ea6:	85 ff                	test   %edi,%edi
  800ea8:	0f 45 c2             	cmovne %edx,%eax
}
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	89 c7                	mov    %eax,%edi
  800ece:	89 c6                	mov    %eax,%esi
  800ed0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ed2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800edb:	89 ec                	mov    %ebp,%esp
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_cgetc>:

int
sys_cgetc(void)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eeb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 d3                	mov    %edx,%ebx
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	89 d6                	mov    %edx,%esi
  800f00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0b:	89 ec                	mov    %ebp,%esp
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 38             	sub    $0x38,%esp
  800f15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f23:	b8 03 00 00 00       	mov    $0x3,%eax
  800f28:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2b:	89 cb                	mov    %ecx,%ebx
  800f2d:	89 cf                	mov    %ecx,%edi
  800f2f:	89 ce                	mov    %ecx,%esi
  800f31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f33:	85 c0                	test   %eax,%eax
  800f35:	7e 28                	jle    800f5f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f42:	00 
  800f43:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f52:	00 
  800f53:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  800f5a:	e8 29 f3 ff ff       	call   800288 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800f80:	b8 02 00 00 00       	mov    $0x2,%eax
  800f85:	89 d1                	mov    %edx,%ecx
  800f87:	89 d3                	mov    %edx,%ebx
  800f89:	89 d7                	mov    %edx,%edi
  800f8b:	89 d6                	mov    %edx,%esi
  800f8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f98:	89 ec                	mov    %ebp,%esp
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_yield>:

void
sys_yield(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 d3                	mov    %edx,%ebx
  800fb9:	89 d7                	mov    %edx,%edi
  800fbb:	89 d6                	mov    %edx,%esi
  800fbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc8:	89 ec                	mov    %ebp,%esp
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 38             	sub    $0x38,%esp
  800fd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdb:	be 00 00 00 00       	mov    $0x0,%esi
  800fe0:	b8 04 00 00 00       	mov    $0x4,%eax
  800fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	89 f7                	mov    %esi,%edi
  800ff0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	7e 28                	jle    80101e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  801019:	e8 6a f2 ff ff       	call   800288 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80101e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801021:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801024:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801027:	89 ec                	mov    %ebp,%esp
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 38             	sub    $0x38,%esp
  801031:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801034:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801037:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	b8 05 00 00 00       	mov    $0x5,%eax
  80103f:	8b 75 18             	mov    0x18(%ebp),%esi
  801042:	8b 7d 14             	mov    0x14(%ebp),%edi
  801045:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801050:	85 c0                	test   %eax,%eax
  801052:	7e 28                	jle    80107c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801054:	89 44 24 10          	mov    %eax,0x10(%esp)
  801058:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80105f:	00 
  801060:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801067:	00 
  801068:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106f:	00 
  801070:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  801077:	e8 0c f2 ff ff       	call   800288 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80107c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801082:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801085:	89 ec                	mov    %ebp,%esp
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 38             	sub    $0x38,%esp
  80108f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801092:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801095:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801098:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109d:	b8 06 00 00 00       	mov    $0x6,%eax
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	89 df                	mov    %ebx,%edi
  8010aa:	89 de                	mov    %ebx,%esi
  8010ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	7e 28                	jle    8010da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010bd:	00 
  8010be:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  8010d5:	e8 ae f1 ff ff       	call   800288 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e3:	89 ec                	mov    %ebp,%esp
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  8010f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801100:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
  801106:	89 df                	mov    %ebx,%edi
  801108:	89 de                	mov    %ebx,%esi
  80110a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110c:	85 c0                	test   %eax,%eax
  80110e:	7e 28                	jle    801138 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801110:	89 44 24 10          	mov    %eax,0x10(%esp)
  801114:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80111b:	00 
  80111c:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801123:	00 
  801124:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112b:	00 
  80112c:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  801133:	e8 50 f1 ff ff       	call   800288 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801138:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80113b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801141:	89 ec                	mov    %ebp,%esp
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 38             	sub    $0x38,%esp
  80114b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80114e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801151:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801154:	bb 00 00 00 00       	mov    $0x0,%ebx
  801159:	b8 09 00 00 00       	mov    $0x9,%eax
  80115e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801161:	8b 55 08             	mov    0x8(%ebp),%edx
  801164:	89 df                	mov    %ebx,%edi
  801166:	89 de                	mov    %ebx,%esi
  801168:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80116a:	85 c0                	test   %eax,%eax
  80116c:	7e 28                	jle    801196 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801172:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801179:	00 
  80117a:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801181:	00 
  801182:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801189:	00 
  80118a:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  801191:	e8 f2 f0 ff ff       	call   800288 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801196:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801199:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80119c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80119f:	89 ec                	mov    %ebp,%esp
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	83 ec 38             	sub    $0x38,%esp
  8011a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c2:	89 df                	mov    %ebx,%edi
  8011c4:	89 de                	mov    %ebx,%esi
  8011c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	7e 28                	jle    8011f4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  8011df:	00 
  8011e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011e7:	00 
  8011e8:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  8011ef:	e8 94 f0 ff ff       	call   800288 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011fd:	89 ec                	mov    %ebp,%esp
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80120a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80120d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801210:	be 00 00 00 00       	mov    $0x0,%esi
  801215:	b8 0c 00 00 00       	mov    $0xc,%eax
  80121a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80121d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	8b 55 08             	mov    0x8(%ebp),%edx
  801226:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801228:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80122b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80122e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801231:	89 ec                	mov    %ebp,%esp
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	83 ec 38             	sub    $0x38,%esp
  80123b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80123e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801241:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801244:	b9 00 00 00 00       	mov    $0x0,%ecx
  801249:	b8 0d 00 00 00       	mov    $0xd,%eax
  80124e:	8b 55 08             	mov    0x8(%ebp),%edx
  801251:	89 cb                	mov    %ecx,%ebx
  801253:	89 cf                	mov    %ecx,%edi
  801255:	89 ce                	mov    %ecx,%esi
  801257:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801259:	85 c0                	test   %eax,%eax
  80125b:	7e 28                	jle    801285 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801261:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801268:	00 
  801269:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801270:	00 
  801271:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801278:	00 
  801279:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  801280:	e8 03 f0 ff ff       	call   800288 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801285:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801288:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80128b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80128e:	89 ec                	mov    %ebp,%esp
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 0c             	sub    $0xc,%esp
  801298:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80129b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80129e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ae:	89 cb                	mov    %ecx,%ebx
  8012b0:	89 cf                	mov    %ecx,%edi
  8012b2:	89 ce                	mov    %ecx,%esi
  8012b4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8012b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012bf:	89 ec                	mov    %ebp,%esp
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    
	...

008012c4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 24             	sub    $0x24,%esp
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8012ce:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  8012d0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8012d4:	75 1c                	jne    8012f2 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  8012d6:	c7 44 24 08 8a 2e 80 	movl   $0x802e8a,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8012e5:	00 
  8012e6:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8012ed:	e8 96 ef ff ff       	call   800288 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  8012f2:	89 d8                	mov    %ebx,%eax
  8012f4:	c1 e8 0c             	shr    $0xc,%eax
  8012f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fe:	f6 c4 08             	test   $0x8,%ah
  801301:	0f 84 be 00 00 00    	je     8013c5 <pgfault+0x101>
  801307:	89 d8                	mov    %ebx,%eax
  801309:	c1 e8 16             	shr    $0x16,%eax
  80130c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801313:	a8 01                	test   $0x1,%al
  801315:	0f 84 aa 00 00 00    	je     8013c5 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  80131b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801322:	00 
  801323:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80132a:	00 
  80132b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801332:	e8 95 fc ff ff       	call   800fcc <sys_page_alloc>
		if (r < 0)
  801337:	85 c0                	test   %eax,%eax
  801339:	79 20                	jns    80135b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80133b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133f:	c7 44 24 08 c4 2e 80 	movl   $0x802ec4,0x8(%esp)
  801346:	00 
  801347:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  801356:	e8 2d ef ff ff       	call   800288 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80135b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801361:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801368:	00 
  801369:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80136d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801374:	e8 bc f9 ff ff       	call   800d35 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801379:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801380:	00 
  801381:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801385:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80138c:	00 
  80138d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801394:	00 
  801395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80139c:	e8 8a fc ff ff       	call   80102b <sys_page_map>
		if (r < 0)
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	79 3c                	jns    8013e1 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  8013a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a9:	c7 44 24 08 ec 2e 80 	movl   $0x802eec,0x8(%esp)
  8013b0:	00 
  8013b1:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8013b8:	00 
  8013b9:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8013c0:	e8 c3 ee ff ff       	call   800288 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  8013c5:	c7 44 24 08 10 2f 80 	movl   $0x802f10,0x8(%esp)
  8013cc:	00 
  8013cd:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8013d4:	00 
  8013d5:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8013dc:	e8 a7 ee ff ff       	call   800288 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  8013e1:	83 c4 24             	add    $0x24,%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	57                   	push   %edi
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8013f0:	c7 04 24 c4 12 80 00 	movl   $0x8012c4,(%esp)
  8013f7:	e8 24 11 00 00       	call   802520 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8013fc:	bf 07 00 00 00       	mov    $0x7,%edi
  801401:	89 f8                	mov    %edi,%eax
  801403:	cd 30                	int    $0x30
  801405:	89 c7                	mov    %eax,%edi
  801407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80140a:	85 c0                	test   %eax,%eax
  80140c:	79 20                	jns    80142e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80140e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801412:	c7 44 24 08 30 2f 80 	movl   $0x802f30,0x8(%esp)
  801419:	00 
  80141a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801421:	00 
  801422:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  801429:	e8 5a ee ff ff       	call   800288 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80142e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801433:	85 c0                	test   %eax,%eax
  801435:	75 1c                	jne    801453 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801437:	e8 30 fb ff ff       	call   800f6c <sys_getenvid>
  80143c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801441:	c1 e0 07             	shl    $0x7,%eax
  801444:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801449:	a3 20 54 80 00       	mov    %eax,0x805420
		//cprintf("child fork ok!\n");
		return 0;
  80144e:	e9 51 02 00 00       	jmp    8016a4 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801453:	89 d8                	mov    %ebx,%eax
  801455:	c1 e8 16             	shr    $0x16,%eax
  801458:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80145f:	a8 01                	test   $0x1,%al
  801461:	0f 84 87 01 00 00    	je     8015ee <fork+0x207>
  801467:	89 d8                	mov    %ebx,%eax
  801469:	c1 e8 0c             	shr    $0xc,%eax
  80146c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801473:	f6 c2 01             	test   $0x1,%dl
  801476:	0f 84 72 01 00 00    	je     8015ee <fork+0x207>
  80147c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801483:	f6 c2 04             	test   $0x4,%dl
  801486:	0f 84 62 01 00 00    	je     8015ee <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80148c:	89 c6                	mov    %eax,%esi
  80148e:	c1 e6 0c             	shl    $0xc,%esi
  801491:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801497:	0f 84 51 01 00 00    	je     8015ee <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  80149d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a4:	f6 c6 04             	test   $0x4,%dh
  8014a7:	74 53                	je     8014fc <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8014a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014cf:	e8 57 fb ff ff       	call   80102b <sys_page_map>
		if (r < 0)
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	0f 89 12 01 00 00    	jns    8015ee <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  8014dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e0:	c7 44 24 08 50 2f 80 	movl   $0x802f50,0x8(%esp)
  8014e7:	00 
  8014e8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8014ef:	00 
  8014f0:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8014f7:	e8 8c ed ff ff       	call   800288 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  8014fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801503:	f6 c2 02             	test   $0x2,%dl
  801506:	75 10                	jne    801518 <fork+0x131>
  801508:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150f:	f6 c4 08             	test   $0x8,%ah
  801512:	0f 84 8f 00 00 00    	je     8015a7 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801518:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80151f:	00 
  801520:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801524:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801527:	89 44 24 08          	mov    %eax,0x8(%esp)
  80152b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80152f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801536:	e8 f0 fa ff ff       	call   80102b <sys_page_map>
		if (r < 0)
  80153b:	85 c0                	test   %eax,%eax
  80153d:	79 20                	jns    80155f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80153f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801543:	c7 44 24 08 7c 2f 80 	movl   $0x802f7c,0x8(%esp)
  80154a:	00 
  80154b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801552:	00 
  801553:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80155a:	e8 29 ed ff ff       	call   800288 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80155f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801566:	00 
  801567:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80156b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801572:	00 
  801573:	89 74 24 04          	mov    %esi,0x4(%esp)
  801577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157e:	e8 a8 fa ff ff       	call   80102b <sys_page_map>
		if (r < 0)
  801583:	85 c0                	test   %eax,%eax
  801585:	79 67                	jns    8015ee <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801587:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80158b:	c7 44 24 08 7c 2f 80 	movl   $0x802f7c,0x8(%esp)
  801592:	00 
  801593:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80159a:	00 
  80159b:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8015a2:	e8 e1 ec ff ff       	call   800288 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  8015a7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8015ae:	00 
  8015af:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c5:	e8 61 fa ff ff       	call   80102b <sys_page_map>
		if (r < 0)
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	79 20                	jns    8015ee <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8015ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d2:	c7 44 24 08 7c 2f 80 	movl   $0x802f7c,0x8(%esp)
  8015d9:	00 
  8015da:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8015e1:	00 
  8015e2:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8015e9:	e8 9a ec ff ff       	call   800288 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  8015ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015f4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8015fa:	0f 85 53 fe ff ff    	jne    801453 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801600:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801607:	00 
  801608:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80160f:	ee 
  801610:	89 3c 24             	mov    %edi,(%esp)
  801613:	e8 b4 f9 ff ff       	call   800fcc <sys_page_alloc>
	if (res < 0)
  801618:	85 c0                	test   %eax,%eax
  80161a:	79 20                	jns    80163c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  80161c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801620:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  801627:	00 
  801628:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80162f:	00 
  801630:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  801637:	e8 4c ec ff ff       	call   800288 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80163c:	c7 44 24 04 ac 25 80 	movl   $0x8025ac,0x4(%esp)
  801643:	00 
  801644:	89 3c 24             	mov    %edi,(%esp)
  801647:	e8 57 fb ff ff       	call   8011a3 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80164c:	85 c0                	test   %eax,%eax
  80164e:	79 20                	jns    801670 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801650:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801654:	c7 44 24 08 c4 2f 80 	movl   $0x802fc4,0x8(%esp)
  80165b:	00 
  80165c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801663:	00 
  801664:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80166b:	e8 18 ec ff ff       	call   800288 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801670:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801677:	00 
  801678:	89 3c 24             	mov    %edi,(%esp)
  80167b:	e8 67 fa ff ff       	call   8010e7 <sys_env_set_status>
	if (res < 0)
  801680:	85 c0                	test   %eax,%eax
  801682:	79 20                	jns    8016a4 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801684:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801688:	c7 44 24 08 f4 2f 80 	movl   $0x802ff4,0x8(%esp)
  80168f:	00 
  801690:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801697:	00 
  801698:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80169f:	e8 e4 eb ff ff       	call   800288 <_panic>

	return pid;
	//panic("fork not implemented");
}
  8016a4:	89 f8                	mov    %edi,%eax
  8016a6:	83 c4 3c             	add    $0x3c,%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5f                   	pop    %edi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <sfork>:

// Challenge!
int
sfork(void)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016b4:	c7 44 24 08 ac 2e 80 	movl   $0x802eac,0x8(%esp)
  8016bb:	00 
  8016bc:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8016c3:	00 
  8016c4:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8016cb:	e8 b8 eb ff ff       	call   800288 <_panic>

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
  8017d1:	39 0d 08 40 80 00    	cmp    %ecx,0x804008
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
  8017e2:	ba 08 40 80 00       	mov    $0x804008,%edx
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
  8017f3:	8b 14 85 98 30 80 00 	mov    0x803098(,%eax,4),%edx
  8017fa:	85 d2                	test   %edx,%edx
  8017fc:	75 dd                	jne    8017db <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017fe:	a1 20 54 80 00       	mov    0x805420,%eax
  801803:	8b 40 48             	mov    0x48(%eax),%eax
  801806:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80180a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180e:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  801815:	e8 69 eb ff ff       	call   800383 <cprintf>
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
  8018a9:	e8 db f7 ff ff       	call   801089 <sys_page_unmap>
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
  8019b2:	e8 74 f6 ff ff       	call   80102b <sys_page_map>
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
  8019ed:	e8 39 f6 ff ff       	call   80102b <sys_page_map>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	79 25                	jns    801a1d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a03:	e8 81 f6 ff ff       	call   801089 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a16:	e8 6e f6 ff ff       	call   801089 <sys_page_unmap>
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
  801a71:	a1 20 54 80 00       	mov    0x805420,%eax
  801a76:	8b 40 48             	mov    0x48(%eax),%eax
  801a79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a81:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  801a88:	e8 f6 e8 ff ff       	call   800383 <cprintf>
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
  801b4c:	a1 20 54 80 00       	mov    0x805420,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
  801b54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	c7 04 24 79 30 80 00 	movl   $0x803079,(%esp)
  801b63:	e8 1b e8 ff ff       	call   800383 <cprintf>
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
  801c03:	a1 20 54 80 00       	mov    0x805420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c08:	8b 40 48             	mov    0x48(%eax),%eax
  801c0b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c13:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  801c1a:	e8 64 e7 ff ff       	call   800383 <cprintf>
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
  801d20:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d27:	75 11                	jne    801d3a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d30:	e8 6c 09 00 00       	call   8026a1 <ipc_find_env>
  801d35:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d3a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d41:	00 
  801d42:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d49:	00 
  801d4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4e:	a1 00 50 80 00       	mov    0x805000,%eax
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 db 08 00 00       	call   802636 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801d5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d62:	00 
  801d63:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6e:	e8 5d 08 00 00       	call   8025d0 <ipc_recv>
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
  801d8d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d92:	ba 00 00 00 00       	mov    $0x0,%edx
  801d97:	b8 05 00 00 00       	mov    $0x5,%eax
  801d9c:	e8 6f ff ff ff       	call   801d10 <fsipc>
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 2b                	js     801dd0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801da5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801dac:	00 
  801dad:	89 1c 24             	mov    %ebx,(%esp)
  801db0:	e8 16 ed ff ff       	call   800acb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801db5:	a1 80 60 80 00       	mov    0x806080,%eax
  801dba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801dc0:	a1 84 60 80 00       	mov    0x806084,%eax
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
  801de2:	a3 00 60 80 00       	mov    %eax,0x806000
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
  801e09:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e0e:	89 35 04 60 80 00    	mov    %esi,0x806004
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
  801e2d:	c7 44 24 0c a8 30 80 	movl   $0x8030a8,0xc(%esp)
  801e34:	00 
  801e35:	c7 44 24 08 af 30 80 	movl   $0x8030af,0x8(%esp)
  801e3c:	00 
  801e3d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801e44:	00 
  801e45:	c7 04 24 c4 30 80 00 	movl   $0x8030c4,(%esp)
  801e4c:	e8 37 e4 ff ff       	call   800288 <_panic>
	assert(r <= PGSIZE);
  801e51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e56:	7e 24                	jle    801e7c <devfile_read+0x84>
  801e58:	c7 44 24 0c cf 30 80 	movl   $0x8030cf,0xc(%esp)
  801e5f:	00 
  801e60:	c7 44 24 08 af 30 80 	movl   $0x8030af,0x8(%esp)
  801e67:	00 
  801e68:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e6f:	00 
  801e70:	c7 04 24 c4 30 80 00 	movl   $0x8030c4,(%esp)
  801e77:	e8 0c e4 ff ff       	call   800288 <_panic>
	memmove(buf, &fsipcbuf, r);
  801e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e80:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e87:	00 
  801e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8b:	89 04 24             	mov    %eax,(%esp)
  801e8e:	e8 29 ee ff ff       	call   800cbc <memmove>
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
  801eaa:	e8 d1 eb ff ff       	call   800a80 <strlen>
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
  801ed0:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ed7:	e8 ef eb ff ff       	call   800acb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edf:	a3 00 64 80 00       	mov    %eax,0x806400

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
  801f4c:	c7 44 24 04 db 30 80 	movl   $0x8030db,0x4(%esp)
  801f53:	00 
  801f54:	89 34 24             	mov    %esi,(%esp)
  801f57:	e8 6f eb ff ff       	call   800acb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f5c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f5f:	2b 03                	sub    (%ebx),%eax
  801f61:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f67:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f6e:	00 00 00 
	stat->st_dev = &devpipe;
  801f71:	c7 86 88 00 00 00 24 	movl   $0x804024,0x88(%esi)
  801f78:	40 80 00 
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
  801f9f:	e8 e5 f0 ff ff       	call   801089 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fa4:	89 1c 24             	mov    %ebx,(%esp)
  801fa7:	e8 34 f7 ff ff       	call   8016e0 <fd2data>
  801fac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb7:	e8 cd f0 ff ff       	call   801089 <sys_page_unmap>
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
  801fd0:	a1 20 54 80 00       	mov    0x805420,%eax
  801fd5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fd8:	89 3c 24             	mov    %edi,(%esp)
  801fdb:	e8 0c 07 00 00       	call   8026ec <pageref>
  801fe0:	89 c6                	mov    %eax,%esi
  801fe2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 ff 06 00 00       	call   8026ec <pageref>
  801fed:	39 c6                	cmp    %eax,%esi
  801fef:	0f 94 c0             	sete   %al
  801ff2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ff5:	8b 15 20 54 80 00    	mov    0x805420,%edx
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
  80201e:	c7 04 24 e2 30 80 00 	movl   $0x8030e2,(%esp)
  802025:	e8 59 e3 ff ff       	call   800383 <cprintf>
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
  80205c:	e8 3b ef ff ff       	call   800f9c <sys_yield>
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
  8020f9:	e8 9e ee ff ff       	call   800f9c <sys_yield>
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
  802191:	e8 36 ee ff ff       	call   800fcc <sys_page_alloc>
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
  8021cb:	e8 fc ed ff ff       	call   800fcc <sys_page_alloc>
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
  8021fa:	e8 cd ed ff ff       	call   800fcc <sys_page_alloc>
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
  802233:	e8 f3 ed ff ff       	call   80102b <sys_page_map>
  802238:	89 c3                	mov    %eax,%ebx
  80223a:	85 c0                	test   %eax,%eax
  80223c:	78 4c                	js     80228a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80223e:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802247:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80224c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802253:	8b 15 24 40 80 00    	mov    0x804024,%edx
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
  802295:	e8 ef ed ff ff       	call   801089 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80229a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80229d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a8:	e8 dc ed ff ff       	call   801089 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022bb:	e8 c9 ed ff ff       	call   801089 <sys_page_unmap>
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

00802304 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	56                   	push   %esi
  802308:	53                   	push   %ebx
  802309:	83 ec 10             	sub    $0x10,%esp
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  80230f:	85 c0                	test   %eax,%eax
  802311:	75 24                	jne    802337 <wait+0x33>
  802313:	c7 44 24 0c fa 30 80 	movl   $0x8030fa,0xc(%esp)
  80231a:	00 
  80231b:	c7 44 24 08 af 30 80 	movl   $0x8030af,0x8(%esp)
  802322:	00 
  802323:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80232a:	00 
  80232b:	c7 04 24 05 31 80 00 	movl   $0x803105,(%esp)
  802332:	e8 51 df ff ff       	call   800288 <_panic>
	e = &envs[ENVX(envid)];
  802337:	89 c3                	mov    %eax,%ebx
  802339:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80233f:	c1 e3 07             	shl    $0x7,%ebx
  802342:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802348:	8b 73 48             	mov    0x48(%ebx),%esi
  80234b:	39 c6                	cmp    %eax,%esi
  80234d:	75 1a                	jne    802369 <wait+0x65>
  80234f:	8b 43 54             	mov    0x54(%ebx),%eax
  802352:	85 c0                	test   %eax,%eax
  802354:	74 13                	je     802369 <wait+0x65>
		sys_yield();
  802356:	e8 41 ec ff ff       	call   800f9c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80235b:	8b 43 48             	mov    0x48(%ebx),%eax
  80235e:	39 f0                	cmp    %esi,%eax
  802360:	75 07                	jne    802369 <wait+0x65>
  802362:	8b 43 54             	mov    0x54(%ebx),%eax
  802365:	85 c0                	test   %eax,%eax
  802367:	75 ed                	jne    802356 <wait+0x52>
		sys_yield();
}
  802369:	83 c4 10             	add    $0x10,%esp
  80236c:	5b                   	pop    %ebx
  80236d:	5e                   	pop    %esi
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    

00802370 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802373:	b8 00 00 00 00       	mov    $0x0,%eax
  802378:	5d                   	pop    %ebp
  802379:	c3                   	ret    

0080237a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802380:	c7 44 24 04 10 31 80 	movl   $0x803110,0x4(%esp)
  802387:	00 
  802388:	8b 45 0c             	mov    0xc(%ebp),%eax
  80238b:	89 04 24             	mov    %eax,(%esp)
  80238e:	e8 38 e7 ff ff       	call   800acb <strcpy>
	return 0;
}
  802393:	b8 00 00 00 00       	mov    $0x0,%eax
  802398:	c9                   	leave  
  802399:	c3                   	ret    

0080239a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	57                   	push   %edi
  80239e:	56                   	push   %esi
  80239f:	53                   	push   %ebx
  8023a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023a6:	be 00 00 00 00       	mov    $0x0,%esi
  8023ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023af:	74 43                	je     8023f4 <devcons_write+0x5a>
  8023b1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023b6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023bf:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8023c1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023c4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023c9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d0:	03 45 0c             	add    0xc(%ebp),%eax
  8023d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d7:	89 3c 24             	mov    %edi,(%esp)
  8023da:	e8 dd e8 ff ff       	call   800cbc <memmove>
		sys_cputs(buf, m);
  8023df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023e3:	89 3c 24             	mov    %edi,(%esp)
  8023e6:	e8 c5 ea ff ff       	call   800eb0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023eb:	01 de                	add    %ebx,%esi
  8023ed:	89 f0                	mov    %esi,%eax
  8023ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023f2:	72 c8                	jb     8023bc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023f4:	89 f0                	mov    %esi,%eax
  8023f6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8023fc:	5b                   	pop    %ebx
  8023fd:	5e                   	pop    %esi
  8023fe:	5f                   	pop    %edi
  8023ff:	5d                   	pop    %ebp
  802400:	c3                   	ret    

00802401 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802401:	55                   	push   %ebp
  802402:	89 e5                	mov    %esp,%ebp
  802404:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802407:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80240c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802410:	75 07                	jne    802419 <devcons_read+0x18>
  802412:	eb 31                	jmp    802445 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802414:	e8 83 eb ff ff       	call   800f9c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	e8 ba ea ff ff       	call   800edf <sys_cgetc>
  802425:	85 c0                	test   %eax,%eax
  802427:	74 eb                	je     802414 <devcons_read+0x13>
  802429:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80242b:	85 c0                	test   %eax,%eax
  80242d:	78 16                	js     802445 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80242f:	83 f8 04             	cmp    $0x4,%eax
  802432:	74 0c                	je     802440 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802434:	8b 45 0c             	mov    0xc(%ebp),%eax
  802437:	88 10                	mov    %dl,(%eax)
	return 1;
  802439:	b8 01 00 00 00       	mov    $0x1,%eax
  80243e:	eb 05                	jmp    802445 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802440:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802445:	c9                   	leave  
  802446:	c3                   	ret    

00802447 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802447:	55                   	push   %ebp
  802448:	89 e5                	mov    %esp,%ebp
  80244a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80244d:	8b 45 08             	mov    0x8(%ebp),%eax
  802450:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802453:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80245a:	00 
  80245b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80245e:	89 04 24             	mov    %eax,(%esp)
  802461:	e8 4a ea ff ff       	call   800eb0 <sys_cputs>
}
  802466:	c9                   	leave  
  802467:	c3                   	ret    

00802468 <getchar>:

int
getchar(void)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80246e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802475:	00 
  802476:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802484:	e8 a5 f5 ff ff       	call   801a2e <read>
	if (r < 0)
  802489:	85 c0                	test   %eax,%eax
  80248b:	78 0f                	js     80249c <getchar+0x34>
		return r;
	if (r < 1)
  80248d:	85 c0                	test   %eax,%eax
  80248f:	7e 06                	jle    802497 <getchar+0x2f>
		return -E_EOF;
	return c;
  802491:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802495:	eb 05                	jmp    80249c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802497:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80249c:	c9                   	leave  
  80249d:	c3                   	ret    

0080249e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80249e:	55                   	push   %ebp
  80249f:	89 e5                	mov    %esp,%ebp
  8024a1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ae:	89 04 24             	mov    %eax,(%esp)
  8024b1:	e8 b8 f2 ff ff       	call   80176e <fd_lookup>
  8024b6:	85 c0                	test   %eax,%eax
  8024b8:	78 11                	js     8024cb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bd:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8024c3:	39 10                	cmp    %edx,(%eax)
  8024c5:	0f 94 c0             	sete   %al
  8024c8:	0f b6 c0             	movzbl %al,%eax
}
  8024cb:	c9                   	leave  
  8024cc:	c3                   	ret    

008024cd <opencons>:

int
opencons(void)
{
  8024cd:	55                   	push   %ebp
  8024ce:	89 e5                	mov    %esp,%ebp
  8024d0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024d6:	89 04 24             	mov    %eax,(%esp)
  8024d9:	e8 1d f2 ff ff       	call   8016fb <fd_alloc>
  8024de:	85 c0                	test   %eax,%eax
  8024e0:	78 3c                	js     80251e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024e9:	00 
  8024ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f8:	e8 cf ea ff ff       	call   800fcc <sys_page_alloc>
  8024fd:	85 c0                	test   %eax,%eax
  8024ff:	78 1d                	js     80251e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802501:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80250c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802516:	89 04 24             	mov    %eax,(%esp)
  802519:	e8 b2 f1 ff ff       	call   8016d0 <fd2num>
}
  80251e:	c9                   	leave  
  80251f:	c3                   	ret    

00802520 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802526:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80252d:	75 3c                	jne    80256b <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80252f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802536:	00 
  802537:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80253e:	ee 
  80253f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802546:	e8 81 ea ff ff       	call   800fcc <sys_page_alloc>
  80254b:	85 c0                	test   %eax,%eax
  80254d:	79 1c                	jns    80256b <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  80254f:	c7 44 24 08 1c 31 80 	movl   $0x80311c,0x8(%esp)
  802556:	00 
  802557:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80255e:	00 
  80255f:	c7 04 24 80 31 80 00 	movl   $0x803180,(%esp)
  802566:	e8 1d dd ff ff       	call   800288 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80256b:	8b 45 08             	mov    0x8(%ebp),%eax
  80256e:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802573:	c7 44 24 04 ac 25 80 	movl   $0x8025ac,0x4(%esp)
  80257a:	00 
  80257b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802582:	e8 1c ec ff ff       	call   8011a3 <sys_env_set_pgfault_upcall>
  802587:	85 c0                	test   %eax,%eax
  802589:	79 1c                	jns    8025a7 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80258b:	c7 44 24 08 48 31 80 	movl   $0x803148,0x8(%esp)
  802592:	00 
  802593:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80259a:	00 
  80259b:	c7 04 24 80 31 80 00 	movl   $0x803180,(%esp)
  8025a2:	e8 e1 dc ff ff       	call   800288 <_panic>
}
  8025a7:	c9                   	leave  
  8025a8:	c3                   	ret    
  8025a9:	00 00                	add    %al,(%eax)
	...

008025ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025ad:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8025b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025b4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  8025b7:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  8025bb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  8025c0:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8025c4:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  8025c6:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  8025c9:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  8025ca:	83 c4 04             	add    $0x4,%esp
    popfl
  8025cd:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8025ce:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8025cf:	c3                   	ret    

008025d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	56                   	push   %esi
  8025d4:	53                   	push   %ebx
  8025d5:	83 ec 10             	sub    $0x10,%esp
  8025d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8025db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025de:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8025e1:	85 db                	test   %ebx,%ebx
  8025e3:	74 06                	je     8025eb <ipc_recv+0x1b>
  8025e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8025eb:	85 f6                	test   %esi,%esi
  8025ed:	74 06                	je     8025f5 <ipc_recv+0x25>
  8025ef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8025fc:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8025ff:	89 04 24             	mov    %eax,(%esp)
  802602:	e8 2e ec ff ff       	call   801235 <sys_ipc_recv>
    if (ret) return ret;
  802607:	85 c0                	test   %eax,%eax
  802609:	75 24                	jne    80262f <ipc_recv+0x5f>
    if (from_env_store)
  80260b:	85 db                	test   %ebx,%ebx
  80260d:	74 0a                	je     802619 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80260f:	a1 20 54 80 00       	mov    0x805420,%eax
  802614:	8b 40 74             	mov    0x74(%eax),%eax
  802617:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802619:	85 f6                	test   %esi,%esi
  80261b:	74 0a                	je     802627 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80261d:	a1 20 54 80 00       	mov    0x805420,%eax
  802622:	8b 40 78             	mov    0x78(%eax),%eax
  802625:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802627:	a1 20 54 80 00       	mov    0x805420,%eax
  80262c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80262f:	83 c4 10             	add    $0x10,%esp
  802632:	5b                   	pop    %ebx
  802633:	5e                   	pop    %esi
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    

00802636 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	57                   	push   %edi
  80263a:	56                   	push   %esi
  80263b:	53                   	push   %ebx
  80263c:	83 ec 1c             	sub    $0x1c,%esp
  80263f:	8b 75 08             	mov    0x8(%ebp),%esi
  802642:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802645:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802648:	85 db                	test   %ebx,%ebx
  80264a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80264f:	0f 44 d8             	cmove  %eax,%ebx
  802652:	eb 2a                	jmp    80267e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802654:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802657:	74 20                	je     802679 <ipc_send+0x43>
  802659:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80265d:	c7 44 24 08 8e 31 80 	movl   $0x80318e,0x8(%esp)
  802664:	00 
  802665:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80266c:	00 
  80266d:	c7 04 24 a5 31 80 00 	movl   $0x8031a5,(%esp)
  802674:	e8 0f dc ff ff       	call   800288 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802679:	e8 1e e9 ff ff       	call   800f9c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80267e:	8b 45 14             	mov    0x14(%ebp),%eax
  802681:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802685:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802689:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80268d:	89 34 24             	mov    %esi,(%esp)
  802690:	e8 6c eb ff ff       	call   801201 <sys_ipc_try_send>
  802695:	85 c0                	test   %eax,%eax
  802697:	75 bb                	jne    802654 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802699:	83 c4 1c             	add    $0x1c,%esp
  80269c:	5b                   	pop    %ebx
  80269d:	5e                   	pop    %esi
  80269e:	5f                   	pop    %edi
  80269f:	5d                   	pop    %ebp
  8026a0:	c3                   	ret    

008026a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026a1:	55                   	push   %ebp
  8026a2:	89 e5                	mov    %esp,%ebp
  8026a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8026a7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8026ac:	39 c8                	cmp    %ecx,%eax
  8026ae:	74 19                	je     8026c9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026b0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8026b5:	89 c2                	mov    %eax,%edx
  8026b7:	c1 e2 07             	shl    $0x7,%edx
  8026ba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026c0:	8b 52 50             	mov    0x50(%edx),%edx
  8026c3:	39 ca                	cmp    %ecx,%edx
  8026c5:	75 14                	jne    8026db <ipc_find_env+0x3a>
  8026c7:	eb 05                	jmp    8026ce <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026c9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8026ce:	c1 e0 07             	shl    $0x7,%eax
  8026d1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026d6:	8b 40 40             	mov    0x40(%eax),%eax
  8026d9:	eb 0e                	jmp    8026e9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026db:	83 c0 01             	add    $0x1,%eax
  8026de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026e3:	75 d0                	jne    8026b5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026e5:	66 b8 00 00          	mov    $0x0,%ax
}
  8026e9:	5d                   	pop    %ebp
  8026ea:	c3                   	ret    
	...

008026ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
  8026ef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026f2:	89 d0                	mov    %edx,%eax
  8026f4:	c1 e8 16             	shr    $0x16,%eax
  8026f7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026fe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802703:	f6 c1 01             	test   $0x1,%cl
  802706:	74 1d                	je     802725 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802708:	c1 ea 0c             	shr    $0xc,%edx
  80270b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802712:	f6 c2 01             	test   $0x1,%dl
  802715:	74 0e                	je     802725 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802717:	c1 ea 0c             	shr    $0xc,%edx
  80271a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802721:	ef 
  802722:	0f b7 c0             	movzwl %ax,%eax
}
  802725:	5d                   	pop    %ebp
  802726:	c3                   	ret    
	...

00802730 <__udivdi3>:
  802730:	83 ec 1c             	sub    $0x1c,%esp
  802733:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802737:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80273b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80273f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802743:	89 74 24 10          	mov    %esi,0x10(%esp)
  802747:	8b 74 24 24          	mov    0x24(%esp),%esi
  80274b:	85 ff                	test   %edi,%edi
  80274d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802751:	89 44 24 08          	mov    %eax,0x8(%esp)
  802755:	89 cd                	mov    %ecx,%ebp
  802757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80275b:	75 33                	jne    802790 <__udivdi3+0x60>
  80275d:	39 f1                	cmp    %esi,%ecx
  80275f:	77 57                	ja     8027b8 <__udivdi3+0x88>
  802761:	85 c9                	test   %ecx,%ecx
  802763:	75 0b                	jne    802770 <__udivdi3+0x40>
  802765:	b8 01 00 00 00       	mov    $0x1,%eax
  80276a:	31 d2                	xor    %edx,%edx
  80276c:	f7 f1                	div    %ecx
  80276e:	89 c1                	mov    %eax,%ecx
  802770:	89 f0                	mov    %esi,%eax
  802772:	31 d2                	xor    %edx,%edx
  802774:	f7 f1                	div    %ecx
  802776:	89 c6                	mov    %eax,%esi
  802778:	8b 44 24 04          	mov    0x4(%esp),%eax
  80277c:	f7 f1                	div    %ecx
  80277e:	89 f2                	mov    %esi,%edx
  802780:	8b 74 24 10          	mov    0x10(%esp),%esi
  802784:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802788:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80278c:	83 c4 1c             	add    $0x1c,%esp
  80278f:	c3                   	ret    
  802790:	31 d2                	xor    %edx,%edx
  802792:	31 c0                	xor    %eax,%eax
  802794:	39 f7                	cmp    %esi,%edi
  802796:	77 e8                	ja     802780 <__udivdi3+0x50>
  802798:	0f bd cf             	bsr    %edi,%ecx
  80279b:	83 f1 1f             	xor    $0x1f,%ecx
  80279e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027a2:	75 2c                	jne    8027d0 <__udivdi3+0xa0>
  8027a4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8027a8:	76 04                	jbe    8027ae <__udivdi3+0x7e>
  8027aa:	39 f7                	cmp    %esi,%edi
  8027ac:	73 d2                	jae    802780 <__udivdi3+0x50>
  8027ae:	31 d2                	xor    %edx,%edx
  8027b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b5:	eb c9                	jmp    802780 <__udivdi3+0x50>
  8027b7:	90                   	nop
  8027b8:	89 f2                	mov    %esi,%edx
  8027ba:	f7 f1                	div    %ecx
  8027bc:	31 d2                	xor    %edx,%edx
  8027be:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027c2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027c6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027ca:	83 c4 1c             	add    $0x1c,%esp
  8027cd:	c3                   	ret    
  8027ce:	66 90                	xchg   %ax,%ax
  8027d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027d5:	b8 20 00 00 00       	mov    $0x20,%eax
  8027da:	89 ea                	mov    %ebp,%edx
  8027dc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027e0:	d3 e7                	shl    %cl,%edi
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	d3 ea                	shr    %cl,%edx
  8027e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027eb:	09 fa                	or     %edi,%edx
  8027ed:	89 f7                	mov    %esi,%edi
  8027ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027f9:	d3 e5                	shl    %cl,%ebp
  8027fb:	89 c1                	mov    %eax,%ecx
  8027fd:	d3 ef                	shr    %cl,%edi
  8027ff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802804:	d3 e2                	shl    %cl,%edx
  802806:	89 c1                	mov    %eax,%ecx
  802808:	d3 ee                	shr    %cl,%esi
  80280a:	09 d6                	or     %edx,%esi
  80280c:	89 fa                	mov    %edi,%edx
  80280e:	89 f0                	mov    %esi,%eax
  802810:	f7 74 24 0c          	divl   0xc(%esp)
  802814:	89 d7                	mov    %edx,%edi
  802816:	89 c6                	mov    %eax,%esi
  802818:	f7 e5                	mul    %ebp
  80281a:	39 d7                	cmp    %edx,%edi
  80281c:	72 22                	jb     802840 <__udivdi3+0x110>
  80281e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802822:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802827:	d3 e5                	shl    %cl,%ebp
  802829:	39 c5                	cmp    %eax,%ebp
  80282b:	73 04                	jae    802831 <__udivdi3+0x101>
  80282d:	39 d7                	cmp    %edx,%edi
  80282f:	74 0f                	je     802840 <__udivdi3+0x110>
  802831:	89 f0                	mov    %esi,%eax
  802833:	31 d2                	xor    %edx,%edx
  802835:	e9 46 ff ff ff       	jmp    802780 <__udivdi3+0x50>
  80283a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802840:	8d 46 ff             	lea    -0x1(%esi),%eax
  802843:	31 d2                	xor    %edx,%edx
  802845:	8b 74 24 10          	mov    0x10(%esp),%esi
  802849:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80284d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802851:	83 c4 1c             	add    $0x1c,%esp
  802854:	c3                   	ret    
	...

00802860 <__umoddi3>:
  802860:	83 ec 1c             	sub    $0x1c,%esp
  802863:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802867:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80286b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80286f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802873:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802877:	8b 74 24 24          	mov    0x24(%esp),%esi
  80287b:	85 ed                	test   %ebp,%ebp
  80287d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802881:	89 44 24 08          	mov    %eax,0x8(%esp)
  802885:	89 cf                	mov    %ecx,%edi
  802887:	89 04 24             	mov    %eax,(%esp)
  80288a:	89 f2                	mov    %esi,%edx
  80288c:	75 1a                	jne    8028a8 <__umoddi3+0x48>
  80288e:	39 f1                	cmp    %esi,%ecx
  802890:	76 4e                	jbe    8028e0 <__umoddi3+0x80>
  802892:	f7 f1                	div    %ecx
  802894:	89 d0                	mov    %edx,%eax
  802896:	31 d2                	xor    %edx,%edx
  802898:	8b 74 24 10          	mov    0x10(%esp),%esi
  80289c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028a4:	83 c4 1c             	add    $0x1c,%esp
  8028a7:	c3                   	ret    
  8028a8:	39 f5                	cmp    %esi,%ebp
  8028aa:	77 54                	ja     802900 <__umoddi3+0xa0>
  8028ac:	0f bd c5             	bsr    %ebp,%eax
  8028af:	83 f0 1f             	xor    $0x1f,%eax
  8028b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028b6:	75 60                	jne    802918 <__umoddi3+0xb8>
  8028b8:	3b 0c 24             	cmp    (%esp),%ecx
  8028bb:	0f 87 07 01 00 00    	ja     8029c8 <__umoddi3+0x168>
  8028c1:	89 f2                	mov    %esi,%edx
  8028c3:	8b 34 24             	mov    (%esp),%esi
  8028c6:	29 ce                	sub    %ecx,%esi
  8028c8:	19 ea                	sbb    %ebp,%edx
  8028ca:	89 34 24             	mov    %esi,(%esp)
  8028cd:	8b 04 24             	mov    (%esp),%eax
  8028d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028dc:	83 c4 1c             	add    $0x1c,%esp
  8028df:	c3                   	ret    
  8028e0:	85 c9                	test   %ecx,%ecx
  8028e2:	75 0b                	jne    8028ef <__umoddi3+0x8f>
  8028e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028e9:	31 d2                	xor    %edx,%edx
  8028eb:	f7 f1                	div    %ecx
  8028ed:	89 c1                	mov    %eax,%ecx
  8028ef:	89 f0                	mov    %esi,%eax
  8028f1:	31 d2                	xor    %edx,%edx
  8028f3:	f7 f1                	div    %ecx
  8028f5:	8b 04 24             	mov    (%esp),%eax
  8028f8:	f7 f1                	div    %ecx
  8028fa:	eb 98                	jmp    802894 <__umoddi3+0x34>
  8028fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802900:	89 f2                	mov    %esi,%edx
  802902:	8b 74 24 10          	mov    0x10(%esp),%esi
  802906:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80290a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80290e:	83 c4 1c             	add    $0x1c,%esp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80291d:	89 e8                	mov    %ebp,%eax
  80291f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802924:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802928:	89 fa                	mov    %edi,%edx
  80292a:	d3 e0                	shl    %cl,%eax
  80292c:	89 e9                	mov    %ebp,%ecx
  80292e:	d3 ea                	shr    %cl,%edx
  802930:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802935:	09 c2                	or     %eax,%edx
  802937:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293b:	89 14 24             	mov    %edx,(%esp)
  80293e:	89 f2                	mov    %esi,%edx
  802940:	d3 e7                	shl    %cl,%edi
  802942:	89 e9                	mov    %ebp,%ecx
  802944:	d3 ea                	shr    %cl,%edx
  802946:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80294b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80294f:	d3 e6                	shl    %cl,%esi
  802951:	89 e9                	mov    %ebp,%ecx
  802953:	d3 e8                	shr    %cl,%eax
  802955:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80295a:	09 f0                	or     %esi,%eax
  80295c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802960:	f7 34 24             	divl   (%esp)
  802963:	d3 e6                	shl    %cl,%esi
  802965:	89 74 24 08          	mov    %esi,0x8(%esp)
  802969:	89 d6                	mov    %edx,%esi
  80296b:	f7 e7                	mul    %edi
  80296d:	39 d6                	cmp    %edx,%esi
  80296f:	89 c1                	mov    %eax,%ecx
  802971:	89 d7                	mov    %edx,%edi
  802973:	72 3f                	jb     8029b4 <__umoddi3+0x154>
  802975:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802979:	72 35                	jb     8029b0 <__umoddi3+0x150>
  80297b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80297f:	29 c8                	sub    %ecx,%eax
  802981:	19 fe                	sbb    %edi,%esi
  802983:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802988:	89 f2                	mov    %esi,%edx
  80298a:	d3 e8                	shr    %cl,%eax
  80298c:	89 e9                	mov    %ebp,%ecx
  80298e:	d3 e2                	shl    %cl,%edx
  802990:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802995:	09 d0                	or     %edx,%eax
  802997:	89 f2                	mov    %esi,%edx
  802999:	d3 ea                	shr    %cl,%edx
  80299b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80299f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029a7:	83 c4 1c             	add    $0x1c,%esp
  8029aa:	c3                   	ret    
  8029ab:	90                   	nop
  8029ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029b0:	39 d6                	cmp    %edx,%esi
  8029b2:	75 c7                	jne    80297b <__umoddi3+0x11b>
  8029b4:	89 d7                	mov    %edx,%edi
  8029b6:	89 c1                	mov    %eax,%ecx
  8029b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8029bc:	1b 3c 24             	sbb    (%esp),%edi
  8029bf:	eb ba                	jmp    80297b <__umoddi3+0x11b>
  8029c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029c8:	39 f5                	cmp    %esi,%ebp
  8029ca:	0f 82 f1 fe ff ff    	jb     8028c1 <__umoddi3+0x61>
  8029d0:	e9 f8 fe ff ff       	jmp    8028cd <__umoddi3+0x6d>
