
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
f010005f:	e8 ec 6a 00 00       	call   f0106b50 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 a0 72 10 f0 	movl   $0xf01072a0,(%esp)
f010007d:	e8 6c 45 00 00       	call   f01045ee <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 2d 45 00 00       	call   f01045bb <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 d6 86 10 f0 	movl   $0xf01086d6,(%esp)
f0100095:	e8 54 45 00 00       	call   f01045ee <cprintf>
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
f01000be:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 0b 73 10 f0 	movl   $0xf010730b,(%esp)
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
f01000e2:	e8 69 6a 00 00       	call   f0106b50 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 17 73 10 f0 	movl   $0xf0107317,(%esp)
f01000f2:	e8 f7 44 00 00       	call   f01045ee <cprintf>

	lapic_init();
f01000f7:	e8 6e 6a 00 00       	call   f0106b6a <lapic_init>
	env_init_percpu();
f01000fc:	e8 90 3c 00 00       	call   f0103d91 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 0a 45 00 00       	call   f0104610 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 45 6a 00 00       	call   f0106b50 <cpunum>
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
f0100124:	e8 d7 6c 00 00       	call   f0106e00 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 e6 4e 00 00       	call   f0105014 <sched_yield>

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
f010013a:	2d 0c b9 22 f0       	sub    $0xf022b90c,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 0c b9 22 f0 	movl   $0xf022b90c,(%esp)
f0100152:	e8 6a 63 00 00       	call   f01064c1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 2f 05 00 00       	call   f010068b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 2d 73 10 f0 	movl   $0xf010732d,(%esp)
f010016b:	e8 7e 44 00 00       	call   f01045ee <cprintf>

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
f0100180:	e8 ec 66 00 00       	call   f0106871 <mp_init>
	lapic_init();
f0100185:	e8 e0 69 00 00       	call   f0106b6a <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 8e 43 00 00       	call   f010451d <pic_init>
f010018f:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0100196:	e8 65 6c 00 00       	call   f0106e00 <spin_lock>
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
f01001ac:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 0b 73 10 f0 	movl   $0xf010730b,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 8a 67 10 f0       	mov    $0xf010678a,%eax
f01001cd:	2d 10 67 10 f0       	sub    $0xf0106710,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 10 67 10 	movl   $0xf0106710,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 32 63 00 00       	call   f010651c <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f01001f1:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f01001f6:	3d 20 d0 22 f0       	cmp    $0xf022d020,%eax
f01001fb:	76 62                	jbe    f010025f <i386_init+0x131>
f01001fd:	bb 20 d0 22 f0       	mov    $0xf022d020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100202:	e8 49 69 00 00       	call   f0106b50 <cpunum>
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
f010023f:	e8 74 6a 00 00       	call   f0106cb8 <lapic_startap>
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
f0100267:	c7 44 24 04 db 9a 00 	movl   $0x9adb,0x4(%esp)
f010026e:	00 
f010026f:	c7 04 24 31 1e 22 f0 	movl   $0xf0221e31,(%esp)
f0100276:	e8 31 3d 00 00       	call   f0103fac <env_create>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	
	// Schedule and run the first user environment!
	sched_yield();
f010027b:	e8 94 4d 00 00       	call   f0105014 <sched_yield>

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
f0100298:	c7 04 24 48 73 10 f0 	movl   $0xf0107348,(%esp)
f010029f:	e8 4a 43 00 00       	call   f01045ee <cprintf>
	vcprintf(fmt, ap);
f01002a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ab:	89 04 24             	mov    %eax,(%esp)
f01002ae:	e8 08 43 00 00       	call   f01045bb <vcprintf>
	cprintf("\n");
f01002b3:	c7 04 24 d6 86 10 f0 	movl   $0xf01086d6,(%esp)
f01002ba:	e8 2f 43 00 00       	call   f01045ee <cprintf>
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
f01004bd:	e8 5a 60 00 00       	call   f010651c <memmove>
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
f0100569:	0f b6 82 a0 73 10 f0 	movzbl -0xfef8c60(%edx),%eax
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
f01005a6:	0f b6 82 a0 73 10 f0 	movzbl -0xfef8c60(%edx),%eax
f01005ad:	0b 05 28 c2 22 f0    	or     0xf022c228,%eax
	shift ^= togglecode[data];
f01005b3:	0f b6 8a a0 74 10 f0 	movzbl -0xfef8b60(%edx),%ecx
f01005ba:	31 c8                	xor    %ecx,%eax
f01005bc:	a3 28 c2 22 f0       	mov    %eax,0xf022c228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005c1:	89 c1                	mov    %eax,%ecx
f01005c3:	83 e1 03             	and    $0x3,%ecx
f01005c6:	8b 0c 8d a0 75 10 f0 	mov    -0xfef8a60(,%ecx,4),%ecx
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
f01005fc:	c7 04 24 62 73 10 f0 	movl   $0xf0107362,(%esp)
f0100603:	e8 e6 3f 00 00       	call   f01045ee <cprintf>
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
f0100723:	e8 84 3d 00 00       	call   f01044ac <irq_setmask_8259A>
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
f0100785:	c7 04 24 6e 73 10 f0 	movl   $0xf010736e,(%esp)
f010078c:	e8 5d 3e 00 00       	call   f01045ee <cprintf>
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
f01007d6:	c7 04 24 b0 75 10 f0 	movl   $0xf01075b0,(%esp)
f01007dd:	e8 0c 3e 00 00       	call   f01045ee <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007e9:	00 
f01007ea:	c7 04 24 3c 77 10 f0 	movl   $0xf010773c,(%esp)
f01007f1:	e8 f8 3d 00 00       	call   f01045ee <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007fd:	00 
f01007fe:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 64 77 10 f0 	movl   $0xf0107764,(%esp)
f010080d:	e8 dc 3d 00 00       	call   f01045ee <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100812:	c7 44 24 08 85 72 10 	movl   $0x107285,0x8(%esp)
f0100819:	00 
f010081a:	c7 44 24 04 85 72 10 	movl   $0xf0107285,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 88 77 10 f0 	movl   $0xf0107788,(%esp)
f0100829:	e8 c0 3d 00 00       	call   f01045ee <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082e:	c7 44 24 08 0c b9 22 	movl   $0x22b90c,0x8(%esp)
f0100835:	00 
f0100836:	c7 44 24 04 0c b9 22 	movl   $0xf022b90c,0x4(%esp)
f010083d:	f0 
f010083e:	c7 04 24 ac 77 10 f0 	movl   $0xf01077ac,(%esp)
f0100845:	e8 a4 3d 00 00       	call   f01045ee <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084a:	c7 44 24 08 08 e0 26 	movl   $0x26e008,0x8(%esp)
f0100851:	00 
f0100852:	c7 44 24 04 08 e0 26 	movl   $0xf026e008,0x4(%esp)
f0100859:	f0 
f010085a:	c7 04 24 d0 77 10 f0 	movl   $0xf01077d0,(%esp)
f0100861:	e8 88 3d 00 00       	call   f01045ee <cprintf>
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
f0100887:	c7 04 24 f4 77 10 f0 	movl   $0xf01077f4,(%esp)
f010088e:	e8 5b 3d 00 00       	call   f01045ee <cprintf>
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
f01008a6:	8b 83 a4 7a 10 f0    	mov    -0xfef855c(%ebx),%eax
f01008ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008b0:	8b 83 a0 7a 10 f0    	mov    -0xfef8560(%ebx),%eax
f01008b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ba:	c7 04 24 c9 75 10 f0 	movl   $0xf01075c9,(%esp)
f01008c1:	e8 28 3d 00 00       	call   f01045ee <cprintf>
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
f010090f:	e8 20 5d 00 00       	call   f0106634 <strtol>
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
f0100936:	c7 44 24 04 d2 75 10 	movl   $0xf01075d2,0x4(%esp)
f010093d:	f0 
f010093e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100941:	89 04 24             	mov    %eax,(%esp)
f0100944:	e8 a2 5a 00 00       	call   f01063eb <strcmp>
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
f0100968:	e8 c7 5c 00 00       	call   f0106634 <strtol>
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
f0100980:	c7 44 24 04 d7 75 10 	movl   $0xf01075d7,0x4(%esp)
f0100987:	f0 
f0100988:	8b 43 04             	mov    0x4(%ebx),%eax
f010098b:	89 04 24             	mov    %eax,(%esp)
f010098e:	e8 58 5a 00 00       	call   f01063eb <strcmp>
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
f01009ab:	c7 44 24 04 de 75 10 	movl   $0xf01075de,0x4(%esp)
f01009b2:	f0 
f01009b3:	8b 43 04             	mov    0x4(%ebx),%eax
f01009b6:	89 04 24             	mov    %eax,(%esp)
f01009b9:	e8 2d 5a 00 00       	call   f01063eb <strcmp>
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	0f 85 0b 01 00 00    	jne    f0100ad1 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f01009c6:	c7 44 24 04 e3 86 10 	movl   $0xf01086e3,0x4(%esp)
f01009cd:	f0 
f01009ce:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009d1:	89 04 24             	mov    %eax,(%esp)
f01009d4:	e8 12 5a 00 00       	call   f01063eb <strcmp>
f01009d9:	85 c0                	test   %eax,%eax
f01009db:	75 06                	jne    f01009e3 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f01009dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009e0:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f01009e3:	c7 44 24 04 f4 86 10 	movl   $0xf01086f4,0x4(%esp)
f01009ea:	f0 
f01009eb:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009ee:	89 04 24             	mov    %eax,(%esp)
f01009f1:	e8 f5 59 00 00       	call   f01063eb <strcmp>
f01009f6:	85 c0                	test   %eax,%eax
f01009f8:	75 06                	jne    f0100a00 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f01009fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009fd:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f0100a00:	c7 44 24 04 e6 75 10 	movl   $0xf01075e6,0x4(%esp)
f0100a07:	f0 
f0100a08:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a0b:	89 04 24             	mov    %eax,(%esp)
f0100a0e:	e8 d8 59 00 00       	call   f01063eb <strcmp>
f0100a13:	85 c0                	test   %eax,%eax
f0100a15:	75 06                	jne    f0100a1d <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f0100a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1a:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f0100a1d:	c7 44 24 04 45 86 10 	movl   $0xf0108645,0x4(%esp)
f0100a24:	f0 
f0100a25:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a28:	89 04 24             	mov    %eax,(%esp)
f0100a2b:	e8 bb 59 00 00       	call   f01063eb <strcmp>
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	75 06                	jne    f0100a3a <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f0100a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a37:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f0100a3a:	c7 44 24 04 ee 75 10 	movl   $0xf01075ee,0x4(%esp)
f0100a41:	f0 
f0100a42:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a45:	89 04 24             	mov    %eax,(%esp)
f0100a48:	e8 9e 59 00 00       	call   f01063eb <strcmp>
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	75 06                	jne    f0100a57 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f0100a51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a54:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f0100a57:	c7 44 24 04 f6 75 10 	movl   $0xf01075f6,0x4(%esp)
f0100a5e:	f0 
f0100a5f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a62:	89 04 24             	mov    %eax,(%esp)
f0100a65:	e8 81 59 00 00       	call   f01063eb <strcmp>
f0100a6a:	85 c0                	test   %eax,%eax
f0100a6c:	75 06                	jne    f0100a74 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f0100a6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a71:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f0100a74:	c7 44 24 04 fc 75 10 	movl   $0xf01075fc,0x4(%esp)
f0100a7b:	f0 
f0100a7c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a7f:	89 04 24             	mov    %eax,(%esp)
f0100a82:	e8 64 59 00 00       	call   f01063eb <strcmp>
f0100a87:	85 c0                	test   %eax,%eax
f0100a89:	75 06                	jne    f0100a91 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f0100a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8e:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f0100a91:	c7 44 24 04 02 76 10 	movl   $0xf0107602,0x4(%esp)
f0100a98:	f0 
f0100a99:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a9c:	89 04 24             	mov    %eax,(%esp)
f0100a9f:	e8 47 59 00 00       	call   f01063eb <strcmp>
f0100aa4:	85 c0                	test   %eax,%eax
f0100aa6:	75 09                	jne    f0100ab1 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f0100aa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aab:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100ab1:	c7 44 24 04 09 76 10 	movl   $0xf0107609,0x4(%esp)
f0100ab8:	f0 
f0100ab9:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100abc:	89 04 24             	mov    %eax,(%esp)
f0100abf:	e8 27 59 00 00       	call   f01063eb <strcmp>
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
f0100ad9:	c7 04 24 0f 76 10 f0 	movl   $0xf010760f,(%esp)
f0100ae0:	e8 09 3b 00 00       	call   f01045ee <cprintf>
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
f0100b2a:	e8 05 5b 00 00       	call   f0106634 <strtol>
f0100b2f:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f0100b31:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b38:	00 
f0100b39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b40:	00 
f0100b41:	8b 46 08             	mov    0x8(%esi),%eax
f0100b44:	89 04 24             	mov    %eax,(%esp)
f0100b47:	e8 e8 5a 00 00       	call   f0106634 <strtol>
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
f0100b73:	c7 04 24 20 78 10 f0 	movl   $0xf0107820,(%esp)
f0100b7a:	e8 6f 3a 00 00       	call   f01045ee <cprintf>
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
f0100b9f:	c7 04 24 48 78 10 f0 	movl   $0xf0107848,(%esp)
f0100ba6:	e8 43 3a 00 00       	call   f01045ee <cprintf>
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
f0100c02:	c7 04 24 2b 76 10 f0 	movl   $0xf010762b,(%esp)
f0100c09:	e8 e0 39 00 00       	call   f01045ee <cprintf>
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
f0100c55:	c7 04 24 7c 78 10 f0 	movl   $0xf010787c,(%esp)
f0100c5c:	e8 8d 39 00 00       	call   f01045ee <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100c61:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c68:	89 1c 24             	mov    %ebx,(%esp)
f0100c6b:	e8 8e 4b 00 00       	call   f01057fe <debuginfo_eip>
f0100c70:	85 c0                	test   %eax,%eax
f0100c72:	0f 88 93 00 00 00    	js     f0100d0b <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100c78:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100c85:	89 04 24             	mov    %eax,(%esp)
f0100c88:	e8 9e 56 00 00       	call   f010632b <strcpy>

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
f0100caa:	e8 c7 56 00 00       	call   f0106376 <strncpy>
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
f0100cd6:	c7 04 24 3d 76 10 f0 	movl   $0xf010763d,(%esp)
f0100cdd:	e8 0c 39 00 00       	call   f01045ee <cprintf>
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
f0100d47:	e8 e8 58 00 00       	call   f0106634 <strtol>
f0100d4c:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100d4e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d55:	00 
f0100d56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d5d:	00 
f0100d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d61:	8b 42 0c             	mov    0xc(%edx),%eax
f0100d64:	89 04 24             	mov    %eax,(%esp)
f0100d67:	e8 c8 58 00 00       	call   f0106634 <strtol>
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
f0100da3:	c7 04 24 54 76 10 f0 	movl   $0xf0107654,(%esp)
f0100daa:	e8 3f 38 00 00       	call   f01045ee <cprintf>

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
f0100de0:	c7 04 24 6d 76 10 f0 	movl   $0xf010766d,(%esp)
f0100de7:	e8 02 38 00 00       	call   f01045ee <cprintf>
f0100dec:	eb 0c                	jmp    f0100dfa <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100dee:	c7 04 24 75 76 10 f0 	movl   $0xf0107675,(%esp)
f0100df5:	e8 f4 37 00 00       	call   f01045ee <cprintf>
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
f0100e0f:	c7 04 24 d6 86 10 f0 	movl   $0xf01086d6,(%esp)
f0100e16:	e8 d3 37 00 00       	call   f01045ee <cprintf>
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
f0100e66:	c7 04 24 7b 76 10 f0 	movl   $0xf010767b,(%esp)
f0100e6d:	e8 7c 37 00 00       	call   f01045ee <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100e72:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0100e77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e7c:	77 20                	ja     f0100e9e <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e82:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0100e89:	f0 
f0100e8a:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100e91:	00 
f0100e92:	c7 04 24 95 76 10 f0 	movl   $0xf0107695,(%esp)
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
f0100ebe:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0100ec5:	f0 
f0100ec6:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100ecd:	00 
f0100ece:	c7 04 24 95 76 10 f0 	movl   $0xf0107695,(%esp)
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
f0100ef4:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0100efb:	f0 
f0100efc:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0100f03:	00 
f0100f04:	c7 04 24 95 76 10 f0 	movl   $0xf0107695,(%esp)
f0100f0b:	e8 30 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f10:	89 da                	mov    %ebx,%edx
f0100f12:	29 c2                	sub    %eax,%edx
f0100f14:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f1e:	c7 04 24 6d 76 10 f0 	movl   $0xf010766d,(%esp)
f0100f25:	e8 c4 36 00 00       	call   f01045ee <cprintf>
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
f0100f3f:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0100f46:	f0 
f0100f47:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f4e:	00 
f0100f4f:	c7 04 24 95 76 10 f0 	movl   $0xf0107695,(%esp)
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
f0100f73:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0100f7a:	f0 
f0100f7b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f82:	00 
f0100f83:	c7 04 24 95 76 10 f0 	movl   $0xf0107695,(%esp)
f0100f8a:	e8 b1 f0 ff ff       	call   f0100040 <_panic>
f0100f8f:	81 fb 00 10 12 00    	cmp    $0x121000,%ebx
f0100f95:	73 1c                	jae    f0100fb3 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100f97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f9a:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa5:	c7 04 24 6d 76 10 f0 	movl   $0xf010766d,(%esp)
f0100fac:	e8 3d 36 00 00       	call   f01045ee <cprintf>
f0100fb1:	eb 2c                	jmp    f0100fdf <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100fb3:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100fb9:	77 18                	ja     f0100fd3 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100fbb:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fc5:	c7 04 24 6d 76 10 f0 	movl   $0xf010766d,(%esp)
f0100fcc:	e8 1d 36 00 00       	call   f01045ee <cprintf>
f0100fd1:	eb 0c                	jmp    f0100fdf <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0100fd3:	c7 04 24 75 76 10 f0 	movl   $0xf0107675,(%esp)
f0100fda:	e8 0f 36 00 00       	call   f01045ee <cprintf>
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
f0100ff4:	c7 04 24 d6 86 10 f0 	movl   $0xf01086d6,(%esp)
f0100ffb:	e8 ee 35 00 00       	call   f01045ee <cprintf>
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
f0101035:	c7 04 24 b0 78 10 f0 	movl   $0xf01078b0,(%esp)
f010103c:	e8 ad 35 00 00       	call   f01045ee <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101041:	c7 04 24 d4 78 10 f0 	movl   $0xf01078d4,(%esp)
f0101048:	e8 a1 35 00 00       	call   f01045ee <cprintf>

	if (tf != NULL)
f010104d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101051:	74 0b                	je     f010105e <monitor+0x32>
		print_trapframe(tf);
