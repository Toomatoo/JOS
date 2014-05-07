
obj/user/faultalloc.debug:     file format elf32-i386


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
  800044:	c7 04 24 60 24 80 00 	movl   $0x802460,(%esp)
  80004b:	e8 0f 02 00 00       	call   80025f <cprintf>
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
  80007b:	c7 44 24 08 80 24 80 	movl   $0x802480,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 6a 24 80 00 	movl   $0x80246a,(%esp)
  800092:	e8 cd 00 00 00       	call   800164 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ac 24 80 	movl   $0x8024ac,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 80 08 00 00       	call   800933 <snprintf>
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
  8000c6:	e8 d9 10 00 00       	call   8011a4 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  8000da:	e8 80 01 00 00       	call   80025f <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  8000ee:	e8 6c 01 00 00       	call   80025f <cprintf>
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
  80011c:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  80014e:	e8 2b 13 00 00       	call   80147e <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 90 0c 00 00       	call   800def <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	00 00                	add    %al,(%eax)
	...

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80016c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800175:	e8 d2 0c 00 00       	call   800e4c <sys_getenvid>
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800188:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800190:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  800197:	e8 c3 00 00 00       	call   80025f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a3:	89 04 24             	mov    %eax,(%esp)
  8001a6:	e8 53 00 00 00       	call   8001fe <vcprintf>
	cprintf("\n");
  8001ab:	c7 04 24 97 29 80 00 	movl   $0x802997,(%esp)
  8001b2:	e8 a8 00 00 00       	call   80025f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x53>
	...

