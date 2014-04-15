
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 be 22 f0    	mov    %esi,0xf022be80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 8c 68 00 00       	call   f01068f0 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 40 70 10 f0 	movl   $0xf0107040,(%esp)
f010007d:	e8 74 45 00 00       	call   f01045f6 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 35 45 00 00       	call   f01045c3 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 30 87 10 f0 	movl   $0xf0108730,(%esp)
f0100095:	e8 5c 45 00 00       	call   f01045f6 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 86 0f 00 00       	call   f010102c <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 ab 70 10 f0 	movl   $0xf01070ab,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 09 68 00 00       	call   f01068f0 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 b7 70 10 f0 	movl   $0xf01070b7,(%esp)
f01000f2:	e8 ff 44 00 00       	call   f01045f6 <cprintf>

	lapic_init();
f01000f7:	e8 0e 68 00 00       	call   f010690a <lapic_init>
	env_init_percpu();
f01000fc:	e8 90 3c 00 00       	call   f0103d91 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 0a 45 00 00       	call   f0104610 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 e5 67 00 00       	call   f01068f0 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f0100124:	e8 77 6a 00 00       	call   f0106ba0 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 3e 4e 00 00       	call   f0104f6c <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 d0 26 f0       	mov    $0xf026d008,%eax
f010013a:	2d 74 a4 22 f0       	sub    $0xf022a474,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 74 a4 22 f0 	movl   $0xf022a474,(%esp)
f0100152:	e8 0a 61 00 00       	call   f0106261 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 2f 05 00 00       	call   f010068b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 cd 70 10 f0 	movl   $0xf01070cd,(%esp)
f010016b:	e8 86 44 00 00       	call   f01045f6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 f2 19 00 00       	call   f0101b67 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 41 3c 00 00       	call   f0103dbb <env_init>
	trap_init();
f010017a:	e8 89 45 00 00       	call   f0104708 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 8c 64 00 00       	call   f0106611 <mp_init>
	lapic_init();
f0100185:	e8 80 67 00 00       	call   f010690a <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 96 43 00 00       	call   f0104525 <pic_init>
f010018f:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f0100196:	e8 05 6a 00 00       	call   f0106ba0 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019b:	83 3d 88 be 22 f0 07 	cmpl   $0x7,0xf022be88
f01001a2:	77 24                	ja     f01001c8 <i386_init+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001ab:	00 
f01001ac:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 ab 70 10 f0 	movl   $0xf01070ab,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 2a 65 10 f0       	mov    $0xf010652a,%eax
f01001cd:	2d b0 64 10 f0       	sub    $0xf01064b0,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 b0 64 10 	movl   $0xf01064b0,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 d2 60 00 00       	call   f01062bc <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01001f1:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01001f6:	3d 20 c0 22 f0       	cmp    $0xf022c020,%eax
f01001fb:	76 62                	jbe    f010025f <i386_init+0x131>
f01001fd:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100202:	e8 e9 66 00 00       	call   f01068f0 <cpunum>
f0100207:	6b c0 74             	imul   $0x74,%eax,%eax
f010020a:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010020f:	39 c3                	cmp    %eax,%ebx
f0100211:	74 39                	je     f010024c <i386_init+0x11e>

static void boot_aps(void);


void
i386_init(void)
f0100213:	89 d8                	mov    %ebx,%eax
f0100215:	2d 20 c0 22 f0       	sub    $0xf022c020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021a:	c1 f8 02             	sar    $0x2,%eax
f010021d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100223:	c1 e0 0f             	shl    $0xf,%eax
f0100226:	8d 80 00 50 23 f0    	lea    -0xfdcb000(%eax),%eax
f010022c:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100231:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100238:	00 
f0100239:	0f b6 03             	movzbl (%ebx),%eax
f010023c:	89 04 24             	mov    %eax,(%esp)
f010023f:	e8 14 68 00 00       	call   f0106a58 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100244:	8b 43 04             	mov    0x4(%ebx),%eax
f0100247:	83 f8 01             	cmp    $0x1,%eax
f010024a:	75 f8                	jne    f0100244 <i386_init+0x116>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010024c:	83 c3 74             	add    $0x74,%ebx
f010024f:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0100256:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010025b:	39 c3                	cmp    %eax,%ebx
f010025d:	72 a3                	jb     f0100202 <i386_init+0xd4>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010025f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100266:	00 
f0100267:	c7 44 24 04 0e 9a 00 	movl   $0x9a0e,0x4(%esp)
f010026e:	00 
f010026f:	c7 04 24 36 b1 1f f0 	movl   $0xf01fb136,(%esp)
f0100276:	e8 2d 3d 00 00       	call   f0103fa8 <env_create>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	
	// Schedule and run the first user environment!
	sched_yield();
f010027b:	e8 ec 4c 00 00       	call   f0104f6c <sched_yield>

f0100280 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100280:	55                   	push   %ebp
f0100281:	89 e5                	mov    %esp,%ebp
f0100283:	53                   	push   %ebx
f0100284:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100287:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010028a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010028d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100291:	8b 45 08             	mov    0x8(%ebp),%eax
f0100294:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100298:	c7 04 24 e8 70 10 f0 	movl   $0xf01070e8,(%esp)
f010029f:	e8 52 43 00 00       	call   f01045f6 <cprintf>
	vcprintf(fmt, ap);
f01002a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ab:	89 04 24             	mov    %eax,(%esp)
f01002ae:	e8 10 43 00 00       	call   f01045c3 <vcprintf>
	cprintf("\n");
f01002b3:	c7 04 24 30 87 10 f0 	movl   $0xf0108730,(%esp)
f01002ba:	e8 37 43 00 00       	call   f01045f6 <cprintf>
	va_end(ap);
}
f01002bf:	83 c4 14             	add    $0x14,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    
	...

f01002d0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	ec                   	in     (%dx),%al
f01002da:	ec                   	in     (%dx),%al
f01002db:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002dc:	5d                   	pop    %ebp
f01002dd:	c3                   	ret    

f01002de <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002de:	55                   	push   %ebp
f01002df:	89 e5                	mov    %esp,%ebp
f01002e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002e7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002ec:	a8 01                	test   $0x1,%al
f01002ee:	74 06                	je     f01002f6 <serial_proc_data+0x18>
f01002f0:	b2 f8                	mov    $0xf8,%dl
f01002f2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002f3:	0f b6 c8             	movzbl %al,%ecx
}
f01002f6:	89 c8                	mov    %ecx,%eax
f01002f8:	5d                   	pop    %ebp
f01002f9:	c3                   	ret    

f01002fa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fa:	55                   	push   %ebp
f01002fb:	89 e5                	mov    %esp,%ebp
f01002fd:	53                   	push   %ebx
f01002fe:	83 ec 04             	sub    $0x4,%esp
f0100301:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100303:	eb 25                	jmp    f010032a <cons_intr+0x30>
		if (c == 0)
f0100305:	85 c0                	test   %eax,%eax
f0100307:	74 21                	je     f010032a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f0100309:	8b 15 24 b2 22 f0    	mov    0xf022b224,%edx
f010030f:	88 82 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%edx)
f0100315:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100318:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010031d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100322:	0f 44 c2             	cmove  %edx,%eax
f0100325:	a3 24 b2 22 f0       	mov    %eax,0xf022b224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010032a:	ff d3                	call   *%ebx
f010032c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010032f:	75 d4                	jne    f0100305 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100331:	83 c4 04             	add    $0x4,%esp
f0100334:	5b                   	pop    %ebx
f0100335:	5d                   	pop    %ebp
f0100336:	c3                   	ret    

f0100337 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	57                   	push   %edi
f010033b:	56                   	push   %esi
f010033c:	53                   	push   %ebx
f010033d:	83 ec 2c             	sub    $0x2c,%esp
f0100340:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100343:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100348:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100349:	a8 20                	test   $0x20,%al
f010034b:	75 1b                	jne    f0100368 <cons_putc+0x31>
f010034d:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100352:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100357:	e8 74 ff ff ff       	call   f01002d0 <delay>
f010035c:	89 f2                	mov    %esi,%edx
f010035e:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010035f:	a8 20                	test   $0x20,%al
f0100361:	75 05                	jne    f0100368 <cons_putc+0x31>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100363:	83 eb 01             	sub    $0x1,%ebx
f0100366:	75 ef                	jne    f0100357 <cons_putc+0x20>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100368:	0f b6 7d e4          	movzbl -0x1c(%ebp),%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100371:	89 f8                	mov    %edi,%eax
f0100373:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100374:	b2 79                	mov    $0x79,%dl
f0100376:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100377:	84 c0                	test   %al,%al
f0100379:	78 1b                	js     f0100396 <cons_putc+0x5f>
f010037b:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100380:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100385:	e8 46 ff ff ff       	call   f01002d0 <delay>
f010038a:	89 f2                	mov    %esi,%edx
f010038c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010038d:	84 c0                	test   %al,%al
f010038f:	78 05                	js     f0100396 <cons_putc+0x5f>
f0100391:	83 eb 01             	sub    $0x1,%ebx
f0100394:	75 ef                	jne    f0100385 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100396:	ba 78 03 00 00       	mov    $0x378,%edx
f010039b:	89 f8                	mov    %edi,%eax
f010039d:	ee                   	out    %al,(%dx)
f010039e:	b2 7a                	mov    $0x7a,%dl
f01003a0:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003a5:	ee                   	out    %al,(%dx)
f01003a6:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ab:	ee                   	out    %al,(%dx)
extern int ncolor;

static void
cga_putc(int c)
{
	c = c + (ncolor << 8);
f01003ac:	a1 78 24 12 f0       	mov    0xf0122478,%eax
f01003b1:	c1 e0 08             	shl    $0x8,%eax
f01003b4:	03 45 e4             	add    -0x1c(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003b7:	89 c1                	mov    %eax,%ecx
f01003b9:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0700;
f01003bf:	89 c2                	mov    %eax,%edx
f01003c1:	80 ce 07             	or     $0x7,%dh
f01003c4:	85 c9                	test   %ecx,%ecx
f01003c6:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f01003c9:	0f b6 d0             	movzbl %al,%edx
f01003cc:	83 fa 09             	cmp    $0x9,%edx
f01003cf:	74 75                	je     f0100446 <cons_putc+0x10f>
f01003d1:	83 fa 09             	cmp    $0x9,%edx
f01003d4:	7f 0c                	jg     f01003e2 <cons_putc+0xab>
f01003d6:	83 fa 08             	cmp    $0x8,%edx
f01003d9:	0f 85 9b 00 00 00    	jne    f010047a <cons_putc+0x143>
f01003df:	90                   	nop
f01003e0:	eb 10                	jmp    f01003f2 <cons_putc+0xbb>
f01003e2:	83 fa 0a             	cmp    $0xa,%edx
f01003e5:	74 39                	je     f0100420 <cons_putc+0xe9>
f01003e7:	83 fa 0d             	cmp    $0xd,%edx
f01003ea:	0f 85 8a 00 00 00    	jne    f010047a <cons_putc+0x143>
f01003f0:	eb 36                	jmp    f0100428 <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f01003f2:	0f b7 15 34 b2 22 f0 	movzwl 0xf022b234,%edx
f01003f9:	66 85 d2             	test   %dx,%dx
f01003fc:	0f 84 e3 00 00 00    	je     f01004e5 <cons_putc+0x1ae>
			crt_pos--;
f0100402:	83 ea 01             	sub    $0x1,%edx
f0100405:	66 89 15 34 b2 22 f0 	mov    %dx,0xf022b234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010040c:	0f b7 d2             	movzwl %dx,%edx
f010040f:	b0 00                	mov    $0x0,%al
f0100411:	83 c8 20             	or     $0x20,%eax
f0100414:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f010041a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010041e:	eb 78                	jmp    f0100498 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100420:	66 83 05 34 b2 22 f0 	addw   $0x50,0xf022b234
f0100427:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100428:	0f b7 05 34 b2 22 f0 	movzwl 0xf022b234,%eax
f010042f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100435:	c1 e8 16             	shr    $0x16,%eax
f0100438:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043b:	c1 e0 04             	shl    $0x4,%eax
f010043e:	66 a3 34 b2 22 f0    	mov    %ax,0xf022b234
f0100444:	eb 52                	jmp    f0100498 <cons_putc+0x161>
		break;
	case '\t':
		cons_putc(' ');
f0100446:	b8 20 00 00 00       	mov    $0x20,%eax
f010044b:	e8 e7 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 dd fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f010045a:	b8 20 00 00 00       	mov    $0x20,%eax
f010045f:	e8 d3 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100464:	b8 20 00 00 00       	mov    $0x20,%eax
f0100469:	e8 c9 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f010046e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100473:	e8 bf fe ff ff       	call   f0100337 <cons_putc>
f0100478:	eb 1e                	jmp    f0100498 <cons_putc+0x161>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010047a:	0f b7 15 34 b2 22 f0 	movzwl 0xf022b234,%edx
f0100481:	0f b7 da             	movzwl %dx,%ebx
f0100484:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f010048a:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010048e:	83 c2 01             	add    $0x1,%edx
f0100491:	66 89 15 34 b2 22 f0 	mov    %dx,0xf022b234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100498:	66 81 3d 34 b2 22 f0 	cmpw   $0x7cf,0xf022b234
f010049f:	cf 07 
f01004a1:	76 42                	jbe    f01004e5 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a3:	a1 30 b2 22 f0       	mov    0xf022b230,%eax
f01004a8:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004af:	00 
f01004b0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004ba:	89 04 24             	mov    %eax,(%esp)
f01004bd:	e8 fa 5d 00 00       	call   f01062bc <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004c2:	8b 15 30 b2 22 f0    	mov    0xf022b230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c8:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004cd:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d3:	83 c0 01             	add    $0x1,%eax
f01004d6:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004db:	75 f0                	jne    f01004cd <cons_putc+0x196>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004dd:	66 83 2d 34 b2 22 f0 	subw   $0x50,0xf022b234
f01004e4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e5:	8b 0d 2c b2 22 f0    	mov    0xf022b22c,%ecx
f01004eb:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004f0:	89 ca                	mov    %ecx,%edx
f01004f2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f3:	0f b7 35 34 b2 22 f0 	movzwl 0xf022b234,%esi
f01004fa:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004fd:	89 f0                	mov    %esi,%eax
f01004ff:	66 c1 e8 08          	shr    $0x8,%ax
f0100503:	89 da                	mov    %ebx,%edx
f0100505:	ee                   	out    %al,(%dx)
f0100506:	b8 0f 00 00 00       	mov    $0xf,%eax
f010050b:	89 ca                	mov    %ecx,%edx
f010050d:	ee                   	out    %al,(%dx)
f010050e:	89 f0                	mov    %esi,%eax
f0100510:	89 da                	mov    %ebx,%edx
f0100512:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100513:	83 c4 2c             	add    $0x2c,%esp
f0100516:	5b                   	pop    %ebx
f0100517:	5e                   	pop    %esi
f0100518:	5f                   	pop    %edi
f0100519:	5d                   	pop    %ebp
f010051a:	c3                   	ret    

f010051b <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010051b:	55                   	push   %ebp
f010051c:	89 e5                	mov    %esp,%ebp
f010051e:	53                   	push   %ebx
f010051f:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100522:	ba 64 00 00 00       	mov    $0x64,%edx
f0100527:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100528:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010052d:	a8 01                	test   $0x1,%al
f010052f:	0f 84 de 00 00 00    	je     f0100613 <kbd_proc_data+0xf8>
f0100535:	b2 60                	mov    $0x60,%dl
f0100537:	ec                   	in     (%dx),%al
f0100538:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010053a:	3c e0                	cmp    $0xe0,%al
f010053c:	75 11                	jne    f010054f <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010053e:	83 0d 28 b2 22 f0 40 	orl    $0x40,0xf022b228
		return 0;
f0100545:	bb 00 00 00 00       	mov    $0x0,%ebx
f010054a:	e9 c4 00 00 00       	jmp    f0100613 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f010054f:	84 c0                	test   %al,%al
f0100551:	79 37                	jns    f010058a <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100553:	8b 0d 28 b2 22 f0    	mov    0xf022b228,%ecx
f0100559:	89 cb                	mov    %ecx,%ebx
f010055b:	83 e3 40             	and    $0x40,%ebx
f010055e:	83 e0 7f             	and    $0x7f,%eax
f0100561:	85 db                	test   %ebx,%ebx
f0100563:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100566:	0f b6 d2             	movzbl %dl,%edx
f0100569:	0f b6 82 40 71 10 f0 	movzbl -0xfef8ec0(%edx),%eax
f0100570:	83 c8 40             	or     $0x40,%eax
f0100573:	0f b6 c0             	movzbl %al,%eax
f0100576:	f7 d0                	not    %eax
f0100578:	21 c1                	and    %eax,%ecx
f010057a:	89 0d 28 b2 22 f0    	mov    %ecx,0xf022b228
		return 0;
f0100580:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100585:	e9 89 00 00 00       	jmp    f0100613 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010058a:	8b 0d 28 b2 22 f0    	mov    0xf022b228,%ecx
f0100590:	f6 c1 40             	test   $0x40,%cl
f0100593:	74 0e                	je     f01005a3 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100595:	89 c2                	mov    %eax,%edx
f0100597:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010059a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010059d:	89 0d 28 b2 22 f0    	mov    %ecx,0xf022b228
	}

	shift |= shiftcode[data];
f01005a3:	0f b6 d2             	movzbl %dl,%edx
f01005a6:	0f b6 82 40 71 10 f0 	movzbl -0xfef8ec0(%edx),%eax
f01005ad:	0b 05 28 b2 22 f0    	or     0xf022b228,%eax
	shift ^= togglecode[data];
f01005b3:	0f b6 8a 40 72 10 f0 	movzbl -0xfef8dc0(%edx),%ecx
f01005ba:	31 c8                	xor    %ecx,%eax
f01005bc:	a3 28 b2 22 f0       	mov    %eax,0xf022b228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005c1:	89 c1                	mov    %eax,%ecx
f01005c3:	83 e1 03             	and    $0x3,%ecx
f01005c6:	8b 0c 8d 40 73 10 f0 	mov    -0xfef8cc0(,%ecx,4),%ecx
f01005cd:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005d1:	a8 08                	test   $0x8,%al
f01005d3:	74 19                	je     f01005ee <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005d5:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005d8:	83 fa 19             	cmp    $0x19,%edx
f01005db:	77 05                	ja     f01005e2 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005dd:	83 eb 20             	sub    $0x20,%ebx
f01005e0:	eb 0c                	jmp    f01005ee <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01005e2:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01005e5:	8d 53 20             	lea    0x20(%ebx),%edx
f01005e8:	83 f9 19             	cmp    $0x19,%ecx
f01005eb:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005ee:	f7 d0                	not    %eax
f01005f0:	a8 06                	test   $0x6,%al
f01005f2:	75 1f                	jne    f0100613 <kbd_proc_data+0xf8>
f01005f4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005fa:	75 17                	jne    f0100613 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01005fc:	c7 04 24 02 71 10 f0 	movl   $0xf0107102,(%esp)
f0100603:	e8 ee 3f 00 00       	call   f01045f6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100608:	ba 92 00 00 00       	mov    $0x92,%edx
f010060d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100612:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100613:	89 d8                	mov    %ebx,%eax
f0100615:	83 c4 14             	add    $0x14,%esp
f0100618:	5b                   	pop    %ebx
f0100619:	5d                   	pop    %ebp
f010061a:	c3                   	ret    

f010061b <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010061b:	55                   	push   %ebp
f010061c:	89 e5                	mov    %esp,%ebp
f010061e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100621:	80 3d 00 b0 22 f0 00 	cmpb   $0x0,0xf022b000
f0100628:	74 0a                	je     f0100634 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010062a:	b8 de 02 10 f0       	mov    $0xf01002de,%eax
f010062f:	e8 c6 fc ff ff       	call   f01002fa <cons_intr>
}
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    

f0100636 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100636:	55                   	push   %ebp
f0100637:	89 e5                	mov    %esp,%ebp
f0100639:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010063c:	b8 1b 05 10 f0       	mov    $0xf010051b,%eax
f0100641:	e8 b4 fc ff ff       	call   f01002fa <cons_intr>
}
f0100646:	c9                   	leave  
f0100647:	c3                   	ret    

f0100648 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100648:	55                   	push   %ebp
f0100649:	89 e5                	mov    %esp,%ebp
f010064b:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010064e:	e8 c8 ff ff ff       	call   f010061b <serial_intr>
	kbd_intr();
f0100653:	e8 de ff ff ff       	call   f0100636 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100658:	8b 15 20 b2 22 f0    	mov    0xf022b220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010065e:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100663:	3b 15 24 b2 22 f0    	cmp    0xf022b224,%edx
f0100669:	74 1e                	je     f0100689 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010066b:	0f b6 82 20 b0 22 f0 	movzbl -0xfdd4fe0(%edx),%eax
f0100672:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100675:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100680:	0f 44 d1             	cmove  %ecx,%edx
f0100683:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
		return c;
	}
	return 0;
}
f0100689:	c9                   	leave  
f010068a:	c3                   	ret    

f010068b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010068b:	55                   	push   %ebp
f010068c:	89 e5                	mov    %esp,%ebp
f010068e:	57                   	push   %edi
f010068f:	56                   	push   %esi
f0100690:	53                   	push   %ebx
f0100691:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100694:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010069b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006a2:	5a a5 
	if (*cp != 0xA55A) {
f01006a4:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006ab:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006af:	74 11                	je     f01006c2 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006b1:	c7 05 2c b2 22 f0 b4 	movl   $0x3b4,0xf022b22c
f01006b8:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006bb:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006c0:	eb 16                	jmp    f01006d8 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006c2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006c9:	c7 05 2c b2 22 f0 d4 	movl   $0x3d4,0xf022b22c
f01006d0:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006d3:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006d8:	8b 0d 2c b2 22 f0    	mov    0xf022b22c,%ecx
f01006de:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e3:	89 ca                	mov    %ecx,%edx
f01006e5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006e6:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e9:	89 da                	mov    %ebx,%edx
f01006eb:	ec                   	in     (%dx),%al
f01006ec:	0f b6 f8             	movzbl %al,%edi
f01006ef:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006f7:	89 ca                	mov    %ecx,%edx
f01006f9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fa:	89 da                	mov    %ebx,%edx
f01006fc:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006fd:	89 35 30 b2 22 f0    	mov    %esi,0xf022b230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100703:	0f b6 d8             	movzbl %al,%ebx
f0100706:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100708:	66 89 3d 34 b2 22 f0 	mov    %di,0xf022b234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f010070f:	e8 22 ff ff ff       	call   f0100636 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100714:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010071b:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100720:	89 04 24             	mov    %eax,(%esp)
f0100723:	e8 8c 3d 00 00       	call   f01044b4 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100728:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010072d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100732:	89 da                	mov    %ebx,%edx
f0100734:	ee                   	out    %al,(%dx)
f0100735:	b2 fb                	mov    $0xfb,%dl
f0100737:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010073c:	ee                   	out    %al,(%dx)
f010073d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100742:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100747:	89 ca                	mov    %ecx,%edx
f0100749:	ee                   	out    %al,(%dx)
f010074a:	b2 f9                	mov    $0xf9,%dl
f010074c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100751:	ee                   	out    %al,(%dx)
f0100752:	b2 fb                	mov    $0xfb,%dl
f0100754:	b8 03 00 00 00       	mov    $0x3,%eax
f0100759:	ee                   	out    %al,(%dx)
f010075a:	b2 fc                	mov    $0xfc,%dl
f010075c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100761:	ee                   	out    %al,(%dx)
f0100762:	b2 f9                	mov    $0xf9,%dl
f0100764:	b8 01 00 00 00       	mov    $0x1,%eax
f0100769:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076a:	b2 fd                	mov    $0xfd,%dl
f010076c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010076d:	3c ff                	cmp    $0xff,%al
f010076f:	0f 95 c0             	setne  %al
f0100772:	89 c6                	mov    %eax,%esi
f0100774:	a2 00 b0 22 f0       	mov    %al,0xf022b000
f0100779:	89 da                	mov    %ebx,%edx
f010077b:	ec                   	in     (%dx),%al
f010077c:	89 ca                	mov    %ecx,%edx
f010077e:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010077f:	89 f0                	mov    %esi,%eax
f0100781:	84 c0                	test   %al,%al
f0100783:	75 0c                	jne    f0100791 <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f0100785:	c7 04 24 0e 71 10 f0 	movl   $0xf010710e,(%esp)
f010078c:	e8 65 3e 00 00       	call   f01045f6 <cprintf>
}
f0100791:	83 c4 1c             	add    $0x1c,%esp
f0100794:	5b                   	pop    %ebx
f0100795:	5e                   	pop    %esi
f0100796:	5f                   	pop    %edi
f0100797:	5d                   	pop    %ebp
f0100798:	c3                   	ret    

f0100799 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100799:	55                   	push   %ebp
f010079a:	89 e5                	mov    %esp,%ebp
f010079c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079f:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a2:	e8 90 fb ff ff       	call   f0100337 <cons_putc>
}
f01007a7:	c9                   	leave  
f01007a8:	c3                   	ret    

f01007a9 <getchar>:

int
getchar(void)
{
f01007a9:	55                   	push   %ebp
f01007aa:	89 e5                	mov    %esp,%ebp
f01007ac:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007af:	e8 94 fe ff ff       	call   f0100648 <cons_getc>
f01007b4:	85 c0                	test   %eax,%eax
f01007b6:	74 f7                	je     f01007af <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b8:	c9                   	leave  
f01007b9:	c3                   	ret    

f01007ba <iscons>:

int
iscons(int fdnum)
{
f01007ba:	55                   	push   %ebp
f01007bb:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007bd:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c2:	5d                   	pop    %ebp
f01007c3:	c3                   	ret    
	...

f01007d0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d6:	c7 04 24 50 73 10 f0 	movl   $0xf0107350,(%esp)
f01007dd:	e8 14 3e 00 00       	call   f01045f6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007e9:	00 
f01007ea:	c7 04 24 dc 74 10 f0 	movl   $0xf01074dc,(%esp)
f01007f1:	e8 00 3e 00 00       	call   f01045f6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007fd:	00 
f01007fe:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 04 75 10 f0 	movl   $0xf0107504,(%esp)
f010080d:	e8 e4 3d 00 00       	call   f01045f6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100812:	c7 44 24 08 25 70 10 	movl   $0x107025,0x8(%esp)
f0100819:	00 
f010081a:	c7 44 24 04 25 70 10 	movl   $0xf0107025,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 28 75 10 f0 	movl   $0xf0107528,(%esp)
f0100829:	e8 c8 3d 00 00       	call   f01045f6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082e:	c7 44 24 08 74 a4 22 	movl   $0x22a474,0x8(%esp)
f0100835:	00 
f0100836:	c7 44 24 04 74 a4 22 	movl   $0xf022a474,0x4(%esp)
f010083d:	f0 
f010083e:	c7 04 24 4c 75 10 f0 	movl   $0xf010754c,(%esp)
f0100845:	e8 ac 3d 00 00       	call   f01045f6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084a:	c7 44 24 08 08 d0 26 	movl   $0x26d008,0x8(%esp)
f0100851:	00 
f0100852:	c7 44 24 04 08 d0 26 	movl   $0xf026d008,0x4(%esp)
f0100859:	f0 
f010085a:	c7 04 24 70 75 10 f0 	movl   $0xf0107570,(%esp)
f0100861:	e8 90 3d 00 00       	call   f01045f6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100866:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f010086b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100870:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100875:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010087b:	85 c0                	test   %eax,%eax
f010087d:	0f 48 c2             	cmovs  %edx,%eax
f0100880:	c1 f8 0a             	sar    $0xa,%eax
f0100883:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100887:	c7 04 24 94 75 10 f0 	movl   $0xf0107594,(%esp)
f010088e:	e8 63 3d 00 00       	call   f01045f6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100893:	b8 00 00 00 00       	mov    $0x0,%eax
f0100898:	c9                   	leave  
f0100899:	c3                   	ret    

f010089a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010089a:	55                   	push   %ebp
f010089b:	89 e5                	mov    %esp,%ebp
f010089d:	53                   	push   %ebx
f010089e:	83 ec 14             	sub    $0x14,%esp
f01008a1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008a6:	8b 83 44 78 10 f0    	mov    -0xfef87bc(%ebx),%eax
f01008ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008b0:	8b 83 40 78 10 f0    	mov    -0xfef87c0(%ebx),%eax
f01008b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ba:	c7 04 24 69 73 10 f0 	movl   $0xf0107369,(%esp)
f01008c1:	e8 30 3d 00 00       	call   f01045f6 <cprintf>
f01008c6:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008c9:	83 fb 48             	cmp    $0x48,%ebx
f01008cc:	75 d8                	jne    f01008a6 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d3:	83 c4 14             	add    $0x14,%esp
f01008d6:	5b                   	pop    %ebx
f01008d7:	5d                   	pop    %ebp
f01008d8:	c3                   	ret    

f01008d9 <mon_changepermission>:
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
f01008d9:	55                   	push   %ebp
f01008da:	89 e5                	mov    %esp,%ebp
f01008dc:	57                   	push   %edi
f01008dd:	56                   	push   %esi
f01008de:	53                   	push   %ebx
f01008df:	83 ec 2c             	sub    $0x2c,%esp
f01008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f01008e5:	8b 55 08             	mov    0x8(%ebp),%edx
f01008e8:	83 ea 03             	sub    $0x3,%edx
		return -1;
f01008eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f01008f0:	83 fa 01             	cmp    $0x1,%edx
f01008f3:	0f 87 f8 01 00 00    	ja     f0100af1 <mon_changepermission+0x218>
		return -1;

	extern pde_t *kern_pgdir;
	unsigned int num = strtol(argv[2], NULL, 16);
f01008f9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100900:	00 
f0100901:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100908:	00 
f0100909:	8b 43 08             	mov    0x8(%ebx),%eax
f010090c:	89 04 24             	mov    %eax,(%esp)
f010090f:	e8 c0 5a 00 00       	call   f01063d4 <strtol>
f0100914:	89 c6                	mov    %eax,%esi

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
f0100916:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100919:	89 44 24 08          	mov    %eax,0x8(%esp)
f010091d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100921:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0100926:	89 04 24             	mov    %eax,(%esp)
f0100929:	e8 1b 10 00 00       	call   f0101949 <page_lookup>
	if(!pageofva)
f010092e:	85 c0                	test   %eax,%eax
f0100930:	0f 84 b6 01 00 00    	je     f0100aec <mon_changepermission+0x213>
		return -1;

	unsigned int perm = 0;
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f0100936:	c7 44 24 04 72 73 10 	movl   $0xf0107372,0x4(%esp)
f010093d:	f0 
f010093e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100941:	89 04 24             	mov    %eax,(%esp)
f0100944:	e8 42 58 00 00       	call   f010618b <strcmp>
	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;

	unsigned int perm = 0;
f0100949:	bf 00 00 00 00       	mov    $0x0,%edi
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f010094e:	85 c0                	test   %eax,%eax
f0100950:	75 2e                	jne    f0100980 <mon_changepermission+0xa7>
		perm = strtol(argv[3], NULL, 16) | PTE_P;
f0100952:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100959:	00 
f010095a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100961:	00 
f0100962:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100965:	89 04 24             	mov    %eax,(%esp)
f0100968:	e8 67 5a 00 00       	call   f01063d4 <strtol>
f010096d:	89 c7                	mov    %eax,%edi
f010096f:	83 cf 01             	or     $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f0100972:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100975:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f010097b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010097e:	01 38                	add    %edi,(%eax)
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
f0100980:	c7 44 24 04 77 73 10 	movl   $0xf0107377,0x4(%esp)
f0100987:	f0 
f0100988:	8b 43 04             	mov    0x4(%ebx),%eax
f010098b:	89 04 24             	mov    %eax,(%esp)
f010098e:	e8 f8 57 00 00       	call   f010618b <strcmp>
f0100993:	85 c0                	test   %eax,%eax
f0100995:	75 14                	jne    f01009ab <mon_changepermission+0xd2>
		perm = 1;
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f0100997:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010099a:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f01009a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009a3:	83 00 01             	addl   $0x1,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
		perm = 1;
f01009a6:	bf 01 00 00 00       	mov    $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// change
	if(strcmp(argv[1], "-change") == 0) {
f01009ab:	c7 44 24 04 7e 73 10 	movl   $0xf010737e,0x4(%esp)
f01009b2:	f0 
f01009b3:	8b 43 04             	mov    0x4(%ebx),%eax
f01009b6:	89 04 24             	mov    %eax,(%esp)
f01009b9:	e8 cd 57 00 00       	call   f010618b <strcmp>
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	0f 85 0b 01 00 00    	jne    f0100ad1 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f01009c6:	c7 44 24 04 83 84 10 	movl   $0xf0108483,0x4(%esp)
f01009cd:	f0 
f01009ce:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009d1:	89 04 24             	mov    %eax,(%esp)
f01009d4:	e8 b2 57 00 00       	call   f010618b <strcmp>
f01009d9:	85 c0                	test   %eax,%eax
f01009db:	75 06                	jne    f01009e3 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f01009dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009e0:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f01009e3:	c7 44 24 04 94 84 10 	movl   $0xf0108494,0x4(%esp)
f01009ea:	f0 
f01009eb:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009ee:	89 04 24             	mov    %eax,(%esp)
f01009f1:	e8 95 57 00 00       	call   f010618b <strcmp>
f01009f6:	85 c0                	test   %eax,%eax
f01009f8:	75 06                	jne    f0100a00 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f01009fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009fd:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f0100a00:	c7 44 24 04 86 73 10 	movl   $0xf0107386,0x4(%esp)
f0100a07:	f0 
f0100a08:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a0b:	89 04 24             	mov    %eax,(%esp)
f0100a0e:	e8 78 57 00 00       	call   f010618b <strcmp>
f0100a13:	85 c0                	test   %eax,%eax
f0100a15:	75 06                	jne    f0100a1d <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f0100a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1a:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f0100a1d:	c7 44 24 04 e5 83 10 	movl   $0xf01083e5,0x4(%esp)
f0100a24:	f0 
f0100a25:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a28:	89 04 24             	mov    %eax,(%esp)
f0100a2b:	e8 5b 57 00 00       	call   f010618b <strcmp>
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	75 06                	jne    f0100a3a <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f0100a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a37:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f0100a3a:	c7 44 24 04 8e 73 10 	movl   $0xf010738e,0x4(%esp)
f0100a41:	f0 
f0100a42:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a45:	89 04 24             	mov    %eax,(%esp)
f0100a48:	e8 3e 57 00 00       	call   f010618b <strcmp>
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	75 06                	jne    f0100a57 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f0100a51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a54:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f0100a57:	c7 44 24 04 96 73 10 	movl   $0xf0107396,0x4(%esp)
f0100a5e:	f0 
f0100a5f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a62:	89 04 24             	mov    %eax,(%esp)
f0100a65:	e8 21 57 00 00       	call   f010618b <strcmp>
f0100a6a:	85 c0                	test   %eax,%eax
f0100a6c:	75 06                	jne    f0100a74 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f0100a6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a71:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f0100a74:	c7 44 24 04 9c 73 10 	movl   $0xf010739c,0x4(%esp)
f0100a7b:	f0 
f0100a7c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a7f:	89 04 24             	mov    %eax,(%esp)
f0100a82:	e8 04 57 00 00       	call   f010618b <strcmp>
f0100a87:	85 c0                	test   %eax,%eax
f0100a89:	75 06                	jne    f0100a91 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f0100a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8e:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f0100a91:	c7 44 24 04 a2 73 10 	movl   $0xf01073a2,0x4(%esp)
f0100a98:	f0 
f0100a99:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a9c:	89 04 24             	mov    %eax,(%esp)
f0100a9f:	e8 e7 56 00 00       	call   f010618b <strcmp>
f0100aa4:	85 c0                	test   %eax,%eax
f0100aa6:	75 09                	jne    f0100ab1 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f0100aa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aab:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100ab1:	c7 44 24 04 a9 73 10 	movl   $0xf01073a9,0x4(%esp)
f0100ab8:	f0 
f0100ab9:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100abc:	89 04 24             	mov    %eax,(%esp)
f0100abf:	e8 c7 56 00 00       	call   f010618b <strcmp>
f0100ac4:	85 c0                	test   %eax,%eax
f0100ac6:	75 09                	jne    f0100ad1 <mon_changepermission+0x1f8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_G;
f0100ac8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100acb:	81 30 00 01 00 00    	xorl   $0x100,(%eax)
	}
	

	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
f0100ad1:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100ad5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ad9:	c7 04 24 af 73 10 f0 	movl   $0xf01073af,(%esp)
f0100ae0:	e8 11 3b 00 00       	call   f01045f6 <cprintf>
		num, perm);

	return 0;
f0100ae5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aea:	eb 05                	jmp    f0100af1 <mon_changepermission+0x218>
	unsigned int num = strtol(argv[2], NULL, 16);

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;
f0100aec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
		num, perm);

	return 0;
}
f0100af1:	83 c4 2c             	add    $0x2c,%esp
f0100af4:	5b                   	pop    %ebx
f0100af5:	5e                   	pop    %esi
f0100af6:	5f                   	pop    %edi
f0100af7:	5d                   	pop    %ebp
f0100af8:	c3                   	ret    

f0100af9 <mon_showmappings>:
	}
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
f0100af9:	55                   	push   %ebp
f0100afa:	89 e5                	mov    %esp,%ebp
f0100afc:	57                   	push   %edi
f0100afd:	56                   	push   %esi
f0100afe:	53                   	push   %ebx
f0100aff:	83 ec 2c             	sub    $0x2c,%esp
f0100b02:	8b 75 0c             	mov    0xc(%ebp),%esi
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
		return -1;
f0100b05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
f0100b0a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100b0e:	0f 85 a6 00 00 00    	jne    f0100bba <mon_showmappings+0xc1>

	// Get the 2 arguments
	extern pde_t *kern_pgdir;
	unsigned int num[2];

	num[0] = strtol(argv[1], NULL, 16);
f0100b14:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b1b:	00 
f0100b1c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b23:	00 
f0100b24:	8b 46 04             	mov    0x4(%esi),%eax
f0100b27:	89 04 24             	mov    %eax,(%esp)
f0100b2a:	e8 a5 58 00 00       	call   f01063d4 <strtol>
f0100b2f:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f0100b31:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b38:	00 
f0100b39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b40:	00 
f0100b41:	8b 46 08             	mov    0x8(%esi),%eax
f0100b44:	89 04 24             	mov    %eax,(%esp)
f0100b47:	e8 88 58 00 00       	call   f01063d4 <strtol>
f0100b4c:	89 c7                	mov    %eax,%edi
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100b4e:	b8 00 00 00 00       	mov    $0x0,%eax

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100b53:	39 fb                	cmp    %edi,%ebx
f0100b55:	77 63                	ja     f0100bba <mon_showmappings+0xc1>
		unsigned int _pte;
		struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num[0], (pte_t **)(&_pte));
f0100b57:	8d 75 e4             	lea    -0x1c(%ebp),%esi
f0100b5a:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100b5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b62:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0100b67:	89 04 24             	mov    %eax,(%esp)
f0100b6a:	e8 da 0d 00 00       	call   f0101949 <page_lookup>

		if(!pageofva) {
f0100b6f:	85 c0                	test   %eax,%eax
f0100b71:	75 0e                	jne    f0100b81 <mon_showmappings+0x88>
			cprintf("0x%x: There is no physical page here.\n");
f0100b73:	c7 04 24 c0 75 10 f0 	movl   $0xf01075c0,(%esp)
f0100b7a:	e8 77 3a 00 00       	call   f01045f6 <cprintf>
			continue;
f0100b7f:	eb 2a                	jmp    f0100bab <mon_showmappings+0xb2>
		}
		pte_t pte = *((pte_t *)_pte);
f0100b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b84:	8b 00                	mov    (%eax),%eax
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));
f0100b86:	89 c2                	mov    %eax,%edx
f0100b88:	81 e2 ff 0f 00 00    	and    $0xfff,%edx

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
f0100b8e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b9f:	c7 04 24 e8 75 10 f0 	movl   $0xf01075e8,(%esp)
f0100ba6:	e8 4b 3a 00 00       	call   f01045f6 <cprintf>
f0100bab:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100bb1:	39 df                	cmp    %ebx,%edi
f0100bb3:	73 a5                	jae    f0100b5a <mon_showmappings+0x61>
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bba:	83 c4 2c             	add    $0x2c,%esp
f0100bbd:	5b                   	pop    %ebx
f0100bbe:	5e                   	pop    %esi
f0100bbf:	5f                   	pop    %edi
f0100bc0:	5d                   	pop    %ebp
f0100bc1:	c3                   	ret    

f0100bc2 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100bc2:	55                   	push   %ebp
f0100bc3:	89 e5                	mov    %esp,%ebp
f0100bc5:	57                   	push   %edi
f0100bc6:	56                   	push   %esi
f0100bc7:	53                   	push   %ebx
f0100bc8:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100bce:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f0100bd0:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f0100bd2:	8b 43 04             	mov    0x4(%ebx),%eax
f0100bd5:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f0100bdb:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bde:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f0100be4:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100be7:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f0100bed:	8b 43 10             	mov    0x10(%ebx),%eax
f0100bf0:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f0100bf6:	8b 43 14             	mov    0x14(%ebx),%eax
f0100bf9:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f0100bff:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f0100c02:	c7 04 24 cb 73 10 f0 	movl   $0xf01073cb,(%esp)
f0100c09:	e8 e8 39 00 00       	call   f01045f6 <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100c0e:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100c13:	85 db                	test   %ebx,%ebx
f0100c15:	0f 84 f5 00 00 00    	je     f0100d10 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f0100c1b:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100c21:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f0100c27:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f0100c2d:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100c33:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f0100c37:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100c3b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100c3f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c43:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c4d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100c51:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c55:	c7 04 24 1c 76 10 f0 	movl   $0xf010761c,(%esp)
f0100c5c:	e8 95 39 00 00       	call   f01045f6 <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100c61:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c68:	89 1c 24             	mov    %ebx,(%esp)
f0100c6b:	e8 36 49 00 00       	call   f01055a6 <debuginfo_eip>
f0100c70:	85 c0                	test   %eax,%eax
f0100c72:	0f 88 93 00 00 00    	js     f0100d0b <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100c78:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100c85:	89 04 24             	mov    %eax,(%esp)
f0100c88:	e8 3e 54 00 00       	call   f01060cb <strcpy>

		int eip_line = info.eip_line;
f0100c8d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c90:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f0100c96:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c99:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ca4:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f0100ca7:	89 3c 24             	mov    %edi,(%esp)
f0100caa:	e8 67 54 00 00       	call   f0106116 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100caf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cb2:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f0100cb7:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100cba:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100cbe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100cc2:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100cc8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ccc:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cd6:	c7 04 24 dd 73 10 f0 	movl   $0xf01073dd,(%esp)
f0100cdd:	e8 14 39 00 00       	call   f01045f6 <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f0100ce2:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f0100ce4:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f0100ce7:	8b 46 08             	mov    0x8(%esi),%eax
f0100cea:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f0100cf0:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f0100cf3:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f0100cf6:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f0100cf9:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100cfc:	85 f6                	test   %esi,%esi
f0100cfe:	0f 85 2f ff ff ff    	jne    f0100c33 <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100d04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d09:	eb 05                	jmp    f0100d10 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f0100d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f0100d10:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f0100d16:	5b                   	pop    %ebx
f0100d17:	5e                   	pop    %esi
f0100d18:	5f                   	pop    %edi
f0100d19:	5d                   	pop    %ebp
f0100d1a:	c3                   	ret    

f0100d1b <mon_dump>:
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100d1b:	55                   	push   %ebp
f0100d1c:	89 e5                	mov    %esp,%ebp
f0100d1e:	57                   	push   %edi
f0100d1f:	56                   	push   %esi
f0100d20:	53                   	push   %ebx
f0100d21:	83 ec 3c             	sub    $0x3c,%esp
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
f0100d24:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d28:	0f 85 ea 02 00 00    	jne    f0101018 <mon_dump+0x2fd>
		return -1;
	
	unsigned int addr = strtol(argv[2], NULL, 16);
f0100d2e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d35:	00 
f0100d36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d3d:	00 
f0100d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d41:	8b 42 08             	mov    0x8(%edx),%eax
f0100d44:	89 04 24             	mov    %eax,(%esp)
f0100d47:	e8 88 56 00 00       	call   f01063d4 <strtol>
f0100d4c:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100d4e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d55:	00 
f0100d56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d5d:	00 
f0100d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d61:	8b 42 0c             	mov    0xc(%edx),%eax
f0100d64:	89 04 24             	mov    %eax,(%esp)
f0100d67:	e8 68 56 00 00       	call   f01063d4 <strtol>
f0100d6c:	89 45 d0             	mov    %eax,-0x30(%ebp)

	if(argv[1][1] == 'v') {
f0100d6f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d72:	8b 42 04             	mov    0x4(%edx),%eax
f0100d75:	80 78 01 76          	cmpb   $0x76,0x1(%eax)
f0100d79:	0f 85 af 00 00 00    	jne    f0100e2e <mon_dump+0x113>
		int i;
		for(i=0; i<len; i++) {
f0100d7f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100d83:	0f 84 a5 00 00 00    	je     f0100e2e <mon_dump+0x113>
f0100d89:	89 df                	mov    %ebx,%edi
f0100d8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d90:	be 00 00 00 00       	mov    $0x0,%esi
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100d95:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100d98:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100d9b:	a8 03                	test   $0x3,%al
f0100d9d:	75 10                	jne    f0100daf <mon_dump+0x94>
				cprintf("Virtual Address 0x%08x: ", addr + i*4);
f0100d9f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100da3:	c7 04 24 f4 73 10 f0 	movl   $0xf01073f4,(%esp)
f0100daa:	e8 47 38 00 00       	call   f01045f6 <cprintf>

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100daf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100db2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100db6:	89 f8                	mov    %edi,%eax
f0100db8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
f0100dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dc1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0100dc6:	89 04 24             	mov    %eax,(%esp)
f0100dc9:	e8 7b 0b 00 00       	call   f0101949 <page_lookup>
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
			if(_pte && (*(pte_t *)_pte&PTE_P))
f0100dce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dd1:	85 c0                	test   %eax,%eax
f0100dd3:	74 19                	je     f0100dee <mon_dump+0xd3>
f0100dd5:	f6 00 01             	testb  $0x1,(%eax)
f0100dd8:	74 14                	je     f0100dee <mon_dump+0xd3>
				cprintf("0x%08x ", *(uint32_t *)(addr + i*4));
f0100dda:	8b 07                	mov    (%edi),%eax
f0100ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100de0:	c7 04 24 0d 74 10 f0 	movl   $0xf010740d,(%esp)
f0100de7:	e8 0a 38 00 00       	call   f01045f6 <cprintf>
f0100dec:	eb 0c                	jmp    f0100dfa <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100dee:	c7 04 24 15 74 10 f0 	movl   $0xf0107415,(%esp)
f0100df5:	e8 fc 37 00 00       	call   f01045f6 <cprintf>
			if(i % 4 == 3)
f0100dfa:	89 f0                	mov    %esi,%eax
f0100dfc:	c1 f8 1f             	sar    $0x1f,%eax
f0100dff:	c1 e8 1e             	shr    $0x1e,%eax
f0100e02:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100e05:	83 e2 03             	and    $0x3,%edx
f0100e08:	29 c2                	sub    %eax,%edx
f0100e0a:	83 fa 03             	cmp    $0x3,%edx
f0100e0d:	75 0c                	jne    f0100e1b <mon_dump+0x100>
				cprintf("\n");
f0100e0f:	c7 04 24 30 87 10 f0 	movl   $0xf0108730,(%esp)
f0100e16:	e8 db 37 00 00       	call   f01045f6 <cprintf>
	unsigned int addr = strtol(argv[2], NULL, 16);
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
f0100e1b:	83 c6 01             	add    $0x1,%esi
f0100e1e:	89 f0                	mov    %esi,%eax
f0100e20:	83 c7 04             	add    $0x4,%edi
f0100e23:	39 de                	cmp    %ebx,%esi
f0100e25:	0f 85 70 ff ff ff    	jne    f0100d9b <mon_dump+0x80>
f0100e2b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e31:	8b 50 04             	mov    0x4(%eax),%edx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100e34:	b8 00 00 00 00       	mov    $0x0,%eax
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100e39:	80 7a 01 70          	cmpb   $0x70,0x1(%edx)
f0100e3d:	0f 85 e1 01 00 00    	jne    f0101024 <mon_dump+0x309>
		int i;
		for(i=0; i<len; i++) {
f0100e43:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100e47:	0f 84 d2 01 00 00    	je     f010101f <mon_dump+0x304>
f0100e4d:	be 00 00 00 00       	mov    $0x0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e52:	bf 00 80 11 f0       	mov    $0xf0118000,%edi
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100e57:	89 fa                	mov    %edi,%edx
f0100e59:	f7 da                	neg    %edx
f0100e5b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100e5e:	a8 03                	test   $0x3,%al
f0100e60:	75 10                	jne    f0100e72 <mon_dump+0x157>
				cprintf("Physical Address 0x%08x: ", addr + i*4);
f0100e62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e66:	c7 04 24 1b 74 10 f0 	movl   $0xf010741b,(%esp)
f0100e6d:	e8 84 37 00 00       	call   f01045f6 <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100e72:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100e77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e7c:	77 20                	ja     f0100e9e <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e82:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0100e89:	f0 
f0100e8a:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100e91:	00 
f0100e92:	c7 04 24 35 74 10 f0 	movl   $0xf0107435,(%esp)
f0100e99:	e8 a2 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e9e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100ea4:	39 d3                	cmp    %edx,%ebx
f0100ea6:	0f 82 83 00 00 00    	jb     f0100f2f <mon_dump+0x214>
f0100eac:	8d 90 00 00 40 00    	lea    0x400000(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100eb2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100eb8:	77 20                	ja     f0100eda <mon_dump+0x1bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100eba:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ebe:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0100ec5:	f0 
f0100ec6:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100ecd:	00 
f0100ece:	c7 04 24 35 74 10 f0 	movl   $0xf0107435,(%esp)
f0100ed5:	e8 66 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100eda:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100ee0:	39 d3                	cmp    %edx,%ebx
f0100ee2:	73 4b                	jae    f0100f2f <mon_dump+0x214>
				cprintf("0x%08x ", *(uint32_t *)(_addr - PADDR((void *)pages + UPAGES)));
f0100ee4:	2d 00 00 00 11       	sub    $0x11000000,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ee9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100eee:	77 20                	ja     f0100f10 <mon_dump+0x1f5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ef0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ef4:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0100efb:	f0 
f0100efc:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0100f03:	00 
f0100f04:	c7 04 24 35 74 10 f0 	movl   $0xf0107435,(%esp)
f0100f0b:	e8 30 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f10:	89 da                	mov    %ebx,%edx
f0100f12:	29 c2                	sub    %eax,%edx
f0100f14:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f1e:	c7 04 24 0d 74 10 f0 	movl   $0xf010740d,(%esp)
f0100f25:	e8 cc 36 00 00       	call   f01045f6 <cprintf>
f0100f2a:	e9 b0 00 00 00       	jmp    f0100fdf <mon_dump+0x2c4>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f2f:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100f35:	77 24                	ja     f0100f5b <mon_dump+0x240>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f37:	c7 44 24 0c 00 80 11 	movl   $0xf0118000,0xc(%esp)
f0100f3e:	f0 
f0100f3f:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0100f46:	f0 
f0100f47:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f4e:	00 
f0100f4f:	c7 04 24 35 74 10 f0 	movl   $0xf0107435,(%esp)
f0100f56:	e8 e5 f0 ff ff       	call   f0100040 <_panic>
			else if(_addr >= PADDR((void *)bootstack) && _addr < PADDR((void *)bootstack + KSTKSIZE))
f0100f5b:	81 fb 00 80 11 00    	cmp    $0x118000,%ebx
f0100f61:	72 50                	jb     f0100fb3 <mon_dump+0x298>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f63:	b8 00 00 12 f0       	mov    $0xf0120000,%eax
f0100f68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f6d:	77 20                	ja     f0100f8f <mon_dump+0x274>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f73:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0100f7a:	f0 
f0100f7b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f82:	00 
f0100f83:	c7 04 24 35 74 10 f0 	movl   $0xf0107435,(%esp)
f0100f8a:	e8 b1 f0 ff ff       	call   f0100040 <_panic>
f0100f8f:	81 fb 00 00 12 00    	cmp    $0x120000,%ebx
f0100f95:	73 1c                	jae    f0100fb3 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100f97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f9a:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa5:	c7 04 24 0d 74 10 f0 	movl   $0xf010740d,(%esp)
f0100fac:	e8 45 36 00 00       	call   f01045f6 <cprintf>
f0100fb1:	eb 2c                	jmp    f0100fdf <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100fb3:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100fb9:	77 18                	ja     f0100fd3 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100fbb:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fc5:	c7 04 24 0d 74 10 f0 	movl   $0xf010740d,(%esp)
f0100fcc:	e8 25 36 00 00       	call   f01045f6 <cprintf>
f0100fd1:	eb 0c                	jmp    f0100fdf <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0100fd3:	c7 04 24 15 74 10 f0 	movl   $0xf0107415,(%esp)
f0100fda:	e8 17 36 00 00       	call   f01045f6 <cprintf>
			if(i % 4 == 3)
f0100fdf:	89 f0                	mov    %esi,%eax
f0100fe1:	c1 f8 1f             	sar    $0x1f,%eax
f0100fe4:	c1 e8 1e             	shr    $0x1e,%eax
f0100fe7:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100fea:	83 e2 03             	and    $0x3,%edx
f0100fed:	29 c2                	sub    %eax,%edx
f0100fef:	83 fa 03             	cmp    $0x3,%edx
f0100ff2:	75 0c                	jne    f0101000 <mon_dump+0x2e5>
				cprintf("\n");
f0100ff4:	c7 04 24 30 87 10 f0 	movl   $0xf0108730,(%esp)
f0100ffb:	e8 f6 35 00 00       	call   f01045f6 <cprintf>
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
f0101000:	83 c6 01             	add    $0x1,%esi
f0101003:	89 f0                	mov    %esi,%eax
f0101005:	83 c3 04             	add    $0x4,%ebx
f0101008:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f010100b:	0f 85 4d fe ff ff    	jne    f0100e5e <mon_dump+0x143>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0101011:	b8 00 00 00 00       	mov    $0x0,%eax
f0101016:	eb 0c                	jmp    f0101024 <mon_dump+0x309>
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
		return -1;
f0101018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010101d:	eb 05                	jmp    f0101024 <mon_dump+0x309>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f010101f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101024:	83 c4 3c             	add    $0x3c,%esp
f0101027:	5b                   	pop    %ebx
f0101028:	5e                   	pop    %esi
f0101029:	5f                   	pop    %edi
f010102a:	5d                   	pop    %ebp
f010102b:	c3                   	ret    

f010102c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010102c:	55                   	push   %ebp
f010102d:	89 e5                	mov    %esp,%ebp
f010102f:	57                   	push   %edi
f0101030:	56                   	push   %esi
f0101031:	53                   	push   %ebx
f0101032:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;


	cprintf("Welcome to the JOS kernel monitor!\n");
f0101035:	c7 04 24 50 76 10 f0 	movl   $0xf0107650,(%esp)
f010103c:	e8 b5 35 00 00       	call   f01045f6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101041:	c7 04 24 74 76 10 f0 	movl   $0xf0107674,(%esp)
f0101048:	e8 a9 35 00 00       	call   f01045f6 <cprintf>

	if (tf != NULL)
f010104d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101051:	74 0b                	je     f010105e <monitor+0x32>
		print_trapframe(tf);
f0101053:	8b 45 08             	mov    0x8(%ebp),%eax
f0101056:	89 04 24             	mov    %eax,(%esp)
f0101059:	e8 18 38 00 00       	call   f0104876 <print_trapframe>

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f010105e:	c7 04 24 9c 76 10 f0 	movl   $0xf010769c,(%esp)
f0101065:	e8 8c 35 00 00       	call   f01045f6 <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f010106a:	c7 04 24 d0 76 10 f0 	movl   $0xf01076d0,(%esp)
f0101071:	e8 80 35 00 00       	call   f01045f6 <cprintf>
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);


	while (1) {
		buf = readline("K> ");
f0101076:	c7 04 24 44 74 10 f0 	movl   $0xf0107444,(%esp)
f010107d:	e8 2e 4f 00 00       	call   f0105fb0 <readline>
f0101082:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101084:	85 c0                	test   %eax,%eax
f0101086:	74 ee                	je     f0101076 <monitor+0x4a>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0101088:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010108f:	be 00 00 00 00       	mov    $0x0,%esi
f0101094:	eb 06                	jmp    f010109c <monitor+0x70>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101096:	c6 03 00             	movb   $0x0,(%ebx)
f0101099:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010109c:	0f b6 03             	movzbl (%ebx),%eax
f010109f:	84 c0                	test   %al,%al
f01010a1:	74 6a                	je     f010110d <monitor+0xe1>
f01010a3:	0f be c0             	movsbl %al,%eax
f01010a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010aa:	c7 04 24 48 74 10 f0 	movl   $0xf0107448,(%esp)
f01010b1:	e8 50 51 00 00       	call   f0106206 <strchr>
f01010b6:	85 c0                	test   %eax,%eax
f01010b8:	75 dc                	jne    f0101096 <monitor+0x6a>
			*buf++ = 0;
		if (*buf == 0)
f01010ba:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010bd:	74 4e                	je     f010110d <monitor+0xe1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01010bf:	83 fe 0f             	cmp    $0xf,%esi
f01010c2:	75 16                	jne    f01010da <monitor+0xae>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01010c4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01010cb:	00 
f01010cc:	c7 04 24 4d 74 10 f0 	movl   $0xf010744d,(%esp)
f01010d3:	e8 1e 35 00 00       	call   f01045f6 <cprintf>
f01010d8:	eb 9c                	jmp    f0101076 <monitor+0x4a>
			return 0;
		}
		argv[argc++] = buf;
f01010da:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01010de:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01010e1:	0f b6 03             	movzbl (%ebx),%eax
f01010e4:	84 c0                	test   %al,%al
f01010e6:	75 0c                	jne    f01010f4 <monitor+0xc8>
f01010e8:	eb b2                	jmp    f010109c <monitor+0x70>
			buf++;
f01010ea:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01010ed:	0f b6 03             	movzbl (%ebx),%eax
f01010f0:	84 c0                	test   %al,%al
f01010f2:	74 a8                	je     f010109c <monitor+0x70>
f01010f4:	0f be c0             	movsbl %al,%eax
f01010f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010fb:	c7 04 24 48 74 10 f0 	movl   $0xf0107448,(%esp)
f0101102:	e8 ff 50 00 00       	call   f0106206 <strchr>
f0101107:	85 c0                	test   %eax,%eax
f0101109:	74 df                	je     f01010ea <monitor+0xbe>
f010110b:	eb 8f                	jmp    f010109c <monitor+0x70>
			buf++;
	}
	argv[argc] = 0;
f010110d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101114:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101115:	85 f6                	test   %esi,%esi
f0101117:	0f 84 59 ff ff ff    	je     f0101076 <monitor+0x4a>
f010111d:	bb 40 78 10 f0       	mov    $0xf0107840,%ebx
f0101122:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101127:	8b 03                	mov    (%ebx),%eax
f0101129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010112d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101130:	89 04 24             	mov    %eax,(%esp)
f0101133:	e8 53 50 00 00       	call   f010618b <strcmp>
f0101138:	85 c0                	test   %eax,%eax
f010113a:	75 24                	jne    f0101160 <monitor+0x134>
			return commands[i].func(argc, argv, tf);
f010113c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010113f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101142:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101146:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101149:	89 54 24 04          	mov    %edx,0x4(%esp)
f010114d:	89 34 24             	mov    %esi,(%esp)
f0101150:	ff 14 85 48 78 10 f0 	call   *-0xfef87b8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101157:	85 c0                	test   %eax,%eax
f0101159:	78 28                	js     f0101183 <monitor+0x157>
f010115b:	e9 16 ff ff ff       	jmp    f0101076 <monitor+0x4a>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0101160:	83 c7 01             	add    $0x1,%edi
f0101163:	83 c3 0c             	add    $0xc,%ebx
f0101166:	83 ff 06             	cmp    $0x6,%edi
f0101169:	75 bc                	jne    f0101127 <monitor+0xfb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010116b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010116e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101172:	c7 04 24 6a 74 10 f0 	movl   $0xf010746a,(%esp)
f0101179:	e8 78 34 00 00       	call   f01045f6 <cprintf>
f010117e:	e9 f3 fe ff ff       	jmp    f0101076 <monitor+0x4a>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101183:	83 c4 5c             	add    $0x5c,%esp
f0101186:	5b                   	pop    %ebx
f0101187:	5e                   	pop    %esi
f0101188:	5f                   	pop    %edi
f0101189:	5d                   	pop    %ebp
f010118a:	c3                   	ret    
f010118b:	00 00                	add    %al,(%eax)
f010118d:	00 00                	add    %al,(%eax)
	...

f0101190 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101190:	55                   	push   %ebp
f0101191:	89 e5                	mov    %esp,%ebp
f0101193:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101196:	89 d1                	mov    %edx,%ecx
f0101198:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010119b:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f010119e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01011a3:	f6 c1 01             	test   $0x1,%cl
f01011a6:	74 57                	je     f01011ff <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01011a8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011ae:	89 c8                	mov    %ecx,%eax
f01011b0:	c1 e8 0c             	shr    $0xc,%eax
f01011b3:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01011b9:	72 20                	jb     f01011db <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01011bf:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01011c6:	f0 
f01011c7:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01011ce:	00 
f01011cf:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01011d6:	e8 65 ee ff ff       	call   f0100040 <_panic>
	//cprintf("**%x\n", p);
	if (!(p[PTX(va)] & PTE_P))
f01011db:	c1 ea 0c             	shr    $0xc,%edx
f01011de:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01011e4:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f01011eb:	89 c2                	mov    %eax,%edx
f01011ed:	83 e2 01             	and    $0x1,%edx
		return ~0;
	//cprintf("**%x\n\n", p[PTX(va)]);
	return PTE_ADDR(p[PTX(va)]);
f01011f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011f5:	85 d2                	test   %edx,%edx
f01011f7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01011fc:	0f 44 c2             	cmove  %edx,%eax
}
f01011ff:	c9                   	leave  
f0101200:	c3                   	ret    

f0101201 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101201:	55                   	push   %ebp
f0101202:	89 e5                	mov    %esp,%ebp
f0101204:	53                   	push   %ebx
f0101205:	83 ec 14             	sub    $0x14,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101208:	83 3d 3c b2 22 f0 00 	cmpl   $0x0,0xf022b23c
f010120f:	75 11                	jne    f0101222 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101211:	ba 07 e0 26 f0       	mov    $0xf026e007,%edx
f0101216:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010121c:	89 15 3c b2 22 f0    	mov    %edx,0xf022b23c
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f0101222:	83 3d 00 23 12 f0 ff 	cmpl   $0xffffffff,0xf0122300
f0101229:	75 0c                	jne    f0101237 <boot_alloc+0x36>
		npages_left = npages;
f010122b:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f0101231:	89 15 00 23 12 f0    	mov    %edx,0xf0122300
		panic("The size of space requested is below 0!\n");
		return NULL;
	}
	// if n==0, returns the address of the next free page without allocating
	// anything.
	if (n == 0) {
f0101237:	85 c0                	test   %eax,%eax
f0101239:	75 2c                	jne    f0101267 <boot_alloc+0x66>
// !- Whether I should check here -!
		if(npages_left < 1) {
f010123b:	83 3d 00 23 12 f0 00 	cmpl   $0x0,0xf0122300
f0101242:	75 1c                	jne    f0101260 <boot_alloc+0x5f>
			panic("Out of memory!\n");
f0101244:	c7 44 24 08 a1 81 10 	movl   $0xf01081a1,0x8(%esp)
f010124b:	f0 
f010124c:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0101253:	00 
f0101254:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010125b:	e8 e0 ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f0101260:	a1 3c b2 22 f0       	mov    0xf022b23c,%eax
f0101265:	eb 4d                	jmp    f01012b4 <boot_alloc+0xb3>
	}
	// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
	// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
	else if (n > 0) {
		size_t srequest = (size_t)ROUNDUP((char *)n, PGSIZE);
f0101267:	05 ff 0f 00 00       	add    $0xfff,%eax
f010126c:	89 c3                	mov    %eax,%ebx
f010126e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

		if(npages_left < srequest/PGSIZE) {
f0101274:	89 da                	mov    %ebx,%edx
f0101276:	c1 ea 0c             	shr    $0xc,%edx
f0101279:	8b 0d 00 23 12 f0    	mov    0xf0122300,%ecx
f010127f:	39 ca                	cmp    %ecx,%edx
f0101281:	76 1c                	jbe    f010129f <boot_alloc+0x9e>
			panic("Out of memory!\n");
f0101283:	c7 44 24 08 a1 81 10 	movl   $0xf01081a1,0x8(%esp)
f010128a:	f0 
f010128b:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
f0101292:	00 
f0101293:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010129a:	e8 a1 ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f010129f:	a1 3c b2 22 f0       	mov    0xf022b23c,%eax
		nextfree += srequest;
f01012a4:	01 c3                	add    %eax,%ebx
f01012a6:	89 1d 3c b2 22 f0    	mov    %ebx,0xf022b23c
		npages_left -= srequest/PGSIZE;
f01012ac:	29 d1                	sub    %edx,%ecx
f01012ae:	89 0d 00 23 12 f0    	mov    %ecx,0xf0122300

	// Make sure nextfree is kept aligned to a multiple of PGSIZE;
	//nextfree = ROUNDUP((char *) nextfree, PGSIZE);
	return result;
	//******************************My code ends***********************************//
}
f01012b4:	83 c4 14             	add    $0x14,%esp
f01012b7:	5b                   	pop    %ebx
f01012b8:	5d                   	pop    %ebp
f01012b9:	c3                   	ret    

f01012ba <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01012ba:	55                   	push   %ebp
f01012bb:	89 e5                	mov    %esp,%ebp
f01012bd:	83 ec 18             	sub    $0x18,%esp
f01012c0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01012c3:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01012c6:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012c8:	89 04 24             	mov    %eax,(%esp)
f01012cb:	e8 bc 31 00 00       	call   f010448c <mc146818_read>
f01012d0:	89 c6                	mov    %eax,%esi
f01012d2:	83 c3 01             	add    $0x1,%ebx
f01012d5:	89 1c 24             	mov    %ebx,(%esp)
f01012d8:	e8 af 31 00 00       	call   f010448c <mc146818_read>
f01012dd:	c1 e0 08             	shl    $0x8,%eax
f01012e0:	09 f0                	or     %esi,%eax
}
f01012e2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01012e5:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01012e8:	89 ec                	mov    %ebp,%esp
f01012ea:	5d                   	pop    %ebp
f01012eb:	c3                   	ret    

f01012ec <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01012ec:	55                   	push   %ebp
f01012ed:	89 e5                	mov    %esp,%ebp
f01012ef:	57                   	push   %edi
f01012f0:	56                   	push   %esi
f01012f1:	53                   	push   %ebx
f01012f2:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012f5:	3c 01                	cmp    $0x1,%al
f01012f7:	19 f6                	sbb    %esi,%esi
f01012f9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01012ff:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101302:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0101308:	85 db                	test   %ebx,%ebx
f010130a:	75 1c                	jne    f0101328 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f010130c:	c7 44 24 08 88 78 10 	movl   $0xf0107888,0x8(%esp)
f0101313:	f0 
f0101314:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f010131b:	00 
f010131c:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101323:	e8 18 ed ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0101328:	84 c0                	test   %al,%al
f010132a:	74 50                	je     f010137c <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010132c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010132f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101332:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101335:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101338:	89 d8                	mov    %ebx,%eax
f010133a:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101340:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101343:	c1 e8 16             	shr    $0x16,%eax
f0101346:	39 c6                	cmp    %eax,%esi
f0101348:	0f 96 c0             	setbe  %al
f010134b:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010134e:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101352:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101354:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101358:	8b 1b                	mov    (%ebx),%ebx
f010135a:	85 db                	test   %ebx,%ebx
f010135c:	75 da                	jne    f0101338 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010135e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101361:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101367:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010136a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010136d:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010136f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101372:	89 1d 40 b2 22 f0    	mov    %ebx,0xf022b240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101378:	85 db                	test   %ebx,%ebx
f010137a:	74 67                	je     f01013e3 <check_page_free_list+0xf7>
f010137c:	89 d8                	mov    %ebx,%eax
f010137e:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101384:	c1 f8 03             	sar    $0x3,%eax
f0101387:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010138a:	89 c2                	mov    %eax,%edx
f010138c:	c1 ea 16             	shr    $0x16,%edx
f010138f:	39 d6                	cmp    %edx,%esi
f0101391:	76 4a                	jbe    f01013dd <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101393:	89 c2                	mov    %eax,%edx
f0101395:	c1 ea 0c             	shr    $0xc,%edx
f0101398:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010139e:	72 20                	jb     f01013c0 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013a4:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01013ab:	f0 
f01013ac:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01013b3:	00 
f01013b4:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f01013bb:	e8 80 ec ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01013c0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01013c7:	00 
f01013c8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01013cf:	00 
	return (void *)(pa + KERNBASE);
f01013d0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013d5:	89 04 24             	mov    %eax,(%esp)
f01013d8:	e8 84 4e 00 00       	call   f0106261 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013dd:	8b 1b                	mov    (%ebx),%ebx
f01013df:	85 db                	test   %ebx,%ebx
f01013e1:	75 99                	jne    f010137c <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01013e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01013e8:	e8 14 fe ff ff       	call   f0101201 <boot_alloc>
f01013ed:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01013f0:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f01013f6:	85 d2                	test   %edx,%edx
f01013f8:	0f 84 2f 02 00 00    	je     f010162d <check_page_free_list+0x341>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01013fe:	8b 1d 90 be 22 f0    	mov    0xf022be90,%ebx
f0101404:	39 da                	cmp    %ebx,%edx
f0101406:	72 51                	jb     f0101459 <check_page_free_list+0x16d>
		assert(pp < pages + npages);
f0101408:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f010140d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101410:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101413:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101416:	39 c2                	cmp    %eax,%edx
f0101418:	73 68                	jae    f0101482 <check_page_free_list+0x196>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010141a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010141d:	89 d0                	mov    %edx,%eax
f010141f:	29 d8                	sub    %ebx,%eax
f0101421:	a8 07                	test   $0x7,%al
f0101423:	0f 85 86 00 00 00    	jne    f01014af <check_page_free_list+0x1c3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101429:	c1 f8 03             	sar    $0x3,%eax
f010142c:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010142f:	85 c0                	test   %eax,%eax
f0101431:	0f 84 a6 00 00 00    	je     f01014dd <check_page_free_list+0x1f1>
		assert(page2pa(pp) != IOPHYSMEM);
f0101437:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010143c:	0f 84 c6 00 00 00    	je     f0101508 <check_page_free_list+0x21c>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101442:	be 00 00 00 00       	mov    $0x0,%esi
f0101447:	bf 00 00 00 00       	mov    $0x0,%edi
f010144c:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f010144f:	e9 d8 00 00 00       	jmp    f010152c <check_page_free_list+0x240>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101454:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0101457:	73 24                	jae    f010147d <check_page_free_list+0x191>
f0101459:	c7 44 24 0c bf 81 10 	movl   $0xf01081bf,0xc(%esp)
f0101460:	f0 
f0101461:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101468:	f0 
f0101469:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101470:	00 
f0101471:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101478:	e8 c3 eb ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010147d:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101480:	72 24                	jb     f01014a6 <check_page_free_list+0x1ba>
f0101482:	c7 44 24 0c e0 81 10 	movl   $0xf01081e0,0xc(%esp)
f0101489:	f0 
f010148a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101491:	f0 
f0101492:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101499:	00 
f010149a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01014a1:	e8 9a eb ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01014a6:	89 d0                	mov    %edx,%eax
f01014a8:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01014ab:	a8 07                	test   $0x7,%al
f01014ad:	74 24                	je     f01014d3 <check_page_free_list+0x1e7>
f01014af:	c7 44 24 0c ac 78 10 	movl   $0xf01078ac,0xc(%esp)
f01014b6:	f0 
f01014b7:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f01014c6:	00 
f01014c7:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01014ce:	e8 6d eb ff ff       	call   f0100040 <_panic>
f01014d3:	c1 f8 03             	sar    $0x3,%eax
f01014d6:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01014d9:	85 c0                	test   %eax,%eax
f01014db:	75 24                	jne    f0101501 <check_page_free_list+0x215>
f01014dd:	c7 44 24 0c f4 81 10 	movl   $0xf01081f4,0xc(%esp)
f01014e4:	f0 
f01014e5:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01014ec:	f0 
f01014ed:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01014f4:	00 
f01014f5:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01014fc:	e8 3f eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101501:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101506:	75 24                	jne    f010152c <check_page_free_list+0x240>
f0101508:	c7 44 24 0c 05 82 10 	movl   $0xf0108205,0xc(%esp)
f010150f:	f0 
f0101510:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101517:	f0 
f0101518:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f010151f:	00 
f0101520:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101527:	e8 14 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010152c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101531:	75 24                	jne    f0101557 <check_page_free_list+0x26b>
f0101533:	c7 44 24 0c e0 78 10 	movl   $0xf01078e0,0xc(%esp)
f010153a:	f0 
f010153b:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101542:	f0 
f0101543:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f010154a:	00 
f010154b:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101552:	e8 e9 ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101557:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010155c:	75 24                	jne    f0101582 <check_page_free_list+0x296>
f010155e:	c7 44 24 0c 1e 82 10 	movl   $0xf010821e,0xc(%esp)
f0101565:	f0 
f0101566:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010156d:	f0 
f010156e:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101575:	00 
f0101576:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010157d:	e8 be ea ff ff       	call   f0100040 <_panic>
f0101582:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101584:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101589:	76 59                	jbe    f01015e4 <check_page_free_list+0x2f8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010158b:	89 c3                	mov    %eax,%ebx
f010158d:	c1 eb 0c             	shr    $0xc,%ebx
f0101590:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101593:	77 20                	ja     f01015b5 <check_page_free_list+0x2c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101595:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101599:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01015a0:	f0 
f01015a1:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01015a8:	00 
f01015a9:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f01015b0:	e8 8b ea ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01015b5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01015bb:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01015be:	76 24                	jbe    f01015e4 <check_page_free_list+0x2f8>
f01015c0:	c7 44 24 0c 04 79 10 	movl   $0xf0107904,0xc(%esp)
f01015c7:	f0 
f01015c8:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01015cf:	f0 
f01015d0:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f01015d7:	00 
f01015d8:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01015df:	e8 5c ea ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01015e4:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01015e9:	75 24                	jne    f010160f <check_page_free_list+0x323>
f01015eb:	c7 44 24 0c 38 82 10 	movl   $0xf0108238,0xc(%esp)
f01015f2:	f0 
f01015f3:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101602:	00 
f0101603:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010160a:	e8 31 ea ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010160f:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101615:	77 05                	ja     f010161c <check_page_free_list+0x330>
			++nfree_basemem;
f0101617:	83 c7 01             	add    $0x1,%edi
f010161a:	eb 03                	jmp    f010161f <check_page_free_list+0x333>
		else
			++nfree_extmem;
f010161c:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010161f:	8b 12                	mov    (%edx),%edx
f0101621:	85 d2                	test   %edx,%edx
f0101623:	0f 85 2b fe ff ff    	jne    f0101454 <check_page_free_list+0x168>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101629:	85 ff                	test   %edi,%edi
f010162b:	7f 24                	jg     f0101651 <check_page_free_list+0x365>
f010162d:	c7 44 24 0c 55 82 10 	movl   $0xf0108255,0xc(%esp)
f0101634:	f0 
f0101635:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010163c:	f0 
f010163d:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101644:	00 
f0101645:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101651:	85 f6                	test   %esi,%esi
f0101653:	7f 24                	jg     f0101679 <check_page_free_list+0x38d>
f0101655:	c7 44 24 0c 67 82 10 	movl   $0xf0108267,0xc(%esp)
f010165c:	f0 
f010165d:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101664:	f0 
f0101665:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f010166c:	00 
f010166d:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101674:	e8 c7 e9 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101679:	c7 04 24 4c 79 10 f0 	movl   $0xf010794c,(%esp)
f0101680:	e8 71 2f 00 00       	call   f01045f6 <cprintf>
}
f0101685:	83 c4 4c             	add    $0x4c,%esp
f0101688:	5b                   	pop    %ebx
f0101689:	5e                   	pop    %esi
f010168a:	5f                   	pop    %edi
f010168b:	5d                   	pop    %ebp
f010168c:	c3                   	ret    

f010168d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010168d:	55                   	push   %ebp
f010168e:	89 e5                	mov    %esp,%ebp
f0101690:	57                   	push   %edi
f0101691:	56                   	push   %esi
f0101692:	53                   	push   %ebx
f0101693:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101696:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f010169d:	0f 85 a5 00 00 00    	jne    f0101748 <page_init+0xbb>
f01016a3:	e9 b2 00 00 00       	jmp    f010175a <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f01016a8:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f01016ad:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f01016b4:	8d 3c 30             	lea    (%eax,%esi,1),%edi
f01016b7:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

		// 1) Mark physical page 0 as in use.
		//    This way we preserve the real-mode IDT and BIOS structures
		//    in case we ever need them.  (Currently we don't, but...)
		if(i == 0) {
f01016bd:	85 db                	test   %ebx,%ebx
f01016bf:	74 76                	je     f0101737 <page_init+0xaa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016c1:	29 c7                	sub    %eax,%edi
f01016c3:	c1 ff 03             	sar    $0x3,%edi
f01016c6:	c1 e7 0c             	shl    $0xc,%edi
		// 4) Then extended memory [EXTPHYSMEM, ...).
		// extended memory: 0x100000~
		//   0x100000~0x115000 is allocated to kernel(0x115000 is the end of .bss segment)
		//   0x115000~0x116000 is for kern_pgdir.
		//   0x116000~... is for pages (amount is 33)
		if(page2pa(&pages[i]) >= IOPHYSMEM
f01016c9:	81 ff ff ff 09 00    	cmp    $0x9ffff,%edi
f01016cf:	76 3f                	jbe    f0101710 <page_init+0x83>
			&& page2pa(&pages[i]) < ROUNDUP(PADDR(boot_alloc(0)), PGSIZE)) {	
f01016d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d6:	e8 26 fb ff ff       	call   f0101201 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01016db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016e0:	77 20                	ja     f0101702 <page_init+0x75>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01016e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016e6:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f01016ed:	f0 
f01016ee:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f01016f5:	00 
f01016f6:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01016fd:	e8 3e e9 ff ff       	call   f0100040 <_panic>
f0101702:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0101707:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010170c:	39 f8                	cmp    %edi,%eax
f010170e:	77 27                	ja     f0101737 <page_init+0xaa>
			continue;	
		}
		
		if(page2pa(&pages[i]) == MPENTRY_PADDR)
f0101710:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0101716:	01 f2                	add    %esi,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101718:	89 f0                	mov    %esi,%eax
f010171a:	c1 e0 09             	shl    $0x9,%eax
f010171d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101722:	74 13                	je     f0101737 <page_init+0xaa>
			continue;
		// others is free
		pages[i].pp_link = page_free_list;
f0101724:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101729:	89 02                	mov    %eax,(%edx)
		page_free_list = &pages[i];
f010172b:	03 35 90 be 22 f0    	add    0xf022be90,%esi
f0101731:	89 35 40 b2 22 f0    	mov    %esi,0xf022b240
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101737:	83 c3 01             	add    $0x1,%ebx
f010173a:	39 1d 88 be 22 f0    	cmp    %ebx,0xf022be88
f0101740:	0f 87 62 ff ff ff    	ja     f01016a8 <page_init+0x1b>
f0101746:	eb 12                	jmp    f010175a <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f0101748:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f010174d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101753:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101758:	eb dd                	jmp    f0101737 <page_init+0xaa>
			continue;
		// others is free
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f010175a:	83 c4 1c             	add    $0x1c,%esp
f010175d:	5b                   	pop    %ebx
f010175e:	5e                   	pop    %esi
f010175f:	5f                   	pop    %edi
f0101760:	5d                   	pop    %ebp
f0101761:	c3                   	ret    

f0101762 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101762:	55                   	push   %ebp
f0101763:	89 e5                	mov    %esp,%ebp
f0101765:	53                   	push   %ebx
f0101766:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in

	// If (alloc_flags & ALLOC_ZERO), fills the entire
	// returned physical page with '\0' bytes.
	struct PageInfo *result = NULL;
	if(page_free_list) {
f0101769:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f010176f:	85 db                	test   %ebx,%ebx
f0101771:	74 65                	je     f01017d8 <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101773:	8b 03                	mov    (%ebx),%eax
f0101775:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
		
		if(alloc_flags & ALLOC_ZERO) { 
f010177a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010177e:	74 58                	je     f01017d8 <page_alloc+0x76>
f0101780:	89 d8                	mov    %ebx,%eax
f0101782:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101788:	c1 f8 03             	sar    $0x3,%eax
f010178b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010178e:	89 c2                	mov    %eax,%edx
f0101790:	c1 ea 0c             	shr    $0xc,%edx
f0101793:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101799:	72 20                	jb     f01017bb <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010179b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010179f:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01017a6:	f0 
f01017a7:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01017ae:	00 
f01017af:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f01017b6:	e8 85 e8 ff ff       	call   f0100040 <_panic>
			// fill in '\0'
			memset(page2kva(result), 0, PGSIZE);
f01017bb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017c2:	00 
f01017c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017ca:	00 
	return (void *)(pa + KERNBASE);
f01017cb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017d0:	89 04 24             	mov    %eax,(%esp)
f01017d3:	e8 89 4a 00 00       	call   f0106261 <memset>
		}
	}
	return result;
}
f01017d8:	89 d8                	mov    %ebx,%eax
f01017da:	83 c4 14             	add    $0x14,%esp
f01017dd:	5b                   	pop    %ebx
f01017de:	5d                   	pop    %ebp
f01017df:	c3                   	ret    

f01017e0 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01017e0:	55                   	push   %ebp
f01017e1:	89 e5                	mov    %esp,%ebp
f01017e3:	83 ec 18             	sub    $0x18,%esp
f01017e6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(!pp)
f01017e9:	85 c0                	test   %eax,%eax
f01017eb:	75 1c                	jne    f0101809 <page_free+0x29>
		panic("page_free: invalid page to free!\n");
f01017ed:	c7 44 24 08 70 79 10 	movl   $0xf0107970,0x8(%esp)
f01017f4:	f0 
f01017f5:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f01017fc:	00 
f01017fd:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101804:	e8 37 e8 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0101809:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f010180f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101811:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
}
f0101816:	c9                   	leave  
f0101817:	c3                   	ret    

f0101818 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101818:	55                   	push   %ebp
f0101819:	89 e5                	mov    %esp,%ebp
f010181b:	83 ec 18             	sub    $0x18,%esp
f010181e:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101821:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101825:	83 ea 01             	sub    $0x1,%edx
f0101828:	66 89 50 04          	mov    %dx,0x4(%eax)
f010182c:	66 85 d2             	test   %dx,%dx
f010182f:	75 08                	jne    f0101839 <page_decref+0x21>
		page_free(pp);
f0101831:	89 04 24             	mov    %eax,(%esp)
f0101834:	e8 a7 ff ff ff       	call   f01017e0 <page_free>
//cprintf("page_decref: success!\n");
}
f0101839:	c9                   	leave  
f010183a:	c3                   	ret    

f010183b <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010183b:	55                   	push   %ebp
f010183c:	89 e5                	mov    %esp,%ebp
f010183e:	56                   	push   %esi
f010183f:	53                   	push   %ebx
f0101840:	83 ec 10             	sub    $0x10,%esp
f0101843:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
f0101846:	89 f3                	mov    %esi,%ebx
f0101848:	c1 eb 16             	shr    $0x16,%ebx
	uintptr_t ptx = PTX(va);
	uintptr_t pgoff = PGOFF(va);

	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];
f010184b:	c1 e3 02             	shl    $0x2,%ebx
f010184e:	03 5d 08             	add    0x8(%ebp),%ebx

	if(((*pde) & PTE_P) == 0) {
f0101851:	f6 03 01             	testb  $0x1,(%ebx)
f0101854:	75 2c                	jne    f0101882 <pgdir_walk+0x47>
		if(create == 0) 
f0101856:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010185a:	74 6c                	je     f01018c8 <pgdir_walk+0x8d>
			return NULL;
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
f010185c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101863:	e8 fa fe ff ff       	call   f0101762 <page_alloc>
			if(pgtbl == NULL)
f0101868:	85 c0                	test   %eax,%eax
f010186a:	74 63                	je     f01018cf <pgdir_walk+0x94>
				return NULL;
			else {
				pgtbl->pp_ref ++;
f010186c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101871:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101877:	c1 f8 03             	sar    $0x3,%eax
f010187a:	c1 e0 0c             	shl    $0xc,%eax
				/* store in physical address*/
				*pde = page2pa(pgtbl) | PTE_U | PTE_W | PTE_P;
f010187d:	83 c8 07             	or     $0x7,%eax
f0101880:	89 03                	mov    %eax,(%ebx)
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f0101882:	8b 03                	mov    (%ebx),%eax
f0101884:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101889:	89 c2                	mov    %eax,%edx
f010188b:	c1 ea 0c             	shr    $0xc,%edx
f010188e:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101894:	72 20                	jb     f01018b6 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101896:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010189a:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01018a1:	f0 
f01018a2:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
f01018a9:	00 
f01018aa:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01018b1:	e8 8a e7 ff ff       	call   f0100040 <_panic>
{
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
	uintptr_t ptx = PTX(va);
f01018b6:	c1 ee 0a             	shr    $0xa,%esi
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f01018b9:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01018bf:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax

	return pte;
f01018c6:	eb 0c                	jmp    f01018d4 <pgdir_walk+0x99>
	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];

	if(((*pde) & PTE_P) == 0) {
		if(create == 0) 
			return NULL;
f01018c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01018cd:	eb 05                	jmp    f01018d4 <pgdir_walk+0x99>
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
			if(pgtbl == NULL)
				return NULL;
f01018cf:	b8 00 00 00 00       	mov    $0x0,%eax
	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;

	return pte;
}
f01018d4:	83 c4 10             	add    $0x10,%esp
f01018d7:	5b                   	pop    %ebx
f01018d8:	5e                   	pop    %esi
f01018d9:	5d                   	pop    %ebp
f01018da:	c3                   	ret    

f01018db <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01018db:	55                   	push   %ebp
f01018dc:	89 e5                	mov    %esp,%ebp
f01018de:	57                   	push   %edi
f01018df:	56                   	push   %esi
f01018e0:	53                   	push   %ebx
f01018e1:	83 ec 2c             	sub    $0x2c,%esp
f01018e4:	89 c7                	mov    %eax,%edi
f01018e6:	8b 75 08             	mov    0x8(%ebp),%esi
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f01018e9:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01018ef:	c1 e9 0c             	shr    $0xc,%ecx
f01018f2:	85 c9                	test   %ecx,%ecx
f01018f4:	74 4b                	je     f0101941 <boot_map_region+0x66>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01018f6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f01018f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f01018fe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101904:	89 55 e0             	mov    %edx,-0x20(%ebp)
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f0101907:	8b 45 0c             	mov    0xc(%ebp),%eax
f010190a:	83 c8 01             	or     $0x1,%eax
f010190d:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f0101910:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101917:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101918:	89 d8                	mov    %ebx,%eax
f010191a:	c1 e0 0c             	shl    $0xc,%eax

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010191d:	03 45 e0             	add    -0x20(%ebp),%eax
f0101920:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101924:	89 3c 24             	mov    %edi,(%esp)
f0101927:	e8 0f ff ff ff       	call   f010183b <pgdir_walk>
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f010192c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010192f:	09 f2                	or     %esi,%edx
f0101931:	89 10                	mov    %edx,(%eax)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101933:	83 c3 01             	add    $0x1,%ebx
f0101936:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010193c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010193f:	75 cf                	jne    f0101910 <boot_map_region+0x35>
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
	}
}
f0101941:	83 c4 2c             	add    $0x2c,%esp
f0101944:	5b                   	pop    %ebx
f0101945:	5e                   	pop    %esi
f0101946:	5f                   	pop    %edi
f0101947:	5d                   	pop    %ebp
f0101948:	c3                   	ret    

f0101949 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101949:	55                   	push   %ebp
f010194a:	89 e5                	mov    %esp,%ebp
f010194c:	53                   	push   %ebx
f010194d:	83 ec 14             	sub    $0x14,%esp
f0101950:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
f0101953:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010195a:	00 
f010195b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010195e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101962:	8b 45 08             	mov    0x8(%ebp),%eax
f0101965:	89 04 24             	mov    %eax,(%esp)
f0101968:	e8 ce fe ff ff       	call   f010183b <pgdir_walk>
	struct PageInfo *pg = NULL;
	// Check if the pte_store is zero
	if(pte_store != 0)
f010196d:	85 db                	test   %ebx,%ebx
f010196f:	74 02                	je     f0101973 <page_lookup+0x2a>
		*pte_store = pte;
f0101971:	89 03                	mov    %eax,(%ebx)

	// Check if the page is mapped
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
f0101973:	85 c0                	test   %eax,%eax
f0101975:	74 38                	je     f01019af <page_lookup+0x66>
f0101977:	8b 00                	mov    (%eax),%eax
f0101979:	a8 01                	test   $0x1,%al
f010197b:	74 39                	je     f01019b6 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010197d:	c1 e8 0c             	shr    $0xc,%eax
f0101980:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0101986:	72 1c                	jb     f01019a4 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101988:	c7 44 24 08 94 79 10 	movl   $0xf0107994,0x8(%esp)
f010198f:	f0 
f0101990:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101997:	00 
f0101998:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f010199f:	e8 9c e6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01019a4:	c1 e0 03             	shl    $0x3,%eax
f01019a7:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f01019ad:	eb 0c                	jmp    f01019bb <page_lookup+0x72>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
	struct PageInfo *pg = NULL;
f01019af:	b8 00 00 00 00       	mov    $0x0,%eax
f01019b4:	eb 05                	jmp    f01019bb <page_lookup+0x72>
f01019b6:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
		pg = pa2page(PTE_ADDR(*pte));
	}

	return pg;
}
f01019bb:	83 c4 14             	add    $0x14,%esp
f01019be:	5b                   	pop    %ebx
f01019bf:	5d                   	pop    %ebp
f01019c0:	c3                   	ret    

f01019c1 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01019c1:	55                   	push   %ebp
f01019c2:	89 e5                	mov    %esp,%ebp
f01019c4:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01019c7:	e8 24 4f 00 00       	call   f01068f0 <cpunum>
f01019cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01019cf:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01019d6:	74 16                	je     f01019ee <tlb_invalidate+0x2d>
f01019d8:	e8 13 4f 00 00       	call   f01068f0 <cpunum>
f01019dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01019e0:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01019e6:	8b 55 08             	mov    0x8(%ebp),%edx
f01019e9:	39 50 60             	cmp    %edx,0x60(%eax)
f01019ec:	75 06                	jne    f01019f4 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01019ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019f1:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01019f4:	c9                   	leave  
f01019f5:	c3                   	ret    

f01019f6 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01019f6:	55                   	push   %ebp
f01019f7:	89 e5                	mov    %esp,%ebp
f01019f9:	83 ec 28             	sub    $0x28,%esp
f01019fc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01019ff:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101a02:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;

	// look up the pte for the va
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f0101a08:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a13:	89 34 24             	mov    %esi,(%esp)
f0101a16:	e8 2e ff ff ff       	call   f0101949 <page_lookup>

	if(pg != NULL) {
f0101a1b:	85 c0                	test   %eax,%eax
f0101a1d:	74 1d                	je     f0101a3c <page_remove+0x46>
		// Decrease the count and free
		page_decref(pg);
f0101a1f:	89 04 24             	mov    %eax,(%esp)
f0101a22:	e8 f1 fd ff ff       	call   f0101818 <page_decref>
		// Set the pte to zero
		*pte = 0;
f0101a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		// The TLB must be invalidated if a page was formerly present at 'va'.
		tlb_invalidate(pgdir, va);
f0101a30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a34:	89 34 24             	mov    %esi,(%esp)
f0101a37:	e8 85 ff ff ff       	call   f01019c1 <tlb_invalidate>
	}
}
f0101a3c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101a3f:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101a42:	89 ec                	mov    %ebp,%esp
f0101a44:	5d                   	pop    %ebp
f0101a45:	c3                   	ret    

f0101a46 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101a46:	55                   	push   %ebp
f0101a47:	89 e5                	mov    %esp,%ebp
f0101a49:	83 ec 28             	sub    $0x28,%esp
f0101a4c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101a4f:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101a52:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101a55:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a58:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
f0101a5b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101a62:	00 
f0101a63:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a67:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a6a:	89 04 24             	mov    %eax,(%esp)
f0101a6d:	e8 c9 fd ff ff       	call   f010183b <pgdir_walk>
f0101a72:	89 c3                	mov    %eax,%ebx
	if(pte == NULL) 
f0101a74:	85 c0                	test   %eax,%eax
f0101a76:	74 66                	je     f0101ade <page_insert+0x98>
		return -E_NO_MEM;
	// If there is already a page mapped at 'va', it should be page_remove()d.
	if(((*pte) & PTE_P) == 1) {
f0101a78:	8b 00                	mov    (%eax),%eax
f0101a7a:	a8 01                	test   $0x1,%al
f0101a7c:	74 3c                	je     f0101aba <page_insert+0x74>
		//On one hand, the mapped page is pp;
		if(PTE_ADDR(*pte) == page2pa(pp)) {
f0101a7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a83:	89 f2                	mov    %esi,%edx
f0101a85:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101a8b:	c1 fa 03             	sar    $0x3,%edx
f0101a8e:	c1 e2 0c             	shl    $0xc,%edx
f0101a91:	39 d0                	cmp    %edx,%eax
f0101a93:	75 16                	jne    f0101aab <page_insert+0x65>
			// The TLB must be invalidated if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f0101a95:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a99:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a9c:	89 04 24             	mov    %eax,(%esp)
f0101a9f:	e8 1d ff ff ff       	call   f01019c1 <tlb_invalidate>
			// The reference for the same page should not change(latter add one)
			pp->pp_ref --;
f0101aa4:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f0101aa9:	eb 0f                	jmp    f0101aba <page_insert+0x74>
		}
		//On the other hand, the mapped page is not pp;
		else
			page_remove(pgdir, va);
f0101aab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ab2:	89 04 24             	mov    %eax,(%esp)
f0101ab5:	e8 3c ff ff ff       	call   f01019f6 <page_remove>
	}

	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
f0101aba:	8b 45 14             	mov    0x14(%ebp),%eax
f0101abd:	83 c8 01             	or     $0x1,%eax
f0101ac0:	89 f2                	mov    %esi,%edx
f0101ac2:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101ac8:	c1 fa 03             	sar    $0x3,%edx
f0101acb:	c1 e2 0c             	shl    $0xc,%edx
f0101ace:	09 d0                	or     %edx,%eax
f0101ad0:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref ++;
f0101ad2:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	
	return 0;
f0101ad7:	b8 00 00 00 00       	mov    $0x0,%eax
f0101adc:	eb 05                	jmp    f0101ae3 <page_insert+0x9d>
{
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
	if(pte == NULL) 
		return -E_NO_MEM;
f0101ade:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref ++;
	
	return 0;
}
f0101ae3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101ae6:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101ae9:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101aec:	89 ec                	mov    %ebp,%esp
f0101aee:	5d                   	pop    %ebp
f0101aef:	c3                   	ret    

f0101af0 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101af0:	55                   	push   %ebp
f0101af1:	89 e5                	mov    %esp,%ebp
f0101af3:	53                   	push   %ebx
f0101af4:	83 ec 14             	sub    $0x14,%esp
f0101af7:	8b 45 08             	mov    0x8(%ebp),%eax
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

    size = ROUNDUP(pa+size, PGSIZE);
f0101afa:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101b00:	03 5d 0c             	add    0xc(%ebp),%ebx
f0101b03:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    pa = ROUNDDOWN(pa, PGSIZE);
f0101b09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    size -= pa;
f0101b0e:	29 c3                	sub    %eax,%ebx

    if (base+size >= MMIOLIM) 
f0101b10:	8b 15 04 23 12 f0    	mov    0xf0122304,%edx
f0101b16:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0101b19:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101b1f:	76 1c                	jbe    f0101b3d <mmio_map_region+0x4d>
    	panic("not enough memory");
f0101b21:	c7 44 24 08 78 82 10 	movl   $0xf0108278,0x8(%esp)
f0101b28:	f0 
f0101b29:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101b30:	00 
f0101b31:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101b38:	e8 03 e5 ff ff       	call   f0100040 <_panic>
    
    boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101b3d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101b44:	00 
f0101b45:	89 04 24             	mov    %eax,(%esp)
f0101b48:	89 d9                	mov    %ebx,%ecx
f0101b4a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101b4f:	e8 87 fd ff ff       	call   f01018db <boot_map_region>
    
    base += size;
f0101b54:	a1 04 23 12 f0       	mov    0xf0122304,%eax
f0101b59:	01 c3                	add    %eax,%ebx
f0101b5b:	89 1d 04 23 12 f0    	mov    %ebx,0xf0122304
    return (void*) (base - size);
}
f0101b61:	83 c4 14             	add    $0x14,%esp
f0101b64:	5b                   	pop    %ebx
f0101b65:	5d                   	pop    %ebp
f0101b66:	c3                   	ret    

f0101b67 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101b67:	55                   	push   %ebp
f0101b68:	89 e5                	mov    %esp,%ebp
f0101b6a:	57                   	push   %edi
f0101b6b:	56                   	push   %esi
f0101b6c:	53                   	push   %ebx
f0101b6d:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101b70:	b8 15 00 00 00       	mov    $0x15,%eax
f0101b75:	e8 40 f7 ff ff       	call   f01012ba <nvram_read>
f0101b7a:	c1 e0 0a             	shl    $0xa,%eax
f0101b7d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101b83:	85 c0                	test   %eax,%eax
f0101b85:	0f 48 c2             	cmovs  %edx,%eax
f0101b88:	c1 f8 0c             	sar    $0xc,%eax
f0101b8b:	a3 38 b2 22 f0       	mov    %eax,0xf022b238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101b90:	b8 17 00 00 00       	mov    $0x17,%eax
f0101b95:	e8 20 f7 ff ff       	call   f01012ba <nvram_read>
f0101b9a:	c1 e0 0a             	shl    $0xa,%eax
f0101b9d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101ba3:	85 c0                	test   %eax,%eax
f0101ba5:	0f 48 c2             	cmovs  %edx,%eax
f0101ba8:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101bab:	85 c0                	test   %eax,%eax
f0101bad:	74 0e                	je     f0101bbd <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101baf:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101bb5:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
f0101bbb:	eb 0c                	jmp    f0101bc9 <mem_init+0x62>
	else
		npages = npages_basemem;
f0101bbd:	8b 15 38 b2 22 f0    	mov    0xf022b238,%edx
f0101bc3:	89 15 88 be 22 f0    	mov    %edx,0xf022be88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101bc9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bcc:	c1 e8 0a             	shr    $0xa,%eax
f0101bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101bd3:	a1 38 b2 22 f0       	mov    0xf022b238,%eax
f0101bd8:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bdb:	c1 e8 0a             	shr    $0xa,%eax
f0101bde:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101be2:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101be7:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bea:	c1 e8 0a             	shr    $0xa,%eax
f0101bed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bf1:	c7 04 24 b4 79 10 f0 	movl   $0xf01079b4,(%esp)
f0101bf8:	e8 f9 29 00 00       	call   f01045f6 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101bfd:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101c02:	e8 fa f5 ff ff       	call   f0101201 <boot_alloc>
f0101c07:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f0101c0c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c13:	00 
f0101c14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c1b:	00 
f0101c1c:	89 04 24             	mov    %eax,(%esp)
f0101c1f:	e8 3d 46 00 00       	call   f0106261 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c24:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101c29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c2e:	77 20                	ja     f0101c50 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c34:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0101c3b:	f0 
f0101c3c:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
f0101c43:	00 
f0101c44:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101c4b:	e8 f0 e3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101c50:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101c56:	83 ca 05             	or     $0x5,%edx
f0101c59:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// Request for pages to store 'struct PageInfo's
	uint32_t pagesneed = (uint32_t)(sizeof(struct PageInfo) * npages);
f0101c5f:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101c64:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f0101c67:	e8 95 f5 ff ff       	call   f0101201 <boot_alloc>
f0101c6c:	a3 90 be 22 f0       	mov    %eax,0xf022be90
	
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0101c71:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101c76:	e8 86 f5 ff ff       	call   f0101201 <boot_alloc>
f0101c7b:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101c80:	e8 08 fa ff ff       	call   f010168d <page_init>

	check_page_free_list(1);
f0101c85:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c8a:	e8 5d f6 ff ff       	call   f01012ec <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101c8f:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0101c96:	75 1c                	jne    f0101cb4 <mem_init+0x14d>
		panic("'pages' is a null pointer!");
f0101c98:	c7 44 24 08 8a 82 10 	movl   $0xf010828a,0x8(%esp)
f0101c9f:	f0 
f0101ca0:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101ca7:	00 
f0101ca8:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101caf:	e8 8c e3 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cb4:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101cbe:	85 c0                	test   %eax,%eax
f0101cc0:	74 09                	je     f0101ccb <mem_init+0x164>
		++nfree;
f0101cc2:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cc5:	8b 00                	mov    (%eax),%eax
f0101cc7:	85 c0                	test   %eax,%eax
f0101cc9:	75 f7                	jne    f0101cc2 <mem_init+0x15b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ccb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cd2:	e8 8b fa ff ff       	call   f0101762 <page_alloc>
f0101cd7:	89 c6                	mov    %eax,%esi
f0101cd9:	85 c0                	test   %eax,%eax
f0101cdb:	75 24                	jne    f0101d01 <mem_init+0x19a>
f0101cdd:	c7 44 24 0c a5 82 10 	movl   $0xf01082a5,0xc(%esp)
f0101ce4:	f0 
f0101ce5:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101cec:	f0 
f0101ced:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101cf4:	00 
f0101cf5:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101cfc:	e8 3f e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d08:	e8 55 fa ff ff       	call   f0101762 <page_alloc>
f0101d0d:	89 c7                	mov    %eax,%edi
f0101d0f:	85 c0                	test   %eax,%eax
f0101d11:	75 24                	jne    f0101d37 <mem_init+0x1d0>
f0101d13:	c7 44 24 0c bb 82 10 	movl   $0xf01082bb,0xc(%esp)
f0101d1a:	f0 
f0101d1b:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101d2a:	00 
f0101d2b:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101d32:	e8 09 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d3e:	e8 1f fa ff ff       	call   f0101762 <page_alloc>
f0101d43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d46:	85 c0                	test   %eax,%eax
f0101d48:	75 24                	jne    f0101d6e <mem_init+0x207>
f0101d4a:	c7 44 24 0c d1 82 10 	movl   $0xf01082d1,0xc(%esp)
f0101d51:	f0 
f0101d52:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101d59:	f0 
f0101d5a:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101d61:	00 
f0101d62:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101d69:	e8 d2 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d6e:	39 fe                	cmp    %edi,%esi
f0101d70:	75 24                	jne    f0101d96 <mem_init+0x22f>
f0101d72:	c7 44 24 0c e7 82 10 	movl   $0xf01082e7,0xc(%esp)
f0101d79:	f0 
f0101d7a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101d81:	f0 
f0101d82:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101d89:	00 
f0101d8a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101d91:	e8 aa e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d96:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d99:	74 05                	je     f0101da0 <mem_init+0x239>
f0101d9b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d9e:	75 24                	jne    f0101dc4 <mem_init+0x25d>
f0101da0:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101dbf:	e8 7c e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dc4:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101dca:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101dcf:	c1 e0 0c             	shl    $0xc,%eax
f0101dd2:	89 f1                	mov    %esi,%ecx
f0101dd4:	29 d1                	sub    %edx,%ecx
f0101dd6:	c1 f9 03             	sar    $0x3,%ecx
f0101dd9:	c1 e1 0c             	shl    $0xc,%ecx
f0101ddc:	39 c1                	cmp    %eax,%ecx
f0101dde:	72 24                	jb     f0101e04 <mem_init+0x29d>
f0101de0:	c7 44 24 0c f9 82 10 	movl   $0xf01082f9,0xc(%esp)
f0101de7:	f0 
f0101de8:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101def:	f0 
f0101df0:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101df7:	00 
f0101df8:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101dff:	e8 3c e2 ff ff       	call   f0100040 <_panic>
f0101e04:	89 f9                	mov    %edi,%ecx
f0101e06:	29 d1                	sub    %edx,%ecx
f0101e08:	c1 f9 03             	sar    $0x3,%ecx
f0101e0b:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101e0e:	39 c8                	cmp    %ecx,%eax
f0101e10:	77 24                	ja     f0101e36 <mem_init+0x2cf>
f0101e12:	c7 44 24 0c 16 83 10 	movl   $0xf0108316,0xc(%esp)
f0101e19:	f0 
f0101e1a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101e21:	f0 
f0101e22:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101e29:	00 
f0101e2a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101e31:	e8 0a e2 ff ff       	call   f0100040 <_panic>
f0101e36:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e39:	29 d1                	sub    %edx,%ecx
f0101e3b:	89 ca                	mov    %ecx,%edx
f0101e3d:	c1 fa 03             	sar    $0x3,%edx
f0101e40:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e43:	39 d0                	cmp    %edx,%eax
f0101e45:	77 24                	ja     f0101e6b <mem_init+0x304>
f0101e47:	c7 44 24 0c 33 83 10 	movl   $0xf0108333,0xc(%esp)
f0101e4e:	f0 
f0101e4f:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101e56:	f0 
f0101e57:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101e5e:	00 
f0101e5f:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101e66:	e8 d5 e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e6b:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101e70:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101e73:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101e7a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e84:	e8 d9 f8 ff ff       	call   f0101762 <page_alloc>
f0101e89:	85 c0                	test   %eax,%eax
f0101e8b:	74 24                	je     f0101eb1 <mem_init+0x34a>
f0101e8d:	c7 44 24 0c 50 83 10 	movl   $0xf0108350,0xc(%esp)
f0101e94:	f0 
f0101e95:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101e9c:	f0 
f0101e9d:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101ea4:	00 
f0101ea5:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101eac:	e8 8f e1 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101eb1:	89 34 24             	mov    %esi,(%esp)
f0101eb4:	e8 27 f9 ff ff       	call   f01017e0 <page_free>
	page_free(pp1);
f0101eb9:	89 3c 24             	mov    %edi,(%esp)
f0101ebc:	e8 1f f9 ff ff       	call   f01017e0 <page_free>
	page_free(pp2);
f0101ec1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ec4:	89 04 24             	mov    %eax,(%esp)
f0101ec7:	e8 14 f9 ff ff       	call   f01017e0 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ecc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ed3:	e8 8a f8 ff ff       	call   f0101762 <page_alloc>
f0101ed8:	89 c6                	mov    %eax,%esi
f0101eda:	85 c0                	test   %eax,%eax
f0101edc:	75 24                	jne    f0101f02 <mem_init+0x39b>
f0101ede:	c7 44 24 0c a5 82 10 	movl   $0xf01082a5,0xc(%esp)
f0101ee5:	f0 
f0101ee6:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101eed:	f0 
f0101eee:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101ef5:	00 
f0101ef6:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101efd:	e8 3e e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f09:	e8 54 f8 ff ff       	call   f0101762 <page_alloc>
f0101f0e:	89 c7                	mov    %eax,%edi
f0101f10:	85 c0                	test   %eax,%eax
f0101f12:	75 24                	jne    f0101f38 <mem_init+0x3d1>
f0101f14:	c7 44 24 0c bb 82 10 	movl   $0xf01082bb,0xc(%esp)
f0101f1b:	f0 
f0101f1c:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101f2b:	00 
f0101f2c:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101f33:	e8 08 e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f3f:	e8 1e f8 ff ff       	call   f0101762 <page_alloc>
f0101f44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f47:	85 c0                	test   %eax,%eax
f0101f49:	75 24                	jne    f0101f6f <mem_init+0x408>
f0101f4b:	c7 44 24 0c d1 82 10 	movl   $0xf01082d1,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101f6a:	e8 d1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f6f:	39 fe                	cmp    %edi,%esi
f0101f71:	75 24                	jne    f0101f97 <mem_init+0x430>
f0101f73:	c7 44 24 0c e7 82 10 	movl   $0xf01082e7,0xc(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101f82:	f0 
f0101f83:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101f8a:	00 
f0101f8b:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101f92:	e8 a9 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f97:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101f9a:	74 05                	je     f0101fa1 <mem_init+0x43a>
f0101f9c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101f9f:	75 24                	jne    f0101fc5 <mem_init+0x45e>
f0101fa1:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f0101fa8:	f0 
f0101fa9:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101fb0:	f0 
f0101fb1:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101fb8:	00 
f0101fb9:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101fc0:	e8 7b e0 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fcc:	e8 91 f7 ff ff       	call   f0101762 <page_alloc>
f0101fd1:	85 c0                	test   %eax,%eax
f0101fd3:	74 24                	je     f0101ff9 <mem_init+0x492>
f0101fd5:	c7 44 24 0c 50 83 10 	movl   $0xf0108350,0xc(%esp)
f0101fdc:	f0 
f0101fdd:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0101fe4:	f0 
f0101fe5:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101fec:	00 
f0101fed:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0101ff4:	e8 47 e0 ff ff       	call   f0100040 <_panic>
f0101ff9:	89 f0                	mov    %esi,%eax
f0101ffb:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102001:	c1 f8 03             	sar    $0x3,%eax
f0102004:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102007:	89 c2                	mov    %eax,%edx
f0102009:	c1 ea 0c             	shr    $0xc,%edx
f010200c:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102012:	72 20                	jb     f0102034 <mem_init+0x4cd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102014:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102018:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f010201f:	f0 
f0102020:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102027:	00 
f0102028:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f010202f:	e8 0c e0 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102034:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010203b:	00 
f010203c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102043:	00 
	return (void *)(pa + KERNBASE);
f0102044:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102049:	89 04 24             	mov    %eax,(%esp)
f010204c:	e8 10 42 00 00       	call   f0106261 <memset>
	page_free(pp0);
f0102051:	89 34 24             	mov    %esi,(%esp)
f0102054:	e8 87 f7 ff ff       	call   f01017e0 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102059:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102060:	e8 fd f6 ff ff       	call   f0101762 <page_alloc>
f0102065:	85 c0                	test   %eax,%eax
f0102067:	75 24                	jne    f010208d <mem_init+0x526>
f0102069:	c7 44 24 0c 5f 83 10 	movl   $0xf010835f,0xc(%esp)
f0102070:	f0 
f0102071:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102078:	f0 
f0102079:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102080:	00 
f0102081:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102088:	e8 b3 df ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010208d:	39 c6                	cmp    %eax,%esi
f010208f:	74 24                	je     f01020b5 <mem_init+0x54e>
f0102091:	c7 44 24 0c 7d 83 10 	movl   $0xf010837d,0xc(%esp)
f0102098:	f0 
f0102099:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01020a0:	f0 
f01020a1:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f01020a8:	00 
f01020a9:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01020b0:	e8 8b df ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020b5:	89 f2                	mov    %esi,%edx
f01020b7:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01020bd:	c1 fa 03             	sar    $0x3,%edx
f01020c0:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020c3:	89 d0                	mov    %edx,%eax
f01020c5:	c1 e8 0c             	shr    $0xc,%eax
f01020c8:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01020ce:	72 20                	jb     f01020f0 <mem_init+0x589>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01020d4:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01020db:	f0 
f01020dc:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01020e3:	00 
f01020e4:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f01020eb:	e8 50 df ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01020f0:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01020f7:	75 11                	jne    f010210a <mem_init+0x5a3>
f01020f9:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01020ff:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102105:	80 38 00             	cmpb   $0x0,(%eax)
f0102108:	74 24                	je     f010212e <mem_init+0x5c7>
f010210a:	c7 44 24 0c 8d 83 10 	movl   $0xf010838d,0xc(%esp)
f0102111:	f0 
f0102112:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102119:	f0 
f010211a:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102121:	00 
f0102122:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102129:	e8 12 df ff ff       	call   f0100040 <_panic>
f010212e:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102131:	39 d0                	cmp    %edx,%eax
f0102133:	75 d0                	jne    f0102105 <mem_init+0x59e>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102135:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102138:	89 15 40 b2 22 f0    	mov    %edx,0xf022b240

	// free the pages we took
	page_free(pp0);
f010213e:	89 34 24             	mov    %esi,(%esp)
f0102141:	e8 9a f6 ff ff       	call   f01017e0 <page_free>
	page_free(pp1);
f0102146:	89 3c 24             	mov    %edi,(%esp)
f0102149:	e8 92 f6 ff ff       	call   f01017e0 <page_free>
	page_free(pp2);
f010214e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102151:	89 04 24             	mov    %eax,(%esp)
f0102154:	e8 87 f6 ff ff       	call   f01017e0 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102159:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f010215e:	85 c0                	test   %eax,%eax
f0102160:	74 09                	je     f010216b <mem_init+0x604>
		--nfree;
f0102162:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102165:	8b 00                	mov    (%eax),%eax
f0102167:	85 c0                	test   %eax,%eax
f0102169:	75 f7                	jne    f0102162 <mem_init+0x5fb>
		--nfree;
	assert(nfree == 0);
f010216b:	85 db                	test   %ebx,%ebx
f010216d:	74 24                	je     f0102193 <mem_init+0x62c>
f010216f:	c7 44 24 0c 97 83 10 	movl   $0xf0108397,0xc(%esp)
f0102176:	f0 
f0102177:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010217e:	f0 
f010217f:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102186:	00 
f0102187:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010218e:	e8 ad de ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102193:	c7 04 24 10 7a 10 f0 	movl   $0xf0107a10,(%esp)
f010219a:	e8 57 24 00 00       	call   f01045f6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010219f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021a6:	e8 b7 f5 ff ff       	call   f0101762 <page_alloc>
f01021ab:	89 c6                	mov    %eax,%esi
f01021ad:	85 c0                	test   %eax,%eax
f01021af:	75 24                	jne    f01021d5 <mem_init+0x66e>
f01021b1:	c7 44 24 0c a5 82 10 	movl   $0xf01082a5,0xc(%esp)
f01021b8:	f0 
f01021b9:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01021c0:	f0 
f01021c1:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01021c8:	00 
f01021c9:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01021d0:	e8 6b de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021dc:	e8 81 f5 ff ff       	call   f0101762 <page_alloc>
f01021e1:	89 c7                	mov    %eax,%edi
f01021e3:	85 c0                	test   %eax,%eax
f01021e5:	75 24                	jne    f010220b <mem_init+0x6a4>
f01021e7:	c7 44 24 0c bb 82 10 	movl   $0xf01082bb,0xc(%esp)
f01021ee:	f0 
f01021ef:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01021f6:	f0 
f01021f7:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01021fe:	00 
f01021ff:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102206:	e8 35 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010220b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102212:	e8 4b f5 ff ff       	call   f0101762 <page_alloc>
f0102217:	89 c3                	mov    %eax,%ebx
f0102219:	85 c0                	test   %eax,%eax
f010221b:	75 24                	jne    f0102241 <mem_init+0x6da>
f010221d:	c7 44 24 0c d1 82 10 	movl   $0xf01082d1,0xc(%esp)
f0102224:	f0 
f0102225:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010222c:	f0 
f010222d:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102234:	00 
f0102235:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010223c:	e8 ff dd ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102241:	39 fe                	cmp    %edi,%esi
f0102243:	75 24                	jne    f0102269 <mem_init+0x702>
f0102245:	c7 44 24 0c e7 82 10 	movl   $0xf01082e7,0xc(%esp)
f010224c:	f0 
f010224d:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102254:	f0 
f0102255:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f010225c:	00 
f010225d:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102264:	e8 d7 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102269:	39 c7                	cmp    %eax,%edi
f010226b:	74 04                	je     f0102271 <mem_init+0x70a>
f010226d:	39 c6                	cmp    %eax,%esi
f010226f:	75 24                	jne    f0102295 <mem_init+0x72e>
f0102271:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f0102278:	f0 
f0102279:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102280:	f0 
f0102281:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102288:	00 
f0102289:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102290:	e8 ab dd ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102295:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f010229b:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010229e:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f01022a5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01022a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022af:	e8 ae f4 ff ff       	call   f0101762 <page_alloc>
f01022b4:	85 c0                	test   %eax,%eax
f01022b6:	74 24                	je     f01022dc <mem_init+0x775>
f01022b8:	c7 44 24 0c 50 83 10 	movl   $0xf0108350,0xc(%esp)
f01022bf:	f0 
f01022c0:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01022c7:	f0 
f01022c8:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01022cf:	00 
f01022d0:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01022d7:	e8 64 dd ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01022df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022ea:	00 
f01022eb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01022f0:	89 04 24             	mov    %eax,(%esp)
f01022f3:	e8 51 f6 ff ff       	call   f0101949 <page_lookup>
f01022f8:	85 c0                	test   %eax,%eax
f01022fa:	74 24                	je     f0102320 <mem_init+0x7b9>
f01022fc:	c7 44 24 0c 30 7a 10 	movl   $0xf0107a30,0xc(%esp)
f0102303:	f0 
f0102304:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010230b:	f0 
f010230c:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102313:	00 
f0102314:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010231b:	e8 20 dd ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102320:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102327:	00 
f0102328:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010232f:	00 
f0102330:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102334:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102339:	89 04 24             	mov    %eax,(%esp)
f010233c:	e8 05 f7 ff ff       	call   f0101a46 <page_insert>
f0102341:	85 c0                	test   %eax,%eax
f0102343:	78 24                	js     f0102369 <mem_init+0x802>
f0102345:	c7 44 24 0c 68 7a 10 	movl   $0xf0107a68,0xc(%esp)
f010234c:	f0 
f010234d:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102354:	f0 
f0102355:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f010235c:	00 
f010235d:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102364:	e8 d7 dc ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102369:	89 34 24             	mov    %esi,(%esp)
f010236c:	e8 6f f4 ff ff       	call   f01017e0 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102371:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102378:	00 
f0102379:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102380:	00 
f0102381:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102385:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010238a:	89 04 24             	mov    %eax,(%esp)
f010238d:	e8 b4 f6 ff ff       	call   f0101a46 <page_insert>
f0102392:	85 c0                	test   %eax,%eax
f0102394:	74 24                	je     f01023ba <mem_init+0x853>
f0102396:	c7 44 24 0c 98 7a 10 	movl   $0xf0107a98,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01023b5:	e8 86 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023ba:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f01023c0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023c3:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f01023c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023cb:	8b 11                	mov    (%ecx),%edx
f01023cd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01023d3:	89 f0                	mov    %esi,%eax
f01023d5:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01023d8:	c1 f8 03             	sar    $0x3,%eax
f01023db:	c1 e0 0c             	shl    $0xc,%eax
f01023de:	39 c2                	cmp    %eax,%edx
f01023e0:	74 24                	je     f0102406 <mem_init+0x89f>
f01023e2:	c7 44 24 0c c8 7a 10 	movl   $0xf0107ac8,0xc(%esp)
f01023e9:	f0 
f01023ea:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01023f1:	f0 
f01023f2:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f01023f9:	00 
f01023fa:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102401:	e8 3a dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102406:	ba 00 00 00 00       	mov    $0x0,%edx
f010240b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010240e:	e8 7d ed ff ff       	call   f0101190 <check_va2pa>
f0102413:	89 fa                	mov    %edi,%edx
f0102415:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0102418:	c1 fa 03             	sar    $0x3,%edx
f010241b:	c1 e2 0c             	shl    $0xc,%edx
f010241e:	39 d0                	cmp    %edx,%eax
f0102420:	74 24                	je     f0102446 <mem_init+0x8df>
f0102422:	c7 44 24 0c f0 7a 10 	movl   $0xf0107af0,0xc(%esp)
f0102429:	f0 
f010242a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102431:	f0 
f0102432:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102439:	00 
f010243a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102446:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010244b:	74 24                	je     f0102471 <mem_init+0x90a>
f010244d:	c7 44 24 0c a2 83 10 	movl   $0xf01083a2,0xc(%esp)
f0102454:	f0 
f0102455:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010245c:	f0 
f010245d:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0102464:	00 
f0102465:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010246c:	e8 cf db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102471:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102476:	74 24                	je     f010249c <mem_init+0x935>
f0102478:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f010247f:	f0 
f0102480:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102487:	f0 
f0102488:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f010248f:	00 
f0102490:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102497:	e8 a4 db ff ff       	call   f0100040 <_panic>



	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010249c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024a3:	00 
f01024a4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ab:	00 
f01024ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01024b3:	89 14 24             	mov    %edx,(%esp)
f01024b6:	e8 8b f5 ff ff       	call   f0101a46 <page_insert>
f01024bb:	85 c0                	test   %eax,%eax
f01024bd:	74 24                	je     f01024e3 <mem_init+0x97c>
f01024bf:	c7 44 24 0c 20 7b 10 	movl   $0xf0107b20,0xc(%esp)
f01024c6:	f0 
f01024c7:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01024ce:	f0 
f01024cf:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01024d6:	00 
f01024d7:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01024de:	e8 5d db ff ff       	call   f0100040 <_panic>

	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024e3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01024ed:	e8 9e ec ff ff       	call   f0101190 <check_va2pa>
f01024f2:	89 da                	mov    %ebx,%edx
f01024f4:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01024fa:	c1 fa 03             	sar    $0x3,%edx
f01024fd:	c1 e2 0c             	shl    $0xc,%edx
f0102500:	39 d0                	cmp    %edx,%eax
f0102502:	74 24                	je     f0102528 <mem_init+0x9c1>
f0102504:	c7 44 24 0c 5c 7b 10 	movl   $0xf0107b5c,0xc(%esp)
f010250b:	f0 
f010250c:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102513:	f0 
f0102514:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f010251b:	00 
f010251c:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102523:	e8 18 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102528:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010252d:	74 24                	je     f0102553 <mem_init+0x9ec>
f010252f:	c7 44 24 0c c4 83 10 	movl   $0xf01083c4,0xc(%esp)
f0102536:	f0 
f0102537:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010253e:	f0 
f010253f:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102546:	00 
f0102547:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010254e:	e8 ed da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102553:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010255a:	e8 03 f2 ff ff       	call   f0101762 <page_alloc>
f010255f:	85 c0                	test   %eax,%eax
f0102561:	74 24                	je     f0102587 <mem_init+0xa20>
f0102563:	c7 44 24 0c 50 83 10 	movl   $0xf0108350,0xc(%esp)
f010256a:	f0 
f010256b:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102572:	f0 
f0102573:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f010257a:	00 
f010257b:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102582:	e8 b9 da ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102587:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010258e:	00 
f010258f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102596:	00 
f0102597:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010259b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01025a0:	89 04 24             	mov    %eax,(%esp)
f01025a3:	e8 9e f4 ff ff       	call   f0101a46 <page_insert>
f01025a8:	85 c0                	test   %eax,%eax
f01025aa:	74 24                	je     f01025d0 <mem_init+0xa69>
f01025ac:	c7 44 24 0c 20 7b 10 	movl   $0xf0107b20,0xc(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f01025c3:	00 
f01025c4:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01025cb:	e8 70 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025d0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025d5:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01025da:	e8 b1 eb ff ff       	call   f0101190 <check_va2pa>
f01025df:	89 da                	mov    %ebx,%edx
f01025e1:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01025e7:	c1 fa 03             	sar    $0x3,%edx
f01025ea:	c1 e2 0c             	shl    $0xc,%edx
f01025ed:	39 d0                	cmp    %edx,%eax
f01025ef:	74 24                	je     f0102615 <mem_init+0xaae>
f01025f1:	c7 44 24 0c 5c 7b 10 	movl   $0xf0107b5c,0xc(%esp)
f01025f8:	f0 
f01025f9:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102600:	f0 
f0102601:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102608:	00 
f0102609:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102610:	e8 2b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102615:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010261a:	74 24                	je     f0102640 <mem_init+0xad9>
f010261c:	c7 44 24 0c c4 83 10 	movl   $0xf01083c4,0xc(%esp)
f0102623:	f0 
f0102624:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010262b:	f0 
f010262c:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102633:	00 
f0102634:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010263b:	e8 00 da ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102640:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102647:	e8 16 f1 ff ff       	call   f0101762 <page_alloc>
f010264c:	85 c0                	test   %eax,%eax
f010264e:	74 24                	je     f0102674 <mem_init+0xb0d>
f0102650:	c7 44 24 0c 50 83 10 	movl   $0xf0108350,0xc(%esp)
f0102657:	f0 
f0102658:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010265f:	f0 
f0102660:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0102667:	00 
f0102668:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010266f:	e8 cc d9 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102674:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f010267a:	8b 02                	mov    (%edx),%eax
f010267c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102681:	89 c1                	mov    %eax,%ecx
f0102683:	c1 e9 0c             	shr    $0xc,%ecx
f0102686:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f010268c:	72 20                	jb     f01026ae <mem_init+0xb47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010268e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102692:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0102699:	f0 
f010269a:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01026a1:	00 
f01026a2:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01026a9:	e8 92 d9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01026ae:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026bd:	00 
f01026be:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026c5:	00 
f01026c6:	89 14 24             	mov    %edx,(%esp)
f01026c9:	e8 6d f1 ff ff       	call   f010183b <pgdir_walk>
f01026ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01026d1:	83 c2 04             	add    $0x4,%edx
f01026d4:	39 d0                	cmp    %edx,%eax
f01026d6:	74 24                	je     f01026fc <mem_init+0xb95>
f01026d8:	c7 44 24 0c 8c 7b 10 	movl   $0xf0107b8c,0xc(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01026e7:	f0 
f01026e8:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f01026ef:	00 
f01026f0:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01026f7:	e8 44 d9 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01026fc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102703:	00 
f0102704:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010270b:	00 
f010270c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102710:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102715:	89 04 24             	mov    %eax,(%esp)
f0102718:	e8 29 f3 ff ff       	call   f0101a46 <page_insert>
f010271d:	85 c0                	test   %eax,%eax
f010271f:	74 24                	je     f0102745 <mem_init+0xbde>
f0102721:	c7 44 24 0c cc 7b 10 	movl   $0xf0107bcc,0xc(%esp)
f0102728:	f0 
f0102729:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102730:	f0 
f0102731:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0102738:	00 
f0102739:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102740:	e8 fb d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102745:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f010274b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010274e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102753:	89 c8                	mov    %ecx,%eax
f0102755:	e8 36 ea ff ff       	call   f0101190 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010275a:	89 da                	mov    %ebx,%edx
f010275c:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102762:	c1 fa 03             	sar    $0x3,%edx
f0102765:	c1 e2 0c             	shl    $0xc,%edx
f0102768:	39 d0                	cmp    %edx,%eax
f010276a:	74 24                	je     f0102790 <mem_init+0xc29>
f010276c:	c7 44 24 0c 5c 7b 10 	movl   $0xf0107b5c,0xc(%esp)
f0102773:	f0 
f0102774:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010277b:	f0 
f010277c:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102783:	00 
f0102784:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010278b:	e8 b0 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102790:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102795:	74 24                	je     f01027bb <mem_init+0xc54>
f0102797:	c7 44 24 0c c4 83 10 	movl   $0xf01083c4,0xc(%esp)
f010279e:	f0 
f010279f:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01027a6:	f0 
f01027a7:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01027ae:	00 
f01027af:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01027b6:	e8 85 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01027bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027c2:	00 
f01027c3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027ca:	00 
f01027cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027ce:	89 04 24             	mov    %eax,(%esp)
f01027d1:	e8 65 f0 ff ff       	call   f010183b <pgdir_walk>
f01027d6:	f6 00 04             	testb  $0x4,(%eax)
f01027d9:	75 24                	jne    f01027ff <mem_init+0xc98>
f01027db:	c7 44 24 0c 0c 7c 10 	movl   $0xf0107c0c,0xc(%esp)
f01027e2:	f0 
f01027e3:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01027ea:	f0 
f01027eb:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01027f2:	00 
f01027f3:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01027ff:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102804:	f6 00 04             	testb  $0x4,(%eax)
f0102807:	75 24                	jne    f010282d <mem_init+0xcc6>
f0102809:	c7 44 24 0c d5 83 10 	movl   $0xf01083d5,0xc(%esp)
f0102810:	f0 
f0102811:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102818:	f0 
f0102819:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0102820:	00 
f0102821:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102828:	e8 13 d8 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010282d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102834:	00 
f0102835:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010283c:	00 
f010283d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102841:	89 04 24             	mov    %eax,(%esp)
f0102844:	e8 fd f1 ff ff       	call   f0101a46 <page_insert>
f0102849:	85 c0                	test   %eax,%eax
f010284b:	74 24                	je     f0102871 <mem_init+0xd0a>
f010284d:	c7 44 24 0c 20 7b 10 	movl   $0xf0107b20,0xc(%esp)
f0102854:	f0 
f0102855:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010285c:	f0 
f010285d:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102864:	00 
f0102865:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010286c:	e8 cf d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102871:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102878:	00 
f0102879:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102880:	00 
f0102881:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102886:	89 04 24             	mov    %eax,(%esp)
f0102889:	e8 ad ef ff ff       	call   f010183b <pgdir_walk>
f010288e:	f6 00 02             	testb  $0x2,(%eax)
f0102891:	75 24                	jne    f01028b7 <mem_init+0xd50>
f0102893:	c7 44 24 0c 40 7c 10 	movl   $0xf0107c40,0xc(%esp)
f010289a:	f0 
f010289b:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01028a2:	f0 
f01028a3:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f01028aa:	00 
f01028ab:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01028b2:	e8 89 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028be:	00 
f01028bf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028c6:	00 
f01028c7:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01028cc:	89 04 24             	mov    %eax,(%esp)
f01028cf:	e8 67 ef ff ff       	call   f010183b <pgdir_walk>
f01028d4:	f6 00 04             	testb  $0x4,(%eax)
f01028d7:	74 24                	je     f01028fd <mem_init+0xd96>
f01028d9:	c7 44 24 0c 74 7c 10 	movl   $0xf0107c74,0xc(%esp)
f01028e0:	f0 
f01028e1:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01028e8:	f0 
f01028e9:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f01028f0:	00 
f01028f1:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01028f8:	e8 43 d7 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01028fd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102904:	00 
f0102905:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010290c:	00 
f010290d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102911:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102916:	89 04 24             	mov    %eax,(%esp)
f0102919:	e8 28 f1 ff ff       	call   f0101a46 <page_insert>
f010291e:	85 c0                	test   %eax,%eax
f0102920:	78 24                	js     f0102946 <mem_init+0xddf>
f0102922:	c7 44 24 0c ac 7c 10 	movl   $0xf0107cac,0xc(%esp)
f0102929:	f0 
f010292a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102931:	f0 
f0102932:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102939:	00 
f010293a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102941:	e8 fa d6 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102946:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010294d:	00 
f010294e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102955:	00 
f0102956:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010295a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010295f:	89 04 24             	mov    %eax,(%esp)
f0102962:	e8 df f0 ff ff       	call   f0101a46 <page_insert>
f0102967:	85 c0                	test   %eax,%eax
f0102969:	74 24                	je     f010298f <mem_init+0xe28>
f010296b:	c7 44 24 0c e4 7c 10 	movl   $0xf0107ce4,0xc(%esp)
f0102972:	f0 
f0102973:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010297a:	f0 
f010297b:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0102982:	00 
f0102983:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010298a:	e8 b1 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010298f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102996:	00 
f0102997:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010299e:	00 
f010299f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01029a4:	89 04 24             	mov    %eax,(%esp)
f01029a7:	e8 8f ee ff ff       	call   f010183b <pgdir_walk>
f01029ac:	f6 00 04             	testb  $0x4,(%eax)
f01029af:	74 24                	je     f01029d5 <mem_init+0xe6e>
f01029b1:	c7 44 24 0c 74 7c 10 	movl   $0xf0107c74,0xc(%esp)
f01029b8:	f0 
f01029b9:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01029c0:	f0 
f01029c1:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01029c8:	00 
f01029c9:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01029d0:	e8 6b d6 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01029d5:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01029da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01029e2:	e8 a9 e7 ff ff       	call   f0101190 <check_va2pa>
f01029e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029ea:	89 f8                	mov    %edi,%eax
f01029ec:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01029f2:	c1 f8 03             	sar    $0x3,%eax
f01029f5:	c1 e0 0c             	shl    $0xc,%eax
f01029f8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01029fb:	74 24                	je     f0102a21 <mem_init+0xeba>
f01029fd:	c7 44 24 0c 20 7d 10 	movl   $0xf0107d20,0xc(%esp)
f0102a04:	f0 
f0102a05:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102a0c:	f0 
f0102a0d:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102a14:	00 
f0102a15:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102a1c:	e8 1f d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a21:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a29:	e8 62 e7 ff ff       	call   f0101190 <check_va2pa>
f0102a2e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a31:	74 24                	je     f0102a57 <mem_init+0xef0>
f0102a33:	c7 44 24 0c 4c 7d 10 	movl   $0xf0107d4c,0xc(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102a4a:	00 
f0102a4b:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102a52:	e8 e9 d5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102a57:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102a5c:	74 24                	je     f0102a82 <mem_init+0xf1b>
f0102a5e:	c7 44 24 0c eb 83 10 	movl   $0xf01083eb,0xc(%esp)
f0102a65:	f0 
f0102a66:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102a6d:	f0 
f0102a6e:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0102a75:	00 
f0102a76:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102a7d:	e8 be d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a82:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a87:	74 24                	je     f0102aad <mem_init+0xf46>
f0102a89:	c7 44 24 0c fc 83 10 	movl   $0xf01083fc,0xc(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102aa0:	00 
f0102aa1:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102aa8:	e8 93 d5 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102aad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ab4:	e8 a9 ec ff ff       	call   f0101762 <page_alloc>
f0102ab9:	85 c0                	test   %eax,%eax
f0102abb:	74 04                	je     f0102ac1 <mem_init+0xf5a>
f0102abd:	39 c3                	cmp    %eax,%ebx
f0102abf:	74 24                	je     f0102ae5 <mem_init+0xf7e>
f0102ac1:	c7 44 24 0c 7c 7d 10 	movl   $0xf0107d7c,0xc(%esp)
f0102ac8:	f0 
f0102ac9:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102ad0:	f0 
f0102ad1:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102ad8:	00 
f0102ad9:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102ae0:	e8 5b d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102aec:	00 
f0102aed:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102af2:	89 04 24             	mov    %eax,(%esp)
f0102af5:	e8 fc ee ff ff       	call   f01019f6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102afa:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0102b00:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102b03:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b0b:	e8 80 e6 ff ff       	call   f0101190 <check_va2pa>
f0102b10:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b13:	74 24                	je     f0102b39 <mem_init+0xfd2>
f0102b15:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0102b1c:	f0 
f0102b1d:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102b24:	f0 
f0102b25:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0102b2c:	00 
f0102b2d:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102b34:	e8 07 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b39:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b41:	e8 4a e6 ff ff       	call   f0101190 <check_va2pa>
f0102b46:	89 fa                	mov    %edi,%edx
f0102b48:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102b4e:	c1 fa 03             	sar    $0x3,%edx
f0102b51:	c1 e2 0c             	shl    $0xc,%edx
f0102b54:	39 d0                	cmp    %edx,%eax
f0102b56:	74 24                	je     f0102b7c <mem_init+0x1015>
f0102b58:	c7 44 24 0c 4c 7d 10 	movl   $0xf0107d4c,0xc(%esp)
f0102b5f:	f0 
f0102b60:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102b67:	f0 
f0102b68:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0102b6f:	00 
f0102b70:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102b77:	e8 c4 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102b7c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b81:	74 24                	je     f0102ba7 <mem_init+0x1040>
f0102b83:	c7 44 24 0c a2 83 10 	movl   $0xf01083a2,0xc(%esp)
f0102b8a:	f0 
f0102b8b:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102b92:	f0 
f0102b93:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0102b9a:	00 
f0102b9b:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102ba2:	e8 99 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ba7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bac:	74 24                	je     f0102bd2 <mem_init+0x106b>
f0102bae:	c7 44 24 0c fc 83 10 	movl   $0xf01083fc,0xc(%esp)
f0102bb5:	f0 
f0102bb6:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102bbd:	f0 
f0102bbe:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0102bc5:	00 
f0102bc6:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102bcd:	e8 6e d4 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102bd2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102bd9:	00 
f0102bda:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bdd:	89 0c 24             	mov    %ecx,(%esp)
f0102be0:	e8 11 ee ff ff       	call   f01019f6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102be5:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102bea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102bed:	ba 00 00 00 00       	mov    $0x0,%edx
f0102bf2:	e8 99 e5 ff ff       	call   f0101190 <check_va2pa>
f0102bf7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102bfa:	74 24                	je     f0102c20 <mem_init+0x10b9>
f0102bfc:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0102c03:	f0 
f0102c04:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102c0b:	f0 
f0102c0c:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0102c13:	00 
f0102c14:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102c1b:	e8 20 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102c20:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102c25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c28:	e8 63 e5 ff ff       	call   f0101190 <check_va2pa>
f0102c2d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c30:	74 24                	je     f0102c56 <mem_init+0x10ef>
f0102c32:	c7 44 24 0c c4 7d 10 	movl   $0xf0107dc4,0xc(%esp)
f0102c39:	f0 
f0102c3a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102c41:	f0 
f0102c42:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0102c49:	00 
f0102c4a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102c51:	e8 ea d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c56:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c5b:	74 24                	je     f0102c81 <mem_init+0x111a>
f0102c5d:	c7 44 24 0c 0d 84 10 	movl   $0xf010840d,0xc(%esp)
f0102c64:	f0 
f0102c65:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f0102c74:	00 
f0102c75:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102c7c:	e8 bf d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102c81:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c86:	74 24                	je     f0102cac <mem_init+0x1145>
f0102c88:	c7 44 24 0c fc 83 10 	movl   $0xf01083fc,0xc(%esp)
f0102c8f:	f0 
f0102c90:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102c97:	f0 
f0102c98:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102c9f:	00 
f0102ca0:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102ca7:	e8 94 d3 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cb3:	e8 aa ea ff ff       	call   f0101762 <page_alloc>
f0102cb8:	85 c0                	test   %eax,%eax
f0102cba:	74 04                	je     f0102cc0 <mem_init+0x1159>
f0102cbc:	39 c7                	cmp    %eax,%edi
f0102cbe:	74 24                	je     f0102ce4 <mem_init+0x117d>
f0102cc0:	c7 44 24 0c ec 7d 10 	movl   $0xf0107dec,0xc(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102ccf:	f0 
f0102cd0:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0102cd7:	00 
f0102cd8:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102cdf:	e8 5c d3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102ce4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ceb:	e8 72 ea ff ff       	call   f0101762 <page_alloc>
f0102cf0:	85 c0                	test   %eax,%eax
f0102cf2:	74 24                	je     f0102d18 <mem_init+0x11b1>
f0102cf4:	c7 44 24 0c 50 83 10 	movl   $0xf0108350,0xc(%esp)
f0102cfb:	f0 
f0102cfc:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102d03:	f0 
f0102d04:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102d0b:	00 
f0102d0c:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102d13:	e8 28 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d18:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d1d:	8b 08                	mov    (%eax),%ecx
f0102d1f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102d25:	89 f2                	mov    %esi,%edx
f0102d27:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102d2d:	c1 fa 03             	sar    $0x3,%edx
f0102d30:	c1 e2 0c             	shl    $0xc,%edx
f0102d33:	39 d1                	cmp    %edx,%ecx
f0102d35:	74 24                	je     f0102d5b <mem_init+0x11f4>
f0102d37:	c7 44 24 0c c8 7a 10 	movl   $0xf0107ac8,0xc(%esp)
f0102d3e:	f0 
f0102d3f:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102d46:	f0 
f0102d47:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102d4e:	00 
f0102d4f:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102d56:	e8 e5 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d61:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d66:	74 24                	je     f0102d8c <mem_init+0x1225>
f0102d68:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f0102d6f:	f0 
f0102d70:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102d77:	f0 
f0102d78:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f0102d7f:	00 
f0102d80:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102d87:	e8 b4 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d8c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102d92:	89 34 24             	mov    %esi,(%esp)
f0102d95:	e8 46 ea ff ff       	call   f01017e0 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102d9a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102da1:	00 
f0102da2:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102da9:	00 
f0102daa:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102daf:	89 04 24             	mov    %eax,(%esp)
f0102db2:	e8 84 ea ff ff       	call   f010183b <pgdir_walk>
f0102db7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102dba:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0102dc0:	8b 51 04             	mov    0x4(%ecx),%edx
f0102dc3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102dc9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dcc:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f0102dd2:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102dd5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102dd8:	c1 ea 0c             	shr    $0xc,%edx
f0102ddb:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102dde:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102de1:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102de4:	72 23                	jb     f0102e09 <mem_init+0x12a2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102de6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102de9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102ded:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0102df4:	f0 
f0102df5:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f0102dfc:	00 
f0102dfd:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102e09:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e0c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102e12:	39 d0                	cmp    %edx,%eax
f0102e14:	74 24                	je     f0102e3a <mem_init+0x12d3>
f0102e16:	c7 44 24 0c 1e 84 10 	movl   $0xf010841e,0xc(%esp)
f0102e1d:	f0 
f0102e1e:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102e25:	f0 
f0102e26:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102e2d:	00 
f0102e2e:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102e35:	e8 06 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102e3a:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102e41:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e47:	89 f0                	mov    %esi,%eax
f0102e49:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102e4f:	c1 f8 03             	sar    $0x3,%eax
f0102e52:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e55:	89 c1                	mov    %eax,%ecx
f0102e57:	c1 e9 0c             	shr    $0xc,%ecx
f0102e5a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102e5d:	77 20                	ja     f0102e7f <mem_init+0x1318>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e63:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0102e6a:	f0 
f0102e6b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102e72:	00 
f0102e73:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f0102e7a:	e8 c1 d1 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102e7f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102e86:	00 
f0102e87:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102e8e:	00 
	return (void *)(pa + KERNBASE);
f0102e8f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e94:	89 04 24             	mov    %eax,(%esp)
f0102e97:	e8 c5 33 00 00       	call   f0106261 <memset>
	page_free(pp0);
f0102e9c:	89 34 24             	mov    %esi,(%esp)
f0102e9f:	e8 3c e9 ff ff       	call   f01017e0 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102ea4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102eab:	00 
f0102eac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102eb3:	00 
f0102eb4:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102eb9:	89 04 24             	mov    %eax,(%esp)
f0102ebc:	e8 7a e9 ff ff       	call   f010183b <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ec1:	89 f2                	mov    %esi,%edx
f0102ec3:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102ec9:	c1 fa 03             	sar    $0x3,%edx
f0102ecc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ecf:	89 d0                	mov    %edx,%eax
f0102ed1:	c1 e8 0c             	shr    $0xc,%eax
f0102ed4:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0102eda:	72 20                	jb     f0102efc <mem_init+0x1395>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102edc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ee0:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0102ee7:	f0 
f0102ee8:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102eef:	00 
f0102ef0:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f0102ef7:	e8 44 d1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102efc:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102f02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102f05:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102f0c:	75 11                	jne    f0102f1f <mem_init+0x13b8>
f0102f0e:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f14:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102f1a:	f6 00 01             	testb  $0x1,(%eax)
f0102f1d:	74 24                	je     f0102f43 <mem_init+0x13dc>
f0102f1f:	c7 44 24 0c 36 84 10 	movl   $0xf0108436,0xc(%esp)
f0102f26:	f0 
f0102f27:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102f2e:	f0 
f0102f2f:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f0102f36:	00 
f0102f37:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102f3e:	e8 fd d0 ff ff       	call   f0100040 <_panic>
f0102f43:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102f46:	39 d0                	cmp    %edx,%eax
f0102f48:	75 d0                	jne    f0102f1a <mem_init+0x13b3>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102f4a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102f4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102f55:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102f5b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102f5e:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240

	// free the pages we took
	page_free(pp0);
f0102f64:	89 34 24             	mov    %esi,(%esp)
f0102f67:	e8 74 e8 ff ff       	call   f01017e0 <page_free>
	page_free(pp1);
f0102f6c:	89 3c 24             	mov    %edi,(%esp)
f0102f6f:	e8 6c e8 ff ff       	call   f01017e0 <page_free>
	page_free(pp2);
f0102f74:	89 1c 24             	mov    %ebx,(%esp)
f0102f77:	e8 64 e8 ff ff       	call   f01017e0 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102f7c:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102f83:	00 
f0102f84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f8b:	e8 60 eb ff ff       	call   f0101af0 <mmio_map_region>
f0102f90:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102f92:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102f99:	00 
f0102f9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fa1:	e8 4a eb ff ff       	call   f0101af0 <mmio_map_region>
f0102fa6:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102fa8:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102fae:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102fb4:	76 07                	jbe    f0102fbd <mem_init+0x1456>
f0102fb6:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102fbb:	76 24                	jbe    f0102fe1 <mem_init+0x147a>
f0102fbd:	c7 44 24 0c 10 7e 10 	movl   $0xf0107e10,0xc(%esp)
f0102fc4:	f0 
f0102fc5:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0102fcc:	f0 
f0102fcd:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f0102fd4:	00 
f0102fd5:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0102fdc:	e8 5f d0 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102fe1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102fe7:	76 0e                	jbe    f0102ff7 <mem_init+0x1490>
f0102fe9:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102fef:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102ff5:	76 24                	jbe    f010301b <mem_init+0x14b4>
f0102ff7:	c7 44 24 0c 38 7e 10 	movl   $0xf0107e38,0xc(%esp)
f0102ffe:	f0 
f0102fff:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103006:	f0 
f0103007:	c7 44 24 04 9e 04 00 	movl   $0x49e,0x4(%esp)
f010300e:	00 
f010300f:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103016:	e8 25 d0 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010301b:	89 da                	mov    %ebx,%edx
f010301d:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010301f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0103025:	74 24                	je     f010304b <mem_init+0x14e4>
f0103027:	c7 44 24 0c 60 7e 10 	movl   $0xf0107e60,0xc(%esp)
f010302e:	f0 
f010302f:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103036:	f0 
f0103037:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f010303e:	00 
f010303f:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103046:	e8 f5 cf ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010304b:	39 c6                	cmp    %eax,%esi
f010304d:	73 24                	jae    f0103073 <mem_init+0x150c>
f010304f:	c7 44 24 0c 4d 84 10 	movl   $0xf010844d,0xc(%esp)
f0103056:	f0 
f0103057:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010305e:	f0 
f010305f:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f0103066:	00 
f0103067:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010306e:	e8 cd cf ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103073:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0103079:	89 da                	mov    %ebx,%edx
f010307b:	89 f8                	mov    %edi,%eax
f010307d:	e8 0e e1 ff ff       	call   f0101190 <check_va2pa>
f0103082:	85 c0                	test   %eax,%eax
f0103084:	74 24                	je     f01030aa <mem_init+0x1543>
f0103086:	c7 44 24 0c 88 7e 10 	movl   $0xf0107e88,0xc(%esp)
f010308d:	f0 
f010308e:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103095:	f0 
f0103096:	c7 44 24 04 a4 04 00 	movl   $0x4a4,0x4(%esp)
f010309d:	00 
f010309e:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01030a5:	e8 96 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01030aa:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01030b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01030b3:	89 c2                	mov    %eax,%edx
f01030b5:	89 f8                	mov    %edi,%eax
f01030b7:	e8 d4 e0 ff ff       	call   f0101190 <check_va2pa>
f01030bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01030c1:	74 24                	je     f01030e7 <mem_init+0x1580>
f01030c3:	c7 44 24 0c ac 7e 10 	movl   $0xf0107eac,0xc(%esp)
f01030ca:	f0 
f01030cb:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01030d2:	f0 
f01030d3:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
f01030da:	00 
f01030db:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01030e2:	e8 59 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01030e7:	89 f2                	mov    %esi,%edx
f01030e9:	89 f8                	mov    %edi,%eax
f01030eb:	e8 a0 e0 ff ff       	call   f0101190 <check_va2pa>
f01030f0:	85 c0                	test   %eax,%eax
f01030f2:	74 24                	je     f0103118 <mem_init+0x15b1>
f01030f4:	c7 44 24 0c dc 7e 10 	movl   $0xf0107edc,0xc(%esp)
f01030fb:	f0 
f01030fc:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103103:	f0 
f0103104:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f010310b:	00 
f010310c:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103113:	e8 28 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103118:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010311e:	89 f8                	mov    %edi,%eax
f0103120:	e8 6b e0 ff ff       	call   f0101190 <check_va2pa>
f0103125:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103128:	74 24                	je     f010314e <mem_init+0x15e7>
f010312a:	c7 44 24 0c 00 7f 10 	movl   $0xf0107f00,0xc(%esp)
f0103131:	f0 
f0103132:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103139:	f0 
f010313a:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
f0103141:	00 
f0103142:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103149:	e8 f2 ce ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010314e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103155:	00 
f0103156:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010315a:	89 3c 24             	mov    %edi,(%esp)
f010315d:	e8 d9 e6 ff ff       	call   f010183b <pgdir_walk>
f0103162:	f6 00 1a             	testb  $0x1a,(%eax)
f0103165:	75 24                	jne    f010318b <mem_init+0x1624>
f0103167:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f010316e:	f0 
f010316f:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103176:	f0 
f0103177:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f010317e:	00 
f010317f:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103186:	e8 b5 ce ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010318b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103192:	00 
f0103193:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103197:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010319c:	89 04 24             	mov    %eax,(%esp)
f010319f:	e8 97 e6 ff ff       	call   f010183b <pgdir_walk>
f01031a4:	f6 00 04             	testb  $0x4,(%eax)
f01031a7:	74 24                	je     f01031cd <mem_init+0x1666>
f01031a9:	c7 44 24 0c 70 7f 10 	movl   $0xf0107f70,0xc(%esp)
f01031b0:	f0 
f01031b1:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01031b8:	f0 
f01031b9:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f01031c0:	00 
f01031c1:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01031c8:	e8 73 ce ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01031cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031d4:	00 
f01031d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031d9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01031de:	89 04 24             	mov    %eax,(%esp)
f01031e1:	e8 55 e6 ff ff       	call   f010183b <pgdir_walk>
f01031e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01031ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031f3:	00 
f01031f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01031f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01031fb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103200:	89 04 24             	mov    %eax,(%esp)
f0103203:	e8 33 e6 ff ff       	call   f010183b <pgdir_walk>
f0103208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010320e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103215:	00 
f0103216:	89 74 24 04          	mov    %esi,0x4(%esp)
f010321a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010321f:	89 04 24             	mov    %eax,(%esp)
f0103222:	e8 14 e6 ff ff       	call   f010183b <pgdir_walk>
f0103227:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010322d:	c7 04 24 5f 84 10 f0 	movl   $0xf010845f,(%esp)
f0103234:	e8 bd 13 00 00       	call   f01045f6 <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0103239:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103243:	77 20                	ja     f0103265 <mem_init+0x16fe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103245:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103249:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0103250:	f0 
f0103251:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
f0103258:	00 
f0103259:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103260:	e8 db cd ff ff       	call   f0100040 <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f0103265:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f010326b:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0103272:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0103278:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f010327f:	00 
	return (physaddr_t)kva - KERNBASE;
f0103280:	05 00 00 00 10       	add    $0x10000000,%eax
f0103285:	89 04 24             	mov    %eax,(%esp)
f0103288:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010328d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103292:	e8 44 e6 ff ff       	call   f01018db <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(
f0103297:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010329c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032a1:	77 20                	ja     f01032c3 <mem_init+0x175c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032a7:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f01032ae:	f0 
f01032af:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f01032b6:	00 
f01032b7:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01032be:	e8 7d cd ff ff       	call   f0100040 <_panic>
f01032c3:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01032ca:	00 
	return (physaddr_t)kva - KERNBASE;
f01032cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01032d0:	89 04 24             	mov    %eax,(%esp)
f01032d3:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01032d8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01032dd:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01032e2:	e8 f4 e5 ff ff       	call   f01018db <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032e7:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01032ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f1:	77 20                	ja     f0103313 <mem_init+0x17ac>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032f7:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f01032fe:	f0 
f01032ff:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
f0103306:	00 
f0103307:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010330e:	e8 2d cd ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0103313:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010331a:	00 
f010331b:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0103322:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103327:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010332c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103331:	e8 a5 e5 ff ff       	call   f01018db <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(
f0103336:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010333d:	00 
f010333e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103345:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010334a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010334f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103354:	e8 82 e5 ff ff       	call   f01018db <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103359:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
f010335e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103363:	0f 87 d3 07 00 00    	ja     f0103b3c <mem_init+0x1fd5>
f0103369:	eb 0c                	jmp    f0103377 <mem_init+0x1810>
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);

		boot_map_region(
f010336b:	89 d8                	mov    %ebx,%eax
f010336d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103373:	77 27                	ja     f010339c <mem_init+0x1835>
f0103375:	eb 05                	jmp    f010337c <mem_init+0x1815>
f0103377:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103380:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0103387:	f0 
f0103388:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f010338f:	00 
f0103390:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103397:	e8 a4 cc ff ff       	call   f0100040 <_panic>
f010339c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01033a3:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01033a4:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);

		boot_map_region(
f01033aa:	89 04 24             	mov    %eax,(%esp)
f01033ad:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01033b2:	89 f2                	mov    %esi,%edx
f01033b4:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01033b9:	e8 1d e5 ff ff       	call   f01018db <boot_map_region>
f01033be:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01033c4:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
f01033ca:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f01033d0:	75 99                	jne    f010336b <mem_init+0x1804>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01033d2:	8b 1d 8c be 22 f0    	mov    0xf022be8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01033d8:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f01033de:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01033e1:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01033e8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01033ee:	0f 84 80 00 00 00    	je     f0103474 <mem_init+0x190d>
f01033f4:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01033f9:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01033ff:	89 d8                	mov    %ebx,%eax
f0103401:	e8 8a dd ff ff       	call   f0101190 <check_va2pa>
f0103406:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010340c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103412:	77 20                	ja     f0103434 <mem_init+0x18cd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103414:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103418:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f010341f:	f0 
f0103420:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103427:	00 
f0103428:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010342f:	e8 0c cc ff ff       	call   f0100040 <_panic>
f0103434:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010343b:	39 d0                	cmp    %edx,%eax
f010343d:	74 24                	je     f0103463 <mem_init+0x18fc>
f010343f:	c7 44 24 0c a4 7f 10 	movl   $0xf0107fa4,0xc(%esp)
f0103446:	f0 
f0103447:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010344e:	f0 
f010344f:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103456:	00 
f0103457:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010345e:	e8 dd cb ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103463:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103469:	39 f7                	cmp    %esi,%edi
f010346b:	77 8c                	ja     f01033f9 <mem_init+0x1892>
f010346d:	be 00 00 00 00       	mov    $0x0,%esi
f0103472:	eb 05                	jmp    f0103479 <mem_init+0x1912>
f0103474:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103479:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010347f:	89 d8                	mov    %ebx,%eax
f0103481:	e8 0a dd ff ff       	call   f0101190 <check_va2pa>
f0103486:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010348c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103492:	77 20                	ja     f01034b4 <mem_init+0x194d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103494:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103498:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f010349f:	f0 
f01034a0:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034a7:	00 
f01034a8:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01034af:	e8 8c cb ff ff       	call   f0100040 <_panic>
f01034b4:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01034bb:	39 d0                	cmp    %edx,%eax
f01034bd:	74 24                	je     f01034e3 <mem_init+0x197c>
f01034bf:	c7 44 24 0c d8 7f 10 	movl   $0xf0107fd8,0xc(%esp)
f01034c6:	f0 
f01034c7:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01034ce:	f0 
f01034cf:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034d6:	00 
f01034d7:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01034de:	e8 5d cb ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01034e3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01034e9:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f01034ef:	75 88                	jne    f0103479 <mem_init+0x1912>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01034f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01034f4:	c1 e7 0c             	shl    $0xc,%edi
f01034f7:	85 ff                	test   %edi,%edi
f01034f9:	74 44                	je     f010353f <mem_init+0x19d8>
f01034fb:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103500:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103506:	89 d8                	mov    %ebx,%eax
f0103508:	e8 83 dc ff ff       	call   f0101190 <check_va2pa>
f010350d:	39 c6                	cmp    %eax,%esi
f010350f:	74 24                	je     f0103535 <mem_init+0x19ce>
f0103511:	c7 44 24 0c 0c 80 10 	movl   $0xf010800c,0xc(%esp)
f0103518:	f0 
f0103519:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103520:	f0 
f0103521:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0103528:	00 
f0103529:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103530:	e8 0b cb ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103535:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010353b:	39 fe                	cmp    %edi,%esi
f010353d:	72 c1                	jb     f0103500 <mem_init+0x1999>
f010353f:	c7 45 cc 00 d0 22 f0 	movl   $0xf022d000,-0x34(%ebp)
f0103546:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)
f010354d:	89 df                	mov    %ebx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010354f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103552:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103555:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103558:	81 c3 00 80 00 00    	add    $0x8000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010355e:	89 c6                	mov    %eax,%esi
f0103560:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103566:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103569:	81 c2 00 00 01 00    	add    $0x10000,%edx
f010356f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103572:	89 da                	mov    %ebx,%edx
f0103574:	89 f8                	mov    %edi,%eax
f0103576:	e8 15 dc ff ff       	call   f0101190 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010357b:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103582:	77 23                	ja     f01035a7 <mem_init+0x1a40>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103584:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103587:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010358b:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0103592:	f0 
f0103593:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010359a:	00 
f010359b:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01035a2:	e8 99 ca ff ff       	call   f0100040 <_panic>
f01035a7:	39 f0                	cmp    %esi,%eax
f01035a9:	74 24                	je     f01035cf <mem_init+0x1a68>
f01035ab:	c7 44 24 0c 34 80 10 	movl   $0xf0108034,0xc(%esp)
f01035b2:	f0 
f01035b3:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01035ba:	f0 
f01035bb:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01035c2:	00 
f01035c3:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01035ca:	e8 71 ca ff ff       	call   f0100040 <_panic>
f01035cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035d5:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01035db:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01035de:	0f 85 8a 05 00 00    	jne    f0103b6e <mem_init+0x2007>
f01035e4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01035e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01035ec:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01035ef:	89 f8                	mov    %edi,%eax
f01035f1:	e8 9a db ff ff       	call   f0101190 <check_va2pa>
f01035f6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01035f9:	74 24                	je     f010361f <mem_init+0x1ab8>
f01035fb:	c7 44 24 0c 7c 80 10 	movl   $0xf010807c,0xc(%esp)
f0103602:	f0 
f0103603:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f010360a:	f0 
f010360b:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0103612:	00 
f0103613:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010361a:	e8 21 ca ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010361f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103625:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010362b:	75 bf                	jne    f01035ec <mem_init+0x1a85>
f010362d:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0103634:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010363b:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f0103642:	0f 85 07 ff ff ff    	jne    f010354f <mem_init+0x19e8>
f0103648:	89 fb                	mov    %edi,%ebx
f010364a:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010364f:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103655:	83 fa 04             	cmp    $0x4,%edx
f0103658:	77 2e                	ja     f0103688 <mem_init+0x1b21>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010365a:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010365e:	0f 85 aa 00 00 00    	jne    f010370e <mem_init+0x1ba7>
f0103664:	c7 44 24 0c 78 84 10 	movl   $0xf0108478,0xc(%esp)
f010366b:	f0 
f010366c:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103673:	f0 
f0103674:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f010367b:	00 
f010367c:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103683:	e8 b8 c9 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103688:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010368d:	76 55                	jbe    f01036e4 <mem_init+0x1b7d>
				assert(pgdir[i] & PTE_P);
f010368f:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103692:	f6 c2 01             	test   $0x1,%dl
f0103695:	75 24                	jne    f01036bb <mem_init+0x1b54>
f0103697:	c7 44 24 0c 78 84 10 	movl   $0xf0108478,0xc(%esp)
f010369e:	f0 
f010369f:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01036a6:	f0 
f01036a7:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01036ae:	00 
f01036af:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01036b6:	e8 85 c9 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01036bb:	f6 c2 02             	test   $0x2,%dl
f01036be:	75 4e                	jne    f010370e <mem_init+0x1ba7>
f01036c0:	c7 44 24 0c 89 84 10 	movl   $0xf0108489,0xc(%esp)
f01036c7:	f0 
f01036c8:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01036cf:	f0 
f01036d0:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01036d7:	00 
f01036d8:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01036df:	e8 5c c9 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01036e4:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01036e8:	74 24                	je     f010370e <mem_init+0x1ba7>
f01036ea:	c7 44 24 0c 9a 84 10 	movl   $0xf010849a,0xc(%esp)
f01036f1:	f0 
f01036f2:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01036f9:	f0 
f01036fa:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0103701:	00 
f0103702:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103709:	e8 32 c9 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010370e:	83 c0 01             	add    $0x1,%eax
f0103711:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103716:	0f 85 33 ff ff ff    	jne    f010364f <mem_init+0x1ae8>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010371c:	c7 04 24 a0 80 10 f0 	movl   $0xf01080a0,(%esp)
f0103723:	e8 ce 0e 00 00       	call   f01045f6 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103728:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010372d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103732:	77 20                	ja     f0103754 <mem_init+0x1bed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103734:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103738:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f010373f:	f0 
f0103740:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f0103747:	00 
f0103748:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f010374f:	e8 ec c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103754:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103759:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010375c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103761:	e8 86 db ff ff       	call   f01012ec <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103766:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103769:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010376e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103771:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103774:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010377b:	e8 e2 df ff ff       	call   f0101762 <page_alloc>
f0103780:	89 c6                	mov    %eax,%esi
f0103782:	85 c0                	test   %eax,%eax
f0103784:	75 24                	jne    f01037aa <mem_init+0x1c43>
f0103786:	c7 44 24 0c a5 82 10 	movl   $0xf01082a5,0xc(%esp)
f010378d:	f0 
f010378e:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103795:	f0 
f0103796:	c7 44 24 04 bf 04 00 	movl   $0x4bf,0x4(%esp)
f010379d:	00 
f010379e:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01037a5:	e8 96 c8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01037aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037b1:	e8 ac df ff ff       	call   f0101762 <page_alloc>
f01037b6:	89 c7                	mov    %eax,%edi
f01037b8:	85 c0                	test   %eax,%eax
f01037ba:	75 24                	jne    f01037e0 <mem_init+0x1c79>
f01037bc:	c7 44 24 0c bb 82 10 	movl   $0xf01082bb,0xc(%esp)
f01037c3:	f0 
f01037c4:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01037cb:	f0 
f01037cc:	c7 44 24 04 c0 04 00 	movl   $0x4c0,0x4(%esp)
f01037d3:	00 
f01037d4:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01037db:	e8 60 c8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01037e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037e7:	e8 76 df ff ff       	call   f0101762 <page_alloc>
f01037ec:	89 c3                	mov    %eax,%ebx
f01037ee:	85 c0                	test   %eax,%eax
f01037f0:	75 24                	jne    f0103816 <mem_init+0x1caf>
f01037f2:	c7 44 24 0c d1 82 10 	movl   $0xf01082d1,0xc(%esp)
f01037f9:	f0 
f01037fa:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103801:	f0 
f0103802:	c7 44 24 04 c1 04 00 	movl   $0x4c1,0x4(%esp)
f0103809:	00 
f010380a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103811:	e8 2a c8 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103816:	89 34 24             	mov    %esi,(%esp)
f0103819:	e8 c2 df ff ff       	call   f01017e0 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010381e:	89 f8                	mov    %edi,%eax
f0103820:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103826:	c1 f8 03             	sar    $0x3,%eax
f0103829:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010382c:	89 c2                	mov    %eax,%edx
f010382e:	c1 ea 0c             	shr    $0xc,%edx
f0103831:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0103837:	72 20                	jb     f0103859 <mem_init+0x1cf2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103839:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010383d:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0103844:	f0 
f0103845:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f010384c:	00 
f010384d:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f0103854:	e8 e7 c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103859:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103860:	00 
f0103861:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103868:	00 
	return (void *)(pa + KERNBASE);
f0103869:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010386e:	89 04 24             	mov    %eax,(%esp)
f0103871:	e8 eb 29 00 00       	call   f0106261 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103876:	89 d8                	mov    %ebx,%eax
f0103878:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010387e:	c1 f8 03             	sar    $0x3,%eax
f0103881:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103884:	89 c2                	mov    %eax,%edx
f0103886:	c1 ea 0c             	shr    $0xc,%edx
f0103889:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010388f:	72 20                	jb     f01038b1 <mem_init+0x1d4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103891:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103895:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f010389c:	f0 
f010389d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01038a4:	00 
f01038a5:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f01038ac:	e8 8f c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01038b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038b8:	00 
f01038b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01038c0:	00 
	return (void *)(pa + KERNBASE);
f01038c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038c6:	89 04 24             	mov    %eax,(%esp)
f01038c9:	e8 93 29 00 00       	call   f0106261 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01038ce:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01038d5:	00 
f01038d6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038dd:	00 
f01038de:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038e2:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01038e7:	89 04 24             	mov    %eax,(%esp)
f01038ea:	e8 57 e1 ff ff       	call   f0101a46 <page_insert>
	assert(pp1->pp_ref == 1);
f01038ef:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01038f4:	74 24                	je     f010391a <mem_init+0x1db3>
f01038f6:	c7 44 24 0c a2 83 10 	movl   $0xf01083a2,0xc(%esp)
f01038fd:	f0 
f01038fe:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103905:	f0 
f0103906:	c7 44 24 04 c6 04 00 	movl   $0x4c6,0x4(%esp)
f010390d:	00 
f010390e:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103915:	e8 26 c7 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010391a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103921:	01 01 01 
f0103924:	74 24                	je     f010394a <mem_init+0x1de3>
f0103926:	c7 44 24 0c c0 80 10 	movl   $0xf01080c0,0xc(%esp)
f010392d:	f0 
f010392e:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103935:	f0 
f0103936:	c7 44 24 04 c7 04 00 	movl   $0x4c7,0x4(%esp)
f010393d:	00 
f010393e:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103945:	e8 f6 c6 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010394a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103951:	00 
f0103952:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103959:	00 
f010395a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010395e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103963:	89 04 24             	mov    %eax,(%esp)
f0103966:	e8 db e0 ff ff       	call   f0101a46 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010396b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103972:	02 02 02 
f0103975:	74 24                	je     f010399b <mem_init+0x1e34>
f0103977:	c7 44 24 0c e4 80 10 	movl   $0xf01080e4,0xc(%esp)
f010397e:	f0 
f010397f:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103986:	f0 
f0103987:	c7 44 24 04 c9 04 00 	movl   $0x4c9,0x4(%esp)
f010398e:	00 
f010398f:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103996:	e8 a5 c6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010399b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01039a0:	74 24                	je     f01039c6 <mem_init+0x1e5f>
f01039a2:	c7 44 24 0c c4 83 10 	movl   $0xf01083c4,0xc(%esp)
f01039a9:	f0 
f01039aa:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01039b1:	f0 
f01039b2:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f01039b9:	00 
f01039ba:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01039c1:	e8 7a c6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01039c6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01039cb:	74 24                	je     f01039f1 <mem_init+0x1e8a>
f01039cd:	c7 44 24 0c 0d 84 10 	movl   $0xf010840d,0xc(%esp)
f01039d4:	f0 
f01039d5:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f01039dc:	f0 
f01039dd:	c7 44 24 04 cb 04 00 	movl   $0x4cb,0x4(%esp)
f01039e4:	00 
f01039e5:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f01039ec:	e8 4f c6 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01039f1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01039f8:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01039fb:	89 d8                	mov    %ebx,%eax
f01039fd:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103a03:	c1 f8 03             	sar    $0x3,%eax
f0103a06:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a09:	89 c2                	mov    %eax,%edx
f0103a0b:	c1 ea 0c             	shr    $0xc,%edx
f0103a0e:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0103a14:	72 20                	jb     f0103a36 <mem_init+0x1ecf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a1a:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0103a21:	f0 
f0103a22:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103a29:	00 
f0103a2a:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f0103a31:	e8 0a c6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103a36:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103a3d:	03 03 03 
f0103a40:	74 24                	je     f0103a66 <mem_init+0x1eff>
f0103a42:	c7 44 24 0c 08 81 10 	movl   $0xf0108108,0xc(%esp)
f0103a49:	f0 
f0103a4a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103a51:	f0 
f0103a52:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f0103a59:	00 
f0103a5a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103a61:	e8 da c5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103a66:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103a6d:	00 
f0103a6e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103a73:	89 04 24             	mov    %eax,(%esp)
f0103a76:	e8 7b df ff ff       	call   f01019f6 <page_remove>
	assert(pp2->pp_ref == 0);
f0103a7b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103a80:	74 24                	je     f0103aa6 <mem_init+0x1f3f>
f0103a82:	c7 44 24 0c fc 83 10 	movl   $0xf01083fc,0xc(%esp)
f0103a89:	f0 
f0103a8a:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103a91:	f0 
f0103a92:	c7 44 24 04 cf 04 00 	movl   $0x4cf,0x4(%esp)
f0103a99:	00 
f0103a9a:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103aa1:	e8 9a c5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103aa6:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103aab:	8b 08                	mov    (%eax),%ecx
f0103aad:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103ab3:	89 f2                	mov    %esi,%edx
f0103ab5:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0103abb:	c1 fa 03             	sar    $0x3,%edx
f0103abe:	c1 e2 0c             	shl    $0xc,%edx
f0103ac1:	39 d1                	cmp    %edx,%ecx
f0103ac3:	74 24                	je     f0103ae9 <mem_init+0x1f82>
f0103ac5:	c7 44 24 0c c8 7a 10 	movl   $0xf0107ac8,0xc(%esp)
f0103acc:	f0 
f0103acd:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103ad4:	f0 
f0103ad5:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
f0103adc:	00 
f0103add:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103ae4:	e8 57 c5 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103ae9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103aef:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103af4:	74 24                	je     f0103b1a <mem_init+0x1fb3>
f0103af6:	c7 44 24 0c b3 83 10 	movl   $0xf01083b3,0xc(%esp)
f0103afd:	f0 
f0103afe:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0103b05:	f0 
f0103b06:	c7 44 24 04 d4 04 00 	movl   $0x4d4,0x4(%esp)
f0103b0d:	00 
f0103b0e:	c7 04 24 95 81 10 f0 	movl   $0xf0108195,(%esp)
f0103b15:	e8 26 c5 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103b1a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103b20:	89 34 24             	mov    %esi,(%esp)
f0103b23:	e8 b8 dc ff ff       	call   f01017e0 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103b28:	c7 04 24 34 81 10 f0 	movl   $0xf0108134,(%esp)
f0103b2f:	e8 c2 0a 00 00       	call   f01045f6 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103b34:	83 c4 3c             	add    $0x3c,%esp
f0103b37:	5b                   	pop    %ebx
f0103b38:	5e                   	pop    %esi
f0103b39:	5f                   	pop    %edi
f0103b3a:	5d                   	pop    %ebp
f0103b3b:	c3                   	ret    
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);

		boot_map_region(
f0103b3c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103b43:	00 
f0103b44:	c7 04 24 00 d0 22 00 	movl   $0x22d000,(%esp)
f0103b4b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103b50:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103b55:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103b5a:	e8 7c dd ff ff       	call   f01018db <boot_map_region>
f0103b5f:	bb 00 50 23 f0       	mov    $0xf0235000,%ebx
f0103b64:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f0103b69:	e9 fd f7 ff ff       	jmp    f010336b <mem_init+0x1804>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103b6e:	89 da                	mov    %ebx,%edx
f0103b70:	89 f8                	mov    %edi,%eax
f0103b72:	e8 19 d6 ff ff       	call   f0101190 <check_va2pa>
f0103b77:	e9 2b fa ff ff       	jmp    f01035a7 <mem_init+0x1a40>

f0103b7c <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103b7c:	55                   	push   %ebp
f0103b7d:	89 e5                	mov    %esp,%ebp
f0103b7f:	57                   	push   %edi
f0103b80:	56                   	push   %esi
f0103b81:	53                   	push   %ebx
f0103b82:	83 ec 2c             	sub    $0x2c,%esp
f0103b85:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b88:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
//cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0103b8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b8e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
f0103b94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b97:	03 45 10             	add    0x10(%ebp),%eax
f0103b9a:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103b9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103ba4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	}

//cprintf("user_mem_check success va: %x, len: %x\n", va, len);

	return 0;
f0103ba7:	b8 00 00 00 00       	mov    $0x0,%eax
	// LAB 3: Your code here.
//cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f0103bac:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103baf:	73 53                	jae    f0103c04 <user_mem_check+0x88>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)_va_start, 0);
f0103bb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103bb8:	00 
f0103bb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103bbd:	8b 46 60             	mov    0x60(%esi),%eax
f0103bc0:	89 04 24             	mov    %eax,(%esp)
f0103bc3:	e8 73 dc ff ff       	call   f010183b <pgdir_walk>

        if ((_va_start>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0103bc8:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103bce:	77 10                	ja     f0103be0 <user_mem_check+0x64>
f0103bd0:	85 c0                	test   %eax,%eax
f0103bd2:	74 0c                	je     f0103be0 <user_mem_check+0x64>
f0103bd4:	8b 00                	mov    (%eax),%eax
f0103bd6:	a8 01                	test   $0x1,%al
f0103bd8:	74 06                	je     f0103be0 <user_mem_check+0x64>
f0103bda:	21 f8                	and    %edi,%eax
f0103bdc:	39 c7                	cmp    %eax,%edi
f0103bde:	74 14                	je     f0103bf4 <user_mem_check+0x78>
            user_mem_check_addr = (_va_start<(uint32_t)va) ? (uint32_t)va : _va_start;
f0103be0:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103be3:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103be7:	89 1d 44 b2 22 f0    	mov    %ebx,0xf022b244
//cprintf("user_mem_check fail va: %x, len: %x\n", va, len);
            return -E_FAULT;
f0103bed:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103bf2:	eb 10                	jmp    f0103c04 <user_mem_check+0x88>
	// LAB 3: Your code here.
//cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f0103bf4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103bfa:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103bfd:	77 b2                	ja     f0103bb1 <user_mem_check+0x35>

	}

//cprintf("user_mem_check success va: %x, len: %x\n", va, len);

	return 0;
f0103bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c04:	83 c4 2c             	add    $0x2c,%esp
f0103c07:	5b                   	pop    %ebx
f0103c08:	5e                   	pop    %esi
f0103c09:	5f                   	pop    %edi
f0103c0a:	5d                   	pop    %ebp
f0103c0b:	c3                   	ret    

f0103c0c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103c0c:	55                   	push   %ebp
f0103c0d:	89 e5                	mov    %esp,%ebp
f0103c0f:	53                   	push   %ebx
f0103c10:	83 ec 14             	sub    $0x14,%esp
f0103c13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103c16:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c19:	83 c8 04             	or     $0x4,%eax
f0103c1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c20:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c23:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c2e:	89 1c 24             	mov    %ebx,(%esp)
f0103c31:	e8 46 ff ff ff       	call   f0103b7c <user_mem_check>
f0103c36:	85 c0                	test   %eax,%eax
f0103c38:	79 24                	jns    f0103c5e <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103c3a:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f0103c3f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c43:	8b 43 48             	mov    0x48(%ebx),%eax
f0103c46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c4a:	c7 04 24 60 81 10 f0 	movl   $0xf0108160,(%esp)
f0103c51:	e8 a0 09 00 00       	call   f01045f6 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103c56:	89 1c 24             	mov    %ebx,(%esp)
f0103c59:	e8 b7 06 00 00       	call   f0104315 <env_destroy>
	}
}
f0103c5e:	83 c4 14             	add    $0x14,%esp
f0103c61:	5b                   	pop    %ebx
f0103c62:	5d                   	pop    %ebp
f0103c63:	c3                   	ret    

f0103c64 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103c64:	55                   	push   %ebp
f0103c65:	89 e5                	mov    %esp,%ebp
f0103c67:	57                   	push   %edi
f0103c68:	56                   	push   %esi
f0103c69:	53                   	push   %ebx
f0103c6a:	83 ec 2c             	sub    $0x2c,%esp
f0103c6d:	89 c7                	mov    %eax,%edi
	//   (Watch out for corner-cases!)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
f0103c6f:	89 d3                	mov    %edx,%ebx
f0103c71:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103c77:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0103c7d:	c1 e8 0c             	shr    $0xc,%eax
f0103c80:	85 c0                	test   %eax,%eax
f0103c82:	74 5d                	je     f0103ce1 <region_alloc+0x7d>
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
f0103c84:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103c87:	be 00 00 00 00       	mov    $0x0,%esi
		struct PageInfo *p = page_alloc(0);
f0103c8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103c93:	e8 ca da ff ff       	call   f0101762 <page_alloc>
		if(!p)
f0103c98:	85 c0                	test   %eax,%eax
f0103c9a:	75 1c                	jne    f0103cb8 <region_alloc+0x54>
			panic("region_alloc failed!");
f0103c9c:	c7 44 24 08 a8 84 10 	movl   $0xf01084a8,0x8(%esp)
f0103ca3:	f0 
f0103ca4:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0103cab:	00 
f0103cac:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f0103cb3:	e8 88 c3 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
f0103cb8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103cbf:	00 
f0103cc0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cc8:	8b 47 60             	mov    0x60(%edi),%eax
f0103ccb:	89 04 24             	mov    %eax,(%esp)
f0103cce:	e8 73 dd ff ff       	call   f0101a46 <page_insert>

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103cd3:	83 c6 01             	add    $0x1,%esi
f0103cd6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103cdc:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103cdf:	75 ab                	jne    f0103c8c <region_alloc+0x28>
		struct PageInfo *p = page_alloc(0);
		if(!p)
			panic("region_alloc failed!");
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
	}
}
f0103ce1:	83 c4 2c             	add    $0x2c,%esp
f0103ce4:	5b                   	pop    %ebx
f0103ce5:	5e                   	pop    %esi
f0103ce6:	5f                   	pop    %edi
f0103ce7:	5d                   	pop    %ebp
f0103ce8:	c3                   	ret    

f0103ce9 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103ce9:	55                   	push   %ebp
f0103cea:	89 e5                	mov    %esp,%ebp
f0103cec:	83 ec 18             	sub    $0x18,%esp
f0103cef:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103cf2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103cf5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103cf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cfb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103cfe:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103d02:	85 c0                	test   %eax,%eax
f0103d04:	75 17                	jne    f0103d1d <envid2env+0x34>
		*env_store = curenv;
f0103d06:	e8 e5 2b 00 00       	call   f01068f0 <cpunum>
f0103d0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d14:	89 06                	mov    %eax,(%esi)
		return 0;
f0103d16:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d1b:	eb 67                	jmp    f0103d84 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103d1d:	89 c3                	mov    %eax,%ebx
f0103d1f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103d25:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103d28:	03 1d 48 b2 22 f0    	add    0xf022b248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103d2e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103d32:	74 05                	je     f0103d39 <envid2env+0x50>
f0103d34:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103d37:	74 0d                	je     f0103d46 <envid2env+0x5d>
		*env_store = 0;
f0103d39:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103d3f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103d44:	eb 3e                	jmp    f0103d84 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103d46:	84 d2                	test   %dl,%dl
f0103d48:	74 33                	je     f0103d7d <envid2env+0x94>
f0103d4a:	e8 a1 2b 00 00       	call   f01068f0 <cpunum>
f0103d4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d52:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103d58:	74 23                	je     f0103d7d <envid2env+0x94>
f0103d5a:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103d5d:	e8 8e 2b 00 00       	call   f01068f0 <cpunum>
f0103d62:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d65:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d6b:	3b 78 48             	cmp    0x48(%eax),%edi
f0103d6e:	74 0d                	je     f0103d7d <envid2env+0x94>
		*env_store = 0;
f0103d70:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103d76:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103d7b:	eb 07                	jmp    f0103d84 <envid2env+0x9b>
	}

	*env_store = e;
f0103d7d:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103d87:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103d8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103d8d:	89 ec                	mov    %ebp,%esp
f0103d8f:	5d                   	pop    %ebp
f0103d90:	c3                   	ret    

f0103d91 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103d91:	55                   	push   %ebp
f0103d92:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103d94:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103d99:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103d9c:	b8 23 00 00 00       	mov    $0x23,%eax
f0103da1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103da3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103da5:	b0 10                	mov    $0x10,%al
f0103da7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103da9:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103dab:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103dad:	ea b4 3d 10 f0 08 00 	ljmp   $0x8,$0xf0103db4
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103db4:	b0 00                	mov    $0x0,%al
f0103db6:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103db9:	5d                   	pop    %ebp
f0103dba:	c3                   	ret    

f0103dbb <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103dbb:	55                   	push   %ebp
f0103dbc:	89 e5                	mov    %esp,%ebp
f0103dbe:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	envs[0].env_id = 0;
f0103dbf:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
f0103dc5:	c7 42 48 00 00 00 00 	movl   $0x0,0x48(%edx)
	env_free_list = envs;
f0103dcc:	89 15 4c b2 22 f0    	mov    %edx,0xf022b24c
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103dd2:	8d 42 7c             	lea    0x7c(%edx),%eax
f0103dd5:	8d 9a 00 f0 01 00    	lea    0x1f000(%edx),%ebx
f0103ddb:	eb 02                	jmp    f0103ddf <env_init+0x24>

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
		_env->env_link = &envs[i];
		_env = _env->env_link;
f0103ddd:	89 ca                	mov    %ecx,%edx
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
f0103ddf:	89 c1                	mov    %eax,%ecx
f0103de1:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		_env->env_link = &envs[i];
f0103de8:	89 42 44             	mov    %eax,0x44(%edx)
f0103deb:	83 c0 7c             	add    $0x7c,%eax
	envs[0].env_id = 0;
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
f0103dee:	39 d8                	cmp    %ebx,%eax
f0103df0:	75 eb                	jne    f0103ddd <env_init+0x22>
		_env->env_link = &envs[i];
		_env = _env->env_link;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103df2:	e8 9a ff ff ff       	call   f0103d91 <env_init_percpu>
}
f0103df7:	5b                   	pop    %ebx
f0103df8:	5d                   	pop    %ebp
f0103df9:	c3                   	ret    

f0103dfa <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103dfa:	55                   	push   %ebp
f0103dfb:	89 e5                	mov    %esp,%ebp
f0103dfd:	53                   	push   %ebx
f0103dfe:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103e01:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
f0103e07:	85 db                	test   %ebx,%ebx
f0103e09:	0f 84 87 01 00 00    	je     f0103f96 <env_alloc+0x19c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103e0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103e16:	e8 47 d9 ff ff       	call   f0101762 <page_alloc>
f0103e1b:	85 c0                	test   %eax,%eax
f0103e1d:	0f 84 7a 01 00 00    	je     f0103f9d <env_alloc+0x1a3>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	/*************************** LAB 3: Your code here.***************************/
	p->pp_ref ++;
f0103e23:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103e28:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103e2e:	c1 f8 03             	sar    $0x3,%eax
f0103e31:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e34:	89 c2                	mov    %eax,%edx
f0103e36:	c1 ea 0c             	shr    $0xc,%edx
f0103e39:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0103e3f:	72 20                	jb     f0103e61 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e45:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0103e4c:	f0 
f0103e4d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103e54:	00 
f0103e55:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f0103e5c:	e8 df c1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103e61:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0103e66:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103e69:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103e70:	00 
f0103e71:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0103e77:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e7b:	89 04 24             	mov    %eax,(%esp)
f0103e7e:	e8 b2 24 00 00       	call   f0106335 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103e83:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e86:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e8b:	77 20                	ja     f0103ead <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e91:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0103e98:	f0 
f0103e99:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0103ea0:	00 
f0103ea1:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f0103ea8:	e8 93 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ead:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103eb3:	83 ca 05             	or     $0x5,%edx
f0103eb6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103ebc:	8b 43 48             	mov    0x48(%ebx),%eax
f0103ebf:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103ec4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103ec9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103ece:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103ed1:	89 da                	mov    %ebx,%edx
f0103ed3:	2b 15 48 b2 22 f0    	sub    0xf022b248,%edx
f0103ed9:	c1 fa 02             	sar    $0x2,%edx
f0103edc:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103ee2:	09 d0                	or     %edx,%eax
f0103ee4:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103eea:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103eed:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103ef4:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103efb:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103f02:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103f09:	00 
f0103f0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103f11:	00 
f0103f12:	89 1c 24             	mov    %ebx,(%esp)
f0103f15:	e8 47 23 00 00       	call   f0106261 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103f1a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103f20:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103f26:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103f2c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103f33:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103f39:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103f40:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103f44:	8b 43 44             	mov    0x44(%ebx),%eax
f0103f47:	a3 4c b2 22 f0       	mov    %eax,0xf022b24c
	*newenv_store = e;
f0103f4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f4f:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103f51:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103f54:	e8 97 29 00 00       	call   f01068f0 <cpunum>
f0103f59:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f5c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f61:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103f68:	74 11                	je     f0103f7b <env_alloc+0x181>
f0103f6a:	e8 81 29 00 00       	call   f01068f0 <cpunum>
f0103f6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f72:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103f78:	8b 50 48             	mov    0x48(%eax),%edx
f0103f7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103f7f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f83:	c7 04 24 c8 84 10 f0 	movl   $0xf01084c8,(%esp)
f0103f8a:	e8 67 06 00 00       	call   f01045f6 <cprintf>
	return 0;
f0103f8f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f94:	eb 0c                	jmp    f0103fa2 <env_alloc+0x1a8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103f96:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103f9b:	eb 05                	jmp    f0103fa2 <env_alloc+0x1a8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103f9d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103fa2:	83 c4 14             	add    $0x14,%esp
f0103fa5:	5b                   	pop    %ebx
f0103fa6:	5d                   	pop    %ebp
f0103fa7:	c3                   	ret    

f0103fa8 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103fa8:	55                   	push   %ebp
f0103fa9:	89 e5                	mov    %esp,%ebp
f0103fab:	57                   	push   %edi
f0103fac:	56                   	push   %esi
f0103fad:	53                   	push   %ebx
f0103fae:	83 ec 3c             	sub    $0x3c,%esp
f0103fb1:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int res;
	if ((res = env_alloc(&env, 0)))
f0103fb4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fbb:	00 
f0103fbc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103fbf:	89 04 24             	mov    %eax,(%esp)
f0103fc2:	e8 33 fe ff ff       	call   f0103dfa <env_alloc>
f0103fc7:	85 c0                	test   %eax,%eax
f0103fc9:	74 20                	je     f0103feb <env_create+0x43>
		panic("env_create: %e", res);
f0103fcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fcf:	c7 44 24 08 dd 84 10 	movl   $0xf01084dd,0x8(%esp)
f0103fd6:	f0 
f0103fd7:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0103fde:	00 
f0103fdf:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f0103fe6:	e8 55 c0 ff ff       	call   f0100040 <_panic>

	load_icode(env, binary, size);
f0103feb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103fee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
f0103ff1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103ff7:	74 1c                	je     f0104015 <env_create+0x6d>
		panic("Invalid ELF!");
f0103ff9:	c7 44 24 08 ec 84 10 	movl   $0xf01084ec,0x8(%esp)
f0104000:	f0 
f0104001:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
f0104008:	00 
f0104009:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f0104010:	e8 2b c0 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0104015:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f0104018:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
f010401c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010401f:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104022:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104027:	77 20                	ja     f0104049 <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104029:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010402d:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0104034:	f0 
f0104035:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f010403c:	00 
f010403d:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f0104044:	e8 f7 bf ff ff       	call   f0100040 <_panic>
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
		panic("Invalid ELF!");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0104049:	01 fb                	add    %edi,%ebx
	eph = ph + elf->e_phnum;
f010404b:	0f b7 f6             	movzwl %si,%esi
f010404e:	c1 e6 05             	shl    $0x5,%esi
f0104051:	01 de                	add    %ebx,%esi
	return (physaddr_t)kva - KERNBASE;
f0104053:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104058:	0f 22 d8             	mov    %eax,%cr3

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f010405b:	39 f3                	cmp    %esi,%ebx
f010405d:	73 4f                	jae    f01040ae <env_create+0x106>
		if (ph->p_type != ELF_PROG_LOAD)
f010405f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0104062:	75 43                	jne    f01040a7 <env_create+0xff>
			continue;
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0104064:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0104067:	8b 53 08             	mov    0x8(%ebx),%edx
f010406a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010406d:	e8 f2 fb ff ff       	call   f0103c64 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f0104072:	8b 43 14             	mov    0x14(%ebx),%eax
f0104075:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104079:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104080:	00 
f0104081:	8b 43 08             	mov    0x8(%ebx),%eax
f0104084:	89 04 24             	mov    %eax,(%esp)
f0104087:	e8 d5 21 00 00       	call   f0106261 <memset>
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010408c:	8b 43 10             	mov    0x10(%ebx),%eax
f010408f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104093:	89 f8                	mov    %edi,%eax
f0104095:	03 43 04             	add    0x4(%ebx),%eax
f0104098:	89 44 24 04          	mov    %eax,0x4(%esp)
f010409c:	8b 43 08             	mov    0x8(%ebx),%eax
f010409f:	89 04 24             	mov    %eax,(%esp)
f01040a2:	e8 15 22 00 00       	call   f01062bc <memmove>
	eph = ph + elf->e_phnum;

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f01040a7:	83 c3 20             	add    $0x20,%ebx
f01040aa:	39 de                	cmp    %ebx,%esi
f01040ac:	77 b1                	ja     f010405f <env_create+0xb7>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
		memset((void*)ph->p_va, 0, ph->p_memsz);
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}
	// switch back to kernel page directory
	lcr3(PADDR(kern_pgdir));
f01040ae:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040b8:	77 20                	ja     f01040da <env_create+0x132>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040be:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f01040c5:	f0 
f01040c6:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f01040cd:	00 
f01040ce:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f01040d5:	e8 66 bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01040da:	05 00 00 00 10       	add    $0x10000000,%eax
f01040df:	0f 22 d8             	mov    %eax,%cr3

	(e->env_tf).tf_eip = (uintptr_t)(elf->e_entry);
f01040e2:	8b 47 18             	mov    0x18(%edi),%eax
f01040e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01040e8:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f01040eb:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01040f0:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01040f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040f8:	e8 67 fb ff ff       	call   f0103c64 <region_alloc>
	if ((res = env_alloc(&env, 0)))
		panic("env_create: %e", res);

	load_icode(env, binary, size);

	env->env_type = type;
f01040fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104100:	8b 55 10             	mov    0x10(%ebp),%edx
f0104103:	89 50 50             	mov    %edx,0x50(%eax)
}
f0104106:	83 c4 3c             	add    $0x3c,%esp
f0104109:	5b                   	pop    %ebx
f010410a:	5e                   	pop    %esi
f010410b:	5f                   	pop    %edi
f010410c:	5d                   	pop    %ebp
f010410d:	c3                   	ret    

f010410e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010410e:	55                   	push   %ebp
f010410f:	89 e5                	mov    %esp,%ebp
f0104111:	57                   	push   %edi
f0104112:	56                   	push   %esi
f0104113:	53                   	push   %ebx
f0104114:	83 ec 2c             	sub    $0x2c,%esp
f0104117:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010411a:	e8 d1 27 00 00       	call   f01068f0 <cpunum>
f010411f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104122:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f0104128:	75 34                	jne    f010415e <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f010412a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010412f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104134:	77 20                	ja     f0104156 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104136:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010413a:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0104141:	f0 
f0104142:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0104149:	00 
f010414a:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f0104151:	e8 ea be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104156:	05 00 00 00 10       	add    $0x10000000,%eax
f010415b:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010415e:	8b 5f 48             	mov    0x48(%edi),%ebx
f0104161:	e8 8a 27 00 00       	call   f01068f0 <cpunum>
f0104166:	6b d0 74             	imul   $0x74,%eax,%edx
f0104169:	b8 00 00 00 00       	mov    $0x0,%eax
f010416e:	83 ba 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%edx)
f0104175:	74 11                	je     f0104188 <env_free+0x7a>
f0104177:	e8 74 27 00 00       	call   f01068f0 <cpunum>
f010417c:	6b c0 74             	imul   $0x74,%eax,%eax
f010417f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104185:	8b 40 48             	mov    0x48(%eax),%eax
f0104188:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010418c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104190:	c7 04 24 f9 84 10 f0 	movl   $0xf01084f9,(%esp)
f0104197:	e8 5a 04 00 00       	call   f01045f6 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010419c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
//cprintf("*****e->env_pgdir[pdeno]: up to now!\n");
		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01041a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041a6:	c1 e0 02             	shl    $0x2,%eax
f01041a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041ac:	8b 47 60             	mov    0x60(%edi),%eax
f01041af:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041b2:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01041b5:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01041bb:	0f 84 b8 00 00 00    	je     f0104279 <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01041c1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01041c7:	89 f0                	mov    %esi,%eax
f01041c9:	c1 e8 0c             	shr    $0xc,%eax
f01041cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01041cf:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01041d5:	72 20                	jb     f01041f7 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01041d7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01041db:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01041e2:	f0 
f01041e3:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
f01041ea:	00 
f01041eb:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f01041f2:	e8 49 be ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01041f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041fa:	c1 e2 16             	shl    $0x16,%edx
f01041fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104200:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0104205:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010420c:	01 
f010420d:	74 17                	je     f0104226 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010420f:	89 d8                	mov    %ebx,%eax
f0104211:	c1 e0 0c             	shl    $0xc,%eax
f0104214:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0104217:	89 44 24 04          	mov    %eax,0x4(%esp)
f010421b:	8b 47 60             	mov    0x60(%edi),%eax
f010421e:	89 04 24             	mov    %eax,(%esp)
f0104221:	e8 d0 d7 ff ff       	call   f01019f6 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104226:	83 c3 01             	add    $0x1,%ebx
f0104229:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010422f:	75 d4                	jne    f0104205 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}
//cprintf("*****e table: up to now!\n");
		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104231:	8b 47 60             	mov    0x60(%edi),%eax
f0104234:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104237:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010423e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104241:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0104247:	72 1c                	jb     f0104265 <env_free+0x157>
		panic("pa2page called with invalid pa");
f0104249:	c7 44 24 08 94 79 10 	movl   $0xf0107994,0x8(%esp)
f0104250:	f0 
f0104251:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104258:	00 
f0104259:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f0104260:	e8 db bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104265:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104268:	c1 e0 03             	shl    $0x3,%eax
f010426b:	03 05 90 be 22 f0    	add    0xf022be90,%eax
		page_decref(pa2page(pa));
f0104271:	89 04 24             	mov    %eax,(%esp)
f0104274:	e8 9f d5 ff ff       	call   f0101818 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104279:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010427d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104284:	0f 85 19 ff ff ff    	jne    f01041a3 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}
//cprintf("*****e->env_pgdir: up to now!\n");
	// free the page directory
	pa = PADDR(e->env_pgdir);
f010428a:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010428d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104292:	77 20                	ja     f01042b4 <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104294:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104298:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f010429f:	f0 
f01042a0:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f01042a7:	00 
f01042a8:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f01042af:	e8 8c bd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01042b4:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01042bb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01042c0:	c1 e8 0c             	shr    $0xc,%eax
f01042c3:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01042c9:	72 1c                	jb     f01042e7 <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f01042cb:	c7 44 24 08 94 79 10 	movl   $0xf0107994,0x8(%esp)
f01042d2:	f0 
f01042d3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01042da:	00 
f01042db:	c7 04 24 b1 81 10 f0 	movl   $0xf01081b1,(%esp)
f01042e2:	e8 59 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01042e7:	c1 e0 03             	shl    $0x3,%eax
f01042ea:	03 05 90 be 22 f0    	add    0xf022be90,%eax
//cprintf("*****Get into page_decref!\n");
	page_decref(pa2page(pa));
f01042f0:	89 04 24             	mov    %eax,(%esp)
f01042f3:	e8 20 d5 ff ff       	call   f0101818 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01042f8:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01042ff:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
f0104304:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0104307:	89 3d 4c b2 22 f0    	mov    %edi,0xf022b24c
}
f010430d:	83 c4 2c             	add    $0x2c,%esp
f0104310:	5b                   	pop    %ebx
f0104311:	5e                   	pop    %esi
f0104312:	5f                   	pop    %edi
f0104313:	5d                   	pop    %ebp
f0104314:	c3                   	ret    

f0104315 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104315:	55                   	push   %ebp
f0104316:	89 e5                	mov    %esp,%ebp
f0104318:	53                   	push   %ebx
f0104319:	83 ec 14             	sub    $0x14,%esp
f010431c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010431f:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104323:	75 19                	jne    f010433e <env_destroy+0x29>
f0104325:	e8 c6 25 00 00       	call   f01068f0 <cpunum>
f010432a:	6b c0 74             	imul   $0x74,%eax,%eax
f010432d:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0104333:	74 09                	je     f010433e <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0104335:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010433c:	eb 3b                	jmp    f0104379 <env_destroy+0x64>
	}
	env_free(e);
f010433e:	89 1c 24             	mov    %ebx,(%esp)
f0104341:	e8 c8 fd ff ff       	call   f010410e <env_free>

	if (curenv == e) {
f0104346:	e8 a5 25 00 00       	call   f01068f0 <cpunum>
f010434b:	6b c0 74             	imul   $0x74,%eax,%eax
f010434e:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0104354:	75 23                	jne    f0104379 <env_destroy+0x64>
		curenv = NULL;
f0104356:	e8 95 25 00 00       	call   f01068f0 <cpunum>
f010435b:	6b c0 74             	imul   $0x74,%eax,%eax
f010435e:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104365:	00 00 00 
cprintf("****destroy\n");
f0104368:	c7 04 24 0f 85 10 f0 	movl   $0xf010850f,(%esp)
f010436f:	e8 82 02 00 00       	call   f01045f6 <cprintf>
		sched_yield();
f0104374:	e8 f3 0b 00 00       	call   f0104f6c <sched_yield>
	}
}
f0104379:	83 c4 14             	add    $0x14,%esp
f010437c:	5b                   	pop    %ebx
f010437d:	5d                   	pop    %ebp
f010437e:	c3                   	ret    

f010437f <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010437f:	55                   	push   %ebp
f0104380:	89 e5                	mov    %esp,%ebp
f0104382:	53                   	push   %ebx
f0104383:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104386:	e8 65 25 00 00       	call   f01068f0 <cpunum>
f010438b:	6b c0 74             	imul   $0x74,%eax,%eax
f010438e:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0104394:	e8 57 25 00 00       	call   f01068f0 <cpunum>
f0104399:	89 43 5c             	mov    %eax,0x5c(%ebx)
//cprintf("**Start transfering\n");

	__asm __volatile("movl %0,%%esp\n"
f010439c:	8b 65 08             	mov    0x8(%ebp),%esp
f010439f:	61                   	popa   
f01043a0:	07                   	pop    %es
f01043a1:	1f                   	pop    %ds
f01043a2:	83 c4 08             	add    $0x8,%esp
f01043a5:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01043a6:	c7 44 24 08 1c 85 10 	movl   $0xf010851c,0x8(%esp)
f01043ad:	f0 
f01043ae:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
f01043b5:	00 
f01043b6:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f01043bd:	e8 7e bc ff ff       	call   f0100040 <_panic>

f01043c2 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01043c2:	55                   	push   %ebp
f01043c3:	89 e5                	mov    %esp,%ebp
f01043c5:	53                   	push   %ebx
f01043c6:	83 ec 14             	sub    $0x14,%esp
f01043c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f01043cc:	e8 1f 25 00 00       	call   f01068f0 <cpunum>
f01043d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d4:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f01043da:	0f 84 85 00 00 00    	je     f0104465 <env_run+0xa3>
		if (curenv && curenv->env_status == ENV_RUNNING)
f01043e0:	e8 0b 25 00 00       	call   f01068f0 <cpunum>
f01043e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e8:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01043ef:	74 29                	je     f010441a <env_run+0x58>
f01043f1:	e8 fa 24 00 00       	call   f01068f0 <cpunum>
f01043f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f9:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01043ff:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104403:	75 15                	jne    f010441a <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0104405:	e8 e6 24 00 00       	call   f01068f0 <cpunum>
f010440a:	6b c0 74             	imul   $0x74,%eax,%eax
f010440d:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104413:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f010441a:	e8 d1 24 00 00       	call   f01068f0 <cpunum>
f010441f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104422:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
		e->env_status = ENV_RUNNING;
f0104428:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f010442f:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f0104433:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104436:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010443b:	77 20                	ja     f010445d <env_run+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010443d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104441:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0104448:	f0 
f0104449:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
f0104450:	00 
f0104451:	c7 04 24 bd 84 10 f0 	movl   $0xf01084bd,(%esp)
f0104458:	e8 e3 bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010445d:	05 00 00 00 10       	add    $0x10000000,%eax
f0104462:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104465:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f010446c:	e8 f2 27 00 00       	call   f0106c63 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104471:	f3 90                	pause  
	}

	unlock_kernel();

	env_pop_tf(&(curenv->env_tf));
f0104473:	e8 78 24 00 00       	call   f01068f0 <cpunum>
f0104478:	6b c0 74             	imul   $0x74,%eax,%eax
f010447b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104481:	89 04 24             	mov    %eax,(%esp)
f0104484:	e8 f6 fe ff ff       	call   f010437f <env_pop_tf>
f0104489:	00 00                	add    %al,(%eax)
	...

f010448c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010448c:	55                   	push   %ebp
f010448d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010448f:	ba 70 00 00 00       	mov    $0x70,%edx
f0104494:	8b 45 08             	mov    0x8(%ebp),%eax
f0104497:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104498:	b2 71                	mov    $0x71,%dl
f010449a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010449b:	0f b6 c0             	movzbl %al,%eax
}
f010449e:	5d                   	pop    %ebp
f010449f:	c3                   	ret    

f01044a0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01044a0:	55                   	push   %ebp
f01044a1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01044a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01044a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01044ab:	ee                   	out    %al,(%dx)
f01044ac:	b2 71                	mov    $0x71,%dl
f01044ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044b1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01044b2:	5d                   	pop    %ebp
f01044b3:	c3                   	ret    

f01044b4 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01044b4:	55                   	push   %ebp
f01044b5:	89 e5                	mov    %esp,%ebp
f01044b7:	56                   	push   %esi
f01044b8:	53                   	push   %ebx
f01044b9:	83 ec 10             	sub    $0x10,%esp
f01044bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01044bf:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01044c1:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01044c7:	80 3d 50 b2 22 f0 00 	cmpb   $0x0,0xf022b250
f01044ce:	74 4e                	je     f010451e <irq_setmask_8259A+0x6a>
f01044d0:	ba 21 00 00 00       	mov    $0x21,%edx
f01044d5:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01044d6:	89 f0                	mov    %esi,%eax
f01044d8:	66 c1 e8 08          	shr    $0x8,%ax
f01044dc:	b2 a1                	mov    $0xa1,%dl
f01044de:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01044df:	c7 04 24 28 85 10 f0 	movl   $0xf0108528,(%esp)
f01044e6:	e8 0b 01 00 00       	call   f01045f6 <cprintf>
	for (i = 0; i < 16; i++)
f01044eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01044f0:	0f b7 f6             	movzwl %si,%esi
f01044f3:	f7 d6                	not    %esi
f01044f5:	0f a3 de             	bt     %ebx,%esi
f01044f8:	73 10                	jae    f010450a <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f01044fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044fe:	c7 04 24 1f 8a 10 f0 	movl   $0xf0108a1f,(%esp)
f0104505:	e8 ec 00 00 00       	call   f01045f6 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010450a:	83 c3 01             	add    $0x1,%ebx
f010450d:	83 fb 10             	cmp    $0x10,%ebx
f0104510:	75 e3                	jne    f01044f5 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104512:	c7 04 24 30 87 10 f0 	movl   $0xf0108730,(%esp)
f0104519:	e8 d8 00 00 00       	call   f01045f6 <cprintf>
}
f010451e:	83 c4 10             	add    $0x10,%esp
f0104521:	5b                   	pop    %ebx
f0104522:	5e                   	pop    %esi
f0104523:	5d                   	pop    %ebp
f0104524:	c3                   	ret    

f0104525 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104525:	55                   	push   %ebp
f0104526:	89 e5                	mov    %esp,%ebp
f0104528:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010452b:	c6 05 50 b2 22 f0 01 	movb   $0x1,0xf022b250
f0104532:	ba 21 00 00 00       	mov    $0x21,%edx
f0104537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010453c:	ee                   	out    %al,(%dx)
f010453d:	b2 a1                	mov    $0xa1,%dl
f010453f:	ee                   	out    %al,(%dx)
f0104540:	b2 20                	mov    $0x20,%dl
f0104542:	b8 11 00 00 00       	mov    $0x11,%eax
f0104547:	ee                   	out    %al,(%dx)
f0104548:	b2 21                	mov    $0x21,%dl
f010454a:	b8 20 00 00 00       	mov    $0x20,%eax
f010454f:	ee                   	out    %al,(%dx)
f0104550:	b8 04 00 00 00       	mov    $0x4,%eax
f0104555:	ee                   	out    %al,(%dx)
f0104556:	b8 03 00 00 00       	mov    $0x3,%eax
f010455b:	ee                   	out    %al,(%dx)
f010455c:	b2 a0                	mov    $0xa0,%dl
f010455e:	b8 11 00 00 00       	mov    $0x11,%eax
f0104563:	ee                   	out    %al,(%dx)
f0104564:	b2 a1                	mov    $0xa1,%dl
f0104566:	b8 28 00 00 00       	mov    $0x28,%eax
f010456b:	ee                   	out    %al,(%dx)
f010456c:	b8 02 00 00 00       	mov    $0x2,%eax
f0104571:	ee                   	out    %al,(%dx)
f0104572:	b8 01 00 00 00       	mov    $0x1,%eax
f0104577:	ee                   	out    %al,(%dx)
f0104578:	b2 20                	mov    $0x20,%dl
f010457a:	b8 68 00 00 00       	mov    $0x68,%eax
f010457f:	ee                   	out    %al,(%dx)
f0104580:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104585:	ee                   	out    %al,(%dx)
f0104586:	b2 a0                	mov    $0xa0,%dl
f0104588:	b8 68 00 00 00       	mov    $0x68,%eax
f010458d:	ee                   	out    %al,(%dx)
f010458e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104593:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104594:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010459b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010459f:	74 0b                	je     f01045ac <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f01045a1:	0f b7 c0             	movzwl %ax,%eax
f01045a4:	89 04 24             	mov    %eax,(%esp)
f01045a7:	e8 08 ff ff ff       	call   f01044b4 <irq_setmask_8259A>
}
f01045ac:	c9                   	leave  
f01045ad:	c3                   	ret    
	...

f01045b0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01045b0:	55                   	push   %ebp
f01045b1:	89 e5                	mov    %esp,%ebp
f01045b3:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01045b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01045b9:	89 04 24             	mov    %eax,(%esp)
f01045bc:	e8 d8 c1 ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f01045c1:	c9                   	leave  
f01045c2:	c3                   	ret    

f01045c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01045c3:	55                   	push   %ebp
f01045c4:	89 e5                	mov    %esp,%ebp
f01045c6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01045c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01045d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01045da:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045de:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e5:	c7 04 24 b0 45 10 f0 	movl   $0xf01045b0,(%esp)
f01045ec:	e8 39 14 00 00       	call   f0105a2a <vprintfmt>
	return cnt;
}
f01045f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045f4:	c9                   	leave  
f01045f5:	c3                   	ret    

f01045f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01045f6:	55                   	push   %ebp
f01045f7:	89 e5                	mov    %esp,%ebp
f01045f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01045fc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01045ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104603:	8b 45 08             	mov    0x8(%ebp),%eax
f0104606:	89 04 24             	mov    %eax,(%esp)
f0104609:	e8 b5 ff ff ff       	call   f01045c3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010460e:	c9                   	leave  
f010460f:	c3                   	ret    

f0104610 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104610:	55                   	push   %ebp
f0104611:	89 e5                	mov    %esp,%ebp
f0104613:	57                   	push   %edi
f0104614:	56                   	push   %esi
f0104615:	53                   	push   %ebx
f0104616:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP);
f0104619:	e8 d2 22 00 00       	call   f01068f0 <cpunum>
f010461e:	89 c3                	mov    %eax,%ebx
f0104620:	e8 cb 22 00 00       	call   f01068f0 <cpunum>
f0104625:	6b db 74             	imul   $0x74,%ebx,%ebx
f0104628:	6b c0 74             	imul   $0x74,%eax,%eax
f010462b:	0f b6 80 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%eax
f0104632:	f7 d8                	neg    %eax
f0104634:	c1 e0 10             	shl    $0x10,%eax
f0104637:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010463c:	89 83 30 c0 22 f0    	mov    %eax,-0xfdd3fd0(%ebx)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104642:	e8 a9 22 00 00       	call   f01068f0 <cpunum>
f0104647:	6b c0 74             	imul   $0x74,%eax,%eax
f010464a:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f0104651:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0104653:	e8 98 22 00 00       	call   f01068f0 <cpunum>
f0104658:	6b c0 74             	imul   $0x74,%eax,%eax
f010465b:	0f b6 98 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%ebx
f0104662:	83 c3 05             	add    $0x5,%ebx
f0104665:	e8 86 22 00 00       	call   f01068f0 <cpunum>
f010466a:	89 c6                	mov    %eax,%esi
f010466c:	e8 7f 22 00 00       	call   f01068f0 <cpunum>
f0104671:	89 c7                	mov    %eax,%edi
f0104673:	e8 78 22 00 00       	call   f01068f0 <cpunum>
f0104678:	66 c7 04 dd 40 23 12 	movw   $0x68,-0xfeddcc0(,%ebx,8)
f010467f:	f0 68 00 
f0104682:	6b f6 74             	imul   $0x74,%esi,%esi
f0104685:	81 c6 2c c0 22 f0    	add    $0xf022c02c,%esi
f010468b:	66 89 34 dd 42 23 12 	mov    %si,-0xfeddcbe(,%ebx,8)
f0104692:	f0 
f0104693:	6b d7 74             	imul   $0x74,%edi,%edx
f0104696:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f010469c:	c1 ea 10             	shr    $0x10,%edx
f010469f:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f01046a6:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f01046ad:	99 
f01046ae:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f01046b5:	40 
f01046b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b9:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f01046be:	c1 e8 18             	shr    $0x18,%eax
f01046c1:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
                    sizeof(struct Taskstate), 0);
    gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id].sd_s = 0;
f01046c8:	e8 23 22 00 00       	call   f01068f0 <cpunum>
f01046cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d0:	0f b6 80 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%eax
f01046d7:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f01046de:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8*(thiscpu->cpu_id));
f01046df:	e8 0c 22 00 00       	call   f01068f0 <cpunum>
f01046e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e7:	0f b6 80 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%eax
f01046ee:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01046f5:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01046f8:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f01046fd:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104700:	83 c4 0c             	add    $0xc,%esp
f0104703:	5b                   	pop    %ebx
f0104704:	5e                   	pop    %esi
f0104705:	5f                   	pop    %edi
f0104706:	5d                   	pop    %ebp
f0104707:	c3                   	ret    

f0104708 <trap_init>:
}


void
trap_init(void)
{
f0104708:	55                   	push   %ebp
f0104709:	89 e5                	mov    %esp,%ebp
f010470b:	53                   	push   %ebx
f010470c:	83 ec 04             	sub    $0x4,%esp
f010470f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0104714:	b8 00 00 00 00       	mov    $0x0,%eax
f0104719:	eb 06                	jmp    f0104721 <trap_init+0x19>
f010471b:	83 c0 01             	add    $0x1,%eax
f010471e:	83 c1 01             	add    $0x1,%ecx

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
		if (i==T_BRKPT)
f0104721:	83 f8 03             	cmp    $0x3,%eax
f0104724:	75 30                	jne    f0104756 <trap_init+0x4e>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f0104726:	8b 15 c0 23 12 f0    	mov    0xf01223c0,%edx
f010472c:	66 89 15 78 b2 22 f0 	mov    %dx,0xf022b278
f0104733:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f010473a:	08 00 
f010473c:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f0104743:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f010474a:	c1 ea 10             	shr    $0x10,%edx
f010474d:	66 89 15 7e b2 22 f0 	mov    %dx,0xf022b27e
f0104754:	eb c5                	jmp    f010471b <trap_init+0x13>
		else if (i!=2 && i!=15) {
f0104756:	83 f8 02             	cmp    $0x2,%eax
f0104759:	74 39                	je     f0104794 <trap_init+0x8c>
f010475b:	83 f8 0f             	cmp    $0xf,%eax
f010475e:	74 34                	je     f0104794 <trap_init+0x8c>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f0104760:	8b 1c 85 b4 23 12 f0 	mov    -0xfeddc4c(,%eax,4),%ebx
f0104767:	66 89 1c c5 60 b2 22 	mov    %bx,-0xfdd4da0(,%eax,8)
f010476e:	f0 
f010476f:	66 c7 04 c5 62 b2 22 	movw   $0x8,-0xfdd4d9e(,%eax,8)
f0104776:	f0 08 00 
f0104779:	c6 04 c5 64 b2 22 f0 	movb   $0x0,-0xfdd4d9c(,%eax,8)
f0104780:	00 
f0104781:	c6 04 c5 65 b2 22 f0 	movb   $0x8e,-0xfdd4d9b(,%eax,8)
f0104788:	8e 
f0104789:	c1 eb 10             	shr    $0x10,%ebx
f010478c:	66 89 1c c5 66 b2 22 	mov    %bx,-0xfdd4d9a(,%eax,8)
f0104793:	f0 
	// SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
f0104794:	83 f9 10             	cmp    $0x10,%ecx
f0104797:	7e 82                	jle    f010471b <trap_init+0x13>
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f0104799:	a1 74 24 12 f0       	mov    0xf0122474,%eax
f010479e:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f01047a4:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f01047ab:	08 00 
f01047ad:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f01047b4:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f01047bb:	c1 e8 10             	shr    $0x10,%eax
f01047be:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6

	// Per-CPU setup 
	trap_init_percpu();
f01047c4:	e8 47 fe ff ff       	call   f0104610 <trap_init_percpu>
}
f01047c9:	83 c4 04             	add    $0x4,%esp
f01047cc:	5b                   	pop    %ebx
f01047cd:	5d                   	pop    %ebp
f01047ce:	c3                   	ret    

f01047cf <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01047cf:	55                   	push   %ebp
f01047d0:	89 e5                	mov    %esp,%ebp
f01047d2:	53                   	push   %ebx
f01047d3:	83 ec 14             	sub    $0x14,%esp
f01047d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01047d9:	8b 03                	mov    (%ebx),%eax
f01047db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047df:	c7 04 24 3c 85 10 f0 	movl   $0xf010853c,(%esp)
f01047e6:	e8 0b fe ff ff       	call   f01045f6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01047eb:	8b 43 04             	mov    0x4(%ebx),%eax
f01047ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047f2:	c7 04 24 4b 85 10 f0 	movl   $0xf010854b,(%esp)
f01047f9:	e8 f8 fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01047fe:	8b 43 08             	mov    0x8(%ebx),%eax
f0104801:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104805:	c7 04 24 5a 85 10 f0 	movl   $0xf010855a,(%esp)
f010480c:	e8 e5 fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104811:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104814:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104818:	c7 04 24 69 85 10 f0 	movl   $0xf0108569,(%esp)
f010481f:	e8 d2 fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104824:	8b 43 10             	mov    0x10(%ebx),%eax
f0104827:	89 44 24 04          	mov    %eax,0x4(%esp)
f010482b:	c7 04 24 78 85 10 f0 	movl   $0xf0108578,(%esp)
f0104832:	e8 bf fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104837:	8b 43 14             	mov    0x14(%ebx),%eax
f010483a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010483e:	c7 04 24 87 85 10 f0 	movl   $0xf0108587,(%esp)
f0104845:	e8 ac fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010484a:	8b 43 18             	mov    0x18(%ebx),%eax
f010484d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104851:	c7 04 24 96 85 10 f0 	movl   $0xf0108596,(%esp)
f0104858:	e8 99 fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010485d:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104860:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104864:	c7 04 24 a5 85 10 f0 	movl   $0xf01085a5,(%esp)
f010486b:	e8 86 fd ff ff       	call   f01045f6 <cprintf>
}
f0104870:	83 c4 14             	add    $0x14,%esp
f0104873:	5b                   	pop    %ebx
f0104874:	5d                   	pop    %ebp
f0104875:	c3                   	ret    

f0104876 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104876:	55                   	push   %ebp
f0104877:	89 e5                	mov    %esp,%ebp
f0104879:	56                   	push   %esi
f010487a:	53                   	push   %ebx
f010487b:	83 ec 10             	sub    $0x10,%esp
f010487e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104881:	e8 6a 20 00 00       	call   f01068f0 <cpunum>
f0104886:	89 44 24 08          	mov    %eax,0x8(%esp)
f010488a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010488e:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0104895:	e8 5c fd ff ff       	call   f01045f6 <cprintf>
	print_regs(&tf->tf_regs);
f010489a:	89 1c 24             	mov    %ebx,(%esp)
f010489d:	e8 2d ff ff ff       	call   f01047cf <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01048a2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01048a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048aa:	c7 04 24 27 86 10 f0 	movl   $0xf0108627,(%esp)
f01048b1:	e8 40 fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01048b6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01048ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048be:	c7 04 24 3a 86 10 f0 	movl   $0xf010863a,(%esp)
f01048c5:	e8 2c fd ff ff       	call   f01045f6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048ca:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01048cd:	83 f8 13             	cmp    $0x13,%eax
f01048d0:	77 09                	ja     f01048db <print_trapframe+0x65>
		return excnames[trapno];
f01048d2:	8b 14 85 e0 88 10 f0 	mov    -0xfef7720(,%eax,4),%edx
f01048d9:	eb 1d                	jmp    f01048f8 <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f01048db:	ba b4 85 10 f0       	mov    $0xf01085b4,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f01048e0:	83 f8 30             	cmp    $0x30,%eax
f01048e3:	74 13                	je     f01048f8 <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01048e5:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01048e8:	83 fa 0f             	cmp    $0xf,%edx
f01048eb:	ba c0 85 10 f0       	mov    $0xf01085c0,%edx
f01048f0:	b9 d3 85 10 f0       	mov    $0xf01085d3,%ecx
f01048f5:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048f8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104900:	c7 04 24 4d 86 10 f0 	movl   $0xf010864d,(%esp)
f0104907:	e8 ea fc ff ff       	call   f01045f6 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010490c:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0104912:	75 19                	jne    f010492d <print_trapframe+0xb7>
f0104914:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104918:	75 13                	jne    f010492d <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010491a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010491d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104921:	c7 04 24 5f 86 10 f0 	movl   $0xf010865f,(%esp)
f0104928:	e8 c9 fc ff ff       	call   f01045f6 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010492d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104930:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104934:	c7 04 24 6e 86 10 f0 	movl   $0xf010866e,(%esp)
f010493b:	e8 b6 fc ff ff       	call   f01045f6 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104940:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104944:	75 51                	jne    f0104997 <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104946:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104949:	89 c2                	mov    %eax,%edx
f010494b:	83 e2 01             	and    $0x1,%edx
f010494e:	ba e2 85 10 f0       	mov    $0xf01085e2,%edx
f0104953:	b9 ed 85 10 f0       	mov    $0xf01085ed,%ecx
f0104958:	0f 45 ca             	cmovne %edx,%ecx
f010495b:	89 c2                	mov    %eax,%edx
f010495d:	83 e2 02             	and    $0x2,%edx
f0104960:	ba f9 85 10 f0       	mov    $0xf01085f9,%edx
f0104965:	be ff 85 10 f0       	mov    $0xf01085ff,%esi
f010496a:	0f 44 d6             	cmove  %esi,%edx
f010496d:	83 e0 04             	and    $0x4,%eax
f0104970:	b8 04 86 10 f0       	mov    $0xf0108604,%eax
f0104975:	be 6f 87 10 f0       	mov    $0xf010876f,%esi
f010497a:	0f 44 c6             	cmove  %esi,%eax
f010497d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104981:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104985:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104989:	c7 04 24 7c 86 10 f0 	movl   $0xf010867c,(%esp)
f0104990:	e8 61 fc ff ff       	call   f01045f6 <cprintf>
f0104995:	eb 0c                	jmp    f01049a3 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104997:	c7 04 24 30 87 10 f0 	movl   $0xf0108730,(%esp)
f010499e:	e8 53 fc ff ff       	call   f01045f6 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01049a3:	8b 43 30             	mov    0x30(%ebx),%eax
f01049a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049aa:	c7 04 24 8b 86 10 f0 	movl   $0xf010868b,(%esp)
f01049b1:	e8 40 fc ff ff       	call   f01045f6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01049b6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01049ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049be:	c7 04 24 9a 86 10 f0 	movl   $0xf010869a,(%esp)
f01049c5:	e8 2c fc ff ff       	call   f01045f6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01049ca:	8b 43 38             	mov    0x38(%ebx),%eax
f01049cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049d1:	c7 04 24 ad 86 10 f0 	movl   $0xf01086ad,(%esp)
f01049d8:	e8 19 fc ff ff       	call   f01045f6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01049dd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01049e1:	74 27                	je     f0104a0a <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01049e3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01049e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049ea:	c7 04 24 bc 86 10 f0 	movl   $0xf01086bc,(%esp)
f01049f1:	e8 00 fc ff ff       	call   f01045f6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01049f6:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01049fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049fe:	c7 04 24 cb 86 10 f0 	movl   $0xf01086cb,(%esp)
f0104a05:	e8 ec fb ff ff       	call   f01045f6 <cprintf>
	}
}
f0104a0a:	83 c4 10             	add    $0x10,%esp
f0104a0d:	5b                   	pop    %ebx
f0104a0e:	5e                   	pop    %esi
f0104a0f:	5d                   	pop    %ebp
f0104a10:	c3                   	ret    

f0104a11 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104a11:	55                   	push   %ebp
f0104a12:	89 e5                	mov    %esp,%ebp
f0104a14:	83 ec 38             	sub    $0x38,%esp
f0104a17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104a1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104a1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a23:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0){
f0104a26:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a2a:	75 28                	jne    f0104a54 <page_fault_handler+0x43>
		print_trapframe(tf);
f0104a2c:	89 1c 24             	mov    %ebx,(%esp)
f0104a2f:	e8 42 fe ff ff       	call   f0104876 <print_trapframe>
		panic("kernel page fault va: %08x", fault_va);
f0104a34:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104a38:	c7 44 24 08 de 86 10 	movl   $0xf01086de,0x8(%esp)
f0104a3f:	f0 
f0104a40:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f0104a47:	00 
f0104a48:	c7 04 24 f9 86 10 f0 	movl   $0xf01086f9,(%esp)
f0104a4f:	e8 ec b5 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104a54:	e8 97 1e 00 00       	call   f01068f0 <cpunum>
f0104a59:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a5c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104a62:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104a66:	0f 84 06 01 00 00    	je     f0104b72 <page_fault_handler+0x161>
        struct UTrapframe *utf;
        uintptr_t utf_addr;
        // Locate the exception stack
        if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0104a6c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a6f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
            utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104a75:	83 e8 38             	sub    $0x38,%eax
f0104a78:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104a7e:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104a83:	0f 46 d0             	cmovbe %eax,%edx
f0104a86:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        else 
            utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
        user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
f0104a89:	e8 62 1e 00 00       	call   f01068f0 <cpunum>
f0104a8e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104a95:	00 
f0104a96:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104a9d:	00 
f0104a9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104aa5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104aae:	89 04 24             	mov    %eax,(%esp)
f0104ab1:	e8 56 f1 ff ff       	call   f0103c0c <user_mem_assert>
        utf = (struct UTrapframe *) utf_addr;
f0104ab6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ab9:	89 45 e0             	mov    %eax,-0x20(%ebp)

        // Form the UTrapframe
        utf->utf_fault_va = fault_va;
f0104abc:	89 30                	mov    %esi,(%eax)
        utf->utf_err = tf->tf_err;
f0104abe:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104ac1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ac4:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0104ac7:	89 d7                	mov    %edx,%edi
f0104ac9:	83 c7 08             	add    $0x8,%edi
f0104acc:	89 de                	mov    %ebx,%esi
f0104ace:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ad3:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104ad9:	74 03                	je     f0104ade <page_fault_handler+0xcd>
f0104adb:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104adc:	b0 1f                	mov    $0x1f,%al
f0104ade:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104ae4:	74 05                	je     f0104aeb <page_fault_handler+0xda>
f0104ae6:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104ae8:	83 e8 02             	sub    $0x2,%eax
f0104aeb:	89 c1                	mov    %eax,%ecx
f0104aed:	c1 e9 02             	shr    $0x2,%ecx
f0104af0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104af2:	ba 00 00 00 00       	mov    $0x0,%edx
f0104af7:	a8 02                	test   $0x2,%al
f0104af9:	74 0b                	je     f0104b06 <page_fault_handler+0xf5>
f0104afb:	0f b7 16             	movzwl (%esi),%edx
f0104afe:	66 89 17             	mov    %dx,(%edi)
f0104b01:	ba 02 00 00 00       	mov    $0x2,%edx
f0104b06:	a8 01                	test   $0x1,%al
f0104b08:	74 07                	je     f0104b11 <page_fault_handler+0x100>
f0104b0a:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104b0e:	88 04 17             	mov    %al,(%edi,%edx,1)
        utf->utf_eip = tf->tf_eip;
f0104b11:	8b 43 30             	mov    0x30(%ebx),%eax
f0104b14:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b17:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104b1a:	8b 43 38             	mov    0x38(%ebx),%eax
f0104b1d:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104b20:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b23:	89 42 30             	mov    %eax,0x30(%edx)

        //Modify the env's trapframe to run the handler set before
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104b26:	e8 c5 1d 00 00       	call   f01068f0 <cpunum>
f0104b2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2e:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0104b34:	e8 b7 1d 00 00       	call   f01068f0 <cpunum>
f0104b39:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b42:	8b 40 64             	mov    0x64(%eax),%eax
f0104b45:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = utf_addr;
f0104b48:	e8 a3 1d 00 00       	call   f01068f0 <cpunum>
f0104b4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b50:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b59:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104b5c:	e8 8f 1d 00 00       	call   f01068f0 <cpunum>
f0104b61:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b64:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b6a:	89 04 24             	mov    %eax,(%esp)
f0104b6d:	e8 50 f8 ff ff       	call   f01043c2 <env_run>
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b72:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104b75:	e8 76 1d 00 00       	call   f01068f0 <cpunum>
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        curenv->env_tf.tf_esp = utf_addr;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b7a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104b7e:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104b82:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b85:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        curenv->env_tf.tf_esp = utf_addr;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b8b:	8b 40 48             	mov    0x48(%eax),%eax
f0104b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b92:	c7 04 24 bc 88 10 f0 	movl   $0xf01088bc,(%esp)
f0104b99:	e8 58 fa ff ff       	call   f01045f6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104b9e:	89 1c 24             	mov    %ebx,(%esp)
f0104ba1:	e8 d0 fc ff ff       	call   f0104876 <print_trapframe>
	env_destroy(curenv);
f0104ba6:	e8 45 1d 00 00       	call   f01068f0 <cpunum>
f0104bab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bae:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104bb4:	89 04 24             	mov    %eax,(%esp)
f0104bb7:	e8 59 f7 ff ff       	call   f0104315 <env_destroy>
}
f0104bbc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104bbf:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104bc2:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104bc5:	89 ec                	mov    %ebp,%esp
f0104bc7:	5d                   	pop    %ebp
f0104bc8:	c3                   	ret    

f0104bc9 <breakpoint_handler>:

void
breakpoint_handler(struct Trapframe *tf) {
f0104bc9:	55                   	push   %ebp
f0104bca:	89 e5                	mov    %esp,%ebp
f0104bcc:	53                   	push   %ebx
f0104bcd:	83 ec 14             	sub    $0x14,%esp
f0104bd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	print_trapframe(tf);
f0104bd3:	89 1c 24             	mov    %ebx,(%esp)
f0104bd6:	e8 9b fc ff ff       	call   f0104876 <print_trapframe>
	monitor(tf);
f0104bdb:	89 1c 24             	mov    %ebx,(%esp)
f0104bde:	e8 49 c4 ff ff       	call   f010102c <monitor>
	return;
}
f0104be3:	83 c4 14             	add    $0x14,%esp
f0104be6:	5b                   	pop    %ebx
f0104be7:	5d                   	pop    %ebp
f0104be8:	c3                   	ret    

f0104be9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104be9:	55                   	push   %ebp
f0104bea:	89 e5                	mov    %esp,%ebp
f0104bec:	57                   	push   %edi
f0104bed:	56                   	push   %esi
f0104bee:	83 ec 20             	sub    $0x20,%esp
f0104bf1:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104bf4:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104bf5:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0104bfc:	74 01                	je     f0104bff <trap+0x16>
		asm volatile("hlt");
f0104bfe:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104bff:	e8 ec 1c 00 00       	call   f01068f0 <cpunum>
f0104c04:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c07:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c0d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c12:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104c16:	83 f8 02             	cmp    $0x2,%eax
f0104c19:	75 0c                	jne    f0104c27 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104c1b:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f0104c22:	e8 79 1f 00 00       	call   f0106ba0 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104c27:	9c                   	pushf  
f0104c28:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104c29:	f6 c4 02             	test   $0x2,%ah
f0104c2c:	74 24                	je     f0104c52 <trap+0x69>
f0104c2e:	c7 44 24 0c 05 87 10 	movl   $0xf0108705,0xc(%esp)
f0104c35:	f0 
f0104c36:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0104c3d:	f0 
f0104c3e:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
f0104c45:	00 
f0104c46:	c7 04 24 f9 86 10 f0 	movl   $0xf01086f9,(%esp)
f0104c4d:	e8 ee b3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104c52:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104c56:	83 e0 03             	and    $0x3,%eax
f0104c59:	83 f8 03             	cmp    $0x3,%eax
f0104c5c:	0f 85 a7 00 00 00    	jne    f0104d09 <trap+0x120>
f0104c62:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f0104c69:	e8 32 1f 00 00       	call   f0106ba0 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104c6e:	e8 7d 1c 00 00       	call   f01068f0 <cpunum>
f0104c73:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c76:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104c7d:	75 24                	jne    f0104ca3 <trap+0xba>
f0104c7f:	c7 44 24 0c 1e 87 10 	movl   $0xf010871e,0xc(%esp)
f0104c86:	f0 
f0104c87:	c7 44 24 08 cb 81 10 	movl   $0xf01081cb,0x8(%esp)
f0104c8e:	f0 
f0104c8f:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f0104c96:	00 
f0104c97:	c7 04 24 f9 86 10 f0 	movl   $0xf01086f9,(%esp)
f0104c9e:	e8 9d b3 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104ca3:	e8 48 1c 00 00       	call   f01068f0 <cpunum>
f0104ca8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cab:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104cb1:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104cb5:	75 2d                	jne    f0104ce4 <trap+0xfb>
			env_free(curenv);
f0104cb7:	e8 34 1c 00 00       	call   f01068f0 <cpunum>
f0104cbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cbf:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104cc5:	89 04 24             	mov    %eax,(%esp)
f0104cc8:	e8 41 f4 ff ff       	call   f010410e <env_free>
			curenv = NULL;
f0104ccd:	e8 1e 1c 00 00       	call   f01068f0 <cpunum>
f0104cd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cd5:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104cdc:	00 00 00 
			sched_yield();
f0104cdf:	e8 88 02 00 00       	call   f0104f6c <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104ce4:	e8 07 1c 00 00       	call   f01068f0 <cpunum>
f0104ce9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cec:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104cf2:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104cf7:	89 c7                	mov    %eax,%edi
f0104cf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104cfb:	e8 f0 1b 00 00       	call   f01068f0 <cpunum>
f0104d00:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d03:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104d09:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT) {
f0104d0f:	8b 46 28             	mov    0x28(%esi),%eax
f0104d12:	83 f8 0e             	cmp    $0xe,%eax
f0104d15:	75 19                	jne    f0104d30 <trap+0x147>
		cprintf("PAGE FAULT!\n");
f0104d17:	c7 04 24 25 87 10 f0 	movl   $0xf0108725,(%esp)
f0104d1e:	e8 d3 f8 ff ff       	call   f01045f6 <cprintf>
		page_fault_handler(tf);
f0104d23:	89 34 24             	mov    %esi,(%esp)
f0104d26:	e8 e6 fc ff ff       	call   f0104a11 <page_fault_handler>
f0104d2b:	e9 b1 00 00 00       	jmp    f0104de1 <trap+0x1f8>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104d30:	83 f8 27             	cmp    $0x27,%eax
f0104d33:	75 19                	jne    f0104d4e <trap+0x165>
		cprintf("Spurious interrupt on irq 7\n");
f0104d35:	c7 04 24 32 87 10 f0 	movl   $0xf0108732,(%esp)
f0104d3c:	e8 b5 f8 ff ff       	call   f01045f6 <cprintf>
		print_trapframe(tf);
f0104d41:	89 34 24             	mov    %esi,(%esp)
f0104d44:	e8 2d fb ff ff       	call   f0104876 <print_trapframe>
f0104d49:	e9 93 00 00 00       	jmp    f0104de1 <trap+0x1f8>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if(tf->tf_trapno == T_BRKPT) {
f0104d4e:	83 f8 03             	cmp    $0x3,%eax
f0104d51:	75 16                	jne    f0104d69 <trap+0x180>
		cprintf("BREAK POINT!\n");
f0104d53:	c7 04 24 4f 87 10 f0 	movl   $0xf010874f,(%esp)
f0104d5a:	e8 97 f8 ff ff       	call   f01045f6 <cprintf>
		breakpoint_handler(tf);
f0104d5f:	89 34 24             	mov    %esi,(%esp)
f0104d62:	e8 62 fe ff ff       	call   f0104bc9 <breakpoint_handler>
f0104d67:	eb 78                	jmp    f0104de1 <trap+0x1f8>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
f0104d69:	83 f8 30             	cmp    $0x30,%eax
f0104d6c:	75 32                	jne    f0104da0 <trap+0x1b7>
		//cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104d6e:	8b 46 04             	mov    0x4(%esi),%eax
f0104d71:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104d75:	8b 06                	mov    (%esi),%eax
f0104d77:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104d7b:	8b 46 10             	mov    0x10(%esi),%eax
f0104d7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d82:	8b 46 18             	mov    0x18(%esi),%eax
f0104d85:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d89:	8b 46 14             	mov    0x14(%esi),%eax
f0104d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d90:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104d93:	89 04 24             	mov    %eax,(%esp)
f0104d96:	e8 c5 02 00 00       	call   f0105060 <syscall>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
		//cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
f0104d9b:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104d9e:	eb 41                	jmp    f0104de1 <trap+0x1f8>
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104da0:	89 34 24             	mov    %esi,(%esp)
f0104da3:	e8 ce fa ff ff       	call   f0104876 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104da8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104dad:	75 1c                	jne    f0104dcb <trap+0x1e2>
		panic("unhandled trap in kernel");
f0104daf:	c7 44 24 08 5d 87 10 	movl   $0xf010875d,0x8(%esp)
f0104db6:	f0 
f0104db7:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
f0104dbe:	00 
f0104dbf:	c7 04 24 f9 86 10 f0 	movl   $0xf01086f9,(%esp)
f0104dc6:	e8 75 b2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104dcb:	e8 20 1b 00 00       	call   f01068f0 <cpunum>
f0104dd0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dd3:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104dd9:	89 04 24             	mov    %eax,(%esp)
f0104ddc:	e8 34 f5 ff ff       	call   f0104315 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104de1:	e8 0a 1b 00 00       	call   f01068f0 <cpunum>
f0104de6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104de9:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104df0:	74 2a                	je     f0104e1c <trap+0x233>
f0104df2:	e8 f9 1a 00 00       	call   f01068f0 <cpunum>
f0104df7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dfa:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104e00:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e04:	75 16                	jne    f0104e1c <trap+0x233>
		env_run(curenv);
f0104e06:	e8 e5 1a 00 00       	call   f01068f0 <cpunum>
f0104e0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e0e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104e14:	89 04 24             	mov    %eax,(%esp)
f0104e17:	e8 a6 f5 ff ff       	call   f01043c2 <env_run>
	else
		sched_yield();
f0104e1c:	e8 4b 01 00 00       	call   f0104f6c <sched_yield>
f0104e21:	00 00                	add    %al,(%eax)
	...

f0104e24 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec_entry(th0, 0)
f0104e24:	6a 00                	push   $0x0
f0104e26:	6a 00                	push   $0x0
f0104e28:	eb 4e                	jmp    f0104e78 <_alltraps>

f0104e2a <th1>:
	noec_entry(th1, 1)
f0104e2a:	6a 00                	push   $0x0
f0104e2c:	6a 01                	push   $0x1
f0104e2e:	eb 48                	jmp    f0104e78 <_alltraps>

f0104e30 <th3>:
	reserved_entry()
	noec_entry(th3, 3)
f0104e30:	6a 00                	push   $0x0
f0104e32:	6a 03                	push   $0x3
f0104e34:	eb 42                	jmp    f0104e78 <_alltraps>

f0104e36 <th4>:
	noec_entry(th4, 4)
f0104e36:	6a 00                	push   $0x0
f0104e38:	6a 04                	push   $0x4
f0104e3a:	eb 3c                	jmp    f0104e78 <_alltraps>

f0104e3c <th5>:
	noec_entry(th5, 5)
f0104e3c:	6a 00                	push   $0x0
f0104e3e:	6a 05                	push   $0x5
f0104e40:	eb 36                	jmp    f0104e78 <_alltraps>

f0104e42 <th6>:
	noec_entry(th6, 6)
f0104e42:	6a 00                	push   $0x0
f0104e44:	6a 06                	push   $0x6
f0104e46:	eb 30                	jmp    f0104e78 <_alltraps>

f0104e48 <th7>:
	noec_entry(th7, 7)
f0104e48:	6a 00                	push   $0x0
f0104e4a:	6a 07                	push   $0x7
f0104e4c:	eb 2a                	jmp    f0104e78 <_alltraps>

f0104e4e <th8>:
	ec_entry(th8, 8)
f0104e4e:	6a 08                	push   $0x8
f0104e50:	eb 26                	jmp    f0104e78 <_alltraps>

f0104e52 <th9>:
	noec_entry(th9, 9)
f0104e52:	6a 00                	push   $0x0
f0104e54:	6a 09                	push   $0x9
f0104e56:	eb 20                	jmp    f0104e78 <_alltraps>

f0104e58 <th10>:
	ec_entry(th10, 10)
f0104e58:	6a 0a                	push   $0xa
f0104e5a:	eb 1c                	jmp    f0104e78 <_alltraps>

f0104e5c <th11>:
	ec_entry(th11, 11)
f0104e5c:	6a 0b                	push   $0xb
f0104e5e:	eb 18                	jmp    f0104e78 <_alltraps>

f0104e60 <th12>:
	ec_entry(th12, 12)
f0104e60:	6a 0c                	push   $0xc
f0104e62:	eb 14                	jmp    f0104e78 <_alltraps>

f0104e64 <th13>:
	ec_entry(th13, 13)
f0104e64:	6a 0d                	push   $0xd
f0104e66:	eb 10                	jmp    f0104e78 <_alltraps>

f0104e68 <th14>:
	ec_entry(th14, 14)
f0104e68:	6a 0e                	push   $0xe
f0104e6a:	eb 0c                	jmp    f0104e78 <_alltraps>

f0104e6c <th16>:
	reserved_entry()
	noec_entry(th16, 16)
f0104e6c:	6a 00                	push   $0x0
f0104e6e:	6a 10                	push   $0x10
f0104e70:	eb 06                	jmp    f0104e78 <_alltraps>

f0104e72 <th48>:
.data
	.space 124
.text
	noec_entry(th48, 48)
f0104e72:	6a 00                	push   $0x0
f0104e74:	6a 30                	push   $0x30
f0104e76:	eb 00                	jmp    f0104e78 <_alltraps>

f0104e78 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104e78:	1e                   	push   %ds
	pushl %es
f0104e79:	06                   	push   %es
	pushal
f0104e7a:	60                   	pusha  
	pushl $GD_KD
f0104e7b:	6a 10                	push   $0x10
	popl %ds
f0104e7d:	1f                   	pop    %ds
	pushl $GD_KD
f0104e7e:	6a 10                	push   $0x10
	popl %es
f0104e80:	07                   	pop    %es
	pushl %esp
f0104e81:	54                   	push   %esp
	call trap
f0104e82:	e8 62 fd ff ff       	call   f0104be9 <trap>
	...

f0104e88 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104e88:	55                   	push   %ebp
f0104e89:	89 e5                	mov    %esp,%ebp
f0104e8b:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104e8e:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
f0104e94:	8b 42 54             	mov    0x54(%edx),%eax
f0104e97:	83 e8 02             	sub    $0x2,%eax
f0104e9a:	83 f8 01             	cmp    $0x1,%eax
f0104e9d:	76 45                	jbe    f0104ee4 <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104e9f:	81 c2 d0 00 00 00    	add    $0xd0,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ea5:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104eaa:	8b 0a                	mov    (%edx),%ecx
f0104eac:	83 e9 02             	sub    $0x2,%ecx
f0104eaf:	83 f9 01             	cmp    $0x1,%ecx
f0104eb2:	76 0f                	jbe    f0104ec3 <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104eb4:	83 c0 01             	add    $0x1,%eax
f0104eb7:	83 c2 7c             	add    $0x7c,%edx
f0104eba:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104ebf:	75 e9                	jne    f0104eaa <sched_halt+0x22>
f0104ec1:	eb 07                	jmp    f0104eca <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104ec3:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104ec8:	75 1a                	jne    f0104ee4 <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f0104eca:	c7 04 24 30 89 10 f0 	movl   $0xf0108930,(%esp)
f0104ed1:	e8 20 f7 ff ff       	call   f01045f6 <cprintf>
		while (1)
			monitor(NULL);
f0104ed6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104edd:	e8 4a c1 ff ff       	call   f010102c <monitor>
f0104ee2:	eb f2                	jmp    f0104ed6 <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104ee4:	e8 07 1a 00 00       	call   f01068f0 <cpunum>
f0104ee9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eec:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104ef3:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104ef6:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104efb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104f00:	77 20                	ja     f0104f22 <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104f02:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f06:	c7 44 24 08 64 70 10 	movl   $0xf0107064,0x8(%esp)
f0104f0d:	f0 
f0104f0e:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f0104f15:	00 
f0104f16:	c7 04 24 59 89 10 f0 	movl   $0xf0108959,(%esp)
f0104f1d:	e8 1e b1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104f22:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104f27:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104f2a:	e8 c1 19 00 00       	call   f01068f0 <cpunum>
f0104f2f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104f32:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104f38:	b8 02 00 00 00       	mov    $0x2,%eax
f0104f3d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104f41:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f0104f48:	e8 16 1d 00 00       	call   f0106c63 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104f4d:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104f4f:	e8 9c 19 00 00       	call   f01068f0 <cpunum>
f0104f54:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104f57:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104f5d:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104f62:	89 c4                	mov    %eax,%esp
f0104f64:	6a 00                	push   $0x0
f0104f66:	6a 00                	push   $0x0
f0104f68:	fb                   	sti    
f0104f69:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104f6a:	c9                   	leave  
f0104f6b:	c3                   	ret    

f0104f6c <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104f6c:	55                   	push   %ebp
f0104f6d:	89 e5                	mov    %esp,%ebp
f0104f6f:	57                   	push   %edi
f0104f70:	56                   	push   %esi
f0104f71:	53                   	push   %ebx
f0104f72:	83 ec 1c             	sub    $0x1c,%esp
		env_run(idle);
	}

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
f0104f75:	e8 76 19 00 00       	call   f01068f0 <cpunum>
f0104f7a:	6b c0 74             	imul   $0x74,%eax,%eax
		else cur = 0;
f0104f7d:	b9 00 00 00 00       	mov    $0x0,%ecx
		env_run(idle);
	}

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
f0104f82:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104f89:	74 1a                	je     f0104fa5 <sched_yield+0x39>
f0104f8b:	e8 60 19 00 00       	call   f01068f0 <cpunum>
f0104f90:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f93:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104f99:	8b 40 44             	mov    0x44(%eax),%eax
f0104f9c:	8b 48 48             	mov    0x48(%eax),%ecx
f0104f9f:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
f0104fa5:	89 cf                	mov    %ecx,%edi
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104fa7:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
f0104fad:	6b c1 7c             	imul   $0x7c,%ecx,%eax
f0104fb0:	89 c3                	mov    %eax,%ebx
f0104fb2:	83 7c 06 54 02       	cmpl   $0x2,0x54(%esi,%eax,1)
f0104fb7:	74 28                	je     f0104fe1 <sched_yield+0x75>

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
f0104fb9:	b8 01 00 00 00       	mov    $0x1,%eax

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0104fbe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
f0104fc1:	89 d3                	mov    %edx,%ebx
f0104fc3:	c1 fb 1f             	sar    $0x1f,%ebx
f0104fc6:	c1 eb 16             	shr    $0x16,%ebx
f0104fc9:	01 da                	add    %ebx,%edx
f0104fcb:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104fd1:	29 da                	sub    %ebx,%edx
f0104fd3:	89 d7                	mov    %edx,%edi
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104fd5:	6b d2 7c             	imul   $0x7c,%edx,%edx
f0104fd8:	89 d3                	mov    %edx,%ebx
f0104fda:	83 7c 16 54 02       	cmpl   $0x2,0x54(%esi,%edx,1)
f0104fdf:	75 1f                	jne    f0105000 <sched_yield+0x94>
			if (j == 1) 
f0104fe1:	83 ff 01             	cmp    $0x1,%edi
f0104fe4:	75 0c                	jne    f0104ff2 <sched_yield+0x86>
				cprintf("\n");
f0104fe6:	c7 04 24 30 87 10 f0 	movl   $0xf0108730,(%esp)
f0104fed:	e8 04 f6 ff ff       	call   f01045f6 <cprintf>
			env_run(envs + j);
f0104ff2:	03 1d 48 b2 22 f0    	add    0xf022b248,%ebx
f0104ff8:	89 1c 24             	mov    %ebx,(%esp)
f0104ffb:	e8 c2 f3 ff ff       	call   f01043c2 <env_run>

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
f0105000:	83 c0 01             	add    $0x1,%eax
f0105003:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105008:	75 b4                	jne    f0104fbe <sched_yield+0x52>
			if (j == 1) 
				cprintf("\n");
			env_run(envs + j);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f010500a:	e8 e1 18 00 00       	call   f01068f0 <cpunum>
f010500f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105012:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0105019:	74 2a                	je     f0105045 <sched_yield+0xd9>
f010501b:	e8 d0 18 00 00       	call   f01068f0 <cpunum>
f0105020:	6b c0 74             	imul   $0x74,%eax,%eax
f0105023:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105029:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010502d:	75 16                	jne    f0105045 <sched_yield+0xd9>
		env_run(curenv);
f010502f:	e8 bc 18 00 00       	call   f01068f0 <cpunum>
f0105034:	6b c0 74             	imul   $0x74,%eax,%eax
f0105037:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010503d:	89 04 24             	mov    %eax,(%esp)
f0105040:	e8 7d f3 ff ff       	call   f01043c2 <env_run>

	// sched_halt never returns
cprintf("**Fail to find one\n");
f0105045:	c7 04 24 66 89 10 f0 	movl   $0xf0108966,(%esp)
f010504c:	e8 a5 f5 ff ff       	call   f01045f6 <cprintf>
	sched_halt();
f0105051:	e8 32 fe ff ff       	call   f0104e88 <sched_halt>
}
f0105056:	83 c4 1c             	add    $0x1c,%esp
f0105059:	5b                   	pop    %ebx
f010505a:	5e                   	pop    %esi
f010505b:	5f                   	pop    %edi
f010505c:	5d                   	pop    %ebp
f010505d:	c3                   	ret    
	...

f0105060 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105060:	55                   	push   %ebp
f0105061:	89 e5                	mov    %esp,%ebp
f0105063:	83 ec 38             	sub    $0x38,%esp
f0105066:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105069:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010506c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010506f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105072:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105075:	8b 7d 10             	mov    0x10(%ebp),%edi

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);

		default: 
			return -E_INVAL;
f0105078:	be fd ff ff ff       	mov    $0xfffffffd,%esi
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno){
f010507d:	83 f8 0a             	cmp    $0xa,%eax
f0105080:	0f 87 e3 03 00 00    	ja     f0105469 <syscall+0x409>
f0105086:	ff 24 85 b4 89 10 f0 	jmp    *-0xfef764c(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(void *)s, len, PTE_U | PTE_P);
f010508d:	e8 5e 18 00 00       	call   f01068f0 <cpunum>
f0105092:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0105099:	00 
f010509a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010509e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01050ab:	89 04 24             	mov    %eax,(%esp)
f01050ae:	e8 59 eb ff ff       	call   f0103c0c <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01050b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01050b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01050bb:	c7 04 24 7a 89 10 f0 	movl   $0xf010897a,(%esp)
f01050c2:	e8 2f f5 ff ff       	call   f01045f6 <cprintf>
	// LAB 3: Your code here.
	switch (syscallno){
		case SYS_cputs:
			//cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
f01050c7:	be 00 00 00 00       	mov    $0x0,%esi
f01050cc:	e9 98 03 00 00       	jmp    f0105469 <syscall+0x409>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01050d1:	e8 72 b5 ff ff       	call   f0100648 <cons_getc>
f01050d6:	89 c6                	mov    %eax,%esi
			//cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
		case SYS_cgetc:
			//cprintf("SYS_cgetc\n");
			return sys_cgetc();
f01050d8:	e9 8c 03 00 00       	jmp    f0105469 <syscall+0x409>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01050dd:	8d 76 00             	lea    0x0(%esi),%esi
f01050e0:	e8 0b 18 00 00       	call   f01068f0 <cpunum>
f01050e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01050ee:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_cgetc:
			//cprintf("SYS_cgetc\n");
			return sys_cgetc();
		case SYS_getenvid:
			//cprintf("SYS_getenvid\n");
			return sys_getenvid();
f01050f1:	e9 73 03 00 00       	jmp    f0105469 <syscall+0x409>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01050f6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050fd:	00 
f01050fe:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105101:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105105:	89 1c 24             	mov    %ebx,(%esp)
f0105108:	e8 dc eb ff ff       	call   f0103ce9 <envid2env>
f010510d:	89 c6                	mov    %eax,%esi
f010510f:	85 c0                	test   %eax,%eax
f0105111:	0f 88 52 03 00 00    	js     f0105469 <syscall+0x409>
		return r;
	if (e == curenv)
f0105117:	e8 d4 17 00 00       	call   f01068f0 <cpunum>
f010511c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010511f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105122:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0105128:	75 23                	jne    f010514d <syscall+0xed>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010512a:	e8 c1 17 00 00       	call   f01068f0 <cpunum>
f010512f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105132:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105138:	8b 40 48             	mov    0x48(%eax),%eax
f010513b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010513f:	c7 04 24 7f 89 10 f0 	movl   $0xf010897f,(%esp)
f0105146:	e8 ab f4 ff ff       	call   f01045f6 <cprintf>
f010514b:	eb 28                	jmp    f0105175 <syscall+0x115>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010514d:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105150:	e8 9b 17 00 00       	call   f01068f0 <cpunum>
f0105155:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105159:	6b c0 74             	imul   $0x74,%eax,%eax
f010515c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105162:	8b 40 48             	mov    0x48(%eax),%eax
f0105165:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105169:	c7 04 24 9a 89 10 f0 	movl   $0xf010899a,(%esp)
f0105170:	e8 81 f4 ff ff       	call   f01045f6 <cprintf>
	env_destroy(e);
f0105175:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105178:	89 04 24             	mov    %eax,(%esp)
f010517b:	e8 95 f1 ff ff       	call   f0104315 <env_destroy>
	return 0;
f0105180:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_getenvid:
			//cprintf("SYS_getenvid\n");
			return sys_getenvid();
		case SYS_env_destroy:
			//cprintf("SYS_env_destroy\n");
			return sys_env_destroy(a1);
f0105185:	e9 df 02 00 00       	jmp    f0105469 <syscall+0x409>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010518a:	e8 dd fd ff ff       	call   f0104f6c <sched_yield>

	// LAB 4: Your code here.
//cprintf("**sys_exofork: get into\n");
	struct Env *env;
	int ret;
	if((ret = env_alloc(&env, curenv->env_id)) < 0) {
f010518f:	e8 5c 17 00 00       	call   f01068f0 <cpunum>
f0105194:	6b c0 74             	imul   $0x74,%eax,%eax
f0105197:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010519d:	8b 40 48             	mov    0x48(%eax),%eax
f01051a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051a4:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051a7:	89 04 24             	mov    %eax,(%esp)
f01051aa:	e8 4b ec ff ff       	call   f0103dfa <env_alloc>
f01051af:	89 c6                	mov    %eax,%esi
f01051b1:	85 c0                	test   %eax,%eax
f01051b3:	0f 88 b0 02 00 00    	js     f0105469 <syscall+0x409>
//cprintf("**sys_exofork: env_alloc fails\n");
		return ret;
	}

	env->env_status = ENV_NOT_RUNNABLE;
f01051b9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01051bc:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	env->env_tf = curenv->env_tf;
f01051c3:	e8 28 17 00 00       	call   f01068f0 <cpunum>
f01051c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01051cb:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
f01051d1:	b9 11 00 00 00       	mov    $0x11,%ecx
f01051d6:	89 df                	mov    %ebx,%edi
f01051d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// At the point that system call
	// Why the child does not go into the system call again
	env->env_tf.tf_regs.reg_eax = 0;
f01051da:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051dd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

//cprintf("**sys_exofork: env_id = %x\n", env->env_id);
	return env->env_id;
f01051e4:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_yield:
			//cprintf("SYS_yield\n");
			sys_yield();

		case SYS_exofork:
			return sys_exofork();
f01051e7:	e9 7d 02 00 00       	jmp    f0105469 <syscall+0x409>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
f01051ec:	89 d8                	mov    %ebx,%eax
f01051ee:	c1 e8 1f             	shr    $0x1f,%eax
f01051f1:	84 c0                	test   %al,%al
f01051f3:	0f 85 f5 00 00 00    	jne    f01052ee <syscall+0x28e>
f01051f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01051fc:	c1 e8 1f             	shr    $0x1f,%eax
f01051ff:	84 c0                	test   %al,%al
f0105201:	0f 85 e7 00 00 00    	jne    f01052ee <syscall+0x28e>
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
f0105207:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010520e:	00 
f010520f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105212:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105216:	89 1c 24             	mov    %ebx,(%esp)
f0105219:	e8 cb ea ff ff       	call   f0103ce9 <envid2env>
		return -E_BAD_ENV;
f010521e:	be fe ff ff ff       	mov    $0xfffffffe,%esi

	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
f0105223:	85 c0                	test   %eax,%eax
f0105225:	0f 88 3e 02 00 00    	js     f0105469 <syscall+0x409>
f010522b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105232:	00 
f0105233:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105236:	89 44 24 04          	mov    %eax,0x4(%esp)
f010523a:	8b 45 14             	mov    0x14(%ebp),%eax
f010523d:	89 04 24             	mov    %eax,(%esp)
f0105240:	e8 a4 ea ff ff       	call   f0103ce9 <envid2env>
f0105245:	85 c0                	test   %eax,%eax
f0105247:	0f 88 ab 00 00 00    	js     f01052f8 <syscall+0x298>
		return -E_BAD_ENV;

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
		return -E_INVAL;
f010524d:	66 be fd ff          	mov    $0xfffd,%si
	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
		return -E_BAD_ENV;

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
f0105251:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105257:	0f 87 0c 02 00 00    	ja     f0105469 <syscall+0x409>
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
f010525d:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105263:	0f 85 99 00 00 00    	jne    f0105302 <syscall+0x2a2>
f0105269:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105270:	0f 87 8c 00 00 00    	ja     f0105302 <syscall+0x2a2>
f0105276:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010527d:	0f 85 e6 01 00 00    	jne    f0105469 <syscall+0x409>
		return -E_INVAL;

	pte_t *pte;
	struct PageInfo *p;
	if((p = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f0105283:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105286:	89 44 24 08          	mov    %eax,0x8(%esp)
f010528a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010528e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105291:	8b 40 60             	mov    0x60(%eax),%eax
f0105294:	89 04 24             	mov    %eax,(%esp)
f0105297:	e8 ad c6 ff ff       	call   f0101949 <page_lookup>
f010529c:	85 c0                	test   %eax,%eax
f010529e:	74 6c                	je     f010530c <syscall+0x2ac>
		return -E_INVAL;

	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f01052a0:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01052a3:	83 e2 05             	and    $0x5,%edx
f01052a6:	83 fa 05             	cmp    $0x5,%edx
f01052a9:	0f 85 ba 01 00 00    	jne    f0105469 <syscall+0x409>
		return -E_INVAL;

	if(perm & PTE_W && !(*pte & PTE_W))
f01052af:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01052b3:	74 0c                	je     f01052c1 <syscall+0x261>
f01052b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01052b8:	f6 02 02             	testb  $0x2,(%edx)
f01052bb:	0f 84 a8 01 00 00    	je     f0105469 <syscall+0x409>
		return -E_INVAL;

	if(page_insert(dstenv->env_pgdir, p, dstva, perm) < 0)
f01052c1:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01052c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01052c8:	8b 55 18             	mov    0x18(%ebp),%edx
f01052cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01052cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052d6:	8b 40 60             	mov    0x60(%eax),%eax
f01052d9:	89 04 24             	mov    %eax,(%esp)
f01052dc:	e8 65 c7 ff ff       	call   f0101a46 <page_insert>
		return -E_NO_MEM;
f01052e1:	89 c6                	mov    %eax,%esi
f01052e3:	c1 fe 1f             	sar    $0x1f,%esi
f01052e6:	83 e6 fc             	and    $0xfffffffc,%esi
f01052e9:	e9 7b 01 00 00       	jmp    f0105469 <syscall+0x409>
	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
		return -E_BAD_ENV;
f01052ee:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01052f3:	e9 71 01 00 00       	jmp    f0105469 <syscall+0x409>
f01052f8:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01052fd:	e9 67 01 00 00       	jmp    f0105469 <syscall+0x409>

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
		return -E_INVAL;
f0105302:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105307:	e9 5d 01 00 00       	jmp    f0105469 <syscall+0x409>

	pte_t *pte;
	struct PageInfo *p;
	if((p = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f010530c:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105311:	e9 53 01 00 00       	jmp    f0105469 <syscall+0x409>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
f0105316:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010531d:	00 
f010531e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105321:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105325:	89 1c 24             	mov    %ebx,(%esp)
f0105328:	e8 bc e9 ff ff       	call   f0103ce9 <envid2env>
f010532d:	85 c0                	test   %eax,%eax
f010532f:	78 39                	js     f010536a <syscall+0x30a>
		return -E_BAD_ENV;
	if(va >= (void *)UTOP || (unsigned int)va % PGSIZE != 0)
		return -E_INVAL;
f0105331:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
		return -E_BAD_ENV;
	if(va >= (void *)UTOP || (unsigned int)va % PGSIZE != 0)
f0105336:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010533c:	0f 87 27 01 00 00    	ja     f0105469 <syscall+0x409>
f0105342:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105348:	0f 85 1b 01 00 00    	jne    f0105469 <syscall+0x409>
		return -E_INVAL;

	page_remove(env->env_pgdir, va);
f010534e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105355:	8b 40 60             	mov    0x60(%eax),%eax
f0105358:	89 04 24             	mov    %eax,(%esp)
f010535b:	e8 96 c6 ff ff       	call   f01019f6 <page_remove>

	return 0;
f0105360:	be 00 00 00 00       	mov    $0x0,%esi
f0105365:	e9 ff 00 00 00       	jmp    f0105469 <syscall+0x409>

	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
		return -E_BAD_ENV;
f010536a:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f010536f:	e9 f5 00 00 00       	jmp    f0105469 <syscall+0x409>

	// LAB 4: Your code here.

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
f0105374:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010537b:	00 
f010537c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010537f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105383:	89 1c 24             	mov    %ebx,(%esp)
f0105386:	e8 5e e9 ff ff       	call   f0103ce9 <envid2env>
f010538b:	85 c0                	test   %eax,%eax
f010538d:	78 64                	js     f01053f3 <syscall+0x393>
		return -E_BAD_ENV;
	if(va >= (void *)UTOP)
		return -E_INVAL;
f010538f:	be fd ff ff ff       	mov    $0xfffffffd,%esi

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
	if(va >= (void *)UTOP)
f0105394:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010539a:	0f 87 c9 00 00 00    	ja     f0105469 <syscall+0x409>
		return -E_INVAL;
	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f01053a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a3:	83 e0 05             	and    $0x5,%eax
f01053a6:	83 f8 05             	cmp    $0x5,%eax
f01053a9:	0f 85 ba 00 00 00    	jne    f0105469 <syscall+0x409>
		return -E_INVAL;

	
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f01053af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01053b6:	e8 a7 c3 ff ff       	call   f0101762 <page_alloc>
f01053bb:	89 c3                	mov    %eax,%ebx
	if(!p) {
f01053bd:	85 c0                	test   %eax,%eax
f01053bf:	74 39                	je     f01053fa <syscall+0x39a>
		return -E_NO_MEM;
	}
	p->pp_ref ++;
f01053c1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

	int ret;
	if((ret = page_insert(env->env_pgdir, p, va, perm)) < 0) {
f01053c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01053c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01053cd:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01053d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053d8:	8b 40 60             	mov    0x60(%eax),%eax
f01053db:	89 04 24             	mov    %eax,(%esp)
f01053de:	e8 63 c6 ff ff       	call   f0101a46 <page_insert>
f01053e3:	89 c6                	mov    %eax,%esi
f01053e5:	85 c0                	test   %eax,%eax
f01053e7:	79 18                	jns    f0105401 <syscall+0x3a1>
		page_free(p);
f01053e9:	89 1c 24             	mov    %ebx,(%esp)
f01053ec:	e8 ef c3 ff ff       	call   f01017e0 <page_free>
f01053f1:	eb 76                	jmp    f0105469 <syscall+0x409>
	// LAB 4: Your code here.

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f01053f3:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01053f8:	eb 6f                	jmp    f0105469 <syscall+0x409>
		return -E_INVAL;

	
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
	if(!p) {
		return -E_NO_MEM;
f01053fa:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f01053ff:	eb 68                	jmp    f0105469 <syscall+0x409>
	int ret;
	if((ret = page_insert(env->env_pgdir, p, va, perm)) < 0) {
		page_free(p);
		return ret;
	}
	return 0;
f0105401:	be 00 00 00 00       	mov    $0x0,%esi
			return sys_page_map((envid_t)a1, (void *)a2,
	     		(envid_t)a3, (void *)a4, (int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0105406:	eb 61                	jmp    f0105469 <syscall+0x409>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f0105408:	83 ff 04             	cmp    $0x4,%edi
f010540b:	74 0a                	je     f0105417 <syscall+0x3b7>
		return -E_INVAL;
f010540d:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f0105412:	83 ff 02             	cmp    $0x2,%edi
f0105415:	75 52                	jne    f0105469 <syscall+0x409>
		return -E_INVAL;
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0)
f0105417:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010541e:	00 
f010541f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105422:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105426:	89 1c 24             	mov    %ebx,(%esp)
f0105429:	e8 bb e8 ff ff       	call   f0103ce9 <envid2env>
f010542e:	85 c0                	test   %eax,%eax
f0105430:	78 0d                	js     f010543f <syscall+0x3df>
		return -E_BAD_ENV;

	env->env_status = status;
f0105432:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105435:	89 78 54             	mov    %edi,0x54(%eax)

	return 0;
f0105438:	be 00 00 00 00       	mov    $0x0,%esi
f010543d:	eb 2a                	jmp    f0105469 <syscall+0x409>
	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
		return -E_INVAL;
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f010543f:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f0105444:	eb 23                	jmp    f0105469 <syscall+0x409>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
    int ret = envid2env(envid, &e, 1);
f0105446:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010544d:	00 
f010544e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105451:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105455:	89 1c 24             	mov    %ebx,(%esp)
f0105458:	e8 8c e8 ff ff       	call   f0103ce9 <envid2env>
f010545d:	89 c6                	mov    %eax,%esi
    if (ret) return ret;    //bad_env
f010545f:	85 c0                	test   %eax,%eax
f0105461:	75 06                	jne    f0105469 <syscall+0x409>
    e->env_pgfault_upcall = func;
f0105463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105466:	89 78 64             	mov    %edi,0x64(%eax)
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);

		default: 
			return -E_INVAL;
	}
}
f0105469:	89 f0                	mov    %esi,%eax
f010546b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010546e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105471:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105474:	89 ec                	mov    %ebp,%esp
f0105476:	5d                   	pop    %ebp
f0105477:	c3                   	ret    

f0105478 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105478:	55                   	push   %ebp
f0105479:	89 e5                	mov    %esp,%ebp
f010547b:	57                   	push   %edi
f010547c:	56                   	push   %esi
f010547d:	53                   	push   %ebx
f010547e:	83 ec 14             	sub    $0x14,%esp
f0105481:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105484:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105487:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010548a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010548d:	8b 1a                	mov    (%edx),%ebx
f010548f:	8b 01                	mov    (%ecx),%eax
f0105491:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0105494:	39 c3                	cmp    %eax,%ebx
f0105496:	0f 8f 9c 00 00 00    	jg     f0105538 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f010549c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01054a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054a6:	01 d8                	add    %ebx,%eax
f01054a8:	89 c7                	mov    %eax,%edi
f01054aa:	c1 ef 1f             	shr    $0x1f,%edi
f01054ad:	01 c7                	add    %eax,%edi
f01054af:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01054b1:	39 df                	cmp    %ebx,%edi
f01054b3:	7c 33                	jl     f01054e8 <stab_binsearch+0x70>
f01054b5:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01054b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01054bb:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01054c0:	39 f0                	cmp    %esi,%eax
f01054c2:	0f 84 bc 00 00 00    	je     f0105584 <stab_binsearch+0x10c>
f01054c8:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01054cc:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01054d0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01054d2:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01054d5:	39 d8                	cmp    %ebx,%eax
f01054d7:	7c 0f                	jl     f01054e8 <stab_binsearch+0x70>
f01054d9:	0f b6 0a             	movzbl (%edx),%ecx
f01054dc:	83 ea 0c             	sub    $0xc,%edx
f01054df:	39 f1                	cmp    %esi,%ecx
f01054e1:	75 ef                	jne    f01054d2 <stab_binsearch+0x5a>
f01054e3:	e9 9e 00 00 00       	jmp    f0105586 <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01054e8:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01054eb:	eb 3c                	jmp    f0105529 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01054ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01054f0:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01054f2:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054f5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01054fc:	eb 2b                	jmp    f0105529 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01054fe:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105501:	76 14                	jbe    f0105517 <stab_binsearch+0x9f>
			*region_right = m - 1;
f0105503:	83 e8 01             	sub    $0x1,%eax
f0105506:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105509:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010550c:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010550e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105515:	eb 12                	jmp    f0105529 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105517:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010551a:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f010551c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105520:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105522:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105529:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f010552c:	0f 8d 71 ff ff ff    	jge    f01054a3 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105532:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105536:	75 0f                	jne    f0105547 <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0105538:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010553b:	8b 02                	mov    (%edx),%eax
f010553d:	83 e8 01             	sub    $0x1,%eax
f0105540:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105543:	89 01                	mov    %eax,(%ecx)
f0105545:	eb 57                	jmp    f010559e <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105547:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010554a:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010554c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010554f:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105551:	39 c1                	cmp    %eax,%ecx
f0105553:	7d 28                	jge    f010557d <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105555:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105558:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f010555b:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105560:	39 f2                	cmp    %esi,%edx
f0105562:	74 19                	je     f010557d <stab_binsearch+0x105>
f0105564:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105568:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010556c:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010556f:	39 c1                	cmp    %eax,%ecx
f0105571:	7d 0a                	jge    f010557d <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105573:	0f b6 1a             	movzbl (%edx),%ebx
f0105576:	83 ea 0c             	sub    $0xc,%edx
f0105579:	39 f3                	cmp    %esi,%ebx
f010557b:	75 ef                	jne    f010556c <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f010557d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105580:	89 02                	mov    %eax,(%edx)
f0105582:	eb 1a                	jmp    f010559e <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105584:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105586:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105589:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f010558c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105590:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105593:	0f 82 54 ff ff ff    	jb     f01054ed <stab_binsearch+0x75>
f0105599:	e9 60 ff ff ff       	jmp    f01054fe <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010559e:	83 c4 14             	add    $0x14,%esp
f01055a1:	5b                   	pop    %ebx
f01055a2:	5e                   	pop    %esi
f01055a3:	5f                   	pop    %edi
f01055a4:	5d                   	pop    %ebp
f01055a5:	c3                   	ret    

f01055a6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01055a6:	55                   	push   %ebp
f01055a7:	89 e5                	mov    %esp,%ebp
f01055a9:	57                   	push   %edi
f01055aa:	56                   	push   %esi
f01055ab:	53                   	push   %ebx
f01055ac:	83 ec 5c             	sub    $0x5c,%esp
f01055af:	8b 75 08             	mov    0x8(%ebp),%esi
f01055b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01055b5:	c7 03 e0 89 10 f0    	movl   $0xf01089e0,(%ebx)
	info->eip_line = 0;
f01055bb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01055c2:	c7 43 08 e0 89 10 f0 	movl   $0xf01089e0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01055c9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01055d0:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01055d3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01055da:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01055e0:	0f 87 d8 00 00 00    	ja     f01056be <debuginfo_eip+0x118>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01055e6:	e8 05 13 00 00       	call   f01068f0 <cpunum>
f01055eb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01055f2:	00 
f01055f3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01055fa:	00 
f01055fb:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105602:	00 
f0105603:	6b c0 74             	imul   $0x74,%eax,%eax
f0105606:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010560c:	89 04 24             	mov    %eax,(%esp)
f010560f:	e8 68 e5 ff ff       	call   f0103b7c <user_mem_check>
f0105614:	89 c2                	mov    %eax,%edx
			return -1;
f0105616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010561b:	85 d2                	test   %edx,%edx
f010561d:	0f 85 a5 02 00 00    	jne    f01058c8 <debuginfo_eip+0x322>
			return -1;

		stabs = usd->stabs;
f0105623:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105629:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010562c:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105632:	a1 08 00 20 00       	mov    0x200008,%eax
f0105637:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010563a:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105640:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105643:	e8 a8 12 00 00       	call   f01068f0 <cpunum>
f0105648:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010564f:	00 
f0105650:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0105657:	00 
f0105658:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010565b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010565f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105662:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105668:	89 04 24             	mov    %eax,(%esp)
f010566b:	e8 0c e5 ff ff       	call   f0103b7c <user_mem_check>
f0105670:	89 c2                	mov    %eax,%edx
			return -1;
f0105672:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105677:	85 d2                	test   %edx,%edx
f0105679:	0f 85 49 02 00 00    	jne    f01058c8 <debuginfo_eip+0x322>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010567f:	e8 6c 12 00 00       	call   f01068f0 <cpunum>
f0105684:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010568b:	00 
f010568c:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010568f:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105692:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105696:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105699:	89 54 24 04          	mov    %edx,0x4(%esp)
f010569d:	6b c0 74             	imul   $0x74,%eax,%eax
f01056a0:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01056a6:	89 04 24             	mov    %eax,(%esp)
f01056a9:	e8 ce e4 ff ff       	call   f0103b7c <user_mem_check>
f01056ae:	89 c2                	mov    %eax,%edx
			return -1;
f01056b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f01056b5:	85 d2                	test   %edx,%edx
f01056b7:	74 1f                	je     f01056d8 <debuginfo_eip+0x132>
f01056b9:	e9 0a 02 00 00       	jmp    f01058c8 <debuginfo_eip+0x322>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01056be:	c7 45 c0 f8 7b 11 f0 	movl   $0xf0117bf8,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01056c5:	c7 45 bc f9 42 11 f0 	movl   $0xf01142f9,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01056cc:	bf f8 42 11 f0       	mov    $0xf01142f8,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01056d1:	c7 45 c4 d4 8e 10 f0 	movl   $0xf0108ed4,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01056d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01056dd:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01056e0:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01056e3:	0f 83 df 01 00 00    	jae    f01058c8 <debuginfo_eip+0x322>
f01056e9:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01056ed:	0f 85 d5 01 00 00    	jne    f01058c8 <debuginfo_eip+0x322>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01056f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01056fa:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01056fd:	c1 ff 02             	sar    $0x2,%edi
f0105700:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0105706:	83 e8 01             	sub    $0x1,%eax
f0105709:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010570c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105710:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105717:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010571a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010571d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105720:	e8 53 fd ff ff       	call   f0105478 <stab_binsearch>
	if (lfile == 0)
f0105725:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0105728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010572d:	85 d2                	test   %edx,%edx
f010572f:	0f 84 93 01 00 00    	je     f01058c8 <debuginfo_eip+0x322>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105735:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0105738:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010573b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010573e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105742:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105749:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010574c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010574f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105752:	e8 21 fd ff ff       	call   f0105478 <stab_binsearch>

	if (lfun <= rfun) {
f0105757:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010575a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010575d:	39 d0                	cmp    %edx,%eax
f010575f:	7f 32                	jg     f0105793 <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105761:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105764:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105767:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f010576a:	8b 39                	mov    (%ecx),%edi
f010576c:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f010576f:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105772:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105775:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105778:	73 09                	jae    f0105783 <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010577a:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010577d:	03 7d bc             	add    -0x44(%ebp),%edi
f0105780:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105783:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105786:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105789:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010578b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010578e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105791:	eb 0f                	jmp    f01057a2 <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105793:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105796:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105799:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010579c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010579f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01057a2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01057a9:	00 
f01057aa:	8b 43 08             	mov    0x8(%ebx),%eax
f01057ad:	89 04 24             	mov    %eax,(%esp)
f01057b0:	e8 85 0a 00 00       	call   f010623a <strfind>
f01057b5:	2b 43 08             	sub    0x8(%ebx),%eax
f01057b8:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01057bb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057bf:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01057c6:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01057c9:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01057cc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01057cf:	e8 a4 fc ff ff       	call   f0105478 <stab_binsearch>

	if(lline <= rline)
f01057d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f01057d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f01057dc:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01057df:	0f 8f e3 00 00 00    	jg     f01058c8 <debuginfo_eip+0x322>
		info->eip_line = stabs[lline].n_desc;
f01057e5:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01057e8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01057eb:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01057f0:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01057f3:	89 d0                	mov    %edx,%eax
f01057f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01057f8:	89 7d b8             	mov    %edi,-0x48(%ebp)
f01057fb:	39 fa                	cmp    %edi,%edx
f01057fd:	7c 74                	jl     f0105873 <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f01057ff:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105802:	89 f7                	mov    %esi,%edi
f0105804:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0105807:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f010580b:	80 f9 84             	cmp    $0x84,%cl
f010580e:	74 46                	je     f0105856 <debuginfo_eip+0x2b0>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105810:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0105814:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105817:	89 c7                	mov    %eax,%edi
f0105819:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f010581c:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010581f:	eb 1f                	jmp    f0105840 <debuginfo_eip+0x29a>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105821:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105824:	39 c3                	cmp    %eax,%ebx
f0105826:	7f 48                	jg     f0105870 <debuginfo_eip+0x2ca>
	       && stabs[lline].n_type != N_SOL
f0105828:	89 d6                	mov    %edx,%esi
f010582a:	83 ea 0c             	sub    $0xc,%edx
f010582d:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f0105831:	80 f9 84             	cmp    $0x84,%cl
f0105834:	75 08                	jne    f010583e <debuginfo_eip+0x298>
f0105836:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105839:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010583c:	eb 18                	jmp    f0105856 <debuginfo_eip+0x2b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010583e:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105840:	80 f9 64             	cmp    $0x64,%cl
f0105843:	75 dc                	jne    f0105821 <debuginfo_eip+0x27b>
f0105845:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105849:	74 d6                	je     f0105821 <debuginfo_eip+0x27b>
f010584b:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f010584e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105851:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f0105854:	7c 1d                	jl     f0105873 <debuginfo_eip+0x2cd>
f0105856:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105859:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010585c:	8b 04 86             	mov    (%esi,%eax,4),%eax
f010585f:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105862:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105865:	39 d0                	cmp    %edx,%eax
f0105867:	73 0a                	jae    f0105873 <debuginfo_eip+0x2cd>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105869:	03 45 bc             	add    -0x44(%ebp),%eax
f010586c:	89 03                	mov    %eax,(%ebx)
f010586e:	eb 03                	jmp    f0105873 <debuginfo_eip+0x2cd>
f0105870:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105873:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105876:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105879:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010587c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105881:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f0105884:	7d 42                	jge    f01058c8 <debuginfo_eip+0x322>
		for (lline = lfun + 1;
f0105886:	8d 57 01             	lea    0x1(%edi),%edx
f0105889:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010588c:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f010588f:	7e 37                	jle    f01058c8 <debuginfo_eip+0x322>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105891:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0105894:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105897:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f010589c:	75 2a                	jne    f01058c8 <debuginfo_eip+0x322>
f010589e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01058a1:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f01058a5:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01058a8:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01058ac:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01058af:	39 d1                	cmp    %edx,%ecx
f01058b1:	7e 10                	jle    f01058c3 <debuginfo_eip+0x31d>
f01058b3:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01058b6:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f01058ba:	74 ec                	je     f01058a8 <debuginfo_eip+0x302>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01058bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01058c1:	eb 05                	jmp    f01058c8 <debuginfo_eip+0x322>
f01058c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058c8:	83 c4 5c             	add    $0x5c,%esp
f01058cb:	5b                   	pop    %ebx
f01058cc:	5e                   	pop    %esi
f01058cd:	5f                   	pop    %edi
f01058ce:	5d                   	pop    %ebp
f01058cf:	c3                   	ret    

f01058d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01058d0:	55                   	push   %ebp
f01058d1:	89 e5                	mov    %esp,%ebp
f01058d3:	57                   	push   %edi
f01058d4:	56                   	push   %esi
f01058d5:	53                   	push   %ebx
f01058d6:	83 ec 3c             	sub    $0x3c,%esp
f01058d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058dc:	89 d7                	mov    %edx,%edi
f01058de:	8b 45 08             	mov    0x8(%ebp),%eax
f01058e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01058e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01058ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01058ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01058f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01058f5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01058f8:	72 11                	jb     f010590b <printnum+0x3b>
f01058fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01058fd:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105900:	76 09                	jbe    f010590b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105902:	83 eb 01             	sub    $0x1,%ebx
f0105905:	85 db                	test   %ebx,%ebx
f0105907:	7f 51                	jg     f010595a <printnum+0x8a>
f0105909:	eb 5e                	jmp    f0105969 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010590b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010590f:	83 eb 01             	sub    $0x1,%ebx
f0105912:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105916:	8b 45 10             	mov    0x10(%ebp),%eax
f0105919:	89 44 24 08          	mov    %eax,0x8(%esp)
f010591d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105921:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105925:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010592c:	00 
f010592d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105930:	89 04 24             	mov    %eax,(%esp)
f0105933:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105936:	89 44 24 04          	mov    %eax,0x4(%esp)
f010593a:	e8 41 14 00 00       	call   f0106d80 <__udivdi3>
f010593f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105943:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105947:	89 04 24             	mov    %eax,(%esp)
f010594a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010594e:	89 fa                	mov    %edi,%edx
f0105950:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105953:	e8 78 ff ff ff       	call   f01058d0 <printnum>
f0105958:	eb 0f                	jmp    f0105969 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010595a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010595e:	89 34 24             	mov    %esi,(%esp)
f0105961:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105964:	83 eb 01             	sub    $0x1,%ebx
f0105967:	75 f1                	jne    f010595a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105969:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010596d:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105971:	8b 45 10             	mov    0x10(%ebp),%eax
f0105974:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105978:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010597f:	00 
f0105980:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105983:	89 04 24             	mov    %eax,(%esp)
f0105986:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105989:	89 44 24 04          	mov    %eax,0x4(%esp)
f010598d:	e8 1e 15 00 00       	call   f0106eb0 <__umoddi3>
f0105992:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105996:	0f be 80 ea 89 10 f0 	movsbl -0xfef7616(%eax),%eax
f010599d:	89 04 24             	mov    %eax,(%esp)
f01059a0:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01059a3:	83 c4 3c             	add    $0x3c,%esp
f01059a6:	5b                   	pop    %ebx
f01059a7:	5e                   	pop    %esi
f01059a8:	5f                   	pop    %edi
f01059a9:	5d                   	pop    %ebp
f01059aa:	c3                   	ret    

f01059ab <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01059ab:	55                   	push   %ebp
f01059ac:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01059ae:	83 fa 01             	cmp    $0x1,%edx
f01059b1:	7e 0e                	jle    f01059c1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01059b3:	8b 10                	mov    (%eax),%edx
f01059b5:	8d 4a 08             	lea    0x8(%edx),%ecx
f01059b8:	89 08                	mov    %ecx,(%eax)
f01059ba:	8b 02                	mov    (%edx),%eax
f01059bc:	8b 52 04             	mov    0x4(%edx),%edx
f01059bf:	eb 22                	jmp    f01059e3 <getuint+0x38>
	else if (lflag)
f01059c1:	85 d2                	test   %edx,%edx
f01059c3:	74 10                	je     f01059d5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01059c5:	8b 10                	mov    (%eax),%edx
f01059c7:	8d 4a 04             	lea    0x4(%edx),%ecx
f01059ca:	89 08                	mov    %ecx,(%eax)
f01059cc:	8b 02                	mov    (%edx),%eax
f01059ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01059d3:	eb 0e                	jmp    f01059e3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01059d5:	8b 10                	mov    (%eax),%edx
f01059d7:	8d 4a 04             	lea    0x4(%edx),%ecx
f01059da:	89 08                	mov    %ecx,(%eax)
f01059dc:	8b 02                	mov    (%edx),%eax
f01059de:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01059e3:	5d                   	pop    %ebp
f01059e4:	c3                   	ret    

f01059e5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01059e5:	55                   	push   %ebp
f01059e6:	89 e5                	mov    %esp,%ebp
f01059e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01059eb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01059ef:	8b 10                	mov    (%eax),%edx
f01059f1:	3b 50 04             	cmp    0x4(%eax),%edx
f01059f4:	73 0a                	jae    f0105a00 <sprintputch+0x1b>
		*b->buf++ = ch;
f01059f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059f9:	88 0a                	mov    %cl,(%edx)
f01059fb:	83 c2 01             	add    $0x1,%edx
f01059fe:	89 10                	mov    %edx,(%eax)
}
f0105a00:	5d                   	pop    %ebp
f0105a01:	c3                   	ret    

f0105a02 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105a02:	55                   	push   %ebp
f0105a03:	89 e5                	mov    %esp,%ebp
f0105a05:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105a08:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105a0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a0f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a12:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a19:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a20:	89 04 24             	mov    %eax,(%esp)
f0105a23:	e8 02 00 00 00       	call   f0105a2a <vprintfmt>
	va_end(ap);
}
f0105a28:	c9                   	leave  
f0105a29:	c3                   	ret    

f0105a2a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105a2a:	55                   	push   %ebp
f0105a2b:	89 e5                	mov    %esp,%ebp
f0105a2d:	57                   	push   %edi
f0105a2e:	56                   	push   %esi
f0105a2f:	53                   	push   %ebx
f0105a30:	83 ec 5c             	sub    $0x5c,%esp
f0105a33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a36:	8b 75 10             	mov    0x10(%ebp),%esi
f0105a39:	eb 12                	jmp    f0105a4d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105a3b:	85 c0                	test   %eax,%eax
f0105a3d:	0f 84 e4 04 00 00    	je     f0105f27 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f0105a43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a47:	89 04 24             	mov    %eax,(%esp)
f0105a4a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105a4d:	0f b6 06             	movzbl (%esi),%eax
f0105a50:	83 c6 01             	add    $0x1,%esi
f0105a53:	83 f8 25             	cmp    $0x25,%eax
f0105a56:	75 e3                	jne    f0105a3b <vprintfmt+0x11>
f0105a58:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0105a5c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0105a63:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105a68:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0105a6f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a74:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105a77:	eb 2b                	jmp    f0105aa4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a79:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105a7c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0105a80:	eb 22                	jmp    f0105aa4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a82:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105a85:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0105a89:	eb 19                	jmp    f0105aa4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a8b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105a8e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105a95:	eb 0d                	jmp    f0105aa4 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105a97:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105a9a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105a9d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105aa4:	0f b6 06             	movzbl (%esi),%eax
f0105aa7:	0f b6 d0             	movzbl %al,%edx
f0105aaa:	8d 7e 01             	lea    0x1(%esi),%edi
f0105aad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105ab0:	83 e8 23             	sub    $0x23,%eax
f0105ab3:	3c 55                	cmp    $0x55,%al
f0105ab5:	0f 87 46 04 00 00    	ja     f0105f01 <vprintfmt+0x4d7>
f0105abb:	0f b6 c0             	movzbl %al,%eax
f0105abe:	ff 24 85 c0 8a 10 f0 	jmp    *-0xfef7540(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105ac5:	83 ea 30             	sub    $0x30,%edx
f0105ac8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0105acb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105acf:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ad2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0105ad5:	83 fa 09             	cmp    $0x9,%edx
f0105ad8:	77 4a                	ja     f0105b24 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ada:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105add:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105ae0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105ae3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105ae7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105aea:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105aed:	83 fa 09             	cmp    $0x9,%edx
f0105af0:	76 eb                	jbe    f0105add <vprintfmt+0xb3>
f0105af2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105af5:	eb 2d                	jmp    f0105b24 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105af7:	8b 45 14             	mov    0x14(%ebp),%eax
f0105afa:	8d 50 04             	lea    0x4(%eax),%edx
f0105afd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b00:	8b 00                	mov    (%eax),%eax
f0105b02:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b05:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105b08:	eb 1a                	jmp    f0105b24 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b0a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0105b0d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105b11:	79 91                	jns    f0105aa4 <vprintfmt+0x7a>
f0105b13:	e9 73 ff ff ff       	jmp    f0105a8b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b18:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105b1b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f0105b22:	eb 80                	jmp    f0105aa4 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0105b24:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105b28:	0f 89 76 ff ff ff    	jns    f0105aa4 <vprintfmt+0x7a>
f0105b2e:	e9 64 ff ff ff       	jmp    f0105a97 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105b33:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b36:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105b39:	e9 66 ff ff ff       	jmp    f0105aa4 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105b3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b41:	8d 50 04             	lea    0x4(%eax),%edx
f0105b44:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b4b:	8b 00                	mov    (%eax),%eax
f0105b4d:	89 04 24             	mov    %eax,(%esp)
f0105b50:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b53:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105b56:	e9 f2 fe ff ff       	jmp    f0105a4d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0105b5b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105b5f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f0105b62:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f0105b66:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0105b69:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0105b6d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0105b70:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0105b73:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f0105b77:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105b7a:	80 f9 09             	cmp    $0x9,%cl
f0105b7d:	77 1d                	ja     f0105b9c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0105b7f:	0f be c0             	movsbl %al,%eax
f0105b82:	6b c0 64             	imul   $0x64,%eax,%eax
f0105b85:	0f be d2             	movsbl %dl,%edx
f0105b88:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105b8b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0105b92:	a3 78 24 12 f0       	mov    %eax,0xf0122478
f0105b97:	e9 b1 fe ff ff       	jmp    f0105a4d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0105b9c:	c7 44 24 04 02 8a 10 	movl   $0xf0108a02,0x4(%esp)
f0105ba3:	f0 
f0105ba4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105ba7:	89 04 24             	mov    %eax,(%esp)
f0105baa:	e8 dc 05 00 00       	call   f010618b <strcmp>
f0105baf:	85 c0                	test   %eax,%eax
f0105bb1:	75 0f                	jne    f0105bc2 <vprintfmt+0x198>
f0105bb3:	c7 05 78 24 12 f0 04 	movl   $0x4,0xf0122478
f0105bba:	00 00 00 
f0105bbd:	e9 8b fe ff ff       	jmp    f0105a4d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0105bc2:	c7 44 24 04 06 8a 10 	movl   $0xf0108a06,0x4(%esp)
f0105bc9:	f0 
f0105bca:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105bcd:	89 14 24             	mov    %edx,(%esp)
f0105bd0:	e8 b6 05 00 00       	call   f010618b <strcmp>
f0105bd5:	85 c0                	test   %eax,%eax
f0105bd7:	75 0f                	jne    f0105be8 <vprintfmt+0x1be>
f0105bd9:	c7 05 78 24 12 f0 02 	movl   $0x2,0xf0122478
f0105be0:	00 00 00 
f0105be3:	e9 65 fe ff ff       	jmp    f0105a4d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0105be8:	c7 44 24 04 0a 8a 10 	movl   $0xf0108a0a,0x4(%esp)
f0105bef:	f0 
f0105bf0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0105bf3:	89 0c 24             	mov    %ecx,(%esp)
f0105bf6:	e8 90 05 00 00       	call   f010618b <strcmp>
f0105bfb:	85 c0                	test   %eax,%eax
f0105bfd:	75 0f                	jne    f0105c0e <vprintfmt+0x1e4>
f0105bff:	c7 05 78 24 12 f0 01 	movl   $0x1,0xf0122478
f0105c06:	00 00 00 
f0105c09:	e9 3f fe ff ff       	jmp    f0105a4d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f0105c0e:	c7 44 24 04 0e 8a 10 	movl   $0xf0108a0e,0x4(%esp)
f0105c15:	f0 
f0105c16:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0105c19:	89 3c 24             	mov    %edi,(%esp)
f0105c1c:	e8 6a 05 00 00       	call   f010618b <strcmp>
f0105c21:	85 c0                	test   %eax,%eax
f0105c23:	75 0f                	jne    f0105c34 <vprintfmt+0x20a>
f0105c25:	c7 05 78 24 12 f0 06 	movl   $0x6,0xf0122478
f0105c2c:	00 00 00 
f0105c2f:	e9 19 fe ff ff       	jmp    f0105a4d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f0105c34:	c7 44 24 04 12 8a 10 	movl   $0xf0108a12,0x4(%esp)
f0105c3b:	f0 
f0105c3c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105c3f:	89 04 24             	mov    %eax,(%esp)
f0105c42:	e8 44 05 00 00       	call   f010618b <strcmp>
f0105c47:	85 c0                	test   %eax,%eax
f0105c49:	75 0f                	jne    f0105c5a <vprintfmt+0x230>
f0105c4b:	c7 05 78 24 12 f0 07 	movl   $0x7,0xf0122478
f0105c52:	00 00 00 
f0105c55:	e9 f3 fd ff ff       	jmp    f0105a4d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0105c5a:	c7 44 24 04 16 8a 10 	movl   $0xf0108a16,0x4(%esp)
f0105c61:	f0 
f0105c62:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105c65:	89 14 24             	mov    %edx,(%esp)
f0105c68:	e8 1e 05 00 00       	call   f010618b <strcmp>
f0105c6d:	83 f8 01             	cmp    $0x1,%eax
f0105c70:	19 c0                	sbb    %eax,%eax
f0105c72:	f7 d0                	not    %eax
f0105c74:	83 c0 08             	add    $0x8,%eax
f0105c77:	a3 78 24 12 f0       	mov    %eax,0xf0122478
f0105c7c:	e9 cc fd ff ff       	jmp    f0105a4d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0105c81:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c84:	8d 50 04             	lea    0x4(%eax),%edx
f0105c87:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c8a:	8b 00                	mov    (%eax),%eax
f0105c8c:	89 c2                	mov    %eax,%edx
f0105c8e:	c1 fa 1f             	sar    $0x1f,%edx
f0105c91:	31 d0                	xor    %edx,%eax
f0105c93:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105c95:	83 f8 08             	cmp    $0x8,%eax
f0105c98:	7f 0b                	jg     f0105ca5 <vprintfmt+0x27b>
f0105c9a:	8b 14 85 20 8c 10 f0 	mov    -0xfef73e0(,%eax,4),%edx
f0105ca1:	85 d2                	test   %edx,%edx
f0105ca3:	75 23                	jne    f0105cc8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0105ca5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ca9:	c7 44 24 08 1a 8a 10 	movl   $0xf0108a1a,0x8(%esp)
f0105cb0:	f0 
f0105cb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cb5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105cb8:	89 3c 24             	mov    %edi,(%esp)
f0105cbb:	e8 42 fd ff ff       	call   f0105a02 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cc0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105cc3:	e9 85 fd ff ff       	jmp    f0105a4d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105cc8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ccc:	c7 44 24 08 dd 81 10 	movl   $0xf01081dd,0x8(%esp)
f0105cd3:	f0 
f0105cd4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cd8:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105cdb:	89 3c 24             	mov    %edi,(%esp)
f0105cde:	e8 1f fd ff ff       	call   f0105a02 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ce3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105ce6:	e9 62 fd ff ff       	jmp    f0105a4d <vprintfmt+0x23>
f0105ceb:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105cee:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105cf1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105cf4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cf7:	8d 50 04             	lea    0x4(%eax),%edx
f0105cfa:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cfd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105cff:	85 f6                	test   %esi,%esi
f0105d01:	b8 fb 89 10 f0       	mov    $0xf01089fb,%eax
f0105d06:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105d09:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0105d0d:	7e 06                	jle    f0105d15 <vprintfmt+0x2eb>
f0105d0f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0105d13:	75 13                	jne    f0105d28 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105d15:	0f be 06             	movsbl (%esi),%eax
f0105d18:	83 c6 01             	add    $0x1,%esi
f0105d1b:	85 c0                	test   %eax,%eax
f0105d1d:	0f 85 94 00 00 00    	jne    f0105db7 <vprintfmt+0x38d>
f0105d23:	e9 81 00 00 00       	jmp    f0105da9 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105d28:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d2c:	89 34 24             	mov    %esi,(%esp)
f0105d2f:	e8 67 03 00 00       	call   f010609b <strnlen>
f0105d34:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105d37:	29 c2                	sub    %eax,%edx
f0105d39:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0105d3c:	85 d2                	test   %edx,%edx
f0105d3e:	7e d5                	jle    f0105d15 <vprintfmt+0x2eb>
					putch(padc, putdat);
f0105d40:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0105d44:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105d47:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0105d4a:	89 d6                	mov    %edx,%esi
f0105d4c:	89 cf                	mov    %ecx,%edi
f0105d4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d52:	89 3c 24             	mov    %edi,(%esp)
f0105d55:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105d58:	83 ee 01             	sub    $0x1,%esi
f0105d5b:	75 f1                	jne    f0105d4e <vprintfmt+0x324>
f0105d5d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105d60:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0105d63:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105d66:	eb ad                	jmp    f0105d15 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105d68:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0105d6c:	74 1b                	je     f0105d89 <vprintfmt+0x35f>
f0105d6e:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105d71:	83 fa 5e             	cmp    $0x5e,%edx
f0105d74:	76 13                	jbe    f0105d89 <vprintfmt+0x35f>
					putch('?', putdat);
f0105d76:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105d79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d7d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105d84:	ff 55 08             	call   *0x8(%ebp)
f0105d87:	eb 0d                	jmp    f0105d96 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0105d89:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105d8c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d90:	89 04 24             	mov    %eax,(%esp)
f0105d93:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105d96:	83 eb 01             	sub    $0x1,%ebx
f0105d99:	0f be 06             	movsbl (%esi),%eax
f0105d9c:	83 c6 01             	add    $0x1,%esi
f0105d9f:	85 c0                	test   %eax,%eax
f0105da1:	75 1a                	jne    f0105dbd <vprintfmt+0x393>
f0105da3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0105da6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105da9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105dac:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105db0:	7f 1c                	jg     f0105dce <vprintfmt+0x3a4>
f0105db2:	e9 96 fc ff ff       	jmp    f0105a4d <vprintfmt+0x23>
f0105db7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0105dba:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105dbd:	85 ff                	test   %edi,%edi
f0105dbf:	78 a7                	js     f0105d68 <vprintfmt+0x33e>
f0105dc1:	83 ef 01             	sub    $0x1,%edi
f0105dc4:	79 a2                	jns    f0105d68 <vprintfmt+0x33e>
f0105dc6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0105dc9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105dcc:	eb db                	jmp    f0105da9 <vprintfmt+0x37f>
f0105dce:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105dd1:	89 de                	mov    %ebx,%esi
f0105dd3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105dda:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105de1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105de3:	83 eb 01             	sub    $0x1,%ebx
f0105de6:	75 ee                	jne    f0105dd6 <vprintfmt+0x3ac>
f0105de8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105dea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105ded:	e9 5b fc ff ff       	jmp    f0105a4d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105df2:	83 f9 01             	cmp    $0x1,%ecx
f0105df5:	7e 10                	jle    f0105e07 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f0105df7:	8b 45 14             	mov    0x14(%ebp),%eax
f0105dfa:	8d 50 08             	lea    0x8(%eax),%edx
f0105dfd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e00:	8b 30                	mov    (%eax),%esi
f0105e02:	8b 78 04             	mov    0x4(%eax),%edi
f0105e05:	eb 26                	jmp    f0105e2d <vprintfmt+0x403>
	else if (lflag)
f0105e07:	85 c9                	test   %ecx,%ecx
f0105e09:	74 12                	je     f0105e1d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f0105e0b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e0e:	8d 50 04             	lea    0x4(%eax),%edx
f0105e11:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e14:	8b 30                	mov    (%eax),%esi
f0105e16:	89 f7                	mov    %esi,%edi
f0105e18:	c1 ff 1f             	sar    $0x1f,%edi
f0105e1b:	eb 10                	jmp    f0105e2d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f0105e1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e20:	8d 50 04             	lea    0x4(%eax),%edx
f0105e23:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e26:	8b 30                	mov    (%eax),%esi
f0105e28:	89 f7                	mov    %esi,%edi
f0105e2a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105e2d:	85 ff                	test   %edi,%edi
f0105e2f:	78 0e                	js     f0105e3f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105e31:	89 f0                	mov    %esi,%eax
f0105e33:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105e35:	be 0a 00 00 00       	mov    $0xa,%esi
f0105e3a:	e9 84 00 00 00       	jmp    f0105ec3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105e3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e43:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105e4a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105e4d:	89 f0                	mov    %esi,%eax
f0105e4f:	89 fa                	mov    %edi,%edx
f0105e51:	f7 d8                	neg    %eax
f0105e53:	83 d2 00             	adc    $0x0,%edx
f0105e56:	f7 da                	neg    %edx
			}
			base = 10;
f0105e58:	be 0a 00 00 00       	mov    $0xa,%esi
f0105e5d:	eb 64                	jmp    f0105ec3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105e5f:	89 ca                	mov    %ecx,%edx
f0105e61:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e64:	e8 42 fb ff ff       	call   f01059ab <getuint>
			base = 10;
f0105e69:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0105e6e:	eb 53                	jmp    f0105ec3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0105e70:	89 ca                	mov    %ecx,%edx
f0105e72:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e75:	e8 31 fb ff ff       	call   f01059ab <getuint>
    			base = 8;
f0105e7a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0105e7f:	eb 42                	jmp    f0105ec3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0105e81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e85:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105e8c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105e8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e93:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105e9a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105e9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ea0:	8d 50 04             	lea    0x4(%eax),%edx
f0105ea3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105ea6:	8b 00                	mov    (%eax),%eax
f0105ea8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105ead:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0105eb2:	eb 0f                	jmp    f0105ec3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105eb4:	89 ca                	mov    %ecx,%edx
f0105eb6:	8d 45 14             	lea    0x14(%ebp),%eax
f0105eb9:	e8 ed fa ff ff       	call   f01059ab <getuint>
			base = 16;
f0105ebe:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105ec3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0105ec7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105ecb:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105ece:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105ed2:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105ed6:	89 04 24             	mov    %eax,(%esp)
f0105ed9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105edd:	89 da                	mov    %ebx,%edx
f0105edf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ee2:	e8 e9 f9 ff ff       	call   f01058d0 <printnum>
			break;
f0105ee7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105eea:	e9 5e fb ff ff       	jmp    f0105a4d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105eef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ef3:	89 14 24             	mov    %edx,(%esp)
f0105ef6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ef9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105efc:	e9 4c fb ff ff       	jmp    f0105a4d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105f01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f05:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105f0c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105f0f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105f13:	0f 84 34 fb ff ff    	je     f0105a4d <vprintfmt+0x23>
f0105f19:	83 ee 01             	sub    $0x1,%esi
f0105f1c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105f20:	75 f7                	jne    f0105f19 <vprintfmt+0x4ef>
f0105f22:	e9 26 fb ff ff       	jmp    f0105a4d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105f27:	83 c4 5c             	add    $0x5c,%esp
f0105f2a:	5b                   	pop    %ebx
f0105f2b:	5e                   	pop    %esi
f0105f2c:	5f                   	pop    %edi
f0105f2d:	5d                   	pop    %ebp
f0105f2e:	c3                   	ret    

f0105f2f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105f2f:	55                   	push   %ebp
f0105f30:	89 e5                	mov    %esp,%ebp
f0105f32:	83 ec 28             	sub    $0x28,%esp
f0105f35:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f38:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105f3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105f3e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105f42:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105f45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105f4c:	85 c0                	test   %eax,%eax
f0105f4e:	74 30                	je     f0105f80 <vsnprintf+0x51>
f0105f50:	85 d2                	test   %edx,%edx
f0105f52:	7e 2c                	jle    f0105f80 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105f54:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f5b:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f5e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f62:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105f65:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f69:	c7 04 24 e5 59 10 f0 	movl   $0xf01059e5,(%esp)
f0105f70:	e8 b5 fa ff ff       	call   f0105a2a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105f75:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105f78:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105f7e:	eb 05                	jmp    f0105f85 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105f80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105f85:	c9                   	leave  
f0105f86:	c3                   	ret    

f0105f87 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105f87:	55                   	push   %ebp
f0105f88:	89 e5                	mov    %esp,%ebp
f0105f8a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105f8d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f94:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa5:	89 04 24             	mov    %eax,(%esp)
f0105fa8:	e8 82 ff ff ff       	call   f0105f2f <vsnprintf>
	va_end(ap);

	return rc;
}
f0105fad:	c9                   	leave  
f0105fae:	c3                   	ret    
	...

f0105fb0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105fb0:	55                   	push   %ebp
f0105fb1:	89 e5                	mov    %esp,%ebp
f0105fb3:	57                   	push   %edi
f0105fb4:	56                   	push   %esi
f0105fb5:	53                   	push   %ebx
f0105fb6:	83 ec 1c             	sub    $0x1c,%esp
f0105fb9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105fbc:	85 c0                	test   %eax,%eax
f0105fbe:	74 10                	je     f0105fd0 <readline+0x20>
		cprintf("%s", prompt);
f0105fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fc4:	c7 04 24 dd 81 10 f0 	movl   $0xf01081dd,(%esp)
f0105fcb:	e8 26 e6 ff ff       	call   f01045f6 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105fd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105fd7:	e8 de a7 ff ff       	call   f01007ba <iscons>
f0105fdc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105fde:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105fe3:	e8 c1 a7 ff ff       	call   f01007a9 <getchar>
f0105fe8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105fea:	85 c0                	test   %eax,%eax
f0105fec:	79 17                	jns    f0106005 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105fee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ff2:	c7 04 24 44 8c 10 f0 	movl   $0xf0108c44,(%esp)
f0105ff9:	e8 f8 e5 ff ff       	call   f01045f6 <cprintf>
			return NULL;
f0105ffe:	b8 00 00 00 00       	mov    $0x0,%eax
f0106003:	eb 6d                	jmp    f0106072 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106005:	83 f8 08             	cmp    $0x8,%eax
f0106008:	74 05                	je     f010600f <readline+0x5f>
f010600a:	83 f8 7f             	cmp    $0x7f,%eax
f010600d:	75 19                	jne    f0106028 <readline+0x78>
f010600f:	85 f6                	test   %esi,%esi
f0106011:	7e 15                	jle    f0106028 <readline+0x78>
			if (echoing)
f0106013:	85 ff                	test   %edi,%edi
f0106015:	74 0c                	je     f0106023 <readline+0x73>
				cputchar('\b');
f0106017:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010601e:	e8 76 a7 ff ff       	call   f0100799 <cputchar>
			i--;
f0106023:	83 ee 01             	sub    $0x1,%esi
f0106026:	eb bb                	jmp    f0105fe3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106028:	83 fb 1f             	cmp    $0x1f,%ebx
f010602b:	7e 1f                	jle    f010604c <readline+0x9c>
f010602d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106033:	7f 17                	jg     f010604c <readline+0x9c>
			if (echoing)
f0106035:	85 ff                	test   %edi,%edi
f0106037:	74 08                	je     f0106041 <readline+0x91>
				cputchar(c);
f0106039:	89 1c 24             	mov    %ebx,(%esp)
f010603c:	e8 58 a7 ff ff       	call   f0100799 <cputchar>
			buf[i++] = c;
f0106041:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f0106047:	83 c6 01             	add    $0x1,%esi
f010604a:	eb 97                	jmp    f0105fe3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010604c:	83 fb 0a             	cmp    $0xa,%ebx
f010604f:	74 05                	je     f0106056 <readline+0xa6>
f0106051:	83 fb 0d             	cmp    $0xd,%ebx
f0106054:	75 8d                	jne    f0105fe3 <readline+0x33>
			if (echoing)
f0106056:	85 ff                	test   %edi,%edi
f0106058:	74 0c                	je     f0106066 <readline+0xb6>
				cputchar('\n');
f010605a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0106061:	e8 33 a7 ff ff       	call   f0100799 <cputchar>
			buf[i] = 0;
f0106066:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f010606d:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f0106072:	83 c4 1c             	add    $0x1c,%esp
f0106075:	5b                   	pop    %ebx
f0106076:	5e                   	pop    %esi
f0106077:	5f                   	pop    %edi
f0106078:	5d                   	pop    %ebp
f0106079:	c3                   	ret    
f010607a:	00 00                	add    %al,(%eax)
f010607c:	00 00                	add    %al,(%eax)
	...

f0106080 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106080:	55                   	push   %ebp
f0106081:	89 e5                	mov    %esp,%ebp
f0106083:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106086:	b8 00 00 00 00       	mov    $0x0,%eax
f010608b:	80 3a 00             	cmpb   $0x0,(%edx)
f010608e:	74 09                	je     f0106099 <strlen+0x19>
		n++;
f0106090:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0106093:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106097:	75 f7                	jne    f0106090 <strlen+0x10>
		n++;
	return n;
}
f0106099:	5d                   	pop    %ebp
f010609a:	c3                   	ret    

f010609b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010609b:	55                   	push   %ebp
f010609c:	89 e5                	mov    %esp,%ebp
f010609e:	53                   	push   %ebx
f010609f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01060a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01060a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01060aa:	85 c9                	test   %ecx,%ecx
f01060ac:	74 1a                	je     f01060c8 <strnlen+0x2d>
f01060ae:	80 3b 00             	cmpb   $0x0,(%ebx)
f01060b1:	74 15                	je     f01060c8 <strnlen+0x2d>
f01060b3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01060b8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01060ba:	39 ca                	cmp    %ecx,%edx
f01060bc:	74 0a                	je     f01060c8 <strnlen+0x2d>
f01060be:	83 c2 01             	add    $0x1,%edx
f01060c1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01060c6:	75 f0                	jne    f01060b8 <strnlen+0x1d>
		n++;
	return n;
}
f01060c8:	5b                   	pop    %ebx
f01060c9:	5d                   	pop    %ebp
f01060ca:	c3                   	ret    

f01060cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01060cb:	55                   	push   %ebp
f01060cc:	89 e5                	mov    %esp,%ebp
f01060ce:	53                   	push   %ebx
f01060cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01060d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01060d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01060da:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01060de:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01060e1:	83 c2 01             	add    $0x1,%edx
f01060e4:	84 c9                	test   %cl,%cl
f01060e6:	75 f2                	jne    f01060da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01060e8:	5b                   	pop    %ebx
f01060e9:	5d                   	pop    %ebp
f01060ea:	c3                   	ret    

f01060eb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01060eb:	55                   	push   %ebp
f01060ec:	89 e5                	mov    %esp,%ebp
f01060ee:	53                   	push   %ebx
f01060ef:	83 ec 08             	sub    $0x8,%esp
f01060f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01060f5:	89 1c 24             	mov    %ebx,(%esp)
f01060f8:	e8 83 ff ff ff       	call   f0106080 <strlen>
	strcpy(dst + len, src);
f01060fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106100:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106104:	01 d8                	add    %ebx,%eax
f0106106:	89 04 24             	mov    %eax,(%esp)
f0106109:	e8 bd ff ff ff       	call   f01060cb <strcpy>
	return dst;
}
f010610e:	89 d8                	mov    %ebx,%eax
f0106110:	83 c4 08             	add    $0x8,%esp
f0106113:	5b                   	pop    %ebx
f0106114:	5d                   	pop    %ebp
f0106115:	c3                   	ret    

f0106116 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106116:	55                   	push   %ebp
f0106117:	89 e5                	mov    %esp,%ebp
f0106119:	56                   	push   %esi
f010611a:	53                   	push   %ebx
f010611b:	8b 45 08             	mov    0x8(%ebp),%eax
f010611e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106121:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106124:	85 f6                	test   %esi,%esi
f0106126:	74 18                	je     f0106140 <strncpy+0x2a>
f0106128:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010612d:	0f b6 1a             	movzbl (%edx),%ebx
f0106130:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106133:	80 3a 01             	cmpb   $0x1,(%edx)
f0106136:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106139:	83 c1 01             	add    $0x1,%ecx
f010613c:	39 f1                	cmp    %esi,%ecx
f010613e:	75 ed                	jne    f010612d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106140:	5b                   	pop    %ebx
f0106141:	5e                   	pop    %esi
f0106142:	5d                   	pop    %ebp
f0106143:	c3                   	ret    

f0106144 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106144:	55                   	push   %ebp
f0106145:	89 e5                	mov    %esp,%ebp
f0106147:	57                   	push   %edi
f0106148:	56                   	push   %esi
f0106149:	53                   	push   %ebx
f010614a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010614d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106150:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106153:	89 f8                	mov    %edi,%eax
f0106155:	85 f6                	test   %esi,%esi
f0106157:	74 2b                	je     f0106184 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0106159:	83 fe 01             	cmp    $0x1,%esi
f010615c:	74 23                	je     f0106181 <strlcpy+0x3d>
f010615e:	0f b6 0b             	movzbl (%ebx),%ecx
f0106161:	84 c9                	test   %cl,%cl
f0106163:	74 1c                	je     f0106181 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0106165:	83 ee 02             	sub    $0x2,%esi
f0106168:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010616d:	88 08                	mov    %cl,(%eax)
f010616f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106172:	39 f2                	cmp    %esi,%edx
f0106174:	74 0b                	je     f0106181 <strlcpy+0x3d>
f0106176:	83 c2 01             	add    $0x1,%edx
f0106179:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010617d:	84 c9                	test   %cl,%cl
f010617f:	75 ec                	jne    f010616d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0106181:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0106184:	29 f8                	sub    %edi,%eax
}
f0106186:	5b                   	pop    %ebx
f0106187:	5e                   	pop    %esi
f0106188:	5f                   	pop    %edi
f0106189:	5d                   	pop    %ebp
f010618a:	c3                   	ret    

f010618b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010618b:	55                   	push   %ebp
f010618c:	89 e5                	mov    %esp,%ebp
f010618e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106191:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106194:	0f b6 01             	movzbl (%ecx),%eax
f0106197:	84 c0                	test   %al,%al
f0106199:	74 16                	je     f01061b1 <strcmp+0x26>
f010619b:	3a 02                	cmp    (%edx),%al
f010619d:	75 12                	jne    f01061b1 <strcmp+0x26>
		p++, q++;
f010619f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01061a2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01061a6:	84 c0                	test   %al,%al
f01061a8:	74 07                	je     f01061b1 <strcmp+0x26>
f01061aa:	83 c1 01             	add    $0x1,%ecx
f01061ad:	3a 02                	cmp    (%edx),%al
f01061af:	74 ee                	je     f010619f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01061b1:	0f b6 c0             	movzbl %al,%eax
f01061b4:	0f b6 12             	movzbl (%edx),%edx
f01061b7:	29 d0                	sub    %edx,%eax
}
f01061b9:	5d                   	pop    %ebp
f01061ba:	c3                   	ret    

f01061bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01061bb:	55                   	push   %ebp
f01061bc:	89 e5                	mov    %esp,%ebp
f01061be:	53                   	push   %ebx
f01061bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01061c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01061c5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01061c8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01061cd:	85 d2                	test   %edx,%edx
f01061cf:	74 28                	je     f01061f9 <strncmp+0x3e>
f01061d1:	0f b6 01             	movzbl (%ecx),%eax
f01061d4:	84 c0                	test   %al,%al
f01061d6:	74 24                	je     f01061fc <strncmp+0x41>
f01061d8:	3a 03                	cmp    (%ebx),%al
f01061da:	75 20                	jne    f01061fc <strncmp+0x41>
f01061dc:	83 ea 01             	sub    $0x1,%edx
f01061df:	74 13                	je     f01061f4 <strncmp+0x39>
		n--, p++, q++;
f01061e1:	83 c1 01             	add    $0x1,%ecx
f01061e4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01061e7:	0f b6 01             	movzbl (%ecx),%eax
f01061ea:	84 c0                	test   %al,%al
f01061ec:	74 0e                	je     f01061fc <strncmp+0x41>
f01061ee:	3a 03                	cmp    (%ebx),%al
f01061f0:	74 ea                	je     f01061dc <strncmp+0x21>
f01061f2:	eb 08                	jmp    f01061fc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01061f4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01061f9:	5b                   	pop    %ebx
f01061fa:	5d                   	pop    %ebp
f01061fb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01061fc:	0f b6 01             	movzbl (%ecx),%eax
f01061ff:	0f b6 13             	movzbl (%ebx),%edx
f0106202:	29 d0                	sub    %edx,%eax
f0106204:	eb f3                	jmp    f01061f9 <strncmp+0x3e>

f0106206 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106206:	55                   	push   %ebp
f0106207:	89 e5                	mov    %esp,%ebp
f0106209:	8b 45 08             	mov    0x8(%ebp),%eax
f010620c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106210:	0f b6 10             	movzbl (%eax),%edx
f0106213:	84 d2                	test   %dl,%dl
f0106215:	74 1c                	je     f0106233 <strchr+0x2d>
		if (*s == c)
f0106217:	38 ca                	cmp    %cl,%dl
f0106219:	75 09                	jne    f0106224 <strchr+0x1e>
f010621b:	eb 1b                	jmp    f0106238 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010621d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0106220:	38 ca                	cmp    %cl,%dl
f0106222:	74 14                	je     f0106238 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106224:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0106228:	84 d2                	test   %dl,%dl
f010622a:	75 f1                	jne    f010621d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f010622c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106231:	eb 05                	jmp    f0106238 <strchr+0x32>
f0106233:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106238:	5d                   	pop    %ebp
f0106239:	c3                   	ret    

f010623a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010623a:	55                   	push   %ebp
f010623b:	89 e5                	mov    %esp,%ebp
f010623d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106240:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106244:	0f b6 10             	movzbl (%eax),%edx
f0106247:	84 d2                	test   %dl,%dl
f0106249:	74 14                	je     f010625f <strfind+0x25>
		if (*s == c)
f010624b:	38 ca                	cmp    %cl,%dl
f010624d:	75 06                	jne    f0106255 <strfind+0x1b>
f010624f:	eb 0e                	jmp    f010625f <strfind+0x25>
f0106251:	38 ca                	cmp    %cl,%dl
f0106253:	74 0a                	je     f010625f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106255:	83 c0 01             	add    $0x1,%eax
f0106258:	0f b6 10             	movzbl (%eax),%edx
f010625b:	84 d2                	test   %dl,%dl
f010625d:	75 f2                	jne    f0106251 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f010625f:	5d                   	pop    %ebp
f0106260:	c3                   	ret    

f0106261 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106261:	55                   	push   %ebp
f0106262:	89 e5                	mov    %esp,%ebp
f0106264:	83 ec 0c             	sub    $0xc,%esp
f0106267:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010626a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010626d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106270:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106273:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106276:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106279:	85 c9                	test   %ecx,%ecx
f010627b:	74 30                	je     f01062ad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010627d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106283:	75 25                	jne    f01062aa <memset+0x49>
f0106285:	f6 c1 03             	test   $0x3,%cl
f0106288:	75 20                	jne    f01062aa <memset+0x49>
		c &= 0xFF;
f010628a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010628d:	89 d3                	mov    %edx,%ebx
f010628f:	c1 e3 08             	shl    $0x8,%ebx
f0106292:	89 d6                	mov    %edx,%esi
f0106294:	c1 e6 18             	shl    $0x18,%esi
f0106297:	89 d0                	mov    %edx,%eax
f0106299:	c1 e0 10             	shl    $0x10,%eax
f010629c:	09 f0                	or     %esi,%eax
f010629e:	09 d0                	or     %edx,%eax
f01062a0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01062a2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01062a5:	fc                   	cld    
f01062a6:	f3 ab                	rep stos %eax,%es:(%edi)
f01062a8:	eb 03                	jmp    f01062ad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01062aa:	fc                   	cld    
f01062ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01062ad:	89 f8                	mov    %edi,%eax
f01062af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01062b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01062b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01062b8:	89 ec                	mov    %ebp,%esp
f01062ba:	5d                   	pop    %ebp
f01062bb:	c3                   	ret    

f01062bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01062bc:	55                   	push   %ebp
f01062bd:	89 e5                	mov    %esp,%ebp
f01062bf:	83 ec 08             	sub    $0x8,%esp
f01062c2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01062c5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01062c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01062cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01062d1:	39 c6                	cmp    %eax,%esi
f01062d3:	73 36                	jae    f010630b <memmove+0x4f>
f01062d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01062d8:	39 d0                	cmp    %edx,%eax
f01062da:	73 2f                	jae    f010630b <memmove+0x4f>
		s += n;
		d += n;
f01062dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062df:	f6 c2 03             	test   $0x3,%dl
f01062e2:	75 1b                	jne    f01062ff <memmove+0x43>
f01062e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01062ea:	75 13                	jne    f01062ff <memmove+0x43>
f01062ec:	f6 c1 03             	test   $0x3,%cl
f01062ef:	75 0e                	jne    f01062ff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01062f1:	83 ef 04             	sub    $0x4,%edi
f01062f4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01062f7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01062fa:	fd                   	std    
f01062fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01062fd:	eb 09                	jmp    f0106308 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01062ff:	83 ef 01             	sub    $0x1,%edi
f0106302:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106305:	fd                   	std    
f0106306:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106308:	fc                   	cld    
f0106309:	eb 20                	jmp    f010632b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010630b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106311:	75 13                	jne    f0106326 <memmove+0x6a>
f0106313:	a8 03                	test   $0x3,%al
f0106315:	75 0f                	jne    f0106326 <memmove+0x6a>
f0106317:	f6 c1 03             	test   $0x3,%cl
f010631a:	75 0a                	jne    f0106326 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010631c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010631f:	89 c7                	mov    %eax,%edi
f0106321:	fc                   	cld    
f0106322:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106324:	eb 05                	jmp    f010632b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106326:	89 c7                	mov    %eax,%edi
f0106328:	fc                   	cld    
f0106329:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010632b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010632e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106331:	89 ec                	mov    %ebp,%esp
f0106333:	5d                   	pop    %ebp
f0106334:	c3                   	ret    

f0106335 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106335:	55                   	push   %ebp
f0106336:	89 e5                	mov    %esp,%ebp
f0106338:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010633b:	8b 45 10             	mov    0x10(%ebp),%eax
f010633e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106342:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106345:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106349:	8b 45 08             	mov    0x8(%ebp),%eax
f010634c:	89 04 24             	mov    %eax,(%esp)
f010634f:	e8 68 ff ff ff       	call   f01062bc <memmove>
}
f0106354:	c9                   	leave  
f0106355:	c3                   	ret    

f0106356 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106356:	55                   	push   %ebp
f0106357:	89 e5                	mov    %esp,%ebp
f0106359:	57                   	push   %edi
f010635a:	56                   	push   %esi
f010635b:	53                   	push   %ebx
f010635c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010635f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106362:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106365:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010636a:	85 ff                	test   %edi,%edi
f010636c:	74 37                	je     f01063a5 <memcmp+0x4f>
		if (*s1 != *s2)
f010636e:	0f b6 03             	movzbl (%ebx),%eax
f0106371:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106374:	83 ef 01             	sub    $0x1,%edi
f0106377:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f010637c:	38 c8                	cmp    %cl,%al
f010637e:	74 1c                	je     f010639c <memcmp+0x46>
f0106380:	eb 10                	jmp    f0106392 <memcmp+0x3c>
f0106382:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0106387:	83 c2 01             	add    $0x1,%edx
f010638a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010638e:	38 c8                	cmp    %cl,%al
f0106390:	74 0a                	je     f010639c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0106392:	0f b6 c0             	movzbl %al,%eax
f0106395:	0f b6 c9             	movzbl %cl,%ecx
f0106398:	29 c8                	sub    %ecx,%eax
f010639a:	eb 09                	jmp    f01063a5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010639c:	39 fa                	cmp    %edi,%edx
f010639e:	75 e2                	jne    f0106382 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01063a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063a5:	5b                   	pop    %ebx
f01063a6:	5e                   	pop    %esi
f01063a7:	5f                   	pop    %edi
f01063a8:	5d                   	pop    %ebp
f01063a9:	c3                   	ret    

f01063aa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01063aa:	55                   	push   %ebp
f01063ab:	89 e5                	mov    %esp,%ebp
f01063ad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01063b0:	89 c2                	mov    %eax,%edx
f01063b2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01063b5:	39 d0                	cmp    %edx,%eax
f01063b7:	73 19                	jae    f01063d2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f01063b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01063bd:	38 08                	cmp    %cl,(%eax)
f01063bf:	75 06                	jne    f01063c7 <memfind+0x1d>
f01063c1:	eb 0f                	jmp    f01063d2 <memfind+0x28>
f01063c3:	38 08                	cmp    %cl,(%eax)
f01063c5:	74 0b                	je     f01063d2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01063c7:	83 c0 01             	add    $0x1,%eax
f01063ca:	39 d0                	cmp    %edx,%eax
f01063cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063d0:	75 f1                	jne    f01063c3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01063d2:	5d                   	pop    %ebp
f01063d3:	c3                   	ret    

f01063d4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01063d4:	55                   	push   %ebp
f01063d5:	89 e5                	mov    %esp,%ebp
f01063d7:	57                   	push   %edi
f01063d8:	56                   	push   %esi
f01063d9:	53                   	push   %ebx
f01063da:	8b 55 08             	mov    0x8(%ebp),%edx
f01063dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01063e0:	0f b6 02             	movzbl (%edx),%eax
f01063e3:	3c 20                	cmp    $0x20,%al
f01063e5:	74 04                	je     f01063eb <strtol+0x17>
f01063e7:	3c 09                	cmp    $0x9,%al
f01063e9:	75 0e                	jne    f01063f9 <strtol+0x25>
		s++;
f01063eb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01063ee:	0f b6 02             	movzbl (%edx),%eax
f01063f1:	3c 20                	cmp    $0x20,%al
f01063f3:	74 f6                	je     f01063eb <strtol+0x17>
f01063f5:	3c 09                	cmp    $0x9,%al
f01063f7:	74 f2                	je     f01063eb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01063f9:	3c 2b                	cmp    $0x2b,%al
f01063fb:	75 0a                	jne    f0106407 <strtol+0x33>
		s++;
f01063fd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106400:	bf 00 00 00 00       	mov    $0x0,%edi
f0106405:	eb 10                	jmp    f0106417 <strtol+0x43>
f0106407:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010640c:	3c 2d                	cmp    $0x2d,%al
f010640e:	75 07                	jne    f0106417 <strtol+0x43>
		s++, neg = 1;
f0106410:	83 c2 01             	add    $0x1,%edx
f0106413:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106417:	85 db                	test   %ebx,%ebx
f0106419:	0f 94 c0             	sete   %al
f010641c:	74 05                	je     f0106423 <strtol+0x4f>
f010641e:	83 fb 10             	cmp    $0x10,%ebx
f0106421:	75 15                	jne    f0106438 <strtol+0x64>
f0106423:	80 3a 30             	cmpb   $0x30,(%edx)
f0106426:	75 10                	jne    f0106438 <strtol+0x64>
f0106428:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010642c:	75 0a                	jne    f0106438 <strtol+0x64>
		s += 2, base = 16;
f010642e:	83 c2 02             	add    $0x2,%edx
f0106431:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106436:	eb 13                	jmp    f010644b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0106438:	84 c0                	test   %al,%al
f010643a:	74 0f                	je     f010644b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010643c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106441:	80 3a 30             	cmpb   $0x30,(%edx)
f0106444:	75 05                	jne    f010644b <strtol+0x77>
		s++, base = 8;
f0106446:	83 c2 01             	add    $0x1,%edx
f0106449:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010644b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106450:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106452:	0f b6 0a             	movzbl (%edx),%ecx
f0106455:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106458:	80 fb 09             	cmp    $0x9,%bl
f010645b:	77 08                	ja     f0106465 <strtol+0x91>
			dig = *s - '0';
f010645d:	0f be c9             	movsbl %cl,%ecx
f0106460:	83 e9 30             	sub    $0x30,%ecx
f0106463:	eb 1e                	jmp    f0106483 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0106465:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0106468:	80 fb 19             	cmp    $0x19,%bl
f010646b:	77 08                	ja     f0106475 <strtol+0xa1>
			dig = *s - 'a' + 10;
f010646d:	0f be c9             	movsbl %cl,%ecx
f0106470:	83 e9 57             	sub    $0x57,%ecx
f0106473:	eb 0e                	jmp    f0106483 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0106475:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0106478:	80 fb 19             	cmp    $0x19,%bl
f010647b:	77 14                	ja     f0106491 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010647d:	0f be c9             	movsbl %cl,%ecx
f0106480:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106483:	39 f1                	cmp    %esi,%ecx
f0106485:	7d 0e                	jge    f0106495 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0106487:	83 c2 01             	add    $0x1,%edx
f010648a:	0f af c6             	imul   %esi,%eax
f010648d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010648f:	eb c1                	jmp    f0106452 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0106491:	89 c1                	mov    %eax,%ecx
f0106493:	eb 02                	jmp    f0106497 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106495:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0106497:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010649b:	74 05                	je     f01064a2 <strtol+0xce>
		*endptr = (char *) s;
f010649d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01064a0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01064a2:	89 ca                	mov    %ecx,%edx
f01064a4:	f7 da                	neg    %edx
f01064a6:	85 ff                	test   %edi,%edi
f01064a8:	0f 45 c2             	cmovne %edx,%eax
}
f01064ab:	5b                   	pop    %ebx
f01064ac:	5e                   	pop    %esi
f01064ad:	5f                   	pop    %edi
f01064ae:	5d                   	pop    %ebp
f01064af:	c3                   	ret    

f01064b0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01064b0:	fa                   	cli    

	xorw    %ax, %ax
f01064b1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01064b3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01064b5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01064b7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01064b9:	0f 01 16             	lgdtl  (%esi)
f01064bc:	74 70                	je     f010652e <mpentry_end+0x4>
	movl    %cr0, %eax
f01064be:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01064c1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01064c5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01064c8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01064ce:	08 00                	or     %al,(%eax)

f01064d0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01064d0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01064d4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01064d6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01064d8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01064da:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01064de:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01064e0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01064e2:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01064e7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01064ea:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01064ed:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01064f2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01064f5:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01064fb:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106500:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106505:	ff d0                	call   *%eax

f0106507 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106507:	eb fe                	jmp    f0106507 <spin>
f0106509:	8d 76 00             	lea    0x0(%esi),%esi

f010650c <gdt>:
	...
f0106514:	ff                   	(bad)  
f0106515:	ff 00                	incl   (%eax)
f0106517:	00 00                	add    %al,(%eax)
f0106519:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106520:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106524 <gdtdesc>:
f0106524:	17                   	pop    %ss
f0106525:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010652a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010652a:	90                   	nop
f010652b:	00 00                	add    %al,(%eax)
f010652d:	00 00                	add    %al,(%eax)
	...

f0106530 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106530:	55                   	push   %ebp
f0106531:	89 e5                	mov    %esp,%ebp
f0106533:	56                   	push   %esi
f0106534:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106535:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010653a:	85 d2                	test   %edx,%edx
f010653c:	7e 12                	jle    f0106550 <sum+0x20>
f010653e:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0106543:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106547:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106549:	83 c1 01             	add    $0x1,%ecx
f010654c:	39 d1                	cmp    %edx,%ecx
f010654e:	75 f3                	jne    f0106543 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106550:	89 d8                	mov    %ebx,%eax
f0106552:	5b                   	pop    %ebx
f0106553:	5e                   	pop    %esi
f0106554:	5d                   	pop    %ebp
f0106555:	c3                   	ret    

f0106556 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106556:	55                   	push   %ebp
f0106557:	89 e5                	mov    %esp,%ebp
f0106559:	56                   	push   %esi
f010655a:	53                   	push   %ebx
f010655b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010655e:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0106564:	89 c3                	mov    %eax,%ebx
f0106566:	c1 eb 0c             	shr    $0xc,%ebx
f0106569:	39 cb                	cmp    %ecx,%ebx
f010656b:	72 20                	jb     f010658d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010656d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106571:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0106578:	f0 
f0106579:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106580:	00 
f0106581:	c7 04 24 e1 8d 10 f0 	movl   $0xf0108de1,(%esp)
f0106588:	e8 b3 9a ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010658d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106590:	89 f2                	mov    %esi,%edx
f0106592:	c1 ea 0c             	shr    $0xc,%edx
f0106595:	39 d1                	cmp    %edx,%ecx
f0106597:	77 20                	ja     f01065b9 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106599:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010659d:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01065a4:	f0 
f01065a5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01065ac:	00 
f01065ad:	c7 04 24 e1 8d 10 f0 	movl   $0xf0108de1,(%esp)
f01065b4:	e8 87 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01065b9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01065bf:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01065c5:	39 f3                	cmp    %esi,%ebx
f01065c7:	73 3a                	jae    f0106603 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01065c9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01065d0:	00 
f01065d1:	c7 44 24 04 f1 8d 10 	movl   $0xf0108df1,0x4(%esp)
f01065d8:	f0 
f01065d9:	89 1c 24             	mov    %ebx,(%esp)
f01065dc:	e8 75 fd ff ff       	call   f0106356 <memcmp>
f01065e1:	85 c0                	test   %eax,%eax
f01065e3:	75 10                	jne    f01065f5 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f01065e5:	ba 10 00 00 00       	mov    $0x10,%edx
f01065ea:	89 d8                	mov    %ebx,%eax
f01065ec:	e8 3f ff ff ff       	call   f0106530 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01065f1:	84 c0                	test   %al,%al
f01065f3:	74 13                	je     f0106608 <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01065f5:	83 c3 10             	add    $0x10,%ebx
f01065f8:	39 f3                	cmp    %esi,%ebx
f01065fa:	72 cd                	jb     f01065c9 <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01065fc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106601:	eb 05                	jmp    f0106608 <mpsearch1+0xb2>
f0106603:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106608:	89 d8                	mov    %ebx,%eax
f010660a:	83 c4 10             	add    $0x10,%esp
f010660d:	5b                   	pop    %ebx
f010660e:	5e                   	pop    %esi
f010660f:	5d                   	pop    %ebp
f0106610:	c3                   	ret    

f0106611 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106611:	55                   	push   %ebp
f0106612:	89 e5                	mov    %esp,%ebp
f0106614:	57                   	push   %edi
f0106615:	56                   	push   %esi
f0106616:	53                   	push   %ebx
f0106617:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010661a:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f0106621:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106624:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f010662b:	75 24                	jne    f0106651 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010662d:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106634:	00 
f0106635:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f010663c:	f0 
f010663d:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106644:	00 
f0106645:	c7 04 24 e1 8d 10 f0 	movl   $0xf0108de1,(%esp)
f010664c:	e8 ef 99 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106651:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106658:	85 c0                	test   %eax,%eax
f010665a:	74 16                	je     f0106672 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010665c:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010665f:	ba 00 04 00 00       	mov    $0x400,%edx
f0106664:	e8 ed fe ff ff       	call   f0106556 <mpsearch1>
f0106669:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010666c:	85 c0                	test   %eax,%eax
f010666e:	75 3c                	jne    f01066ac <mp_init+0x9b>
f0106670:	eb 20                	jmp    f0106692 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106672:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106679:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010667c:	2d 00 04 00 00       	sub    $0x400,%eax
f0106681:	ba 00 04 00 00       	mov    $0x400,%edx
f0106686:	e8 cb fe ff ff       	call   f0106556 <mpsearch1>
f010668b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010668e:	85 c0                	test   %eax,%eax
f0106690:	75 1a                	jne    f01066ac <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106692:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106697:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010669c:	e8 b5 fe ff ff       	call   f0106556 <mpsearch1>
f01066a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01066a4:	85 c0                	test   %eax,%eax
f01066a6:	0f 84 24 02 00 00    	je     f01068d0 <mp_init+0x2bf>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01066ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01066af:	8b 78 04             	mov    0x4(%eax),%edi
f01066b2:	85 ff                	test   %edi,%edi
f01066b4:	74 06                	je     f01066bc <mp_init+0xab>
f01066b6:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01066ba:	74 11                	je     f01066cd <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01066bc:	c7 04 24 54 8c 10 f0 	movl   $0xf0108c54,(%esp)
f01066c3:	e8 2e df ff ff       	call   f01045f6 <cprintf>
f01066c8:	e9 03 02 00 00       	jmp    f01068d0 <mp_init+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01066cd:	89 f8                	mov    %edi,%eax
f01066cf:	c1 e8 0c             	shr    $0xc,%eax
f01066d2:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01066d8:	72 20                	jb     f01066fa <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01066da:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01066de:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f01066e5:	f0 
f01066e6:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01066ed:	00 
f01066ee:	c7 04 24 e1 8d 10 f0 	movl   $0xf0108de1,(%esp)
f01066f5:	e8 46 99 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01066fa:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106700:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106707:	00 
f0106708:	c7 44 24 04 f6 8d 10 	movl   $0xf0108df6,0x4(%esp)
f010670f:	f0 
f0106710:	89 3c 24             	mov    %edi,(%esp)
f0106713:	e8 3e fc ff ff       	call   f0106356 <memcmp>
f0106718:	85 c0                	test   %eax,%eax
f010671a:	74 11                	je     f010672d <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010671c:	c7 04 24 84 8c 10 f0 	movl   $0xf0108c84,(%esp)
f0106723:	e8 ce de ff ff       	call   f01045f6 <cprintf>
f0106728:	e9 a3 01 00 00       	jmp    f01068d0 <mp_init+0x2bf>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010672d:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106731:	0f b7 d3             	movzwl %bx,%edx
f0106734:	89 f8                	mov    %edi,%eax
f0106736:	e8 f5 fd ff ff       	call   f0106530 <sum>
f010673b:	84 c0                	test   %al,%al
f010673d:	74 11                	je     f0106750 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010673f:	c7 04 24 b8 8c 10 f0 	movl   $0xf0108cb8,(%esp)
f0106746:	e8 ab de ff ff       	call   f01045f6 <cprintf>
f010674b:	e9 80 01 00 00       	jmp    f01068d0 <mp_init+0x2bf>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106750:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106754:	3c 01                	cmp    $0x1,%al
f0106756:	74 1c                	je     f0106774 <mp_init+0x163>
f0106758:	3c 04                	cmp    $0x4,%al
f010675a:	74 18                	je     f0106774 <mp_init+0x163>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010675c:	0f b6 c0             	movzbl %al,%eax
f010675f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106763:	c7 04 24 dc 8c 10 f0 	movl   $0xf0108cdc,(%esp)
f010676a:	e8 87 de ff ff       	call   f01045f6 <cprintf>
f010676f:	e9 5c 01 00 00       	jmp    f01068d0 <mp_init+0x2bf>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106774:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0106778:	0f b7 db             	movzwl %bx,%ebx
f010677b:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010677e:	e8 ad fd ff ff       	call   f0106530 <sum>
f0106783:	3a 47 2a             	cmp    0x2a(%edi),%al
f0106786:	74 11                	je     f0106799 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106788:	c7 04 24 fc 8c 10 f0 	movl   $0xf0108cfc,(%esp)
f010678f:	e8 62 de ff ff       	call   f01045f6 <cprintf>
f0106794:	e9 37 01 00 00       	jmp    f01068d0 <mp_init+0x2bf>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106799:	85 ff                	test   %edi,%edi
f010679b:	0f 84 2f 01 00 00    	je     f01068d0 <mp_init+0x2bf>
		return;
	ismp = 1;
f01067a1:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f01067a8:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01067ab:	8b 47 24             	mov    0x24(%edi),%eax
f01067ae:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01067b3:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f01067b8:	0f 84 97 00 00 00    	je     f0106855 <mp_init+0x244>
f01067be:	8d 77 2c             	lea    0x2c(%edi),%esi
f01067c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f01067c6:	0f b6 06             	movzbl (%esi),%eax
f01067c9:	84 c0                	test   %al,%al
f01067cb:	74 06                	je     f01067d3 <mp_init+0x1c2>
f01067cd:	3c 04                	cmp    $0x4,%al
f01067cf:	77 54                	ja     f0106825 <mp_init+0x214>
f01067d1:	eb 4d                	jmp    f0106820 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01067d3:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01067d7:	74 11                	je     f01067ea <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f01067d9:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01067e0:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01067e5:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f01067ea:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f01067ef:	83 f8 07             	cmp    $0x7,%eax
f01067f2:	7f 13                	jg     f0106807 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f01067f4:	6b d0 74             	imul   $0x74,%eax,%edx
f01067f7:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f01067fd:	83 c0 01             	add    $0x1,%eax
f0106800:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f0106805:	eb 14                	jmp    f010681b <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106807:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010680b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010680f:	c7 04 24 2c 8d 10 f0 	movl   $0xf0108d2c,(%esp)
f0106816:	e8 db dd ff ff       	call   f01045f6 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010681b:	83 c6 14             	add    $0x14,%esi
			continue;
f010681e:	eb 26                	jmp    f0106846 <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106820:	83 c6 08             	add    $0x8,%esi
			continue;
f0106823:	eb 21                	jmp    f0106846 <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106825:	0f b6 c0             	movzbl %al,%eax
f0106828:	89 44 24 04          	mov    %eax,0x4(%esp)
f010682c:	c7 04 24 54 8d 10 f0 	movl   $0xf0108d54,(%esp)
f0106833:	e8 be dd ff ff       	call   f01045f6 <cprintf>
			ismp = 0;
f0106838:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f010683f:	00 00 00 
			i = conf->entry;
f0106842:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106846:	83 c3 01             	add    $0x1,%ebx
f0106849:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f010684d:	39 d8                	cmp    %ebx,%eax
f010684f:	0f 87 71 ff ff ff    	ja     f01067c6 <mp_init+0x1b5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106855:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f010685a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106861:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f0106868:	75 22                	jne    f010688c <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010686a:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f0106871:	00 00 00 
		lapicaddr = 0;
f0106874:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f010687b:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010687e:	c7 04 24 74 8d 10 f0 	movl   $0xf0108d74,(%esp)
f0106885:	e8 6c dd ff ff       	call   f01045f6 <cprintf>
		return;
f010688a:	eb 44                	jmp    f01068d0 <mp_init+0x2bf>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010688c:	8b 15 c4 c3 22 f0    	mov    0xf022c3c4,%edx
f0106892:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106896:	0f b6 00             	movzbl (%eax),%eax
f0106899:	89 44 24 04          	mov    %eax,0x4(%esp)
f010689d:	c7 04 24 fb 8d 10 f0 	movl   $0xf0108dfb,(%esp)
f01068a4:	e8 4d dd ff ff       	call   f01045f6 <cprintf>

	if (mp->imcrp) {
f01068a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01068ac:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01068b0:	74 1e                	je     f01068d0 <mp_init+0x2bf>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01068b2:	c7 04 24 a0 8d 10 f0 	movl   $0xf0108da0,(%esp)
f01068b9:	e8 38 dd ff ff       	call   f01045f6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01068be:	ba 22 00 00 00       	mov    $0x22,%edx
f01068c3:	b8 70 00 00 00       	mov    $0x70,%eax
f01068c8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01068c9:	b2 23                	mov    $0x23,%dl
f01068cb:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01068cc:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01068cf:	ee                   	out    %al,(%dx)
	}
}
f01068d0:	83 c4 2c             	add    $0x2c,%esp
f01068d3:	5b                   	pop    %ebx
f01068d4:	5e                   	pop    %esi
f01068d5:	5f                   	pop    %edi
f01068d6:	5d                   	pop    %ebp
f01068d7:	c3                   	ret    

f01068d8 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01068d8:	55                   	push   %ebp
f01068d9:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01068db:	c1 e0 02             	shl    $0x2,%eax
f01068de:	03 05 04 d0 26 f0    	add    0xf026d004,%eax
f01068e4:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01068e6:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01068eb:	8b 40 20             	mov    0x20(%eax),%eax
}
f01068ee:	5d                   	pop    %ebp
f01068ef:	c3                   	ret    

f01068f0 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01068f0:	55                   	push   %ebp
f01068f1:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01068f3:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
		return lapic[ID] >> 24;
	return 0;
f01068f9:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f01068fe:	85 d2                	test   %edx,%edx
f0106900:	74 06                	je     f0106908 <cpunum+0x18>
		return lapic[ID] >> 24;
f0106902:	8b 42 20             	mov    0x20(%edx),%eax
f0106905:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106908:	5d                   	pop    %ebp
f0106909:	c3                   	ret    

f010690a <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010690a:	55                   	push   %ebp
f010690b:	89 e5                	mov    %esp,%ebp
f010690d:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106910:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f0106915:	85 c0                	test   %eax,%eax
f0106917:	0f 84 1c 01 00 00    	je     f0106a39 <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010691d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106924:	00 
f0106925:	89 04 24             	mov    %eax,(%esp)
f0106928:	e8 c3 b1 ff ff       	call   f0101af0 <mmio_map_region>
f010692d:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106932:	ba 27 01 00 00       	mov    $0x127,%edx
f0106937:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010693c:	e8 97 ff ff ff       	call   f01068d8 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106941:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106946:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010694b:	e8 88 ff ff ff       	call   f01068d8 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106950:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106955:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010695a:	e8 79 ff ff ff       	call   f01068d8 <lapicw>
	lapicw(TICR, 10000000); 
f010695f:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106964:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106969:	e8 6a ff ff ff       	call   f01068d8 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010696e:	e8 7d ff ff ff       	call   f01068f0 <cpunum>
f0106973:	6b c0 74             	imul   $0x74,%eax,%eax
f0106976:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010697b:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f0106981:	74 0f                	je     f0106992 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106983:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106988:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010698d:	e8 46 ff ff ff       	call   f01068d8 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106992:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106997:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010699c:	e8 37 ff ff ff       	call   f01068d8 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01069a1:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01069a6:	8b 40 30             	mov    0x30(%eax),%eax
f01069a9:	c1 e8 10             	shr    $0x10,%eax
f01069ac:	3c 03                	cmp    $0x3,%al
f01069ae:	76 0f                	jbe    f01069bf <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f01069b0:	ba 00 00 01 00       	mov    $0x10000,%edx
f01069b5:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01069ba:	e8 19 ff ff ff       	call   f01068d8 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01069bf:	ba 33 00 00 00       	mov    $0x33,%edx
f01069c4:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01069c9:	e8 0a ff ff ff       	call   f01068d8 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01069ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01069d3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01069d8:	e8 fb fe ff ff       	call   f01068d8 <lapicw>
	lapicw(ESR, 0);
f01069dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01069e2:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01069e7:	e8 ec fe ff ff       	call   f01068d8 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01069ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01069f1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01069f6:	e8 dd fe ff ff       	call   f01068d8 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01069fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a00:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106a05:	e8 ce fe ff ff       	call   f01068d8 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106a0a:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106a0f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106a14:	e8 bf fe ff ff       	call   f01068d8 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106a19:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0106a1f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106a25:	f6 c4 10             	test   $0x10,%ah
f0106a28:	75 f5                	jne    f0106a1f <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106a2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a2f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106a34:	e8 9f fe ff ff       	call   f01068d8 <lapicw>
}
f0106a39:	c9                   	leave  
f0106a3a:	c3                   	ret    

f0106a3b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106a3b:	55                   	push   %ebp
f0106a3c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106a3e:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f0106a45:	74 0f                	je     f0106a56 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0106a47:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a4c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106a51:	e8 82 fe ff ff       	call   f01068d8 <lapicw>
}
f0106a56:	5d                   	pop    %ebp
f0106a57:	c3                   	ret    

f0106a58 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106a58:	55                   	push   %ebp
f0106a59:	89 e5                	mov    %esp,%ebp
f0106a5b:	56                   	push   %esi
f0106a5c:	53                   	push   %ebx
f0106a5d:	83 ec 10             	sub    $0x10,%esp
f0106a60:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106a63:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0106a67:	ba 70 00 00 00       	mov    $0x70,%edx
f0106a6c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106a71:	ee                   	out    %al,(%dx)
f0106a72:	b2 71                	mov    $0x71,%dl
f0106a74:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106a79:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106a7a:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0106a81:	75 24                	jne    f0106aa7 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106a83:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106a8a:	00 
f0106a8b:	c7 44 24 08 88 70 10 	movl   $0xf0107088,0x8(%esp)
f0106a92:	f0 
f0106a93:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106a9a:	00 
f0106a9b:	c7 04 24 18 8e 10 f0 	movl   $0xf0108e18,(%esp)
f0106aa2:	e8 99 95 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106aa7:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106aae:	00 00 
	wrv[1] = addr >> 4;
f0106ab0:	89 f0                	mov    %esi,%eax
f0106ab2:	c1 e8 04             	shr    $0x4,%eax
f0106ab5:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106abb:	c1 e3 18             	shl    $0x18,%ebx
f0106abe:	89 da                	mov    %ebx,%edx
f0106ac0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106ac5:	e8 0e fe ff ff       	call   f01068d8 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106aca:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106acf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ad4:	e8 ff fd ff ff       	call   f01068d8 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106ad9:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106ade:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ae3:	e8 f0 fd ff ff       	call   f01068d8 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ae8:	c1 ee 0c             	shr    $0xc,%esi
f0106aeb:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106af1:	89 da                	mov    %ebx,%edx
f0106af3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106af8:	e8 db fd ff ff       	call   f01068d8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106afd:	89 f2                	mov    %esi,%edx
f0106aff:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b04:	e8 cf fd ff ff       	call   f01068d8 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106b09:	89 da                	mov    %ebx,%edx
f0106b0b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106b10:	e8 c3 fd ff ff       	call   f01068d8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106b15:	89 f2                	mov    %esi,%edx
f0106b17:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b1c:	e8 b7 fd ff ff       	call   f01068d8 <lapicw>
		microdelay(200);
	}
}
f0106b21:	83 c4 10             	add    $0x10,%esp
f0106b24:	5b                   	pop    %ebx
f0106b25:	5e                   	pop    %esi
f0106b26:	5d                   	pop    %ebp
f0106b27:	c3                   	ret    

f0106b28 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106b28:	55                   	push   %ebp
f0106b29:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106b2b:	8b 55 08             	mov    0x8(%ebp),%edx
f0106b2e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106b34:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b39:	e8 9a fd ff ff       	call   f01068d8 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106b3e:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0106b44:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106b4a:	f6 c4 10             	test   $0x10,%ah
f0106b4d:	75 f5                	jne    f0106b44 <lapic_ipi+0x1c>
		;
}
f0106b4f:	5d                   	pop    %ebp
f0106b50:	c3                   	ret    
f0106b51:	00 00                	add    %al,(%eax)
	...

f0106b54 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106b54:	55                   	push   %ebp
f0106b55:	89 e5                	mov    %esp,%ebp
f0106b57:	53                   	push   %ebx
f0106b58:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106b5b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106b60:	83 38 00             	cmpl   $0x0,(%eax)
f0106b63:	74 18                	je     f0106b7d <holding+0x29>
f0106b65:	8b 58 08             	mov    0x8(%eax),%ebx
f0106b68:	e8 83 fd ff ff       	call   f01068f0 <cpunum>
f0106b6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106b70:	05 20 c0 22 f0       	add    $0xf022c020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106b75:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106b77:	0f 94 c2             	sete   %dl
f0106b7a:	0f b6 d2             	movzbl %dl,%edx
}
f0106b7d:	89 d0                	mov    %edx,%eax
f0106b7f:	83 c4 04             	add    $0x4,%esp
f0106b82:	5b                   	pop    %ebx
f0106b83:	5d                   	pop    %ebp
f0106b84:	c3                   	ret    

f0106b85 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106b85:	55                   	push   %ebp
f0106b86:	89 e5                	mov    %esp,%ebp
f0106b88:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106b8b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106b91:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b94:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106b97:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106b9e:	5d                   	pop    %ebp
f0106b9f:	c3                   	ret    

f0106ba0 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106ba0:	55                   	push   %ebp
f0106ba1:	89 e5                	mov    %esp,%ebp
f0106ba3:	53                   	push   %ebx
f0106ba4:	83 ec 24             	sub    $0x24,%esp
f0106ba7:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106baa:	89 d8                	mov    %ebx,%eax
f0106bac:	e8 a3 ff ff ff       	call   f0106b54 <holding>
f0106bb1:	85 c0                	test   %eax,%eax
f0106bb3:	75 12                	jne    f0106bc7 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106bb5:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106bb7:	b0 01                	mov    $0x1,%al
f0106bb9:	f0 87 03             	lock xchg %eax,(%ebx)
f0106bbc:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106bc1:	85 c0                	test   %eax,%eax
f0106bc3:	75 2e                	jne    f0106bf3 <spin_lock+0x53>
f0106bc5:	eb 37                	jmp    f0106bfe <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106bc7:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106bca:	e8 21 fd ff ff       	call   f01068f0 <cpunum>
f0106bcf:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106bd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106bd7:	c7 44 24 08 28 8e 10 	movl   $0xf0108e28,0x8(%esp)
f0106bde:	f0 
f0106bdf:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106be6:	00 
f0106be7:	c7 04 24 8c 8e 10 f0 	movl   $0xf0108e8c,(%esp)
f0106bee:	e8 4d 94 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106bf3:	f3 90                	pause  
f0106bf5:	89 c8                	mov    %ecx,%eax
f0106bf7:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106bfa:	85 c0                	test   %eax,%eax
f0106bfc:	75 f5                	jne    f0106bf3 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106bfe:	e8 ed fc ff ff       	call   f01068f0 <cpunum>
f0106c03:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c06:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106c0b:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106c0e:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106c11:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106c13:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106c18:	77 34                	ja     f0106c4e <spin_lock+0xae>
f0106c1a:	eb 2b                	jmp    f0106c47 <spin_lock+0xa7>
f0106c1c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106c22:	76 12                	jbe    f0106c36 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106c24:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106c27:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106c2a:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106c2c:	83 c0 01             	add    $0x1,%eax
f0106c2f:	83 f8 0a             	cmp    $0xa,%eax
f0106c32:	75 e8                	jne    f0106c1c <spin_lock+0x7c>
f0106c34:	eb 27                	jmp    f0106c5d <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106c36:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106c3d:	83 c0 01             	add    $0x1,%eax
f0106c40:	83 f8 09             	cmp    $0x9,%eax
f0106c43:	7e f1                	jle    f0106c36 <spin_lock+0x96>
f0106c45:	eb 16                	jmp    f0106c5d <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106c47:	b8 00 00 00 00       	mov    $0x0,%eax
f0106c4c:	eb e8                	jmp    f0106c36 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106c4e:	8b 50 04             	mov    0x4(%eax),%edx
f0106c51:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106c54:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106c56:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c5b:	eb bf                	jmp    f0106c1c <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106c5d:	83 c4 24             	add    $0x24,%esp
f0106c60:	5b                   	pop    %ebx
f0106c61:	5d                   	pop    %ebp
f0106c62:	c3                   	ret    

f0106c63 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106c63:	55                   	push   %ebp
f0106c64:	89 e5                	mov    %esp,%ebp
f0106c66:	83 ec 78             	sub    $0x78,%esp
f0106c69:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106c6c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106c6f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106c72:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106c75:	89 d8                	mov    %ebx,%eax
f0106c77:	e8 d8 fe ff ff       	call   f0106b54 <holding>
f0106c7c:	85 c0                	test   %eax,%eax
f0106c7e:	0f 85 d4 00 00 00    	jne    f0106d58 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106c84:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106c8b:	00 
f0106c8c:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c93:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106c96:	89 04 24             	mov    %eax,(%esp)
f0106c99:	e8 1e f6 ff ff       	call   f01062bc <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106c9e:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106ca1:	0f b6 30             	movzbl (%eax),%esi
f0106ca4:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106ca7:	e8 44 fc ff ff       	call   f01068f0 <cpunum>
f0106cac:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106cb0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cb8:	c7 04 24 54 8e 10 f0 	movl   $0xf0108e54,(%esp)
f0106cbf:	e8 32 d9 ff ff       	call   f01045f6 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106cc4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106cc7:	85 c0                	test   %eax,%eax
f0106cc9:	74 71                	je     f0106d3c <spin_unlock+0xd9>
f0106ccb:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106cce:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106cd1:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106cd4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106cd8:	89 04 24             	mov    %eax,(%esp)
f0106cdb:	e8 c6 e8 ff ff       	call   f01055a6 <debuginfo_eip>
f0106ce0:	85 c0                	test   %eax,%eax
f0106ce2:	78 39                	js     f0106d1d <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106ce4:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106ce6:	89 c2                	mov    %eax,%edx
f0106ce8:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106ceb:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106cef:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106cf2:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106cf6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106cf9:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106cfd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106d00:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106d04:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106d07:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d0f:	c7 04 24 9c 8e 10 f0 	movl   $0xf0108e9c,(%esp)
f0106d16:	e8 db d8 ff ff       	call   f01045f6 <cprintf>
f0106d1b:	eb 12                	jmp    f0106d2f <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106d1d:	8b 03                	mov    (%ebx),%eax
f0106d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d23:	c7 04 24 b3 8e 10 f0 	movl   $0xf0108eb3,(%esp)
f0106d2a:	e8 c7 d8 ff ff       	call   f01045f6 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106d2f:	39 fb                	cmp    %edi,%ebx
f0106d31:	74 09                	je     f0106d3c <spin_unlock+0xd9>
f0106d33:	83 c3 04             	add    $0x4,%ebx
f0106d36:	8b 03                	mov    (%ebx),%eax
f0106d38:	85 c0                	test   %eax,%eax
f0106d3a:	75 98                	jne    f0106cd4 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106d3c:	c7 44 24 08 bb 8e 10 	movl   $0xf0108ebb,0x8(%esp)
f0106d43:	f0 
f0106d44:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106d4b:	00 
f0106d4c:	c7 04 24 8c 8e 10 f0 	movl   $0xf0108e8c,(%esp)
f0106d53:	e8 e8 92 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106d58:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106d5f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106d66:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d6b:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106d6e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106d71:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106d74:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106d77:	89 ec                	mov    %ebp,%esp
f0106d79:	5d                   	pop    %ebp
f0106d7a:	c3                   	ret    
f0106d7b:	00 00                	add    %al,(%eax)
f0106d7d:	00 00                	add    %al,(%eax)
	...

f0106d80 <__udivdi3>:
f0106d80:	83 ec 1c             	sub    $0x1c,%esp
f0106d83:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106d87:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0106d8b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106d8f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106d93:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106d97:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106d9b:	85 ff                	test   %edi,%edi
f0106d9d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106da1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106da5:	89 cd                	mov    %ecx,%ebp
f0106da7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106dab:	75 33                	jne    f0106de0 <__udivdi3+0x60>
f0106dad:	39 f1                	cmp    %esi,%ecx
f0106daf:	77 57                	ja     f0106e08 <__udivdi3+0x88>
f0106db1:	85 c9                	test   %ecx,%ecx
f0106db3:	75 0b                	jne    f0106dc0 <__udivdi3+0x40>
f0106db5:	b8 01 00 00 00       	mov    $0x1,%eax
f0106dba:	31 d2                	xor    %edx,%edx
f0106dbc:	f7 f1                	div    %ecx
f0106dbe:	89 c1                	mov    %eax,%ecx
f0106dc0:	89 f0                	mov    %esi,%eax
f0106dc2:	31 d2                	xor    %edx,%edx
f0106dc4:	f7 f1                	div    %ecx
f0106dc6:	89 c6                	mov    %eax,%esi
f0106dc8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106dcc:	f7 f1                	div    %ecx
f0106dce:	89 f2                	mov    %esi,%edx
f0106dd0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106dd4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106dd8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106ddc:	83 c4 1c             	add    $0x1c,%esp
f0106ddf:	c3                   	ret    
f0106de0:	31 d2                	xor    %edx,%edx
f0106de2:	31 c0                	xor    %eax,%eax
f0106de4:	39 f7                	cmp    %esi,%edi
f0106de6:	77 e8                	ja     f0106dd0 <__udivdi3+0x50>
f0106de8:	0f bd cf             	bsr    %edi,%ecx
f0106deb:	83 f1 1f             	xor    $0x1f,%ecx
f0106dee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106df2:	75 2c                	jne    f0106e20 <__udivdi3+0xa0>
f0106df4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0106df8:	76 04                	jbe    f0106dfe <__udivdi3+0x7e>
f0106dfa:	39 f7                	cmp    %esi,%edi
f0106dfc:	73 d2                	jae    f0106dd0 <__udivdi3+0x50>
f0106dfe:	31 d2                	xor    %edx,%edx
f0106e00:	b8 01 00 00 00       	mov    $0x1,%eax
f0106e05:	eb c9                	jmp    f0106dd0 <__udivdi3+0x50>
f0106e07:	90                   	nop
f0106e08:	89 f2                	mov    %esi,%edx
f0106e0a:	f7 f1                	div    %ecx
f0106e0c:	31 d2                	xor    %edx,%edx
f0106e0e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106e12:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106e16:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106e1a:	83 c4 1c             	add    $0x1c,%esp
f0106e1d:	c3                   	ret    
f0106e1e:	66 90                	xchg   %ax,%ax
f0106e20:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106e25:	b8 20 00 00 00       	mov    $0x20,%eax
f0106e2a:	89 ea                	mov    %ebp,%edx
f0106e2c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106e30:	d3 e7                	shl    %cl,%edi
f0106e32:	89 c1                	mov    %eax,%ecx
f0106e34:	d3 ea                	shr    %cl,%edx
f0106e36:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106e3b:	09 fa                	or     %edi,%edx
f0106e3d:	89 f7                	mov    %esi,%edi
f0106e3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106e43:	89 f2                	mov    %esi,%edx
f0106e45:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106e49:	d3 e5                	shl    %cl,%ebp
f0106e4b:	89 c1                	mov    %eax,%ecx
f0106e4d:	d3 ef                	shr    %cl,%edi
f0106e4f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106e54:	d3 e2                	shl    %cl,%edx
f0106e56:	89 c1                	mov    %eax,%ecx
f0106e58:	d3 ee                	shr    %cl,%esi
f0106e5a:	09 d6                	or     %edx,%esi
f0106e5c:	89 fa                	mov    %edi,%edx
f0106e5e:	89 f0                	mov    %esi,%eax
f0106e60:	f7 74 24 0c          	divl   0xc(%esp)
f0106e64:	89 d7                	mov    %edx,%edi
f0106e66:	89 c6                	mov    %eax,%esi
f0106e68:	f7 e5                	mul    %ebp
f0106e6a:	39 d7                	cmp    %edx,%edi
f0106e6c:	72 22                	jb     f0106e90 <__udivdi3+0x110>
f0106e6e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0106e72:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106e77:	d3 e5                	shl    %cl,%ebp
f0106e79:	39 c5                	cmp    %eax,%ebp
f0106e7b:	73 04                	jae    f0106e81 <__udivdi3+0x101>
f0106e7d:	39 d7                	cmp    %edx,%edi
f0106e7f:	74 0f                	je     f0106e90 <__udivdi3+0x110>
f0106e81:	89 f0                	mov    %esi,%eax
f0106e83:	31 d2                	xor    %edx,%edx
f0106e85:	e9 46 ff ff ff       	jmp    f0106dd0 <__udivdi3+0x50>
f0106e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106e90:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106e93:	31 d2                	xor    %edx,%edx
f0106e95:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106e99:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106e9d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106ea1:	83 c4 1c             	add    $0x1c,%esp
f0106ea4:	c3                   	ret    
	...

f0106eb0 <__umoddi3>:
f0106eb0:	83 ec 1c             	sub    $0x1c,%esp
f0106eb3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106eb7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0106ebb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106ebf:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106ec3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106ec7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106ecb:	85 ed                	test   %ebp,%ebp
f0106ecd:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106ed1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ed5:	89 cf                	mov    %ecx,%edi
f0106ed7:	89 04 24             	mov    %eax,(%esp)
f0106eda:	89 f2                	mov    %esi,%edx
f0106edc:	75 1a                	jne    f0106ef8 <__umoddi3+0x48>
f0106ede:	39 f1                	cmp    %esi,%ecx
f0106ee0:	76 4e                	jbe    f0106f30 <__umoddi3+0x80>
f0106ee2:	f7 f1                	div    %ecx
f0106ee4:	89 d0                	mov    %edx,%eax
f0106ee6:	31 d2                	xor    %edx,%edx
f0106ee8:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106eec:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106ef0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106ef4:	83 c4 1c             	add    $0x1c,%esp
f0106ef7:	c3                   	ret    
f0106ef8:	39 f5                	cmp    %esi,%ebp
f0106efa:	77 54                	ja     f0106f50 <__umoddi3+0xa0>
f0106efc:	0f bd c5             	bsr    %ebp,%eax
f0106eff:	83 f0 1f             	xor    $0x1f,%eax
f0106f02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f06:	75 60                	jne    f0106f68 <__umoddi3+0xb8>
f0106f08:	3b 0c 24             	cmp    (%esp),%ecx
f0106f0b:	0f 87 07 01 00 00    	ja     f0107018 <__umoddi3+0x168>
f0106f11:	89 f2                	mov    %esi,%edx
f0106f13:	8b 34 24             	mov    (%esp),%esi
f0106f16:	29 ce                	sub    %ecx,%esi
f0106f18:	19 ea                	sbb    %ebp,%edx
f0106f1a:	89 34 24             	mov    %esi,(%esp)
f0106f1d:	8b 04 24             	mov    (%esp),%eax
f0106f20:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106f24:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106f28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106f2c:	83 c4 1c             	add    $0x1c,%esp
f0106f2f:	c3                   	ret    
f0106f30:	85 c9                	test   %ecx,%ecx
f0106f32:	75 0b                	jne    f0106f3f <__umoddi3+0x8f>
f0106f34:	b8 01 00 00 00       	mov    $0x1,%eax
f0106f39:	31 d2                	xor    %edx,%edx
f0106f3b:	f7 f1                	div    %ecx
f0106f3d:	89 c1                	mov    %eax,%ecx
f0106f3f:	89 f0                	mov    %esi,%eax
f0106f41:	31 d2                	xor    %edx,%edx
f0106f43:	f7 f1                	div    %ecx
f0106f45:	8b 04 24             	mov    (%esp),%eax
f0106f48:	f7 f1                	div    %ecx
f0106f4a:	eb 98                	jmp    f0106ee4 <__umoddi3+0x34>
f0106f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106f50:	89 f2                	mov    %esi,%edx
f0106f52:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106f56:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106f5a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106f5e:	83 c4 1c             	add    $0x1c,%esp
f0106f61:	c3                   	ret    
f0106f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106f68:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106f6d:	89 e8                	mov    %ebp,%eax
f0106f6f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0106f74:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0106f78:	89 fa                	mov    %edi,%edx
f0106f7a:	d3 e0                	shl    %cl,%eax
f0106f7c:	89 e9                	mov    %ebp,%ecx
f0106f7e:	d3 ea                	shr    %cl,%edx
f0106f80:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106f85:	09 c2                	or     %eax,%edx
f0106f87:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106f8b:	89 14 24             	mov    %edx,(%esp)
f0106f8e:	89 f2                	mov    %esi,%edx
f0106f90:	d3 e7                	shl    %cl,%edi
f0106f92:	89 e9                	mov    %ebp,%ecx
f0106f94:	d3 ea                	shr    %cl,%edx
f0106f96:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106f9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106f9f:	d3 e6                	shl    %cl,%esi
f0106fa1:	89 e9                	mov    %ebp,%ecx
f0106fa3:	d3 e8                	shr    %cl,%eax
f0106fa5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106faa:	09 f0                	or     %esi,%eax
f0106fac:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106fb0:	f7 34 24             	divl   (%esp)
f0106fb3:	d3 e6                	shl    %cl,%esi
f0106fb5:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106fb9:	89 d6                	mov    %edx,%esi
f0106fbb:	f7 e7                	mul    %edi
f0106fbd:	39 d6                	cmp    %edx,%esi
f0106fbf:	89 c1                	mov    %eax,%ecx
f0106fc1:	89 d7                	mov    %edx,%edi
f0106fc3:	72 3f                	jb     f0107004 <__umoddi3+0x154>
f0106fc5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106fc9:	72 35                	jb     f0107000 <__umoddi3+0x150>
f0106fcb:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106fcf:	29 c8                	sub    %ecx,%eax
f0106fd1:	19 fe                	sbb    %edi,%esi
f0106fd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106fd8:	89 f2                	mov    %esi,%edx
f0106fda:	d3 e8                	shr    %cl,%eax
f0106fdc:	89 e9                	mov    %ebp,%ecx
f0106fde:	d3 e2                	shl    %cl,%edx
f0106fe0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106fe5:	09 d0                	or     %edx,%eax
f0106fe7:	89 f2                	mov    %esi,%edx
f0106fe9:	d3 ea                	shr    %cl,%edx
f0106feb:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106fef:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106ff3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106ff7:	83 c4 1c             	add    $0x1c,%esp
f0106ffa:	c3                   	ret    
f0106ffb:	90                   	nop
f0106ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107000:	39 d6                	cmp    %edx,%esi
f0107002:	75 c7                	jne    f0106fcb <__umoddi3+0x11b>
f0107004:	89 d7                	mov    %edx,%edi
f0107006:	89 c1                	mov    %eax,%ecx
f0107008:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010700c:	1b 3c 24             	sbb    (%esp),%edi
f010700f:	eb ba                	jmp    f0106fcb <__umoddi3+0x11b>
f0107011:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107018:	39 f5                	cmp    %esi,%ebp
f010701a:	0f 82 f1 fe ff ff    	jb     f0106f11 <__umoddi3+0x61>
f0107020:	e9 f8 fe ff ff       	jmp    f0106f1d <__umoddi3+0x6d>
