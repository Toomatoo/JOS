
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800043:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800046:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004d:	00 
  80004e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800052:	89 1c 24             	mov    %ebx,(%esp)
  800055:	e8 14 1b 00 00       	call   801b6e <readn>
  80005a:	83 f8 04             	cmp    $0x4,%eax
  80005d:	74 2e                	je     80008d <primeproc+0x59>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005f:	85 c0                	test   %eax,%eax
  800061:	ba 00 00 00 00       	mov    $0x0,%edx
  800066:	0f 4e d0             	cmovle %eax,%edx
  800069:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800071:	c7 44 24 08 40 2a 80 	movl   $0x802a40,0x8(%esp)
  800078:	00 
  800079:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800080:	00 
  800081:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  800088:	e8 a3 02 00 00       	call   800330 <_panic>

	cprintf("%d\n", p);
  80008d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800090:	89 44 24 04          	mov    %eax,0x4(%esp)
  800094:	c7 04 24 81 2a 80 00 	movl   $0x802a81,(%esp)
  80009b:	e8 8b 03 00 00       	call   80042b <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  8000a0:	89 3c 24             	mov    %edi,(%esp)
  8000a3:	e8 5c 21 00 00       	call   802204 <pipe>
  8000a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 20                	jns    8000cf <primeproc+0x9b>
		panic("pipe: %e", i);
  8000af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b3:	c7 44 24 08 85 2a 80 	movl   $0x802a85,0x8(%esp)
  8000ba:	00 
  8000bb:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c2:	00 
  8000c3:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  8000ca:	e8 61 02 00 00       	call   800330 <_panic>
	if ((id = fork()) < 0)
  8000cf:	e8 c3 13 00 00       	call   801497 <fork>
  8000d4:	85 c0                	test   %eax,%eax
  8000d6:	79 20                	jns    8000f8 <primeproc+0xc4>
		panic("fork: %e", id);
  8000d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000dc:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  8000e3:	00 
  8000e4:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000eb:	00 
  8000ec:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  8000f3:	e8 38 02 00 00       	call   800330 <_panic>
	if (id == 0) {
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	75 1b                	jne    800117 <primeproc+0xe3>
		close(fd);
  8000fc:	89 1c 24             	mov    %ebx,(%esp)
  8000ff:	e8 69 18 00 00       	call   80196d <close>
		close(pfd[1]);
  800104:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800107:	89 04 24             	mov    %eax,(%esp)
  80010a:	e8 5e 18 00 00       	call   80196d <close>
		fd = pfd[0];
  80010f:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800112:	e9 2f ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  800117:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80011a:	89 04 24             	mov    %eax,(%esp)
  80011d:	e8 4b 18 00 00       	call   80196d <close>
	wfd = pfd[1];
  800122:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800125:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800128:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80012f:	00 
  800130:	89 74 24 04          	mov    %esi,0x4(%esp)
  800134:	89 1c 24             	mov    %ebx,(%esp)
  800137:	e8 32 1a 00 00       	call   801b6e <readn>
  80013c:	83 f8 04             	cmp    $0x4,%eax
  80013f:	74 39                	je     80017a <primeproc+0x146>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800141:	85 c0                	test   %eax,%eax
  800143:	ba 00 00 00 00       	mov    $0x0,%edx
  800148:	0f 4e d0             	cmovle %eax,%edx
  80014b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80014f:	89 44 24 14          	mov    %eax,0x14(%esp)
  800153:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800157:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015e:	c7 44 24 08 97 2a 80 	movl   $0x802a97,0x8(%esp)
  800165:	00 
  800166:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80016d:	00 
  80016e:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  800175:	e8 b6 01 00 00       	call   800330 <_panic>
		if (i%p)
  80017a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80017d:	89 c2                	mov    %eax,%edx
  80017f:	c1 fa 1f             	sar    $0x1f,%edx
  800182:	f7 7d e0             	idivl  -0x20(%ebp)
  800185:	85 d2                	test   %edx,%edx
  800187:	74 9f                	je     800128 <primeproc+0xf4>
			if ((r=write(wfd, &i, 4)) != 4)
  800189:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800190:	00 
  800191:	89 74 24 04          	mov    %esi,0x4(%esp)
  800195:	89 3c 24             	mov    %edi,(%esp)
  800198:	e8 21 1a 00 00       	call   801bbe <write>
  80019d:	83 f8 04             	cmp    $0x4,%eax
  8001a0:	74 86                	je     800128 <primeproc+0xf4>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a9:	0f 4e d0             	cmovle %eax,%edx
  8001ac:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bb:	c7 44 24 08 b3 2a 80 	movl   $0x802ab3,0x8(%esp)
  8001c2:	00 
  8001c3:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001ca:	00 
  8001cb:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  8001d2:	e8 59 01 00 00       	call   800330 <_panic>

008001d7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	53                   	push   %ebx
  8001db:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001de:	c7 05 00 40 80 00 cd 	movl   $0x802acd,0x804000
  8001e5:	2a 80 00 

	if ((i=pipe(p)) < 0)
  8001e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001eb:	89 04 24             	mov    %eax,(%esp)
  8001ee:	e8 11 20 00 00       	call   802204 <pipe>
  8001f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	79 20                	jns    80021a <umain+0x43>
		panic("pipe: %e", i);
  8001fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fe:	c7 44 24 08 85 2a 80 	movl   $0x802a85,0x8(%esp)
  800205:	00 
  800206:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80020d:	00 
  80020e:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  800215:	e8 16 01 00 00       	call   800330 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80021a:	e8 78 12 00 00       	call   801497 <fork>
  80021f:	85 c0                	test   %eax,%eax
  800221:	79 20                	jns    800243 <umain+0x6c>
		panic("fork: %e", id);
  800223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800227:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  80022e:	00 
  80022f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800236:	00 
  800237:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  80023e:	e8 ed 00 00 00       	call   800330 <_panic>

	if (id == 0) {
  800243:	85 c0                	test   %eax,%eax
  800245:	75 16                	jne    80025d <umain+0x86>
		close(p[1]);
  800247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 1b 17 00 00       	call   80196d <close>
		primeproc(p[0]);
  800252:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	e8 d7 fd ff ff       	call   800034 <primeproc>
	}

	close(p[0]);
  80025d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 05 17 00 00       	call   80196d <close>

	// feed all the integers through
	for (i=2;; i++)
  800268:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  80026f:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800272:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800279:	00 
  80027a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80027e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800281:	89 04 24             	mov    %eax,(%esp)
  800284:	e8 35 19 00 00       	call   801bbe <write>
  800289:	83 f8 04             	cmp    $0x4,%eax
  80028c:	74 2e                	je     8002bc <umain+0xe5>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  80028e:	85 c0                	test   %eax,%eax
  800290:	ba 00 00 00 00       	mov    $0x0,%edx
  800295:	0f 4e d0             	cmovle %eax,%edx
  800298:	89 54 24 10          	mov    %edx,0x10(%esp)
  80029c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a0:	c7 44 24 08 d8 2a 80 	movl   $0x802ad8,0x8(%esp)
  8002a7:	00 
  8002a8:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002af:	00 
  8002b0:	c7 04 24 6f 2a 80 00 	movl   $0x802a6f,(%esp)
  8002b7:	e8 74 00 00 00       	call   800330 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002c0:	eb b0                	jmp    800272 <umain+0x9b>
	...

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
  8002ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d6:	e8 41 0d 00 00       	call   80101c <sys_getenvid>
  8002db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e0:	c1 e0 07             	shl    $0x7,%eax
  8002e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e8:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ed:	85 f6                	test   %esi,%esi
  8002ef:	7e 07                	jle    8002f8 <libmain+0x34>
		binaryname = argv[0];
  8002f1:	8b 03                	mov    (%ebx),%eax
  8002f3:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8002f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002fc:	89 34 24             	mov    %esi,(%esp)
  8002ff:	e8 d3 fe ff ff       	call   8001d7 <umain>

	// exit gracefully
	exit();
  800304:	e8 0b 00 00 00       	call   800314 <exit>
}
  800309:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80030c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80030f:	89 ec                	mov    %ebp,%esp
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    
	...

00800314 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80031a:	e8 7f 16 00 00       	call   80199e <close_all>
	sys_env_destroy(0);
  80031f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800326:	e8 94 0c 00 00       	call   800fbf <sys_env_destroy>
}
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    
  80032d:	00 00                	add    %al,(%eax)
	...

00800330 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800338:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033b:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800341:	e8 d6 0c 00 00       	call   80101c <sys_getenvid>
  800346:	8b 55 0c             	mov    0xc(%ebp),%edx
  800349:	89 54 24 10          	mov    %edx,0x10(%esp)
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800354:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035c:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800363:	e8 c3 00 00 00       	call   80042b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800368:	89 74 24 04          	mov    %esi,0x4(%esp)
  80036c:	8b 45 10             	mov    0x10(%ebp),%eax
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	e8 53 00 00 00       	call   8003ca <vcprintf>
	cprintf("\n");
  800377:	c7 04 24 7f 2e 80 00 	movl   $0x802e7f,(%esp)
  80037e:	e8 a8 00 00 00       	call   80042b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800383:	cc                   	int3   
  800384:	eb fd                	jmp    800383 <_panic+0x53>
	...

00800388 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	53                   	push   %ebx
  80038c:	83 ec 14             	sub    $0x14,%esp
  80038f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800392:	8b 03                	mov    (%ebx),%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80039b:	83 c0 01             	add    $0x1,%eax
  80039e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a5:	75 19                	jne    8003c0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003a7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ae:	00 
  8003af:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b2:	89 04 24             	mov    %eax,(%esp)
  8003b5:	e8 a6 0b 00 00       	call   800f60 <sys_cputs>
		b->idx = 0;
  8003ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c4:	83 c4 14             	add    $0x14,%esp
  8003c7:	5b                   	pop    %ebx
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003da:	00 00 00 
	b.cnt = 0;
  8003dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800406:	e8 97 01 00 00       	call   8005a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800411:	89 44 24 04          	mov    %eax,0x4(%esp)
  800415:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	e8 3d 0b 00 00       	call   800f60 <sys_cputs>

	return b.cnt;
}
  800423:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800431:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800434:	89 44 24 04          	mov    %eax,0x4(%esp)
  800438:	8b 45 08             	mov    0x8(%ebp),%eax
  80043b:	89 04 24             	mov    %eax,(%esp)
  80043e:	e8 87 ff ff ff       	call   8003ca <vcprintf>
	va_end(ap);

	return cnt;
}
  800443:	c9                   	leave  
  800444:	c3                   	ret    
  800445:	00 00                	add    %al,(%eax)
	...

00800448 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 3c             	sub    $0x3c,%esp
  800451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800454:	89 d7                	mov    %edx,%edi
  800456:	8b 45 08             	mov    0x8(%ebp),%eax
  800459:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80045c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800462:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800465:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800470:	72 11                	jb     800483 <printnum+0x3b>
  800472:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800475:	39 45 10             	cmp    %eax,0x10(%ebp)
  800478:	76 09                	jbe    800483 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047a:	83 eb 01             	sub    $0x1,%ebx
  80047d:	85 db                	test   %ebx,%ebx
  80047f:	7f 51                	jg     8004d2 <printnum+0x8a>
  800481:	eb 5e                	jmp    8004e1 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800483:	89 74 24 10          	mov    %esi,0x10(%esp)
  800487:	83 eb 01             	sub    $0x1,%ebx
  80048a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80048e:	8b 45 10             	mov    0x10(%ebp),%eax
  800491:	89 44 24 08          	mov    %eax,0x8(%esp)
  800495:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800499:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80049d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004a4:	00 
  8004a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b2:	e8 c9 22 00 00       	call   802780 <__udivdi3>
  8004b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004bf:	89 04 24             	mov    %eax,(%esp)
  8004c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c6:	89 fa                	mov    %edi,%edx
  8004c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cb:	e8 78 ff ff ff       	call   800448 <printnum>
  8004d0:	eb 0f                	jmp    8004e1 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d6:	89 34 24             	mov    %esi,(%esp)
  8004d9:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004dc:	83 eb 01             	sub    $0x1,%ebx
  8004df:	75 f1                	jne    8004d2 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f7:	00 
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	e8 a6 23 00 00       	call   8028b0 <__umoddi3>
  80050a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050e:	0f be 80 1f 2b 80 00 	movsbl 0x802b1f(%eax),%eax
  800515:	89 04 24             	mov    %eax,(%esp)
  800518:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80051b:	83 c4 3c             	add    $0x3c,%esp
  80051e:	5b                   	pop    %ebx
  80051f:	5e                   	pop    %esi
  800520:	5f                   	pop    %edi
  800521:	5d                   	pop    %ebp
  800522:	c3                   	ret    

00800523 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800526:	83 fa 01             	cmp    $0x1,%edx
  800529:	7e 0e                	jle    800539 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80052b:	8b 10                	mov    (%eax),%edx
  80052d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800530:	89 08                	mov    %ecx,(%eax)
  800532:	8b 02                	mov    (%edx),%eax
  800534:	8b 52 04             	mov    0x4(%edx),%edx
  800537:	eb 22                	jmp    80055b <getuint+0x38>
	else if (lflag)
  800539:	85 d2                	test   %edx,%edx
  80053b:	74 10                	je     80054d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80053d:	8b 10                	mov    (%eax),%edx
  80053f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800542:	89 08                	mov    %ecx,(%eax)
  800544:	8b 02                	mov    (%edx),%eax
  800546:	ba 00 00 00 00       	mov    $0x0,%edx
  80054b:	eb 0e                	jmp    80055b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80054d:	8b 10                	mov    (%eax),%edx
  80054f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800552:	89 08                	mov    %ecx,(%eax)
  800554:	8b 02                	mov    (%edx),%eax
  800556:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80055b:	5d                   	pop    %ebp
  80055c:	c3                   	ret    

0080055d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800563:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800567:	8b 10                	mov    (%eax),%edx
  800569:	3b 50 04             	cmp    0x4(%eax),%edx
  80056c:	73 0a                	jae    800578 <sprintputch+0x1b>
		*b->buf++ = ch;
  80056e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800571:	88 0a                	mov    %cl,(%edx)
  800573:	83 c2 01             	add    $0x1,%edx
  800576:	89 10                	mov    %edx,(%eax)
}
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800580:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800583:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800587:	8b 45 10             	mov    0x10(%ebp),%eax
  80058a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800591:	89 44 24 04          	mov    %eax,0x4(%esp)
  800595:	8b 45 08             	mov    0x8(%ebp),%eax
  800598:	89 04 24             	mov    %eax,(%esp)
  80059b:	e8 02 00 00 00       	call   8005a2 <vprintfmt>
	va_end(ap);
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    