008001bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 14             	sub    $0x14,%esp
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c6:	8b 03                	mov    (%ebx),%eax
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cf:	83 c0 01             	add    $0x1,%eax
  8001d2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d9:	75 19                	jne    8001f4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001db:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e2:	00 
  8001e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	e8 a2 0b 00 00       	call   800d90 <sys_cputs>
		b->idx = 0;
  8001ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f8:	83 c4 14             	add    $0x14,%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800207:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020e:	00 00 00 
	b.cnt = 0;
  800211:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800218:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	89 44 24 08          	mov    %eax,0x8(%esp)
  800229:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800233:	c7 04 24 bc 01 80 00 	movl   $0x8001bc,(%esp)
  80023a:	e8 97 01 00 00       	call   8003d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024f:	89 04 24             	mov    %eax,(%esp)
  800252:	e8 39 0b 00 00       	call   800d90 <sys_cputs>

	return b.cnt;
}
  800257:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800265:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	8b 45 08             	mov    0x8(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 87 ff ff ff       	call   8001fe <vcprintf>
	va_end(ap);

	return cnt;
}
  800277:	c9                   	leave  
  800278:	c3                   	ret    
  800279:	00 00                	add    %al,(%eax)
	...

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 3c             	sub    $0x3c,%esp
  800285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800288:	89 d7                	mov    %edx,%edi
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029c:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a4:	72 11                	jb     8002b7 <printnum+0x3b>
  8002a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ac:	76 09                	jbe    8002b7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ae:	83 eb 01             	sub    $0x1,%ebx
  8002b1:	85 db                	test   %ebx,%ebx
  8002b3:	7f 51                	jg     800306 <printnum+0x8a>
  8002b5:	eb 5e                	jmp    800315 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002bb:	83 eb 01             	sub    $0x1,%ebx
  8002be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002cd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d8:	00 
  8002d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e6:	e8 c5 1e 00 00       	call   8021b0 <__udivdi3>
  8002eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fa:	89 fa                	mov    %edi,%edx
  8002fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ff:	e8 78 ff ff ff       	call   80027c <printnum>
  800304:	eb 0f                	jmp    800315 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800306:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030a:	89 34 24             	mov    %esi,(%esp)
  80030d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800310:	83 eb 01             	sub    $0x1,%ebx
  800313:	75 f1                	jne    800306 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800315:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800319:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031d:	8b 45 10             	mov    0x10(%ebp),%eax
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032b:	00 
  80032c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	e8 a2 1f 00 00       	call   8022e0 <__umoddi3>
  80033e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800342:	0f be 80 fb 24 80 00 	movsbl 0x8024fb(%eax),%eax
  800349:	89 04 24             	mov    %eax,(%esp)
  80034c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034f:	83 c4 3c             	add    $0x3c,%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035a:	83 fa 01             	cmp    $0x1,%edx
  80035d:	7e 0e                	jle    80036d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	8d 4a 08             	lea    0x8(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 02                	mov    (%edx),%eax
  800368:	8b 52 04             	mov    0x4(%edx),%edx
  80036b:	eb 22                	jmp    80038f <getuint+0x38>
	else if (lflag)
  80036d:	85 d2                	test   %edx,%edx
  80036f:	74 10                	je     800381 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800371:	8b 10                	mov    (%eax),%edx
  800373:	8d 4a 04             	lea    0x4(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 02                	mov    (%edx),%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
  80037f:	eb 0e                	jmp    80038f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800381:	8b 10                	mov    (%eax),%edx
  800383:	8d 4a 04             	lea    0x4(%edx),%ecx
  800386:	89 08                	mov    %ecx,(%eax)
  800388:	8b 02                	mov    (%edx),%eax
  80038a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800397:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a0:	73 0a                	jae    8003ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a5:	88 0a                	mov    %cl,(%edx)
  8003a7:	83 c2 01             	add    $0x1,%edx
  8003aa:	89 10                	mov    %edx,(%eax)
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8003be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	e8 02 00 00 00       	call   8003d6 <vprintfmt>
	va_end(ap);
}
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	57                   	push   %edi
  8003da:	56                   	push   %esi
  8003db:	53                   	push   %ebx
  8003dc:	83 ec 5c             	sub    $0x5c,%esp
  8003df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e5:	eb 12                	jmp    8003f9 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	0f 84 e4 04 00 00    	je     8008d3 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f3:	89 04 24             	mov    %eax,(%esp)
  8003f6:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f9:	0f b6 06             	movzbl (%esi),%eax
  8003fc:	83 c6 01             	add    $0x1,%esi
  8003ff:	83 f8 25             	cmp    $0x25,%eax
  800402:	75 e3                	jne    8003e7 <vprintfmt+0x11>
  800404:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800408:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80040f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800414:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80041b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800420:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800423:	eb 2b                	jmp    800450 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800428:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80042c:	eb 22                	jmp    800450 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800431:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800435:	eb 19                	jmp    800450 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80043a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800441:	eb 0d                	jmp    800450 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800443:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800446:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800449:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	0f b6 06             	movzbl (%esi),%eax
  800453:	0f b6 d0             	movzbl %al,%edx
  800456:	8d 7e 01             	lea    0x1(%esi),%edi
  800459:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045c:	83 e8 23             	sub    $0x23,%eax
  80045f:	3c 55                	cmp    $0x55,%al
  800461:	0f 87 46 04 00 00    	ja     8008ad <vprintfmt+0x4d7>
  800467:	0f b6 c0             	movzbl %al,%eax
  80046a:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800471:	83 ea 30             	sub    $0x30,%edx
  800474:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800477:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80047b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800481:	83 fa 09             	cmp    $0x9,%edx
  800484:	77 4a                	ja     8004d0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800489:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80048c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80048f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800493:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800496:	8d 50 d0             	lea    -0x30(%eax),%edx
  800499:	83 fa 09             	cmp    $0x9,%edx
  80049c:	76 eb                	jbe    800489 <vprintfmt+0xb3>
  80049e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004a1:	eb 2d                	jmp    8004d0 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 50 04             	lea    0x4(%eax),%edx
  8004a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ac:	8b 00                	mov    (%eax),%eax
  8004ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b4:	eb 1a                	jmp    8004d0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004b9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004bd:	79 91                	jns    800450 <vprintfmt+0x7a>
  8004bf:	e9 73 ff ff ff       	jmp    800437 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004ce:	eb 80                	jmp    800450 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004d0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d4:	0f 89 76 ff ff ff    	jns    800450 <vprintfmt+0x7a>
  8004da:	e9 64 ff ff ff       	jmp    800443 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004df:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e5:	e9 66 ff ff ff       	jmp    800450 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f7:	8b 00                	mov    (%eax),%eax
  8004f9:	89 04 24             	mov    %eax,(%esp)
  8004fc:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800502:	e9 f2 fe ff ff       	jmp    8003f9 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800507:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80050b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80050e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800512:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800515:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800519:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80051c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80051f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800523:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800526:	80 f9 09             	cmp    $0x9,%cl
  800529:	77 1d                	ja     800548 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80052b:	0f be c0             	movsbl %al,%eax
  80052e:	6b c0 64             	imul   $0x64,%eax,%eax
  800531:	0f be d2             	movsbl %dl,%edx
  800534:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800537:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80053e:	a3 04 30 80 00       	mov    %eax,0x803004
  800543:	e9 b1 fe ff ff       	jmp    8003f9 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800548:	c7 44 24 04 13 25 80 	movl   $0x802513,0x4(%esp)
  80054f:	00 
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	e8 10 05 00 00       	call   800a6b <strcmp>
  80055b:	85 c0                	test   %eax,%eax
  80055d:	75 0f                	jne    80056e <vprintfmt+0x198>
  80055f:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800566:	00 00 00 
  800569:	e9 8b fe ff ff       	jmp    8003f9 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80056e:	c7 44 24 04 17 25 80 	movl   $0x802517,0x4(%esp)
  800575:	00 
  800576:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800579:	89 14 24             	mov    %edx,(%esp)
  80057c:	e8 ea 04 00 00       	call   800a6b <strcmp>
  800581:	85 c0                	test   %eax,%eax
  800583:	75 0f                	jne    800594 <vprintfmt+0x1be>
  800585:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  80058c:	00 00 00 
  80058f:	e9 65 fe ff ff       	jmp    8003f9 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800594:	c7 44 24 04 1b 25 80 	movl   $0x80251b,0x4(%esp)
  80059b:	00 
  80059c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80059f:	89 0c 24             	mov    %ecx,(%esp)
  8005a2:	e8 c4 04 00 00       	call   800a6b <strcmp>
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	75 0f                	jne    8005ba <vprintfmt+0x1e4>
  8005ab:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8005b2:	00 00 00 
  8005b5:	e9 3f fe ff ff       	jmp    8003f9 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005ba:	c7 44 24 04 1f 25 80 	movl   $0x80251f,0x4(%esp)
  8005c1:	00 
  8005c2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005c5:	89 3c 24             	mov    %edi,(%esp)
  8005c8:	e8 9e 04 00 00       	call   800a6b <strcmp>
  8005cd:	85 c0                	test   %eax,%eax
  8005cf:	75 0f                	jne    8005e0 <vprintfmt+0x20a>
  8005d1:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  8005d8:	00 00 00 
  8005db:	e9 19 fe ff ff       	jmp    8003f9 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005e0:	c7 44 24 04 23 25 80 	movl   $0x802523,0x4(%esp)
  8005e7:	00 
  8005e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 78 04 00 00       	call   800a6b <strcmp>
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	75 0f                	jne    800606 <vprintfmt+0x230>
  8005f7:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  8005fe:	00 00 00 
  800601:	e9 f3 fd ff ff       	jmp    8003f9 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800606:	c7 44 24 04 27 25 80 	movl   $0x802527,0x4(%esp)
  80060d:	00 
  80060e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800611:	89 14 24             	mov    %edx,(%esp)
  800614:	e8 52 04 00 00       	call   800a6b <strcmp>
  800619:	83 f8 01             	cmp    $0x1,%eax
  80061c:	19 c0                	sbb    %eax,%eax
  80061e:	f7 d0                	not    %eax
  800620:	83 c0 08             	add    $0x8,%eax
  800623:	a3 04 30 80 00       	mov    %eax,0x803004
  800628:	e9 cc fd ff ff       	jmp    8003f9 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 00                	mov    (%eax),%eax
  800638:	89 c2                	mov    %eax,%edx
  80063a:	c1 fa 1f             	sar    $0x1f,%edx
  80063d:	31 d0                	xor    %edx,%eax
  80063f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800641:	83 f8 0f             	cmp    $0xf,%eax
  800644:	7f 0b                	jg     800651 <vprintfmt+0x27b>
  800646:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  80064d:	85 d2                	test   %edx,%edx
  80064f:	75 23                	jne    800674 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800651:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800655:	c7 44 24 08 2b 25 80 	movl   $0x80252b,0x8(%esp)
  80065c:	00 
  80065d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800661:	8b 7d 08             	mov    0x8(%ebp),%edi
  800664:	89 3c 24             	mov    %edi,(%esp)
  800667:	e8 42 fd ff ff       	call   8003ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066f:	e9 85 fd ff ff       	jmp    8003f9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800674:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800678:	c7 44 24 08 65 29 80 	movl   $0x802965,0x8(%esp)
  80067f:	00 
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	8b 7d 08             	mov    0x8(%ebp),%edi
  800687:	89 3c 24             	mov    %edi,(%esp)
  80068a:	e8 1f fd ff ff       	call   8003ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800692:	e9 62 fd ff ff       	jmp    8003f9 <vprintfmt+0x23>
  800697:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80069a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80069d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006ab:	85 f6                	test   %esi,%esi
  8006ad:	b8 0c 25 80 00       	mov    $0x80250c,%eax
  8006b2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006b5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006b9:	7e 06                	jle    8006c1 <vprintfmt+0x2eb>
  8006bb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006bf:	75 13                	jne    8006d4 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c1:	0f be 06             	movsbl (%esi),%eax
  8006c4:	83 c6 01             	add    $0x1,%esi
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	0f 85 94 00 00 00    	jne    800763 <vprintfmt+0x38d>
  8006cf:	e9 81 00 00 00       	jmp    800755 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d8:	89 34 24             	mov    %esi,(%esp)
  8006db:	e8 9b 02 00 00       	call   80097b <strnlen>
  8006e0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e3:	29 c2                	sub    %eax,%edx
  8006e5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	7e d5                	jle    8006c1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006ec:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006f0:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006f3:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006f6:	89 d6                	mov    %edx,%esi
  8006f8:	89 cf                	mov    %ecx,%edi
  8006fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fe:	89 3c 24             	mov    %edi,(%esp)
  800701:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800704:	83 ee 01             	sub    $0x1,%esi
  800707:	75 f1                	jne    8006fa <vprintfmt+0x324>
  800709:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80070c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80070f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800712:	eb ad                	jmp    8006c1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x35f>
  80071a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80071d:	83 fa 5e             	cmp    $0x5e,%edx
  800720:	76 13                	jbe    800735 <vprintfmt+0x35f>
					putch('?', putdat);
  800722:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800735:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800738:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	0f be 06             	movsbl (%esi),%eax
  800748:	83 c6 01             	add    $0x1,%esi
  80074b:	85 c0                	test   %eax,%eax
  80074d:	75 1a                	jne    800769 <vprintfmt+0x393>
  80074f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800752:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800755:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800758:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80075c:	7f 1c                	jg     80077a <vprintfmt+0x3a4>
  80075e:	e9 96 fc ff ff       	jmp    8003f9 <vprintfmt+0x23>
  800763:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800766:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800769:	85 ff                	test   %edi,%edi
  80076b:	78 a7                	js     800714 <vprintfmt+0x33e>
  80076d:	83 ef 01             	sub    $0x1,%edi
  800770:	79 a2                	jns    800714 <vprintfmt+0x33e>
  800772:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800775:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800778:	eb db                	jmp    800755 <vprintfmt+0x37f>
  80077a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077d:	89 de                	mov    %ebx,%esi
  80077f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800782:	89 74 24 04          	mov    %esi,0x4(%esp)
  800786:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80078d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078f:	83 eb 01             	sub    $0x1,%ebx
  800792:	75 ee                	jne    800782 <vprintfmt+0x3ac>
  800794:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800796:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800799:	e9 5b fc ff ff       	jmp    8003f9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079e:	83 f9 01             	cmp    $0x1,%ecx
  8007a1:	7e 10                	jle    8007b3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 08             	lea    0x8(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ac:	8b 30                	mov    (%eax),%esi
  8007ae:	8b 78 04             	mov    0x4(%eax),%edi
  8007b1:	eb 26                	jmp    8007d9 <vprintfmt+0x403>
	else if (lflag)
  8007b3:	85 c9                	test   %ecx,%ecx
  8007b5:	74 12                	je     8007c9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 04             	lea    0x4(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c0:	8b 30                	mov    (%eax),%esi
  8007c2:	89 f7                	mov    %esi,%edi
  8007c4:	c1 ff 1f             	sar    $0x1f,%edi
  8007c7:	eb 10                	jmp    8007d9 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 50 04             	lea    0x4(%eax),%edx
  8007cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d2:	8b 30                	mov    (%eax),%esi
  8007d4:	89 f7                	mov    %esi,%edi
  8007d6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d9:	85 ff                	test   %edi,%edi
  8007db:	78 0e                	js     8007eb <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e1:	be 0a 00 00 00       	mov    $0xa,%esi
  8007e6:	e9 84 00 00 00       	jmp    80086f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007f6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	89 fa                	mov    %edi,%edx
  8007fd:	f7 d8                	neg    %eax
  8007ff:	83 d2 00             	adc    $0x0,%edx
  800802:	f7 da                	neg    %edx
			}
			base = 10;
  800804:	be 0a 00 00 00       	mov    $0xa,%esi
  800809:	eb 64                	jmp    80086f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80080b:	89 ca                	mov    %ecx,%edx
  80080d:	8d 45 14             	lea    0x14(%ebp),%eax
  800810:	e8 42 fb ff ff       	call   800357 <getuint>
			base = 10;
  800815:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80081a:	eb 53                	jmp    80086f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80081c:	89 ca                	mov    %ecx,%edx
  80081e:	8d 45 14             	lea    0x14(%ebp),%eax
  800821:	e8 31 fb ff ff       	call   800357 <getuint>
    			base = 8;
  800826:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80082b:	eb 42                	jmp    80086f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80082d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800831:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800838:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80083b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800846:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8d 50 04             	lea    0x4(%eax),%edx
  80084f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800852:	8b 00                	mov    (%eax),%eax
  800854:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800859:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80085e:	eb 0f                	jmp    80086f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800860:	89 ca                	mov    %ecx,%edx
  800862:	8d 45 14             	lea    0x14(%ebp),%eax
  800865:	e8 ed fa ff ff       	call   800357 <getuint>
			base = 16;
  80086a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800873:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800877:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80087a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80087e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	89 54 24 04          	mov    %edx,0x4(%esp)
  800889:	89 da                	mov    %ebx,%edx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	e8 e9 f9 ff ff       	call   80027c <printnum>
			break;
  800893:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800896:	e9 5e fb ff ff       	jmp    8003f9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089f:	89 14 24             	mov    %edx,(%esp)
  8008a2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a8:	e9 4c fb ff ff       	jmp    8003f9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008bb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008bf:	0f 84 34 fb ff ff    	je     8003f9 <vprintfmt+0x23>
  8008c5:	83 ee 01             	sub    $0x1,%esi
  8008c8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008cc:	75 f7                	jne    8008c5 <vprintfmt+0x4ef>
  8008ce:	e9 26 fb ff ff       	jmp    8003f9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008d3:	83 c4 5c             	add    $0x5c,%esp
  8008d6:	5b                   	pop    %ebx
  8008d7:	5e                   	pop    %esi
  8008d8:	5f                   	pop    %edi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 28             	sub    $0x28,%esp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	74 30                	je     80092c <vsnprintf+0x51>
  8008fc:	85 d2                	test   %edx,%edx
  8008fe:	7e 2c                	jle    80092c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800907:	8b 45 10             	mov    0x10(%ebp),%eax
  80090a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800911:	89 44 24 04          	mov    %eax,0x4(%esp)
  800915:	c7 04 24 91 03 80 00 	movl   $0x800391,(%esp)
  80091c:	e8 b5 fa ff ff       	call   8003d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800921:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800924:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092a:	eb 05                	jmp    800931 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80092c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800939:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800940:	8b 45 10             	mov    0x10(%ebp),%eax
  800943:	89 44 24 08          	mov    %eax,0x8(%esp)
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	89 04 24             	mov    %eax,(%esp)
  800954:	e8 82 ff ff ff       	call   8008db <vsnprintf>
	va_end(ap);

	return rc;
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    
  80095b:	00 00                	add    %al,(%eax)
  80095d:	00 00                	add    %al,(%eax)
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
  800e23:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800e3a:	e8 25 f3 ff ff       	call   800164 <_panic>

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
  800e90:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800ee2:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef1:	00 
  800ef2:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800ef9:	e8 66 f2 ff ff       	call   800164 <_panic>

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
  800f40:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800f47:	00 
  800f48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4f:	00 
  800f50:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800f57:	e8 08 f2 ff ff       	call   800164 <_panic>

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
  800f9e:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800fa5:	00 
  800fa6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fad:	00 
  800fae:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800fb5:	e8 aa f1 ff ff       	call   800164 <_panic>

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
  800ffc:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801003:	00 
  801004:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100b:	00 
  80100c:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801013:	e8 4c f1 ff ff       	call   800164 <_panic>

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

00801025 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  80104c:	7e 28                	jle    801076 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801052:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801059:	00 
  80105a:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801061:	00 
  801062:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801069:	00 
  80106a:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801071:	e8 ee f0 ff ff       	call   800164 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801076:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801079:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107f:	89 ec                	mov    %ebp,%esp
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 38             	sub    $0x38,%esp
  801089:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80108f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
  801097:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a2:	89 df                	mov    %ebx,%edi
  8010a4:	89 de                	mov    %ebx,%esi
  8010a6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	7e 28                	jle    8010d4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  8010cf:	e8 90 f0 ff ff       	call   800164 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010da:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010dd:	89 ec                	mov    %ebp,%esp
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ed:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f0:	be 00 00 00 00       	mov    $0x0,%esi
  8010f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801100:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
  801106:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801108:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80110b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801111:	89 ec                	mov    %ebp,%esp
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 38             	sub    $0x38,%esp
  80111b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801121:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801124:	b9 00 00 00 00       	mov    $0x0,%ecx
  801129:	b8 0d 00 00 00       	mov    $0xd,%eax
  80112e:	8b 55 08             	mov    0x8(%ebp),%edx
  801131:	89 cb                	mov    %ecx,%ebx
  801133:	89 cf                	mov    %ecx,%edi
  801135:	89 ce                	mov    %ecx,%esi
  801137:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801139:	85 c0                	test   %eax,%eax
  80113b:	7e 28                	jle    801165 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801141:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801148:	00 
  801149:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801160:	e8 ff ef ff ff       	call   800164 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801165:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801168:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80116e:	89 ec                	mov    %ebp,%esp
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80117b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80117e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801181:	b9 00 00 00 00       	mov    $0x0,%ecx
  801186:	b8 0e 00 00 00       	mov    $0xe,%eax
  80118b:	8b 55 08             	mov    0x8(%ebp),%edx
  80118e:	89 cb                	mov    %ecx,%ebx
  801190:	89 cf                	mov    %ecx,%edi
  801192:	89 ce                	mov    %ecx,%esi
  801194:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801196:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801199:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80119c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80119f:	89 ec                	mov    %ebp,%esp
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    
	...

008011a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011aa:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8011b1:	75 3c                	jne    8011ef <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8011b3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011c2:	ee 
  8011c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ca:	e8 dd fc ff ff       	call   800eac <sys_page_alloc>
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	79 1c                	jns    8011ef <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8011d3:	c7 44 24 08 4c 28 80 	movl   $0x80284c,0x8(%esp)
  8011da:	00 
  8011db:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8011e2:	00 
  8011e3:	c7 04 24 ae 28 80 00 	movl   $0x8028ae,(%esp)
  8011ea:	e8 75 ef ff ff       	call   800164 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8011f7:	c7 44 24 04 30 12 80 	movl   $0x801230,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801206:	e8 78 fe ff ff       	call   801083 <sys_env_set_pgfault_upcall>
  80120b:	85 c0                	test   %eax,%eax
  80120d:	79 1c                	jns    80122b <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80120f:	c7 44 24 08 78 28 80 	movl   $0x802878,0x8(%esp)
  801216:	00 
  801217:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80121e:	00 
  80121f:	c7 04 24 ae 28 80 00 	movl   $0x8028ae,(%esp)
  801226:	e8 39 ef ff ff       	call   800164 <_panic>
}
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    
  80122d:	00 00                	add    %al,(%eax)
	...

00801230 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801230:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801231:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801236:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801238:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80123b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80123f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801244:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  801248:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80124a:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  80124d:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80124e:	83 c4 04             	add    $0x4,%esp
    popfl
  801251:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  801252:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  801253:	c3                   	ret    
	...

00801260 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	05 00 00 00 30       	add    $0x30000000,%eax
  80126b:	c1 e8 0c             	shr    $0xc,%eax
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
  801279:	89 04 24             	mov    %eax,(%esp)
  80127c:	e8 df ff ff ff       	call   801260 <fd2num>
  801281:	05 20 00 0d 00       	add    $0xd0020,%eax
  801286:	c1 e0 0c             	shl    $0xc,%eax
}
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801292:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801297:	a8 01                	test   $0x1,%al
  801299:	74 34                	je     8012cf <fd_alloc+0x44>
  80129b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012a0:	a8 01                	test   $0x1,%al
  8012a2:	74 32                	je     8012d6 <fd_alloc+0x4b>
  8012a4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012a9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	c1 ea 16             	shr    $0x16,%edx
  8012b0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b7:	f6 c2 01             	test   $0x1,%dl
  8012ba:	74 1f                	je     8012db <fd_alloc+0x50>
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	c1 ea 0c             	shr    $0xc,%edx
  8012c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c8:	f6 c2 01             	test   $0x1,%dl
  8012cb:	75 17                	jne    8012e4 <fd_alloc+0x59>
  8012cd:	eb 0c                	jmp    8012db <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012cf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012d4:	eb 05                	jmp    8012db <fd_alloc+0x50>
  8012d6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012db:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e2:	eb 17                	jmp    8012fb <fd_alloc+0x70>
  8012e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ee:	75 b9                	jne    8012a9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012fb:	5b                   	pop    %ebx
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801304:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801309:	83 fa 1f             	cmp    $0x1f,%edx
  80130c:	77 3f                	ja     80134d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80130e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801314:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801317:	89 d0                	mov    %edx,%eax
  801319:	c1 e8 16             	shr    $0x16,%eax
  80131c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801328:	f6 c1 01             	test   $0x1,%cl
  80132b:	74 20                	je     80134d <fd_lookup+0x4f>
  80132d:	89 d0                	mov    %edx,%eax
  80132f:	c1 e8 0c             	shr    $0xc,%eax
  801332:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80133e:	f6 c1 01             	test   $0x1,%cl
  801341:	74 0a                	je     80134d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801343:	8b 45 0c             	mov    0xc(%ebp),%eax
  801346:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801348:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	53                   	push   %ebx
  801353:	83 ec 14             	sub    $0x14,%esp
  801356:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80135c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801361:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801367:	75 17                	jne    801380 <dev_lookup+0x31>
  801369:	eb 07                	jmp    801372 <dev_lookup+0x23>
  80136b:	39 0a                	cmp    %ecx,(%edx)
  80136d:	75 11                	jne    801380 <dev_lookup+0x31>
  80136f:	90                   	nop
  801370:	eb 05                	jmp    801377 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801372:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801377:	89 13                	mov    %edx,(%ebx)
			return 0;
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
  80137e:	eb 35                	jmp    8013b5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801380:	83 c0 01             	add    $0x1,%eax
  801383:	8b 14 85 3c 29 80 00 	mov    0x80293c(,%eax,4),%edx
  80138a:	85 d2                	test   %edx,%edx
  80138c:	75 dd                	jne    80136b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80138e:	a1 04 40 80 00       	mov    0x804004,%eax
  801393:	8b 40 48             	mov    0x48(%eax),%eax
  801396:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139e:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  8013a5:	e8 b5 ee ff ff       	call   80025f <cprintf>
	*dev = 0;
  8013aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b5:	83 c4 14             	add    $0x14,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 38             	sub    $0x38,%esp
  8013c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013cd:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d1:	89 3c 24             	mov    %edi,(%esp)
  8013d4:	e8 87 fe ff ff       	call   801260 <fd2num>
  8013d9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8013dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e0:	89 04 24             	mov    %eax,(%esp)
  8013e3:	e8 16 ff ff ff       	call   8012fe <fd_lookup>
  8013e8:	89 c3                	mov    %eax,%ebx
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 05                	js     8013f3 <fd_close+0x38>
	    || fd != fd2)
  8013ee:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8013f1:	74 0e                	je     801401 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013f3:	89 f0                	mov    %esi,%eax
  8013f5:	84 c0                	test   %al,%al
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fc:	0f 44 d8             	cmove  %eax,%ebx
  8013ff:	eb 3d                	jmp    80143e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801401:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 07                	mov    (%edi),%eax
  80140a:	89 04 24             	mov    %eax,(%esp)
  80140d:	e8 3d ff ff ff       	call   80134f <dev_lookup>
  801412:	89 c3                	mov    %eax,%ebx
  801414:	85 c0                	test   %eax,%eax
  801416:	78 16                	js     80142e <fd_close+0x73>
		if (dev->dev_close)
  801418:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80141b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801423:	85 c0                	test   %eax,%eax
  801425:	74 07                	je     80142e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801427:	89 3c 24             	mov    %edi,(%esp)
  80142a:	ff d0                	call   *%eax
  80142c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80142e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801432:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801439:	e8 2b fb ff ff       	call   800f69 <sys_page_unmap>
	return r;
}
  80143e:	89 d8                	mov    %ebx,%eax
  801440:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801443:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801446:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801449:	89 ec                	mov    %ebp,%esp
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801453:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	89 04 24             	mov    %eax,(%esp)
  801460:	e8 99 fe ff ff       	call   8012fe <fd_lookup>
  801465:	85 c0                	test   %eax,%eax
  801467:	78 13                	js     80147c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801469:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801470:	00 
  801471:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801474:	89 04 24             	mov    %eax,(%esp)
  801477:	e8 3f ff ff ff       	call   8013bb <fd_close>
}
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <close_all>:

void
close_all(void)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	53                   	push   %ebx
  801482:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801485:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80148a:	89 1c 24             	mov    %ebx,(%esp)
  80148d:	e8 bb ff ff ff       	call   80144d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801492:	83 c3 01             	add    $0x1,%ebx
  801495:	83 fb 20             	cmp    $0x20,%ebx
  801498:	75 f0                	jne    80148a <close_all+0xc>
		close(i);
}
  80149a:	83 c4 14             	add    $0x14,%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    

008014a0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	83 ec 58             	sub    $0x58,%esp
  8014a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014af:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bc:	89 04 24             	mov    %eax,(%esp)
  8014bf:	e8 3a fe ff ff       	call   8012fe <fd_lookup>
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	0f 88 e1 00 00 00    	js     8015af <dup+0x10f>
		return r;
	close(newfdnum);
  8014ce:	89 3c 24             	mov    %edi,(%esp)
  8014d1:	e8 77 ff ff ff       	call   80144d <close>

	newfd = INDEX2FD(newfdnum);
  8014d6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014dc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	e8 86 fd ff ff       	call   801270 <fd2data>
  8014ea:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014ec:	89 34 24             	mov    %esi,(%esp)
  8014ef:	e8 7c fd ff ff       	call   801270 <fd2data>
  8014f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f7:	89 d8                	mov    %ebx,%eax
  8014f9:	c1 e8 16             	shr    $0x16,%eax
  8014fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801503:	a8 01                	test   $0x1,%al
  801505:	74 46                	je     80154d <dup+0xad>
  801507:	89 d8                	mov    %ebx,%eax
  801509:	c1 e8 0c             	shr    $0xc,%eax
  80150c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801513:	f6 c2 01             	test   $0x1,%dl
  801516:	74 35                	je     80154d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801518:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151f:	25 07 0e 00 00       	and    $0xe07,%eax
  801524:	89 44 24 10          	mov    %eax,0x10(%esp)
  801528:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80152b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80152f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801536:	00 
  801537:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80153b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801542:	e8 c4 f9 ff ff       	call   800f0b <sys_page_map>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 3b                	js     801588 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80154d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801550:	89 c2                	mov    %eax,%edx
  801552:	c1 ea 0c             	shr    $0xc,%edx
  801555:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801562:	89 54 24 10          	mov    %edx,0x10(%esp)
  801566:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80156a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801571:	00 
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157d:	e8 89 f9 ff ff       	call   800f0b <sys_page_map>
  801582:	89 c3                	mov    %eax,%ebx
  801584:	85 c0                	test   %eax,%eax
  801586:	79 25                	jns    8015ad <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801588:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801593:	e8 d1 f9 ff ff       	call   800f69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801598:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80159b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a6:	e8 be f9 ff ff       	call   800f69 <sys_page_unmap>
	return r;
  8015ab:	eb 02                	jmp    8015af <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015ad:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015af:	89 d8                	mov    %ebx,%eax
  8015b1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015b4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ba:	89 ec                	mov    %ebp,%esp
  8015bc:	5d                   	pop    %ebp
  8015bd:	c3                   	ret    

