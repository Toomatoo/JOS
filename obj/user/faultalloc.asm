
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800044:	c7 04 24 c0 14 80 00 	movl   $0x8014c0,(%esp)
  80004b:	e8 07 02 00 00       	call   800257 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 3d 0e 00 00       	call   800eac <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 e0 14 80 	movl   $0x8014e0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ca 14 80 00 	movl   $0x8014ca,(%esp)
  800092:	e8 c5 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 0c 15 80 	movl   $0x80150c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 78 08 00 00       	call   80092b <snprintf>
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
  8000c6:	e8 7d 10 00 00       	call   801148 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 dc 14 80 00 	movl   $0x8014dc,(%esp)
  8000da:	e8 78 01 00 00       	call   800257 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 dc 14 80 00 	movl   $0x8014dc,(%esp)
  8000ee:	e8 64 01 00 00       	call   800257 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010a:	e8 3d 0d 00 00       	call   800e4c <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 81 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 95 0c 00 00       	call   800def <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016d:	e8 da 0c 00 00       	call   800e4c <sys_getenvid>
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 54 24 10          	mov    %edx,0x10(%esp)
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800180:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 38 15 80 00 	movl   $0x801538,(%esp)
  80018f:	e8 c3 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	89 74 24 04          	mov    %esi,0x4(%esp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 53 00 00 00       	call   8001f6 <vcprintf>
	cprintf("\n");
  8001a3:	c7 04 24 de 14 80 00 	movl   $0x8014de,(%esp)
  8001aa:	e8 a8 00 00 00       	call   800257 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x53>
	...

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 14             	sub    $0x14,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 03                	mov    (%ebx),%eax
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c7:	83 c0 01             	add    $0x1,%eax
  8001ca:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d1:	75 19                	jne    8001ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001da:	00 
  8001db:	8d 43 08             	lea    0x8(%ebx),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 aa 0b 00 00       	call   800d90 <sys_cputs>
		b->idx = 0;
  8001e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f0:	83 c4 14             	add    $0x14,%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800206:	00 00 00 
	b.cnt = 0;
  800209:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800210:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	c7 04 24 b4 01 80 00 	movl   $0x8001b4,(%esp)
  800232:	e8 97 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800237:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 41 0b 00 00       	call   800d90 <sys_cputs>

	return b.cnt;
}
  80024f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 87 ff ff ff       	call   8001f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    
  800271:	00 00                	add    %al,(%eax)
	...

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 3c             	sub    $0x3c,%esp
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	89 d7                	mov    %edx,%edi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800291:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800294:	b8 00 00 00 00       	mov    $0x0,%eax
  800299:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80029c:	72 11                	jb     8002af <printnum+0x3b>
  80029e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a4:	76 09                	jbe    8002af <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a6:	83 eb 01             	sub    $0x1,%ebx
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f 51                	jg     8002fe <printnum+0x8a>
  8002ad:	eb 5e                	jmp    80030d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b3:	83 eb 01             	sub    $0x1,%ebx
  8002b6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d0:	00 
  8002d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002de:	e8 1d 0f 00 00       	call   801200 <__udivdi3>
  8002e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f2:	89 fa                	mov    %edi,%edx
  8002f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f7:	e8 78 ff ff ff       	call   800274 <printnum>
  8002fc:	eb 0f                	jmp    80030d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800302:	89 34 24             	mov    %esi,(%esp)
  800305:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800308:	83 eb 01             	sub    $0x1,%ebx
  80030b:	75 f1                	jne    8002fe <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800311:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800315:	8b 45 10             	mov    0x10(%ebp),%eax
  800318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800323:	00 
  800324:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	e8 fa 0f 00 00       	call   801330 <__umoddi3>
  800336:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033a:	0f be 80 5b 15 80 00 	movsbl 0x80155b(%eax),%eax
  800341:	89 04 24             	mov    %eax,(%esp)
  800344:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800347:	83 c4 3c             	add    $0x3c,%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039d:	88 0a                	mov    %cl,(%edx)
  80039f:	83 c2 01             	add    $0x1,%edx
  8003a2:	89 10                	mov    %edx,(%eax)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 02 00 00 00       	call   8003ce <vprintfmt>
	va_end(ap);
}
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 5c             	sub    $0x5c,%esp
  8003d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003da:	8b 75 10             	mov    0x10(%ebp),%esi
  8003dd:	eb 12                	jmp    8003f1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	0f 84 e4 04 00 00    	je     8008cb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f1:	0f b6 06             	movzbl (%esi),%eax
  8003f4:	83 c6 01             	add    $0x1,%esi
  8003f7:	83 f8 25             	cmp    $0x25,%eax
  8003fa:	75 e3                	jne    8003df <vprintfmt+0x11>
  8003fc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800400:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800407:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800413:	b9 00 00 00 00       	mov    $0x0,%ecx
  800418:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80041b:	eb 2b                	jmp    800448 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800420:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800424:	eb 22                	jmp    800448 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800429:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80042d:	eb 19                	jmp    800448 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800432:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800439:	eb 0d                	jmp    800448 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80043e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800441:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	0f b6 06             	movzbl (%esi),%eax
  80044b:	0f b6 d0             	movzbl %al,%edx
  80044e:	8d 7e 01             	lea    0x1(%esi),%edi
  800451:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800454:	83 e8 23             	sub    $0x23,%eax
  800457:	3c 55                	cmp    $0x55,%al
  800459:	0f 87 46 04 00 00    	ja     8008a5 <vprintfmt+0x4d7>
  80045f:	0f b6 c0             	movzbl %al,%eax
  800462:	ff 24 85 40 16 80 00 	jmp    *0x801640(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800469:	83 ea 30             	sub    $0x30,%edx
  80046c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80046f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800473:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800479:	83 fa 09             	cmp    $0x9,%edx
  80047c:	77 4a                	ja     8004c8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800481:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800484:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800487:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80048b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80048e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800491:	83 fa 09             	cmp    $0x9,%edx
  800494:	76 eb                	jbe    800481 <vprintfmt+0xb3>
  800496:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800499:	eb 2d                	jmp    8004c8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 50 04             	lea    0x4(%eax),%edx
  8004a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a4:	8b 00                	mov    (%eax),%eax
  8004a6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ac:	eb 1a                	jmp    8004c8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004b1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004b5:	79 91                	jns    800448 <vprintfmt+0x7a>
  8004b7:	e9 73 ff ff ff       	jmp    80042f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bf:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004c6:	eb 80                	jmp    800448 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004cc:	0f 89 76 ff ff ff    	jns    800448 <vprintfmt+0x7a>
  8004d2:	e9 64 ff ff ff       	jmp    80043b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004dd:	e9 66 ff ff ff       	jmp    800448 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 04 24             	mov    %eax,(%esp)
  8004f4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004fa:	e9 f2 fe ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004ff:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800503:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800506:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80050a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80050d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800511:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800514:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800517:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80051b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80051e:	80 f9 09             	cmp    $0x9,%cl
  800521:	77 1d                	ja     800540 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800523:	0f be c0             	movsbl %al,%eax
  800526:	6b c0 64             	imul   $0x64,%eax,%eax
  800529:	0f be d2             	movsbl %dl,%edx
  80052c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80052f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800536:	a3 04 20 80 00       	mov    %eax,0x802004
  80053b:	e9 b1 fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800540:	c7 44 24 04 73 15 80 	movl   $0x801573,0x4(%esp)
  800547:	00 
  800548:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	e8 18 05 00 00       	call   800a6b <strcmp>
  800553:	85 c0                	test   %eax,%eax
  800555:	75 0f                	jne    800566 <vprintfmt+0x198>
  800557:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80055e:	00 00 00 
  800561:	e9 8b fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800566:	c7 44 24 04 77 15 80 	movl   $0x801577,0x4(%esp)
  80056d:	00 
  80056e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800571:	89 14 24             	mov    %edx,(%esp)
  800574:	e8 f2 04 00 00       	call   800a6b <strcmp>
  800579:	85 c0                	test   %eax,%eax
  80057b:	75 0f                	jne    80058c <vprintfmt+0x1be>
  80057d:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800584:	00 00 00 
  800587:	e9 65 fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80058c:	c7 44 24 04 7b 15 80 	movl   $0x80157b,0x4(%esp)
  800593:	00 
  800594:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800597:	89 0c 24             	mov    %ecx,(%esp)
  80059a:	e8 cc 04 00 00       	call   800a6b <strcmp>
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	75 0f                	jne    8005b2 <vprintfmt+0x1e4>
  8005a3:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005aa:	00 00 00 
  8005ad:	e9 3f fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005b2:	c7 44 24 04 7f 15 80 	movl   $0x80157f,0x4(%esp)
  8005b9:	00 
  8005ba:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005bd:	89 3c 24             	mov    %edi,(%esp)
  8005c0:	e8 a6 04 00 00       	call   800a6b <strcmp>
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	75 0f                	jne    8005d8 <vprintfmt+0x20a>
  8005c9:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005d0:	00 00 00 
  8005d3:	e9 19 fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005d8:	c7 44 24 04 83 15 80 	movl   $0x801583,0x4(%esp)
  8005df:	00 
  8005e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 80 04 00 00       	call   800a6b <strcmp>
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	75 0f                	jne    8005fe <vprintfmt+0x230>
  8005ef:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8005f6:	00 00 00 
  8005f9:	e9 f3 fd ff ff       	jmp    8003f1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005fe:	c7 44 24 04 87 15 80 	movl   $0x801587,0x4(%esp)
  800605:	00 
  800606:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800609:	89 14 24             	mov    %edx,(%esp)
  80060c:	e8 5a 04 00 00       	call   800a6b <strcmp>
  800611:	83 f8 01             	cmp    $0x1,%eax
  800614:	19 c0                	sbb    %eax,%eax
  800616:	f7 d0                	not    %eax
  800618:	83 c0 08             	add    $0x8,%eax
  80061b:	a3 04 20 80 00       	mov    %eax,0x802004
  800620:	e9 cc fd ff ff       	jmp    8003f1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 00                	mov    (%eax),%eax
  800630:	89 c2                	mov    %eax,%edx
  800632:	c1 fa 1f             	sar    $0x1f,%edx
  800635:	31 d0                	xor    %edx,%eax
  800637:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800639:	83 f8 08             	cmp    $0x8,%eax
  80063c:	7f 0b                	jg     800649 <vprintfmt+0x27b>
  80063e:	8b 14 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%edx
  800645:	85 d2                	test   %edx,%edx
  800647:	75 23                	jne    80066c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800649:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80064d:	c7 44 24 08 8b 15 80 	movl   $0x80158b,0x8(%esp)
  800654:	00 
  800655:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800659:	8b 7d 08             	mov    0x8(%ebp),%edi
  80065c:	89 3c 24             	mov    %edi,(%esp)
  80065f:	e8 42 fd ff ff       	call   8003a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800667:	e9 85 fd ff ff       	jmp    8003f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80066c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800670:	c7 44 24 08 94 15 80 	movl   $0x801594,0x8(%esp)
  800677:	00 
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80067f:	89 3c 24             	mov    %edi,(%esp)
  800682:	e8 1f fd ff ff       	call   8003a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80068a:	e9 62 fd ff ff       	jmp    8003f1 <vprintfmt+0x23>
  80068f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800692:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800695:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006a3:	85 f6                	test   %esi,%esi
  8006a5:	b8 6c 15 80 00       	mov    $0x80156c,%eax
  8006aa:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006b1:	7e 06                	jle    8006b9 <vprintfmt+0x2eb>
  8006b3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006b7:	75 13                	jne    8006cc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b9:	0f be 06             	movsbl (%esi),%eax
  8006bc:	83 c6 01             	add    $0x1,%esi
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	0f 85 94 00 00 00    	jne    80075b <vprintfmt+0x38d>
  8006c7:	e9 81 00 00 00       	jmp    80074d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d0:	89 34 24             	mov    %esi,(%esp)
  8006d3:	e8 a3 02 00 00       	call   80097b <strnlen>
  8006d8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006db:	29 c2                	sub    %eax,%edx
  8006dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006e0:	85 d2                	test   %edx,%edx
  8006e2:	7e d5                	jle    8006b9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006e4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006e8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006eb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006ee:	89 d6                	mov    %edx,%esi
  8006f0:	89 cf                	mov    %ecx,%edi
  8006f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f6:	89 3c 24             	mov    %edi,(%esp)
  8006f9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	83 ee 01             	sub    $0x1,%esi
  8006ff:	75 f1                	jne    8006f2 <vprintfmt+0x324>
  800701:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800704:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800707:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80070a:	eb ad                	jmp    8006b9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80070c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800710:	74 1b                	je     80072d <vprintfmt+0x35f>
  800712:	8d 50 e0             	lea    -0x20(%eax),%edx
  800715:	83 fa 5e             	cmp    $0x5e,%edx
  800718:	76 13                	jbe    80072d <vprintfmt+0x35f>
					putch('?', putdat);
  80071a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800721:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800728:	ff 55 08             	call   *0x8(%ebp)
  80072b:	eb 0d                	jmp    80073a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80072d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800730:	89 54 24 04          	mov    %edx,0x4(%esp)
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073a:	83 eb 01             	sub    $0x1,%ebx
  80073d:	0f be 06             	movsbl (%esi),%eax
  800740:	83 c6 01             	add    $0x1,%esi
  800743:	85 c0                	test   %eax,%eax
  800745:	75 1a                	jne    800761 <vprintfmt+0x393>
  800747:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80074a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800750:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800754:	7f 1c                	jg     800772 <vprintfmt+0x3a4>
  800756:	e9 96 fc ff ff       	jmp    8003f1 <vprintfmt+0x23>
  80075b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80075e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800761:	85 ff                	test   %edi,%edi
  800763:	78 a7                	js     80070c <vprintfmt+0x33e>
  800765:	83 ef 01             	sub    $0x1,%edi
  800768:	79 a2                	jns    80070c <vprintfmt+0x33e>
  80076a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80076d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800770:	eb db                	jmp    80074d <vprintfmt+0x37f>
  800772:	8b 7d 08             	mov    0x8(%ebp),%edi
  800775:	89 de                	mov    %ebx,%esi
  800777:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800785:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800787:	83 eb 01             	sub    $0x1,%ebx
  80078a:	75 ee                	jne    80077a <vprintfmt+0x3ac>
  80078c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800791:	e9 5b fc ff ff       	jmp    8003f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800796:	83 f9 01             	cmp    $0x1,%ecx
  800799:	7e 10                	jle    8007ab <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 50 08             	lea    0x8(%eax),%edx
  8007a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a4:	8b 30                	mov    (%eax),%esi
  8007a6:	8b 78 04             	mov    0x4(%eax),%edi
  8007a9:	eb 26                	jmp    8007d1 <vprintfmt+0x403>
	else if (lflag)
  8007ab:	85 c9                	test   %ecx,%ecx
  8007ad:	74 12                	je     8007c1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b8:	8b 30                	mov    (%eax),%esi
  8007ba:	89 f7                	mov    %esi,%edi
  8007bc:	c1 ff 1f             	sar    $0x1f,%edi
  8007bf:	eb 10                	jmp    8007d1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 04             	lea    0x4(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 30                	mov    (%eax),%esi
  8007cc:	89 f7                	mov    %esi,%edi
  8007ce:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d1:	85 ff                	test   %edi,%edi
  8007d3:	78 0e                	js     8007e3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d9:	be 0a 00 00 00       	mov    $0xa,%esi
  8007de:	e9 84 00 00 00       	jmp    800867 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	89 fa                	mov    %edi,%edx
  8007f5:	f7 d8                	neg    %eax
  8007f7:	83 d2 00             	adc    $0x0,%edx
  8007fa:	f7 da                	neg    %edx
			}
			base = 10;
  8007fc:	be 0a 00 00 00       	mov    $0xa,%esi
  800801:	eb 64                	jmp    800867 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800803:	89 ca                	mov    %ecx,%edx
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	e8 42 fb ff ff       	call   80034f <getuint>
			base = 10;
  80080d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800812:	eb 53                	jmp    800867 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800814:	89 ca                	mov    %ecx,%edx
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
  800819:	e8 31 fb ff ff       	call   80034f <getuint>
    			base = 8;
  80081e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800823:	eb 42                	jmp    800867 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800825:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800829:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800830:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800833:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800837:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80083e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8d 50 04             	lea    0x4(%eax),%edx
  800847:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80084a:	8b 00                	mov    (%eax),%eax
  80084c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800851:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800856:	eb 0f                	jmp    800867 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800858:	89 ca                	mov    %ecx,%edx
  80085a:	8d 45 14             	lea    0x14(%ebp),%eax
  80085d:	e8 ed fa ff ff       	call   80034f <getuint>
			base = 16;
  800862:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800867:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80086b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80086f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800872:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800876:	89 74 24 08          	mov    %esi,0x8(%esp)
  80087a:	89 04 24             	mov    %eax,(%esp)
  80087d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800881:	89 da                	mov    %ebx,%edx
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	e8 e9 f9 ff ff       	call   800274 <printnum>
			break;
  80088b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80088e:	e9 5e fb ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800893:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800897:	89 14 24             	mov    %edx,(%esp)
  80089a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a0:	e9 4c fb ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008b7:	0f 84 34 fb ff ff    	je     8003f1 <vprintfmt+0x23>
  8008bd:	83 ee 01             	sub    $0x1,%esi
  8008c0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008c4:	75 f7                	jne    8008bd <vprintfmt+0x4ef>
  8008c6:	e9 26 fb ff ff       	jmp    8003f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008cb:	83 c4 5c             	add    $0x5c,%esp
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5f                   	pop    %edi
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	83 ec 28             	sub    $0x28,%esp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f0:	85 c0                	test   %eax,%eax
  8008f2:	74 30                	je     800924 <vsnprintf+0x51>
  8008f4:	85 d2                	test   %edx,%edx
  8008f6:	7e 2c                	jle    800924 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800902:	89 44 24 08          	mov    %eax,0x8(%esp)
  800906:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090d:	c7 04 24 89 03 80 00 	movl   $0x800389,(%esp)
  800914:	e8 b5 fa ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800919:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800922:	eb 05                	jmp    800929 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800924:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800931:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800934:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800938:	8b 45 10             	mov    0x10(%ebp),%eax
  80093b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	89 44 24 04          	mov    %eax,0x4(%esp)
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	89 04 24             	mov    %eax,(%esp)
  80094c:	e8 82 ff ff ff       	call   8008d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    
	...

00800960 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	80 3a 00             	cmpb   $0x0,(%edx)
  80096e:	74 09                	je     800979 <strlen+0x19>
		n++;
  800970:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800973:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800977:	75 f7                	jne    800970 <strlen+0x10>
		n++;
	return n;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
  80098a:	85 c9                	test   %ecx,%ecx
  80098c:	74 1a                	je     8009a8 <strnlen+0x2d>
  80098e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800991:	74 15                	je     8009a8 <strnlen+0x2d>
  800993:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800998:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099a:	39 ca                	cmp    %ecx,%edx
  80099c:	74 0a                	je     8009a8 <strnlen+0x2d>
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009a6:	75 f0                	jne    800998 <strnlen+0x1d>
		n++;
	return n;
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009be:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009c1:	83 c2 01             	add    $0x1,%edx
  8009c4:	84 c9                	test   %cl,%cl
  8009c6:	75 f2                	jne    8009ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 08             	sub    $0x8,%esp
  8009d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d5:	89 1c 24             	mov    %ebx,(%esp)
  8009d8:	e8 83 ff ff ff       	call   800960 <strlen>
	strcpy(dst + len, src);
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e4:	01 d8                	add    %ebx,%eax
  8009e6:	89 04 24             	mov    %eax,(%esp)
  8009e9:	e8 bd ff ff ff       	call   8009ab <strcpy>
	return dst;
}
  8009ee:	89 d8                	mov    %ebx,%eax
  8009f0:	83 c4 08             	add    $0x8,%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a04:	85 f6                	test   %esi,%esi
  800a06:	74 18                	je     800a20 <strncpy+0x2a>
  800a08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a0d:	0f b6 1a             	movzbl (%edx),%ebx
  800a10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a13:	80 3a 01             	cmpb   $0x1,(%edx)
  800a16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	39 f1                	cmp    %esi,%ecx
  800a1e:	75 ed                	jne    800a0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a33:	89 f8                	mov    %edi,%eax
  800a35:	85 f6                	test   %esi,%esi
  800a37:	74 2b                	je     800a64 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a39:	83 fe 01             	cmp    $0x1,%esi
  800a3c:	74 23                	je     800a61 <strlcpy+0x3d>
  800a3e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a41:	84 c9                	test   %cl,%cl
  800a43:	74 1c                	je     800a61 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a45:	83 ee 02             	sub    $0x2,%esi
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a4d:	88 08                	mov    %cl,(%eax)
  800a4f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a52:	39 f2                	cmp    %esi,%edx
  800a54:	74 0b                	je     800a61 <strlcpy+0x3d>
  800a56:	83 c2 01             	add    $0x1,%edx
  800a59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a5d:	84 c9                	test   %cl,%cl
  800a5f:	75 ec                	jne    800a4d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a61:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a64:	29 f8                	sub    %edi,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	84 c0                	test   %al,%al
  800a79:	74 16                	je     800a91 <strcmp+0x26>
  800a7b:	3a 02                	cmp    (%edx),%al
  800a7d:	75 12                	jne    800a91 <strcmp+0x26>
		p++, q++;
  800a7f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a82:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a86:	84 c0                	test   %al,%al
  800a88:	74 07                	je     800a91 <strcmp+0x26>
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	3a 02                	cmp    (%edx),%al
  800a8f:	74 ee                	je     800a7f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a91:	0f b6 c0             	movzbl %al,%eax
  800a94:	0f b6 12             	movzbl (%edx),%edx
  800a97:	29 d0                	sub    %edx,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aad:	85 d2                	test   %edx,%edx
  800aaf:	74 28                	je     800ad9 <strncmp+0x3e>
  800ab1:	0f b6 01             	movzbl (%ecx),%eax
  800ab4:	84 c0                	test   %al,%al
  800ab6:	74 24                	je     800adc <strncmp+0x41>
  800ab8:	3a 03                	cmp    (%ebx),%al
  800aba:	75 20                	jne    800adc <strncmp+0x41>
  800abc:	83 ea 01             	sub    $0x1,%edx
  800abf:	74 13                	je     800ad4 <strncmp+0x39>
		n--, p++, q++;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac7:	0f b6 01             	movzbl (%ecx),%eax
  800aca:	84 c0                	test   %al,%al
  800acc:	74 0e                	je     800adc <strncmp+0x41>
  800ace:	3a 03                	cmp    (%ebx),%al
  800ad0:	74 ea                	je     800abc <strncmp+0x21>
  800ad2:	eb 08                	jmp    800adc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800adc:	0f b6 01             	movzbl (%ecx),%eax
  800adf:	0f b6 13             	movzbl (%ebx),%edx
  800ae2:	29 d0                	sub    %edx,%eax
  800ae4:	eb f3                	jmp    800ad9 <strncmp+0x3e>

