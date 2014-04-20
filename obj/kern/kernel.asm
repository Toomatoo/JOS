
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
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
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
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

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
f010004b:	83 3d 80 ce 22 f0 00 	cmpl   $0x0,0xf022ce80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 ce 22 f0    	mov    %esi,0xf022ce80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 dc 6a 00 00       	call   f0106b40 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 80 72 10 f0 	movl   $0xf0107280,(%esp)
f010007d:	e8 78 45 00 00       	call   f01045fa <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 39 45 00 00       	call   f01045c7 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 b6 86 10 f0 	movl   $0xf01086b6,(%esp)
f0100095:	e8 60 45 00 00       	call   f01045fa <cprintf>
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
f01000ae:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 eb 72 10 f0 	movl   $0xf01072eb,(%esp)
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
f01000e2:	e8 59 6a 00 00       	call   f0106b40 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 f7 72 10 f0 	movl   $0xf01072f7,(%esp)
f01000f2:	e8 03 45 00 00       	call   f01045fa <cprintf>

	lapic_init();
f01000f7:	e8 5e 6a 00 00       	call   f0106b5a <lapic_init>
	env_init_percpu();
f01000fc:	e8 90 3c 00 00       	call   f0103d91 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 1a 45 00 00       	call   f0104620 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 35 6a 00 00       	call   f0106b40 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
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
f010011d:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0100124:	e8 c7 6c 00 00       	call   f0106df0 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 f6 4e 00 00       	call   f0105024 <sched_yield>

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
f0100135:	b8 08 e0 26 f0       	mov    $0xf026e008,%eax
f010013a:	2d 74 b4 22 f0       	sub    $0xf022b474,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 74 b4 22 f0 	movl   $0xf022b474,(%esp)
f0100152:	e8 5a 63 00 00       	call   f01064b1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 2f 05 00 00       	call   f010068b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 0d 73 10 f0 	movl   $0xf010730d,(%esp)
f010016b:	e8 8a 44 00 00       	call   f01045fa <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 f2 19 00 00       	call   f0101b67 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 41 3c 00 00       	call   f0103dbb <env_init>
	trap_init();
f010017a:	e8 99 45 00 00       	call   f0104718 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 dc 66 00 00       	call   f0106861 <mp_init>
	lapic_init();
f0100185:	e8 d0 69 00 00       	call   f0106b5a <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 9a 43 00 00       	call   f0104529 <pic_init>
f010018f:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0100196:	e8 55 6c 00 00       	call   f0106df0 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019b:	83 3d 88 ce 22 f0 07 	cmpl   $0x7,0xf022ce88
f01001a2:	77 24                	ja     f01001c8 <i386_init+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001ab:	00 
f01001ac:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 eb 72 10 f0 	movl   $0xf01072eb,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 7a 67 10 f0       	mov    $0xf010677a,%eax
f01001cd:	2d 00 67 10 f0       	sub    $0xf0106700,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 00 67 10 	movl   $0xf0106700,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 22 63 00 00       	call   f010650c <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f01001f1:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f01001f6:	3d 20 d0 22 f0       	cmp    $0xf022d020,%eax
f01001fb:	76 62                	jbe    f010025f <i386_init+0x131>
f01001fd:	bb 20 d0 22 f0       	mov    $0xf022d020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100202:	e8 39 69 00 00       	call   f0106b40 <cpunum>
f0100207:	6b c0 74             	imul   $0x74,%eax,%eax
f010020a:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f010020f:	39 c3                	cmp    %eax,%ebx
f0100211:	74 39                	je     f010024c <i386_init+0x11e>

static void boot_aps(void);


void
i386_init(void)
f0100213:	89 d8                	mov    %ebx,%eax
f0100215:	2d 20 d0 22 f0       	sub    $0xf022d020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021a:	c1 f8 02             	sar    $0x2,%eax
f010021d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100223:	c1 e0 0f             	shl    $0xf,%eax
f0100226:	8d 80 00 60 23 f0    	lea    -0xfdca000(%eax),%eax
f010022c:	a3 84 ce 22 f0       	mov    %eax,0xf022ce84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100231:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100238:	00 
f0100239:	0f b6 03             	movzbl (%ebx),%eax
f010023c:	89 04 24             	mov    %eax,(%esp)
f010023f:	e8 64 6a 00 00       	call   f0106ca8 <lapic_startap>
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
f010024f:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f0100256:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f010025b:	39 c3                	cmp    %eax,%ebx
f010025d:	72 a3                	jb     f0100202 <i386_init+0xd4>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010025f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100266:	00 
f0100267:	c7 44 24 04 8f 9a 00 	movl   $0x9a8f,0x4(%esp)
f010026e:	00 
f010026f:	c7 04 24 e5 19 22 f0 	movl   $0xf02219e5,(%esp)
f0100276:	e8 34 3d 00 00       	call   f0103faf <env_create>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	
	// Schedule and run the first user environment!
	sched_yield();
f010027b:	e8 a4 4d 00 00       	call   f0105024 <sched_yield>

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
f0100298:	c7 04 24 28 73 10 f0 	movl   $0xf0107328,(%esp)
f010029f:	e8 56 43 00 00       	call   f01045fa <cprintf>
	vcprintf(fmt, ap);
f01002a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ab:	89 04 24             	mov    %eax,(%esp)
f01002ae:	e8 14 43 00 00       	call   f01045c7 <vcprintf>
	cprintf("\n");
f01002b3:	c7 04 24 b6 86 10 f0 	movl   $0xf01086b6,(%esp)
f01002ba:	e8 3b 43 00 00       	call   f01045fa <cprintf>
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
f0100309:	8b 15 24 c2 22 f0    	mov    0xf022c224,%edx
f010030f:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
f0100315:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100318:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010031d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100322:	0f 44 c2             	cmove  %edx,%eax
f0100325:	a3 24 c2 22 f0       	mov    %eax,0xf022c224
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
f01003ac:	a1 78 34 12 f0       	mov    0xf0123478,%eax
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
f01003f2:	0f b7 15 34 c2 22 f0 	movzwl 0xf022c234,%edx
f01003f9:	66 85 d2             	test   %dx,%dx
f01003fc:	0f 84 e3 00 00 00    	je     f01004e5 <cons_putc+0x1ae>
			crt_pos--;
f0100402:	83 ea 01             	sub    $0x1,%edx
f0100405:	66 89 15 34 c2 22 f0 	mov    %dx,0xf022c234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010040c:	0f b7 d2             	movzwl %dx,%edx
f010040f:	b0 00                	mov    $0x0,%al
f0100411:	83 c8 20             	or     $0x20,%eax
f0100414:	8b 0d 30 c2 22 f0    	mov    0xf022c230,%ecx
f010041a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010041e:	eb 78                	jmp    f0100498 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100420:	66 83 05 34 c2 22 f0 	addw   $0x50,0xf022c234
f0100427:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100428:	0f b7 05 34 c2 22 f0 	movzwl 0xf022c234,%eax
f010042f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100435:	c1 e8 16             	shr    $0x16,%eax
f0100438:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043b:	c1 e0 04             	shl    $0x4,%eax
f010043e:	66 a3 34 c2 22 f0    	mov    %ax,0xf022c234
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
f010047a:	0f b7 15 34 c2 22 f0 	movzwl 0xf022c234,%edx
f0100481:	0f b7 da             	movzwl %dx,%ebx
f0100484:	8b 0d 30 c2 22 f0    	mov    0xf022c230,%ecx
f010048a:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010048e:	83 c2 01             	add    $0x1,%edx
f0100491:	66 89 15 34 c2 22 f0 	mov    %dx,0xf022c234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100498:	66 81 3d 34 c2 22 f0 	cmpw   $0x7cf,0xf022c234
f010049f:	cf 07 
f01004a1:	76 42                	jbe    f01004e5 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a3:	a1 30 c2 22 f0       	mov    0xf022c230,%eax
f01004a8:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004af:	00 
f01004b0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004ba:	89 04 24             	mov    %eax,(%esp)
f01004bd:	e8 4a 60 00 00       	call   f010650c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004c2:	8b 15 30 c2 22 f0    	mov    0xf022c230,%edx
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
f01004dd:	66 83 2d 34 c2 22 f0 	subw   $0x50,0xf022c234
f01004e4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e5:	8b 0d 2c c2 22 f0    	mov    0xf022c22c,%ecx
f01004eb:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004f0:	89 ca                	mov    %ecx,%edx
f01004f2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f3:	0f b7 35 34 c2 22 f0 	movzwl 0xf022c234,%esi
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
f010053e:	83 0d 28 c2 22 f0 40 	orl    $0x40,0xf022c228
		return 0;
f0100545:	bb 00 00 00 00       	mov    $0x0,%ebx
f010054a:	e9 c4 00 00 00       	jmp    f0100613 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f010054f:	84 c0                	test   %al,%al
f0100551:	79 37                	jns    f010058a <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100553:	8b 0d 28 c2 22 f0    	mov    0xf022c228,%ecx
f0100559:	89 cb                	mov    %ecx,%ebx
f010055b:	83 e3 40             	and    $0x40,%ebx
f010055e:	83 e0 7f             	and    $0x7f,%eax
f0100561:	85 db                	test   %ebx,%ebx
f0100563:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100566:	0f b6 d2             	movzbl %dl,%edx
f0100569:	0f b6 82 80 73 10 f0 	movzbl -0xfef8c80(%edx),%eax
f0100570:	83 c8 40             	or     $0x40,%eax
f0100573:	0f b6 c0             	movzbl %al,%eax
f0100576:	f7 d0                	not    %eax
f0100578:	21 c1                	and    %eax,%ecx
f010057a:	89 0d 28 c2 22 f0    	mov    %ecx,0xf022c228
		return 0;
f0100580:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100585:	e9 89 00 00 00       	jmp    f0100613 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010058a:	8b 0d 28 c2 22 f0    	mov    0xf022c228,%ecx
f0100590:	f6 c1 40             	test   $0x40,%cl
f0100593:	74 0e                	je     f01005a3 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100595:	89 c2                	mov    %eax,%edx
f0100597:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010059a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010059d:	89 0d 28 c2 22 f0    	mov    %ecx,0xf022c228
	}

	shift |= shiftcode[data];
f01005a3:	0f b6 d2             	movzbl %dl,%edx
f01005a6:	0f b6 82 80 73 10 f0 	movzbl -0xfef8c80(%edx),%eax
f01005ad:	0b 05 28 c2 22 f0    	or     0xf022c228,%eax
	shift ^= togglecode[data];
f01005b3:	0f b6 8a 80 74 10 f0 	movzbl -0xfef8b80(%edx),%ecx
f01005ba:	31 c8                	xor    %ecx,%eax
f01005bc:	a3 28 c2 22 f0       	mov    %eax,0xf022c228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005c1:	89 c1                	mov    %eax,%ecx
f01005c3:	83 e1 03             	and    $0x3,%ecx
f01005c6:	8b 0c 8d 80 75 10 f0 	mov    -0xfef8a80(,%ecx,4),%ecx
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
f01005fc:	c7 04 24 42 73 10 f0 	movl   $0xf0107342,(%esp)
f0100603:	e8 f2 3f 00 00       	call   f01045fa <cprintf>
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
f0100621:	80 3d 00 c0 22 f0 00 	cmpb   $0x0,0xf022c000
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
f0100658:	8b 15 20 c2 22 f0    	mov    0xf022c220,%edx
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
f0100663:	3b 15 24 c2 22 f0    	cmp    0xf022c224,%edx
f0100669:	74 1e                	je     f0100689 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010066b:	0f b6 82 20 c0 22 f0 	movzbl -0xfdd3fe0(%edx),%eax
f0100672:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100675:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100680:	0f 44 d1             	cmove  %ecx,%edx
f0100683:	89 15 20 c2 22 f0    	mov    %edx,0xf022c220
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
f01006b1:	c7 05 2c c2 22 f0 b4 	movl   $0x3b4,0xf022c22c
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
f01006c9:	c7 05 2c c2 22 f0 d4 	movl   $0x3d4,0xf022c22c
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
f01006d8:	8b 0d 2c c2 22 f0    	mov    0xf022c22c,%ecx
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
f01006fd:	89 35 30 c2 22 f0    	mov    %esi,0xf022c230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100703:	0f b6 d8             	movzbl %al,%ebx
f0100706:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100708:	66 89 3d 34 c2 22 f0 	mov    %di,0xf022c234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f010070f:	e8 22 ff ff ff       	call   f0100636 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100714:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f010071b:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100720:	89 04 24             	mov    %eax,(%esp)
f0100723:	e8 90 3d 00 00       	call   f01044b8 <irq_setmask_8259A>
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
f0100774:	a2 00 c0 22 f0       	mov    %al,0xf022c000
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
f0100785:	c7 04 24 4e 73 10 f0 	movl   $0xf010734e,(%esp)
f010078c:	e8 69 3e 00 00       	call   f01045fa <cprintf>
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
f01007d6:	c7 04 24 90 75 10 f0 	movl   $0xf0107590,(%esp)
f01007dd:	e8 18 3e 00 00       	call   f01045fa <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007e9:	00 
f01007ea:	c7 04 24 1c 77 10 f0 	movl   $0xf010771c,(%esp)
f01007f1:	e8 04 3e 00 00       	call   f01045fa <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007fd:	00 
f01007fe:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 44 77 10 f0 	movl   $0xf0107744,(%esp)
f010080d:	e8 e8 3d 00 00       	call   f01045fa <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100812:	c7 44 24 08 75 72 10 	movl   $0x107275,0x8(%esp)
f0100819:	00 
f010081a:	c7 44 24 04 75 72 10 	movl   $0xf0107275,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 68 77 10 f0 	movl   $0xf0107768,(%esp)
f0100829:	e8 cc 3d 00 00       	call   f01045fa <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082e:	c7 44 24 08 74 b4 22 	movl   $0x22b474,0x8(%esp)
f0100835:	00 
f0100836:	c7 44 24 04 74 b4 22 	movl   $0xf022b474,0x4(%esp)
f010083d:	f0 
f010083e:	c7 04 24 8c 77 10 f0 	movl   $0xf010778c,(%esp)
f0100845:	e8 b0 3d 00 00       	call   f01045fa <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084a:	c7 44 24 08 08 e0 26 	movl   $0x26e008,0x8(%esp)
f0100851:	00 
f0100852:	c7 44 24 04 08 e0 26 	movl   $0xf026e008,0x4(%esp)
f0100859:	f0 
f010085a:	c7 04 24 b0 77 10 f0 	movl   $0xf01077b0,(%esp)
f0100861:	e8 94 3d 00 00       	call   f01045fa <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100866:	b8 07 e4 26 f0       	mov    $0xf026e407,%eax
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
f0100887:	c7 04 24 d4 77 10 f0 	movl   $0xf01077d4,(%esp)
f010088e:	e8 67 3d 00 00       	call   f01045fa <cprintf>
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
f01008a6:	8b 83 84 7a 10 f0    	mov    -0xfef857c(%ebx),%eax
f01008ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008b0:	8b 83 80 7a 10 f0    	mov    -0xfef8580(%ebx),%eax
f01008b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ba:	c7 04 24 a9 75 10 f0 	movl   $0xf01075a9,(%esp)
f01008c1:	e8 34 3d 00 00       	call   f01045fa <cprintf>
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
f010090f:	e8 10 5d 00 00       	call   f0106624 <strtol>
f0100914:	89 c6                	mov    %eax,%esi

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
f0100916:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100919:	89 44 24 08          	mov    %eax,0x8(%esp)
f010091d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100921:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0100926:	89 04 24             	mov    %eax,(%esp)
f0100929:	e8 1b 10 00 00       	call   f0101949 <page_lookup>
	if(!pageofva)
f010092e:	85 c0                	test   %eax,%eax
f0100930:	0f 84 b6 01 00 00    	je     f0100aec <mon_changepermission+0x213>
		return -1;

	unsigned int perm = 0;
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f0100936:	c7 44 24 04 b2 75 10 	movl   $0xf01075b2,0x4(%esp)
f010093d:	f0 
f010093e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100941:	89 04 24             	mov    %eax,(%esp)
f0100944:	e8 92 5a 00 00       	call   f01063db <strcmp>
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
f0100968:	e8 b7 5c 00 00       	call   f0106624 <strtol>
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
f0100980:	c7 44 24 04 b7 75 10 	movl   $0xf01075b7,0x4(%esp)
f0100987:	f0 
f0100988:	8b 43 04             	mov    0x4(%ebx),%eax
f010098b:	89 04 24             	mov    %eax,(%esp)
f010098e:	e8 48 5a 00 00       	call   f01063db <strcmp>
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
f01009ab:	c7 44 24 04 be 75 10 	movl   $0xf01075be,0x4(%esp)
f01009b2:	f0 
f01009b3:	8b 43 04             	mov    0x4(%ebx),%eax
f01009b6:	89 04 24             	mov    %eax,(%esp)
f01009b9:	e8 1d 5a 00 00       	call   f01063db <strcmp>
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	0f 85 0b 01 00 00    	jne    f0100ad1 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f01009c6:	c7 44 24 04 c3 86 10 	movl   $0xf01086c3,0x4(%esp)
f01009cd:	f0 
f01009ce:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009d1:	89 04 24             	mov    %eax,(%esp)
f01009d4:	e8 02 5a 00 00       	call   f01063db <strcmp>
f01009d9:	85 c0                	test   %eax,%eax
f01009db:	75 06                	jne    f01009e3 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f01009dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009e0:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f01009e3:	c7 44 24 04 d4 86 10 	movl   $0xf01086d4,0x4(%esp)
f01009ea:	f0 
f01009eb:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009ee:	89 04 24             	mov    %eax,(%esp)
f01009f1:	e8 e5 59 00 00       	call   f01063db <strcmp>
f01009f6:	85 c0                	test   %eax,%eax
f01009f8:	75 06                	jne    f0100a00 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f01009fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009fd:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f0100a00:	c7 44 24 04 c6 75 10 	movl   $0xf01075c6,0x4(%esp)
f0100a07:	f0 
f0100a08:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a0b:	89 04 24             	mov    %eax,(%esp)
f0100a0e:	e8 c8 59 00 00       	call   f01063db <strcmp>
f0100a13:	85 c0                	test   %eax,%eax
f0100a15:	75 06                	jne    f0100a1d <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f0100a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1a:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f0100a1d:	c7 44 24 04 25 86 10 	movl   $0xf0108625,0x4(%esp)
f0100a24:	f0 
f0100a25:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a28:	89 04 24             	mov    %eax,(%esp)
f0100a2b:	e8 ab 59 00 00       	call   f01063db <strcmp>
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	75 06                	jne    f0100a3a <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f0100a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a37:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f0100a3a:	c7 44 24 04 ce 75 10 	movl   $0xf01075ce,0x4(%esp)
f0100a41:	f0 
f0100a42:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a45:	89 04 24             	mov    %eax,(%esp)
f0100a48:	e8 8e 59 00 00       	call   f01063db <strcmp>
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	75 06                	jne    f0100a57 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f0100a51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a54:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f0100a57:	c7 44 24 04 d6 75 10 	movl   $0xf01075d6,0x4(%esp)
f0100a5e:	f0 
f0100a5f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a62:	89 04 24             	mov    %eax,(%esp)
f0100a65:	e8 71 59 00 00       	call   f01063db <strcmp>
f0100a6a:	85 c0                	test   %eax,%eax
f0100a6c:	75 06                	jne    f0100a74 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f0100a6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a71:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f0100a74:	c7 44 24 04 dc 75 10 	movl   $0xf01075dc,0x4(%esp)
f0100a7b:	f0 
f0100a7c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a7f:	89 04 24             	mov    %eax,(%esp)
f0100a82:	e8 54 59 00 00       	call   f01063db <strcmp>
f0100a87:	85 c0                	test   %eax,%eax
f0100a89:	75 06                	jne    f0100a91 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f0100a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8e:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f0100a91:	c7 44 24 04 e2 75 10 	movl   $0xf01075e2,0x4(%esp)
f0100a98:	f0 
f0100a99:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a9c:	89 04 24             	mov    %eax,(%esp)
f0100a9f:	e8 37 59 00 00       	call   f01063db <strcmp>
f0100aa4:	85 c0                	test   %eax,%eax
f0100aa6:	75 09                	jne    f0100ab1 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f0100aa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aab:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100ab1:	c7 44 24 04 e9 75 10 	movl   $0xf01075e9,0x4(%esp)
f0100ab8:	f0 
f0100ab9:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100abc:	89 04 24             	mov    %eax,(%esp)
f0100abf:	e8 17 59 00 00       	call   f01063db <strcmp>
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
f0100ad9:	c7 04 24 ef 75 10 f0 	movl   $0xf01075ef,(%esp)
f0100ae0:	e8 15 3b 00 00       	call   f01045fa <cprintf>
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
f0100b2a:	e8 f5 5a 00 00       	call   f0106624 <strtol>
f0100b2f:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f0100b31:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b38:	00 
f0100b39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b40:	00 
f0100b41:	8b 46 08             	mov    0x8(%esi),%eax
f0100b44:	89 04 24             	mov    %eax,(%esp)
f0100b47:	e8 d8 5a 00 00       	call   f0106624 <strtol>
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
f0100b62:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0100b67:	89 04 24             	mov    %eax,(%esp)
f0100b6a:	e8 da 0d 00 00       	call   f0101949 <page_lookup>

		if(!pageofva) {
f0100b6f:	85 c0                	test   %eax,%eax
f0100b71:	75 0e                	jne    f0100b81 <mon_showmappings+0x88>
			cprintf("0x%x: There is no physical page here.\n");
f0100b73:	c7 04 24 00 78 10 f0 	movl   $0xf0107800,(%esp)
f0100b7a:	e8 7b 3a 00 00       	call   f01045fa <cprintf>
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
f0100b9f:	c7 04 24 28 78 10 f0 	movl   $0xf0107828,(%esp)
f0100ba6:	e8 4f 3a 00 00       	call   f01045fa <cprintf>
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
f0100c02:	c7 04 24 0b 76 10 f0 	movl   $0xf010760b,(%esp)
f0100c09:	e8 ec 39 00 00       	call   f01045fa <cprintf>
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
f0100c55:	c7 04 24 5c 78 10 f0 	movl   $0xf010785c,(%esp)
f0100c5c:	e8 99 39 00 00       	call   f01045fa <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100c61:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c68:	89 1c 24             	mov    %ebx,(%esp)
f0100c6b:	e8 86 4b 00 00       	call   f01057f6 <debuginfo_eip>
f0100c70:	85 c0                	test   %eax,%eax
f0100c72:	0f 88 93 00 00 00    	js     f0100d0b <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100c78:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100c85:	89 04 24             	mov    %eax,(%esp)
f0100c88:	e8 8e 56 00 00       	call   f010631b <strcpy>

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
f0100caa:	e8 b7 56 00 00       	call   f0106366 <strncpy>
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
f0100cd6:	c7 04 24 1d 76 10 f0 	movl   $0xf010761d,(%esp)
f0100cdd:	e8 18 39 00 00       	call   f01045fa <cprintf>
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
f0100d47:	e8 d8 58 00 00       	call   f0106624 <strtol>
f0100d4c:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100d4e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d55:	00 
f0100d56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d5d:	00 
f0100d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d61:	8b 42 0c             	mov    0xc(%edx),%eax
f0100d64:	89 04 24             	mov    %eax,(%esp)
f0100d67:	e8 b8 58 00 00       	call   f0106624 <strtol>
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
f0100da3:	c7 04 24 34 76 10 f0 	movl   $0xf0107634,(%esp)
f0100daa:	e8 4b 38 00 00       	call   f01045fa <cprintf>

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
f0100dc1:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
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
f0100de0:	c7 04 24 4d 76 10 f0 	movl   $0xf010764d,(%esp)
f0100de7:	e8 0e 38 00 00       	call   f01045fa <cprintf>
f0100dec:	eb 0c                	jmp    f0100dfa <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100dee:	c7 04 24 55 76 10 f0 	movl   $0xf0107655,(%esp)
f0100df5:	e8 00 38 00 00       	call   f01045fa <cprintf>
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
f0100e0f:	c7 04 24 b6 86 10 f0 	movl   $0xf01086b6,(%esp)
f0100e16:	e8 df 37 00 00       	call   f01045fa <cprintf>
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
f0100e52:	bf 00 90 11 f0       	mov    $0xf0119000,%edi
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
f0100e66:	c7 04 24 5b 76 10 f0 	movl   $0xf010765b,(%esp)
f0100e6d:	e8 88 37 00 00       	call   f01045fa <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100e72:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0100e77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e7c:	77 20                	ja     f0100e9e <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e82:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0100e89:	f0 
f0100e8a:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100e91:	00 
f0100e92:	c7 04 24 75 76 10 f0 	movl   $0xf0107675,(%esp)
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
f0100ebe:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0100ec5:	f0 
f0100ec6:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100ecd:	00 
f0100ece:	c7 04 24 75 76 10 f0 	movl   $0xf0107675,(%esp)
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
f0100ef4:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0100efb:	f0 
f0100efc:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0100f03:	00 
f0100f04:	c7 04 24 75 76 10 f0 	movl   $0xf0107675,(%esp)
f0100f0b:	e8 30 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f10:	89 da                	mov    %ebx,%edx
f0100f12:	29 c2                	sub    %eax,%edx
f0100f14:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f1e:	c7 04 24 4d 76 10 f0 	movl   $0xf010764d,(%esp)
f0100f25:	e8 d0 36 00 00       	call   f01045fa <cprintf>
f0100f2a:	e9 b0 00 00 00       	jmp    f0100fdf <mon_dump+0x2c4>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f2f:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100f35:	77 24                	ja     f0100f5b <mon_dump+0x240>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f37:	c7 44 24 0c 00 90 11 	movl   $0xf0119000,0xc(%esp)
f0100f3e:	f0 
f0100f3f:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0100f46:	f0 
f0100f47:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f4e:	00 
f0100f4f:	c7 04 24 75 76 10 f0 	movl   $0xf0107675,(%esp)
f0100f56:	e8 e5 f0 ff ff       	call   f0100040 <_panic>
			else if(_addr >= PADDR((void *)bootstack) && _addr < PADDR((void *)bootstack + KSTKSIZE))
f0100f5b:	81 fb 00 90 11 00    	cmp    $0x119000,%ebx
f0100f61:	72 50                	jb     f0100fb3 <mon_dump+0x298>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f63:	b8 00 10 12 f0       	mov    $0xf0121000,%eax
f0100f68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f6d:	77 20                	ja     f0100f8f <mon_dump+0x274>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f73:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0100f7a:	f0 
f0100f7b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f82:	00 
f0100f83:	c7 04 24 75 76 10 f0 	movl   $0xf0107675,(%esp)
f0100f8a:	e8 b1 f0 ff ff       	call   f0100040 <_panic>
f0100f8f:	81 fb 00 10 12 00    	cmp    $0x121000,%ebx
f0100f95:	73 1c                	jae    f0100fb3 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100f97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f9a:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa5:	c7 04 24 4d 76 10 f0 	movl   $0xf010764d,(%esp)
f0100fac:	e8 49 36 00 00       	call   f01045fa <cprintf>
f0100fb1:	eb 2c                	jmp    f0100fdf <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100fb3:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100fb9:	77 18                	ja     f0100fd3 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100fbb:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fc5:	c7 04 24 4d 76 10 f0 	movl   $0xf010764d,(%esp)
f0100fcc:	e8 29 36 00 00       	call   f01045fa <cprintf>
f0100fd1:	eb 0c                	jmp    f0100fdf <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0100fd3:	c7 04 24 55 76 10 f0 	movl   $0xf0107655,(%esp)
f0100fda:	e8 1b 36 00 00       	call   f01045fa <cprintf>
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
f0100ff4:	c7 04 24 b6 86 10 f0 	movl   $0xf01086b6,(%esp)
f0100ffb:	e8 fa 35 00 00       	call   f01045fa <cprintf>
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
f0101035:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f010103c:	e8 b9 35 00 00       	call   f01045fa <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101041:	c7 04 24 b4 78 10 f0 	movl   $0xf01078b4,(%esp)
f0101048:	e8 ad 35 00 00       	call   f01045fa <cprintf>

	if (tf != NULL)
f010104d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101051:	74 0b                	je     f010105e <monitor+0x32>
		print_trapframe(tf);
f0101053:	8b 45 08             	mov    0x8(%ebp),%eax
f0101056:	89 04 24             	mov    %eax,(%esp)
f0101059:	e8 69 38 00 00       	call   f01048c7 <print_trapframe>

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f010105e:	c7 04 24 dc 78 10 f0 	movl   $0xf01078dc,(%esp)
f0101065:	e8 90 35 00 00       	call   f01045fa <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f010106a:	c7 04 24 10 79 10 f0 	movl   $0xf0107910,(%esp)
f0101071:	e8 84 35 00 00       	call   f01045fa <cprintf>
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);


	while (1) {
		buf = readline("K> ");
f0101076:	c7 04 24 84 76 10 f0 	movl   $0xf0107684,(%esp)
f010107d:	e8 7e 51 00 00       	call   f0106200 <readline>
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
f01010aa:	c7 04 24 88 76 10 f0 	movl   $0xf0107688,(%esp)
f01010b1:	e8 a0 53 00 00       	call   f0106456 <strchr>
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
f01010cc:	c7 04 24 8d 76 10 f0 	movl   $0xf010768d,(%esp)
f01010d3:	e8 22 35 00 00       	call   f01045fa <cprintf>
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
f01010fb:	c7 04 24 88 76 10 f0 	movl   $0xf0107688,(%esp)
f0101102:	e8 4f 53 00 00       	call   f0106456 <strchr>
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
f010111d:	bb 80 7a 10 f0       	mov    $0xf0107a80,%ebx
f0101122:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101127:	8b 03                	mov    (%ebx),%eax
f0101129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010112d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101130:	89 04 24             	mov    %eax,(%esp)
f0101133:	e8 a3 52 00 00       	call   f01063db <strcmp>
f0101138:	85 c0                	test   %eax,%eax
f010113a:	75 24                	jne    f0101160 <monitor+0x134>
			return commands[i].func(argc, argv, tf);
f010113c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010113f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101142:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101146:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101149:	89 54 24 04          	mov    %edx,0x4(%esp)
f010114d:	89 34 24             	mov    %esi,(%esp)
f0101150:	ff 14 85 88 7a 10 f0 	call   *-0xfef8578(,%eax,4)


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
f0101172:	c7 04 24 aa 76 10 f0 	movl   $0xf01076aa,(%esp)
f0101179:	e8 7c 34 00 00       	call   f01045fa <cprintf>
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
f01011b3:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01011b9:	72 20                	jb     f01011db <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01011bf:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01011c6:	f0 
f01011c7:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01011ce:	00 
f01011cf:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0101208:	83 3d 3c c2 22 f0 00 	cmpl   $0x0,0xf022c23c
f010120f:	75 11                	jne    f0101222 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101211:	ba 07 f0 26 f0       	mov    $0xf026f007,%edx
f0101216:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010121c:	89 15 3c c2 22 f0    	mov    %edx,0xf022c23c
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f0101222:	83 3d 00 33 12 f0 ff 	cmpl   $0xffffffff,0xf0123300
f0101229:	75 0c                	jne    f0101237 <boot_alloc+0x36>
		npages_left = npages;
f010122b:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
f0101231:	89 15 00 33 12 f0    	mov    %edx,0xf0123300
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
f010123b:	83 3d 00 33 12 f0 00 	cmpl   $0x0,0xf0123300
f0101242:	75 1c                	jne    f0101260 <boot_alloc+0x5f>
			panic("Out of memory!\n");
f0101244:	c7 44 24 08 e1 83 10 	movl   $0xf01083e1,0x8(%esp)
f010124b:	f0 
f010124c:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0101253:	00 
f0101254:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010125b:	e8 e0 ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f0101260:	a1 3c c2 22 f0       	mov    0xf022c23c,%eax
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
f0101279:	8b 0d 00 33 12 f0    	mov    0xf0123300,%ecx
f010127f:	39 ca                	cmp    %ecx,%edx
f0101281:	76 1c                	jbe    f010129f <boot_alloc+0x9e>
			panic("Out of memory!\n");
f0101283:	c7 44 24 08 e1 83 10 	movl   $0xf01083e1,0x8(%esp)
f010128a:	f0 
f010128b:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
f0101292:	00 
f0101293:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010129a:	e8 a1 ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f010129f:	a1 3c c2 22 f0       	mov    0xf022c23c,%eax
		nextfree += srequest;
f01012a4:	01 c3                	add    %eax,%ebx
f01012a6:	89 1d 3c c2 22 f0    	mov    %ebx,0xf022c23c
		npages_left -= srequest/PGSIZE;
f01012ac:	29 d1                	sub    %edx,%ecx
f01012ae:	89 0d 00 33 12 f0    	mov    %ecx,0xf0123300

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
f01012cb:	e8 c0 31 00 00       	call   f0104490 <mc146818_read>
f01012d0:	89 c6                	mov    %eax,%esi
f01012d2:	83 c3 01             	add    $0x1,%ebx
f01012d5:	89 1c 24             	mov    %ebx,(%esp)
f01012d8:	e8 b3 31 00 00       	call   f0104490 <mc146818_read>
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
f0101302:	8b 1d 40 c2 22 f0    	mov    0xf022c240,%ebx
f0101308:	85 db                	test   %ebx,%ebx
f010130a:	75 1c                	jne    f0101328 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f010130c:	c7 44 24 08 c8 7a 10 	movl   $0xf0107ac8,0x8(%esp)
f0101313:	f0 
f0101314:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f010131b:	00 
f010131c:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f010133a:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
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
f0101372:	89 1d 40 c2 22 f0    	mov    %ebx,0xf022c240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101378:	85 db                	test   %ebx,%ebx
f010137a:	74 67                	je     f01013e3 <check_page_free_list+0xf7>
f010137c:	89 d8                	mov    %ebx,%eax
f010137e:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
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
f0101398:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f010139e:	72 20                	jb     f01013c0 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013a4:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01013ab:	f0 
f01013ac:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01013b3:	00 
f01013b4:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f01013bb:	e8 80 ec ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01013c0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01013c7:	00 
f01013c8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01013cf:	00 
	return (void *)(pa + KERNBASE);
f01013d0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013d5:	89 04 24             	mov    %eax,(%esp)
f01013d8:	e8 d4 50 00 00       	call   f01064b1 <memset>
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
f01013f0:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f01013f6:	85 d2                	test   %edx,%edx
f01013f8:	0f 84 2f 02 00 00    	je     f010162d <check_page_free_list+0x341>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01013fe:	8b 1d 90 ce 22 f0    	mov    0xf022ce90,%ebx
f0101404:	39 da                	cmp    %ebx,%edx
f0101406:	72 51                	jb     f0101459 <check_page_free_list+0x16d>
		assert(pp < pages + npages);
f0101408:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
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
f0101459:	c7 44 24 0c ff 83 10 	movl   $0xf01083ff,0xc(%esp)
f0101460:	f0 
f0101461:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101468:	f0 
f0101469:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101470:	00 
f0101471:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101478:	e8 c3 eb ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010147d:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101480:	72 24                	jb     f01014a6 <check_page_free_list+0x1ba>
f0101482:	c7 44 24 0c 20 84 10 	movl   $0xf0108420,0xc(%esp)
f0101489:	f0 
f010148a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101491:	f0 
f0101492:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101499:	00 
f010149a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01014a1:	e8 9a eb ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01014a6:	89 d0                	mov    %edx,%eax
f01014a8:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01014ab:	a8 07                	test   $0x7,%al
f01014ad:	74 24                	je     f01014d3 <check_page_free_list+0x1e7>
f01014af:	c7 44 24 0c ec 7a 10 	movl   $0xf0107aec,0xc(%esp)
f01014b6:	f0 
f01014b7:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f01014c6:	00 
f01014c7:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01014ce:	e8 6d eb ff ff       	call   f0100040 <_panic>
f01014d3:	c1 f8 03             	sar    $0x3,%eax
f01014d6:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01014d9:	85 c0                	test   %eax,%eax
f01014db:	75 24                	jne    f0101501 <check_page_free_list+0x215>
f01014dd:	c7 44 24 0c 34 84 10 	movl   $0xf0108434,0xc(%esp)
f01014e4:	f0 
f01014e5:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01014ec:	f0 
f01014ed:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01014f4:	00 
f01014f5:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01014fc:	e8 3f eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101501:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101506:	75 24                	jne    f010152c <check_page_free_list+0x240>
f0101508:	c7 44 24 0c 45 84 10 	movl   $0xf0108445,0xc(%esp)
f010150f:	f0 
f0101510:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101517:	f0 
f0101518:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f010151f:	00 
f0101520:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101527:	e8 14 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010152c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101531:	75 24                	jne    f0101557 <check_page_free_list+0x26b>
f0101533:	c7 44 24 0c 20 7b 10 	movl   $0xf0107b20,0xc(%esp)
f010153a:	f0 
f010153b:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101542:	f0 
f0101543:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f010154a:	00 
f010154b:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101552:	e8 e9 ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101557:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010155c:	75 24                	jne    f0101582 <check_page_free_list+0x296>
f010155e:	c7 44 24 0c 5e 84 10 	movl   $0xf010845e,0xc(%esp)
f0101565:	f0 
f0101566:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010156d:	f0 
f010156e:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101575:	00 
f0101576:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0101599:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01015a0:	f0 
f01015a1:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01015a8:	00 
f01015a9:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f01015b0:	e8 8b ea ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01015b5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01015bb:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01015be:	76 24                	jbe    f01015e4 <check_page_free_list+0x2f8>
f01015c0:	c7 44 24 0c 44 7b 10 	movl   $0xf0107b44,0xc(%esp)
f01015c7:	f0 
f01015c8:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01015cf:	f0 
f01015d0:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f01015d7:	00 
f01015d8:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01015df:	e8 5c ea ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01015e4:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01015e9:	75 24                	jne    f010160f <check_page_free_list+0x323>
f01015eb:	c7 44 24 0c 78 84 10 	movl   $0xf0108478,0xc(%esp)
f01015f2:	f0 
f01015f3:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101602:	00 
f0101603:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f010162d:	c7 44 24 0c 95 84 10 	movl   $0xf0108495,0xc(%esp)
f0101634:	f0 
f0101635:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010163c:	f0 
f010163d:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101644:	00 
f0101645:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101651:	85 f6                	test   %esi,%esi
f0101653:	7f 24                	jg     f0101679 <check_page_free_list+0x38d>
f0101655:	c7 44 24 0c a7 84 10 	movl   $0xf01084a7,0xc(%esp)
f010165c:	f0 
f010165d:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101664:	f0 
f0101665:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f010166c:	00 
f010166d:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101674:	e8 c7 e9 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101679:	c7 04 24 8c 7b 10 f0 	movl   $0xf0107b8c,(%esp)
f0101680:	e8 75 2f 00 00       	call   f01045fa <cprintf>
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
f0101696:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f010169d:	0f 85 a5 00 00 00    	jne    f0101748 <page_init+0xbb>
f01016a3:	e9 b2 00 00 00       	jmp    f010175a <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f01016a8:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
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
f01016e6:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f01016ed:	f0 
f01016ee:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f01016f5:	00 
f01016f6:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01016fd:	e8 3e e9 ff ff       	call   f0100040 <_panic>
f0101702:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0101707:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010170c:	39 f8                	cmp    %edi,%eax
f010170e:	77 27                	ja     f0101737 <page_init+0xaa>
			continue;	
		}
		
		if(page2pa(&pages[i]) == MPENTRY_PADDR)
