
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	8b 45 08             	mov    0x8(%ebp),%eax
  800045:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80004f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	7e 08                	jle    80005e <libmain+0x22>
		binaryname = argv[0];
  800056:	8b 0a                	mov    (%edx),%ecx
  800058:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800062:	89 04 24             	mov    %eax,(%esp)
  800065:	e8 ca ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	c9                   	leave  
  800070:	c3                   	ret    
  800071:	00 00                	add    %al,(%eax)
	...

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800081:	e8 61 00 00 00       	call   8000e7 <sys_env_destroy>
}
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800091:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800094:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000ad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000b0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 0c             	sub    $0xc,%esp
  8000bd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 38             	sub    $0x38,%esp
  8000ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 28                	jle    800137 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800113:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011a:	00 
  80011b:	c7 44 24 08 52 10 80 	movl   $0x801052,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800132:	e8 3d 00 00 00       	call   800174 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80013a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80013d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800140:	89 ec                	mov    %ebp,%esp
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80014d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800150:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 02 00 00 00       	mov    $0x2,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800167:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80016d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80017c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800185:	e8 ba ff ff ff       	call   800144 <sys_getenvid>
  80018a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800191:	8b 55 08             	mov    0x8(%ebp),%edx
  800194:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800198:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a0:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  8001a7:	e8 c3 00 00 00       	call   80026f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 53 00 00 00       	call   80020e <vcprintf>
	cprintf("\n");
  8001bb:	c7 04 24 a4 10 80 00 	movl   $0x8010a4,(%esp)
  8001c2:	e8 a8 00 00 00       	call   80026f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c7:	cc                   	int3   
  8001c8:	eb fd                	jmp    8001c7 <_panic+0x53>
	...

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 14             	sub    $0x14,%esp
  8001d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d6:	8b 03                	mov    (%ebx),%eax
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001df:	83 c0 01             	add    $0x1,%eax
  8001e2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e9:	75 19                	jne    800204 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f2:	00 
  8001f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f6:	89 04 24             	mov    %eax,(%esp)
  8001f9:	e8 8a fe ff ff       	call   800088 <sys_cputs>
		b->idx = 0;
  8001fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800204:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800208:	83 c4 14             	add    $0x14,%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800217:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021e:	00 00 00 
	b.cnt = 0;
  800221:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800228:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 44 24 08          	mov    %eax,0x8(%esp)
  800239:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800243:	c7 04 24 cc 01 80 00 	movl   $0x8001cc,(%esp)
  80024a:	e8 97 01 00 00       	call   8003e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 21 fe ff ff       	call   800088 <sys_cputs>

	return b.cnt;
}
  800267:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800275:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027c:	8b 45 08             	mov    0x8(%ebp),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	e8 87 ff ff ff       	call   80020e <vcprintf>
	va_end(ap);

	return cnt;
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    
  800289:	00 00                	add    %al,(%eax)
	...

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	89 d7                	mov    %edx,%edi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b4:	72 11                	jb     8002c7 <printnum+0x3b>
  8002b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bc:	76 09                	jbe    8002c7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	85 db                	test   %ebx,%ebx
  8002c3:	7f 51                	jg     800316 <printnum+0x8a>
  8002c5:	eb 5e                	jmp    800325 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002cb:	83 eb 01             	sub    $0x1,%ebx
  8002ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002dd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e8:	00 
  8002e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ec:	89 04 24             	mov    %eax,(%esp)
  8002ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f6:	e8 a5 0a 00 00       	call   800da0 <__udivdi3>
  8002fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030a:	89 fa                	mov    %edi,%edx
  80030c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030f:	e8 78 ff ff ff       	call   80028c <printnum>
  800314:	eb 0f                	jmp    800325 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800316:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031a:	89 34 24             	mov    %esi,(%esp)
  80031d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800320:	83 eb 01             	sub    $0x1,%ebx
  800323:	75 f1                	jne    800316 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800329:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80032d:	8b 45 10             	mov    0x10(%ebp),%eax
  800330:	89 44 24 08          	mov    %eax,0x8(%esp)
  800334:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033b:	00 
  80033c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 44 24 04          	mov    %eax,0x4(%esp)
  800349:	e8 82 0b 00 00       	call   800ed0 <__umoddi3>
  80034e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800352:	0f be 80 a6 10 80 00 	movsbl 0x8010a6(%eax),%eax
  800359:	89 04 24             	mov    %eax,(%esp)
  80035c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80035f:	83 c4 3c             	add    $0x3c,%esp
  800362:	5b                   	pop    %ebx
  800363:	5e                   	pop    %esi
  800364:	5f                   	pop    %edi
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036a:	83 fa 01             	cmp    $0x1,%edx
  80036d:	7e 0e                	jle    80037d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	8d 4a 08             	lea    0x8(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 02                	mov    (%edx),%eax
  800378:	8b 52 04             	mov    0x4(%edx),%edx
  80037b:	eb 22                	jmp    80039f <getuint+0x38>
	else if (lflag)
  80037d:	85 d2                	test   %edx,%edx
  80037f:	74 10                	je     800391 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800381:	8b 10                	mov    (%eax),%edx
  800383:	8d 4a 04             	lea    0x4(%edx),%ecx
  800386:	89 08                	mov    %ecx,(%eax)
  800388:	8b 02                	mov    (%edx),%eax
  80038a:	ba 00 00 00 00       	mov    $0x0,%edx
  80038f:	eb 0e                	jmp    80039f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800391:	8b 10                	mov    (%eax),%edx
  800393:	8d 4a 04             	lea    0x4(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 02                	mov    (%edx),%eax
  80039a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b0:	73 0a                	jae    8003bc <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b5:	88 0a                	mov    %cl,(%edx)
  8003b7:	83 c2 01             	add    $0x1,%edx
  8003ba:	89 10                	mov    %edx,(%eax)
}
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    

008003be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dc:	89 04 24             	mov    %eax,(%esp)
  8003df:	e8 02 00 00 00       	call   8003e6 <vprintfmt>
	va_end(ap);
}
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	57                   	push   %edi
  8003ea:	56                   	push   %esi
  8003eb:	53                   	push   %ebx
  8003ec:	83 ec 5c             	sub    $0x5c,%esp
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f5:	eb 12                	jmp    800409 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	0f 84 e4 04 00 00    	je     8008e3 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800403:	89 04 24             	mov    %eax,(%esp)
  800406:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800409:	0f b6 06             	movzbl (%esi),%eax
  80040c:	83 c6 01             	add    $0x1,%esi
  80040f:	83 f8 25             	cmp    $0x25,%eax
  800412:	75 e3                	jne    8003f7 <vprintfmt+0x11>
  800414:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800418:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80041f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800424:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80042b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800430:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800433:	eb 2b                	jmp    800460 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800438:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80043c:	eb 22                	jmp    800460 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800441:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800445:	eb 19                	jmp    800460 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80044a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800451:	eb 0d                	jmp    800460 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800453:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800456:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800459:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	0f b6 06             	movzbl (%esi),%eax
  800463:	0f b6 d0             	movzbl %al,%edx
  800466:	8d 7e 01             	lea    0x1(%esi),%edi
  800469:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046c:	83 e8 23             	sub    $0x23,%eax
  80046f:	3c 55                	cmp    $0x55,%al
  800471:	0f 87 46 04 00 00    	ja     8008bd <vprintfmt+0x4d7>
  800477:	0f b6 c0             	movzbl %al,%eax
  80047a:	ff 24 85 4c 11 80 00 	jmp    *0x80114c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800481:	83 ea 30             	sub    $0x30,%edx
  800484:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800487:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80048b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800491:	83 fa 09             	cmp    $0x9,%edx
  800494:	77 4a                	ja     8004e0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800499:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80049c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80049f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004a3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004a9:	83 fa 09             	cmp    $0x9,%edx
  8004ac:	76 eb                	jbe    800499 <vprintfmt+0xb3>
  8004ae:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004b1:	eb 2d                	jmp    8004e0 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 50 04             	lea    0x4(%eax),%edx
  8004b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bc:	8b 00                	mov    (%eax),%eax
  8004be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c4:	eb 1a                	jmp    8004e0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004c9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004cd:	79 91                	jns    800460 <vprintfmt+0x7a>
  8004cf:	e9 73 ff ff ff       	jmp    800447 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004de:	eb 80                	jmp    800460 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004e0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e4:	0f 89 76 ff ff ff    	jns    800460 <vprintfmt+0x7a>
  8004ea:	e9 64 ff ff ff       	jmp    800453 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f5:	e9 66 ff ff ff       	jmp    800460 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 04 24             	mov    %eax,(%esp)
  80050c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800512:	e9 f2 fe ff ff       	jmp    800409 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800517:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80051b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80051e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800522:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800525:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800529:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80052c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80052f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800533:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800536:	80 f9 09             	cmp    $0x9,%cl
  800539:	77 1d                	ja     800558 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80053b:	0f be c0             	movsbl %al,%eax
  80053e:	6b c0 64             	imul   $0x64,%eax,%eax
  800541:	0f be d2             	movsbl %dl,%edx
  800544:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800547:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80054e:	a3 04 20 80 00       	mov    %eax,0x802004
  800553:	e9 b1 fe ff ff       	jmp    800409 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800558:	c7 44 24 04 be 10 80 	movl   $0x8010be,0x4(%esp)
  80055f:	00 
  800560:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800563:	89 04 24             	mov    %eax,(%esp)
  800566:	e8 10 05 00 00       	call   800a7b <strcmp>
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 0f                	jne    80057e <vprintfmt+0x198>
  80056f:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800576:	00 00 00 
  800579:	e9 8b fe ff ff       	jmp    800409 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80057e:	c7 44 24 04 c2 10 80 	movl   $0x8010c2,0x4(%esp)
  800585:	00 
  800586:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800589:	89 14 24             	mov    %edx,(%esp)
  80058c:	e8 ea 04 00 00       	call   800a7b <strcmp>
  800591:	85 c0                	test   %eax,%eax
  800593:	75 0f                	jne    8005a4 <vprintfmt+0x1be>
  800595:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  80059c:	00 00 00 
  80059f:	e9 65 fe ff ff       	jmp    800409 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005a4:	c7 44 24 04 c6 10 80 	movl   $0x8010c6,0x4(%esp)
  8005ab:	00 
  8005ac:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005af:	89 0c 24             	mov    %ecx,(%esp)
  8005b2:	e8 c4 04 00 00       	call   800a7b <strcmp>
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	75 0f                	jne    8005ca <vprintfmt+0x1e4>
  8005bb:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005c2:	00 00 00 
  8005c5:	e9 3f fe ff ff       	jmp    800409 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005ca:	c7 44 24 04 ca 10 80 	movl   $0x8010ca,0x4(%esp)
  8005d1:	00 
  8005d2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005d5:	89 3c 24             	mov    %edi,(%esp)
  8005d8:	e8 9e 04 00 00       	call   800a7b <strcmp>
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	75 0f                	jne    8005f0 <vprintfmt+0x20a>
  8005e1:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005e8:	00 00 00 
  8005eb:	e9 19 fe ff ff       	jmp    800409 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005f0:	c7 44 24 04 ce 10 80 	movl   $0x8010ce,0x4(%esp)
  8005f7:	00 
  8005f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	e8 78 04 00 00       	call   800a7b <strcmp>
  800603:	85 c0                	test   %eax,%eax
  800605:	75 0f                	jne    800616 <vprintfmt+0x230>
  800607:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80060e:	00 00 00 
  800611:	e9 f3 fd ff ff       	jmp    800409 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800616:	c7 44 24 04 d2 10 80 	movl   $0x8010d2,0x4(%esp)
  80061d:	00 
  80061e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800621:	89 14 24             	mov    %edx,(%esp)
  800624:	e8 52 04 00 00       	call   800a7b <strcmp>
  800629:	83 f8 01             	cmp    $0x1,%eax
  80062c:	19 c0                	sbb    %eax,%eax
  80062e:	f7 d0                	not    %eax
  800630:	83 c0 08             	add    $0x8,%eax
  800633:	a3 04 20 80 00       	mov    %eax,0x802004
  800638:	e9 cc fd ff ff       	jmp    800409 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	89 c2                	mov    %eax,%edx
  80064a:	c1 fa 1f             	sar    $0x1f,%edx
  80064d:	31 d0                	xor    %edx,%eax
  80064f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800651:	83 f8 06             	cmp    $0x6,%eax
  800654:	7f 0b                	jg     800661 <vprintfmt+0x27b>
  800656:	8b 14 85 a4 12 80 00 	mov    0x8012a4(,%eax,4),%edx
  80065d:	85 d2                	test   %edx,%edx
  80065f:	75 23                	jne    800684 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800661:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800665:	c7 44 24 08 d6 10 80 	movl   $0x8010d6,0x8(%esp)
  80066c:	00 
  80066d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800671:	8b 7d 08             	mov    0x8(%ebp),%edi
  800674:	89 3c 24             	mov    %edi,(%esp)
  800677:	e8 42 fd ff ff       	call   8003be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067f:	e9 85 fd ff ff       	jmp    800409 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800684:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800688:	c7 44 24 08 df 10 80 	movl   $0x8010df,0x8(%esp)
  80068f:	00 
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	8b 7d 08             	mov    0x8(%ebp),%edi
  800697:	89 3c 24             	mov    %edi,(%esp)
  80069a:	e8 1f fd ff ff       	call   8003be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006a2:	e9 62 fd ff ff       	jmp    800409 <vprintfmt+0x23>
  8006a7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006bb:	85 f6                	test   %esi,%esi
  8006bd:	b8 b7 10 80 00       	mov    $0x8010b7,%eax
  8006c2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006c5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006c9:	7e 06                	jle    8006d1 <vprintfmt+0x2eb>
  8006cb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006cf:	75 13                	jne    8006e4 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d1:	0f be 06             	movsbl (%esi),%eax
  8006d4:	83 c6 01             	add    $0x1,%esi
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	0f 85 94 00 00 00    	jne    800773 <vprintfmt+0x38d>
  8006df:	e9 81 00 00 00       	jmp    800765 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e8:	89 34 24             	mov    %esi,(%esp)
  8006eb:	e8 9b 02 00 00       	call   80098b <strnlen>
  8006f0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	7e d5                	jle    8006d1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006fc:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800700:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800703:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800706:	89 d6                	mov    %edx,%esi
  800708:	89 cf                	mov    %ecx,%edi
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	89 3c 24             	mov    %edi,(%esp)
  800711:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	83 ee 01             	sub    $0x1,%esi
  800717:	75 f1                	jne    80070a <vprintfmt+0x324>
  800719:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80071c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80071f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800722:	eb ad                	jmp    8006d1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800724:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800728:	74 1b                	je     800745 <vprintfmt+0x35f>
  80072a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80072d:	83 fa 5e             	cmp    $0x5e,%edx
  800730:	76 13                	jbe    800745 <vprintfmt+0x35f>
					putch('?', putdat);
  800732:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800735:	89 44 24 04          	mov    %eax,0x4(%esp)
  800739:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
  800743:	eb 0d                	jmp    800752 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800745:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800748:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074c:	89 04 24             	mov    %eax,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800752:	83 eb 01             	sub    $0x1,%ebx
  800755:	0f be 06             	movsbl (%esi),%eax
  800758:	83 c6 01             	add    $0x1,%esi
  80075b:	85 c0                	test   %eax,%eax
  80075d:	75 1a                	jne    800779 <vprintfmt+0x393>
  80075f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800762:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800765:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800768:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80076c:	7f 1c                	jg     80078a <vprintfmt+0x3a4>
  80076e:	e9 96 fc ff ff       	jmp    800409 <vprintfmt+0x23>
  800773:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800776:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800779:	85 ff                	test   %edi,%edi
  80077b:	78 a7                	js     800724 <vprintfmt+0x33e>
  80077d:	83 ef 01             	sub    $0x1,%edi
  800780:	79 a2                	jns    800724 <vprintfmt+0x33e>
  800782:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800785:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800788:	eb db                	jmp    800765 <vprintfmt+0x37f>
  80078a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80078d:	89 de                	mov    %ebx,%esi
  80078f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800792:	89 74 24 04          	mov    %esi,0x4(%esp)
  800796:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80079d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079f:	83 eb 01             	sub    $0x1,%ebx
  8007a2:	75 ee                	jne    800792 <vprintfmt+0x3ac>
  8007a4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007a9:	e9 5b fc ff ff       	jmp    800409 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ae:	83 f9 01             	cmp    $0x1,%ecx
  8007b1:	7e 10                	jle    8007c3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 50 08             	lea    0x8(%eax),%edx
  8007b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bc:	8b 30                	mov    (%eax),%esi
  8007be:	8b 78 04             	mov    0x4(%eax),%edi
  8007c1:	eb 26                	jmp    8007e9 <vprintfmt+0x403>
	else if (lflag)
  8007c3:	85 c9                	test   %ecx,%ecx
  8007c5:	74 12                	je     8007d9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 04             	lea    0x4(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 30                	mov    (%eax),%esi
  8007d2:	89 f7                	mov    %esi,%edi
  8007d4:	c1 ff 1f             	sar    $0x1f,%edi
  8007d7:	eb 10                	jmp    8007e9 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e2:	8b 30                	mov    (%eax),%esi
  8007e4:	89 f7                	mov    %esi,%edi
  8007e6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e9:	85 ff                	test   %edi,%edi
  8007eb:	78 0e                	js     8007fb <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ed:	89 f0                	mov    %esi,%eax
  8007ef:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f1:	be 0a 00 00 00       	mov    $0xa,%esi
  8007f6:	e9 84 00 00 00       	jmp    80087f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800806:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800809:	89 f0                	mov    %esi,%eax
  80080b:	89 fa                	mov    %edi,%edx
  80080d:	f7 d8                	neg    %eax
  80080f:	83 d2 00             	adc    $0x0,%edx
  800812:	f7 da                	neg    %edx
			}
			base = 10;
  800814:	be 0a 00 00 00       	mov    $0xa,%esi
  800819:	eb 64                	jmp    80087f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081b:	89 ca                	mov    %ecx,%edx
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
  800820:	e8 42 fb ff ff       	call   800367 <getuint>
			base = 10;
  800825:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80082a:	eb 53                	jmp    80087f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80082c:	89 ca                	mov    %ecx,%edx
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
  800831:	e8 31 fb ff ff       	call   800367 <getuint>
    			base = 8;
  800836:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80083b:	eb 42                	jmp    80087f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80083d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800841:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800848:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80084b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800856:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8d 50 04             	lea    0x4(%eax),%edx
  80085f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800862:	8b 00                	mov    (%eax),%eax
  800864:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800869:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80086e:	eb 0f                	jmp    80087f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800870:	89 ca                	mov    %ecx,%edx
  800872:	8d 45 14             	lea    0x14(%ebp),%eax
  800875:	e8 ed fa ff ff       	call   800367 <getuint>
			base = 16;
  80087a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800883:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800887:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80088a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80088e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	89 54 24 04          	mov    %edx,0x4(%esp)
  800899:	89 da                	mov    %ebx,%edx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	e8 e9 f9 ff ff       	call   80028c <printnum>
			break;
  8008a3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008a6:	e9 5e fb ff ff       	jmp    800409 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008af:	89 14 24             	mov    %edx,(%esp)
  8008b2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b8:	e9 4c fb ff ff       	jmp    800409 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008cf:	0f 84 34 fb ff ff    	je     800409 <vprintfmt+0x23>
  8008d5:	83 ee 01             	sub    $0x1,%esi
  8008d8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008dc:	75 f7                	jne    8008d5 <vprintfmt+0x4ef>
  8008de:	e9 26 fb ff ff       	jmp    800409 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008e3:	83 c4 5c             	add    $0x5c,%esp
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 28             	sub    $0x28,%esp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800901:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800908:	85 c0                	test   %eax,%eax
  80090a:	74 30                	je     80093c <vsnprintf+0x51>
  80090c:	85 d2                	test   %edx,%edx
  80090e:	7e 2c                	jle    80093c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800917:	8b 45 10             	mov    0x10(%ebp),%eax
  80091a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800921:	89 44 24 04          	mov    %eax,0x4(%esp)
  800925:	c7 04 24 a1 03 80 00 	movl   $0x8003a1,(%esp)
  80092c:	e8 b5 fa ff ff       	call   8003e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800931:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800934:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093a:	eb 05                	jmp    800941 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80093c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800949:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80094c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800950:	8b 45 10             	mov    0x10(%ebp),%eax
  800953:	89 44 24 08          	mov    %eax,0x8(%esp)
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	89 04 24             	mov    %eax,(%esp)
  800964:	e8 82 ff ff ff       	call   8008eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    
  80096b:	00 00                	add    %al,(%eax)
  80096d:	00 00                	add    %al,(%eax)
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

