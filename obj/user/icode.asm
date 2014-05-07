
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 40 80 00 c0 	movl   $0x802ac0,0x804000
  800046:	2a 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 c6 2a 80 00 	movl   $0x802ac6,(%esp)
  800050:	e8 6e 02 00 00       	call   8002c3 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 d5 2a 80 00 	movl   $0x802ad5,(%esp)
  80005c:	e8 62 02 00 00       	call   8002c3 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 e8 2a 80 00 	movl   $0x802ae8,(%esp)
  800070:	e8 67 19 00 00       	call   8019dc <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 ee 2a 80 	movl   $0x802aee,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 04 2b 80 00 	movl   $0x802b04,(%esp)
  800096:	e8 2d 01 00 00       	call   8001c8 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 11 2b 80 00 	movl   $0x802b11,(%esp)
  8000a2:	e8 1c 02 00 00       	call   8002c3 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 35 0d 00 00       	call   800df0 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 9f 14 00 00       	call   80156e <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 24 2b 80 00 	movl   $0x802b24,(%esp)
  8000da:	e8 e4 01 00 00       	call   8002c3 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 16 13 00 00       	call   8013fd <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 38 2b 80 00 	movl   $0x802b38,(%esp)
  8000ee:	e8 d0 01 00 00       	call   8002c3 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 4c 2b 80 	movl   $0x802b4c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 55 2b 80 	movl   $0x802b55,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 5f 2b 80 	movl   $0x802b5f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 5e 2b 80 00 	movl   $0x802b5e,(%esp)
  80011a:	e8 65 1f 00 00       	call   802084 <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 64 2b 80 	movl   $0x802b64,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 04 2b 80 00 	movl   $0x802b04,(%esp)
  80013e:	e8 85 00 00 00       	call   8001c8 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 7b 2b 80 00 	movl   $0x802b7b,(%esp)
  80014a:	e8 74 01 00 00       	call   8002c3 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
  800162:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800165:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800168:	8b 75 08             	mov    0x8(%ebp),%esi
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80016e:	e8 39 0d 00 00       	call   800eac <sys_getenvid>
  800173:	25 ff 03 00 00       	and    $0x3ff,%eax
  800178:	c1 e0 07             	shl    $0x7,%eax
  80017b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800180:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800185:	85 f6                	test   %esi,%esi
  800187:	7e 07                	jle    800190 <libmain+0x34>
		binaryname = argv[0];
  800189:	8b 03                	mov    (%ebx),%eax
  80018b:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800190:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800194:	89 34 24             	mov    %esi,(%esp)
  800197:	e8 98 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80019c:	e8 0b 00 00 00       	call   8001ac <exit>
}
  8001a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a7:	89 ec                	mov    %ebp,%esp
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    
	...

008001ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b2:	e8 77 12 00 00       	call   80142e <close_all>
	sys_env_destroy(0);
  8001b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001be:	e8 8c 0c 00 00       	call   800e4f <sys_env_destroy>
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
  8001c5:	00 00                	add    %al,(%eax)
	...

008001c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001d0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d3:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001d9:	e8 ce 0c 00 00       	call   800eac <sys_getenvid>
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 98 2b 80 00 	movl   $0x802b98,(%esp)
  8001fb:	e8 c3 00 00 00       	call   8002c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	89 74 24 04          	mov    %esi,0x4(%esp)
  800204:	8b 45 10             	mov    0x10(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 53 00 00 00       	call   800262 <vcprintf>
	cprintf("\n");
  80020f:	c7 04 24 b0 30 80 00 	movl   $0x8030b0,(%esp)
  800216:	e8 a8 00 00 00       	call   8002c3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x53>
	...

00800220 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	53                   	push   %ebx
  800224:	83 ec 14             	sub    $0x14,%esp
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022a:	8b 03                	mov    (%ebx),%eax
  80022c:	8b 55 08             	mov    0x8(%ebp),%edx
  80022f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800233:	83 c0 01             	add    $0x1,%eax
  800236:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800238:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023d:	75 19                	jne    800258 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80023f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800246:	00 
  800247:	8d 43 08             	lea    0x8(%ebx),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 9e 0b 00 00       	call   800df0 <sys_cputs>
		b->idx = 0;
  800252:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800258:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	5b                   	pop    %ebx
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    

00800262 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80026b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800272:	00 00 00 
	b.cnt = 0;
  800275:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800282:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800293:	89 44 24 04          	mov    %eax,0x4(%esp)
  800297:	c7 04 24 20 02 80 00 	movl   $0x800220,(%esp)
  80029e:	e8 97 01 00 00       	call   80043a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	e8 35 0b 00 00       	call   800df0 <sys_cputs>

	return b.cnt;
}
  8002bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	e8 87 ff ff ff       	call   800262 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    
  8002dd:	00 00                	add    %al,(%eax)
	...

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800300:	b8 00 00 00 00       	mov    $0x0,%eax
  800305:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800308:	72 11                	jb     80031b <printnum+0x3b>
  80030a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800310:	76 09                	jbe    80031b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800312:	83 eb 01             	sub    $0x1,%ebx
  800315:	85 db                	test   %ebx,%ebx
  800317:	7f 51                	jg     80036a <printnum+0x8a>
  800319:	eb 5e                	jmp    800379 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800326:	8b 45 10             	mov    0x10(%ebp),%eax
  800329:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800331:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800335:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033c:	00 
  80033d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034a:	e8 c1 24 00 00       	call   802810 <__udivdi3>
  80034f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800353:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800357:	89 04 24             	mov    %eax,(%esp)
  80035a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035e:	89 fa                	mov    %edi,%edx
  800360:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800363:	e8 78 ff ff ff       	call   8002e0 <printnum>
  800368:	eb 0f                	jmp    800379 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036e:	89 34 24             	mov    %esi,(%esp)
  800371:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800374:	83 eb 01             	sub    $0x1,%ebx
  800377:	75 f1                	jne    80036a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800379:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800381:	8b 45 10             	mov    0x10(%ebp),%eax
  800384:	89 44 24 08          	mov    %eax,0x8(%esp)
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	e8 9e 25 00 00       	call   802940 <__umoddi3>
  8003a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a6:	0f be 80 bb 2b 80 00 	movsbl 0x802bbb(%eax),%eax
  8003ad:	89 04 24             	mov    %eax,(%esp)
  8003b0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003b3:	83 c4 3c             	add    $0x3c,%esp
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003be:	83 fa 01             	cmp    $0x1,%edx
  8003c1:	7e 0e                	jle    8003d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 02                	mov    (%edx),%eax
  8003cc:	8b 52 04             	mov    0x4(%edx),%edx
  8003cf:	eb 22                	jmp    8003f3 <getuint+0x38>
	else if (lflag)
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	74 10                	je     8003e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d5:	8b 10                	mov    (%eax),%edx
  8003d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003da:	89 08                	mov    %ecx,(%eax)
  8003dc:	8b 02                	mov    (%edx),%eax
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e3:	eb 0e                	jmp    8003f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e5:	8b 10                	mov    (%eax),%edx
  8003e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ea:	89 08                	mov    %ecx,(%eax)
  8003ec:	8b 02                	mov    (%edx),%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	3b 50 04             	cmp    0x4(%eax),%edx
  800404:	73 0a                	jae    800410 <sprintputch+0x1b>
		*b->buf++ = ch;
  800406:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800409:	88 0a                	mov    %cl,(%edx)
  80040b:	83 c2 01             	add    $0x1,%edx
  80040e:	89 10                	mov    %edx,(%eax)
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800418:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041f:	8b 45 10             	mov    0x10(%ebp),%eax
  800422:	89 44 24 08          	mov    %eax,0x8(%esp)
  800426:	8b 45 0c             	mov    0xc(%ebp),%eax
  800429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	e8 02 00 00 00       	call   80043a <vprintfmt>
	va_end(ap);
}
  800438:	c9                   	leave  
  800439:	c3                   	ret    

