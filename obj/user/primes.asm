
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 b8 15 00 00       	call   801610 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 28 80 00 	movl   $0x8028c0,(%esp)
  800071:	e8 41 02 00 00       	call   8002b7 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 ac 12 00 00       	call   801327 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  80009c:	e8 1b 01 00 00       	call   8001bc <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 50 15 00 00       	call   801610 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 8d 15 00 00       	call   801676 <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 2f 12 00 00       	call   801327 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  800119:	e8 9e 00 00 00       	call   8001bc <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 2e 15 00 00       	call   801676 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800162:	e8 45 0d 00 00       	call   800eac <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	c1 e0 07             	shl    $0x7,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a6:	e8 a3 17 00 00       	call   80194e <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 98 0c 00 00       	call   800e4f <sys_env_destroy>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
	...

008001bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001cd:	e8 da 0c 00 00       	call   800eac <sys_getenvid>
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e8:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  8001ef:	e8 c3 00 00 00       	call   8002b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 53 00 00 00       	call   800256 <vcprintf>
	cprintf("\n");
  800203:	c7 04 24 5f 2c 80 00 	movl   $0x802c5f,(%esp)
  80020a:	e8 a8 00 00 00       	call   8002b7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020f:	cc                   	int3   
  800210:	eb fd                	jmp    80020f <_panic+0x53>
	...

00800214 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	53                   	push   %ebx
  800218:	83 ec 14             	sub    $0x14,%esp
  80021b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021e:	8b 03                	mov    (%ebx),%eax
  800220:	8b 55 08             	mov    0x8(%ebp),%edx
  800223:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800227:	83 c0 01             	add    $0x1,%eax
  80022a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80022c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800231:	75 19                	jne    80024c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800233:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80023a:	00 
  80023b:	8d 43 08             	lea    0x8(%ebx),%eax
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	e8 aa 0b 00 00       	call   800df0 <sys_cputs>
		b->idx = 0;
  800246:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80024c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	5b                   	pop    %ebx
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80025f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800266:	00 00 00 
	b.cnt = 0;
  800269:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800270:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
  800276:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800281:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028b:	c7 04 24 14 02 80 00 	movl   $0x800214,(%esp)
  800292:	e8 97 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800297:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 41 0b 00 00       	call   800df0 <sys_cputs>

	return b.cnt;
}
  8002af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 87 ff ff ff       	call   800256 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    
  8002d1:	00 00                	add    %al,(%eax)
	...

