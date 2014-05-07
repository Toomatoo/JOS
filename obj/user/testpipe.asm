
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 e7 02 00 00       	call   800318 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 40 80 00 e0 	movl   $0x802ae0,0x804004
  800043:	2a 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 03 22 00 00       	call   802254 <pipe>
  800051:	89 c6                	mov    %eax,%esi
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", i);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 ec 2a 80 	movl   $0x802aec,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  800072:	e8 0d 03 00 00       	call   800384 <_panic>

	if ((pid = fork()) < 0)
  800077:	e8 6b 14 00 00       	call   8014e7 <fork>
  80007c:	89 c3                	mov    %eax,%ebx
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", i);
  800082:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800086:	c7 44 24 08 05 2b 80 	movl   $0x802b05,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  80009d:	e8 e2 02 00 00       	call   800384 <_panic>

	if (pid == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 85 d5 00 00 00    	jne    80017f <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000aa:	a1 04 50 80 00       	mov    0x805004,%eax
  8000af:	8b 40 48             	mov    0x48(%eax),%eax
  8000b2:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 0e 2b 80 00 	movl   $0x802b0e,(%esp)
  8000c4:	e8 b6 03 00 00       	call   80047f <cprintf>
		close(p[1]);
  8000c9:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 e9 18 00 00       	call   8019bd <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d4:	a1 04 50 80 00       	mov    0x805004,%eax
  8000d9:	8b 40 48             	mov    0x48(%eax),%eax
  8000dc:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e7:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  8000ee:	e8 8c 03 00 00       	call   80047f <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f3:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000fa:	00 
  8000fb:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 b1 1a 00 00       	call   801bbe <readn>
  80010d:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0xff>
			panic("read: %e", i);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  80012e:	e8 51 02 00 00       	call   800384 <_panic>
		buf[i] = 0;
  800133:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800138:	a1 00 40 80 00       	mov    0x804000,%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 3f 0b 00 00       	call   800c8b <strcmp>
  80014c:	85 c0                	test   %eax,%eax
  80014e:	75 0e                	jne    80015e <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  800150:	c7 04 24 51 2b 80 00 	movl   $0x802b51,(%esp)
  800157:	e8 23 03 00 00       	call   80047f <cprintf>
  80015c:	eb 17                	jmp    800175 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015e:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	89 74 24 04          	mov    %esi,0x4(%esp)
  800169:	c7 04 24 6d 2b 80 00 	movl   $0x802b6d,(%esp)
  800170:	e8 0a 03 00 00       	call   80047f <cprintf>
		exit();
  800175:	e8 ee 01 00 00       	call   800368 <exit>
  80017a:	e9 ac 00 00 00       	jmp    80022b <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017f:	a1 04 50 80 00       	mov    0x805004,%eax
  800184:	8b 40 48             	mov    0x48(%eax),%eax
  800187:	8b 55 8c             	mov    -0x74(%ebp),%edx
  80018a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 0e 2b 80 00 	movl   $0x802b0e,(%esp)
  800199:	e8 e1 02 00 00       	call   80047f <cprintf>
		close(p[0]);
  80019e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 14 18 00 00       	call   8019bd <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a9:	a1 04 50 80 00       	mov    0x805004,%eax
  8001ae:	8b 40 48             	mov    0x48(%eax),%eax
  8001b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  8001c3:	e8 b7 02 00 00       	call   80047f <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c8:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 ab 09 00 00       	call   800b80 <strlen>
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	a1 00 40 80 00       	mov    0x804000,%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 21 1a 00 00       	call   801c0e <write>
  8001ed:	89 c6                	mov    %eax,%esi
  8001ef:	a1 00 40 80 00       	mov    0x804000,%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 84 09 00 00       	call   800b80 <strlen>
  8001fc:	39 c6                	cmp    %eax,%esi
  8001fe:	74 20                	je     800220 <umain+0x1ec>
			panic("write: %e", i);
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	c7 44 24 08 9d 2b 80 	movl   $0x802b9d,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  80021b:	e8 64 01 00 00       	call   800384 <_panic>
		close(p[1]);
  800220:	8b 45 90             	mov    -0x70(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	e8 92 17 00 00       	call   8019bd <close>
	}
	wait(pid);
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	e8 d1 21 00 00       	call   802404 <wait>

	binaryname = "pipewriteeof";
  800233:	c7 05 04 40 80 00 a7 	movl   $0x802ba7,0x804004
  80023a:	2b 80 00 
	if ((i = pipe(p)) < 0)
  80023d:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 0c 20 00 00       	call   802254 <pipe>
  800248:	89 c6                	mov    %eax,%esi
  80024a:	85 c0                	test   %eax,%eax
  80024c:	79 20                	jns    80026e <umain+0x23a>
		panic("pipe: %e", i);
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	c7 44 24 08 ec 2a 80 	movl   $0x802aec,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  800269:	e8 16 01 00 00       	call   800384 <_panic>

	if ((pid = fork()) < 0)
  80026e:	e8 74 12 00 00       	call   8014e7 <fork>
  800273:	89 c3                	mov    %eax,%ebx
  800275:	85 c0                	test   %eax,%eax
  800277:	79 20                	jns    800299 <umain+0x265>
		panic("fork: %e", i);
  800279:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027d:	c7 44 24 08 05 2b 80 	movl   $0x802b05,0x8(%esp)
  800284:	00 
  800285:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028c:	00 
  80028d:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  800294:	e8 eb 00 00 00       	call   800384 <_panic>

	if (pid == 0) {
  800299:	85 c0                	test   %eax,%eax
  80029b:	75 48                	jne    8002e5 <umain+0x2b1>
		close(p[0]);
  80029d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 15 17 00 00       	call   8019bd <close>
		while (1) {
			cprintf(".");
  8002a8:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8002af:	e8 cb 01 00 00       	call   80047f <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002bb:	00 
  8002bc:	c7 44 24 04 b6 2b 80 	movl   $0x802bb6,0x4(%esp)
  8002c3:	00 
  8002c4:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 3f 19 00 00       	call   801c0e <write>
  8002cf:	83 f8 01             	cmp    $0x1,%eax
  8002d2:	74 d4                	je     8002a8 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d4:	c7 04 24 b8 2b 80 00 	movl   $0x802bb8,(%esp)
  8002db:	e8 9f 01 00 00       	call   80047f <cprintf>
		exit();
  8002e0:	e8 83 00 00 00       	call   800368 <exit>
	}
	close(p[0]);
  8002e5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 cd 16 00 00       	call   8019bd <close>
	close(p[1]);
  8002f0:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 c2 16 00 00       	call   8019bd <close>
	wait(pid);
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	e8 01 21 00 00       	call   802404 <wait>

	cprintf("pipe tests passed\n");
  800303:	c7 04 24 d5 2b 80 00 	movl   $0x802bd5,(%esp)
  80030a:	e8 70 01 00 00       	call   80047f <cprintf>
}
  80030f:	83 ec 80             	sub    $0xffffff80,%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    
	...

00800318 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 18             	sub    $0x18,%esp
  80031e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800321:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800324:	8b 75 08             	mov    0x8(%ebp),%esi
  800327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80032a:	e8 3d 0d 00 00       	call   80106c <sys_getenvid>
  80032f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800334:	c1 e0 07             	shl    $0x7,%eax
  800337:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80033c:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800341:	85 f6                	test   %esi,%esi
  800343:	7e 07                	jle    80034c <libmain+0x34>
		binaryname = argv[0];
  800345:	8b 03                	mov    (%ebx),%eax
  800347:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  80034c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800350:	89 34 24             	mov    %esi,(%esp)
  800353:	e8 dc fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800358:	e8 0b 00 00 00       	call   800368 <exit>
}
  80035d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800360:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800363:	89 ec                	mov    %ebp,%esp
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    
	...

00800368 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80036e:	e8 7b 16 00 00       	call   8019ee <close_all>
	sys_env_destroy(0);
  800373:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80037a:	e8 90 0c 00 00       	call   80100f <sys_env_destroy>
}
  80037f:	c9                   	leave  
  800380:	c3                   	ret    
  800381:	00 00                	add    %al,(%eax)
	...

00800384 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80038f:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  800395:	e8 d2 0c 00 00       	call   80106c <sys_getenvid>
  80039a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	c7 04 24 38 2c 80 00 	movl   $0x802c38,(%esp)
  8003b7:	e8 c3 00 00 00       	call   80047f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	e8 53 00 00 00       	call   80041e <vcprintf>
	cprintf("\n");
  8003cb:	c7 04 24 bf 2f 80 00 	movl   $0x802fbf,(%esp)
  8003d2:	e8 a8 00 00 00       	call   80047f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003d7:	cc                   	int3   
  8003d8:	eb fd                	jmp    8003d7 <_panic+0x53>
	...

008003dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	53                   	push   %ebx
  8003e0:	83 ec 14             	sub    $0x14,%esp
  8003e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e6:	8b 03                	mov    (%ebx),%eax
  8003e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003ef:	83 c0 01             	add    $0x1,%eax
  8003f2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f9:	75 19                	jne    800414 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800402:	00 
  800403:	8d 43 08             	lea    0x8(%ebx),%eax
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	e8 a2 0b 00 00       	call   800fb0 <sys_cputs>
		b->idx = 0;
  80040e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800414:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800418:	83 c4 14             	add    $0x14,%esp
  80041b:	5b                   	pop    %ebx
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800427:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042e:	00 00 00 
	b.cnt = 0;
  800431:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800438:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	89 44 24 08          	mov    %eax,0x8(%esp)
  800449:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80044f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800453:	c7 04 24 dc 03 80 00 	movl   $0x8003dc,(%esp)
  80045a:	e8 97 01 00 00       	call   8005f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80045f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800465:	89 44 24 04          	mov    %eax,0x4(%esp)
  800469:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	e8 39 0b 00 00       	call   800fb0 <sys_cputs>

	return b.cnt;
}
  800477:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047d:	c9                   	leave  
  80047e:	c3                   	ret    

0080047f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800485:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	8b 45 08             	mov    0x8(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 87 ff ff ff       	call   80041e <vcprintf>
	va_end(ap);

	return cnt;
}
  800497:	c9                   	leave  
  800498:	c3                   	ret    
  800499:	00 00                	add    %al,(%eax)
	...

0080049c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 3c             	sub    $0x3c,%esp
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	89 d7                	mov    %edx,%edi
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004c4:	72 11                	jb     8004d7 <printnum+0x3b>
  8004c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004cc:	76 09                	jbe    8004d7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004ce:	83 eb 01             	sub    $0x1,%ebx
  8004d1:	85 db                	test   %ebx,%ebx
  8004d3:	7f 51                	jg     800526 <printnum+0x8a>
  8004d5:	eb 5e                	jmp    800535 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004db:	83 eb 01             	sub    $0x1,%ebx
  8004de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004ed:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f8:	00 
  8004f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800502:	89 44 24 04          	mov    %eax,0x4(%esp)
  800506:	e8 25 23 00 00       	call   802830 <__udivdi3>
  80050b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800513:	89 04 24             	mov    %eax,(%esp)
  800516:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051a:	89 fa                	mov    %edi,%edx
  80051c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051f:	e8 78 ff ff ff       	call   80049c <printnum>
  800524:	eb 0f                	jmp    800535 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800526:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052a:	89 34 24             	mov    %esi,(%esp)
  80052d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800530:	83 eb 01             	sub    $0x1,%ebx
  800533:	75 f1                	jne    800526 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800535:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800539:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80053d:	8b 45 10             	mov    0x10(%ebp),%eax
  800540:	89 44 24 08          	mov    %eax,0x8(%esp)
  800544:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054b:	00 
  80054c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	e8 02 24 00 00       	call   802960 <__umoddi3>
  80055e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800562:	0f be 80 5b 2c 80 00 	movsbl 0x802c5b(%eax),%eax
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056f:	83 c4 3c             	add    $0x3c,%esp
  800572:	5b                   	pop    %ebx
  800573:	5e                   	pop    %esi
  800574:	5f                   	pop    %edi
  800575:	5d                   	pop    %ebp
  800576:	c3                   	ret    

00800577 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80057a:	83 fa 01             	cmp    $0x1,%edx
  80057d:	7e 0e                	jle    80058d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057f:	8b 10                	mov    (%eax),%edx
  800581:	8d 4a 08             	lea    0x8(%edx),%ecx
  800584:	89 08                	mov    %ecx,(%eax)
  800586:	8b 02                	mov    (%edx),%eax
  800588:	8b 52 04             	mov    0x4(%edx),%edx
  80058b:	eb 22                	jmp    8005af <getuint+0x38>
	else if (lflag)
  80058d:	85 d2                	test   %edx,%edx
  80058f:	74 10                	je     8005a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800591:	8b 10                	mov    (%eax),%edx
  800593:	8d 4a 04             	lea    0x4(%edx),%ecx
  800596:	89 08                	mov    %ecx,(%eax)
  800598:	8b 02                	mov    (%edx),%eax
  80059a:	ba 00 00 00 00       	mov    $0x0,%edx
  80059f:	eb 0e                	jmp    8005af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a6:	89 08                	mov    %ecx,(%eax)
  8005a8:	8b 02                	mov    (%edx),%eax
  8005aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005af:	5d                   	pop    %ebp
  8005b0:	c3                   	ret    

008005b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005bb:	8b 10                	mov    (%eax),%edx
  8005bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c0:	73 0a                	jae    8005cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8005c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c5:	88 0a                	mov    %cl,(%edx)
  8005c7:	83 c2 01             	add    $0x1,%edx
  8005ca:	89 10                	mov    %edx,(%eax)
}
  8005cc:	5d                   	pop    %ebp
  8005cd:	c3                   	ret    