0080043a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	57                   	push   %edi
  80043e:	56                   	push   %esi
  80043f:	53                   	push   %ebx
  800440:	83 ec 5c             	sub    $0x5c,%esp
  800443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800446:	8b 75 10             	mov    0x10(%ebp),%esi
  800449:	eb 12                	jmp    80045d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80044b:	85 c0                	test   %eax,%eax
  80044d:	0f 84 e4 04 00 00    	je     800937 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800453:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800457:	89 04 24             	mov    %eax,(%esp)
  80045a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045d:	0f b6 06             	movzbl (%esi),%eax
  800460:	83 c6 01             	add    $0x1,%esi
  800463:	83 f8 25             	cmp    $0x25,%eax
  800466:	75 e3                	jne    80044b <vprintfmt+0x11>
  800468:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80046c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800473:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800478:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80047f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800484:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800487:	eb 2b                	jmp    8004b4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80048c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800490:	eb 22                	jmp    8004b4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800495:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800499:	eb 19                	jmp    8004b4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80049e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004a5:	eb 0d                	jmp    8004b4 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004a7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ad:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	0f b6 06             	movzbl (%esi),%eax
  8004b7:	0f b6 d0             	movzbl %al,%edx
  8004ba:	8d 7e 01             	lea    0x1(%esi),%edi
  8004bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c0:	83 e8 23             	sub    $0x23,%eax
  8004c3:	3c 55                	cmp    $0x55,%al
  8004c5:	0f 87 46 04 00 00    	ja     800911 <vprintfmt+0x4d7>
  8004cb:	0f b6 c0             	movzbl %al,%eax
  8004ce:	ff 24 85 20 2d 80 00 	jmp    *0x802d20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d5:	83 ea 30             	sub    $0x30,%edx
  8004d8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004db:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004df:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004e5:	83 fa 09             	cmp    $0x9,%edx
  8004e8:	77 4a                	ja     800534 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ed:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004f0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004f3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004f7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004fa:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004fd:	83 fa 09             	cmp    $0x9,%edx
  800500:	76 eb                	jbe    8004ed <vprintfmt+0xb3>
  800502:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800505:	eb 2d                	jmp    800534 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 50 04             	lea    0x4(%eax),%edx
  80050d:	89 55 14             	mov    %edx,0x14(%ebp)
  800510:	8b 00                	mov    (%eax),%eax
  800512:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800518:	eb 1a                	jmp    800534 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80051d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800521:	79 91                	jns    8004b4 <vprintfmt+0x7a>
  800523:	e9 73 ff ff ff       	jmp    80049b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80052b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800532:	eb 80                	jmp    8004b4 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800534:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800538:	0f 89 76 ff ff ff    	jns    8004b4 <vprintfmt+0x7a>
  80053e:	e9 64 ff ff ff       	jmp    8004a7 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800543:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800549:	e9 66 ff ff ff       	jmp    8004b4 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 04 24             	mov    %eax,(%esp)
  800560:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800566:	e9 f2 fe ff ff       	jmp    80045d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80056b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80056f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800572:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800576:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800579:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80057d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800580:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800583:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800587:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80058a:	80 f9 09             	cmp    $0x9,%cl
  80058d:	77 1d                	ja     8005ac <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80058f:	0f be c0             	movsbl %al,%eax
  800592:	6b c0 64             	imul   $0x64,%eax,%eax
  800595:	0f be d2             	movsbl %dl,%edx
  800598:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80059b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8005a2:	a3 04 40 80 00       	mov    %eax,0x804004
  8005a7:	e9 b1 fe ff ff       	jmp    80045d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8005ac:	c7 44 24 04 d3 2b 80 	movl   $0x802bd3,0x4(%esp)
  8005b3:	00 
  8005b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	e8 0c 05 00 00       	call   800acb <strcmp>
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	75 0f                	jne    8005d2 <vprintfmt+0x198>
  8005c3:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  8005ca:	00 00 00 
  8005cd:	e9 8b fe ff ff       	jmp    80045d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8005d2:	c7 44 24 04 d7 2b 80 	movl   $0x802bd7,0x4(%esp)
  8005d9:	00 
  8005da:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005dd:	89 14 24             	mov    %edx,(%esp)
  8005e0:	e8 e6 04 00 00       	call   800acb <strcmp>
  8005e5:	85 c0                	test   %eax,%eax
  8005e7:	75 0f                	jne    8005f8 <vprintfmt+0x1be>
  8005e9:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  8005f0:	00 00 00 
  8005f3:	e9 65 fe ff ff       	jmp    80045d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005f8:	c7 44 24 04 db 2b 80 	movl   $0x802bdb,0x4(%esp)
  8005ff:	00 
  800600:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800603:	89 0c 24             	mov    %ecx,(%esp)
  800606:	e8 c0 04 00 00       	call   800acb <strcmp>
  80060b:	85 c0                	test   %eax,%eax
  80060d:	75 0f                	jne    80061e <vprintfmt+0x1e4>
  80060f:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  800616:	00 00 00 
  800619:	e9 3f fe ff ff       	jmp    80045d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80061e:	c7 44 24 04 df 2b 80 	movl   $0x802bdf,0x4(%esp)
  800625:	00 
  800626:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800629:	89 3c 24             	mov    %edi,(%esp)
  80062c:	e8 9a 04 00 00       	call   800acb <strcmp>
  800631:	85 c0                	test   %eax,%eax
  800633:	75 0f                	jne    800644 <vprintfmt+0x20a>
  800635:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  80063c:	00 00 00 
  80063f:	e9 19 fe ff ff       	jmp    80045d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800644:	c7 44 24 04 e3 2b 80 	movl   $0x802be3,0x4(%esp)
  80064b:	00 
  80064c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 74 04 00 00       	call   800acb <strcmp>
  800657:	85 c0                	test   %eax,%eax
  800659:	75 0f                	jne    80066a <vprintfmt+0x230>
  80065b:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  800662:	00 00 00 
  800665:	e9 f3 fd ff ff       	jmp    80045d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80066a:	c7 44 24 04 e7 2b 80 	movl   $0x802be7,0x4(%esp)
  800671:	00 
  800672:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800675:	89 14 24             	mov    %edx,(%esp)
  800678:	e8 4e 04 00 00       	call   800acb <strcmp>
  80067d:	83 f8 01             	cmp    $0x1,%eax
  800680:	19 c0                	sbb    %eax,%eax
  800682:	f7 d0                	not    %eax
  800684:	83 c0 08             	add    $0x8,%eax
  800687:	a3 04 40 80 00       	mov    %eax,0x804004
  80068c:	e9 cc fd ff ff       	jmp    80045d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	c1 fa 1f             	sar    $0x1f,%edx
  8006a1:	31 d0                	xor    %edx,%eax
  8006a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a5:	83 f8 0f             	cmp    $0xf,%eax
  8006a8:	7f 0b                	jg     8006b5 <vprintfmt+0x27b>
  8006aa:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  8006b1:	85 d2                	test   %edx,%edx
  8006b3:	75 23                	jne    8006d8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8006b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b9:	c7 44 24 08 eb 2b 80 	movl   $0x802beb,0x8(%esp)
  8006c0:	00 
  8006c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	89 3c 24             	mov    %edi,(%esp)
  8006cb:	e8 42 fd ff ff       	call   800412 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d3:	e9 85 fd ff ff       	jmp    80045d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006dc:	c7 44 24 08 b1 2f 80 	movl   $0x802fb1,0x8(%esp)
  8006e3:	00 
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	89 3c 24             	mov    %edi,(%esp)
  8006ee:	e8 1f fd ff ff       	call   800412 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006f6:	e9 62 fd ff ff       	jmp    80045d <vprintfmt+0x23>
  8006fb:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006fe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800701:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8d 50 04             	lea    0x4(%eax),%edx
  80070a:	89 55 14             	mov    %edx,0x14(%ebp)
  80070d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80070f:	85 f6                	test   %esi,%esi
  800711:	b8 cc 2b 80 00       	mov    $0x802bcc,%eax
  800716:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800719:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80071d:	7e 06                	jle    800725 <vprintfmt+0x2eb>
  80071f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800723:	75 13                	jne    800738 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800725:	0f be 06             	movsbl (%esi),%eax
  800728:	83 c6 01             	add    $0x1,%esi
  80072b:	85 c0                	test   %eax,%eax
  80072d:	0f 85 94 00 00 00    	jne    8007c7 <vprintfmt+0x38d>
  800733:	e9 81 00 00 00       	jmp    8007b9 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800738:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073c:	89 34 24             	mov    %esi,(%esp)
  80073f:	e8 97 02 00 00       	call   8009db <strnlen>
  800744:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800747:	29 c2                	sub    %eax,%edx
  800749:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80074c:	85 d2                	test   %edx,%edx
  80074e:	7e d5                	jle    800725 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800750:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800754:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800757:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80075a:	89 d6                	mov    %edx,%esi
  80075c:	89 cf                	mov    %ecx,%edi
  80075e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800762:	89 3c 24             	mov    %edi,(%esp)
  800765:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800768:	83 ee 01             	sub    $0x1,%esi
  80076b:	75 f1                	jne    80075e <vprintfmt+0x324>
  80076d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800770:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800773:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800776:	eb ad                	jmp    800725 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800778:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80077c:	74 1b                	je     800799 <vprintfmt+0x35f>
  80077e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800781:	83 fa 5e             	cmp    $0x5e,%edx
  800784:	76 13                	jbe    800799 <vprintfmt+0x35f>
					putch('?', putdat);
  800786:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800794:	ff 55 08             	call   *0x8(%ebp)
  800797:	eb 0d                	jmp    8007a6 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800799:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80079c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a6:	83 eb 01             	sub    $0x1,%ebx
  8007a9:	0f be 06             	movsbl (%esi),%eax
  8007ac:	83 c6 01             	add    $0x1,%esi
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	75 1a                	jne    8007cd <vprintfmt+0x393>
  8007b3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007b6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007c0:	7f 1c                	jg     8007de <vprintfmt+0x3a4>
  8007c2:	e9 96 fc ff ff       	jmp    80045d <vprintfmt+0x23>
  8007c7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007ca:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cd:	85 ff                	test   %edi,%edi
  8007cf:	78 a7                	js     800778 <vprintfmt+0x33e>
  8007d1:	83 ef 01             	sub    $0x1,%edi
  8007d4:	79 a2                	jns    800778 <vprintfmt+0x33e>
  8007d6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007d9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007dc:	eb db                	jmp    8007b9 <vprintfmt+0x37f>
  8007de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e1:	89 de                	mov    %ebx,%esi
  8007e3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f3:	83 eb 01             	sub    $0x1,%ebx
  8007f6:	75 ee                	jne    8007e6 <vprintfmt+0x3ac>
  8007f8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007fd:	e9 5b fc ff ff       	jmp    80045d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800802:	83 f9 01             	cmp    $0x1,%ecx
  800805:	7e 10                	jle    800817 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 08             	lea    0x8(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 30                	mov    (%eax),%esi
  800812:	8b 78 04             	mov    0x4(%eax),%edi
  800815:	eb 26                	jmp    80083d <vprintfmt+0x403>
	else if (lflag)
  800817:	85 c9                	test   %ecx,%ecx
  800819:	74 12                	je     80082d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8d 50 04             	lea    0x4(%eax),%edx
  800821:	89 55 14             	mov    %edx,0x14(%ebp)
  800824:	8b 30                	mov    (%eax),%esi
  800826:	89 f7                	mov    %esi,%edi
  800828:	c1 ff 1f             	sar    $0x1f,%edi
  80082b:	eb 10                	jmp    80083d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	8d 50 04             	lea    0x4(%eax),%edx
  800833:	89 55 14             	mov    %edx,0x14(%ebp)
  800836:	8b 30                	mov    (%eax),%esi
  800838:	89 f7                	mov    %esi,%edi
  80083a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80083d:	85 ff                	test   %edi,%edi
  80083f:	78 0e                	js     80084f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800841:	89 f0                	mov    %esi,%eax
  800843:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800845:	be 0a 00 00 00       	mov    $0xa,%esi
  80084a:	e9 84 00 00 00       	jmp    8008d3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80084f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800853:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80085a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80085d:	89 f0                	mov    %esi,%eax
  80085f:	89 fa                	mov    %edi,%edx
  800861:	f7 d8                	neg    %eax
  800863:	83 d2 00             	adc    $0x0,%edx
  800866:	f7 da                	neg    %edx
			}
			base = 10;
  800868:	be 0a 00 00 00       	mov    $0xa,%esi
  80086d:	eb 64                	jmp    8008d3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80086f:	89 ca                	mov    %ecx,%edx
  800871:	8d 45 14             	lea    0x14(%ebp),%eax
  800874:	e8 42 fb ff ff       	call   8003bb <getuint>
			base = 10;
  800879:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80087e:	eb 53                	jmp    8008d3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800880:	89 ca                	mov    %ecx,%edx
  800882:	8d 45 14             	lea    0x14(%ebp),%eax
  800885:	e8 31 fb ff ff       	call   8003bb <getuint>
    			base = 8;
  80088a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80088f:	eb 42                	jmp    8008d3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800891:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800895:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80089c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80089f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008aa:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8d 50 04             	lea    0x4(%eax),%edx
  8008b3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008b6:	8b 00                	mov    (%eax),%eax
  8008b8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008bd:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008c2:	eb 0f                	jmp    8008d3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c4:	89 ca                	mov    %ecx,%edx
  8008c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c9:	e8 ed fa ff ff       	call   8003bb <getuint>
			base = 16;
  8008ce:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008d7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008db:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008de:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008e2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ed:	89 da                	mov    %ebx,%edx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	e8 e9 f9 ff ff       	call   8002e0 <printnum>
			break;
  8008f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008fa:	e9 5e fb ff ff       	jmp    80045d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800903:	89 14 24             	mov    %edx,(%esp)
  800906:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800909:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80090c:	e9 4c fb ff ff       	jmp    80045d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800911:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800915:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80091c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80091f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800923:	0f 84 34 fb ff ff    	je     80045d <vprintfmt+0x23>
  800929:	83 ee 01             	sub    $0x1,%esi
  80092c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800930:	75 f7                	jne    800929 <vprintfmt+0x4ef>
  800932:	e9 26 fb ff ff       	jmp    80045d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800937:	83 c4 5c             	add    $0x5c,%esp
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	83 ec 28             	sub    $0x28,%esp
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80094b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800952:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095c:	85 c0                	test   %eax,%eax
  80095e:	74 30                	je     800990 <vsnprintf+0x51>
  800960:	85 d2                	test   %edx,%edx
  800962:	7e 2c                	jle    800990 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096b:	8b 45 10             	mov    0x10(%ebp),%eax
  80096e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800972:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800975:	89 44 24 04          	mov    %eax,0x4(%esp)
  800979:	c7 04 24 f5 03 80 00 	movl   $0x8003f5,(%esp)
  800980:	e8 b5 fa ff ff       	call   80043a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800985:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800988:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098e:	eb 05                	jmp    800995 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800990:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80099d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	89 04 24             	mov    %eax,(%esp)
  8009b8:	e8 82 ff ff ff       	call   80093f <vsnprintf>
	va_end(ap);

	return rc;
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    
	...

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ce:	74 09                	je     8009d9 <strlen+0x19>
		n++;
  8009d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d7:	75 f7                	jne    8009d0 <strlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 1a                	je     800a08 <strnlen+0x2d>
  8009ee:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009f1:	74 15                	je     800a08 <strnlen+0x2d>
  8009f3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009f8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fa:	39 ca                	cmp    %ecx,%edx
  8009fc:	74 0a                	je     800a08 <strnlen+0x2d>
  8009fe:	83 c2 01             	add    $0x1,%edx
  800a01:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a06:	75 f0                	jne    8009f8 <strnlen+0x1d>
		n++;
	return n;
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a1e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a21:	83 c2 01             	add    $0x1,%edx
  800a24:	84 c9                	test   %cl,%cl
  800a26:	75 f2                	jne    800a1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	83 ec 08             	sub    $0x8,%esp
  800a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a35:	89 1c 24             	mov    %ebx,(%esp)
  800a38:	e8 83 ff ff ff       	call   8009c0 <strlen>
	strcpy(dst + len, src);
  800a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a40:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a44:	01 d8                	add    %ebx,%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 bd ff ff ff       	call   800a0b <strcpy>
	return dst;
}
  800a4e:	89 d8                	mov    %ebx,%eax
  800a50:	83 c4 08             	add    $0x8,%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a64:	85 f6                	test   %esi,%esi
  800a66:	74 18                	je     800a80 <strncpy+0x2a>
  800a68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a6d:	0f b6 1a             	movzbl (%edx),%ebx
  800a70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a73:	80 3a 01             	cmpb   $0x1,(%edx)
  800a76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	39 f1                	cmp    %esi,%ecx
  800a7e:	75 ed                	jne    800a6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a90:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a93:	89 f8                	mov    %edi,%eax
  800a95:	85 f6                	test   %esi,%esi
  800a97:	74 2b                	je     800ac4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a99:	83 fe 01             	cmp    $0x1,%esi
  800a9c:	74 23                	je     800ac1 <strlcpy+0x3d>
  800a9e:	0f b6 0b             	movzbl (%ebx),%ecx
  800aa1:	84 c9                	test   %cl,%cl
  800aa3:	74 1c                	je     800ac1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800aa5:	83 ee 02             	sub    $0x2,%esi
  800aa8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aad:	88 08                	mov    %cl,(%eax)
  800aaf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab2:	39 f2                	cmp    %esi,%edx
  800ab4:	74 0b                	je     800ac1 <strlcpy+0x3d>
  800ab6:	83 c2 01             	add    $0x1,%edx
  800ab9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800abd:	84 c9                	test   %cl,%cl
  800abf:	75 ec                	jne    800aad <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800ac1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac4:	29 f8                	sub    %edi,%eax
}
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad4:	0f b6 01             	movzbl (%ecx),%eax
  800ad7:	84 c0                	test   %al,%al
  800ad9:	74 16                	je     800af1 <strcmp+0x26>
  800adb:	3a 02                	cmp    (%edx),%al
  800add:	75 12                	jne    800af1 <strcmp+0x26>
		p++, q++;
  800adf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ae6:	84 c0                	test   %al,%al
  800ae8:	74 07                	je     800af1 <strcmp+0x26>
  800aea:	83 c1 01             	add    $0x1,%ecx
  800aed:	3a 02                	cmp    (%edx),%al
  800aef:	74 ee                	je     800adf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 c0             	movzbl %al,%eax
  800af4:	0f b6 12             	movzbl (%edx),%edx
  800af7:	29 d0                	sub    %edx,%eax
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0d:	85 d2                	test   %edx,%edx
  800b0f:	74 28                	je     800b39 <strncmp+0x3e>
  800b11:	0f b6 01             	movzbl (%ecx),%eax
  800b14:	84 c0                	test   %al,%al
  800b16:	74 24                	je     800b3c <strncmp+0x41>
  800b18:	3a 03                	cmp    (%ebx),%al
  800b1a:	75 20                	jne    800b3c <strncmp+0x41>
  800b1c:	83 ea 01             	sub    $0x1,%edx
  800b1f:	74 13                	je     800b34 <strncmp+0x39>
		n--, p++, q++;
  800b21:	83 c1 01             	add    $0x1,%ecx
  800b24:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b27:	0f b6 01             	movzbl (%ecx),%eax
  800b2a:	84 c0                	test   %al,%al
  800b2c:	74 0e                	je     800b3c <strncmp+0x41>
  800b2e:	3a 03                	cmp    (%ebx),%al
  800b30:	74 ea                	je     800b1c <strncmp+0x21>
  800b32:	eb 08                	jmp    800b3c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3c:	0f b6 01             	movzbl (%ecx),%eax
  800b3f:	0f b6 13             	movzbl (%ebx),%edx
  800b42:	29 d0                	sub    %edx,%eax
  800b44:	eb f3                	jmp    800b39 <strncmp+0x3e>