f0101053:	8b 45 08             	mov    0x8(%ebp),%eax
f0101056:	89 04 24             	mov    %eax,(%esp)
f0101059:	e8 59 38 00 00       	call   f01048b7 <print_trapframe>

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f010105e:	c7 04 24 fc 78 10 f0 	movl   $0xf01078fc,(%esp)
f0101065:	e8 84 35 00 00       	call   f01045ee <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f010106a:	c7 04 24 30 79 10 f0 	movl   $0xf0107930,(%esp)
f0101071:	e8 78 35 00 00       	call   f01045ee <cprintf>
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);


	while (1) {
		buf = readline("K> ");
f0101076:	c7 04 24 a4 76 10 f0 	movl   $0xf01076a4,(%esp)
f010107d:	e8 8e 51 00 00       	call   f0106210 <readline>
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
f01010aa:	c7 04 24 a8 76 10 f0 	movl   $0xf01076a8,(%esp)
f01010b1:	e8 b0 53 00 00       	call   f0106466 <strchr>
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
f01010cc:	c7 04 24 ad 76 10 f0 	movl   $0xf01076ad,(%esp)
f01010d3:	e8 16 35 00 00       	call   f01045ee <cprintf>
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
f01010fb:	c7 04 24 a8 76 10 f0 	movl   $0xf01076a8,(%esp)
f0101102:	e8 5f 53 00 00       	call   f0106466 <strchr>
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
f010111d:	bb a0 7a 10 f0       	mov    $0xf0107aa0,%ebx
f0101122:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101127:	8b 03                	mov    (%ebx),%eax
f0101129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010112d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101130:	89 04 24             	mov    %eax,(%esp)
f0101133:	e8 b3 52 00 00       	call   f01063eb <strcmp>
f0101138:	85 c0                	test   %eax,%eax
f010113a:	75 24                	jne    f0101160 <monitor+0x134>
			return commands[i].func(argc, argv, tf);
f010113c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010113f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101142:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101146:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101149:	89 54 24 04          	mov    %edx,0x4(%esp)
f010114d:	89 34 24             	mov    %esi,(%esp)
f0101150:	ff 14 85 a8 7a 10 f0 	call   *-0xfef8558(,%eax,4)


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
f0101172:	c7 04 24 ca 76 10 f0 	movl   $0xf01076ca,(%esp)
f0101179:	e8 70 34 00 00       	call   f01045ee <cprintf>
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
f01011bf:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01011c6:	f0 
f01011c7:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01011ce:	00 
f01011cf:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101244:	c7 44 24 08 01 84 10 	movl   $0xf0108401,0x8(%esp)
f010124b:	f0 
f010124c:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0101253:	00 
f0101254:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101283:	c7 44 24 08 01 84 10 	movl   $0xf0108401,0x8(%esp)
f010128a:	f0 
f010128b:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
f0101292:	00 
f0101293:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01012cb:	e8 b4 31 00 00       	call   f0104484 <mc146818_read>
f01012d0:	89 c6                	mov    %eax,%esi
f01012d2:	83 c3 01             	add    $0x1,%ebx
f01012d5:	89 1c 24             	mov    %ebx,(%esp)
f01012d8:	e8 a7 31 00 00       	call   f0104484 <mc146818_read>
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
f010130c:	c7 44 24 08 e8 7a 10 	movl   $0xf0107ae8,0x8(%esp)
f0101313:	f0 
f0101314:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f010131b:	00 
f010131c:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01013a4:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01013ab:	f0 
f01013ac:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01013b3:	00 
f01013b4:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f01013bb:	e8 80 ec ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01013c0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01013c7:	00 
f01013c8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01013cf:	00 
	return (void *)(pa + KERNBASE);
f01013d0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013d5:	89 04 24             	mov    %eax,(%esp)
f01013d8:	e8 e4 50 00 00       	call   f01064c1 <memset>
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
f0101459:	c7 44 24 0c 1f 84 10 	movl   $0xf010841f,0xc(%esp)
f0101460:	f0 
f0101461:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101468:	f0 
f0101469:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101470:	00 
f0101471:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101478:	e8 c3 eb ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010147d:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101480:	72 24                	jb     f01014a6 <check_page_free_list+0x1ba>
f0101482:	c7 44 24 0c 40 84 10 	movl   $0xf0108440,0xc(%esp)
f0101489:	f0 
f010148a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101491:	f0 
f0101492:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101499:	00 
f010149a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01014a1:	e8 9a eb ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01014a6:	89 d0                	mov    %edx,%eax
f01014a8:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01014ab:	a8 07                	test   $0x7,%al
f01014ad:	74 24                	je     f01014d3 <check_page_free_list+0x1e7>
f01014af:	c7 44 24 0c 0c 7b 10 	movl   $0xf0107b0c,0xc(%esp)
f01014b6:	f0 
f01014b7:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f01014c6:	00 
f01014c7:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01014ce:	e8 6d eb ff ff       	call   f0100040 <_panic>
f01014d3:	c1 f8 03             	sar    $0x3,%eax
f01014d6:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01014d9:	85 c0                	test   %eax,%eax
f01014db:	75 24                	jne    f0101501 <check_page_free_list+0x215>
f01014dd:	c7 44 24 0c 54 84 10 	movl   $0xf0108454,0xc(%esp)
f01014e4:	f0 
f01014e5:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01014ec:	f0 
f01014ed:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01014f4:	00 
f01014f5:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01014fc:	e8 3f eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101501:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101506:	75 24                	jne    f010152c <check_page_free_list+0x240>
f0101508:	c7 44 24 0c 65 84 10 	movl   $0xf0108465,0xc(%esp)
f010150f:	f0 
f0101510:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101517:	f0 
f0101518:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f010151f:	00 
f0101520:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101527:	e8 14 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010152c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101531:	75 24                	jne    f0101557 <check_page_free_list+0x26b>
f0101533:	c7 44 24 0c 40 7b 10 	movl   $0xf0107b40,0xc(%esp)
f010153a:	f0 
f010153b:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101542:	f0 
f0101543:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f010154a:	00 
f010154b:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101552:	e8 e9 ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101557:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010155c:	75 24                	jne    f0101582 <check_page_free_list+0x296>
f010155e:	c7 44 24 0c 7e 84 10 	movl   $0xf010847e,0xc(%esp)
f0101565:	f0 
f0101566:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010156d:	f0 
f010156e:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101575:	00 
f0101576:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101599:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01015a0:	f0 
f01015a1:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01015a8:	00 
f01015a9:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f01015b0:	e8 8b ea ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01015b5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01015bb:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01015be:	76 24                	jbe    f01015e4 <check_page_free_list+0x2f8>
f01015c0:	c7 44 24 0c 64 7b 10 	movl   $0xf0107b64,0xc(%esp)
f01015c7:	f0 
f01015c8:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01015cf:	f0 
f01015d0:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f01015d7:	00 
f01015d8:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01015df:	e8 5c ea ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01015e4:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01015e9:	75 24                	jne    f010160f <check_page_free_list+0x323>
f01015eb:	c7 44 24 0c 98 84 10 	movl   $0xf0108498,0xc(%esp)
f01015f2:	f0 
f01015f3:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101602:	00 
f0101603:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010162d:	c7 44 24 0c b5 84 10 	movl   $0xf01084b5,0xc(%esp)
f0101634:	f0 
f0101635:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010163c:	f0 
f010163d:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101644:	00 
f0101645:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101651:	85 f6                	test   %esi,%esi
f0101653:	7f 24                	jg     f0101679 <check_page_free_list+0x38d>
f0101655:	c7 44 24 0c c7 84 10 	movl   $0xf01084c7,0xc(%esp)
f010165c:	f0 
f010165d:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101664:	f0 
f0101665:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f010166c:	00 
f010166d:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101674:	e8 c7 e9 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101679:	c7 04 24 ac 7b 10 f0 	movl   $0xf0107bac,(%esp)
f0101680:	e8 69 2f 00 00       	call   f01045ee <cprintf>
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
f01016e6:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f01016ed:	f0 
f01016ee:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f01016f5:	00 
f01016f6:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010179f:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01017a6:	f0 
f01017a7:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01017ae:	00 
f01017af:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
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
f01017d3:	e8 e9 4c 00 00       	call   f01064c1 <memset>
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
f01017ed:	c7 44 24 08 d0 7b 10 	movl   $0xf0107bd0,0x8(%esp)
f01017f4:	f0 
f01017f5:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f01017fc:	00 
f01017fd:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010189a:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01018a1:	f0 
f01018a2:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
f01018a9:	00 
f01018aa:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101988:	c7 44 24 08 f4 7b 10 	movl   $0xf0107bf4,0x8(%esp)
f010198f:	f0 
f0101990:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101997:	00 
f0101998:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
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
f01019c7:	e8 84 51 00 00       	call   f0106b50 <cpunum>
f01019cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01019cf:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01019d6:	74 16                	je     f01019ee <tlb_invalidate+0x2d>
f01019d8:	e8 73 51 00 00       	call   f0106b50 <cpunum>
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
f0101b21:	c7 44 24 08 d8 84 10 	movl   $0xf01084d8,0x8(%esp)
f0101b28:	f0 
f0101b29:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101b30:	00 
f0101b31:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101bf1:	c7 04 24 14 7c 10 f0 	movl   $0xf0107c14,(%esp)
f0101bf8:	e8 f1 29 00 00       	call   f01045ee <cprintf>
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
f0101c1f:	e8 9d 48 00 00       	call   f01064c1 <memset>
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
f0101c34:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0101c3b:	f0 
f0101c3c:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
f0101c43:	00 
f0101c44:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101c71:	b8 00 00 02 00       	mov    $0x20000,%eax
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
f0101c98:	c7 44 24 08 ea 84 10 	movl   $0xf01084ea,0x8(%esp)
f0101c9f:	f0 
f0101ca0:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101ca7:	00 
f0101ca8:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101cdd:	c7 44 24 0c 05 85 10 	movl   $0xf0108505,0xc(%esp)
f0101ce4:	f0 
f0101ce5:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101cec:	f0 
f0101ced:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101cf4:	00 
f0101cf5:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101cfc:	e8 3f e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d08:	e8 55 fa ff ff       	call   f0101762 <page_alloc>
f0101d0d:	89 c7                	mov    %eax,%edi
f0101d0f:	85 c0                	test   %eax,%eax
f0101d11:	75 24                	jne    f0101d37 <mem_init+0x1d0>
f0101d13:	c7 44 24 0c 1b 85 10 	movl   $0xf010851b,0xc(%esp)
f0101d1a:	f0 
f0101d1b:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101d2a:	00 
f0101d2b:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101d32:	e8 09 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d3e:	e8 1f fa ff ff       	call   f0101762 <page_alloc>
f0101d43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d46:	85 c0                	test   %eax,%eax
f0101d48:	75 24                	jne    f0101d6e <mem_init+0x207>
f0101d4a:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f0101d51:	f0 
f0101d52:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101d59:	f0 
f0101d5a:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101d61:	00 
f0101d62:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101d69:	e8 d2 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d6e:	39 fe                	cmp    %edi,%esi
f0101d70:	75 24                	jne    f0101d96 <mem_init+0x22f>
f0101d72:	c7 44 24 0c 47 85 10 	movl   $0xf0108547,0xc(%esp)
f0101d79:	f0 
f0101d7a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101d81:	f0 
f0101d82:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101d89:	00 
f0101d8a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101d91:	e8 aa e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d96:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d99:	74 05                	je     f0101da0 <mem_init+0x239>
f0101d9b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d9e:	75 24                	jne    f0101dc4 <mem_init+0x25d>
f0101da0:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101de0:	c7 44 24 0c 59 85 10 	movl   $0xf0108559,0xc(%esp)
f0101de7:	f0 
f0101de8:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101def:	f0 
f0101df0:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101df7:	00 
f0101df8:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101dff:	e8 3c e2 ff ff       	call   f0100040 <_panic>
f0101e04:	89 f9                	mov    %edi,%ecx
f0101e06:	29 d1                	sub    %edx,%ecx
f0101e08:	c1 f9 03             	sar    $0x3,%ecx
f0101e0b:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101e0e:	39 c8                	cmp    %ecx,%eax
f0101e10:	77 24                	ja     f0101e36 <mem_init+0x2cf>
f0101e12:	c7 44 24 0c 76 85 10 	movl   $0xf0108576,0xc(%esp)
f0101e19:	f0 
f0101e1a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101e21:	f0 
f0101e22:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101e29:	00 
f0101e2a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101e31:	e8 0a e2 ff ff       	call   f0100040 <_panic>
f0101e36:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e39:	29 d1                	sub    %edx,%ecx
f0101e3b:	89 ca                	mov    %ecx,%edx
f0101e3d:	c1 fa 03             	sar    $0x3,%edx
f0101e40:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e43:	39 d0                	cmp    %edx,%eax
f0101e45:	77 24                	ja     f0101e6b <mem_init+0x304>
f0101e47:	c7 44 24 0c 93 85 10 	movl   $0xf0108593,0xc(%esp)
f0101e4e:	f0 
f0101e4f:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101e56:	f0 
f0101e57:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101e5e:	00 
f0101e5f:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101e8d:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f0101e94:	f0 
f0101e95:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101e9c:	f0 
f0101e9d:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101ea4:	00 
f0101ea5:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0101ede:	c7 44 24 0c 05 85 10 	movl   $0xf0108505,0xc(%esp)
f0101ee5:	f0 
f0101ee6:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101eed:	f0 
f0101eee:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101ef5:	00 
f0101ef6:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101efd:	e8 3e e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f09:	e8 54 f8 ff ff       	call   f0101762 <page_alloc>
f0101f0e:	89 c7                	mov    %eax,%edi
f0101f10:	85 c0                	test   %eax,%eax
f0101f12:	75 24                	jne    f0101f38 <mem_init+0x3d1>
f0101f14:	c7 44 24 0c 1b 85 10 	movl   $0xf010851b,0xc(%esp)
f0101f1b:	f0 
f0101f1c:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101f2b:	00 
f0101f2c:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101f33:	e8 08 e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f3f:	e8 1e f8 ff ff       	call   f0101762 <page_alloc>
f0101f44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f47:	85 c0                	test   %eax,%eax
f0101f49:	75 24                	jne    f0101f6f <mem_init+0x408>
f0101f4b:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101f6a:	e8 d1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f6f:	39 fe                	cmp    %edi,%esi
f0101f71:	75 24                	jne    f0101f97 <mem_init+0x430>
f0101f73:	c7 44 24 0c 47 85 10 	movl   $0xf0108547,0xc(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101f82:	f0 
f0101f83:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101f8a:	00 
f0101f8b:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101f92:	e8 a9 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f97:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101f9a:	74 05                	je     f0101fa1 <mem_init+0x43a>
f0101f9c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101f9f:	75 24                	jne    f0101fc5 <mem_init+0x45e>
f0101fa1:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0101fa8:	f0 
f0101fa9:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101fb0:	f0 
f0101fb1:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101fb8:	00 
f0101fb9:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0101fc0:	e8 7b e0 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fcc:	e8 91 f7 ff ff       	call   f0101762 <page_alloc>
f0101fd1:	85 c0                	test   %eax,%eax
f0101fd3:	74 24                	je     f0101ff9 <mem_init+0x492>
f0101fd5:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f0101fdc:	f0 
f0101fdd:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0101fe4:	f0 
f0101fe5:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101fec:	00 
f0101fed:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102018:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f010201f:	f0 
f0102020:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102027:	00 
f0102028:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
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
f010204c:	e8 70 44 00 00       	call   f01064c1 <memset>
	page_free(pp0);
f0102051:	89 34 24             	mov    %esi,(%esp)
f0102054:	e8 87 f7 ff ff       	call   f01017e0 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102059:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102060:	e8 fd f6 ff ff       	call   f0101762 <page_alloc>
f0102065:	85 c0                	test   %eax,%eax
f0102067:	75 24                	jne    f010208d <mem_init+0x526>
f0102069:	c7 44 24 0c bf 85 10 	movl   $0xf01085bf,0xc(%esp)
f0102070:	f0 
f0102071:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102078:	f0 
f0102079:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102080:	00 
f0102081:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102088:	e8 b3 df ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010208d:	39 c6                	cmp    %eax,%esi
f010208f:	74 24                	je     f01020b5 <mem_init+0x54e>
f0102091:	c7 44 24 0c dd 85 10 	movl   $0xf01085dd,0xc(%esp)
f0102098:	f0 
f0102099:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01020a0:	f0 
f01020a1:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f01020a8:	00 
f01020a9:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01020d4:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01020db:	f0 
f01020dc:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01020e3:	00 
f01020e4:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
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
f010210a:	c7 44 24 0c ed 85 10 	movl   $0xf01085ed,0xc(%esp)
f0102111:	f0 
f0102112:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102119:	f0 
f010211a:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102121:	00 
f0102122:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010216f:	c7 44 24 0c f7 85 10 	movl   $0xf01085f7,0xc(%esp)
f0102176:	f0 
f0102177:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010217e:	f0 
f010217f:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102186:	00 
f0102187:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010218e:	e8 ad de ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102193:	c7 04 24 70 7c 10 f0 	movl   $0xf0107c70,(%esp)
f010219a:	e8 4f 24 00 00       	call   f01045ee <cprintf>
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
f01021b1:	c7 44 24 0c 05 85 10 	movl   $0xf0108505,0xc(%esp)
f01021b8:	f0 
f01021b9:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01021c0:	f0 
f01021c1:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01021c8:	00 
f01021c9:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01021d0:	e8 6b de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021dc:	e8 81 f5 ff ff       	call   f0101762 <page_alloc>
f01021e1:	89 c7                	mov    %eax,%edi
f01021e3:	85 c0                	test   %eax,%eax
f01021e5:	75 24                	jne    f010220b <mem_init+0x6a4>
f01021e7:	c7 44 24 0c 1b 85 10 	movl   $0xf010851b,0xc(%esp)
f01021ee:	f0 
f01021ef:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01021f6:	f0 
f01021f7:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01021fe:	00 
f01021ff:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102206:	e8 35 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010220b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102212:	e8 4b f5 ff ff       	call   f0101762 <page_alloc>
f0102217:	89 c3                	mov    %eax,%ebx
f0102219:	85 c0                	test   %eax,%eax
f010221b:	75 24                	jne    f0102241 <mem_init+0x6da>
f010221d:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f0102224:	f0 
f0102225:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010222c:	f0 
f010222d:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102234:	00 
f0102235:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010223c:	e8 ff dd ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102241:	39 fe                	cmp    %edi,%esi
f0102243:	75 24                	jne    f0102269 <mem_init+0x702>
f0102245:	c7 44 24 0c 47 85 10 	movl   $0xf0108547,0xc(%esp)
f010224c:	f0 
f010224d:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102254:	f0 
f0102255:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f010225c:	00 
f010225d:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102264:	e8 d7 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102269:	39 c7                	cmp    %eax,%edi
f010226b:	74 04                	je     f0102271 <mem_init+0x70a>
f010226d:	39 c6                	cmp    %eax,%esi
f010226f:	75 24                	jne    f0102295 <mem_init+0x72e>
f0102271:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0102278:	f0 
f0102279:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102280:	f0 
f0102281:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102288:	00 
f0102289:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01022b8:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f01022bf:	f0 
f01022c0:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01022c7:	f0 
f01022c8:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01022cf:	00 
f01022d0:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01022fc:	c7 44 24 0c 90 7c 10 	movl   $0xf0107c90,0xc(%esp)
f0102303:	f0 
f0102304:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010230b:	f0 
f010230c:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102313:	00 
f0102314:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102345:	c7 44 24 0c c8 7c 10 	movl   $0xf0107cc8,0xc(%esp)
f010234c:	f0 
f010234d:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102354:	f0 
f0102355:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f010235c:	00 
f010235d:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102396:	c7 44 24 0c f8 7c 10 	movl   $0xf0107cf8,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01023e2:	c7 44 24 0c 28 7d 10 	movl   $0xf0107d28,0xc(%esp)
f01023e9:	f0 
f01023ea:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01023f1:	f0 
f01023f2:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f01023f9:	00 
f01023fa:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102422:	c7 44 24 0c 50 7d 10 	movl   $0xf0107d50,0xc(%esp)
f0102429:	f0 
f010242a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102431:	f0 
f0102432:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102439:	00 
f010243a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102446:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010244b:	74 24                	je     f0102471 <mem_init+0x90a>
f010244d:	c7 44 24 0c 02 86 10 	movl   $0xf0108602,0xc(%esp)
f0102454:	f0 
f0102455:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010245c:	f0 
f010245d:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0102464:	00 
f0102465:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010246c:	e8 cf db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102471:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102476:	74 24                	je     f010249c <mem_init+0x935>
f0102478:	c7 44 24 0c 13 86 10 	movl   $0xf0108613,0xc(%esp)
f010247f:	f0 
f0102480:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102487:	f0 
f0102488:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f010248f:	00 
f0102490:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01024bf:	c7 44 24 0c 80 7d 10 	movl   $0xf0107d80,0xc(%esp)
f01024c6:	f0 
f01024c7:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01024ce:	f0 
f01024cf:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01024d6:	00 
f01024d7:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102504:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f010250b:	f0 
f010250c:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102513:	f0 
f0102514:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f010251b:	00 
f010251c:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102523:	e8 18 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102528:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010252d:	74 24                	je     f0102553 <mem_init+0x9ec>
f010252f:	c7 44 24 0c 24 86 10 	movl   $0xf0108624,0xc(%esp)
f0102536:	f0 
f0102537:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010253e:	f0 
f010253f:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102546:	00 
f0102547:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010254e:	e8 ed da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102553:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010255a:	e8 03 f2 ff ff       	call   f0101762 <page_alloc>
f010255f:	85 c0                	test   %eax,%eax
f0102561:	74 24                	je     f0102587 <mem_init+0xa20>
f0102563:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f010256a:	f0 
f010256b:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102572:	f0 
f0102573:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f010257a:	00 
f010257b:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01025ac:	c7 44 24 0c 80 7d 10 	movl   $0xf0107d80,0xc(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f01025c3:	00 
f01025c4:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01025f1:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f01025f8:	f0 
f01025f9:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102600:	f0 
f0102601:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102608:	00 
f0102609:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102610:	e8 2b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102615:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010261a:	74 24                	je     f0102640 <mem_init+0xad9>
f010261c:	c7 44 24 0c 24 86 10 	movl   $0xf0108624,0xc(%esp)
f0102623:	f0 
f0102624:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010262b:	f0 
f010262c:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102633:	00 
f0102634:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010263b:	e8 00 da ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102640:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102647:	e8 16 f1 ff ff       	call   f0101762 <page_alloc>
f010264c:	85 c0                	test   %eax,%eax
f010264e:	74 24                	je     f0102674 <mem_init+0xb0d>
f0102650:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f0102657:	f0 
f0102658:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010265f:	f0 
f0102660:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0102667:	00 
f0102668:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102692:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0102699:	f0 
f010269a:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01026a1:	00 
f01026a2:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01026d8:	c7 44 24 0c ec 7d 10 	movl   $0xf0107dec,0xc(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01026e7:	f0 
f01026e8:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f01026ef:	00 
f01026f0:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102721:	c7 44 24 0c 2c 7e 10 	movl   $0xf0107e2c,0xc(%esp)
f0102728:	f0 
f0102729:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102730:	f0 
f0102731:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0102738:	00 
f0102739:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010276c:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f0102773:	f0 
f0102774:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010277b:	f0 
f010277c:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102783:	00 
f0102784:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010278b:	e8 b0 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102790:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102795:	74 24                	je     f01027bb <mem_init+0xc54>
f0102797:	c7 44 24 0c 24 86 10 	movl   $0xf0108624,0xc(%esp)
f010279e:	f0 
f010279f:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01027a6:	f0 
f01027a7:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01027ae:	00 
f01027af:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01027db:	c7 44 24 0c 6c 7e 10 	movl   $0xf0107e6c,0xc(%esp)
f01027e2:	f0 
f01027e3:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01027ea:	f0 
f01027eb:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01027f2:	00 
f01027f3:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01027ff:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102804:	f6 00 04             	testb  $0x4,(%eax)
f0102807:	75 24                	jne    f010282d <mem_init+0xcc6>
f0102809:	c7 44 24 0c 35 86 10 	movl   $0xf0108635,0xc(%esp)
f0102810:	f0 
f0102811:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102818:	f0 
f0102819:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0102820:	00 
f0102821:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010284d:	c7 44 24 0c 80 7d 10 	movl   $0xf0107d80,0xc(%esp)
f0102854:	f0 
f0102855:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010285c:	f0 
f010285d:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102864:	00 
f0102865:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102893:	c7 44 24 0c a0 7e 10 	movl   $0xf0107ea0,0xc(%esp)
f010289a:	f0 
f010289b:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01028a2:	f0 
f01028a3:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f01028aa:	00 
f01028ab:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01028d9:	c7 44 24 0c d4 7e 10 	movl   $0xf0107ed4,0xc(%esp)
f01028e0:	f0 
f01028e1:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01028e8:	f0 
f01028e9:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f01028f0:	00 
f01028f1:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102922:	c7 44 24 0c 0c 7f 10 	movl   $0xf0107f0c,0xc(%esp)
f0102929:	f0 
f010292a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102931:	f0 
f0102932:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102939:	00 
f010293a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010296b:	c7 44 24 0c 44 7f 10 	movl   $0xf0107f44,0xc(%esp)
f0102972:	f0 
f0102973:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010297a:	f0 
f010297b:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0102982:	00 
f0102983:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01029b1:	c7 44 24 0c d4 7e 10 	movl   $0xf0107ed4,0xc(%esp)
f01029b8:	f0 
f01029b9:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01029c0:	f0 
f01029c1:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01029c8:	00 
f01029c9:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01029fd:	c7 44 24 0c 80 7f 10 	movl   $0xf0107f80,0xc(%esp)
f0102a04:	f0 
f0102a05:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102a0c:	f0 
f0102a0d:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102a14:	00 
f0102a15:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102a1c:	e8 1f d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a21:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a29:	e8 62 e7 ff ff       	call   f0101190 <check_va2pa>
f0102a2e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a31:	74 24                	je     f0102a57 <mem_init+0xef0>
f0102a33:	c7 44 24 0c ac 7f 10 	movl   $0xf0107fac,0xc(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102a4a:	00 
f0102a4b:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102a52:	e8 e9 d5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102a57:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102a5c:	74 24                	je     f0102a82 <mem_init+0xf1b>
f0102a5e:	c7 44 24 0c 4b 86 10 	movl   $0xf010864b,0xc(%esp)
f0102a65:	f0 
f0102a66:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102a6d:	f0 
f0102a6e:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0102a75:	00 
f0102a76:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102a7d:	e8 be d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a82:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a87:	74 24                	je     f0102aad <mem_init+0xf46>
f0102a89:	c7 44 24 0c 5c 86 10 	movl   $0xf010865c,0xc(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102aa0:	00 
f0102aa1:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102aa8:	e8 93 d5 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102aad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ab4:	e8 a9 ec ff ff       	call   f0101762 <page_alloc>
f0102ab9:	85 c0                	test   %eax,%eax
f0102abb:	74 04                	je     f0102ac1 <mem_init+0xf5a>
f0102abd:	39 c3                	cmp    %eax,%ebx
f0102abf:	74 24                	je     f0102ae5 <mem_init+0xf7e>
f0102ac1:	c7 44 24 0c dc 7f 10 	movl   $0xf0107fdc,0xc(%esp)
f0102ac8:	f0 
f0102ac9:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102ad0:	f0 
f0102ad1:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102ad8:	00 
f0102ad9:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102b15:	c7 44 24 0c 00 80 10 	movl   $0xf0108000,0xc(%esp)
f0102b1c:	f0 
f0102b1d:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102b24:	f0 
f0102b25:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0102b2c:	00 
f0102b2d:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102b58:	c7 44 24 0c ac 7f 10 	movl   $0xf0107fac,0xc(%esp)
f0102b5f:	f0 
f0102b60:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102b67:	f0 
f0102b68:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0102b6f:	00 
f0102b70:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102b77:	e8 c4 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102b7c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b81:	74 24                	je     f0102ba7 <mem_init+0x1040>
f0102b83:	c7 44 24 0c 02 86 10 	movl   $0xf0108602,0xc(%esp)
f0102b8a:	f0 
f0102b8b:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102b92:	f0 
f0102b93:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0102b9a:	00 
f0102b9b:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102ba2:	e8 99 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ba7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bac:	74 24                	je     f0102bd2 <mem_init+0x106b>
f0102bae:	c7 44 24 0c 5c 86 10 	movl   $0xf010865c,0xc(%esp)
f0102bb5:	f0 
f0102bb6:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102bbd:	f0 
f0102bbe:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0102bc5:	00 
f0102bc6:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102bfc:	c7 44 24 0c 00 80 10 	movl   $0xf0108000,0xc(%esp)
f0102c03:	f0 
f0102c04:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102c0b:	f0 
f0102c0c:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0102c13:	00 
f0102c14:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102c1b:	e8 20 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102c20:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102c25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c28:	e8 63 e5 ff ff       	call   f0101190 <check_va2pa>
f0102c2d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c30:	74 24                	je     f0102c56 <mem_init+0x10ef>
f0102c32:	c7 44 24 0c 24 80 10 	movl   $0xf0108024,0xc(%esp)
f0102c39:	f0 
f0102c3a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102c41:	f0 
f0102c42:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0102c49:	00 
f0102c4a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102c51:	e8 ea d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c56:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c5b:	74 24                	je     f0102c81 <mem_init+0x111a>
f0102c5d:	c7 44 24 0c 6d 86 10 	movl   $0xf010866d,0xc(%esp)
f0102c64:	f0 
f0102c65:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f0102c74:	00 
f0102c75:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102c7c:	e8 bf d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102c81:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c86:	74 24                	je     f0102cac <mem_init+0x1145>
f0102c88:	c7 44 24 0c 5c 86 10 	movl   $0xf010865c,0xc(%esp)
f0102c8f:	f0 
f0102c90:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102c97:	f0 
f0102c98:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102c9f:	00 
f0102ca0:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102ca7:	e8 94 d3 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cb3:	e8 aa ea ff ff       	call   f0101762 <page_alloc>
f0102cb8:	85 c0                	test   %eax,%eax
f0102cba:	74 04                	je     f0102cc0 <mem_init+0x1159>
f0102cbc:	39 c7                	cmp    %eax,%edi
f0102cbe:	74 24                	je     f0102ce4 <mem_init+0x117d>
f0102cc0:	c7 44 24 0c 4c 80 10 	movl   $0xf010804c,0xc(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102ccf:	f0 
f0102cd0:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0102cd7:	00 
f0102cd8:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102cdf:	e8 5c d3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102ce4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ceb:	e8 72 ea ff ff       	call   f0101762 <page_alloc>
f0102cf0:	85 c0                	test   %eax,%eax
f0102cf2:	74 24                	je     f0102d18 <mem_init+0x11b1>
f0102cf4:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f0102cfb:	f0 
f0102cfc:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102d03:	f0 
f0102d04:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102d0b:	00 
f0102d0c:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102d37:	c7 44 24 0c 28 7d 10 	movl   $0xf0107d28,0xc(%esp)
f0102d3e:	f0 
f0102d3f:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102d46:	f0 
f0102d47:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102d4e:	00 
f0102d4f:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102d56:	e8 e5 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d61:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d66:	74 24                	je     f0102d8c <mem_init+0x1225>
f0102d68:	c7 44 24 0c 13 86 10 	movl   $0xf0108613,0xc(%esp)
f0102d6f:	f0 
f0102d70:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102d77:	f0 
f0102d78:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f0102d7f:	00 
f0102d80:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102ded:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0102df4:	f0 
f0102df5:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f0102dfc:	00 
f0102dfd:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102e09:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e0c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102e12:	39 d0                	cmp    %edx,%eax
f0102e14:	74 24                	je     f0102e3a <mem_init+0x12d3>
f0102e16:	c7 44 24 0c 7e 86 10 	movl   $0xf010867e,0xc(%esp)
f0102e1d:	f0 
f0102e1e:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102e25:	f0 
f0102e26:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102e2d:	00 
f0102e2e:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102e63:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0102e6a:	f0 
f0102e6b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102e72:	00 
f0102e73:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
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
f0102e97:	e8 25 36 00 00       	call   f01064c1 <memset>
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
f0102ee0:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0102ee7:	f0 
f0102ee8:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102eef:	00 
f0102ef0:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
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
f0102f1f:	c7 44 24 0c 96 86 10 	movl   $0xf0108696,0xc(%esp)
f0102f26:	f0 
f0102f27:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102f2e:	f0 
f0102f2f:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f0102f36:	00 
f0102f37:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0102fbd:	c7 44 24 0c 70 80 10 	movl   $0xf0108070,0xc(%esp)
f0102fc4:	f0 
f0102fc5:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0102fcc:	f0 
f0102fcd:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f0102fd4:	00 
f0102fd5:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0102fdc:	e8 5f d0 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102fe1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102fe7:	76 0e                	jbe    f0102ff7 <mem_init+0x1490>
f0102fe9:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102fef:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102ff5:	76 24                	jbe    f010301b <mem_init+0x14b4>
f0102ff7:	c7 44 24 0c 98 80 10 	movl   $0xf0108098,0xc(%esp)
f0102ffe:	f0 
f0102fff:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103006:	f0 
f0103007:	c7 44 24 04 9e 04 00 	movl   $0x49e,0x4(%esp)
f010300e:	00 
f010300f:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103027:	c7 44 24 0c c0 80 10 	movl   $0xf01080c0,0xc(%esp)
f010302e:	f0 
f010302f:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103036:	f0 
f0103037:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f010303e:	00 
f010303f:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0103046:	e8 f5 cf ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010304b:	39 c6                	cmp    %eax,%esi
f010304d:	73 24                	jae    f0103073 <mem_init+0x150c>
f010304f:	c7 44 24 0c ad 86 10 	movl   $0xf01086ad,0xc(%esp)
f0103056:	f0 
f0103057:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010305e:	f0 
f010305f:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f0103066:	00 
f0103067:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010306e:	e8 cd cf ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103073:	8b 3d 8c ce 22 f0    	mov    0xf022ce8c,%edi
f0103079:	89 da                	mov    %ebx,%edx
f010307b:	89 f8                	mov    %edi,%eax
f010307d:	e8 0e e1 ff ff       	call   f0101190 <check_va2pa>
f0103082:	85 c0                	test   %eax,%eax
f0103084:	74 24                	je     f01030aa <mem_init+0x1543>
f0103086:	c7 44 24 0c e8 80 10 	movl   $0xf01080e8,0xc(%esp)
f010308d:	f0 
f010308e:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103095:	f0 
f0103096:	c7 44 24 04 a4 04 00 	movl   $0x4a4,0x4(%esp)
f010309d:	00 
f010309e:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01030a5:	e8 96 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01030aa:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01030b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01030b3:	89 c2                	mov    %eax,%edx
f01030b5:	89 f8                	mov    %edi,%eax
f01030b7:	e8 d4 e0 ff ff       	call   f0101190 <check_va2pa>
f01030bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01030c1:	74 24                	je     f01030e7 <mem_init+0x1580>
f01030c3:	c7 44 24 0c 0c 81 10 	movl   $0xf010810c,0xc(%esp)
f01030ca:	f0 
f01030cb:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01030d2:	f0 
f01030d3:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
f01030da:	00 
f01030db:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01030e2:	e8 59 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01030e7:	89 f2                	mov    %esi,%edx
f01030e9:	89 f8                	mov    %edi,%eax
f01030eb:	e8 a0 e0 ff ff       	call   f0101190 <check_va2pa>
f01030f0:	85 c0                	test   %eax,%eax
f01030f2:	74 24                	je     f0103118 <mem_init+0x15b1>
f01030f4:	c7 44 24 0c 3c 81 10 	movl   $0xf010813c,0xc(%esp)
f01030fb:	f0 
f01030fc:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103103:	f0 
f0103104:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f010310b:	00 
f010310c:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0103113:	e8 28 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103118:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010311e:	89 f8                	mov    %edi,%eax
f0103120:	e8 6b e0 ff ff       	call   f0101190 <check_va2pa>
f0103125:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103128:	74 24                	je     f010314e <mem_init+0x15e7>
f010312a:	c7 44 24 0c 60 81 10 	movl   $0xf0108160,0xc(%esp)
f0103131:	f0 
f0103132:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103139:	f0 
f010313a:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
f0103141:	00 
f0103142:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103167:	c7 44 24 0c 8c 81 10 	movl   $0xf010818c,0xc(%esp)
f010316e:	f0 
f010316f:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103176:	f0 
f0103177:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f010317e:	00 
f010317f:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01031a9:	c7 44 24 0c d0 81 10 	movl   $0xf01081d0,0xc(%esp)
f01031b0:	f0 
f01031b1:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01031b8:	f0 
f01031b9:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f01031c0:	00 
f01031c1:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010322d:	c7 04 24 bf 86 10 f0 	movl   $0xf01086bf,(%esp)
f0103234:	e8 b5 13 00 00       	call   f01045ee <cprintf>
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
f0103249:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0103250:	f0 
f0103251:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
f0103258:	00 
f0103259:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01032a7:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f01032ae:	f0 
f01032af:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f01032b6:	00 
f01032b7:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01032be:	e8 7d cd ff ff       	call   f0100040 <_panic>
f01032c3:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01032ca:	00 
	return (physaddr_t)kva - KERNBASE;
f01032cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01032d0:	89 04 24             	mov    %eax,(%esp)
f01032d3:	b9 00 00 02 00       	mov    $0x20000,%ecx
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
f01032f7:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f01032fe:	f0 
f01032ff:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
f0103306:	00 
f0103307:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103380:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0103387:	f0 
f0103388:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f010338f:	00 
f0103390:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103418:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f010341f:	f0 
f0103420:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103427:	00 
f0103428:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f010342f:	e8 0c cc ff ff       	call   f0100040 <_panic>
f0103434:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010343b:	39 d0                	cmp    %edx,%eax
f010343d:	74 24                	je     f0103463 <mem_init+0x18fc>
f010343f:	c7 44 24 0c 04 82 10 	movl   $0xf0108204,0xc(%esp)
f0103446:	f0 
f0103447:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010344e:	f0 
f010344f:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103456:	00 
f0103457:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103498:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f010349f:	f0 
f01034a0:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034a7:	00 
f01034a8:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01034af:	e8 8c cb ff ff       	call   f0100040 <_panic>
f01034b4:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01034bb:	39 d0                	cmp    %edx,%eax
f01034bd:	74 24                	je     f01034e3 <mem_init+0x197c>
f01034bf:	c7 44 24 0c 38 82 10 	movl   $0xf0108238,0xc(%esp)
f01034c6:	f0 
f01034c7:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01034ce:	f0 
f01034cf:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034d6:	00 
f01034d7:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01034de:	e8 5d cb ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01034e3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01034e9:	81 fe 00 00 02 00    	cmp    $0x20000,%esi
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
f0103511:	c7 44 24 0c 6c 82 10 	movl   $0xf010826c,0xc(%esp)
f0103518:	f0 
f0103519:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103520:	f0 
f0103521:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0103528:	00 
f0103529:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010358b:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0103592:	f0 
f0103593:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010359a:	00 
f010359b:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01035a2:	e8 99 ca ff ff       	call   f0100040 <_panic>
f01035a7:	39 f0                	cmp    %esi,%eax
f01035a9:	74 24                	je     f01035cf <mem_init+0x1a68>
f01035ab:	c7 44 24 0c 94 82 10 	movl   $0xf0108294,0xc(%esp)
f01035b2:	f0 
f01035b3:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01035ba:	f0 
f01035bb:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01035c2:	00 
f01035c3:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f01035fb:	c7 44 24 0c dc 82 10 	movl   $0xf01082dc,0xc(%esp)
f0103602:	f0 
f0103603:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f010360a:	f0 
f010360b:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0103612:	00 
f0103613:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103664:	c7 44 24 0c d8 86 10 	movl   $0xf01086d8,0xc(%esp)
f010366b:	f0 
f010366c:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103673:	f0 
f0103674:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f010367b:	00 
f010367c:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103697:	c7 44 24 0c d8 86 10 	movl   $0xf01086d8,0xc(%esp)
f010369e:	f0 
f010369f:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01036a6:	f0 
f01036a7:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01036ae:	00 
f01036af:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01036b6:	e8 85 c9 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01036bb:	f6 c2 02             	test   $0x2,%dl
f01036be:	75 4e                	jne    f010370e <mem_init+0x1ba7>
f01036c0:	c7 44 24 0c e9 86 10 	movl   $0xf01086e9,0xc(%esp)
f01036c7:	f0 
f01036c8:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01036cf:	f0 
f01036d0:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01036d7:	00 
f01036d8:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01036df:	e8 5c c9 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01036e4:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01036e8:	74 24                	je     f010370e <mem_init+0x1ba7>
f01036ea:	c7 44 24 0c fa 86 10 	movl   $0xf01086fa,0xc(%esp)
f01036f1:	f0 
f01036f2:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01036f9:	f0 
f01036fa:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0103701:	00 
f0103702:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010371c:	c7 04 24 00 83 10 f0 	movl   $0xf0108300,(%esp)
f0103723:	e8 c6 0e 00 00       	call   f01045ee <cprintf>
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
f0103738:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f010373f:	f0 
f0103740:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f0103747:	00 
f0103748:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103786:	c7 44 24 0c 05 85 10 	movl   $0xf0108505,0xc(%esp)
f010378d:	f0 
f010378e:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103795:	f0 
f0103796:	c7 44 24 04 bf 04 00 	movl   $0x4bf,0x4(%esp)
f010379d:	00 
f010379e:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01037a5:	e8 96 c8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01037aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037b1:	e8 ac df ff ff       	call   f0101762 <page_alloc>
f01037b6:	89 c7                	mov    %eax,%edi
f01037b8:	85 c0                	test   %eax,%eax
f01037ba:	75 24                	jne    f01037e0 <mem_init+0x1c79>
f01037bc:	c7 44 24 0c 1b 85 10 	movl   $0xf010851b,0xc(%esp)
f01037c3:	f0 
f01037c4:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01037cb:	f0 
f01037cc:	c7 44 24 04 c0 04 00 	movl   $0x4c0,0x4(%esp)
f01037d3:	00 
f01037d4:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01037db:	e8 60 c8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01037e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037e7:	e8 76 df ff ff       	call   f0101762 <page_alloc>
f01037ec:	89 c3                	mov    %eax,%ebx
f01037ee:	85 c0                	test   %eax,%eax
f01037f0:	75 24                	jne    f0103816 <mem_init+0x1caf>
f01037f2:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f01037f9:	f0 
f01037fa:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103801:	f0 
f0103802:	c7 44 24 04 c1 04 00 	movl   $0x4c1,0x4(%esp)
f0103809:	00 
f010380a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f010383d:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0103844:	f0 
f0103845:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f010384c:	00 
f010384d:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f0103854:	e8 e7 c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103859:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103860:	00 
f0103861:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103868:	00 
	return (void *)(pa + KERNBASE);
f0103869:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010386e:	89 04 24             	mov    %eax,(%esp)
f0103871:	e8 4b 2c 00 00       	call   f01064c1 <memset>
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
f0103895:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f010389c:	f0 
f010389d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01038a4:	00 
f01038a5:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f01038ac:	e8 8f c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01038b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038b8:	00 
f01038b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01038c0:	00 
	return (void *)(pa + KERNBASE);
f01038c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038c6:	89 04 24             	mov    %eax,(%esp)
f01038c9:	e8 f3 2b 00 00       	call   f01064c1 <memset>
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
f01038f6:	c7 44 24 0c 02 86 10 	movl   $0xf0108602,0xc(%esp)
f01038fd:	f0 
f01038fe:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103905:	f0 
f0103906:	c7 44 24 04 c6 04 00 	movl   $0x4c6,0x4(%esp)
f010390d:	00 
f010390e:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0103915:	e8 26 c7 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010391a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103921:	01 01 01 
f0103924:	74 24                	je     f010394a <mem_init+0x1de3>
f0103926:	c7 44 24 0c 20 83 10 	movl   $0xf0108320,0xc(%esp)
f010392d:	f0 
f010392e:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103935:	f0 
f0103936:	c7 44 24 04 c7 04 00 	movl   $0x4c7,0x4(%esp)
f010393d:	00 
f010393e:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103977:	c7 44 24 0c 44 83 10 	movl   $0xf0108344,0xc(%esp)
f010397e:	f0 
f010397f:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103986:	f0 
f0103987:	c7 44 24 04 c9 04 00 	movl   $0x4c9,0x4(%esp)
f010398e:	00 
f010398f:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0103996:	e8 a5 c6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010399b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01039a0:	74 24                	je     f01039c6 <mem_init+0x1e5f>
f01039a2:	c7 44 24 0c 24 86 10 	movl   $0xf0108624,0xc(%esp)
f01039a9:	f0 
f01039aa:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01039b1:	f0 
f01039b2:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f01039b9:	00 
f01039ba:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f01039c1:	e8 7a c6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01039c6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01039cb:	74 24                	je     f01039f1 <mem_init+0x1e8a>
f01039cd:	c7 44 24 0c 6d 86 10 	movl   $0xf010866d,0xc(%esp)
f01039d4:	f0 
f01039d5:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f01039dc:	f0 
f01039dd:	c7 44 24 04 cb 04 00 	movl   $0x4cb,0x4(%esp)
f01039e4:	00 
f01039e5:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103a1a:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0103a21:	f0 
f0103a22:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103a29:	00 
f0103a2a:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f0103a31:	e8 0a c6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103a36:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103a3d:	03 03 03 
f0103a40:	74 24                	je     f0103a66 <mem_init+0x1eff>
f0103a42:	c7 44 24 0c 68 83 10 	movl   $0xf0108368,0xc(%esp)
f0103a49:	f0 
f0103a4a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103a51:	f0 
f0103a52:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f0103a59:	00 
f0103a5a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103a82:	c7 44 24 0c 5c 86 10 	movl   $0xf010865c,0xc(%esp)
f0103a89:	f0 
f0103a8a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103a91:	f0 
f0103a92:	c7 44 24 04 cf 04 00 	movl   $0x4cf,0x4(%esp)
f0103a99:	00 
f0103a9a:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
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
f0103ac5:	c7 44 24 0c 28 7d 10 	movl   $0xf0107d28,0xc(%esp)
f0103acc:	f0 
f0103acd:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103ad4:	f0 
f0103ad5:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
f0103adc:	00 
f0103add:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0103ae4:	e8 57 c5 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103ae9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103aef:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103af4:	74 24                	je     f0103b1a <mem_init+0x1fb3>
f0103af6:	c7 44 24 0c 13 86 10 	movl   $0xf0108613,0xc(%esp)
f0103afd:	f0 
f0103afe:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0103b05:	f0 
f0103b06:	c7 44 24 04 d4 04 00 	movl   $0x4d4,0x4(%esp)
f0103b0d:	00 
f0103b0e:	c7 04 24 f5 83 10 f0 	movl   $0xf01083f5,(%esp)
f0103b15:	e8 26 c5 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103b1a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103b20:	89 34 24             	mov    %esi,(%esp)
f0103b23:	e8 b8 dc ff ff       	call   f01017e0 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103b28:	c7 04 24 94 83 10 f0 	movl   $0xf0108394,(%esp)
f0103b2f:	e8 ba 0a 00 00       	call   f01045ee <cprintf>
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
f0103c4a:	c7 04 24 c0 83 10 f0 	movl   $0xf01083c0,(%esp)
f0103c51:	e8 98 09 00 00       	call   f01045ee <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103c56:	89 1c 24             	mov    %ebx,(%esp)
f0103c59:	e8 bb 06 00 00       	call   f0104319 <env_destroy>
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
f0103c9c:	c7 44 24 08 08 87 10 	movl   $0xf0108708,0x8(%esp)
f0103ca3:	f0 
f0103ca4:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f0103cab:	00 
f0103cac:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
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
f0103d06:	e8 45 2e 00 00       	call   f0106b50 <cpunum>
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
f0103d25:	c1 e3 07             	shl    $0x7,%ebx
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
f0103d4a:	e8 01 2e 00 00       	call   f0106b50 <cpunum>
f0103d4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d52:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0103d58:	74 23                	je     f0103d7d <envid2env+0x94>
f0103d5a:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103d5d:	e8 ee 2d 00 00       	call   f0106b50 <cpunum>
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
f0103dd2:	8d 82 80 00 00 00    	lea    0x80(%edx),%eax
f0103dd8:	8d 9a 00 00 02 00    	lea    0x20000(%edx),%ebx
f0103dde:	eb 02                	jmp    f0103de2 <env_init+0x27>

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
		_env->env_link = &envs[i];
		_env = _env->env_link;
f0103de0:	89 ca                	mov    %ecx,%edx
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
f0103de2:	89 c1                	mov    %eax,%ecx
f0103de4:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		_env->env_link = &envs[i];
f0103deb:	89 42 44             	mov    %eax,0x44(%edx)
f0103dee:	83 e8 80             	sub    $0xffffff80,%eax
	envs[0].env_id = 0;
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
f0103df1:	39 d8                	cmp    %ebx,%eax
f0103df3:	75 eb                	jne    f0103de0 <env_init+0x25>
		_env->env_link = &envs[i];
		_env = _env->env_link;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103df5:	e8 97 ff ff ff       	call   f0103d91 <env_init_percpu>
}
f0103dfa:	5b                   	pop    %ebx
f0103dfb:	5d                   	pop    %ebp
f0103dfc:	c3                   	ret    

f0103dfd <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103dfd:	55                   	push   %ebp
f0103dfe:	89 e5                	mov    %esp,%ebp
f0103e00:	53                   	push   %ebx
f0103e01:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103e04:	8b 1d 4c c2 22 f0    	mov    0xf022c24c,%ebx
f0103e0a:	85 db                	test   %ebx,%ebx
f0103e0c:	0f 84 88 01 00 00    	je     f0103f9a <env_alloc+0x19d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103e12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103e19:	e8 44 d9 ff ff       	call   f0101762 <page_alloc>
f0103e1e:	85 c0                	test   %eax,%eax
f0103e20:	0f 84 7b 01 00 00    	je     f0103fa1 <env_alloc+0x1a4>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	/*************************** LAB 3: Your code here.***************************/
	p->pp_ref ++;
f0103e26:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103e2b:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103e31:	c1 f8 03             	sar    $0x3,%eax
f0103e34:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e37:	89 c2                	mov    %eax,%edx
f0103e39:	c1 ea 0c             	shr    $0xc,%edx
f0103e3c:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103e42:	72 20                	jb     f0103e64 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e48:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0103e4f:	f0 
f0103e50:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103e57:	00 
f0103e58:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f0103e5f:	e8 dc c1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103e64:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0103e69:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103e6c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103e73:	00 
f0103e74:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f0103e7a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e7e:	89 04 24             	mov    %eax,(%esp)
f0103e81:	e8 0f 27 00 00       	call   f0106595 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103e86:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e89:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e8e:	77 20                	ja     f0103eb0 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e94:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0103e9b:	f0 
f0103e9c:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0103ea3:	00 
f0103ea4:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f0103eab:	e8 90 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103eb0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103eb6:	83 ca 05             	or     $0x5,%edx
f0103eb9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103ebf:	8b 43 48             	mov    0x48(%ebx),%eax
f0103ec2:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103ec7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103ecc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103ed1:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103ed4:	89 da                	mov    %ebx,%edx
f0103ed6:	2b 15 48 c2 22 f0    	sub    0xf022c248,%edx
f0103edc:	c1 fa 07             	sar    $0x7,%edx
f0103edf:	09 d0                	or     %edx,%eax
f0103ee1:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ee7:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103eea:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103ef1:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103ef8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103eff:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103f06:	00 
f0103f07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103f0e:	00 
f0103f0f:	89 1c 24             	mov    %ebx,(%esp)
f0103f12:	e8 aa 25 00 00       	call   f01064c1 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103f17:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103f1d:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103f23:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103f29:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103f30:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103f36:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103f3d:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103f44:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103f48:	8b 43 44             	mov    0x44(%ebx),%eax
f0103f4b:	a3 4c c2 22 f0       	mov    %eax,0xf022c24c
	*newenv_store = e;
f0103f50:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f53:	89 18                	mov    %ebx,(%eax)

	

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103f55:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103f58:	e8 f3 2b 00 00       	call   f0106b50 <cpunum>
f0103f5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f60:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f65:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0103f6c:	74 11                	je     f0103f7f <env_alloc+0x182>
f0103f6e:	e8 dd 2b 00 00       	call   f0106b50 <cpunum>
f0103f73:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f76:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103f7c:	8b 50 48             	mov    0x48(%eax),%edx
f0103f7f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103f83:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f87:	c7 04 24 28 87 10 f0 	movl   $0xf0108728,(%esp)
f0103f8e:	e8 5b 06 00 00       	call   f01045ee <cprintf>
	return 0;
f0103f93:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f98:	eb 0c                	jmp    f0103fa6 <env_alloc+0x1a9>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103f9a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103f9f:	eb 05                	jmp    f0103fa6 <env_alloc+0x1a9>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103fa1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103fa6:	83 c4 14             	add    $0x14,%esp
f0103fa9:	5b                   	pop    %ebx
f0103faa:	5d                   	pop    %ebp
f0103fab:	c3                   	ret    

f0103fac <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103fac:	55                   	push   %ebp
f0103fad:	89 e5                	mov    %esp,%ebp
f0103faf:	57                   	push   %edi
f0103fb0:	56                   	push   %esi
f0103fb1:	53                   	push   %ebx
f0103fb2:	83 ec 3c             	sub    $0x3c,%esp
f0103fb5:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int res;
	if ((res = env_alloc(&env, 0)))
f0103fb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fbf:	00 
f0103fc0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103fc3:	89 04 24             	mov    %eax,(%esp)
f0103fc6:	e8 32 fe ff ff       	call   f0103dfd <env_alloc>
f0103fcb:	85 c0                	test   %eax,%eax
f0103fcd:	74 20                	je     f0103fef <env_create+0x43>
		panic("env_create: %e", res);
f0103fcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fd3:	c7 44 24 08 3d 87 10 	movl   $0xf010873d,0x8(%esp)
f0103fda:	f0 
f0103fdb:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
f0103fe2:	00 
f0103fe3:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f0103fea:	e8 51 c0 ff ff       	call   f0100040 <_panic>

	load_icode(env, binary, size);
f0103fef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ff2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
f0103ff5:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103ffb:	74 1c                	je     f0104019 <env_create+0x6d>
		panic("Invalid ELF!");
f0103ffd:	c7 44 24 08 4c 87 10 	movl   $0xf010874c,0x8(%esp)
f0104004:	f0 
f0104005:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f010400c:	00 
f010400d:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f0104014:	e8 27 c0 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0104019:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f010401c:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
f0104020:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104023:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104026:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010402b:	77 20                	ja     f010404d <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010402d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104031:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0104038:	f0 
f0104039:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0104040:	00 
f0104041:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f0104048:	e8 f3 bf ff ff       	call   f0100040 <_panic>
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
		panic("Invalid ELF!");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010404d:	01 fb                	add    %edi,%ebx
	eph = ph + elf->e_phnum;
f010404f:	0f b7 f6             	movzwl %si,%esi
f0104052:	c1 e6 05             	shl    $0x5,%esi
f0104055:	01 de                	add    %ebx,%esi
	return (physaddr_t)kva - KERNBASE;
f0104057:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010405c:	0f 22 d8             	mov    %eax,%cr3

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f010405f:	39 f3                	cmp    %esi,%ebx
f0104061:	73 4f                	jae    f01040b2 <env_create+0x106>
		if (ph->p_type != ELF_PROG_LOAD)
f0104063:	83 3b 01             	cmpl   $0x1,(%ebx)
f0104066:	75 43                	jne    f01040ab <env_create+0xff>
			continue;
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0104068:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010406b:	8b 53 08             	mov    0x8(%ebx),%edx
f010406e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104071:	e8 ee fb ff ff       	call   f0103c64 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f0104076:	8b 43 14             	mov    0x14(%ebx),%eax
f0104079:	89 44 24 08          	mov    %eax,0x8(%esp)
f010407d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104084:	00 
f0104085:	8b 43 08             	mov    0x8(%ebx),%eax
f0104088:	89 04 24             	mov    %eax,(%esp)
f010408b:	e8 31 24 00 00       	call   f01064c1 <memset>
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0104090:	8b 43 10             	mov    0x10(%ebx),%eax
f0104093:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104097:	89 f8                	mov    %edi,%eax
f0104099:	03 43 04             	add    0x4(%ebx),%eax
f010409c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040a0:	8b 43 08             	mov    0x8(%ebx),%eax
f01040a3:	89 04 24             	mov    %eax,(%esp)
f01040a6:	e8 71 24 00 00       	call   f010651c <memmove>
	eph = ph + elf->e_phnum;

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f01040ab:	83 c3 20             	add    $0x20,%ebx
f01040ae:	39 de                	cmp    %ebx,%esi
f01040b0:	77 b1                	ja     f0104063 <env_create+0xb7>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
		memset((void*)ph->p_va, 0, ph->p_memsz);
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}
	// switch back to kernel page directory
	lcr3(PADDR(kern_pgdir));
f01040b2:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040b7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040bc:	77 20                	ja     f01040de <env_create+0x132>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040c2:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f01040c9:	f0 
f01040ca:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f01040d1:	00 
f01040d2:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f01040d9:	e8 62 bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01040de:	05 00 00 00 10       	add    $0x10000000,%eax
f01040e3:	0f 22 d8             	mov    %eax,%cr3

	(e->env_tf).tf_eip = (uintptr_t)(elf->e_entry);
f01040e6:	8b 47 18             	mov    0x18(%edi),%eax
f01040e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01040ec:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f01040ef:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01040f4:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01040f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040fc:	e8 63 fb ff ff       	call   f0103c64 <region_alloc>
	if ((res = env_alloc(&env, 0)))
		panic("env_create: %e", res);

	load_icode(env, binary, size);

	env->env_type = type;
f0104101:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104104:	8b 55 10             	mov    0x10(%ebp),%edx
f0104107:	89 50 50             	mov    %edx,0x50(%eax)
}
f010410a:	83 c4 3c             	add    $0x3c,%esp
f010410d:	5b                   	pop    %ebx
f010410e:	5e                   	pop    %esi
f010410f:	5f                   	pop    %edi
f0104110:	5d                   	pop    %ebp
f0104111:	c3                   	ret    

f0104112 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0104112:	55                   	push   %ebp
f0104113:	89 e5                	mov    %esp,%ebp
f0104115:	57                   	push   %edi
f0104116:	56                   	push   %esi
f0104117:	53                   	push   %ebx
f0104118:	83 ec 2c             	sub    $0x2c,%esp
f010411b:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010411e:	e8 2d 2a 00 00       	call   f0106b50 <cpunum>
f0104123:	6b c0 74             	imul   $0x74,%eax,%eax
f0104126:	39 b8 28 d0 22 f0    	cmp    %edi,-0xfdd2fd8(%eax)
f010412c:	75 34                	jne    f0104162 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f010412e:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104133:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104138:	77 20                	ja     f010415a <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010413a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010413e:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0104145:	f0 
f0104146:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
f010414d:	00 
f010414e:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f0104155:	e8 e6 be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010415a:	05 00 00 00 10       	add    $0x10000000,%eax
f010415f:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0104162:	8b 5f 48             	mov    0x48(%edi),%ebx
f0104165:	e8 e6 29 00 00       	call   f0106b50 <cpunum>
f010416a:	6b d0 74             	imul   $0x74,%eax,%edx
f010416d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104172:	83 ba 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%edx)
f0104179:	74 11                	je     f010418c <env_free+0x7a>
f010417b:	e8 d0 29 00 00       	call   f0106b50 <cpunum>
f0104180:	6b c0 74             	imul   $0x74,%eax,%eax
f0104183:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104189:	8b 40 48             	mov    0x48(%eax),%eax
f010418c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104190:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104194:	c7 04 24 59 87 10 f0 	movl   $0xf0108759,(%esp)
f010419b:	e8 4e 04 00 00       	call   f01045ee <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01041a0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
//cprintf("*****e->env_pgdir[pdeno]: up to now!\n");
		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01041a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041aa:	c1 e0 02             	shl    $0x2,%eax
f01041ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041b0:	8b 47 60             	mov    0x60(%edi),%eax
f01041b3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041b6:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01041b9:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01041bf:	0f 84 b8 00 00 00    	je     f010427d <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01041c5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01041cb:	89 f0                	mov    %esi,%eax
f01041cd:	c1 e8 0c             	shr    $0xc,%eax
f01041d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01041d3:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01041d9:	72 20                	jb     f01041fb <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01041db:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01041df:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01041e6:	f0 
f01041e7:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
f01041ee:	00 
f01041ef:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f01041f6:	e8 45 be ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01041fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041fe:	c1 e2 16             	shl    $0x16,%edx
f0104201:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104204:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0104209:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0104210:	01 
f0104211:	74 17                	je     f010422a <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104213:	89 d8                	mov    %ebx,%eax
f0104215:	c1 e0 0c             	shl    $0xc,%eax
f0104218:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010421b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010421f:	8b 47 60             	mov    0x60(%edi),%eax
f0104222:	89 04 24             	mov    %eax,(%esp)
f0104225:	e8 cc d7 ff ff       	call   f01019f6 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010422a:	83 c3 01             	add    $0x1,%ebx
f010422d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104233:	75 d4                	jne    f0104209 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}
//cprintf("*****e table: up to now!\n");
		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104235:	8b 47 60             	mov    0x60(%edi),%eax
f0104238:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010423b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104242:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104245:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f010424b:	72 1c                	jb     f0104269 <env_free+0x157>
		panic("pa2page called with invalid pa");
f010424d:	c7 44 24 08 f4 7b 10 	movl   $0xf0107bf4,0x8(%esp)
f0104254:	f0 
f0104255:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010425c:	00 
f010425d:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f0104264:	e8 d7 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104269:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010426c:	c1 e0 03             	shl    $0x3,%eax
f010426f:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
		page_decref(pa2page(pa));
f0104275:	89 04 24             	mov    %eax,(%esp)
f0104278:	e8 9b d5 ff ff       	call   f0101818 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010427d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0104281:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104288:	0f 85 19 ff ff ff    	jne    f01041a7 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}
//cprintf("*****e->env_pgdir: up to now!\n");
	// free the page directory
	pa = PADDR(e->env_pgdir);
f010428e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104291:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104296:	77 20                	ja     f01042b8 <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104298:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010429c:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f01042a3:	f0 
f01042a4:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f01042ab:	00 
f01042ac:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f01042b3:	e8 88 bd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01042b8:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01042bf:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01042c4:	c1 e8 0c             	shr    $0xc,%eax
f01042c7:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01042cd:	72 1c                	jb     f01042eb <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f01042cf:	c7 44 24 08 f4 7b 10 	movl   $0xf0107bf4,0x8(%esp)
f01042d6:	f0 
f01042d7:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01042de:	00 
f01042df:	c7 04 24 11 84 10 f0 	movl   $0xf0108411,(%esp)
f01042e6:	e8 55 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01042eb:	c1 e0 03             	shl    $0x3,%eax
f01042ee:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
//cprintf("*****Get into page_decref!\n");
	page_decref(pa2page(pa));
f01042f4:	89 04 24             	mov    %eax,(%esp)
f01042f7:	e8 1c d5 ff ff       	call   f0101818 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01042fc:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104303:	a1 4c c2 22 f0       	mov    0xf022c24c,%eax
f0104308:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010430b:	89 3d 4c c2 22 f0    	mov    %edi,0xf022c24c
}
f0104311:	83 c4 2c             	add    $0x2c,%esp
f0104314:	5b                   	pop    %ebx
f0104315:	5e                   	pop    %esi
f0104316:	5f                   	pop    %edi
f0104317:	5d                   	pop    %ebp
f0104318:	c3                   	ret    

