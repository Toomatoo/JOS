
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 2f 02 00 00       	call   800260 <libmain>
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
  800051:	e8 c6 0f 00 00       	call   80101c <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 33 25 80 00 	movl   $0x802533,(%esp)
  800075:	e8 52 02 00 00       	call   8002cc <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 dd 0f 00 00       	call   80107b <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 43 25 80 	movl   $0x802543,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 33 25 80 00 	movl   $0x802533,(%esp)
  8000bd:	e8 0a 02 00 00       	call   8002cc <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 32 0c 00 00       	call   800d0c <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 eb 0f 00 00       	call   8010d9 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 54 25 80 	movl   $0x802554,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 33 25 80 00 	movl   $0x802533,(%esp)
  80010d:	e8 ba 01 00 00       	call   8002cc <_panic>
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
	cprintf("**envid modified: %x\n", envid);
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	c7 04 24 67 25 80 00 	movl   $0x802567,(%esp)
  800139:	e8 89 02 00 00       	call   8003c7 <cprintf>
	if (envid < 0) {
  80013e:	85 f6                	test   %esi,%esi
  800140:	79 20                	jns    800162 <dumbfork+0x49>
		panic("sys_exofork: %e", envid);
  800142:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800146:	c7 44 24 08 7d 25 80 	movl   $0x80257d,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 33 25 80 00 	movl   $0x802533,(%esp)
  80015d:	e8 6a 01 00 00       	call   8002cc <_panic>
	}
	if (envid == 0) {
  800162:	85 f6                	test   %esi,%esi
  800164:	75 19                	jne    80017f <dumbfork+0x66>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800166:	e8 51 0e 00 00       	call   800fbc <sys_getenvid>
  80016b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800170:	c1 e0 07             	shl    $0x7,%eax
  800173:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800178:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80017d:	eb 7e                	jmp    8001fd <dumbfork+0xe4>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800186:	b8 00 60 80 00       	mov    $0x806000,%eax
  80018b:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800190:	76 23                	jbe    8001b5 <dumbfork+0x9c>
  800192:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019b:	89 1c 24             	mov    %ebx,(%esp)
  80019e:	e8 91 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001a6:	05 00 10 00 00       	add    $0x1000,%eax
  8001ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001ae:	3d 00 60 80 00       	cmp    $0x806000,%eax
  8001b3:	72 e2                	jb     800197 <dumbfork+0x7e>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 6b fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8001c9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001d0:	00 
  8001d1:	89 34 24             	mov    %esi,(%esp)
  8001d4:	e8 5e 0f 00 00       	call   801137 <sys_env_set_status>
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	79 20                	jns    8001fd <dumbfork+0xe4>
		panic("sys_env_set_status: %e", r);
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	c7 44 24 08 8d 25 80 	movl   $0x80258d,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 33 25 80 00 	movl   $0x802533,(%esp)
  8001f8:	e8 cf 00 00 00       	call   8002cc <_panic>
	}

	return envid;
}
  8001fd:	89 f0                	mov    %esi,%eax
  8001ff:	83 c4 20             	add    $0x20,%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80020f:	e8 05 ff ff ff       	call   800119 <dumbfork>
  800214:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800216:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80021b:	bf ab 25 80 00       	mov    $0x8025ab,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800220:	eb 26                	jmp    800248 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800222:	85 db                	test   %ebx,%ebx
  800224:	b8 a4 25 80 00       	mov    $0x8025a4,%eax
  800229:	0f 44 c7             	cmove  %edi,%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	89 74 24 04          	mov    %esi,0x4(%esp)
  800234:	c7 04 24 b1 25 80 00 	movl   $0x8025b1,(%esp)
  80023b:	e8 87 01 00 00       	call   8003c7 <cprintf>
		sys_yield();
  800240:	e8 a7 0d 00 00       	call   800fec <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800245:	83 c6 01             	add    $0x1,%esi
  800248:	83 fb 01             	cmp    $0x1,%ebx
  80024b:	19 c0                	sbb    %eax,%eax
  80024d:	83 e0 0a             	and    $0xa,%eax
  800250:	83 c0 0a             	add    $0xa,%eax
  800253:	39 c6                	cmp    %eax,%esi
  800255:	7c cb                	jl     800222 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800257:	83 c4 1c             	add    $0x1c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    
	...

00800260 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
  800266:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800269:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80026c:	8b 75 08             	mov    0x8(%ebp),%esi
  80026f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800272:	e8 45 0d 00 00       	call   800fbc <sys_getenvid>
  800277:	25 ff 03 00 00       	and    $0x3ff,%eax
  80027c:	c1 e0 07             	shl    $0x7,%eax
  80027f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800284:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800289:	85 f6                	test   %esi,%esi
  80028b:	7e 07                	jle    800294 <libmain+0x34>
		binaryname = argv[0];
  80028d:	8b 03                	mov    (%ebx),%eax
  80028f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800294:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800298:	89 34 24             	mov    %esi,(%esp)
  80029b:	e8 66 ff ff ff       	call   800206 <umain>

	// exit gracefully
	exit();
  8002a0:	e8 0b 00 00 00       	call   8002b0 <exit>
}
  8002a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002ab:	89 ec                	mov    %ebp,%esp
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    
	...

008002b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002b6:	e8 83 12 00 00       	call   80153e <close_all>
	sys_env_destroy(0);
  8002bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002c2:	e8 98 0c 00 00       	call   800f5f <sys_env_destroy>
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
	...

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002dd:	e8 da 0c 00 00       	call   800fbc <sys_getenvid>
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 d0 25 80 00 	movl   $0x8025d0,(%esp)
  8002ff:	e8 c3 00 00 00       	call   8003c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800304:	89 74 24 04          	mov    %esi,0x4(%esp)
  800308:	8b 45 10             	mov    0x10(%ebp),%eax
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 53 00 00 00       	call   800366 <vcprintf>
	cprintf("\n");
  800313:	c7 04 24 c1 25 80 00 	movl   $0x8025c1,(%esp)
  80031a:	e8 a8 00 00 00       	call   8003c7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80031f:	cc                   	int3   
  800320:	eb fd                	jmp    80031f <_panic+0x53>
	...

00800324 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	53                   	push   %ebx
  800328:	83 ec 14             	sub    $0x14,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80032e:	8b 03                	mov    (%ebx),%eax
  800330:	8b 55 08             	mov    0x8(%ebp),%edx
  800333:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800337:	83 c0 01             	add    $0x1,%eax
  80033a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80033c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800341:	75 19                	jne    80035c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800343:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80034a:	00 
  80034b:	8d 43 08             	lea    0x8(%ebx),%eax
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	e8 aa 0b 00 00       	call   800f00 <sys_cputs>
		b->idx = 0;
  800356:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80035c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800360:	83 c4 14             	add    $0x14,%esp
  800363:	5b                   	pop    %ebx
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80036f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800376:	00 00 00 
	b.cnt = 0;
  800379:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800380:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
  800386:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800391:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039b:	c7 04 24 24 03 80 00 	movl   $0x800324,(%esp)
  8003a2:	e8 97 01 00 00       	call   80053e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	e8 41 0b 00 00       	call   800f00 <sys_cputs>

	return b.cnt;
}
  8003bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 87 ff ff ff       	call   800366 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    
  8003e1:	00 00                	add    %al,(%eax)
	...

