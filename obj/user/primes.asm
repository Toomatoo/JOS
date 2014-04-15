
obj/user/primes:     file format elf32-i386


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
  800053:	e8 74 14 00 00       	call   8014cc <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 08 20 80 00       	mov    0x802008,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 18 80 00 	movl   $0x8018c0,(%esp)
  800071:	e8 39 02 00 00       	call   8002af <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 20 12 00 00       	call   80129b <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 de 1b 80 	movl   $0x801bde,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 cc 18 80 00 	movl   $0x8018cc,(%esp)
  80009c:	e8 13 01 00 00       	call   8001b4 <_panic>
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
  8000bb:	e8 0c 14 00 00       	call   8014cc <ipc_recv>
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
  8000e4:	e8 05 14 00 00       	call   8014ee <ipc_send>
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
  8000f3:	e8 a3 11 00 00       	call   80129b <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 de 1b 80 	movl   $0x801bde,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 cc 18 80 00 	movl   $0x8018cc,(%esp)
  800119:	e8 96 00 00 00       	call   8001b4 <_panic>
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
  800143:	e8 a6 13 00 00       	call   8014ee <ipc_send>
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
  800162:	e8 35 0d 00 00       	call   800e9c <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 8d 0c 00 00       	call   800e3f <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001bc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c5:	e8 d2 0c 00 00       	call   800e9c <sys_getenvid>
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	c7 04 24 e4 18 80 00 	movl   $0x8018e4,(%esp)
  8001e7:	e8 c3 00 00 00       	call   8002af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 53 00 00 00       	call   80024e <vcprintf>
	cprintf("\n");
  8001fb:	c7 04 24 07 19 80 00 	movl   $0x801907,(%esp)
  800202:	e8 a8 00 00 00       	call   8002af <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800207:	cc                   	int3   
  800208:	eb fd                	jmp    800207 <_panic+0x53>
	...

0080020c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	83 ec 14             	sub    $0x14,%esp
  800213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800216:	8b 03                	mov    (%ebx),%eax
  800218:	8b 55 08             	mov    0x8(%ebp),%edx
  80021b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021f:	83 c0 01             	add    $0x1,%eax
  800222:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800224:	3d ff 00 00 00       	cmp    $0xff,%eax
  800229:	75 19                	jne    800244 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80022b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800232:	00 
  800233:	8d 43 08             	lea    0x8(%ebx),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 a2 0b 00 00       	call   800de0 <sys_cputs>
		b->idx = 0;
  80023e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800244:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800257:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025e:	00 00 00 
	b.cnt = 0;
  800261:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800268:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	89 44 24 08          	mov    %eax,0x8(%esp)
  800279:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800283:	c7 04 24 0c 02 80 00 	movl   $0x80020c,(%esp)
  80028a:	e8 97 01 00 00       	call   800426 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800295:	89 44 24 04          	mov    %eax,0x4(%esp)
  800299:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 39 0b 00 00       	call   800de0 <sys_cputs>

	return b.cnt;
}
  8002a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	e8 87 ff ff ff       	call   80024e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
	...

008002cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 3c             	sub    $0x3c,%esp
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	89 d7                	mov    %edx,%edi
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f4:	72 11                	jb     800307 <printnum+0x3b>
  8002f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002fc:	76 09                	jbe    800307 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fe:	83 eb 01             	sub    $0x1,%ebx
  800301:	85 db                	test   %ebx,%ebx
  800303:	7f 51                	jg     800356 <printnum+0x8a>
  800305:	eb 5e                	jmp    800365 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800307:	89 74 24 10          	mov    %esi,0x10(%esp)
  80030b:	83 eb 01             	sub    $0x1,%ebx
  80030e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800312:	8b 45 10             	mov    0x10(%ebp),%eax
  800315:	89 44 24 08          	mov    %eax,0x8(%esp)
  800319:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80031d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800321:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800328:	00 
  800329:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800332:	89 44 24 04          	mov    %eax,0x4(%esp)
  800336:	e8 d5 12 00 00       	call   801610 <__udivdi3>
  80033b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034a:	89 fa                	mov    %edi,%edx
  80034c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034f:	e8 78 ff ff ff       	call   8002cc <printnum>
  800354:	eb 0f                	jmp    800365 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800356:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035a:	89 34 24             	mov    %esi,(%esp)
  80035d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800360:	83 eb 01             	sub    $0x1,%ebx
  800363:	75 f1                	jne    800356 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800365:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800369:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80036d:	8b 45 10             	mov    0x10(%ebp),%eax
  800370:	89 44 24 08          	mov    %eax,0x8(%esp)
  800374:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037b:	00 
  80037c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037f:	89 04 24             	mov    %eax,(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	e8 b2 13 00 00       	call   801740 <__umoddi3>
  80038e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800392:	0f be 80 09 19 80 00 	movsbl 0x801909(%eax),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039f:	83 c4 3c             	add    $0x3c,%esp
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003aa:	83 fa 01             	cmp    $0x1,%edx
  8003ad:	7e 0e                	jle    8003bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	8b 52 04             	mov    0x4(%edx),%edx
  8003bb:	eb 22                	jmp    8003df <getuint+0x38>
	else if (lflag)
  8003bd:	85 d2                	test   %edx,%edx
  8003bf:	74 10                	je     8003d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c1:	8b 10                	mov    (%eax),%edx
  8003c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c6:	89 08                	mov    %ecx,(%eax)
  8003c8:	8b 02                	mov    (%edx),%eax
  8003ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cf:	eb 0e                	jmp    8003df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d1:	8b 10                	mov    (%eax),%edx
  8003d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d6:	89 08                	mov    %ecx,(%eax)
  8003d8:	8b 02                	mov    (%edx),%eax
  8003da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003eb:	8b 10                	mov    (%eax),%edx
  8003ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f0:	73 0a                	jae    8003fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f5:	88 0a                	mov    %cl,(%edx)
  8003f7:	83 c2 01             	add    $0x1,%edx
  8003fa:	89 10                	mov    %edx,(%eax)
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800407:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040b:	8b 45 10             	mov    0x10(%ebp),%eax
  80040e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
  800415:	89 44 24 04          	mov    %eax,0x4(%esp)
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	e8 02 00 00 00       	call   800426 <vprintfmt>
	va_end(ap);
}
  800424:	c9                   	leave  
  800425:	c3                   	ret    

