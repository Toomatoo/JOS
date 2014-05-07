
obj/user/testbss.debug:     file format elf32-i386


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
  80003a:	c7 04 24 e0 23 80 00 	movl   $0x8023e0,(%esp)
  800041:	e8 41 02 00 00       	call   800287 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0) {
  800046:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0) {
  800054:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
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
  800069:	c7 44 24 08 5b 24 80 	movl   $0x80245b,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  800080:	e8 07 01 00 00       	call   80018c <_panic>
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
  800094:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)
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
  8000a5:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  8000ac:	75 10                	jne    8000be <umain+0x8a>
			//cprintf("%u not zero\n", bigarray[i]);
			panic("bigarray[%d] isn't cleared!\n", i);
		}
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  8000ba:	74 27                	je     8000e3 <umain+0xaf>
  8000bc:	eb 05                	jmp    8000c3 <umain+0x8f>
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c7:	c7 44 24 08 00 24 80 	movl   $0x802400,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  8000de:	e8 a9 00 00 00       	call   80018c <_panic>
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
  8000ed:	c7 04 24 28 24 80 00 	movl   $0x802428,(%esp)
  8000f4:	e8 8e 01 00 00       	call   800287 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 87 24 80 	movl   $0x802487,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  80011a:	e8 6d 00 00 00       	call   80018c <_panic>
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
  800132:	e8 45 0d 00 00       	call   800e7c <sys_getenvid>
  800137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013c:	c1 e0 07             	shl    $0x7,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	85 f6                	test   %esi,%esi
  80014b:	7e 07                	jle    800154 <libmain+0x34>
		binaryname = argv[0];
  80014d:	8b 03                	mov    (%ebx),%eax
  80014f:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800176:	e8 83 12 00 00       	call   8013fe <close_all>
	sys_env_destroy(0);
  80017b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800182:	e8 98 0c 00 00       	call   800e1f <sys_env_destroy>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
	...

0080018c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800194:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800197:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80019d:	e8 da 0c 00 00       	call   800e7c <sys_getenvid>
  8001a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  8001bf:	e8 c3 00 00 00       	call   800287 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 53 00 00 00       	call   800226 <vcprintf>
	cprintf("\n");
  8001d3:	c7 04 24 76 24 80 00 	movl   $0x802476,(%esp)
  8001da:	e8 a8 00 00 00       	call   800287 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x53>
	...

008001e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	53                   	push   %ebx
  8001e8:	83 ec 14             	sub    $0x14,%esp
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ee:	8b 03                	mov    (%ebx),%eax
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f7:	83 c0 01             	add    $0x1,%eax
  8001fa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800201:	75 19                	jne    80021c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800203:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020a:	00 
  80020b:	8d 43 08             	lea    0x8(%ebx),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 aa 0b 00 00       	call   800dc0 <sys_cputs>
		b->idx = 0;
  800216:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80021c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800220:	83 c4 14             	add    $0x14,%esp
  800223:	5b                   	pop    %ebx
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800236:	00 00 00 
	b.cnt = 0;
  800239:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800240:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800251:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	c7 04 24 e4 01 80 00 	movl   $0x8001e4,(%esp)
  800262:	e8 97 01 00 00       	call   8003fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	e8 41 0b 00 00       	call   800dc0 <sys_cputs>

	return b.cnt;
}
  80027f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800285:	c9                   	leave  
  800286:	c3                   	ret    