f0101710:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
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
f0101724:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f0101729:	89 02                	mov    %eax,(%edx)
		page_free_list = &pages[i];
f010172b:	03 35 90 ce 22 f0    	add    0xf022ce90,%esi
f0101731:	89 35 40 c2 22 f0    	mov    %esi,0xf022c240
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101737:	83 c3 01             	add    $0x1,%ebx
f010173a:	39 1d 88 ce 22 f0    	cmp    %ebx,0xf022ce88
f0101740:	0f 87 62 ff ff ff    	ja     f01016a8 <page_init+0x1b>
f0101746:	eb 12                	jmp    f010175a <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f0101748:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
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
f0101769:	8b 1d 40 c2 22 f0    	mov    0xf022c240,%ebx
f010176f:	85 db                	test   %ebx,%ebx
f0101771:	74 65                	je     f01017d8 <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101773:	8b 03                	mov    (%ebx),%eax
f0101775:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
		
		if(alloc_flags & ALLOC_ZERO) { 
f010177a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010177e:	74 58                	je     f01017d8 <page_alloc+0x76>
f0101780:	89 d8                	mov    %ebx,%eax
f0101782:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0101788:	c1 f8 03             	sar    $0x3,%eax
f010178b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010178e:	89 c2                	mov    %eax,%edx
f0101790:	c1 ea 0c             	shr    $0xc,%edx
f0101793:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0101799:	72 20                	jb     f01017bb <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010179b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010179f:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01017a6:	f0 
f01017a7:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01017ae:	00 
f01017af:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
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
f01017d3:	e8 d9 4c 00 00       	call   f01064b1 <memset>
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
f01017ed:	c7 44 24 08 b0 7b 10 	movl   $0xf0107bb0,0x8(%esp)
f01017f4:	f0 
f01017f5:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f01017fc:	00 
f01017fd:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101804:	e8 37 e8 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0101809:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f010180f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101811:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
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
f0101871:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
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
f010188e:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0101894:	72 20                	jb     f01018b6 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101896:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010189a:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01018a1:	f0 
f01018a2:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
f01018a9:	00 
f01018aa:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0101980:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0101986:	72 1c                	jb     f01019a4 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101988:	c7 44 24 08 d4 7b 10 	movl   $0xf0107bd4,0x8(%esp)
f010198f:	f0 
f0101990:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101997:	00 
f0101998:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f010199f:	e8 9c e6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01019a4:	c1 e0 03             	shl    $0x3,%eax
f01019a7:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
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
f01019c7:	e8 74 51 00 00       	call   f0106b40 <cpunum>
f01019cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01019cf:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01019d6:	74 16                	je     f01019ee <tlb_invalidate+0x2d>
f01019d8:	e8 63 51 00 00       	call   f0106b40 <cpunum>
f01019dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01019e0:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
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
f0101a85:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
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
f0101ac2:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
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
f0101b10:	8b 15 04 33 12 f0    	mov    0xf0123304,%edx
f0101b16:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0101b19:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101b1f:	76 1c                	jbe    f0101b3d <mmio_map_region+0x4d>
    	panic("not enough memory");
f0101b21:	c7 44 24 08 b8 84 10 	movl   $0xf01084b8,0x8(%esp)
f0101b28:	f0 
f0101b29:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101b30:	00 
f0101b31:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101b38:	e8 03 e5 ff ff       	call   f0100040 <_panic>
    
    boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101b3d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101b44:	00 
f0101b45:	89 04 24             	mov    %eax,(%esp)
f0101b48:	89 d9                	mov    %ebx,%ecx
f0101b4a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101b4f:	e8 87 fd ff ff       	call   f01018db <boot_map_region>
    
    base += size;
f0101b54:	a1 04 33 12 f0       	mov    0xf0123304,%eax
f0101b59:	01 c3                	add    %eax,%ebx
f0101b5b:	89 1d 04 33 12 f0    	mov    %ebx,0xf0123304
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
f0101b8b:	a3 38 c2 22 f0       	mov    %eax,0xf022c238
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
f0101bb5:	89 15 88 ce 22 f0    	mov    %edx,0xf022ce88
f0101bbb:	eb 0c                	jmp    f0101bc9 <mem_init+0x62>
	else
		npages = npages_basemem;
f0101bbd:	8b 15 38 c2 22 f0    	mov    0xf022c238,%edx
f0101bc3:	89 15 88 ce 22 f0    	mov    %edx,0xf022ce88

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
f0101bd3:	a1 38 c2 22 f0       	mov    0xf022c238,%eax
f0101bd8:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bdb:	c1 e8 0a             	shr    $0xa,%eax
f0101bde:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101be2:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f0101be7:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bea:	c1 e8 0a             	shr    $0xa,%eax
f0101bed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bf1:	c7 04 24 f4 7b 10 f0 	movl   $0xf0107bf4,(%esp)
f0101bf8:	e8 fd 29 00 00       	call   f01045fa <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101bfd:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101c02:	e8 fa f5 ff ff       	call   f0101201 <boot_alloc>
f0101c07:	a3 8c ce 22 f0       	mov    %eax,0xf022ce8c
	memset(kern_pgdir, 0, PGSIZE);
f0101c0c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c13:	00 
f0101c14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c1b:	00 
f0101c1c:	89 04 24             	mov    %eax,(%esp)
f0101c1f:	e8 8d 48 00 00       	call   f01064b1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c24:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101c29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c2e:	77 20                	ja     f0101c50 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c34:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0101c3b:	f0 
f0101c3c:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
f0101c43:	00 
f0101c44:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0101c5f:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f0101c64:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f0101c67:	e8 95 f5 ff ff       	call   f0101201 <boot_alloc>
f0101c6c:	a3 90 ce 22 f0       	mov    %eax,0xf022ce90
	
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0101c71:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101c76:	e8 86 f5 ff ff       	call   f0101201 <boot_alloc>
f0101c7b:	a3 48 c2 22 f0       	mov    %eax,0xf022c248
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
f0101c8f:	83 3d 90 ce 22 f0 00 	cmpl   $0x0,0xf022ce90
f0101c96:	75 1c                	jne    f0101cb4 <mem_init+0x14d>
		panic("'pages' is a null pointer!");
f0101c98:	c7 44 24 08 ca 84 10 	movl   $0xf01084ca,0x8(%esp)
f0101c9f:	f0 
f0101ca0:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101ca7:	00 
f0101ca8:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101caf:	e8 8c e3 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cb4:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
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
f0101cdd:	c7 44 24 0c e5 84 10 	movl   $0xf01084e5,0xc(%esp)
f0101ce4:	f0 
f0101ce5:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101cec:	f0 
f0101ced:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101cf4:	00 
f0101cf5:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101cfc:	e8 3f e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d08:	e8 55 fa ff ff       	call   f0101762 <page_alloc>
f0101d0d:	89 c7                	mov    %eax,%edi
f0101d0f:	85 c0                	test   %eax,%eax
f0101d11:	75 24                	jne    f0101d37 <mem_init+0x1d0>
f0101d13:	c7 44 24 0c fb 84 10 	movl   $0xf01084fb,0xc(%esp)
f0101d1a:	f0 
f0101d1b:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101d2a:	00 
f0101d2b:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101d32:	e8 09 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d3e:	e8 1f fa ff ff       	call   f0101762 <page_alloc>
f0101d43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d46:	85 c0                	test   %eax,%eax
f0101d48:	75 24                	jne    f0101d6e <mem_init+0x207>
f0101d4a:	c7 44 24 0c 11 85 10 	movl   $0xf0108511,0xc(%esp)
f0101d51:	f0 
f0101d52:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101d59:	f0 
f0101d5a:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101d61:	00 
f0101d62:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101d69:	e8 d2 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d6e:	39 fe                	cmp    %edi,%esi
f0101d70:	75 24                	jne    f0101d96 <mem_init+0x22f>
f0101d72:	c7 44 24 0c 27 85 10 	movl   $0xf0108527,0xc(%esp)
f0101d79:	f0 
f0101d7a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101d81:	f0 
f0101d82:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101d89:	00 
f0101d8a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101d91:	e8 aa e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d96:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d99:	74 05                	je     f0101da0 <mem_init+0x239>
f0101d9b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d9e:	75 24                	jne    f0101dc4 <mem_init+0x25d>
f0101da0:	c7 44 24 0c 30 7c 10 	movl   $0xf0107c30,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101dbf:	e8 7c e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dc4:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101dca:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f0101dcf:	c1 e0 0c             	shl    $0xc,%eax
f0101dd2:	89 f1                	mov    %esi,%ecx
f0101dd4:	29 d1                	sub    %edx,%ecx
f0101dd6:	c1 f9 03             	sar    $0x3,%ecx
f0101dd9:	c1 e1 0c             	shl    $0xc,%ecx
f0101ddc:	39 c1                	cmp    %eax,%ecx
f0101dde:	72 24                	jb     f0101e04 <mem_init+0x29d>
f0101de0:	c7 44 24 0c 39 85 10 	movl   $0xf0108539,0xc(%esp)
f0101de7:	f0 
f0101de8:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101def:	f0 
f0101df0:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101df7:	00 
f0101df8:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101dff:	e8 3c e2 ff ff       	call   f0100040 <_panic>
f0101e04:	89 f9                	mov    %edi,%ecx
f0101e06:	29 d1                	sub    %edx,%ecx
f0101e08:	c1 f9 03             	sar    $0x3,%ecx
f0101e0b:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101e0e:	39 c8                	cmp    %ecx,%eax
f0101e10:	77 24                	ja     f0101e36 <mem_init+0x2cf>
f0101e12:	c7 44 24 0c 56 85 10 	movl   $0xf0108556,0xc(%esp)
f0101e19:	f0 
f0101e1a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101e21:	f0 
f0101e22:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101e29:	00 
f0101e2a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101e31:	e8 0a e2 ff ff       	call   f0100040 <_panic>
f0101e36:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e39:	29 d1                	sub    %edx,%ecx
f0101e3b:	89 ca                	mov    %ecx,%edx
f0101e3d:	c1 fa 03             	sar    $0x3,%edx
f0101e40:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e43:	39 d0                	cmp    %edx,%eax
f0101e45:	77 24                	ja     f0101e6b <mem_init+0x304>
f0101e47:	c7 44 24 0c 73 85 10 	movl   $0xf0108573,0xc(%esp)
f0101e4e:	f0 
f0101e4f:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101e56:	f0 
f0101e57:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101e5e:	00 
f0101e5f:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101e66:	e8 d5 e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e6b:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f0101e70:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101e73:	c7 05 40 c2 22 f0 00 	movl   $0x0,0xf022c240
f0101e7a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e84:	e8 d9 f8 ff ff       	call   f0101762 <page_alloc>
f0101e89:	85 c0                	test   %eax,%eax
f0101e8b:	74 24                	je     f0101eb1 <mem_init+0x34a>
f0101e8d:	c7 44 24 0c 90 85 10 	movl   $0xf0108590,0xc(%esp)
f0101e94:	f0 
f0101e95:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101e9c:	f0 
f0101e9d:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101ea4:	00 
f0101ea5:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0101ede:	c7 44 24 0c e5 84 10 	movl   $0xf01084e5,0xc(%esp)
f0101ee5:	f0 
f0101ee6:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101eed:	f0 
f0101eee:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101ef5:	00 
f0101ef6:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101efd:	e8 3e e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f09:	e8 54 f8 ff ff       	call   f0101762 <page_alloc>
f0101f0e:	89 c7                	mov    %eax,%edi
f0101f10:	85 c0                	test   %eax,%eax
f0101f12:	75 24                	jne    f0101f38 <mem_init+0x3d1>
f0101f14:	c7 44 24 0c fb 84 10 	movl   $0xf01084fb,0xc(%esp)
f0101f1b:	f0 
f0101f1c:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101f2b:	00 
f0101f2c:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101f33:	e8 08 e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f3f:	e8 1e f8 ff ff       	call   f0101762 <page_alloc>
f0101f44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f47:	85 c0                	test   %eax,%eax
f0101f49:	75 24                	jne    f0101f6f <mem_init+0x408>
f0101f4b:	c7 44 24 0c 11 85 10 	movl   $0xf0108511,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101f6a:	e8 d1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f6f:	39 fe                	cmp    %edi,%esi
f0101f71:	75 24                	jne    f0101f97 <mem_init+0x430>
f0101f73:	c7 44 24 0c 27 85 10 	movl   $0xf0108527,0xc(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101f82:	f0 
f0101f83:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101f8a:	00 
f0101f8b:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101f92:	e8 a9 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f97:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101f9a:	74 05                	je     f0101fa1 <mem_init+0x43a>
f0101f9c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101f9f:	75 24                	jne    f0101fc5 <mem_init+0x45e>
f0101fa1:	c7 44 24 0c 30 7c 10 	movl   $0xf0107c30,0xc(%esp)
f0101fa8:	f0 
f0101fa9:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101fb0:	f0 
f0101fb1:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101fb8:	00 
f0101fb9:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101fc0:	e8 7b e0 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fcc:	e8 91 f7 ff ff       	call   f0101762 <page_alloc>
f0101fd1:	85 c0                	test   %eax,%eax
f0101fd3:	74 24                	je     f0101ff9 <mem_init+0x492>
f0101fd5:	c7 44 24 0c 90 85 10 	movl   $0xf0108590,0xc(%esp)
f0101fdc:	f0 
f0101fdd:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0101fe4:	f0 
f0101fe5:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101fec:	00 
f0101fed:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0101ff4:	e8 47 e0 ff ff       	call   f0100040 <_panic>
f0101ff9:	89 f0                	mov    %esi,%eax
f0101ffb:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0102001:	c1 f8 03             	sar    $0x3,%eax
f0102004:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102007:	89 c2                	mov    %eax,%edx
f0102009:	c1 ea 0c             	shr    $0xc,%edx
f010200c:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0102012:	72 20                	jb     f0102034 <mem_init+0x4cd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102014:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102018:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f010201f:	f0 
f0102020:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102027:	00 
f0102028:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
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
f010204c:	e8 60 44 00 00       	call   f01064b1 <memset>
	page_free(pp0);
f0102051:	89 34 24             	mov    %esi,(%esp)
f0102054:	e8 87 f7 ff ff       	call   f01017e0 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102059:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102060:	e8 fd f6 ff ff       	call   f0101762 <page_alloc>
f0102065:	85 c0                	test   %eax,%eax
f0102067:	75 24                	jne    f010208d <mem_init+0x526>
f0102069:	c7 44 24 0c 9f 85 10 	movl   $0xf010859f,0xc(%esp)
f0102070:	f0 
f0102071:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102078:	f0 
f0102079:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102080:	00 
f0102081:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102088:	e8 b3 df ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010208d:	39 c6                	cmp    %eax,%esi
f010208f:	74 24                	je     f01020b5 <mem_init+0x54e>
f0102091:	c7 44 24 0c bd 85 10 	movl   $0xf01085bd,0xc(%esp)
f0102098:	f0 
f0102099:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01020a0:	f0 
f01020a1:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f01020a8:	00 
f01020a9:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01020b0:	e8 8b df ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020b5:	89 f2                	mov    %esi,%edx
f01020b7:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01020bd:	c1 fa 03             	sar    $0x3,%edx
f01020c0:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020c3:	89 d0                	mov    %edx,%eax
f01020c5:	c1 e8 0c             	shr    $0xc,%eax
f01020c8:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01020ce:	72 20                	jb     f01020f0 <mem_init+0x589>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01020d4:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01020db:	f0 
f01020dc:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01020e3:	00 
f01020e4:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
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
f010210a:	c7 44 24 0c cd 85 10 	movl   $0xf01085cd,0xc(%esp)
f0102111:	f0 
f0102112:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102119:	f0 
f010211a:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102121:	00 
f0102122:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0102138:	89 15 40 c2 22 f0    	mov    %edx,0xf022c240

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
f0102159:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
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
f010216f:	c7 44 24 0c d7 85 10 	movl   $0xf01085d7,0xc(%esp)
f0102176:	f0 
f0102177:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010217e:	f0 
f010217f:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102186:	00 
f0102187:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010218e:	e8 ad de ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102193:	c7 04 24 50 7c 10 f0 	movl   $0xf0107c50,(%esp)
f010219a:	e8 5b 24 00 00       	call   f01045fa <cprintf>
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
f01021b1:	c7 44 24 0c e5 84 10 	movl   $0xf01084e5,0xc(%esp)
f01021b8:	f0 
f01021b9:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01021c0:	f0 
f01021c1:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01021c8:	00 
f01021c9:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01021d0:	e8 6b de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021dc:	e8 81 f5 ff ff       	call   f0101762 <page_alloc>
f01021e1:	89 c7                	mov    %eax,%edi
f01021e3:	85 c0                	test   %eax,%eax
f01021e5:	75 24                	jne    f010220b <mem_init+0x6a4>
f01021e7:	c7 44 24 0c fb 84 10 	movl   $0xf01084fb,0xc(%esp)
f01021ee:	f0 
f01021ef:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01021f6:	f0 
f01021f7:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01021fe:	00 
f01021ff:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102206:	e8 35 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010220b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102212:	e8 4b f5 ff ff       	call   f0101762 <page_alloc>
f0102217:	89 c3                	mov    %eax,%ebx
f0102219:	85 c0                	test   %eax,%eax
f010221b:	75 24                	jne    f0102241 <mem_init+0x6da>
f010221d:	c7 44 24 0c 11 85 10 	movl   $0xf0108511,0xc(%esp)
f0102224:	f0 
f0102225:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010222c:	f0 
f010222d:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102234:	00 
f0102235:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010223c:	e8 ff dd ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102241:	39 fe                	cmp    %edi,%esi
f0102243:	75 24                	jne    f0102269 <mem_init+0x702>
f0102245:	c7 44 24 0c 27 85 10 	movl   $0xf0108527,0xc(%esp)
f010224c:	f0 
f010224d:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102254:	f0 
f0102255:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f010225c:	00 
f010225d:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102264:	e8 d7 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102269:	39 c7                	cmp    %eax,%edi
f010226b:	74 04                	je     f0102271 <mem_init+0x70a>
f010226d:	39 c6                	cmp    %eax,%esi
f010226f:	75 24                	jne    f0102295 <mem_init+0x72e>
f0102271:	c7 44 24 0c 30 7c 10 	movl   $0xf0107c30,0xc(%esp)
f0102278:	f0 
f0102279:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102280:	f0 
f0102281:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102288:	00 
f0102289:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102290:	e8 ab dd ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102295:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f010229b:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010229e:	c7 05 40 c2 22 f0 00 	movl   $0x0,0xf022c240
f01022a5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01022a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022af:	e8 ae f4 ff ff       	call   f0101762 <page_alloc>
f01022b4:	85 c0                	test   %eax,%eax
f01022b6:	74 24                	je     f01022dc <mem_init+0x775>
f01022b8:	c7 44 24 0c 90 85 10 	movl   $0xf0108590,0xc(%esp)
f01022bf:	f0 
f01022c0:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01022c7:	f0 
f01022c8:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01022cf:	00 
f01022d0:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01022d7:	e8 64 dd ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01022df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022ea:	00 
f01022eb:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01022f0:	89 04 24             	mov    %eax,(%esp)
f01022f3:	e8 51 f6 ff ff       	call   f0101949 <page_lookup>
f01022f8:	85 c0                	test   %eax,%eax
f01022fa:	74 24                	je     f0102320 <mem_init+0x7b9>
f01022fc:	c7 44 24 0c 70 7c 10 	movl   $0xf0107c70,0xc(%esp)
f0102303:	f0 
f0102304:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010230b:	f0 
f010230c:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102313:	00 
f0102314:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010231b:	e8 20 dd ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102320:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102327:	00 
f0102328:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010232f:	00 
f0102330:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102334:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102339:	89 04 24             	mov    %eax,(%esp)
f010233c:	e8 05 f7 ff ff       	call   f0101a46 <page_insert>
f0102341:	85 c0                	test   %eax,%eax
f0102343:	78 24                	js     f0102369 <mem_init+0x802>
f0102345:	c7 44 24 0c a8 7c 10 	movl   $0xf0107ca8,0xc(%esp)
f010234c:	f0 
f010234d:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102354:	f0 
f0102355:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f010235c:	00 
f010235d:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0102385:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010238a:	89 04 24             	mov    %eax,(%esp)
f010238d:	e8 b4 f6 ff ff       	call   f0101a46 <page_insert>
f0102392:	85 c0                	test   %eax,%eax
f0102394:	74 24                	je     f01023ba <mem_init+0x853>
f0102396:	c7 44 24 0c d8 7c 10 	movl   $0xf0107cd8,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01023b5:	e8 86 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023ba:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f01023c0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023c3:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f01023c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023cb:	8b 11                	mov    (%ecx),%edx
f01023cd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01023d3:	89 f0                	mov    %esi,%eax
f01023d5:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01023d8:	c1 f8 03             	sar    $0x3,%eax
f01023db:	c1 e0 0c             	shl    $0xc,%eax
f01023de:	39 c2                	cmp    %eax,%edx
f01023e0:	74 24                	je     f0102406 <mem_init+0x89f>
f01023e2:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f01023e9:	f0 
f01023ea:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01023f1:	f0 
f01023f2:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f01023f9:	00 
f01023fa:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0102422:	c7 44 24 0c 30 7d 10 	movl   $0xf0107d30,0xc(%esp)
f0102429:	f0 
f010242a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102431:	f0 
f0102432:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102439:	00 
f010243a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102446:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010244b:	74 24                	je     f0102471 <mem_init+0x90a>
f010244d:	c7 44 24 0c e2 85 10 	movl   $0xf01085e2,0xc(%esp)
f0102454:	f0 
f0102455:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010245c:	f0 
f010245d:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0102464:	00 
f0102465:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010246c:	e8 cf db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102471:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102476:	74 24                	je     f010249c <mem_init+0x935>
f0102478:	c7 44 24 0c f3 85 10 	movl   $0xf01085f3,0xc(%esp)
f010247f:	f0 
f0102480:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102487:	f0 
f0102488:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f010248f:	00 
f0102490:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f01024bf:	c7 44 24 0c 60 7d 10 	movl   $0xf0107d60,0xc(%esp)
f01024c6:	f0 
f01024c7:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01024ce:	f0 
f01024cf:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01024d6:	00 
f01024d7:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01024de:	e8 5d db ff ff       	call   f0100040 <_panic>

	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024e3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e8:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01024ed:	e8 9e ec ff ff       	call   f0101190 <check_va2pa>
f01024f2:	89 da                	mov    %ebx,%edx
f01024f4:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01024fa:	c1 fa 03             	sar    $0x3,%edx
f01024fd:	c1 e2 0c             	shl    $0xc,%edx
f0102500:	39 d0                	cmp    %edx,%eax
f0102502:	74 24                	je     f0102528 <mem_init+0x9c1>
f0102504:	c7 44 24 0c 9c 7d 10 	movl   $0xf0107d9c,0xc(%esp)
f010250b:	f0 
f010250c:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102513:	f0 
f0102514:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f010251b:	00 
f010251c:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102523:	e8 18 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102528:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010252d:	74 24                	je     f0102553 <mem_init+0x9ec>
f010252f:	c7 44 24 0c 04 86 10 	movl   $0xf0108604,0xc(%esp)
f0102536:	f0 
f0102537:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010253e:	f0 
f010253f:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102546:	00 
f0102547:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010254e:	e8 ed da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102553:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010255a:	e8 03 f2 ff ff       	call   f0101762 <page_alloc>
f010255f:	85 c0                	test   %eax,%eax
f0102561:	74 24                	je     f0102587 <mem_init+0xa20>
f0102563:	c7 44 24 0c 90 85 10 	movl   $0xf0108590,0xc(%esp)
f010256a:	f0 
f010256b:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102572:	f0 
f0102573:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f010257a:	00 
f010257b:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102582:	e8 b9 da ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102587:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010258e:	00 
f010258f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102596:	00 
f0102597:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010259b:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01025a0:	89 04 24             	mov    %eax,(%esp)
f01025a3:	e8 9e f4 ff ff       	call   f0101a46 <page_insert>
f01025a8:	85 c0                	test   %eax,%eax
f01025aa:	74 24                	je     f01025d0 <mem_init+0xa69>
f01025ac:	c7 44 24 0c 60 7d 10 	movl   $0xf0107d60,0xc(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f01025c3:	00 
f01025c4:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01025cb:	e8 70 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025d0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025d5:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01025da:	e8 b1 eb ff ff       	call   f0101190 <check_va2pa>
f01025df:	89 da                	mov    %ebx,%edx
f01025e1:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01025e7:	c1 fa 03             	sar    $0x3,%edx
f01025ea:	c1 e2 0c             	shl    $0xc,%edx
f01025ed:	39 d0                	cmp    %edx,%eax
f01025ef:	74 24                	je     f0102615 <mem_init+0xaae>
f01025f1:	c7 44 24 0c 9c 7d 10 	movl   $0xf0107d9c,0xc(%esp)
f01025f8:	f0 
f01025f9:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102600:	f0 
f0102601:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102608:	00 
f0102609:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102610:	e8 2b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102615:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010261a:	74 24                	je     f0102640 <mem_init+0xad9>
f010261c:	c7 44 24 0c 04 86 10 	movl   $0xf0108604,0xc(%esp)
f0102623:	f0 
f0102624:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010262b:	f0 
f010262c:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102633:	00 
f0102634:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010263b:	e8 00 da ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102640:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102647:	e8 16 f1 ff ff       	call   f0101762 <page_alloc>
f010264c:	85 c0                	test   %eax,%eax
f010264e:	74 24                	je     f0102674 <mem_init+0xb0d>
f0102650:	c7 44 24 0c 90 85 10 	movl   $0xf0108590,0xc(%esp)
f0102657:	f0 
f0102658:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010265f:	f0 
f0102660:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0102667:	00 
f0102668:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010266f:	e8 cc d9 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102674:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f010267a:	8b 02                	mov    (%edx),%eax
f010267c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102681:	89 c1                	mov    %eax,%ecx
f0102683:	c1 e9 0c             	shr    $0xc,%ecx
f0102686:	3b 0d 88 ce 22 f0    	cmp    0xf022ce88,%ecx
f010268c:	72 20                	jb     f01026ae <mem_init+0xb47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010268e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102692:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0102699:	f0 
f010269a:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01026a1:	00 
f01026a2:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f01026d8:	c7 44 24 0c cc 7d 10 	movl   $0xf0107dcc,0xc(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01026e7:	f0 
f01026e8:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f01026ef:	00 
f01026f0:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01026f7:	e8 44 d9 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01026fc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102703:	00 
f0102704:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010270b:	00 
f010270c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102710:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102715:	89 04 24             	mov    %eax,(%esp)
f0102718:	e8 29 f3 ff ff       	call   f0101a46 <page_insert>
f010271d:	85 c0                	test   %eax,%eax
f010271f:	74 24                	je     f0102745 <mem_init+0xbde>
f0102721:	c7 44 24 0c 0c 7e 10 	movl   $0xf0107e0c,0xc(%esp)
f0102728:	f0 
f0102729:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102730:	f0 
f0102731:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0102738:	00 
f0102739:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102740:	e8 fb d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102745:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
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
f010275c:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102762:	c1 fa 03             	sar    $0x3,%edx
f0102765:	c1 e2 0c             	shl    $0xc,%edx
f0102768:	39 d0                	cmp    %edx,%eax
f010276a:	74 24                	je     f0102790 <mem_init+0xc29>
f010276c:	c7 44 24 0c 9c 7d 10 	movl   $0xf0107d9c,0xc(%esp)
f0102773:	f0 
f0102774:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010277b:	f0 
f010277c:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102783:	00 
f0102784:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010278b:	e8 b0 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102790:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102795:	74 24                	je     f01027bb <mem_init+0xc54>
f0102797:	c7 44 24 0c 04 86 10 	movl   $0xf0108604,0xc(%esp)
f010279e:	f0 
f010279f:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01027a6:	f0 
f01027a7:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01027ae:	00 
f01027af:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f01027db:	c7 44 24 0c 4c 7e 10 	movl   $0xf0107e4c,0xc(%esp)
f01027e2:	f0 
f01027e3:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01027ea:	f0 
f01027eb:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01027f2:	00 
f01027f3:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01027ff:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102804:	f6 00 04             	testb  $0x4,(%eax)
f0102807:	75 24                	jne    f010282d <mem_init+0xcc6>
f0102809:	c7 44 24 0c 15 86 10 	movl   $0xf0108615,0xc(%esp)
f0102810:	f0 
f0102811:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102818:	f0 
f0102819:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0102820:	00 
f0102821:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f010284d:	c7 44 24 0c 60 7d 10 	movl   $0xf0107d60,0xc(%esp)
f0102854:	f0 
f0102855:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010285c:	f0 
f010285d:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102864:	00 
f0102865:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010286c:	e8 cf d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102871:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102878:	00 
f0102879:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102880:	00 
f0102881:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102886:	89 04 24             	mov    %eax,(%esp)
f0102889:	e8 ad ef ff ff       	call   f010183b <pgdir_walk>
f010288e:	f6 00 02             	testb  $0x2,(%eax)
f0102891:	75 24                	jne    f01028b7 <mem_init+0xd50>
f0102893:	c7 44 24 0c 80 7e 10 	movl   $0xf0107e80,0xc(%esp)
f010289a:	f0 
f010289b:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01028a2:	f0 
f01028a3:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f01028aa:	00 
f01028ab:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01028b2:	e8 89 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028be:	00 
f01028bf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028c6:	00 
f01028c7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01028cc:	89 04 24             	mov    %eax,(%esp)
f01028cf:	e8 67 ef ff ff       	call   f010183b <pgdir_walk>
f01028d4:	f6 00 04             	testb  $0x4,(%eax)
f01028d7:	74 24                	je     f01028fd <mem_init+0xd96>
f01028d9:	c7 44 24 0c b4 7e 10 	movl   $0xf0107eb4,0xc(%esp)
f01028e0:	f0 
f01028e1:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01028e8:	f0 
f01028e9:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f01028f0:	00 
f01028f1:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01028f8:	e8 43 d7 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01028fd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102904:	00 
f0102905:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010290c:	00 
f010290d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102911:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102916:	89 04 24             	mov    %eax,(%esp)
f0102919:	e8 28 f1 ff ff       	call   f0101a46 <page_insert>
f010291e:	85 c0                	test   %eax,%eax
f0102920:	78 24                	js     f0102946 <mem_init+0xddf>
f0102922:	c7 44 24 0c ec 7e 10 	movl   $0xf0107eec,0xc(%esp)
f0102929:	f0 
f010292a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102931:	f0 
f0102932:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102939:	00 
f010293a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102941:	e8 fa d6 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102946:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010294d:	00 
f010294e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102955:	00 
f0102956:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010295a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010295f:	89 04 24             	mov    %eax,(%esp)
f0102962:	e8 df f0 ff ff       	call   f0101a46 <page_insert>
f0102967:	85 c0                	test   %eax,%eax
f0102969:	74 24                	je     f010298f <mem_init+0xe28>
f010296b:	c7 44 24 0c 24 7f 10 	movl   $0xf0107f24,0xc(%esp)
f0102972:	f0 
f0102973:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010297a:	f0 
f010297b:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0102982:	00 
f0102983:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010298a:	e8 b1 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010298f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102996:	00 
f0102997:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010299e:	00 
f010299f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01029a4:	89 04 24             	mov    %eax,(%esp)
f01029a7:	e8 8f ee ff ff       	call   f010183b <pgdir_walk>
f01029ac:	f6 00 04             	testb  $0x4,(%eax)
f01029af:	74 24                	je     f01029d5 <mem_init+0xe6e>
f01029b1:	c7 44 24 0c b4 7e 10 	movl   $0xf0107eb4,0xc(%esp)
f01029b8:	f0 
f01029b9:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01029c0:	f0 
f01029c1:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01029c8:	00 
f01029c9:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01029d0:	e8 6b d6 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01029d5:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01029da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01029e2:	e8 a9 e7 ff ff       	call   f0101190 <check_va2pa>
f01029e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029ea:	89 f8                	mov    %edi,%eax
f01029ec:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f01029f2:	c1 f8 03             	sar    $0x3,%eax
f01029f5:	c1 e0 0c             	shl    $0xc,%eax
f01029f8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01029fb:	74 24                	je     f0102a21 <mem_init+0xeba>
f01029fd:	c7 44 24 0c 60 7f 10 	movl   $0xf0107f60,0xc(%esp)
f0102a04:	f0 
f0102a05:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102a0c:	f0 
f0102a0d:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102a14:	00 
f0102a15:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102a1c:	e8 1f d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a21:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a29:	e8 62 e7 ff ff       	call   f0101190 <check_va2pa>
f0102a2e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a31:	74 24                	je     f0102a57 <mem_init+0xef0>
f0102a33:	c7 44 24 0c 8c 7f 10 	movl   $0xf0107f8c,0xc(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102a4a:	00 
f0102a4b:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102a52:	e8 e9 d5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102a57:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102a5c:	74 24                	je     f0102a82 <mem_init+0xf1b>
f0102a5e:	c7 44 24 0c 2b 86 10 	movl   $0xf010862b,0xc(%esp)
f0102a65:	f0 
f0102a66:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102a6d:	f0 
f0102a6e:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0102a75:	00 
f0102a76:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102a7d:	e8 be d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a82:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a87:	74 24                	je     f0102aad <mem_init+0xf46>
f0102a89:	c7 44 24 0c 3c 86 10 	movl   $0xf010863c,0xc(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102aa0:	00 
f0102aa1:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102aa8:	e8 93 d5 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102aad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ab4:	e8 a9 ec ff ff       	call   f0101762 <page_alloc>
f0102ab9:	85 c0                	test   %eax,%eax
f0102abb:	74 04                	je     f0102ac1 <mem_init+0xf5a>
f0102abd:	39 c3                	cmp    %eax,%ebx
f0102abf:	74 24                	je     f0102ae5 <mem_init+0xf7e>
f0102ac1:	c7 44 24 0c bc 7f 10 	movl   $0xf0107fbc,0xc(%esp)
f0102ac8:	f0 
f0102ac9:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102ad0:	f0 
f0102ad1:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102ad8:	00 
f0102ad9:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102ae0:	e8 5b d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102aec:	00 
f0102aed:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102af2:	89 04 24             	mov    %eax,(%esp)
f0102af5:	e8 fc ee ff ff       	call   f01019f6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102afa:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f0102b00:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102b03:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b0b:	e8 80 e6 ff ff       	call   f0101190 <check_va2pa>
f0102b10:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b13:	74 24                	je     f0102b39 <mem_init+0xfd2>
f0102b15:	c7 44 24 0c e0 7f 10 	movl   $0xf0107fe0,0xc(%esp)
f0102b1c:	f0 
f0102b1d:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102b24:	f0 
f0102b25:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0102b2c:	00 
f0102b2d:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102b34:	e8 07 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b39:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b41:	e8 4a e6 ff ff       	call   f0101190 <check_va2pa>
f0102b46:	89 fa                	mov    %edi,%edx
f0102b48:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102b4e:	c1 fa 03             	sar    $0x3,%edx
f0102b51:	c1 e2 0c             	shl    $0xc,%edx
f0102b54:	39 d0                	cmp    %edx,%eax
f0102b56:	74 24                	je     f0102b7c <mem_init+0x1015>
f0102b58:	c7 44 24 0c 8c 7f 10 	movl   $0xf0107f8c,0xc(%esp)
f0102b5f:	f0 
f0102b60:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102b67:	f0 
f0102b68:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0102b6f:	00 
f0102b70:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102b77:	e8 c4 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102b7c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b81:	74 24                	je     f0102ba7 <mem_init+0x1040>
f0102b83:	c7 44 24 0c e2 85 10 	movl   $0xf01085e2,0xc(%esp)
f0102b8a:	f0 
f0102b8b:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102b92:	f0 
f0102b93:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0102b9a:	00 
f0102b9b:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102ba2:	e8 99 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ba7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bac:	74 24                	je     f0102bd2 <mem_init+0x106b>
f0102bae:	c7 44 24 0c 3c 86 10 	movl   $0xf010863c,0xc(%esp)
f0102bb5:	f0 
f0102bb6:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102bbd:	f0 
f0102bbe:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0102bc5:	00 
f0102bc6:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102bcd:	e8 6e d4 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102bd2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102bd9:	00 
f0102bda:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bdd:	89 0c 24             	mov    %ecx,(%esp)
f0102be0:	e8 11 ee ff ff       	call   f01019f6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102be5:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102bea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102bed:	ba 00 00 00 00       	mov    $0x0,%edx
f0102bf2:	e8 99 e5 ff ff       	call   f0101190 <check_va2pa>
f0102bf7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102bfa:	74 24                	je     f0102c20 <mem_init+0x10b9>
f0102bfc:	c7 44 24 0c e0 7f 10 	movl   $0xf0107fe0,0xc(%esp)
f0102c03:	f0 
f0102c04:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102c0b:	f0 
f0102c0c:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0102c13:	00 
f0102c14:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102c1b:	e8 20 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102c20:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102c25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c28:	e8 63 e5 ff ff       	call   f0101190 <check_va2pa>
f0102c2d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c30:	74 24                	je     f0102c56 <mem_init+0x10ef>
f0102c32:	c7 44 24 0c 04 80 10 	movl   $0xf0108004,0xc(%esp)
f0102c39:	f0 
f0102c3a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102c41:	f0 
f0102c42:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0102c49:	00 
f0102c4a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102c51:	e8 ea d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c56:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c5b:	74 24                	je     f0102c81 <mem_init+0x111a>
f0102c5d:	c7 44 24 0c 4d 86 10 	movl   $0xf010864d,0xc(%esp)
f0102c64:	f0 
f0102c65:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f0102c74:	00 
f0102c75:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102c7c:	e8 bf d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102c81:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c86:	74 24                	je     f0102cac <mem_init+0x1145>
f0102c88:	c7 44 24 0c 3c 86 10 	movl   $0xf010863c,0xc(%esp)
f0102c8f:	f0 
f0102c90:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102c97:	f0 
f0102c98:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102c9f:	00 
f0102ca0:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102ca7:	e8 94 d3 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cb3:	e8 aa ea ff ff       	call   f0101762 <page_alloc>
f0102cb8:	85 c0                	test   %eax,%eax
f0102cba:	74 04                	je     f0102cc0 <mem_init+0x1159>
f0102cbc:	39 c7                	cmp    %eax,%edi
f0102cbe:	74 24                	je     f0102ce4 <mem_init+0x117d>
f0102cc0:	c7 44 24 0c 2c 80 10 	movl   $0xf010802c,0xc(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102ccf:	f0 
f0102cd0:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0102cd7:	00 
f0102cd8:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102cdf:	e8 5c d3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102ce4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ceb:	e8 72 ea ff ff       	call   f0101762 <page_alloc>
f0102cf0:	85 c0                	test   %eax,%eax
f0102cf2:	74 24                	je     f0102d18 <mem_init+0x11b1>
f0102cf4:	c7 44 24 0c 90 85 10 	movl   $0xf0108590,0xc(%esp)
f0102cfb:	f0 
f0102cfc:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102d03:	f0 
f0102d04:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102d0b:	00 
f0102d0c:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102d13:	e8 28 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d18:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102d1d:	8b 08                	mov    (%eax),%ecx
f0102d1f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102d25:	89 f2                	mov    %esi,%edx
f0102d27:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102d2d:	c1 fa 03             	sar    $0x3,%edx
f0102d30:	c1 e2 0c             	shl    $0xc,%edx
f0102d33:	39 d1                	cmp    %edx,%ecx
f0102d35:	74 24                	je     f0102d5b <mem_init+0x11f4>
f0102d37:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f0102d3e:	f0 
f0102d3f:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102d46:	f0 
f0102d47:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102d4e:	00 
f0102d4f:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102d56:	e8 e5 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d61:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d66:	74 24                	je     f0102d8c <mem_init+0x1225>
f0102d68:	c7 44 24 0c f3 85 10 	movl   $0xf01085f3,0xc(%esp)
f0102d6f:	f0 
f0102d70:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102d77:	f0 
f0102d78:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f0102d7f:	00 
f0102d80:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0102daa:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102daf:	89 04 24             	mov    %eax,(%esp)
f0102db2:	e8 84 ea ff ff       	call   f010183b <pgdir_walk>
f0102db7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102dba:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f0102dc0:	8b 51 04             	mov    0x4(%ecx),%edx
f0102dc3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102dc9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dcc:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
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
f0102ded:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0102df4:	f0 
f0102df5:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f0102dfc:	00 
f0102dfd:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102e09:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e0c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102e12:	39 d0                	cmp    %edx,%eax
f0102e14:	74 24                	je     f0102e3a <mem_init+0x12d3>
f0102e16:	c7 44 24 0c 5e 86 10 	movl   $0xf010865e,0xc(%esp)
f0102e1d:	f0 
f0102e1e:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102e25:	f0 
f0102e26:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102e2d:	00 
f0102e2e:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0102e49:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
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
f0102e63:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0102e6a:	f0 
f0102e6b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102e72:	00 
f0102e73:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
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
f0102e97:	e8 15 36 00 00       	call   f01064b1 <memset>
	page_free(pp0);
f0102e9c:	89 34 24             	mov    %esi,(%esp)
f0102e9f:	e8 3c e9 ff ff       	call   f01017e0 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102ea4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102eab:	00 
f0102eac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102eb3:	00 
f0102eb4:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102eb9:	89 04 24             	mov    %eax,(%esp)
f0102ebc:	e8 7a e9 ff ff       	call   f010183b <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ec1:	89 f2                	mov    %esi,%edx
f0102ec3:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102ec9:	c1 fa 03             	sar    $0x3,%edx
f0102ecc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ecf:	89 d0                	mov    %edx,%eax
f0102ed1:	c1 e8 0c             	shr    $0xc,%eax
f0102ed4:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0102eda:	72 20                	jb     f0102efc <mem_init+0x1395>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102edc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ee0:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0102ee7:	f0 
f0102ee8:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102eef:	00 
f0102ef0:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
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
f0102f1f:	c7 44 24 0c 76 86 10 	movl   $0xf0108676,0xc(%esp)
f0102f26:	f0 
f0102f27:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102f2e:	f0 
f0102f2f:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f0102f36:	00 
f0102f37:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0102f4a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102f4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102f55:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102f5b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102f5e:	89 0d 40 c2 22 f0    	mov    %ecx,0xf022c240

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
f0102fbd:	c7 44 24 0c 50 80 10 	movl   $0xf0108050,0xc(%esp)
f0102fc4:	f0 
f0102fc5:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0102fcc:	f0 
f0102fcd:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f0102fd4:	00 
f0102fd5:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0102fdc:	e8 5f d0 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102fe1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102fe7:	76 0e                	jbe    f0102ff7 <mem_init+0x1490>
f0102fe9:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102fef:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102ff5:	76 24                	jbe    f010301b <mem_init+0x14b4>
f0102ff7:	c7 44 24 0c 78 80 10 	movl   $0xf0108078,0xc(%esp)
f0102ffe:	f0 
f0102fff:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103006:	f0 
f0103007:	c7 44 24 04 9e 04 00 	movl   $0x49e,0x4(%esp)
f010300e:	00 
f010300f:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103027:	c7 44 24 0c a0 80 10 	movl   $0xf01080a0,0xc(%esp)
f010302e:	f0 
f010302f:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103036:	f0 
f0103037:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f010303e:	00 
f010303f:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103046:	e8 f5 cf ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010304b:	39 c6                	cmp    %eax,%esi
f010304d:	73 24                	jae    f0103073 <mem_init+0x150c>
f010304f:	c7 44 24 0c 8d 86 10 	movl   $0xf010868d,0xc(%esp)
f0103056:	f0 
f0103057:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010305e:	f0 
f010305f:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f0103066:	00 
f0103067:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010306e:	e8 cd cf ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103073:	8b 3d 8c ce 22 f0    	mov    0xf022ce8c,%edi
f0103079:	89 da                	mov    %ebx,%edx
f010307b:	89 f8                	mov    %edi,%eax
f010307d:	e8 0e e1 ff ff       	call   f0101190 <check_va2pa>
f0103082:	85 c0                	test   %eax,%eax
f0103084:	74 24                	je     f01030aa <mem_init+0x1543>
f0103086:	c7 44 24 0c c8 80 10 	movl   $0xf01080c8,0xc(%esp)
f010308d:	f0 
f010308e:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103095:	f0 
f0103096:	c7 44 24 04 a4 04 00 	movl   $0x4a4,0x4(%esp)
f010309d:	00 
f010309e:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01030a5:	e8 96 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01030aa:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01030b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01030b3:	89 c2                	mov    %eax,%edx
f01030b5:	89 f8                	mov    %edi,%eax
f01030b7:	e8 d4 e0 ff ff       	call   f0101190 <check_va2pa>
f01030bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01030c1:	74 24                	je     f01030e7 <mem_init+0x1580>
f01030c3:	c7 44 24 0c ec 80 10 	movl   $0xf01080ec,0xc(%esp)
f01030ca:	f0 
f01030cb:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01030d2:	f0 
f01030d3:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
f01030da:	00 
f01030db:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01030e2:	e8 59 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01030e7:	89 f2                	mov    %esi,%edx
f01030e9:	89 f8                	mov    %edi,%eax
f01030eb:	e8 a0 e0 ff ff       	call   f0101190 <check_va2pa>
f01030f0:	85 c0                	test   %eax,%eax
f01030f2:	74 24                	je     f0103118 <mem_init+0x15b1>
f01030f4:	c7 44 24 0c 1c 81 10 	movl   $0xf010811c,0xc(%esp)
f01030fb:	f0 
f01030fc:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103103:	f0 
f0103104:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f010310b:	00 
f010310c:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103113:	e8 28 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103118:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010311e:	89 f8                	mov    %edi,%eax
f0103120:	e8 6b e0 ff ff       	call   f0101190 <check_va2pa>
f0103125:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103128:	74 24                	je     f010314e <mem_init+0x15e7>
f010312a:	c7 44 24 0c 40 81 10 	movl   $0xf0108140,0xc(%esp)
f0103131:	f0 
f0103132:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103139:	f0 
f010313a:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
f0103141:	00 
f0103142:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103167:	c7 44 24 0c 6c 81 10 	movl   $0xf010816c,0xc(%esp)
f010316e:	f0 
f010316f:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103176:	f0 
f0103177:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f010317e:	00 
f010317f:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103186:	e8 b5 ce ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010318b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103192:	00 
f0103193:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103197:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010319c:	89 04 24             	mov    %eax,(%esp)
f010319f:	e8 97 e6 ff ff       	call   f010183b <pgdir_walk>
f01031a4:	f6 00 04             	testb  $0x4,(%eax)
f01031a7:	74 24                	je     f01031cd <mem_init+0x1666>
f01031a9:	c7 44 24 0c b0 81 10 	movl   $0xf01081b0,0xc(%esp)
f01031b0:	f0 
f01031b1:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01031b8:	f0 
f01031b9:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f01031c0:	00 
f01031c1:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01031c8:	e8 73 ce ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01031cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031d4:	00 
f01031d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031d9:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01031de:	89 04 24             	mov    %eax,(%esp)
f01031e1:	e8 55 e6 ff ff       	call   f010183b <pgdir_walk>
f01031e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01031ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031f3:	00 
f01031f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01031f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01031fb:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103200:	89 04 24             	mov    %eax,(%esp)
f0103203:	e8 33 e6 ff ff       	call   f010183b <pgdir_walk>
f0103208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010320e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103215:	00 
f0103216:	89 74 24 04          	mov    %esi,0x4(%esp)
f010321a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010321f:	89 04 24             	mov    %eax,(%esp)
f0103222:	e8 14 e6 ff ff       	call   f010183b <pgdir_walk>
f0103227:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010322d:	c7 04 24 9f 86 10 f0 	movl   $0xf010869f,(%esp)
f0103234:	e8 c1 13 00 00       	call   f01045fa <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0103239:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103243:	77 20                	ja     f0103265 <mem_init+0x16fe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103245:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103249:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0103250:	f0 
f0103251:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
f0103258:	00 
f0103259:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103260:	e8 db cd ff ff       	call   f0100040 <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f0103265:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
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
f010328d:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103292:	e8 44 e6 ff ff       	call   f01018db <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(
f0103297:	a1 48 c2 22 f0       	mov    0xf022c248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010329c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032a1:	77 20                	ja     f01032c3 <mem_init+0x175c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032a7:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f01032ae:	f0 
f01032af:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f01032b6:	00 
f01032b7:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01032be:	e8 7d cd ff ff       	call   f0100040 <_panic>
f01032c3:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01032ca:	00 
	return (physaddr_t)kva - KERNBASE;
f01032cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01032d0:	89 04 24             	mov    %eax,(%esp)
f01032d3:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01032d8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01032dd:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01032e2:	e8 f4 e5 ff ff       	call   f01018db <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032e7:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01032ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f1:	77 20                	ja     f0103313 <mem_init+0x17ac>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032f7:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f01032fe:	f0 
f01032ff:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
f0103306:	00 
f0103307:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010330e:	e8 2d cd ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0103313:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010331a:	00 
f010331b:	c7 04 24 00 90 11 00 	movl   $0x119000,(%esp)
f0103322:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103327:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010332c:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
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
f010334f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103354:	e8 82 e5 ff ff       	call   f01018db <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103359:	b8 00 e0 22 f0       	mov    $0xf022e000,%eax
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
f0103377:	b8 00 e0 22 f0       	mov    $0xf022e000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103380:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0103387:	f0 
f0103388:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f010338f:	00 
f0103390:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f01033b4:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
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
f01033d2:	8b 1d 8c ce 22 f0    	mov    0xf022ce8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01033d8:	8b 0d 88 ce 22 f0    	mov    0xf022ce88,%ecx
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
f0103406:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010340c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103412:	77 20                	ja     f0103434 <mem_init+0x18cd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103414:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103418:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f010341f:	f0 
f0103420:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103427:	00 
f0103428:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f010342f:	e8 0c cc ff ff       	call   f0100040 <_panic>
f0103434:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010343b:	39 d0                	cmp    %edx,%eax
f010343d:	74 24                	je     f0103463 <mem_init+0x18fc>
f010343f:	c7 44 24 0c e4 81 10 	movl   $0xf01081e4,0xc(%esp)
f0103446:	f0 
f0103447:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010344e:	f0 
f010344f:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103456:	00 
f0103457:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103486:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010348c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103492:	77 20                	ja     f01034b4 <mem_init+0x194d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103494:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103498:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f010349f:	f0 
f01034a0:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034a7:	00 
f01034a8:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01034af:	e8 8c cb ff ff       	call   f0100040 <_panic>
f01034b4:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01034bb:	39 d0                	cmp    %edx,%eax
f01034bd:	74 24                	je     f01034e3 <mem_init+0x197c>
f01034bf:	c7 44 24 0c 18 82 10 	movl   $0xf0108218,0xc(%esp)
f01034c6:	f0 
f01034c7:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01034ce:	f0 
f01034cf:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034d6:	00 
f01034d7:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103511:	c7 44 24 0c 4c 82 10 	movl   $0xf010824c,0xc(%esp)
f0103518:	f0 
f0103519:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103520:	f0 
f0103521:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0103528:	00 
f0103529:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103530:	e8 0b cb ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103535:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010353b:	39 fe                	cmp    %edi,%esi
f010353d:	72 c1                	jb     f0103500 <mem_init+0x1999>
f010353f:	c7 45 cc 00 e0 22 f0 	movl   $0xf022e000,-0x34(%ebp)
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
f010358b:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0103592:	f0 
f0103593:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010359a:	00 
f010359b:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01035a2:	e8 99 ca ff ff       	call   f0100040 <_panic>
f01035a7:	39 f0                	cmp    %esi,%eax
f01035a9:	74 24                	je     f01035cf <mem_init+0x1a68>
f01035ab:	c7 44 24 0c 74 82 10 	movl   $0xf0108274,0xc(%esp)
f01035b2:	f0 
f01035b3:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01035ba:	f0 
f01035bb:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01035c2:	00 
f01035c3:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f01035fb:	c7 44 24 0c bc 82 10 	movl   $0xf01082bc,0xc(%esp)
f0103602:	f0 
f0103603:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f010360a:	f0 
f010360b:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0103612:	00 
f0103613:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103664:	c7 44 24 0c b8 86 10 	movl   $0xf01086b8,0xc(%esp)
f010366b:	f0 
f010366c:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103673:	f0 
f0103674:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f010367b:	00 
f010367c:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103697:	c7 44 24 0c b8 86 10 	movl   $0xf01086b8,0xc(%esp)
f010369e:	f0 
f010369f:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01036a6:	f0 
f01036a7:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01036ae:	00 
f01036af:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01036b6:	e8 85 c9 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01036bb:	f6 c2 02             	test   $0x2,%dl
f01036be:	75 4e                	jne    f010370e <mem_init+0x1ba7>
f01036c0:	c7 44 24 0c c9 86 10 	movl   $0xf01086c9,0xc(%esp)
f01036c7:	f0 
f01036c8:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01036cf:	f0 
f01036d0:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01036d7:	00 
f01036d8:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01036df:	e8 5c c9 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01036e4:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01036e8:	74 24                	je     f010370e <mem_init+0x1ba7>
f01036ea:	c7 44 24 0c da 86 10 	movl   $0xf01086da,0xc(%esp)
f01036f1:	f0 
f01036f2:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01036f9:	f0 
f01036fa:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0103701:	00 
f0103702:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f010371c:	c7 04 24 e0 82 10 f0 	movl   $0xf01082e0,(%esp)
f0103723:	e8 d2 0e 00 00       	call   f01045fa <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103728:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010372d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103732:	77 20                	ja     f0103754 <mem_init+0x1bed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103734:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103738:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f010373f:	f0 
f0103740:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f0103747:	00 
f0103748:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103786:	c7 44 24 0c e5 84 10 	movl   $0xf01084e5,0xc(%esp)
f010378d:	f0 
f010378e:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103795:	f0 
f0103796:	c7 44 24 04 bf 04 00 	movl   $0x4bf,0x4(%esp)
f010379d:	00 
f010379e:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01037a5:	e8 96 c8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01037aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037b1:	e8 ac df ff ff       	call   f0101762 <page_alloc>
f01037b6:	89 c7                	mov    %eax,%edi
f01037b8:	85 c0                	test   %eax,%eax
f01037ba:	75 24                	jne    f01037e0 <mem_init+0x1c79>
f01037bc:	c7 44 24 0c fb 84 10 	movl   $0xf01084fb,0xc(%esp)
f01037c3:	f0 
f01037c4:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01037cb:	f0 
f01037cc:	c7 44 24 04 c0 04 00 	movl   $0x4c0,0x4(%esp)
f01037d3:	00 
f01037d4:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01037db:	e8 60 c8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01037e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037e7:	e8 76 df ff ff       	call   f0101762 <page_alloc>
f01037ec:	89 c3                	mov    %eax,%ebx
f01037ee:	85 c0                	test   %eax,%eax
f01037f0:	75 24                	jne    f0103816 <mem_init+0x1caf>
f01037f2:	c7 44 24 0c 11 85 10 	movl   $0xf0108511,0xc(%esp)
f01037f9:	f0 
f01037fa:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103801:	f0 
f0103802:	c7 44 24 04 c1 04 00 	movl   $0x4c1,0x4(%esp)
f0103809:	00 
f010380a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f0103820:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103826:	c1 f8 03             	sar    $0x3,%eax
f0103829:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010382c:	89 c2                	mov    %eax,%edx
f010382e:	c1 ea 0c             	shr    $0xc,%edx
f0103831:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103837:	72 20                	jb     f0103859 <mem_init+0x1cf2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103839:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010383d:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0103844:	f0 
f0103845:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f010384c:	00 
f010384d:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f0103854:	e8 e7 c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103859:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103860:	00 
f0103861:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103868:	00 
	return (void *)(pa + KERNBASE);
f0103869:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010386e:	89 04 24             	mov    %eax,(%esp)
f0103871:	e8 3b 2c 00 00       	call   f01064b1 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103876:	89 d8                	mov    %ebx,%eax
f0103878:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f010387e:	c1 f8 03             	sar    $0x3,%eax
f0103881:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103884:	89 c2                	mov    %eax,%edx
f0103886:	c1 ea 0c             	shr    $0xc,%edx
f0103889:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f010388f:	72 20                	jb     f01038b1 <mem_init+0x1d4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103891:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103895:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f010389c:	f0 
f010389d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01038a4:	00 
f01038a5:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f01038ac:	e8 8f c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01038b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038b8:	00 
f01038b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01038c0:	00 
	return (void *)(pa + KERNBASE);
f01038c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038c6:	89 04 24             	mov    %eax,(%esp)
f01038c9:	e8 e3 2b 00 00       	call   f01064b1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01038ce:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01038d5:	00 
f01038d6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038dd:	00 
f01038de:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038e2:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01038e7:	89 04 24             	mov    %eax,(%esp)
f01038ea:	e8 57 e1 ff ff       	call   f0101a46 <page_insert>
	assert(pp1->pp_ref == 1);
f01038ef:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01038f4:	74 24                	je     f010391a <mem_init+0x1db3>
f01038f6:	c7 44 24 0c e2 85 10 	movl   $0xf01085e2,0xc(%esp)
f01038fd:	f0 
f01038fe:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103905:	f0 
f0103906:	c7 44 24 04 c6 04 00 	movl   $0x4c6,0x4(%esp)
f010390d:	00 
f010390e:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103915:	e8 26 c7 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010391a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103921:	01 01 01 
f0103924:	74 24                	je     f010394a <mem_init+0x1de3>
f0103926:	c7 44 24 0c 00 83 10 	movl   $0xf0108300,0xc(%esp)
f010392d:	f0 
f010392e:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103935:	f0 
f0103936:	c7 44 24 04 c7 04 00 	movl   $0x4c7,0x4(%esp)
f010393d:	00 
f010393e:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103945:	e8 f6 c6 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010394a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103951:	00 
f0103952:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103959:	00 
f010395a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010395e:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103963:	89 04 24             	mov    %eax,(%esp)
f0103966:	e8 db e0 ff ff       	call   f0101a46 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010396b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103972:	02 02 02 
f0103975:	74 24                	je     f010399b <mem_init+0x1e34>
f0103977:	c7 44 24 0c 24 83 10 	movl   $0xf0108324,0xc(%esp)
f010397e:	f0 
f010397f:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103986:	f0 
f0103987:	c7 44 24 04 c9 04 00 	movl   $0x4c9,0x4(%esp)
f010398e:	00 
f010398f:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103996:	e8 a5 c6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010399b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01039a0:	74 24                	je     f01039c6 <mem_init+0x1e5f>
f01039a2:	c7 44 24 0c 04 86 10 	movl   $0xf0108604,0xc(%esp)
f01039a9:	f0 
f01039aa:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01039b1:	f0 
f01039b2:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f01039b9:	00 
f01039ba:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f01039c1:	e8 7a c6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01039c6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01039cb:	74 24                	je     f01039f1 <mem_init+0x1e8a>
f01039cd:	c7 44 24 0c 4d 86 10 	movl   $0xf010864d,0xc(%esp)
f01039d4:	f0 
f01039d5:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f01039dc:	f0 
f01039dd:	c7 44 24 04 cb 04 00 	movl   $0x4cb,0x4(%esp)
f01039e4:	00 
f01039e5:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
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
f01039fd:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103a03:	c1 f8 03             	sar    $0x3,%eax
f0103a06:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a09:	89 c2                	mov    %eax,%edx
f0103a0b:	c1 ea 0c             	shr    $0xc,%edx
f0103a0e:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103a14:	72 20                	jb     f0103a36 <mem_init+0x1ecf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a1a:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0103a21:	f0 
f0103a22:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103a29:	00 
f0103a2a:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f0103a31:	e8 0a c6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103a36:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103a3d:	03 03 03 
f0103a40:	74 24                	je     f0103a66 <mem_init+0x1eff>
f0103a42:	c7 44 24 0c 48 83 10 	movl   $0xf0108348,0xc(%esp)
f0103a49:	f0 
f0103a4a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103a51:	f0 
f0103a52:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f0103a59:	00 
f0103a5a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103a61:	e8 da c5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103a66:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103a6d:	00 
f0103a6e:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103a73:	89 04 24             	mov    %eax,(%esp)
f0103a76:	e8 7b df ff ff       	call   f01019f6 <page_remove>
	assert(pp2->pp_ref == 0);
f0103a7b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103a80:	74 24                	je     f0103aa6 <mem_init+0x1f3f>
f0103a82:	c7 44 24 0c 3c 86 10 	movl   $0xf010863c,0xc(%esp)
f0103a89:	f0 
f0103a8a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103a91:	f0 
f0103a92:	c7 44 24 04 cf 04 00 	movl   $0x4cf,0x4(%esp)
f0103a99:	00 
f0103a9a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103aa1:	e8 9a c5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103aa6:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103aab:	8b 08                	mov    (%eax),%ecx
f0103aad:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103ab3:	89 f2                	mov    %esi,%edx
f0103ab5:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0103abb:	c1 fa 03             	sar    $0x3,%edx
f0103abe:	c1 e2 0c             	shl    $0xc,%edx
f0103ac1:	39 d1                	cmp    %edx,%ecx
f0103ac3:	74 24                	je     f0103ae9 <mem_init+0x1f82>
f0103ac5:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f0103acc:	f0 
f0103acd:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103ad4:	f0 
f0103ad5:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
f0103adc:	00 
f0103add:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103ae4:	e8 57 c5 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103ae9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103aef:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103af4:	74 24                	je     f0103b1a <mem_init+0x1fb3>
f0103af6:	c7 44 24 0c f3 85 10 	movl   $0xf01085f3,0xc(%esp)
f0103afd:	f0 
f0103afe:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0103b05:	f0 
f0103b06:	c7 44 24 04 d4 04 00 	movl   $0x4d4,0x4(%esp)
f0103b0d:	00 
f0103b0e:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0103b15:	e8 26 c5 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103b1a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103b20:	89 34 24             	mov    %esi,(%esp)
f0103b23:	e8 b8 dc ff ff       	call   f01017e0 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103b28:	c7 04 24 74 83 10 f0 	movl   $0xf0108374,(%esp)
f0103b2f:	e8 c6 0a 00 00       	call   f01045fa <cprintf>
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
f0103b44:	c7 04 24 00 e0 22 00 	movl   $0x22e000,(%esp)
f0103b4b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103b50:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103b55:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103b5a:	e8 7c dd ff ff       	call   f01018db <boot_map_region>
f0103b5f:	bb 00 60 23 f0       	mov    $0xf0236000,%ebx
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
f0103be7:	89 1d 44 c2 22 f0    	mov    %ebx,0xf022c244
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
f0103c3a:	a1 44 c2 22 f0       	mov    0xf022c244,%eax
f0103c3f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c43:	8b 43 48             	mov    0x48(%ebx),%eax
f0103c46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c4a:	c7 04 24 a0 83 10 f0 	movl   $0xf01083a0,(%esp)
f0103c51:	e8 a4 09 00 00       	call   f01045fa <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103c56:	89 1c 24             	mov    %ebx,(%esp)
f0103c59:	e8 be 06 00 00       	call   f010431c <env_destroy>
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
f0103c9c:	c7 44 24 08 e8 86 10 	movl   $0xf01086e8,0x8(%esp)
f0103ca3:	f0 
f0103ca4:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f0103cab:	00 
f0103cac:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
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
f0103d06:	e8 35 2e 00 00       	call   f0106b40 <cpunum>
f0103d0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0e:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
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
f0103d28:	03 1d 48 c2 22 f0    	add    0xf022c248,%ebx
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
f0103d4a:	e8 f1 2d 00 00       	call   f0106b40 <cpunum>
f0103d4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d52:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0103d58:	74 23                	je     f0103d7d <envid2env+0x94>
f0103d5a:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103d5d:	e8 de 2d 00 00       	call   f0106b40 <cpunum>
f0103d62:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d65:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
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
f0103d94:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
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
f0103dbf:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
f0103dc5:	c7 42 48 00 00 00 00 	movl   $0x0,0x48(%edx)
	env_free_list = envs;
f0103dcc:	89 15 4c c2 22 f0    	mov    %edx,0xf022c24c
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
f0103e01:	8b 1d 4c c2 22 f0    	mov    0xf022c24c,%ebx
f0103e07:	85 db                	test   %ebx,%ebx
f0103e09:	0f 84 8e 01 00 00    	je     f0103f9d <env_alloc+0x1a3>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103e0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103e16:	e8 47 d9 ff ff       	call   f0101762 <page_alloc>
f0103e1b:	85 c0                	test   %eax,%eax
f0103e1d:	0f 84 81 01 00 00    	je     f0103fa4 <env_alloc+0x1aa>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	/*************************** LAB 3: Your code here.***************************/
	p->pp_ref ++;
f0103e23:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103e28:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103e2e:	c1 f8 03             	sar    $0x3,%eax
f0103e31:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e34:	89 c2                	mov    %eax,%edx
f0103e36:	c1 ea 0c             	shr    $0xc,%edx
f0103e39:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103e3f:	72 20                	jb     f0103e61 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e45:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0103e4c:	f0 
f0103e4d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103e54:	00 
f0103e55:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f0103e5c:	e8 df c1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103e61:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0103e66:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103e69:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103e70:	00 
f0103e71:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f0103e77:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e7b:	89 04 24             	mov    %eax,(%esp)
f0103e7e:	e8 02 27 00 00       	call   f0106585 <memcpy>
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
f0103e91:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0103e98:	f0 
f0103e99:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0103ea0:	00 
f0103ea1:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
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
f0103ed3:	2b 15 48 c2 22 f0    	sub    0xf022c248,%edx
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
f0103f15:	e8 97 25 00 00       	call   f01064b1 <memset>
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
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103f39:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103f40:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103f47:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103f4b:	8b 43 44             	mov    0x44(%ebx),%eax
f0103f4e:	a3 4c c2 22 f0       	mov    %eax,0xf022c24c
	*newenv_store = e;
f0103f53:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f56:	89 18                	mov    %ebx,(%eax)

	

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103f58:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103f5b:	e8 e0 2b 00 00       	call   f0106b40 <cpunum>
f0103f60:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f63:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f68:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0103f6f:	74 11                	je     f0103f82 <env_alloc+0x188>
f0103f71:	e8 ca 2b 00 00       	call   f0106b40 <cpunum>
f0103f76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f79:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103f7f:	8b 50 48             	mov    0x48(%eax),%edx
f0103f82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103f86:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f8a:	c7 04 24 08 87 10 f0 	movl   $0xf0108708,(%esp)
f0103f91:	e8 64 06 00 00       	call   f01045fa <cprintf>
	return 0;
f0103f96:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f9b:	eb 0c                	jmp    f0103fa9 <env_alloc+0x1af>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103f9d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103fa2:	eb 05                	jmp    f0103fa9 <env_alloc+0x1af>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103fa4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103fa9:	83 c4 14             	add    $0x14,%esp
f0103fac:	5b                   	pop    %ebx
f0103fad:	5d                   	pop    %ebp
f0103fae:	c3                   	ret    

f0103faf <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103faf:	55                   	push   %ebp
f0103fb0:	89 e5                	mov    %esp,%ebp
f0103fb2:	57                   	push   %edi
f0103fb3:	56                   	push   %esi
f0103fb4:	53                   	push   %ebx
f0103fb5:	83 ec 3c             	sub    $0x3c,%esp
f0103fb8:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int res;
	if ((res = env_alloc(&env, 0)))
f0103fbb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fc2:	00 
f0103fc3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103fc6:	89 04 24             	mov    %eax,(%esp)
f0103fc9:	e8 2c fe ff ff       	call   f0103dfa <env_alloc>
f0103fce:	85 c0                	test   %eax,%eax
f0103fd0:	74 20                	je     f0103ff2 <env_create+0x43>
		panic("env_create: %e", res);
f0103fd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fd6:	c7 44 24 08 1d 87 10 	movl   $0xf010871d,0x8(%esp)
f0103fdd:	f0 
f0103fde:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
f0103fe5:	00 
f0103fe6:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f0103fed:	e8 4e c0 ff ff       	call   f0100040 <_panic>

	load_icode(env, binary, size);
f0103ff2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ff5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
f0103ff8:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103ffe:	74 1c                	je     f010401c <env_create+0x6d>
		panic("Invalid ELF!");
f0104000:	c7 44 24 08 2c 87 10 	movl   $0xf010872c,0x8(%esp)
f0104007:	f0 
f0104008:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f010400f:	00 
f0104010:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f0104017:	e8 24 c0 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010401c:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f010401f:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
f0104023:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104026:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104029:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010402e:	77 20                	ja     f0104050 <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104030:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104034:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f010403b:	f0 
f010403c:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0104043:	00 
f0104044:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f010404b:	e8 f0 bf ff ff       	call   f0100040 <_panic>
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
		panic("Invalid ELF!");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0104050:	01 fb                	add    %edi,%ebx
	eph = ph + elf->e_phnum;
f0104052:	0f b7 f6             	movzwl %si,%esi
f0104055:	c1 e6 05             	shl    $0x5,%esi
f0104058:	01 de                	add    %ebx,%esi
	return (physaddr_t)kva - KERNBASE;
f010405a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010405f:	0f 22 d8             	mov    %eax,%cr3

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f0104062:	39 f3                	cmp    %esi,%ebx
f0104064:	73 4f                	jae    f01040b5 <env_create+0x106>
		if (ph->p_type != ELF_PROG_LOAD)
f0104066:	83 3b 01             	cmpl   $0x1,(%ebx)
f0104069:	75 43                	jne    f01040ae <env_create+0xff>
			continue;
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f010406b:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010406e:	8b 53 08             	mov    0x8(%ebx),%edx
f0104071:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104074:	e8 eb fb ff ff       	call   f0103c64 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f0104079:	8b 43 14             	mov    0x14(%ebx),%eax
f010407c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104080:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104087:	00 
f0104088:	8b 43 08             	mov    0x8(%ebx),%eax
f010408b:	89 04 24             	mov    %eax,(%esp)
f010408e:	e8 1e 24 00 00       	call   f01064b1 <memset>
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0104093:	8b 43 10             	mov    0x10(%ebx),%eax
f0104096:	89 44 24 08          	mov    %eax,0x8(%esp)
f010409a:	89 f8                	mov    %edi,%eax
f010409c:	03 43 04             	add    0x4(%ebx),%eax
f010409f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040a3:	8b 43 08             	mov    0x8(%ebx),%eax
f01040a6:	89 04 24             	mov    %eax,(%esp)
f01040a9:	e8 5e 24 00 00       	call   f010650c <memmove>
	eph = ph + elf->e_phnum;

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f01040ae:	83 c3 20             	add    $0x20,%ebx
f01040b1:	39 de                	cmp    %ebx,%esi
f01040b3:	77 b1                	ja     f0104066 <env_create+0xb7>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
		memset((void*)ph->p_va, 0, ph->p_memsz);
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}
	// switch back to kernel page directory
	lcr3(PADDR(kern_pgdir));
f01040b5:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040bf:	77 20                	ja     f01040e1 <env_create+0x132>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040c5:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f01040cc:	f0 
f01040cd:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f01040d4:	00 
f01040d5:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f01040dc:	e8 5f bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01040e1:	05 00 00 00 10       	add    $0x10000000,%eax
f01040e6:	0f 22 d8             	mov    %eax,%cr3

	(e->env_tf).tf_eip = (uintptr_t)(elf->e_entry);
f01040e9:	8b 47 18             	mov    0x18(%edi),%eax
f01040ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01040ef:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f01040f2:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01040f7:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01040fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040ff:	e8 60 fb ff ff       	call   f0103c64 <region_alloc>
	if ((res = env_alloc(&env, 0)))
		panic("env_create: %e", res);

	load_icode(env, binary, size);

	env->env_type = type;
f0104104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104107:	8b 55 10             	mov    0x10(%ebp),%edx
f010410a:	89 50 50             	mov    %edx,0x50(%eax)
}
f010410d:	83 c4 3c             	add    $0x3c,%esp
f0104110:	5b                   	pop    %ebx
f0104111:	5e                   	pop    %esi
f0104112:	5f                   	pop    %edi
f0104113:	5d                   	pop    %ebp
f0104114:	c3                   	ret    

f0104115 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0104115:	55                   	push   %ebp
f0104116:	89 e5                	mov    %esp,%ebp
f0104118:	57                   	push   %edi
f0104119:	56                   	push   %esi
f010411a:	53                   	push   %ebx
f010411b:	83 ec 2c             	sub    $0x2c,%esp
f010411e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0104121:	e8 1a 2a 00 00       	call   f0106b40 <cpunum>
f0104126:	6b c0 74             	imul   $0x74,%eax,%eax
f0104129:	39 b8 28 d0 22 f0    	cmp    %edi,-0xfdd2fd8(%eax)
f010412f:	75 34                	jne    f0104165 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0104131:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104136:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010413b:	77 20                	ja     f010415d <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010413d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104141:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0104148:	f0 
f0104149:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
f0104150:	00 
f0104151:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f0104158:	e8 e3 be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010415d:	05 00 00 00 10       	add    $0x10000000,%eax
f0104162:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0104165:	8b 5f 48             	mov    0x48(%edi),%ebx
f0104168:	e8 d3 29 00 00       	call   f0106b40 <cpunum>
f010416d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104170:	b8 00 00 00 00       	mov    $0x0,%eax
f0104175:	83 ba 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%edx)
f010417c:	74 11                	je     f010418f <env_free+0x7a>
f010417e:	e8 bd 29 00 00       	call   f0106b40 <cpunum>
f0104183:	6b c0 74             	imul   $0x74,%eax,%eax
f0104186:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010418c:	8b 40 48             	mov    0x48(%eax),%eax
f010418f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104193:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104197:	c7 04 24 39 87 10 f0 	movl   $0xf0108739,(%esp)
f010419e:	e8 57 04 00 00       	call   f01045fa <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01041a3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
//cprintf("*****e->env_pgdir[pdeno]: up to now!\n");
		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01041aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041ad:	c1 e0 02             	shl    $0x2,%eax
f01041b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041b3:	8b 47 60             	mov    0x60(%edi),%eax
f01041b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041b9:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01041bc:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01041c2:	0f 84 b8 00 00 00    	je     f0104280 <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01041c8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01041ce:	89 f0                	mov    %esi,%eax
f01041d0:	c1 e8 0c             	shr    $0xc,%eax
f01041d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01041d6:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01041dc:	72 20                	jb     f01041fe <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01041de:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01041e2:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01041e9:	f0 
f01041ea:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
f01041f1:	00 
f01041f2:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f01041f9:	e8 42 be ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01041fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104201:	c1 e2 16             	shl    $0x16,%edx
f0104204:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104207:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010420c:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0104213:	01 
f0104214:	74 17                	je     f010422d <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104216:	89 d8                	mov    %ebx,%eax
f0104218:	c1 e0 0c             	shl    $0xc,%eax
f010421b:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010421e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104222:	8b 47 60             	mov    0x60(%edi),%eax
f0104225:	89 04 24             	mov    %eax,(%esp)
f0104228:	e8 c9 d7 ff ff       	call   f01019f6 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010422d:	83 c3 01             	add    $0x1,%ebx
f0104230:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104236:	75 d4                	jne    f010420c <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}
//cprintf("*****e table: up to now!\n");
		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104238:	8b 47 60             	mov    0x60(%edi),%eax
f010423b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010423e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104245:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104248:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f010424e:	72 1c                	jb     f010426c <env_free+0x157>
		panic("pa2page called with invalid pa");
f0104250:	c7 44 24 08 d4 7b 10 	movl   $0xf0107bd4,0x8(%esp)
f0104257:	f0 
f0104258:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010425f:	00 
f0104260:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f0104267:	e8 d4 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010426c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010426f:	c1 e0 03             	shl    $0x3,%eax
f0104272:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
		page_decref(pa2page(pa));
f0104278:	89 04 24             	mov    %eax,(%esp)
f010427b:	e8 98 d5 ff ff       	call   f0101818 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104280:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0104284:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010428b:	0f 85 19 ff ff ff    	jne    f01041aa <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}
//cprintf("*****e->env_pgdir: up to now!\n");
	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104291:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104294:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104299:	77 20                	ja     f01042bb <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010429b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010429f:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f01042a6:	f0 
f01042a7:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f01042ae:	00 
f01042af:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f01042b6:	e8 85 bd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01042bb:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01042c2:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01042c7:	c1 e8 0c             	shr    $0xc,%eax
f01042ca:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01042d0:	72 1c                	jb     f01042ee <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f01042d2:	c7 44 24 08 d4 7b 10 	movl   $0xf0107bd4,0x8(%esp)
f01042d9:	f0 
f01042da:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01042e1:	00 
f01042e2:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f01042e9:	e8 52 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01042ee:	c1 e0 03             	shl    $0x3,%eax
f01042f1:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
//cprintf("*****Get into page_decref!\n");
	page_decref(pa2page(pa));
f01042f7:	89 04 24             	mov    %eax,(%esp)
f01042fa:	e8 19 d5 ff ff       	call   f0101818 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01042ff:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104306:	a1 4c c2 22 f0       	mov    0xf022c24c,%eax
f010430b:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010430e:	89 3d 4c c2 22 f0    	mov    %edi,0xf022c24c
}
f0104314:	83 c4 2c             	add    $0x2c,%esp
f0104317:	5b                   	pop    %ebx
f0104318:	5e                   	pop    %esi
f0104319:	5f                   	pop    %edi
f010431a:	5d                   	pop    %ebp
f010431b:	c3                   	ret    

f010431c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010431c:	55                   	push   %ebp
f010431d:	89 e5                	mov    %esp,%ebp
f010431f:	53                   	push   %ebx
f0104320:	83 ec 14             	sub    $0x14,%esp
f0104323:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104326:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010432a:	75 19                	jne    f0104345 <env_destroy+0x29>
f010432c:	e8 0f 28 00 00       	call   f0106b40 <cpunum>
f0104331:	6b c0 74             	imul   $0x74,%eax,%eax
f0104334:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f010433a:	74 09                	je     f0104345 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010433c:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0104343:	eb 3b                	jmp    f0104380 <env_destroy+0x64>
	}
	env_free(e);
f0104345:	89 1c 24             	mov    %ebx,(%esp)
f0104348:	e8 c8 fd ff ff       	call   f0104115 <env_free>

	if (curenv == e) {
f010434d:	e8 ee 27 00 00       	call   f0106b40 <cpunum>
f0104352:	6b c0 74             	imul   $0x74,%eax,%eax
f0104355:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f010435b:	75 23                	jne    f0104380 <env_destroy+0x64>
		curenv = NULL;
f010435d:	e8 de 27 00 00       	call   f0106b40 <cpunum>
f0104362:	6b c0 74             	imul   $0x74,%eax,%eax
f0104365:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f010436c:	00 00 00 
cprintf("****destroy\n");
f010436f:	c7 04 24 4f 87 10 f0 	movl   $0xf010874f,(%esp)
f0104376:	e8 7f 02 00 00       	call   f01045fa <cprintf>
		sched_yield();
f010437b:	e8 a4 0c 00 00       	call   f0105024 <sched_yield>
	}
}
f0104380:	83 c4 14             	add    $0x14,%esp
f0104383:	5b                   	pop    %ebx
f0104384:	5d                   	pop    %ebp
f0104385:	c3                   	ret    