008003e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	57                   	push   %edi
  8003e8:	56                   	push   %esi
  8003e9:	53                   	push   %ebx
  8003ea:	83 ec 3c             	sub    $0x3c,%esp
  8003ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f0:	89 d7                	mov    %edx,%edi
  8003f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800401:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80040c:	72 11                	jb     80041f <printnum+0x3b>
  80040e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800411:	39 45 10             	cmp    %eax,0x10(%ebp)
  800414:	76 09                	jbe    80041f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800416:	83 eb 01             	sub    $0x1,%ebx
  800419:	85 db                	test   %ebx,%ebx
  80041b:	7f 51                	jg     80046e <printnum+0x8a>
  80041d:	eb 5e                	jmp    80047d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800423:	83 eb 01             	sub    $0x1,%ebx
  800426:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80042a:	8b 45 10             	mov    0x10(%ebp),%eax
  80042d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800431:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800435:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800439:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800440:	00 
  800441:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80044a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044e:	e8 1d 1e 00 00       	call   802270 <__udivdi3>
  800453:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800457:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800462:	89 fa                	mov    %edi,%edx
  800464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800467:	e8 78 ff ff ff       	call   8003e4 <printnum>
  80046c:	eb 0f                	jmp    80047d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800472:	89 34 24             	mov    %esi,(%esp)
  800475:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800478:	83 eb 01             	sub    $0x1,%ebx
  80047b:	75 f1                	jne    80046e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800481:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800485:	8b 45 10             	mov    0x10(%ebp),%eax
  800488:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800493:	00 
  800494:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800497:	89 04 24             	mov    %eax,(%esp)
  80049a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a1:	e8 fa 1e 00 00       	call   8023a0 <__umoddi3>
  8004a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004aa:	0f be 80 f3 25 80 00 	movsbl 0x8025f3(%eax),%eax
  8004b1:	89 04 24             	mov    %eax,(%esp)
  8004b4:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004b7:	83 c4 3c             	add    $0x3c,%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c2:	83 fa 01             	cmp    $0x1,%edx
  8004c5:	7e 0e                	jle    8004d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	8b 52 04             	mov    0x4(%edx),%edx
  8004d3:	eb 22                	jmp    8004f7 <getuint+0x38>
	else if (lflag)
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 10                	je     8004e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 02                	mov    (%edx),%eax
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	eb 0e                	jmp    8004f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e9:	8b 10                	mov    (%eax),%edx
  8004eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ee:	89 08                	mov    %ecx,(%eax)
  8004f0:	8b 02                	mov    (%edx),%eax
  8004f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800503:	8b 10                	mov    (%eax),%edx
  800505:	3b 50 04             	cmp    0x4(%eax),%edx
  800508:	73 0a                	jae    800514 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80050d:	88 0a                	mov    %cl,(%edx)
  80050f:	83 c2 01             	add    $0x1,%edx
  800512:	89 10                	mov    %edx,(%eax)
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80051c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	8b 45 10             	mov    0x10(%ebp),%eax
  800526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	8b 45 08             	mov    0x8(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 02 00 00 00       	call   80053e <vprintfmt>
	va_end(ap);
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	57                   	push   %edi
  800542:	56                   	push   %esi
  800543:	53                   	push   %ebx
  800544:	83 ec 5c             	sub    $0x5c,%esp
  800547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054a:	8b 75 10             	mov    0x10(%ebp),%esi
  80054d:	eb 12                	jmp    800561 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 84 e4 04 00 00    	je     800a3b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800561:	0f b6 06             	movzbl (%esi),%eax
  800564:	83 c6 01             	add    $0x1,%esi
  800567:	83 f8 25             	cmp    $0x25,%eax
  80056a:	75 e3                	jne    80054f <vprintfmt+0x11>
  80056c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800570:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800577:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80057c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800583:	b9 00 00 00 00       	mov    $0x0,%ecx
  800588:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80058b:	eb 2b                	jmp    8005b8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800590:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800594:	eb 22                	jmp    8005b8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800599:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80059d:	eb 19                	jmp    8005b8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005a2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005a9:	eb 0d                	jmp    8005b8 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005ab:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8005ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005b1:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	0f b6 06             	movzbl (%esi),%eax
  8005bb:	0f b6 d0             	movzbl %al,%edx
  8005be:	8d 7e 01             	lea    0x1(%esi),%edi
  8005c1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c4:	83 e8 23             	sub    $0x23,%eax
  8005c7:	3c 55                	cmp    $0x55,%al
  8005c9:	0f 87 46 04 00 00    	ja     800a15 <vprintfmt+0x4d7>
  8005cf:	0f b6 c0             	movzbl %al,%eax
  8005d2:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d9:	83 ea 30             	sub    $0x30,%edx
  8005dc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8005df:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005e3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8005e9:	83 fa 09             	cmp    $0x9,%edx
  8005ec:	77 4a                	ja     800638 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005f4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005f7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005fb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005fe:	8d 50 d0             	lea    -0x30(%eax),%edx
  800601:	83 fa 09             	cmp    $0x9,%edx
  800604:	76 eb                	jbe    8005f1 <vprintfmt+0xb3>
  800606:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800609:	eb 2d                	jmp    800638 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80061c:	eb 1a                	jmp    800638 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800621:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800625:	79 91                	jns    8005b8 <vprintfmt+0x7a>
  800627:	e9 73 ff ff ff       	jmp    80059f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80062f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800636:	eb 80                	jmp    8005b8 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800638:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80063c:	0f 89 76 ff ff ff    	jns    8005b8 <vprintfmt+0x7a>
  800642:	e9 64 ff ff ff       	jmp    8005ab <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800647:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80064d:	e9 66 ff ff ff       	jmp    8005b8 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80066a:	e9 f2 fe ff ff       	jmp    800561 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80066f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800673:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800676:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80067a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80067d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800681:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800684:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800687:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80068b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80068e:	80 f9 09             	cmp    $0x9,%cl
  800691:	77 1d                	ja     8006b0 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800693:	0f be c0             	movsbl %al,%eax
  800696:	6b c0 64             	imul   $0x64,%eax,%eax
  800699:	0f be d2             	movsbl %dl,%edx
  80069c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80069f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8006a6:	a3 04 30 80 00       	mov    %eax,0x803004
  8006ab:	e9 b1 fe ff ff       	jmp    800561 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8006b0:	c7 44 24 04 0b 26 80 	movl   $0x80260b,0x4(%esp)
  8006b7:	00 
  8006b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	e8 18 05 00 00       	call   800bdb <strcmp>
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	75 0f                	jne    8006d6 <vprintfmt+0x198>
  8006c7:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8006ce:	00 00 00 
  8006d1:	e9 8b fe ff ff       	jmp    800561 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8006d6:	c7 44 24 04 0f 26 80 	movl   $0x80260f,0x4(%esp)
  8006dd:	00 
  8006de:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006e1:	89 14 24             	mov    %edx,(%esp)
  8006e4:	e8 f2 04 00 00       	call   800bdb <strcmp>
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	75 0f                	jne    8006fc <vprintfmt+0x1be>
  8006ed:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8006f4:	00 00 00 
  8006f7:	e9 65 fe ff ff       	jmp    800561 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8006fc:	c7 44 24 04 13 26 80 	movl   $0x802613,0x4(%esp)
  800703:	00 
  800704:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800707:	89 0c 24             	mov    %ecx,(%esp)
  80070a:	e8 cc 04 00 00       	call   800bdb <strcmp>
  80070f:	85 c0                	test   %eax,%eax
  800711:	75 0f                	jne    800722 <vprintfmt+0x1e4>
  800713:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  80071a:	00 00 00 
  80071d:	e9 3f fe ff ff       	jmp    800561 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800722:	c7 44 24 04 17 26 80 	movl   $0x802617,0x4(%esp)
  800729:	00 
  80072a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80072d:	89 3c 24             	mov    %edi,(%esp)
  800730:	e8 a6 04 00 00       	call   800bdb <strcmp>
  800735:	85 c0                	test   %eax,%eax
  800737:	75 0f                	jne    800748 <vprintfmt+0x20a>
  800739:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800740:	00 00 00 
  800743:	e9 19 fe ff ff       	jmp    800561 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800748:	c7 44 24 04 1b 26 80 	movl   $0x80261b,0x4(%esp)
  80074f:	00 
  800750:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 80 04 00 00       	call   800bdb <strcmp>
  80075b:	85 c0                	test   %eax,%eax
  80075d:	75 0f                	jne    80076e <vprintfmt+0x230>
  80075f:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800766:	00 00 00 
  800769:	e9 f3 fd ff ff       	jmp    800561 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80076e:	c7 44 24 04 1f 26 80 	movl   $0x80261f,0x4(%esp)
  800775:	00 
  800776:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800779:	89 14 24             	mov    %edx,(%esp)
  80077c:	e8 5a 04 00 00       	call   800bdb <strcmp>
  800781:	83 f8 01             	cmp    $0x1,%eax
  800784:	19 c0                	sbb    %eax,%eax
  800786:	f7 d0                	not    %eax
  800788:	83 c0 08             	add    $0x8,%eax
  80078b:	a3 04 30 80 00       	mov    %eax,0x803004
  800790:	e9 cc fd ff ff       	jmp    800561 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 04             	lea    0x4(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	c1 fa 1f             	sar    $0x1f,%edx
  8007a5:	31 d0                	xor    %edx,%eax
  8007a7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007a9:	83 f8 0f             	cmp    $0xf,%eax
  8007ac:	7f 0b                	jg     8007b9 <vprintfmt+0x27b>
  8007ae:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	75 23                	jne    8007dc <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8007b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bd:	c7 44 24 08 23 26 80 	movl   $0x802623,0x8(%esp)
  8007c4:	00 
  8007c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007cc:	89 3c 24             	mov    %edi,(%esp)
  8007cf:	e8 42 fd ff ff       	call   800516 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007d7:	e9 85 fd ff ff       	jmp    800561 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e0:	c7 44 24 08 d5 29 80 	movl   $0x8029d5,0x8(%esp)
  8007e7:	00 
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ef:	89 3c 24             	mov    %edi,(%esp)
  8007f2:	e8 1f fd ff ff       	call   800516 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007fa:	e9 62 fd ff ff       	jmp    800561 <vprintfmt+0x23>
  8007ff:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800802:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800805:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8d 50 04             	lea    0x4(%eax),%edx
  80080e:	89 55 14             	mov    %edx,0x14(%ebp)
  800811:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800813:	85 f6                	test   %esi,%esi
  800815:	b8 04 26 80 00       	mov    $0x802604,%eax
  80081a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80081d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800821:	7e 06                	jle    800829 <vprintfmt+0x2eb>
  800823:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800827:	75 13                	jne    80083c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800829:	0f be 06             	movsbl (%esi),%eax
  80082c:	83 c6 01             	add    $0x1,%esi
  80082f:	85 c0                	test   %eax,%eax
  800831:	0f 85 94 00 00 00    	jne    8008cb <vprintfmt+0x38d>
  800837:	e9 81 00 00 00       	jmp    8008bd <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80083c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800840:	89 34 24             	mov    %esi,(%esp)
  800843:	e8 a3 02 00 00       	call   800aeb <strnlen>
  800848:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80084b:	29 c2                	sub    %eax,%edx
  80084d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800850:	85 d2                	test   %edx,%edx
  800852:	7e d5                	jle    800829 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800854:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800858:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80085b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80085e:	89 d6                	mov    %edx,%esi
  800860:	89 cf                	mov    %ecx,%edi
  800862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800866:	89 3c 24             	mov    %edi,(%esp)
  800869:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086c:	83 ee 01             	sub    $0x1,%esi
  80086f:	75 f1                	jne    800862 <vprintfmt+0x324>
  800871:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800874:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800877:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80087a:	eb ad                	jmp    800829 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80087c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800880:	74 1b                	je     80089d <vprintfmt+0x35f>
  800882:	8d 50 e0             	lea    -0x20(%eax),%edx
  800885:	83 fa 5e             	cmp    $0x5e,%edx
  800888:	76 13                	jbe    80089d <vprintfmt+0x35f>
					putch('?', putdat);
  80088a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80088d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800891:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800898:	ff 55 08             	call   *0x8(%ebp)
  80089b:	eb 0d                	jmp    8008aa <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80089d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008aa:	83 eb 01             	sub    $0x1,%ebx
  8008ad:	0f be 06             	movsbl (%esi),%eax
  8008b0:	83 c6 01             	add    $0x1,%esi
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	75 1a                	jne    8008d1 <vprintfmt+0x393>
  8008b7:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8008ba:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008c0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008c4:	7f 1c                	jg     8008e2 <vprintfmt+0x3a4>
  8008c6:	e9 96 fc ff ff       	jmp    800561 <vprintfmt+0x23>
  8008cb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008ce:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d1:	85 ff                	test   %edi,%edi
  8008d3:	78 a7                	js     80087c <vprintfmt+0x33e>
  8008d5:	83 ef 01             	sub    $0x1,%edi
  8008d8:	79 a2                	jns    80087c <vprintfmt+0x33e>
  8008da:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8008dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008e0:	eb db                	jmp    8008bd <vprintfmt+0x37f>
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	89 de                	mov    %ebx,%esi
  8008e7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008f7:	83 eb 01             	sub    $0x1,%ebx
  8008fa:	75 ee                	jne    8008ea <vprintfmt+0x3ac>
  8008fc:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800901:	e9 5b fc ff ff       	jmp    800561 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800906:	83 f9 01             	cmp    $0x1,%ecx
  800909:	7e 10                	jle    80091b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 50 08             	lea    0x8(%eax),%edx
  800911:	89 55 14             	mov    %edx,0x14(%ebp)
  800914:	8b 30                	mov    (%eax),%esi
  800916:	8b 78 04             	mov    0x4(%eax),%edi
  800919:	eb 26                	jmp    800941 <vprintfmt+0x403>
	else if (lflag)
  80091b:	85 c9                	test   %ecx,%ecx
  80091d:	74 12                	je     800931 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8d 50 04             	lea    0x4(%eax),%edx
  800925:	89 55 14             	mov    %edx,0x14(%ebp)
  800928:	8b 30                	mov    (%eax),%esi
  80092a:	89 f7                	mov    %esi,%edi
  80092c:	c1 ff 1f             	sar    $0x1f,%edi
  80092f:	eb 10                	jmp    800941 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800931:	8b 45 14             	mov    0x14(%ebp),%eax
  800934:	8d 50 04             	lea    0x4(%eax),%edx
  800937:	89 55 14             	mov    %edx,0x14(%ebp)
  80093a:	8b 30                	mov    (%eax),%esi
  80093c:	89 f7                	mov    %esi,%edi
  80093e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800941:	85 ff                	test   %edi,%edi
  800943:	78 0e                	js     800953 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800945:	89 f0                	mov    %esi,%eax
  800947:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800949:	be 0a 00 00 00       	mov    $0xa,%esi
  80094e:	e9 84 00 00 00       	jmp    8009d7 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800953:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800957:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80095e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800961:	89 f0                	mov    %esi,%eax
  800963:	89 fa                	mov    %edi,%edx
  800965:	f7 d8                	neg    %eax
  800967:	83 d2 00             	adc    $0x0,%edx
  80096a:	f7 da                	neg    %edx
			}
			base = 10;
  80096c:	be 0a 00 00 00       	mov    $0xa,%esi
  800971:	eb 64                	jmp    8009d7 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800973:	89 ca                	mov    %ecx,%edx
  800975:	8d 45 14             	lea    0x14(%ebp),%eax
  800978:	e8 42 fb ff ff       	call   8004bf <getuint>
			base = 10;
  80097d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800982:	eb 53                	jmp    8009d7 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800984:	89 ca                	mov    %ecx,%edx
  800986:	8d 45 14             	lea    0x14(%ebp),%eax
  800989:	e8 31 fb ff ff       	call   8004bf <getuint>
    			base = 8;
  80098e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800993:	eb 42                	jmp    8009d7 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800995:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800999:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009ae:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b4:	8d 50 04             	lea    0x4(%eax),%edx
  8009b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009ba:	8b 00                	mov    (%eax),%eax
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009c1:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8009c6:	eb 0f                	jmp    8009d7 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c8:	89 ca                	mov    %ecx,%edx
  8009ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8009cd:	e8 ed fa ff ff       	call   8004bf <getuint>
			base = 16;
  8009d2:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009d7:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009db:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8009df:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009e2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8009e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8009ea:	89 04 24             	mov    %eax,(%esp)
  8009ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f1:	89 da                	mov    %ebx,%edx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	e8 e9 f9 ff ff       	call   8003e4 <printnum>
			break;
  8009fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009fe:	e9 5e fb ff ff       	jmp    800561 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a07:	89 14 24             	mov    %edx,(%esp)
  800a0a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a10:	e9 4c fb ff ff       	jmp    800561 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a19:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a20:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a23:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a27:	0f 84 34 fb ff ff    	je     800561 <vprintfmt+0x23>
  800a2d:	83 ee 01             	sub    $0x1,%esi
  800a30:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a34:	75 f7                	jne    800a2d <vprintfmt+0x4ef>
  800a36:	e9 26 fb ff ff       	jmp    800561 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a3b:	83 c4 5c             	add    $0x5c,%esp
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	83 ec 28             	sub    $0x28,%esp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a52:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a56:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a60:	85 c0                	test   %eax,%eax
  800a62:	74 30                	je     800a94 <vsnprintf+0x51>
  800a64:	85 d2                	test   %edx,%edx
  800a66:	7e 2c                	jle    800a94 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a68:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a72:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a76:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7d:	c7 04 24 f9 04 80 00 	movl   $0x8004f9,(%esp)
  800a84:	e8 b5 fa ff ff       	call   80053e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a92:	eb 05                	jmp    800a99 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a99:	c9                   	leave  
  800a9a:	c3                   	ret    

00800a9b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aa1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	89 04 24             	mov    %eax,(%esp)
  800abc:	e8 82 ff ff ff       	call   800a43 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    
	...

00800ad0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	80 3a 00             	cmpb   $0x0,(%edx)
  800ade:	74 09                	je     800ae9 <strlen+0x19>
		n++;
  800ae0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ae3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ae7:	75 f7                	jne    800ae0 <strlen+0x10>
		n++;
	return n;
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	85 c9                	test   %ecx,%ecx
  800afc:	74 1a                	je     800b18 <strnlen+0x2d>
  800afe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b01:	74 15                	je     800b18 <strnlen+0x2d>
  800b03:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b08:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b0a:	39 ca                	cmp    %ecx,%edx
  800b0c:	74 0a                	je     800b18 <strnlen+0x2d>
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b16:	75 f0                	jne    800b08 <strnlen+0x1d>
		n++;
	return n;
}
  800b18:	5b                   	pop    %ebx
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	53                   	push   %ebx
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b2e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b31:	83 c2 01             	add    $0x1,%edx
  800b34:	84 c9                	test   %cl,%cl
  800b36:	75 f2                	jne    800b2a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b38:	5b                   	pop    %ebx
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b45:	89 1c 24             	mov    %ebx,(%esp)
  800b48:	e8 83 ff ff ff       	call   800ad0 <strlen>
	strcpy(dst + len, src);
  800b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b50:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b54:	01 d8                	add    %ebx,%eax
  800b56:	89 04 24             	mov    %eax,(%esp)
  800b59:	e8 bd ff ff ff       	call   800b1b <strcpy>
	return dst;
}
  800b5e:	89 d8                	mov    %ebx,%eax
  800b60:	83 c4 08             	add    $0x8,%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b74:	85 f6                	test   %esi,%esi
  800b76:	74 18                	je     800b90 <strncpy+0x2a>
  800b78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b7d:	0f b6 1a             	movzbl (%edx),%ebx
  800b80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b83:	80 3a 01             	cmpb   $0x1,(%edx)
  800b86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b89:	83 c1 01             	add    $0x1,%ecx
  800b8c:	39 f1                	cmp    %esi,%ecx
  800b8e:	75 ed                	jne    800b7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba3:	89 f8                	mov    %edi,%eax
  800ba5:	85 f6                	test   %esi,%esi
  800ba7:	74 2b                	je     800bd4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800ba9:	83 fe 01             	cmp    $0x1,%esi
  800bac:	74 23                	je     800bd1 <strlcpy+0x3d>
  800bae:	0f b6 0b             	movzbl (%ebx),%ecx
  800bb1:	84 c9                	test   %cl,%cl
  800bb3:	74 1c                	je     800bd1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800bb5:	83 ee 02             	sub    $0x2,%esi
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bbd:	88 08                	mov    %cl,(%eax)
  800bbf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bc2:	39 f2                	cmp    %esi,%edx
  800bc4:	74 0b                	je     800bd1 <strlcpy+0x3d>
  800bc6:	83 c2 01             	add    $0x1,%edx
  800bc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bcd:	84 c9                	test   %cl,%cl
  800bcf:	75 ec                	jne    800bbd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800bd1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bd4:	29 f8                	sub    %edi,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800be4:	0f b6 01             	movzbl (%ecx),%eax
  800be7:	84 c0                	test   %al,%al
  800be9:	74 16                	je     800c01 <strcmp+0x26>
  800beb:	3a 02                	cmp    (%edx),%al
  800bed:	75 12                	jne    800c01 <strcmp+0x26>
		p++, q++;
  800bef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bf2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800bf6:	84 c0                	test   %al,%al
  800bf8:	74 07                	je     800c01 <strcmp+0x26>
  800bfa:	83 c1 01             	add    $0x1,%ecx
  800bfd:	3a 02                	cmp    (%edx),%al
  800bff:	74 ee                	je     800bef <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c01:	0f b6 c0             	movzbl %al,%eax
  800c04:	0f b6 12             	movzbl (%edx),%edx
  800c07:	29 d0                	sub    %edx,%eax
}
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	53                   	push   %ebx
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c1d:	85 d2                	test   %edx,%edx
  800c1f:	74 28                	je     800c49 <strncmp+0x3e>
  800c21:	0f b6 01             	movzbl (%ecx),%eax
  800c24:	84 c0                	test   %al,%al
  800c26:	74 24                	je     800c4c <strncmp+0x41>
  800c28:	3a 03                	cmp    (%ebx),%al
  800c2a:	75 20                	jne    800c4c <strncmp+0x41>
  800c2c:	83 ea 01             	sub    $0x1,%edx
  800c2f:	74 13                	je     800c44 <strncmp+0x39>
		n--, p++, q++;
  800c31:	83 c1 01             	add    $0x1,%ecx
  800c34:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c37:	0f b6 01             	movzbl (%ecx),%eax
  800c3a:	84 c0                	test   %al,%al
  800c3c:	74 0e                	je     800c4c <strncmp+0x41>
  800c3e:	3a 03                	cmp    (%ebx),%al
  800c40:	74 ea                	je     800c2c <strncmp+0x21>
  800c42:	eb 08                	jmp    800c4c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c4c:	0f b6 01             	movzbl (%ecx),%eax
  800c4f:	0f b6 13             	movzbl (%ebx),%edx
  800c52:	29 d0                	sub    %edx,%eax
  800c54:	eb f3                	jmp    800c49 <strncmp+0x3e>