008002d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 3c             	sub    $0x3c,%esp
  8002dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e0:	89 d7                	mov    %edx,%edi
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002fc:	72 11                	jb     80030f <printnum+0x3b>
  8002fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800301:	39 45 10             	cmp    %eax,0x10(%ebp)
  800304:	76 09                	jbe    80030f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800306:	83 eb 01             	sub    $0x1,%ebx
  800309:	85 db                	test   %ebx,%ebx
  80030b:	7f 51                	jg     80035e <printnum+0x8a>
  80030d:	eb 5e                	jmp    80036d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800313:	83 eb 01             	sub    $0x1,%ebx
  800316:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031a:	8b 45 10             	mov    0x10(%ebp),%eax
  80031d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800321:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800325:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800329:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800330:	00 
  800331:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033e:	e8 cd 22 00 00       	call   802610 <__udivdi3>
  800343:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800347:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800352:	89 fa                	mov    %edi,%edx
  800354:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800357:	e8 78 ff ff ff       	call   8002d4 <printnum>
  80035c:	eb 0f                	jmp    80036d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80035e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800362:	89 34 24             	mov    %esi,(%esp)
  800365:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800368:	83 eb 01             	sub    $0x1,%ebx
  80036b:	75 f1                	jne    80035e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800371:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800375:	8b 45 10             	mov    0x10(%ebp),%eax
  800378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800383:	00 
  800384:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	e8 aa 23 00 00       	call   802740 <__umoddi3>
  800396:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039a:	0f be 80 13 29 80 00 	movsbl 0x802913(%eax),%eax
  8003a1:	89 04 24             	mov    %eax,(%esp)
  8003a4:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003a7:	83 c4 3c             	add    $0x3c,%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7e 0e                	jle    8003c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bc:	89 08                	mov    %ecx,(%eax)
  8003be:	8b 02                	mov    (%edx),%eax
  8003c0:	8b 52 04             	mov    0x4(%edx),%edx
  8003c3:	eb 22                	jmp    8003e7 <getuint+0x38>
	else if (lflag)
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 10                	je     8003d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 02                	mov    (%edx),%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 0e                	jmp    8003e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f8:	73 0a                	jae    800404 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fd:	88 0a                	mov    %cl,(%edx)
  8003ff:	83 c2 01             	add    $0x1,%edx
  800402:	89 10                	mov    %edx,(%eax)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 02 00 00 00       	call   80042e <vprintfmt>
	va_end(ap);
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 5c             	sub    $0x5c,%esp
  800437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043a:	8b 75 10             	mov    0x10(%ebp),%esi
  80043d:	eb 12                	jmp    800451 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043f:	85 c0                	test   %eax,%eax
  800441:	0f 84 e4 04 00 00    	je     80092b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800447:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800451:	0f b6 06             	movzbl (%esi),%eax
  800454:	83 c6 01             	add    $0x1,%esi
  800457:	83 f8 25             	cmp    $0x25,%eax
  80045a:	75 e3                	jne    80043f <vprintfmt+0x11>
  80045c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800460:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800467:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80046c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800473:	b9 00 00 00 00       	mov    $0x0,%ecx
  800478:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80047b:	eb 2b                	jmp    8004a8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800480:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800484:	eb 22                	jmp    8004a8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800489:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80048d:	eb 19                	jmp    8004a8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800492:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800499:	eb 0d                	jmp    8004a8 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80049b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80049e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a1:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	0f b6 06             	movzbl (%esi),%eax
  8004ab:	0f b6 d0             	movzbl %al,%edx
  8004ae:	8d 7e 01             	lea    0x1(%esi),%edi
  8004b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b4:	83 e8 23             	sub    $0x23,%eax
  8004b7:	3c 55                	cmp    $0x55,%al
  8004b9:	0f 87 46 04 00 00    	ja     800905 <vprintfmt+0x4d7>
  8004bf:	0f b6 c0             	movzbl %al,%eax
  8004c2:	ff 24 85 60 2a 80 00 	jmp    *0x802a60(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c9:	83 ea 30             	sub    $0x30,%edx
  8004cc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004cf:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004d3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004d9:	83 fa 09             	cmp    $0x9,%edx
  8004dc:	77 4a                	ja     800528 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004e4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004e7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004eb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ee:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f1:	83 fa 09             	cmp    $0x9,%edx
  8004f4:	76 eb                	jbe    8004e1 <vprintfmt+0xb3>
  8004f6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004f9:	eb 2d                	jmp    800528 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 00                	mov    (%eax),%eax
  800506:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050c:	eb 1a                	jmp    800528 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800511:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800515:	79 91                	jns    8004a8 <vprintfmt+0x7a>
  800517:	e9 73 ff ff ff       	jmp    80048f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800526:	eb 80                	jmp    8004a8 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800528:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80052c:	0f 89 76 ff ff ff    	jns    8004a8 <vprintfmt+0x7a>
  800532:	e9 64 ff ff ff       	jmp    80049b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800537:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053d:	e9 66 ff ff ff       	jmp    8004a8 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055a:	e9 f2 fe ff ff       	jmp    800451 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80055f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800563:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800566:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80056a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80056d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800571:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800574:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800577:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80057b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80057e:	80 f9 09             	cmp    $0x9,%cl
  800581:	77 1d                	ja     8005a0 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800583:	0f be c0             	movsbl %al,%eax
  800586:	6b c0 64             	imul   $0x64,%eax,%eax
  800589:	0f be d2             	movsbl %dl,%edx
  80058c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80058f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800596:	a3 04 30 80 00       	mov    %eax,0x803004
  80059b:	e9 b1 fe ff ff       	jmp    800451 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8005a0:	c7 44 24 04 2b 29 80 	movl   $0x80292b,0x4(%esp)
  8005a7:	00 
  8005a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ab:	89 04 24             	mov    %eax,(%esp)
  8005ae:	e8 18 05 00 00       	call   800acb <strcmp>
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	75 0f                	jne    8005c6 <vprintfmt+0x198>
  8005b7:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8005be:	00 00 00 
  8005c1:	e9 8b fe ff ff       	jmp    800451 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8005c6:	c7 44 24 04 2f 29 80 	movl   $0x80292f,0x4(%esp)
  8005cd:	00 
  8005ce:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005d1:	89 14 24             	mov    %edx,(%esp)
  8005d4:	e8 f2 04 00 00       	call   800acb <strcmp>
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	75 0f                	jne    8005ec <vprintfmt+0x1be>
  8005dd:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8005e4:	00 00 00 
  8005e7:	e9 65 fe ff ff       	jmp    800451 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005ec:	c7 44 24 04 33 29 80 	movl   $0x802933,0x4(%esp)
  8005f3:	00 
  8005f4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005f7:	89 0c 24             	mov    %ecx,(%esp)
  8005fa:	e8 cc 04 00 00       	call   800acb <strcmp>
  8005ff:	85 c0                	test   %eax,%eax
  800601:	75 0f                	jne    800612 <vprintfmt+0x1e4>
  800603:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  80060a:	00 00 00 
  80060d:	e9 3f fe ff ff       	jmp    800451 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800612:	c7 44 24 04 37 29 80 	movl   $0x802937,0x4(%esp)
  800619:	00 
  80061a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80061d:	89 3c 24             	mov    %edi,(%esp)
  800620:	e8 a6 04 00 00       	call   800acb <strcmp>
  800625:	85 c0                	test   %eax,%eax
  800627:	75 0f                	jne    800638 <vprintfmt+0x20a>
  800629:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800630:	00 00 00 
  800633:	e9 19 fe ff ff       	jmp    800451 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800638:	c7 44 24 04 3b 29 80 	movl   $0x80293b,0x4(%esp)
  80063f:	00 
  800640:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 80 04 00 00       	call   800acb <strcmp>
  80064b:	85 c0                	test   %eax,%eax
  80064d:	75 0f                	jne    80065e <vprintfmt+0x230>
  80064f:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800656:	00 00 00 
  800659:	e9 f3 fd ff ff       	jmp    800451 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80065e:	c7 44 24 04 3f 29 80 	movl   $0x80293f,0x4(%esp)
  800665:	00 
  800666:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800669:	89 14 24             	mov    %edx,(%esp)
  80066c:	e8 5a 04 00 00       	call   800acb <strcmp>
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	19 c0                	sbb    %eax,%eax
  800676:	f7 d0                	not    %eax
  800678:	83 c0 08             	add    $0x8,%eax
  80067b:	a3 04 30 80 00       	mov    %eax,0x803004
  800680:	e9 cc fd ff ff       	jmp    800451 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 50 04             	lea    0x4(%eax),%edx
  80068b:	89 55 14             	mov    %edx,0x14(%ebp)
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	89 c2                	mov    %eax,%edx
  800692:	c1 fa 1f             	sar    $0x1f,%edx
  800695:	31 d0                	xor    %edx,%eax
  800697:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800699:	83 f8 0f             	cmp    $0xf,%eax
  80069c:	7f 0b                	jg     8006a9 <vprintfmt+0x27b>
  80069e:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  8006a5:	85 d2                	test   %edx,%edx
  8006a7:	75 23                	jne    8006cc <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8006a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ad:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  8006b4:	00 
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bc:	89 3c 24             	mov    %edi,(%esp)
  8006bf:	e8 42 fd ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006c7:	e9 85 fd ff ff       	jmp    800451 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d0:	c7 44 24 08 a1 2e 80 	movl   $0x802ea1,0x8(%esp)
  8006d7:	00 
  8006d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006df:	89 3c 24             	mov    %edi,(%esp)
  8006e2:	e8 1f fd ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006ea:	e9 62 fd ff ff       	jmp    800451 <vprintfmt+0x23>
  8006ef:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800703:	85 f6                	test   %esi,%esi
  800705:	b8 24 29 80 00       	mov    $0x802924,%eax
  80070a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80070d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800711:	7e 06                	jle    800719 <vprintfmt+0x2eb>
  800713:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800717:	75 13                	jne    80072c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800719:	0f be 06             	movsbl (%esi),%eax
  80071c:	83 c6 01             	add    $0x1,%esi
  80071f:	85 c0                	test   %eax,%eax
  800721:	0f 85 94 00 00 00    	jne    8007bb <vprintfmt+0x38d>
  800727:	e9 81 00 00 00       	jmp    8007ad <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800730:	89 34 24             	mov    %esi,(%esp)
  800733:	e8 a3 02 00 00       	call   8009db <strnlen>
  800738:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80073b:	29 c2                	sub    %eax,%edx
  80073d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800740:	85 d2                	test   %edx,%edx
  800742:	7e d5                	jle    800719 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800744:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800748:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80074b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80074e:	89 d6                	mov    %edx,%esi
  800750:	89 cf                	mov    %ecx,%edi
  800752:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800756:	89 3c 24             	mov    %edi,(%esp)
  800759:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80075c:	83 ee 01             	sub    $0x1,%esi
  80075f:	75 f1                	jne    800752 <vprintfmt+0x324>
  800761:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800764:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800767:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80076a:	eb ad                	jmp    800719 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80076c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800770:	74 1b                	je     80078d <vprintfmt+0x35f>
  800772:	8d 50 e0             	lea    -0x20(%eax),%edx
  800775:	83 fa 5e             	cmp    $0x5e,%edx
  800778:	76 13                	jbe    80078d <vprintfmt+0x35f>
					putch('?', putdat);
  80077a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80077d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800781:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800788:	ff 55 08             	call   *0x8(%ebp)
  80078b:	eb 0d                	jmp    80079a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80078d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800790:	89 54 24 04          	mov    %edx,0x4(%esp)
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079a:	83 eb 01             	sub    $0x1,%ebx
  80079d:	0f be 06             	movsbl (%esi),%eax
  8007a0:	83 c6 01             	add    $0x1,%esi
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	75 1a                	jne    8007c1 <vprintfmt+0x393>
  8007a7:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007aa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007b4:	7f 1c                	jg     8007d2 <vprintfmt+0x3a4>
  8007b6:	e9 96 fc ff ff       	jmp    800451 <vprintfmt+0x23>
  8007bb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007be:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c1:	85 ff                	test   %edi,%edi
  8007c3:	78 a7                	js     80076c <vprintfmt+0x33e>
  8007c5:	83 ef 01             	sub    $0x1,%edi
  8007c8:	79 a2                	jns    80076c <vprintfmt+0x33e>
  8007ca:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007cd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007d0:	eb db                	jmp    8007ad <vprintfmt+0x37f>
  8007d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d5:	89 de                	mov    %ebx,%esi
  8007d7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e7:	83 eb 01             	sub    $0x1,%ebx
  8007ea:	75 ee                	jne    8007da <vprintfmt+0x3ac>
  8007ec:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007f1:	e9 5b fc ff ff       	jmp    800451 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f6:	83 f9 01             	cmp    $0x1,%ecx
  8007f9:	7e 10                	jle    80080b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8d 50 08             	lea    0x8(%eax),%edx
  800801:	89 55 14             	mov    %edx,0x14(%ebp)
  800804:	8b 30                	mov    (%eax),%esi
  800806:	8b 78 04             	mov    0x4(%eax),%edi
  800809:	eb 26                	jmp    800831 <vprintfmt+0x403>
	else if (lflag)
  80080b:	85 c9                	test   %ecx,%ecx
  80080d:	74 12                	je     800821 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)
  800818:	8b 30                	mov    (%eax),%esi
  80081a:	89 f7                	mov    %esi,%edi
  80081c:	c1 ff 1f             	sar    $0x1f,%edi
  80081f:	eb 10                	jmp    800831 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8d 50 04             	lea    0x4(%eax),%edx
  800827:	89 55 14             	mov    %edx,0x14(%ebp)
  80082a:	8b 30                	mov    (%eax),%esi
  80082c:	89 f7                	mov    %esi,%edi
  80082e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800831:	85 ff                	test   %edi,%edi
  800833:	78 0e                	js     800843 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800835:	89 f0                	mov    %esi,%eax
  800837:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800839:	be 0a 00 00 00       	mov    $0xa,%esi
  80083e:	e9 84 00 00 00       	jmp    8008c7 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800843:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800847:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800851:	89 f0                	mov    %esi,%eax
  800853:	89 fa                	mov    %edi,%edx
  800855:	f7 d8                	neg    %eax
  800857:	83 d2 00             	adc    $0x0,%edx
  80085a:	f7 da                	neg    %edx
			}
			base = 10;
  80085c:	be 0a 00 00 00       	mov    $0xa,%esi
  800861:	eb 64                	jmp    8008c7 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800863:	89 ca                	mov    %ecx,%edx
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	e8 42 fb ff ff       	call   8003af <getuint>
			base = 10;
  80086d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800872:	eb 53                	jmp    8008c7 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800874:	89 ca                	mov    %ecx,%edx
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
  800879:	e8 31 fb ff ff       	call   8003af <getuint>
    			base = 8;
  80087e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800883:	eb 42                	jmp    8008c7 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800885:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800889:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800890:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800893:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800897:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80089e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 50 04             	lea    0x4(%eax),%edx
  8008a7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b1:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008b6:	eb 0f                	jmp    8008c7 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008b8:	89 ca                	mov    %ecx,%edx
  8008ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8008bd:	e8 ed fa ff ff       	call   8003af <getuint>
			base = 16;
  8008c2:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008c7:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008cb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008cf:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008d2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008d6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008da:	89 04 24             	mov    %eax,(%esp)
  8008dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e1:	89 da                	mov    %ebx,%edx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	e8 e9 f9 ff ff       	call   8002d4 <printnum>
			break;
  8008eb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008ee:	e9 5e fb ff ff       	jmp    800451 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f7:	89 14 24             	mov    %edx,(%esp)
  8008fa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800900:	e9 4c fb ff ff       	jmp    800451 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800905:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800909:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800910:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800913:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800917:	0f 84 34 fb ff ff    	je     800451 <vprintfmt+0x23>
  80091d:	83 ee 01             	sub    $0x1,%esi
  800920:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800924:	75 f7                	jne    80091d <vprintfmt+0x4ef>
  800926:	e9 26 fb ff ff       	jmp    800451 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80092b:	83 c4 5c             	add    $0x5c,%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 28             	sub    $0x28,%esp
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800942:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800946:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800949:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800950:	85 c0                	test   %eax,%eax
  800952:	74 30                	je     800984 <vsnprintf+0x51>
  800954:	85 d2                	test   %edx,%edx
  800956:	7e 2c                	jle    800984 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800958:	8b 45 14             	mov    0x14(%ebp),%eax
  80095b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095f:	8b 45 10             	mov    0x10(%ebp),%eax
  800962:	89 44 24 08          	mov    %eax,0x8(%esp)
  800966:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	c7 04 24 e9 03 80 00 	movl   $0x8003e9,(%esp)
  800974:	e8 b5 fa ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800979:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80097c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800982:	eb 05                	jmp    800989 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800984:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800991:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800994:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800998:	8b 45 10             	mov    0x10(%ebp),%eax
  80099b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 82 ff ff ff       	call   800933 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    
	...

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ce:	74 09                	je     8009d9 <strlen+0x19>
		n++;
  8009d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d7:	75 f7                	jne    8009d0 <strlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 1a                	je     800a08 <strnlen+0x2d>
  8009ee:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009f1:	74 15                	je     800a08 <strnlen+0x2d>
  8009f3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009f8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fa:	39 ca                	cmp    %ecx,%edx
  8009fc:	74 0a                	je     800a08 <strnlen+0x2d>
  8009fe:	83 c2 01             	add    $0x1,%edx
  800a01:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a06:	75 f0                	jne    8009f8 <strnlen+0x1d>
		n++;
	return n;
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a1e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a21:	83 c2 01             	add    $0x1,%edx
  800a24:	84 c9                	test   %cl,%cl
  800a26:	75 f2                	jne    800a1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	83 ec 08             	sub    $0x8,%esp
  800a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a35:	89 1c 24             	mov    %ebx,(%esp)
  800a38:	e8 83 ff ff ff       	call   8009c0 <strlen>
	strcpy(dst + len, src);
  800a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a40:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a44:	01 d8                	add    %ebx,%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 bd ff ff ff       	call   800a0b <strcpy>
	return dst;
}
  800a4e:	89 d8                	mov    %ebx,%eax
  800a50:	83 c4 08             	add    $0x8,%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a64:	85 f6                	test   %esi,%esi
  800a66:	74 18                	je     800a80 <strncpy+0x2a>
  800a68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a6d:	0f b6 1a             	movzbl (%edx),%ebx
  800a70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a73:	80 3a 01             	cmpb   $0x1,(%edx)
  800a76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	39 f1                	cmp    %esi,%ecx
  800a7e:	75 ed                	jne    800a6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a90:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a93:	89 f8                	mov    %edi,%eax
  800a95:	85 f6                	test   %esi,%esi
  800a97:	74 2b                	je     800ac4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a99:	83 fe 01             	cmp    $0x1,%esi
  800a9c:	74 23                	je     800ac1 <strlcpy+0x3d>
  800a9e:	0f b6 0b             	movzbl (%ebx),%ecx
  800aa1:	84 c9                	test   %cl,%cl
  800aa3:	74 1c                	je     800ac1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800aa5:	83 ee 02             	sub    $0x2,%esi
  800aa8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aad:	88 08                	mov    %cl,(%eax)
  800aaf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab2:	39 f2                	cmp    %esi,%edx
  800ab4:	74 0b                	je     800ac1 <strlcpy+0x3d>
  800ab6:	83 c2 01             	add    $0x1,%edx
  800ab9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800abd:	84 c9                	test   %cl,%cl
  800abf:	75 ec                	jne    800aad <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800ac1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac4:	29 f8                	sub    %edi,%eax
}
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad4:	0f b6 01             	movzbl (%ecx),%eax
  800ad7:	84 c0                	test   %al,%al
  800ad9:	74 16                	je     800af1 <strcmp+0x26>
  800adb:	3a 02                	cmp    (%edx),%al
  800add:	75 12                	jne    800af1 <strcmp+0x26>
		p++, q++;
  800adf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ae6:	84 c0                	test   %al,%al
  800ae8:	74 07                	je     800af1 <strcmp+0x26>
  800aea:	83 c1 01             	add    $0x1,%ecx
  800aed:	3a 02                	cmp    (%edx),%al
  800aef:	74 ee                	je     800adf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 c0             	movzbl %al,%eax
  800af4:	0f b6 12             	movzbl (%edx),%edx
  800af7:	29 d0                	sub    %edx,%eax
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0d:	85 d2                	test   %edx,%edx
  800b0f:	74 28                	je     800b39 <strncmp+0x3e>
  800b11:	0f b6 01             	movzbl (%ecx),%eax
  800b14:	84 c0                	test   %al,%al
  800b16:	74 24                	je     800b3c <strncmp+0x41>
  800b18:	3a 03                	cmp    (%ebx),%al
  800b1a:	75 20                	jne    800b3c <strncmp+0x41>
  800b1c:	83 ea 01             	sub    $0x1,%edx
  800b1f:	74 13                	je     800b34 <strncmp+0x39>
		n--, p++, q++;
  800b21:	83 c1 01             	add    $0x1,%ecx
  800b24:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b27:	0f b6 01             	movzbl (%ecx),%eax
  800b2a:	84 c0                	test   %al,%al
  800b2c:	74 0e                	je     800b3c <strncmp+0x41>
  800b2e:	3a 03                	cmp    (%ebx),%al
  800b30:	74 ea                	je     800b1c <strncmp+0x21>
  800b32:	eb 08                	jmp    800b3c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3c:	0f b6 01             	movzbl (%ecx),%eax
  800b3f:	0f b6 13             	movzbl (%ebx),%edx
  800b42:	29 d0                	sub    %edx,%eax
  800b44:	eb f3                	jmp    800b39 <strncmp+0x3e>

