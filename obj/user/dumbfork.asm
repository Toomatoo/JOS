
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 1f 02 00 00       	call   800250 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 a6 0f 00 00       	call   800ffc <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 20 15 80 	movl   $0x801520,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 33 15 80 00 	movl   $0x801533,(%esp)
  800075:	e8 3a 02 00 00       	call   8002b4 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 bd 0f 00 00       	call   80105b <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 43 15 80 	movl   $0x801543,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 33 15 80 00 	movl   $0x801533,(%esp)
  8000bd:	e8 f2 01 00 00       	call   8002b4 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 12 0c 00 00       	call   800cec <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 cb 0f 00 00       	call   8010b9 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 54 15 80 	movl   $0x801554,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 33 15 80 00 	movl   $0x801533,(%esp)
  80010d:	e8 a2 01 00 00       	call   8002b4 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 67 15 80 	movl   $0x801567,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 33 15 80 00 	movl   $0x801533,(%esp)
  80014d:	e8 62 01 00 00       	call   8002b4 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 19                	jne    80016f <dumbfork+0x56>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 41 0e 00 00       	call   800f9c <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  80016d:	eb 7e                	jmp    8001ed <dumbfork+0xd4>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80016f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800176:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80017b:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800180:	76 23                	jbe    8001a5 <dumbfork+0x8c>
  800182:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	89 1c 24             	mov    %ebx,(%esp)
  80018e:	e8 a1 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800196:	05 00 10 00 00       	add    $0x1000,%eax
  80019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019e:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
  8001a3:	72 e2                	jb     800187 <dumbfork+0x6e>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 7b fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c0:	00 
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 4e 0f 00 00       	call   801117 <sys_env_set_status>
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	79 20                	jns    8001ed <dumbfork+0xd4>
		panic("sys_env_set_status: %e", r);
  8001cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d1:	c7 44 24 08 77 15 80 	movl   $0x801577,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 33 15 80 00 	movl   $0x801533,(%esp)
  8001e8:	e8 c7 00 00 00       	call   8002b4 <_panic>

	return envid;
}
  8001ed:	89 f0                	mov    %esi,%eax
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	57                   	push   %edi
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001ff:	e8 15 ff ff ff       	call   800119 <dumbfork>
  800204:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800206:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020b:	bf 95 15 80 00       	mov    $0x801595,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800210:	eb 26                	jmp    800238 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800212:	85 db                	test   %ebx,%ebx
  800214:	b8 8e 15 80 00       	mov    $0x80158e,%eax
  800219:	0f 44 c7             	cmove  %edi,%eax
  80021c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800220:	89 74 24 04          	mov    %esi,0x4(%esp)
  800224:	c7 04 24 9b 15 80 00 	movl   $0x80159b,(%esp)
  80022b:	e8 7f 01 00 00       	call   8003af <cprintf>
		sys_yield();
  800230:	e8 97 0d 00 00       	call   800fcc <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800235:	83 c6 01             	add    $0x1,%esi
  800238:	83 fb 01             	cmp    $0x1,%ebx
  80023b:	19 c0                	sbb    %eax,%eax
  80023d:	83 e0 0a             	and    $0xa,%eax
  800240:	83 c0 0a             	add    $0xa,%eax
  800243:	39 c6                	cmp    %eax,%esi
  800245:	7c cb                	jl     800212 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800247:	83 c4 1c             	add    $0x1c,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    
	...

00800250 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
  800256:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800259:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80025c:	8b 75 08             	mov    0x8(%ebp),%esi
  80025f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800262:	e8 35 0d 00 00       	call   800f9c <sys_getenvid>
  800267:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80026f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800274:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800279:	85 f6                	test   %esi,%esi
  80027b:	7e 07                	jle    800284 <libmain+0x34>
		binaryname = argv[0];
  80027d:	8b 03                	mov    (%ebx),%eax
  80027f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800284:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800288:	89 34 24             	mov    %esi,(%esp)
  80028b:	e8 66 ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  800290:	e8 0b 00 00 00       	call   8002a0 <exit>
}
  800295:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800298:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80029b:	89 ec                	mov    %ebp,%esp
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    
	...

008002a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ad:	e8 8d 0c 00 00       	call   800f3f <sys_env_destroy>
}
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002bf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002c5:	e8 d2 0c 00 00       	call   800f9c <sys_getenvid>
  8002ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e0:	c7 04 24 b8 15 80 00 	movl   $0x8015b8,(%esp)
  8002e7:	e8 c3 00 00 00       	call   8003af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 53 00 00 00       	call   80034e <vcprintf>
	cprintf("\n");
  8002fb:	c7 04 24 ab 15 80 00 	movl   $0x8015ab,(%esp)
  800302:	e8 a8 00 00 00       	call   8003af <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800307:	cc                   	int3   
  800308:	eb fd                	jmp    800307 <_panic+0x53>
	...

0080030c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	53                   	push   %ebx
  800310:	83 ec 14             	sub    $0x14,%esp
  800313:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800316:	8b 03                	mov    (%ebx),%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80031f:	83 c0 01             	add    $0x1,%eax
  800322:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800324:	3d ff 00 00 00       	cmp    $0xff,%eax
  800329:	75 19                	jne    800344 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80032b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800332:	00 
  800333:	8d 43 08             	lea    0x8(%ebx),%eax
  800336:	89 04 24             	mov    %eax,(%esp)
  800339:	e8 a2 0b 00 00       	call   800ee0 <sys_cputs>
		b->idx = 0;
  80033e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800344:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800348:	83 c4 14             	add    $0x14,%esp
  80034b:	5b                   	pop    %ebx
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800357:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035e:	00 00 00 
	b.cnt = 0;
  800361:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800368:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80036b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	89 44 24 08          	mov    %eax,0x8(%esp)
  800379:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800383:	c7 04 24 0c 03 80 00 	movl   $0x80030c,(%esp)
  80038a:	e8 97 01 00 00       	call   800526 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80038f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	e8 39 0b 00 00       	call   800ee0 <sys_cputs>

	return b.cnt;
}
  8003a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ad:	c9                   	leave  
  8003ae:	c3                   	ret    

008003af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	e8 87 ff ff ff       	call   80034e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c7:	c9                   	leave  
  8003c8:	c3                   	ret    
  8003c9:	00 00                	add    %al,(%eax)
	...