00800287 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800290:	89 44 24 04          	mov    %eax,0x4(%esp)
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	e8 87 ff ff ff       	call   800226 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    
  8002a1:	00 00                	add    %al,(%eax)
	...

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 3c             	sub    $0x3c,%esp
  8002ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b0:	89 d7                	mov    %edx,%edi
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002cc:	72 11                	jb     8002df <printnum+0x3b>
  8002ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d4:	76 09                	jbe    8002df <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d6:	83 eb 01             	sub    $0x1,%ebx
  8002d9:	85 db                	test   %ebx,%ebx
  8002db:	7f 51                	jg     80032e <printnum+0x8a>
  8002dd:	eb 5e                	jmp    80033d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002e3:	83 eb 01             	sub    $0x1,%ebx
  8002e6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002f5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800300:	00 
  800301:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030e:	e8 1d 1e 00 00       	call   802130 <__udivdi3>
  800313:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800317:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800322:	89 fa                	mov    %edi,%edx
  800324:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800327:	e8 78 ff ff ff       	call   8002a4 <printnum>
  80032c:	eb 0f                	jmp    80033d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800332:	89 34 24             	mov    %esi,(%esp)
  800335:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800338:	83 eb 01             	sub    $0x1,%ebx
  80033b:	75 f1                	jne    80032e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800345:	8b 45 10             	mov    0x10(%ebp),%eax
  800348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800353:	00 
  800354:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800357:	89 04 24             	mov    %eax,(%esp)
  80035a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800361:	e8 fa 1e 00 00       	call   802260 <__umoddi3>
  800366:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036a:	0f be 80 cb 24 80 00 	movsbl 0x8024cb(%eax),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800377:	83 c4 3c             	add    $0x3c,%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800382:	83 fa 01             	cmp    $0x1,%edx
  800385:	7e 0e                	jle    800395 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800387:	8b 10                	mov    (%eax),%edx
  800389:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 02                	mov    (%edx),%eax
  800390:	8b 52 04             	mov    0x4(%edx),%edx
  800393:	eb 22                	jmp    8003b7 <getuint+0x38>
	else if (lflag)
  800395:	85 d2                	test   %edx,%edx
  800397:	74 10                	je     8003a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a7:	eb 0e                	jmp    8003b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c8:	73 0a                	jae    8003d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003cd:	88 0a                	mov    %cl,(%edx)
  8003cf:	83 c2 01             	add    $0x1,%edx
  8003d2:	89 10                	mov    %edx,(%eax)
}
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	e8 02 00 00 00       	call   8003fe <vprintfmt>
	va_end(ap);
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 5c             	sub    $0x5c,%esp
  800407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040a:	8b 75 10             	mov    0x10(%ebp),%esi
  80040d:	eb 12                	jmp    800421 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80040f:	85 c0                	test   %eax,%eax
  800411:	0f 84 e4 04 00 00    	je     8008fb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800417:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800421:	0f b6 06             	movzbl (%esi),%eax
  800424:	83 c6 01             	add    $0x1,%esi
  800427:	83 f8 25             	cmp    $0x25,%eax
  80042a:	75 e3                	jne    80040f <vprintfmt+0x11>
  80042c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800430:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800437:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80043c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800443:	b9 00 00 00 00       	mov    $0x0,%ecx
  800448:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80044b:	eb 2b                	jmp    800478 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800450:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800454:	eb 22                	jmp    800478 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800459:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80045d:	eb 19                	jmp    800478 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800462:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800469:	eb 0d                	jmp    800478 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80046b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80046e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800471:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	0f b6 06             	movzbl (%esi),%eax
  80047b:	0f b6 d0             	movzbl %al,%edx
  80047e:	8d 7e 01             	lea    0x1(%esi),%edi
  800481:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800484:	83 e8 23             	sub    $0x23,%eax
  800487:	3c 55                	cmp    $0x55,%al
  800489:	0f 87 46 04 00 00    	ja     8008d5 <vprintfmt+0x4d7>
  80048f:	0f b6 c0             	movzbl %al,%eax
  800492:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800499:	83 ea 30             	sub    $0x30,%edx
  80049c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80049f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004a3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004a9:	83 fa 09             	cmp    $0x9,%edx
  8004ac:	77 4a                	ja     8004f8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004b4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004b7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004bb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004be:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c1:	83 fa 09             	cmp    $0x9,%edx
  8004c4:	76 eb                	jbe    8004b1 <vprintfmt+0xb3>
  8004c6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004c9:	eb 2d                	jmp    8004f8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	8b 00                	mov    (%eax),%eax
  8004d6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004dc:	eb 1a                	jmp    8004f8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004e1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e5:	79 91                	jns    800478 <vprintfmt+0x7a>
  8004e7:	e9 73 ff ff ff       	jmp    80045f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ef:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004f6:	eb 80                	jmp    800478 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004fc:	0f 89 76 ff ff ff    	jns    800478 <vprintfmt+0x7a>
  800502:	e9 64 ff ff ff       	jmp    80046b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800507:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050d:	e9 66 ff ff ff       	jmp    800478 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052a:	e9 f2 fe ff ff       	jmp    800421 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80052f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800533:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800536:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80053a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80053d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800541:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800544:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800547:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80054b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80054e:	80 f9 09             	cmp    $0x9,%cl
  800551:	77 1d                	ja     800570 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800553:	0f be c0             	movsbl %al,%eax
  800556:	6b c0 64             	imul   $0x64,%eax,%eax
  800559:	0f be d2             	movsbl %dl,%edx
  80055c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80055f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800566:	a3 04 30 80 00       	mov    %eax,0x803004
  80056b:	e9 b1 fe ff ff       	jmp    800421 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800570:	c7 44 24 04 e3 24 80 	movl   $0x8024e3,0x4(%esp)
  800577:	00 
  800578:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	e8 18 05 00 00       	call   800a9b <strcmp>
  800583:	85 c0                	test   %eax,%eax
  800585:	75 0f                	jne    800596 <vprintfmt+0x198>
  800587:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  80058e:	00 00 00 
  800591:	e9 8b fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800596:	c7 44 24 04 e7 24 80 	movl   $0x8024e7,0x4(%esp)
  80059d:	00 
  80059e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005a1:	89 14 24             	mov    %edx,(%esp)
  8005a4:	e8 f2 04 00 00       	call   800a9b <strcmp>
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	75 0f                	jne    8005bc <vprintfmt+0x1be>
  8005ad:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8005b4:	00 00 00 
  8005b7:	e9 65 fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005bc:	c7 44 24 04 eb 24 80 	movl   $0x8024eb,0x4(%esp)
  8005c3:	00 
  8005c4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005c7:	89 0c 24             	mov    %ecx,(%esp)
  8005ca:	e8 cc 04 00 00       	call   800a9b <strcmp>
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	75 0f                	jne    8005e2 <vprintfmt+0x1e4>
  8005d3:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8005da:	00 00 00 
  8005dd:	e9 3f fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005e2:	c7 44 24 04 ef 24 80 	movl   $0x8024ef,0x4(%esp)
  8005e9:	00 
  8005ea:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005ed:	89 3c 24             	mov    %edi,(%esp)
  8005f0:	e8 a6 04 00 00       	call   800a9b <strcmp>
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	75 0f                	jne    800608 <vprintfmt+0x20a>
  8005f9:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800600:	00 00 00 
  800603:	e9 19 fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800608:	c7 44 24 04 f3 24 80 	movl   $0x8024f3,0x4(%esp)
  80060f:	00 
  800610:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	e8 80 04 00 00       	call   800a9b <strcmp>
  80061b:	85 c0                	test   %eax,%eax
  80061d:	75 0f                	jne    80062e <vprintfmt+0x230>
  80061f:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800626:	00 00 00 
  800629:	e9 f3 fd ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80062e:	c7 44 24 04 f7 24 80 	movl   $0x8024f7,0x4(%esp)
  800635:	00 
  800636:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800639:	89 14 24             	mov    %edx,(%esp)
  80063c:	e8 5a 04 00 00       	call   800a9b <strcmp>
  800641:	83 f8 01             	cmp    $0x1,%eax
  800644:	19 c0                	sbb    %eax,%eax
  800646:	f7 d0                	not    %eax
  800648:	83 c0 08             	add    $0x8,%eax
  80064b:	a3 04 30 80 00       	mov    %eax,0x803004
  800650:	e9 cc fd ff ff       	jmp    800421 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	89 c2                	mov    %eax,%edx
  800662:	c1 fa 1f             	sar    $0x1f,%edx
  800665:	31 d0                	xor    %edx,%eax
  800667:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800669:	83 f8 0f             	cmp    $0xf,%eax
  80066c:	7f 0b                	jg     800679 <vprintfmt+0x27b>
  80066e:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800675:	85 d2                	test   %edx,%edx
  800677:	75 23                	jne    80069c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800679:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067d:	c7 44 24 08 fb 24 80 	movl   $0x8024fb,0x8(%esp)
  800684:	00 
  800685:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800689:	8b 7d 08             	mov    0x8(%ebp),%edi
  80068c:	89 3c 24             	mov    %edi,(%esp)
  80068f:	e8 42 fd ff ff       	call   8003d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800697:	e9 85 fd ff ff       	jmp    800421 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80069c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a0:	c7 44 24 08 b5 28 80 	movl   $0x8028b5,0x8(%esp)
  8006a7:	00 
  8006a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	89 3c 24             	mov    %edi,(%esp)
  8006b2:	e8 1f fd ff ff       	call   8003d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006ba:	e9 62 fd ff ff       	jmp    800421 <vprintfmt+0x23>
  8006bf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006c5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006d3:	85 f6                	test   %esi,%esi
  8006d5:	b8 dc 24 80 00       	mov    $0x8024dc,%eax
  8006da:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006dd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006e1:	7e 06                	jle    8006e9 <vprintfmt+0x2eb>
  8006e3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006e7:	75 13                	jne    8006fc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e9:	0f be 06             	movsbl (%esi),%eax
  8006ec:	83 c6 01             	add    $0x1,%esi
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	0f 85 94 00 00 00    	jne    80078b <vprintfmt+0x38d>
  8006f7:	e9 81 00 00 00       	jmp    80077d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800700:	89 34 24             	mov    %esi,(%esp)
  800703:	e8 a3 02 00 00       	call   8009ab <strnlen>
  800708:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80070b:	29 c2                	sub    %eax,%edx
  80070d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800710:	85 d2                	test   %edx,%edx
  800712:	7e d5                	jle    8006e9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800714:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800718:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80071b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80071e:	89 d6                	mov    %edx,%esi
  800720:	89 cf                	mov    %ecx,%edi
  800722:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800726:	89 3c 24             	mov    %edi,(%esp)
  800729:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072c:	83 ee 01             	sub    $0x1,%esi
  80072f:	75 f1                	jne    800722 <vprintfmt+0x324>
  800731:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800734:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800737:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80073a:	eb ad                	jmp    8006e9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800740:	74 1b                	je     80075d <vprintfmt+0x35f>
  800742:	8d 50 e0             	lea    -0x20(%eax),%edx
  800745:	83 fa 5e             	cmp    $0x5e,%edx
  800748:	76 13                	jbe    80075d <vprintfmt+0x35f>
					putch('?', putdat);
  80074a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80074d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800751:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800758:	ff 55 08             	call   *0x8(%ebp)
  80075b:	eb 0d                	jmp    80076a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80075d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800760:	89 54 24 04          	mov    %edx,0x4(%esp)
  800764:	89 04 24             	mov    %eax,(%esp)
  800767:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076a:	83 eb 01             	sub    $0x1,%ebx
  80076d:	0f be 06             	movsbl (%esi),%eax
  800770:	83 c6 01             	add    $0x1,%esi
  800773:	85 c0                	test   %eax,%eax
  800775:	75 1a                	jne    800791 <vprintfmt+0x393>
  800777:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80077a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800780:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800784:	7f 1c                	jg     8007a2 <vprintfmt+0x3a4>
  800786:	e9 96 fc ff ff       	jmp    800421 <vprintfmt+0x23>
  80078b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80078e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800791:	85 ff                	test   %edi,%edi
  800793:	78 a7                	js     80073c <vprintfmt+0x33e>
  800795:	83 ef 01             	sub    $0x1,%edi
  800798:	79 a2                	jns    80073c <vprintfmt+0x33e>
  80079a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80079d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007a0:	eb db                	jmp    80077d <vprintfmt+0x37f>
  8007a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b7:	83 eb 01             	sub    $0x1,%ebx
  8007ba:	75 ee                	jne    8007aa <vprintfmt+0x3ac>
  8007bc:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007c1:	e9 5b fc ff ff       	jmp    800421 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c6:	83 f9 01             	cmp    $0x1,%ecx
  8007c9:	7e 10                	jle    8007db <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 08             	lea    0x8(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 30                	mov    (%eax),%esi
  8007d6:	8b 78 04             	mov    0x4(%eax),%edi
  8007d9:	eb 26                	jmp    800801 <vprintfmt+0x403>
	else if (lflag)
  8007db:	85 c9                	test   %ecx,%ecx
  8007dd:	74 12                	je     8007f1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 30                	mov    (%eax),%esi
  8007ea:	89 f7                	mov    %esi,%edi
  8007ec:	c1 ff 1f             	sar    $0x1f,%edi
  8007ef:	eb 10                	jmp    800801 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 04             	lea    0x4(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fa:	8b 30                	mov    (%eax),%esi
  8007fc:	89 f7                	mov    %esi,%edi
  8007fe:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800801:	85 ff                	test   %edi,%edi
  800803:	78 0e                	js     800813 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800805:	89 f0                	mov    %esi,%eax
  800807:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800809:	be 0a 00 00 00       	mov    $0xa,%esi
  80080e:	e9 84 00 00 00       	jmp    800897 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800813:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800817:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80081e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800821:	89 f0                	mov    %esi,%eax
  800823:	89 fa                	mov    %edi,%edx
  800825:	f7 d8                	neg    %eax
  800827:	83 d2 00             	adc    $0x0,%edx
  80082a:	f7 da                	neg    %edx
			}
			base = 10;
  80082c:	be 0a 00 00 00       	mov    $0xa,%esi
  800831:	eb 64                	jmp    800897 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800833:	89 ca                	mov    %ecx,%edx
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 42 fb ff ff       	call   80037f <getuint>
			base = 10;
  80083d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800842:	eb 53                	jmp    800897 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800844:	89 ca                	mov    %ecx,%edx
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 31 fb ff ff       	call   80037f <getuint>
    			base = 8;
  80084e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800853:	eb 42                	jmp    800897 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800855:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800859:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800860:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800863:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800867:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80086e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8d 50 04             	lea    0x4(%eax),%edx
  800877:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087a:	8b 00                	mov    (%eax),%eax
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800881:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800886:	eb 0f                	jmp    800897 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800888:	89 ca                	mov    %ecx,%edx
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
  80088d:	e8 ed fa ff ff       	call   80037f <getuint>
			base = 16;
  800892:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800897:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80089b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80089f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008a2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008a6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008aa:	89 04 24             	mov    %eax,(%esp)
  8008ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b1:	89 da                	mov    %ebx,%edx
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	e8 e9 f9 ff ff       	call   8002a4 <printnum>
			break;
  8008bb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008be:	e9 5e fb ff ff       	jmp    800421 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c7:	89 14 24             	mov    %edx,(%esp)
  8008ca:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d0:	e9 4c fb ff ff       	jmp    800421 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008e7:	0f 84 34 fb ff ff    	je     800421 <vprintfmt+0x23>
  8008ed:	83 ee 01             	sub    $0x1,%esi
  8008f0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f4:	75 f7                	jne    8008ed <vprintfmt+0x4ef>
  8008f6:	e9 26 fb ff ff       	jmp    800421 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008fb:	83 c4 5c             	add    $0x5c,%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5f                   	pop    %edi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	83 ec 28             	sub    $0x28,%esp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800912:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800916:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800919:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800920:	85 c0                	test   %eax,%eax
  800922:	74 30                	je     800954 <vsnprintf+0x51>
  800924:	85 d2                	test   %edx,%edx
  800926:	7e 2c                	jle    800954 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092f:	8b 45 10             	mov    0x10(%ebp),%eax
  800932:	89 44 24 08          	mov    %eax,0x8(%esp)
  800936:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093d:	c7 04 24 b9 03 80 00 	movl   $0x8003b9,(%esp)
  800944:	e8 b5 fa ff ff       	call   8003fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800949:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800952:	eb 05                	jmp    800959 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800954:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800961:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800964:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800968:	8b 45 10             	mov    0x10(%ebp),%eax
  80096b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	89 44 24 04          	mov    %eax,0x4(%esp)
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	e8 82 ff ff ff       	call   800903 <vsnprintf>
	va_end(ap);

	return rc;
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    
	...

00800990 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	80 3a 00             	cmpb   $0x0,(%edx)
  80099e:	74 09                	je     8009a9 <strlen+0x19>
		n++;
  8009a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a7:	75 f7                	jne    8009a0 <strlen+0x10>
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	85 c9                	test   %ecx,%ecx
  8009bc:	74 1a                	je     8009d8 <strnlen+0x2d>
  8009be:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009c1:	74 15                	je     8009d8 <strnlen+0x2d>
  8009c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ca:	39 ca                	cmp    %ecx,%edx
  8009cc:	74 0a                	je     8009d8 <strnlen+0x2d>
  8009ce:	83 c2 01             	add    $0x1,%edx
  8009d1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009d6:	75 f0                	jne    8009c8 <strnlen+0x1d>
		n++;
	return n;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f1:	83 c2 01             	add    $0x1,%edx
  8009f4:	84 c9                	test   %cl,%cl
  8009f6:	75 f2                	jne    8009ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a05:	89 1c 24             	mov    %ebx,(%esp)
  800a08:	e8 83 ff ff ff       	call   800990 <strlen>
	strcpy(dst + len, src);
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a10:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a14:	01 d8                	add    %ebx,%eax
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 bd ff ff ff       	call   8009db <strcpy>
	return dst;
}
  800a1e:	89 d8                	mov    %ebx,%eax
  800a20:	83 c4 08             	add    $0x8,%esp
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a34:	85 f6                	test   %esi,%esi
  800a36:	74 18                	je     800a50 <strncpy+0x2a>
  800a38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a3d:	0f b6 1a             	movzbl (%edx),%ebx
  800a40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a43:	80 3a 01             	cmpb   $0x1,(%edx)
  800a46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	39 f1                	cmp    %esi,%ecx
  800a4e:	75 ed                	jne    800a3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a60:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a63:	89 f8                	mov    %edi,%eax
  800a65:	85 f6                	test   %esi,%esi
  800a67:	74 2b                	je     800a94 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a69:	83 fe 01             	cmp    $0x1,%esi
  800a6c:	74 23                	je     800a91 <strlcpy+0x3d>
  800a6e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a71:	84 c9                	test   %cl,%cl
  800a73:	74 1c                	je     800a91 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a75:	83 ee 02             	sub    $0x2,%esi
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7d:	88 08                	mov    %cl,(%eax)
  800a7f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a82:	39 f2                	cmp    %esi,%edx
  800a84:	74 0b                	je     800a91 <strlcpy+0x3d>
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a8d:	84 c9                	test   %cl,%cl
  800a8f:	75 ec                	jne    800a7d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a94:	29 f8                	sub    %edi,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa4:	0f b6 01             	movzbl (%ecx),%eax
  800aa7:	84 c0                	test   %al,%al
  800aa9:	74 16                	je     800ac1 <strcmp+0x26>
  800aab:	3a 02                	cmp    (%edx),%al
  800aad:	75 12                	jne    800ac1 <strcmp+0x26>
		p++, q++;
  800aaf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ab6:	84 c0                	test   %al,%al
  800ab8:	74 07                	je     800ac1 <strcmp+0x26>
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	3a 02                	cmp    (%edx),%al
  800abf:	74 ee                	je     800aaf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac1:	0f b6 c0             	movzbl %al,%eax
  800ac4:	0f b6 12             	movzbl (%edx),%edx
  800ac7:	29 d0                	sub    %edx,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800add:	85 d2                	test   %edx,%edx
  800adf:	74 28                	je     800b09 <strncmp+0x3e>
  800ae1:	0f b6 01             	movzbl (%ecx),%eax
  800ae4:	84 c0                	test   %al,%al
  800ae6:	74 24                	je     800b0c <strncmp+0x41>
  800ae8:	3a 03                	cmp    (%ebx),%al
  800aea:	75 20                	jne    800b0c <strncmp+0x41>
  800aec:	83 ea 01             	sub    $0x1,%edx
  800aef:	74 13                	je     800b04 <strncmp+0x39>
		n--, p++, q++;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af7:	0f b6 01             	movzbl (%ecx),%eax
  800afa:	84 c0                	test   %al,%al
  800afc:	74 0e                	je     800b0c <strncmp+0x41>
  800afe:	3a 03                	cmp    (%ebx),%al
  800b00:	74 ea                	je     800aec <strncmp+0x21>
  800b02:	eb 08                	jmp    800b0c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0c:	0f b6 01             	movzbl (%ecx),%eax
  800b0f:	0f b6 13             	movzbl (%ebx),%edx
  800b12:	29 d0                	sub    %edx,%eax
  800b14:	eb f3                	jmp    800b09 <strncmp+0x3e>

