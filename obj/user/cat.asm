
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 3b 01 00 00       	call   80016c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800043:	eb 40                	jmp    800085 <cat+0x51>
		if ((r = write(1, buf, n)) != n)
  800045:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800049:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800050:	00 
  800051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800058:	e8 01 16 00 00       	call   80165e <write>
  80005d:	39 d8                	cmp    %ebx,%eax
  80005f:	74 24                	je     800085 <cat+0x51>
			panic("write error copying %s: %e", s, r);
  800061:	89 44 24 10          	mov    %eax,0x10(%esp)
  800065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800069:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 7b 25 80 00 	movl   $0x80257b,(%esp)
  800080:	e8 53 01 00 00       	call   8001d8 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800085:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800094:	00 
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 e1 14 00 00       	call   80157e <read>
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	85 c0                	test   %eax,%eax
  8000a1:	7f a2                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 24                	jns    8000cb <cat+0x97>
		panic("error reading %s: %e", s, n);
  8000a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000af:	c7 44 24 08 86 25 80 	movl   $0x802586,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 7b 25 80 00 	movl   $0x80257b,(%esp)
  8000c6:	e8 0d 01 00 00       	call   8001d8 <_panic>
}
  8000cb:	83 c4 2c             	add    $0x2c,%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 9b 	movl   $0x80259b,0x803000
  8000e6:	25 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	74 0d                	je     8000fc <umain+0x29>
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000ef:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000f4:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000f8:	7f 18                	jg     800112 <umain+0x3f>
  8000fa:	eb 67                	jmp    800163 <umain+0x90>
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
  8000fc:	c7 44 24 04 9f 25 80 	movl   $0x80259f,0x4(%esp)
  800103:	00 
  800104:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80010b:	e8 24 ff ff ff       	call   800034 <cat>
  800110:	eb 51                	jmp    800163 <umain+0x90>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800112:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800119:	00 
  80011a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 c7 18 00 00       	call   8019ec <open>
  800125:	89 c7                	mov    %eax,%edi
			if (f < 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	79 19                	jns    800144 <umain+0x71>
				printf("can't open %s: %e\n", argv[i], f);
  80012b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012f:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800132:	89 44 24 04          	mov    %eax,0x4(%esp)
  800136:	c7 04 24 a7 25 80 00 	movl   $0x8025a7,(%esp)
  80013d:	e8 47 1a 00 00       	call   801b89 <printf>
  800142:	eb 17                	jmp    80015b <umain+0x88>
			else {
				cat(f, argv[i]);
  800144:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014b:	89 3c 24             	mov    %edi,(%esp)
  80014e:	e8 e1 fe ff ff       	call   800034 <cat>
				close(f);
  800153:	89 3c 24             	mov    %edi,(%esp)
  800156:	e8 b2 12 00 00       	call   80140d <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80015b:	83 c3 01             	add    $0x1,%ebx
  80015e:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800161:	75 af                	jne    800112 <umain+0x3f>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  800163:	83 c4 1c             	add    $0x1c,%esp
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    
	...

0080016c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
  800172:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800175:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800178:	8b 75 08             	mov    0x8(%ebp),%esi
  80017b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80017e:	e8 39 0d 00 00       	call   800ebc <sys_getenvid>
  800183:	25 ff 03 00 00       	and    $0x3ff,%eax
  800188:	c1 e0 07             	shl    $0x7,%eax
  80018b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800190:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800195:	85 f6                	test   %esi,%esi
  800197:	7e 07                	jle    8001a0 <libmain+0x34>
		binaryname = argv[0];
  800199:	8b 03                	mov    (%ebx),%eax
  80019b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a4:	89 34 24             	mov    %esi,(%esp)
  8001a7:	e8 27 ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001ac:	e8 0b 00 00 00       	call   8001bc <exit>
}
  8001b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001b7:	89 ec                	mov    %ebp,%esp
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    
	...

008001bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001c2:	e8 77 12 00 00       	call   80143e <close_all>
	sys_env_destroy(0);
  8001c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ce:	e8 8c 0c 00 00       	call   800e5f <sys_env_destroy>
}
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    
  8001d5:	00 00                	add    %al,(%eax)
	...

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e9:	e8 ce 0c 00 00       	call   800ebc <sys_getenvid>
  8001ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  80020b:	e8 c3 00 00 00       	call   8002d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	e8 53 00 00 00       	call   800272 <vcprintf>
	cprintf("\n");
  80021f:	c7 04 24 07 2a 80 00 	movl   $0x802a07,(%esp)
  800226:	e8 a8 00 00 00       	call   8002d3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022b:	cc                   	int3   
  80022c:	eb fd                	jmp    80022b <_panic+0x53>
	...

00800230 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	53                   	push   %ebx
  800234:	83 ec 14             	sub    $0x14,%esp
  800237:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023a:	8b 03                	mov    (%ebx),%eax
  80023c:	8b 55 08             	mov    0x8(%ebp),%edx
  80023f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800243:	83 c0 01             	add    $0x1,%eax
  800246:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800248:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024d:	75 19                	jne    800268 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800256:	00 
  800257:	8d 43 08             	lea    0x8(%ebx),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	e8 9e 0b 00 00       	call   800e00 <sys_cputs>
		b->idx = 0;
  800262:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800268:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80026c:	83 c4 14             	add    $0x14,%esp
  80026f:	5b                   	pop    %ebx
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80027b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800282:	00 00 00 
	b.cnt = 0;
  800285:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80028c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800292:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a7:	c7 04 24 30 02 80 00 	movl   $0x800230,(%esp)
  8002ae:	e8 97 01 00 00       	call   80044a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	e8 35 0b 00 00       	call   800e00 <sys_cputs>

	return b.cnt;
}
  8002cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	e8 87 ff ff ff       	call   800272 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    
  8002ed:	00 00                	add    %al,(%eax)
	...

008002f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 3c             	sub    $0x3c,%esp
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	89 d7                	mov    %edx,%edi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800304:	8b 45 0c             	mov    0xc(%ebp),%eax
  800307:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80030d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800318:	72 11                	jb     80032b <printnum+0x3b>
  80031a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800320:	76 09                	jbe    80032b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800322:	83 eb 01             	sub    $0x1,%ebx
  800325:	85 db                	test   %ebx,%ebx
  800327:	7f 51                	jg     80037a <printnum+0x8a>
  800329:	eb 5e                	jmp    800389 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80032b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80032f:	83 eb 01             	sub    $0x1,%ebx
  800332:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800336:	8b 45 10             	mov    0x10(%ebp),%eax
  800339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800341:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800345:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034c:	00 
  80034d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800350:	89 04 24             	mov    %eax,(%esp)
  800353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035a:	e8 41 1f 00 00       	call   8022a0 <__udivdi3>
  80035f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800363:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036e:	89 fa                	mov    %edi,%edx
  800370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800373:	e8 78 ff ff ff       	call   8002f0 <printnum>
  800378:	eb 0f                	jmp    800389 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037e:	89 34 24             	mov    %esi,(%esp)
  800381:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800384:	83 eb 01             	sub    $0x1,%ebx
  800387:	75 f1                	jne    80037a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800389:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800391:	8b 45 10             	mov    0x10(%ebp),%eax
  800394:	89 44 24 08          	mov    %eax,0x8(%esp)
  800398:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039f:	00 
  8003a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a3:	89 04 24             	mov    %eax,(%esp)
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	e8 1e 20 00 00       	call   8023d0 <__umoddi3>
  8003b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b6:	0f be 80 e7 25 80 00 	movsbl 0x8025e7(%eax),%eax
  8003bd:	89 04 24             	mov    %eax,(%esp)
  8003c0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003c3:	83 c4 3c             	add    $0x3c,%esp
  8003c6:	5b                   	pop    %ebx
  8003c7:	5e                   	pop    %esi
  8003c8:	5f                   	pop    %edi
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ce:	83 fa 01             	cmp    $0x1,%edx
  8003d1:	7e 0e                	jle    8003e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d8:	89 08                	mov    %ecx,(%eax)
  8003da:	8b 02                	mov    (%edx),%eax
  8003dc:	8b 52 04             	mov    0x4(%edx),%edx
  8003df:	eb 22                	jmp    800403 <getuint+0x38>
	else if (lflag)
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	74 10                	je     8003f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e5:	8b 10                	mov    (%eax),%edx
  8003e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ea:	89 08                	mov    %ecx,(%eax)
  8003ec:	8b 02                	mov    (%edx),%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 0e                	jmp    800403 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fa:	89 08                	mov    %ecx,(%eax)
  8003fc:	8b 02                	mov    (%edx),%eax
  8003fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040f:	8b 10                	mov    (%eax),%edx
  800411:	3b 50 04             	cmp    0x4(%eax),%edx
  800414:	73 0a                	jae    800420 <sprintputch+0x1b>
		*b->buf++ = ch;
  800416:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800419:	88 0a                	mov    %cl,(%edx)
  80041b:	83 c2 01             	add    $0x1,%edx
  80041e:	89 10                	mov    %edx,(%eax)
}
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800428:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	8b 45 10             	mov    0x10(%ebp),%eax
  800432:	89 44 24 08          	mov    %eax,0x8(%esp)
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 02 00 00 00       	call   80044a <vprintfmt>
	va_end(ap);
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    

