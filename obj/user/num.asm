
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800043:	8d 5d e7             	lea    -0x19(%ebp),%ebx
  800046:	e9 81 00 00 00       	jmp    8000cc <num+0x98>
		if (bol) {
  80004b:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  800052:	74 27                	je     80007b <num+0x47>
			printf("%5d ", ++line);
  800054:	a1 00 40 80 00       	mov    0x804000,%eax
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	a3 00 40 80 00       	mov    %eax,0x804000
  800061:	89 44 24 04          	mov    %eax,0x4(%esp)
  800065:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80006c:	e8 78 1b 00 00       	call   801be9 <printf>
			bol = 0;
  800071:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800078:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  80007b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800082:	00 
  800083:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800087:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80008e:	e8 2b 16 00 00       	call   8016be <write>
  800093:	83 f8 01             	cmp    $0x1,%eax
  800096:	74 24                	je     8000bc <num+0x88>
			panic("write error copying %s: %e", s, r);
  800098:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000a0:	c7 44 24 08 c5 25 80 	movl   $0x8025c5,0x8(%esp)
  8000a7:	00 
  8000a8:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000af:	00 
  8000b0:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  8000b7:	e8 7c 01 00 00       	call   800238 <_panic>
		if (c == '\n')
  8000bc:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8000c0:	75 0a                	jne    8000cc <num+0x98>
			bol = 1;
  8000c2:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c9:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d3:	00 
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 fe 14 00 00       	call   8015de <read>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	0f 8f 63 ff ff ff    	jg     80004b <num+0x17>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	79 24                	jns    800110 <num+0xdc>
		panic("error reading %s: %e", s, n);
  8000ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000f4:	c7 44 24 08 eb 25 80 	movl   $0x8025eb,0x8(%esp)
  8000fb:	00 
  8000fc:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  800103:	00 
  800104:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  80010b:	e8 28 01 00 00       	call   800238 <_panic>
}
  800110:	83 c4 3c             	add    $0x3c,%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <umain>:

void
umain(int argc, char **argv)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 3c             	sub    $0x3c,%esp
	int f, i;

	binaryname = "num";
  800121:	c7 05 04 30 80 00 00 	movl   $0x802600,0x803004
  800128:	26 80 00 
	if (argc == 1)
  80012b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012f:	74 13                	je     800144 <umain+0x2c>
	if (n < 0)
		panic("error reading %s: %e", s, n);
}

void
umain(int argc, char **argv)
  800131:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800134:	83 c3 04             	add    $0x4,%ebx
  800137:	bf 01 00 00 00       	mov    $0x1,%edi

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80013c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800140:	7f 18                	jg     80015a <umain+0x42>
  800142:	eb 7b                	jmp    8001bf <umain+0xa7>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800144:	c7 44 24 04 04 26 80 	movl   $0x802604,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800153:	e8 dc fe ff ff       	call   800034 <num>
  800158:	eb 65                	jmp    8001bf <umain+0xa7>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80015a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80015d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800164:	00 
  800165:	8b 03                	mov    (%ebx),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 dd 18 00 00       	call   801a4c <open>
  80016f:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800171:	85 c0                	test   %eax,%eax
  800173:	79 29                	jns    80019e <umain+0x86>
				panic("can't open %s: %e", argv[i], f);
  800175:	89 44 24 10          	mov    %eax,0x10(%esp)
  800179:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80017c:	8b 02                	mov    (%edx),%eax
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	c7 44 24 08 0c 26 80 	movl   $0x80260c,0x8(%esp)
  800189:	00 
  80018a:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800191:	00 
  800192:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  800199:	e8 9a 00 00 00       	call   800238 <_panic>
			else {
				num(f, argv[i]);
  80019e:	8b 03                	mov    (%ebx),%eax
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	89 34 24             	mov    %esi,(%esp)
  8001a7:	e8 88 fe ff ff       	call   800034 <num>
				close(f);
  8001ac:	89 34 24             	mov    %esi,(%esp)
  8001af:	e8 b9 12 00 00       	call   80146d <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001b4:	83 c7 01             	add    $0x1,%edi
  8001b7:	83 c3 04             	add    $0x4,%ebx
  8001ba:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001bd:	75 9b                	jne    80015a <umain+0x42>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001bf:	e8 58 00 00 00       	call   80021c <exit>
}
  8001c4:	83 c4 3c             	add    $0x3c,%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 18             	sub    $0x18,%esp
  8001d2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001d5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001de:	e8 39 0d 00 00       	call   800f1c <sys_getenvid>
  8001e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e8:	c1 e0 07             	shl    $0x7,%eax
  8001eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f0:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f5:	85 f6                	test   %esi,%esi
  8001f7:	7e 07                	jle    800200 <libmain+0x34>
		binaryname = argv[0];
  8001f9:	8b 03                	mov    (%ebx),%eax
  8001fb:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800200:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800204:	89 34 24             	mov    %esi,(%esp)
  800207:	e8 0c ff ff ff       	call   800118 <umain>

	// exit gracefully
	exit();
  80020c:	e8 0b 00 00 00       	call   80021c <exit>
}
  800211:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800214:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800217:	89 ec                	mov    %ebp,%esp
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    
	...

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800222:	e8 77 12 00 00       	call   80149e <close_all>
	sys_env_destroy(0);
  800227:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80022e:	e8 8c 0c 00 00       	call   800ebf <sys_env_destroy>
}
  800233:	c9                   	leave  
  800234:	c3                   	ret    
  800235:	00 00                	add    %al,(%eax)
	...

00800238 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800249:	e8 ce 0c 00 00       	call   800f1c <sys_getenvid>
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 54 24 10          	mov    %edx,0x10(%esp)
  800255:	8b 55 08             	mov    0x8(%ebp),%edx
  800258:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80025c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	c7 04 24 28 26 80 00 	movl   $0x802628,(%esp)
  80026b:	e8 c3 00 00 00       	call   800333 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800270:	89 74 24 04          	mov    %esi,0x4(%esp)
  800274:	8b 45 10             	mov    0x10(%ebp),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	e8 53 00 00 00       	call   8002d2 <vcprintf>
	cprintf("\n");
  80027f:	c7 04 24 67 2a 80 00 	movl   $0x802a67,(%esp)
  800286:	e8 a8 00 00 00       	call   800333 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80028b:	cc                   	int3   
  80028c:	eb fd                	jmp    80028b <_panic+0x53>
	...

00800290 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	53                   	push   %ebx
  800294:	83 ec 14             	sub    $0x14,%esp
  800297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80029a:	8b 03                	mov    (%ebx),%eax
  80029c:	8b 55 08             	mov    0x8(%ebp),%edx
  80029f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002a3:	83 c0 01             	add    $0x1,%eax
  8002a6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ad:	75 19                	jne    8002c8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002af:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002b6:	00 
  8002b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	e8 9e 0b 00 00       	call   800e60 <sys_cputs>
		b->idx = 0;
  8002c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002cc:	83 c4 14             	add    $0x14,%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e2:	00 00 00 
	b.cnt = 0;
  8002e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800303:	89 44 24 04          	mov    %eax,0x4(%esp)
  800307:	c7 04 24 90 02 80 00 	movl   $0x800290,(%esp)
  80030e:	e8 97 01 00 00       	call   8004aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800313:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	e8 35 0b 00 00       	call   800e60 <sys_cputs>

	return b.cnt;
}
  80032b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800331:	c9                   	leave  
  800332:	c3                   	ret    

00800333 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800339:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80033c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800340:	8b 45 08             	mov    0x8(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	e8 87 ff ff ff       	call   8002d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80034b:	c9                   	leave  
  80034c:	c3                   	ret    
  80034d:	00 00                	add    %al,(%eax)
	...

00800350 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 3c             	sub    $0x3c,%esp
  800359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035c:	89 d7                	mov    %edx,%edi
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
  800367:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80036d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800370:	b8 00 00 00 00       	mov    $0x0,%eax
  800375:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800378:	72 11                	jb     80038b <printnum+0x3b>
  80037a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800380:	76 09                	jbe    80038b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800382:	83 eb 01             	sub    $0x1,%ebx
  800385:	85 db                	test   %ebx,%ebx
  800387:	7f 51                	jg     8003da <printnum+0x8a>
  800389:	eb 5e                	jmp    8003e9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80038b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80038f:	83 eb 01             	sub    $0x1,%ebx
  800392:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800396:	8b 45 10             	mov    0x10(%ebp),%eax
  800399:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003a1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ac:	00 
  8003ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ba:	e8 41 1f 00 00       	call   802300 <__udivdi3>
  8003bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ce:	89 fa                	mov    %edi,%edx
  8003d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003d3:	e8 78 ff ff ff       	call   800350 <printnum>
  8003d8:	eb 0f                	jmp    8003e9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003de:	89 34 24             	mov    %esi,(%esp)
  8003e1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e4:	83 eb 01             	sub    $0x1,%ebx
  8003e7:	75 f1                	jne    8003da <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ed:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ff:	00 
  800400:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800403:	89 04 24             	mov    %eax,(%esp)
  800406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	e8 1e 20 00 00       	call   802430 <__umoddi3>
  800412:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800416:	0f be 80 4b 26 80 00 	movsbl 0x80264b(%eax),%eax
  80041d:	89 04 24             	mov    %eax,(%esp)
  800420:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800423:	83 c4 3c             	add    $0x3c,%esp
  800426:	5b                   	pop    %ebx
  800427:	5e                   	pop    %esi
  800428:	5f                   	pop    %edi
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    

0080042b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042e:	83 fa 01             	cmp    $0x1,%edx
  800431:	7e 0e                	jle    800441 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800433:	8b 10                	mov    (%eax),%edx
  800435:	8d 4a 08             	lea    0x8(%edx),%ecx
  800438:	89 08                	mov    %ecx,(%eax)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	8b 52 04             	mov    0x4(%edx),%edx
  80043f:	eb 22                	jmp    800463 <getuint+0x38>
	else if (lflag)
  800441:	85 d2                	test   %edx,%edx
  800443:	74 10                	je     800455 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800445:	8b 10                	mov    (%eax),%edx
  800447:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044a:	89 08                	mov    %ecx,(%eax)
  80044c:	8b 02                	mov    (%edx),%eax
  80044e:	ba 00 00 00 00       	mov    $0x0,%edx
  800453:	eb 0e                	jmp    800463 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800455:	8b 10                	mov    (%eax),%edx
  800457:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045a:	89 08                	mov    %ecx,(%eax)
  80045c:	8b 02                	mov    (%edx),%eax
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800463:	5d                   	pop    %ebp
  800464:	c3                   	ret    

00800465 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80046f:	8b 10                	mov    (%eax),%edx
  800471:	3b 50 04             	cmp    0x4(%eax),%edx
  800474:	73 0a                	jae    800480 <sprintputch+0x1b>
		*b->buf++ = ch;
  800476:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800479:	88 0a                	mov    %cl,(%edx)
  80047b:	83 c2 01             	add    $0x1,%edx
  80047e:	89 10                	mov    %edx,(%eax)
}
  800480:	5d                   	pop    %ebp
  800481:	c3                   	ret    

