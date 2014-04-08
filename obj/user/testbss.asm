
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ef 00 00 00       	call   800120 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 00 14 80 00 	movl   $0x801400,(%esp)
  800041:	e8 39 02 00 00       	call   80027f <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0) {
  800046:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0) {
  800054:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  80005b:	00 
  80005c:	74 27                	je     800085 <umain+0x51>
  80005e:	eb 05                	jmp    800065 <umain+0x31>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0) {
			//cprintf("%u not zero\n", bigarray[i]);
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800069:	c7 44 24 08 7b 14 80 	movl   $0x80147b,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  800080:	e8 ff 00 00 00       	call   800184 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	83 c0 01             	add    $0x1,%eax
  800088:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008d:	75 c5                	jne    800054 <umain+0x20>
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0) {
			//cprintf("%u not zero\n", bigarray[i]);
			panic("bigarray[%d] isn't cleared!\n", i);
		}
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800094:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0) {
			//cprintf("%u not zero\n", bigarray[i]);
			panic("bigarray[%d] isn't cleared!\n", i);
		}
	for (i = 0; i < ARRAYSIZE; i++)
  80009b:	83 c0 01             	add    $0x1,%eax
  80009e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a3:	75 ef                	jne    800094 <umain+0x60>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a5:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000ac:	75 10                	jne    8000be <umain+0x8a>
			//cprintf("%u not zero\n", bigarray[i]);
			panic("bigarray[%d] isn't cleared!\n", i);
		}
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000ba:	74 27                	je     8000e3 <umain+0xaf>
  8000bc:	eb 05                	jmp    8000c3 <umain+0x8f>
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c7:	c7 44 24 08 20 14 80 	movl   $0x801420,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  8000de:	e8 a1 00 00 00       	call   800184 <_panic>
			//cprintf("%u not zero\n", bigarray[i]);
			panic("bigarray[%d] isn't cleared!\n", i);
		}
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e3:	83 c0 01             	add    $0x1,%eax
  8000e6:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000eb:	75 c6                	jne    8000b3 <umain+0x7f>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ed:	c7 04 24 48 14 80 00 	movl   $0x801448,(%esp)
  8000f4:	e8 86 01 00 00       	call   80027f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 a7 14 80 	movl   $0x8014a7,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  80011a:	e8 65 00 00 00       	call   800184 <_panic>
	...

00800120 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
  800126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800129:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80012c:	8b 75 08             	mov    0x8(%ebp),%esi
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800132:	e8 35 0d 00 00       	call   800e6c <sys_getenvid>
  800137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	85 f6                	test   %esi,%esi
  80014b:	7e 07                	jle    800154 <libmain+0x34>
		binaryname = argv[0];
  80014d:	8b 03                	mov    (%ebx),%eax
  80014f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800154:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800158:	89 34 24             	mov    %esi,(%esp)
  80015b:	e8 d4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800160:	e8 0b 00 00 00       	call   800170 <exit>
}
  800165:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800168:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016b:	89 ec                	mov    %ebp,%esp
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
	...

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017d:	e8 8d 0c 00 00       	call   800e0f <sys_env_destroy>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800195:	e8 d2 0c 00 00       	call   800e6c <sys_getenvid>
  80019a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	c7 04 24 c8 14 80 00 	movl   $0x8014c8,(%esp)
  8001b7:	e8 c3 00 00 00       	call   80027f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 53 00 00 00       	call   80021e <vcprintf>
	cprintf("\n");
  8001cb:	c7 04 24 96 14 80 00 	movl   $0x801496,(%esp)
  8001d2:	e8 a8 00 00 00       	call   80027f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x53>
	...

008001dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 14             	sub    $0x14,%esp
  8001e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e6:	8b 03                	mov    (%ebx),%eax
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ef:	83 c0 01             	add    $0x1,%eax
  8001f2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f9:	75 19                	jne    800214 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800202:	00 
  800203:	8d 43 08             	lea    0x8(%ebx),%eax
  800206:	89 04 24             	mov    %eax,(%esp)
  800209:	e8 a2 0b 00 00       	call   800db0 <sys_cputs>
		b->idx = 0;
  80020e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800214:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800218:	83 c4 14             	add    $0x14,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800227:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022e:	00 00 00 
	b.cnt = 0;
  800231:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800238:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	89 44 24 08          	mov    %eax,0x8(%esp)
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	c7 04 24 dc 01 80 00 	movl   $0x8001dc,(%esp)
  80025a:	e8 97 01 00 00       	call   8003f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 39 0b 00 00       	call   800db0 <sys_cputs>

	return b.cnt;
}
  800277:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800285:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	e8 87 ff ff ff       	call   80021e <vcprintf>
	va_end(ap);

	return cnt;
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
	...

0080029c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 3c             	sub    $0x3c,%esp
  8002a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a8:	89 d7                	mov    %edx,%edi
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002c4:	72 11                	jb     8002d7 <printnum+0x3b>
  8002c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cc:	76 09                	jbe    8002d7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ce:	83 eb 01             	sub    $0x1,%ebx
  8002d1:	85 db                	test   %ebx,%ebx
  8002d3:	7f 51                	jg     800326 <printnum+0x8a>
  8002d5:	eb 5e                	jmp    800335 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002db:	83 eb 01             	sub    $0x1,%ebx
  8002de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002ed:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f8:	00 
  8002f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fc:	89 04 24             	mov    %eax,(%esp)
  8002ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800302:	89 44 24 04          	mov    %eax,0x4(%esp)
  800306:	e8 35 0e 00 00       	call   801140 <__udivdi3>
  80030b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80030f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031a:	89 fa                	mov    %edi,%edx
  80031c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031f:	e8 78 ff ff ff       	call   80029c <printnum>
  800324:	eb 0f                	jmp    800335 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800326:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032a:	89 34 24             	mov    %esi,(%esp)
  80032d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800330:	83 eb 01             	sub    $0x1,%ebx
  800333:	75 f1                	jne    800326 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80033d:	8b 45 10             	mov    0x10(%ebp),%eax
  800340:	89 44 24 08          	mov    %eax,0x8(%esp)
  800344:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034b:	00 
  80034c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	89 44 24 04          	mov    %eax,0x4(%esp)
  800359:	e8 12 0f 00 00       	call   801270 <__umoddi3>
  80035e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800362:	0f be 80 ec 14 80 00 	movsbl 0x8014ec(%eax),%eax
  800369:	89 04 24             	mov    %eax,(%esp)
  80036c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80036f:	83 c4 3c             	add    $0x3c,%esp
  800372:	5b                   	pop    %ebx
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037a:	83 fa 01             	cmp    $0x1,%edx
  80037d:	7e 0e                	jle    80038d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	8d 4a 08             	lea    0x8(%edx),%ecx
  800384:	89 08                	mov    %ecx,(%eax)
  800386:	8b 02                	mov    (%edx),%eax
  800388:	8b 52 04             	mov    0x4(%edx),%edx
  80038b:	eb 22                	jmp    8003af <getuint+0x38>
	else if (lflag)
  80038d:	85 d2                	test   %edx,%edx
  80038f:	74 10                	je     8003a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800391:	8b 10                	mov    (%eax),%edx
  800393:	8d 4a 04             	lea    0x4(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 02                	mov    (%edx),%eax
  80039a:	ba 00 00 00 00       	mov    $0x0,%edx
  80039f:	eb 0e                	jmp    8003af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a6:	89 08                	mov    %ecx,(%eax)
  8003a8:	8b 02                	mov    (%edx),%eax
  8003aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c0:	73 0a                	jae    8003cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c5:	88 0a                	mov    %cl,(%edx)
  8003c7:	83 c2 01             	add    $0x1,%edx
  8003ca:	89 10                	mov    %edx,(%eax)
}
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003db:	8b 45 10             	mov    0x10(%ebp),%eax
  8003de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	e8 02 00 00 00       	call   8003f6 <vprintfmt>
	va_end(ap);
}
  8003f4:	c9                   	leave  
  8003f5:	c3                   	ret    

