
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
  80003a:	c7 04 24 38 11 80 00 	movl   $0x801138,(%esp)
  800041:	e8 21 02 00 00       	call   800267 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
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
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800069:	c7 44 24 08 b3 11 80 	movl   $0x8011b3,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 d0 11 80 00 	movl   $0x8011d0,(%esp)
  800080:	e8 e7 00 00 00       	call   80016c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	83 c0 01             	add    $0x1,%eax
  800088:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008d:	75 c5                	jne    800054 <umain+0x20>
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800094:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009b:	83 c0 01             	add    $0x1,%eax
  80009e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a3:	75 ef                	jne    800094 <umain+0x60>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a5:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000ac:	75 10                	jne    8000be <umain+0x8a>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
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
  8000c7:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 d0 11 80 00 	movl   $0x8011d0,(%esp)
  8000de:	e8 89 00 00 00       	call   80016c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e3:	83 c0 01             	add    $0x1,%eax
  8000e6:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000eb:	75 c6                	jne    8000b3 <umain+0x7f>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ed:	c7 04 24 80 11 80 00 	movl   $0x801180,(%esp)
  8000f4:	e8 6e 01 00 00       	call   800267 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 df 11 80 	movl   $0x8011df,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 d0 11 80 00 	movl   $0x8011d0,(%esp)
  80011a:	e8 4d 00 00 00       	call   80016c <_panic>
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
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80012c:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  800133:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	7e 08                	jle    800142 <libmain+0x22>
		binaryname = argv[0];
  80013a:	8b 0a                	mov    (%edx),%ecx
  80013c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800142:	89 54 24 04          	mov    %edx,0x4(%esp)
  800146:	89 04 24             	mov    %eax,(%esp)
  800149:	e8 e6 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014e:	e8 05 00 00 00       	call   800158 <exit>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    
  800155:	00 00                	add    %al,(%eax)
	...

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800165:	e8 95 0c 00 00       	call   800dff <sys_env_destroy>
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80017d:	e8 da 0c 00 00       	call   800e5c <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  80019f:	e8 c3 00 00 00       	call   800267 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 53 00 00 00       	call   800206 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 ce 11 80 00 	movl   $0x8011ce,(%esp)
  8001ba:	e8 a8 00 00 00       	call   800267 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	83 c0 01             	add    $0x1,%eax
  8001da:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e1:	75 19                	jne    8001fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ea:	00 
  8001eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	e8 aa 0b 00 00       	call   800da0 <sys_cputs>
		b->idx = 0;
  8001f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800200:	83 c4 14             	add    $0x14,%esp
  800203:	5b                   	pop    %ebx
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800216:	00 00 00 
	b.cnt = 0;
  800219:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800220:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800223:	8b 45 0c             	mov    0xc(%ebp),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023b:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  800242:	e8 97 01 00 00       	call   8003de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 41 0b 00 00       	call   800da0 <sys_cputs>

	return b.cnt;
}
  80025f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800270:	89 44 24 04          	mov    %eax,0x4(%esp)
  800274:	8b 45 08             	mov    0x8(%ebp),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	e8 87 ff ff ff       	call   800206 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    
  800281:	00 00                	add    %al,(%eax)
	...

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 3c             	sub    $0x3c,%esp
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	89 d7                	mov    %edx,%edi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002ac:	72 11                	jb     8002bf <printnum+0x3b>
  8002ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b4:	76 09                	jbe    8002bf <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b6:	83 eb 01             	sub    $0x1,%ebx
  8002b9:	85 db                	test   %ebx,%ebx
  8002bb:	7f 51                	jg     80030e <printnum+0x8a>
  8002bd:	eb 5e                	jmp    80031d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002c3:	83 eb 01             	sub    $0x1,%ebx
  8002c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002d5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e0:	00 
  8002e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ee:	e8 9d 0b 00 00       	call   800e90 <__udivdi3>
  8002f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800302:	89 fa                	mov    %edi,%edx
  800304:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800307:	e8 78 ff ff ff       	call   800284 <printnum>
  80030c:	eb 0f                	jmp    80031d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800312:	89 34 24             	mov    %esi,(%esp)
  800315:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	75 f1                	jne    80030e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800321:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800325:	8b 45 10             	mov    0x10(%ebp),%eax
  800328:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800333:	00 
  800334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	e8 7a 0c 00 00       	call   800fc0 <__umoddi3>
  800346:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034a:	0f be 80 24 12 80 00 	movsbl 0x801224(%eax),%eax
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800357:	83 c4 3c             	add    $0x3c,%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800362:	83 fa 01             	cmp    $0x1,%edx
  800365:	7e 0e                	jle    800375 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	8b 52 04             	mov    0x4(%edx),%edx
  800373:	eb 22                	jmp    800397 <getuint+0x38>
	else if (lflag)
  800375:	85 d2                	test   %edx,%edx
  800377:	74 10                	je     800389 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 0e                	jmp    800397 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a8:	73 0a                	jae    8003b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ad:	88 0a                	mov    %cl,(%edx)
  8003af:	83 c2 01             	add    $0x1,%edx
  8003b2:	89 10                	mov    %edx,(%eax)
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	e8 02 00 00 00       	call   8003de <vprintfmt>
	va_end(ap);
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	57                   	push   %edi
  8003e2:	56                   	push   %esi
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 5c             	sub    $0x5c,%esp
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ea:	8b 75 10             	mov    0x10(%ebp),%esi
  8003ed:	eb 12                	jmp    800401 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	0f 84 e4 04 00 00    	je     8008db <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800401:	0f b6 06             	movzbl (%esi),%eax
  800404:	83 c6 01             	add    $0x1,%esi
  800407:	83 f8 25             	cmp    $0x25,%eax
  80040a:	75 e3                	jne    8003ef <vprintfmt+0x11>
  80040c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800410:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800417:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80041c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800423:	b9 00 00 00 00       	mov    $0x0,%ecx
  800428:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80042b:	eb 2b                	jmp    800458 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800430:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800434:	eb 22                	jmp    800458 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800439:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80043d:	eb 19                	jmp    800458 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800442:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800449:	eb 0d                	jmp    800458 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80044b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80044e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800451:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	0f b6 06             	movzbl (%esi),%eax
  80045b:	0f b6 d0             	movzbl %al,%edx
  80045e:	8d 7e 01             	lea    0x1(%esi),%edi
  800461:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800464:	83 e8 23             	sub    $0x23,%eax
  800467:	3c 55                	cmp    $0x55,%al
  800469:	0f 87 46 04 00 00    	ja     8008b5 <vprintfmt+0x4d7>
  80046f:	0f b6 c0             	movzbl %al,%eax
  800472:	ff 24 85 cc 12 80 00 	jmp    *0x8012cc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800479:	83 ea 30             	sub    $0x30,%edx
  80047c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80047f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800483:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800489:	83 fa 09             	cmp    $0x9,%edx
  80048c:	77 4a                	ja     8004d8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800491:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800494:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800497:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80049b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80049e:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004a1:	83 fa 09             	cmp    $0x9,%edx
  8004a4:	76 eb                	jbe    800491 <vprintfmt+0xb3>
  8004a6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004a9:	eb 2d                	jmp    8004d8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 50 04             	lea    0x4(%eax),%edx
  8004b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004bc:	eb 1a                	jmp    8004d8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004c1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004c5:	79 91                	jns    800458 <vprintfmt+0x7a>
  8004c7:	e9 73 ff ff ff       	jmp    80043f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cf:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004d6:	eb 80                	jmp    800458 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004dc:	0f 89 76 ff ff ff    	jns    800458 <vprintfmt+0x7a>
  8004e2:	e9 64 ff ff ff       	jmp    80044b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ed:	e9 66 ff ff ff       	jmp    800458 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 04 24             	mov    %eax,(%esp)
  800504:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050a:	e9 f2 fe ff ff       	jmp    800401 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80050f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800513:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800516:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80051a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80051d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800521:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800524:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800527:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80052b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80052e:	80 f9 09             	cmp    $0x9,%cl
  800531:	77 1d                	ja     800550 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800533:	0f be c0             	movsbl %al,%eax
  800536:	6b c0 64             	imul   $0x64,%eax,%eax
  800539:	0f be d2             	movsbl %dl,%edx
  80053c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80053f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800546:	a3 04 20 80 00       	mov    %eax,0x802004
  80054b:	e9 b1 fe ff ff       	jmp    800401 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800550:	c7 44 24 04 3c 12 80 	movl   $0x80123c,0x4(%esp)
  800557:	00 
  800558:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 18 05 00 00       	call   800a7b <strcmp>
  800563:	85 c0                	test   %eax,%eax
  800565:	75 0f                	jne    800576 <vprintfmt+0x198>
  800567:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80056e:	00 00 00 
  800571:	e9 8b fe ff ff       	jmp    800401 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800576:	c7 44 24 04 40 12 80 	movl   $0x801240,0x4(%esp)
  80057d:	00 
  80057e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800581:	89 14 24             	mov    %edx,(%esp)
  800584:	e8 f2 04 00 00       	call   800a7b <strcmp>
  800589:	85 c0                	test   %eax,%eax
  80058b:	75 0f                	jne    80059c <vprintfmt+0x1be>
  80058d:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800594:	00 00 00 
  800597:	e9 65 fe ff ff       	jmp    800401 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80059c:	c7 44 24 04 44 12 80 	movl   $0x801244,0x4(%esp)
  8005a3:	00 
  8005a4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005a7:	89 0c 24             	mov    %ecx,(%esp)
  8005aa:	e8 cc 04 00 00       	call   800a7b <strcmp>
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	75 0f                	jne    8005c2 <vprintfmt+0x1e4>
  8005b3:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005ba:	00 00 00 
  8005bd:	e9 3f fe ff ff       	jmp    800401 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005c2:	c7 44 24 04 48 12 80 	movl   $0x801248,0x4(%esp)
  8005c9:	00 
  8005ca:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005cd:	89 3c 24             	mov    %edi,(%esp)
  8005d0:	e8 a6 04 00 00       	call   800a7b <strcmp>
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	75 0f                	jne    8005e8 <vprintfmt+0x20a>
  8005d9:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005e0:	00 00 00 
  8005e3:	e9 19 fe ff ff       	jmp    800401 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005e8:	c7 44 24 04 4c 12 80 	movl   $0x80124c,0x4(%esp)
  8005ef:	00 
  8005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f3:	89 04 24             	mov    %eax,(%esp)
  8005f6:	e8 80 04 00 00       	call   800a7b <strcmp>
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	75 0f                	jne    80060e <vprintfmt+0x230>
  8005ff:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800606:	00 00 00 
  800609:	e9 f3 fd ff ff       	jmp    800401 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80060e:	c7 44 24 04 50 12 80 	movl   $0x801250,0x4(%esp)
  800615:	00 
  800616:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800619:	89 14 24             	mov    %edx,(%esp)
  80061c:	e8 5a 04 00 00       	call   800a7b <strcmp>
  800621:	83 f8 01             	cmp    $0x1,%eax
  800624:	19 c0                	sbb    %eax,%eax
  800626:	f7 d0                	not    %eax
  800628:	83 c0 08             	add    $0x8,%eax
  80062b:	a3 04 20 80 00       	mov    %eax,0x802004
  800630:	e9 cc fd ff ff       	jmp    800401 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 50 04             	lea    0x4(%eax),%edx
  80063b:	89 55 14             	mov    %edx,0x14(%ebp)
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	89 c2                	mov    %eax,%edx
  800642:	c1 fa 1f             	sar    $0x1f,%edx
  800645:	31 d0                	xor    %edx,%eax
  800647:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800649:	83 f8 06             	cmp    $0x6,%eax
  80064c:	7f 0b                	jg     800659 <vprintfmt+0x27b>
  80064e:	8b 14 85 24 14 80 00 	mov    0x801424(,%eax,4),%edx
  800655:	85 d2                	test   %edx,%edx
  800657:	75 23                	jne    80067c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800659:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065d:	c7 44 24 08 54 12 80 	movl   $0x801254,0x8(%esp)
  800664:	00 
  800665:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800669:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066c:	89 3c 24             	mov    %edi,(%esp)
  80066f:	e8 42 fd ff ff       	call   8003b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800677:	e9 85 fd ff ff       	jmp    800401 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800680:	c7 44 24 08 5d 12 80 	movl   $0x80125d,0x8(%esp)
  800687:	00 
  800688:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80068f:	89 3c 24             	mov    %edi,(%esp)
  800692:	e8 1f fd ff ff       	call   8003b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80069a:	e9 62 fd ff ff       	jmp    800401 <vprintfmt+0x23>
  80069f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006b3:	85 f6                	test   %esi,%esi
  8006b5:	b8 35 12 80 00       	mov    $0x801235,%eax
  8006ba:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006bd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006c1:	7e 06                	jle    8006c9 <vprintfmt+0x2eb>
  8006c3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006c7:	75 13                	jne    8006dc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c9:	0f be 06             	movsbl (%esi),%eax
  8006cc:	83 c6 01             	add    $0x1,%esi
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	0f 85 94 00 00 00    	jne    80076b <vprintfmt+0x38d>
  8006d7:	e9 81 00 00 00       	jmp    80075d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e0:	89 34 24             	mov    %esi,(%esp)
  8006e3:	e8 a3 02 00 00       	call   80098b <strnlen>
  8006e8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006eb:	29 c2                	sub    %eax,%edx
  8006ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006f0:	85 d2                	test   %edx,%edx
  8006f2:	7e d5                	jle    8006c9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006f4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006f8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006fb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006fe:	89 d6                	mov    %edx,%esi
  800700:	89 cf                	mov    %ecx,%edi
  800702:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800706:	89 3c 24             	mov    %edi,(%esp)
  800709:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070c:	83 ee 01             	sub    $0x1,%esi
  80070f:	75 f1                	jne    800702 <vprintfmt+0x324>
  800711:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800714:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800717:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80071a:	eb ad                	jmp    8006c9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800720:	74 1b                	je     80073d <vprintfmt+0x35f>
  800722:	8d 50 e0             	lea    -0x20(%eax),%edx
  800725:	83 fa 5e             	cmp    $0x5e,%edx
  800728:	76 13                	jbe    80073d <vprintfmt+0x35f>
					putch('?', putdat);
  80072a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80072d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800731:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800738:	ff 55 08             	call   *0x8(%ebp)
  80073b:	eb 0d                	jmp    80074a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80073d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800740:	89 54 24 04          	mov    %edx,0x4(%esp)
  800744:	89 04 24             	mov    %eax,(%esp)
  800747:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074a:	83 eb 01             	sub    $0x1,%ebx
  80074d:	0f be 06             	movsbl (%esi),%eax
  800750:	83 c6 01             	add    $0x1,%esi
  800753:	85 c0                	test   %eax,%eax
  800755:	75 1a                	jne    800771 <vprintfmt+0x393>
  800757:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80075a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800760:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800764:	7f 1c                	jg     800782 <vprintfmt+0x3a4>
  800766:	e9 96 fc ff ff       	jmp    800401 <vprintfmt+0x23>
  80076b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80076e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800771:	85 ff                	test   %edi,%edi
  800773:	78 a7                	js     80071c <vprintfmt+0x33e>
  800775:	83 ef 01             	sub    $0x1,%edi
  800778:	79 a2                	jns    80071c <vprintfmt+0x33e>
  80077a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80077d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800780:	eb db                	jmp    80075d <vprintfmt+0x37f>
  800782:	8b 7d 08             	mov    0x8(%ebp),%edi
  800785:	89 de                	mov    %ebx,%esi
  800787:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800795:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800797:	83 eb 01             	sub    $0x1,%ebx
  80079a:	75 ee                	jne    80078a <vprintfmt+0x3ac>
  80079c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007a1:	e9 5b fc ff ff       	jmp    800401 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a6:	83 f9 01             	cmp    $0x1,%ecx
  8007a9:	7e 10                	jle    8007bb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 08             	lea    0x8(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 30                	mov    (%eax),%esi
  8007b6:	8b 78 04             	mov    0x4(%eax),%edi
  8007b9:	eb 26                	jmp    8007e1 <vprintfmt+0x403>
	else if (lflag)
  8007bb:	85 c9                	test   %ecx,%ecx
  8007bd:	74 12                	je     8007d1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 30                	mov    (%eax),%esi
  8007ca:	89 f7                	mov    %esi,%edi
  8007cc:	c1 ff 1f             	sar    $0x1f,%edi
  8007cf:	eb 10                	jmp    8007e1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 04             	lea    0x4(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007da:	8b 30                	mov    (%eax),%esi
  8007dc:	89 f7                	mov    %esi,%edi
  8007de:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e1:	85 ff                	test   %edi,%edi
  8007e3:	78 0e                	js     8007f3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e9:	be 0a 00 00 00       	mov    $0xa,%esi
  8007ee:	e9 84 00 00 00       	jmp    800877 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800801:	89 f0                	mov    %esi,%eax
  800803:	89 fa                	mov    %edi,%edx
  800805:	f7 d8                	neg    %eax
  800807:	83 d2 00             	adc    $0x0,%edx
  80080a:	f7 da                	neg    %edx
			}
			base = 10;
  80080c:	be 0a 00 00 00       	mov    $0xa,%esi
  800811:	eb 64                	jmp    800877 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800813:	89 ca                	mov    %ecx,%edx
  800815:	8d 45 14             	lea    0x14(%ebp),%eax
  800818:	e8 42 fb ff ff       	call   80035f <getuint>
			base = 10;
  80081d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800822:	eb 53                	jmp    800877 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800824:	89 ca                	mov    %ecx,%edx
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
  800829:	e8 31 fb ff ff       	call   80035f <getuint>
    			base = 8;
  80082e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800833:	eb 42                	jmp    800877 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800835:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800839:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800840:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800843:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800847:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085a:	8b 00                	mov    (%eax),%eax
  80085c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800861:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800866:	eb 0f                	jmp    800877 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800868:	89 ca                	mov    %ecx,%edx
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
  80086d:	e8 ed fa ff ff       	call   80035f <getuint>
			base = 16;
  800872:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800877:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80087b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80087f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800882:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800886:	89 74 24 08          	mov    %esi,0x8(%esp)
  80088a:	89 04 24             	mov    %eax,(%esp)
  80088d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800891:	89 da                	mov    %ebx,%edx
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	e8 e9 f9 ff ff       	call   800284 <printnum>
			break;
  80089b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80089e:	e9 5e fb ff ff       	jmp    800401 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a7:	89 14 24             	mov    %edx,(%esp)
  8008aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b0:	e9 4c fb ff ff       	jmp    800401 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008c7:	0f 84 34 fb ff ff    	je     800401 <vprintfmt+0x23>
  8008cd:	83 ee 01             	sub    $0x1,%esi
  8008d0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008d4:	75 f7                	jne    8008cd <vprintfmt+0x4ef>
  8008d6:	e9 26 fb ff ff       	jmp    800401 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008db:	83 c4 5c             	add    $0x5c,%esp
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5f                   	pop    %edi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	83 ec 28             	sub    $0x28,%esp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800900:	85 c0                	test   %eax,%eax
  800902:	74 30                	je     800934 <vsnprintf+0x51>
  800904:	85 d2                	test   %edx,%edx
  800906:	7e 2c                	jle    800934 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090f:	8b 45 10             	mov    0x10(%ebp),%eax
  800912:	89 44 24 08          	mov    %eax,0x8(%esp)
  800916:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091d:	c7 04 24 99 03 80 00 	movl   $0x800399,(%esp)
  800924:	e8 b5 fa ff ff       	call   8003de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800929:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800932:	eb 05                	jmp    800939 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800934:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800941:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800944:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800948:	8b 45 10             	mov    0x10(%ebp),%eax
  80094b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	89 44 24 04          	mov    %eax,0x4(%esp)
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	89 04 24             	mov    %eax,(%esp)
  80095c:	e8 82 ff ff ff       	call   8008e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    
	...

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	80 3a 00             	cmpb   $0x0,(%edx)
  80097e:	74 09                	je     800989 <strlen+0x19>
		n++;
  800980:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800983:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800987:	75 f7                	jne    800980 <strlen+0x10>
		n++;
	return n;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800992:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
  80099a:	85 c9                	test   %ecx,%ecx
  80099c:	74 1a                	je     8009b8 <strnlen+0x2d>
  80099e:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009a1:	74 15                	je     8009b8 <strnlen+0x2d>
  8009a3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009a8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009aa:	39 ca                	cmp    %ecx,%edx
  8009ac:	74 0a                	je     8009b8 <strnlen+0x2d>
  8009ae:	83 c2 01             	add    $0x1,%edx
  8009b1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009b6:	75 f0                	jne    8009a8 <strnlen+0x1d>
		n++;
	return n;
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ce:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009d1:	83 c2 01             	add    $0x1,%edx
  8009d4:	84 c9                	test   %cl,%cl
  8009d6:	75 f2                	jne    8009ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	83 ec 08             	sub    $0x8,%esp
  8009e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e5:	89 1c 24             	mov    %ebx,(%esp)
  8009e8:	e8 83 ff ff ff       	call   800970 <strlen>
	strcpy(dst + len, src);
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f4:	01 d8                	add    %ebx,%eax
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	e8 bd ff ff ff       	call   8009bb <strcpy>
	return dst;
}
  8009fe:	89 d8                	mov    %ebx,%eax
  800a00:	83 c4 08             	add    $0x8,%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a14:	85 f6                	test   %esi,%esi
  800a16:	74 18                	je     800a30 <strncpy+0x2a>
  800a18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a1d:	0f b6 1a             	movzbl (%edx),%ebx
  800a20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a23:	80 3a 01             	cmpb   $0x1,(%edx)
  800a26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	39 f1                	cmp    %esi,%ecx
  800a2e:	75 ed                	jne    800a1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a40:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a43:	89 f8                	mov    %edi,%eax
  800a45:	85 f6                	test   %esi,%esi
  800a47:	74 2b                	je     800a74 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a49:	83 fe 01             	cmp    $0x1,%esi
  800a4c:	74 23                	je     800a71 <strlcpy+0x3d>
  800a4e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a51:	84 c9                	test   %cl,%cl
  800a53:	74 1c                	je     800a71 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a55:	83 ee 02             	sub    $0x2,%esi
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a5d:	88 08                	mov    %cl,(%eax)
  800a5f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a62:	39 f2                	cmp    %esi,%edx
  800a64:	74 0b                	je     800a71 <strlcpy+0x3d>
  800a66:	83 c2 01             	add    $0x1,%edx
  800a69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a6d:	84 c9                	test   %cl,%cl
  800a6f:	75 ec                	jne    800a5d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a71:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a74:	29 f8                	sub    %edi,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a84:	0f b6 01             	movzbl (%ecx),%eax
  800a87:	84 c0                	test   %al,%al
  800a89:	74 16                	je     800aa1 <strcmp+0x26>
  800a8b:	3a 02                	cmp    (%edx),%al
  800a8d:	75 12                	jne    800aa1 <strcmp+0x26>
		p++, q++;
  800a8f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a92:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a96:	84 c0                	test   %al,%al
  800a98:	74 07                	je     800aa1 <strcmp+0x26>
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	3a 02                	cmp    (%edx),%al
  800a9f:	74 ee                	je     800a8f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa1:	0f b6 c0             	movzbl %al,%eax
  800aa4:	0f b6 12             	movzbl (%edx),%edx
  800aa7:	29 d0                	sub    %edx,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	53                   	push   %ebx
  800aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800abd:	85 d2                	test   %edx,%edx
  800abf:	74 28                	je     800ae9 <strncmp+0x3e>
  800ac1:	0f b6 01             	movzbl (%ecx),%eax
  800ac4:	84 c0                	test   %al,%al
  800ac6:	74 24                	je     800aec <strncmp+0x41>
  800ac8:	3a 03                	cmp    (%ebx),%al
  800aca:	75 20                	jne    800aec <strncmp+0x41>
  800acc:	83 ea 01             	sub    $0x1,%edx
  800acf:	74 13                	je     800ae4 <strncmp+0x39>
		n--, p++, q++;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad7:	0f b6 01             	movzbl (%ecx),%eax
  800ada:	84 c0                	test   %al,%al
  800adc:	74 0e                	je     800aec <strncmp+0x41>
  800ade:	3a 03                	cmp    (%ebx),%al
  800ae0:	74 ea                	je     800acc <strncmp+0x21>
  800ae2:	eb 08                	jmp    800aec <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aec:	0f b6 01             	movzbl (%ecx),%eax
  800aef:	0f b6 13             	movzbl (%ebx),%edx
  800af2:	29 d0                	sub    %edx,%eax
  800af4:	eb f3                	jmp    800ae9 <strncmp+0x3e>

