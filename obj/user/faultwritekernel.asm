
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800056:	e8 0d 01 00 00       	call   800168 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800063:	c1 e0 05             	shl    $0x5,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 f6                	test   %esi,%esi
  800072:	7e 07                	jle    80007b <libmain+0x37>
		binaryname = argv[0];
  800074:	8b 03                	mov    (%ebx),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007f:	89 34 24             	mov    %esi,(%esp)
  800082:	e8 ad ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800087:	e8 0c 00 00 00       	call   800098 <exit>
}
  80008c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008f:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800092:	89 ec                	mov    %ebp,%esp
  800094:	5d                   	pop    %ebp
  800095:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 61 00 00 00       	call   80010b <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c6:	89 c3                	mov    %eax,%ebx
  8000c8:	89 c7                	mov    %eax,%edi
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000d7:	89 ec                	mov    %ebp,%esp
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f4:	89 d1                	mov    %edx,%ecx
  8000f6:	89 d3                	mov    %edx,%ebx
  8000f8:	89 d7                	mov    %edx,%edi
  8000fa:	89 d6                	mov    %edx,%esi
  8000fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800101:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800104:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 38             	sub    $0x38,%esp
  800111:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800114:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800117:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011f:	b8 03 00 00 00       	mov    $0x3,%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	89 cb                	mov    %ecx,%ebx
  800129:	89 cf                	mov    %ecx,%edi
  80012b:	89 ce                	mov    %ecx,%esi
  80012d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012f:	85 c0                	test   %eax,%eax
  800131:	7e 28                	jle    80015b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800133:	89 44 24 10          	mov    %eax,0x10(%esp)
  800137:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013e:	00 
  80013f:	c7 44 24 08 72 10 80 	movl   $0x801072,0x8(%esp)
  800146:	00 
  800147:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014e:	00 
  80014f:	c7 04 24 8f 10 80 00 	movl   $0x80108f,(%esp)
  800156:	e8 3d 00 00 00       	call   800198 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80015e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800161:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800164:	89 ec                	mov    %ebp,%esp
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800171:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800174:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800177:	ba 00 00 00 00       	mov    $0x0,%edx
  80017c:	b8 02 00 00 00       	mov    $0x2,%eax
  800181:	89 d1                	mov    %edx,%ecx
  800183:	89 d3                	mov    %edx,%ebx
  800185:	89 d7                	mov    %edx,%edi
  800187:	89 d6                	mov    %edx,%esi
  800189:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80018e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800191:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800194:	89 ec                	mov    %ebp,%esp
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a9:	e8 ba ff ff ff       	call   800168 <sys_getenvid>
  8001ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c4:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  8001cb:	e8 c3 00 00 00       	call   800293 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	e8 53 00 00 00       	call   800232 <vcprintf>
	cprintf("\n");
  8001df:	c7 04 24 c4 10 80 00 	movl   $0x8010c4,(%esp)
  8001e6:	e8 a8 00 00 00       	call   800293 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x53>
	...

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 14             	sub    $0x14,%esp
  8001f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fa:	8b 03                	mov    (%ebx),%eax
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800203:	83 c0 01             	add    $0x1,%eax
  800206:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800208:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020d:	75 19                	jne    800228 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800216:	00 
  800217:	8d 43 08             	lea    0x8(%ebx),%eax
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	e8 8a fe ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800222:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800228:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022c:	83 c4 14             	add    $0x14,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80023b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800242:	00 00 00 
	b.cnt = 0;
  800245:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800252:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800263:	89 44 24 04          	mov    %eax,0x4(%esp)
  800267:	c7 04 24 f0 01 80 00 	movl   $0x8001f0,(%esp)
  80026e:	e8 97 01 00 00       	call   80040a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 21 fe ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80028b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800299:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	e8 87 ff ff ff       	call   800232 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 3c             	sub    $0x3c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d7                	mov    %edx,%edi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002d8:	72 11                	jb     8002eb <printnum+0x3b>
  8002da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e0:	76 09                	jbe    8002eb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e2:	83 eb 01             	sub    $0x1,%ebx
  8002e5:	85 db                	test   %ebx,%ebx
  8002e7:	7f 51                	jg     80033a <printnum+0x8a>
  8002e9:	eb 5e                	jmp    800349 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002eb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ef:	83 eb 01             	sub    $0x1,%ebx
  8002f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800301:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800305:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030c:	00 
  80030d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031a:	e8 a1 0a 00 00       	call   800dc0 <__udivdi3>
  80031f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800323:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032e:	89 fa                	mov    %edi,%edx
  800330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800333:	e8 78 ff ff ff       	call   8002b0 <printnum>
  800338:	eb 0f                	jmp    800349 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	89 34 24             	mov    %esi,(%esp)
  800341:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800344:	83 eb 01             	sub    $0x1,%ebx
  800347:	75 f1                	jne    80033a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800349:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800351:	8b 45 10             	mov    0x10(%ebp),%eax
  800354:	89 44 24 08          	mov    %eax,0x8(%esp)
  800358:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035f:	00 
  800360:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	e8 7e 0b 00 00       	call   800ef0 <__umoddi3>
  800372:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800376:	0f be 80 c6 10 80 00 	movsbl 0x8010c6(%eax),%eax
  80037d:	89 04 24             	mov    %eax,(%esp)
  800380:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800383:	83 c4 3c             	add    $0x3c,%esp
  800386:	5b                   	pop    %ebx
  800387:	5e                   	pop    %esi
  800388:	5f                   	pop    %edi
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038e:	83 fa 01             	cmp    $0x1,%edx
  800391:	7e 0e                	jle    8003a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800393:	8b 10                	mov    (%eax),%edx
  800395:	8d 4a 08             	lea    0x8(%edx),%ecx
  800398:	89 08                	mov    %ecx,(%eax)
  80039a:	8b 02                	mov    (%edx),%eax
  80039c:	8b 52 04             	mov    0x4(%edx),%edx
  80039f:	eb 22                	jmp    8003c3 <getuint+0x38>
	else if (lflag)
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 10                	je     8003b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a5:	8b 10                	mov    (%eax),%edx
  8003a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003aa:	89 08                	mov    %ecx,(%eax)
  8003ac:	8b 02                	mov    (%edx),%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 0e                	jmp    8003c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b5:	8b 10                	mov    (%eax),%edx
  8003b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ba:	89 08                	mov    %ecx,(%eax)
  8003bc:	8b 02                	mov    (%edx),%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d4:	73 0a                	jae    8003e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d9:	88 0a                	mov    %cl,(%edx)
  8003db:	83 c2 01             	add    $0x1,%edx
  8003de:	89 10                	mov    %edx,(%eax)
}
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 02 00 00 00       	call   80040a <vprintfmt>
	va_end(ap);
}
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	57                   	push   %edi
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	83 ec 5c             	sub    $0x5c,%esp
  800413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800416:	8b 75 10             	mov    0x10(%ebp),%esi
  800419:	eb 12                	jmp    80042d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80041b:	85 c0                	test   %eax,%eax
  80041d:	0f 84 e4 04 00 00    	je     800907 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800423:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042d:	0f b6 06             	movzbl (%esi),%eax
  800430:	83 c6 01             	add    $0x1,%esi
  800433:	83 f8 25             	cmp    $0x25,%eax
  800436:	75 e3                	jne    80041b <vprintfmt+0x11>
  800438:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80043c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800443:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800448:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80044f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800454:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800457:	eb 2b                	jmp    800484 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80045c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800460:	eb 22                	jmp    800484 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800465:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800469:	eb 19                	jmp    800484 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80046e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800475:	eb 0d                	jmp    800484 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800477:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80047a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	0f b6 06             	movzbl (%esi),%eax
  800487:	0f b6 d0             	movzbl %al,%edx
  80048a:	8d 7e 01             	lea    0x1(%esi),%edi
  80048d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800490:	83 e8 23             	sub    $0x23,%eax
  800493:	3c 55                	cmp    $0x55,%al
  800495:	0f 87 46 04 00 00    	ja     8008e1 <vprintfmt+0x4d7>
  80049b:	0f b6 c0             	movzbl %al,%eax
  80049e:	ff 24 85 6c 11 80 00 	jmp    *0x80116c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a5:	83 ea 30             	sub    $0x30,%edx
  8004a8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004ab:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004af:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004b5:	83 fa 09             	cmp    $0x9,%edx
  8004b8:	77 4a                	ja     800504 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bd:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004c0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004c3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ca:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004cd:	83 fa 09             	cmp    $0x9,%edx
  8004d0:	76 eb                	jbe    8004bd <vprintfmt+0xb3>
  8004d2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004d5:	eb 2d                	jmp    800504 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e8:	eb 1a                	jmp    800504 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004ed:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004f1:	79 91                	jns    800484 <vprintfmt+0x7a>
  8004f3:	e9 73 ff ff ff       	jmp    80046b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004fb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800502:	eb 80                	jmp    800484 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800504:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800508:	0f 89 76 ff ff ff    	jns    800484 <vprintfmt+0x7a>
  80050e:	e9 64 ff ff ff       	jmp    800477 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800513:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800519:	e9 66 ff ff ff       	jmp    800484 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800536:	e9 f2 fe ff ff       	jmp    80042d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80053b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80053f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800542:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800546:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800549:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80054d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800550:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800553:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800557:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80055a:	80 f9 09             	cmp    $0x9,%cl
  80055d:	77 1d                	ja     80057c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80055f:	0f be c0             	movsbl %al,%eax
  800562:	6b c0 64             	imul   $0x64,%eax,%eax
  800565:	0f be d2             	movsbl %dl,%edx
  800568:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80056b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800572:	a3 04 20 80 00       	mov    %eax,0x802004
  800577:	e9 b1 fe ff ff       	jmp    80042d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80057c:	c7 44 24 04 de 10 80 	movl   $0x8010de,0x4(%esp)
  800583:	00 
  800584:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800587:	89 04 24             	mov    %eax,(%esp)
  80058a:	e8 0c 05 00 00       	call   800a9b <strcmp>
  80058f:	85 c0                	test   %eax,%eax
  800591:	75 0f                	jne    8005a2 <vprintfmt+0x198>
  800593:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80059a:	00 00 00 
  80059d:	e9 8b fe ff ff       	jmp    80042d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8005a2:	c7 44 24 04 e2 10 80 	movl   $0x8010e2,0x4(%esp)
  8005a9:	00 
  8005aa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005ad:	89 14 24             	mov    %edx,(%esp)
  8005b0:	e8 e6 04 00 00       	call   800a9b <strcmp>
  8005b5:	85 c0                	test   %eax,%eax
  8005b7:	75 0f                	jne    8005c8 <vprintfmt+0x1be>
  8005b9:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005c0:	00 00 00 
  8005c3:	e9 65 fe ff ff       	jmp    80042d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005c8:	c7 44 24 04 e6 10 80 	movl   $0x8010e6,0x4(%esp)
  8005cf:	00 
  8005d0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005d3:	89 0c 24             	mov    %ecx,(%esp)
  8005d6:	e8 c0 04 00 00       	call   800a9b <strcmp>
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	75 0f                	jne    8005ee <vprintfmt+0x1e4>
  8005df:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005e6:	00 00 00 
  8005e9:	e9 3f fe ff ff       	jmp    80042d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005ee:	c7 44 24 04 ea 10 80 	movl   $0x8010ea,0x4(%esp)
  8005f5:	00 
  8005f6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005f9:	89 3c 24             	mov    %edi,(%esp)
  8005fc:	e8 9a 04 00 00       	call   800a9b <strcmp>
  800601:	85 c0                	test   %eax,%eax
  800603:	75 0f                	jne    800614 <vprintfmt+0x20a>
  800605:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  80060c:	00 00 00 
  80060f:	e9 19 fe ff ff       	jmp    80042d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800614:	c7 44 24 04 ee 10 80 	movl   $0x8010ee,0x4(%esp)
  80061b:	00 
  80061c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	e8 74 04 00 00       	call   800a9b <strcmp>
  800627:	85 c0                	test   %eax,%eax
  800629:	75 0f                	jne    80063a <vprintfmt+0x230>
  80062b:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800632:	00 00 00 
  800635:	e9 f3 fd ff ff       	jmp    80042d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80063a:	c7 44 24 04 f2 10 80 	movl   $0x8010f2,0x4(%esp)
  800641:	00 
  800642:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800645:	89 14 24             	mov    %edx,(%esp)
  800648:	e8 4e 04 00 00       	call   800a9b <strcmp>
  80064d:	83 f8 01             	cmp    $0x1,%eax
  800650:	19 c0                	sbb    %eax,%eax
  800652:	f7 d0                	not    %eax
  800654:	83 c0 08             	add    $0x8,%eax
  800657:	a3 04 20 80 00       	mov    %eax,0x802004
  80065c:	e9 cc fd ff ff       	jmp    80042d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 50 04             	lea    0x4(%eax),%edx
  800667:	89 55 14             	mov    %edx,0x14(%ebp)
  80066a:	8b 00                	mov    (%eax),%eax
  80066c:	89 c2                	mov    %eax,%edx
  80066e:	c1 fa 1f             	sar    $0x1f,%edx
  800671:	31 d0                	xor    %edx,%eax
  800673:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800675:	83 f8 06             	cmp    $0x6,%eax
  800678:	7f 0b                	jg     800685 <vprintfmt+0x27b>
  80067a:	8b 14 85 c4 12 80 00 	mov    0x8012c4(,%eax,4),%edx
  800681:	85 d2                	test   %edx,%edx
  800683:	75 23                	jne    8006a8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800685:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800689:	c7 44 24 08 f6 10 80 	movl   $0x8010f6,0x8(%esp)
  800690:	00 
  800691:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800695:	8b 7d 08             	mov    0x8(%ebp),%edi
  800698:	89 3c 24             	mov    %edi,(%esp)
  80069b:	e8 42 fd ff ff       	call   8003e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a3:	e9 85 fd ff ff       	jmp    80042d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ac:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  8006b3:	00 
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bb:	89 3c 24             	mov    %edi,(%esp)
  8006be:	e8 1f fd ff ff       	call   8003e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006c6:	e9 62 fd ff ff       	jmp    80042d <vprintfmt+0x23>
  8006cb:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006d1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006df:	85 f6                	test   %esi,%esi
  8006e1:	b8 d7 10 80 00       	mov    $0x8010d7,%eax
  8006e6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006e9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006ed:	7e 06                	jle    8006f5 <vprintfmt+0x2eb>
  8006ef:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006f3:	75 13                	jne    800708 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f5:	0f be 06             	movsbl (%esi),%eax
  8006f8:	83 c6 01             	add    $0x1,%esi
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	0f 85 94 00 00 00    	jne    800797 <vprintfmt+0x38d>
  800703:	e9 81 00 00 00       	jmp    800789 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800708:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070c:	89 34 24             	mov    %esi,(%esp)
  80070f:	e8 97 02 00 00       	call   8009ab <strnlen>
  800714:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800717:	29 c2                	sub    %eax,%edx
  800719:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e d5                	jle    8006f5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800720:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800724:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800727:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80072a:	89 d6                	mov    %edx,%esi
  80072c:	89 cf                	mov    %ecx,%edi
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	89 3c 24             	mov    %edi,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800738:	83 ee 01             	sub    $0x1,%esi
  80073b:	75 f1                	jne    80072e <vprintfmt+0x324>
  80073d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800740:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800743:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800746:	eb ad                	jmp    8006f5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800748:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80074c:	74 1b                	je     800769 <vprintfmt+0x35f>
  80074e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800751:	83 fa 5e             	cmp    $0x5e,%edx
  800754:	76 13                	jbe    800769 <vprintfmt+0x35f>
					putch('?', putdat);
  800756:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800764:	ff 55 08             	call   *0x8(%ebp)
  800767:	eb 0d                	jmp    800776 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800769:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80076c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800776:	83 eb 01             	sub    $0x1,%ebx
  800779:	0f be 06             	movsbl (%esi),%eax
  80077c:	83 c6 01             	add    $0x1,%esi
  80077f:	85 c0                	test   %eax,%eax
  800781:	75 1a                	jne    80079d <vprintfmt+0x393>
  800783:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800786:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800789:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800790:	7f 1c                	jg     8007ae <vprintfmt+0x3a4>
  800792:	e9 96 fc ff ff       	jmp    80042d <vprintfmt+0x23>
  800797:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80079a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079d:	85 ff                	test   %edi,%edi
  80079f:	78 a7                	js     800748 <vprintfmt+0x33e>
  8007a1:	83 ef 01             	sub    $0x1,%edi
  8007a4:	79 a2                	jns    800748 <vprintfmt+0x33e>
  8007a6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007a9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007ac:	eb db                	jmp    800789 <vprintfmt+0x37f>
  8007ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b1:	89 de                	mov    %ebx,%esi
  8007b3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c3:	83 eb 01             	sub    $0x1,%ebx
  8007c6:	75 ee                	jne    8007b6 <vprintfmt+0x3ac>
  8007c8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007cd:	e9 5b fc ff ff       	jmp    80042d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d2:	83 f9 01             	cmp    $0x1,%ecx
  8007d5:	7e 10                	jle    8007e7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 08             	lea    0x8(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 30                	mov    (%eax),%esi
  8007e2:	8b 78 04             	mov    0x4(%eax),%edi
  8007e5:	eb 26                	jmp    80080d <vprintfmt+0x403>
	else if (lflag)
  8007e7:	85 c9                	test   %ecx,%ecx
  8007e9:	74 12                	je     8007fd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 50 04             	lea    0x4(%eax),%edx
  8007f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f4:	8b 30                	mov    (%eax),%esi
  8007f6:	89 f7                	mov    %esi,%edi
  8007f8:	c1 ff 1f             	sar    $0x1f,%edi
  8007fb:	eb 10                	jmp    80080d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 50 04             	lea    0x4(%eax),%edx
  800803:	89 55 14             	mov    %edx,0x14(%ebp)
  800806:	8b 30                	mov    (%eax),%esi
  800808:	89 f7                	mov    %esi,%edi
  80080a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80080d:	85 ff                	test   %edi,%edi
  80080f:	78 0e                	js     80081f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800811:	89 f0                	mov    %esi,%eax
  800813:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800815:	be 0a 00 00 00       	mov    $0xa,%esi
  80081a:	e9 84 00 00 00       	jmp    8008a3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80081f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800823:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80082d:	89 f0                	mov    %esi,%eax
  80082f:	89 fa                	mov    %edi,%edx
  800831:	f7 d8                	neg    %eax
  800833:	83 d2 00             	adc    $0x0,%edx
  800836:	f7 da                	neg    %edx
			}
			base = 10;
  800838:	be 0a 00 00 00       	mov    $0xa,%esi
  80083d:	eb 64                	jmp    8008a3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083f:	89 ca                	mov    %ecx,%edx
  800841:	8d 45 14             	lea    0x14(%ebp),%eax
  800844:	e8 42 fb ff ff       	call   80038b <getuint>
			base = 10;
  800849:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80084e:	eb 53                	jmp    8008a3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800850:	89 ca                	mov    %ecx,%edx
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	e8 31 fb ff ff       	call   80038b <getuint>
    			base = 8;
  80085a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80085f:	eb 42                	jmp    8008a3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800861:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800865:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80086c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80086f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800873:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80087a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	8d 50 04             	lea    0x4(%eax),%edx
  800883:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800886:	8b 00                	mov    (%eax),%eax
  800888:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800892:	eb 0f                	jmp    8008a3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800894:	89 ca                	mov    %ecx,%edx
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
  800899:	e8 ed fa ff ff       	call   80038b <getuint>
			base = 16;
  80089e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008a7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008ab:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008ae:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008b2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008bd:	89 da                	mov    %ebx,%edx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	e8 e9 f9 ff ff       	call   8002b0 <printnum>
			break;
  8008c7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008ca:	e9 5e fb ff ff       	jmp    80042d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d3:	89 14 24             	mov    %edx,(%esp)
  8008d6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008dc:	e9 4c fb ff ff       	jmp    80042d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008ec:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ef:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f3:	0f 84 34 fb ff ff    	je     80042d <vprintfmt+0x23>
  8008f9:	83 ee 01             	sub    $0x1,%esi
  8008fc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800900:	75 f7                	jne    8008f9 <vprintfmt+0x4ef>
  800902:	e9 26 fb ff ff       	jmp    80042d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800907:	83 c4 5c             	add    $0x5c,%esp
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	83 ec 28             	sub    $0x28,%esp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800922:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092c:	85 c0                	test   %eax,%eax
  80092e:	74 30                	je     800960 <vsnprintf+0x51>
  800930:	85 d2                	test   %edx,%edx
  800932:	7e 2c                	jle    800960 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800934:	8b 45 14             	mov    0x14(%ebp),%eax
  800937:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093b:	8b 45 10             	mov    0x10(%ebp),%eax
  80093e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800942:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	c7 04 24 c5 03 80 00 	movl   $0x8003c5,(%esp)
  800950:	e8 b5 fa ff ff       	call   80040a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800955:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800958:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095e:	eb 05                	jmp    800965 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800960:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800970:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800974:	8b 45 10             	mov    0x10(%ebp),%eax
  800977:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 82 ff ff ff       	call   80090f <vsnprintf>
	va_end(ap);

	return rc;
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    
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
