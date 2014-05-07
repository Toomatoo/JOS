
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 60 24 80 00 	movl   $0x802460,(%esp)
  80004b:	e8 fb 01 00 00       	call   80024b <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 2d 0e 00 00       	call   800e9c <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 80 24 80 	movl   $0x802480,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 6a 24 80 00 	movl   $0x80246a,(%esp)
  800092:	e8 b9 00 00 00       	call   800150 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ac 24 80 	movl   $0x8024ac,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 6c 08 00 00       	call   80091f <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 c9 10 00 00       	call   801194 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 a1 0c 00 00       	call   800d80 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f6:	e8 41 0d 00 00       	call   800e3c <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	c1 e0 07             	shl    $0x7,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800118:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011c:	89 34 24             	mov    %esi,(%esp)
  80011f:	e8 95 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80013a:	e8 2f 13 00 00       	call   80146e <close_all>
	sys_env_destroy(0);
  80013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800146:	e8 94 0c 00 00       	call   800ddf <sys_env_destroy>
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800161:	e8 d6 0c 00 00       	call   800e3c <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  800183:	e8 c3 00 00 00       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 53 00 00 00       	call   8001ea <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 97 29 80 00 	movl   $0x802997,(%esp)
  80019e:	e8 a8 00 00 00       	call   80024b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x53>
	...

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 03                	mov    (%ebx),%eax
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bb:	83 c0 01             	add    $0x1,%eax
  8001be:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c5:	75 19                	jne    8001e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ce:	00 
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 a6 0b 00 00       	call   800d80 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800226:	e8 97 01 00 00       	call   8003c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	e8 3d 0b 00 00       	call   800d80 <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800251:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 87 ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    
  800265:	00 00                	add    %al,(%eax)
	...