f0104319 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104319:	55                   	push   %ebp
f010431a:	89 e5                	mov    %esp,%ebp
f010431c:	53                   	push   %ebx
f010431d:	83 ec 14             	sub    $0x14,%esp
f0104320:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104323:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104327:	75 19                	jne    f0104342 <env_destroy+0x29>
f0104329:	e8 22 28 00 00       	call   f0106b50 <cpunum>
f010432e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104331:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0104337:	74 09                	je     f0104342 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0104339:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0104340:	eb 2f                	jmp    f0104371 <env_destroy+0x58>
	}
	env_free(e);
f0104342:	89 1c 24             	mov    %ebx,(%esp)
f0104345:	e8 c8 fd ff ff       	call   f0104112 <env_free>

	if (curenv == e) {
f010434a:	e8 01 28 00 00       	call   f0106b50 <cpunum>
f010434f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104352:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0104358:	75 17                	jne    f0104371 <env_destroy+0x58>
		curenv = NULL;
f010435a:	e8 f1 27 00 00       	call   f0106b50 <cpunum>
f010435f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104362:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0104369:	00 00 00 
//cprintf("****destroy\n");
		sched_yield();
f010436c:	e8 a3 0c 00 00       	call   f0105014 <sched_yield>
	}
}
f0104371:	83 c4 14             	add    $0x14,%esp
f0104374:	5b                   	pop    %ebx
f0104375:	5d                   	pop    %ebp
f0104376:	c3                   	ret    

f0104377 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104377:	55                   	push   %ebp
f0104378:	89 e5                	mov    %esp,%ebp
f010437a:	53                   	push   %ebx
f010437b:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010437e:	e8 cd 27 00 00       	call   f0106b50 <cpunum>
f0104383:	6b c0 74             	imul   $0x74,%eax,%eax
f0104386:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
f010438c:	e8 bf 27 00 00       	call   f0106b50 <cpunum>
f0104391:	89 43 5c             	mov    %eax,0x5c(%ebx)
//cprintf("**Start transfering\n");

	__asm __volatile("movl %0,%%esp\n"
f0104394:	8b 65 08             	mov    0x8(%ebp),%esp
f0104397:	61                   	popa   
f0104398:	07                   	pop    %es
f0104399:	1f                   	pop    %ds
f010439a:	83 c4 08             	add    $0x8,%esp
f010439d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010439e:	c7 44 24 08 6f 87 10 	movl   $0xf010876f,0x8(%esp)
f01043a5:	f0 
f01043a6:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
f01043ad:	00 
f01043ae:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f01043b5:	e8 86 bc ff ff       	call   f0100040 <_panic>

f01043ba <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01043ba:	55                   	push   %ebp
f01043bb:	89 e5                	mov    %esp,%ebp
f01043bd:	53                   	push   %ebx
f01043be:	83 ec 14             	sub    $0x14,%esp
f01043c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f01043c4:	e8 87 27 00 00       	call   f0106b50 <cpunum>
f01043c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01043cc:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f01043d2:	0f 84 85 00 00 00    	je     f010445d <env_run+0xa3>
		if (curenv && curenv->env_status == ENV_RUNNING)
f01043d8:	e8 73 27 00 00       	call   f0106b50 <cpunum>
f01043dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e0:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01043e7:	74 29                	je     f0104412 <env_run+0x58>
f01043e9:	e8 62 27 00 00       	call   f0106b50 <cpunum>
f01043ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f1:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01043f7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01043fb:	75 15                	jne    f0104412 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f01043fd:	e8 4e 27 00 00       	call   f0106b50 <cpunum>
f0104402:	6b c0 74             	imul   $0x74,%eax,%eax
f0104405:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010440b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0104412:	e8 39 27 00 00       	call   f0106b50 <cpunum>
f0104417:	6b c0 74             	imul   $0x74,%eax,%eax
f010441a:	89 98 28 d0 22 f0    	mov    %ebx,-0xfdd2fd8(%eax)
		e->env_status = ENV_RUNNING;
f0104420:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0104427:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f010442b:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010442e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104433:	77 20                	ja     f0104455 <env_run+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104435:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104439:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0104440:	f0 
f0104441:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
f0104448:	00 
f0104449:	c7 04 24 1d 87 10 f0 	movl   $0xf010871d,(%esp)
f0104450:	e8 eb bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104455:	05 00 00 00 10       	add    $0x10000000,%eax
f010445a:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010445d:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104464:	e8 5a 2a 00 00       	call   f0106ec3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104469:	f3 90                	pause  
	}

	unlock_kernel();

	env_pop_tf(&(curenv->env_tf));
f010446b:	e8 e0 26 00 00       	call   f0106b50 <cpunum>
f0104470:	6b c0 74             	imul   $0x74,%eax,%eax
f0104473:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104479:	89 04 24             	mov    %eax,(%esp)
f010447c:	e8 f6 fe ff ff       	call   f0104377 <env_pop_tf>
f0104481:	00 00                	add    %al,(%eax)
	...

f0104484 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104484:	55                   	push   %ebp
f0104485:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104487:	ba 70 00 00 00       	mov    $0x70,%edx
f010448c:	8b 45 08             	mov    0x8(%ebp),%eax
f010448f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104490:	b2 71                	mov    $0x71,%dl
f0104492:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104493:	0f b6 c0             	movzbl %al,%eax
}
f0104496:	5d                   	pop    %ebp
f0104497:	c3                   	ret    

f0104498 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104498:	55                   	push   %ebp
f0104499:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010449b:	ba 70 00 00 00       	mov    $0x70,%edx
f01044a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01044a3:	ee                   	out    %al,(%dx)
f01044a4:	b2 71                	mov    $0x71,%dl
f01044a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044a9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01044aa:	5d                   	pop    %ebp
f01044ab:	c3                   	ret    

f01044ac <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01044ac:	55                   	push   %ebp
f01044ad:	89 e5                	mov    %esp,%ebp
f01044af:	56                   	push   %esi
f01044b0:	53                   	push   %ebx
f01044b1:	83 ec 10             	sub    $0x10,%esp
f01044b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01044b7:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01044b9:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f01044bf:	80 3d 50 c2 22 f0 00 	cmpb   $0x0,0xf022c250
f01044c6:	74 4e                	je     f0104516 <irq_setmask_8259A+0x6a>
f01044c8:	ba 21 00 00 00       	mov    $0x21,%edx
f01044cd:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01044ce:	89 f0                	mov    %esi,%eax
f01044d0:	66 c1 e8 08          	shr    $0x8,%ax
f01044d4:	b2 a1                	mov    $0xa1,%dl
f01044d6:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01044d7:	c7 04 24 7b 87 10 f0 	movl   $0xf010877b,(%esp)
f01044de:	e8 0b 01 00 00       	call   f01045ee <cprintf>
	for (i = 0; i < 16; i++)
f01044e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01044e8:	0f b7 f6             	movzwl %si,%esi
f01044eb:	f7 d6                	not    %esi
f01044ed:	0f a3 de             	bt     %ebx,%esi
f01044f0:	73 10                	jae    f0104502 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f01044f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044f6:	c7 04 24 37 8c 10 f0 	movl   $0xf0108c37,(%esp)
f01044fd:	e8 ec 00 00 00       	call   f01045ee <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104502:	83 c3 01             	add    $0x1,%ebx
f0104505:	83 fb 10             	cmp    $0x10,%ebx
f0104508:	75 e3                	jne    f01044ed <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010450a:	c7 04 24 d6 86 10 f0 	movl   $0xf01086d6,(%esp)
f0104511:	e8 d8 00 00 00       	call   f01045ee <cprintf>
}
f0104516:	83 c4 10             	add    $0x10,%esp
f0104519:	5b                   	pop    %ebx
f010451a:	5e                   	pop    %esi
f010451b:	5d                   	pop    %ebp
f010451c:	c3                   	ret    

f010451d <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010451d:	55                   	push   %ebp
f010451e:	89 e5                	mov    %esp,%ebp
f0104520:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104523:	c6 05 50 c2 22 f0 01 	movb   $0x1,0xf022c250
f010452a:	ba 21 00 00 00       	mov    $0x21,%edx
f010452f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104534:	ee                   	out    %al,(%dx)
f0104535:	b2 a1                	mov    $0xa1,%dl
f0104537:	ee                   	out    %al,(%dx)
f0104538:	b2 20                	mov    $0x20,%dl
f010453a:	b8 11 00 00 00       	mov    $0x11,%eax
f010453f:	ee                   	out    %al,(%dx)
f0104540:	b2 21                	mov    $0x21,%dl
f0104542:	b8 20 00 00 00       	mov    $0x20,%eax
f0104547:	ee                   	out    %al,(%dx)
f0104548:	b8 04 00 00 00       	mov    $0x4,%eax
f010454d:	ee                   	out    %al,(%dx)
f010454e:	b8 03 00 00 00       	mov    $0x3,%eax
f0104553:	ee                   	out    %al,(%dx)
f0104554:	b2 a0                	mov    $0xa0,%dl
f0104556:	b8 11 00 00 00       	mov    $0x11,%eax
f010455b:	ee                   	out    %al,(%dx)
f010455c:	b2 a1                	mov    $0xa1,%dl
f010455e:	b8 28 00 00 00       	mov    $0x28,%eax
f0104563:	ee                   	out    %al,(%dx)
f0104564:	b8 02 00 00 00       	mov    $0x2,%eax
f0104569:	ee                   	out    %al,(%dx)
f010456a:	b8 01 00 00 00       	mov    $0x1,%eax
f010456f:	ee                   	out    %al,(%dx)
f0104570:	b2 20                	mov    $0x20,%dl
f0104572:	b8 68 00 00 00       	mov    $0x68,%eax
f0104577:	ee                   	out    %al,(%dx)
f0104578:	b8 0a 00 00 00       	mov    $0xa,%eax
f010457d:	ee                   	out    %al,(%dx)
f010457e:	b2 a0                	mov    $0xa0,%dl
f0104580:	b8 68 00 00 00       	mov    $0x68,%eax
f0104585:	ee                   	out    %al,(%dx)
f0104586:	b8 0a 00 00 00       	mov    $0xa,%eax
f010458b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010458c:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0104593:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104597:	74 0b                	je     f01045a4 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f0104599:	0f b7 c0             	movzwl %ax,%eax
f010459c:	89 04 24             	mov    %eax,(%esp)
f010459f:	e8 08 ff ff ff       	call   f01044ac <irq_setmask_8259A>
}
f01045a4:	c9                   	leave  
f01045a5:	c3                   	ret    
	...

f01045a8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01045a8:	55                   	push   %ebp
f01045a9:	89 e5                	mov    %esp,%ebp
f01045ab:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01045ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01045b1:	89 04 24             	mov    %eax,(%esp)
f01045b4:	e8 e0 c1 ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f01045b9:	c9                   	leave  
f01045ba:	c3                   	ret    

f01045bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01045bb:	55                   	push   %ebp
f01045bc:	89 e5                	mov    %esp,%ebp
f01045be:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01045c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01045c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01045d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045dd:	c7 04 24 a8 45 10 f0 	movl   $0xf01045a8,(%esp)
f01045e4:	e8 99 16 00 00       	call   f0105c82 <vprintfmt>
	return cnt;
}
f01045e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045ec:	c9                   	leave  
f01045ed:	c3                   	ret    

f01045ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01045ee:	55                   	push   %ebp
f01045ef:	89 e5                	mov    %esp,%ebp
f01045f1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01045f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01045f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01045fe:	89 04 24             	mov    %eax,(%esp)
f0104601:	e8 b5 ff ff ff       	call   f01045bb <vcprintf>
	va_end(ap);

	return cnt;
}
f0104606:	c9                   	leave  
f0104607:	c3                   	ret    
	...

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
f0104619:	e8 32 25 00 00       	call   f0106b50 <cpunum>
f010461e:	89 c3                	mov    %eax,%ebx
f0104620:	e8 2b 25 00 00       	call   f0106b50 <cpunum>
f0104625:	6b db 74             	imul   $0x74,%ebx,%ebx
f0104628:	6b c0 74             	imul   $0x74,%eax,%eax
f010462b:	0f b6 80 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%eax
f0104632:	f7 d8                	neg    %eax
f0104634:	c1 e0 10             	shl    $0x10,%eax
f0104637:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010463c:	89 83 30 d0 22 f0    	mov    %eax,-0xfdd2fd0(%ebx)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104642:	e8 09 25 00 00       	call   f0106b50 <cpunum>
f0104647:	6b c0 74             	imul   $0x74,%eax,%eax
f010464a:	66 c7 80 34 d0 22 f0 	movw   $0x10,-0xfdd2fcc(%eax)
f0104651:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0104653:	e8 f8 24 00 00       	call   f0106b50 <cpunum>
f0104658:	6b c0 74             	imul   $0x74,%eax,%eax
f010465b:	0f b6 98 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%ebx
f0104662:	83 c3 05             	add    $0x5,%ebx
f0104665:	e8 e6 24 00 00       	call   f0106b50 <cpunum>
f010466a:	89 c6                	mov    %eax,%esi
f010466c:	e8 df 24 00 00       	call   f0106b50 <cpunum>
f0104671:	89 c7                	mov    %eax,%edi
f0104673:	e8 d8 24 00 00       	call   f0106b50 <cpunum>
f0104678:	66 c7 04 dd 40 33 12 	movw   $0x68,-0xfedccc0(,%ebx,8)
f010467f:	f0 68 00 
f0104682:	6b f6 74             	imul   $0x74,%esi,%esi
f0104685:	81 c6 2c d0 22 f0    	add    $0xf022d02c,%esi
f010468b:	66 89 34 dd 42 33 12 	mov    %si,-0xfedccbe(,%ebx,8)
f0104692:	f0 
f0104693:	6b d7 74             	imul   $0x74,%edi,%edx
f0104696:	81 c2 2c d0 22 f0    	add    $0xf022d02c,%edx
f010469c:	c1 ea 10             	shr    $0x10,%edx
f010469f:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f01046a6:	c6 04 dd 45 33 12 f0 	movb   $0x99,-0xfedccbb(,%ebx,8)
f01046ad:	99 
f01046ae:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f01046b5:	40 
f01046b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b9:	05 2c d0 22 f0       	add    $0xf022d02c,%eax
f01046be:	c1 e8 18             	shr    $0x18,%eax
f01046c1:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
                    sizeof(struct Taskstate), 0);
    gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id].sd_s = 0;
f01046c8:	e8 83 24 00 00       	call   f0106b50 <cpunum>
f01046cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d0:	0f b6 80 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%eax
f01046d7:	80 24 c5 6d 33 12 f0 	andb   $0xef,-0xfedcc93(,%eax,8)
f01046de:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8*(thiscpu->cpu_id));
f01046df:	e8 6c 24 00 00       	call   f0106b50 <cpunum>
f01046e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e7:	0f b6 80 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%eax
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
f01046f8:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
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
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
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
f0104726:	8b 15 c0 33 12 f0    	mov    0xf01233c0,%edx
f010472c:	66 89 15 78 c2 22 f0 	mov    %dx,0xf022c278
f0104733:	66 c7 05 7a c2 22 f0 	movw   $0x8,0xf022c27a
f010473a:	08 00 
f010473c:	c6 05 7c c2 22 f0 00 	movb   $0x0,0xf022c27c
f0104743:	c6 05 7d c2 22 f0 ee 	movb   $0xee,0xf022c27d
f010474a:	c1 ea 10             	shr    $0x10,%edx
f010474d:	66 89 15 7e c2 22 f0 	mov    %dx,0xf022c27e
f0104754:	eb c5                	jmp    f010471b <trap_init+0x13>
		else if (i!=2 && i!=15) {
f0104756:	83 f8 02             	cmp    $0x2,%eax
f0104759:	74 39                	je     f0104794 <trap_init+0x8c>
f010475b:	83 f8 0f             	cmp    $0xf,%eax
f010475e:	74 34                	je     f0104794 <trap_init+0x8c>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f0104760:	8b 1c 85 b4 33 12 f0 	mov    -0xfedcc4c(,%eax,4),%ebx
f0104767:	66 89 1c c5 60 c2 22 	mov    %bx,-0xfdd3da0(,%eax,8)
f010476e:	f0 
f010476f:	66 c7 04 c5 62 c2 22 	movw   $0x8,-0xfdd3d9e(,%eax,8)
f0104776:	f0 08 00 
f0104779:	c6 04 c5 64 c2 22 f0 	movb   $0x0,-0xfdd3d9c(,%eax,8)
f0104780:	00 
f0104781:	c6 04 c5 65 c2 22 f0 	movb   $0x8e,-0xfdd3d9b(,%eax,8)
f0104788:	8e 
f0104789:	c1 eb 10             	shr    $0x10,%ebx
f010478c:	66 89 1c c5 66 c2 22 	mov    %bx,-0xfdd3d9a(,%eax,8)
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
f0104799:	a1 74 34 12 f0       	mov    0xf0123474,%eax
f010479e:	66 a3 e0 c3 22 f0    	mov    %ax,0xf022c3e0
f01047a4:	66 c7 05 e2 c3 22 f0 	movw   $0x8,0xf022c3e2
f01047ab:	08 00 
f01047ad:	c6 05 e4 c3 22 f0 00 	movb   $0x0,0xf022c3e4
f01047b4:	c6 05 e5 c3 22 f0 ee 	movb   $0xee,0xf022c3e5
f01047bb:	c1 e8 10             	shr    $0x10,%eax
f01047be:	66 a3 e6 c3 22 f0    	mov    %ax,0xf022c3e6
f01047c4:	b8 20 00 00 00       	mov    $0x20,%eax

	for (i = 0; i < 16; ++i)
    	SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);
f01047c9:	8b 14 85 b4 33 12 f0 	mov    -0xfedcc4c(,%eax,4),%edx
f01047d0:	66 89 14 c5 60 c2 22 	mov    %dx,-0xfdd3da0(,%eax,8)
f01047d7:	f0 
f01047d8:	66 c7 04 c5 62 c2 22 	movw   $0x8,-0xfdd3d9e(,%eax,8)
f01047df:	f0 08 00 
f01047e2:	c6 04 c5 64 c2 22 f0 	movb   $0x0,-0xfdd3d9c(,%eax,8)
f01047e9:	00 
f01047ea:	c6 04 c5 65 c2 22 f0 	movb   $0x8e,-0xfdd3d9b(,%eax,8)
f01047f1:	8e 
f01047f2:	c1 ea 10             	shr    $0x10,%edx
f01047f5:	66 89 14 c5 66 c2 22 	mov    %dx,-0xfdd3d9a(,%eax,8)
f01047fc:	f0 
f01047fd:	83 c0 01             	add    $0x1,%eax
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);

	for (i = 0; i < 16; ++i)
