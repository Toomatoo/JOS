
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80004a:	e8 1c 0a 00 00       	call   800a6b <strcpy>
	exit();
  80004f:	e8 b4 01 00 00       	call   800208 <exit>
}
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	53                   	push   %ebx
  80005a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800061:	74 05                	je     800068 <umain+0x12>
		childofspawn();
  800063:	e8 cc ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800068:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800077:	a0 
  800078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007f:	e8 e8 0e 00 00       	call   800f6c <sys_page_alloc>
  800084:	85 c0                	test   %eax,%eax
  800086:	79 20                	jns    8000a8 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008c:	c7 44 24 08 4c 30 80 	movl   $0x80304c,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 5f 30 80 00 	movl   $0x80305f,(%esp)
  8000a3:	e8 7c 01 00 00       	call   800224 <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a8:	e8 da 12 00 00       	call   801387 <fork>
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	79 20                	jns    8000d3 <umain+0x7d>
		panic("fork: %e", r);
  8000b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b7:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 5f 30 80 00 	movl   $0x80305f,(%esp)
  8000ce:	e8 51 01 00 00       	call   800224 <_panic>
	if (r == 0) {
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 1a                	jne    8000f1 <umain+0x9b>
		strcpy(VA, msg);
  8000d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e7:	e8 7f 09 00 00       	call   800a6b <strcpy>
		exit();
  8000ec:	e8 17 01 00 00       	call   800208 <exit>
	}
	wait(r);
  8000f1:	89 1c 24             	mov    %ebx,(%esp)
  8000f4:	e8 5b 28 00 00       	call   802954 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800109:	e8 1d 0a 00 00       	call   800b2b <strcmp>
  80010e:	85 c0                	test   %eax,%eax
  800110:	b8 40 30 80 00       	mov    $0x803040,%eax
  800115:	ba 46 30 80 00       	mov    $0x803046,%edx
  80011a:	0f 45 c2             	cmovne %edx,%eax
  80011d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800121:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800128:	e8 f2 01 00 00       	call   80031f <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800134:	00 
  800135:	c7 44 24 08 97 30 80 	movl   $0x803097,0x8(%esp)
  80013c:	00 
  80013d:	c7 44 24 04 9c 30 80 	movl   $0x80309c,0x4(%esp)
  800144:	00 
  800145:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
  80014c:	e8 93 23 00 00       	call   8024e4 <spawnl>
  800151:	85 c0                	test   %eax,%eax
  800153:	79 20                	jns    800175 <umain+0x11f>
		panic("spawn: %e", r);
  800155:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800159:	c7 44 24 08 a9 30 80 	movl   $0x8030a9,0x8(%esp)
  800160:	00 
  800161:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800168:	00 
  800169:	c7 04 24 5f 30 80 00 	movl   $0x80305f,(%esp)
  800170:	e8 af 00 00 00       	call   800224 <_panic>
	wait(r);
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 d7 27 00 00       	call   802954 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017d:	a1 00 40 80 00       	mov    0x804000,%eax
  800182:	89 44 24 04          	mov    %eax,0x4(%esp)
  800186:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018d:	e8 99 09 00 00       	call   800b2b <strcmp>
  800192:	85 c0                	test   %eax,%eax
  800194:	b8 40 30 80 00       	mov    $0x803040,%eax
  800199:	ba 46 30 80 00       	mov    $0x803046,%edx
  80019e:	0f 45 c2             	cmovne %edx,%eax
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	c7 04 24 b3 30 80 00 	movl   $0x8030b3,(%esp)
  8001ac:	e8 6e 01 00 00       	call   80031f <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001b1:	cc                   	int3   

	breakpoint();
}
  8001b2:	83 c4 14             	add    $0x14,%esp
  8001b5:	5b                   	pop    %ebx
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
  8001be:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001c1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ca:	e8 3d 0d 00 00       	call   800f0c <sys_getenvid>
  8001cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d4:	c1 e0 07             	shl    $0x7,%eax
  8001d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001dc:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e1:	85 f6                	test   %esi,%esi
  8001e3:	7e 07                	jle    8001ec <libmain+0x34>
		binaryname = argv[0];
  8001e5:	8b 03                	mov    (%ebx),%eax
  8001e7:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f0:	89 34 24             	mov    %esi,(%esp)
  8001f3:	e8 5e fe ff ff       	call   800056 <umain>

	// exit gracefully
	exit();
  8001f8:	e8 0b 00 00 00       	call   800208 <exit>
}
  8001fd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800200:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800203:	89 ec                	mov    %ebp,%esp
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    
	...

00800208 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80020e:	e8 7b 16 00 00       	call   80188e <close_all>
	sys_env_destroy(0);
  800213:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021a:	e8 90 0c 00 00       	call   800eaf <sys_env_destroy>
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    
  800221:	00 00                	add    %al,(%eax)
	...

00800224 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80022c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022f:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  800235:	e8 d2 0c 00 00       	call   800f0c <sys_getenvid>
  80023a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800248:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	c7 04 24 f8 30 80 00 	movl   $0x8030f8,(%esp)
  800257:	e8 c3 00 00 00       	call   80031f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 53 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026b:	c7 04 24 7f 34 80 00 	movl   $0x80347f,(%esp)
  800272:	e8 a8 00 00 00       	call   80031f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800277:	cc                   	int3   
  800278:	eb fd                	jmp    800277 <_panic+0x53>
	...

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 14             	sub    $0x14,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 03                	mov    (%ebx),%eax
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 19                	jne    8002b4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80029b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a2:	00 
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	89 04 24             	mov    %eax,(%esp)
  8002a9:	e8 a2 0b 00 00       	call   800e50 <sys_cputs>
		b->idx = 0;
  8002ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b8:	83 c4 14             	add    $0x14,%esp
  8002bb:	5b                   	pop    %ebx
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f3:	c7 04 24 7c 02 80 00 	movl   $0x80027c,(%esp)
  8002fa:	e8 97 01 00 00       	call   800496 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ff:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800305:	89 44 24 04          	mov    %eax,0x4(%esp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	89 04 24             	mov    %eax,(%esp)
  800312:	e8 39 0b 00 00       	call   800e50 <sys_cputs>

	return b.cnt;
}
  800317:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031d:	c9                   	leave  
  80031e:	c3                   	ret    

0080031f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800325:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	e8 87 ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800337:	c9                   	leave  
  800338:	c3                   	ret    
  800339:	00 00                	add    %al,(%eax)
	...

0080033c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 3c             	sub    $0x3c,%esp
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	89 d7                	mov    %edx,%edi
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800350:	8b 45 0c             	mov    0xc(%ebp),%eax
  800353:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800356:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800359:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80035c:	b8 00 00 00 00       	mov    $0x0,%eax
  800361:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800364:	72 11                	jb     800377 <printnum+0x3b>
  800366:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800369:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036c:	76 09                	jbe    800377 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036e:	83 eb 01             	sub    $0x1,%ebx
  800371:	85 db                	test   %ebx,%ebx
  800373:	7f 51                	jg     8003c6 <printnum+0x8a>
  800375:	eb 5e                	jmp    8003d5 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800377:	89 74 24 10          	mov    %esi,0x10(%esp)
  80037b:	83 eb 01             	sub    $0x1,%ebx
  80037e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800382:	8b 45 10             	mov    0x10(%ebp),%eax
  800385:	89 44 24 08          	mov    %eax,0x8(%esp)
  800389:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80038d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800391:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800398:	00 
  800399:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a6:	e8 d5 29 00 00       	call   802d80 <__udivdi3>
  8003ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003af:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ba:	89 fa                	mov    %edi,%edx
  8003bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003bf:	e8 78 ff ff ff       	call   80033c <printnum>
  8003c4:	eb 0f                	jmp    8003d5 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ca:	89 34 24             	mov    %esi,(%esp)
  8003cd:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d0:	83 eb 01             	sub    $0x1,%ebx
  8003d3:	75 f1                	jne    8003c6 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003eb:	00 
  8003ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f9:	e8 b2 2a 00 00       	call   802eb0 <__umoddi3>
  8003fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800402:	0f be 80 1b 31 80 00 	movsbl 0x80311b(%eax),%eax
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80040f:	83 c4 3c             	add    $0x3c,%esp
  800412:	5b                   	pop    %ebx
  800413:	5e                   	pop    %esi
  800414:	5f                   	pop    %edi
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80041a:	83 fa 01             	cmp    $0x1,%edx
  80041d:	7e 0e                	jle    80042d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80041f:	8b 10                	mov    (%eax),%edx
  800421:	8d 4a 08             	lea    0x8(%edx),%ecx
  800424:	89 08                	mov    %ecx,(%eax)
  800426:	8b 02                	mov    (%edx),%eax
  800428:	8b 52 04             	mov    0x4(%edx),%edx
  80042b:	eb 22                	jmp    80044f <getuint+0x38>
	else if (lflag)
  80042d:	85 d2                	test   %edx,%edx
  80042f:	74 10                	je     800441 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800431:	8b 10                	mov    (%eax),%edx
  800433:	8d 4a 04             	lea    0x4(%edx),%ecx
  800436:	89 08                	mov    %ecx,(%eax)
  800438:	8b 02                	mov    (%edx),%eax
  80043a:	ba 00 00 00 00       	mov    $0x0,%edx
  80043f:	eb 0e                	jmp    80044f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800441:	8b 10                	mov    (%eax),%edx
  800443:	8d 4a 04             	lea    0x4(%edx),%ecx
  800446:	89 08                	mov    %ecx,(%eax)
  800448:	8b 02                	mov    (%edx),%eax
  80044a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800457:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80045b:	8b 10                	mov    (%eax),%edx
  80045d:	3b 50 04             	cmp    0x4(%eax),%edx
  800460:	73 0a                	jae    80046c <sprintputch+0x1b>
		*b->buf++ = ch;
  800462:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800465:	88 0a                	mov    %cl,(%edx)
  800467:	83 c2 01             	add    $0x1,%edx
  80046a:	89 10                	mov    %edx,(%eax)
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800474:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800477:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047b:	8b 45 10             	mov    0x10(%ebp),%eax
  80047e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800482:	8b 45 0c             	mov    0xc(%ebp),%eax
  800485:	89 44 24 04          	mov    %eax,0x4(%esp)
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  80048c:	89 04 24             	mov    %eax,(%esp)
  80048f:	e8 02 00 00 00       	call   800496 <vprintfmt>
	va_end(ap);
}
  800494:	c9                   	leave  
  800495:	c3                   	ret    