00800268 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800274:	89 d7                	mov    %edx,%edi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800282:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800285:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800288:	b8 00 00 00 00       	mov    $0x0,%eax
  80028d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800290:	72 11                	jb     8002a3 <printnum+0x3b>
  800292:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800295:	39 45 10             	cmp    %eax,0x10(%ebp)
  800298:	76 09                	jbe    8002a3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f 51                	jg     8002f2 <printnum+0x8a>
  8002a1:	eb 5e                	jmp    800301 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a7:	83 eb 01             	sub    $0x1,%ebx
  8002aa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c4:	00 
  8002c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d2:	e8 c9 1e 00 00       	call   8021a0 <__udivdi3>
  8002d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e6:	89 fa                	mov    %edi,%edx
  8002e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002eb:	e8 78 ff ff ff       	call   800268 <printnum>
  8002f0:	eb 0f                	jmp    800301 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f6:	89 34 24             	mov    %esi,(%esp)
  8002f9:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fc:	83 eb 01             	sub    $0x1,%ebx
  8002ff:	75 f1                	jne    8002f2 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800317:	00 
  800318:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	e8 a6 1f 00 00       	call   8022d0 <__umoddi3>
  80032a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032e:	0f be 80 fb 24 80 00 	movsbl 0x8024fb(%eax),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033b:	83 c4 3c             	add    $0x3c,%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800346:	83 fa 01             	cmp    $0x1,%edx
  800349:	7e 0e                	jle    800359 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034b:	8b 10                	mov    (%eax),%edx
  80034d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800350:	89 08                	mov    %ecx,(%eax)
  800352:	8b 02                	mov    (%edx),%eax
  800354:	8b 52 04             	mov    0x4(%edx),%edx
  800357:	eb 22                	jmp    80037b <getuint+0x38>
	else if (lflag)
  800359:	85 d2                	test   %edx,%edx
  80035b:	74 10                	je     80036d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 02                	mov    (%edx),%eax
  800366:	ba 00 00 00 00       	mov    $0x0,%edx
  80036b:	eb 0e                	jmp    80037b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 02                	mov    (%edx),%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800383:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800387:	8b 10                	mov    (%eax),%edx
  800389:	3b 50 04             	cmp    0x4(%eax),%edx
  80038c:	73 0a                	jae    800398 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800391:	88 0a                	mov    %cl,(%edx)
  800393:	83 c2 01             	add    $0x1,%edx
  800396:	89 10                	mov    %edx,(%eax)
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 02 00 00 00       	call   8003c2 <vprintfmt>
	va_end(ap);
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	57                   	push   %edi
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 5c             	sub    $0x5c,%esp
  8003cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d1:	eb 12                	jmp    8003e5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	0f 84 e4 04 00 00    	je     8008bf <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	0f b6 06             	movzbl (%esi),%eax
  8003e8:	83 c6 01             	add    $0x1,%esi
  8003eb:	83 f8 25             	cmp    $0x25,%eax
  8003ee:	75 e3                	jne    8003d3 <vprintfmt+0x11>
  8003f0:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003f4:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003fb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800400:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800407:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80040f:	eb 2b                	jmp    80043c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800414:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800418:	eb 22                	jmp    80043c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800421:	eb 19                	jmp    80043c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800426:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80042d:	eb 0d                	jmp    80043c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800432:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800435:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	0f b6 06             	movzbl (%esi),%eax
  80043f:	0f b6 d0             	movzbl %al,%edx
  800442:	8d 7e 01             	lea    0x1(%esi),%edi
  800445:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800448:	83 e8 23             	sub    $0x23,%eax
  80044b:	3c 55                	cmp    $0x55,%al
  80044d:	0f 87 46 04 00 00    	ja     800899 <vprintfmt+0x4d7>
  800453:	0f b6 c0             	movzbl %al,%eax
  800456:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045d:	83 ea 30             	sub    $0x30,%edx
  800460:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800463:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800467:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80046d:	83 fa 09             	cmp    $0x9,%edx
  800470:	77 4a                	ja     8004bc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800475:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800478:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80047b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80047f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800482:	8d 50 d0             	lea    -0x30(%eax),%edx
  800485:	83 fa 09             	cmp    $0x9,%edx
  800488:	76 eb                	jbe    800475 <vprintfmt+0xb3>
  80048a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80048d:	eb 2d                	jmp    8004bc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a0:	eb 1a                	jmp    8004bc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004a5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004a9:	79 91                	jns    80043c <vprintfmt+0x7a>
  8004ab:	e9 73 ff ff ff       	jmp    800423 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004ba:	eb 80                	jmp    80043c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004bc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004c0:	0f 89 76 ff ff ff    	jns    80043c <vprintfmt+0x7a>
  8004c6:	e9 64 ff ff ff       	jmp    80042f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004cb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004d1:	e9 66 ff ff ff       	jmp    80043c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 50 04             	lea    0x4(%eax),%edx
  8004dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	89 04 24             	mov    %eax,(%esp)
  8004e8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ee:	e9 f2 fe ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004f3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004f7:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004fa:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8004fe:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800501:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800505:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800508:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80050b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80050f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800512:	80 f9 09             	cmp    $0x9,%cl
  800515:	77 1d                	ja     800534 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800517:	0f be c0             	movsbl %al,%eax
  80051a:	6b c0 64             	imul   $0x64,%eax,%eax
  80051d:	0f be d2             	movsbl %dl,%edx
  800520:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800523:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80052a:	a3 04 30 80 00       	mov    %eax,0x803004
  80052f:	e9 b1 fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800534:	c7 44 24 04 13 25 80 	movl   $0x802513,0x4(%esp)
  80053b:	00 
  80053c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	e8 14 05 00 00       	call   800a5b <strcmp>
  800547:	85 c0                	test   %eax,%eax
  800549:	75 0f                	jne    80055a <vprintfmt+0x198>
  80054b:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800552:	00 00 00 
  800555:	e9 8b fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80055a:	c7 44 24 04 17 25 80 	movl   $0x802517,0x4(%esp)
  800561:	00 
  800562:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800565:	89 14 24             	mov    %edx,(%esp)
  800568:	e8 ee 04 00 00       	call   800a5b <strcmp>
  80056d:	85 c0                	test   %eax,%eax
  80056f:	75 0f                	jne    800580 <vprintfmt+0x1be>
  800571:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800578:	00 00 00 
  80057b:	e9 65 fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800580:	c7 44 24 04 1b 25 80 	movl   $0x80251b,0x4(%esp)
  800587:	00 
  800588:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80058b:	89 0c 24             	mov    %ecx,(%esp)
  80058e:	e8 c8 04 00 00       	call   800a5b <strcmp>
  800593:	85 c0                	test   %eax,%eax
  800595:	75 0f                	jne    8005a6 <vprintfmt+0x1e4>
  800597:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  80059e:	00 00 00 
  8005a1:	e9 3f fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005a6:	c7 44 24 04 1f 25 80 	movl   $0x80251f,0x4(%esp)
  8005ad:	00 
  8005ae:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005b1:	89 3c 24             	mov    %edi,(%esp)
  8005b4:	e8 a2 04 00 00       	call   800a5b <strcmp>
  8005b9:	85 c0                	test   %eax,%eax
  8005bb:	75 0f                	jne    8005cc <vprintfmt+0x20a>
  8005bd:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  8005c4:	00 00 00 
  8005c7:	e9 19 fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005cc:	c7 44 24 04 23 25 80 	movl   $0x802523,0x4(%esp)
  8005d3:	00 
  8005d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	e8 7c 04 00 00       	call   800a5b <strcmp>
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	75 0f                	jne    8005f2 <vprintfmt+0x230>
  8005e3:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  8005ea:	00 00 00 
  8005ed:	e9 f3 fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005f2:	c7 44 24 04 27 25 80 	movl   $0x802527,0x4(%esp)
  8005f9:	00 
  8005fa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005fd:	89 14 24             	mov    %edx,(%esp)
  800600:	e8 56 04 00 00       	call   800a5b <strcmp>
  800605:	83 f8 01             	cmp    $0x1,%eax
  800608:	19 c0                	sbb    %eax,%eax
  80060a:	f7 d0                	not    %eax
  80060c:	83 c0 08             	add    $0x8,%eax
  80060f:	a3 04 30 80 00       	mov    %eax,0x803004
  800614:	e9 cc fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 c2                	mov    %eax,%edx
  800626:	c1 fa 1f             	sar    $0x1f,%edx
  800629:	31 d0                	xor    %edx,%eax
  80062b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062d:	83 f8 0f             	cmp    $0xf,%eax
  800630:	7f 0b                	jg     80063d <vprintfmt+0x27b>
  800632:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800639:	85 d2                	test   %edx,%edx
  80063b:	75 23                	jne    800660 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80063d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800641:	c7 44 24 08 2b 25 80 	movl   $0x80252b,0x8(%esp)
  800648:	00 
  800649:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800650:	89 3c 24             	mov    %edi,(%esp)
  800653:	e8 42 fd ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800658:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065b:	e9 85 fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800660:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800664:	c7 44 24 08 65 29 80 	movl   $0x802965,0x8(%esp)
  80066b:	00 
  80066c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800670:	8b 7d 08             	mov    0x8(%ebp),%edi
  800673:	89 3c 24             	mov    %edi,(%esp)
  800676:	e8 1f fd ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80067e:	e9 62 fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
  800683:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800686:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800689:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800697:	85 f6                	test   %esi,%esi
  800699:	b8 0c 25 80 00       	mov    $0x80250c,%eax
  80069e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006a1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006a5:	7e 06                	jle    8006ad <vprintfmt+0x2eb>
  8006a7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006ab:	75 13                	jne    8006c0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ad:	0f be 06             	movsbl (%esi),%eax
  8006b0:	83 c6 01             	add    $0x1,%esi
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	0f 85 94 00 00 00    	jne    80074f <vprintfmt+0x38d>
  8006bb:	e9 81 00 00 00       	jmp    800741 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c4:	89 34 24             	mov    %esi,(%esp)
  8006c7:	e8 9f 02 00 00       	call   80096b <strnlen>
  8006cc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006cf:	29 c2                	sub    %eax,%edx
  8006d1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e d5                	jle    8006ad <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006d8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006dc:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006df:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006e2:	89 d6                	mov    %edx,%esi
  8006e4:	89 cf                	mov    %ecx,%edi
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	89 3c 24             	mov    %edi,(%esp)
  8006ed:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f0:	83 ee 01             	sub    $0x1,%esi
  8006f3:	75 f1                	jne    8006e6 <vprintfmt+0x324>
  8006f5:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006f8:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006fb:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8006fe:	eb ad                	jmp    8006ad <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800700:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800704:	74 1b                	je     800721 <vprintfmt+0x35f>
  800706:	8d 50 e0             	lea    -0x20(%eax),%edx
  800709:	83 fa 5e             	cmp    $0x5e,%edx
  80070c:	76 13                	jbe    800721 <vprintfmt+0x35f>
					putch('?', putdat);
  80070e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800711:	89 44 24 04          	mov    %eax,0x4(%esp)
  800715:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80071c:	ff 55 08             	call   *0x8(%ebp)
  80071f:	eb 0d                	jmp    80072e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800721:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800724:	89 54 24 04          	mov    %edx,0x4(%esp)
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072e:	83 eb 01             	sub    $0x1,%ebx
  800731:	0f be 06             	movsbl (%esi),%eax
  800734:	83 c6 01             	add    $0x1,%esi
  800737:	85 c0                	test   %eax,%eax
  800739:	75 1a                	jne    800755 <vprintfmt+0x393>
  80073b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80073e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800748:	7f 1c                	jg     800766 <vprintfmt+0x3a4>
  80074a:	e9 96 fc ff ff       	jmp    8003e5 <vprintfmt+0x23>
  80074f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800752:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800755:	85 ff                	test   %edi,%edi
  800757:	78 a7                	js     800700 <vprintfmt+0x33e>
  800759:	83 ef 01             	sub    $0x1,%edi
  80075c:	79 a2                	jns    800700 <vprintfmt+0x33e>
  80075e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800761:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800764:	eb db                	jmp    800741 <vprintfmt+0x37f>
  800766:	8b 7d 08             	mov    0x8(%ebp),%edi
  800769:	89 de                	mov    %ebx,%esi
  80076b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800772:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800779:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077b:	83 eb 01             	sub    $0x1,%ebx
  80077e:	75 ee                	jne    80076e <vprintfmt+0x3ac>
  800780:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800785:	e9 5b fc ff ff       	jmp    8003e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80078a:	83 f9 01             	cmp    $0x1,%ecx
  80078d:	7e 10                	jle    80079f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 08             	lea    0x8(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 30                	mov    (%eax),%esi
  80079a:	8b 78 04             	mov    0x4(%eax),%edi
  80079d:	eb 26                	jmp    8007c5 <vprintfmt+0x403>
	else if (lflag)
  80079f:	85 c9                	test   %ecx,%ecx
  8007a1:	74 12                	je     8007b5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 04             	lea    0x4(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ac:	8b 30                	mov    (%eax),%esi
  8007ae:	89 f7                	mov    %esi,%edi
  8007b0:	c1 ff 1f             	sar    $0x1f,%edi
  8007b3:	eb 10                	jmp    8007c5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 50 04             	lea    0x4(%eax),%edx
  8007bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007be:	8b 30                	mov    (%eax),%esi
  8007c0:	89 f7                	mov    %esi,%edi
  8007c2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007c5:	85 ff                	test   %edi,%edi
  8007c7:	78 0e                	js     8007d7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c9:	89 f0                	mov    %esi,%eax
  8007cb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007cd:	be 0a 00 00 00       	mov    $0xa,%esi
  8007d2:	e9 84 00 00 00       	jmp    80085b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007db:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007e2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	89 fa                	mov    %edi,%edx
  8007e9:	f7 d8                	neg    %eax
  8007eb:	83 d2 00             	adc    $0x0,%edx
  8007ee:	f7 da                	neg    %edx
			}
			base = 10;
  8007f0:	be 0a 00 00 00       	mov    $0xa,%esi
  8007f5:	eb 64                	jmp    80085b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f7:	89 ca                	mov    %ecx,%edx
  8007f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fc:	e8 42 fb ff ff       	call   800343 <getuint>
			base = 10;
  800801:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800806:	eb 53                	jmp    80085b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800808:	89 ca                	mov    %ecx,%edx
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
  80080d:	e8 31 fb ff ff       	call   800343 <getuint>
    			base = 8;
  800812:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800817:	eb 42                	jmp    80085b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800819:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800824:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800827:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800832:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8d 50 04             	lea    0x4(%eax),%edx
  80083b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80083e:	8b 00                	mov    (%eax),%eax
  800840:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800845:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80084a:	eb 0f                	jmp    80085b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80084c:	89 ca                	mov    %ecx,%edx
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
  800851:	e8 ed fa ff ff       	call   800343 <getuint>
			base = 16;
  800856:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80085b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80085f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800863:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800866:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80086a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80086e:	89 04 24             	mov    %eax,(%esp)
  800871:	89 54 24 04          	mov    %edx,0x4(%esp)
  800875:	89 da                	mov    %ebx,%edx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	e8 e9 f9 ff ff       	call   800268 <printnum>
			break;
  80087f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800882:	e9 5e fb ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800887:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088b:	89 14 24             	mov    %edx,(%esp)
  80088e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800891:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800894:	e9 4c fb ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800899:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008a4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008ab:	0f 84 34 fb ff ff    	je     8003e5 <vprintfmt+0x23>
  8008b1:	83 ee 01             	sub    $0x1,%esi
  8008b4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008b8:	75 f7                	jne    8008b1 <vprintfmt+0x4ef>
  8008ba:	e9 26 fb ff ff       	jmp    8003e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008bf:	83 c4 5c             	add    $0x5c,%esp
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5f                   	pop    %edi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 28             	sub    $0x28,%esp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	74 30                	je     800918 <vsnprintf+0x51>
  8008e8:	85 d2                	test   %edx,%edx
  8008ea:	7e 2c                	jle    800918 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	c7 04 24 7d 03 80 00 	movl   $0x80037d,(%esp)
  800908:	e8 b5 fa ff ff       	call   8003c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800910:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800916:	eb 05                	jmp    80091d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800918:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800925:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800928:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092c:	8b 45 10             	mov    0x10(%ebp),%eax
  80092f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	89 04 24             	mov    %eax,(%esp)
  800940:	e8 82 ff ff ff       	call   8008c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    
	...

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	80 3a 00             	cmpb   $0x0,(%edx)
  80095e:	74 09                	je     800969 <strlen+0x19>
		n++;
  800960:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800963:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800967:	75 f7                	jne    800960 <strlen+0x10>
		n++;
	return n;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	85 c9                	test   %ecx,%ecx
  80097c:	74 1a                	je     800998 <strnlen+0x2d>
  80097e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800981:	74 15                	je     800998 <strnlen+0x2d>
  800983:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800988:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098a:	39 ca                	cmp    %ecx,%edx
  80098c:	74 0a                	je     800998 <strnlen+0x2d>
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800996:	75 f0                	jne    800988 <strnlen+0x1d>
		n++;
	return n;
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009b1:	83 c2 01             	add    $0x1,%edx
  8009b4:	84 c9                	test   %cl,%cl
  8009b6:	75 f2                	jne    8009aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c5:	89 1c 24             	mov    %ebx,(%esp)
  8009c8:	e8 83 ff ff ff       	call   800950 <strlen>
	strcpy(dst + len, src);
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d4:	01 d8                	add    %ebx,%eax
  8009d6:	89 04 24             	mov    %eax,(%esp)
  8009d9:	e8 bd ff ff ff       	call   80099b <strcpy>
	return dst;
}
  8009de:	89 d8                	mov    %ebx,%eax
  8009e0:	83 c4 08             	add    $0x8,%esp
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f4:	85 f6                	test   %esi,%esi
  8009f6:	74 18                	je     800a10 <strncpy+0x2a>
  8009f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a03:	80 3a 01             	cmpb   $0x1,(%edx)
  800a06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	39 f1                	cmp    %esi,%ecx
  800a0e:	75 ed                	jne    8009fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a20:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a23:	89 f8                	mov    %edi,%eax
  800a25:	85 f6                	test   %esi,%esi
  800a27:	74 2b                	je     800a54 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a29:	83 fe 01             	cmp    $0x1,%esi
  800a2c:	74 23                	je     800a51 <strlcpy+0x3d>
  800a2e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a31:	84 c9                	test   %cl,%cl
  800a33:	74 1c                	je     800a51 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a35:	83 ee 02             	sub    $0x2,%esi
  800a38:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3d:	88 08                	mov    %cl,(%eax)
  800a3f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a42:	39 f2                	cmp    %esi,%edx
  800a44:	74 0b                	je     800a51 <strlcpy+0x3d>
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a4d:	84 c9                	test   %cl,%cl
  800a4f:	75 ec                	jne    800a3d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a54:	29 f8                	sub    %edi,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	84 c0                	test   %al,%al
  800a69:	74 16                	je     800a81 <strcmp+0x26>
  800a6b:	3a 02                	cmp    (%edx),%al
  800a6d:	75 12                	jne    800a81 <strcmp+0x26>
		p++, q++;
  800a6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a72:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a76:	84 c0                	test   %al,%al
  800a78:	74 07                	je     800a81 <strcmp+0x26>
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	3a 02                	cmp    (%edx),%al
  800a7f:	74 ee                	je     800a6f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a95:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9d:	85 d2                	test   %edx,%edx
  800a9f:	74 28                	je     800ac9 <strncmp+0x3e>
  800aa1:	0f b6 01             	movzbl (%ecx),%eax
  800aa4:	84 c0                	test   %al,%al
  800aa6:	74 24                	je     800acc <strncmp+0x41>
  800aa8:	3a 03                	cmp    (%ebx),%al
  800aaa:	75 20                	jne    800acc <strncmp+0x41>
  800aac:	83 ea 01             	sub    $0x1,%edx
  800aaf:	74 13                	je     800ac4 <strncmp+0x39>
		n--, p++, q++;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab7:	0f b6 01             	movzbl (%ecx),%eax
  800aba:	84 c0                	test   %al,%al
  800abc:	74 0e                	je     800acc <strncmp+0x41>
  800abe:	3a 03                	cmp    (%ebx),%al
  800ac0:	74 ea                	je     800aac <strncmp+0x21>
  800ac2:	eb 08                	jmp    800acc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800acc:	0f b6 01             	movzbl (%ecx),%eax
  800acf:	0f b6 13             	movzbl (%ebx),%edx
  800ad2:	29 d0                	sub    %edx,%eax
  800ad4:	eb f3                	jmp    800ac9 <strncmp+0x3e>