00800426 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	57                   	push   %edi
  80042a:	56                   	push   %esi
  80042b:	53                   	push   %ebx
  80042c:	83 ec 5c             	sub    $0x5c,%esp
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800432:	8b 75 10             	mov    0x10(%ebp),%esi
  800435:	eb 12                	jmp    800449 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800437:	85 c0                	test   %eax,%eax
  800439:	0f 84 e4 04 00 00    	je     800923 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80043f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	0f b6 06             	movzbl (%esi),%eax
  80044c:	83 c6 01             	add    $0x1,%esi
  80044f:	83 f8 25             	cmp    $0x25,%eax
  800452:	75 e3                	jne    800437 <vprintfmt+0x11>
  800454:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800458:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80045f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800464:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80046b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800470:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800473:	eb 2b                	jmp    8004a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800478:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80047c:	eb 22                	jmp    8004a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800481:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800485:	eb 19                	jmp    8004a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80048a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800491:	eb 0d                	jmp    8004a0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800493:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800496:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800499:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	0f b6 06             	movzbl (%esi),%eax
  8004a3:	0f b6 d0             	movzbl %al,%edx
  8004a6:	8d 7e 01             	lea    0x1(%esi),%edi
  8004a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ac:	83 e8 23             	sub    $0x23,%eax
  8004af:	3c 55                	cmp    $0x55,%al
  8004b1:	0f 87 46 04 00 00    	ja     8008fd <vprintfmt+0x4d7>
  8004b7:	0f b6 c0             	movzbl %al,%eax
  8004ba:	ff 24 85 e0 19 80 00 	jmp    *0x8019e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c1:	83 ea 30             	sub    $0x30,%edx
  8004c4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004c7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004cb:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004d1:	83 fa 09             	cmp    $0x9,%edx
  8004d4:	77 4a                	ja     800520 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004dc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004df:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004e3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004e9:	83 fa 09             	cmp    $0x9,%edx
  8004ec:	76 eb                	jbe    8004d9 <vprintfmt+0xb3>
  8004ee:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004f1:	eb 2d                	jmp    800520 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8d 50 04             	lea    0x4(%eax),%edx
  8004f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fc:	8b 00                	mov    (%eax),%eax
  8004fe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800504:	eb 1a                	jmp    800520 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800509:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80050d:	79 91                	jns    8004a0 <vprintfmt+0x7a>
  80050f:	e9 73 ff ff ff       	jmp    800487 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800517:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80051e:	eb 80                	jmp    8004a0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800520:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800524:	0f 89 76 ff ff ff    	jns    8004a0 <vprintfmt+0x7a>
  80052a:	e9 64 ff ff ff       	jmp    800493 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800535:	e9 66 ff ff ff       	jmp    8004a0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 04 24             	mov    %eax,(%esp)
  80054c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800552:	e9 f2 fe ff ff       	jmp    800449 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800557:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80055b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80055e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800562:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800565:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800569:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80056c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80056f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800573:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800576:	80 f9 09             	cmp    $0x9,%cl
  800579:	77 1d                	ja     800598 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80057b:	0f be c0             	movsbl %al,%eax
  80057e:	6b c0 64             	imul   $0x64,%eax,%eax
  800581:	0f be d2             	movsbl %dl,%edx
  800584:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800587:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80058e:	a3 04 20 80 00       	mov    %eax,0x802004
  800593:	e9 b1 fe ff ff       	jmp    800449 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800598:	c7 44 24 04 21 19 80 	movl   $0x801921,0x4(%esp)
  80059f:	00 
  8005a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	e8 10 05 00 00       	call   800abb <strcmp>
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 0f                	jne    8005be <vprintfmt+0x198>
  8005af:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8005b6:	00 00 00 
  8005b9:	e9 8b fe ff ff       	jmp    800449 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8005be:	c7 44 24 04 25 19 80 	movl   $0x801925,0x4(%esp)
  8005c5:	00 
  8005c6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005c9:	89 14 24             	mov    %edx,(%esp)
  8005cc:	e8 ea 04 00 00       	call   800abb <strcmp>
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	75 0f                	jne    8005e4 <vprintfmt+0x1be>
  8005d5:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005dc:	00 00 00 
  8005df:	e9 65 fe ff ff       	jmp    800449 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005e4:	c7 44 24 04 29 19 80 	movl   $0x801929,0x4(%esp)
  8005eb:	00 
  8005ec:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005ef:	89 0c 24             	mov    %ecx,(%esp)
  8005f2:	e8 c4 04 00 00       	call   800abb <strcmp>
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	75 0f                	jne    80060a <vprintfmt+0x1e4>
  8005fb:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800602:	00 00 00 
  800605:	e9 3f fe ff ff       	jmp    800449 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80060a:	c7 44 24 04 2d 19 80 	movl   $0x80192d,0x4(%esp)
  800611:	00 
  800612:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800615:	89 3c 24             	mov    %edi,(%esp)
  800618:	e8 9e 04 00 00       	call   800abb <strcmp>
  80061d:	85 c0                	test   %eax,%eax
  80061f:	75 0f                	jne    800630 <vprintfmt+0x20a>
  800621:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800628:	00 00 00 
  80062b:	e9 19 fe ff ff       	jmp    800449 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800630:	c7 44 24 04 31 19 80 	movl   $0x801931,0x4(%esp)
  800637:	00 
  800638:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 78 04 00 00       	call   800abb <strcmp>
  800643:	85 c0                	test   %eax,%eax
  800645:	75 0f                	jne    800656 <vprintfmt+0x230>
  800647:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80064e:	00 00 00 
  800651:	e9 f3 fd ff ff       	jmp    800449 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800656:	c7 44 24 04 35 19 80 	movl   $0x801935,0x4(%esp)
  80065d:	00 
  80065e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800661:	89 14 24             	mov    %edx,(%esp)
  800664:	e8 52 04 00 00       	call   800abb <strcmp>
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	19 c0                	sbb    %eax,%eax
  80066e:	f7 d0                	not    %eax
  800670:	83 c0 08             	add    $0x8,%eax
  800673:	a3 04 20 80 00       	mov    %eax,0x802004
  800678:	e9 cc fd ff ff       	jmp    800449 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 04             	lea    0x4(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)
  800686:	8b 00                	mov    (%eax),%eax
  800688:	89 c2                	mov    %eax,%edx
  80068a:	c1 fa 1f             	sar    $0x1f,%edx
  80068d:	31 d0                	xor    %edx,%eax
  80068f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800691:	83 f8 08             	cmp    $0x8,%eax
  800694:	7f 0b                	jg     8006a1 <vprintfmt+0x27b>
  800696:	8b 14 85 40 1b 80 00 	mov    0x801b40(,%eax,4),%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	75 23                	jne    8006c4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8006a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a5:	c7 44 24 08 39 19 80 	movl   $0x801939,0x8(%esp)
  8006ac:	00 
  8006ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b4:	89 3c 24             	mov    %edi,(%esp)
  8006b7:	e8 42 fd ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006bf:	e9 85 fd ff ff       	jmp    800449 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c8:	c7 44 24 08 42 19 80 	movl   $0x801942,0x8(%esp)
  8006cf:	00 
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d7:	89 3c 24             	mov    %edi,(%esp)
  8006da:	e8 1f fd ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006e2:	e9 62 fd ff ff       	jmp    800449 <vprintfmt+0x23>
  8006e7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ed:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 04             	lea    0x4(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006fb:	85 f6                	test   %esi,%esi
  8006fd:	b8 1a 19 80 00       	mov    $0x80191a,%eax
  800702:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800705:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800709:	7e 06                	jle    800711 <vprintfmt+0x2eb>
  80070b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80070f:	75 13                	jne    800724 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800711:	0f be 06             	movsbl (%esi),%eax
  800714:	83 c6 01             	add    $0x1,%esi
  800717:	85 c0                	test   %eax,%eax
  800719:	0f 85 94 00 00 00    	jne    8007b3 <vprintfmt+0x38d>
  80071f:	e9 81 00 00 00       	jmp    8007a5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800724:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800728:	89 34 24             	mov    %esi,(%esp)
  80072b:	e8 9b 02 00 00       	call   8009cb <strnlen>
  800730:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800733:	29 c2                	sub    %eax,%edx
  800735:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e d5                	jle    800711 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80073c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800740:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800743:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800746:	89 d6                	mov    %edx,%esi
  800748:	89 cf                	mov    %ecx,%edi
  80074a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074e:	89 3c 24             	mov    %edi,(%esp)
  800751:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800754:	83 ee 01             	sub    $0x1,%esi
  800757:	75 f1                	jne    80074a <vprintfmt+0x324>
  800759:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80075c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80075f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800762:	eb ad                	jmp    800711 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800764:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800768:	74 1b                	je     800785 <vprintfmt+0x35f>
  80076a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80076d:	83 fa 5e             	cmp    $0x5e,%edx
  800770:	76 13                	jbe    800785 <vprintfmt+0x35f>
					putch('?', putdat);
  800772:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800775:	89 44 24 04          	mov    %eax,0x4(%esp)
  800779:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
  800783:	eb 0d                	jmp    800792 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800785:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800788:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800792:	83 eb 01             	sub    $0x1,%ebx
  800795:	0f be 06             	movsbl (%esi),%eax
  800798:	83 c6 01             	add    $0x1,%esi
  80079b:	85 c0                	test   %eax,%eax
  80079d:	75 1a                	jne    8007b9 <vprintfmt+0x393>
  80079f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007ac:	7f 1c                	jg     8007ca <vprintfmt+0x3a4>
  8007ae:	e9 96 fc ff ff       	jmp    800449 <vprintfmt+0x23>
  8007b3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007b6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b9:	85 ff                	test   %edi,%edi
  8007bb:	78 a7                	js     800764 <vprintfmt+0x33e>
  8007bd:	83 ef 01             	sub    $0x1,%edi
  8007c0:	79 a2                	jns    800764 <vprintfmt+0x33e>
  8007c2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007c5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007c8:	eb db                	jmp    8007a5 <vprintfmt+0x37f>
  8007ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007cd:	89 de                	mov    %ebx,%esi
  8007cf:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007df:	83 eb 01             	sub    $0x1,%ebx
  8007e2:	75 ee                	jne    8007d2 <vprintfmt+0x3ac>
  8007e4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007e9:	e9 5b fc ff ff       	jmp    800449 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ee:	83 f9 01             	cmp    $0x1,%ecx
  8007f1:	7e 10                	jle    800803 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 50 08             	lea    0x8(%eax),%edx
  8007f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fc:	8b 30                	mov    (%eax),%esi
  8007fe:	8b 78 04             	mov    0x4(%eax),%edi
  800801:	eb 26                	jmp    800829 <vprintfmt+0x403>
	else if (lflag)
  800803:	85 c9                	test   %ecx,%ecx
  800805:	74 12                	je     800819 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 04             	lea    0x4(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 30                	mov    (%eax),%esi
  800812:	89 f7                	mov    %esi,%edi
  800814:	c1 ff 1f             	sar    $0x1f,%edi
  800817:	eb 10                	jmp    800829 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8d 50 04             	lea    0x4(%eax),%edx
  80081f:	89 55 14             	mov    %edx,0x14(%ebp)
  800822:	8b 30                	mov    (%eax),%esi
  800824:	89 f7                	mov    %esi,%edi
  800826:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800829:	85 ff                	test   %edi,%edi
  80082b:	78 0e                	js     80083b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80082d:	89 f0                	mov    %esi,%eax
  80082f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800831:	be 0a 00 00 00       	mov    $0xa,%esi
  800836:	e9 84 00 00 00       	jmp    8008bf <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80083b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800846:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800849:	89 f0                	mov    %esi,%eax
  80084b:	89 fa                	mov    %edi,%edx
  80084d:	f7 d8                	neg    %eax
  80084f:	83 d2 00             	adc    $0x0,%edx
  800852:	f7 da                	neg    %edx
			}
			base = 10;
  800854:	be 0a 00 00 00       	mov    $0xa,%esi
  800859:	eb 64                	jmp    8008bf <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80085b:	89 ca                	mov    %ecx,%edx
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
  800860:	e8 42 fb ff ff       	call   8003a7 <getuint>
			base = 10;
  800865:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80086a:	eb 53                	jmp    8008bf <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80086c:	89 ca                	mov    %ecx,%edx
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
  800871:	e8 31 fb ff ff       	call   8003a7 <getuint>
    			base = 8;
  800876:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80087b:	eb 42                	jmp    8008bf <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80087d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800881:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800888:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80088b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800896:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8d 50 04             	lea    0x4(%eax),%edx
  80089f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008a2:	8b 00                	mov    (%eax),%eax
  8008a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008ae:	eb 0f                	jmp    8008bf <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008b0:	89 ca                	mov    %ecx,%edx
  8008b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b5:	e8 ed fa ff ff       	call   8003a7 <getuint>
			base = 16;
  8008ba:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008bf:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008c7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008ca:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008d2:	89 04 24             	mov    %eax,(%esp)
  8008d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d9:	89 da                	mov    %ebx,%edx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	e8 e9 f9 ff ff       	call   8002cc <printnum>
			break;
  8008e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008e6:	e9 5e fb ff ff       	jmp    800449 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ef:	89 14 24             	mov    %edx,(%esp)
  8008f2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f8:	e9 4c fb ff ff       	jmp    800449 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800901:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800908:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80090f:	0f 84 34 fb ff ff    	je     800449 <vprintfmt+0x23>
  800915:	83 ee 01             	sub    $0x1,%esi
  800918:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80091c:	75 f7                	jne    800915 <vprintfmt+0x4ef>
  80091e:	e9 26 fb ff ff       	jmp    800449 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800923:	83 c4 5c             	add    $0x5c,%esp
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 28             	sub    $0x28,%esp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800937:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800948:	85 c0                	test   %eax,%eax
  80094a:	74 30                	je     80097c <vsnprintf+0x51>
  80094c:	85 d2                	test   %edx,%edx
  80094e:	7e 2c                	jle    80097c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800950:	8b 45 14             	mov    0x14(%ebp),%eax
  800953:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800957:	8b 45 10             	mov    0x10(%ebp),%eax
  80095a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800961:	89 44 24 04          	mov    %eax,0x4(%esp)
  800965:	c7 04 24 e1 03 80 00 	movl   $0x8003e1,(%esp)
  80096c:	e8 b5 fa ff ff       	call   800426 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800971:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800974:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800977:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097a:	eb 05                	jmp    800981 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80097c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800989:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800990:	8b 45 10             	mov    0x10(%ebp),%eax
  800993:	89 44 24 08          	mov    %eax,0x8(%esp)
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	89 04 24             	mov    %eax,(%esp)
  8009a4:	e8 82 ff ff ff       	call   80092b <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    
  8009ab:	00 00                	add    %al,(%eax)
  8009ad:	00 00                	add    %al,(%eax)
	...

008009b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009be:	74 09                	je     8009c9 <strlen+0x19>
		n++;
  8009c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c7:	75 f7                	jne    8009c0 <strlen+0x10>
		n++;
	return n;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	74 1a                	je     8009f8 <strnlen+0x2d>
  8009de:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009e1:	74 15                	je     8009f8 <strnlen+0x2d>
  8009e3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009e8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ea:	39 ca                	cmp    %ecx,%edx
  8009ec:	74 0a                	je     8009f8 <strnlen+0x2d>
  8009ee:	83 c2 01             	add    $0x1,%edx
  8009f1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009f6:	75 f0                	jne    8009e8 <strnlen+0x1d>
		n++;
	return n;
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a0e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a11:	83 c2 01             	add    $0x1,%edx
  800a14:	84 c9                	test   %cl,%cl
  800a16:	75 f2                	jne    800a0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	83 ec 08             	sub    $0x8,%esp
  800a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a25:	89 1c 24             	mov    %ebx,(%esp)
  800a28:	e8 83 ff ff ff       	call   8009b0 <strlen>
	strcpy(dst + len, src);
  800a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a30:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a34:	01 d8                	add    %ebx,%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	e8 bd ff ff ff       	call   8009fb <strcpy>
	return dst;
}
  800a3e:	89 d8                	mov    %ebx,%eax
  800a40:	83 c4 08             	add    $0x8,%esp
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a54:	85 f6                	test   %esi,%esi
  800a56:	74 18                	je     800a70 <strncpy+0x2a>
  800a58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a5d:	0f b6 1a             	movzbl (%edx),%ebx
  800a60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a63:	80 3a 01             	cmpb   $0x1,(%edx)
  800a66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	39 f1                	cmp    %esi,%ecx
  800a6e:	75 ed                	jne    800a5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a80:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a83:	89 f8                	mov    %edi,%eax
  800a85:	85 f6                	test   %esi,%esi
  800a87:	74 2b                	je     800ab4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a89:	83 fe 01             	cmp    $0x1,%esi
  800a8c:	74 23                	je     800ab1 <strlcpy+0x3d>
  800a8e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a91:	84 c9                	test   %cl,%cl
  800a93:	74 1c                	je     800ab1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a95:	83 ee 02             	sub    $0x2,%esi
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a9d:	88 08                	mov    %cl,(%eax)
  800a9f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa2:	39 f2                	cmp    %esi,%edx
  800aa4:	74 0b                	je     800ab1 <strlcpy+0x3d>
  800aa6:	83 c2 01             	add    $0x1,%edx
  800aa9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800aad:	84 c9                	test   %cl,%cl
  800aaf:	75 ec                	jne    800a9d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800ab1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ab4:	29 f8                	sub    %edi,%eax
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ac4:	0f b6 01             	movzbl (%ecx),%eax
  800ac7:	84 c0                	test   %al,%al
  800ac9:	74 16                	je     800ae1 <strcmp+0x26>
  800acb:	3a 02                	cmp    (%edx),%al
  800acd:	75 12                	jne    800ae1 <strcmp+0x26>
		p++, q++;
  800acf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ad2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ad6:	84 c0                	test   %al,%al
  800ad8:	74 07                	je     800ae1 <strcmp+0x26>
  800ada:	83 c1 01             	add    $0x1,%ecx
  800add:	3a 02                	cmp    (%edx),%al
  800adf:	74 ee                	je     800acf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae1:	0f b6 c0             	movzbl %al,%eax
  800ae4:	0f b6 12             	movzbl (%edx),%edx
  800ae7:	29 d0                	sub    %edx,%eax
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800afd:	85 d2                	test   %edx,%edx
  800aff:	74 28                	je     800b29 <strncmp+0x3e>
  800b01:	0f b6 01             	movzbl (%ecx),%eax
  800b04:	84 c0                	test   %al,%al
  800b06:	74 24                	je     800b2c <strncmp+0x41>
  800b08:	3a 03                	cmp    (%ebx),%al
  800b0a:	75 20                	jne    800b2c <strncmp+0x41>
  800b0c:	83 ea 01             	sub    $0x1,%edx
  800b0f:	74 13                	je     800b24 <strncmp+0x39>
		n--, p++, q++;
  800b11:	83 c1 01             	add    $0x1,%ecx
  800b14:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b17:	0f b6 01             	movzbl (%ecx),%eax
  800b1a:	84 c0                	test   %al,%al
  800b1c:	74 0e                	je     800b2c <strncmp+0x41>
  800b1e:	3a 03                	cmp    (%ebx),%al
  800b20:	74 ea                	je     800b0c <strncmp+0x21>
  800b22:	eb 08                	jmp    800b2c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2c:	0f b6 01             	movzbl (%ecx),%eax
  800b2f:	0f b6 13             	movzbl (%ebx),%edx
  800b32:	29 d0                	sub    %edx,%eax
  800b34:	eb f3                	jmp    800b29 <strncmp+0x3e>

