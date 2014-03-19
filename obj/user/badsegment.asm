
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
  800049:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800053:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	7e 08                	jle    800062 <libmain+0x22>
		binaryname = argv[0];
  80005a:	8b 0a                	mov    (%edx),%ecx
  80005c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800062:	89 54 24 04          	mov    %edx,0x4(%esp)
  800066:	89 04 24             	mov    %eax,(%esp)
  800069:	e8 c6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006e:	e8 05 00 00 00       	call   800078 <exit>
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    
  800075:	00 00                	add    %al,(%eax)
	...

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800085:	e8 61 00 00 00       	call   8000eb <sys_env_destroy>
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800095:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800098:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000b1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000b4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000b7:	89 ec                	mov    %ebp,%esp
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e7:	89 ec                	mov    %ebp,%esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 38             	sub    $0x38,%esp
  8000f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 52 10 80 	movl   $0x801052,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800136:	e8 3d 00 00 00       	call   800178 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80013e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800141:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800144:	89 ec                	mov    %ebp,%esp
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800151:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800154:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 02 00 00 00       	mov    $0x2,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800171:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800174:	89 ec                	mov    %ebp,%esp
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800180:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800189:	e8 ba ff ff ff       	call   800148 <sys_getenvid>
  80018e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800191:	89 54 24 10          	mov    %edx,0x10(%esp)
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  8001ab:	e8 c3 00 00 00       	call   800273 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 53 00 00 00       	call   800212 <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 a4 10 80 00 	movl   $0x8010a4,(%esp)
  8001c6:	e8 a8 00 00 00       	call   800273 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x53>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	83 c0 01             	add    $0x1,%eax
  8001e6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ed:	75 19                	jne    800208 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f6:	00 
  8001f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fa:	89 04 24             	mov    %eax,(%esp)
  8001fd:	e8 8a fe ff ff       	call   80008c <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800208:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020c:	83 c4 14             	add    $0x14,%esp
  80020f:	5b                   	pop    %ebx
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800222:	00 00 00 
	b.cnt = 0;
  800225:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800232:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024e:	e8 97 01 00 00       	call   8003ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800253:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 21 fe ff ff       	call   80008c <sys_cputs>

	return b.cnt;
}
  80026b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800279:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 87 ff ff ff       	call   800212 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    
  80028d:	00 00                	add    %al,(%eax)
	...

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b8:	72 11                	jb     8002cb <printnum+0x3b>
  8002ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002c0:	76 09                	jbe    8002cb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c2:	83 eb 01             	sub    $0x1,%ebx
  8002c5:	85 db                	test   %ebx,%ebx
  8002c7:	7f 51                	jg     80031a <printnum+0x8a>
  8002c9:	eb 5e                	jmp    800329 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002cf:	83 eb 01             	sub    $0x1,%ebx
  8002d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ec:	00 
  8002ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fa:	e8 a1 0a 00 00       	call   800da0 <__udivdi3>
  8002ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800303:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030e:	89 fa                	mov    %edi,%edx
  800310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800313:	e8 78 ff ff ff       	call   800290 <printnum>
  800318:	eb 0f                	jmp    800329 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031e:	89 34 24             	mov    %esi,(%esp)
  800321:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800324:	83 eb 01             	sub    $0x1,%ebx
  800327:	75 f1                	jne    80031a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800331:	8b 45 10             	mov    0x10(%ebp),%eax
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033f:	00 
  800340:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034d:	e8 7e 0b 00 00       	call   800ed0 <__umoddi3>
  800352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800356:	0f be 80 a6 10 80 00 	movsbl 0x8010a6(%eax),%eax
  80035d:	89 04 24             	mov    %eax,(%esp)
  800360:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800363:	83 c4 3c             	add    $0x3c,%esp
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036e:	83 fa 01             	cmp    $0x1,%edx
  800371:	7e 0e                	jle    800381 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800373:	8b 10                	mov    (%eax),%edx
  800375:	8d 4a 08             	lea    0x8(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 02                	mov    (%edx),%eax
  80037c:	8b 52 04             	mov    0x4(%edx),%edx
  80037f:	eb 22                	jmp    8003a3 <getuint+0x38>
	else if (lflag)
  800381:	85 d2                	test   %edx,%edx
  800383:	74 10                	je     800395 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800385:	8b 10                	mov    (%eax),%edx
  800387:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 02                	mov    (%edx),%eax
  80038e:	ba 00 00 00 00       	mov    $0x0,%edx
  800393:	eb 0e                	jmp    8003a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800395:	8b 10                	mov    (%eax),%edx
  800397:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039a:	89 08                	mov    %ecx,(%eax)
  80039c:	8b 02                	mov    (%edx),%eax
  80039e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b4:	73 0a                	jae    8003c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b9:	88 0a                	mov    %cl,(%edx)
  8003bb:	83 c2 01             	add    $0x1,%edx
  8003be:	89 10                	mov    %edx,(%eax)
}
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e0:	89 04 24             	mov    %eax,(%esp)
  8003e3:	e8 02 00 00 00       	call   8003ea <vprintfmt>
	va_end(ap);
}
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	57                   	push   %edi
  8003ee:	56                   	push   %esi
  8003ef:	53                   	push   %ebx
  8003f0:	83 ec 5c             	sub    $0x5c,%esp
  8003f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f9:	eb 12                	jmp    80040d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	0f 84 e4 04 00 00    	je     8008e7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800403:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040d:	0f b6 06             	movzbl (%esi),%eax
  800410:	83 c6 01             	add    $0x1,%esi
  800413:	83 f8 25             	cmp    $0x25,%eax
  800416:	75 e3                	jne    8003fb <vprintfmt+0x11>
  800418:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80041c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800423:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800428:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80042f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800434:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800437:	eb 2b                	jmp    800464 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800440:	eb 22                	jmp    800464 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800445:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800449:	eb 19                	jmp    800464 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80044e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800455:	eb 0d                	jmp    800464 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800457:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80045a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	0f b6 06             	movzbl (%esi),%eax
  800467:	0f b6 d0             	movzbl %al,%edx
  80046a:	8d 7e 01             	lea    0x1(%esi),%edi
  80046d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800470:	83 e8 23             	sub    $0x23,%eax
  800473:	3c 55                	cmp    $0x55,%al
  800475:	0f 87 46 04 00 00    	ja     8008c1 <vprintfmt+0x4d7>
  80047b:	0f b6 c0             	movzbl %al,%eax
  80047e:	ff 24 85 4c 11 80 00 	jmp    *0x80114c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800485:	83 ea 30             	sub    $0x30,%edx
  800488:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80048b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80048f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800495:	83 fa 09             	cmp    $0x9,%edx
  800498:	77 4a                	ja     8004e4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004a0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004a3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004a7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004aa:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004ad:	83 fa 09             	cmp    $0x9,%edx
  8004b0:	76 eb                	jbe    80049d <vprintfmt+0xb3>
  8004b2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004b5:	eb 2d                	jmp    8004e4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 50 04             	lea    0x4(%eax),%edx
  8004bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c8:	eb 1a                	jmp    8004e4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004cd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d1:	79 91                	jns    800464 <vprintfmt+0x7a>
  8004d3:	e9 73 ff ff ff       	jmp    80044b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004db:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004e2:	eb 80                	jmp    800464 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004e4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e8:	0f 89 76 ff ff ff    	jns    800464 <vprintfmt+0x7a>
  8004ee:	e9 64 ff ff ff       	jmp    800457 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f9:	e9 66 ff ff ff       	jmp    800464 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800516:	e9 f2 fe ff ff       	jmp    80040d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80051b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80051f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800522:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800526:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800529:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80052d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800530:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800533:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800537:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80053a:	80 f9 09             	cmp    $0x9,%cl
  80053d:	77 1d                	ja     80055c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80053f:	0f be c0             	movsbl %al,%eax
  800542:	6b c0 64             	imul   $0x64,%eax,%eax
  800545:	0f be d2             	movsbl %dl,%edx
  800548:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80054b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800552:	a3 04 20 80 00       	mov    %eax,0x802004
  800557:	e9 b1 fe ff ff       	jmp    80040d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80055c:	c7 44 24 04 be 10 80 	movl   $0x8010be,0x4(%esp)
  800563:	00 
  800564:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800567:	89 04 24             	mov    %eax,(%esp)
  80056a:	e8 0c 05 00 00       	call   800a7b <strcmp>
  80056f:	85 c0                	test   %eax,%eax
  800571:	75 0f                	jne    800582 <vprintfmt+0x198>
  800573:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80057a:	00 00 00 
  80057d:	e9 8b fe ff ff       	jmp    80040d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800582:	c7 44 24 04 c2 10 80 	movl   $0x8010c2,0x4(%esp)
  800589:	00 
  80058a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80058d:	89 14 24             	mov    %edx,(%esp)
  800590:	e8 e6 04 00 00       	call   800a7b <strcmp>
  800595:	85 c0                	test   %eax,%eax
  800597:	75 0f                	jne    8005a8 <vprintfmt+0x1be>
  800599:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005a0:	00 00 00 
  8005a3:	e9 65 fe ff ff       	jmp    80040d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005a8:	c7 44 24 04 c6 10 80 	movl   $0x8010c6,0x4(%esp)
  8005af:	00 
  8005b0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005b3:	89 0c 24             	mov    %ecx,(%esp)
  8005b6:	e8 c0 04 00 00       	call   800a7b <strcmp>
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	75 0f                	jne    8005ce <vprintfmt+0x1e4>
  8005bf:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005c6:	00 00 00 
  8005c9:	e9 3f fe ff ff       	jmp    80040d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005ce:	c7 44 24 04 ca 10 80 	movl   $0x8010ca,0x4(%esp)
  8005d5:	00 
  8005d6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005d9:	89 3c 24             	mov    %edi,(%esp)
  8005dc:	e8 9a 04 00 00       	call   800a7b <strcmp>
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	75 0f                	jne    8005f4 <vprintfmt+0x20a>
  8005e5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8005ec:	00 00 00 
  8005ef:	e9 19 fe ff ff       	jmp    80040d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005f4:	c7 44 24 04 ce 10 80 	movl   $0x8010ce,0x4(%esp)
  8005fb:	00 
  8005fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	e8 74 04 00 00       	call   800a7b <strcmp>
  800607:	85 c0                	test   %eax,%eax
  800609:	75 0f                	jne    80061a <vprintfmt+0x230>
  80060b:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800612:	00 00 00 
  800615:	e9 f3 fd ff ff       	jmp    80040d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80061a:	c7 44 24 04 d2 10 80 	movl   $0x8010d2,0x4(%esp)
  800621:	00 
  800622:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800625:	89 14 24             	mov    %edx,(%esp)
  800628:	e8 4e 04 00 00       	call   800a7b <strcmp>
  80062d:	83 f8 01             	cmp    $0x1,%eax
  800630:	19 c0                	sbb    %eax,%eax
  800632:	f7 d0                	not    %eax
  800634:	83 c0 08             	add    $0x8,%eax
  800637:	a3 04 20 80 00       	mov    %eax,0x802004
  80063c:	e9 cc fd ff ff       	jmp    80040d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 00                	mov    (%eax),%eax
  80064c:	89 c2                	mov    %eax,%edx
  80064e:	c1 fa 1f             	sar    $0x1f,%edx
  800651:	31 d0                	xor    %edx,%eax
  800653:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800655:	83 f8 06             	cmp    $0x6,%eax
  800658:	7f 0b                	jg     800665 <vprintfmt+0x27b>
  80065a:	8b 14 85 a4 12 80 00 	mov    0x8012a4(,%eax,4),%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	75 23                	jne    800688 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800665:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800669:	c7 44 24 08 d6 10 80 	movl   $0x8010d6,0x8(%esp)
  800670:	00 
  800671:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800675:	8b 7d 08             	mov    0x8(%ebp),%edi
  800678:	89 3c 24             	mov    %edi,(%esp)
  80067b:	e8 42 fd ff ff       	call   8003c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800680:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800683:	e9 85 fd ff ff       	jmp    80040d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800688:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068c:	c7 44 24 08 df 10 80 	movl   $0x8010df,0x8(%esp)
  800693:	00 
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069b:	89 3c 24             	mov    %edi,(%esp)
  80069e:	e8 1f fd ff ff       	call   8003c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006a6:	e9 62 fd ff ff       	jmp    80040d <vprintfmt+0x23>
  8006ab:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006b1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006bf:	85 f6                	test   %esi,%esi
  8006c1:	b8 b7 10 80 00       	mov    $0x8010b7,%eax
  8006c6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006c9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006cd:	7e 06                	jle    8006d5 <vprintfmt+0x2eb>
  8006cf:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006d3:	75 13                	jne    8006e8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d5:	0f be 06             	movsbl (%esi),%eax
  8006d8:	83 c6 01             	add    $0x1,%esi
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	0f 85 94 00 00 00    	jne    800777 <vprintfmt+0x38d>
  8006e3:	e9 81 00 00 00       	jmp    800769 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ec:	89 34 24             	mov    %esi,(%esp)
  8006ef:	e8 97 02 00 00       	call   80098b <strnlen>
  8006f4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f7:	29 c2                	sub    %eax,%edx
  8006f9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	7e d5                	jle    8006d5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800700:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800704:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800707:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80070a:	89 d6                	mov    %edx,%esi
  80070c:	89 cf                	mov    %ecx,%edi
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	89 3c 24             	mov    %edi,(%esp)
  800715:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800718:	83 ee 01             	sub    $0x1,%esi
  80071b:	75 f1                	jne    80070e <vprintfmt+0x324>
  80071d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800720:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800723:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800726:	eb ad                	jmp    8006d5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800728:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80072c:	74 1b                	je     800749 <vprintfmt+0x35f>
  80072e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800731:	83 fa 5e             	cmp    $0x5e,%edx
  800734:	76 13                	jbe    800749 <vprintfmt+0x35f>
					putch('?', putdat);
  800736:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800744:	ff 55 08             	call   *0x8(%ebp)
  800747:	eb 0d                	jmp    800756 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800749:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80074c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800756:	83 eb 01             	sub    $0x1,%ebx
  800759:	0f be 06             	movsbl (%esi),%eax
  80075c:	83 c6 01             	add    $0x1,%esi
  80075f:	85 c0                	test   %eax,%eax
  800761:	75 1a                	jne    80077d <vprintfmt+0x393>
  800763:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800766:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800769:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80076c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800770:	7f 1c                	jg     80078e <vprintfmt+0x3a4>
  800772:	e9 96 fc ff ff       	jmp    80040d <vprintfmt+0x23>
  800777:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80077a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80077d:	85 ff                	test   %edi,%edi
  80077f:	78 a7                	js     800728 <vprintfmt+0x33e>
  800781:	83 ef 01             	sub    $0x1,%edi
  800784:	79 a2                	jns    800728 <vprintfmt+0x33e>
  800786:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800789:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80078c:	eb db                	jmp    800769 <vprintfmt+0x37f>
  80078e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800791:	89 de                	mov    %ebx,%esi
  800793:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800796:	89 74 24 04          	mov    %esi,0x4(%esp)
  80079a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007a1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a3:	83 eb 01             	sub    $0x1,%ebx
  8007a6:	75 ee                	jne    800796 <vprintfmt+0x3ac>
  8007a8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007ad:	e9 5b fc ff ff       	jmp    80040d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b2:	83 f9 01             	cmp    $0x1,%ecx
  8007b5:	7e 10                	jle    8007c7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 08             	lea    0x8(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c0:	8b 30                	mov    (%eax),%esi
  8007c2:	8b 78 04             	mov    0x4(%eax),%edi
  8007c5:	eb 26                	jmp    8007ed <vprintfmt+0x403>
	else if (lflag)
  8007c7:	85 c9                	test   %ecx,%ecx
  8007c9:	74 12                	je     8007dd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 04             	lea    0x4(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 30                	mov    (%eax),%esi
  8007d6:	89 f7                	mov    %esi,%edi
  8007d8:	c1 ff 1f             	sar    $0x1f,%edi
  8007db:	eb 10                	jmp    8007ed <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 30                	mov    (%eax),%esi
  8007e8:	89 f7                	mov    %esi,%edi
  8007ea:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ed:	85 ff                	test   %edi,%edi
  8007ef:	78 0e                	js     8007ff <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f5:	be 0a 00 00 00       	mov    $0xa,%esi
  8007fa:	e9 84 00 00 00       	jmp    800883 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800803:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80080a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	89 fa                	mov    %edi,%edx
  800811:	f7 d8                	neg    %eax
  800813:	83 d2 00             	adc    $0x0,%edx
  800816:	f7 da                	neg    %edx
			}
			base = 10;
  800818:	be 0a 00 00 00       	mov    $0xa,%esi
  80081d:	eb 64                	jmp    800883 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081f:	89 ca                	mov    %ecx,%edx
  800821:	8d 45 14             	lea    0x14(%ebp),%eax
  800824:	e8 42 fb ff ff       	call   80036b <getuint>
			base = 10;
  800829:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80082e:	eb 53                	jmp    800883 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800830:	89 ca                	mov    %ecx,%edx
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 31 fb ff ff       	call   80036b <getuint>
    			base = 8;
  80083a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80083f:	eb 42                	jmp    800883 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800841:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800845:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80084c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80084f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800853:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80085a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085d:	8b 45 14             	mov    0x14(%ebp),%eax
  800860:	8d 50 04             	lea    0x4(%eax),%edx
  800863:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800866:	8b 00                	mov    (%eax),%eax
  800868:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800872:	eb 0f                	jmp    800883 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800874:	89 ca                	mov    %ecx,%edx
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
  800879:	e8 ed fa ff ff       	call   80036b <getuint>
			base = 16;
  80087e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800883:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800887:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80088b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80088e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800892:	89 74 24 08          	mov    %esi,0x8(%esp)
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	89 54 24 04          	mov    %edx,0x4(%esp)
  80089d:	89 da                	mov    %ebx,%edx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	e8 e9 f9 ff ff       	call   800290 <printnum>
			break;
  8008a7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008aa:	e9 5e fb ff ff       	jmp    80040d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b3:	89 14 24             	mov    %edx,(%esp)
  8008b6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008bc:	e9 4c fb ff ff       	jmp    80040d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008cc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008d3:	0f 84 34 fb ff ff    	je     80040d <vprintfmt+0x23>
  8008d9:	83 ee 01             	sub    $0x1,%esi
  8008dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008e0:	75 f7                	jne    8008d9 <vprintfmt+0x4ef>
  8008e2:	e9 26 fb ff ff       	jmp    80040d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008e7:	83 c4 5c             	add    $0x5c,%esp
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	83 ec 28             	sub    $0x28,%esp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800902:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800905:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090c:	85 c0                	test   %eax,%eax
  80090e:	74 30                	je     800940 <vsnprintf+0x51>
  800910:	85 d2                	test   %edx,%edx
  800912:	7e 2c                	jle    800940 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800914:	8b 45 14             	mov    0x14(%ebp),%eax
  800917:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80091b:	8b 45 10             	mov    0x10(%ebp),%eax
  80091e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800922:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	c7 04 24 a5 03 80 00 	movl   $0x8003a5,(%esp)
  800930:	e8 b5 fa ff ff       	call   8003ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800935:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800938:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093e:	eb 05                	jmp    800945 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800940:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800950:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800954:	8b 45 10             	mov    0x10(%ebp),%eax
  800957:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	e8 82 ff ff ff       	call   8008ef <vsnprintf>
	va_end(ap);

	return rc;
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    
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