f0104386 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104386:	55                   	push   %ebp
f0104387:	89 e5                	mov    %esp,%ebp
f0104389:	53                   	push   %ebx
f010438a:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010438d:	e8 ae 27 00 00       	call   f0106b40 <cpunum>
f0104392:	6b c0 74             	imul   $0x74,%eax,%eax
f0104395:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
f010439b:	e8 a0 27 00 00       	call   f0106b40 <cpunum>
f01043a0:	89 43 5c             	mov    %eax,0x5c(%ebx)
//cprintf("**Start transfering\n");

	__asm __volatile("movl %0,%%esp\n"
f01043a3:	8b 65 08             	mov    0x8(%ebp),%esp
f01043a6:	61                   	popa   
f01043a7:	07                   	pop    %es
f01043a8:	1f                   	pop    %ds
f01043a9:	83 c4 08             	add    $0x8,%esp
f01043ac:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01043ad:	c7 44 24 08 5c 87 10 	movl   $0xf010875c,0x8(%esp)
f01043b4:	f0 
f01043b5:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
f01043bc:	00 
f01043bd:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f01043c4:	e8 77 bc ff ff       	call   f0100040 <_panic>

f01043c9 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01043c9:	55                   	push   %ebp
f01043ca:	89 e5                	mov    %esp,%ebp
f01043cc:	53                   	push   %ebx
f01043cd:	83 ec 14             	sub    $0x14,%esp
f01043d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f01043d3:	e8 68 27 00 00       	call   f0106b40 <cpunum>
f01043d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043db:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f01043e1:	0f 84 85 00 00 00    	je     f010446c <env_run+0xa3>
		if (curenv && curenv->env_status == ENV_RUNNING)
f01043e7:	e8 54 27 00 00       	call   f0106b40 <cpunum>
f01043ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ef:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01043f6:	74 29                	je     f0104421 <env_run+0x58>
f01043f8:	e8 43 27 00 00       	call   f0106b40 <cpunum>
f01043fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104400:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104406:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010440a:	75 15                	jne    f0104421 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f010440c:	e8 2f 27 00 00       	call   f0106b40 <cpunum>
f0104411:	6b c0 74             	imul   $0x74,%eax,%eax
f0104414:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010441a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0104421:	e8 1a 27 00 00       	call   f0106b40 <cpunum>
f0104426:	6b c0 74             	imul   $0x74,%eax,%eax
f0104429:	89 98 28 d0 22 f0    	mov    %ebx,-0xfdd2fd8(%eax)
		e->env_status = ENV_RUNNING;
f010442f:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0104436:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f010443a:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010443d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104442:	77 20                	ja     f0104464 <env_run+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104444:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104448:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f010444f:	f0 
f0104450:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
f0104457:	00 
f0104458:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f010445f:	e8 dc bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104464:	05 00 00 00 10       	add    $0x10000000,%eax
f0104469:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010446c:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104473:	e8 3b 2a 00 00       	call   f0106eb3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104478:	f3 90                	pause  
	}

	unlock_kernel();

	env_pop_tf(&(curenv->env_tf));