0080044a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 5c             	sub    $0x5c,%esp
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800456:	8b 75 10             	mov    0x10(%ebp),%esi
  800459:	eb 12                	jmp    80046d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045b:	85 c0                	test   %eax,%eax
  80045d:	0f 84 e4 04 00 00    	je     800947 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046d:	0f b6 06             	movzbl (%esi),%eax
  800470:	83 c6 01             	add    $0x1,%esi
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e3                	jne    80045b <vprintfmt+0x11>
  800478:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80047c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800483:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800488:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80048f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800494:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800497:	eb 2b                	jmp    8004c4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8004a0:	eb 22                	jmp    8004c4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8004a9:	eb 19                	jmp    8004c4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004ae:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004b5:	eb 0d                	jmp    8004c4 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004bd:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	0f b6 06             	movzbl (%esi),%eax
  8004c7:	0f b6 d0             	movzbl %al,%edx
  8004ca:	8d 7e 01             	lea    0x1(%esi),%edi
  8004cd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d0:	83 e8 23             	sub    $0x23,%eax
  8004d3:	3c 55                	cmp    $0x55,%al
  8004d5:	0f 87 46 04 00 00    	ja     800921 <vprintfmt+0x4d7>
  8004db:	0f b6 c0             	movzbl %al,%eax
  8004de:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e5:	83 ea 30             	sub    $0x30,%edx
  8004e8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004eb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004ef:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004f5:	83 fa 09             	cmp    $0x9,%edx
  8004f8:	77 4a                	ja     800544 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004fd:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800500:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800503:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800507:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80050a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80050d:	83 fa 09             	cmp    $0x9,%edx
  800510:	76 eb                	jbe    8004fd <vprintfmt+0xb3>
  800512:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800515:	eb 2d                	jmp    800544 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 00                	mov    (%eax),%eax
  800522:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800528:	eb 1a                	jmp    800544 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80052d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800531:	79 91                	jns    8004c4 <vprintfmt+0x7a>
  800533:	e9 73 ff ff ff       	jmp    8004ab <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80053b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800542:	eb 80                	jmp    8004c4 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800544:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800548:	0f 89 76 ff ff ff    	jns    8004c4 <vprintfmt+0x7a>
  80054e:	e9 64 ff ff ff       	jmp    8004b7 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800553:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800559:	e9 66 ff ff ff       	jmp    8004c4 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 04 24             	mov    %eax,(%esp)
  800570:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800576:	e9 f2 fe ff ff       	jmp    80046d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80057b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80057f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800582:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800586:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800589:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80058d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800590:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800593:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800597:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80059a:	80 f9 09             	cmp    $0x9,%cl
  80059d:	77 1d                	ja     8005bc <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80059f:	0f be c0             	movsbl %al,%eax
  8005a2:	6b c0 64             	imul   $0x64,%eax,%eax
  8005a5:	0f be d2             	movsbl %dl,%edx
  8005a8:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005ab:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8005b2:	a3 04 30 80 00       	mov    %eax,0x803004
  8005b7:	e9 b1 fe ff ff       	jmp    80046d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8005bc:	c7 44 24 04 ff 25 80 	movl   $0x8025ff,0x4(%esp)
  8005c3:	00 
  8005c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	e8 0c 05 00 00       	call   800adb <strcmp>
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	75 0f                	jne    8005e2 <vprintfmt+0x198>
  8005d3:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8005da:	00 00 00 
  8005dd:	e9 8b fe ff ff       	jmp    80046d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8005e2:	c7 44 24 04 03 26 80 	movl   $0x802603,0x4(%esp)
  8005e9:	00 
  8005ea:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005ed:	89 14 24             	mov    %edx,(%esp)
  8005f0:	e8 e6 04 00 00       	call   800adb <strcmp>
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	75 0f                	jne    800608 <vprintfmt+0x1be>
  8005f9:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800600:	00 00 00 
  800603:	e9 65 fe ff ff       	jmp    80046d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800608:	c7 44 24 04 07 26 80 	movl   $0x802607,0x4(%esp)
  80060f:	00 
  800610:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800613:	89 0c 24             	mov    %ecx,(%esp)
  800616:	e8 c0 04 00 00       	call   800adb <strcmp>
  80061b:	85 c0                	test   %eax,%eax
  80061d:	75 0f                	jne    80062e <vprintfmt+0x1e4>
  80061f:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  800626:	00 00 00 
  800629:	e9 3f fe ff ff       	jmp    80046d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80062e:	c7 44 24 04 0b 26 80 	movl   $0x80260b,0x4(%esp)
  800635:	00 
  800636:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800639:	89 3c 24             	mov    %edi,(%esp)
  80063c:	e8 9a 04 00 00       	call   800adb <strcmp>
  800641:	85 c0                	test   %eax,%eax
  800643:	75 0f                	jne    800654 <vprintfmt+0x20a>
  800645:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  80064c:	00 00 00 
  80064f:	e9 19 fe ff ff       	jmp    80046d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800654:	c7 44 24 04 0f 26 80 	movl   $0x80260f,0x4(%esp)
  80065b:	00 
  80065c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	e8 74 04 00 00       	call   800adb <strcmp>
  800667:	85 c0                	test   %eax,%eax
  800669:	75 0f                	jne    80067a <vprintfmt+0x230>
  80066b:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800672:	00 00 00 
  800675:	e9 f3 fd ff ff       	jmp    80046d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80067a:	c7 44 24 04 13 26 80 	movl   $0x802613,0x4(%esp)
  800681:	00 
  800682:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800685:	89 14 24             	mov    %edx,(%esp)
  800688:	e8 4e 04 00 00       	call   800adb <strcmp>
  80068d:	83 f8 01             	cmp    $0x1,%eax
  800690:	19 c0                	sbb    %eax,%eax
  800692:	f7 d0                	not    %eax
  800694:	83 c0 08             	add    $0x8,%eax
  800697:	a3 04 30 80 00       	mov    %eax,0x803004
  80069c:	e9 cc fd ff ff       	jmp    80046d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	c1 fa 1f             	sar    $0x1f,%edx
  8006b1:	31 d0                	xor    %edx,%eax
  8006b3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b5:	83 f8 0f             	cmp    $0xf,%eax
  8006b8:	7f 0b                	jg     8006c5 <vprintfmt+0x27b>
  8006ba:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  8006c1:	85 d2                	test   %edx,%edx
  8006c3:	75 23                	jne    8006e8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8006c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c9:	c7 44 24 08 17 26 80 	movl   $0x802617,0x8(%esp)
  8006d0:	00 
  8006d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d8:	89 3c 24             	mov    %edi,(%esp)
  8006db:	e8 42 fd ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006e3:	e9 85 fd ff ff       	jmp    80046d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ec:	c7 44 24 08 d5 29 80 	movl   $0x8029d5,0x8(%esp)
  8006f3:	00 
  8006f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fb:	89 3c 24             	mov    %edi,(%esp)
  8006fe:	e8 1f fd ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800706:	e9 62 fd ff ff       	jmp    80046d <vprintfmt+0x23>
  80070b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80070e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800711:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80071f:	85 f6                	test   %esi,%esi
  800721:	b8 f8 25 80 00       	mov    $0x8025f8,%eax
  800726:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800729:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80072d:	7e 06                	jle    800735 <vprintfmt+0x2eb>
  80072f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800733:	75 13                	jne    800748 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800735:	0f be 06             	movsbl (%esi),%eax
  800738:	83 c6 01             	add    $0x1,%esi
  80073b:	85 c0                	test   %eax,%eax
  80073d:	0f 85 94 00 00 00    	jne    8007d7 <vprintfmt+0x38d>
  800743:	e9 81 00 00 00       	jmp    8007c9 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800748:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074c:	89 34 24             	mov    %esi,(%esp)
  80074f:	e8 97 02 00 00       	call   8009eb <strnlen>
  800754:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800757:	29 c2                	sub    %eax,%edx
  800759:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80075c:	85 d2                	test   %edx,%edx
  80075e:	7e d5                	jle    800735 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800760:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800764:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800767:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80076a:	89 d6                	mov    %edx,%esi
  80076c:	89 cf                	mov    %ecx,%edi
  80076e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800772:	89 3c 24             	mov    %edi,(%esp)
  800775:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800778:	83 ee 01             	sub    $0x1,%esi
  80077b:	75 f1                	jne    80076e <vprintfmt+0x324>
  80077d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800780:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800783:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800786:	eb ad                	jmp    800735 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800788:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80078c:	74 1b                	je     8007a9 <vprintfmt+0x35f>
  80078e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800791:	83 fa 5e             	cmp    $0x5e,%edx
  800794:	76 13                	jbe    8007a9 <vprintfmt+0x35f>
					putch('?', putdat);
  800796:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
  8007a7:	eb 0d                	jmp    8007b6 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8007a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b0:	89 04 24             	mov    %eax,(%esp)
  8007b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b6:	83 eb 01             	sub    $0x1,%ebx
  8007b9:	0f be 06             	movsbl (%esi),%eax
  8007bc:	83 c6 01             	add    $0x1,%esi
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	75 1a                	jne    8007dd <vprintfmt+0x393>
  8007c3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007c6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007d0:	7f 1c                	jg     8007ee <vprintfmt+0x3a4>
  8007d2:	e9 96 fc ff ff       	jmp    80046d <vprintfmt+0x23>
  8007d7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007da:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007dd:	85 ff                	test   %edi,%edi
  8007df:	78 a7                	js     800788 <vprintfmt+0x33e>
  8007e1:	83 ef 01             	sub    $0x1,%edi
  8007e4:	79 a2                	jns    800788 <vprintfmt+0x33e>
  8007e6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007e9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007ec:	eb db                	jmp    8007c9 <vprintfmt+0x37f>
  8007ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f1:	89 de                	mov    %ebx,%esi
  8007f3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800801:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800803:	83 eb 01             	sub    $0x1,%ebx
  800806:	75 ee                	jne    8007f6 <vprintfmt+0x3ac>
  800808:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80080d:	e9 5b fc ff ff       	jmp    80046d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800812:	83 f9 01             	cmp    $0x1,%ecx
  800815:	7e 10                	jle    800827 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 08             	lea    0x8(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
  800820:	8b 30                	mov    (%eax),%esi
  800822:	8b 78 04             	mov    0x4(%eax),%edi
  800825:	eb 26                	jmp    80084d <vprintfmt+0x403>
	else if (lflag)
  800827:	85 c9                	test   %ecx,%ecx
  800829:	74 12                	je     80083d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8d 50 04             	lea    0x4(%eax),%edx
  800831:	89 55 14             	mov    %edx,0x14(%ebp)
  800834:	8b 30                	mov    (%eax),%esi
  800836:	89 f7                	mov    %esi,%edi
  800838:	c1 ff 1f             	sar    $0x1f,%edi
  80083b:	eb 10                	jmp    80084d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8d 50 04             	lea    0x4(%eax),%edx
  800843:	89 55 14             	mov    %edx,0x14(%ebp)
  800846:	8b 30                	mov    (%eax),%esi
  800848:	89 f7                	mov    %esi,%edi
  80084a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80084d:	85 ff                	test   %edi,%edi
  80084f:	78 0e                	js     80085f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800851:	89 f0                	mov    %esi,%eax
  800853:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800855:	be 0a 00 00 00       	mov    $0xa,%esi
  80085a:	e9 84 00 00 00       	jmp    8008e3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80085f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800863:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80086a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	89 fa                	mov    %edi,%edx
  800871:	f7 d8                	neg    %eax
  800873:	83 d2 00             	adc    $0x0,%edx
  800876:	f7 da                	neg    %edx
			}
			base = 10;
  800878:	be 0a 00 00 00       	mov    $0xa,%esi
  80087d:	eb 64                	jmp    8008e3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80087f:	89 ca                	mov    %ecx,%edx
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
  800884:	e8 42 fb ff ff       	call   8003cb <getuint>
			base = 10;
  800889:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80088e:	eb 53                	jmp    8008e3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800890:	89 ca                	mov    %ecx,%edx
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
  800895:	e8 31 fb ff ff       	call   8003cb <getuint>
    			base = 8;
  80089a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80089f:	eb 42                	jmp    8008e3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8008a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ba:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 50 04             	lea    0x4(%eax),%edx
  8008c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008c6:	8b 00                	mov    (%eax),%eax
  8008c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008cd:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008d2:	eb 0f                	jmp    8008e3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d4:	89 ca                	mov    %ecx,%edx
  8008d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d9:	e8 ed fa ff ff       	call   8003cb <getuint>
			base = 16;
  8008de:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008e7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008eb:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008ee:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008f2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fd:	89 da                	mov    %ebx,%edx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	e8 e9 f9 ff ff       	call   8002f0 <printnum>
			break;
  800907:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80090a:	e9 5e fb ff ff       	jmp    80046d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80090f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800913:	89 14 24             	mov    %edx,(%esp)
  800916:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800919:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80091c:	e9 4c fb ff ff       	jmp    80046d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800921:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800925:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80092c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800933:	0f 84 34 fb ff ff    	je     80046d <vprintfmt+0x23>
  800939:	83 ee 01             	sub    $0x1,%esi
  80093c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800940:	75 f7                	jne    800939 <vprintfmt+0x4ef>
  800942:	e9 26 fb ff ff       	jmp    80046d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800947:	83 c4 5c             	add    $0x5c,%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 28             	sub    $0x28,%esp
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800962:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800965:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096c:	85 c0                	test   %eax,%eax
  80096e:	74 30                	je     8009a0 <vsnprintf+0x51>
  800970:	85 d2                	test   %edx,%edx
  800972:	7e 2c                	jle    8009a0 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800974:	8b 45 14             	mov    0x14(%ebp),%eax
  800977:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097b:	8b 45 10             	mov    0x10(%ebp),%eax
  80097e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800982:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800985:	89 44 24 04          	mov    %eax,0x4(%esp)
  800989:	c7 04 24 05 04 80 00 	movl   $0x800405,(%esp)
  800990:	e8 b5 fa ff ff       	call   80044a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800995:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800998:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099e:	eb 05                	jmp    8009a5 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	e8 82 ff ff ff       	call   80094f <vsnprintf>
	va_end(ap);

	return rc;
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    
	...