00800da0 <__udivdi3>:
  800da0:	83 ec 1c             	sub    $0x1c,%esp
  800da3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800da7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800dab:	8b 44 24 20          	mov    0x20(%esp),%eax
  800daf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800db3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800db7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800dbb:	85 ff                	test   %edi,%edi
  800dbd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800dc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc5:	89 cd                	mov    %ecx,%ebp
  800dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcb:	75 33                	jne    800e00 <__udivdi3+0x60>
  800dcd:	39 f1                	cmp    %esi,%ecx
  800dcf:	77 57                	ja     800e28 <__udivdi3+0x88>
  800dd1:	85 c9                	test   %ecx,%ecx
  800dd3:	75 0b                	jne    800de0 <__udivdi3+0x40>
  800dd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dda:	31 d2                	xor    %edx,%edx
  800ddc:	f7 f1                	div    %ecx
  800dde:	89 c1                	mov    %eax,%ecx
  800de0:	89 f0                	mov    %esi,%eax
  800de2:	31 d2                	xor    %edx,%edx
  800de4:	f7 f1                	div    %ecx
  800de6:	89 c6                	mov    %eax,%esi
  800de8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dec:	f7 f1                	div    %ecx
  800dee:	89 f2                	mov    %esi,%edx
  800df0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800df4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800df8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800dfc:	83 c4 1c             	add    $0x1c,%esp
  800dff:	c3                   	ret    
  800e00:	31 d2                	xor    %edx,%edx
  800e02:	31 c0                	xor    %eax,%eax
  800e04:	39 f7                	cmp    %esi,%edi
  800e06:	77 e8                	ja     800df0 <__udivdi3+0x50>
  800e08:	0f bd cf             	bsr    %edi,%ecx
  800e0b:	83 f1 1f             	xor    $0x1f,%ecx
  800e0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e12:	75 2c                	jne    800e40 <__udivdi3+0xa0>
  800e14:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800e18:	76 04                	jbe    800e1e <__udivdi3+0x7e>
  800e1a:	39 f7                	cmp    %esi,%edi
  800e1c:	73 d2                	jae    800df0 <__udivdi3+0x50>
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	b8 01 00 00 00       	mov    $0x1,%eax
  800e25:	eb c9                	jmp    800df0 <__udivdi3+0x50>
  800e27:	90                   	nop
  800e28:	89 f2                	mov    %esi,%edx
  800e2a:	f7 f1                	div    %ecx
  800e2c:	31 d2                	xor    %edx,%edx
  800e2e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e32:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e36:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	c3                   	ret    
  800e3e:	66 90                	xchg   %ax,%ax
  800e40:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e45:	b8 20 00 00 00       	mov    $0x20,%eax
  800e4a:	89 ea                	mov    %ebp,%edx
  800e4c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e50:	d3 e7                	shl    %cl,%edi
  800e52:	89 c1                	mov    %eax,%ecx
  800e54:	d3 ea                	shr    %cl,%edx
  800e56:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e5b:	09 fa                	or     %edi,%edx
  800e5d:	89 f7                	mov    %esi,%edi
  800e5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e63:	89 f2                	mov    %esi,%edx
  800e65:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e69:	d3 e5                	shl    %cl,%ebp
  800e6b:	89 c1                	mov    %eax,%ecx
  800e6d:	d3 ef                	shr    %cl,%edi
  800e6f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e74:	d3 e2                	shl    %cl,%edx
  800e76:	89 c1                	mov    %eax,%ecx
  800e78:	d3 ee                	shr    %cl,%esi
  800e7a:	09 d6                	or     %edx,%esi
  800e7c:	89 fa                	mov    %edi,%edx
  800e7e:	89 f0                	mov    %esi,%eax
  800e80:	f7 74 24 0c          	divl   0xc(%esp)
  800e84:	89 d7                	mov    %edx,%edi
  800e86:	89 c6                	mov    %eax,%esi
  800e88:	f7 e5                	mul    %ebp
  800e8a:	39 d7                	cmp    %edx,%edi
  800e8c:	72 22                	jb     800eb0 <__udivdi3+0x110>
  800e8e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800e92:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e97:	d3 e5                	shl    %cl,%ebp
  800e99:	39 c5                	cmp    %eax,%ebp
  800e9b:	73 04                	jae    800ea1 <__udivdi3+0x101>
  800e9d:	39 d7                	cmp    %edx,%edi
  800e9f:	74 0f                	je     800eb0 <__udivdi3+0x110>
  800ea1:	89 f0                	mov    %esi,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	e9 46 ff ff ff       	jmp    800df0 <__udivdi3+0x50>
  800eaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800eb9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ebd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	c3                   	ret    
	...