f010447a:	e8 c1 26 00 00       	call   f0106b40 <cpunum>
f010447f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104482:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104488:	89 04 24             	mov    %eax,(%esp)
f010448b:	e8 f6 fe ff ff       	call   f0104386 <env_pop_tf>

f0104490 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104490:	55                   	push   %ebp
f0104491:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104493:	ba 70 00 00 00       	mov    $0x70,%edx
f0104498:	8b 45 08             	mov    0x8(%ebp),%eax
f010449b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010449c:	b2 71                	mov    $0x71,%dl
f010449e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010449f:	0f b6 c0             	movzbl %al,%eax
}
f01044a2:	5d                   	pop    %ebp
f01044a3:	c3                   	ret    

f01044a4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01044a4:	55                   	push   %ebp
f01044a5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01044a7:	ba 70 00 00 00       	mov    $0x70,%edx
f01044ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01044af:	ee                   	out    %al,(%dx)
f01044b0:	b2 71                	mov    $0x71,%dl
f01044b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044b5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01044b6:	5d                   	pop    %ebp
f01044b7:	c3                   	ret    

f01044b8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01044b8:	55                   	push   %ebp
f01044b9:	89 e5                	mov    %esp,%ebp
f01044bb:	56                   	push   %esi
f01044bc:	53                   	push   %ebx
f01044bd:	83 ec 10             	sub    $0x10,%esp
f01044c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01044c3:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01044c5:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f01044cb:	80 3d 50 c2 22 f0 00 	cmpb   $0x0,0xf022c250
f01044d2:	74 4e                	je     f0104522 <irq_setmask_8259A+0x6a>
f01044d4:	ba 21 00 00 00       	mov    $0x21,%edx
f01044d9:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01044da:	89 f0                	mov    %esi,%eax
f01044dc:	66 c1 e8 08          	shr    $0x8,%ax
f01044e0:	b2 a1                	mov    $0xa1,%dl
f01044e2:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01044e3:	c7 04 24 68 87 10 f0 	movl   $0xf0108768,(%esp)
f01044ea:	e8 0b 01 00 00       	call   f01045fa <cprintf>
	for (i = 0; i < 16; i++)
f01044ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01044f4:	0f b7 f6             	movzwl %si,%esi
f01044f7:	f7 d6                	not    %esi
f01044f9:	0f a3 de             	bt     %ebx,%esi
f01044fc:	73 10                	jae    f010450e <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f01044fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104502:	c7 04 24 33 8c 10 f0 	movl   $0xf0108c33,(%esp)
f0104509:	e8 ec 00 00 00       	call   f01045fa <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010450e:	83 c3 01             	add    $0x1,%ebx
f0104511:	83 fb 10             	cmp    $0x10,%ebx
f0104514:	75 e3                	jne    f01044f9 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104516:	c7 04 24 b6 86 10 f0 	movl   $0xf01086b6,(%esp)
f010451d:	e8 d8 00 00 00       	call   f01045fa <cprintf>
}
f0104522:	83 c4 10             	add    $0x10,%esp
f0104525:	5b                   	pop    %ebx
f0104526:	5e                   	pop    %esi
f0104527:	5d                   	pop    %ebp
f0104528:	c3                   	ret    

f0104529 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104529:	55                   	push   %ebp
f010452a:	89 e5                	mov    %esp,%ebp
f010452c:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010452f:	c6 05 50 c2 22 f0 01 	movb   $0x1,0xf022c250
f0104536:	ba 21 00 00 00       	mov    $0x21,%edx
f010453b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104540:	ee                   	out    %al,(%dx)
f0104541:	b2 a1                	mov    $0xa1,%dl
f0104543:	ee                   	out    %al,(%dx)
f0104544:	b2 20                	mov    $0x20,%dl
f0104546:	b8 11 00 00 00       	mov    $0x11,%eax
f010454b:	ee                   	out    %al,(%dx)
f010454c:	b2 21                	mov    $0x21,%dl
f010454e:	b8 20 00 00 00       	mov    $0x20,%eax
f0104553:	ee                   	out    %al,(%dx)
f0104554:	b8 04 00 00 00       	mov    $0x4,%eax
f0104559:	ee                   	out    %al,(%dx)
f010455a:	b8 03 00 00 00       	mov    $0x3,%eax
f010455f:	ee                   	out    %al,(%dx)
f0104560:	b2 a0                	mov    $0xa0,%dl
f0104562:	b8 11 00 00 00       	mov    $0x11,%eax
f0104567:	ee                   	out    %al,(%dx)
f0104568:	b2 a1                	mov    $0xa1,%dl
f010456a:	b8 28 00 00 00       	mov    $0x28,%eax
f010456f:	ee                   	out    %al,(%dx)
f0104570:	b8 02 00 00 00       	mov    $0x2,%eax
f0104575:	ee                   	out    %al,(%dx)
f0104576:	b8 01 00 00 00       	mov    $0x1,%eax
f010457b:	ee                   	out    %al,(%dx)
f010457c:	b2 20                	mov    $0x20,%dl
f010457e:	b8 68 00 00 00       	mov    $0x68,%eax
f0104583:	ee                   	out    %al,(%dx)
f0104584:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104589:	ee                   	out    %al,(%dx)
f010458a:	b2 a0                	mov    $0xa0,%dl
f010458c:	b8 68 00 00 00       	mov    $0x68,%eax
f0104591:	ee                   	out    %al,(%dx)
f0104592:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104597:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104598:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f010459f:	66 83 f8 ff          	cmp    $0xffff,%ax
f01045a3:	74 0b                	je     f01045b0 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f01045a5:	0f b7 c0             	movzwl %ax,%eax
f01045a8:	89 04 24             	mov    %eax,(%esp)
f01045ab:	e8 08 ff ff ff       	call   f01044b8 <irq_setmask_8259A>
}
f01045b0:	c9                   	leave  
f01045b1:	c3                   	ret    
	...

f01045b4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01045b4:	55                   	push   %ebp
f01045b5:	89 e5                	mov    %esp,%ebp
f01045b7:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01045ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01045bd:	89 04 24             	mov    %eax,(%esp)
f01045c0:	e8 d4 c1 ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f01045c5:	c9                   	leave  
f01045c6:	c3                   	ret    

f01045c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01045c7:	55                   	push   %ebp
f01045c8:	89 e5                	mov    %esp,%ebp
f01045ca:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01045cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01045d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045db:	8b 45 08             	mov    0x8(%ebp),%eax
f01045de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e9:	c7 04 24 b4 45 10 f0 	movl   $0xf01045b4,(%esp)
f01045f0:	e8 85 16 00 00       	call   f0105c7a <vprintfmt>
	return cnt;
}
f01045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045f8:	c9                   	leave  
f01045f9:	c3                   	ret    

f01045fa <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01045fa:	55                   	push   %ebp
f01045fb:	89 e5                	mov    %esp,%ebp
f01045fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104600:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104603:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104607:	8b 45 08             	mov    0x8(%ebp),%eax
f010460a:	89 04 24             	mov    %eax,(%esp)
f010460d:	e8 b5 ff ff ff       	call   f01045c7 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104612:	c9                   	leave  
f0104613:	c3                   	ret    
	...

f0104620 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104620:	55                   	push   %ebp
f0104621:	89 e5                	mov    %esp,%ebp
f0104623:	57                   	push   %edi
f0104624:	56                   	push   %esi
f0104625:	53                   	push   %ebx
f0104626:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP);
f0104629:	e8 12 25 00 00       	call   f0106b40 <cpunum>
f010462e:	89 c3                	mov    %eax,%ebx
f0104630:	e8 0b 25 00 00       	call   f0106b40 <cpunum>
f0104635:	6b db 74             	imul   $0x74,%ebx,%ebx
f0104638:	6b c0 74             	imul   $0x74,%eax,%eax
f010463b:	0f b6 80 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%eax
f0104642:	f7 d8                	neg    %eax
f0104644:	c1 e0 10             	shl    $0x10,%eax
f0104647:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010464c:	89 83 30 d0 22 f0    	mov    %eax,-0xfdd2fd0(%ebx)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104652:	e8 e9 24 00 00       	call   f0106b40 <cpunum>
f0104657:	6b c0 74             	imul   $0x74,%eax,%eax
f010465a:	66 c7 80 34 d0 22 f0 	movw   $0x10,-0xfdd2fcc(%eax)
f0104661:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0104663:	e8 d8 24 00 00       	call   f0106b40 <cpunum>
f0104668:	6b c0 74             	imul   $0x74,%eax,%eax
f010466b:	0f b6 98 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%ebx
f0104672:	83 c3 05             	add    $0x5,%ebx
f0104675:	e8 c6 24 00 00       	call   f0106b40 <cpunum>
f010467a:	89 c6                	mov    %eax,%esi
f010467c:	e8 bf 24 00 00       	call   f0106b40 <cpunum>
f0104681:	89 c7                	mov    %eax,%edi
f0104683:	e8 b8 24 00 00       	call   f0106b40 <cpunum>
f0104688:	66 c7 04 dd 40 33 12 	movw   $0x68,-0xfedccc0(,%ebx,8)
f010468f:	f0 68 00 
f0104692:	6b f6 74             	imul   $0x74,%esi,%esi
f0104695:	81 c6 2c d0 22 f0    	add    $0xf022d02c,%esi
f010469b:	66 89 34 dd 42 33 12 	mov    %si,-0xfedccbe(,%ebx,8)
f01046a2:	f0 
f01046a3:	6b d7 74             	imul   $0x74,%edi,%edx
f01046a6:	81 c2 2c d0 22 f0    	add    $0xf022d02c,%edx
f01046ac:	c1 ea 10             	shr    $0x10,%edx
f01046af:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f01046b6:	c6 04 dd 45 33 12 f0 	movb   $0x99,-0xfedccbb(,%ebx,8)
f01046bd:	99 
f01046be:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f01046c5:	40 
f01046c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c9:	05 2c d0 22 f0       	add    $0xf022d02c,%eax
f01046ce:	c1 e8 18             	shr    $0x18,%eax
f01046d1:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
                    sizeof(struct Taskstate), 0);
    gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id].sd_s = 0;
f01046d8:	e8 63 24 00 00       	call   f0106b40 <cpunum>
f01046dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e0:	0f b6 80 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%eax
f01046e7:	80 24 c5 6d 33 12 f0 	andb   $0xef,-0xfedcc93(,%eax,8)
f01046ee:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8*(thiscpu->cpu_id));
f01046ef:	e8 4c 24 00 00       	call   f0106b40 <cpunum>
f01046f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f7:	0f b6 80 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%eax
f01046fe:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104705:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104708:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f010470d:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104710:	83 c4 0c             	add    $0xc,%esp
f0104713:	5b                   	pop    %ebx
f0104714:	5e                   	pop    %esi
f0104715:	5f                   	pop    %edi
f0104716:	5d                   	pop    %ebp
f0104717:	c3                   	ret    

f0104718 <trap_init>:
}


void
trap_init(void)
{
f0104718:	55                   	push   %ebp
f0104719:	89 e5                	mov    %esp,%ebp
f010471b:	53                   	push   %ebx
f010471c:	83 ec 04             	sub    $0x4,%esp
f010471f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0104724:	b8 00 00 00 00       	mov    $0x0,%eax
f0104729:	eb 06                	jmp    f0104731 <trap_init+0x19>
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f010472b:	83 c0 01             	add    $0x1,%eax
f010472e:	83 c1 01             	add    $0x1,%ecx

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
		if (i==T_BRKPT)
f0104731:	83 f8 03             	cmp    $0x3,%eax
f0104734:	75 30                	jne    f0104766 <trap_init+0x4e>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f0104736:	8b 15 c0 33 12 f0    	mov    0xf01233c0,%edx
f010473c:	66 89 15 78 c2 22 f0 	mov    %dx,0xf022c278
f0104743:	66 c7 05 7a c2 22 f0 	movw   $0x8,0xf022c27a
f010474a:	08 00 
f010474c:	c6 05 7c c2 22 f0 00 	movb   $0x0,0xf022c27c
f0104753:	c6 05 7d c2 22 f0 ee 	movb   $0xee,0xf022c27d
f010475a:	c1 ea 10             	shr    $0x10,%edx
f010475d:	66 89 15 7e c2 22 f0 	mov    %dx,0xf022c27e
f0104764:	eb c5                	jmp    f010472b <trap_init+0x13>
		else if (i!=2 && i!=15) {
f0104766:	83 f8 02             	cmp    $0x2,%eax
f0104769:	74 39                	je     f01047a4 <trap_init+0x8c>
f010476b:	83 f8 0f             	cmp    $0xf,%eax
f010476e:	74 34                	je     f01047a4 <trap_init+0x8c>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f0104770:	8b 1c 85 b4 33 12 f0 	mov    -0xfedcc4c(,%eax,4),%ebx
f0104777:	66 89 1c c5 60 c2 22 	mov    %bx,-0xfdd3da0(,%eax,8)
f010477e:	f0 
f010477f:	66 c7 04 c5 62 c2 22 	movw   $0x8,-0xfdd3d9e(,%eax,8)
f0104786:	f0 08 00 
f0104789:	c6 04 c5 64 c2 22 f0 	movb   $0x0,-0xfdd3d9c(,%eax,8)
f0104790:	00 
f0104791:	c6 04 c5 65 c2 22 f0 	movb   $0x8e,-0xfdd3d9b(,%eax,8)
f0104798:	8e 
f0104799:	c1 eb 10             	shr    $0x10,%ebx
f010479c:	66 89 1c c5 66 c2 22 	mov    %bx,-0xfdd3d9a(,%eax,8)
f01047a3:	f0 
	// SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
f01047a4:	83 f9 10             	cmp    $0x10,%ecx
f01047a7:	7e 82                	jle    f010472b <trap_init+0x13>
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f01047a9:	a1 74 34 12 f0       	mov    0xf0123474,%eax
f01047ae:	66 a3 e0 c3 22 f0    	mov    %ax,0xf022c3e0
f01047b4:	66 c7 05 e2 c3 22 f0 	movw   $0x8,0xf022c3e2
f01047bb:	08 00 
f01047bd:	c6 05 e4 c3 22 f0 00 	movb   $0x0,0xf022c3e4
f01047c4:	c6 05 e5 c3 22 f0 ee 	movb   $0xee,0xf022c3e5
f01047cb:	c1 e8 10             	shr    $0x10,%eax
f01047ce:	66 a3 e6 c3 22 f0    	mov    %ax,0xf022c3e6
f01047d4:	b8 20 00 00 00       	mov    $0x20,%eax

	for (i = 0; i < 16; ++i)
    	SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);
f01047d9:	8b 14 85 b4 33 12 f0 	mov    -0xfedcc4c(,%eax,4),%edx
f01047e0:	66 89 14 c5 60 c2 22 	mov    %dx,-0xfdd3da0(,%eax,8)
f01047e7:	f0 
f01047e8:	66 c7 04 c5 62 c2 22 	movw   $0x8,-0xfdd3d9e(,%eax,8)
f01047ef:	f0 08 00 
f01047f2:	c6 04 c5 64 c2 22 f0 	movb   $0x0,-0xfdd3d9c(,%eax,8)
f01047f9:	00 
f01047fa:	c6 04 c5 65 c2 22 f0 	movb   $0x8e,-0xfdd3d9b(,%eax,8)
f0104801:	8e 
f0104802:	c1 ea 10             	shr    $0x10,%edx
f0104805:	66 89 14 c5 66 c2 22 	mov    %dx,-0xfdd3d9a(,%eax,8)
f010480c:	f0 
f010480d:	83 c0 01             	add    $0x1,%eax
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);

	for (i = 0; i < 16; ++i)
f0104810:	83 f8 30             	cmp    $0x30,%eax
f0104813:	75 c4                	jne    f01047d9 <trap_init+0xc1>
    	SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);

	// Per-CPU setup 
	trap_init_percpu();
f0104815:	e8 06 fe ff ff       	call   f0104620 <trap_init_percpu>
}
f010481a:	83 c4 04             	add    $0x4,%esp
f010481d:	5b                   	pop    %ebx
f010481e:	5d                   	pop    %ebp
f010481f:	c3                   	ret    

f0104820 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104820:	55                   	push   %ebp
f0104821:	89 e5                	mov    %esp,%ebp
f0104823:	53                   	push   %ebx
f0104824:	83 ec 14             	sub    $0x14,%esp
f0104827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010482a:	8b 03                	mov    (%ebx),%eax
f010482c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104830:	c7 04 24 7c 87 10 f0 	movl   $0xf010877c,(%esp)
f0104837:	e8 be fd ff ff       	call   f01045fa <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010483c:	8b 43 04             	mov    0x4(%ebx),%eax
f010483f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104843:	c7 04 24 8b 87 10 f0 	movl   $0xf010878b,(%esp)
f010484a:	e8 ab fd ff ff       	call   f01045fa <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010484f:	8b 43 08             	mov    0x8(%ebx),%eax
f0104852:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104856:	c7 04 24 9a 87 10 f0 	movl   $0xf010879a,(%esp)
f010485d:	e8 98 fd ff ff       	call   f01045fa <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104862:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104865:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104869:	c7 04 24 a9 87 10 f0 	movl   $0xf01087a9,(%esp)
f0104870:	e8 85 fd ff ff       	call   f01045fa <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104875:	8b 43 10             	mov    0x10(%ebx),%eax
f0104878:	89 44 24 04          	mov    %eax,0x4(%esp)
f010487c:	c7 04 24 b8 87 10 f0 	movl   $0xf01087b8,(%esp)
f0104883:	e8 72 fd ff ff       	call   f01045fa <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104888:	8b 43 14             	mov    0x14(%ebx),%eax
f010488b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010488f:	c7 04 24 c7 87 10 f0 	movl   $0xf01087c7,(%esp)
f0104896:	e8 5f fd ff ff       	call   f01045fa <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010489b:	8b 43 18             	mov    0x18(%ebx),%eax
f010489e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a2:	c7 04 24 d6 87 10 f0 	movl   $0xf01087d6,(%esp)
f01048a9:	e8 4c fd ff ff       	call   f01045fa <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01048ae:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01048b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048b5:	c7 04 24 e5 87 10 f0 	movl   $0xf01087e5,(%esp)
f01048bc:	e8 39 fd ff ff       	call   f01045fa <cprintf>
}
f01048c1:	83 c4 14             	add    $0x14,%esp
f01048c4:	5b                   	pop    %ebx
f01048c5:	5d                   	pop    %ebp
f01048c6:	c3                   	ret    

f01048c7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01048c7:	55                   	push   %ebp
f01048c8:	89 e5                	mov    %esp,%ebp
f01048ca:	56                   	push   %esi
f01048cb:	53                   	push   %ebx
f01048cc:	83 ec 10             	sub    $0x10,%esp
f01048cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01048d2:	e8 69 22 00 00       	call   f0106b40 <cpunum>
f01048d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048df:	c7 04 24 49 88 10 f0 	movl   $0xf0108849,(%esp)
f01048e6:	e8 0f fd ff ff       	call   f01045fa <cprintf>
	print_regs(&tf->tf_regs);
f01048eb:	89 1c 24             	mov    %ebx,(%esp)
f01048ee:	e8 2d ff ff ff       	call   f0104820 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01048f3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01048f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048fb:	c7 04 24 67 88 10 f0 	movl   $0xf0108867,(%esp)
f0104902:	e8 f3 fc ff ff       	call   f01045fa <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104907:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010490b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010490f:	c7 04 24 7a 88 10 f0 	movl   $0xf010887a,(%esp)
f0104916:	e8 df fc ff ff       	call   f01045fa <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010491b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010491e:	83 f8 13             	cmp    $0x13,%eax
f0104921:	77 09                	ja     f010492c <print_trapframe+0x65>
		return excnames[trapno];
f0104923:	8b 14 85 00 8b 10 f0 	mov    -0xfef7500(,%eax,4),%edx
f010492a:	eb 1d                	jmp    f0104949 <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f010492c:	ba f4 87 10 f0       	mov    $0xf01087f4,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0104931:	83 f8 30             	cmp    $0x30,%eax
f0104934:	74 13                	je     f0104949 <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104936:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104939:	83 fa 0f             	cmp    $0xf,%edx
f010493c:	ba 00 88 10 f0       	mov    $0xf0108800,%edx
f0104941:	b9 13 88 10 f0       	mov    $0xf0108813,%ecx
f0104946:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104949:	89 54 24 08          	mov    %edx,0x8(%esp)
f010494d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104951:	c7 04 24 8d 88 10 f0 	movl   $0xf010888d,(%esp)
f0104958:	e8 9d fc ff ff       	call   f01045fa <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010495d:	3b 1d 60 ca 22 f0    	cmp    0xf022ca60,%ebx
f0104963:	75 19                	jne    f010497e <print_trapframe+0xb7>
f0104965:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104969:	75 13                	jne    f010497e <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010496b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010496e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104972:	c7 04 24 9f 88 10 f0 	movl   $0xf010889f,(%esp)
f0104979:	e8 7c fc ff ff       	call   f01045fa <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010497e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104981:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104985:	c7 04 24 ae 88 10 f0 	movl   $0xf01088ae,(%esp)
f010498c:	e8 69 fc ff ff       	call   f01045fa <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104991:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104995:	75 51                	jne    f01049e8 <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104997:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010499a:	89 c2                	mov    %eax,%edx
f010499c:	83 e2 01             	and    $0x1,%edx
f010499f:	ba 22 88 10 f0       	mov    $0xf0108822,%edx
f01049a4:	b9 2d 88 10 f0       	mov    $0xf010882d,%ecx
f01049a9:	0f 45 ca             	cmovne %edx,%ecx
f01049ac:	89 c2                	mov    %eax,%edx
f01049ae:	83 e2 02             	and    $0x2,%edx
f01049b1:	ba 39 88 10 f0       	mov    $0xf0108839,%edx
f01049b6:	be 3f 88 10 f0       	mov    $0xf010883f,%esi
f01049bb:	0f 44 d6             	cmove  %esi,%edx
f01049be:	83 e0 04             	and    $0x4,%eax
f01049c1:	b8 44 88 10 f0       	mov    $0xf0108844,%eax
f01049c6:	be 77 89 10 f0       	mov    $0xf0108977,%esi
f01049cb:	0f 44 c6             	cmove  %esi,%eax
f01049ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01049d2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01049d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049da:	c7 04 24 bc 88 10 f0 	movl   $0xf01088bc,(%esp)
f01049e1:	e8 14 fc ff ff       	call   f01045fa <cprintf>
f01049e6:	eb 0c                	jmp    f01049f4 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01049e8:	c7 04 24 b6 86 10 f0 	movl   $0xf01086b6,(%esp)
f01049ef:	e8 06 fc ff ff       	call   f01045fa <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01049f4:	8b 43 30             	mov    0x30(%ebx),%eax
f01049f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049fb:	c7 04 24 cb 88 10 f0 	movl   $0xf01088cb,(%esp)
f0104a02:	e8 f3 fb ff ff       	call   f01045fa <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104a07:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a0f:	c7 04 24 da 88 10 f0 	movl   $0xf01088da,(%esp)
f0104a16:	e8 df fb ff ff       	call   f01045fa <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104a1b:	8b 43 38             	mov    0x38(%ebx),%eax
f0104a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a22:	c7 04 24 ed 88 10 f0 	movl   $0xf01088ed,(%esp)
f0104a29:	e8 cc fb ff ff       	call   f01045fa <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104a2e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a32:	74 27                	je     f0104a5b <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104a34:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a3b:	c7 04 24 fc 88 10 f0 	movl   $0xf01088fc,(%esp)
f0104a42:	e8 b3 fb ff ff       	call   f01045fa <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104a47:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a4f:	c7 04 24 0b 89 10 f0 	movl   $0xf010890b,(%esp)
f0104a56:	e8 9f fb ff ff       	call   f01045fa <cprintf>
	}
}
f0104a5b:	83 c4 10             	add    $0x10,%esp
f0104a5e:	5b                   	pop    %ebx
f0104a5f:	5e                   	pop    %esi
f0104a60:	5d                   	pop    %ebp
f0104a61:	c3                   	ret    

f0104a62 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104a62:	55                   	push   %ebp
f0104a63:	89 e5                	mov    %esp,%ebp
f0104a65:	83 ec 38             	sub    $0x38,%esp
f0104a68:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104a6b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104a6e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a74:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0){
f0104a77:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a7b:	75 28                	jne    f0104aa5 <page_fault_handler+0x43>
		print_trapframe(tf);
f0104a7d:	89 1c 24             	mov    %ebx,(%esp)
f0104a80:	e8 42 fe ff ff       	call   f01048c7 <print_trapframe>
		panic("kernel page fault va: %08x", fault_va);
f0104a85:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104a89:	c7 44 24 08 1e 89 10 	movl   $0xf010891e,0x8(%esp)
f0104a90:	f0 
f0104a91:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f0104a98:	00 
f0104a99:	c7 04 24 39 89 10 f0 	movl   $0xf0108939,(%esp)
f0104aa0:	e8 9b b5 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104aa5:	e8 96 20 00 00       	call   f0106b40 <cpunum>
f0104aaa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aad:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104ab3:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104ab7:	0f 84 06 01 00 00    	je     f0104bc3 <page_fault_handler+0x161>
        struct UTrapframe *utf;
        uintptr_t utf_addr;
        // Locate the exception stack
        if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0104abd:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104ac0:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
            utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104ac6:	83 e8 38             	sub    $0x38,%eax
f0104ac9:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104acf:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104ad4:	0f 46 d0             	cmovbe %eax,%edx
f0104ad7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        else 
            utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
        user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
f0104ada:	e8 61 20 00 00       	call   f0106b40 <cpunum>
f0104adf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104ae6:	00 
f0104ae7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104aee:	00 
f0104aef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104af2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104af6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af9:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104aff:	89 04 24             	mov    %eax,(%esp)
f0104b02:	e8 05 f1 ff ff       	call   f0103c0c <user_mem_assert>
        utf = (struct UTrapframe *) utf_addr;
f0104b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b0a:	89 45 e0             	mov    %eax,-0x20(%ebp)

        // Form the UTrapframe
        utf->utf_fault_va = fault_va;
f0104b0d:	89 30                	mov    %esi,(%eax)
        utf->utf_err = tf->tf_err;
f0104b0f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104b12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b15:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0104b18:	89 d7                	mov    %edx,%edi
f0104b1a:	83 c7 08             	add    $0x8,%edi
f0104b1d:	89 de                	mov    %ebx,%esi
f0104b1f:	b8 20 00 00 00       	mov    $0x20,%eax
f0104b24:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104b2a:	74 03                	je     f0104b2f <page_fault_handler+0xcd>
f0104b2c:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104b2d:	b0 1f                	mov    $0x1f,%al
f0104b2f:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104b35:	74 05                	je     f0104b3c <page_fault_handler+0xda>
f0104b37:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104b39:	83 e8 02             	sub    $0x2,%eax
f0104b3c:	89 c1                	mov    %eax,%ecx
f0104b3e:	c1 e9 02             	shr    $0x2,%ecx
f0104b41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b43:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b48:	a8 02                	test   $0x2,%al
f0104b4a:	74 0b                	je     f0104b57 <page_fault_handler+0xf5>
f0104b4c:	0f b7 16             	movzwl (%esi),%edx
f0104b4f:	66 89 17             	mov    %dx,(%edi)
f0104b52:	ba 02 00 00 00       	mov    $0x2,%edx
f0104b57:	a8 01                	test   $0x1,%al
f0104b59:	74 07                	je     f0104b62 <page_fault_handler+0x100>
f0104b5b:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104b5f:	88 04 17             	mov    %al,(%edi,%edx,1)
        utf->utf_eip = tf->tf_eip;
f0104b62:	8b 43 30             	mov    0x30(%ebx),%eax
f0104b65:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b68:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104b6b:	8b 43 38             	mov    0x38(%ebx),%eax
f0104b6e:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104b71:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b74:	89 42 30             	mov    %eax,0x30(%edx)

        //Modify the env's trapframe to run the handler set before
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104b77:	e8 c4 1f 00 00       	call   f0106b40 <cpunum>
f0104b7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7f:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
f0104b85:	e8 b6 1f 00 00       	call   f0106b40 <cpunum>
f0104b8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b8d:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104b93:	8b 40 64             	mov    0x64(%eax),%eax
f0104b96:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = utf_addr;
f0104b99:	e8 a2 1f 00 00       	call   f0106b40 <cpunum>
f0104b9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba1:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104ba7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104baa:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104bad:	e8 8e 1f 00 00       	call   f0106b40 <cpunum>
f0104bb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb5:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104bbb:	89 04 24             	mov    %eax,(%esp)
f0104bbe:	e8 06 f8 ff ff       	call   f01043c9 <env_run>
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bc3:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104bc6:	e8 75 1f 00 00       	call   f0106b40 <cpunum>
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        curenv->env_tf.tf_esp = utf_addr;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104bcf:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104bd3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd6:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        curenv->env_tf.tf_esp = utf_addr;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bdc:	8b 40 48             	mov    0x48(%eax),%eax
f0104bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104be3:	c7 04 24 c4 8a 10 f0 	movl   $0xf0108ac4,(%esp)
f0104bea:	e8 0b fa ff ff       	call   f01045fa <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104bef:	89 1c 24             	mov    %ebx,(%esp)
f0104bf2:	e8 d0 fc ff ff       	call   f01048c7 <print_trapframe>
	env_destroy(curenv);
f0104bf7:	e8 44 1f 00 00       	call   f0106b40 <cpunum>
f0104bfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bff:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104c05:	89 04 24             	mov    %eax,(%esp)
f0104c08:	e8 0f f7 ff ff       	call   f010431c <env_destroy>
}
f0104c0d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104c10:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104c13:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104c16:	89 ec                	mov    %ebp,%esp
f0104c18:	5d                   	pop    %ebp
f0104c19:	c3                   	ret    

f0104c1a <breakpoint_handler>:

void
breakpoint_handler(struct Trapframe *tf) {
f0104c1a:	55                   	push   %ebp
f0104c1b:	89 e5                	mov    %esp,%ebp
f0104c1d:	83 ec 18             	sub    $0x18,%esp
	//print_trapframe(tf);
	monitor(tf);
f0104c20:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c23:	89 04 24             	mov    %eax,(%esp)
f0104c26:	e8 01 c4 ff ff       	call   f010102c <monitor>
	return;
}
f0104c2b:	c9                   	leave  
f0104c2c:	c3                   	ret    

f0104c2d <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104c2d:	55                   	push   %ebp
f0104c2e:	89 e5                	mov    %esp,%ebp
f0104c30:	57                   	push   %edi
f0104c31:	56                   	push   %esi
f0104c32:	83 ec 20             	sub    $0x20,%esp
f0104c35:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104c38:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104c39:	83 3d 80 ce 22 f0 00 	cmpl   $0x0,0xf022ce80
f0104c40:	74 01                	je     f0104c43 <trap+0x16>
		asm volatile("hlt");