008003f6 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	57                   	push   %edi
  8003fa:	56                   	push   %esi
  8003fb:	53                   	push   %ebx
  8003fc:	83 ec 5c             	sub    $0x5c,%esp
  8003ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800402:	8b 75 10             	mov    0x10(%ebp),%esi
  800405:	eb 12                	jmp    800419 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800407:	85 c0                	test   %eax,%eax
  800409:	0f 84 e4 04 00 00    	je     8008f3 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80040f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800413:	89 04 24             	mov    %eax,(%esp)
  800416:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800419:	0f b6 06             	movzbl (%esi),%eax
  80041c:	83 c6 01             	add    $0x1,%esi
  80041f:	83 f8 25             	cmp    $0x25,%eax
  800422:	75 e3                	jne    800407 <vprintfmt+0x11>
  800424:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800428:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80042f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800434:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80043b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800440:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800443:	eb 2b                	jmp    800470 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800448:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80044c:	eb 22                	jmp    800470 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800451:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800455:	eb 19                	jmp    800470 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80045a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800461:	eb 0d                	jmp    800470 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800463:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800466:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800469:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	0f b6 06             	movzbl (%esi),%eax
  800473:	0f b6 d0             	movzbl %al,%edx
  800476:	8d 7e 01             	lea    0x1(%esi),%edi
  800479:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047c:	83 e8 23             	sub    $0x23,%eax
  80047f:	3c 55                	cmp    $0x55,%al
  800481:	0f 87 46 04 00 00    	ja     8008cd <vprintfmt+0x4d7>
  800487:	0f b6 c0             	movzbl %al,%eax
  80048a:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800491:	83 ea 30             	sub    $0x30,%edx
  800494:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800497:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80049b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004a1:	83 fa 09             	cmp    $0x9,%edx
  8004a4:	77 4a                	ja     8004f0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004ac:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004af:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004b3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b9:	83 fa 09             	cmp    $0x9,%edx
  8004bc:	76 eb                	jbe    8004a9 <vprintfmt+0xb3>
  8004be:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004c1:	eb 2d                	jmp    8004f0 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 50 04             	lea    0x4(%eax),%edx
  8004c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cc:	8b 00                	mov    (%eax),%eax
  8004ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d4:	eb 1a                	jmp    8004f0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004d9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004dd:	79 91                	jns    800470 <vprintfmt+0x7a>
  8004df:	e9 73 ff ff ff       	jmp    800457 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004ee:	eb 80                	jmp    800470 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004f0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004f4:	0f 89 76 ff ff ff    	jns    800470 <vprintfmt+0x7a>
  8004fa:	e9 64 ff ff ff       	jmp    800463 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ff:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800505:	e9 66 ff ff ff       	jmp    800470 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800522:	e9 f2 fe ff ff       	jmp    800419 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800527:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80052b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80052e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800532:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800535:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800539:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80053c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80053f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800543:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800546:	80 f9 09             	cmp    $0x9,%cl
  800549:	77 1d                	ja     800568 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80054b:	0f be c0             	movsbl %al,%eax
  80054e:	6b c0 64             	imul   $0x64,%eax,%eax
  800551:	0f be d2             	movsbl %dl,%edx
  800554:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800557:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80055e:	a3 04 20 80 00       	mov    %eax,0x802004
  800563:	e9 b1 fe ff ff       	jmp    800419 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800568:	c7 44 24 04 04 15 80 	movl   $0x801504,0x4(%esp)
  80056f:	00 
  800570:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 10 05 00 00       	call   800a8b <strcmp>
  80057b:	85 c0                	test   %eax,%eax
  80057d:	75 0f                	jne    80058e <vprintfmt+0x198>
  80057f:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800586:	00 00 00 
  800589:	e9 8b fe ff ff       	jmp    800419 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80058e:	c7 44 24 04 08 15 80 	movl   $0x801508,0x4(%esp)
  800595:	00 
  800596:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800599:	89 14 24             	mov    %edx,(%esp)
  80059c:	e8 ea 04 00 00       	call   800a8b <strcmp>
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	75 0f                	jne    8005b4 <vprintfmt+0x1be>
  8005a5:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005ac:	00 00 00 
  8005af:	e9 65 fe ff ff       	jmp    800419 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005b4:	c7 44 24 04 0c 15 80 	movl   $0x80150c,0x4(%esp)
  8005bb:	00 
  8005bc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005bf:	89 0c 24             	mov    %ecx,(%esp)
  8005c2:	e8 c4 04 00 00       	call   800a8b <strcmp>
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	75 0f                	jne    8005da <vprintfmt+0x1e4>
  8005cb:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005d2:	00 00 00 
  8005d5:	e9 3f fe ff ff       	jmp    800419 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005da:	c7 44 24 04 10 15 80 	movl   $0x801510,0x4(%esp)
  8005e1:	00 
  8005e2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005e5:	89 3c 24             	mov    %edi,(%esp)
  8005e8:	e8 9e 04 00 00       	call   800a8b <strcmp>
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	75 0f                	jne    800600 <vprintfmt+0x20a>
  8005f1:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005f8:	00 00 00 
  8005fb:	e9 19 fe ff ff       	jmp    800419 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800600:	c7 44 24 04 14 15 80 	movl   $0x801514,0x4(%esp)
  800607:	00 
  800608:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80060b:	89 04 24             	mov    %eax,(%esp)
  80060e:	e8 78 04 00 00       	call   800a8b <strcmp>
  800613:	85 c0                	test   %eax,%eax
  800615:	75 0f                	jne    800626 <vprintfmt+0x230>
  800617:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80061e:	00 00 00 
  800621:	e9 f3 fd ff ff       	jmp    800419 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800626:	c7 44 24 04 18 15 80 	movl   $0x801518,0x4(%esp)
  80062d:	00 
  80062e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800631:	89 14 24             	mov    %edx,(%esp)
  800634:	e8 52 04 00 00       	call   800a8b <strcmp>
  800639:	83 f8 01             	cmp    $0x1,%eax
  80063c:	19 c0                	sbb    %eax,%eax
  80063e:	f7 d0                	not    %eax
  800640:	83 c0 08             	add    $0x8,%eax
  800643:	a3 04 20 80 00       	mov    %eax,0x802004
  800648:	e9 cc fd ff ff       	jmp    800419 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 50 04             	lea    0x4(%eax),%edx
  800653:	89 55 14             	mov    %edx,0x14(%ebp)
  800656:	8b 00                	mov    (%eax),%eax
  800658:	89 c2                	mov    %eax,%edx
  80065a:	c1 fa 1f             	sar    $0x1f,%edx
  80065d:	31 d0                	xor    %edx,%eax
  80065f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800661:	83 f8 08             	cmp    $0x8,%eax
  800664:	7f 0b                	jg     800671 <vprintfmt+0x27b>
  800666:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  80066d:	85 d2                	test   %edx,%edx
  80066f:	75 23                	jne    800694 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800671:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800675:	c7 44 24 08 1c 15 80 	movl   $0x80151c,0x8(%esp)
  80067c:	00 
  80067d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800681:	8b 7d 08             	mov    0x8(%ebp),%edi
  800684:	89 3c 24             	mov    %edi,(%esp)
  800687:	e8 42 fd ff ff       	call   8003ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80068f:	e9 85 fd ff ff       	jmp    800419 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800694:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800698:	c7 44 24 08 25 15 80 	movl   $0x801525,0x8(%esp)
  80069f:	00 
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a7:	89 3c 24             	mov    %edi,(%esp)
  8006aa:	e8 1f fd ff ff       	call   8003ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006b2:	e9 62 fd ff ff       	jmp    800419 <vprintfmt+0x23>
  8006b7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006bd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 50 04             	lea    0x4(%eax),%edx
  8006c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006cb:	85 f6                	test   %esi,%esi
  8006cd:	b8 fd 14 80 00       	mov    $0x8014fd,%eax
  8006d2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006d5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006d9:	7e 06                	jle    8006e1 <vprintfmt+0x2eb>
  8006db:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006df:	75 13                	jne    8006f4 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e1:	0f be 06             	movsbl (%esi),%eax
  8006e4:	83 c6 01             	add    $0x1,%esi
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	0f 85 94 00 00 00    	jne    800783 <vprintfmt+0x38d>
  8006ef:	e9 81 00 00 00       	jmp    800775 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f8:	89 34 24             	mov    %esi,(%esp)
  8006fb:	e8 9b 02 00 00       	call   80099b <strnlen>
  800700:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800703:	29 c2                	sub    %eax,%edx
  800705:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800708:	85 d2                	test   %edx,%edx
  80070a:	7e d5                	jle    8006e1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80070c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800710:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800713:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800716:	89 d6                	mov    %edx,%esi
  800718:	89 cf                	mov    %ecx,%edi
  80071a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071e:	89 3c 24             	mov    %edi,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800724:	83 ee 01             	sub    $0x1,%esi
  800727:	75 f1                	jne    80071a <vprintfmt+0x324>
  800729:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80072c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80072f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800732:	eb ad                	jmp    8006e1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800734:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800738:	74 1b                	je     800755 <vprintfmt+0x35f>
  80073a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80073d:	83 fa 5e             	cmp    $0x5e,%edx
  800740:	76 13                	jbe    800755 <vprintfmt+0x35f>
					putch('?', putdat);
  800742:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800745:	89 44 24 04          	mov    %eax,0x4(%esp)
  800749:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800755:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800758:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800762:	83 eb 01             	sub    $0x1,%ebx
  800765:	0f be 06             	movsbl (%esi),%eax
  800768:	83 c6 01             	add    $0x1,%esi
  80076b:	85 c0                	test   %eax,%eax
  80076d:	75 1a                	jne    800789 <vprintfmt+0x393>
  80076f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800772:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800775:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800778:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80077c:	7f 1c                	jg     80079a <vprintfmt+0x3a4>
  80077e:	e9 96 fc ff ff       	jmp    800419 <vprintfmt+0x23>
  800783:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800786:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800789:	85 ff                	test   %edi,%edi
  80078b:	78 a7                	js     800734 <vprintfmt+0x33e>
  80078d:	83 ef 01             	sub    $0x1,%edi
  800790:	79 a2                	jns    800734 <vprintfmt+0x33e>
  800792:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800795:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800798:	eb db                	jmp    800775 <vprintfmt+0x37f>
  80079a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80079d:	89 de                	mov    %ebx,%esi
  80079f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007ad:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007af:	83 eb 01             	sub    $0x1,%ebx
  8007b2:	75 ee                	jne    8007a2 <vprintfmt+0x3ac>
  8007b4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007b9:	e9 5b fc ff ff       	jmp    800419 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007be:	83 f9 01             	cmp    $0x1,%ecx
  8007c1:	7e 10                	jle    8007d3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 50 08             	lea    0x8(%eax),%edx
  8007c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cc:	8b 30                	mov    (%eax),%esi
  8007ce:	8b 78 04             	mov    0x4(%eax),%edi
  8007d1:	eb 26                	jmp    8007f9 <vprintfmt+0x403>
	else if (lflag)
  8007d3:	85 c9                	test   %ecx,%ecx
  8007d5:	74 12                	je     8007e9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 30                	mov    (%eax),%esi
  8007e2:	89 f7                	mov    %esi,%edi
  8007e4:	c1 ff 1f             	sar    $0x1f,%edi
  8007e7:	eb 10                	jmp    8007f9 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f2:	8b 30                	mov    (%eax),%esi
  8007f4:	89 f7                	mov    %esi,%edi
  8007f6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f9:	85 ff                	test   %edi,%edi
  8007fb:	78 0e                	js     80080b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800801:	be 0a 00 00 00       	mov    $0xa,%esi
  800806:	e9 84 00 00 00       	jmp    80088f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80080b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800816:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800819:	89 f0                	mov    %esi,%eax
  80081b:	89 fa                	mov    %edi,%edx
  80081d:	f7 d8                	neg    %eax
  80081f:	83 d2 00             	adc    $0x0,%edx
  800822:	f7 da                	neg    %edx
			}
			base = 10;
  800824:	be 0a 00 00 00       	mov    $0xa,%esi
  800829:	eb 64                	jmp    80088f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082b:	89 ca                	mov    %ecx,%edx
  80082d:	8d 45 14             	lea    0x14(%ebp),%eax
  800830:	e8 42 fb ff ff       	call   800377 <getuint>
			base = 10;
  800835:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80083a:	eb 53                	jmp    80088f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80083c:	89 ca                	mov    %ecx,%edx
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
  800841:	e8 31 fb ff ff       	call   800377 <getuint>
    			base = 8;
  800846:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80084b:	eb 42                	jmp    80088f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80084d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800851:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800858:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80085b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800866:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8d 50 04             	lea    0x4(%eax),%edx
  80086f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800872:	8b 00                	mov    (%eax),%eax
  800874:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800879:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80087e:	eb 0f                	jmp    80088f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800880:	89 ca                	mov    %ecx,%edx
  800882:	8d 45 14             	lea    0x14(%ebp),%eax
  800885:	e8 ed fa ff ff       	call   800377 <getuint>
			base = 16;
  80088a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800893:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800897:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80089a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80089e:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a9:	89 da                	mov    %ebx,%edx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	e8 e9 f9 ff ff       	call   80029c <printnum>
			break;
  8008b3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008b6:	e9 5e fb ff ff       	jmp    800419 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bf:	89 14 24             	mov    %edx,(%esp)
  8008c2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c8:	e9 4c fb ff ff       	jmp    800419 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008d8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008db:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008df:	0f 84 34 fb ff ff    	je     800419 <vprintfmt+0x23>
  8008e5:	83 ee 01             	sub    $0x1,%esi
  8008e8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008ec:	75 f7                	jne    8008e5 <vprintfmt+0x4ef>
  8008ee:	e9 26 fb ff ff       	jmp    800419 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008f3:	83 c4 5c             	add    $0x5c,%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5f                   	pop    %edi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	83 ec 28             	sub    $0x28,%esp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800907:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800911:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800918:	85 c0                	test   %eax,%eax
  80091a:	74 30                	je     80094c <vsnprintf+0x51>
  80091c:	85 d2                	test   %edx,%edx
  80091e:	7e 2c                	jle    80094c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800927:	8b 45 10             	mov    0x10(%ebp),%eax
  80092a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800931:	89 44 24 04          	mov    %eax,0x4(%esp)
  800935:	c7 04 24 b1 03 80 00 	movl   $0x8003b1,(%esp)
  80093c:	e8 b5 fa ff ff       	call   8003f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800941:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800944:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094a:	eb 05                	jmp    800951 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800959:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800960:	8b 45 10             	mov    0x10(%ebp),%eax
  800963:	89 44 24 08          	mov    %eax,0x8(%esp)
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	89 04 24             	mov    %eax,(%esp)
  800974:	e8 82 ff ff ff       	call   8008fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    
  80097b:	00 00                	add    %al,(%eax)
  80097d:	00 00                	add    %al,(%eax)
	...