008003cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	57                   	push   %edi
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 3c             	sub    $0x3c,%esp
  8003d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d8:	89 d7                	mov    %edx,%edi
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003f4:	72 11                	jb     800407 <printnum+0x3b>
  8003f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003f9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003fc:	76 09                	jbe    800407 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fe:	83 eb 01             	sub    $0x1,%ebx
  800401:	85 db                	test   %ebx,%ebx
  800403:	7f 51                	jg     800456 <printnum+0x8a>
  800405:	eb 5e                	jmp    800465 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800407:	89 74 24 10          	mov    %esi,0x10(%esp)
  80040b:	83 eb 01             	sub    $0x1,%ebx
  80040e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800412:	8b 45 10             	mov    0x10(%ebp),%eax
  800415:	89 44 24 08          	mov    %eax,0x8(%esp)
  800419:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80041d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800421:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800428:	00 
  800429:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800432:	89 44 24 04          	mov    %eax,0x4(%esp)
  800436:	e8 35 0e 00 00       	call   801270 <__udivdi3>
  80043b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80043f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044a:	89 fa                	mov    %edi,%edx
  80044c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044f:	e8 78 ff ff ff       	call   8003cc <printnum>
  800454:	eb 0f                	jmp    800465 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800456:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80045a:	89 34 24             	mov    %esi,(%esp)
  80045d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800460:	83 eb 01             	sub    $0x1,%ebx
  800463:	75 f1                	jne    800456 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800465:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800469:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80046d:	8b 45 10             	mov    0x10(%ebp),%eax
  800470:	89 44 24 08          	mov    %eax,0x8(%esp)
  800474:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80047b:	00 
  80047c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047f:	89 04 24             	mov    %eax,(%esp)
  800482:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800485:	89 44 24 04          	mov    %eax,0x4(%esp)
  800489:	e8 12 0f 00 00       	call   8013a0 <__umoddi3>
  80048e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800492:	0f be 80 dc 15 80 00 	movsbl 0x8015dc(%eax),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80049f:	83 c4 3c             	add    $0x3c,%esp
  8004a2:	5b                   	pop    %ebx
  8004a3:	5e                   	pop    %esi
  8004a4:	5f                   	pop    %edi
  8004a5:	5d                   	pop    %ebp
  8004a6:	c3                   	ret    