00800b46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b50:	0f b6 10             	movzbl (%eax),%edx
  800b53:	84 d2                	test   %dl,%dl
  800b55:	74 1c                	je     800b73 <strchr+0x2d>
		if (*s == c)
  800b57:	38 ca                	cmp    %cl,%dl
  800b59:	75 09                	jne    800b64 <strchr+0x1e>
  800b5b:	eb 1b                	jmp    800b78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b5d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b60:	38 ca                	cmp    %cl,%dl
  800b62:	74 14                	je     800b78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b64:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 f1                	jne    800b5d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	eb 05                	jmp    800b78 <strchr+0x32>
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b84:	0f b6 10             	movzbl (%eax),%edx
  800b87:	84 d2                	test   %dl,%dl
  800b89:	74 14                	je     800b9f <strfind+0x25>
		if (*s == c)
  800b8b:	38 ca                	cmp    %cl,%dl
  800b8d:	75 06                	jne    800b95 <strfind+0x1b>
  800b8f:	eb 0e                	jmp    800b9f <strfind+0x25>
  800b91:	38 ca                	cmp    %cl,%dl
  800b93:	74 0a                	je     800b9f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b95:	83 c0 01             	add    $0x1,%eax
  800b98:	0f b6 10             	movzbl (%eax),%edx
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	75 f2                	jne    800b91 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800baa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb9:	85 c9                	test   %ecx,%ecx
  800bbb:	74 30                	je     800bed <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc3:	75 25                	jne    800bea <memset+0x49>
  800bc5:	f6 c1 03             	test   $0x3,%cl
  800bc8:	75 20                	jne    800bea <memset+0x49>
		c &= 0xFF;
  800bca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	c1 e3 08             	shl    $0x8,%ebx
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	c1 e6 18             	shl    $0x18,%esi
  800bd7:	89 d0                	mov    %edx,%eax
  800bd9:	c1 e0 10             	shl    $0x10,%eax
  800bdc:	09 f0                	or     %esi,%eax
  800bde:	09 d0                	or     %edx,%eax
  800be0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800be2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800be5:	fc                   	cld    
  800be6:	f3 ab                	rep stos %eax,%es:(%edi)
  800be8:	eb 03                	jmp    800bed <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bea:	fc                   	cld    
  800beb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bed:	89 f8                	mov    %edi,%eax
  800bef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf8:	89 ec                	mov    %ebp,%esp
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c05:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c11:	39 c6                	cmp    %eax,%esi
  800c13:	73 36                	jae    800c4b <memmove+0x4f>
  800c15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c18:	39 d0                	cmp    %edx,%eax
  800c1a:	73 2f                	jae    800c4b <memmove+0x4f>
		s += n;
		d += n;
  800c1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1f:	f6 c2 03             	test   $0x3,%dl
  800c22:	75 1b                	jne    800c3f <memmove+0x43>
  800c24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2a:	75 13                	jne    800c3f <memmove+0x43>
  800c2c:	f6 c1 03             	test   $0x3,%cl
  800c2f:	75 0e                	jne    800c3f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c31:	83 ef 04             	sub    $0x4,%edi
  800c34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c3a:	fd                   	std    
  800c3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3d:	eb 09                	jmp    800c48 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c3f:	83 ef 01             	sub    $0x1,%edi
  800c42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c45:	fd                   	std    
  800c46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c48:	fc                   	cld    
  800c49:	eb 20                	jmp    800c6b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c51:	75 13                	jne    800c66 <memmove+0x6a>
  800c53:	a8 03                	test   $0x3,%al
  800c55:	75 0f                	jne    800c66 <memmove+0x6a>
  800c57:	f6 c1 03             	test   $0x3,%cl
  800c5a:	75 0a                	jne    800c66 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c5f:	89 c7                	mov    %eax,%edi
  800c61:	fc                   	cld    
  800c62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c64:	eb 05                	jmp    800c6b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	fc                   	cld    
  800c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c71:	89 ec                	mov    %ebp,%esp
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	89 04 24             	mov    %eax,(%esp)
  800c8f:	e8 68 ff ff ff       	call   800bfc <memmove>
}
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caa:	85 ff                	test   %edi,%edi
  800cac:	74 37                	je     800ce5 <memcmp+0x4f>
		if (*s1 != *s2)
  800cae:	0f b6 03             	movzbl (%ebx),%eax
  800cb1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb4:	83 ef 01             	sub    $0x1,%edi
  800cb7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800cbc:	38 c8                	cmp    %cl,%al
  800cbe:	74 1c                	je     800cdc <memcmp+0x46>
  800cc0:	eb 10                	jmp    800cd2 <memcmp+0x3c>
  800cc2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800cc7:	83 c2 01             	add    $0x1,%edx
  800cca:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cce:	38 c8                	cmp    %cl,%al
  800cd0:	74 0a                	je     800cdc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800cd2:	0f b6 c0             	movzbl %al,%eax
  800cd5:	0f b6 c9             	movzbl %cl,%ecx
  800cd8:	29 c8                	sub    %ecx,%eax
  800cda:	eb 09                	jmp    800ce5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdc:	39 fa                	cmp    %edi,%edx
  800cde:	75 e2                	jne    800cc2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf5:	39 d0                	cmp    %edx,%eax
  800cf7:	73 19                	jae    800d12 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cfd:	38 08                	cmp    %cl,(%eax)
  800cff:	75 06                	jne    800d07 <memfind+0x1d>
  800d01:	eb 0f                	jmp    800d12 <memfind+0x28>
  800d03:	38 08                	cmp    %cl,(%eax)
  800d05:	74 0b                	je     800d12 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d07:	83 c0 01             	add    $0x1,%eax
  800d0a:	39 d0                	cmp    %edx,%eax
  800d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d10:	75 f1                	jne    800d03 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d20:	0f b6 02             	movzbl (%edx),%eax
  800d23:	3c 20                	cmp    $0x20,%al
  800d25:	74 04                	je     800d2b <strtol+0x17>
  800d27:	3c 09                	cmp    $0x9,%al
  800d29:	75 0e                	jne    800d39 <strtol+0x25>
		s++;
  800d2b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2e:	0f b6 02             	movzbl (%edx),%eax
  800d31:	3c 20                	cmp    $0x20,%al
  800d33:	74 f6                	je     800d2b <strtol+0x17>
  800d35:	3c 09                	cmp    $0x9,%al
  800d37:	74 f2                	je     800d2b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d39:	3c 2b                	cmp    $0x2b,%al
  800d3b:	75 0a                	jne    800d47 <strtol+0x33>
		s++;
  800d3d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d40:	bf 00 00 00 00       	mov    $0x0,%edi
  800d45:	eb 10                	jmp    800d57 <strtol+0x43>
  800d47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d4c:	3c 2d                	cmp    $0x2d,%al
  800d4e:	75 07                	jne    800d57 <strtol+0x43>
		s++, neg = 1;
  800d50:	83 c2 01             	add    $0x1,%edx
  800d53:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d57:	85 db                	test   %ebx,%ebx
  800d59:	0f 94 c0             	sete   %al
  800d5c:	74 05                	je     800d63 <strtol+0x4f>
  800d5e:	83 fb 10             	cmp    $0x10,%ebx
  800d61:	75 15                	jne    800d78 <strtol+0x64>
  800d63:	80 3a 30             	cmpb   $0x30,(%edx)
  800d66:	75 10                	jne    800d78 <strtol+0x64>
  800d68:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d6c:	75 0a                	jne    800d78 <strtol+0x64>
		s += 2, base = 16;
  800d6e:	83 c2 02             	add    $0x2,%edx
  800d71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d76:	eb 13                	jmp    800d8b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d78:	84 c0                	test   %al,%al
  800d7a:	74 0f                	je     800d8b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d81:	80 3a 30             	cmpb   $0x30,(%edx)
  800d84:	75 05                	jne    800d8b <strtol+0x77>
		s++, base = 8;
  800d86:	83 c2 01             	add    $0x1,%edx
  800d89:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d90:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d92:	0f b6 0a             	movzbl (%edx),%ecx
  800d95:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d98:	80 fb 09             	cmp    $0x9,%bl
  800d9b:	77 08                	ja     800da5 <strtol+0x91>
			dig = *s - '0';
  800d9d:	0f be c9             	movsbl %cl,%ecx
  800da0:	83 e9 30             	sub    $0x30,%ecx
  800da3:	eb 1e                	jmp    800dc3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800da5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800da8:	80 fb 19             	cmp    $0x19,%bl
  800dab:	77 08                	ja     800db5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800dad:	0f be c9             	movsbl %cl,%ecx
  800db0:	83 e9 57             	sub    $0x57,%ecx
  800db3:	eb 0e                	jmp    800dc3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800db5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800db8:	80 fb 19             	cmp    $0x19,%bl
  800dbb:	77 14                	ja     800dd1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dbd:	0f be c9             	movsbl %cl,%ecx
  800dc0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dc3:	39 f1                	cmp    %esi,%ecx
  800dc5:	7d 0e                	jge    800dd5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800dc7:	83 c2 01             	add    $0x1,%edx
  800dca:	0f af c6             	imul   %esi,%eax
  800dcd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dcf:	eb c1                	jmp    800d92 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dd1:	89 c1                	mov    %eax,%ecx
  800dd3:	eb 02                	jmp    800dd7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dd5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ddb:	74 05                	je     800de2 <strtol+0xce>
		*endptr = (char *) s;
  800ddd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800de2:	89 ca                	mov    %ecx,%edx
  800de4:	f7 da                	neg    %edx
  800de6:	85 ff                	test   %edi,%edi
  800de8:	0f 45 c2             	cmovne %edx,%eax
}
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	b8 00 00 00 00       	mov    $0x0,%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 c7                	mov    %eax,%edi
  800e0e:	89 c6                	mov    %eax,%esi
  800e10:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e33:	b8 01 00 00 00       	mov    $0x1,%eax
  800e38:	89 d1                	mov    %edx,%ecx
  800e3a:	89 d3                	mov    %edx,%ebx
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	89 d6                	mov    %edx,%esi
  800e40:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4b:	89 ec                	mov    %ebp,%esp
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 38             	sub    $0x38,%esp
  800e55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 03 00 00 00       	mov    $0x3,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 28                	jle    800e9f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e82:	00 
  800e83:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e92:	00 
  800e93:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800e9a:	e8 1d f3 ff ff       	call   8001bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800ec0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_yield>:

void
sys_yield(void)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef5:	89 d1                	mov    %edx,%ecx
  800ef7:	89 d3                	mov    %edx,%ebx
  800ef9:	89 d7                	mov    %edx,%edi
  800efb:	89 d6                	mov    %edx,%esi
  800efd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 38             	sub    $0x38,%esp
  800f12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1b:	be 00 00 00 00       	mov    $0x0,%esi
  800f20:	b8 04 00 00 00       	mov    $0x4,%eax
  800f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	89 f7                	mov    %esi,%edi
  800f30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f32:	85 c0                	test   %eax,%eax
  800f34:	7e 28                	jle    800f5e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f51:	00 
  800f52:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800f59:	e8 5e f2 ff ff       	call   8001bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f67:	89 ec                	mov    %ebp,%esp
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 38             	sub    $0x38,%esp
  800f71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 28                	jle    800fbc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800fa7:	00 
  800fa8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800faf:	00 
  800fb0:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800fb7:	e8 00 f2 ff ff       	call   8001bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fbc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc5:	89 ec                	mov    %ebp,%esp
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 38             	sub    $0x38,%esp
  800fcf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdd:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe8:	89 df                	mov    %ebx,%edi
  800fea:	89 de                	mov    %ebx,%esi
  800fec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 28                	jle    80101a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  801005:	00 
  801006:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100d:	00 
  80100e:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  801015:	e8 a2 f1 ff ff       	call   8001bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80101a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801020:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801023:	89 ec                	mov    %ebp,%esp
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 38             	sub    $0x38,%esp
  80102d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801030:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801033:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103b:	b8 08 00 00 00       	mov    $0x8,%eax
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	89 df                	mov    %ebx,%edi
  801048:	89 de                	mov    %ebx,%esi
  80104a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	7e 28                	jle    801078 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801050:	89 44 24 10          	mov    %eax,0x10(%esp)
  801054:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80105b:	00 
  80105c:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  801063:	00 
  801064:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  801073:	e8 44 f1 ff ff       	call   8001bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801078:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801081:	89 ec                	mov    %ebp,%esp
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 38             	sub    $0x38,%esp
  80108b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801091:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801094:	bb 00 00 00 00       	mov    $0x0,%ebx
  801099:	b8 09 00 00 00       	mov    $0x9,%eax
  80109e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a4:	89 df                	mov    %ebx,%edi
  8010a6:	89 de                	mov    %ebx,%esi
  8010a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	7e 28                	jle    8010d6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010b9:	00 
  8010ba:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  8010c1:	00 
  8010c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c9:	00 
  8010ca:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  8010d1:	e8 e6 f0 ff ff       	call   8001bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010df:	89 ec                	mov    %ebp,%esp
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	83 ec 38             	sub    $0x38,%esp
  8010e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	89 df                	mov    %ebx,%edi
  801104:	89 de                	mov    %ebx,%esi
  801106:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801108:	85 c0                	test   %eax,%eax
  80110a:	7e 28                	jle    801134 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801110:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801117:	00 
  801118:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  80111f:	00 
  801120:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801127:	00 
  801128:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  80112f:	e8 88 f0 ff ff       	call   8001bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801134:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801137:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113d:	89 ec                	mov    %ebp,%esp
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80114a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80114d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801150:	be 00 00 00 00       	mov    $0x0,%esi
  801155:	b8 0c 00 00 00       	mov    $0xc,%eax
  80115a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
  801166:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801168:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80116b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801171:	89 ec                	mov    %ebp,%esp
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	83 ec 38             	sub    $0x38,%esp
  80117b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80117e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801181:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801184:	b9 00 00 00 00       	mov    $0x0,%ecx
  801189:	b8 0d 00 00 00       	mov    $0xd,%eax
  80118e:	8b 55 08             	mov    0x8(%ebp),%edx
  801191:	89 cb                	mov    %ecx,%ebx
  801193:	89 cf                	mov    %ecx,%edi
  801195:	89 ce                	mov    %ecx,%esi
  801197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	7e 28                	jle    8011c5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  8011c0:	e8 f7 ef ff ff       	call   8001bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011c5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011c8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ce:	89 ec                	mov    %ebp,%esp
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011db:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011de:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ee:	89 cb                	mov    %ecx,%ebx
  8011f0:	89 cf                	mov    %ecx,%edi
  8011f2:	89 ce                	mov    %ecx,%esi
  8011f4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8011f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ff:	89 ec                	mov    %ebp,%esp
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    
	...

00801204 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	53                   	push   %ebx
  801208:	83 ec 24             	sub    $0x24,%esp
  80120b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80120e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  801210:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801214:	75 1c                	jne    801232 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  801216:	c7 44 24 08 4a 2c 80 	movl   $0x802c4a,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80122d:	e8 8a ef ff ff       	call   8001bc <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801232:	89 d8                	mov    %ebx,%eax
  801234:	c1 e8 0c             	shr    $0xc,%eax
  801237:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80123e:	f6 c4 08             	test   $0x8,%ah
  801241:	0f 84 be 00 00 00    	je     801305 <pgfault+0x101>
  801247:	89 d8                	mov    %ebx,%eax
  801249:	c1 e8 16             	shr    $0x16,%eax
  80124c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801253:	a8 01                	test   $0x1,%al
  801255:	0f 84 aa 00 00 00    	je     801305 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  80125b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801262:	00 
  801263:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80126a:	00 
  80126b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801272:	e8 95 fc ff ff       	call   800f0c <sys_page_alloc>
		if (r < 0)
  801277:	85 c0                	test   %eax,%eax
  801279:	79 20                	jns    80129b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  80127b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127f:	c7 44 24 08 84 2c 80 	movl   $0x802c84,0x8(%esp)
  801286:	00 
  801287:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80128e:	00 
  80128f:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801296:	e8 21 ef ff ff       	call   8001bc <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  80129b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  8012a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012a8:	00 
  8012a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012ad:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8012b4:	e8 bc f9 ff ff       	call   800c75 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8012b9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012c0:	00 
  8012c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012cc:	00 
  8012cd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012d4:	00 
  8012d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012dc:	e8 8a fc ff ff       	call   800f6b <sys_page_map>
		if (r < 0)
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	79 3c                	jns    801321 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  8012e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e9:	c7 44 24 08 ac 2c 80 	movl   $0x802cac,0x8(%esp)
  8012f0:	00 
  8012f1:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8012f8:	00 
  8012f9:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801300:	e8 b7 ee ff ff       	call   8001bc <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801305:	c7 44 24 08 d0 2c 80 	movl   $0x802cd0,0x8(%esp)
  80130c:	00 
  80130d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801314:	00 
  801315:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80131c:	e8 9b ee ff ff       	call   8001bc <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801321:	83 c4 24             	add    $0x24,%esp
  801324:	5b                   	pop    %ebx
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    