00800980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	80 3a 00             	cmpb   $0x0,(%edx)
  80098e:	74 09                	je     800999 <strlen+0x19>
		n++;
  800990:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800993:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800997:	75 f7                	jne    800990 <strlen+0x10>
		n++;
	return n;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009aa:	85 c9                	test   %ecx,%ecx
  8009ac:	74 1a                	je     8009c8 <strnlen+0x2d>
  8009ae:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009b1:	74 15                	je     8009c8 <strnlen+0x2d>
  8009b3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009b8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ba:	39 ca                	cmp    %ecx,%edx
  8009bc:	74 0a                	je     8009c8 <strnlen+0x2d>
  8009be:	83 c2 01             	add    $0x1,%edx
  8009c1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009c6:	75 f0                	jne    8009b8 <strnlen+0x1d>
		n++;
	return n;
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009da:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009de:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	75 f2                	jne    8009da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	83 ec 08             	sub    $0x8,%esp
  8009f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f5:	89 1c 24             	mov    %ebx,(%esp)
  8009f8:	e8 83 ff ff ff       	call   800980 <strlen>
	strcpy(dst + len, src);
  8009fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a00:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a04:	01 d8                	add    %ebx,%eax
  800a06:	89 04 24             	mov    %eax,(%esp)
  800a09:	e8 bd ff ff ff       	call   8009cb <strcpy>
	return dst;
}
  800a0e:	89 d8                	mov    %ebx,%eax
  800a10:	83 c4 08             	add    $0x8,%esp
  800a13:	5b                   	pop    %ebx
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a24:	85 f6                	test   %esi,%esi
  800a26:	74 18                	je     800a40 <strncpy+0x2a>
  800a28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a2d:	0f b6 1a             	movzbl (%edx),%ebx
  800a30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a33:	80 3a 01             	cmpb   $0x1,(%edx)
  800a36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	39 f1                	cmp    %esi,%ecx
  800a3e:	75 ed                	jne    800a2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a50:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a53:	89 f8                	mov    %edi,%eax
  800a55:	85 f6                	test   %esi,%esi
  800a57:	74 2b                	je     800a84 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a59:	83 fe 01             	cmp    $0x1,%esi
  800a5c:	74 23                	je     800a81 <strlcpy+0x3d>
  800a5e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a61:	84 c9                	test   %cl,%cl
  800a63:	74 1c                	je     800a81 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a65:	83 ee 02             	sub    $0x2,%esi
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a6d:	88 08                	mov    %cl,(%eax)
  800a6f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a72:	39 f2                	cmp    %esi,%edx
  800a74:	74 0b                	je     800a81 <strlcpy+0x3d>
  800a76:	83 c2 01             	add    $0x1,%edx
  800a79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a7d:	84 c9                	test   %cl,%cl
  800a7f:	75 ec                	jne    800a6d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a81:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a84:	29 f8                	sub    %edi,%eax
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a94:	0f b6 01             	movzbl (%ecx),%eax
  800a97:	84 c0                	test   %al,%al
  800a99:	74 16                	je     800ab1 <strcmp+0x26>
  800a9b:	3a 02                	cmp    (%edx),%al
  800a9d:	75 12                	jne    800ab1 <strcmp+0x26>
		p++, q++;
  800a9f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800aa6:	84 c0                	test   %al,%al
  800aa8:	74 07                	je     800ab1 <strcmp+0x26>
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	3a 02                	cmp    (%edx),%al
  800aaf:	74 ee                	je     800a9f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab1:	0f b6 c0             	movzbl %al,%eax
  800ab4:	0f b6 12             	movzbl (%edx),%edx
  800ab7:	29 d0                	sub    %edx,%eax
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800acd:	85 d2                	test   %edx,%edx
  800acf:	74 28                	je     800af9 <strncmp+0x3e>
  800ad1:	0f b6 01             	movzbl (%ecx),%eax
  800ad4:	84 c0                	test   %al,%al
  800ad6:	74 24                	je     800afc <strncmp+0x41>
  800ad8:	3a 03                	cmp    (%ebx),%al
  800ada:	75 20                	jne    800afc <strncmp+0x41>
  800adc:	83 ea 01             	sub    $0x1,%edx
  800adf:	74 13                	je     800af4 <strncmp+0x39>
		n--, p++, q++;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ae7:	0f b6 01             	movzbl (%ecx),%eax
  800aea:	84 c0                	test   %al,%al
  800aec:	74 0e                	je     800afc <strncmp+0x41>
  800aee:	3a 03                	cmp    (%ebx),%al
  800af0:	74 ea                	je     800adc <strncmp+0x21>
  800af2:	eb 08                	jmp    800afc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800afc:	0f b6 01             	movzbl (%ecx),%eax
  800aff:	0f b6 13             	movzbl (%ebx),%edx
  800b02:	29 d0                	sub    %edx,%eax
  800b04:	eb f3                	jmp    800af9 <strncmp+0x3e>