008005ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
  8005d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005db:	8b 45 10             	mov    0x10(%ebp),%eax
  8005de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 02 00 00 00       	call   8005f6 <vprintfmt>
	va_end(ap);
}
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	57                   	push   %edi
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
  8005fc:	83 ec 5c             	sub    $0x5c,%esp
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	8b 75 10             	mov    0x10(%ebp),%esi
  800605:	eb 12                	jmp    800619 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800607:	85 c0                	test   %eax,%eax
  800609:	0f 84 e4 04 00 00    	je     800af3 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800619:	0f b6 06             	movzbl (%esi),%eax
  80061c:	83 c6 01             	add    $0x1,%esi
  80061f:	83 f8 25             	cmp    $0x25,%eax
  800622:	75 e3                	jne    800607 <vprintfmt+0x11>
  800624:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800628:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80062f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800634:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800640:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800643:	eb 2b                	jmp    800670 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800648:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80064c:	eb 22                	jmp    800670 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800651:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800655:	eb 19                	jmp    800670 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80065a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800661:	eb 0d                	jmp    800670 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800663:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800666:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800669:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	0f b6 06             	movzbl (%esi),%eax
  800673:	0f b6 d0             	movzbl %al,%edx
  800676:	8d 7e 01             	lea    0x1(%esi),%edi
  800679:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80067c:	83 e8 23             	sub    $0x23,%eax
  80067f:	3c 55                	cmp    $0x55,%al
  800681:	0f 87 46 04 00 00    	ja     800acd <vprintfmt+0x4d7>
  800687:	0f b6 c0             	movzbl %al,%eax
  80068a:	ff 24 85 c0 2d 80 00 	jmp    *0x802dc0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800691:	83 ea 30             	sub    $0x30,%edx
  800694:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800697:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80069b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8006a1:	83 fa 09             	cmp    $0x9,%edx
  8006a4:	77 4a                	ja     8006f0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006ac:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006af:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006b3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006b6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006b9:	83 fa 09             	cmp    $0x9,%edx
  8006bc:	76 eb                	jbe    8006a9 <vprintfmt+0xb3>
  8006be:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8006c1:	eb 2d                	jmp    8006f0 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 04             	lea    0x4(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006d4:	eb 1a                	jmp    8006f0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8006d9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006dd:	79 91                	jns    800670 <vprintfmt+0x7a>
  8006df:	e9 73 ff ff ff       	jmp    800657 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8006ee:	eb 80                	jmp    800670 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8006f0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006f4:	0f 89 76 ff ff ff    	jns    800670 <vprintfmt+0x7a>
  8006fa:	e9 64 ff ff ff       	jmp    800663 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006ff:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800705:	e9 66 ff ff ff       	jmp    800670 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800717:	8b 00                	mov    (%eax),%eax
  800719:	89 04 24             	mov    %eax,(%esp)
  80071c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800722:	e9 f2 fe ff ff       	jmp    800619 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800727:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80072b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80072e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800732:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800735:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800739:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80073c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80073f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800743:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800746:	80 f9 09             	cmp    $0x9,%cl
  800749:	77 1d                	ja     800768 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80074b:	0f be c0             	movsbl %al,%eax
  80074e:	6b c0 64             	imul   $0x64,%eax,%eax
  800751:	0f be d2             	movsbl %dl,%edx
  800754:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800757:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80075e:	a3 08 40 80 00       	mov    %eax,0x804008
  800763:	e9 b1 fe ff ff       	jmp    800619 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800768:	c7 44 24 04 73 2c 80 	movl   $0x802c73,0x4(%esp)
  80076f:	00 
  800770:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 10 05 00 00       	call   800c8b <strcmp>
  80077b:	85 c0                	test   %eax,%eax
  80077d:	75 0f                	jne    80078e <vprintfmt+0x198>
  80077f:	c7 05 08 40 80 00 04 	movl   $0x4,0x804008
  800786:	00 00 00 
  800789:	e9 8b fe ff ff       	jmp    800619 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80078e:	c7 44 24 04 77 2c 80 	movl   $0x802c77,0x4(%esp)
  800795:	00 
  800796:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800799:	89 14 24             	mov    %edx,(%esp)
  80079c:	e8 ea 04 00 00       	call   800c8b <strcmp>
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	75 0f                	jne    8007b4 <vprintfmt+0x1be>
  8007a5:	c7 05 08 40 80 00 02 	movl   $0x2,0x804008
  8007ac:	00 00 00 
  8007af:	e9 65 fe ff ff       	jmp    800619 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8007b4:	c7 44 24 04 7b 2c 80 	movl   $0x802c7b,0x4(%esp)
  8007bb:	00 
  8007bc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8007bf:	89 0c 24             	mov    %ecx,(%esp)
  8007c2:	e8 c4 04 00 00       	call   800c8b <strcmp>
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	75 0f                	jne    8007da <vprintfmt+0x1e4>
  8007cb:	c7 05 08 40 80 00 01 	movl   $0x1,0x804008
  8007d2:	00 00 00 
  8007d5:	e9 3f fe ff ff       	jmp    800619 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8007da:	c7 44 24 04 7f 2c 80 	movl   $0x802c7f,0x4(%esp)
  8007e1:	00 
  8007e2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8007e5:	89 3c 24             	mov    %edi,(%esp)
  8007e8:	e8 9e 04 00 00       	call   800c8b <strcmp>
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	75 0f                	jne    800800 <vprintfmt+0x20a>
  8007f1:	c7 05 08 40 80 00 06 	movl   $0x6,0x804008
  8007f8:	00 00 00 
  8007fb:	e9 19 fe ff ff       	jmp    800619 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800800:	c7 44 24 04 83 2c 80 	movl   $0x802c83,0x4(%esp)
  800807:	00 
  800808:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80080b:	89 04 24             	mov    %eax,(%esp)
  80080e:	e8 78 04 00 00       	call   800c8b <strcmp>
  800813:	85 c0                	test   %eax,%eax
  800815:	75 0f                	jne    800826 <vprintfmt+0x230>
  800817:	c7 05 08 40 80 00 07 	movl   $0x7,0x804008
  80081e:	00 00 00 
  800821:	e9 f3 fd ff ff       	jmp    800619 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800826:	c7 44 24 04 87 2c 80 	movl   $0x802c87,0x4(%esp)
  80082d:	00 
  80082e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800831:	89 14 24             	mov    %edx,(%esp)
  800834:	e8 52 04 00 00       	call   800c8b <strcmp>
  800839:	83 f8 01             	cmp    $0x1,%eax
  80083c:	19 c0                	sbb    %eax,%eax
  80083e:	f7 d0                	not    %eax
  800840:	83 c0 08             	add    $0x8,%eax
  800843:	a3 08 40 80 00       	mov    %eax,0x804008
  800848:	e9 cc fd ff ff       	jmp    800619 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8d 50 04             	lea    0x4(%eax),%edx
  800853:	89 55 14             	mov    %edx,0x14(%ebp)
  800856:	8b 00                	mov    (%eax),%eax
  800858:	89 c2                	mov    %eax,%edx
  80085a:	c1 fa 1f             	sar    $0x1f,%edx
  80085d:	31 d0                	xor    %edx,%eax
  80085f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800861:	83 f8 0f             	cmp    $0xf,%eax
  800864:	7f 0b                	jg     800871 <vprintfmt+0x27b>
  800866:	8b 14 85 20 2f 80 00 	mov    0x802f20(,%eax,4),%edx
  80086d:	85 d2                	test   %edx,%edx
  80086f:	75 23                	jne    800894 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800871:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800875:	c7 44 24 08 8b 2c 80 	movl   $0x802c8b,0x8(%esp)
  80087c:	00 
  80087d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	89 3c 24             	mov    %edi,(%esp)
  800887:	e8 42 fd ff ff       	call   8005ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80088f:	e9 85 fd ff ff       	jmp    800619 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800894:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800898:	c7 44 24 08 e1 31 80 	movl   $0x8031e1,0x8(%esp)
  80089f:	00 
  8008a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a7:	89 3c 24             	mov    %edi,(%esp)
  8008aa:	e8 1f fd ff ff       	call   8005ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008b2:	e9 62 fd ff ff       	jmp    800619 <vprintfmt+0x23>
  8008b7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8008ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008bd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c3:	8d 50 04             	lea    0x4(%eax),%edx
  8008c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008cb:	85 f6                	test   %esi,%esi
  8008cd:	b8 6c 2c 80 00       	mov    $0x802c6c,%eax
  8008d2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8008d5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8008d9:	7e 06                	jle    8008e1 <vprintfmt+0x2eb>
  8008db:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8008df:	75 13                	jne    8008f4 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e1:	0f be 06             	movsbl (%esi),%eax
  8008e4:	83 c6 01             	add    $0x1,%esi
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	0f 85 94 00 00 00    	jne    800983 <vprintfmt+0x38d>
  8008ef:	e9 81 00 00 00       	jmp    800975 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f8:	89 34 24             	mov    %esi,(%esp)
  8008fb:	e8 9b 02 00 00       	call   800b9b <strnlen>
  800900:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800903:	29 c2                	sub    %eax,%edx
  800905:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800908:	85 d2                	test   %edx,%edx
  80090a:	7e d5                	jle    8008e1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80090c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800910:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800913:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800916:	89 d6                	mov    %edx,%esi
  800918:	89 cf                	mov    %ecx,%edi
  80091a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091e:	89 3c 24             	mov    %edi,(%esp)
  800921:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800924:	83 ee 01             	sub    $0x1,%esi
  800927:	75 f1                	jne    80091a <vprintfmt+0x324>
  800929:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80092c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80092f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800932:	eb ad                	jmp    8008e1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800934:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800938:	74 1b                	je     800955 <vprintfmt+0x35f>
  80093a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80093d:	83 fa 5e             	cmp    $0x5e,%edx
  800940:	76 13                	jbe    800955 <vprintfmt+0x35f>
					putch('?', putdat);
  800942:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800950:	ff 55 08             	call   *0x8(%ebp)
  800953:	eb 0d                	jmp    800962 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800955:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800958:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800962:	83 eb 01             	sub    $0x1,%ebx
  800965:	0f be 06             	movsbl (%esi),%eax
  800968:	83 c6 01             	add    $0x1,%esi
  80096b:	85 c0                	test   %eax,%eax
  80096d:	75 1a                	jne    800989 <vprintfmt+0x393>
  80096f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800972:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800975:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800978:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80097c:	7f 1c                	jg     80099a <vprintfmt+0x3a4>
  80097e:	e9 96 fc ff ff       	jmp    800619 <vprintfmt+0x23>
  800983:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800986:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800989:	85 ff                	test   %edi,%edi
  80098b:	78 a7                	js     800934 <vprintfmt+0x33e>
  80098d:	83 ef 01             	sub    $0x1,%edi
  800990:	79 a2                	jns    800934 <vprintfmt+0x33e>
  800992:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800995:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800998:	eb db                	jmp    800975 <vprintfmt+0x37f>
  80099a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099d:	89 de                	mov    %ebx,%esi
  80099f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009ad:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009af:	83 eb 01             	sub    $0x1,%ebx
  8009b2:	75 ee                	jne    8009a2 <vprintfmt+0x3ac>
  8009b4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009b9:	e9 5b fc ff ff       	jmp    800619 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009be:	83 f9 01             	cmp    $0x1,%ecx
  8009c1:	7e 10                	jle    8009d3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	8d 50 08             	lea    0x8(%eax),%edx
  8009c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cc:	8b 30                	mov    (%eax),%esi
  8009ce:	8b 78 04             	mov    0x4(%eax),%edi
  8009d1:	eb 26                	jmp    8009f9 <vprintfmt+0x403>
	else if (lflag)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 12                	je     8009e9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8009d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009da:	8d 50 04             	lea    0x4(%eax),%edx
  8009dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e0:	8b 30                	mov    (%eax),%esi
  8009e2:	89 f7                	mov    %esi,%edi
  8009e4:	c1 ff 1f             	sar    $0x1f,%edi
  8009e7:	eb 10                	jmp    8009f9 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8009e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ec:	8d 50 04             	lea    0x4(%eax),%edx
  8009ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f2:	8b 30                	mov    (%eax),%esi
  8009f4:	89 f7                	mov    %esi,%edi
  8009f6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009f9:	85 ff                	test   %edi,%edi
  8009fb:	78 0e                	js     800a0b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009fd:	89 f0                	mov    %esi,%eax
  8009ff:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a01:	be 0a 00 00 00       	mov    $0xa,%esi
  800a06:	e9 84 00 00 00       	jmp    800a8f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a16:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a19:	89 f0                	mov    %esi,%eax
  800a1b:	89 fa                	mov    %edi,%edx
  800a1d:	f7 d8                	neg    %eax
  800a1f:	83 d2 00             	adc    $0x0,%edx
  800a22:	f7 da                	neg    %edx
			}
			base = 10;
  800a24:	be 0a 00 00 00       	mov    $0xa,%esi
  800a29:	eb 64                	jmp    800a8f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a2b:	89 ca                	mov    %ecx,%edx
  800a2d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a30:	e8 42 fb ff ff       	call   800577 <getuint>
			base = 10;
  800a35:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800a3a:	eb 53                	jmp    800a8f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a3c:	89 ca                	mov    %ecx,%edx
  800a3e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a41:	e8 31 fb ff ff       	call   800577 <getuint>
    			base = 8;
  800a46:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800a4b:	eb 42                	jmp    800a8f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800a4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a51:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a58:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a66:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a69:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6c:	8d 50 04             	lea    0x4(%eax),%edx
  800a6f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a72:	8b 00                	mov    (%eax),%eax
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a79:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800a7e:	eb 0f                	jmp    800a8f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a80:	89 ca                	mov    %ecx,%edx
  800a82:	8d 45 14             	lea    0x14(%ebp),%eax
  800a85:	e8 ed fa ff ff       	call   800577 <getuint>
			base = 16;
  800a8a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a8f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800a93:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800a97:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800a9a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a9e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800aa2:	89 04 24             	mov    %eax,(%esp)
  800aa5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa9:	89 da                	mov    %ebx,%edx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	e8 e9 f9 ff ff       	call   80049c <printnum>
			break;
  800ab3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ab6:	e9 5e fb ff ff       	jmp    800619 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800abb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800abf:	89 14 24             	mov    %edx,(%esp)
  800ac2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ac8:	e9 4c fb ff ff       	jmp    800619 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800acd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800adb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800adf:	0f 84 34 fb ff ff    	je     800619 <vprintfmt+0x23>
  800ae5:	83 ee 01             	sub    $0x1,%esi
  800ae8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aec:	75 f7                	jne    800ae5 <vprintfmt+0x4ef>
  800aee:	e9 26 fb ff ff       	jmp    800619 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800af3:	83 c4 5c             	add    $0x5c,%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 28             	sub    $0x28,%esp
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
  800b04:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b07:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b0a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b0e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	74 30                	je     800b4c <vsnprintf+0x51>
  800b1c:	85 d2                	test   %edx,%edx
  800b1e:	7e 2c                	jle    800b4c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b20:	8b 45 14             	mov    0x14(%ebp),%eax
  800b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b27:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b35:	c7 04 24 b1 05 80 00 	movl   $0x8005b1,(%esp)
  800b3c:	e8 b5 fa ff ff       	call   8005f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b44:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b4a:	eb 05                	jmp    800b51 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b59:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b60:	8b 45 10             	mov    0x10(%ebp),%eax
  800b63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	89 04 24             	mov    %eax,(%esp)
  800b74:	e8 82 ff ff ff       	call   800afb <vsnprintf>
	va_end(ap);

	return rc;
}
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    
  800b7b:	00 00                	add    %al,(%eax)
  800b7d:	00 00                	add    %al,(%eax)
	...