00800b46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b50:	0f b6 10             	movzbl (%eax),%edx
  800b53:	84 d2                	test   %dl,%dl
  800b55:	74 1c                	je     800b73 <strchr+0x2d>
		if (*s == c)
  800b57:	38 ca                	cmp    %cl,%dl
  800b59:	75 09                	jne    800b64 <strchr+0x1e>
  800b5b:	eb 1b                	jmp    800b78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b5d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b60:	38 ca                	cmp    %cl,%dl
  800b62:	74 14                	je     800b78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b64:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 f1                	jne    800b5d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	eb 05                	jmp    800b78 <strchr+0x32>
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b84:	0f b6 10             	movzbl (%eax),%edx
  800b87:	84 d2                	test   %dl,%dl
  800b89:	74 14                	je     800b9f <strfind+0x25>
		if (*s == c)
  800b8b:	38 ca                	cmp    %cl,%dl
  800b8d:	75 06                	jne    800b95 <strfind+0x1b>
  800b8f:	eb 0e                	jmp    800b9f <strfind+0x25>
  800b91:	38 ca                	cmp    %cl,%dl
  800b93:	74 0a                	je     800b9f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b95:	83 c0 01             	add    $0x1,%eax
  800b98:	0f b6 10             	movzbl (%eax),%edx
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	75 f2                	jne    800b91 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800baa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb9:	85 c9                	test   %ecx,%ecx
  800bbb:	74 30                	je     800bed <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc3:	75 25                	jne    800bea <memset+0x49>
  800bc5:	f6 c1 03             	test   $0x3,%cl
  800bc8:	75 20                	jne    800bea <memset+0x49>
		c &= 0xFF;
  800bca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	c1 e3 08             	shl    $0x8,%ebx
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	c1 e6 18             	shl    $0x18,%esi
  800bd7:	89 d0                	mov    %edx,%eax
  800bd9:	c1 e0 10             	shl    $0x10,%eax
  800bdc:	09 f0                	or     %esi,%eax
  800bde:	09 d0                	or     %edx,%eax
  800be0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800be2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800be5:	fc                   	cld    
  800be6:	f3 ab                	rep stos %eax,%es:(%edi)
  800be8:	eb 03                	jmp    800bed <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bea:	fc                   	cld    
  800beb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bed:	89 f8                	mov    %edi,%eax
  800bef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf8:	89 ec                	mov    %ebp,%esp
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c05:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c11:	39 c6                	cmp    %eax,%esi
  800c13:	73 36                	jae    800c4b <memmove+0x4f>
  800c15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c18:	39 d0                	cmp    %edx,%eax
  800c1a:	73 2f                	jae    800c4b <memmove+0x4f>
		s += n;
		d += n;
  800c1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1f:	f6 c2 03             	test   $0x3,%dl
  800c22:	75 1b                	jne    800c3f <memmove+0x43>
  800c24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2a:	75 13                	jne    800c3f <memmove+0x43>
  800c2c:	f6 c1 03             	test   $0x3,%cl
  800c2f:	75 0e                	jne    800c3f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c31:	83 ef 04             	sub    $0x4,%edi
  800c34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c3a:	fd                   	std    
  800c3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3d:	eb 09                	jmp    800c48 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c3f:	83 ef 01             	sub    $0x1,%edi
  800c42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c45:	fd                   	std    
  800c46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c48:	fc                   	cld    
  800c49:	eb 20                	jmp    800c6b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c51:	75 13                	jne    800c66 <memmove+0x6a>
  800c53:	a8 03                	test   $0x3,%al
  800c55:	75 0f                	jne    800c66 <memmove+0x6a>
  800c57:	f6 c1 03             	test   $0x3,%cl
  800c5a:	75 0a                	jne    800c66 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c5f:	89 c7                	mov    %eax,%edi
  800c61:	fc                   	cld    
  800c62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c64:	eb 05                	jmp    800c6b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	fc                   	cld    
  800c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c71:	89 ec                	mov    %ebp,%esp
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	89 04 24             	mov    %eax,(%esp)
  800c8f:	e8 68 ff ff ff       	call   800bfc <memmove>
}
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caa:	85 ff                	test   %edi,%edi
  800cac:	74 37                	je     800ce5 <memcmp+0x4f>
		if (*s1 != *s2)
  800cae:	0f b6 03             	movzbl (%ebx),%eax
  800cb1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb4:	83 ef 01             	sub    $0x1,%edi
  800cb7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800cbc:	38 c8                	cmp    %cl,%al
  800cbe:	74 1c                	je     800cdc <memcmp+0x46>
  800cc0:	eb 10                	jmp    800cd2 <memcmp+0x3c>
  800cc2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800cc7:	83 c2 01             	add    $0x1,%edx
  800cca:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cce:	38 c8                	cmp    %cl,%al
  800cd0:	74 0a                	je     800cdc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800cd2:	0f b6 c0             	movzbl %al,%eax
  800cd5:	0f b6 c9             	movzbl %cl,%ecx
  800cd8:	29 c8                	sub    %ecx,%eax
  800cda:	eb 09                	jmp    800ce5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdc:	39 fa                	cmp    %edi,%edx
  800cde:	75 e2                	jne    800cc2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf5:	39 d0                	cmp    %edx,%eax
  800cf7:	73 19                	jae    800d12 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cfd:	38 08                	cmp    %cl,(%eax)
  800cff:	75 06                	jne    800d07 <memfind+0x1d>
  800d01:	eb 0f                	jmp    800d12 <memfind+0x28>
  800d03:	38 08                	cmp    %cl,(%eax)
  800d05:	74 0b                	je     800d12 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d07:	83 c0 01             	add    $0x1,%eax
  800d0a:	39 d0                	cmp    %edx,%eax
  800d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d10:	75 f1                	jne    800d03 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d20:	0f b6 02             	movzbl (%edx),%eax
  800d23:	3c 20                	cmp    $0x20,%al
  800d25:	74 04                	je     800d2b <strtol+0x17>
  800d27:	3c 09                	cmp    $0x9,%al
  800d29:	75 0e                	jne    800d39 <strtol+0x25>
		s++;
  800d2b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2e:	0f b6 02             	movzbl (%edx),%eax
  800d31:	3c 20                	cmp    $0x20,%al
  800d33:	74 f6                	je     800d2b <strtol+0x17>
  800d35:	3c 09                	cmp    $0x9,%al
  800d37:	74 f2                	je     800d2b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d39:	3c 2b                	cmp    $0x2b,%al
  800d3b:	75 0a                	jne    800d47 <strtol+0x33>
		s++;
  800d3d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d40:	bf 00 00 00 00       	mov    $0x0,%edi
  800d45:	eb 10                	jmp    800d57 <strtol+0x43>
  800d47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d4c:	3c 2d                	cmp    $0x2d,%al
  800d4e:	75 07                	jne    800d57 <strtol+0x43>
		s++, neg = 1;
  800d50:	83 c2 01             	add    $0x1,%edx
  800d53:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d57:	85 db                	test   %ebx,%ebx
  800d59:	0f 94 c0             	sete   %al
  800d5c:	74 05                	je     800d63 <strtol+0x4f>
  800d5e:	83 fb 10             	cmp    $0x10,%ebx
  800d61:	75 15                	jne    800d78 <strtol+0x64>
  800d63:	80 3a 30             	cmpb   $0x30,(%edx)
  800d66:	75 10                	jne    800d78 <strtol+0x64>
  800d68:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d6c:	75 0a                	jne    800d78 <strtol+0x64>
		s += 2, base = 16;
  800d6e:	83 c2 02             	add    $0x2,%edx
  800d71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d76:	eb 13                	jmp    800d8b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d78:	84 c0                	test   %al,%al
  800d7a:	74 0f                	je     800d8b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d81:	80 3a 30             	cmpb   $0x30,(%edx)
  800d84:	75 05                	jne    800d8b <strtol+0x77>
		s++, base = 8;
  800d86:	83 c2 01             	add    $0x1,%edx
  800d89:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d90:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d92:	0f b6 0a             	movzbl (%edx),%ecx
  800d95:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d98:	80 fb 09             	cmp    $0x9,%bl
  800d9b:	77 08                	ja     800da5 <strtol+0x91>
			dig = *s - '0';
  800d9d:	0f be c9             	movsbl %cl,%ecx
  800da0:	83 e9 30             	sub    $0x30,%ecx
  800da3:	eb 1e                	jmp    800dc3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800da5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800da8:	80 fb 19             	cmp    $0x19,%bl
  800dab:	77 08                	ja     800db5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800dad:	0f be c9             	movsbl %cl,%ecx
  800db0:	83 e9 57             	sub    $0x57,%ecx
  800db3:	eb 0e                	jmp    800dc3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800db5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800db8:	80 fb 19             	cmp    $0x19,%bl
  800dbb:	77 14                	ja     800dd1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dbd:	0f be c9             	movsbl %cl,%ecx
  800dc0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dc3:	39 f1                	cmp    %esi,%ecx
  800dc5:	7d 0e                	jge    800dd5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800dc7:	83 c2 01             	add    $0x1,%edx
  800dca:	0f af c6             	imul   %esi,%eax
  800dcd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dcf:	eb c1                	jmp    800d92 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dd1:	89 c1                	mov    %eax,%ecx
  800dd3:	eb 02                	jmp    800dd7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dd5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ddb:	74 05                	je     800de2 <strtol+0xce>
		*endptr = (char *) s;
  800ddd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800de2:	89 ca                	mov    %ecx,%edx
  800de4:	f7 da                	neg    %edx
  800de6:	85 ff                	test   %edi,%edi
  800de8:	0f 45 c2             	cmovne %edx,%eax
}
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	b8 00 00 00 00       	mov    $0x0,%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 c7                	mov    %eax,%edi
  800e0e:	89 c6                	mov    %eax,%esi
  800e10:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e33:	b8 01 00 00 00       	mov    $0x1,%eax
  800e38:	89 d1                	mov    %edx,%ecx
  800e3a:	89 d3                	mov    %edx,%ebx
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	89 d6                	mov    %edx,%esi
  800e40:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4b:	89 ec                	mov    %ebp,%esp
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 38             	sub    $0x38,%esp
  800e55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 03 00 00 00       	mov    $0x3,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 28                	jle    800e9f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e82:	00 
  800e83:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e92:	00 
  800e93:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800e9a:	e8 29 f3 ff ff       	call   8001c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800ec0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_yield>:

void
sys_yield(void)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef5:	89 d1                	mov    %edx,%ecx
  800ef7:	89 d3                	mov    %edx,%ebx
  800ef9:	89 d7                	mov    %edx,%edi
  800efb:	89 d6                	mov    %edx,%esi
  800efd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 38             	sub    $0x38,%esp
  800f12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1b:	be 00 00 00 00       	mov    $0x0,%esi
  800f20:	b8 04 00 00 00       	mov    $0x4,%eax
  800f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	89 f7                	mov    %esi,%edi
  800f30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f32:	85 c0                	test   %eax,%eax
  800f34:	7e 28                	jle    800f5e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f51:	00 
  800f52:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800f59:	e8 6a f2 ff ff       	call   8001c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f67:	89 ec                	mov    %ebp,%esp
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 38             	sub    $0x38,%esp
  800f71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 28                	jle    800fbc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800fa7:	00 
  800fa8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800faf:	00 
  800fb0:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800fb7:	e8 0c f2 ff ff       	call   8001c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fbc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc5:	89 ec                	mov    %ebp,%esp
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 38             	sub    $0x38,%esp
  800fcf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdd:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe8:	89 df                	mov    %ebx,%edi
  800fea:	89 de                	mov    %ebx,%esi
  800fec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 28                	jle    80101a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  801005:	00 
  801006:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100d:	00 
  80100e:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  801015:	e8 ae f1 ff ff       	call   8001c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80101a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801020:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801023:	89 ec                	mov    %ebp,%esp
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 38             	sub    $0x38,%esp
  80102d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801030:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801033:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103b:	b8 08 00 00 00       	mov    $0x8,%eax
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	89 df                	mov    %ebx,%edi
  801048:	89 de                	mov    %ebx,%esi
  80104a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	7e 28                	jle    801078 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801050:	89 44 24 10          	mov    %eax,0x10(%esp)
  801054:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80105b:	00 
  80105c:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  801063:	00 
  801064:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  801073:	e8 50 f1 ff ff       	call   8001c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801078:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801081:	89 ec                	mov    %ebp,%esp
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 38             	sub    $0x38,%esp
  80108b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801091:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801094:	bb 00 00 00 00       	mov    $0x0,%ebx
  801099:	b8 09 00 00 00       	mov    $0x9,%eax
  80109e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a4:	89 df                	mov    %ebx,%edi
  8010a6:	89 de                	mov    %ebx,%esi
  8010a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	7e 28                	jle    8010d6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010b9:	00 
  8010ba:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  8010c1:	00 
  8010c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c9:	00 
  8010ca:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  8010d1:	e8 f2 f0 ff ff       	call   8001c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010df:	89 ec                	mov    %ebp,%esp
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	83 ec 38             	sub    $0x38,%esp
  8010e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	89 df                	mov    %ebx,%edi
  801104:	89 de                	mov    %ebx,%esi
  801106:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801108:	85 c0                	test   %eax,%eax
  80110a:	7e 28                	jle    801134 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801110:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801117:	00 
  801118:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  80111f:	00 
  801120:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801127:	00 
  801128:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  80112f:	e8 94 f0 ff ff       	call   8001c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801134:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801137:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113d:	89 ec                	mov    %ebp,%esp
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80114a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80114d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801150:	be 00 00 00 00       	mov    $0x0,%esi
  801155:	b8 0c 00 00 00       	mov    $0xc,%eax
  80115a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
  801166:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801168:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80116b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801171:	89 ec                	mov    %ebp,%esp
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	83 ec 38             	sub    $0x38,%esp
  80117b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80117e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801181:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801184:	b9 00 00 00 00       	mov    $0x0,%ecx
  801189:	b8 0d 00 00 00       	mov    $0xd,%eax
  80118e:	8b 55 08             	mov    0x8(%ebp),%edx
  801191:	89 cb                	mov    %ecx,%ebx
  801193:	89 cf                	mov    %ecx,%edi
  801195:	89 ce                	mov    %ecx,%esi
  801197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	7e 28                	jle    8011c5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  8011c0:	e8 03 f0 ff ff       	call   8001c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011c5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011c8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ce:	89 ec                	mov    %ebp,%esp
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011db:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011de:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ee:	89 cb                	mov    %ecx,%ebx
  8011f0:	89 cf                	mov    %ecx,%edi
  8011f2:	89 ce                	mov    %ecx,%esi
  8011f4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8011f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ff:	89 ec                	mov    %ebp,%esp
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    
	...