00800b06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b10:	0f b6 10             	movzbl (%eax),%edx
  800b13:	84 d2                	test   %dl,%dl
  800b15:	74 1c                	je     800b33 <strchr+0x2d>
		if (*s == c)
  800b17:	38 ca                	cmp    %cl,%dl
  800b19:	75 09                	jne    800b24 <strchr+0x1e>
  800b1b:	eb 1b                	jmp    800b38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b1d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b20:	38 ca                	cmp    %cl,%dl
  800b22:	74 14                	je     800b38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b24:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b28:	84 d2                	test   %dl,%dl
  800b2a:	75 f1                	jne    800b1d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b31:	eb 05                	jmp    800b38 <strchr+0x32>
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b44:	0f b6 10             	movzbl (%eax),%edx
  800b47:	84 d2                	test   %dl,%dl
  800b49:	74 14                	je     800b5f <strfind+0x25>
		if (*s == c)
  800b4b:	38 ca                	cmp    %cl,%dl
  800b4d:	75 06                	jne    800b55 <strfind+0x1b>
  800b4f:	eb 0e                	jmp    800b5f <strfind+0x25>
  800b51:	38 ca                	cmp    %cl,%dl
  800b53:	74 0a                	je     800b5f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	0f b6 10             	movzbl (%eax),%edx
  800b5b:	84 d2                	test   %dl,%dl
  800b5d:	75 f2                	jne    800b51 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b79:	85 c9                	test   %ecx,%ecx
  800b7b:	74 30                	je     800bad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b83:	75 25                	jne    800baa <memset+0x49>
  800b85:	f6 c1 03             	test   $0x3,%cl
  800b88:	75 20                	jne    800baa <memset+0x49>
		c &= 0xFF;
  800b8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	c1 e3 08             	shl    $0x8,%ebx
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	c1 e6 18             	shl    $0x18,%esi
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	c1 e0 10             	shl    $0x10,%eax
  800b9c:	09 f0                	or     %esi,%eax
  800b9e:	09 d0                	or     %edx,%eax
  800ba0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba5:	fc                   	cld    
  800ba6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba8:	eb 03                	jmp    800bad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800baa:	fc                   	cld    
  800bab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bad:	89 f8                	mov    %edi,%eax
  800baf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bb8:	89 ec                	mov    %ebp,%esp
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 08             	sub    $0x8,%esp
  800bc2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bc5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd1:	39 c6                	cmp    %eax,%esi
  800bd3:	73 36                	jae    800c0b <memmove+0x4f>
  800bd5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd8:	39 d0                	cmp    %edx,%eax
  800bda:	73 2f                	jae    800c0b <memmove+0x4f>
		s += n;
		d += n;
  800bdc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdf:	f6 c2 03             	test   $0x3,%dl
  800be2:	75 1b                	jne    800bff <memmove+0x43>
  800be4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bea:	75 13                	jne    800bff <memmove+0x43>
  800bec:	f6 c1 03             	test   $0x3,%cl
  800bef:	75 0e                	jne    800bff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf1:	83 ef 04             	sub    $0x4,%edi
  800bf4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bfa:	fd                   	std    
  800bfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfd:	eb 09                	jmp    800c08 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bff:	83 ef 01             	sub    $0x1,%edi
  800c02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c05:	fd                   	std    
  800c06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c08:	fc                   	cld    
  800c09:	eb 20                	jmp    800c2b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c11:	75 13                	jne    800c26 <memmove+0x6a>
  800c13:	a8 03                	test   $0x3,%al
  800c15:	75 0f                	jne    800c26 <memmove+0x6a>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0a                	jne    800c26 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c1f:	89 c7                	mov    %eax,%edi
  800c21:	fc                   	cld    
  800c22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c24:	eb 05                	jmp    800c2b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	fc                   	cld    
  800c29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c31:	89 ec                	mov    %ebp,%esp
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	89 04 24             	mov    %eax,(%esp)
  800c4f:	e8 68 ff ff ff       	call   800bbc <memmove>
}
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c62:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6a:	85 ff                	test   %edi,%edi
  800c6c:	74 37                	je     800ca5 <memcmp+0x4f>
		if (*s1 != *s2)
  800c6e:	0f b6 03             	movzbl (%ebx),%eax
  800c71:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c74:	83 ef 01             	sub    $0x1,%edi
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c7c:	38 c8                	cmp    %cl,%al
  800c7e:	74 1c                	je     800c9c <memcmp+0x46>
  800c80:	eb 10                	jmp    800c92 <memcmp+0x3c>
  800c82:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c87:	83 c2 01             	add    $0x1,%edx
  800c8a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c8e:	38 c8                	cmp    %cl,%al
  800c90:	74 0a                	je     800c9c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c92:	0f b6 c0             	movzbl %al,%eax
  800c95:	0f b6 c9             	movzbl %cl,%ecx
  800c98:	29 c8                	sub    %ecx,%eax
  800c9a:	eb 09                	jmp    800ca5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9c:	39 fa                	cmp    %edi,%edx
  800c9e:	75 e2                	jne    800c82 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cb0:	89 c2                	mov    %eax,%edx
  800cb2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb5:	39 d0                	cmp    %edx,%eax
  800cb7:	73 19                	jae    800cd2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cbd:	38 08                	cmp    %cl,(%eax)
  800cbf:	75 06                	jne    800cc7 <memfind+0x1d>
  800cc1:	eb 0f                	jmp    800cd2 <memfind+0x28>
  800cc3:	38 08                	cmp    %cl,(%eax)
  800cc5:	74 0b                	je     800cd2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	39 d0                	cmp    %edx,%eax
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	75 f1                	jne    800cc3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce0:	0f b6 02             	movzbl (%edx),%eax
  800ce3:	3c 20                	cmp    $0x20,%al
  800ce5:	74 04                	je     800ceb <strtol+0x17>
  800ce7:	3c 09                	cmp    $0x9,%al
  800ce9:	75 0e                	jne    800cf9 <strtol+0x25>
		s++;
  800ceb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cee:	0f b6 02             	movzbl (%edx),%eax
  800cf1:	3c 20                	cmp    $0x20,%al
  800cf3:	74 f6                	je     800ceb <strtol+0x17>
  800cf5:	3c 09                	cmp    $0x9,%al
  800cf7:	74 f2                	je     800ceb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf9:	3c 2b                	cmp    $0x2b,%al
  800cfb:	75 0a                	jne    800d07 <strtol+0x33>
		s++;
  800cfd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d00:	bf 00 00 00 00       	mov    $0x0,%edi
  800d05:	eb 10                	jmp    800d17 <strtol+0x43>
  800d07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d0c:	3c 2d                	cmp    $0x2d,%al
  800d0e:	75 07                	jne    800d17 <strtol+0x43>
		s++, neg = 1;
  800d10:	83 c2 01             	add    $0x1,%edx
  800d13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d17:	85 db                	test   %ebx,%ebx
  800d19:	0f 94 c0             	sete   %al
  800d1c:	74 05                	je     800d23 <strtol+0x4f>
  800d1e:	83 fb 10             	cmp    $0x10,%ebx
  800d21:	75 15                	jne    800d38 <strtol+0x64>
  800d23:	80 3a 30             	cmpb   $0x30,(%edx)
  800d26:	75 10                	jne    800d38 <strtol+0x64>
  800d28:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d2c:	75 0a                	jne    800d38 <strtol+0x64>
		s += 2, base = 16;
  800d2e:	83 c2 02             	add    $0x2,%edx
  800d31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d36:	eb 13                	jmp    800d4b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d38:	84 c0                	test   %al,%al
  800d3a:	74 0f                	je     800d4b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d41:	80 3a 30             	cmpb   $0x30,(%edx)
  800d44:	75 05                	jne    800d4b <strtol+0x77>
		s++, base = 8;
  800d46:	83 c2 01             	add    $0x1,%edx
  800d49:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d52:	0f b6 0a             	movzbl (%edx),%ecx
  800d55:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d58:	80 fb 09             	cmp    $0x9,%bl
  800d5b:	77 08                	ja     800d65 <strtol+0x91>
			dig = *s - '0';
  800d5d:	0f be c9             	movsbl %cl,%ecx
  800d60:	83 e9 30             	sub    $0x30,%ecx
  800d63:	eb 1e                	jmp    800d83 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d65:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d68:	80 fb 19             	cmp    $0x19,%bl
  800d6b:	77 08                	ja     800d75 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d6d:	0f be c9             	movsbl %cl,%ecx
  800d70:	83 e9 57             	sub    $0x57,%ecx
  800d73:	eb 0e                	jmp    800d83 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d75:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d78:	80 fb 19             	cmp    $0x19,%bl
  800d7b:	77 14                	ja     800d91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d7d:	0f be c9             	movsbl %cl,%ecx
  800d80:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d83:	39 f1                	cmp    %esi,%ecx
  800d85:	7d 0e                	jge    800d95 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	0f af c6             	imul   %esi,%eax
  800d8d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d8f:	eb c1                	jmp    800d52 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d91:	89 c1                	mov    %eax,%ecx
  800d93:	eb 02                	jmp    800d97 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d95:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9b:	74 05                	je     800da2 <strtol+0xce>
		*endptr = (char *) s;
  800d9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800da2:	89 ca                	mov    %ecx,%edx
  800da4:	f7 da                	neg    %edx
  800da6:	85 ff                	test   %edi,%edi
  800da8:	0f 45 c2             	cmovne %edx,%eax
}
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	89 c7                	mov    %eax,%edi
  800dce:	89 c6                	mov    %eax,%esi
  800dd0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_cgetc>:

int
sys_cgetc(void)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800deb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	ba 00 00 00 00       	mov    $0x0,%edx
  800df3:	b8 01 00 00 00       	mov    $0x1,%eax
  800df8:	89 d1                	mov    %edx,%ecx
  800dfa:	89 d3                	mov    %edx,%ebx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	89 d6                	mov    %edx,%esi
  800e00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0b:	89 ec                	mov    %ebp,%esp
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 38             	sub    $0x38,%esp
  800e15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e23:	b8 03 00 00 00       	mov    $0x3,%eax
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 cb                	mov    %ecx,%ebx
  800e2d:	89 cf                	mov    %ecx,%edi
  800e2f:	89 ce                	mov    %ecx,%esi
  800e31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 28                	jle    800e5f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e42:	00 
  800e43:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800e5a:	e8 25 f3 ff ff       	call   800184 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800e80:	b8 02 00 00 00       	mov    $0x2,%eax
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 d3                	mov    %edx,%ebx
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_yield>:

void
sys_yield(void)
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
  800eb0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb5:	89 d1                	mov    %edx,%ecx
  800eb7:	89 d3                	mov    %edx,%ebx
  800eb9:	89 d7                	mov    %edx,%edi
  800ebb:	89 d6                	mov    %edx,%esi
  800ebd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ebf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec8:	89 ec                	mov    %ebp,%esp
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 38             	sub    $0x38,%esp
  800ed2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edb:	be 00 00 00 00       	mov    $0x0,%esi
  800ee0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	89 f7                	mov    %esi,%edi
  800ef0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	7e 28                	jle    800f1e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f01:	00 
  800f02:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800f09:	00 
  800f0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f11:	00 
  800f12:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800f19:	e8 66 f2 ff ff       	call   800184 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f1e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f21:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f24:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f27:	89 ec                	mov    %ebp,%esp
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 38             	sub    $0x38,%esp
  800f31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f37:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f3f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	7e 28                	jle    800f7c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f58:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f5f:	00 
  800f60:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800f67:	00 
  800f68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f6f:	00 
  800f70:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800f77:	e8 08 f2 ff ff       	call   800184 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f7c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f82:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f85:	89 ec                	mov    %ebp,%esp
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 38             	sub    $0x38,%esp
  800f8f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f95:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	89 df                	mov    %ebx,%edi
  800faa:	89 de                	mov    %ebx,%esi
  800fac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 28                	jle    800fda <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fcd:	00 
  800fce:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800fd5:	e8 aa f1 ff ff       	call   800184 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fdd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe3:	89 ec                	mov    %ebp,%esp
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 38             	sub    $0x38,%esp
  800fed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ff0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ff3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffb:	b8 08 00 00 00       	mov    $0x8,%eax
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	89 df                	mov    %ebx,%edi
  801008:	89 de                	mov    %ebx,%esi
  80100a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	7e 28                	jle    801038 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801010:	89 44 24 10          	mov    %eax,0x10(%esp)
  801014:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80101b:	00 
  80101c:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  801023:	00 
  801024:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102b:	00 
  80102c:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  801033:	e8 4c f1 ff ff       	call   800184 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801038:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80103b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801041:	89 ec                	mov    %ebp,%esp
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 38             	sub    $0x38,%esp
  80104b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80104e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801051:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801054:	bb 00 00 00 00       	mov    $0x0,%ebx
  801059:	b8 09 00 00 00       	mov    $0x9,%eax
  80105e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801061:	8b 55 08             	mov    0x8(%ebp),%edx
  801064:	89 df                	mov    %ebx,%edi
  801066:	89 de                	mov    %ebx,%esi
  801068:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106a:	85 c0                	test   %eax,%eax
  80106c:	7e 28                	jle    801096 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801072:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801079:	00 
  80107a:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  801081:	00 
  801082:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801089:	00 
  80108a:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  801091:	e8 ee f0 ff ff       	call   800184 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801096:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801099:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80109c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80109f:	89 ec                	mov    %ebp,%esp
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b2:	be 00 00 00 00       	mov    $0x0,%esi
  8010b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d3:	89 ec                	mov    %ebp,%esp
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 38             	sub    $0x38,%esp
  8010dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f3:	89 cb                	mov    %ecx,%ebx
  8010f5:	89 cf                	mov    %ecx,%edi
  8010f7:	89 ce                	mov    %ecx,%esi
  8010f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	7e 28                	jle    801127 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801103:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80110a:	00 
  80110b:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  801112:	00 
  801113:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111a:	00 
  80111b:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  801122:	e8 5d f0 ff ff       	call   800184 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801127:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80112a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80112d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801130:	89 ec                	mov    %ebp,%esp
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    
	...