008005a2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	57                   	push   %edi
  8005a6:	56                   	push   %esi
  8005a7:	53                   	push   %ebx
  8005a8:	83 ec 5c             	sub    $0x5c,%esp
  8005ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8005b1:	eb 12                	jmp    8005c5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	0f 84 e4 04 00 00    	je     800a9f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8005bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c5:	0f b6 06             	movzbl (%esi),%eax
  8005c8:	83 c6 01             	add    $0x1,%esi
  8005cb:	83 f8 25             	cmp    $0x25,%eax
  8005ce:	75 e3                	jne    8005b3 <vprintfmt+0x11>
  8005d0:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8005d4:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8005db:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005e0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ec:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8005ef:	eb 2b                	jmp    80061c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005f4:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8005f8:	eb 22                	jmp    80061c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005fd:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800601:	eb 19                	jmp    80061c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800606:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80060d:	eb 0d                	jmp    80061c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80060f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800612:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800615:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061c:	0f b6 06             	movzbl (%esi),%eax
  80061f:	0f b6 d0             	movzbl %al,%edx
  800622:	8d 7e 01             	lea    0x1(%esi),%edi
  800625:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800628:	83 e8 23             	sub    $0x23,%eax
  80062b:	3c 55                	cmp    $0x55,%al
  80062d:	0f 87 46 04 00 00    	ja     800a79 <vprintfmt+0x4d7>
  800633:	0f b6 c0             	movzbl %al,%eax
  800636:	ff 24 85 80 2c 80 00 	jmp    *0x802c80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80063d:	83 ea 30             	sub    $0x30,%edx
  800640:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800643:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800647:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80064d:	83 fa 09             	cmp    $0x9,%edx
  800650:	77 4a                	ja     80069c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800655:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800658:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80065b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80065f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800662:	8d 50 d0             	lea    -0x30(%eax),%edx
  800665:	83 fa 09             	cmp    $0x9,%edx
  800668:	76 eb                	jbe    800655 <vprintfmt+0xb3>
  80066a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80066d:	eb 2d                	jmp    80069c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800680:	eb 1a                	jmp    80069c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800685:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800689:	79 91                	jns    80061c <vprintfmt+0x7a>
  80068b:	e9 73 ff ff ff       	jmp    800603 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800693:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80069a:	eb 80                	jmp    80061c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80069c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006a0:	0f 89 76 ff ff ff    	jns    80061c <vprintfmt+0x7a>
  8006a6:	e9 64 ff ff ff       	jmp    80060f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006ab:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006b1:	e9 66 ff ff ff       	jmp    80061c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 04             	lea    0x4(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	89 04 24             	mov    %eax,(%esp)
  8006c8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ce:	e9 f2 fe ff ff       	jmp    8005c5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8006d3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8006d7:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8006da:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8006de:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8006e1:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8006e5:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8006e8:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8006eb:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8006ef:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006f2:	80 f9 09             	cmp    $0x9,%cl
  8006f5:	77 1d                	ja     800714 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8006f7:	0f be c0             	movsbl %al,%eax
  8006fa:	6b c0 64             	imul   $0x64,%eax,%eax
  8006fd:	0f be d2             	movsbl %dl,%edx
  800700:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800703:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80070a:	a3 04 40 80 00       	mov    %eax,0x804004
  80070f:	e9 b1 fe ff ff       	jmp    8005c5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800714:	c7 44 24 04 37 2b 80 	movl   $0x802b37,0x4(%esp)
  80071b:	00 
  80071c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80071f:	89 04 24             	mov    %eax,(%esp)
  800722:	e8 14 05 00 00       	call   800c3b <strcmp>
  800727:	85 c0                	test   %eax,%eax
  800729:	75 0f                	jne    80073a <vprintfmt+0x198>
  80072b:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  800732:	00 00 00 
  800735:	e9 8b fe ff ff       	jmp    8005c5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80073a:	c7 44 24 04 3b 2b 80 	movl   $0x802b3b,0x4(%esp)
  800741:	00 
  800742:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800745:	89 14 24             	mov    %edx,(%esp)
  800748:	e8 ee 04 00 00       	call   800c3b <strcmp>
  80074d:	85 c0                	test   %eax,%eax
  80074f:	75 0f                	jne    800760 <vprintfmt+0x1be>
  800751:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  800758:	00 00 00 
  80075b:	e9 65 fe ff ff       	jmp    8005c5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800760:	c7 44 24 04 3f 2b 80 	movl   $0x802b3f,0x4(%esp)
  800767:	00 
  800768:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80076b:	89 0c 24             	mov    %ecx,(%esp)
  80076e:	e8 c8 04 00 00       	call   800c3b <strcmp>
  800773:	85 c0                	test   %eax,%eax
  800775:	75 0f                	jne    800786 <vprintfmt+0x1e4>
  800777:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  80077e:	00 00 00 
  800781:	e9 3f fe ff ff       	jmp    8005c5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800786:	c7 44 24 04 43 2b 80 	movl   $0x802b43,0x4(%esp)
  80078d:	00 
  80078e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800791:	89 3c 24             	mov    %edi,(%esp)
  800794:	e8 a2 04 00 00       	call   800c3b <strcmp>
  800799:	85 c0                	test   %eax,%eax
  80079b:	75 0f                	jne    8007ac <vprintfmt+0x20a>
  80079d:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  8007a4:	00 00 00 
  8007a7:	e9 19 fe ff ff       	jmp    8005c5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8007ac:	c7 44 24 04 47 2b 80 	movl   $0x802b47,0x4(%esp)
  8007b3:	00 
  8007b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 7c 04 00 00       	call   800c3b <strcmp>
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	75 0f                	jne    8007d2 <vprintfmt+0x230>
  8007c3:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  8007ca:	00 00 00 
  8007cd:	e9 f3 fd ff ff       	jmp    8005c5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8007d2:	c7 44 24 04 4b 2b 80 	movl   $0x802b4b,0x4(%esp)
  8007d9:	00 
  8007da:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8007dd:	89 14 24             	mov    %edx,(%esp)
  8007e0:	e8 56 04 00 00       	call   800c3b <strcmp>
  8007e5:	83 f8 01             	cmp    $0x1,%eax
  8007e8:	19 c0                	sbb    %eax,%eax
  8007ea:	f7 d0                	not    %eax
  8007ec:	83 c0 08             	add    $0x8,%eax
  8007ef:	a3 04 40 80 00       	mov    %eax,0x804004
  8007f4:	e9 cc fd ff ff       	jmp    8005c5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 c2                	mov    %eax,%edx
  800806:	c1 fa 1f             	sar    $0x1f,%edx
  800809:	31 d0                	xor    %edx,%eax
  80080b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80080d:	83 f8 0f             	cmp    $0xf,%eax
  800810:	7f 0b                	jg     80081d <vprintfmt+0x27b>
  800812:	8b 14 85 e0 2d 80 00 	mov    0x802de0(,%eax,4),%edx
  800819:	85 d2                	test   %edx,%edx
  80081b:	75 23                	jne    800840 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80081d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800821:	c7 44 24 08 4f 2b 80 	movl   $0x802b4f,0x8(%esp)
  800828:	00 
  800829:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800830:	89 3c 24             	mov    %edi,(%esp)
  800833:	e8 42 fd ff ff       	call   80057a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800838:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80083b:	e9 85 fd ff ff       	jmp    8005c5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800840:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800844:	c7 44 24 08 a1 30 80 	movl   $0x8030a1,0x8(%esp)
  80084b:	00 
  80084c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800850:	8b 7d 08             	mov    0x8(%ebp),%edi
  800853:	89 3c 24             	mov    %edi,(%esp)
  800856:	e8 1f fd ff ff       	call   80057a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80085e:	e9 62 fd ff ff       	jmp    8005c5 <vprintfmt+0x23>
  800863:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800866:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800869:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8d 50 04             	lea    0x4(%eax),%edx
  800872:	89 55 14             	mov    %edx,0x14(%ebp)
  800875:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800877:	85 f6                	test   %esi,%esi
  800879:	b8 30 2b 80 00       	mov    $0x802b30,%eax
  80087e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800881:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800885:	7e 06                	jle    80088d <vprintfmt+0x2eb>
  800887:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80088b:	75 13                	jne    8008a0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088d:	0f be 06             	movsbl (%esi),%eax
  800890:	83 c6 01             	add    $0x1,%esi
  800893:	85 c0                	test   %eax,%eax
  800895:	0f 85 94 00 00 00    	jne    80092f <vprintfmt+0x38d>
  80089b:	e9 81 00 00 00       	jmp    800921 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a4:	89 34 24             	mov    %esi,(%esp)
  8008a7:	e8 9f 02 00 00       	call   800b4b <strnlen>
  8008ac:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008af:	29 c2                	sub    %eax,%edx
  8008b1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8008b4:	85 d2                	test   %edx,%edx
  8008b6:	7e d5                	jle    80088d <vprintfmt+0x2eb>
					putch(padc, putdat);
  8008b8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008bc:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8008bf:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	89 cf                	mov    %ecx,%edi
  8008c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ca:	89 3c 24             	mov    %edi,(%esp)
  8008cd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d0:	83 ee 01             	sub    $0x1,%esi
  8008d3:	75 f1                	jne    8008c6 <vprintfmt+0x324>
  8008d5:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8008d8:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8008db:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8008de:	eb ad                	jmp    80088d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008e4:	74 1b                	je     800901 <vprintfmt+0x35f>
  8008e6:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008e9:	83 fa 5e             	cmp    $0x5e,%edx
  8008ec:	76 13                	jbe    800901 <vprintfmt+0x35f>
					putch('?', putdat);
  8008ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f5:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008fc:	ff 55 08             	call   *0x8(%ebp)
  8008ff:	eb 0d                	jmp    80090e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800901:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800904:	89 54 24 04          	mov    %edx,0x4(%esp)
  800908:	89 04 24             	mov    %eax,(%esp)
  80090b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090e:	83 eb 01             	sub    $0x1,%ebx
  800911:	0f be 06             	movsbl (%esi),%eax
  800914:	83 c6 01             	add    $0x1,%esi
  800917:	85 c0                	test   %eax,%eax
  800919:	75 1a                	jne    800935 <vprintfmt+0x393>
  80091b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80091e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800921:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800924:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800928:	7f 1c                	jg     800946 <vprintfmt+0x3a4>
  80092a:	e9 96 fc ff ff       	jmp    8005c5 <vprintfmt+0x23>
  80092f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800932:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800935:	85 ff                	test   %edi,%edi
  800937:	78 a7                	js     8008e0 <vprintfmt+0x33e>
  800939:	83 ef 01             	sub    $0x1,%edi
  80093c:	79 a2                	jns    8008e0 <vprintfmt+0x33e>
  80093e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800941:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800944:	eb db                	jmp    800921 <vprintfmt+0x37f>
  800946:	8b 7d 08             	mov    0x8(%ebp),%edi
  800949:	89 de                	mov    %ebx,%esi
  80094b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800952:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800959:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095b:	83 eb 01             	sub    $0x1,%ebx
  80095e:	75 ee                	jne    80094e <vprintfmt+0x3ac>
  800960:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800965:	e9 5b fc ff ff       	jmp    8005c5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80096a:	83 f9 01             	cmp    $0x1,%ecx
  80096d:	7e 10                	jle    80097f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80096f:	8b 45 14             	mov    0x14(%ebp),%eax
  800972:	8d 50 08             	lea    0x8(%eax),%edx
  800975:	89 55 14             	mov    %edx,0x14(%ebp)
  800978:	8b 30                	mov    (%eax),%esi
  80097a:	8b 78 04             	mov    0x4(%eax),%edi
  80097d:	eb 26                	jmp    8009a5 <vprintfmt+0x403>
	else if (lflag)
  80097f:	85 c9                	test   %ecx,%ecx
  800981:	74 12                	je     800995 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800983:	8b 45 14             	mov    0x14(%ebp),%eax
  800986:	8d 50 04             	lea    0x4(%eax),%edx
  800989:	89 55 14             	mov    %edx,0x14(%ebp)
  80098c:	8b 30                	mov    (%eax),%esi
  80098e:	89 f7                	mov    %esi,%edi
  800990:	c1 ff 1f             	sar    $0x1f,%edi
  800993:	eb 10                	jmp    8009a5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800995:	8b 45 14             	mov    0x14(%ebp),%eax
  800998:	8d 50 04             	lea    0x4(%eax),%edx
  80099b:	89 55 14             	mov    %edx,0x14(%ebp)
  80099e:	8b 30                	mov    (%eax),%esi
  8009a0:	89 f7                	mov    %esi,%edi
  8009a2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009a5:	85 ff                	test   %edi,%edi
  8009a7:	78 0e                	js     8009b7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ad:	be 0a 00 00 00       	mov    $0xa,%esi
  8009b2:	e9 84 00 00 00       	jmp    800a3b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009c2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009c5:	89 f0                	mov    %esi,%eax
  8009c7:	89 fa                	mov    %edi,%edx
  8009c9:	f7 d8                	neg    %eax
  8009cb:	83 d2 00             	adc    $0x0,%edx
  8009ce:	f7 da                	neg    %edx
			}
			base = 10;
  8009d0:	be 0a 00 00 00       	mov    $0xa,%esi
  8009d5:	eb 64                	jmp    800a3b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d7:	89 ca                	mov    %ecx,%edx
  8009d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8009dc:	e8 42 fb ff ff       	call   800523 <getuint>
			base = 10;
  8009e1:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8009e6:	eb 53                	jmp    800a3b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8009e8:	89 ca                	mov    %ecx,%edx
  8009ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ed:	e8 31 fb ff ff       	call   800523 <getuint>
    			base = 8;
  8009f2:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8009f7:	eb 42                	jmp    800a3b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8009f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a04:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a12:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a15:	8b 45 14             	mov    0x14(%ebp),%eax
  800a18:	8d 50 04             	lea    0x4(%eax),%edx
  800a1b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a1e:	8b 00                	mov    (%eax),%eax
  800a20:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a25:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800a2a:	eb 0f                	jmp    800a3b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a2c:	89 ca                	mov    %ecx,%edx
  800a2e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a31:	e8 ed fa ff ff       	call   800523 <getuint>
			base = 16;
  800a36:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a3b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800a3f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800a43:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800a46:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a4a:	89 74 24 08          	mov    %esi,0x8(%esp)
  800a4e:	89 04 24             	mov    %eax,(%esp)
  800a51:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a55:	89 da                	mov    %ebx,%edx
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	e8 e9 f9 ff ff       	call   800448 <printnum>
			break;
  800a5f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a62:	e9 5e fb ff ff       	jmp    8005c5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6b:	89 14 24             	mov    %edx,(%esp)
  800a6e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a71:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a74:	e9 4c fb ff ff       	jmp    8005c5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a7d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a84:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a87:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a8b:	0f 84 34 fb ff ff    	je     8005c5 <vprintfmt+0x23>
  800a91:	83 ee 01             	sub    $0x1,%esi
  800a94:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a98:	75 f7                	jne    800a91 <vprintfmt+0x4ef>
  800a9a:	e9 26 fb ff ff       	jmp    8005c5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a9f:	83 c4 5c             	add    $0x5c,%esp
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	83 ec 28             	sub    $0x28,%esp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800abd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ac4:	85 c0                	test   %eax,%eax
  800ac6:	74 30                	je     800af8 <vsnprintf+0x51>
  800ac8:	85 d2                	test   %edx,%edx
  800aca:	7e 2c                	jle    800af8 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800acc:	8b 45 14             	mov    0x14(%ebp),%eax
  800acf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ada:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800add:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae1:	c7 04 24 5d 05 80 00 	movl   $0x80055d,(%esp)
  800ae8:	e8 b5 fa ff ff       	call   8005a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af6:	eb 05                	jmp    800afd <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800af8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b05:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	89 04 24             	mov    %eax,(%esp)
  800b20:	e8 82 ff ff ff       	call   800aa7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    
	...