00800496 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	57                   	push   %edi
  80049a:	56                   	push   %esi
  80049b:	53                   	push   %ebx
  80049c:	83 ec 5c             	sub    $0x5c,%esp
  80049f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004a5:	eb 12                	jmp    8004b9 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	0f 84 e4 04 00 00    	je     800993 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8004af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b3:	89 04 24             	mov    %eax,(%esp)
  8004b6:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b9:	0f b6 06             	movzbl (%esi),%eax
  8004bc:	83 c6 01             	add    $0x1,%esi
  8004bf:	83 f8 25             	cmp    $0x25,%eax
  8004c2:	75 e3                	jne    8004a7 <vprintfmt+0x11>
  8004c4:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8004c8:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8004cf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004d4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e0:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004e3:	eb 2b                	jmp    800510 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e8:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8004ec:	eb 22                	jmp    800510 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f1:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8004f5:	eb 19                	jmp    800510 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004fa:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800501:	eb 0d                	jmp    800510 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800503:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800506:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800509:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	0f b6 06             	movzbl (%esi),%eax
  800513:	0f b6 d0             	movzbl %al,%edx
  800516:	8d 7e 01             	lea    0x1(%esi),%edi
  800519:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051c:	83 e8 23             	sub    $0x23,%eax
  80051f:	3c 55                	cmp    $0x55,%al
  800521:	0f 87 46 04 00 00    	ja     80096d <vprintfmt+0x4d7>
  800527:	0f b6 c0             	movzbl %al,%eax
  80052a:	ff 24 85 80 32 80 00 	jmp    *0x803280(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800531:	83 ea 30             	sub    $0x30,%edx
  800534:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800537:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80053b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800541:	83 fa 09             	cmp    $0x9,%edx
  800544:	77 4a                	ja     800590 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800549:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80054c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80054f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800553:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800556:	8d 50 d0             	lea    -0x30(%eax),%edx
  800559:	83 fa 09             	cmp    $0x9,%edx
  80055c:	76 eb                	jbe    800549 <vprintfmt+0xb3>
  80055e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800561:	eb 2d                	jmp    800590 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 50 04             	lea    0x4(%eax),%edx
  800569:	89 55 14             	mov    %edx,0x14(%ebp)
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800574:	eb 1a                	jmp    800590 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800579:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80057d:	79 91                	jns    800510 <vprintfmt+0x7a>
  80057f:	e9 73 ff ff ff       	jmp    8004f7 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800587:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80058e:	eb 80                	jmp    800510 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800590:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800594:	0f 89 76 ff ff ff    	jns    800510 <vprintfmt+0x7a>
  80059a:	e9 64 ff ff ff       	jmp    800503 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80059f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a5:	e9 66 ff ff ff       	jmp    800510 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c2:	e9 f2 fe ff ff       	jmp    8004b9 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8005c7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8005cb:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8005ce:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8005d2:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8005d5:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8005d9:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8005dc:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8005df:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8005e3:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005e6:	80 f9 09             	cmp    $0x9,%cl
  8005e9:	77 1d                	ja     800608 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8005eb:	0f be c0             	movsbl %al,%eax
  8005ee:	6b c0 64             	imul   $0x64,%eax,%eax
  8005f1:	0f be d2             	movsbl %dl,%edx
  8005f4:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005f7:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8005fe:	a3 0c 40 80 00       	mov    %eax,0x80400c
  800603:	e9 b1 fe ff ff       	jmp    8004b9 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800608:	c7 44 24 04 33 31 80 	movl   $0x803133,0x4(%esp)
  80060f:	00 
  800610:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	e8 10 05 00 00       	call   800b2b <strcmp>
  80061b:	85 c0                	test   %eax,%eax
  80061d:	75 0f                	jne    80062e <vprintfmt+0x198>
  80061f:	c7 05 0c 40 80 00 04 	movl   $0x4,0x80400c
  800626:	00 00 00 
  800629:	e9 8b fe ff ff       	jmp    8004b9 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80062e:	c7 44 24 04 37 31 80 	movl   $0x803137,0x4(%esp)
  800635:	00 
  800636:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800639:	89 14 24             	mov    %edx,(%esp)
  80063c:	e8 ea 04 00 00       	call   800b2b <strcmp>
  800641:	85 c0                	test   %eax,%eax
  800643:	75 0f                	jne    800654 <vprintfmt+0x1be>
  800645:	c7 05 0c 40 80 00 02 	movl   $0x2,0x80400c
  80064c:	00 00 00 
  80064f:	e9 65 fe ff ff       	jmp    8004b9 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800654:	c7 44 24 04 3b 31 80 	movl   $0x80313b,0x4(%esp)
  80065b:	00 
  80065c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80065f:	89 0c 24             	mov    %ecx,(%esp)
  800662:	e8 c4 04 00 00       	call   800b2b <strcmp>
  800667:	85 c0                	test   %eax,%eax
  800669:	75 0f                	jne    80067a <vprintfmt+0x1e4>
  80066b:	c7 05 0c 40 80 00 01 	movl   $0x1,0x80400c
  800672:	00 00 00 
  800675:	e9 3f fe ff ff       	jmp    8004b9 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80067a:	c7 44 24 04 3f 31 80 	movl   $0x80313f,0x4(%esp)
  800681:	00 
  800682:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800685:	89 3c 24             	mov    %edi,(%esp)
  800688:	e8 9e 04 00 00       	call   800b2b <strcmp>
  80068d:	85 c0                	test   %eax,%eax
  80068f:	75 0f                	jne    8006a0 <vprintfmt+0x20a>
  800691:	c7 05 0c 40 80 00 06 	movl   $0x6,0x80400c
  800698:	00 00 00 
  80069b:	e9 19 fe ff ff       	jmp    8004b9 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8006a0:	c7 44 24 04 43 31 80 	movl   $0x803143,0x4(%esp)
  8006a7:	00 
  8006a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	e8 78 04 00 00       	call   800b2b <strcmp>
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	75 0f                	jne    8006c6 <vprintfmt+0x230>
  8006b7:	c7 05 0c 40 80 00 07 	movl   $0x7,0x80400c
  8006be:	00 00 00 
  8006c1:	e9 f3 fd ff ff       	jmp    8004b9 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8006c6:	c7 44 24 04 47 31 80 	movl   $0x803147,0x4(%esp)
  8006cd:	00 
  8006ce:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006d1:	89 14 24             	mov    %edx,(%esp)
  8006d4:	e8 52 04 00 00       	call   800b2b <strcmp>
  8006d9:	83 f8 01             	cmp    $0x1,%eax
  8006dc:	19 c0                	sbb    %eax,%eax
  8006de:	f7 d0                	not    %eax
  8006e0:	83 c0 08             	add    $0x8,%eax
  8006e3:	a3 0c 40 80 00       	mov    %eax,0x80400c
  8006e8:	e9 cc fd ff ff       	jmp    8004b9 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 50 04             	lea    0x4(%eax),%edx
  8006f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f6:	8b 00                	mov    (%eax),%eax
  8006f8:	89 c2                	mov    %eax,%edx
  8006fa:	c1 fa 1f             	sar    $0x1f,%edx
  8006fd:	31 d0                	xor    %edx,%eax
  8006ff:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800701:	83 f8 0f             	cmp    $0xf,%eax
  800704:	7f 0b                	jg     800711 <vprintfmt+0x27b>
  800706:	8b 14 85 e0 33 80 00 	mov    0x8033e0(,%eax,4),%edx
  80070d:	85 d2                	test   %edx,%edx
  80070f:	75 23                	jne    800734 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800711:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800715:	c7 44 24 08 4b 31 80 	movl   $0x80314b,0x8(%esp)
  80071c:	00 
  80071d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800721:	8b 7d 08             	mov    0x8(%ebp),%edi
  800724:	89 3c 24             	mov    %edi,(%esp)
  800727:	e8 42 fd ff ff       	call   80046e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80072f:	e9 85 fd ff ff       	jmp    8004b9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800734:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800738:	c7 44 24 08 a1 36 80 	movl   $0x8036a1,0x8(%esp)
  80073f:	00 
  800740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800744:	8b 7d 08             	mov    0x8(%ebp),%edi
  800747:	89 3c 24             	mov    %edi,(%esp)
  80074a:	e8 1f fd ff ff       	call   80046e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800752:	e9 62 fd ff ff       	jmp    8004b9 <vprintfmt+0x23>
  800757:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80075a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80075d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)
  800769:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80076b:	85 f6                	test   %esi,%esi
  80076d:	b8 2c 31 80 00       	mov    $0x80312c,%eax
  800772:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800775:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800779:	7e 06                	jle    800781 <vprintfmt+0x2eb>
  80077b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80077f:	75 13                	jne    800794 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800781:	0f be 06             	movsbl (%esi),%eax
  800784:	83 c6 01             	add    $0x1,%esi
  800787:	85 c0                	test   %eax,%eax
  800789:	0f 85 94 00 00 00    	jne    800823 <vprintfmt+0x38d>
  80078f:	e9 81 00 00 00       	jmp    800815 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800794:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800798:	89 34 24             	mov    %esi,(%esp)
  80079b:	e8 9b 02 00 00       	call   800a3b <strnlen>
  8007a0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8007a3:	29 c2                	sub    %eax,%edx
  8007a5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007a8:	85 d2                	test   %edx,%edx
  8007aa:	7e d5                	jle    800781 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8007ac:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8007b0:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8007b3:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8007b6:	89 d6                	mov    %edx,%esi
  8007b8:	89 cf                	mov    %ecx,%edi
  8007ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007be:	89 3c 24             	mov    %edi,(%esp)
  8007c1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c4:	83 ee 01             	sub    $0x1,%esi
  8007c7:	75 f1                	jne    8007ba <vprintfmt+0x324>
  8007c9:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8007cc:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8007cf:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8007d2:	eb ad                	jmp    800781 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d4:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8007d8:	74 1b                	je     8007f5 <vprintfmt+0x35f>
  8007da:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007dd:	83 fa 5e             	cmp    $0x5e,%edx
  8007e0:	76 13                	jbe    8007f5 <vprintfmt+0x35f>
					putch('?', putdat);
  8007e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f0:	ff 55 08             	call   *0x8(%ebp)
  8007f3:	eb 0d                	jmp    800802 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8007f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800802:	83 eb 01             	sub    $0x1,%ebx
  800805:	0f be 06             	movsbl (%esi),%eax
  800808:	83 c6 01             	add    $0x1,%esi
  80080b:	85 c0                	test   %eax,%eax
  80080d:	75 1a                	jne    800829 <vprintfmt+0x393>
  80080f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800812:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800815:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800818:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80081c:	7f 1c                	jg     80083a <vprintfmt+0x3a4>
  80081e:	e9 96 fc ff ff       	jmp    8004b9 <vprintfmt+0x23>
  800823:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800826:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800829:	85 ff                	test   %edi,%edi
  80082b:	78 a7                	js     8007d4 <vprintfmt+0x33e>
  80082d:	83 ef 01             	sub    $0x1,%edi
  800830:	79 a2                	jns    8007d4 <vprintfmt+0x33e>
  800832:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800835:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800838:	eb db                	jmp    800815 <vprintfmt+0x37f>
  80083a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083d:	89 de                	mov    %ebx,%esi
  80083f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800842:	89 74 24 04          	mov    %esi,0x4(%esp)
  800846:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80084d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80084f:	83 eb 01             	sub    $0x1,%ebx
  800852:	75 ee                	jne    800842 <vprintfmt+0x3ac>
  800854:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800859:	e9 5b fc ff ff       	jmp    8004b9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80085e:	83 f9 01             	cmp    $0x1,%ecx
  800861:	7e 10                	jle    800873 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 50 08             	lea    0x8(%eax),%edx
  800869:	89 55 14             	mov    %edx,0x14(%ebp)
  80086c:	8b 30                	mov    (%eax),%esi
  80086e:	8b 78 04             	mov    0x4(%eax),%edi
  800871:	eb 26                	jmp    800899 <vprintfmt+0x403>
	else if (lflag)
  800873:	85 c9                	test   %ecx,%ecx
  800875:	74 12                	je     800889 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8d 50 04             	lea    0x4(%eax),%edx
  80087d:	89 55 14             	mov    %edx,0x14(%ebp)
  800880:	8b 30                	mov    (%eax),%esi
  800882:	89 f7                	mov    %esi,%edi
  800884:	c1 ff 1f             	sar    $0x1f,%edi
  800887:	eb 10                	jmp    800899 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8d 50 04             	lea    0x4(%eax),%edx
  80088f:	89 55 14             	mov    %edx,0x14(%ebp)
  800892:	8b 30                	mov    (%eax),%esi
  800894:	89 f7                	mov    %esi,%edi
  800896:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800899:	85 ff                	test   %edi,%edi
  80089b:	78 0e                	js     8008ab <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008a1:	be 0a 00 00 00       	mov    $0xa,%esi
  8008a6:	e9 84 00 00 00       	jmp    80092f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008af:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008b6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008b9:	89 f0                	mov    %esi,%eax
  8008bb:	89 fa                	mov    %edi,%edx
  8008bd:	f7 d8                	neg    %eax
  8008bf:	83 d2 00             	adc    $0x0,%edx
  8008c2:	f7 da                	neg    %edx
			}
			base = 10;
  8008c4:	be 0a 00 00 00       	mov    $0xa,%esi
  8008c9:	eb 64                	jmp    80092f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008cb:	89 ca                	mov    %ecx,%edx
  8008cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d0:	e8 42 fb ff ff       	call   800417 <getuint>
			base = 10;
  8008d5:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008da:	eb 53                	jmp    80092f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008dc:	89 ca                	mov    %ecx,%edx
  8008de:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e1:	e8 31 fb ff ff       	call   800417 <getuint>
    			base = 8;
  8008e6:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8008eb:	eb 42                	jmp    80092f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800906:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800909:	8b 45 14             	mov    0x14(%ebp),%eax
  80090c:	8d 50 04             	lea    0x4(%eax),%edx
  80090f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800912:	8b 00                	mov    (%eax),%eax
  800914:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800919:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80091e:	eb 0f                	jmp    80092f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800920:	89 ca                	mov    %ecx,%edx
  800922:	8d 45 14             	lea    0x14(%ebp),%eax
  800925:	e8 ed fa ff ff       	call   800417 <getuint>
			base = 16;
  80092a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80092f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800933:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800937:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80093a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80093e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800942:	89 04 24             	mov    %eax,(%esp)
  800945:	89 54 24 04          	mov    %edx,0x4(%esp)
  800949:	89 da                	mov    %ebx,%edx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	e8 e9 f9 ff ff       	call   80033c <printnum>
			break;
  800953:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800956:	e9 5e fb ff ff       	jmp    8004b9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80095b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095f:	89 14 24             	mov    %edx,(%esp)
  800962:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800965:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800968:	e9 4c fb ff ff       	jmp    8004b9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800971:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800978:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80097b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80097f:	0f 84 34 fb ff ff    	je     8004b9 <vprintfmt+0x23>
  800985:	83 ee 01             	sub    $0x1,%esi
  800988:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80098c:	75 f7                	jne    800985 <vprintfmt+0x4ef>
  80098e:	e9 26 fb ff ff       	jmp    8004b9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800993:	83 c4 5c             	add    $0x5c,%esp
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	83 ec 28             	sub    $0x28,%esp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009b8:	85 c0                	test   %eax,%eax
  8009ba:	74 30                	je     8009ec <vsnprintf+0x51>
  8009bc:	85 d2                	test   %edx,%edx
  8009be:	7e 2c                	jle    8009ec <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d5:	c7 04 24 51 04 80 00 	movl   $0x800451,(%esp)
  8009dc:	e8 b5 fa ff ff       	call   800496 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ea:	eb 05                	jmp    8009f1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009f9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
  800a03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	89 04 24             	mov    %eax,(%esp)
  800a14:	e8 82 ff ff ff       	call   80099b <vsnprintf>
	va_end(ap);

	return rc;
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    
  800a1b:	00 00                	add    %al,(%eax)
  800a1d:	00 00                	add    %al,(%eax)
	...

00800a20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a2e:	74 09                	je     800a39 <strlen+0x19>
		n++;
  800a30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a37:	75 f7                	jne    800a30 <strlen+0x10>
		n++;
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	85 c9                	test   %ecx,%ecx
  800a4c:	74 1a                	je     800a68 <strnlen+0x2d>
  800a4e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a51:	74 15                	je     800a68 <strnlen+0x2d>
  800a53:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a58:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5a:	39 ca                	cmp    %ecx,%edx
  800a5c:	74 0a                	je     800a68 <strnlen+0x2d>
  800a5e:	83 c2 01             	add    $0x1,%edx
  800a61:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a66:	75 f0                	jne    800a58 <strnlen+0x1d>
		n++;
	return n;
}
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a7e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a81:	83 c2 01             	add    $0x1,%edx
  800a84:	84 c9                	test   %cl,%cl
  800a86:	75 f2                	jne    800a7a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	83 ec 08             	sub    $0x8,%esp
  800a92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a95:	89 1c 24             	mov    %ebx,(%esp)
  800a98:	e8 83 ff ff ff       	call   800a20 <strlen>
	strcpy(dst + len, src);
  800a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa4:	01 d8                	add    %ebx,%eax
  800aa6:	89 04 24             	mov    %eax,(%esp)
  800aa9:	e8 bd ff ff ff       	call   800a6b <strcpy>
	return dst;
}
  800aae:	89 d8                	mov    %ebx,%eax
  800ab0:	83 c4 08             	add    $0x8,%esp
  800ab3:	5b                   	pop    %ebx
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac4:	85 f6                	test   %esi,%esi
  800ac6:	74 18                	je     800ae0 <strncpy+0x2a>
  800ac8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800acd:	0f b6 1a             	movzbl (%edx),%ebx
  800ad0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ad6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	39 f1                	cmp    %esi,%ecx
  800ade:	75 ed                	jne    800acd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  800aea:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af3:	89 f8                	mov    %edi,%eax
  800af5:	85 f6                	test   %esi,%esi
  800af7:	74 2b                	je     800b24 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800af9:	83 fe 01             	cmp    $0x1,%esi
  800afc:	74 23                	je     800b21 <strlcpy+0x3d>
  800afe:	0f b6 0b             	movzbl (%ebx),%ecx
  800b01:	84 c9                	test   %cl,%cl
  800b03:	74 1c                	je     800b21 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b05:	83 ee 02             	sub    $0x2,%esi
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b0d:	88 08                	mov    %cl,(%eax)
  800b0f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b12:	39 f2                	cmp    %esi,%edx
  800b14:	74 0b                	je     800b21 <strlcpy+0x3d>
  800b16:	83 c2 01             	add    $0x1,%edx
  800b19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b1d:	84 c9                	test   %cl,%cl
  800b1f:	75 ec                	jne    800b0d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800b21:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b24:	29 f8                	sub    %edi,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b34:	0f b6 01             	movzbl (%ecx),%eax
  800b37:	84 c0                	test   %al,%al
  800b39:	74 16                	je     800b51 <strcmp+0x26>
  800b3b:	3a 02                	cmp    (%edx),%al
  800b3d:	75 12                	jne    800b51 <strcmp+0x26>
		p++, q++;
  800b3f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b42:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800b46:	84 c0                	test   %al,%al
  800b48:	74 07                	je     800b51 <strcmp+0x26>
  800b4a:	83 c1 01             	add    $0x1,%ecx
  800b4d:	3a 02                	cmp    (%edx),%al
  800b4f:	74 ee                	je     800b3f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b51:	0f b6 c0             	movzbl %al,%eax
  800b54:	0f b6 12             	movzbl (%edx),%edx
  800b57:	29 d0                	sub    %edx,%eax
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	53                   	push   %ebx
  800b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b65:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b6d:	85 d2                	test   %edx,%edx
  800b6f:	74 28                	je     800b99 <strncmp+0x3e>
  800b71:	0f b6 01             	movzbl (%ecx),%eax
  800b74:	84 c0                	test   %al,%al
  800b76:	74 24                	je     800b9c <strncmp+0x41>
  800b78:	3a 03                	cmp    (%ebx),%al
  800b7a:	75 20                	jne    800b9c <strncmp+0x41>
  800b7c:	83 ea 01             	sub    $0x1,%edx
  800b7f:	74 13                	je     800b94 <strncmp+0x39>
		n--, p++, q++;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b87:	0f b6 01             	movzbl (%ecx),%eax
  800b8a:	84 c0                	test   %al,%al
  800b8c:	74 0e                	je     800b9c <strncmp+0x41>
  800b8e:	3a 03                	cmp    (%ebx),%al
  800b90:	74 ea                	je     800b7c <strncmp+0x21>
  800b92:	eb 08                	jmp    800b9c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b9c:	0f b6 01             	movzbl (%ecx),%eax
  800b9f:	0f b6 13             	movzbl (%ebx),%edx
  800ba2:	29 d0                	sub    %edx,%eax
  800ba4:	eb f3                	jmp    800b99 <strncmp+0x3e>