00800b36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b40:	0f b6 10             	movzbl (%eax),%edx
  800b43:	84 d2                	test   %dl,%dl
  800b45:	74 1c                	je     800b63 <strchr+0x2d>
		if (*s == c)
  800b47:	38 ca                	cmp    %cl,%dl
  800b49:	75 09                	jne    800b54 <strchr+0x1e>
  800b4b:	eb 1b                	jmp    800b68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b4d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b50:	38 ca                	cmp    %cl,%dl
  800b52:	74 14                	je     800b68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b54:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	75 f1                	jne    800b4d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b61:	eb 05                	jmp    800b68 <strchr+0x32>
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b74:	0f b6 10             	movzbl (%eax),%edx
  800b77:	84 d2                	test   %dl,%dl
  800b79:	74 14                	je     800b8f <strfind+0x25>
		if (*s == c)
  800b7b:	38 ca                	cmp    %cl,%dl
  800b7d:	75 06                	jne    800b85 <strfind+0x1b>
  800b7f:	eb 0e                	jmp    800b8f <strfind+0x25>
  800b81:	38 ca                	cmp    %cl,%dl
  800b83:	74 0a                	je     800b8f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b85:	83 c0 01             	add    $0x1,%eax
  800b88:	0f b6 10             	movzbl (%eax),%edx
  800b8b:	84 d2                	test   %dl,%dl
  800b8d:	75 f2                	jne    800b81 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ba0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba9:	85 c9                	test   %ecx,%ecx
  800bab:	74 30                	je     800bdd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb3:	75 25                	jne    800bda <memset+0x49>
  800bb5:	f6 c1 03             	test   $0x3,%cl
  800bb8:	75 20                	jne    800bda <memset+0x49>
		c &= 0xFF;
  800bba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bbd:	89 d3                	mov    %edx,%ebx
  800bbf:	c1 e3 08             	shl    $0x8,%ebx
  800bc2:	89 d6                	mov    %edx,%esi
  800bc4:	c1 e6 18             	shl    $0x18,%esi
  800bc7:	89 d0                	mov    %edx,%eax
  800bc9:	c1 e0 10             	shl    $0x10,%eax
  800bcc:	09 f0                	or     %esi,%eax
  800bce:	09 d0                	or     %edx,%eax
  800bd0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bd2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bd5:	fc                   	cld    
  800bd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd8:	eb 03                	jmp    800bdd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bda:	fc                   	cld    
  800bdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bdd:	89 f8                	mov    %edi,%eax
  800bdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800be2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800be5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800be8:	89 ec                	mov    %ebp,%esp
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bf5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c01:	39 c6                	cmp    %eax,%esi
  800c03:	73 36                	jae    800c3b <memmove+0x4f>
  800c05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c08:	39 d0                	cmp    %edx,%eax
  800c0a:	73 2f                	jae    800c3b <memmove+0x4f>
		s += n;
		d += n;
  800c0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0f:	f6 c2 03             	test   $0x3,%dl
  800c12:	75 1b                	jne    800c2f <memmove+0x43>
  800c14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c1a:	75 13                	jne    800c2f <memmove+0x43>
  800c1c:	f6 c1 03             	test   $0x3,%cl
  800c1f:	75 0e                	jne    800c2f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c21:	83 ef 04             	sub    $0x4,%edi
  800c24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c2a:	fd                   	std    
  800c2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2d:	eb 09                	jmp    800c38 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c2f:	83 ef 01             	sub    $0x1,%edi
  800c32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c35:	fd                   	std    
  800c36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c38:	fc                   	cld    
  800c39:	eb 20                	jmp    800c5b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c41:	75 13                	jne    800c56 <memmove+0x6a>
  800c43:	a8 03                	test   $0x3,%al
  800c45:	75 0f                	jne    800c56 <memmove+0x6a>
  800c47:	f6 c1 03             	test   $0x3,%cl
  800c4a:	75 0a                	jne    800c56 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c4c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c4f:	89 c7                	mov    %eax,%edi
  800c51:	fc                   	cld    
  800c52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c54:	eb 05                	jmp    800c5b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	fc                   	cld    
  800c59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c61:	89 ec                	mov    %ebp,%esp
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	89 04 24             	mov    %eax,(%esp)
  800c7f:	e8 68 ff ff ff       	call   800bec <memmove>
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c92:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9a:	85 ff                	test   %edi,%edi
  800c9c:	74 37                	je     800cd5 <memcmp+0x4f>
		if (*s1 != *s2)
  800c9e:	0f b6 03             	movzbl (%ebx),%eax
  800ca1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca4:	83 ef 01             	sub    $0x1,%edi
  800ca7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800cac:	38 c8                	cmp    %cl,%al
  800cae:	74 1c                	je     800ccc <memcmp+0x46>
  800cb0:	eb 10                	jmp    800cc2 <memcmp+0x3c>
  800cb2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800cb7:	83 c2 01             	add    $0x1,%edx
  800cba:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cbe:	38 c8                	cmp    %cl,%al
  800cc0:	74 0a                	je     800ccc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800cc2:	0f b6 c0             	movzbl %al,%eax
  800cc5:	0f b6 c9             	movzbl %cl,%ecx
  800cc8:	29 c8                	sub    %ecx,%eax
  800cca:	eb 09                	jmp    800cd5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccc:	39 fa                	cmp    %edi,%edx
  800cce:	75 e2                	jne    800cb2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ce0:	89 c2                	mov    %eax,%edx
  800ce2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce5:	39 d0                	cmp    %edx,%eax
  800ce7:	73 19                	jae    800d02 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ced:	38 08                	cmp    %cl,(%eax)
  800cef:	75 06                	jne    800cf7 <memfind+0x1d>
  800cf1:	eb 0f                	jmp    800d02 <memfind+0x28>
  800cf3:	38 08                	cmp    %cl,(%eax)
  800cf5:	74 0b                	je     800d02 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cf7:	83 c0 01             	add    $0x1,%eax
  800cfa:	39 d0                	cmp    %edx,%eax
  800cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d00:	75 f1                	jne    800cf3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d10:	0f b6 02             	movzbl (%edx),%eax
  800d13:	3c 20                	cmp    $0x20,%al
  800d15:	74 04                	je     800d1b <strtol+0x17>
  800d17:	3c 09                	cmp    $0x9,%al
  800d19:	75 0e                	jne    800d29 <strtol+0x25>
		s++;
  800d1b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1e:	0f b6 02             	movzbl (%edx),%eax
  800d21:	3c 20                	cmp    $0x20,%al
  800d23:	74 f6                	je     800d1b <strtol+0x17>
  800d25:	3c 09                	cmp    $0x9,%al
  800d27:	74 f2                	je     800d1b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d29:	3c 2b                	cmp    $0x2b,%al
  800d2b:	75 0a                	jne    800d37 <strtol+0x33>
		s++;
  800d2d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d30:	bf 00 00 00 00       	mov    $0x0,%edi
  800d35:	eb 10                	jmp    800d47 <strtol+0x43>
  800d37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d3c:	3c 2d                	cmp    $0x2d,%al
  800d3e:	75 07                	jne    800d47 <strtol+0x43>
		s++, neg = 1;
  800d40:	83 c2 01             	add    $0x1,%edx
  800d43:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	0f 94 c0             	sete   %al
  800d4c:	74 05                	je     800d53 <strtol+0x4f>
  800d4e:	83 fb 10             	cmp    $0x10,%ebx
  800d51:	75 15                	jne    800d68 <strtol+0x64>
  800d53:	80 3a 30             	cmpb   $0x30,(%edx)
  800d56:	75 10                	jne    800d68 <strtol+0x64>
  800d58:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d5c:	75 0a                	jne    800d68 <strtol+0x64>
		s += 2, base = 16;
  800d5e:	83 c2 02             	add    $0x2,%edx
  800d61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d66:	eb 13                	jmp    800d7b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d68:	84 c0                	test   %al,%al
  800d6a:	74 0f                	je     800d7b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d71:	80 3a 30             	cmpb   $0x30,(%edx)
  800d74:	75 05                	jne    800d7b <strtol+0x77>
		s++, base = 8;
  800d76:	83 c2 01             	add    $0x1,%edx
  800d79:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d80:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d82:	0f b6 0a             	movzbl (%edx),%ecx
  800d85:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d88:	80 fb 09             	cmp    $0x9,%bl
  800d8b:	77 08                	ja     800d95 <strtol+0x91>
			dig = *s - '0';
  800d8d:	0f be c9             	movsbl %cl,%ecx
  800d90:	83 e9 30             	sub    $0x30,%ecx
  800d93:	eb 1e                	jmp    800db3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d95:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d98:	80 fb 19             	cmp    $0x19,%bl
  800d9b:	77 08                	ja     800da5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d9d:	0f be c9             	movsbl %cl,%ecx
  800da0:	83 e9 57             	sub    $0x57,%ecx
  800da3:	eb 0e                	jmp    800db3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800da5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800da8:	80 fb 19             	cmp    $0x19,%bl
  800dab:	77 14                	ja     800dc1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dad:	0f be c9             	movsbl %cl,%ecx
  800db0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800db3:	39 f1                	cmp    %esi,%ecx
  800db5:	7d 0e                	jge    800dc5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800db7:	83 c2 01             	add    $0x1,%edx
  800dba:	0f af c6             	imul   %esi,%eax
  800dbd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dbf:	eb c1                	jmp    800d82 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dc1:	89 c1                	mov    %eax,%ecx
  800dc3:	eb 02                	jmp    800dc7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dc5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dcb:	74 05                	je     800dd2 <strtol+0xce>
		*endptr = (char *) s;
  800dcd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dd2:	89 ca                	mov    %ecx,%edx
  800dd4:	f7 da                	neg    %edx
  800dd6:	85 ff                	test   %edi,%edi
  800dd8:	0f 45 c2             	cmovne %edx,%eax
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	b8 00 00 00 00       	mov    $0x0,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 c7                	mov    %eax,%edi
  800dfe:	89 c6                	mov    %eax,%esi
  800e00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0b:	89 ec                	mov    %ebp,%esp
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e23:	b8 01 00 00 00       	mov    $0x1,%eax
  800e28:	89 d1                	mov    %edx,%ecx
  800e2a:	89 d3                	mov    %edx,%ebx
  800e2c:	89 d7                	mov    %edx,%edi
  800e2e:	89 d6                	mov    %edx,%esi
  800e30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3b:	89 ec                	mov    %ebp,%esp
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 38             	sub    $0x38,%esp
  800e45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e53:	b8 03 00 00 00       	mov    $0x3,%eax
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	89 cf                	mov    %ecx,%edi
  800e5f:	89 ce                	mov    %ecx,%esi
  800e61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 28                	jle    800e8f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e72:	00 
  800e73:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e82:	00 
  800e83:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  800e8a:	e8 25 f3 ff ff       	call   8001b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eab:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800eb5:	89 d1                	mov    %edx,%ecx
  800eb7:	89 d3                	mov    %edx,%ebx
  800eb9:	89 d7                	mov    %edx,%edi
  800ebb:	89 d6                	mov    %edx,%esi
  800ebd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ebf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec8:	89 ec                	mov    %ebp,%esp
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_yield>:

void
sys_yield(void)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee5:	89 d1                	mov    %edx,%ecx
  800ee7:	89 d3                	mov    %edx,%ebx
  800ee9:	89 d7                	mov    %edx,%edi
  800eeb:	89 d6                	mov    %edx,%esi
  800eed:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef8:	89 ec                	mov    %ebp,%esp
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 38             	sub    $0x38,%esp
  800f02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0b:	be 00 00 00 00       	mov    $0x0,%esi
  800f10:	b8 04 00 00 00       	mov    $0x4,%eax
  800f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	89 f7                	mov    %esi,%edi
  800f20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 28                	jle    800f4e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f31:	00 
  800f32:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  800f39:	00 
  800f3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f41:	00 
  800f42:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  800f49:	e8 66 f2 ff ff       	call   8001b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f4e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f51:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f54:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f57:	89 ec                	mov    %ebp,%esp
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 38             	sub    $0x38,%esp
  800f61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f67:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f80:	85 c0                	test   %eax,%eax
  800f82:	7e 28                	jle    800fac <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f8f:	00 
  800f90:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  800f97:	00 
  800f98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9f:	00 
  800fa0:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  800fa7:	e8 08 f2 ff ff       	call   8001b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fac:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800faf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb5:	89 ec                	mov    %ebp,%esp
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 38             	sub    $0x38,%esp
  800fbf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcd:	b8 06 00 00 00       	mov    $0x6,%eax
  800fd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd8:	89 df                	mov    %ebx,%edi
  800fda:	89 de                	mov    %ebx,%esi
  800fdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	7e 28                	jle    80100a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fed:	00 
  800fee:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  800ff5:	00 
  800ff6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffd:	00 
  800ffe:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  801005:	e8 aa f1 ff ff       	call   8001b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80100a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801010:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801013:	89 ec                	mov    %ebp,%esp
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 38             	sub    $0x38,%esp
  80101d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801020:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801023:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801026:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102b:	b8 08 00 00 00       	mov    $0x8,%eax
  801030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801033:	8b 55 08             	mov    0x8(%ebp),%edx
  801036:	89 df                	mov    %ebx,%edi
  801038:	89 de                	mov    %ebx,%esi
  80103a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103c:	85 c0                	test   %eax,%eax
  80103e:	7e 28                	jle    801068 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801040:	89 44 24 10          	mov    %eax,0x10(%esp)
  801044:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80104b:	00 
  80104c:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  801053:	00 
  801054:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80105b:	00 
  80105c:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  801063:	e8 4c f1 ff ff       	call   8001b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801068:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80106b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801071:	89 ec                	mov    %ebp,%esp
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 38             	sub    $0x38,%esp
  80107b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80107e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801081:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801084:	bb 00 00 00 00       	mov    $0x0,%ebx
  801089:	b8 09 00 00 00       	mov    $0x9,%eax
  80108e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801091:	8b 55 08             	mov    0x8(%ebp),%edx
  801094:	89 df                	mov    %ebx,%edi
  801096:	89 de                	mov    %ebx,%esi
  801098:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80109a:	85 c0                	test   %eax,%eax
  80109c:	7e 28                	jle    8010c6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b9:	00 
  8010ba:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  8010c1:	e8 ee f0 ff ff       	call   8001b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cf:	89 ec                	mov    %ebp,%esp
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010df:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	be 00 00 00 00       	mov    $0x0,%esi
  8010e7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801100:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801103:	89 ec                	mov    %ebp,%esp
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 38             	sub    $0x38,%esp
  80110d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801110:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801113:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801120:	8b 55 08             	mov    0x8(%ebp),%edx
  801123:	89 cb                	mov    %ecx,%ebx
  801125:	89 cf                	mov    %ecx,%edi
  801127:	89 ce                	mov    %ecx,%esi
  801129:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80112b:	85 c0                	test   %eax,%eax
  80112d:	7e 28                	jle    801157 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801133:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80113a:	00 
  80113b:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  801142:	00 
  801143:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  801152:	e8 5d f0 ff ff       	call   8001b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801157:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80115a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80115d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801160:	89 ec                	mov    %ebp,%esp
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	53                   	push   %ebx
  801168:	83 ec 24             	sub    $0x24,%esp
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  80116e:	8b 18                	mov    (%eax),%ebx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  801170:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801174:	74 2d                	je     8011a3 <pgfault+0x3f>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801176:	89 d8                	mov    %ebx,%eax
  801178:	c1 e8 16             	shr    $0x16,%eax
  80117b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801182:	a8 01                	test   $0x1,%al
  801184:	74 1d                	je     8011a3 <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  801186:	89 d8                	mov    %ebx,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
  80118b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801192:	f6 c2 01             	test   $0x1,%dl
  801195:	74 0c                	je     8011a3 <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  801197:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  80119e:	f6 c4 08             	test   $0x8,%ah
  8011a1:	75 1c                	jne    8011bf <pgfault+0x5b>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  8011a3:	c7 44 24 08 8f 1b 80 	movl   $0x801b8f,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8011ba:	e8 f5 ef ff ff       	call   8001b4 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  8011bf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011c6:	00 
  8011c7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011ce:	00 
  8011cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d6:	e8 21 fd ff ff       	call   800efc <sys_page_alloc>
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	79 1c                	jns    8011fb <pgfault+0x97>
		panic("sys_page_alloc");
  8011df:	c7 44 24 08 ac 1b 80 	movl   $0x801bac,0x8(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8011ee:	00 
  8011ef:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8011f6:	e8 b9 ef ff ff       	call   8001b4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  8011fb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  801201:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801208:	00 
  801209:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80120d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801214:	e8 4c fa ff ff       	call   800c65 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801219:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801220:	00 
  801221:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801225:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80122c:	00 
  80122d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801234:	00 
  801235:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123c:	e8 1a fd ff ff       	call   800f5b <sys_page_map>
  801241:	85 c0                	test   %eax,%eax
  801243:	79 1c                	jns    801261 <pgfault+0xfd>
		panic("sys_page_map");
  801245:	c7 44 24 08 bb 1b 80 	movl   $0x801bbb,0x8(%esp)
  80124c:	00 
  80124d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801254:	00 
  801255:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  80125c:	e8 53 ef ff ff       	call   8001b4 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  801261:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801270:	e8 44 fd ff ff       	call   800fb9 <sys_page_unmap>
  801275:	85 c0                	test   %eax,%eax
  801277:	79 1c                	jns    801295 <pgfault+0x131>
		panic("sys_page_unmap");
  801279:	c7 44 24 08 c8 1b 80 	movl   $0x801bc8,0x8(%esp)
  801280:	00 
  801281:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  801290:	e8 1f ef ff ff       	call   8001b4 <_panic>
	return;
}
  801295:	83 c4 24             	add    $0x24,%esp
  801298:	5b                   	pop    %ebx
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    

