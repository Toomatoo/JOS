
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 51 00 00 00       	call   8000a0 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 04 20 80 00    	mov    %ecx,0x802004

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 61 00 00 00       	call   8000ff <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000cb:	89 ec                	mov    %ebp,%esp
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000fb:	89 ec                	mov    %ebp,%esp
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 38             	sub    $0x38,%esp
  800105:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800108:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7e 28                	jle    80014f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800132:	00 
  800133:	c7 44 24 08 80 10 80 	movl   $0x801080,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 9d 10 80 00 	movl   $0x80109d,(%esp)
  80014a:	e8 3d 00 00 00       	call   80018c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800152:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800155:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800158:	89 ec                	mov    %ebp,%esp
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800165:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800168:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800182:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800185:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800188:	89 ec                	mov    %ebp,%esp
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

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
  800197:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80019d:	e8 ba ff ff ff       	call   80015c <sys_getenvid>
  8001a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8001bf:	e8 c3 00 00 00       	call   800287 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 53 00 00 00       	call   800226 <vcprintf>
	cprintf("\n");
  8001d3:	c7 04 24 74 10 80 00 	movl   $0x801074,(%esp)
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
  800211:	e8 8a fe ff ff       	call   8000a0 <sys_cputs>
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
  80027a:	e8 21 fe ff ff       	call   8000a0 <sys_cputs>

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
  80030e:	e8 ad 0a 00 00       	call   800dc0 <__udivdi3>
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
  800361:	e8 8a 0b 00 00       	call   800ef0 <__umoddi3>
  800366:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036a:	0f be 80 d0 10 80 00 	movsbl 0x8010d0(%eax),%eax
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
  800492:	ff 24 85 78 11 80 00 	jmp    *0x801178(,%eax,4)
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
  800566:	a3 08 20 80 00       	mov    %eax,0x802008
  80056b:	e9 b1 fe ff ff       	jmp    800421 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800570:	c7 44 24 04 e8 10 80 	movl   $0x8010e8,0x4(%esp)
  800577:	00 
  800578:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	e8 18 05 00 00       	call   800a9b <strcmp>
  800583:	85 c0                	test   %eax,%eax
  800585:	75 0f                	jne    800596 <vprintfmt+0x198>
  800587:	c7 05 08 20 80 00 04 	movl   $0x4,0x802008
  80058e:	00 00 00 
  800591:	e9 8b fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800596:	c7 44 24 04 ec 10 80 	movl   $0x8010ec,0x4(%esp)
  80059d:	00 
  80059e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005a1:	89 14 24             	mov    %edx,(%esp)
  8005a4:	e8 f2 04 00 00       	call   800a9b <strcmp>
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	75 0f                	jne    8005bc <vprintfmt+0x1be>
  8005ad:	c7 05 08 20 80 00 02 	movl   $0x2,0x802008
  8005b4:	00 00 00 
  8005b7:	e9 65 fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005bc:	c7 44 24 04 f0 10 80 	movl   $0x8010f0,0x4(%esp)
  8005c3:	00 
  8005c4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005c7:	89 0c 24             	mov    %ecx,(%esp)
  8005ca:	e8 cc 04 00 00       	call   800a9b <strcmp>
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	75 0f                	jne    8005e2 <vprintfmt+0x1e4>
  8005d3:	c7 05 08 20 80 00 01 	movl   $0x1,0x802008
  8005da:	00 00 00 
  8005dd:	e9 3f fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005e2:	c7 44 24 04 f4 10 80 	movl   $0x8010f4,0x4(%esp)
  8005e9:	00 
  8005ea:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005ed:	89 3c 24             	mov    %edi,(%esp)
  8005f0:	e8 a6 04 00 00       	call   800a9b <strcmp>
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	75 0f                	jne    800608 <vprintfmt+0x20a>
  8005f9:	c7 05 08 20 80 00 06 	movl   $0x6,0x802008
  800600:	00 00 00 
  800603:	e9 19 fe ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800608:	c7 44 24 04 f8 10 80 	movl   $0x8010f8,0x4(%esp)
  80060f:	00 
  800610:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	e8 80 04 00 00       	call   800a9b <strcmp>
  80061b:	85 c0                	test   %eax,%eax
  80061d:	75 0f                	jne    80062e <vprintfmt+0x230>
  80061f:	c7 05 08 20 80 00 07 	movl   $0x7,0x802008
  800626:	00 00 00 
  800629:	e9 f3 fd ff ff       	jmp    800421 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80062e:	c7 44 24 04 fc 10 80 	movl   $0x8010fc,0x4(%esp)
  800635:	00 
  800636:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800639:	89 14 24             	mov    %edx,(%esp)
  80063c:	e8 5a 04 00 00       	call   800a9b <strcmp>
  800641:	83 f8 01             	cmp    $0x1,%eax
  800644:	19 c0                	sbb    %eax,%eax
  800646:	f7 d0                	not    %eax
  800648:	83 c0 08             	add    $0x8,%eax
  80064b:	a3 08 20 80 00       	mov    %eax,0x802008
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
  800669:	83 f8 06             	cmp    $0x6,%eax
  80066c:	7f 0b                	jg     800679 <vprintfmt+0x27b>
  80066e:	8b 14 85 d0 12 80 00 	mov    0x8012d0(,%eax,4),%edx
  800675:	85 d2                	test   %edx,%edx
  800677:	75 23                	jne    80069c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800679:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067d:	c7 44 24 08 00 11 80 	movl   $0x801100,0x8(%esp)
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
  8006a0:	c7 44 24 08 09 11 80 	movl   $0x801109,0x8(%esp)
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
  8006d5:	b8 e1 10 80 00       	mov    $0x8010e1,%eax
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