00801210 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	05 00 00 00 30       	add    $0x30000000,%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	89 04 24             	mov    %eax,(%esp)
  80122c:	e8 df ff ff ff       	call   801210 <fd2num>
  801231:	05 20 00 0d 00       	add    $0xd0020,%eax
  801236:	c1 e0 0c             	shl    $0xc,%eax
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801242:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801247:	a8 01                	test   $0x1,%al
  801249:	74 34                	je     80127f <fd_alloc+0x44>
  80124b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801250:	a8 01                	test   $0x1,%al
  801252:	74 32                	je     801286 <fd_alloc+0x4b>
  801254:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801259:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 16             	shr    $0x16,%edx
  801260:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 1f                	je     80128b <fd_alloc+0x50>
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	c1 ea 0c             	shr    $0xc,%edx
  801271:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801278:	f6 c2 01             	test   $0x1,%dl
  80127b:	75 17                	jne    801294 <fd_alloc+0x59>
  80127d:	eb 0c                	jmp    80128b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80127f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801284:	eb 05                	jmp    80128b <fd_alloc+0x50>
  801286:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80128b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	eb 17                	jmp    8012ab <fd_alloc+0x70>
  801294:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801299:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129e:	75 b9                	jne    801259 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ab:	5b                   	pop    %ebx
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    

008012ae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b9:	83 fa 1f             	cmp    $0x1f,%edx
  8012bc:	77 3f                	ja     8012fd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012be:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8012c4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c7:	89 d0                	mov    %edx,%eax
  8012c9:	c1 e8 16             	shr    $0x16,%eax
  8012cc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d8:	f6 c1 01             	test   $0x1,%cl
  8012db:	74 20                	je     8012fd <fd_lookup+0x4f>
  8012dd:	89 d0                	mov    %edx,%eax
  8012df:	c1 e8 0c             	shr    $0xc,%eax
  8012e2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ee:	f6 c1 01             	test   $0x1,%cl
  8012f1:	74 0a                	je     8012fd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801311:	39 0d 08 40 80 00    	cmp    %ecx,0x804008
  801317:	75 17                	jne    801330 <dev_lookup+0x31>
  801319:	eb 07                	jmp    801322 <dev_lookup+0x23>
  80131b:	39 0a                	cmp    %ecx,(%edx)
  80131d:	75 11                	jne    801330 <dev_lookup+0x31>
  80131f:	90                   	nop
  801320:	eb 05                	jmp    801327 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801322:	ba 08 40 80 00       	mov    $0x804008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801327:	89 13                	mov    %edx,(%ebx)
			return 0;
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
  80132e:	eb 35                	jmp    801365 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801330:	83 c0 01             	add    $0x1,%eax
  801333:	8b 14 85 88 2f 80 00 	mov    0x802f88(,%eax,4),%edx
  80133a:	85 d2                	test   %edx,%edx
  80133c:	75 dd                	jne    80131b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80133e:	a1 04 50 80 00       	mov    0x805004,%eax
  801343:	8b 40 48             	mov    0x48(%eax),%eax
  801346:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134e:	c7 04 24 0c 2f 80 00 	movl   $0x802f0c,(%esp)
  801355:	e8 69 ef ff ff       	call   8002c3 <cprintf>
	*dev = 0;
  80135a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801360:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801365:	83 c4 14             	add    $0x14,%esp
  801368:	5b                   	pop    %ebx
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 38             	sub    $0x38,%esp
  801371:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801374:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801377:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80137a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80137d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801381:	89 3c 24             	mov    %edi,(%esp)
  801384:	e8 87 fe ff ff       	call   801210 <fd2num>
  801389:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80138c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801390:	89 04 24             	mov    %eax,(%esp)
  801393:	e8 16 ff ff ff       	call   8012ae <fd_lookup>
  801398:	89 c3                	mov    %eax,%ebx
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 05                	js     8013a3 <fd_close+0x38>
	    || fd != fd2)
  80139e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8013a1:	74 0e                	je     8013b1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	84 c0                	test   %al,%al
  8013a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ac:	0f 44 d8             	cmove  %eax,%ebx
  8013af:	eb 3d                	jmp    8013ee <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 07                	mov    (%edi),%eax
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	e8 3d ff ff ff       	call   8012ff <dev_lookup>
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 16                	js     8013de <fd_close+0x73>
		if (dev->dev_close)
  8013c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	74 07                	je     8013de <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8013d7:	89 3c 24             	mov    %edi,(%esp)
  8013da:	ff d0                	call   *%eax
  8013dc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e9:	e8 db fb ff ff       	call   800fc9 <sys_page_unmap>
	return r;
}
  8013ee:	89 d8                	mov    %ebx,%eax
  8013f0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013f3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013f6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f9:	89 ec                	mov    %ebp,%esp
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801403:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140a:	8b 45 08             	mov    0x8(%ebp),%eax
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	e8 99 fe ff ff       	call   8012ae <fd_lookup>
  801415:	85 c0                	test   %eax,%eax
  801417:	78 13                	js     80142c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801419:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801420:	00 
  801421:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801424:	89 04 24             	mov    %eax,(%esp)
  801427:	e8 3f ff ff ff       	call   80136b <fd_close>
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <close_all>:

void
close_all(void)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	53                   	push   %ebx
  801432:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801435:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80143a:	89 1c 24             	mov    %ebx,(%esp)
  80143d:	e8 bb ff ff ff       	call   8013fd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801442:	83 c3 01             	add    $0x1,%ebx
  801445:	83 fb 20             	cmp    $0x20,%ebx
  801448:	75 f0                	jne    80143a <close_all+0xc>
		close(i);
}
  80144a:	83 c4 14             	add    $0x14,%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 58             	sub    $0x58,%esp
  801456:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801459:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80145c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80145f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801462:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801465:	89 44 24 04          	mov    %eax,0x4(%esp)
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	89 04 24             	mov    %eax,(%esp)
  80146f:	e8 3a fe ff ff       	call   8012ae <fd_lookup>
  801474:	89 c3                	mov    %eax,%ebx
  801476:	85 c0                	test   %eax,%eax
  801478:	0f 88 e1 00 00 00    	js     80155f <dup+0x10f>
		return r;
	close(newfdnum);
  80147e:	89 3c 24             	mov    %edi,(%esp)
  801481:	e8 77 ff ff ff       	call   8013fd <close>

	newfd = INDEX2FD(newfdnum);
  801486:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80148c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80148f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	e8 86 fd ff ff       	call   801220 <fd2data>
  80149a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80149c:	89 34 24             	mov    %esi,(%esp)
  80149f:	e8 7c fd ff ff       	call   801220 <fd2data>
  8014a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a7:	89 d8                	mov    %ebx,%eax
  8014a9:	c1 e8 16             	shr    $0x16,%eax
  8014ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b3:	a8 01                	test   $0x1,%al
  8014b5:	74 46                	je     8014fd <dup+0xad>
  8014b7:	89 d8                	mov    %ebx,%eax
  8014b9:	c1 e8 0c             	shr    $0xc,%eax
  8014bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c3:	f6 c2 01             	test   $0x1,%dl
  8014c6:	74 35                	je     8014fd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014e6:	00 
  8014e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f2:	e8 74 fa ff ff       	call   800f6b <sys_page_map>
  8014f7:	89 c3                	mov    %eax,%ebx
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 3b                	js     801538 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801500:	89 c2                	mov    %eax,%edx
  801502:	c1 ea 0c             	shr    $0xc,%edx
  801505:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801512:	89 54 24 10          	mov    %edx,0x10(%esp)
  801516:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80151a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801521:	00 
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
  801526:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80152d:	e8 39 fa ff ff       	call   800f6b <sys_page_map>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	85 c0                	test   %eax,%eax
  801536:	79 25                	jns    80155d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801538:	89 74 24 04          	mov    %esi,0x4(%esp)
  80153c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801543:	e8 81 fa ff ff       	call   800fc9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801548:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80154b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801556:	e8 6e fa ff ff       	call   800fc9 <sys_page_unmap>
	return r;
  80155b:	eb 02                	jmp    80155f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80155d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801564:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801567:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80156a:	89 ec                	mov    %ebp,%esp
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	53                   	push   %ebx
  801572:	83 ec 24             	sub    $0x24,%esp
  801575:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801578:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157f:	89 1c 24             	mov    %ebx,(%esp)
  801582:	e8 27 fd ff ff       	call   8012ae <fd_lookup>
  801587:	85 c0                	test   %eax,%eax
  801589:	78 6d                	js     8015f8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801595:	8b 00                	mov    (%eax),%eax
  801597:	89 04 24             	mov    %eax,(%esp)
  80159a:	e8 60 fd ff ff       	call   8012ff <dev_lookup>
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 55                	js     8015f8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a6:	8b 50 08             	mov    0x8(%eax),%edx
  8015a9:	83 e2 03             	and    $0x3,%edx
  8015ac:	83 fa 01             	cmp    $0x1,%edx
  8015af:	75 23                	jne    8015d4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b1:	a1 04 50 80 00       	mov    0x805004,%eax
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	c7 04 24 4d 2f 80 00 	movl   $0x802f4d,(%esp)
  8015c8:	e8 f6 ec ff ff       	call   8002c3 <cprintf>
		return -E_INVAL;
  8015cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d2:	eb 24                	jmp    8015f8 <read+0x8a>
	}
	if (!dev->dev_read)
  8015d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d7:	8b 52 08             	mov    0x8(%edx),%edx
  8015da:	85 d2                	test   %edx,%edx
  8015dc:	74 15                	je     8015f3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8015de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ec:	89 04 24             	mov    %eax,(%esp)
  8015ef:	ff d2                	call   *%edx
  8015f1:	eb 05                	jmp    8015f8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8015f8:	83 c4 24             	add    $0x24,%esp
  8015fb:	5b                   	pop    %ebx
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    

008015fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	57                   	push   %edi
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	83 ec 1c             	sub    $0x1c,%esp
  801607:	8b 7d 08             	mov    0x8(%ebp),%edi
  80160a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160d:	b8 00 00 00 00       	mov    $0x0,%eax
  801612:	85 f6                	test   %esi,%esi
  801614:	74 30                	je     801646 <readn+0x48>
  801616:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80161b:	89 f2                	mov    %esi,%edx
  80161d:	29 c2                	sub    %eax,%edx
  80161f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801623:	03 45 0c             	add    0xc(%ebp),%eax
  801626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162a:	89 3c 24             	mov    %edi,(%esp)
  80162d:	e8 3c ff ff ff       	call   80156e <read>
		if (m < 0)
  801632:	85 c0                	test   %eax,%eax
  801634:	78 10                	js     801646 <readn+0x48>
			return m;
		if (m == 0)
  801636:	85 c0                	test   %eax,%eax
  801638:	74 0a                	je     801644 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80163a:	01 c3                	add    %eax,%ebx
  80163c:	89 d8                	mov    %ebx,%eax
  80163e:	39 f3                	cmp    %esi,%ebx
  801640:	72 d9                	jb     80161b <readn+0x1d>
  801642:	eb 02                	jmp    801646 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801644:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801646:	83 c4 1c             	add    $0x1c,%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	53                   	push   %ebx
  801652:	83 ec 24             	sub    $0x24,%esp
  801655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 47 fc ff ff       	call   8012ae <fd_lookup>
  801667:	85 c0                	test   %eax,%eax
  801669:	78 68                	js     8016d3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	8b 00                	mov    (%eax),%eax
  801677:	89 04 24             	mov    %eax,(%esp)
  80167a:	e8 80 fc ff ff       	call   8012ff <dev_lookup>
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 50                	js     8016d3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801686:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168a:	75 23                	jne    8016af <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80168c:	a1 04 50 80 00       	mov    0x805004,%eax
  801691:	8b 40 48             	mov    0x48(%eax),%eax
  801694:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169c:	c7 04 24 69 2f 80 00 	movl   $0x802f69,(%esp)
  8016a3:	e8 1b ec ff ff       	call   8002c3 <cprintf>
		return -E_INVAL;
  8016a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ad:	eb 24                	jmp    8016d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b5:	85 d2                	test   %edx,%edx
  8016b7:	74 15                	je     8016ce <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016bc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016c7:	89 04 24             	mov    %eax,(%esp)
  8016ca:	ff d2                	call   *%edx
  8016cc:	eb 05                	jmp    8016d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016d3:	83 c4 24             	add    $0x24,%esp
  8016d6:	5b                   	pop    %ebx
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	89 04 24             	mov    %eax,(%esp)
  8016ec:	e8 bd fb ff ff       	call   8012ae <fd_lookup>
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 0e                	js     801703 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	53                   	push   %ebx
  801709:	83 ec 24             	sub    $0x24,%esp
  80170c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801712:	89 44 24 04          	mov    %eax,0x4(%esp)
  801716:	89 1c 24             	mov    %ebx,(%esp)
  801719:	e8 90 fb ff ff       	call   8012ae <fd_lookup>
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 61                	js     801783 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172c:	8b 00                	mov    (%eax),%eax
  80172e:	89 04 24             	mov    %eax,(%esp)
  801731:	e8 c9 fb ff ff       	call   8012ff <dev_lookup>
  801736:	85 c0                	test   %eax,%eax
  801738:	78 49                	js     801783 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801741:	75 23                	jne    801766 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801743:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801748:	8b 40 48             	mov    0x48(%eax),%eax
  80174b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  80175a:	e8 64 eb ff ff       	call   8002c3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80175f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801764:	eb 1d                	jmp    801783 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801766:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801769:	8b 52 18             	mov    0x18(%edx),%edx
  80176c:	85 d2                	test   %edx,%edx
  80176e:	74 0e                	je     80177e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801773:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801777:	89 04 24             	mov    %eax,(%esp)
  80177a:	ff d2                	call   *%edx
  80177c:	eb 05                	jmp    801783 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80177e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801783:	83 c4 24             	add    $0x24,%esp
  801786:	5b                   	pop    %ebx
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	53                   	push   %ebx
  80178d:	83 ec 24             	sub    $0x24,%esp
  801790:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801793:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801796:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	89 04 24             	mov    %eax,(%esp)
  8017a0:	e8 09 fb ff ff       	call   8012ae <fd_lookup>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 52                	js     8017fb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b3:	8b 00                	mov    (%eax),%eax
  8017b5:	89 04 24             	mov    %eax,(%esp)
  8017b8:	e8 42 fb ff ff       	call   8012ff <dev_lookup>
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	78 3a                	js     8017fb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c8:	74 2c                	je     8017f6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ca:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017cd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d4:	00 00 00 
	stat->st_isdir = 0;
  8017d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017de:	00 00 00 
	stat->st_dev = dev;
  8017e1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017ee:	89 14 24             	mov    %edx,(%esp)
  8017f1:	ff 50 14             	call   *0x14(%eax)
  8017f4:	eb 05                	jmp    8017fb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017fb:	83 c4 24             	add    $0x24,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 18             	sub    $0x18,%esp
  801807:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80180a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80180d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801814:	00 
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	e8 bc 01 00 00       	call   8019dc <open>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	85 c0                	test   %eax,%eax
  801824:	78 1b                	js     801841 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 54 ff ff ff       	call   801789 <fstat>
  801835:	89 c6                	mov    %eax,%esi
	close(fd);
  801837:	89 1c 24             	mov    %ebx,(%esp)
  80183a:	e8 be fb ff ff       	call   8013fd <close>
	return r;
  80183f:	89 f3                	mov    %esi,%ebx
}
  801841:	89 d8                	mov    %ebx,%eax
  801843:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801846:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801849:	89 ec                	mov    %ebp,%esp
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    
  80184d:	00 00                	add    %al,(%eax)
	...

