
obj/user/faultallocbad:     file format elf32-i386


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
  800044:	c7 04 24 60 14 80 00 	movl   $0x801460,(%esp)
  80004b:	e8 f3 01 00 00       	call   800243 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 1d 0e 00 00       	call   800e8c <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 80 14 80 	movl   $0x801480,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 6a 14 80 00 	movl   $0x80146a,(%esp)
  800092:	e8 b1 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ac 14 80 	movl   $0x8014ac,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 64 08 00 00       	call   800917 <snprintf>
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
  8000c6:	e8 29 10 00 00       	call   8010f4 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 91 0c 00 00       	call   800d70 <sys_cputs>
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
  8000f6:	e8 31 0d 00 00       	call   800e2c <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 89 0c 00 00       	call   800dcf <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800159:	e8 ce 0c 00 00       	call   800e2c <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  80017b:	e8 c3 00 00 00       	call   800243 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 53 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 68 14 80 00 	movl   $0x801468,(%esp)
  800196:	e8 a8 00 00 00       	call   800243 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 14             	sub    $0x14,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b3:	83 c0 01             	add    $0x1,%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	75 19                	jne    8001d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c6:	00 
  8001c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 9e 0b 00 00       	call   800d70 <sys_cputs>
		b->idx = 0;
  8001d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	83 c4 14             	add    $0x14,%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800202:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800206:	8b 45 08             	mov    0x8(%ebp),%eax
  800209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	c7 04 24 a0 01 80 00 	movl   $0x8001a0,(%esp)
  80021e:	e8 97 01 00 00       	call   8003ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800223:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	e8 35 0b 00 00       	call   800d70 <sys_cputs>

	return b.cnt;
}
  80023b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800249:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 87 ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    
  80025d:	00 00                	add    %al,(%eax)
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	b8 00 00 00 00       	mov    $0x0,%eax
  800285:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800288:	72 11                	jb     80029b <printnum+0x3b>
  80028a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800290:	76 09                	jbe    80029b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800292:	83 eb 01             	sub    $0x1,%ebx
  800295:	85 db                	test   %ebx,%ebx
  800297:	7f 51                	jg     8002ea <printnum+0x8a>
  800299:	eb 5e                	jmp    8002f9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80029f:	83 eb 01             	sub    $0x1,%ebx
  8002a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ad:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bc:	00 
  8002bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ca:	e8 e1 0e 00 00       	call   8011b0 <__udivdi3>
  8002cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002de:	89 fa                	mov    %edi,%edx
  8002e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e3:	e8 78 ff ff ff       	call   800260 <printnum>
  8002e8:	eb 0f                	jmp    8002f9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ee:	89 34 24             	mov    %esi,(%esp)
  8002f1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f4:	83 eb 01             	sub    $0x1,%ebx
  8002f7:	75 f1                	jne    8002ea <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800301:	8b 45 10             	mov    0x10(%ebp),%eax
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030f:	00 
  800310:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	e8 be 0f 00 00       	call   8012e0 <__umoddi3>
  800322:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800326:	0f be 80 fb 14 80 00 	movsbl 0x8014fb(%eax),%eax
  80032d:	89 04 24             	mov    %eax,(%esp)
  800330:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800333:	83 c4 3c             	add    $0x3c,%esp
  800336:	5b                   	pop    %ebx
  800337:	5e                   	pop    %esi
  800338:	5f                   	pop    %edi
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033e:	83 fa 01             	cmp    $0x1,%edx
  800341:	7e 0e                	jle    800351 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800343:	8b 10                	mov    (%eax),%edx
  800345:	8d 4a 08             	lea    0x8(%edx),%ecx
  800348:	89 08                	mov    %ecx,(%eax)
  80034a:	8b 02                	mov    (%edx),%eax
  80034c:	8b 52 04             	mov    0x4(%edx),%edx
  80034f:	eb 22                	jmp    800373 <getuint+0x38>
	else if (lflag)
  800351:	85 d2                	test   %edx,%edx
  800353:	74 10                	je     800365 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800355:	8b 10                	mov    (%eax),%edx
  800357:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035a:	89 08                	mov    %ecx,(%eax)
  80035c:	8b 02                	mov    (%edx),%eax
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
  800363:	eb 0e                	jmp    800373 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800365:	8b 10                	mov    (%eax),%edx
  800367:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036a:	89 08                	mov    %ecx,(%eax)
  80036c:	8b 02                	mov    (%edx),%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	3b 50 04             	cmp    0x4(%eax),%edx
  800384:	73 0a                	jae    800390 <sprintputch+0x1b>
		*b->buf++ = ch;
  800386:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800389:	88 0a                	mov    %cl,(%edx)
  80038b:	83 c2 01             	add    $0x1,%edx
  80038e:	89 10                	mov    %edx,(%eax)
}
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800398:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80039f:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 02 00 00 00       	call   8003ba <vprintfmt>
	va_end(ap);
}
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	57                   	push   %edi
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
  8003c0:	83 ec 5c             	sub    $0x5c,%esp
  8003c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c9:	eb 12                	jmp    8003dd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cb:	85 c0                	test   %eax,%eax
  8003cd:	0f 84 e4 04 00 00    	je     8008b7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003dd:	0f b6 06             	movzbl (%esi),%eax
  8003e0:	83 c6 01             	add    $0x1,%esi
  8003e3:	83 f8 25             	cmp    $0x25,%eax
  8003e6:	75 e3                	jne    8003cb <vprintfmt+0x11>
  8003e8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003ec:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003f3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003f8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800404:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800407:	eb 2b                	jmp    800434 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800410:	eb 22                	jmp    800434 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800415:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800419:	eb 19                	jmp    800434 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80041e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800425:	eb 0d                	jmp    800434 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800427:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80042a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80042d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	0f b6 06             	movzbl (%esi),%eax
  800437:	0f b6 d0             	movzbl %al,%edx
  80043a:	8d 7e 01             	lea    0x1(%esi),%edi
  80043d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800440:	83 e8 23             	sub    $0x23,%eax
  800443:	3c 55                	cmp    $0x55,%al
  800445:	0f 87 46 04 00 00    	ja     800891 <vprintfmt+0x4d7>
  80044b:	0f b6 c0             	movzbl %al,%eax
  80044e:	ff 24 85 e0 15 80 00 	jmp    *0x8015e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800455:	83 ea 30             	sub    $0x30,%edx
  800458:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80045b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80045f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800465:	83 fa 09             	cmp    $0x9,%edx
  800468:	77 4a                	ja     8004b4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800470:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800473:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800477:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80047a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80047d:	83 fa 09             	cmp    $0x9,%edx
  800480:	76 eb                	jbe    80046d <vprintfmt+0xb3>
  800482:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800485:	eb 2d                	jmp    8004b4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 50 04             	lea    0x4(%eax),%edx
  80048d:	89 55 14             	mov    %edx,0x14(%ebp)
  800490:	8b 00                	mov    (%eax),%eax
  800492:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800498:	eb 1a                	jmp    8004b4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80049d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004a1:	79 91                	jns    800434 <vprintfmt+0x7a>
  8004a3:	e9 73 ff ff ff       	jmp    80041b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ab:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004b2:	eb 80                	jmp    800434 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004b4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004b8:	0f 89 76 ff ff ff    	jns    800434 <vprintfmt+0x7a>
  8004be:	e9 64 ff ff ff       	jmp    800427 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c9:	e9 66 ff ff ff       	jmp    800434 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	89 04 24             	mov    %eax,(%esp)
  8004e0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e6:	e9 f2 fe ff ff       	jmp    8003dd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004eb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004ef:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004f2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8004f6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8004f9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8004fd:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800500:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800503:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800507:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80050a:	80 f9 09             	cmp    $0x9,%cl
  80050d:	77 1d                	ja     80052c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80050f:	0f be c0             	movsbl %al,%eax
  800512:	6b c0 64             	imul   $0x64,%eax,%eax
  800515:	0f be d2             	movsbl %dl,%edx
  800518:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80051b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800522:	a3 04 20 80 00       	mov    %eax,0x802004
  800527:	e9 b1 fe ff ff       	jmp    8003dd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80052c:	c7 44 24 04 13 15 80 	movl   $0x801513,0x4(%esp)
  800533:	00 
  800534:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	e8 0c 05 00 00       	call   800a4b <strcmp>
  80053f:	85 c0                	test   %eax,%eax
  800541:	75 0f                	jne    800552 <vprintfmt+0x198>
  800543:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80054a:	00 00 00 
  80054d:	e9 8b fe ff ff       	jmp    8003dd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800552:	c7 44 24 04 17 15 80 	movl   $0x801517,0x4(%esp)
  800559:	00 
  80055a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80055d:	89 14 24             	mov    %edx,(%esp)
  800560:	e8 e6 04 00 00       	call   800a4b <strcmp>
  800565:	85 c0                	test   %eax,%eax
  800567:	75 0f                	jne    800578 <vprintfmt+0x1be>
  800569:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800570:	00 00 00 
  800573:	e9 65 fe ff ff       	jmp    8003dd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800578:	c7 44 24 04 1b 15 80 	movl   $0x80151b,0x4(%esp)
  80057f:	00 
  800580:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800583:	89 0c 24             	mov    %ecx,(%esp)
  800586:	e8 c0 04 00 00       	call   800a4b <strcmp>
  80058b:	85 c0                	test   %eax,%eax
  80058d:	75 0f                	jne    80059e <vprintfmt+0x1e4>
  80058f:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800596:	00 00 00 
  800599:	e9 3f fe ff ff       	jmp    8003dd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80059e:	c7 44 24 04 1f 15 80 	movl   $0x80151f,0x4(%esp)
  8005a5:	00 
  8005a6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005a9:	89 3c 24             	mov    %edi,(%esp)
  8005ac:	e8 9a 04 00 00       	call   800a4b <strcmp>
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	75 0f                	jne    8005c4 <vprintfmt+0x20a>
  8005b5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005bc:	00 00 00 
  8005bf:	e9 19 fe ff ff       	jmp    8003dd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005c4:	c7 44 24 04 23 15 80 	movl   $0x801523,0x4(%esp)
  8005cb:	00 
  8005cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 74 04 00 00       	call   800a4b <strcmp>
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	75 0f                	jne    8005ea <vprintfmt+0x230>
  8005db:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8005e2:	00 00 00 
  8005e5:	e9 f3 fd ff ff       	jmp    8003dd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005ea:	c7 44 24 04 27 15 80 	movl   $0x801527,0x4(%esp)
  8005f1:	00 
  8005f2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005f5:	89 14 24             	mov    %edx,(%esp)
  8005f8:	e8 4e 04 00 00       	call   800a4b <strcmp>
  8005fd:	83 f8 01             	cmp    $0x1,%eax
  800600:	19 c0                	sbb    %eax,%eax
  800602:	f7 d0                	not    %eax
  800604:	83 c0 08             	add    $0x8,%eax
  800607:	a3 04 20 80 00       	mov    %eax,0x802004
  80060c:	e9 cc fd ff ff       	jmp    8003dd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 c2                	mov    %eax,%edx
  80061e:	c1 fa 1f             	sar    $0x1f,%edx
  800621:	31 d0                	xor    %edx,%eax
  800623:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800625:	83 f8 08             	cmp    $0x8,%eax
  800628:	7f 0b                	jg     800635 <vprintfmt+0x27b>
  80062a:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	75 23                	jne    800658 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800635:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800639:	c7 44 24 08 2b 15 80 	movl   $0x80152b,0x8(%esp)
  800640:	00 
  800641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800645:	8b 7d 08             	mov    0x8(%ebp),%edi
  800648:	89 3c 24             	mov    %edi,(%esp)
  80064b:	e8 42 fd ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800653:	e9 85 fd ff ff       	jmp    8003dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800658:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065c:	c7 44 24 08 34 15 80 	movl   $0x801534,0x8(%esp)
  800663:	00 
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066b:	89 3c 24             	mov    %edi,(%esp)
  80066e:	e8 1f fd ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800676:	e9 62 fd ff ff       	jmp    8003dd <vprintfmt+0x23>
  80067b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80067e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800681:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80068f:	85 f6                	test   %esi,%esi
  800691:	b8 0c 15 80 00       	mov    $0x80150c,%eax
  800696:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800699:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80069d:	7e 06                	jle    8006a5 <vprintfmt+0x2eb>
  80069f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006a3:	75 13                	jne    8006b8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a5:	0f be 06             	movsbl (%esi),%eax
  8006a8:	83 c6 01             	add    $0x1,%esi
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	0f 85 94 00 00 00    	jne    800747 <vprintfmt+0x38d>
  8006b3:	e9 81 00 00 00       	jmp    800739 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bc:	89 34 24             	mov    %esi,(%esp)
  8006bf:	e8 97 02 00 00       	call   80095b <strnlen>
  8006c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006c7:	29 c2                	sub    %eax,%edx
  8006c9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	7e d5                	jle    8006a5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006d0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006d4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006d7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006da:	89 d6                	mov    %edx,%esi
  8006dc:	89 cf                	mov    %ecx,%edi
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	89 3c 24             	mov    %edi,(%esp)
  8006e5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e8:	83 ee 01             	sub    $0x1,%esi
  8006eb:	75 f1                	jne    8006de <vprintfmt+0x324>
  8006ed:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006f0:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006f3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8006f6:	eb ad                	jmp    8006a5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006fc:	74 1b                	je     800719 <vprintfmt+0x35f>
  8006fe:	8d 50 e0             	lea    -0x20(%eax),%edx
  800701:	83 fa 5e             	cmp    $0x5e,%edx
  800704:	76 13                	jbe    800719 <vprintfmt+0x35f>
					putch('?', putdat);
  800706:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800714:	ff 55 08             	call   *0x8(%ebp)
  800717:	eb 0d                	jmp    800726 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800719:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80071c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800726:	83 eb 01             	sub    $0x1,%ebx
  800729:	0f be 06             	movsbl (%esi),%eax
  80072c:	83 c6 01             	add    $0x1,%esi
  80072f:	85 c0                	test   %eax,%eax
  800731:	75 1a                	jne    80074d <vprintfmt+0x393>
  800733:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800736:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800740:	7f 1c                	jg     80075e <vprintfmt+0x3a4>
  800742:	e9 96 fc ff ff       	jmp    8003dd <vprintfmt+0x23>
  800747:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80074a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074d:	85 ff                	test   %edi,%edi
  80074f:	78 a7                	js     8006f8 <vprintfmt+0x33e>
  800751:	83 ef 01             	sub    $0x1,%edi
  800754:	79 a2                	jns    8006f8 <vprintfmt+0x33e>
  800756:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800759:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80075c:	eb db                	jmp    800739 <vprintfmt+0x37f>
  80075e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800761:	89 de                	mov    %ebx,%esi
  800763:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800766:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800771:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800773:	83 eb 01             	sub    $0x1,%ebx
  800776:	75 ee                	jne    800766 <vprintfmt+0x3ac>
  800778:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80077d:	e9 5b fc ff ff       	jmp    8003dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800782:	83 f9 01             	cmp    $0x1,%ecx
  800785:	7e 10                	jle    800797 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8d 50 08             	lea    0x8(%eax),%edx
  80078d:	89 55 14             	mov    %edx,0x14(%ebp)
  800790:	8b 30                	mov    (%eax),%esi
  800792:	8b 78 04             	mov    0x4(%eax),%edi
  800795:	eb 26                	jmp    8007bd <vprintfmt+0x403>
	else if (lflag)
  800797:	85 c9                	test   %ecx,%ecx
  800799:	74 12                	je     8007ad <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 50 04             	lea    0x4(%eax),%edx
  8007a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a4:	8b 30                	mov    (%eax),%esi
  8007a6:	89 f7                	mov    %esi,%edi
  8007a8:	c1 ff 1f             	sar    $0x1f,%edi
  8007ab:	eb 10                	jmp    8007bd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8d 50 04             	lea    0x4(%eax),%edx
  8007b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b6:	8b 30                	mov    (%eax),%esi
  8007b8:	89 f7                	mov    %esi,%edi
  8007ba:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007bd:	85 ff                	test   %edi,%edi
  8007bf:	78 0e                	js     8007cf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c1:	89 f0                	mov    %esi,%eax
  8007c3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c5:	be 0a 00 00 00       	mov    $0xa,%esi
  8007ca:	e9 84 00 00 00       	jmp    800853 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007da:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	89 fa                	mov    %edi,%edx
  8007e1:	f7 d8                	neg    %eax
  8007e3:	83 d2 00             	adc    $0x0,%edx
  8007e6:	f7 da                	neg    %edx
			}
			base = 10;
  8007e8:	be 0a 00 00 00       	mov    $0xa,%esi
  8007ed:	eb 64                	jmp    800853 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ef:	89 ca                	mov    %ecx,%edx
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 42 fb ff ff       	call   80033b <getuint>
			base = 10;
  8007f9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8007fe:	eb 53                	jmp    800853 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800800:	89 ca                	mov    %ecx,%edx
  800802:	8d 45 14             	lea    0x14(%ebp),%eax
  800805:	e8 31 fb ff ff       	call   80033b <getuint>
    			base = 8;
  80080a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80080f:	eb 42                	jmp    800853 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800811:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800815:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80081c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80081f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800823:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80082a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	8d 50 04             	lea    0x4(%eax),%edx
  800833:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800836:	8b 00                	mov    (%eax),%eax
  800838:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80083d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800842:	eb 0f                	jmp    800853 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800844:	89 ca                	mov    %ecx,%edx
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 ed fa ff ff       	call   80033b <getuint>
			base = 16;
  80084e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800853:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800857:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80085b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80085e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800862:	89 74 24 08          	mov    %esi,0x8(%esp)
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	89 54 24 04          	mov    %edx,0x4(%esp)
  80086d:	89 da                	mov    %ebx,%edx
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	e8 e9 f9 ff ff       	call   800260 <printnum>
			break;
  800877:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80087a:	e9 5e fb ff ff       	jmp    8003dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80087f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800883:	89 14 24             	mov    %edx,(%esp)
  800886:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800889:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80088c:	e9 4c fb ff ff       	jmp    8003dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800891:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800895:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80089c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80089f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008a3:	0f 84 34 fb ff ff    	je     8003dd <vprintfmt+0x23>
  8008a9:	83 ee 01             	sub    $0x1,%esi
  8008ac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008b0:	75 f7                	jne    8008a9 <vprintfmt+0x4ef>
  8008b2:	e9 26 fb ff ff       	jmp    8003dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008b7:	83 c4 5c             	add    $0x5c,%esp
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	83 ec 28             	sub    $0x28,%esp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	74 30                	je     800910 <vsnprintf+0x51>
  8008e0:	85 d2                	test   %edx,%edx
  8008e2:	7e 2c                	jle    800910 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f9:	c7 04 24 75 03 80 00 	movl   $0x800375,(%esp)
  800900:	e8 b5 fa ff ff       	call   8003ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800905:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800908:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090e:	eb 05                	jmp    800915 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800910:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800920:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800924:	8b 45 10             	mov    0x10(%ebp),%eax
  800927:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	89 04 24             	mov    %eax,(%esp)
  800938:	e8 82 ff ff ff       	call   8008bf <vsnprintf>
	va_end(ap);

	return rc;
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    
	...