008015be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 24             	sub    $0x24,%esp
  8015c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cf:	89 1c 24             	mov    %ebx,(%esp)
  8015d2:	e8 27 fd ff ff       	call   8012fe <fd_lookup>
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 6d                	js     801648 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	8b 00                	mov    (%eax),%eax
  8015e7:	89 04 24             	mov    %eax,(%esp)
  8015ea:	e8 60 fd ff ff       	call   80134f <dev_lookup>
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 55                	js     801648 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	8b 50 08             	mov    0x8(%eax),%edx
  8015f9:	83 e2 03             	and    $0x3,%edx
  8015fc:	83 fa 01             	cmp    $0x1,%edx
  8015ff:	75 23                	jne    801624 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801601:	a1 04 40 80 00       	mov    0x804004,%eax
  801606:	8b 40 48             	mov    0x48(%eax),%eax
  801609:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80160d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801611:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
  801618:	e8 42 ec ff ff       	call   80025f <cprintf>
		return -E_INVAL;
  80161d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801622:	eb 24                	jmp    801648 <read+0x8a>
	}
	if (!dev->dev_read)
  801624:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801627:	8b 52 08             	mov    0x8(%edx),%edx
  80162a:	85 d2                	test   %edx,%edx
  80162c:	74 15                	je     801643 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80162e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801631:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801638:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	ff d2                	call   *%edx
  801641:	eb 05                	jmp    801648 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801643:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801648:	83 c4 24             	add    $0x24,%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	57                   	push   %edi
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 1c             	sub    $0x1c,%esp
  801657:	8b 7d 08             	mov    0x8(%ebp),%edi
  80165a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165d:	b8 00 00 00 00       	mov    $0x0,%eax
  801662:	85 f6                	test   %esi,%esi
  801664:	74 30                	je     801696 <readn+0x48>
  801666:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80166b:	89 f2                	mov    %esi,%edx
  80166d:	29 c2                	sub    %eax,%edx
  80166f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801673:	03 45 0c             	add    0xc(%ebp),%eax
  801676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167a:	89 3c 24             	mov    %edi,(%esp)
  80167d:	e8 3c ff ff ff       	call   8015be <read>
		if (m < 0)
  801682:	85 c0                	test   %eax,%eax
  801684:	78 10                	js     801696 <readn+0x48>
			return m;
		if (m == 0)
  801686:	85 c0                	test   %eax,%eax
  801688:	74 0a                	je     801694 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80168a:	01 c3                	add    %eax,%ebx
  80168c:	89 d8                	mov    %ebx,%eax
  80168e:	39 f3                	cmp    %esi,%ebx
  801690:	72 d9                	jb     80166b <readn+0x1d>
  801692:	eb 02                	jmp    801696 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801694:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801696:	83 c4 1c             	add    $0x1c,%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5f                   	pop    %edi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 24             	sub    $0x24,%esp
  8016a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016af:	89 1c 24             	mov    %ebx,(%esp)
  8016b2:	e8 47 fc ff ff       	call   8012fe <fd_lookup>
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 68                	js     801723 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c5:	8b 00                	mov    (%eax),%eax
  8016c7:	89 04 24             	mov    %eax,(%esp)
  8016ca:	e8 80 fc ff ff       	call   80134f <dev_lookup>
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 50                	js     801723 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016da:	75 23                	jne    8016ff <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e1:	8b 40 48             	mov    0x48(%eax),%eax
  8016e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ec:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8016f3:	e8 67 eb ff ff       	call   80025f <cprintf>
		return -E_INVAL;
  8016f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fd:	eb 24                	jmp    801723 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801702:	8b 52 0c             	mov    0xc(%edx),%edx
  801705:	85 d2                	test   %edx,%edx
  801707:	74 15                	je     80171e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801709:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80170c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801713:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801717:	89 04 24             	mov    %eax,(%esp)
  80171a:	ff d2                	call   *%edx
  80171c:	eb 05                	jmp    801723 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80171e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801723:	83 c4 24             	add    $0x24,%esp
  801726:	5b                   	pop    %ebx
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <seek>:

int
seek(int fdnum, off_t offset)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80172f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801732:	89 44 24 04          	mov    %eax,0x4(%esp)
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	89 04 24             	mov    %eax,(%esp)
  80173c:	e8 bd fb ff ff       	call   8012fe <fd_lookup>
  801741:	85 c0                	test   %eax,%eax
  801743:	78 0e                	js     801753 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801745:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801748:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80174e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801753:	c9                   	leave  
  801754:	c3                   	ret    

00801755 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 24             	sub    $0x24,%esp
  80175c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801762:	89 44 24 04          	mov    %eax,0x4(%esp)
  801766:	89 1c 24             	mov    %ebx,(%esp)
  801769:	e8 90 fb ff ff       	call   8012fe <fd_lookup>
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 61                	js     8017d3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177c:	8b 00                	mov    (%eax),%eax
  80177e:	89 04 24             	mov    %eax,(%esp)
  801781:	e8 c9 fb ff ff       	call   80134f <dev_lookup>
  801786:	85 c0                	test   %eax,%eax
  801788:	78 49                	js     8017d3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801791:	75 23                	jne    8017b6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801793:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801798:	8b 40 48             	mov    0x48(%eax),%eax
  80179b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80179f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a3:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  8017aa:	e8 b0 ea ff ff       	call   80025f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b4:	eb 1d                	jmp    8017d3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b9:	8b 52 18             	mov    0x18(%edx),%edx
  8017bc:	85 d2                	test   %edx,%edx
  8017be:	74 0e                	je     8017ce <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017c7:	89 04 24             	mov    %eax,(%esp)
  8017ca:	ff d2                	call   *%edx
  8017cc:	eb 05                	jmp    8017d3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017d3:	83 c4 24             	add    $0x24,%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 24             	sub    $0x24,%esp
  8017e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 09 fb ff ff       	call   8012fe <fd_lookup>
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 52                	js     80184b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801803:	8b 00                	mov    (%eax),%eax
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	e8 42 fb ff ff       	call   80134f <dev_lookup>
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 3a                	js     80184b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801811:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801814:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801818:	74 2c                	je     801846 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80181a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80181d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801824:	00 00 00 
	stat->st_isdir = 0;
  801827:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80182e:	00 00 00 
	stat->st_dev = dev;
  801831:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801837:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80183e:	89 14 24             	mov    %edx,(%esp)
  801841:	ff 50 14             	call   *0x14(%eax)
  801844:	eb 05                	jmp    80184b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801846:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80184b:	83 c4 24             	add    $0x24,%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 18             	sub    $0x18,%esp
  801857:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80185a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80185d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801864:	00 
  801865:	8b 45 08             	mov    0x8(%ebp),%eax
  801868:	89 04 24             	mov    %eax,(%esp)
  80186b:	e8 bc 01 00 00       	call   801a2c <open>
  801870:	89 c3                	mov    %eax,%ebx
  801872:	85 c0                	test   %eax,%eax
  801874:	78 1b                	js     801891 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801876:	8b 45 0c             	mov    0xc(%ebp),%eax
  801879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187d:	89 1c 24             	mov    %ebx,(%esp)
  801880:	e8 54 ff ff ff       	call   8017d9 <fstat>
  801885:	89 c6                	mov    %eax,%esi
	close(fd);
  801887:	89 1c 24             	mov    %ebx,(%esp)
  80188a:	e8 be fb ff ff       	call   80144d <close>
	return r;
  80188f:	89 f3                	mov    %esi,%ebx
}
  801891:	89 d8                	mov    %ebx,%eax
  801893:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801896:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801899:	89 ec                	mov    %ebp,%esp
  80189b:	5d                   	pop    %ebp
  80189c:	c3                   	ret    
  80189d:	00 00                	add    %al,(%eax)
	...

008018a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	83 ec 18             	sub    $0x18,%esp
  8018a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018ac:	89 c3                	mov    %eax,%ebx
  8018ae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018b0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018b7:	75 11                	jne    8018ca <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018c0:	e8 5c 08 00 00       	call   802121 <ipc_find_env>
  8018c5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018d1:	00 
  8018d2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018d9:	00 
  8018da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018de:	a1 00 40 80 00       	mov    0x804000,%eax
  8018e3:	89 04 24             	mov    %eax,(%esp)
  8018e6:	e8 cb 07 00 00       	call   8020b6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8018eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018f2:	00 
  8018f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fe:	e8 4d 07 00 00       	call   802050 <ipc_recv>
}
  801903:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801906:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801909:	89 ec                	mov    %ebp,%esp
  80190b:	5d                   	pop    %ebp
  80190c:	c3                   	ret    

0080190d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	53                   	push   %ebx
  801911:	83 ec 14             	sub    $0x14,%esp
  801914:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	8b 40 0c             	mov    0xc(%eax),%eax
  80191d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801922:	ba 00 00 00 00       	mov    $0x0,%edx
  801927:	b8 05 00 00 00       	mov    $0x5,%eax
  80192c:	e8 6f ff ff ff       	call   8018a0 <fsipc>
  801931:	85 c0                	test   %eax,%eax
  801933:	78 2b                	js     801960 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801935:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80193c:	00 
  80193d:	89 1c 24             	mov    %ebx,(%esp)
  801940:	e8 66 f0 ff ff       	call   8009ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801945:	a1 80 50 80 00       	mov    0x805080,%eax
  80194a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801950:	a1 84 50 80 00       	mov    0x805084,%eax
  801955:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801960:	83 c4 14             	add    $0x14,%esp
  801963:	5b                   	pop    %ebx
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	8b 40 0c             	mov    0xc(%eax),%eax
  801972:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 06 00 00 00       	mov    $0x6,%eax
  801981:	e8 1a ff ff ff       	call   8018a0 <fsipc>
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	83 ec 10             	sub    $0x10,%esp
  801990:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	8b 40 0c             	mov    0xc(%eax),%eax
  801999:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80199e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ae:	e8 ed fe ff ff       	call   8018a0 <fsipc>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 6a                	js     801a23 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019b9:	39 c6                	cmp    %eax,%esi
  8019bb:	73 24                	jae    8019e1 <devfile_read+0x59>
  8019bd:	c7 44 24 0c 4c 29 80 	movl   $0x80294c,0xc(%esp)
  8019c4:	00 
  8019c5:	c7 44 24 08 53 29 80 	movl   $0x802953,0x8(%esp)
  8019cc:	00 
  8019cd:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8019d4:	00 
  8019d5:	c7 04 24 68 29 80 00 	movl   $0x802968,(%esp)
  8019dc:	e8 83 e7 ff ff       	call   800164 <_panic>
	assert(r <= PGSIZE);
  8019e1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019e6:	7e 24                	jle    801a0c <devfile_read+0x84>
  8019e8:	c7 44 24 0c 73 29 80 	movl   $0x802973,0xc(%esp)
  8019ef:	00 
  8019f0:	c7 44 24 08 53 29 80 	movl   $0x802953,0x8(%esp)
  8019f7:	00 
  8019f8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019ff:	00 
  801a00:	c7 04 24 68 29 80 00 	movl   $0x802968,(%esp)
  801a07:	e8 58 e7 ff ff       	call   800164 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a10:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a17:	00 
  801a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1b:	89 04 24             	mov    %eax,(%esp)
  801a1e:	e8 79 f1 ff ff       	call   800b9c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801a23:	89 d8                	mov    %ebx,%eax
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5e                   	pop    %esi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	83 ec 20             	sub    $0x20,%esp
  801a34:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a37:	89 34 24             	mov    %esi,(%esp)
  801a3a:	e8 21 ef ff ff       	call   800960 <strlen>
		return -E_BAD_PATH;
  801a3f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a44:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a49:	7f 5e                	jg     801aa9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	89 04 24             	mov    %eax,(%esp)
  801a51:	e8 35 f8 ff ff       	call   80128b <fd_alloc>
  801a56:	89 c3                	mov    %eax,%ebx
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 4d                	js     801aa9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a60:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a67:	e8 3f ef ff ff       	call   8009ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a77:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7c:	e8 1f fe ff ff       	call   8018a0 <fsipc>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	85 c0                	test   %eax,%eax
  801a85:	79 15                	jns    801a9c <open+0x70>
		fd_close(fd, 0);
  801a87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a8e:	00 
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 21 f9 ff ff       	call   8013bb <fd_close>
		return r;
  801a9a:	eb 0d                	jmp    801aa9 <open+0x7d>
	}

	return fd2num(fd);
  801a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9f:	89 04 24             	mov    %eax,(%esp)
  801aa2:	e8 b9 f7 ff ff       	call   801260 <fd2num>
  801aa7:	89 c3                	mov    %eax,%ebx
}
  801aa9:	89 d8                	mov    %ebx,%eax
  801aab:	83 c4 20             	add    $0x20,%esp
  801aae:	5b                   	pop    %ebx
  801aaf:	5e                   	pop    %esi
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    
	...

