
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 1f 05 00 00       	call   800550 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004d:	89 3c 24             	mov    %edi,(%esp)
  800050:	e8 84 1e 00 00       	call   801ed9 <seek>
	seek(kfd, off);
  800055:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800059:	89 34 24             	mov    %esi,(%esp)
  80005c:	e8 78 1e 00 00       	call   801ed9 <seek>

	cprintf("shell produced incorrect output.\n");
  800061:	c7 04 24 20 32 80 00 	movl   $0x803220,(%esp)
  800068:	e8 4a 06 00 00       	call   8006b7 <cprintf>
	cprintf("expected:\n===\n");
  80006d:	c7 04 24 8b 32 80 00 	movl   $0x80328b,(%esp)
  800074:	e8 3e 06 00 00       	call   8006b7 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800079:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007c:	eb 0c                	jmp    80008a <wrong+0x56>
		sys_cputs(buf, n);
  80007e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800082:	89 1c 24             	mov    %ebx,(%esp)
  800085:	e8 66 11 00 00       	call   8011f0 <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  80008a:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 d0 1c 00 00       	call   801d6e <read>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7f dc                	jg     80007e <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a2:	c7 04 24 9a 32 80 00 	movl   $0x80329a,(%esp)
  8000a9:	e8 09 06 00 00       	call   8006b7 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ae:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b1:	eb 0c                	jmp    8000bf <wrong+0x8b>
		sys_cputs(buf, n);
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 31 11 00 00       	call   8011f0 <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bf:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c6:	00 
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 3c 24             	mov    %edi,(%esp)
  8000ce:	e8 9b 1c 00 00       	call   801d6e <read>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f dc                	jg     8000b3 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d7:	c7 04 24 95 32 80 00 	movl   $0x803295,(%esp)
  8000de:	e8 d4 05 00 00       	call   8006b7 <cprintf>
	exit();
  8000e3:	e8 b8 04 00 00       	call   8005a0 <exit>
}
  8000e8:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 f5 1a 00 00       	call   801bfd <close>
	close(1);
  800108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010f:	e8 e9 1a 00 00       	call   801bfd <close>
	opencons();
  800114:	e8 e4 03 00 00       	call   8004fd <opencons>
	opencons();
  800119:	e8 df 03 00 00       	call   8004fd <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 a8 32 80 00 	movl   $0x8032a8,(%esp)
  80012d:	e8 aa 20 00 00       	call   8021dc <open>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 b5 32 80 	movl   $0x8032b5,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 cb 32 80 00 	movl   $0x8032cb,(%esp)
  800153:	e8 64 04 00 00       	call   8005bc <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800158:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 e1 29 00 00       	call   802b44 <pipe>
  800163:	85 c0                	test   %eax,%eax
  800165:	79 20                	jns    800187 <umain+0x94>
		panic("pipe: %e", wfd);
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	c7 44 24 08 dc 32 80 	movl   $0x8032dc,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 cb 32 80 00 	movl   $0x8032cb,(%esp)
  800182:	e8 35 04 00 00       	call   8005bc <_panic>
	wfd = pfds[1];
  800187:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  80018a:	c7 04 24 44 32 80 00 	movl   $0x803244,(%esp)
  800191:	e8 21 05 00 00       	call   8006b7 <cprintf>
	if ((r = fork()) < 0)
  800196:	e8 8c 15 00 00       	call   801727 <fork>
  80019b:	85 c0                	test   %eax,%eax
  80019d:	79 20                	jns    8001bf <umain+0xcc>
		panic("fork: %e", r);
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	c7 44 24 08 e5 32 80 	movl   $0x8032e5,0x8(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b2:	00 
  8001b3:	c7 04 24 cb 32 80 00 	movl   $0x8032cb,(%esp)
  8001ba:	e8 fd 03 00 00       	call   8005bc <_panic>
	if (r == 0) {
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	0f 85 9f 00 00 00    	jne    800266 <umain+0x173>
		dup(rfd, 0);
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	89 1c 24             	mov    %ebx,(%esp)
  8001d2:	e8 79 1a 00 00       	call   801c50 <dup>
		dup(wfd, 1);
  8001d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001de:	00 
  8001df:	89 34 24             	mov    %esi,(%esp)
  8001e2:	e8 69 1a 00 00       	call   801c50 <dup>
		close(rfd);
  8001e7:	89 1c 24             	mov    %ebx,(%esp)
  8001ea:	e8 0e 1a 00 00       	call   801bfd <close>
		close(wfd);
  8001ef:	89 34 24             	mov    %esi,(%esp)
  8001f2:	e8 06 1a 00 00       	call   801bfd <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 ee 32 80 	movl   $0x8032ee,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 b2 32 80 	movl   $0x8032b2,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 f1 32 80 00 	movl   $0x8032f1,(%esp)
  800216:	e8 69 26 00 00       	call   802884 <spawnl>
  80021b:	89 c7                	mov    %eax,%edi
  80021d:	85 c0                	test   %eax,%eax
  80021f:	79 20                	jns    800241 <umain+0x14e>
			panic("spawn: %e", r);
  800221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800225:	c7 44 24 08 f5 32 80 	movl   $0x8032f5,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 cb 32 80 00 	movl   $0x8032cb,(%esp)
  80023c:	e8 7b 03 00 00       	call   8005bc <_panic>
		close(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 b0 19 00 00       	call   801bfd <close>
		close(1);
  80024d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800254:	e8 a4 19 00 00       	call   801bfd <close>
		wait(r);
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	e8 93 2a 00 00       	call   802cf4 <wait>
		exit();
  800261:	e8 3a 03 00 00       	call   8005a0 <exit>
	}
	close(rfd);
  800266:	89 1c 24             	mov    %ebx,(%esp)
  800269:	e8 8f 19 00 00       	call   801bfd <close>
	close(wfd);
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	e8 87 19 00 00       	call   801bfd <close>

	rfd = pfds[0];
  800276:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800279:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  80027c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800283:	00 
  800284:	c7 04 24 ff 32 80 00 	movl   $0x8032ff,(%esp)
  80028b:	e8 4c 1f 00 00       	call   8021dc <open>
  800290:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800293:	85 c0                	test   %eax,%eax
  800295:	79 20                	jns    8002b7 <umain+0x1c4>
		panic("open testshell.key for reading: %e", kfd);
  800297:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029b:	c7 44 24 08 68 32 80 	movl   $0x803268,0x8(%esp)
  8002a2:	00 
  8002a3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002aa:	00 
  8002ab:	c7 04 24 cb 32 80 00 	movl   $0x8032cb,(%esp)
  8002b2:	e8 05 03 00 00       	call   8005bc <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b7:	bf 01 00 00 00       	mov    $0x1,%edi
  8002bc:	be 00 00 00 00       	mov    $0x0,%esi
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
//cprintf("reading!\n");
		n1 = read(rfd, &c1, 1);
  8002c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c8:	00 
  8002c9:	8d 55 e7             	lea    -0x19(%ebp),%edx
  8002cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	e8 93 1a 00 00       	call   801d6e <read>
  8002db:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002dd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e4:	00 
  8002e5:	8d 55 e6             	lea    -0x1a(%ebp),%edx
  8002e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 77 1a 00 00       	call   801d6e <read>
//cprintf("%c %c\n", c1, c2);
		if (n1 < 0)
  8002f7:	85 db                	test   %ebx,%ebx
  8002f9:	79 20                	jns    80031b <umain+0x228>
			panic("reading testshell.out: %e", n1);
  8002fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ff:	c7 44 24 08 0d 33 80 	movl   $0x80330d,0x8(%esp)
  800306:	00 
  800307:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80030e:	00 
  80030f:	c7 04 24 cb 32 80 00 	movl   $0x8032cb,(%esp)
  800316:	e8 a1 02 00 00       	call   8005bc <_panic>
		if (n2 < 0)
  80031b:	85 c0                	test   %eax,%eax
  80031d:	79 20                	jns    80033f <umain+0x24c>
			panic("reading testshell.key: %e", n2);
  80031f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800323:	c7 44 24 08 27 33 80 	movl   $0x803327,0x8(%esp)
  80032a:	00 
  80032b:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800332:	00 
  800333:	c7 04 24 cb 32 80 00 	movl   $0x8032cb,(%esp)
  80033a:	e8 7d 02 00 00       	call   8005bc <_panic>
		if (n1 == 0 && n2 == 0)
  80033f:	89 c2                	mov    %eax,%edx
  800341:	09 da                	or     %ebx,%edx
  800343:	74 38                	je     80037d <umain+0x28a>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800345:	83 fb 01             	cmp    $0x1,%ebx
  800348:	75 0e                	jne    800358 <umain+0x265>
  80034a:	83 f8 01             	cmp    $0x1,%eax
  80034d:	75 09                	jne    800358 <umain+0x265>
  80034f:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  800353:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800356:	74 16                	je     80036e <umain+0x27b>
			wrong(rfd, kfd, nloff);
  800358:	89 74 24 08          	mov    %esi,0x8(%esp)
  80035c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800363:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800366:	89 14 24             	mov    %edx,(%esp)
  800369:	e8 c6 fc ff ff       	call   800034 <wrong>
		if (c1 == '\n')
			nloff = off+1;
  80036e:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  800372:	0f 44 f7             	cmove  %edi,%esi
  800375:	83 c7 01             	add    $0x1,%edi
	}
  800378:	e9 44 ff ff ff       	jmp    8002c1 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037d:	c7 04 24 41 33 80 00 	movl   $0x803341,(%esp)
  800384:	e8 2e 03 00 00       	call   8006b7 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800389:	cc                   	int3   

	breakpoint();
}
  80038a:	83 c4 3c             	add    $0x3c,%esp
  80038d:	5b                   	pop    %ebx
  80038e:	5e                   	pop    %esi
  80038f:	5f                   	pop    %edi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    
	...

008003a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003b0:	c7 44 24 04 56 33 80 	movl   $0x803356,0x4(%esp)
  8003b7:	00 
  8003b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	e8 48 0a 00 00       	call   800e0b <strcpy>
	return 0;
}
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d6:	be 00 00 00 00       	mov    $0x0,%esi
  8003db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8003df:	74 43                	je     800424 <devcons_write+0x5a>
  8003e1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003e6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8003ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ef:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8003f1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8003f4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8003f9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800400:	03 45 0c             	add    0xc(%ebp),%eax
  800403:	89 44 24 04          	mov    %eax,0x4(%esp)
  800407:	89 3c 24             	mov    %edi,(%esp)
  80040a:	e8 ed 0b 00 00       	call   800ffc <memmove>
		sys_cputs(buf, m);
  80040f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800413:	89 3c 24             	mov    %edi,(%esp)
  800416:	e8 d5 0d 00 00       	call   8011f0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80041b:	01 de                	add    %ebx,%esi
  80041d:	89 f0                	mov    %esi,%eax
  80041f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800422:	72 c8                	jb     8003ec <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800424:	89 f0                	mov    %esi,%eax
  800426:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5e                   	pop    %esi
  80042e:	5f                   	pop    %edi
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80043c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800440:	75 07                	jne    800449 <devcons_read+0x18>
  800442:	eb 31                	jmp    800475 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800444:	e8 93 0e 00 00       	call   8012dc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800450:	e8 ca 0d 00 00       	call   80121f <sys_cgetc>
  800455:	85 c0                	test   %eax,%eax
  800457:	74 eb                	je     800444 <devcons_read+0x13>
  800459:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80045b:	85 c0                	test   %eax,%eax
  80045d:	78 16                	js     800475 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80045f:	83 f8 04             	cmp    $0x4,%eax
  800462:	74 0c                	je     800470 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  800464:	8b 45 0c             	mov    0xc(%ebp),%eax
  800467:	88 10                	mov    %dl,(%eax)
	return 1;
  800469:	b8 01 00 00 00       	mov    $0x1,%eax
  80046e:	eb 05                	jmp    800475 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800475:	c9                   	leave  
  800476:	c3                   	ret    

00800477 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800483:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80048a:	00 
  80048b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	e8 5a 0d 00 00       	call   8011f0 <sys_cputs>
}
  800496:	c9                   	leave  
  800497:	c3                   	ret    

00800498 <getchar>:

int
getchar(void)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80049e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8004a5:	00 
  8004a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8004a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004b4:	e8 b5 18 00 00       	call   801d6e <read>
	if (r < 0)
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	78 0f                	js     8004cc <getchar+0x34>
		return r;
	if (r < 1)
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	7e 06                	jle    8004c7 <getchar+0x2f>
		return -E_EOF;
	return c;
  8004c1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004c5:	eb 05                	jmp    8004cc <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004c7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    

008004ce <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	e8 c8 15 00 00       	call   801aae <fd_lookup>
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	78 11                	js     8004fb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004ed:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004f3:	39 10                	cmp    %edx,(%eax)
  8004f5:	0f 94 c0             	sete   %al
  8004f8:	0f b6 c0             	movzbl %al,%eax
}
  8004fb:	c9                   	leave  
  8004fc:	c3                   	ret    

008004fd <opencons>:

int
opencons(void)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800503:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	e8 2d 15 00 00       	call   801a3b <fd_alloc>
  80050e:	85 c0                	test   %eax,%eax
  800510:	78 3c                	js     80054e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800512:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800519:	00 
  80051a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800528:	e8 df 0d 00 00       	call   80130c <sys_page_alloc>
  80052d:	85 c0                	test   %eax,%eax
  80052f:	78 1d                	js     80054e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800531:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800537:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80053a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80053c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80053f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	e8 c2 14 00 00       	call   801a10 <fd2num>
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 18             	sub    $0x18,%esp
  800556:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800559:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80055c:	8b 75 08             	mov    0x8(%ebp),%esi
  80055f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800562:	e8 45 0d 00 00       	call   8012ac <sys_getenvid>
  800567:	25 ff 03 00 00       	and    $0x3ff,%eax
  80056c:	c1 e0 07             	shl    $0x7,%eax
  80056f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800574:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800579:	85 f6                	test   %esi,%esi
  80057b:	7e 07                	jle    800584 <libmain+0x34>
		binaryname = argv[0];
  80057d:	8b 03                	mov    (%ebx),%eax
  80057f:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800584:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800588:	89 34 24             	mov    %esi,(%esp)
  80058b:	e8 63 fb ff ff       	call   8000f3 <umain>

	// exit gracefully
	exit();
  800590:	e8 0b 00 00 00       	call   8005a0 <exit>
}
  800595:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800598:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80059b:	89 ec                	mov    %ebp,%esp
  80059d:	5d                   	pop    %ebp
  80059e:	c3                   	ret    
	...

008005a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005a6:	e8 83 16 00 00       	call   801c2e <close_all>
	sys_env_destroy(0);
  8005ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005b2:	e8 98 0c 00 00       	call   80124f <sys_env_destroy>
}
  8005b7:	c9                   	leave  
  8005b8:	c3                   	ret    
  8005b9:	00 00                	add    %al,(%eax)
	...

008005bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	56                   	push   %esi
  8005c0:	53                   	push   %ebx
  8005c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005c7:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8005cd:	e8 da 0c 00 00       	call   8012ac <sys_getenvid>
  8005d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8005dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e8:	c7 04 24 6c 33 80 00 	movl   $0x80336c,(%esp)
  8005ef:	e8 c3 00 00 00       	call   8006b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	e8 53 00 00 00       	call   800656 <vcprintf>
	cprintf("\n");
  800603:	c7 04 24 df 36 80 00 	movl   $0x8036df,(%esp)
  80060a:	e8 a8 00 00 00       	call   8006b7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80060f:	cc                   	int3   
  800610:	eb fd                	jmp    80060f <_panic+0x53>
	...

00800614 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	53                   	push   %ebx
  800618:	83 ec 14             	sub    $0x14,%esp
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80061e:	8b 03                	mov    (%ebx),%eax
  800620:	8b 55 08             	mov    0x8(%ebp),%edx
  800623:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800627:	83 c0 01             	add    $0x1,%eax
  80062a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80062c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800631:	75 19                	jne    80064c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800633:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80063a:	00 
  80063b:	8d 43 08             	lea    0x8(%ebx),%eax
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	e8 aa 0b 00 00       	call   8011f0 <sys_cputs>
		b->idx = 0;
  800646:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80064c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800650:	83 c4 14             	add    $0x14,%esp
  800653:	5b                   	pop    %ebx
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80065f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800666:	00 00 00 
	b.cnt = 0;
  800669:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800670:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800673:	8b 45 0c             	mov    0xc(%ebp),%eax
  800676:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800681:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068b:	c7 04 24 14 06 80 00 	movl   $0x800614,(%esp)
  800692:	e8 97 01 00 00       	call   80082e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800697:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	e8 41 0b 00 00       	call   8011f0 <sys_cputs>

	return b.cnt;
}
  8006af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	e8 87 ff ff ff       	call   800656 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    
  8006d1:	00 00                	add    %al,(%eax)
	...