00800ae6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af0:	0f b6 10             	movzbl (%eax),%edx
  800af3:	84 d2                	test   %dl,%dl
  800af5:	74 1c                	je     800b13 <strchr+0x2d>
		if (*s == c)
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	75 09                	jne    800b04 <strchr+0x1e>
  800afb:	eb 1b                	jmp    800b18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b00:	38 ca                	cmp    %cl,%dl
  800b02:	74 14                	je     800b18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b04:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	75 f1                	jne    800afd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	eb 05                	jmp    800b18 <strchr+0x32>
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b24:	0f b6 10             	movzbl (%eax),%edx
  800b27:	84 d2                	test   %dl,%dl
  800b29:	74 14                	je     800b3f <strfind+0x25>
		if (*s == c)
  800b2b:	38 ca                	cmp    %cl,%dl
  800b2d:	75 06                	jne    800b35 <strfind+0x1b>
  800b2f:	eb 0e                	jmp    800b3f <strfind+0x25>
  800b31:	38 ca                	cmp    %cl,%dl
  800b33:	74 0a                	je     800b3f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	0f b6 10             	movzbl (%eax),%edx
  800b3b:	84 d2                	test   %dl,%dl
  800b3d:	75 f2                	jne    800b31 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 0c             	sub    $0xc,%esp
  800b47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b59:	85 c9                	test   %ecx,%ecx
  800b5b:	74 30                	je     800b8d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b63:	75 25                	jne    800b8a <memset+0x49>
  800b65:	f6 c1 03             	test   $0x3,%cl
  800b68:	75 20                	jne    800b8a <memset+0x49>
		c &= 0xFF;
  800b6a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	c1 e3 08             	shl    $0x8,%ebx
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	c1 e6 18             	shl    $0x18,%esi
  800b77:	89 d0                	mov    %edx,%eax
  800b79:	c1 e0 10             	shl    $0x10,%eax
  800b7c:	09 f0                	or     %esi,%eax
  800b7e:	09 d0                	or     %edx,%eax
  800b80:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b82:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b85:	fc                   	cld    
  800b86:	f3 ab                	rep stos %eax,%es:(%edi)
  800b88:	eb 03                	jmp    800b8d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8a:	fc                   	cld    
  800b8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b8d:	89 f8                	mov    %edi,%eax
  800b8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b98:	89 ec                	mov    %ebp,%esp
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb1:	39 c6                	cmp    %eax,%esi
  800bb3:	73 36                	jae    800beb <memmove+0x4f>
  800bb5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb8:	39 d0                	cmp    %edx,%eax
  800bba:	73 2f                	jae    800beb <memmove+0x4f>
		s += n;
		d += n;
  800bbc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbf:	f6 c2 03             	test   $0x3,%dl
  800bc2:	75 1b                	jne    800bdf <memmove+0x43>
  800bc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bca:	75 13                	jne    800bdf <memmove+0x43>
  800bcc:	f6 c1 03             	test   $0x3,%cl
  800bcf:	75 0e                	jne    800bdf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd1:	83 ef 04             	sub    $0x4,%edi
  800bd4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bda:	fd                   	std    
  800bdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bdd:	eb 09                	jmp    800be8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bdf:	83 ef 01             	sub    $0x1,%edi
  800be2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be5:	fd                   	std    
  800be6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be8:	fc                   	cld    
  800be9:	eb 20                	jmp    800c0b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800beb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf1:	75 13                	jne    800c06 <memmove+0x6a>
  800bf3:	a8 03                	test   $0x3,%al
  800bf5:	75 0f                	jne    800c06 <memmove+0x6a>
  800bf7:	f6 c1 03             	test   $0x3,%cl
  800bfa:	75 0a                	jne    800c06 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bfc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bff:	89 c7                	mov    %eax,%edi
  800c01:	fc                   	cld    
  800c02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c04:	eb 05                	jmp    800c0b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c06:	89 c7                	mov    %eax,%edi
  800c08:	fc                   	cld    
  800c09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c11:	89 ec                	mov    %ebp,%esp
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2c:	89 04 24             	mov    %eax,(%esp)
  800c2f:	e8 68 ff ff ff       	call   800b9c <memmove>
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c42:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4a:	85 ff                	test   %edi,%edi
  800c4c:	74 37                	je     800c85 <memcmp+0x4f>
		if (*s1 != *s2)
  800c4e:	0f b6 03             	movzbl (%ebx),%eax
  800c51:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c54:	83 ef 01             	sub    $0x1,%edi
  800c57:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c5c:	38 c8                	cmp    %cl,%al
  800c5e:	74 1c                	je     800c7c <memcmp+0x46>
  800c60:	eb 10                	jmp    800c72 <memcmp+0x3c>
  800c62:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c67:	83 c2 01             	add    $0x1,%edx
  800c6a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c6e:	38 c8                	cmp    %cl,%al
  800c70:	74 0a                	je     800c7c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c72:	0f b6 c0             	movzbl %al,%eax
  800c75:	0f b6 c9             	movzbl %cl,%ecx
  800c78:	29 c8                	sub    %ecx,%eax
  800c7a:	eb 09                	jmp    800c85 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7c:	39 fa                	cmp    %edi,%edx
  800c7e:	75 e2                	jne    800c62 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c95:	39 d0                	cmp    %edx,%eax
  800c97:	73 19                	jae    800cb2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c9d:	38 08                	cmp    %cl,(%eax)
  800c9f:	75 06                	jne    800ca7 <memfind+0x1d>
  800ca1:	eb 0f                	jmp    800cb2 <memfind+0x28>
  800ca3:	38 08                	cmp    %cl,(%eax)
  800ca5:	74 0b                	je     800cb2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca7:	83 c0 01             	add    $0x1,%eax
  800caa:	39 d0                	cmp    %edx,%eax
  800cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	75 f1                	jne    800ca3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc0:	0f b6 02             	movzbl (%edx),%eax
  800cc3:	3c 20                	cmp    $0x20,%al
  800cc5:	74 04                	je     800ccb <strtol+0x17>
  800cc7:	3c 09                	cmp    $0x9,%al
  800cc9:	75 0e                	jne    800cd9 <strtol+0x25>
		s++;
  800ccb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cce:	0f b6 02             	movzbl (%edx),%eax
  800cd1:	3c 20                	cmp    $0x20,%al
  800cd3:	74 f6                	je     800ccb <strtol+0x17>
  800cd5:	3c 09                	cmp    $0x9,%al
  800cd7:	74 f2                	je     800ccb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cd9:	3c 2b                	cmp    $0x2b,%al
  800cdb:	75 0a                	jne    800ce7 <strtol+0x33>
		s++;
  800cdd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce5:	eb 10                	jmp    800cf7 <strtol+0x43>
  800ce7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cec:	3c 2d                	cmp    $0x2d,%al
  800cee:	75 07                	jne    800cf7 <strtol+0x43>
		s++, neg = 1;
  800cf0:	83 c2 01             	add    $0x1,%edx
  800cf3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	0f 94 c0             	sete   %al
  800cfc:	74 05                	je     800d03 <strtol+0x4f>
  800cfe:	83 fb 10             	cmp    $0x10,%ebx
  800d01:	75 15                	jne    800d18 <strtol+0x64>
  800d03:	80 3a 30             	cmpb   $0x30,(%edx)
  800d06:	75 10                	jne    800d18 <strtol+0x64>
  800d08:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d0c:	75 0a                	jne    800d18 <strtol+0x64>
		s += 2, base = 16;
  800d0e:	83 c2 02             	add    $0x2,%edx
  800d11:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d16:	eb 13                	jmp    800d2b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d18:	84 c0                	test   %al,%al
  800d1a:	74 0f                	je     800d2b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d21:	80 3a 30             	cmpb   $0x30,(%edx)
  800d24:	75 05                	jne    800d2b <strtol+0x77>
		s++, base = 8;
  800d26:	83 c2 01             	add    $0x1,%edx
  800d29:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d32:	0f b6 0a             	movzbl (%edx),%ecx
  800d35:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d38:	80 fb 09             	cmp    $0x9,%bl
  800d3b:	77 08                	ja     800d45 <strtol+0x91>
			dig = *s - '0';
  800d3d:	0f be c9             	movsbl %cl,%ecx
  800d40:	83 e9 30             	sub    $0x30,%ecx
  800d43:	eb 1e                	jmp    800d63 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d45:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d48:	80 fb 19             	cmp    $0x19,%bl
  800d4b:	77 08                	ja     800d55 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d4d:	0f be c9             	movsbl %cl,%ecx
  800d50:	83 e9 57             	sub    $0x57,%ecx
  800d53:	eb 0e                	jmp    800d63 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d55:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d58:	80 fb 19             	cmp    $0x19,%bl
  800d5b:	77 14                	ja     800d71 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d5d:	0f be c9             	movsbl %cl,%ecx
  800d60:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d63:	39 f1                	cmp    %esi,%ecx
  800d65:	7d 0e                	jge    800d75 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d67:	83 c2 01             	add    $0x1,%edx
  800d6a:	0f af c6             	imul   %esi,%eax
  800d6d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d6f:	eb c1                	jmp    800d32 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d71:	89 c1                	mov    %eax,%ecx
  800d73:	eb 02                	jmp    800d77 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d75:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d7b:	74 05                	je     800d82 <strtol+0xce>
		*endptr = (char *) s;
  800d7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d80:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d82:	89 ca                	mov    %ecx,%edx
  800d84:	f7 da                	neg    %edx
  800d86:	85 ff                	test   %edi,%edi
  800d88:	0f 45 c2             	cmovne %edx,%eax
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	89 c7                	mov    %eax,%edi
  800dae:	89 c6                	mov    %eax,%esi
  800db0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800db2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbb:	89 ec                	mov    %ebp,%esp
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd8:	89 d1                	mov    %edx,%ecx
  800dda:	89 d3                	mov    %edx,%ebx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	89 d6                	mov    %edx,%esi
  800de0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 38             	sub    $0x38,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e03:	b8 03 00 00 00       	mov    $0x3,%eax
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	89 cb                	mov    %ecx,%ebx
  800e0d:	89 cf                	mov    %ecx,%edi
  800e0f:	89 ce                	mov    %ecx,%esi
  800e11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 28                	jle    800e3f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800e3a:	e8 1d f3 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e48:	89 ec                	mov    %ebp,%esp
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 0c             	sub    $0xc,%esp
  800e52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e60:	b8 02 00 00 00       	mov    $0x2,%eax
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 d3                	mov    %edx,%ebx
  800e69:	89 d7                	mov    %edx,%edi
  800e6b:	89 d6                	mov    %edx,%esi
  800e6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_yield>:

void
sys_yield(void)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 d3                	mov    %edx,%ebx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 38             	sub    $0x38,%esp
  800eb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	be 00 00 00 00       	mov    $0x0,%esi
  800ec0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	89 f7                	mov    %esi,%edi
  800ed0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	7e 28                	jle    800efe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eda:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef1:	00 
  800ef2:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800ef9:	e8 5e f2 ff ff       	call   80015c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800efe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f01:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f04:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f07:	89 ec                	mov    %ebp,%esp
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 38             	sub    $0x38,%esp
  800f11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f30:	85 c0                	test   %eax,%eax
  800f32:	7e 28                	jle    800f5c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f3f:	00 
  800f40:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800f47:	00 
  800f48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4f:	00 
  800f50:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800f57:	e8 00 f2 ff ff       	call   80015c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f5c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f62:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f65:	89 ec                	mov    %ebp,%esp
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 38             	sub    $0x38,%esp
  800f6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f75:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	89 df                	mov    %ebx,%edi
  800f8a:	89 de                	mov    %ebx,%esi
  800f8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	7e 28                	jle    800fba <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f96:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800fa5:	00 
  800fa6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fad:	00 
  800fae:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800fb5:	e8 a2 f1 ff ff       	call   80015c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc3:	89 ec                	mov    %ebp,%esp
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 38             	sub    $0x38,%esp
  800fcd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	89 df                	mov    %ebx,%edi
  800fe8:	89 de                	mov    %ebx,%esi
  800fea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	7e 28                	jle    801018 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  801003:	00 
  801004:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100b:	00 
  80100c:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801013:	e8 44 f1 ff ff       	call   80015c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801018:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801021:	89 ec                	mov    %ebp,%esp
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 38             	sub    $0x38,%esp
  80102b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801031:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801034:	bb 00 00 00 00       	mov    $0x0,%ebx
  801039:	b8 09 00 00 00       	mov    $0x9,%eax
  80103e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801041:	8b 55 08             	mov    0x8(%ebp),%edx
  801044:	89 df                	mov    %ebx,%edi
  801046:	89 de                	mov    %ebx,%esi
  801048:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104a:	85 c0                	test   %eax,%eax
  80104c:	7e 28                	jle    801076 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801052:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801059:	00 
  80105a:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  801061:	00 
  801062:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801069:	00 
  80106a:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801071:	e8 e6 f0 ff ff       	call   80015c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801076:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801079:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107f:	89 ec                	mov    %ebp,%esp
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80108f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801092:	be 00 00 00 00       	mov    $0x0,%esi
  801097:	b8 0b 00 00 00       	mov    $0xb,%eax
  80109c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80109f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010aa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b3:	89 ec                	mov    %ebp,%esp
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  8010c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010cb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d3:	89 cb                	mov    %ecx,%ebx
  8010d5:	89 cf                	mov    %ecx,%edi
  8010d7:	89 ce                	mov    %ecx,%esi
  8010d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	7e 28                	jle    801107 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8010ea:	00 
  8010eb:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801102:	e8 55 f0 ff ff       	call   80015c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801107:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80110a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801110:	89 ec                	mov    %ebp,%esp
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801120:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801123:	b9 00 00 00 00       	mov    $0x0,%ecx
  801128:	b8 0d 00 00 00       	mov    $0xd,%eax
  80112d:	8b 55 08             	mov    0x8(%ebp),%edx
  801130:	89 cb                	mov    %ecx,%ebx
  801132:	89 cf                	mov    %ecx,%edi
  801134:	89 ce                	mov    %ecx,%esi
  801136:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  801138:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80113b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801141:	89 ec                	mov    %ebp,%esp
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    
  801145:	00 00                	add    %al,(%eax)
	...

