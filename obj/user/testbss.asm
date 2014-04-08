
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
  80003a:	c7 04 24 48 11 80 00 	movl   $0x801148,(%esp)
  800041:	e8 3d 02 00 00       	call   800283 <cprintf>
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
  800069:	c7 44 24 08 c3 11 80 	movl   $0x8011c3,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  800080:	e8 03 01 00 00       	call   800188 <_panic>
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
  8000c7:	c7 44 24 08 68 11 80 	movl   $0x801168,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  8000de:	e8 a5 00 00 00       	call   800188 <_panic>
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
  8000ed:	c7 04 24 90 11 80 00 	movl   $0x801190,(%esp)
  8000f4:	e8 8a 01 00 00       	call   800283 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 ef 11 80 	movl   $0x8011ef,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  80011a:	e8 69 00 00 00       	call   800188 <_panic>
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
  80013c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80013f:	c1 e0 05             	shl    $0x5,%eax
  800142:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800147:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014c:	85 f6                	test   %esi,%esi
  80014e:	7e 07                	jle    800157 <libmain+0x37>
		binaryname = argv[0];
  800150:	8b 03                	mov    (%ebx),%eax
  800152:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800157:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80015b:	89 34 24             	mov    %esi,(%esp)
  80015e:	e8 d1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800163:	e8 0c 00 00 00       	call   800174 <exit>
}
  800168:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80016b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016e:	89 ec                	mov    %ebp,%esp
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    
	...

00800174 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80017a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800181:	e8 89 0c 00 00       	call   800e0f <sys_env_destroy>
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800190:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800193:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800199:	e8 ce 0c 00 00       	call   800e6c <sys_getenvid>
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 10 12 80 00 	movl   $0x801210,(%esp)
  8001bb:	e8 c3 00 00 00       	call   800283 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 53 00 00 00       	call   800222 <vcprintf>
	cprintf("\n");
  8001cf:	c7 04 24 de 11 80 00 	movl   $0x8011de,(%esp)
  8001d6:	e8 a8 00 00 00       	call   800283 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001db:	cc                   	int3   
  8001dc:	eb fd                	jmp    8001db <_panic+0x53>
	...

