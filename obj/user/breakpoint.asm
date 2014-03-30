
obj/user/breakpoint:     file format elf32-i386


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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
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
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 0d 01 00 00       	call   800160 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005b:	c1 e0 05             	shl    $0x5,%eax
  80005e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800063:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 f6                	test   %esi,%esi
  80006a:	7e 07                	jle    800073 <libmain+0x37>
		binaryname = argv[0];
  80006c:	8b 03                	mov    (%ebx),%eax
  80006e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800073:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800077:	89 34 24             	mov    %esi,(%esp)
  80007a:	e8 b5 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007f:	e8 0c 00 00 00       	call   800090 <exit>
}
  800084:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800087:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008a:	89 ec                	mov    %ebp,%esp
  80008c:	5d                   	pop    %ebp
  80008d:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 61 00 00 00       	call   800103 <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000be:	89 c3                	mov    %eax,%ebx
  8000c0:	89 c7                	mov    %eax,%edi
  8000c2:	89 c6                	mov    %eax,%esi
  8000c4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000cf:	89 ec                	mov    %ebp,%esp
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000df:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	89 d6                	mov    %edx,%esi
  8000f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000ff:	89 ec                	mov    %ebp,%esp
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	83 ec 38             	sub    $0x38,%esp
  800109:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80010c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	89 cb                	mov    %ecx,%ebx
  800121:	89 cf                	mov    %ecx,%edi
  800123:	89 ce                	mov    %ecx,%esi
  800125:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	7e 28                	jle    800153 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800136:	00 
  800137:	c7 44 24 08 72 10 80 	movl   $0x801072,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 8f 10 80 00 	movl   $0x80108f,(%esp)
  80014e:	e8 3d 00 00 00       	call   800190 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800153:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800156:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800159:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80015c:	89 ec                	mov    %ebp,%esp
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800169:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80016c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	ba 00 00 00 00       	mov    $0x0,%edx
  800174:	b8 02 00 00 00       	mov    $0x2,%eax
  800179:	89 d1                	mov    %edx,%ecx
  80017b:	89 d3                	mov    %edx,%ebx
  80017d:	89 d7                	mov    %edx,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800183:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800186:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800189:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80018c:	89 ec                	mov    %ebp,%esp
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
  800195:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a1:	e8 ba ff ff ff       	call   800160 <sys_getenvid>
  8001a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  8001c3:	e8 c3 00 00 00       	call   80028b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	e8 53 00 00 00       	call   80022a <vcprintf>
	cprintf("\n");
  8001d7:	c7 04 24 c4 10 80 00 	movl   $0x8010c4,(%esp)
  8001de:	e8 a8 00 00 00       	call   80028b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e3:	cc                   	int3   
  8001e4:	eb fd                	jmp    8001e3 <_panic+0x53>
	...

008001e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 14             	sub    $0x14,%esp
  8001ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001fb:	83 c0 01             	add    $0x1,%eax
  8001fe:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800200:	3d ff 00 00 00       	cmp    $0xff,%eax
  800205:	75 19                	jne    800220 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800207:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020e:	00 
  80020f:	8d 43 08             	lea    0x8(%ebx),%eax
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	e8 8a fe ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  80021a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800220:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800224:	83 c4 14             	add    $0x14,%esp
  800227:	5b                   	pop    %ebx
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800233:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023a:	00 00 00 
	b.cnt = 0;
  80023d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800244:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 44 24 08          	mov    %eax,0x8(%esp)
  800255:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	c7 04 24 e8 01 80 00 	movl   $0x8001e8,(%esp)
  800266:	e8 97 01 00 00       	call   800402 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 21 fe ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  800283:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800291:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800294:	89 44 24 04          	mov    %eax,0x4(%esp)
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	e8 87 ff ff ff       	call   80022a <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    
  8002a5:	00 00                	add    %al,(%eax)
	...