00800b16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b20:	0f b6 10             	movzbl (%eax),%edx
  800b23:	84 d2                	test   %dl,%dl
  800b25:	74 1c                	je     800b43 <strchr+0x2d>
		if (*s == c)
  800b27:	38 ca                	cmp    %cl,%dl
  800b29:	75 09                	jne    800b34 <strchr+0x1e>
  800b2b:	eb 1b                	jmp    800b48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b2d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b30:	38 ca                	cmp    %cl,%dl
  800b32:	74 14                	je     800b48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b34:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b38:	84 d2                	test   %dl,%dl
  800b3a:	75 f1                	jne    800b2d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	eb 05                	jmp    800b48 <strchr+0x32>
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b54:	0f b6 10             	movzbl (%eax),%edx
  800b57:	84 d2                	test   %dl,%dl
  800b59:	74 14                	je     800b6f <strfind+0x25>
		if (*s == c)
  800b5b:	38 ca                	cmp    %cl,%dl
  800b5d:	75 06                	jne    800b65 <strfind+0x1b>
  800b5f:	eb 0e                	jmp    800b6f <strfind+0x25>
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 0a                	je     800b6f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b65:	83 c0 01             	add    $0x1,%eax
  800b68:	0f b6 10             	movzbl (%eax),%edx
  800b6b:	84 d2                	test   %dl,%dl
  800b6d:	75 f2                	jne    800b61 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b89:	85 c9                	test   %ecx,%ecx
  800b8b:	74 30                	je     800bbd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b93:	75 25                	jne    800bba <memset+0x49>
  800b95:	f6 c1 03             	test   $0x3,%cl
  800b98:	75 20                	jne    800bba <memset+0x49>
		c &= 0xFF;
  800b9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	c1 e3 08             	shl    $0x8,%ebx
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	c1 e6 18             	shl    $0x18,%esi
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	c1 e0 10             	shl    $0x10,%eax
  800bac:	09 f0                	or     %esi,%eax
  800bae:	09 d0                	or     %edx,%eax
  800bb0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bb2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bb5:	fc                   	cld    
  800bb6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb8:	eb 03                	jmp    800bbd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bba:	fc                   	cld    
  800bbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbd:	89 f8                	mov    %edi,%eax
  800bbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc8:	89 ec                	mov    %ebp,%esp
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 08             	sub    $0x8,%esp
  800bd2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be1:	39 c6                	cmp    %eax,%esi
  800be3:	73 36                	jae    800c1b <memmove+0x4f>
  800be5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be8:	39 d0                	cmp    %edx,%eax
  800bea:	73 2f                	jae    800c1b <memmove+0x4f>
		s += n;
		d += n;
  800bec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bef:	f6 c2 03             	test   $0x3,%dl
  800bf2:	75 1b                	jne    800c0f <memmove+0x43>
  800bf4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfa:	75 13                	jne    800c0f <memmove+0x43>
  800bfc:	f6 c1 03             	test   $0x3,%cl
  800bff:	75 0e                	jne    800c0f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c01:	83 ef 04             	sub    $0x4,%edi
  800c04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c0a:	fd                   	std    
  800c0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0d:	eb 09                	jmp    800c18 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c0f:	83 ef 01             	sub    $0x1,%edi
  800c12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c15:	fd                   	std    
  800c16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c18:	fc                   	cld    
  800c19:	eb 20                	jmp    800c3b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c21:	75 13                	jne    800c36 <memmove+0x6a>
  800c23:	a8 03                	test   $0x3,%al
  800c25:	75 0f                	jne    800c36 <memmove+0x6a>
  800c27:	f6 c1 03             	test   $0x3,%cl
  800c2a:	75 0a                	jne    800c36 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c2f:	89 c7                	mov    %eax,%edi
  800c31:	fc                   	cld    
  800c32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c34:	eb 05                	jmp    800c3b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	fc                   	cld    
  800c39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c41:	89 ec                	mov    %ebp,%esp
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	89 04 24             	mov    %eax,(%esp)
  800c5f:	e8 68 ff ff ff       	call   800bcc <memmove>
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c72:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	85 ff                	test   %edi,%edi
  800c7c:	74 37                	je     800cb5 <memcmp+0x4f>
		if (*s1 != *s2)
  800c7e:	0f b6 03             	movzbl (%ebx),%eax
  800c81:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c84:	83 ef 01             	sub    $0x1,%edi
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c8c:	38 c8                	cmp    %cl,%al
  800c8e:	74 1c                	je     800cac <memcmp+0x46>
  800c90:	eb 10                	jmp    800ca2 <memcmp+0x3c>
  800c92:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c97:	83 c2 01             	add    $0x1,%edx
  800c9a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c9e:	38 c8                	cmp    %cl,%al
  800ca0:	74 0a                	je     800cac <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800ca2:	0f b6 c0             	movzbl %al,%eax
  800ca5:	0f b6 c9             	movzbl %cl,%ecx
  800ca8:	29 c8                	sub    %ecx,%eax
  800caa:	eb 09                	jmp    800cb5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cac:	39 fa                	cmp    %edi,%edx
  800cae:	75 e2                	jne    800c92 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cc0:	89 c2                	mov    %eax,%edx
  800cc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cc5:	39 d0                	cmp    %edx,%eax
  800cc7:	73 19                	jae    800ce2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ccd:	38 08                	cmp    %cl,(%eax)
  800ccf:	75 06                	jne    800cd7 <memfind+0x1d>
  800cd1:	eb 0f                	jmp    800ce2 <memfind+0x28>
  800cd3:	38 08                	cmp    %cl,(%eax)
  800cd5:	74 0b                	je     800ce2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd7:	83 c0 01             	add    $0x1,%eax
  800cda:	39 d0                	cmp    %edx,%eax
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	75 f1                	jne    800cd3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf0:	0f b6 02             	movzbl (%edx),%eax
  800cf3:	3c 20                	cmp    $0x20,%al
  800cf5:	74 04                	je     800cfb <strtol+0x17>
  800cf7:	3c 09                	cmp    $0x9,%al
  800cf9:	75 0e                	jne    800d09 <strtol+0x25>
		s++;
  800cfb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfe:	0f b6 02             	movzbl (%edx),%eax
  800d01:	3c 20                	cmp    $0x20,%al
  800d03:	74 f6                	je     800cfb <strtol+0x17>
  800d05:	3c 09                	cmp    $0x9,%al
  800d07:	74 f2                	je     800cfb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d09:	3c 2b                	cmp    $0x2b,%al
  800d0b:	75 0a                	jne    800d17 <strtol+0x33>
		s++;
  800d0d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d10:	bf 00 00 00 00       	mov    $0x0,%edi
  800d15:	eb 10                	jmp    800d27 <strtol+0x43>
  800d17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d1c:	3c 2d                	cmp    $0x2d,%al
  800d1e:	75 07                	jne    800d27 <strtol+0x43>
		s++, neg = 1;
  800d20:	83 c2 01             	add    $0x1,%edx
  800d23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d27:	85 db                	test   %ebx,%ebx
  800d29:	0f 94 c0             	sete   %al
  800d2c:	74 05                	je     800d33 <strtol+0x4f>
  800d2e:	83 fb 10             	cmp    $0x10,%ebx
  800d31:	75 15                	jne    800d48 <strtol+0x64>
  800d33:	80 3a 30             	cmpb   $0x30,(%edx)
  800d36:	75 10                	jne    800d48 <strtol+0x64>
  800d38:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d3c:	75 0a                	jne    800d48 <strtol+0x64>
		s += 2, base = 16;
  800d3e:	83 c2 02             	add    $0x2,%edx
  800d41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d46:	eb 13                	jmp    800d5b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d48:	84 c0                	test   %al,%al
  800d4a:	74 0f                	je     800d5b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d51:	80 3a 30             	cmpb   $0x30,(%edx)
  800d54:	75 05                	jne    800d5b <strtol+0x77>
		s++, base = 8;
  800d56:	83 c2 01             	add    $0x1,%edx
  800d59:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d60:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d62:	0f b6 0a             	movzbl (%edx),%ecx
  800d65:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d68:	80 fb 09             	cmp    $0x9,%bl
  800d6b:	77 08                	ja     800d75 <strtol+0x91>
			dig = *s - '0';
  800d6d:	0f be c9             	movsbl %cl,%ecx
  800d70:	83 e9 30             	sub    $0x30,%ecx
  800d73:	eb 1e                	jmp    800d93 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d75:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d78:	80 fb 19             	cmp    $0x19,%bl
  800d7b:	77 08                	ja     800d85 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d7d:	0f be c9             	movsbl %cl,%ecx
  800d80:	83 e9 57             	sub    $0x57,%ecx
  800d83:	eb 0e                	jmp    800d93 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d85:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d88:	80 fb 19             	cmp    $0x19,%bl
  800d8b:	77 14                	ja     800da1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d8d:	0f be c9             	movsbl %cl,%ecx
  800d90:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d93:	39 f1                	cmp    %esi,%ecx
  800d95:	7d 0e                	jge    800da5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d97:	83 c2 01             	add    $0x1,%edx
  800d9a:	0f af c6             	imul   %esi,%eax
  800d9d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d9f:	eb c1                	jmp    800d62 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800da1:	89 c1                	mov    %eax,%ecx
  800da3:	eb 02                	jmp    800da7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800da7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dab:	74 05                	je     800db2 <strtol+0xce>
		*endptr = (char *) s;
  800dad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800db0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800db2:	89 ca                	mov    %ecx,%edx
  800db4:	f7 da                	neg    %edx
  800db6:	85 ff                	test   %edi,%edi
  800db8:	0f 45 c2             	cmovne %edx,%eax
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 c7                	mov    %eax,%edi
  800dde:	89 c6                	mov    %eax,%esi
  800de0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_cgetc>:

int
sys_cgetc(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800e03:	b8 01 00 00 00       	mov    $0x1,%eax
  800e08:	89 d1                	mov    %edx,%ecx
  800e0a:	89 d3                	mov    %edx,%ebx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 d6                	mov    %edx,%esi
  800e10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 38             	sub    $0x38,%esp
  800e25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e33:	b8 03 00 00 00       	mov    $0x3,%eax
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 cb                	mov    %ecx,%ebx
  800e3d:	89 cf                	mov    %ecx,%edi
  800e3f:	89 ce                	mov    %ecx,%esi
  800e41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 28                	jle    800e6f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e52:	00 
  800e53:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800e6a:	e8 1d f3 ff ff       	call   80018c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800e90:	b8 02 00 00 00       	mov    $0x2,%eax
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 d3                	mov    %edx,%ebx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_yield>:

void
sys_yield(void)
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
  800ec0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 38             	sub    $0x38,%esp
  800ee2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
  800ef0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 f7                	mov    %esi,%edi
  800f00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	7e 28                	jle    800f2e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f11:	00 
  800f12:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800f29:	e8 5e f2 ff ff       	call   80018c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f37:	89 ec                	mov    %ebp,%esp
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 38             	sub    $0x38,%esp
  800f41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f60:	85 c0                	test   %eax,%eax
  800f62:	7e 28                	jle    800f8c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f6f:	00 
  800f70:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800f87:	e8 00 f2 ff ff       	call   80018c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f95:	89 ec                	mov    %ebp,%esp
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 38             	sub    $0x38,%esp
  800f9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fad:	b8 06 00 00 00       	mov    $0x6,%eax
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 df                	mov    %ebx,%edi
  800fba:	89 de                	mov    %ebx,%esi
  800fbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	7e 28                	jle    800fea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fcd:	00 
  800fce:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdd:	00 
  800fde:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800fe5:	e8 a2 f1 ff ff       	call   80018c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff3:	89 ec                	mov    %ebp,%esp
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 38             	sub    $0x38,%esp
  800ffd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801000:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801003:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100b:	b8 08 00 00 00       	mov    $0x8,%eax
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	89 df                	mov    %ebx,%edi
  801018:	89 de                	mov    %ebx,%esi
  80101a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	7e 28                	jle    801048 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801020:	89 44 24 10          	mov    %eax,0x10(%esp)
  801024:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80102b:	00 
  80102c:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  801043:	e8 44 f1 ff ff       	call   80018c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801048:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801051:	89 ec                	mov    %ebp,%esp
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 38             	sub    $0x38,%esp
  80105b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80105e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801061:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801064:	bb 00 00 00 00       	mov    $0x0,%ebx
  801069:	b8 09 00 00 00       	mov    $0x9,%eax
  80106e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801071:	8b 55 08             	mov    0x8(%ebp),%edx
  801074:	89 df                	mov    %ebx,%edi
  801076:	89 de                	mov    %ebx,%esi
  801078:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	7e 28                	jle    8010a6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801082:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801089:	00 
  80108a:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  801091:	00 
  801092:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801099:	00 
  80109a:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  8010a1:	e8 e6 f0 ff ff       	call   80018c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010af:	89 ec                	mov    %ebp,%esp
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 38             	sub    $0x38,%esp
  8010b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d2:	89 df                	mov    %ebx,%edi
  8010d4:	89 de                	mov    %ebx,%esi
  8010d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	7e 28                	jle    801104 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010e7:	00 
  8010e8:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  8010ef:	00 
  8010f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f7:	00 
  8010f8:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  8010ff:	e8 88 f0 ff ff       	call   80018c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801104:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801107:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80110d:	89 ec                	mov    %ebp,%esp
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80111d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801120:	be 00 00 00 00       	mov    $0x0,%esi
  801125:	b8 0c 00 00 00       	mov    $0xc,%eax
  80112a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80112d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801133:	8b 55 08             	mov    0x8(%ebp),%edx
  801136:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801138:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80113b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801141:	89 ec                	mov    %ebp,%esp
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 38             	sub    $0x38,%esp
  80114b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80114e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801151:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801154:	b9 00 00 00 00       	mov    $0x0,%ecx
  801159:	b8 0d 00 00 00       	mov    $0xd,%eax
  80115e:	8b 55 08             	mov    0x8(%ebp),%edx
  801161:	89 cb                	mov    %ecx,%ebx
  801163:	89 cf                	mov    %ecx,%edi
  801165:	89 ce                	mov    %ecx,%esi
  801167:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	7e 28                	jle    801195 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801171:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801178:	00 
  801179:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  801180:	00 
  801181:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801188:	00 
  801189:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  801190:	e8 f7 ef ff ff       	call   80018c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801195:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801198:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80119b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80119e:	89 ec                	mov    %ebp,%esp
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	83 ec 0c             	sub    $0xc,%esp
  8011a8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011ae:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011b6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011be:	89 cb                	mov    %ecx,%ebx
  8011c0:	89 cf                	mov    %ecx,%edi
  8011c2:	89 ce                	mov    %ecx,%esi
  8011c4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8011c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011cf:	89 ec                	mov    %ebp,%esp
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    
	...

008011e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	89 04 24             	mov    %eax,(%esp)
  8011fc:	e8 df ff ff ff       	call   8011e0 <fd2num>
  801201:	05 20 00 0d 00       	add    $0xd0020,%eax
  801206:	c1 e0 0c             	shl    $0xc,%eax
}
  801209:	c9                   	leave  
  80120a:	c3                   	ret    

0080120b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	53                   	push   %ebx
  80120f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801212:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801217:	a8 01                	test   $0x1,%al
  801219:	74 34                	je     80124f <fd_alloc+0x44>
  80121b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801220:	a8 01                	test   $0x1,%al
  801222:	74 32                	je     801256 <fd_alloc+0x4b>
  801224:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801229:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	c1 ea 16             	shr    $0x16,%edx
  801230:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801237:	f6 c2 01             	test   $0x1,%dl
  80123a:	74 1f                	je     80125b <fd_alloc+0x50>
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	c1 ea 0c             	shr    $0xc,%edx
  801241:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801248:	f6 c2 01             	test   $0x1,%dl
  80124b:	75 17                	jne    801264 <fd_alloc+0x59>
  80124d:	eb 0c                	jmp    80125b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80124f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801254:	eb 05                	jmp    80125b <fd_alloc+0x50>
  801256:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80125b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80125d:	b8 00 00 00 00       	mov    $0x0,%eax
  801262:	eb 17                	jmp    80127b <fd_alloc+0x70>
  801264:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801269:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126e:	75 b9                	jne    801229 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801270:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801276:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80127b:	5b                   	pop    %ebx
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801284:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801289:	83 fa 1f             	cmp    $0x1f,%edx
  80128c:	77 3f                	ja     8012cd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80128e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801294:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801297:	89 d0                	mov    %edx,%eax
  801299:	c1 e8 16             	shr    $0x16,%eax
  80129c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a8:	f6 c1 01             	test   $0x1,%cl
  8012ab:	74 20                	je     8012cd <fd_lookup+0x4f>
  8012ad:	89 d0                	mov    %edx,%eax
  8012af:	c1 e8 0c             	shr    $0xc,%eax
  8012b2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012be:	f6 c1 01             	test   $0x1,%cl
  8012c1:	74 0a                	je     8012cd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012e1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8012e7:	75 17                	jne    801300 <dev_lookup+0x31>
  8012e9:	eb 07                	jmp    8012f2 <dev_lookup+0x23>
  8012eb:	39 0a                	cmp    %ecx,(%edx)
  8012ed:	75 11                	jne    801300 <dev_lookup+0x31>
  8012ef:	90                   	nop
  8012f0:	eb 05                	jmp    8012f7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f2:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012f7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fe:	eb 35                	jmp    801335 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801300:	83 c0 01             	add    $0x1,%eax
  801303:	8b 14 85 8c 28 80 00 	mov    0x80288c(,%eax,4),%edx
  80130a:	85 d2                	test   %edx,%edx
  80130c:	75 dd                	jne    8012eb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130e:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801313:	8b 40 48             	mov    0x48(%eax),%eax
  801316:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131e:	c7 04 24 0c 28 80 00 	movl   $0x80280c,(%esp)
  801325:	e8 5d ef ff ff       	call   800287 <cprintf>
	*dev = 0;
  80132a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801330:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801335:	83 c4 14             	add    $0x14,%esp
  801338:	5b                   	pop    %ebx
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	83 ec 38             	sub    $0x38,%esp
  801341:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801344:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801347:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80134a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80134d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801351:	89 3c 24             	mov    %edi,(%esp)
  801354:	e8 87 fe ff ff       	call   8011e0 <fd2num>
  801359:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80135c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801360:	89 04 24             	mov    %eax,(%esp)
  801363:	e8 16 ff ff ff       	call   80127e <fd_lookup>
  801368:	89 c3                	mov    %eax,%ebx
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 05                	js     801373 <fd_close+0x38>
	    || fd != fd2)
  80136e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801371:	74 0e                	je     801381 <fd_close+0x46>
		return (must_exist ? r : 0);
  801373:	89 f0                	mov    %esi,%eax
  801375:	84 c0                	test   %al,%al
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
  80137c:	0f 44 d8             	cmove  %eax,%ebx
  80137f:	eb 3d                	jmp    8013be <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801381:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	8b 07                	mov    (%edi),%eax
  80138a:	89 04 24             	mov    %eax,(%esp)
  80138d:	e8 3d ff ff ff       	call   8012cf <dev_lookup>
  801392:	89 c3                	mov    %eax,%ebx
  801394:	85 c0                	test   %eax,%eax
  801396:	78 16                	js     8013ae <fd_close+0x73>
		if (dev->dev_close)
  801398:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80139b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80139e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 07                	je     8013ae <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8013a7:	89 3c 24             	mov    %edi,(%esp)
  8013aa:	ff d0                	call   *%eax
  8013ac:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b9:	e8 db fb ff ff       	call   800f99 <sys_page_unmap>
	return r;
}
  8013be:	89 d8                	mov    %ebx,%eax
  8013c0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013c3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013c6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013c9:	89 ec                	mov    %ebp,%esp
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dd:	89 04 24             	mov    %eax,(%esp)
  8013e0:	e8 99 fe ff ff       	call   80127e <fd_lookup>
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 13                	js     8013fc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013f0:	00 
  8013f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f4:	89 04 24             	mov    %eax,(%esp)
  8013f7:	e8 3f ff ff ff       	call   80133b <fd_close>
}
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <close_all>:

void
close_all(void)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	53                   	push   %ebx
  801402:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80140a:	89 1c 24             	mov    %ebx,(%esp)
  80140d:	e8 bb ff ff ff       	call   8013cd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801412:	83 c3 01             	add    $0x1,%ebx
  801415:	83 fb 20             	cmp    $0x20,%ebx
  801418:	75 f0                	jne    80140a <close_all+0xc>
		close(i);
}
  80141a:	83 c4 14             	add    $0x14,%esp
  80141d:	5b                   	pop    %ebx
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 58             	sub    $0x58,%esp
  801426:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801429:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80142c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80142f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801432:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801435:	89 44 24 04          	mov    %eax,0x4(%esp)
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	89 04 24             	mov    %eax,(%esp)
  80143f:	e8 3a fe ff ff       	call   80127e <fd_lookup>
  801444:	89 c3                	mov    %eax,%ebx
  801446:	85 c0                	test   %eax,%eax
  801448:	0f 88 e1 00 00 00    	js     80152f <dup+0x10f>
		return r;
	close(newfdnum);
  80144e:	89 3c 24             	mov    %edi,(%esp)
  801451:	e8 77 ff ff ff       	call   8013cd <close>

	newfd = INDEX2FD(newfdnum);
  801456:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80145c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80145f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 86 fd ff ff       	call   8011f0 <fd2data>
  80146a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80146c:	89 34 24             	mov    %esi,(%esp)
  80146f:	e8 7c fd ff ff       	call   8011f0 <fd2data>
  801474:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801477:	89 d8                	mov    %ebx,%eax
  801479:	c1 e8 16             	shr    $0x16,%eax
  80147c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801483:	a8 01                	test   $0x1,%al
  801485:	74 46                	je     8014cd <dup+0xad>
  801487:	89 d8                	mov    %ebx,%eax
  801489:	c1 e8 0c             	shr    $0xc,%eax
  80148c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801493:	f6 c2 01             	test   $0x1,%dl
  801496:	74 35                	je     8014cd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801498:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149f:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b6:	00 
  8014b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c2:	e8 74 fa ff ff       	call   800f3b <sys_page_map>
  8014c7:	89 c3                	mov    %eax,%ebx
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 3b                	js     801508 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	c1 ea 0c             	shr    $0xc,%edx
  8014d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014dc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014e2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f1:	00 
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fd:	e8 39 fa ff ff       	call   800f3b <sys_page_map>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	85 c0                	test   %eax,%eax
  801506:	79 25                	jns    80152d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801508:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801513:	e8 81 fa ff ff       	call   800f99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801518:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80151b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801526:	e8 6e fa ff ff       	call   800f99 <sys_page_unmap>
	return r;
  80152b:	eb 02                	jmp    80152f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80152d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801534:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801537:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80153a:	89 ec                	mov    %ebp,%esp
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 24             	sub    $0x24,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154f:	89 1c 24             	mov    %ebx,(%esp)
  801552:	e8 27 fd ff ff       	call   80127e <fd_lookup>
  801557:	85 c0                	test   %eax,%eax
  801559:	78 6d                	js     8015c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	8b 00                	mov    (%eax),%eax
  801567:	89 04 24             	mov    %eax,(%esp)
  80156a:	e8 60 fd ff ff       	call   8012cf <dev_lookup>
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 55                	js     8015c8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	8b 50 08             	mov    0x8(%eax),%edx
  801579:	83 e2 03             	and    $0x3,%edx
  80157c:	83 fa 01             	cmp    $0x1,%edx
  80157f:	75 23                	jne    8015a4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801581:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801586:	8b 40 48             	mov    0x48(%eax),%eax
  801589:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80158d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801591:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  801598:	e8 ea ec ff ff       	call   800287 <cprintf>
		return -E_INVAL;
  80159d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a2:	eb 24                	jmp    8015c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8015a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a7:	8b 52 08             	mov    0x8(%edx),%edx
  8015aa:	85 d2                	test   %edx,%edx
  8015ac:	74 15                	je     8015c3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8015ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015bc:	89 04 24             	mov    %eax,(%esp)
  8015bf:	ff d2                	call   *%edx
  8015c1:	eb 05                	jmp    8015c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8015c8:	83 c4 24             	add    $0x24,%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 1c             	sub    $0x1c,%esp
  8015d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e2:	85 f6                	test   %esi,%esi
  8015e4:	74 30                	je     801616 <readn+0x48>
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015eb:	89 f2                	mov    %esi,%edx
  8015ed:	29 c2                	sub    %eax,%edx
  8015ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015f3:	03 45 0c             	add    0xc(%ebp),%eax
  8015f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fa:	89 3c 24             	mov    %edi,(%esp)
  8015fd:	e8 3c ff ff ff       	call   80153e <read>
		if (m < 0)
  801602:	85 c0                	test   %eax,%eax
  801604:	78 10                	js     801616 <readn+0x48>
			return m;
		if (m == 0)
  801606:	85 c0                	test   %eax,%eax
  801608:	74 0a                	je     801614 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160a:	01 c3                	add    %eax,%ebx
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	39 f3                	cmp    %esi,%ebx
  801610:	72 d9                	jb     8015eb <readn+0x1d>
  801612:	eb 02                	jmp    801616 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801614:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801616:	83 c4 1c             	add    $0x1c,%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5f                   	pop    %edi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	53                   	push   %ebx
  801622:	83 ec 24             	sub    $0x24,%esp
  801625:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801628:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162f:	89 1c 24             	mov    %ebx,(%esp)
  801632:	e8 47 fc ff ff       	call   80127e <fd_lookup>
  801637:	85 c0                	test   %eax,%eax
  801639:	78 68                	js     8016a3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801642:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801645:	8b 00                	mov    (%eax),%eax
  801647:	89 04 24             	mov    %eax,(%esp)
  80164a:	e8 80 fc ff ff       	call   8012cf <dev_lookup>
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 50                	js     8016a3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801653:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801656:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165a:	75 23                	jne    80167f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80165c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801661:	8b 40 48             	mov    0x48(%eax),%eax
  801664:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166c:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  801673:	e8 0f ec ff ff       	call   800287 <cprintf>
		return -E_INVAL;
  801678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167d:	eb 24                	jmp    8016a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80167f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801682:	8b 52 0c             	mov    0xc(%edx),%edx
  801685:	85 d2                	test   %edx,%edx
  801687:	74 15                	je     80169e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801689:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80168c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801690:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801693:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	ff d2                	call   *%edx
  80169c:	eb 05                	jmp    8016a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80169e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016a3:	83 c4 24             	add    $0x24,%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	89 04 24             	mov    %eax,(%esp)
  8016bc:	e8 bd fb ff ff       	call   80127e <fd_lookup>
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 0e                	js     8016d3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 24             	sub    $0x24,%esp
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e6:	89 1c 24             	mov    %ebx,(%esp)
  8016e9:	e8 90 fb ff ff       	call   80127e <fd_lookup>
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 61                	js     801753 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	8b 00                	mov    (%eax),%eax
  8016fe:	89 04 24             	mov    %eax,(%esp)
  801701:	e8 c9 fb ff ff       	call   8012cf <dev_lookup>
  801706:	85 c0                	test   %eax,%eax
  801708:	78 49                	js     801753 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801711:	75 23                	jne    801736 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801713:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801718:	8b 40 48             	mov    0x48(%eax),%eax
  80171b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	c7 04 24 2c 28 80 00 	movl   $0x80282c,(%esp)
  80172a:	e8 58 eb ff ff       	call   800287 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80172f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801734:	eb 1d                	jmp    801753 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801736:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801739:	8b 52 18             	mov    0x18(%edx),%edx
  80173c:	85 d2                	test   %edx,%edx
  80173e:	74 0e                	je     80174e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801743:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801747:	89 04 24             	mov    %eax,(%esp)
  80174a:	ff d2                	call   *%edx
  80174c:	eb 05                	jmp    801753 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80174e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801753:	83 c4 24             	add    $0x24,%esp
  801756:	5b                   	pop    %ebx
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	53                   	push   %ebx
  80175d:	83 ec 24             	sub    $0x24,%esp
  801760:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801763:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	89 04 24             	mov    %eax,(%esp)
  801770:	e8 09 fb ff ff       	call   80127e <fd_lookup>
  801775:	85 c0                	test   %eax,%eax
  801777:	78 52                	js     8017cb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801779:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801780:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801783:	8b 00                	mov    (%eax),%eax
  801785:	89 04 24             	mov    %eax,(%esp)
  801788:	e8 42 fb ff ff       	call   8012cf <dev_lookup>
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 3a                	js     8017cb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801794:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801798:	74 2c                	je     8017c6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80179a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80179d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a4:	00 00 00 
	stat->st_isdir = 0;
  8017a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ae:	00 00 00 
	stat->st_dev = dev;
  8017b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017be:	89 14 24             	mov    %edx,(%esp)
  8017c1:	ff 50 14             	call   *0x14(%eax)
  8017c4:	eb 05                	jmp    8017cb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017cb:	83 c4 24             	add    $0x24,%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	83 ec 18             	sub    $0x18,%esp
  8017d7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017da:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017e4:	00 
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	e8 bc 01 00 00       	call   8019ac <open>
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 1b                	js     801811 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8017f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	89 1c 24             	mov    %ebx,(%esp)
  801800:	e8 54 ff ff ff       	call   801759 <fstat>
  801805:	89 c6                	mov    %eax,%esi
	close(fd);
  801807:	89 1c 24             	mov    %ebx,(%esp)
  80180a:	e8 be fb ff ff       	call   8013cd <close>
	return r;
  80180f:	89 f3                	mov    %esi,%ebx
}
  801811:	89 d8                	mov    %ebx,%eax
  801813:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801816:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801819:	89 ec                	mov    %ebp,%esp
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    
  80181d:	00 00                	add    %al,(%eax)
	...