00801ac0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 18             	sub    $0x18,%esp
  801ac6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ac9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801acc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	89 04 24             	mov    %eax,(%esp)
  801ad5:	e8 96 f7 ff ff       	call   801270 <fd2data>
  801ada:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801adc:	c7 44 24 04 7f 29 80 	movl   $0x80297f,0x4(%esp)
  801ae3:	00 
  801ae4:	89 34 24             	mov    %esi,(%esp)
  801ae7:	e8 bf ee ff ff       	call   8009ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aec:	8b 43 04             	mov    0x4(%ebx),%eax
  801aef:	2b 03                	sub    (%ebx),%eax
  801af1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801af7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801afe:	00 00 00 
	stat->st_dev = &devpipe;
  801b01:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801b08:	30 80 00 
	return 0;
}
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b10:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b13:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b16:	89 ec                	mov    %ebp,%esp
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 14             	sub    $0x14,%esp
  801b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2f:	e8 35 f4 ff ff       	call   800f69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b34:	89 1c 24             	mov    %ebx,(%esp)
  801b37:	e8 34 f7 ff ff       	call   801270 <fd2data>
  801b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b47:	e8 1d f4 ff ff       	call   800f69 <sys_page_unmap>
}
  801b4c:	83 c4 14             	add    $0x14,%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	57                   	push   %edi
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 2c             	sub    $0x2c,%esp
  801b5b:	89 c7                	mov    %eax,%edi
  801b5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b60:	a1 04 40 80 00       	mov    0x804004,%eax
  801b65:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b68:	89 3c 24             	mov    %edi,(%esp)
  801b6b:	e8 fc 05 00 00       	call   80216c <pageref>
  801b70:	89 c6                	mov    %eax,%esi
  801b72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b75:	89 04 24             	mov    %eax,(%esp)
  801b78:	e8 ef 05 00 00       	call   80216c <pageref>
  801b7d:	39 c6                	cmp    %eax,%esi
  801b7f:	0f 94 c0             	sete   %al
  801b82:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b85:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b8b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b8e:	39 cb                	cmp    %ecx,%ebx
  801b90:	75 08                	jne    801b9a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b92:	83 c4 2c             	add    $0x2c,%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b9a:	83 f8 01             	cmp    $0x1,%eax
  801b9d:	75 c1                	jne    801b60 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b9f:	8b 52 58             	mov    0x58(%edx),%edx
  801ba2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ba6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801baa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bae:	c7 04 24 86 29 80 00 	movl   $0x802986,(%esp)
  801bb5:	e8 a5 e6 ff ff       	call   80025f <cprintf>
  801bba:	eb a4                	jmp    801b60 <_pipeisclosed+0xe>

00801bbc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	57                   	push   %edi
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 2c             	sub    $0x2c,%esp
  801bc5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bc8:	89 34 24             	mov    %esi,(%esp)
  801bcb:	e8 a0 f6 ff ff       	call   801270 <fd2data>
  801bd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801bd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bdb:	75 50                	jne    801c2d <devpipe_write+0x71>
  801bdd:	eb 5c                	jmp    801c3b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bdf:	89 da                	mov    %ebx,%edx
  801be1:	89 f0                	mov    %esi,%eax
  801be3:	e8 6a ff ff ff       	call   801b52 <_pipeisclosed>
  801be8:	85 c0                	test   %eax,%eax
  801bea:	75 53                	jne    801c3f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bec:	e8 8b f2 ff ff       	call   800e7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bf1:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf4:	8b 13                	mov    (%ebx),%edx
  801bf6:	83 c2 20             	add    $0x20,%edx
  801bf9:	39 d0                	cmp    %edx,%eax
  801bfb:	73 e2                	jae    801bdf <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c00:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801c04:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801c07:	89 c2                	mov    %eax,%edx
  801c09:	c1 fa 1f             	sar    $0x1f,%edx
  801c0c:	c1 ea 1b             	shr    $0x1b,%edx
  801c0f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801c12:	83 e1 1f             	and    $0x1f,%ecx
  801c15:	29 d1                	sub    %edx,%ecx
  801c17:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801c1b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801c1f:	83 c0 01             	add    $0x1,%eax
  801c22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c25:	83 c7 01             	add    $0x1,%edi
  801c28:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c2b:	74 0e                	je     801c3b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c2d:	8b 43 04             	mov    0x4(%ebx),%eax
  801c30:	8b 13                	mov    (%ebx),%edx
  801c32:	83 c2 20             	add    $0x20,%edx
  801c35:	39 d0                	cmp    %edx,%eax
  801c37:	73 a6                	jae    801bdf <devpipe_write+0x23>
  801c39:	eb c2                	jmp    801bfd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c3b:	89 f8                	mov    %edi,%eax
  801c3d:	eb 05                	jmp    801c44 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c44:	83 c4 2c             	add    $0x2c,%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5f                   	pop    %edi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 28             	sub    $0x28,%esp
  801c52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c58:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c5b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5e:	89 3c 24             	mov    %edi,(%esp)
  801c61:	e8 0a f6 ff ff       	call   801270 <fd2data>
  801c66:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c68:	be 00 00 00 00       	mov    $0x0,%esi
  801c6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c71:	75 47                	jne    801cba <devpipe_read+0x6e>
  801c73:	eb 52                	jmp    801cc7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c75:	89 f0                	mov    %esi,%eax
  801c77:	eb 5e                	jmp    801cd7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c79:	89 da                	mov    %ebx,%edx
  801c7b:	89 f8                	mov    %edi,%eax
  801c7d:	8d 76 00             	lea    0x0(%esi),%esi
  801c80:	e8 cd fe ff ff       	call   801b52 <_pipeisclosed>
  801c85:	85 c0                	test   %eax,%eax
  801c87:	75 49                	jne    801cd2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801c89:	e8 ee f1 ff ff       	call   800e7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c8e:	8b 03                	mov    (%ebx),%eax
  801c90:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c93:	74 e4                	je     801c79 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c95:	89 c2                	mov    %eax,%edx
  801c97:	c1 fa 1f             	sar    $0x1f,%edx
  801c9a:	c1 ea 1b             	shr    $0x1b,%edx
  801c9d:	01 d0                	add    %edx,%eax
  801c9f:	83 e0 1f             	and    $0x1f,%eax
  801ca2:	29 d0                	sub    %edx,%eax
  801ca4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cac:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801caf:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb2:	83 c6 01             	add    $0x1,%esi
  801cb5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cb8:	74 0d                	je     801cc7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801cba:	8b 03                	mov    (%ebx),%eax
  801cbc:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cbf:	75 d4                	jne    801c95 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cc1:	85 f6                	test   %esi,%esi
  801cc3:	75 b0                	jne    801c75 <devpipe_read+0x29>
  801cc5:	eb b2                	jmp    801c79 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc7:	89 f0                	mov    %esi,%eax
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	eb 05                	jmp    801cd7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ce0:	89 ec                	mov    %ebp,%esp
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 48             	sub    $0x48,%esp
  801cea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ced:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801cf0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801cf3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cf6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801cf9:	89 04 24             	mov    %eax,(%esp)
  801cfc:	e8 8a f5 ff ff       	call   80128b <fd_alloc>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	85 c0                	test   %eax,%eax
  801d05:	0f 88 45 01 00 00    	js     801e50 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d12:	00 
  801d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d21:	e8 86 f1 ff ff       	call   800eac <sys_page_alloc>
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	0f 88 20 01 00 00    	js     801e50 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d30:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d33:	89 04 24             	mov    %eax,(%esp)
  801d36:	e8 50 f5 ff ff       	call   80128b <fd_alloc>
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	0f 88 f8 00 00 00    	js     801e3d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d45:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d4c:	00 
  801d4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5b:	e8 4c f1 ff ff       	call   800eac <sys_page_alloc>
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	85 c0                	test   %eax,%eax
  801d64:	0f 88 d3 00 00 00    	js     801e3d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d6d:	89 04 24             	mov    %eax,(%esp)
  801d70:	e8 fb f4 ff ff       	call   801270 <fd2data>
  801d75:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d77:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d7e:	00 
  801d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8a:	e8 1d f1 ff ff       	call   800eac <sys_page_alloc>
  801d8f:	89 c3                	mov    %eax,%ebx
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 91 00 00 00    	js     801e2a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d99:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 cc f4 ff ff       	call   801270 <fd2data>
  801da4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801dab:	00 
  801dac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801db7:	00 
  801db8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc3:	e8 43 f1 ff ff       	call   800f0b <sys_page_map>
  801dc8:	89 c3                	mov    %eax,%ebx
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 4c                	js     801e1a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dce:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ddc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801de3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801df1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dfb:	89 04 24             	mov    %eax,(%esp)
  801dfe:	e8 5d f4 ff ff       	call   801260 <fd2num>
  801e03:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 50 f4 ff ff       	call   801260 <fd2num>
  801e10:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e18:	eb 36                	jmp    801e50 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801e1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e25:	e8 3f f1 ff ff       	call   800f69 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e38:	e8 2c f1 ff ff       	call   800f69 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4b:	e8 19 f1 ff ff       	call   800f69 <sys_page_unmap>
    err:
	return r;
}
  801e50:	89 d8                	mov    %ebx,%eax
  801e52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801e5b:	89 ec                	mov    %ebp,%esp
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6f:	89 04 24             	mov    %eax,(%esp)
  801e72:	e8 87 f4 ff ff       	call   8012fe <fd_lookup>
  801e77:	85 c0                	test   %eax,%eax
  801e79:	78 15                	js     801e90 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7e:	89 04 24             	mov    %eax,(%esp)
  801e81:	e8 ea f3 ff ff       	call   801270 <fd2data>
	return _pipeisclosed(fd, p);
  801e86:	89 c2                	mov    %eax,%edx
  801e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8b:	e8 c2 fc ff ff       	call   801b52 <_pipeisclosed>
}
  801e90:	c9                   	leave  
  801e91:	c3                   	ret    
	...