008004a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a7:	55                   	push   %ebp
  8004a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004aa:	83 fa 01             	cmp    $0x1,%edx
  8004ad:	7e 0e                	jle    8004bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004af:	8b 10                	mov    (%eax),%edx
  8004b1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b4:	89 08                	mov    %ecx,(%eax)
  8004b6:	8b 02                	mov    (%edx),%eax
  8004b8:	8b 52 04             	mov    0x4(%edx),%edx
  8004bb:	eb 22                	jmp    8004df <getuint+0x38>
	else if (lflag)
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	74 10                	je     8004d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c6:	89 08                	mov    %ecx,(%eax)
  8004c8:	8b 02                	mov    (%edx),%eax
  8004ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cf:	eb 0e                	jmp    8004df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f0:	73 0a                	jae    8004fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004f5:	88 0a                	mov    %cl,(%edx)
  8004f7:	83 c2 01             	add    $0x1,%edx
  8004fa:	89 10                	mov    %edx,(%eax)
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800504:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800507:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050b:	8b 45 10             	mov    0x10(%ebp),%eax
  80050e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
  800515:	89 44 24 04          	mov    %eax,0x4(%esp)
  800519:	8b 45 08             	mov    0x8(%ebp),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	e8 02 00 00 00       	call   800526 <vprintfmt>
	va_end(ap);
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	57                   	push   %edi
  80052a:	56                   	push   %esi
  80052b:	53                   	push   %ebx
  80052c:	83 ec 5c             	sub    $0x5c,%esp
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	8b 75 10             	mov    0x10(%ebp),%esi
  800535:	eb 12                	jmp    800549 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800537:	85 c0                	test   %eax,%eax
  800539:	0f 84 e4 04 00 00    	je     800a23 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80053f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800549:	0f b6 06             	movzbl (%esi),%eax
  80054c:	83 c6 01             	add    $0x1,%esi
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e3                	jne    800537 <vprintfmt+0x11>
  800554:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800558:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80055f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800564:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80056b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800570:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800573:	eb 2b                	jmp    8005a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800578:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80057c:	eb 22                	jmp    8005a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800581:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800585:	eb 19                	jmp    8005a0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80058a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800591:	eb 0d                	jmp    8005a0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800593:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800596:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800599:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	0f b6 06             	movzbl (%esi),%eax
  8005a3:	0f b6 d0             	movzbl %al,%edx
  8005a6:	8d 7e 01             	lea    0x1(%esi),%edi
  8005a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ac:	83 e8 23             	sub    $0x23,%eax
  8005af:	3c 55                	cmp    $0x55,%al
  8005b1:	0f 87 46 04 00 00    	ja     8009fd <vprintfmt+0x4d7>
  8005b7:	0f b6 c0             	movzbl %al,%eax
  8005ba:	ff 24 85 c0 16 80 00 	jmp    *0x8016c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c1:	83 ea 30             	sub    $0x30,%edx
  8005c4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8005c7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005cb:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8005d1:	83 fa 09             	cmp    $0x9,%edx
  8005d4:	77 4a                	ja     800620 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005dc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005df:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005e3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005e6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005e9:	83 fa 09             	cmp    $0x9,%edx
  8005ec:	76 eb                	jbe    8005d9 <vprintfmt+0xb3>
  8005ee:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8005f1:	eb 2d                	jmp    800620 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800604:	eb 1a                	jmp    800620 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800609:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80060d:	79 91                	jns    8005a0 <vprintfmt+0x7a>
  80060f:	e9 73 ff ff ff       	jmp    800587 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800617:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80061e:	eb 80                	jmp    8005a0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800620:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800624:	0f 89 76 ff ff ff    	jns    8005a0 <vprintfmt+0x7a>
  80062a:	e9 64 ff ff ff       	jmp    800593 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800635:	e9 66 ff ff ff       	jmp    8005a0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800652:	e9 f2 fe ff ff       	jmp    800549 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800657:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80065b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80065e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800662:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800665:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800669:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80066c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80066f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800673:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800676:	80 f9 09             	cmp    $0x9,%cl
  800679:	77 1d                	ja     800698 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80067b:	0f be c0             	movsbl %al,%eax
  80067e:	6b c0 64             	imul   $0x64,%eax,%eax
  800681:	0f be d2             	movsbl %dl,%edx
  800684:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800687:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80068e:	a3 04 20 80 00       	mov    %eax,0x802004
  800693:	e9 b1 fe ff ff       	jmp    800549 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800698:	c7 44 24 04 f4 15 80 	movl   $0x8015f4,0x4(%esp)
  80069f:	00 
  8006a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006a3:	89 04 24             	mov    %eax,(%esp)
  8006a6:	e8 10 05 00 00       	call   800bbb <strcmp>
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	75 0f                	jne    8006be <vprintfmt+0x198>
  8006af:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8006b6:	00 00 00 
  8006b9:	e9 8b fe ff ff       	jmp    800549 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8006be:	c7 44 24 04 f8 15 80 	movl   $0x8015f8,0x4(%esp)
  8006c5:	00 
  8006c6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006c9:	89 14 24             	mov    %edx,(%esp)
  8006cc:	e8 ea 04 00 00       	call   800bbb <strcmp>
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	75 0f                	jne    8006e4 <vprintfmt+0x1be>
  8006d5:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8006dc:	00 00 00 
  8006df:	e9 65 fe ff ff       	jmp    800549 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8006e4:	c7 44 24 04 fc 15 80 	movl   $0x8015fc,0x4(%esp)
  8006eb:	00 
  8006ec:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8006ef:	89 0c 24             	mov    %ecx,(%esp)
  8006f2:	e8 c4 04 00 00       	call   800bbb <strcmp>
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	75 0f                	jne    80070a <vprintfmt+0x1e4>
  8006fb:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800702:	00 00 00 
  800705:	e9 3f fe ff ff       	jmp    800549 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80070a:	c7 44 24 04 00 16 80 	movl   $0x801600,0x4(%esp)
  800711:	00 
  800712:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800715:	89 3c 24             	mov    %edi,(%esp)
  800718:	e8 9e 04 00 00       	call   800bbb <strcmp>
  80071d:	85 c0                	test   %eax,%eax
  80071f:	75 0f                	jne    800730 <vprintfmt+0x20a>
  800721:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800728:	00 00 00 
  80072b:	e9 19 fe ff ff       	jmp    800549 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800730:	c7 44 24 04 04 16 80 	movl   $0x801604,0x4(%esp)
  800737:	00 
  800738:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	e8 78 04 00 00       	call   800bbb <strcmp>
  800743:	85 c0                	test   %eax,%eax
  800745:	75 0f                	jne    800756 <vprintfmt+0x230>
  800747:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80074e:	00 00 00 
  800751:	e9 f3 fd ff ff       	jmp    800549 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800756:	c7 44 24 04 08 16 80 	movl   $0x801608,0x4(%esp)
  80075d:	00 
  80075e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800761:	89 14 24             	mov    %edx,(%esp)
  800764:	e8 52 04 00 00       	call   800bbb <strcmp>
  800769:	83 f8 01             	cmp    $0x1,%eax
  80076c:	19 c0                	sbb    %eax,%eax
  80076e:	f7 d0                	not    %eax
  800770:	83 c0 08             	add    $0x8,%eax
  800773:	a3 04 20 80 00       	mov    %eax,0x802004
  800778:	e9 cc fd ff ff       	jmp    800549 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8d 50 04             	lea    0x4(%eax),%edx
  800783:	89 55 14             	mov    %edx,0x14(%ebp)
  800786:	8b 00                	mov    (%eax),%eax
  800788:	89 c2                	mov    %eax,%edx
  80078a:	c1 fa 1f             	sar    $0x1f,%edx
  80078d:	31 d0                	xor    %edx,%eax
  80078f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800791:	83 f8 08             	cmp    $0x8,%eax
  800794:	7f 0b                	jg     8007a1 <vprintfmt+0x27b>
  800796:	8b 14 85 20 18 80 00 	mov    0x801820(,%eax,4),%edx
  80079d:	85 d2                	test   %edx,%edx
  80079f:	75 23                	jne    8007c4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8007a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a5:	c7 44 24 08 0c 16 80 	movl   $0x80160c,0x8(%esp)
  8007ac:	00 
  8007ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b4:	89 3c 24             	mov    %edi,(%esp)
  8007b7:	e8 42 fd ff ff       	call   8004fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007bf:	e9 85 fd ff ff       	jmp    800549 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c8:	c7 44 24 08 15 16 80 	movl   $0x801615,0x8(%esp)
  8007cf:	00 
  8007d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d7:	89 3c 24             	mov    %edi,(%esp)
  8007da:	e8 1f fd ff ff       	call   8004fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007df:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007e2:	e9 62 fd ff ff       	jmp    800549 <vprintfmt+0x23>
  8007e7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8007ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007ed:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 50 04             	lea    0x4(%eax),%edx
  8007f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007fb:	85 f6                	test   %esi,%esi
  8007fd:	b8 ed 15 80 00       	mov    $0x8015ed,%eax
  800802:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800805:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800809:	7e 06                	jle    800811 <vprintfmt+0x2eb>
  80080b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80080f:	75 13                	jne    800824 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800811:	0f be 06             	movsbl (%esi),%eax
  800814:	83 c6 01             	add    $0x1,%esi
  800817:	85 c0                	test   %eax,%eax
  800819:	0f 85 94 00 00 00    	jne    8008b3 <vprintfmt+0x38d>
  80081f:	e9 81 00 00 00       	jmp    8008a5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800824:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800828:	89 34 24             	mov    %esi,(%esp)
  80082b:	e8 9b 02 00 00       	call   800acb <strnlen>
  800830:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800833:	29 c2                	sub    %eax,%edx
  800835:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800838:	85 d2                	test   %edx,%edx
  80083a:	7e d5                	jle    800811 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80083c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800840:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800843:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800846:	89 d6                	mov    %edx,%esi
  800848:	89 cf                	mov    %ecx,%edi
  80084a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084e:	89 3c 24             	mov    %edi,(%esp)
  800851:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800854:	83 ee 01             	sub    $0x1,%esi
  800857:	75 f1                	jne    80084a <vprintfmt+0x324>
  800859:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80085c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80085f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800862:	eb ad                	jmp    800811 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800864:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800868:	74 1b                	je     800885 <vprintfmt+0x35f>
  80086a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80086d:	83 fa 5e             	cmp    $0x5e,%edx
  800870:	76 13                	jbe    800885 <vprintfmt+0x35f>
					putch('?', putdat);
  800872:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800875:	89 44 24 04          	mov    %eax,0x4(%esp)
  800879:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800880:	ff 55 08             	call   *0x8(%ebp)
  800883:	eb 0d                	jmp    800892 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800885:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800888:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088c:	89 04 24             	mov    %eax,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800892:	83 eb 01             	sub    $0x1,%ebx
  800895:	0f be 06             	movsbl (%esi),%eax
  800898:	83 c6 01             	add    $0x1,%esi
  80089b:	85 c0                	test   %eax,%eax
  80089d:	75 1a                	jne    8008b9 <vprintfmt+0x393>
  80089f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8008a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008ac:	7f 1c                	jg     8008ca <vprintfmt+0x3a4>
  8008ae:	e9 96 fc ff ff       	jmp    800549 <vprintfmt+0x23>
  8008b3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008b6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008b9:	85 ff                	test   %edi,%edi
  8008bb:	78 a7                	js     800864 <vprintfmt+0x33e>
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	79 a2                	jns    800864 <vprintfmt+0x33e>
  8008c2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8008c5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008c8:	eb db                	jmp    8008a5 <vprintfmt+0x37f>
  8008ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cd:	89 de                	mov    %ebx,%esi
  8008cf:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008df:	83 eb 01             	sub    $0x1,%ebx
  8008e2:	75 ee                	jne    8008d2 <vprintfmt+0x3ac>
  8008e4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008e9:	e9 5b fc ff ff       	jmp    800549 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ee:	83 f9 01             	cmp    $0x1,%ecx
  8008f1:	7e 10                	jle    800903 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8008f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f6:	8d 50 08             	lea    0x8(%eax),%edx
  8008f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fc:	8b 30                	mov    (%eax),%esi
  8008fe:	8b 78 04             	mov    0x4(%eax),%edi
  800901:	eb 26                	jmp    800929 <vprintfmt+0x403>
	else if (lflag)
  800903:	85 c9                	test   %ecx,%ecx
  800905:	74 12                	je     800919 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 50 04             	lea    0x4(%eax),%edx
  80090d:	89 55 14             	mov    %edx,0x14(%ebp)
  800910:	8b 30                	mov    (%eax),%esi
  800912:	89 f7                	mov    %esi,%edi
  800914:	c1 ff 1f             	sar    $0x1f,%edi
  800917:	eb 10                	jmp    800929 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8d 50 04             	lea    0x4(%eax),%edx
  80091f:	89 55 14             	mov    %edx,0x14(%ebp)
  800922:	8b 30                	mov    (%eax),%esi
  800924:	89 f7                	mov    %esi,%edi
  800926:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800929:	85 ff                	test   %edi,%edi
  80092b:	78 0e                	js     80093b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80092d:	89 f0                	mov    %esi,%eax
  80092f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800931:	be 0a 00 00 00       	mov    $0xa,%esi
  800936:	e9 84 00 00 00       	jmp    8009bf <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80093b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800946:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800949:	89 f0                	mov    %esi,%eax
  80094b:	89 fa                	mov    %edi,%edx
  80094d:	f7 d8                	neg    %eax
  80094f:	83 d2 00             	adc    $0x0,%edx
  800952:	f7 da                	neg    %edx
			}
			base = 10;
  800954:	be 0a 00 00 00       	mov    $0xa,%esi
  800959:	eb 64                	jmp    8009bf <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80095b:	89 ca                	mov    %ecx,%edx
  80095d:	8d 45 14             	lea    0x14(%ebp),%eax
  800960:	e8 42 fb ff ff       	call   8004a7 <getuint>
			base = 10;
  800965:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80096a:	eb 53                	jmp    8009bf <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80096c:	89 ca                	mov    %ecx,%edx
  80096e:	8d 45 14             	lea    0x14(%ebp),%eax
  800971:	e8 31 fb ff ff       	call   8004a7 <getuint>
    			base = 8;
  800976:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80097b:	eb 42                	jmp    8009bf <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80097d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800981:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800988:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80098b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800996:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800999:	8b 45 14             	mov    0x14(%ebp),%eax
  80099c:	8d 50 04             	lea    0x4(%eax),%edx
  80099f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009a2:	8b 00                	mov    (%eax),%eax
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009a9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8009ae:	eb 0f                	jmp    8009bf <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009b0:	89 ca                	mov    %ecx,%edx
  8009b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b5:	e8 ed fa ff ff       	call   8004a7 <getuint>
			base = 16;
  8009ba:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009bf:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8009c7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009ca:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8009ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d9:	89 da                	mov    %ebx,%edx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	e8 e9 f9 ff ff       	call   8003cc <printnum>
			break;
  8009e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009e6:	e9 5e fb ff ff       	jmp    800549 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ef:	89 14 24             	mov    %edx,(%esp)
  8009f2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009f8:	e9 4c fb ff ff       	jmp    800549 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a01:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a08:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a0b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a0f:	0f 84 34 fb ff ff    	je     800549 <vprintfmt+0x23>
  800a15:	83 ee 01             	sub    $0x1,%esi
  800a18:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a1c:	75 f7                	jne    800a15 <vprintfmt+0x4ef>
  800a1e:	e9 26 fb ff ff       	jmp    800549 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a23:	83 c4 5c             	add    $0x5c,%esp
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	83 ec 28             	sub    $0x28,%esp
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a37:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a3a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a3e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	74 30                	je     800a7c <vsnprintf+0x51>
  800a4c:	85 d2                	test   %edx,%edx
  800a4e:	7e 2c                	jle    800a7c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a50:	8b 45 14             	mov    0x14(%ebp),%eax
  800a53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a57:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a65:	c7 04 24 e1 04 80 00 	movl   $0x8004e1,(%esp)
  800a6c:	e8 b5 fa ff ff       	call   800526 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a74:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a7a:	eb 05                	jmp    800a81 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a89:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a90:	8b 45 10             	mov    0x10(%ebp),%eax
  800a93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	89 04 24             	mov    %eax,(%esp)
  800aa4:	e8 82 ff ff ff       	call   800a2b <vsnprintf>
	va_end(ap);

	return rc;
}
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    
  800aab:	00 00                	add    %al,(%eax)
  800aad:	00 00                	add    %al,(%eax)
	...

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	80 3a 00             	cmpb   $0x0,(%edx)
  800abe:	74 09                	je     800ac9 <strlen+0x19>
		n++;
  800ac0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac7:	75 f7                	jne    800ac0 <strlen+0x10>
		n++;
	return n;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	85 c9                	test   %ecx,%ecx
  800adc:	74 1a                	je     800af8 <strnlen+0x2d>
  800ade:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ae1:	74 15                	je     800af8 <strnlen+0x2d>
  800ae3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ae8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aea:	39 ca                	cmp    %ecx,%edx
  800aec:	74 0a                	je     800af8 <strnlen+0x2d>
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800af6:	75 f0                	jne    800ae8 <strnlen+0x1d>
		n++;
	return n;
}
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b0e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b11:	83 c2 01             	add    $0x1,%edx
  800b14:	84 c9                	test   %cl,%cl
  800b16:	75 f2                	jne    800b0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b18:	5b                   	pop    %ebx
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 08             	sub    $0x8,%esp
  800b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b25:	89 1c 24             	mov    %ebx,(%esp)
  800b28:	e8 83 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b30:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b34:	01 d8                	add    %ebx,%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 bd ff ff ff       	call   800afb <strcpy>
	return dst;
}
  800b3e:	89 d8                	mov    %ebx,%eax
  800b40:	83 c4 08             	add    $0x8,%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b54:	85 f6                	test   %esi,%esi
  800b56:	74 18                	je     800b70 <strncpy+0x2a>
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b63:	80 3a 01             	cmpb   $0x1,(%edx)
  800b66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	39 f1                	cmp    %esi,%ecx
  800b6e:	75 ed                	jne    800b5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b80:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b83:	89 f8                	mov    %edi,%eax
  800b85:	85 f6                	test   %esi,%esi
  800b87:	74 2b                	je     800bb4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b89:	83 fe 01             	cmp    $0x1,%esi
  800b8c:	74 23                	je     800bb1 <strlcpy+0x3d>
  800b8e:	0f b6 0b             	movzbl (%ebx),%ecx
  800b91:	84 c9                	test   %cl,%cl
  800b93:	74 1c                	je     800bb1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b95:	83 ee 02             	sub    $0x2,%esi
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b9d:	88 08                	mov    %cl,(%eax)
  800b9f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba2:	39 f2                	cmp    %esi,%edx
  800ba4:	74 0b                	je     800bb1 <strlcpy+0x3d>
  800ba6:	83 c2 01             	add    $0x1,%edx
  800ba9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bad:	84 c9                	test   %cl,%cl
  800baf:	75 ec                	jne    800b9d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800bb1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bb4:	29 f8                	sub    %edi,%eax
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bc4:	0f b6 01             	movzbl (%ecx),%eax
  800bc7:	84 c0                	test   %al,%al
  800bc9:	74 16                	je     800be1 <strcmp+0x26>
  800bcb:	3a 02                	cmp    (%edx),%al
  800bcd:	75 12                	jne    800be1 <strcmp+0x26>
		p++, q++;
  800bcf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bd2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800bd6:	84 c0                	test   %al,%al
  800bd8:	74 07                	je     800be1 <strcmp+0x26>
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	3a 02                	cmp    (%edx),%al
  800bdf:	74 ee                	je     800bcf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be1:	0f b6 c0             	movzbl %al,%eax
  800be4:	0f b6 12             	movzbl (%edx),%edx
  800be7:	29 d0                	sub    %edx,%eax
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bfd:	85 d2                	test   %edx,%edx
  800bff:	74 28                	je     800c29 <strncmp+0x3e>
  800c01:	0f b6 01             	movzbl (%ecx),%eax
  800c04:	84 c0                	test   %al,%al
  800c06:	74 24                	je     800c2c <strncmp+0x41>
  800c08:	3a 03                	cmp    (%ebx),%al
  800c0a:	75 20                	jne    800c2c <strncmp+0x41>
  800c0c:	83 ea 01             	sub    $0x1,%edx
  800c0f:	74 13                	je     800c24 <strncmp+0x39>
		n--, p++, q++;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c17:	0f b6 01             	movzbl (%ecx),%eax
  800c1a:	84 c0                	test   %al,%al
  800c1c:	74 0e                	je     800c2c <strncmp+0x41>
  800c1e:	3a 03                	cmp    (%ebx),%al
  800c20:	74 ea                	je     800c0c <strncmp+0x21>
  800c22:	eb 08                	jmp    800c2c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c2c:	0f b6 01             	movzbl (%ecx),%eax
  800c2f:	0f b6 13             	movzbl (%ebx),%edx
  800c32:	29 d0                	sub    %edx,%eax
  800c34:	eb f3                	jmp    800c29 <strncmp+0x3e>