00800ad6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae0:	0f b6 10             	movzbl (%eax),%edx
  800ae3:	84 d2                	test   %dl,%dl
  800ae5:	74 1c                	je     800b03 <strchr+0x2d>
		if (*s == c)
  800ae7:	38 ca                	cmp    %cl,%dl
  800ae9:	75 09                	jne    800af4 <strchr+0x1e>
  800aeb:	eb 1b                	jmp    800b08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800af0:	38 ca                	cmp    %cl,%dl
  800af2:	74 14                	je     800b08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800af8:	84 d2                	test   %dl,%dl
  800afa:	75 f1                	jne    800aed <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	eb 05                	jmp    800b08 <strchr+0x32>
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b14:	0f b6 10             	movzbl (%eax),%edx
  800b17:	84 d2                	test   %dl,%dl
  800b19:	74 14                	je     800b2f <strfind+0x25>
		if (*s == c)
  800b1b:	38 ca                	cmp    %cl,%dl
  800b1d:	75 06                	jne    800b25 <strfind+0x1b>
  800b1f:	eb 0e                	jmp    800b2f <strfind+0x25>
  800b21:	38 ca                	cmp    %cl,%dl
  800b23:	74 0a                	je     800b2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b25:	83 c0 01             	add    $0x1,%eax
  800b28:	0f b6 10             	movzbl (%eax),%edx
  800b2b:	84 d2                	test   %dl,%dl
  800b2d:	75 f2                	jne    800b21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b3a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b3d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b49:	85 c9                	test   %ecx,%ecx
  800b4b:	74 30                	je     800b7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b53:	75 25                	jne    800b7a <memset+0x49>
  800b55:	f6 c1 03             	test   $0x3,%cl
  800b58:	75 20                	jne    800b7a <memset+0x49>
		c &= 0xFF;
  800b5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5d:	89 d3                	mov    %edx,%ebx
  800b5f:	c1 e3 08             	shl    $0x8,%ebx
  800b62:	89 d6                	mov    %edx,%esi
  800b64:	c1 e6 18             	shl    $0x18,%esi
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	c1 e0 10             	shl    $0x10,%eax
  800b6c:	09 f0                	or     %esi,%eax
  800b6e:	09 d0                	or     %edx,%eax
  800b70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b75:	fc                   	cld    
  800b76:	f3 ab                	rep stos %eax,%es:(%edi)
  800b78:	eb 03                	jmp    800b7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7a:	fc                   	cld    
  800b7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7d:	89 f8                	mov    %edi,%eax
  800b7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b88:	89 ec                	mov    %ebp,%esp
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 08             	sub    $0x8,%esp
  800b92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b95:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba1:	39 c6                	cmp    %eax,%esi
  800ba3:	73 36                	jae    800bdb <memmove+0x4f>
  800ba5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba8:	39 d0                	cmp    %edx,%eax
  800baa:	73 2f                	jae    800bdb <memmove+0x4f>
		s += n;
		d += n;
  800bac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baf:	f6 c2 03             	test   $0x3,%dl
  800bb2:	75 1b                	jne    800bcf <memmove+0x43>
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 13                	jne    800bcf <memmove+0x43>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 0e                	jne    800bcf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc1:	83 ef 04             	sub    $0x4,%edi
  800bc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bca:	fd                   	std    
  800bcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcd:	eb 09                	jmp    800bd8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bcf:	83 ef 01             	sub    $0x1,%edi
  800bd2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bd5:	fd                   	std    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd8:	fc                   	cld    
  800bd9:	eb 20                	jmp    800bfb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be1:	75 13                	jne    800bf6 <memmove+0x6a>
  800be3:	a8 03                	test   $0x3,%al
  800be5:	75 0f                	jne    800bf6 <memmove+0x6a>
  800be7:	f6 c1 03             	test   $0x3,%cl
  800bea:	75 0a                	jne    800bf6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	fc                   	cld    
  800bf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf4:	eb 05                	jmp    800bfb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	fc                   	cld    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bfb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bfe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c01:	89 ec                	mov    %ebp,%esp
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	89 04 24             	mov    %eax,(%esp)
  800c1f:	e8 68 ff ff ff       	call   800b8c <memmove>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c32:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	74 37                	je     800c75 <memcmp+0x4f>
		if (*s1 != *s2)
  800c3e:	0f b6 03             	movzbl (%ebx),%eax
  800c41:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c44:	83 ef 01             	sub    $0x1,%edi
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c4c:	38 c8                	cmp    %cl,%al
  800c4e:	74 1c                	je     800c6c <memcmp+0x46>
  800c50:	eb 10                	jmp    800c62 <memcmp+0x3c>
  800c52:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c5e:	38 c8                	cmp    %cl,%al
  800c60:	74 0a                	je     800c6c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c62:	0f b6 c0             	movzbl %al,%eax
  800c65:	0f b6 c9             	movzbl %cl,%ecx
  800c68:	29 c8                	sub    %ecx,%eax
  800c6a:	eb 09                	jmp    800c75 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6c:	39 fa                	cmp    %edi,%edx
  800c6e:	75 e2                	jne    800c52 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c80:	89 c2                	mov    %eax,%edx
  800c82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c85:	39 d0                	cmp    %edx,%eax
  800c87:	73 19                	jae    800ca2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c8d:	38 08                	cmp    %cl,(%eax)
  800c8f:	75 06                	jne    800c97 <memfind+0x1d>
  800c91:	eb 0f                	jmp    800ca2 <memfind+0x28>
  800c93:	38 08                	cmp    %cl,(%eax)
  800c95:	74 0b                	je     800ca2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	39 d0                	cmp    %edx,%eax
  800c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	75 f1                	jne    800c93 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb0:	0f b6 02             	movzbl (%edx),%eax
  800cb3:	3c 20                	cmp    $0x20,%al
  800cb5:	74 04                	je     800cbb <strtol+0x17>
  800cb7:	3c 09                	cmp    $0x9,%al
  800cb9:	75 0e                	jne    800cc9 <strtol+0x25>
		s++;
  800cbb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cbe:	0f b6 02             	movzbl (%edx),%eax
  800cc1:	3c 20                	cmp    $0x20,%al
  800cc3:	74 f6                	je     800cbb <strtol+0x17>
  800cc5:	3c 09                	cmp    $0x9,%al
  800cc7:	74 f2                	je     800cbb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc9:	3c 2b                	cmp    $0x2b,%al
  800ccb:	75 0a                	jne    800cd7 <strtol+0x33>
		s++;
  800ccd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd5:	eb 10                	jmp    800ce7 <strtol+0x43>
  800cd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cdc:	3c 2d                	cmp    $0x2d,%al
  800cde:	75 07                	jne    800ce7 <strtol+0x43>
		s++, neg = 1;
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce7:	85 db                	test   %ebx,%ebx
  800ce9:	0f 94 c0             	sete   %al
  800cec:	74 05                	je     800cf3 <strtol+0x4f>
  800cee:	83 fb 10             	cmp    $0x10,%ebx
  800cf1:	75 15                	jne    800d08 <strtol+0x64>
  800cf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cf6:	75 10                	jne    800d08 <strtol+0x64>
  800cf8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cfc:	75 0a                	jne    800d08 <strtol+0x64>
		s += 2, base = 16;
  800cfe:	83 c2 02             	add    $0x2,%edx
  800d01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d06:	eb 13                	jmp    800d1b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d08:	84 c0                	test   %al,%al
  800d0a:	74 0f                	je     800d1b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d11:	80 3a 30             	cmpb   $0x30,(%edx)
  800d14:	75 05                	jne    800d1b <strtol+0x77>
		s++, base = 8;
  800d16:	83 c2 01             	add    $0x1,%edx
  800d19:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d22:	0f b6 0a             	movzbl (%edx),%ecx
  800d25:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d28:	80 fb 09             	cmp    $0x9,%bl
  800d2b:	77 08                	ja     800d35 <strtol+0x91>
			dig = *s - '0';
  800d2d:	0f be c9             	movsbl %cl,%ecx
  800d30:	83 e9 30             	sub    $0x30,%ecx
  800d33:	eb 1e                	jmp    800d53 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d35:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d38:	80 fb 19             	cmp    $0x19,%bl
  800d3b:	77 08                	ja     800d45 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d3d:	0f be c9             	movsbl %cl,%ecx
  800d40:	83 e9 57             	sub    $0x57,%ecx
  800d43:	eb 0e                	jmp    800d53 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d45:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d48:	80 fb 19             	cmp    $0x19,%bl
  800d4b:	77 14                	ja     800d61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d4d:	0f be c9             	movsbl %cl,%ecx
  800d50:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d53:	39 f1                	cmp    %esi,%ecx
  800d55:	7d 0e                	jge    800d65 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d57:	83 c2 01             	add    $0x1,%edx
  800d5a:	0f af c6             	imul   %esi,%eax
  800d5d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d5f:	eb c1                	jmp    800d22 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d61:	89 c1                	mov    %eax,%ecx
  800d63:	eb 02                	jmp    800d67 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d65:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d6b:	74 05                	je     800d72 <strtol+0xce>
		*endptr = (char *) s;
  800d6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d70:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d72:	89 ca                	mov    %ecx,%edx
  800d74:	f7 da                	neg    %edx
  800d76:	85 ff                	test   %edi,%edi
  800d78:	0f 45 c2             	cmovne %edx,%eax
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	89 c7                	mov    %eax,%edi
  800d9e:	89 c6                	mov    %eax,%esi
  800da0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dab:	89 ec                	mov    %ebp,%esp
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_cgetc>:

int
sys_cgetc(void)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc8:	89 d1                	mov    %edx,%ecx
  800dca:	89 d3                	mov    %edx,%ebx
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	89 d6                	mov    %edx,%esi
  800dd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 38             	sub    $0x38,%esp
  800de5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800deb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df3:	b8 03 00 00 00       	mov    $0x3,%eax
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 cb                	mov    %ecx,%ebx
  800dfd:	89 cf                	mov    %ecx,%edi
  800dff:	89 ce                	mov    %ecx,%esi
  800e01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7e 28                	jle    800e2f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e12:	00 
  800e13:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800e1a:	00 
  800e1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e22:	00 
  800e23:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800e2a:	e8 21 f3 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e38:	89 ec                	mov    %ebp,%esp
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e50:	b8 02 00 00 00       	mov    $0x2,%eax
  800e55:	89 d1                	mov    %edx,%ecx
  800e57:	89 d3                	mov    %edx,%ebx
  800e59:	89 d7                	mov    %edx,%edi
  800e5b:	89 d6                	mov    %edx,%esi
  800e5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_yield>:

void
sys_yield(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 d3                	mov    %edx,%ebx
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 38             	sub    $0x38,%esp
  800ea2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eab:	be 00 00 00 00       	mov    $0x0,%esi
  800eb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 f7                	mov    %esi,%edi
  800ec0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800ee9:	e8 62 f2 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef7:	89 ec                	mov    %ebp,%esp
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 38             	sub    $0x38,%esp
  800f01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	7e 28                	jle    800f4c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f2f:	00 
  800f30:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800f37:	00 
  800f38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3f:	00 
  800f40:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800f47:	e8 04 f2 ff ff       	call   800150 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f55:	89 ec                	mov    %ebp,%esp
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 38             	sub    $0x38,%esp
  800f5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	89 df                	mov    %ebx,%edi
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 28                	jle    800faa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800f95:	00 
  800f96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800fa5:	e8 a6 f1 ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800faa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb3:	89 ec                	mov    %ebp,%esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 38             	sub    $0x38,%esp
  800fbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801003:	e8 48 f1 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801008:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801011:	89 ec                	mov    %ebp,%esp
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 38             	sub    $0x38,%esp
  80101b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80101e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801021:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
  801029:	b8 09 00 00 00       	mov    $0x9,%eax
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	8b 55 08             	mov    0x8(%ebp),%edx
  801034:	89 df                	mov    %ebx,%edi
  801036:	89 de                	mov    %ebx,%esi
  801038:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	7e 28                	jle    801066 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801042:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801049:	00 
  80104a:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801051:	00 
  801052:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801059:	00 
  80105a:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801061:	e8 ea f0 ff ff       	call   800150 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801066:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801069:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80106f:	89 ec                	mov    %ebp,%esp
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 38             	sub    $0x38,%esp
  801079:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80107c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80107f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	bb 00 00 00 00       	mov    $0x0,%ebx
  801087:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108f:	8b 55 08             	mov    0x8(%ebp),%edx
  801092:	89 df                	mov    %ebx,%edi
  801094:	89 de                	mov    %ebx,%esi
  801096:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801098:	85 c0                	test   %eax,%eax
  80109a:	7e 28                	jle    8010c4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010a7:	00 
  8010a8:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  8010af:	00 
  8010b0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b7:	00 
  8010b8:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  8010bf:	e8 8c f0 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cd:	89 ec                	mov    %ebp,%esp
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010da:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	be 00 00 00 00       	mov    $0x0,%esi
  8010e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801101:	89 ec                	mov    %ebp,%esp
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 38             	sub    $0x38,%esp
  80110b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80110e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801111:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801114:	b9 00 00 00 00       	mov    $0x0,%ecx
  801119:	b8 0d 00 00 00       	mov    $0xd,%eax
  80111e:	8b 55 08             	mov    0x8(%ebp),%edx
  801121:	89 cb                	mov    %ecx,%ebx
  801123:	89 cf                	mov    %ecx,%edi
  801125:	89 ce                	mov    %ecx,%esi
  801127:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801129:	85 c0                	test   %eax,%eax
  80112b:	7e 28                	jle    801155 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801131:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801138:	00 
  801139:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801140:	00 
  801141:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801148:	00 
  801149:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801150:	e8 fb ef ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801155:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801158:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80115b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80115e:	89 ec                	mov    %ebp,%esp
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80116b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80116e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801171:	b9 00 00 00 00       	mov    $0x0,%ecx
  801176:	b8 0e 00 00 00       	mov    $0xe,%eax
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
  80117e:	89 cb                	mov    %ecx,%ebx
  801180:	89 cf                	mov    %ecx,%edi
  801182:	89 ce                	mov    %ecx,%esi
  801184:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801186:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801189:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80118c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80118f:	89 ec                	mov    %ebp,%esp
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    
	...

00801194 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80119a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8011a1:	75 3c                	jne    8011df <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8011a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011b2:	ee 
  8011b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ba:	e8 dd fc ff ff       	call   800e9c <sys_page_alloc>
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 1c                	jns    8011df <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8011c3:	c7 44 24 08 4c 28 80 	movl   $0x80284c,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 ae 28 80 00 	movl   $0x8028ae,(%esp)
  8011da:	e8 71 ef ff ff       	call   800150 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011df:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e2:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8011e7:	c7 44 24 04 20 12 80 	movl   $0x801220,0x4(%esp)
  8011ee:	00 
  8011ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f6:	e8 78 fe ff ff       	call   801073 <sys_env_set_pgfault_upcall>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	79 1c                	jns    80121b <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8011ff:	c7 44 24 08 78 28 80 	movl   $0x802878,0x8(%esp)
  801206:	00 
  801207:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80120e:	00 
  80120f:	c7 04 24 ae 28 80 00 	movl   $0x8028ae,(%esp)
  801216:	e8 35 ef ff ff       	call   800150 <_panic>
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    
  80121d:	00 00                	add    %al,(%eax)
	...

00801220 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801220:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801221:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801226:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801228:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80122b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80122f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801234:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  801238:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80123a:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  80123d:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80123e:	83 c4 04             	add    $0x4,%esp
    popfl
  801241:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  801242:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  801243:	c3                   	ret    
	...

00801250 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	05 00 00 00 30       	add    $0x30000000,%eax
  80125b:	c1 e8 0c             	shr    $0xc,%eax
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 df ff ff ff       	call   801250 <fd2num>
  801271:	05 20 00 0d 00       	add    $0xd0020,%eax
  801276:	c1 e0 0c             	shl    $0xc,%eax
}
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801282:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801287:	a8 01                	test   $0x1,%al
  801289:	74 34                	je     8012bf <fd_alloc+0x44>
  80128b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801290:	a8 01                	test   $0x1,%al
  801292:	74 32                	je     8012c6 <fd_alloc+0x4b>
  801294:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801299:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	c1 ea 16             	shr    $0x16,%edx
  8012a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a7:	f6 c2 01             	test   $0x1,%dl
  8012aa:	74 1f                	je     8012cb <fd_alloc+0x50>
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	c1 ea 0c             	shr    $0xc,%edx
  8012b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b8:	f6 c2 01             	test   $0x1,%dl
  8012bb:	75 17                	jne    8012d4 <fd_alloc+0x59>
  8012bd:	eb 0c                	jmp    8012cb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012bf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012c4:	eb 05                	jmp    8012cb <fd_alloc+0x50>
  8012c6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012cb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	eb 17                	jmp    8012eb <fd_alloc+0x70>
  8012d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012de:	75 b9                	jne    801299 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012eb:	5b                   	pop    %ebx
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f9:	83 fa 1f             	cmp    $0x1f,%edx
  8012fc:	77 3f                	ja     80133d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012fe:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801304:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801307:	89 d0                	mov    %edx,%eax
  801309:	c1 e8 16             	shr    $0x16,%eax
  80130c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801318:	f6 c1 01             	test   $0x1,%cl
  80131b:	74 20                	je     80133d <fd_lookup+0x4f>
  80131d:	89 d0                	mov    %edx,%eax
  80131f:	c1 e8 0c             	shr    $0xc,%eax
  801322:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801329:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80132e:	f6 c1 01             	test   $0x1,%cl
  801331:	74 0a                	je     80133d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801333:	8b 45 0c             	mov    0xc(%ebp),%eax
  801336:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801338:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	53                   	push   %ebx
  801343:	83 ec 14             	sub    $0x14,%esp
  801346:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801351:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801357:	75 17                	jne    801370 <dev_lookup+0x31>
  801359:	eb 07                	jmp    801362 <dev_lookup+0x23>
  80135b:	39 0a                	cmp    %ecx,(%edx)
  80135d:	75 11                	jne    801370 <dev_lookup+0x31>
  80135f:	90                   	nop
  801360:	eb 05                	jmp    801367 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801362:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801367:	89 13                	mov    %edx,(%ebx)
			return 0;
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
  80136e:	eb 35                	jmp    8013a5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801370:	83 c0 01             	add    $0x1,%eax
  801373:	8b 14 85 3c 29 80 00 	mov    0x80293c(,%eax,4),%edx
  80137a:	85 d2                	test   %edx,%edx
  80137c:	75 dd                	jne    80135b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80137e:	a1 04 40 80 00       	mov    0x804004,%eax
  801383:	8b 40 48             	mov    0x48(%eax),%eax
  801386:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138e:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  801395:	e8 b1 ee ff ff       	call   80024b <cprintf>
	*dev = 0;
  80139a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013a5:	83 c4 14             	add    $0x14,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 38             	sub    $0x38,%esp
  8013b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013bd:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c1:	89 3c 24             	mov    %edi,(%esp)
  8013c4:	e8 87 fe ff ff       	call   801250 <fd2num>
  8013c9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8013cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	e8 16 ff ff ff       	call   8012ee <fd_lookup>
  8013d8:	89 c3                	mov    %eax,%ebx
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 05                	js     8013e3 <fd_close+0x38>
	    || fd != fd2)
  8013de:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8013e1:	74 0e                	je     8013f1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	84 c0                	test   %al,%al
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ec:	0f 44 d8             	cmove  %eax,%ebx
  8013ef:	eb 3d                	jmp    80142e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013f1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	8b 07                	mov    (%edi),%eax
  8013fa:	89 04 24             	mov    %eax,(%esp)
  8013fd:	e8 3d ff ff ff       	call   80133f <dev_lookup>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	85 c0                	test   %eax,%eax
  801406:	78 16                	js     80141e <fd_close+0x73>
		if (dev->dev_close)
  801408:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80140b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80140e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801413:	85 c0                	test   %eax,%eax
  801415:	74 07                	je     80141e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801417:	89 3c 24             	mov    %edi,(%esp)
  80141a:	ff d0                	call   *%eax
  80141c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80141e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801429:	e8 2b fb ff ff       	call   800f59 <sys_page_unmap>
	return r;
}
  80142e:	89 d8                	mov    %ebx,%eax
  801430:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801433:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801436:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801439:	89 ec                	mov    %ebp,%esp
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    

0080143d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801443:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	89 04 24             	mov    %eax,(%esp)
  801450:	e8 99 fe ff ff       	call   8012ee <fd_lookup>
  801455:	85 c0                	test   %eax,%eax
  801457:	78 13                	js     80146c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801459:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801460:	00 
  801461:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801464:	89 04 24             	mov    %eax,(%esp)
  801467:	e8 3f ff ff ff       	call   8013ab <fd_close>
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <close_all>:

void
close_all(void)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801475:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80147a:	89 1c 24             	mov    %ebx,(%esp)
  80147d:	e8 bb ff ff ff       	call   80143d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801482:	83 c3 01             	add    $0x1,%ebx
  801485:	83 fb 20             	cmp    $0x20,%ebx
  801488:	75 f0                	jne    80147a <close_all+0xc>
		close(i);
}
  80148a:	83 c4 14             	add    $0x14,%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 58             	sub    $0x58,%esp
  801496:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801499:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80149c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80149f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 3a fe ff ff       	call   8012ee <fd_lookup>
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	0f 88 e1 00 00 00    	js     80159f <dup+0x10f>
		return r;
	close(newfdnum);
  8014be:	89 3c 24             	mov    %edi,(%esp)
  8014c1:	e8 77 ff ff ff       	call   80143d <close>

	newfd = INDEX2FD(newfdnum);
  8014c6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014cc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d2:	89 04 24             	mov    %eax,(%esp)
  8014d5:	e8 86 fd ff ff       	call   801260 <fd2data>
  8014da:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014dc:	89 34 24             	mov    %esi,(%esp)
  8014df:	e8 7c fd ff ff       	call   801260 <fd2data>
  8014e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014e7:	89 d8                	mov    %ebx,%eax
  8014e9:	c1 e8 16             	shr    $0x16,%eax
  8014ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014f3:	a8 01                	test   $0x1,%al
  8014f5:	74 46                	je     80153d <dup+0xad>
  8014f7:	89 d8                	mov    %ebx,%eax
  8014f9:	c1 e8 0c             	shr    $0xc,%eax
  8014fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801503:	f6 c2 01             	test   $0x1,%dl
  801506:	74 35                	je     80153d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801508:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150f:	25 07 0e 00 00       	and    $0xe07,%eax
  801514:	89 44 24 10          	mov    %eax,0x10(%esp)
  801518:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80151b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801526:	00 
  801527:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80152b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801532:	e8 c4 f9 ff ff       	call   800efb <sys_page_map>
  801537:	89 c3                	mov    %eax,%ebx
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 3b                	js     801578 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80153d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801540:	89 c2                	mov    %eax,%edx
  801542:	c1 ea 0c             	shr    $0xc,%edx
  801545:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801552:	89 54 24 10          	mov    %edx,0x10(%esp)
  801556:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80155a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801561:	00 
  801562:	89 44 24 04          	mov    %eax,0x4(%esp)
  801566:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156d:	e8 89 f9 ff ff       	call   800efb <sys_page_map>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	85 c0                	test   %eax,%eax
  801576:	79 25                	jns    80159d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801578:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801583:	e8 d1 f9 ff ff       	call   800f59 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801588:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80158b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801596:	e8 be f9 ff ff       	call   800f59 <sys_page_unmap>
	return r;
  80159b:	eb 02                	jmp    80159f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80159d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80159f:	89 d8                	mov    %ebx,%eax
  8015a1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015a4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015a7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015aa:	89 ec                	mov    %ebp,%esp
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    

008015ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 24             	sub    $0x24,%esp
  8015b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bf:	89 1c 24             	mov    %ebx,(%esp)
  8015c2:	e8 27 fd ff ff       	call   8012ee <fd_lookup>
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 6d                	js     801638 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	8b 00                	mov    (%eax),%eax
  8015d7:	89 04 24             	mov    %eax,(%esp)
  8015da:	e8 60 fd ff ff       	call   80133f <dev_lookup>
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 55                	js     801638 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e6:	8b 50 08             	mov    0x8(%eax),%edx
  8015e9:	83 e2 03             	and    $0x3,%edx
  8015ec:	83 fa 01             	cmp    $0x1,%edx
  8015ef:	75 23                	jne    801614 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f6:	8b 40 48             	mov    0x48(%eax),%eax
  8015f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801601:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
  801608:	e8 3e ec ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  80160d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801612:	eb 24                	jmp    801638 <read+0x8a>
	}
	if (!dev->dev_read)
  801614:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801617:	8b 52 08             	mov    0x8(%edx),%edx
  80161a:	85 d2                	test   %edx,%edx
  80161c:	74 15                	je     801633 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80161e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801621:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801625:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801628:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80162c:	89 04 24             	mov    %eax,(%esp)
  80162f:	ff d2                	call   *%edx
  801631:	eb 05                	jmp    801638 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801633:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801638:	83 c4 24             	add    $0x24,%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 1c             	sub    $0x1c,%esp
  801647:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164d:	b8 00 00 00 00       	mov    $0x0,%eax
  801652:	85 f6                	test   %esi,%esi
  801654:	74 30                	je     801686 <readn+0x48>
  801656:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80165b:	89 f2                	mov    %esi,%edx
  80165d:	29 c2                	sub    %eax,%edx
  80165f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801663:	03 45 0c             	add    0xc(%ebp),%eax
  801666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166a:	89 3c 24             	mov    %edi,(%esp)
  80166d:	e8 3c ff ff ff       	call   8015ae <read>
		if (m < 0)
  801672:	85 c0                	test   %eax,%eax
  801674:	78 10                	js     801686 <readn+0x48>
			return m;
		if (m == 0)
  801676:	85 c0                	test   %eax,%eax
  801678:	74 0a                	je     801684 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167a:	01 c3                	add    %eax,%ebx
  80167c:	89 d8                	mov    %ebx,%eax
  80167e:	39 f3                	cmp    %esi,%ebx
  801680:	72 d9                	jb     80165b <readn+0x1d>
  801682:	eb 02                	jmp    801686 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801684:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801686:	83 c4 1c             	add    $0x1c,%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5f                   	pop    %edi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 24             	sub    $0x24,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169f:	89 1c 24             	mov    %ebx,(%esp)
  8016a2:	e8 47 fc ff ff       	call   8012ee <fd_lookup>
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 68                	js     801713 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	8b 00                	mov    (%eax),%eax
  8016b7:	89 04 24             	mov    %eax,(%esp)
  8016ba:	e8 80 fc ff ff       	call   80133f <dev_lookup>
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 50                	js     801713 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ca:	75 23                	jne    8016ef <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d1:	8b 40 48             	mov    0x48(%eax),%eax
  8016d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dc:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8016e3:	e8 63 eb ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  8016e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ed:	eb 24                	jmp    801713 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f5:	85 d2                	test   %edx,%edx
  8016f7:	74 15                	je     80170e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016fc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801700:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801703:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	ff d2                	call   *%edx
  80170c:	eb 05                	jmp    801713 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80170e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801713:	83 c4 24             	add    $0x24,%esp
  801716:	5b                   	pop    %ebx
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <seek>:

int
seek(int fdnum, off_t offset)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801722:	89 44 24 04          	mov    %eax,0x4(%esp)
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	89 04 24             	mov    %eax,(%esp)
  80172c:	e8 bd fb ff ff       	call   8012ee <fd_lookup>
  801731:	85 c0                	test   %eax,%eax
  801733:	78 0e                	js     801743 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801735:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801738:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80173e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 24             	sub    $0x24,%esp
  80174c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	89 1c 24             	mov    %ebx,(%esp)
  801759:	e8 90 fb ff ff       	call   8012ee <fd_lookup>
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 61                	js     8017c3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176c:	8b 00                	mov    (%eax),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 c9 fb ff ff       	call   80133f <dev_lookup>
  801776:	85 c0                	test   %eax,%eax
  801778:	78 49                	js     8017c3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801781:	75 23                	jne    8017a6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801783:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801788:	8b 40 48             	mov    0x48(%eax),%eax
  80178b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80178f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801793:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  80179a:	e8 ac ea ff ff       	call   80024b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80179f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a4:	eb 1d                	jmp    8017c3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a9:	8b 52 18             	mov    0x18(%edx),%edx
  8017ac:	85 d2                	test   %edx,%edx
  8017ae:	74 0e                	je     8017be <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017b7:	89 04 24             	mov    %eax,(%esp)
  8017ba:	ff d2                	call   *%edx
  8017bc:	eb 05                	jmp    8017c3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c3:	83 c4 24             	add    $0x24,%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 24             	sub    $0x24,%esp
  8017d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	89 04 24             	mov    %eax,(%esp)
  8017e0:	e8 09 fb ff ff       	call   8012ee <fd_lookup>
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 52                	js     80183b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f3:	8b 00                	mov    (%eax),%eax
  8017f5:	89 04 24             	mov    %eax,(%esp)
  8017f8:	e8 42 fb ff ff       	call   80133f <dev_lookup>
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 3a                	js     80183b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801804:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801808:	74 2c                	je     801836 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801814:	00 00 00 
	stat->st_isdir = 0;
  801817:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181e:	00 00 00 
	stat->st_dev = dev;
  801821:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801827:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80182b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80182e:	89 14 24             	mov    %edx,(%esp)
  801831:	ff 50 14             	call   *0x14(%eax)
  801834:	eb 05                	jmp    80183b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801836:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80183b:	83 c4 24             	add    $0x24,%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 18             	sub    $0x18,%esp
  801847:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80184a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801854:	00 
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	89 04 24             	mov    %eax,(%esp)
  80185b:	e8 bc 01 00 00       	call   801a1c <open>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	85 c0                	test   %eax,%eax
  801864:	78 1b                	js     801881 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801866:	8b 45 0c             	mov    0xc(%ebp),%eax
  801869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186d:	89 1c 24             	mov    %ebx,(%esp)
  801870:	e8 54 ff ff ff       	call   8017c9 <fstat>
  801875:	89 c6                	mov    %eax,%esi
	close(fd);
  801877:	89 1c 24             	mov    %ebx,(%esp)
  80187a:	e8 be fb ff ff       	call   80143d <close>
	return r;
  80187f:	89 f3                	mov    %esi,%ebx
}
  801881:	89 d8                	mov    %ebx,%eax
  801883:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801886:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801889:	89 ec                	mov    %ebp,%esp
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    
  80188d:	00 00                	add    %al,(%eax)
	...

