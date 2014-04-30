
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
  800051:	e8 b6 0f 00 00       	call   80100c <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 60 15 80 	movl   $0x801560,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  800075:	e8 4a 02 00 00       	call   8002c4 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 cd 0f 00 00       	call   80106b <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 83 15 80 	movl   $0x801583,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  8000bd:	e8 02 02 00 00       	call   8002c4 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 22 0c 00 00       	call   800cfc <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 db 0f 00 00       	call   8010c9 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 94 15 80 	movl   $0x801594,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  80010d:	e8 b2 01 00 00       	call   8002c4 <_panic>
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
  800132:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  800139:	e8 81 02 00 00       	call   8003bf <cprintf>
	if (envid < 0) {
  80013e:	85 f6                	test   %esi,%esi
  800140:	79 20                	jns    800162 <dumbfork+0x49>
		panic("sys_exofork: %e", envid);
  800142:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800146:	c7 44 24 08 bd 15 80 	movl   $0x8015bd,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  80015d:	e8 62 01 00 00       	call   8002c4 <_panic>
	}
	if (envid == 0) {
  800162:	85 f6                	test   %esi,%esi
  800164:	75 19                	jne    80017f <dumbfork+0x66>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800166:	e8 41 0e 00 00       	call   800fac <sys_getenvid>
  80016b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800170:	c1 e0 07             	shl    $0x7,%eax
  800173:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800178:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  80017d:	eb 7e                	jmp    8001fd <dumbfork+0xe4>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800186:	b8 0c 20 80 00       	mov    $0x80200c,%eax
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
  8001ae:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
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
  8001d4:	e8 4e 0f 00 00       	call   801127 <sys_env_set_status>
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	79 20                	jns    8001fd <dumbfork+0xe4>
		panic("sys_env_set_status: %e", r);
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	c7 44 24 08 cd 15 80 	movl   $0x8015cd,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  8001f8:	e8 c7 00 00 00       	call   8002c4 <_panic>
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
  80021b:	bf eb 15 80 00       	mov    $0x8015eb,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800220:	eb 26                	jmp    800248 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800222:	85 db                	test   %ebx,%ebx
  800224:	b8 e4 15 80 00       	mov    $0x8015e4,%eax
  800229:	0f 44 c7             	cmove  %edi,%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	89 74 24 04          	mov    %esi,0x4(%esp)
  800234:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  80023b:	e8 7f 01 00 00       	call   8003bf <cprintf>
		sys_yield();
  800240:	e8 97 0d 00 00       	call   800fdc <sys_yield>

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
  800272:	e8 35 0d 00 00       	call   800fac <sys_getenvid>
  800277:	25 ff 03 00 00       	and    $0x3ff,%eax
  80027c:	c1 e0 07             	shl    $0x7,%eax
  80027f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800284:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800289:	85 f6                	test   %esi,%esi
  80028b:	7e 07                	jle    800294 <libmain+0x34>
		binaryname = argv[0];
  80028d:	8b 03                	mov    (%ebx),%eax
  80028f:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8002b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002bd:	e8 8d 0c 00 00       	call   800f4f <sys_env_destroy>
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002d5:	e8 d2 0c 00 00       	call   800fac <sys_getenvid>
  8002da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f0:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  8002f7:	e8 c3 00 00 00       	call   8003bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	e8 53 00 00 00       	call   80035e <vcprintf>
	cprintf("\n");
  80030b:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800312:	e8 a8 00 00 00       	call   8003bf <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800317:	cc                   	int3   
  800318:	eb fd                	jmp    800317 <_panic+0x53>
	...

0080031c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	53                   	push   %ebx
  800320:	83 ec 14             	sub    $0x14,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800326:	8b 03                	mov    (%ebx),%eax
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80032f:	83 c0 01             	add    $0x1,%eax
  800332:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800334:	3d ff 00 00 00       	cmp    $0xff,%eax
  800339:	75 19                	jne    800354 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80033b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800342:	00 
  800343:	8d 43 08             	lea    0x8(%ebx),%eax
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	e8 a2 0b 00 00       	call   800ef0 <sys_cputs>
		b->idx = 0;
  80034e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800354:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800358:	83 c4 14             	add    $0x14,%esp
  80035b:	5b                   	pop    %ebx
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800367:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036e:	00 00 00 
	b.cnt = 0;
  800371:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800378:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800382:	8b 45 08             	mov    0x8(%ebp),%eax
  800385:	89 44 24 08          	mov    %eax,0x8(%esp)
  800389:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800393:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  80039a:	e8 97 01 00 00       	call   800536 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 39 0b 00 00       	call   800ef0 <sys_cputs>

	return b.cnt;
}
  8003b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003bd:	c9                   	leave  
  8003be:	c3                   	ret    

008003bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 87 ff ff ff       	call   80035e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d7:	c9                   	leave  
  8003d8:	c3                   	ret    
  8003d9:	00 00                	add    %al,(%eax)
	...