008009d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	80 3a 00             	cmpb   $0x0,(%edx)
  8009de:	74 09                	je     8009e9 <strlen+0x19>
		n++;
  8009e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e7:	75 f7                	jne    8009e0 <strlen+0x10>
		n++;
	return n;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fa:	85 c9                	test   %ecx,%ecx
  8009fc:	74 1a                	je     800a18 <strnlen+0x2d>
  8009fe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a01:	74 15                	je     800a18 <strnlen+0x2d>
  800a03:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a08:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0a:	39 ca                	cmp    %ecx,%edx
  800a0c:	74 0a                	je     800a18 <strnlen+0x2d>
  800a0e:	83 c2 01             	add    $0x1,%edx
  800a11:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a16:	75 f0                	jne    800a08 <strnlen+0x1d>
		n++;
	return n;
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a2e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a31:	83 c2 01             	add    $0x1,%edx
  800a34:	84 c9                	test   %cl,%cl
  800a36:	75 f2                	jne    800a2a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a38:	5b                   	pop    %ebx
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	83 ec 08             	sub    $0x8,%esp
  800a42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a45:	89 1c 24             	mov    %ebx,(%esp)
  800a48:	e8 83 ff ff ff       	call   8009d0 <strlen>
	strcpy(dst + len, src);
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a50:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a54:	01 d8                	add    %ebx,%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 bd ff ff ff       	call   800a1b <strcpy>
	return dst;
}
  800a5e:	89 d8                	mov    %ebx,%eax
  800a60:	83 c4 08             	add    $0x8,%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a74:	85 f6                	test   %esi,%esi
  800a76:	74 18                	je     800a90 <strncpy+0x2a>
  800a78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a7d:	0f b6 1a             	movzbl (%edx),%ebx
  800a80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a83:	80 3a 01             	cmpb   $0x1,(%edx)
  800a86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	39 f1                	cmp    %esi,%ecx
  800a8e:	75 ed                	jne    800a7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa3:	89 f8                	mov    %edi,%eax
  800aa5:	85 f6                	test   %esi,%esi
  800aa7:	74 2b                	je     800ad4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800aa9:	83 fe 01             	cmp    $0x1,%esi
  800aac:	74 23                	je     800ad1 <strlcpy+0x3d>
  800aae:	0f b6 0b             	movzbl (%ebx),%ecx
  800ab1:	84 c9                	test   %cl,%cl
  800ab3:	74 1c                	je     800ad1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ab5:	83 ee 02             	sub    $0x2,%esi
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800abd:	88 08                	mov    %cl,(%eax)
  800abf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac2:	39 f2                	cmp    %esi,%edx
  800ac4:	74 0b                	je     800ad1 <strlcpy+0x3d>
  800ac6:	83 c2 01             	add    $0x1,%edx
  800ac9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800acd:	84 c9                	test   %cl,%cl
  800acf:	75 ec                	jne    800abd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800ad1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad4:	29 f8                	sub    %edi,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae4:	0f b6 01             	movzbl (%ecx),%eax
  800ae7:	84 c0                	test   %al,%al
  800ae9:	74 16                	je     800b01 <strcmp+0x26>
  800aeb:	3a 02                	cmp    (%edx),%al
  800aed:	75 12                	jne    800b01 <strcmp+0x26>
		p++, q++;
  800aef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800af6:	84 c0                	test   %al,%al
  800af8:	74 07                	je     800b01 <strcmp+0x26>
  800afa:	83 c1 01             	add    $0x1,%ecx
  800afd:	3a 02                	cmp    (%edx),%al
  800aff:	74 ee                	je     800aef <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b01:	0f b6 c0             	movzbl %al,%eax
  800b04:	0f b6 12             	movzbl (%edx),%edx
  800b07:	29 d0                	sub    %edx,%eax
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b1d:	85 d2                	test   %edx,%edx
  800b1f:	74 28                	je     800b49 <strncmp+0x3e>
  800b21:	0f b6 01             	movzbl (%ecx),%eax
  800b24:	84 c0                	test   %al,%al
  800b26:	74 24                	je     800b4c <strncmp+0x41>
  800b28:	3a 03                	cmp    (%ebx),%al
  800b2a:	75 20                	jne    800b4c <strncmp+0x41>
  800b2c:	83 ea 01             	sub    $0x1,%edx
  800b2f:	74 13                	je     800b44 <strncmp+0x39>
		n--, p++, q++;
  800b31:	83 c1 01             	add    $0x1,%ecx
  800b34:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b37:	0f b6 01             	movzbl (%ecx),%eax
  800b3a:	84 c0                	test   %al,%al
  800b3c:	74 0e                	je     800b4c <strncmp+0x41>
  800b3e:	3a 03                	cmp    (%ebx),%al
  800b40:	74 ea                	je     800b2c <strncmp+0x21>
  800b42:	eb 08                	jmp    800b4c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4c:	0f b6 01             	movzbl (%ecx),%eax
  800b4f:	0f b6 13             	movzbl (%ebx),%edx
  800b52:	29 d0                	sub    %edx,%eax
  800b54:	eb f3                	jmp    800b49 <strncmp+0x3e>

00800b56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b60:	0f b6 10             	movzbl (%eax),%edx
  800b63:	84 d2                	test   %dl,%dl
  800b65:	74 1c                	je     800b83 <strchr+0x2d>
		if (*s == c)
  800b67:	38 ca                	cmp    %cl,%dl
  800b69:	75 09                	jne    800b74 <strchr+0x1e>
  800b6b:	eb 1b                	jmp    800b88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b6d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b70:	38 ca                	cmp    %cl,%dl
  800b72:	74 14                	je     800b88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b74:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b78:	84 d2                	test   %dl,%dl
  800b7a:	75 f1                	jne    800b6d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	eb 05                	jmp    800b88 <strchr+0x32>
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b94:	0f b6 10             	movzbl (%eax),%edx
  800b97:	84 d2                	test   %dl,%dl
  800b99:	74 14                	je     800baf <strfind+0x25>
		if (*s == c)
  800b9b:	38 ca                	cmp    %cl,%dl
  800b9d:	75 06                	jne    800ba5 <strfind+0x1b>
  800b9f:	eb 0e                	jmp    800baf <strfind+0x25>
  800ba1:	38 ca                	cmp    %cl,%dl
  800ba3:	74 0a                	je     800baf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ba5:	83 c0 01             	add    $0x1,%eax
  800ba8:	0f b6 10             	movzbl (%eax),%edx
  800bab:	84 d2                	test   %dl,%dl
  800bad:	75 f2                	jne    800ba1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc9:	85 c9                	test   %ecx,%ecx
  800bcb:	74 30                	je     800bfd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bcd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd3:	75 25                	jne    800bfa <memset+0x49>
  800bd5:	f6 c1 03             	test   $0x3,%cl
  800bd8:	75 20                	jne    800bfa <memset+0x49>
		c &= 0xFF;
  800bda:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	c1 e3 08             	shl    $0x8,%ebx
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	c1 e6 18             	shl    $0x18,%esi
  800be7:	89 d0                	mov    %edx,%eax
  800be9:	c1 e0 10             	shl    $0x10,%eax
  800bec:	09 f0                	or     %esi,%eax
  800bee:	09 d0                	or     %edx,%eax
  800bf0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bf5:	fc                   	cld    
  800bf6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bf8:	eb 03                	jmp    800bfd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bfa:	fc                   	cld    
  800bfb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bfd:	89 f8                	mov    %edi,%eax
  800bff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c08:	89 ec                	mov    %ebp,%esp
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 08             	sub    $0x8,%esp
  800c12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c15:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c21:	39 c6                	cmp    %eax,%esi
  800c23:	73 36                	jae    800c5b <memmove+0x4f>
  800c25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c28:	39 d0                	cmp    %edx,%eax
  800c2a:	73 2f                	jae    800c5b <memmove+0x4f>
		s += n;
		d += n;
  800c2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2f:	f6 c2 03             	test   $0x3,%dl
  800c32:	75 1b                	jne    800c4f <memmove+0x43>
  800c34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3a:	75 13                	jne    800c4f <memmove+0x43>
  800c3c:	f6 c1 03             	test   $0x3,%cl
  800c3f:	75 0e                	jne    800c4f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c41:	83 ef 04             	sub    $0x4,%edi
  800c44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c4a:	fd                   	std    
  800c4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4d:	eb 09                	jmp    800c58 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c4f:	83 ef 01             	sub    $0x1,%edi
  800c52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c55:	fd                   	std    
  800c56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c58:	fc                   	cld    
  800c59:	eb 20                	jmp    800c7b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c61:	75 13                	jne    800c76 <memmove+0x6a>
  800c63:	a8 03                	test   $0x3,%al
  800c65:	75 0f                	jne    800c76 <memmove+0x6a>
  800c67:	f6 c1 03             	test   $0x3,%cl
  800c6a:	75 0a                	jne    800c76 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c6c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c6f:	89 c7                	mov    %eax,%edi
  800c71:	fc                   	cld    
  800c72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c74:	eb 05                	jmp    800c7b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c76:	89 c7                	mov    %eax,%edi
  800c78:	fc                   	cld    
  800c79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c81:	89 ec                	mov    %ebp,%esp
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	89 04 24             	mov    %eax,(%esp)
  800c9f:	e8 68 ff ff ff       	call   800c0c <memmove>
}
  800ca4:	c9                   	leave  
  800ca5:	c3                   	ret    