00800482 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800488:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048f:	8b 45 10             	mov    0x10(%ebp),%eax
  800492:	89 44 24 08          	mov    %eax,0x8(%esp)
  800496:	8b 45 0c             	mov    0xc(%ebp),%eax
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 02 00 00 00       	call   8004aa <vprintfmt>
	va_end(ap);
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	57                   	push   %edi
  8004ae:	56                   	push   %esi
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 5c             	sub    $0x5c,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b6:	8b 75 10             	mov    0x10(%ebp),%esi
  8004b9:	eb 12                	jmp    8004cd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	0f 84 e4 04 00 00    	je     8009a7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8004c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cd:	0f b6 06             	movzbl (%esi),%eax
  8004d0:	83 c6 01             	add    $0x1,%esi
  8004d3:	83 f8 25             	cmp    $0x25,%eax
  8004d6:	75 e3                	jne    8004bb <vprintfmt+0x11>
  8004d8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8004dc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8004e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004e8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004f7:	eb 2b                	jmp    800524 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fc:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800500:	eb 22                	jmp    800524 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800505:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800509:	eb 19                	jmp    800524 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80050e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800515:	eb 0d                	jmp    800524 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800517:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80051a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80051d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	0f b6 06             	movzbl (%esi),%eax
  800527:	0f b6 d0             	movzbl %al,%edx
  80052a:	8d 7e 01             	lea    0x1(%esi),%edi
  80052d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800530:	83 e8 23             	sub    $0x23,%eax
  800533:	3c 55                	cmp    $0x55,%al
  800535:	0f 87 46 04 00 00    	ja     800981 <vprintfmt+0x4d7>
  80053b:	0f b6 c0             	movzbl %al,%eax
  80053e:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800545:	83 ea 30             	sub    $0x30,%edx
  800548:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80054b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80054f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800555:	83 fa 09             	cmp    $0x9,%edx
  800558:	77 4a                	ja     8005a4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80055d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800560:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800563:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800567:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80056a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80056d:	83 fa 09             	cmp    $0x9,%edx
  800570:	76 eb                	jbe    80055d <vprintfmt+0xb3>
  800572:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800575:	eb 2d                	jmp    8005a4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800588:	eb 1a                	jmp    8005a4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80058d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800591:	79 91                	jns    800524 <vprintfmt+0x7a>
  800593:	e9 73 ff ff ff       	jmp    80050b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8005a2:	eb 80                	jmp    800524 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8005a4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005a8:	0f 89 76 ff ff ff    	jns    800524 <vprintfmt+0x7a>
  8005ae:	e9 64 ff ff ff       	jmp    800517 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005b9:	e9 66 ff ff ff       	jmp    800524 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 04 24             	mov    %eax,(%esp)
  8005d0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005d6:	e9 f2 fe ff ff       	jmp    8004cd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8005db:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8005df:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8005e2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8005e6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8005e9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8005ed:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8005f0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8005f3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8005f7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005fa:	80 f9 09             	cmp    $0x9,%cl
  8005fd:	77 1d                	ja     80061c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8005ff:	0f be c0             	movsbl %al,%eax
  800602:	6b c0 64             	imul   $0x64,%eax,%eax
  800605:	0f be d2             	movsbl %dl,%edx
  800608:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80060b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800612:	a3 08 30 80 00       	mov    %eax,0x803008
  800617:	e9 b1 fe ff ff       	jmp    8004cd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80061c:	c7 44 24 04 63 26 80 	movl   $0x802663,0x4(%esp)
  800623:	00 
  800624:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 0c 05 00 00       	call   800b3b <strcmp>
  80062f:	85 c0                	test   %eax,%eax
  800631:	75 0f                	jne    800642 <vprintfmt+0x198>
  800633:	c7 05 08 30 80 00 04 	movl   $0x4,0x803008
  80063a:	00 00 00 
  80063d:	e9 8b fe ff ff       	jmp    8004cd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800642:	c7 44 24 04 67 26 80 	movl   $0x802667,0x4(%esp)
  800649:	00 
  80064a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80064d:	89 14 24             	mov    %edx,(%esp)
  800650:	e8 e6 04 00 00       	call   800b3b <strcmp>
  800655:	85 c0                	test   %eax,%eax
  800657:	75 0f                	jne    800668 <vprintfmt+0x1be>
  800659:	c7 05 08 30 80 00 02 	movl   $0x2,0x803008
  800660:	00 00 00 
  800663:	e9 65 fe ff ff       	jmp    8004cd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800668:	c7 44 24 04 6b 26 80 	movl   $0x80266b,0x4(%esp)
  80066f:	00 
  800670:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800673:	89 0c 24             	mov    %ecx,(%esp)
  800676:	e8 c0 04 00 00       	call   800b3b <strcmp>
  80067b:	85 c0                	test   %eax,%eax
  80067d:	75 0f                	jne    80068e <vprintfmt+0x1e4>
  80067f:	c7 05 08 30 80 00 01 	movl   $0x1,0x803008
  800686:	00 00 00 
  800689:	e9 3f fe ff ff       	jmp    8004cd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80068e:	c7 44 24 04 6f 26 80 	movl   $0x80266f,0x4(%esp)
  800695:	00 
  800696:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800699:	89 3c 24             	mov    %edi,(%esp)
  80069c:	e8 9a 04 00 00       	call   800b3b <strcmp>
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	75 0f                	jne    8006b4 <vprintfmt+0x20a>
  8006a5:	c7 05 08 30 80 00 06 	movl   $0x6,0x803008
  8006ac:	00 00 00 
  8006af:	e9 19 fe ff ff       	jmp    8004cd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8006b4:	c7 44 24 04 73 26 80 	movl   $0x802673,0x4(%esp)
  8006bb:	00 
  8006bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006bf:	89 04 24             	mov    %eax,(%esp)
  8006c2:	e8 74 04 00 00       	call   800b3b <strcmp>
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	75 0f                	jne    8006da <vprintfmt+0x230>
  8006cb:	c7 05 08 30 80 00 07 	movl   $0x7,0x803008
  8006d2:	00 00 00 
  8006d5:	e9 f3 fd ff ff       	jmp    8004cd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8006da:	c7 44 24 04 77 26 80 	movl   $0x802677,0x4(%esp)
  8006e1:	00 
  8006e2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006e5:	89 14 24             	mov    %edx,(%esp)
  8006e8:	e8 4e 04 00 00       	call   800b3b <strcmp>
  8006ed:	83 f8 01             	cmp    $0x1,%eax
  8006f0:	19 c0                	sbb    %eax,%eax
  8006f2:	f7 d0                	not    %eax
  8006f4:	83 c0 08             	add    $0x8,%eax
  8006f7:	a3 08 30 80 00       	mov    %eax,0x803008
  8006fc:	e9 cc fd ff ff       	jmp    8004cd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 c2                	mov    %eax,%edx
  80070e:	c1 fa 1f             	sar    $0x1f,%edx
  800711:	31 d0                	xor    %edx,%eax
  800713:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800715:	83 f8 0f             	cmp    $0xf,%eax
  800718:	7f 0b                	jg     800725 <vprintfmt+0x27b>
  80071a:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  800721:	85 d2                	test   %edx,%edx
  800723:	75 23                	jne    800748 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800725:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800729:	c7 44 24 08 7b 26 80 	movl   $0x80267b,0x8(%esp)
  800730:	00 
  800731:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800735:	8b 7d 08             	mov    0x8(%ebp),%edi
  800738:	89 3c 24             	mov    %edi,(%esp)
  80073b:	e8 42 fd ff ff       	call   800482 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800740:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800743:	e9 85 fd ff ff       	jmp    8004cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800748:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074c:	c7 44 24 08 35 2a 80 	movl   $0x802a35,0x8(%esp)
  800753:	00 
  800754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800758:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075b:	89 3c 24             	mov    %edi,(%esp)
  80075e:	e8 1f fd ff ff       	call   800482 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800766:	e9 62 fd ff ff       	jmp    8004cd <vprintfmt+0x23>
  80076b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80076e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800771:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)
  80077d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80077f:	85 f6                	test   %esi,%esi
  800781:	b8 5c 26 80 00       	mov    $0x80265c,%eax
  800786:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800789:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80078d:	7e 06                	jle    800795 <vprintfmt+0x2eb>
  80078f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800793:	75 13                	jne    8007a8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800795:	0f be 06             	movsbl (%esi),%eax
  800798:	83 c6 01             	add    $0x1,%esi
  80079b:	85 c0                	test   %eax,%eax
  80079d:	0f 85 94 00 00 00    	jne    800837 <vprintfmt+0x38d>
  8007a3:	e9 81 00 00 00       	jmp    800829 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ac:	89 34 24             	mov    %esi,(%esp)
  8007af:	e8 97 02 00 00       	call   800a4b <strnlen>
  8007b4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8007b7:	29 c2                	sub    %eax,%edx
  8007b9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	7e d5                	jle    800795 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8007c0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007c4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8007c7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8007ca:	89 d6                	mov    %edx,%esi
  8007cc:	89 cf                	mov    %ecx,%edi
  8007ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d2:	89 3c 24             	mov    %edi,(%esp)
  8007d5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d8:	83 ee 01             	sub    $0x1,%esi
  8007db:	75 f1                	jne    8007ce <vprintfmt+0x324>
  8007dd:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8007e0:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8007e3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8007e6:	eb ad                	jmp    800795 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007e8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8007ec:	74 1b                	je     800809 <vprintfmt+0x35f>
  8007ee:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007f1:	83 fa 5e             	cmp    $0x5e,%edx
  8007f4:	76 13                	jbe    800809 <vprintfmt+0x35f>
					putch('?', putdat);
  8007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800804:	ff 55 08             	call   *0x8(%ebp)
  800807:	eb 0d                	jmp    800816 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800809:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80080c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800810:	89 04 24             	mov    %eax,(%esp)
  800813:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800816:	83 eb 01             	sub    $0x1,%ebx
  800819:	0f be 06             	movsbl (%esi),%eax
  80081c:	83 c6 01             	add    $0x1,%esi
  80081f:	85 c0                	test   %eax,%eax
  800821:	75 1a                	jne    80083d <vprintfmt+0x393>
  800823:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800826:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800829:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800830:	7f 1c                	jg     80084e <vprintfmt+0x3a4>
  800832:	e9 96 fc ff ff       	jmp    8004cd <vprintfmt+0x23>
  800837:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80083a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80083d:	85 ff                	test   %edi,%edi
  80083f:	78 a7                	js     8007e8 <vprintfmt+0x33e>
  800841:	83 ef 01             	sub    $0x1,%edi
  800844:	79 a2                	jns    8007e8 <vprintfmt+0x33e>
  800846:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800849:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80084c:	eb db                	jmp    800829 <vprintfmt+0x37f>
  80084e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800851:	89 de                	mov    %ebx,%esi
  800853:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800856:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800861:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800863:	83 eb 01             	sub    $0x1,%ebx
  800866:	75 ee                	jne    800856 <vprintfmt+0x3ac>
  800868:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80086d:	e9 5b fc ff ff       	jmp    8004cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800872:	83 f9 01             	cmp    $0x1,%ecx
  800875:	7e 10                	jle    800887 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8d 50 08             	lea    0x8(%eax),%edx
  80087d:	89 55 14             	mov    %edx,0x14(%ebp)
  800880:	8b 30                	mov    (%eax),%esi
  800882:	8b 78 04             	mov    0x4(%eax),%edi
  800885:	eb 26                	jmp    8008ad <vprintfmt+0x403>
	else if (lflag)
  800887:	85 c9                	test   %ecx,%ecx
  800889:	74 12                	je     80089d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80088b:	8b 45 14             	mov    0x14(%ebp),%eax
  80088e:	8d 50 04             	lea    0x4(%eax),%edx
  800891:	89 55 14             	mov    %edx,0x14(%ebp)
  800894:	8b 30                	mov    (%eax),%esi
  800896:	89 f7                	mov    %esi,%edi
  800898:	c1 ff 1f             	sar    $0x1f,%edi
  80089b:	eb 10                	jmp    8008ad <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8d 50 04             	lea    0x4(%eax),%edx
  8008a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a6:	8b 30                	mov    (%eax),%esi
  8008a8:	89 f7                	mov    %esi,%edi
  8008aa:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008ad:	85 ff                	test   %edi,%edi
  8008af:	78 0e                	js     8008bf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008b1:	89 f0                	mov    %esi,%eax
  8008b3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008b5:	be 0a 00 00 00       	mov    $0xa,%esi
  8008ba:	e9 84 00 00 00       	jmp    800943 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008ca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008cd:	89 f0                	mov    %esi,%eax
  8008cf:	89 fa                	mov    %edi,%edx
  8008d1:	f7 d8                	neg    %eax
  8008d3:	83 d2 00             	adc    $0x0,%edx
  8008d6:	f7 da                	neg    %edx
			}
			base = 10;
  8008d8:	be 0a 00 00 00       	mov    $0xa,%esi
  8008dd:	eb 64                	jmp    800943 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008df:	89 ca                	mov    %ecx,%edx
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e4:	e8 42 fb ff ff       	call   80042b <getuint>
			base = 10;
  8008e9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008ee:	eb 53                	jmp    800943 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008f0:	89 ca                	mov    %ecx,%edx
  8008f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f5:	e8 31 fb ff ff       	call   80042b <getuint>
    			base = 8;
  8008fa:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8008ff:	eb 42                	jmp    800943 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800901:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800905:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80090c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80090f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800913:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80091a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80091d:	8b 45 14             	mov    0x14(%ebp),%eax
  800920:	8d 50 04             	lea    0x4(%eax),%edx
  800923:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800926:	8b 00                	mov    (%eax),%eax
  800928:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80092d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800932:	eb 0f                	jmp    800943 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800934:	89 ca                	mov    %ecx,%edx
  800936:	8d 45 14             	lea    0x14(%ebp),%eax
  800939:	e8 ed fa ff ff       	call   80042b <getuint>
			base = 16;
  80093e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800943:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800947:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80094b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80094e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800952:	89 74 24 08          	mov    %esi,0x8(%esp)
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095d:	89 da                	mov    %ebx,%edx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	e8 e9 f9 ff ff       	call   800350 <printnum>
			break;
  800967:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80096a:	e9 5e fb ff ff       	jmp    8004cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80096f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800973:	89 14 24             	mov    %edx,(%esp)
  800976:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800979:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80097c:	e9 4c fb ff ff       	jmp    8004cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800981:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800985:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80098c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80098f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800993:	0f 84 34 fb ff ff    	je     8004cd <vprintfmt+0x23>
  800999:	83 ee 01             	sub    $0x1,%esi
  80099c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009a0:	75 f7                	jne    800999 <vprintfmt+0x4ef>
  8009a2:	e9 26 fb ff ff       	jmp    8004cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009a7:	83 c4 5c             	add    $0x5c,%esp
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	83 ec 28             	sub    $0x28,%esp
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009cc:	85 c0                	test   %eax,%eax
  8009ce:	74 30                	je     800a00 <vsnprintf+0x51>
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	7e 2c                	jle    800a00 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009db:	8b 45 10             	mov    0x10(%ebp),%eax
  8009de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e9:	c7 04 24 65 04 80 00 	movl   $0x800465,(%esp)
  8009f0:	e8 b5 fa ff ff       	call   8004aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fe:	eb 05                	jmp    800a05 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
  800a17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	89 04 24             	mov    %eax,(%esp)
  800a28:	e8 82 ff ff ff       	call   8009af <vsnprintf>
	va_end(ap);

	return rc;
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    
	...