00800af6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b00:	0f b6 10             	movzbl (%eax),%edx
  800b03:	84 d2                	test   %dl,%dl
  800b05:	74 1c                	je     800b23 <strchr+0x2d>
		if (*s == c)
  800b07:	38 ca                	cmp    %cl,%dl
  800b09:	75 09                	jne    800b14 <strchr+0x1e>
  800b0b:	eb 1b                	jmp    800b28 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b10:	38 ca                	cmp    %cl,%dl
  800b12:	74 14                	je     800b28 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b14:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b18:	84 d2                	test   %dl,%dl
  800b1a:	75 f1                	jne    800b0d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b21:	eb 05                	jmp    800b28 <strchr+0x32>
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b34:	0f b6 10             	movzbl (%eax),%edx
  800b37:	84 d2                	test   %dl,%dl
  800b39:	74 14                	je     800b4f <strfind+0x25>
		if (*s == c)
  800b3b:	38 ca                	cmp    %cl,%dl
  800b3d:	75 06                	jne    800b45 <strfind+0x1b>
  800b3f:	eb 0e                	jmp    800b4f <strfind+0x25>
  800b41:	38 ca                	cmp    %cl,%dl
  800b43:	74 0a                	je     800b4f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b45:	83 c0 01             	add    $0x1,%eax
  800b48:	0f b6 10             	movzbl (%eax),%edx
  800b4b:	84 d2                	test   %dl,%dl
  800b4d:	75 f2                	jne    800b41 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b69:	85 c9                	test   %ecx,%ecx
  800b6b:	74 30                	je     800b9d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b73:	75 25                	jne    800b9a <memset+0x49>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 20                	jne    800b9a <memset+0x49>
		c &= 0xFF;
  800b7a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	c1 e3 08             	shl    $0x8,%ebx
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	c1 e6 18             	shl    $0x18,%esi
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	c1 e0 10             	shl    $0x10,%eax
  800b8c:	09 f0                	or     %esi,%eax
  800b8e:	09 d0                	or     %edx,%eax
  800b90:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b92:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b95:	fc                   	cld    
  800b96:	f3 ab                	rep stos %eax,%es:(%edi)
  800b98:	eb 03                	jmp    800b9d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9a:	fc                   	cld    
  800b9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b9d:	89 f8                	mov    %edi,%eax
  800b9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ba2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba8:	89 ec                	mov    %ebp,%esp
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bb5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc1:	39 c6                	cmp    %eax,%esi
  800bc3:	73 36                	jae    800bfb <memmove+0x4f>
  800bc5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc8:	39 d0                	cmp    %edx,%eax
  800bca:	73 2f                	jae    800bfb <memmove+0x4f>
		s += n;
		d += n;
  800bcc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcf:	f6 c2 03             	test   $0x3,%dl
  800bd2:	75 1b                	jne    800bef <memmove+0x43>
  800bd4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bda:	75 13                	jne    800bef <memmove+0x43>
  800bdc:	f6 c1 03             	test   $0x3,%cl
  800bdf:	75 0e                	jne    800bef <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be1:	83 ef 04             	sub    $0x4,%edi
  800be4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bea:	fd                   	std    
  800beb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bed:	eb 09                	jmp    800bf8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bef:	83 ef 01             	sub    $0x1,%edi
  800bf2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf5:	fd                   	std    
  800bf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf8:	fc                   	cld    
  800bf9:	eb 20                	jmp    800c1b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c01:	75 13                	jne    800c16 <memmove+0x6a>
  800c03:	a8 03                	test   $0x3,%al
  800c05:	75 0f                	jne    800c16 <memmove+0x6a>
  800c07:	f6 c1 03             	test   $0x3,%cl
  800c0a:	75 0a                	jne    800c16 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	fc                   	cld    
  800c12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c14:	eb 05                	jmp    800c1b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c16:	89 c7                	mov    %eax,%edi
  800c18:	fc                   	cld    
  800c19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c21:	89 ec                	mov    %ebp,%esp
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	89 04 24             	mov    %eax,(%esp)
  800c3f:	e8 68 ff ff ff       	call   800bac <memmove>
}
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    