00801ea0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801eb0:	c7 44 24 04 9e 29 80 	movl   $0x80299e,0x4(%esp)
  801eb7:	00 
  801eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebb:	89 04 24             	mov    %eax,(%esp)
  801ebe:	e8 e8 ea ff ff       	call   8009ab <strcpy>
	return 0;
}
  801ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed6:	be 00 00 00 00       	mov    $0x0,%esi
  801edb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801edf:	74 43                	je     801f24 <devcons_write+0x5a>
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eef:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ef1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ef4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ef9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801efc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f00:	03 45 0c             	add    0xc(%ebp),%eax
  801f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f07:	89 3c 24             	mov    %edi,(%esp)
  801f0a:	e8 8d ec ff ff       	call   800b9c <memmove>
		sys_cputs(buf, m);
  801f0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f13:	89 3c 24             	mov    %edi,(%esp)
  801f16:	e8 75 ee ff ff       	call   800d90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f1b:	01 de                	add    %ebx,%esi
  801f1d:	89 f0                	mov    %esi,%eax
  801f1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f22:	72 c8                	jb     801eec <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f24:	89 f0                	mov    %esi,%eax
  801f26:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5f                   	pop    %edi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801f3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f40:	75 07                	jne    801f49 <devcons_read+0x18>
  801f42:	eb 31                	jmp    801f75 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f44:	e8 33 ef ff ff       	call   800e7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	e8 6a ee ff ff       	call   800dbf <sys_cgetc>
  801f55:	85 c0                	test   %eax,%eax
  801f57:	74 eb                	je     801f44 <devcons_read+0x13>
  801f59:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	78 16                	js     801f75 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f5f:	83 f8 04             	cmp    $0x4,%eax
  801f62:	74 0c                	je     801f70 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f67:	88 10                	mov    %dl,(%eax)
	return 1;
  801f69:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6e:	eb 05                	jmp    801f75 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f75:	c9                   	leave  
  801f76:	c3                   	ret    

00801f77 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f80:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f83:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f8a:	00 
  801f8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8e:	89 04 24             	mov    %eax,(%esp)
  801f91:	e8 fa ed ff ff       	call   800d90 <sys_cputs>
}
  801f96:	c9                   	leave  
  801f97:	c3                   	ret    

00801f98 <getchar>:

int
getchar(void)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f9e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801fa5:	00 
  801fa6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb4:	e8 05 f6 ff ff       	call   8015be <read>
	if (r < 0)
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 0f                	js     801fcc <getchar+0x34>
		return r;
	if (r < 1)
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	7e 06                	jle    801fc7 <getchar+0x2f>
		return -E_EOF;
	return c;
  801fc1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fc5:	eb 05                	jmp    801fcc <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fc7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fcc:	c9                   	leave  
  801fcd:	c3                   	ret    

00801fce <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	89 04 24             	mov    %eax,(%esp)
  801fe1:	e8 18 f3 ff ff       	call   8012fe <fd_lookup>
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	78 11                	js     801ffb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fed:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ff3:	39 10                	cmp    %edx,(%eax)
  801ff5:	0f 94 c0             	sete   %al
  801ff8:	0f b6 c0             	movzbl %al,%eax
}
  801ffb:	c9                   	leave  
  801ffc:	c3                   	ret    

00801ffd <opencons>:

int
opencons(void)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802003:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802006:	89 04 24             	mov    %eax,(%esp)
  802009:	e8 7d f2 ff ff       	call   80128b <fd_alloc>
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 3c                	js     80204e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802012:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802019:	00 
  80201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802021:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802028:	e8 7f ee ff ff       	call   800eac <sys_page_alloc>
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 1d                	js     80204e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802031:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80203c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802046:	89 04 24             	mov    %eax,(%esp)
  802049:	e8 12 f2 ff ff       	call   801260 <fd2num>
}
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	83 ec 10             	sub    $0x10,%esp
  802058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80205b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802061:	85 db                	test   %ebx,%ebx
  802063:	74 06                	je     80206b <ipc_recv+0x1b>
  802065:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80206b:	85 f6                	test   %esi,%esi
  80206d:	74 06                	je     802075 <ipc_recv+0x25>
  80206f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802075:	85 c0                	test   %eax,%eax
  802077:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80207c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80207f:	89 04 24             	mov    %eax,(%esp)
  802082:	e8 8e f0 ff ff       	call   801115 <sys_ipc_recv>
    if (ret) return ret;
  802087:	85 c0                	test   %eax,%eax
  802089:	75 24                	jne    8020af <ipc_recv+0x5f>
    if (from_env_store)
  80208b:	85 db                	test   %ebx,%ebx
  80208d:	74 0a                	je     802099 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80208f:	a1 04 40 80 00       	mov    0x804004,%eax
  802094:	8b 40 74             	mov    0x74(%eax),%eax
  802097:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802099:	85 f6                	test   %esi,%esi
  80209b:	74 0a                	je     8020a7 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80209d:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a2:	8b 40 78             	mov    0x78(%eax),%eax
  8020a5:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8020a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ac:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	5b                   	pop    %ebx
  8020b3:	5e                   	pop    %esi
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    

008020b6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	57                   	push   %edi
  8020ba:	56                   	push   %esi
  8020bb:	53                   	push   %ebx
  8020bc:	83 ec 1c             	sub    $0x1c,%esp
  8020bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8020c8:	85 db                	test   %ebx,%ebx
  8020ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020cf:	0f 44 d8             	cmove  %eax,%ebx
  8020d2:	eb 2a                	jmp    8020fe <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8020d4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d7:	74 20                	je     8020f9 <ipc_send+0x43>
  8020d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020dd:	c7 44 24 08 aa 29 80 	movl   $0x8029aa,0x8(%esp)
  8020e4:	00 
  8020e5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8020ec:	00 
  8020ed:	c7 04 24 c1 29 80 00 	movl   $0x8029c1,(%esp)
  8020f4:	e8 6b e0 ff ff       	call   800164 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8020f9:	e8 7e ed ff ff       	call   800e7c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8020fe:	8b 45 14             	mov    0x14(%ebp),%eax
  802101:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802105:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802109:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80210d:	89 34 24             	mov    %esi,(%esp)
  802110:	e8 cc ef ff ff       	call   8010e1 <sys_ipc_try_send>
  802115:	85 c0                	test   %eax,%eax
  802117:	75 bb                	jne    8020d4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802119:	83 c4 1c             	add    $0x1c,%esp
  80211c:	5b                   	pop    %ebx
  80211d:	5e                   	pop    %esi
  80211e:	5f                   	pop    %edi
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    

00802121 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802127:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80212c:	39 c8                	cmp    %ecx,%eax
  80212e:	74 19                	je     802149 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802130:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802135:	89 c2                	mov    %eax,%edx
  802137:	c1 e2 07             	shl    $0x7,%edx
  80213a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802140:	8b 52 50             	mov    0x50(%edx),%edx
  802143:	39 ca                	cmp    %ecx,%edx
  802145:	75 14                	jne    80215b <ipc_find_env+0x3a>
  802147:	eb 05                	jmp    80214e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802149:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80214e:	c1 e0 07             	shl    $0x7,%eax
  802151:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802156:	8b 40 40             	mov    0x40(%eax),%eax
  802159:	eb 0e                	jmp    802169 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80215b:	83 c0 01             	add    $0x1,%eax
  80215e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802163:	75 d0                	jne    802135 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802165:	66 b8 00 00          	mov    $0x0,%ax
}
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    
	...

0080216c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802172:	89 d0                	mov    %edx,%eax
  802174:	c1 e8 16             	shr    $0x16,%eax
  802177:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80217e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802183:	f6 c1 01             	test   $0x1,%cl
  802186:	74 1d                	je     8021a5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802188:	c1 ea 0c             	shr    $0xc,%edx
  80218b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802192:	f6 c2 01             	test   $0x1,%dl
  802195:	74 0e                	je     8021a5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802197:	c1 ea 0c             	shr    $0xc,%edx
  80219a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021a1:	ef 
  8021a2:	0f b7 c0             	movzwl %ax,%eax
}
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    
	...