00800ba6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	0f b6 10             	movzbl (%eax),%edx
  800bb3:	84 d2                	test   %dl,%dl
  800bb5:	74 1c                	je     800bd3 <strchr+0x2d>
		if (*s == c)
  800bb7:	38 ca                	cmp    %cl,%dl
  800bb9:	75 09                	jne    800bc4 <strchr+0x1e>
  800bbb:	eb 1b                	jmp    800bd8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bbd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800bc0:	38 ca                	cmp    %cl,%dl
  800bc2:	74 14                	je     800bd8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bc4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	75 f1                	jne    800bbd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	eb 05                	jmp    800bd8 <strchr+0x32>
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be4:	0f b6 10             	movzbl (%eax),%edx
  800be7:	84 d2                	test   %dl,%dl
  800be9:	74 14                	je     800bff <strfind+0x25>
		if (*s == c)
  800beb:	38 ca                	cmp    %cl,%dl
  800bed:	75 06                	jne    800bf5 <strfind+0x1b>
  800bef:	eb 0e                	jmp    800bff <strfind+0x25>
  800bf1:	38 ca                	cmp    %cl,%dl
  800bf3:	74 0a                	je     800bff <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bf5:	83 c0 01             	add    $0x1,%eax
  800bf8:	0f b6 10             	movzbl (%eax),%edx
  800bfb:	84 d2                	test   %dl,%dl
  800bfd:	75 f2                	jne    800bf1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c19:	85 c9                	test   %ecx,%ecx
  800c1b:	74 30                	je     800c4d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c23:	75 25                	jne    800c4a <memset+0x49>
  800c25:	f6 c1 03             	test   $0x3,%cl
  800c28:	75 20                	jne    800c4a <memset+0x49>
		c &= 0xFF;
  800c2a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c2d:	89 d3                	mov    %edx,%ebx
  800c2f:	c1 e3 08             	shl    $0x8,%ebx
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	c1 e6 18             	shl    $0x18,%esi
  800c37:	89 d0                	mov    %edx,%eax
  800c39:	c1 e0 10             	shl    $0x10,%eax
  800c3c:	09 f0                	or     %esi,%eax
  800c3e:	09 d0                	or     %edx,%eax
  800c40:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c42:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c45:	fc                   	cld    
  800c46:	f3 ab                	rep stos %eax,%es:(%edi)
  800c48:	eb 03                	jmp    800c4d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c4a:	fc                   	cld    
  800c4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c4d:	89 f8                	mov    %edi,%eax
  800c4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c58:	89 ec                	mov    %ebp,%esp
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 08             	sub    $0x8,%esp
  800c62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c65:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c71:	39 c6                	cmp    %eax,%esi
  800c73:	73 36                	jae    800cab <memmove+0x4f>
  800c75:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c78:	39 d0                	cmp    %edx,%eax
  800c7a:	73 2f                	jae    800cab <memmove+0x4f>
		s += n;
		d += n;
  800c7c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7f:	f6 c2 03             	test   $0x3,%dl
  800c82:	75 1b                	jne    800c9f <memmove+0x43>
  800c84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c8a:	75 13                	jne    800c9f <memmove+0x43>
  800c8c:	f6 c1 03             	test   $0x3,%cl
  800c8f:	75 0e                	jne    800c9f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c91:	83 ef 04             	sub    $0x4,%edi
  800c94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c9a:	fd                   	std    
  800c9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c9d:	eb 09                	jmp    800ca8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c9f:	83 ef 01             	sub    $0x1,%edi
  800ca2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca5:	fd                   	std    
  800ca6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ca8:	fc                   	cld    
  800ca9:	eb 20                	jmp    800ccb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cb1:	75 13                	jne    800cc6 <memmove+0x6a>
  800cb3:	a8 03                	test   $0x3,%al
  800cb5:	75 0f                	jne    800cc6 <memmove+0x6a>
  800cb7:	f6 c1 03             	test   $0x3,%cl
  800cba:	75 0a                	jne    800cc6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cbc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cbf:	89 c7                	mov    %eax,%edi
  800cc1:	fc                   	cld    
  800cc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc4:	eb 05                	jmp    800ccb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc6:	89 c7                	mov    %eax,%edi
  800cc8:	fc                   	cld    
  800cc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ccb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd1:	89 ec                	mov    %ebp,%esp
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cde:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	89 04 24             	mov    %eax,(%esp)
  800cef:	e8 68 ff ff ff       	call   800c5c <memmove>
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d02:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0a:	85 ff                	test   %edi,%edi
  800d0c:	74 37                	je     800d45 <memcmp+0x4f>
		if (*s1 != *s2)
  800d0e:	0f b6 03             	movzbl (%ebx),%eax
  800d11:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d14:	83 ef 01             	sub    $0x1,%edi
  800d17:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800d1c:	38 c8                	cmp    %cl,%al
  800d1e:	74 1c                	je     800d3c <memcmp+0x46>
  800d20:	eb 10                	jmp    800d32 <memcmp+0x3c>
  800d22:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d27:	83 c2 01             	add    $0x1,%edx
  800d2a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d2e:	38 c8                	cmp    %cl,%al
  800d30:	74 0a                	je     800d3c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800d32:	0f b6 c0             	movzbl %al,%eax
  800d35:	0f b6 c9             	movzbl %cl,%ecx
  800d38:	29 c8                	sub    %ecx,%eax
  800d3a:	eb 09                	jmp    800d45 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3c:	39 fa                	cmp    %edi,%edx
  800d3e:	75 e2                	jne    800d22 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d50:	89 c2                	mov    %eax,%edx
  800d52:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d55:	39 d0                	cmp    %edx,%eax
  800d57:	73 19                	jae    800d72 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d5d:	38 08                	cmp    %cl,(%eax)
  800d5f:	75 06                	jne    800d67 <memfind+0x1d>
  800d61:	eb 0f                	jmp    800d72 <memfind+0x28>
  800d63:	38 08                	cmp    %cl,(%eax)
  800d65:	74 0b                	je     800d72 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d67:	83 c0 01             	add    $0x1,%eax
  800d6a:	39 d0                	cmp    %edx,%eax
  800d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d70:	75 f1                	jne    800d63 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d80:	0f b6 02             	movzbl (%edx),%eax
  800d83:	3c 20                	cmp    $0x20,%al
  800d85:	74 04                	je     800d8b <strtol+0x17>
  800d87:	3c 09                	cmp    $0x9,%al
  800d89:	75 0e                	jne    800d99 <strtol+0x25>
		s++;
  800d8b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8e:	0f b6 02             	movzbl (%edx),%eax
  800d91:	3c 20                	cmp    $0x20,%al
  800d93:	74 f6                	je     800d8b <strtol+0x17>
  800d95:	3c 09                	cmp    $0x9,%al
  800d97:	74 f2                	je     800d8b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d99:	3c 2b                	cmp    $0x2b,%al
  800d9b:	75 0a                	jne    800da7 <strtol+0x33>
		s++;
  800d9d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800da0:	bf 00 00 00 00       	mov    $0x0,%edi
  800da5:	eb 10                	jmp    800db7 <strtol+0x43>
  800da7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dac:	3c 2d                	cmp    $0x2d,%al
  800dae:	75 07                	jne    800db7 <strtol+0x43>
		s++, neg = 1;
  800db0:	83 c2 01             	add    $0x1,%edx
  800db3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db7:	85 db                	test   %ebx,%ebx
  800db9:	0f 94 c0             	sete   %al
  800dbc:	74 05                	je     800dc3 <strtol+0x4f>
  800dbe:	83 fb 10             	cmp    $0x10,%ebx
  800dc1:	75 15                	jne    800dd8 <strtol+0x64>
  800dc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dc6:	75 10                	jne    800dd8 <strtol+0x64>
  800dc8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dcc:	75 0a                	jne    800dd8 <strtol+0x64>
		s += 2, base = 16;
  800dce:	83 c2 02             	add    $0x2,%edx
  800dd1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dd6:	eb 13                	jmp    800deb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800dd8:	84 c0                	test   %al,%al
  800dda:	74 0f                	je     800deb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ddc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de1:	80 3a 30             	cmpb   $0x30,(%edx)
  800de4:	75 05                	jne    800deb <strtol+0x77>
		s++, base = 8;
  800de6:	83 c2 01             	add    $0x1,%edx
  800de9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800deb:	b8 00 00 00 00       	mov    $0x0,%eax
  800df0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df2:	0f b6 0a             	movzbl (%edx),%ecx
  800df5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800df8:	80 fb 09             	cmp    $0x9,%bl
  800dfb:	77 08                	ja     800e05 <strtol+0x91>
			dig = *s - '0';
  800dfd:	0f be c9             	movsbl %cl,%ecx
  800e00:	83 e9 30             	sub    $0x30,%ecx
  800e03:	eb 1e                	jmp    800e23 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800e05:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e08:	80 fb 19             	cmp    $0x19,%bl
  800e0b:	77 08                	ja     800e15 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800e0d:	0f be c9             	movsbl %cl,%ecx
  800e10:	83 e9 57             	sub    $0x57,%ecx
  800e13:	eb 0e                	jmp    800e23 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800e15:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e18:	80 fb 19             	cmp    $0x19,%bl
  800e1b:	77 14                	ja     800e31 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e1d:	0f be c9             	movsbl %cl,%ecx
  800e20:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e23:	39 f1                	cmp    %esi,%ecx
  800e25:	7d 0e                	jge    800e35 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e27:	83 c2 01             	add    $0x1,%edx
  800e2a:	0f af c6             	imul   %esi,%eax
  800e2d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e2f:	eb c1                	jmp    800df2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e31:	89 c1                	mov    %eax,%ecx
  800e33:	eb 02                	jmp    800e37 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e35:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e3b:	74 05                	je     800e42 <strtol+0xce>
		*endptr = (char *) s;
  800e3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e40:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e42:	89 ca                	mov    %ecx,%edx
  800e44:	f7 da                	neg    %edx
  800e46:	85 ff                	test   %edi,%edi
  800e48:	0f 45 c2             	cmovne %edx,%eax
}
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	89 c7                	mov    %eax,%edi
  800e6e:	89 c6                	mov    %eax,%esi
  800e70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e72:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e75:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e78:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7b:	89 ec                	mov    %ebp,%esp
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e88:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	b8 01 00 00 00       	mov    $0x1,%eax
  800e98:	89 d1                	mov    %edx,%ecx
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ea2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eab:	89 ec                	mov    %ebp,%esp
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 38             	sub    $0x38,%esp
  800eb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	89 cb                	mov    %ecx,%ebx
  800ecd:	89 cf                	mov    %ecx,%edi
  800ecf:	89 ce                	mov    %ecx,%esi
  800ed1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  800efa:	e8 25 f3 ff ff       	call   800224 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	b8 02 00 00 00       	mov    $0x2,%eax
  800f25:	89 d1                	mov    %edx,%ecx
  800f27:	89 d3                	mov    %edx,%ebx
  800f29:	89 d7                	mov    %edx,%edi
  800f2b:	89 d6                	mov    %edx,%esi
  800f2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_yield>:

void
sys_yield(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f50:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f55:	89 d1                	mov    %edx,%ecx
  800f57:	89 d3                	mov    %edx,%ebx
  800f59:	89 d7                	mov    %edx,%edi
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 38             	sub    $0x38,%esp
  800f72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	be 00 00 00 00       	mov    $0x0,%esi
  800f80:	b8 04 00 00 00       	mov    $0x4,%eax
  800f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8e:	89 f7                	mov    %esi,%edi
  800f90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f92:	85 c0                	test   %eax,%eax
  800f94:	7e 28                	jle    800fbe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  800fa9:	00 
  800faa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb1:	00 
  800fb2:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  800fb9:	e8 66 f2 ff ff       	call   800224 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc7:	89 ec                	mov    %ebp,%esp
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	83 ec 38             	sub    $0x38,%esp
  800fd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	b8 05 00 00 00       	mov    $0x5,%eax
  800fdf:	8b 75 18             	mov    0x18(%ebp),%esi
  800fe2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	7e 28                	jle    80101c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fff:	00 
  801000:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  801007:	00 
  801008:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100f:	00 
  801010:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  801017:	e8 08 f2 ff ff       	call   800224 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80101c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801022:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801025:	89 ec                	mov    %ebp,%esp
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 38             	sub    $0x38,%esp
  80102f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801032:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801035:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801038:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103d:	b8 06 00 00 00       	mov    $0x6,%eax
  801042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801045:	8b 55 08             	mov    0x8(%ebp),%edx
  801048:	89 df                	mov    %ebx,%edi
  80104a:	89 de                	mov    %ebx,%esi
  80104c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	7e 28                	jle    80107a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801052:	89 44 24 10          	mov    %eax,0x10(%esp)
  801056:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80105d:	00 
  80105e:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  801065:	00 
  801066:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  801075:	e8 aa f1 ff ff       	call   800224 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80107a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801080:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801083:	89 ec                	mov    %ebp,%esp
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 38             	sub    $0x38,%esp
  80108d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801090:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801093:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109b:	b8 08 00 00 00       	mov    $0x8,%eax
  8010a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a6:	89 df                	mov    %ebx,%edi
  8010a8:	89 de                	mov    %ebx,%esi
  8010aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 28                	jle    8010d8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  8010d3:	e8 4c f1 ff ff       	call   800224 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e1:	89 ec                	mov    %ebp,%esp
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 38             	sub    $0x38,%esp
  8010eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f9:	b8 09 00 00 00       	mov    $0x9,%eax
  8010fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801101:	8b 55 08             	mov    0x8(%ebp),%edx
  801104:	89 df                	mov    %ebx,%edi
  801106:	89 de                	mov    %ebx,%esi
  801108:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110a:	85 c0                	test   %eax,%eax
  80110c:	7e 28                	jle    801136 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801112:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801119:	00 
  80111a:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  801121:	00 
  801122:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801129:	00 
  80112a:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  801131:	e8 ee f0 ff ff       	call   800224 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801136:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801139:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113f:	89 ec                	mov    %ebp,%esp
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 38             	sub    $0x38,%esp
  801149:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80114c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80114f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801152:	bb 00 00 00 00       	mov    $0x0,%ebx
  801157:	b8 0a 00 00 00       	mov    $0xa,%eax
  80115c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115f:	8b 55 08             	mov    0x8(%ebp),%edx
  801162:	89 df                	mov    %ebx,%edi
  801164:	89 de                	mov    %ebx,%esi
  801166:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801168:	85 c0                	test   %eax,%eax
  80116a:	7e 28                	jle    801194 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801170:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801177:	00 
  801178:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  80117f:	00 
  801180:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801187:	00 
  801188:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  80118f:	e8 90 f0 ff ff       	call   800224 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801194:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801197:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80119a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80119d:	89 ec                	mov    %ebp,%esp
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011aa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011ad:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b0:	be 00 00 00 00       	mov    $0x0,%esi
  8011b5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d1:	89 ec                	mov    %ebp,%esp
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 38             	sub    $0x38,%esp
  8011db:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011de:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011e1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f1:	89 cb                	mov    %ecx,%ebx
  8011f3:	89 cf                	mov    %ecx,%edi
  8011f5:	89 ce                	mov    %ecx,%esi
  8011f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 3f 34 80 	movl   $0x80343f,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 5c 34 80 00 	movl   $0x80345c,(%esp)
  801220:	e8 ff ef ff ff       	call   800224 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801225:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801228:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80122b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80122e:	89 ec                	mov    %ebp,%esp
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 0c             	sub    $0xc,%esp
  801238:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80123b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80123e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801241:	b9 00 00 00 00       	mov    $0x0,%ecx
  801246:	b8 0e 00 00 00       	mov    $0xe,%eax
  80124b:	8b 55 08             	mov    0x8(%ebp),%edx
  80124e:	89 cb                	mov    %ecx,%ebx
  801250:	89 cf                	mov    %ecx,%edi
  801252:	89 ce                	mov    %ecx,%esi
  801254:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801256:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801259:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80125c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80125f:	89 ec                	mov    %ebp,%esp
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
	...

00801264 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 24             	sub    $0x24,%esp
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80126e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  801270:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801274:	75 1c                	jne    801292 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  801276:	c7 44 24 08 6a 34 80 	movl   $0x80346a,0x8(%esp)
  80127d:	00 
  80127e:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801285:	00 
  801286:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  80128d:	e8 92 ef ff ff       	call   800224 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801292:	89 d8                	mov    %ebx,%eax
  801294:	c1 e8 0c             	shr    $0xc,%eax
  801297:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80129e:	f6 c4 08             	test   $0x8,%ah
  8012a1:	0f 84 be 00 00 00    	je     801365 <pgfault+0x101>
  8012a7:	89 d8                	mov    %ebx,%eax
  8012a9:	c1 e8 16             	shr    $0x16,%eax
  8012ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b3:	a8 01                	test   $0x1,%al
  8012b5:	0f 84 aa 00 00 00    	je     801365 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  8012bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012c2:	00 
  8012c3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012ca:	00 
  8012cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d2:	e8 95 fc ff ff       	call   800f6c <sys_page_alloc>
		if (r < 0)
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	79 20                	jns    8012fb <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  8012db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012df:	c7 44 24 08 a4 34 80 	movl   $0x8034a4,0x8(%esp)
  8012e6:	00 
  8012e7:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8012ee:	00 
  8012ef:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  8012f6:	e8 29 ef ff ff       	call   800224 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  8012fb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801301:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801308:	00 
  801309:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80130d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801314:	e8 bc f9 ff ff       	call   800cd5 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801319:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801320:	00 
  801321:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801325:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80132c:	00 
  80132d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801334:	00 
  801335:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133c:	e8 8a fc ff ff       	call   800fcb <sys_page_map>
		if (r < 0)
  801341:	85 c0                	test   %eax,%eax
  801343:	79 3c                	jns    801381 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  801345:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801349:	c7 44 24 08 cc 34 80 	movl   $0x8034cc,0x8(%esp)
  801350:	00 
  801351:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801358:	00 
  801359:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  801360:	e8 bf ee ff ff       	call   800224 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801365:	c7 44 24 08 f0 34 80 	movl   $0x8034f0,0x8(%esp)
  80136c:	00 
  80136d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801374:	00 
  801375:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  80137c:	e8 a3 ee ff ff       	call   800224 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801381:	83 c4 24             	add    $0x24,%esp
  801384:	5b                   	pop    %ebx
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801390:	c7 04 24 64 12 80 00 	movl   $0x801264,(%esp)
  801397:	e8 d4 17 00 00       	call   802b70 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80139c:	bf 07 00 00 00       	mov    $0x7,%edi
  8013a1:	89 f8                	mov    %edi,%eax
  8013a3:	cd 30                	int    $0x30
  8013a5:	89 c7                	mov    %eax,%edi
  8013a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	79 20                	jns    8013ce <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  8013ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b2:	c7 44 24 08 10 35 80 	movl   $0x803510,0x8(%esp)
  8013b9:	00 
  8013ba:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8013c1:	00 
  8013c2:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  8013c9:	e8 56 ee ff ff       	call   800224 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  8013ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	75 1c                	jne    8013f3 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  8013d7:	e8 30 fb ff ff       	call   800f0c <sys_getenvid>
  8013dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013e1:	c1 e0 07             	shl    $0x7,%eax
  8013e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013e9:	a3 04 50 80 00       	mov    %eax,0x805004
		//cprintf("child fork ok!\n");
		return 0;
  8013ee:	e9 51 02 00 00       	jmp    801644 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  8013f3:	89 d8                	mov    %ebx,%eax
  8013f5:	c1 e8 16             	shr    $0x16,%eax
  8013f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ff:	a8 01                	test   $0x1,%al
  801401:	0f 84 87 01 00 00    	je     80158e <fork+0x207>
  801407:	89 d8                	mov    %ebx,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
  80140c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801413:	f6 c2 01             	test   $0x1,%dl
  801416:	0f 84 72 01 00 00    	je     80158e <fork+0x207>
  80141c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801423:	f6 c2 04             	test   $0x4,%dl
  801426:	0f 84 62 01 00 00    	je     80158e <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80142c:	89 c6                	mov    %eax,%esi
  80142e:	c1 e6 0c             	shl    $0xc,%esi
  801431:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801437:	0f 84 51 01 00 00    	je     80158e <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  80143d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801444:	f6 c6 04             	test   $0x4,%dh
  801447:	74 53                	je     80149c <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801449:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801450:	25 07 0e 00 00       	and    $0xe07,%eax
  801455:	89 44 24 10          	mov    %eax,0x10(%esp)
  801459:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80145d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801460:	89 44 24 08          	mov    %eax,0x8(%esp)
  801464:	89 74 24 04          	mov    %esi,0x4(%esp)
  801468:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146f:	e8 57 fb ff ff       	call   800fcb <sys_page_map>
		if (r < 0)
  801474:	85 c0                	test   %eax,%eax
  801476:	0f 89 12 01 00 00    	jns    80158e <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  80147c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801480:	c7 44 24 08 30 35 80 	movl   $0x803530,0x8(%esp)
  801487:	00 
  801488:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80148f:	00 
  801490:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  801497:	e8 88 ed ff ff       	call   800224 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80149c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a3:	f6 c2 02             	test   $0x2,%dl
  8014a6:	75 10                	jne    8014b8 <fork+0x131>
  8014a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014af:	f6 c4 08             	test   $0x8,%ah
  8014b2:	0f 84 8f 00 00 00    	je     801547 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8014b8:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8014bf:	00 
  8014c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d6:	e8 f0 fa ff ff       	call   800fcb <sys_page_map>
		if (r < 0)
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	79 20                	jns    8014ff <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  8014df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e3:	c7 44 24 08 5c 35 80 	movl   $0x80355c,0x8(%esp)
  8014ea:	00 
  8014eb:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8014f2:	00 
  8014f3:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  8014fa:	e8 25 ed ff ff       	call   800224 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8014ff:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801506:	00 
  801507:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80150b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801512:	00 
  801513:	89 74 24 04          	mov    %esi,0x4(%esp)
  801517:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151e:	e8 a8 fa ff ff       	call   800fcb <sys_page_map>
		if (r < 0)
  801523:	85 c0                	test   %eax,%eax
  801525:	79 67                	jns    80158e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801527:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80152b:	c7 44 24 08 5c 35 80 	movl   $0x80355c,0x8(%esp)
  801532:	00 
  801533:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80153a:	00 
  80153b:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  801542:	e8 dd ec ff ff       	call   800224 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  801547:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80154e:	00 
  80154f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801556:	89 44 24 08          	mov    %eax,0x8(%esp)
  80155a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801565:	e8 61 fa ff ff       	call   800fcb <sys_page_map>
		if (r < 0)
  80156a:	85 c0                	test   %eax,%eax
  80156c:	79 20                	jns    80158e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  80156e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801572:	c7 44 24 08 5c 35 80 	movl   $0x80355c,0x8(%esp)
  801579:	00 
  80157a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801581:	00 
  801582:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  801589:	e8 96 ec ff ff       	call   800224 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  80158e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801594:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80159a:	0f 85 53 fe ff ff    	jne    8013f3 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8015a0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015a7:	00 
  8015a8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015af:	ee 
  8015b0:	89 3c 24             	mov    %edi,(%esp)
  8015b3:	e8 b4 f9 ff ff       	call   800f6c <sys_page_alloc>
	if (res < 0)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	79 20                	jns    8015dc <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  8015bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c0:	c7 44 24 08 80 35 80 	movl   $0x803580,0x8(%esp)
  8015c7:	00 
  8015c8:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8015cf:	00 
  8015d0:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  8015d7:	e8 48 ec ff ff       	call   800224 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  8015dc:	c7 44 24 04 fc 2b 80 	movl   $0x802bfc,0x4(%esp)
  8015e3:	00 
  8015e4:	89 3c 24             	mov    %edi,(%esp)
  8015e7:	e8 57 fb ff ff       	call   801143 <sys_env_set_pgfault_upcall>
	if (res < 0)
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	79 20                	jns    801610 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  8015f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f4:	c7 44 24 08 a4 35 80 	movl   $0x8035a4,0x8(%esp)
  8015fb:	00 
  8015fc:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801603:	00 
  801604:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  80160b:	e8 14 ec ff ff       	call   800224 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801610:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801617:	00 
  801618:	89 3c 24             	mov    %edi,(%esp)
  80161b:	e8 67 fa ff ff       	call   801087 <sys_env_set_status>
	if (res < 0)
  801620:	85 c0                	test   %eax,%eax
  801622:	79 20                	jns    801644 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801624:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801628:	c7 44 24 08 d4 35 80 	movl   $0x8035d4,0x8(%esp)
  80162f:	00 
  801630:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801637:	00 
  801638:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  80163f:	e8 e0 eb ff ff       	call   800224 <_panic>

	return pid;
	//panic("fork not implemented");
}
  801644:	89 f8                	mov    %edi,%eax
  801646:	83 c4 3c             	add    $0x3c,%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <sfork>:

// Challenge!
int
sfork(void)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801654:	c7 44 24 08 8c 34 80 	movl   $0x80348c,0x8(%esp)
  80165b:	00 
  80165c:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801663:	00 
  801664:	c7 04 24 81 34 80 00 	movl   $0x803481,(%esp)
  80166b:	e8 b4 eb ff ff       	call   800224 <_panic>

00801670 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	05 00 00 00 30       	add    $0x30000000,%eax
  80167b:	c1 e8 0c             	shr    $0xc,%eax
}
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	89 04 24             	mov    %eax,(%esp)
  80168c:	e8 df ff ff ff       	call   801670 <fd2num>
  801691:	05 20 00 0d 00       	add    $0xd0020,%eax
  801696:	c1 e0 0c             	shl    $0xc,%eax
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	53                   	push   %ebx
  80169f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016a2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016a7:	a8 01                	test   $0x1,%al
  8016a9:	74 34                	je     8016df <fd_alloc+0x44>
  8016ab:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016b0:	a8 01                	test   $0x1,%al
  8016b2:	74 32                	je     8016e6 <fd_alloc+0x4b>
  8016b4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016b9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	c1 ea 16             	shr    $0x16,%edx
  8016c0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016c7:	f6 c2 01             	test   $0x1,%dl
  8016ca:	74 1f                	je     8016eb <fd_alloc+0x50>
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	c1 ea 0c             	shr    $0xc,%edx
  8016d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016d8:	f6 c2 01             	test   $0x1,%dl
  8016db:	75 17                	jne    8016f4 <fd_alloc+0x59>
  8016dd:	eb 0c                	jmp    8016eb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016df:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8016e4:	eb 05                	jmp    8016eb <fd_alloc+0x50>
  8016e6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8016eb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8016ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f2:	eb 17                	jmp    80170b <fd_alloc+0x70>
  8016f4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016f9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016fe:	75 b9                	jne    8016b9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801700:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801706:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80170b:	5b                   	pop    %ebx
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801719:	83 fa 1f             	cmp    $0x1f,%edx
  80171c:	77 3f                	ja     80175d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80171e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801724:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801727:	89 d0                	mov    %edx,%eax
  801729:	c1 e8 16             	shr    $0x16,%eax
  80172c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801738:	f6 c1 01             	test   $0x1,%cl
  80173b:	74 20                	je     80175d <fd_lookup+0x4f>
  80173d:	89 d0                	mov    %edx,%eax
  80173f:	c1 e8 0c             	shr    $0xc,%eax
  801742:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801749:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80174e:	f6 c1 01             	test   $0x1,%cl
  801751:	74 0a                	je     80175d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801753:	8b 45 0c             	mov    0xc(%ebp),%eax
  801756:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801758:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 14             	sub    $0x14,%esp
  801766:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80176c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801771:	39 0d 10 40 80 00    	cmp    %ecx,0x804010
  801777:	75 17                	jne    801790 <dev_lookup+0x31>
  801779:	eb 07                	jmp    801782 <dev_lookup+0x23>
  80177b:	39 0a                	cmp    %ecx,(%edx)
  80177d:	75 11                	jne    801790 <dev_lookup+0x31>
  80177f:	90                   	nop
  801780:	eb 05                	jmp    801787 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801782:	ba 10 40 80 00       	mov    $0x804010,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801787:	89 13                	mov    %edx,(%ebx)
			return 0;
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
  80178e:	eb 35                	jmp    8017c5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801790:	83 c0 01             	add    $0x1,%eax
  801793:	8b 14 85 78 36 80 00 	mov    0x803678(,%eax,4),%edx
  80179a:	85 d2                	test   %edx,%edx
  80179c:	75 dd                	jne    80177b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80179e:	a1 04 50 80 00       	mov    0x805004,%eax
  8017a3:	8b 40 48             	mov    0x48(%eax),%eax
  8017a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ae:	c7 04 24 fc 35 80 00 	movl   $0x8035fc,(%esp)
  8017b5:	e8 65 eb ff ff       	call   80031f <cprintf>
	*dev = 0;
  8017ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8017c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017c5:	83 c4 14             	add    $0x14,%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	83 ec 38             	sub    $0x38,%esp
  8017d1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017d4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017d7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8017da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017dd:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017e1:	89 3c 24             	mov    %edi,(%esp)
  8017e4:	e8 87 fe ff ff       	call   801670 <fd2num>
  8017e9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8017ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017f0:	89 04 24             	mov    %eax,(%esp)
  8017f3:	e8 16 ff ff ff       	call   80170e <fd_lookup>
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 05                	js     801803 <fd_close+0x38>
	    || fd != fd2)
  8017fe:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801801:	74 0e                	je     801811 <fd_close+0x46>
		return (must_exist ? r : 0);
  801803:	89 f0                	mov    %esi,%eax
  801805:	84 c0                	test   %al,%al
  801807:	b8 00 00 00 00       	mov    $0x0,%eax
  80180c:	0f 44 d8             	cmove  %eax,%ebx
  80180f:	eb 3d                	jmp    80184e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801811:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801814:	89 44 24 04          	mov    %eax,0x4(%esp)
  801818:	8b 07                	mov    (%edi),%eax
  80181a:	89 04 24             	mov    %eax,(%esp)
  80181d:	e8 3d ff ff ff       	call   80175f <dev_lookup>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	85 c0                	test   %eax,%eax
  801826:	78 16                	js     80183e <fd_close+0x73>
		if (dev->dev_close)
  801828:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80182b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80182e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801833:	85 c0                	test   %eax,%eax
  801835:	74 07                	je     80183e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801837:	89 3c 24             	mov    %edi,(%esp)
  80183a:	ff d0                	call   *%eax
  80183c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80183e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801842:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801849:	e8 db f7 ff ff       	call   801029 <sys_page_unmap>
	return r;
}
  80184e:	89 d8                	mov    %ebx,%eax
  801850:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801853:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801856:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801859:	89 ec                	mov    %ebp,%esp
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    

0080185d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801863:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801866:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	89 04 24             	mov    %eax,(%esp)
  801870:	e8 99 fe ff ff       	call   80170e <fd_lookup>
  801875:	85 c0                	test   %eax,%eax
  801877:	78 13                	js     80188c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801879:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801880:	00 
  801881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801884:	89 04 24             	mov    %eax,(%esp)
  801887:	e8 3f ff ff ff       	call   8017cb <fd_close>
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <close_all>:

void
close_all(void)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	53                   	push   %ebx
  801892:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801895:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80189a:	89 1c 24             	mov    %ebx,(%esp)
  80189d:	e8 bb ff ff ff       	call   80185d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018a2:	83 c3 01             	add    $0x1,%ebx
  8018a5:	83 fb 20             	cmp    $0x20,%ebx
  8018a8:	75 f0                	jne    80189a <close_all+0xc>
		close(i);
}
  8018aa:	83 c4 14             	add    $0x14,%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 58             	sub    $0x58,%esp
  8018b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8018b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8018bf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	89 04 24             	mov    %eax,(%esp)
  8018cf:	e8 3a fe ff ff       	call   80170e <fd_lookup>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	0f 88 e1 00 00 00    	js     8019bf <dup+0x10f>
		return r;
	close(newfdnum);
  8018de:	89 3c 24             	mov    %edi,(%esp)
  8018e1:	e8 77 ff ff ff       	call   80185d <close>

	newfd = INDEX2FD(newfdnum);
  8018e6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8018ec:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8018ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 86 fd ff ff       	call   801680 <fd2data>
  8018fa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8018fc:	89 34 24             	mov    %esi,(%esp)
  8018ff:	e8 7c fd ff ff       	call   801680 <fd2data>
  801904:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801907:	89 d8                	mov    %ebx,%eax
  801909:	c1 e8 16             	shr    $0x16,%eax
  80190c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801913:	a8 01                	test   $0x1,%al
  801915:	74 46                	je     80195d <dup+0xad>
  801917:	89 d8                	mov    %ebx,%eax
  801919:	c1 e8 0c             	shr    $0xc,%eax
  80191c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801923:	f6 c2 01             	test   $0x1,%dl
  801926:	74 35                	je     80195d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801928:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80192f:	25 07 0e 00 00       	and    $0xe07,%eax
  801934:	89 44 24 10          	mov    %eax,0x10(%esp)
  801938:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80193b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801946:	00 
  801947:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801952:	e8 74 f6 ff ff       	call   800fcb <sys_page_map>
  801957:	89 c3                	mov    %eax,%ebx
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 3b                	js     801998 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80195d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801960:	89 c2                	mov    %eax,%edx
  801962:	c1 ea 0c             	shr    $0xc,%edx
  801965:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80196c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801972:	89 54 24 10          	mov    %edx,0x10(%esp)
  801976:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80197a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801981:	00 
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198d:	e8 39 f6 ff ff       	call   800fcb <sys_page_map>
  801992:	89 c3                	mov    %eax,%ebx
  801994:	85 c0                	test   %eax,%eax
  801996:	79 25                	jns    8019bd <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801998:	89 74 24 04          	mov    %esi,0x4(%esp)
  80199c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a3:	e8 81 f6 ff ff       	call   801029 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8019a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b6:	e8 6e f6 ff ff       	call   801029 <sys_page_unmap>
	return r;
  8019bb:	eb 02                	jmp    8019bf <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8019bd:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8019bf:	89 d8                	mov    %ebx,%eax
  8019c1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019c4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019c7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019ca:	89 ec                	mov    %ebp,%esp
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 24             	sub    $0x24,%esp
  8019d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019df:	89 1c 24             	mov    %ebx,(%esp)
  8019e2:	e8 27 fd ff ff       	call   80170e <fd_lookup>
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 6d                	js     801a58 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f5:	8b 00                	mov    (%eax),%eax
  8019f7:	89 04 24             	mov    %eax,(%esp)
  8019fa:	e8 60 fd ff ff       	call   80175f <dev_lookup>
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 55                	js     801a58 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a06:	8b 50 08             	mov    0x8(%eax),%edx
  801a09:	83 e2 03             	and    $0x3,%edx
  801a0c:	83 fa 01             	cmp    $0x1,%edx
  801a0f:	75 23                	jne    801a34 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a11:	a1 04 50 80 00       	mov    0x805004,%eax
  801a16:	8b 40 48             	mov    0x48(%eax),%eax
  801a19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 3d 36 80 00 	movl   $0x80363d,(%esp)
  801a28:	e8 f2 e8 ff ff       	call   80031f <cprintf>
		return -E_INVAL;
  801a2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a32:	eb 24                	jmp    801a58 <read+0x8a>
	}
	if (!dev->dev_read)
  801a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a37:	8b 52 08             	mov    0x8(%edx),%edx
  801a3a:	85 d2                	test   %edx,%edx
  801a3c:	74 15                	je     801a53 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801a3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a41:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a48:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a4c:	89 04 24             	mov    %eax,(%esp)
  801a4f:	ff d2                	call   *%edx
  801a51:	eb 05                	jmp    801a58 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a53:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801a58:	83 c4 24             	add    $0x24,%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	57                   	push   %edi
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 1c             	sub    $0x1c,%esp
  801a67:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a6a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a72:	85 f6                	test   %esi,%esi
  801a74:	74 30                	je     801aa6 <readn+0x48>
  801a76:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a7b:	89 f2                	mov    %esi,%edx
  801a7d:	29 c2                	sub    %eax,%edx
  801a7f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a83:	03 45 0c             	add    0xc(%ebp),%eax
  801a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8a:	89 3c 24             	mov    %edi,(%esp)
  801a8d:	e8 3c ff ff ff       	call   8019ce <read>
		if (m < 0)
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 10                	js     801aa6 <readn+0x48>
			return m;
		if (m == 0)
  801a96:	85 c0                	test   %eax,%eax
  801a98:	74 0a                	je     801aa4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a9a:	01 c3                	add    %eax,%ebx
  801a9c:	89 d8                	mov    %ebx,%eax
  801a9e:	39 f3                	cmp    %esi,%ebx
  801aa0:	72 d9                	jb     801a7b <readn+0x1d>
  801aa2:	eb 02                	jmp    801aa6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801aa4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801aa6:	83 c4 1c             	add    $0x1c,%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5f                   	pop    %edi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 24             	sub    $0x24,%esp
  801ab5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ab8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abf:	89 1c 24             	mov    %ebx,(%esp)
  801ac2:	e8 47 fc ff ff       	call   80170e <fd_lookup>
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 68                	js     801b33 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801acb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad5:	8b 00                	mov    (%eax),%eax
  801ad7:	89 04 24             	mov    %eax,(%esp)
  801ada:	e8 80 fc ff ff       	call   80175f <dev_lookup>
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 50                	js     801b33 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801aea:	75 23                	jne    801b0f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801aec:	a1 04 50 80 00       	mov    0x805004,%eax
  801af1:	8b 40 48             	mov    0x48(%eax),%eax
  801af4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801af8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afc:	c7 04 24 59 36 80 00 	movl   $0x803659,(%esp)
  801b03:	e8 17 e8 ff ff       	call   80031f <cprintf>
		return -E_INVAL;
  801b08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b0d:	eb 24                	jmp    801b33 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b12:	8b 52 0c             	mov    0xc(%edx),%edx
  801b15:	85 d2                	test   %edx,%edx
  801b17:	74 15                	je     801b2e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b19:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b1c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b27:	89 04 24             	mov    %eax,(%esp)
  801b2a:	ff d2                	call   *%edx
  801b2c:	eb 05                	jmp    801b33 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b2e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b33:	83 c4 24             	add    $0x24,%esp
  801b36:	5b                   	pop    %ebx
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b3f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
  801b49:	89 04 24             	mov    %eax,(%esp)
  801b4c:	e8 bd fb ff ff       	call   80170e <fd_lookup>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 0e                	js     801b63 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b5b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	53                   	push   %ebx
  801b69:	83 ec 24             	sub    $0x24,%esp
  801b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b76:	89 1c 24             	mov    %ebx,(%esp)
  801b79:	e8 90 fb ff ff       	call   80170e <fd_lookup>
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 61                	js     801be3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8c:	8b 00                	mov    (%eax),%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 c9 fb ff ff       	call   80175f <dev_lookup>
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 49                	js     801be3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ba1:	75 23                	jne    801bc6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ba3:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ba8:	8b 40 48             	mov    0x48(%eax),%eax
  801bab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801baf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb3:	c7 04 24 1c 36 80 00 	movl   $0x80361c,(%esp)
  801bba:	e8 60 e7 ff ff       	call   80031f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bbf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bc4:	eb 1d                	jmp    801be3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801bc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc9:	8b 52 18             	mov    0x18(%edx),%edx
  801bcc:	85 d2                	test   %edx,%edx
  801bce:	74 0e                	je     801bde <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bd7:	89 04 24             	mov    %eax,(%esp)
  801bda:	ff d2                	call   *%edx
  801bdc:	eb 05                	jmp    801be3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801bde:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801be3:	83 c4 24             	add    $0x24,%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	53                   	push   %ebx
  801bed:	83 ec 24             	sub    $0x24,%esp
  801bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bf3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	89 04 24             	mov    %eax,(%esp)
  801c00:	e8 09 fb ff ff       	call   80170e <fd_lookup>
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 52                	js     801c5b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c13:	8b 00                	mov    (%eax),%eax
  801c15:	89 04 24             	mov    %eax,(%esp)
  801c18:	e8 42 fb ff ff       	call   80175f <dev_lookup>
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 3a                	js     801c5b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c24:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c28:	74 2c                	je     801c56 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c2a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c2d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c34:	00 00 00 
	stat->st_isdir = 0;
  801c37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c3e:	00 00 00 
	stat->st_dev = dev;
  801c41:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c4e:	89 14 24             	mov    %edx,(%esp)
  801c51:	ff 50 14             	call   *0x14(%eax)
  801c54:	eb 05                	jmp    801c5b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c56:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c5b:	83 c4 24             	add    $0x24,%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 18             	sub    $0x18,%esp
  801c67:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c6a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c74:	00 
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 bc 01 00 00       	call   801e3c <open>
  801c80:	89 c3                	mov    %eax,%ebx
  801c82:	85 c0                	test   %eax,%eax
  801c84:	78 1b                	js     801ca1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8d:	89 1c 24             	mov    %ebx,(%esp)
  801c90:	e8 54 ff ff ff       	call   801be9 <fstat>
  801c95:	89 c6                	mov    %eax,%esi
	close(fd);
  801c97:	89 1c 24             	mov    %ebx,(%esp)
  801c9a:	e8 be fb ff ff       	call   80185d <close>
	return r;
  801c9f:	89 f3                	mov    %esi,%ebx
}
  801ca1:	89 d8                	mov    %ebx,%eax
  801ca3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ca6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ca9:	89 ec                	mov    %ebp,%esp
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    
  801cad:	00 00                	add    %al,(%eax)
	...