00800c46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c52:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5a:	85 ff                	test   %edi,%edi
  800c5c:	74 37                	je     800c95 <memcmp+0x4f>
		if (*s1 != *s2)
  800c5e:	0f b6 03             	movzbl (%ebx),%eax
  800c61:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c64:	83 ef 01             	sub    $0x1,%edi
  800c67:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c6c:	38 c8                	cmp    %cl,%al
  800c6e:	74 1c                	je     800c8c <memcmp+0x46>
  800c70:	eb 10                	jmp    800c82 <memcmp+0x3c>
  800c72:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c77:	83 c2 01             	add    $0x1,%edx
  800c7a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c7e:	38 c8                	cmp    %cl,%al
  800c80:	74 0a                	je     800c8c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c82:	0f b6 c0             	movzbl %al,%eax
  800c85:	0f b6 c9             	movzbl %cl,%ecx
  800c88:	29 c8                	sub    %ecx,%eax
  800c8a:	eb 09                	jmp    800c95 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8c:	39 fa                	cmp    %edi,%edx
  800c8e:	75 e2                	jne    800c72 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ca0:	89 c2                	mov    %eax,%edx
  800ca2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ca5:	39 d0                	cmp    %edx,%eax
  800ca7:	73 19                	jae    800cc2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cad:	38 08                	cmp    %cl,(%eax)
  800caf:	75 06                	jne    800cb7 <memfind+0x1d>
  800cb1:	eb 0f                	jmp    800cc2 <memfind+0x28>
  800cb3:	38 08                	cmp    %cl,(%eax)
  800cb5:	74 0b                	je     800cc2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb7:	83 c0 01             	add    $0x1,%eax
  800cba:	39 d0                	cmp    %edx,%eax
  800cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	75 f1                	jne    800cb3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd0:	0f b6 02             	movzbl (%edx),%eax
  800cd3:	3c 20                	cmp    $0x20,%al
  800cd5:	74 04                	je     800cdb <strtol+0x17>
  800cd7:	3c 09                	cmp    $0x9,%al
  800cd9:	75 0e                	jne    800ce9 <strtol+0x25>
		s++;
  800cdb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cde:	0f b6 02             	movzbl (%edx),%eax
  800ce1:	3c 20                	cmp    $0x20,%al
  800ce3:	74 f6                	je     800cdb <strtol+0x17>
  800ce5:	3c 09                	cmp    $0x9,%al
  800ce7:	74 f2                	je     800cdb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce9:	3c 2b                	cmp    $0x2b,%al
  800ceb:	75 0a                	jne    800cf7 <strtol+0x33>
		s++;
  800ced:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cf0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf5:	eb 10                	jmp    800d07 <strtol+0x43>
  800cf7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cfc:	3c 2d                	cmp    $0x2d,%al
  800cfe:	75 07                	jne    800d07 <strtol+0x43>
		s++, neg = 1;
  800d00:	83 c2 01             	add    $0x1,%edx
  800d03:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d07:	85 db                	test   %ebx,%ebx
  800d09:	0f 94 c0             	sete   %al
  800d0c:	74 05                	je     800d13 <strtol+0x4f>
  800d0e:	83 fb 10             	cmp    $0x10,%ebx
  800d11:	75 15                	jne    800d28 <strtol+0x64>
  800d13:	80 3a 30             	cmpb   $0x30,(%edx)
  800d16:	75 10                	jne    800d28 <strtol+0x64>
  800d18:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d1c:	75 0a                	jne    800d28 <strtol+0x64>
		s += 2, base = 16;
  800d1e:	83 c2 02             	add    $0x2,%edx
  800d21:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d26:	eb 13                	jmp    800d3b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d28:	84 c0                	test   %al,%al
  800d2a:	74 0f                	je     800d3b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d31:	80 3a 30             	cmpb   $0x30,(%edx)
  800d34:	75 05                	jne    800d3b <strtol+0x77>
		s++, base = 8;
  800d36:	83 c2 01             	add    $0x1,%edx
  800d39:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d40:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d42:	0f b6 0a             	movzbl (%edx),%ecx
  800d45:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d48:	80 fb 09             	cmp    $0x9,%bl
  800d4b:	77 08                	ja     800d55 <strtol+0x91>
			dig = *s - '0';
  800d4d:	0f be c9             	movsbl %cl,%ecx
  800d50:	83 e9 30             	sub    $0x30,%ecx
  800d53:	eb 1e                	jmp    800d73 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d55:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d58:	80 fb 19             	cmp    $0x19,%bl
  800d5b:	77 08                	ja     800d65 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d5d:	0f be c9             	movsbl %cl,%ecx
  800d60:	83 e9 57             	sub    $0x57,%ecx
  800d63:	eb 0e                	jmp    800d73 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d65:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d68:	80 fb 19             	cmp    $0x19,%bl
  800d6b:	77 14                	ja     800d81 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d6d:	0f be c9             	movsbl %cl,%ecx
  800d70:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d73:	39 f1                	cmp    %esi,%ecx
  800d75:	7d 0e                	jge    800d85 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d77:	83 c2 01             	add    $0x1,%edx
  800d7a:	0f af c6             	imul   %esi,%eax
  800d7d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d7f:	eb c1                	jmp    800d42 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d81:	89 c1                	mov    %eax,%ecx
  800d83:	eb 02                	jmp    800d87 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d85:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8b:	74 05                	je     800d92 <strtol+0xce>
		*endptr = (char *) s;
  800d8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d90:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d92:	89 ca                	mov    %ecx,%edx
  800d94:	f7 da                	neg    %edx
  800d96:	85 ff                	test   %edi,%edi
  800d98:	0f 45 c2             	cmovne %edx,%eax
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	89 c7                	mov    %eax,%edi
  800dbe:	89 c6                	mov    %eax,%esi
  800dc0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcb:	89 ec                	mov    %ebp,%esp
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_cgetc>:

int
sys_cgetc(void)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dde:	ba 00 00 00 00       	mov    $0x0,%edx
  800de3:	b8 01 00 00 00       	mov    $0x1,%eax
  800de8:	89 d1                	mov    %edx,%ecx
  800dea:	89 d3                	mov    %edx,%ebx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	89 d6                	mov    %edx,%esi
  800df0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800df2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfb:	89 ec                	mov    %ebp,%esp
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 38             	sub    $0x38,%esp
  800e05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e13:	b8 03 00 00 00       	mov    $0x3,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 cb                	mov    %ecx,%ebx
  800e1d:	89 cf                	mov    %ecx,%edi
  800e1f:	89 ce                	mov    %ecx,%esi
  800e21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 28                	jle    800e4f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e32:	00 
  800e33:	c7 44 24 08 40 14 80 	movl   $0x801440,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e42:	00 
  800e43:	c7 04 24 5d 14 80 00 	movl   $0x80145d,(%esp)
  800e4a:	e8 1d f3 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800e70:	b8 02 00 00 00       	mov    $0x2,%eax
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	89 d3                	mov    %edx,%ebx
  800e79:	89 d7                	mov    %edx,%edi
  800e7b:	89 d6                	mov    %edx,%esi
  800e7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    
  800e8c:	00 00                	add    %al,(%eax)
	...