00800c36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c40:	0f b6 10             	movzbl (%eax),%edx
  800c43:	84 d2                	test   %dl,%dl
  800c45:	74 1c                	je     800c63 <strchr+0x2d>
		if (*s == c)
  800c47:	38 ca                	cmp    %cl,%dl
  800c49:	75 09                	jne    800c54 <strchr+0x1e>
  800c4b:	eb 1b                	jmp    800c68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c4d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800c50:	38 ca                	cmp    %cl,%dl
  800c52:	74 14                	je     800c68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c54:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800c58:	84 d2                	test   %dl,%dl
  800c5a:	75 f1                	jne    800c4d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c61:	eb 05                	jmp    800c68 <strchr+0x32>
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c74:	0f b6 10             	movzbl (%eax),%edx
  800c77:	84 d2                	test   %dl,%dl
  800c79:	74 14                	je     800c8f <strfind+0x25>
		if (*s == c)
  800c7b:	38 ca                	cmp    %cl,%dl
  800c7d:	75 06                	jne    800c85 <strfind+0x1b>
  800c7f:	eb 0e                	jmp    800c8f <strfind+0x25>
  800c81:	38 ca                	cmp    %cl,%dl
  800c83:	74 0a                	je     800c8f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c85:	83 c0 01             	add    $0x1,%eax
  800c88:	0f b6 10             	movzbl (%eax),%edx
  800c8b:	84 d2                	test   %dl,%dl
  800c8d:	75 f2                	jne    800c81 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ca9:	85 c9                	test   %ecx,%ecx
  800cab:	74 30                	je     800cdd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb3:	75 25                	jne    800cda <memset+0x49>
  800cb5:	f6 c1 03             	test   $0x3,%cl
  800cb8:	75 20                	jne    800cda <memset+0x49>
		c &= 0xFF;
  800cba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cbd:	89 d3                	mov    %edx,%ebx
  800cbf:	c1 e3 08             	shl    $0x8,%ebx
  800cc2:	89 d6                	mov    %edx,%esi
  800cc4:	c1 e6 18             	shl    $0x18,%esi
  800cc7:	89 d0                	mov    %edx,%eax
  800cc9:	c1 e0 10             	shl    $0x10,%eax
  800ccc:	09 f0                	or     %esi,%eax
  800cce:	09 d0                	or     %edx,%eax
  800cd0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cd2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cd5:	fc                   	cld    
  800cd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800cd8:	eb 03                	jmp    800cdd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cda:	fc                   	cld    
  800cdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cdd:	89 f8                	mov    %edi,%eax
  800cdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce8:	89 ec                	mov    %ebp,%esp
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 08             	sub    $0x8,%esp
  800cf2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d01:	39 c6                	cmp    %eax,%esi
  800d03:	73 36                	jae    800d3b <memmove+0x4f>
  800d05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d08:	39 d0                	cmp    %edx,%eax
  800d0a:	73 2f                	jae    800d3b <memmove+0x4f>
		s += n;
		d += n;
  800d0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0f:	f6 c2 03             	test   $0x3,%dl
  800d12:	75 1b                	jne    800d2f <memmove+0x43>
  800d14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1a:	75 13                	jne    800d2f <memmove+0x43>
  800d1c:	f6 c1 03             	test   $0x3,%cl
  800d1f:	75 0e                	jne    800d2f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d21:	83 ef 04             	sub    $0x4,%edi
  800d24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d2a:	fd                   	std    
  800d2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2d:	eb 09                	jmp    800d38 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d2f:	83 ef 01             	sub    $0x1,%edi
  800d32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d35:	fd                   	std    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d38:	fc                   	cld    
  800d39:	eb 20                	jmp    800d5b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d3b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d41:	75 13                	jne    800d56 <memmove+0x6a>
  800d43:	a8 03                	test   $0x3,%al
  800d45:	75 0f                	jne    800d56 <memmove+0x6a>
  800d47:	f6 c1 03             	test   $0x3,%cl
  800d4a:	75 0a                	jne    800d56 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d4c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d4f:	89 c7                	mov    %eax,%edi
  800d51:	fc                   	cld    
  800d52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d54:	eb 05                	jmp    800d5b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d56:	89 c7                	mov    %eax,%edi
  800d58:	fc                   	cld    
  800d59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d61:	89 ec                	mov    %ebp,%esp
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	89 04 24             	mov    %eax,(%esp)
  800d7f:	e8 68 ff ff ff       	call   800cec <memmove>
}
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    