00800940 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	80 3a 00             	cmpb   $0x0,(%edx)
  80094e:	74 09                	je     800959 <strlen+0x19>
		n++;
  800950:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800953:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800957:	75 f7                	jne    800950 <strlen+0x10>
		n++;
	return n;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
  80096a:	85 c9                	test   %ecx,%ecx
  80096c:	74 1a                	je     800988 <strnlen+0x2d>
  80096e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800971:	74 15                	je     800988 <strnlen+0x2d>
  800973:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800978:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097a:	39 ca                	cmp    %ecx,%edx
  80097c:	74 0a                	je     800988 <strnlen+0x2d>
  80097e:	83 c2 01             	add    $0x1,%edx
  800981:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800986:	75 f0                	jne    800978 <strnlen+0x1d>
		n++;
	return n;
}
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800995:	ba 00 00 00 00       	mov    $0x0,%edx
  80099a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80099e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009a1:	83 c2 01             	add    $0x1,%edx
  8009a4:	84 c9                	test   %cl,%cl
  8009a6:	75 f2                	jne    80099a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	83 ec 08             	sub    $0x8,%esp
  8009b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b5:	89 1c 24             	mov    %ebx,(%esp)
  8009b8:	e8 83 ff ff ff       	call   800940 <strlen>
	strcpy(dst + len, src);
  8009bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009c4:	01 d8                	add    %ebx,%eax
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	e8 bd ff ff ff       	call   80098b <strcpy>
	return dst;
}
  8009ce:	89 d8                	mov    %ebx,%eax
  8009d0:	83 c4 08             	add    $0x8,%esp
  8009d3:	5b                   	pop    %ebx
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e4:	85 f6                	test   %esi,%esi
  8009e6:	74 18                	je     800a00 <strncpy+0x2a>
  8009e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009ed:	0f b6 1a             	movzbl (%edx),%ebx
  8009f0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009f6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	39 f1                	cmp    %esi,%ecx
  8009fe:	75 ed                	jne    8009ed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a10:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a13:	89 f8                	mov    %edi,%eax
  800a15:	85 f6                	test   %esi,%esi
  800a17:	74 2b                	je     800a44 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a19:	83 fe 01             	cmp    $0x1,%esi
  800a1c:	74 23                	je     800a41 <strlcpy+0x3d>
  800a1e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a21:	84 c9                	test   %cl,%cl
  800a23:	74 1c                	je     800a41 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a25:	83 ee 02             	sub    $0x2,%esi
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a2d:	88 08                	mov    %cl,(%eax)
  800a2f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a32:	39 f2                	cmp    %esi,%edx
  800a34:	74 0b                	je     800a41 <strlcpy+0x3d>
  800a36:	83 c2 01             	add    $0x1,%edx
  800a39:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a3d:	84 c9                	test   %cl,%cl
  800a3f:	75 ec                	jne    800a2d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a44:	29 f8                	sub    %edi,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a51:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a54:	0f b6 01             	movzbl (%ecx),%eax
  800a57:	84 c0                	test   %al,%al
  800a59:	74 16                	je     800a71 <strcmp+0x26>
  800a5b:	3a 02                	cmp    (%edx),%al
  800a5d:	75 12                	jne    800a71 <strcmp+0x26>
		p++, q++;
  800a5f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a62:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a66:	84 c0                	test   %al,%al
  800a68:	74 07                	je     800a71 <strcmp+0x26>
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	3a 02                	cmp    (%edx),%al
  800a6f:	74 ee                	je     800a5f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a71:	0f b6 c0             	movzbl %al,%eax
  800a74:	0f b6 12             	movzbl (%edx),%edx
  800a77:	29 d0                	sub    %edx,%eax
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a85:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8d:	85 d2                	test   %edx,%edx
  800a8f:	74 28                	je     800ab9 <strncmp+0x3e>
  800a91:	0f b6 01             	movzbl (%ecx),%eax
  800a94:	84 c0                	test   %al,%al
  800a96:	74 24                	je     800abc <strncmp+0x41>
  800a98:	3a 03                	cmp    (%ebx),%al
  800a9a:	75 20                	jne    800abc <strncmp+0x41>
  800a9c:	83 ea 01             	sub    $0x1,%edx
  800a9f:	74 13                	je     800ab4 <strncmp+0x39>
		n--, p++, q++;
  800aa1:	83 c1 01             	add    $0x1,%ecx
  800aa4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa7:	0f b6 01             	movzbl (%ecx),%eax
  800aaa:	84 c0                	test   %al,%al
  800aac:	74 0e                	je     800abc <strncmp+0x41>
  800aae:	3a 03                	cmp    (%ebx),%al
  800ab0:	74 ea                	je     800a9c <strncmp+0x21>
  800ab2:	eb 08                	jmp    800abc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abc:	0f b6 01             	movzbl (%ecx),%eax
  800abf:	0f b6 13             	movzbl (%ebx),%edx
  800ac2:	29 d0                	sub    %edx,%eax
  800ac4:	eb f3                	jmp    800ab9 <strncmp+0x3e>