008006d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	57                   	push   %edi
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 3c             	sub    $0x3c,%esp
  8006dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e0:	89 d7                	mov    %edx,%edi
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8006fc:	72 11                	jb     80070f <printnum+0x3b>
  8006fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800701:	39 45 10             	cmp    %eax,0x10(%ebp)
  800704:	76 09                	jbe    80070f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800706:	83 eb 01             	sub    $0x1,%ebx
  800709:	85 db                	test   %ebx,%ebx
  80070b:	7f 51                	jg     80075e <printnum+0x8a>
  80070d:	eb 5e                	jmp    80076d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800713:	83 eb 01             	sub    $0x1,%ebx
  800716:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800721:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800725:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800729:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800730:	00 
  800731:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80073a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073e:	e8 2d 28 00 00       	call   802f70 <__udivdi3>
  800743:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800747:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800752:	89 fa                	mov    %edi,%edx
  800754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800757:	e8 78 ff ff ff       	call   8006d4 <printnum>
  80075c:	eb 0f                	jmp    80076d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80075e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800762:	89 34 24             	mov    %esi,(%esp)
  800765:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800768:	83 eb 01             	sub    $0x1,%ebx
  80076b:	75 f1                	jne    80075e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80076d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800771:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800775:	8b 45 10             	mov    0x10(%ebp),%eax
  800778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800783:	00 
  800784:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	e8 0a 29 00 00       	call   8030a0 <__umoddi3>
  800796:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079a:	0f be 80 8f 33 80 00 	movsbl 0x80338f(%eax),%eax
  8007a1:	89 04 24             	mov    %eax,(%esp)
  8007a4:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007a7:	83 c4 3c             	add    $0x3c,%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b2:	83 fa 01             	cmp    $0x1,%edx
  8007b5:	7e 0e                	jle    8007c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007bc:	89 08                	mov    %ecx,(%eax)
  8007be:	8b 02                	mov    (%edx),%eax
  8007c0:	8b 52 04             	mov    0x4(%edx),%edx
  8007c3:	eb 22                	jmp    8007e7 <getuint+0x38>
	else if (lflag)
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 10                	je     8007d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ce:	89 08                	mov    %ecx,(%eax)
  8007d0:	8b 02                	mov    (%edx),%eax
  8007d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d7:	eb 0e                	jmp    8007e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007d9:	8b 10                	mov    (%eax),%edx
  8007db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007de:	89 08                	mov    %ecx,(%eax)
  8007e0:	8b 02                	mov    (%edx),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8007f8:	73 0a                	jae    800804 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fd:	88 0a                	mov    %cl,(%edx)
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	89 10                	mov    %edx,(%eax)
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80080c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80080f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800813:	8b 45 10             	mov    0x10(%ebp),%eax
  800816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 02 00 00 00       	call   80082e <vprintfmt>
	va_end(ap);
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	57                   	push   %edi
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	83 ec 5c             	sub    $0x5c,%esp
  800837:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083a:	8b 75 10             	mov    0x10(%ebp),%esi
  80083d:	eb 12                	jmp    800851 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80083f:	85 c0                	test   %eax,%eax
  800841:	0f 84 e4 04 00 00    	je     800d2b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800847:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800851:	0f b6 06             	movzbl (%esi),%eax
  800854:	83 c6 01             	add    $0x1,%esi
  800857:	83 f8 25             	cmp    $0x25,%eax
  80085a:	75 e3                	jne    80083f <vprintfmt+0x11>
  80085c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800860:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800867:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80086c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800873:	b9 00 00 00 00       	mov    $0x0,%ecx
  800878:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80087b:	eb 2b                	jmp    8008a8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800880:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800884:	eb 22                	jmp    8008a8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800889:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80088d:	eb 19                	jmp    8008a8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800892:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800899:	eb 0d                	jmp    8008a8 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80089b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80089e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8008a1:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a8:	0f b6 06             	movzbl (%esi),%eax
  8008ab:	0f b6 d0             	movzbl %al,%edx
  8008ae:	8d 7e 01             	lea    0x1(%esi),%edi
  8008b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b4:	83 e8 23             	sub    $0x23,%eax
  8008b7:	3c 55                	cmp    $0x55,%al
  8008b9:	0f 87 46 04 00 00    	ja     800d05 <vprintfmt+0x4d7>
  8008bf:	0f b6 c0             	movzbl %al,%eax
  8008c2:	ff 24 85 e0 34 80 00 	jmp    *0x8034e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008c9:	83 ea 30             	sub    $0x30,%edx
  8008cc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8008cf:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8008d3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8008d9:	83 fa 09             	cmp    $0x9,%edx
  8008dc:	77 4a                	ja     800928 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008de:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008e1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008e4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008e7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008eb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008ee:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008f1:	83 fa 09             	cmp    $0x9,%edx
  8008f4:	76 eb                	jbe    8008e1 <vprintfmt+0xb3>
  8008f6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8008f9:	eb 2d                	jmp    800928 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fe:	8d 50 04             	lea    0x4(%eax),%edx
  800901:	89 55 14             	mov    %edx,0x14(%ebp)
  800904:	8b 00                	mov    (%eax),%eax
  800906:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800909:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80090c:	eb 1a                	jmp    800928 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800911:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800915:	79 91                	jns    8008a8 <vprintfmt+0x7a>
  800917:	e9 73 ff ff ff       	jmp    80088f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80091f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800926:	eb 80                	jmp    8008a8 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800928:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80092c:	0f 89 76 ff ff ff    	jns    8008a8 <vprintfmt+0x7a>
  800932:	e9 64 ff ff ff       	jmp    80089b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800937:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80093d:	e9 66 ff ff ff       	jmp    8008a8 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 50 04             	lea    0x4(%eax),%edx
  800948:	89 55 14             	mov    %edx,0x14(%ebp)
  80094b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	89 04 24             	mov    %eax,(%esp)
  800954:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800957:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80095a:	e9 f2 fe ff ff       	jmp    800851 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80095f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800963:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800966:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80096a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80096d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800971:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800974:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800977:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80097b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80097e:	80 f9 09             	cmp    $0x9,%cl
  800981:	77 1d                	ja     8009a0 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800983:	0f be c0             	movsbl %al,%eax
  800986:	6b c0 64             	imul   $0x64,%eax,%eax
  800989:	0f be d2             	movsbl %dl,%edx
  80098c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80098f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800996:	a3 20 40 80 00       	mov    %eax,0x804020
  80099b:	e9 b1 fe ff ff       	jmp    800851 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8009a0:	c7 44 24 04 a7 33 80 	movl   $0x8033a7,0x4(%esp)
  8009a7:	00 
  8009a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009ab:	89 04 24             	mov    %eax,(%esp)
  8009ae:	e8 18 05 00 00       	call   800ecb <strcmp>
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	75 0f                	jne    8009c6 <vprintfmt+0x198>
  8009b7:	c7 05 20 40 80 00 04 	movl   $0x4,0x804020
  8009be:	00 00 00 
  8009c1:	e9 8b fe ff ff       	jmp    800851 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8009c6:	c7 44 24 04 ab 33 80 	movl   $0x8033ab,0x4(%esp)
  8009cd:	00 
  8009ce:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8009d1:	89 14 24             	mov    %edx,(%esp)
  8009d4:	e8 f2 04 00 00       	call   800ecb <strcmp>
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	75 0f                	jne    8009ec <vprintfmt+0x1be>
  8009dd:	c7 05 20 40 80 00 02 	movl   $0x2,0x804020
  8009e4:	00 00 00 
  8009e7:	e9 65 fe ff ff       	jmp    800851 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8009ec:	c7 44 24 04 af 33 80 	movl   $0x8033af,0x4(%esp)
  8009f3:	00 
  8009f4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8009f7:	89 0c 24             	mov    %ecx,(%esp)
  8009fa:	e8 cc 04 00 00       	call   800ecb <strcmp>
  8009ff:	85 c0                	test   %eax,%eax
  800a01:	75 0f                	jne    800a12 <vprintfmt+0x1e4>
  800a03:	c7 05 20 40 80 00 01 	movl   $0x1,0x804020
  800a0a:	00 00 00 
  800a0d:	e9 3f fe ff ff       	jmp    800851 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800a12:	c7 44 24 04 b3 33 80 	movl   $0x8033b3,0x4(%esp)
  800a19:	00 
  800a1a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800a1d:	89 3c 24             	mov    %edi,(%esp)
  800a20:	e8 a6 04 00 00       	call   800ecb <strcmp>
  800a25:	85 c0                	test   %eax,%eax
  800a27:	75 0f                	jne    800a38 <vprintfmt+0x20a>
  800a29:	c7 05 20 40 80 00 06 	movl   $0x6,0x804020
  800a30:	00 00 00 
  800a33:	e9 19 fe ff ff       	jmp    800851 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800a38:	c7 44 24 04 b7 33 80 	movl   $0x8033b7,0x4(%esp)
  800a3f:	00 
  800a40:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a43:	89 04 24             	mov    %eax,(%esp)
  800a46:	e8 80 04 00 00       	call   800ecb <strcmp>
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	75 0f                	jne    800a5e <vprintfmt+0x230>
  800a4f:	c7 05 20 40 80 00 07 	movl   $0x7,0x804020
  800a56:	00 00 00 
  800a59:	e9 f3 fd ff ff       	jmp    800851 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800a5e:	c7 44 24 04 bb 33 80 	movl   $0x8033bb,0x4(%esp)
  800a65:	00 
  800a66:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800a69:	89 14 24             	mov    %edx,(%esp)
  800a6c:	e8 5a 04 00 00       	call   800ecb <strcmp>
  800a71:	83 f8 01             	cmp    $0x1,%eax
  800a74:	19 c0                	sbb    %eax,%eax
  800a76:	f7 d0                	not    %eax
  800a78:	83 c0 08             	add    $0x8,%eax
  800a7b:	a3 20 40 80 00       	mov    %eax,0x804020
  800a80:	e9 cc fd ff ff       	jmp    800851 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	8d 50 04             	lea    0x4(%eax),%edx
  800a8b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8e:	8b 00                	mov    (%eax),%eax
  800a90:	89 c2                	mov    %eax,%edx
  800a92:	c1 fa 1f             	sar    $0x1f,%edx
  800a95:	31 d0                	xor    %edx,%eax
  800a97:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a99:	83 f8 0f             	cmp    $0xf,%eax
  800a9c:	7f 0b                	jg     800aa9 <vprintfmt+0x27b>
  800a9e:	8b 14 85 40 36 80 00 	mov    0x803640(,%eax,4),%edx
  800aa5:	85 d2                	test   %edx,%edx
  800aa7:	75 23                	jne    800acc <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800aa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aad:	c7 44 24 08 bf 33 80 	movl   $0x8033bf,0x8(%esp)
  800ab4:	00 
  800ab5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abc:	89 3c 24             	mov    %edi,(%esp)
  800abf:	e8 42 fd ff ff       	call   800806 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ac7:	e9 85 fd ff ff       	jmp    800851 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800acc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad0:	c7 44 24 08 01 39 80 	movl   $0x803901,0x8(%esp)
  800ad7:	00 
  800ad8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800adc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adf:	89 3c 24             	mov    %edi,(%esp)
  800ae2:	e8 1f fd ff ff       	call   800806 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800aea:	e9 62 fd ff ff       	jmp    800851 <vprintfmt+0x23>
  800aef:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800af2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800af5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800af8:	8b 45 14             	mov    0x14(%ebp),%eax
  800afb:	8d 50 04             	lea    0x4(%eax),%edx
  800afe:	89 55 14             	mov    %edx,0x14(%ebp)
  800b01:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800b03:	85 f6                	test   %esi,%esi
  800b05:	b8 a0 33 80 00       	mov    $0x8033a0,%eax
  800b0a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800b0d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800b11:	7e 06                	jle    800b19 <vprintfmt+0x2eb>
  800b13:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800b17:	75 13                	jne    800b2c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b19:	0f be 06             	movsbl (%esi),%eax
  800b1c:	83 c6 01             	add    $0x1,%esi
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	0f 85 94 00 00 00    	jne    800bbb <vprintfmt+0x38d>
  800b27:	e9 81 00 00 00       	jmp    800bad <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b30:	89 34 24             	mov    %esi,(%esp)
  800b33:	e8 a3 02 00 00       	call   800ddb <strnlen>
  800b38:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800b3b:	29 c2                	sub    %eax,%edx
  800b3d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800b40:	85 d2                	test   %edx,%edx
  800b42:	7e d5                	jle    800b19 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800b44:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b48:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800b4b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	89 cf                	mov    %ecx,%edi
  800b52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b56:	89 3c 24             	mov    %edi,(%esp)
  800b59:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b5c:	83 ee 01             	sub    $0x1,%esi
  800b5f:	75 f1                	jne    800b52 <vprintfmt+0x324>
  800b61:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800b64:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800b67:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800b6a:	eb ad                	jmp    800b19 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b6c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800b70:	74 1b                	je     800b8d <vprintfmt+0x35f>
  800b72:	8d 50 e0             	lea    -0x20(%eax),%edx
  800b75:	83 fa 5e             	cmp    $0x5e,%edx
  800b78:	76 13                	jbe    800b8d <vprintfmt+0x35f>
					putch('?', putdat);
  800b7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b81:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b88:	ff 55 08             	call   *0x8(%ebp)
  800b8b:	eb 0d                	jmp    800b9a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800b8d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800b90:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b94:	89 04 24             	mov    %eax,(%esp)
  800b97:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b9a:	83 eb 01             	sub    $0x1,%ebx
  800b9d:	0f be 06             	movsbl (%esi),%eax
  800ba0:	83 c6 01             	add    $0x1,%esi
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	75 1a                	jne    800bc1 <vprintfmt+0x393>
  800ba7:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800baa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bb0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800bb4:	7f 1c                	jg     800bd2 <vprintfmt+0x3a4>
  800bb6:	e9 96 fc ff ff       	jmp    800851 <vprintfmt+0x23>
  800bbb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800bbe:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc1:	85 ff                	test   %edi,%edi
  800bc3:	78 a7                	js     800b6c <vprintfmt+0x33e>
  800bc5:	83 ef 01             	sub    $0x1,%edi
  800bc8:	79 a2                	jns    800b6c <vprintfmt+0x33e>
  800bca:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800bcd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bd0:	eb db                	jmp    800bad <vprintfmt+0x37f>
  800bd2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd5:	89 de                	mov    %ebx,%esi
  800bd7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bda:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bde:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800be5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800be7:	83 eb 01             	sub    $0x1,%ebx
  800bea:	75 ee                	jne    800bda <vprintfmt+0x3ac>
  800bec:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800bf1:	e9 5b fc ff ff       	jmp    800851 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bf6:	83 f9 01             	cmp    $0x1,%ecx
  800bf9:	7e 10                	jle    800c0b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800bfb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfe:	8d 50 08             	lea    0x8(%eax),%edx
  800c01:	89 55 14             	mov    %edx,0x14(%ebp)
  800c04:	8b 30                	mov    (%eax),%esi
  800c06:	8b 78 04             	mov    0x4(%eax),%edi
  800c09:	eb 26                	jmp    800c31 <vprintfmt+0x403>
	else if (lflag)
  800c0b:	85 c9                	test   %ecx,%ecx
  800c0d:	74 12                	je     800c21 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800c0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c12:	8d 50 04             	lea    0x4(%eax),%edx
  800c15:	89 55 14             	mov    %edx,0x14(%ebp)
  800c18:	8b 30                	mov    (%eax),%esi
  800c1a:	89 f7                	mov    %esi,%edi
  800c1c:	c1 ff 1f             	sar    $0x1f,%edi
  800c1f:	eb 10                	jmp    800c31 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800c21:	8b 45 14             	mov    0x14(%ebp),%eax
  800c24:	8d 50 04             	lea    0x4(%eax),%edx
  800c27:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2a:	8b 30                	mov    (%eax),%esi
  800c2c:	89 f7                	mov    %esi,%edi
  800c2e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c31:	85 ff                	test   %edi,%edi
  800c33:	78 0e                	js     800c43 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c35:	89 f0                	mov    %esi,%eax
  800c37:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c39:	be 0a 00 00 00       	mov    $0xa,%esi
  800c3e:	e9 84 00 00 00       	jmp    800cc7 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800c43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c47:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c4e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c51:	89 f0                	mov    %esi,%eax
  800c53:	89 fa                	mov    %edi,%edx
  800c55:	f7 d8                	neg    %eax
  800c57:	83 d2 00             	adc    $0x0,%edx
  800c5a:	f7 da                	neg    %edx
			}
			base = 10;
  800c5c:	be 0a 00 00 00       	mov    $0xa,%esi
  800c61:	eb 64                	jmp    800cc7 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c63:	89 ca                	mov    %ecx,%edx
  800c65:	8d 45 14             	lea    0x14(%ebp),%eax
  800c68:	e8 42 fb ff ff       	call   8007af <getuint>
			base = 10;
  800c6d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800c72:	eb 53                	jmp    800cc7 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800c74:	89 ca                	mov    %ecx,%edx
  800c76:	8d 45 14             	lea    0x14(%ebp),%eax
  800c79:	e8 31 fb ff ff       	call   8007af <getuint>
    			base = 8;
  800c7e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800c83:	eb 42                	jmp    800cc7 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800c85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c89:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c90:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800c93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c97:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c9e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ca1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca4:	8d 50 04             	lea    0x4(%eax),%edx
  800ca7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800caa:	8b 00                	mov    (%eax),%eax
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cb1:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800cb6:	eb 0f                	jmp    800cc7 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cb8:	89 ca                	mov    %ecx,%edx
  800cba:	8d 45 14             	lea    0x14(%ebp),%eax
  800cbd:	e8 ed fa ff ff       	call   8007af <getuint>
			base = 16;
  800cc2:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cc7:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800ccb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ccf:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800cd2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cd6:	89 74 24 08          	mov    %esi,0x8(%esp)
  800cda:	89 04 24             	mov    %eax,(%esp)
  800cdd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ce1:	89 da                	mov    %ebx,%edx
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	e8 e9 f9 ff ff       	call   8006d4 <printnum>
			break;
  800ceb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800cee:	e9 5e fb ff ff       	jmp    800851 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cf7:	89 14 24             	mov    %edx,(%esp)
  800cfa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cfd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d00:	e9 4c fb ff ff       	jmp    800851 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d09:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d10:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d13:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800d17:	0f 84 34 fb ff ff    	je     800851 <vprintfmt+0x23>
  800d1d:	83 ee 01             	sub    $0x1,%esi
  800d20:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800d24:	75 f7                	jne    800d1d <vprintfmt+0x4ef>
  800d26:	e9 26 fb ff ff       	jmp    800851 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800d2b:	83 c4 5c             	add    $0x5c,%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 28             	sub    $0x28,%esp
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d42:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d46:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	74 30                	je     800d84 <vsnprintf+0x51>
  800d54:	85 d2                	test   %edx,%edx
  800d56:	7e 2c                	jle    800d84 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d58:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d66:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6d:	c7 04 24 e9 07 80 00 	movl   $0x8007e9,(%esp)
  800d74:	e8 b5 fa ff ff       	call   80082e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d7c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d82:	eb 05                	jmp    800d89 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d91:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d98:	8b 45 10             	mov    0x10(%ebp),%eax
  800d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	89 04 24             	mov    %eax,(%esp)
  800dac:	e8 82 ff ff ff       	call   800d33 <vsnprintf>
	va_end(ap);

	return rc;
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    
	...