00801890 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 18             	sub    $0x18,%esp
  801896:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801899:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018a0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018a7:	75 11                	jne    8018ba <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018b0:	e8 5c 08 00 00       	call   802111 <ipc_find_env>
  8018b5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ba:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018c1:	00 
  8018c2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018c9:	00 
  8018ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ce:	a1 00 40 80 00       	mov    0x804000,%eax
  8018d3:	89 04 24             	mov    %eax,(%esp)
  8018d6:	e8 cb 07 00 00       	call   8020a6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8018db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e2:	00 
  8018e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ee:	e8 4d 07 00 00       	call   802040 <ipc_recv>
}
  8018f3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018f6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018f9:	89 ec                	mov    %ebp,%esp
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	53                   	push   %ebx
  801901:	83 ec 14             	sub    $0x14,%esp
  801904:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	8b 40 0c             	mov    0xc(%eax),%eax
  80190d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 05 00 00 00       	mov    $0x5,%eax
  80191c:	e8 6f ff ff ff       	call   801890 <fsipc>
  801921:	85 c0                	test   %eax,%eax
  801923:	78 2b                	js     801950 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801925:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80192c:	00 
  80192d:	89 1c 24             	mov    %ebx,(%esp)
  801930:	e8 66 f0 ff ff       	call   80099b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801935:	a1 80 50 80 00       	mov    0x805080,%eax
  80193a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801940:	a1 84 50 80 00       	mov    0x805084,%eax
  801945:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	83 c4 14             	add    $0x14,%esp
  801953:	5b                   	pop    %ebx
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 40 0c             	mov    0xc(%eax),%eax
  801962:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801967:	ba 00 00 00 00       	mov    $0x0,%edx
  80196c:	b8 06 00 00 00       	mov    $0x6,%eax
  801971:	e8 1a ff ff ff       	call   801890 <fsipc>
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
  80197d:	83 ec 10             	sub    $0x10,%esp
  801980:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	8b 40 0c             	mov    0xc(%eax),%eax
  801989:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80198e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801994:	ba 00 00 00 00       	mov    $0x0,%edx
  801999:	b8 03 00 00 00       	mov    $0x3,%eax
  80199e:	e8 ed fe ff ff       	call   801890 <fsipc>
  8019a3:	89 c3                	mov    %eax,%ebx
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 6a                	js     801a13 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019a9:	39 c6                	cmp    %eax,%esi
  8019ab:	73 24                	jae    8019d1 <devfile_read+0x59>
  8019ad:	c7 44 24 0c 4c 29 80 	movl   $0x80294c,0xc(%esp)
  8019b4:	00 
  8019b5:	c7 44 24 08 53 29 80 	movl   $0x802953,0x8(%esp)
  8019bc:	00 
  8019bd:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8019c4:	00 
  8019c5:	c7 04 24 68 29 80 00 	movl   $0x802968,(%esp)
  8019cc:	e8 7f e7 ff ff       	call   800150 <_panic>
	assert(r <= PGSIZE);
  8019d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019d6:	7e 24                	jle    8019fc <devfile_read+0x84>
  8019d8:	c7 44 24 0c 73 29 80 	movl   $0x802973,0xc(%esp)
  8019df:	00 
  8019e0:	c7 44 24 08 53 29 80 	movl   $0x802953,0x8(%esp)
  8019e7:	00 
  8019e8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019ef:	00 
  8019f0:	c7 04 24 68 29 80 00 	movl   $0x802968,(%esp)
  8019f7:	e8 54 e7 ff ff       	call   800150 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a00:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a07:	00 
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	e8 79 f1 ff ff       	call   800b8c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801a13:	89 d8                	mov    %ebx,%eax
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	83 ec 20             	sub    $0x20,%esp
  801a24:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a27:	89 34 24             	mov    %esi,(%esp)
  801a2a:	e8 21 ef ff ff       	call   800950 <strlen>
		return -E_BAD_PATH;
  801a2f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a39:	7f 5e                	jg     801a99 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3e:	89 04 24             	mov    %eax,(%esp)
  801a41:	e8 35 f8 ff ff       	call   80127b <fd_alloc>
  801a46:	89 c3                	mov    %eax,%ebx
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	78 4d                	js     801a99 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a50:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a57:	e8 3f ef ff ff       	call   80099b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a67:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6c:	e8 1f fe ff ff       	call   801890 <fsipc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	85 c0                	test   %eax,%eax
  801a75:	79 15                	jns    801a8c <open+0x70>
		fd_close(fd, 0);
  801a77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a7e:	00 
  801a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a82:	89 04 24             	mov    %eax,(%esp)
  801a85:	e8 21 f9 ff ff       	call   8013ab <fd_close>
		return r;
  801a8a:	eb 0d                	jmp    801a99 <open+0x7d>
	}

	return fd2num(fd);
  801a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 b9 f7 ff ff       	call   801250 <fd2num>
  801a97:	89 c3                	mov    %eax,%ebx
}
  801a99:	89 d8                	mov    %ebx,%eax
  801a9b:	83 c4 20             	add    $0x20,%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    
	...

00801ab0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 18             	sub    $0x18,%esp
  801ab6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ab9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801abc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 96 f7 ff ff       	call   801260 <fd2data>
  801aca:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801acc:	c7 44 24 04 7f 29 80 	movl   $0x80297f,0x4(%esp)
  801ad3:	00 
  801ad4:	89 34 24             	mov    %esi,(%esp)
  801ad7:	e8 bf ee ff ff       	call   80099b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801adc:	8b 43 04             	mov    0x4(%ebx),%eax
  801adf:	2b 03                	sub    (%ebx),%eax
  801ae1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ae7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801aee:	00 00 00 
	stat->st_dev = &devpipe;
  801af1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801af8:	30 80 00 
	return 0;
}
  801afb:	b8 00 00 00 00       	mov    $0x0,%eax
  801b00:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b03:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b06:	89 ec                	mov    %ebp,%esp
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 14             	sub    $0x14,%esp
  801b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1f:	e8 35 f4 ff ff       	call   800f59 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b24:	89 1c 24             	mov    %ebx,(%esp)
  801b27:	e8 34 f7 ff ff       	call   801260 <fd2data>
  801b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b37:	e8 1d f4 ff ff       	call   800f59 <sys_page_unmap>
}
  801b3c:	83 c4 14             	add    $0x14,%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	57                   	push   %edi
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 2c             	sub    $0x2c,%esp
  801b4b:	89 c7                	mov    %eax,%edi
  801b4d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b50:	a1 04 40 80 00       	mov    0x804004,%eax
  801b55:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b58:	89 3c 24             	mov    %edi,(%esp)
  801b5b:	e8 fc 05 00 00       	call   80215c <pageref>
  801b60:	89 c6                	mov    %eax,%esi
  801b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 ef 05 00 00       	call   80215c <pageref>
  801b6d:	39 c6                	cmp    %eax,%esi
  801b6f:	0f 94 c0             	sete   %al
  801b72:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b75:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b7b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b7e:	39 cb                	cmp    %ecx,%ebx
  801b80:	75 08                	jne    801b8a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b82:	83 c4 2c             	add    $0x2c,%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b8a:	83 f8 01             	cmp    $0x1,%eax
  801b8d:	75 c1                	jne    801b50 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b8f:	8b 52 58             	mov    0x58(%edx),%edx
  801b92:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b96:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9e:	c7 04 24 86 29 80 00 	movl   $0x802986,(%esp)
  801ba5:	e8 a1 e6 ff ff       	call   80024b <cprintf>
  801baa:	eb a4                	jmp    801b50 <_pipeisclosed+0xe>

00801bac <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	57                   	push   %edi
  801bb0:	56                   	push   %esi
  801bb1:	53                   	push   %ebx
  801bb2:	83 ec 2c             	sub    $0x2c,%esp
  801bb5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bb8:	89 34 24             	mov    %esi,(%esp)
  801bbb:	e8 a0 f6 ff ff       	call   801260 <fd2data>
  801bc0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc2:	bf 00 00 00 00       	mov    $0x0,%edi
  801bc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bcb:	75 50                	jne    801c1d <devpipe_write+0x71>
  801bcd:	eb 5c                	jmp    801c2b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bcf:	89 da                	mov    %ebx,%edx
  801bd1:	89 f0                	mov    %esi,%eax
  801bd3:	e8 6a ff ff ff       	call   801b42 <_pipeisclosed>
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	75 53                	jne    801c2f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bdc:	e8 8b f2 ff ff       	call   800e6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801be1:	8b 43 04             	mov    0x4(%ebx),%eax
  801be4:	8b 13                	mov    (%ebx),%edx
  801be6:	83 c2 20             	add    $0x20,%edx
  801be9:	39 d0                	cmp    %edx,%eax
  801beb:	73 e2                	jae    801bcf <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bed:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801bf4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801bf7:	89 c2                	mov    %eax,%edx
  801bf9:	c1 fa 1f             	sar    $0x1f,%edx
  801bfc:	c1 ea 1b             	shr    $0x1b,%edx
  801bff:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801c02:	83 e1 1f             	and    $0x1f,%ecx
  801c05:	29 d1                	sub    %edx,%ecx
  801c07:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801c0b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801c0f:	83 c0 01             	add    $0x1,%eax
  801c12:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c15:	83 c7 01             	add    $0x1,%edi
  801c18:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c1b:	74 0e                	je     801c2b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801c20:	8b 13                	mov    (%ebx),%edx
  801c22:	83 c2 20             	add    $0x20,%edx
  801c25:	39 d0                	cmp    %edx,%eax
  801c27:	73 a6                	jae    801bcf <devpipe_write+0x23>
  801c29:	eb c2                	jmp    801bed <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c2b:	89 f8                	mov    %edi,%eax
  801c2d:	eb 05                	jmp    801c34 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c34:	83 c4 2c             	add    $0x2c,%esp
  801c37:	5b                   	pop    %ebx
  801c38:	5e                   	pop    %esi
  801c39:	5f                   	pop    %edi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 28             	sub    $0x28,%esp
  801c42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c48:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c4b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c4e:	89 3c 24             	mov    %edi,(%esp)
  801c51:	e8 0a f6 ff ff       	call   801260 <fd2data>
  801c56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c58:	be 00 00 00 00       	mov    $0x0,%esi
  801c5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c61:	75 47                	jne    801caa <devpipe_read+0x6e>
  801c63:	eb 52                	jmp    801cb7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c65:	89 f0                	mov    %esi,%eax
  801c67:	eb 5e                	jmp    801cc7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c69:	89 da                	mov    %ebx,%edx
  801c6b:	89 f8                	mov    %edi,%eax
  801c6d:	8d 76 00             	lea    0x0(%esi),%esi
  801c70:	e8 cd fe ff ff       	call   801b42 <_pipeisclosed>
  801c75:	85 c0                	test   %eax,%eax
  801c77:	75 49                	jne    801cc2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801c79:	e8 ee f1 ff ff       	call   800e6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c7e:	8b 03                	mov    (%ebx),%eax
  801c80:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c83:	74 e4                	je     801c69 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c85:	89 c2                	mov    %eax,%edx
  801c87:	c1 fa 1f             	sar    $0x1f,%edx
  801c8a:	c1 ea 1b             	shr    $0x1b,%edx
  801c8d:	01 d0                	add    %edx,%eax
  801c8f:	83 e0 1f             	and    $0x1f,%eax
  801c92:	29 d0                	sub    %edx,%eax
  801c94:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c9f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca2:	83 c6 01             	add    $0x1,%esi
  801ca5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca8:	74 0d                	je     801cb7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801caa:	8b 03                	mov    (%ebx),%eax
  801cac:	3b 43 04             	cmp    0x4(%ebx),%eax
  801caf:	75 d4                	jne    801c85 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb1:	85 f6                	test   %esi,%esi
  801cb3:	75 b0                	jne    801c65 <devpipe_read+0x29>
  801cb5:	eb b2                	jmp    801c69 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb7:	89 f0                	mov    %esi,%eax
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	eb 05                	jmp    801cc7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ccd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cd0:	89 ec                	mov    %ebp,%esp
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	83 ec 48             	sub    $0x48,%esp
  801cda:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801cdd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ce0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ce3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ce9:	89 04 24             	mov    %eax,(%esp)
  801cec:	e8 8a f5 ff ff       	call   80127b <fd_alloc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	0f 88 45 01 00 00    	js     801e40 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d02:	00 
  801d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d11:	e8 86 f1 ff ff       	call   800e9c <sys_page_alloc>
  801d16:	89 c3                	mov    %eax,%ebx
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	0f 88 20 01 00 00    	js     801e40 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d20:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d23:	89 04 24             	mov    %eax,(%esp)
  801d26:	e8 50 f5 ff ff       	call   80127b <fd_alloc>
  801d2b:	89 c3                	mov    %eax,%ebx
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	0f 88 f8 00 00 00    	js     801e2d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d35:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d3c:	00 
  801d3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4b:	e8 4c f1 ff ff       	call   800e9c <sys_page_alloc>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 d3 00 00 00    	js     801e2d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d5d:	89 04 24             	mov    %eax,(%esp)
  801d60:	e8 fb f4 ff ff       	call   801260 <fd2data>
  801d65:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d67:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d6e:	00 
  801d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7a:	e8 1d f1 ff ff       	call   800e9c <sys_page_alloc>
  801d7f:	89 c3                	mov    %eax,%ebx
  801d81:	85 c0                	test   %eax,%eax
  801d83:	0f 88 91 00 00 00    	js     801e1a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 cc f4 ff ff       	call   801260 <fd2data>
  801d94:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d9b:	00 
  801d9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801da7:	00 
  801da8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db3:	e8 43 f1 ff ff       	call   800efb <sys_page_map>
  801db8:	89 c3                	mov    %eax,%ebx
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	78 4c                	js     801e0a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dbe:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dcc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dd3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ddc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dde:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801deb:	89 04 24             	mov    %eax,(%esp)
  801dee:	e8 5d f4 ff ff       	call   801250 <fd2num>
  801df3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801df5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	e8 50 f4 ff ff       	call   801250 <fd2num>
  801e00:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e08:	eb 36                	jmp    801e40 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801e0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e15:	e8 3f f1 ff ff       	call   800f59 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e28:	e8 2c f1 ff ff       	call   800f59 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3b:	e8 19 f1 ff ff       	call   800f59 <sys_page_unmap>
    err:
	return r;
}
  801e40:	89 d8                	mov    %ebx,%eax
  801e42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801e4b:	89 ec                	mov    %ebp,%esp
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5f:	89 04 24             	mov    %eax,(%esp)
  801e62:	e8 87 f4 ff ff       	call   8012ee <fd_lookup>
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 15                	js     801e80 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 ea f3 ff ff       	call   801260 <fd2data>
	return _pipeisclosed(fd, p);
  801e76:	89 c2                	mov    %eax,%edx
  801e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7b:	e8 c2 fc ff ff       	call   801b42 <_pipeisclosed>
}
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    
	...