00800c56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c60:	0f b6 10             	movzbl (%eax),%edx
  800c63:	84 d2                	test   %dl,%dl
  800c65:	74 1c                	je     800c83 <strchr+0x2d>
		if (*s == c)
  800c67:	38 ca                	cmp    %cl,%dl
  800c69:	75 09                	jne    800c74 <strchr+0x1e>
  800c6b:	eb 1b                	jmp    800c88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c6d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800c70:	38 ca                	cmp    %cl,%dl
  800c72:	74 14                	je     800c88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c74:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800c78:	84 d2                	test   %dl,%dl
  800c7a:	75 f1                	jne    800c6d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c81:	eb 05                	jmp    800c88 <strchr+0x32>
  800c83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c94:	0f b6 10             	movzbl (%eax),%edx
  800c97:	84 d2                	test   %dl,%dl
  800c99:	74 14                	je     800caf <strfind+0x25>
		if (*s == c)
  800c9b:	38 ca                	cmp    %cl,%dl
  800c9d:	75 06                	jne    800ca5 <strfind+0x1b>
  800c9f:	eb 0e                	jmp    800caf <strfind+0x25>
  800ca1:	38 ca                	cmp    %cl,%dl
  800ca3:	74 0a                	je     800caf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ca5:	83 c0 01             	add    $0x1,%eax
  800ca8:	0f b6 10             	movzbl (%eax),%edx
  800cab:	84 d2                	test   %dl,%dl
  800cad:	75 f2                	jne    800ca1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cc9:	85 c9                	test   %ecx,%ecx
  800ccb:	74 30                	je     800cfd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ccd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cd3:	75 25                	jne    800cfa <memset+0x49>
  800cd5:	f6 c1 03             	test   $0x3,%cl
  800cd8:	75 20                	jne    800cfa <memset+0x49>
		c &= 0xFF;
  800cda:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cdd:	89 d3                	mov    %edx,%ebx
  800cdf:	c1 e3 08             	shl    $0x8,%ebx
  800ce2:	89 d6                	mov    %edx,%esi
  800ce4:	c1 e6 18             	shl    $0x18,%esi
  800ce7:	89 d0                	mov    %edx,%eax
  800ce9:	c1 e0 10             	shl    $0x10,%eax
  800cec:	09 f0                	or     %esi,%eax
  800cee:	09 d0                	or     %edx,%eax
  800cf0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cf2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cf5:	fc                   	cld    
  800cf6:	f3 ab                	rep stos %eax,%es:(%edi)
  800cf8:	eb 03                	jmp    800cfd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cfa:	fc                   	cld    
  800cfb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cfd:	89 f8                	mov    %edi,%eax
  800cff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d08:	89 ec                	mov    %ebp,%esp
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 08             	sub    $0x8,%esp
  800d12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d15:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d21:	39 c6                	cmp    %eax,%esi
  800d23:	73 36                	jae    800d5b <memmove+0x4f>
  800d25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d28:	39 d0                	cmp    %edx,%eax
  800d2a:	73 2f                	jae    800d5b <memmove+0x4f>
		s += n;
		d += n;
  800d2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d2f:	f6 c2 03             	test   $0x3,%dl
  800d32:	75 1b                	jne    800d4f <memmove+0x43>
  800d34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d3a:	75 13                	jne    800d4f <memmove+0x43>
  800d3c:	f6 c1 03             	test   $0x3,%cl
  800d3f:	75 0e                	jne    800d4f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d41:	83 ef 04             	sub    $0x4,%edi
  800d44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d4a:	fd                   	std    
  800d4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d4d:	eb 09                	jmp    800d58 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d4f:	83 ef 01             	sub    $0x1,%edi
  800d52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d55:	fd                   	std    
  800d56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d58:	fc                   	cld    
  800d59:	eb 20                	jmp    800d7b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d61:	75 13                	jne    800d76 <memmove+0x6a>
  800d63:	a8 03                	test   $0x3,%al
  800d65:	75 0f                	jne    800d76 <memmove+0x6a>
  800d67:	f6 c1 03             	test   $0x3,%cl
  800d6a:	75 0a                	jne    800d76 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d6c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d6f:	89 c7                	mov    %eax,%edi
  800d71:	fc                   	cld    
  800d72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d74:	eb 05                	jmp    800d7b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d76:	89 c7                	mov    %eax,%edi
  800d78:	fc                   	cld    
  800d79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d81:	89 ec                	mov    %ebp,%esp
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	89 04 24             	mov    %eax,(%esp)
  800d9f:	e8 68 ff ff ff       	call   800d0c <memmove>
}
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    