00800e90 <__udivdi3>:
  800e90:	83 ec 1c             	sub    $0x1c,%esp
  800e93:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800e97:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800e9b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800e9f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ea3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ea7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800eab:	85 ff                	test   %edi,%edi
  800ead:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800eb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eb5:	89 cd                	mov    %ecx,%ebp
  800eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ebb:	75 33                	jne    800ef0 <__udivdi3+0x60>
  800ebd:	39 f1                	cmp    %esi,%ecx
  800ebf:	77 57                	ja     800f18 <__udivdi3+0x88>
  800ec1:	85 c9                	test   %ecx,%ecx
  800ec3:	75 0b                	jne    800ed0 <__udivdi3+0x40>
  800ec5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eca:	31 d2                	xor    %edx,%edx
  800ecc:	f7 f1                	div    %ecx
  800ece:	89 c1                	mov    %eax,%ecx
  800ed0:	89 f0                	mov    %esi,%eax
  800ed2:	31 d2                	xor    %edx,%edx
  800ed4:	f7 f1                	div    %ecx
  800ed6:	89 c6                	mov    %eax,%esi
  800ed8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edc:	f7 f1                	div    %ecx
  800ede:	89 f2                	mov    %esi,%edx
  800ee0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ee4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ee8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800eec:	83 c4 1c             	add    $0x1c,%esp
  800eef:	c3                   	ret    
  800ef0:	31 d2                	xor    %edx,%edx
  800ef2:	31 c0                	xor    %eax,%eax
  800ef4:	39 f7                	cmp    %esi,%edi
  800ef6:	77 e8                	ja     800ee0 <__udivdi3+0x50>
  800ef8:	0f bd cf             	bsr    %edi,%ecx
  800efb:	83 f1 1f             	xor    $0x1f,%ecx
  800efe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f02:	75 2c                	jne    800f30 <__udivdi3+0xa0>
  800f04:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f08:	76 04                	jbe    800f0e <__udivdi3+0x7e>
  800f0a:	39 f7                	cmp    %esi,%edi
  800f0c:	73 d2                	jae    800ee0 <__udivdi3+0x50>
  800f0e:	31 d2                	xor    %edx,%edx
  800f10:	b8 01 00 00 00       	mov    $0x1,%eax
  800f15:	eb c9                	jmp    800ee0 <__udivdi3+0x50>
  800f17:	90                   	nop
  800f18:	89 f2                	mov    %esi,%edx
  800f1a:	f7 f1                	div    %ecx
  800f1c:	31 d2                	xor    %edx,%edx
  800f1e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f22:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f26:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	c3                   	ret    
  800f2e:	66 90                	xchg   %ax,%ax
  800f30:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f35:	b8 20 00 00 00       	mov    $0x20,%eax
  800f3a:	89 ea                	mov    %ebp,%edx
  800f3c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f40:	d3 e7                	shl    %cl,%edi
  800f42:	89 c1                	mov    %eax,%ecx
  800f44:	d3 ea                	shr    %cl,%edx
  800f46:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f4b:	09 fa                	or     %edi,%edx
  800f4d:	89 f7                	mov    %esi,%edi
  800f4f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f53:	89 f2                	mov    %esi,%edx
  800f55:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f59:	d3 e5                	shl    %cl,%ebp
  800f5b:	89 c1                	mov    %eax,%ecx
  800f5d:	d3 ef                	shr    %cl,%edi
  800f5f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f64:	d3 e2                	shl    %cl,%edx
  800f66:	89 c1                	mov    %eax,%ecx
  800f68:	d3 ee                	shr    %cl,%esi
  800f6a:	09 d6                	or     %edx,%esi
  800f6c:	89 fa                	mov    %edi,%edx
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	f7 74 24 0c          	divl   0xc(%esp)
  800f74:	89 d7                	mov    %edx,%edi
  800f76:	89 c6                	mov    %eax,%esi
  800f78:	f7 e5                	mul    %ebp
  800f7a:	39 d7                	cmp    %edx,%edi
  800f7c:	72 22                	jb     800fa0 <__udivdi3+0x110>
  800f7e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800f82:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f87:	d3 e5                	shl    %cl,%ebp
  800f89:	39 c5                	cmp    %eax,%ebp
  800f8b:	73 04                	jae    800f91 <__udivdi3+0x101>
  800f8d:	39 d7                	cmp    %edx,%edi
  800f8f:	74 0f                	je     800fa0 <__udivdi3+0x110>
  800f91:	89 f0                	mov    %esi,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	e9 46 ff ff ff       	jmp    800ee0 <__udivdi3+0x50>
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fad:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fb1:	83 c4 1c             	add    $0x1c,%esp
  800fb4:	c3                   	ret    
	...