00801e90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    

00801e9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ea0:	c7 44 24 04 9e 29 80 	movl   $0x80299e,0x4(%esp)
  801ea7:	00 
  801ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eab:	89 04 24             	mov    %eax,(%esp)
  801eae:	e8 e8 ea ff ff       	call   80099b <strcpy>
	return 0;
}
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	57                   	push   %edi
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec6:	be 00 00 00 00       	mov    $0x0,%esi
  801ecb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ecf:	74 43                	je     801f14 <devcons_write+0x5a>
  801ed1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801edf:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ee1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ee9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ef0:	03 45 0c             	add    0xc(%ebp),%eax
  801ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef7:	89 3c 24             	mov    %edi,(%esp)
  801efa:	e8 8d ec ff ff       	call   800b8c <memmove>
		sys_cputs(buf, m);
  801eff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f03:	89 3c 24             	mov    %edi,(%esp)
  801f06:	e8 75 ee ff ff       	call   800d80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0b:	01 de                	add    %ebx,%esi
  801f0d:	89 f0                	mov    %esi,%eax
  801f0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f12:	72 c8                	jb     801edc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f14:	89 f0                	mov    %esi,%eax
  801f16:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f1c:	5b                   	pop    %ebx
  801f1d:	5e                   	pop    %esi
  801f1e:	5f                   	pop    %edi
  801f1f:	5d                   	pop    %ebp
  801f20:	c3                   	ret    

00801f21 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801f2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f30:	75 07                	jne    801f39 <devcons_read+0x18>
  801f32:	eb 31                	jmp    801f65 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f34:	e8 33 ef ff ff       	call   800e6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	e8 6a ee ff ff       	call   800daf <sys_cgetc>
  801f45:	85 c0                	test   %eax,%eax
  801f47:	74 eb                	je     801f34 <devcons_read+0x13>
  801f49:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 16                	js     801f65 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f4f:	83 f8 04             	cmp    $0x4,%eax
  801f52:	74 0c                	je     801f60 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f57:	88 10                	mov    %dl,(%eax)
	return 1;
  801f59:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5e:	eb 05                	jmp    801f65 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    

00801f67 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f70:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f73:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f7a:	00 
  801f7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7e:	89 04 24             	mov    %eax,(%esp)
  801f81:	e8 fa ed ff ff       	call   800d80 <sys_cputs>
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <getchar>:

int
getchar(void)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f8e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801f95:	00 
  801f96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa4:	e8 05 f6 ff ff       	call   8015ae <read>
	if (r < 0)
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 0f                	js     801fbc <getchar+0x34>
		return r;
	if (r < 1)
  801fad:	85 c0                	test   %eax,%eax
  801faf:	7e 06                	jle    801fb7 <getchar+0x2f>
		return -E_EOF;
	return c;
  801fb1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fb5:	eb 05                	jmp    801fbc <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fb7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    

00801fbe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	89 04 24             	mov    %eax,(%esp)
  801fd1:	e8 18 f3 ff ff       	call   8012ee <fd_lookup>
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	78 11                	js     801feb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdd:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fe3:	39 10                	cmp    %edx,(%eax)
  801fe5:	0f 94 c0             	sete   %al
  801fe8:	0f b6 c0             	movzbl %al,%eax
}
  801feb:	c9                   	leave  
  801fec:	c3                   	ret    

00801fed <opencons>:

int
opencons(void)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff6:	89 04 24             	mov    %eax,(%esp)
  801ff9:	e8 7d f2 ff ff       	call   80127b <fd_alloc>
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 3c                	js     80203e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802002:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802009:	00 
  80200a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802011:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802018:	e8 7f ee ff ff       	call   800e9c <sys_page_alloc>
  80201d:	85 c0                	test   %eax,%eax
  80201f:	78 1d                	js     80203e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802021:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802027:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80202c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802036:	89 04 24             	mov    %eax,(%esp)
  802039:	e8 12 f2 ff ff       	call   801250 <fd2num>
}
  80203e:	c9                   	leave  
  80203f:	c3                   	ret    

00802040 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	56                   	push   %esi
  802044:	53                   	push   %ebx
  802045:	83 ec 10             	sub    $0x10,%esp
  802048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80204b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802051:	85 db                	test   %ebx,%ebx
  802053:	74 06                	je     80205b <ipc_recv+0x1b>
  802055:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80205b:	85 f6                	test   %esi,%esi
  80205d:	74 06                	je     802065 <ipc_recv+0x25>
  80205f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802065:	85 c0                	test   %eax,%eax
  802067:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80206c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80206f:	89 04 24             	mov    %eax,(%esp)
  802072:	e8 8e f0 ff ff       	call   801105 <sys_ipc_recv>
    if (ret) return ret;
  802077:	85 c0                	test   %eax,%eax
  802079:	75 24                	jne    80209f <ipc_recv+0x5f>
    if (from_env_store)
  80207b:	85 db                	test   %ebx,%ebx
  80207d:	74 0a                	je     802089 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80207f:	a1 04 40 80 00       	mov    0x804004,%eax
  802084:	8b 40 74             	mov    0x74(%eax),%eax
  802087:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802089:	85 f6                	test   %esi,%esi
  80208b:	74 0a                	je     802097 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80208d:	a1 04 40 80 00       	mov    0x804004,%eax
  802092:	8b 40 78             	mov    0x78(%eax),%eax
  802095:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802097:	a1 04 40 80 00       	mov    0x804004,%eax
  80209c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	5b                   	pop    %ebx
  8020a3:	5e                   	pop    %esi
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    

008020a6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	57                   	push   %edi
  8020aa:	56                   	push   %esi
  8020ab:	53                   	push   %ebx
  8020ac:	83 ec 1c             	sub    $0x1c,%esp
  8020af:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8020b8:	85 db                	test   %ebx,%ebx
  8020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020bf:	0f 44 d8             	cmove  %eax,%ebx
  8020c2:	eb 2a                	jmp    8020ee <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8020c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c7:	74 20                	je     8020e9 <ipc_send+0x43>
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	c7 44 24 08 aa 29 80 	movl   $0x8029aa,0x8(%esp)
  8020d4:	00 
  8020d5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8020dc:	00 
  8020dd:	c7 04 24 c1 29 80 00 	movl   $0x8029c1,(%esp)
  8020e4:	e8 67 e0 ff ff       	call   800150 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8020e9:	e8 7e ed ff ff       	call   800e6c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8020ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8020f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020fd:	89 34 24             	mov    %esi,(%esp)
  802100:	e8 cc ef ff ff       	call   8010d1 <sys_ipc_try_send>
  802105:	85 c0                	test   %eax,%eax
  802107:	75 bb                	jne    8020c4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802109:	83 c4 1c             	add    $0x1c,%esp
  80210c:	5b                   	pop    %ebx
  80210d:	5e                   	pop    %esi
  80210e:	5f                   	pop    %edi
  80210f:	5d                   	pop    %ebp
  802110:	c3                   	ret    

00802111 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802111:	55                   	push   %ebp
  802112:	89 e5                	mov    %esp,%ebp
  802114:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802117:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80211c:	39 c8                	cmp    %ecx,%eax
  80211e:	74 19                	je     802139 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802120:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802125:	89 c2                	mov    %eax,%edx
  802127:	c1 e2 07             	shl    $0x7,%edx
  80212a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802130:	8b 52 50             	mov    0x50(%edx),%edx
  802133:	39 ca                	cmp    %ecx,%edx
  802135:	75 14                	jne    80214b <ipc_find_env+0x3a>
  802137:	eb 05                	jmp    80213e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802139:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80213e:	c1 e0 07             	shl    $0x7,%eax
  802141:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802146:	8b 40 40             	mov    0x40(%eax),%eax
  802149:	eb 0e                	jmp    802159 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80214b:	83 c0 01             	add    $0x1,%eax
  80214e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802153:	75 d0                	jne    802125 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802155:	66 b8 00 00          	mov    $0x0,%ax
}
  802159:	5d                   	pop    %ebp
  80215a:	c3                   	ret    
	...