00800da6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800daf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dba:	85 ff                	test   %edi,%edi
  800dbc:	74 37                	je     800df5 <memcmp+0x4f>
		if (*s1 != *s2)
  800dbe:	0f b6 03             	movzbl (%ebx),%eax
  800dc1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc4:	83 ef 01             	sub    $0x1,%edi
  800dc7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800dcc:	38 c8                	cmp    %cl,%al
  800dce:	74 1c                	je     800dec <memcmp+0x46>
  800dd0:	eb 10                	jmp    800de2 <memcmp+0x3c>
  800dd2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800dd7:	83 c2 01             	add    $0x1,%edx
  800dda:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800dde:	38 c8                	cmp    %cl,%al
  800de0:	74 0a                	je     800dec <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800de2:	0f b6 c0             	movzbl %al,%eax
  800de5:	0f b6 c9             	movzbl %cl,%ecx
  800de8:	29 c8                	sub    %ecx,%eax
  800dea:	eb 09                	jmp    800df5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dec:	39 fa                	cmp    %edi,%edx
  800dee:	75 e2                	jne    800dd2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800df0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e00:	89 c2                	mov    %eax,%edx
  800e02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e05:	39 d0                	cmp    %edx,%eax
  800e07:	73 19                	jae    800e22 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e0d:	38 08                	cmp    %cl,(%eax)
  800e0f:	75 06                	jne    800e17 <memfind+0x1d>
  800e11:	eb 0f                	jmp    800e22 <memfind+0x28>
  800e13:	38 08                	cmp    %cl,(%eax)
  800e15:	74 0b                	je     800e22 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e17:	83 c0 01             	add    $0x1,%eax
  800e1a:	39 d0                	cmp    %edx,%eax
  800e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e20:	75 f1                	jne    800e13 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e30:	0f b6 02             	movzbl (%edx),%eax
  800e33:	3c 20                	cmp    $0x20,%al
  800e35:	74 04                	je     800e3b <strtol+0x17>
  800e37:	3c 09                	cmp    $0x9,%al
  800e39:	75 0e                	jne    800e49 <strtol+0x25>
		s++;
  800e3b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e3e:	0f b6 02             	movzbl (%edx),%eax
  800e41:	3c 20                	cmp    $0x20,%al
  800e43:	74 f6                	je     800e3b <strtol+0x17>
  800e45:	3c 09                	cmp    $0x9,%al
  800e47:	74 f2                	je     800e3b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e49:	3c 2b                	cmp    $0x2b,%al
  800e4b:	75 0a                	jne    800e57 <strtol+0x33>
		s++;
  800e4d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e50:	bf 00 00 00 00       	mov    $0x0,%edi
  800e55:	eb 10                	jmp    800e67 <strtol+0x43>
  800e57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e5c:	3c 2d                	cmp    $0x2d,%al
  800e5e:	75 07                	jne    800e67 <strtol+0x43>
		s++, neg = 1;
  800e60:	83 c2 01             	add    $0x1,%edx
  800e63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e67:	85 db                	test   %ebx,%ebx
  800e69:	0f 94 c0             	sete   %al
  800e6c:	74 05                	je     800e73 <strtol+0x4f>
  800e6e:	83 fb 10             	cmp    $0x10,%ebx
  800e71:	75 15                	jne    800e88 <strtol+0x64>
  800e73:	80 3a 30             	cmpb   $0x30,(%edx)
  800e76:	75 10                	jne    800e88 <strtol+0x64>
  800e78:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e7c:	75 0a                	jne    800e88 <strtol+0x64>
		s += 2, base = 16;
  800e7e:	83 c2 02             	add    $0x2,%edx
  800e81:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e86:	eb 13                	jmp    800e9b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e88:	84 c0                	test   %al,%al
  800e8a:	74 0f                	je     800e9b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e91:	80 3a 30             	cmpb   $0x30,(%edx)
  800e94:	75 05                	jne    800e9b <strtol+0x77>
		s++, base = 8;
  800e96:	83 c2 01             	add    $0x1,%edx
  800e99:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ea2:	0f b6 0a             	movzbl (%edx),%ecx
  800ea5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ea8:	80 fb 09             	cmp    $0x9,%bl
  800eab:	77 08                	ja     800eb5 <strtol+0x91>
			dig = *s - '0';
  800ead:	0f be c9             	movsbl %cl,%ecx
  800eb0:	83 e9 30             	sub    $0x30,%ecx
  800eb3:	eb 1e                	jmp    800ed3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800eb5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800eb8:	80 fb 19             	cmp    $0x19,%bl
  800ebb:	77 08                	ja     800ec5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ebd:	0f be c9             	movsbl %cl,%ecx
  800ec0:	83 e9 57             	sub    $0x57,%ecx
  800ec3:	eb 0e                	jmp    800ed3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800ec5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ec8:	80 fb 19             	cmp    $0x19,%bl
  800ecb:	77 14                	ja     800ee1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ecd:	0f be c9             	movsbl %cl,%ecx
  800ed0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ed3:	39 f1                	cmp    %esi,%ecx
  800ed5:	7d 0e                	jge    800ee5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ed7:	83 c2 01             	add    $0x1,%edx
  800eda:	0f af c6             	imul   %esi,%eax
  800edd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800edf:	eb c1                	jmp    800ea2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ee1:	89 c1                	mov    %eax,%ecx
  800ee3:	eb 02                	jmp    800ee7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ee5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ee7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eeb:	74 05                	je     800ef2 <strtol+0xce>
		*endptr = (char *) s;
  800eed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ef0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ef2:	89 ca                	mov    %ecx,%edx
  800ef4:	f7 da                	neg    %edx
  800ef6:	85 ff                	test   %edi,%edi
  800ef8:	0f 45 c2             	cmovne %edx,%eax
}
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f17:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	89 c7                	mov    %eax,%edi
  800f1e:	89 c6                	mov    %eax,%esi
  800f20:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f2b:	89 ec                	mov    %ebp,%esp
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	89 d1                	mov    %edx,%ecx
  800f4a:	89 d3                	mov    %edx,%ebx
  800f4c:	89 d7                	mov    %edx,%edi
  800f4e:	89 d6                	mov    %edx,%esi
  800f50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5b:	89 ec                	mov    %ebp,%esp
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 38             	sub    $0x38,%esp
  800f65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f73:	b8 03 00 00 00       	mov    $0x3,%eax
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7b:	89 cb                	mov    %ecx,%ebx
  800f7d:	89 cf                	mov    %ecx,%edi
  800f7f:	89 ce                	mov    %ecx,%esi
  800f81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f83:	85 c0                	test   %eax,%eax
  800f85:	7e 28                	jle    800faf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f92:	00 
  800f93:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa2:	00 
  800fa3:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800faa:	e8 1d f3 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800faf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb8:	89 ec                	mov    %ebp,%esp
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	89 d3                	mov    %edx,%ebx
  800fd9:	89 d7                	mov    %edx,%edi
  800fdb:	89 d6                	mov    %edx,%esi
  800fdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_yield>:

void
sys_yield(void)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ff5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ff8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffb:	ba 00 00 00 00       	mov    $0x0,%edx
  801000:	b8 0b 00 00 00       	mov    $0xb,%eax
  801005:	89 d1                	mov    %edx,%ecx
  801007:	89 d3                	mov    %edx,%ebx
  801009:	89 d7                	mov    %edx,%edi
  80100b:	89 d6                	mov    %edx,%esi
  80100d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80100f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801012:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801015:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801018:	89 ec                	mov    %ebp,%esp
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 38             	sub    $0x38,%esp
  801022:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801025:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801028:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102b:	be 00 00 00 00       	mov    $0x0,%esi
  801030:	b8 04 00 00 00       	mov    $0x4,%eax
  801035:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	8b 55 08             	mov    0x8(%ebp),%edx
  80103e:	89 f7                	mov    %esi,%edi
  801040:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801042:	85 c0                	test   %eax,%eax
  801044:	7e 28                	jle    80106e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801046:	89 44 24 10          	mov    %eax,0x10(%esp)
  80104a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801051:	00 
  801052:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801059:	00 
  80105a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801061:	00 
  801062:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801069:	e8 5e f2 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80106e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801071:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801074:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801077:	89 ec                	mov    %ebp,%esp
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	83 ec 38             	sub    $0x38,%esp
  801081:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801084:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801087:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108a:	b8 05 00 00 00       	mov    $0x5,%eax
  80108f:	8b 75 18             	mov    0x18(%ebp),%esi
  801092:	8b 7d 14             	mov    0x14(%ebp),%edi
  801095:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801098:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109b:	8b 55 08             	mov    0x8(%ebp),%edx
  80109e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	7e 28                	jle    8010cc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010af:	00 
  8010b0:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010bf:	00 
  8010c0:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8010c7:	e8 00 f2 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010cc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010cf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d5:	89 ec                	mov    %ebp,%esp
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	83 ec 38             	sub    $0x38,%esp
  8010df:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010e2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010e5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f8:	89 df                	mov    %ebx,%edi
  8010fa:	89 de                	mov    %ebx,%esi
  8010fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	7e 28                	jle    80112a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801102:	89 44 24 10          	mov    %eax,0x10(%esp)
  801106:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80110d:	00 
  80110e:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801115:	00 
  801116:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111d:	00 
  80111e:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801125:	e8 a2 f1 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80112a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80112d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801130:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801133:	89 ec                	mov    %ebp,%esp
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 38             	sub    $0x38,%esp
  80113d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801140:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801143:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114b:	b8 08 00 00 00       	mov    $0x8,%eax
  801150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
  801156:	89 df                	mov    %ebx,%edi
  801158:	89 de                	mov    %ebx,%esi
  80115a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80115c:	85 c0                	test   %eax,%eax
  80115e:	7e 28                	jle    801188 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801160:	89 44 24 10          	mov    %eax,0x10(%esp)
  801164:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80116b:	00 
  80116c:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801183:	e8 44 f1 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801188:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80118b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80118e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801191:	89 ec                	mov    %ebp,%esp
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 38             	sub    $0x38,%esp
  80119b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80119e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a9:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b4:	89 df                	mov    %ebx,%edi
  8011b6:	89 de                	mov    %ebx,%esi
  8011b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	7e 28                	jle    8011e6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011c9:	00 
  8011ca:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8011e1:	e8 e6 f0 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ef:	89 ec                	mov    %ebp,%esp
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 38             	sub    $0x38,%esp
  8011f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	b8 0a 00 00 00       	mov    $0xa,%eax
  80120c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120f:	8b 55 08             	mov    0x8(%ebp),%edx
  801212:	89 df                	mov    %ebx,%edi
  801214:	89 de                	mov    %ebx,%esi
  801216:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801218:	85 c0                	test   %eax,%eax
  80121a:	7e 28                	jle    801244 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801220:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801227:	00 
  801228:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  80122f:	00 
  801230:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801237:	00 
  801238:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  80123f:	e8 88 f0 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801244:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801247:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80124a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80124d:	89 ec                	mov    %ebp,%esp
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80125a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80125d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801260:	be 00 00 00 00       	mov    $0x0,%esi
  801265:	b8 0c 00 00 00       	mov    $0xc,%eax
  80126a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80126d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801273:	8b 55 08             	mov    0x8(%ebp),%edx
  801276:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801278:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80127b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80127e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801281:	89 ec                	mov    %ebp,%esp
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	83 ec 38             	sub    $0x38,%esp
  80128b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80128e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801291:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801294:	b9 00 00 00 00       	mov    $0x0,%ecx
  801299:	b8 0d 00 00 00       	mov    $0xd,%eax
  80129e:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a1:	89 cb                	mov    %ecx,%ebx
  8012a3:	89 cf                	mov    %ecx,%edi
  8012a5:	89 ce                	mov    %ecx,%esi
  8012a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	7e 28                	jle    8012d5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c8:	00 
  8012c9:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8012d0:	e8 f7 ef ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012de:	89 ec                	mov    %ebp,%esp
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012eb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012ee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fe:	89 cb                	mov    %ecx,%ebx
  801300:	89 cf                	mov    %ecx,%edi
  801302:	89 ce                	mov    %ecx,%esi
  801304:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801306:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801309:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80130c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80130f:	89 ec                	mov    %ebp,%esp
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    
	...