f0104800:	83 f8 30             	cmp    $0x30,%eax
f0104803:	75 c4                	jne    f01047c9 <trap_init+0xc1>
    	SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);

	// Per-CPU setup 
	trap_init_percpu();
f0104805:	e8 06 fe ff ff       	call   f0104610 <trap_init_percpu>
}
f010480a:	83 c4 04             	add    $0x4,%esp
f010480d:	5b                   	pop    %ebx
f010480e:	5d                   	pop    %ebp
f010480f:	c3                   	ret    

f0104810 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104810:	55                   	push   %ebp
f0104811:	89 e5                	mov    %esp,%ebp
f0104813:	53                   	push   %ebx
f0104814:	83 ec 14             	sub    $0x14,%esp
f0104817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010481a:	8b 03                	mov    (%ebx),%eax
f010481c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104820:	c7 04 24 8f 87 10 f0 	movl   $0xf010878f,(%esp)
f0104827:	e8 c2 fd ff ff       	call   f01045ee <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010482c:	8b 43 04             	mov    0x4(%ebx),%eax
f010482f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104833:	c7 04 24 9e 87 10 f0 	movl   $0xf010879e,(%esp)
f010483a:	e8 af fd ff ff       	call   f01045ee <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010483f:	8b 43 08             	mov    0x8(%ebx),%eax
f0104842:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104846:	c7 04 24 ad 87 10 f0 	movl   $0xf01087ad,(%esp)
f010484d:	e8 9c fd ff ff       	call   f01045ee <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104852:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104855:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104859:	c7 04 24 bc 87 10 f0 	movl   $0xf01087bc,(%esp)
f0104860:	e8 89 fd ff ff       	call   f01045ee <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104865:	8b 43 10             	mov    0x10(%ebx),%eax
f0104868:	89 44 24 04          	mov    %eax,0x4(%esp)
f010486c:	c7 04 24 cb 87 10 f0 	movl   $0xf01087cb,(%esp)
f0104873:	e8 76 fd ff ff       	call   f01045ee <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104878:	8b 43 14             	mov    0x14(%ebx),%eax
f010487b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010487f:	c7 04 24 da 87 10 f0 	movl   $0xf01087da,(%esp)
f0104886:	e8 63 fd ff ff       	call   f01045ee <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010488b:	8b 43 18             	mov    0x18(%ebx),%eax
f010488e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104892:	c7 04 24 e9 87 10 f0 	movl   $0xf01087e9,(%esp)
f0104899:	e8 50 fd ff ff       	call   f01045ee <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010489e:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01048a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a5:	c7 04 24 f8 87 10 f0 	movl   $0xf01087f8,(%esp)
f01048ac:	e8 3d fd ff ff       	call   f01045ee <cprintf>
}
f01048b1:	83 c4 14             	add    $0x14,%esp
f01048b4:	5b                   	pop    %ebx
f01048b5:	5d                   	pop    %ebp
f01048b6:	c3                   	ret    

f01048b7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01048b7:	55                   	push   %ebp
f01048b8:	89 e5                	mov    %esp,%ebp
f01048ba:	56                   	push   %esi
f01048bb:	53                   	push   %ebx
f01048bc:	83 ec 10             	sub    $0x10,%esp
f01048bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01048c2:	e8 89 22 00 00       	call   f0106b50 <cpunum>
f01048c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048cf:	c7 04 24 5c 88 10 f0 	movl   $0xf010885c,(%esp)
f01048d6:	e8 13 fd ff ff       	call   f01045ee <cprintf>
	print_regs(&tf->tf_regs);
f01048db:	89 1c 24             	mov    %ebx,(%esp)
f01048de:	e8 2d ff ff ff       	call   f0104810 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01048e3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01048e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048eb:	c7 04 24 7a 88 10 f0 	movl   $0xf010887a,(%esp)
f01048f2:	e8 f7 fc ff ff       	call   f01045ee <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01048f7:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01048fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048ff:	c7 04 24 8d 88 10 f0 	movl   $0xf010888d,(%esp)
f0104906:	e8 e3 fc ff ff       	call   f01045ee <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010490b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010490e:	83 f8 13             	cmp    $0x13,%eax
f0104911:	77 09                	ja     f010491c <print_trapframe+0x65>
		return excnames[trapno];
f0104913:	8b 14 85 00 8b 10 f0 	mov    -0xfef7500(,%eax,4),%edx
f010491a:	eb 1d                	jmp    f0104939 <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f010491c:	ba 07 88 10 f0       	mov    $0xf0108807,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0104921:	83 f8 30             	cmp    $0x30,%eax
f0104924:	74 13                	je     f0104939 <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104926:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104929:	83 fa 0f             	cmp    $0xf,%edx
f010492c:	ba 13 88 10 f0       	mov    $0xf0108813,%edx
f0104931:	b9 26 88 10 f0       	mov    $0xf0108826,%ecx
f0104936:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104939:	89 54 24 08          	mov    %edx,0x8(%esp)
f010493d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104941:	c7 04 24 a0 88 10 f0 	movl   $0xf01088a0,(%esp)
f0104948:	e8 a1 fc ff ff       	call   f01045ee <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010494d:	3b 1d 60 ca 22 f0    	cmp    0xf022ca60,%ebx
f0104953:	75 19                	jne    f010496e <print_trapframe+0xb7>
f0104955:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104959:	75 13                	jne    f010496e <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010495b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010495e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104962:	c7 04 24 b2 88 10 f0 	movl   $0xf01088b2,(%esp)
f0104969:	e8 80 fc ff ff       	call   f01045ee <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010496e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104971:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104975:	c7 04 24 c1 88 10 f0 	movl   $0xf01088c1,(%esp)
f010497c:	e8 6d fc ff ff       	call   f01045ee <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104981:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104985:	75 51                	jne    f01049d8 <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104987:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010498a:	89 c2                	mov    %eax,%edx
f010498c:	83 e2 01             	and    $0x1,%edx
f010498f:	ba 35 88 10 f0       	mov    $0xf0108835,%edx
f0104994:	b9 40 88 10 f0       	mov    $0xf0108840,%ecx
f0104999:	0f 45 ca             	cmovne %edx,%ecx
f010499c:	89 c2                	mov    %eax,%edx
f010499e:	83 e2 02             	and    $0x2,%edx
f01049a1:	ba 4c 88 10 f0       	mov    $0xf010884c,%edx
f01049a6:	be 52 88 10 f0       	mov    $0xf0108852,%esi
f01049ab:	0f 44 d6             	cmove  %esi,%edx
f01049ae:	83 e0 04             	and    $0x4,%eax
f01049b1:	b8 57 88 10 f0       	mov    $0xf0108857,%eax
f01049b6:	be 8a 89 10 f0       	mov    $0xf010898a,%esi
f01049bb:	0f 44 c6             	cmove  %esi,%eax
f01049be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01049c2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01049c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049ca:	c7 04 24 cf 88 10 f0 	movl   $0xf01088cf,(%esp)
f01049d1:	e8 18 fc ff ff       	call   f01045ee <cprintf>
f01049d6:	eb 0c                	jmp    f01049e4 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01049d8:	c7 04 24 d6 86 10 f0 	movl   $0xf01086d6,(%esp)
f01049df:	e8 0a fc ff ff       	call   f01045ee <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01049e4:	8b 43 30             	mov    0x30(%ebx),%eax
f01049e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049eb:	c7 04 24 de 88 10 f0 	movl   $0xf01088de,(%esp)
f01049f2:	e8 f7 fb ff ff       	call   f01045ee <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01049f7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01049fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049ff:	c7 04 24 ed 88 10 f0 	movl   $0xf01088ed,(%esp)
f0104a06:	e8 e3 fb ff ff       	call   f01045ee <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104a0b:	8b 43 38             	mov    0x38(%ebx),%eax
f0104a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a12:	c7 04 24 00 89 10 f0 	movl   $0xf0108900,(%esp)
f0104a19:	e8 d0 fb ff ff       	call   f01045ee <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104a1e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a22:	74 27                	je     f0104a4b <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104a24:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a2b:	c7 04 24 0f 89 10 f0 	movl   $0xf010890f,(%esp)
f0104a32:	e8 b7 fb ff ff       	call   f01045ee <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104a37:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a3f:	c7 04 24 1e 89 10 f0 	movl   $0xf010891e,(%esp)
f0104a46:	e8 a3 fb ff ff       	call   f01045ee <cprintf>
	}
}
f0104a4b:	83 c4 10             	add    $0x10,%esp
f0104a4e:	5b                   	pop    %ebx
f0104a4f:	5e                   	pop    %esi
f0104a50:	5d                   	pop    %ebp
f0104a51:	c3                   	ret    

f0104a52 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104a52:	55                   	push   %ebp
f0104a53:	89 e5                	mov    %esp,%ebp
f0104a55:	83 ec 38             	sub    $0x38,%esp
f0104a58:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104a5b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104a5e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a64:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0){
f0104a67:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a6b:	75 28                	jne    f0104a95 <page_fault_handler+0x43>
		print_trapframe(tf);
f0104a6d:	89 1c 24             	mov    %ebx,(%esp)
f0104a70:	e8 42 fe ff ff       	call   f01048b7 <print_trapframe>
		panic("kernel page fault va: %08x", fault_va);
f0104a75:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104a79:	c7 44 24 08 31 89 10 	movl   $0xf0108931,0x8(%esp)
f0104a80:	f0 
f0104a81:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f0104a88:	00 
f0104a89:	c7 04 24 4c 89 10 f0 	movl   $0xf010894c,(%esp)
f0104a90:	e8 ab b5 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104a95:	e8 b6 20 00 00       	call   f0106b50 <cpunum>
f0104a9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a9d:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104aa3:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104aa7:	0f 84 06 01 00 00    	je     f0104bb3 <page_fault_handler+0x161>
        struct UTrapframe *utf;
        uintptr_t utf_addr;
        // Locate the exception stack
        if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0104aad:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104ab0:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
            utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104ab6:	83 e8 38             	sub    $0x38,%eax
f0104ab9:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104abf:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104ac4:	0f 46 d0             	cmovbe %eax,%edx
f0104ac7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        else 
            utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
        user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
f0104aca:	e8 81 20 00 00       	call   f0106b50 <cpunum>
f0104acf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104ad6:	00 
f0104ad7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ade:	00 
f0104adf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ae2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104ae6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae9:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104aef:	89 04 24             	mov    %eax,(%esp)
f0104af2:	e8 15 f1 ff ff       	call   f0103c0c <user_mem_assert>
        utf = (struct UTrapframe *) utf_addr;
f0104af7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104afa:	89 45 e0             	mov    %eax,-0x20(%ebp)

        // Form the UTrapframe
        utf->utf_fault_va = fault_va;
f0104afd:	89 30                	mov    %esi,(%eax)
        utf->utf_err = tf->tf_err;
f0104aff:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104b02:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b05:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0104b08:	89 d7                	mov    %edx,%edi
f0104b0a:	83 c7 08             	add    $0x8,%edi
f0104b0d:	89 de                	mov    %ebx,%esi
f0104b0f:	b8 20 00 00 00       	mov    $0x20,%eax
f0104b14:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104b1a:	74 03                	je     f0104b1f <page_fault_handler+0xcd>
f0104b1c:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104b1d:	b0 1f                	mov    $0x1f,%al
f0104b1f:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104b25:	74 05                	je     f0104b2c <page_fault_handler+0xda>
f0104b27:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104b29:	83 e8 02             	sub    $0x2,%eax
f0104b2c:	89 c1                	mov    %eax,%ecx
f0104b2e:	c1 e9 02             	shr    $0x2,%ecx
f0104b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b33:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b38:	a8 02                	test   $0x2,%al
f0104b3a:	74 0b                	je     f0104b47 <page_fault_handler+0xf5>
f0104b3c:	0f b7 16             	movzwl (%esi),%edx
f0104b3f:	66 89 17             	mov    %dx,(%edi)
f0104b42:	ba 02 00 00 00       	mov    $0x2,%edx
f0104b47:	a8 01                	test   $0x1,%al
f0104b49:	74 07                	je     f0104b52 <page_fault_handler+0x100>
f0104b4b:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104b4f:	88 04 17             	mov    %al,(%edi,%edx,1)
        utf->utf_eip = tf->tf_eip;
f0104b52:	8b 43 30             	mov    0x30(%ebx),%eax
f0104b55:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b58:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104b5b:	8b 43 38             	mov    0x38(%ebx),%eax
f0104b5e:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104b61:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b64:	89 42 30             	mov    %eax,0x30(%edx)

        //Modify the env's trapframe to run the handler set before
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104b67:	e8 e4 1f 00 00       	call   f0106b50 <cpunum>
f0104b6c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6f:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
f0104b75:	e8 d6 1f 00 00       	call   f0106b50 <cpunum>
f0104b7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7d:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104b83:	8b 40 64             	mov    0x64(%eax),%eax
f0104b86:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = utf_addr;
f0104b89:	e8 c2 1f 00 00       	call   f0106b50 <cpunum>
f0104b8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b91:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104b97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b9a:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104b9d:	e8 ae 1f 00 00       	call   f0106b50 <cpunum>
f0104ba2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba5:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104bab:	89 04 24             	mov    %eax,(%esp)
f0104bae:	e8 07 f8 ff ff       	call   f01043ba <env_run>
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bb3:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104bb6:	e8 95 1f 00 00       	call   f0106b50 <cpunum>
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        curenv->env_tf.tf_esp = utf_addr;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104bbf:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104bc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc6:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        curenv->env_tf.tf_esp = utf_addr;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bcc:	8b 40 48             	mov    0x48(%eax),%eax
f0104bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bd3:	c7 04 24 d4 8a 10 f0 	movl   $0xf0108ad4,(%esp)
f0104bda:	e8 0f fa ff ff       	call   f01045ee <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104bdf:	89 1c 24             	mov    %ebx,(%esp)
f0104be2:	e8 d0 fc ff ff       	call   f01048b7 <print_trapframe>
	env_destroy(curenv);
f0104be7:	e8 64 1f 00 00       	call   f0106b50 <cpunum>
f0104bec:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bef:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104bf5:	89 04 24             	mov    %eax,(%esp)
f0104bf8:	e8 1c f7 ff ff       	call   f0104319 <env_destroy>
}
f0104bfd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104c00:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104c03:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104c06:	89 ec                	mov    %ebp,%esp
f0104c08:	5d                   	pop    %ebp
f0104c09:	c3                   	ret    

f0104c0a <breakpoint_handler>:

void
breakpoint_handler(struct Trapframe *tf) {
f0104c0a:	55                   	push   %ebp
f0104c0b:	89 e5                	mov    %esp,%ebp
f0104c0d:	83 ec 18             	sub    $0x18,%esp
	//print_trapframe(tf);
	monitor(tf);
f0104c10:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c13:	89 04 24             	mov    %eax,(%esp)
f0104c16:	e8 11 c4 ff ff       	call   f010102c <monitor>
	return;
}
f0104c1b:	c9                   	leave  
f0104c1c:	c3                   	ret    

f0104c1d <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104c1d:	55                   	push   %ebp
f0104c1e:	89 e5                	mov    %esp,%ebp
f0104c20:	57                   	push   %edi
f0104c21:	56                   	push   %esi
f0104c22:	83 ec 20             	sub    $0x20,%esp
f0104c25:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104c28:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104c29:	83 3d 80 ce 22 f0 00 	cmpl   $0x0,0xf022ce80
f0104c30:	74 01                	je     f0104c33 <trap+0x16>
		asm volatile("hlt");
f0104c32:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104c33:	e8 18 1f 00 00       	call   f0106b50 <cpunum>
f0104c38:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c3b:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c41:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c46:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104c4a:	83 f8 02             	cmp    $0x2,%eax
f0104c4d:	75 0c                	jne    f0104c5b <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104c4f:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104c56:	e8 a5 21 00 00       	call   f0106e00 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104c5b:	9c                   	pushf  
f0104c5c:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104c5d:	f6 c4 02             	test   $0x2,%ah
f0104c60:	74 24                	je     f0104c86 <trap+0x69>
f0104c62:	c7 44 24 0c 58 89 10 	movl   $0xf0108958,0xc(%esp)
f0104c69:	f0 
f0104c6a:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0104c71:	f0 
f0104c72:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
f0104c79:	00 
f0104c7a:	c7 04 24 4c 89 10 f0 	movl   $0xf010894c,(%esp)
f0104c81:	e8 ba b3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104c86:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104c8a:	83 e0 03             	and    $0x3,%eax
f0104c8d:	83 f8 03             	cmp    $0x3,%eax
f0104c90:	0f 85 a7 00 00 00    	jne    f0104d3d <trap+0x120>
f0104c96:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104c9d:	e8 5e 21 00 00       	call   f0106e00 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104ca2:	e8 a9 1e 00 00       	call   f0106b50 <cpunum>
f0104ca7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104caa:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0104cb1:	75 24                	jne    f0104cd7 <trap+0xba>
f0104cb3:	c7 44 24 0c 71 89 10 	movl   $0xf0108971,0xc(%esp)
f0104cba:	f0 
f0104cbb:	c7 44 24 08 2b 84 10 	movl   $0xf010842b,0x8(%esp)
f0104cc2:	f0 
f0104cc3:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f0104cca:	00 
f0104ccb:	c7 04 24 4c 89 10 f0 	movl   $0xf010894c,(%esp)
f0104cd2:	e8 69 b3 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104cd7:	e8 74 1e 00 00       	call   f0106b50 <cpunum>
f0104cdc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cdf:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104ce5:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104ce9:	75 2d                	jne    f0104d18 <trap+0xfb>
			env_free(curenv);
f0104ceb:	e8 60 1e 00 00       	call   f0106b50 <cpunum>
f0104cf0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf3:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104cf9:	89 04 24             	mov    %eax,(%esp)
f0104cfc:	e8 11 f4 ff ff       	call   f0104112 <env_free>
			curenv = NULL;
f0104d01:	e8 4a 1e 00 00       	call   f0106b50 <cpunum>
f0104d06:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d09:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0104d10:	00 00 00 
			sched_yield();