00800d86 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d92:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d95:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d9a:	85 ff                	test   %edi,%edi
  800d9c:	74 37                	je     800dd5 <memcmp+0x4f>
		if (*s1 != *s2)
  800d9e:	0f b6 03             	movzbl (%ebx),%eax
  800da1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da4:	83 ef 01             	sub    $0x1,%edi
  800da7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800dac:	38 c8                	cmp    %cl,%al
  800dae:	74 1c                	je     800dcc <memcmp+0x46>
  800db0:	eb 10                	jmp    800dc2 <memcmp+0x3c>
  800db2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800db7:	83 c2 01             	add    $0x1,%edx
  800dba:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800dbe:	38 c8                	cmp    %cl,%al
  800dc0:	74 0a                	je     800dcc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800dc2:	0f b6 c0             	movzbl %al,%eax
  800dc5:	0f b6 c9             	movzbl %cl,%ecx
  800dc8:	29 c8                	sub    %ecx,%eax
  800dca:	eb 09                	jmp    800dd5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dcc:	39 fa                	cmp    %edi,%edx
  800dce:	75 e2                	jne    800db2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800de0:	89 c2                	mov    %eax,%edx
  800de2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800de5:	39 d0                	cmp    %edx,%eax
  800de7:	73 19                	jae    800e02 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ded:	38 08                	cmp    %cl,(%eax)
  800def:	75 06                	jne    800df7 <memfind+0x1d>
  800df1:	eb 0f                	jmp    800e02 <memfind+0x28>
  800df3:	38 08                	cmp    %cl,(%eax)
  800df5:	74 0b                	je     800e02 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df7:	83 c0 01             	add    $0x1,%eax
  800dfa:	39 d0                	cmp    %edx,%eax
  800dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e00:	75 f1                	jne    800df3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e10:	0f b6 02             	movzbl (%edx),%eax
  800e13:	3c 20                	cmp    $0x20,%al
  800e15:	74 04                	je     800e1b <strtol+0x17>
  800e17:	3c 09                	cmp    $0x9,%al
  800e19:	75 0e                	jne    800e29 <strtol+0x25>
		s++;
  800e1b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1e:	0f b6 02             	movzbl (%edx),%eax
  800e21:	3c 20                	cmp    $0x20,%al
  800e23:	74 f6                	je     800e1b <strtol+0x17>
  800e25:	3c 09                	cmp    $0x9,%al
  800e27:	74 f2                	je     800e1b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e29:	3c 2b                	cmp    $0x2b,%al
  800e2b:	75 0a                	jne    800e37 <strtol+0x33>
		s++;
  800e2d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e30:	bf 00 00 00 00       	mov    $0x0,%edi
  800e35:	eb 10                	jmp    800e47 <strtol+0x43>
  800e37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e3c:	3c 2d                	cmp    $0x2d,%al
  800e3e:	75 07                	jne    800e47 <strtol+0x43>
		s++, neg = 1;
  800e40:	83 c2 01             	add    $0x1,%edx
  800e43:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e47:	85 db                	test   %ebx,%ebx
  800e49:	0f 94 c0             	sete   %al
  800e4c:	74 05                	je     800e53 <strtol+0x4f>
  800e4e:	83 fb 10             	cmp    $0x10,%ebx
  800e51:	75 15                	jne    800e68 <strtol+0x64>
  800e53:	80 3a 30             	cmpb   $0x30,(%edx)
  800e56:	75 10                	jne    800e68 <strtol+0x64>
  800e58:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e5c:	75 0a                	jne    800e68 <strtol+0x64>
		s += 2, base = 16;
  800e5e:	83 c2 02             	add    $0x2,%edx
  800e61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e66:	eb 13                	jmp    800e7b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e68:	84 c0                	test   %al,%al
  800e6a:	74 0f                	je     800e7b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e71:	80 3a 30             	cmpb   $0x30,(%edx)
  800e74:	75 05                	jne    800e7b <strtol+0x77>
		s++, base = 8;
  800e76:	83 c2 01             	add    $0x1,%edx
  800e79:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e82:	0f b6 0a             	movzbl (%edx),%ecx
  800e85:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e88:	80 fb 09             	cmp    $0x9,%bl
  800e8b:	77 08                	ja     800e95 <strtol+0x91>
			dig = *s - '0';
  800e8d:	0f be c9             	movsbl %cl,%ecx
  800e90:	83 e9 30             	sub    $0x30,%ecx
  800e93:	eb 1e                	jmp    800eb3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800e95:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e98:	80 fb 19             	cmp    $0x19,%bl
  800e9b:	77 08                	ja     800ea5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800e9d:	0f be c9             	movsbl %cl,%ecx
  800ea0:	83 e9 57             	sub    $0x57,%ecx
  800ea3:	eb 0e                	jmp    800eb3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800ea5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ea8:	80 fb 19             	cmp    $0x19,%bl
  800eab:	77 14                	ja     800ec1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ead:	0f be c9             	movsbl %cl,%ecx
  800eb0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800eb3:	39 f1                	cmp    %esi,%ecx
  800eb5:	7d 0e                	jge    800ec5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800eb7:	83 c2 01             	add    $0x1,%edx
  800eba:	0f af c6             	imul   %esi,%eax
  800ebd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ebf:	eb c1                	jmp    800e82 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ec1:	89 c1                	mov    %eax,%ecx
  800ec3:	eb 02                	jmp    800ec7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ec5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ec7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ecb:	74 05                	je     800ed2 <strtol+0xce>
		*endptr = (char *) s;
  800ecd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ed0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ed2:	89 ca                	mov    %ecx,%edx
  800ed4:	f7 da                	neg    %edx
  800ed6:	85 ff                	test   %edi,%edi
  800ed8:	0f 45 c2             	cmovne %edx,%eax
}
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 0c             	sub    $0xc,%esp
  800ee6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	89 c3                	mov    %eax,%ebx
  800efc:	89 c7                	mov    %eax,%edi
  800efe:	89 c6                	mov    %eax,%esi
  800f00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0b:	89 ec                	mov    %ebp,%esp
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f23:	b8 01 00 00 00       	mov    $0x1,%eax
  800f28:	89 d1                	mov    %edx,%ecx
  800f2a:	89 d3                	mov    %edx,%ebx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	89 d6                	mov    %edx,%esi
  800f30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f3b:	89 ec                	mov    %ebp,%esp
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 38             	sub    $0x38,%esp
  800f45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	b8 03 00 00 00       	mov    $0x3,%eax
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	89 cb                	mov    %ecx,%ebx
  800f5d:	89 cf                	mov    %ecx,%edi
  800f5f:	89 ce                	mov    %ecx,%esi
  800f61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f63:	85 c0                	test   %eax,%eax
  800f65:	7e 28                	jle    800f8f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f72:	00 
  800f73:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f82:	00 
  800f83:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  800f8a:	e8 25 f3 ff ff       	call   8002b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f98:	89 ec                	mov    %ebp,%esp
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 d3                	mov    %edx,%ebx
  800fb9:	89 d7                	mov    %edx,%edi
  800fbb:	89 d6                	mov    %edx,%esi
  800fbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc8:	89 ec                	mov    %ebp,%esp
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <sys_yield>:

void
sys_yield(void)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	89 d3                	mov    %edx,%ebx
  800fe9:	89 d7                	mov    %edx,%edi
  800feb:	89 d6                	mov    %edx,%esi
  800fed:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 38             	sub    $0x38,%esp
  801002:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801005:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801008:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100b:	be 00 00 00 00       	mov    $0x0,%esi
  801010:	b8 04 00 00 00       	mov    $0x4,%eax
  801015:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	89 f7                	mov    %esi,%edi
  801020:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801022:	85 c0                	test   %eax,%eax
  801024:	7e 28                	jle    80104e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801026:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  801049:	e8 66 f2 ff ff       	call   8002b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80104e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801051:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801054:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801057:	89 ec                	mov    %ebp,%esp
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 38             	sub    $0x38,%esp
  801061:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801064:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801067:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106a:	b8 05 00 00 00       	mov    $0x5,%eax
  80106f:	8b 75 18             	mov    0x18(%ebp),%esi
  801072:	8b 7d 14             	mov    0x14(%ebp),%edi
  801075:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801078:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107b:	8b 55 08             	mov    0x8(%ebp),%edx
  80107e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801080:	85 c0                	test   %eax,%eax
  801082:	7e 28                	jle    8010ac <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801084:	89 44 24 10          	mov    %eax,0x10(%esp)
  801088:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80108f:	00 
  801090:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  801097:	00 
  801098:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109f:	00 
  8010a0:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  8010a7:	e8 08 f2 ff ff       	call   8002b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010ac:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010af:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b5:	89 ec                	mov    %ebp,%esp
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 38             	sub    $0x38,%esp
  8010bf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010c2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8010d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d8:	89 df                	mov    %ebx,%edi
  8010da:	89 de                	mov    %ebx,%esi
  8010dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	7e 28                	jle    80110a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  8010f5:	00 
  8010f6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010fd:	00 
  8010fe:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  801105:	e8 aa f1 ff ff       	call   8002b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80110a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80110d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801110:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801113:	89 ec                	mov    %ebp,%esp
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	83 ec 38             	sub    $0x38,%esp
  80111d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801120:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801123:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801126:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112b:	b8 08 00 00 00       	mov    $0x8,%eax
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801133:	8b 55 08             	mov    0x8(%ebp),%edx
  801136:	89 df                	mov    %ebx,%edi
  801138:	89 de                	mov    %ebx,%esi
  80113a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113c:	85 c0                	test   %eax,%eax
  80113e:	7e 28                	jle    801168 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801140:	89 44 24 10          	mov    %eax,0x10(%esp)
  801144:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80114b:	00 
  80114c:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  801153:	00 
  801154:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80115b:	00 
  80115c:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  801163:	e8 4c f1 ff ff       	call   8002b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801168:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80116b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801171:	89 ec                	mov    %ebp,%esp
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  801184:	bb 00 00 00 00       	mov    $0x0,%ebx
  801189:	b8 09 00 00 00       	mov    $0x9,%eax
  80118e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801191:	8b 55 08             	mov    0x8(%ebp),%edx
  801194:	89 df                	mov    %ebx,%edi
  801196:	89 de                	mov    %ebx,%esi
  801198:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80119a:	85 c0                	test   %eax,%eax
  80119c:	7e 28                	jle    8011c6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  8011b1:	00 
  8011b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b9:	00 
  8011ba:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  8011c1:	e8 ee f0 ff ff       	call   8002b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011cf:	89 ec                	mov    %ebp,%esp
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	83 ec 0c             	sub    $0xc,%esp
  8011d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011df:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e2:	be 00 00 00 00       	mov    $0x0,%esi
  8011e7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801200:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801203:	89 ec                	mov    %ebp,%esp
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 38             	sub    $0x38,%esp
  80120d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801210:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801213:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801220:	8b 55 08             	mov    0x8(%ebp),%edx
  801223:	89 cb                	mov    %ecx,%ebx
  801225:	89 cf                	mov    %ecx,%edi
  801227:	89 ce                	mov    %ecx,%esi
  801229:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80122b:	85 c0                	test   %eax,%eax
  80122d:	7e 28                	jle    801257 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801233:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80123a:	00 
  80123b:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  801242:	00 
  801243:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80124a:	00 
  80124b:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  801252:	e8 5d f0 ff ff       	call   8002b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801257:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80125a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80125d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801260:	89 ec                	mov    %ebp,%esp
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    
	...