00801850 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 18             	sub    $0x18,%esp
  801856:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801859:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80185c:	89 c3                	mov    %eax,%ebx
  80185e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801860:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801867:	75 11                	jne    80187a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801869:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801870:	e8 0c 0f 00 00       	call   802781 <ipc_find_env>
  801875:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80187a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801881:	00 
  801882:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801889:	00 
  80188a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80188e:	a1 00 50 80 00       	mov    0x805000,%eax
  801893:	89 04 24             	mov    %eax,(%esp)
  801896:	e8 7b 0e 00 00       	call   802716 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80189b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018a2:	00 
  8018a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ae:	e8 fd 0d 00 00       	call   8026b0 <ipc_recv>
}
  8018b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018b6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018b9:	89 ec                	mov    %ebp,%esp
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	53                   	push   %ebx
  8018c1:	83 ec 14             	sub    $0x14,%esp
  8018c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cd:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018dc:	e8 6f ff ff ff       	call   801850 <fsipc>
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 2b                	js     801910 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8018ec:	00 
  8018ed:	89 1c 24             	mov    %ebx,(%esp)
  8018f0:	e8 16 f1 ff ff       	call   800a0b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f5:	a1 80 60 80 00       	mov    0x806080,%eax
  8018fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801900:	a1 84 60 80 00       	mov    0x806084,%eax
  801905:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801910:	83 c4 14             	add    $0x14,%esp
  801913:	5b                   	pop    %ebx
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	b8 06 00 00 00       	mov    $0x6,%eax
  801931:	e8 1a ff ff ff       	call   801850 <fsipc>
}
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	83 ec 10             	sub    $0x10,%esp
  801940:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	8b 40 0c             	mov    0xc(%eax),%eax
  801949:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80194e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801954:	ba 00 00 00 00       	mov    $0x0,%edx
  801959:	b8 03 00 00 00       	mov    $0x3,%eax
  80195e:	e8 ed fe ff ff       	call   801850 <fsipc>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	85 c0                	test   %eax,%eax
  801967:	78 6a                	js     8019d3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801969:	39 c6                	cmp    %eax,%esi
  80196b:	73 24                	jae    801991 <devfile_read+0x59>
  80196d:	c7 44 24 0c 98 2f 80 	movl   $0x802f98,0xc(%esp)
  801974:	00 
  801975:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  80197c:	00 
  80197d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801984:	00 
  801985:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  80198c:	e8 37 e8 ff ff       	call   8001c8 <_panic>
	assert(r <= PGSIZE);
  801991:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801996:	7e 24                	jle    8019bc <devfile_read+0x84>
  801998:	c7 44 24 0c bf 2f 80 	movl   $0x802fbf,0xc(%esp)
  80199f:	00 
  8019a0:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  8019a7:	00 
  8019a8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019af:	00 
  8019b0:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8019b7:	e8 0c e8 ff ff       	call   8001c8 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8019c7:	00 
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	89 04 24             	mov    %eax,(%esp)
  8019ce:	e8 29 f2 ff ff       	call   800bfc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  8019d3:	89 d8                	mov    %ebx,%eax
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 20             	sub    $0x20,%esp
  8019e4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e7:	89 34 24             	mov    %esi,(%esp)
  8019ea:	e8 d1 ef ff ff       	call   8009c0 <strlen>
		return -E_BAD_PATH;
  8019ef:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f9:	7f 5e                	jg     801a59 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 35 f8 ff ff       	call   80123b <fd_alloc>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 4d                	js     801a59 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a10:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801a17:	e8 ef ef ff ff       	call   800a0b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a27:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2c:	e8 1f fe ff ff       	call   801850 <fsipc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	85 c0                	test   %eax,%eax
  801a35:	79 15                	jns    801a4c <open+0x70>
		fd_close(fd, 0);
  801a37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a3e:	00 
  801a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a42:	89 04 24             	mov    %eax,(%esp)
  801a45:	e8 21 f9 ff ff       	call   80136b <fd_close>
		return r;
  801a4a:	eb 0d                	jmp    801a59 <open+0x7d>
	}

	return fd2num(fd);
  801a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4f:	89 04 24             	mov    %eax,(%esp)
  801a52:	e8 b9 f7 ff ff       	call   801210 <fd2num>
  801a57:	89 c3                	mov    %eax,%ebx
}
  801a59:	89 d8                	mov    %ebx,%eax
  801a5b:	83 c4 20             	add    $0x20,%esp
  801a5e:	5b                   	pop    %ebx
  801a5f:	5e                   	pop    %esi
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    
	...