f0104d13:	e8 fc 02 00 00       	call   f0105014 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104d18:	e8 33 1e 00 00       	call   f0106b50 <cpunum>
f0104d1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d20:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d26:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d2b:	89 c7                	mov    %eax,%edi
f0104d2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104d2f:	e8 1c 1e 00 00       	call   f0106b50 <cpunum>
f0104d34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d37:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104d3d:	89 35 60 ca 22 f0    	mov    %esi,0xf022ca60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT) {
f0104d43:	8b 46 28             	mov    0x28(%esi),%eax
f0104d46:	83 f8 0e             	cmp    $0xe,%eax
f0104d49:	75 0d                	jne    f0104d58 <trap+0x13b>
//		cprintf("PAGE FAULT!\n");
		page_fault_handler(tf);
f0104d4b:	89 34 24             	mov    %esi,(%esp)
f0104d4e:	e8 ff fc ff ff       	call   f0104a52 <page_fault_handler>
f0104d53:	e9 ae 00 00 00       	jmp    f0104e06 <trap+0x1e9>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104d58:	83 f8 27             	cmp    $0x27,%eax
f0104d5b:	75 0d                	jne    f0104d6a <trap+0x14d>
//		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
f0104d5d:	89 34 24             	mov    %esi,(%esp)
f0104d60:	e8 52 fb ff ff       	call   f01048b7 <print_trapframe>
f0104d65:	e9 9c 00 00 00       	jmp    f0104e06 <trap+0x1e9>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if(tf->tf_trapno == T_BRKPT) {
f0104d6a:	83 f8 03             	cmp    $0x3,%eax
f0104d6d:	75 0d                	jne    f0104d7c <trap+0x15f>
//		cprintf("BREAK POINT!\n");
		breakpoint_handler(tf);
f0104d6f:	89 34 24             	mov    %esi,(%esp)
f0104d72:	e8 93 fe ff ff       	call   f0104c0a <breakpoint_handler>
f0104d77:	e9 8a 00 00 00       	jmp    f0104e06 <trap+0x1e9>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
f0104d7c:	83 f8 30             	cmp    $0x30,%eax
f0104d7f:	90                   	nop
f0104d80:	75 32                	jne    f0104db4 <trap+0x197>
		//cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104d82:	8b 46 04             	mov    0x4(%esi),%eax
f0104d85:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104d89:	8b 06                	mov    (%esi),%eax
f0104d8b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104d8f:	8b 46 10             	mov    0x10(%esi),%eax
f0104d92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d96:	8b 46 18             	mov    0x18(%esi),%eax
f0104d99:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d9d:	8b 46 14             	mov    0x14(%esi),%eax
f0104da0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104da4:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104da7:	89 04 24             	mov    %eax,(%esp)
f0104daa:	e8 5d 03 00 00       	call   f010510c <syscall>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
		//cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
f0104daf:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104db2:	eb 52                	jmp    f0104e06 <trap+0x1e9>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104db4:	83 f8 20             	cmp    $0x20,%eax
f0104db7:	75 0c                	jne    f0104dc5 <trap+0x1a8>
		lapic_eoi();
f0104db9:	e8 dd 1e 00 00       	call   f0106c9b <lapic_eoi>
		sched_yield();
f0104dbe:	66 90                	xchg   %ax,%ax
f0104dc0:	e8 4f 02 00 00       	call   f0105014 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104dc5:	89 34 24             	mov    %esi,(%esp)
f0104dc8:	e8 ea fa ff ff       	call   f01048b7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104dcd:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104dd2:	75 1c                	jne    f0104df0 <trap+0x1d3>
		panic("unhandled trap in kernel");
f0104dd4:	c7 44 24 08 78 89 10 	movl   $0xf0108978,0x8(%esp)
f0104ddb:	f0 
f0104ddc:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
f0104de3:	00 
f0104de4:	c7 04 24 4c 89 10 f0 	movl   $0xf010894c,(%esp)
f0104deb:	e8 50 b2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104df0:	e8 5b 1d 00 00       	call   f0106b50 <cpunum>
f0104df5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df8:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104dfe:	89 04 24             	mov    %eax,(%esp)
f0104e01:	e8 13 f5 ff ff       	call   f0104319 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104e06:	e8 45 1d 00 00       	call   f0106b50 <cpunum>
f0104e0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e0e:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0104e15:	74 2a                	je     f0104e41 <trap+0x224>
f0104e17:	e8 34 1d 00 00       	call   f0106b50 <cpunum>
f0104e1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e1f:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104e25:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e29:	75 16                	jne    f0104e41 <trap+0x224>
		env_run(curenv);
f0104e2b:	e8 20 1d 00 00       	call   f0106b50 <cpunum>
f0104e30:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e33:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104e39:	89 04 24             	mov    %eax,(%esp)
f0104e3c:	e8 79 f5 ff ff       	call   f01043ba <env_run>
	else
		sched_yield();
f0104e41:	e8 ce 01 00 00       	call   f0105014 <sched_yield>
	...

f0104e48 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec_entry(th0, 0)
f0104e48:	6a 00                	push   $0x0
f0104e4a:	6a 00                	push   $0x0
f0104e4c:	e9 cf 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e51:	90                   	nop

f0104e52 <th1>:
	noec_entry(th1, 1)
f0104e52:	6a 00                	push   $0x0
f0104e54:	6a 01                	push   $0x1
f0104e56:	e9 c5 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e5b:	90                   	nop

f0104e5c <th3>:
	reserved_entry()
	noec_entry(th3, 3)
f0104e5c:	6a 00                	push   $0x0
f0104e5e:	6a 03                	push   $0x3
f0104e60:	e9 bb 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e65:	90                   	nop

f0104e66 <th4>:
	noec_entry(th4, 4)
f0104e66:	6a 00                	push   $0x0
f0104e68:	6a 04                	push   $0x4
f0104e6a:	e9 b1 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e6f:	90                   	nop

f0104e70 <th5>:
	noec_entry(th5, 5)
f0104e70:	6a 00                	push   $0x0
f0104e72:	6a 05                	push   $0x5
f0104e74:	e9 a7 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e79:	90                   	nop

f0104e7a <th6>:
	noec_entry(th6, 6)
f0104e7a:	6a 00                	push   $0x0
f0104e7c:	6a 06                	push   $0x6
f0104e7e:	e9 9d 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e83:	90                   	nop

f0104e84 <th7>:
	noec_entry(th7, 7)
f0104e84:	6a 00                	push   $0x0
f0104e86:	6a 07                	push   $0x7
f0104e88:	e9 93 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e8d:	90                   	nop

f0104e8e <th8>:
	ec_entry(th8, 8)
f0104e8e:	6a 08                	push   $0x8
f0104e90:	e9 8b 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e95:	90                   	nop

f0104e96 <th9>:
	noec_entry(th9, 9)
f0104e96:	6a 00                	push   $0x0
f0104e98:	6a 09                	push   $0x9
f0104e9a:	e9 81 00 00 00       	jmp    f0104f20 <_alltraps>
f0104e9f:	90                   	nop

f0104ea0 <th10>:
	ec_entry(th10, 10)
f0104ea0:	6a 0a                	push   $0xa
f0104ea2:	eb 7c                	jmp    f0104f20 <_alltraps>

f0104ea4 <th11>:
	ec_entry(th11, 11)
f0104ea4:	6a 0b                	push   $0xb
f0104ea6:	eb 78                	jmp    f0104f20 <_alltraps>

f0104ea8 <th12>:
	ec_entry(th12, 12)
f0104ea8:	6a 0c                	push   $0xc
f0104eaa:	eb 74                	jmp    f0104f20 <_alltraps>

f0104eac <th13>:
	ec_entry(th13, 13)
f0104eac:	6a 0d                	push   $0xd
f0104eae:	eb 70                	jmp    f0104f20 <_alltraps>

f0104eb0 <th14>:
	ec_entry(th14, 14)
f0104eb0:	6a 0e                	push   $0xe
f0104eb2:	eb 6c                	jmp    f0104f20 <_alltraps>

f0104eb4 <th16>:
	reserved_entry()
	
.data
	.space 60
.text
	noec_entry(th16, 16)
f0104eb4:	6a 00                	push   $0x0
f0104eb6:	6a 10                	push   $0x10
f0104eb8:	eb 66                	jmp    f0104f20 <_alltraps>

f0104eba <th32>:
	noec_entry(th32, 32)
f0104eba:	6a 00                	push   $0x0
f0104ebc:	6a 20                	push   $0x20
f0104ebe:	eb 60                	jmp    f0104f20 <_alltraps>

f0104ec0 <th33>:
    noec_entry(th33, 33)
f0104ec0:	6a 00                	push   $0x0
f0104ec2:	6a 21                	push   $0x21
f0104ec4:	eb 5a                	jmp    f0104f20 <_alltraps>

f0104ec6 <th34>:
    noec_entry(th34, 34)
f0104ec6:	6a 00                	push   $0x0
f0104ec8:	6a 22                	push   $0x22
f0104eca:	eb 54                	jmp    f0104f20 <_alltraps>

f0104ecc <th35>:
    noec_entry(th35, 35)
f0104ecc:	6a 00                	push   $0x0
f0104ece:	6a 23                	push   $0x23
f0104ed0:	eb 4e                	jmp    f0104f20 <_alltraps>

f0104ed2 <th36>:
    noec_entry(th36, 36)
f0104ed2:	6a 00                	push   $0x0
f0104ed4:	6a 24                	push   $0x24
f0104ed6:	eb 48                	jmp    f0104f20 <_alltraps>

f0104ed8 <th37>:
    noec_entry(th37, 37)
f0104ed8:	6a 00                	push   $0x0
f0104eda:	6a 25                	push   $0x25
f0104edc:	eb 42                	jmp    f0104f20 <_alltraps>

f0104ede <th38>:
    noec_entry(th38, 38)
f0104ede:	6a 00                	push   $0x0
f0104ee0:	6a 26                	push   $0x26
f0104ee2:	eb 3c                	jmp    f0104f20 <_alltraps>

f0104ee4 <th39>:
    noec_entry(th39, 39)
f0104ee4:	6a 00                	push   $0x0
f0104ee6:	6a 27                	push   $0x27
f0104ee8:	eb 36                	jmp    f0104f20 <_alltraps>

f0104eea <th40>:
    noec_entry(th40, 40)
f0104eea:	6a 00                	push   $0x0
f0104eec:	6a 28                	push   $0x28
f0104eee:	eb 30                	jmp    f0104f20 <_alltraps>

f0104ef0 <th41>:
    noec_entry(th41, 41)
f0104ef0:	6a 00                	push   $0x0
f0104ef2:	6a 29                	push   $0x29
f0104ef4:	eb 2a                	jmp    f0104f20 <_alltraps>

f0104ef6 <th42>:
    noec_entry(th42, 42)
f0104ef6:	6a 00                	push   $0x0
f0104ef8:	6a 2a                	push   $0x2a
f0104efa:	eb 24                	jmp    f0104f20 <_alltraps>

f0104efc <th43>:
    noec_entry(th43, 43)
f0104efc:	6a 00                	push   $0x0
f0104efe:	6a 2b                	push   $0x2b
f0104f00:	eb 1e                	jmp    f0104f20 <_alltraps>

f0104f02 <th44>:
    noec_entry(th44, 44)
f0104f02:	6a 00                	push   $0x0
f0104f04:	6a 2c                	push   $0x2c
f0104f06:	eb 18                	jmp    f0104f20 <_alltraps>

f0104f08 <th45>:
    noec_entry(th45, 45)
f0104f08:	6a 00                	push   $0x0
f0104f0a:	6a 2d                	push   $0x2d
f0104f0c:	eb 12                	jmp    f0104f20 <_alltraps>

f0104f0e <th46>:
    noec_entry(th46, 46)
f0104f0e:	6a 00                	push   $0x0
f0104f10:	6a 2e                	push   $0x2e
f0104f12:	eb 0c                	jmp    f0104f20 <_alltraps>

f0104f14 <th47>:
    noec_entry(th47, 47)
f0104f14:	6a 00                	push   $0x0
f0104f16:	6a 2f                	push   $0x2f
f0104f18:	eb 06                	jmp    f0104f20 <_alltraps>

f0104f1a <th48>:
	noec_entry(th48, 48)
f0104f1a:	6a 00                	push   $0x0
f0104f1c:	6a 30                	push   $0x30
f0104f1e:	eb 00                	jmp    f0104f20 <_alltraps>

f0104f20 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104f20:	1e                   	push   %ds
	pushl %es
f0104f21:	06                   	push   %es
	pushal
f0104f22:	60                   	pusha  
	pushl $GD_KD
f0104f23:	6a 10                	push   $0x10
	popl %ds
f0104f25:	1f                   	pop    %ds
	pushl $GD_KD
f0104f26:	6a 10                	push   $0x10
	popl %es
f0104f28:	07                   	pop    %es
	pushl %esp
f0104f29:	54                   	push   %esp
	call trap
f0104f2a:	e8 ee fc ff ff       	call   f0104c1d <trap>
	...

f0104f30 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104f30:	55                   	push   %ebp
f0104f31:	89 e5                	mov    %esp,%ebp
f0104f33:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f36:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
f0104f3c:	8b 42 54             	mov    0x54(%edx),%eax
f0104f3f:	83 e8 02             	sub    $0x2,%eax
f0104f42:	83 f8 01             	cmp    $0x1,%eax
f0104f45:	76 45                	jbe    f0104f8c <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104f47:	81 c2 d4 00 00 00    	add    $0xd4,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104f4d:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f52:	8b 0a                	mov    (%edx),%ecx
f0104f54:	83 e9 02             	sub    $0x2,%ecx
f0104f57:	83 f9 01             	cmp    $0x1,%ecx
f0104f5a:	76 0f                	jbe    f0104f6b <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104f5c:	83 c0 01             	add    $0x1,%eax
f0104f5f:	83 ea 80             	sub    $0xffffff80,%edx
f0104f62:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f67:	75 e9                	jne    f0104f52 <sched_halt+0x22>
f0104f69:	eb 07                	jmp    f0104f72 <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104f6b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f70:	75 1a                	jne    f0104f8c <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f0104f72:	c7 04 24 50 8b 10 f0 	movl   $0xf0108b50,(%esp)
f0104f79:	e8 70 f6 ff ff       	call   f01045ee <cprintf>
		while (1)
			monitor(NULL);
f0104f7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104f85:	e8 a2 c0 ff ff       	call   f010102c <monitor>
f0104f8a:	eb f2                	jmp    f0104f7e <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104f8c:	e8 bf 1b 00 00       	call   f0106b50 <cpunum>
f0104f91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f94:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0104f9b:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104f9e:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104fa3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104fa8:	77 20                	ja     f0104fca <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104faa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fae:	c7 44 24 08 c4 72 10 	movl   $0xf01072c4,0x8(%esp)
f0104fb5:	f0 
f0104fb6:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
f0104fbd:	00 
f0104fbe:	c7 04 24 79 8b 10 f0 	movl   $0xf0108b79,(%esp)
f0104fc5:	e8 76 b0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104fca:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104fcf:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104fd2:	e8 79 1b 00 00       	call   f0106b50 <cpunum>
f0104fd7:	6b d0 74             	imul   $0x74,%eax,%edx
f0104fda:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104fe0:	b8 02 00 00 00       	mov    $0x2,%eax
f0104fe5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104fe9:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104ff0:	e8 ce 1e 00 00       	call   f0106ec3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104ff5:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104ff7:	e8 54 1b 00 00       	call   f0106b50 <cpunum>
f0104ffc:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104fff:	8b 80 30 d0 22 f0    	mov    -0xfdd2fd0(%eax),%eax
f0105005:	bd 00 00 00 00       	mov    $0x0,%ebp
f010500a:	89 c4                	mov    %eax,%esp
f010500c:	6a 00                	push   $0x0
f010500e:	6a 00                	push   $0x0
f0105010:	fb                   	sti    
f0105011:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0105012:	c9                   	leave  
f0105013:	c3                   	ret    

f0105014 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105014:	55                   	push   %ebp
f0105015:	89 e5                	mov    %esp,%ebp
f0105017:	56                   	push   %esi
f0105018:	53                   	push   %ebx
f0105019:	83 ec 10             	sub    $0x10,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
f010501c:	e8 2f 1b 00 00       	call   f0106b50 <cpunum>
f0105021:	6b c0 74             	imul   $0x74,%eax,%eax
		else cur = 0;
f0105024:	bb 00 00 00 00       	mov    $0x0,%ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
f0105029:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0105030:	74 1a                	je     f010504c <sched_yield+0x38>
f0105032:	e8 19 1b 00 00       	call   f0106b50 <cpunum>
f0105037:	6b c0 74             	imul   $0x74,%eax,%eax
f010503a:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105040:	8b 40 44             	mov    0x44(%eax),%eax
f0105043:	8b 58 48             	mov    0x48(%eax),%ebx
f0105046:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
f010504c:	8b 35 48 c2 22 f0    	mov    0xf022c248,%esi
f0105052:	89 da                	mov    %ebx,%edx
f0105054:	c1 e2 07             	shl    $0x7,%edx
f0105057:	01 f2                	add    %esi,%edx
f0105059:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f010505d:	74 27                	je     f0105086 <sched_yield+0x72>

	// LAB 4: Your code here.
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
f010505f:	b8 01 00 00 00       	mov    $0x1,%eax

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0105064:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
	// LAB 4: Your code here.
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
f0105067:	89 ca                	mov    %ecx,%edx
f0105069:	c1 fa 1f             	sar    $0x1f,%edx
f010506c:	c1 ea 16             	shr    $0x16,%edx
f010506f:	01 d1                	add    %edx,%ecx
f0105071:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0105077:	29 d1                	sub    %edx,%ecx
f0105079:	89 ca                	mov    %ecx,%edx
		if (envs[j].env_status == ENV_RUNNABLE) {
f010507b:	c1 e2 07             	shl    $0x7,%edx
f010507e:	01 f2                	add    %esi,%edx
f0105080:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0105084:	75 08                	jne    f010508e <sched_yield+0x7a>
//			if (j == 1) 
//				cprintf("\n");
			env_run(envs + j);
f0105086:	89 14 24             	mov    %edx,(%esp)
f0105089:	e8 2c f3 ff ff       	call   f01043ba <env_run>

	// LAB 4: Your code here.
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
f010508e:	83 c0 01             	add    $0x1,%eax
f0105091:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105096:	75 cc                	jne    f0105064 <sched_yield+0x50>
//			if (j == 1) 
//				cprintf("\n");
			env_run(envs + j);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0105098:	e8 b3 1a 00 00       	call   f0106b50 <cpunum>
f010509d:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a0:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01050a7:	74 2a                	je     f01050d3 <sched_yield+0xbf>
f01050a9:	e8 a2 1a 00 00       	call   f0106b50 <cpunum>
f01050ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01050b1:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01050b7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01050bb:	75 16                	jne    f01050d3 <sched_yield+0xbf>
		env_run(curenv);
f01050bd:	e8 8e 1a 00 00       	call   f0106b50 <cpunum>
f01050c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01050c5:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01050cb:	89 04 24             	mov    %eax,(%esp)
f01050ce:	e8 e7 f2 ff ff       	call   f01043ba <env_run>

	// sched_halt never returns
//cprintf("**Fail to find one\n");
	sched_halt();
f01050d3:	e8 58 fe ff ff       	call   f0104f30 <sched_halt>
}
f01050d8:	83 c4 10             	add    $0x10,%esp
f01050db:	5b                   	pop    %ebx
f01050dc:	5e                   	pop    %esi
f01050dd:	5d                   	pop    %ebp
f01050de:	c3                   	ret    
	...

f01050e0 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f01050e0:	55                   	push   %ebp
f01050e1:	89 e5                	mov    %esp,%ebp
f01050e3:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f01050e6:	e8 29 ff ff ff       	call   f0105014 <sched_yield>

f01050eb <sys_change_pr>:
    sys_yield();
	return 0;
}


int sys_change_pr(int pr) {
f01050eb:	55                   	push   %ebp
f01050ec:	89 e5                	mov    %esp,%ebp
f01050ee:	83 ec 08             	sub    $0x8,%esp
    curenv->pr = pr;
f01050f1:	e8 5a 1a 00 00       	call   f0106b50 <cpunum>
f01050f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f9:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01050ff:	8b 55 08             	mov    0x8(%ebp),%edx
f0105102:	89 50 7c             	mov    %edx,0x7c(%eax)
    return 0;
}
f0105105:	b8 00 00 00 00       	mov    $0x0,%eax
f010510a:	c9                   	leave  
f010510b:	c3                   	ret    

f010510c <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010510c:	55                   	push   %ebp
f010510d:	89 e5                	mov    %esp,%ebp
f010510f:	83 ec 38             	sub    $0x38,%esp
f0105112:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105115:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105118:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010511b:	8b 45 08             	mov    0x8(%ebp),%eax
f010511e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105121:	8b 5d 10             	mov    0x10(%ebp),%ebx
			
		case SYS_change_pr:
			return sys_change_pr((int)a1);
			
		default: 
			return -E_INVAL;
f0105124:	be fd ff ff ff       	mov    $0xfffffffd,%esi
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno){
f0105129:	83 f8 0d             	cmp    $0xd,%eax
f010512c:	0f 87 8e 05 00 00    	ja     f01056c0 <syscall+0x5b4>
f0105132:	ff 24 85 c0 8b 10 f0 	jmp    *-0xfef7440(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(void *)s, len, PTE_U | PTE_P);
f0105139:	e8 12 1a 00 00       	call   f0106b50 <cpunum>
f010513e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0105145:	00 
f0105146:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010514a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010514e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105151:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105157:	89 04 24             	mov    %eax,(%esp)
f010515a:	e8 ad ea ff ff       	call   f0103c0c <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010515f:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105163:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105167:	c7 04 24 86 8b 10 f0 	movl   $0xf0108b86,(%esp)
f010516e:	e8 7b f4 ff ff       	call   f01045ee <cprintf>
	// LAB 3: Your code here.
	switch (syscallno){
		case SYS_cputs:
			//cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
f0105173:	be 00 00 00 00       	mov    $0x0,%esi
f0105178:	e9 43 05 00 00       	jmp    f01056c0 <syscall+0x5b4>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010517d:	e8 c6 b4 ff ff       	call   f0100648 <cons_getc>
f0105182:	89 c6                	mov    %eax,%esi
			//cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
		case SYS_cgetc:
			//cprintf("SYS_cgetc\n");
			return sys_cgetc();
f0105184:	e9 37 05 00 00       	jmp    f01056c0 <syscall+0x5b4>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105189:	e8 c2 19 00 00       	call   f0106b50 <cpunum>
f010518e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105191:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105197:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_cgetc:
			//cprintf("SYS_cgetc\n");
			return sys_cgetc();
		case SYS_getenvid:
			//cprintf("SYS_getenvid\n");
			return sys_getenvid();
f010519a:	e9 21 05 00 00       	jmp    f01056c0 <syscall+0x5b4>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010519f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051a6:	00 
f01051a7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051ae:	89 3c 24             	mov    %edi,(%esp)
f01051b1:	e8 33 eb ff ff       	call   f0103ce9 <envid2env>
f01051b6:	89 c6                	mov    %eax,%esi
f01051b8:	85 c0                	test   %eax,%eax
f01051ba:	0f 88 00 05 00 00    	js     f01056c0 <syscall+0x5b4>
		return r;
	if (e == curenv)
f01051c0:	e8 8b 19 00 00       	call   f0106b50 <cpunum>
f01051c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01051c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01051cb:	39 90 28 d0 22 f0    	cmp    %edx,-0xfdd2fd8(%eax)
f01051d1:	75 23                	jne    f01051f6 <syscall+0xea>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01051d3:	e8 78 19 00 00       	call   f0106b50 <cpunum>
f01051d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01051db:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01051e1:	8b 40 48             	mov    0x48(%eax),%eax
f01051e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051e8:	c7 04 24 8b 8b 10 f0 	movl   $0xf0108b8b,(%esp)
f01051ef:	e8 fa f3 ff ff       	call   f01045ee <cprintf>
f01051f4:	eb 28                	jmp    f010521e <syscall+0x112>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01051f6:	8b 5a 48             	mov    0x48(%edx),%ebx
f01051f9:	e8 52 19 00 00       	call   f0106b50 <cpunum>
f01051fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105202:	6b c0 74             	imul   $0x74,%eax,%eax
f0105205:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010520b:	8b 40 48             	mov    0x48(%eax),%eax
f010520e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105212:	c7 04 24 a6 8b 10 f0 	movl   $0xf0108ba6,(%esp)
f0105219:	e8 d0 f3 ff ff       	call   f01045ee <cprintf>
	env_destroy(e);
f010521e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105221:	89 04 24             	mov    %eax,(%esp)
f0105224:	e8 f0 f0 ff ff       	call   f0104319 <env_destroy>
	return 0;
f0105229:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_getenvid:
			//cprintf("SYS_getenvid\n");
			return sys_getenvid();
		case SYS_env_destroy:
			//cprintf("SYS_env_destroy\n");
			return sys_env_destroy(a1);
f010522e:	e9 8d 04 00 00       	jmp    f01056c0 <syscall+0x5b4>
		case SYS_yield:
			//cprintf("SYS_yield\n");
			sys_yield();
f0105233:	e8 a8 fe ff ff       	call   f01050e0 <sys_yield>

	// LAB 4: Your code here.
//cprintf("**sys_exofork: get into\n");
	struct Env *env;
	int ret;
	if((ret = env_alloc(&env, curenv->env_id)) < 0) {
f0105238:	e8 13 19 00 00       	call   f0106b50 <cpunum>
f010523d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105240:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105246:	8b 40 48             	mov    0x48(%eax),%eax
f0105249:	89 44 24 04          	mov    %eax,0x4(%esp)
f010524d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105250:	89 04 24             	mov    %eax,(%esp)
f0105253:	e8 a5 eb ff ff       	call   f0103dfd <env_alloc>
f0105258:	89 c6                	mov    %eax,%esi
f010525a:	85 c0                	test   %eax,%eax
f010525c:	0f 88 5e 04 00 00    	js     f01056c0 <syscall+0x5b4>
//cprintf("**sys_exofork: env_alloc fails\n");
		return ret;
	}

	env->env_status = ENV_NOT_RUNNABLE;
f0105262:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105265:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	env->env_tf = curenv->env_tf;
f010526c:	e8 df 18 00 00       	call   f0106b50 <cpunum>
f0105271:	6b c0 74             	imul   $0x74,%eax,%eax
f0105274:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
f010527a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010527f:	89 df                	mov    %ebx,%edi
f0105281:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// At the point that system call
	// Why the child does not go into the system call again
	env->env_tf.tf_regs.reg_eax = 0;
f0105283:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105286:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

//cprintf("**sys_exofork: env_id = %x\n", env->env_id);
	return env->env_id;
f010528d:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_yield:
			//cprintf("SYS_yield\n");
			sys_yield();

		case SYS_exofork:
			return sys_exofork();
f0105290:	e9 2b 04 00 00       	jmp    f01056c0 <syscall+0x5b4>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
f0105295:	89 f8                	mov    %edi,%eax
f0105297:	c1 e8 1f             	shr    $0x1f,%eax
f010529a:	84 c0                	test   %al,%al
f010529c:	0f 85 f5 00 00 00    	jne    f0105397 <syscall+0x28b>
f01052a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a5:	c1 e8 1f             	shr    $0x1f,%eax
f01052a8:	84 c0                	test   %al,%al
f01052aa:	0f 85 e7 00 00 00    	jne    f0105397 <syscall+0x28b>
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
f01052b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052b7:	00 
f01052b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01052bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052bf:	89 3c 24             	mov    %edi,(%esp)
f01052c2:	e8 22 ea ff ff       	call   f0103ce9 <envid2env>
		return -E_BAD_ENV;
f01052c7:	be fe ff ff ff       	mov    $0xfffffffe,%esi

	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
f01052cc:	85 c0                	test   %eax,%eax
f01052ce:	0f 88 ec 03 00 00    	js     f01056c0 <syscall+0x5b4>
f01052d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052db:	00 
f01052dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01052df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052e3:	8b 7d 14             	mov    0x14(%ebp),%edi
f01052e6:	89 3c 24             	mov    %edi,(%esp)
f01052e9:	e8 fb e9 ff ff       	call   f0103ce9 <envid2env>
f01052ee:	85 c0                	test   %eax,%eax
f01052f0:	0f 88 ab 00 00 00    	js     f01053a1 <syscall+0x295>
		return -E_BAD_ENV;

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
		return -E_INVAL;
f01052f6:	66 be fd ff          	mov    $0xfffd,%si
	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
		return -E_BAD_ENV;

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
f01052fa:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105300:	0f 87 ba 03 00 00    	ja     f01056c0 <syscall+0x5b4>
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
f0105306:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f010530c:	0f 85 99 00 00 00    	jne    f01053ab <syscall+0x29f>
f0105312:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105319:	0f 87 8c 00 00 00    	ja     f01053ab <syscall+0x29f>
f010531f:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105326:	0f 85 94 03 00 00    	jne    f01056c0 <syscall+0x5b4>
		return -E_INVAL;

	pte_t *pte;
	struct PageInfo *p;
	if((p = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f010532c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010532f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105333:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105337:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010533a:	8b 40 60             	mov    0x60(%eax),%eax
f010533d:	89 04 24             	mov    %eax,(%esp)
f0105340:	e8 04 c6 ff ff       	call   f0101949 <page_lookup>
f0105345:	85 c0                	test   %eax,%eax
f0105347:	74 6c                	je     f01053b5 <syscall+0x2a9>
		return -E_INVAL;

	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f0105349:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010534c:	83 e2 05             	and    $0x5,%edx
f010534f:	83 fa 05             	cmp    $0x5,%edx
f0105352:	0f 85 68 03 00 00    	jne    f01056c0 <syscall+0x5b4>
		return -E_INVAL;

	if(perm & PTE_W && !(*pte & PTE_W))
f0105358:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010535c:	74 0c                	je     f010536a <syscall+0x25e>
f010535e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105361:	f6 02 02             	testb  $0x2,(%edx)
f0105364:	0f 84 56 03 00 00    	je     f01056c0 <syscall+0x5b4>
		return -E_INVAL;

	if(page_insert(dstenv->env_pgdir, p, dstva, perm) < 0)
f010536a:	8b 7d 1c             	mov    0x1c(%ebp),%edi
f010536d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105371:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105374:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105378:	89 44 24 04          	mov    %eax,0x4(%esp)
f010537c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010537f:	8b 40 60             	mov    0x60(%eax),%eax
f0105382:	89 04 24             	mov    %eax,(%esp)
f0105385:	e8 bc c6 ff ff       	call   f0101a46 <page_insert>
		return -E_NO_MEM;
f010538a:	89 c6                	mov    %eax,%esi
f010538c:	c1 fe 1f             	sar    $0x1f,%esi
f010538f:	83 e6 fc             	and    $0xfffffffc,%esi
f0105392:	e9 29 03 00 00       	jmp    f01056c0 <syscall+0x5b4>
	// LAB 4: Your code here.

	struct Env *srcenv, *dstenv;
	if(srcenvid < 0 || dstenvid < 0
		|| envid2env(srcenvid, &srcenv, true) < 0 || envid2env(dstenvid, &dstenv, true) < 0)
		return -E_BAD_ENV;
f0105397:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f010539c:	e9 1f 03 00 00       	jmp    f01056c0 <syscall+0x5b4>
f01053a1:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01053a6:	e9 15 03 00 00       	jmp    f01056c0 <syscall+0x5b4>

	if(srcva >= (void *)UTOP || (unsigned int)srcva % PGSIZE != 0 
		|| dstva >= (void *)UTOP || (unsigned int)dstva % PGSIZE != 0)
		return -E_INVAL;
f01053ab:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01053b0:	e9 0b 03 00 00       	jmp    f01056c0 <syscall+0x5b4>

	pte_t *pte;
	struct PageInfo *p;
	if((p = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f01053b5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01053ba:	e9 01 03 00 00       	jmp    f01056c0 <syscall+0x5b4>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
f01053bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01053c6:	00 
f01053c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053ce:	89 3c 24             	mov    %edi,(%esp)
f01053d1:	e8 13 e9 ff ff       	call   f0103ce9 <envid2env>
f01053d6:	85 c0                	test   %eax,%eax
f01053d8:	78 39                	js     f0105413 <syscall+0x307>
		return -E_BAD_ENV;
	if(va >= (void *)UTOP || (unsigned int)va % PGSIZE != 0)
		return -E_INVAL;
f01053da:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
		return -E_BAD_ENV;
	if(va >= (void *)UTOP || (unsigned int)va % PGSIZE != 0)
f01053df:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01053e5:	0f 87 d5 02 00 00    	ja     f01056c0 <syscall+0x5b4>
f01053eb:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01053f1:	0f 85 c9 02 00 00    	jne    f01056c0 <syscall+0x5b4>
		return -E_INVAL;

	page_remove(env->env_pgdir, va);
f01053f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053fe:	8b 40 60             	mov    0x60(%eax),%eax
f0105401:	89 04 24             	mov    %eax,(%esp)
f0105404:	e8 ed c5 ff ff       	call   f01019f6 <page_remove>

	return 0;
f0105409:	be 00 00 00 00       	mov    $0x0,%esi
f010540e:	e9 ad 02 00 00       	jmp    f01056c0 <syscall+0x5b4>

	// LAB 4: Your code here.

	struct Env *env;
	if(envid2env(envid, &env, true) < 0)
		return -E_BAD_ENV;
f0105413:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105418:	e9 a3 02 00 00       	jmp    f01056c0 <syscall+0x5b4>

	// LAB 4: Your code here.

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
f010541d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105424:	00 
f0105425:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105428:	89 44 24 04          	mov    %eax,0x4(%esp)
f010542c:	89 3c 24             	mov    %edi,(%esp)
f010542f:	e8 b5 e8 ff ff       	call   f0103ce9 <envid2env>
f0105434:	85 c0                	test   %eax,%eax
f0105436:	78 67                	js     f010549f <syscall+0x393>
		return -E_BAD_ENV;
	if(va >= (void *)UTOP)
		return -E_INVAL;
f0105438:	be fd ff ff ff       	mov    $0xfffffffd,%esi

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
	if(va >= (void *)UTOP)
f010543d:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105443:	0f 87 77 02 00 00    	ja     f01056c0 <syscall+0x5b4>
		return -E_INVAL;
	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f0105449:	8b 45 14             	mov    0x14(%ebp),%eax
f010544c:	83 e0 05             	and    $0x5,%eax
f010544f:	83 f8 05             	cmp    $0x5,%eax
f0105452:	0f 85 68 02 00 00    	jne    f01056c0 <syscall+0x5b4>
		return -E_INVAL;

	
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0105458:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010545f:	e8 fe c2 ff ff       	call   f0101762 <page_alloc>
f0105464:	89 c7                	mov    %eax,%edi
	if(!p) {
f0105466:	85 c0                	test   %eax,%eax
f0105468:	74 3f                	je     f01054a9 <syscall+0x39d>
		return -E_NO_MEM;
	}
	p->pp_ref ++;
f010546a:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

	int ret;
	if((ret = page_insert(env->env_pgdir, p, va, perm)) < 0) {
f010546f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105472:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105476:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010547a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010547e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105481:	8b 40 60             	mov    0x60(%eax),%eax
f0105484:	89 04 24             	mov    %eax,(%esp)
f0105487:	e8 ba c5 ff ff       	call   f0101a46 <page_insert>
f010548c:	89 c6                	mov    %eax,%esi
f010548e:	85 c0                	test   %eax,%eax
f0105490:	79 21                	jns    f01054b3 <syscall+0x3a7>
		page_free(p);
f0105492:	89 3c 24             	mov    %edi,(%esp)
f0105495:	e8 46 c3 ff ff       	call   f01017e0 <page_free>
f010549a:	e9 21 02 00 00       	jmp    f01056c0 <syscall+0x5b4>
	// LAB 4: Your code here.

	struct Env *env;

	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f010549f:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01054a4:	e9 17 02 00 00       	jmp    f01056c0 <syscall+0x5b4>
		return -E_INVAL;

	
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
	if(!p) {
		return -E_NO_MEM;
f01054a9:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f01054ae:	e9 0d 02 00 00       	jmp    f01056c0 <syscall+0x5b4>
	int ret;
	if((ret = page_insert(env->env_pgdir, p, va, perm)) < 0) {
		page_free(p);
		return ret;
	}
	return 0;
f01054b3:	be 00 00 00 00       	mov    $0x0,%esi
			return sys_page_map((envid_t)a1, (void *)a2,
	     		(envid_t)a3, (void *)a4, (int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f01054b8:	e9 03 02 00 00       	jmp    f01056c0 <syscall+0x5b4>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f01054bd:	83 fb 04             	cmp    $0x4,%ebx
f01054c0:	74 0e                	je     f01054d0 <syscall+0x3c4>
		return -E_INVAL;
f01054c2:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f01054c7:	83 fb 02             	cmp    $0x2,%ebx
f01054ca:	0f 85 f0 01 00 00    	jne    f01056c0 <syscall+0x5b4>
		return -E_INVAL;
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0)
f01054d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054d7:	00 
f01054d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054df:	89 3c 24             	mov    %edi,(%esp)
f01054e2:	e8 02 e8 ff ff       	call   f0103ce9 <envid2env>
f01054e7:	85 c0                	test   %eax,%eax
f01054e9:	78 10                	js     f01054fb <syscall+0x3ef>
		return -E_BAD_ENV;

	env->env_status = status;
f01054eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054ee:	89 58 54             	mov    %ebx,0x54(%eax)

	return 0;
f01054f1:	be 00 00 00 00       	mov    $0x0,%esi
f01054f6:	e9 c5 01 00 00       	jmp    f01056c0 <syscall+0x5b4>
	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
		return -E_INVAL;
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f01054fb:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f0105500:	e9 bb 01 00 00       	jmp    f01056c0 <syscall+0x5b4>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
    int ret = envid2env(envid, &e, 1);
f0105505:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010550c:	00 
f010550d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105510:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105514:	89 3c 24             	mov    %edi,(%esp)
f0105517:	e8 cd e7 ff ff       	call   f0103ce9 <envid2env>
f010551c:	89 c6                	mov    %eax,%esi
    if (ret) return ret;    //bad_env
f010551e:	85 c0                	test   %eax,%eax
f0105520:	0f 85 9a 01 00 00    	jne    f01056c0 <syscall+0x5b4>
    e->env_pgfault_upcall = func;
f0105526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105529:	89 58 64             	mov    %ebx,0x64(%eax)
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f010552c:	e9 8f 01 00 00       	jmp    f01056c0 <syscall+0x5b4>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env *e;
    int ret = envid2env(envid, &e, 0);
f0105531:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105538:	00 
f0105539:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010553c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105540:	89 3c 24             	mov    %edi,(%esp)
f0105543:	e8 a1 e7 ff ff       	call   f0103ce9 <envid2env>
f0105548:	89 c6                	mov    %eax,%esi
    if (ret) return ret;
f010554a:	85 c0                	test   %eax,%eax
f010554c:	0f 85 6e 01 00 00    	jne    f01056c0 <syscall+0x5b4>

    if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0105552:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105555:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105559:	0f 84 d6 00 00 00    	je     f0105635 <syscall+0x529>
    if (srcva < (void*)UTOP) {
f010555f:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105566:	0f 87 95 00 00 00    	ja     f0105601 <syscall+0x4f5>
    	// Find the current env's page
        pte_t *pte;
        struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f010556c:	e8 df 15 00 00       	call   f0106b50 <cpunum>
f0105571:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105574:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105578:	8b 7d 14             	mov    0x14(%ebp),%edi
f010557b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010557f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105582:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105588:	8b 40 60             	mov    0x60(%eax),%eax
f010558b:	89 04 24             	mov    %eax,(%esp)
f010558e:	e8 b6 c3 ff ff       	call   f0101949 <page_lookup>
        if (!pg) return -E_INVAL;
f0105593:	85 c0                	test   %eax,%eax
f0105595:	0f 84 a4 00 00 00    	je     f010563f <syscall+0x533>
        if ((*pte & perm) != perm) return -E_INVAL;
f010559b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010559e:	8b 12                	mov    (%edx),%edx
f01055a0:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01055a3:	21 d1                	and    %edx,%ecx
f01055a5:	39 4d 18             	cmp    %ecx,0x18(%ebp)
f01055a8:	0f 85 98 00 00 00    	jne    f0105646 <syscall+0x53a>
        if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f01055ae:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01055b2:	74 09                	je     f01055bd <syscall+0x4b1>
f01055b4:	f6 c2 02             	test   $0x2,%dl
f01055b7:	0f 84 90 00 00 00    	je     f010564d <syscall+0x541>
        if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
f01055bd:	8b 55 14             	mov    0x14(%ebp),%edx
f01055c0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01055c6:	39 55 14             	cmp    %edx,0x14(%ebp)
f01055c9:	0f 85 85 00 00 00    	jne    f0105654 <syscall+0x548>

        // Insert the current env's page into a certain env waiting to recive
        if (e->env_ipc_dstva < (void*)UTOP) {
f01055cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01055d2:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01055d5:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01055db:	77 24                	ja     f0105601 <syscall+0x4f5>
            ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
f01055dd:	8b 7d 18             	mov    0x18(%ebp),%edi
f01055e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01055e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01055e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055ec:	8b 42 60             	mov    0x60(%edx),%eax
f01055ef:	89 04 24             	mov    %eax,(%esp)
f01055f2:	e8 4f c4 ff ff       	call   f0101a46 <page_insert>
            if (ret) return ret;
f01055f7:	85 c0                	test   %eax,%eax
f01055f9:	75 60                	jne    f010565b <syscall+0x54f>
            e->env_ipc_perm = perm;
f01055fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055fe:	89 78 78             	mov    %edi,0x78(%eax)
        }
    }

    // Update the reciving env
    e->env_ipc_recving = 0;
f0105601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105604:	c6 47 68 00          	movb   $0x0,0x68(%edi)
    e->env_ipc_from = curenv->env_id;
f0105608:	e8 43 15 00 00       	call   f0106b50 <cpunum>
f010560d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105610:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105616:	8b 40 48             	mov    0x48(%eax),%eax
f0105619:	89 47 74             	mov    %eax,0x74(%edi)
    e->env_ipc_value = value; 
f010561c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010561f:	89 58 70             	mov    %ebx,0x70(%eax)
    e->env_status = ENV_RUNNABLE;
f0105622:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    e->env_tf.tf_regs.reg_eax = 0;
f0105629:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0105630:	e9 8b 00 00 00       	jmp    f01056c0 <syscall+0x5b4>
	// LAB 4: Your code here.
	struct Env *e;
    int ret = envid2env(envid, &e, 0);
    if (ret) return ret;

    if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0105635:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f010563a:	e9 81 00 00 00       	jmp    f01056c0 <syscall+0x5b4>
    if (srcva < (void*)UTOP) {
    	// Find the current env's page
        pte_t *pte;
        struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
        if (!pg) return -E_INVAL;
f010563f:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105644:	eb 7a                	jmp    f01056c0 <syscall+0x5b4>
        if ((*pte & perm) != perm) return -E_INVAL;
f0105646:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010564b:	eb 73                	jmp    f01056c0 <syscall+0x5b4>
        if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f010564d:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105652:	eb 6c                	jmp    f01056c0 <syscall+0x5b4>
        if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
f0105654:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105659:	eb 65                	jmp    f01056c0 <syscall+0x5b4>

        // Insert the current env's page into a certain env waiting to recive
        if (e->env_ipc_dstva < (void*)UTOP) {
            ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
            if (ret) return ret;
f010565b:	89 c6                	mov    %eax,%esi

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);

		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, 
f010565d:	eb 61                	jmp    f01056c0 <syscall+0x5b4>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void*)UTOP) 
f010565f:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105665:	77 0b                	ja     f0105672 <syscall+0x566>
        if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
f0105667:	89 f8                	mov    %edi,%eax
f0105669:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010566e:	39 c7                	cmp    %eax,%edi
f0105670:	75 49                	jne    f01056bb <syscall+0x5af>
            return -E_INVAL;

    // Set up the parameters to wait
    curenv->env_ipc_recving = 1;
f0105672:	e8 d9 14 00 00       	call   f0106b50 <cpunum>
f0105677:	6b c0 74             	imul   $0x74,%eax,%eax
f010567a:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105680:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0105684:	e8 c7 14 00 00       	call   f0106b50 <cpunum>
f0105689:	6b c0 74             	imul   $0x74,%eax,%eax
f010568c:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105692:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    curenv->env_ipc_dstva = dstva;
f0105699:	e8 b2 14 00 00       	call   f0106b50 <cpunum>
f010569e:	6b c0 74             	imul   $0x74,%eax,%eax
f01056a1:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01056a7:	89 78 6c             	mov    %edi,0x6c(%eax)
    sys_yield();
f01056aa:	e8 31 fa ff ff       	call   f01050e0 <sys_yield>
				(void *)a3, (unsigned)a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
			
		case SYS_change_pr:
			return sys_change_pr((int)a1);
f01056af:	89 3c 24             	mov    %edi,(%esp)
f01056b2:	e8 34 fa ff ff       	call   f01050eb <sys_change_pr>
f01056b7:	89 c6                	mov    %eax,%esi
f01056b9:	eb 05                	jmp    f01056c0 <syscall+0x5b4>

		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, 
				(void *)a3, (unsigned)a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f01056bb:	be fd ff ff ff       	mov    $0xfffffffd,%esi
			return sys_change_pr((int)a1);
			
		default: 
			return -E_INVAL;
	}
}
f01056c0:	89 f0                	mov    %esi,%eax
f01056c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01056c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01056c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01056cb:	89 ec                	mov    %ebp,%esp
f01056cd:	5d                   	pop    %ebp
f01056ce:	c3                   	ret    
	...

f01056d0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01056d0:	55                   	push   %ebp
f01056d1:	89 e5                	mov    %esp,%ebp
f01056d3:	57                   	push   %edi
f01056d4:	56                   	push   %esi
f01056d5:	53                   	push   %ebx
f01056d6:	83 ec 14             	sub    $0x14,%esp
f01056d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01056dc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01056df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01056e2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01056e5:	8b 1a                	mov    (%edx),%ebx
f01056e7:	8b 01                	mov    (%ecx),%eax
f01056e9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01056ec:	39 c3                	cmp    %eax,%ebx
f01056ee:	0f 8f 9c 00 00 00    	jg     f0105790 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01056f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01056fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01056fe:	01 d8                	add    %ebx,%eax
f0105700:	89 c7                	mov    %eax,%edi
f0105702:	c1 ef 1f             	shr    $0x1f,%edi
f0105705:	01 c7                	add    %eax,%edi
f0105707:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105709:	39 df                	cmp    %ebx,%edi
f010570b:	7c 33                	jl     f0105740 <stab_binsearch+0x70>
f010570d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105710:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105713:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105718:	39 f0                	cmp    %esi,%eax
f010571a:	0f 84 bc 00 00 00    	je     f01057dc <stab_binsearch+0x10c>
f0105720:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105724:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105728:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010572a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010572d:	39 d8                	cmp    %ebx,%eax
f010572f:	7c 0f                	jl     f0105740 <stab_binsearch+0x70>
f0105731:	0f b6 0a             	movzbl (%edx),%ecx
f0105734:	83 ea 0c             	sub    $0xc,%edx
f0105737:	39 f1                	cmp    %esi,%ecx
f0105739:	75 ef                	jne    f010572a <stab_binsearch+0x5a>
f010573b:	e9 9e 00 00 00       	jmp    f01057de <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105740:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105743:	eb 3c                	jmp    f0105781 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105745:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105748:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010574a:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010574d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105754:	eb 2b                	jmp    f0105781 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105756:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105759:	76 14                	jbe    f010576f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010575b:	83 e8 01             	sub    $0x1,%eax
f010575e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105761:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105764:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105766:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010576d:	eb 12                	jmp    f0105781 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010576f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105772:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0105774:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105778:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010577a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105781:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0105784:	0f 8d 71 ff ff ff    	jge    f01056fb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010578a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010578e:	75 0f                	jne    f010579f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0105790:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105793:	8b 02                	mov    (%edx),%eax
f0105795:	83 e8 01             	sub    $0x1,%eax
f0105798:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010579b:	89 01                	mov    %eax,(%ecx)
f010579d:	eb 57                	jmp    f01057f6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010579f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057a2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01057a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01057a7:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01057a9:	39 c1                	cmp    %eax,%ecx
f01057ab:	7d 28                	jge    f01057d5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01057ad:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01057b0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01057b3:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01057b8:	39 f2                	cmp    %esi,%edx
f01057ba:	74 19                	je     f01057d5 <stab_binsearch+0x105>
f01057bc:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01057c0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01057c4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01057c7:	39 c1                	cmp    %eax,%ecx
f01057c9:	7d 0a                	jge    f01057d5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01057cb:	0f b6 1a             	movzbl (%edx),%ebx
f01057ce:	83 ea 0c             	sub    $0xc,%edx
f01057d1:	39 f3                	cmp    %esi,%ebx
f01057d3:	75 ef                	jne    f01057c4 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01057d5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01057d8:	89 02                	mov    %eax,(%edx)
f01057da:	eb 1a                	jmp    f01057f6 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01057dc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01057de:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01057e1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01057e4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01057e8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01057eb:	0f 82 54 ff ff ff    	jb     f0105745 <stab_binsearch+0x75>
f01057f1:	e9 60 ff ff ff       	jmp    f0105756 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01057f6:	83 c4 14             	add    $0x14,%esp
f01057f9:	5b                   	pop    %ebx
f01057fa:	5e                   	pop    %esi
f01057fb:	5f                   	pop    %edi
f01057fc:	5d                   	pop    %ebp
f01057fd:	c3                   	ret    

f01057fe <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01057fe:	55                   	push   %ebp
f01057ff:	89 e5                	mov    %esp,%ebp
f0105801:	57                   	push   %edi
f0105802:	56                   	push   %esi
f0105803:	53                   	push   %ebx
f0105804:	83 ec 5c             	sub    $0x5c,%esp
f0105807:	8b 75 08             	mov    0x8(%ebp),%esi
f010580a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010580d:	c7 03 f8 8b 10 f0    	movl   $0xf0108bf8,(%ebx)
	info->eip_line = 0;
f0105813:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010581a:	c7 43 08 f8 8b 10 f0 	movl   $0xf0108bf8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105821:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105828:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010582b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105832:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105838:	0f 87 d8 00 00 00    	ja     f0105916 <debuginfo_eip+0x118>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010583e:	e8 0d 13 00 00       	call   f0106b50 <cpunum>
f0105843:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010584a:	00 
f010584b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105852:	00 
f0105853:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010585a:	00 
f010585b:	6b c0 74             	imul   $0x74,%eax,%eax
f010585e:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105864:	89 04 24             	mov    %eax,(%esp)
f0105867:	e8 10 e3 ff ff       	call   f0103b7c <user_mem_check>
f010586c:	89 c2                	mov    %eax,%edx
			return -1;
f010586e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0105873:	85 d2                	test   %edx,%edx
f0105875:	0f 85 a5 02 00 00    	jne    f0105b20 <debuginfo_eip+0x322>
			return -1;

		stabs = usd->stabs;
f010587b:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105881:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105884:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010588a:	a1 08 00 20 00       	mov    0x200008,%eax
f010588f:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105892:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105898:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010589b:	e8 b0 12 00 00       	call   f0106b50 <cpunum>
f01058a0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01058a7:	00 
f01058a8:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01058af:	00 
f01058b0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01058b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01058b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01058ba:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01058c0:	89 04 24             	mov    %eax,(%esp)
f01058c3:	e8 b4 e2 ff ff       	call   f0103b7c <user_mem_check>
f01058c8:	89 c2                	mov    %eax,%edx
			return -1;
f01058ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01058cf:	85 d2                	test   %edx,%edx
f01058d1:	0f 85 49 02 00 00    	jne    f0105b20 <debuginfo_eip+0x322>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f01058d7:	e8 74 12 00 00       	call   f0106b50 <cpunum>
f01058dc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01058e3:	00 
f01058e4:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01058e7:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01058ea:	89 54 24 08          	mov    %edx,0x8(%esp)
f01058ee:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01058f1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01058f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01058f8:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01058fe:	89 04 24             	mov    %eax,(%esp)
f0105901:	e8 76 e2 ff ff       	call   f0103b7c <user_mem_check>
f0105906:	89 c2                	mov    %eax,%edx
			return -1;
f0105908:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010590d:	85 d2                	test   %edx,%edx
f010590f:	74 1f                	je     f0105930 <debuginfo_eip+0x132>
f0105911:	e9 0a 02 00 00       	jmp    f0105b20 <debuginfo_eip+0x322>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105916:	c7 45 c0 81 81 11 f0 	movl   $0xf0118181,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010591d:	c7 45 bc 19 48 11 f0 	movl   $0xf0114819,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105924:	bf 18 48 11 f0       	mov    $0xf0114818,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105929:	c7 45 c4 f4 90 10 f0 	movl   $0xf01090f4,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105930:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105935:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105938:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f010593b:	0f 83 df 01 00 00    	jae    f0105b20 <debuginfo_eip+0x322>
f0105941:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0105945:	0f 85 d5 01 00 00    	jne    f0105b20 <debuginfo_eip+0x322>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010594b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105952:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105955:	c1 ff 02             	sar    $0x2,%edi
f0105958:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f010595e:	83 e8 01             	sub    $0x1,%eax
f0105961:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105964:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105968:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010596f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105972:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105975:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105978:	e8 53 fd ff ff       	call   f01056d0 <stab_binsearch>
	if (lfile == 0)
f010597d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0105980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0105985:	85 d2                	test   %edx,%edx
f0105987:	0f 84 93 01 00 00    	je     f0105b20 <debuginfo_eip+0x322>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010598d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0105990:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105993:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105996:	89 74 24 04          	mov    %esi,0x4(%esp)
f010599a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01059a1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01059a4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01059a7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01059aa:	e8 21 fd ff ff       	call   f01056d0 <stab_binsearch>

	if (lfun <= rfun) {
f01059af:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01059b5:	39 d0                	cmp    %edx,%eax
f01059b7:	7f 32                	jg     f01059eb <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01059b9:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01059bc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01059bf:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01059c2:	8b 39                	mov    (%ecx),%edi
f01059c4:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01059c7:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01059ca:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01059cd:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01059d0:	73 09                	jae    f01059db <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01059d2:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01059d5:	03 7d bc             	add    -0x44(%ebp),%edi
f01059d8:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01059db:	8b 49 08             	mov    0x8(%ecx),%ecx
f01059de:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01059e1:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01059e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01059e6:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01059e9:	eb 0f                	jmp    f01059fa <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01059eb:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01059ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01059f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01059fa:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105a01:	00 
f0105a02:	8b 43 08             	mov    0x8(%ebx),%eax
f0105a05:	89 04 24             	mov    %eax,(%esp)
f0105a08:	e8 8d 0a 00 00       	call   f010649a <strfind>
f0105a0d:	2b 43 08             	sub    0x8(%ebx),%eax
f0105a10:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105a13:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a17:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105a1e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105a21:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105a24:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105a27:	e8 a4 fc ff ff       	call   f01056d0 <stab_binsearch>

	if(lline <= rline)
f0105a2c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0105a2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f0105a34:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105a37:	0f 8f e3 00 00 00    	jg     f0105b20 <debuginfo_eip+0x322>
		info->eip_line = stabs[lline].n_desc;
f0105a3d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105a40:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105a43:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105a48:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105a4b:	89 d0                	mov    %edx,%eax
f0105a4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a50:	89 7d b8             	mov    %edi,-0x48(%ebp)
f0105a53:	39 fa                	cmp    %edi,%edx
f0105a55:	7c 74                	jl     f0105acb <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f0105a57:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105a5a:	89 f7                	mov    %esi,%edi
f0105a5c:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0105a5f:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f0105a63:	80 f9 84             	cmp    $0x84,%cl
f0105a66:	74 46                	je     f0105aae <debuginfo_eip+0x2b0>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105a68:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0105a6c:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105a6f:	89 c7                	mov    %eax,%edi
f0105a71:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0105a74:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105a77:	eb 1f                	jmp    f0105a98 <debuginfo_eip+0x29a>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105a79:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105a7c:	39 c3                	cmp    %eax,%ebx
f0105a7e:	7f 48                	jg     f0105ac8 <debuginfo_eip+0x2ca>
	       && stabs[lline].n_type != N_SOL
f0105a80:	89 d6                	mov    %edx,%esi
f0105a82:	83 ea 0c             	sub    $0xc,%edx
f0105a85:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f0105a89:	80 f9 84             	cmp    $0x84,%cl
f0105a8c:	75 08                	jne    f0105a96 <debuginfo_eip+0x298>
f0105a8e:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105a91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105a94:	eb 18                	jmp    f0105aae <debuginfo_eip+0x2b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105a96:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105a98:	80 f9 64             	cmp    $0x64,%cl
f0105a9b:	75 dc                	jne    f0105a79 <debuginfo_eip+0x27b>
f0105a9d:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105aa1:	74 d6                	je     f0105a79 <debuginfo_eip+0x27b>
f0105aa3:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105aa6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105aa9:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f0105aac:	7c 1d                	jl     f0105acb <debuginfo_eip+0x2cd>
f0105aae:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105ab1:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105ab4:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105ab7:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105aba:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105abd:	39 d0                	cmp    %edx,%eax
f0105abf:	73 0a                	jae    f0105acb <debuginfo_eip+0x2cd>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105ac1:	03 45 bc             	add    -0x44(%ebp),%eax
f0105ac4:	89 03                	mov    %eax,(%ebx)
f0105ac6:	eb 03                	jmp    f0105acb <debuginfo_eip+0x2cd>
f0105ac8:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105acb:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105ace:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105ad1:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105ad4:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105ad9:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f0105adc:	7d 42                	jge    f0105b20 <debuginfo_eip+0x322>
		for (lline = lfun + 1;
f0105ade:	8d 57 01             	lea    0x1(%edi),%edx
f0105ae1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105ae4:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0105ae7:	7e 37                	jle    f0105b20 <debuginfo_eip+0x322>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105ae9:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0105aec:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105aef:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f0105af4:	75 2a                	jne    f0105b20 <debuginfo_eip+0x322>
f0105af6:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105af9:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f0105afd:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105b00:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105b04:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105b07:	39 d1                	cmp    %edx,%ecx
f0105b09:	7e 10                	jle    f0105b1b <debuginfo_eip+0x31d>
f0105b0b:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105b0e:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0105b12:	74 ec                	je     f0105b00 <debuginfo_eip+0x302>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105b14:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b19:	eb 05                	jmp    f0105b20 <debuginfo_eip+0x322>
f0105b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b20:	83 c4 5c             	add    $0x5c,%esp
f0105b23:	5b                   	pop    %ebx
f0105b24:	5e                   	pop    %esi
f0105b25:	5f                   	pop    %edi
f0105b26:	5d                   	pop    %ebp
f0105b27:	c3                   	ret    

f0105b28 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105b28:	55                   	push   %ebp
f0105b29:	89 e5                	mov    %esp,%ebp
f0105b2b:	57                   	push   %edi
f0105b2c:	56                   	push   %esi
f0105b2d:	53                   	push   %ebx
f0105b2e:	83 ec 3c             	sub    $0x3c,%esp
f0105b31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b34:	89 d7                	mov    %edx,%edi
f0105b36:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b39:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105b42:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105b45:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105b48:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b4d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105b50:	72 11                	jb     f0105b63 <printnum+0x3b>
f0105b52:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b55:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105b58:	76 09                	jbe    f0105b63 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105b5a:	83 eb 01             	sub    $0x1,%ebx
f0105b5d:	85 db                	test   %ebx,%ebx
f0105b5f:	7f 51                	jg     f0105bb2 <printnum+0x8a>
f0105b61:	eb 5e                	jmp    f0105bc1 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105b63:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105b67:	83 eb 01             	sub    $0x1,%ebx
f0105b6a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105b6e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b71:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b75:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105b79:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105b7d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105b84:	00 
f0105b85:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b88:	89 04 24             	mov    %eax,(%esp)
f0105b8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b92:	e8 49 14 00 00       	call   f0106fe0 <__udivdi3>
f0105b97:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105b9b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105b9f:	89 04 24             	mov    %eax,(%esp)
f0105ba2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ba6:	89 fa                	mov    %edi,%edx
f0105ba8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bab:	e8 78 ff ff ff       	call   f0105b28 <printnum>
f0105bb0:	eb 0f                	jmp    f0105bc1 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105bb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bb6:	89 34 24             	mov    %esi,(%esp)
f0105bb9:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105bbc:	83 eb 01             	sub    $0x1,%ebx
f0105bbf:	75 f1                	jne    f0105bb2 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105bc1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bc5:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105bc9:	8b 45 10             	mov    0x10(%ebp),%eax
f0105bcc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bd0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105bd7:	00 
f0105bd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105bdb:	89 04 24             	mov    %eax,(%esp)
f0105bde:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105be1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105be5:	e8 26 15 00 00       	call   f0107110 <__umoddi3>
f0105bea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bee:	0f be 80 02 8c 10 f0 	movsbl -0xfef73fe(%eax),%eax
f0105bf5:	89 04 24             	mov    %eax,(%esp)
f0105bf8:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105bfb:	83 c4 3c             	add    $0x3c,%esp
f0105bfe:	5b                   	pop    %ebx
f0105bff:	5e                   	pop    %esi
f0105c00:	5f                   	pop    %edi
f0105c01:	5d                   	pop    %ebp
f0105c02:	c3                   	ret    

f0105c03 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105c03:	55                   	push   %ebp
f0105c04:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105c06:	83 fa 01             	cmp    $0x1,%edx
f0105c09:	7e 0e                	jle    f0105c19 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105c0b:	8b 10                	mov    (%eax),%edx
f0105c0d:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105c10:	89 08                	mov    %ecx,(%eax)
f0105c12:	8b 02                	mov    (%edx),%eax
f0105c14:	8b 52 04             	mov    0x4(%edx),%edx
f0105c17:	eb 22                	jmp    f0105c3b <getuint+0x38>
	else if (lflag)
f0105c19:	85 d2                	test   %edx,%edx
f0105c1b:	74 10                	je     f0105c2d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105c1d:	8b 10                	mov    (%eax),%edx
f0105c1f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c22:	89 08                	mov    %ecx,(%eax)
f0105c24:	8b 02                	mov    (%edx),%eax
f0105c26:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c2b:	eb 0e                	jmp    f0105c3b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105c2d:	8b 10                	mov    (%eax),%edx
f0105c2f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c32:	89 08                	mov    %ecx,(%eax)
f0105c34:	8b 02                	mov    (%edx),%eax
f0105c36:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105c3b:	5d                   	pop    %ebp
f0105c3c:	c3                   	ret    

f0105c3d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105c3d:	55                   	push   %ebp
f0105c3e:	89 e5                	mov    %esp,%ebp
f0105c40:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105c43:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105c47:	8b 10                	mov    (%eax),%edx
f0105c49:	3b 50 04             	cmp    0x4(%eax),%edx
f0105c4c:	73 0a                	jae    f0105c58 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c51:	88 0a                	mov    %cl,(%edx)
f0105c53:	83 c2 01             	add    $0x1,%edx
f0105c56:	89 10                	mov    %edx,(%eax)
}
f0105c58:	5d                   	pop    %ebp
f0105c59:	c3                   	ret    

f0105c5a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105c5a:	55                   	push   %ebp
f0105c5b:	89 e5                	mov    %esp,%ebp
f0105c5d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105c60:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105c63:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c67:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c6a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c75:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c78:	89 04 24             	mov    %eax,(%esp)
f0105c7b:	e8 02 00 00 00       	call   f0105c82 <vprintfmt>
	va_end(ap);
}
f0105c80:	c9                   	leave  
f0105c81:	c3                   	ret    

f0105c82 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105c82:	55                   	push   %ebp
f0105c83:	89 e5                	mov    %esp,%ebp
f0105c85:	57                   	push   %edi
f0105c86:	56                   	push   %esi
f0105c87:	53                   	push   %ebx
f0105c88:	83 ec 5c             	sub    $0x5c,%esp
f0105c8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105c8e:	8b 75 10             	mov    0x10(%ebp),%esi
f0105c91:	eb 12                	jmp    f0105ca5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105c93:	85 c0                	test   %eax,%eax
f0105c95:	0f 84 e4 04 00 00    	je     f010617f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f0105c9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c9f:	89 04 24             	mov    %eax,(%esp)
f0105ca2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105ca5:	0f b6 06             	movzbl (%esi),%eax
f0105ca8:	83 c6 01             	add    $0x1,%esi
f0105cab:	83 f8 25             	cmp    $0x25,%eax
f0105cae:	75 e3                	jne    f0105c93 <vprintfmt+0x11>
f0105cb0:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0105cb4:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0105cbb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105cc0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0105cc7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105ccc:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105ccf:	eb 2b                	jmp    f0105cfc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cd1:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105cd4:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0105cd8:	eb 22                	jmp    f0105cfc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cda:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105cdd:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0105ce1:	eb 19                	jmp    f0105cfc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ce3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105ce6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105ced:	eb 0d                	jmp    f0105cfc <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105cef:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105cf2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105cf5:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cfc:	0f b6 06             	movzbl (%esi),%eax
f0105cff:	0f b6 d0             	movzbl %al,%edx
f0105d02:	8d 7e 01             	lea    0x1(%esi),%edi
f0105d05:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105d08:	83 e8 23             	sub    $0x23,%eax
f0105d0b:	3c 55                	cmp    $0x55,%al
f0105d0d:	0f 87 46 04 00 00    	ja     f0106159 <vprintfmt+0x4d7>
f0105d13:	0f b6 c0             	movzbl %al,%eax
f0105d16:	ff 24 85 e0 8c 10 f0 	jmp    *-0xfef7320(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105d1d:	83 ea 30             	sub    $0x30,%edx
f0105d20:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0105d23:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105d27:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d2a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0105d2d:	83 fa 09             	cmp    $0x9,%edx
f0105d30:	77 4a                	ja     f0105d7c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d32:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105d35:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105d38:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105d3b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105d3f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105d42:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105d45:	83 fa 09             	cmp    $0x9,%edx
f0105d48:	76 eb                	jbe    f0105d35 <vprintfmt+0xb3>
f0105d4a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105d4d:	eb 2d                	jmp    f0105d7c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105d4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d52:	8d 50 04             	lea    0x4(%eax),%edx
f0105d55:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d58:	8b 00                	mov    (%eax),%eax
f0105d5a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d5d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105d60:	eb 1a                	jmp    f0105d7c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d62:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0105d65:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105d69:	79 91                	jns    f0105cfc <vprintfmt+0x7a>
f0105d6b:	e9 73 ff ff ff       	jmp    f0105ce3 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d70:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105d73:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f0105d7a:	eb 80                	jmp    f0105cfc <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0105d7c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105d80:	0f 89 76 ff ff ff    	jns    f0105cfc <vprintfmt+0x7a>
f0105d86:	e9 64 ff ff ff       	jmp    f0105cef <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105d8b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d8e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105d91:	e9 66 ff ff ff       	jmp    f0105cfc <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105d96:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d99:	8d 50 04             	lea    0x4(%eax),%edx
f0105d9c:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105da3:	8b 00                	mov    (%eax),%eax
f0105da5:	89 04 24             	mov    %eax,(%esp)
f0105da8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105dab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105dae:	e9 f2 fe ff ff       	jmp    f0105ca5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0105db3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105db7:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f0105dba:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f0105dbe:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0105dc1:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0105dc5:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0105dc8:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0105dcb:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f0105dcf:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105dd2:	80 f9 09             	cmp    $0x9,%cl
f0105dd5:	77 1d                	ja     f0105df4 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0105dd7:	0f be c0             	movsbl %al,%eax
f0105dda:	6b c0 64             	imul   $0x64,%eax,%eax
f0105ddd:	0f be d2             	movsbl %dl,%edx
f0105de0:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105de3:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0105dea:	a3 78 34 12 f0       	mov    %eax,0xf0123478
f0105def:	e9 b1 fe ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0105df4:	c7 44 24 04 1a 8c 10 	movl   $0xf0108c1a,0x4(%esp)
f0105dfb:	f0 
f0105dfc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105dff:	89 04 24             	mov    %eax,(%esp)
f0105e02:	e8 e4 05 00 00       	call   f01063eb <strcmp>
f0105e07:	85 c0                	test   %eax,%eax
f0105e09:	75 0f                	jne    f0105e1a <vprintfmt+0x198>
f0105e0b:	c7 05 78 34 12 f0 04 	movl   $0x4,0xf0123478
f0105e12:	00 00 00 
f0105e15:	e9 8b fe ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0105e1a:	c7 44 24 04 1e 8c 10 	movl   $0xf0108c1e,0x4(%esp)
f0105e21:	f0 
f0105e22:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105e25:	89 14 24             	mov    %edx,(%esp)
f0105e28:	e8 be 05 00 00       	call   f01063eb <strcmp>
f0105e2d:	85 c0                	test   %eax,%eax
f0105e2f:	75 0f                	jne    f0105e40 <vprintfmt+0x1be>
f0105e31:	c7 05 78 34 12 f0 02 	movl   $0x2,0xf0123478
f0105e38:	00 00 00 
f0105e3b:	e9 65 fe ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0105e40:	c7 44 24 04 22 8c 10 	movl   $0xf0108c22,0x4(%esp)
f0105e47:	f0 
f0105e48:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0105e4b:	89 0c 24             	mov    %ecx,(%esp)
f0105e4e:	e8 98 05 00 00       	call   f01063eb <strcmp>
f0105e53:	85 c0                	test   %eax,%eax
f0105e55:	75 0f                	jne    f0105e66 <vprintfmt+0x1e4>
f0105e57:	c7 05 78 34 12 f0 01 	movl   $0x1,0xf0123478
f0105e5e:	00 00 00 
f0105e61:	e9 3f fe ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f0105e66:	c7 44 24 04 26 8c 10 	movl   $0xf0108c26,0x4(%esp)
f0105e6d:	f0 
f0105e6e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0105e71:	89 3c 24             	mov    %edi,(%esp)
f0105e74:	e8 72 05 00 00       	call   f01063eb <strcmp>
f0105e79:	85 c0                	test   %eax,%eax
f0105e7b:	75 0f                	jne    f0105e8c <vprintfmt+0x20a>
f0105e7d:	c7 05 78 34 12 f0 06 	movl   $0x6,0xf0123478
f0105e84:	00 00 00 
f0105e87:	e9 19 fe ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f0105e8c:	c7 44 24 04 2a 8c 10 	movl   $0xf0108c2a,0x4(%esp)
f0105e93:	f0 
f0105e94:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105e97:	89 04 24             	mov    %eax,(%esp)
f0105e9a:	e8 4c 05 00 00       	call   f01063eb <strcmp>
f0105e9f:	85 c0                	test   %eax,%eax
f0105ea1:	75 0f                	jne    f0105eb2 <vprintfmt+0x230>
f0105ea3:	c7 05 78 34 12 f0 07 	movl   $0x7,0xf0123478
f0105eaa:	00 00 00 
f0105ead:	e9 f3 fd ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0105eb2:	c7 44 24 04 2e 8c 10 	movl   $0xf0108c2e,0x4(%esp)
f0105eb9:	f0 
f0105eba:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105ebd:	89 14 24             	mov    %edx,(%esp)
f0105ec0:	e8 26 05 00 00       	call   f01063eb <strcmp>
f0105ec5:	83 f8 01             	cmp    $0x1,%eax
f0105ec8:	19 c0                	sbb    %eax,%eax
f0105eca:	f7 d0                	not    %eax
f0105ecc:	83 c0 08             	add    $0x8,%eax
f0105ecf:	a3 78 34 12 f0       	mov    %eax,0xf0123478
f0105ed4:	e9 cc fd ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0105ed9:	8b 45 14             	mov    0x14(%ebp),%eax
f0105edc:	8d 50 04             	lea    0x4(%eax),%edx
f0105edf:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ee2:	8b 00                	mov    (%eax),%eax
f0105ee4:	89 c2                	mov    %eax,%edx
f0105ee6:	c1 fa 1f             	sar    $0x1f,%edx
f0105ee9:	31 d0                	xor    %edx,%eax
f0105eeb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105eed:	83 f8 08             	cmp    $0x8,%eax
f0105ef0:	7f 0b                	jg     f0105efd <vprintfmt+0x27b>
f0105ef2:	8b 14 85 40 8e 10 f0 	mov    -0xfef71c0(,%eax,4),%edx
f0105ef9:	85 d2                	test   %edx,%edx
f0105efb:	75 23                	jne    f0105f20 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0105efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f01:	c7 44 24 08 32 8c 10 	movl   $0xf0108c32,0x8(%esp)
f0105f08:	f0 
f0105f09:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f0d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f10:	89 3c 24             	mov    %edi,(%esp)
f0105f13:	e8 42 fd ff ff       	call   f0105c5a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f18:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105f1b:	e9 85 fd ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105f20:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f24:	c7 44 24 08 3d 84 10 	movl   $0xf010843d,0x8(%esp)
f0105f2b:	f0 
f0105f2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f30:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f33:	89 3c 24             	mov    %edi,(%esp)
f0105f36:	e8 1f fd ff ff       	call   f0105c5a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f3b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105f3e:	e9 62 fd ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
f0105f43:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105f46:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105f49:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105f4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f4f:	8d 50 04             	lea    0x4(%eax),%edx
f0105f52:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f55:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105f57:	85 f6                	test   %esi,%esi
f0105f59:	b8 13 8c 10 f0       	mov    $0xf0108c13,%eax
f0105f5e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105f61:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0105f65:	7e 06                	jle    f0105f6d <vprintfmt+0x2eb>
f0105f67:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0105f6b:	75 13                	jne    f0105f80 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105f6d:	0f be 06             	movsbl (%esi),%eax
f0105f70:	83 c6 01             	add    $0x1,%esi
f0105f73:	85 c0                	test   %eax,%eax
f0105f75:	0f 85 94 00 00 00    	jne    f010600f <vprintfmt+0x38d>
f0105f7b:	e9 81 00 00 00       	jmp    f0106001 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105f80:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f84:	89 34 24             	mov    %esi,(%esp)
f0105f87:	e8 6f 03 00 00       	call   f01062fb <strnlen>
f0105f8c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105f8f:	29 c2                	sub    %eax,%edx
f0105f91:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0105f94:	85 d2                	test   %edx,%edx
f0105f96:	7e d5                	jle    f0105f6d <vprintfmt+0x2eb>
					putch(padc, putdat);
f0105f98:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0105f9c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105f9f:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0105fa2:	89 d6                	mov    %edx,%esi
f0105fa4:	89 cf                	mov    %ecx,%edi
f0105fa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105faa:	89 3c 24             	mov    %edi,(%esp)
f0105fad:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105fb0:	83 ee 01             	sub    $0x1,%esi
f0105fb3:	75 f1                	jne    f0105fa6 <vprintfmt+0x324>
f0105fb5:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105fb8:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0105fbb:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105fbe:	eb ad                	jmp    f0105f6d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105fc0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0105fc4:	74 1b                	je     f0105fe1 <vprintfmt+0x35f>
f0105fc6:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105fc9:	83 fa 5e             	cmp    $0x5e,%edx
f0105fcc:	76 13                	jbe    f0105fe1 <vprintfmt+0x35f>
					putch('?', putdat);
f0105fce:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fd5:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105fdc:	ff 55 08             	call   *0x8(%ebp)
f0105fdf:	eb 0d                	jmp    f0105fee <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0105fe1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105fe4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105fe8:	89 04 24             	mov    %eax,(%esp)
f0105feb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105fee:	83 eb 01             	sub    $0x1,%ebx
f0105ff1:	0f be 06             	movsbl (%esi),%eax
f0105ff4:	83 c6 01             	add    $0x1,%esi
f0105ff7:	85 c0                	test   %eax,%eax
f0105ff9:	75 1a                	jne    f0106015 <vprintfmt+0x393>
f0105ffb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0105ffe:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106001:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106004:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0106008:	7f 1c                	jg     f0106026 <vprintfmt+0x3a4>
f010600a:	e9 96 fc ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
f010600f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0106012:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106015:	85 ff                	test   %edi,%edi
f0106017:	78 a7                	js     f0105fc0 <vprintfmt+0x33e>
f0106019:	83 ef 01             	sub    $0x1,%edi
f010601c:	79 a2                	jns    f0105fc0 <vprintfmt+0x33e>
f010601e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0106021:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106024:	eb db                	jmp    f0106001 <vprintfmt+0x37f>
f0106026:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106029:	89 de                	mov    %ebx,%esi
f010602b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010602e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106032:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106039:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010603b:	83 eb 01             	sub    $0x1,%ebx
f010603e:	75 ee                	jne    f010602e <vprintfmt+0x3ac>
f0106040:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106042:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0106045:	e9 5b fc ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010604a:	83 f9 01             	cmp    $0x1,%ecx
f010604d:	7e 10                	jle    f010605f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f010604f:	8b 45 14             	mov    0x14(%ebp),%eax
f0106052:	8d 50 08             	lea    0x8(%eax),%edx
f0106055:	89 55 14             	mov    %edx,0x14(%ebp)
f0106058:	8b 30                	mov    (%eax),%esi
f010605a:	8b 78 04             	mov    0x4(%eax),%edi
f010605d:	eb 26                	jmp    f0106085 <vprintfmt+0x403>
	else if (lflag)
f010605f:	85 c9                	test   %ecx,%ecx
f0106061:	74 12                	je     f0106075 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f0106063:	8b 45 14             	mov    0x14(%ebp),%eax
f0106066:	8d 50 04             	lea    0x4(%eax),%edx
f0106069:	89 55 14             	mov    %edx,0x14(%ebp)
f010606c:	8b 30                	mov    (%eax),%esi
f010606e:	89 f7                	mov    %esi,%edi
f0106070:	c1 ff 1f             	sar    $0x1f,%edi
f0106073:	eb 10                	jmp    f0106085 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f0106075:	8b 45 14             	mov    0x14(%ebp),%eax
f0106078:	8d 50 04             	lea    0x4(%eax),%edx
f010607b:	89 55 14             	mov    %edx,0x14(%ebp)
f010607e:	8b 30                	mov    (%eax),%esi
f0106080:	89 f7                	mov    %esi,%edi
f0106082:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0106085:	85 ff                	test   %edi,%edi
f0106087:	78 0e                	js     f0106097 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0106089:	89 f0                	mov    %esi,%eax
f010608b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010608d:	be 0a 00 00 00       	mov    $0xa,%esi
f0106092:	e9 84 00 00 00       	jmp    f010611b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0106097:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010609b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01060a2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01060a5:	89 f0                	mov    %esi,%eax
f01060a7:	89 fa                	mov    %edi,%edx
f01060a9:	f7 d8                	neg    %eax
f01060ab:	83 d2 00             	adc    $0x0,%edx
f01060ae:	f7 da                	neg    %edx
			}
			base = 10;
f01060b0:	be 0a 00 00 00       	mov    $0xa,%esi
f01060b5:	eb 64                	jmp    f010611b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01060b7:	89 ca                	mov    %ecx,%edx
f01060b9:	8d 45 14             	lea    0x14(%ebp),%eax
f01060bc:	e8 42 fb ff ff       	call   f0105c03 <getuint>
			base = 10;
f01060c1:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f01060c6:	eb 53                	jmp    f010611b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01060c8:	89 ca                	mov    %ecx,%edx
f01060ca:	8d 45 14             	lea    0x14(%ebp),%eax
f01060cd:	e8 31 fb ff ff       	call   f0105c03 <getuint>
    			base = 8;
f01060d2:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f01060d7:	eb 42                	jmp    f010611b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f01060d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060dd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01060e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01060e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060eb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01060f2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01060f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01060f8:	8d 50 04             	lea    0x4(%eax),%edx
f01060fb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01060fe:	8b 00                	mov    (%eax),%eax
f0106100:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0106105:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f010610a:	eb 0f                	jmp    f010611b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010610c:	89 ca                	mov    %ecx,%edx
f010610e:	8d 45 14             	lea    0x14(%ebp),%eax
f0106111:	e8 ed fa ff ff       	call   f0105c03 <getuint>
			base = 16;
f0106116:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f010611b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f010611f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106123:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0106126:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010612a:	89 74 24 08          	mov    %esi,0x8(%esp)
f010612e:	89 04 24             	mov    %eax,(%esp)
f0106131:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106135:	89 da                	mov    %ebx,%edx
f0106137:	8b 45 08             	mov    0x8(%ebp),%eax
f010613a:	e8 e9 f9 ff ff       	call   f0105b28 <printnum>
			break;
f010613f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0106142:	e9 5e fb ff ff       	jmp    f0105ca5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0106147:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010614b:	89 14 24             	mov    %edx,(%esp)
f010614e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106151:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0106154:	e9 4c fb ff ff       	jmp    f0105ca5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0106159:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010615d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106164:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106167:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010616b:	0f 84 34 fb ff ff    	je     f0105ca5 <vprintfmt+0x23>
f0106171:	83 ee 01             	sub    $0x1,%esi
f0106174:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0106178:	75 f7                	jne    f0106171 <vprintfmt+0x4ef>
f010617a:	e9 26 fb ff ff       	jmp    f0105ca5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f010617f:	83 c4 5c             	add    $0x5c,%esp
f0106182:	5b                   	pop    %ebx
f0106183:	5e                   	pop    %esi
f0106184:	5f                   	pop    %edi
f0106185:	5d                   	pop    %ebp
f0106186:	c3                   	ret    

f0106187 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0106187:	55                   	push   %ebp
f0106188:	89 e5                	mov    %esp,%ebp
f010618a:	83 ec 28             	sub    $0x28,%esp
f010618d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106190:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0106193:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106196:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010619a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010619d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01061a4:	85 c0                	test   %eax,%eax
f01061a6:	74 30                	je     f01061d8 <vsnprintf+0x51>
f01061a8:	85 d2                	test   %edx,%edx
f01061aa:	7e 2c                	jle    f01061d8 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01061ac:	8b 45 14             	mov    0x14(%ebp),%eax
f01061af:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061b3:	8b 45 10             	mov    0x10(%ebp),%eax
f01061b6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01061bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061c1:	c7 04 24 3d 5c 10 f0 	movl   $0xf0105c3d,(%esp)
f01061c8:	e8 b5 fa ff ff       	call   f0105c82 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01061cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01061d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01061d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01061d6:	eb 05                	jmp    f01061dd <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01061d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01061dd:	c9                   	leave  
f01061de:	c3                   	ret    

f01061df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01061df:	55                   	push   %ebp
f01061e0:	89 e5                	mov    %esp,%ebp
f01061e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01061e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01061e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061ec:	8b 45 10             	mov    0x10(%ebp),%eax
f01061ef:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01061f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01061fd:	89 04 24             	mov    %eax,(%esp)
f0106200:	e8 82 ff ff ff       	call   f0106187 <vsnprintf>
	va_end(ap);

	return rc;
}
f0106205:	c9                   	leave  
f0106206:	c3                   	ret    
	...

f0106210 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106210:	55                   	push   %ebp
f0106211:	89 e5                	mov    %esp,%ebp
f0106213:	57                   	push   %edi
f0106214:	56                   	push   %esi
f0106215:	53                   	push   %ebx
f0106216:	83 ec 1c             	sub    $0x1c,%esp
f0106219:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010621c:	85 c0                	test   %eax,%eax
f010621e:	74 10                	je     f0106230 <readline+0x20>
		cprintf("%s", prompt);
f0106220:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106224:	c7 04 24 3d 84 10 f0 	movl   $0xf010843d,(%esp)
f010622b:	e8 be e3 ff ff       	call   f01045ee <cprintf>

	i = 0;
	echoing = iscons(0);
f0106230:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106237:	e8 7e a5 ff ff       	call   f01007ba <iscons>
f010623c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010623e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0106243:	e8 61 a5 ff ff       	call   f01007a9 <getchar>
f0106248:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010624a:	85 c0                	test   %eax,%eax
f010624c:	79 17                	jns    f0106265 <readline+0x55>
			cprintf("read error: %e\n", c);
f010624e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106252:	c7 04 24 64 8e 10 f0 	movl   $0xf0108e64,(%esp)
f0106259:	e8 90 e3 ff ff       	call   f01045ee <cprintf>
			return NULL;
f010625e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106263:	eb 6d                	jmp    f01062d2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106265:	83 f8 08             	cmp    $0x8,%eax
f0106268:	74 05                	je     f010626f <readline+0x5f>
f010626a:	83 f8 7f             	cmp    $0x7f,%eax
f010626d:	75 19                	jne    f0106288 <readline+0x78>
f010626f:	85 f6                	test   %esi,%esi
f0106271:	7e 15                	jle    f0106288 <readline+0x78>
			if (echoing)
f0106273:	85 ff                	test   %edi,%edi
f0106275:	74 0c                	je     f0106283 <readline+0x73>
				cputchar('\b');
f0106277:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010627e:	e8 16 a5 ff ff       	call   f0100799 <cputchar>
			i--;
f0106283:	83 ee 01             	sub    $0x1,%esi
f0106286:	eb bb                	jmp    f0106243 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106288:	83 fb 1f             	cmp    $0x1f,%ebx
f010628b:	7e 1f                	jle    f01062ac <readline+0x9c>
f010628d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106293:	7f 17                	jg     f01062ac <readline+0x9c>
			if (echoing)
f0106295:	85 ff                	test   %edi,%edi
f0106297:	74 08                	je     f01062a1 <readline+0x91>
				cputchar(c);
f0106299:	89 1c 24             	mov    %ebx,(%esp)
f010629c:	e8 f8 a4 ff ff       	call   f0100799 <cputchar>
			buf[i++] = c;
f01062a1:	88 9e 80 ca 22 f0    	mov    %bl,-0xfdd3580(%esi)
f01062a7:	83 c6 01             	add    $0x1,%esi
f01062aa:	eb 97                	jmp    f0106243 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01062ac:	83 fb 0a             	cmp    $0xa,%ebx
f01062af:	74 05                	je     f01062b6 <readline+0xa6>
f01062b1:	83 fb 0d             	cmp    $0xd,%ebx
f01062b4:	75 8d                	jne    f0106243 <readline+0x33>
			if (echoing)
f01062b6:	85 ff                	test   %edi,%edi
f01062b8:	74 0c                	je     f01062c6 <readline+0xb6>
				cputchar('\n');
f01062ba:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01062c1:	e8 d3 a4 ff ff       	call   f0100799 <cputchar>
			buf[i] = 0;
f01062c6:	c6 86 80 ca 22 f0 00 	movb   $0x0,-0xfdd3580(%esi)
			return buf;
f01062cd:	b8 80 ca 22 f0       	mov    $0xf022ca80,%eax
		}
	}
}
f01062d2:	83 c4 1c             	add    $0x1c,%esp
f01062d5:	5b                   	pop    %ebx
f01062d6:	5e                   	pop    %esi
f01062d7:	5f                   	pop    %edi
f01062d8:	5d                   	pop    %ebp
f01062d9:	c3                   	ret    
f01062da:	00 00                	add    %al,(%eax)
f01062dc:	00 00                	add    %al,(%eax)
	...

f01062e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01062e0:	55                   	push   %ebp
f01062e1:	89 e5                	mov    %esp,%ebp
f01062e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01062e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01062eb:	80 3a 00             	cmpb   $0x0,(%edx)
f01062ee:	74 09                	je     f01062f9 <strlen+0x19>
		n++;
f01062f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01062f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01062f7:	75 f7                	jne    f01062f0 <strlen+0x10>
		n++;
	return n;
}
f01062f9:	5d                   	pop    %ebp
f01062fa:	c3                   	ret    

f01062fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01062fb:	55                   	push   %ebp
f01062fc:	89 e5                	mov    %esp,%ebp
f01062fe:	53                   	push   %ebx
f01062ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106305:	b8 00 00 00 00       	mov    $0x0,%eax
f010630a:	85 c9                	test   %ecx,%ecx
f010630c:	74 1a                	je     f0106328 <strnlen+0x2d>
f010630e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0106311:	74 15                	je     f0106328 <strnlen+0x2d>
f0106313:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0106318:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010631a:	39 ca                	cmp    %ecx,%edx
f010631c:	74 0a                	je     f0106328 <strnlen+0x2d>
f010631e:	83 c2 01             	add    $0x1,%edx
f0106321:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0106326:	75 f0                	jne    f0106318 <strnlen+0x1d>
		n++;
	return n;
}
f0106328:	5b                   	pop    %ebx
f0106329:	5d                   	pop    %ebp
f010632a:	c3                   	ret    