f0104c42:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104c43:	e8 f8 1e 00 00       	call   f0106b40 <cpunum>
f0104c48:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c4b:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c51:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c56:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104c5a:	83 f8 02             	cmp    $0x2,%eax
f0104c5d:	75 0c                	jne    f0104c6b <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104c5f:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104c66:	e8 85 21 00 00       	call   f0106df0 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104c6b:	9c                   	pushf  
f0104c6c:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104c6d:	f6 c4 02             	test   $0x2,%ah
f0104c70:	74 24                	je     f0104c96 <trap+0x69>
f0104c72:	c7 44 24 0c 45 89 10 	movl   $0xf0108945,0xc(%esp)
f0104c79:	f0 
f0104c7a:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0104c81:	f0 
f0104c82:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
f0104c89:	00 
f0104c8a:	c7 04 24 39 89 10 f0 	movl   $0xf0108939,(%esp)
f0104c91:	e8 aa b3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104c96:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104c9a:	83 e0 03             	and    $0x3,%eax
f0104c9d:	83 f8 03             	cmp    $0x3,%eax
f0104ca0:	0f 85 a7 00 00 00    	jne    f0104d4d <trap+0x120>
f0104ca6:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104cad:	e8 3e 21 00 00       	call   f0106df0 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104cb2:	e8 89 1e 00 00       	call   f0106b40 <cpunum>
f0104cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cba:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0104cc1:	75 24                	jne    f0104ce7 <trap+0xba>
f0104cc3:	c7 44 24 0c 5e 89 10 	movl   $0xf010895e,0xc(%esp)
f0104cca:	f0 
f0104ccb:	c7 44 24 08 0b 84 10 	movl   $0xf010840b,0x8(%esp)
f0104cd2:	f0 
f0104cd3:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f0104cda:	00 
f0104cdb:	c7 04 24 39 89 10 f0 	movl   $0xf0108939,(%esp)
f0104ce2:	e8 59 b3 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104ce7:	e8 54 1e 00 00       	call   f0106b40 <cpunum>
f0104cec:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cef:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104cf5:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104cf9:	75 2d                	jne    f0104d28 <trap+0xfb>
			env_free(curenv);
f0104cfb:	e8 40 1e 00 00       	call   f0106b40 <cpunum>
f0104d00:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d03:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d09:	89 04 24             	mov    %eax,(%esp)
f0104d0c:	e8 04 f4 ff ff       	call   f0104115 <env_free>
			curenv = NULL;
f0104d11:	e8 2a 1e 00 00       	call   f0106b40 <cpunum>
f0104d16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d19:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0104d20:	00 00 00 
			sched_yield();