00801320 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	05 00 00 00 30       	add    $0x30000000,%eax
  80132b:	c1 e8 0c             	shr    $0xc,%eax
}
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801336:	8b 45 08             	mov    0x8(%ebp),%eax
  801339:	89 04 24             	mov    %eax,(%esp)
  80133c:	e8 df ff ff ff       	call   801320 <fd2num>
  801341:	05 20 00 0d 00       	add    $0xd0020,%eax
  801346:	c1 e0 0c             	shl    $0xc,%eax
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801352:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801357:	a8 01                	test   $0x1,%al
  801359:	74 34                	je     80138f <fd_alloc+0x44>
  80135b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801360:	a8 01                	test   $0x1,%al
  801362:	74 32                	je     801396 <fd_alloc+0x4b>
  801364:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801369:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	c1 ea 16             	shr    $0x16,%edx
  801370:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801377:	f6 c2 01             	test   $0x1,%dl
  80137a:	74 1f                	je     80139b <fd_alloc+0x50>
  80137c:	89 c2                	mov    %eax,%edx
  80137e:	c1 ea 0c             	shr    $0xc,%edx
  801381:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801388:	f6 c2 01             	test   $0x1,%dl
  80138b:	75 17                	jne    8013a4 <fd_alloc+0x59>
  80138d:	eb 0c                	jmp    80139b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80138f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801394:	eb 05                	jmp    80139b <fd_alloc+0x50>
  801396:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80139b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80139d:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a2:	eb 17                	jmp    8013bb <fd_alloc+0x70>
  8013a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013ae:	75 b9                	jne    801369 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013bb:	5b                   	pop    %ebx
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013c9:	83 fa 1f             	cmp    $0x1f,%edx
  8013cc:	77 3f                	ja     80140d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ce:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8013d4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013d7:	89 d0                	mov    %edx,%eax
  8013d9:	c1 e8 16             	shr    $0x16,%eax
  8013dc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e8:	f6 c1 01             	test   $0x1,%cl
  8013eb:	74 20                	je     80140d <fd_lookup+0x4f>
  8013ed:	89 d0                	mov    %edx,%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
  8013f2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013fe:	f6 c1 01             	test   $0x1,%cl
  801401:	74 0a                	je     80140d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801403:	8b 45 0c             	mov    0xc(%ebp),%eax
  801406:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 14             	sub    $0x14,%esp
  801416:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801419:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80141c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801421:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801427:	75 17                	jne    801440 <dev_lookup+0x31>
  801429:	eb 07                	jmp    801432 <dev_lookup+0x23>
  80142b:	39 0a                	cmp    %ecx,(%edx)
  80142d:	75 11                	jne    801440 <dev_lookup+0x31>
  80142f:	90                   	nop
  801430:	eb 05                	jmp    801437 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801432:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801437:	89 13                	mov    %edx,(%ebx)
			return 0;
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
  80143e:	eb 35                	jmp    801475 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801440:	83 c0 01             	add    $0x1,%eax
  801443:	8b 14 85 ac 29 80 00 	mov    0x8029ac(,%eax,4),%edx
  80144a:	85 d2                	test   %edx,%edx
  80144c:	75 dd                	jne    80142b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80144e:	a1 04 40 80 00       	mov    0x804004,%eax
  801453:	8b 40 48             	mov    0x48(%eax),%eax
  801456:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80145a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145e:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  801465:	e8 5d ef ff ff       	call   8003c7 <cprintf>
	*dev = 0;
  80146a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801470:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801475:	83 c4 14             	add    $0x14,%esp
  801478:	5b                   	pop    %ebx
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 38             	sub    $0x38,%esp
  801481:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801484:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801487:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80148a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801491:	89 3c 24             	mov    %edi,(%esp)
  801494:	e8 87 fe ff ff       	call   801320 <fd2num>
  801499:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80149c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a0:	89 04 24             	mov    %eax,(%esp)
  8014a3:	e8 16 ff ff ff       	call   8013be <fd_lookup>
  8014a8:	89 c3                	mov    %eax,%ebx
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 05                	js     8014b3 <fd_close+0x38>
	    || fd != fd2)
  8014ae:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8014b1:	74 0e                	je     8014c1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8014b3:	89 f0                	mov    %esi,%eax
  8014b5:	84 c0                	test   %al,%al
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bc:	0f 44 d8             	cmove  %eax,%ebx
  8014bf:	eb 3d                	jmp    8014fe <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c8:	8b 07                	mov    (%edi),%eax
  8014ca:	89 04 24             	mov    %eax,(%esp)
  8014cd:	e8 3d ff ff ff       	call   80140f <dev_lookup>
  8014d2:	89 c3                	mov    %eax,%ebx
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 16                	js     8014ee <fd_close+0x73>
		if (dev->dev_close)
  8014d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	74 07                	je     8014ee <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8014e7:	89 3c 24             	mov    %edi,(%esp)
  8014ea:	ff d0                	call   *%eax
  8014ec:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f9:	e8 db fb ff ff       	call   8010d9 <sys_page_unmap>
	return r;
}
  8014fe:	89 d8                	mov    %ebx,%eax
  801500:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801503:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801506:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801509:	89 ec                	mov    %ebp,%esp
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    

0080150d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801513:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	89 04 24             	mov    %eax,(%esp)
  801520:	e8 99 fe ff ff       	call   8013be <fd_lookup>
  801525:	85 c0                	test   %eax,%eax
  801527:	78 13                	js     80153c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801529:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801530:	00 
  801531:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 3f ff ff ff       	call   80147b <fd_close>
}
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <close_all>:

void
close_all(void)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801545:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80154a:	89 1c 24             	mov    %ebx,(%esp)
  80154d:	e8 bb ff ff ff       	call   80150d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801552:	83 c3 01             	add    $0x1,%ebx
  801555:	83 fb 20             	cmp    $0x20,%ebx
  801558:	75 f0                	jne    80154a <close_all+0xc>
		close(i);
}
  80155a:	83 c4 14             	add    $0x14,%esp
  80155d:	5b                   	pop    %ebx
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    

00801560 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	83 ec 58             	sub    $0x58,%esp
  801566:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801569:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80156c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80156f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801572:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801575:	89 44 24 04          	mov    %eax,0x4(%esp)
  801579:	8b 45 08             	mov    0x8(%ebp),%eax
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	e8 3a fe ff ff       	call   8013be <fd_lookup>
  801584:	89 c3                	mov    %eax,%ebx
  801586:	85 c0                	test   %eax,%eax
  801588:	0f 88 e1 00 00 00    	js     80166f <dup+0x10f>
		return r;
	close(newfdnum);
  80158e:	89 3c 24             	mov    %edi,(%esp)
  801591:	e8 77 ff ff ff       	call   80150d <close>

	newfd = INDEX2FD(newfdnum);
  801596:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80159c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80159f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015a2:	89 04 24             	mov    %eax,(%esp)
  8015a5:	e8 86 fd ff ff       	call   801330 <fd2data>
  8015aa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015ac:	89 34 24             	mov    %esi,(%esp)
  8015af:	e8 7c fd ff ff       	call   801330 <fd2data>
  8015b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015b7:	89 d8                	mov    %ebx,%eax
  8015b9:	c1 e8 16             	shr    $0x16,%eax
  8015bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c3:	a8 01                	test   $0x1,%al
  8015c5:	74 46                	je     80160d <dup+0xad>
  8015c7:	89 d8                	mov    %ebx,%eax
  8015c9:	c1 e8 0c             	shr    $0xc,%eax
  8015cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015d3:	f6 c2 01             	test   $0x1,%dl
  8015d6:	74 35                	je     80160d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015df:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f6:	00 
  8015f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801602:	e8 74 fa ff ff       	call   80107b <sys_page_map>
  801607:	89 c3                	mov    %eax,%ebx
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 3b                	js     801648 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80160d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801610:	89 c2                	mov    %eax,%edx
  801612:	c1 ea 0c             	shr    $0xc,%edx
  801615:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80161c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801622:	89 54 24 10          	mov    %edx,0x10(%esp)
  801626:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80162a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801631:	00 
  801632:	89 44 24 04          	mov    %eax,0x4(%esp)
  801636:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163d:	e8 39 fa ff ff       	call   80107b <sys_page_map>
  801642:	89 c3                	mov    %eax,%ebx
  801644:	85 c0                	test   %eax,%eax
  801646:	79 25                	jns    80166d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801648:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801653:	e8 81 fa ff ff       	call   8010d9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801658:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80165b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801666:	e8 6e fa ff ff       	call   8010d9 <sys_page_unmap>
	return r;
  80166b:	eb 02                	jmp    80166f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80166d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80166f:	89 d8                	mov    %ebx,%eax
  801671:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801674:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801677:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80167a:	89 ec                	mov    %ebp,%esp
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 24             	sub    $0x24,%esp
  801685:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801688:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168f:	89 1c 24             	mov    %ebx,(%esp)
  801692:	e8 27 fd ff ff       	call   8013be <fd_lookup>
  801697:	85 c0                	test   %eax,%eax
  801699:	78 6d                	js     801708 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	8b 00                	mov    (%eax),%eax
  8016a7:	89 04 24             	mov    %eax,(%esp)
  8016aa:	e8 60 fd ff ff       	call   80140f <dev_lookup>
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 55                	js     801708 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	8b 50 08             	mov    0x8(%eax),%edx
  8016b9:	83 e2 03             	and    $0x3,%edx
  8016bc:	83 fa 01             	cmp    $0x1,%edx
  8016bf:	75 23                	jne    8016e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c6:	8b 40 48             	mov    0x48(%eax),%eax
  8016c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d1:	c7 04 24 70 29 80 00 	movl   $0x802970,(%esp)
  8016d8:	e8 ea ec ff ff       	call   8003c7 <cprintf>
		return -E_INVAL;
  8016dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e2:	eb 24                	jmp    801708 <read+0x8a>
	}
	if (!dev->dev_read)
  8016e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e7:	8b 52 08             	mov    0x8(%edx),%edx
  8016ea:	85 d2                	test   %edx,%edx
  8016ec:	74 15                	je     801703 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8016ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016fc:	89 04 24             	mov    %eax,(%esp)
  8016ff:	ff d2                	call   *%edx
  801701:	eb 05                	jmp    801708 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801703:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801708:	83 c4 24             	add    $0x24,%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	57                   	push   %edi
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 1c             	sub    $0x1c,%esp
  801717:	8b 7d 08             	mov    0x8(%ebp),%edi
  80171a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
  801722:	85 f6                	test   %esi,%esi
  801724:	74 30                	je     801756 <readn+0x48>
  801726:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80172b:	89 f2                	mov    %esi,%edx
  80172d:	29 c2                	sub    %eax,%edx
  80172f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801733:	03 45 0c             	add    0xc(%ebp),%eax
  801736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173a:	89 3c 24             	mov    %edi,(%esp)
  80173d:	e8 3c ff ff ff       	call   80167e <read>
		if (m < 0)
  801742:	85 c0                	test   %eax,%eax
  801744:	78 10                	js     801756 <readn+0x48>
			return m;
		if (m == 0)
  801746:	85 c0                	test   %eax,%eax
  801748:	74 0a                	je     801754 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174a:	01 c3                	add    %eax,%ebx
  80174c:	89 d8                	mov    %ebx,%eax
  80174e:	39 f3                	cmp    %esi,%ebx
  801750:	72 d9                	jb     80172b <readn+0x1d>
  801752:	eb 02                	jmp    801756 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801754:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801756:	83 c4 1c             	add    $0x1c,%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5f                   	pop    %edi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 24             	sub    $0x24,%esp
  801765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176f:	89 1c 24             	mov    %ebx,(%esp)
  801772:	e8 47 fc ff ff       	call   8013be <fd_lookup>
  801777:	85 c0                	test   %eax,%eax
  801779:	78 68                	js     8017e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801785:	8b 00                	mov    (%eax),%eax
  801787:	89 04 24             	mov    %eax,(%esp)
  80178a:	e8 80 fc ff ff       	call   80140f <dev_lookup>
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 50                	js     8017e3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801793:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801796:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179a:	75 23                	jne    8017bf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80179c:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a1:	8b 40 48             	mov    0x48(%eax),%eax
  8017a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ac:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  8017b3:	e8 0f ec ff ff       	call   8003c7 <cprintf>
		return -E_INVAL;
  8017b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017bd:	eb 24                	jmp    8017e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c5:	85 d2                	test   %edx,%edx
  8017c7:	74 15                	je     8017de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017cc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d7:	89 04 24             	mov    %eax,(%esp)
  8017da:	ff d2                	call   *%edx
  8017dc:	eb 05                	jmp    8017e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017e3:	83 c4 24             	add    $0x24,%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	89 04 24             	mov    %eax,(%esp)
  8017fc:	e8 bd fb ff ff       	call   8013be <fd_lookup>
  801801:	85 c0                	test   %eax,%eax
  801803:	78 0e                	js     801813 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801805:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801808:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	53                   	push   %ebx
  801819:	83 ec 24             	sub    $0x24,%esp
  80181c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801822:	89 44 24 04          	mov    %eax,0x4(%esp)
  801826:	89 1c 24             	mov    %ebx,(%esp)
  801829:	e8 90 fb ff ff       	call   8013be <fd_lookup>
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 61                	js     801893 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801835:	89 44 24 04          	mov    %eax,0x4(%esp)
  801839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183c:	8b 00                	mov    (%eax),%eax
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	e8 c9 fb ff ff       	call   80140f <dev_lookup>
  801846:	85 c0                	test   %eax,%eax
  801848:	78 49                	js     801893 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80184a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801851:	75 23                	jne    801876 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801853:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801858:	8b 40 48             	mov    0x48(%eax),%eax
  80185b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  80186a:	e8 58 eb ff ff       	call   8003c7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80186f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801874:	eb 1d                	jmp    801893 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801876:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801879:	8b 52 18             	mov    0x18(%edx),%edx
  80187c:	85 d2                	test   %edx,%edx
  80187e:	74 0e                	je     80188e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801883:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801887:	89 04 24             	mov    %eax,(%esp)
  80188a:	ff d2                	call   *%edx
  80188c:	eb 05                	jmp    801893 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80188e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801893:	83 c4 24             	add    $0x24,%esp
  801896:	5b                   	pop    %ebx
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	53                   	push   %ebx
  80189d:	83 ec 24             	sub    $0x24,%esp
  8018a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	89 04 24             	mov    %eax,(%esp)
  8018b0:	e8 09 fb ff ff       	call   8013be <fd_lookup>
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 52                	js     80190b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c3:	8b 00                	mov    (%eax),%eax
  8018c5:	89 04 24             	mov    %eax,(%esp)
  8018c8:	e8 42 fb ff ff       	call   80140f <dev_lookup>
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 3a                	js     80190b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018d8:	74 2c                	je     801906 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018e4:	00 00 00 
	stat->st_isdir = 0;
  8018e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ee:	00 00 00 
	stat->st_dev = dev;
  8018f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018fe:	89 14 24             	mov    %edx,(%esp)
  801901:	ff 50 14             	call   *0x14(%eax)
  801904:	eb 05                	jmp    80190b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801906:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80190b:	83 c4 24             	add    $0x24,%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 18             	sub    $0x18,%esp
  801917:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80191a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801924:	00 
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	89 04 24             	mov    %eax,(%esp)
  80192b:	e8 bc 01 00 00       	call   801aec <open>
  801930:	89 c3                	mov    %eax,%ebx
  801932:	85 c0                	test   %eax,%eax
  801934:	78 1b                	js     801951 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801936:	8b 45 0c             	mov    0xc(%ebp),%eax
  801939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193d:	89 1c 24             	mov    %ebx,(%esp)
  801940:	e8 54 ff ff ff       	call   801899 <fstat>
  801945:	89 c6                	mov    %eax,%esi
	close(fd);
  801947:	89 1c 24             	mov    %ebx,(%esp)
  80194a:	e8 be fb ff ff       	call   80150d <close>
	return r;
  80194f:	89 f3                	mov    %esi,%ebx
}
  801951:	89 d8                	mov    %ebx,%eax
  801953:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801956:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801959:	89 ec                	mov    %ebp,%esp
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    
  80195d:	00 00                	add    %al,(%eax)
	...