f010632b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010632b:	55                   	push   %ebp
f010632c:	89 e5                	mov    %esp,%ebp
f010632e:	53                   	push   %ebx
f010632f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106335:	ba 00 00 00 00       	mov    $0x0,%edx
f010633a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010633e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0106341:	83 c2 01             	add    $0x1,%edx
f0106344:	84 c9                	test   %cl,%cl
f0106346:	75 f2                	jne    f010633a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0106348:	5b                   	pop    %ebx
f0106349:	5d                   	pop    %ebp
f010634a:	c3                   	ret    

f010634b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010634b:	55                   	push   %ebp
f010634c:	89 e5                	mov    %esp,%ebp
f010634e:	53                   	push   %ebx
f010634f:	83 ec 08             	sub    $0x8,%esp
f0106352:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106355:	89 1c 24             	mov    %ebx,(%esp)
f0106358:	e8 83 ff ff ff       	call   f01062e0 <strlen>
	strcpy(dst + len, src);
f010635d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106360:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106364:	01 d8                	add    %ebx,%eax
f0106366:	89 04 24             	mov    %eax,(%esp)
f0106369:	e8 bd ff ff ff       	call   f010632b <strcpy>
	return dst;
}
f010636e:	89 d8                	mov    %ebx,%eax
f0106370:	83 c4 08             	add    $0x8,%esp
f0106373:	5b                   	pop    %ebx
f0106374:	5d                   	pop    %ebp
f0106375:	c3                   	ret    