00800ed0 <__umoddi3>:
  800ed0:	83 ec 1c             	sub    $0x1c,%esp
  800ed3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ed7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800edb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800edf:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ee3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ee7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800eeb:	85 ed                	test   %ebp,%ebp
  800eed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800ef1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef5:	89 cf                	mov    %ecx,%edi
  800ef7:	89 04 24             	mov    %eax,(%esp)
  800efa:	89 f2                	mov    %esi,%edx
  800efc:	75 1a                	jne    800f18 <__umoddi3+0x48>
  800efe:	39 f1                	cmp    %esi,%ecx
  800f00:	76 4e                	jbe    800f50 <__umoddi3+0x80>
  800f02:	f7 f1                	div    %ecx
  800f04:	89 d0                	mov    %edx,%eax
  800f06:	31 d2                	xor    %edx,%edx
  800f08:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f0c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f10:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f14:	83 c4 1c             	add    $0x1c,%esp
  800f17:	c3                   	ret    
  800f18:	39 f5                	cmp    %esi,%ebp
  800f1a:	77 54                	ja     800f70 <__umoddi3+0xa0>
  800f1c:	0f bd c5             	bsr    %ebp,%eax
  800f1f:	83 f0 1f             	xor    $0x1f,%eax
  800f22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f26:	75 60                	jne    800f88 <__umoddi3+0xb8>
  800f28:	3b 0c 24             	cmp    (%esp),%ecx
  800f2b:	0f 87 07 01 00 00    	ja     801038 <__umoddi3+0x168>
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	8b 34 24             	mov    (%esp),%esi
  800f36:	29 ce                	sub    %ecx,%esi
  800f38:	19 ea                	sbb    %ebp,%edx
  800f3a:	89 34 24             	mov    %esi,(%esp)
  800f3d:	8b 04 24             	mov    (%esp),%eax
  800f40:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f44:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f48:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f4c:	83 c4 1c             	add    $0x1c,%esp
  800f4f:	c3                   	ret    
  800f50:	85 c9                	test   %ecx,%ecx
  800f52:	75 0b                	jne    800f5f <__umoddi3+0x8f>
  800f54:	b8 01 00 00 00       	mov    $0x1,%eax
  800f59:	31 d2                	xor    %edx,%edx
  800f5b:	f7 f1                	div    %ecx
  800f5d:	89 c1                	mov    %eax,%ecx
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	f7 f1                	div    %ecx
  800f65:	8b 04 24             	mov    (%esp),%eax
  800f68:	f7 f1                	div    %ecx
  800f6a:	eb 98                	jmp    800f04 <__umoddi3+0x34>
  800f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 f2                	mov    %esi,%edx
  800f72:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f76:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f7a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f7e:	83 c4 1c             	add    $0x1c,%esp
  800f81:	c3                   	ret    
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f8d:	89 e8                	mov    %ebp,%eax
  800f8f:	bd 20 00 00 00       	mov    $0x20,%ebp
  800f94:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800f98:	89 fa                	mov    %edi,%edx
  800f9a:	d3 e0                	shl    %cl,%eax
  800f9c:	89 e9                	mov    %ebp,%ecx
  800f9e:	d3 ea                	shr    %cl,%edx
  800fa0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fa5:	09 c2                	or     %eax,%edx
  800fa7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fab:	89 14 24             	mov    %edx,(%esp)
  800fae:	89 f2                	mov    %esi,%edx
  800fb0:	d3 e7                	shl    %cl,%edi
  800fb2:	89 e9                	mov    %ebp,%ecx
  800fb4:	d3 ea                	shr    %cl,%edx
  800fb6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	d3 e6                	shl    %cl,%esi
  800fc1:	89 e9                	mov    %ebp,%ecx
  800fc3:	d3 e8                	shr    %cl,%eax
  800fc5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fca:	09 f0                	or     %esi,%eax
  800fcc:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fd0:	f7 34 24             	divl   (%esp)
  800fd3:	d3 e6                	shl    %cl,%esi
  800fd5:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fd9:	89 d6                	mov    %edx,%esi
  800fdb:	f7 e7                	mul    %edi
  800fdd:	39 d6                	cmp    %edx,%esi
  800fdf:	89 c1                	mov    %eax,%ecx
  800fe1:	89 d7                	mov    %edx,%edi
  800fe3:	72 3f                	jb     801024 <__umoddi3+0x154>
  800fe5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fe9:	72 35                	jb     801020 <__umoddi3+0x150>
  800feb:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fef:	29 c8                	sub    %ecx,%eax
  800ff1:	19 fe                	sbb    %edi,%esi
  800ff3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	d3 e8                	shr    %cl,%eax
  800ffc:	89 e9                	mov    %ebp,%ecx
  800ffe:	d3 e2                	shl    %cl,%edx
  801000:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801005:	09 d0                	or     %edx,%eax
  801007:	89 f2                	mov    %esi,%edx
  801009:	d3 ea                	shr    %cl,%edx
  80100b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80100f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801013:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801017:	83 c4 1c             	add    $0x1c,%esp
  80101a:	c3                   	ret    
  80101b:	90                   	nop
  80101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801020:	39 d6                	cmp    %edx,%esi
  801022:	75 c7                	jne    800feb <__umoddi3+0x11b>
  801024:	89 d7                	mov    %edx,%edi
  801026:	89 c1                	mov    %eax,%ecx
  801028:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80102c:	1b 3c 24             	sbb    (%esp),%edi
  80102f:	eb ba                	jmp    800feb <__umoddi3+0x11b>
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	39 f5                	cmp    %esi,%ebp
  80103a:	0f 82 f1 fe ff ff    	jb     800f31 <__umoddi3+0x61>
  801040:	e9 f8 fe ff ff       	jmp    800f3d <__umoddi3+0x6d>