00801cb0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 18             	sub    $0x18,%esp
  801cb6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cb9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cbc:	89 c3                	mov    %eax,%ebx
  801cbe:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cc0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801cc7:	75 11                	jne    801cda <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801cd0:	e8 1c 10 00 00       	call   802cf1 <ipc_find_env>
  801cd5:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cda:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ce1:	00 
  801ce2:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ce9:	00 
  801cea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cee:	a1 00 50 80 00       	mov    0x805000,%eax
  801cf3:	89 04 24             	mov    %eax,(%esp)
  801cf6:	e8 8b 0f 00 00       	call   802c86 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801cfb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d02:	00 
  801d03:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0e:	e8 0d 0f 00 00       	call   802c20 <ipc_recv>
}
  801d13:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d16:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d19:	89 ec                	mov    %ebp,%esp
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	53                   	push   %ebx
  801d21:	83 ec 14             	sub    $0x14,%esp
  801d24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d2d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d32:	ba 00 00 00 00       	mov    $0x0,%edx
  801d37:	b8 05 00 00 00       	mov    $0x5,%eax
  801d3c:	e8 6f ff ff ff       	call   801cb0 <fsipc>
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 2b                	js     801d70 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d45:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d4c:	00 
  801d4d:	89 1c 24             	mov    %ebx,(%esp)
  801d50:	e8 16 ed ff ff       	call   800a6b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d55:	a1 80 60 80 00       	mov    0x806080,%eax
  801d5a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d60:	a1 84 60 80 00       	mov    0x806084,%eax
  801d65:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d70:	83 c4 14             	add    $0x14,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d82:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d87:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8c:	b8 06 00 00 00       	mov    $0x6,%eax
  801d91:	e8 1a ff ff ff       	call   801cb0 <fsipc>
}
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	56                   	push   %esi
  801d9c:	53                   	push   %ebx
  801d9d:	83 ec 10             	sub    $0x10,%esp
  801da0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	8b 40 0c             	mov    0xc(%eax),%eax
  801da9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801dae:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801db4:	ba 00 00 00 00       	mov    $0x0,%edx
  801db9:	b8 03 00 00 00       	mov    $0x3,%eax
  801dbe:	e8 ed fe ff ff       	call   801cb0 <fsipc>
  801dc3:	89 c3                	mov    %eax,%ebx
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 6a                	js     801e33 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801dc9:	39 c6                	cmp    %eax,%esi
  801dcb:	73 24                	jae    801df1 <devfile_read+0x59>
  801dcd:	c7 44 24 0c 88 36 80 	movl   $0x803688,0xc(%esp)
  801dd4:	00 
  801dd5:	c7 44 24 08 8f 36 80 	movl   $0x80368f,0x8(%esp)
  801ddc:	00 
  801ddd:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801de4:	00 
  801de5:	c7 04 24 a4 36 80 00 	movl   $0x8036a4,(%esp)
  801dec:	e8 33 e4 ff ff       	call   800224 <_panic>
	assert(r <= PGSIZE);
  801df1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801df6:	7e 24                	jle    801e1c <devfile_read+0x84>
  801df8:	c7 44 24 0c af 36 80 	movl   $0x8036af,0xc(%esp)
  801dff:	00 
  801e00:	c7 44 24 08 8f 36 80 	movl   $0x80368f,0x8(%esp)
  801e07:	00 
  801e08:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e0f:	00 
  801e10:	c7 04 24 a4 36 80 00 	movl   $0x8036a4,(%esp)
  801e17:	e8 08 e4 ff ff       	call   800224 <_panic>
	memmove(buf, &fsipcbuf, r);
  801e1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e20:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e27:	00 
  801e28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2b:	89 04 24             	mov    %eax,(%esp)
  801e2e:	e8 29 ee ff ff       	call   800c5c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801e33:	89 d8                	mov    %ebx,%eax
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	83 ec 20             	sub    $0x20,%esp
  801e44:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e47:	89 34 24             	mov    %esi,(%esp)
  801e4a:	e8 d1 eb ff ff       	call   800a20 <strlen>
		return -E_BAD_PATH;
  801e4f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e59:	7f 5e                	jg     801eb9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5e:	89 04 24             	mov    %eax,(%esp)
  801e61:	e8 35 f8 ff ff       	call   80169b <fd_alloc>
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 4d                	js     801eb9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e70:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e77:	e8 ef eb ff ff       	call   800a6b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e87:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8c:	e8 1f fe ff ff       	call   801cb0 <fsipc>
  801e91:	89 c3                	mov    %eax,%ebx
  801e93:	85 c0                	test   %eax,%eax
  801e95:	79 15                	jns    801eac <open+0x70>
		fd_close(fd, 0);
  801e97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e9e:	00 
  801e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea2:	89 04 24             	mov    %eax,(%esp)
  801ea5:	e8 21 f9 ff ff       	call   8017cb <fd_close>
		return r;
  801eaa:	eb 0d                	jmp    801eb9 <open+0x7d>
	}

	return fd2num(fd);
  801eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaf:	89 04 24             	mov    %eax,(%esp)
  801eb2:	e8 b9 f7 ff ff       	call   801670 <fd2num>
  801eb7:	89 c3                	mov    %eax,%ebx
}
  801eb9:	89 d8                	mov    %ebx,%eax
  801ebb:	83 c4 20             	add    $0x20,%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5e                   	pop    %esi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    
	...