00800dc0 <__udivdi3>:
  800dc0:	83 ec 1c             	sub    $0x1c,%esp
  800dc3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800dc7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800dcb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800dcf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800dd3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800dd7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ddb:	85 ff                	test   %edi,%edi
  800ddd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800de1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de5:	89 cd                	mov    %ecx,%ebp
  800de7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800deb:	75 33                	jne    800e20 <__udivdi3+0x60>
  800ded:	39 f1                	cmp    %esi,%ecx
  800def:	77 57                	ja     800e48 <__udivdi3+0x88>
  800df1:	85 c9                	test   %ecx,%ecx
  800df3:	75 0b                	jne    800e00 <__udivdi3+0x40>
  800df5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfa:	31 d2                	xor    %edx,%edx
  800dfc:	f7 f1                	div    %ecx
  800dfe:	89 c1                	mov    %eax,%ecx
  800e00:	89 f0                	mov    %esi,%eax
  800e02:	31 d2                	xor    %edx,%edx
  800e04:	f7 f1                	div    %ecx
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e0c:	f7 f1                	div    %ecx
  800e0e:	89 f2                	mov    %esi,%edx
  800e10:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e14:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e18:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	c3                   	ret    
  800e20:	31 d2                	xor    %edx,%edx
  800e22:	31 c0                	xor    %eax,%eax
  800e24:	39 f7                	cmp    %esi,%edi
  800e26:	77 e8                	ja     800e10 <__udivdi3+0x50>
  800e28:	0f bd cf             	bsr    %edi,%ecx
  800e2b:	83 f1 1f             	xor    $0x1f,%ecx
  800e2e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e32:	75 2c                	jne    800e60 <__udivdi3+0xa0>
  800e34:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800e38:	76 04                	jbe    800e3e <__udivdi3+0x7e>
  800e3a:	39 f7                	cmp    %esi,%edi
  800e3c:	73 d2                	jae    800e10 <__udivdi3+0x50>
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	b8 01 00 00 00       	mov    $0x1,%eax
  800e45:	eb c9                	jmp    800e10 <__udivdi3+0x50>
  800e47:	90                   	nop
  800e48:	89 f2                	mov    %esi,%edx
  800e4a:	f7 f1                	div    %ecx
  800e4c:	31 d2                	xor    %edx,%edx
  800e4e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e52:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e56:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	c3                   	ret    
  800e5e:	66 90                	xchg   %ax,%ax
  800e60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e65:	b8 20 00 00 00       	mov    $0x20,%eax
  800e6a:	89 ea                	mov    %ebp,%edx
  800e6c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e70:	d3 e7                	shl    %cl,%edi
  800e72:	89 c1                	mov    %eax,%ecx
  800e74:	d3 ea                	shr    %cl,%edx
  800e76:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e7b:	09 fa                	or     %edi,%edx
  800e7d:	89 f7                	mov    %esi,%edi
  800e7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e83:	89 f2                	mov    %esi,%edx
  800e85:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e89:	d3 e5                	shl    %cl,%ebp
  800e8b:	89 c1                	mov    %eax,%ecx
  800e8d:	d3 ef                	shr    %cl,%edi
  800e8f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e94:	d3 e2                	shl    %cl,%edx
  800e96:	89 c1                	mov    %eax,%ecx
  800e98:	d3 ee                	shr    %cl,%esi
  800e9a:	09 d6                	or     %edx,%esi
  800e9c:	89 fa                	mov    %edi,%edx
  800e9e:	89 f0                	mov    %esi,%eax
  800ea0:	f7 74 24 0c          	divl   0xc(%esp)
  800ea4:	89 d7                	mov    %edx,%edi
  800ea6:	89 c6                	mov    %eax,%esi
  800ea8:	f7 e5                	mul    %ebp
  800eaa:	39 d7                	cmp    %edx,%edi
  800eac:	72 22                	jb     800ed0 <__udivdi3+0x110>
  800eae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800eb2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eb7:	d3 e5                	shl    %cl,%ebp
  800eb9:	39 c5                	cmp    %eax,%ebp
  800ebb:	73 04                	jae    800ec1 <__udivdi3+0x101>
  800ebd:	39 d7                	cmp    %edx,%edi
  800ebf:	74 0f                	je     800ed0 <__udivdi3+0x110>
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	e9 46 ff ff ff       	jmp    800e10 <__udivdi3+0x50>
  800eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ed9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800edd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	c3                   	ret    
	...