00800ca6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800caf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cba:	85 ff                	test   %edi,%edi
  800cbc:	74 37                	je     800cf5 <memcmp+0x4f>
		if (*s1 != *s2)
  800cbe:	0f b6 03             	movzbl (%ebx),%eax
  800cc1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc4:	83 ef 01             	sub    $0x1,%edi
  800cc7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800ccc:	38 c8                	cmp    %cl,%al
  800cce:	74 1c                	je     800cec <memcmp+0x46>
  800cd0:	eb 10                	jmp    800ce2 <memcmp+0x3c>
  800cd2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800cd7:	83 c2 01             	add    $0x1,%edx
  800cda:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cde:	38 c8                	cmp    %cl,%al
  800ce0:	74 0a                	je     800cec <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800ce2:	0f b6 c0             	movzbl %al,%eax
  800ce5:	0f b6 c9             	movzbl %cl,%ecx
  800ce8:	29 c8                	sub    %ecx,%eax
  800cea:	eb 09                	jmp    800cf5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cec:	39 fa                	cmp    %edi,%edx
  800cee:	75 e2                	jne    800cd2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d00:	89 c2                	mov    %eax,%edx
  800d02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d05:	39 d0                	cmp    %edx,%eax
  800d07:	73 19                	jae    800d22 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d0d:	38 08                	cmp    %cl,(%eax)
  800d0f:	75 06                	jne    800d17 <memfind+0x1d>
  800d11:	eb 0f                	jmp    800d22 <memfind+0x28>
  800d13:	38 08                	cmp    %cl,(%eax)
  800d15:	74 0b                	je     800d22 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d17:	83 c0 01             	add    $0x1,%eax
  800d1a:	39 d0                	cmp    %edx,%eax
  800d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d20:	75 f1                	jne    800d13 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d30:	0f b6 02             	movzbl (%edx),%eax
  800d33:	3c 20                	cmp    $0x20,%al
  800d35:	74 04                	je     800d3b <strtol+0x17>
  800d37:	3c 09                	cmp    $0x9,%al
  800d39:	75 0e                	jne    800d49 <strtol+0x25>
		s++;
  800d3b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3e:	0f b6 02             	movzbl (%edx),%eax
  800d41:	3c 20                	cmp    $0x20,%al
  800d43:	74 f6                	je     800d3b <strtol+0x17>
  800d45:	3c 09                	cmp    $0x9,%al
  800d47:	74 f2                	je     800d3b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d49:	3c 2b                	cmp    $0x2b,%al
  800d4b:	75 0a                	jne    800d57 <strtol+0x33>
		s++;
  800d4d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d50:	bf 00 00 00 00       	mov    $0x0,%edi
  800d55:	eb 10                	jmp    800d67 <strtol+0x43>
  800d57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d5c:	3c 2d                	cmp    $0x2d,%al
  800d5e:	75 07                	jne    800d67 <strtol+0x43>
		s++, neg = 1;
  800d60:	83 c2 01             	add    $0x1,%edx
  800d63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d67:	85 db                	test   %ebx,%ebx
  800d69:	0f 94 c0             	sete   %al
  800d6c:	74 05                	je     800d73 <strtol+0x4f>
  800d6e:	83 fb 10             	cmp    $0x10,%ebx
  800d71:	75 15                	jne    800d88 <strtol+0x64>
  800d73:	80 3a 30             	cmpb   $0x30,(%edx)
  800d76:	75 10                	jne    800d88 <strtol+0x64>
  800d78:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d7c:	75 0a                	jne    800d88 <strtol+0x64>
		s += 2, base = 16;
  800d7e:	83 c2 02             	add    $0x2,%edx
  800d81:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d86:	eb 13                	jmp    800d9b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d88:	84 c0                	test   %al,%al
  800d8a:	74 0f                	je     800d9b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d91:	80 3a 30             	cmpb   $0x30,(%edx)
  800d94:	75 05                	jne    800d9b <strtol+0x77>
		s++, base = 8;
  800d96:	83 c2 01             	add    $0x1,%edx
  800d99:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800da0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da2:	0f b6 0a             	movzbl (%edx),%ecx
  800da5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800da8:	80 fb 09             	cmp    $0x9,%bl
  800dab:	77 08                	ja     800db5 <strtol+0x91>
			dig = *s - '0';
  800dad:	0f be c9             	movsbl %cl,%ecx
  800db0:	83 e9 30             	sub    $0x30,%ecx
  800db3:	eb 1e                	jmp    800dd3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800db5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800db8:	80 fb 19             	cmp    $0x19,%bl
  800dbb:	77 08                	ja     800dc5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800dbd:	0f be c9             	movsbl %cl,%ecx
  800dc0:	83 e9 57             	sub    $0x57,%ecx
  800dc3:	eb 0e                	jmp    800dd3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800dc5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800dc8:	80 fb 19             	cmp    $0x19,%bl
  800dcb:	77 14                	ja     800de1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dcd:	0f be c9             	movsbl %cl,%ecx
  800dd0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dd3:	39 f1                	cmp    %esi,%ecx
  800dd5:	7d 0e                	jge    800de5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800dd7:	83 c2 01             	add    $0x1,%edx
  800dda:	0f af c6             	imul   %esi,%eax
  800ddd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ddf:	eb c1                	jmp    800da2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800de1:	89 c1                	mov    %eax,%ecx
  800de3:	eb 02                	jmp    800de7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800de5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800de7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800deb:	74 05                	je     800df2 <strtol+0xce>
		*endptr = (char *) s;
  800ded:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800df2:	89 ca                	mov    %ecx,%edx
  800df4:	f7 da                	neg    %edx
  800df6:	85 ff                	test   %edi,%edi
  800df8:	0f 45 c2             	cmovne %edx,%eax
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	89 c7                	mov    %eax,%edi
  800e1e:	89 c6                	mov    %eax,%esi
  800e20:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2b:	89 ec                	mov    %ebp,%esp
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e43:	b8 01 00 00 00       	mov    $0x1,%eax
  800e48:	89 d1                	mov    %edx,%ecx
  800e4a:	89 d3                	mov    %edx,%ebx
  800e4c:	89 d7                	mov    %edx,%edi
  800e4e:	89 d6                	mov    %edx,%esi
  800e50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5b:	89 ec                	mov    %ebp,%esp
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 38             	sub    $0x38,%esp
  800e65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e73:	b8 03 00 00 00       	mov    $0x3,%eax
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	89 cb                	mov    %ecx,%ebx
  800e7d:	89 cf                	mov    %ecx,%edi
  800e7f:	89 ce                	mov    %ecx,%esi
  800e81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	7e 28                	jle    800eaf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e92:	00 
  800e93:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e9a:	00 
  800e9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea2:	00 
  800ea3:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800eaa:	e8 29 f3 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eaf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb8:	89 ec                	mov    %ebp,%esp
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ed5:	89 d1                	mov    %edx,%ecx
  800ed7:	89 d3                	mov    %edx,%ebx
  800ed9:	89 d7                	mov    %edx,%edi
  800edb:	89 d6                	mov    %edx,%esi
  800edd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800edf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_yield>:

void
sys_yield(void)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efb:	ba 00 00 00 00       	mov    $0x0,%edx
  800f00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f05:	89 d1                	mov    %edx,%ecx
  800f07:	89 d3                	mov    %edx,%ebx
  800f09:	89 d7                	mov    %edx,%edi
  800f0b:	89 d6                	mov    %edx,%esi
  800f0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 38             	sub    $0x38,%esp
  800f22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2b:	be 00 00 00 00       	mov    $0x0,%esi
  800f30:	b8 04 00 00 00       	mov    $0x4,%eax
  800f35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 f7                	mov    %esi,%edi
  800f40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f42:	85 c0                	test   %eax,%eax
  800f44:	7e 28                	jle    800f6e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f69:	e8 6a f2 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f6e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f71:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f74:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f77:	89 ec                	mov    %ebp,%esp
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 38             	sub    $0x38,%esp
  800f81:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f84:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f87:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	7e 28                	jle    800fcc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800faf:	00 
  800fb0:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbf:	00 
  800fc0:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800fc7:	e8 0c f2 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fcc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fcf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd5:	89 ec                	mov    %ebp,%esp
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	83 ec 38             	sub    $0x38,%esp
  800fdf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fed:	b8 06 00 00 00       	mov    $0x6,%eax
  800ff2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff8:	89 df                	mov    %ebx,%edi
  800ffa:	89 de                	mov    %ebx,%esi
  800ffc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ffe:	85 c0                	test   %eax,%eax
  801000:	7e 28                	jle    80102a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801002:	89 44 24 10          	mov    %eax,0x10(%esp)
  801006:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80100d:	00 
  80100e:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801015:	00 
  801016:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101d:	00 
  80101e:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801025:	e8 ae f1 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80102a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80102d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801030:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801033:	89 ec                	mov    %ebp,%esp
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 38             	sub    $0x38,%esp
  80103d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801040:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801043:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104b:	b8 08 00 00 00       	mov    $0x8,%eax
  801050:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
  801056:	89 df                	mov    %ebx,%edi
  801058:	89 de                	mov    %ebx,%esi
  80105a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80105c:	85 c0                	test   %eax,%eax
  80105e:	7e 28                	jle    801088 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801060:	89 44 24 10          	mov    %eax,0x10(%esp)
  801064:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80106b:	00 
  80106c:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801073:	00 
  801074:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107b:	00 
  80107c:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801083:	e8 50 f1 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801088:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80108e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801091:	89 ec                	mov    %ebp,%esp
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 38             	sub    $0x38,%esp
  80109b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80109e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a9:	b8 09 00 00 00       	mov    $0x9,%eax
  8010ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b4:	89 df                	mov    %ebx,%edi
  8010b6:	89 de                	mov    %ebx,%esi
  8010b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	7e 28                	jle    8010e6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010c9:	00 
  8010ca:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  8010d1:	00 
  8010d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010d9:	00 
  8010da:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8010e1:	e8 f2 f0 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ef:	89 ec                	mov    %ebp,%esp
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	83 ec 38             	sub    $0x38,%esp
  8010f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801102:	bb 00 00 00 00       	mov    $0x0,%ebx
  801107:	b8 0a 00 00 00       	mov    $0xa,%eax
  80110c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110f:	8b 55 08             	mov    0x8(%ebp),%edx
  801112:	89 df                	mov    %ebx,%edi
  801114:	89 de                	mov    %ebx,%esi
  801116:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801118:	85 c0                	test   %eax,%eax
  80111a:	7e 28                	jle    801144 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801120:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801127:	00 
  801128:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  80112f:	00 
  801130:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801137:	00 
  801138:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  80113f:	e8 94 f0 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801144:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801147:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80114a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80114d:	89 ec                	mov    %ebp,%esp
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80115a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80115d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801160:	be 00 00 00 00       	mov    $0x0,%esi
  801165:	b8 0c 00 00 00       	mov    $0xc,%eax
  80116a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801170:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801173:	8b 55 08             	mov    0x8(%ebp),%edx
  801176:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801178:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80117b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80117e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801181:	89 ec                	mov    %ebp,%esp
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 38             	sub    $0x38,%esp
  80118b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80118e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801191:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801194:	b9 00 00 00 00       	mov    $0x0,%ecx
  801199:	b8 0d 00 00 00       	mov    $0xd,%eax
  80119e:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a1:	89 cb                	mov    %ecx,%ebx
  8011a3:	89 cf                	mov    %ecx,%edi
  8011a5:	89 ce                	mov    %ecx,%esi
  8011a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	7e 28                	jle    8011d5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8011d0:	e8 03 f0 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011de:	89 ec                	mov    %ebp,%esp
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	83 ec 0c             	sub    $0xc,%esp
  8011e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011eb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011ee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fe:	89 cb                	mov    %ecx,%ebx
  801200:	89 cf                	mov    %ecx,%edi
  801202:	89 ce                	mov    %ecx,%esi
  801204:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801206:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801209:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80120c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80120f:	89 ec                	mov    %ebp,%esp
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    
	...

00801220 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
  80122b:	c1 e8 0c             	shr    $0xc,%eax
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	89 04 24             	mov    %eax,(%esp)
  80123c:	e8 df ff ff ff       	call   801220 <fd2num>
  801241:	05 20 00 0d 00       	add    $0xd0020,%eax
  801246:	c1 e0 0c             	shl    $0xc,%eax
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	53                   	push   %ebx
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801252:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801257:	a8 01                	test   $0x1,%al
  801259:	74 34                	je     80128f <fd_alloc+0x44>
  80125b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801260:	a8 01                	test   $0x1,%al
  801262:	74 32                	je     801296 <fd_alloc+0x4b>
  801264:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801269:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	c1 ea 16             	shr    $0x16,%edx
  801270:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801277:	f6 c2 01             	test   $0x1,%dl
  80127a:	74 1f                	je     80129b <fd_alloc+0x50>
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	c1 ea 0c             	shr    $0xc,%edx
  801281:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801288:	f6 c2 01             	test   $0x1,%dl
  80128b:	75 17                	jne    8012a4 <fd_alloc+0x59>
  80128d:	eb 0c                	jmp    80129b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80128f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801294:	eb 05                	jmp    80129b <fd_alloc+0x50>
  801296:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80129b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80129d:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a2:	eb 17                	jmp    8012bb <fd_alloc+0x70>
  8012a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ae:	75 b9                	jne    801269 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012bb:	5b                   	pop    %ebx
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c9:	83 fa 1f             	cmp    $0x1f,%edx
  8012cc:	77 3f                	ja     80130d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ce:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8012d4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d7:	89 d0                	mov    %edx,%eax
  8012d9:	c1 e8 16             	shr    $0x16,%eax
  8012dc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e8:	f6 c1 01             	test   $0x1,%cl
  8012eb:	74 20                	je     80130d <fd_lookup+0x4f>
  8012ed:	89 d0                	mov    %edx,%eax
  8012ef:	c1 e8 0c             	shr    $0xc,%eax
  8012f2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012fe:	f6 c1 01             	test   $0x1,%cl
  801301:	74 0a                	je     80130d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801303:	8b 45 0c             	mov    0xc(%ebp),%eax
  801306:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801321:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801327:	75 17                	jne    801340 <dev_lookup+0x31>
  801329:	eb 07                	jmp    801332 <dev_lookup+0x23>
  80132b:	39 0a                	cmp    %ecx,(%edx)
  80132d:	75 11                	jne    801340 <dev_lookup+0x31>
  80132f:	90                   	nop
  801330:	eb 05                	jmp    801337 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801332:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801337:	89 13                	mov    %edx,(%ebx)
			return 0;
  801339:	b8 00 00 00 00       	mov    $0x0,%eax
  80133e:	eb 35                	jmp    801375 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801340:	83 c0 01             	add    $0x1,%eax
  801343:	8b 14 85 ac 29 80 00 	mov    0x8029ac(,%eax,4),%edx
  80134a:	85 d2                	test   %edx,%edx
  80134c:	75 dd                	jne    80132b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134e:	a1 20 60 80 00       	mov    0x806020,%eax
  801353:	8b 40 48             	mov    0x48(%eax),%eax
  801356:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135e:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  801365:	e8 69 ef ff ff       	call   8002d3 <cprintf>
	*dev = 0;
  80136a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801370:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801375:	83 c4 14             	add    $0x14,%esp
  801378:	5b                   	pop    %ebx
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 38             	sub    $0x38,%esp
  801381:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801384:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801387:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80138a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801391:	89 3c 24             	mov    %edi,(%esp)
  801394:	e8 87 fe ff ff       	call   801220 <fd2num>
  801399:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80139c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013a0:	89 04 24             	mov    %eax,(%esp)
  8013a3:	e8 16 ff ff ff       	call   8012be <fd_lookup>
  8013a8:	89 c3                	mov    %eax,%ebx
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 05                	js     8013b3 <fd_close+0x38>
	    || fd != fd2)
  8013ae:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8013b1:	74 0e                	je     8013c1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013b3:	89 f0                	mov    %esi,%eax
  8013b5:	84 c0                	test   %al,%al
  8013b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bc:	0f 44 d8             	cmove  %eax,%ebx
  8013bf:	eb 3d                	jmp    8013fe <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	8b 07                	mov    (%edi),%eax
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	e8 3d ff ff ff       	call   80130f <dev_lookup>
  8013d2:	89 c3                	mov    %eax,%ebx
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 16                	js     8013ee <fd_close+0x73>
		if (dev->dev_close)
  8013d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	74 07                	je     8013ee <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8013e7:	89 3c 24             	mov    %edi,(%esp)
  8013ea:	ff d0                	call   *%eax
  8013ec:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f9:	e8 db fb ff ff       	call   800fd9 <sys_page_unmap>
	return r;
}
  8013fe:	89 d8                	mov    %ebx,%eax
  801400:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801403:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801406:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801409:	89 ec                	mov    %ebp,%esp
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	89 04 24             	mov    %eax,(%esp)
  801420:	e8 99 fe ff ff       	call   8012be <fd_lookup>
  801425:	85 c0                	test   %eax,%eax
  801427:	78 13                	js     80143c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801429:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801430:	00 
  801431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801434:	89 04 24             	mov    %eax,(%esp)
  801437:	e8 3f ff ff ff       	call   80137b <fd_close>
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <close_all>:

void
close_all(void)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	53                   	push   %ebx
  801442:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801445:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80144a:	89 1c 24             	mov    %ebx,(%esp)
  80144d:	e8 bb ff ff ff       	call   80140d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801452:	83 c3 01             	add    $0x1,%ebx
  801455:	83 fb 20             	cmp    $0x20,%ebx
  801458:	75 f0                	jne    80144a <close_all+0xc>
		close(i);
}
  80145a:	83 c4 14             	add    $0x14,%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 58             	sub    $0x58,%esp
  801466:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801469:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80146c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80146f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801472:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	89 04 24             	mov    %eax,(%esp)
  80147f:	e8 3a fe ff ff       	call   8012be <fd_lookup>
  801484:	89 c3                	mov    %eax,%ebx
  801486:	85 c0                	test   %eax,%eax
  801488:	0f 88 e1 00 00 00    	js     80156f <dup+0x10f>
		return r;
	close(newfdnum);
  80148e:	89 3c 24             	mov    %edi,(%esp)
  801491:	e8 77 ff ff ff       	call   80140d <close>

	newfd = INDEX2FD(newfdnum);
  801496:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80149c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80149f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a2:	89 04 24             	mov    %eax,(%esp)
  8014a5:	e8 86 fd ff ff       	call   801230 <fd2data>
  8014aa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014ac:	89 34 24             	mov    %esi,(%esp)
  8014af:	e8 7c fd ff ff       	call   801230 <fd2data>
  8014b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b7:	89 d8                	mov    %ebx,%eax
  8014b9:	c1 e8 16             	shr    $0x16,%eax
  8014bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c3:	a8 01                	test   $0x1,%al
  8014c5:	74 46                	je     80150d <dup+0xad>
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	c1 e8 0c             	shr    $0xc,%eax
  8014cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d3:	f6 c2 01             	test   $0x1,%dl
  8014d6:	74 35                	je     80150d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014df:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f6:	00 
  8014f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801502:	e8 74 fa ff ff       	call   800f7b <sys_page_map>
  801507:	89 c3                	mov    %eax,%ebx
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 3b                	js     801548 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801510:	89 c2                	mov    %eax,%edx
  801512:	c1 ea 0c             	shr    $0xc,%edx
  801515:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801522:	89 54 24 10          	mov    %edx,0x10(%esp)
  801526:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80152a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801531:	00 
  801532:	89 44 24 04          	mov    %eax,0x4(%esp)
  801536:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153d:	e8 39 fa ff ff       	call   800f7b <sys_page_map>
  801542:	89 c3                	mov    %eax,%ebx
  801544:	85 c0                	test   %eax,%eax
  801546:	79 25                	jns    80156d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801548:	89 74 24 04          	mov    %esi,0x4(%esp)
  80154c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801553:	e8 81 fa ff ff       	call   800fd9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80155b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801566:	e8 6e fa ff ff       	call   800fd9 <sys_page_unmap>
	return r;
  80156b:	eb 02                	jmp    80156f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80156d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80156f:	89 d8                	mov    %ebx,%eax
  801571:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801574:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801577:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80157a:	89 ec                	mov    %ebp,%esp
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	53                   	push   %ebx
  801582:	83 ec 24             	sub    $0x24,%esp
  801585:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801588:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158f:	89 1c 24             	mov    %ebx,(%esp)
  801592:	e8 27 fd ff ff       	call   8012be <fd_lookup>
  801597:	85 c0                	test   %eax,%eax
  801599:	78 6d                	js     801608 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a5:	8b 00                	mov    (%eax),%eax
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 60 fd ff ff       	call   80130f <dev_lookup>
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 55                	js     801608 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	8b 50 08             	mov    0x8(%eax),%edx
  8015b9:	83 e2 03             	and    $0x3,%edx
  8015bc:	83 fa 01             	cmp    $0x1,%edx
  8015bf:	75 23                	jne    8015e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c1:	a1 20 60 80 00       	mov    0x806020,%eax
  8015c6:	8b 40 48             	mov    0x48(%eax),%eax
  8015c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d1:	c7 04 24 70 29 80 00 	movl   $0x802970,(%esp)
  8015d8:	e8 f6 ec ff ff       	call   8002d3 <cprintf>
		return -E_INVAL;
  8015dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e2:	eb 24                	jmp    801608 <read+0x8a>
	}
	if (!dev->dev_read)
  8015e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e7:	8b 52 08             	mov    0x8(%edx),%edx
  8015ea:	85 d2                	test   %edx,%edx
  8015ec:	74 15                	je     801603 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8015ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015fc:	89 04 24             	mov    %eax,(%esp)
  8015ff:	ff d2                	call   *%edx
  801601:	eb 05                	jmp    801608 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801603:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801608:	83 c4 24             	add    $0x24,%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 1c             	sub    $0x1c,%esp
  801617:	8b 7d 08             	mov    0x8(%ebp),%edi
  80161a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
  801622:	85 f6                	test   %esi,%esi
  801624:	74 30                	je     801656 <readn+0x48>
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80162b:	89 f2                	mov    %esi,%edx
  80162d:	29 c2                	sub    %eax,%edx
  80162f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801633:	03 45 0c             	add    0xc(%ebp),%eax
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	89 3c 24             	mov    %edi,(%esp)
  80163d:	e8 3c ff ff ff       	call   80157e <read>
		if (m < 0)
  801642:	85 c0                	test   %eax,%eax
  801644:	78 10                	js     801656 <readn+0x48>
			return m;
		if (m == 0)
  801646:	85 c0                	test   %eax,%eax
  801648:	74 0a                	je     801654 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164a:	01 c3                	add    %eax,%ebx
  80164c:	89 d8                	mov    %ebx,%eax
  80164e:	39 f3                	cmp    %esi,%ebx
  801650:	72 d9                	jb     80162b <readn+0x1d>
  801652:	eb 02                	jmp    801656 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801654:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801656:	83 c4 1c             	add    $0x1c,%esp
  801659:	5b                   	pop    %ebx
  80165a:	5e                   	pop    %esi
  80165b:	5f                   	pop    %edi
  80165c:	5d                   	pop    %ebp
  80165d:	c3                   	ret    

0080165e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	53                   	push   %ebx
  801662:	83 ec 24             	sub    $0x24,%esp
  801665:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801668:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166f:	89 1c 24             	mov    %ebx,(%esp)
  801672:	e8 47 fc ff ff       	call   8012be <fd_lookup>
  801677:	85 c0                	test   %eax,%eax
  801679:	78 68                	js     8016e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801685:	8b 00                	mov    (%eax),%eax
  801687:	89 04 24             	mov    %eax,(%esp)
  80168a:	e8 80 fc ff ff       	call   80130f <dev_lookup>
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 50                	js     8016e3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801693:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801696:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169a:	75 23                	jne    8016bf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80169c:	a1 20 60 80 00       	mov    0x806020,%eax
  8016a1:	8b 40 48             	mov    0x48(%eax),%eax
  8016a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ac:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  8016b3:	e8 1b ec ff ff       	call   8002d3 <cprintf>
		return -E_INVAL;
  8016b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bd:	eb 24                	jmp    8016e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c5:	85 d2                	test   %edx,%edx
  8016c7:	74 15                	je     8016de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016cc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016d7:	89 04 24             	mov    %eax,(%esp)
  8016da:	ff d2                	call   *%edx
  8016dc:	eb 05                	jmp    8016e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016e3:	83 c4 24             	add    $0x24,%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 bd fb ff ff       	call   8012be <fd_lookup>
  801701:	85 c0                	test   %eax,%eax
  801703:	78 0e                	js     801713 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801705:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801708:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 24             	sub    $0x24,%esp
  80171c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801722:	89 44 24 04          	mov    %eax,0x4(%esp)
  801726:	89 1c 24             	mov    %ebx,(%esp)
  801729:	e8 90 fb ff ff       	call   8012be <fd_lookup>
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 61                	js     801793 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801732:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801735:	89 44 24 04          	mov    %eax,0x4(%esp)
  801739:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173c:	8b 00                	mov    (%eax),%eax
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 c9 fb ff ff       	call   80130f <dev_lookup>
  801746:	85 c0                	test   %eax,%eax
  801748:	78 49                	js     801793 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801751:	75 23                	jne    801776 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801753:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801758:	8b 40 48             	mov    0x48(%eax),%eax
  80175b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  80176a:	e8 64 eb ff ff       	call   8002d3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80176f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801774:	eb 1d                	jmp    801793 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801776:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801779:	8b 52 18             	mov    0x18(%edx),%edx
  80177c:	85 d2                	test   %edx,%edx
  80177e:	74 0e                	je     80178e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801783:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801787:	89 04 24             	mov    %eax,(%esp)
  80178a:	ff d2                	call   *%edx
  80178c:	eb 05                	jmp    801793 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80178e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801793:	83 c4 24             	add    $0x24,%esp
  801796:	5b                   	pop    %ebx
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	53                   	push   %ebx
  80179d:	83 ec 24             	sub    $0x24,%esp
  8017a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	89 04 24             	mov    %eax,(%esp)
  8017b0:	e8 09 fb ff ff       	call   8012be <fd_lookup>
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 52                	js     80180b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c3:	8b 00                	mov    (%eax),%eax
  8017c5:	89 04 24             	mov    %eax,(%esp)
  8017c8:	e8 42 fb ff ff       	call   80130f <dev_lookup>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 3a                	js     80180b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8017d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017d8:	74 2c                	je     801806 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017e4:	00 00 00 
	stat->st_isdir = 0;
  8017e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ee:	00 00 00 
	stat->st_dev = dev;
  8017f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017fe:	89 14 24             	mov    %edx,(%esp)
  801801:	ff 50 14             	call   *0x14(%eax)
  801804:	eb 05                	jmp    80180b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801806:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80180b:	83 c4 24             	add    $0x24,%esp
  80180e:	5b                   	pop    %ebx
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	83 ec 18             	sub    $0x18,%esp
  801817:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80181a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80181d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801824:	00 
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	89 04 24             	mov    %eax,(%esp)
  80182b:	e8 bc 01 00 00       	call   8019ec <open>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	85 c0                	test   %eax,%eax
  801834:	78 1b                	js     801851 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	89 1c 24             	mov    %ebx,(%esp)
  801840:	e8 54 ff ff ff       	call   801799 <fstat>
  801845:	89 c6                	mov    %eax,%esi
	close(fd);
  801847:	89 1c 24             	mov    %ebx,(%esp)
  80184a:	e8 be fb ff ff       	call   80140d <close>
	return r;
  80184f:	89 f3                	mov    %esi,%ebx
}
  801851:	89 d8                	mov    %ebx,%eax
  801853:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801856:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801859:	89 ec                	mov    %ebp,%esp
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    
  80185d:	00 00                	add    %al,(%eax)
	...