0080129b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	57                   	push   %edi
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8012a4:	c7 04 24 64 11 80 00 	movl   $0x801164,(%esp)
  8012ab:	e8 a8 02 00 00       	call   801558 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8012b0:	ba 07 00 00 00       	mov    $0x7,%edx
  8012b5:	89 d0                	mov    %edx,%eax
  8012b7:	cd 30                	int    $0x30
  8012b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bc:	89 c7                	mov    %eax,%edi

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	75 1c                	jne    8012de <fork+0x43>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012c2:	e8 d5 fb ff ff       	call   800e9c <sys_getenvid>
  8012c7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012cc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012cf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d4:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  8012d9:	e9 bf 01 00 00       	jmp    80149d <fork+0x202>
	}
	if (envid < 0)
  8012de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e2:	79 23                	jns    801307 <fork+0x6c>
		panic("sys_exofork: %e", envid);
  8012e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012eb:	c7 44 24 08 d7 1b 80 	movl   $0x801bd7,0x8(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  8012fa:	00 
  8012fb:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  801302:	e8 ad ee ff ff       	call   8001b4 <_panic>
	envid = sys_exofork();
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  801307:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80130c:	89 d8                	mov    %ebx,%eax
  80130e:	c1 e8 16             	shr    $0x16,%eax
  801311:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801318:	a8 01                	test   $0x1,%al
  80131a:	0f 84 ea 00 00 00    	je     80140a <fork+0x16f>
  801320:	89 d8                	mov    %ebx,%eax
  801322:	c1 e8 0c             	shr    $0xc,%eax
  801325:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132c:	f6 c2 01             	test   $0x1,%dl
  80132f:	0f 84 d5 00 00 00    	je     80140a <fork+0x16f>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801335:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80133c:	f6 c2 04             	test   $0x4,%dl
  80133f:	0f 84 c5 00 00 00    	je     80140a <fork+0x16f>
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  801345:	89 c6                	mov    %eax,%esi
  801347:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80134a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801351:	f6 c2 02             	test   $0x2,%dl
  801354:	75 10                	jne    801366 <fork+0xcb>
  801356:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135d:	f6 c4 08             	test   $0x8,%ah
  801360:	0f 84 84 00 00 00    	je     8013ea <fork+0x14f>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801366:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80136d:	00 
  80136e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801372:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80137a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801381:	e8 d5 fb ff ff       	call   800f5b <sys_page_map>
  801386:	85 c0                	test   %eax,%eax
  801388:	79 1c                	jns    8013a6 <fork+0x10b>
			panic("2");
  80138a:	c7 44 24 08 e7 1b 80 	movl   $0x801be7,0x8(%esp)
  801391:	00 
  801392:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801399:	00 
  80139a:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8013a1:	e8 0e ee ff ff       	call   8001b4 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8013a6:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013ad:	00 
  8013ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013b9:	00 
  8013ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c5:	e8 91 fb ff ff       	call   800f5b <sys_page_map>
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	79 3c                	jns    80140a <fork+0x16f>
			panic("3");
  8013ce:	c7 44 24 08 e9 1b 80 	movl   $0x801be9,0x8(%esp)
  8013d5:	00 
  8013d6:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8013dd:	00 
  8013de:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8013e5:	e8 ca ed ff ff       	call   8001b4 <_panic>
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8013ea:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8013f1:	00 
  8013f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013f6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801405:	e8 51 fb ff ff       	call   800f5b <sys_page_map>
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80140a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801410:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801416:	0f 85 f0 fe ff ff    	jne    80130c <fork+0x71>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80141c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801423:	00 
  801424:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80142b:	ee 
  80142c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80142f:	89 04 24             	mov    %eax,(%esp)
  801432:	e8 c5 fa ff ff       	call   800efc <sys_page_alloc>
  801437:	85 c0                	test   %eax,%eax
  801439:	79 1c                	jns    801457 <fork+0x1bc>
		panic("1");
  80143b:	c7 44 24 08 eb 1b 80 	movl   $0x801beb,0x8(%esp)
  801442:	00 
  801443:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  80144a:	00 
  80144b:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  801452:	e8 5d ed ff ff       	call   8001b4 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801457:	c7 44 24 04 e4 15 80 	movl   $0x8015e4,0x4(%esp)
  80145e:	00 
  80145f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 0b fc ff ff       	call   801075 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80146a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801471:	00 
  801472:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801475:	89 04 24             	mov    %eax,(%esp)
  801478:	e8 9a fb ff ff       	call   801017 <sys_env_set_status>
  80147d:	85 c0                	test   %eax,%eax
  80147f:	79 1c                	jns    80149d <fork+0x202>
		panic("sys_env_set_status");
  801481:	c7 44 24 08 ed 1b 80 	movl   $0x801bed,0x8(%esp)
  801488:	00 
  801489:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801490:	00 
  801491:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  801498:	e8 17 ed ff ff       	call   8001b4 <_panic>

	return envid;
	panic("fork not implemented");
}
  80149d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a0:	83 c4 3c             	add    $0x3c,%esp
  8014a3:	5b                   	pop    %ebx
  8014a4:	5e                   	pop    %esi
  8014a5:	5f                   	pop    %edi
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <sfork>:

// Challenge!
int
sfork(void)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014ae:	c7 44 24 08 00 1c 80 	movl   $0x801c00,0x8(%esp)
  8014b5:	00 
  8014b6:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8014bd:	00 
  8014be:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8014c5:	e8 ea ec ff ff       	call   8001b4 <_panic>
	...

008014cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  8014d2:	c7 44 24 08 16 1c 80 	movl   $0x801c16,0x8(%esp)
  8014d9:	00 
  8014da:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8014e1:	00 
  8014e2:	c7 04 24 2f 1c 80 00 	movl   $0x801c2f,(%esp)
  8014e9:	e8 c6 ec ff ff       	call   8001b4 <_panic>

008014ee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  8014f4:	c7 44 24 08 39 1c 80 	movl   $0x801c39,0x8(%esp)
  8014fb:	00 
  8014fc:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801503:	00 
  801504:	c7 04 24 2f 1c 80 00 	movl   $0x801c2f,(%esp)
  80150b:	e8 a4 ec ff ff       	call   8001b4 <_panic>

00801510 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801516:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80151b:	39 c8                	cmp    %ecx,%eax
  80151d:	74 17                	je     801536 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80151f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801524:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801527:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80152d:	8b 52 50             	mov    0x50(%edx),%edx
  801530:	39 ca                	cmp    %ecx,%edx
  801532:	75 14                	jne    801548 <ipc_find_env+0x38>
  801534:	eb 05                	jmp    80153b <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80153b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80153e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801543:	8b 40 40             	mov    0x40(%eax),%eax
  801546:	eb 0e                	jmp    801556 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801548:	83 c0 01             	add    $0x1,%eax
  80154b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801550:	75 d2                	jne    801524 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801552:	66 b8 00 00          	mov    $0x0,%ax
}
  801556:	5d                   	pop    %ebp
  801557:	c3                   	ret    