f0104d23:	e8 fc 02 00 00       	call   f0105024 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104d28:	e8 13 1e 00 00       	call   f0106b40 <cpunum>
f0104d2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d30:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d36:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d3b:	89 c7                	mov    %eax,%edi
f0104d3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104d3f:	e8 fc 1d 00 00       	call   f0106b40 <cpunum>
f0104d44:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d47:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104d4d:	89 35 60 ca 22 f0    	mov    %esi,0xf022ca60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT) {
f0104d53:	8b 46 28             	mov    0x28(%esi),%eax
f0104d56:	83 f8 0e             	cmp    $0xe,%eax
f0104d59:	75 0d                	jne    f0104d68 <trap+0x13b>
//		cprintf("PAGE FAULT!\n");
		page_fault_handler(tf);
f0104d5b:	89 34 24             	mov    %esi,(%esp)
f0104d5e:	e8 ff fc ff ff       	call   f0104a62 <page_fault_handler>
f0104d63:	e9 ae 00 00 00       	jmp    f0104e16 <trap+0x1e9>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104d68:	83 f8 27             	cmp    $0x27,%eax
f0104d6b:	75 0d                	jne    f0104d7a <trap+0x14d>
//		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
f0104d6d:	89 34 24             	mov    %esi,(%esp)
f0104d70:	e8 52 fb ff ff       	call   f01048c7 <print_trapframe>
f0104d75:	e9 9c 00 00 00       	jmp    f0104e16 <trap+0x1e9>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if(tf->tf_trapno == T_BRKPT) {
f0104d7a:	83 f8 03             	cmp    $0x3,%eax
f0104d7d:	75 0d                	jne    f0104d8c <trap+0x15f>
//		cprintf("BREAK POINT!\n");
		breakpoint_handler(tf);
f0104d7f:	89 34 24             	mov    %esi,(%esp)
f0104d82:	e8 93 fe ff ff       	call   f0104c1a <breakpoint_handler>
f0104d87:	e9 8a 00 00 00       	jmp    f0104e16 <trap+0x1e9>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
f0104d8c:	83 f8 30             	cmp    $0x30,%eax
f0104d8f:	90                   	nop
f0104d90:	75 32                	jne    f0104dc4 <trap+0x197>
		//cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104d92:	8b 46 04             	mov    0x4(%esi),%eax
f0104d95:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104d99:	8b 06                	mov    (%esi),%eax
f0104d9b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104d9f:	8b 46 10             	mov    0x10(%esi),%eax
f0104da2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104da6:	8b 46 18             	mov    0x18(%esi),%eax
f0104da9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104dad:	8b 46 14             	mov    0x14(%esi),%eax
f0104db0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104db4:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104db7:	89 04 24             	mov    %eax,(%esp)
f0104dba:	e8 5c 03 00 00       	call   f010511b <syscall>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
		//cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
f0104dbf:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104dc2:	eb 52                	jmp    f0104e16 <trap+0x1e9>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104dc4:	83 f8 20             	cmp    $0x20,%eax
f0104dc7:	75 0c                	jne    f0104dd5 <trap+0x1a8>
		lapic_eoi();
f0104dc9:	e8 bd 1e 00 00       	call   f0106c8b <lapic_eoi>
		sched_yield();
f0104dce:	66 90                	xchg   %ax,%ax
f0104dd0:	e8 4f 02 00 00       	call   f0105024 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104dd5:	89 34 24             	mov    %esi,(%esp)
f0104dd8:	e8 ea fa ff ff       	call   f01048c7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ddd:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104de2:	75 1c                	jne    f0104e00 <trap+0x1d3>
		panic("unhandled trap in kernel");
f0104de4:	c7 44 24 08 65 89 10 	movl   $0xf0108965,0x8(%esp)
f0104deb:	f0 
f0104dec:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
f0104df3:	00 
f0104df4:	c7 04 24 39 89 10 f0 	movl   $0xf0108939,(%esp)
f0104dfb:	e8 40 b2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104e00:	e8 3b 1d 00 00       	call   f0106b40 <cpunum>
f0104e05:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e08:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104e0e:	89 04 24             	mov    %eax,(%esp)
f0104e11:	e8 06 f5 ff ff       	call   f010431c <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104e16:	e8 25 1d 00 00       	call   f0106b40 <cpunum>
f0104e1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e1e:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0104e25:	74 2a                	je     f0104e51 <trap+0x224>
f0104e27:	e8 14 1d 00 00       	call   f0106b40 <cpunum>
f0104e2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2f:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104e35:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e39:	75 16                	jne    f0104e51 <trap+0x224>
		env_run(curenv);
f0104e3b:	e8 00 1d 00 00       	call   f0106b40 <cpunum>
f0104e40:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e43:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104e49:	89 04 24             	mov    %eax,(%esp)
f0104e4c:	e8 78 f5 ff ff       	call   f01043c9 <env_run>
	else
		sched_yield();
f0104e51:	e8 ce 01 00 00       	call   f0105024 <sched_yield>
	...

f0104e58 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec_entry(th0, 0)
f0104e58:	6a 00                	push   $0x0
f0104e5a:	6a 00                	push   $0x0
f0104e5c:	e9 cf 00 00 00       	jmp    f0104f30 <_alltraps>
f0104e61:	90                   	nop

f0104e62 <th1>:
	noec_entry(th1, 1)
f0104e62:	6a 00                	push   $0x0
f0104e64:	6a 01                	push   $0x1
f0104e66:	e9 c5 00 00 00       	jmp    f0104f30 <_alltraps>
f0104e6b:	90                   	nop

f0104e6c <th3>:
	reserved_entry()
	noec_entry(th3, 3)
f0104e6c:	6a 00                	push   $0x0
f0104e6e:	6a 03                	push   $0x3
f0104e70:	e9 bb 00 00 00       	jmp    f0104f30 <_alltraps>
f0104e75:	90                   	nop

f0104e76 <th4>:
	noec_entry(th4, 4)
f0104e76:	6a 00                	push   $0x0
f0104e78:	6a 04                	push   $0x4
f0104e7a:	e9 b1 00 00 00       	jmp    f0104f30 <_alltraps>
f0104e7f:	90                   	nop

f0104e80 <th5>:
	noec_entry(th5, 5)
f0104e80:	6a 00                	push   $0x0
f0104e82:	6a 05                	push   $0x5
f0104e84:	e9 a7 00 00 00       	jmp    f0104f30 <_alltraps>
f0104e89:	90                   	nop

f0104e8a <th6>:
	noec_entry(th6, 6)
f0104e8a:	6a 00                	push   $0x0
f0104e8c:	6a 06                	push   $0x6
f0104e8e:	e9 9d 00 00 00       	jmp    f0104f30 <_alltraps>
f0104e93:	90                   	nop

f0104e94 <th7>:
	noec_entry(th7, 7)
f0104e94:	6a 00                	push   $0x0
f0104e96:	6a 07                	push   $0x7
f0104e98:	e9 93 00 00 00       	jmp    f0104f30 <_alltraps>
f0104e9d:	90                   	nop

f0104e9e <th8>:
	ec_entry(th8, 8)
f0104e9e:	6a 08                	push   $0x8
f0104ea0:	e9 8b 00 00 00       	jmp    f0104f30 <_alltraps>
f0104ea5:	90                   	nop

f0104ea6 <th9>:
	noec_entry(th9, 9)
f0104ea6:	6a 00                	push   $0x0
f0104ea8:	6a 09                	push   $0x9
f0104eaa:	e9 81 00 00 00       	jmp    f0104f30 <_alltraps>
f0104eaf:	90                   	nop

f0104eb0 <th10>:
	ec_entry(th10, 10)
f0104eb0:	6a 0a                	push   $0xa
f0104eb2:	eb 7c                	jmp    f0104f30 <_alltraps>

f0104eb4 <th11>:
	ec_entry(th11, 11)
f0104eb4:	6a 0b                	push   $0xb
f0104eb6:	eb 78                	jmp    f0104f30 <_alltraps>

f0104eb8 <th12>:
	ec_entry(th12, 12)
f0104eb8:	6a 0c                	push   $0xc
f0104eba:	eb 74                	jmp    f0104f30 <_alltraps>

f0104ebc <th13>:
	ec_entry(th13, 13)
f0104ebc:	6a 0d                	push   $0xd
f0104ebe:	eb 70                	jmp    f0104f30 <_alltraps>

f0104ec0 <th14>:
	ec_entry(th14, 14)
f0104ec0:	6a 0e                	push   $0xe
f0104ec2:	eb 6c                	jmp    f0104f30 <_alltraps>

f0104ec4 <th16>:
	reserved_entry()
	
.data
	.space 60
.text
	noec_entry(th16, 16)
f0104ec4:	6a 00                	push   $0x0
f0104ec6:	6a 10                	push   $0x10
f0104ec8:	eb 66                	jmp    f0104f30 <_alltraps>

f0104eca <th32>:
	noec_entry(th32, 32)
f0104eca:	6a 00                	push   $0x0
f0104ecc:	6a 20                	push   $0x20
f0104ece:	eb 60                	jmp    f0104f30 <_alltraps>

f0104ed0 <th33>:
    noec_entry(th33, 33)
f0104ed0:	6a 00                	push   $0x0
f0104ed2:	6a 21                	push   $0x21
f0104ed4:	eb 5a                	jmp    f0104f30 <_alltraps>

f0104ed6 <th34>:
    noec_entry(th34, 34)
f0104ed6:	6a 00                	push   $0x0
f0104ed8:	6a 22                	push   $0x22
f0104eda:	eb 54                	jmp    f0104f30 <_alltraps>

f0104edc <th35>:
    noec_entry(th35, 35)
f0104edc:	6a 00                	push   $0x0
f0104ede:	6a 23                	push   $0x23
f0104ee0:	eb 4e                	jmp    f0104f30 <_alltraps>

f0104ee2 <th36>:
    noec_entry(th36, 36)
f0104ee2:	6a 00                	push   $0x0
f0104ee4:	6a 24                	push   $0x24
f0104ee6:	eb 48                	jmp    f0104f30 <_alltraps>

f0104ee8 <th37>:
    noec_entry(th37, 37)
f0104ee8:	6a 00                	push   $0x0
f0104eea:	6a 25                	push   $0x25
f0104eec:	eb 42                	jmp    f0104f30 <_alltraps>

f0104eee <th38>:
    noec_entry(th38, 38)
f0104eee:	6a 00                	push   $0x0
f0104ef0:	6a 26                	push   $0x26
f0104ef2:	eb 3c                	jmp    f0104f30 <_alltraps>

f0104ef4 <th39>:
    noec_entry(th39, 39)
f0104ef4:	6a 00                	push   $0x0
f0104ef6:	6a 27                	push   $0x27
f0104ef8:	eb 36                	jmp    f0104f30 <_alltraps>

f0104efa <th40>:
    noec_entry(th40, 40)
f0104efa:	6a 00                	push   $0x0
f0104efc:	6a 28                	push   $0x28
f0104efe:	eb 30                	jmp    f0104f30 <_alltraps>

f0104f00 <th41>:
    noec_entry(th41, 41)
f0104f00:	6a 00                	push   $0x0
f0104f02:	6a 29                	push   $0x29
f0104f04:	eb 2a                	jmp    f0104f30 <_alltraps>

f0104f06 <th42>:
    noec_entry(th42, 42)
f0104f06:	6a 00                	push   $0x0
f0104f08:	6a 2a                	push   $0x2a
f0104f0a:	eb 24                	jmp    f0104f30 <_alltraps>

f0104f0c <th43>:
    noec_entry(th43, 43)
f0104f0c:	6a 00                	push   $0x0
f0104f0e:	6a 2b                	push   $0x2b
f0104f10:	eb 1e                	jmp    f0104f30 <_alltraps>

f0104f12 <th44>:
    noec_entry(th44, 44)
f0104f12:	6a 00                	push   $0x0
f0104f14:	6a 2c                	push   $0x2c
f0104f16:	eb 18                	jmp    f0104f30 <_alltraps>

f0104f18 <th45>:
    noec_entry(th45, 45)
f0104f18:	6a 00                	push   $0x0
f0104f1a:	6a 2d                	push   $0x2d
f0104f1c:	eb 12                	jmp    f0104f30 <_alltraps>

f0104f1e <th46>:
    noec_entry(th46, 46)
f0104f1e:	6a 00                	push   $0x0
f0104f20:	6a 2e                	push   $0x2e
f0104f22:	eb 0c                	jmp    f0104f30 <_alltraps>

f0104f24 <th47>:
    noec_entry(th47, 47)
f0104f24:	6a 00                	push   $0x0
f0104f26:	6a 2f                	push   $0x2f
f0104f28:	eb 06                	jmp    f0104f30 <_alltraps>

f0104f2a <th48>:
	noec_entry(th48, 48)
f0104f2a:	6a 00                	push   $0x0
f0104f2c:	6a 30                	push   $0x30
f0104f2e:	eb 00                	jmp    f0104f30 <_alltraps>

f0104f30 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104f30:	1e                   	push   %ds
	pushl %es
f0104f31:	06                   	push   %es
	pushal
f0104f32:	60                   	pusha  
	pushl $GD_KD
f0104f33:	6a 10                	push   $0x10
	popl %ds
f0104f35:	1f                   	pop    %ds
	pushl $GD_KD
f0104f36:	6a 10                	push   $0x10
	popl %es
f0104f38:	07                   	pop    %es
	pushl %esp
f0104f39:	54                   	push   %esp
	call trap
f0104f3a:	e8 ee fc ff ff       	call   f0104c2d <trap>
	...

f0104f40 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104f40:	55                   	push   %ebp
f0104f41:	89 e5                	mov    %esp,%ebp
f0104f43:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f46:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
f0104f4c:	8b 42 54             	mov    0x54(%edx),%eax
f0104f4f:	83 e8 02             	sub    $0x2,%eax
f0104f52:	83 f8 01             	cmp    $0x1,%eax
f0104f55:	76 45                	jbe    f0104f9c <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104f57:	81 c2 d0 00 00 00    	add    $0xd0,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104f5d:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f62:	8b 0a                	mov    (%edx),%ecx
f0104f64:	83 e9 02             	sub    $0x2,%ecx
f0104f67:	83 f9 01             	cmp    $0x1,%ecx
f0104f6a:	76 0f                	jbe    f0104f7b <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104f6c:	83 c0 01             	add    $0x1,%eax
f0104f6f:	83 c2 7c             	add    $0x7c,%edx
f0104f72:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f77:	75 e9                	jne    f0104f62 <sched_halt+0x22>
f0104f79:	eb 07                	jmp    f0104f82 <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104f7b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f80:	75 1a                	jne    f0104f9c <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f0104f82:	c7 04 24 50 8b 10 f0 	movl   $0xf0108b50,(%esp)
f0104f89:	e8 6c f6 ff ff       	call   f01045fa <cprintf>
		while (1)
			monitor(NULL);
f0104f8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104f95:	e8 92 c0 ff ff       	call   f010102c <monitor>
f0104f9a:	eb f2                	jmp    f0104f8e <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104f9c:	e8 9f 1b 00 00       	call   f0106b40 <cpunum>
f0104fa1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa4:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0104fab:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104fae:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104fb3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104fb8:	77 20                	ja     f0104fda <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104fba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fbe:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0104fc5:	f0 
f0104fc6:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f0104fcd:	00 
f0104fce:	c7 04 24 79 8b 10 f0 	movl   $0xf0108b79,(%esp)
f0104fd5:	e8 66 b0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104fda:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104fdf:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104fe2:	e8 59 1b 00 00       	call   f0106b40 <cpunum>
f0104fe7:	6b d0 74             	imul   $0x74,%eax,%edx
f0104fea:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104ff0:	b8 02 00 00 00       	mov    $0x2,%eax
f0104ff5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104ff9:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0105000:	e8 ae 1e 00 00       	call   f0106eb3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105005:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0105007:	e8 34 1b 00 00       	call   f0106b40 <cpunum>
f010500c:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010500f:	8b 80 30 d0 22 f0    	mov    -0xfdd2fd0(%eax),%eax
f0105015:	bd 00 00 00 00       	mov    $0x0,%ebp
f010501a:	89 c4                	mov    %eax,%esp
f010501c:	6a 00                	push   $0x0
f010501e:	6a 00                	push   $0x0
f0105020:	fb                   	sti    
f0105021:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0105022:	c9                   	leave  
f0105023:	c3                   	ret    

f0105024 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105024:	55                   	push   %ebp
f0105025:	89 e5                	mov    %esp,%ebp
f0105027:	57                   	push   %edi
f0105028:	56                   	push   %esi
f0105029:	53                   	push   %ebx
f010502a:	83 ec 1c             	sub    $0x1c,%esp
		env_run(idle);
	}

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
f010502d:	e8 0e 1b 00 00       	call   f0106b40 <cpunum>
f0105032:	6b c0 74             	imul   $0x74,%eax,%eax
		else cur = 0;
f0105035:	b9 00 00 00 00       	mov    $0x0,%ecx
		env_run(idle);
	}

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
f010503a:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0105041:	74 1a                	je     f010505d <sched_yield+0x39>
f0105043:	e8 f8 1a 00 00       	call   f0106b40 <cpunum>
f0105048:	6b c0 74             	imul   $0x74,%eax,%eax
f010504b:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105051:	8b 40 44             	mov    0x44(%eax),%eax
f0105054:	8b 48 48             	mov    0x48(%eax),%ecx
f0105057:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
f010505d:	89 cf                	mov    %ecx,%edi
		if (envs[j].env_status == ENV_RUNNABLE) {
f010505f:	8b 35 48 c2 22 f0    	mov    0xf022c248,%esi
f0105065:	6b c1 7c             	imul   $0x7c,%ecx,%eax
f0105068:	89 c3                	mov    %eax,%ebx
f010506a:	83 7c 06 54 02       	cmpl   $0x2,0x54(%esi,%eax,1)
f010506f:	74 28                	je     f0105099 <sched_yield+0x75>

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
f0105071:	b8 01 00 00 00       	mov    $0x1,%eax

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0105076:	8d 14 08             	lea    (%eax,%ecx,1),%edx
*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
f0105079:	89 d3                	mov    %edx,%ebx
f010507b:	c1 fb 1f             	sar    $0x1f,%ebx
f010507e:	c1 eb 16             	shr    $0x16,%ebx
f0105081:	01 da                	add    %ebx,%edx
f0105083:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0105089:	29 da                	sub    %ebx,%edx
f010508b:	89 d7                	mov    %edx,%edi
		if (envs[j].env_status == ENV_RUNNABLE) {
f010508d:	6b d2 7c             	imul   $0x7c,%edx,%edx
f0105090:	89 d3                	mov    %edx,%ebx
f0105092:	83 7c 16 54 02       	cmpl   $0x2,0x54(%esi,%edx,1)
f0105097:	75 1f                	jne    f01050b8 <sched_yield+0x94>
			if (j == 1) 
f0105099:	83 ff 01             	cmp    $0x1,%edi
f010509c:	75 0c                	jne    f01050aa <sched_yield+0x86>
				cprintf("\n");
f010509e:	c7 04 24 b6 86 10 f0 	movl   $0xf01086b6,(%esp)
f01050a5:	e8 50 f5 ff ff       	call   f01045fa <cprintf>
			env_run(envs + j);
f01050aa:	03 1d 48 c2 22 f0    	add    0xf022c248,%ebx
f01050b0:	89 1c 24             	mov    %ebx,(%esp)
f01050b3:	e8 11 f3 ff ff       	call   f01043c9 <env_run>

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
f01050b8:	83 c0 01             	add    $0x1,%eax
f01050bb:	3d 00 04 00 00       	cmp    $0x400,%eax
f01050c0:	75 b4                	jne    f0105076 <sched_yield+0x52>
			if (j == 1) 
				cprintf("\n");
			env_run(envs + j);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f01050c2:	e8 79 1a 00 00       	call   f0106b40 <cpunum>
f01050c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ca:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01050d1:	74 2a                	je     f01050fd <sched_yield+0xd9>
f01050d3:	e8 68 1a 00 00       	call   f0106b40 <cpunum>
f01050d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01050db:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01050e1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01050e5:	75 16                	jne    f01050fd <sched_yield+0xd9>
		env_run(curenv);
f01050e7:	e8 54 1a 00 00       	call   f0106b40 <cpunum>
f01050ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ef:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01050f5:	89 04 24             	mov    %eax,(%esp)
f01050f8:	e8 cc f2 ff ff       	call   f01043c9 <env_run>

	// sched_halt never returns
//cprintf("**Fail to find one\n");
	sched_halt();
f01050fd:	e8 3e fe ff ff       	call   f0104f40 <sched_halt>
}
f0105102:	83 c4 1c             	add    $0x1c,%esp
f0105105:	5b                   	pop    %ebx
f0105106:	5e                   	pop    %esi
f0105107:	5f                   	pop    %edi
f0105108:	5d                   	pop    %ebp
f0105109:	c3                   	ret    
f010510a:	00 00                	add    %al,(%eax)
f010510c:	00 00                	add    %al,(%eax)
	...

f0105110 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0105110:	55                   	push   %ebp
f0105111:	89 e5                	mov    %esp,%ebp
f0105113:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0105116:	e8 09 ff ff ff       	call   f0105024 <sched_yield>

f010511b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010511b:	55                   	push   %ebp
f010511c:	89 e5                	mov    %esp,%ebp
f010511e:	83 ec 38             	sub    $0x38,%esp
f0105121:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105124:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105127:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010512a:	8b 45 08             	mov    0x8(%ebp),%eax
f010512d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105130:	8b 5d 10             	mov    0x10(%ebp),%ebx
				(void *)a3, (unsigned)a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
			
		default: 
			return -E_INVAL;
f0105133:	be fd ff ff ff       	mov    $0xfffffffd,%esi
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno){
f0105138:	83 f8 0c             	cmp    $0xc,%eax
f010513b:	0f 87 78 05 00 00    	ja     f01056b9 <syscall+0x59e>
f0105141:	ff 24 85 c0 8b 10 f0 	jmp    *-0xfef7440(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(void *)s, len, PTE_U | PTE_P);
f0105148:	e8 f3 19 00 00       	call   f0106b40 <cpunum>
f010514d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0105154:	00 
f0105155:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105159:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010515d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105160:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105166:	89 04 24             	mov    %eax,(%esp)
f0105169:	e8 9e ea ff ff       	call   f0103c0c <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010516e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105172:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105176:	c7 04 24 86 8b 10 f0 	movl   $0xf0108b86,(%esp)
f010517d:	e8 78 f4 ff ff       	call   f01045fa <cprintf>
	// LAB 3: Your code here.
	switch (syscallno){
		case SYS_cputs:
			//cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
f0105182:	be 00 00 00 00       	mov    $0x0,%esi
f0105187:	e9 2d 05 00 00       	jmp    f01056b9 <syscall+0x59e>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010518c:	e8 b7 b4 ff ff       	call   f0100648 <cons_getc>
f0105191:	89 c6                	mov    %eax,%esi
			//cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
		case SYS_cgetc:
			//cprintf("SYS_cgetc\n");
			return sys_cgetc();
f0105193:	e9 21 05 00 00       	jmp    f01056b9 <syscall+0x59e>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105198:	e8 a3 19 00 00       	call   f0106b40 <cpunum>
f010519d:	6b c0 74             	imul   $0x74,%eax,%eax
f01051a0:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01051a6:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_cgetc:
			//cprintf("SYS_cgetc\n");
			return sys_cgetc();
		case SYS_getenvid:
			//cprintf("SYS_getenvid\n");
			return sys_getenvid();
f01051a9:	e9 0b 05 00 00       	jmp    f01056b9 <syscall+0x59e>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01051ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051b5:	00 
f01051b6:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051bd:	89 3c 24             	mov    %edi,(%esp)
f01051c0:	e8 24 eb ff ff       	call   f0103ce9 <envid2env>
f01051c5:	89 c6                	mov    %eax,%esi
f01051c7:	85 c0                	test   %eax,%eax
f01051c9:	0f 88 ea 04 00 00    	js     f01056b9 <syscall+0x59e>
		return r;
	if (e == curenv)
f01051cf:	e8 6c 19 00 00       	call   f0106b40 <cpunum>
f01051d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01051d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01051da:	39 90 28 d0 22 f0    	cmp    %edx,-0xfdd2fd8(%eax)
f01051e0:	75 23                	jne    f0105205 <syscall+0xea>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01051e2:	e8 59 19 00 00       	call   f0106b40 <cpunum>
f01051e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01051ea:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01051f0:	8b 40 48             	mov    0x48(%eax),%eax
f01051f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051f7:	c7 04 24 8b 8b 10 f0 	movl   $0xf0108b8b,(%esp)
f01051fe:	e8 f7 f3 ff ff       	call   f01045fa <cprintf>
f0105203:	eb 28                	jmp    f010522d <syscall+0x112>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105205:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105208:	e8 33 19 00 00       	call   f0106b40 <cpunum>
f010520d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105211:	6b c0 74             	imul   $0x74,%eax,%eax
f0105214:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010521a:	8b 40 48             	mov    0x48(%eax),%eax
f010521d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105221:	c7 04 24 a6 8b 10 f0 	movl   $0xf0108ba6,(%esp)
f0105228:	e8 cd f3 ff ff       	call   f01045fa <cprintf>
	env_destroy(e);
f010522d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105230:	89 04 24             	mov    %eax,(%esp)
f0105233:	e8 e4 f0 ff ff       	call   f010431c <env_destroy>
	return 0;
f0105238:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_getenvid:
			//cprintf("SYS_getenvid\n");
			return sys_getenvid();
		case SYS_env_destroy:
			//cprintf("SYS_env_destroy\n");
			return sys_env_destroy(a1);
f010523d:	e9 77 04 00 00       	jmp    f01056b9 <syscall+0x59e>
		case SYS_yield:
			//cprintf("SYS_yield\n");
			sys_yield();
f0105242:	e8 c9 fe ff ff       	call   f0105110 <sys_yield>

	// LAB 4: Your code here.
//cprintf("**sys_exofork: get into\n");
	struct Env *env;
	int ret;
	if((ret = env_alloc(&env, curenv->env_id)) < 0) {
f0105247:	e8 f4 18 00 00       	call   f0106b40 <cpunum>
f010524c:	6b c0 74             	imul   $0x74,%eax,%eax
f010524f:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105255:	8b 40 48             	mov    0x48(%eax),%eax
f0105258:	89 44 24 04          	mov    %eax,0x4(%esp)
f010525c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010525f:	89 04 24             	mov    %eax,(%esp)
f0105262:	e8 93 eb ff ff       	call   f0103dfa <env_alloc>
f0105267:	89 c6                	mov    %eax,%esi
f0105269:	85 c0                	test   %eax,%eax
f010526b:	0f 88 48 04 00 00    	js     f01056b9 <syscall+0x59e>
//cprintf("**sys_exofork: env_alloc fails\n");
		return ret;
	}

	env->env_status = ENV_NOT_RUNNABLE;
f0105271:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105274:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	env->env_tf = curenv->env_tf;
f010527b:	e8 c0 18 00 00       	call   f0106b40 <cpunum>
f0105280:	6b c0 74             	imul   $0x74,%eax,%eax
f0105283:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
f0105289:	b9 11 00 00 00       	mov    $0x11,%ecx
f010528e:	89 df                	mov    %ebx,%edi
f0105290:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// At the point that system call
	// Why the child does not go into the system call again
	env->env_tf.tf_regs.reg_eax = 0;
f0105292:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105295:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

//cprintf("**sys_exofork: env_id = %x\n", env->env_id);
	return env->env_id;
f010529c:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_yield:
			//cprintf("SYS_yield\n");
			sys_yield();

		case SYS_exofork:
			return sys_exofork();
f010529f:	e9 15 04 00 00       	jmp    f01056b9 <syscall+0x59e>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
f01052a4:	89 f8                	mov    %edi,%eax
f01052a6:	c1 e8 1f             	shr    $0x1f,%eax
f01052a9:	84 c0                	test   %al,%al
f01052ab:	0f 85 f5 00 00 00    	jne    f01053a6 <syscall+0x28b>
f01052b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01052b4:	c1 e8 1f             	shr    $0x1f,%eax
f01052b7:	84 c0                	test   %al,%al
f01052b9:	0f 85 e7 00 00 00    	jne    f01053a6 <syscall+0x28b>
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
f01052bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052c6:	00 
f01052c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01052ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052ce:	89 3c 24             	mov    %edi,(%esp)
f01052d1:	e8 13 ea ff ff       	call   f0103ce9 <envid2env>
		return -E_BAD_ENV;
f01052d6:	be fe ff ff ff       	mov    $0xfffffffe,%esi

	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
f01052db:	85 c0                	test   %eax,%eax
f01052dd:	0f 88 d6 03 00 00    	js     f01056b9 <syscall+0x59e>
f01052e3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052ea:	00 
f01052eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01052ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052f2:	8b 7d 14             	mov    0x14(%ebp),%edi
f01052f5:	89 3c 24             	mov    %edi,(%esp)
f01052f8:	e8 ec e9 ff ff       	call   f0103ce9 <envid2env>
f01052fd:	85 c0                	test   %eax,%eax
f01052ff:	0f 88 ab 00 00 00    	js     f01053b0 <syscall+0x295>
		return -E_BAD_ENV;

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
		return -E_INVAL;
f0105305:	66 be fd ff          	mov    $0xfffd,%si
	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
		return -E_BAD_ENV;

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
f0105309:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010530f:	0f 87 a4 03 00 00    	ja     f01056b9 <syscall+0x59e>
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
f0105315:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f010531b:	0f 85 99 00 00 00    	jne    f01053ba <syscall+0x29f>
f0105321:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105328:	0f 87 8c 00 00 00    	ja     f01053ba <syscall+0x29f>
f010532e:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105335:	0f 85 7e 03 00 00    	jne    f01056b9 <syscall+0x59e>
		return -E_INVAL;

	pte_t *pte;
	struct PageInfo *p;
	if((p = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f010533b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010533e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105342:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105346:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105349:	8b 40 60             	mov    0x60(%eax),%eax
f010534c:	89 04 24             	mov    %eax,(%esp)
f010534f:	e8 f5 c5 ff ff       	call   f0101949 <page_lookup>
f0105354:	85 c0                	test   %eax,%eax
f0105356:	74 6c                	je     f01053c4 <syscall+0x2a9>
		return -E_INVAL;

	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f0105358:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010535b:	83 e2 05             	and    $0x5,%edx
f010535e:	83 fa 05             	cmp    $0x5,%edx
f0105361:	0f 85 52 03 00 00    	jne    f01056b9 <syscall+0x59e>
		return -E_INVAL;

	if(perm & PTE_W && !(*pte & PTE_W))
f0105367:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010536b:	74 0c                	je     f0105379 <syscall+0x25e>
f010536d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105370:	f6 02 02             	testb  $0x2,(%edx)
f0105373:	0f 84 40 03 00 00    	je     f01056b9 <syscall+0x59e>
		return -E_INVAL;

	if(page_insert(dstenv->env_pgdir, p, dstva, perm) < 0)
f0105379:	8b 7d 1c             	mov    0x1c(%ebp),%edi
f010537c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105380:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105383:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105387:	89 44 24 04          	mov    %eax,0x4(%esp)
f010538b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010538e:	8b 40 60             	mov    0x60(%eax),%eax
f0105391:	89 04 24             	mov    %eax,(%esp)
f0105394:	e8 ad c6 ff ff       	call   f0101a46 <page_insert>
		return -E_NO_MEM;
f0105399:	89 c6                	mov    %eax,%esi
f010539b:	c1 fe 1f             	sar    $0x1f,%esi
f010539e:	83 e6 fc             	and    $0xfffffffc,%esi
f01053a1:	e9 13 03 00 00       	jmp    f01056b9 <syscall+0x59e>
	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
		return -E_BAD_ENV;
f01053a6:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01053ab:	e9 09 03 00 00       	jmp    f01056b9 <syscall+0x59e>
f01053b0:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01053b5:	e9 ff 02 00 00       	jmp    f01056b9 <syscall+0x59e>

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
		return -E_INVAL;
f01053ba:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01053bf:	e9 f5 02 00 00       	jmp    f01056b9 <syscall+0x59e>

	pte_t *pte;
	struct PageInfo *p;
	if((p = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f01053c4:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01053c9:	e9 eb 02 00 00       	jmp    f01056b9 <syscall+0x59e>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
f01053ce:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01053d5:	00 
f01053d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053dd:	89 3c 24             	mov    %edi,(%esp)
f01053e0:	e8 04 e9 ff ff       	call   f0103ce9 <envid2env>
f01053e5:	85 c0                	test   %eax,%eax
f01053e7:	78 39                	js     f0105422 <syscall+0x307>
		return -E_BAD_ENV;
	if(va >= (void *)UTOP || (unsigned int)va % PGSIZE != 0)
		return -E_INVAL;
f01053e9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
		return -E_BAD_ENV;
	if(va >= (void *)UTOP || (unsigned int)va % PGSIZE != 0)
f01053ee:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01053f4:	0f 87 bf 02 00 00    	ja     f01056b9 <syscall+0x59e>
f01053fa:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0105400:	0f 85 b3 02 00 00    	jne    f01056b9 <syscall+0x59e>
		return -E_INVAL;

	page_remove(env->env_pgdir, va);
f0105406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010540a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010540d:	8b 40 60             	mov    0x60(%eax),%eax
f0105410:	89 04 24             	mov    %eax,(%esp)
f0105413:	e8 de c5 ff ff       	call   f01019f6 <page_remove>

	return 0;
f0105418:	be 00 00 00 00       	mov    $0x0,%esi
f010541d:	e9 97 02 00 00       	jmp    f01056b9 <syscall+0x59e>

	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
		return -E_BAD_ENV;
f0105422:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105427:	e9 8d 02 00 00       	jmp    f01056b9 <syscall+0x59e>

	// LAB 4: Your code here.

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
f010542c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105433:	00 
f0105434:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105437:	89 44 24 04          	mov    %eax,0x4(%esp)
f010543b:	89 3c 24             	mov    %edi,(%esp)
f010543e:	e8 a6 e8 ff ff       	call   f0103ce9 <envid2env>
f0105443:	85 c0                	test   %eax,%eax
f0105445:	78 67                	js     f01054ae <syscall+0x393>
		return -E_BAD_ENV;
	if(va >= (void *)UTOP)
		return -E_INVAL;
f0105447:	be fd ff ff ff       	mov    $0xfffffffd,%esi

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
	if(va >= (void *)UTOP)
f010544c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105452:	0f 87 61 02 00 00    	ja     f01056b9 <syscall+0x59e>
		return -E_INVAL;
	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f0105458:	8b 45 14             	mov    0x14(%ebp),%eax
f010545b:	83 e0 05             	and    $0x5,%eax
f010545e:	83 f8 05             	cmp    $0x5,%eax
f0105461:	0f 85 52 02 00 00    	jne    f01056b9 <syscall+0x59e>
		return -E_INVAL;

	
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0105467:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010546e:	e8 ef c2 ff ff       	call   f0101762 <page_alloc>
f0105473:	89 c7                	mov    %eax,%edi
	if(!p) {
f0105475:	85 c0                	test   %eax,%eax
f0105477:	74 3f                	je     f01054b8 <syscall+0x39d>
		return -E_NO_MEM;
	}
	p->pp_ref ++;
f0105479:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

	int ret;
	if((ret = page_insert(env->env_pgdir, p, va, perm)) < 0) {
f010547e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105481:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105485:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105489:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010548d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105490:	8b 40 60             	mov    0x60(%eax),%eax
f0105493:	89 04 24             	mov    %eax,(%esp)
f0105496:	e8 ab c5 ff ff       	call   f0101a46 <page_insert>
f010549b:	89 c6                	mov    %eax,%esi
f010549d:	85 c0                	test   %eax,%eax
f010549f:	79 21                	jns    f01054c2 <syscall+0x3a7>
		page_free(p);
f01054a1:	89 3c 24             	mov    %edi,(%esp)
f01054a4:	e8 37 c3 ff ff       	call   f01017e0 <page_free>
f01054a9:	e9 0b 02 00 00       	jmp    f01056b9 <syscall+0x59e>
	// LAB 4: Your code here.

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f01054ae:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01054b3:	e9 01 02 00 00       	jmp    f01056b9 <syscall+0x59e>
		return -E_INVAL;

	
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
	if(!p) {
		return -E_NO_MEM;
f01054b8:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f01054bd:	e9 f7 01 00 00       	jmp    f01056b9 <syscall+0x59e>
	int ret;
	if((ret = page_insert(env->env_pgdir, p, va, perm)) < 0) {
		page_free(p);
		return ret;
	}
	return 0;
f01054c2:	be 00 00 00 00       	mov    $0x0,%esi
			return sys_page_map((envid_t)a1, (void *)a2,
	     		(envid_t)a3, (void *)a4, (int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f01054c7:	e9 ed 01 00 00       	jmp    f01056b9 <syscall+0x59e>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f01054cc:	83 fb 04             	cmp    $0x4,%ebx
f01054cf:	74 0e                	je     f01054df <syscall+0x3c4>
		return -E_INVAL;
f01054d1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f01054d6:	83 fb 02             	cmp    $0x2,%ebx
f01054d9:	0f 85 da 01 00 00    	jne    f01056b9 <syscall+0x59e>
		return -E_INVAL;
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0)
f01054df:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054e6:	00 
f01054e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054ee:	89 3c 24             	mov    %edi,(%esp)
f01054f1:	e8 f3 e7 ff ff       	call   f0103ce9 <envid2env>
f01054f6:	85 c0                	test   %eax,%eax
f01054f8:	78 10                	js     f010550a <syscall+0x3ef>
		return -E_BAD_ENV;

	env->env_status = status;
f01054fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054fd:	89 58 54             	mov    %ebx,0x54(%eax)

	return 0;
f0105500:	be 00 00 00 00       	mov    $0x0,%esi
f0105505:	e9 af 01 00 00       	jmp    f01056b9 <syscall+0x59e>
	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
		return -E_INVAL;
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f010550a:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f010550f:	e9 a5 01 00 00       	jmp    f01056b9 <syscall+0x59e>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
    int ret = envid2env(envid, &e, 1);
f0105514:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010551b:	00 
f010551c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010551f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105523:	89 3c 24             	mov    %edi,(%esp)
f0105526:	e8 be e7 ff ff       	call   f0103ce9 <envid2env>
f010552b:	89 c6                	mov    %eax,%esi
    if (ret) return ret;    //bad_env
f010552d:	85 c0                	test   %eax,%eax
f010552f:	0f 85 84 01 00 00    	jne    f01056b9 <syscall+0x59e>
    e->env_pgfault_upcall = func;
f0105535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105538:	89 58 64             	mov    %ebx,0x64(%eax)
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f010553b:	e9 79 01 00 00       	jmp    f01056b9 <syscall+0x59e>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env *e;
    int ret = envid2env(envid, &e, 0);
f0105540:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105547:	00 
f0105548:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010554b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010554f:	89 3c 24             	mov    %edi,(%esp)
f0105552:	e8 92 e7 ff ff       	call   f0103ce9 <envid2env>
f0105557:	89 c6                	mov    %eax,%esi
    if (ret) return ret;
f0105559:	85 c0                	test   %eax,%eax
f010555b:	0f 85 58 01 00 00    	jne    f01056b9 <syscall+0x59e>

    if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0105561:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105564:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105568:	0f 84 cf 00 00 00    	je     f010563d <syscall+0x522>
    if (srcva < (void*)UTOP) {
f010556e:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105575:	0f 87 91 00 00 00    	ja     f010560c <syscall+0x4f1>
    	// Find the current env's page
        pte_t *pte;
        struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f010557b:	e8 c0 15 00 00       	call   f0106b40 <cpunum>
f0105580:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105583:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105587:	8b 7d 14             	mov    0x14(%ebp),%edi
f010558a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010558e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105591:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105597:	8b 40 60             	mov    0x60(%eax),%eax
f010559a:	89 04 24             	mov    %eax,(%esp)
f010559d:	e8 a7 c3 ff ff       	call   f0101949 <page_lookup>
        if (!pg) return -E_INVAL;
f01055a2:	85 c0                	test   %eax,%eax
f01055a4:	0f 84 9a 00 00 00    	je     f0105644 <syscall+0x529>
        if ((*pte & perm) != perm) return -E_INVAL;
f01055aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01055ad:	8b 12                	mov    (%edx),%edx
f01055af:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01055b2:	21 d1                	and    %edx,%ecx
f01055b4:	39 4d 18             	cmp    %ecx,0x18(%ebp)
f01055b7:	0f 85 8e 00 00 00    	jne    f010564b <syscall+0x530>
        if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f01055bd:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01055c1:	74 09                	je     f01055cc <syscall+0x4b1>
f01055c3:	f6 c2 02             	test   $0x2,%dl
f01055c6:	0f 84 86 00 00 00    	je     f0105652 <syscall+0x537>
        if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
f01055cc:	8b 55 14             	mov    0x14(%ebp),%edx
f01055cf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01055d5:	39 55 14             	cmp    %edx,0x14(%ebp)
f01055d8:	75 7f                	jne    f0105659 <syscall+0x53e>

        // Insert the current env's page into a certain env waiting to recive
        if (e->env_ipc_dstva < (void*)UTOP) {
f01055da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01055dd:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01055e0:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01055e6:	77 24                	ja     f010560c <syscall+0x4f1>
            ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
f01055e8:	8b 7d 18             	mov    0x18(%ebp),%edi
f01055eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01055ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01055f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055f7:	8b 42 60             	mov    0x60(%edx),%eax
f01055fa:	89 04 24             	mov    %eax,(%esp)
f01055fd:	e8 44 c4 ff ff       	call   f0101a46 <page_insert>
            if (ret) return ret;
f0105602:	85 c0                	test   %eax,%eax
f0105604:	75 5a                	jne    f0105660 <syscall+0x545>
            e->env_ipc_perm = perm;
f0105606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105609:	89 78 78             	mov    %edi,0x78(%eax)
        }
    }

    // Update the reciving env
    e->env_ipc_recving = 0;
f010560c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010560f:	c6 47 68 00          	movb   $0x0,0x68(%edi)
    e->env_ipc_from = curenv->env_id;
f0105613:	e8 28 15 00 00       	call   f0106b40 <cpunum>
f0105618:	6b c0 74             	imul   $0x74,%eax,%eax
f010561b:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105621:	8b 40 48             	mov    0x48(%eax),%eax
f0105624:	89 47 74             	mov    %eax,0x74(%edi)
    e->env_ipc_value = value; 
f0105627:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010562a:	89 58 70             	mov    %ebx,0x70(%eax)
    e->env_status = ENV_RUNNABLE;
f010562d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    e->env_tf.tf_regs.reg_eax = 0;
f0105634:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f010563b:	eb 7c                	jmp    f01056b9 <syscall+0x59e>
	// LAB 4: Your code here.
	struct Env *e;
    int ret = envid2env(envid, &e, 0);
    if (ret) return ret;

    if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f010563d:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0105642:	eb 75                	jmp    f01056b9 <syscall+0x59e>
    if (srcva < (void*)UTOP) {
    	// Find the current env's page
        pte_t *pte;
        struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
        if (!pg) return -E_INVAL;
f0105644:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105649:	eb 6e                	jmp    f01056b9 <syscall+0x59e>
        if ((*pte & perm) != perm) return -E_INVAL;
f010564b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105650:	eb 67                	jmp    f01056b9 <syscall+0x59e>
        if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0105652:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105657:	eb 60                	jmp    f01056b9 <syscall+0x59e>
        if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
f0105659:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010565e:	eb 59                	jmp    f01056b9 <syscall+0x59e>

        // Insert the current env's page into a certain env waiting to recive
        if (e->env_ipc_dstva < (void*)UTOP) {
            ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
            if (ret) return ret;
f0105660:	89 c6                	mov    %eax,%esi

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);

		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, 
f0105662:	eb 55                	jmp    f01056b9 <syscall+0x59e>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void*)UTOP) 
f0105664:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010566a:	77 0b                	ja     f0105677 <syscall+0x55c>
        if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
f010566c:	89 f8                	mov    %edi,%eax
f010566e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105673:	39 c7                	cmp    %eax,%edi
f0105675:	75 3d                	jne    f01056b4 <syscall+0x599>
            return -E_INVAL;

    // Set up the parameters to wait
    curenv->env_ipc_recving = 1;
f0105677:	e8 c4 14 00 00       	call   f0106b40 <cpunum>
f010567c:	6b c0 74             	imul   $0x74,%eax,%eax
f010567f:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105685:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0105689:	e8 b2 14 00 00       	call   f0106b40 <cpunum>
f010568e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105691:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105697:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    curenv->env_ipc_dstva = dstva;
f010569e:	e8 9d 14 00 00       	call   f0106b40 <cpunum>
f01056a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01056a6:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01056ac:	89 78 6c             	mov    %edi,0x6c(%eax)
    sys_yield();
f01056af:	e8 5c fa ff ff       	call   f0105110 <sys_yield>

		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, 
				(void *)a3, (unsigned)a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f01056b4:	be fd ff ff ff       	mov    $0xfffffffd,%esi
			
		default: 
			return -E_INVAL;
	}
}
f01056b9:	89 f0                	mov    %esi,%eax
f01056bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01056be:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01056c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01056c4:	89 ec                	mov    %ebp,%esp
f01056c6:	5d                   	pop    %ebp
f01056c7:	c3                   	ret    

f01056c8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01056c8:	55                   	push   %ebp
f01056c9:	89 e5                	mov    %esp,%ebp
f01056cb:	57                   	push   %edi
f01056cc:	56                   	push   %esi
f01056cd:	53                   	push   %ebx
f01056ce:	83 ec 14             	sub    $0x14,%esp
f01056d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01056d4:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01056d7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01056da:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01056dd:	8b 1a                	mov    (%edx),%ebx
f01056df:	8b 01                	mov    (%ecx),%eax
f01056e1:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01056e4:	39 c3                	cmp    %eax,%ebx
f01056e6:	0f 8f 9c 00 00 00    	jg     f0105788 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01056ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01056f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01056f6:	01 d8                	add    %ebx,%eax
f01056f8:	89 c7                	mov    %eax,%edi
f01056fa:	c1 ef 1f             	shr    $0x1f,%edi
f01056fd:	01 c7                	add    %eax,%edi
f01056ff:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105701:	39 df                	cmp    %ebx,%edi
f0105703:	7c 33                	jl     f0105738 <stab_binsearch+0x70>
f0105705:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105708:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010570b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105710:	39 f0                	cmp    %esi,%eax
f0105712:	0f 84 bc 00 00 00    	je     f01057d4 <stab_binsearch+0x10c>
f0105718:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010571c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105720:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0105722:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105725:	39 d8                	cmp    %ebx,%eax
f0105727:	7c 0f                	jl     f0105738 <stab_binsearch+0x70>
f0105729:	0f b6 0a             	movzbl (%edx),%ecx
f010572c:	83 ea 0c             	sub    $0xc,%edx
f010572f:	39 f1                	cmp    %esi,%ecx
f0105731:	75 ef                	jne    f0105722 <stab_binsearch+0x5a>
f0105733:	e9 9e 00 00 00       	jmp    f01057d6 <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105738:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010573b:	eb 3c                	jmp    f0105779 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010573d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105740:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0105742:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105745:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010574c:	eb 2b                	jmp    f0105779 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010574e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105751:	76 14                	jbe    f0105767 <stab_binsearch+0x9f>
			*region_right = m - 1;
f0105753:	83 e8 01             	sub    $0x1,%eax
f0105756:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105759:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010575c:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010575e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105765:	eb 12                	jmp    f0105779 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105767:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010576a:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f010576c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105770:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105772:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105779:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f010577c:	0f 8d 71 ff ff ff    	jge    f01056f3 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105782:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105786:	75 0f                	jne    f0105797 <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0105788:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010578b:	8b 02                	mov    (%edx),%eax
f010578d:	83 e8 01             	sub    $0x1,%eax
f0105790:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105793:	89 01                	mov    %eax,(%ecx)
f0105795:	eb 57                	jmp    f01057ee <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105797:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010579a:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010579c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010579f:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01057a1:	39 c1                	cmp    %eax,%ecx
f01057a3:	7d 28                	jge    f01057cd <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01057a5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01057a8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01057ab:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01057b0:	39 f2                	cmp    %esi,%edx
f01057b2:	74 19                	je     f01057cd <stab_binsearch+0x105>
f01057b4:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01057b8:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01057bc:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01057bf:	39 c1                	cmp    %eax,%ecx
f01057c1:	7d 0a                	jge    f01057cd <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01057c3:	0f b6 1a             	movzbl (%edx),%ebx
f01057c6:	83 ea 0c             	sub    $0xc,%edx
f01057c9:	39 f3                	cmp    %esi,%ebx
f01057cb:	75 ef                	jne    f01057bc <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01057cd:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01057d0:	89 02                	mov    %eax,(%edx)
f01057d2:	eb 1a                	jmp    f01057ee <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01057d4:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01057d6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01057d9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01057dc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01057e0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01057e3:	0f 82 54 ff ff ff    	jb     f010573d <stab_binsearch+0x75>
f01057e9:	e9 60 ff ff ff       	jmp    f010574e <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01057ee:	83 c4 14             	add    $0x14,%esp
f01057f1:	5b                   	pop    %ebx
f01057f2:	5e                   	pop    %esi
f01057f3:	5f                   	pop    %edi
f01057f4:	5d                   	pop    %ebp
f01057f5:	c3                   	ret    

f01057f6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01057f6:	55                   	push   %ebp
f01057f7:	89 e5                	mov    %esp,%ebp
f01057f9:	57                   	push   %edi
f01057fa:	56                   	push   %esi
f01057fb:	53                   	push   %ebx
f01057fc:	83 ec 5c             	sub    $0x5c,%esp
f01057ff:	8b 75 08             	mov    0x8(%ebp),%esi
f0105802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105805:	c7 03 f4 8b 10 f0    	movl   $0xf0108bf4,(%ebx)
	info->eip_line = 0;
f010580b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105812:	c7 43 08 f4 8b 10 f0 	movl   $0xf0108bf4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105819:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105820:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105823:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010582a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105830:	0f 87 d8 00 00 00    	ja     f010590e <debuginfo_eip+0x118>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0105836:	e8 05 13 00 00       	call   f0106b40 <cpunum>
f010583b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105842:	00 
f0105843:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010584a:	00 
f010584b:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105852:	00 
f0105853:	6b c0 74             	imul   $0x74,%eax,%eax
f0105856:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010585c:	89 04 24             	mov    %eax,(%esp)
f010585f:	e8 18 e3 ff ff       	call   f0103b7c <user_mem_check>
f0105864:	89 c2                	mov    %eax,%edx
			return -1;
f0105866:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010586b:	85 d2                	test   %edx,%edx
f010586d:	0f 85 a5 02 00 00    	jne    f0105b18 <debuginfo_eip+0x322>
			return -1;

		stabs = usd->stabs;
f0105873:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105879:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010587c:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105882:	a1 08 00 20 00       	mov    0x200008,%eax
f0105887:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010588a:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105890:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105893:	e8 a8 12 00 00       	call   f0106b40 <cpunum>
f0105898:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010589f:	00 
f01058a0:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01058a7:	00 
f01058a8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01058ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01058af:	6b c0 74             	imul   $0x74,%eax,%eax
f01058b2:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01058b8:	89 04 24             	mov    %eax,(%esp)
f01058bb:	e8 bc e2 ff ff       	call   f0103b7c <user_mem_check>
f01058c0:	89 c2                	mov    %eax,%edx
			return -1;
f01058c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01058c7:	85 d2                	test   %edx,%edx
f01058c9:	0f 85 49 02 00 00    	jne    f0105b18 <debuginfo_eip+0x322>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f01058cf:	e8 6c 12 00 00       	call   f0106b40 <cpunum>
f01058d4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01058db:	00 
f01058dc:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01058df:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01058e2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01058e6:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01058e9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01058ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01058f0:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01058f6:	89 04 24             	mov    %eax,(%esp)
f01058f9:	e8 7e e2 ff ff       	call   f0103b7c <user_mem_check>
f01058fe:	89 c2                	mov    %eax,%edx
			return -1;
f0105900:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105905:	85 d2                	test   %edx,%edx
f0105907:	74 1f                	je     f0105928 <debuginfo_eip+0x132>
f0105909:	e9 0a 02 00 00       	jmp    f0105b18 <debuginfo_eip+0x322>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010590e:	c7 45 c0 40 81 11 f0 	movl   $0xf0118140,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105915:	c7 45 bc 19 48 11 f0 	movl   $0xf0114819,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010591c:	bf 18 48 11 f0       	mov    $0xf0114818,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105921:	c7 45 c4 f4 90 10 f0 	movl   $0xf01090f4,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105928:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010592d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105930:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0105933:	0f 83 df 01 00 00    	jae    f0105b18 <debuginfo_eip+0x322>
f0105939:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010593d:	0f 85 d5 01 00 00    	jne    f0105b18 <debuginfo_eip+0x322>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105943:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010594a:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f010594d:	c1 ff 02             	sar    $0x2,%edi
f0105950:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0105956:	83 e8 01             	sub    $0x1,%eax
f0105959:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010595c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105960:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105967:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010596a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010596d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105970:	e8 53 fd ff ff       	call   f01056c8 <stab_binsearch>
	if (lfile == 0)
f0105975:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0105978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010597d:	85 d2                	test   %edx,%edx
f010597f:	0f 84 93 01 00 00    	je     f0105b18 <debuginfo_eip+0x322>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105985:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0105988:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010598b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010598e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105992:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105999:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010599c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010599f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01059a2:	e8 21 fd ff ff       	call   f01056c8 <stab_binsearch>

	if (lfun <= rfun) {
f01059a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01059ad:	39 d0                	cmp    %edx,%eax
f01059af:	7f 32                	jg     f01059e3 <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01059b1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01059b4:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01059b7:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01059ba:	8b 39                	mov    (%ecx),%edi
f01059bc:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01059bf:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01059c2:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01059c5:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01059c8:	73 09                	jae    f01059d3 <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01059ca:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01059cd:	03 7d bc             	add    -0x44(%ebp),%edi
f01059d0:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01059d3:	8b 49 08             	mov    0x8(%ecx),%ecx
f01059d6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01059d9:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01059db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01059de:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01059e1:	eb 0f                	jmp    f01059f2 <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01059e3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01059e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01059ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01059f2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01059f9:	00 
f01059fa:	8b 43 08             	mov    0x8(%ebx),%eax
f01059fd:	89 04 24             	mov    %eax,(%esp)
f0105a00:	e8 85 0a 00 00       	call   f010648a <strfind>
f0105a05:	2b 43 08             	sub    0x8(%ebx),%eax
f0105a08:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105a0b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a0f:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105a16:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105a19:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105a1c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105a1f:	e8 a4 fc ff ff       	call   f01056c8 <stab_binsearch>

	if(lline <= rline)
f0105a24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0105a27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f0105a2c:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105a2f:	0f 8f e3 00 00 00    	jg     f0105b18 <debuginfo_eip+0x322>
		info->eip_line = stabs[lline].n_desc;
f0105a35:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105a38:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105a3b:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105a40:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105a43:	89 d0                	mov    %edx,%eax
f0105a45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a48:	89 7d b8             	mov    %edi,-0x48(%ebp)
f0105a4b:	39 fa                	cmp    %edi,%edx
f0105a4d:	7c 74                	jl     f0105ac3 <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f0105a4f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105a52:	89 f7                	mov    %esi,%edi
f0105a54:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0105a57:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f0105a5b:	80 f9 84             	cmp    $0x84,%cl
f0105a5e:	74 46                	je     f0105aa6 <debuginfo_eip+0x2b0>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105a60:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0105a64:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105a67:	89 c7                	mov    %eax,%edi
f0105a69:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0105a6c:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105a6f:	eb 1f                	jmp    f0105a90 <debuginfo_eip+0x29a>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105a71:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105a74:	39 c3                	cmp    %eax,%ebx
f0105a76:	7f 48                	jg     f0105ac0 <debuginfo_eip+0x2ca>
	       && stabs[lline].n_type != N_SOL
f0105a78:	89 d6                	mov    %edx,%esi
f0105a7a:	83 ea 0c             	sub    $0xc,%edx
f0105a7d:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f0105a81:	80 f9 84             	cmp    $0x84,%cl
f0105a84:	75 08                	jne    f0105a8e <debuginfo_eip+0x298>
f0105a86:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105a89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105a8c:	eb 18                	jmp    f0105aa6 <debuginfo_eip+0x2b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105a8e:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105a90:	80 f9 64             	cmp    $0x64,%cl
f0105a93:	75 dc                	jne    f0105a71 <debuginfo_eip+0x27b>
f0105a95:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105a99:	74 d6                	je     f0105a71 <debuginfo_eip+0x27b>
f0105a9b:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105a9e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105aa1:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f0105aa4:	7c 1d                	jl     f0105ac3 <debuginfo_eip+0x2cd>
f0105aa6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105aa9:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105aac:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105aaf:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105ab2:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105ab5:	39 d0                	cmp    %edx,%eax
f0105ab7:	73 0a                	jae    f0105ac3 <debuginfo_eip+0x2cd>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105ab9:	03 45 bc             	add    -0x44(%ebp),%eax
f0105abc:	89 03                	mov    %eax,(%ebx)
f0105abe:	eb 03                	jmp    f0105ac3 <debuginfo_eip+0x2cd>
f0105ac0:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105ac3:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105ac6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105ac9:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105acc:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105ad1:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f0105ad4:	7d 42                	jge    f0105b18 <debuginfo_eip+0x322>
		for (lline = lfun + 1;
f0105ad6:	8d 57 01             	lea    0x1(%edi),%edx
f0105ad9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105adc:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0105adf:	7e 37                	jle    f0105b18 <debuginfo_eip+0x322>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105ae1:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0105ae4:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105ae7:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f0105aec:	75 2a                	jne    f0105b18 <debuginfo_eip+0x322>
f0105aee:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105af1:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f0105af5:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105af8:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105afc:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105aff:	39 d1                	cmp    %edx,%ecx
f0105b01:	7e 10                	jle    f0105b13 <debuginfo_eip+0x31d>
f0105b03:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105b06:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0105b0a:	74 ec                	je     f0105af8 <debuginfo_eip+0x302>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105b0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b11:	eb 05                	jmp    f0105b18 <debuginfo_eip+0x322>
f0105b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b18:	83 c4 5c             	add    $0x5c,%esp
f0105b1b:	5b                   	pop    %ebx
f0105b1c:	5e                   	pop    %esi
f0105b1d:	5f                   	pop    %edi
f0105b1e:	5d                   	pop    %ebp
f0105b1f:	c3                   	ret    

f0105b20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105b20:	55                   	push   %ebp
f0105b21:	89 e5                	mov    %esp,%ebp
f0105b23:	57                   	push   %edi
f0105b24:	56                   	push   %esi
f0105b25:	53                   	push   %ebx
f0105b26:	83 ec 3c             	sub    $0x3c,%esp
f0105b29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b2c:	89 d7                	mov    %edx,%edi
f0105b2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b31:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105b34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b37:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105b3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105b3d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105b40:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b45:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105b48:	72 11                	jb     f0105b5b <printnum+0x3b>
f0105b4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b4d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105b50:	76 09                	jbe    f0105b5b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105b52:	83 eb 01             	sub    $0x1,%ebx
f0105b55:	85 db                	test   %ebx,%ebx
f0105b57:	7f 51                	jg     f0105baa <printnum+0x8a>
f0105b59:	eb 5e                	jmp    f0105bb9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105b5b:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105b5f:	83 eb 01             	sub    $0x1,%ebx
f0105b62:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105b66:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b69:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b6d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105b71:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105b75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105b7c:	00 
f0105b7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b80:	89 04 24             	mov    %eax,(%esp)
f0105b83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b8a:	e8 41 14 00 00       	call   f0106fd0 <__udivdi3>
f0105b8f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105b93:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105b97:	89 04 24             	mov    %eax,(%esp)
f0105b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b9e:	89 fa                	mov    %edi,%edx
f0105ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ba3:	e8 78 ff ff ff       	call   f0105b20 <printnum>
f0105ba8:	eb 0f                	jmp    f0105bb9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105baa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bae:	89 34 24             	mov    %esi,(%esp)
f0105bb1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105bb4:	83 eb 01             	sub    $0x1,%ebx
f0105bb7:	75 f1                	jne    f0105baa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105bb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bbd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105bc1:	8b 45 10             	mov    0x10(%ebp),%eax
f0105bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105bcf:	00 
f0105bd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105bd3:	89 04 24             	mov    %eax,(%esp)
f0105bd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bdd:	e8 1e 15 00 00       	call   f0107100 <__umoddi3>
f0105be2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105be6:	0f be 80 fe 8b 10 f0 	movsbl -0xfef7402(%eax),%eax
f0105bed:	89 04 24             	mov    %eax,(%esp)
f0105bf0:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105bf3:	83 c4 3c             	add    $0x3c,%esp
f0105bf6:	5b                   	pop    %ebx
f0105bf7:	5e                   	pop    %esi
f0105bf8:	5f                   	pop    %edi
f0105bf9:	5d                   	pop    %ebp
f0105bfa:	c3                   	ret    

f0105bfb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105bfb:	55                   	push   %ebp
f0105bfc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105bfe:	83 fa 01             	cmp    $0x1,%edx
f0105c01:	7e 0e                	jle    f0105c11 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105c03:	8b 10                	mov    (%eax),%edx
f0105c05:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105c08:	89 08                	mov    %ecx,(%eax)
f0105c0a:	8b 02                	mov    (%edx),%eax
f0105c0c:	8b 52 04             	mov    0x4(%edx),%edx
f0105c0f:	eb 22                	jmp    f0105c33 <getuint+0x38>
	else if (lflag)
f0105c11:	85 d2                	test   %edx,%edx
f0105c13:	74 10                	je     f0105c25 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105c15:	8b 10                	mov    (%eax),%edx
f0105c17:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c1a:	89 08                	mov    %ecx,(%eax)
f0105c1c:	8b 02                	mov    (%edx),%eax
f0105c1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c23:	eb 0e                	jmp    f0105c33 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105c25:	8b 10                	mov    (%eax),%edx
f0105c27:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c2a:	89 08                	mov    %ecx,(%eax)
f0105c2c:	8b 02                	mov    (%edx),%eax
f0105c2e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105c33:	5d                   	pop    %ebp
f0105c34:	c3                   	ret    

f0105c35 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105c35:	55                   	push   %ebp
f0105c36:	89 e5                	mov    %esp,%ebp
f0105c38:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105c3b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105c3f:	8b 10                	mov    (%eax),%edx
f0105c41:	3b 50 04             	cmp    0x4(%eax),%edx
f0105c44:	73 0a                	jae    f0105c50 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c49:	88 0a                	mov    %cl,(%edx)
f0105c4b:	83 c2 01             	add    $0x1,%edx
f0105c4e:	89 10                	mov    %edx,(%eax)
}
f0105c50:	5d                   	pop    %ebp
f0105c51:	c3                   	ret    

f0105c52 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105c52:	55                   	push   %ebp
f0105c53:	89 e5                	mov    %esp,%ebp
f0105c55:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105c58:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105c5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c5f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c62:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c66:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c70:	89 04 24             	mov    %eax,(%esp)
f0105c73:	e8 02 00 00 00       	call   f0105c7a <vprintfmt>
	va_end(ap);
}
f0105c78:	c9                   	leave  
f0105c79:	c3                   	ret    

f0105c7a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105c7a:	55                   	push   %ebp
f0105c7b:	89 e5                	mov    %esp,%ebp
f0105c7d:	57                   	push   %edi
f0105c7e:	56                   	push   %esi
f0105c7f:	53                   	push   %ebx
f0105c80:	83 ec 5c             	sub    $0x5c,%esp
f0105c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105c86:	8b 75 10             	mov    0x10(%ebp),%esi
f0105c89:	eb 12                	jmp    f0105c9d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105c8b:	85 c0                	test   %eax,%eax
f0105c8d:	0f 84 e4 04 00 00    	je     f0106177 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f0105c93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c97:	89 04 24             	mov    %eax,(%esp)
f0105c9a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105c9d:	0f b6 06             	movzbl (%esi),%eax
f0105ca0:	83 c6 01             	add    $0x1,%esi
f0105ca3:	83 f8 25             	cmp    $0x25,%eax
f0105ca6:	75 e3                	jne    f0105c8b <vprintfmt+0x11>
f0105ca8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0105cac:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0105cb3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105cb8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0105cbf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cc4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105cc7:	eb 2b                	jmp    f0105cf4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cc9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105ccc:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0105cd0:	eb 22                	jmp    f0105cf4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cd2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105cd5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0105cd9:	eb 19                	jmp    f0105cf4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cdb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105cde:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105ce5:	eb 0d                	jmp    f0105cf4 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105ce7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105cea:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105ced:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cf4:	0f b6 06             	movzbl (%esi),%eax
f0105cf7:	0f b6 d0             	movzbl %al,%edx
f0105cfa:	8d 7e 01             	lea    0x1(%esi),%edi
f0105cfd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105d00:	83 e8 23             	sub    $0x23,%eax
f0105d03:	3c 55                	cmp    $0x55,%al
f0105d05:	0f 87 46 04 00 00    	ja     f0106151 <vprintfmt+0x4d7>
f0105d0b:	0f b6 c0             	movzbl %al,%eax
f0105d0e:	ff 24 85 e0 8c 10 f0 	jmp    *-0xfef7320(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105d15:	83 ea 30             	sub    $0x30,%edx
f0105d18:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0105d1b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105d1f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d22:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0105d25:	83 fa 09             	cmp    $0x9,%edx
f0105d28:	77 4a                	ja     f0105d74 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d2a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105d2d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105d30:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105d33:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105d37:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105d3a:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105d3d:	83 fa 09             	cmp    $0x9,%edx
f0105d40:	76 eb                	jbe    f0105d2d <vprintfmt+0xb3>
f0105d42:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105d45:	eb 2d                	jmp    f0105d74 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105d47:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d4a:	8d 50 04             	lea    0x4(%eax),%edx
f0105d4d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d50:	8b 00                	mov    (%eax),%eax
f0105d52:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d55:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105d58:	eb 1a                	jmp    f0105d74 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d5a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0105d5d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105d61:	79 91                	jns    f0105cf4 <vprintfmt+0x7a>
f0105d63:	e9 73 ff ff ff       	jmp    f0105cdb <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d68:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105d6b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f0105d72:	eb 80                	jmp    f0105cf4 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0105d74:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105d78:	0f 89 76 ff ff ff    	jns    f0105cf4 <vprintfmt+0x7a>
f0105d7e:	e9 64 ff ff ff       	jmp    f0105ce7 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105d83:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d86:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105d89:	e9 66 ff ff ff       	jmp    f0105cf4 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105d8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d91:	8d 50 04             	lea    0x4(%eax),%edx
f0105d94:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d9b:	8b 00                	mov    (%eax),%eax
f0105d9d:	89 04 24             	mov    %eax,(%esp)
f0105da0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105da3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105da6:	e9 f2 fe ff ff       	jmp    f0105c9d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0105dab:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105daf:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f0105db2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f0105db6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0105db9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0105dbd:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0105dc0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0105dc3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f0105dc7:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105dca:	80 f9 09             	cmp    $0x9,%cl
f0105dcd:	77 1d                	ja     f0105dec <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0105dcf:	0f be c0             	movsbl %al,%eax
f0105dd2:	6b c0 64             	imul   $0x64,%eax,%eax
f0105dd5:	0f be d2             	movsbl %dl,%edx
f0105dd8:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105ddb:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0105de2:	a3 78 34 12 f0       	mov    %eax,0xf0123478
f0105de7:	e9 b1 fe ff ff       	jmp    f0105c9d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0105dec:	c7 44 24 04 16 8c 10 	movl   $0xf0108c16,0x4(%esp)
f0105df3:	f0 
f0105df4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105df7:	89 04 24             	mov    %eax,(%esp)
f0105dfa:	e8 dc 05 00 00       	call   f01063db <strcmp>
f0105dff:	85 c0                	test   %eax,%eax
f0105e01:	75 0f                	jne    f0105e12 <vprintfmt+0x198>
f0105e03:	c7 05 78 34 12 f0 04 	movl   $0x4,0xf0123478
f0105e0a:	00 00 00 
f0105e0d:	e9 8b fe ff ff       	jmp    f0105c9d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0105e12:	c7 44 24 04 1a 8c 10 	movl   $0xf0108c1a,0x4(%esp)
f0105e19:	f0 
f0105e1a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105e1d:	89 14 24             	mov    %edx,(%esp)
f0105e20:	e8 b6 05 00 00       	call   f01063db <strcmp>
f0105e25:	85 c0                	test   %eax,%eax
f0105e27:	75 0f                	jne    f0105e38 <vprintfmt+0x1be>
f0105e29:	c7 05 78 34 12 f0 02 	movl   $0x2,0xf0123478
f0105e30:	00 00 00 
f0105e33:	e9 65 fe ff ff       	jmp    f0105c9d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0105e38:	c7 44 24 04 1e 8c 10 	movl   $0xf0108c1e,0x4(%esp)
f0105e3f:	f0 
f0105e40:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0105e43:	89 0c 24             	mov    %ecx,(%esp)
f0105e46:	e8 90 05 00 00       	call   f01063db <strcmp>
f0105e4b:	85 c0                	test   %eax,%eax
f0105e4d:	75 0f                	jne    f0105e5e <vprintfmt+0x1e4>
f0105e4f:	c7 05 78 34 12 f0 01 	movl   $0x1,0xf0123478
f0105e56:	00 00 00 
f0105e59:	e9 3f fe ff ff       	jmp    f0105c9d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f0105e5e:	c7 44 24 04 22 8c 10 	movl   $0xf0108c22,0x4(%esp)
f0105e65:	f0 
f0105e66:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0105e69:	89 3c 24             	mov    %edi,(%esp)
f0105e6c:	e8 6a 05 00 00       	call   f01063db <strcmp>
f0105e71:	85 c0                	test   %eax,%eax
f0105e73:	75 0f                	jne    f0105e84 <vprintfmt+0x20a>
f0105e75:	c7 05 78 34 12 f0 06 	movl   $0x6,0xf0123478
f0105e7c:	00 00 00 
f0105e7f:	e9 19 fe ff ff       	jmp    f0105c9d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f0105e84:	c7 44 24 04 26 8c 10 	movl   $0xf0108c26,0x4(%esp)
f0105e8b:	f0 
f0105e8c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105e8f:	89 04 24             	mov    %eax,(%esp)
f0105e92:	e8 44 05 00 00       	call   f01063db <strcmp>
f0105e97:	85 c0                	test   %eax,%eax
f0105e99:	75 0f                	jne    f0105eaa <vprintfmt+0x230>
f0105e9b:	c7 05 78 34 12 f0 07 	movl   $0x7,0xf0123478
f0105ea2:	00 00 00 
f0105ea5:	e9 f3 fd ff ff       	jmp    f0105c9d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0105eaa:	c7 44 24 04 2a 8c 10 	movl   $0xf0108c2a,0x4(%esp)
f0105eb1:	f0 
f0105eb2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105eb5:	89 14 24             	mov    %edx,(%esp)
f0105eb8:	e8 1e 05 00 00       	call   f01063db <strcmp>
f0105ebd:	83 f8 01             	cmp    $0x1,%eax
f0105ec0:	19 c0                	sbb    %eax,%eax
f0105ec2:	f7 d0                	not    %eax
f0105ec4:	83 c0 08             	add    $0x8,%eax
f0105ec7:	a3 78 34 12 f0       	mov    %eax,0xf0123478
f0105ecc:	e9 cc fd ff ff       	jmp    f0105c9d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0105ed1:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ed4:	8d 50 04             	lea    0x4(%eax),%edx
f0105ed7:	89 55 14             	mov    %edx,0x14(%ebp)
f0105eda:	8b 00                	mov    (%eax),%eax
f0105edc:	89 c2                	mov    %eax,%edx
f0105ede:	c1 fa 1f             	sar    $0x1f,%edx
f0105ee1:	31 d0                	xor    %edx,%eax
f0105ee3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105ee5:	83 f8 08             	cmp    $0x8,%eax
f0105ee8:	7f 0b                	jg     f0105ef5 <vprintfmt+0x27b>
f0105eea:	8b 14 85 40 8e 10 f0 	mov    -0xfef71c0(,%eax,4),%edx
f0105ef1:	85 d2                	test   %edx,%edx
f0105ef3:	75 23                	jne    f0105f18 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0105ef5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ef9:	c7 44 24 08 2e 8c 10 	movl   $0xf0108c2e,0x8(%esp)
f0105f00:	f0 
f0105f01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f05:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f08:	89 3c 24             	mov    %edi,(%esp)
f0105f0b:	e8 42 fd ff ff       	call   f0105c52 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f10:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105f13:	e9 85 fd ff ff       	jmp    f0105c9d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105f18:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f1c:	c7 44 24 08 1d 84 10 	movl   $0xf010841d,0x8(%esp)
f0105f23:	f0 
f0105f24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f28:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f2b:	89 3c 24             	mov    %edi,(%esp)
f0105f2e:	e8 1f fd ff ff       	call   f0105c52 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f33:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105f36:	e9 62 fd ff ff       	jmp    f0105c9d <vprintfmt+0x23>
f0105f3b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105f3e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105f41:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105f44:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f47:	8d 50 04             	lea    0x4(%eax),%edx
f0105f4a:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f4d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105f4f:	85 f6                	test   %esi,%esi
f0105f51:	b8 0f 8c 10 f0       	mov    $0xf0108c0f,%eax
f0105f56:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105f59:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0105f5d:	7e 06                	jle    f0105f65 <vprintfmt+0x2eb>
f0105f5f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0105f63:	75 13                	jne    f0105f78 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105f65:	0f be 06             	movsbl (%esi),%eax
f0105f68:	83 c6 01             	add    $0x1,%esi
f0105f6b:	85 c0                	test   %eax,%eax
f0105f6d:	0f 85 94 00 00 00    	jne    f0106007 <vprintfmt+0x38d>
f0105f73:	e9 81 00 00 00       	jmp    f0105ff9 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105f78:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f7c:	89 34 24             	mov    %esi,(%esp)
f0105f7f:	e8 67 03 00 00       	call   f01062eb <strnlen>
f0105f84:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105f87:	29 c2                	sub    %eax,%edx
f0105f89:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0105f8c:	85 d2                	test   %edx,%edx
f0105f8e:	7e d5                	jle    f0105f65 <vprintfmt+0x2eb>
					putch(padc, putdat);
f0105f90:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0105f94:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105f97:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0105f9a:	89 d6                	mov    %edx,%esi
f0105f9c:	89 cf                	mov    %ecx,%edi
f0105f9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105fa2:	89 3c 24             	mov    %edi,(%esp)
f0105fa5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105fa8:	83 ee 01             	sub    $0x1,%esi
f0105fab:	75 f1                	jne    f0105f9e <vprintfmt+0x324>
f0105fad:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105fb0:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0105fb3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105fb6:	eb ad                	jmp    f0105f65 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105fb8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0105fbc:	74 1b                	je     f0105fd9 <vprintfmt+0x35f>
f0105fbe:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105fc1:	83 fa 5e             	cmp    $0x5e,%edx
f0105fc4:	76 13                	jbe    f0105fd9 <vprintfmt+0x35f>
					putch('?', putdat);
f0105fc6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fcd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105fd4:	ff 55 08             	call   *0x8(%ebp)
f0105fd7:	eb 0d                	jmp    f0105fe6 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0105fd9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105fdc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105fe0:	89 04 24             	mov    %eax,(%esp)
f0105fe3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105fe6:	83 eb 01             	sub    $0x1,%ebx
f0105fe9:	0f be 06             	movsbl (%esi),%eax
f0105fec:	83 c6 01             	add    $0x1,%esi
f0105fef:	85 c0                	test   %eax,%eax
f0105ff1:	75 1a                	jne    f010600d <vprintfmt+0x393>
f0105ff3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0105ff6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ff9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105ffc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0106000:	7f 1c                	jg     f010601e <vprintfmt+0x3a4>
f0106002:	e9 96 fc ff ff       	jmp    f0105c9d <vprintfmt+0x23>
f0106007:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010600a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010600d:	85 ff                	test   %edi,%edi
f010600f:	78 a7                	js     f0105fb8 <vprintfmt+0x33e>
f0106011:	83 ef 01             	sub    $0x1,%edi
f0106014:	79 a2                	jns    f0105fb8 <vprintfmt+0x33e>
f0106016:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0106019:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010601c:	eb db                	jmp    f0105ff9 <vprintfmt+0x37f>
f010601e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106021:	89 de                	mov    %ebx,%esi
f0106023:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0106026:	89 74 24 04          	mov    %esi,0x4(%esp)
f010602a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106031:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106033:	83 eb 01             	sub    $0x1,%ebx
f0106036:	75 ee                	jne    f0106026 <vprintfmt+0x3ac>
f0106038:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010603a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010603d:	e9 5b fc ff ff       	jmp    f0105c9d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0106042:	83 f9 01             	cmp    $0x1,%ecx
f0106045:	7e 10                	jle    f0106057 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f0106047:	8b 45 14             	mov    0x14(%ebp),%eax
f010604a:	8d 50 08             	lea    0x8(%eax),%edx
f010604d:	89 55 14             	mov    %edx,0x14(%ebp)
f0106050:	8b 30                	mov    (%eax),%esi
f0106052:	8b 78 04             	mov    0x4(%eax),%edi
f0106055:	eb 26                	jmp    f010607d <vprintfmt+0x403>
	else if (lflag)
f0106057:	85 c9                	test   %ecx,%ecx
f0106059:	74 12                	je     f010606d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f010605b:	8b 45 14             	mov    0x14(%ebp),%eax
f010605e:	8d 50 04             	lea    0x4(%eax),%edx
f0106061:	89 55 14             	mov    %edx,0x14(%ebp)
f0106064:	8b 30                	mov    (%eax),%esi
f0106066:	89 f7                	mov    %esi,%edi
f0106068:	c1 ff 1f             	sar    $0x1f,%edi
f010606b:	eb 10                	jmp    f010607d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f010606d:	8b 45 14             	mov    0x14(%ebp),%eax
f0106070:	8d 50 04             	lea    0x4(%eax),%edx
f0106073:	89 55 14             	mov    %edx,0x14(%ebp)
f0106076:	8b 30                	mov    (%eax),%esi
f0106078:	89 f7                	mov    %esi,%edi
f010607a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010607d:	85 ff                	test   %edi,%edi
f010607f:	78 0e                	js     f010608f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0106081:	89 f0                	mov    %esi,%eax
f0106083:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0106085:	be 0a 00 00 00       	mov    $0xa,%esi
f010608a:	e9 84 00 00 00       	jmp    f0106113 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010608f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106093:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010609a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010609d:	89 f0                	mov    %esi,%eax
f010609f:	89 fa                	mov    %edi,%edx
f01060a1:	f7 d8                	neg    %eax
f01060a3:	83 d2 00             	adc    $0x0,%edx
f01060a6:	f7 da                	neg    %edx
			}
			base = 10;
f01060a8:	be 0a 00 00 00       	mov    $0xa,%esi
f01060ad:	eb 64                	jmp    f0106113 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01060af:	89 ca                	mov    %ecx,%edx
f01060b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01060b4:	e8 42 fb ff ff       	call   f0105bfb <getuint>
			base = 10;
f01060b9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f01060be:	eb 53                	jmp    f0106113 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01060c0:	89 ca                	mov    %ecx,%edx
f01060c2:	8d 45 14             	lea    0x14(%ebp),%eax
f01060c5:	e8 31 fb ff ff       	call   f0105bfb <getuint>
    			base = 8;
f01060ca:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f01060cf:	eb 42                	jmp    f0106113 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f01060d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060d5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01060dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01060df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060e3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01060ea:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01060ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01060f0:	8d 50 04             	lea    0x4(%eax),%edx
f01060f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01060f6:	8b 00                	mov    (%eax),%eax
f01060f8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01060fd:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0106102:	eb 0f                	jmp    f0106113 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106104:	89 ca                	mov    %ecx,%edx
f0106106:	8d 45 14             	lea    0x14(%ebp),%eax
f0106109:	e8 ed fa ff ff       	call   f0105bfb <getuint>
			base = 16;
f010610e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106113:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0106117:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010611b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010611e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106122:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106126:	89 04 24             	mov    %eax,(%esp)
f0106129:	89 54 24 04          	mov    %edx,0x4(%esp)
f010612d:	89 da                	mov    %ebx,%edx
f010612f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106132:	e8 e9 f9 ff ff       	call   f0105b20 <printnum>
			break;
f0106137:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010613a:	e9 5e fb ff ff       	jmp    f0105c9d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010613f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106143:	89 14 24             	mov    %edx,(%esp)
f0106146:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106149:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010614c:	e9 4c fb ff ff       	jmp    f0105c9d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0106151:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106155:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010615c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010615f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0106163:	0f 84 34 fb ff ff    	je     f0105c9d <vprintfmt+0x23>
f0106169:	83 ee 01             	sub    $0x1,%esi
f010616c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0106170:	75 f7                	jne    f0106169 <vprintfmt+0x4ef>
f0106172:	e9 26 fb ff ff       	jmp    f0105c9d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0106177:	83 c4 5c             	add    $0x5c,%esp
f010617a:	5b                   	pop    %ebx
f010617b:	5e                   	pop    %esi
f010617c:	5f                   	pop    %edi
f010617d:	5d                   	pop    %ebp
f010617e:	c3                   	ret    

f010617f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010617f:	55                   	push   %ebp
f0106180:	89 e5                	mov    %esp,%ebp
f0106182:	83 ec 28             	sub    $0x28,%esp
f0106185:	8b 45 08             	mov    0x8(%ebp),%eax
f0106188:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010618b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010618e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0106192:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010619c:	85 c0                	test   %eax,%eax
f010619e:	74 30                	je     f01061d0 <vsnprintf+0x51>
f01061a0:	85 d2                	test   %edx,%edx
f01061a2:	7e 2c                	jle    f01061d0 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01061a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01061a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061ab:	8b 45 10             	mov    0x10(%ebp),%eax
f01061ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01061b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061b9:	c7 04 24 35 5c 10 f0 	movl   $0xf0105c35,(%esp)
f01061c0:	e8 b5 fa ff ff       	call   f0105c7a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01061c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01061c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01061cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01061ce:	eb 05                	jmp    f01061d5 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01061d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01061d5:	c9                   	leave  
f01061d6:	c3                   	ret    

f01061d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01061d7:	55                   	push   %ebp
f01061d8:	89 e5                	mov    %esp,%ebp
f01061da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01061dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01061e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061e4:	8b 45 10             	mov    0x10(%ebp),%eax
f01061e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01061ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01061f5:	89 04 24             	mov    %eax,(%esp)
f01061f8:	e8 82 ff ff ff       	call   f010617f <vsnprintf>
	va_end(ap);

	return rc;
}
f01061fd:	c9                   	leave  
f01061fe:	c3                   	ret    
	...

f0106200 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106200:	55                   	push   %ebp
f0106201:	89 e5                	mov    %esp,%ebp
f0106203:	57                   	push   %edi
f0106204:	56                   	push   %esi
f0106205:	53                   	push   %ebx
f0106206:	83 ec 1c             	sub    $0x1c,%esp
f0106209:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010620c:	85 c0                	test   %eax,%eax
f010620e:	74 10                	je     f0106220 <readline+0x20>
		cprintf("%s", prompt);
f0106210:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106214:	c7 04 24 1d 84 10 f0 	movl   $0xf010841d,(%esp)
f010621b:	e8 da e3 ff ff       	call   f01045fa <cprintf>

	i = 0;
	echoing = iscons(0);
f0106220:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106227:	e8 8e a5 ff ff       	call   f01007ba <iscons>
f010622c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010622e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0106233:	e8 71 a5 ff ff       	call   f01007a9 <getchar>
f0106238:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010623a:	85 c0                	test   %eax,%eax
f010623c:	79 17                	jns    f0106255 <readline+0x55>
			cprintf("read error: %e\n", c);
f010623e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106242:	c7 04 24 64 8e 10 f0 	movl   $0xf0108e64,(%esp)
f0106249:	e8 ac e3 ff ff       	call   f01045fa <cprintf>
			return NULL;
f010624e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106253:	eb 6d                	jmp    f01062c2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106255:	83 f8 08             	cmp    $0x8,%eax
f0106258:	74 05                	je     f010625f <readline+0x5f>
f010625a:	83 f8 7f             	cmp    $0x7f,%eax
f010625d:	75 19                	jne    f0106278 <readline+0x78>
f010625f:	85 f6                	test   %esi,%esi
f0106261:	7e 15                	jle    f0106278 <readline+0x78>
			if (echoing)
f0106263:	85 ff                	test   %edi,%edi
f0106265:	74 0c                	je     f0106273 <readline+0x73>
				cputchar('\b');
f0106267:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010626e:	e8 26 a5 ff ff       	call   f0100799 <cputchar>
			i--;
f0106273:	83 ee 01             	sub    $0x1,%esi
f0106276:	eb bb                	jmp    f0106233 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106278:	83 fb 1f             	cmp    $0x1f,%ebx
f010627b:	7e 1f                	jle    f010629c <readline+0x9c>
f010627d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106283:	7f 17                	jg     f010629c <readline+0x9c>
			if (echoing)
f0106285:	85 ff                	test   %edi,%edi
f0106287:	74 08                	je     f0106291 <readline+0x91>
				cputchar(c);
f0106289:	89 1c 24             	mov    %ebx,(%esp)
f010628c:	e8 08 a5 ff ff       	call   f0100799 <cputchar>
			buf[i++] = c;
f0106291:	88 9e 80 ca 22 f0    	mov    %bl,-0xfdd3580(%esi)
f0106297:	83 c6 01             	add    $0x1,%esi
f010629a:	eb 97                	jmp    f0106233 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010629c:	83 fb 0a             	cmp    $0xa,%ebx
f010629f:	74 05                	je     f01062a6 <readline+0xa6>
f01062a1:	83 fb 0d             	cmp    $0xd,%ebx
f01062a4:	75 8d                	jne    f0106233 <readline+0x33>
			if (echoing)
f01062a6:	85 ff                	test   %edi,%edi
f01062a8:	74 0c                	je     f01062b6 <readline+0xb6>
				cputchar('\n');
f01062aa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01062b1:	e8 e3 a4 ff ff       	call   f0100799 <cputchar>
			buf[i] = 0;
f01062b6:	c6 86 80 ca 22 f0 00 	movb   $0x0,-0xfdd3580(%esi)
			return buf;
f01062bd:	b8 80 ca 22 f0       	mov    $0xf022ca80,%eax
		}
	}
}
f01062c2:	83 c4 1c             	add    $0x1c,%esp
f01062c5:	5b                   	pop    %ebx
f01062c6:	5e                   	pop    %esi
f01062c7:	5f                   	pop    %edi
f01062c8:	5d                   	pop    %ebp
f01062c9:	c3                   	ret    
f01062ca:	00 00                	add    %al,(%eax)
f01062cc:	00 00                	add    %al,(%eax)
	...

f01062d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01062d0:	55                   	push   %ebp
f01062d1:	89 e5                	mov    %esp,%ebp
f01062d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01062d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01062db:	80 3a 00             	cmpb   $0x0,(%edx)
f01062de:	74 09                	je     f01062e9 <strlen+0x19>
		n++;
f01062e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01062e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01062e7:	75 f7                	jne    f01062e0 <strlen+0x10>
		n++;
	return n;
}
f01062e9:	5d                   	pop    %ebp
f01062ea:	c3                   	ret    

f01062eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01062eb:	55                   	push   %ebp
f01062ec:	89 e5                	mov    %esp,%ebp
f01062ee:	53                   	push   %ebx
f01062ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01062f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01062f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01062fa:	85 c9                	test   %ecx,%ecx
f01062fc:	74 1a                	je     f0106318 <strnlen+0x2d>
f01062fe:	80 3b 00             	cmpb   $0x0,(%ebx)
f0106301:	74 15                	je     f0106318 <strnlen+0x2d>
f0106303:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0106308:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010630a:	39 ca                	cmp    %ecx,%edx
f010630c:	74 0a                	je     f0106318 <strnlen+0x2d>
f010630e:	83 c2 01             	add    $0x1,%edx
f0106311:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0106316:	75 f0                	jne    f0106308 <strnlen+0x1d>
		n++;
	return n;
}
f0106318:	5b                   	pop    %ebx
f0106319:	5d                   	pop    %ebp
f010631a:	c3                   	ret    