00801148 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80114e:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801155:	75 3c                	jne    801193 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801157:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801166:	ee 
  801167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116e:	e8 39 fd ff ff       	call   800eac <sys_page_alloc>
  801173:	85 c0                	test   %eax,%eax
  801175:	79 1c                	jns    801193 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801177:	c7 44 24 08 f0 17 80 	movl   $0x8017f0,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 54 18 80 00 	movl   $0x801854,(%esp)
  80118e:	e8 c9 ef ff ff       	call   80015c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80119b:	c7 44 24 04 d4 11 80 	movl   $0x8011d4,0x4(%esp)
  8011a2:	00 
  8011a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011aa:	e8 76 fe ff ff       	call   801025 <sys_env_set_pgfault_upcall>
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	79 1c                	jns    8011cf <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8011b3:	c7 44 24 08 1c 18 80 	movl   $0x80181c,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 54 18 80 00 	movl   $0x801854,(%esp)
  8011ca:	e8 8d ef ff ff       	call   80015c <_panic>
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    
  8011d1:	00 00                	add    %al,(%eax)
	...

008011d4 <_pgfault_upcall>:
  8011d4:	54                   	push   %esp
  8011d5:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011da:	ff d0                	call   *%eax
  8011dc:	83 c4 04             	add    $0x4,%esp
  8011df:	8b 54 24 28          	mov    0x28(%esp),%edx
  8011e3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  8011e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8011ec:	89 10                	mov    %edx,(%eax)
  8011ee:	83 c4 08             	add    $0x8,%esp
  8011f1:	61                   	popa   
  8011f2:	83 c4 04             	add    $0x4,%esp
  8011f5:	9d                   	popf   
  8011f6:	5c                   	pop    %esp
  8011f7:	c3                   	ret    
	...