00800fc0 <__umoddi3>:
  800fc0:	83 ec 1c             	sub    $0x1c,%esp
  800fc3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fc7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800fcb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800fcf:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fd3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fd7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800fdb:	85 ed                	test   %ebp,%ebp
  800fdd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fe1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe5:	89 cf                	mov    %ecx,%edi
  800fe7:	89 04 24             	mov    %eax,(%esp)
  800fea:	89 f2                	mov    %esi,%edx
  800fec:	75 1a                	jne    801008 <__umoddi3+0x48>
  800fee:	39 f1                	cmp    %esi,%ecx
  800ff0:	76 4e                	jbe    801040 <__umoddi3+0x80>
  800ff2:	f7 f1                	div    %ecx
  800ff4:	89 d0                	mov    %edx,%eax
  800ff6:	31 d2                	xor    %edx,%edx
  800ff8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ffc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801000:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801004:	83 c4 1c             	add    $0x1c,%esp
  801007:	c3                   	ret    
  801008:	39 f5                	cmp    %esi,%ebp
  80100a:	77 54                	ja     801060 <__umoddi3+0xa0>
  80100c:	0f bd c5             	bsr    %ebp,%eax
  80100f:	83 f0 1f             	xor    $0x1f,%eax
  801012:	89 44 24 04          	mov    %eax,0x4(%esp)
  801016:	75 60                	jne    801078 <__umoddi3+0xb8>
  801018:	3b 0c 24             	cmp    (%esp),%ecx
  80101b:	0f 87 07 01 00 00    	ja     801128 <__umoddi3+0x168>
  801021:	89 f2                	mov    %esi,%edx
  801023:	8b 34 24             	mov    (%esp),%esi
  801026:	29 ce                	sub    %ecx,%esi
  801028:	19 ea                	sbb    %ebp,%edx
  80102a:	89 34 24             	mov    %esi,(%esp)
  80102d:	8b 04 24             	mov    (%esp),%eax
  801030:	8b 74 24 10          	mov    0x10(%esp),%esi
  801034:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801038:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80103c:	83 c4 1c             	add    $0x1c,%esp
  80103f:	c3                   	ret    
  801040:	85 c9                	test   %ecx,%ecx
  801042:	75 0b                	jne    80104f <__umoddi3+0x8f>
  801044:	b8 01 00 00 00       	mov    $0x1,%eax
  801049:	31 d2                	xor    %edx,%edx
  80104b:	f7 f1                	div    %ecx
  80104d:	89 c1                	mov    %eax,%ecx
  80104f:	89 f0                	mov    %esi,%eax
  801051:	31 d2                	xor    %edx,%edx
  801053:	f7 f1                	div    %ecx
  801055:	8b 04 24             	mov    (%esp),%eax
  801058:	f7 f1                	div    %ecx
  80105a:	eb 98                	jmp    800ff4 <__umoddi3+0x34>
  80105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801060:	89 f2                	mov    %esi,%edx
  801062:	8b 74 24 10          	mov    0x10(%esp),%esi
  801066:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80106a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80106e:	83 c4 1c             	add    $0x1c,%esp
  801071:	c3                   	ret    
  801072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801078:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80107d:	89 e8                	mov    %ebp,%eax
  80107f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801084:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801088:	89 fa                	mov    %edi,%edx
  80108a:	d3 e0                	shl    %cl,%eax
  80108c:	89 e9                	mov    %ebp,%ecx
  80108e:	d3 ea                	shr    %cl,%edx
  801090:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801095:	09 c2                	or     %eax,%edx
  801097:	8b 44 24 08          	mov    0x8(%esp),%eax
  80109b:	89 14 24             	mov    %edx,(%esp)
  80109e:	89 f2                	mov    %esi,%edx
  8010a0:	d3 e7                	shl    %cl,%edi
  8010a2:	89 e9                	mov    %ebp,%ecx
  8010a4:	d3 ea                	shr    %cl,%edx
  8010a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010af:	d3 e6                	shl    %cl,%esi
  8010b1:	89 e9                	mov    %ebp,%ecx
  8010b3:	d3 e8                	shr    %cl,%eax
  8010b5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ba:	09 f0                	or     %esi,%eax
  8010bc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010c0:	f7 34 24             	divl   (%esp)
  8010c3:	d3 e6                	shl    %cl,%esi
  8010c5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010c9:	89 d6                	mov    %edx,%esi
  8010cb:	f7 e7                	mul    %edi
  8010cd:	39 d6                	cmp    %edx,%esi
  8010cf:	89 c1                	mov    %eax,%ecx
  8010d1:	89 d7                	mov    %edx,%edi
  8010d3:	72 3f                	jb     801114 <__umoddi3+0x154>
  8010d5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010d9:	72 35                	jb     801110 <__umoddi3+0x150>
  8010db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010df:	29 c8                	sub    %ecx,%eax
  8010e1:	19 fe                	sbb    %edi,%esi
  8010e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010e8:	89 f2                	mov    %esi,%edx
  8010ea:	d3 e8                	shr    %cl,%eax
  8010ec:	89 e9                	mov    %ebp,%ecx
  8010ee:	d3 e2                	shl    %cl,%edx
  8010f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f5:	09 d0                	or     %edx,%eax
  8010f7:	89 f2                	mov    %esi,%edx
  8010f9:	d3 ea                	shr    %cl,%edx
  8010fb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010ff:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801103:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801107:	83 c4 1c             	add    $0x1c,%esp
  80110a:	c3                   	ret    
  80110b:	90                   	nop
  80110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801110:	39 d6                	cmp    %edx,%esi
  801112:	75 c7                	jne    8010db <__umoddi3+0x11b>
  801114:	89 d7                	mov    %edx,%edi
  801116:	89 c1                	mov    %eax,%ecx
  801118:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80111c:	1b 3c 24             	sbb    (%esp),%edi
  80111f:	eb ba                	jmp    8010db <__umoddi3+0x11b>
  801121:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801128:	39 f5                	cmp    %esi,%ebp
  80112a:	0f 82 f1 fe ff ff    	jb     801021 <__umoddi3+0x61>
  801130:	e9 f8 fe ff ff       	jmp    80102d <__umoddi3+0x6d>