00800dc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800dce:	74 09                	je     800dd9 <strlen+0x19>
		n++;
  800dd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dd7:	75 f7                	jne    800dd0 <strlen+0x10>
		n++;
	return n;
}
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800de5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dea:	85 c9                	test   %ecx,%ecx
  800dec:	74 1a                	je     800e08 <strnlen+0x2d>
  800dee:	80 3b 00             	cmpb   $0x0,(%ebx)
  800df1:	74 15                	je     800e08 <strnlen+0x2d>
  800df3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800df8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dfa:	39 ca                	cmp    %ecx,%edx
  800dfc:	74 0a                	je     800e08 <strnlen+0x2d>
  800dfe:	83 c2 01             	add    $0x1,%edx
  800e01:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800e06:	75 f0                	jne    800df8 <strnlen+0x1d>
		n++;
	return n;
}
  800e08:	5b                   	pop    %ebx
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	53                   	push   %ebx
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e15:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e1e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e21:	83 c2 01             	add    $0x1,%edx
  800e24:	84 c9                	test   %cl,%cl
  800e26:	75 f2                	jne    800e1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e28:	5b                   	pop    %ebx
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e35:	89 1c 24             	mov    %ebx,(%esp)
  800e38:	e8 83 ff ff ff       	call   800dc0 <strlen>
	strcpy(dst + len, src);
  800e3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e40:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e44:	01 d8                	add    %ebx,%eax
  800e46:	89 04 24             	mov    %eax,(%esp)
  800e49:	e8 bd ff ff ff       	call   800e0b <strcpy>
	return dst;
}
  800e4e:	89 d8                	mov    %ebx,%eax
  800e50:	83 c4 08             	add    $0x8,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e64:	85 f6                	test   %esi,%esi
  800e66:	74 18                	je     800e80 <strncpy+0x2a>
  800e68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e6d:	0f b6 1a             	movzbl (%edx),%ebx
  800e70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e73:	80 3a 01             	cmpb   $0x1,(%edx)
  800e76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e79:	83 c1 01             	add    $0x1,%ecx
  800e7c:	39 f1                	cmp    %esi,%ecx
  800e7e:	75 ed                	jne    800e6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e90:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e93:	89 f8                	mov    %edi,%eax
  800e95:	85 f6                	test   %esi,%esi
  800e97:	74 2b                	je     800ec4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800e99:	83 fe 01             	cmp    $0x1,%esi
  800e9c:	74 23                	je     800ec1 <strlcpy+0x3d>
  800e9e:	0f b6 0b             	movzbl (%ebx),%ecx
  800ea1:	84 c9                	test   %cl,%cl
  800ea3:	74 1c                	je     800ec1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ea5:	83 ee 02             	sub    $0x2,%esi
  800ea8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ead:	88 08                	mov    %cl,(%eax)
  800eaf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800eb2:	39 f2                	cmp    %esi,%edx
  800eb4:	74 0b                	je     800ec1 <strlcpy+0x3d>
  800eb6:	83 c2 01             	add    $0x1,%edx
  800eb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800ebd:	84 c9                	test   %cl,%cl
  800ebf:	75 ec                	jne    800ead <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800ec1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ec4:	29 f8                	sub    %edi,%eax
}
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ed4:	0f b6 01             	movzbl (%ecx),%eax
  800ed7:	84 c0                	test   %al,%al
  800ed9:	74 16                	je     800ef1 <strcmp+0x26>
  800edb:	3a 02                	cmp    (%edx),%al
  800edd:	75 12                	jne    800ef1 <strcmp+0x26>
		p++, q++;
  800edf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ee2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ee6:	84 c0                	test   %al,%al
  800ee8:	74 07                	je     800ef1 <strcmp+0x26>
  800eea:	83 c1 01             	add    $0x1,%ecx
  800eed:	3a 02                	cmp    (%edx),%al
  800eef:	74 ee                	je     800edf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ef1:	0f b6 c0             	movzbl %al,%eax
  800ef4:	0f b6 12             	movzbl (%edx),%edx
  800ef7:	29 d0                	sub    %edx,%eax
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f0d:	85 d2                	test   %edx,%edx
  800f0f:	74 28                	je     800f39 <strncmp+0x3e>
  800f11:	0f b6 01             	movzbl (%ecx),%eax
  800f14:	84 c0                	test   %al,%al
  800f16:	74 24                	je     800f3c <strncmp+0x41>
  800f18:	3a 03                	cmp    (%ebx),%al
  800f1a:	75 20                	jne    800f3c <strncmp+0x41>
  800f1c:	83 ea 01             	sub    $0x1,%edx
  800f1f:	74 13                	je     800f34 <strncmp+0x39>
		n--, p++, q++;
  800f21:	83 c1 01             	add    $0x1,%ecx
  800f24:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f27:	0f b6 01             	movzbl (%ecx),%eax
  800f2a:	84 c0                	test   %al,%al
  800f2c:	74 0e                	je     800f3c <strncmp+0x41>
  800f2e:	3a 03                	cmp    (%ebx),%al
  800f30:	74 ea                	je     800f1c <strncmp+0x21>
  800f32:	eb 08                	jmp    800f3c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f39:	5b                   	pop    %ebx
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f3c:	0f b6 01             	movzbl (%ecx),%eax
  800f3f:	0f b6 13             	movzbl (%ebx),%edx
  800f42:	29 d0                	sub    %edx,%eax
  800f44:	eb f3                	jmp    800f39 <strncmp+0x3e>

00800f46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f50:	0f b6 10             	movzbl (%eax),%edx
  800f53:	84 d2                	test   %dl,%dl
  800f55:	74 1c                	je     800f73 <strchr+0x2d>
		if (*s == c)
  800f57:	38 ca                	cmp    %cl,%dl
  800f59:	75 09                	jne    800f64 <strchr+0x1e>
  800f5b:	eb 1b                	jmp    800f78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f5d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800f60:	38 ca                	cmp    %cl,%dl
  800f62:	74 14                	je     800f78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f64:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800f68:	84 d2                	test   %dl,%dl
  800f6a:	75 f1                	jne    800f5d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f71:	eb 05                	jmp    800f78 <strchr+0x32>
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f84:	0f b6 10             	movzbl (%eax),%edx
  800f87:	84 d2                	test   %dl,%dl
  800f89:	74 14                	je     800f9f <strfind+0x25>
		if (*s == c)
  800f8b:	38 ca                	cmp    %cl,%dl
  800f8d:	75 06                	jne    800f95 <strfind+0x1b>
  800f8f:	eb 0e                	jmp    800f9f <strfind+0x25>
  800f91:	38 ca                	cmp    %cl,%dl
  800f93:	74 0a                	je     800f9f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f95:	83 c0 01             	add    $0x1,%eax
  800f98:	0f b6 10             	movzbl (%eax),%edx
  800f9b:	84 d2                	test   %dl,%dl
  800f9d:	75 f2                	jne    800f91 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800faa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fb9:	85 c9                	test   %ecx,%ecx
  800fbb:	74 30                	je     800fed <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fc3:	75 25                	jne    800fea <memset+0x49>
  800fc5:	f6 c1 03             	test   $0x3,%cl
  800fc8:	75 20                	jne    800fea <memset+0x49>
		c &= 0xFF;
  800fca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fcd:	89 d3                	mov    %edx,%ebx
  800fcf:	c1 e3 08             	shl    $0x8,%ebx
  800fd2:	89 d6                	mov    %edx,%esi
  800fd4:	c1 e6 18             	shl    $0x18,%esi
  800fd7:	89 d0                	mov    %edx,%eax
  800fd9:	c1 e0 10             	shl    $0x10,%eax
  800fdc:	09 f0                	or     %esi,%eax
  800fde:	09 d0                	or     %edx,%eax
  800fe0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800fe2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800fe5:	fc                   	cld    
  800fe6:	f3 ab                	rep stos %eax,%es:(%edi)
  800fe8:	eb 03                	jmp    800fed <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fea:	fc                   	cld    
  800feb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fed:	89 f8                	mov    %edi,%eax
  800fef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801005:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801008:	8b 45 08             	mov    0x8(%ebp),%eax
  80100b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80100e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801011:	39 c6                	cmp    %eax,%esi
  801013:	73 36                	jae    80104b <memmove+0x4f>
  801015:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801018:	39 d0                	cmp    %edx,%eax
  80101a:	73 2f                	jae    80104b <memmove+0x4f>
		s += n;
		d += n;
  80101c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80101f:	f6 c2 03             	test   $0x3,%dl
  801022:	75 1b                	jne    80103f <memmove+0x43>
  801024:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80102a:	75 13                	jne    80103f <memmove+0x43>
  80102c:	f6 c1 03             	test   $0x3,%cl
  80102f:	75 0e                	jne    80103f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801031:	83 ef 04             	sub    $0x4,%edi
  801034:	8d 72 fc             	lea    -0x4(%edx),%esi
  801037:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80103a:	fd                   	std    
  80103b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80103d:	eb 09                	jmp    801048 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80103f:	83 ef 01             	sub    $0x1,%edi
  801042:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801045:	fd                   	std    
  801046:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801048:	fc                   	cld    
  801049:	eb 20                	jmp    80106b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80104b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801051:	75 13                	jne    801066 <memmove+0x6a>
  801053:	a8 03                	test   $0x3,%al
  801055:	75 0f                	jne    801066 <memmove+0x6a>
  801057:	f6 c1 03             	test   $0x3,%cl
  80105a:	75 0a                	jne    801066 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80105c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80105f:	89 c7                	mov    %eax,%edi
  801061:	fc                   	cld    
  801062:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801064:	eb 05                	jmp    80106b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801066:	89 c7                	mov    %eax,%edi
  801068:	fc                   	cld    
  801069:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80106b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801071:	89 ec                	mov    %ebp,%esp
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80107b:	8b 45 10             	mov    0x10(%ebp),%eax
  80107e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801082:	8b 45 0c             	mov    0xc(%ebp),%eax
  801085:	89 44 24 04          	mov    %eax,0x4(%esp)
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	89 04 24             	mov    %eax,(%esp)
  80108f:	e8 68 ff ff ff       	call   800ffc <memmove>
}
  801094:	c9                   	leave  
  801095:	c3                   	ret    

00801096 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	57                   	push   %edi
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80109f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010a5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010aa:	85 ff                	test   %edi,%edi
  8010ac:	74 37                	je     8010e5 <memcmp+0x4f>
		if (*s1 != *s2)
  8010ae:	0f b6 03             	movzbl (%ebx),%eax
  8010b1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010b4:	83 ef 01             	sub    $0x1,%edi
  8010b7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8010bc:	38 c8                	cmp    %cl,%al
  8010be:	74 1c                	je     8010dc <memcmp+0x46>
  8010c0:	eb 10                	jmp    8010d2 <memcmp+0x3c>
  8010c2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8010c7:	83 c2 01             	add    $0x1,%edx
  8010ca:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8010ce:	38 c8                	cmp    %cl,%al
  8010d0:	74 0a                	je     8010dc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  8010d2:	0f b6 c0             	movzbl %al,%eax
  8010d5:	0f b6 c9             	movzbl %cl,%ecx
  8010d8:	29 c8                	sub    %ecx,%eax
  8010da:	eb 09                	jmp    8010e5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010dc:	39 fa                	cmp    %edi,%edx
  8010de:	75 e2                	jne    8010c2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8010f0:	89 c2                	mov    %eax,%edx
  8010f2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010f5:	39 d0                	cmp    %edx,%eax
  8010f7:	73 19                	jae    801112 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010fd:	38 08                	cmp    %cl,(%eax)
  8010ff:	75 06                	jne    801107 <memfind+0x1d>
  801101:	eb 0f                	jmp    801112 <memfind+0x28>
  801103:	38 08                	cmp    %cl,(%eax)
  801105:	74 0b                	je     801112 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801107:	83 c0 01             	add    $0x1,%eax
  80110a:	39 d0                	cmp    %edx,%eax
  80110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801110:	75 f1                	jne    801103 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	8b 55 08             	mov    0x8(%ebp),%edx
  80111d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801120:	0f b6 02             	movzbl (%edx),%eax
  801123:	3c 20                	cmp    $0x20,%al
  801125:	74 04                	je     80112b <strtol+0x17>
  801127:	3c 09                	cmp    $0x9,%al
  801129:	75 0e                	jne    801139 <strtol+0x25>
		s++;
  80112b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80112e:	0f b6 02             	movzbl (%edx),%eax
  801131:	3c 20                	cmp    $0x20,%al
  801133:	74 f6                	je     80112b <strtol+0x17>
  801135:	3c 09                	cmp    $0x9,%al
  801137:	74 f2                	je     80112b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801139:	3c 2b                	cmp    $0x2b,%al
  80113b:	75 0a                	jne    801147 <strtol+0x33>
		s++;
  80113d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801140:	bf 00 00 00 00       	mov    $0x0,%edi
  801145:	eb 10                	jmp    801157 <strtol+0x43>
  801147:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80114c:	3c 2d                	cmp    $0x2d,%al
  80114e:	75 07                	jne    801157 <strtol+0x43>
		s++, neg = 1;
  801150:	83 c2 01             	add    $0x1,%edx
  801153:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801157:	85 db                	test   %ebx,%ebx
  801159:	0f 94 c0             	sete   %al
  80115c:	74 05                	je     801163 <strtol+0x4f>
  80115e:	83 fb 10             	cmp    $0x10,%ebx
  801161:	75 15                	jne    801178 <strtol+0x64>
  801163:	80 3a 30             	cmpb   $0x30,(%edx)
  801166:	75 10                	jne    801178 <strtol+0x64>
  801168:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80116c:	75 0a                	jne    801178 <strtol+0x64>
		s += 2, base = 16;
  80116e:	83 c2 02             	add    $0x2,%edx
  801171:	bb 10 00 00 00       	mov    $0x10,%ebx
  801176:	eb 13                	jmp    80118b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801178:	84 c0                	test   %al,%al
  80117a:	74 0f                	je     80118b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80117c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801181:	80 3a 30             	cmpb   $0x30,(%edx)
  801184:	75 05                	jne    80118b <strtol+0x77>
		s++, base = 8;
  801186:	83 c2 01             	add    $0x1,%edx
  801189:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
  801190:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801192:	0f b6 0a             	movzbl (%edx),%ecx
  801195:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801198:	80 fb 09             	cmp    $0x9,%bl
  80119b:	77 08                	ja     8011a5 <strtol+0x91>
			dig = *s - '0';
  80119d:	0f be c9             	movsbl %cl,%ecx
  8011a0:	83 e9 30             	sub    $0x30,%ecx
  8011a3:	eb 1e                	jmp    8011c3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  8011a5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8011a8:	80 fb 19             	cmp    $0x19,%bl
  8011ab:	77 08                	ja     8011b5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  8011ad:	0f be c9             	movsbl %cl,%ecx
  8011b0:	83 e9 57             	sub    $0x57,%ecx
  8011b3:	eb 0e                	jmp    8011c3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  8011b5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8011b8:	80 fb 19             	cmp    $0x19,%bl
  8011bb:	77 14                	ja     8011d1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8011bd:	0f be c9             	movsbl %cl,%ecx
  8011c0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8011c3:	39 f1                	cmp    %esi,%ecx
  8011c5:	7d 0e                	jge    8011d5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8011c7:	83 c2 01             	add    $0x1,%edx
  8011ca:	0f af c6             	imul   %esi,%eax
  8011cd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8011cf:	eb c1                	jmp    801192 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8011d1:	89 c1                	mov    %eax,%ecx
  8011d3:	eb 02                	jmp    8011d7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8011d5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8011d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011db:	74 05                	je     8011e2 <strtol+0xce>
		*endptr = (char *) s;
  8011dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8011e2:	89 ca                	mov    %ecx,%edx
  8011e4:	f7 da                	neg    %edx
  8011e6:	85 ff                	test   %edi,%edi
  8011e8:	0f 45 c2             	cmovne %edx,%eax
}
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801207:	8b 55 08             	mov    0x8(%ebp),%edx
  80120a:	89 c3                	mov    %eax,%ebx
  80120c:	89 c7                	mov    %eax,%edi
  80120e:	89 c6                	mov    %eax,%esi
  801210:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801212:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801215:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801218:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80121b:	89 ec                	mov    %ebp,%esp
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <sys_cgetc>:

int
sys_cgetc(void)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 0c             	sub    $0xc,%esp
  801225:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801228:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80122b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122e:	ba 00 00 00 00       	mov    $0x0,%edx
  801233:	b8 01 00 00 00       	mov    $0x1,%eax
  801238:	89 d1                	mov    %edx,%ecx
  80123a:	89 d3                	mov    %edx,%ebx
  80123c:	89 d7                	mov    %edx,%edi
  80123e:	89 d6                	mov    %edx,%esi
  801240:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801242:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801245:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801248:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80124b:	89 ec                	mov    %ebp,%esp
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 38             	sub    $0x38,%esp
  801255:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801258:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80125b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801263:	b8 03 00 00 00       	mov    $0x3,%eax
  801268:	8b 55 08             	mov    0x8(%ebp),%edx
  80126b:	89 cb                	mov    %ecx,%ebx
  80126d:	89 cf                	mov    %ecx,%edi
  80126f:	89 ce                	mov    %ecx,%esi
  801271:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801273:	85 c0                	test   %eax,%eax
  801275:	7e 28                	jle    80129f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801277:	89 44 24 10          	mov    %eax,0x10(%esp)
  80127b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801282:	00 
  801283:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  80128a:	00 
  80128b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801292:	00 
  801293:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  80129a:	e8 1d f3 ff ff       	call   8005bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80129f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012a8:	89 ec                	mov    %ebp,%esp
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	83 ec 0c             	sub    $0xc,%esp
  8012b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8012c5:	89 d1                	mov    %edx,%ecx
  8012c7:	89 d3                	mov    %edx,%ebx
  8012c9:	89 d7                	mov    %edx,%edi
  8012cb:	89 d6                	mov    %edx,%esi
  8012cd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012d8:	89 ec                	mov    %ebp,%esp
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <sys_yield>:

void
sys_yield(void)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 0c             	sub    $0xc,%esp
  8012e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012f5:	89 d1                	mov    %edx,%ecx
  8012f7:	89 d3                	mov    %edx,%ebx
  8012f9:	89 d7                	mov    %edx,%edi
  8012fb:	89 d6                	mov    %edx,%esi
  8012fd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012ff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801302:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801305:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801308:	89 ec                	mov    %ebp,%esp
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 38             	sub    $0x38,%esp
  801312:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801315:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801318:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80131b:	be 00 00 00 00       	mov    $0x0,%esi
  801320:	b8 04 00 00 00       	mov    $0x4,%eax
  801325:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132b:	8b 55 08             	mov    0x8(%ebp),%edx
  80132e:	89 f7                	mov    %esi,%edi
  801330:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801332:	85 c0                	test   %eax,%eax
  801334:	7e 28                	jle    80135e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801336:	89 44 24 10          	mov    %eax,0x10(%esp)
  80133a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801341:	00 
  801342:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  801349:	00 
  80134a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801351:	00 
  801352:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  801359:	e8 5e f2 ff ff       	call   8005bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80135e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801361:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801364:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801367:	89 ec                	mov    %ebp,%esp
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 38             	sub    $0x38,%esp
  801371:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801374:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801377:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80137a:	b8 05 00 00 00       	mov    $0x5,%eax
  80137f:	8b 75 18             	mov    0x18(%ebp),%esi
  801382:	8b 7d 14             	mov    0x14(%ebp),%edi
  801385:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801388:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138b:	8b 55 08             	mov    0x8(%ebp),%edx
  80138e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801390:	85 c0                	test   %eax,%eax
  801392:	7e 28                	jle    8013bc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801394:	89 44 24 10          	mov    %eax,0x10(%esp)
  801398:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80139f:	00 
  8013a0:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  8013a7:	00 
  8013a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013af:	00 
  8013b0:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  8013b7:	e8 00 f2 ff ff       	call   8005bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8013bc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013bf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013c5:	89 ec                	mov    %ebp,%esp
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	83 ec 38             	sub    $0x38,%esp
  8013cf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013d2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013d5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e8:	89 df                	mov    %ebx,%edi
  8013ea:	89 de                	mov    %ebx,%esi
  8013ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	7e 28                	jle    80141a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013fd:	00 
  8013fe:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  801405:	00 
  801406:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80140d:	00 
  80140e:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  801415:	e8 a2 f1 ff ff       	call   8005bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80141a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80141d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801420:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801423:	89 ec                	mov    %ebp,%esp
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 38             	sub    $0x38,%esp
  80142d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801430:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801433:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801436:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143b:	b8 08 00 00 00       	mov    $0x8,%eax
  801440:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801443:	8b 55 08             	mov    0x8(%ebp),%edx
  801446:	89 df                	mov    %ebx,%edi
  801448:	89 de                	mov    %ebx,%esi
  80144a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80144c:	85 c0                	test   %eax,%eax
  80144e:	7e 28                	jle    801478 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801450:	89 44 24 10          	mov    %eax,0x10(%esp)
  801454:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80145b:	00 
  80145c:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  801463:	00 
  801464:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80146b:	00 
  80146c:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  801473:	e8 44 f1 ff ff       	call   8005bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801478:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80147b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80147e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801481:	89 ec                	mov    %ebp,%esp
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    

00801485 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 38             	sub    $0x38,%esp
  80148b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80148e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801491:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801494:	bb 00 00 00 00       	mov    $0x0,%ebx
  801499:	b8 09 00 00 00       	mov    $0x9,%eax
  80149e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a4:	89 df                	mov    %ebx,%edi
  8014a6:	89 de                	mov    %ebx,%esi
  8014a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	7e 28                	jle    8014d6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014b9:	00 
  8014ba:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  8014c1:	00 
  8014c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014c9:	00 
  8014ca:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  8014d1:	e8 e6 f0 ff ff       	call   8005bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8014d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014df:	89 ec                	mov    %ebp,%esp
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	83 ec 38             	sub    $0x38,%esp
  8014e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801502:	89 df                	mov    %ebx,%edi
  801504:	89 de                	mov    %ebx,%esi
  801506:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801508:	85 c0                	test   %eax,%eax
  80150a:	7e 28                	jle    801534 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801510:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801517:	00 
  801518:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  80151f:	00 
  801520:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801527:	00 
  801528:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  80152f:	e8 88 f0 ff ff       	call   8005bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801534:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801537:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80153a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80153d:	89 ec                	mov    %ebp,%esp
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80154a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80154d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801550:	be 00 00 00 00       	mov    $0x0,%esi
  801555:	b8 0c 00 00 00       	mov    $0xc,%eax
  80155a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80155d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801560:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801563:	8b 55 08             	mov    0x8(%ebp),%edx
  801566:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801568:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80156b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80156e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801571:	89 ec                	mov    %ebp,%esp
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 38             	sub    $0x38,%esp
  80157b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80157e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801581:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801584:	b9 00 00 00 00       	mov    $0x0,%ecx
  801589:	b8 0d 00 00 00       	mov    $0xd,%eax
  80158e:	8b 55 08             	mov    0x8(%ebp),%edx
  801591:	89 cb                	mov    %ecx,%ebx
  801593:	89 cf                	mov    %ecx,%edi
  801595:	89 ce                	mov    %ecx,%esi
  801597:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801599:	85 c0                	test   %eax,%eax
  80159b:	7e 28                	jle    8015c5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80159d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8015a8:	00 
  8015a9:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  8015b0:	00 
  8015b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015b8:	00 
  8015b9:	c7 04 24 bc 36 80 00 	movl   $0x8036bc,(%esp)
  8015c0:	e8 f7 ef ff ff       	call   8005bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8015c5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015c8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ce:	89 ec                	mov    %ebp,%esp
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015db:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015de:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015e6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8015eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ee:	89 cb                	mov    %ecx,%ebx
  8015f0:	89 cf                	mov    %ecx,%edi
  8015f2:	89 ce                	mov    %ecx,%esi
  8015f4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8015f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ff:	89 ec                	mov    %ebp,%esp
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    
	...

00801604 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	53                   	push   %ebx
  801608:	83 ec 24             	sub    $0x24,%esp
  80160b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80160e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  801610:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801614:	75 1c                	jne    801632 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  801616:	c7 44 24 08 ca 36 80 	movl   $0x8036ca,0x8(%esp)
  80161d:	00 
  80161e:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801625:	00 
  801626:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  80162d:	e8 8a ef ff ff       	call   8005bc <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801632:	89 d8                	mov    %ebx,%eax
  801634:	c1 e8 0c             	shr    $0xc,%eax
  801637:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80163e:	f6 c4 08             	test   $0x8,%ah
  801641:	0f 84 be 00 00 00    	je     801705 <pgfault+0x101>
  801647:	89 d8                	mov    %ebx,%eax
  801649:	c1 e8 16             	shr    $0x16,%eax
  80164c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801653:	a8 01                	test   $0x1,%al
  801655:	0f 84 aa 00 00 00    	je     801705 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  80165b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801662:	00 
  801663:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80166a:	00 
  80166b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801672:	e8 95 fc ff ff       	call   80130c <sys_page_alloc>
		if (r < 0)
  801677:	85 c0                	test   %eax,%eax
  801679:	79 20                	jns    80169b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80167b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80167f:	c7 44 24 08 04 37 80 	movl   $0x803704,0x8(%esp)
  801686:	00 
  801687:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80168e:	00 
  80168f:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  801696:	e8 21 ef ff ff       	call   8005bc <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80169b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  8016a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8016a8:	00 
  8016a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ad:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8016b4:	e8 bc f9 ff ff       	call   801075 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8016b9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8016c0:	00 
  8016c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016cc:	00 
  8016cd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8016d4:	00 
  8016d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016dc:	e8 8a fc ff ff       	call   80136b <sys_page_map>
		if (r < 0)
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	79 3c                	jns    801721 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  8016e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016e9:	c7 44 24 08 2c 37 80 	movl   $0x80372c,0x8(%esp)
  8016f0:	00 
  8016f1:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8016f8:	00 
  8016f9:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  801700:	e8 b7 ee ff ff       	call   8005bc <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801705:	c7 44 24 08 50 37 80 	movl   $0x803750,0x8(%esp)
  80170c:	00 
  80170d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801714:	00 
  801715:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  80171c:	e8 9b ee ff ff       	call   8005bc <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801721:	83 c4 24             	add    $0x24,%esp
  801724:	5b                   	pop    %ebx
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801730:	c7 04 24 04 16 80 00 	movl   $0x801604,(%esp)
  801737:	e8 24 16 00 00       	call   802d60 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80173c:	bf 07 00 00 00       	mov    $0x7,%edi
  801741:	89 f8                	mov    %edi,%eax
  801743:	cd 30                	int    $0x30
  801745:	89 c7                	mov    %eax,%edi
  801747:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80174a:	85 c0                	test   %eax,%eax
  80174c:	79 20                	jns    80176e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80174e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801752:	c7 44 24 08 70 37 80 	movl   $0x803770,0x8(%esp)
  801759:	00 
  80175a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801761:	00 
  801762:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  801769:	e8 4e ee ff ff       	call   8005bc <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80176e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801773:	85 c0                	test   %eax,%eax
  801775:	75 1c                	jne    801793 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801777:	e8 30 fb ff ff       	call   8012ac <sys_getenvid>
  80177c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801781:	c1 e0 07             	shl    $0x7,%eax
  801784:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801789:	a3 04 50 80 00       	mov    %eax,0x805004
		//cprintf("child fork ok!\n");
		return 0;
  80178e:	e9 51 02 00 00       	jmp    8019e4 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801793:	89 d8                	mov    %ebx,%eax
  801795:	c1 e8 16             	shr    $0x16,%eax
  801798:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80179f:	a8 01                	test   $0x1,%al
  8017a1:	0f 84 87 01 00 00    	je     80192e <fork+0x207>
  8017a7:	89 d8                	mov    %ebx,%eax
  8017a9:	c1 e8 0c             	shr    $0xc,%eax
  8017ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017b3:	f6 c2 01             	test   $0x1,%dl
  8017b6:	0f 84 72 01 00 00    	je     80192e <fork+0x207>
  8017bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017c3:	f6 c2 04             	test   $0x4,%dl
  8017c6:	0f 84 62 01 00 00    	je     80192e <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8017cc:	89 c6                	mov    %eax,%esi
  8017ce:	c1 e6 0c             	shl    $0xc,%esi
  8017d1:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8017d7:	0f 84 51 01 00 00    	je     80192e <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  8017dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017e4:	f6 c6 04             	test   $0x4,%dh
  8017e7:	74 53                	je     80183c <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8017e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8017f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801800:	89 44 24 08          	mov    %eax,0x8(%esp)
  801804:	89 74 24 04          	mov    %esi,0x4(%esp)
  801808:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180f:	e8 57 fb ff ff       	call   80136b <sys_page_map>
		if (r < 0)
  801814:	85 c0                	test   %eax,%eax
  801816:	0f 89 12 01 00 00    	jns    80192e <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  80181c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801820:	c7 44 24 08 90 37 80 	movl   $0x803790,0x8(%esp)
  801827:	00 
  801828:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80182f:	00 
  801830:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  801837:	e8 80 ed ff ff       	call   8005bc <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80183c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801843:	f6 c2 02             	test   $0x2,%dl
  801846:	75 10                	jne    801858 <fork+0x131>
  801848:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80184f:	f6 c4 08             	test   $0x8,%ah
  801852:	0f 84 8f 00 00 00    	je     8018e7 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801858:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80185f:	00 
  801860:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801864:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801867:	89 44 24 08          	mov    %eax,0x8(%esp)
  80186b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80186f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801876:	e8 f0 fa ff ff       	call   80136b <sys_page_map>
		if (r < 0)
  80187b:	85 c0                	test   %eax,%eax
  80187d:	79 20                	jns    80189f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80187f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801883:	c7 44 24 08 bc 37 80 	movl   $0x8037bc,0x8(%esp)
  80188a:	00 
  80188b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801892:	00 
  801893:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  80189a:	e8 1d ed ff ff       	call   8005bc <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80189f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8018a6:	00 
  8018a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018b2:	00 
  8018b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018be:	e8 a8 fa ff ff       	call   80136b <sys_page_map>
		if (r < 0)
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	79 67                	jns    80192e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8018c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018cb:	c7 44 24 08 bc 37 80 	movl   $0x8037bc,0x8(%esp)
  8018d2:	00 
  8018d3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8018da:	00 
  8018db:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  8018e2:	e8 d5 ec ff ff       	call   8005bc <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  8018e7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8018ee:	00 
  8018ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801905:	e8 61 fa ff ff       	call   80136b <sys_page_map>
		if (r < 0)
  80190a:	85 c0                	test   %eax,%eax
  80190c:	79 20                	jns    80192e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  80190e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801912:	c7 44 24 08 bc 37 80 	movl   $0x8037bc,0x8(%esp)
  801919:	00 
  80191a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801921:	00 
  801922:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  801929:	e8 8e ec ff ff       	call   8005bc <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  80192e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801934:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80193a:	0f 85 53 fe ff ff    	jne    801793 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801940:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801947:	00 
  801948:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80194f:	ee 
  801950:	89 3c 24             	mov    %edi,(%esp)
  801953:	e8 b4 f9 ff ff       	call   80130c <sys_page_alloc>
	if (res < 0)
  801958:	85 c0                	test   %eax,%eax
  80195a:	79 20                	jns    80197c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  80195c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801960:	c7 44 24 08 e0 37 80 	movl   $0x8037e0,0x8(%esp)
  801967:	00 
  801968:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80196f:	00 
  801970:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  801977:	e8 40 ec ff ff       	call   8005bc <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80197c:	c7 44 24 04 ec 2d 80 	movl   $0x802dec,0x4(%esp)
  801983:	00 
  801984:	89 3c 24             	mov    %edi,(%esp)
  801987:	e8 57 fb ff ff       	call   8014e3 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	79 20                	jns    8019b0 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801990:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801994:	c7 44 24 08 04 38 80 	movl   $0x803804,0x8(%esp)
  80199b:	00 
  80199c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8019a3:	00 
  8019a4:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  8019ab:	e8 0c ec ff ff       	call   8005bc <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  8019b0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8019b7:	00 
  8019b8:	89 3c 24             	mov    %edi,(%esp)
  8019bb:	e8 67 fa ff ff       	call   801427 <sys_env_set_status>
	if (res < 0)
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	79 20                	jns    8019e4 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  8019c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c8:	c7 44 24 08 34 38 80 	movl   $0x803834,0x8(%esp)
  8019cf:	00 
  8019d0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  8019d7:	00 
  8019d8:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  8019df:	e8 d8 eb ff ff       	call   8005bc <_panic>

	return pid;
	//panic("fork not implemented");
}
  8019e4:	89 f8                	mov    %edi,%eax
  8019e6:	83 c4 3c             	add    $0x3c,%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5f                   	pop    %edi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <sfork>:

// Challenge!
int
sfork(void)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8019f4:	c7 44 24 08 ec 36 80 	movl   $0x8036ec,0x8(%esp)
  8019fb:	00 
  8019fc:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801a03:	00 
  801a04:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  801a0b:	e8 ac eb ff ff       	call   8005bc <_panic>

00801a10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801a13:	8b 45 08             	mov    0x8(%ebp),%eax
  801a16:	05 00 00 00 30       	add    $0x30000000,%eax
  801a1b:	c1 e8 0c             	shr    $0xc,%eax
}
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801a26:	8b 45 08             	mov    0x8(%ebp),%eax
  801a29:	89 04 24             	mov    %eax,(%esp)
  801a2c:	e8 df ff ff ff       	call   801a10 <fd2num>
  801a31:	05 20 00 0d 00       	add    $0xd0020,%eax
  801a36:	c1 e0 0c             	shl    $0xc,%eax
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	53                   	push   %ebx
  801a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801a42:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801a47:	a8 01                	test   $0x1,%al
  801a49:	74 34                	je     801a7f <fd_alloc+0x44>
  801a4b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801a50:	a8 01                	test   $0x1,%al
  801a52:	74 32                	je     801a86 <fd_alloc+0x4b>
  801a54:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801a59:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	c1 ea 16             	shr    $0x16,%edx
  801a60:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a67:	f6 c2 01             	test   $0x1,%dl
  801a6a:	74 1f                	je     801a8b <fd_alloc+0x50>
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	c1 ea 0c             	shr    $0xc,%edx
  801a71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a78:	f6 c2 01             	test   $0x1,%dl
  801a7b:	75 17                	jne    801a94 <fd_alloc+0x59>
  801a7d:	eb 0c                	jmp    801a8b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801a7f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801a84:	eb 05                	jmp    801a8b <fd_alloc+0x50>
  801a86:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801a8b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a92:	eb 17                	jmp    801aab <fd_alloc+0x70>
  801a94:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801a99:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801a9e:	75 b9                	jne    801a59 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801aa0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801aa6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801aab:	5b                   	pop    %ebx
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ab4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ab9:	83 fa 1f             	cmp    $0x1f,%edx
  801abc:	77 3f                	ja     801afd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801abe:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801ac4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ac7:	89 d0                	mov    %edx,%eax
  801ac9:	c1 e8 16             	shr    $0x16,%eax
  801acc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ad3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ad8:	f6 c1 01             	test   $0x1,%cl
  801adb:	74 20                	je     801afd <fd_lookup+0x4f>
  801add:	89 d0                	mov    %edx,%eax
  801adf:	c1 e8 0c             	shr    $0xc,%eax
  801ae2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ae9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801aee:	f6 c1 01             	test   $0x1,%cl
  801af1:	74 0a                	je     801afd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	53                   	push   %ebx
  801b03:	83 ec 14             	sub    $0x14,%esp
  801b06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801b11:	39 0d 24 40 80 00    	cmp    %ecx,0x804024
  801b17:	75 17                	jne    801b30 <dev_lookup+0x31>
  801b19:	eb 07                	jmp    801b22 <dev_lookup+0x23>
  801b1b:	39 0a                	cmp    %ecx,(%edx)
  801b1d:	75 11                	jne    801b30 <dev_lookup+0x31>
  801b1f:	90                   	nop
  801b20:	eb 05                	jmp    801b27 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b22:	ba 24 40 80 00       	mov    $0x804024,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801b27:	89 13                	mov    %edx,(%ebx)
			return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2e:	eb 35                	jmp    801b65 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b30:	83 c0 01             	add    $0x1,%eax
  801b33:	8b 14 85 d8 38 80 00 	mov    0x8038d8(,%eax,4),%edx
  801b3a:	85 d2                	test   %edx,%edx
  801b3c:	75 dd                	jne    801b1b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801b3e:	a1 04 50 80 00       	mov    0x805004,%eax
  801b43:	8b 40 48             	mov    0x48(%eax),%eax
  801b46:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4e:	c7 04 24 5c 38 80 00 	movl   $0x80385c,(%esp)
  801b55:	e8 5d eb ff ff       	call   8006b7 <cprintf>
	*dev = 0;
  801b5a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801b60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b65:	83 c4 14             	add    $0x14,%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 38             	sub    $0x38,%esp
  801b71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b77:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b81:	89 3c 24             	mov    %edi,(%esp)
  801b84:	e8 87 fe ff ff       	call   801a10 <fd2num>
  801b89:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801b8c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b90:	89 04 24             	mov    %eax,(%esp)
  801b93:	e8 16 ff ff ff       	call   801aae <fd_lookup>
  801b98:	89 c3                	mov    %eax,%ebx
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 05                	js     801ba3 <fd_close+0x38>
	    || fd != fd2)
  801b9e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801ba1:	74 0e                	je     801bb1 <fd_close+0x46>
		return (must_exist ? r : 0);
  801ba3:	89 f0                	mov    %esi,%eax
  801ba5:	84 c0                	test   %al,%al
  801ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bac:	0f 44 d8             	cmove  %eax,%ebx
  801baf:	eb 3d                	jmp    801bee <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801bb1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb8:	8b 07                	mov    (%edi),%eax
  801bba:	89 04 24             	mov    %eax,(%esp)
  801bbd:	e8 3d ff ff ff       	call   801aff <dev_lookup>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 16                	js     801bde <fd_close+0x73>
		if (dev->dev_close)
  801bc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bcb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801bce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	74 07                	je     801bde <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801bd7:	89 3c 24             	mov    %edi,(%esp)
  801bda:	ff d0                	call   *%eax
  801bdc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801bde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801be2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be9:	e8 db f7 ff ff       	call   8013c9 <sys_page_unmap>
	return r;
}
  801bee:	89 d8                	mov    %ebx,%eax
  801bf0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801bf3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801bf6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801bf9:	89 ec                	mov    %ebp,%esp
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	89 04 24             	mov    %eax,(%esp)
  801c10:	e8 99 fe ff ff       	call   801aae <fd_lookup>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 13                	js     801c2c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801c19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c20:	00 
  801c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c24:	89 04 24             	mov    %eax,(%esp)
  801c27:	e8 3f ff ff ff       	call   801b6b <fd_close>
}
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <close_all>:

void
close_all(void)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	53                   	push   %ebx
  801c32:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801c35:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801c3a:	89 1c 24             	mov    %ebx,(%esp)
  801c3d:	e8 bb ff ff ff       	call   801bfd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c42:	83 c3 01             	add    $0x1,%ebx
  801c45:	83 fb 20             	cmp    $0x20,%ebx
  801c48:	75 f0                	jne    801c3a <close_all+0xc>
		close(i);
}
  801c4a:	83 c4 14             	add    $0x14,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 58             	sub    $0x58,%esp
  801c56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c5f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	89 04 24             	mov    %eax,(%esp)
  801c6f:	e8 3a fe ff ff       	call   801aae <fd_lookup>
  801c74:	89 c3                	mov    %eax,%ebx
  801c76:	85 c0                	test   %eax,%eax
  801c78:	0f 88 e1 00 00 00    	js     801d5f <dup+0x10f>
		return r;
	close(newfdnum);
  801c7e:	89 3c 24             	mov    %edi,(%esp)
  801c81:	e8 77 ff ff ff       	call   801bfd <close>

	newfd = INDEX2FD(newfdnum);
  801c86:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c8c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c92:	89 04 24             	mov    %eax,(%esp)
  801c95:	e8 86 fd ff ff       	call   801a20 <fd2data>
  801c9a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c9c:	89 34 24             	mov    %esi,(%esp)
  801c9f:	e8 7c fd ff ff       	call   801a20 <fd2data>
  801ca4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801ca7:	89 d8                	mov    %ebx,%eax
  801ca9:	c1 e8 16             	shr    $0x16,%eax
  801cac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cb3:	a8 01                	test   $0x1,%al
  801cb5:	74 46                	je     801cfd <dup+0xad>
  801cb7:	89 d8                	mov    %ebx,%eax
  801cb9:	c1 e8 0c             	shr    $0xc,%eax
  801cbc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cc3:	f6 c2 01             	test   $0x1,%dl
  801cc6:	74 35                	je     801cfd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801cc8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ccf:	25 07 0e 00 00       	and    $0xe07,%eax
  801cd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801cdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cdf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ce6:	00 
  801ce7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ceb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf2:	e8 74 f6 ff ff       	call   80136b <sys_page_map>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 3b                	js     801d38 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d00:	89 c2                	mov    %eax,%edx
  801d02:	c1 ea 0c             	shr    $0xc,%edx
  801d05:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d0c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d12:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d16:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d21:	00 
  801d22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2d:	e8 39 f6 ff ff       	call   80136b <sys_page_map>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	85 c0                	test   %eax,%eax
  801d36:	79 25                	jns    801d5d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d43:	e8 81 f6 ff ff       	call   8013c9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d56:	e8 6e f6 ff ff       	call   8013c9 <sys_page_unmap>
	return r;
  801d5b:	eb 02                	jmp    801d5f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801d5d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801d5f:	89 d8                	mov    %ebx,%eax
  801d61:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d64:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d67:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d6a:	89 ec                	mov    %ebp,%esp
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    

00801d6e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	53                   	push   %ebx
  801d72:	83 ec 24             	sub    $0x24,%esp
  801d75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7f:	89 1c 24             	mov    %ebx,(%esp)
  801d82:	e8 27 fd ff ff       	call   801aae <fd_lookup>
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 6d                	js     801df8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d95:	8b 00                	mov    (%eax),%eax
  801d97:	89 04 24             	mov    %eax,(%esp)
  801d9a:	e8 60 fd ff ff       	call   801aff <dev_lookup>
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 55                	js     801df8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da6:	8b 50 08             	mov    0x8(%eax),%edx
  801da9:	83 e2 03             	and    $0x3,%edx
  801dac:	83 fa 01             	cmp    $0x1,%edx
  801daf:	75 23                	jne    801dd4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801db1:	a1 04 50 80 00       	mov    0x805004,%eax
  801db6:	8b 40 48             	mov    0x48(%eax),%eax
  801db9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc1:	c7 04 24 9d 38 80 00 	movl   $0x80389d,(%esp)
  801dc8:	e8 ea e8 ff ff       	call   8006b7 <cprintf>
		return -E_INVAL;
  801dcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801dd2:	eb 24                	jmp    801df8 <read+0x8a>
	}
	if (!dev->dev_read)
  801dd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dd7:	8b 52 08             	mov    0x8(%edx),%edx
  801dda:	85 d2                	test   %edx,%edx
  801ddc:	74 15                	je     801df3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801dde:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801de1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801dec:	89 04 24             	mov    %eax,(%esp)
  801def:	ff d2                	call   *%edx
  801df1:	eb 05                	jmp    801df8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801df3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801df8:	83 c4 24             	add    $0x24,%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	57                   	push   %edi
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	83 ec 1c             	sub    $0x1c,%esp
  801e07:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e0a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e12:	85 f6                	test   %esi,%esi
  801e14:	74 30                	je     801e46 <readn+0x48>
  801e16:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801e1b:	89 f2                	mov    %esi,%edx
  801e1d:	29 c2                	sub    %eax,%edx
  801e1f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e23:	03 45 0c             	add    0xc(%ebp),%eax
  801e26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2a:	89 3c 24             	mov    %edi,(%esp)
  801e2d:	e8 3c ff ff ff       	call   801d6e <read>
		if (m < 0)
  801e32:	85 c0                	test   %eax,%eax
  801e34:	78 10                	js     801e46 <readn+0x48>
			return m;
		if (m == 0)
  801e36:	85 c0                	test   %eax,%eax
  801e38:	74 0a                	je     801e44 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e3a:	01 c3                	add    %eax,%ebx
  801e3c:	89 d8                	mov    %ebx,%eax
  801e3e:	39 f3                	cmp    %esi,%ebx
  801e40:	72 d9                	jb     801e1b <readn+0x1d>
  801e42:	eb 02                	jmp    801e46 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801e44:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801e46:	83 c4 1c             	add    $0x1c,%esp
  801e49:	5b                   	pop    %ebx
  801e4a:	5e                   	pop    %esi
  801e4b:	5f                   	pop    %edi
  801e4c:	5d                   	pop    %ebp
  801e4d:	c3                   	ret    

00801e4e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	53                   	push   %ebx
  801e52:	83 ec 24             	sub    $0x24,%esp
  801e55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5f:	89 1c 24             	mov    %ebx,(%esp)
  801e62:	e8 47 fc ff ff       	call   801aae <fd_lookup>
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 68                	js     801ed3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e75:	8b 00                	mov    (%eax),%eax
  801e77:	89 04 24             	mov    %eax,(%esp)
  801e7a:	e8 80 fc ff ff       	call   801aff <dev_lookup>
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	78 50                	js     801ed3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e86:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e8a:	75 23                	jne    801eaf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801e8c:	a1 04 50 80 00       	mov    0x805004,%eax
  801e91:	8b 40 48             	mov    0x48(%eax),%eax
  801e94:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9c:	c7 04 24 b9 38 80 00 	movl   $0x8038b9,(%esp)
  801ea3:	e8 0f e8 ff ff       	call   8006b7 <cprintf>
		return -E_INVAL;
  801ea8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ead:	eb 24                	jmp    801ed3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801eaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801eb2:	8b 52 0c             	mov    0xc(%edx),%edx
  801eb5:	85 d2                	test   %edx,%edx
  801eb7:	74 15                	je     801ece <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801eb9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ebc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ec3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ec7:	89 04 24             	mov    %eax,(%esp)
  801eca:	ff d2                	call   *%edx
  801ecc:	eb 05                	jmp    801ed3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801ece:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801ed3:	83 c4 24             	add    $0x24,%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	89 04 24             	mov    %eax,(%esp)
  801eec:	e8 bd fb ff ff       	call   801aae <fd_lookup>
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 0e                	js     801f03 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ef5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ef8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	53                   	push   %ebx
  801f09:	83 ec 24             	sub    $0x24,%esp
  801f0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f16:	89 1c 24             	mov    %ebx,(%esp)
  801f19:	e8 90 fb ff ff       	call   801aae <fd_lookup>
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 61                	js     801f83 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2c:	8b 00                	mov    (%eax),%eax
  801f2e:	89 04 24             	mov    %eax,(%esp)
  801f31:	e8 c9 fb ff ff       	call   801aff <dev_lookup>
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 49                	js     801f83 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f41:	75 23                	jne    801f66 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801f43:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801f48:	8b 40 48             	mov    0x48(%eax),%eax
  801f4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f53:	c7 04 24 7c 38 80 00 	movl   $0x80387c,(%esp)
  801f5a:	e8 58 e7 ff ff       	call   8006b7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801f5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f64:	eb 1d                	jmp    801f83 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f69:	8b 52 18             	mov    0x18(%edx),%edx
  801f6c:	85 d2                	test   %edx,%edx
  801f6e:	74 0e                	je     801f7e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f73:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801f77:	89 04 24             	mov    %eax,(%esp)
  801f7a:	ff d2                	call   *%edx
  801f7c:	eb 05                	jmp    801f83 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801f7e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801f83:	83 c4 24             	add    $0x24,%esp
  801f86:	5b                   	pop    %ebx
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	53                   	push   %ebx
  801f8d:	83 ec 24             	sub    $0x24,%esp
  801f90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9d:	89 04 24             	mov    %eax,(%esp)
  801fa0:	e8 09 fb ff ff       	call   801aae <fd_lookup>
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 52                	js     801ffb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fb3:	8b 00                	mov    (%eax),%eax
  801fb5:	89 04 24             	mov    %eax,(%esp)
  801fb8:	e8 42 fb ff ff       	call   801aff <dev_lookup>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 3a                	js     801ffb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801fc8:	74 2c                	je     801ff6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801fca:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801fcd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801fd4:	00 00 00 
	stat->st_isdir = 0;
  801fd7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fde:	00 00 00 
	stat->st_dev = dev;
  801fe1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801fe7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801feb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fee:	89 14 24             	mov    %edx,(%esp)
  801ff1:	ff 50 14             	call   *0x14(%eax)
  801ff4:	eb 05                	jmp    801ffb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ff6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ffb:	83 c4 24             	add    $0x24,%esp
  801ffe:	5b                   	pop    %ebx
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    

00802001 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 18             	sub    $0x18,%esp
  802007:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80200a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80200d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802014:	00 
  802015:	8b 45 08             	mov    0x8(%ebp),%eax
  802018:	89 04 24             	mov    %eax,(%esp)
  80201b:	e8 bc 01 00 00       	call   8021dc <open>
  802020:	89 c3                	mov    %eax,%ebx
  802022:	85 c0                	test   %eax,%eax
  802024:	78 1b                	js     802041 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802026:	8b 45 0c             	mov    0xc(%ebp),%eax
  802029:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202d:	89 1c 24             	mov    %ebx,(%esp)
  802030:	e8 54 ff ff ff       	call   801f89 <fstat>
  802035:	89 c6                	mov    %eax,%esi
	close(fd);
  802037:	89 1c 24             	mov    %ebx,(%esp)
  80203a:	e8 be fb ff ff       	call   801bfd <close>
	return r;
  80203f:	89 f3                	mov    %esi,%ebx
}
  802041:	89 d8                	mov    %ebx,%eax
  802043:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802046:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802049:	89 ec                	mov    %ebp,%esp
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    
  80204d:	00 00                	add    %al,(%eax)
	...

00802050 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	83 ec 18             	sub    $0x18,%esp
  802056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80205c:	89 c3                	mov    %eax,%ebx
  80205e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802060:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  802067:	75 11                	jne    80207a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802069:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802070:	e8 6c 0e 00 00       	call   802ee1 <ipc_find_env>
  802075:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80207a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802081:	00 
  802082:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802089:	00 
  80208a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80208e:	a1 00 50 80 00       	mov    0x805000,%eax
  802093:	89 04 24             	mov    %eax,(%esp)
  802096:	e8 db 0d 00 00       	call   802e76 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80209b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020a2:	00 
  8020a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ae:	e8 5d 0d 00 00       	call   802e10 <ipc_recv>
}
  8020b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8020b6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8020b9:	89 ec                	mov    %ebp,%esp
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    

008020bd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	53                   	push   %ebx
  8020c1:	83 ec 14             	sub    $0x14,%esp
  8020c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8020cd:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8020d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8020dc:	e8 6f ff ff ff       	call   802050 <fsipc>
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 2b                	js     802110 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8020e5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8020ec:	00 
  8020ed:	89 1c 24             	mov    %ebx,(%esp)
  8020f0:	e8 16 ed ff ff       	call   800e0b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8020f5:	a1 80 60 80 00       	mov    0x806080,%eax
  8020fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802100:	a1 84 60 80 00       	mov    0x806084,%eax
  802105:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80210b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802110:	83 c4 14             	add    $0x14,%esp
  802113:	5b                   	pop    %ebx
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80211c:	8b 45 08             	mov    0x8(%ebp),%eax
  80211f:	8b 40 0c             	mov    0xc(%eax),%eax
  802122:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802127:	ba 00 00 00 00       	mov    $0x0,%edx
  80212c:	b8 06 00 00 00       	mov    $0x6,%eax
  802131:	e8 1a ff ff ff       	call   802050 <fsipc>
}
  802136:	c9                   	leave  
  802137:	c3                   	ret    

00802138 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	56                   	push   %esi
  80213c:	53                   	push   %ebx
  80213d:	83 ec 10             	sub    $0x10,%esp
  802140:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802143:	8b 45 08             	mov    0x8(%ebp),%eax
  802146:	8b 40 0c             	mov    0xc(%eax),%eax
  802149:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80214e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802154:	ba 00 00 00 00       	mov    $0x0,%edx
  802159:	b8 03 00 00 00       	mov    $0x3,%eax
  80215e:	e8 ed fe ff ff       	call   802050 <fsipc>
  802163:	89 c3                	mov    %eax,%ebx
  802165:	85 c0                	test   %eax,%eax
  802167:	78 6a                	js     8021d3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 24                	jae    802191 <devfile_read+0x59>
  80216d:	c7 44 24 0c e8 38 80 	movl   $0x8038e8,0xc(%esp)
  802174:	00 
  802175:	c7 44 24 08 ef 38 80 	movl   $0x8038ef,0x8(%esp)
  80217c:	00 
  80217d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  802184:	00 
  802185:	c7 04 24 04 39 80 00 	movl   $0x803904,(%esp)
  80218c:	e8 2b e4 ff ff       	call   8005bc <_panic>
	assert(r <= PGSIZE);
  802191:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802196:	7e 24                	jle    8021bc <devfile_read+0x84>
  802198:	c7 44 24 0c 0f 39 80 	movl   $0x80390f,0xc(%esp)
  80219f:	00 
  8021a0:	c7 44 24 08 ef 38 80 	movl   $0x8038ef,0x8(%esp)
  8021a7:	00 
  8021a8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8021af:	00 
  8021b0:	c7 04 24 04 39 80 00 	movl   $0x803904,(%esp)
  8021b7:	e8 00 e4 ff ff       	call   8005bc <_panic>
	memmove(buf, &fsipcbuf, r);
  8021bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8021c7:	00 
  8021c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cb:	89 04 24             	mov    %eax,(%esp)
  8021ce:	e8 29 ee ff ff       	call   800ffc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  8021d3:	89 d8                	mov    %ebx,%eax
  8021d5:	83 c4 10             	add    $0x10,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    