008003dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 3c             	sub    $0x3c,%esp
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	89 d7                	mov    %edx,%edi
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800401:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800404:	72 11                	jb     800417 <printnum+0x3b>
  800406:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800409:	39 45 10             	cmp    %eax,0x10(%ebp)
  80040c:	76 09                	jbe    800417 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040e:	83 eb 01             	sub    $0x1,%ebx
  800411:	85 db                	test   %ebx,%ebx
  800413:	7f 51                	jg     800466 <printnum+0x8a>
  800415:	eb 5e                	jmp    800475 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800417:	89 74 24 10          	mov    %esi,0x10(%esp)
  80041b:	83 eb 01             	sub    $0x1,%ebx
  80041e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800422:	8b 45 10             	mov    0x10(%ebp),%eax
  800425:	89 44 24 08          	mov    %eax,0x8(%esp)
  800429:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80042d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800431:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800438:	00 
  800439:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80043c:	89 04 24             	mov    %eax,(%esp)
  80043f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800442:	89 44 24 04          	mov    %eax,0x4(%esp)
  800446:	e8 65 0e 00 00       	call   8012b0 <__udivdi3>
  80044b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80044f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045a:	89 fa                	mov    %edi,%edx
  80045c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045f:	e8 78 ff ff ff       	call   8003dc <printnum>
  800464:	eb 0f                	jmp    800475 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046a:	89 34 24             	mov    %esi,(%esp)
  80046d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800470:	83 eb 01             	sub    $0x1,%ebx
  800473:	75 f1                	jne    800466 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800475:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800479:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80047d:	8b 45 10             	mov    0x10(%ebp),%eax
  800480:	89 44 24 08          	mov    %eax,0x8(%esp)
  800484:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048b:	00 
  80048c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	e8 42 0f 00 00       	call   8013e0 <__umoddi3>
  80049e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a2:	0f be 80 34 16 80 00 	movsbl 0x801634(%eax),%eax
  8004a9:	89 04 24             	mov    %eax,(%esp)
  8004ac:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004af:	83 c4 3c             	add    $0x3c,%esp
  8004b2:	5b                   	pop    %ebx
  8004b3:	5e                   	pop    %esi
  8004b4:	5f                   	pop    %edi
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ba:	83 fa 01             	cmp    $0x1,%edx
  8004bd:	7e 0e                	jle    8004cd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004bf:	8b 10                	mov    (%eax),%edx
  8004c1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c4:	89 08                	mov    %ecx,(%eax)
  8004c6:	8b 02                	mov    (%edx),%eax
  8004c8:	8b 52 04             	mov    0x4(%edx),%edx
  8004cb:	eb 22                	jmp    8004ef <getuint+0x38>
	else if (lflag)
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	74 10                	je     8004e1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	eb 0e                	jmp    8004ef <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 02                	mov    (%edx),%eax
  8004ea:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fb:	8b 10                	mov    (%eax),%edx
  8004fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800500:	73 0a                	jae    80050c <sprintputch+0x1b>
		*b->buf++ = ch;
  800502:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800505:	88 0a                	mov    %cl,(%edx)
  800507:	83 c2 01             	add    $0x1,%edx
  80050a:	89 10                	mov    %edx,(%eax)
}
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800514:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800517:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051b:	8b 45 10             	mov    0x10(%ebp),%eax
  80051e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800522:	8b 45 0c             	mov    0xc(%ebp),%eax
  800525:	89 44 24 04          	mov    %eax,0x4(%esp)
  800529:	8b 45 08             	mov    0x8(%ebp),%eax
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	e8 02 00 00 00       	call   800536 <vprintfmt>
	va_end(ap);
}
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 5c             	sub    $0x5c,%esp
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800542:	8b 75 10             	mov    0x10(%ebp),%esi
  800545:	eb 12                	jmp    800559 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800547:	85 c0                	test   %eax,%eax
  800549:	0f 84 e4 04 00 00    	je     800a33 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80054f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800559:	0f b6 06             	movzbl (%esi),%eax
  80055c:	83 c6 01             	add    $0x1,%esi
  80055f:	83 f8 25             	cmp    $0x25,%eax
  800562:	75 e3                	jne    800547 <vprintfmt+0x11>
  800564:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800568:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80056f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800574:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80057b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800580:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800583:	eb 2b                	jmp    8005b0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800588:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80058c:	eb 22                	jmp    8005b0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800591:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800595:	eb 19                	jmp    8005b0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80059a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005a1:	eb 0d                	jmp    8005b0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005a3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8005a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005a9:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	0f b6 06             	movzbl (%esi),%eax
  8005b3:	0f b6 d0             	movzbl %al,%edx
  8005b6:	8d 7e 01             	lea    0x1(%esi),%edi
  8005b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005bc:	83 e8 23             	sub    $0x23,%eax
  8005bf:	3c 55                	cmp    $0x55,%al
  8005c1:	0f 87 46 04 00 00    	ja     800a0d <vprintfmt+0x4d7>
  8005c7:	0f b6 c0             	movzbl %al,%eax
  8005ca:	ff 24 85 20 17 80 00 	jmp    *0x801720(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d1:	83 ea 30             	sub    $0x30,%edx
  8005d4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8005d7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005db:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8005e1:	83 fa 09             	cmp    $0x9,%edx
  8005e4:	77 4a                	ja     800630 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005ec:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005ef:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005f3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005f6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005f9:	83 fa 09             	cmp    $0x9,%edx
  8005fc:	76 eb                	jbe    8005e9 <vprintfmt+0xb3>
  8005fe:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800601:	eb 2d                	jmp    800630 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800614:	eb 1a                	jmp    800630 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800619:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80061d:	79 91                	jns    8005b0 <vprintfmt+0x7a>
  80061f:	e9 73 ff ff ff       	jmp    800597 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800627:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80062e:	eb 80                	jmp    8005b0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800630:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800634:	0f 89 76 ff ff ff    	jns    8005b0 <vprintfmt+0x7a>
  80063a:	e9 64 ff ff ff       	jmp    8005a3 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80063f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800645:	e9 66 ff ff ff       	jmp    8005b0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800662:	e9 f2 fe ff ff       	jmp    800559 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800667:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80066b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80066e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800672:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800675:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800679:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80067c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80067f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800683:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800686:	80 f9 09             	cmp    $0x9,%cl
  800689:	77 1d                	ja     8006a8 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80068b:	0f be c0             	movsbl %al,%eax
  80068e:	6b c0 64             	imul   $0x64,%eax,%eax
  800691:	0f be d2             	movsbl %dl,%edx
  800694:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800697:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80069e:	a3 04 20 80 00       	mov    %eax,0x802004
  8006a3:	e9 b1 fe ff ff       	jmp    800559 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8006a8:	c7 44 24 04 4c 16 80 	movl   $0x80164c,0x4(%esp)
  8006af:	00 
  8006b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006b3:	89 04 24             	mov    %eax,(%esp)
  8006b6:	e8 10 05 00 00       	call   800bcb <strcmp>
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	75 0f                	jne    8006ce <vprintfmt+0x198>
  8006bf:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8006c6:	00 00 00 
  8006c9:	e9 8b fe ff ff       	jmp    800559 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8006ce:	c7 44 24 04 50 16 80 	movl   $0x801650,0x4(%esp)
  8006d5:	00 
  8006d6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006d9:	89 14 24             	mov    %edx,(%esp)
  8006dc:	e8 ea 04 00 00       	call   800bcb <strcmp>
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	75 0f                	jne    8006f4 <vprintfmt+0x1be>
  8006e5:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8006ec:	00 00 00 
  8006ef:	e9 65 fe ff ff       	jmp    800559 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8006f4:	c7 44 24 04 54 16 80 	movl   $0x801654,0x4(%esp)
  8006fb:	00 
  8006fc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8006ff:	89 0c 24             	mov    %ecx,(%esp)
  800702:	e8 c4 04 00 00       	call   800bcb <strcmp>
  800707:	85 c0                	test   %eax,%eax
  800709:	75 0f                	jne    80071a <vprintfmt+0x1e4>
  80070b:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800712:	00 00 00 
  800715:	e9 3f fe ff ff       	jmp    800559 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80071a:	c7 44 24 04 58 16 80 	movl   $0x801658,0x4(%esp)
  800721:	00 
  800722:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800725:	89 3c 24             	mov    %edi,(%esp)
  800728:	e8 9e 04 00 00       	call   800bcb <strcmp>
  80072d:	85 c0                	test   %eax,%eax
  80072f:	75 0f                	jne    800740 <vprintfmt+0x20a>
  800731:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800738:	00 00 00 
  80073b:	e9 19 fe ff ff       	jmp    800559 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800740:	c7 44 24 04 5c 16 80 	movl   $0x80165c,0x4(%esp)
  800747:	00 
  800748:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	e8 78 04 00 00       	call   800bcb <strcmp>
  800753:	85 c0                	test   %eax,%eax
  800755:	75 0f                	jne    800766 <vprintfmt+0x230>
  800757:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80075e:	00 00 00 
  800761:	e9 f3 fd ff ff       	jmp    800559 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800766:	c7 44 24 04 60 16 80 	movl   $0x801660,0x4(%esp)
  80076d:	00 
  80076e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800771:	89 14 24             	mov    %edx,(%esp)
  800774:	e8 52 04 00 00       	call   800bcb <strcmp>
  800779:	83 f8 01             	cmp    $0x1,%eax
  80077c:	19 c0                	sbb    %eax,%eax
  80077e:	f7 d0                	not    %eax
  800780:	83 c0 08             	add    $0x8,%eax
  800783:	a3 04 20 80 00       	mov    %eax,0x802004
  800788:	e9 cc fd ff ff       	jmp    800559 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8d 50 04             	lea    0x4(%eax),%edx
  800793:	89 55 14             	mov    %edx,0x14(%ebp)
  800796:	8b 00                	mov    (%eax),%eax
  800798:	89 c2                	mov    %eax,%edx
  80079a:	c1 fa 1f             	sar    $0x1f,%edx
  80079d:	31 d0                	xor    %edx,%eax
  80079f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007a1:	83 f8 08             	cmp    $0x8,%eax
  8007a4:	7f 0b                	jg     8007b1 <vprintfmt+0x27b>
  8007a6:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	75 23                	jne    8007d4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8007b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b5:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  8007bc:	00 
  8007bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c4:	89 3c 24             	mov    %edi,(%esp)
  8007c7:	e8 42 fd ff ff       	call   80050e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007cf:	e9 85 fd ff ff       	jmp    800559 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d8:	c7 44 24 08 6d 16 80 	movl   $0x80166d,0x8(%esp)
  8007df:	00 
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e7:	89 3c 24             	mov    %edi,(%esp)
  8007ea:	e8 1f fd ff ff       	call   80050e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ef:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007f2:	e9 62 fd ff ff       	jmp    800559 <vprintfmt+0x23>
  8007f7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8007fa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007fd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80080b:	85 f6                	test   %esi,%esi
  80080d:	b8 45 16 80 00       	mov    $0x801645,%eax
  800812:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800815:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800819:	7e 06                	jle    800821 <vprintfmt+0x2eb>
  80081b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80081f:	75 13                	jne    800834 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800821:	0f be 06             	movsbl (%esi),%eax
  800824:	83 c6 01             	add    $0x1,%esi
  800827:	85 c0                	test   %eax,%eax
  800829:	0f 85 94 00 00 00    	jne    8008c3 <vprintfmt+0x38d>
  80082f:	e9 81 00 00 00       	jmp    8008b5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800834:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800838:	89 34 24             	mov    %esi,(%esp)
  80083b:	e8 9b 02 00 00       	call   800adb <strnlen>
  800840:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800843:	29 c2                	sub    %eax,%edx
  800845:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800848:	85 d2                	test   %edx,%edx
  80084a:	7e d5                	jle    800821 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80084c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800850:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800853:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800856:	89 d6                	mov    %edx,%esi
  800858:	89 cf                	mov    %ecx,%edi
  80085a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085e:	89 3c 24             	mov    %edi,(%esp)
  800861:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800864:	83 ee 01             	sub    $0x1,%esi
  800867:	75 f1                	jne    80085a <vprintfmt+0x324>
  800869:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80086c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80086f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800872:	eb ad                	jmp    800821 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800874:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800878:	74 1b                	je     800895 <vprintfmt+0x35f>
  80087a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80087d:	83 fa 5e             	cmp    $0x5e,%edx
  800880:	76 13                	jbe    800895 <vprintfmt+0x35f>
					putch('?', putdat);
  800882:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800890:	ff 55 08             	call   *0x8(%ebp)
  800893:	eb 0d                	jmp    8008a2 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800895:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800898:	89 54 24 04          	mov    %edx,0x4(%esp)
  80089c:	89 04 24             	mov    %eax,(%esp)
  80089f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a2:	83 eb 01             	sub    $0x1,%ebx
  8008a5:	0f be 06             	movsbl (%esi),%eax
  8008a8:	83 c6 01             	add    $0x1,%esi
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	75 1a                	jne    8008c9 <vprintfmt+0x393>
  8008af:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8008b2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008bc:	7f 1c                	jg     8008da <vprintfmt+0x3a4>
  8008be:	e9 96 fc ff ff       	jmp    800559 <vprintfmt+0x23>
  8008c3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008c6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c9:	85 ff                	test   %edi,%edi
  8008cb:	78 a7                	js     800874 <vprintfmt+0x33e>
  8008cd:	83 ef 01             	sub    $0x1,%edi
  8008d0:	79 a2                	jns    800874 <vprintfmt+0x33e>
  8008d2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8008d5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008d8:	eb db                	jmp    8008b5 <vprintfmt+0x37f>
  8008da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008dd:	89 de                	mov    %ebx,%esi
  8008df:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008ed:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008ef:	83 eb 01             	sub    $0x1,%ebx
  8008f2:	75 ee                	jne    8008e2 <vprintfmt+0x3ac>
  8008f4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008f9:	e9 5b fc ff ff       	jmp    800559 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008fe:	83 f9 01             	cmp    $0x1,%ecx
  800901:	7e 10                	jle    800913 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8d 50 08             	lea    0x8(%eax),%edx
  800909:	89 55 14             	mov    %edx,0x14(%ebp)
  80090c:	8b 30                	mov    (%eax),%esi
  80090e:	8b 78 04             	mov    0x4(%eax),%edi
  800911:	eb 26                	jmp    800939 <vprintfmt+0x403>
	else if (lflag)
  800913:	85 c9                	test   %ecx,%ecx
  800915:	74 12                	je     800929 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8d 50 04             	lea    0x4(%eax),%edx
  80091d:	89 55 14             	mov    %edx,0x14(%ebp)
  800920:	8b 30                	mov    (%eax),%esi
  800922:	89 f7                	mov    %esi,%edi
  800924:	c1 ff 1f             	sar    $0x1f,%edi
  800927:	eb 10                	jmp    800939 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8d 50 04             	lea    0x4(%eax),%edx
  80092f:	89 55 14             	mov    %edx,0x14(%ebp)
  800932:	8b 30                	mov    (%eax),%esi
  800934:	89 f7                	mov    %esi,%edi
  800936:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800939:	85 ff                	test   %edi,%edi
  80093b:	78 0e                	js     80094b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80093d:	89 f0                	mov    %esi,%eax
  80093f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800941:	be 0a 00 00 00       	mov    $0xa,%esi
  800946:	e9 84 00 00 00       	jmp    8009cf <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80094b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800956:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800959:	89 f0                	mov    %esi,%eax
  80095b:	89 fa                	mov    %edi,%edx
  80095d:	f7 d8                	neg    %eax
  80095f:	83 d2 00             	adc    $0x0,%edx
  800962:	f7 da                	neg    %edx
			}
			base = 10;
  800964:	be 0a 00 00 00       	mov    $0xa,%esi
  800969:	eb 64                	jmp    8009cf <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80096b:	89 ca                	mov    %ecx,%edx
  80096d:	8d 45 14             	lea    0x14(%ebp),%eax
  800970:	e8 42 fb ff ff       	call   8004b7 <getuint>
			base = 10;
  800975:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80097a:	eb 53                	jmp    8009cf <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80097c:	89 ca                	mov    %ecx,%edx
  80097e:	8d 45 14             	lea    0x14(%ebp),%eax
  800981:	e8 31 fb ff ff       	call   8004b7 <getuint>
    			base = 8;
  800986:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80098b:	eb 42                	jmp    8009cf <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80098d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800991:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800998:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80099b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009a6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ac:	8d 50 04             	lea    0x4(%eax),%edx
  8009af:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009b2:	8b 00                	mov    (%eax),%eax
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009b9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8009be:	eb 0f                	jmp    8009cf <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c0:	89 ca                	mov    %ecx,%edx
  8009c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c5:	e8 ed fa ff ff       	call   8004b7 <getuint>
			base = 16;
  8009ca:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009cf:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009d3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8009d7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009da:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8009de:	89 74 24 08          	mov    %esi,0x8(%esp)
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e9:	89 da                	mov    %ebx,%edx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	e8 e9 f9 ff ff       	call   8003dc <printnum>
			break;
  8009f3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009f6:	e9 5e fb ff ff       	jmp    800559 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ff:	89 14 24             	mov    %edx,(%esp)
  800a02:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a05:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a08:	e9 4c fb ff ff       	jmp    800559 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a11:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a18:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a1b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a1f:	0f 84 34 fb ff ff    	je     800559 <vprintfmt+0x23>
  800a25:	83 ee 01             	sub    $0x1,%esi
  800a28:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a2c:	75 f7                	jne    800a25 <vprintfmt+0x4ef>
  800a2e:	e9 26 fb ff ff       	jmp    800559 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a33:	83 c4 5c             	add    $0x5c,%esp
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	83 ec 28             	sub    $0x28,%esp
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a4a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a4e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	74 30                	je     800a8c <vsnprintf+0x51>
  800a5c:	85 d2                	test   %edx,%edx
  800a5e:	7e 2c                	jle    800a8c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a60:	8b 45 14             	mov    0x14(%ebp),%eax
  800a63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a67:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	c7 04 24 f1 04 80 00 	movl   $0x8004f1,(%esp)
  800a7c:	e8 b5 fa ff ff       	call   800536 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a84:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a8a:	eb 05                	jmp    800a91 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a99:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa0:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	89 04 24             	mov    %eax,(%esp)
  800ab4:	e8 82 ff ff ff       	call   800a3b <vsnprintf>
	va_end(ap);

	return rc;
}
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    
  800abb:	00 00                	add    %al,(%eax)
  800abd:	00 00                	add    %al,(%eax)
	...

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	80 3a 00             	cmpb   $0x0,(%edx)
  800ace:	74 09                	je     800ad9 <strlen+0x19>
		n++;
  800ad0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad7:	75 f7                	jne    800ad0 <strlen+0x10>
		n++;
	return n;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	85 c9                	test   %ecx,%ecx
  800aec:	74 1a                	je     800b08 <strnlen+0x2d>
  800aee:	80 3b 00             	cmpb   $0x0,(%ebx)
  800af1:	74 15                	je     800b08 <strnlen+0x2d>
  800af3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800af8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800afa:	39 ca                	cmp    %ecx,%edx
  800afc:	74 0a                	je     800b08 <strnlen+0x2d>
  800afe:	83 c2 01             	add    $0x1,%edx
  800b01:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b06:	75 f0                	jne    800af8 <strnlen+0x1d>
		n++;
	return n;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b1e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b21:	83 c2 01             	add    $0x1,%edx
  800b24:	84 c9                	test   %cl,%cl
  800b26:	75 f2                	jne    800b1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b28:	5b                   	pop    %ebx
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b35:	89 1c 24             	mov    %ebx,(%esp)
  800b38:	e8 83 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b40:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b44:	01 d8                	add    %ebx,%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 bd ff ff ff       	call   800b0b <strcpy>
	return dst;
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b64:	85 f6                	test   %esi,%esi
  800b66:	74 18                	je     800b80 <strncpy+0x2a>
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b6d:	0f b6 1a             	movzbl (%edx),%ebx
  800b70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b73:	80 3a 01             	cmpb   $0x1,(%edx)
  800b76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	39 f1                	cmp    %esi,%ecx
  800b7e:	75 ed                	jne    800b6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b90:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b93:	89 f8                	mov    %edi,%eax
  800b95:	85 f6                	test   %esi,%esi
  800b97:	74 2b                	je     800bc4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b99:	83 fe 01             	cmp    $0x1,%esi
  800b9c:	74 23                	je     800bc1 <strlcpy+0x3d>
  800b9e:	0f b6 0b             	movzbl (%ebx),%ecx
  800ba1:	84 c9                	test   %cl,%cl
  800ba3:	74 1c                	je     800bc1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ba5:	83 ee 02             	sub    $0x2,%esi
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bad:	88 08                	mov    %cl,(%eax)
  800baf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb2:	39 f2                	cmp    %esi,%edx
  800bb4:	74 0b                	je     800bc1 <strlcpy+0x3d>
  800bb6:	83 c2 01             	add    $0x1,%edx
  800bb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbd:	84 c9                	test   %cl,%cl
  800bbf:	75 ec                	jne    800bad <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800bc1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc4:	29 f8                	sub    %edi,%eax
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd4:	0f b6 01             	movzbl (%ecx),%eax
  800bd7:	84 c0                	test   %al,%al
  800bd9:	74 16                	je     800bf1 <strcmp+0x26>
  800bdb:	3a 02                	cmp    (%edx),%al
  800bdd:	75 12                	jne    800bf1 <strcmp+0x26>
		p++, q++;
  800bdf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800be6:	84 c0                	test   %al,%al
  800be8:	74 07                	je     800bf1 <strcmp+0x26>
  800bea:	83 c1 01             	add    $0x1,%ecx
  800bed:	3a 02                	cmp    (%edx),%al
  800bef:	74 ee                	je     800bdf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf1:	0f b6 c0             	movzbl %al,%eax
  800bf4:	0f b6 12             	movzbl (%edx),%edx
  800bf7:	29 d0                	sub    %edx,%eax
}
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	53                   	push   %ebx
  800bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c08:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c0d:	85 d2                	test   %edx,%edx
  800c0f:	74 28                	je     800c39 <strncmp+0x3e>
  800c11:	0f b6 01             	movzbl (%ecx),%eax
  800c14:	84 c0                	test   %al,%al
  800c16:	74 24                	je     800c3c <strncmp+0x41>
  800c18:	3a 03                	cmp    (%ebx),%al
  800c1a:	75 20                	jne    800c3c <strncmp+0x41>
  800c1c:	83 ea 01             	sub    $0x1,%edx
  800c1f:	74 13                	je     800c34 <strncmp+0x39>
		n--, p++, q++;
  800c21:	83 c1 01             	add    $0x1,%ecx
  800c24:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c27:	0f b6 01             	movzbl (%ecx),%eax
  800c2a:	84 c0                	test   %al,%al
  800c2c:	74 0e                	je     800c3c <strncmp+0x41>
  800c2e:	3a 03                	cmp    (%ebx),%al
  800c30:	74 ea                	je     800c1c <strncmp+0x21>
  800c32:	eb 08                	jmp    800c3c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c3c:	0f b6 01             	movzbl (%ecx),%eax
  800c3f:	0f b6 13             	movzbl (%ebx),%edx
  800c42:	29 d0                	sub    %edx,%eax
  800c44:	eb f3                	jmp    800c39 <strncmp+0x3e>