00801820 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 18             	sub    $0x18,%esp
  801826:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801829:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80182c:	89 c3                	mov    %eax,%ebx
  80182e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801830:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801837:	75 11                	jne    80184a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801839:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801840:	e8 5c 08 00 00       	call   8020a1 <ipc_find_env>
  801845:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80184a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801851:	00 
  801852:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  801859:	00 
  80185a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185e:	a1 00 40 80 00       	mov    0x804000,%eax
  801863:	89 04 24             	mov    %eax,(%esp)
  801866:	e8 cb 07 00 00       	call   802036 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80186b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801872:	00 
  801873:	89 74 24 04          	mov    %esi,0x4(%esp)
  801877:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187e:	e8 4d 07 00 00       	call   801fd0 <ipc_recv>
}
  801883:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801886:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801889:	89 ec                	mov    %ebp,%esp
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	53                   	push   %ebx
  801891:	83 ec 14             	sub    $0x14,%esp
  801894:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	8b 40 0c             	mov    0xc(%eax),%eax
  80189d:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ac:	e8 6f ff ff ff       	call   801820 <fsipc>
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 2b                	js     8018e0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018b5:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8018bc:	00 
  8018bd:	89 1c 24             	mov    %ebx,(%esp)
  8018c0:	e8 16 f1 ff ff       	call   8009db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018c5:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8018ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d0:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8018d5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e0:	83 c4 14             	add    $0x14,%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f2:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801901:	e8 1a ff ff ff       	call   801820 <fsipc>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	83 ec 10             	sub    $0x10,%esp
  801910:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	8b 40 0c             	mov    0xc(%eax),%eax
  801919:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80191e:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801924:	ba 00 00 00 00       	mov    $0x0,%edx
  801929:	b8 03 00 00 00       	mov    $0x3,%eax
  80192e:	e8 ed fe ff ff       	call   801820 <fsipc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	85 c0                	test   %eax,%eax
  801937:	78 6a                	js     8019a3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801939:	39 c6                	cmp    %eax,%esi
  80193b:	73 24                	jae    801961 <devfile_read+0x59>
  80193d:	c7 44 24 0c 9c 28 80 	movl   $0x80289c,0xc(%esp)
  801944:	00 
  801945:	c7 44 24 08 a3 28 80 	movl   $0x8028a3,0x8(%esp)
  80194c:	00 
  80194d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801954:	00 
  801955:	c7 04 24 b8 28 80 00 	movl   $0x8028b8,(%esp)
  80195c:	e8 2b e8 ff ff       	call   80018c <_panic>
	assert(r <= PGSIZE);
  801961:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801966:	7e 24                	jle    80198c <devfile_read+0x84>
  801968:	c7 44 24 0c c3 28 80 	movl   $0x8028c3,0xc(%esp)
  80196f:	00 
  801970:	c7 44 24 08 a3 28 80 	movl   $0x8028a3,0x8(%esp)
  801977:	00 
  801978:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80197f:	00 
  801980:	c7 04 24 b8 28 80 00 	movl   $0x8028b8,(%esp)
  801987:	e8 00 e8 ff ff       	call   80018c <_panic>
	memmove(buf, &fsipcbuf, r);
  80198c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801990:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801997:	00 
  801998:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199b:	89 04 24             	mov    %eax,(%esp)
  80199e:	e8 29 f2 ff ff       	call   800bcc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  8019a3:	89 d8                	mov    %ebx,%eax
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    

008019ac <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 20             	sub    $0x20,%esp
  8019b4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b7:	89 34 24             	mov    %esi,(%esp)
  8019ba:	e8 d1 ef ff ff       	call   800990 <strlen>
		return -E_BAD_PATH;
  8019bf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c9:	7f 5e                	jg     801a29 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	e8 35 f8 ff ff       	call   80120b <fd_alloc>
  8019d6:	89 c3                	mov    %eax,%ebx
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 4d                	js     801a29 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e0:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  8019e7:	e8 ef ef ff ff       	call   8009db <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fc:	e8 1f fe ff ff       	call   801820 <fsipc>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	79 15                	jns    801a1c <open+0x70>
		fd_close(fd, 0);
  801a07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a0e:	00 
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 21 f9 ff ff       	call   80133b <fd_close>
		return r;
  801a1a:	eb 0d                	jmp    801a29 <open+0x7d>
	}

	return fd2num(fd);
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 b9 f7 ff ff       	call   8011e0 <fd2num>
  801a27:	89 c3                	mov    %eax,%ebx
}
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	83 c4 20             	add    $0x20,%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    
	...

00801a40 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 18             	sub    $0x18,%esp
  801a46:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a49:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	e8 96 f7 ff ff       	call   8011f0 <fd2data>
  801a5a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a5c:	c7 44 24 04 cf 28 80 	movl   $0x8028cf,0x4(%esp)
  801a63:	00 
  801a64:	89 34 24             	mov    %esi,(%esp)
  801a67:	e8 6f ef ff ff       	call   8009db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a6c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a6f:	2b 03                	sub    (%ebx),%eax
  801a71:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a77:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a7e:	00 00 00 
	stat->st_dev = &devpipe;
  801a81:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801a88:	30 80 00 
	return 0;
}
  801a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a90:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a93:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a96:	89 ec                	mov    %ebp,%esp
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 14             	sub    $0x14,%esp
  801aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aaf:	e8 e5 f4 ff ff       	call   800f99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ab4:	89 1c 24             	mov    %ebx,(%esp)
  801ab7:	e8 34 f7 ff ff       	call   8011f0 <fd2data>
  801abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac7:	e8 cd f4 ff ff       	call   800f99 <sys_page_unmap>
}
  801acc:	83 c4 14             	add    $0x14,%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	57                   	push   %edi
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 2c             	sub    $0x2c,%esp
  801adb:	89 c7                	mov    %eax,%edi
  801add:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae0:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ae5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ae8:	89 3c 24             	mov    %edi,(%esp)
  801aeb:	e8 fc 05 00 00       	call   8020ec <pageref>
  801af0:	89 c6                	mov    %eax,%esi
  801af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af5:	89 04 24             	mov    %eax,(%esp)
  801af8:	e8 ef 05 00 00       	call   8020ec <pageref>
  801afd:	39 c6                	cmp    %eax,%esi
  801aff:	0f 94 c0             	sete   %al
  801b02:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b05:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801b0b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b0e:	39 cb                	cmp    %ecx,%ebx
  801b10:	75 08                	jne    801b1a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b12:	83 c4 2c             	add    $0x2c,%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5f                   	pop    %edi
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b1a:	83 f8 01             	cmp    $0x1,%eax
  801b1d:	75 c1                	jne    801ae0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b1f:	8b 52 58             	mov    0x58(%edx),%edx
  801b22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b26:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b2e:	c7 04 24 d6 28 80 00 	movl   $0x8028d6,(%esp)
  801b35:	e8 4d e7 ff ff       	call   800287 <cprintf>
  801b3a:	eb a4                	jmp    801ae0 <_pipeisclosed+0xe>

00801b3c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	83 ec 2c             	sub    $0x2c,%esp
  801b45:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b48:	89 34 24             	mov    %esi,(%esp)
  801b4b:	e8 a0 f6 ff ff       	call   8011f0 <fd2data>
  801b50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b52:	bf 00 00 00 00       	mov    $0x0,%edi
  801b57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b5b:	75 50                	jne    801bad <devpipe_write+0x71>
  801b5d:	eb 5c                	jmp    801bbb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b5f:	89 da                	mov    %ebx,%edx
  801b61:	89 f0                	mov    %esi,%eax
  801b63:	e8 6a ff ff ff       	call   801ad2 <_pipeisclosed>
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	75 53                	jne    801bbf <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b6c:	e8 3b f3 ff ff       	call   800eac <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b71:	8b 43 04             	mov    0x4(%ebx),%eax
  801b74:	8b 13                	mov    (%ebx),%edx
  801b76:	83 c2 20             	add    $0x20,%edx
  801b79:	39 d0                	cmp    %edx,%eax
  801b7b:	73 e2                	jae    801b5f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b80:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801b84:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801b87:	89 c2                	mov    %eax,%edx
  801b89:	c1 fa 1f             	sar    $0x1f,%edx
  801b8c:	c1 ea 1b             	shr    $0x1b,%edx
  801b8f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801b92:	83 e1 1f             	and    $0x1f,%ecx
  801b95:	29 d1                	sub    %edx,%ecx
  801b97:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801b9b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801b9f:	83 c0 01             	add    $0x1,%eax
  801ba2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba5:	83 c7 01             	add    $0x1,%edi
  801ba8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bab:	74 0e                	je     801bbb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bad:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb0:	8b 13                	mov    (%ebx),%edx
  801bb2:	83 c2 20             	add    $0x20,%edx
  801bb5:	39 d0                	cmp    %edx,%eax
  801bb7:	73 a6                	jae    801b5f <devpipe_write+0x23>
  801bb9:	eb c2                	jmp    801b7d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bbb:	89 f8                	mov    %edi,%eax
  801bbd:	eb 05                	jmp    801bc4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bbf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc4:	83 c4 2c             	add    $0x2c,%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5f                   	pop    %edi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 28             	sub    $0x28,%esp
  801bd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801bdb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bde:	89 3c 24             	mov    %edi,(%esp)
  801be1:	e8 0a f6 ff ff       	call   8011f0 <fd2data>
  801be6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be8:	be 00 00 00 00       	mov    $0x0,%esi
  801bed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bf1:	75 47                	jne    801c3a <devpipe_read+0x6e>
  801bf3:	eb 52                	jmp    801c47 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bf5:	89 f0                	mov    %esi,%eax
  801bf7:	eb 5e                	jmp    801c57 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf9:	89 da                	mov    %ebx,%edx
  801bfb:	89 f8                	mov    %edi,%eax
  801bfd:	8d 76 00             	lea    0x0(%esi),%esi
  801c00:	e8 cd fe ff ff       	call   801ad2 <_pipeisclosed>
  801c05:	85 c0                	test   %eax,%eax
  801c07:	75 49                	jne    801c52 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801c09:	e8 9e f2 ff ff       	call   800eac <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c0e:	8b 03                	mov    (%ebx),%eax
  801c10:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c13:	74 e4                	je     801bf9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c15:	89 c2                	mov    %eax,%edx
  801c17:	c1 fa 1f             	sar    $0x1f,%edx
  801c1a:	c1 ea 1b             	shr    $0x1b,%edx
  801c1d:	01 d0                	add    %edx,%eax
  801c1f:	83 e0 1f             	and    $0x1f,%eax
  801c22:	29 d0                	sub    %edx,%eax
  801c24:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c29:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c2f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c32:	83 c6 01             	add    $0x1,%esi
  801c35:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c38:	74 0d                	je     801c47 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801c3a:	8b 03                	mov    (%ebx),%eax
  801c3c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c3f:	75 d4                	jne    801c15 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c41:	85 f6                	test   %esi,%esi
  801c43:	75 b0                	jne    801bf5 <devpipe_read+0x29>
  801c45:	eb b2                	jmp    801bf9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c47:	89 f0                	mov    %esi,%eax
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	eb 05                	jmp    801c57 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c60:	89 ec                	mov    %ebp,%esp
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 48             	sub    $0x48,%esp
  801c6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c70:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c73:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c79:	89 04 24             	mov    %eax,(%esp)
  801c7c:	e8 8a f5 ff ff       	call   80120b <fd_alloc>
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	85 c0                	test   %eax,%eax
  801c85:	0f 88 45 01 00 00    	js     801dd0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c92:	00 
  801c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca1:	e8 36 f2 ff ff       	call   800edc <sys_page_alloc>
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	0f 88 20 01 00 00    	js     801dd0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cb0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801cb3:	89 04 24             	mov    %eax,(%esp)
  801cb6:	e8 50 f5 ff ff       	call   80120b <fd_alloc>
  801cbb:	89 c3                	mov    %eax,%ebx
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	0f 88 f8 00 00 00    	js     801dbd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ccc:	00 
  801ccd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdb:	e8 fc f1 ff ff       	call   800edc <sys_page_alloc>
  801ce0:	89 c3                	mov    %eax,%ebx
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	0f 88 d3 00 00 00    	js     801dbd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ced:	89 04 24             	mov    %eax,(%esp)
  801cf0:	e8 fb f4 ff ff       	call   8011f0 <fd2data>
  801cf5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cfe:	00 
  801cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0a:	e8 cd f1 ff ff       	call   800edc <sys_page_alloc>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	85 c0                	test   %eax,%eax
  801d13:	0f 88 91 00 00 00    	js     801daa <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d19:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d1c:	89 04 24             	mov    %eax,(%esp)
  801d1f:	e8 cc f4 ff ff       	call   8011f0 <fd2data>
  801d24:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d2b:	00 
  801d2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d37:	00 
  801d38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d43:	e8 f3 f1 ff ff       	call   800f3b <sys_page_map>
  801d48:	89 c3                	mov    %eax,%ebx
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 4c                	js     801d9a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d4e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d57:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d5c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d63:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d6c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d71:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d7b:	89 04 24             	mov    %eax,(%esp)
  801d7e:	e8 5d f4 ff ff       	call   8011e0 <fd2num>
  801d83:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d85:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d88:	89 04 24             	mov    %eax,(%esp)
  801d8b:	e8 50 f4 ff ff       	call   8011e0 <fd2num>
  801d90:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d98:	eb 36                	jmp    801dd0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801d9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da5:	e8 ef f1 ff ff       	call   800f99 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801daa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db8:	e8 dc f1 ff ff       	call   800f99 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801dbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dcb:	e8 c9 f1 ff ff       	call   800f99 <sys_page_unmap>
    err:
	return r;
}
  801dd0:	89 d8                	mov    %ebx,%eax
  801dd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801dd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801dd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ddb:	89 ec                	mov    %ebp,%esp
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	89 04 24             	mov    %eax,(%esp)
  801df2:	e8 87 f4 ff ff       	call   80127e <fd_lookup>
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 15                	js     801e10 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfe:	89 04 24             	mov    %eax,(%esp)
  801e01:	e8 ea f3 ff ff       	call   8011f0 <fd2data>
	return _pipeisclosed(fd, p);
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	e8 c2 fc ff ff       	call   801ad2 <_pipeisclosed>
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    
	...