008002a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 3c             	sub    $0x3c,%esp
  8002b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b4:	89 d7                	mov    %edx,%edi
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002cd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002d0:	72 11                	jb     8002e3 <printnum+0x3b>
  8002d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d8:	76 09                	jbe    8002e3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	85 db                	test   %ebx,%ebx
  8002df:	7f 51                	jg     800332 <printnum+0x8a>
  8002e1:	eb 5e                	jmp    800341 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002e7:	83 eb 01             	sub    $0x1,%ebx
  8002ea:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002f9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800304:	00 
  800305:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	e8 a9 0a 00 00       	call   800dc0 <__udivdi3>
  800317:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80031f:	89 04 24             	mov    %eax,(%esp)
  800322:	89 54 24 04          	mov    %edx,0x4(%esp)
  800326:	89 fa                	mov    %edi,%edx
  800328:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032b:	e8 78 ff ff ff       	call   8002a8 <printnum>
  800330:	eb 0f                	jmp    800341 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800332:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800336:	89 34 24             	mov    %esi,(%esp)
  800339:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033c:	83 eb 01             	sub    $0x1,%ebx
  80033f:	75 f1                	jne    800332 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800341:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800345:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800349:	8b 45 10             	mov    0x10(%ebp),%eax
  80034c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800350:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800357:	00 
  800358:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	e8 86 0b 00 00       	call   800ef0 <__umoddi3>
  80036a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036e:	0f be 80 c6 10 80 00 	movsbl 0x8010c6(%eax),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80037b:	83 c4 3c             	add    $0x3c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800386:	83 fa 01             	cmp    $0x1,%edx
  800389:	7e 0e                	jle    800399 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800390:	89 08                	mov    %ecx,(%eax)
  800392:	8b 02                	mov    (%edx),%eax
  800394:	8b 52 04             	mov    0x4(%edx),%edx
  800397:	eb 22                	jmp    8003bb <getuint+0x38>
	else if (lflag)
  800399:	85 d2                	test   %edx,%edx
  80039b:	74 10                	je     8003ad <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ab:	eb 0e                	jmp    8003bb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c7:	8b 10                	mov    (%eax),%edx
  8003c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003cc:	73 0a                	jae    8003d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d1:	88 0a                	mov    %cl,(%edx)
  8003d3:	83 c2 01             	add    $0x1,%edx
  8003d6:	89 10                	mov    %edx,(%eax)
}
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 02 00 00 00       	call   800402 <vprintfmt>
	va_end(ap);
}
  800400:	c9                   	leave  
  800401:	c3                   	ret    