00801ec4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801ed0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ed7:	00 
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	89 04 24             	mov    %eax,(%esp)
  801ede:	e8 59 ff ff ff       	call   801e3c <open>
  801ee3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	0f 88 c9 05 00 00    	js     8024ba <spawn+0x5f6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ef1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801ef8:	00 
  801ef9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801eff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f03:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f09:	89 04 24             	mov    %eax,(%esp)
  801f0c:	e8 4d fb ff ff       	call   801a5e <readn>
  801f11:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f16:	75 0c                	jne    801f24 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801f18:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f1f:	45 4c 46 
  801f22:	74 3b                	je     801f5f <spawn+0x9b>
		close(fd);
  801f24:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f2a:	89 04 24             	mov    %eax,(%esp)
  801f2d:	e8 2b f9 ff ff       	call   80185d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f32:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801f39:	46 
  801f3a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801f40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f44:	c7 04 24 bb 36 80 00 	movl   $0x8036bb,(%esp)
  801f4b:	e8 cf e3 ff ff       	call   80031f <cprintf>
		return -E_NOT_EXEC;
  801f50:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801f57:	ff ff ff 
  801f5a:	e9 67 05 00 00       	jmp    8024c6 <spawn+0x602>
  801f5f:	ba 07 00 00 00       	mov    $0x7,%edx
  801f64:	89 d0                	mov    %edx,%eax
  801f66:	cd 30                	int    $0x30
  801f68:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801f6e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801f74:	85 c0                	test   %eax,%eax
  801f76:	0f 88 4a 05 00 00    	js     8024c6 <spawn+0x602>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801f7c:	89 c6                	mov    %eax,%esi
  801f7e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801f84:	c1 e6 07             	shl    $0x7,%esi
  801f87:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801f8d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801f93:	b9 11 00 00 00       	mov    $0x11,%ecx
  801f98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801f9a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801fa0:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa9:	8b 02                	mov    (%edx),%eax
  801fab:	85 c0                	test   %eax,%eax
  801fad:	74 5f                	je     80200e <spawn+0x14a>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801faf:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (argc = 0; argv[argc] != 0; argc++)
  801fb4:	be 00 00 00 00       	mov    $0x0,%esi
  801fb9:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 5d ea ff ff       	call   800a20 <strlen>
  801fc3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801fc7:	83 c6 01             	add    $0x1,%esi
  801fca:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801fcc:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801fd3:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	75 e1                	jne    801fbb <spawn+0xf7>
  801fda:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801fe0:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801fe6:	bf 00 10 40 00       	mov    $0x401000,%edi
  801feb:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801fed:	89 f8                	mov    %edi,%eax
  801fef:	83 e0 fc             	and    $0xfffffffc,%eax
  801ff2:	f7 d2                	not    %edx
  801ff4:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801ff7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ffd:	89 d0                	mov    %edx,%eax
  801fff:	83 e8 08             	sub    $0x8,%eax
  802002:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802007:	77 2d                	ja     802036 <spawn+0x172>
  802009:	e9 c9 04 00 00       	jmp    8024d7 <spawn+0x613>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80200e:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802015:	00 00 00 
  802018:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  80201f:	00 00 00 
  802022:	be 00 00 00 00       	mov    $0x0,%esi
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802027:	c7 85 94 fd ff ff fc 	movl   $0x400ffc,-0x26c(%ebp)
  80202e:	0f 40 00 
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802031:	bf 00 10 40 00       	mov    $0x401000,%edi
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802036:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80203d:	00 
  80203e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802045:	00 
  802046:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204d:	e8 1a ef ff ff       	call   800f6c <sys_page_alloc>
  802052:	85 c0                	test   %eax,%eax
  802054:	0f 88 82 04 00 00    	js     8024dc <spawn+0x618>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80205a:	85 f6                	test   %esi,%esi
  80205c:	7e 46                	jle    8020a4 <spawn+0x1e0>
  80205e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802063:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802069:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  80206c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802072:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802078:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80207b:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80207e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802082:	89 3c 24             	mov    %edi,(%esp)
  802085:	e8 e1 e9 ff ff       	call   800a6b <strcpy>
		string_store += strlen(argv[i]) + 1;
  80208a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80208d:	89 04 24             	mov    %eax,(%esp)
  802090:	e8 8b e9 ff ff       	call   800a20 <strlen>
  802095:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802099:	83 c3 01             	add    $0x1,%ebx
  80209c:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8020a2:	75 c8                	jne    80206c <spawn+0x1a8>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8020a4:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020aa:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8020b0:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8020b7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8020bd:	74 24                	je     8020e3 <spawn+0x21f>
  8020bf:	c7 44 24 0c 30 37 80 	movl   $0x803730,0xc(%esp)
  8020c6:	00 
  8020c7:	c7 44 24 08 8f 36 80 	movl   $0x80368f,0x8(%esp)
  8020ce:	00 
  8020cf:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  8020d6:	00 
  8020d7:	c7 04 24 d5 36 80 00 	movl   $0x8036d5,(%esp)
  8020de:	e8 41 e1 ff ff       	call   800224 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8020e3:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8020e9:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8020ee:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020f4:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8020f7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8020fd:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802100:	89 d0                	mov    %edx,%eax
  802102:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802107:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80210d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802114:	00 
  802115:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  80211c:	ee 
  80211d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802123:	89 44 24 08          	mov    %eax,0x8(%esp)
  802127:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80212e:	00 
  80212f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802136:	e8 90 ee ff ff       	call   800fcb <sys_page_map>
  80213b:	89 c3                	mov    %eax,%ebx
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 1a                	js     80215b <spawn+0x297>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802141:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802148:	00 
  802149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802150:	e8 d4 ee ff ff       	call   801029 <sys_page_unmap>
  802155:	89 c3                	mov    %eax,%ebx
  802157:	85 c0                	test   %eax,%eax
  802159:	79 1f                	jns    80217a <spawn+0x2b6>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80215b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802162:	00 
  802163:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216a:	e8 ba ee ff ff       	call   801029 <sys_page_unmap>
	return r;
  80216f:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802175:	e9 4c 03 00 00       	jmp    8024c6 <spawn+0x602>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80217a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802180:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802187:	00 
  802188:	0f 84 e2 01 00 00    	je     802370 <spawn+0x4ac>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80218e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802195:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80219b:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8021a2:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  8021a5:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8021ab:	83 3a 01             	cmpl   $0x1,(%edx)
  8021ae:	0f 85 9b 01 00 00    	jne    80234f <spawn+0x48b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8021b4:	8b 42 18             	mov    0x18(%edx),%eax
  8021b7:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8021ba:	83 f8 01             	cmp    $0x1,%eax
  8021bd:	19 c0                	sbb    %eax,%eax
  8021bf:	83 e0 fe             	and    $0xfffffffe,%eax
  8021c2:	83 c0 07             	add    $0x7,%eax
  8021c5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8021cb:	8b 52 04             	mov    0x4(%edx),%edx
  8021ce:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  8021d4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8021da:	8b 70 10             	mov    0x10(%eax),%esi
  8021dd:	8b 50 14             	mov    0x14(%eax),%edx
  8021e0:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8021e6:	8b 40 08             	mov    0x8(%eax),%eax
  8021e9:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8021ef:	25 ff 0f 00 00       	and    $0xfff,%eax
  8021f4:	74 16                	je     80220c <spawn+0x348>
		va -= i;
  8021f6:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  8021fc:	01 c2                	add    %eax,%edx
  8021fe:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802204:	01 c6                	add    %eax,%esi
		fileoffset -= i;
  802206:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80220c:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  802213:	0f 84 36 01 00 00    	je     80234f <spawn+0x48b>
  802219:	bf 00 00 00 00       	mov    $0x0,%edi
  80221e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  802223:	39 f7                	cmp    %esi,%edi
  802225:	72 31                	jb     802258 <spawn+0x394>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802227:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80222d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802231:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802237:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80223b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802241:	89 04 24             	mov    %eax,(%esp)
  802244:	e8 23 ed ff ff       	call   800f6c <sys_page_alloc>
  802249:	85 c0                	test   %eax,%eax
  80224b:	0f 89 ea 00 00 00    	jns    80233b <spawn+0x477>
  802251:	89 c6                	mov    %eax,%esi
  802253:	e9 3e 02 00 00       	jmp    802496 <spawn+0x5d2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802258:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80225f:	00 
  802260:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802267:	00 
  802268:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80226f:	e8 f8 ec ff ff       	call   800f6c <sys_page_alloc>
  802274:	85 c0                	test   %eax,%eax
  802276:	0f 88 10 02 00 00    	js     80248c <spawn+0x5c8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80227c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802282:	01 d8                	add    %ebx,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802284:	89 44 24 04          	mov    %eax,0x4(%esp)
  802288:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80228e:	89 04 24             	mov    %eax,(%esp)
  802291:	e8 a3 f8 ff ff       	call   801b39 <seek>
  802296:	85 c0                	test   %eax,%eax
  802298:	0f 88 f2 01 00 00    	js     802490 <spawn+0x5cc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80229e:	89 f0                	mov    %esi,%eax
  8022a0:	29 f8                	sub    %edi,%eax
  8022a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022a7:	ba 00 10 00 00       	mov    $0x1000,%edx
  8022ac:	0f 47 c2             	cmova  %edx,%eax
  8022af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022b3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022ba:	00 
  8022bb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8022c1:	89 04 24             	mov    %eax,(%esp)
  8022c4:	e8 95 f7 ff ff       	call   801a5e <readn>
  8022c9:	85 c0                	test   %eax,%eax
  8022cb:	0f 88 c3 01 00 00    	js     802494 <spawn+0x5d0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8022d1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8022d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8022db:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  8022e1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022e5:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8022eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ef:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022f6:	00 
  8022f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fe:	e8 c8 ec ff ff       	call   800fcb <sys_page_map>
  802303:	85 c0                	test   %eax,%eax
  802305:	79 20                	jns    802327 <spawn+0x463>
				panic("spawn: sys_page_map data: %e", r);
  802307:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230b:	c7 44 24 08 e1 36 80 	movl   $0x8036e1,0x8(%esp)
  802312:	00 
  802313:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  80231a:	00 
  80231b:	c7 04 24 d5 36 80 00 	movl   $0x8036d5,(%esp)
  802322:	e8 fd de ff ff       	call   800224 <_panic>
			sys_page_unmap(0, UTEMP);
  802327:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80232e:	00 
  80232f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802336:	e8 ee ec ff ff       	call   801029 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80233b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802341:	89 df                	mov    %ebx,%edi
  802343:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802349:	0f 82 d4 fe ff ff    	jb     802223 <spawn+0x35f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80234f:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  802356:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  80235d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802364:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  80236a:	0f 8f 35 fe ff ff    	jg     8021a5 <spawn+0x2e1>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802370:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802376:	89 04 24             	mov    %eax,(%esp)
  802379:	e8 df f4 ff ff       	call   80185d <close>
  80237e:	bf 00 00 00 00       	mov    $0x0,%edi
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  802383:	be 00 00 00 00       	mov    $0x0,%esi
  802388:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(i * PGSIZE)] & PTE_P) && (uvpt[i] & PTE_P) && (uvpt[i] & PTE_SHARE)) {
  80238e:	89 f8                	mov    %edi,%eax
  802390:	c1 e8 16             	shr    $0x16,%eax
  802393:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80239a:	a8 01                	test   $0x1,%al
  80239c:	74 63                	je     802401 <spawn+0x53d>
  80239e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8023a5:	a8 01                	test   $0x1,%al
  8023a7:	74 58                	je     802401 <spawn+0x53d>
  8023a9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8023b0:	f6 c4 04             	test   $0x4,%ah
  8023b3:	74 4c                	je     802401 <spawn+0x53d>
			res = sys_page_map(0, (void *)(i * PGSIZE), child, (void *)(i * PGSIZE), uvpt[i] & PTE_SYSCALL);
  8023b5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8023bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8023c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023d8:	e8 ee eb ff ff       	call   800fcb <sys_page_map>
			if (res < 0)
  8023dd:	85 c0                	test   %eax,%eax
  8023df:	79 20                	jns    802401 <spawn+0x53d>
				panic("sys_page_map failed in copy_shared_pages %e\n", res);
  8023e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023e5:	c7 44 24 08 58 37 80 	movl   $0x803758,0x8(%esp)
  8023ec:	00 
  8023ed:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  8023f4:	00 
  8023f5:	c7 04 24 d5 36 80 00 	movl   $0x8036d5,(%esp)
  8023fc:	e8 23 de ff ff       	call   800224 <_panic>
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  802401:	83 c6 01             	add    $0x1,%esi
  802404:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80240a:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  802410:	0f 85 78 ff ff ff    	jne    80238e <spawn+0x4ca>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802416:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80241c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802420:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802426:	89 04 24             	mov    %eax,(%esp)
  802429:	e8 b7 ec ff ff       	call   8010e5 <sys_env_set_trapframe>
  80242e:	85 c0                	test   %eax,%eax
  802430:	79 20                	jns    802452 <spawn+0x58e>
		panic("sys_env_set_trapframe: %e", r);
  802432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802436:	c7 44 24 08 fe 36 80 	movl   $0x8036fe,0x8(%esp)
  80243d:	00 
  80243e:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802445:	00 
  802446:	c7 04 24 d5 36 80 00 	movl   $0x8036d5,(%esp)
  80244d:	e8 d2 dd ff ff       	call   800224 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802452:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802459:	00 
  80245a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802460:	89 04 24             	mov    %eax,(%esp)
  802463:	e8 1f ec ff ff       	call   801087 <sys_env_set_status>
  802468:	85 c0                	test   %eax,%eax
  80246a:	79 5a                	jns    8024c6 <spawn+0x602>
		panic("sys_env_set_status: %e", r);
  80246c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802470:	c7 44 24 08 18 37 80 	movl   $0x803718,0x8(%esp)
  802477:	00 
  802478:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  80247f:	00 
  802480:	c7 04 24 d5 36 80 00 	movl   $0x8036d5,(%esp)
  802487:	e8 98 dd ff ff       	call   800224 <_panic>
  80248c:	89 c6                	mov    %eax,%esi
  80248e:	eb 06                	jmp    802496 <spawn+0x5d2>
  802490:	89 c6                	mov    %eax,%esi
  802492:	eb 02                	jmp    802496 <spawn+0x5d2>
  802494:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802496:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80249c:	89 04 24             	mov    %eax,(%esp)
  80249f:	e8 0b ea ff ff       	call   800eaf <sys_env_destroy>
	close(fd);
  8024a4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8024aa:	89 04 24             	mov    %eax,(%esp)
  8024ad:	e8 ab f3 ff ff       	call   80185d <close>
	return r;
  8024b2:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  8024b8:	eb 0c                	jmp    8024c6 <spawn+0x602>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8024ba:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8024c0:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8024c6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8024cc:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8024d2:	5b                   	pop    %ebx
  8024d3:	5e                   	pop    %esi
  8024d4:	5f                   	pop    %edi
  8024d5:	5d                   	pop    %ebp
  8024d6:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8024d7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  8024dc:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8024e2:	eb e2                	jmp    8024c6 <spawn+0x602>

008024e4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8024e4:	55                   	push   %ebp
  8024e5:	89 e5                	mov    %esp,%ebp
  8024e7:	56                   	push   %esi
  8024e8:	53                   	push   %ebx
  8024e9:	83 ec 10             	sub    $0x10,%esp
  8024ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8024ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8024f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024f6:	74 66                	je     80255e <spawnl+0x7a>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8024f8:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  8024fd:	83 c1 01             	add    $0x1,%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802500:	89 c2                	mov    %eax,%edx
  802502:	83 c0 04             	add    $0x4,%eax
  802505:	83 3a 00             	cmpl   $0x0,(%edx)
  802508:	75 f3                	jne    8024fd <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80250a:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802511:	83 e0 f0             	and    $0xfffffff0,%eax
  802514:	29 c4                	sub    %eax,%esp
  802516:	8d 44 24 17          	lea    0x17(%esp),%eax
  80251a:	83 e0 f0             	and    $0xfffffff0,%eax
  80251d:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80251f:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802521:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802528:	00 

	va_start(vl, arg0);
  802529:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80252c:	89 ce                	mov    %ecx,%esi
  80252e:	85 c9                	test   %ecx,%ecx
  802530:	74 16                	je     802548 <spawnl+0x64>
  802532:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802537:	83 c0 01             	add    $0x1,%eax
  80253a:	89 d1                	mov    %edx,%ecx
  80253c:	83 c2 04             	add    $0x4,%edx
  80253f:	8b 09                	mov    (%ecx),%ecx
  802541:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802544:	39 f0                	cmp    %esi,%eax
  802546:	75 ef                	jne    802537 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80254c:	8b 45 08             	mov    0x8(%ebp),%eax
  80254f:	89 04 24             	mov    %eax,(%esp)
  802552:	e8 6d f9 ff ff       	call   801ec4 <spawn>
}
  802557:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255a:	5b                   	pop    %ebx
  80255b:	5e                   	pop    %esi
  80255c:	5d                   	pop    %ebp
  80255d:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80255e:	83 ec 20             	sub    $0x20,%esp
  802561:	8d 44 24 17          	lea    0x17(%esp),%eax
  802565:	83 e0 f0             	and    $0xfffffff0,%eax
  802568:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80256a:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80256c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802573:	eb d3                	jmp    802548 <spawnl+0x64>
	...

00802580 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802580:	55                   	push   %ebp
  802581:	89 e5                	mov    %esp,%ebp
  802583:	83 ec 18             	sub    $0x18,%esp
  802586:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802589:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80258c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80258f:	8b 45 08             	mov    0x8(%ebp),%eax
  802592:	89 04 24             	mov    %eax,(%esp)
  802595:	e8 e6 f0 ff ff       	call   801680 <fd2data>
  80259a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80259c:	c7 44 24 04 85 37 80 	movl   $0x803785,0x4(%esp)
  8025a3:	00 
  8025a4:	89 34 24             	mov    %esi,(%esp)
  8025a7:	e8 bf e4 ff ff       	call   800a6b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8025ac:	8b 43 04             	mov    0x4(%ebx),%eax
  8025af:	2b 03                	sub    (%ebx),%eax
  8025b1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8025b7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8025be:	00 00 00 
	stat->st_dev = &devpipe;
  8025c1:	c7 86 88 00 00 00 2c 	movl   $0x80402c,0x88(%esi)
  8025c8:	40 80 00 
	return 0;
}
  8025cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8025d0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8025d3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8025d6:	89 ec                	mov    %ebp,%esp
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    

008025da <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8025da:	55                   	push   %ebp
  8025db:	89 e5                	mov    %esp,%ebp
  8025dd:	53                   	push   %ebx
  8025de:	83 ec 14             	sub    $0x14,%esp
  8025e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8025e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8025e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025ef:	e8 35 ea ff ff       	call   801029 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8025f4:	89 1c 24             	mov    %ebx,(%esp)
  8025f7:	e8 84 f0 ff ff       	call   801680 <fd2data>
  8025fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802600:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802607:	e8 1d ea ff ff       	call   801029 <sys_page_unmap>
}
  80260c:	83 c4 14             	add    $0x14,%esp
  80260f:	5b                   	pop    %ebx
  802610:	5d                   	pop    %ebp
  802611:	c3                   	ret    

00802612 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802612:	55                   	push   %ebp
  802613:	89 e5                	mov    %esp,%ebp
  802615:	57                   	push   %edi
  802616:	56                   	push   %esi
  802617:	53                   	push   %ebx
  802618:	83 ec 2c             	sub    $0x2c,%esp
  80261b:	89 c7                	mov    %eax,%edi
  80261d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802620:	a1 04 50 80 00       	mov    0x805004,%eax
  802625:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802628:	89 3c 24             	mov    %edi,(%esp)
  80262b:	e8 0c 07 00 00       	call   802d3c <pageref>
  802630:	89 c6                	mov    %eax,%esi
  802632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802635:	89 04 24             	mov    %eax,(%esp)
  802638:	e8 ff 06 00 00       	call   802d3c <pageref>
  80263d:	39 c6                	cmp    %eax,%esi
  80263f:	0f 94 c0             	sete   %al
  802642:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802645:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80264b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80264e:	39 cb                	cmp    %ecx,%ebx
  802650:	75 08                	jne    80265a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802652:	83 c4 2c             	add    $0x2c,%esp
  802655:	5b                   	pop    %ebx
  802656:	5e                   	pop    %esi
  802657:	5f                   	pop    %edi
  802658:	5d                   	pop    %ebp
  802659:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80265a:	83 f8 01             	cmp    $0x1,%eax
  80265d:	75 c1                	jne    802620 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80265f:	8b 52 58             	mov    0x58(%edx),%edx
  802662:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802666:	89 54 24 08          	mov    %edx,0x8(%esp)
  80266a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80266e:	c7 04 24 8c 37 80 00 	movl   $0x80378c,(%esp)
  802675:	e8 a5 dc ff ff       	call   80031f <cprintf>
  80267a:	eb a4                	jmp    802620 <_pipeisclosed+0xe>

0080267c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	57                   	push   %edi
  802680:	56                   	push   %esi
  802681:	53                   	push   %ebx
  802682:	83 ec 2c             	sub    $0x2c,%esp
  802685:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802688:	89 34 24             	mov    %esi,(%esp)
  80268b:	e8 f0 ef ff ff       	call   801680 <fd2data>
  802690:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802692:	bf 00 00 00 00       	mov    $0x0,%edi
  802697:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80269b:	75 50                	jne    8026ed <devpipe_write+0x71>
  80269d:	eb 5c                	jmp    8026fb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80269f:	89 da                	mov    %ebx,%edx
  8026a1:	89 f0                	mov    %esi,%eax
  8026a3:	e8 6a ff ff ff       	call   802612 <_pipeisclosed>
  8026a8:	85 c0                	test   %eax,%eax
  8026aa:	75 53                	jne    8026ff <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8026ac:	e8 8b e8 ff ff       	call   800f3c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8026b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8026b4:	8b 13                	mov    (%ebx),%edx
  8026b6:	83 c2 20             	add    $0x20,%edx
  8026b9:	39 d0                	cmp    %edx,%eax
  8026bb:	73 e2                	jae    80269f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8026bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026c0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  8026c4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  8026c7:	89 c2                	mov    %eax,%edx
  8026c9:	c1 fa 1f             	sar    $0x1f,%edx
  8026cc:	c1 ea 1b             	shr    $0x1b,%edx
  8026cf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8026d2:	83 e1 1f             	and    $0x1f,%ecx
  8026d5:	29 d1                	sub    %edx,%ecx
  8026d7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8026db:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8026df:	83 c0 01             	add    $0x1,%eax
  8026e2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026e5:	83 c7 01             	add    $0x1,%edi
  8026e8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8026eb:	74 0e                	je     8026fb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8026ed:	8b 43 04             	mov    0x4(%ebx),%eax
  8026f0:	8b 13                	mov    (%ebx),%edx
  8026f2:	83 c2 20             	add    $0x20,%edx
  8026f5:	39 d0                	cmp    %edx,%eax
  8026f7:	73 a6                	jae    80269f <devpipe_write+0x23>
  8026f9:	eb c2                	jmp    8026bd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8026fb:	89 f8                	mov    %edi,%eax
  8026fd:	eb 05                	jmp    802704 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8026ff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802704:	83 c4 2c             	add    $0x2c,%esp
  802707:	5b                   	pop    %ebx
  802708:	5e                   	pop    %esi
  802709:	5f                   	pop    %edi
  80270a:	5d                   	pop    %ebp
  80270b:	c3                   	ret    