00800c46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c50:	0f b6 10             	movzbl (%eax),%edx
  800c53:	84 d2                	test   %dl,%dl
  800c55:	74 1c                	je     800c73 <strchr+0x2d>
		if (*s == c)
  800c57:	38 ca                	cmp    %cl,%dl
  800c59:	75 09                	jne    800c64 <strchr+0x1e>
  800c5b:	eb 1b                	jmp    800c78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800c60:	38 ca                	cmp    %cl,%dl
  800c62:	74 14                	je     800c78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c64:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800c68:	84 d2                	test   %dl,%dl
  800c6a:	75 f1                	jne    800c5d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800c6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c71:	eb 05                	jmp    800c78 <strchr+0x32>
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c84:	0f b6 10             	movzbl (%eax),%edx
  800c87:	84 d2                	test   %dl,%dl
  800c89:	74 14                	je     800c9f <strfind+0x25>
		if (*s == c)
  800c8b:	38 ca                	cmp    %cl,%dl
  800c8d:	75 06                	jne    800c95 <strfind+0x1b>
  800c8f:	eb 0e                	jmp    800c9f <strfind+0x25>
  800c91:	38 ca                	cmp    %cl,%dl
  800c93:	74 0a                	je     800c9f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	0f b6 10             	movzbl (%eax),%edx
  800c9b:	84 d2                	test   %dl,%dl
  800c9d:	75 f2                	jne    800c91 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800caa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb9:	85 c9                	test   %ecx,%ecx
  800cbb:	74 30                	je     800ced <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cc3:	75 25                	jne    800cea <memset+0x49>
  800cc5:	f6 c1 03             	test   $0x3,%cl
  800cc8:	75 20                	jne    800cea <memset+0x49>
		c &= 0xFF;
  800cca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	c1 e3 08             	shl    $0x8,%ebx
  800cd2:	89 d6                	mov    %edx,%esi
  800cd4:	c1 e6 18             	shl    $0x18,%esi
  800cd7:	89 d0                	mov    %edx,%eax
  800cd9:	c1 e0 10             	shl    $0x10,%eax
  800cdc:	09 f0                	or     %esi,%eax
  800cde:	09 d0                	or     %edx,%eax
  800ce0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ce2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ce5:	fc                   	cld    
  800ce6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ce8:	eb 03                	jmp    800ced <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cea:	fc                   	cld    
  800ceb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ced:	89 f8                	mov    %edi,%eax
  800cef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf8:	89 ec                	mov    %ebp,%esp
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
  800d02:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d05:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d11:	39 c6                	cmp    %eax,%esi
  800d13:	73 36                	jae    800d4b <memmove+0x4f>
  800d15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d18:	39 d0                	cmp    %edx,%eax
  800d1a:	73 2f                	jae    800d4b <memmove+0x4f>
		s += n;
		d += n;
  800d1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 1b                	jne    800d3f <memmove+0x43>
  800d24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d2a:	75 13                	jne    800d3f <memmove+0x43>
  800d2c:	f6 c1 03             	test   $0x3,%cl
  800d2f:	75 0e                	jne    800d3f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d31:	83 ef 04             	sub    $0x4,%edi
  800d34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d3a:	fd                   	std    
  800d3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d3d:	eb 09                	jmp    800d48 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d3f:	83 ef 01             	sub    $0x1,%edi
  800d42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d45:	fd                   	std    
  800d46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d48:	fc                   	cld    
  800d49:	eb 20                	jmp    800d6b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d51:	75 13                	jne    800d66 <memmove+0x6a>
  800d53:	a8 03                	test   $0x3,%al
  800d55:	75 0f                	jne    800d66 <memmove+0x6a>
  800d57:	f6 c1 03             	test   $0x3,%cl
  800d5a:	75 0a                	jne    800d66 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d5c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d5f:	89 c7                	mov    %eax,%edi
  800d61:	fc                   	cld    
  800d62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d64:	eb 05                	jmp    800d6b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d66:	89 c7                	mov    %eax,%edi
  800d68:	fc                   	cld    
  800d69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d71:	89 ec                	mov    %ebp,%esp
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	89 04 24             	mov    %eax,(%esp)
  800d8f:	e8 68 ff ff ff       	call   800cfc <memmove>
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    