00801860 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 18             	sub    $0x18,%esp
  801866:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801869:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80186c:	89 c3                	mov    %eax,%ebx
  80186e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801870:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801877:	75 11                	jne    80188a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801879:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801880:	e8 8c 09 00 00       	call   802211 <ipc_find_env>
  801885:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80188a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801891:	00 
  801892:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801899:	00 
  80189a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80189e:	a1 00 40 80 00       	mov    0x804000,%eax
  8018a3:	89 04 24             	mov    %eax,(%esp)
  8018a6:	e8 fb 08 00 00       	call   8021a6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8018ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018b2:	00 
  8018b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018be:	e8 7d 08 00 00       	call   802140 <ipc_recv>
}
  8018c3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018c6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018c9:	89 ec                	mov    %ebp,%esp
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 14             	sub    $0x14,%esp
  8018d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dd:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ec:	e8 6f ff ff ff       	call   801860 <fsipc>
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 2b                	js     801920 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8018fc:	00 
  8018fd:	89 1c 24             	mov    %ebx,(%esp)
  801900:	e8 16 f1 ff ff       	call   800a1b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801905:	a1 80 70 80 00       	mov    0x807080,%eax
  80190a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801910:	a1 84 70 80 00       	mov    0x807084,%eax
  801915:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80191b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801920:	83 c4 14             	add    $0x14,%esp
  801923:	5b                   	pop    %ebx
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	8b 40 0c             	mov    0xc(%eax),%eax
  801932:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801937:	ba 00 00 00 00       	mov    $0x0,%edx
  80193c:	b8 06 00 00 00       	mov    $0x6,%eax
  801941:	e8 1a ff ff ff       	call   801860 <fsipc>
}
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	83 ec 10             	sub    $0x10,%esp
  801950:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801953:	8b 45 08             	mov    0x8(%ebp),%eax
  801956:	8b 40 0c             	mov    0xc(%eax),%eax
  801959:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80195e:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801964:	ba 00 00 00 00       	mov    $0x0,%edx
  801969:	b8 03 00 00 00       	mov    $0x3,%eax
  80196e:	e8 ed fe ff ff       	call   801860 <fsipc>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	85 c0                	test   %eax,%eax
  801977:	78 6a                	js     8019e3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801979:	39 c6                	cmp    %eax,%esi
  80197b:	73 24                	jae    8019a1 <devfile_read+0x59>
  80197d:	c7 44 24 0c bc 29 80 	movl   $0x8029bc,0xc(%esp)
  801984:	00 
  801985:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  80198c:	00 
  80198d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801994:	00 
  801995:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  80199c:	e8 37 e8 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8019a1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a6:	7e 24                	jle    8019cc <devfile_read+0x84>
  8019a8:	c7 44 24 0c e3 29 80 	movl   $0x8029e3,0xc(%esp)
  8019af:	00 
  8019b0:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  8019b7:	00 
  8019b8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019bf:	00 
  8019c0:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  8019c7:	e8 0c e8 ff ff       	call   8001d8 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d0:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8019d7:	00 
  8019d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 29 f2 ff ff       	call   800c0c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  8019e3:	89 d8                	mov    %ebx,%eax
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5d                   	pop    %ebp
  8019eb:	c3                   	ret    

008019ec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	56                   	push   %esi
  8019f0:	53                   	push   %ebx
  8019f1:	83 ec 20             	sub    $0x20,%esp
  8019f4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019f7:	89 34 24             	mov    %esi,(%esp)
  8019fa:	e8 d1 ef ff ff       	call   8009d0 <strlen>
		return -E_BAD_PATH;
  8019ff:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a09:	7f 5e                	jg     801a69 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 35 f8 ff ff       	call   80124b <fd_alloc>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	78 4d                	js     801a69 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a20:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801a27:	e8 ef ef ff ff       	call   800a1b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2f:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a37:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3c:	e8 1f fe ff ff       	call   801860 <fsipc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	85 c0                	test   %eax,%eax
  801a45:	79 15                	jns    801a5c <open+0x70>
		fd_close(fd, 0);
  801a47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a4e:	00 
  801a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	e8 21 f9 ff ff       	call   80137b <fd_close>
		return r;
  801a5a:	eb 0d                	jmp    801a69 <open+0x7d>
	}

	return fd2num(fd);
  801a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5f:	89 04 24             	mov    %eax,(%esp)
  801a62:	e8 b9 f7 ff ff       	call   801220 <fd2num>
  801a67:	89 c3                	mov    %eax,%ebx
}
  801a69:	89 d8                	mov    %ebx,%eax
  801a6b:	83 c4 20             	add    $0x20,%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    
	...

00801a74 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	53                   	push   %ebx
  801a78:	83 ec 14             	sub    $0x14,%esp
  801a7b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a7d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a81:	7e 31                	jle    801ab4 <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a83:	8b 40 04             	mov    0x4(%eax),%eax
  801a86:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8a:	8d 43 10             	lea    0x10(%ebx),%eax
  801a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a91:	8b 03                	mov    (%ebx),%eax
  801a93:	89 04 24             	mov    %eax,(%esp)
  801a96:	e8 c3 fb ff ff       	call   80165e <write>
		if (result > 0)
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	7e 03                	jle    801aa2 <writebuf+0x2e>
			b->result += result;
  801a9f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801aa2:	39 43 04             	cmp    %eax,0x4(%ebx)
  801aa5:	74 0d                	je     801ab4 <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aae:	0f 4f c2             	cmovg  %edx,%eax
  801ab1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801ab4:	83 c4 14             	add    $0x14,%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <putch>:

static void
putch(int ch, void *thunk)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	53                   	push   %ebx
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801ac4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  801aca:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801ace:	83 c0 01             	add    $0x1,%eax
  801ad1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801ad4:	3d 00 01 00 00       	cmp    $0x100,%eax
  801ad9:	75 0e                	jne    801ae9 <putch+0x2f>
		writebuf(b);
  801adb:	89 d8                	mov    %ebx,%eax
  801add:	e8 92 ff ff ff       	call   801a74 <writebuf>
		b->idx = 0;
  801ae2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ae9:	83 c4 04             	add    $0x4,%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b01:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b08:	00 00 00 
	b.result = 0;
  801b0b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b12:	00 00 00 
	b.error = 1;
  801b15:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b1c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b29:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b2d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b37:	c7 04 24 ba 1a 80 00 	movl   $0x801aba,(%esp)
  801b3e:	e8 07 e9 ff ff       	call   80044a <vprintfmt>
	if (b.idx > 0)
  801b43:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801b4a:	7e 0b                	jle    801b57 <vfprintf+0x68>
		writebuf(&b);
  801b4c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b52:	e8 1d ff ff ff       	call   801a74 <writebuf>

	return (b.result ? b.result : b.error);
  801b57:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b6e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7f:	89 04 24             	mov    %eax,(%esp)
  801b82:	e8 68 ff ff ff       	call   801aef <vfprintf>
	va_end(ap);

	return cnt;
}
  801b87:	c9                   	leave  
  801b88:	c3                   	ret    

00801b89 <printf>:

int
printf(const char *fmt, ...)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b8f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ba4:	e8 46 ff ff ff       	call   801aef <vfprintf>
	va_end(ap);

	return cnt;
}
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    
  801bab:	00 00                	add    %al,(%eax)
  801bad:	00 00                	add    %al,(%eax)
	...

00801bb0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 18             	sub    $0x18,%esp
  801bb6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bb9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	e8 66 f6 ff ff       	call   801230 <fd2data>
  801bca:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bcc:	c7 44 24 04 ef 29 80 	movl   $0x8029ef,0x4(%esp)
  801bd3:	00 
  801bd4:	89 34 24             	mov    %esi,(%esp)
  801bd7:	e8 3f ee ff ff       	call   800a1b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bdc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bdf:	2b 03                	sub    (%ebx),%eax
  801be1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801be7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bee:	00 00 00 
	stat->st_dev = &devpipe;
  801bf1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801bf8:	30 80 00 
	return 0;
}
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801c00:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c03:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c06:	89 ec                	mov    %ebp,%esp
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	53                   	push   %ebx
  801c0e:	83 ec 14             	sub    $0x14,%esp
  801c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1f:	e8 b5 f3 ff ff       	call   800fd9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c24:	89 1c 24             	mov    %ebx,(%esp)
  801c27:	e8 04 f6 ff ff       	call   801230 <fd2data>
  801c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c37:	e8 9d f3 ff ff       	call   800fd9 <sys_page_unmap>
}
  801c3c:	83 c4 14             	add    $0x14,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	57                   	push   %edi
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 2c             	sub    $0x2c,%esp
  801c4b:	89 c7                	mov    %eax,%edi
  801c4d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c50:	a1 20 60 80 00       	mov    0x806020,%eax
  801c55:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c58:	89 3c 24             	mov    %edi,(%esp)
  801c5b:	e8 fc 05 00 00       	call   80225c <pageref>
  801c60:	89 c6                	mov    %eax,%esi
  801c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c65:	89 04 24             	mov    %eax,(%esp)
  801c68:	e8 ef 05 00 00       	call   80225c <pageref>
  801c6d:	39 c6                	cmp    %eax,%esi
  801c6f:	0f 94 c0             	sete   %al
  801c72:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c75:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c7b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c7e:	39 cb                	cmp    %ecx,%ebx
  801c80:	75 08                	jne    801c8a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c82:	83 c4 2c             	add    $0x2c,%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5f                   	pop    %edi
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c8a:	83 f8 01             	cmp    $0x1,%eax
  801c8d:	75 c1                	jne    801c50 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c8f:	8b 52 58             	mov    0x58(%edx),%edx
  801c92:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c96:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c9e:	c7 04 24 f6 29 80 00 	movl   $0x8029f6,(%esp)
  801ca5:	e8 29 e6 ff ff       	call   8002d3 <cprintf>
  801caa:	eb a4                	jmp    801c50 <_pipeisclosed+0xe>