00801e20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801e30:	c7 44 24 04 ee 28 80 	movl   $0x8028ee,0x4(%esp)
  801e37:	00 
  801e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3b:	89 04 24             	mov    %eax,(%esp)
  801e3e:	e8 98 eb ff ff       	call   8009db <strcpy>
	return 0;
}
  801e43:	b8 00 00 00 00       	mov    $0x0,%eax
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	57                   	push   %edi
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e56:	be 00 00 00 00       	mov    $0x0,%esi
  801e5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5f:	74 43                	je     801ea4 <devcons_write+0x5a>
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e66:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e6f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e71:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e74:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e79:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e7c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e80:	03 45 0c             	add    0xc(%ebp),%eax
  801e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e87:	89 3c 24             	mov    %edi,(%esp)
  801e8a:	e8 3d ed ff ff       	call   800bcc <memmove>
		sys_cputs(buf, m);
  801e8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e93:	89 3c 24             	mov    %edi,(%esp)
  801e96:	e8 25 ef ff ff       	call   800dc0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9b:	01 de                	add    %ebx,%esi
  801e9d:	89 f0                	mov    %esi,%eax
  801e9f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea2:	72 c8                	jb     801e6c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea4:	89 f0                	mov    %esi,%eax
  801ea6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801eac:	5b                   	pop    %ebx
  801ead:	5e                   	pop    %esi
  801eae:	5f                   	pop    %edi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ebc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ec0:	75 07                	jne    801ec9 <devcons_read+0x18>
  801ec2:	eb 31                	jmp    801ef5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec4:	e8 e3 ef ff ff       	call   800eac <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	e8 1a ef ff ff       	call   800def <sys_cgetc>
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	74 eb                	je     801ec4 <devcons_read+0x13>
  801ed9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 16                	js     801ef5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801edf:	83 f8 04             	cmp    $0x4,%eax
  801ee2:	74 0c                	je     801ef0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee7:	88 10                	mov    %dl,(%eax)
	return 1;
  801ee9:	b8 01 00 00 00       	mov    $0x1,%eax
  801eee:	eb 05                	jmp    801ef5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
  801f00:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f03:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f0a:	00 
  801f0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0e:	89 04 24             	mov    %eax,(%esp)
  801f11:	e8 aa ee ff ff       	call   800dc0 <sys_cputs>
}
  801f16:	c9                   	leave  
  801f17:	c3                   	ret    

00801f18 <getchar>:

int
getchar(void)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f1e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801f25:	00 
  801f26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f34:	e8 05 f6 ff ff       	call   80153e <read>
	if (r < 0)
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 0f                	js     801f4c <getchar+0x34>
		return r;
	if (r < 1)
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	7e 06                	jle    801f47 <getchar+0x2f>
		return -E_EOF;
	return c;
  801f41:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f45:	eb 05                	jmp    801f4c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f47:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    

00801f4e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	89 04 24             	mov    %eax,(%esp)
  801f61:	e8 18 f3 ff ff       	call   80127e <fd_lookup>
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 11                	js     801f7b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f73:	39 10                	cmp    %edx,(%eax)
  801f75:	0f 94 c0             	sete   %al
  801f78:	0f b6 c0             	movzbl %al,%eax
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <opencons>:

int
opencons(void)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 7d f2 ff ff       	call   80120b <fd_alloc>
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 3c                	js     801fce <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f99:	00 
  801f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa8:	e8 2f ef ff ff       	call   800edc <sys_page_alloc>
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 1d                	js     801fce <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fb1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fba:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc6:	89 04 24             	mov    %eax,(%esp)
  801fc9:	e8 12 f2 ff ff       	call   8011e0 <fd2num>
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	56                   	push   %esi
  801fd4:	53                   	push   %ebx
  801fd5:	83 ec 10             	sub    $0x10,%esp
  801fd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fde:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801fe1:	85 db                	test   %ebx,%ebx
  801fe3:	74 06                	je     801feb <ipc_recv+0x1b>
  801fe5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801feb:	85 f6                	test   %esi,%esi
  801fed:	74 06                	je     801ff5 <ipc_recv+0x25>
  801fef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ffc:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801fff:	89 04 24             	mov    %eax,(%esp)
  802002:	e8 3e f1 ff ff       	call   801145 <sys_ipc_recv>
    if (ret) return ret;
  802007:	85 c0                	test   %eax,%eax
  802009:	75 24                	jne    80202f <ipc_recv+0x5f>
    if (from_env_store)
  80200b:	85 db                	test   %ebx,%ebx
  80200d:	74 0a                	je     802019 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80200f:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802014:	8b 40 74             	mov    0x74(%eax),%eax
  802017:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802019:	85 f6                	test   %esi,%esi
  80201b:	74 0a                	je     802027 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80201d:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802022:	8b 40 78             	mov    0x78(%eax),%eax
  802025:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802027:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80202c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	57                   	push   %edi
  80203a:	56                   	push   %esi
  80203b:	53                   	push   %ebx
  80203c:	83 ec 1c             	sub    $0x1c,%esp
  80203f:	8b 75 08             	mov    0x8(%ebp),%esi
  802042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802048:	85 db                	test   %ebx,%ebx
  80204a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80204f:	0f 44 d8             	cmove  %eax,%ebx
  802052:	eb 2a                	jmp    80207e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802054:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802057:	74 20                	je     802079 <ipc_send+0x43>
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	c7 44 24 08 fa 28 80 	movl   $0x8028fa,0x8(%esp)
  802064:	00 
  802065:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80206c:	00 
  80206d:	c7 04 24 11 29 80 00 	movl   $0x802911,(%esp)
  802074:	e8 13 e1 ff ff       	call   80018c <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802079:	e8 2e ee ff ff       	call   800eac <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80207e:	8b 45 14             	mov    0x14(%ebp),%eax
  802081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802085:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802089:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80208d:	89 34 24             	mov    %esi,(%esp)
  802090:	e8 7c f0 ff ff       	call   801111 <sys_ipc_try_send>
  802095:	85 c0                	test   %eax,%eax
  802097:	75 bb                	jne    802054 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802099:	83 c4 1c             	add    $0x1c,%esp
  80209c:	5b                   	pop    %ebx
  80209d:	5e                   	pop    %esi
  80209e:	5f                   	pop    %edi
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    

008020a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8020a7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8020ac:	39 c8                	cmp    %ecx,%eax
  8020ae:	74 19                	je     8020c9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020b0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8020b5:	89 c2                	mov    %eax,%edx
  8020b7:	c1 e2 07             	shl    $0x7,%edx
  8020ba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020c0:	8b 52 50             	mov    0x50(%edx),%edx
  8020c3:	39 ca                	cmp    %ecx,%edx
  8020c5:	75 14                	jne    8020db <ipc_find_env+0x3a>
  8020c7:	eb 05                	jmp    8020ce <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020ce:	c1 e0 07             	shl    $0x7,%eax
  8020d1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8020d6:	8b 40 40             	mov    0x40(%eax),%eax
  8020d9:	eb 0e                	jmp    8020e9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020db:	83 c0 01             	add    $0x1,%eax
  8020de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020e3:	75 d0                	jne    8020b5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020e5:	66 b8 00 00          	mov    $0x0,%ax
}
  8020e9:	5d                   	pop    %ebp
  8020ea:	c3                   	ret    
	...