00801270 <__udivdi3>:
  801270:	83 ec 1c             	sub    $0x1c,%esp
  801273:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801277:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80127b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80127f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801283:	89 74 24 10          	mov    %esi,0x10(%esp)
  801287:	8b 74 24 24          	mov    0x24(%esp),%esi
  80128b:	85 ff                	test   %edi,%edi
  80128d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801291:	89 44 24 08          	mov    %eax,0x8(%esp)
  801295:	89 cd                	mov    %ecx,%ebp
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	75 33                	jne    8012d0 <__udivdi3+0x60>
  80129d:	39 f1                	cmp    %esi,%ecx
  80129f:	77 57                	ja     8012f8 <__udivdi3+0x88>
  8012a1:	85 c9                	test   %ecx,%ecx
  8012a3:	75 0b                	jne    8012b0 <__udivdi3+0x40>
  8012a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8012aa:	31 d2                	xor    %edx,%edx
  8012ac:	f7 f1                	div    %ecx
  8012ae:	89 c1                	mov    %eax,%ecx
  8012b0:	89 f0                	mov    %esi,%eax
  8012b2:	31 d2                	xor    %edx,%edx
  8012b4:	f7 f1                	div    %ecx
  8012b6:	89 c6                	mov    %eax,%esi
  8012b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012bc:	f7 f1                	div    %ecx
  8012be:	89 f2                	mov    %esi,%edx
  8012c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012cc:	83 c4 1c             	add    $0x1c,%esp
  8012cf:	c3                   	ret    
  8012d0:	31 d2                	xor    %edx,%edx
  8012d2:	31 c0                	xor    %eax,%eax
  8012d4:	39 f7                	cmp    %esi,%edi
  8012d6:	77 e8                	ja     8012c0 <__udivdi3+0x50>
  8012d8:	0f bd cf             	bsr    %edi,%ecx
  8012db:	83 f1 1f             	xor    $0x1f,%ecx
  8012de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e2:	75 2c                	jne    801310 <__udivdi3+0xa0>
  8012e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8012e8:	76 04                	jbe    8012ee <__udivdi3+0x7e>
  8012ea:	39 f7                	cmp    %esi,%edi
  8012ec:	73 d2                	jae    8012c0 <__udivdi3+0x50>
  8012ee:	31 d2                	xor    %edx,%edx
  8012f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f5:	eb c9                	jmp    8012c0 <__udivdi3+0x50>
  8012f7:	90                   	nop
  8012f8:	89 f2                	mov    %esi,%edx
  8012fa:	f7 f1                	div    %ecx
  8012fc:	31 d2                	xor    %edx,%edx
  8012fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  801302:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801306:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80130a:	83 c4 1c             	add    $0x1c,%esp
  80130d:	c3                   	ret    
  80130e:	66 90                	xchg   %ax,%ax
  801310:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801315:	b8 20 00 00 00       	mov    $0x20,%eax
  80131a:	89 ea                	mov    %ebp,%edx
  80131c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801320:	d3 e7                	shl    %cl,%edi
  801322:	89 c1                	mov    %eax,%ecx
  801324:	d3 ea                	shr    %cl,%edx
  801326:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80132b:	09 fa                	or     %edi,%edx
  80132d:	89 f7                	mov    %esi,%edi
  80132f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801333:	89 f2                	mov    %esi,%edx
  801335:	8b 74 24 08          	mov    0x8(%esp),%esi
  801339:	d3 e5                	shl    %cl,%ebp
  80133b:	89 c1                	mov    %eax,%ecx
  80133d:	d3 ef                	shr    %cl,%edi
  80133f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801344:	d3 e2                	shl    %cl,%edx
  801346:	89 c1                	mov    %eax,%ecx
  801348:	d3 ee                	shr    %cl,%esi
  80134a:	09 d6                	or     %edx,%esi
  80134c:	89 fa                	mov    %edi,%edx
  80134e:	89 f0                	mov    %esi,%eax
  801350:	f7 74 24 0c          	divl   0xc(%esp)
  801354:	89 d7                	mov    %edx,%edi
  801356:	89 c6                	mov    %eax,%esi
  801358:	f7 e5                	mul    %ebp
  80135a:	39 d7                	cmp    %edx,%edi
  80135c:	72 22                	jb     801380 <__udivdi3+0x110>
  80135e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801362:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801367:	d3 e5                	shl    %cl,%ebp
  801369:	39 c5                	cmp    %eax,%ebp
  80136b:	73 04                	jae    801371 <__udivdi3+0x101>
  80136d:	39 d7                	cmp    %edx,%edi
  80136f:	74 0f                	je     801380 <__udivdi3+0x110>
  801371:	89 f0                	mov    %esi,%eax
  801373:	31 d2                	xor    %edx,%edx
  801375:	e9 46 ff ff ff       	jmp    8012c0 <__udivdi3+0x50>
  80137a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801380:	8d 46 ff             	lea    -0x1(%esi),%eax
  801383:	31 d2                	xor    %edx,%edx
  801385:	8b 74 24 10          	mov    0x10(%esp),%esi
  801389:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80138d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801391:	83 c4 1c             	add    $0x1c,%esp
  801394:	c3                   	ret    
	...