00801558 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80155e:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801565:	75 3c                	jne    8015a3 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801567:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80156e:	00 
  80156f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801576:	ee 
  801577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157e:	e8 79 f9 ff ff       	call   800efc <sys_page_alloc>
  801583:	85 c0                	test   %eax,%eax
  801585:	79 1c                	jns    8015a3 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801587:	c7 44 24 08 54 1c 80 	movl   $0x801c54,0x8(%esp)
  80158e:	00 
  80158f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801596:	00 
  801597:	c7 04 24 b8 1c 80 00 	movl   $0x801cb8,(%esp)
  80159e:	e8 11 ec ff ff       	call   8001b4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8015ab:	c7 44 24 04 e4 15 80 	movl   $0x8015e4,0x4(%esp)
  8015b2:	00 
  8015b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ba:	e8 b6 fa ff ff       	call   801075 <sys_env_set_pgfault_upcall>
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	79 1c                	jns    8015df <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8015c3:	c7 44 24 08 80 1c 80 	movl   $0x801c80,0x8(%esp)
  8015ca:	00 
  8015cb:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8015d2:	00 
  8015d3:	c7 04 24 b8 1c 80 00 	movl   $0x801cb8,(%esp)
  8015da:	e8 d5 eb ff ff       	call   8001b4 <_panic>
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    
  8015e1:	00 00                	add    %al,(%eax)
	...

008015e4 <_pgfault_upcall>:
  8015e4:	54                   	push   %esp
  8015e5:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8015ea:	ff d0                	call   *%eax
  8015ec:	83 c4 04             	add    $0x4,%esp
  8015ef:	8b 54 24 28          	mov    0x28(%esp),%edx
  8015f3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  8015f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8015fc:	89 10                	mov    %edx,(%eax)
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	61                   	popa   
  801602:	83 c4 04             	add    $0x4,%esp
  801605:	9d                   	popf   
  801606:	5c                   	pop    %esp
  801607:	c3                   	ret    
	...

00801610 <__udivdi3>:
  801610:	83 ec 1c             	sub    $0x1c,%esp
  801613:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801617:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80161b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80161f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801623:	89 74 24 10          	mov    %esi,0x10(%esp)
  801627:	8b 74 24 24          	mov    0x24(%esp),%esi
  80162b:	85 ff                	test   %edi,%edi
  80162d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801631:	89 44 24 08          	mov    %eax,0x8(%esp)
  801635:	89 cd                	mov    %ecx,%ebp
  801637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163b:	75 33                	jne    801670 <__udivdi3+0x60>
  80163d:	39 f1                	cmp    %esi,%ecx
  80163f:	77 57                	ja     801698 <__udivdi3+0x88>
  801641:	85 c9                	test   %ecx,%ecx
  801643:	75 0b                	jne    801650 <__udivdi3+0x40>
  801645:	b8 01 00 00 00       	mov    $0x1,%eax
  80164a:	31 d2                	xor    %edx,%edx
  80164c:	f7 f1                	div    %ecx
  80164e:	89 c1                	mov    %eax,%ecx
  801650:	89 f0                	mov    %esi,%eax
  801652:	31 d2                	xor    %edx,%edx
  801654:	f7 f1                	div    %ecx
  801656:	89 c6                	mov    %eax,%esi
  801658:	8b 44 24 04          	mov    0x4(%esp),%eax
  80165c:	f7 f1                	div    %ecx
  80165e:	89 f2                	mov    %esi,%edx
  801660:	8b 74 24 10          	mov    0x10(%esp),%esi
  801664:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801668:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80166c:	83 c4 1c             	add    $0x1c,%esp
  80166f:	c3                   	ret    
  801670:	31 d2                	xor    %edx,%edx
  801672:	31 c0                	xor    %eax,%eax
  801674:	39 f7                	cmp    %esi,%edi
  801676:	77 e8                	ja     801660 <__udivdi3+0x50>
  801678:	0f bd cf             	bsr    %edi,%ecx
  80167b:	83 f1 1f             	xor    $0x1f,%ecx
  80167e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801682:	75 2c                	jne    8016b0 <__udivdi3+0xa0>
  801684:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801688:	76 04                	jbe    80168e <__udivdi3+0x7e>
  80168a:	39 f7                	cmp    %esi,%edi
  80168c:	73 d2                	jae    801660 <__udivdi3+0x50>
  80168e:	31 d2                	xor    %edx,%edx
  801690:	b8 01 00 00 00       	mov    $0x1,%eax
  801695:	eb c9                	jmp    801660 <__udivdi3+0x50>
  801697:	90                   	nop
  801698:	89 f2                	mov    %esi,%edx
  80169a:	f7 f1                	div    %ecx
  80169c:	31 d2                	xor    %edx,%edx
  80169e:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016a2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016a6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016aa:	83 c4 1c             	add    $0x1c,%esp
  8016ad:	c3                   	ret    
  8016ae:	66 90                	xchg   %ax,%ax
  8016b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016b5:	b8 20 00 00 00       	mov    $0x20,%eax
  8016ba:	89 ea                	mov    %ebp,%edx
  8016bc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8016c0:	d3 e7                	shl    %cl,%edi
  8016c2:	89 c1                	mov    %eax,%ecx
  8016c4:	d3 ea                	shr    %cl,%edx
  8016c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016cb:	09 fa                	or     %edi,%edx
  8016cd:	89 f7                	mov    %esi,%edi
  8016cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016d3:	89 f2                	mov    %esi,%edx
  8016d5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8016d9:	d3 e5                	shl    %cl,%ebp
  8016db:	89 c1                	mov    %eax,%ecx
  8016dd:	d3 ef                	shr    %cl,%edi
  8016df:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016e4:	d3 e2                	shl    %cl,%edx
  8016e6:	89 c1                	mov    %eax,%ecx
  8016e8:	d3 ee                	shr    %cl,%esi
  8016ea:	09 d6                	or     %edx,%esi
  8016ec:	89 fa                	mov    %edi,%edx
  8016ee:	89 f0                	mov    %esi,%eax
  8016f0:	f7 74 24 0c          	divl   0xc(%esp)
  8016f4:	89 d7                	mov    %edx,%edi
  8016f6:	89 c6                	mov    %eax,%esi
  8016f8:	f7 e5                	mul    %ebp
  8016fa:	39 d7                	cmp    %edx,%edi
  8016fc:	72 22                	jb     801720 <__udivdi3+0x110>
  8016fe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801702:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801707:	d3 e5                	shl    %cl,%ebp
  801709:	39 c5                	cmp    %eax,%ebp
  80170b:	73 04                	jae    801711 <__udivdi3+0x101>
  80170d:	39 d7                	cmp    %edx,%edi
  80170f:	74 0f                	je     801720 <__udivdi3+0x110>
  801711:	89 f0                	mov    %esi,%eax
  801713:	31 d2                	xor    %edx,%edx
  801715:	e9 46 ff ff ff       	jmp    801660 <__udivdi3+0x50>
  80171a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801720:	8d 46 ff             	lea    -0x1(%esi),%eax
  801723:	31 d2                	xor    %edx,%edx
  801725:	8b 74 24 10          	mov    0x10(%esp),%esi
  801729:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80172d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801731:	83 c4 1c             	add    $0x1c,%esp
  801734:	c3                   	ret    
	...