00800ac6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad0:	0f b6 10             	movzbl (%eax),%edx
  800ad3:	84 d2                	test   %dl,%dl
  800ad5:	74 1c                	je     800af3 <strchr+0x2d>
		if (*s == c)
  800ad7:	38 ca                	cmp    %cl,%dl
  800ad9:	75 09                	jne    800ae4 <strchr+0x1e>
  800adb:	eb 1b                	jmp    800af8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800add:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 14                	je     800af8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f1                	jne    800add <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	eb 05                	jmp    800af8 <strchr+0x32>
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b04:	0f b6 10             	movzbl (%eax),%edx
  800b07:	84 d2                	test   %dl,%dl
  800b09:	74 14                	je     800b1f <strfind+0x25>
		if (*s == c)
  800b0b:	38 ca                	cmp    %cl,%dl
  800b0d:	75 06                	jne    800b15 <strfind+0x1b>
  800b0f:	eb 0e                	jmp    800b1f <strfind+0x25>
  800b11:	38 ca                	cmp    %cl,%dl
  800b13:	74 0a                	je     800b1f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b15:	83 c0 01             	add    $0x1,%eax
  800b18:	0f b6 10             	movzbl (%eax),%edx
  800b1b:	84 d2                	test   %dl,%dl
  800b1d:	75 f2                	jne    800b11 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b2a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b2d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b39:	85 c9                	test   %ecx,%ecx
  800b3b:	74 30                	je     800b6d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b43:	75 25                	jne    800b6a <memset+0x49>
  800b45:	f6 c1 03             	test   $0x3,%cl
  800b48:	75 20                	jne    800b6a <memset+0x49>
		c &= 0xFF;
  800b4a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	c1 e3 08             	shl    $0x8,%ebx
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	c1 e6 18             	shl    $0x18,%esi
  800b57:	89 d0                	mov    %edx,%eax
  800b59:	c1 e0 10             	shl    $0x10,%eax
  800b5c:	09 f0                	or     %esi,%eax
  800b5e:	09 d0                	or     %edx,%eax
  800b60:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b62:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b65:	fc                   	cld    
  800b66:	f3 ab                	rep stos %eax,%es:(%edi)
  800b68:	eb 03                	jmp    800b6d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b6a:	fc                   	cld    
  800b6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b78:	89 ec                	mov    %ebp,%esp
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
  800b82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b85:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b91:	39 c6                	cmp    %eax,%esi
  800b93:	73 36                	jae    800bcb <memmove+0x4f>
  800b95:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b98:	39 d0                	cmp    %edx,%eax
  800b9a:	73 2f                	jae    800bcb <memmove+0x4f>
		s += n;
		d += n;
  800b9c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9f:	f6 c2 03             	test   $0x3,%dl
  800ba2:	75 1b                	jne    800bbf <memmove+0x43>
  800ba4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800baa:	75 13                	jne    800bbf <memmove+0x43>
  800bac:	f6 c1 03             	test   $0x3,%cl
  800baf:	75 0e                	jne    800bbf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bb1:	83 ef 04             	sub    $0x4,%edi
  800bb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bba:	fd                   	std    
  800bbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbd:	eb 09                	jmp    800bc8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bbf:	83 ef 01             	sub    $0x1,%edi
  800bc2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bc5:	fd                   	std    
  800bc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc8:	fc                   	cld    
  800bc9:	eb 20                	jmp    800beb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd1:	75 13                	jne    800be6 <memmove+0x6a>
  800bd3:	a8 03                	test   $0x3,%al
  800bd5:	75 0f                	jne    800be6 <memmove+0x6a>
  800bd7:	f6 c1 03             	test   $0x3,%cl
  800bda:	75 0a                	jne    800be6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bdf:	89 c7                	mov    %eax,%edi
  800be1:	fc                   	cld    
  800be2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be4:	eb 05                	jmp    800beb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	fc                   	cld    
  800be9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800beb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf1:	89 ec                	mov    %ebp,%esp
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bfb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	89 04 24             	mov    %eax,(%esp)
  800c0f:	e8 68 ff ff ff       	call   800b7c <memmove>
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c22:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2a:	85 ff                	test   %edi,%edi
  800c2c:	74 37                	je     800c65 <memcmp+0x4f>
		if (*s1 != *s2)
  800c2e:	0f b6 03             	movzbl (%ebx),%eax
  800c31:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c34:	83 ef 01             	sub    $0x1,%edi
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c3c:	38 c8                	cmp    %cl,%al
  800c3e:	74 1c                	je     800c5c <memcmp+0x46>
  800c40:	eb 10                	jmp    800c52 <memcmp+0x3c>
  800c42:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c47:	83 c2 01             	add    $0x1,%edx
  800c4a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c4e:	38 c8                	cmp    %cl,%al
  800c50:	74 0a                	je     800c5c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c52:	0f b6 c0             	movzbl %al,%eax
  800c55:	0f b6 c9             	movzbl %cl,%ecx
  800c58:	29 c8                	sub    %ecx,%eax
  800c5a:	eb 09                	jmp    800c65 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5c:	39 fa                	cmp    %edi,%edx
  800c5e:	75 e2                	jne    800c42 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c70:	89 c2                	mov    %eax,%edx
  800c72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c75:	39 d0                	cmp    %edx,%eax
  800c77:	73 19                	jae    800c92 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c7d:	38 08                	cmp    %cl,(%eax)
  800c7f:	75 06                	jne    800c87 <memfind+0x1d>
  800c81:	eb 0f                	jmp    800c92 <memfind+0x28>
  800c83:	38 08                	cmp    %cl,(%eax)
  800c85:	74 0b                	je     800c92 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c87:	83 c0 01             	add    $0x1,%eax
  800c8a:	39 d0                	cmp    %edx,%eax
  800c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c90:	75 f1                	jne    800c83 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca0:	0f b6 02             	movzbl (%edx),%eax
  800ca3:	3c 20                	cmp    $0x20,%al
  800ca5:	74 04                	je     800cab <strtol+0x17>
  800ca7:	3c 09                	cmp    $0x9,%al
  800ca9:	75 0e                	jne    800cb9 <strtol+0x25>
		s++;
  800cab:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cae:	0f b6 02             	movzbl (%edx),%eax
  800cb1:	3c 20                	cmp    $0x20,%al
  800cb3:	74 f6                	je     800cab <strtol+0x17>
  800cb5:	3c 09                	cmp    $0x9,%al
  800cb7:	74 f2                	je     800cab <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb9:	3c 2b                	cmp    $0x2b,%al
  800cbb:	75 0a                	jne    800cc7 <strtol+0x33>
		s++;
  800cbd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc5:	eb 10                	jmp    800cd7 <strtol+0x43>
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ccc:	3c 2d                	cmp    $0x2d,%al
  800cce:	75 07                	jne    800cd7 <strtol+0x43>
		s++, neg = 1;
  800cd0:	83 c2 01             	add    $0x1,%edx
  800cd3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd7:	85 db                	test   %ebx,%ebx
  800cd9:	0f 94 c0             	sete   %al
  800cdc:	74 05                	je     800ce3 <strtol+0x4f>
  800cde:	83 fb 10             	cmp    $0x10,%ebx
  800ce1:	75 15                	jne    800cf8 <strtol+0x64>
  800ce3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ce6:	75 10                	jne    800cf8 <strtol+0x64>
  800ce8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cec:	75 0a                	jne    800cf8 <strtol+0x64>
		s += 2, base = 16;
  800cee:	83 c2 02             	add    $0x2,%edx
  800cf1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf6:	eb 13                	jmp    800d0b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cf8:	84 c0                	test   %al,%al
  800cfa:	74 0f                	je     800d0b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cfc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d01:	80 3a 30             	cmpb   $0x30,(%edx)
  800d04:	75 05                	jne    800d0b <strtol+0x77>
		s++, base = 8;
  800d06:	83 c2 01             	add    $0x1,%edx
  800d09:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d10:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d12:	0f b6 0a             	movzbl (%edx),%ecx
  800d15:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d18:	80 fb 09             	cmp    $0x9,%bl
  800d1b:	77 08                	ja     800d25 <strtol+0x91>
			dig = *s - '0';
  800d1d:	0f be c9             	movsbl %cl,%ecx
  800d20:	83 e9 30             	sub    $0x30,%ecx
  800d23:	eb 1e                	jmp    800d43 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d25:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d28:	80 fb 19             	cmp    $0x19,%bl
  800d2b:	77 08                	ja     800d35 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d2d:	0f be c9             	movsbl %cl,%ecx
  800d30:	83 e9 57             	sub    $0x57,%ecx
  800d33:	eb 0e                	jmp    800d43 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d35:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d38:	80 fb 19             	cmp    $0x19,%bl
  800d3b:	77 14                	ja     800d51 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d3d:	0f be c9             	movsbl %cl,%ecx
  800d40:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d43:	39 f1                	cmp    %esi,%ecx
  800d45:	7d 0e                	jge    800d55 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d47:	83 c2 01             	add    $0x1,%edx
  800d4a:	0f af c6             	imul   %esi,%eax
  800d4d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d4f:	eb c1                	jmp    800d12 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d51:	89 c1                	mov    %eax,%ecx
  800d53:	eb 02                	jmp    800d57 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d55:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5b:	74 05                	je     800d62 <strtol+0xce>
		*endptr = (char *) s;
  800d5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d60:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d62:	89 ca                	mov    %ecx,%edx
  800d64:	f7 da                	neg    %edx
  800d66:	85 ff                	test   %edi,%edi
  800d68:	0f 45 c2             	cmovne %edx,%eax
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d79:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	89 c7                	mov    %eax,%edi
  800d8e:	89 c6                	mov    %eax,%esi
  800d90:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9b:	89 ec                	mov    %ebp,%esp
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	ba 00 00 00 00       	mov    $0x0,%edx
  800db3:	b8 01 00 00 00       	mov    $0x1,%eax
  800db8:	89 d1                	mov    %edx,%ecx
  800dba:	89 d3                	mov    %edx,%ebx
  800dbc:	89 d7                	mov    %edx,%edi
  800dbe:	89 d6                	mov    %edx,%esi
  800dc0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcb:	89 ec                	mov    %ebp,%esp
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 38             	sub    $0x38,%esp
  800dd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de3:	b8 03 00 00 00       	mov    $0x3,%eax
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	89 cb                	mov    %ecx,%ebx
  800ded:	89 cf                	mov    %ecx,%edi
  800def:	89 ce                	mov    %ecx,%esi
  800df1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 28                	jle    800e1f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e02:	00 
  800e03:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800e1a:	e8 29 f3 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e28:	89 ec                	mov    %ebp,%esp
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	b8 02 00 00 00       	mov    $0x2,%eax
  800e45:	89 d1                	mov    %edx,%ecx
  800e47:	89 d3                	mov    %edx,%ebx
  800e49:	89 d7                	mov    %edx,%edi
  800e4b:	89 d6                	mov    %edx,%esi
  800e4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_yield>:

void
sys_yield(void)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e68:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e70:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	89 d3                	mov    %edx,%ebx
  800e79:	89 d7                	mov    %edx,%edi
  800e7b:	89 d6                	mov    %edx,%esi
  800e7d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 38             	sub    $0x38,%esp
  800e92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e98:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ea0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	89 f7                	mov    %esi,%edi
  800eb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7e 28                	jle    800ede <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eba:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800ec9:	00 
  800eca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed1:	00 
  800ed2:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800ed9:	e8 6a f2 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ede:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee7:	89 ec                	mov    %ebp,%esp
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 38             	sub    $0x38,%esp
  800ef1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	b8 05 00 00 00       	mov    $0x5,%eax
  800eff:	8b 75 18             	mov    0x18(%ebp),%esi
  800f02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f10:	85 c0                	test   %eax,%eax
  800f12:	7e 28                	jle    800f3c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f18:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f1f:	00 
  800f20:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800f27:	00 
  800f28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2f:	00 
  800f30:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800f37:	e8 0c f2 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f3c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f42:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f45:	89 ec                	mov    %ebp,%esp
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 38             	sub    $0x38,%esp
  800f4f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f52:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f55:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	89 df                	mov    %ebx,%edi
  800f6a:	89 de                	mov    %ebx,%esi
  800f6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 28                	jle    800f9a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f76:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800f85:	00 
  800f86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8d:	00 
  800f8e:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800f95:	e8 ae f1 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa3:	89 ec                	mov    %ebp,%esp
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 38             	sub    $0x38,%esp
  800fad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	89 df                	mov    %ebx,%edi
  800fc8:	89 de                	mov    %ebx,%esi
  800fca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	7e 28                	jle    800ff8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800feb:	00 
  800fec:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800ff3:	e8 50 f1 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ff8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801001:	89 ec                	mov    %ebp,%esp
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 38             	sub    $0x38,%esp
  80100b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801011:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801014:	bb 00 00 00 00       	mov    $0x0,%ebx
  801019:	b8 09 00 00 00       	mov    $0x9,%eax
  80101e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801021:	8b 55 08             	mov    0x8(%ebp),%edx
  801024:	89 df                	mov    %ebx,%edi
  801026:	89 de                	mov    %ebx,%esi
  801028:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102a:	85 c0                	test   %eax,%eax
  80102c:	7e 28                	jle    801056 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801032:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801039:	00 
  80103a:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  801041:	00 
  801042:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801049:	00 
  80104a:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  801051:	e8 f2 f0 ff ff       	call   800148 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801056:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801059:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80105c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80105f:	89 ec                	mov    %ebp,%esp
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80106c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80106f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801072:	be 00 00 00 00       	mov    $0x0,%esi
  801077:	b8 0b 00 00 00       	mov    $0xb,%eax
  80107c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80107f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801082:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801085:	8b 55 08             	mov    0x8(%ebp),%edx
  801088:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80108a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801090:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801093:	89 ec                	mov    %ebp,%esp
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	83 ec 38             	sub    $0x38,%esp
  80109d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010a0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010a3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ab:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b3:	89 cb                	mov    %ecx,%ebx
  8010b5:	89 cf                	mov    %ecx,%edi
  8010b7:	89 ce                	mov    %ecx,%esi
  8010b9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	7e 28                	jle    8010e7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  8010d2:	00 
  8010d3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010da:	00 
  8010db:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  8010e2:	e8 61 f0 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010f0:	89 ec                	mov    %ebp,%esp
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010fa:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801101:	75 3c                	jne    80113f <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801103:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80110a:	00 
  80110b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801112:	ee 
  801113:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80111a:	e8 6d fd ff ff       	call   800e8c <sys_page_alloc>
  80111f:	85 c0                	test   %eax,%eax
  801121:	79 1c                	jns    80113f <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801123:	c7 44 24 08 90 17 80 	movl   $0x801790,0x8(%esp)
  80112a:	00 
  80112b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801132:	00 
  801133:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  80113a:	e8 09 f0 ff ff       	call   800148 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801147:	c7 44 24 04 80 11 80 	movl   $0x801180,0x4(%esp)
  80114e:	00 
  80114f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801156:	e8 aa fe ff ff       	call   801005 <sys_env_set_pgfault_upcall>
  80115b:	85 c0                	test   %eax,%eax
  80115d:	79 1c                	jns    80117b <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80115f:	c7 44 24 08 bc 17 80 	movl   $0x8017bc,0x8(%esp)
  801166:	00 
  801167:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80116e:	00 
  80116f:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  801176:	e8 cd ef ff ff       	call   800148 <_panic>
}
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    
  80117d:	00 00                	add    %al,(%eax)
	...