008020ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f2:	89 d0                	mov    %edx,%eax
  8020f4:	c1 e8 16             	shr    $0x16,%eax
  8020f7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020fe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802103:	f6 c1 01             	test   $0x1,%cl
  802106:	74 1d                	je     802125 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802108:	c1 ea 0c             	shr    $0xc,%edx
  80210b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802112:	f6 c2 01             	test   $0x1,%dl
  802115:	74 0e                	je     802125 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802117:	c1 ea 0c             	shr    $0xc,%edx
  80211a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802121:	ef 
  802122:	0f b7 c0             	movzwl %ax,%eax
}
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    
	...

00802130 <__udivdi3>:
  802130:	83 ec 1c             	sub    $0x1c,%esp
  802133:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802137:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80213b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80213f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802143:	89 74 24 10          	mov    %esi,0x10(%esp)
  802147:	8b 74 24 24          	mov    0x24(%esp),%esi
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802151:	89 44 24 08          	mov    %eax,0x8(%esp)
  802155:	89 cd                	mov    %ecx,%ebp
  802157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215b:	75 33                	jne    802190 <__udivdi3+0x60>
  80215d:	39 f1                	cmp    %esi,%ecx
  80215f:	77 57                	ja     8021b8 <__udivdi3+0x88>
  802161:	85 c9                	test   %ecx,%ecx
  802163:	75 0b                	jne    802170 <__udivdi3+0x40>
  802165:	b8 01 00 00 00       	mov    $0x1,%eax
  80216a:	31 d2                	xor    %edx,%edx
  80216c:	f7 f1                	div    %ecx
  80216e:	89 c1                	mov    %eax,%ecx
  802170:	89 f0                	mov    %esi,%eax
  802172:	31 d2                	xor    %edx,%edx
  802174:	f7 f1                	div    %ecx
  802176:	89 c6                	mov    %eax,%esi
  802178:	8b 44 24 04          	mov    0x4(%esp),%eax
  80217c:	f7 f1                	div    %ecx
  80217e:	89 f2                	mov    %esi,%edx
  802180:	8b 74 24 10          	mov    0x10(%esp),%esi
  802184:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802188:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	c3                   	ret    
  802190:	31 d2                	xor    %edx,%edx
  802192:	31 c0                	xor    %eax,%eax
  802194:	39 f7                	cmp    %esi,%edi
  802196:	77 e8                	ja     802180 <__udivdi3+0x50>
  802198:	0f bd cf             	bsr    %edi,%ecx
  80219b:	83 f1 1f             	xor    $0x1f,%ecx
  80219e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021a2:	75 2c                	jne    8021d0 <__udivdi3+0xa0>
  8021a4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8021a8:	76 04                	jbe    8021ae <__udivdi3+0x7e>
  8021aa:	39 f7                	cmp    %esi,%edi
  8021ac:	73 d2                	jae    802180 <__udivdi3+0x50>
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b5:	eb c9                	jmp    802180 <__udivdi3+0x50>
  8021b7:	90                   	nop
  8021b8:	89 f2                	mov    %esi,%edx
  8021ba:	f7 f1                	div    %ecx
  8021bc:	31 d2                	xor    %edx,%edx
  8021be:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021c2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021c6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	c3                   	ret    
  8021ce:	66 90                	xchg   %ax,%ax
  8021d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021d5:	b8 20 00 00 00       	mov    $0x20,%eax
  8021da:	89 ea                	mov    %ebp,%edx
  8021dc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e0:	d3 e7                	shl    %cl,%edi
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	d3 ea                	shr    %cl,%edx
  8021e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021eb:	09 fa                	or     %edi,%edx
  8021ed:	89 f7                	mov    %esi,%edi
  8021ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021f9:	d3 e5                	shl    %cl,%ebp
  8021fb:	89 c1                	mov    %eax,%ecx
  8021fd:	d3 ef                	shr    %cl,%edi
  8021ff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802204:	d3 e2                	shl    %cl,%edx
  802206:	89 c1                	mov    %eax,%ecx
  802208:	d3 ee                	shr    %cl,%esi
  80220a:	09 d6                	or     %edx,%esi
  80220c:	89 fa                	mov    %edi,%edx
  80220e:	89 f0                	mov    %esi,%eax
  802210:	f7 74 24 0c          	divl   0xc(%esp)
  802214:	89 d7                	mov    %edx,%edi
  802216:	89 c6                	mov    %eax,%esi
  802218:	f7 e5                	mul    %ebp
  80221a:	39 d7                	cmp    %edx,%edi
  80221c:	72 22                	jb     802240 <__udivdi3+0x110>
  80221e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802222:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802227:	d3 e5                	shl    %cl,%ebp
  802229:	39 c5                	cmp    %eax,%ebp
  80222b:	73 04                	jae    802231 <__udivdi3+0x101>
  80222d:	39 d7                	cmp    %edx,%edi
  80222f:	74 0f                	je     802240 <__udivdi3+0x110>
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	e9 46 ff ff ff       	jmp    802180 <__udivdi3+0x50>
  80223a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802240:	8d 46 ff             	lea    -0x1(%esi),%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	8b 74 24 10          	mov    0x10(%esp),%esi
  802249:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80224d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	c3                   	ret    
	...

00802260 <__umoddi3>:
  802260:	83 ec 1c             	sub    $0x1c,%esp
  802263:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802267:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80226b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80226f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802273:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802277:	8b 74 24 24          	mov    0x24(%esp),%esi
  80227b:	85 ed                	test   %ebp,%ebp
  80227d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802281:	89 44 24 08          	mov    %eax,0x8(%esp)
  802285:	89 cf                	mov    %ecx,%edi
  802287:	89 04 24             	mov    %eax,(%esp)
  80228a:	89 f2                	mov    %esi,%edx
  80228c:	75 1a                	jne    8022a8 <__umoddi3+0x48>
  80228e:	39 f1                	cmp    %esi,%ecx
  802290:	76 4e                	jbe    8022e0 <__umoddi3+0x80>
  802292:	f7 f1                	div    %ecx
  802294:	89 d0                	mov    %edx,%eax
  802296:	31 d2                	xor    %edx,%edx
  802298:	8b 74 24 10          	mov    0x10(%esp),%esi
  80229c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	c3                   	ret    
  8022a8:	39 f5                	cmp    %esi,%ebp
  8022aa:	77 54                	ja     802300 <__umoddi3+0xa0>
  8022ac:	0f bd c5             	bsr    %ebp,%eax
  8022af:	83 f0 1f             	xor    $0x1f,%eax
  8022b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b6:	75 60                	jne    802318 <__umoddi3+0xb8>
  8022b8:	3b 0c 24             	cmp    (%esp),%ecx
  8022bb:	0f 87 07 01 00 00    	ja     8023c8 <__umoddi3+0x168>
  8022c1:	89 f2                	mov    %esi,%edx
  8022c3:	8b 34 24             	mov    (%esp),%esi
  8022c6:	29 ce                	sub    %ecx,%esi
  8022c8:	19 ea                	sbb    %ebp,%edx
  8022ca:	89 34 24             	mov    %esi,(%esp)
  8022cd:	8b 04 24             	mov    (%esp),%eax
  8022d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	c3                   	ret    
  8022e0:	85 c9                	test   %ecx,%ecx
  8022e2:	75 0b                	jne    8022ef <__umoddi3+0x8f>
  8022e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e9:	31 d2                	xor    %edx,%edx
  8022eb:	f7 f1                	div    %ecx
  8022ed:	89 c1                	mov    %eax,%ecx
  8022ef:	89 f0                	mov    %esi,%eax
  8022f1:	31 d2                	xor    %edx,%edx
  8022f3:	f7 f1                	div    %ecx
  8022f5:	8b 04 24             	mov    (%esp),%eax
  8022f8:	f7 f1                	div    %ecx
  8022fa:	eb 98                	jmp    802294 <__umoddi3+0x34>
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 f2                	mov    %esi,%edx
  802302:	8b 74 24 10          	mov    0x10(%esp),%esi
  802306:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80230a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80230e:	83 c4 1c             	add    $0x1c,%esp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80231d:	89 e8                	mov    %ebp,%eax
  80231f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802324:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802328:	89 fa                	mov    %edi,%edx
  80232a:	d3 e0                	shl    %cl,%eax
  80232c:	89 e9                	mov    %ebp,%ecx
  80232e:	d3 ea                	shr    %cl,%edx
  802330:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802335:	09 c2                	or     %eax,%edx
  802337:	8b 44 24 08          	mov    0x8(%esp),%eax
  80233b:	89 14 24             	mov    %edx,(%esp)
  80233e:	89 f2                	mov    %esi,%edx
  802340:	d3 e7                	shl    %cl,%edi
  802342:	89 e9                	mov    %ebp,%ecx
  802344:	d3 ea                	shr    %cl,%edx
  802346:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80234b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80234f:	d3 e6                	shl    %cl,%esi
  802351:	89 e9                	mov    %ebp,%ecx
  802353:	d3 e8                	shr    %cl,%eax
  802355:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80235a:	09 f0                	or     %esi,%eax
  80235c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802360:	f7 34 24             	divl   (%esp)
  802363:	d3 e6                	shl    %cl,%esi
  802365:	89 74 24 08          	mov    %esi,0x8(%esp)
  802369:	89 d6                	mov    %edx,%esi
  80236b:	f7 e7                	mul    %edi
  80236d:	39 d6                	cmp    %edx,%esi
  80236f:	89 c1                	mov    %eax,%ecx
  802371:	89 d7                	mov    %edx,%edi
  802373:	72 3f                	jb     8023b4 <__umoddi3+0x154>
  802375:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802379:	72 35                	jb     8023b0 <__umoddi3+0x150>
  80237b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237f:	29 c8                	sub    %ecx,%eax
  802381:	19 fe                	sbb    %edi,%esi
  802383:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802388:	89 f2                	mov    %esi,%edx
  80238a:	d3 e8                	shr    %cl,%eax
  80238c:	89 e9                	mov    %ebp,%ecx
  80238e:	d3 e2                	shl    %cl,%edx
  802390:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802395:	09 d0                	or     %edx,%eax
  802397:	89 f2                	mov    %esi,%edx
  802399:	d3 ea                	shr    %cl,%edx
  80239b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80239f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8023a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8023a7:	83 c4 1c             	add    $0x1c,%esp
  8023aa:	c3                   	ret    
  8023ab:	90                   	nop
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	39 d6                	cmp    %edx,%esi
  8023b2:	75 c7                	jne    80237b <__umoddi3+0x11b>
  8023b4:	89 d7                	mov    %edx,%edi
  8023b6:	89 c1                	mov    %eax,%ecx
  8023b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8023bc:	1b 3c 24             	sbb    (%esp),%edi
  8023bf:	eb ba                	jmp    80237b <__umoddi3+0x11b>
  8023c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	39 f5                	cmp    %esi,%ebp
  8023ca:	0f 82 f1 fe ff ff    	jb     8022c1 <__umoddi3+0x61>
  8023d0:	e9 f8 fe ff ff       	jmp    8022cd <__umoddi3+0x6d>