008021dc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	56                   	push   %esi
  8021e0:	53                   	push   %ebx
  8021e1:	83 ec 20             	sub    $0x20,%esp
  8021e4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8021e7:	89 34 24             	mov    %esi,(%esp)
  8021ea:	e8 d1 eb ff ff       	call   800dc0 <strlen>
		return -E_BAD_PATH;
  8021ef:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8021f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8021f9:	7f 5e                	jg     802259 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8021fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fe:	89 04 24             	mov    %eax,(%esp)
  802201:	e8 35 f8 ff ff       	call   801a3b <fd_alloc>
  802206:	89 c3                	mov    %eax,%ebx
  802208:	85 c0                	test   %eax,%eax
  80220a:	78 4d                	js     802259 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80220c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802210:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802217:	e8 ef eb ff ff       	call   800e0b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80221c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80221f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802224:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802227:	b8 01 00 00 00       	mov    $0x1,%eax
  80222c:	e8 1f fe ff ff       	call   802050 <fsipc>
  802231:	89 c3                	mov    %eax,%ebx
  802233:	85 c0                	test   %eax,%eax
  802235:	79 15                	jns    80224c <open+0x70>
		fd_close(fd, 0);
  802237:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80223e:	00 
  80223f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802242:	89 04 24             	mov    %eax,(%esp)
  802245:	e8 21 f9 ff ff       	call   801b6b <fd_close>
		return r;
  80224a:	eb 0d                	jmp    802259 <open+0x7d>
	}

	return fd2num(fd);
  80224c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224f:	89 04 24             	mov    %eax,(%esp)
  802252:	e8 b9 f7 ff ff       	call   801a10 <fd2num>
  802257:	89 c3                	mov    %eax,%ebx
}
  802259:	89 d8                	mov    %ebx,%eax
  80225b:	83 c4 20             	add    $0x20,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
	...

00802264 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802264:	55                   	push   %ebp
  802265:	89 e5                	mov    %esp,%ebp
  802267:	57                   	push   %edi
  802268:	56                   	push   %esi
  802269:	53                   	push   %ebx
  80226a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802270:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802277:	00 
  802278:	8b 45 08             	mov    0x8(%ebp),%eax
  80227b:	89 04 24             	mov    %eax,(%esp)
  80227e:	e8 59 ff ff ff       	call   8021dc <open>
  802283:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802289:	85 c0                	test   %eax,%eax
  80228b:	0f 88 c9 05 00 00    	js     80285a <spawn+0x5f6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802291:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802298:	00 
  802299:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80229f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8022a9:	89 04 24             	mov    %eax,(%esp)
  8022ac:	e8 4d fb ff ff       	call   801dfe <readn>
  8022b1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8022b6:	75 0c                	jne    8022c4 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8022b8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8022bf:	45 4c 46 
  8022c2:	74 3b                	je     8022ff <spawn+0x9b>
		close(fd);
  8022c4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8022ca:	89 04 24             	mov    %eax,(%esp)
  8022cd:	e8 2b f9 ff ff       	call   801bfd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8022d2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8022d9:	46 
  8022da:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8022e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e4:	c7 04 24 1b 39 80 00 	movl   $0x80391b,(%esp)
  8022eb:	e8 c7 e3 ff ff       	call   8006b7 <cprintf>
		return -E_NOT_EXEC;
  8022f0:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  8022f7:	ff ff ff 
  8022fa:	e9 67 05 00 00       	jmp    802866 <spawn+0x602>
  8022ff:	ba 07 00 00 00       	mov    $0x7,%edx
  802304:	89 d0                	mov    %edx,%eax
  802306:	cd 30                	int    $0x30
  802308:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80230e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802314:	85 c0                	test   %eax,%eax
  802316:	0f 88 4a 05 00 00    	js     802866 <spawn+0x602>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80231c:	89 c6                	mov    %eax,%esi
  80231e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802324:	c1 e6 07             	shl    $0x7,%esi
  802327:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80232d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802333:	b9 11 00 00 00       	mov    $0x11,%ecx
  802338:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80233a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802340:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802346:	8b 55 0c             	mov    0xc(%ebp),%edx
  802349:	8b 02                	mov    (%edx),%eax
  80234b:	85 c0                	test   %eax,%eax
  80234d:	74 5f                	je     8023ae <spawn+0x14a>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80234f:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (argc = 0; argv[argc] != 0; argc++)
  802354:	be 00 00 00 00       	mov    $0x0,%esi
  802359:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  80235b:	89 04 24             	mov    %eax,(%esp)
  80235e:	e8 5d ea ff ff       	call   800dc0 <strlen>
  802363:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802367:	83 c6 01             	add    $0x1,%esi
  80236a:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80236c:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802373:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  802376:	85 c0                	test   %eax,%eax
  802378:	75 e1                	jne    80235b <spawn+0xf7>
  80237a:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802380:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802386:	bf 00 10 40 00       	mov    $0x401000,%edi
  80238b:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80238d:	89 f8                	mov    %edi,%eax
  80238f:	83 e0 fc             	and    $0xfffffffc,%eax
  802392:	f7 d2                	not    %edx
  802394:	8d 14 90             	lea    (%eax,%edx,4),%edx
  802397:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80239d:	89 d0                	mov    %edx,%eax
  80239f:	83 e8 08             	sub    $0x8,%eax
  8023a2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8023a7:	77 2d                	ja     8023d6 <spawn+0x172>
  8023a9:	e9 c9 04 00 00       	jmp    802877 <spawn+0x613>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8023ae:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8023b5:	00 00 00 
  8023b8:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8023bf:	00 00 00 
  8023c2:	be 00 00 00 00       	mov    $0x0,%esi
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8023c7:	c7 85 94 fd ff ff fc 	movl   $0x400ffc,-0x26c(%ebp)
  8023ce:	0f 40 00 
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8023d1:	bf 00 10 40 00       	mov    $0x401000,%edi
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8023d6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023dd:	00 
  8023de:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8023e5:	00 
  8023e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ed:	e8 1a ef ff ff       	call   80130c <sys_page_alloc>
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	0f 88 82 04 00 00    	js     80287c <spawn+0x618>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8023fa:	85 f6                	test   %esi,%esi
  8023fc:	7e 46                	jle    802444 <spawn+0x1e0>
  8023fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  802403:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802409:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  80240c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802412:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802418:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80241b:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80241e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802422:	89 3c 24             	mov    %edi,(%esp)
  802425:	e8 e1 e9 ff ff       	call   800e0b <strcpy>
		string_store += strlen(argv[i]) + 1;
  80242a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80242d:	89 04 24             	mov    %eax,(%esp)
  802430:	e8 8b e9 ff ff       	call   800dc0 <strlen>
  802435:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802439:	83 c3 01             	add    $0x1,%ebx
  80243c:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802442:	75 c8                	jne    80240c <spawn+0x1a8>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802444:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80244a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802450:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802457:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80245d:	74 24                	je     802483 <spawn+0x21f>
  80245f:	c7 44 24 0c 90 39 80 	movl   $0x803990,0xc(%esp)
  802466:	00 
  802467:	c7 44 24 08 ef 38 80 	movl   $0x8038ef,0x8(%esp)
  80246e:	00 
  80246f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802476:	00 
  802477:	c7 04 24 35 39 80 00 	movl   $0x803935,(%esp)
  80247e:	e8 39 e1 ff ff       	call   8005bc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802483:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802489:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80248e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802494:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802497:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80249d:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8024a0:	89 d0                	mov    %edx,%eax
  8024a2:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8024a7:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8024ad:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8024b4:	00 
  8024b5:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8024bc:	ee 
  8024bd:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8024c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024c7:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8024ce:	00 
  8024cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024d6:	e8 90 ee ff ff       	call   80136b <sys_page_map>
  8024db:	89 c3                	mov    %eax,%ebx
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	78 1a                	js     8024fb <spawn+0x297>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8024e1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8024e8:	00 
  8024e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f0:	e8 d4 ee ff ff       	call   8013c9 <sys_page_unmap>
  8024f5:	89 c3                	mov    %eax,%ebx
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	79 1f                	jns    80251a <spawn+0x2b6>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8024fb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802502:	00 
  802503:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250a:	e8 ba ee ff ff       	call   8013c9 <sys_page_unmap>
	return r;
  80250f:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802515:	e9 4c 03 00 00       	jmp    802866 <spawn+0x602>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80251a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802520:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802527:	00 
  802528:	0f 84 e2 01 00 00    	je     802710 <spawn+0x4ac>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80252e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802535:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80253b:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802542:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  802545:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80254b:	83 3a 01             	cmpl   $0x1,(%edx)
  80254e:	0f 85 9b 01 00 00    	jne    8026ef <spawn+0x48b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802554:	8b 42 18             	mov    0x18(%edx),%eax
  802557:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80255a:	83 f8 01             	cmp    $0x1,%eax
  80255d:	19 c0                	sbb    %eax,%eax
  80255f:	83 e0 fe             	and    $0xfffffffe,%eax
  802562:	83 c0 07             	add    $0x7,%eax
  802565:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80256b:	8b 52 04             	mov    0x4(%edx),%edx
  80256e:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802574:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80257a:	8b 70 10             	mov    0x10(%eax),%esi
  80257d:	8b 50 14             	mov    0x14(%eax),%edx
  802580:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802586:	8b 40 08             	mov    0x8(%eax),%eax
  802589:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80258f:	25 ff 0f 00 00       	and    $0xfff,%eax
  802594:	74 16                	je     8025ac <spawn+0x348>
		va -= i;
  802596:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  80259c:	01 c2                	add    %eax,%edx
  80259e:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  8025a4:	01 c6                	add    %eax,%esi
		fileoffset -= i;
  8025a6:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8025ac:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  8025b3:	0f 84 36 01 00 00    	je     8026ef <spawn+0x48b>
  8025b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8025be:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  8025c3:	39 f7                	cmp    %esi,%edi
  8025c5:	72 31                	jb     8025f8 <spawn+0x394>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8025c7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8025cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025d1:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  8025d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025db:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8025e1:	89 04 24             	mov    %eax,(%esp)
  8025e4:	e8 23 ed ff ff       	call   80130c <sys_page_alloc>
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	0f 89 ea 00 00 00    	jns    8026db <spawn+0x477>
  8025f1:	89 c6                	mov    %eax,%esi
  8025f3:	e9 3e 02 00 00       	jmp    802836 <spawn+0x5d2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025f8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8025ff:	00 
  802600:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802607:	00 
  802608:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80260f:	e8 f8 ec ff ff       	call   80130c <sys_page_alloc>
  802614:	85 c0                	test   %eax,%eax
  802616:	0f 88 10 02 00 00    	js     80282c <spawn+0x5c8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80261c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802622:	01 d8                	add    %ebx,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802624:	89 44 24 04          	mov    %eax,0x4(%esp)
  802628:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80262e:	89 04 24             	mov    %eax,(%esp)
  802631:	e8 a3 f8 ff ff       	call   801ed9 <seek>
  802636:	85 c0                	test   %eax,%eax
  802638:	0f 88 f2 01 00 00    	js     802830 <spawn+0x5cc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80263e:	89 f0                	mov    %esi,%eax
  802640:	29 f8                	sub    %edi,%eax
  802642:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802647:	ba 00 10 00 00       	mov    $0x1000,%edx
  80264c:	0f 47 c2             	cmova  %edx,%eax
  80264f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802653:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80265a:	00 
  80265b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802661:	89 04 24             	mov    %eax,(%esp)
  802664:	e8 95 f7 ff ff       	call   801dfe <readn>
  802669:	85 c0                	test   %eax,%eax
  80266b:	0f 88 c3 01 00 00    	js     802834 <spawn+0x5d0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802671:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802677:	89 54 24 10          	mov    %edx,0x10(%esp)
  80267b:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802681:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802685:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80268b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80268f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802696:	00 
  802697:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80269e:	e8 c8 ec ff ff       	call   80136b <sys_page_map>
  8026a3:	85 c0                	test   %eax,%eax
  8026a5:	79 20                	jns    8026c7 <spawn+0x463>
				panic("spawn: sys_page_map data: %e", r);
  8026a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026ab:	c7 44 24 08 41 39 80 	movl   $0x803941,0x8(%esp)
  8026b2:	00 
  8026b3:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  8026ba:	00 
  8026bb:	c7 04 24 35 39 80 00 	movl   $0x803935,(%esp)
  8026c2:	e8 f5 de ff ff       	call   8005bc <_panic>
			sys_page_unmap(0, UTEMP);
  8026c7:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8026ce:	00 
  8026cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d6:	e8 ee ec ff ff       	call   8013c9 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8026db:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8026e1:	89 df                	mov    %ebx,%edi
  8026e3:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  8026e9:	0f 82 d4 fe ff ff    	jb     8025c3 <spawn+0x35f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026ef:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  8026f6:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8026fd:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802704:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  80270a:	0f 8f 35 fe ff ff    	jg     802545 <spawn+0x2e1>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802710:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802716:	89 04 24             	mov    %eax,(%esp)
  802719:	e8 df f4 ff ff       	call   801bfd <close>
  80271e:	bf 00 00 00 00       	mov    $0x0,%edi
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  802723:	be 00 00 00 00       	mov    $0x0,%esi
  802728:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(i * PGSIZE)] & PTE_P) && (uvpt[i] & PTE_P) && (uvpt[i] & PTE_SHARE)) {
  80272e:	89 f8                	mov    %edi,%eax
  802730:	c1 e8 16             	shr    $0x16,%eax
  802733:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80273a:	a8 01                	test   $0x1,%al
  80273c:	74 63                	je     8027a1 <spawn+0x53d>
  80273e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802745:	a8 01                	test   $0x1,%al
  802747:	74 58                	je     8027a1 <spawn+0x53d>
  802749:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802750:	f6 c4 04             	test   $0x4,%ah
  802753:	74 4c                	je     8027a1 <spawn+0x53d>
			res = sys_page_map(0, (void *)(i * PGSIZE), child, (void *)(i * PGSIZE), uvpt[i] & PTE_SYSCALL);
  802755:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80275c:	25 07 0e 00 00       	and    $0xe07,%eax
  802761:	89 44 24 10          	mov    %eax,0x10(%esp)
  802765:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802769:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80276d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802771:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802778:	e8 ee eb ff ff       	call   80136b <sys_page_map>
			if (res < 0)
  80277d:	85 c0                	test   %eax,%eax
  80277f:	79 20                	jns    8027a1 <spawn+0x53d>
				panic("sys_page_map failed in copy_shared_pages %e\n", res);
  802781:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802785:	c7 44 24 08 b8 39 80 	movl   $0x8039b8,0x8(%esp)
  80278c:	00 
  80278d:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  802794:	00 
  802795:	c7 04 24 35 39 80 00 	movl   $0x803935,(%esp)
  80279c:	e8 1b de ff ff       	call   8005bc <_panic>
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  8027a1:	83 c6 01             	add    $0x1,%esi
  8027a4:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8027aa:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8027b0:	0f 85 78 ff ff ff    	jne    80272e <spawn+0x4ca>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8027b6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8027bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027c0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8027c6:	89 04 24             	mov    %eax,(%esp)
  8027c9:	e8 b7 ec ff ff       	call   801485 <sys_env_set_trapframe>
  8027ce:	85 c0                	test   %eax,%eax
  8027d0:	79 20                	jns    8027f2 <spawn+0x58e>
		panic("sys_env_set_trapframe: %e", r);
  8027d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027d6:	c7 44 24 08 5e 39 80 	movl   $0x80395e,0x8(%esp)
  8027dd:	00 
  8027de:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8027e5:	00 
  8027e6:	c7 04 24 35 39 80 00 	movl   $0x803935,(%esp)
  8027ed:	e8 ca dd ff ff       	call   8005bc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8027f2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8027f9:	00 
  8027fa:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802800:	89 04 24             	mov    %eax,(%esp)
  802803:	e8 1f ec ff ff       	call   801427 <sys_env_set_status>
  802808:	85 c0                	test   %eax,%eax
  80280a:	79 5a                	jns    802866 <spawn+0x602>
		panic("sys_env_set_status: %e", r);
  80280c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802810:	c7 44 24 08 78 39 80 	movl   $0x803978,0x8(%esp)
  802817:	00 
  802818:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  80281f:	00 
  802820:	c7 04 24 35 39 80 00 	movl   $0x803935,(%esp)
  802827:	e8 90 dd ff ff       	call   8005bc <_panic>
  80282c:	89 c6                	mov    %eax,%esi
  80282e:	eb 06                	jmp    802836 <spawn+0x5d2>
  802830:	89 c6                	mov    %eax,%esi
  802832:	eb 02                	jmp    802836 <spawn+0x5d2>
  802834:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802836:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80283c:	89 04 24             	mov    %eax,(%esp)
  80283f:	e8 0b ea ff ff       	call   80124f <sys_env_destroy>
	close(fd);
  802844:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80284a:	89 04 24             	mov    %eax,(%esp)
  80284d:	e8 ab f3 ff ff       	call   801bfd <close>
	return r;
  802852:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802858:	eb 0c                	jmp    802866 <spawn+0x602>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80285a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802860:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802866:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80286c:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802872:	5b                   	pop    %ebx
  802873:	5e                   	pop    %esi
  802874:	5f                   	pop    %edi
  802875:	5d                   	pop    %ebp
  802876:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802877:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  80287c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802882:	eb e2                	jmp    802866 <spawn+0x602>

00802884 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802884:	55                   	push   %ebp
  802885:	89 e5                	mov    %esp,%ebp
  802887:	56                   	push   %esi
  802888:	53                   	push   %ebx
  802889:	83 ec 10             	sub    $0x10,%esp
  80288c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80288f:	8d 45 14             	lea    0x14(%ebp),%eax
  802892:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802896:	74 66                	je     8028fe <spawnl+0x7a>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802898:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  80289d:	83 c1 01             	add    $0x1,%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8028a0:	89 c2                	mov    %eax,%edx
  8028a2:	83 c0 04             	add    $0x4,%eax
  8028a5:	83 3a 00             	cmpl   $0x0,(%edx)
  8028a8:	75 f3                	jne    80289d <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8028aa:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8028b1:	83 e0 f0             	and    $0xfffffff0,%eax
  8028b4:	29 c4                	sub    %eax,%esp
  8028b6:	8d 44 24 17          	lea    0x17(%esp),%eax
  8028ba:	83 e0 f0             	and    $0xfffffff0,%eax
  8028bd:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8028bf:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8028c1:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  8028c8:	00 

	va_start(vl, arg0);
  8028c9:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8028cc:	89 ce                	mov    %ecx,%esi
  8028ce:	85 c9                	test   %ecx,%ecx
  8028d0:	74 16                	je     8028e8 <spawnl+0x64>
  8028d2:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8028d7:	83 c0 01             	add    $0x1,%eax
  8028da:	89 d1                	mov    %edx,%ecx
  8028dc:	83 c2 04             	add    $0x4,%edx
  8028df:	8b 09                	mov    (%ecx),%ecx
  8028e1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8028e4:	39 f0                	cmp    %esi,%eax
  8028e6:	75 ef                	jne    8028d7 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8028e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8028ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8028ef:	89 04 24             	mov    %eax,(%esp)
  8028f2:	e8 6d f9 ff ff       	call   802264 <spawn>
}
  8028f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028fa:	5b                   	pop    %ebx
  8028fb:	5e                   	pop    %esi
  8028fc:	5d                   	pop    %ebp
  8028fd:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8028fe:	83 ec 20             	sub    $0x20,%esp
  802901:	8d 44 24 17          	lea    0x17(%esp),%eax
  802905:	83 e0 f0             	and    $0xfffffff0,%eax
  802908:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80290a:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80290c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802913:	eb d3                	jmp    8028e8 <spawnl+0x64>
	...