00800ef0 <__umoddi3>:
  800ef0:	83 ec 1c             	sub    $0x1c,%esp
  800ef3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ef7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800efb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800eff:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f03:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f07:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f0b:	85 ed                	test   %ebp,%ebp
  800f0d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f15:	89 cf                	mov    %ecx,%edi
  800f17:	89 04 24             	mov    %eax,(%esp)
  800f1a:	89 f2                	mov    %esi,%edx
  800f1c:	75 1a                	jne    800f38 <__umoddi3+0x48>
  800f1e:	39 f1                	cmp    %esi,%ecx
  800f20:	76 4e                	jbe    800f70 <__umoddi3+0x80>
  800f22:	f7 f1                	div    %ecx
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	31 d2                	xor    %edx,%edx
  800f28:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f2c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f30:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f34:	83 c4 1c             	add    $0x1c,%esp
  800f37:	c3                   	ret    
  800f38:	39 f5                	cmp    %esi,%ebp
  800f3a:	77 54                	ja     800f90 <__umoddi3+0xa0>
  800f3c:	0f bd c5             	bsr    %ebp,%eax
  800f3f:	83 f0 1f             	xor    $0x1f,%eax
  800f42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f46:	75 60                	jne    800fa8 <__umoddi3+0xb8>
  800f48:	3b 0c 24             	cmp    (%esp),%ecx
  800f4b:	0f 87 07 01 00 00    	ja     801058 <__umoddi3+0x168>
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	8b 34 24             	mov    (%esp),%esi
  800f56:	29 ce                	sub    %ecx,%esi
  800f58:	19 ea                	sbb    %ebp,%edx
  800f5a:	89 34 24             	mov    %esi,(%esp)
  800f5d:	8b 04 24             	mov    (%esp),%eax
  800f60:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f64:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f68:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f6c:	83 c4 1c             	add    $0x1c,%esp
  800f6f:	c3                   	ret    
  800f70:	85 c9                	test   %ecx,%ecx
  800f72:	75 0b                	jne    800f7f <__umoddi3+0x8f>
  800f74:	b8 01 00 00 00       	mov    $0x1,%eax
  800f79:	31 d2                	xor    %edx,%edx
  800f7b:	f7 f1                	div    %ecx
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	89 f0                	mov    %esi,%eax
  800f81:	31 d2                	xor    %edx,%edx
  800f83:	f7 f1                	div    %ecx
  800f85:	8b 04 24             	mov    (%esp),%eax
  800f88:	f7 f1                	div    %ecx
  800f8a:	eb 98                	jmp    800f24 <__umoddi3+0x34>
  800f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f96:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f9a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f9e:	83 c4 1c             	add    $0x1c,%esp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fad:	89 e8                	mov    %ebp,%eax
  800faf:	bd 20 00 00 00       	mov    $0x20,%ebp
  800fb4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800fb8:	89 fa                	mov    %edi,%edx
  800fba:	d3 e0                	shl    %cl,%eax
  800fbc:	89 e9                	mov    %ebp,%ecx
  800fbe:	d3 ea                	shr    %cl,%edx
  800fc0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fc5:	09 c2                	or     %eax,%edx
  800fc7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fcb:	89 14 24             	mov    %edx,(%esp)
  800fce:	89 f2                	mov    %esi,%edx
  800fd0:	d3 e7                	shl    %cl,%edi
  800fd2:	89 e9                	mov    %ebp,%ecx
  800fd4:	d3 ea                	shr    %cl,%edx
  800fd6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	d3 e6                	shl    %cl,%esi
  800fe1:	89 e9                	mov    %ebp,%ecx
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fea:	09 f0                	or     %esi,%eax
  800fec:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ff0:	f7 34 24             	divl   (%esp)
  800ff3:	d3 e6                	shl    %cl,%esi
  800ff5:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ff9:	89 d6                	mov    %edx,%esi
  800ffb:	f7 e7                	mul    %edi
  800ffd:	39 d6                	cmp    %edx,%esi
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	89 d7                	mov    %edx,%edi
  801003:	72 3f                	jb     801044 <__umoddi3+0x154>
  801005:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801009:	72 35                	jb     801040 <__umoddi3+0x150>
  80100b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80100f:	29 c8                	sub    %ecx,%eax
  801011:	19 fe                	sbb    %edi,%esi
  801013:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801018:	89 f2                	mov    %esi,%edx
  80101a:	d3 e8                	shr    %cl,%eax
  80101c:	89 e9                	mov    %ebp,%ecx
  80101e:	d3 e2                	shl    %cl,%edx
  801020:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801025:	09 d0                	or     %edx,%eax
  801027:	89 f2                	mov    %esi,%edx
  801029:	d3 ea                	shr    %cl,%edx
  80102b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80102f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801033:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801037:	83 c4 1c             	add    $0x1c,%esp
  80103a:	c3                   	ret    
  80103b:	90                   	nop
  80103c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801040:	39 d6                	cmp    %edx,%esi
  801042:	75 c7                	jne    80100b <__umoddi3+0x11b>
  801044:	89 d7                	mov    %edx,%edi
  801046:	89 c1                	mov    %eax,%ecx
  801048:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80104c:	1b 3c 24             	sbb    (%esp),%edi
  80104f:	eb ba                	jmp    80100b <__umoddi3+0x11b>
  801051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801058:	39 f5                	cmp    %esi,%ebp
  80105a:	0f 82 f1 fe ff ff    	jb     800f51 <__umoddi3+0x61>
  801060:	e9 f8 fe ff ff       	jmp    800f5d <__umoddi3+0x6d>