00800d96 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800da5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800daa:	85 ff                	test   %edi,%edi
  800dac:	74 37                	je     800de5 <memcmp+0x4f>
		if (*s1 != *s2)
  800dae:	0f b6 03             	movzbl (%ebx),%eax
  800db1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800db4:	83 ef 01             	sub    $0x1,%edi
  800db7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800dbc:	38 c8                	cmp    %cl,%al
  800dbe:	74 1c                	je     800ddc <memcmp+0x46>
  800dc0:	eb 10                	jmp    800dd2 <memcmp+0x3c>
  800dc2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800dc7:	83 c2 01             	add    $0x1,%edx
  800dca:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800dce:	38 c8                	cmp    %cl,%al
  800dd0:	74 0a                	je     800ddc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800dd2:	0f b6 c0             	movzbl %al,%eax
  800dd5:	0f b6 c9             	movzbl %cl,%ecx
  800dd8:	29 c8                	sub    %ecx,%eax
  800dda:	eb 09                	jmp    800de5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ddc:	39 fa                	cmp    %edi,%edx
  800dde:	75 e2                	jne    800dc2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800de0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800df0:	89 c2                	mov    %eax,%edx
  800df2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df5:	39 d0                	cmp    %edx,%eax
  800df7:	73 19                	jae    800e12 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800dfd:	38 08                	cmp    %cl,(%eax)
  800dff:	75 06                	jne    800e07 <memfind+0x1d>
  800e01:	eb 0f                	jmp    800e12 <memfind+0x28>
  800e03:	38 08                	cmp    %cl,(%eax)
  800e05:	74 0b                	je     800e12 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e07:	83 c0 01             	add    $0x1,%eax
  800e0a:	39 d0                	cmp    %edx,%eax
  800e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e10:	75 f1                	jne    800e03 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e20:	0f b6 02             	movzbl (%edx),%eax
  800e23:	3c 20                	cmp    $0x20,%al
  800e25:	74 04                	je     800e2b <strtol+0x17>
  800e27:	3c 09                	cmp    $0x9,%al
  800e29:	75 0e                	jne    800e39 <strtol+0x25>
		s++;
  800e2b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e2e:	0f b6 02             	movzbl (%edx),%eax
  800e31:	3c 20                	cmp    $0x20,%al
  800e33:	74 f6                	je     800e2b <strtol+0x17>
  800e35:	3c 09                	cmp    $0x9,%al
  800e37:	74 f2                	je     800e2b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e39:	3c 2b                	cmp    $0x2b,%al
  800e3b:	75 0a                	jne    800e47 <strtol+0x33>
		s++;
  800e3d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e40:	bf 00 00 00 00       	mov    $0x0,%edi
  800e45:	eb 10                	jmp    800e57 <strtol+0x43>
  800e47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e4c:	3c 2d                	cmp    $0x2d,%al
  800e4e:	75 07                	jne    800e57 <strtol+0x43>
		s++, neg = 1;
  800e50:	83 c2 01             	add    $0x1,%edx
  800e53:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e57:	85 db                	test   %ebx,%ebx
  800e59:	0f 94 c0             	sete   %al
  800e5c:	74 05                	je     800e63 <strtol+0x4f>
  800e5e:	83 fb 10             	cmp    $0x10,%ebx
  800e61:	75 15                	jne    800e78 <strtol+0x64>
  800e63:	80 3a 30             	cmpb   $0x30,(%edx)
  800e66:	75 10                	jne    800e78 <strtol+0x64>
  800e68:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e6c:	75 0a                	jne    800e78 <strtol+0x64>
		s += 2, base = 16;
  800e6e:	83 c2 02             	add    $0x2,%edx
  800e71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e76:	eb 13                	jmp    800e8b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e78:	84 c0                	test   %al,%al
  800e7a:	74 0f                	je     800e8b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e81:	80 3a 30             	cmpb   $0x30,(%edx)
  800e84:	75 05                	jne    800e8b <strtol+0x77>
		s++, base = 8;
  800e86:	83 c2 01             	add    $0x1,%edx
  800e89:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e92:	0f b6 0a             	movzbl (%edx),%ecx
  800e95:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e98:	80 fb 09             	cmp    $0x9,%bl
  800e9b:	77 08                	ja     800ea5 <strtol+0x91>
			dig = *s - '0';
  800e9d:	0f be c9             	movsbl %cl,%ecx
  800ea0:	83 e9 30             	sub    $0x30,%ecx
  800ea3:	eb 1e                	jmp    800ec3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ea5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ea8:	80 fb 19             	cmp    $0x19,%bl
  800eab:	77 08                	ja     800eb5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ead:	0f be c9             	movsbl %cl,%ecx
  800eb0:	83 e9 57             	sub    $0x57,%ecx
  800eb3:	eb 0e                	jmp    800ec3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800eb5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800eb8:	80 fb 19             	cmp    $0x19,%bl
  800ebb:	77 14                	ja     800ed1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ebd:	0f be c9             	movsbl %cl,%ecx
  800ec0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ec3:	39 f1                	cmp    %esi,%ecx
  800ec5:	7d 0e                	jge    800ed5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ec7:	83 c2 01             	add    $0x1,%edx
  800eca:	0f af c6             	imul   %esi,%eax
  800ecd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ecf:	eb c1                	jmp    800e92 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ed1:	89 c1                	mov    %eax,%ecx
  800ed3:	eb 02                	jmp    800ed7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ed5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ed7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800edb:	74 05                	je     800ee2 <strtol+0xce>
		*endptr = (char *) s;
  800edd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ee2:	89 ca                	mov    %ecx,%edx
  800ee4:	f7 da                	neg    %edx
  800ee6:	85 ff                	test   %edi,%edi
  800ee8:	0f 45 c2             	cmovne %edx,%eax
}
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eff:	b8 00 00 00 00       	mov    $0x0,%eax
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	89 c7                	mov    %eax,%edi
  800f0e:	89 c6                	mov    %eax,%esi
  800f10:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1b:	89 ec                	mov    %ebp,%esp
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 0c             	sub    $0xc,%esp
  800f25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 01 00 00 00       	mov    $0x1,%eax
  800f38:	89 d1                	mov    %edx,%ecx
  800f3a:	89 d3                	mov    %edx,%ebx
  800f3c:	89 d7                	mov    %edx,%edi
  800f3e:	89 d6                	mov    %edx,%esi
  800f40:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4b:	89 ec                	mov    %ebp,%esp
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 38             	sub    $0x38,%esp
  800f55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f63:	b8 03 00 00 00       	mov    $0x3,%eax
  800f68:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6b:	89 cb                	mov    %ecx,%ebx
  800f6d:	89 cf                	mov    %ecx,%edi
  800f6f:	89 ce                	mov    %ecx,%esi
  800f71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7e 28                	jle    800f9f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f82:	00 
  800f83:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f92:	00 
  800f93:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800f9a:	e8 25 f3 ff ff       	call   8002c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa8:	89 ec                	mov    %ebp,%esp
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	89 d3                	mov    %edx,%ebx
  800fc9:	89 d7                	mov    %edx,%edi
  800fcb:	89 d6                	mov    %edx,%esi
  800fcd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_yield>:

void
sys_yield(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800feb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	89 d3                	mov    %edx,%ebx
  800ff9:	89 d7                	mov    %edx,%edi
  800ffb:	89 d6                	mov    %edx,%esi
  800ffd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801002:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801005:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801008:	89 ec                	mov    %ebp,%esp
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 38             	sub    $0x38,%esp
  801012:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801015:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801018:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101b:	be 00 00 00 00       	mov    $0x0,%esi
  801020:	b8 04 00 00 00       	mov    $0x4,%eax
  801025:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801028:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102b:	8b 55 08             	mov    0x8(%ebp),%edx
  80102e:	89 f7                	mov    %esi,%edi
  801030:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801032:	85 c0                	test   %eax,%eax
  801034:	7e 28                	jle    80105e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801036:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801041:	00 
  801042:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  801049:	00 
  80104a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801051:	00 
  801052:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  801059:	e8 66 f2 ff ff       	call   8002c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80105e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801061:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801064:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801067:	89 ec                	mov    %ebp,%esp
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	83 ec 38             	sub    $0x38,%esp
  801071:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801074:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801077:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107a:	b8 05 00 00 00       	mov    $0x5,%eax
  80107f:	8b 75 18             	mov    0x18(%ebp),%esi
  801082:	8b 7d 14             	mov    0x14(%ebp),%edi
  801085:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801090:	85 c0                	test   %eax,%eax
  801092:	7e 28                	jle    8010bc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801094:	89 44 24 10          	mov    %eax,0x10(%esp)
  801098:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80109f:	00 
  8010a0:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  8010a7:	00 
  8010a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010af:	00 
  8010b0:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  8010b7:	e8 08 f2 ff ff       	call   8002c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010bc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010bf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c5:	89 ec                	mov    %ebp,%esp
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	83 ec 38             	sub    $0x38,%esp
  8010cf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010d2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010d5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	89 df                	mov    %ebx,%edi
  8010ea:	89 de                	mov    %ebx,%esi
  8010ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	7e 28                	jle    80111a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  801105:	00 
  801106:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80110d:	00 
  80110e:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  801115:	e8 aa f1 ff ff       	call   8002c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80111a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80111d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801120:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801123:	89 ec                	mov    %ebp,%esp
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 38             	sub    $0x38,%esp
  80112d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801130:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801133:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801136:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113b:	b8 08 00 00 00       	mov    $0x8,%eax
  801140:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801143:	8b 55 08             	mov    0x8(%ebp),%edx
  801146:	89 df                	mov    %ebx,%edi
  801148:	89 de                	mov    %ebx,%esi
  80114a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80114c:	85 c0                	test   %eax,%eax
  80114e:	7e 28                	jle    801178 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801150:	89 44 24 10          	mov    %eax,0x10(%esp)
  801154:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80115b:	00 
  80115c:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  801163:	00 
  801164:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80116b:	00 
  80116c:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  801173:	e8 4c f1 ff ff       	call   8002c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801178:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80117b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80117e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801181:	89 ec                	mov    %ebp,%esp
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  801194:	bb 00 00 00 00       	mov    $0x0,%ebx
  801199:	b8 09 00 00 00       	mov    $0x9,%eax
  80119e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a4:	89 df                	mov    %ebx,%edi
  8011a6:	89 de                	mov    %ebx,%esi
  8011a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	7e 28                	jle    8011d6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  8011c1:	00 
  8011c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c9:	00 
  8011ca:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  8011d1:	e8 ee f0 ff ff       	call   8002c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011df:	89 ec                	mov    %ebp,%esp
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 0c             	sub    $0xc,%esp
  8011e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f2:	be 00 00 00 00       	mov    $0x0,%esi
  8011f7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801205:	8b 55 08             	mov    0x8(%ebp),%edx
  801208:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80120a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80120d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801210:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801213:	89 ec                	mov    %ebp,%esp
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	83 ec 38             	sub    $0x38,%esp
  80121d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801220:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801223:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801226:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801230:	8b 55 08             	mov    0x8(%ebp),%edx
  801233:	89 cb                	mov    %ecx,%ebx
  801235:	89 cf                	mov    %ecx,%edi
  801237:	89 ce                	mov    %ecx,%esi
  801239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80123b:	85 c0                	test   %eax,%eax
  80123d:	7e 28                	jle    801267 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801243:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80124a:	00 
  80124b:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  801252:	00 
  801253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80125a:	00 
  80125b:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  801262:	e8 5d f0 ff ff       	call   8002c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801267:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80126a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80126d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801270:	89 ec                	mov    %ebp,%esp
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 0c             	sub    $0xc,%esp
  80127a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80127d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801280:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801283:	b9 00 00 00 00       	mov    $0x0,%ecx
  801288:	b8 0d 00 00 00       	mov    $0xd,%eax
  80128d:	8b 55 08             	mov    0x8(%ebp),%edx
  801290:	89 cb                	mov    %ecx,%ebx
  801292:	89 cf                	mov    %ecx,%edi
  801294:	89 ce                	mov    %ecx,%esi
  801296:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  801298:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80129b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80129e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012a1:	89 ec                	mov    %ebp,%esp
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
	...

008012b0 <__udivdi3>:
  8012b0:	83 ec 1c             	sub    $0x1c,%esp
  8012b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8012b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8012bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8012bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8012cb:	85 ff                	test   %edi,%edi
  8012cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8012d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d5:	89 cd                	mov    %ecx,%ebp
  8012d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012db:	75 33                	jne    801310 <__udivdi3+0x60>
  8012dd:	39 f1                	cmp    %esi,%ecx
  8012df:	77 57                	ja     801338 <__udivdi3+0x88>
  8012e1:	85 c9                	test   %ecx,%ecx
  8012e3:	75 0b                	jne    8012f0 <__udivdi3+0x40>
  8012e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ea:	31 d2                	xor    %edx,%edx
  8012ec:	f7 f1                	div    %ecx
  8012ee:	89 c1                	mov    %eax,%ecx
  8012f0:	89 f0                	mov    %esi,%eax
  8012f2:	31 d2                	xor    %edx,%edx
  8012f4:	f7 f1                	div    %ecx
  8012f6:	89 c6                	mov    %eax,%esi
  8012f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012fc:	f7 f1                	div    %ecx
  8012fe:	89 f2                	mov    %esi,%edx
  801300:	8b 74 24 10          	mov    0x10(%esp),%esi
  801304:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801308:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80130c:	83 c4 1c             	add    $0x1c,%esp
  80130f:	c3                   	ret    
  801310:	31 d2                	xor    %edx,%edx
  801312:	31 c0                	xor    %eax,%eax
  801314:	39 f7                	cmp    %esi,%edi
  801316:	77 e8                	ja     801300 <__udivdi3+0x50>
  801318:	0f bd cf             	bsr    %edi,%ecx
  80131b:	83 f1 1f             	xor    $0x1f,%ecx
  80131e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801322:	75 2c                	jne    801350 <__udivdi3+0xa0>
  801324:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801328:	76 04                	jbe    80132e <__udivdi3+0x7e>
  80132a:	39 f7                	cmp    %esi,%edi
  80132c:	73 d2                	jae    801300 <__udivdi3+0x50>
  80132e:	31 d2                	xor    %edx,%edx
  801330:	b8 01 00 00 00       	mov    $0x1,%eax
  801335:	eb c9                	jmp    801300 <__udivdi3+0x50>
  801337:	90                   	nop
  801338:	89 f2                	mov    %esi,%edx
  80133a:	f7 f1                	div    %ecx
  80133c:	31 d2                	xor    %edx,%edx
  80133e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801342:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801346:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80134a:	83 c4 1c             	add    $0x1c,%esp
  80134d:	c3                   	ret    
  80134e:	66 90                	xchg   %ax,%ax
  801350:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801355:	b8 20 00 00 00       	mov    $0x20,%eax
  80135a:	89 ea                	mov    %ebp,%edx
  80135c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801360:	d3 e7                	shl    %cl,%edi
  801362:	89 c1                	mov    %eax,%ecx
  801364:	d3 ea                	shr    %cl,%edx
  801366:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80136b:	09 fa                	or     %edi,%edx
  80136d:	89 f7                	mov    %esi,%edi
  80136f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801373:	89 f2                	mov    %esi,%edx
  801375:	8b 74 24 08          	mov    0x8(%esp),%esi
  801379:	d3 e5                	shl    %cl,%ebp
  80137b:	89 c1                	mov    %eax,%ecx
  80137d:	d3 ef                	shr    %cl,%edi
  80137f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801384:	d3 e2                	shl    %cl,%edx
  801386:	89 c1                	mov    %eax,%ecx
  801388:	d3 ee                	shr    %cl,%esi
  80138a:	09 d6                	or     %edx,%esi
  80138c:	89 fa                	mov    %edi,%edx
  80138e:	89 f0                	mov    %esi,%eax
  801390:	f7 74 24 0c          	divl   0xc(%esp)
  801394:	89 d7                	mov    %edx,%edi
  801396:	89 c6                	mov    %eax,%esi
  801398:	f7 e5                	mul    %ebp
  80139a:	39 d7                	cmp    %edx,%edi
  80139c:	72 22                	jb     8013c0 <__udivdi3+0x110>
  80139e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8013a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013a7:	d3 e5                	shl    %cl,%ebp
  8013a9:	39 c5                	cmp    %eax,%ebp
  8013ab:	73 04                	jae    8013b1 <__udivdi3+0x101>
  8013ad:	39 d7                	cmp    %edx,%edi
  8013af:	74 0f                	je     8013c0 <__udivdi3+0x110>
  8013b1:	89 f0                	mov    %esi,%eax
  8013b3:	31 d2                	xor    %edx,%edx
  8013b5:	e9 46 ff ff ff       	jmp    801300 <__udivdi3+0x50>
  8013ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8013c3:	31 d2                	xor    %edx,%edx
  8013c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013d1:	83 c4 1c             	add    $0x1c,%esp
  8013d4:	c3                   	ret    
	...

008013e0 <__umoddi3>:
  8013e0:	83 ec 1c             	sub    $0x1c,%esp
  8013e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8013e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8013eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8013ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8013fb:	85 ed                	test   %ebp,%ebp
  8013fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801401:	89 44 24 08          	mov    %eax,0x8(%esp)
  801405:	89 cf                	mov    %ecx,%edi
  801407:	89 04 24             	mov    %eax,(%esp)
  80140a:	89 f2                	mov    %esi,%edx
  80140c:	75 1a                	jne    801428 <__umoddi3+0x48>
  80140e:	39 f1                	cmp    %esi,%ecx
  801410:	76 4e                	jbe    801460 <__umoddi3+0x80>
  801412:	f7 f1                	div    %ecx
  801414:	89 d0                	mov    %edx,%eax
  801416:	31 d2                	xor    %edx,%edx
  801418:	8b 74 24 10          	mov    0x10(%esp),%esi
  80141c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801420:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801424:	83 c4 1c             	add    $0x1c,%esp
  801427:	c3                   	ret    
  801428:	39 f5                	cmp    %esi,%ebp
  80142a:	77 54                	ja     801480 <__umoddi3+0xa0>
  80142c:	0f bd c5             	bsr    %ebp,%eax
  80142f:	83 f0 1f             	xor    $0x1f,%eax
  801432:	89 44 24 04          	mov    %eax,0x4(%esp)
  801436:	75 60                	jne    801498 <__umoddi3+0xb8>
  801438:	3b 0c 24             	cmp    (%esp),%ecx
  80143b:	0f 87 07 01 00 00    	ja     801548 <__umoddi3+0x168>
  801441:	89 f2                	mov    %esi,%edx
  801443:	8b 34 24             	mov    (%esp),%esi
  801446:	29 ce                	sub    %ecx,%esi
  801448:	19 ea                	sbb    %ebp,%edx
  80144a:	89 34 24             	mov    %esi,(%esp)
  80144d:	8b 04 24             	mov    (%esp),%eax
  801450:	8b 74 24 10          	mov    0x10(%esp),%esi
  801454:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801458:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80145c:	83 c4 1c             	add    $0x1c,%esp
  80145f:	c3                   	ret    
  801460:	85 c9                	test   %ecx,%ecx
  801462:	75 0b                	jne    80146f <__umoddi3+0x8f>
  801464:	b8 01 00 00 00       	mov    $0x1,%eax
  801469:	31 d2                	xor    %edx,%edx
  80146b:	f7 f1                	div    %ecx
  80146d:	89 c1                	mov    %eax,%ecx
  80146f:	89 f0                	mov    %esi,%eax
  801471:	31 d2                	xor    %edx,%edx
  801473:	f7 f1                	div    %ecx
  801475:	8b 04 24             	mov    (%esp),%eax
  801478:	f7 f1                	div    %ecx
  80147a:	eb 98                	jmp    801414 <__umoddi3+0x34>
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	89 f2                	mov    %esi,%edx
  801482:	8b 74 24 10          	mov    0x10(%esp),%esi
  801486:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80148a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80148e:	83 c4 1c             	add    $0x1c,%esp
  801491:	c3                   	ret    
  801492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801498:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80149d:	89 e8                	mov    %ebp,%eax
  80149f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8014a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8014a8:	89 fa                	mov    %edi,%edx
  8014aa:	d3 e0                	shl    %cl,%eax
  8014ac:	89 e9                	mov    %ebp,%ecx
  8014ae:	d3 ea                	shr    %cl,%edx
  8014b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014b5:	09 c2                	or     %eax,%edx
  8014b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014bb:	89 14 24             	mov    %edx,(%esp)
  8014be:	89 f2                	mov    %esi,%edx
  8014c0:	d3 e7                	shl    %cl,%edi
  8014c2:	89 e9                	mov    %ebp,%ecx
  8014c4:	d3 ea                	shr    %cl,%edx
  8014c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014cf:	d3 e6                	shl    %cl,%esi
  8014d1:	89 e9                	mov    %ebp,%ecx
  8014d3:	d3 e8                	shr    %cl,%eax
  8014d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014da:	09 f0                	or     %esi,%eax
  8014dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8014e0:	f7 34 24             	divl   (%esp)
  8014e3:	d3 e6                	shl    %cl,%esi
  8014e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014e9:	89 d6                	mov    %edx,%esi
  8014eb:	f7 e7                	mul    %edi
  8014ed:	39 d6                	cmp    %edx,%esi
  8014ef:	89 c1                	mov    %eax,%ecx
  8014f1:	89 d7                	mov    %edx,%edi
  8014f3:	72 3f                	jb     801534 <__umoddi3+0x154>
  8014f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014f9:	72 35                	jb     801530 <__umoddi3+0x150>
  8014fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014ff:	29 c8                	sub    %ecx,%eax
  801501:	19 fe                	sbb    %edi,%esi
  801503:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801508:	89 f2                	mov    %esi,%edx
  80150a:	d3 e8                	shr    %cl,%eax
  80150c:	89 e9                	mov    %ebp,%ecx
  80150e:	d3 e2                	shl    %cl,%edx
  801510:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801515:	09 d0                	or     %edx,%eax
  801517:	89 f2                	mov    %esi,%edx
  801519:	d3 ea                	shr    %cl,%edx
  80151b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80151f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801523:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801527:	83 c4 1c             	add    $0x1c,%esp
  80152a:	c3                   	ret    
  80152b:	90                   	nop
  80152c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801530:	39 d6                	cmp    %edx,%esi
  801532:	75 c7                	jne    8014fb <__umoddi3+0x11b>
  801534:	89 d7                	mov    %edx,%edi
  801536:	89 c1                	mov    %eax,%ecx
  801538:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80153c:	1b 3c 24             	sbb    (%esp),%edi
  80153f:	eb ba                	jmp    8014fb <__umoddi3+0x11b>
  801541:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801548:	39 f5                	cmp    %esi,%ebp
  80154a:	0f 82 f1 fe ff ff    	jb     801441 <__umoddi3+0x61>
  801550:	e9 f8 fe ff ff       	jmp    80144d <__umoddi3+0x6d>