00802920 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802920:	55                   	push   %ebp
  802921:	89 e5                	mov    %esp,%ebp
  802923:	83 ec 18             	sub    $0x18,%esp
  802926:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802929:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80292c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80292f:	8b 45 08             	mov    0x8(%ebp),%eax
  802932:	89 04 24             	mov    %eax,(%esp)
  802935:	e8 e6 f0 ff ff       	call   801a20 <fd2data>
  80293a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80293c:	c7 44 24 04 e5 39 80 	movl   $0x8039e5,0x4(%esp)
  802943:	00 
  802944:	89 34 24             	mov    %esi,(%esp)
  802947:	e8 bf e4 ff ff       	call   800e0b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80294c:	8b 43 04             	mov    0x4(%ebx),%eax
  80294f:	2b 03                	sub    (%ebx),%eax
  802951:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802957:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80295e:	00 00 00 
	stat->st_dev = &devpipe;
  802961:	c7 86 88 00 00 00 40 	movl   $0x804040,0x88(%esi)
  802968:	40 80 00 
	return 0;
}
  80296b:	b8 00 00 00 00       	mov    $0x0,%eax
  802970:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802973:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802976:	89 ec                	mov    %ebp,%esp
  802978:	5d                   	pop    %ebp
  802979:	c3                   	ret    

0080297a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80297a:	55                   	push   %ebp
  80297b:	89 e5                	mov    %esp,%ebp
  80297d:	53                   	push   %ebx
  80297e:	83 ec 14             	sub    $0x14,%esp
  802981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802988:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80298f:	e8 35 ea ff ff       	call   8013c9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802994:	89 1c 24             	mov    %ebx,(%esp)
  802997:	e8 84 f0 ff ff       	call   801a20 <fd2data>
  80299c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029a7:	e8 1d ea ff ff       	call   8013c9 <sys_page_unmap>
}
  8029ac:	83 c4 14             	add    $0x14,%esp
  8029af:	5b                   	pop    %ebx
  8029b0:	5d                   	pop    %ebp
  8029b1:	c3                   	ret    

008029b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8029b2:	55                   	push   %ebp
  8029b3:	89 e5                	mov    %esp,%ebp
  8029b5:	57                   	push   %edi
  8029b6:	56                   	push   %esi
  8029b7:	53                   	push   %ebx
  8029b8:	83 ec 2c             	sub    $0x2c,%esp
  8029bb:	89 c7                	mov    %eax,%edi
  8029bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8029c0:	a1 04 50 80 00       	mov    0x805004,%eax
  8029c5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8029c8:	89 3c 24             	mov    %edi,(%esp)
  8029cb:	e8 5c 05 00 00       	call   802f2c <pageref>
  8029d0:	89 c6                	mov    %eax,%esi
  8029d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8029d5:	89 04 24             	mov    %eax,(%esp)
  8029d8:	e8 4f 05 00 00       	call   802f2c <pageref>
  8029dd:	39 c6                	cmp    %eax,%esi
  8029df:	0f 94 c0             	sete   %al
  8029e2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8029e5:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8029eb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8029ee:	39 cb                	cmp    %ecx,%ebx
  8029f0:	75 08                	jne    8029fa <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8029f2:	83 c4 2c             	add    $0x2c,%esp
  8029f5:	5b                   	pop    %ebx
  8029f6:	5e                   	pop    %esi
  8029f7:	5f                   	pop    %edi
  8029f8:	5d                   	pop    %ebp
  8029f9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8029fa:	83 f8 01             	cmp    $0x1,%eax
  8029fd:	75 c1                	jne    8029c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8029ff:	8b 52 58             	mov    0x58(%edx),%edx
  802a02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a06:	89 54 24 08          	mov    %edx,0x8(%esp)
  802a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802a0e:	c7 04 24 ec 39 80 00 	movl   $0x8039ec,(%esp)
  802a15:	e8 9d dc ff ff       	call   8006b7 <cprintf>
  802a1a:	eb a4                	jmp    8029c0 <_pipeisclosed+0xe>

00802a1c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802a1c:	55                   	push   %ebp
  802a1d:	89 e5                	mov    %esp,%ebp
  802a1f:	57                   	push   %edi
  802a20:	56                   	push   %esi
  802a21:	53                   	push   %ebx
  802a22:	83 ec 2c             	sub    $0x2c,%esp
  802a25:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802a28:	89 34 24             	mov    %esi,(%esp)
  802a2b:	e8 f0 ef ff ff       	call   801a20 <fd2data>
  802a30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a32:	bf 00 00 00 00       	mov    $0x0,%edi
  802a37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802a3b:	75 50                	jne    802a8d <devpipe_write+0x71>
  802a3d:	eb 5c                	jmp    802a9b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802a3f:	89 da                	mov    %ebx,%edx
  802a41:	89 f0                	mov    %esi,%eax
  802a43:	e8 6a ff ff ff       	call   8029b2 <_pipeisclosed>
  802a48:	85 c0                	test   %eax,%eax
  802a4a:	75 53                	jne    802a9f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802a4c:	e8 8b e8 ff ff       	call   8012dc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802a51:	8b 43 04             	mov    0x4(%ebx),%eax
  802a54:	8b 13                	mov    (%ebx),%edx
  802a56:	83 c2 20             	add    $0x20,%edx
  802a59:	39 d0                	cmp    %edx,%eax
  802a5b:	73 e2                	jae    802a3f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a60:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802a64:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802a67:	89 c2                	mov    %eax,%edx
  802a69:	c1 fa 1f             	sar    $0x1f,%edx
  802a6c:	c1 ea 1b             	shr    $0x1b,%edx
  802a6f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802a72:	83 e1 1f             	and    $0x1f,%ecx
  802a75:	29 d1                	sub    %edx,%ecx
  802a77:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802a7b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802a7f:	83 c0 01             	add    $0x1,%eax
  802a82:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a85:	83 c7 01             	add    $0x1,%edi
  802a88:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802a8b:	74 0e                	je     802a9b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802a8d:	8b 43 04             	mov    0x4(%ebx),%eax
  802a90:	8b 13                	mov    (%ebx),%edx
  802a92:	83 c2 20             	add    $0x20,%edx
  802a95:	39 d0                	cmp    %edx,%eax
  802a97:	73 a6                	jae    802a3f <devpipe_write+0x23>
  802a99:	eb c2                	jmp    802a5d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802a9b:	89 f8                	mov    %edi,%eax
  802a9d:	eb 05                	jmp    802aa4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802a9f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802aa4:	83 c4 2c             	add    $0x2c,%esp
  802aa7:	5b                   	pop    %ebx
  802aa8:	5e                   	pop    %esi
  802aa9:	5f                   	pop    %edi
  802aaa:	5d                   	pop    %ebp
  802aab:	c3                   	ret    

00802aac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802aac:	55                   	push   %ebp
  802aad:	89 e5                	mov    %esp,%ebp
  802aaf:	83 ec 28             	sub    $0x28,%esp
  802ab2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802ab5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802ab8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802abb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802abe:	89 3c 24             	mov    %edi,(%esp)
  802ac1:	e8 5a ef ff ff       	call   801a20 <fd2data>
  802ac6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ac8:	be 00 00 00 00       	mov    $0x0,%esi
  802acd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802ad1:	75 47                	jne    802b1a <devpipe_read+0x6e>
  802ad3:	eb 52                	jmp    802b27 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802ad5:	89 f0                	mov    %esi,%eax
  802ad7:	eb 5e                	jmp    802b37 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802ad9:	89 da                	mov    %ebx,%edx
  802adb:	89 f8                	mov    %edi,%eax
  802add:	8d 76 00             	lea    0x0(%esi),%esi
  802ae0:	e8 cd fe ff ff       	call   8029b2 <_pipeisclosed>
  802ae5:	85 c0                	test   %eax,%eax
  802ae7:	75 49                	jne    802b32 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802ae9:	e8 ee e7 ff ff       	call   8012dc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802aee:	8b 03                	mov    (%ebx),%eax
  802af0:	3b 43 04             	cmp    0x4(%ebx),%eax
  802af3:	74 e4                	je     802ad9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802af5:	89 c2                	mov    %eax,%edx
  802af7:	c1 fa 1f             	sar    $0x1f,%edx
  802afa:	c1 ea 1b             	shr    $0x1b,%edx
  802afd:	01 d0                	add    %edx,%eax
  802aff:	83 e0 1f             	and    $0x1f,%eax
  802b02:	29 d0                	sub    %edx,%eax
  802b04:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802b09:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b0c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802b0f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b12:	83 c6 01             	add    $0x1,%esi
  802b15:	3b 75 10             	cmp    0x10(%ebp),%esi
  802b18:	74 0d                	je     802b27 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  802b1a:	8b 03                	mov    (%ebx),%eax
  802b1c:	3b 43 04             	cmp    0x4(%ebx),%eax
  802b1f:	75 d4                	jne    802af5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b21:	85 f6                	test   %esi,%esi
  802b23:	75 b0                	jne    802ad5 <devpipe_read+0x29>
  802b25:	eb b2                	jmp    802ad9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802b27:	89 f0                	mov    %esi,%eax
  802b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b30:	eb 05                	jmp    802b37 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b32:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802b37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802b3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802b3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802b40:	89 ec                	mov    %ebp,%esp
  802b42:	5d                   	pop    %ebp
  802b43:	c3                   	ret    

00802b44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802b44:	55                   	push   %ebp
  802b45:	89 e5                	mov    %esp,%ebp
  802b47:	83 ec 48             	sub    $0x48,%esp
  802b4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802b4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802b50:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802b53:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802b56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b59:	89 04 24             	mov    %eax,(%esp)
  802b5c:	e8 da ee ff ff       	call   801a3b <fd_alloc>
  802b61:	89 c3                	mov    %eax,%ebx
  802b63:	85 c0                	test   %eax,%eax
  802b65:	0f 88 45 01 00 00    	js     802cb0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802b6b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802b72:	00 
  802b73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b81:	e8 86 e7 ff ff       	call   80130c <sys_page_alloc>
  802b86:	89 c3                	mov    %eax,%ebx
  802b88:	85 c0                	test   %eax,%eax
  802b8a:	0f 88 20 01 00 00    	js     802cb0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802b90:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802b93:	89 04 24             	mov    %eax,(%esp)
  802b96:	e8 a0 ee ff ff       	call   801a3b <fd_alloc>
  802b9b:	89 c3                	mov    %eax,%ebx
  802b9d:	85 c0                	test   %eax,%eax
  802b9f:	0f 88 f8 00 00 00    	js     802c9d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ba5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802bac:	00 
  802bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bbb:	e8 4c e7 ff ff       	call   80130c <sys_page_alloc>
  802bc0:	89 c3                	mov    %eax,%ebx
  802bc2:	85 c0                	test   %eax,%eax
  802bc4:	0f 88 d3 00 00 00    	js     802c9d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802bca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bcd:	89 04 24             	mov    %eax,(%esp)
  802bd0:	e8 4b ee ff ff       	call   801a20 <fd2data>
  802bd5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bd7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802bde:	00 
  802bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  802be3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bea:	e8 1d e7 ff ff       	call   80130c <sys_page_alloc>
  802bef:	89 c3                	mov    %eax,%ebx
  802bf1:	85 c0                	test   %eax,%eax
  802bf3:	0f 88 91 00 00 00    	js     802c8a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802bfc:	89 04 24             	mov    %eax,(%esp)
  802bff:	e8 1c ee ff ff       	call   801a20 <fd2data>
  802c04:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802c0b:	00 
  802c0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802c17:	00 
  802c18:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c23:	e8 43 e7 ff ff       	call   80136b <sys_page_map>
  802c28:	89 c3                	mov    %eax,%ebx
  802c2a:	85 c0                	test   %eax,%eax
  802c2c:	78 4c                	js     802c7a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802c2e:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802c34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c37:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c3c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802c43:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802c49:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802c4c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802c51:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802c58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c5b:	89 04 24             	mov    %eax,(%esp)
  802c5e:	e8 ad ed ff ff       	call   801a10 <fd2num>
  802c63:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802c65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802c68:	89 04 24             	mov    %eax,(%esp)
  802c6b:	e8 a0 ed ff ff       	call   801a10 <fd2num>
  802c70:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c78:	eb 36                	jmp    802cb0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  802c7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c85:	e8 3f e7 ff ff       	call   8013c9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c98:	e8 2c e7 ff ff       	call   8013c9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ca4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cab:	e8 19 e7 ff ff       	call   8013c9 <sys_page_unmap>
    err:
	return r;
}
  802cb0:	89 d8                	mov    %ebx,%eax
  802cb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802cb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802cb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802cbb:	89 ec                	mov    %ebp,%esp
  802cbd:	5d                   	pop    %ebp
  802cbe:	c3                   	ret    

00802cbf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802cbf:	55                   	push   %ebp
  802cc0:	89 e5                	mov    %esp,%ebp
  802cc2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802cc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  802ccf:	89 04 24             	mov    %eax,(%esp)
  802cd2:	e8 d7 ed ff ff       	call   801aae <fd_lookup>
  802cd7:	85 c0                	test   %eax,%eax
  802cd9:	78 15                	js     802cf0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cde:	89 04 24             	mov    %eax,(%esp)
  802ce1:	e8 3a ed ff ff       	call   801a20 <fd2data>
	return _pipeisclosed(fd, p);
  802ce6:	89 c2                	mov    %eax,%edx
  802ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ceb:	e8 c2 fc ff ff       	call   8029b2 <_pipeisclosed>
}
  802cf0:	c9                   	leave  
  802cf1:	c3                   	ret    
	...

00802cf4 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802cf4:	55                   	push   %ebp
  802cf5:	89 e5                	mov    %esp,%ebp
  802cf7:	56                   	push   %esi
  802cf8:	53                   	push   %ebx
  802cf9:	83 ec 10             	sub    $0x10,%esp
  802cfc:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802cff:	85 c0                	test   %eax,%eax
  802d01:	75 24                	jne    802d27 <wait+0x33>
  802d03:	c7 44 24 0c 04 3a 80 	movl   $0x803a04,0xc(%esp)
  802d0a:	00 
  802d0b:	c7 44 24 08 ef 38 80 	movl   $0x8038ef,0x8(%esp)
  802d12:	00 
  802d13:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802d1a:	00 
  802d1b:	c7 04 24 0f 3a 80 00 	movl   $0x803a0f,(%esp)
  802d22:	e8 95 d8 ff ff       	call   8005bc <_panic>
	e = &envs[ENVX(envid)];
  802d27:	89 c3                	mov    %eax,%ebx
  802d29:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802d2f:	c1 e3 07             	shl    $0x7,%ebx
  802d32:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802d38:	8b 73 48             	mov    0x48(%ebx),%esi
  802d3b:	39 c6                	cmp    %eax,%esi
  802d3d:	75 1a                	jne    802d59 <wait+0x65>
  802d3f:	8b 43 54             	mov    0x54(%ebx),%eax
  802d42:	85 c0                	test   %eax,%eax
  802d44:	74 13                	je     802d59 <wait+0x65>
		sys_yield();
  802d46:	e8 91 e5 ff ff       	call   8012dc <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802d4b:	8b 43 48             	mov    0x48(%ebx),%eax
  802d4e:	39 f0                	cmp    %esi,%eax
  802d50:	75 07                	jne    802d59 <wait+0x65>
  802d52:	8b 43 54             	mov    0x54(%ebx),%eax
  802d55:	85 c0                	test   %eax,%eax
  802d57:	75 ed                	jne    802d46 <wait+0x52>
		sys_yield();
}
  802d59:	83 c4 10             	add    $0x10,%esp
  802d5c:	5b                   	pop    %ebx
  802d5d:	5e                   	pop    %esi
  802d5e:	5d                   	pop    %ebp
  802d5f:	c3                   	ret    

00802d60 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802d60:	55                   	push   %ebp
  802d61:	89 e5                	mov    %esp,%ebp
  802d63:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802d66:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802d6d:	75 3c                	jne    802dab <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802d6f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802d76:	00 
  802d77:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802d7e:	ee 
  802d7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d86:	e8 81 e5 ff ff       	call   80130c <sys_page_alloc>
  802d8b:	85 c0                	test   %eax,%eax
  802d8d:	79 1c                	jns    802dab <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  802d8f:	c7 44 24 08 1c 3a 80 	movl   $0x803a1c,0x8(%esp)
  802d96:	00 
  802d97:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802d9e:	00 
  802d9f:	c7 04 24 80 3a 80 00 	movl   $0x803a80,(%esp)
  802da6:	e8 11 d8 ff ff       	call   8005bc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802dab:	8b 45 08             	mov    0x8(%ebp),%eax
  802dae:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802db3:	c7 44 24 04 ec 2d 80 	movl   $0x802dec,0x4(%esp)
  802dba:	00 
  802dbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dc2:	e8 1c e7 ff ff       	call   8014e3 <sys_env_set_pgfault_upcall>
  802dc7:	85 c0                	test   %eax,%eax
  802dc9:	79 1c                	jns    802de7 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802dcb:	c7 44 24 08 48 3a 80 	movl   $0x803a48,0x8(%esp)
  802dd2:	00 
  802dd3:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  802dda:	00 
  802ddb:	c7 04 24 80 3a 80 00 	movl   $0x803a80,(%esp)
  802de2:	e8 d5 d7 ff ff       	call   8005bc <_panic>
}
  802de7:	c9                   	leave  
  802de8:	c3                   	ret    
  802de9:	00 00                	add    %al,(%eax)
	...