00801180 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801180:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801181:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801186:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801188:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80118b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80118f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801194:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  801198:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80119a:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  80119d:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80119e:	83 c4 04             	add    $0x4,%esp
    popfl
  8011a1:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8011a2:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8011a3:	c3                   	ret    
	...

008011b0 <__udivdi3>:
  8011b0:	83 ec 1c             	sub    $0x1c,%esp
  8011b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8011bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011cb:	85 ff                	test   %edi,%edi
  8011cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	89 cd                	mov    %ecx,%ebp
  8011d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011db:	75 33                	jne    801210 <__udivdi3+0x60>
  8011dd:	39 f1                	cmp    %esi,%ecx
  8011df:	77 57                	ja     801238 <__udivdi3+0x88>
  8011e1:	85 c9                	test   %ecx,%ecx
  8011e3:	75 0b                	jne    8011f0 <__udivdi3+0x40>
  8011e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ea:	31 d2                	xor    %edx,%edx
  8011ec:	f7 f1                	div    %ecx
  8011ee:	89 c1                	mov    %eax,%ecx
  8011f0:	89 f0                	mov    %esi,%eax
  8011f2:	31 d2                	xor    %edx,%edx
  8011f4:	f7 f1                	div    %ecx
  8011f6:	89 c6                	mov    %eax,%esi
  8011f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011fc:	f7 f1                	div    %ecx
  8011fe:	89 f2                	mov    %esi,%edx
  801200:	8b 74 24 10          	mov    0x10(%esp),%esi
  801204:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801208:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80120c:	83 c4 1c             	add    $0x1c,%esp
  80120f:	c3                   	ret    
  801210:	31 d2                	xor    %edx,%edx
  801212:	31 c0                	xor    %eax,%eax
  801214:	39 f7                	cmp    %esi,%edi
  801216:	77 e8                	ja     801200 <__udivdi3+0x50>
  801218:	0f bd cf             	bsr    %edi,%ecx
  80121b:	83 f1 1f             	xor    $0x1f,%ecx
  80121e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801222:	75 2c                	jne    801250 <__udivdi3+0xa0>
  801224:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801228:	76 04                	jbe    80122e <__udivdi3+0x7e>
  80122a:	39 f7                	cmp    %esi,%edi
  80122c:	73 d2                	jae    801200 <__udivdi3+0x50>
  80122e:	31 d2                	xor    %edx,%edx
  801230:	b8 01 00 00 00       	mov    $0x1,%eax
  801235:	eb c9                	jmp    801200 <__udivdi3+0x50>
  801237:	90                   	nop
  801238:	89 f2                	mov    %esi,%edx
  80123a:	f7 f1                	div    %ecx
  80123c:	31 d2                	xor    %edx,%edx
  80123e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801242:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801246:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124a:	83 c4 1c             	add    $0x1c,%esp
  80124d:	c3                   	ret    
  80124e:	66 90                	xchg   %ax,%ax
  801250:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801255:	b8 20 00 00 00       	mov    $0x20,%eax
  80125a:	89 ea                	mov    %ebp,%edx
  80125c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801260:	d3 e7                	shl    %cl,%edi
  801262:	89 c1                	mov    %eax,%ecx
  801264:	d3 ea                	shr    %cl,%edx
  801266:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126b:	09 fa                	or     %edi,%edx
  80126d:	89 f7                	mov    %esi,%edi
  80126f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801273:	89 f2                	mov    %esi,%edx
  801275:	8b 74 24 08          	mov    0x8(%esp),%esi
  801279:	d3 e5                	shl    %cl,%ebp
  80127b:	89 c1                	mov    %eax,%ecx
  80127d:	d3 ef                	shr    %cl,%edi
  80127f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801284:	d3 e2                	shl    %cl,%edx
  801286:	89 c1                	mov    %eax,%ecx
  801288:	d3 ee                	shr    %cl,%esi
  80128a:	09 d6                	or     %edx,%esi
  80128c:	89 fa                	mov    %edi,%edx
  80128e:	89 f0                	mov    %esi,%eax
  801290:	f7 74 24 0c          	divl   0xc(%esp)
  801294:	89 d7                	mov    %edx,%edi
  801296:	89 c6                	mov    %eax,%esi
  801298:	f7 e5                	mul    %ebp
  80129a:	39 d7                	cmp    %edx,%edi
  80129c:	72 22                	jb     8012c0 <__udivdi3+0x110>
  80129e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8012a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a7:	d3 e5                	shl    %cl,%ebp
  8012a9:	39 c5                	cmp    %eax,%ebp
  8012ab:	73 04                	jae    8012b1 <__udivdi3+0x101>
  8012ad:	39 d7                	cmp    %edx,%edi
  8012af:	74 0f                	je     8012c0 <__udivdi3+0x110>
  8012b1:	89 f0                	mov    %esi,%eax
  8012b3:	31 d2                	xor    %edx,%edx
  8012b5:	e9 46 ff ff ff       	jmp    801200 <__udivdi3+0x50>
  8012ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8012c3:	31 d2                	xor    %edx,%edx
  8012c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012d1:	83 c4 1c             	add    $0x1c,%esp
  8012d4:	c3                   	ret    
	...