00800b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b3e:	74 09                	je     800b49 <strlen+0x19>
		n++;
  800b40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b47:	75 f7                	jne    800b40 <strlen+0x10>
		n++;
	return n;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5a:	85 c9                	test   %ecx,%ecx
  800b5c:	74 1a                	je     800b78 <strnlen+0x2d>
  800b5e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b61:	74 15                	je     800b78 <strnlen+0x2d>
  800b63:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b68:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b6a:	39 ca                	cmp    %ecx,%edx
  800b6c:	74 0a                	je     800b78 <strnlen+0x2d>
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b76:	75 f0                	jne    800b68 <strnlen+0x1d>
		n++;
	return n;
}
  800b78:	5b                   	pop    %ebx
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	53                   	push   %ebx
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b8e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b91:	83 c2 01             	add    $0x1,%edx
  800b94:	84 c9                	test   %cl,%cl
  800b96:	75 f2                	jne    800b8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b98:	5b                   	pop    %ebx
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ba5:	89 1c 24             	mov    %ebx,(%esp)
  800ba8:	e8 83 ff ff ff       	call   800b30 <strlen>
	strcpy(dst + len, src);
  800bad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb4:	01 d8                	add    %ebx,%eax
  800bb6:	89 04 24             	mov    %eax,(%esp)
  800bb9:	e8 bd ff ff ff       	call   800b7b <strcpy>
	return dst;
}
  800bbe:	89 d8                	mov    %ebx,%eax
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd4:	85 f6                	test   %esi,%esi
  800bd6:	74 18                	je     800bf0 <strncpy+0x2a>
  800bd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bdd:	0f b6 1a             	movzbl (%edx),%ebx
  800be0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be3:	80 3a 01             	cmpb   $0x1,(%edx)
  800be6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be9:	83 c1 01             	add    $0x1,%ecx
  800bec:	39 f1                	cmp    %esi,%ecx
  800bee:	75 ed                	jne    800bdd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c00:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c03:	89 f8                	mov    %edi,%eax
  800c05:	85 f6                	test   %esi,%esi
  800c07:	74 2b                	je     800c34 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c09:	83 fe 01             	cmp    $0x1,%esi
  800c0c:	74 23                	je     800c31 <strlcpy+0x3d>
  800c0e:	0f b6 0b             	movzbl (%ebx),%ecx
  800c11:	84 c9                	test   %cl,%cl
  800c13:	74 1c                	je     800c31 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c15:	83 ee 02             	sub    $0x2,%esi
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c1d:	88 08                	mov    %cl,(%eax)
  800c1f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c22:	39 f2                	cmp    %esi,%edx
  800c24:	74 0b                	je     800c31 <strlcpy+0x3d>
  800c26:	83 c2 01             	add    $0x1,%edx
  800c29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c2d:	84 c9                	test   %cl,%cl
  800c2f:	75 ec                	jne    800c1d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c34:	29 f8                	sub    %edi,%eax
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c41:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c44:	0f b6 01             	movzbl (%ecx),%eax
  800c47:	84 c0                	test   %al,%al
  800c49:	74 16                	je     800c61 <strcmp+0x26>
  800c4b:	3a 02                	cmp    (%edx),%al
  800c4d:	75 12                	jne    800c61 <strcmp+0x26>
		p++, q++;
  800c4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c52:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800c56:	84 c0                	test   %al,%al
  800c58:	74 07                	je     800c61 <strcmp+0x26>
  800c5a:	83 c1 01             	add    $0x1,%ecx
  800c5d:	3a 02                	cmp    (%edx),%al
  800c5f:	74 ee                	je     800c4f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c61:	0f b6 c0             	movzbl %al,%eax
  800c64:	0f b6 12             	movzbl (%edx),%edx
  800c67:	29 d0                	sub    %edx,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	53                   	push   %ebx
  800c6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c75:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c7d:	85 d2                	test   %edx,%edx
  800c7f:	74 28                	je     800ca9 <strncmp+0x3e>
  800c81:	0f b6 01             	movzbl (%ecx),%eax
  800c84:	84 c0                	test   %al,%al
  800c86:	74 24                	je     800cac <strncmp+0x41>
  800c88:	3a 03                	cmp    (%ebx),%al
  800c8a:	75 20                	jne    800cac <strncmp+0x41>
  800c8c:	83 ea 01             	sub    $0x1,%edx
  800c8f:	74 13                	je     800ca4 <strncmp+0x39>
		n--, p++, q++;
  800c91:	83 c1 01             	add    $0x1,%ecx
  800c94:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c97:	0f b6 01             	movzbl (%ecx),%eax
  800c9a:	84 c0                	test   %al,%al
  800c9c:	74 0e                	je     800cac <strncmp+0x41>
  800c9e:	3a 03                	cmp    (%ebx),%al
  800ca0:	74 ea                	je     800c8c <strncmp+0x21>
  800ca2:	eb 08                	jmp    800cac <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ca4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cac:	0f b6 01             	movzbl (%ecx),%eax
  800caf:	0f b6 13             	movzbl (%ebx),%edx
  800cb2:	29 d0                	sub    %edx,%eax
  800cb4:	eb f3                	jmp    800ca9 <strncmp+0x3e>

00800cb6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc0:	0f b6 10             	movzbl (%eax),%edx
  800cc3:	84 d2                	test   %dl,%dl
  800cc5:	74 1c                	je     800ce3 <strchr+0x2d>
		if (*s == c)
  800cc7:	38 ca                	cmp    %cl,%dl
  800cc9:	75 09                	jne    800cd4 <strchr+0x1e>
  800ccb:	eb 1b                	jmp    800ce8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ccd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800cd0:	38 ca                	cmp    %cl,%dl
  800cd2:	74 14                	je     800ce8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cd4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800cd8:	84 d2                	test   %dl,%dl
  800cda:	75 f1                	jne    800ccd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce1:	eb 05                	jmp    800ce8 <strchr+0x32>
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf4:	0f b6 10             	movzbl (%eax),%edx
  800cf7:	84 d2                	test   %dl,%dl
  800cf9:	74 14                	je     800d0f <strfind+0x25>
		if (*s == c)
  800cfb:	38 ca                	cmp    %cl,%dl
  800cfd:	75 06                	jne    800d05 <strfind+0x1b>
  800cff:	eb 0e                	jmp    800d0f <strfind+0x25>
  800d01:	38 ca                	cmp    %cl,%dl
  800d03:	74 0a                	je     800d0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d05:	83 c0 01             	add    $0x1,%eax
  800d08:	0f b6 10             	movzbl (%eax),%edx
  800d0b:	84 d2                	test   %dl,%dl
  800d0d:	75 f2                	jne    800d01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d29:	85 c9                	test   %ecx,%ecx
  800d2b:	74 30                	je     800d5d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d33:	75 25                	jne    800d5a <memset+0x49>
  800d35:	f6 c1 03             	test   $0x3,%cl
  800d38:	75 20                	jne    800d5a <memset+0x49>
		c &= 0xFF;
  800d3a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d3d:	89 d3                	mov    %edx,%ebx
  800d3f:	c1 e3 08             	shl    $0x8,%ebx
  800d42:	89 d6                	mov    %edx,%esi
  800d44:	c1 e6 18             	shl    $0x18,%esi
  800d47:	89 d0                	mov    %edx,%eax
  800d49:	c1 e0 10             	shl    $0x10,%eax
  800d4c:	09 f0                	or     %esi,%eax
  800d4e:	09 d0                	or     %edx,%eax
  800d50:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d52:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d55:	fc                   	cld    
  800d56:	f3 ab                	rep stos %eax,%es:(%edi)
  800d58:	eb 03                	jmp    800d5d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d5a:	fc                   	cld    
  800d5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d5d:	89 f8                	mov    %edi,%eax
  800d5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d68:	89 ec                	mov    %ebp,%esp
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d75:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d81:	39 c6                	cmp    %eax,%esi
  800d83:	73 36                	jae    800dbb <memmove+0x4f>
  800d85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d88:	39 d0                	cmp    %edx,%eax
  800d8a:	73 2f                	jae    800dbb <memmove+0x4f>
		s += n;
		d += n;
  800d8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8f:	f6 c2 03             	test   $0x3,%dl
  800d92:	75 1b                	jne    800daf <memmove+0x43>
  800d94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d9a:	75 13                	jne    800daf <memmove+0x43>
  800d9c:	f6 c1 03             	test   $0x3,%cl
  800d9f:	75 0e                	jne    800daf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800da1:	83 ef 04             	sub    $0x4,%edi
  800da4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800da7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800daa:	fd                   	std    
  800dab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dad:	eb 09                	jmp    800db8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800daf:	83 ef 01             	sub    $0x1,%edi
  800db2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800db5:	fd                   	std    
  800db6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800db8:	fc                   	cld    
  800db9:	eb 20                	jmp    800ddb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dbb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dc1:	75 13                	jne    800dd6 <memmove+0x6a>
  800dc3:	a8 03                	test   $0x3,%al
  800dc5:	75 0f                	jne    800dd6 <memmove+0x6a>
  800dc7:	f6 c1 03             	test   $0x3,%cl
  800dca:	75 0a                	jne    800dd6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dcc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800dcf:	89 c7                	mov    %eax,%edi
  800dd1:	fc                   	cld    
  800dd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dd4:	eb 05                	jmp    800ddb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dd6:	89 c7                	mov    %eax,%edi
  800dd8:	fc                   	cld    
  800dd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ddb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dde:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de1:	89 ec                	mov    %ebp,%esp
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800deb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	89 04 24             	mov    %eax,(%esp)
  800dff:	e8 68 ff ff ff       	call   800d6c <memmove>
}
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e12:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e15:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e1a:	85 ff                	test   %edi,%edi
  800e1c:	74 37                	je     800e55 <memcmp+0x4f>
		if (*s1 != *s2)
  800e1e:	0f b6 03             	movzbl (%ebx),%eax
  800e21:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e24:	83 ef 01             	sub    $0x1,%edi
  800e27:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e2c:	38 c8                	cmp    %cl,%al
  800e2e:	74 1c                	je     800e4c <memcmp+0x46>
  800e30:	eb 10                	jmp    800e42 <memcmp+0x3c>
  800e32:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e37:	83 c2 01             	add    $0x1,%edx
  800e3a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e3e:	38 c8                	cmp    %cl,%al
  800e40:	74 0a                	je     800e4c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e42:	0f b6 c0             	movzbl %al,%eax
  800e45:	0f b6 c9             	movzbl %cl,%ecx
  800e48:	29 c8                	sub    %ecx,%eax
  800e4a:	eb 09                	jmp    800e55 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e4c:	39 fa                	cmp    %edi,%edx
  800e4e:	75 e2                	jne    800e32 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e60:	89 c2                	mov    %eax,%edx
  800e62:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e65:	39 d0                	cmp    %edx,%eax
  800e67:	73 19                	jae    800e82 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e6d:	38 08                	cmp    %cl,(%eax)
  800e6f:	75 06                	jne    800e77 <memfind+0x1d>
  800e71:	eb 0f                	jmp    800e82 <memfind+0x28>
  800e73:	38 08                	cmp    %cl,(%eax)
  800e75:	74 0b                	je     800e82 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e77:	83 c0 01             	add    $0x1,%eax
  800e7a:	39 d0                	cmp    %edx,%eax
  800e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e80:	75 f1                	jne    800e73 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e90:	0f b6 02             	movzbl (%edx),%eax
  800e93:	3c 20                	cmp    $0x20,%al
  800e95:	74 04                	je     800e9b <strtol+0x17>
  800e97:	3c 09                	cmp    $0x9,%al
  800e99:	75 0e                	jne    800ea9 <strtol+0x25>
		s++;
  800e9b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e9e:	0f b6 02             	movzbl (%edx),%eax
  800ea1:	3c 20                	cmp    $0x20,%al
  800ea3:	74 f6                	je     800e9b <strtol+0x17>
  800ea5:	3c 09                	cmp    $0x9,%al
  800ea7:	74 f2                	je     800e9b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ea9:	3c 2b                	cmp    $0x2b,%al
  800eab:	75 0a                	jne    800eb7 <strtol+0x33>
		s++;
  800ead:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb5:	eb 10                	jmp    800ec7 <strtol+0x43>
  800eb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ebc:	3c 2d                	cmp    $0x2d,%al
  800ebe:	75 07                	jne    800ec7 <strtol+0x43>
		s++, neg = 1;
  800ec0:	83 c2 01             	add    $0x1,%edx
  800ec3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ec7:	85 db                	test   %ebx,%ebx
  800ec9:	0f 94 c0             	sete   %al
  800ecc:	74 05                	je     800ed3 <strtol+0x4f>
  800ece:	83 fb 10             	cmp    $0x10,%ebx
  800ed1:	75 15                	jne    800ee8 <strtol+0x64>
  800ed3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ed6:	75 10                	jne    800ee8 <strtol+0x64>
  800ed8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800edc:	75 0a                	jne    800ee8 <strtol+0x64>
		s += 2, base = 16;
  800ede:	83 c2 02             	add    $0x2,%edx
  800ee1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ee6:	eb 13                	jmp    800efb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ee8:	84 c0                	test   %al,%al
  800eea:	74 0f                	je     800efb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800eec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ef1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ef4:	75 05                	jne    800efb <strtol+0x77>
		s++, base = 8;
  800ef6:	83 c2 01             	add    $0x1,%edx
  800ef9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f02:	0f b6 0a             	movzbl (%edx),%ecx
  800f05:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f08:	80 fb 09             	cmp    $0x9,%bl
  800f0b:	77 08                	ja     800f15 <strtol+0x91>
			dig = *s - '0';
  800f0d:	0f be c9             	movsbl %cl,%ecx
  800f10:	83 e9 30             	sub    $0x30,%ecx
  800f13:	eb 1e                	jmp    800f33 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f15:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f18:	80 fb 19             	cmp    $0x19,%bl
  800f1b:	77 08                	ja     800f25 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f1d:	0f be c9             	movsbl %cl,%ecx
  800f20:	83 e9 57             	sub    $0x57,%ecx
  800f23:	eb 0e                	jmp    800f33 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f25:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f28:	80 fb 19             	cmp    $0x19,%bl
  800f2b:	77 14                	ja     800f41 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f2d:	0f be c9             	movsbl %cl,%ecx
  800f30:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f33:	39 f1                	cmp    %esi,%ecx
  800f35:	7d 0e                	jge    800f45 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f37:	83 c2 01             	add    $0x1,%edx
  800f3a:	0f af c6             	imul   %esi,%eax
  800f3d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f3f:	eb c1                	jmp    800f02 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f41:	89 c1                	mov    %eax,%ecx
  800f43:	eb 02                	jmp    800f47 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f45:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f4b:	74 05                	je     800f52 <strtol+0xce>
		*endptr = (char *) s;
  800f4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f50:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f52:	89 ca                	mov    %ecx,%edx
  800f54:	f7 da                	neg    %edx
  800f56:	85 ff                	test   %edi,%edi
  800f58:	0f 45 c2             	cmovne %edx,%eax
}
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f77:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7a:	89 c3                	mov    %eax,%ebx
  800f7c:	89 c7                	mov    %eax,%edi
  800f7e:	89 c6                	mov    %eax,%esi
  800f80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8b:	89 ec                	mov    %ebp,%esp
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa8:	89 d1                	mov    %edx,%ecx
  800faa:	89 d3                	mov    %edx,%ebx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	89 d6                	mov    %edx,%esi
  800fb0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fbb:	89 ec                	mov    %ebp,%esp
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 38             	sub    $0x38,%esp
  800fc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fcb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdb:	89 cb                	mov    %ecx,%ebx
  800fdd:	89 cf                	mov    %ecx,%edi
  800fdf:	89 ce                	mov    %ecx,%esi
  800fe1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	7e 28                	jle    80100f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800feb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801002:	00 
  801003:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  80100a:	e8 21 f3 ff ff       	call   800330 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80100f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801012:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801015:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801018:	89 ec                	mov    %ebp,%esp
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801025:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801028:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102b:	ba 00 00 00 00       	mov    $0x0,%edx
  801030:	b8 02 00 00 00       	mov    $0x2,%eax
  801035:	89 d1                	mov    %edx,%ecx
  801037:	89 d3                	mov    %edx,%ebx
  801039:	89 d7                	mov    %edx,%edi
  80103b:	89 d6                	mov    %edx,%esi
  80103d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80103f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801042:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801045:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801048:	89 ec                	mov    %ebp,%esp
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <sys_yield>:

void
sys_yield(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801055:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801058:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	ba 00 00 00 00       	mov    $0x0,%edx
  801060:	b8 0b 00 00 00       	mov    $0xb,%eax
  801065:	89 d1                	mov    %edx,%ecx
  801067:	89 d3                	mov    %edx,%ebx
  801069:	89 d7                	mov    %edx,%edi
  80106b:	89 d6                	mov    %edx,%esi
  80106d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80106f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801072:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801075:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801078:	89 ec                	mov    %ebp,%esp
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 38             	sub    $0x38,%esp
  801082:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801085:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801088:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108b:	be 00 00 00 00       	mov    $0x0,%esi
  801090:	b8 04 00 00 00       	mov    $0x4,%eax
  801095:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801098:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109b:	8b 55 08             	mov    0x8(%ebp),%edx
  80109e:	89 f7                	mov    %esi,%edi
  8010a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	7e 28                	jle    8010ce <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010aa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  8010b9:	00 
  8010ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c1:	00 
  8010c2:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  8010c9:	e8 62 f2 ff ff       	call   800330 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d7:	89 ec                	mov    %ebp,%esp
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	83 ec 38             	sub    $0x38,%esp
  8010e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8010f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	7e 28                	jle    80112c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801104:	89 44 24 10          	mov    %eax,0x10(%esp)
  801108:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80110f:	00 
  801110:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801127:	e8 04 f2 ff ff       	call   800330 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80112c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80112f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801132:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801135:	89 ec                	mov    %ebp,%esp
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	83 ec 38             	sub    $0x38,%esp
  80113f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801142:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801145:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801148:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114d:	b8 06 00 00 00       	mov    $0x6,%eax
  801152:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801155:	8b 55 08             	mov    0x8(%ebp),%edx
  801158:	89 df                	mov    %ebx,%edi
  80115a:	89 de                	mov    %ebx,%esi
  80115c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80115e:	85 c0                	test   %eax,%eax
  801160:	7e 28                	jle    80118a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801162:	89 44 24 10          	mov    %eax,0x10(%esp)
  801166:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80116d:	00 
  80116e:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  801175:	00 
  801176:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80117d:	00 
  80117e:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801185:	e8 a6 f1 ff ff       	call   800330 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80118a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80118d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801190:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801193:	89 ec                	mov    %ebp,%esp
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	83 ec 38             	sub    $0x38,%esp
  80119d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011a0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011a3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 df                	mov    %ebx,%edi
  8011b8:	89 de                	mov    %ebx,%esi
  8011ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	7e 28                	jle    8011e8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  8011d3:	00 
  8011d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  8011e3:	e8 48 f1 ff ff       	call   800330 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011f1:	89 ec                	mov    %ebp,%esp
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	83 ec 38             	sub    $0x38,%esp
  8011fb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011fe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801201:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
  801209:	b8 09 00 00 00       	mov    $0x9,%eax
  80120e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801211:	8b 55 08             	mov    0x8(%ebp),%edx
  801214:	89 df                	mov    %ebx,%edi
  801216:	89 de                	mov    %ebx,%esi
  801218:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80121a:	85 c0                	test   %eax,%eax
  80121c:	7e 28                	jle    801246 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801222:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801229:	00 
  80122a:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  801231:	00 
  801232:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801239:	00 
  80123a:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801241:	e8 ea f0 ff ff       	call   800330 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801246:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801249:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80124c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80124f:	89 ec                	mov    %ebp,%esp
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 38             	sub    $0x38,%esp
  801259:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80125c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80125f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801262:	bb 00 00 00 00       	mov    $0x0,%ebx
  801267:	b8 0a 00 00 00       	mov    $0xa,%eax
  80126c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126f:	8b 55 08             	mov    0x8(%ebp),%edx
  801272:	89 df                	mov    %ebx,%edi
  801274:	89 de                	mov    %ebx,%esi
  801276:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801278:	85 c0                	test   %eax,%eax
  80127a:	7e 28                	jle    8012a4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80127c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801280:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801287:	00 
  801288:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  80128f:	00 
  801290:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801297:	00 
  801298:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  80129f:	e8 8c f0 ff ff       	call   800330 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ad:	89 ec                	mov    %ebp,%esp
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	83 ec 0c             	sub    $0xc,%esp
  8012b7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012ba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012bd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c0:	be 00 00 00 00       	mov    $0x0,%esi
  8012c5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012e1:	89 ec                	mov    %ebp,%esp
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	83 ec 38             	sub    $0x38,%esp
  8012eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801301:	89 cb                	mov    %ecx,%ebx
  801303:	89 cf                	mov    %ecx,%edi
  801305:	89 ce                	mov    %ecx,%esi
  801307:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801309:	85 c0                	test   %eax,%eax
  80130b:	7e 28                	jle    801335 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80130d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801311:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801318:	00 
  801319:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  801320:	00 
  801321:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801328:	00 
  801329:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801330:	e8 fb ef ff ff       	call   800330 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801335:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801338:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80133b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80133e:	89 ec                	mov    %ebp,%esp
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80134b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80134e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801351:	b9 00 00 00 00       	mov    $0x0,%ecx
  801356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80135b:	8b 55 08             	mov    0x8(%ebp),%edx
  80135e:	89 cb                	mov    %ecx,%ebx
  801360:	89 cf                	mov    %ecx,%edi
  801362:	89 ce                	mov    %ecx,%esi
  801364:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801366:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801369:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80136c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80136f:	89 ec                	mov    %ebp,%esp
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
	...

00801374 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	53                   	push   %ebx
  801378:	83 ec 24             	sub    $0x24,%esp
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80137e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  801380:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801384:	75 1c                	jne    8013a2 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  801386:	c7 44 24 08 6a 2e 80 	movl   $0x802e6a,0x8(%esp)
  80138d:	00 
  80138e:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801395:	00 
  801396:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  80139d:	e8 8e ef ff ff       	call   800330 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  8013a2:	89 d8                	mov    %ebx,%eax
  8013a4:	c1 e8 0c             	shr    $0xc,%eax
  8013a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ae:	f6 c4 08             	test   $0x8,%ah
  8013b1:	0f 84 be 00 00 00    	je     801475 <pgfault+0x101>
  8013b7:	89 d8                	mov    %ebx,%eax
  8013b9:	c1 e8 16             	shr    $0x16,%eax
  8013bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c3:	a8 01                	test   $0x1,%al
  8013c5:	0f 84 aa 00 00 00    	je     801475 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  8013cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013d2:	00 
  8013d3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013da:	00 
  8013db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e2:	e8 95 fc ff ff       	call   80107c <sys_page_alloc>
		if (r < 0)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	79 20                	jns    80140b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  8013eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ef:	c7 44 24 08 a4 2e 80 	movl   $0x802ea4,0x8(%esp)
  8013f6:	00 
  8013f7:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8013fe:	00 
  8013ff:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  801406:	e8 25 ef ff ff       	call   800330 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80140b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801411:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801418:	00 
  801419:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80141d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801424:	e8 bc f9 ff ff       	call   800de5 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801429:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801430:	00 
  801431:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801435:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80143c:	00 
  80143d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801444:	00 
  801445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144c:	e8 8a fc ff ff       	call   8010db <sys_page_map>
		if (r < 0)
  801451:	85 c0                	test   %eax,%eax
  801453:	79 3c                	jns    801491 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  801455:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801459:	c7 44 24 08 cc 2e 80 	movl   $0x802ecc,0x8(%esp)
  801460:	00 
  801461:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801468:	00 
  801469:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  801470:	e8 bb ee ff ff       	call   800330 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801475:	c7 44 24 08 f0 2e 80 	movl   $0x802ef0,0x8(%esp)
  80147c:	00 
  80147d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801484:	00 
  801485:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  80148c:	e8 9f ee ff ff       	call   800330 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801491:	83 c4 24             	add    $0x24,%esp
  801494:	5b                   	pop    %ebx
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	57                   	push   %edi
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014a0:	c7 04 24 74 13 80 00 	movl   $0x801374,(%esp)
  8014a7:	e8 c4 10 00 00       	call   802570 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014ac:	bf 07 00 00 00       	mov    $0x7,%edi
  8014b1:	89 f8                	mov    %edi,%eax
  8014b3:	cd 30                	int    $0x30
  8014b5:	89 c7                	mov    %eax,%edi
  8014b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	79 20                	jns    8014de <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  8014be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c2:	c7 44 24 08 10 2f 80 	movl   $0x802f10,0x8(%esp)
  8014c9:	00 
  8014ca:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8014d1:	00 
  8014d2:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  8014d9:	e8 52 ee ff ff       	call   800330 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  8014de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	75 1c                	jne    801503 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  8014e7:	e8 30 fb ff ff       	call   80101c <sys_getenvid>
  8014ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014f1:	c1 e0 07             	shl    $0x7,%eax
  8014f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014f9:	a3 04 50 80 00       	mov    %eax,0x805004
		//cprintf("child fork ok!\n");
		return 0;
  8014fe:	e9 51 02 00 00       	jmp    801754 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801503:	89 d8                	mov    %ebx,%eax
  801505:	c1 e8 16             	shr    $0x16,%eax
  801508:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80150f:	a8 01                	test   $0x1,%al
  801511:	0f 84 87 01 00 00    	je     80169e <fork+0x207>
  801517:	89 d8                	mov    %ebx,%eax
  801519:	c1 e8 0c             	shr    $0xc,%eax
  80151c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801523:	f6 c2 01             	test   $0x1,%dl
  801526:	0f 84 72 01 00 00    	je     80169e <fork+0x207>
  80152c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801533:	f6 c2 04             	test   $0x4,%dl
  801536:	0f 84 62 01 00 00    	je     80169e <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80153c:	89 c6                	mov    %eax,%esi
  80153e:	c1 e6 0c             	shl    $0xc,%esi
  801541:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801547:	0f 84 51 01 00 00    	je     80169e <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  80154d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801554:	f6 c6 04             	test   $0x4,%dh
  801557:	74 53                	je     8015ac <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801559:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801560:	25 07 0e 00 00       	and    $0xe07,%eax
  801565:	89 44 24 10          	mov    %eax,0x10(%esp)
  801569:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80156d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801570:	89 44 24 08          	mov    %eax,0x8(%esp)
  801574:	89 74 24 04          	mov    %esi,0x4(%esp)
  801578:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157f:	e8 57 fb ff ff       	call   8010db <sys_page_map>
		if (r < 0)
  801584:	85 c0                	test   %eax,%eax
  801586:	0f 89 12 01 00 00    	jns    80169e <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  80158c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801590:	c7 44 24 08 30 2f 80 	movl   $0x802f30,0x8(%esp)
  801597:	00 
  801598:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80159f:	00 
  8015a0:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  8015a7:	e8 84 ed ff ff       	call   800330 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  8015ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015b3:	f6 c2 02             	test   $0x2,%dl
  8015b6:	75 10                	jne    8015c8 <fork+0x131>
  8015b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015bf:	f6 c4 08             	test   $0x8,%ah
  8015c2:	0f 84 8f 00 00 00    	je     801657 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8015c8:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8015cf:	00 
  8015d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e6:	e8 f0 fa ff ff       	call   8010db <sys_page_map>
		if (r < 0)
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	79 20                	jns    80160f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  8015ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f3:	c7 44 24 08 5c 2f 80 	movl   $0x802f5c,0x8(%esp)
  8015fa:	00 
  8015fb:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801602:	00 
  801603:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  80160a:	e8 21 ed ff ff       	call   800330 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80160f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801616:	00 
  801617:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80161b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801622:	00 
  801623:	89 74 24 04          	mov    %esi,0x4(%esp)
  801627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162e:	e8 a8 fa ff ff       	call   8010db <sys_page_map>
		if (r < 0)
  801633:	85 c0                	test   %eax,%eax
  801635:	79 67                	jns    80169e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801637:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80163b:	c7 44 24 08 5c 2f 80 	movl   $0x802f5c,0x8(%esp)
  801642:	00 
  801643:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80164a:	00 
  80164b:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  801652:	e8 d9 ec ff ff       	call   800330 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  801657:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80165e:	00 
  80165f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801666:	89 44 24 08          	mov    %eax,0x8(%esp)
  80166a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801675:	e8 61 fa ff ff       	call   8010db <sys_page_map>
		if (r < 0)
  80167a:	85 c0                	test   %eax,%eax
  80167c:	79 20                	jns    80169e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  80167e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801682:	c7 44 24 08 5c 2f 80 	movl   $0x802f5c,0x8(%esp)
  801689:	00 
  80168a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801691:	00 
  801692:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  801699:	e8 92 ec ff ff       	call   800330 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  80169e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8016a4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8016aa:	0f 85 53 fe ff ff    	jne    801503 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8016b0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016b7:	00 
  8016b8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016bf:	ee 
  8016c0:	89 3c 24             	mov    %edi,(%esp)
  8016c3:	e8 b4 f9 ff ff       	call   80107c <sys_page_alloc>
	if (res < 0)
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	79 20                	jns    8016ec <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  8016cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d0:	c7 44 24 08 80 2f 80 	movl   $0x802f80,0x8(%esp)
  8016d7:	00 
  8016d8:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8016df:	00 
  8016e0:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  8016e7:	e8 44 ec ff ff       	call   800330 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  8016ec:	c7 44 24 04 fc 25 80 	movl   $0x8025fc,0x4(%esp)
  8016f3:	00 
  8016f4:	89 3c 24             	mov    %edi,(%esp)
  8016f7:	e8 57 fb ff ff       	call   801253 <sys_env_set_pgfault_upcall>
	if (res < 0)
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	79 20                	jns    801720 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801700:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801704:	c7 44 24 08 a4 2f 80 	movl   $0x802fa4,0x8(%esp)
  80170b:	00 
  80170c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801713:	00 
  801714:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  80171b:	e8 10 ec ff ff       	call   800330 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801720:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801727:	00 
  801728:	89 3c 24             	mov    %edi,(%esp)
  80172b:	e8 67 fa ff ff       	call   801197 <sys_env_set_status>
	if (res < 0)
  801730:	85 c0                	test   %eax,%eax
  801732:	79 20                	jns    801754 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801734:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801738:	c7 44 24 08 d4 2f 80 	movl   $0x802fd4,0x8(%esp)
  80173f:	00 
  801740:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801747:	00 
  801748:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  80174f:	e8 dc eb ff ff       	call   800330 <_panic>

	return pid;
	//panic("fork not implemented");
}
  801754:	89 f8                	mov    %edi,%eax
  801756:	83 c4 3c             	add    $0x3c,%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5f                   	pop    %edi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <sfork>:

// Challenge!
int
sfork(void)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801764:	c7 44 24 08 8c 2e 80 	movl   $0x802e8c,0x8(%esp)
  80176b:	00 
  80176c:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801773:	00 
  801774:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  80177b:	e8 b0 eb ff ff       	call   800330 <_panic>

00801780 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	05 00 00 00 30       	add    $0x30000000,%eax
  80178b:	c1 e8 0c             	shr    $0xc,%eax
}
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	89 04 24             	mov    %eax,(%esp)
  80179c:	e8 df ff ff ff       	call   801780 <fd2num>
  8017a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8017a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8017b2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8017b7:	a8 01                	test   $0x1,%al
  8017b9:	74 34                	je     8017ef <fd_alloc+0x44>
  8017bb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8017c0:	a8 01                	test   $0x1,%al
  8017c2:	74 32                	je     8017f6 <fd_alloc+0x4b>
  8017c4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8017c9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	c1 ea 16             	shr    $0x16,%edx
  8017d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017d7:	f6 c2 01             	test   $0x1,%dl
  8017da:	74 1f                	je     8017fb <fd_alloc+0x50>
  8017dc:	89 c2                	mov    %eax,%edx
  8017de:	c1 ea 0c             	shr    $0xc,%edx
  8017e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017e8:	f6 c2 01             	test   $0x1,%dl
  8017eb:	75 17                	jne    801804 <fd_alloc+0x59>
  8017ed:	eb 0c                	jmp    8017fb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8017ef:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8017f4:	eb 05                	jmp    8017fb <fd_alloc+0x50>
  8017f6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8017fb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801802:	eb 17                	jmp    80181b <fd_alloc+0x70>
  801804:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801809:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80180e:	75 b9                	jne    8017c9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801810:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801816:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80181b:	5b                   	pop    %ebx
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801824:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801829:	83 fa 1f             	cmp    $0x1f,%edx
  80182c:	77 3f                	ja     80186d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80182e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801834:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801837:	89 d0                	mov    %edx,%eax
  801839:	c1 e8 16             	shr    $0x16,%eax
  80183c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801843:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801848:	f6 c1 01             	test   $0x1,%cl
  80184b:	74 20                	je     80186d <fd_lookup+0x4f>
  80184d:	89 d0                	mov    %edx,%eax
  80184f:	c1 e8 0c             	shr    $0xc,%eax
  801852:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80185e:	f6 c1 01             	test   $0x1,%cl
  801861:	74 0a                	je     80186d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801863:	8b 45 0c             	mov    0xc(%ebp),%eax
  801866:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	53                   	push   %ebx
  801873:	83 ec 14             	sub    $0x14,%esp
  801876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801881:	39 0d 08 40 80 00    	cmp    %ecx,0x804008
  801887:	75 17                	jne    8018a0 <dev_lookup+0x31>
  801889:	eb 07                	jmp    801892 <dev_lookup+0x23>
  80188b:	39 0a                	cmp    %ecx,(%edx)
  80188d:	75 11                	jne    8018a0 <dev_lookup+0x31>
  80188f:	90                   	nop
  801890:	eb 05                	jmp    801897 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801892:	ba 08 40 80 00       	mov    $0x804008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801897:	89 13                	mov    %edx,(%ebx)
			return 0;
  801899:	b8 00 00 00 00       	mov    $0x0,%eax
  80189e:	eb 35                	jmp    8018d5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018a0:	83 c0 01             	add    $0x1,%eax
  8018a3:	8b 14 85 78 30 80 00 	mov    0x803078(,%eax,4),%edx
  8018aa:	85 d2                	test   %edx,%edx
  8018ac:	75 dd                	jne    80188b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8018ae:	a1 04 50 80 00       	mov    0x805004,%eax
  8018b3:	8b 40 48             	mov    0x48(%eax),%eax
  8018b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018be:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  8018c5:	e8 61 eb ff ff       	call   80042b <cprintf>
	*dev = 0;
  8018ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8018d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8018d5:	83 c4 14             	add    $0x14,%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 38             	sub    $0x38,%esp
  8018e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8018e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8018ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018ed:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018f1:	89 3c 24             	mov    %edi,(%esp)
  8018f4:	e8 87 fe ff ff       	call   801780 <fd2num>
  8018f9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8018fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	e8 16 ff ff ff       	call   80181e <fd_lookup>
  801908:	89 c3                	mov    %eax,%ebx
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 05                	js     801913 <fd_close+0x38>
	    || fd != fd2)
  80190e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801911:	74 0e                	je     801921 <fd_close+0x46>
		return (must_exist ? r : 0);
  801913:	89 f0                	mov    %esi,%eax
  801915:	84 c0                	test   %al,%al
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
  80191c:	0f 44 d8             	cmove  %eax,%ebx
  80191f:	eb 3d                	jmp    80195e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801921:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801924:	89 44 24 04          	mov    %eax,0x4(%esp)
  801928:	8b 07                	mov    (%edi),%eax
  80192a:	89 04 24             	mov    %eax,(%esp)
  80192d:	e8 3d ff ff ff       	call   80186f <dev_lookup>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	85 c0                	test   %eax,%eax
  801936:	78 16                	js     80194e <fd_close+0x73>
		if (dev->dev_close)
  801938:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80193b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80193e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801943:	85 c0                	test   %eax,%eax
  801945:	74 07                	je     80194e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801947:	89 3c 24             	mov    %edi,(%esp)
  80194a:	ff d0                	call   *%eax
  80194c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80194e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801952:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801959:	e8 db f7 ff ff       	call   801139 <sys_page_unmap>
	return r;
}
  80195e:	89 d8                	mov    %ebx,%eax
  801960:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801963:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801966:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801969:	89 ec                	mov    %ebp,%esp
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	89 04 24             	mov    %eax,(%esp)
  801980:	e8 99 fe ff ff       	call   80181e <fd_lookup>
  801985:	85 c0                	test   %eax,%eax
  801987:	78 13                	js     80199c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801989:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801990:	00 
  801991:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	e8 3f ff ff ff       	call   8018db <fd_close>
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <close_all>:

void
close_all(void)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8019a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8019aa:	89 1c 24             	mov    %ebx,(%esp)
  8019ad:	e8 bb ff ff ff       	call   80196d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8019b2:	83 c3 01             	add    $0x1,%ebx
  8019b5:	83 fb 20             	cmp    $0x20,%ebx
  8019b8:	75 f0                	jne    8019aa <close_all+0xc>
		close(i);
}
  8019ba:	83 c4 14             	add    $0x14,%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 58             	sub    $0x58,%esp
  8019c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8019d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dc:	89 04 24             	mov    %eax,(%esp)
  8019df:	e8 3a fe ff ff       	call   80181e <fd_lookup>
  8019e4:	89 c3                	mov    %eax,%ebx
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	0f 88 e1 00 00 00    	js     801acf <dup+0x10f>
		return r;
	close(newfdnum);
  8019ee:	89 3c 24             	mov    %edi,(%esp)
  8019f1:	e8 77 ff ff ff       	call   80196d <close>

	newfd = INDEX2FD(newfdnum);
  8019f6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8019fc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8019ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a02:	89 04 24             	mov    %eax,(%esp)
  801a05:	e8 86 fd ff ff       	call   801790 <fd2data>
  801a0a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a0c:	89 34 24             	mov    %esi,(%esp)
  801a0f:	e8 7c fd ff ff       	call   801790 <fd2data>
  801a14:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a17:	89 d8                	mov    %ebx,%eax
  801a19:	c1 e8 16             	shr    $0x16,%eax
  801a1c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a23:	a8 01                	test   $0x1,%al
  801a25:	74 46                	je     801a6d <dup+0xad>
  801a27:	89 d8                	mov    %ebx,%eax
  801a29:	c1 e8 0c             	shr    $0xc,%eax
  801a2c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a33:	f6 c2 01             	test   $0x1,%dl
  801a36:	74 35                	je     801a6d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a38:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a3f:	25 07 0e 00 00       	and    $0xe07,%eax
  801a44:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a56:	00 
  801a57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a62:	e8 74 f6 ff ff       	call   8010db <sys_page_map>
  801a67:	89 c3                	mov    %eax,%ebx
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 3b                	js     801aa8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a70:	89 c2                	mov    %eax,%edx
  801a72:	c1 ea 0c             	shr    $0xc,%edx
  801a75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a7c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a82:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a86:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a91:	00 
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9d:	e8 39 f6 ff ff       	call   8010db <sys_page_map>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	79 25                	jns    801acd <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801aa8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab3:	e8 81 f6 ff ff       	call   801139 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ab8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac6:	e8 6e f6 ff ff       	call   801139 <sys_page_unmap>
	return r;
  801acb:	eb 02                	jmp    801acf <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801acd:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801acf:	89 d8                	mov    %ebx,%eax
  801ad1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ad4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ad7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ada:	89 ec                	mov    %ebp,%esp
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	53                   	push   %ebx
  801ae2:	83 ec 24             	sub    $0x24,%esp
  801ae5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ae8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aef:	89 1c 24             	mov    %ebx,(%esp)
  801af2:	e8 27 fd ff ff       	call   80181e <fd_lookup>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 6d                	js     801b68 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801afb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b05:	8b 00                	mov    (%eax),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 60 fd ff ff       	call   80186f <dev_lookup>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 55                	js     801b68 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b16:	8b 50 08             	mov    0x8(%eax),%edx
  801b19:	83 e2 03             	and    $0x3,%edx
  801b1c:	83 fa 01             	cmp    $0x1,%edx
  801b1f:	75 23                	jne    801b44 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801b21:	a1 04 50 80 00       	mov    0x805004,%eax
  801b26:	8b 40 48             	mov    0x48(%eax),%eax
  801b29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b31:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  801b38:	e8 ee e8 ff ff       	call   80042b <cprintf>
		return -E_INVAL;
  801b3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b42:	eb 24                	jmp    801b68 <read+0x8a>
	}
	if (!dev->dev_read)
  801b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b47:	8b 52 08             	mov    0x8(%edx),%edx
  801b4a:	85 d2                	test   %edx,%edx
  801b4c:	74 15                	je     801b63 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b51:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b58:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	ff d2                	call   *%edx
  801b61:	eb 05                	jmp    801b68 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b63:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801b68:	83 c4 24             	add    $0x24,%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 1c             	sub    $0x1c,%esp
  801b77:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b82:	85 f6                	test   %esi,%esi
  801b84:	74 30                	je     801bb6 <readn+0x48>
  801b86:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b8b:	89 f2                	mov    %esi,%edx
  801b8d:	29 c2                	sub    %eax,%edx
  801b8f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b93:	03 45 0c             	add    0xc(%ebp),%eax
  801b96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9a:	89 3c 24             	mov    %edi,(%esp)
  801b9d:	e8 3c ff ff ff       	call   801ade <read>
		if (m < 0)
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 10                	js     801bb6 <readn+0x48>
			return m;
		if (m == 0)
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	74 0a                	je     801bb4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801baa:	01 c3                	add    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	39 f3                	cmp    %esi,%ebx
  801bb0:	72 d9                	jb     801b8b <readn+0x1d>
  801bb2:	eb 02                	jmp    801bb6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801bb4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801bb6:	83 c4 1c             	add    $0x1c,%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 24             	sub    $0x24,%esp
  801bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcf:	89 1c 24             	mov    %ebx,(%esp)
  801bd2:	e8 47 fc ff ff       	call   80181e <fd_lookup>
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	78 68                	js     801c43 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be5:	8b 00                	mov    (%eax),%eax
  801be7:	89 04 24             	mov    %eax,(%esp)
  801bea:	e8 80 fc ff ff       	call   80186f <dev_lookup>
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	78 50                	js     801c43 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bfa:	75 23                	jne    801c1f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801bfc:	a1 04 50 80 00       	mov    0x805004,%eax
  801c01:	8b 40 48             	mov    0x48(%eax),%eax
  801c04:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0c:	c7 04 24 59 30 80 00 	movl   $0x803059,(%esp)
  801c13:	e8 13 e8 ff ff       	call   80042b <cprintf>
		return -E_INVAL;
  801c18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c1d:	eb 24                	jmp    801c43 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c22:	8b 52 0c             	mov    0xc(%edx),%edx
  801c25:	85 d2                	test   %edx,%edx
  801c27:	74 15                	je     801c3e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c29:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c2c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	ff d2                	call   *%edx
  801c3c:	eb 05                	jmp    801c43 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801c3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801c43:	83 c4 24             	add    $0x24,%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <seek>:

int
seek(int fdnum, off_t offset)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	89 04 24             	mov    %eax,(%esp)
  801c5c:	e8 bd fb ff ff       	call   80181e <fd_lookup>
  801c61:	85 c0                	test   %eax,%eax
  801c63:	78 0e                	js     801c73 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c65:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c68:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 24             	sub    $0x24,%esp
  801c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c86:	89 1c 24             	mov    %ebx,(%esp)
  801c89:	e8 90 fb ff ff       	call   80181e <fd_lookup>
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 61                	js     801cf3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9c:	8b 00                	mov    (%eax),%eax
  801c9e:	89 04 24             	mov    %eax,(%esp)
  801ca1:	e8 c9 fb ff ff       	call   80186f <dev_lookup>
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	78 49                	js     801cf3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801cb1:	75 23                	jne    801cd6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801cb3:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801cb8:	8b 40 48             	mov    0x48(%eax),%eax
  801cbb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc3:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  801cca:	e8 5c e7 ff ff       	call   80042b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801ccf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cd4:	eb 1d                	jmp    801cf3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801cd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd9:	8b 52 18             	mov    0x18(%edx),%edx
  801cdc:	85 d2                	test   %edx,%edx
  801cde:	74 0e                	je     801cee <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ce7:	89 04 24             	mov    %eax,(%esp)
  801cea:	ff d2                	call   *%edx
  801cec:	eb 05                	jmp    801cf3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801cee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801cf3:	83 c4 24             	add    $0x24,%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	53                   	push   %ebx
  801cfd:	83 ec 24             	sub    $0x24,%esp
  801d00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0d:	89 04 24             	mov    %eax,(%esp)
  801d10:	e8 09 fb ff ff       	call   80181e <fd_lookup>
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 52                	js     801d6b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d23:	8b 00                	mov    (%eax),%eax
  801d25:	89 04 24             	mov    %eax,(%esp)
  801d28:	e8 42 fb ff ff       	call   80186f <dev_lookup>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	78 3a                	js     801d6b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d34:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801d38:	74 2c                	je     801d66 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d3a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d3d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d44:	00 00 00 
	stat->st_isdir = 0;
  801d47:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d4e:	00 00 00 
	stat->st_dev = dev;
  801d51:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d5e:	89 14 24             	mov    %edx,(%esp)
  801d61:	ff 50 14             	call   *0x14(%eax)
  801d64:	eb 05                	jmp    801d6b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d6b:	83 c4 24             	add    $0x24,%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 18             	sub    $0x18,%esp
  801d77:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d7a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d84:	00 
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	89 04 24             	mov    %eax,(%esp)
  801d8b:	e8 bc 01 00 00       	call   801f4c <open>
  801d90:	89 c3                	mov    %eax,%ebx
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 1b                	js     801db1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9d:	89 1c 24             	mov    %ebx,(%esp)
  801da0:	e8 54 ff ff ff       	call   801cf9 <fstat>
  801da5:	89 c6                	mov    %eax,%esi
	close(fd);
  801da7:	89 1c 24             	mov    %ebx,(%esp)
  801daa:	e8 be fb ff ff       	call   80196d <close>
	return r;
  801daf:	89 f3                	mov    %esi,%ebx
}
  801db1:	89 d8                	mov    %ebx,%eax
  801db3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801db6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801db9:	89 ec                	mov    %ebp,%esp
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	00 00                	add    %al,(%eax)
	...

00801dc0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 18             	sub    $0x18,%esp
  801dc6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dc9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801dcc:	89 c3                	mov    %eax,%ebx
  801dce:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801dd0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801dd7:	75 11                	jne    801dea <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801dd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801de0:	e8 0c 09 00 00       	call   8026f1 <ipc_find_env>
  801de5:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801dea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801df1:	00 
  801df2:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801df9:	00 
  801dfa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dfe:	a1 00 50 80 00       	mov    0x805000,%eax
  801e03:	89 04 24             	mov    %eax,(%esp)
  801e06:	e8 7b 08 00 00       	call   802686 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801e0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e12:	00 
  801e13:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1e:	e8 fd 07 00 00       	call   802620 <ipc_recv>
}
  801e23:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e26:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e29:	89 ec                	mov    %ebp,%esp
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	53                   	push   %ebx
  801e31:	83 ec 14             	sub    $0x14,%esp
  801e34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e3d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e42:	ba 00 00 00 00       	mov    $0x0,%edx
  801e47:	b8 05 00 00 00       	mov    $0x5,%eax
  801e4c:	e8 6f ff ff ff       	call   801dc0 <fsipc>
  801e51:	85 c0                	test   %eax,%eax
  801e53:	78 2b                	js     801e80 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e55:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e5c:	00 
  801e5d:	89 1c 24             	mov    %ebx,(%esp)
  801e60:	e8 16 ed ff ff       	call   800b7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e65:	a1 80 60 80 00       	mov    0x806080,%eax
  801e6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e70:	a1 84 60 80 00       	mov    0x806084,%eax
  801e75:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e80:	83 c4 14             	add    $0x14,%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801e92:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e97:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9c:	b8 06 00 00 00       	mov    $0x6,%eax
  801ea1:	e8 1a ff ff ff       	call   801dc0 <fsipc>
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	56                   	push   %esi
  801eac:	53                   	push   %ebx
  801ead:	83 ec 10             	sub    $0x10,%esp
  801eb0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	8b 40 0c             	mov    0xc(%eax),%eax
  801eb9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ebe:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ec4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec9:	b8 03 00 00 00       	mov    $0x3,%eax
  801ece:	e8 ed fe ff ff       	call   801dc0 <fsipc>
  801ed3:	89 c3                	mov    %eax,%ebx
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 6a                	js     801f43 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ed9:	39 c6                	cmp    %eax,%esi
  801edb:	73 24                	jae    801f01 <devfile_read+0x59>
  801edd:	c7 44 24 0c 88 30 80 	movl   $0x803088,0xc(%esp)
  801ee4:	00 
  801ee5:	c7 44 24 08 8f 30 80 	movl   $0x80308f,0x8(%esp)
  801eec:	00 
  801eed:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801ef4:	00 
  801ef5:	c7 04 24 a4 30 80 00 	movl   $0x8030a4,(%esp)
  801efc:	e8 2f e4 ff ff       	call   800330 <_panic>
	assert(r <= PGSIZE);
  801f01:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f06:	7e 24                	jle    801f2c <devfile_read+0x84>
  801f08:	c7 44 24 0c af 30 80 	movl   $0x8030af,0xc(%esp)
  801f0f:	00 
  801f10:	c7 44 24 08 8f 30 80 	movl   $0x80308f,0x8(%esp)
  801f17:	00 
  801f18:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801f1f:	00 
  801f20:	c7 04 24 a4 30 80 00 	movl   $0x8030a4,(%esp)
  801f27:	e8 04 e4 ff ff       	call   800330 <_panic>
	memmove(buf, &fsipcbuf, r);
  801f2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f30:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f37:	00 
  801f38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3b:	89 04 24             	mov    %eax,(%esp)
  801f3e:	e8 29 ee ff ff       	call   800d6c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801f43:	89 d8                	mov    %ebx,%eax
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	5b                   	pop    %ebx
  801f49:	5e                   	pop    %esi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	56                   	push   %esi
  801f50:	53                   	push   %ebx
  801f51:	83 ec 20             	sub    $0x20,%esp
  801f54:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f57:	89 34 24             	mov    %esi,(%esp)
  801f5a:	e8 d1 eb ff ff       	call   800b30 <strlen>
		return -E_BAD_PATH;
  801f5f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f64:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f69:	7f 5e                	jg     801fc9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	e8 35 f8 ff ff       	call   8017ab <fd_alloc>
  801f76:	89 c3                	mov    %eax,%ebx
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 4d                	js     801fc9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f80:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f87:	e8 ef eb ff ff       	call   800b7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f97:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9c:	e8 1f fe ff ff       	call   801dc0 <fsipc>
  801fa1:	89 c3                	mov    %eax,%ebx
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	79 15                	jns    801fbc <open+0x70>
		fd_close(fd, 0);
  801fa7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fae:	00 
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	89 04 24             	mov    %eax,(%esp)
  801fb5:	e8 21 f9 ff ff       	call   8018db <fd_close>
		return r;
  801fba:	eb 0d                	jmp    801fc9 <open+0x7d>
	}

	return fd2num(fd);
  801fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbf:	89 04 24             	mov    %eax,(%esp)
  801fc2:	e8 b9 f7 ff ff       	call   801780 <fd2num>
  801fc7:	89 c3                	mov    %eax,%ebx
}
  801fc9:	89 d8                	mov    %ebx,%eax
  801fcb:	83 c4 20             	add    $0x20,%esp
  801fce:	5b                   	pop    %ebx
  801fcf:	5e                   	pop    %esi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
	...

00801fe0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	83 ec 18             	sub    $0x18,%esp
  801fe6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fe9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801fec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff2:	89 04 24             	mov    %eax,(%esp)
  801ff5:	e8 96 f7 ff ff       	call   801790 <fd2data>
  801ffa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ffc:	c7 44 24 04 bb 30 80 	movl   $0x8030bb,0x4(%esp)
  802003:	00 
  802004:	89 34 24             	mov    %esi,(%esp)
  802007:	e8 6f eb ff ff       	call   800b7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80200c:	8b 43 04             	mov    0x4(%ebx),%eax
  80200f:	2b 03                	sub    (%ebx),%eax
  802011:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802017:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80201e:	00 00 00 
	stat->st_dev = &devpipe;
  802021:	c7 86 88 00 00 00 24 	movl   $0x804024,0x88(%esi)
  802028:	40 80 00 
	return 0;
}
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
  802030:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802033:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802036:	89 ec                	mov    %ebp,%esp
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    

0080203a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	53                   	push   %ebx
  80203e:	83 ec 14             	sub    $0x14,%esp
  802041:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802044:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204f:	e8 e5 f0 ff ff       	call   801139 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802054:	89 1c 24             	mov    %ebx,(%esp)
  802057:	e8 34 f7 ff ff       	call   801790 <fd2data>
  80205c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802060:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802067:	e8 cd f0 ff ff       	call   801139 <sys_page_unmap>
}
  80206c:	83 c4 14             	add    $0x14,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    

00802072 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	57                   	push   %edi
  802076:	56                   	push   %esi
  802077:	53                   	push   %ebx
  802078:	83 ec 2c             	sub    $0x2c,%esp
  80207b:	89 c7                	mov    %eax,%edi
  80207d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802080:	a1 04 50 80 00       	mov    0x805004,%eax
  802085:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802088:	89 3c 24             	mov    %edi,(%esp)
  80208b:	e8 ac 06 00 00       	call   80273c <pageref>
  802090:	89 c6                	mov    %eax,%esi
  802092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802095:	89 04 24             	mov    %eax,(%esp)
  802098:	e8 9f 06 00 00       	call   80273c <pageref>
  80209d:	39 c6                	cmp    %eax,%esi
  80209f:	0f 94 c0             	sete   %al
  8020a2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020a5:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8020ab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020ae:	39 cb                	cmp    %ecx,%ebx
  8020b0:	75 08                	jne    8020ba <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8020b2:	83 c4 2c             	add    $0x2c,%esp
  8020b5:	5b                   	pop    %ebx
  8020b6:	5e                   	pop    %esi
  8020b7:	5f                   	pop    %edi
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8020ba:	83 f8 01             	cmp    $0x1,%eax
  8020bd:	75 c1                	jne    802080 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020bf:	8b 52 58             	mov    0x58(%edx),%edx
  8020c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020ce:	c7 04 24 c2 30 80 00 	movl   $0x8030c2,(%esp)
  8020d5:	e8 51 e3 ff ff       	call   80042b <cprintf>
  8020da:	eb a4                	jmp    802080 <_pipeisclosed+0xe>

008020dc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	57                   	push   %edi
  8020e0:	56                   	push   %esi
  8020e1:	53                   	push   %ebx
  8020e2:	83 ec 2c             	sub    $0x2c,%esp
  8020e5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020e8:	89 34 24             	mov    %esi,(%esp)
  8020eb:	e8 a0 f6 ff ff       	call   801790 <fd2data>
  8020f0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8020f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020fb:	75 50                	jne    80214d <devpipe_write+0x71>
  8020fd:	eb 5c                	jmp    80215b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020ff:	89 da                	mov    %ebx,%edx
  802101:	89 f0                	mov    %esi,%eax
  802103:	e8 6a ff ff ff       	call   802072 <_pipeisclosed>
  802108:	85 c0                	test   %eax,%eax
  80210a:	75 53                	jne    80215f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80210c:	e8 3b ef ff ff       	call   80104c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802111:	8b 43 04             	mov    0x4(%ebx),%eax
  802114:	8b 13                	mov    (%ebx),%edx
  802116:	83 c2 20             	add    $0x20,%edx
  802119:	39 d0                	cmp    %edx,%eax
  80211b:	73 e2                	jae    8020ff <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80211d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802120:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802124:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802127:	89 c2                	mov    %eax,%edx
  802129:	c1 fa 1f             	sar    $0x1f,%edx
  80212c:	c1 ea 1b             	shr    $0x1b,%edx
  80212f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802132:	83 e1 1f             	and    $0x1f,%ecx
  802135:	29 d1                	sub    %edx,%ecx
  802137:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80213b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80213f:	83 c0 01             	add    $0x1,%eax
  802142:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802145:	83 c7 01             	add    $0x1,%edi
  802148:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80214b:	74 0e                	je     80215b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80214d:	8b 43 04             	mov    0x4(%ebx),%eax
  802150:	8b 13                	mov    (%ebx),%edx
  802152:	83 c2 20             	add    $0x20,%edx
  802155:	39 d0                	cmp    %edx,%eax
  802157:	73 a6                	jae    8020ff <devpipe_write+0x23>
  802159:	eb c2                	jmp    80211d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80215b:	89 f8                	mov    %edi,%eax
  80215d:	eb 05                	jmp    802164 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80215f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802164:	83 c4 2c             	add    $0x2c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    