00801cac <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	57                   	push   %edi
  801cb0:	56                   	push   %esi
  801cb1:	53                   	push   %ebx
  801cb2:	83 ec 2c             	sub    $0x2c,%esp
  801cb5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cb8:	89 34 24             	mov    %esi,(%esp)
  801cbb:	e8 70 f5 ff ff       	call   801230 <fd2data>
  801cc0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc2:	bf 00 00 00 00       	mov    $0x0,%edi
  801cc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ccb:	75 50                	jne    801d1d <devpipe_write+0x71>
  801ccd:	eb 5c                	jmp    801d2b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ccf:	89 da                	mov    %ebx,%edx
  801cd1:	89 f0                	mov    %esi,%eax
  801cd3:	e8 6a ff ff ff       	call   801c42 <_pipeisclosed>
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	75 53                	jne    801d2f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cdc:	e8 0b f2 ff ff       	call   800eec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ce1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce4:	8b 13                	mov    (%ebx),%edx
  801ce6:	83 c2 20             	add    $0x20,%edx
  801ce9:	39 d0                	cmp    %edx,%eax
  801ceb:	73 e2                	jae    801ccf <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ced:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801cf4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801cf7:	89 c2                	mov    %eax,%edx
  801cf9:	c1 fa 1f             	sar    $0x1f,%edx
  801cfc:	c1 ea 1b             	shr    $0x1b,%edx
  801cff:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d02:	83 e1 1f             	and    $0x1f,%ecx
  801d05:	29 d1                	sub    %edx,%ecx
  801d07:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d0b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d0f:	83 c0 01             	add    $0x1,%eax
  801d12:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d15:	83 c7 01             	add    $0x1,%edi
  801d18:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d1b:	74 0e                	je     801d2b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801d20:	8b 13                	mov    (%ebx),%edx
  801d22:	83 c2 20             	add    $0x20,%edx
  801d25:	39 d0                	cmp    %edx,%eax
  801d27:	73 a6                	jae    801ccf <devpipe_write+0x23>
  801d29:	eb c2                	jmp    801ced <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d2b:	89 f8                	mov    %edi,%eax
  801d2d:	eb 05                	jmp    801d34 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d34:	83 c4 2c             	add    $0x2c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 28             	sub    $0x28,%esp
  801d42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801d45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d48:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d4b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d4e:	89 3c 24             	mov    %edi,(%esp)
  801d51:	e8 da f4 ff ff       	call   801230 <fd2data>
  801d56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d58:	be 00 00 00 00       	mov    $0x0,%esi
  801d5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d61:	75 47                	jne    801daa <devpipe_read+0x6e>
  801d63:	eb 52                	jmp    801db7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	eb 5e                	jmp    801dc7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d69:	89 da                	mov    %ebx,%edx
  801d6b:	89 f8                	mov    %edi,%eax
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	e8 cd fe ff ff       	call   801c42 <_pipeisclosed>
  801d75:	85 c0                	test   %eax,%eax
  801d77:	75 49                	jne    801dc2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801d79:	e8 6e f1 ff ff       	call   800eec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d7e:	8b 03                	mov    (%ebx),%eax
  801d80:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d83:	74 e4                	je     801d69 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d85:	89 c2                	mov    %eax,%edx
  801d87:	c1 fa 1f             	sar    $0x1f,%edx
  801d8a:	c1 ea 1b             	shr    $0x1b,%edx
  801d8d:	01 d0                	add    %edx,%eax
  801d8f:	83 e0 1f             	and    $0x1f,%eax
  801d92:	29 d0                	sub    %edx,%eax
  801d94:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d9f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da2:	83 c6 01             	add    $0x1,%esi
  801da5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da8:	74 0d                	je     801db7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801daa:	8b 03                	mov    (%ebx),%eax
  801dac:	3b 43 04             	cmp    0x4(%ebx),%eax
  801daf:	75 d4                	jne    801d85 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801db1:	85 f6                	test   %esi,%esi
  801db3:	75 b0                	jne    801d65 <devpipe_read+0x29>
  801db5:	eb b2                	jmp    801d69 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801db7:	89 f0                	mov    %esi,%eax
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	eb 05                	jmp    801dc7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801dca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801dcd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801dd0:	89 ec                	mov    %ebp,%esp
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 48             	sub    $0x48,%esp
  801dda:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ddd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801de0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801de3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801de9:	89 04 24             	mov    %eax,(%esp)
  801dec:	e8 5a f4 ff ff       	call   80124b <fd_alloc>
  801df1:	89 c3                	mov    %eax,%ebx
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 45 01 00 00    	js     801f40 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e02:	00 
  801e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e11:	e8 06 f1 ff ff       	call   800f1c <sys_page_alloc>
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	0f 88 20 01 00 00    	js     801f40 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e20:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e23:	89 04 24             	mov    %eax,(%esp)
  801e26:	e8 20 f4 ff ff       	call   80124b <fd_alloc>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	0f 88 f8 00 00 00    	js     801f2d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e35:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e3c:	00 
  801e3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4b:	e8 cc f0 ff ff       	call   800f1c <sys_page_alloc>
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 d3 00 00 00    	js     801f2d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e5d:	89 04 24             	mov    %eax,(%esp)
  801e60:	e8 cb f3 ff ff       	call   801230 <fd2data>
  801e65:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e67:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e6e:	00 
  801e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e7a:	e8 9d f0 ff ff       	call   800f1c <sys_page_alloc>
  801e7f:	89 c3                	mov    %eax,%ebx
  801e81:	85 c0                	test   %eax,%eax
  801e83:	0f 88 91 00 00 00    	js     801f1a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e8c:	89 04 24             	mov    %eax,(%esp)
  801e8f:	e8 9c f3 ff ff       	call   801230 <fd2data>
  801e94:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e9b:	00 
  801e9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ea7:	00 
  801ea8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb3:	e8 c3 f0 ff ff       	call   800f7b <sys_page_map>
  801eb8:	89 c3                	mov    %eax,%ebx
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 4c                	js     801f0a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ebe:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ecc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ed3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ed9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801edc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ede:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ee1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ee8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eeb:	89 04 24             	mov    %eax,(%esp)
  801eee:	e8 2d f3 ff ff       	call   801220 <fd2num>
  801ef3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef8:	89 04 24             	mov    %eax,(%esp)
  801efb:	e8 20 f3 ff ff       	call   801220 <fd2num>
  801f00:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f08:	eb 36                	jmp    801f40 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801f0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f15:	e8 bf f0 ff ff       	call   800fd9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f28:	e8 ac f0 ff ff       	call   800fd9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3b:	e8 99 f0 ff ff       	call   800fd9 <sys_page_unmap>
    err:
	return r;
}
  801f40:	89 d8                	mov    %ebx,%eax
  801f42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801f4b:	89 ec                	mov    %ebp,%esp
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5f:	89 04 24             	mov    %eax,(%esp)
  801f62:	e8 57 f3 ff ff       	call   8012be <fd_lookup>
  801f67:	85 c0                	test   %eax,%eax
  801f69:	78 15                	js     801f80 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	e8 ba f2 ff ff       	call   801230 <fd2data>
	return _pipeisclosed(fd, p);
  801f76:	89 c2                	mov    %eax,%edx
  801f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7b:	e8 c2 fc ff ff       	call   801c42 <_pipeisclosed>
}
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    
	...

00801f90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fa0:	c7 44 24 04 0e 2a 80 	movl   $0x802a0e,0x4(%esp)
  801fa7:	00 
  801fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fab:	89 04 24             	mov    %eax,(%esp)
  801fae:	e8 68 ea ff ff       	call   800a1b <strcpy>
	return 0;
}
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	57                   	push   %edi
  801fbe:	56                   	push   %esi
  801fbf:	53                   	push   %ebx
  801fc0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc6:	be 00 00 00 00       	mov    $0x0,%esi
  801fcb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fcf:	74 43                	je     802014 <devcons_write+0x5a>
  801fd1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fd6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fdf:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801fe1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fe4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fe9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ff0:	03 45 0c             	add    0xc(%ebp),%eax
  801ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff7:	89 3c 24             	mov    %edi,(%esp)
  801ffa:	e8 0d ec ff ff       	call   800c0c <memmove>
		sys_cputs(buf, m);
  801fff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802003:	89 3c 24             	mov    %edi,(%esp)
  802006:	e8 f5 ed ff ff       	call   800e00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80200b:	01 de                	add    %ebx,%esi
  80200d:	89 f0                	mov    %esi,%eax
  80200f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802012:	72 c8                	jb     801fdc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802014:	89 f0                	mov    %esi,%eax
  802016:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5e                   	pop    %esi
  80201e:	5f                   	pop    %edi
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    

00802021 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80202c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802030:	75 07                	jne    802039 <devcons_read+0x18>
  802032:	eb 31                	jmp    802065 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802034:	e8 b3 ee ff ff       	call   800eec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	e8 ea ed ff ff       	call   800e2f <sys_cgetc>
  802045:	85 c0                	test   %eax,%eax
  802047:	74 eb                	je     802034 <devcons_read+0x13>
  802049:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 16                	js     802065 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80204f:	83 f8 04             	cmp    $0x4,%eax
  802052:	74 0c                	je     802060 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802054:	8b 45 0c             	mov    0xc(%ebp),%eax
  802057:	88 10                	mov    %dl,(%eax)
	return 1;
  802059:	b8 01 00 00 00       	mov    $0x1,%eax
  80205e:	eb 05                	jmp    802065 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802060:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802065:	c9                   	leave  
  802066:	c3                   	ret    

00802067 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80206d:	8b 45 08             	mov    0x8(%ebp),%eax
  802070:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802073:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80207a:	00 
  80207b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80207e:	89 04 24             	mov    %eax,(%esp)
  802081:	e8 7a ed ff ff       	call   800e00 <sys_cputs>
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <getchar>:

int
getchar(void)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80208e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802095:	00 
  802096:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a4:	e8 d5 f4 ff ff       	call   80157e <read>
	if (r < 0)
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 0f                	js     8020bc <getchar+0x34>
		return r;
	if (r < 1)
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	7e 06                	jle    8020b7 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020b5:	eb 05                	jmp    8020bc <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020b7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    

008020be <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ce:	89 04 24             	mov    %eax,(%esp)
  8020d1:	e8 e8 f1 ff ff       	call   8012be <fd_lookup>
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	78 11                	js     8020eb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020e3:	39 10                	cmp    %edx,(%eax)
  8020e5:	0f 94 c0             	sete   %al
  8020e8:	0f b6 c0             	movzbl %al,%eax
}
  8020eb:	c9                   	leave  
  8020ec:	c3                   	ret    

008020ed <opencons>:

int
opencons(void)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	89 04 24             	mov    %eax,(%esp)
  8020f9:	e8 4d f1 ff ff       	call   80124b <fd_alloc>
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 3c                	js     80213e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802102:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802109:	00 
  80210a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802118:	e8 ff ed ff ff       	call   800f1c <sys_page_alloc>
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 1d                	js     80213e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802121:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80212c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802136:	89 04 24             	mov    %eax,(%esp)
  802139:	e8 e2 f0 ff ff       	call   801220 <fd2num>
}
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	56                   	push   %esi
  802144:	53                   	push   %ebx
  802145:	83 ec 10             	sub    $0x10,%esp
  802148:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80214b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802151:	85 db                	test   %ebx,%ebx
  802153:	74 06                	je     80215b <ipc_recv+0x1b>
  802155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80215b:	85 f6                	test   %esi,%esi
  80215d:	74 06                	je     802165 <ipc_recv+0x25>
  80215f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802165:	85 c0                	test   %eax,%eax
  802167:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80216c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80216f:	89 04 24             	mov    %eax,(%esp)
  802172:	e8 0e f0 ff ff       	call   801185 <sys_ipc_recv>
    if (ret) return ret;
  802177:	85 c0                	test   %eax,%eax
  802179:	75 24                	jne    80219f <ipc_recv+0x5f>
    if (from_env_store)
  80217b:	85 db                	test   %ebx,%ebx
  80217d:	74 0a                	je     802189 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80217f:	a1 20 60 80 00       	mov    0x806020,%eax
  802184:	8b 40 74             	mov    0x74(%eax),%eax
  802187:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802189:	85 f6                	test   %esi,%esi
  80218b:	74 0a                	je     802197 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80218d:	a1 20 60 80 00       	mov    0x806020,%eax
  802192:	8b 40 78             	mov    0x78(%eax),%eax
  802195:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802197:	a1 20 60 80 00       	mov    0x806020,%eax
  80219c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80219f:	83 c4 10             	add    $0x10,%esp
  8021a2:	5b                   	pop    %ebx
  8021a3:	5e                   	pop    %esi
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    

008021a6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	57                   	push   %edi
  8021aa:	56                   	push   %esi
  8021ab:	53                   	push   %ebx
  8021ac:	83 ec 1c             	sub    $0x1c,%esp
  8021af:	8b 75 08             	mov    0x8(%ebp),%esi
  8021b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8021b8:	85 db                	test   %ebx,%ebx
  8021ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8021bf:	0f 44 d8             	cmove  %eax,%ebx
  8021c2:	eb 2a                	jmp    8021ee <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8021c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021c7:	74 20                	je     8021e9 <ipc_send+0x43>
  8021c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021cd:	c7 44 24 08 1a 2a 80 	movl   $0x802a1a,0x8(%esp)
  8021d4:	00 
  8021d5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8021dc:	00 
  8021dd:	c7 04 24 31 2a 80 00 	movl   $0x802a31,(%esp)
  8021e4:	e8 ef df ff ff       	call   8001d8 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8021e9:	e8 fe ec ff ff       	call   800eec <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8021ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8021f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021fd:	89 34 24             	mov    %esi,(%esp)
  802200:	e8 4c ef ff ff       	call   801151 <sys_ipc_try_send>
  802205:	85 c0                	test   %eax,%eax
  802207:	75 bb                	jne    8021c4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802209:	83 c4 1c             	add    $0x1c,%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5e                   	pop    %esi
  80220e:	5f                   	pop    %edi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    