008012e0 <__umoddi3>:
  8012e0:	83 ec 1c             	sub    $0x1c,%esp
  8012e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8012e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8012eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8012ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8012fb:	85 ed                	test   %ebp,%ebp
  8012fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801301:	89 44 24 08          	mov    %eax,0x8(%esp)
  801305:	89 cf                	mov    %ecx,%edi
  801307:	89 04 24             	mov    %eax,(%esp)
  80130a:	89 f2                	mov    %esi,%edx
  80130c:	75 1a                	jne    801328 <__umoddi3+0x48>
  80130e:	39 f1                	cmp    %esi,%ecx
  801310:	76 4e                	jbe    801360 <__umoddi3+0x80>
  801312:	f7 f1                	div    %ecx
  801314:	89 d0                	mov    %edx,%eax
  801316:	31 d2                	xor    %edx,%edx
  801318:	8b 74 24 10          	mov    0x10(%esp),%esi
  80131c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801320:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801324:	83 c4 1c             	add    $0x1c,%esp
  801327:	c3                   	ret    
  801328:	39 f5                	cmp    %esi,%ebp
  80132a:	77 54                	ja     801380 <__umoddi3+0xa0>
  80132c:	0f bd c5             	bsr    %ebp,%eax
  80132f:	83 f0 1f             	xor    $0x1f,%eax
  801332:	89 44 24 04          	mov    %eax,0x4(%esp)
  801336:	75 60                	jne    801398 <__umoddi3+0xb8>
  801338:	3b 0c 24             	cmp    (%esp),%ecx
  80133b:	0f 87 07 01 00 00    	ja     801448 <__umoddi3+0x168>
  801341:	89 f2                	mov    %esi,%edx
  801343:	8b 34 24             	mov    (%esp),%esi
  801346:	29 ce                	sub    %ecx,%esi
  801348:	19 ea                	sbb    %ebp,%edx
  80134a:	89 34 24             	mov    %esi,(%esp)
  80134d:	8b 04 24             	mov    (%esp),%eax
  801350:	8b 74 24 10          	mov    0x10(%esp),%esi
  801354:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801358:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80135c:	83 c4 1c             	add    $0x1c,%esp
  80135f:	c3                   	ret    
  801360:	85 c9                	test   %ecx,%ecx
  801362:	75 0b                	jne    80136f <__umoddi3+0x8f>
  801364:	b8 01 00 00 00       	mov    $0x1,%eax
  801369:	31 d2                	xor    %edx,%edx
  80136b:	f7 f1                	div    %ecx
  80136d:	89 c1                	mov    %eax,%ecx
  80136f:	89 f0                	mov    %esi,%eax
  801371:	31 d2                	xor    %edx,%edx
  801373:	f7 f1                	div    %ecx
  801375:	8b 04 24             	mov    (%esp),%eax
  801378:	f7 f1                	div    %ecx
  80137a:	eb 98                	jmp    801314 <__umoddi3+0x34>
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	89 f2                	mov    %esi,%edx
  801382:	8b 74 24 10          	mov    0x10(%esp),%esi
  801386:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80138a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80138e:	83 c4 1c             	add    $0x1c,%esp
  801391:	c3                   	ret    
  801392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801398:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80139d:	89 e8                	mov    %ebp,%eax
  80139f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8013a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8013a8:	89 fa                	mov    %edi,%edx
  8013aa:	d3 e0                	shl    %cl,%eax
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	d3 ea                	shr    %cl,%edx
  8013b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013b5:	09 c2                	or     %eax,%edx
  8013b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013bb:	89 14 24             	mov    %edx,(%esp)
  8013be:	89 f2                	mov    %esi,%edx
  8013c0:	d3 e7                	shl    %cl,%edi
  8013c2:	89 e9                	mov    %ebp,%ecx
  8013c4:	d3 ea                	shr    %cl,%edx
  8013c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013cf:	d3 e6                	shl    %cl,%esi
  8013d1:	89 e9                	mov    %ebp,%ecx
  8013d3:	d3 e8                	shr    %cl,%eax
  8013d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013da:	09 f0                	or     %esi,%eax
  8013dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8013e0:	f7 34 24             	divl   (%esp)
  8013e3:	d3 e6                	shl    %cl,%esi
  8013e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013e9:	89 d6                	mov    %edx,%esi
  8013eb:	f7 e7                	mul    %edi
  8013ed:	39 d6                	cmp    %edx,%esi
  8013ef:	89 c1                	mov    %eax,%ecx
  8013f1:	89 d7                	mov    %edx,%edi
  8013f3:	72 3f                	jb     801434 <__umoddi3+0x154>
  8013f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013f9:	72 35                	jb     801430 <__umoddi3+0x150>
  8013fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013ff:	29 c8                	sub    %ecx,%eax
  801401:	19 fe                	sbb    %edi,%esi
  801403:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801408:	89 f2                	mov    %esi,%edx
  80140a:	d3 e8                	shr    %cl,%eax
  80140c:	89 e9                	mov    %ebp,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801415:	09 d0                	or     %edx,%eax
  801417:	89 f2                	mov    %esi,%edx
  801419:	d3 ea                	shr    %cl,%edx
  80141b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80141f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801423:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801427:	83 c4 1c             	add    $0x1c,%esp
  80142a:	c3                   	ret    
  80142b:	90                   	nop
  80142c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801430:	39 d6                	cmp    %edx,%esi
  801432:	75 c7                	jne    8013fb <__umoddi3+0x11b>
  801434:	89 d7                	mov    %edx,%edi
  801436:	89 c1                	mov    %eax,%ecx
  801438:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80143c:	1b 3c 24             	sbb    (%esp),%edi
  80143f:	eb ba                	jmp    8013fb <__umoddi3+0x11b>
  801441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801448:	39 f5                	cmp    %esi,%ebp
  80144a:	0f 82 f1 fe ff ff    	jb     801341 <__umoddi3+0x61>
  801450:	e9 f8 fe ff ff       	jmp    80134d <__umoddi3+0x6d>