00801140 <__udivdi3>:
  801140:	83 ec 1c             	sub    $0x1c,%esp
  801143:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801147:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80114b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80114f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801153:	89 74 24 10          	mov    %esi,0x10(%esp)
  801157:	8b 74 24 24          	mov    0x24(%esp),%esi
  80115b:	85 ff                	test   %edi,%edi
  80115d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801161:	89 44 24 08          	mov    %eax,0x8(%esp)
  801165:	89 cd                	mov    %ecx,%ebp
  801167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116b:	75 33                	jne    8011a0 <__udivdi3+0x60>
  80116d:	39 f1                	cmp    %esi,%ecx
  80116f:	77 57                	ja     8011c8 <__udivdi3+0x88>
  801171:	85 c9                	test   %ecx,%ecx
  801173:	75 0b                	jne    801180 <__udivdi3+0x40>
  801175:	b8 01 00 00 00       	mov    $0x1,%eax
  80117a:	31 d2                	xor    %edx,%edx
  80117c:	f7 f1                	div    %ecx
  80117e:	89 c1                	mov    %eax,%ecx
  801180:	89 f0                	mov    %esi,%eax
  801182:	31 d2                	xor    %edx,%edx
  801184:	f7 f1                	div    %ecx
  801186:	89 c6                	mov    %eax,%esi
  801188:	8b 44 24 04          	mov    0x4(%esp),%eax
  80118c:	f7 f1                	div    %ecx
  80118e:	89 f2                	mov    %esi,%edx
  801190:	8b 74 24 10          	mov    0x10(%esp),%esi
  801194:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801198:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80119c:	83 c4 1c             	add    $0x1c,%esp
  80119f:	c3                   	ret    
  8011a0:	31 d2                	xor    %edx,%edx
  8011a2:	31 c0                	xor    %eax,%eax
  8011a4:	39 f7                	cmp    %esi,%edi
  8011a6:	77 e8                	ja     801190 <__udivdi3+0x50>
  8011a8:	0f bd cf             	bsr    %edi,%ecx
  8011ab:	83 f1 1f             	xor    $0x1f,%ecx
  8011ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011b2:	75 2c                	jne    8011e0 <__udivdi3+0xa0>
  8011b4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8011b8:	76 04                	jbe    8011be <__udivdi3+0x7e>
  8011ba:	39 f7                	cmp    %esi,%edi
  8011bc:	73 d2                	jae    801190 <__udivdi3+0x50>
  8011be:	31 d2                	xor    %edx,%edx
  8011c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c5:	eb c9                	jmp    801190 <__udivdi3+0x50>
  8011c7:	90                   	nop
  8011c8:	89 f2                	mov    %esi,%edx
  8011ca:	f7 f1                	div    %ecx
  8011cc:	31 d2                	xor    %edx,%edx
  8011ce:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011d2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011d6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011da:	83 c4 1c             	add    $0x1c,%esp
  8011dd:	c3                   	ret    
  8011de:	66 90                	xchg   %ax,%ax
  8011e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011e5:	b8 20 00 00 00       	mov    $0x20,%eax
  8011ea:	89 ea                	mov    %ebp,%edx
  8011ec:	2b 44 24 04          	sub    0x4(%esp),%eax
  8011f0:	d3 e7                	shl    %cl,%edi
  8011f2:	89 c1                	mov    %eax,%ecx
  8011f4:	d3 ea                	shr    %cl,%edx
  8011f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011fb:	09 fa                	or     %edi,%edx
  8011fd:	89 f7                	mov    %esi,%edi
  8011ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801203:	89 f2                	mov    %esi,%edx
  801205:	8b 74 24 08          	mov    0x8(%esp),%esi
  801209:	d3 e5                	shl    %cl,%ebp
  80120b:	89 c1                	mov    %eax,%ecx
  80120d:	d3 ef                	shr    %cl,%edi
  80120f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801214:	d3 e2                	shl    %cl,%edx
  801216:	89 c1                	mov    %eax,%ecx
  801218:	d3 ee                	shr    %cl,%esi
  80121a:	09 d6                	or     %edx,%esi
  80121c:	89 fa                	mov    %edi,%edx
  80121e:	89 f0                	mov    %esi,%eax
  801220:	f7 74 24 0c          	divl   0xc(%esp)
  801224:	89 d7                	mov    %edx,%edi
  801226:	89 c6                	mov    %eax,%esi
  801228:	f7 e5                	mul    %ebp
  80122a:	39 d7                	cmp    %edx,%edi
  80122c:	72 22                	jb     801250 <__udivdi3+0x110>
  80122e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801232:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801237:	d3 e5                	shl    %cl,%ebp
  801239:	39 c5                	cmp    %eax,%ebp
  80123b:	73 04                	jae    801241 <__udivdi3+0x101>
  80123d:	39 d7                	cmp    %edx,%edi
  80123f:	74 0f                	je     801250 <__udivdi3+0x110>
  801241:	89 f0                	mov    %esi,%eax
  801243:	31 d2                	xor    %edx,%edx
  801245:	e9 46 ff ff ff       	jmp    801190 <__udivdi3+0x50>
  80124a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801250:	8d 46 ff             	lea    -0x1(%esi),%eax
  801253:	31 d2                	xor    %edx,%edx
  801255:	8b 74 24 10          	mov    0x10(%esp),%esi
  801259:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80125d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801261:	83 c4 1c             	add    $0x1c,%esp
  801264:	c3                   	ret    
	...