00800b80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b8e:	74 09                	je     800b99 <strlen+0x19>
		n++;
  800b90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b97:	75 f7                	jne    800b90 <strlen+0x10>
		n++;
	return n;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	85 c9                	test   %ecx,%ecx
  800bac:	74 1a                	je     800bc8 <strnlen+0x2d>
  800bae:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bb1:	74 15                	je     800bc8 <strnlen+0x2d>
  800bb3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800bb8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bba:	39 ca                	cmp    %ecx,%edx
  800bbc:	74 0a                	je     800bc8 <strnlen+0x2d>
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800bc6:	75 f0                	jne    800bb8 <strnlen+0x1d>
		n++;
	return n;
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bde:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800be1:	83 c2 01             	add    $0x1,%edx
  800be4:	84 c9                	test   %cl,%cl
  800be6:	75 f2                	jne    800bda <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bf5:	89 1c 24             	mov    %ebx,(%esp)
  800bf8:	e8 83 ff ff ff       	call   800b80 <strlen>
	strcpy(dst + len, src);
  800bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c00:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c04:	01 d8                	add    %ebx,%eax
  800c06:	89 04 24             	mov    %eax,(%esp)
  800c09:	e8 bd ff ff ff       	call   800bcb <strcpy>
	return dst;
}
  800c0e:	89 d8                	mov    %ebx,%eax
  800c10:	83 c4 08             	add    $0x8,%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c24:	85 f6                	test   %esi,%esi
  800c26:	74 18                	je     800c40 <strncpy+0x2a>
  800c28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c2d:	0f b6 1a             	movzbl (%edx),%ebx
  800c30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c33:	80 3a 01             	cmpb   $0x1,(%edx)
  800c36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c39:	83 c1 01             	add    $0x1,%ecx
  800c3c:	39 f1                	cmp    %esi,%ecx
  800c3e:	75 ed                	jne    800c2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c50:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c53:	89 f8                	mov    %edi,%eax
  800c55:	85 f6                	test   %esi,%esi
  800c57:	74 2b                	je     800c84 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c59:	83 fe 01             	cmp    $0x1,%esi
  800c5c:	74 23                	je     800c81 <strlcpy+0x3d>
  800c5e:	0f b6 0b             	movzbl (%ebx),%ecx
  800c61:	84 c9                	test   %cl,%cl
  800c63:	74 1c                	je     800c81 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c65:	83 ee 02             	sub    $0x2,%esi
  800c68:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c6d:	88 08                	mov    %cl,(%eax)
  800c6f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c72:	39 f2                	cmp    %esi,%edx
  800c74:	74 0b                	je     800c81 <strlcpy+0x3d>
  800c76:	83 c2 01             	add    $0x1,%edx
  800c79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c7d:	84 c9                	test   %cl,%cl
  800c7f:	75 ec                	jne    800c6d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c81:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c84:	29 f8                	sub    %edi,%eax
}
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c94:	0f b6 01             	movzbl (%ecx),%eax
  800c97:	84 c0                	test   %al,%al
  800c99:	74 16                	je     800cb1 <strcmp+0x26>
  800c9b:	3a 02                	cmp    (%edx),%al
  800c9d:	75 12                	jne    800cb1 <strcmp+0x26>
		p++, q++;
  800c9f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ca2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ca6:	84 c0                	test   %al,%al
  800ca8:	74 07                	je     800cb1 <strcmp+0x26>
  800caa:	83 c1 01             	add    $0x1,%ecx
  800cad:	3a 02                	cmp    (%edx),%al
  800caf:	74 ee                	je     800c9f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb1:	0f b6 c0             	movzbl %al,%eax
  800cb4:	0f b6 12             	movzbl (%edx),%edx
  800cb7:	29 d0                	sub    %edx,%eax
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	53                   	push   %ebx
  800cbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ccd:	85 d2                	test   %edx,%edx
  800ccf:	74 28                	je     800cf9 <strncmp+0x3e>
  800cd1:	0f b6 01             	movzbl (%ecx),%eax
  800cd4:	84 c0                	test   %al,%al
  800cd6:	74 24                	je     800cfc <strncmp+0x41>
  800cd8:	3a 03                	cmp    (%ebx),%al
  800cda:	75 20                	jne    800cfc <strncmp+0x41>
  800cdc:	83 ea 01             	sub    $0x1,%edx
  800cdf:	74 13                	je     800cf4 <strncmp+0x39>
		n--, p++, q++;
  800ce1:	83 c1 01             	add    $0x1,%ecx
  800ce4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ce7:	0f b6 01             	movzbl (%ecx),%eax
  800cea:	84 c0                	test   %al,%al
  800cec:	74 0e                	je     800cfc <strncmp+0x41>
  800cee:	3a 03                	cmp    (%ebx),%al
  800cf0:	74 ea                	je     800cdc <strncmp+0x21>
  800cf2:	eb 08                	jmp    800cfc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cf4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cfc:	0f b6 01             	movzbl (%ecx),%eax
  800cff:	0f b6 13             	movzbl (%ebx),%edx
  800d02:	29 d0                	sub    %edx,%eax
  800d04:	eb f3                	jmp    800cf9 <strncmp+0x3e>

00800d06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d10:	0f b6 10             	movzbl (%eax),%edx
  800d13:	84 d2                	test   %dl,%dl
  800d15:	74 1c                	je     800d33 <strchr+0x2d>
		if (*s == c)
  800d17:	38 ca                	cmp    %cl,%dl
  800d19:	75 09                	jne    800d24 <strchr+0x1e>
  800d1b:	eb 1b                	jmp    800d38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d1d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800d20:	38 ca                	cmp    %cl,%dl
  800d22:	74 14                	je     800d38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d24:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	75 f1                	jne    800d1d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	eb 05                	jmp    800d38 <strchr+0x32>
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d44:	0f b6 10             	movzbl (%eax),%edx
  800d47:	84 d2                	test   %dl,%dl
  800d49:	74 14                	je     800d5f <strfind+0x25>
		if (*s == c)
  800d4b:	38 ca                	cmp    %cl,%dl
  800d4d:	75 06                	jne    800d55 <strfind+0x1b>
  800d4f:	eb 0e                	jmp    800d5f <strfind+0x25>
  800d51:	38 ca                	cmp    %cl,%dl
  800d53:	74 0a                	je     800d5f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d55:	83 c0 01             	add    $0x1,%eax
  800d58:	0f b6 10             	movzbl (%eax),%edx
  800d5b:	84 d2                	test   %dl,%dl
  800d5d:	75 f2                	jne    800d51 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d79:	85 c9                	test   %ecx,%ecx
  800d7b:	74 30                	je     800dad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d83:	75 25                	jne    800daa <memset+0x49>
  800d85:	f6 c1 03             	test   $0x3,%cl
  800d88:	75 20                	jne    800daa <memset+0x49>
		c &= 0xFF;
  800d8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d8d:	89 d3                	mov    %edx,%ebx
  800d8f:	c1 e3 08             	shl    $0x8,%ebx
  800d92:	89 d6                	mov    %edx,%esi
  800d94:	c1 e6 18             	shl    $0x18,%esi
  800d97:	89 d0                	mov    %edx,%eax
  800d99:	c1 e0 10             	shl    $0x10,%eax
  800d9c:	09 f0                	or     %esi,%eax
  800d9e:	09 d0                	or     %edx,%eax
  800da0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800da2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800da5:	fc                   	cld    
  800da6:	f3 ab                	rep stos %eax,%es:(%edi)
  800da8:	eb 03                	jmp    800dad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800daa:	fc                   	cld    
  800dab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dad:	89 f8                	mov    %edi,%eax
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 08             	sub    $0x8,%esp
  800dc2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dd1:	39 c6                	cmp    %eax,%esi
  800dd3:	73 36                	jae    800e0b <memmove+0x4f>
  800dd5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dd8:	39 d0                	cmp    %edx,%eax
  800dda:	73 2f                	jae    800e0b <memmove+0x4f>
		s += n;
		d += n;
  800ddc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ddf:	f6 c2 03             	test   $0x3,%dl
  800de2:	75 1b                	jne    800dff <memmove+0x43>
  800de4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dea:	75 13                	jne    800dff <memmove+0x43>
  800dec:	f6 c1 03             	test   $0x3,%cl
  800def:	75 0e                	jne    800dff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800df1:	83 ef 04             	sub    $0x4,%edi
  800df4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800df7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800dfa:	fd                   	std    
  800dfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dfd:	eb 09                	jmp    800e08 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800dff:	83 ef 01             	sub    $0x1,%edi
  800e02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e05:	fd                   	std    
  800e06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e08:	fc                   	cld    
  800e09:	eb 20                	jmp    800e2b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e11:	75 13                	jne    800e26 <memmove+0x6a>
  800e13:	a8 03                	test   $0x3,%al
  800e15:	75 0f                	jne    800e26 <memmove+0x6a>
  800e17:	f6 c1 03             	test   $0x3,%cl
  800e1a:	75 0a                	jne    800e26 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e1c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e1f:	89 c7                	mov    %eax,%edi
  800e21:	fc                   	cld    
  800e22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e24:	eb 05                	jmp    800e2b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e26:	89 c7                	mov    %eax,%edi
  800e28:	fc                   	cld    
  800e29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e31:	89 ec                	mov    %ebp,%esp
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	89 04 24             	mov    %eax,(%esp)
  800e4f:	e8 68 ff ff ff       	call   800dbc <memmove>
}
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e62:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6a:	85 ff                	test   %edi,%edi
  800e6c:	74 37                	je     800ea5 <memcmp+0x4f>
		if (*s1 != *s2)
  800e6e:	0f b6 03             	movzbl (%ebx),%eax
  800e71:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e74:	83 ef 01             	sub    $0x1,%edi
  800e77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e7c:	38 c8                	cmp    %cl,%al
  800e7e:	74 1c                	je     800e9c <memcmp+0x46>
  800e80:	eb 10                	jmp    800e92 <memcmp+0x3c>
  800e82:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e87:	83 c2 01             	add    $0x1,%edx
  800e8a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e8e:	38 c8                	cmp    %cl,%al
  800e90:	74 0a                	je     800e9c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e92:	0f b6 c0             	movzbl %al,%eax
  800e95:	0f b6 c9             	movzbl %cl,%ecx
  800e98:	29 c8                	sub    %ecx,%eax
  800e9a:	eb 09                	jmp    800ea5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e9c:	39 fa                	cmp    %edi,%edx
  800e9e:	75 e2                	jne    800e82 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eb5:	39 d0                	cmp    %edx,%eax
  800eb7:	73 19                	jae    800ed2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ebd:	38 08                	cmp    %cl,(%eax)
  800ebf:	75 06                	jne    800ec7 <memfind+0x1d>
  800ec1:	eb 0f                	jmp    800ed2 <memfind+0x28>
  800ec3:	38 08                	cmp    %cl,(%eax)
  800ec5:	74 0b                	je     800ed2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec7:	83 c0 01             	add    $0x1,%eax
  800eca:	39 d0                	cmp    %edx,%eax
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	75 f1                	jne    800ec3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee0:	0f b6 02             	movzbl (%edx),%eax
  800ee3:	3c 20                	cmp    $0x20,%al
  800ee5:	74 04                	je     800eeb <strtol+0x17>
  800ee7:	3c 09                	cmp    $0x9,%al
  800ee9:	75 0e                	jne    800ef9 <strtol+0x25>
		s++;
  800eeb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eee:	0f b6 02             	movzbl (%edx),%eax
  800ef1:	3c 20                	cmp    $0x20,%al
  800ef3:	74 f6                	je     800eeb <strtol+0x17>
  800ef5:	3c 09                	cmp    $0x9,%al
  800ef7:	74 f2                	je     800eeb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ef9:	3c 2b                	cmp    $0x2b,%al
  800efb:	75 0a                	jne    800f07 <strtol+0x33>
		s++;
  800efd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f00:	bf 00 00 00 00       	mov    $0x0,%edi
  800f05:	eb 10                	jmp    800f17 <strtol+0x43>
  800f07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f0c:	3c 2d                	cmp    $0x2d,%al
  800f0e:	75 07                	jne    800f17 <strtol+0x43>
		s++, neg = 1;
  800f10:	83 c2 01             	add    $0x1,%edx
  800f13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f17:	85 db                	test   %ebx,%ebx
  800f19:	0f 94 c0             	sete   %al
  800f1c:	74 05                	je     800f23 <strtol+0x4f>
  800f1e:	83 fb 10             	cmp    $0x10,%ebx
  800f21:	75 15                	jne    800f38 <strtol+0x64>
  800f23:	80 3a 30             	cmpb   $0x30,(%edx)
  800f26:	75 10                	jne    800f38 <strtol+0x64>
  800f28:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f2c:	75 0a                	jne    800f38 <strtol+0x64>
		s += 2, base = 16;
  800f2e:	83 c2 02             	add    $0x2,%edx
  800f31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f36:	eb 13                	jmp    800f4b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800f38:	84 c0                	test   %al,%al
  800f3a:	74 0f                	je     800f4b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f41:	80 3a 30             	cmpb   $0x30,(%edx)
  800f44:	75 05                	jne    800f4b <strtol+0x77>
		s++, base = 8;
  800f46:	83 c2 01             	add    $0x1,%edx
  800f49:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f52:	0f b6 0a             	movzbl (%edx),%ecx
  800f55:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f58:	80 fb 09             	cmp    $0x9,%bl
  800f5b:	77 08                	ja     800f65 <strtol+0x91>
			dig = *s - '0';
  800f5d:	0f be c9             	movsbl %cl,%ecx
  800f60:	83 e9 30             	sub    $0x30,%ecx
  800f63:	eb 1e                	jmp    800f83 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f65:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f68:	80 fb 19             	cmp    $0x19,%bl
  800f6b:	77 08                	ja     800f75 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f6d:	0f be c9             	movsbl %cl,%ecx
  800f70:	83 e9 57             	sub    $0x57,%ecx
  800f73:	eb 0e                	jmp    800f83 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f75:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f78:	80 fb 19             	cmp    $0x19,%bl
  800f7b:	77 14                	ja     800f91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f7d:	0f be c9             	movsbl %cl,%ecx
  800f80:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f83:	39 f1                	cmp    %esi,%ecx
  800f85:	7d 0e                	jge    800f95 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f87:	83 c2 01             	add    $0x1,%edx
  800f8a:	0f af c6             	imul   %esi,%eax
  800f8d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f8f:	eb c1                	jmp    800f52 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f91:	89 c1                	mov    %eax,%ecx
  800f93:	eb 02                	jmp    800f97 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f95:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f9b:	74 05                	je     800fa2 <strtol+0xce>
		*endptr = (char *) s;
  800f9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fa0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fa2:	89 ca                	mov    %ecx,%edx
  800fa4:	f7 da                	neg    %edx
  800fa6:	85 ff                	test   %edi,%edi
  800fa8:	0f 45 c2             	cmovne %edx,%eax
}
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fbc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	89 c7                	mov    %eax,%edi
  800fce:	89 c6                	mov    %eax,%esi
  800fd0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fdb:	89 ec                	mov    %ebp,%esp
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800feb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff8:	89 d1                	mov    %edx,%ecx
  800ffa:	89 d3                	mov    %edx,%ebx
  800ffc:	89 d7                	mov    %edx,%edi
  800ffe:	89 d6                	mov    %edx,%esi
  801000:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801002:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801005:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801008:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80100b:	89 ec                	mov    %ebp,%esp
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 38             	sub    $0x38,%esp
  801015:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801018:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80101b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801023:	b8 03 00 00 00       	mov    $0x3,%eax
  801028:	8b 55 08             	mov    0x8(%ebp),%edx
  80102b:	89 cb                	mov    %ecx,%ebx
  80102d:	89 cf                	mov    %ecx,%edi
  80102f:	89 ce                	mov    %ecx,%esi
  801031:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	7e 28                	jle    80105f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801037:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801042:	00 
  801043:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  80104a:	00 
  80104b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801052:	00 
  801053:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  80105a:	e8 25 f3 ff ff       	call   800384 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80105f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801062:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801065:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801068:	89 ec                	mov    %ebp,%esp
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801075:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801078:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107b:	ba 00 00 00 00       	mov    $0x0,%edx
  801080:	b8 02 00 00 00       	mov    $0x2,%eax
  801085:	89 d1                	mov    %edx,%ecx
  801087:	89 d3                	mov    %edx,%ebx
  801089:	89 d7                	mov    %edx,%edi
  80108b:	89 d6                	mov    %edx,%esi
  80108d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80108f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801092:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801095:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801098:	89 ec                	mov    %ebp,%esp
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <sys_yield>:

void
sys_yield(void)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	89 d3                	mov    %edx,%ebx
  8010b9:	89 d7                	mov    %edx,%edi
  8010bb:	89 d6                	mov    %edx,%esi
  8010bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c8:	89 ec                	mov    %ebp,%esp
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 38             	sub    $0x38,%esp
  8010d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010db:	be 00 00 00 00       	mov    $0x0,%esi
  8010e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ee:	89 f7                	mov    %esi,%edi
  8010f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	7e 28                	jle    80111e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010fa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801101:	00 
  801102:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  801109:	00 
  80110a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801111:	00 
  801112:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  801119:	e8 66 f2 ff ff       	call   800384 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80111e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801121:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801124:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801127:	89 ec                	mov    %ebp,%esp
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 38             	sub    $0x38,%esp
  801131:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801134:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801137:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113a:	b8 05 00 00 00       	mov    $0x5,%eax
  80113f:	8b 75 18             	mov    0x18(%ebp),%esi
  801142:	8b 7d 14             	mov    0x14(%ebp),%edi
  801145:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801148:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114b:	8b 55 08             	mov    0x8(%ebp),%edx
  80114e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801150:	85 c0                	test   %eax,%eax
  801152:	7e 28                	jle    80117c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801154:	89 44 24 10          	mov    %eax,0x10(%esp)
  801158:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80115f:	00 
  801160:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  801167:	00 
  801168:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80116f:	00 
  801170:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  801177:	e8 08 f2 ff ff       	call   800384 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80117c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80117f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801182:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801185:	89 ec                	mov    %ebp,%esp
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 38             	sub    $0x38,%esp
  80118f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801192:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801195:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801198:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119d:	b8 06 00 00 00       	mov    $0x6,%eax
  8011a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a8:	89 df                	mov    %ebx,%edi
  8011aa:	89 de                	mov    %ebx,%esi
  8011ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	7e 28                	jle    8011da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011bd:	00 
  8011be:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  8011c5:	00 
  8011c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011cd:	00 
  8011ce:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  8011d5:	e8 aa f1 ff ff       	call   800384 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e3:	89 ec                	mov    %ebp,%esp
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 38             	sub    $0x38,%esp
  8011ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
  801206:	89 df                	mov    %ebx,%edi
  801208:	89 de                	mov    %ebx,%esi
  80120a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	7e 28                	jle    801238 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801210:	89 44 24 10          	mov    %eax,0x10(%esp)
  801214:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80121b:	00 
  80121c:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  801223:	00 
  801224:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80122b:	00 
  80122c:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  801233:	e8 4c f1 ff ff       	call   800384 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801238:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80123b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80123e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801241:	89 ec                	mov    %ebp,%esp
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  801254:	bb 00 00 00 00       	mov    $0x0,%ebx
  801259:	b8 09 00 00 00       	mov    $0x9,%eax
  80125e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801261:	8b 55 08             	mov    0x8(%ebp),%edx
  801264:	89 df                	mov    %ebx,%edi
  801266:	89 de                	mov    %ebx,%esi
  801268:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80126a:	85 c0                	test   %eax,%eax
  80126c:	7e 28                	jle    801296 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801272:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801279:	00 
  80127a:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  801281:	00 
  801282:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801289:	00 
  80128a:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  801291:	e8 ee f0 ff ff       	call   800384 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801296:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801299:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80129c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80129f:	89 ec                	mov    %ebp,%esp
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 38             	sub    $0x38,%esp
  8012a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c2:	89 df                	mov    %ebx,%edi
  8012c4:	89 de                	mov    %ebx,%esi
  8012c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	7e 28                	jle    8012f4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012d7:	00 
  8012d8:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  8012df:	00 
  8012e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012e7:	00 
  8012e8:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  8012ef:	e8 90 f0 ff ff       	call   800384 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012fd:	89 ec                	mov    %ebp,%esp
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80130a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80130d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801310:	be 00 00 00 00       	mov    $0x0,%esi
  801315:	b8 0c 00 00 00       	mov    $0xc,%eax
  80131a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80131d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801323:	8b 55 08             	mov    0x8(%ebp),%edx
  801326:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801328:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80132b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80132e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801331:	89 ec                	mov    %ebp,%esp
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 38             	sub    $0x38,%esp
  80133b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80133e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801341:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801344:	b9 00 00 00 00       	mov    $0x0,%ecx
  801349:	b8 0d 00 00 00       	mov    $0xd,%eax
  80134e:	8b 55 08             	mov    0x8(%ebp),%edx
  801351:	89 cb                	mov    %ecx,%ebx
  801353:	89 cf                	mov    %ecx,%edi
  801355:	89 ce                	mov    %ecx,%esi
  801357:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801359:	85 c0                	test   %eax,%eax
  80135b:	7e 28                	jle    801385 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801361:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801368:	00 
  801369:	c7 44 24 08 7f 2f 80 	movl   $0x802f7f,0x8(%esp)
  801370:	00 
  801371:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801378:	00 
  801379:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  801380:	e8 ff ef ff ff       	call   800384 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801385:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801388:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80138b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80138e:	89 ec                	mov    %ebp,%esp
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80139b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80139e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013a6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8013ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ae:	89 cb                	mov    %ecx,%ebx
  8013b0:	89 cf                	mov    %ecx,%edi
  8013b2:	89 ce                	mov    %ecx,%esi
  8013b4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8013b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013bf:	89 ec                	mov    %ebp,%esp
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    
	...

008013c4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 24             	sub    $0x24,%esp
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8013ce:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  8013d0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8013d4:	75 1c                	jne    8013f2 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  8013d6:	c7 44 24 08 aa 2f 80 	movl   $0x802faa,0x8(%esp)
  8013dd:	00 
  8013de:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8013e5:	00 
  8013e6:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8013ed:	e8 92 ef ff ff       	call   800384 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  8013f2:	89 d8                	mov    %ebx,%eax
  8013f4:	c1 e8 0c             	shr    $0xc,%eax
  8013f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013fe:	f6 c4 08             	test   $0x8,%ah
  801401:	0f 84 be 00 00 00    	je     8014c5 <pgfault+0x101>
  801407:	89 d8                	mov    %ebx,%eax
  801409:	c1 e8 16             	shr    $0x16,%eax
  80140c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801413:	a8 01                	test   $0x1,%al
  801415:	0f 84 aa 00 00 00    	je     8014c5 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  80141b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801422:	00 
  801423:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80142a:	00 
  80142b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801432:	e8 95 fc ff ff       	call   8010cc <sys_page_alloc>
		if (r < 0)
  801437:	85 c0                	test   %eax,%eax
  801439:	79 20                	jns    80145b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80143b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143f:	c7 44 24 08 e4 2f 80 	movl   $0x802fe4,0x8(%esp)
  801446:	00 
  801447:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80144e:	00 
  80144f:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  801456:	e8 29 ef ff ff       	call   800384 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80145b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801461:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801468:	00 
  801469:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801474:	e8 bc f9 ff ff       	call   800e35 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801479:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801480:	00 
  801481:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801485:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80148c:	00 
  80148d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801494:	00 
  801495:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149c:	e8 8a fc ff ff       	call   80112b <sys_page_map>
		if (r < 0)
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	79 3c                	jns    8014e1 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  8014a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a9:	c7 44 24 08 0c 30 80 	movl   $0x80300c,0x8(%esp)
  8014b0:	00 
  8014b1:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8014b8:	00 
  8014b9:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8014c0:	e8 bf ee ff ff       	call   800384 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  8014c5:	c7 44 24 08 30 30 80 	movl   $0x803030,0x8(%esp)
  8014cc:	00 
  8014cd:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8014d4:	00 
  8014d5:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8014dc:	e8 a3 ee ff ff       	call   800384 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  8014e1:	83 c4 24             	add    $0x24,%esp
  8014e4:	5b                   	pop    %ebx
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	57                   	push   %edi
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014f0:	c7 04 24 c4 13 80 00 	movl   $0x8013c4,(%esp)
  8014f7:	e8 24 11 00 00       	call   802620 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014fc:	bf 07 00 00 00       	mov    $0x7,%edi
  801501:	89 f8                	mov    %edi,%eax
  801503:	cd 30                	int    $0x30
  801505:	89 c7                	mov    %eax,%edi
  801507:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	79 20                	jns    80152e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80150e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801512:	c7 44 24 08 50 30 80 	movl   $0x803050,0x8(%esp)
  801519:	00 
  80151a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801521:	00 
  801522:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  801529:	e8 56 ee ff ff       	call   800384 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80152e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801533:	85 c0                	test   %eax,%eax
  801535:	75 1c                	jne    801553 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801537:	e8 30 fb ff ff       	call   80106c <sys_getenvid>
  80153c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801541:	c1 e0 07             	shl    $0x7,%eax
  801544:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801549:	a3 04 50 80 00       	mov    %eax,0x805004
		//cprintf("child fork ok!\n");
		return 0;
  80154e:	e9 51 02 00 00       	jmp    8017a4 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801553:	89 d8                	mov    %ebx,%eax
  801555:	c1 e8 16             	shr    $0x16,%eax
  801558:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155f:	a8 01                	test   $0x1,%al
  801561:	0f 84 87 01 00 00    	je     8016ee <fork+0x207>
  801567:	89 d8                	mov    %ebx,%eax
  801569:	c1 e8 0c             	shr    $0xc,%eax
  80156c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801573:	f6 c2 01             	test   $0x1,%dl
  801576:	0f 84 72 01 00 00    	je     8016ee <fork+0x207>
  80157c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801583:	f6 c2 04             	test   $0x4,%dl
  801586:	0f 84 62 01 00 00    	je     8016ee <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80158c:	89 c6                	mov    %eax,%esi
  80158e:	c1 e6 0c             	shl    $0xc,%esi
  801591:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801597:	0f 84 51 01 00 00    	je     8016ee <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  80159d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a4:	f6 c6 04             	test   $0x4,%dh
  8015a7:	74 53                	je     8015fc <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8015a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015b9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015cf:	e8 57 fb ff ff       	call   80112b <sys_page_map>
		if (r < 0)
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	0f 89 12 01 00 00    	jns    8016ee <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  8015dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e0:	c7 44 24 08 70 30 80 	movl   $0x803070,0x8(%esp)
  8015e7:	00 
  8015e8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8015ef:	00 
  8015f0:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8015f7:	e8 88 ed ff ff       	call   800384 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  8015fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801603:	f6 c2 02             	test   $0x2,%dl
  801606:	75 10                	jne    801618 <fork+0x131>
  801608:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80160f:	f6 c4 08             	test   $0x8,%ah
  801612:	0f 84 8f 00 00 00    	je     8016a7 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801618:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80161f:	00 
  801620:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801627:	89 44 24 08          	mov    %eax,0x8(%esp)
  80162b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801636:	e8 f0 fa ff ff       	call   80112b <sys_page_map>
		if (r < 0)
  80163b:	85 c0                	test   %eax,%eax
  80163d:	79 20                	jns    80165f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80163f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801643:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  80164a:	00 
  80164b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801652:	00 
  801653:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  80165a:	e8 25 ed ff ff       	call   800384 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80165f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801666:	00 
  801667:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80166b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801672:	00 
  801673:	89 74 24 04          	mov    %esi,0x4(%esp)
  801677:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167e:	e8 a8 fa ff ff       	call   80112b <sys_page_map>
		if (r < 0)
  801683:	85 c0                	test   %eax,%eax
  801685:	79 67                	jns    8016ee <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801687:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80168b:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  801692:	00 
  801693:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80169a:	00 
  80169b:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8016a2:	e8 dd ec ff ff       	call   800384 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  8016a7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8016ae:	00 
  8016af:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c5:	e8 61 fa ff ff       	call   80112b <sys_page_map>
		if (r < 0)
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	79 20                	jns    8016ee <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8016ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d2:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  8016d9:	00 
  8016da:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8016e1:	00 
  8016e2:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8016e9:	e8 96 ec ff ff       	call   800384 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  8016ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8016f4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8016fa:	0f 85 53 fe ff ff    	jne    801553 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801700:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801707:	00 
  801708:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80170f:	ee 
  801710:	89 3c 24             	mov    %edi,(%esp)
  801713:	e8 b4 f9 ff ff       	call   8010cc <sys_page_alloc>
	if (res < 0)
  801718:	85 c0                	test   %eax,%eax
  80171a:	79 20                	jns    80173c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  80171c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801720:	c7 44 24 08 c0 30 80 	movl   $0x8030c0,0x8(%esp)
  801727:	00 
  801728:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80172f:	00 
  801730:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  801737:	e8 48 ec ff ff       	call   800384 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80173c:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  801743:	00 
  801744:	89 3c 24             	mov    %edi,(%esp)
  801747:	e8 57 fb ff ff       	call   8012a3 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80174c:	85 c0                	test   %eax,%eax
  80174e:	79 20                	jns    801770 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801750:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801754:	c7 44 24 08 e4 30 80 	movl   $0x8030e4,0x8(%esp)
  80175b:	00 
  80175c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801763:	00 
  801764:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  80176b:	e8 14 ec ff ff       	call   800384 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801770:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801777:	00 
  801778:	89 3c 24             	mov    %edi,(%esp)
  80177b:	e8 67 fa ff ff       	call   8011e7 <sys_env_set_status>
	if (res < 0)
  801780:	85 c0                	test   %eax,%eax
  801782:	79 20                	jns    8017a4 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801784:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801788:	c7 44 24 08 14 31 80 	movl   $0x803114,0x8(%esp)
  80178f:	00 
  801790:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801797:	00 
  801798:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  80179f:	e8 e0 eb ff ff       	call   800384 <_panic>

	return pid;
	//panic("fork not implemented");
}
  8017a4:	89 f8                	mov    %edi,%eax
  8017a6:	83 c4 3c             	add    $0x3c,%esp
  8017a9:	5b                   	pop    %ebx
  8017aa:	5e                   	pop    %esi
  8017ab:	5f                   	pop    %edi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <sfork>:

// Challenge!
int
sfork(void)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8017b4:	c7 44 24 08 cc 2f 80 	movl   $0x802fcc,0x8(%esp)
  8017bb:	00 
  8017bc:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8017c3:	00 
  8017c4:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8017cb:	e8 b4 eb ff ff       	call   800384 <_panic>

008017d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8017db:	c1 e8 0c             	shr    $0xc,%eax
}
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	89 04 24             	mov    %eax,(%esp)
  8017ec:	e8 df ff ff ff       	call   8017d0 <fd2num>
  8017f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8017f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801802:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801807:	a8 01                	test   $0x1,%al
  801809:	74 34                	je     80183f <fd_alloc+0x44>
  80180b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801810:	a8 01                	test   $0x1,%al
  801812:	74 32                	je     801846 <fd_alloc+0x4b>
  801814:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801819:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	c1 ea 16             	shr    $0x16,%edx
  801820:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801827:	f6 c2 01             	test   $0x1,%dl
  80182a:	74 1f                	je     80184b <fd_alloc+0x50>
  80182c:	89 c2                	mov    %eax,%edx
  80182e:	c1 ea 0c             	shr    $0xc,%edx
  801831:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801838:	f6 c2 01             	test   $0x1,%dl
  80183b:	75 17                	jne    801854 <fd_alloc+0x59>
  80183d:	eb 0c                	jmp    80184b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80183f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801844:	eb 05                	jmp    80184b <fd_alloc+0x50>
  801846:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80184b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80184d:	b8 00 00 00 00       	mov    $0x0,%eax
  801852:	eb 17                	jmp    80186b <fd_alloc+0x70>
  801854:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801859:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80185e:	75 b9                	jne    801819 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801860:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801866:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80186b:	5b                   	pop    %ebx
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801879:	83 fa 1f             	cmp    $0x1f,%edx
  80187c:	77 3f                	ja     8018bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80187e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801884:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801887:	89 d0                	mov    %edx,%eax
  801889:	c1 e8 16             	shr    $0x16,%eax
  80188c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801893:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801898:	f6 c1 01             	test   $0x1,%cl
  80189b:	74 20                	je     8018bd <fd_lookup+0x4f>
  80189d:	89 d0                	mov    %edx,%eax
  80189f:	c1 e8 0c             	shr    $0xc,%eax
  8018a2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8018ae:	f6 c1 01             	test   $0x1,%cl
  8018b1:	74 0a                	je     8018bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 14             	sub    $0x14,%esp
  8018c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8018cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8018d1:	39 0d 0c 40 80 00    	cmp    %ecx,0x80400c
  8018d7:	75 17                	jne    8018f0 <dev_lookup+0x31>
  8018d9:	eb 07                	jmp    8018e2 <dev_lookup+0x23>
  8018db:	39 0a                	cmp    %ecx,(%edx)
  8018dd:	75 11                	jne    8018f0 <dev_lookup+0x31>
  8018df:	90                   	nop
  8018e0:	eb 05                	jmp    8018e7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018e2:	ba 0c 40 80 00       	mov    $0x80400c,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8018e7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8018e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ee:	eb 35                	jmp    801925 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018f0:	83 c0 01             	add    $0x1,%eax
  8018f3:	8b 14 85 b8 31 80 00 	mov    0x8031b8(,%eax,4),%edx
  8018fa:	85 d2                	test   %edx,%edx
  8018fc:	75 dd                	jne    8018db <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8018fe:	a1 04 50 80 00       	mov    0x805004,%eax
  801903:	8b 40 48             	mov    0x48(%eax),%eax
  801906:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80190a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190e:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  801915:	e8 65 eb ff ff       	call   80047f <cprintf>
	*dev = 0;
  80191a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801920:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801925:	83 c4 14             	add    $0x14,%esp
  801928:	5b                   	pop    %ebx
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	83 ec 38             	sub    $0x38,%esp
  801931:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801934:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801937:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80193a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80193d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801941:	89 3c 24             	mov    %edi,(%esp)
  801944:	e8 87 fe ff ff       	call   8017d0 <fd2num>
  801949:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80194c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801950:	89 04 24             	mov    %eax,(%esp)
  801953:	e8 16 ff ff ff       	call   80186e <fd_lookup>
  801958:	89 c3                	mov    %eax,%ebx
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 05                	js     801963 <fd_close+0x38>
	    || fd != fd2)
  80195e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801961:	74 0e                	je     801971 <fd_close+0x46>
		return (must_exist ? r : 0);
  801963:	89 f0                	mov    %esi,%eax
  801965:	84 c0                	test   %al,%al
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
  80196c:	0f 44 d8             	cmove  %eax,%ebx
  80196f:	eb 3d                	jmp    8019ae <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801971:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801974:	89 44 24 04          	mov    %eax,0x4(%esp)
  801978:	8b 07                	mov    (%edi),%eax
  80197a:	89 04 24             	mov    %eax,(%esp)
  80197d:	e8 3d ff ff ff       	call   8018bf <dev_lookup>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	85 c0                	test   %eax,%eax
  801986:	78 16                	js     80199e <fd_close+0x73>
		if (dev->dev_close)
  801988:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80198b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80198e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801993:	85 c0                	test   %eax,%eax
  801995:	74 07                	je     80199e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801997:	89 3c 24             	mov    %edi,(%esp)
  80199a:	ff d0                	call   *%eax
  80199c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80199e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a9:	e8 db f7 ff ff       	call   801189 <sys_page_unmap>
	return r;
}
  8019ae:	89 d8                	mov    %ebx,%eax
  8019b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019b9:	89 ec                	mov    %ebp,%esp
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cd:	89 04 24             	mov    %eax,(%esp)
  8019d0:	e8 99 fe ff ff       	call   80186e <fd_lookup>
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 13                	js     8019ec <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019e0:	00 
  8019e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e4:	89 04 24             	mov    %eax,(%esp)
  8019e7:	e8 3f ff ff ff       	call   80192b <fd_close>
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <close_all>:

void
close_all(void)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8019f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8019fa:	89 1c 24             	mov    %ebx,(%esp)
  8019fd:	e8 bb ff ff ff       	call   8019bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a02:	83 c3 01             	add    $0x1,%ebx
  801a05:	83 fb 20             	cmp    $0x20,%ebx
  801a08:	75 f0                	jne    8019fa <close_all+0xc>
		close(i);
}
  801a0a:	83 c4 14             	add    $0x14,%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 58             	sub    $0x58,%esp
  801a16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a1f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a22:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 3a fe ff ff       	call   80186e <fd_lookup>
  801a34:	89 c3                	mov    %eax,%ebx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 e1 00 00 00    	js     801b1f <dup+0x10f>
		return r;
	close(newfdnum);
  801a3e:	89 3c 24             	mov    %edi,(%esp)
  801a41:	e8 77 ff ff ff       	call   8019bd <close>

	newfd = INDEX2FD(newfdnum);
  801a46:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a4c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	e8 86 fd ff ff       	call   8017e0 <fd2data>
  801a5a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a5c:	89 34 24             	mov    %esi,(%esp)
  801a5f:	e8 7c fd ff ff       	call   8017e0 <fd2data>
  801a64:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a67:	89 d8                	mov    %ebx,%eax
  801a69:	c1 e8 16             	shr    $0x16,%eax
  801a6c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a73:	a8 01                	test   $0x1,%al
  801a75:	74 46                	je     801abd <dup+0xad>
  801a77:	89 d8                	mov    %ebx,%eax
  801a79:	c1 e8 0c             	shr    $0xc,%eax
  801a7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a83:	f6 c2 01             	test   $0x1,%dl
  801a86:	74 35                	je     801abd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a88:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a8f:	25 07 0e 00 00       	and    $0xe07,%eax
  801a94:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aa6:	00 
  801aa7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab2:	e8 74 f6 ff ff       	call   80112b <sys_page_map>
  801ab7:	89 c3                	mov    %eax,%ebx
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 3b                	js     801af8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac0:	89 c2                	mov    %eax,%edx
  801ac2:	c1 ea 0c             	shr    $0xc,%edx
  801ac5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801acc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ad2:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ad6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ada:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ae1:	00 
  801ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aed:	e8 39 f6 ff ff       	call   80112b <sys_page_map>
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	85 c0                	test   %eax,%eax
  801af6:	79 25                	jns    801b1d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801af8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801afc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b03:	e8 81 f6 ff ff       	call   801189 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b16:	e8 6e f6 ff ff       	call   801189 <sys_page_unmap>
	return r;
  801b1b:	eb 02                	jmp    801b1f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801b1d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801b1f:	89 d8                	mov    %ebx,%eax
  801b21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b2a:	89 ec                	mov    %ebp,%esp
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	53                   	push   %ebx
  801b32:	83 ec 24             	sub    $0x24,%esp
  801b35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3f:	89 1c 24             	mov    %ebx,(%esp)
  801b42:	e8 27 fd ff ff       	call   80186e <fd_lookup>
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 6d                	js     801bb8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b55:	8b 00                	mov    (%eax),%eax
  801b57:	89 04 24             	mov    %eax,(%esp)
  801b5a:	e8 60 fd ff ff       	call   8018bf <dev_lookup>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 55                	js     801bb8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b66:	8b 50 08             	mov    0x8(%eax),%edx
  801b69:	83 e2 03             	and    $0x3,%edx
  801b6c:	83 fa 01             	cmp    $0x1,%edx
  801b6f:	75 23                	jne    801b94 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801b71:	a1 04 50 80 00       	mov    0x805004,%eax
  801b76:	8b 40 48             	mov    0x48(%eax),%eax
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b81:	c7 04 24 7d 31 80 00 	movl   $0x80317d,(%esp)
  801b88:	e8 f2 e8 ff ff       	call   80047f <cprintf>
		return -E_INVAL;
  801b8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b92:	eb 24                	jmp    801bb8 <read+0x8a>
	}
	if (!dev->dev_read)
  801b94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b97:	8b 52 08             	mov    0x8(%edx),%edx
  801b9a:	85 d2                	test   %edx,%edx
  801b9c:	74 15                	je     801bb3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ba1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bac:	89 04 24             	mov    %eax,(%esp)
  801baf:	ff d2                	call   *%edx
  801bb1:	eb 05                	jmp    801bb8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801bb3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801bb8:	83 c4 24             	add    $0x24,%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd2:	85 f6                	test   %esi,%esi
  801bd4:	74 30                	je     801c06 <readn+0x48>
  801bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801bdb:	89 f2                	mov    %esi,%edx
  801bdd:	29 c2                	sub    %eax,%edx
  801bdf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801be3:	03 45 0c             	add    0xc(%ebp),%eax
  801be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bea:	89 3c 24             	mov    %edi,(%esp)
  801bed:	e8 3c ff ff ff       	call   801b2e <read>
		if (m < 0)
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	78 10                	js     801c06 <readn+0x48>
			return m;
		if (m == 0)
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	74 0a                	je     801c04 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bfa:	01 c3                	add    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	39 f3                	cmp    %esi,%ebx
  801c00:	72 d9                	jb     801bdb <readn+0x1d>
  801c02:	eb 02                	jmp    801c06 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801c04:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801c06:	83 c4 1c             	add    $0x1c,%esp
  801c09:	5b                   	pop    %ebx
  801c0a:	5e                   	pop    %esi
  801c0b:	5f                   	pop    %edi
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	53                   	push   %ebx
  801c12:	83 ec 24             	sub    $0x24,%esp
  801c15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1f:	89 1c 24             	mov    %ebx,(%esp)
  801c22:	e8 47 fc ff ff       	call   80186e <fd_lookup>
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 68                	js     801c93 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c35:	8b 00                	mov    (%eax),%eax
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	e8 80 fc ff ff       	call   8018bf <dev_lookup>
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 50                	js     801c93 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c46:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c4a:	75 23                	jne    801c6f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801c4c:	a1 04 50 80 00       	mov    0x805004,%eax
  801c51:	8b 40 48             	mov    0x48(%eax),%eax
  801c54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5c:	c7 04 24 99 31 80 00 	movl   $0x803199,(%esp)
  801c63:	e8 17 e8 ff ff       	call   80047f <cprintf>
		return -E_INVAL;
  801c68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c6d:	eb 24                	jmp    801c93 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c72:	8b 52 0c             	mov    0xc(%edx),%edx
  801c75:	85 d2                	test   %edx,%edx
  801c77:	74 15                	je     801c8e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c79:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c7c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c83:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c87:	89 04 24             	mov    %eax,(%esp)
  801c8a:	ff d2                	call   *%edx
  801c8c:	eb 05                	jmp    801c93 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801c8e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801c93:	83 c4 24             	add    $0x24,%esp
  801c96:	5b                   	pop    %ebx
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <seek>:

int
seek(int fdnum, off_t offset)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca9:	89 04 24             	mov    %eax,(%esp)
  801cac:	e8 bd fb ff ff       	call   80186e <fd_lookup>
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	78 0e                	js     801cc3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801cb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801cb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cbb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 24             	sub    $0x24,%esp
  801ccc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ccf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd6:	89 1c 24             	mov    %ebx,(%esp)
  801cd9:	e8 90 fb ff ff       	call   80186e <fd_lookup>
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 61                	js     801d43 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cec:	8b 00                	mov    (%eax),%eax
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 c9 fb ff ff       	call   8018bf <dev_lookup>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 49                	js     801d43 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d01:	75 23                	jne    801d26 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801d03:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801d08:	8b 40 48             	mov    0x48(%eax),%eax
  801d0b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d13:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  801d1a:	e8 60 e7 ff ff       	call   80047f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801d1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d24:	eb 1d                	jmp    801d43 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801d26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d29:	8b 52 18             	mov    0x18(%edx),%edx
  801d2c:	85 d2                	test   %edx,%edx
  801d2e:	74 0e                	je     801d3e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d37:	89 04 24             	mov    %eax,(%esp)
  801d3a:	ff d2                	call   *%edx
  801d3c:	eb 05                	jmp    801d43 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801d3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801d43:	83 c4 24             	add    $0x24,%esp
  801d46:	5b                   	pop    %ebx
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	53                   	push   %ebx
  801d4d:	83 ec 24             	sub    $0x24,%esp
  801d50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	89 04 24             	mov    %eax,(%esp)
  801d60:	e8 09 fb ff ff       	call   80186e <fd_lookup>
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 52                	js     801dbb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d73:	8b 00                	mov    (%eax),%eax
  801d75:	89 04 24             	mov    %eax,(%esp)
  801d78:	e8 42 fb ff ff       	call   8018bf <dev_lookup>
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	78 3a                	js     801dbb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d84:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801d88:	74 2c                	je     801db6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d8a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d8d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d94:	00 00 00 
	stat->st_isdir = 0;
  801d97:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d9e:	00 00 00 
	stat->st_dev = dev;
  801da1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801da7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dae:	89 14 24             	mov    %edx,(%esp)
  801db1:	ff 50 14             	call   *0x14(%eax)
  801db4:	eb 05                	jmp    801dbb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801db6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801dbb:	83 c4 24             	add    $0x24,%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    

00801dc1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 18             	sub    $0x18,%esp
  801dc7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dca:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801dcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dd4:	00 
  801dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd8:	89 04 24             	mov    %eax,(%esp)
  801ddb:	e8 bc 01 00 00       	call   801f9c <open>
  801de0:	89 c3                	mov    %eax,%ebx
  801de2:	85 c0                	test   %eax,%eax
  801de4:	78 1b                	js     801e01 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ded:	89 1c 24             	mov    %ebx,(%esp)
  801df0:	e8 54 ff ff ff       	call   801d49 <fstat>
  801df5:	89 c6                	mov    %eax,%esi
	close(fd);
  801df7:	89 1c 24             	mov    %ebx,(%esp)
  801dfa:	e8 be fb ff ff       	call   8019bd <close>
	return r;
  801dff:	89 f3                	mov    %esi,%ebx
}
  801e01:	89 d8                	mov    %ebx,%eax
  801e03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e09:	89 ec                	mov    %ebp,%esp
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	00 00                	add    %al,(%eax)
	...

00801e10 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 18             	sub    $0x18,%esp
  801e16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e19:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e1c:	89 c3                	mov    %eax,%ebx
  801e1e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801e20:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801e27:	75 11                	jne    801e3a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801e29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801e30:	e8 6c 09 00 00       	call   8027a1 <ipc_find_env>
  801e35:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e3a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e41:	00 
  801e42:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e49:	00 
  801e4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e4e:	a1 00 50 80 00       	mov    0x805000,%eax
  801e53:	89 04 24             	mov    %eax,(%esp)
  801e56:	e8 db 08 00 00       	call   802736 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801e5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e62:	00 
  801e63:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6e:	e8 5d 08 00 00       	call   8026d0 <ipc_recv>
}
  801e73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e79:	89 ec                	mov    %ebp,%esp
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	53                   	push   %ebx
  801e81:	83 ec 14             	sub    $0x14,%esp
  801e84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e87:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e8d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e92:	ba 00 00 00 00       	mov    $0x0,%edx
  801e97:	b8 05 00 00 00       	mov    $0x5,%eax
  801e9c:	e8 6f ff ff ff       	call   801e10 <fsipc>
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 2b                	js     801ed0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ea5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801eac:	00 
  801ead:	89 1c 24             	mov    %ebx,(%esp)
  801eb0:	e8 16 ed ff ff       	call   800bcb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801eb5:	a1 80 60 80 00       	mov    0x806080,%eax
  801eba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ec0:	a1 84 60 80 00       	mov    0x806084,%eax
  801ec5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ed0:	83 c4 14             	add    $0x14,%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    

00801ed6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801edc:	8b 45 08             	mov    0x8(%ebp),%eax
  801edf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ee2:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  801eec:	b8 06 00 00 00       	mov    $0x6,%eax
  801ef1:	e8 1a ff ff ff       	call   801e10 <fsipc>
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 10             	sub    $0x10,%esp
  801f00:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	8b 40 0c             	mov    0xc(%eax),%eax
  801f09:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801f0e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801f14:	ba 00 00 00 00       	mov    $0x0,%edx
  801f19:	b8 03 00 00 00       	mov    $0x3,%eax
  801f1e:	e8 ed fe ff ff       	call   801e10 <fsipc>
  801f23:	89 c3                	mov    %eax,%ebx
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 6a                	js     801f93 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801f29:	39 c6                	cmp    %eax,%esi
  801f2b:	73 24                	jae    801f51 <devfile_read+0x59>
  801f2d:	c7 44 24 0c c8 31 80 	movl   $0x8031c8,0xc(%esp)
  801f34:	00 
  801f35:	c7 44 24 08 cf 31 80 	movl   $0x8031cf,0x8(%esp)
  801f3c:	00 
  801f3d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801f44:	00 
  801f45:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  801f4c:	e8 33 e4 ff ff       	call   800384 <_panic>
	assert(r <= PGSIZE);
  801f51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f56:	7e 24                	jle    801f7c <devfile_read+0x84>
  801f58:	c7 44 24 0c ef 31 80 	movl   $0x8031ef,0xc(%esp)
  801f5f:	00 
  801f60:	c7 44 24 08 cf 31 80 	movl   $0x8031cf,0x8(%esp)
  801f67:	00 
  801f68:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801f6f:	00 
  801f70:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  801f77:	e8 08 e4 ff ff       	call   800384 <_panic>
	memmove(buf, &fsipcbuf, r);
  801f7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f80:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f87:	00 
  801f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8b:	89 04 24             	mov    %eax,(%esp)
  801f8e:	e8 29 ee ff ff       	call   800dbc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	56                   	push   %esi
  801fa0:	53                   	push   %ebx
  801fa1:	83 ec 20             	sub    $0x20,%esp
  801fa4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801fa7:	89 34 24             	mov    %esi,(%esp)
  801faa:	e8 d1 eb ff ff       	call   800b80 <strlen>
		return -E_BAD_PATH;
  801faf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801fb4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801fb9:	7f 5e                	jg     802019 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801fbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbe:	89 04 24             	mov    %eax,(%esp)
  801fc1:	e8 35 f8 ff ff       	call   8017fb <fd_alloc>
  801fc6:	89 c3                	mov    %eax,%ebx
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 4d                	js     802019 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801fcc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fd0:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801fd7:	e8 ef eb ff ff       	call   800bcb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fdf:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801fe4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fe7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fec:	e8 1f fe ff ff       	call   801e10 <fsipc>
  801ff1:	89 c3                	mov    %eax,%ebx
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	79 15                	jns    80200c <open+0x70>
		fd_close(fd, 0);
  801ff7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ffe:	00 
  801fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802002:	89 04 24             	mov    %eax,(%esp)
  802005:	e8 21 f9 ff ff       	call   80192b <fd_close>
		return r;
  80200a:	eb 0d                	jmp    802019 <open+0x7d>
	}

	return fd2num(fd);
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	89 04 24             	mov    %eax,(%esp)
  802012:	e8 b9 f7 ff ff       	call   8017d0 <fd2num>
  802017:	89 c3                	mov    %eax,%ebx
}
  802019:	89 d8                	mov    %ebx,%eax
  80201b:	83 c4 20             	add    $0x20,%esp
  80201e:	5b                   	pop    %ebx
  80201f:	5e                   	pop    %esi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
	...

00802030 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	83 ec 18             	sub    $0x18,%esp
  802036:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802039:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80203c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80203f:	8b 45 08             	mov    0x8(%ebp),%eax
  802042:	89 04 24             	mov    %eax,(%esp)
  802045:	e8 96 f7 ff ff       	call   8017e0 <fd2data>
  80204a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80204c:	c7 44 24 04 fb 31 80 	movl   $0x8031fb,0x4(%esp)
  802053:	00 
  802054:	89 34 24             	mov    %esi,(%esp)
  802057:	e8 6f eb ff ff       	call   800bcb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80205c:	8b 43 04             	mov    0x4(%ebx),%eax
  80205f:	2b 03                	sub    (%ebx),%eax
  802061:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802067:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80206e:	00 00 00 
	stat->st_dev = &devpipe;
  802071:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  802078:	40 80 00 
	return 0;
}
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
  802080:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802083:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802086:	89 ec                	mov    %ebp,%esp
  802088:	5d                   	pop    %ebp
  802089:	c3                   	ret    

0080208a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	53                   	push   %ebx
  80208e:	83 ec 14             	sub    $0x14,%esp
  802091:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802098:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209f:	e8 e5 f0 ff ff       	call   801189 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020a4:	89 1c 24             	mov    %ebx,(%esp)
  8020a7:	e8 34 f7 ff ff       	call   8017e0 <fd2data>
  8020ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b7:	e8 cd f0 ff ff       	call   801189 <sys_page_unmap>
}
  8020bc:	83 c4 14             	add    $0x14,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    

008020c2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	57                   	push   %edi
  8020c6:	56                   	push   %esi
  8020c7:	53                   	push   %ebx
  8020c8:	83 ec 2c             	sub    $0x2c,%esp
  8020cb:	89 c7                	mov    %eax,%edi
  8020cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020d0:	a1 04 50 80 00       	mov    0x805004,%eax
  8020d5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020d8:	89 3c 24             	mov    %edi,(%esp)
  8020db:	e8 0c 07 00 00       	call   8027ec <pageref>
  8020e0:	89 c6                	mov    %eax,%esi
  8020e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 ff 06 00 00       	call   8027ec <pageref>
  8020ed:	39 c6                	cmp    %eax,%esi
  8020ef:	0f 94 c0             	sete   %al
  8020f2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020f5:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8020fb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020fe:	39 cb                	cmp    %ecx,%ebx
  802100:	75 08                	jne    80210a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802102:	83 c4 2c             	add    $0x2c,%esp
  802105:	5b                   	pop    %ebx
  802106:	5e                   	pop    %esi
  802107:	5f                   	pop    %edi
  802108:	5d                   	pop    %ebp
  802109:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80210a:	83 f8 01             	cmp    $0x1,%eax
  80210d:	75 c1                	jne    8020d0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80210f:	8b 52 58             	mov    0x58(%edx),%edx
  802112:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802116:	89 54 24 08          	mov    %edx,0x8(%esp)
  80211a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80211e:	c7 04 24 02 32 80 00 	movl   $0x803202,(%esp)
  802125:	e8 55 e3 ff ff       	call   80047f <cprintf>
  80212a:	eb a4                	jmp    8020d0 <_pipeisclosed+0xe>

0080212c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	57                   	push   %edi
  802130:	56                   	push   %esi
  802131:	53                   	push   %ebx
  802132:	83 ec 2c             	sub    $0x2c,%esp
  802135:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802138:	89 34 24             	mov    %esi,(%esp)
  80213b:	e8 a0 f6 ff ff       	call   8017e0 <fd2data>
  802140:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802142:	bf 00 00 00 00       	mov    $0x0,%edi
  802147:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80214b:	75 50                	jne    80219d <devpipe_write+0x71>
  80214d:	eb 5c                	jmp    8021ab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80214f:	89 da                	mov    %ebx,%edx
  802151:	89 f0                	mov    %esi,%eax
  802153:	e8 6a ff ff ff       	call   8020c2 <_pipeisclosed>
  802158:	85 c0                	test   %eax,%eax
  80215a:	75 53                	jne    8021af <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80215c:	e8 3b ef ff ff       	call   80109c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802161:	8b 43 04             	mov    0x4(%ebx),%eax
  802164:	8b 13                	mov    (%ebx),%edx
  802166:	83 c2 20             	add    $0x20,%edx
  802169:	39 d0                	cmp    %edx,%eax
  80216b:	73 e2                	jae    80214f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80216d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802170:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802174:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802177:	89 c2                	mov    %eax,%edx
  802179:	c1 fa 1f             	sar    $0x1f,%edx
  80217c:	c1 ea 1b             	shr    $0x1b,%edx
  80217f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802182:	83 e1 1f             	and    $0x1f,%ecx
  802185:	29 d1                	sub    %edx,%ecx
  802187:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80218b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80218f:	83 c0 01             	add    $0x1,%eax
  802192:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802195:	83 c7 01             	add    $0x1,%edi
  802198:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80219b:	74 0e                	je     8021ab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80219d:	8b 43 04             	mov    0x4(%ebx),%eax
  8021a0:	8b 13                	mov    (%ebx),%edx
  8021a2:	83 c2 20             	add    $0x20,%edx
  8021a5:	39 d0                	cmp    %edx,%eax
  8021a7:	73 a6                	jae    80214f <devpipe_write+0x23>
  8021a9:	eb c2                	jmp    80216d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021ab:	89 f8                	mov    %edi,%eax
  8021ad:	eb 05                	jmp    8021b4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021b4:	83 c4 2c             	add    $0x2c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    