00801960 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 18             	sub    $0x18,%esp
  801966:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801969:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801970:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801977:	75 11                	jne    80198a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801979:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801980:	e8 5c 08 00 00       	call   8021e1 <ipc_find_env>
  801985:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80198a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801991:	00 
  801992:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801999:	00 
  80199a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199e:	a1 00 40 80 00       	mov    0x804000,%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 cb 07 00 00       	call   802176 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8019ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019b2:	00 
  8019b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019be:	e8 4d 07 00 00       	call   802110 <ipc_recv>
}
  8019c3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019c6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019c9:	89 ec                	mov    %ebp,%esp
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	53                   	push   %ebx
  8019d1:	83 ec 14             	sub    $0x14,%esp
  8019d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	8b 40 0c             	mov    0xc(%eax),%eax
  8019dd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8019ec:	e8 6f ff ff ff       	call   801960 <fsipc>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	78 2b                	js     801a20 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019f5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019fc:	00 
  8019fd:	89 1c 24             	mov    %ebx,(%esp)
  801a00:	e8 16 f1 ff ff       	call   800b1b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a05:	a1 80 50 80 00       	mov    0x805080,%eax
  801a0a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a10:	a1 84 50 80 00       	mov    0x805084,%eax
  801a15:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a20:	83 c4 14             	add    $0x14,%esp
  801a23:	5b                   	pop    %ebx
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a32:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a37:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3c:	b8 06 00 00 00       	mov    $0x6,%eax
  801a41:	e8 1a ff ff ff       	call   801960 <fsipc>
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 10             	sub    $0x10,%esp
  801a50:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	8b 40 0c             	mov    0xc(%eax),%eax
  801a59:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a64:	ba 00 00 00 00       	mov    $0x0,%edx
  801a69:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6e:	e8 ed fe ff ff       	call   801960 <fsipc>
  801a73:	89 c3                	mov    %eax,%ebx
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 6a                	js     801ae3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a79:	39 c6                	cmp    %eax,%esi
  801a7b:	73 24                	jae    801aa1 <devfile_read+0x59>
  801a7d:	c7 44 24 0c bc 29 80 	movl   $0x8029bc,0xc(%esp)
  801a84:	00 
  801a85:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801a8c:	00 
  801a8d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801a94:	00 
  801a95:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  801a9c:	e8 2b e8 ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  801aa1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa6:	7e 24                	jle    801acc <devfile_read+0x84>
  801aa8:	c7 44 24 0c e3 29 80 	movl   $0x8029e3,0xc(%esp)
  801aaf:	00 
  801ab0:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801ab7:	00 
  801ab8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801abf:	00 
  801ac0:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  801ac7:	e8 00 e8 ff ff       	call   8002cc <_panic>
	memmove(buf, &fsipcbuf, r);
  801acc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ad7:	00 
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	89 04 24             	mov    %eax,(%esp)
  801ade:	e8 29 f2 ff ff       	call   800d0c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801ae3:	89 d8                	mov    %ebx,%eax
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	83 ec 20             	sub    $0x20,%esp
  801af4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801af7:	89 34 24             	mov    %esi,(%esp)
  801afa:	e8 d1 ef ff ff       	call   800ad0 <strlen>
		return -E_BAD_PATH;
  801aff:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b09:	7f 5e                	jg     801b69 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 35 f8 ff ff       	call   80134b <fd_alloc>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 4d                	js     801b69 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b20:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b27:	e8 ef ef ff ff       	call   800b1b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b37:	b8 01 00 00 00       	mov    $0x1,%eax
  801b3c:	e8 1f fe ff ff       	call   801960 <fsipc>
  801b41:	89 c3                	mov    %eax,%ebx
  801b43:	85 c0                	test   %eax,%eax
  801b45:	79 15                	jns    801b5c <open+0x70>
		fd_close(fd, 0);
  801b47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b4e:	00 
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	89 04 24             	mov    %eax,(%esp)
  801b55:	e8 21 f9 ff ff       	call   80147b <fd_close>
		return r;
  801b5a:	eb 0d                	jmp    801b69 <open+0x7d>
	}

	return fd2num(fd);
  801b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 b9 f7 ff ff       	call   801320 <fd2num>
  801b67:	89 c3                	mov    %eax,%ebx
}
  801b69:	89 d8                	mov    %ebx,%eax
  801b6b:	83 c4 20             	add    $0x20,%esp
  801b6e:	5b                   	pop    %ebx
  801b6f:	5e                   	pop    %esi
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    
	...

00801b80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 18             	sub    $0x18,%esp
  801b86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b89:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 96 f7 ff ff       	call   801330 <fd2data>
  801b9a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b9c:	c7 44 24 04 ef 29 80 	movl   $0x8029ef,0x4(%esp)
  801ba3:	00 
  801ba4:	89 34 24             	mov    %esi,(%esp)
  801ba7:	e8 6f ef ff ff       	call   800b1b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bac:	8b 43 04             	mov    0x4(%ebx),%eax
  801baf:	2b 03                	sub    (%ebx),%eax
  801bb1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bb7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bbe:	00 00 00 
	stat->st_dev = &devpipe;
  801bc1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801bc8:	30 80 00 
	return 0;
}
  801bcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bd3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bd6:	89 ec                	mov    %ebp,%esp
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 14             	sub    $0x14,%esp
  801be1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801be4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bef:	e8 e5 f4 ff ff       	call   8010d9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf4:	89 1c 24             	mov    %ebx,(%esp)
  801bf7:	e8 34 f7 ff ff       	call   801330 <fd2data>
  801bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c07:	e8 cd f4 ff ff       	call   8010d9 <sys_page_unmap>
}
  801c0c:	83 c4 14             	add    $0x14,%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	57                   	push   %edi
  801c16:	56                   	push   %esi
  801c17:	53                   	push   %ebx
  801c18:	83 ec 2c             	sub    $0x2c,%esp
  801c1b:	89 c7                	mov    %eax,%edi
  801c1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c20:	a1 04 40 80 00       	mov    0x804004,%eax
  801c25:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c28:	89 3c 24             	mov    %edi,(%esp)
  801c2b:	e8 fc 05 00 00       	call   80222c <pageref>
  801c30:	89 c6                	mov    %eax,%esi
  801c32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 ef 05 00 00       	call   80222c <pageref>
  801c3d:	39 c6                	cmp    %eax,%esi
  801c3f:	0f 94 c0             	sete   %al
  801c42:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c45:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c4b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c4e:	39 cb                	cmp    %ecx,%ebx
  801c50:	75 08                	jne    801c5a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c52:	83 c4 2c             	add    $0x2c,%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5f                   	pop    %edi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c5a:	83 f8 01             	cmp    $0x1,%eax
  801c5d:	75 c1                	jne    801c20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c5f:	8b 52 58             	mov    0x58(%edx),%edx
  801c62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c66:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c6e:	c7 04 24 f6 29 80 00 	movl   $0x8029f6,(%esp)
  801c75:	e8 4d e7 ff ff       	call   8003c7 <cprintf>
  801c7a:	eb a4                	jmp    801c20 <_pipeisclosed+0xe>