00801a64 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	57                   	push   %edi
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a77:	00 
  801a78:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7b:	89 04 24             	mov    %eax,(%esp)
  801a7e:	e8 59 ff ff ff       	call   8019dc <open>
  801a83:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	0f 88 c9 05 00 00    	js     80205a <spawn+0x5f6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a91:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a98:	00 
  801a99:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 4d fb ff ff       	call   8015fe <readn>
  801ab1:	3d 00 02 00 00       	cmp    $0x200,%eax
  801ab6:	75 0c                	jne    801ac4 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801ab8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801abf:	45 4c 46 
  801ac2:	74 3b                	je     801aff <spawn+0x9b>
		close(fd);
  801ac4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801aca:	89 04 24             	mov    %eax,(%esp)
  801acd:	e8 2b f9 ff ff       	call   8013fd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ad2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ad9:	46 
  801ada:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae4:	c7 04 24 cb 2f 80 00 	movl   $0x802fcb,(%esp)
  801aeb:	e8 d3 e7 ff ff       	call   8002c3 <cprintf>
		return -E_NOT_EXEC;
  801af0:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801af7:	ff ff ff 
  801afa:	e9 67 05 00 00       	jmp    802066 <spawn+0x602>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801aff:	ba 07 00 00 00       	mov    $0x7,%edx
  801b04:	89 d0                	mov    %edx,%eax
  801b06:	cd 30                	int    $0x30
  801b08:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801b0e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801b14:	85 c0                	test   %eax,%eax
  801b16:	0f 88 4a 05 00 00    	js     802066 <spawn+0x602>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b1c:	89 c6                	mov    %eax,%esi
  801b1e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801b24:	c1 e6 07             	shl    $0x7,%esi
  801b27:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801b2d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b33:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b3a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b40:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b49:	8b 02                	mov    (%edx),%eax
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	74 5f                	je     801bae <spawn+0x14a>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801b4f:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (argc = 0; argv[argc] != 0; argc++)
  801b54:	be 00 00 00 00       	mov    $0x0,%esi
  801b59:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  801b5b:	89 04 24             	mov    %eax,(%esp)
  801b5e:	e8 5d ee ff ff       	call   8009c0 <strlen>
  801b63:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b67:	83 c6 01             	add    $0x1,%esi
  801b6a:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b6c:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b73:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801b76:	85 c0                	test   %eax,%eax
  801b78:	75 e1                	jne    801b5b <spawn+0xf7>
  801b7a:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801b80:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b86:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b8b:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	83 e0 fc             	and    $0xfffffffc,%eax
  801b92:	f7 d2                	not    %edx
  801b94:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801b97:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b9d:	89 d0                	mov    %edx,%eax
  801b9f:	83 e8 08             	sub    $0x8,%eax
  801ba2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ba7:	77 2d                	ja     801bd6 <spawn+0x172>
  801ba9:	e9 c9 04 00 00       	jmp    802077 <spawn+0x613>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801bae:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801bb5:	00 00 00 
  801bb8:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801bbf:	00 00 00 
  801bc2:	be 00 00 00 00       	mov    $0x0,%esi
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801bc7:	c7 85 94 fd ff ff fc 	movl   $0x400ffc,-0x26c(%ebp)
  801bce:	0f 40 00 
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801bd1:	bf 00 10 40 00       	mov    $0x401000,%edi
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bd6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bdd:	00 
  801bde:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801be5:	00 
  801be6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bed:	e8 1a f3 ff ff       	call   800f0c <sys_page_alloc>
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	0f 88 82 04 00 00    	js     80207c <spawn+0x618>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bfa:	85 f6                	test   %esi,%esi
  801bfc:	7e 46                	jle    801c44 <spawn+0x1e0>
  801bfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c03:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801c09:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  801c0c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801c12:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c18:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801c1b:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c22:	89 3c 24             	mov    %edi,(%esp)
  801c25:	e8 e1 ed ff ff       	call   800a0b <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c2a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801c2d:	89 04 24             	mov    %eax,(%esp)
  801c30:	e8 8b ed ff ff       	call   8009c0 <strlen>
  801c35:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c39:	83 c3 01             	add    $0x1,%ebx
  801c3c:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801c42:	75 c8                	jne    801c0c <spawn+0x1a8>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c44:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c4a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c50:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c57:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c5d:	74 24                	je     801c83 <spawn+0x21f>
  801c5f:	c7 44 24 0c 40 30 80 	movl   $0x803040,0xc(%esp)
  801c66:	00 
  801c67:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  801c6e:	00 
  801c6f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801c76:	00 
  801c77:	c7 04 24 e5 2f 80 00 	movl   $0x802fe5,(%esp)
  801c7e:	e8 45 e5 ff ff       	call   8001c8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c83:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c89:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c8e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c94:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801c97:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c9d:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ca0:	89 d0                	mov    %edx,%eax
  801ca2:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ca7:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801cad:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801cb4:	00 
  801cb5:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801cbc:	ee 
  801cbd:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc7:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cce:	00 
  801ccf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd6:	e8 90 f2 ff ff       	call   800f6b <sys_page_map>
  801cdb:	89 c3                	mov    %eax,%ebx
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 1a                	js     801cfb <spawn+0x297>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ce1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ce8:	00 
  801ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf0:	e8 d4 f2 ff ff       	call   800fc9 <sys_page_unmap>
  801cf5:	89 c3                	mov    %eax,%ebx
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	79 1f                	jns    801d1a <spawn+0x2b6>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801cfb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d02:	00 
  801d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0a:	e8 ba f2 ff ff       	call   800fc9 <sys_page_unmap>
	return r;
  801d0f:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801d15:	e9 4c 03 00 00       	jmp    802066 <spawn+0x602>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d1a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d20:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801d27:	00 
  801d28:	0f 84 e2 01 00 00    	je     801f10 <spawn+0x4ac>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d2e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801d35:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d3b:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801d42:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801d45:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d4b:	83 3a 01             	cmpl   $0x1,(%edx)
  801d4e:	0f 85 9b 01 00 00    	jne    801eef <spawn+0x48b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d54:	8b 42 18             	mov    0x18(%edx),%eax
  801d57:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801d5a:	83 f8 01             	cmp    $0x1,%eax
  801d5d:	19 c0                	sbb    %eax,%eax
  801d5f:	83 e0 fe             	and    $0xfffffffe,%eax
  801d62:	83 c0 07             	add    $0x7,%eax
  801d65:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d6b:	8b 52 04             	mov    0x4(%edx),%edx
  801d6e:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801d74:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d7a:	8b 70 10             	mov    0x10(%eax),%esi
  801d7d:	8b 50 14             	mov    0x14(%eax),%edx
  801d80:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d86:	8b 40 08             	mov    0x8(%eax),%eax
  801d89:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d8f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d94:	74 16                	je     801dac <spawn+0x348>
		va -= i;
  801d96:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  801d9c:	01 c2                	add    %eax,%edx
  801d9e:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801da4:	01 c6                	add    %eax,%esi
		fileoffset -= i;
  801da6:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801dac:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801db3:	0f 84 36 01 00 00    	je     801eef <spawn+0x48b>
  801db9:	bf 00 00 00 00       	mov    $0x0,%edi
  801dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801dc3:	39 f7                	cmp    %esi,%edi
  801dc5:	72 31                	jb     801df8 <spawn+0x394>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801dc7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dcd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd1:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801dd7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ddb:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801de1:	89 04 24             	mov    %eax,(%esp)
  801de4:	e8 23 f1 ff ff       	call   800f0c <sys_page_alloc>
  801de9:	85 c0                	test   %eax,%eax
  801deb:	0f 89 ea 00 00 00    	jns    801edb <spawn+0x477>
  801df1:	89 c6                	mov    %eax,%esi
  801df3:	e9 3e 02 00 00       	jmp    802036 <spawn+0x5d2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801df8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801dff:	00 
  801e00:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e07:	00 
  801e08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0f:	e8 f8 f0 ff ff       	call   800f0c <sys_page_alloc>
  801e14:	85 c0                	test   %eax,%eax
  801e16:	0f 88 10 02 00 00    	js     80202c <spawn+0x5c8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801e1c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801e22:	01 d8                	add    %ebx,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e28:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e2e:	89 04 24             	mov    %eax,(%esp)
  801e31:	e8 a3 f8 ff ff       	call   8016d9 <seek>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	0f 88 f2 01 00 00    	js     802030 <spawn+0x5cc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e3e:	89 f0                	mov    %esi,%eax
  801e40:	29 f8                	sub    %edi,%eax
  801e42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e47:	ba 00 10 00 00       	mov    $0x1000,%edx
  801e4c:	0f 47 c2             	cmova  %edx,%eax
  801e4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e53:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e5a:	00 
  801e5b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e61:	89 04 24             	mov    %eax,(%esp)
  801e64:	e8 95 f7 ff ff       	call   8015fe <readn>
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	0f 88 c3 01 00 00    	js     802034 <spawn+0x5d0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e71:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e77:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e7b:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801e81:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e85:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e8f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e96:	00 
  801e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9e:	e8 c8 f0 ff ff       	call   800f6b <sys_page_map>
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	79 20                	jns    801ec7 <spawn+0x463>
				panic("spawn: sys_page_map data: %e", r);
  801ea7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eab:	c7 44 24 08 f1 2f 80 	movl   $0x802ff1,0x8(%esp)
  801eb2:	00 
  801eb3:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801eba:	00 
  801ebb:	c7 04 24 e5 2f 80 00 	movl   $0x802fe5,(%esp)
  801ec2:	e8 01 e3 ff ff       	call   8001c8 <_panic>
			sys_page_unmap(0, UTEMP);
  801ec7:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ece:	00 
  801ecf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed6:	e8 ee f0 ff ff       	call   800fc9 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801edb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ee1:	89 df                	mov    %ebx,%edi
  801ee3:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801ee9:	0f 82 d4 fe ff ff    	jb     801dc3 <spawn+0x35f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801eef:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801ef6:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801efd:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f04:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801f0a:	0f 8f 35 fe ff ff    	jg     801d45 <spawn+0x2e1>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f10:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f16:	89 04 24             	mov    %eax,(%esp)
  801f19:	e8 df f4 ff ff       	call   8013fd <close>
  801f1e:	bf 00 00 00 00       	mov    $0x0,%edi
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  801f23:	be 00 00 00 00       	mov    $0x0,%esi
  801f28:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(i * PGSIZE)] & PTE_P) && (uvpt[i] & PTE_P) && (uvpt[i] & PTE_SHARE)) {
  801f2e:	89 f8                	mov    %edi,%eax
  801f30:	c1 e8 16             	shr    $0x16,%eax
  801f33:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f3a:	a8 01                	test   $0x1,%al
  801f3c:	74 63                	je     801fa1 <spawn+0x53d>
  801f3e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801f45:	a8 01                	test   $0x1,%al
  801f47:	74 58                	je     801fa1 <spawn+0x53d>
  801f49:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801f50:	f6 c4 04             	test   $0x4,%ah
  801f53:	74 4c                	je     801fa1 <spawn+0x53d>
			res = sys_page_map(0, (void *)(i * PGSIZE), child, (void *)(i * PGSIZE), uvpt[i] & PTE_SYSCALL);
  801f55:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801f5c:	25 07 0e 00 00       	and    $0xe07,%eax
  801f61:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f65:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f6d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f78:	e8 ee ef ff ff       	call   800f6b <sys_page_map>
			if (res < 0)
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	79 20                	jns    801fa1 <spawn+0x53d>
				panic("sys_page_map failed in copy_shared_pages %e\n", res);
  801f81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f85:	c7 44 24 08 68 30 80 	movl   $0x803068,0x8(%esp)
  801f8c:	00 
  801f8d:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  801f94:	00 
  801f95:	c7 04 24 e5 2f 80 00 	movl   $0x802fe5,(%esp)
  801f9c:	e8 27 e2 ff ff       	call   8001c8 <_panic>
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  801fa1:	83 c6 01             	add    $0x1,%esi
  801fa4:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801faa:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801fb0:	0f 85 78 ff ff ff    	jne    801f2e <spawn+0x4ca>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801fb6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fc6:	89 04 24             	mov    %eax,(%esp)
  801fc9:	e8 b7 f0 ff ff       	call   801085 <sys_env_set_trapframe>
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	79 20                	jns    801ff2 <spawn+0x58e>
		panic("sys_env_set_trapframe: %e", r);
  801fd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd6:	c7 44 24 08 0e 30 80 	movl   $0x80300e,0x8(%esp)
  801fdd:	00 
  801fde:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801fe5:	00 
  801fe6:	c7 04 24 e5 2f 80 00 	movl   $0x802fe5,(%esp)
  801fed:	e8 d6 e1 ff ff       	call   8001c8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ff2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801ff9:	00 
  801ffa:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802000:	89 04 24             	mov    %eax,(%esp)
  802003:	e8 1f f0 ff ff       	call   801027 <sys_env_set_status>
  802008:	85 c0                	test   %eax,%eax
  80200a:	79 5a                	jns    802066 <spawn+0x602>
		panic("sys_env_set_status: %e", r);
  80200c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802010:	c7 44 24 08 28 30 80 	movl   $0x803028,0x8(%esp)
  802017:	00 
  802018:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  80201f:	00 
  802020:	c7 04 24 e5 2f 80 00 	movl   $0x802fe5,(%esp)
  802027:	e8 9c e1 ff ff       	call   8001c8 <_panic>
  80202c:	89 c6                	mov    %eax,%esi
  80202e:	eb 06                	jmp    802036 <spawn+0x5d2>
  802030:	89 c6                	mov    %eax,%esi
  802032:	eb 02                	jmp    802036 <spawn+0x5d2>
  802034:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802036:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80203c:	89 04 24             	mov    %eax,(%esp)
  80203f:	e8 0b ee ff ff       	call   800e4f <sys_env_destroy>
	close(fd);
  802044:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80204a:	89 04 24             	mov    %eax,(%esp)
  80204d:	e8 ab f3 ff ff       	call   8013fd <close>
	return r;
  802052:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802058:	eb 0c                	jmp    802066 <spawn+0x602>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80205a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802060:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802066:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80206c:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802072:	5b                   	pop    %ebx
  802073:	5e                   	pop    %esi
  802074:	5f                   	pop    %edi
  802075:	5d                   	pop    %ebp
  802076:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802077:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  80207c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802082:	eb e2                	jmp    802066 <spawn+0x602>

00802084 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	83 ec 10             	sub    $0x10,%esp
  80208c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80208f:	8d 45 14             	lea    0x14(%ebp),%eax
  802092:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802096:	74 66                	je     8020fe <spawnl+0x7a>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802098:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  80209d:	83 c1 01             	add    $0x1,%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020a0:	89 c2                	mov    %eax,%edx
  8020a2:	83 c0 04             	add    $0x4,%eax
  8020a5:	83 3a 00             	cmpl   $0x0,(%edx)
  8020a8:	75 f3                	jne    80209d <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020aa:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8020b1:	83 e0 f0             	and    $0xfffffff0,%eax
  8020b4:	29 c4                	sub    %eax,%esp
  8020b6:	8d 44 24 17          	lea    0x17(%esp),%eax
  8020ba:	83 e0 f0             	and    $0xfffffff0,%eax
  8020bd:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8020bf:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8020c1:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  8020c8:	00 

	va_start(vl, arg0);
  8020c9:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8020cc:	89 ce                	mov    %ecx,%esi
  8020ce:	85 c9                	test   %ecx,%ecx
  8020d0:	74 16                	je     8020e8 <spawnl+0x64>
  8020d2:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8020d7:	83 c0 01             	add    $0x1,%eax
  8020da:	89 d1                	mov    %edx,%ecx
  8020dc:	83 c2 04             	add    $0x4,%edx
  8020df:	8b 09                	mov    (%ecx),%ecx
  8020e1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8020e4:	39 f0                	cmp    %esi,%eax
  8020e6:	75 ef                	jne    8020d7 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8020e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ef:	89 04 24             	mov    %eax,(%esp)
  8020f2:	e8 6d f9 ff ff       	call   801a64 <spawn>
}
  8020f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020fe:	83 ec 20             	sub    $0x20,%esp
  802101:	8d 44 24 17          	lea    0x17(%esp),%eax
  802105:	83 e0 f0             	and    $0xfffffff0,%eax
  802108:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80210a:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80210c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802113:	eb d3                	jmp    8020e8 <spawnl+0x64>
	...

00802120 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 18             	sub    $0x18,%esp
  802126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802129:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80212c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80212f:	8b 45 08             	mov    0x8(%ebp),%eax
  802132:	89 04 24             	mov    %eax,(%esp)
  802135:	e8 e6 f0 ff ff       	call   801220 <fd2data>
  80213a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80213c:	c7 44 24 04 98 30 80 	movl   $0x803098,0x4(%esp)
  802143:	00 
  802144:	89 34 24             	mov    %esi,(%esp)
  802147:	e8 bf e8 ff ff       	call   800a0b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80214c:	8b 43 04             	mov    0x4(%ebx),%eax
  80214f:	2b 03                	sub    (%ebx),%eax
  802151:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802157:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80215e:	00 00 00 
	stat->st_dev = &devpipe;
  802161:	c7 86 88 00 00 00 24 	movl   $0x804024,0x88(%esi)
  802168:	40 80 00 
	return 0;
}
  80216b:	b8 00 00 00 00       	mov    $0x0,%eax
  802170:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802173:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802176:	89 ec                	mov    %ebp,%esp
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    

0080217a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	53                   	push   %ebx
  80217e:	83 ec 14             	sub    $0x14,%esp
  802181:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802188:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218f:	e8 35 ee ff ff       	call   800fc9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802194:	89 1c 24             	mov    %ebx,(%esp)
  802197:	e8 84 f0 ff ff       	call   801220 <fd2data>
  80219c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a7:	e8 1d ee ff ff       	call   800fc9 <sys_page_unmap>
}
  8021ac:	83 c4 14             	add    $0x14,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    

008021b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021b2:	55                   	push   %ebp
  8021b3:	89 e5                	mov    %esp,%ebp
  8021b5:	57                   	push   %edi
  8021b6:	56                   	push   %esi
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 2c             	sub    $0x2c,%esp
  8021bb:	89 c7                	mov    %eax,%edi
  8021bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021c0:	a1 04 50 80 00       	mov    0x805004,%eax
  8021c5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021c8:	89 3c 24             	mov    %edi,(%esp)
  8021cb:	e8 fc 05 00 00       	call   8027cc <pageref>
  8021d0:	89 c6                	mov    %eax,%esi
  8021d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021d5:	89 04 24             	mov    %eax,(%esp)
  8021d8:	e8 ef 05 00 00       	call   8027cc <pageref>
  8021dd:	39 c6                	cmp    %eax,%esi
  8021df:	0f 94 c0             	sete   %al
  8021e2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021e5:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8021eb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021ee:	39 cb                	cmp    %ecx,%ebx
  8021f0:	75 08                	jne    8021fa <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021f2:	83 c4 2c             	add    $0x2c,%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8021fa:	83 f8 01             	cmp    $0x1,%eax
  8021fd:	75 c1                	jne    8021c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021ff:	8b 52 58             	mov    0x58(%edx),%edx
  802202:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802206:	89 54 24 08          	mov    %edx,0x8(%esp)
  80220a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80220e:	c7 04 24 9f 30 80 00 	movl   $0x80309f,(%esp)
  802215:	e8 a9 e0 ff ff       	call   8002c3 <cprintf>
  80221a:	eb a4                	jmp    8021c0 <_pipeisclosed+0xe>

0080221c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	57                   	push   %edi
  802220:	56                   	push   %esi
  802221:	53                   	push   %ebx
  802222:	83 ec 2c             	sub    $0x2c,%esp
  802225:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802228:	89 34 24             	mov    %esi,(%esp)
  80222b:	e8 f0 ef ff ff       	call   801220 <fd2data>
  802230:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802232:	bf 00 00 00 00       	mov    $0x0,%edi
  802237:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80223b:	75 50                	jne    80228d <devpipe_write+0x71>
  80223d:	eb 5c                	jmp    80229b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80223f:	89 da                	mov    %ebx,%edx
  802241:	89 f0                	mov    %esi,%eax
  802243:	e8 6a ff ff ff       	call   8021b2 <_pipeisclosed>
  802248:	85 c0                	test   %eax,%eax
  80224a:	75 53                	jne    80229f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80224c:	e8 8b ec ff ff       	call   800edc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802251:	8b 43 04             	mov    0x4(%ebx),%eax
  802254:	8b 13                	mov    (%ebx),%edx
  802256:	83 c2 20             	add    $0x20,%edx
  802259:	39 d0                	cmp    %edx,%eax
  80225b:	73 e2                	jae    80223f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80225d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802260:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802264:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802267:	89 c2                	mov    %eax,%edx
  802269:	c1 fa 1f             	sar    $0x1f,%edx
  80226c:	c1 ea 1b             	shr    $0x1b,%edx
  80226f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802272:	83 e1 1f             	and    $0x1f,%ecx
  802275:	29 d1                	sub    %edx,%ecx
  802277:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80227b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80227f:	83 c0 01             	add    $0x1,%eax
  802282:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802285:	83 c7 01             	add    $0x1,%edi
  802288:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80228b:	74 0e                	je     80229b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80228d:	8b 43 04             	mov    0x4(%ebx),%eax
  802290:	8b 13                	mov    (%ebx),%edx
  802292:	83 c2 20             	add    $0x20,%edx
  802295:	39 d0                	cmp    %edx,%eax
  802297:	73 a6                	jae    80223f <devpipe_write+0x23>
  802299:	eb c2                	jmp    80225d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80229b:	89 f8                	mov    %edi,%eax
  80229d:	eb 05                	jmp    8022a4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80229f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022a4:	83 c4 2c             	add    $0x2c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    