0080216c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	83 ec 28             	sub    $0x28,%esp
  802172:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802175:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802178:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80217b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80217e:	89 3c 24             	mov    %edi,(%esp)
  802181:	e8 0a f6 ff ff       	call   801790 <fd2data>
  802186:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802188:	be 00 00 00 00       	mov    $0x0,%esi
  80218d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802191:	75 47                	jne    8021da <devpipe_read+0x6e>
  802193:	eb 52                	jmp    8021e7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802195:	89 f0                	mov    %esi,%eax
  802197:	eb 5e                	jmp    8021f7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802199:	89 da                	mov    %ebx,%edx
  80219b:	89 f8                	mov    %edi,%eax
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	e8 cd fe ff ff       	call   802072 <_pipeisclosed>
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	75 49                	jne    8021f2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8021a9:	e8 9e ee ff ff       	call   80104c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021ae:	8b 03                	mov    (%ebx),%eax
  8021b0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021b3:	74 e4                	je     802199 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021b5:	89 c2                	mov    %eax,%edx
  8021b7:	c1 fa 1f             	sar    $0x1f,%edx
  8021ba:	c1 ea 1b             	shr    $0x1b,%edx
  8021bd:	01 d0                	add    %edx,%eax
  8021bf:	83 e0 1f             	and    $0x1f,%eax
  8021c2:	29 d0                	sub    %edx,%eax
  8021c4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8021c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021cc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8021cf:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021d2:	83 c6 01             	add    $0x1,%esi
  8021d5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021d8:	74 0d                	je     8021e7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  8021da:	8b 03                	mov    (%ebx),%eax
  8021dc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021df:	75 d4                	jne    8021b5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021e1:	85 f6                	test   %esi,%esi
  8021e3:	75 b0                	jne    802195 <devpipe_read+0x29>
  8021e5:	eb b2                	jmp    802199 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021e7:	89 f0                	mov    %esi,%eax
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	eb 05                	jmp    8021f7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021f2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8021fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8021fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802200:	89 ec                	mov    %ebp,%esp
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    

00802204 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	83 ec 48             	sub    $0x48,%esp
  80220a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80220d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802210:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802213:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802216:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802219:	89 04 24             	mov    %eax,(%esp)
  80221c:	e8 8a f5 ff ff       	call   8017ab <fd_alloc>
  802221:	89 c3                	mov    %eax,%ebx
  802223:	85 c0                	test   %eax,%eax
  802225:	0f 88 45 01 00 00    	js     802370 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802232:	00 
  802233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802241:	e8 36 ee ff ff       	call   80107c <sys_page_alloc>
  802246:	89 c3                	mov    %eax,%ebx
  802248:	85 c0                	test   %eax,%eax
  80224a:	0f 88 20 01 00 00    	js     802370 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802250:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802253:	89 04 24             	mov    %eax,(%esp)
  802256:	e8 50 f5 ff ff       	call   8017ab <fd_alloc>
  80225b:	89 c3                	mov    %eax,%ebx
  80225d:	85 c0                	test   %eax,%eax
  80225f:	0f 88 f8 00 00 00    	js     80235d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802265:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80226c:	00 
  80226d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802270:	89 44 24 04          	mov    %eax,0x4(%esp)
  802274:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227b:	e8 fc ed ff ff       	call   80107c <sys_page_alloc>
  802280:	89 c3                	mov    %eax,%ebx
  802282:	85 c0                	test   %eax,%eax
  802284:	0f 88 d3 00 00 00    	js     80235d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80228a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80228d:	89 04 24             	mov    %eax,(%esp)
  802290:	e8 fb f4 ff ff       	call   801790 <fd2data>
  802295:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802297:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80229e:	00 
  80229f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022aa:	e8 cd ed ff ff       	call   80107c <sys_page_alloc>
  8022af:	89 c3                	mov    %eax,%ebx
  8022b1:	85 c0                	test   %eax,%eax
  8022b3:	0f 88 91 00 00 00    	js     80234a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022bc:	89 04 24             	mov    %eax,(%esp)
  8022bf:	e8 cc f4 ff ff       	call   801790 <fd2data>
  8022c4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022cb:	00 
  8022cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022d7:	00 
  8022d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e3:	e8 f3 ed ff ff       	call   8010db <sys_page_map>
  8022e8:	89 c3                	mov    %eax,%ebx
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	78 4c                	js     80233a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022ee:	8b 15 24 40 80 00    	mov    0x804024,%edx
  8022f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022f7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802303:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80230c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80230e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802311:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80231b:	89 04 24             	mov    %eax,(%esp)
  80231e:	e8 5d f4 ff ff       	call   801780 <fd2num>
  802323:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802328:	89 04 24             	mov    %eax,(%esp)
  80232b:	e8 50 f4 ff ff       	call   801780 <fd2num>
  802330:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802333:	bb 00 00 00 00       	mov    $0x0,%ebx
  802338:	eb 36                	jmp    802370 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80233a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802345:	e8 ef ed ff ff       	call   801139 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80234a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80234d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802351:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802358:	e8 dc ed ff ff       	call   801139 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80235d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802360:	89 44 24 04          	mov    %eax,0x4(%esp)
  802364:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236b:	e8 c9 ed ff ff       	call   801139 <sys_page_unmap>
    err:
	return r;
}
  802370:	89 d8                	mov    %ebx,%eax
  802372:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802375:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802378:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80237b:	89 ec                	mov    %ebp,%esp
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    

0080237f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80237f:	55                   	push   %ebp
  802380:	89 e5                	mov    %esp,%ebp
  802382:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80238c:	8b 45 08             	mov    0x8(%ebp),%eax
  80238f:	89 04 24             	mov    %eax,(%esp)
  802392:	e8 87 f4 ff ff       	call   80181e <fd_lookup>
  802397:	85 c0                	test   %eax,%eax
  802399:	78 15                	js     8023b0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80239b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239e:	89 04 24             	mov    %eax,(%esp)
  8023a1:	e8 ea f3 ff ff       	call   801790 <fd2data>
	return _pipeisclosed(fd, p);
  8023a6:	89 c2                	mov    %eax,%edx
  8023a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ab:	e8 c2 fc ff ff       	call   802072 <_pipeisclosed>
}
  8023b0:	c9                   	leave  
  8023b1:	c3                   	ret    
	...

008023c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    

008023ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8023d0:	c7 44 24 04 d5 30 80 	movl   $0x8030d5,0x4(%esp)
  8023d7:	00 
  8023d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023db:	89 04 24             	mov    %eax,(%esp)
  8023de:	e8 98 e7 ff ff       	call   800b7b <strcpy>
	return 0;
}
  8023e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e8:	c9                   	leave  
  8023e9:	c3                   	ret    

008023ea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023ea:	55                   	push   %ebp
  8023eb:	89 e5                	mov    %esp,%ebp
  8023ed:	57                   	push   %edi
  8023ee:	56                   	push   %esi
  8023ef:	53                   	push   %ebx
  8023f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023f6:	be 00 00 00 00       	mov    $0x0,%esi
  8023fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023ff:	74 43                	je     802444 <devcons_write+0x5a>
  802401:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802406:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80240c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80240f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802411:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802414:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802419:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80241c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802420:	03 45 0c             	add    0xc(%ebp),%eax
  802423:	89 44 24 04          	mov    %eax,0x4(%esp)
  802427:	89 3c 24             	mov    %edi,(%esp)
  80242a:	e8 3d e9 ff ff       	call   800d6c <memmove>
		sys_cputs(buf, m);
  80242f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802433:	89 3c 24             	mov    %edi,(%esp)
  802436:	e8 25 eb ff ff       	call   800f60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80243b:	01 de                	add    %ebx,%esi
  80243d:	89 f0                	mov    %esi,%eax
  80243f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802442:	72 c8                	jb     80240c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802444:	89 f0                	mov    %esi,%eax
  802446:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80244c:	5b                   	pop    %ebx
  80244d:	5e                   	pop    %esi
  80244e:	5f                   	pop    %edi
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    

00802451 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802451:	55                   	push   %ebp
  802452:	89 e5                	mov    %esp,%ebp
  802454:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802457:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80245c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802460:	75 07                	jne    802469 <devcons_read+0x18>
  802462:	eb 31                	jmp    802495 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802464:	e8 e3 eb ff ff       	call   80104c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	e8 1a eb ff ff       	call   800f8f <sys_cgetc>
  802475:	85 c0                	test   %eax,%eax
  802477:	74 eb                	je     802464 <devcons_read+0x13>
  802479:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80247b:	85 c0                	test   %eax,%eax
  80247d:	78 16                	js     802495 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80247f:	83 f8 04             	cmp    $0x4,%eax
  802482:	74 0c                	je     802490 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802484:	8b 45 0c             	mov    0xc(%ebp),%eax
  802487:	88 10                	mov    %dl,(%eax)
	return 1;
  802489:	b8 01 00 00 00       	mov    $0x1,%eax
  80248e:	eb 05                	jmp    802495 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802490:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802495:	c9                   	leave  
  802496:	c3                   	ret    

00802497 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802497:	55                   	push   %ebp
  802498:	89 e5                	mov    %esp,%ebp
  80249a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80249d:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8024aa:	00 
  8024ab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024ae:	89 04 24             	mov    %eax,(%esp)
  8024b1:	e8 aa ea ff ff       	call   800f60 <sys_cputs>
}
  8024b6:	c9                   	leave  
  8024b7:	c3                   	ret    

008024b8 <getchar>:

int
getchar(void)
{
  8024b8:	55                   	push   %ebp
  8024b9:	89 e5                	mov    %esp,%ebp
  8024bb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024be:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8024c5:	00 
  8024c6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024d4:	e8 05 f6 ff ff       	call   801ade <read>
	if (r < 0)
  8024d9:	85 c0                	test   %eax,%eax
  8024db:	78 0f                	js     8024ec <getchar+0x34>
		return r;
	if (r < 1)
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	7e 06                	jle    8024e7 <getchar+0x2f>
		return -E_EOF;
	return c;
  8024e1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024e5:	eb 05                	jmp    8024ec <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024e7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024ec:	c9                   	leave  
  8024ed:	c3                   	ret    

008024ee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fe:	89 04 24             	mov    %eax,(%esp)
  802501:	e8 18 f3 ff ff       	call   80181e <fd_lookup>
  802506:	85 c0                	test   %eax,%eax
  802508:	78 11                	js     80251b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80250a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250d:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802513:	39 10                	cmp    %edx,(%eax)
  802515:	0f 94 c0             	sete   %al
  802518:	0f b6 c0             	movzbl %al,%eax
}
  80251b:	c9                   	leave  
  80251c:	c3                   	ret    

0080251d <opencons>:

int
opencons(void)
{
  80251d:	55                   	push   %ebp
  80251e:	89 e5                	mov    %esp,%ebp
  802520:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802526:	89 04 24             	mov    %eax,(%esp)
  802529:	e8 7d f2 ff ff       	call   8017ab <fd_alloc>
  80252e:	85 c0                	test   %eax,%eax
  802530:	78 3c                	js     80256e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802532:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802539:	00 
  80253a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802541:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802548:	e8 2f eb ff ff       	call   80107c <sys_page_alloc>
  80254d:	85 c0                	test   %eax,%eax
  80254f:	78 1d                	js     80256e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802551:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802566:	89 04 24             	mov    %eax,(%esp)
  802569:	e8 12 f2 ff ff       	call   801780 <fd2num>
}
  80256e:	c9                   	leave  
  80256f:	c3                   	ret    

00802570 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802570:	55                   	push   %ebp
  802571:	89 e5                	mov    %esp,%ebp
  802573:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802576:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80257d:	75 3c                	jne    8025bb <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80257f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802586:	00 
  802587:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80258e:	ee 
  80258f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802596:	e8 e1 ea ff ff       	call   80107c <sys_page_alloc>
  80259b:	85 c0                	test   %eax,%eax
  80259d:	79 1c                	jns    8025bb <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  80259f:	c7 44 24 08 e4 30 80 	movl   $0x8030e4,0x8(%esp)
  8025a6:	00 
  8025a7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8025ae:	00 
  8025af:	c7 04 24 48 31 80 00 	movl   $0x803148,(%esp)
  8025b6:	e8 75 dd ff ff       	call   800330 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025be:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8025c3:	c7 44 24 04 fc 25 80 	movl   $0x8025fc,0x4(%esp)
  8025ca:	00 
  8025cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d2:	e8 7c ec ff ff       	call   801253 <sys_env_set_pgfault_upcall>
  8025d7:	85 c0                	test   %eax,%eax
  8025d9:	79 1c                	jns    8025f7 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8025db:	c7 44 24 08 10 31 80 	movl   $0x803110,0x8(%esp)
  8025e2:	00 
  8025e3:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8025ea:	00 
  8025eb:	c7 04 24 48 31 80 00 	movl   $0x803148,(%esp)
  8025f2:	e8 39 dd ff ff       	call   800330 <_panic>
}
  8025f7:	c9                   	leave  
  8025f8:	c3                   	ret    
  8025f9:	00 00                	add    %al,(%eax)
	...

008025fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025fd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802602:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802604:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  802607:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80260b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802610:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802614:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  802616:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802619:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80261a:	83 c4 04             	add    $0x4,%esp
    popfl
  80261d:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  80261e:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  80261f:	c3                   	ret    

00802620 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	56                   	push   %esi
  802624:	53                   	push   %ebx
  802625:	83 ec 10             	sub    $0x10,%esp
  802628:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80262b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80262e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802631:	85 db                	test   %ebx,%ebx
  802633:	74 06                	je     80263b <ipc_recv+0x1b>
  802635:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80263b:	85 f6                	test   %esi,%esi
  80263d:	74 06                	je     802645 <ipc_recv+0x25>
  80263f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802645:	85 c0                	test   %eax,%eax
  802647:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80264c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80264f:	89 04 24             	mov    %eax,(%esp)
  802652:	e8 8e ec ff ff       	call   8012e5 <sys_ipc_recv>
    if (ret) return ret;
  802657:	85 c0                	test   %eax,%eax
  802659:	75 24                	jne    80267f <ipc_recv+0x5f>
    if (from_env_store)
  80265b:	85 db                	test   %ebx,%ebx
  80265d:	74 0a                	je     802669 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80265f:	a1 04 50 80 00       	mov    0x805004,%eax
  802664:	8b 40 74             	mov    0x74(%eax),%eax
  802667:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802669:	85 f6                	test   %esi,%esi
  80266b:	74 0a                	je     802677 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80266d:	a1 04 50 80 00       	mov    0x805004,%eax
  802672:	8b 40 78             	mov    0x78(%eax),%eax
  802675:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802677:	a1 04 50 80 00       	mov    0x805004,%eax
  80267c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80267f:	83 c4 10             	add    $0x10,%esp
  802682:	5b                   	pop    %ebx
  802683:	5e                   	pop    %esi
  802684:	5d                   	pop    %ebp
  802685:	c3                   	ret    