00802211 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802217:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80221c:	39 c8                	cmp    %ecx,%eax
  80221e:	74 19                	je     802239 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802220:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802225:	89 c2                	mov    %eax,%edx
  802227:	c1 e2 07             	shl    $0x7,%edx
  80222a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802230:	8b 52 50             	mov    0x50(%edx),%edx
  802233:	39 ca                	cmp    %ecx,%edx
  802235:	75 14                	jne    80224b <ipc_find_env+0x3a>
  802237:	eb 05                	jmp    80223e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802239:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80223e:	c1 e0 07             	shl    $0x7,%eax
  802241:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802246:	8b 40 40             	mov    0x40(%eax),%eax
  802249:	eb 0e                	jmp    802259 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80224b:	83 c0 01             	add    $0x1,%eax
  80224e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802253:	75 d0                	jne    802225 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802255:	66 b8 00 00          	mov    $0x0,%ax
}
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
	...

0080225c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802262:	89 d0                	mov    %edx,%eax
  802264:	c1 e8 16             	shr    $0x16,%eax
  802267:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80226e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802273:	f6 c1 01             	test   $0x1,%cl
  802276:	74 1d                	je     802295 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802278:	c1 ea 0c             	shr    $0xc,%edx
  80227b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802282:	f6 c2 01             	test   $0x1,%dl
  802285:	74 0e                	je     802295 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802287:	c1 ea 0c             	shr    $0xc,%edx
  80228a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802291:	ef 
  802292:	0f b7 c0             	movzwl %ax,%eax
}
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    
	...

008022a0 <__udivdi3>:
  8022a0:	83 ec 1c             	sub    $0x1c,%esp
  8022a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8022a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8022ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8022af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8022b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8022b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8022bb:	85 ff                	test   %edi,%edi
  8022bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8022c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022c5:	89 cd                	mov    %ecx,%ebp
  8022c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cb:	75 33                	jne    802300 <__udivdi3+0x60>
  8022cd:	39 f1                	cmp    %esi,%ecx
  8022cf:	77 57                	ja     802328 <__udivdi3+0x88>
  8022d1:	85 c9                	test   %ecx,%ecx
  8022d3:	75 0b                	jne    8022e0 <__udivdi3+0x40>
  8022d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8022da:	31 d2                	xor    %edx,%edx
  8022dc:	f7 f1                	div    %ecx
  8022de:	89 c1                	mov    %eax,%ecx
  8022e0:	89 f0                	mov    %esi,%eax
  8022e2:	31 d2                	xor    %edx,%edx
  8022e4:	f7 f1                	div    %ecx
  8022e6:	89 c6                	mov    %eax,%esi
  8022e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022ec:	f7 f1                	div    %ecx
  8022ee:	89 f2                	mov    %esi,%edx
  8022f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	c3                   	ret    
  802300:	31 d2                	xor    %edx,%edx
  802302:	31 c0                	xor    %eax,%eax
  802304:	39 f7                	cmp    %esi,%edi
  802306:	77 e8                	ja     8022f0 <__udivdi3+0x50>
  802308:	0f bd cf             	bsr    %edi,%ecx
  80230b:	83 f1 1f             	xor    $0x1f,%ecx
  80230e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802312:	75 2c                	jne    802340 <__udivdi3+0xa0>
  802314:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802318:	76 04                	jbe    80231e <__udivdi3+0x7e>
  80231a:	39 f7                	cmp    %esi,%edi
  80231c:	73 d2                	jae    8022f0 <__udivdi3+0x50>
  80231e:	31 d2                	xor    %edx,%edx
  802320:	b8 01 00 00 00       	mov    $0x1,%eax
  802325:	eb c9                	jmp    8022f0 <__udivdi3+0x50>
  802327:	90                   	nop
  802328:	89 f2                	mov    %esi,%edx
  80232a:	f7 f1                	div    %ecx
  80232c:	31 d2                	xor    %edx,%edx
  80232e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802332:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802336:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	c3                   	ret    
  80233e:	66 90                	xchg   %ax,%ax
  802340:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802345:	b8 20 00 00 00       	mov    $0x20,%eax
  80234a:	89 ea                	mov    %ebp,%edx
  80234c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802350:	d3 e7                	shl    %cl,%edi
  802352:	89 c1                	mov    %eax,%ecx
  802354:	d3 ea                	shr    %cl,%edx
  802356:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80235b:	09 fa                	or     %edi,%edx
  80235d:	89 f7                	mov    %esi,%edi
  80235f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802363:	89 f2                	mov    %esi,%edx
  802365:	8b 74 24 08          	mov    0x8(%esp),%esi
  802369:	d3 e5                	shl    %cl,%ebp
  80236b:	89 c1                	mov    %eax,%ecx
  80236d:	d3 ef                	shr    %cl,%edi
  80236f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802374:	d3 e2                	shl    %cl,%edx
  802376:	89 c1                	mov    %eax,%ecx
  802378:	d3 ee                	shr    %cl,%esi
  80237a:	09 d6                	or     %edx,%esi
  80237c:	89 fa                	mov    %edi,%edx
  80237e:	89 f0                	mov    %esi,%eax
  802380:	f7 74 24 0c          	divl   0xc(%esp)
  802384:	89 d7                	mov    %edx,%edi
  802386:	89 c6                	mov    %eax,%esi
  802388:	f7 e5                	mul    %ebp
  80238a:	39 d7                	cmp    %edx,%edi
  80238c:	72 22                	jb     8023b0 <__udivdi3+0x110>
  80238e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802392:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802397:	d3 e5                	shl    %cl,%ebp
  802399:	39 c5                	cmp    %eax,%ebp
  80239b:	73 04                	jae    8023a1 <__udivdi3+0x101>
  80239d:	39 d7                	cmp    %edx,%edi
  80239f:	74 0f                	je     8023b0 <__udivdi3+0x110>
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	e9 46 ff ff ff       	jmp    8022f0 <__udivdi3+0x50>
  8023aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8023bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	c3                   	ret    
	...

008023d0 <__umoddi3>:
  8023d0:	83 ec 1c             	sub    $0x1c,%esp
  8023d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8023d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8023db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8023df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8023e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8023e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8023eb:	85 ed                	test   %ebp,%ebp
  8023ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8023f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023f5:	89 cf                	mov    %ecx,%edi
  8023f7:	89 04 24             	mov    %eax,(%esp)
  8023fa:	89 f2                	mov    %esi,%edx
  8023fc:	75 1a                	jne    802418 <__umoddi3+0x48>
  8023fe:	39 f1                	cmp    %esi,%ecx
  802400:	76 4e                	jbe    802450 <__umoddi3+0x80>
  802402:	f7 f1                	div    %ecx
  802404:	89 d0                	mov    %edx,%eax
  802406:	31 d2                	xor    %edx,%edx
  802408:	8b 74 24 10          	mov    0x10(%esp),%esi
  80240c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802410:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802414:	83 c4 1c             	add    $0x1c,%esp
  802417:	c3                   	ret    
  802418:	39 f5                	cmp    %esi,%ebp
  80241a:	77 54                	ja     802470 <__umoddi3+0xa0>
  80241c:	0f bd c5             	bsr    %ebp,%eax
  80241f:	83 f0 1f             	xor    $0x1f,%eax
  802422:	89 44 24 04          	mov    %eax,0x4(%esp)
  802426:	75 60                	jne    802488 <__umoddi3+0xb8>
  802428:	3b 0c 24             	cmp    (%esp),%ecx
  80242b:	0f 87 07 01 00 00    	ja     802538 <__umoddi3+0x168>
  802431:	89 f2                	mov    %esi,%edx
  802433:	8b 34 24             	mov    (%esp),%esi
  802436:	29 ce                	sub    %ecx,%esi
  802438:	19 ea                	sbb    %ebp,%edx
  80243a:	89 34 24             	mov    %esi,(%esp)
  80243d:	8b 04 24             	mov    (%esp),%eax
  802440:	8b 74 24 10          	mov    0x10(%esp),%esi
  802444:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802448:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80244c:	83 c4 1c             	add    $0x1c,%esp
  80244f:	c3                   	ret    
  802450:	85 c9                	test   %ecx,%ecx
  802452:	75 0b                	jne    80245f <__umoddi3+0x8f>
  802454:	b8 01 00 00 00       	mov    $0x1,%eax
  802459:	31 d2                	xor    %edx,%edx
  80245b:	f7 f1                	div    %ecx
  80245d:	89 c1                	mov    %eax,%ecx
  80245f:	89 f0                	mov    %esi,%eax
  802461:	31 d2                	xor    %edx,%edx
  802463:	f7 f1                	div    %ecx
  802465:	8b 04 24             	mov    (%esp),%eax
  802468:	f7 f1                	div    %ecx
  80246a:	eb 98                	jmp    802404 <__umoddi3+0x34>
  80246c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 f2                	mov    %esi,%edx
  802472:	8b 74 24 10          	mov    0x10(%esp),%esi
  802476:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80247a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80247e:	83 c4 1c             	add    $0x1c,%esp
  802481:	c3                   	ret    
  802482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802488:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80248d:	89 e8                	mov    %ebp,%eax
  80248f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802494:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802498:	89 fa                	mov    %edi,%edx
  80249a:	d3 e0                	shl    %cl,%eax
  80249c:	89 e9                	mov    %ebp,%ecx
  80249e:	d3 ea                	shr    %cl,%edx
  8024a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024a5:	09 c2                	or     %eax,%edx
  8024a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024ab:	89 14 24             	mov    %edx,(%esp)
  8024ae:	89 f2                	mov    %esi,%edx
  8024b0:	d3 e7                	shl    %cl,%edi
  8024b2:	89 e9                	mov    %ebp,%ecx
  8024b4:	d3 ea                	shr    %cl,%edx
  8024b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024bf:	d3 e6                	shl    %cl,%esi
  8024c1:	89 e9                	mov    %ebp,%ecx
  8024c3:	d3 e8                	shr    %cl,%eax
  8024c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024ca:	09 f0                	or     %esi,%eax
  8024cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024d0:	f7 34 24             	divl   (%esp)
  8024d3:	d3 e6                	shl    %cl,%esi
  8024d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8024d9:	89 d6                	mov    %edx,%esi
  8024db:	f7 e7                	mul    %edi
  8024dd:	39 d6                	cmp    %edx,%esi
  8024df:	89 c1                	mov    %eax,%ecx
  8024e1:	89 d7                	mov    %edx,%edi
  8024e3:	72 3f                	jb     802524 <__umoddi3+0x154>
  8024e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024e9:	72 35                	jb     802520 <__umoddi3+0x150>
  8024eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024ef:	29 c8                	sub    %ecx,%eax
  8024f1:	19 fe                	sbb    %edi,%esi
  8024f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024f8:	89 f2                	mov    %esi,%edx
  8024fa:	d3 e8                	shr    %cl,%eax
  8024fc:	89 e9                	mov    %ebp,%ecx
  8024fe:	d3 e2                	shl    %cl,%edx
  802500:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802505:	09 d0                	or     %edx,%eax
  802507:	89 f2                	mov    %esi,%edx
  802509:	d3 ea                	shr    %cl,%edx
  80250b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80250f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802513:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802517:	83 c4 1c             	add    $0x1c,%esp
  80251a:	c3                   	ret    
  80251b:	90                   	nop
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	39 d6                	cmp    %edx,%esi
  802522:	75 c7                	jne    8024eb <__umoddi3+0x11b>
  802524:	89 d7                	mov    %edx,%edi
  802526:	89 c1                	mov    %eax,%ecx
  802528:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80252c:	1b 3c 24             	sbb    (%esp),%edi
  80252f:	eb ba                	jmp    8024eb <__umoddi3+0x11b>
  802531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802538:	39 f5                	cmp    %esi,%ebp
  80253a:	0f 82 f1 fe ff ff    	jb     802431 <__umoddi3+0x61>
  802540:	e9 f8 fe ff ff       	jmp    80243d <__umoddi3+0x6d>