00800a30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a3e:	74 09                	je     800a49 <strlen+0x19>
		n++;
  800a40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a47:	75 f7                	jne    800a40 <strlen+0x10>
		n++;
	return n;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	85 c9                	test   %ecx,%ecx
  800a5c:	74 1a                	je     800a78 <strnlen+0x2d>
  800a5e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a61:	74 15                	je     800a78 <strnlen+0x2d>
  800a63:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a68:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6a:	39 ca                	cmp    %ecx,%edx
  800a6c:	74 0a                	je     800a78 <strnlen+0x2d>
  800a6e:	83 c2 01             	add    $0x1,%edx
  800a71:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a76:	75 f0                	jne    800a68 <strnlen+0x1d>
		n++;
	return n;
}
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a8e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a91:	83 c2 01             	add    $0x1,%edx
  800a94:	84 c9                	test   %cl,%cl
  800a96:	75 f2                	jne    800a8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	83 ec 08             	sub    $0x8,%esp
  800aa2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa5:	89 1c 24             	mov    %ebx,(%esp)
  800aa8:	e8 83 ff ff ff       	call   800a30 <strlen>
	strcpy(dst + len, src);
  800aad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab4:	01 d8                	add    %ebx,%eax
  800ab6:	89 04 24             	mov    %eax,(%esp)
  800ab9:	e8 bd ff ff ff       	call   800a7b <strcpy>
	return dst;
}
  800abe:	89 d8                	mov    %ebx,%eax
  800ac0:	83 c4 08             	add    $0x8,%esp
  800ac3:	5b                   	pop    %ebx
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad4:	85 f6                	test   %esi,%esi
  800ad6:	74 18                	je     800af0 <strncpy+0x2a>
  800ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800add:	0f b6 1a             	movzbl (%edx),%ebx
  800ae0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ae6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	39 f1                	cmp    %esi,%ecx
  800aee:	75 ed                	jne    800add <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b00:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b03:	89 f8                	mov    %edi,%eax
  800b05:	85 f6                	test   %esi,%esi
  800b07:	74 2b                	je     800b34 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b09:	83 fe 01             	cmp    $0x1,%esi
  800b0c:	74 23                	je     800b31 <strlcpy+0x3d>
  800b0e:	0f b6 0b             	movzbl (%ebx),%ecx
  800b11:	84 c9                	test   %cl,%cl
  800b13:	74 1c                	je     800b31 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b15:	83 ee 02             	sub    $0x2,%esi
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b1d:	88 08                	mov    %cl,(%eax)
  800b1f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b22:	39 f2                	cmp    %esi,%edx
  800b24:	74 0b                	je     800b31 <strlcpy+0x3d>
  800b26:	83 c2 01             	add    $0x1,%edx
  800b29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b2d:	84 c9                	test   %cl,%cl
  800b2f:	75 ec                	jne    800b1d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800b31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b34:	29 f8                	sub    %edi,%eax
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b41:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b44:	0f b6 01             	movzbl (%ecx),%eax
  800b47:	84 c0                	test   %al,%al
  800b49:	74 16                	je     800b61 <strcmp+0x26>
  800b4b:	3a 02                	cmp    (%edx),%al
  800b4d:	75 12                	jne    800b61 <strcmp+0x26>
		p++, q++;
  800b4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b52:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800b56:	84 c0                	test   %al,%al
  800b58:	74 07                	je     800b61 <strcmp+0x26>
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	3a 02                	cmp    (%edx),%al
  800b5f:	74 ee                	je     800b4f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b61:	0f b6 c0             	movzbl %al,%eax
  800b64:	0f b6 12             	movzbl (%edx),%edx
  800b67:	29 d0                	sub    %edx,%eax
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	53                   	push   %ebx
  800b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b75:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b7d:	85 d2                	test   %edx,%edx
  800b7f:	74 28                	je     800ba9 <strncmp+0x3e>
  800b81:	0f b6 01             	movzbl (%ecx),%eax
  800b84:	84 c0                	test   %al,%al
  800b86:	74 24                	je     800bac <strncmp+0x41>
  800b88:	3a 03                	cmp    (%ebx),%al
  800b8a:	75 20                	jne    800bac <strncmp+0x41>
  800b8c:	83 ea 01             	sub    $0x1,%edx
  800b8f:	74 13                	je     800ba4 <strncmp+0x39>
		n--, p++, q++;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b97:	0f b6 01             	movzbl (%ecx),%eax
  800b9a:	84 c0                	test   %al,%al
  800b9c:	74 0e                	je     800bac <strncmp+0x41>
  800b9e:	3a 03                	cmp    (%ebx),%al
  800ba0:	74 ea                	je     800b8c <strncmp+0x21>
  800ba2:	eb 08                	jmp    800bac <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bac:	0f b6 01             	movzbl (%ecx),%eax
  800baf:	0f b6 13             	movzbl (%ebx),%edx
  800bb2:	29 d0                	sub    %edx,%eax
  800bb4:	eb f3                	jmp    800ba9 <strncmp+0x3e>

00800bb6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc0:	0f b6 10             	movzbl (%eax),%edx
  800bc3:	84 d2                	test   %dl,%dl
  800bc5:	74 1c                	je     800be3 <strchr+0x2d>
		if (*s == c)
  800bc7:	38 ca                	cmp    %cl,%dl
  800bc9:	75 09                	jne    800bd4 <strchr+0x1e>
  800bcb:	eb 1b                	jmp    800be8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bcd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800bd0:	38 ca                	cmp    %cl,%dl
  800bd2:	74 14                	je     800be8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bd4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	75 f1                	jne    800bcd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	eb 05                	jmp    800be8 <strchr+0x32>
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bf4:	0f b6 10             	movzbl (%eax),%edx
  800bf7:	84 d2                	test   %dl,%dl
  800bf9:	74 14                	je     800c0f <strfind+0x25>
		if (*s == c)
  800bfb:	38 ca                	cmp    %cl,%dl
  800bfd:	75 06                	jne    800c05 <strfind+0x1b>
  800bff:	eb 0e                	jmp    800c0f <strfind+0x25>
  800c01:	38 ca                	cmp    %cl,%dl
  800c03:	74 0a                	je     800c0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	0f b6 10             	movzbl (%eax),%edx
  800c0b:	84 d2                	test   %dl,%dl
  800c0d:	75 f2                	jne    800c01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c29:	85 c9                	test   %ecx,%ecx
  800c2b:	74 30                	je     800c5d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c33:	75 25                	jne    800c5a <memset+0x49>
  800c35:	f6 c1 03             	test   $0x3,%cl
  800c38:	75 20                	jne    800c5a <memset+0x49>
		c &= 0xFF;
  800c3a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c3d:	89 d3                	mov    %edx,%ebx
  800c3f:	c1 e3 08             	shl    $0x8,%ebx
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	c1 e6 18             	shl    $0x18,%esi
  800c47:	89 d0                	mov    %edx,%eax
  800c49:	c1 e0 10             	shl    $0x10,%eax
  800c4c:	09 f0                	or     %esi,%eax
  800c4e:	09 d0                	or     %edx,%eax
  800c50:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c52:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c55:	fc                   	cld    
  800c56:	f3 ab                	rep stos %eax,%es:(%edi)
  800c58:	eb 03                	jmp    800c5d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c5a:	fc                   	cld    
  800c5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c5d:	89 f8                	mov    %edi,%eax
  800c5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c68:	89 ec                	mov    %ebp,%esp
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 08             	sub    $0x8,%esp
  800c72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c75:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c81:	39 c6                	cmp    %eax,%esi
  800c83:	73 36                	jae    800cbb <memmove+0x4f>
  800c85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c88:	39 d0                	cmp    %edx,%eax
  800c8a:	73 2f                	jae    800cbb <memmove+0x4f>
		s += n;
		d += n;
  800c8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8f:	f6 c2 03             	test   $0x3,%dl
  800c92:	75 1b                	jne    800caf <memmove+0x43>
  800c94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9a:	75 13                	jne    800caf <memmove+0x43>
  800c9c:	f6 c1 03             	test   $0x3,%cl
  800c9f:	75 0e                	jne    800caf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ca1:	83 ef 04             	sub    $0x4,%edi
  800ca4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800caa:	fd                   	std    
  800cab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cad:	eb 09                	jmp    800cb8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800caf:	83 ef 01             	sub    $0x1,%edi
  800cb2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb5:	fd                   	std    
  800cb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb8:	fc                   	cld    
  800cb9:	eb 20                	jmp    800cdb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cbb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cc1:	75 13                	jne    800cd6 <memmove+0x6a>
  800cc3:	a8 03                	test   $0x3,%al
  800cc5:	75 0f                	jne    800cd6 <memmove+0x6a>
  800cc7:	f6 c1 03             	test   $0x3,%cl
  800cca:	75 0a                	jne    800cd6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ccc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ccf:	89 c7                	mov    %eax,%edi
  800cd1:	fc                   	cld    
  800cd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cd4:	eb 05                	jmp    800cdb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd6:	89 c7                	mov    %eax,%edi
  800cd8:	fc                   	cld    
  800cd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cdb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cde:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce1:	89 ec                	mov    %ebp,%esp
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ceb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	89 04 24             	mov    %eax,(%esp)
  800cff:	e8 68 ff ff ff       	call   800c6c <memmove>
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d12:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1a:	85 ff                	test   %edi,%edi
  800d1c:	74 37                	je     800d55 <memcmp+0x4f>
		if (*s1 != *s2)
  800d1e:	0f b6 03             	movzbl (%ebx),%eax
  800d21:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d24:	83 ef 01             	sub    $0x1,%edi
  800d27:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800d2c:	38 c8                	cmp    %cl,%al
  800d2e:	74 1c                	je     800d4c <memcmp+0x46>
  800d30:	eb 10                	jmp    800d42 <memcmp+0x3c>
  800d32:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d37:	83 c2 01             	add    $0x1,%edx
  800d3a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d3e:	38 c8                	cmp    %cl,%al
  800d40:	74 0a                	je     800d4c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800d42:	0f b6 c0             	movzbl %al,%eax
  800d45:	0f b6 c9             	movzbl %cl,%ecx
  800d48:	29 c8                	sub    %ecx,%eax
  800d4a:	eb 09                	jmp    800d55 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d4c:	39 fa                	cmp    %edi,%edx
  800d4e:	75 e2                	jne    800d32 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d60:	89 c2                	mov    %eax,%edx
  800d62:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d65:	39 d0                	cmp    %edx,%eax
  800d67:	73 19                	jae    800d82 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d6d:	38 08                	cmp    %cl,(%eax)
  800d6f:	75 06                	jne    800d77 <memfind+0x1d>
  800d71:	eb 0f                	jmp    800d82 <memfind+0x28>
  800d73:	38 08                	cmp    %cl,(%eax)
  800d75:	74 0b                	je     800d82 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d77:	83 c0 01             	add    $0x1,%eax
  800d7a:	39 d0                	cmp    %edx,%eax
  800d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d80:	75 f1                	jne    800d73 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d90:	0f b6 02             	movzbl (%edx),%eax
  800d93:	3c 20                	cmp    $0x20,%al
  800d95:	74 04                	je     800d9b <strtol+0x17>
  800d97:	3c 09                	cmp    $0x9,%al
  800d99:	75 0e                	jne    800da9 <strtol+0x25>
		s++;
  800d9b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9e:	0f b6 02             	movzbl (%edx),%eax
  800da1:	3c 20                	cmp    $0x20,%al
  800da3:	74 f6                	je     800d9b <strtol+0x17>
  800da5:	3c 09                	cmp    $0x9,%al
  800da7:	74 f2                	je     800d9b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da9:	3c 2b                	cmp    $0x2b,%al
  800dab:	75 0a                	jne    800db7 <strtol+0x33>
		s++;
  800dad:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800db0:	bf 00 00 00 00       	mov    $0x0,%edi
  800db5:	eb 10                	jmp    800dc7 <strtol+0x43>
  800db7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dbc:	3c 2d                	cmp    $0x2d,%al
  800dbe:	75 07                	jne    800dc7 <strtol+0x43>
		s++, neg = 1;
  800dc0:	83 c2 01             	add    $0x1,%edx
  800dc3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc7:	85 db                	test   %ebx,%ebx
  800dc9:	0f 94 c0             	sete   %al
  800dcc:	74 05                	je     800dd3 <strtol+0x4f>
  800dce:	83 fb 10             	cmp    $0x10,%ebx
  800dd1:	75 15                	jne    800de8 <strtol+0x64>
  800dd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dd6:	75 10                	jne    800de8 <strtol+0x64>
  800dd8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ddc:	75 0a                	jne    800de8 <strtol+0x64>
		s += 2, base = 16;
  800dde:	83 c2 02             	add    $0x2,%edx
  800de1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800de6:	eb 13                	jmp    800dfb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800de8:	84 c0                	test   %al,%al
  800dea:	74 0f                	je     800dfb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800df1:	80 3a 30             	cmpb   $0x30,(%edx)
  800df4:	75 05                	jne    800dfb <strtol+0x77>
		s++, base = 8;
  800df6:	83 c2 01             	add    $0x1,%edx
  800df9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800dfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800e00:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e02:	0f b6 0a             	movzbl (%edx),%ecx
  800e05:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e08:	80 fb 09             	cmp    $0x9,%bl
  800e0b:	77 08                	ja     800e15 <strtol+0x91>
			dig = *s - '0';
  800e0d:	0f be c9             	movsbl %cl,%ecx
  800e10:	83 e9 30             	sub    $0x30,%ecx
  800e13:	eb 1e                	jmp    800e33 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800e15:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e18:	80 fb 19             	cmp    $0x19,%bl
  800e1b:	77 08                	ja     800e25 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800e1d:	0f be c9             	movsbl %cl,%ecx
  800e20:	83 e9 57             	sub    $0x57,%ecx
  800e23:	eb 0e                	jmp    800e33 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800e25:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e28:	80 fb 19             	cmp    $0x19,%bl
  800e2b:	77 14                	ja     800e41 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e2d:	0f be c9             	movsbl %cl,%ecx
  800e30:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e33:	39 f1                	cmp    %esi,%ecx
  800e35:	7d 0e                	jge    800e45 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e37:	83 c2 01             	add    $0x1,%edx
  800e3a:	0f af c6             	imul   %esi,%eax
  800e3d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e3f:	eb c1                	jmp    800e02 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e41:	89 c1                	mov    %eax,%ecx
  800e43:	eb 02                	jmp    800e47 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e45:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e4b:	74 05                	je     800e52 <strtol+0xce>
		*endptr = (char *) s;
  800e4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e50:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e52:	89 ca                	mov    %ecx,%edx
  800e54:	f7 da                	neg    %edx
  800e56:	85 ff                	test   %edi,%edi
  800e58:	0f 45 c2             	cmovne %edx,%eax
}
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 c7                	mov    %eax,%edi
  800e7e:	89 c6                	mov    %eax,%esi
  800e80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8b:	89 ec                	mov    %ebp,%esp
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea8:	89 d1                	mov    %edx,%ecx
  800eaa:	89 d3                	mov    %edx,%ebx
  800eac:	89 d7                	mov    %edx,%edi
  800eae:	89 d6                	mov    %edx,%esi
  800eb0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebb:	89 ec                	mov    %ebp,%esp
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 38             	sub    $0x38,%esp
  800ec5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ece:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed8:	8b 55 08             	mov    0x8(%ebp),%edx
  800edb:	89 cb                	mov    %ecx,%ebx
  800edd:	89 cf                	mov    %ecx,%edi
  800edf:	89 ce                	mov    %ecx,%esi
  800ee1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f0a:	e8 29 f3 ff ff       	call   800238 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 0c             	sub    $0xc,%esp
  800f22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f30:	b8 02 00 00 00       	mov    $0x2,%eax
  800f35:	89 d1                	mov    %edx,%ecx
  800f37:	89 d3                	mov    %edx,%ebx
  800f39:	89 d7                	mov    %edx,%edi
  800f3b:	89 d6                	mov    %edx,%esi
  800f3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f48:	89 ec                	mov    %ebp,%esp
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_yield>:

void
sys_yield(void)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f60:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f65:	89 d1                	mov    %edx,%ecx
  800f67:	89 d3                	mov    %edx,%ebx
  800f69:	89 d7                	mov    %edx,%edi
  800f6b:	89 d6                	mov    %edx,%esi
  800f6d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f78:	89 ec                	mov    %ebp,%esp
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 38             	sub    $0x38,%esp
  800f82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8b:	be 00 00 00 00       	mov    $0x0,%esi
  800f90:	b8 04 00 00 00       	mov    $0x4,%eax
  800f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9e:	89 f7                	mov    %esi,%edi
  800fa0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	7e 28                	jle    800fce <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800faa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800fb9:	00 
  800fba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc1:	00 
  800fc2:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800fc9:	e8 6a f2 ff ff       	call   800238 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd7:	89 ec                	mov    %ebp,%esp
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 38             	sub    $0x38,%esp
  800fe1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fea:	b8 05 00 00 00       	mov    $0x5,%eax
  800fef:	8b 75 18             	mov    0x18(%ebp),%esi
  800ff2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801000:	85 c0                	test   %eax,%eax
  801002:	7e 28                	jle    80102c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801004:	89 44 24 10          	mov    %eax,0x10(%esp)
  801008:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80100f:	00 
  801010:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801017:	00 
  801018:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101f:	00 
  801020:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801027:	e8 0c f2 ff ff       	call   800238 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80102c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80102f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801032:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801035:	89 ec                	mov    %ebp,%esp
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 38             	sub    $0x38,%esp
  80103f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801042:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801045:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801048:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104d:	b8 06 00 00 00       	mov    $0x6,%eax
  801052:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801055:	8b 55 08             	mov    0x8(%ebp),%edx
  801058:	89 df                	mov    %ebx,%edi
  80105a:	89 de                	mov    %ebx,%esi
  80105c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80105e:	85 c0                	test   %eax,%eax
  801060:	7e 28                	jle    80108a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801062:	89 44 24 10          	mov    %eax,0x10(%esp)
  801066:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80106d:	00 
  80106e:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801085:	e8 ae f1 ff ff       	call   800238 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80108a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801090:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801093:	89 ec                	mov    %ebp,%esp
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 df                	mov    %ebx,%edi
  8010b8:	89 de                	mov    %ebx,%esi
  8010ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 28                	jle    8010e8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  8010e3:	e8 50 f1 ff ff       	call   800238 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010f1:	89 ec                	mov    %ebp,%esp
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	83 ec 38             	sub    $0x38,%esp
  8010fb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010fe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801101:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801104:	bb 00 00 00 00       	mov    $0x0,%ebx
  801109:	b8 09 00 00 00       	mov    $0x9,%eax
  80110e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801111:	8b 55 08             	mov    0x8(%ebp),%edx
  801114:	89 df                	mov    %ebx,%edi
  801116:	89 de                	mov    %ebx,%esi
  801118:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	7e 28                	jle    801146 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801122:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801129:	00 
  80112a:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801131:	00 
  801132:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801139:	00 
  80113a:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801141:	e8 f2 f0 ff ff       	call   800238 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801146:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801149:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80114c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80114f:	89 ec                	mov    %ebp,%esp
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 38             	sub    $0x38,%esp
  801159:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80115c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80115f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801162:	bb 00 00 00 00       	mov    $0x0,%ebx
  801167:	b8 0a 00 00 00       	mov    $0xa,%eax
  80116c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116f:	8b 55 08             	mov    0x8(%ebp),%edx
  801172:	89 df                	mov    %ebx,%edi
  801174:	89 de                	mov    %ebx,%esi
  801176:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801178:	85 c0                	test   %eax,%eax
  80117a:	7e 28                	jle    8011a4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801180:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801187:	00 
  801188:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  80118f:	00 
  801190:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801197:	00 
  801198:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  80119f:	e8 94 f0 ff ff       	call   800238 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ad:	89 ec                	mov    %ebp,%esp
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011bd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c0:	be 00 00 00 00       	mov    $0x0,%esi
  8011c5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e1:	89 ec                	mov    %ebp,%esp
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	83 ec 38             	sub    $0x38,%esp
  8011eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801201:	89 cb                	mov    %ecx,%ebx
  801203:	89 cf                	mov    %ecx,%edi
  801205:	89 ce                	mov    %ecx,%esi
  801207:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801209:	85 c0                	test   %eax,%eax
  80120b:	7e 28                	jle    801235 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801211:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801218:	00 
  801219:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801230:	e8 03 f0 ff ff       	call   800238 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801235:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801238:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80123b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80123e:	89 ec                	mov    %ebp,%esp
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80124b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80124e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801251:	b9 00 00 00 00       	mov    $0x0,%ecx
  801256:	b8 0e 00 00 00       	mov    $0xe,%eax
  80125b:	8b 55 08             	mov    0x8(%ebp),%edx
  80125e:	89 cb                	mov    %ecx,%ebx
  801260:	89 cf                	mov    %ecx,%edi
  801262:	89 ce                	mov    %ecx,%esi
  801264:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801266:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801269:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80126c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80126f:	89 ec                	mov    %ebp,%esp
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    
	...

00801280 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801283:	8b 45 08             	mov    0x8(%ebp),%eax
  801286:	05 00 00 00 30       	add    $0x30000000,%eax
  80128b:	c1 e8 0c             	shr    $0xc,%eax
}
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
  801299:	89 04 24             	mov    %eax,(%esp)
  80129c:	e8 df ff ff ff       	call   801280 <fd2num>
  8012a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	53                   	push   %ebx
  8012af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012b7:	a8 01                	test   $0x1,%al
  8012b9:	74 34                	je     8012ef <fd_alloc+0x44>
  8012bb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012c0:	a8 01                	test   $0x1,%al
  8012c2:	74 32                	je     8012f6 <fd_alloc+0x4b>
  8012c4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012c9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012cb:	89 c2                	mov    %eax,%edx
  8012cd:	c1 ea 16             	shr    $0x16,%edx
  8012d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d7:	f6 c2 01             	test   $0x1,%dl
  8012da:	74 1f                	je     8012fb <fd_alloc+0x50>
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	c1 ea 0c             	shr    $0xc,%edx
  8012e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e8:	f6 c2 01             	test   $0x1,%dl
  8012eb:	75 17                	jne    801304 <fd_alloc+0x59>
  8012ed:	eb 0c                	jmp    8012fb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012ef:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012f4:	eb 05                	jmp    8012fb <fd_alloc+0x50>
  8012f6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012fb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801302:	eb 17                	jmp    80131b <fd_alloc+0x70>
  801304:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801309:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130e:	75 b9                	jne    8012c9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801310:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801316:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80131b:	5b                   	pop    %ebx
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801324:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801329:	83 fa 1f             	cmp    $0x1f,%edx
  80132c:	77 3f                	ja     80136d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80132e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801334:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801337:	89 d0                	mov    %edx,%eax
  801339:	c1 e8 16             	shr    $0x16,%eax
  80133c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801343:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801348:	f6 c1 01             	test   $0x1,%cl
  80134b:	74 20                	je     80136d <fd_lookup+0x4f>
  80134d:	89 d0                	mov    %edx,%eax
  80134f:	c1 e8 0c             	shr    $0xc,%eax
  801352:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801359:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80135e:	f6 c1 01             	test   $0x1,%cl
  801361:	74 0a                	je     80136d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801363:	8b 45 0c             	mov    0xc(%ebp),%eax
  801366:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801368:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	53                   	push   %ebx
  801373:	83 ec 14             	sub    $0x14,%esp
  801376:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80137c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801381:	39 0d 0c 30 80 00    	cmp    %ecx,0x80300c
  801387:	75 17                	jne    8013a0 <dev_lookup+0x31>
  801389:	eb 07                	jmp    801392 <dev_lookup+0x23>
  80138b:	39 0a                	cmp    %ecx,(%edx)
  80138d:	75 11                	jne    8013a0 <dev_lookup+0x31>
  80138f:	90                   	nop
  801390:	eb 05                	jmp    801397 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801392:	ba 0c 30 80 00       	mov    $0x80300c,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801397:	89 13                	mov    %edx,(%ebx)
			return 0;
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
  80139e:	eb 35                	jmp    8013d5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a0:	83 c0 01             	add    $0x1,%eax
  8013a3:	8b 14 85 0c 2a 80 00 	mov    0x802a0c(,%eax,4),%edx
  8013aa:	85 d2                	test   %edx,%edx
  8013ac:	75 dd                	jne    80138b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ae:	a1 08 40 80 00       	mov    0x804008,%eax
  8013b3:	8b 40 48             	mov    0x48(%eax),%eax
  8013b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013be:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  8013c5:	e8 69 ef ff ff       	call   800333 <cprintf>
	*dev = 0;
  8013ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d5:	83 c4 14             	add    $0x14,%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	83 ec 38             	sub    $0x38,%esp
  8013e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ed:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f1:	89 3c 24             	mov    %edi,(%esp)
  8013f4:	e8 87 fe ff ff       	call   801280 <fd2num>
  8013f9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8013fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801400:	89 04 24             	mov    %eax,(%esp)
  801403:	e8 16 ff ff ff       	call   80131e <fd_lookup>
  801408:	89 c3                	mov    %eax,%ebx
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 05                	js     801413 <fd_close+0x38>
	    || fd != fd2)
  80140e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801411:	74 0e                	je     801421 <fd_close+0x46>
		return (must_exist ? r : 0);
  801413:	89 f0                	mov    %esi,%eax
  801415:	84 c0                	test   %al,%al
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
  80141c:	0f 44 d8             	cmove  %eax,%ebx
  80141f:	eb 3d                	jmp    80145e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801421:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	8b 07                	mov    (%edi),%eax
  80142a:	89 04 24             	mov    %eax,(%esp)
  80142d:	e8 3d ff ff ff       	call   80136f <dev_lookup>
  801432:	89 c3                	mov    %eax,%ebx
  801434:	85 c0                	test   %eax,%eax
  801436:	78 16                	js     80144e <fd_close+0x73>
		if (dev->dev_close)
  801438:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80143b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80143e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801443:	85 c0                	test   %eax,%eax
  801445:	74 07                	je     80144e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801447:	89 3c 24             	mov    %edi,(%esp)
  80144a:	ff d0                	call   *%eax
  80144c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80144e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801459:	e8 db fb ff ff       	call   801039 <sys_page_unmap>
	return r;
}
  80145e:	89 d8                	mov    %ebx,%eax
  801460:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801463:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801466:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801469:	89 ec                	mov    %ebp,%esp
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    