00801740 <__umoddi3>:
  801740:	83 ec 1c             	sub    $0x1c,%esp
  801743:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801747:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80174b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80174f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801753:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801757:	8b 74 24 24          	mov    0x24(%esp),%esi
  80175b:	85 ed                	test   %ebp,%ebp
  80175d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801761:	89 44 24 08          	mov    %eax,0x8(%esp)
  801765:	89 cf                	mov    %ecx,%edi
  801767:	89 04 24             	mov    %eax,(%esp)
  80176a:	89 f2                	mov    %esi,%edx
  80176c:	75 1a                	jne    801788 <__umoddi3+0x48>
  80176e:	39 f1                	cmp    %esi,%ecx
  801770:	76 4e                	jbe    8017c0 <__umoddi3+0x80>
  801772:	f7 f1                	div    %ecx
  801774:	89 d0                	mov    %edx,%eax
  801776:	31 d2                	xor    %edx,%edx
  801778:	8b 74 24 10          	mov    0x10(%esp),%esi
  80177c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801780:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801784:	83 c4 1c             	add    $0x1c,%esp
  801787:	c3                   	ret    
  801788:	39 f5                	cmp    %esi,%ebp
  80178a:	77 54                	ja     8017e0 <__umoddi3+0xa0>
  80178c:	0f bd c5             	bsr    %ebp,%eax
  80178f:	83 f0 1f             	xor    $0x1f,%eax
  801792:	89 44 24 04          	mov    %eax,0x4(%esp)
  801796:	75 60                	jne    8017f8 <__umoddi3+0xb8>
  801798:	3b 0c 24             	cmp    (%esp),%ecx
  80179b:	0f 87 07 01 00 00    	ja     8018a8 <__umoddi3+0x168>
  8017a1:	89 f2                	mov    %esi,%edx
  8017a3:	8b 34 24             	mov    (%esp),%esi
  8017a6:	29 ce                	sub    %ecx,%esi
  8017a8:	19 ea                	sbb    %ebp,%edx
  8017aa:	89 34 24             	mov    %esi,(%esp)
  8017ad:	8b 04 24             	mov    (%esp),%eax
  8017b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8017bc:	83 c4 1c             	add    $0x1c,%esp
  8017bf:	c3                   	ret    
  8017c0:	85 c9                	test   %ecx,%ecx
  8017c2:	75 0b                	jne    8017cf <__umoddi3+0x8f>
  8017c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c9:	31 d2                	xor    %edx,%edx
  8017cb:	f7 f1                	div    %ecx
  8017cd:	89 c1                	mov    %eax,%ecx
  8017cf:	89 f0                	mov    %esi,%eax
  8017d1:	31 d2                	xor    %edx,%edx
  8017d3:	f7 f1                	div    %ecx
  8017d5:	8b 04 24             	mov    (%esp),%eax
  8017d8:	f7 f1                	div    %ecx
  8017da:	eb 98                	jmp    801774 <__umoddi3+0x34>
  8017dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017e0:	89 f2                	mov    %esi,%edx
  8017e2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017e6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017ea:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8017ee:	83 c4 1c             	add    $0x1c,%esp
  8017f1:	c3                   	ret    
  8017f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017f8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8017fd:	89 e8                	mov    %ebp,%eax
  8017ff:	bd 20 00 00 00       	mov    $0x20,%ebp
  801804:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801808:	89 fa                	mov    %edi,%edx
  80180a:	d3 e0                	shl    %cl,%eax
  80180c:	89 e9                	mov    %ebp,%ecx
  80180e:	d3 ea                	shr    %cl,%edx
  801810:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801815:	09 c2                	or     %eax,%edx
  801817:	8b 44 24 08          	mov    0x8(%esp),%eax
  80181b:	89 14 24             	mov    %edx,(%esp)
  80181e:	89 f2                	mov    %esi,%edx
  801820:	d3 e7                	shl    %cl,%edi
  801822:	89 e9                	mov    %ebp,%ecx
  801824:	d3 ea                	shr    %cl,%edx
  801826:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80182b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80182f:	d3 e6                	shl    %cl,%esi
  801831:	89 e9                	mov    %ebp,%ecx
  801833:	d3 e8                	shr    %cl,%eax
  801835:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80183a:	09 f0                	or     %esi,%eax
  80183c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801840:	f7 34 24             	divl   (%esp)
  801843:	d3 e6                	shl    %cl,%esi
  801845:	89 74 24 08          	mov    %esi,0x8(%esp)
  801849:	89 d6                	mov    %edx,%esi
  80184b:	f7 e7                	mul    %edi
  80184d:	39 d6                	cmp    %edx,%esi
  80184f:	89 c1                	mov    %eax,%ecx
  801851:	89 d7                	mov    %edx,%edi
  801853:	72 3f                	jb     801894 <__umoddi3+0x154>
  801855:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801859:	72 35                	jb     801890 <__umoddi3+0x150>
  80185b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80185f:	29 c8                	sub    %ecx,%eax
  801861:	19 fe                	sbb    %edi,%esi
  801863:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801868:	89 f2                	mov    %esi,%edx
  80186a:	d3 e8                	shr    %cl,%eax
  80186c:	89 e9                	mov    %ebp,%ecx
  80186e:	d3 e2                	shl    %cl,%edx
  801870:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801875:	09 d0                	or     %edx,%eax
  801877:	89 f2                	mov    %esi,%edx
  801879:	d3 ea                	shr    %cl,%edx
  80187b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80187f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801883:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801887:	83 c4 1c             	add    $0x1c,%esp
  80188a:	c3                   	ret    
  80188b:	90                   	nop
  80188c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801890:	39 d6                	cmp    %edx,%esi
  801892:	75 c7                	jne    80185b <__umoddi3+0x11b>
  801894:	89 d7                	mov    %edx,%edi
  801896:	89 c1                	mov    %eax,%ecx
  801898:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80189c:	1b 3c 24             	sbb    (%esp),%edi
  80189f:	eb ba                	jmp    80185b <__umoddi3+0x11b>
  8018a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8018a8:	39 f5                	cmp    %esi,%ebp
  8018aa:	0f 82 f1 fe ff ff    	jb     8017a1 <__umoddi3+0x61>
  8018b0:	e9 f8 fe ff ff       	jmp    8017ad <__umoddi3+0x6d>