008021bc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	83 ec 28             	sub    $0x28,%esp
  8021c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8021c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8021c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8021cb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021ce:	89 3c 24             	mov    %edi,(%esp)
  8021d1:	e8 0a f6 ff ff       	call   8017e0 <fd2data>
  8021d6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021d8:	be 00 00 00 00       	mov    $0x0,%esi
  8021dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021e1:	75 47                	jne    80222a <devpipe_read+0x6e>
  8021e3:	eb 52                	jmp    802237 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	eb 5e                	jmp    802247 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021e9:	89 da                	mov    %ebx,%edx
  8021eb:	89 f8                	mov    %edi,%eax
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	e8 cd fe ff ff       	call   8020c2 <_pipeisclosed>
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	75 49                	jne    802242 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8021f9:	e8 9e ee ff ff       	call   80109c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021fe:	8b 03                	mov    (%ebx),%eax
  802200:	3b 43 04             	cmp    0x4(%ebx),%eax
  802203:	74 e4                	je     8021e9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802205:	89 c2                	mov    %eax,%edx
  802207:	c1 fa 1f             	sar    $0x1f,%edx
  80220a:	c1 ea 1b             	shr    $0x1b,%edx
  80220d:	01 d0                	add    %edx,%eax
  80220f:	83 e0 1f             	and    $0x1f,%eax
  802212:	29 d0                	sub    %edx,%eax
  802214:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802219:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80221f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802222:	83 c6 01             	add    $0x1,%esi
  802225:	3b 75 10             	cmp    0x10(%ebp),%esi
  802228:	74 0d                	je     802237 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80222a:	8b 03                	mov    (%ebx),%eax
  80222c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80222f:	75 d4                	jne    802205 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802231:	85 f6                	test   %esi,%esi
  802233:	75 b0                	jne    8021e5 <devpipe_read+0x29>
  802235:	eb b2                	jmp    8021e9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802237:	89 f0                	mov    %esi,%eax
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	eb 05                	jmp    802247 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802242:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802247:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80224a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80224d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802250:	89 ec                	mov    %ebp,%esp
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	83 ec 48             	sub    $0x48,%esp
  80225a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80225d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802260:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802263:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802266:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802269:	89 04 24             	mov    %eax,(%esp)
  80226c:	e8 8a f5 ff ff       	call   8017fb <fd_alloc>
  802271:	89 c3                	mov    %eax,%ebx
  802273:	85 c0                	test   %eax,%eax
  802275:	0f 88 45 01 00 00    	js     8023c0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80227b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802282:	00 
  802283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802291:	e8 36 ee ff ff       	call   8010cc <sys_page_alloc>
  802296:	89 c3                	mov    %eax,%ebx
  802298:	85 c0                	test   %eax,%eax
  80229a:	0f 88 20 01 00 00    	js     8023c0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022a0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8022a3:	89 04 24             	mov    %eax,(%esp)
  8022a6:	e8 50 f5 ff ff       	call   8017fb <fd_alloc>
  8022ab:	89 c3                	mov    %eax,%ebx
  8022ad:	85 c0                	test   %eax,%eax
  8022af:	0f 88 f8 00 00 00    	js     8023ad <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022bc:	00 
  8022bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022cb:	e8 fc ed ff ff       	call   8010cc <sys_page_alloc>
  8022d0:	89 c3                	mov    %eax,%ebx
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	0f 88 d3 00 00 00    	js     8023ad <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022dd:	89 04 24             	mov    %eax,(%esp)
  8022e0:	e8 fb f4 ff ff       	call   8017e0 <fd2data>
  8022e5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022ee:	00 
  8022ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fa:	e8 cd ed ff ff       	call   8010cc <sys_page_alloc>
  8022ff:	89 c3                	mov    %eax,%ebx
  802301:	85 c0                	test   %eax,%eax
  802303:	0f 88 91 00 00 00    	js     80239a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80230c:	89 04 24             	mov    %eax,(%esp)
  80230f:	e8 cc f4 ff ff       	call   8017e0 <fd2data>
  802314:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80231b:	00 
  80231c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802320:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802327:	00 
  802328:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802333:	e8 f3 ed ff ff       	call   80112b <sys_page_map>
  802338:	89 c3                	mov    %eax,%ebx
  80233a:	85 c0                	test   %eax,%eax
  80233c:	78 4c                	js     80238a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80233e:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802347:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80234c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802353:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80235c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80235e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802361:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802368:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80236b:	89 04 24             	mov    %eax,(%esp)
  80236e:	e8 5d f4 ff ff       	call   8017d0 <fd2num>
  802373:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802375:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802378:	89 04 24             	mov    %eax,(%esp)
  80237b:	e8 50 f4 ff ff       	call   8017d0 <fd2num>
  802380:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802383:	bb 00 00 00 00       	mov    $0x0,%ebx
  802388:	eb 36                	jmp    8023c0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80238a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802395:	e8 ef ed ff ff       	call   801189 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80239a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80239d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a8:	e8 dc ed ff ff       	call   801189 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8023ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023bb:	e8 c9 ed ff ff       	call   801189 <sys_page_unmap>
    err:
	return r;
}
  8023c0:	89 d8                	mov    %ebx,%eax
  8023c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8023c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8023c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8023cb:	89 ec                	mov    %ebp,%esp
  8023cd:	5d                   	pop    %ebp
  8023ce:	c3                   	ret    

008023cf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023cf:	55                   	push   %ebp
  8023d0:	89 e5                	mov    %esp,%ebp
  8023d2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023df:	89 04 24             	mov    %eax,(%esp)
  8023e2:	e8 87 f4 ff ff       	call   80186e <fd_lookup>
  8023e7:	85 c0                	test   %eax,%eax
  8023e9:	78 15                	js     802400 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ee:	89 04 24             	mov    %eax,(%esp)
  8023f1:	e8 ea f3 ff ff       	call   8017e0 <fd2data>
	return _pipeisclosed(fd, p);
  8023f6:	89 c2                	mov    %eax,%edx
  8023f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fb:	e8 c2 fc ff ff       	call   8020c2 <_pipeisclosed>
}
  802400:	c9                   	leave  
  802401:	c3                   	ret    
	...

00802404 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	56                   	push   %esi
  802408:	53                   	push   %ebx
  802409:	83 ec 10             	sub    $0x10,%esp
  80240c:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  80240f:	85 c0                	test   %eax,%eax
  802411:	75 24                	jne    802437 <wait+0x33>
  802413:	c7 44 24 0c 1a 32 80 	movl   $0x80321a,0xc(%esp)
  80241a:	00 
  80241b:	c7 44 24 08 cf 31 80 	movl   $0x8031cf,0x8(%esp)
  802422:	00 
  802423:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80242a:	00 
  80242b:	c7 04 24 25 32 80 00 	movl   $0x803225,(%esp)
  802432:	e8 4d df ff ff       	call   800384 <_panic>
	e = &envs[ENVX(envid)];
  802437:	89 c3                	mov    %eax,%ebx
  802439:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80243f:	c1 e3 07             	shl    $0x7,%ebx
  802442:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802448:	8b 73 48             	mov    0x48(%ebx),%esi
  80244b:	39 c6                	cmp    %eax,%esi
  80244d:	75 1a                	jne    802469 <wait+0x65>
  80244f:	8b 43 54             	mov    0x54(%ebx),%eax
  802452:	85 c0                	test   %eax,%eax
  802454:	74 13                	je     802469 <wait+0x65>
		sys_yield();
  802456:	e8 41 ec ff ff       	call   80109c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80245b:	8b 43 48             	mov    0x48(%ebx),%eax
  80245e:	39 f0                	cmp    %esi,%eax
  802460:	75 07                	jne    802469 <wait+0x65>
  802462:	8b 43 54             	mov    0x54(%ebx),%eax
  802465:	85 c0                	test   %eax,%eax
  802467:	75 ed                	jne    802456 <wait+0x52>
		sys_yield();
}
  802469:	83 c4 10             	add    $0x10,%esp
  80246c:	5b                   	pop    %ebx
  80246d:	5e                   	pop    %esi
  80246e:	5d                   	pop    %ebp
  80246f:	c3                   	ret    

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
  802480:	c7 44 24 04 30 32 80 	movl   $0x803230,0x4(%esp)
  802487:	00 
  802488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248b:	89 04 24             	mov    %eax,(%esp)
  80248e:	e8 38 e7 ff ff       	call   800bcb <strcpy>
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
  8024da:	e8 dd e8 ff ff       	call   800dbc <memmove>
		sys_cputs(buf, m);
  8024df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024e3:	89 3c 24             	mov    %edi,(%esp)
  8024e6:	e8 c5 ea ff ff       	call   800fb0 <sys_cputs>
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
  802514:	e8 83 eb ff ff       	call   80109c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	e8 ba ea ff ff       	call   800fdf <sys_cgetc>
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
  802561:	e8 4a ea ff ff       	call   800fb0 <sys_cputs>
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
  802584:	e8 a5 f5 ff ff       	call   801b2e <read>
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
  8025b1:	e8 b8 f2 ff ff       	call   80186e <fd_lookup>
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	78 11                	js     8025cb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025bd:	8b 15 44 40 80 00    	mov    0x804044,%edx
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
  8025d9:	e8 1d f2 ff ff       	call   8017fb <fd_alloc>
  8025de:	85 c0                	test   %eax,%eax
  8025e0:	78 3c                	js     80261e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025e9:	00 
  8025ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025f8:	e8 cf ea ff ff       	call   8010cc <sys_page_alloc>
  8025fd:	85 c0                	test   %eax,%eax
  8025ff:	78 1d                	js     80261e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802601:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802607:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80260c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802616:	89 04 24             	mov    %eax,(%esp)
  802619:	e8 b2 f1 ff ff       	call   8017d0 <fd2num>
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
  802646:	e8 81 ea ff ff       	call   8010cc <sys_page_alloc>
  80264b:	85 c0                	test   %eax,%eax
  80264d:	79 1c                	jns    80266b <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  80264f:	c7 44 24 08 3c 32 80 	movl   $0x80323c,0x8(%esp)
  802656:	00 
  802657:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80265e:	00 
  80265f:	c7 04 24 a0 32 80 00 	movl   $0x8032a0,(%esp)
  802666:	e8 19 dd ff ff       	call   800384 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80266b:	8b 45 08             	mov    0x8(%ebp),%eax
  80266e:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802673:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  80267a:	00 
  80267b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802682:	e8 1c ec ff ff       	call   8012a3 <sys_env_set_pgfault_upcall>
  802687:	85 c0                	test   %eax,%eax
  802689:	79 1c                	jns    8026a7 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80268b:	c7 44 24 08 68 32 80 	movl   $0x803268,0x8(%esp)
  802692:	00 
  802693:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80269a:	00 
  80269b:	c7 04 24 a0 32 80 00 	movl   $0x8032a0,(%esp)
  8026a2:	e8 dd dc ff ff       	call   800384 <_panic>
}
  8026a7:	c9                   	leave  
  8026a8:	c3                   	ret    
  8026a9:	00 00                	add    %al,(%eax)
	...

008026ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026ad:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026b4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  8026b7:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  8026bb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  8026c0:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8026c4:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  8026c6:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  8026c9:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  8026ca:	83 c4 04             	add    $0x4,%esp
    popfl
  8026cd:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8026ce:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8026cf:	c3                   	ret    

008026d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	56                   	push   %esi
  8026d4:	53                   	push   %ebx
  8026d5:	83 ec 10             	sub    $0x10,%esp
  8026d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8026db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026de:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8026e1:	85 db                	test   %ebx,%ebx
  8026e3:	74 06                	je     8026eb <ipc_recv+0x1b>
  8026e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8026eb:	85 f6                	test   %esi,%esi
  8026ed:	74 06                	je     8026f5 <ipc_recv+0x25>
  8026ef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8026f5:	85 c0                	test   %eax,%eax
  8026f7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8026fc:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8026ff:	89 04 24             	mov    %eax,(%esp)
  802702:	e8 2e ec ff ff       	call   801335 <sys_ipc_recv>
    if (ret) return ret;
  802707:	85 c0                	test   %eax,%eax
  802709:	75 24                	jne    80272f <ipc_recv+0x5f>
    if (from_env_store)
  80270b:	85 db                	test   %ebx,%ebx
  80270d:	74 0a                	je     802719 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80270f:	a1 04 50 80 00       	mov    0x805004,%eax
  802714:	8b 40 74             	mov    0x74(%eax),%eax
  802717:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802719:	85 f6                	test   %esi,%esi
  80271b:	74 0a                	je     802727 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80271d:	a1 04 50 80 00       	mov    0x805004,%eax
  802722:	8b 40 78             	mov    0x78(%eax),%eax
  802725:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802727:	a1 04 50 80 00       	mov    0x805004,%eax
  80272c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80272f:	83 c4 10             	add    $0x10,%esp
  802732:	5b                   	pop    %ebx
  802733:	5e                   	pop    %esi
  802734:	5d                   	pop    %ebp
  802735:	c3                   	ret    