00802dec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802dec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ded:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802df2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802df4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  802df7:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  802dfb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802e00:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802e04:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  802e06:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802e09:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  802e0a:	83 c4 04             	add    $0x4,%esp
    popfl
  802e0d:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  802e0e:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  802e0f:	c3                   	ret    

00802e10 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e10:	55                   	push   %ebp
  802e11:	89 e5                	mov    %esp,%ebp
  802e13:	56                   	push   %esi
  802e14:	53                   	push   %ebx
  802e15:	83 ec 10             	sub    $0x10,%esp
  802e18:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e1e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802e21:	85 db                	test   %ebx,%ebx
  802e23:	74 06                	je     802e2b <ipc_recv+0x1b>
  802e25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  802e2b:	85 f6                	test   %esi,%esi
  802e2d:	74 06                	je     802e35 <ipc_recv+0x25>
  802e2f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802e35:	85 c0                	test   %eax,%eax
  802e37:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802e3c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  802e3f:	89 04 24             	mov    %eax,(%esp)
  802e42:	e8 2e e7 ff ff       	call   801575 <sys_ipc_recv>
    if (ret) return ret;
  802e47:	85 c0                	test   %eax,%eax
  802e49:	75 24                	jne    802e6f <ipc_recv+0x5f>
    if (from_env_store)
  802e4b:	85 db                	test   %ebx,%ebx
  802e4d:	74 0a                	je     802e59 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  802e4f:	a1 04 50 80 00       	mov    0x805004,%eax
  802e54:	8b 40 74             	mov    0x74(%eax),%eax
  802e57:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802e59:	85 f6                	test   %esi,%esi
  802e5b:	74 0a                	je     802e67 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  802e5d:	a1 04 50 80 00       	mov    0x805004,%eax
  802e62:	8b 40 78             	mov    0x78(%eax),%eax
  802e65:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802e67:	a1 04 50 80 00       	mov    0x805004,%eax
  802e6c:	8b 40 70             	mov    0x70(%eax),%eax
}
  802e6f:	83 c4 10             	add    $0x10,%esp
  802e72:	5b                   	pop    %ebx
  802e73:	5e                   	pop    %esi
  802e74:	5d                   	pop    %ebp
  802e75:	c3                   	ret    

00802e76 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e76:	55                   	push   %ebp
  802e77:	89 e5                	mov    %esp,%ebp
  802e79:	57                   	push   %edi
  802e7a:	56                   	push   %esi
  802e7b:	53                   	push   %ebx
  802e7c:	83 ec 1c             	sub    $0x1c,%esp
  802e7f:	8b 75 08             	mov    0x8(%ebp),%esi
  802e82:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802e88:	85 db                	test   %ebx,%ebx
  802e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802e8f:	0f 44 d8             	cmove  %eax,%ebx
  802e92:	eb 2a                	jmp    802ebe <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802e94:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e97:	74 20                	je     802eb9 <ipc_send+0x43>
  802e99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e9d:	c7 44 24 08 8e 3a 80 	movl   $0x803a8e,0x8(%esp)
  802ea4:	00 
  802ea5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  802eac:	00 
  802ead:	c7 04 24 a5 3a 80 00 	movl   $0x803aa5,(%esp)
  802eb4:	e8 03 d7 ff ff       	call   8005bc <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802eb9:	e8 1e e4 ff ff       	call   8012dc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802ebe:	8b 45 14             	mov    0x14(%ebp),%eax
  802ec1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ec5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ec9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802ecd:	89 34 24             	mov    %esi,(%esp)
  802ed0:	e8 6c e6 ff ff       	call   801541 <sys_ipc_try_send>
  802ed5:	85 c0                	test   %eax,%eax
  802ed7:	75 bb                	jne    802e94 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802ed9:	83 c4 1c             	add    $0x1c,%esp
  802edc:	5b                   	pop    %ebx
  802edd:	5e                   	pop    %esi
  802ede:	5f                   	pop    %edi
  802edf:	5d                   	pop    %ebp
  802ee0:	c3                   	ret    

00802ee1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802ee1:	55                   	push   %ebp
  802ee2:	89 e5                	mov    %esp,%ebp
  802ee4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802ee7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802eec:	39 c8                	cmp    %ecx,%eax
  802eee:	74 19                	je     802f09 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802ef0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802ef5:	89 c2                	mov    %eax,%edx
  802ef7:	c1 e2 07             	shl    $0x7,%edx
  802efa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802f00:	8b 52 50             	mov    0x50(%edx),%edx
  802f03:	39 ca                	cmp    %ecx,%edx
  802f05:	75 14                	jne    802f1b <ipc_find_env+0x3a>
  802f07:	eb 05                	jmp    802f0e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802f09:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802f0e:	c1 e0 07             	shl    $0x7,%eax
  802f11:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802f16:	8b 40 40             	mov    0x40(%eax),%eax
  802f19:	eb 0e                	jmp    802f29 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802f1b:	83 c0 01             	add    $0x1,%eax
  802f1e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802f23:	75 d0                	jne    802ef5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802f25:	66 b8 00 00          	mov    $0x0,%ax
}
  802f29:	5d                   	pop    %ebp
  802f2a:	c3                   	ret    
	...

00802f2c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f2c:	55                   	push   %ebp
  802f2d:	89 e5                	mov    %esp,%ebp
  802f2f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f32:	89 d0                	mov    %edx,%eax
  802f34:	c1 e8 16             	shr    $0x16,%eax
  802f37:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f3e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f43:	f6 c1 01             	test   $0x1,%cl
  802f46:	74 1d                	je     802f65 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f48:	c1 ea 0c             	shr    $0xc,%edx
  802f4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802f52:	f6 c2 01             	test   $0x1,%dl
  802f55:	74 0e                	je     802f65 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f57:	c1 ea 0c             	shr    $0xc,%edx
  802f5a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802f61:	ef 
  802f62:	0f b7 c0             	movzwl %ax,%eax
}
  802f65:	5d                   	pop    %ebp
  802f66:	c3                   	ret    
	...

00802f70 <__udivdi3>:
  802f70:	83 ec 1c             	sub    $0x1c,%esp
  802f73:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802f77:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  802f7b:	8b 44 24 20          	mov    0x20(%esp),%eax
  802f7f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802f83:	89 74 24 10          	mov    %esi,0x10(%esp)
  802f87:	8b 74 24 24          	mov    0x24(%esp),%esi
  802f8b:	85 ff                	test   %edi,%edi
  802f8d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802f91:	89 44 24 08          	mov    %eax,0x8(%esp)
  802f95:	89 cd                	mov    %ecx,%ebp
  802f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f9b:	75 33                	jne    802fd0 <__udivdi3+0x60>
  802f9d:	39 f1                	cmp    %esi,%ecx
  802f9f:	77 57                	ja     802ff8 <__udivdi3+0x88>
  802fa1:	85 c9                	test   %ecx,%ecx
  802fa3:	75 0b                	jne    802fb0 <__udivdi3+0x40>
  802fa5:	b8 01 00 00 00       	mov    $0x1,%eax
  802faa:	31 d2                	xor    %edx,%edx
  802fac:	f7 f1                	div    %ecx
  802fae:	89 c1                	mov    %eax,%ecx
  802fb0:	89 f0                	mov    %esi,%eax
  802fb2:	31 d2                	xor    %edx,%edx
  802fb4:	f7 f1                	div    %ecx
  802fb6:	89 c6                	mov    %eax,%esi
  802fb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  802fbc:	f7 f1                	div    %ecx
  802fbe:	89 f2                	mov    %esi,%edx
  802fc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  802fc4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802fc8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802fcc:	83 c4 1c             	add    $0x1c,%esp
  802fcf:	c3                   	ret    
  802fd0:	31 d2                	xor    %edx,%edx
  802fd2:	31 c0                	xor    %eax,%eax
  802fd4:	39 f7                	cmp    %esi,%edi
  802fd6:	77 e8                	ja     802fc0 <__udivdi3+0x50>
  802fd8:	0f bd cf             	bsr    %edi,%ecx
  802fdb:	83 f1 1f             	xor    $0x1f,%ecx
  802fde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802fe2:	75 2c                	jne    803010 <__udivdi3+0xa0>
  802fe4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802fe8:	76 04                	jbe    802fee <__udivdi3+0x7e>
  802fea:	39 f7                	cmp    %esi,%edi
  802fec:	73 d2                	jae    802fc0 <__udivdi3+0x50>
  802fee:	31 d2                	xor    %edx,%edx
  802ff0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ff5:	eb c9                	jmp    802fc0 <__udivdi3+0x50>
  802ff7:	90                   	nop
  802ff8:	89 f2                	mov    %esi,%edx
  802ffa:	f7 f1                	div    %ecx
  802ffc:	31 d2                	xor    %edx,%edx
  802ffe:	8b 74 24 10          	mov    0x10(%esp),%esi
  803002:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803006:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80300a:	83 c4 1c             	add    $0x1c,%esp
  80300d:	c3                   	ret    
  80300e:	66 90                	xchg   %ax,%ax
  803010:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803015:	b8 20 00 00 00       	mov    $0x20,%eax
  80301a:	89 ea                	mov    %ebp,%edx
  80301c:	2b 44 24 04          	sub    0x4(%esp),%eax
  803020:	d3 e7                	shl    %cl,%edi
  803022:	89 c1                	mov    %eax,%ecx
  803024:	d3 ea                	shr    %cl,%edx
  803026:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80302b:	09 fa                	or     %edi,%edx
  80302d:	89 f7                	mov    %esi,%edi
  80302f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803033:	89 f2                	mov    %esi,%edx
  803035:	8b 74 24 08          	mov    0x8(%esp),%esi
  803039:	d3 e5                	shl    %cl,%ebp
  80303b:	89 c1                	mov    %eax,%ecx
  80303d:	d3 ef                	shr    %cl,%edi
  80303f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803044:	d3 e2                	shl    %cl,%edx
  803046:	89 c1                	mov    %eax,%ecx
  803048:	d3 ee                	shr    %cl,%esi
  80304a:	09 d6                	or     %edx,%esi
  80304c:	89 fa                	mov    %edi,%edx
  80304e:	89 f0                	mov    %esi,%eax
  803050:	f7 74 24 0c          	divl   0xc(%esp)
  803054:	89 d7                	mov    %edx,%edi
  803056:	89 c6                	mov    %eax,%esi
  803058:	f7 e5                	mul    %ebp
  80305a:	39 d7                	cmp    %edx,%edi
  80305c:	72 22                	jb     803080 <__udivdi3+0x110>
  80305e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  803062:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803067:	d3 e5                	shl    %cl,%ebp
  803069:	39 c5                	cmp    %eax,%ebp
  80306b:	73 04                	jae    803071 <__udivdi3+0x101>
  80306d:	39 d7                	cmp    %edx,%edi
  80306f:	74 0f                	je     803080 <__udivdi3+0x110>
  803071:	89 f0                	mov    %esi,%eax
  803073:	31 d2                	xor    %edx,%edx
  803075:	e9 46 ff ff ff       	jmp    802fc0 <__udivdi3+0x50>
  80307a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803080:	8d 46 ff             	lea    -0x1(%esi),%eax
  803083:	31 d2                	xor    %edx,%edx
  803085:	8b 74 24 10          	mov    0x10(%esp),%esi
  803089:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80308d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  803091:	83 c4 1c             	add    $0x1c,%esp
  803094:	c3                   	ret    
	...

008030a0 <__umoddi3>:
  8030a0:	83 ec 1c             	sub    $0x1c,%esp
  8030a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8030a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8030ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8030af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8030b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8030b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8030bb:	85 ed                	test   %ebp,%ebp
  8030bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8030c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8030c5:	89 cf                	mov    %ecx,%edi
  8030c7:	89 04 24             	mov    %eax,(%esp)
  8030ca:	89 f2                	mov    %esi,%edx
  8030cc:	75 1a                	jne    8030e8 <__umoddi3+0x48>
  8030ce:	39 f1                	cmp    %esi,%ecx
  8030d0:	76 4e                	jbe    803120 <__umoddi3+0x80>
  8030d2:	f7 f1                	div    %ecx
  8030d4:	89 d0                	mov    %edx,%eax
  8030d6:	31 d2                	xor    %edx,%edx
  8030d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8030dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8030e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8030e4:	83 c4 1c             	add    $0x1c,%esp
  8030e7:	c3                   	ret    
  8030e8:	39 f5                	cmp    %esi,%ebp
  8030ea:	77 54                	ja     803140 <__umoddi3+0xa0>
  8030ec:	0f bd c5             	bsr    %ebp,%eax
  8030ef:	83 f0 1f             	xor    $0x1f,%eax
  8030f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030f6:	75 60                	jne    803158 <__umoddi3+0xb8>
  8030f8:	3b 0c 24             	cmp    (%esp),%ecx
  8030fb:	0f 87 07 01 00 00    	ja     803208 <__umoddi3+0x168>
  803101:	89 f2                	mov    %esi,%edx
  803103:	8b 34 24             	mov    (%esp),%esi
  803106:	29 ce                	sub    %ecx,%esi
  803108:	19 ea                	sbb    %ebp,%edx
  80310a:	89 34 24             	mov    %esi,(%esp)
  80310d:	8b 04 24             	mov    (%esp),%eax
  803110:	8b 74 24 10          	mov    0x10(%esp),%esi
  803114:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803118:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80311c:	83 c4 1c             	add    $0x1c,%esp
  80311f:	c3                   	ret    
  803120:	85 c9                	test   %ecx,%ecx
  803122:	75 0b                	jne    80312f <__umoddi3+0x8f>
  803124:	b8 01 00 00 00       	mov    $0x1,%eax
  803129:	31 d2                	xor    %edx,%edx
  80312b:	f7 f1                	div    %ecx
  80312d:	89 c1                	mov    %eax,%ecx
  80312f:	89 f0                	mov    %esi,%eax
  803131:	31 d2                	xor    %edx,%edx
  803133:	f7 f1                	div    %ecx
  803135:	8b 04 24             	mov    (%esp),%eax
  803138:	f7 f1                	div    %ecx
  80313a:	eb 98                	jmp    8030d4 <__umoddi3+0x34>
  80313c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803140:	89 f2                	mov    %esi,%edx
  803142:	8b 74 24 10          	mov    0x10(%esp),%esi
  803146:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80314a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80314e:	83 c4 1c             	add    $0x1c,%esp
  803151:	c3                   	ret    
  803152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803158:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80315d:	89 e8                	mov    %ebp,%eax
  80315f:	bd 20 00 00 00       	mov    $0x20,%ebp
  803164:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  803168:	89 fa                	mov    %edi,%edx
  80316a:	d3 e0                	shl    %cl,%eax
  80316c:	89 e9                	mov    %ebp,%ecx
  80316e:	d3 ea                	shr    %cl,%edx
  803170:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803175:	09 c2                	or     %eax,%edx
  803177:	8b 44 24 08          	mov    0x8(%esp),%eax
  80317b:	89 14 24             	mov    %edx,(%esp)
  80317e:	89 f2                	mov    %esi,%edx
  803180:	d3 e7                	shl    %cl,%edi
  803182:	89 e9                	mov    %ebp,%ecx
  803184:	d3 ea                	shr    %cl,%edx
  803186:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80318b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80318f:	d3 e6                	shl    %cl,%esi
  803191:	89 e9                	mov    %ebp,%ecx
  803193:	d3 e8                	shr    %cl,%eax
  803195:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80319a:	09 f0                	or     %esi,%eax
  80319c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8031a0:	f7 34 24             	divl   (%esp)
  8031a3:	d3 e6                	shl    %cl,%esi
  8031a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8031a9:	89 d6                	mov    %edx,%esi
  8031ab:	f7 e7                	mul    %edi
  8031ad:	39 d6                	cmp    %edx,%esi
  8031af:	89 c1                	mov    %eax,%ecx
  8031b1:	89 d7                	mov    %edx,%edi
  8031b3:	72 3f                	jb     8031f4 <__umoddi3+0x154>
  8031b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8031b9:	72 35                	jb     8031f0 <__umoddi3+0x150>
  8031bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8031bf:	29 c8                	sub    %ecx,%eax
  8031c1:	19 fe                	sbb    %edi,%esi
  8031c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8031c8:	89 f2                	mov    %esi,%edx
  8031ca:	d3 e8                	shr    %cl,%eax
  8031cc:	89 e9                	mov    %ebp,%ecx
  8031ce:	d3 e2                	shl    %cl,%edx
  8031d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8031d5:	09 d0                	or     %edx,%eax
  8031d7:	89 f2                	mov    %esi,%edx
  8031d9:	d3 ea                	shr    %cl,%edx
  8031db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8031df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8031e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8031e7:	83 c4 1c             	add    $0x1c,%esp
  8031ea:	c3                   	ret    
  8031eb:	90                   	nop
  8031ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031f0:	39 d6                	cmp    %edx,%esi
  8031f2:	75 c7                	jne    8031bb <__umoddi3+0x11b>
  8031f4:	89 d7                	mov    %edx,%edi
  8031f6:	89 c1                	mov    %eax,%ecx
  8031f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8031fc:	1b 3c 24             	sbb    (%esp),%edi
  8031ff:	eb ba                	jmp    8031bb <__umoddi3+0x11b>
  803201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803208:	39 f5                	cmp    %esi,%ebp
  80320a:	0f 82 f1 fe ff ff    	jb     803101 <__umoddi3+0x61>
  803210:	e9 f8 fe ff ff       	jmp    80310d <__umoddi3+0x6d>