00801200 <__udivdi3>:
  801200:	83 ec 1c             	sub    $0x1c,%esp
  801203:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801207:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80120b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80120f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801213:	89 74 24 10          	mov    %esi,0x10(%esp)
  801217:	8b 74 24 24          	mov    0x24(%esp),%esi
  80121b:	85 ff                	test   %edi,%edi
  80121d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801221:	89 44 24 08          	mov    %eax,0x8(%esp)
  801225:	89 cd                	mov    %ecx,%ebp
  801227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122b:	75 33                	jne    801260 <__udivdi3+0x60>
  80122d:	39 f1                	cmp    %esi,%ecx
  80122f:	77 57                	ja     801288 <__udivdi3+0x88>
  801231:	85 c9                	test   %ecx,%ecx
  801233:	75 0b                	jne    801240 <__udivdi3+0x40>
  801235:	b8 01 00 00 00       	mov    $0x1,%eax
  80123a:	31 d2                	xor    %edx,%edx
  80123c:	f7 f1                	div    %ecx
  80123e:	89 c1                	mov    %eax,%ecx
  801240:	89 f0                	mov    %esi,%eax
  801242:	31 d2                	xor    %edx,%edx
  801244:	f7 f1                	div    %ecx
  801246:	89 c6                	mov    %eax,%esi
  801248:	8b 44 24 04          	mov    0x4(%esp),%eax
  80124c:	f7 f1                	div    %ecx
  80124e:	89 f2                	mov    %esi,%edx
  801250:	8b 74 24 10          	mov    0x10(%esp),%esi
  801254:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801258:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80125c:	83 c4 1c             	add    $0x1c,%esp
  80125f:	c3                   	ret    
  801260:	31 d2                	xor    %edx,%edx
  801262:	31 c0                	xor    %eax,%eax
  801264:	39 f7                	cmp    %esi,%edi
  801266:	77 e8                	ja     801250 <__udivdi3+0x50>
  801268:	0f bd cf             	bsr    %edi,%ecx
  80126b:	83 f1 1f             	xor    $0x1f,%ecx
  80126e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801272:	75 2c                	jne    8012a0 <__udivdi3+0xa0>
  801274:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801278:	76 04                	jbe    80127e <__udivdi3+0x7e>
  80127a:	39 f7                	cmp    %esi,%edi
  80127c:	73 d2                	jae    801250 <__udivdi3+0x50>
  80127e:	31 d2                	xor    %edx,%edx
  801280:	b8 01 00 00 00       	mov    $0x1,%eax
  801285:	eb c9                	jmp    801250 <__udivdi3+0x50>
  801287:	90                   	nop
  801288:	89 f2                	mov    %esi,%edx
  80128a:	f7 f1                	div    %ecx
  80128c:	31 d2                	xor    %edx,%edx
  80128e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801292:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801296:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80129a:	83 c4 1c             	add    $0x1c,%esp
  80129d:	c3                   	ret    
  80129e:	66 90                	xchg   %ax,%ax
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	b8 20 00 00 00       	mov    $0x20,%eax
  8012aa:	89 ea                	mov    %ebp,%edx
  8012ac:	2b 44 24 04          	sub    0x4(%esp),%eax
  8012b0:	d3 e7                	shl    %cl,%edi
  8012b2:	89 c1                	mov    %eax,%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012bb:	09 fa                	or     %edi,%edx
  8012bd:	89 f7                	mov    %esi,%edi
  8012bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012c3:	89 f2                	mov    %esi,%edx
  8012c5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012c9:	d3 e5                	shl    %cl,%ebp
  8012cb:	89 c1                	mov    %eax,%ecx
  8012cd:	d3 ef                	shr    %cl,%edi
  8012cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d4:	d3 e2                	shl    %cl,%edx
  8012d6:	89 c1                	mov    %eax,%ecx
  8012d8:	d3 ee                	shr    %cl,%esi
  8012da:	09 d6                	or     %edx,%esi
  8012dc:	89 fa                	mov    %edi,%edx
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	f7 74 24 0c          	divl   0xc(%esp)
  8012e4:	89 d7                	mov    %edx,%edi
  8012e6:	89 c6                	mov    %eax,%esi
  8012e8:	f7 e5                	mul    %ebp
  8012ea:	39 d7                	cmp    %edx,%edi
  8012ec:	72 22                	jb     801310 <__udivdi3+0x110>
  8012ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8012f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f7:	d3 e5                	shl    %cl,%ebp
  8012f9:	39 c5                	cmp    %eax,%ebp
  8012fb:	73 04                	jae    801301 <__udivdi3+0x101>
  8012fd:	39 d7                	cmp    %edx,%edi
  8012ff:	74 0f                	je     801310 <__udivdi3+0x110>
  801301:	89 f0                	mov    %esi,%eax
  801303:	31 d2                	xor    %edx,%edx
  801305:	e9 46 ff ff ff       	jmp    801250 <__udivdi3+0x50>
  80130a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801310:	8d 46 ff             	lea    -0x1(%esi),%eax
  801313:	31 d2                	xor    %edx,%edx
  801315:	8b 74 24 10          	mov    0x10(%esp),%esi
  801319:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80131d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801321:	83 c4 1c             	add    $0x1c,%esp
  801324:	c3                   	ret    
	...