008001e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 14             	sub    $0x14,%esp
  8001e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ea:	8b 03                	mov    (%ebx),%eax
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f3:	83 c0 01             	add    $0x1,%eax
  8001f6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fd:	75 19                	jne    800218 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ff:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800206:	00 
  800207:	8d 43 08             	lea    0x8(%ebx),%eax
  80020a:	89 04 24             	mov    %eax,(%esp)
  80020d:	e8 9e 0b 00 00       	call   800db0 <sys_cputs>
		b->idx = 0;
  800212:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800218:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021c:	83 c4 14             	add    $0x14,%esp
  80021f:	5b                   	pop    %ebx
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800232:	00 00 00 
	b.cnt = 0;
  800235:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800242:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	c7 04 24 e0 01 80 00 	movl   $0x8001e0,(%esp)
  80025e:	e8 97 01 00 00       	call   8003fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800263:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	e8 35 0b 00 00       	call   800db0 <sys_cputs>

	return b.cnt;
}
  80027b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800289:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	e8 87 ff ff ff       	call   800222 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 3c             	sub    $0x3c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d7                	mov    %edx,%edi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002c8:	72 11                	jb     8002db <printnum+0x3b>
  8002ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d0:	76 09                	jbe    8002db <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d2:	83 eb 01             	sub    $0x1,%ebx
  8002d5:	85 db                	test   %ebx,%ebx
  8002d7:	7f 51                	jg     80032a <printnum+0x8a>
  8002d9:	eb 5e                	jmp    800339 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002db:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002df:	83 eb 01             	sub    $0x1,%ebx
  8002e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ed:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002f1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fc:	00 
  8002fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030a:	e8 91 0b 00 00       	call   800ea0 <__udivdi3>
  80030f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800313:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031e:	89 fa                	mov    %edi,%edx
  800320:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800323:	e8 78 ff ff ff       	call   8002a0 <printnum>
  800328:	eb 0f                	jmp    800339 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032e:	89 34 24             	mov    %esi,(%esp)
  800331:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800334:	83 eb 01             	sub    $0x1,%ebx
  800337:	75 f1                	jne    80032a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800339:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034f:	00 
  800350:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	e8 6e 0c 00 00       	call   800fd0 <__umoddi3>
  800362:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800366:	0f be 80 34 12 80 00 	movsbl 0x801234(%eax),%eax
  80036d:	89 04 24             	mov    %eax,(%esp)
  800370:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800373:	83 c4 3c             	add    $0x3c,%esp
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037e:	83 fa 01             	cmp    $0x1,%edx
  800381:	7e 0e                	jle    800391 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800383:	8b 10                	mov    (%eax),%edx
  800385:	8d 4a 08             	lea    0x8(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 02                	mov    (%edx),%eax
  80038c:	8b 52 04             	mov    0x4(%edx),%edx
  80038f:	eb 22                	jmp    8003b3 <getuint+0x38>
	else if (lflag)
  800391:	85 d2                	test   %edx,%edx
  800393:	74 10                	je     8003a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800395:	8b 10                	mov    (%eax),%edx
  800397:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039a:	89 08                	mov    %ecx,(%eax)
  80039c:	8b 02                	mov    (%edx),%eax
  80039e:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a3:	eb 0e                	jmp    8003b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a5:	8b 10                	mov    (%eax),%edx
  8003a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003aa:	89 08                	mov    %ecx,(%eax)
  8003ac:	8b 02                	mov    (%edx),%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c4:	73 0a                	jae    8003d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c9:	88 0a                	mov    %cl,(%edx)
  8003cb:	83 c2 01             	add    $0x1,%edx
  8003ce:	89 10                	mov    %edx,(%eax)
}
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003df:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	e8 02 00 00 00       	call   8003fa <vprintfmt>
	va_end(ap);
}
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	57                   	push   %edi
  8003fe:	56                   	push   %esi
  8003ff:	53                   	push   %ebx
  800400:	83 ec 5c             	sub    $0x5c,%esp
  800403:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800406:	8b 75 10             	mov    0x10(%ebp),%esi
  800409:	eb 12                	jmp    80041d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80040b:	85 c0                	test   %eax,%eax
  80040d:	0f 84 e4 04 00 00    	je     8008f7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800413:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041d:	0f b6 06             	movzbl (%esi),%eax
  800420:	83 c6 01             	add    $0x1,%esi
  800423:	83 f8 25             	cmp    $0x25,%eax
  800426:	75 e3                	jne    80040b <vprintfmt+0x11>
  800428:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80042c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800433:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800438:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80043f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800444:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800447:	eb 2b                	jmp    800474 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800450:	eb 22                	jmp    800474 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800455:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800459:	eb 19                	jmp    800474 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80045e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800465:	eb 0d                	jmp    800474 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800467:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80046a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	0f b6 06             	movzbl (%esi),%eax
  800477:	0f b6 d0             	movzbl %al,%edx
  80047a:	8d 7e 01             	lea    0x1(%esi),%edi
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	83 e8 23             	sub    $0x23,%eax
  800483:	3c 55                	cmp    $0x55,%al
  800485:	0f 87 46 04 00 00    	ja     8008d1 <vprintfmt+0x4d7>
  80048b:	0f b6 c0             	movzbl %al,%eax
  80048e:	ff 24 85 dc 12 80 00 	jmp    *0x8012dc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800495:	83 ea 30             	sub    $0x30,%edx
  800498:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80049b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80049f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004a5:	83 fa 09             	cmp    $0x9,%edx
  8004a8:	77 4a                	ja     8004f4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ad:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004b0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004b3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004b7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ba:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004bd:	83 fa 09             	cmp    $0x9,%edx
  8004c0:	76 eb                	jbe    8004ad <vprintfmt+0xb3>
  8004c2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004c5:	eb 2d                	jmp    8004f4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d8:	eb 1a                	jmp    8004f4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004dd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e1:	79 91                	jns    800474 <vprintfmt+0x7a>
  8004e3:	e9 73 ff ff ff       	jmp    80045b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004eb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004f2:	eb 80                	jmp    800474 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004f4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004f8:	0f 89 76 ff ff ff    	jns    800474 <vprintfmt+0x7a>
  8004fe:	e9 64 ff ff ff       	jmp    800467 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800503:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800509:	e9 66 ff ff ff       	jmp    800474 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 04 24             	mov    %eax,(%esp)
  800520:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800526:	e9 f2 fe ff ff       	jmp    80041d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80052b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80052f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800532:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800536:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800539:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80053d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800540:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800543:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800547:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80054a:	80 f9 09             	cmp    $0x9,%cl
  80054d:	77 1d                	ja     80056c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80054f:	0f be c0             	movsbl %al,%eax
  800552:	6b c0 64             	imul   $0x64,%eax,%eax
  800555:	0f be d2             	movsbl %dl,%edx
  800558:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80055b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800562:	a3 04 20 80 00       	mov    %eax,0x802004
  800567:	e9 b1 fe ff ff       	jmp    80041d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80056c:	c7 44 24 04 4c 12 80 	movl   $0x80124c,0x4(%esp)
  800573:	00 
  800574:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800577:	89 04 24             	mov    %eax,(%esp)
  80057a:	e8 0c 05 00 00       	call   800a8b <strcmp>
  80057f:	85 c0                	test   %eax,%eax
  800581:	75 0f                	jne    800592 <vprintfmt+0x198>
  800583:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80058a:	00 00 00 
  80058d:	e9 8b fe ff ff       	jmp    80041d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800592:	c7 44 24 04 50 12 80 	movl   $0x801250,0x4(%esp)
  800599:	00 
  80059a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80059d:	89 14 24             	mov    %edx,(%esp)
  8005a0:	e8 e6 04 00 00       	call   800a8b <strcmp>
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	75 0f                	jne    8005b8 <vprintfmt+0x1be>
  8005a9:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005b0:	00 00 00 
  8005b3:	e9 65 fe ff ff       	jmp    80041d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005b8:	c7 44 24 04 54 12 80 	movl   $0x801254,0x4(%esp)
  8005bf:	00 
  8005c0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005c3:	89 0c 24             	mov    %ecx,(%esp)
  8005c6:	e8 c0 04 00 00       	call   800a8b <strcmp>
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 0f                	jne    8005de <vprintfmt+0x1e4>
  8005cf:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005d6:	00 00 00 
  8005d9:	e9 3f fe ff ff       	jmp    80041d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005de:	c7 44 24 04 58 12 80 	movl   $0x801258,0x4(%esp)
  8005e5:	00 
  8005e6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005e9:	89 3c 24             	mov    %edi,(%esp)
  8005ec:	e8 9a 04 00 00       	call   800a8b <strcmp>
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	75 0f                	jne    800604 <vprintfmt+0x20a>
  8005f5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005fc:	00 00 00 
  8005ff:	e9 19 fe ff ff       	jmp    80041d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800604:	c7 44 24 04 5c 12 80 	movl   $0x80125c,0x4(%esp)
  80060b:	00 
  80060c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 74 04 00 00       	call   800a8b <strcmp>
  800617:	85 c0                	test   %eax,%eax
  800619:	75 0f                	jne    80062a <vprintfmt+0x230>
  80061b:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800622:	00 00 00 
  800625:	e9 f3 fd ff ff       	jmp    80041d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80062a:	c7 44 24 04 60 12 80 	movl   $0x801260,0x4(%esp)
  800631:	00 
  800632:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800635:	89 14 24             	mov    %edx,(%esp)
  800638:	e8 4e 04 00 00       	call   800a8b <strcmp>
  80063d:	83 f8 01             	cmp    $0x1,%eax
  800640:	19 c0                	sbb    %eax,%eax
  800642:	f7 d0                	not    %eax
  800644:	83 c0 08             	add    $0x8,%eax
  800647:	a3 04 20 80 00       	mov    %eax,0x802004
  80064c:	e9 cc fd ff ff       	jmp    80041d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	89 c2                	mov    %eax,%edx
  80065e:	c1 fa 1f             	sar    $0x1f,%edx
  800661:	31 d0                	xor    %edx,%eax
  800663:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800665:	83 f8 06             	cmp    $0x6,%eax
  800668:	7f 0b                	jg     800675 <vprintfmt+0x27b>
  80066a:	8b 14 85 34 14 80 00 	mov    0x801434(,%eax,4),%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	75 23                	jne    800698 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800675:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800679:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800680:	00 
  800681:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800685:	8b 7d 08             	mov    0x8(%ebp),%edi
  800688:	89 3c 24             	mov    %edi,(%esp)
  80068b:	e8 42 fd ff ff       	call   8003d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800693:	e9 85 fd ff ff       	jmp    80041d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800698:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069c:	c7 44 24 08 6d 12 80 	movl   $0x80126d,0x8(%esp)
  8006a3:	00 
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ab:	89 3c 24             	mov    %edi,(%esp)
  8006ae:	e8 1f fd ff ff       	call   8003d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006b6:	e9 62 fd ff ff       	jmp    80041d <vprintfmt+0x23>
  8006bb:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006c1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006cf:	85 f6                	test   %esi,%esi
  8006d1:	b8 45 12 80 00       	mov    $0x801245,%eax
  8006d6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006d9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006dd:	7e 06                	jle    8006e5 <vprintfmt+0x2eb>
  8006df:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006e3:	75 13                	jne    8006f8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e5:	0f be 06             	movsbl (%esi),%eax
  8006e8:	83 c6 01             	add    $0x1,%esi
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	0f 85 94 00 00 00    	jne    800787 <vprintfmt+0x38d>
  8006f3:	e9 81 00 00 00       	jmp    800779 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fc:	89 34 24             	mov    %esi,(%esp)
  8006ff:	e8 97 02 00 00       	call   80099b <strnlen>
  800704:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800707:	29 c2                	sub    %eax,%edx
  800709:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80070c:	85 d2                	test   %edx,%edx
  80070e:	7e d5                	jle    8006e5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800710:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800714:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800717:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80071a:	89 d6                	mov    %edx,%esi
  80071c:	89 cf                	mov    %ecx,%edi
  80071e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800722:	89 3c 24             	mov    %edi,(%esp)
  800725:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800728:	83 ee 01             	sub    $0x1,%esi
  80072b:	75 f1                	jne    80071e <vprintfmt+0x324>
  80072d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800730:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800733:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800736:	eb ad                	jmp    8006e5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800738:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80073c:	74 1b                	je     800759 <vprintfmt+0x35f>
  80073e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800741:	83 fa 5e             	cmp    $0x5e,%edx
  800744:	76 13                	jbe    800759 <vprintfmt+0x35f>
					putch('?', putdat);
  800746:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800754:	ff 55 08             	call   *0x8(%ebp)
  800757:	eb 0d                	jmp    800766 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800759:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80075c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800766:	83 eb 01             	sub    $0x1,%ebx
  800769:	0f be 06             	movsbl (%esi),%eax
  80076c:	83 c6 01             	add    $0x1,%esi
  80076f:	85 c0                	test   %eax,%eax
  800771:	75 1a                	jne    80078d <vprintfmt+0x393>
  800773:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800776:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800780:	7f 1c                	jg     80079e <vprintfmt+0x3a4>
  800782:	e9 96 fc ff ff       	jmp    80041d <vprintfmt+0x23>
  800787:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80078a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078d:	85 ff                	test   %edi,%edi
  80078f:	78 a7                	js     800738 <vprintfmt+0x33e>
  800791:	83 ef 01             	sub    $0x1,%edi
  800794:	79 a2                	jns    800738 <vprintfmt+0x33e>
  800796:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800799:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80079c:	eb db                	jmp    800779 <vprintfmt+0x37f>
  80079e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a1:	89 de                	mov    %ebx,%esi
  8007a3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007aa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b3:	83 eb 01             	sub    $0x1,%ebx
  8007b6:	75 ee                	jne    8007a6 <vprintfmt+0x3ac>
  8007b8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007bd:	e9 5b fc ff ff       	jmp    80041d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c2:	83 f9 01             	cmp    $0x1,%ecx
  8007c5:	7e 10                	jle    8007d7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 08             	lea    0x8(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 30                	mov    (%eax),%esi
  8007d2:	8b 78 04             	mov    0x4(%eax),%edi
  8007d5:	eb 26                	jmp    8007fd <vprintfmt+0x403>
	else if (lflag)
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	74 12                	je     8007ed <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 50 04             	lea    0x4(%eax),%edx
  8007e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e4:	8b 30                	mov    (%eax),%esi
  8007e6:	89 f7                	mov    %esi,%edi
  8007e8:	c1 ff 1f             	sar    $0x1f,%edi
  8007eb:	eb 10                	jmp    8007fd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f6:	8b 30                	mov    (%eax),%esi
  8007f8:	89 f7                	mov    %esi,%edi
  8007fa:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fd:	85 ff                	test   %edi,%edi
  8007ff:	78 0e                	js     80080f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800801:	89 f0                	mov    %esi,%eax
  800803:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800805:	be 0a 00 00 00       	mov    $0xa,%esi
  80080a:	e9 84 00 00 00       	jmp    800893 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80080f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800813:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80081a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80081d:	89 f0                	mov    %esi,%eax
  80081f:	89 fa                	mov    %edi,%edx
  800821:	f7 d8                	neg    %eax
  800823:	83 d2 00             	adc    $0x0,%edx
  800826:	f7 da                	neg    %edx
			}
			base = 10;
  800828:	be 0a 00 00 00       	mov    $0xa,%esi
  80082d:	eb 64                	jmp    800893 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082f:	89 ca                	mov    %ecx,%edx
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
  800834:	e8 42 fb ff ff       	call   80037b <getuint>
			base = 10;
  800839:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80083e:	eb 53                	jmp    800893 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800840:	89 ca                	mov    %ecx,%edx
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 31 fb ff ff       	call   80037b <getuint>
    			base = 8;
  80084a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80084f:	eb 42                	jmp    800893 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800851:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800855:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80085c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80085f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800863:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80086a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8d 50 04             	lea    0x4(%eax),%edx
  800873:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800876:	8b 00                	mov    (%eax),%eax
  800878:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800882:	eb 0f                	jmp    800893 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800884:	89 ca                	mov    %ecx,%edx
  800886:	8d 45 14             	lea    0x14(%ebp),%eax
  800889:	e8 ed fa ff ff       	call   80037b <getuint>
			base = 16;
  80088e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800893:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800897:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80089b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80089e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008a2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ad:	89 da                	mov    %ebx,%edx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	e8 e9 f9 ff ff       	call   8002a0 <printnum>
			break;
  8008b7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008ba:	e9 5e fb ff ff       	jmp    80041d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c3:	89 14 24             	mov    %edx,(%esp)
  8008c6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008cc:	e9 4c fb ff ff       	jmp    80041d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008dc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008df:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008e3:	0f 84 34 fb ff ff    	je     80041d <vprintfmt+0x23>
  8008e9:	83 ee 01             	sub    $0x1,%esi
  8008ec:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f0:	75 f7                	jne    8008e9 <vprintfmt+0x4ef>
  8008f2:	e9 26 fb ff ff       	jmp    80041d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008f7:	83 c4 5c             	add    $0x5c,%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	83 ec 28             	sub    $0x28,%esp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800912:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800915:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091c:	85 c0                	test   %eax,%eax
  80091e:	74 30                	je     800950 <vsnprintf+0x51>
  800920:	85 d2                	test   %edx,%edx
  800922:	7e 2c                	jle    800950 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800924:	8b 45 14             	mov    0x14(%ebp),%eax
  800927:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092b:	8b 45 10             	mov    0x10(%ebp),%eax
  80092e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800932:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800935:	89 44 24 04          	mov    %eax,0x4(%esp)
  800939:	c7 04 24 b5 03 80 00 	movl   $0x8003b5,(%esp)
  800940:	e8 b5 fa ff ff       	call   8003fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800945:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800948:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094e:	eb 05                	jmp    800955 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800950:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800960:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800964:	8b 45 10             	mov    0x10(%ebp),%eax
  800967:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	89 04 24             	mov    %eax,(%esp)
  800978:	e8 82 ff ff ff       	call   8008ff <vsnprintf>
	va_end(ap);

	return rc;
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    
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
  800e43:	c7 44 24 08 50 14 80 	movl   $0x801450,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 6d 14 80 00 	movl   $0x80146d,(%esp)
  800e5a:	e8 29 f3 ff ff       	call   800188 <_panic>

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
  800e9c:	00 00                	add    %al,(%eax)
	...