00801c7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	57                   	push   %edi
  801c80:	56                   	push   %esi
  801c81:	53                   	push   %ebx
  801c82:	83 ec 2c             	sub    $0x2c,%esp
  801c85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c88:	89 34 24             	mov    %esi,(%esp)
  801c8b:	e8 a0 f6 ff ff       	call   801330 <fd2data>
  801c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c92:	bf 00 00 00 00       	mov    $0x0,%edi
  801c97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9b:	75 50                	jne    801ced <devpipe_write+0x71>
  801c9d:	eb 5c                	jmp    801cfb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c9f:	89 da                	mov    %ebx,%edx
  801ca1:	89 f0                	mov    %esi,%eax
  801ca3:	e8 6a ff ff ff       	call   801c12 <_pipeisclosed>
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	75 53                	jne    801cff <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cac:	e8 3b f3 ff ff       	call   800fec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cb1:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb4:	8b 13                	mov    (%ebx),%edx
  801cb6:	83 c2 20             	add    $0x20,%edx
  801cb9:	39 d0                	cmp    %edx,%eax
  801cbb:	73 e2                	jae    801c9f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801cc4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801cc7:	89 c2                	mov    %eax,%edx
  801cc9:	c1 fa 1f             	sar    $0x1f,%edx
  801ccc:	c1 ea 1b             	shr    $0x1b,%edx
  801ccf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801cd2:	83 e1 1f             	and    $0x1f,%ecx
  801cd5:	29 d1                	sub    %edx,%ecx
  801cd7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801cdb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801cdf:	83 c0 01             	add    $0x1,%eax
  801ce2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce5:	83 c7 01             	add    $0x1,%edi
  801ce8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ceb:	74 0e                	je     801cfb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ced:	8b 43 04             	mov    0x4(%ebx),%eax
  801cf0:	8b 13                	mov    (%ebx),%edx
  801cf2:	83 c2 20             	add    $0x20,%edx
  801cf5:	39 d0                	cmp    %edx,%eax
  801cf7:	73 a6                	jae    801c9f <devpipe_write+0x23>
  801cf9:	eb c2                	jmp    801cbd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cfb:	89 f8                	mov    %edi,%eax
  801cfd:	eb 05                	jmp    801d04 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d04:	83 c4 2c             	add    $0x2c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	83 ec 28             	sub    $0x28,%esp
  801d12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801d15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d18:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d1b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d1e:	89 3c 24             	mov    %edi,(%esp)
  801d21:	e8 0a f6 ff ff       	call   801330 <fd2data>
  801d26:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d28:	be 00 00 00 00       	mov    $0x0,%esi
  801d2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d31:	75 47                	jne    801d7a <devpipe_read+0x6e>
  801d33:	eb 52                	jmp    801d87 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d35:	89 f0                	mov    %esi,%eax
  801d37:	eb 5e                	jmp    801d97 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d39:	89 da                	mov    %ebx,%edx
  801d3b:	89 f8                	mov    %edi,%eax
  801d3d:	8d 76 00             	lea    0x0(%esi),%esi
  801d40:	e8 cd fe ff ff       	call   801c12 <_pipeisclosed>
  801d45:	85 c0                	test   %eax,%eax
  801d47:	75 49                	jne    801d92 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801d49:	e8 9e f2 ff ff       	call   800fec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d4e:	8b 03                	mov    (%ebx),%eax
  801d50:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d53:	74 e4                	je     801d39 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d55:	89 c2                	mov    %eax,%edx
  801d57:	c1 fa 1f             	sar    $0x1f,%edx
  801d5a:	c1 ea 1b             	shr    $0x1b,%edx
  801d5d:	01 d0                	add    %edx,%eax
  801d5f:	83 e0 1f             	and    $0x1f,%eax
  801d62:	29 d0                	sub    %edx,%eax
  801d64:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d6f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d72:	83 c6 01             	add    $0x1,%esi
  801d75:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d78:	74 0d                	je     801d87 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801d7a:	8b 03                	mov    (%ebx),%eax
  801d7c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d7f:	75 d4                	jne    801d55 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d81:	85 f6                	test   %esi,%esi
  801d83:	75 b0                	jne    801d35 <devpipe_read+0x29>
  801d85:	eb b2                	jmp    801d39 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d87:	89 f0                	mov    %esi,%eax
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	eb 05                	jmp    801d97 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801da0:	89 ec                	mov    %ebp,%esp
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 48             	sub    $0x48,%esp
  801daa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801dad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801db0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801db3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801db6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801db9:	89 04 24             	mov    %eax,(%esp)
  801dbc:	e8 8a f5 ff ff       	call   80134b <fd_alloc>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	0f 88 45 01 00 00    	js     801f10 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd2:	00 
  801dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de1:	e8 36 f2 ff ff       	call   80101c <sys_page_alloc>
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	85 c0                	test   %eax,%eax
  801dea:	0f 88 20 01 00 00    	js     801f10 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801df0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801df3:	89 04 24             	mov    %eax,(%esp)
  801df6:	e8 50 f5 ff ff       	call   80134b <fd_alloc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	0f 88 f8 00 00 00    	js     801efd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e05:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e0c:	00 
  801e0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1b:	e8 fc f1 ff ff       	call   80101c <sys_page_alloc>
  801e20:	89 c3                	mov    %eax,%ebx
  801e22:	85 c0                	test   %eax,%eax
  801e24:	0f 88 d3 00 00 00    	js     801efd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e2d:	89 04 24             	mov    %eax,(%esp)
  801e30:	e8 fb f4 ff ff       	call   801330 <fd2data>
  801e35:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e37:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e3e:	00 
  801e3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4a:	e8 cd f1 ff ff       	call   80101c <sys_page_alloc>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	85 c0                	test   %eax,%eax
  801e53:	0f 88 91 00 00 00    	js     801eea <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5c:	89 04 24             	mov    %eax,(%esp)
  801e5f:	e8 cc f4 ff ff       	call   801330 <fd2data>
  801e64:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e6b:	00 
  801e6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e77:	00 
  801e78:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e83:	e8 f3 f1 ff ff       	call   80107b <sys_page_map>
  801e88:	89 c3                	mov    %eax,%ebx
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	78 4c                	js     801eda <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e8e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e97:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ea3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ea9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eb1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebb:	89 04 24             	mov    %eax,(%esp)
  801ebe:	e8 5d f4 ff ff       	call   801320 <fd2num>
  801ec3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ec5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 50 f4 ff ff       	call   801320 <fd2num>
  801ed0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed8:	eb 36                	jmp    801f10 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801eda:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ede:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee5:	e8 ef f1 ff ff       	call   8010d9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef8:	e8 dc f1 ff ff       	call   8010d9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0b:	e8 c9 f1 ff ff       	call   8010d9 <sys_page_unmap>
    err:
	return r;
}
  801f10:	89 d8                	mov    %ebx,%eax
  801f12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801f1b:	89 ec                	mov    %ebp,%esp
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2f:	89 04 24             	mov    %eax,(%esp)
  801f32:	e8 87 f4 ff ff       	call   8013be <fd_lookup>
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 15                	js     801f50 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3e:	89 04 24             	mov    %eax,(%esp)
  801f41:	e8 ea f3 ff ff       	call   801330 <fd2data>
	return _pipeisclosed(fd, p);
  801f46:	89 c2                	mov    %eax,%edx
  801f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4b:	e8 c2 fc ff ff       	call   801c12 <_pipeisclosed>
}
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    
	...

00801f60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f70:	c7 44 24 04 0e 2a 80 	movl   $0x802a0e,0x4(%esp)
  801f77:	00 
  801f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7b:	89 04 24             	mov    %eax,(%esp)
  801f7e:	e8 98 eb ff ff       	call   800b1b <strcpy>
	return 0;
}
  801f83:	b8 00 00 00 00       	mov    $0x0,%eax
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	57                   	push   %edi
  801f8e:	56                   	push   %esi
  801f8f:	53                   	push   %ebx
  801f90:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f96:	be 00 00 00 00       	mov    $0x0,%esi
  801f9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f9f:	74 43                	je     801fe4 <devcons_write+0x5a>
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fa6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801faf:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801fb1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fb4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fb9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fbc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fc0:	03 45 0c             	add    0xc(%ebp),%eax
  801fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc7:	89 3c 24             	mov    %edi,(%esp)
  801fca:	e8 3d ed ff ff       	call   800d0c <memmove>
		sys_cputs(buf, m);
  801fcf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fd3:	89 3c 24             	mov    %edi,(%esp)
  801fd6:	e8 25 ef ff ff       	call   800f00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fdb:	01 de                	add    %ebx,%esi
  801fdd:	89 f0                	mov    %esi,%eax
  801fdf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fe2:	72 c8                	jb     801fac <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fe4:	89 f0                	mov    %esi,%eax
  801fe6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fec:	5b                   	pop    %ebx
  801fed:	5e                   	pop    %esi
  801fee:	5f                   	pop    %edi
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    

00801ff1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ffc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802000:	75 07                	jne    802009 <devcons_read+0x18>
  802002:	eb 31                	jmp    802035 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802004:	e8 e3 ef ff ff       	call   800fec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	e8 1a ef ff ff       	call   800f2f <sys_cgetc>
  802015:	85 c0                	test   %eax,%eax
  802017:	74 eb                	je     802004 <devcons_read+0x13>
  802019:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 16                	js     802035 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80201f:	83 f8 04             	cmp    $0x4,%eax
  802022:	74 0c                	je     802030 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802024:	8b 45 0c             	mov    0xc(%ebp),%eax
  802027:	88 10                	mov    %dl,(%eax)
	return 1;
  802029:	b8 01 00 00 00       	mov    $0x1,%eax
  80202e:	eb 05                	jmp    802035 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802030:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802035:	c9                   	leave  
  802036:	c3                   	ret    

00802037 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80203d:	8b 45 08             	mov    0x8(%ebp),%eax
  802040:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802043:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80204a:	00 
  80204b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204e:	89 04 24             	mov    %eax,(%esp)
  802051:	e8 aa ee ff ff       	call   800f00 <sys_cputs>
}
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <getchar>:

int
getchar(void)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80205e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802065:	00 
  802066:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802074:	e8 05 f6 ff ff       	call   80167e <read>
	if (r < 0)
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 0f                	js     80208c <getchar+0x34>
		return r;
	if (r < 1)
  80207d:	85 c0                	test   %eax,%eax
  80207f:	7e 06                	jle    802087 <getchar+0x2f>
		return -E_EOF;
	return c;
  802081:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802085:	eb 05                	jmp    80208c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802087:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802094:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	89 04 24             	mov    %eax,(%esp)
  8020a1:	e8 18 f3 ff ff       	call   8013be <fd_lookup>
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 11                	js     8020bb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ad:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020b3:	39 10                	cmp    %edx,(%eax)
  8020b5:	0f 94 c0             	sete   %al
  8020b8:	0f b6 c0             	movzbl %al,%eax
}
  8020bb:	c9                   	leave  
  8020bc:	c3                   	ret    

008020bd <opencons>:

int
opencons(void)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c6:	89 04 24             	mov    %eax,(%esp)
  8020c9:	e8 7d f2 ff ff       	call   80134b <fd_alloc>
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	78 3c                	js     80210e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020d9:	00 
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e8:	e8 2f ef ff ff       	call   80101c <sys_page_alloc>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 1d                	js     80210e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020f1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802106:	89 04 24             	mov    %eax,(%esp)
  802109:	e8 12 f2 ff ff       	call   801320 <fd2num>
}
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	56                   	push   %esi
  802114:	53                   	push   %ebx
  802115:	83 ec 10             	sub    $0x10,%esp
  802118:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80211b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802121:	85 db                	test   %ebx,%ebx
  802123:	74 06                	je     80212b <ipc_recv+0x1b>
  802125:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80212b:	85 f6                	test   %esi,%esi
  80212d:	74 06                	je     802135 <ipc_recv+0x25>
  80212f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802135:	85 c0                	test   %eax,%eax
  802137:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80213c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80213f:	89 04 24             	mov    %eax,(%esp)
  802142:	e8 3e f1 ff ff       	call   801285 <sys_ipc_recv>
    if (ret) return ret;
  802147:	85 c0                	test   %eax,%eax
  802149:	75 24                	jne    80216f <ipc_recv+0x5f>
    if (from_env_store)
  80214b:	85 db                	test   %ebx,%ebx
  80214d:	74 0a                	je     802159 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80214f:	a1 04 40 80 00       	mov    0x804004,%eax
  802154:	8b 40 74             	mov    0x74(%eax),%eax
  802157:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802159:	85 f6                	test   %esi,%esi
  80215b:	74 0a                	je     802167 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80215d:	a1 04 40 80 00       	mov    0x804004,%eax
  802162:	8b 40 78             	mov    0x78(%eax),%eax
  802165:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802167:	a1 04 40 80 00       	mov    0x804004,%eax
  80216c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80216f:	83 c4 10             	add    $0x10,%esp
  802172:	5b                   	pop    %ebx
  802173:	5e                   	pop    %esi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    

00802176 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	57                   	push   %edi
  80217a:	56                   	push   %esi
  80217b:	53                   	push   %ebx
  80217c:	83 ec 1c             	sub    $0x1c,%esp
  80217f:	8b 75 08             	mov    0x8(%ebp),%esi
  802182:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802185:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802188:	85 db                	test   %ebx,%ebx
  80218a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80218f:	0f 44 d8             	cmove  %eax,%ebx
  802192:	eb 2a                	jmp    8021be <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802194:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802197:	74 20                	je     8021b9 <ipc_send+0x43>
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	c7 44 24 08 1a 2a 80 	movl   $0x802a1a,0x8(%esp)
  8021a4:	00 
  8021a5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8021ac:	00 
  8021ad:	c7 04 24 31 2a 80 00 	movl   $0x802a31,(%esp)
  8021b4:	e8 13 e1 ff ff       	call   8002cc <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8021b9:	e8 2e ee ff ff       	call   800fec <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8021be:	8b 45 14             	mov    0x14(%ebp),%eax
  8021c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021cd:	89 34 24             	mov    %esi,(%esp)
  8021d0:	e8 7c f0 ff ff       	call   801251 <sys_ipc_try_send>
  8021d5:	85 c0                	test   %eax,%eax
  8021d7:	75 bb                	jne    802194 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8021d9:	83 c4 1c             	add    $0x1c,%esp
  8021dc:	5b                   	pop    %ebx
  8021dd:	5e                   	pop    %esi
  8021de:	5f                   	pop    %edi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8021e7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8021ec:	39 c8                	cmp    %ecx,%eax
  8021ee:	74 19                	je     802209 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021f0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8021f5:	89 c2                	mov    %eax,%edx
  8021f7:	c1 e2 07             	shl    $0x7,%edx
  8021fa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802200:	8b 52 50             	mov    0x50(%edx),%edx
  802203:	39 ca                	cmp    %ecx,%edx
  802205:	75 14                	jne    80221b <ipc_find_env+0x3a>
  802207:	eb 05                	jmp    80220e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802209:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80220e:	c1 e0 07             	shl    $0x7,%eax
  802211:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802216:	8b 40 40             	mov    0x40(%eax),%eax
  802219:	eb 0e                	jmp    802229 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80221b:	83 c0 01             	add    $0x1,%eax
  80221e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802223:	75 d0                	jne    8021f5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802225:	66 b8 00 00          	mov    $0x0,%ax
}
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    
	...