0080146d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
  80147d:	89 04 24             	mov    %eax,(%esp)
  801480:	e8 99 fe ff ff       	call   80131e <fd_lookup>
  801485:	85 c0                	test   %eax,%eax
  801487:	78 13                	js     80149c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801489:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801490:	00 
  801491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801494:	89 04 24             	mov    %eax,(%esp)
  801497:	e8 3f ff ff ff       	call   8013db <fd_close>
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <close_all>:

void
close_all(void)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014aa:	89 1c 24             	mov    %ebx,(%esp)
  8014ad:	e8 bb ff ff ff       	call   80146d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b2:	83 c3 01             	add    $0x1,%ebx
  8014b5:	83 fb 20             	cmp    $0x20,%ebx
  8014b8:	75 f0                	jne    8014aa <close_all+0xc>
		close(i);
}
  8014ba:	83 c4 14             	add    $0x14,%esp
  8014bd:	5b                   	pop    %ebx
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 58             	sub    $0x58,%esp
  8014c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	e8 3a fe ff ff       	call   80131e <fd_lookup>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	0f 88 e1 00 00 00    	js     8015cf <dup+0x10f>
		return r;
	close(newfdnum);
  8014ee:	89 3c 24             	mov    %edi,(%esp)
  8014f1:	e8 77 ff ff ff       	call   80146d <close>

	newfd = INDEX2FD(newfdnum);
  8014f6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014fc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801502:	89 04 24             	mov    %eax,(%esp)
  801505:	e8 86 fd ff ff       	call   801290 <fd2data>
  80150a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80150c:	89 34 24             	mov    %esi,(%esp)
  80150f:	e8 7c fd ff ff       	call   801290 <fd2data>
  801514:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801517:	89 d8                	mov    %ebx,%eax
  801519:	c1 e8 16             	shr    $0x16,%eax
  80151c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801523:	a8 01                	test   $0x1,%al
  801525:	74 46                	je     80156d <dup+0xad>
  801527:	89 d8                	mov    %ebx,%eax
  801529:	c1 e8 0c             	shr    $0xc,%eax
  80152c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801533:	f6 c2 01             	test   $0x1,%dl
  801536:	74 35                	je     80156d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801538:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153f:	25 07 0e 00 00       	and    $0xe07,%eax
  801544:	89 44 24 10          	mov    %eax,0x10(%esp)
  801548:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80154b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80154f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801556:	00 
  801557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80155b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801562:	e8 74 fa ff ff       	call   800fdb <sys_page_map>
  801567:	89 c3                	mov    %eax,%ebx
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 3b                	js     8015a8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801570:	89 c2                	mov    %eax,%edx
  801572:	c1 ea 0c             	shr    $0xc,%edx
  801575:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80157c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801582:	89 54 24 10          	mov    %edx,0x10(%esp)
  801586:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80158a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801591:	00 
  801592:	89 44 24 04          	mov    %eax,0x4(%esp)
  801596:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159d:	e8 39 fa ff ff       	call   800fdb <sys_page_map>
  8015a2:	89 c3                	mov    %eax,%ebx
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	79 25                	jns    8015cd <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b3:	e8 81 fa ff ff       	call   801039 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c6:	e8 6e fa ff ff       	call   801039 <sys_page_unmap>
	return r;
  8015cb:	eb 02                	jmp    8015cf <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015cd:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015cf:	89 d8                	mov    %ebx,%eax
  8015d1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015d4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015d7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015da:	89 ec                	mov    %ebp,%esp
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 24             	sub    $0x24,%esp
  8015e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ef:	89 1c 24             	mov    %ebx,(%esp)
  8015f2:	e8 27 fd ff ff       	call   80131e <fd_lookup>
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 6d                	js     801668 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801605:	8b 00                	mov    (%eax),%eax
  801607:	89 04 24             	mov    %eax,(%esp)
  80160a:	e8 60 fd ff ff       	call   80136f <dev_lookup>
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 55                	js     801668 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801616:	8b 50 08             	mov    0x8(%eax),%edx
  801619:	83 e2 03             	and    $0x3,%edx
  80161c:	83 fa 01             	cmp    $0x1,%edx
  80161f:	75 23                	jne    801644 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801621:	a1 08 40 80 00       	mov    0x804008,%eax
  801626:	8b 40 48             	mov    0x48(%eax),%eax
  801629:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80162d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801631:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  801638:	e8 f6 ec ff ff       	call   800333 <cprintf>
		return -E_INVAL;
  80163d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801642:	eb 24                	jmp    801668 <read+0x8a>
	}
	if (!dev->dev_read)
  801644:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801647:	8b 52 08             	mov    0x8(%edx),%edx
  80164a:	85 d2                	test   %edx,%edx
  80164c:	74 15                	je     801663 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80164e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801651:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801655:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801658:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80165c:	89 04 24             	mov    %eax,(%esp)
  80165f:	ff d2                	call   *%edx
  801661:	eb 05                	jmp    801668 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801663:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801668:	83 c4 24             	add    $0x24,%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	57                   	push   %edi
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
  801674:	83 ec 1c             	sub    $0x1c,%esp
  801677:	8b 7d 08             	mov    0x8(%ebp),%edi
  80167a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
  801682:	85 f6                	test   %esi,%esi
  801684:	74 30                	je     8016b6 <readn+0x48>
  801686:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80168b:	89 f2                	mov    %esi,%edx
  80168d:	29 c2                	sub    %eax,%edx
  80168f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801693:	03 45 0c             	add    0xc(%ebp),%eax
  801696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169a:	89 3c 24             	mov    %edi,(%esp)
  80169d:	e8 3c ff ff ff       	call   8015de <read>
		if (m < 0)
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 10                	js     8016b6 <readn+0x48>
			return m;
		if (m == 0)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	74 0a                	je     8016b4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016aa:	01 c3                	add    %eax,%ebx
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	39 f3                	cmp    %esi,%ebx
  8016b0:	72 d9                	jb     80168b <readn+0x1d>
  8016b2:	eb 02                	jmp    8016b6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016b4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016b6:	83 c4 1c             	add    $0x1c,%esp
  8016b9:	5b                   	pop    %ebx
  8016ba:	5e                   	pop    %esi
  8016bb:	5f                   	pop    %edi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 24             	sub    $0x24,%esp
  8016c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	89 1c 24             	mov    %ebx,(%esp)
  8016d2:	e8 47 fc ff ff       	call   80131e <fd_lookup>
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 68                	js     801743 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e5:	8b 00                	mov    (%eax),%eax
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	e8 80 fc ff ff       	call   80136f <dev_lookup>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 50                	js     801743 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fa:	75 23                	jne    80171f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016fc:	a1 08 40 80 00       	mov    0x804008,%eax
  801701:	8b 40 48             	mov    0x48(%eax),%eax
  801704:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170c:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801713:	e8 1b ec ff ff       	call   800333 <cprintf>
		return -E_INVAL;
  801718:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171d:	eb 24                	jmp    801743 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80171f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801722:	8b 52 0c             	mov    0xc(%edx),%edx
  801725:	85 d2                	test   %edx,%edx
  801727:	74 15                	je     80173e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801729:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80172c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801730:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801733:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	ff d2                	call   *%edx
  80173c:	eb 05                	jmp    801743 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80173e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801743:	83 c4 24             	add    $0x24,%esp
  801746:	5b                   	pop    %ebx
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <seek>:

int
seek(int fdnum, off_t offset)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80174f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	8b 45 08             	mov    0x8(%ebp),%eax
  801759:	89 04 24             	mov    %eax,(%esp)
  80175c:	e8 bd fb ff ff       	call   80131e <fd_lookup>
  801761:	85 c0                	test   %eax,%eax
  801763:	78 0e                	js     801773 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801765:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801768:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80176e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	53                   	push   %ebx
  801779:	83 ec 24             	sub    $0x24,%esp
  80177c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801782:	89 44 24 04          	mov    %eax,0x4(%esp)
  801786:	89 1c 24             	mov    %ebx,(%esp)
  801789:	e8 90 fb ff ff       	call   80131e <fd_lookup>
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 61                	js     8017f3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801795:	89 44 24 04          	mov    %eax,0x4(%esp)
  801799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179c:	8b 00                	mov    (%eax),%eax
  80179e:	89 04 24             	mov    %eax,(%esp)
  8017a1:	e8 c9 fb ff ff       	call   80136f <dev_lookup>
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 49                	js     8017f3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b1:	75 23                	jne    8017d6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017b3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b8:	8b 40 48             	mov    0x48(%eax),%eax
  8017bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c3:	c7 04 24 ac 29 80 00 	movl   $0x8029ac,(%esp)
  8017ca:	e8 64 eb ff ff       	call   800333 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d4:	eb 1d                	jmp    8017f3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d9:	8b 52 18             	mov    0x18(%edx),%edx
  8017dc:	85 d2                	test   %edx,%edx
  8017de:	74 0e                	je     8017ee <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e7:	89 04 24             	mov    %eax,(%esp)
  8017ea:	ff d2                	call   *%edx
  8017ec:	eb 05                	jmp    8017f3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017ee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017f3:	83 c4 24             	add    $0x24,%esp
  8017f6:	5b                   	pop    %ebx
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 24             	sub    $0x24,%esp
  801800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801803:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801806:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	89 04 24             	mov    %eax,(%esp)
  801810:	e8 09 fb ff ff       	call   80131e <fd_lookup>
  801815:	85 c0                	test   %eax,%eax
  801817:	78 52                	js     80186b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801823:	8b 00                	mov    (%eax),%eax
  801825:	89 04 24             	mov    %eax,(%esp)
  801828:	e8 42 fb ff ff       	call   80136f <dev_lookup>
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 3a                	js     80186b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801834:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801838:	74 2c                	je     801866 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80183a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801844:	00 00 00 
	stat->st_isdir = 0;
  801847:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184e:	00 00 00 
	stat->st_dev = dev;
  801851:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801857:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80185e:	89 14 24             	mov    %edx,(%esp)
  801861:	ff 50 14             	call   *0x14(%eax)
  801864:	eb 05                	jmp    80186b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801866:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80186b:	83 c4 24             	add    $0x24,%esp
  80186e:	5b                   	pop    %ebx
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	83 ec 18             	sub    $0x18,%esp
  801877:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80187a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80187d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801884:	00 
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	89 04 24             	mov    %eax,(%esp)
  80188b:	e8 bc 01 00 00       	call   801a4c <open>
  801890:	89 c3                	mov    %eax,%ebx
  801892:	85 c0                	test   %eax,%eax
  801894:	78 1b                	js     8018b1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801896:	8b 45 0c             	mov    0xc(%ebp),%eax
  801899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189d:	89 1c 24             	mov    %ebx,(%esp)
  8018a0:	e8 54 ff ff ff       	call   8017f9 <fstat>
  8018a5:	89 c6                	mov    %eax,%esi
	close(fd);
  8018a7:	89 1c 24             	mov    %ebx,(%esp)
  8018aa:	e8 be fb ff ff       	call   80146d <close>
	return r;
  8018af:	89 f3                	mov    %esi,%ebx
}
  8018b1:	89 d8                	mov    %ebx,%eax
  8018b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018b6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018b9:	89 ec                	mov    %ebp,%esp
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    
  8018bd:	00 00                	add    %al,(%eax)
	...