0080270c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
  80270f:	83 ec 28             	sub    $0x28,%esp
  802712:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802715:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802718:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80271b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80271e:	89 3c 24             	mov    %edi,(%esp)
  802721:	e8 5a ef ff ff       	call   801680 <fd2data>
  802726:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802728:	be 00 00 00 00       	mov    $0x0,%esi
  80272d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802731:	75 47                	jne    80277a <devpipe_read+0x6e>
  802733:	eb 52                	jmp    802787 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802735:	89 f0                	mov    %esi,%eax
  802737:	eb 5e                	jmp    802797 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802739:	89 da                	mov    %ebx,%edx
  80273b:	89 f8                	mov    %edi,%eax
  80273d:	8d 76 00             	lea    0x0(%esi),%esi
  802740:	e8 cd fe ff ff       	call   802612 <_pipeisclosed>
  802745:	85 c0                	test   %eax,%eax
  802747:	75 49                	jne    802792 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802749:	e8 ee e7 ff ff       	call   800f3c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80274e:	8b 03                	mov    (%ebx),%eax
  802750:	3b 43 04             	cmp    0x4(%ebx),%eax
  802753:	74 e4                	je     802739 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802755:	89 c2                	mov    %eax,%edx
  802757:	c1 fa 1f             	sar    $0x1f,%edx
  80275a:	c1 ea 1b             	shr    $0x1b,%edx
  80275d:	01 d0                	add    %edx,%eax
  80275f:	83 e0 1f             	and    $0x1f,%eax
  802762:	29 d0                	sub    %edx,%eax
  802764:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802769:	8b 55 0c             	mov    0xc(%ebp),%edx
  80276c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80276f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802772:	83 c6 01             	add    $0x1,%esi
  802775:	3b 75 10             	cmp    0x10(%ebp),%esi
  802778:	74 0d                	je     802787 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80277a:	8b 03                	mov    (%ebx),%eax
  80277c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80277f:	75 d4                	jne    802755 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802781:	85 f6                	test   %esi,%esi
  802783:	75 b0                	jne    802735 <devpipe_read+0x29>
  802785:	eb b2                	jmp    802739 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802787:	89 f0                	mov    %esi,%eax
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	eb 05                	jmp    802797 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802792:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802797:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80279a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80279d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8027a0:	89 ec                	mov    %ebp,%esp
  8027a2:	5d                   	pop    %ebp
  8027a3:	c3                   	ret    

008027a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8027a4:	55                   	push   %ebp
  8027a5:	89 e5                	mov    %esp,%ebp
  8027a7:	83 ec 48             	sub    $0x48,%esp
  8027aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8027ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8027b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8027b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8027b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8027b9:	89 04 24             	mov    %eax,(%esp)
  8027bc:	e8 da ee ff ff       	call   80169b <fd_alloc>
  8027c1:	89 c3                	mov    %eax,%ebx
  8027c3:	85 c0                	test   %eax,%eax
  8027c5:	0f 88 45 01 00 00    	js     802910 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027cb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027d2:	00 
  8027d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027e1:	e8 86 e7 ff ff       	call   800f6c <sys_page_alloc>
  8027e6:	89 c3                	mov    %eax,%ebx
  8027e8:	85 c0                	test   %eax,%eax
  8027ea:	0f 88 20 01 00 00    	js     802910 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8027f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8027f3:	89 04 24             	mov    %eax,(%esp)
  8027f6:	e8 a0 ee ff ff       	call   80169b <fd_alloc>
  8027fb:	89 c3                	mov    %eax,%ebx
  8027fd:	85 c0                	test   %eax,%eax
  8027ff:	0f 88 f8 00 00 00    	js     8028fd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802805:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80280c:	00 
  80280d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802810:	89 44 24 04          	mov    %eax,0x4(%esp)
  802814:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80281b:	e8 4c e7 ff ff       	call   800f6c <sys_page_alloc>
  802820:	89 c3                	mov    %eax,%ebx
  802822:	85 c0                	test   %eax,%eax
  802824:	0f 88 d3 00 00 00    	js     8028fd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80282a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80282d:	89 04 24             	mov    %eax,(%esp)
  802830:	e8 4b ee ff ff       	call   801680 <fd2data>
  802835:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802837:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80283e:	00 
  80283f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802843:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80284a:	e8 1d e7 ff ff       	call   800f6c <sys_page_alloc>
  80284f:	89 c3                	mov    %eax,%ebx
  802851:	85 c0                	test   %eax,%eax
  802853:	0f 88 91 00 00 00    	js     8028ea <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802859:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80285c:	89 04 24             	mov    %eax,(%esp)
  80285f:	e8 1c ee ff ff       	call   801680 <fd2data>
  802864:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80286b:	00 
  80286c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802870:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802877:	00 
  802878:	89 74 24 04          	mov    %esi,0x4(%esp)
  80287c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802883:	e8 43 e7 ff ff       	call   800fcb <sys_page_map>
  802888:	89 c3                	mov    %eax,%ebx
  80288a:	85 c0                	test   %eax,%eax
  80288c:	78 4c                	js     8028da <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80288e:	8b 15 2c 40 80 00    	mov    0x80402c,%edx
  802894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802897:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802899:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80289c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8028a3:	8b 15 2c 40 80 00    	mov    0x80402c,%edx
  8028a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028ac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8028ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8028b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028bb:	89 04 24             	mov    %eax,(%esp)
  8028be:	e8 ad ed ff ff       	call   801670 <fd2num>
  8028c3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8028c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028c8:	89 04 24             	mov    %eax,(%esp)
  8028cb:	e8 a0 ed ff ff       	call   801670 <fd2num>
  8028d0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8028d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028d8:	eb 36                	jmp    802910 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8028da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028e5:	e8 3f e7 ff ff       	call   801029 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8028ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028f8:	e8 2c e7 ff ff       	call   801029 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8028fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802900:	89 44 24 04          	mov    %eax,0x4(%esp)
  802904:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80290b:	e8 19 e7 ff ff       	call   801029 <sys_page_unmap>
    err:
	return r;
}
  802910:	89 d8                	mov    %ebx,%eax
  802912:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802915:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802918:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80291b:	89 ec                	mov    %ebp,%esp
  80291d:	5d                   	pop    %ebp
  80291e:	c3                   	ret    

0080291f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80291f:	55                   	push   %ebp
  802920:	89 e5                	mov    %esp,%ebp
  802922:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802925:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80292c:	8b 45 08             	mov    0x8(%ebp),%eax
  80292f:	89 04 24             	mov    %eax,(%esp)
  802932:	e8 d7 ed ff ff       	call   80170e <fd_lookup>
  802937:	85 c0                	test   %eax,%eax
  802939:	78 15                	js     802950 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80293b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80293e:	89 04 24             	mov    %eax,(%esp)
  802941:	e8 3a ed ff ff       	call   801680 <fd2data>
	return _pipeisclosed(fd, p);
  802946:	89 c2                	mov    %eax,%edx
  802948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80294b:	e8 c2 fc ff ff       	call   802612 <_pipeisclosed>
}
  802950:	c9                   	leave  
  802951:	c3                   	ret    
	...

00802954 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802954:	55                   	push   %ebp
  802955:	89 e5                	mov    %esp,%ebp
  802957:	56                   	push   %esi
  802958:	53                   	push   %ebx
  802959:	83 ec 10             	sub    $0x10,%esp
  80295c:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  80295f:	85 c0                	test   %eax,%eax
  802961:	75 24                	jne    802987 <wait+0x33>
  802963:	c7 44 24 0c a4 37 80 	movl   $0x8037a4,0xc(%esp)
  80296a:	00 
  80296b:	c7 44 24 08 8f 36 80 	movl   $0x80368f,0x8(%esp)
  802972:	00 
  802973:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80297a:	00 
  80297b:	c7 04 24 af 37 80 00 	movl   $0x8037af,(%esp)
  802982:	e8 9d d8 ff ff       	call   800224 <_panic>
	e = &envs[ENVX(envid)];
  802987:	89 c3                	mov    %eax,%ebx
  802989:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80298f:	c1 e3 07             	shl    $0x7,%ebx
  802992:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802998:	8b 73 48             	mov    0x48(%ebx),%esi
  80299b:	39 c6                	cmp    %eax,%esi
  80299d:	75 1a                	jne    8029b9 <wait+0x65>
  80299f:	8b 43 54             	mov    0x54(%ebx),%eax
  8029a2:	85 c0                	test   %eax,%eax
  8029a4:	74 13                	je     8029b9 <wait+0x65>
		sys_yield();
  8029a6:	e8 91 e5 ff ff       	call   800f3c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8029ab:	8b 43 48             	mov    0x48(%ebx),%eax
  8029ae:	39 f0                	cmp    %esi,%eax
  8029b0:	75 07                	jne    8029b9 <wait+0x65>
  8029b2:	8b 43 54             	mov    0x54(%ebx),%eax
  8029b5:	85 c0                	test   %eax,%eax
  8029b7:	75 ed                	jne    8029a6 <wait+0x52>
		sys_yield();
}
  8029b9:	83 c4 10             	add    $0x10,%esp
  8029bc:	5b                   	pop    %ebx
  8029bd:	5e                   	pop    %esi
  8029be:	5d                   	pop    %ebp
  8029bf:	c3                   	ret    

008029c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8029c0:	55                   	push   %ebp
  8029c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8029c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8029c8:	5d                   	pop    %ebp
  8029c9:	c3                   	ret    

008029ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8029ca:	55                   	push   %ebp
  8029cb:	89 e5                	mov    %esp,%ebp
  8029cd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8029d0:	c7 44 24 04 ba 37 80 	movl   $0x8037ba,0x4(%esp)
  8029d7:	00 
  8029d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029db:	89 04 24             	mov    %eax,(%esp)
  8029de:	e8 88 e0 ff ff       	call   800a6b <strcpy>
	return 0;
}
  8029e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8029e8:	c9                   	leave  
  8029e9:	c3                   	ret    

008029ea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8029ea:	55                   	push   %ebp
  8029eb:	89 e5                	mov    %esp,%ebp
  8029ed:	57                   	push   %edi
  8029ee:	56                   	push   %esi
  8029ef:	53                   	push   %ebx
  8029f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8029f6:	be 00 00 00 00       	mov    $0x0,%esi
  8029fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8029ff:	74 43                	je     802a44 <devcons_write+0x5a>
  802a01:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802a06:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a0f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802a11:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802a14:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802a19:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802a1c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a20:	03 45 0c             	add    0xc(%ebp),%eax
  802a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a27:	89 3c 24             	mov    %edi,(%esp)
  802a2a:	e8 2d e2 ff ff       	call   800c5c <memmove>
		sys_cputs(buf, m);
  802a2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802a33:	89 3c 24             	mov    %edi,(%esp)
  802a36:	e8 15 e4 ff ff       	call   800e50 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802a3b:	01 de                	add    %ebx,%esi
  802a3d:	89 f0                	mov    %esi,%eax
  802a3f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802a42:	72 c8                	jb     802a0c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802a44:	89 f0                	mov    %esi,%eax
  802a46:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802a4c:	5b                   	pop    %ebx
  802a4d:	5e                   	pop    %esi
  802a4e:	5f                   	pop    %edi
  802a4f:	5d                   	pop    %ebp
  802a50:	c3                   	ret    

00802a51 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802a51:	55                   	push   %ebp
  802a52:	89 e5                	mov    %esp,%ebp
  802a54:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802a57:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802a5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802a60:	75 07                	jne    802a69 <devcons_read+0x18>
  802a62:	eb 31                	jmp    802a95 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802a64:	e8 d3 e4 ff ff       	call   800f3c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a70:	e8 0a e4 ff ff       	call   800e7f <sys_cgetc>
  802a75:	85 c0                	test   %eax,%eax
  802a77:	74 eb                	je     802a64 <devcons_read+0x13>
  802a79:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802a7b:	85 c0                	test   %eax,%eax
  802a7d:	78 16                	js     802a95 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802a7f:	83 f8 04             	cmp    $0x4,%eax
  802a82:	74 0c                	je     802a90 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a87:	88 10                	mov    %dl,(%eax)
	return 1;
  802a89:	b8 01 00 00 00       	mov    $0x1,%eax
  802a8e:	eb 05                	jmp    802a95 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802a90:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802a95:	c9                   	leave  
  802a96:	c3                   	ret    

00802a97 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802a97:	55                   	push   %ebp
  802a98:	89 e5                	mov    %esp,%ebp
  802a9a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  802aa0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802aa3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802aaa:	00 
  802aab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802aae:	89 04 24             	mov    %eax,(%esp)
  802ab1:	e8 9a e3 ff ff       	call   800e50 <sys_cputs>
}
  802ab6:	c9                   	leave  
  802ab7:	c3                   	ret    

00802ab8 <getchar>:

int
getchar(void)
{
  802ab8:	55                   	push   %ebp
  802ab9:	89 e5                	mov    %esp,%ebp
  802abb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802abe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802ac5:	00 
  802ac6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802acd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ad4:	e8 f5 ee ff ff       	call   8019ce <read>
	if (r < 0)
  802ad9:	85 c0                	test   %eax,%eax
  802adb:	78 0f                	js     802aec <getchar+0x34>
		return r;
	if (r < 1)
  802add:	85 c0                	test   %eax,%eax
  802adf:	7e 06                	jle    802ae7 <getchar+0x2f>
		return -E_EOF;
	return c;
  802ae1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802ae5:	eb 05                	jmp    802aec <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802ae7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802aec:	c9                   	leave  
  802aed:	c3                   	ret    

00802aee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802aee:	55                   	push   %ebp
  802aef:	89 e5                	mov    %esp,%ebp
  802af1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802afb:	8b 45 08             	mov    0x8(%ebp),%eax
  802afe:	89 04 24             	mov    %eax,(%esp)
  802b01:	e8 08 ec ff ff       	call   80170e <fd_lookup>
  802b06:	85 c0                	test   %eax,%eax
  802b08:	78 11                	js     802b1b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b0d:	8b 15 48 40 80 00    	mov    0x804048,%edx
  802b13:	39 10                	cmp    %edx,(%eax)
  802b15:	0f 94 c0             	sete   %al
  802b18:	0f b6 c0             	movzbl %al,%eax
}
  802b1b:	c9                   	leave  
  802b1c:	c3                   	ret    

00802b1d <opencons>:

int
opencons(void)
{
  802b1d:	55                   	push   %ebp
  802b1e:	89 e5                	mov    %esp,%ebp
  802b20:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b26:	89 04 24             	mov    %eax,(%esp)
  802b29:	e8 6d eb ff ff       	call   80169b <fd_alloc>
  802b2e:	85 c0                	test   %eax,%eax
  802b30:	78 3c                	js     802b6e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802b32:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802b39:	00 
  802b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b48:	e8 1f e4 ff ff       	call   800f6c <sys_page_alloc>
  802b4d:	85 c0                	test   %eax,%eax
  802b4f:	78 1d                	js     802b6e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802b51:	8b 15 48 40 80 00    	mov    0x804048,%edx
  802b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b5a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b5f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802b66:	89 04 24             	mov    %eax,(%esp)
  802b69:	e8 02 eb ff ff       	call   801670 <fd2num>
}
  802b6e:	c9                   	leave  
  802b6f:	c3                   	ret    

00802b70 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802b70:	55                   	push   %ebp
  802b71:	89 e5                	mov    %esp,%ebp
  802b73:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802b76:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802b7d:	75 3c                	jne    802bbb <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802b7f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802b86:	00 
  802b87:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802b8e:	ee 
  802b8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b96:	e8 d1 e3 ff ff       	call   800f6c <sys_page_alloc>
  802b9b:	85 c0                	test   %eax,%eax
  802b9d:	79 1c                	jns    802bbb <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  802b9f:	c7 44 24 08 c8 37 80 	movl   $0x8037c8,0x8(%esp)
  802ba6:	00 
  802ba7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802bae:	00 
  802baf:	c7 04 24 2c 38 80 00 	movl   $0x80382c,(%esp)
  802bb6:	e8 69 d6 ff ff       	call   800224 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  802bbe:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802bc3:	c7 44 24 04 fc 2b 80 	movl   $0x802bfc,0x4(%esp)
  802bca:	00 
  802bcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bd2:	e8 6c e5 ff ff       	call   801143 <sys_env_set_pgfault_upcall>
  802bd7:	85 c0                	test   %eax,%eax
  802bd9:	79 1c                	jns    802bf7 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802bdb:	c7 44 24 08 f4 37 80 	movl   $0x8037f4,0x8(%esp)
  802be2:	00 
  802be3:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  802bea:	00 
  802beb:	c7 04 24 2c 38 80 00 	movl   $0x80382c,(%esp)
  802bf2:	e8 2d d6 ff ff       	call   800224 <_panic>
}
  802bf7:	c9                   	leave  
  802bf8:	c3                   	ret    
  802bf9:	00 00                	add    %al,(%eax)
	...

00802bfc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802bfc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802bfd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802c02:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802c04:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  802c07:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  802c0b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802c10:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802c14:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  802c16:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802c19:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  802c1a:	83 c4 04             	add    $0x4,%esp
    popfl
  802c1d:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  802c1e:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  802c1f:	c3                   	ret    