008022ac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	83 ec 28             	sub    $0x28,%esp
  8022b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8022b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8022b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8022bb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022be:	89 3c 24             	mov    %edi,(%esp)
  8022c1:	e8 5a ef ff ff       	call   801220 <fd2data>
  8022c6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022c8:	be 00 00 00 00       	mov    $0x0,%esi
  8022cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022d1:	75 47                	jne    80231a <devpipe_read+0x6e>
  8022d3:	eb 52                	jmp    802327 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	eb 5e                	jmp    802337 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022d9:	89 da                	mov    %ebx,%edx
  8022db:	89 f8                	mov    %edi,%eax
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	e8 cd fe ff ff       	call   8021b2 <_pipeisclosed>
  8022e5:	85 c0                	test   %eax,%eax
  8022e7:	75 49                	jne    802332 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8022e9:	e8 ee eb ff ff       	call   800edc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022ee:	8b 03                	mov    (%ebx),%eax
  8022f0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022f3:	74 e4                	je     8022d9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022f5:	89 c2                	mov    %eax,%edx
  8022f7:	c1 fa 1f             	sar    $0x1f,%edx
  8022fa:	c1 ea 1b             	shr    $0x1b,%edx
  8022fd:	01 d0                	add    %edx,%eax
  8022ff:	83 e0 1f             	and    $0x1f,%eax
  802302:	29 d0                	sub    %edx,%eax
  802304:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802309:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80230f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802312:	83 c6 01             	add    $0x1,%esi
  802315:	3b 75 10             	cmp    0x10(%ebp),%esi
  802318:	74 0d                	je     802327 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80231a:	8b 03                	mov    (%ebx),%eax
  80231c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80231f:	75 d4                	jne    8022f5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802321:	85 f6                	test   %esi,%esi
  802323:	75 b0                	jne    8022d5 <devpipe_read+0x29>
  802325:	eb b2                	jmp    8022d9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802327:	89 f0                	mov    %esi,%eax
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	eb 05                	jmp    802337 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80233a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80233d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802340:	89 ec                	mov    %ebp,%esp
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    

00802344 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	83 ec 48             	sub    $0x48,%esp
  80234a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80234d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802350:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802353:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802356:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802359:	89 04 24             	mov    %eax,(%esp)
  80235c:	e8 da ee ff ff       	call   80123b <fd_alloc>
  802361:	89 c3                	mov    %eax,%ebx
  802363:	85 c0                	test   %eax,%eax
  802365:	0f 88 45 01 00 00    	js     8024b0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802372:	00 
  802373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802381:	e8 86 eb ff ff       	call   800f0c <sys_page_alloc>
  802386:	89 c3                	mov    %eax,%ebx
  802388:	85 c0                	test   %eax,%eax
  80238a:	0f 88 20 01 00 00    	js     8024b0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802390:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802393:	89 04 24             	mov    %eax,(%esp)
  802396:	e8 a0 ee ff ff       	call   80123b <fd_alloc>
  80239b:	89 c3                	mov    %eax,%ebx
  80239d:	85 c0                	test   %eax,%eax
  80239f:	0f 88 f8 00 00 00    	js     80249d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023ac:	00 
  8023ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023bb:	e8 4c eb ff ff       	call   800f0c <sys_page_alloc>
  8023c0:	89 c3                	mov    %eax,%ebx
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	0f 88 d3 00 00 00    	js     80249d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023cd:	89 04 24             	mov    %eax,(%esp)
  8023d0:	e8 4b ee ff ff       	call   801220 <fd2data>
  8023d5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023d7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023de:	00 
  8023df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ea:	e8 1d eb ff ff       	call   800f0c <sys_page_alloc>
  8023ef:	89 c3                	mov    %eax,%ebx
  8023f1:	85 c0                	test   %eax,%eax
  8023f3:	0f 88 91 00 00 00    	js     80248a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023fc:	89 04 24             	mov    %eax,(%esp)
  8023ff:	e8 1c ee ff ff       	call   801220 <fd2data>
  802404:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80240b:	00 
  80240c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802410:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802417:	00 
  802418:	89 74 24 04          	mov    %esi,0x4(%esp)
  80241c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802423:	e8 43 eb ff ff       	call   800f6b <sys_page_map>
  802428:	89 c3                	mov    %eax,%ebx
  80242a:	85 c0                	test   %eax,%eax
  80242c:	78 4c                	js     80247a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80242e:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802437:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80243c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802443:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802449:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80244c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80244e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802451:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80245b:	89 04 24             	mov    %eax,(%esp)
  80245e:	e8 ad ed ff ff       	call   801210 <fd2num>
  802463:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802465:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802468:	89 04 24             	mov    %eax,(%esp)
  80246b:	e8 a0 ed ff ff       	call   801210 <fd2num>
  802470:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802473:	bb 00 00 00 00       	mov    $0x0,%ebx
  802478:	eb 36                	jmp    8024b0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80247a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80247e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802485:	e8 3f eb ff ff       	call   800fc9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80248a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80248d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802491:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802498:	e8 2c eb ff ff       	call   800fc9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80249d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024ab:	e8 19 eb ff ff       	call   800fc9 <sys_page_unmap>
    err:
	return r;
}
  8024b0:	89 d8                	mov    %ebx,%eax
  8024b2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8024b5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8024b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8024bb:	89 ec                	mov    %ebp,%esp
  8024bd:	5d                   	pop    %ebp
  8024be:	c3                   	ret    

008024bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024bf:	55                   	push   %ebp
  8024c0:	89 e5                	mov    %esp,%ebp
  8024c2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cf:	89 04 24             	mov    %eax,(%esp)
  8024d2:	e8 d7 ed ff ff       	call   8012ae <fd_lookup>
  8024d7:	85 c0                	test   %eax,%eax
  8024d9:	78 15                	js     8024f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024de:	89 04 24             	mov    %eax,(%esp)
  8024e1:	e8 3a ed ff ff       	call   801220 <fd2data>
	return _pipeisclosed(fd, p);
  8024e6:	89 c2                	mov    %eax,%edx
  8024e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024eb:	e8 c2 fc ff ff       	call   8021b2 <_pipeisclosed>
}
  8024f0:	c9                   	leave  
  8024f1:	c3                   	ret    
	...

00802500 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802500:	55                   	push   %ebp
  802501:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802503:	b8 00 00 00 00       	mov    $0x0,%eax
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    

0080250a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80250a:	55                   	push   %ebp
  80250b:	89 e5                	mov    %esp,%ebp
  80250d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802510:	c7 44 24 04 b7 30 80 	movl   $0x8030b7,0x4(%esp)
  802517:	00 
  802518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80251b:	89 04 24             	mov    %eax,(%esp)
  80251e:	e8 e8 e4 ff ff       	call   800a0b <strcpy>
	return 0;
}
  802523:	b8 00 00 00 00       	mov    $0x0,%eax
  802528:	c9                   	leave  
  802529:	c3                   	ret    

0080252a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80252a:	55                   	push   %ebp
  80252b:	89 e5                	mov    %esp,%ebp
  80252d:	57                   	push   %edi
  80252e:	56                   	push   %esi
  80252f:	53                   	push   %ebx
  802530:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802536:	be 00 00 00 00       	mov    $0x0,%esi
  80253b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80253f:	74 43                	je     802584 <devcons_write+0x5a>
  802541:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802546:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80254c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80254f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802551:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802554:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802559:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80255c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802560:	03 45 0c             	add    0xc(%ebp),%eax
  802563:	89 44 24 04          	mov    %eax,0x4(%esp)
  802567:	89 3c 24             	mov    %edi,(%esp)
  80256a:	e8 8d e6 ff ff       	call   800bfc <memmove>
		sys_cputs(buf, m);
  80256f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802573:	89 3c 24             	mov    %edi,(%esp)
  802576:	e8 75 e8 ff ff       	call   800df0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80257b:	01 de                	add    %ebx,%esi
  80257d:	89 f0                	mov    %esi,%eax
  80257f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802582:	72 c8                	jb     80254c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802584:	89 f0                	mov    %esi,%eax
  802586:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80258c:	5b                   	pop    %ebx
  80258d:	5e                   	pop    %esi
  80258e:	5f                   	pop    %edi
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    

00802591 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802597:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80259c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025a0:	75 07                	jne    8025a9 <devcons_read+0x18>
  8025a2:	eb 31                	jmp    8025d5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025a4:	e8 33 e9 ff ff       	call   800edc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	e8 6a e8 ff ff       	call   800e1f <sys_cgetc>
  8025b5:	85 c0                	test   %eax,%eax
  8025b7:	74 eb                	je     8025a4 <devcons_read+0x13>
  8025b9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025bb:	85 c0                	test   %eax,%eax
  8025bd:	78 16                	js     8025d5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025bf:	83 f8 04             	cmp    $0x4,%eax
  8025c2:	74 0c                	je     8025d0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8025c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c7:	88 10                	mov    %dl,(%eax)
	return 1;
  8025c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ce:	eb 05                	jmp    8025d5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025d0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025d5:	c9                   	leave  
  8025d6:	c3                   	ret    

008025d7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025d7:	55                   	push   %ebp
  8025d8:	89 e5                	mov    %esp,%ebp
  8025da:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8025dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8025ea:	00 
  8025eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025ee:	89 04 24             	mov    %eax,(%esp)
  8025f1:	e8 fa e7 ff ff       	call   800df0 <sys_cputs>
}
  8025f6:	c9                   	leave  
  8025f7:	c3                   	ret    

008025f8 <getchar>:

int
getchar(void)
{
  8025f8:	55                   	push   %ebp
  8025f9:	89 e5                	mov    %esp,%ebp
  8025fb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802605:	00 
  802606:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802614:	e8 55 ef ff ff       	call   80156e <read>
	if (r < 0)
  802619:	85 c0                	test   %eax,%eax
  80261b:	78 0f                	js     80262c <getchar+0x34>
		return r;
	if (r < 1)
  80261d:	85 c0                	test   %eax,%eax
  80261f:	7e 06                	jle    802627 <getchar+0x2f>
		return -E_EOF;
	return c;
  802621:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802625:	eb 05                	jmp    80262c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802627:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80262c:	c9                   	leave  
  80262d:	c3                   	ret    

0080262e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80262e:	55                   	push   %ebp
  80262f:	89 e5                	mov    %esp,%ebp
  802631:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802634:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80263b:	8b 45 08             	mov    0x8(%ebp),%eax
  80263e:	89 04 24             	mov    %eax,(%esp)
  802641:	e8 68 ec ff ff       	call   8012ae <fd_lookup>
  802646:	85 c0                	test   %eax,%eax
  802648:	78 11                	js     80265b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80264a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264d:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802653:	39 10                	cmp    %edx,(%eax)
  802655:	0f 94 c0             	sete   %al
  802658:	0f b6 c0             	movzbl %al,%eax
}
  80265b:	c9                   	leave  
  80265c:	c3                   	ret    

0080265d <opencons>:

int
opencons(void)
{
  80265d:	55                   	push   %ebp
  80265e:	89 e5                	mov    %esp,%ebp
  802660:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802666:	89 04 24             	mov    %eax,(%esp)
  802669:	e8 cd eb ff ff       	call   80123b <fd_alloc>
  80266e:	85 c0                	test   %eax,%eax
  802670:	78 3c                	js     8026ae <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802672:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802679:	00 
  80267a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80267d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802681:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802688:	e8 7f e8 ff ff       	call   800f0c <sys_page_alloc>
  80268d:	85 c0                	test   %eax,%eax
  80268f:	78 1d                	js     8026ae <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802691:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80269c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026a6:	89 04 24             	mov    %eax,(%esp)
  8026a9:	e8 62 eb ff ff       	call   801210 <fd2num>
}
  8026ae:	c9                   	leave  
  8026af:	c3                   	ret    

008026b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026b0:	55                   	push   %ebp
  8026b1:	89 e5                	mov    %esp,%ebp
  8026b3:	56                   	push   %esi
  8026b4:	53                   	push   %ebx
  8026b5:	83 ec 10             	sub    $0x10,%esp
  8026b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8026bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026be:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8026c1:	85 db                	test   %ebx,%ebx
  8026c3:	74 06                	je     8026cb <ipc_recv+0x1b>
  8026c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8026cb:	85 f6                	test   %esi,%esi
  8026cd:	74 06                	je     8026d5 <ipc_recv+0x25>
  8026cf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8026dc:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  8026df:	89 04 24             	mov    %eax,(%esp)
  8026e2:	e8 8e ea ff ff       	call   801175 <sys_ipc_recv>
    if (ret) return ret;
  8026e7:	85 c0                	test   %eax,%eax
  8026e9:	75 24                	jne    80270f <ipc_recv+0x5f>
    if (from_env_store)
  8026eb:	85 db                	test   %ebx,%ebx
  8026ed:	74 0a                	je     8026f9 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  8026ef:	a1 04 50 80 00       	mov    0x805004,%eax
  8026f4:	8b 40 74             	mov    0x74(%eax),%eax
  8026f7:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8026f9:	85 f6                	test   %esi,%esi
  8026fb:	74 0a                	je     802707 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8026fd:	a1 04 50 80 00       	mov    0x805004,%eax
  802702:	8b 40 78             	mov    0x78(%eax),%eax
  802705:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802707:	a1 04 50 80 00       	mov    0x805004,%eax
  80270c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80270f:	83 c4 10             	add    $0x10,%esp
  802712:	5b                   	pop    %ebx
  802713:	5e                   	pop    %esi
  802714:	5d                   	pop    %ebp
  802715:	c3                   	ret    

00802716 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802716:	55                   	push   %ebp
  802717:	89 e5                	mov    %esp,%ebp
  802719:	57                   	push   %edi
  80271a:	56                   	push   %esi
  80271b:	53                   	push   %ebx
  80271c:	83 ec 1c             	sub    $0x1c,%esp
  80271f:	8b 75 08             	mov    0x8(%ebp),%esi
  802722:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802725:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802728:	85 db                	test   %ebx,%ebx
  80272a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80272f:	0f 44 d8             	cmove  %eax,%ebx
  802732:	eb 2a                	jmp    80275e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802734:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802737:	74 20                	je     802759 <ipc_send+0x43>
  802739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80273d:	c7 44 24 08 c3 30 80 	movl   $0x8030c3,0x8(%esp)
  802744:	00 
  802745:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80274c:	00 
  80274d:	c7 04 24 da 30 80 00 	movl   $0x8030da,(%esp)
  802754:	e8 6f da ff ff       	call   8001c8 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802759:	e8 7e e7 ff ff       	call   800edc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80275e:	8b 45 14             	mov    0x14(%ebp),%eax
  802761:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802765:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802769:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80276d:	89 34 24             	mov    %esi,(%esp)
  802770:	e8 cc e9 ff ff       	call   801141 <sys_ipc_try_send>
  802775:	85 c0                	test   %eax,%eax
  802777:	75 bb                	jne    802734 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802779:	83 c4 1c             	add    $0x1c,%esp
  80277c:	5b                   	pop    %ebx
  80277d:	5e                   	pop    %esi
  80277e:	5f                   	pop    %edi
  80277f:	5d                   	pop    %ebp
  802780:	c3                   	ret    