f0106376 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106376:	55                   	push   %ebp
f0106377:	89 e5                	mov    %esp,%ebp
f0106379:	56                   	push   %esi
f010637a:	53                   	push   %ebx
f010637b:	8b 45 08             	mov    0x8(%ebp),%eax
f010637e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106381:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106384:	85 f6                	test   %esi,%esi
f0106386:	74 18                	je     f01063a0 <strncpy+0x2a>
f0106388:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010638d:	0f b6 1a             	movzbl (%edx),%ebx
f0106390:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106393:	80 3a 01             	cmpb   $0x1,(%edx)
f0106396:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106399:	83 c1 01             	add    $0x1,%ecx
f010639c:	39 f1                	cmp    %esi,%ecx
f010639e:	75 ed                	jne    f010638d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01063a0:	5b                   	pop    %ebx
f01063a1:	5e                   	pop    %esi
f01063a2:	5d                   	pop    %ebp
f01063a3:	c3                   	ret    

f01063a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01063a4:	55                   	push   %ebp
f01063a5:	89 e5                	mov    %esp,%ebp
f01063a7:	57                   	push   %edi
f01063a8:	56                   	push   %esi
f01063a9:	53                   	push   %ebx
f01063aa:	8b 7d 08             	mov    0x8(%ebp),%edi
f01063ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01063b0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01063b3:	89 f8                	mov    %edi,%eax
f01063b5:	85 f6                	test   %esi,%esi
f01063b7:	74 2b                	je     f01063e4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01063b9:	83 fe 01             	cmp    $0x1,%esi
f01063bc:	74 23                	je     f01063e1 <strlcpy+0x3d>
f01063be:	0f b6 0b             	movzbl (%ebx),%ecx
f01063c1:	84 c9                	test   %cl,%cl
f01063c3:	74 1c                	je     f01063e1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01063c5:	83 ee 02             	sub    $0x2,%esi
f01063c8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01063cd:	88 08                	mov    %cl,(%eax)
f01063cf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01063d2:	39 f2                	cmp    %esi,%edx
f01063d4:	74 0b                	je     f01063e1 <strlcpy+0x3d>
f01063d6:	83 c2 01             	add    $0x1,%edx
f01063d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01063dd:	84 c9                	test   %cl,%cl
f01063df:	75 ec                	jne    f01063cd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01063e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01063e4:	29 f8                	sub    %edi,%eax
}
f01063e6:	5b                   	pop    %ebx
f01063e7:	5e                   	pop    %esi
f01063e8:	5f                   	pop    %edi
f01063e9:	5d                   	pop    %ebp
f01063ea:	c3                   	ret    

f01063eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01063eb:	55                   	push   %ebp
f01063ec:	89 e5                	mov    %esp,%ebp
f01063ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01063f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01063f4:	0f b6 01             	movzbl (%ecx),%eax
f01063f7:	84 c0                	test   %al,%al
f01063f9:	74 16                	je     f0106411 <strcmp+0x26>
f01063fb:	3a 02                	cmp    (%edx),%al
f01063fd:	75 12                	jne    f0106411 <strcmp+0x26>
		p++, q++;
f01063ff:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0106402:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0106406:	84 c0                	test   %al,%al
f0106408:	74 07                	je     f0106411 <strcmp+0x26>
f010640a:	83 c1 01             	add    $0x1,%ecx
f010640d:	3a 02                	cmp    (%edx),%al
f010640f:	74 ee                	je     f01063ff <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106411:	0f b6 c0             	movzbl %al,%eax
f0106414:	0f b6 12             	movzbl (%edx),%edx
f0106417:	29 d0                	sub    %edx,%eax
}
f0106419:	5d                   	pop    %ebp
f010641a:	c3                   	ret    

f010641b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010641b:	55                   	push   %ebp
f010641c:	89 e5                	mov    %esp,%ebp
f010641e:	53                   	push   %ebx
f010641f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106422:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106425:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106428:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010642d:	85 d2                	test   %edx,%edx
f010642f:	74 28                	je     f0106459 <strncmp+0x3e>
f0106431:	0f b6 01             	movzbl (%ecx),%eax
f0106434:	84 c0                	test   %al,%al
f0106436:	74 24                	je     f010645c <strncmp+0x41>
f0106438:	3a 03                	cmp    (%ebx),%al
f010643a:	75 20                	jne    f010645c <strncmp+0x41>
f010643c:	83 ea 01             	sub    $0x1,%edx
f010643f:	74 13                	je     f0106454 <strncmp+0x39>
		n--, p++, q++;
f0106441:	83 c1 01             	add    $0x1,%ecx
f0106444:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106447:	0f b6 01             	movzbl (%ecx),%eax
f010644a:	84 c0                	test   %al,%al
f010644c:	74 0e                	je     f010645c <strncmp+0x41>
f010644e:	3a 03                	cmp    (%ebx),%al
f0106450:	74 ea                	je     f010643c <strncmp+0x21>
f0106452:	eb 08                	jmp    f010645c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106454:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106459:	5b                   	pop    %ebx
f010645a:	5d                   	pop    %ebp
f010645b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010645c:	0f b6 01             	movzbl (%ecx),%eax
f010645f:	0f b6 13             	movzbl (%ebx),%edx
f0106462:	29 d0                	sub    %edx,%eax
f0106464:	eb f3                	jmp    f0106459 <strncmp+0x3e>

f0106466 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106466:	55                   	push   %ebp
f0106467:	89 e5                	mov    %esp,%ebp
f0106469:	8b 45 08             	mov    0x8(%ebp),%eax
f010646c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106470:	0f b6 10             	movzbl (%eax),%edx
f0106473:	84 d2                	test   %dl,%dl
f0106475:	74 1c                	je     f0106493 <strchr+0x2d>
		if (*s == c)
f0106477:	38 ca                	cmp    %cl,%dl
f0106479:	75 09                	jne    f0106484 <strchr+0x1e>
f010647b:	eb 1b                	jmp    f0106498 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010647d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0106480:	38 ca                	cmp    %cl,%dl
f0106482:	74 14                	je     f0106498 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106484:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0106488:	84 d2                	test   %dl,%dl
f010648a:	75 f1                	jne    f010647d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f010648c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106491:	eb 05                	jmp    f0106498 <strchr+0x32>
f0106493:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106498:	5d                   	pop    %ebp
f0106499:	c3                   	ret    

f010649a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010649a:	55                   	push   %ebp
f010649b:	89 e5                	mov    %esp,%ebp
f010649d:	8b 45 08             	mov    0x8(%ebp),%eax
f01064a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01064a4:	0f b6 10             	movzbl (%eax),%edx
f01064a7:	84 d2                	test   %dl,%dl
f01064a9:	74 14                	je     f01064bf <strfind+0x25>
		if (*s == c)
f01064ab:	38 ca                	cmp    %cl,%dl
f01064ad:	75 06                	jne    f01064b5 <strfind+0x1b>
f01064af:	eb 0e                	jmp    f01064bf <strfind+0x25>
f01064b1:	38 ca                	cmp    %cl,%dl
f01064b3:	74 0a                	je     f01064bf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01064b5:	83 c0 01             	add    $0x1,%eax
f01064b8:	0f b6 10             	movzbl (%eax),%edx
f01064bb:	84 d2                	test   %dl,%dl
f01064bd:	75 f2                	jne    f01064b1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01064bf:	5d                   	pop    %ebp
f01064c0:	c3                   	ret    

f01064c1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01064c1:	55                   	push   %ebp
f01064c2:	89 e5                	mov    %esp,%ebp
f01064c4:	83 ec 0c             	sub    $0xc,%esp
f01064c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01064ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01064cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01064d0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01064d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01064d9:	85 c9                	test   %ecx,%ecx
f01064db:	74 30                	je     f010650d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01064dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01064e3:	75 25                	jne    f010650a <memset+0x49>
f01064e5:	f6 c1 03             	test   $0x3,%cl
f01064e8:	75 20                	jne    f010650a <memset+0x49>
		c &= 0xFF;
f01064ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01064ed:	89 d3                	mov    %edx,%ebx
f01064ef:	c1 e3 08             	shl    $0x8,%ebx
f01064f2:	89 d6                	mov    %edx,%esi
f01064f4:	c1 e6 18             	shl    $0x18,%esi
f01064f7:	89 d0                	mov    %edx,%eax
f01064f9:	c1 e0 10             	shl    $0x10,%eax
f01064fc:	09 f0                	or     %esi,%eax
f01064fe:	09 d0                	or     %edx,%eax
f0106500:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106502:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106505:	fc                   	cld    
f0106506:	f3 ab                	rep stos %eax,%es:(%edi)
f0106508:	eb 03                	jmp    f010650d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010650a:	fc                   	cld    
f010650b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010650d:	89 f8                	mov    %edi,%eax
f010650f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106512:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106515:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106518:	89 ec                	mov    %ebp,%esp
f010651a:	5d                   	pop    %ebp
f010651b:	c3                   	ret    

f010651c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010651c:	55                   	push   %ebp
f010651d:	89 e5                	mov    %esp,%ebp
f010651f:	83 ec 08             	sub    $0x8,%esp
f0106522:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106525:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106528:	8b 45 08             	mov    0x8(%ebp),%eax
f010652b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010652e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106531:	39 c6                	cmp    %eax,%esi
f0106533:	73 36                	jae    f010656b <memmove+0x4f>
f0106535:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106538:	39 d0                	cmp    %edx,%eax
f010653a:	73 2f                	jae    f010656b <memmove+0x4f>
		s += n;
		d += n;
f010653c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010653f:	f6 c2 03             	test   $0x3,%dl
f0106542:	75 1b                	jne    f010655f <memmove+0x43>
f0106544:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010654a:	75 13                	jne    f010655f <memmove+0x43>
f010654c:	f6 c1 03             	test   $0x3,%cl
f010654f:	75 0e                	jne    f010655f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106551:	83 ef 04             	sub    $0x4,%edi
f0106554:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106557:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010655a:	fd                   	std    
f010655b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010655d:	eb 09                	jmp    f0106568 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010655f:	83 ef 01             	sub    $0x1,%edi
f0106562:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106565:	fd                   	std    
f0106566:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106568:	fc                   	cld    
f0106569:	eb 20                	jmp    f010658b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010656b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106571:	75 13                	jne    f0106586 <memmove+0x6a>
f0106573:	a8 03                	test   $0x3,%al
f0106575:	75 0f                	jne    f0106586 <memmove+0x6a>
f0106577:	f6 c1 03             	test   $0x3,%cl
f010657a:	75 0a                	jne    f0106586 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010657c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010657f:	89 c7                	mov    %eax,%edi
f0106581:	fc                   	cld    
f0106582:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106584:	eb 05                	jmp    f010658b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106586:	89 c7                	mov    %eax,%edi
f0106588:	fc                   	cld    
f0106589:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010658b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010658e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106591:	89 ec                	mov    %ebp,%esp
f0106593:	5d                   	pop    %ebp
f0106594:	c3                   	ret    

f0106595 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106595:	55                   	push   %ebp
f0106596:	89 e5                	mov    %esp,%ebp
f0106598:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010659b:	8b 45 10             	mov    0x10(%ebp),%eax
f010659e:	89 44 24 08          	mov    %eax,0x8(%esp)
f01065a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01065ac:	89 04 24             	mov    %eax,(%esp)
f01065af:	e8 68 ff ff ff       	call   f010651c <memmove>
}
f01065b4:	c9                   	leave  
f01065b5:	c3                   	ret    

f01065b6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01065b6:	55                   	push   %ebp
f01065b7:	89 e5                	mov    %esp,%ebp
f01065b9:	57                   	push   %edi
f01065ba:	56                   	push   %esi
f01065bb:	53                   	push   %ebx
f01065bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01065bf:	8b 75 0c             	mov    0xc(%ebp),%esi
f01065c2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01065c5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065ca:	85 ff                	test   %edi,%edi
f01065cc:	74 37                	je     f0106605 <memcmp+0x4f>
		if (*s1 != *s2)
f01065ce:	0f b6 03             	movzbl (%ebx),%eax
f01065d1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065d4:	83 ef 01             	sub    $0x1,%edi
f01065d7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f01065dc:	38 c8                	cmp    %cl,%al
f01065de:	74 1c                	je     f01065fc <memcmp+0x46>
f01065e0:	eb 10                	jmp    f01065f2 <memcmp+0x3c>
f01065e2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01065e7:	83 c2 01             	add    $0x1,%edx
f01065ea:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01065ee:	38 c8                	cmp    %cl,%al
f01065f0:	74 0a                	je     f01065fc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f01065f2:	0f b6 c0             	movzbl %al,%eax
f01065f5:	0f b6 c9             	movzbl %cl,%ecx
f01065f8:	29 c8                	sub    %ecx,%eax
f01065fa:	eb 09                	jmp    f0106605 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065fc:	39 fa                	cmp    %edi,%edx
f01065fe:	75 e2                	jne    f01065e2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106600:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106605:	5b                   	pop    %ebx
f0106606:	5e                   	pop    %esi
f0106607:	5f                   	pop    %edi
f0106608:	5d                   	pop    %ebp
f0106609:	c3                   	ret    

f010660a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010660a:	55                   	push   %ebp
f010660b:	89 e5                	mov    %esp,%ebp
f010660d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106610:	89 c2                	mov    %eax,%edx
f0106612:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106615:	39 d0                	cmp    %edx,%eax
f0106617:	73 19                	jae    f0106632 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106619:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010661d:	38 08                	cmp    %cl,(%eax)
f010661f:	75 06                	jne    f0106627 <memfind+0x1d>
f0106621:	eb 0f                	jmp    f0106632 <memfind+0x28>
f0106623:	38 08                	cmp    %cl,(%eax)
f0106625:	74 0b                	je     f0106632 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106627:	83 c0 01             	add    $0x1,%eax
f010662a:	39 d0                	cmp    %edx,%eax
f010662c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106630:	75 f1                	jne    f0106623 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106632:	5d                   	pop    %ebp
f0106633:	c3                   	ret    

f0106634 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106634:	55                   	push   %ebp
f0106635:	89 e5                	mov    %esp,%ebp
f0106637:	57                   	push   %edi
f0106638:	56                   	push   %esi
f0106639:	53                   	push   %ebx
f010663a:	8b 55 08             	mov    0x8(%ebp),%edx
f010663d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106640:	0f b6 02             	movzbl (%edx),%eax
f0106643:	3c 20                	cmp    $0x20,%al
f0106645:	74 04                	je     f010664b <strtol+0x17>
f0106647:	3c 09                	cmp    $0x9,%al
f0106649:	75 0e                	jne    f0106659 <strtol+0x25>
		s++;
f010664b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010664e:	0f b6 02             	movzbl (%edx),%eax
f0106651:	3c 20                	cmp    $0x20,%al
f0106653:	74 f6                	je     f010664b <strtol+0x17>
f0106655:	3c 09                	cmp    $0x9,%al
f0106657:	74 f2                	je     f010664b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106659:	3c 2b                	cmp    $0x2b,%al
f010665b:	75 0a                	jne    f0106667 <strtol+0x33>
		s++;
f010665d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106660:	bf 00 00 00 00       	mov    $0x0,%edi
f0106665:	eb 10                	jmp    f0106677 <strtol+0x43>
f0106667:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010666c:	3c 2d                	cmp    $0x2d,%al
f010666e:	75 07                	jne    f0106677 <strtol+0x43>
		s++, neg = 1;
f0106670:	83 c2 01             	add    $0x1,%edx
f0106673:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106677:	85 db                	test   %ebx,%ebx
f0106679:	0f 94 c0             	sete   %al
f010667c:	74 05                	je     f0106683 <strtol+0x4f>
f010667e:	83 fb 10             	cmp    $0x10,%ebx
f0106681:	75 15                	jne    f0106698 <strtol+0x64>
f0106683:	80 3a 30             	cmpb   $0x30,(%edx)
f0106686:	75 10                	jne    f0106698 <strtol+0x64>
f0106688:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010668c:	75 0a                	jne    f0106698 <strtol+0x64>
		s += 2, base = 16;
f010668e:	83 c2 02             	add    $0x2,%edx
f0106691:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106696:	eb 13                	jmp    f01066ab <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0106698:	84 c0                	test   %al,%al
f010669a:	74 0f                	je     f01066ab <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010669c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01066a1:	80 3a 30             	cmpb   $0x30,(%edx)
f01066a4:	75 05                	jne    f01066ab <strtol+0x77>
		s++, base = 8;
f01066a6:	83 c2 01             	add    $0x1,%edx
f01066a9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01066ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01066b0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01066b2:	0f b6 0a             	movzbl (%edx),%ecx
f01066b5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01066b8:	80 fb 09             	cmp    $0x9,%bl
f01066bb:	77 08                	ja     f01066c5 <strtol+0x91>
			dig = *s - '0';
f01066bd:	0f be c9             	movsbl %cl,%ecx
f01066c0:	83 e9 30             	sub    $0x30,%ecx
f01066c3:	eb 1e                	jmp    f01066e3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f01066c5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01066c8:	80 fb 19             	cmp    $0x19,%bl
f01066cb:	77 08                	ja     f01066d5 <strtol+0xa1>
			dig = *s - 'a' + 10;
f01066cd:	0f be c9             	movsbl %cl,%ecx
f01066d0:	83 e9 57             	sub    $0x57,%ecx
f01066d3:	eb 0e                	jmp    f01066e3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f01066d5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01066d8:	80 fb 19             	cmp    $0x19,%bl
f01066db:	77 14                	ja     f01066f1 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01066dd:	0f be c9             	movsbl %cl,%ecx
f01066e0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01066e3:	39 f1                	cmp    %esi,%ecx
f01066e5:	7d 0e                	jge    f01066f5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01066e7:	83 c2 01             	add    $0x1,%edx
f01066ea:	0f af c6             	imul   %esi,%eax
f01066ed:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01066ef:	eb c1                	jmp    f01066b2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01066f1:	89 c1                	mov    %eax,%ecx
f01066f3:	eb 02                	jmp    f01066f7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01066f5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01066f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01066fb:	74 05                	je     f0106702 <strtol+0xce>
		*endptr = (char *) s;
f01066fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106700:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106702:	89 ca                	mov    %ecx,%edx
f0106704:	f7 da                	neg    %edx
f0106706:	85 ff                	test   %edi,%edi
f0106708:	0f 45 c2             	cmovne %edx,%eax
}
f010670b:	5b                   	pop    %ebx
f010670c:	5e                   	pop    %esi
f010670d:	5f                   	pop    %edi
f010670e:	5d                   	pop    %ebp
f010670f:	c3                   	ret    

f0106710 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106710:	fa                   	cli    

	xorw    %ax, %ax
f0106711:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106713:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106715:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106717:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106719:	0f 01 16             	lgdtl  (%esi)
f010671c:	74 70                	je     f010678e <mpentry_end+0x4>
	movl    %cr0, %eax
f010671e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106721:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106725:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106728:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010672e:	08 00                	or     %al,(%eax)

f0106730 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106730:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106734:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106736:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106738:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010673a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010673e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106740:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106742:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0106747:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010674a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010674d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106752:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106755:	8b 25 84 ce 22 f0    	mov    0xf022ce84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010675b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106760:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106765:	ff d0                	call   *%eax

f0106767 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106767:	eb fe                	jmp    f0106767 <spin>
f0106769:	8d 76 00             	lea    0x0(%esi),%esi

f010676c <gdt>:
	...
f0106774:	ff                   	(bad)  
f0106775:	ff 00                	incl   (%eax)
f0106777:	00 00                	add    %al,(%eax)
f0106779:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106780:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106784 <gdtdesc>:
f0106784:	17                   	pop    %ss
f0106785:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010678a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010678a:	90                   	nop
f010678b:	00 00                	add    %al,(%eax)
f010678d:	00 00                	add    %al,(%eax)
	...

f0106790 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106790:	55                   	push   %ebp
f0106791:	89 e5                	mov    %esp,%ebp
f0106793:	56                   	push   %esi
f0106794:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106795:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010679a:	85 d2                	test   %edx,%edx
f010679c:	7e 12                	jle    f01067b0 <sum+0x20>
f010679e:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f01067a3:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f01067a7:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01067a9:	83 c1 01             	add    $0x1,%ecx
f01067ac:	39 d1                	cmp    %edx,%ecx
f01067ae:	75 f3                	jne    f01067a3 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01067b0:	89 d8                	mov    %ebx,%eax
f01067b2:	5b                   	pop    %ebx
f01067b3:	5e                   	pop    %esi
f01067b4:	5d                   	pop    %ebp
f01067b5:	c3                   	ret    

f01067b6 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01067b6:	55                   	push   %ebp
f01067b7:	89 e5                	mov    %esp,%ebp
f01067b9:	56                   	push   %esi
f01067ba:	53                   	push   %ebx
f01067bb:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01067be:	8b 0d 88 ce 22 f0    	mov    0xf022ce88,%ecx
f01067c4:	89 c3                	mov    %eax,%ebx
f01067c6:	c1 eb 0c             	shr    $0xc,%ebx
f01067c9:	39 cb                	cmp    %ecx,%ebx
f01067cb:	72 20                	jb     f01067ed <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01067cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01067d1:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f01067d8:	f0 
f01067d9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01067e0:	00 
f01067e1:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f01067e8:	e8 53 98 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01067ed:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01067f0:	89 f2                	mov    %esi,%edx
f01067f2:	c1 ea 0c             	shr    $0xc,%edx
f01067f5:	39 d1                	cmp    %edx,%ecx
f01067f7:	77 20                	ja     f0106819 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01067f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01067fd:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0106804:	f0 
f0106805:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010680c:	00 
f010680d:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f0106814:	e8 27 98 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106819:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010681f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106825:	39 f3                	cmp    %esi,%ebx
f0106827:	73 3a                	jae    f0106863 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106829:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106830:	00 
f0106831:	c7 44 24 04 11 90 10 	movl   $0xf0109011,0x4(%esp)
f0106838:	f0 
f0106839:	89 1c 24             	mov    %ebx,(%esp)
f010683c:	e8 75 fd ff ff       	call   f01065b6 <memcmp>
f0106841:	85 c0                	test   %eax,%eax
f0106843:	75 10                	jne    f0106855 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106845:	ba 10 00 00 00       	mov    $0x10,%edx
f010684a:	89 d8                	mov    %ebx,%eax
f010684c:	e8 3f ff ff ff       	call   f0106790 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106851:	84 c0                	test   %al,%al
f0106853:	74 13                	je     f0106868 <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106855:	83 c3 10             	add    $0x10,%ebx
f0106858:	39 f3                	cmp    %esi,%ebx
f010685a:	72 cd                	jb     f0106829 <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010685c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106861:	eb 05                	jmp    f0106868 <mpsearch1+0xb2>
f0106863:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106868:	89 d8                	mov    %ebx,%eax
f010686a:	83 c4 10             	add    $0x10,%esp
f010686d:	5b                   	pop    %ebx
f010686e:	5e                   	pop    %esi
f010686f:	5d                   	pop    %ebp
f0106870:	c3                   	ret    

f0106871 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106871:	55                   	push   %ebp
f0106872:	89 e5                	mov    %esp,%ebp
f0106874:	57                   	push   %edi
f0106875:	56                   	push   %esi
f0106876:	53                   	push   %ebx
f0106877:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010687a:	c7 05 c0 d3 22 f0 20 	movl   $0xf022d020,0xf022d3c0
f0106881:	d0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106884:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f010688b:	75 24                	jne    f01068b1 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010688d:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106894:	00 
f0106895:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f010689c:	f0 
f010689d:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01068a4:	00 
f01068a5:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f01068ac:	e8 8f 97 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01068b1:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01068b8:	85 c0                	test   %eax,%eax
f01068ba:	74 16                	je     f01068d2 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01068bc:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01068bf:	ba 00 04 00 00       	mov    $0x400,%edx
f01068c4:	e8 ed fe ff ff       	call   f01067b6 <mpsearch1>
f01068c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01068cc:	85 c0                	test   %eax,%eax
f01068ce:	75 3c                	jne    f010690c <mp_init+0x9b>
f01068d0:	eb 20                	jmp    f01068f2 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01068d2:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01068d9:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01068dc:	2d 00 04 00 00       	sub    $0x400,%eax
f01068e1:	ba 00 04 00 00       	mov    $0x400,%edx
f01068e6:	e8 cb fe ff ff       	call   f01067b6 <mpsearch1>
f01068eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01068ee:	85 c0                	test   %eax,%eax
f01068f0:	75 1a                	jne    f010690c <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01068f2:	ba 00 00 01 00       	mov    $0x10000,%edx
f01068f7:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01068fc:	e8 b5 fe ff ff       	call   f01067b6 <mpsearch1>
f0106901:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106904:	85 c0                	test   %eax,%eax
f0106906:	0f 84 24 02 00 00    	je     f0106b30 <mp_init+0x2bf>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010690c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010690f:	8b 78 04             	mov    0x4(%eax),%edi
f0106912:	85 ff                	test   %edi,%edi
f0106914:	74 06                	je     f010691c <mp_init+0xab>
f0106916:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010691a:	74 11                	je     f010692d <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010691c:	c7 04 24 74 8e 10 f0 	movl   $0xf0108e74,(%esp)
f0106923:	e8 c6 dc ff ff       	call   f01045ee <cprintf>
f0106928:	e9 03 02 00 00       	jmp    f0106b30 <mp_init+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010692d:	89 f8                	mov    %edi,%eax
f010692f:	c1 e8 0c             	shr    $0xc,%eax
f0106932:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0106938:	72 20                	jb     f010695a <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010693a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010693e:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0106945:	f0 
f0106946:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010694d:	00 
f010694e:	c7 04 24 01 90 10 f0 	movl   $0xf0109001,(%esp)
f0106955:	e8 e6 96 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010695a:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106960:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106967:	00 
f0106968:	c7 44 24 04 16 90 10 	movl   $0xf0109016,0x4(%esp)
f010696f:	f0 
f0106970:	89 3c 24             	mov    %edi,(%esp)
f0106973:	e8 3e fc ff ff       	call   f01065b6 <memcmp>
f0106978:	85 c0                	test   %eax,%eax
f010697a:	74 11                	je     f010698d <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010697c:	c7 04 24 a4 8e 10 f0 	movl   $0xf0108ea4,(%esp)
f0106983:	e8 66 dc ff ff       	call   f01045ee <cprintf>
f0106988:	e9 a3 01 00 00       	jmp    f0106b30 <mp_init+0x2bf>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010698d:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106991:	0f b7 d3             	movzwl %bx,%edx
f0106994:	89 f8                	mov    %edi,%eax
f0106996:	e8 f5 fd ff ff       	call   f0106790 <sum>
f010699b:	84 c0                	test   %al,%al
f010699d:	74 11                	je     f01069b0 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010699f:	c7 04 24 d8 8e 10 f0 	movl   $0xf0108ed8,(%esp)
f01069a6:	e8 43 dc ff ff       	call   f01045ee <cprintf>
f01069ab:	e9 80 01 00 00       	jmp    f0106b30 <mp_init+0x2bf>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01069b0:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f01069b4:	3c 01                	cmp    $0x1,%al
f01069b6:	74 1c                	je     f01069d4 <mp_init+0x163>
f01069b8:	3c 04                	cmp    $0x4,%al
f01069ba:	74 18                	je     f01069d4 <mp_init+0x163>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01069bc:	0f b6 c0             	movzbl %al,%eax
f01069bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069c3:	c7 04 24 fc 8e 10 f0 	movl   $0xf0108efc,(%esp)
f01069ca:	e8 1f dc ff ff       	call   f01045ee <cprintf>
f01069cf:	e9 5c 01 00 00       	jmp    f0106b30 <mp_init+0x2bf>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01069d4:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f01069d8:	0f b7 db             	movzwl %bx,%ebx
f01069db:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01069de:	e8 ad fd ff ff       	call   f0106790 <sum>
f01069e3:	3a 47 2a             	cmp    0x2a(%edi),%al
f01069e6:	74 11                	je     f01069f9 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01069e8:	c7 04 24 1c 8f 10 f0 	movl   $0xf0108f1c,(%esp)
f01069ef:	e8 fa db ff ff       	call   f01045ee <cprintf>
f01069f4:	e9 37 01 00 00       	jmp    f0106b30 <mp_init+0x2bf>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01069f9:	85 ff                	test   %edi,%edi
f01069fb:	0f 84 2f 01 00 00    	je     f0106b30 <mp_init+0x2bf>
		return;
	ismp = 1;