00801330 <__umoddi3>:
  801330:	83 ec 1c             	sub    $0x1c,%esp
  801333:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801337:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80133b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80133f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801343:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801347:	8b 74 24 24          	mov    0x24(%esp),%esi
  80134b:	85 ed                	test   %ebp,%ebp
  80134d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801351:	89 44 24 08          	mov    %eax,0x8(%esp)
  801355:	89 cf                	mov    %ecx,%edi
  801357:	89 04 24             	mov    %eax,(%esp)
  80135a:	89 f2                	mov    %esi,%edx
  80135c:	75 1a                	jne    801378 <__umoddi3+0x48>
  80135e:	39 f1                	cmp    %esi,%ecx
  801360:	76 4e                	jbe    8013b0 <__umoddi3+0x80>
  801362:	f7 f1                	div    %ecx
  801364:	89 d0                	mov    %edx,%eax
  801366:	31 d2                	xor    %edx,%edx
  801368:	8b 74 24 10          	mov    0x10(%esp),%esi
  80136c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801370:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801374:	83 c4 1c             	add    $0x1c,%esp
  801377:	c3                   	ret    
  801378:	39 f5                	cmp    %esi,%ebp
  80137a:	77 54                	ja     8013d0 <__umoddi3+0xa0>
  80137c:	0f bd c5             	bsr    %ebp,%eax
  80137f:	83 f0 1f             	xor    $0x1f,%eax
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	75 60                	jne    8013e8 <__umoddi3+0xb8>
  801388:	3b 0c 24             	cmp    (%esp),%ecx
  80138b:	0f 87 07 01 00 00    	ja     801498 <__umoddi3+0x168>
  801391:	89 f2                	mov    %esi,%edx
  801393:	8b 34 24             	mov    (%esp),%esi
  801396:	29 ce                	sub    %ecx,%esi
  801398:	19 ea                	sbb    %ebp,%edx
  80139a:	89 34 24             	mov    %esi,(%esp)
  80139d:	8b 04 24             	mov    (%esp),%eax
  8013a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013ac:	83 c4 1c             	add    $0x1c,%esp
  8013af:	c3                   	ret    
  8013b0:	85 c9                	test   %ecx,%ecx
  8013b2:	75 0b                	jne    8013bf <__umoddi3+0x8f>
  8013b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b9:	31 d2                	xor    %edx,%edx
  8013bb:	f7 f1                	div    %ecx
  8013bd:	89 c1                	mov    %eax,%ecx
  8013bf:	89 f0                	mov    %esi,%eax
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	f7 f1                	div    %ecx
  8013c5:	8b 04 24             	mov    (%esp),%eax
  8013c8:	f7 f1                	div    %ecx
  8013ca:	eb 98                	jmp    801364 <__umoddi3+0x34>
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	89 f2                	mov    %esi,%edx
  8013d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013de:	83 c4 1c             	add    $0x1c,%esp
  8013e1:	c3                   	ret    
  8013e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013ed:	89 e8                	mov    %ebp,%eax
  8013ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8013f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8013f8:	89 fa                	mov    %edi,%edx
  8013fa:	d3 e0                	shl    %cl,%eax
  8013fc:	89 e9                	mov    %ebp,%ecx
  8013fe:	d3 ea                	shr    %cl,%edx
  801400:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801405:	09 c2                	or     %eax,%edx
  801407:	8b 44 24 08          	mov    0x8(%esp),%eax
  80140b:	89 14 24             	mov    %edx,(%esp)
  80140e:	89 f2                	mov    %esi,%edx
  801410:	d3 e7                	shl    %cl,%edi
  801412:	89 e9                	mov    %ebp,%ecx
  801414:	d3 ea                	shr    %cl,%edx
  801416:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80141b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80141f:	d3 e6                	shl    %cl,%esi
  801421:	89 e9                	mov    %ebp,%ecx
  801423:	d3 e8                	shr    %cl,%eax
  801425:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80142a:	09 f0                	or     %esi,%eax
  80142c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801430:	f7 34 24             	divl   (%esp)
  801433:	d3 e6                	shl    %cl,%esi
  801435:	89 74 24 08          	mov    %esi,0x8(%esp)
  801439:	89 d6                	mov    %edx,%esi
  80143b:	f7 e7                	mul    %edi
  80143d:	39 d6                	cmp    %edx,%esi
  80143f:	89 c1                	mov    %eax,%ecx
  801441:	89 d7                	mov    %edx,%edi
  801443:	72 3f                	jb     801484 <__umoddi3+0x154>
  801445:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801449:	72 35                	jb     801480 <__umoddi3+0x150>
  80144b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80144f:	29 c8                	sub    %ecx,%eax
  801451:	19 fe                	sbb    %edi,%esi
  801453:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801458:	89 f2                	mov    %esi,%edx
  80145a:	d3 e8                	shr    %cl,%eax
  80145c:	89 e9                	mov    %ebp,%ecx
  80145e:	d3 e2                	shl    %cl,%edx
  801460:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801465:	09 d0                	or     %edx,%eax
  801467:	89 f2                	mov    %esi,%edx
  801469:	d3 ea                	shr    %cl,%edx
  80146b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80146f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801473:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801477:	83 c4 1c             	add    $0x1c,%esp
  80147a:	c3                   	ret    
  80147b:	90                   	nop
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	39 d6                	cmp    %edx,%esi
  801482:	75 c7                	jne    80144b <__umoddi3+0x11b>
  801484:	89 d7                	mov    %edx,%edi
  801486:	89 c1                	mov    %eax,%ecx
  801488:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80148c:	1b 3c 24             	sbb    (%esp),%edi
  80148f:	eb ba                	jmp    80144b <__umoddi3+0x11b>
  801491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801498:	39 f5                	cmp    %esi,%ebp
  80149a:	0f 82 f1 fe ff ff    	jb     801391 <__umoddi3+0x61>
  8014a0:	e9 f8 fe ff ff       	jmp    80139d <__umoddi3+0x6d>