00802781 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802781:	55                   	push   %ebp
  802782:	89 e5                	mov    %esp,%ebp
  802784:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802787:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80278c:	39 c8                	cmp    %ecx,%eax
  80278e:	74 19                	je     8027a9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802790:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802795:	89 c2                	mov    %eax,%edx
  802797:	c1 e2 07             	shl    $0x7,%edx
  80279a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027a0:	8b 52 50             	mov    0x50(%edx),%edx
  8027a3:	39 ca                	cmp    %ecx,%edx
  8027a5:	75 14                	jne    8027bb <ipc_find_env+0x3a>
  8027a7:	eb 05                	jmp    8027ae <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8027ae:	c1 e0 07             	shl    $0x7,%eax
  8027b1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027b6:	8b 40 40             	mov    0x40(%eax),%eax
  8027b9:	eb 0e                	jmp    8027c9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027bb:	83 c0 01             	add    $0x1,%eax
  8027be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027c3:	75 d0                	jne    802795 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027c5:	66 b8 00 00          	mov    $0x0,%ax
}
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    
	...

008027cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027cc:	55                   	push   %ebp
  8027cd:	89 e5                	mov    %esp,%ebp
  8027cf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027d2:	89 d0                	mov    %edx,%eax
  8027d4:	c1 e8 16             	shr    $0x16,%eax
  8027d7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027de:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027e3:	f6 c1 01             	test   $0x1,%cl
  8027e6:	74 1d                	je     802805 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027e8:	c1 ea 0c             	shr    $0xc,%edx
  8027eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027f2:	f6 c2 01             	test   $0x1,%dl
  8027f5:	74 0e                	je     802805 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027f7:	c1 ea 0c             	shr    $0xc,%edx
  8027fa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802801:	ef 
  802802:	0f b7 c0             	movzwl %ax,%eax
}
  802805:	5d                   	pop    %ebp
  802806:	c3                   	ret    
	...

00802810 <__udivdi3>:
  802810:	83 ec 1c             	sub    $0x1c,%esp
  802813:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802817:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80281b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80281f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802823:	89 74 24 10          	mov    %esi,0x10(%esp)
  802827:	8b 74 24 24          	mov    0x24(%esp),%esi
  80282b:	85 ff                	test   %edi,%edi
  80282d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802831:	89 44 24 08          	mov    %eax,0x8(%esp)
  802835:	89 cd                	mov    %ecx,%ebp
  802837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80283b:	75 33                	jne    802870 <__udivdi3+0x60>
  80283d:	39 f1                	cmp    %esi,%ecx
  80283f:	77 57                	ja     802898 <__udivdi3+0x88>
  802841:	85 c9                	test   %ecx,%ecx
  802843:	75 0b                	jne    802850 <__udivdi3+0x40>
  802845:	b8 01 00 00 00       	mov    $0x1,%eax
  80284a:	31 d2                	xor    %edx,%edx
  80284c:	f7 f1                	div    %ecx
  80284e:	89 c1                	mov    %eax,%ecx
  802850:	89 f0                	mov    %esi,%eax
  802852:	31 d2                	xor    %edx,%edx
  802854:	f7 f1                	div    %ecx
  802856:	89 c6                	mov    %eax,%esi
  802858:	8b 44 24 04          	mov    0x4(%esp),%eax
  80285c:	f7 f1                	div    %ecx
  80285e:	89 f2                	mov    %esi,%edx
  802860:	8b 74 24 10          	mov    0x10(%esp),%esi
  802864:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802868:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80286c:	83 c4 1c             	add    $0x1c,%esp
  80286f:	c3                   	ret    
  802870:	31 d2                	xor    %edx,%edx
  802872:	31 c0                	xor    %eax,%eax
  802874:	39 f7                	cmp    %esi,%edi
  802876:	77 e8                	ja     802860 <__udivdi3+0x50>
  802878:	0f bd cf             	bsr    %edi,%ecx
  80287b:	83 f1 1f             	xor    $0x1f,%ecx
  80287e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802882:	75 2c                	jne    8028b0 <__udivdi3+0xa0>
  802884:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802888:	76 04                	jbe    80288e <__udivdi3+0x7e>
  80288a:	39 f7                	cmp    %esi,%edi
  80288c:	73 d2                	jae    802860 <__udivdi3+0x50>
  80288e:	31 d2                	xor    %edx,%edx
  802890:	b8 01 00 00 00       	mov    $0x1,%eax
  802895:	eb c9                	jmp    802860 <__udivdi3+0x50>
  802897:	90                   	nop
  802898:	89 f2                	mov    %esi,%edx
  80289a:	f7 f1                	div    %ecx
  80289c:	31 d2                	xor    %edx,%edx
  80289e:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028a2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028a6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028aa:	83 c4 1c             	add    $0x1c,%esp
  8028ad:	c3                   	ret    
  8028ae:	66 90                	xchg   %ax,%ax
  8028b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028b5:	b8 20 00 00 00       	mov    $0x20,%eax
  8028ba:	89 ea                	mov    %ebp,%edx
  8028bc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028c0:	d3 e7                	shl    %cl,%edi
  8028c2:	89 c1                	mov    %eax,%ecx
  8028c4:	d3 ea                	shr    %cl,%edx
  8028c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028cb:	09 fa                	or     %edi,%edx
  8028cd:	89 f7                	mov    %esi,%edi
  8028cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8028d3:	89 f2                	mov    %esi,%edx
  8028d5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028d9:	d3 e5                	shl    %cl,%ebp
  8028db:	89 c1                	mov    %eax,%ecx
  8028dd:	d3 ef                	shr    %cl,%edi
  8028df:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028e4:	d3 e2                	shl    %cl,%edx
  8028e6:	89 c1                	mov    %eax,%ecx
  8028e8:	d3 ee                	shr    %cl,%esi
  8028ea:	09 d6                	or     %edx,%esi
  8028ec:	89 fa                	mov    %edi,%edx
  8028ee:	89 f0                	mov    %esi,%eax
  8028f0:	f7 74 24 0c          	divl   0xc(%esp)
  8028f4:	89 d7                	mov    %edx,%edi
  8028f6:	89 c6                	mov    %eax,%esi
  8028f8:	f7 e5                	mul    %ebp
  8028fa:	39 d7                	cmp    %edx,%edi
  8028fc:	72 22                	jb     802920 <__udivdi3+0x110>
  8028fe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802902:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802907:	d3 e5                	shl    %cl,%ebp
  802909:	39 c5                	cmp    %eax,%ebp
  80290b:	73 04                	jae    802911 <__udivdi3+0x101>
  80290d:	39 d7                	cmp    %edx,%edi
  80290f:	74 0f                	je     802920 <__udivdi3+0x110>
  802911:	89 f0                	mov    %esi,%eax
  802913:	31 d2                	xor    %edx,%edx
  802915:	e9 46 ff ff ff       	jmp    802860 <__udivdi3+0x50>
  80291a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802920:	8d 46 ff             	lea    -0x1(%esi),%eax
  802923:	31 d2                	xor    %edx,%edx
  802925:	8b 74 24 10          	mov    0x10(%esp),%esi
  802929:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80292d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802931:	83 c4 1c             	add    $0x1c,%esp
  802934:	c3                   	ret    
	...

00802940 <__umoddi3>:
  802940:	83 ec 1c             	sub    $0x1c,%esp
  802943:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802947:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80294b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80294f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802953:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802957:	8b 74 24 24          	mov    0x24(%esp),%esi
  80295b:	85 ed                	test   %ebp,%ebp
  80295d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802961:	89 44 24 08          	mov    %eax,0x8(%esp)
  802965:	89 cf                	mov    %ecx,%edi
  802967:	89 04 24             	mov    %eax,(%esp)
  80296a:	89 f2                	mov    %esi,%edx
  80296c:	75 1a                	jne    802988 <__umoddi3+0x48>
  80296e:	39 f1                	cmp    %esi,%ecx
  802970:	76 4e                	jbe    8029c0 <__umoddi3+0x80>
  802972:	f7 f1                	div    %ecx
  802974:	89 d0                	mov    %edx,%eax
  802976:	31 d2                	xor    %edx,%edx
  802978:	8b 74 24 10          	mov    0x10(%esp),%esi
  80297c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802980:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802984:	83 c4 1c             	add    $0x1c,%esp
  802987:	c3                   	ret    
  802988:	39 f5                	cmp    %esi,%ebp
  80298a:	77 54                	ja     8029e0 <__umoddi3+0xa0>
  80298c:	0f bd c5             	bsr    %ebp,%eax
  80298f:	83 f0 1f             	xor    $0x1f,%eax
  802992:	89 44 24 04          	mov    %eax,0x4(%esp)
  802996:	75 60                	jne    8029f8 <__umoddi3+0xb8>
  802998:	3b 0c 24             	cmp    (%esp),%ecx
  80299b:	0f 87 07 01 00 00    	ja     802aa8 <__umoddi3+0x168>
  8029a1:	89 f2                	mov    %esi,%edx
  8029a3:	8b 34 24             	mov    (%esp),%esi
  8029a6:	29 ce                	sub    %ecx,%esi
  8029a8:	19 ea                	sbb    %ebp,%edx
  8029aa:	89 34 24             	mov    %esi,(%esp)
  8029ad:	8b 04 24             	mov    (%esp),%eax
  8029b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029bc:	83 c4 1c             	add    $0x1c,%esp
  8029bf:	c3                   	ret    
  8029c0:	85 c9                	test   %ecx,%ecx
  8029c2:	75 0b                	jne    8029cf <__umoddi3+0x8f>
  8029c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8029c9:	31 d2                	xor    %edx,%edx
  8029cb:	f7 f1                	div    %ecx
  8029cd:	89 c1                	mov    %eax,%ecx
  8029cf:	89 f0                	mov    %esi,%eax
  8029d1:	31 d2                	xor    %edx,%edx
  8029d3:	f7 f1                	div    %ecx
  8029d5:	8b 04 24             	mov    (%esp),%eax
  8029d8:	f7 f1                	div    %ecx
  8029da:	eb 98                	jmp    802974 <__umoddi3+0x34>
  8029dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029e0:	89 f2                	mov    %esi,%edx
  8029e2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029e6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029ea:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029ee:	83 c4 1c             	add    $0x1c,%esp
  8029f1:	c3                   	ret    
  8029f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029f8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029fd:	89 e8                	mov    %ebp,%eax
  8029ff:	bd 20 00 00 00       	mov    $0x20,%ebp
  802a04:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802a08:	89 fa                	mov    %edi,%edx
  802a0a:	d3 e0                	shl    %cl,%eax
  802a0c:	89 e9                	mov    %ebp,%ecx
  802a0e:	d3 ea                	shr    %cl,%edx
  802a10:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a15:	09 c2                	or     %eax,%edx
  802a17:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a1b:	89 14 24             	mov    %edx,(%esp)
  802a1e:	89 f2                	mov    %esi,%edx
  802a20:	d3 e7                	shl    %cl,%edi
  802a22:	89 e9                	mov    %ebp,%ecx
  802a24:	d3 ea                	shr    %cl,%edx
  802a26:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a2f:	d3 e6                	shl    %cl,%esi
  802a31:	89 e9                	mov    %ebp,%ecx
  802a33:	d3 e8                	shr    %cl,%eax
  802a35:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a3a:	09 f0                	or     %esi,%eax
  802a3c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802a40:	f7 34 24             	divl   (%esp)
  802a43:	d3 e6                	shl    %cl,%esi
  802a45:	89 74 24 08          	mov    %esi,0x8(%esp)
  802a49:	89 d6                	mov    %edx,%esi
  802a4b:	f7 e7                	mul    %edi
  802a4d:	39 d6                	cmp    %edx,%esi
  802a4f:	89 c1                	mov    %eax,%ecx
  802a51:	89 d7                	mov    %edx,%edi
  802a53:	72 3f                	jb     802a94 <__umoddi3+0x154>
  802a55:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a59:	72 35                	jb     802a90 <__umoddi3+0x150>
  802a5b:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a5f:	29 c8                	sub    %ecx,%eax
  802a61:	19 fe                	sbb    %edi,%esi
  802a63:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a68:	89 f2                	mov    %esi,%edx
  802a6a:	d3 e8                	shr    %cl,%eax
  802a6c:	89 e9                	mov    %ebp,%ecx
  802a6e:	d3 e2                	shl    %cl,%edx
  802a70:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a75:	09 d0                	or     %edx,%eax
  802a77:	89 f2                	mov    %esi,%edx
  802a79:	d3 ea                	shr    %cl,%edx
  802a7b:	8b 74 24 10          	mov    0x10(%esp),%esi
  802a7f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802a83:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802a87:	83 c4 1c             	add    $0x1c,%esp
  802a8a:	c3                   	ret    
  802a8b:	90                   	nop
  802a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a90:	39 d6                	cmp    %edx,%esi
  802a92:	75 c7                	jne    802a5b <__umoddi3+0x11b>
  802a94:	89 d7                	mov    %edx,%edi
  802a96:	89 c1                	mov    %eax,%ecx
  802a98:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  802a9c:	1b 3c 24             	sbb    (%esp),%edi
  802a9f:	eb ba                	jmp    802a5b <__umoddi3+0x11b>
  802aa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802aa8:	39 f5                	cmp    %esi,%ebp
  802aaa:	0f 82 f1 fe ff ff    	jb     8029a1 <__umoddi3+0x61>
  802ab0:	e9 f8 fe ff ff       	jmp    8029ad <__umoddi3+0x6d>