f0106a01:	c7 05 00 d0 22 f0 01 	movl   $0x1,0xf022d000
f0106a08:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106a0b:	8b 47 24             	mov    0x24(%edi),%eax
f0106a0e:	a3 00 e0 26 f0       	mov    %eax,0xf026e000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106a13:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106a18:	0f 84 97 00 00 00    	je     f0106ab5 <mp_init+0x244>
f0106a1e:	8d 77 2c             	lea    0x2c(%edi),%esi
f0106a21:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f0106a26:	0f b6 06             	movzbl (%esi),%eax
f0106a29:	84 c0                	test   %al,%al
f0106a2b:	74 06                	je     f0106a33 <mp_init+0x1c2>
f0106a2d:	3c 04                	cmp    $0x4,%al
f0106a2f:	77 54                	ja     f0106a85 <mp_init+0x214>
f0106a31:	eb 4d                	jmp    f0106a80 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106a33:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106a37:	74 11                	je     f0106a4a <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0106a39:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f0106a40:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106a45:	a3 c0 d3 22 f0       	mov    %eax,0xf022d3c0
			if (ncpu < NCPU) {
f0106a4a:	a1 c4 d3 22 f0       	mov    0xf022d3c4,%eax
f0106a4f:	83 f8 07             	cmp    $0x7,%eax
f0106a52:	7f 13                	jg     f0106a67 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f0106a54:	6b d0 74             	imul   $0x74,%eax,%edx
f0106a57:	88 82 20 d0 22 f0    	mov    %al,-0xfdd2fe0(%edx)
				ncpu++;
f0106a5d:	83 c0 01             	add    $0x1,%eax
f0106a60:	a3 c4 d3 22 f0       	mov    %eax,0xf022d3c4
f0106a65:	eb 14                	jmp    f0106a7b <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106a67:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a6f:	c7 04 24 4c 8f 10 f0 	movl   $0xf0108f4c,(%esp)
f0106a76:	e8 73 db ff ff       	call   f01045ee <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106a7b:	83 c6 14             	add    $0x14,%esi
			continue;
f0106a7e:	eb 26                	jmp    f0106aa6 <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106a80:	83 c6 08             	add    $0x8,%esi
			continue;
f0106a83:	eb 21                	jmp    f0106aa6 <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106a85:	0f b6 c0             	movzbl %al,%eax
f0106a88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a8c:	c7 04 24 74 8f 10 f0 	movl   $0xf0108f74,(%esp)
f0106a93:	e8 56 db ff ff       	call   f01045ee <cprintf>
			ismp = 0;
f0106a98:	c7 05 00 d0 22 f0 00 	movl   $0x0,0xf022d000
f0106a9f:	00 00 00 
			i = conf->entry;
f0106aa2:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106aa6:	83 c3 01             	add    $0x1,%ebx
f0106aa9:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106aad:	39 d8                	cmp    %ebx,%eax
f0106aaf:	0f 87 71 ff ff ff    	ja     f0106a26 <mp_init+0x1b5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106ab5:	a1 c0 d3 22 f0       	mov    0xf022d3c0,%eax
f0106aba:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106ac1:	83 3d 00 d0 22 f0 00 	cmpl   $0x0,0xf022d000
f0106ac8:	75 22                	jne    f0106aec <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106aca:	c7 05 c4 d3 22 f0 01 	movl   $0x1,0xf022d3c4
f0106ad1:	00 00 00 
		lapicaddr = 0;
f0106ad4:	c7 05 00 e0 26 f0 00 	movl   $0x0,0xf026e000
f0106adb:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106ade:	c7 04 24 94 8f 10 f0 	movl   $0xf0108f94,(%esp)
f0106ae5:	e8 04 db ff ff       	call   f01045ee <cprintf>
		return;
f0106aea:	eb 44                	jmp    f0106b30 <mp_init+0x2bf>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106aec:	8b 15 c4 d3 22 f0    	mov    0xf022d3c4,%edx
f0106af2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106af6:	0f b6 00             	movzbl (%eax),%eax
f0106af9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106afd:	c7 04 24 1b 90 10 f0 	movl   $0xf010901b,(%esp)
f0106b04:	e8 e5 da ff ff       	call   f01045ee <cprintf>

	if (mp->imcrp) {
f0106b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106b0c:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106b10:	74 1e                	je     f0106b30 <mp_init+0x2bf>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106b12:	c7 04 24 c0 8f 10 f0 	movl   $0xf0108fc0,(%esp)
f0106b19:	e8 d0 da ff ff       	call   f01045ee <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b1e:	ba 22 00 00 00       	mov    $0x22,%edx
f0106b23:	b8 70 00 00 00       	mov    $0x70,%eax
f0106b28:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106b29:	b2 23                	mov    $0x23,%dl
f0106b2b:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106b2c:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b2f:	ee                   	out    %al,(%dx)
	}
}
f0106b30:	83 c4 2c             	add    $0x2c,%esp
f0106b33:	5b                   	pop    %ebx
f0106b34:	5e                   	pop    %esi
f0106b35:	5f                   	pop    %edi
f0106b36:	5d                   	pop    %ebp
f0106b37:	c3                   	ret    

f0106b38 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106b38:	55                   	push   %ebp
f0106b39:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106b3b:	c1 e0 02             	shl    $0x2,%eax
f0106b3e:	03 05 04 e0 26 f0    	add    0xf026e004,%eax
f0106b44:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106b46:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f0106b4b:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106b4e:	5d                   	pop    %ebp
f0106b4f:	c3                   	ret    

f0106b50 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106b50:	55                   	push   %ebp
f0106b51:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106b53:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106b59:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f0106b5e:	85 d2                	test   %edx,%edx
f0106b60:	74 06                	je     f0106b68 <cpunum+0x18>
		return lapic[ID] >> 24;
f0106b62:	8b 42 20             	mov    0x20(%edx),%eax
f0106b65:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106b68:	5d                   	pop    %ebp
f0106b69:	c3                   	ret    

f0106b6a <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106b6a:	55                   	push   %ebp
f0106b6b:	89 e5                	mov    %esp,%ebp
f0106b6d:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106b70:	a1 00 e0 26 f0       	mov    0xf026e000,%eax
f0106b75:	85 c0                	test   %eax,%eax
f0106b77:	0f 84 1c 01 00 00    	je     f0106c99 <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106b7d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106b84:	00 
f0106b85:	89 04 24             	mov    %eax,(%esp)
f0106b88:	e8 63 af ff ff       	call   f0101af0 <mmio_map_region>
f0106b8d:	a3 04 e0 26 f0       	mov    %eax,0xf026e004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106b92:	ba 27 01 00 00       	mov    $0x127,%edx
f0106b97:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106b9c:	e8 97 ff ff ff       	call   f0106b38 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106ba1:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106ba6:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106bab:	e8 88 ff ff ff       	call   f0106b38 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106bb0:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106bb5:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106bba:	e8 79 ff ff ff       	call   f0106b38 <lapicw>
	lapicw(TICR, 10000000); 
f0106bbf:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106bc4:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106bc9:	e8 6a ff ff ff       	call   f0106b38 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106bce:	e8 7d ff ff ff       	call   f0106b50 <cpunum>
f0106bd3:	6b c0 74             	imul   $0x74,%eax,%eax
f0106bd6:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106bdb:	39 05 c0 d3 22 f0    	cmp    %eax,0xf022d3c0
f0106be1:	74 0f                	je     f0106bf2 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106be3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106be8:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106bed:	e8 46 ff ff ff       	call   f0106b38 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106bf2:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106bf7:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106bfc:	e8 37 ff ff ff       	call   f0106b38 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106c01:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f0106c06:	8b 40 30             	mov    0x30(%eax),%eax
f0106c09:	c1 e8 10             	shr    $0x10,%eax
f0106c0c:	3c 03                	cmp    $0x3,%al
f0106c0e:	76 0f                	jbe    f0106c1f <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106c10:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106c15:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106c1a:	e8 19 ff ff ff       	call   f0106b38 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106c1f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106c24:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106c29:	e8 0a ff ff ff       	call   f0106b38 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106c2e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c33:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106c38:	e8 fb fe ff ff       	call   f0106b38 <lapicw>
	lapicw(ESR, 0);
f0106c3d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c42:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106c47:	e8 ec fe ff ff       	call   f0106b38 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106c4c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c51:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106c56:	e8 dd fe ff ff       	call   f0106b38 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106c5b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c60:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106c65:	e8 ce fe ff ff       	call   f0106b38 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106c6a:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106c6f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106c74:	e8 bf fe ff ff       	call   f0106b38 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106c79:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f0106c7f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106c85:	f6 c4 10             	test   $0x10,%ah
f0106c88:	75 f5                	jne    f0106c7f <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106c8a:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c8f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c94:	e8 9f fe ff ff       	call   f0106b38 <lapicw>
}
f0106c99:	c9                   	leave  
f0106c9a:	c3                   	ret    

f0106c9b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106c9b:	55                   	push   %ebp
f0106c9c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106c9e:	83 3d 04 e0 26 f0 00 	cmpl   $0x0,0xf026e004
f0106ca5:	74 0f                	je     f0106cb6 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0106ca7:	ba 00 00 00 00       	mov    $0x0,%edx
f0106cac:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106cb1:	e8 82 fe ff ff       	call   f0106b38 <lapicw>
}
f0106cb6:	5d                   	pop    %ebp
f0106cb7:	c3                   	ret    

f0106cb8 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106cb8:	55                   	push   %ebp
f0106cb9:	89 e5                	mov    %esp,%ebp
f0106cbb:	56                   	push   %esi
f0106cbc:	53                   	push   %ebx
f0106cbd:	83 ec 10             	sub    $0x10,%esp
f0106cc0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106cc3:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0106cc7:	ba 70 00 00 00       	mov    $0x70,%edx
f0106ccc:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106cd1:	ee                   	out    %al,(%dx)
f0106cd2:	b2 71                	mov    $0x71,%dl
f0106cd4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106cd9:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106cda:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f0106ce1:	75 24                	jne    f0106d07 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106ce3:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106cea:	00 
f0106ceb:	c7 44 24 08 e8 72 10 	movl   $0xf01072e8,0x8(%esp)
f0106cf2:	f0 
f0106cf3:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106cfa:	00 
f0106cfb:	c7 04 24 38 90 10 f0 	movl   $0xf0109038,(%esp)
f0106d02:	e8 39 93 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106d07:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106d0e:	00 00 
	wrv[1] = addr >> 4;
f0106d10:	89 f0                	mov    %esi,%eax
f0106d12:	c1 e8 04             	shr    $0x4,%eax
f0106d15:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106d1b:	c1 e3 18             	shl    $0x18,%ebx
f0106d1e:	89 da                	mov    %ebx,%edx
f0106d20:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d25:	e8 0e fe ff ff       	call   f0106b38 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106d2a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106d2f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d34:	e8 ff fd ff ff       	call   f0106b38 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106d39:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106d3e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d43:	e8 f0 fd ff ff       	call   f0106b38 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d48:	c1 ee 0c             	shr    $0xc,%esi
f0106d4b:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d51:	89 da                	mov    %ebx,%edx
f0106d53:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d58:	e8 db fd ff ff       	call   f0106b38 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d5d:	89 f2                	mov    %esi,%edx
f0106d5f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d64:	e8 cf fd ff ff       	call   f0106b38 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d69:	89 da                	mov    %ebx,%edx
f0106d6b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d70:	e8 c3 fd ff ff       	call   f0106b38 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d75:	89 f2                	mov    %esi,%edx
f0106d77:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d7c:	e8 b7 fd ff ff       	call   f0106b38 <lapicw>
		microdelay(200);
	}
}
f0106d81:	83 c4 10             	add    $0x10,%esp
f0106d84:	5b                   	pop    %ebx
f0106d85:	5e                   	pop    %esi
f0106d86:	5d                   	pop    %ebp
f0106d87:	c3                   	ret    

f0106d88 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106d88:	55                   	push   %ebp
f0106d89:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106d8b:	8b 55 08             	mov    0x8(%ebp),%edx
f0106d8e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106d94:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d99:	e8 9a fd ff ff       	call   f0106b38 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106d9e:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f0106da4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106daa:	f6 c4 10             	test   $0x10,%ah
f0106dad:	75 f5                	jne    f0106da4 <lapic_ipi+0x1c>
		;
}
f0106daf:	5d                   	pop    %ebp
f0106db0:	c3                   	ret    
f0106db1:	00 00                	add    %al,(%eax)
	...

f0106db4 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106db4:	55                   	push   %ebp
f0106db5:	89 e5                	mov    %esp,%ebp
f0106db7:	53                   	push   %ebx
f0106db8:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106dbb:	ba 00 00 00 00       	mov    $0x0,%edx
f0106dc0:	83 38 00             	cmpl   $0x0,(%eax)
f0106dc3:	74 18                	je     f0106ddd <holding+0x29>
f0106dc5:	8b 58 08             	mov    0x8(%eax),%ebx
f0106dc8:	e8 83 fd ff ff       	call   f0106b50 <cpunum>
f0106dcd:	6b c0 74             	imul   $0x74,%eax,%eax
f0106dd0:	05 20 d0 22 f0       	add    $0xf022d020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106dd5:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106dd7:	0f 94 c2             	sete   %dl
f0106dda:	0f b6 d2             	movzbl %dl,%edx
}
f0106ddd:	89 d0                	mov    %edx,%eax
f0106ddf:	83 c4 04             	add    $0x4,%esp
f0106de2:	5b                   	pop    %ebx
f0106de3:	5d                   	pop    %ebp
f0106de4:	c3                   	ret    

f0106de5 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106de5:	55                   	push   %ebp
f0106de6:	89 e5                	mov    %esp,%ebp
f0106de8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106deb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106df1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106df4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106df7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106dfe:	5d                   	pop    %ebp
f0106dff:	c3                   	ret    

f0106e00 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106e00:	55                   	push   %ebp
f0106e01:	89 e5                	mov    %esp,%ebp
f0106e03:	53                   	push   %ebx
f0106e04:	83 ec 24             	sub    $0x24,%esp
f0106e07:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106e0a:	89 d8                	mov    %ebx,%eax
f0106e0c:	e8 a3 ff ff ff       	call   f0106db4 <holding>
f0106e11:	85 c0                	test   %eax,%eax
f0106e13:	75 12                	jne    f0106e27 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106e15:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106e17:	b0 01                	mov    $0x1,%al
f0106e19:	f0 87 03             	lock xchg %eax,(%ebx)
f0106e1c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106e21:	85 c0                	test   %eax,%eax
f0106e23:	75 2e                	jne    f0106e53 <spin_lock+0x53>
f0106e25:	eb 37                	jmp    f0106e5e <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106e27:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106e2a:	e8 21 fd ff ff       	call   f0106b50 <cpunum>
f0106e2f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106e33:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106e37:	c7 44 24 08 48 90 10 	movl   $0xf0109048,0x8(%esp)
f0106e3e:	f0 
f0106e3f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106e46:	00 
f0106e47:	c7 04 24 ac 90 10 f0 	movl   $0xf01090ac,(%esp)
f0106e4e:	e8 ed 91 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106e53:	f3 90                	pause  
f0106e55:	89 c8                	mov    %ecx,%eax
f0106e57:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106e5a:	85 c0                	test   %eax,%eax
f0106e5c:	75 f5                	jne    f0106e53 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106e5e:	e8 ed fc ff ff       	call   f0106b50 <cpunum>
f0106e63:	6b c0 74             	imul   $0x74,%eax,%eax
f0106e66:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106e6b:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106e6e:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106e71:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106e73:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106e78:	77 34                	ja     f0106eae <spin_lock+0xae>
f0106e7a:	eb 2b                	jmp    f0106ea7 <spin_lock+0xa7>
f0106e7c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106e82:	76 12                	jbe    f0106e96 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106e84:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106e87:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106e8a:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106e8c:	83 c0 01             	add    $0x1,%eax
f0106e8f:	83 f8 0a             	cmp    $0xa,%eax
f0106e92:	75 e8                	jne    f0106e7c <spin_lock+0x7c>
f0106e94:	eb 27                	jmp    f0106ebd <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106e96:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106e9d:	83 c0 01             	add    $0x1,%eax
f0106ea0:	83 f8 09             	cmp    $0x9,%eax
f0106ea3:	7e f1                	jle    f0106e96 <spin_lock+0x96>
f0106ea5:	eb 16                	jmp    f0106ebd <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106ea7:	b8 00 00 00 00       	mov    $0x0,%eax
f0106eac:	eb e8                	jmp    f0106e96 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106eae:	8b 50 04             	mov    0x4(%eax),%edx
f0106eb1:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106eb4:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106eb6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106ebb:	eb bf                	jmp    f0106e7c <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106ebd:	83 c4 24             	add    $0x24,%esp
f0106ec0:	5b                   	pop    %ebx
f0106ec1:	5d                   	pop    %ebp
f0106ec2:	c3                   	ret    

f0106ec3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106ec3:	55                   	push   %ebp
f0106ec4:	89 e5                	mov    %esp,%ebp
f0106ec6:	83 ec 78             	sub    $0x78,%esp
f0106ec9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106ecc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106ecf:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106ed2:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ed5:	89 d8                	mov    %ebx,%eax
f0106ed7:	e8 d8 fe ff ff       	call   f0106db4 <holding>
f0106edc:	85 c0                	test   %eax,%eax
f0106ede:	0f 85 d4 00 00 00    	jne    f0106fb8 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106ee4:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106eeb:	00 
f0106eec:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106eef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ef3:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106ef6:	89 04 24             	mov    %eax,(%esp)
f0106ef9:	e8 1e f6 ff ff       	call   f010651c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106efe:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106f01:	0f b6 30             	movzbl (%eax),%esi
f0106f04:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106f07:	e8 44 fc ff ff       	call   f0106b50 <cpunum>
f0106f0c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106f10:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106f14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f18:	c7 04 24 74 90 10 f0 	movl   $0xf0109074,(%esp)
f0106f1f:	e8 ca d6 ff ff       	call   f01045ee <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106f24:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106f27:	85 c0                	test   %eax,%eax
f0106f29:	74 71                	je     f0106f9c <spin_unlock+0xd9>
f0106f2b:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106f2e:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106f31:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106f34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106f38:	89 04 24             	mov    %eax,(%esp)
f0106f3b:	e8 be e8 ff ff       	call   f01057fe <debuginfo_eip>
f0106f40:	85 c0                	test   %eax,%eax
f0106f42:	78 39                	js     f0106f7d <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106f44:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106f46:	89 c2                	mov    %eax,%edx
f0106f48:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106f4b:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106f4f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106f52:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106f56:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106f59:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106f5d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106f60:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106f64:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106f67:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f6f:	c7 04 24 bc 90 10 f0 	movl   $0xf01090bc,(%esp)
f0106f76:	e8 73 d6 ff ff       	call   f01045ee <cprintf>
f0106f7b:	eb 12                	jmp    f0106f8f <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106f7d:	8b 03                	mov    (%ebx),%eax
f0106f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f83:	c7 04 24 d3 90 10 f0 	movl   $0xf01090d3,(%esp)
f0106f8a:	e8 5f d6 ff ff       	call   f01045ee <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106f8f:	39 fb                	cmp    %edi,%ebx
f0106f91:	74 09                	je     f0106f9c <spin_unlock+0xd9>
f0106f93:	83 c3 04             	add    $0x4,%ebx
f0106f96:	8b 03                	mov    (%ebx),%eax
f0106f98:	85 c0                	test   %eax,%eax
f0106f9a:	75 98                	jne    f0106f34 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106f9c:	c7 44 24 08 db 90 10 	movl   $0xf01090db,0x8(%esp)
f0106fa3:	f0 
f0106fa4:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106fab:	00 
f0106fac:	c7 04 24 ac 90 10 f0 	movl   $0xf01090ac,(%esp)
f0106fb3:	e8 88 90 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106fb8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106fbf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106fc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0106fcb:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106fce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106fd1:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106fd4:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106fd7:	89 ec                	mov    %ebp,%esp
f0106fd9:	5d                   	pop    %ebp
f0106fda:	c3                   	ret    
f0106fdb:	00 00                	add    %al,(%eax)
f0106fdd:	00 00                	add    %al,(%eax)
	...

f0106fe0 <__udivdi3>:
f0106fe0:	83 ec 1c             	sub    $0x1c,%esp
f0106fe3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106fe7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0106feb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106fef:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106ff3:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106ff7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106ffb:	85 ff                	test   %edi,%edi
f0106ffd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0107001:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107005:	89 cd                	mov    %ecx,%ebp
f0107007:	89 44 24 04          	mov    %eax,0x4(%esp)
f010700b:	75 33                	jne    f0107040 <__udivdi3+0x60>
f010700d:	39 f1                	cmp    %esi,%ecx
f010700f:	77 57                	ja     f0107068 <__udivdi3+0x88>
f0107011:	85 c9                	test   %ecx,%ecx
f0107013:	75 0b                	jne    f0107020 <__udivdi3+0x40>
f0107015:	b8 01 00 00 00       	mov    $0x1,%eax
f010701a:	31 d2                	xor    %edx,%edx
f010701c:	f7 f1                	div    %ecx
f010701e:	89 c1                	mov    %eax,%ecx
f0107020:	89 f0                	mov    %esi,%eax
f0107022:	31 d2                	xor    %edx,%edx
f0107024:	f7 f1                	div    %ecx
f0107026:	89 c6                	mov    %eax,%esi
f0107028:	8b 44 24 04          	mov    0x4(%esp),%eax
f010702c:	f7 f1                	div    %ecx
f010702e:	89 f2                	mov    %esi,%edx
f0107030:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107034:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107038:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010703c:	83 c4 1c             	add    $0x1c,%esp
f010703f:	c3                   	ret    
f0107040:	31 d2                	xor    %edx,%edx
f0107042:	31 c0                	xor    %eax,%eax
f0107044:	39 f7                	cmp    %esi,%edi
f0107046:	77 e8                	ja     f0107030 <__udivdi3+0x50>
f0107048:	0f bd cf             	bsr    %edi,%ecx
f010704b:	83 f1 1f             	xor    $0x1f,%ecx
f010704e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0107052:	75 2c                	jne    f0107080 <__udivdi3+0xa0>
f0107054:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0107058:	76 04                	jbe    f010705e <__udivdi3+0x7e>
f010705a:	39 f7                	cmp    %esi,%edi
f010705c:	73 d2                	jae    f0107030 <__udivdi3+0x50>
f010705e:	31 d2                	xor    %edx,%edx
f0107060:	b8 01 00 00 00       	mov    $0x1,%eax
f0107065:	eb c9                	jmp    f0107030 <__udivdi3+0x50>
f0107067:	90                   	nop
f0107068:	89 f2                	mov    %esi,%edx
f010706a:	f7 f1                	div    %ecx
f010706c:	31 d2                	xor    %edx,%edx
f010706e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107072:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107076:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010707a:	83 c4 1c             	add    $0x1c,%esp
f010707d:	c3                   	ret    
f010707e:	66 90                	xchg   %ax,%ax
f0107080:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107085:	b8 20 00 00 00       	mov    $0x20,%eax
f010708a:	89 ea                	mov    %ebp,%edx
f010708c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0107090:	d3 e7                	shl    %cl,%edi
f0107092:	89 c1                	mov    %eax,%ecx
f0107094:	d3 ea                	shr    %cl,%edx
f0107096:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010709b:	09 fa                	or     %edi,%edx
f010709d:	89 f7                	mov    %esi,%edi
f010709f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01070a3:	89 f2                	mov    %esi,%edx
f01070a5:	8b 74 24 08          	mov    0x8(%esp),%esi
f01070a9:	d3 e5                	shl    %cl,%ebp
f01070ab:	89 c1                	mov    %eax,%ecx
f01070ad:	d3 ef                	shr    %cl,%edi
f01070af:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01070b4:	d3 e2                	shl    %cl,%edx
f01070b6:	89 c1                	mov    %eax,%ecx
f01070b8:	d3 ee                	shr    %cl,%esi
f01070ba:	09 d6                	or     %edx,%esi
f01070bc:	89 fa                	mov    %edi,%edx
f01070be:	89 f0                	mov    %esi,%eax
f01070c0:	f7 74 24 0c          	divl   0xc(%esp)
f01070c4:	89 d7                	mov    %edx,%edi
f01070c6:	89 c6                	mov    %eax,%esi
f01070c8:	f7 e5                	mul    %ebp
f01070ca:	39 d7                	cmp    %edx,%edi
f01070cc:	72 22                	jb     f01070f0 <__udivdi3+0x110>
f01070ce:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01070d2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01070d7:	d3 e5                	shl    %cl,%ebp
f01070d9:	39 c5                	cmp    %eax,%ebp
f01070db:	73 04                	jae    f01070e1 <__udivdi3+0x101>
f01070dd:	39 d7                	cmp    %edx,%edi
f01070df:	74 0f                	je     f01070f0 <__udivdi3+0x110>
f01070e1:	89 f0                	mov    %esi,%eax
f01070e3:	31 d2                	xor    %edx,%edx
f01070e5:	e9 46 ff ff ff       	jmp    f0107030 <__udivdi3+0x50>
f01070ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01070f0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01070f3:	31 d2                	xor    %edx,%edx
f01070f5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01070f9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01070fd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0107101:	83 c4 1c             	add    $0x1c,%esp
f0107104:	c3                   	ret    
	...

f0107110 <__umoddi3>:
f0107110:	83 ec 1c             	sub    $0x1c,%esp
f0107113:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0107117:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010711b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010711f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107123:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0107127:	8b 74 24 24          	mov    0x24(%esp),%esi
f010712b:	85 ed                	test   %ebp,%ebp
f010712d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0107131:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107135:	89 cf                	mov    %ecx,%edi
f0107137:	89 04 24             	mov    %eax,(%esp)
f010713a:	89 f2                	mov    %esi,%edx
f010713c:	75 1a                	jne    f0107158 <__umoddi3+0x48>
f010713e:	39 f1                	cmp    %esi,%ecx
f0107140:	76 4e                	jbe    f0107190 <__umoddi3+0x80>
f0107142:	f7 f1                	div    %ecx
f0107144:	89 d0                	mov    %edx,%eax
f0107146:	31 d2                	xor    %edx,%edx
f0107148:	8b 74 24 10          	mov    0x10(%esp),%esi
f010714c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107150:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0107154:	83 c4 1c             	add    $0x1c,%esp
f0107157:	c3                   	ret    
f0107158:	39 f5                	cmp    %esi,%ebp
f010715a:	77 54                	ja     f01071b0 <__umoddi3+0xa0>
f010715c:	0f bd c5             	bsr    %ebp,%eax
f010715f:	83 f0 1f             	xor    $0x1f,%eax
f0107162:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107166:	75 60                	jne    f01071c8 <__umoddi3+0xb8>
f0107168:	3b 0c 24             	cmp    (%esp),%ecx
f010716b:	0f 87 07 01 00 00    	ja     f0107278 <__umoddi3+0x168>
f0107171:	89 f2                	mov    %esi,%edx
f0107173:	8b 34 24             	mov    (%esp),%esi
f0107176:	29 ce                	sub    %ecx,%esi
f0107178:	19 ea                	sbb    %ebp,%edx
f010717a:	89 34 24             	mov    %esi,(%esp)
f010717d:	8b 04 24             	mov    (%esp),%eax
f0107180:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107184:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107188:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010718c:	83 c4 1c             	add    $0x1c,%esp
f010718f:	c3                   	ret    
f0107190:	85 c9                	test   %ecx,%ecx
f0107192:	75 0b                	jne    f010719f <__umoddi3+0x8f>
f0107194:	b8 01 00 00 00       	mov    $0x1,%eax
f0107199:	31 d2                	xor    %edx,%edx
f010719b:	f7 f1                	div    %ecx
f010719d:	89 c1                	mov    %eax,%ecx
f010719f:	89 f0                	mov    %esi,%eax
f01071a1:	31 d2                	xor    %edx,%edx
f01071a3:	f7 f1                	div    %ecx
f01071a5:	8b 04 24             	mov    (%esp),%eax
f01071a8:	f7 f1                	div    %ecx
f01071aa:	eb 98                	jmp    f0107144 <__umoddi3+0x34>
f01071ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01071b0:	89 f2                	mov    %esi,%edx
f01071b2:	8b 74 24 10          	mov    0x10(%esp),%esi
f01071b6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01071ba:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01071be:	83 c4 1c             	add    $0x1c,%esp
f01071c1:	c3                   	ret    
f01071c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01071c8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01071cd:	89 e8                	mov    %ebp,%eax
f01071cf:	bd 20 00 00 00       	mov    $0x20,%ebp
f01071d4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01071d8:	89 fa                	mov    %edi,%edx
f01071da:	d3 e0                	shl    %cl,%eax
f01071dc:	89 e9                	mov    %ebp,%ecx
f01071de:	d3 ea                	shr    %cl,%edx
f01071e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01071e5:	09 c2                	or     %eax,%edx
f01071e7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01071eb:	89 14 24             	mov    %edx,(%esp)
f01071ee:	89 f2                	mov    %esi,%edx
f01071f0:	d3 e7                	shl    %cl,%edi
f01071f2:	89 e9                	mov    %ebp,%ecx
f01071f4:	d3 ea                	shr    %cl,%edx
f01071f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01071fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01071ff:	d3 e6                	shl    %cl,%esi
f0107201:	89 e9                	mov    %ebp,%ecx
f0107203:	d3 e8                	shr    %cl,%eax
f0107205:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010720a:	09 f0                	or     %esi,%eax
f010720c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0107210:	f7 34 24             	divl   (%esp)
f0107213:	d3 e6                	shl    %cl,%esi
f0107215:	89 74 24 08          	mov    %esi,0x8(%esp)
f0107219:	89 d6                	mov    %edx,%esi
f010721b:	f7 e7                	mul    %edi
f010721d:	39 d6                	cmp    %edx,%esi
f010721f:	89 c1                	mov    %eax,%ecx
f0107221:	89 d7                	mov    %edx,%edi
f0107223:	72 3f                	jb     f0107264 <__umoddi3+0x154>
f0107225:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0107229:	72 35                	jb     f0107260 <__umoddi3+0x150>
f010722b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010722f:	29 c8                	sub    %ecx,%eax
f0107231:	19 fe                	sbb    %edi,%esi
f0107233:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107238:	89 f2                	mov    %esi,%edx
f010723a:	d3 e8                	shr    %cl,%eax
f010723c:	89 e9                	mov    %ebp,%ecx
f010723e:	d3 e2                	shl    %cl,%edx
f0107240:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107245:	09 d0                	or     %edx,%eax
f0107247:	89 f2                	mov    %esi,%edx
f0107249:	d3 ea                	shr    %cl,%edx
f010724b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010724f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107253:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0107257:	83 c4 1c             	add    $0x1c,%esp
f010725a:	c3                   	ret    
f010725b:	90                   	nop
f010725c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107260:	39 d6                	cmp    %edx,%esi
f0107262:	75 c7                	jne    f010722b <__umoddi3+0x11b>
f0107264:	89 d7                	mov    %edx,%edi
f0107266:	89 c1                	mov    %eax,%ecx
f0107268:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010726c:	1b 3c 24             	sbb    (%esp),%edi
f010726f:	eb ba                	jmp    f010722b <__umoddi3+0x11b>
f0107271:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107278:	39 f5                	cmp    %esi,%ebp
f010727a:	0f 82 f1 fe ff ff    	jb     f0107171 <__umoddi3+0x61>
f0107280:	e9 f8 fe ff ff       	jmp    f010717d <__umoddi3+0x6d>