00802c20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802c20:	55                   	push   %ebp
  802c21:	89 e5                	mov    %esp,%ebp
  802c23:	56                   	push   %esi
  802c24:	53                   	push   %ebx
  802c25:	83 ec 10             	sub    $0x10,%esp
  802c28:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c2e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802c31:	85 db                	test   %ebx,%ebx
  802c33:	74 06                	je     802c3b <ipc_recv+0x1b>
  802c35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  802c3b:	85 f6                	test   %esi,%esi
  802c3d:	74 06                	je     802c45 <ipc_recv+0x25>
  802c3f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802c45:	85 c0                	test   %eax,%eax
  802c47:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802c4c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  802c4f:	89 04 24             	mov    %eax,(%esp)
  802c52:	e8 7e e5 ff ff       	call   8011d5 <sys_ipc_recv>
    if (ret) return ret;
  802c57:	85 c0                	test   %eax,%eax
  802c59:	75 24                	jne    802c7f <ipc_recv+0x5f>
    if (from_env_store)
  802c5b:	85 db                	test   %ebx,%ebx
  802c5d:	74 0a                	je     802c69 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  802c5f:	a1 04 50 80 00       	mov    0x805004,%eax
  802c64:	8b 40 74             	mov    0x74(%eax),%eax
  802c67:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802c69:	85 f6                	test   %esi,%esi
  802c6b:	74 0a                	je     802c77 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  802c6d:	a1 04 50 80 00       	mov    0x805004,%eax
  802c72:	8b 40 78             	mov    0x78(%eax),%eax
  802c75:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802c77:	a1 04 50 80 00       	mov    0x805004,%eax
  802c7c:	8b 40 70             	mov    0x70(%eax),%eax
}
  802c7f:	83 c4 10             	add    $0x10,%esp
  802c82:	5b                   	pop    %ebx
  802c83:	5e                   	pop    %esi
  802c84:	5d                   	pop    %ebp
  802c85:	c3                   	ret    

00802c86 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802c86:	55                   	push   %ebp
  802c87:	89 e5                	mov    %esp,%ebp
  802c89:	57                   	push   %edi
  802c8a:	56                   	push   %esi
  802c8b:	53                   	push   %ebx
  802c8c:	83 ec 1c             	sub    $0x1c,%esp
  802c8f:	8b 75 08             	mov    0x8(%ebp),%esi
  802c92:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802c98:	85 db                	test   %ebx,%ebx
  802c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802c9f:	0f 44 d8             	cmove  %eax,%ebx
  802ca2:	eb 2a                	jmp    802cce <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802ca4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ca7:	74 20                	je     802cc9 <ipc_send+0x43>
  802ca9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cad:	c7 44 24 08 3a 38 80 	movl   $0x80383a,0x8(%esp)
  802cb4:	00 
  802cb5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  802cbc:	00 
  802cbd:	c7 04 24 51 38 80 00 	movl   $0x803851,(%esp)
  802cc4:	e8 5b d5 ff ff       	call   800224 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802cc9:	e8 6e e2 ff ff       	call   800f3c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802cce:	8b 45 14             	mov    0x14(%ebp),%eax
  802cd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cd5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802cd9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802cdd:	89 34 24             	mov    %esi,(%esp)
  802ce0:	e8 bc e4 ff ff       	call   8011a1 <sys_ipc_try_send>
  802ce5:	85 c0                	test   %eax,%eax
  802ce7:	75 bb                	jne    802ca4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802ce9:	83 c4 1c             	add    $0x1c,%esp
  802cec:	5b                   	pop    %ebx
  802ced:	5e                   	pop    %esi
  802cee:	5f                   	pop    %edi
  802cef:	5d                   	pop    %ebp
  802cf0:	c3                   	ret    

00802cf1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802cf1:	55                   	push   %ebp
  802cf2:	89 e5                	mov    %esp,%ebp
  802cf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802cf7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802cfc:	39 c8                	cmp    %ecx,%eax
  802cfe:	74 19                	je     802d19 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802d00:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802d05:	89 c2                	mov    %eax,%edx
  802d07:	c1 e2 07             	shl    $0x7,%edx
  802d0a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802d10:	8b 52 50             	mov    0x50(%edx),%edx
  802d13:	39 ca                	cmp    %ecx,%edx
  802d15:	75 14                	jne    802d2b <ipc_find_env+0x3a>
  802d17:	eb 05                	jmp    802d1e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802d19:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802d1e:	c1 e0 07             	shl    $0x7,%eax
  802d21:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802d26:	8b 40 40             	mov    0x40(%eax),%eax
  802d29:	eb 0e                	jmp    802d39 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802d2b:	83 c0 01             	add    $0x1,%eax
  802d2e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802d33:	75 d0                	jne    802d05 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802d35:	66 b8 00 00          	mov    $0x0,%ax
}
  802d39:	5d                   	pop    %ebp
  802d3a:	c3                   	ret    
	...

00802d3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802d3c:	55                   	push   %ebp
  802d3d:	89 e5                	mov    %esp,%ebp
  802d3f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802d42:	89 d0                	mov    %edx,%eax
  802d44:	c1 e8 16             	shr    $0x16,%eax
  802d47:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802d4e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802d53:	f6 c1 01             	test   $0x1,%cl
  802d56:	74 1d                	je     802d75 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802d58:	c1 ea 0c             	shr    $0xc,%edx
  802d5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802d62:	f6 c2 01             	test   $0x1,%dl
  802d65:	74 0e                	je     802d75 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802d67:	c1 ea 0c             	shr    $0xc,%edx
  802d6a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802d71:	ef 
  802d72:	0f b7 c0             	movzwl %ax,%eax
}
  802d75:	5d                   	pop    %ebp
  802d76:	c3                   	ret    
	...

00802d80 <__udivdi3>:
  802d80:	83 ec 1c             	sub    $0x1c,%esp
  802d83:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802d87:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  802d8b:	8b 44 24 20          	mov    0x20(%esp),%eax
  802d8f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802d93:	89 74 24 10          	mov    %esi,0x10(%esp)
  802d97:	8b 74 24 24          	mov    0x24(%esp),%esi
  802d9b:	85 ff                	test   %edi,%edi
  802d9d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802da1:	89 44 24 08          	mov    %eax,0x8(%esp)
  802da5:	89 cd                	mov    %ecx,%ebp
  802da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dab:	75 33                	jne    802de0 <__udivdi3+0x60>
  802dad:	39 f1                	cmp    %esi,%ecx
  802daf:	77 57                	ja     802e08 <__udivdi3+0x88>
  802db1:	85 c9                	test   %ecx,%ecx
  802db3:	75 0b                	jne    802dc0 <__udivdi3+0x40>
  802db5:	b8 01 00 00 00       	mov    $0x1,%eax
  802dba:	31 d2                	xor    %edx,%edx
  802dbc:	f7 f1                	div    %ecx
  802dbe:	89 c1                	mov    %eax,%ecx
  802dc0:	89 f0                	mov    %esi,%eax
  802dc2:	31 d2                	xor    %edx,%edx
  802dc4:	f7 f1                	div    %ecx
  802dc6:	89 c6                	mov    %eax,%esi
  802dc8:	8b 44 24 04          	mov    0x4(%esp),%eax
  802dcc:	f7 f1                	div    %ecx
  802dce:	89 f2                	mov    %esi,%edx
  802dd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  802dd4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802dd8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802ddc:	83 c4 1c             	add    $0x1c,%esp
  802ddf:	c3                   	ret    
  802de0:	31 d2                	xor    %edx,%edx
  802de2:	31 c0                	xor    %eax,%eax
  802de4:	39 f7                	cmp    %esi,%edi
  802de6:	77 e8                	ja     802dd0 <__udivdi3+0x50>
  802de8:	0f bd cf             	bsr    %edi,%ecx
  802deb:	83 f1 1f             	xor    $0x1f,%ecx
  802dee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802df2:	75 2c                	jne    802e20 <__udivdi3+0xa0>
  802df4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802df8:	76 04                	jbe    802dfe <__udivdi3+0x7e>
  802dfa:	39 f7                	cmp    %esi,%edi
  802dfc:	73 d2                	jae    802dd0 <__udivdi3+0x50>
  802dfe:	31 d2                	xor    %edx,%edx
  802e00:	b8 01 00 00 00       	mov    $0x1,%eax
  802e05:	eb c9                	jmp    802dd0 <__udivdi3+0x50>
  802e07:	90                   	nop
  802e08:	89 f2                	mov    %esi,%edx
  802e0a:	f7 f1                	div    %ecx
  802e0c:	31 d2                	xor    %edx,%edx
  802e0e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802e12:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802e16:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802e1a:	83 c4 1c             	add    $0x1c,%esp
  802e1d:	c3                   	ret    
  802e1e:	66 90                	xchg   %ax,%ax
  802e20:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e25:	b8 20 00 00 00       	mov    $0x20,%eax
  802e2a:	89 ea                	mov    %ebp,%edx
  802e2c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802e30:	d3 e7                	shl    %cl,%edi
  802e32:	89 c1                	mov    %eax,%ecx
  802e34:	d3 ea                	shr    %cl,%edx
  802e36:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e3b:	09 fa                	or     %edi,%edx
  802e3d:	89 f7                	mov    %esi,%edi
  802e3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802e43:	89 f2                	mov    %esi,%edx
  802e45:	8b 74 24 08          	mov    0x8(%esp),%esi
  802e49:	d3 e5                	shl    %cl,%ebp
  802e4b:	89 c1                	mov    %eax,%ecx
  802e4d:	d3 ef                	shr    %cl,%edi
  802e4f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e54:	d3 e2                	shl    %cl,%edx
  802e56:	89 c1                	mov    %eax,%ecx
  802e58:	d3 ee                	shr    %cl,%esi
  802e5a:	09 d6                	or     %edx,%esi
  802e5c:	89 fa                	mov    %edi,%edx
  802e5e:	89 f0                	mov    %esi,%eax
  802e60:	f7 74 24 0c          	divl   0xc(%esp)
  802e64:	89 d7                	mov    %edx,%edi
  802e66:	89 c6                	mov    %eax,%esi
  802e68:	f7 e5                	mul    %ebp
  802e6a:	39 d7                	cmp    %edx,%edi
  802e6c:	72 22                	jb     802e90 <__udivdi3+0x110>
  802e6e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802e72:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e77:	d3 e5                	shl    %cl,%ebp
  802e79:	39 c5                	cmp    %eax,%ebp
  802e7b:	73 04                	jae    802e81 <__udivdi3+0x101>
  802e7d:	39 d7                	cmp    %edx,%edi
  802e7f:	74 0f                	je     802e90 <__udivdi3+0x110>
  802e81:	89 f0                	mov    %esi,%eax
  802e83:	31 d2                	xor    %edx,%edx
  802e85:	e9 46 ff ff ff       	jmp    802dd0 <__udivdi3+0x50>
  802e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802e90:	8d 46 ff             	lea    -0x1(%esi),%eax
  802e93:	31 d2                	xor    %edx,%edx
  802e95:	8b 74 24 10          	mov    0x10(%esp),%esi
  802e99:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802e9d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802ea1:	83 c4 1c             	add    $0x1c,%esp
  802ea4:	c3                   	ret    
	...

00802eb0 <__umoddi3>:
  802eb0:	83 ec 1c             	sub    $0x1c,%esp
  802eb3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802eb7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  802ebb:	8b 44 24 20          	mov    0x20(%esp),%eax
  802ebf:	89 74 24 10          	mov    %esi,0x10(%esp)
  802ec3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802ec7:	8b 74 24 24          	mov    0x24(%esp),%esi
  802ecb:	85 ed                	test   %ebp,%ebp
  802ecd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802ed1:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ed5:	89 cf                	mov    %ecx,%edi
  802ed7:	89 04 24             	mov    %eax,(%esp)
  802eda:	89 f2                	mov    %esi,%edx
  802edc:	75 1a                	jne    802ef8 <__umoddi3+0x48>
  802ede:	39 f1                	cmp    %esi,%ecx
  802ee0:	76 4e                	jbe    802f30 <__umoddi3+0x80>
  802ee2:	f7 f1                	div    %ecx
  802ee4:	89 d0                	mov    %edx,%eax
  802ee6:	31 d2                	xor    %edx,%edx
  802ee8:	8b 74 24 10          	mov    0x10(%esp),%esi
  802eec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802ef0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802ef4:	83 c4 1c             	add    $0x1c,%esp
  802ef7:	c3                   	ret    
  802ef8:	39 f5                	cmp    %esi,%ebp
  802efa:	77 54                	ja     802f50 <__umoddi3+0xa0>
  802efc:	0f bd c5             	bsr    %ebp,%eax
  802eff:	83 f0 1f             	xor    $0x1f,%eax
  802f02:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f06:	75 60                	jne    802f68 <__umoddi3+0xb8>
  802f08:	3b 0c 24             	cmp    (%esp),%ecx
  802f0b:	0f 87 07 01 00 00    	ja     803018 <__umoddi3+0x168>
  802f11:	89 f2                	mov    %esi,%edx
  802f13:	8b 34 24             	mov    (%esp),%esi
  802f16:	29 ce                	sub    %ecx,%esi
  802f18:	19 ea                	sbb    %ebp,%edx
  802f1a:	89 34 24             	mov    %esi,(%esp)
  802f1d:	8b 04 24             	mov    (%esp),%eax
  802f20:	8b 74 24 10          	mov    0x10(%esp),%esi
  802f24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802f28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802f2c:	83 c4 1c             	add    $0x1c,%esp
  802f2f:	c3                   	ret    
  802f30:	85 c9                	test   %ecx,%ecx
  802f32:	75 0b                	jne    802f3f <__umoddi3+0x8f>
  802f34:	b8 01 00 00 00       	mov    $0x1,%eax
  802f39:	31 d2                	xor    %edx,%edx
  802f3b:	f7 f1                	div    %ecx
  802f3d:	89 c1                	mov    %eax,%ecx
  802f3f:	89 f0                	mov    %esi,%eax
  802f41:	31 d2                	xor    %edx,%edx
  802f43:	f7 f1                	div    %ecx
  802f45:	8b 04 24             	mov    (%esp),%eax
  802f48:	f7 f1                	div    %ecx
  802f4a:	eb 98                	jmp    802ee4 <__umoddi3+0x34>
  802f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802f50:	89 f2                	mov    %esi,%edx
  802f52:	8b 74 24 10          	mov    0x10(%esp),%esi
  802f56:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802f5a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802f5e:	83 c4 1c             	add    $0x1c,%esp
  802f61:	c3                   	ret    
  802f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802f68:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802f6d:	89 e8                	mov    %ebp,%eax
  802f6f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802f74:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802f78:	89 fa                	mov    %edi,%edx
  802f7a:	d3 e0                	shl    %cl,%eax
  802f7c:	89 e9                	mov    %ebp,%ecx
  802f7e:	d3 ea                	shr    %cl,%edx
  802f80:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802f85:	09 c2                	or     %eax,%edx
  802f87:	8b 44 24 08          	mov    0x8(%esp),%eax
  802f8b:	89 14 24             	mov    %edx,(%esp)
  802f8e:	89 f2                	mov    %esi,%edx
  802f90:	d3 e7                	shl    %cl,%edi
  802f92:	89 e9                	mov    %ebp,%ecx
  802f94:	d3 ea                	shr    %cl,%edx
  802f96:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802f9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802f9f:	d3 e6                	shl    %cl,%esi
  802fa1:	89 e9                	mov    %ebp,%ecx
  802fa3:	d3 e8                	shr    %cl,%eax
  802fa5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802faa:	09 f0                	or     %esi,%eax
  802fac:	8b 74 24 08          	mov    0x8(%esp),%esi
  802fb0:	f7 34 24             	divl   (%esp)
  802fb3:	d3 e6                	shl    %cl,%esi
  802fb5:	89 74 24 08          	mov    %esi,0x8(%esp)
  802fb9:	89 d6                	mov    %edx,%esi
  802fbb:	f7 e7                	mul    %edi
  802fbd:	39 d6                	cmp    %edx,%esi
  802fbf:	89 c1                	mov    %eax,%ecx
  802fc1:	89 d7                	mov    %edx,%edi
  802fc3:	72 3f                	jb     803004 <__umoddi3+0x154>
  802fc5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802fc9:	72 35                	jb     803000 <__umoddi3+0x150>
  802fcb:	8b 44 24 08          	mov    0x8(%esp),%eax
  802fcf:	29 c8                	sub    %ecx,%eax
  802fd1:	19 fe                	sbb    %edi,%esi
  802fd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802fd8:	89 f2                	mov    %esi,%edx
  802fda:	d3 e8                	shr    %cl,%eax
  802fdc:	89 e9                	mov    %ebp,%ecx
  802fde:	d3 e2                	shl    %cl,%edx
  802fe0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802fe5:	09 d0                	or     %edx,%eax
  802fe7:	89 f2                	mov    %esi,%edx
  802fe9:	d3 ea                	shr    %cl,%edx
  802feb:	8b 74 24 10          	mov    0x10(%esp),%esi
  802fef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802ff3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802ff7:	83 c4 1c             	add    $0x1c,%esp
  802ffa:	c3                   	ret    
  802ffb:	90                   	nop
  802ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803000:	39 d6                	cmp    %edx,%esi
  803002:	75 c7                	jne    802fcb <__umoddi3+0x11b>
  803004:	89 d7                	mov    %edx,%edi
  803006:	89 c1                	mov    %eax,%ecx
  803008:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80300c:	1b 3c 24             	sbb    (%esp),%edi
  80300f:	eb ba                	jmp    802fcb <__umoddi3+0x11b>
  803011:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803018:	39 f5                	cmp    %esi,%ebp
  80301a:	0f 82 f1 fe ff ff    	jb     802f11 <__umoddi3+0x61>
  803020:	e9 f8 fe ff ff       	jmp    802f1d <__umoddi3+0x6d>