00801270 <__umoddi3>:
  801270:	83 ec 1c             	sub    $0x1c,%esp
  801273:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801277:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80127b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80127f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801283:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801287:	8b 74 24 24          	mov    0x24(%esp),%esi
  80128b:	85 ed                	test   %ebp,%ebp
  80128d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801291:	89 44 24 08          	mov    %eax,0x8(%esp)
  801295:	89 cf                	mov    %ecx,%edi
  801297:	89 04 24             	mov    %eax,(%esp)
  80129a:	89 f2                	mov    %esi,%edx
  80129c:	75 1a                	jne    8012b8 <__umoddi3+0x48>
  80129e:	39 f1                	cmp    %esi,%ecx
  8012a0:	76 4e                	jbe    8012f0 <__umoddi3+0x80>
  8012a2:	f7 f1                	div    %ecx
  8012a4:	89 d0                	mov    %edx,%eax
  8012a6:	31 d2                	xor    %edx,%edx
  8012a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012b4:	83 c4 1c             	add    $0x1c,%esp
  8012b7:	c3                   	ret    
  8012b8:	39 f5                	cmp    %esi,%ebp
  8012ba:	77 54                	ja     801310 <__umoddi3+0xa0>
  8012bc:	0f bd c5             	bsr    %ebp,%eax
  8012bf:	83 f0 1f             	xor    $0x1f,%eax
  8012c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c6:	75 60                	jne    801328 <__umoddi3+0xb8>
  8012c8:	3b 0c 24             	cmp    (%esp),%ecx
  8012cb:	0f 87 07 01 00 00    	ja     8013d8 <__umoddi3+0x168>
  8012d1:	89 f2                	mov    %esi,%edx
  8012d3:	8b 34 24             	mov    (%esp),%esi
  8012d6:	29 ce                	sub    %ecx,%esi
  8012d8:	19 ea                	sbb    %ebp,%edx
  8012da:	89 34 24             	mov    %esi,(%esp)
  8012dd:	8b 04 24             	mov    (%esp),%eax
  8012e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012ec:	83 c4 1c             	add    $0x1c,%esp
  8012ef:	c3                   	ret    
  8012f0:	85 c9                	test   %ecx,%ecx
  8012f2:	75 0b                	jne    8012ff <__umoddi3+0x8f>
  8012f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f9:	31 d2                	xor    %edx,%edx
  8012fb:	f7 f1                	div    %ecx
  8012fd:	89 c1                	mov    %eax,%ecx
  8012ff:	89 f0                	mov    %esi,%eax
  801301:	31 d2                	xor    %edx,%edx
  801303:	f7 f1                	div    %ecx
  801305:	8b 04 24             	mov    (%esp),%eax
  801308:	f7 f1                	div    %ecx
  80130a:	eb 98                	jmp    8012a4 <__umoddi3+0x34>
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	89 f2                	mov    %esi,%edx
  801312:	8b 74 24 10          	mov    0x10(%esp),%esi
  801316:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80131a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80131e:	83 c4 1c             	add    $0x1c,%esp
  801321:	c3                   	ret    
  801322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801328:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80132d:	89 e8                	mov    %ebp,%eax
  80132f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801334:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801338:	89 fa                	mov    %edi,%edx
  80133a:	d3 e0                	shl    %cl,%eax
  80133c:	89 e9                	mov    %ebp,%ecx
  80133e:	d3 ea                	shr    %cl,%edx
  801340:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801345:	09 c2                	or     %eax,%edx
  801347:	8b 44 24 08          	mov    0x8(%esp),%eax
  80134b:	89 14 24             	mov    %edx,(%esp)
  80134e:	89 f2                	mov    %esi,%edx
  801350:	d3 e7                	shl    %cl,%edi
  801352:	89 e9                	mov    %ebp,%ecx
  801354:	d3 ea                	shr    %cl,%edx
  801356:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80135b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80135f:	d3 e6                	shl    %cl,%esi
  801361:	89 e9                	mov    %ebp,%ecx
  801363:	d3 e8                	shr    %cl,%eax
  801365:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80136a:	09 f0                	or     %esi,%eax
  80136c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801370:	f7 34 24             	divl   (%esp)
  801373:	d3 e6                	shl    %cl,%esi
  801375:	89 74 24 08          	mov    %esi,0x8(%esp)
  801379:	89 d6                	mov    %edx,%esi
  80137b:	f7 e7                	mul    %edi
  80137d:	39 d6                	cmp    %edx,%esi
  80137f:	89 c1                	mov    %eax,%ecx
  801381:	89 d7                	mov    %edx,%edi
  801383:	72 3f                	jb     8013c4 <__umoddi3+0x154>
  801385:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801389:	72 35                	jb     8013c0 <__umoddi3+0x150>
  80138b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80138f:	29 c8                	sub    %ecx,%eax
  801391:	19 fe                	sbb    %edi,%esi
  801393:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801398:	89 f2                	mov    %esi,%edx
  80139a:	d3 e8                	shr    %cl,%eax
  80139c:	89 e9                	mov    %ebp,%ecx
  80139e:	d3 e2                	shl    %cl,%edx
  8013a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013a5:	09 d0                	or     %edx,%eax
  8013a7:	89 f2                	mov    %esi,%edx
  8013a9:	d3 ea                	shr    %cl,%edx
  8013ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013b7:	83 c4 1c             	add    $0x1c,%esp
  8013ba:	c3                   	ret    
  8013bb:	90                   	nop
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	39 d6                	cmp    %edx,%esi
  8013c2:	75 c7                	jne    80138b <__umoddi3+0x11b>
  8013c4:	89 d7                	mov    %edx,%edi
  8013c6:	89 c1                	mov    %eax,%ecx
  8013c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8013cc:	1b 3c 24             	sbb    (%esp),%edi
  8013cf:	eb ba                	jmp    80138b <__umoddi3+0x11b>
  8013d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	39 f5                	cmp    %esi,%ebp
  8013da:	0f 82 f1 fe ff ff    	jb     8012d1 <__umoddi3+0x61>
  8013e0:	e9 f8 fe ff ff       	jmp    8012dd <__umoddi3+0x6d>