008018c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 18             	sub    $0x18,%esp
  8018c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018d0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018d7:	75 11                	jne    8018ea <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018e0:	e8 8c 09 00 00       	call   802271 <ipc_find_env>
  8018e5:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018f1:	00 
  8018f2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018f9:	00 
  8018fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801903:	89 04 24             	mov    %eax,(%esp)
  801906:	e8 fb 08 00 00       	call   802206 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80190b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801912:	00 
  801913:	89 74 24 04          	mov    %esi,0x4(%esp)
  801917:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191e:	e8 7d 08 00 00       	call   8021a0 <ipc_recv>
}
  801923:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801926:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801929:	89 ec                	mov    %ebp,%esp
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	53                   	push   %ebx
  801931:	83 ec 14             	sub    $0x14,%esp
  801934:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801937:	8b 45 08             	mov    0x8(%ebp),%eax
  80193a:	8b 40 0c             	mov    0xc(%eax),%eax
  80193d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801942:	ba 00 00 00 00       	mov    $0x0,%edx
  801947:	b8 05 00 00 00       	mov    $0x5,%eax
  80194c:	e8 6f ff ff ff       	call   8018c0 <fsipc>
  801951:	85 c0                	test   %eax,%eax
  801953:	78 2b                	js     801980 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801955:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80195c:	00 
  80195d:	89 1c 24             	mov    %ebx,(%esp)
  801960:	e8 16 f1 ff ff       	call   800a7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801965:	a1 80 50 80 00       	mov    0x805080,%eax
  80196a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801970:	a1 84 50 80 00       	mov    0x805084,%eax
  801975:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80197b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801980:	83 c4 14             	add    $0x14,%esp
  801983:	5b                   	pop    %ebx
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	8b 40 0c             	mov    0xc(%eax),%eax
  801992:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801997:	ba 00 00 00 00       	mov    $0x0,%edx
  80199c:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a1:	e8 1a ff ff ff       	call   8018c0 <fsipc>
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 10             	sub    $0x10,%esp
  8019b0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019be:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ce:	e8 ed fe ff ff       	call   8018c0 <fsipc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 6a                	js     801a43 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019d9:	39 c6                	cmp    %eax,%esi
  8019db:	73 24                	jae    801a01 <devfile_read+0x59>
  8019dd:	c7 44 24 0c 1c 2a 80 	movl   $0x802a1c,0xc(%esp)
  8019e4:	00 
  8019e5:	c7 44 24 08 23 2a 80 	movl   $0x802a23,0x8(%esp)
  8019ec:	00 
  8019ed:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8019f4:	00 
  8019f5:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  8019fc:	e8 37 e8 ff ff       	call   800238 <_panic>
	assert(r <= PGSIZE);
  801a01:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a06:	7e 24                	jle    801a2c <devfile_read+0x84>
  801a08:	c7 44 24 0c 43 2a 80 	movl   $0x802a43,0xc(%esp)
  801a0f:	00 
  801a10:	c7 44 24 08 23 2a 80 	movl   $0x802a23,0x8(%esp)
  801a17:	00 
  801a18:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a1f:	00 
  801a20:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  801a27:	e8 0c e8 ff ff       	call   800238 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a30:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a37:	00 
  801a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3b:	89 04 24             	mov    %eax,(%esp)
  801a3e:	e8 29 f2 ff ff       	call   800c6c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801a43:	89 d8                	mov    %ebx,%eax
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	83 ec 20             	sub    $0x20,%esp
  801a54:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a57:	89 34 24             	mov    %esi,(%esp)
  801a5a:	e8 d1 ef ff ff       	call   800a30 <strlen>
		return -E_BAD_PATH;
  801a5f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a64:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a69:	7f 5e                	jg     801ac9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6e:	89 04 24             	mov    %eax,(%esp)
  801a71:	e8 35 f8 ff ff       	call   8012ab <fd_alloc>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 4d                	js     801ac9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a80:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a87:	e8 ef ef ff ff       	call   800a7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a97:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9c:	e8 1f fe ff ff       	call   8018c0 <fsipc>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	79 15                	jns    801abc <open+0x70>
		fd_close(fd, 0);
  801aa7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aae:	00 
  801aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab2:	89 04 24             	mov    %eax,(%esp)
  801ab5:	e8 21 f9 ff ff       	call   8013db <fd_close>
		return r;
  801aba:	eb 0d                	jmp    801ac9 <open+0x7d>
	}

	return fd2num(fd);
  801abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abf:	89 04 24             	mov    %eax,(%esp)
  801ac2:	e8 b9 f7 ff ff       	call   801280 <fd2num>
  801ac7:	89 c3                	mov    %eax,%ebx
}
  801ac9:	89 d8                	mov    %ebx,%eax
  801acb:	83 c4 20             	add    $0x20,%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    
	...

00801ad4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 14             	sub    $0x14,%esp
  801adb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801add:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801ae1:	7e 31                	jle    801b14 <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801ae3:	8b 40 04             	mov    0x4(%eax),%eax
  801ae6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aea:	8d 43 10             	lea    0x10(%ebx),%eax
  801aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af1:	8b 03                	mov    (%ebx),%eax
  801af3:	89 04 24             	mov    %eax,(%esp)
  801af6:	e8 c3 fb ff ff       	call   8016be <write>
		if (result > 0)
  801afb:	85 c0                	test   %eax,%eax
  801afd:	7e 03                	jle    801b02 <writebuf+0x2e>
			b->result += result;
  801aff:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b02:	39 43 04             	cmp    %eax,0x4(%ebx)
  801b05:	74 0d                	je     801b14 <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801b07:	85 c0                	test   %eax,%eax
  801b09:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0e:	0f 4f c2             	cmovg  %edx,%eax
  801b11:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801b14:	83 c4 14             	add    $0x14,%esp
  801b17:	5b                   	pop    %ebx
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <putch>:

static void
putch(int ch, void *thunk)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 04             	sub    $0x4,%esp
  801b21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801b24:	8b 43 04             	mov    0x4(%ebx),%eax
  801b27:	8b 55 08             	mov    0x8(%ebp),%edx
  801b2a:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801b2e:	83 c0 01             	add    $0x1,%eax
  801b31:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801b34:	3d 00 01 00 00       	cmp    $0x100,%eax
  801b39:	75 0e                	jne    801b49 <putch+0x2f>
		writebuf(b);
  801b3b:	89 d8                	mov    %ebx,%eax
  801b3d:	e8 92 ff ff ff       	call   801ad4 <writebuf>
		b->idx = 0;
  801b42:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801b49:	83 c4 04             	add    $0x4,%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b61:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b68:	00 00 00 
	b.result = 0;
  801b6b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b72:	00 00 00 
	b.error = 1;
  801b75:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b7c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b89:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b97:	c7 04 24 1a 1b 80 00 	movl   $0x801b1a,(%esp)
  801b9e:	e8 07 e9 ff ff       	call   8004aa <vprintfmt>
	if (b.idx > 0)
  801ba3:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801baa:	7e 0b                	jle    801bb7 <vfprintf+0x68>
		writebuf(&b);
  801bac:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801bb2:	e8 1d ff ff ff       	call   801ad4 <writebuf>

	return (b.result ? b.result : b.error);
  801bb7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bce:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	89 04 24             	mov    %eax,(%esp)
  801be2:	e8 68 ff ff ff       	call   801b4f <vfprintf>
	va_end(ap);

	return cnt;
}
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <printf>:

int
printf(const char *fmt, ...)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801bf2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c04:	e8 46 ff ff ff       	call   801b4f <vfprintf>
	va_end(ap);

	return cnt;
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    
  801c0b:	00 00                	add    %al,(%eax)
  801c0d:	00 00                	add    %al,(%eax)
	...

00801c10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 18             	sub    $0x18,%esp
  801c16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c19:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c1c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c22:	89 04 24             	mov    %eax,(%esp)
  801c25:	e8 66 f6 ff ff       	call   801290 <fd2data>
  801c2a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c2c:	c7 44 24 04 4f 2a 80 	movl   $0x802a4f,0x4(%esp)
  801c33:	00 
  801c34:	89 34 24             	mov    %esi,(%esp)
  801c37:	e8 3f ee ff ff       	call   800a7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c3f:	2b 03                	sub    (%ebx),%eax
  801c41:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c47:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c4e:	00 00 00 
	stat->st_dev = &devpipe;
  801c51:	c7 86 88 00 00 00 28 	movl   $0x803028,0x88(%esi)
  801c58:	30 80 00 
	return 0;
}
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c60:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c63:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c66:	89 ec                	mov    %ebp,%esp
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	53                   	push   %ebx
  801c6e:	83 ec 14             	sub    $0x14,%esp
  801c71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7f:	e8 b5 f3 ff ff       	call   801039 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c84:	89 1c 24             	mov    %ebx,(%esp)
  801c87:	e8 04 f6 ff ff       	call   801290 <fd2data>
  801c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c97:	e8 9d f3 ff ff       	call   801039 <sys_page_unmap>
}
  801c9c:	83 c4 14             	add    $0x14,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 2c             	sub    $0x2c,%esp
  801cab:	89 c7                	mov    %eax,%edi
  801cad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cb0:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cb8:	89 3c 24             	mov    %edi,(%esp)
  801cbb:	e8 fc 05 00 00       	call   8022bc <pageref>
  801cc0:	89 c6                	mov    %eax,%esi
  801cc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc5:	89 04 24             	mov    %eax,(%esp)
  801cc8:	e8 ef 05 00 00       	call   8022bc <pageref>
  801ccd:	39 c6                	cmp    %eax,%esi
  801ccf:	0f 94 c0             	sete   %al
  801cd2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cd5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801cdb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cde:	39 cb                	cmp    %ecx,%ebx
  801ce0:	75 08                	jne    801cea <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ce2:	83 c4 2c             	add    $0x2c,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cea:	83 f8 01             	cmp    $0x1,%eax
  801ced:	75 c1                	jne    801cb0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cef:	8b 52 58             	mov    0x58(%edx),%edx
  801cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cf6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cfa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cfe:	c7 04 24 56 2a 80 00 	movl   $0x802a56,(%esp)
  801d05:	e8 29 e6 ff ff       	call   800333 <cprintf>
  801d0a:	eb a4                	jmp    801cb0 <_pipeisclosed+0xe>