00800ea0 <__udivdi3>:
  800ea0:	83 ec 1c             	sub    $0x1c,%esp
  800ea3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800ea7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800eab:	8b 44 24 20          	mov    0x20(%esp),%eax
  800eaf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800eb3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800eb7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ebb:	85 ff                	test   %edi,%edi
  800ebd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ec1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec5:	89 cd                	mov    %ecx,%ebp
  800ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ecb:	75 33                	jne    800f00 <__udivdi3+0x60>
  800ecd:	39 f1                	cmp    %esi,%ecx
  800ecf:	77 57                	ja     800f28 <__udivdi3+0x88>
  800ed1:	85 c9                	test   %ecx,%ecx
  800ed3:	75 0b                	jne    800ee0 <__udivdi3+0x40>
  800ed5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eda:	31 d2                	xor    %edx,%edx
  800edc:	f7 f1                	div    %ecx
  800ede:	89 c1                	mov    %eax,%ecx
  800ee0:	89 f0                	mov    %esi,%eax
  800ee2:	31 d2                	xor    %edx,%edx
  800ee4:	f7 f1                	div    %ecx
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eec:	f7 f1                	div    %ecx
  800eee:	89 f2                	mov    %esi,%edx
  800ef0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ef4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ef8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800efc:	83 c4 1c             	add    $0x1c,%esp
  800eff:	c3                   	ret    
  800f00:	31 d2                	xor    %edx,%edx
  800f02:	31 c0                	xor    %eax,%eax
  800f04:	39 f7                	cmp    %esi,%edi
  800f06:	77 e8                	ja     800ef0 <__udivdi3+0x50>
  800f08:	0f bd cf             	bsr    %edi,%ecx
  800f0b:	83 f1 1f             	xor    $0x1f,%ecx
  800f0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f12:	75 2c                	jne    800f40 <__udivdi3+0xa0>
  800f14:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f18:	76 04                	jbe    800f1e <__udivdi3+0x7e>
  800f1a:	39 f7                	cmp    %esi,%edi
  800f1c:	73 d2                	jae    800ef0 <__udivdi3+0x50>
  800f1e:	31 d2                	xor    %edx,%edx
  800f20:	b8 01 00 00 00       	mov    $0x1,%eax
  800f25:	eb c9                	jmp    800ef0 <__udivdi3+0x50>
  800f27:	90                   	nop
  800f28:	89 f2                	mov    %esi,%edx
  800f2a:	f7 f1                	div    %ecx
  800f2c:	31 d2                	xor    %edx,%edx
  800f2e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f32:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f36:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	c3                   	ret    
  800f3e:	66 90                	xchg   %ax,%ax
  800f40:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f45:	b8 20 00 00 00       	mov    $0x20,%eax
  800f4a:	89 ea                	mov    %ebp,%edx
  800f4c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f50:	d3 e7                	shl    %cl,%edi
  800f52:	89 c1                	mov    %eax,%ecx
  800f54:	d3 ea                	shr    %cl,%edx
  800f56:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f5b:	09 fa                	or     %edi,%edx
  800f5d:	89 f7                	mov    %esi,%edi
  800f5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f63:	89 f2                	mov    %esi,%edx
  800f65:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f69:	d3 e5                	shl    %cl,%ebp
  800f6b:	89 c1                	mov    %eax,%ecx
  800f6d:	d3 ef                	shr    %cl,%edi
  800f6f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f74:	d3 e2                	shl    %cl,%edx
  800f76:	89 c1                	mov    %eax,%ecx
  800f78:	d3 ee                	shr    %cl,%esi
  800f7a:	09 d6                	or     %edx,%esi
  800f7c:	89 fa                	mov    %edi,%edx
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	f7 74 24 0c          	divl   0xc(%esp)
  800f84:	89 d7                	mov    %edx,%edi
  800f86:	89 c6                	mov    %eax,%esi
  800f88:	f7 e5                	mul    %ebp
  800f8a:	39 d7                	cmp    %edx,%edi
  800f8c:	72 22                	jb     800fb0 <__udivdi3+0x110>
  800f8e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800f92:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f97:	d3 e5                	shl    %cl,%ebp
  800f99:	39 c5                	cmp    %eax,%ebp
  800f9b:	73 04                	jae    800fa1 <__udivdi3+0x101>
  800f9d:	39 d7                	cmp    %edx,%edi
  800f9f:	74 0f                	je     800fb0 <__udivdi3+0x110>
  800fa1:	89 f0                	mov    %esi,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	e9 46 ff ff ff       	jmp    800ef0 <__udivdi3+0x50>
  800faa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fb9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fbd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fc1:	83 c4 1c             	add    $0x1c,%esp
  800fc4:	c3                   	ret    
	...