008013a0 <__umoddi3>:
  8013a0:	83 ec 1c             	sub    $0x1c,%esp
  8013a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8013a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8013ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8013af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8013bb:	85 ed                	test   %ebp,%ebp
  8013bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8013c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c5:	89 cf                	mov    %ecx,%edi
  8013c7:	89 04 24             	mov    %eax,(%esp)
  8013ca:	89 f2                	mov    %esi,%edx
  8013cc:	75 1a                	jne    8013e8 <__umoddi3+0x48>
  8013ce:	39 f1                	cmp    %esi,%ecx
  8013d0:	76 4e                	jbe    801420 <__umoddi3+0x80>
  8013d2:	f7 f1                	div    %ecx
  8013d4:	89 d0                	mov    %edx,%eax
  8013d6:	31 d2                	xor    %edx,%edx
  8013d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013e4:	83 c4 1c             	add    $0x1c,%esp
  8013e7:	c3                   	ret    
  8013e8:	39 f5                	cmp    %esi,%ebp
  8013ea:	77 54                	ja     801440 <__umoddi3+0xa0>
  8013ec:	0f bd c5             	bsr    %ebp,%eax
  8013ef:	83 f0 1f             	xor    $0x1f,%eax
  8013f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f6:	75 60                	jne    801458 <__umoddi3+0xb8>
  8013f8:	3b 0c 24             	cmp    (%esp),%ecx
  8013fb:	0f 87 07 01 00 00    	ja     801508 <__umoddi3+0x168>
  801401:	89 f2                	mov    %esi,%edx
  801403:	8b 34 24             	mov    (%esp),%esi
  801406:	29 ce                	sub    %ecx,%esi
  801408:	19 ea                	sbb    %ebp,%edx
  80140a:	89 34 24             	mov    %esi,(%esp)
  80140d:	8b 04 24             	mov    (%esp),%eax
  801410:	8b 74 24 10          	mov    0x10(%esp),%esi
  801414:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801418:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80141c:	83 c4 1c             	add    $0x1c,%esp
  80141f:	c3                   	ret    
  801420:	85 c9                	test   %ecx,%ecx
  801422:	75 0b                	jne    80142f <__umoddi3+0x8f>
  801424:	b8 01 00 00 00       	mov    $0x1,%eax
  801429:	31 d2                	xor    %edx,%edx
  80142b:	f7 f1                	div    %ecx
  80142d:	89 c1                	mov    %eax,%ecx
  80142f:	89 f0                	mov    %esi,%eax
  801431:	31 d2                	xor    %edx,%edx
  801433:	f7 f1                	div    %ecx
  801435:	8b 04 24             	mov    (%esp),%eax
  801438:	f7 f1                	div    %ecx
  80143a:	eb 98                	jmp    8013d4 <__umoddi3+0x34>
  80143c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801440:	89 f2                	mov    %esi,%edx
  801442:	8b 74 24 10          	mov    0x10(%esp),%esi
  801446:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80144a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80144e:	83 c4 1c             	add    $0x1c,%esp
  801451:	c3                   	ret    
  801452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801458:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80145d:	89 e8                	mov    %ebp,%eax
  80145f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801464:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801468:	89 fa                	mov    %edi,%edx
  80146a:	d3 e0                	shl    %cl,%eax
  80146c:	89 e9                	mov    %ebp,%ecx
  80146e:	d3 ea                	shr    %cl,%edx
  801470:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801475:	09 c2                	or     %eax,%edx
  801477:	8b 44 24 08          	mov    0x8(%esp),%eax
  80147b:	89 14 24             	mov    %edx,(%esp)
  80147e:	89 f2                	mov    %esi,%edx
  801480:	d3 e7                	shl    %cl,%edi
  801482:	89 e9                	mov    %ebp,%ecx
  801484:	d3 ea                	shr    %cl,%edx
  801486:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80148b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80148f:	d3 e6                	shl    %cl,%esi
  801491:	89 e9                	mov    %ebp,%ecx
  801493:	d3 e8                	shr    %cl,%eax
  801495:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80149a:	09 f0                	or     %esi,%eax
  80149c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8014a0:	f7 34 24             	divl   (%esp)
  8014a3:	d3 e6                	shl    %cl,%esi
  8014a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014a9:	89 d6                	mov    %edx,%esi
  8014ab:	f7 e7                	mul    %edi
  8014ad:	39 d6                	cmp    %edx,%esi
  8014af:	89 c1                	mov    %eax,%ecx
  8014b1:	89 d7                	mov    %edx,%edi
  8014b3:	72 3f                	jb     8014f4 <__umoddi3+0x154>
  8014b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014b9:	72 35                	jb     8014f0 <__umoddi3+0x150>
  8014bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014bf:	29 c8                	sub    %ecx,%eax
  8014c1:	19 fe                	sbb    %edi,%esi
  8014c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014c8:	89 f2                	mov    %esi,%edx
  8014ca:	d3 e8                	shr    %cl,%eax
  8014cc:	89 e9                	mov    %ebp,%ecx
  8014ce:	d3 e2                	shl    %cl,%edx
  8014d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014d5:	09 d0                	or     %edx,%eax
  8014d7:	89 f2                	mov    %esi,%edx
  8014d9:	d3 ea                	shr    %cl,%edx
  8014db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014e7:	83 c4 1c             	add    $0x1c,%esp
  8014ea:	c3                   	ret    
  8014eb:	90                   	nop
  8014ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014f0:	39 d6                	cmp    %edx,%esi
  8014f2:	75 c7                	jne    8014bb <__umoddi3+0x11b>
  8014f4:	89 d7                	mov    %edx,%edi
  8014f6:	89 c1                	mov    %eax,%ecx
  8014f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8014fc:	1b 3c 24             	sbb    (%esp),%edi
  8014ff:	eb ba                	jmp    8014bb <__umoddi3+0x11b>
  801501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801508:	39 f5                	cmp    %esi,%ebp
  80150a:	0f 82 f1 fe ff ff    	jb     801401 <__umoddi3+0x61>
  801510:	e9 f8 fe ff ff       	jmp    80140d <__umoddi3+0x6d>