00801327 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	57                   	push   %edi
  80132b:	56                   	push   %esi
  80132c:	53                   	push   %ebx
  80132d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801330:	c7 04 24 04 12 80 00 	movl   $0x801204,(%esp)
  801337:	e8 e4 11 00 00       	call   802520 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80133c:	bf 07 00 00 00       	mov    $0x7,%edi
  801341:	89 f8                	mov    %edi,%eax
  801343:	cd 30                	int    $0x30
  801345:	89 c7                	mov    %eax,%edi
  801347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80134a:	85 c0                	test   %eax,%eax
  80134c:	79 20                	jns    80136e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80134e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801352:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  801359:	00 
  80135a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801361:	00 
  801362:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801369:	e8 4e ee ff ff       	call   8001bc <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  80136e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801373:	85 c0                	test   %eax,%eax
  801375:	75 1c                	jne    801393 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801377:	e8 30 fb ff ff       	call   800eac <sys_getenvid>
  80137c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801381:	c1 e0 07             	shl    $0x7,%eax
  801384:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801389:	a3 04 40 80 00       	mov    %eax,0x804004
		//cprintf("child fork ok!\n");
		return 0;
  80138e:	e9 51 02 00 00       	jmp    8015e4 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801393:	89 d8                	mov    %ebx,%eax
  801395:	c1 e8 16             	shr    $0x16,%eax
  801398:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139f:	a8 01                	test   $0x1,%al
  8013a1:	0f 84 87 01 00 00    	je     80152e <fork+0x207>
  8013a7:	89 d8                	mov    %ebx,%eax
  8013a9:	c1 e8 0c             	shr    $0xc,%eax
  8013ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b3:	f6 c2 01             	test   $0x1,%dl
  8013b6:	0f 84 72 01 00 00    	je     80152e <fork+0x207>
  8013bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c3:	f6 c2 04             	test   $0x4,%dl
  8013c6:	0f 84 62 01 00 00    	je     80152e <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8013cc:	89 c6                	mov    %eax,%esi
  8013ce:	c1 e6 0c             	shl    $0xc,%esi
  8013d1:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8013d7:	0f 84 51 01 00 00    	je     80152e <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  8013dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e4:	f6 c6 04             	test   $0x4,%dh
  8013e7:	74 53                	je     80143c <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  8013e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801400:	89 44 24 08          	mov    %eax,0x8(%esp)
  801404:	89 74 24 04          	mov    %esi,0x4(%esp)
  801408:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140f:	e8 57 fb ff ff       	call   800f6b <sys_page_map>
		if (r < 0)
  801414:	85 c0                	test   %eax,%eax
  801416:	0f 89 12 01 00 00    	jns    80152e <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  80141c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801420:	c7 44 24 08 10 2d 80 	movl   $0x802d10,0x8(%esp)
  801427:	00 
  801428:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80142f:	00 
  801430:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801437:	e8 80 ed ff ff       	call   8001bc <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80143c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801443:	f6 c2 02             	test   $0x2,%dl
  801446:	75 10                	jne    801458 <fork+0x131>
  801448:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144f:	f6 c4 08             	test   $0x8,%ah
  801452:	0f 84 8f 00 00 00    	je     8014e7 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801458:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80145f:	00 
  801460:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801467:	89 44 24 08          	mov    %eax,0x8(%esp)
  80146b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80146f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801476:	e8 f0 fa ff ff       	call   800f6b <sys_page_map>
		if (r < 0)
  80147b:	85 c0                	test   %eax,%eax
  80147d:	79 20                	jns    80149f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  80147f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801483:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  80148a:	00 
  80148b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801492:	00 
  801493:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80149a:	e8 1d ed ff ff       	call   8001bc <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  80149f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8014a6:	00 
  8014a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b2:	00 
  8014b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014be:	e8 a8 fa ff ff       	call   800f6b <sys_page_map>
		if (r < 0)
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	79 67                	jns    80152e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  8014c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014cb:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  8014d2:	00 
  8014d3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8014da:	00 
  8014db:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8014e2:	e8 d5 ec ff ff       	call   8001bc <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  8014e7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8014ee:	00 
  8014ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801505:	e8 61 fa ff ff       	call   800f6b <sys_page_map>
		if (r < 0)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	79 20                	jns    80152e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  80150e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801512:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  801519:	00 
  80151a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801521:	00 
  801522:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801529:	e8 8e ec ff ff       	call   8001bc <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  80152e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801534:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80153a:	0f 85 53 fe ff ff    	jne    801393 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801540:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801547:	00 
  801548:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80154f:	ee 
  801550:	89 3c 24             	mov    %edi,(%esp)
  801553:	e8 b4 f9 ff ff       	call   800f0c <sys_page_alloc>
	if (res < 0)
  801558:	85 c0                	test   %eax,%eax
  80155a:	79 20                	jns    80157c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  80155c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801560:	c7 44 24 08 60 2d 80 	movl   $0x802d60,0x8(%esp)
  801567:	00 
  801568:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80156f:	00 
  801570:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801577:	e8 40 ec ff ff       	call   8001bc <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  80157c:	c7 44 24 04 ac 25 80 	movl   $0x8025ac,0x4(%esp)
  801583:	00 
  801584:	89 3c 24             	mov    %edi,(%esp)
  801587:	e8 57 fb ff ff       	call   8010e3 <sys_env_set_pgfault_upcall>
	if (res < 0)
  80158c:	85 c0                	test   %eax,%eax
  80158e:	79 20                	jns    8015b0 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801590:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801594:	c7 44 24 08 84 2d 80 	movl   $0x802d84,0x8(%esp)
  80159b:	00 
  80159c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8015a3:	00 
  8015a4:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8015ab:	e8 0c ec ff ff       	call   8001bc <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  8015b0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015b7:	00 
  8015b8:	89 3c 24             	mov    %edi,(%esp)
  8015bb:	e8 67 fa ff ff       	call   801027 <sys_env_set_status>
	if (res < 0)
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	79 20                	jns    8015e4 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  8015c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c8:	c7 44 24 08 b4 2d 80 	movl   $0x802db4,0x8(%esp)
  8015cf:	00 
  8015d0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  8015d7:	00 
  8015d8:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8015df:	e8 d8 eb ff ff       	call   8001bc <_panic>

	return pid;
	//panic("fork not implemented");
}
  8015e4:	89 f8                	mov    %edi,%eax
  8015e6:	83 c4 3c             	add    $0x3c,%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <sfork>:

// Challenge!
int
sfork(void)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8015f4:	c7 44 24 08 6c 2c 80 	movl   $0x802c6c,0x8(%esp)
  8015fb:	00 
  8015fc:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801603:	00 
  801604:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80160b:	e8 ac eb ff ff       	call   8001bc <_panic>

00801610 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	83 ec 10             	sub    $0x10,%esp
  801618:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80161b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801621:	85 db                	test   %ebx,%ebx
  801623:	74 06                	je     80162b <ipc_recv+0x1b>
  801625:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80162b:	85 f6                	test   %esi,%esi
  80162d:	74 06                	je     801635 <ipc_recv+0x25>
  80162f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801635:	85 c0                	test   %eax,%eax
  801637:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80163c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80163f:	89 04 24             	mov    %eax,(%esp)
  801642:	e8 2e fb ff ff       	call   801175 <sys_ipc_recv>
    if (ret) return ret;
  801647:	85 c0                	test   %eax,%eax
  801649:	75 24                	jne    80166f <ipc_recv+0x5f>
    if (from_env_store)
  80164b:	85 db                	test   %ebx,%ebx
  80164d:	74 0a                	je     801659 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80164f:	a1 04 40 80 00       	mov    0x804004,%eax
  801654:	8b 40 74             	mov    0x74(%eax),%eax
  801657:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801659:	85 f6                	test   %esi,%esi
  80165b:	74 0a                	je     801667 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80165d:	a1 04 40 80 00       	mov    0x804004,%eax
  801662:	8b 40 78             	mov    0x78(%eax),%eax
  801665:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801667:	a1 04 40 80 00       	mov    0x804004,%eax
  80166c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	57                   	push   %edi
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	83 ec 1c             	sub    $0x1c,%esp
  80167f:	8b 75 08             	mov    0x8(%ebp),%esi
  801682:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801685:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801688:	85 db                	test   %ebx,%ebx
  80168a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80168f:	0f 44 d8             	cmove  %eax,%ebx
  801692:	eb 2a                	jmp    8016be <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801694:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801697:	74 20                	je     8016b9 <ipc_send+0x43>
  801699:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80169d:	c7 44 24 08 da 2d 80 	movl   $0x802dda,0x8(%esp)
  8016a4:	00 
  8016a5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8016ac:	00 
  8016ad:	c7 04 24 f1 2d 80 00 	movl   $0x802df1,(%esp)
  8016b4:	e8 03 eb ff ff       	call   8001bc <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8016b9:	e8 1e f8 ff ff       	call   800edc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8016be:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016cd:	89 34 24             	mov    %esi,(%esp)
  8016d0:	e8 6c fa ff ff       	call   801141 <sys_ipc_try_send>
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	75 bb                	jne    801694 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8016d9:	83 c4 1c             	add    $0x1c,%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5e                   	pop    %esi
  8016de:	5f                   	pop    %edi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8016e7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8016ec:	39 c8                	cmp    %ecx,%eax
  8016ee:	74 19                	je     801709 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8016f0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	c1 e2 07             	shl    $0x7,%edx
  8016fa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801700:	8b 52 50             	mov    0x50(%edx),%edx
  801703:	39 ca                	cmp    %ecx,%edx
  801705:	75 14                	jne    80171b <ipc_find_env+0x3a>
  801707:	eb 05                	jmp    80170e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801709:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80170e:	c1 e0 07             	shl    $0x7,%eax
  801711:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801716:	8b 40 40             	mov    0x40(%eax),%eax
  801719:	eb 0e                	jmp    801729 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80171b:	83 c0 01             	add    $0x1,%eax
  80171e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801723:	75 d0                	jne    8016f5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801725:	66 b8 00 00          	mov    $0x0,%ax
}
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    
  80172b:	00 00                	add    %al,(%eax)
  80172d:	00 00                	add    %al,(%eax)
	...

00801730 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801733:	8b 45 08             	mov    0x8(%ebp),%eax
  801736:	05 00 00 00 30       	add    $0x30000000,%eax
  80173b:	c1 e8 0c             	shr    $0xc,%eax
}
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801746:	8b 45 08             	mov    0x8(%ebp),%eax
  801749:	89 04 24             	mov    %eax,(%esp)
  80174c:	e8 df ff ff ff       	call   801730 <fd2num>
  801751:	05 20 00 0d 00       	add    $0xd0020,%eax
  801756:	c1 e0 0c             	shl    $0xc,%eax
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	53                   	push   %ebx
  80175f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801762:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801767:	a8 01                	test   $0x1,%al
  801769:	74 34                	je     80179f <fd_alloc+0x44>
  80176b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801770:	a8 01                	test   $0x1,%al
  801772:	74 32                	je     8017a6 <fd_alloc+0x4b>
  801774:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801779:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	c1 ea 16             	shr    $0x16,%edx
  801780:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801787:	f6 c2 01             	test   $0x1,%dl
  80178a:	74 1f                	je     8017ab <fd_alloc+0x50>
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	c1 ea 0c             	shr    $0xc,%edx
  801791:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801798:	f6 c2 01             	test   $0x1,%dl
  80179b:	75 17                	jne    8017b4 <fd_alloc+0x59>
  80179d:	eb 0c                	jmp    8017ab <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80179f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8017a4:	eb 05                	jmp    8017ab <fd_alloc+0x50>
  8017a6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8017ab:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b2:	eb 17                	jmp    8017cb <fd_alloc+0x70>
  8017b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017be:	75 b9                	jne    801779 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8017c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8017cb:	5b                   	pop    %ebx
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017d9:	83 fa 1f             	cmp    $0x1f,%edx
  8017dc:	77 3f                	ja     80181d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017de:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8017e4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017e7:	89 d0                	mov    %edx,%eax
  8017e9:	c1 e8 16             	shr    $0x16,%eax
  8017ec:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017f8:	f6 c1 01             	test   $0x1,%cl
  8017fb:	74 20                	je     80181d <fd_lookup+0x4f>
  8017fd:	89 d0                	mov    %edx,%eax
  8017ff:	c1 e8 0c             	shr    $0xc,%eax
  801802:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801809:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80180e:	f6 c1 01             	test   $0x1,%cl
  801811:	74 0a                	je     80181d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 14             	sub    $0x14,%esp
  801826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80182c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801831:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801837:	75 17                	jne    801850 <dev_lookup+0x31>
  801839:	eb 07                	jmp    801842 <dev_lookup+0x23>
  80183b:	39 0a                	cmp    %ecx,(%edx)
  80183d:	75 11                	jne    801850 <dev_lookup+0x31>
  80183f:	90                   	nop
  801840:	eb 05                	jmp    801847 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801842:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801847:	89 13                	mov    %edx,(%ebx)
			return 0;
  801849:	b8 00 00 00 00       	mov    $0x0,%eax
  80184e:	eb 35                	jmp    801885 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801850:	83 c0 01             	add    $0x1,%eax
  801853:	8b 14 85 78 2e 80 00 	mov    0x802e78(,%eax,4),%edx
  80185a:	85 d2                	test   %edx,%edx
  80185c:	75 dd                	jne    80183b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80185e:	a1 04 40 80 00       	mov    0x804004,%eax
  801863:	8b 40 48             	mov    0x48(%eax),%eax
  801866:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80186a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186e:	c7 04 24 fc 2d 80 00 	movl   $0x802dfc,(%esp)
  801875:	e8 3d ea ff ff       	call   8002b7 <cprintf>
	*dev = 0;
  80187a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801880:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801885:	83 c4 14             	add    $0x14,%esp
  801888:	5b                   	pop    %ebx
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	83 ec 38             	sub    $0x38,%esp
  801891:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801894:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801897:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80189a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80189d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018a1:	89 3c 24             	mov    %edi,(%esp)
  8018a4:	e8 87 fe ff ff       	call   801730 <fd2num>
  8018a9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8018ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018b0:	89 04 24             	mov    %eax,(%esp)
  8018b3:	e8 16 ff ff ff       	call   8017ce <fd_lookup>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 05                	js     8018c3 <fd_close+0x38>
	    || fd != fd2)
  8018be:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8018c1:	74 0e                	je     8018d1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8018c3:	89 f0                	mov    %esi,%eax
  8018c5:	84 c0                	test   %al,%al
  8018c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cc:	0f 44 d8             	cmove  %eax,%ebx
  8018cf:	eb 3d                	jmp    80190e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018d1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8018d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d8:	8b 07                	mov    (%edi),%eax
  8018da:	89 04 24             	mov    %eax,(%esp)
  8018dd:	e8 3d ff ff ff       	call   80181f <dev_lookup>
  8018e2:	89 c3                	mov    %eax,%ebx
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 16                	js     8018fe <fd_close+0x73>
		if (dev->dev_close)
  8018e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018eb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8018ee:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	74 07                	je     8018fe <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8018f7:	89 3c 24             	mov    %edi,(%esp)
  8018fa:	ff d0                	call   *%eax
  8018fc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801902:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801909:	e8 bb f6 ff ff       	call   800fc9 <sys_page_unmap>
	return r;
}
  80190e:	89 d8                	mov    %ebx,%eax
  801910:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801913:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801916:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801919:	89 ec                	mov    %ebp,%esp
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	89 04 24             	mov    %eax,(%esp)
  801930:	e8 99 fe ff ff       	call   8017ce <fd_lookup>
  801935:	85 c0                	test   %eax,%eax
  801937:	78 13                	js     80194c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801939:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801940:	00 
  801941:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 3f ff ff ff       	call   80188b <fd_close>
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <close_all>:

void
close_all(void)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801955:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80195a:	89 1c 24             	mov    %ebx,(%esp)
  80195d:	e8 bb ff ff ff       	call   80191d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801962:	83 c3 01             	add    $0x1,%ebx
  801965:	83 fb 20             	cmp    $0x20,%ebx
  801968:	75 f0                	jne    80195a <close_all+0xc>
		close(i);
}
  80196a:	83 c4 14             	add    $0x14,%esp
  80196d:	5b                   	pop    %ebx
  80196e:	5d                   	pop    %ebp
  80196f:	c3                   	ret    

00801970 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 58             	sub    $0x58,%esp
  801976:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801979:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80197c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80197f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801982:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801985:	89 44 24 04          	mov    %eax,0x4(%esp)
  801989:	8b 45 08             	mov    0x8(%ebp),%eax
  80198c:	89 04 24             	mov    %eax,(%esp)
  80198f:	e8 3a fe ff ff       	call   8017ce <fd_lookup>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	85 c0                	test   %eax,%eax
  801998:	0f 88 e1 00 00 00    	js     801a7f <dup+0x10f>
		return r;
	close(newfdnum);
  80199e:	89 3c 24             	mov    %edi,(%esp)
  8019a1:	e8 77 ff ff ff       	call   80191d <close>

	newfd = INDEX2FD(newfdnum);
  8019a6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8019ac:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8019af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b2:	89 04 24             	mov    %eax,(%esp)
  8019b5:	e8 86 fd ff ff       	call   801740 <fd2data>
  8019ba:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8019bc:	89 34 24             	mov    %esi,(%esp)
  8019bf:	e8 7c fd ff ff       	call   801740 <fd2data>
  8019c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8019c7:	89 d8                	mov    %ebx,%eax
  8019c9:	c1 e8 16             	shr    $0x16,%eax
  8019cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019d3:	a8 01                	test   $0x1,%al
  8019d5:	74 46                	je     801a1d <dup+0xad>
  8019d7:	89 d8                	mov    %ebx,%eax
  8019d9:	c1 e8 0c             	shr    $0xc,%eax
  8019dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019e3:	f6 c2 01             	test   $0x1,%dl
  8019e6:	74 35                	je     801a1d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8019f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a06:	00 
  801a07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a12:	e8 54 f5 ff ff       	call   800f6b <sys_page_map>
  801a17:	89 c3                	mov    %eax,%ebx
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	78 3b                	js     801a58 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a20:	89 c2                	mov    %eax,%edx
  801a22:	c1 ea 0c             	shr    $0xc,%edx
  801a25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a2c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a32:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a36:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a41:	00 
  801a42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a4d:	e8 19 f5 ff ff       	call   800f6b <sys_page_map>
  801a52:	89 c3                	mov    %eax,%ebx
  801a54:	85 c0                	test   %eax,%eax
  801a56:	79 25                	jns    801a7d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a63:	e8 61 f5 ff ff       	call   800fc9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a76:	e8 4e f5 ff ff       	call   800fc9 <sys_page_unmap>
	return r;
  801a7b:	eb 02                	jmp    801a7f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801a7d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801a7f:	89 d8                	mov    %ebx,%eax
  801a81:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a84:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a87:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a8a:	89 ec                	mov    %ebp,%esp
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	53                   	push   %ebx
  801a92:	83 ec 24             	sub    $0x24,%esp
  801a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9f:	89 1c 24             	mov    %ebx,(%esp)
  801aa2:	e8 27 fd ff ff       	call   8017ce <fd_lookup>
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 6d                	js     801b18 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab5:	8b 00                	mov    (%eax),%eax
  801ab7:	89 04 24             	mov    %eax,(%esp)
  801aba:	e8 60 fd ff ff       	call   80181f <dev_lookup>
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	78 55                	js     801b18 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac6:	8b 50 08             	mov    0x8(%eax),%edx
  801ac9:	83 e2 03             	and    $0x3,%edx
  801acc:	83 fa 01             	cmp    $0x1,%edx
  801acf:	75 23                	jne    801af4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ad1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad6:	8b 40 48             	mov    0x48(%eax),%eax
  801ad9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801add:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae1:	c7 04 24 3d 2e 80 00 	movl   $0x802e3d,(%esp)
  801ae8:	e8 ca e7 ff ff       	call   8002b7 <cprintf>
		return -E_INVAL;
  801aed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801af2:	eb 24                	jmp    801b18 <read+0x8a>
	}
	if (!dev->dev_read)
  801af4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801af7:	8b 52 08             	mov    0x8(%edx),%edx
  801afa:	85 d2                	test   %edx,%edx
  801afc:	74 15                	je     801b13 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b01:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b08:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	ff d2                	call   *%edx
  801b11:	eb 05                	jmp    801b18 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b13:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801b18:	83 c4 24             	add    $0x24,%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	57                   	push   %edi
  801b22:	56                   	push   %esi
  801b23:	53                   	push   %ebx
  801b24:	83 ec 1c             	sub    $0x1c,%esp
  801b27:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b2a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b32:	85 f6                	test   %esi,%esi
  801b34:	74 30                	je     801b66 <readn+0x48>
  801b36:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b3b:	89 f2                	mov    %esi,%edx
  801b3d:	29 c2                	sub    %eax,%edx
  801b3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b43:	03 45 0c             	add    0xc(%ebp),%eax
  801b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4a:	89 3c 24             	mov    %edi,(%esp)
  801b4d:	e8 3c ff ff ff       	call   801a8e <read>
		if (m < 0)
  801b52:	85 c0                	test   %eax,%eax
  801b54:	78 10                	js     801b66 <readn+0x48>
			return m;
		if (m == 0)
  801b56:	85 c0                	test   %eax,%eax
  801b58:	74 0a                	je     801b64 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b5a:	01 c3                	add    %eax,%ebx
  801b5c:	89 d8                	mov    %ebx,%eax
  801b5e:	39 f3                	cmp    %esi,%ebx
  801b60:	72 d9                	jb     801b3b <readn+0x1d>
  801b62:	eb 02                	jmp    801b66 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801b64:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801b66:	83 c4 1c             	add    $0x1c,%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 24             	sub    $0x24,%esp
  801b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7f:	89 1c 24             	mov    %ebx,(%esp)
  801b82:	e8 47 fc ff ff       	call   8017ce <fd_lookup>
  801b87:	85 c0                	test   %eax,%eax
  801b89:	78 68                	js     801bf3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b95:	8b 00                	mov    (%eax),%eax
  801b97:	89 04 24             	mov    %eax,(%esp)
  801b9a:	e8 80 fc ff ff       	call   80181f <dev_lookup>
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 50                	js     801bf3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801baa:	75 23                	jne    801bcf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801bac:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb1:	8b 40 48             	mov    0x48(%eax),%eax
  801bb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbc:	c7 04 24 59 2e 80 00 	movl   $0x802e59,(%esp)
  801bc3:	e8 ef e6 ff ff       	call   8002b7 <cprintf>
		return -E_INVAL;
  801bc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bcd:	eb 24                	jmp    801bf3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd2:	8b 52 0c             	mov    0xc(%edx),%edx
  801bd5:	85 d2                	test   %edx,%edx
  801bd7:	74 15                	je     801bee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801bd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bdc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801be7:	89 04 24             	mov    %eax,(%esp)
  801bea:	ff d2                	call   *%edx
  801bec:	eb 05                	jmp    801bf3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801bee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801bf3:	83 c4 24             	add    $0x24,%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <seek>:

int
seek(int fdnum, off_t offset)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bff:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	89 04 24             	mov    %eax,(%esp)
  801c0c:	e8 bd fb ff ff       	call   8017ce <fd_lookup>
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 0e                	js     801c23 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c15:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	83 ec 24             	sub    $0x24,%esp
  801c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c36:	89 1c 24             	mov    %ebx,(%esp)
  801c39:	e8 90 fb ff ff       	call   8017ce <fd_lookup>
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 61                	js     801ca3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4c:	8b 00                	mov    (%eax),%eax
  801c4e:	89 04 24             	mov    %eax,(%esp)
  801c51:	e8 c9 fb ff ff       	call   80181f <dev_lookup>
  801c56:	85 c0                	test   %eax,%eax
  801c58:	78 49                	js     801ca3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c61:	75 23                	jne    801c86 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c63:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c68:	8b 40 48             	mov    0x48(%eax),%eax
  801c6b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c73:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801c7a:	e8 38 e6 ff ff       	call   8002b7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c84:	eb 1d                	jmp    801ca3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c89:	8b 52 18             	mov    0x18(%edx),%edx
  801c8c:	85 d2                	test   %edx,%edx
  801c8e:	74 0e                	je     801c9e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c93:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c97:	89 04 24             	mov    %eax,(%esp)
  801c9a:	ff d2                	call   *%edx
  801c9c:	eb 05                	jmp    801ca3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c9e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801ca3:	83 c4 24             	add    $0x24,%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	53                   	push   %ebx
  801cad:	83 ec 24             	sub    $0x24,%esp
  801cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cba:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbd:	89 04 24             	mov    %eax,(%esp)
  801cc0:	e8 09 fb ff ff       	call   8017ce <fd_lookup>
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 52                	js     801d1b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd3:	8b 00                	mov    (%eax),%eax
  801cd5:	89 04 24             	mov    %eax,(%esp)
  801cd8:	e8 42 fb ff ff       	call   80181f <dev_lookup>
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 3a                	js     801d1b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ce8:	74 2c                	je     801d16 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801cea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ced:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cf4:	00 00 00 
	stat->st_isdir = 0;
  801cf7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cfe:	00 00 00 
	stat->st_dev = dev;
  801d01:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d0e:	89 14 24             	mov    %edx,(%esp)
  801d11:	ff 50 14             	call   *0x14(%eax)
  801d14:	eb 05                	jmp    801d1b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d16:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d1b:	83 c4 24             	add    $0x24,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 18             	sub    $0x18,%esp
  801d27:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d2a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d34:	00 
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	89 04 24             	mov    %eax,(%esp)
  801d3b:	e8 bc 01 00 00       	call   801efc <open>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 1b                	js     801d61 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4d:	89 1c 24             	mov    %ebx,(%esp)
  801d50:	e8 54 ff ff ff       	call   801ca9 <fstat>
  801d55:	89 c6                	mov    %eax,%esi
	close(fd);
  801d57:	89 1c 24             	mov    %ebx,(%esp)
  801d5a:	e8 be fb ff ff       	call   80191d <close>
	return r;
  801d5f:	89 f3                	mov    %esi,%ebx
}
  801d61:	89 d8                	mov    %ebx,%eax
  801d63:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d66:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d69:	89 ec                	mov    %ebp,%esp
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	00 00                	add    %al,(%eax)
	...

00801d70 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 18             	sub    $0x18,%esp
  801d76:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d79:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d80:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801d87:	75 11                	jne    801d9a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d90:	e8 4c f9 ff ff       	call   8016e1 <ipc_find_env>
  801d95:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d9a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801da1:	00 
  801da2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801da9:	00 
  801daa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dae:	a1 00 40 80 00       	mov    0x804000,%eax
  801db3:	89 04 24             	mov    %eax,(%esp)
  801db6:	e8 bb f8 ff ff       	call   801676 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801dbb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dc2:	00 
  801dc3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dce:	e8 3d f8 ff ff       	call   801610 <ipc_recv>
}
  801dd3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dd6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801dd9:	89 ec                	mov    %ebp,%esp
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	53                   	push   %ebx
  801de1:	83 ec 14             	sub    $0x14,%esp
  801de4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801de7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dea:	8b 40 0c             	mov    0xc(%eax),%eax
  801ded:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
  801df7:	b8 05 00 00 00       	mov    $0x5,%eax
  801dfc:	e8 6f ff ff ff       	call   801d70 <fsipc>
  801e01:	85 c0                	test   %eax,%eax
  801e03:	78 2b                	js     801e30 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e05:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e0c:	00 
  801e0d:	89 1c 24             	mov    %ebx,(%esp)
  801e10:	e8 f6 eb ff ff       	call   800a0b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e15:	a1 80 50 80 00       	mov    0x805080,%eax
  801e1a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e20:	a1 84 50 80 00       	mov    0x805084,%eax
  801e25:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e30:	83 c4 14             	add    $0x14,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5d                   	pop    %ebp
  801e35:	c3                   	ret    

00801e36 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801e42:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801e47:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4c:	b8 06 00 00 00       	mov    $0x6,%eax
  801e51:	e8 1a ff ff ff       	call   801d70 <fsipc>
}
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	83 ec 10             	sub    $0x10,%esp
  801e60:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	8b 40 0c             	mov    0xc(%eax),%eax
  801e69:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801e6e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e74:	ba 00 00 00 00       	mov    $0x0,%edx
  801e79:	b8 03 00 00 00       	mov    $0x3,%eax
  801e7e:	e8 ed fe ff ff       	call   801d70 <fsipc>
  801e83:	89 c3                	mov    %eax,%ebx
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 6a                	js     801ef3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e89:	39 c6                	cmp    %eax,%esi
  801e8b:	73 24                	jae    801eb1 <devfile_read+0x59>
  801e8d:	c7 44 24 0c 88 2e 80 	movl   $0x802e88,0xc(%esp)
  801e94:	00 
  801e95:	c7 44 24 08 8f 2e 80 	movl   $0x802e8f,0x8(%esp)
  801e9c:	00 
  801e9d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801ea4:	00 
  801ea5:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  801eac:	e8 0b e3 ff ff       	call   8001bc <_panic>
	assert(r <= PGSIZE);
  801eb1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801eb6:	7e 24                	jle    801edc <devfile_read+0x84>
  801eb8:	c7 44 24 0c af 2e 80 	movl   $0x802eaf,0xc(%esp)
  801ebf:	00 
  801ec0:	c7 44 24 08 8f 2e 80 	movl   $0x802e8f,0x8(%esp)
  801ec7:	00 
  801ec8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ecf:	00 
  801ed0:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  801ed7:	e8 e0 e2 ff ff       	call   8001bc <_panic>
	memmove(buf, &fsipcbuf, r);
  801edc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ee0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ee7:	00 
  801ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eeb:	89 04 24             	mov    %eax,(%esp)
  801eee:	e8 09 ed ff ff       	call   800bfc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801ef3:	89 d8                	mov    %ebx,%eax
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 20             	sub    $0x20,%esp
  801f04:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f07:	89 34 24             	mov    %esi,(%esp)
  801f0a:	e8 b1 ea ff ff       	call   8009c0 <strlen>
		return -E_BAD_PATH;
  801f0f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f14:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f19:	7f 5e                	jg     801f79 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 35 f8 ff ff       	call   80175b <fd_alloc>
  801f26:	89 c3                	mov    %eax,%ebx
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 4d                	js     801f79 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f30:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f37:	e8 cf ea ff ff       	call   800a0b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f47:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4c:	e8 1f fe ff ff       	call   801d70 <fsipc>
  801f51:	89 c3                	mov    %eax,%ebx
  801f53:	85 c0                	test   %eax,%eax
  801f55:	79 15                	jns    801f6c <open+0x70>
		fd_close(fd, 0);
  801f57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f5e:	00 
  801f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f62:	89 04 24             	mov    %eax,(%esp)
  801f65:	e8 21 f9 ff ff       	call   80188b <fd_close>
		return r;
  801f6a:	eb 0d                	jmp    801f79 <open+0x7d>
	}

	return fd2num(fd);
  801f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6f:	89 04 24             	mov    %eax,(%esp)
  801f72:	e8 b9 f7 ff ff       	call   801730 <fd2num>
  801f77:	89 c3                	mov    %eax,%ebx
}
  801f79:	89 d8                	mov    %ebx,%eax
  801f7b:	83 c4 20             	add    $0x20,%esp
  801f7e:	5b                   	pop    %ebx
  801f7f:	5e                   	pop    %esi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
	...

00801f90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 18             	sub    $0x18,%esp
  801f96:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f99:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f9c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa2:	89 04 24             	mov    %eax,(%esp)
  801fa5:	e8 96 f7 ff ff       	call   801740 <fd2data>
  801faa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801fac:	c7 44 24 04 bb 2e 80 	movl   $0x802ebb,0x4(%esp)
  801fb3:	00 
  801fb4:	89 34 24             	mov    %esi,(%esp)
  801fb7:	e8 4f ea ff ff       	call   800a0b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fbc:	8b 43 04             	mov    0x4(%ebx),%eax
  801fbf:	2b 03                	sub    (%ebx),%eax
  801fc1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801fc7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801fce:	00 00 00 
	stat->st_dev = &devpipe;
  801fd1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801fd8:	30 80 00 
	return 0;
}
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fe3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fe6:	89 ec                	mov    %ebp,%esp
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    

00801fea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	53                   	push   %ebx
  801fee:	83 ec 14             	sub    $0x14,%esp
  801ff1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ff4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ff8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fff:	e8 c5 ef ff ff       	call   800fc9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802004:	89 1c 24             	mov    %ebx,(%esp)
  802007:	e8 34 f7 ff ff       	call   801740 <fd2data>
  80200c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802010:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802017:	e8 ad ef ff ff       	call   800fc9 <sys_page_unmap>
}
  80201c:	83 c4 14             	add    $0x14,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    

00802022 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	57                   	push   %edi
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 2c             	sub    $0x2c,%esp
  80202b:	89 c7                	mov    %eax,%edi
  80202d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802030:	a1 04 40 80 00       	mov    0x804004,%eax
  802035:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802038:	89 3c 24             	mov    %edi,(%esp)
  80203b:	e8 90 05 00 00       	call   8025d0 <pageref>
  802040:	89 c6                	mov    %eax,%esi
  802042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802045:	89 04 24             	mov    %eax,(%esp)
  802048:	e8 83 05 00 00       	call   8025d0 <pageref>
  80204d:	39 c6                	cmp    %eax,%esi
  80204f:	0f 94 c0             	sete   %al
  802052:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802055:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80205b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80205e:	39 cb                	cmp    %ecx,%ebx
  802060:	75 08                	jne    80206a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802062:	83 c4 2c             	add    $0x2c,%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80206a:	83 f8 01             	cmp    $0x1,%eax
  80206d:	75 c1                	jne    802030 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80206f:	8b 52 58             	mov    0x58(%edx),%edx
  802072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802076:	89 54 24 08          	mov    %edx,0x8(%esp)
  80207a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80207e:	c7 04 24 c2 2e 80 00 	movl   $0x802ec2,(%esp)
  802085:	e8 2d e2 ff ff       	call   8002b7 <cprintf>
  80208a:	eb a4                	jmp    802030 <_pipeisclosed+0xe>