f010631b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010631b:	55                   	push   %ebp
f010631c:	89 e5                	mov    %esp,%ebp
f010631e:	53                   	push   %ebx
f010631f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106325:	ba 00 00 00 00       	mov    $0x0,%edx
f010632a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010632e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0106331:	83 c2 01             	add    $0x1,%edx
f0106334:	84 c9                	test   %cl,%cl
f0106336:	75 f2                	jne    f010632a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0106338:	5b                   	pop    %ebx
f0106339:	5d                   	pop    %ebp
f010633a:	c3                   	ret    

f010633b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010633b:	55                   	push   %ebp
f010633c:	89 e5                	mov    %esp,%ebp
f010633e:	53                   	push   %ebx
f010633f:	83 ec 08             	sub    $0x8,%esp
f0106342:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106345:	89 1c 24             	mov    %ebx,(%esp)
f0106348:	e8 83 ff ff ff       	call   f01062d0 <strlen>
	strcpy(dst + len, src);
f010634d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106350:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106354:	01 d8                	add    %ebx,%eax
f0106356:	89 04 24             	mov    %eax,(%esp)
f0106359:	e8 bd ff ff ff       	call   f010631b <strcpy>
	return dst;
}
f010635e:	89 d8                	mov    %ebx,%eax
f0106360:	83 c4 08             	add    $0x8,%esp
f0106363:	5b                   	pop    %ebx
f0106364:	5d                   	pop    %ebp
f0106365:	c3                   	ret    

f0106366 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106366:	55                   	push   %ebp
f0106367:	89 e5                	mov    %esp,%ebp
f0106369:	56                   	push   %esi
f010636a:	53                   	push   %ebx
f010636b:	8b 45 08             	mov    0x8(%ebp),%eax
f010636e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106371:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106374:	85 f6                	test   %esi,%esi
f0106376:	74 18                	je     f0106390 <strncpy+0x2a>
f0106378:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010637d:	0f b6 1a             	movzbl (%edx),%ebx
f0106380:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106383:	80 3a 01             	cmpb   $0x1,(%edx)
f0106386:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106389:	83 c1 01             	add    $0x1,%ecx
f010638c:	39 f1                	cmp    %esi,%ecx
f010638e:	75 ed                	jne    f010637d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106390:	5b                   	pop    %ebx
f0106391:	5e                   	pop    %esi
f0106392:	5d                   	pop    %ebp
f0106393:	c3                   	ret    

f0106394 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106394:	55                   	push   %ebp
f0106395:	89 e5                	mov    %esp,%ebp
f0106397:	57                   	push   %edi
f0106398:	56                   	push   %esi
f0106399:	53                   	push   %ebx
f010639a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010639d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01063a0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01063a3:	89 f8                	mov    %edi,%eax
f01063a5:	85 f6                	test   %esi,%esi
f01063a7:	74 2b                	je     f01063d4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01063a9:	83 fe 01             	cmp    $0x1,%esi
f01063ac:	74 23                	je     f01063d1 <strlcpy+0x3d>
f01063ae:	0f b6 0b             	movzbl (%ebx),%ecx
f01063b1:	84 c9                	test   %cl,%cl
f01063b3:	74 1c                	je     f01063d1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01063b5:	83 ee 02             	sub    $0x2,%esi
f01063b8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01063bd:	88 08                	mov    %cl,(%eax)
f01063bf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01063c2:	39 f2                	cmp    %esi,%edx
f01063c4:	74 0b                	je     f01063d1 <strlcpy+0x3d>
f01063c6:	83 c2 01             	add    $0x1,%edx
f01063c9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01063cd:	84 c9                	test   %cl,%cl
f01063cf:	75 ec                	jne    f01063bd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01063d1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01063d4:	29 f8                	sub    %edi,%eax
}
f01063d6:	5b                   	pop    %ebx
f01063d7:	5e                   	pop    %esi
f01063d8:	5f                   	pop    %edi
f01063d9:	5d                   	pop    %ebp
f01063da:	c3                   	ret    

f01063db <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01063db:	55                   	push   %ebp
f01063dc:	89 e5                	mov    %esp,%ebp
f01063de:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01063e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01063e4:	0f b6 01             	movzbl (%ecx),%eax
f01063e7:	84 c0                	test   %al,%al
f01063e9:	74 16                	je     f0106401 <strcmp+0x26>
f01063eb:	3a 02                	cmp    (%edx),%al
f01063ed:	75 12                	jne    f0106401 <strcmp+0x26>
		p++, q++;
f01063ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01063f2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01063f6:	84 c0                	test   %al,%al
f01063f8:	74 07                	je     f0106401 <strcmp+0x26>
f01063fa:	83 c1 01             	add    $0x1,%ecx
f01063fd:	3a 02                	cmp    (%edx),%al
f01063ff:	74 ee                	je     f01063ef <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106401:	0f b6 c0             	movzbl %al,%eax
f0106404:	0f b6 12             	movzbl (%edx),%edx
f0106407:	29 d0                	sub    %edx,%eax
}
f0106409:	5d                   	pop    %ebp
f010640a:	c3                   	ret    

f010640b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010640b:	55                   	push   %ebp
f010640c:	89 e5                	mov    %esp,%ebp
f010640e:	53                   	push   %ebx
f010640f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106412:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106415:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106418:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010641d:	85 d2                	test   %edx,%edx
f010641f:	74 28                	je     f0106449 <strncmp+0x3e>
f0106421:	0f b6 01             	movzbl (%ecx),%eax
f0106424:	84 c0                	test   %al,%al
f0106426:	74 24                	je     f010644c <strncmp+0x41>
f0106428:	3a 03                	cmp    (%ebx),%al
f010642a:	75 20                	jne    f010644c <strncmp+0x41>
f010642c:	83 ea 01             	sub    $0x1,%edx
f010642f:	74 13                	je     f0106444 <strncmp+0x39>
		n--, p++, q++;
f0106431:	83 c1 01             	add    $0x1,%ecx
f0106434:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106437:	0f b6 01             	movzbl (%ecx),%eax
f010643a:	84 c0                	test   %al,%al
f010643c:	74 0e                	je     f010644c <strncmp+0x41>
f010643e:	3a 03                	cmp    (%ebx),%al
f0106440:	74 ea                	je     f010642c <strncmp+0x21>
f0106442:	eb 08                	jmp    f010644c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106444:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106449:	5b                   	pop    %ebx
f010644a:	5d                   	pop    %ebp
f010644b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010644c:	0f b6 01             	movzbl (%ecx),%eax
f010644f:	0f b6 13             	movzbl (%ebx),%edx
f0106452:	29 d0                	sub    %edx,%eax
f0106454:	eb f3                	jmp    f0106449 <strncmp+0x3e>

f0106456 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106456:	55                   	push   %ebp
f0106457:	89 e5                	mov    %esp,%ebp
f0106459:	8b 45 08             	mov    0x8(%ebp),%eax
f010645c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106460:	0f b6 10             	movzbl (%eax),%edx
f0106463:	84 d2                	test   %dl,%dl
f0106465:	74 1c                	je     f0106483 <strchr+0x2d>
		if (*s == c)
f0106467:	38 ca                	cmp    %cl,%dl
f0106469:	75 09                	jne    f0106474 <strchr+0x1e>
f010646b:	eb 1b                	jmp    f0106488 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010646d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0106470:	38 ca                	cmp    %cl,%dl
f0106472:	74 14                	je     f0106488 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106474:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0106478:	84 d2                	test   %dl,%dl
f010647a:	75 f1                	jne    f010646d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f010647c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106481:	eb 05                	jmp    f0106488 <strchr+0x32>
f0106483:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106488:	5d                   	pop    %ebp
f0106489:	c3                   	ret    

f010648a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010648a:	55                   	push   %ebp
f010648b:	89 e5                	mov    %esp,%ebp
f010648d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106490:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106494:	0f b6 10             	movzbl (%eax),%edx
f0106497:	84 d2                	test   %dl,%dl
f0106499:	74 14                	je     f01064af <strfind+0x25>
		if (*s == c)
f010649b:	38 ca                	cmp    %cl,%dl
f010649d:	75 06                	jne    f01064a5 <strfind+0x1b>
f010649f:	eb 0e                	jmp    f01064af <strfind+0x25>
f01064a1:	38 ca                	cmp    %cl,%dl
f01064a3:	74 0a                	je     f01064af <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01064a5:	83 c0 01             	add    $0x1,%eax
f01064a8:	0f b6 10             	movzbl (%eax),%edx
f01064ab:	84 d2                	test   %dl,%dl
f01064ad:	75 f2                	jne    f01064a1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01064af:	5d                   	pop    %ebp
f01064b0:	c3                   	ret    

f01064b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01064b1:	55                   	push   %ebp
f01064b2:	89 e5                	mov    %esp,%ebp
f01064b4:	83 ec 0c             	sub    $0xc,%esp
f01064b7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01064ba:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01064bd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01064c0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01064c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01064c9:	85 c9                	test   %ecx,%ecx
f01064cb:	74 30                	je     f01064fd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01064cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01064d3:	75 25                	jne    f01064fa <memset+0x49>
f01064d5:	f6 c1 03             	test   $0x3,%cl
f01064d8:	75 20                	jne    f01064fa <memset+0x49>
		c &= 0xFF;
f01064da:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01064dd:	89 d3                	mov    %edx,%ebx
f01064df:	c1 e3 08             	shl    $0x8,%ebx
f01064e2:	89 d6                	mov    %edx,%esi
f01064e4:	c1 e6 18             	shl    $0x18,%esi
f01064e7:	89 d0                	mov    %edx,%eax
f01064e9:	c1 e0 10             	shl    $0x10,%eax
f01064ec:	09 f0                	or     %esi,%eax
f01064ee:	09 d0                	or     %edx,%eax
f01064f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01064f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01064f5:	fc                   	cld    
f01064f6:	f3 ab                	rep stos %eax,%es:(%edi)
f01064f8:	eb 03                	jmp    f01064fd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01064fa:	fc                   	cld    
f01064fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01064fd:	89 f8                	mov    %edi,%eax
f01064ff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106502:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106505:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106508:	89 ec                	mov    %ebp,%esp
f010650a:	5d                   	pop    %ebp
f010650b:	c3                   	ret    

f010650c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010650c:	55                   	push   %ebp
f010650d:	89 e5                	mov    %esp,%ebp
f010650f:	83 ec 08             	sub    $0x8,%esp
f0106512:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106515:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106518:	8b 45 08             	mov    0x8(%ebp),%eax
f010651b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010651e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106521:	39 c6                	cmp    %eax,%esi
f0106523:	73 36                	jae    f010655b <memmove+0x4f>
f0106525:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106528:	39 d0                	cmp    %edx,%eax
f010652a:	73 2f                	jae    f010655b <memmove+0x4f>
		s += n;
		d += n;
f010652c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010652f:	f6 c2 03             	test   $0x3,%dl
f0106532:	75 1b                	jne    f010654f <memmove+0x43>
f0106534:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010653a:	75 13                	jne    f010654f <memmove+0x43>
f010653c:	f6 c1 03             	test   $0x3,%cl
f010653f:	75 0e                	jne    f010654f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106541:	83 ef 04             	sub    $0x4,%edi
f0106544:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106547:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010654a:	fd                   	std    
f010654b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010654d:	eb 09                	jmp    f0106558 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010654f:	83 ef 01             	sub    $0x1,%edi
f0106552:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106555:	fd                   	std    
f0106556:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106558:	fc                   	cld    
f0106559:	eb 20                	jmp    f010657b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010655b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106561:	75 13                	jne    f0106576 <memmove+0x6a>
f0106563:	a8 03                	test   $0x3,%al
f0106565:	75 0f                	jne    f0106576 <memmove+0x6a>
f0106567:	f6 c1 03             	test   $0x3,%cl
f010656a:	75 0a                	jne    f0106576 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010656c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010656f:	89 c7                	mov    %eax,%edi
f0106571:	fc                   	cld    
f0106572:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106574:	eb 05                	jmp    f010657b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106576:	89 c7                	mov    %eax,%edi
f0106578:	fc                   	cld    
f0106579:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010657b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010657e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106581:	89 ec                	mov    %ebp,%esp
f0106583:	5d                   	pop    %ebp
f0106584:	c3                   	ret    

f0106585 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106585:	55                   	push   %ebp
f0106586:	89 e5                	mov    %esp,%ebp
f0106588:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010658b:	8b 45 10             	mov    0x10(%ebp),%eax
f010658e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106592:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106595:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106599:	8b 45 08             	mov    0x8(%ebp),%eax
f010659c:	89 04 24             	mov    %eax,(%esp)
f010659f:	e8 68 ff ff ff       	call   f010650c <memmove>
}
f01065a4:	c9                   	leave  
f01065a5:	c3                   	ret    

f01065a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01065a6:	55                   	push   %ebp
f01065a7:	89 e5                	mov    %esp,%ebp
f01065a9:	57                   	push   %edi
f01065aa:	56                   	push   %esi
f01065ab:	53                   	push   %ebx
f01065ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01065af:	8b 75 0c             	mov    0xc(%ebp),%esi
f01065b2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01065b5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065ba:	85 ff                	test   %edi,%edi
f01065bc:	74 37                	je     f01065f5 <memcmp+0x4f>
		if (*s1 != *s2)
f01065be:	0f b6 03             	movzbl (%ebx),%eax
f01065c1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065c4:	83 ef 01             	sub    $0x1,%edi
f01065c7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f01065cc:	38 c8                	cmp    %cl,%al
f01065ce:	74 1c                	je     f01065ec <memcmp+0x46>
f01065d0:	eb 10                	jmp    f01065e2 <memcmp+0x3c>
f01065d2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01065d7:	83 c2 01             	add    $0x1,%edx
f01065da:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01065de:	38 c8                	cmp    %cl,%al
f01065e0:	74 0a                	je     f01065ec <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f01065e2:	0f b6 c0             	movzbl %al,%eax
f01065e5:	0f b6 c9             	movzbl %cl,%ecx
f01065e8:	29 c8                	sub    %ecx,%eax
f01065ea:	eb 09                	jmp    f01065f5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065ec:	39 fa                	cmp    %edi,%edx
f01065ee:	75 e2                	jne    f01065d2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01065f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01065f5:	5b                   	pop    %ebx
f01065f6:	5e                   	pop    %esi
f01065f7:	5f                   	pop    %edi
f01065f8:	5d                   	pop    %ebp
f01065f9:	c3                   	ret    

f01065fa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01065fa:	55                   	push   %ebp
f01065fb:	89 e5                	mov    %esp,%ebp
f01065fd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106600:	89 c2                	mov    %eax,%edx
f0106602:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106605:	39 d0                	cmp    %edx,%eax
f0106607:	73 19                	jae    f0106622 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106609:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010660d:	38 08                	cmp    %cl,(%eax)
f010660f:	75 06                	jne    f0106617 <memfind+0x1d>
f0106611:	eb 0f                	jmp    f0106622 <memfind+0x28>
f0106613:	38 08                	cmp    %cl,(%eax)
f0106615:	74 0b                	je     f0106622 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106617:	83 c0 01             	add    $0x1,%eax
f010661a:	39 d0                	cmp    %edx,%eax
f010661c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106620:	75 f1                	jne    f0106613 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106622:	5d                   	pop    %ebp
f0106623:	c3                   	ret    

f0106624 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106624:	55                   	push   %ebp
f0106625:	89 e5                	mov    %esp,%ebp
f0106627:	57                   	push   %edi
f0106628:	56                   	push   %esi
f0106629:	53                   	push   %ebx
f010662a:	8b 55 08             	mov    0x8(%ebp),%edx
f010662d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106630:	0f b6 02             	movzbl (%edx),%eax
f0106633:	3c 20                	cmp    $0x20,%al
f0106635:	74 04                	je     f010663b <strtol+0x17>
f0106637:	3c 09                	cmp    $0x9,%al
f0106639:	75 0e                	jne    f0106649 <strtol+0x25>
		s++;
f010663b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010663e:	0f b6 02             	movzbl (%edx),%eax
f0106641:	3c 20                	cmp    $0x20,%al
f0106643:	74 f6                	je     f010663b <strtol+0x17>
f0106645:	3c 09                	cmp    $0x9,%al
f0106647:	74 f2                	je     f010663b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106649:	3c 2b                	cmp    $0x2b,%al
f010664b:	75 0a                	jne    f0106657 <strtol+0x33>
		s++;
f010664d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106650:	bf 00 00 00 00       	mov    $0x0,%edi
f0106655:	eb 10                	jmp    f0106667 <strtol+0x43>
f0106657:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010665c:	3c 2d                	cmp    $0x2d,%al
f010665e:	75 07                	jne    f0106667 <strtol+0x43>
		s++, neg = 1;
f0106660:	83 c2 01             	add    $0x1,%edx
f0106663:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106667:	85 db                	test   %ebx,%ebx
f0106669:	0f 94 c0             	sete   %al
f010666c:	74 05                	je     f0106673 <strtol+0x4f>
f010666e:	83 fb 10             	cmp    $0x10,%ebx
f0106671:	75 15                	jne    f0106688 <strtol+0x64>
f0106673:	80 3a 30             	cmpb   $0x30,(%edx)
f0106676:	75 10                	jne    f0106688 <strtol+0x64>
f0106678:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010667c:	75 0a                	jne    f0106688 <strtol+0x64>
		s += 2, base = 16;
f010667e:	83 c2 02             	add    $0x2,%edx
f0106681:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106686:	eb 13                	jmp    f010669b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0106688:	84 c0                	test   %al,%al
f010668a:	74 0f                	je     f010669b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010668c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106691:	80 3a 30             	cmpb   $0x30,(%edx)
f0106694:	75 05                	jne    f010669b <strtol+0x77>
		s++, base = 8;
f0106696:	83 c2 01             	add    $0x1,%edx
f0106699:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010669b:	b8 00 00 00 00       	mov    $0x0,%eax
f01066a0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01066a2:	0f b6 0a             	movzbl (%edx),%ecx
f01066a5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01066a8:	80 fb 09             	cmp    $0x9,%bl
f01066ab:	77 08                	ja     f01066b5 <strtol+0x91>
			dig = *s - '0';
f01066ad:	0f be c9             	movsbl %cl,%ecx
f01066b0:	83 e9 30             	sub    $0x30,%ecx
f01066b3:	eb 1e                	jmp    f01066d3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f01066b5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01066b8:	80 fb 19             	cmp    $0x19,%bl
f01066bb:	77 08                	ja     f01066c5 <strtol+0xa1>
			dig = *s - 'a' + 10;
f01066bd:	0f be c9             	movsbl %cl,%ecx
f01066c0:	83 e9 57             	sub    $0x57,%ecx
f01066c3:	eb 0e                	jmp    f01066d3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f01066c5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01066c8:	80 fb 19             	cmp    $0x19,%bl
f01066cb:	77 14                	ja     f01066e1 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01066cd:	0f be c9             	movsbl %cl,%ecx
f01066d0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01066d3:	39 f1                	cmp    %esi,%ecx
f01066d5:	7d 0e                	jge    f01066e5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01066d7:	83 c2 01             	add    $0x1,%edx
f01066da:	0f af c6             	imul   %esi,%eax
f01066dd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01066df:	eb c1                	jmp    f01066a2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01066e1:	89 c1                	mov    %eax,%ecx
f01066e3:	eb 02                	jmp    f01066e7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01066e5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01066e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01066eb:	74 05                	je     f01066f2 <strtol+0xce>
		*endptr = (char *) s;
f01066ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01066f0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01066f2:	89 ca                	mov    %ecx,%edx
f01066f4:	f7 da                	neg    %edx
f01066f6:	85 ff                	test   %edi,%edi
f01066f8:	0f 45 c2             	cmovne %edx,%eax
}
f01066fb:	5b                   	pop    %ebx
f01066fc:	5e                   	pop    %esi
f01066fd:	5f                   	pop    %edi
f01066fe:	5d                   	pop    %ebp
f01066ff:	c3                   	ret    

f0106700 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106700:	fa                   	cli    

	xorw    %ax, %ax
f0106701:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106703:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106705:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106707:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106709:	0f 01 16             	lgdtl  (%esi)
f010670c:	74 70                	je     f010677e <mpentry_end+0x4>
	movl    %cr0, %eax
f010670e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106711:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106715:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106718:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010671e:	08 00                	or     %al,(%eax)

f0106720 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106720:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106724:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106726:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106728:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010672a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010672e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106730:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106732:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0106737:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010673a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010673d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106742:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106745:	8b 25 84 ce 22 f0    	mov    0xf022ce84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010674b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106750:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106755:	ff d0                	call   *%eax

f0106757 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106757:	eb fe                	jmp    f0106757 <spin>
f0106759:	8d 76 00             	lea    0x0(%esi),%esi

f010675c <gdt>:
	...
f0106764:	ff                   	(bad)  
f0106765:	ff 00                	incl   (%eax)
f0106767:	00 00                	add    %al,(%eax)
f0106769:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106770:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106774 <gdtdesc>:
f0106774:	17                   	pop    %ss
f0106775:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010677a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010677a:	90                   	nop
f010677b:	00 00                	add    %al,(%eax)
f010677d:	00 00                	add    %al,(%eax)
	...

f0106780 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106780:	55                   	push   %ebp
f0106781:	89 e5                	mov    %esp,%ebp
f0106783:	56                   	push   %esi
f0106784:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106785:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010678a:	85 d2                	test   %edx,%edx
f010678c:	7e 12                	jle    f01067a0 <sum+0x20>
f010678e:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0106793:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106797:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106799:	83 c1 01             	add    $0x1,%ecx
f010679c:	39 d1                	cmp    %edx,%ecx
f010679e:	75 f3                	jne    f0106793 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01067a0:	89 d8                	mov    %ebx,%eax
f01067a2:	5b                   	pop    %ebx
f01067a3:	5e                   	pop    %esi
f01067a4:	5d                   	pop    %ebp
f01067a5:	c3                   	ret    