008021b0 <__udivdi3>:
  8021b0:	83 ec 1c             	sub    $0x1c,%esp
  8021b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8021bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8021bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8021c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021cb:	85 ff                	test   %edi,%edi
  8021cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8021d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021d5:	89 cd                	mov    %ecx,%ebp
  8021d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021db:	75 33                	jne    802210 <__udivdi3+0x60>
  8021dd:	39 f1                	cmp    %esi,%ecx
  8021df:	77 57                	ja     802238 <__udivdi3+0x88>
  8021e1:	85 c9                	test   %ecx,%ecx
  8021e3:	75 0b                	jne    8021f0 <__udivdi3+0x40>
  8021e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ea:	31 d2                	xor    %edx,%edx
  8021ec:	f7 f1                	div    %ecx
  8021ee:	89 c1                	mov    %eax,%ecx
  8021f0:	89 f0                	mov    %esi,%eax
  8021f2:	31 d2                	xor    %edx,%edx
  8021f4:	f7 f1                	div    %ecx
  8021f6:	89 c6                	mov    %eax,%esi
  8021f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021fc:	f7 f1                	div    %ecx
  8021fe:	89 f2                	mov    %esi,%edx
  802200:	8b 74 24 10          	mov    0x10(%esp),%esi
  802204:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802208:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	c3                   	ret    
  802210:	31 d2                	xor    %edx,%edx
  802212:	31 c0                	xor    %eax,%eax
  802214:	39 f7                	cmp    %esi,%edi
  802216:	77 e8                	ja     802200 <__udivdi3+0x50>
  802218:	0f bd cf             	bsr    %edi,%ecx
  80221b:	83 f1 1f             	xor    $0x1f,%ecx
  80221e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802222:	75 2c                	jne    802250 <__udivdi3+0xa0>
  802224:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802228:	76 04                	jbe    80222e <__udivdi3+0x7e>
  80222a:	39 f7                	cmp    %esi,%edi
  80222c:	73 d2                	jae    802200 <__udivdi3+0x50>
  80222e:	31 d2                	xor    %edx,%edx
  802230:	b8 01 00 00 00       	mov    $0x1,%eax
  802235:	eb c9                	jmp    802200 <__udivdi3+0x50>
  802237:	90                   	nop
  802238:	89 f2                	mov    %esi,%edx
  80223a:	f7 f1                	div    %ecx
  80223c:	31 d2                	xor    %edx,%edx
  80223e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802242:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802246:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	c3                   	ret    
  80224e:	66 90                	xchg   %ax,%ax
  802250:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802255:	b8 20 00 00 00       	mov    $0x20,%eax
  80225a:	89 ea                	mov    %ebp,%edx
  80225c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802260:	d3 e7                	shl    %cl,%edi
  802262:	89 c1                	mov    %eax,%ecx
  802264:	d3 ea                	shr    %cl,%edx
  802266:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80226b:	09 fa                	or     %edi,%edx
  80226d:	89 f7                	mov    %esi,%edi
  80226f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802273:	89 f2                	mov    %esi,%edx
  802275:	8b 74 24 08          	mov    0x8(%esp),%esi
  802279:	d3 e5                	shl    %cl,%ebp
  80227b:	89 c1                	mov    %eax,%ecx
  80227d:	d3 ef                	shr    %cl,%edi
  80227f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802284:	d3 e2                	shl    %cl,%edx
  802286:	89 c1                	mov    %eax,%ecx
  802288:	d3 ee                	shr    %cl,%esi
  80228a:	09 d6                	or     %edx,%esi
  80228c:	89 fa                	mov    %edi,%edx
  80228e:	89 f0                	mov    %esi,%eax
  802290:	f7 74 24 0c          	divl   0xc(%esp)
  802294:	89 d7                	mov    %edx,%edi
  802296:	89 c6                	mov    %eax,%esi
  802298:	f7 e5                	mul    %ebp
  80229a:	39 d7                	cmp    %edx,%edi
  80229c:	72 22                	jb     8022c0 <__udivdi3+0x110>
  80229e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8022a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022a7:	d3 e5                	shl    %cl,%ebp
  8022a9:	39 c5                	cmp    %eax,%ebp
  8022ab:	73 04                	jae    8022b1 <__udivdi3+0x101>
  8022ad:	39 d7                	cmp    %edx,%edi
  8022af:	74 0f                	je     8022c0 <__udivdi3+0x110>
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	e9 46 ff ff ff       	jmp    802200 <__udivdi3+0x50>
  8022ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	c3                   	ret    
	...

008022e0 <__umoddi3>:
  8022e0:	83 ec 1c             	sub    $0x1c,%esp
  8022e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8022e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8022eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8022ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8022f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8022f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8022fb:	85 ed                	test   %ebp,%ebp
  8022fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802301:	89 44 24 08          	mov    %eax,0x8(%esp)
  802305:	89 cf                	mov    %ecx,%edi
  802307:	89 04 24             	mov    %eax,(%esp)
  80230a:	89 f2                	mov    %esi,%edx
  80230c:	75 1a                	jne    802328 <__umoddi3+0x48>
  80230e:	39 f1                	cmp    %esi,%ecx
  802310:	76 4e                	jbe    802360 <__umoddi3+0x80>
  802312:	f7 f1                	div    %ecx
  802314:	89 d0                	mov    %edx,%eax
  802316:	31 d2                	xor    %edx,%edx
  802318:	8b 74 24 10          	mov    0x10(%esp),%esi
  80231c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802320:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802324:	83 c4 1c             	add    $0x1c,%esp
  802327:	c3                   	ret    
  802328:	39 f5                	cmp    %esi,%ebp
  80232a:	77 54                	ja     802380 <__umoddi3+0xa0>
  80232c:	0f bd c5             	bsr    %ebp,%eax
  80232f:	83 f0 1f             	xor    $0x1f,%eax
  802332:	89 44 24 04          	mov    %eax,0x4(%esp)
  802336:	75 60                	jne    802398 <__umoddi3+0xb8>
  802338:	3b 0c 24             	cmp    (%esp),%ecx
  80233b:	0f 87 07 01 00 00    	ja     802448 <__umoddi3+0x168>
  802341:	89 f2                	mov    %esi,%edx
  802343:	8b 34 24             	mov    (%esp),%esi
  802346:	29 ce                	sub    %ecx,%esi
  802348:	19 ea                	sbb    %ebp,%edx
  80234a:	89 34 24             	mov    %esi,(%esp)
  80234d:	8b 04 24             	mov    (%esp),%eax
  802350:	8b 74 24 10          	mov    0x10(%esp),%esi
  802354:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802358:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80235c:	83 c4 1c             	add    $0x1c,%esp
  80235f:	c3                   	ret    
  802360:	85 c9                	test   %ecx,%ecx
  802362:	75 0b                	jne    80236f <__umoddi3+0x8f>
  802364:	b8 01 00 00 00       	mov    $0x1,%eax
  802369:	31 d2                	xor    %edx,%edx
  80236b:	f7 f1                	div    %ecx
  80236d:	89 c1                	mov    %eax,%ecx
  80236f:	89 f0                	mov    %esi,%eax
  802371:	31 d2                	xor    %edx,%edx
  802373:	f7 f1                	div    %ecx
  802375:	8b 04 24             	mov    (%esp),%eax
  802378:	f7 f1                	div    %ecx
  80237a:	eb 98                	jmp    802314 <__umoddi3+0x34>
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	89 f2                	mov    %esi,%edx
  802382:	8b 74 24 10          	mov    0x10(%esp),%esi
  802386:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80238a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80238e:	83 c4 1c             	add    $0x1c,%esp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80239d:	89 e8                	mov    %ebp,%eax
  80239f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8023a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8023a8:	89 fa                	mov    %edi,%edx
  8023aa:	d3 e0                	shl    %cl,%eax
  8023ac:	89 e9                	mov    %ebp,%ecx
  8023ae:	d3 ea                	shr    %cl,%edx
  8023b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023b5:	09 c2                	or     %eax,%edx
  8023b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023bb:	89 14 24             	mov    %edx,(%esp)
  8023be:	89 f2                	mov    %esi,%edx
  8023c0:	d3 e7                	shl    %cl,%edi
  8023c2:	89 e9                	mov    %ebp,%ecx
  8023c4:	d3 ea                	shr    %cl,%edx
  8023c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023cf:	d3 e6                	shl    %cl,%esi
  8023d1:	89 e9                	mov    %ebp,%ecx
  8023d3:	d3 e8                	shr    %cl,%eax
  8023d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023da:	09 f0                	or     %esi,%eax
  8023dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023e0:	f7 34 24             	divl   (%esp)
  8023e3:	d3 e6                	shl    %cl,%esi
  8023e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023e9:	89 d6                	mov    %edx,%esi
  8023eb:	f7 e7                	mul    %edi
  8023ed:	39 d6                	cmp    %edx,%esi
  8023ef:	89 c1                	mov    %eax,%ecx
  8023f1:	89 d7                	mov    %edx,%edi
  8023f3:	72 3f                	jb     802434 <__umoddi3+0x154>
  8023f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023f9:	72 35                	jb     802430 <__umoddi3+0x150>
  8023fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ff:	29 c8                	sub    %ecx,%eax
  802401:	19 fe                	sbb    %edi,%esi
  802403:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802408:	89 f2                	mov    %esi,%edx
  80240a:	d3 e8                	shr    %cl,%eax
  80240c:	89 e9                	mov    %ebp,%ecx
  80240e:	d3 e2                	shl    %cl,%edx
  802410:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802415:	09 d0                	or     %edx,%eax
  802417:	89 f2                	mov    %esi,%edx
  802419:	d3 ea                	shr    %cl,%edx
  80241b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80241f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802423:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802427:	83 c4 1c             	add    $0x1c,%esp
  80242a:	c3                   	ret    
  80242b:	90                   	nop
  80242c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802430:	39 d6                	cmp    %edx,%esi
  802432:	75 c7                	jne    8023fb <__umoddi3+0x11b>
  802434:	89 d7                	mov    %edx,%edi
  802436:	89 c1                	mov    %eax,%ecx
  802438:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80243c:	1b 3c 24             	sbb    (%esp),%edi
  80243f:	eb ba                	jmp    8023fb <__umoddi3+0x11b>
  802441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802448:	39 f5                	cmp    %esi,%ebp
  80244a:	0f 82 f1 fe ff ff    	jb     802341 <__umoddi3+0x61>
  802450:	e9 f8 fe ff ff       	jmp    80234d <__umoddi3+0x6d>