00800fd0 <__umoddi3>:
  800fd0:	83 ec 1c             	sub    $0x1c,%esp
  800fd3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fd7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800fdb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800fdf:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fe3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fe7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800feb:	85 ed                	test   %ebp,%ebp
  800fed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800ff1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff5:	89 cf                	mov    %ecx,%edi
  800ff7:	89 04 24             	mov    %eax,(%esp)
  800ffa:	89 f2                	mov    %esi,%edx
  800ffc:	75 1a                	jne    801018 <__umoddi3+0x48>
  800ffe:	39 f1                	cmp    %esi,%ecx
  801000:	76 4e                	jbe    801050 <__umoddi3+0x80>
  801002:	f7 f1                	div    %ecx
  801004:	89 d0                	mov    %edx,%eax
  801006:	31 d2                	xor    %edx,%edx
  801008:	8b 74 24 10          	mov    0x10(%esp),%esi
  80100c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801010:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801014:	83 c4 1c             	add    $0x1c,%esp
  801017:	c3                   	ret    
  801018:	39 f5                	cmp    %esi,%ebp
  80101a:	77 54                	ja     801070 <__umoddi3+0xa0>
  80101c:	0f bd c5             	bsr    %ebp,%eax
  80101f:	83 f0 1f             	xor    $0x1f,%eax
  801022:	89 44 24 04          	mov    %eax,0x4(%esp)
  801026:	75 60                	jne    801088 <__umoddi3+0xb8>
  801028:	3b 0c 24             	cmp    (%esp),%ecx
  80102b:	0f 87 07 01 00 00    	ja     801138 <__umoddi3+0x168>
  801031:	89 f2                	mov    %esi,%edx
  801033:	8b 34 24             	mov    (%esp),%esi
  801036:	29 ce                	sub    %ecx,%esi
  801038:	19 ea                	sbb    %ebp,%edx
  80103a:	89 34 24             	mov    %esi,(%esp)
  80103d:	8b 04 24             	mov    (%esp),%eax
  801040:	8b 74 24 10          	mov    0x10(%esp),%esi
  801044:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801048:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80104c:	83 c4 1c             	add    $0x1c,%esp
  80104f:	c3                   	ret    
  801050:	85 c9                	test   %ecx,%ecx
  801052:	75 0b                	jne    80105f <__umoddi3+0x8f>
  801054:	b8 01 00 00 00       	mov    $0x1,%eax
  801059:	31 d2                	xor    %edx,%edx
  80105b:	f7 f1                	div    %ecx
  80105d:	89 c1                	mov    %eax,%ecx
  80105f:	89 f0                	mov    %esi,%eax
  801061:	31 d2                	xor    %edx,%edx
  801063:	f7 f1                	div    %ecx
  801065:	8b 04 24             	mov    (%esp),%eax
  801068:	f7 f1                	div    %ecx
  80106a:	eb 98                	jmp    801004 <__umoddi3+0x34>
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	89 f2                	mov    %esi,%edx
  801072:	8b 74 24 10          	mov    0x10(%esp),%esi
  801076:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80107a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80107e:	83 c4 1c             	add    $0x1c,%esp
  801081:	c3                   	ret    
  801082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801088:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80108d:	89 e8                	mov    %ebp,%eax
  80108f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801094:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801098:	89 fa                	mov    %edi,%edx
  80109a:	d3 e0                	shl    %cl,%eax
  80109c:	89 e9                	mov    %ebp,%ecx
  80109e:	d3 ea                	shr    %cl,%edx
  8010a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010a5:	09 c2                	or     %eax,%edx
  8010a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010ab:	89 14 24             	mov    %edx,(%esp)
  8010ae:	89 f2                	mov    %esi,%edx
  8010b0:	d3 e7                	shl    %cl,%edi
  8010b2:	89 e9                	mov    %ebp,%ecx
  8010b4:	d3 ea                	shr    %cl,%edx
  8010b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010bf:	d3 e6                	shl    %cl,%esi
  8010c1:	89 e9                	mov    %ebp,%ecx
  8010c3:	d3 e8                	shr    %cl,%eax
  8010c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ca:	09 f0                	or     %esi,%eax
  8010cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010d0:	f7 34 24             	divl   (%esp)
  8010d3:	d3 e6                	shl    %cl,%esi
  8010d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010d9:	89 d6                	mov    %edx,%esi
  8010db:	f7 e7                	mul    %edi
  8010dd:	39 d6                	cmp    %edx,%esi
  8010df:	89 c1                	mov    %eax,%ecx
  8010e1:	89 d7                	mov    %edx,%edi
  8010e3:	72 3f                	jb     801124 <__umoddi3+0x154>
  8010e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010e9:	72 35                	jb     801120 <__umoddi3+0x150>
  8010eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010ef:	29 c8                	sub    %ecx,%eax
  8010f1:	19 fe                	sbb    %edi,%esi
  8010f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f8:	89 f2                	mov    %esi,%edx
  8010fa:	d3 e8                	shr    %cl,%eax
  8010fc:	89 e9                	mov    %ebp,%ecx
  8010fe:	d3 e2                	shl    %cl,%edx
  801100:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801105:	09 d0                	or     %edx,%eax
  801107:	89 f2                	mov    %esi,%edx
  801109:	d3 ea                	shr    %cl,%edx
  80110b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80110f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801113:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801117:	83 c4 1c             	add    $0x1c,%esp
  80111a:	c3                   	ret    
  80111b:	90                   	nop
  80111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801120:	39 d6                	cmp    %edx,%esi
  801122:	75 c7                	jne    8010eb <__umoddi3+0x11b>
  801124:	89 d7                	mov    %edx,%edi
  801126:	89 c1                	mov    %eax,%ecx
  801128:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80112c:	1b 3c 24             	sbb    (%esp),%edi
  80112f:	eb ba                	jmp    8010eb <__umoddi3+0x11b>
  801131:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801138:	39 f5                	cmp    %esi,%ebp
  80113a:	0f 82 f1 fe ff ff    	jb     801031 <__umoddi3+0x61>
  801140:	e9 f8 fe ff ff       	jmp    80103d <__umoddi3+0x6d>