0080222c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802232:	89 d0                	mov    %edx,%eax
  802234:	c1 e8 16             	shr    $0x16,%eax
  802237:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80223e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802243:	f6 c1 01             	test   $0x1,%cl
  802246:	74 1d                	je     802265 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802248:	c1 ea 0c             	shr    $0xc,%edx
  80224b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802252:	f6 c2 01             	test   $0x1,%dl
  802255:	74 0e                	je     802265 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802257:	c1 ea 0c             	shr    $0xc,%edx
  80225a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802261:	ef 
  802262:	0f b7 c0             	movzwl %ax,%eax
}
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    
	...

00802270 <__udivdi3>:
  802270:	83 ec 1c             	sub    $0x1c,%esp
  802273:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802277:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80227b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80227f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802283:	89 74 24 10          	mov    %esi,0x10(%esp)
  802287:	8b 74 24 24          	mov    0x24(%esp),%esi
  80228b:	85 ff                	test   %edi,%edi
  80228d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802291:	89 44 24 08          	mov    %eax,0x8(%esp)
  802295:	89 cd                	mov    %ecx,%ebp
  802297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229b:	75 33                	jne    8022d0 <__udivdi3+0x60>
  80229d:	39 f1                	cmp    %esi,%ecx
  80229f:	77 57                	ja     8022f8 <__udivdi3+0x88>
  8022a1:	85 c9                	test   %ecx,%ecx
  8022a3:	75 0b                	jne    8022b0 <__udivdi3+0x40>
  8022a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8022aa:	31 d2                	xor    %edx,%edx
  8022ac:	f7 f1                	div    %ecx
  8022ae:	89 c1                	mov    %eax,%ecx
  8022b0:	89 f0                	mov    %esi,%eax
  8022b2:	31 d2                	xor    %edx,%edx
  8022b4:	f7 f1                	div    %ecx
  8022b6:	89 c6                	mov    %eax,%esi
  8022b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022bc:	f7 f1                	div    %ecx
  8022be:	89 f2                	mov    %esi,%edx
  8022c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	c3                   	ret    
  8022d0:	31 d2                	xor    %edx,%edx
  8022d2:	31 c0                	xor    %eax,%eax
  8022d4:	39 f7                	cmp    %esi,%edi
  8022d6:	77 e8                	ja     8022c0 <__udivdi3+0x50>
  8022d8:	0f bd cf             	bsr    %edi,%ecx
  8022db:	83 f1 1f             	xor    $0x1f,%ecx
  8022de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022e2:	75 2c                	jne    802310 <__udivdi3+0xa0>
  8022e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8022e8:	76 04                	jbe    8022ee <__udivdi3+0x7e>
  8022ea:	39 f7                	cmp    %esi,%edi
  8022ec:	73 d2                	jae    8022c0 <__udivdi3+0x50>
  8022ee:	31 d2                	xor    %edx,%edx
  8022f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f5:	eb c9                	jmp    8022c0 <__udivdi3+0x50>
  8022f7:	90                   	nop
  8022f8:	89 f2                	mov    %esi,%edx
  8022fa:	f7 f1                	div    %ecx
  8022fc:	31 d2                	xor    %edx,%edx
  8022fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  802302:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802306:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	c3                   	ret    
  80230e:	66 90                	xchg   %ax,%ax
  802310:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802315:	b8 20 00 00 00       	mov    $0x20,%eax
  80231a:	89 ea                	mov    %ebp,%edx
  80231c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802320:	d3 e7                	shl    %cl,%edi
  802322:	89 c1                	mov    %eax,%ecx
  802324:	d3 ea                	shr    %cl,%edx
  802326:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80232b:	09 fa                	or     %edi,%edx
  80232d:	89 f7                	mov    %esi,%edi
  80232f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802333:	89 f2                	mov    %esi,%edx
  802335:	8b 74 24 08          	mov    0x8(%esp),%esi
  802339:	d3 e5                	shl    %cl,%ebp
  80233b:	89 c1                	mov    %eax,%ecx
  80233d:	d3 ef                	shr    %cl,%edi
  80233f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802344:	d3 e2                	shl    %cl,%edx
  802346:	89 c1                	mov    %eax,%ecx
  802348:	d3 ee                	shr    %cl,%esi
  80234a:	09 d6                	or     %edx,%esi
  80234c:	89 fa                	mov    %edi,%edx
  80234e:	89 f0                	mov    %esi,%eax
  802350:	f7 74 24 0c          	divl   0xc(%esp)
  802354:	89 d7                	mov    %edx,%edi
  802356:	89 c6                	mov    %eax,%esi
  802358:	f7 e5                	mul    %ebp
  80235a:	39 d7                	cmp    %edx,%edi
  80235c:	72 22                	jb     802380 <__udivdi3+0x110>
  80235e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802362:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802367:	d3 e5                	shl    %cl,%ebp
  802369:	39 c5                	cmp    %eax,%ebp
  80236b:	73 04                	jae    802371 <__udivdi3+0x101>
  80236d:	39 d7                	cmp    %edx,%edi
  80236f:	74 0f                	je     802380 <__udivdi3+0x110>
  802371:	89 f0                	mov    %esi,%eax
  802373:	31 d2                	xor    %edx,%edx
  802375:	e9 46 ff ff ff       	jmp    8022c0 <__udivdi3+0x50>
  80237a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802380:	8d 46 ff             	lea    -0x1(%esi),%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	8b 74 24 10          	mov    0x10(%esp),%esi
  802389:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80238d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802391:	83 c4 1c             	add    $0x1c,%esp
  802394:	c3                   	ret    
	...

008023a0 <__umoddi3>:
  8023a0:	83 ec 1c             	sub    $0x1c,%esp
  8023a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8023a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8023ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8023af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8023b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8023b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8023bb:	85 ed                	test   %ebp,%ebp
  8023bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8023c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c5:	89 cf                	mov    %ecx,%edi
  8023c7:	89 04 24             	mov    %eax,(%esp)
  8023ca:	89 f2                	mov    %esi,%edx
  8023cc:	75 1a                	jne    8023e8 <__umoddi3+0x48>
  8023ce:	39 f1                	cmp    %esi,%ecx
  8023d0:	76 4e                	jbe    802420 <__umoddi3+0x80>
  8023d2:	f7 f1                	div    %ecx
  8023d4:	89 d0                	mov    %edx,%eax
  8023d6:	31 d2                	xor    %edx,%edx
  8023d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8023e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8023e4:	83 c4 1c             	add    $0x1c,%esp
  8023e7:	c3                   	ret    
  8023e8:	39 f5                	cmp    %esi,%ebp
  8023ea:	77 54                	ja     802440 <__umoddi3+0xa0>
  8023ec:	0f bd c5             	bsr    %ebp,%eax
  8023ef:	83 f0 1f             	xor    $0x1f,%eax
  8023f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f6:	75 60                	jne    802458 <__umoddi3+0xb8>
  8023f8:	3b 0c 24             	cmp    (%esp),%ecx
  8023fb:	0f 87 07 01 00 00    	ja     802508 <__umoddi3+0x168>
  802401:	89 f2                	mov    %esi,%edx
  802403:	8b 34 24             	mov    (%esp),%esi
  802406:	29 ce                	sub    %ecx,%esi
  802408:	19 ea                	sbb    %ebp,%edx
  80240a:	89 34 24             	mov    %esi,(%esp)
  80240d:	8b 04 24             	mov    (%esp),%eax
  802410:	8b 74 24 10          	mov    0x10(%esp),%esi
  802414:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802418:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80241c:	83 c4 1c             	add    $0x1c,%esp
  80241f:	c3                   	ret    
  802420:	85 c9                	test   %ecx,%ecx
  802422:	75 0b                	jne    80242f <__umoddi3+0x8f>
  802424:	b8 01 00 00 00       	mov    $0x1,%eax
  802429:	31 d2                	xor    %edx,%edx
  80242b:	f7 f1                	div    %ecx
  80242d:	89 c1                	mov    %eax,%ecx
  80242f:	89 f0                	mov    %esi,%eax
  802431:	31 d2                	xor    %edx,%edx
  802433:	f7 f1                	div    %ecx
  802435:	8b 04 24             	mov    (%esp),%eax
  802438:	f7 f1                	div    %ecx
  80243a:	eb 98                	jmp    8023d4 <__umoddi3+0x34>
  80243c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802440:	89 f2                	mov    %esi,%edx
  802442:	8b 74 24 10          	mov    0x10(%esp),%esi
  802446:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80244a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80244e:	83 c4 1c             	add    $0x1c,%esp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80245d:	89 e8                	mov    %ebp,%eax
  80245f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802464:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802468:	89 fa                	mov    %edi,%edx
  80246a:	d3 e0                	shl    %cl,%eax
  80246c:	89 e9                	mov    %ebp,%ecx
  80246e:	d3 ea                	shr    %cl,%edx
  802470:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802475:	09 c2                	or     %eax,%edx
  802477:	8b 44 24 08          	mov    0x8(%esp),%eax
  80247b:	89 14 24             	mov    %edx,(%esp)
  80247e:	89 f2                	mov    %esi,%edx
  802480:	d3 e7                	shl    %cl,%edi
  802482:	89 e9                	mov    %ebp,%ecx
  802484:	d3 ea                	shr    %cl,%edx
  802486:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80248b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80248f:	d3 e6                	shl    %cl,%esi
  802491:	89 e9                	mov    %ebp,%ecx
  802493:	d3 e8                	shr    %cl,%eax
  802495:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80249a:	09 f0                	or     %esi,%eax
  80249c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024a0:	f7 34 24             	divl   (%esp)
  8024a3:	d3 e6                	shl    %cl,%esi
  8024a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8024a9:	89 d6                	mov    %edx,%esi
  8024ab:	f7 e7                	mul    %edi
  8024ad:	39 d6                	cmp    %edx,%esi
  8024af:	89 c1                	mov    %eax,%ecx
  8024b1:	89 d7                	mov    %edx,%edi
  8024b3:	72 3f                	jb     8024f4 <__umoddi3+0x154>
  8024b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024b9:	72 35                	jb     8024f0 <__umoddi3+0x150>
  8024bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024bf:	29 c8                	sub    %ecx,%eax
  8024c1:	19 fe                	sbb    %edi,%esi
  8024c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024c8:	89 f2                	mov    %esi,%edx
  8024ca:	d3 e8                	shr    %cl,%eax
  8024cc:	89 e9                	mov    %ebp,%ecx
  8024ce:	d3 e2                	shl    %cl,%edx
  8024d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024d5:	09 d0                	or     %edx,%eax
  8024d7:	89 f2                	mov    %esi,%edx
  8024d9:	d3 ea                	shr    %cl,%edx
  8024db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8024df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8024e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8024e7:	83 c4 1c             	add    $0x1c,%esp
  8024ea:	c3                   	ret    
  8024eb:	90                   	nop
  8024ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	39 d6                	cmp    %edx,%esi
  8024f2:	75 c7                	jne    8024bb <__umoddi3+0x11b>
  8024f4:	89 d7                	mov    %edx,%edi
  8024f6:	89 c1                	mov    %eax,%ecx
  8024f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8024fc:	1b 3c 24             	sbb    (%esp),%edi
  8024ff:	eb ba                	jmp    8024bb <__umoddi3+0x11b>
  802501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802508:	39 f5                	cmp    %esi,%ebp
  80250a:	0f 82 f1 fe ff ff    	jb     802401 <__umoddi3+0x61>
  802510:	e9 f8 fe ff ff       	jmp    80240d <__umoddi3+0x6d>