00802736 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802736:	55                   	push   %ebp
  802737:	89 e5                	mov    %esp,%ebp
  802739:	57                   	push   %edi
  80273a:	56                   	push   %esi
  80273b:	53                   	push   %ebx
  80273c:	83 ec 1c             	sub    $0x1c,%esp
  80273f:	8b 75 08             	mov    0x8(%ebp),%esi
  802742:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802745:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802748:	85 db                	test   %ebx,%ebx
  80274a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80274f:	0f 44 d8             	cmove  %eax,%ebx
  802752:	eb 2a                	jmp    80277e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802754:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802757:	74 20                	je     802779 <ipc_send+0x43>
  802759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80275d:	c7 44 24 08 ae 32 80 	movl   $0x8032ae,0x8(%esp)
  802764:	00 
  802765:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80276c:	00 
  80276d:	c7 04 24 c5 32 80 00 	movl   $0x8032c5,(%esp)
  802774:	e8 0b dc ff ff       	call   800384 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802779:	e8 1e e9 ff ff       	call   80109c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80277e:	8b 45 14             	mov    0x14(%ebp),%eax
  802781:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802785:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802789:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80278d:	89 34 24             	mov    %esi,(%esp)
  802790:	e8 6c eb ff ff       	call   801301 <sys_ipc_try_send>
  802795:	85 c0                	test   %eax,%eax
  802797:	75 bb                	jne    802754 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802799:	83 c4 1c             	add    $0x1c,%esp
  80279c:	5b                   	pop    %ebx
  80279d:	5e                   	pop    %esi
  80279e:	5f                   	pop    %edi
  80279f:	5d                   	pop    %ebp
  8027a0:	c3                   	ret    

008027a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027a1:	55                   	push   %ebp
  8027a2:	89 e5                	mov    %esp,%ebp
  8027a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8027a7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8027ac:	39 c8                	cmp    %ecx,%eax
  8027ae:	74 19                	je     8027c9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027b0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8027b5:	89 c2                	mov    %eax,%edx
  8027b7:	c1 e2 07             	shl    $0x7,%edx
  8027ba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027c0:	8b 52 50             	mov    0x50(%edx),%edx
  8027c3:	39 ca                	cmp    %ecx,%edx
  8027c5:	75 14                	jne    8027db <ipc_find_env+0x3a>
  8027c7:	eb 05                	jmp    8027ce <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027c9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8027ce:	c1 e0 07             	shl    $0x7,%eax
  8027d1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027d6:	8b 40 40             	mov    0x40(%eax),%eax
  8027d9:	eb 0e                	jmp    8027e9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027db:	83 c0 01             	add    $0x1,%eax
  8027de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027e3:	75 d0                	jne    8027b5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027e5:	66 b8 00 00          	mov    $0x0,%ax
}
  8027e9:	5d                   	pop    %ebp
  8027ea:	c3                   	ret    
	...

008027ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027ec:	55                   	push   %ebp
  8027ed:	89 e5                	mov    %esp,%ebp
  8027ef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027f2:	89 d0                	mov    %edx,%eax
  8027f4:	c1 e8 16             	shr    $0x16,%eax
  8027f7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027fe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802803:	f6 c1 01             	test   $0x1,%cl
  802806:	74 1d                	je     802825 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802808:	c1 ea 0c             	shr    $0xc,%edx
  80280b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802812:	f6 c2 01             	test   $0x1,%dl
  802815:	74 0e                	je     802825 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802817:	c1 ea 0c             	shr    $0xc,%edx
  80281a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802821:	ef 
  802822:	0f b7 c0             	movzwl %ax,%eax
}
  802825:	5d                   	pop    %ebp
  802826:	c3                   	ret    
	...

00802830 <__udivdi3>:
  802830:	83 ec 1c             	sub    $0x1c,%esp
  802833:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802837:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80283b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80283f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802843:	89 74 24 10          	mov    %esi,0x10(%esp)
  802847:	8b 74 24 24          	mov    0x24(%esp),%esi
  80284b:	85 ff                	test   %edi,%edi
  80284d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802851:	89 44 24 08          	mov    %eax,0x8(%esp)
  802855:	89 cd                	mov    %ecx,%ebp
  802857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80285b:	75 33                	jne    802890 <__udivdi3+0x60>
  80285d:	39 f1                	cmp    %esi,%ecx
  80285f:	77 57                	ja     8028b8 <__udivdi3+0x88>
  802861:	85 c9                	test   %ecx,%ecx
  802863:	75 0b                	jne    802870 <__udivdi3+0x40>
  802865:	b8 01 00 00 00       	mov    $0x1,%eax
  80286a:	31 d2                	xor    %edx,%edx
  80286c:	f7 f1                	div    %ecx
  80286e:	89 c1                	mov    %eax,%ecx
  802870:	89 f0                	mov    %esi,%eax
  802872:	31 d2                	xor    %edx,%edx
  802874:	f7 f1                	div    %ecx
  802876:	89 c6                	mov    %eax,%esi
  802878:	8b 44 24 04          	mov    0x4(%esp),%eax
  80287c:	f7 f1                	div    %ecx
  80287e:	89 f2                	mov    %esi,%edx
  802880:	8b 74 24 10          	mov    0x10(%esp),%esi
  802884:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802888:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80288c:	83 c4 1c             	add    $0x1c,%esp
  80288f:	c3                   	ret    
  802890:	31 d2                	xor    %edx,%edx
  802892:	31 c0                	xor    %eax,%eax
  802894:	39 f7                	cmp    %esi,%edi
  802896:	77 e8                	ja     802880 <__udivdi3+0x50>
  802898:	0f bd cf             	bsr    %edi,%ecx
  80289b:	83 f1 1f             	xor    $0x1f,%ecx
  80289e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8028a2:	75 2c                	jne    8028d0 <__udivdi3+0xa0>
  8028a4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8028a8:	76 04                	jbe    8028ae <__udivdi3+0x7e>
  8028aa:	39 f7                	cmp    %esi,%edi
  8028ac:	73 d2                	jae    802880 <__udivdi3+0x50>
  8028ae:	31 d2                	xor    %edx,%edx
  8028b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8028b5:	eb c9                	jmp    802880 <__udivdi3+0x50>
  8028b7:	90                   	nop
  8028b8:	89 f2                	mov    %esi,%edx
  8028ba:	f7 f1                	div    %ecx
  8028bc:	31 d2                	xor    %edx,%edx
  8028be:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028c2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028c6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028ca:	83 c4 1c             	add    $0x1c,%esp
  8028cd:	c3                   	ret    
  8028ce:	66 90                	xchg   %ax,%ax
  8028d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028d5:	b8 20 00 00 00       	mov    $0x20,%eax
  8028da:	89 ea                	mov    %ebp,%edx
  8028dc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028e0:	d3 e7                	shl    %cl,%edi
  8028e2:	89 c1                	mov    %eax,%ecx
  8028e4:	d3 ea                	shr    %cl,%edx
  8028e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028eb:	09 fa                	or     %edi,%edx
  8028ed:	89 f7                	mov    %esi,%edi
  8028ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8028f3:	89 f2                	mov    %esi,%edx
  8028f5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028f9:	d3 e5                	shl    %cl,%ebp
  8028fb:	89 c1                	mov    %eax,%ecx
  8028fd:	d3 ef                	shr    %cl,%edi
  8028ff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802904:	d3 e2                	shl    %cl,%edx
  802906:	89 c1                	mov    %eax,%ecx
  802908:	d3 ee                	shr    %cl,%esi
  80290a:	09 d6                	or     %edx,%esi
  80290c:	89 fa                	mov    %edi,%edx
  80290e:	89 f0                	mov    %esi,%eax
  802910:	f7 74 24 0c          	divl   0xc(%esp)
  802914:	89 d7                	mov    %edx,%edi
  802916:	89 c6                	mov    %eax,%esi
  802918:	f7 e5                	mul    %ebp
  80291a:	39 d7                	cmp    %edx,%edi
  80291c:	72 22                	jb     802940 <__udivdi3+0x110>
  80291e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802922:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802927:	d3 e5                	shl    %cl,%ebp
  802929:	39 c5                	cmp    %eax,%ebp
  80292b:	73 04                	jae    802931 <__udivdi3+0x101>
  80292d:	39 d7                	cmp    %edx,%edi
  80292f:	74 0f                	je     802940 <__udivdi3+0x110>
  802931:	89 f0                	mov    %esi,%eax
  802933:	31 d2                	xor    %edx,%edx
  802935:	e9 46 ff ff ff       	jmp    802880 <__udivdi3+0x50>
  80293a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802940:	8d 46 ff             	lea    -0x1(%esi),%eax
  802943:	31 d2                	xor    %edx,%edx
  802945:	8b 74 24 10          	mov    0x10(%esp),%esi
  802949:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80294d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802951:	83 c4 1c             	add    $0x1c,%esp
  802954:	c3                   	ret    
	...

00802960 <__umoddi3>:
  802960:	83 ec 1c             	sub    $0x1c,%esp
  802963:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802967:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80296b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80296f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802973:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802977:	8b 74 24 24          	mov    0x24(%esp),%esi
  80297b:	85 ed                	test   %ebp,%ebp
  80297d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802981:	89 44 24 08          	mov    %eax,0x8(%esp)
  802985:	89 cf                	mov    %ecx,%edi
  802987:	89 04 24             	mov    %eax,(%esp)
  80298a:	89 f2                	mov    %esi,%edx
  80298c:	75 1a                	jne    8029a8 <__umoddi3+0x48>
  80298e:	39 f1                	cmp    %esi,%ecx
  802990:	76 4e                	jbe    8029e0 <__umoddi3+0x80>
  802992:	f7 f1                	div    %ecx
  802994:	89 d0                	mov    %edx,%eax
  802996:	31 d2                	xor    %edx,%edx
  802998:	8b 74 24 10          	mov    0x10(%esp),%esi
  80299c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029a4:	83 c4 1c             	add    $0x1c,%esp
  8029a7:	c3                   	ret    
  8029a8:	39 f5                	cmp    %esi,%ebp
  8029aa:	77 54                	ja     802a00 <__umoddi3+0xa0>
  8029ac:	0f bd c5             	bsr    %ebp,%eax
  8029af:	83 f0 1f             	xor    $0x1f,%eax
  8029b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029b6:	75 60                	jne    802a18 <__umoddi3+0xb8>
  8029b8:	3b 0c 24             	cmp    (%esp),%ecx
  8029bb:	0f 87 07 01 00 00    	ja     802ac8 <__umoddi3+0x168>
  8029c1:	89 f2                	mov    %esi,%edx
  8029c3:	8b 34 24             	mov    (%esp),%esi
  8029c6:	29 ce                	sub    %ecx,%esi
  8029c8:	19 ea                	sbb    %ebp,%edx
  8029ca:	89 34 24             	mov    %esi,(%esp)
  8029cd:	8b 04 24             	mov    (%esp),%eax
  8029d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029dc:	83 c4 1c             	add    $0x1c,%esp
  8029df:	c3                   	ret    
  8029e0:	85 c9                	test   %ecx,%ecx
  8029e2:	75 0b                	jne    8029ef <__umoddi3+0x8f>
  8029e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8029e9:	31 d2                	xor    %edx,%edx
  8029eb:	f7 f1                	div    %ecx
  8029ed:	89 c1                	mov    %eax,%ecx
  8029ef:	89 f0                	mov    %esi,%eax
  8029f1:	31 d2                	xor    %edx,%edx
  8029f3:	f7 f1                	div    %ecx
  8029f5:	8b 04 24             	mov    (%esp),%eax
  8029f8:	f7 f1                	div    %ecx
  8029fa:	eb 98                	jmp    802994 <__umoddi3+0x34>
  8029fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a00:	89 f2                	mov    %esi,%edx
  802a02:	8b 74 24 10          	mov    0x10(%esp),%esi
  802a06:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802a0a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802a0e:	83 c4 1c             	add    $0x1c,%esp
  802a11:	c3                   	ret    
  802a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a18:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a1d:	89 e8                	mov    %ebp,%eax
  802a1f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802a24:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802a28:	89 fa                	mov    %edi,%edx
  802a2a:	d3 e0                	shl    %cl,%eax
  802a2c:	89 e9                	mov    %ebp,%ecx
  802a2e:	d3 ea                	shr    %cl,%edx
  802a30:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a35:	09 c2                	or     %eax,%edx
  802a37:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a3b:	89 14 24             	mov    %edx,(%esp)
  802a3e:	89 f2                	mov    %esi,%edx
  802a40:	d3 e7                	shl    %cl,%edi
  802a42:	89 e9                	mov    %ebp,%ecx
  802a44:	d3 ea                	shr    %cl,%edx
  802a46:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a4f:	d3 e6                	shl    %cl,%esi
  802a51:	89 e9                	mov    %ebp,%ecx
  802a53:	d3 e8                	shr    %cl,%eax
  802a55:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a5a:	09 f0                	or     %esi,%eax
  802a5c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802a60:	f7 34 24             	divl   (%esp)
  802a63:	d3 e6                	shl    %cl,%esi
  802a65:	89 74 24 08          	mov    %esi,0x8(%esp)
  802a69:	89 d6                	mov    %edx,%esi
  802a6b:	f7 e7                	mul    %edi
  802a6d:	39 d6                	cmp    %edx,%esi
  802a6f:	89 c1                	mov    %eax,%ecx
  802a71:	89 d7                	mov    %edx,%edi
  802a73:	72 3f                	jb     802ab4 <__umoddi3+0x154>
  802a75:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a79:	72 35                	jb     802ab0 <__umoddi3+0x150>
  802a7b:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a7f:	29 c8                	sub    %ecx,%eax
  802a81:	19 fe                	sbb    %edi,%esi
  802a83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a88:	89 f2                	mov    %esi,%edx
  802a8a:	d3 e8                	shr    %cl,%eax
  802a8c:	89 e9                	mov    %ebp,%ecx
  802a8e:	d3 e2                	shl    %cl,%edx
  802a90:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a95:	09 d0                	or     %edx,%eax
  802a97:	89 f2                	mov    %esi,%edx
  802a99:	d3 ea                	shr    %cl,%edx
  802a9b:	8b 74 24 10          	mov    0x10(%esp),%esi
  802a9f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802aa3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802aa7:	83 c4 1c             	add    $0x1c,%esp
  802aaa:	c3                   	ret    
  802aab:	90                   	nop
  802aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ab0:	39 d6                	cmp    %edx,%esi
  802ab2:	75 c7                	jne    802a7b <__umoddi3+0x11b>
  802ab4:	89 d7                	mov    %edx,%edi
  802ab6:	89 c1                	mov    %eax,%ecx
  802ab8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  802abc:	1b 3c 24             	sbb    (%esp),%edi
  802abf:	eb ba                	jmp    802a7b <__umoddi3+0x11b>
  802ac1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ac8:	39 f5                	cmp    %esi,%ebp
  802aca:	0f 82 f1 fe ff ff    	jb     8029c1 <__umoddi3+0x61>
  802ad0:	e9 f8 fe ff ff       	jmp    8029cd <__umoddi3+0x6d>