00801d0c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	83 ec 2c             	sub    $0x2c,%esp
  801d15:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d18:	89 34 24             	mov    %esi,(%esp)
  801d1b:	e8 70 f5 ff ff       	call   801290 <fd2data>
  801d20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d22:	bf 00 00 00 00       	mov    $0x0,%edi
  801d27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d2b:	75 50                	jne    801d7d <devpipe_write+0x71>
  801d2d:	eb 5c                	jmp    801d8b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d2f:	89 da                	mov    %ebx,%edx
  801d31:	89 f0                	mov    %esi,%eax
  801d33:	e8 6a ff ff ff       	call   801ca2 <_pipeisclosed>
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	75 53                	jne    801d8f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3c:	e8 0b f2 ff ff       	call   800f4c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d41:	8b 43 04             	mov    0x4(%ebx),%eax
  801d44:	8b 13                	mov    (%ebx),%edx
  801d46:	83 c2 20             	add    $0x20,%edx
  801d49:	39 d0                	cmp    %edx,%eax
  801d4b:	73 e2                	jae    801d2f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d50:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801d54:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801d57:	89 c2                	mov    %eax,%edx
  801d59:	c1 fa 1f             	sar    $0x1f,%edx
  801d5c:	c1 ea 1b             	shr    $0x1b,%edx
  801d5f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d62:	83 e1 1f             	and    $0x1f,%ecx
  801d65:	29 d1                	sub    %edx,%ecx
  801d67:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d6b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d6f:	83 c0 01             	add    $0x1,%eax
  801d72:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d75:	83 c7 01             	add    $0x1,%edi
  801d78:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d7b:	74 0e                	je     801d8b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d7d:	8b 43 04             	mov    0x4(%ebx),%eax
  801d80:	8b 13                	mov    (%ebx),%edx
  801d82:	83 c2 20             	add    $0x20,%edx
  801d85:	39 d0                	cmp    %edx,%eax
  801d87:	73 a6                	jae    801d2f <devpipe_write+0x23>
  801d89:	eb c2                	jmp    801d4d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d8b:	89 f8                	mov    %edi,%eax
  801d8d:	eb 05                	jmp    801d94 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d94:	83 c4 2c             	add    $0x2c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 28             	sub    $0x28,%esp
  801da2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801da5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801da8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801dab:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dae:	89 3c 24             	mov    %edi,(%esp)
  801db1:	e8 da f4 ff ff       	call   801290 <fd2data>
  801db6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db8:	be 00 00 00 00       	mov    $0x0,%esi
  801dbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc1:	75 47                	jne    801e0a <devpipe_read+0x6e>
  801dc3:	eb 52                	jmp    801e17 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801dc5:	89 f0                	mov    %esi,%eax
  801dc7:	eb 5e                	jmp    801e27 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dc9:	89 da                	mov    %ebx,%edx
  801dcb:	89 f8                	mov    %edi,%eax
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	e8 cd fe ff ff       	call   801ca2 <_pipeisclosed>
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	75 49                	jne    801e22 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801dd9:	e8 6e f1 ff ff       	call   800f4c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dde:	8b 03                	mov    (%ebx),%eax
  801de0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801de3:	74 e4                	je     801dc9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801de5:	89 c2                	mov    %eax,%edx
  801de7:	c1 fa 1f             	sar    $0x1f,%edx
  801dea:	c1 ea 1b             	shr    $0x1b,%edx
  801ded:	01 d0                	add    %edx,%eax
  801def:	83 e0 1f             	and    $0x1f,%eax
  801df2:	29 d0                	sub    %edx,%eax
  801df4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dff:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e02:	83 c6 01             	add    $0x1,%esi
  801e05:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e08:	74 0d                	je     801e17 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801e0a:	8b 03                	mov    (%ebx),%eax
  801e0c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e0f:	75 d4                	jne    801de5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e11:	85 f6                	test   %esi,%esi
  801e13:	75 b0                	jne    801dc5 <devpipe_read+0x29>
  801e15:	eb b2                	jmp    801dc9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e17:	89 f0                	mov    %esi,%eax
  801e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e20:	eb 05                	jmp    801e27 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e22:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801e30:	89 ec                	mov    %ebp,%esp
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    

00801e34 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	83 ec 48             	sub    $0x48,%esp
  801e3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801e3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801e40:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801e43:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e49:	89 04 24             	mov    %eax,(%esp)
  801e4c:	e8 5a f4 ff ff       	call   8012ab <fd_alloc>
  801e51:	89 c3                	mov    %eax,%ebx
  801e53:	85 c0                	test   %eax,%eax
  801e55:	0f 88 45 01 00 00    	js     801fa0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e62:	00 
  801e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e71:	e8 06 f1 ff ff       	call   800f7c <sys_page_alloc>
  801e76:	89 c3                	mov    %eax,%ebx
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	0f 88 20 01 00 00    	js     801fa0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e80:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e83:	89 04 24             	mov    %eax,(%esp)
  801e86:	e8 20 f4 ff ff       	call   8012ab <fd_alloc>
  801e8b:	89 c3                	mov    %eax,%ebx
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	0f 88 f8 00 00 00    	js     801f8d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e95:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e9c:	00 
  801e9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eab:	e8 cc f0 ff ff       	call   800f7c <sys_page_alloc>
  801eb0:	89 c3                	mov    %eax,%ebx
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	0f 88 d3 00 00 00    	js     801f8d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebd:	89 04 24             	mov    %eax,(%esp)
  801ec0:	e8 cb f3 ff ff       	call   801290 <fd2data>
  801ec5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ece:	00 
  801ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eda:	e8 9d f0 ff ff       	call   800f7c <sys_page_alloc>
  801edf:	89 c3                	mov    %eax,%ebx
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	0f 88 91 00 00 00    	js     801f7a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eec:	89 04 24             	mov    %eax,(%esp)
  801eef:	e8 9c f3 ff ff       	call   801290 <fd2data>
  801ef4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801efb:	00 
  801efc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f07:	00 
  801f08:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f13:	e8 c3 f0 ff ff       	call   800fdb <sys_page_map>
  801f18:	89 c3                	mov    %eax,%ebx
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 4c                	js     801f6a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f1e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f27:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f33:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801f39:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f3c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4b:	89 04 24             	mov    %eax,(%esp)
  801f4e:	e8 2d f3 ff ff       	call   801280 <fd2num>
  801f53:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f58:	89 04 24             	mov    %eax,(%esp)
  801f5b:	e8 20 f3 ff ff       	call   801280 <fd2num>
  801f60:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f68:	eb 36                	jmp    801fa0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801f6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f75:	e8 bf f0 ff ff       	call   801039 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f88:	e8 ac f0 ff ff       	call   801039 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9b:	e8 99 f0 ff ff       	call   801039 <sys_page_unmap>
    err:
	return r;
}
  801fa0:	89 d8                	mov    %ebx,%eax
  801fa2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fa5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fa8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fab:	89 ec                	mov    %ebp,%esp
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbf:	89 04 24             	mov    %eax,(%esp)
  801fc2:	e8 57 f3 ff ff       	call   80131e <fd_lookup>
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 15                	js     801fe0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fce:	89 04 24             	mov    %eax,(%esp)
  801fd1:	e8 ba f2 ff ff       	call   801290 <fd2data>
	return _pipeisclosed(fd, p);
  801fd6:	89 c2                	mov    %eax,%edx
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	e8 c2 fc ff ff       	call   801ca2 <_pipeisclosed>
}
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    
	...

00801ff0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802000:	c7 44 24 04 6e 2a 80 	movl   $0x802a6e,0x4(%esp)
  802007:	00 
  802008:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200b:	89 04 24             	mov    %eax,(%esp)
  80200e:	e8 68 ea ff ff       	call   800a7b <strcpy>
	return 0;
}
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	57                   	push   %edi
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802026:	be 00 00 00 00       	mov    $0x0,%esi
  80202b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80202f:	74 43                	je     802074 <devcons_write+0x5a>
  802031:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802036:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80203c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80203f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802041:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802044:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802049:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80204c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802050:	03 45 0c             	add    0xc(%ebp),%eax
  802053:	89 44 24 04          	mov    %eax,0x4(%esp)
  802057:	89 3c 24             	mov    %edi,(%esp)
  80205a:	e8 0d ec ff ff       	call   800c6c <memmove>
		sys_cputs(buf, m);
  80205f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802063:	89 3c 24             	mov    %edi,(%esp)
  802066:	e8 f5 ed ff ff       	call   800e60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80206b:	01 de                	add    %ebx,%esi
  80206d:	89 f0                	mov    %esi,%eax
  80206f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802072:	72 c8                	jb     80203c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802074:	89 f0                	mov    %esi,%eax
  802076:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80207c:	5b                   	pop    %ebx
  80207d:	5e                   	pop    %esi
  80207e:	5f                   	pop    %edi
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    

00802081 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80208c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802090:	75 07                	jne    802099 <devcons_read+0x18>
  802092:	eb 31                	jmp    8020c5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802094:	e8 b3 ee ff ff       	call   800f4c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	e8 ea ed ff ff       	call   800e8f <sys_cgetc>
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	74 eb                	je     802094 <devcons_read+0x13>
  8020a9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	78 16                	js     8020c5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020af:	83 f8 04             	cmp    $0x4,%eax
  8020b2:	74 0c                	je     8020c0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8020b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b7:	88 10                	mov    %dl,(%eax)
	return 1;
  8020b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020be:	eb 05                	jmp    8020c5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020c0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020c5:	c9                   	leave  
  8020c6:	c3                   	ret    

008020c7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020da:	00 
  8020db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020de:	89 04 24             	mov    %eax,(%esp)
  8020e1:	e8 7a ed ff ff       	call   800e60 <sys_cputs>
}
  8020e6:	c9                   	leave  
  8020e7:	c3                   	ret    

008020e8 <getchar>:

int
getchar(void)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020ee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020f5:	00 
  8020f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802104:	e8 d5 f4 ff ff       	call   8015de <read>
	if (r < 0)
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 0f                	js     80211c <getchar+0x34>
		return r;
	if (r < 1)
  80210d:	85 c0                	test   %eax,%eax
  80210f:	7e 06                	jle    802117 <getchar+0x2f>
		return -E_EOF;
	return c;
  802111:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802115:	eb 05                	jmp    80211c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802117:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212b:	8b 45 08             	mov    0x8(%ebp),%eax
  80212e:	89 04 24             	mov    %eax,(%esp)
  802131:	e8 e8 f1 ff ff       	call   80131e <fd_lookup>
  802136:	85 c0                	test   %eax,%eax
  802138:	78 11                	js     80214b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802143:	39 10                	cmp    %edx,(%eax)
  802145:	0f 94 c0             	sete   %al
  802148:	0f b6 c0             	movzbl %al,%eax
}
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    

0080214d <opencons>:

int
opencons(void)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802153:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802156:	89 04 24             	mov    %eax,(%esp)
  802159:	e8 4d f1 ff ff       	call   8012ab <fd_alloc>
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 3c                	js     80219e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802162:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802169:	00 
  80216a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802178:	e8 ff ed ff ff       	call   800f7c <sys_page_alloc>
  80217d:	85 c0                	test   %eax,%eax
  80217f:	78 1d                	js     80219e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802181:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802187:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80218c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802196:	89 04 24             	mov    %eax,(%esp)
  802199:	e8 e2 f0 ff ff       	call   801280 <fd2num>
}
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	56                   	push   %esi
  8021a4:	53                   	push   %ebx
  8021a5:	83 ec 10             	sub    $0x10,%esp
  8021a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8021ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ae:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8021b1:	85 db                	test   %ebx,%ebx
  8021b3:	74 06                	je     8021bb <ipc_recv+0x1b>
  8021b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8021bb:	85 f6                	test   %esi,%esi
  8021bd:	74 06                	je     8021c5 <ipc_recv+0x25>
  8021bf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8021cc:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8021cf:	89 04 24             	mov    %eax,(%esp)
  8021d2:	e8 0e f0 ff ff       	call   8011e5 <sys_ipc_recv>
    if (ret) return ret;
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	75 24                	jne    8021ff <ipc_recv+0x5f>
    if (from_env_store)
  8021db:	85 db                	test   %ebx,%ebx
  8021dd:	74 0a                	je     8021e9 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  8021df:	a1 08 40 80 00       	mov    0x804008,%eax
  8021e4:	8b 40 74             	mov    0x74(%eax),%eax
  8021e7:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8021e9:	85 f6                	test   %esi,%esi
  8021eb:	74 0a                	je     8021f7 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8021ed:	a1 08 40 80 00       	mov    0x804008,%eax
  8021f2:	8b 40 78             	mov    0x78(%eax),%eax
  8021f5:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8021f7:	a1 08 40 80 00       	mov    0x804008,%eax
  8021fc:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021ff:	83 c4 10             	add    $0x10,%esp
  802202:	5b                   	pop    %ebx
  802203:	5e                   	pop    %esi
  802204:	5d                   	pop    %ebp
  802205:	c3                   	ret    

00802206 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	57                   	push   %edi
  80220a:	56                   	push   %esi
  80220b:	53                   	push   %ebx
  80220c:	83 ec 1c             	sub    $0x1c,%esp
  80220f:	8b 75 08             	mov    0x8(%ebp),%esi
  802212:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802215:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802218:	85 db                	test   %ebx,%ebx
  80221a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80221f:	0f 44 d8             	cmove  %eax,%ebx
  802222:	eb 2a                	jmp    80224e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802224:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802227:	74 20                	je     802249 <ipc_send+0x43>
  802229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80222d:	c7 44 24 08 7a 2a 80 	movl   $0x802a7a,0x8(%esp)
  802234:	00 
  802235:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80223c:	00 
  80223d:	c7 04 24 91 2a 80 00 	movl   $0x802a91,(%esp)
  802244:	e8 ef df ff ff       	call   800238 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802249:	e8 fe ec ff ff       	call   800f4c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80224e:	8b 45 14             	mov    0x14(%ebp),%eax
  802251:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802255:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802259:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80225d:	89 34 24             	mov    %esi,(%esp)
  802260:	e8 4c ef ff ff       	call   8011b1 <sys_ipc_try_send>
  802265:	85 c0                	test   %eax,%eax
  802267:	75 bb                	jne    802224 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802269:	83 c4 1c             	add    $0x1c,%esp
  80226c:	5b                   	pop    %ebx
  80226d:	5e                   	pop    %esi
  80226e:	5f                   	pop    %edi
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802277:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80227c:	39 c8                	cmp    %ecx,%eax
  80227e:	74 19                	je     802299 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802280:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802285:	89 c2                	mov    %eax,%edx
  802287:	c1 e2 07             	shl    $0x7,%edx
  80228a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802290:	8b 52 50             	mov    0x50(%edx),%edx
  802293:	39 ca                	cmp    %ecx,%edx
  802295:	75 14                	jne    8022ab <ipc_find_env+0x3a>
  802297:	eb 05                	jmp    80229e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802299:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80229e:	c1 e0 07             	shl    $0x7,%eax
  8022a1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022a6:	8b 40 40             	mov    0x40(%eax),%eax
  8022a9:	eb 0e                	jmp    8022b9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ab:	83 c0 01             	add    $0x1,%eax
  8022ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b3:	75 d0                	jne    802285 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b5:	66 b8 00 00          	mov    $0x0,%ax
}
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    
	...