00802686 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802686:	55                   	push   %ebp
  802687:	89 e5                	mov    %esp,%ebp
  802689:	57                   	push   %edi
  80268a:	56                   	push   %esi
  80268b:	53                   	push   %ebx
  80268c:	83 ec 1c             	sub    $0x1c,%esp
  80268f:	8b 75 08             	mov    0x8(%ebp),%esi
  802692:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802695:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802698:	85 db                	test   %ebx,%ebx
  80269a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80269f:	0f 44 d8             	cmove  %eax,%ebx
  8026a2:	eb 2a                	jmp    8026ce <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8026a4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026a7:	74 20                	je     8026c9 <ipc_send+0x43>
  8026a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026ad:	c7 44 24 08 56 31 80 	movl   $0x803156,0x8(%esp)
  8026b4:	00 
  8026b5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8026bc:	00 
  8026bd:	c7 04 24 6d 31 80 00 	movl   $0x80316d,(%esp)
  8026c4:	e8 67 dc ff ff       	call   800330 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8026c9:	e8 7e e9 ff ff       	call   80104c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8026ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8026d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026dd:	89 34 24             	mov    %esi,(%esp)
  8026e0:	e8 cc eb ff ff       	call   8012b1 <sys_ipc_try_send>
  8026e5:	85 c0                	test   %eax,%eax
  8026e7:	75 bb                	jne    8026a4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8026e9:	83 c4 1c             	add    $0x1c,%esp
  8026ec:	5b                   	pop    %ebx
  8026ed:	5e                   	pop    %esi
  8026ee:	5f                   	pop    %edi
  8026ef:	5d                   	pop    %ebp
  8026f0:	c3                   	ret    

008026f1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026f1:	55                   	push   %ebp
  8026f2:	89 e5                	mov    %esp,%ebp
  8026f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8026f7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8026fc:	39 c8                	cmp    %ecx,%eax
  8026fe:	74 19                	je     802719 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802700:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802705:	89 c2                	mov    %eax,%edx
  802707:	c1 e2 07             	shl    $0x7,%edx
  80270a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802710:	8b 52 50             	mov    0x50(%edx),%edx
  802713:	39 ca                	cmp    %ecx,%edx
  802715:	75 14                	jne    80272b <ipc_find_env+0x3a>
  802717:	eb 05                	jmp    80271e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802719:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80271e:	c1 e0 07             	shl    $0x7,%eax
  802721:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802726:	8b 40 40             	mov    0x40(%eax),%eax
  802729:	eb 0e                	jmp    802739 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80272b:	83 c0 01             	add    $0x1,%eax
  80272e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802733:	75 d0                	jne    802705 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802735:	66 b8 00 00          	mov    $0x0,%ax
}
  802739:	5d                   	pop    %ebp
  80273a:	c3                   	ret    
	...

0080273c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80273c:	55                   	push   %ebp
  80273d:	89 e5                	mov    %esp,%ebp
  80273f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802742:	89 d0                	mov    %edx,%eax
  802744:	c1 e8 16             	shr    $0x16,%eax
  802747:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80274e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802753:	f6 c1 01             	test   $0x1,%cl
  802756:	74 1d                	je     802775 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802758:	c1 ea 0c             	shr    $0xc,%edx
  80275b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802762:	f6 c2 01             	test   $0x1,%dl
  802765:	74 0e                	je     802775 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802767:	c1 ea 0c             	shr    $0xc,%edx
  80276a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802771:	ef 
  802772:	0f b7 c0             	movzwl %ax,%eax
}
  802775:	5d                   	pop    %ebp
  802776:	c3                   	ret    
	...

00802780 <__udivdi3>:
  802780:	83 ec 1c             	sub    $0x1c,%esp
  802783:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802787:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80278b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80278f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802793:	89 74 24 10          	mov    %esi,0x10(%esp)
  802797:	8b 74 24 24          	mov    0x24(%esp),%esi
  80279b:	85 ff                	test   %edi,%edi
  80279d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8027a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027a5:	89 cd                	mov    %ecx,%ebp
  8027a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ab:	75 33                	jne    8027e0 <__udivdi3+0x60>
  8027ad:	39 f1                	cmp    %esi,%ecx
  8027af:	77 57                	ja     802808 <__udivdi3+0x88>
  8027b1:	85 c9                	test   %ecx,%ecx
  8027b3:	75 0b                	jne    8027c0 <__udivdi3+0x40>
  8027b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ba:	31 d2                	xor    %edx,%edx
  8027bc:	f7 f1                	div    %ecx
  8027be:	89 c1                	mov    %eax,%ecx
  8027c0:	89 f0                	mov    %esi,%eax
  8027c2:	31 d2                	xor    %edx,%edx
  8027c4:	f7 f1                	div    %ecx
  8027c6:	89 c6                	mov    %eax,%esi
  8027c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027cc:	f7 f1                	div    %ecx
  8027ce:	89 f2                	mov    %esi,%edx
  8027d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027dc:	83 c4 1c             	add    $0x1c,%esp
  8027df:	c3                   	ret    
  8027e0:	31 d2                	xor    %edx,%edx
  8027e2:	31 c0                	xor    %eax,%eax
  8027e4:	39 f7                	cmp    %esi,%edi
  8027e6:	77 e8                	ja     8027d0 <__udivdi3+0x50>
  8027e8:	0f bd cf             	bsr    %edi,%ecx
  8027eb:	83 f1 1f             	xor    $0x1f,%ecx
  8027ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027f2:	75 2c                	jne    802820 <__udivdi3+0xa0>
  8027f4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8027f8:	76 04                	jbe    8027fe <__udivdi3+0x7e>
  8027fa:	39 f7                	cmp    %esi,%edi
  8027fc:	73 d2                	jae    8027d0 <__udivdi3+0x50>
  8027fe:	31 d2                	xor    %edx,%edx
  802800:	b8 01 00 00 00       	mov    $0x1,%eax
  802805:	eb c9                	jmp    8027d0 <__udivdi3+0x50>
  802807:	90                   	nop
  802808:	89 f2                	mov    %esi,%edx
  80280a:	f7 f1                	div    %ecx
  80280c:	31 d2                	xor    %edx,%edx
  80280e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802812:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802816:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80281a:	83 c4 1c             	add    $0x1c,%esp
  80281d:	c3                   	ret    
  80281e:	66 90                	xchg   %ax,%ax
  802820:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802825:	b8 20 00 00 00       	mov    $0x20,%eax
  80282a:	89 ea                	mov    %ebp,%edx
  80282c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802830:	d3 e7                	shl    %cl,%edi
  802832:	89 c1                	mov    %eax,%ecx
  802834:	d3 ea                	shr    %cl,%edx
  802836:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80283b:	09 fa                	or     %edi,%edx
  80283d:	89 f7                	mov    %esi,%edi
  80283f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802843:	89 f2                	mov    %esi,%edx
  802845:	8b 74 24 08          	mov    0x8(%esp),%esi
  802849:	d3 e5                	shl    %cl,%ebp
  80284b:	89 c1                	mov    %eax,%ecx
  80284d:	d3 ef                	shr    %cl,%edi
  80284f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802854:	d3 e2                	shl    %cl,%edx
  802856:	89 c1                	mov    %eax,%ecx
  802858:	d3 ee                	shr    %cl,%esi
  80285a:	09 d6                	or     %edx,%esi
  80285c:	89 fa                	mov    %edi,%edx
  80285e:	89 f0                	mov    %esi,%eax
  802860:	f7 74 24 0c          	divl   0xc(%esp)
  802864:	89 d7                	mov    %edx,%edi
  802866:	89 c6                	mov    %eax,%esi
  802868:	f7 e5                	mul    %ebp
  80286a:	39 d7                	cmp    %edx,%edi
  80286c:	72 22                	jb     802890 <__udivdi3+0x110>
  80286e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802872:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802877:	d3 e5                	shl    %cl,%ebp
  802879:	39 c5                	cmp    %eax,%ebp
  80287b:	73 04                	jae    802881 <__udivdi3+0x101>
  80287d:	39 d7                	cmp    %edx,%edi
  80287f:	74 0f                	je     802890 <__udivdi3+0x110>
  802881:	89 f0                	mov    %esi,%eax
  802883:	31 d2                	xor    %edx,%edx
  802885:	e9 46 ff ff ff       	jmp    8027d0 <__udivdi3+0x50>
  80288a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802890:	8d 46 ff             	lea    -0x1(%esi),%eax
  802893:	31 d2                	xor    %edx,%edx
  802895:	8b 74 24 10          	mov    0x10(%esp),%esi
  802899:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80289d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028a1:	83 c4 1c             	add    $0x1c,%esp
  8028a4:	c3                   	ret    
	...

008028b0 <__umoddi3>:
  8028b0:	83 ec 1c             	sub    $0x1c,%esp
  8028b3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8028b7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8028bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8028bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8028c3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8028c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8028cb:	85 ed                	test   %ebp,%ebp
  8028cd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8028d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028d5:	89 cf                	mov    %ecx,%edi
  8028d7:	89 04 24             	mov    %eax,(%esp)
  8028da:	89 f2                	mov    %esi,%edx
  8028dc:	75 1a                	jne    8028f8 <__umoddi3+0x48>
  8028de:	39 f1                	cmp    %esi,%ecx
  8028e0:	76 4e                	jbe    802930 <__umoddi3+0x80>
  8028e2:	f7 f1                	div    %ecx
  8028e4:	89 d0                	mov    %edx,%eax
  8028e6:	31 d2                	xor    %edx,%edx
  8028e8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028ec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028f0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028f4:	83 c4 1c             	add    $0x1c,%esp
  8028f7:	c3                   	ret    
  8028f8:	39 f5                	cmp    %esi,%ebp
  8028fa:	77 54                	ja     802950 <__umoddi3+0xa0>
  8028fc:	0f bd c5             	bsr    %ebp,%eax
  8028ff:	83 f0 1f             	xor    $0x1f,%eax
  802902:	89 44 24 04          	mov    %eax,0x4(%esp)
  802906:	75 60                	jne    802968 <__umoddi3+0xb8>
  802908:	3b 0c 24             	cmp    (%esp),%ecx
  80290b:	0f 87 07 01 00 00    	ja     802a18 <__umoddi3+0x168>
  802911:	89 f2                	mov    %esi,%edx
  802913:	8b 34 24             	mov    (%esp),%esi
  802916:	29 ce                	sub    %ecx,%esi
  802918:	19 ea                	sbb    %ebp,%edx
  80291a:	89 34 24             	mov    %esi,(%esp)
  80291d:	8b 04 24             	mov    (%esp),%eax
  802920:	8b 74 24 10          	mov    0x10(%esp),%esi
  802924:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802928:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80292c:	83 c4 1c             	add    $0x1c,%esp
  80292f:	c3                   	ret    
  802930:	85 c9                	test   %ecx,%ecx
  802932:	75 0b                	jne    80293f <__umoddi3+0x8f>
  802934:	b8 01 00 00 00       	mov    $0x1,%eax
  802939:	31 d2                	xor    %edx,%edx
  80293b:	f7 f1                	div    %ecx
  80293d:	89 c1                	mov    %eax,%ecx
  80293f:	89 f0                	mov    %esi,%eax
  802941:	31 d2                	xor    %edx,%edx
  802943:	f7 f1                	div    %ecx
  802945:	8b 04 24             	mov    (%esp),%eax
  802948:	f7 f1                	div    %ecx
  80294a:	eb 98                	jmp    8028e4 <__umoddi3+0x34>
  80294c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802950:	89 f2                	mov    %esi,%edx
  802952:	8b 74 24 10          	mov    0x10(%esp),%esi
  802956:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80295a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80295e:	83 c4 1c             	add    $0x1c,%esp
  802961:	c3                   	ret    
  802962:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802968:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80296d:	89 e8                	mov    %ebp,%eax
  80296f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802974:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802978:	89 fa                	mov    %edi,%edx
  80297a:	d3 e0                	shl    %cl,%eax
  80297c:	89 e9                	mov    %ebp,%ecx
  80297e:	d3 ea                	shr    %cl,%edx
  802980:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802985:	09 c2                	or     %eax,%edx
  802987:	8b 44 24 08          	mov    0x8(%esp),%eax
  80298b:	89 14 24             	mov    %edx,(%esp)
  80298e:	89 f2                	mov    %esi,%edx
  802990:	d3 e7                	shl    %cl,%edi
  802992:	89 e9                	mov    %ebp,%ecx
  802994:	d3 ea                	shr    %cl,%edx
  802996:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80299b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80299f:	d3 e6                	shl    %cl,%esi
  8029a1:	89 e9                	mov    %ebp,%ecx
  8029a3:	d3 e8                	shr    %cl,%eax
  8029a5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029aa:	09 f0                	or     %esi,%eax
  8029ac:	8b 74 24 08          	mov    0x8(%esp),%esi
  8029b0:	f7 34 24             	divl   (%esp)
  8029b3:	d3 e6                	shl    %cl,%esi
  8029b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8029b9:	89 d6                	mov    %edx,%esi
  8029bb:	f7 e7                	mul    %edi
  8029bd:	39 d6                	cmp    %edx,%esi
  8029bf:	89 c1                	mov    %eax,%ecx
  8029c1:	89 d7                	mov    %edx,%edi
  8029c3:	72 3f                	jb     802a04 <__umoddi3+0x154>
  8029c5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029c9:	72 35                	jb     802a00 <__umoddi3+0x150>
  8029cb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029cf:	29 c8                	sub    %ecx,%eax
  8029d1:	19 fe                	sbb    %edi,%esi
  8029d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029d8:	89 f2                	mov    %esi,%edx
  8029da:	d3 e8                	shr    %cl,%eax
  8029dc:	89 e9                	mov    %ebp,%ecx
  8029de:	d3 e2                	shl    %cl,%edx
  8029e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029e5:	09 d0                	or     %edx,%eax
  8029e7:	89 f2                	mov    %esi,%edx
  8029e9:	d3 ea                	shr    %cl,%edx
  8029eb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029ef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029f3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029f7:	83 c4 1c             	add    $0x1c,%esp
  8029fa:	c3                   	ret    
  8029fb:	90                   	nop
  8029fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a00:	39 d6                	cmp    %edx,%esi
  802a02:	75 c7                	jne    8029cb <__umoddi3+0x11b>
  802a04:	89 d7                	mov    %edx,%edi
  802a06:	89 c1                	mov    %eax,%ecx
  802a08:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  802a0c:	1b 3c 24             	sbb    (%esp),%edi
  802a0f:	eb ba                	jmp    8029cb <__umoddi3+0x11b>
  802a11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a18:	39 f5                	cmp    %esi,%ebp
  802a1a:	0f 82 f1 fe ff ff    	jb     802911 <__umoddi3+0x61>
  802a20:	e9 f8 fe ff ff       	jmp    80291d <__umoddi3+0x6d>