0080215c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802162:	89 d0                	mov    %edx,%eax
  802164:	c1 e8 16             	shr    $0x16,%eax
  802167:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80216e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802173:	f6 c1 01             	test   $0x1,%cl
  802176:	74 1d                	je     802195 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802178:	c1 ea 0c             	shr    $0xc,%edx
  80217b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802182:	f6 c2 01             	test   $0x1,%dl
  802185:	74 0e                	je     802195 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802187:	c1 ea 0c             	shr    $0xc,%edx
  80218a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802191:	ef 
  802192:	0f b7 c0             	movzwl %ax,%eax
}
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    
	...

008021a0 <__udivdi3>:
  8021a0:	83 ec 1c             	sub    $0x1c,%esp
  8021a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8021ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8021af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8021b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021bb:	85 ff                	test   %edi,%edi
  8021bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8021c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c5:	89 cd                	mov    %ecx,%ebp
  8021c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021cb:	75 33                	jne    802200 <__udivdi3+0x60>
  8021cd:	39 f1                	cmp    %esi,%ecx
  8021cf:	77 57                	ja     802228 <__udivdi3+0x88>
  8021d1:	85 c9                	test   %ecx,%ecx
  8021d3:	75 0b                	jne    8021e0 <__udivdi3+0x40>
  8021d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8021da:	31 d2                	xor    %edx,%edx
  8021dc:	f7 f1                	div    %ecx
  8021de:	89 c1                	mov    %eax,%ecx
  8021e0:	89 f0                	mov    %esi,%eax
  8021e2:	31 d2                	xor    %edx,%edx
  8021e4:	f7 f1                	div    %ecx
  8021e6:	89 c6                	mov    %eax,%esi
  8021e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021ec:	f7 f1                	div    %ecx
  8021ee:	89 f2                	mov    %esi,%edx
  8021f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	c3                   	ret    
  802200:	31 d2                	xor    %edx,%edx
  802202:	31 c0                	xor    %eax,%eax
  802204:	39 f7                	cmp    %esi,%edi
  802206:	77 e8                	ja     8021f0 <__udivdi3+0x50>
  802208:	0f bd cf             	bsr    %edi,%ecx
  80220b:	83 f1 1f             	xor    $0x1f,%ecx
  80220e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802212:	75 2c                	jne    802240 <__udivdi3+0xa0>
  802214:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802218:	76 04                	jbe    80221e <__udivdi3+0x7e>
  80221a:	39 f7                	cmp    %esi,%edi
  80221c:	73 d2                	jae    8021f0 <__udivdi3+0x50>
  80221e:	31 d2                	xor    %edx,%edx
  802220:	b8 01 00 00 00       	mov    $0x1,%eax
  802225:	eb c9                	jmp    8021f0 <__udivdi3+0x50>
  802227:	90                   	nop
  802228:	89 f2                	mov    %esi,%edx
  80222a:	f7 f1                	div    %ecx
  80222c:	31 d2                	xor    %edx,%edx
  80222e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802232:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802236:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	c3                   	ret    
  80223e:	66 90                	xchg   %ax,%ax
  802240:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802245:	b8 20 00 00 00       	mov    $0x20,%eax
  80224a:	89 ea                	mov    %ebp,%edx
  80224c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802250:	d3 e7                	shl    %cl,%edi
  802252:	89 c1                	mov    %eax,%ecx
  802254:	d3 ea                	shr    %cl,%edx
  802256:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80225b:	09 fa                	or     %edi,%edx
  80225d:	89 f7                	mov    %esi,%edi
  80225f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802263:	89 f2                	mov    %esi,%edx
  802265:	8b 74 24 08          	mov    0x8(%esp),%esi
  802269:	d3 e5                	shl    %cl,%ebp
  80226b:	89 c1                	mov    %eax,%ecx
  80226d:	d3 ef                	shr    %cl,%edi
  80226f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802274:	d3 e2                	shl    %cl,%edx
  802276:	89 c1                	mov    %eax,%ecx
  802278:	d3 ee                	shr    %cl,%esi
  80227a:	09 d6                	or     %edx,%esi
  80227c:	89 fa                	mov    %edi,%edx
  80227e:	89 f0                	mov    %esi,%eax
  802280:	f7 74 24 0c          	divl   0xc(%esp)
  802284:	89 d7                	mov    %edx,%edi
  802286:	89 c6                	mov    %eax,%esi
  802288:	f7 e5                	mul    %ebp
  80228a:	39 d7                	cmp    %edx,%edi
  80228c:	72 22                	jb     8022b0 <__udivdi3+0x110>
  80228e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802292:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802297:	d3 e5                	shl    %cl,%ebp
  802299:	39 c5                	cmp    %eax,%ebp
  80229b:	73 04                	jae    8022a1 <__udivdi3+0x101>
  80229d:	39 d7                	cmp    %edx,%edi
  80229f:	74 0f                	je     8022b0 <__udivdi3+0x110>
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	e9 46 ff ff ff       	jmp    8021f0 <__udivdi3+0x50>
  8022aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	c3                   	ret    
	...

008022d0 <__umoddi3>:
  8022d0:	83 ec 1c             	sub    $0x1c,%esp
  8022d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8022d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8022db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8022df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8022e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8022e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8022eb:	85 ed                	test   %ebp,%ebp
  8022ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8022f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022f5:	89 cf                	mov    %ecx,%edi
  8022f7:	89 04 24             	mov    %eax,(%esp)
  8022fa:	89 f2                	mov    %esi,%edx
  8022fc:	75 1a                	jne    802318 <__umoddi3+0x48>
  8022fe:	39 f1                	cmp    %esi,%ecx
  802300:	76 4e                	jbe    802350 <__umoddi3+0x80>
  802302:	f7 f1                	div    %ecx
  802304:	89 d0                	mov    %edx,%eax
  802306:	31 d2                	xor    %edx,%edx
  802308:	8b 74 24 10          	mov    0x10(%esp),%esi
  80230c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802310:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802314:	83 c4 1c             	add    $0x1c,%esp
  802317:	c3                   	ret    
  802318:	39 f5                	cmp    %esi,%ebp
  80231a:	77 54                	ja     802370 <__umoddi3+0xa0>
  80231c:	0f bd c5             	bsr    %ebp,%eax
  80231f:	83 f0 1f             	xor    $0x1f,%eax
  802322:	89 44 24 04          	mov    %eax,0x4(%esp)
  802326:	75 60                	jne    802388 <__umoddi3+0xb8>
  802328:	3b 0c 24             	cmp    (%esp),%ecx
  80232b:	0f 87 07 01 00 00    	ja     802438 <__umoddi3+0x168>
  802331:	89 f2                	mov    %esi,%edx
  802333:	8b 34 24             	mov    (%esp),%esi
  802336:	29 ce                	sub    %ecx,%esi
  802338:	19 ea                	sbb    %ebp,%edx
  80233a:	89 34 24             	mov    %esi,(%esp)
  80233d:	8b 04 24             	mov    (%esp),%eax
  802340:	8b 74 24 10          	mov    0x10(%esp),%esi
  802344:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802348:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80234c:	83 c4 1c             	add    $0x1c,%esp
  80234f:	c3                   	ret    
  802350:	85 c9                	test   %ecx,%ecx
  802352:	75 0b                	jne    80235f <__umoddi3+0x8f>
  802354:	b8 01 00 00 00       	mov    $0x1,%eax
  802359:	31 d2                	xor    %edx,%edx
  80235b:	f7 f1                	div    %ecx
  80235d:	89 c1                	mov    %eax,%ecx
  80235f:	89 f0                	mov    %esi,%eax
  802361:	31 d2                	xor    %edx,%edx
  802363:	f7 f1                	div    %ecx
  802365:	8b 04 24             	mov    (%esp),%eax
  802368:	f7 f1                	div    %ecx
  80236a:	eb 98                	jmp    802304 <__umoddi3+0x34>
  80236c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 f2                	mov    %esi,%edx
  802372:	8b 74 24 10          	mov    0x10(%esp),%esi
  802376:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80237a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80237e:	83 c4 1c             	add    $0x1c,%esp
  802381:	c3                   	ret    
  802382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802388:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80238d:	89 e8                	mov    %ebp,%eax
  80238f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802394:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802398:	89 fa                	mov    %edi,%edx
  80239a:	d3 e0                	shl    %cl,%eax
  80239c:	89 e9                	mov    %ebp,%ecx
  80239e:	d3 ea                	shr    %cl,%edx
  8023a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023a5:	09 c2                	or     %eax,%edx
  8023a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ab:	89 14 24             	mov    %edx,(%esp)
  8023ae:	89 f2                	mov    %esi,%edx
  8023b0:	d3 e7                	shl    %cl,%edi
  8023b2:	89 e9                	mov    %ebp,%ecx
  8023b4:	d3 ea                	shr    %cl,%edx
  8023b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023bf:	d3 e6                	shl    %cl,%esi
  8023c1:	89 e9                	mov    %ebp,%ecx
  8023c3:	d3 e8                	shr    %cl,%eax
  8023c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023ca:	09 f0                	or     %esi,%eax
  8023cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023d0:	f7 34 24             	divl   (%esp)
  8023d3:	d3 e6                	shl    %cl,%esi
  8023d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023d9:	89 d6                	mov    %edx,%esi
  8023db:	f7 e7                	mul    %edi
  8023dd:	39 d6                	cmp    %edx,%esi
  8023df:	89 c1                	mov    %eax,%ecx
  8023e1:	89 d7                	mov    %edx,%edi
  8023e3:	72 3f                	jb     802424 <__umoddi3+0x154>
  8023e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023e9:	72 35                	jb     802420 <__umoddi3+0x150>
  8023eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ef:	29 c8                	sub    %ecx,%eax
  8023f1:	19 fe                	sbb    %edi,%esi
  8023f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023f8:	89 f2                	mov    %esi,%edx
  8023fa:	d3 e8                	shr    %cl,%eax
  8023fc:	89 e9                	mov    %ebp,%ecx
  8023fe:	d3 e2                	shl    %cl,%edx
  802400:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802405:	09 d0                	or     %edx,%eax
  802407:	89 f2                	mov    %esi,%edx
  802409:	d3 ea                	shr    %cl,%edx
  80240b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80240f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802413:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802417:	83 c4 1c             	add    $0x1c,%esp
  80241a:	c3                   	ret    
  80241b:	90                   	nop
  80241c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802420:	39 d6                	cmp    %edx,%esi
  802422:	75 c7                	jne    8023eb <__umoddi3+0x11b>
  802424:	89 d7                	mov    %edx,%edi
  802426:	89 c1                	mov    %eax,%ecx
  802428:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80242c:	1b 3c 24             	sbb    (%esp),%edi
  80242f:	eb ba                	jmp    8023eb <__umoddi3+0x11b>
  802431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802438:	39 f5                	cmp    %esi,%ebp
  80243a:	0f 82 f1 fe ff ff    	jb     802331 <__umoddi3+0x61>
  802440:	e9 f8 fe ff ff       	jmp    80233d <__umoddi3+0x6d>