00800402 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	57                   	push   %edi
  800406:	56                   	push   %esi
  800407:	53                   	push   %ebx
  800408:	83 ec 5c             	sub    $0x5c,%esp
  80040b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040e:	8b 75 10             	mov    0x10(%ebp),%esi
  800411:	eb 12                	jmp    800425 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800413:	85 c0                	test   %eax,%eax
  800415:	0f 84 e4 04 00 00    	je     8008ff <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80041b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041f:	89 04 24             	mov    %eax,(%esp)
  800422:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800425:	0f b6 06             	movzbl (%esi),%eax
  800428:	83 c6 01             	add    $0x1,%esi
  80042b:	83 f8 25             	cmp    $0x25,%eax
  80042e:	75 e3                	jne    800413 <vprintfmt+0x11>
  800430:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800434:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80043b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800440:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800447:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80044f:	eb 2b                	jmp    80047c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800454:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800458:	eb 22                	jmp    80047c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80045d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800461:	eb 19                	jmp    80047c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800466:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80046d:	eb 0d                	jmp    80047c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80046f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800472:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800475:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	0f b6 06             	movzbl (%esi),%eax
  80047f:	0f b6 d0             	movzbl %al,%edx
  800482:	8d 7e 01             	lea    0x1(%esi),%edi
  800485:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800488:	83 e8 23             	sub    $0x23,%eax
  80048b:	3c 55                	cmp    $0x55,%al
  80048d:	0f 87 46 04 00 00    	ja     8008d9 <vprintfmt+0x4d7>
  800493:	0f b6 c0             	movzbl %al,%eax
  800496:	ff 24 85 6c 11 80 00 	jmp    *0x80116c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049d:	83 ea 30             	sub    $0x30,%edx
  8004a0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004a3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004a7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004ad:	83 fa 09             	cmp    $0x9,%edx
  8004b0:	77 4a                	ja     8004fc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004b8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004bb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004bf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c5:	83 fa 09             	cmp    $0x9,%edx
  8004c8:	76 eb                	jbe    8004b5 <vprintfmt+0xb3>
  8004ca:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004cd:	eb 2d                	jmp    8004fc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 00                	mov    (%eax),%eax
  8004da:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e0:	eb 1a                	jmp    8004fc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004e5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e9:	79 91                	jns    80047c <vprintfmt+0x7a>
  8004eb:	e9 73 ff ff ff       	jmp    800463 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004fa:	eb 80                	jmp    80047c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004fc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800500:	0f 89 76 ff ff ff    	jns    80047c <vprintfmt+0x7a>
  800506:	e9 64 ff ff ff       	jmp    80046f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800511:	e9 66 ff ff ff       	jmp    80047c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 04 24             	mov    %eax,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052e:	e9 f2 fe ff ff       	jmp    800425 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800533:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800537:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80053a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80053e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800541:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800545:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800548:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80054b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80054f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800552:	80 f9 09             	cmp    $0x9,%cl
  800555:	77 1d                	ja     800574 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800557:	0f be c0             	movsbl %al,%eax
  80055a:	6b c0 64             	imul   $0x64,%eax,%eax
  80055d:	0f be d2             	movsbl %dl,%edx
  800560:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800563:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80056a:	a3 04 20 80 00       	mov    %eax,0x802004
  80056f:	e9 b1 fe ff ff       	jmp    800425 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800574:	c7 44 24 04 de 10 80 	movl   $0x8010de,0x4(%esp)
  80057b:	00 
  80057c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	e8 14 05 00 00       	call   800a9b <strcmp>
  800587:	85 c0                	test   %eax,%eax
  800589:	75 0f                	jne    80059a <vprintfmt+0x198>
  80058b:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800592:	00 00 00 
  800595:	e9 8b fe ff ff       	jmp    800425 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80059a:	c7 44 24 04 e2 10 80 	movl   $0x8010e2,0x4(%esp)
  8005a1:	00 
  8005a2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005a5:	89 14 24             	mov    %edx,(%esp)
  8005a8:	e8 ee 04 00 00       	call   800a9b <strcmp>
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	75 0f                	jne    8005c0 <vprintfmt+0x1be>
  8005b1:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005b8:	00 00 00 
  8005bb:	e9 65 fe ff ff       	jmp    800425 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005c0:	c7 44 24 04 e6 10 80 	movl   $0x8010e6,0x4(%esp)
  8005c7:	00 
  8005c8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005cb:	89 0c 24             	mov    %ecx,(%esp)
  8005ce:	e8 c8 04 00 00       	call   800a9b <strcmp>
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	75 0f                	jne    8005e6 <vprintfmt+0x1e4>
  8005d7:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005de:	00 00 00 
  8005e1:	e9 3f fe ff ff       	jmp    800425 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005e6:	c7 44 24 04 ea 10 80 	movl   $0x8010ea,0x4(%esp)
  8005ed:	00 
  8005ee:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005f1:	89 3c 24             	mov    %edi,(%esp)
  8005f4:	e8 a2 04 00 00       	call   800a9b <strcmp>
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	75 0f                	jne    80060c <vprintfmt+0x20a>
  8005fd:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800604:	00 00 00 
  800607:	e9 19 fe ff ff       	jmp    800425 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80060c:	c7 44 24 04 ee 10 80 	movl   $0x8010ee,0x4(%esp)
  800613:	00 
  800614:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	e8 7c 04 00 00       	call   800a9b <strcmp>
  80061f:	85 c0                	test   %eax,%eax
  800621:	75 0f                	jne    800632 <vprintfmt+0x230>
  800623:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80062a:	00 00 00 
  80062d:	e9 f3 fd ff ff       	jmp    800425 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800632:	c7 44 24 04 f2 10 80 	movl   $0x8010f2,0x4(%esp)
  800639:	00 
  80063a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80063d:	89 14 24             	mov    %edx,(%esp)
  800640:	e8 56 04 00 00       	call   800a9b <strcmp>
  800645:	83 f8 01             	cmp    $0x1,%eax
  800648:	19 c0                	sbb    %eax,%eax
  80064a:	f7 d0                	not    %eax
  80064c:	83 c0 08             	add    $0x8,%eax
  80064f:	a3 04 20 80 00       	mov    %eax,0x802004
  800654:	e9 cc fd ff ff       	jmp    800425 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	89 c2                	mov    %eax,%edx
  800666:	c1 fa 1f             	sar    $0x1f,%edx
  800669:	31 d0                	xor    %edx,%eax
  80066b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066d:	83 f8 06             	cmp    $0x6,%eax
  800670:	7f 0b                	jg     80067d <vprintfmt+0x27b>
  800672:	8b 14 85 c4 12 80 00 	mov    0x8012c4(,%eax,4),%edx
  800679:	85 d2                	test   %edx,%edx
  80067b:	75 23                	jne    8006a0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80067d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800681:	c7 44 24 08 f6 10 80 	movl   $0x8010f6,0x8(%esp)
  800688:	00 
  800689:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800690:	89 3c 24             	mov    %edi,(%esp)
  800693:	e8 42 fd ff ff       	call   8003da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069b:	e9 85 fd ff ff       	jmp    800425 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a4:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  8006ab:	00 
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b3:	89 3c 24             	mov    %edi,(%esp)
  8006b6:	e8 1f fd ff ff       	call   8003da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006be:	e9 62 fd ff ff       	jmp    800425 <vprintfmt+0x23>
  8006c3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006c9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006d7:	85 f6                	test   %esi,%esi
  8006d9:	b8 d7 10 80 00       	mov    $0x8010d7,%eax
  8006de:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006e1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006e5:	7e 06                	jle    8006ed <vprintfmt+0x2eb>
  8006e7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006eb:	75 13                	jne    800700 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ed:	0f be 06             	movsbl (%esi),%eax
  8006f0:	83 c6 01             	add    $0x1,%esi
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	0f 85 94 00 00 00    	jne    80078f <vprintfmt+0x38d>
  8006fb:	e9 81 00 00 00       	jmp    800781 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800704:	89 34 24             	mov    %esi,(%esp)
  800707:	e8 9f 02 00 00       	call   8009ab <strnlen>
  80070c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80070f:	29 c2                	sub    %eax,%edx
  800711:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800714:	85 d2                	test   %edx,%edx
  800716:	7e d5                	jle    8006ed <vprintfmt+0x2eb>
					putch(padc, putdat);
  800718:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80071c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80071f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800722:	89 d6                	mov    %edx,%esi
  800724:	89 cf                	mov    %ecx,%edi
  800726:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072a:	89 3c 24             	mov    %edi,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800730:	83 ee 01             	sub    $0x1,%esi
  800733:	75 f1                	jne    800726 <vprintfmt+0x324>
  800735:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800738:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80073b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80073e:	eb ad                	jmp    8006ed <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800740:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800744:	74 1b                	je     800761 <vprintfmt+0x35f>
  800746:	8d 50 e0             	lea    -0x20(%eax),%edx
  800749:	83 fa 5e             	cmp    $0x5e,%edx
  80074c:	76 13                	jbe    800761 <vprintfmt+0x35f>
					putch('?', putdat);
  80074e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800751:	89 44 24 04          	mov    %eax,0x4(%esp)
  800755:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80075c:	ff 55 08             	call   *0x8(%ebp)
  80075f:	eb 0d                	jmp    80076e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800761:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800764:	89 54 24 04          	mov    %edx,0x4(%esp)
  800768:	89 04 24             	mov    %eax,(%esp)
  80076b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076e:	83 eb 01             	sub    $0x1,%ebx
  800771:	0f be 06             	movsbl (%esi),%eax
  800774:	83 c6 01             	add    $0x1,%esi
  800777:	85 c0                	test   %eax,%eax
  800779:	75 1a                	jne    800795 <vprintfmt+0x393>
  80077b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80077e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800784:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800788:	7f 1c                	jg     8007a6 <vprintfmt+0x3a4>
  80078a:	e9 96 fc ff ff       	jmp    800425 <vprintfmt+0x23>
  80078f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800792:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800795:	85 ff                	test   %edi,%edi
  800797:	78 a7                	js     800740 <vprintfmt+0x33e>
  800799:	83 ef 01             	sub    $0x1,%edi
  80079c:	79 a2                	jns    800740 <vprintfmt+0x33e>
  80079e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007a4:	eb db                	jmp    800781 <vprintfmt+0x37f>
  8007a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a9:	89 de                	mov    %ebx,%esi
  8007ab:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bb:	83 eb 01             	sub    $0x1,%ebx
  8007be:	75 ee                	jne    8007ae <vprintfmt+0x3ac>
  8007c0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007c5:	e9 5b fc ff ff       	jmp    800425 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7e 10                	jle    8007df <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 08             	lea    0x8(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d8:	8b 30                	mov    (%eax),%esi
  8007da:	8b 78 04             	mov    0x4(%eax),%edi
  8007dd:	eb 26                	jmp    800805 <vprintfmt+0x403>
	else if (lflag)
  8007df:	85 c9                	test   %ecx,%ecx
  8007e1:	74 12                	je     8007f5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 04             	lea    0x4(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 30                	mov    (%eax),%esi
  8007ee:	89 f7                	mov    %esi,%edi
  8007f0:	c1 ff 1f             	sar    $0x1f,%edi
  8007f3:	eb 10                	jmp    800805 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 04             	lea    0x4(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fe:	8b 30                	mov    (%eax),%esi
  800800:	89 f7                	mov    %esi,%edi
  800802:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800805:	85 ff                	test   %edi,%edi
  800807:	78 0e                	js     800817 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800809:	89 f0                	mov    %esi,%eax
  80080b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080d:	be 0a 00 00 00       	mov    $0xa,%esi
  800812:	e9 84 00 00 00       	jmp    80089b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800822:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800825:	89 f0                	mov    %esi,%eax
  800827:	89 fa                	mov    %edi,%edx
  800829:	f7 d8                	neg    %eax
  80082b:	83 d2 00             	adc    $0x0,%edx
  80082e:	f7 da                	neg    %edx
			}
			base = 10;
  800830:	be 0a 00 00 00       	mov    $0xa,%esi
  800835:	eb 64                	jmp    80089b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800837:	89 ca                	mov    %ecx,%edx
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
  80083c:	e8 42 fb ff ff       	call   800383 <getuint>
			base = 10;
  800841:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800846:	eb 53                	jmp    80089b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800848:	89 ca                	mov    %ecx,%edx
  80084a:	8d 45 14             	lea    0x14(%ebp),%eax
  80084d:	e8 31 fb ff ff       	call   800383 <getuint>
    			base = 8;
  800852:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800857:	eb 42                	jmp    80089b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800859:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800864:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800867:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800872:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8d 50 04             	lea    0x4(%eax),%edx
  80087b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087e:	8b 00                	mov    (%eax),%eax
  800880:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800885:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80088a:	eb 0f                	jmp    80089b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088c:	89 ca                	mov    %ecx,%edx
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
  800891:	e8 ed fa ff ff       	call   800383 <getuint>
			base = 16;
  800896:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80089f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008a3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008a6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b5:	89 da                	mov    %ebx,%edx
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	e8 e9 f9 ff ff       	call   8002a8 <printnum>
			break;
  8008bf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008c2:	e9 5e fb ff ff       	jmp    800425 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cb:	89 14 24             	mov    %edx,(%esp)
  8008ce:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d4:	e9 4c fb ff ff       	jmp    800425 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008dd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008eb:	0f 84 34 fb ff ff    	je     800425 <vprintfmt+0x23>
  8008f1:	83 ee 01             	sub    $0x1,%esi
  8008f4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f8:	75 f7                	jne    8008f1 <vprintfmt+0x4ef>
  8008fa:	e9 26 fb ff ff       	jmp    800425 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008ff:	83 c4 5c             	add    $0x5c,%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	83 ec 28             	sub    $0x28,%esp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800913:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800916:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800924:	85 c0                	test   %eax,%eax
  800926:	74 30                	je     800958 <vsnprintf+0x51>
  800928:	85 d2                	test   %edx,%edx
  80092a:	7e 2c                	jle    800958 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800933:	8b 45 10             	mov    0x10(%ebp),%eax
  800936:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	c7 04 24 bd 03 80 00 	movl   $0x8003bd,(%esp)
  800948:	e8 b5 fa ff ff       	call   800402 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800950:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800956:	eb 05                	jmp    80095d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800958:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800965:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800968:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096c:	8b 45 10             	mov    0x10(%ebp),%eax
  80096f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	89 04 24             	mov    %eax,(%esp)
  800980:	e8 82 ff ff ff       	call   800907 <vsnprintf>
	va_end(ap);

	return rc;
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    
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