0080208c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	57                   	push   %edi
  802090:	56                   	push   %esi
  802091:	53                   	push   %ebx
  802092:	83 ec 2c             	sub    $0x2c,%esp
  802095:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802098:	89 34 24             	mov    %esi,(%esp)
  80209b:	e8 a0 f6 ff ff       	call   801740 <fd2data>
  8020a0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8020a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020ab:	75 50                	jne    8020fd <devpipe_write+0x71>
  8020ad:	eb 5c                	jmp    80210b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020af:	89 da                	mov    %ebx,%edx
  8020b1:	89 f0                	mov    %esi,%eax
  8020b3:	e8 6a ff ff ff       	call   802022 <_pipeisclosed>
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	75 53                	jne    80210f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020bc:	e8 1b ee ff ff       	call   800edc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8020c4:	8b 13                	mov    (%ebx),%edx
  8020c6:	83 c2 20             	add    $0x20,%edx
  8020c9:	39 d0                	cmp    %edx,%eax
  8020cb:	73 e2                	jae    8020af <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  8020d4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  8020d7:	89 c2                	mov    %eax,%edx
  8020d9:	c1 fa 1f             	sar    $0x1f,%edx
  8020dc:	c1 ea 1b             	shr    $0x1b,%edx
  8020df:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8020e2:	83 e1 1f             	and    $0x1f,%ecx
  8020e5:	29 d1                	sub    %edx,%ecx
  8020e7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8020eb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8020ef:	83 c0 01             	add    $0x1,%eax
  8020f2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f5:	83 c7 01             	add    $0x1,%edi
  8020f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020fb:	74 0e                	je     80210b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020fd:	8b 43 04             	mov    0x4(%ebx),%eax
  802100:	8b 13                	mov    (%ebx),%edx
  802102:	83 c2 20             	add    $0x20,%edx
  802105:	39 d0                	cmp    %edx,%eax
  802107:	73 a6                	jae    8020af <devpipe_write+0x23>
  802109:	eb c2                	jmp    8020cd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	eb 05                	jmp    802114 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80210f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802114:	83 c4 2c             	add    $0x2c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 28             	sub    $0x28,%esp
  802122:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802125:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802128:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80212b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80212e:	89 3c 24             	mov    %edi,(%esp)
  802131:	e8 0a f6 ff ff       	call   801740 <fd2data>
  802136:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802138:	be 00 00 00 00       	mov    $0x0,%esi
  80213d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802141:	75 47                	jne    80218a <devpipe_read+0x6e>
  802143:	eb 52                	jmp    802197 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802145:	89 f0                	mov    %esi,%eax
  802147:	eb 5e                	jmp    8021a7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802149:	89 da                	mov    %ebx,%edx
  80214b:	89 f8                	mov    %edi,%eax
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	e8 cd fe ff ff       	call   802022 <_pipeisclosed>
  802155:	85 c0                	test   %eax,%eax
  802157:	75 49                	jne    8021a2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802159:	e8 7e ed ff ff       	call   800edc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80215e:	8b 03                	mov    (%ebx),%eax
  802160:	3b 43 04             	cmp    0x4(%ebx),%eax
  802163:	74 e4                	je     802149 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802165:	89 c2                	mov    %eax,%edx
  802167:	c1 fa 1f             	sar    $0x1f,%edx
  80216a:	c1 ea 1b             	shr    $0x1b,%edx
  80216d:	01 d0                	add    %edx,%eax
  80216f:	83 e0 1f             	and    $0x1f,%eax
  802172:	29 d0                	sub    %edx,%eax
  802174:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80217c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80217f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802182:	83 c6 01             	add    $0x1,%esi
  802185:	3b 75 10             	cmp    0x10(%ebp),%esi
  802188:	74 0d                	je     802197 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80218a:	8b 03                	mov    (%ebx),%eax
  80218c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80218f:	75 d4                	jne    802165 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802191:	85 f6                	test   %esi,%esi
  802193:	75 b0                	jne    802145 <devpipe_read+0x29>
  802195:	eb b2                	jmp    802149 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802197:	89 f0                	mov    %esi,%eax
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	eb 05                	jmp    8021a7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021a2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8021aa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8021ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8021b0:	89 ec                	mov    %ebp,%esp
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	83 ec 48             	sub    $0x48,%esp
  8021ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8021bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8021c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8021c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8021c9:	89 04 24             	mov    %eax,(%esp)
  8021cc:	e8 8a f5 ff ff       	call   80175b <fd_alloc>
  8021d1:	89 c3                	mov    %eax,%ebx
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	0f 88 45 01 00 00    	js     802320 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021db:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021e2:	00 
  8021e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f1:	e8 16 ed ff ff       	call   800f0c <sys_page_alloc>
  8021f6:	89 c3                	mov    %eax,%ebx
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	0f 88 20 01 00 00    	js     802320 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802200:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802203:	89 04 24             	mov    %eax,(%esp)
  802206:	e8 50 f5 ff ff       	call   80175b <fd_alloc>
  80220b:	89 c3                	mov    %eax,%ebx
  80220d:	85 c0                	test   %eax,%eax
  80220f:	0f 88 f8 00 00 00    	js     80230d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802215:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80221c:	00 
  80221d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802220:	89 44 24 04          	mov    %eax,0x4(%esp)
  802224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80222b:	e8 dc ec ff ff       	call   800f0c <sys_page_alloc>
  802230:	89 c3                	mov    %eax,%ebx
  802232:	85 c0                	test   %eax,%eax
  802234:	0f 88 d3 00 00 00    	js     80230d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80223a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80223d:	89 04 24             	mov    %eax,(%esp)
  802240:	e8 fb f4 ff ff       	call   801740 <fd2data>
  802245:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802247:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80224e:	00 
  80224f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802253:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80225a:	e8 ad ec ff ff       	call   800f0c <sys_page_alloc>
  80225f:	89 c3                	mov    %eax,%ebx
  802261:	85 c0                	test   %eax,%eax
  802263:	0f 88 91 00 00 00    	js     8022fa <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802269:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80226c:	89 04 24             	mov    %eax,(%esp)
  80226f:	e8 cc f4 ff ff       	call   801740 <fd2data>
  802274:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80227b:	00 
  80227c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802287:	00 
  802288:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802293:	e8 d3 ec ff ff       	call   800f6b <sys_page_map>
  802298:	89 c3                	mov    %eax,%ebx
  80229a:	85 c0                	test   %eax,%eax
  80229c:	78 4c                	js     8022ea <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80229e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8022a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022a7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022b3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8022b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022bc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022c1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022cb:	89 04 24             	mov    %eax,(%esp)
  8022ce:	e8 5d f4 ff ff       	call   801730 <fd2num>
  8022d3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8022d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022d8:	89 04 24             	mov    %eax,(%esp)
  8022db:	e8 50 f4 ff ff       	call   801730 <fd2num>
  8022e0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8022e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022e8:	eb 36                	jmp    802320 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8022ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f5:	e8 cf ec ff ff       	call   800fc9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8022fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802301:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802308:	e8 bc ec ff ff       	call   800fc9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80230d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802310:	89 44 24 04          	mov    %eax,0x4(%esp)
  802314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80231b:	e8 a9 ec ff ff       	call   800fc9 <sys_page_unmap>
    err:
	return r;
}
  802320:	89 d8                	mov    %ebx,%eax
  802322:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802325:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802328:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80232b:	89 ec                	mov    %ebp,%esp
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    

0080232f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80232f:	55                   	push   %ebp
  802330:	89 e5                	mov    %esp,%ebp
  802332:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	8b 45 08             	mov    0x8(%ebp),%eax
  80233f:	89 04 24             	mov    %eax,(%esp)
  802342:	e8 87 f4 ff ff       	call   8017ce <fd_lookup>
  802347:	85 c0                	test   %eax,%eax
  802349:	78 15                	js     802360 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80234b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234e:	89 04 24             	mov    %eax,(%esp)
  802351:	e8 ea f3 ff ff       	call   801740 <fd2data>
	return _pipeisclosed(fd, p);
  802356:	89 c2                	mov    %eax,%edx
  802358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235b:	e8 c2 fc ff ff       	call   802022 <_pipeisclosed>
}
  802360:	c9                   	leave  
  802361:	c3                   	ret    
	...

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
  802380:	c7 44 24 04 da 2e 80 	movl   $0x802eda,0x4(%esp)
  802387:	00 
  802388:	8b 45 0c             	mov    0xc(%ebp),%eax
  80238b:	89 04 24             	mov    %eax,(%esp)
  80238e:	e8 78 e6 ff ff       	call   800a0b <strcpy>
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
  8023da:	e8 1d e8 ff ff       	call   800bfc <memmove>
		sys_cputs(buf, m);
  8023df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023e3:	89 3c 24             	mov    %edi,(%esp)
  8023e6:	e8 05 ea ff ff       	call   800df0 <sys_cputs>
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
  802414:	e8 c3 ea ff ff       	call   800edc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	e8 fa e9 ff ff       	call   800e1f <sys_cgetc>
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
  802461:	e8 8a e9 ff ff       	call   800df0 <sys_cputs>
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
  802484:	e8 05 f6 ff ff       	call   801a8e <read>
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
  8024b1:	e8 18 f3 ff ff       	call   8017ce <fd_lookup>
  8024b6:	85 c0                	test   %eax,%eax
  8024b8:	78 11                	js     8024cb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bd:	8b 15 40 30 80 00    	mov    0x803040,%edx
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
  8024d9:	e8 7d f2 ff ff       	call   80175b <fd_alloc>
  8024de:	85 c0                	test   %eax,%eax
  8024e0:	78 3c                	js     80251e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024e9:	00 
  8024ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f8:	e8 0f ea ff ff       	call   800f0c <sys_page_alloc>
  8024fd:	85 c0                	test   %eax,%eax
  8024ff:	78 1d                	js     80251e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802501:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80250c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802516:	89 04 24             	mov    %eax,(%esp)
  802519:	e8 12 f2 ff ff       	call   801730 <fd2num>
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
  802526:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80252d:	75 3c                	jne    80256b <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80252f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802536:	00 
  802537:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80253e:	ee 
  80253f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802546:	e8 c1 e9 ff ff       	call   800f0c <sys_page_alloc>
  80254b:	85 c0                	test   %eax,%eax
  80254d:	79 1c                	jns    80256b <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  80254f:	c7 44 24 08 e8 2e 80 	movl   $0x802ee8,0x8(%esp)
  802556:	00 
  802557:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80255e:	00 
  80255f:	c7 04 24 4c 2f 80 00 	movl   $0x802f4c,(%esp)
  802566:	e8 51 dc ff ff       	call   8001bc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80256b:	8b 45 08             	mov    0x8(%ebp),%eax
  80256e:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802573:	c7 44 24 04 ac 25 80 	movl   $0x8025ac,0x4(%esp)
  80257a:	00 
  80257b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802582:	e8 5c eb ff ff       	call   8010e3 <sys_env_set_pgfault_upcall>
  802587:	85 c0                	test   %eax,%eax
  802589:	79 1c                	jns    8025a7 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80258b:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  802592:	00 
  802593:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80259a:	00 
  80259b:	c7 04 24 4c 2f 80 00 	movl   $0x802f4c,(%esp)
  8025a2:	e8 15 dc ff ff       	call   8001bc <_panic>
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
  8025ad:	a1 00 60 80 00       	mov    0x806000,%eax
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

008025d0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025d6:	89 d0                	mov    %edx,%eax
  8025d8:	c1 e8 16             	shr    $0x16,%eax
  8025db:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025e2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025e7:	f6 c1 01             	test   $0x1,%cl
  8025ea:	74 1d                	je     802609 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025ec:	c1 ea 0c             	shr    $0xc,%edx
  8025ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025f6:	f6 c2 01             	test   $0x1,%dl
  8025f9:	74 0e                	je     802609 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025fb:	c1 ea 0c             	shr    $0xc,%edx
  8025fe:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802605:	ef 
  802606:	0f b7 c0             	movzwl %ax,%eax
}
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    
  80260b:	00 00                	add    %al,(%eax)
  80260d:	00 00                	add    %al,(%eax)
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