f01067a6 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01067a6:	55                   	push   %ebp
f01067a7:	89 e5                	mov    %esp,%ebp
f01067a9:	56                   	push   %esi
f01067aa:	53                   	push   %ebx
f01067ab:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01067ae:	8b 0d 88 ce 22 f0    	mov    0xf022ce88,%ecx
f01067b4:	89 c3                	mov    %eax,%ebx
f01067b6:	c1 eb 0c             	shr    $0xc,%ebx
f01067b9:	39 cb                	cmp    %ecx,%ebx
f01067bb:	72 20                	jb     f01067dd <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01067bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01067c1:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01067c8:	f0 
f01067c9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01067d0:	00 
f01067d1:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f01067d8:	e8 63 98 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01067dd:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01067e0:	89 f2                	mov    %esi,%edx
f01067e2:	c1 ea 0c             	shr    $0xc,%edx
f01067e5:	39 d1                	cmp    %edx,%ecx
f01067e7:	77 20                	ja     f0106809 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01067e9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01067ed:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f01067f4:	f0 
f01067f5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01067fc:	00 
f01067fd:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f0106804:	e8 37 98 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106809:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010680f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106815:	39 f3                	cmp    %esi,%ebx
f0106817:	73 3a                	jae    f0106853 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106819:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106820:	00 
f0106821:	c7 44 24 04 11 90 10 	movl   $0xf0109011,0x4(%esp)
f0106828:	f0 
f0106829:	89 1c 24             	mov    %ebx,(%esp)
f010682c:	e8 75 fd ff ff       	call   f01065a6 <memcmp>
f0106831:	85 c0                	test   %eax,%eax
f0106833:	75 10                	jne    f0106845 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106835:	ba 10 00 00 00       	mov    $0x10,%edx
f010683a:	89 d8                	mov    %ebx,%eax
f010683c:	e8 3f ff ff ff       	call   f0106780 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106841:	84 c0                	test   %al,%al
f0106843:	74 13                	je     f0106858 <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106845:	83 c3 10             	add    $0x10,%ebx
f0106848:	39 f3                	cmp    %esi,%ebx
f010684a:	72 cd                	jb     f0106819 <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010684c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106851:	eb 05                	jmp    f0106858 <mpsearch1+0xb2>
f0106853:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106858:	89 d8                	mov    %ebx,%eax
f010685a:	83 c4 10             	add    $0x10,%esp
f010685d:	5b                   	pop    %ebx
f010685e:	5e                   	pop    %esi
f010685f:	5d                   	pop    %ebp
f0106860:	c3                   	ret    

f0106861 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106861:	55                   	push   %ebp
f0106862:	89 e5                	mov    %esp,%ebp
f0106864:	57                   	push   %edi
f0106865:	56                   	push   %esi
f0106866:	53                   	push   %ebx
f0106867:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010686a:	c7 05 c0 d3 22 f0 20 	movl   $0xf022d020,0xf022d3c0
f0106871:	d0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106874:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f010687b:	75 24                	jne    f01068a1 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010687d:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106884:	00 
f0106885:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f010688c:	f0 
f010688d:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106894:	00 
f0106895:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f010689c:	e8 9f 97 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01068a1:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01068a8:	85 c0                	test   %eax,%eax
f01068aa:	74 16                	je     f01068c2 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01068ac:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01068af:	ba 00 04 00 00       	mov    $0x400,%edx
f01068b4:	e8 ed fe ff ff       	call   f01067a6 <mpsearch1>
f01068b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01068bc:	85 c0                	test   %eax,%eax
f01068be:	75 3c                	jne    f01068fc <mp_init+0x9b>
f01068c0:	eb 20                	jmp    f01068e2 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01068c2:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01068c9:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01068cc:	2d 00 04 00 00       	sub    $0x400,%eax
f01068d1:	ba 00 04 00 00       	mov    $0x400,%edx
f01068d6:	e8 cb fe ff ff       	call   f01067a6 <mpsearch1>
f01068db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01068de:	85 c0                	test   %eax,%eax
f01068e0:	75 1a                	jne    f01068fc <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01068e2:	ba 00 00 01 00       	mov    $0x10000,%edx
f01068e7:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01068ec:	e8 b5 fe ff ff       	call   f01067a6 <mpsearch1>
f01068f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01068f4:	85 c0                	test   %eax,%eax
f01068f6:	0f 84 24 02 00 00    	je     f0106b20 <mp_init+0x2bf>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01068fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01068ff:	8b 78 04             	mov    0x4(%eax),%edi
f0106902:	85 ff                	test   %edi,%edi
f0106904:	74 06                	je     f010690c <mp_init+0xab>
f0106906:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010690a:	74 11                	je     f010691d <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010690c:	c7 04 24 74 8e 10 f0 	movl   $0xf0108e74,(%esp)
f0106913:	e8 e2 dc ff ff       	call   f01045fa <cprintf>
f0106918:	e9 03 02 00 00       	jmp    f0106b20 <mp_init+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010691d:	89 f8                	mov    %edi,%eax
f010691f:	c1 e8 0c             	shr    $0xc,%eax
f0106922:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0106928:	72 20                	jb     f010694a <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010692a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010692e:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0106935:	f0 
f0106936:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010693d:	00 
f010693e:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f0106945:	e8 f6 96 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010694a:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106950:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106957:	00 
f0106958:	c7 44 24 04 16 90 10 	movl   $0xf0109016,0x4(%esp)
f010695f:	f0 
f0106960:	89 3c 24             	mov    %edi,(%esp)
f0106963:	e8 3e fc ff ff       	call   f01065a6 <memcmp>
f0106968:	85 c0                	test   %eax,%eax
f010696a:	74 11                	je     f010697d <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010696c:	c7 04 24 a4 8e 10 f0 	movl   $0xf0108ea4,(%esp)
f0106973:	e8 82 dc ff ff       	call   f01045fa <cprintf>
f0106978:	e9 a3 01 00 00       	jmp    f0106b20 <mp_init+0x2bf>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010697d:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106981:	0f b7 d3             	movzwl %bx,%edx
f0106984:	89 f8                	mov    %edi,%eax
f0106986:	e8 f5 fd ff ff       	call   f0106780 <sum>
f010698b:	84 c0                	test   %al,%al
f010698d:	74 11                	je     f01069a0 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010698f:	c7 04 24 d8 8e 10 f0 	movl   $0xf0108ed8,(%esp)
f0106996:	e8 5f dc ff ff       	call   f01045fa <cprintf>
f010699b:	e9 80 01 00 00       	jmp    f0106b20 <mp_init+0x2bf>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01069a0:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f01069a4:	3c 01                	cmp    $0x1,%al
f01069a6:	74 1c                	je     f01069c4 <mp_init+0x163>
f01069a8:	3c 04                	cmp    $0x4,%al
f01069aa:	74 18                	je     f01069c4 <mp_init+0x163>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01069ac:	0f b6 c0             	movzbl %al,%eax
f01069af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069b3:	c7 04 24 fc 8e 10 f0 	movl   $0xf0108efc,(%esp)
f01069ba:	e8 3b dc ff ff       	call   f01045fa <cprintf>
f01069bf:	e9 5c 01 00 00       	jmp    f0106b20 <mp_init+0x2bf>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01069c4:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f01069c8:	0f b7 db             	movzwl %bx,%ebx
f01069cb:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01069ce:	e8 ad fd ff ff       	call   f0106780 <sum>
f01069d3:	3a 47 2a             	cmp    0x2a(%edi),%al
f01069d6:	74 11                	je     f01069e9 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01069d8:	c7 04 24 1c 8f 10 f0 	movl   $0xf0108f1c,(%esp)
f01069df:	e8 16 dc ff ff       	call   f01045fa <cprintf>
f01069e4:	e9 37 01 00 00       	jmp    f0106b20 <mp_init+0x2bf>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01069e9:	85 ff                	test   %edi,%edi
f01069eb:	0f 84 2f 01 00 00    	je     f0106b20 <mp_init+0x2bf>
		return;
	ismp = 1;
f01069f1:	c7 05 00 d0 22 f0 01 	movl   $0x1,0xf022d000
f01069f8:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01069fb:	8b 47 24             	mov    0x24(%edi),%eax
f01069fe:	a3 00 e0 26 f0       	mov    %eax,0xf026e000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106a03:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106a08:	0f 84 97 00 00 00    	je     f0106aa5 <mp_init+0x244>
f0106a0e:	8d 77 2c             	lea    0x2c(%edi),%esi
f0106a11:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f0106a16:	0f b6 06             	movzbl (%esi),%eax
f0106a19:	84 c0                	test   %al,%al
f0106a1b:	74 06                	je     f0106a23 <mp_init+0x1c2>
f0106a1d:	3c 04                	cmp    $0x4,%al
f0106a1f:	77 54                	ja     f0106a75 <mp_init+0x214>
f0106a21:	eb 4d                	jmp    f0106a70 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106a23:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106a27:	74 11                	je     f0106a3a <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0106a29:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f0106a30:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106a35:	a3 c0 d3 22 f0       	mov    %eax,0xf022d3c0
			if (ncpu < NCPU) {
f0106a3a:	a1 c4 d3 22 f0       	mov    0xf022d3c4,%eax
f0106a3f:	83 f8 07             	cmp    $0x7,%eax
f0106a42:	7f 13                	jg     f0106a57 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f0106a44:	6b d0 74             	imul   $0x74,%eax,%edx
f0106a47:	88 82 20 d0 22 f0    	mov    %al,-0xfdd2fe0(%edx)
				ncpu++;
f0106a4d:	83 c0 01             	add    $0x1,%eax
f0106a50:	a3 c4 d3 22 f0       	mov    %eax,0xf022d3c4
f0106a55:	eb 14                	jmp    f0106a6b <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106a57:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a5f:	c7 04 24 4c 8f 10 f0 	movl   $0xf0108f4c,(%esp)
f0106a66:	e8 8f db ff ff       	call   f01045fa <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106a6b:	83 c6 14             	add    $0x14,%esi
			continue;
f0106a6e:	eb 26                	jmp    f0106a96 <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106a70:	83 c6 08             	add    $0x8,%esi
			continue;
f0106a73:	eb 21                	jmp    f0106a96 <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106a75:	0f b6 c0             	movzbl %al,%eax
f0106a78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a7c:	c7 04 24 74 8f 10 f0 	movl   $0xf0108f74,(%esp)
f0106a83:	e8 72 db ff ff       	call   f01045fa <cprintf>
			ismp = 0;
f0106a88:	c7 05 00 d0 22 f0 00 	movl   $0x0,0xf022d000
f0106a8f:	00 00 00 
			i = conf->entry;
f0106a92:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106a96:	83 c3 01             	add    $0x1,%ebx
f0106a99:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106a9d:	39 d8                	cmp    %ebx,%eax
f0106a9f:	0f 87 71 ff ff ff    	ja     f0106a16 <mp_init+0x1b5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106aa5:	a1 c0 d3 22 f0       	mov    0xf022d3c0,%eax
f0106aaa:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106ab1:	83 3d 00 d0 22 f0 00 	cmpl   $0x0,0xf022d000
f0106ab8:	75 22                	jne    f0106adc <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106aba:	c7 05 c4 d3 22 f0 01 	movl   $0x1,0xf022d3c4
f0106ac1:	00 00 00 
		lapicaddr = 0;
f0106ac4:	c7 05 00 e0 26 f0 00 	movl   $0x0,0xf026e000
f0106acb:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106ace:	c7 04 24 94 8f 10 f0 	movl   $0xf0108f94,(%esp)
f0106ad5:	e8 20 db ff ff       	call   f01045fa <cprintf>
		return;
f0106ada:	eb 44                	jmp    f0106b20 <mp_init+0x2bf>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106adc:	8b 15 c4 d3 22 f0    	mov    0xf022d3c4,%edx
f0106ae2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106ae6:	0f b6 00             	movzbl (%eax),%eax
f0106ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106aed:	c7 04 24 1b 90 10 f0 	movl   $0xf010901b,(%esp)
f0106af4:	e8 01 db ff ff       	call   f01045fa <cprintf>

	if (mp->imcrp) {
f0106af9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106afc:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106b00:	74 1e                	je     f0106b20 <mp_init+0x2bf>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106b02:	c7 04 24 c0 8f 10 f0 	movl   $0xf0108fc0,(%esp)
f0106b09:	e8 ec da ff ff       	call   f01045fa <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b0e:	ba 22 00 00 00       	mov    $0x22,%edx
f0106b13:	b8 70 00 00 00       	mov    $0x70,%eax
f0106b18:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106b19:	b2 23                	mov    $0x23,%dl
f0106b1b:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106b1c:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b1f:	ee                   	out    %al,(%dx)
	}
}
f0106b20:	83 c4 2c             	add    $0x2c,%esp
f0106b23:	5b                   	pop    %ebx
f0106b24:	5e                   	pop    %esi
f0106b25:	5f                   	pop    %edi
f0106b26:	5d                   	pop    %ebp
f0106b27:	c3                   	ret    

f0106b28 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106b28:	55                   	push   %ebp
f0106b29:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106b2b:	c1 e0 02             	shl    $0x2,%eax
f0106b2e:	03 05 04 e0 26 f0    	add    0xf026e004,%eax
f0106b34:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106b36:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f0106b3b:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106b3e:	5d                   	pop    %ebp
f0106b3f:	c3                   	ret    

f0106b40 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106b40:	55                   	push   %ebp
f0106b41:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106b43:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106b49:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f0106b4e:	85 d2                	test   %edx,%edx
f0106b50:	74 06                	je     f0106b58 <cpunum+0x18>
		return lapic[ID] >> 24;
f0106b52:	8b 42 20             	mov    0x20(%edx),%eax
f0106b55:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106b58:	5d                   	pop    %ebp
f0106b59:	c3                   	ret    

f0106b5a <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106b5a:	55                   	push   %ebp
f0106b5b:	89 e5                	mov    %esp,%ebp
f0106b5d:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106b60:	a1 00 e0 26 f0       	mov    0xf026e000,%eax
f0106b65:	85 c0                	test   %eax,%eax
f0106b67:	0f 84 1c 01 00 00    	je     f0106c89 <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106b6d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106b74:	00 
f0106b75:	89 04 24             	mov    %eax,(%esp)
f0106b78:	e8 73 af ff ff       	call   f0101af0 <mmio_map_region>
f0106b7d:	a3 04 e0 26 f0       	mov    %eax,0xf026e004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106b82:	ba 27 01 00 00       	mov    $0x127,%edx
f0106b87:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106b8c:	e8 97 ff ff ff       	call   f0106b28 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106b91:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106b96:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106b9b:	e8 88 ff ff ff       	call   f0106b28 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106ba0:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106ba5:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106baa:	e8 79 ff ff ff       	call   f0106b28 <lapicw>
	lapicw(TICR, 10000000); 
f0106baf:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106bb4:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106bb9:	e8 6a ff ff ff       	call   f0106b28 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106bbe:	e8 7d ff ff ff       	call   f0106b40 <cpunum>
f0106bc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0106bc6:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106bcb:	39 05 c0 d3 22 f0    	cmp    %eax,0xf022d3c0
f0106bd1:	74 0f                	je     f0106be2 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106bd3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106bd8:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106bdd:	e8 46 ff ff ff       	call   f0106b28 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106be2:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106be7:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106bec:	e8 37 ff ff ff       	call   f0106b28 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106bf1:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f0106bf6:	8b 40 30             	mov    0x30(%eax),%eax
f0106bf9:	c1 e8 10             	shr    $0x10,%eax
f0106bfc:	3c 03                	cmp    $0x3,%al
f0106bfe:	76 0f                	jbe    f0106c0f <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106c00:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106c05:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106c0a:	e8 19 ff ff ff       	call   f0106b28 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106c0f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106c14:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106c19:	e8 0a ff ff ff       	call   f0106b28 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106c1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c23:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106c28:	e8 fb fe ff ff       	call   f0106b28 <lapicw>
	lapicw(ESR, 0);
f0106c2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c32:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106c37:	e8 ec fe ff ff       	call   f0106b28 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106c3c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c41:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106c46:	e8 dd fe ff ff       	call   f0106b28 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106c4b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c50:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106c55:	e8 ce fe ff ff       	call   f0106b28 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106c5a:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106c5f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106c64:	e8 bf fe ff ff       	call   f0106b28 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106c69:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f0106c6f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106c75:	f6 c4 10             	test   $0x10,%ah
f0106c78:	75 f5                	jne    f0106c6f <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106c7a:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c7f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c84:	e8 9f fe ff ff       	call   f0106b28 <lapicw>
}
f0106c89:	c9                   	leave  
f0106c8a:	c3                   	ret    

f0106c8b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106c8b:	55                   	push   %ebp
f0106c8c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106c8e:	83 3d 04 e0 26 f0 00 	cmpl   $0x0,0xf026e004
f0106c95:	74 0f                	je     f0106ca6 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0106c97:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c9c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106ca1:	e8 82 fe ff ff       	call   f0106b28 <lapicw>
}
f0106ca6:	5d                   	pop    %ebp
f0106ca7:	c3                   	ret    

f0106ca8 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106ca8:	55                   	push   %ebp
f0106ca9:	89 e5                	mov    %esp,%ebp
f0106cab:	56                   	push   %esi
f0106cac:	53                   	push   %ebx
f0106cad:	83 ec 10             	sub    $0x10,%esp
f0106cb0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106cb3:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0106cb7:	ba 70 00 00 00       	mov    $0x70,%edx
f0106cbc:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106cc1:	ee                   	out    %al,(%dx)
f0106cc2:	b2 71                	mov    $0x71,%dl
f0106cc4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106cc9:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106cca:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f0106cd1:	75 24                	jne    f0106cf7 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106cd3:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106cda:	00 
f0106cdb:	c7 44 24 08 c8 72 10 	movl   $0xf01072c8,0x8(%esp)
f0106ce2:	f0 
f0106ce3:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106cea:	00 
f0106ceb:	c7 04 24 38 90 10 f0 	movl   $0xf0109038,(%esp)
f0106cf2:	e8 49 93 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106cf7:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106cfe:	00 00 
	wrv[1] = addr >> 4;
f0106d00:	89 f0                	mov    %esi,%eax
f0106d02:	c1 e8 04             	shr    $0x4,%eax
f0106d05:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106d0b:	c1 e3 18             	shl    $0x18,%ebx
f0106d0e:	89 da                	mov    %ebx,%edx
f0106d10:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d15:	e8 0e fe ff ff       	call   f0106b28 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106d1a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106d1f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d24:	e8 ff fd ff ff       	call   f0106b28 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106d29:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106d2e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d33:	e8 f0 fd ff ff       	call   f0106b28 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d38:	c1 ee 0c             	shr    $0xc,%esi
f0106d3b:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d41:	89 da                	mov    %ebx,%edx
f0106d43:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d48:	e8 db fd ff ff       	call   f0106b28 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d4d:	89 f2                	mov    %esi,%edx
f0106d4f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d54:	e8 cf fd ff ff       	call   f0106b28 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d59:	89 da                	mov    %ebx,%edx
f0106d5b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d60:	e8 c3 fd ff ff       	call   f0106b28 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d65:	89 f2                	mov    %esi,%edx
f0106d67:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d6c:	e8 b7 fd ff ff       	call   f0106b28 <lapicw>
		microdelay(200);
	}
}
f0106d71:	83 c4 10             	add    $0x10,%esp
f0106d74:	5b                   	pop    %ebx
f0106d75:	5e                   	pop    %esi
f0106d76:	5d                   	pop    %ebp
f0106d77:	c3                   	ret    

f0106d78 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106d78:	55                   	push   %ebp
f0106d79:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106d7b:	8b 55 08             	mov    0x8(%ebp),%edx
f0106d7e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106d84:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d89:	e8 9a fd ff ff       	call   f0106b28 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106d8e:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f0106d94:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106d9a:	f6 c4 10             	test   $0x10,%ah
f0106d9d:	75 f5                	jne    f0106d94 <lapic_ipi+0x1c>
		;
}
f0106d9f:	5d                   	pop    %ebp
f0106da0:	c3                   	ret    
f0106da1:	00 00                	add    %al,(%eax)
	...

f0106da4 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106da4:	55                   	push   %ebp
f0106da5:	89 e5                	mov    %esp,%ebp
f0106da7:	53                   	push   %ebx
f0106da8:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106dab:	ba 00 00 00 00       	mov    $0x0,%edx
f0106db0:	83 38 00             	cmpl   $0x0,(%eax)
f0106db3:	74 18                	je     f0106dcd <holding+0x29>
f0106db5:	8b 58 08             	mov    0x8(%eax),%ebx
f0106db8:	e8 83 fd ff ff       	call   f0106b40 <cpunum>
f0106dbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0106dc0:	05 20 d0 22 f0       	add    $0xf022d020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106dc5:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106dc7:	0f 94 c2             	sete   %dl
f0106dca:	0f b6 d2             	movzbl %dl,%edx
}
f0106dcd:	89 d0                	mov    %edx,%eax
f0106dcf:	83 c4 04             	add    $0x4,%esp
f0106dd2:	5b                   	pop    %ebx
f0106dd3:	5d                   	pop    %ebp
f0106dd4:	c3                   	ret    

f0106dd5 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106dd5:	55                   	push   %ebp
f0106dd6:	89 e5                	mov    %esp,%ebp
f0106dd8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106ddb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106de1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106de4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106de7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106dee:	5d                   	pop    %ebp
f0106def:	c3                   	ret    

f0106df0 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106df0:	55                   	push   %ebp
f0106df1:	89 e5                	mov    %esp,%ebp
f0106df3:	53                   	push   %ebx
f0106df4:	83 ec 24             	sub    $0x24,%esp
f0106df7:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106dfa:	89 d8                	mov    %ebx,%eax
f0106dfc:	e8 a3 ff ff ff       	call   f0106da4 <holding>
f0106e01:	85 c0                	test   %eax,%eax
f0106e03:	75 12                	jne    f0106e17 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106e05:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106e07:	b0 01                	mov    $0x1,%al
f0106e09:	f0 87 03             	lock xchg %eax,(%ebx)
f0106e0c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106e11:	85 c0                	test   %eax,%eax
f0106e13:	75 2e                	jne    f0106e43 <spin_lock+0x53>
f0106e15:	eb 37                	jmp    f0106e4e <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106e17:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106e1a:	e8 21 fd ff ff       	call   f0106b40 <cpunum>
f0106e1f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106e23:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106e27:	c7 44 24 08 48 90 10 	movl   $0xf0109048,0x8(%esp)
f0106e2e:	f0 
f0106e2f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106e36:	00 
f0106e37:	c7 04 24 ac 90 10 f0 	movl   $0xf01090ac,(%esp)
f0106e3e:	e8 fd 91 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106e43:	f3 90                	pause  
f0106e45:	89 c8                	mov    %ecx,%eax
f0106e47:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106e4a:	85 c0                	test   %eax,%eax
f0106e4c:	75 f5                	jne    f0106e43 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106e4e:	e8 ed fc ff ff       	call   f0106b40 <cpunum>
f0106e53:	6b c0 74             	imul   $0x74,%eax,%eax
f0106e56:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106e5b:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106e5e:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106e61:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106e63:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106e68:	77 34                	ja     f0106e9e <spin_lock+0xae>
f0106e6a:	eb 2b                	jmp    f0106e97 <spin_lock+0xa7>
f0106e6c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106e72:	76 12                	jbe    f0106e86 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106e74:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106e77:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106e7a:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106e7c:	83 c0 01             	add    $0x1,%eax
f0106e7f:	83 f8 0a             	cmp    $0xa,%eax
f0106e82:	75 e8                	jne    f0106e6c <spin_lock+0x7c>
f0106e84:	eb 27                	jmp    f0106ead <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106e86:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106e8d:	83 c0 01             	add    $0x1,%eax
f0106e90:	83 f8 09             	cmp    $0x9,%eax
f0106e93:	7e f1                	jle    f0106e86 <spin_lock+0x96>
f0106e95:	eb 16                	jmp    f0106ead <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106e97:	b8 00 00 00 00       	mov    $0x0,%eax
f0106e9c:	eb e8                	jmp    f0106e86 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106e9e:	8b 50 04             	mov    0x4(%eax),%edx
f0106ea1:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106ea4:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106ea6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106eab:	eb bf                	jmp    f0106e6c <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106ead:	83 c4 24             	add    $0x24,%esp
f0106eb0:	5b                   	pop    %ebx
f0106eb1:	5d                   	pop    %ebp
f0106eb2:	c3                   	ret    

f0106eb3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106eb3:	55                   	push   %ebp
f0106eb4:	89 e5                	mov    %esp,%ebp
f0106eb6:	83 ec 78             	sub    $0x78,%esp
f0106eb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106ebc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106ebf:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106ec2:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ec5:	89 d8                	mov    %ebx,%eax
f0106ec7:	e8 d8 fe ff ff       	call   f0106da4 <holding>
f0106ecc:	85 c0                	test   %eax,%eax
f0106ece:	0f 85 d4 00 00 00    	jne    f0106fa8 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106ed4:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106edb:	00 
f0106edc:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106edf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ee3:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106ee6:	89 04 24             	mov    %eax,(%esp)
f0106ee9:	e8 1e f6 ff ff       	call   f010650c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106eee:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106ef1:	0f b6 30             	movzbl (%eax),%esi
f0106ef4:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106ef7:	e8 44 fc ff ff       	call   f0106b40 <cpunum>
f0106efc:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106f00:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106f04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f08:	c7 04 24 74 90 10 f0 	movl   $0xf0109074,(%esp)
f0106f0f:	e8 e6 d6 ff ff       	call   f01045fa <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106f14:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106f17:	85 c0                	test   %eax,%eax
f0106f19:	74 71                	je     f0106f8c <spin_unlock+0xd9>
f0106f1b:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106f1e:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106f21:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106f24:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106f28:	89 04 24             	mov    %eax,(%esp)
f0106f2b:	e8 c6 e8 ff ff       	call   f01057f6 <debuginfo_eip>
f0106f30:	85 c0                	test   %eax,%eax
f0106f32:	78 39                	js     f0106f6d <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106f34:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106f36:	89 c2                	mov    %eax,%edx
f0106f38:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106f3b:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106f3f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106f42:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106f46:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106f49:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106f4d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106f50:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106f54:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106f57:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f5f:	c7 04 24 bc 90 10 f0 	movl   $0xf01090bc,(%esp)
f0106f66:	e8 8f d6 ff ff       	call   f01045fa <cprintf>
f0106f6b:	eb 12                	jmp    f0106f7f <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106f6d:	8b 03                	mov    (%ebx),%eax
f0106f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f73:	c7 04 24 d3 90 10 f0 	movl   $0xf01090d3,(%esp)
f0106f7a:	e8 7b d6 ff ff       	call   f01045fa <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106f7f:	39 fb                	cmp    %edi,%ebx
f0106f81:	74 09                	je     f0106f8c <spin_unlock+0xd9>
f0106f83:	83 c3 04             	add    $0x4,%ebx
f0106f86:	8b 03                	mov    (%ebx),%eax
f0106f88:	85 c0                	test   %eax,%eax
f0106f8a:	75 98                	jne    f0106f24 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106f8c:	c7 44 24 08 db 90 10 	movl   $0xf01090db,0x8(%esp)
f0106f93:	f0 
f0106f94:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106f9b:	00 
f0106f9c:	c7 04 24 ac 90 10 f0 	movl   $0xf01090ac,(%esp)
f0106fa3:	e8 98 90 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106fa8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106faf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106fb6:	b8 00 00 00 00       	mov    $0x0,%eax
f0106fbb:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106fbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106fc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106fc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106fc7:	89 ec                	mov    %ebp,%esp
f0106fc9:	5d                   	pop    %ebp
f0106fca:	c3                   	ret    
f0106fcb:	00 00                	add    %al,(%eax)
f0106fcd:	00 00                	add    %al,(%eax)
	...

f0106fd0 <__udivdi3>:
f0106fd0:	83 ec 1c             	sub    $0x1c,%esp
f0106fd3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106fd7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0106fdb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106fdf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106fe3:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106fe7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106feb:	85 ff                	test   %edi,%edi
f0106fed:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106ff1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ff5:	89 cd                	mov    %ecx,%ebp
f0106ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ffb:	75 33                	jne    f0107030 <__udivdi3+0x60>
f0106ffd:	39 f1                	cmp    %esi,%ecx
f0106fff:	77 57                	ja     f0107058 <__udivdi3+0x88>
f0107001:	85 c9                	test   %ecx,%ecx
f0107003:	75 0b                	jne    f0107010 <__udivdi3+0x40>
f0107005:	b8 01 00 00 00       	mov    $0x1,%eax
f010700a:	31 d2                	xor    %edx,%edx
f010700c:	f7 f1                	div    %ecx
f010700e:	89 c1                	mov    %eax,%ecx
f0107010:	89 f0                	mov    %esi,%eax
f0107012:	31 d2                	xor    %edx,%edx
f0107014:	f7 f1                	div    %ecx
f0107016:	89 c6                	mov    %eax,%esi
f0107018:	8b 44 24 04          	mov    0x4(%esp),%eax
f010701c:	f7 f1                	div    %ecx
f010701e:	89 f2                	mov    %esi,%edx
f0107020:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107024:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107028:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010702c:	83 c4 1c             	add    $0x1c,%esp
f010702f:	c3                   	ret    
f0107030:	31 d2                	xor    %edx,%edx
f0107032:	31 c0                	xor    %eax,%eax
f0107034:	39 f7                	cmp    %esi,%edi
f0107036:	77 e8                	ja     f0107020 <__udivdi3+0x50>
f0107038:	0f bd cf             	bsr    %edi,%ecx
f010703b:	83 f1 1f             	xor    $0x1f,%ecx
f010703e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0107042:	75 2c                	jne    f0107070 <__udivdi3+0xa0>
f0107044:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0107048:	76 04                	jbe    f010704e <__udivdi3+0x7e>
f010704a:	39 f7                	cmp    %esi,%edi
f010704c:	73 d2                	jae    f0107020 <__udivdi3+0x50>
f010704e:	31 d2                	xor    %edx,%edx
f0107050:	b8 01 00 00 00       	mov    $0x1,%eax
f0107055:	eb c9                	jmp    f0107020 <__udivdi3+0x50>
f0107057:	90                   	nop
f0107058:	89 f2                	mov    %esi,%edx
f010705a:	f7 f1                	div    %ecx
f010705c:	31 d2                	xor    %edx,%edx
f010705e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107062:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107066:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010706a:	83 c4 1c             	add    $0x1c,%esp
f010706d:	c3                   	ret    
f010706e:	66 90                	xchg   %ax,%ax
f0107070:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107075:	b8 20 00 00 00       	mov    $0x20,%eax
f010707a:	89 ea                	mov    %ebp,%edx
f010707c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0107080:	d3 e7                	shl    %cl,%edi
f0107082:	89 c1                	mov    %eax,%ecx
f0107084:	d3 ea                	shr    %cl,%edx
f0107086:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010708b:	09 fa                	or     %edi,%edx
f010708d:	89 f7                	mov    %esi,%edi
f010708f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107093:	89 f2                	mov    %esi,%edx
f0107095:	8b 74 24 08          	mov    0x8(%esp),%esi
f0107099:	d3 e5                	shl    %cl,%ebp
f010709b:	89 c1                	mov    %eax,%ecx
f010709d:	d3 ef                	shr    %cl,%edi
f010709f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01070a4:	d3 e2                	shl    %cl,%edx
f01070a6:	89 c1                	mov    %eax,%ecx
f01070a8:	d3 ee                	shr    %cl,%esi
f01070aa:	09 d6                	or     %edx,%esi
f01070ac:	89 fa                	mov    %edi,%edx
f01070ae:	89 f0                	mov    %esi,%eax
f01070b0:	f7 74 24 0c          	divl   0xc(%esp)
f01070b4:	89 d7                	mov    %edx,%edi
f01070b6:	89 c6                	mov    %eax,%esi
f01070b8:	f7 e5                	mul    %ebp
f01070ba:	39 d7                	cmp    %edx,%edi
f01070bc:	72 22                	jb     f01070e0 <__udivdi3+0x110>
f01070be:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01070c2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01070c7:	d3 e5                	shl    %cl,%ebp
f01070c9:	39 c5                	cmp    %eax,%ebp
f01070cb:	73 04                	jae    f01070d1 <__udivdi3+0x101>
f01070cd:	39 d7                	cmp    %edx,%edi
f01070cf:	74 0f                	je     f01070e0 <__udivdi3+0x110>
f01070d1:	89 f0                	mov    %esi,%eax
f01070d3:	31 d2                	xor    %edx,%edx
f01070d5:	e9 46 ff ff ff       	jmp    f0107020 <__udivdi3+0x50>
f01070da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01070e0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01070e3:	31 d2                	xor    %edx,%edx
f01070e5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01070e9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01070ed:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01070f1:	83 c4 1c             	add    $0x1c,%esp
f01070f4:	c3                   	ret    
	...

f0107100 <__umoddi3>:
f0107100:	83 ec 1c             	sub    $0x1c,%esp
f0107103:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0107107:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010710b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010710f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107113:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0107117:	8b 74 24 24          	mov    0x24(%esp),%esi
f010711b:	85 ed                	test   %ebp,%ebp
f010711d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0107121:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107125:	89 cf                	mov    %ecx,%edi
f0107127:	89 04 24             	mov    %eax,(%esp)
f010712a:	89 f2                	mov    %esi,%edx
f010712c:	75 1a                	jne    f0107148 <__umoddi3+0x48>
f010712e:	39 f1                	cmp    %esi,%ecx
f0107130:	76 4e                	jbe    f0107180 <__umoddi3+0x80>
f0107132:	f7 f1                	div    %ecx
f0107134:	89 d0                	mov    %edx,%eax
f0107136:	31 d2                	xor    %edx,%edx
f0107138:	8b 74 24 10          	mov    0x10(%esp),%esi
f010713c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107140:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0107144:	83 c4 1c             	add    $0x1c,%esp
f0107147:	c3                   	ret    
f0107148:	39 f5                	cmp    %esi,%ebp
f010714a:	77 54                	ja     f01071a0 <__umoddi3+0xa0>
f010714c:	0f bd c5             	bsr    %ebp,%eax
f010714f:	83 f0 1f             	xor    $0x1f,%eax
f0107152:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107156:	75 60                	jne    f01071b8 <__umoddi3+0xb8>
f0107158:	3b 0c 24             	cmp    (%esp),%ecx
f010715b:	0f 87 07 01 00 00    	ja     f0107268 <__umoddi3+0x168>
f0107161:	89 f2                	mov    %esi,%edx
f0107163:	8b 34 24             	mov    (%esp),%esi
f0107166:	29 ce                	sub    %ecx,%esi
f0107168:	19 ea                	sbb    %ebp,%edx
f010716a:	89 34 24             	mov    %esi,(%esp)
f010716d:	8b 04 24             	mov    (%esp),%eax
f0107170:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107174:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107178:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010717c:	83 c4 1c             	add    $0x1c,%esp
f010717f:	c3                   	ret    
f0107180:	85 c9                	test   %ecx,%ecx
f0107182:	75 0b                	jne    f010718f <__umoddi3+0x8f>
f0107184:	b8 01 00 00 00       	mov    $0x1,%eax
f0107189:	31 d2                	xor    %edx,%edx
f010718b:	f7 f1                	div    %ecx
f010718d:	89 c1                	mov    %eax,%ecx
f010718f:	89 f0                	mov    %esi,%eax
f0107191:	31 d2                	xor    %edx,%edx
f0107193:	f7 f1                	div    %ecx
f0107195:	8b 04 24             	mov    (%esp),%eax
f0107198:	f7 f1                	div    %ecx
f010719a:	eb 98                	jmp    f0107134 <__umoddi3+0x34>
f010719c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01071a0:	89 f2                	mov    %esi,%edx
f01071a2:	8b 74 24 10          	mov    0x10(%esp),%esi
f01071a6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01071aa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01071ae:	83 c4 1c             	add    $0x1c,%esp
f01071b1:	c3                   	ret    
f01071b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01071b8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01071bd:	89 e8                	mov    %ebp,%eax
f01071bf:	bd 20 00 00 00       	mov    $0x20,%ebp
f01071c4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01071c8:	89 fa                	mov    %edi,%edx
f01071ca:	d3 e0                	shl    %cl,%eax
f01071cc:	89 e9                	mov    %ebp,%ecx
f01071ce:	d3 ea                	shr    %cl,%edx
f01071d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01071d5:	09 c2                	or     %eax,%edx
f01071d7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01071db:	89 14 24             	mov    %edx,(%esp)
f01071de:	89 f2                	mov    %esi,%edx
f01071e0:	d3 e7                	shl    %cl,%edi
f01071e2:	89 e9                	mov    %ebp,%ecx
f01071e4:	d3 ea                	shr    %cl,%edx
f01071e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01071eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01071ef:	d3 e6                	shl    %cl,%esi
f01071f1:	89 e9                	mov    %ebp,%ecx
f01071f3:	d3 e8                	shr    %cl,%eax
f01071f5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01071fa:	09 f0                	or     %esi,%eax
f01071fc:	8b 74 24 08          	mov    0x8(%esp),%esi
f0107200:	f7 34 24             	divl   (%esp)
f0107203:	d3 e6                	shl    %cl,%esi
f0107205:	89 74 24 08          	mov    %esi,0x8(%esp)
f0107209:	89 d6                	mov    %edx,%esi
f010720b:	f7 e7                	mul    %edi
f010720d:	39 d6                	cmp    %edx,%esi
f010720f:	89 c1                	mov    %eax,%ecx
f0107211:	89 d7                	mov    %edx,%edi
f0107213:	72 3f                	jb     f0107254 <__umoddi3+0x154>
f0107215:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0107219:	72 35                	jb     f0107250 <__umoddi3+0x150>
f010721b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010721f:	29 c8                	sub    %ecx,%eax
f0107221:	19 fe                	sbb    %edi,%esi
f0107223:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107228:	89 f2                	mov    %esi,%edx
f010722a:	d3 e8                	shr    %cl,%eax
f010722c:	89 e9                	mov    %ebp,%ecx
f010722e:	d3 e2                	shl    %cl,%edx
f0107230:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107235:	09 d0                	or     %edx,%eax
f0107237:	89 f2                	mov    %esi,%edx
f0107239:	d3 ea                	shr    %cl,%edx
f010723b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010723f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107243:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0107247:	83 c4 1c             	add    $0x1c,%esp
f010724a:	c3                   	ret    
f010724b:	90                   	nop
f010724c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107250:	39 d6                	cmp    %edx,%esi
f0107252:	75 c7                	jne    f010721b <__umoddi3+0x11b>
f0107254:	89 d7                	mov    %edx,%edi
f0107256:	89 c1                	mov    %eax,%ecx
f0107258:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010725c:	1b 3c 24             	sbb    (%esp),%edi
f010725f:	eb ba                	jmp    f010721b <__umoddi3+0x11b>
f0107261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107268:	39 f5                	cmp    %esi,%ebp
f010726a:	0f 82 f1 fe ff ff    	jb     f0107161 <__umoddi3+0x61>
f0107270:	e9 f8 fe ff ff       	jmp    f010716d <__umoddi3+0x6d>