008022bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c2:	89 d0                	mov    %edx,%eax
  8022c4:	c1 e8 16             	shr    $0x16,%eax
  8022c7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022ce:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d3:	f6 c1 01             	test   $0x1,%cl
  8022d6:	74 1d                	je     8022f5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d8:	c1 ea 0c             	shr    $0xc,%edx
  8022db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022e2:	f6 c2 01             	test   $0x1,%dl
  8022e5:	74 0e                	je     8022f5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e7:	c1 ea 0c             	shr    $0xc,%edx
  8022ea:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f1:	ef 
  8022f2:	0f b7 c0             	movzwl %ax,%eax
}
  8022f5:	5d                   	pop    %ebp
  8022f6:	c3                   	ret    
	...

00802300 <__udivdi3>:
  802300:	83 ec 1c             	sub    $0x1c,%esp
  802303:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802307:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80230b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80230f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802313:	89 74 24 10          	mov    %esi,0x10(%esp)
  802317:	8b 74 24 24          	mov    0x24(%esp),%esi
  80231b:	85 ff                	test   %edi,%edi
  80231d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802321:	89 44 24 08          	mov    %eax,0x8(%esp)
  802325:	89 cd                	mov    %ecx,%ebp
  802327:	89 44 24 04          	mov    %eax,0x4(%esp)
  80232b:	75 33                	jne    802360 <__udivdi3+0x60>
  80232d:	39 f1                	cmp    %esi,%ecx
  80232f:	77 57                	ja     802388 <__udivdi3+0x88>
  802331:	85 c9                	test   %ecx,%ecx
  802333:	75 0b                	jne    802340 <__udivdi3+0x40>
  802335:	b8 01 00 00 00       	mov    $0x1,%eax
  80233a:	31 d2                	xor    %edx,%edx
  80233c:	f7 f1                	div    %ecx
  80233e:	89 c1                	mov    %eax,%ecx
  802340:	89 f0                	mov    %esi,%eax
  802342:	31 d2                	xor    %edx,%edx
  802344:	f7 f1                	div    %ecx
  802346:	89 c6                	mov    %eax,%esi
  802348:	8b 44 24 04          	mov    0x4(%esp),%eax
  80234c:	f7 f1                	div    %ecx
  80234e:	89 f2                	mov    %esi,%edx
  802350:	8b 74 24 10          	mov    0x10(%esp),%esi
  802354:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802358:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80235c:	83 c4 1c             	add    $0x1c,%esp
  80235f:	c3                   	ret    
  802360:	31 d2                	xor    %edx,%edx
  802362:	31 c0                	xor    %eax,%eax
  802364:	39 f7                	cmp    %esi,%edi
  802366:	77 e8                	ja     802350 <__udivdi3+0x50>
  802368:	0f bd cf             	bsr    %edi,%ecx
  80236b:	83 f1 1f             	xor    $0x1f,%ecx
  80236e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802372:	75 2c                	jne    8023a0 <__udivdi3+0xa0>
  802374:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802378:	76 04                	jbe    80237e <__udivdi3+0x7e>
  80237a:	39 f7                	cmp    %esi,%edi
  80237c:	73 d2                	jae    802350 <__udivdi3+0x50>
  80237e:	31 d2                	xor    %edx,%edx
  802380:	b8 01 00 00 00       	mov    $0x1,%eax
  802385:	eb c9                	jmp    802350 <__udivdi3+0x50>
  802387:	90                   	nop
  802388:	89 f2                	mov    %esi,%edx
  80238a:	f7 f1                	div    %ecx
  80238c:	31 d2                	xor    %edx,%edx
  80238e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802392:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802396:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80239a:	83 c4 1c             	add    $0x1c,%esp
  80239d:	c3                   	ret    
  80239e:	66 90                	xchg   %ax,%ax
  8023a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023a5:	b8 20 00 00 00       	mov    $0x20,%eax
  8023aa:	89 ea                	mov    %ebp,%edx
  8023ac:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b0:	d3 e7                	shl    %cl,%edi
  8023b2:	89 c1                	mov    %eax,%ecx
  8023b4:	d3 ea                	shr    %cl,%edx
  8023b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023bb:	09 fa                	or     %edi,%edx
  8023bd:	89 f7                	mov    %esi,%edi
  8023bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023c9:	d3 e5                	shl    %cl,%ebp
  8023cb:	89 c1                	mov    %eax,%ecx
  8023cd:	d3 ef                	shr    %cl,%edi
  8023cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023d4:	d3 e2                	shl    %cl,%edx
  8023d6:	89 c1                	mov    %eax,%ecx
  8023d8:	d3 ee                	shr    %cl,%esi
  8023da:	09 d6                	or     %edx,%esi
  8023dc:	89 fa                	mov    %edi,%edx
  8023de:	89 f0                	mov    %esi,%eax
  8023e0:	f7 74 24 0c          	divl   0xc(%esp)
  8023e4:	89 d7                	mov    %edx,%edi
  8023e6:	89 c6                	mov    %eax,%esi
  8023e8:	f7 e5                	mul    %ebp
  8023ea:	39 d7                	cmp    %edx,%edi
  8023ec:	72 22                	jb     802410 <__udivdi3+0x110>
  8023ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8023f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023f7:	d3 e5                	shl    %cl,%ebp
  8023f9:	39 c5                	cmp    %eax,%ebp
  8023fb:	73 04                	jae    802401 <__udivdi3+0x101>
  8023fd:	39 d7                	cmp    %edx,%edi
  8023ff:	74 0f                	je     802410 <__udivdi3+0x110>
  802401:	89 f0                	mov    %esi,%eax
  802403:	31 d2                	xor    %edx,%edx
  802405:	e9 46 ff ff ff       	jmp    802350 <__udivdi3+0x50>
  80240a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802410:	8d 46 ff             	lea    -0x1(%esi),%eax
  802413:	31 d2                	xor    %edx,%edx
  802415:	8b 74 24 10          	mov    0x10(%esp),%esi
  802419:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80241d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	c3                   	ret    
	...

00802430 <__umoddi3>:
  802430:	83 ec 1c             	sub    $0x1c,%esp
  802433:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802437:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80243b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80243f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802443:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802447:	8b 74 24 24          	mov    0x24(%esp),%esi
  80244b:	85 ed                	test   %ebp,%ebp
  80244d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802451:	89 44 24 08          	mov    %eax,0x8(%esp)
  802455:	89 cf                	mov    %ecx,%edi
  802457:	89 04 24             	mov    %eax,(%esp)
  80245a:	89 f2                	mov    %esi,%edx
  80245c:	75 1a                	jne    802478 <__umoddi3+0x48>
  80245e:	39 f1                	cmp    %esi,%ecx
  802460:	76 4e                	jbe    8024b0 <__umoddi3+0x80>
  802462:	f7 f1                	div    %ecx
  802464:	89 d0                	mov    %edx,%eax
  802466:	31 d2                	xor    %edx,%edx
  802468:	8b 74 24 10          	mov    0x10(%esp),%esi
  80246c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802470:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802474:	83 c4 1c             	add    $0x1c,%esp
  802477:	c3                   	ret    
  802478:	39 f5                	cmp    %esi,%ebp
  80247a:	77 54                	ja     8024d0 <__umoddi3+0xa0>
  80247c:	0f bd c5             	bsr    %ebp,%eax
  80247f:	83 f0 1f             	xor    $0x1f,%eax
  802482:	89 44 24 04          	mov    %eax,0x4(%esp)
  802486:	75 60                	jne    8024e8 <__umoddi3+0xb8>
  802488:	3b 0c 24             	cmp    (%esp),%ecx
  80248b:	0f 87 07 01 00 00    	ja     802598 <__umoddi3+0x168>
  802491:	89 f2                	mov    %esi,%edx
  802493:	8b 34 24             	mov    (%esp),%esi
  802496:	29 ce                	sub    %ecx,%esi
  802498:	19 ea                	sbb    %ebp,%edx
  80249a:	89 34 24             	mov    %esi,(%esp)
  80249d:	8b 04 24             	mov    (%esp),%eax
  8024a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8024a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8024a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8024ac:	83 c4 1c             	add    $0x1c,%esp
  8024af:	c3                   	ret    
  8024b0:	85 c9                	test   %ecx,%ecx
  8024b2:	75 0b                	jne    8024bf <__umoddi3+0x8f>
  8024b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b9:	31 d2                	xor    %edx,%edx
  8024bb:	f7 f1                	div    %ecx
  8024bd:	89 c1                	mov    %eax,%ecx
  8024bf:	89 f0                	mov    %esi,%eax
  8024c1:	31 d2                	xor    %edx,%edx
  8024c3:	f7 f1                	div    %ecx
  8024c5:	8b 04 24             	mov    (%esp),%eax
  8024c8:	f7 f1                	div    %ecx
  8024ca:	eb 98                	jmp    802464 <__umoddi3+0x34>
  8024cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	89 f2                	mov    %esi,%edx
  8024d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8024d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8024da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8024de:	83 c4 1c             	add    $0x1c,%esp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024ed:	89 e8                	mov    %ebp,%eax
  8024ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8024f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8024f8:	89 fa                	mov    %edi,%edx
  8024fa:	d3 e0                	shl    %cl,%eax
  8024fc:	89 e9                	mov    %ebp,%ecx
  8024fe:	d3 ea                	shr    %cl,%edx
  802500:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802505:	09 c2                	or     %eax,%edx
  802507:	8b 44 24 08          	mov    0x8(%esp),%eax
  80250b:	89 14 24             	mov    %edx,(%esp)
  80250e:	89 f2                	mov    %esi,%edx
  802510:	d3 e7                	shl    %cl,%edi
  802512:	89 e9                	mov    %ebp,%ecx
  802514:	d3 ea                	shr    %cl,%edx
  802516:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80251b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80251f:	d3 e6                	shl    %cl,%esi
  802521:	89 e9                	mov    %ebp,%ecx
  802523:	d3 e8                	shr    %cl,%eax
  802525:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80252a:	09 f0                	or     %esi,%eax
  80252c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802530:	f7 34 24             	divl   (%esp)
  802533:	d3 e6                	shl    %cl,%esi
  802535:	89 74 24 08          	mov    %esi,0x8(%esp)
  802539:	89 d6                	mov    %edx,%esi
  80253b:	f7 e7                	mul    %edi
  80253d:	39 d6                	cmp    %edx,%esi
  80253f:	89 c1                	mov    %eax,%ecx
  802541:	89 d7                	mov    %edx,%edi
  802543:	72 3f                	jb     802584 <__umoddi3+0x154>
  802545:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802549:	72 35                	jb     802580 <__umoddi3+0x150>
  80254b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80254f:	29 c8                	sub    %ecx,%eax
  802551:	19 fe                	sbb    %edi,%esi
  802553:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802558:	89 f2                	mov    %esi,%edx
  80255a:	d3 e8                	shr    %cl,%eax
  80255c:	89 e9                	mov    %ebp,%ecx
  80255e:	d3 e2                	shl    %cl,%edx
  802560:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802565:	09 d0                	or     %edx,%eax
  802567:	89 f2                	mov    %esi,%edx
  802569:	d3 ea                	shr    %cl,%edx
  80256b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80256f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802573:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802577:	83 c4 1c             	add    $0x1c,%esp
  80257a:	c3                   	ret    
  80257b:	90                   	nop
  80257c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802580:	39 d6                	cmp    %edx,%esi
  802582:	75 c7                	jne    80254b <__umoddi3+0x11b>
  802584:	89 d7                	mov    %edx,%edi
  802586:	89 c1                	mov    %eax,%ecx
  802588:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80258c:	1b 3c 24             	sbb    (%esp),%edi
  80258f:	eb ba                	jmp    80254b <__umoddi3+0x11b>
  802591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802598:	39 f5                	cmp    %esi,%ebp
  80259a:	0f 82 f1 fe ff ff    	jb     802491 <__umoddi3+0x61>
  8025a0:	e9 f8 fe ff ff       	jmp    80249d <__umoddi3+0x6d>
